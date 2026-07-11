import 'package:flutter/material.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/widgets/app_bottom_toolbar.dart';
import '../../grpc/meter_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../state/app_state.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/export/export_registry.dart';
import '../../state/device_id_cache.dart';

class FirmwareVersionPage extends ConsumerStatefulWidget {
  const FirmwareVersionPage({super.key});

  @override
  ConsumerState<FirmwareVersionPage> createState() =>
      _FirmwareVersionPageState();
}

class _FirmwareVersionPageState extends ConsumerState<FirmwareVersionPage>
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'firmware_version';

  @override
  String get exportPageLabel => 'Firmware Version';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'fields': {
          for (final name in _fieldOrder) name: _controllers[name]?.text ?? '',
        },
      };

  // ---------------------------------------------------------------------------

  late IMeterClient _client;
  final _formKey = GlobalKey<FormState>();

  Map<String, TextEditingController> _controllers = {};
  Map<String, String> _originalValues = {};
  List<String> _fieldOrder = [];

  // State
  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;
  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _initTemplateFields([
      'Metrology',
      'Application1',
      'Application2',
      'Metrology Signature',
      'Application1 Signature',
      'Application2 Signature',
      'Modem PLC Version',
    ]);
    if (ref.read(appControllerProvider).isConnected) {
      _readFirmwareVersion();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _client.close();
    super.dispose();
  }

  void _initTemplateFields(List<String> fieldNames) {
    for (final name in fieldNames) {
      final controller = TextEditingController(text: '');
      controller.addListener(_checkForChanges);
      _controllers[name] = controller;
      _originalValues[name] = '';
      _fieldOrder.add(name);
    }
  }

  void _checkForChanges() {
    final hasChanges = _controllers.entries.any((entry) {
      final fieldName = entry.key;
      final currentValue = entry.value.text;
      final originalValue = _originalValues[fieldName] ?? '';
      return currentValue != originalValue;
    });

    if (hasChanges != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = hasChanges);
    }
  }

  Future<void> _readFirmwareVersion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _client.getFirmwareVersion();
      print('Received firmware version: $response');

      // ✨ Traitement DYNAMIQUE
      final fields = response.items;

      setState(() {
        // 1. Nettoyer les anciens controllers
        for (var controller in _controllers.values) {
          controller.dispose();
        }
        _controllers.clear();
        _originalValues.clear();
        _fieldOrder.clear();

        // 2. Créer dynamiquement un controller par champ reçu
        for (var entry in fields) {
          final fieldName = entry.name;
          final fieldValue = entry.value;

          // Créer le controller
          final controller = TextEditingController(text: fieldValue);
          controller.addListener(_checkForChanges);

          _controllers[fieldName] = controller;
          _originalValues[fieldName] = fieldValue;
          _fieldOrder.add(fieldName);
        }

        _hasUnsavedChanges = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('Loaded ${fields.length} firmware version fields'),
                ],
              ),
              backgroundColor: DesignTokens.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
      }
    } catch (e) {
      final msg = extractGrpcMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
            ),
          );
      }
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  void _resetValues() {
    setState(() {
      for (var entry in _controllers.entries) {
        final fieldName = entry.key;
        entry.value.text = _originalValues[fieldName] ?? '';
      }
      _hasUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(appControllerProvider).isConnected;
    ref.listen<AppState>(appControllerProvider, (prev, next) {
      if (!(prev?.isConnected ?? false) && next.isConnected) {
        _readFirmwareVersion();
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firmware Version'),
        backgroundColor:
            isDark ? const Color(0xFF1e3a6e) : DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          ExportActionButton(
            key: const Key(FirmwareVersionKeys.exportBtn),
            pageId: exportPageId,
            pageType: 'firmware_version',
            dataGetter: getExportData,
            iconColor: Colors.white,
          ),
          RefreshAppBarButton(
            key: const Key(FirmwareVersionKeys.refreshBtn),
            onPressed: _readFirmwareVersion,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0f172a), Color(0xFF1e293b)]
                : [DesignTokens.background, DesignTokens.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Error banner
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: DesignTokens.danger.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: DesignTokens.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: DesignTokens.danger)),
                    ),
                    IconButton(
                      key: const Key(FirmwareVersionKeys.dismissErrorBtn),
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _error = null),
                    ),
                  ],
                ),
              ),
            // Content
            Expanded(
              child: _isLoading
                  ? _buildPageSkeleton()
                  : _fieldOrder.isEmpty
                      ? _buildPageSkeleton()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Meter Identification',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? const Color(0xFF60A5FA)
                                                : DesignTokens.primary600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'View and manage core meter identification data',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : DesignTokens.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        ...List.generate(_fieldOrder.length,
                                            (index) {
                                          final fieldName = _fieldOrder[index];
                                          final controller =
                                              _controllers[fieldName]!;

                                          return Column(
                                            children: [
                                              if (index > 0)
                                                const SizedBox(height: 20),
                                              _buildFieldRow(
                                                  fieldName, controller),
                                            ],
                                          );
                                        }),

                                        const SizedBox(height: 32),
                                        // Action buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (_hasUnsavedChanges)
                                              TextButton(
                                                key: const Key(FirmwareVersionKeys.resetBtn),
                                                onPressed: _resetValues,
                                                style: TextButton.styleFrom(
                                                  foregroundColor: isDark
                                                      ? Colors.white
                                                      : DesignTokens.primary600,
                                                ),
                                                child: const Text('Reset'),
                                              ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              key: const Key(FirmwareVersionKeys.readBtn),
                                              onPressed: (!isConnected ||
                                                      _isLoading ||
                                                      !userRights
                                                          .hasRightForFeature(
                                                              'Get',
                                                              FeatureKeys
                                                                  .fwVersion))
                                                  ? null
                                                  : _readFirmwareVersion,
                                              icon: const Icon(Icons.visibility,
                                                  size: 18),
                                              label: const Text('Read'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFF9800),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 14,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              key: const Key(FirmwareVersionKeys.writeBtn),
                                              onPressed: (!isConnected ||
                                                      _isLoading ||
                                                      !_hasUnsavedChanges ||
                                                      !userRights
                                                          .hasRightForFeature(
                                                              'Set',
                                                              FeatureKeys
                                                                  .fwVersion))
                                                  ? null
                                                  : () =>
                                                      _showWriteConfirmDialog(),
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              label: const Text('Write'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF1976D2),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 14,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: TextFormField(
            key: Key(FirmwareVersionKeys.fieldKey(label)),
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDark
                        ? DesignTokens.darkBorder
                        : DesignTokens.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDark
                        ? DesignTokens.darkBorder
                        : DesignTokens.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isDark
                        ? DesignTokens.darkFocus
                        : DesignTokens.primary600,
                    width: 1.2),
              ),
              filled: true,
              fillColor: isDark ? DesignTokens.darkFill : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
                fontSize: 14, color: DesignTokens.textPrimaryOf(context)),
          ),
        ),
      ],
    );
  }

  void _showWriteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Write'),
        content: const Text('Apply changes to meter identification?'),
        actions: [
          TextButton(
            key: const Key(FirmwareVersionKeys.writeConfirmCancelBtn),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key(FirmwareVersionKeys.writeConfirmApplyBtn),
            onPressed: () {
              Navigator.pop(context);
              _writeIdentification();
            },
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.success,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _writeIdentification() async {
    // TODO: Implémenter l'écriture dynamique
    setState(() => _isLoading = true);

    try {
      // Construire la map des valeurs à écrire
      final valuesToWrite = <String, String>{};
      for (var entry in _controllers.entries) {
        valuesToWrite[entry.key] = entry.value.text;
      }

      // TODO: Appeler le backend pour écrire
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _originalValues = Map.from(valuesToWrite);
        _hasUnsavedChanges = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Write failed: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildPageSkeleton() {
    return IgnorePointer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 220, height: 28),
                    const SizedBox(height: 10),
                    const SkeletonBox(width: 300, height: 14),
                    const SizedBox(height: 32),
                    ...List.generate(
                      7,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 250, child: SkeletonBox(height: 14)),
                            SizedBox(width: 24),
                            Expanded(child: SkeletonBox(height: 48)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SkeletonBox(width: 88, height: 44, borderRadius: 8),
                        SizedBox(width: 12),
                        SkeletonBox(width: 88, height: 44, borderRadius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Call once at startup (e.g. in main.dart) to make the Firmware Version page
/// available in the export templates screen.
void registerFirmwareVersionPage() {
  ExportRegistry.instance.register(
    const ExportedPageInfo(
      id: 'firmware_version',
      label: 'Firmware Version',
      icon: Icons.memory_outlined,
      builder: _buildFirmwareVersionPage,
      tokens: {
        'fields.*': 'Firmware field value – e.g. fields.Firmware_Version',
      },
    ),
  );
}

Widget _buildFirmwareVersionPage(BuildContext _) => const FirmwareVersionPage();
