import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/stable_tooltip.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../state/app_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/generated/meter.pbgrpc.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../routes/app_routes.dart';
import '../../core/widget_keys.dart';
import '../../core/services/feedback_service.dart';

/// Firmware Download Screen
/// ImplÃ©mentation Flutter de la maquette `firmware_download_interface.html`
/// Principales fonctionnalitÃ©s simulÃ©es:
/// - Navigation latÃ©rale (sidebar)
/// - Breadcrumb + Header
/// - SystÃ¨me d'onglets (ParamÃ¨tres / TÃ©lÃ©chargement / Ã‰tat des blocs)
/// - SÃ©lection de fichier firmware (FilePicker)
/// - ParamÃ¨tres (Authorization Transfer, Size Block, First Block Not Transferred)
/// - Activation Date & Time (sÃ©lection date/heure)
/// - Simulation de tÃ©lÃ©chargement avec progression + mise Ã  jour des blocs
/// - Table d'Ã©tat des blocs avec statut, checksum, retry, last update
class FirmwareDownloadPage extends ConsumerStatefulWidget {
  const FirmwareDownloadPage({
    super.key,
    @visibleForTesting this.testFirmwareFileName,
    @visibleForTesting this.testFirmwareFilePath,
    @visibleForTesting this.testFirmwareFileSize = 0,
  });

  @visibleForTesting
  final String? testFirmwareFileName;
  @visibleForTesting
  final String? testFirmwareFilePath;
  @visibleForTesting
  final int testFirmwareFileSize;

  @override
  ConsumerState<FirmwareDownloadPage> createState() =>
      _FirmwareDownloadPageState();
}

class _FirmwareDownloadPageState extends ConsumerState<FirmwareDownloadPage>
    with SingleTickerProviderStateMixin {
  late final IMeterClient client;
  final GlobalKey _activationDateCardKey = GlobalKey();
  double? _activationDateCardHeight;
  StreamSubscription? _subscription;
  // Tabs
  int _currentTab = 0; // 0: Params, 1: Download, 2: Blocks

  // Parameters
  bool _authorizationGranted = false;
  final TextEditingController _blockSizeCtrl = TextEditingController(text: '');
  final TextEditingController _firstBlockNotTransferredCtrl =
      TextEditingController(text: '0');

  // Activation date/time
  int _activationYear = DateTime.now().year;
  int _activationMonth = DateTime.now().month;
  int _activationDay = DateTime.now().day;
  int _activationHour = DateTime.now().hour;
  int _activationMinute = DateTime.now().minute;
  int _activationSecond = DateTime.now().second;

  // Firmware process inputs
  final TextEditingController _imageIdCtrl = TextEditingController();
  String? _channel; // optional
  String? _firmwareFileName;
  String? _firmwareFilePath;
  int _firmwareFileSize = 0; // bytes (simulÃ©)

  // Download state
  double _progress = 0.0; // 0..1
  int _totalBlocks = 0; // calculÃ© sur sÃ©lection fichier / block size
  int _transferredBlocks = 0;
  bool _isDownloading = false;
  bool _isPickingFile = false;
  bool _isCompleted = false;
  bool _isCancelled = false;
  Timer? _downloadTimer;

  // Transfer state status
  TransferStatus _transferStatus = TransferStatus.notInitiated;

  // Blocks table (nous limitons Ã  un Ã©chantillon pour performance visuelle)
  final List<BlockInfo> _blocks = [];
  final int _maxVisualBlocks = 100; // la maquette montre potentiellement > 1000

  // Random simulation helpers
  final _rnd = DateTime.now().millisecondsSinceEpoch % 7919;

  @override
  void dispose() {
    _blockSizeCtrl.dispose();
    _firstBlockNotTransferredCtrl.dispose();
    _imageIdCtrl.dispose();
    _downloadTimer?.cancel();
    // Persist cancelled download progress so the user can resume on return.
    if (_isCancelled && _firmwareFilePath != null) {
      _saveProgress();
    }
    // Ensure the nav-lock is released if the page is disposed mid-download.
    ref.read(appControllerProvider.notifier).setFirmwareDownloading(false);
    super.dispose();
  }

  // UI COLOR TOKENS (inspirÃ©s de la maquette)
  static const Color cPrimary600 = Color(0xFF1976D2);
  static const Color cPrimary500 = Color(0xFF2196F3);
  static const Color cPrimary50 = Color(0xFFE3F2FD);
  static const Color cInfo = Color(0xFF2196F3);
  static const Color cSuccess = Color(0xFF4CAF50);
  static const Color cWarning = Color(0xFFFF9800);
  static const Color cDanger = Color(0xFFF44336);
  static const Color cGray100 = Color(0xFFF5F5F5);
  static const Color cGray600 = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    client = meterClientFactory();
    // Initialize from current state once
    final initialImageId =
        ref.read(appControllerProvider).firmwareUpgrade.imageId ?? '';
    _imageIdCtrl.text = initialImageId;

    final initialBlockSize =
        ref.read(appControllerProvider).firmwareUpgrade.blockSize ?? 0;
    _blockSizeCtrl.text = '$initialBlockSize';

    // Test injection: pre-populate file fields without FilePicker
    if (widget.testFirmwareFileName != null) {
      _firmwareFileName = widget.testFirmwareFileName;
      _firmwareFilePath = widget.testFirmwareFilePath;
      _firmwareFileSize = widget.testFirmwareFileSize;
      final int bsz = initialBlockSize > 0 ? initialBlockSize : 96;
      _totalBlocks = _firmwareFileSize > 0
          ? (_firmwareFileSize / bsz).ceil()
          : (240 * 1024 / bsz).ceil();
    } else {
      // Restore persisted download progress from a previous cancel.
      final fw = ref.read(appControllerProvider).firmwareUpgrade;
      if (fw.isCancelled && fw.filePath != null) {
        _firmwareFilePath = fw.filePath;
        _firmwareFileName = fw.fileName;
        _firmwareFileSize = fw.fileSize;
        _transferredBlocks = fw.transferredBlocks;
        _totalBlocks = fw.totalBlocks;
        _isCancelled = true;
        _progress =
            fw.totalBlocks > 0 ? fw.transferredBlocks / fw.totalBlocks : 0.0;
        _firstBlockNotTransferredCtrl.text = '${fw.transferredBlocks}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firmware Upgrade"),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          RefreshAppBarButton(onPressed: _resetTransfer),
        ],
      ),
      drawer: const AppDrawer(),
      backgroundColor: DesignTokens.backgroundOf(context),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceOf(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTabs(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildTabContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER / BREADCRUMB ----------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    _breadcrumbText('Menu'),
                    _breadcrumbIcon(),
                    _breadcrumbText('Firmware Upgrade'),
                    _breadcrumbIcon(),
                    _breadcrumbText('Firmware Download', active: true),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Firmware Download',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Download, flash, and activate firmware via DLMS/COSEM',
                    style: TextStyle(
                        fontSize: 14,
                        color: DesignTokens.textSecondaryOf(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumbText(String text, {bool active = false}) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? cPrimary600 : DesignTokens.textSecondaryOf(context)));

  Widget _breadcrumbIcon() => Icon(Icons.chevron_right,
      size: 16, color: DesignTokens.textSecondaryOf(context));

  Widget _iconCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return StableTooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.borderOf(context)),
              color: DesignTokens.surfaceOf(context),
            ),
            child: Icon(icon, color: DesignTokens.textSecondaryOf(context)),
          ),
        ),
      ),
    );
  }

  // ---------- TABS ----------
  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        children: [
          _tabButton(0, Icons.settings, 'Settings',
              key: const Key(FirmwareDownloadKeys.settingsTabBtn)),
          _tabButton(1, Icons.cloud_download, 'Download',
              key: const Key(FirmwareDownloadKeys.downloadTabBtn)),
          _tabButton(2, Icons.view_list, 'Block Status',
              key: const Key(FirmwareDownloadKeys.blocksTabBtn)),
        ],
      ),
    );
  }

  Widget _tabButton(int index, IconData icon, String label, {Key? key}) {
    final bool active = _currentTab == index;
    final bool isDark = DesignTokens.isDark(context);
    return Expanded(
      child: InkWell(
        key: key,
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? DesignTokens.darkSurfaceAlt : cPrimary50)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                  color: active ? cPrimary600 : Colors.transparent, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 19,
                  color: active
                      ? cPrimary600
                      : DesignTokens.textSecondaryOf(context)),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? cPrimary600
                        : DesignTokens.textSecondaryOf(context),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildParametersTab();
      case 1:
        return _buildDownloadTab();
      case 2:
        return _buildBlocksTab();
      default:
        return const SizedBox();
    }
  }

  // ---------- TAB 1 : PARAMÃˆTRES ----------
  Widget _buildParametersTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0),
          _sectionTitle(
            icon: Icons.tune,
            iconColor: cInfo,
            title: 'Firmware Parameters',
            tooltip: 'Firmware transfer configuration settings',
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: constraints.maxWidth < 700
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 32) / 2,
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _formLabel('Authorization Transfer',
                              tooltip: 'Permission to transfer firmware'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _outlinedBtn(
                                key:
                                    const Key(FirmwareDownloadKeys.authReadBtn),
                                icon: Icons.visibility,
                                label: 'Read',
                                onPressed: () {
                                  _showSnack(
                                    'Authorization: ${_authorizationGranted ? 'Granted' : 'Denied'}',
                                    isError: !_authorizationGranted,
                                  );
                                },
                              ),
                              _primaryBtn(
                                key: const Key(
                                    FirmwareDownloadKeys.authWriteBtn),
                                icon: Icons.edit,
                                label:
                                    _authorizationGranted ? 'Revoke' : 'Write',
                                onPressed: () {
                                  setState(() => _authorizationGranted =
                                      !_authorizationGranted);
                                  _showSnack(_authorizationGranted
                                      ? 'Authorization Granted'
                                      : 'Authorization Revoked');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth < 700
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 32) / 2,
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _formLabel('Size Block',
                              tooltip: 'Transfer block size in bytes'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  key: const Key(
                                      FirmwareDownloadKeys.blockSizeField),
                                  controller: _blockSizeCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Ex: 96',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _outlinedBtn(
                                key: const Key(
                                    FirmwareDownloadKeys.blockSizeReadBtn),
                                icon: Icons.visibility,
                                label: 'Read',
                                onPressed: () async {
                                  try {
                                    final blockSize =
                                        await client.getBlockSize();
                                    setState(() {
                                      _blockSizeCtrl.text = '$blockSize';
                                    });
                                    ref
                                        .read(appControllerProvider.notifier)
                                        .setBlockSize(blockSize);
                                    _showSnack('Block size lu: $blockSize');
                                  } catch (e) {
                                    _showSnack(
                                      'Error reading block size: ${_extractErrorMessage(e)}',
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              _primaryBtn(
                                key: const Key(
                                    FirmwareDownloadKeys.blockSizeWriteBtn),
                                icon: Icons.edit,
                                label: 'Write',
                                onPressed: () async {
                                  try {
                                    final blockSize =
                                        int.tryParse(_blockSizeCtrl.text);
                                    if (blockSize == null) {
                                      _showSnack('Invalid block size value');
                                      return;
                                    }
                                    final success =
                                        await client.setBlockSize(blockSize);
                                    if (!success) {
                                      throw Exception(
                                          'Failed to set block size');
                                    }
                                    ref
                                        .read(appControllerProvider.notifier)
                                        .setBlockSize(blockSize);
                                    _showSnack(
                                        'Block size set successfully: $blockSize');
                                  } catch (e) {
                                    _showSnack(
                                      'Error setting block size: ${_extractErrorMessage(e)}',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _formLabel('First Block Not Transferred',
                    tooltip: 'Index of the first block not transferred'),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstBlockNotTransferredCtrl,
                  enabled: false,
                  decoration: const InputDecoration(isDense: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            icon: Icons.sync,
            iconColor: cWarning,
            title: 'Transfer State',
            tooltip: 'Current transfer process status',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusChip(_transferStatus),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                key: const Key(FirmwareDownloadKeys.refreshStatusBtn),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cPrimary600,
                  side: const BorderSide(color: cPrimary600),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    final isEnabled = await client.enableImageTransfer();
                    setState(() => _transferStatus = isEnabled
                        ? TransferStatus.success
                        : TransferStatus.failed);
                    _showSnack(
                      isEnabled ? 'Transfer authorized' : 'Transfer not authorized',
                      isError: !isEnabled,
                    );
                  } catch (e) {
                    _showSnack(
                      'Error reading transfer status: ${_extractErrorMessage(e)}',
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle(
            icon: Icons.event,
            iconColor: cSuccess,
            title: 'Activation Date and Time',
            tooltip: 'Firmware activation scheduling',
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 16;
              const double minDateTimeWidth = 620;
              const double minActionsWidth = 320;
              final double availableWidth = constraints.maxWidth;
              final bool canUseTwoColumns = availableWidth >=
                  (minDateTimeWidth + minActionsWidth + spacing);
              final double dateTimeWidth = canUseTwoColumns
                  ? (availableWidth - minActionsWidth - spacing)
                  : availableWidth;
              final double actionsWidth =
                  canUseTwoColumns ? minActionsWidth : availableWidth;

              Widget actionButtonsWrap() {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _outlinedBtn(
                      key: const Key(
                          FirmwareDownloadKeys.activationDatetimeReadBtn),
                      icon: Icons.visibility,
                      label: 'Read',
                      onPressed: () async {
                        try {
                          final activationDateTime = await client
                              .getImageTransfertActivationDateTime();
                          setState(() {
                            _activationYear = activationDateTime.year;
                            _activationMonth = activationDateTime.month;
                            _activationDay = activationDateTime.day;
                            _activationHour = activationDateTime.hour;
                            _activationMinute = activationDateTime.minute;
                            _activationSecond = activationDateTime.second;
                          });
                          final formattedDateTime =
                              '$_activationYear-${_activationMonth.toString().padLeft(2, '0')}-${_activationDay.toString().padLeft(2, '0')} ${_activationHour.toString().padLeft(2, '0')}:${_activationMinute.toString().padLeft(2, '0')}:${_activationSecond.toString().padLeft(2, '0')}';
                          _showSnack(
                              'Activation date/time read: $formattedDateTime');
                        } catch (e) {
                          _showSnack(
                            'Error reading activation date/time: ${_extractErrorMessage(e)}',
                          );
                        }
                      },
                    ),
                    _primaryBtn(
                      key: const Key(
                          FirmwareDownloadKeys.activationDatetimeWriteBtn),
                      icon: Icons.edit,
                      label: 'Write',
                      onPressed: () async {
                        try {
                          final success =
                              await client.setImageTransfertActivationDateTime(
                            _activationYear,
                            _activationMonth,
                            _activationDay,
                            _activationHour,
                            _activationMinute,
                            _activationSecond,
                          );
                          if (!success) {
                            throw Exception(
                                'Failed to set activation date/time');
                          }
                          final formattedDateTime =
                              '$_activationYear-${_activationMonth.toString().padLeft(2, '0')}-${_activationDay.toString().padLeft(2, '0')} ${_activationHour.toString().padLeft(2, '0')}:${_activationMinute.toString().padLeft(2, '0')}:${_activationSecond.toString().padLeft(2, '0')}';
                          _showSnack(
                              'Activation date/time saved: $formattedDateTime');
                        } catch (e) {
                          _showSnack(
                            'Error setting activation date/time: ${_extractErrorMessage(e)}',
                          );
                        }
                      },
                    ),
                  ],
                );
              }

              if (canUseTwoColumns) {
                _scheduleActivationDateCardHeightSync();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      key: _activationDateCardKey,
                      width: dateTimeWidth,
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Activation date and time',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                            const SizedBox(height: 8),
                            _dateTimeDropdowns(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: spacing),
                    SizedBox(
                      width: actionsWidth,
                      child: SizedBox(
                        height: _activationDateCardHeight,
                        child: _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Actions',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              const SizedBox(height: 8),
                              actionButtonsWrap(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: dateTimeWidth,
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Activation date and time',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 8),
                          _dateTimeDropdowns(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: actionsWidth,
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Actions',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 8),
                          actionButtonsWrap(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------- TAB 2 : TÃ‰LÃ‰CHARGEMENT ----------
  Widget _buildDownloadTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  icon: Icons.folder,
                  iconColor: cPrimary600,
                  title: 'Firmware Process',
                  tooltip: 'Firmware file preparation and selection',
                ),
                const SizedBox(height: 8),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 280,
                            child: _labeledField(
                              label: 'Firmware File',
                              child: _fileUploadAreaCompact(),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: _labeledField(
                              label: 'Image ID',
                              child: TextField(
                                  key: const Key(
                                      FirmwareDownloadKeys.imageIdField),
                                  controller: _imageIdCtrl,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    // Write to global state
                                    ref
                                        .read(appControllerProvider.notifier)
                                        .setImageId(value.trim());
                                  }),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: _labeledField(
                              label: 'Channel (optional)',
                              child: DropdownButtonFormField<String>(
                                key: const Key(
                                    FirmwareDownloadKeys.channelDropdown),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text('Select a channel'),
                                  ),
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Channel 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Channel 2'),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => _channel = v == '' ? null : v);
                                },
                                decoration:
                                    const InputDecoration(isDense: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _primaryBtn(
                            key: const Key(
                                FirmwareDownloadKeys.prepareInitTransferBtn),
                            icon: Icons.settings,
                            label: 'Prepare Init Transfer',
                            onPressed: _prepareTransfer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle(
                  icon: Icons.download,
                  iconColor: cSuccess,
                  title: 'Download Process',
                  tooltip: 'Download start and management',
                ),
                const SizedBox(height: 8),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Download progress',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 10,
                          color: DesignTokens.borderOf(context),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cPrimary600, cPrimary500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_transferredBlocks} / ${_totalBlocks} blocks transferred',
                            style: TextStyle(
                                fontSize: 13,
                                color: DesignTokens.textSecondaryOf(context)),
                          ),
                          Text('${(_progress * 100).round()}%',
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      DesignTokens.textSecondaryOf(context))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        // Fixed buttons at bottom
        Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceOf(context),
            border: Border(
                top: BorderSide(
                    color: DesignTokens.borderOf(context), width: 1)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _successBtn(
                key: const Key(FirmwareDownloadKeys.downloadBtn),
                icon: Icons.download,
                label: _isCompleted
                    ? 'Complete'
                    : _isDownloading
                        ? 'Downloading...'
                        : 'Download',
                onPressed: _canStartDownload() ? _startDownload : null,
              ),
              _warningBtn(
                key: const Key(FirmwareDownloadKeys.resumeBtn),
                icon: Icons.play_arrow,
                label: 'Resume',
                onPressed: _canResume() ? _resumeDownload : null,
              ),
              _dangerBtn(
                key: const Key(FirmwareDownloadKeys.cancelBtn),
                icon: Icons.close,
                label: 'Cancel',
                onPressed: _isDownloading ? _cancelDownload : null,
              ),
              _successBtn(
                key: const Key(FirmwareDownloadKeys.blocksActivateBtn),
                icon: Icons.play_arrow,
                label: 'Activate',
                onPressed: _isCompleted
                    ? () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          final response = await client.activateFirmware();
                          Navigator.pop(context);
                          if (!response.success) {
                            _showSnack(response.message.isNotEmpty
                                ? response.message
                                : 'Error during activation');
                            return;
                          }
                        } catch (e) {
                          _showSnack(
                            'Error during activation: ${_extractErrorMessage(e)}',
                          );
                          return;
                        }
                        await _performReboot();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- TAB 3 : Ã‰TAT DES BLOCS ----------
  Widget _buildBlocksTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.view_list,
          iconColor: cInfo,
          title: 'Table of Blocks Status',
          tooltip: 'Per-block memory transfer status',
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _blocksTableHeader(),
                const Divider(height: 1, thickness: 1),
                Expanded(
                  child: _blocks.isEmpty
                      ? Center(
                          child: Text('No initialized blocks',
                              style: TextStyle(
                                  color:
                                      DesignTokens.textSecondaryOf(context))))
                      : ListView.separated(
                          itemCount: _blocks.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final b = _blocks[i];
                            return Container(
                              color: i.isOdd
                                  ? (DesignTokens.isDark(context)
                                      ? DesignTokens.darkSurfaceAlt
                                      : cGray100)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  _cell(
                                      width: 70,
                                      child: Text(
                                          b.id.toString().padLeft(4, '0'))),
                                  _cell(
                                      width: 120, child: _statusChip(b.status)),
                                  _cell(
                                      width: 90,
                                      child: Text('${b.size}',
                                          style: const TextStyle(
                                              fontFamily: 'monospace'))),
                                  _cell(
                                      width: 110,
                                      child: Text(b.checksum ?? '-',
                                          style: const TextStyle(
                                              fontFamily: 'monospace'))),
                                  _cell(
                                      width: 90,
                                      child: Text('${b.retryCount}')), // retry
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(b.lastUpdate == null
                                          ? '-'
                                          : DateFormat('HH:mm:ss')
                                              .format(b.lastUpdate!)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: $_totalBlocks blocks | Transferred: $_transferredBlocks | Failures: ${_blocks.where((b) => b.status == BlockStatus.notTransferred).length}',
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
            ),
            Row(children: [
              _outlinedBtn(
                key: const Key(FirmwareDownloadKeys.blocksRefreshBtn),
                icon: Icons.refresh,
                label: 'Refresh',
                onPressed: () {
                  _refreshBlockStatus();
                },
              ),
              const SizedBox(width: 12),
              _outlinedBtn(
                key: const Key(FirmwareDownloadKeys.blocksResendBtn),
                icon: Icons.send,
                label: _isDownloading ? 'Resending...' : 'Resend',
                onPressed: (!_isDownloading && _firmwareFilePath != null)
                    ? () async {
                        if (_firmwareFilePath == null) {
                          _showSnack('No firmware file selected');
                          return;
                        }
                        final int blockSize =
                            int.tryParse(_blockSizeCtrl.text) ?? 96;
                        setState(() {
                          _isDownloading = true;
                          _isCancelled = false;
                          _transferStatus = TransferStatus.inProgress;
                        });
                        _syncFw(true);
                        try {
                          final stream = client.resendMissingChunks(
                              _firmwareFilePath!, blockSize);
                          _subscription = stream.listen(
                            (update) {
                              setState(() {
                                _transferredBlocks = update.blockNumber;
                                _progress = _totalBlocks > 0
                                    ? _transferredBlocks / _totalBlocks
                                    : 0;
                              });
                              if (update.message.isNotEmpty) {
                                _showSnack(update.message);
                              }
                            },
                            onDone: () {
                              setState(() {
                                _isDownloading = false;
                                _isCompleted = true;
                                _transferStatus = TransferStatus.success;
                              });
                              _syncFw(false);
                              _showSnack(
                                  'Resend completed â€” all missing blocks sent');
                            },
                            onError: (e) {
                              setState(() {
                                _isDownloading = false;
                                _isCancelled = true;
                                _transferStatus = TransferStatus.failed;
                              });
                              _syncFw(false);
                              _showSnack(
                                'Resend error: ${_extractErrorMessage(e)}',
                              );
                            },
                          );
                        } catch (e) {
                          setState(() {
                            _isDownloading = false;
                            _transferStatus = TransferStatus.failed;
                          });
                          _syncFw(false);
                          _showSnack(
                            'Error starting resend: ${_extractErrorMessage(e)}',
                          );
                        }
                      }
                    : null,
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _blocksTableHeader() {
    Widget headerCell(String label, {double? width}) => _cell(
          width: width,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondaryOf(context))),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color:
          DesignTokens.isDark(context) ? DesignTokens.darkSurfaceAlt : cGray100,
      child: Row(
        children: [
          headerCell('Block #', width: 70),
          headerCell('Status', width: 120),
          headerCell('Size (bytes)', width: 90),
          headerCell('Checksum', width: 110),
          headerCell('Retry Count', width: 90),
          Expanded(child: headerCell('Last Update')),
        ],
      ),
    );
  }

  Widget _cell({required Widget child, double? width}) {
    return SizedBox(
      width: width,
      child: DefaultTextStyle(
        style:
            TextStyle(fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
        child: child,
      ),
    );
  }

  // ---------- SHARED COMPONENTS ----------
  Widget _sectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? tooltip,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimaryOf(context))),
        if (tooltip != null) ...[
          const SizedBox(width: 6),
          StableTooltip(
            message: tooltip,
            child: Icon(Icons.help_outline,
                size: 18, color: DesignTokens.textSecondaryOf(context)),
          )
        ]
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderOf(context)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _formLabel(String label, {String? tooltip}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.textPrimaryOf(context))),
        if (tooltip != null) ...[
          const SizedBox(width: 6),
          StableTooltip(
            message: tooltip,
            child: Icon(Icons.help_outline,
                size: 16, color: DesignTokens.textSecondaryOf(context)),
          ),
        ],
      ],
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.textPrimaryOf(context))),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Compact file upload area for inline use
  Widget _fileUploadAreaCompact() {
    final bool hasFile = _firmwareFileName != null;
    final bool isDark = DesignTokens.isDark(context);
    return GestureDetector(
      key: const Key(FirmwareDownloadKeys.fileUploadArea),
      onTap: _selectFirmwareFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
            color: hasFile
                ? cSuccess.withOpacity(0.06)
                : (isDark ? DesignTokens.darkSurfaceAlt : cGray100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: hasFile ? cSuccess : DesignTokens.borderOf(context),
                style: BorderStyle.solid)),
        child: Row(
          children: [
            Icon(hasFile ? Icons.check_circle : Icons.cloud_upload,
                size: 20,
                color: hasFile
                    ? cSuccess
                    : DesignTokens.textSecondaryOf(context).withOpacity(0.6)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasFile
                        ? (_firmwareFileName!.length > 25
                            ? '${_firmwareFileName!.substring(0, 25)}...'
                            : _firmwareFileName!)
                        : 'Select a file',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: hasFile
                          ? cSuccess
                          : DesignTokens.textPrimaryOf(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasFile)
                    Text(
                      '${_formatBytes(_firmwareFileSize)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: DesignTokens.textSecondaryOf(context)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- STATUS CHIP ----------
  Widget _statusChip(dynamic status) {
    late String label;
    late Color bg;
    late Color fg;

    if (status is TransferStatus) {
      switch (status) {
        case TransferStatus.notInitiated:
          label = 'Transfer not initiated';
          bg = cGray100;
          fg = cGray600;
          break;
        case TransferStatus.inProgress:
          label = 'In Progress';
          bg = cInfo.withOpacity(0.12);
          fg = cInfo;
          break;
        case TransferStatus.success:
          label = 'Completed';
          bg = cSuccess.withOpacity(0.12);
          fg = cSuccess;
          break;
        case TransferStatus.failed:
          label = 'Failed';
          bg = cDanger.withOpacity(0.12);
          fg = cDanger;
          break;
      }
    } else if (status is BlockStatus) {
      switch (status) {
        case BlockStatus.pending:
          label = 'Pending';
          bg = cGray100;
          fg = cGray600;
          break;
        case BlockStatus.transferred:
          label = 'Transferred';
          bg = cSuccess.withOpacity(0.12);
          fg = cSuccess;
          break;
        case BlockStatus.inProgress:
          label = 'In Progress';
          bg = cInfo.withOpacity(0.12);
          fg = cInfo;
          break;
        case BlockStatus.notTransferred:
          label = 'Not Transferred';
          bg = cWarning.withOpacity(0.12);
          fg = cWarning;
          break;
      }
    } else {
      label = status.toString();
      bg = cGray100;
      fg = cGray600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------- FORM FIELDS (DATE/TIME) ----------
  Widget _dateTimeDropdowns() {
    final currentYear = DateTime.now().year;
    final years = [65535, ...List.generate(10, (i) => currentYear + i)];
    final months = [253, 254, 255, ...List.generate(12, (i) => i + 1)];
    final days = [253, 254, 255, ...List.generate(31, (i) => i + 1)];
    final hours = [255, ...List.generate(24, (i) => i)];
    final minutes = [255, ...List.generate(60, (i) => i)];
    final seconds = [255, ...List.generate(60, (i) => i)];

    const double minFieldWidth = 190;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final double fieldWidth = availableWidth >= (minFieldWidth * 3 + 16)
            ? (availableWidth - 16) / 3
            : availableWidth >= (minFieldWidth * 2 + 8)
                ? (availableWidth - 8) / 2
                : availableWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date fields
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key: const Key(FirmwareDownloadKeys.activationYearDropdown),
                    isExpanded: true,
                    value: _activationYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      isDense: true,
                    ),
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(_yearOptionLabel(year)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationYear = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key:
                        const Key(FirmwareDownloadKeys.activationMonthDropdown),
                    isExpanded: true,
                    value: _activationMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      isDense: true,
                    ),
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_monthOptionLabel(month)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationMonth = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key: const Key(FirmwareDownloadKeys.activationDayDropdown),
                    isExpanded: true,
                    value: _activationDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      isDense: true,
                    ),
                    items: days.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text(_dayOptionLabel(day)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationDay = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Time fields
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key: const Key(FirmwareDownloadKeys.activationHourDropdown),
                    isExpanded: true,
                    value: _activationHour,
                    decoration: const InputDecoration(
                      labelText: 'Hour',
                      isDense: true,
                    ),
                    items: hours.map((hour) {
                      return DropdownMenuItem(
                        value: hour,
                        child: Text(_hourOptionLabel(hour)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationHour = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key: const Key(
                        FirmwareDownloadKeys.activationMinuteDropdown),
                    isExpanded: true,
                    value: _activationMinute,
                    decoration: const InputDecoration(
                      labelText: 'Minute',
                      isDense: true,
                    ),
                    items: minutes.map((minute) {
                      return DropdownMenuItem(
                        value: minute,
                        child: Text(_minuteOptionLabel(minute)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationMinute = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<int>(
                    key: const Key(
                        FirmwareDownloadKeys.activationSecondDropdown),
                    isExpanded: true,
                    value: _activationSecond,
                    decoration: const InputDecoration(
                      labelText: 'Second',
                      isDense: true,
                    ),
                    items: seconds.map((second) {
                      return DropdownMenuItem(
                        value: second,
                        child: Text(_secondOptionLabel(second)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activationSecond = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _scheduleActivationDateCardHeightSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _activationDateCardKey.currentContext;
      final renderObject = context?.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        final newHeight = renderObject.size.height;
        final oldHeight = _activationDateCardHeight;
        if (oldHeight == null || (oldHeight - newHeight).abs() > 0.5) {
          setState(() => _activationDateCardHeight = newHeight);
        }
      }
    });
  }

  String _yearOptionLabel(int year) {
    if (year == 65535) return 'Not specified';
    return '$year';
  }

  String _monthOptionLabel(int month) {
    switch (month) {
      case 255:
        return 'Not specified';
      case 254:
        return 'Daylight savings begin';
      case 253:
        return 'Daylight savings end';
      default:
        return month.toString().padLeft(2, '0');
    }
  }

  String _dayOptionLabel(int day) {
    switch (day) {
      case 255:
        return 'Not specified';
      case 254:
        return 'Last day of month';
      case 253:
        return '2nd last day of month';
      default:
        return day.toString().padLeft(2, '0');
    }
  }

  String _hourOptionLabel(int hour) {
    if (hour == 255) return 'Not specified';
    return hour.toString().padLeft(2, '0');
  }

  String _minuteOptionLabel(int minute) {
    if (minute == 255) return 'Not specified';
    return minute.toString().padLeft(2, '0');
  }

  String _secondOptionLabel(int second) {
    if (second == 255) return 'Not specified';
    return second.toString().padLeft(2, '0');
  }

  // ---------- BUTTONS ----------
  Widget _primaryBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      Key? key}) {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    return _baseBtn(
      key: key,
      icon: icon,
      label: label,
      onPressed: (isConnected &&
              onPressed != null &&
              userRights.hasRightForFeature('Set', FeatureKeys.fwUpdate))
          ? onPressed
          : null,
      background: cPrimary600,
      foreground: Colors.white,
    );
  }

  Widget _outlinedBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      Key? key}) {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    return _baseBtn(
      key: key,
      icon: icon,
      label: label,
      onPressed: (isConnected &&
              onPressed != null &&
              userRights.hasRightForFeature('Get', FeatureKeys.fwUpdate))
          ? onPressed
          : null,
      background: cPrimary600,
      foreground: cPrimary600,
      outlined: true,
    );
  }

  Widget _successBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      Key? key}) {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    return _baseBtn(
      key: key,
      icon: icon,
      label: label,
      onPressed: (isConnected &&
              onPressed != null &&
              userRights.hasRightForFeature('Action', FeatureKeys.fwUpdate))
          ? onPressed
          : null,
      background: cSuccess,
      foreground: Colors.white,
    );
  }

  Widget _warningBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      Key? key}) {
    return _baseBtn(
      key: key,
      icon: icon,
      label: label,
      onPressed: onPressed,
      background: cWarning,
      foreground: Colors.white,
    );
  }

  Widget _dangerBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      Key? key}) {
    return _baseBtn(
      key: key,
      icon: icon,
      label: label,
      onPressed: onPressed,
      background: cDanger,
      foreground: Colors.white,
    );
  }

  Widget _baseBtn({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    Color? background,
    Color? foreground,
    bool outlined = false,
    Key? key,
  }) {
    final bool enabled = onPressed != null;
    final Color bg = outlined
        ? Colors.transparent
        : (background ?? cPrimary600).withOpacity(enabled ? 1 : 0.4);
    final Color fg = outlined
        ? (foreground ?? cPrimary600).withOpacity(enabled ? 1 : 0.4)
        : (foreground ?? Colors.white).withOpacity(enabled ? 1 : 0.7);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: ElevatedButton.icon(
        key: key,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          elevation: outlined ? 0 : 2,
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: outlined
                ? BorderSide(
                    color: (foreground ?? cPrimary600).withOpacity(0.9))
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------- ACTIONS LOGIC ----------
  void _selectFirmwareFile() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bin', 'hex', 'fw', 'dat'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Extract hex string starting with 0x from filename (strip the 0x prefix)
        final hexMatch = RegExp(r'0x([0-9A-Fa-f]+)').firstMatch(file.name);
        final hexValue = hexMatch?.group(1);
        setState(() {
          _firmwareFileName = file.name;
          _firmwareFileSize = file.size;
          _firmwareFilePath = file.path;
          _isCompleted = false;
          _isCancelled = false;
          _progress = 0;
          _transferredBlocks = 0;
          if (hexValue != null) {
            _imageIdCtrl.text = hexValue;
          }
        });
        ref.read(appControllerProvider.notifier).clearFirmwareProgress();
        if (hexValue != null) {
          ref.read(appControllerProvider.notifier).setImageId(hexValue);
        }
        _recomputeBlocks();
      }
    } catch (e) {
      print(e.toString());
      _showSnack('File selection error');
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _prepareTransfer() async {
    if (_firmwareFileName == null) {
      _showSnack('Please select a firmware file');
      return;
    }
    _recomputeBlocks();
    setState(() {
      _isCompleted = false;
      _progress = 0;
      _transferredBlocks = 0;
      _blocks.clear();
      for (int i = 1;
          i <=
              (_totalBlocks < _maxVisualBlocks
                  ? _totalBlocks
                  : _maxVisualBlocks);
          i++) {
        _blocks.add(
            BlockInfo(id: i, size: int.tryParse(_blockSizeCtrl.text) ?? 96));
      }
    });
    try {
      final isInitiated =
          await client.initiateTransfer(_imageIdCtrl.text, _firmwareFilePath!);
      if (isInitiated) {
        _showSnack('Initialization ready');
      } else {
        _showSnack('Initialization not ready');
      }
    } catch (e) {
      _showSnack(
        'Transfer initialization error: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Pushes the current [_isDownloading] value to the global app state so the
  /// sidebar can block navigation while a firmware transfer is active, and
  /// pauses / resumes the HDLC idle timer via the generic background-process
  /// counter (no user interaction occurs during a firmware transfer).
  void _syncFw(bool v) {
    final notifier = ref.read(appControllerProvider.notifier);
    notifier.setFirmwareDownloading(v);
    if (v) {
      notifier.beginBackgroundProcess();
    } else {
      notifier.endBackgroundProcess();
    }
  }

  bool _canStartDownload() =>
      !_isDownloading && !_isCompleted && _totalBlocks > 0;

  /// Reads attribute 3 (blocks_transferred) from the meter and refreshes
  /// the Block Status tab. Called automatically when a download completes
  /// and also by the manual Refresh button in the Block Status tab.
  Future<void> _refreshBlockStatus() async {
    if (_firmwareFilePath == null) return;
    try {
      final int blockSize = int.tryParse(_blockSizeCtrl.text) ?? 96;
      final List<bool> data =
          await client.verifyTransfert(_firmwareFilePath!, blockSize);
      if (!mounted) return;
      setState(() {
        _blocks.clear();
        for (var i = 0; i < data.length; i++) {
          _blocks.add(
            BlockInfo(
              id: i,
              size: blockSize,
              status: data[i]
                  ? BlockStatus.transferred
                  : BlockStatus.notTransferred,
            ),
          );
        }
      });
      _showSnack('Block status updated');
    } catch (e) {
      _showSnack('Error refreshing blocks: ${_extractErrorMessage(e)}');
    }
  }

  void _startDownload() {
    if (!_canStartDownload()) return;
    setState(() {
      _isDownloading = true;
      _isCancelled = false;
      _transferStatus = TransferStatus.inProgress;
    });
    _syncFw(true);
    try {
      final int blockSize = int.tryParse(_blockSizeCtrl.text) ?? 96;
      final stream = client.transferFile(_firmwareFilePath!, blockSize);

      _subscription = stream.listen(
        (update) {
          setState(() {
            _transferredBlocks = update.blockNumber;
            _progress = _transferredBlocks / _totalBlocks;
          });
        },
        onDone: () {
          setState(() {
            _isDownloading = false;
            _isCompleted = true;
          });
          _syncFw(false);
          _showSnack('Download completed');
          _refreshBlockStatus();
        },
        onError: (e) {
          setState(() {
            _isDownloading = false;
            _isCompleted = true;
          });
          _syncFw(false);
          _showSnack(
            'Download error: ${_extractErrorMessage(e)}',
          );
          _refreshBlockStatus();
        },
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isCompleted = false;
      });
      _syncFw(false);
      _showSnack(
        'Download start error: ${_extractErrorMessage(e)}',
      );
    }
  }

  void _cancelDownload() {
    _downloadTimer?.cancel();
    setState(() {
      _isDownloading = false;
      _isCancelled = true;
      _transferStatus = TransferStatus.failed;
    });
    _syncFw(false);
    _subscription?.cancel();
    _saveProgress();
    _showSnack('Download canceled');
  }

  bool _canResume() {
    final int blockSize = int.tryParse(_blockSizeCtrl.text) ?? 0;
    return _isCancelled &&
        !_isDownloading &&
        blockSize > 0 &&
        _firmwareFilePath != null;
  }

  void _resumeDownload() {
    if (!_canResume()) return;
    final int blockSize = int.tryParse(_blockSizeCtrl.text) ?? 96;
    final int startBlock = _transferredBlocks; // resume from where we stopped
    setState(() {
      _isDownloading = true;
      _isCancelled = false;
      _transferStatus = TransferStatus.inProgress;
    });
    _syncFw(true);
    try {
      final stream =
          client.resumeTransfer(_firmwareFilePath!, blockSize, startBlock);
      _subscription = stream.listen(
        (update) {
          setState(() {
            _transferredBlocks = update.blockNumber;
            _progress =
                _totalBlocks > 0 ? _transferredBlocks / _totalBlocks : 0;
          });
        },
        onDone: () {
          setState(() {
            _isDownloading = false;
            _isCompleted = true;
          });
          _syncFw(false);
          _showSnack('Resume completed');
          _refreshBlockStatus();
        },
        onError: (e) {
          setState(() {
            _isDownloading = false;
            _isCancelled = true;
          });
          _syncFw(false);
          _saveProgress();
          _showSnack('Resume error: ${_extractErrorMessage(e)}');
        },
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isCancelled = true;
      });
      _syncFw(false);
      _showSnack('Resume start error: ${_extractErrorMessage(e)}');
    }
  }

  /// Shows a non-dismissable reboot spinner, disconnects silently, then
  /// replaces the entire navigation stack with the connection page.
  Future<void> _performReboot() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Firmware Activation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Meter is rebooting\nPlease wait and reconnect.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    // Disconnect â€” meter may have already dropped the link, ignore any error.
    try {
      await client.disconnect();
    } catch (_) {}
    await Future.delayed(Duration(seconds: 15)); // wait 15s
    if (!mounted) return;
    ref.read(appControllerProvider.notifier).setIsConnected(false);
    // Remove all routes (including the dialog above) and go to the connection page.
    AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.meterConnexion,
      (_) => false,
    );
  }

  void _resetTransfer() {
    _downloadTimer?.cancel();
    setState(() {
      _progress = 0;
      _isDownloading = false;
      _isCompleted = false;
      _isCancelled = false;
      _transferStatus = TransferStatus.notInitiated;
      _transferredBlocks = 0;
      _blocks.clear();
      _firstBlockNotTransferredCtrl.text = '0';
    });
    ref.read(appControllerProvider.notifier).clearFirmwareProgress();
    _showSnack('Transfer reset completed');
  }

  /// Saves the current download progress to global state so it survives
  /// page navigation. Should be called whenever [_isCancelled] becomes true.
  void _saveProgress() {
    ref.read(appControllerProvider.notifier).saveFirmwareProgress(
          filePath: _firmwareFilePath,
          fileName: _firmwareFileName,
          fileSize: _firmwareFileSize,
          transferredBlocks: _transferredBlocks,
          totalBlocks: _totalBlocks,
        );
  }

  void _recomputeBlocks() {
    final int blockSize = int.tryParse(_blockSizeCtrl.text) ?? 96;
    if (_firmwareFileSize > 0) {
      final total = (_firmwareFileSize / blockSize).ceil();
      setState(() => _totalBlocks = total);
    } else {
      // simulate simple size if we have a file name but no real size
      if (_firmwareFileName != null) {
        // Suppose file size random 240 KB
        final simulatedSize = 240 * 1024; // 240 KB
        final total = (simulatedSize / blockSize).ceil();
        setState(() => _totalBlocks = total);
      } else {
        setState(() => _totalBlocks = 0);
      }
    }
  }

  /// Shows a feedback SnackBar. [isError] should be passed explicitly by the
  /// caller whenever the message's polarity isn't obvious from generic
  /// "error/failed" wording (e.g. "Authorization: Denied", "Transfer not
  /// authorized") — the keyword heuristic alone previously let refusals like
  /// those render as a green "success" banner.
  void _showSnack(String msg, {bool? isError}) {
    if (!mounted) return;
    final lower = msg.toLowerCase();
    final bool resolvedIsError = isError ??
        (lower.contains('erreur') ||
            lower.contains('error') ||
            lower.contains('failed') ||
            lower.contains('denied') ||
            lower.contains('not authorized'));
    if (resolvedIsError) {
      feedback.error(msg);
    } else {
      feedback.success(msg);
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      return e.toString();
    }
    final raw = e.toString();
    return raw.replaceFirst('Exception: ', '');
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

// ---------- ENUMS & MODELS ----------

enum TransferStatus { notInitiated, inProgress, success, failed }

enum BlockStatus { pending, inProgress, transferred, notTransferred }

class BlockInfo {
  BlockInfo({
    required this.id,
    required this.size,
    this.status = BlockStatus.pending,
    this.checksum,
    this.retryCount = 0,
    this.lastUpdate,
  });
  final int id;
  final int size;
  BlockStatus status;
  String? checksum;
  int retryCount;
  DateTime? lastUpdate;
}
