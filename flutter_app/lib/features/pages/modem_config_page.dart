import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../state/app_controller.dart';
import '../../core/widget_keys.dart';

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class ModemConfigPage extends ConsumerStatefulWidget {
  const ModemConfigPage({super.key});

  @override
  ConsumerState<ModemConfigPage> createState() => _ModemConfigPageState();
}

class _ModemConfigPageState extends ConsumerState<ModemConfigPage>
    with SingleTickerProviderStateMixin {
  late IMeterClient _client;
  late TabController _tabController;

  // ---- global state ----
  bool _isLoading = false;
  String? _error;

  // ---- Tab 1 – Modem Configuration ----
  int _commSpeedIndex = 5; // default 9600
  final _modemProfileCtrl = TextEditingController();
  List<ModemInitStringEntry> _initStrings = [
    ModemInitStringEntry(request: '', expected: '', delayMs: 0),
  ];
  bool _showInitString = true;
  Map<int, bool> _class27WriteRights = {};

  // ---- Tab 2 – Auto Connect ----
  int _autoConnectMode = 101;
  final _repetitionsCtrl = TextEditingController(text: '0');
  final _repetitionDelayCtrl = TextEditingController(text: '0');
  List<CallingWindowEntry> _callingWindow = [];
  List<DestinationEntry> _destinationList = [];
  DateTime? _newCwStart;
  DateTime? _newCwEnd;
  Map<int, bool> _class29WriteRights = {};

  // ---- Tab 3 – Auto Answer ----
  int _autoAnswerMode = 0;
  final _numberOfCallsCtrl = TextEditingController(text: '0');
  final _ringsInWindowCtrl = TextEditingController(text: '0');
  final _ringsOutWindowCtrl = TextEditingController(text: '0');
  int _autoAnswerStatus = 0;
  List<AllowedCallerEntry> _allowedCallers = [];
  List<CallingWindowEntry> _listeningWindow = [];
  DateTime? _newLwStart;
  DateTime? _newLwEnd;
  Map<int, bool> _class30WriteRights = {};

  // ---- Tab 4 – TCP/UDP Setup ----
  final _tcpPortCtrl = TextEditingController(text: '4059');
  final _ipReferenceCtrl = TextEditingController();
  final _mssCtrl = TextEditingController(text: '0');
  final _nbConnectionsCtrl = TextEditingController(text: '1');
  final _inactivityTimeoutCtrl = TextEditingController(text: '0');
  Map<int, bool> _class41WriteRights = {};

  static const _speedLabels = [
    '300 bps',
    '600 bps',
    '1200 bps',
    '2400 bps',
    '4800 bps',
    '9600 bps',
    '19200 bps',
    '38400 bps',
    '57600 bps',
    '115200 bps',
  ];

  static const _autoConnectModeLabels = <int, String>{
    101: 'Permanently connected',
    102: 'Disconnected outside calling window',
    103: 'Disconnected outside calling window + Connect method',
    104: 'Usually disconnected + Connect method',
  };

  static const _autoAnswerModeLabels = <int, String>{
    0: 'Line dedicated to the device',
    1: 'Limited number of calls allowed',
    2: 'Limited number of successful calls allowed',
    3: 'Currently no modem connected',
  };

  static const _autoAnswerStatusLabels = <int, String>{
    0: 'Inactive',
    1: 'Active',
    2: 'Locked',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _client = meterClientFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(appControllerProvider).isConnected) {
        _silentReadCurrentTab();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _modemProfileCtrl.dispose();
    _repetitionsCtrl.dispose();
    _repetitionDelayCtrl.dispose();
    _numberOfCallsCtrl.dispose();
    _ringsInWindowCtrl.dispose();
    _ringsOutWindowCtrl.dispose();
    _tcpPortCtrl.dispose();
    _mssCtrl.dispose();
    _nbConnectionsCtrl.dispose();
    _inactivityTimeoutCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    if (ref.read(appControllerProvider).isConnected) {
      _silentReadCurrentTab();
    }
  }

  // --------------------------------------------------------------------------
  // Read helpers
  // --------------------------------------------------------------------------

  /// Auto-load on tab open: spinner only, no success popup.
  Future<void> _silentReadCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await _silentRead(_doReadModemConfig);
        break;
      case 1:
        await _silentRead(_doReadAutoConnect);
        break;
      case 2:
        await _silentRead(_doReadAutoAnswer);
        break;
      case 3:
        await _silentRead(_doReadTcpUdpSetup);
        break;
    }
  }

  /// Manual Read button: spinner + success/failure popup.
  Future<void> _readCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await _readAndReport(_doReadModemConfig);
        break;
      case 1:
        await _readAndReport(_doReadAutoConnect);
        break;
      case 2:
        await _readAndReport(_doReadAutoAnswer);
        break;
      case 3:
        await _readAndReport(_doReadTcpUdpSetup);
        break;
    }
  }

  Future<void> _doReadModemConfig() async {
    final r = await _client.getModemConfigSettings();
    if (!mounted) return;
    setState(() {
      _commSpeedIndex = r.commSpeed.clamp(0, _speedLabels.length - 1);
      _modemProfileCtrl.text = r.modemProfile;
      _initStrings = r.initStrings.isNotEmpty
          ? List.from(r.initStrings)
          : [ModemInitStringEntry(request: '', expected: '', delayMs: 0)];
      _showInitString = r.showInitString;
    });
    try {
      final json = await _client.getObjectWriteRights(27);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (mounted) {
        setState(() => _class27WriteRights =
            map.map((k, v) => MapEntry(int.parse(k), v as bool)));
      }
    } catch (_) {}
  }

  bool _mcCanWrite(int attrId) => _class27WriteRights[attrId] ?? false;

  Future<void> _doReadAutoConnect() async {
    final r = await _client.getAutoConnect();
    if (!mounted) return;
    setState(() {
      _autoConnectMode =
          _autoConnectModeLabels.containsKey(r.mode) ? r.mode : 101;
      _repetitionsCtrl.text = r.repetitions.toString();
      _repetitionDelayCtrl.text = r.repetitionDelay.toString();
      _callingWindow = List.from(r.callingWindow);
      _destinationList = List.from(r.destinationList);
    });
    try {
      final json = await _client.getObjectWriteRights(29);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (mounted) {
        setState(() => _class29WriteRights =
            map.map((k, v) => MapEntry(int.parse(k), v as bool)));
      }
    } catch (_) {}
  }

  Future<void> _doReadAutoAnswer() async {
    final r = await _client.getAutoAnswer();
    if (!mounted) return;
    setState(() {
      _autoAnswerMode = _autoAnswerModeLabels.containsKey(r.mode) ? r.mode : 0;
      _numberOfCallsCtrl.text = r.numberOfCalls.toString();
      _ringsInWindowCtrl.text = r.ringsInWindow.toString();
      _ringsOutWindowCtrl.text = r.ringsOutWindow.toString();
      _autoAnswerStatus =
          _autoAnswerStatusLabels.containsKey(r.status) ? r.status : 0;
      _allowedCallers = List.from(r.allowedCallers);
      _listeningWindow = List.from(r.listeningWindow);
    });
    try {
      final json = await _client.getObjectWriteRights(28);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (mounted) {
        setState(() => _class30WriteRights =
            map.map((k, v) => MapEntry(int.parse(k), v as bool)));
      }
    } catch (_) {}
  }

  Future<void> _doReadTcpUdpSetup() async {
    final r = await _client.getTcpUdpSetup();
    if (!mounted) return;
    setState(() {
      _tcpPortCtrl.text = r.port.toString();
      _ipReferenceCtrl.text = r.ipReference;
      _mssCtrl.text = r.mss.toString();
      _nbConnectionsCtrl.text = r.nbConnections.toString();
      _inactivityTimeoutCtrl.text = r.inactivityTimeout.toString();
    });
    try {
      final json = await _client.getObjectWriteRights(41);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (mounted) {
        setState(() => _class41WriteRights =
            map.map((k, v) => MapEntry(int.parse(k), v as bool)));
      }
    } catch (_) {}
  }

  bool _tudCanWrite(int attrId) => _class41WriteRights[attrId] ?? false;

  // --------------------------------------------------------------------------
  // Read / Write report helpers (same pattern as sim_config_page)
  // --------------------------------------------------------------------------

  /// Silent read: spinner, no popup on success. Error shown as banner.
  Future<void> _silentRead(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _readAndReport(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Icon(Icons.check_circle, color: DesignTokens.success),
            const SizedBox(width: 10),
            const Text('Read Successful'),
          ]),
          content:
              const Text('The values were read from the meter successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Icon(Icons.error_outline, color: DesignTokens.danger),
            const SizedBox(width: 10),
            const Text('Read Failed'),
          ]),
          content: Text(_friendlyError(e)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _writeAndReport(Future<bool> Function() action) async {
    setState(() => _error = null);
    try {
      final ok = await action();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Icon(
              ok ? Icons.check_circle : Icons.error_outline,
              color: ok ? DesignTokens.success : DesignTokens.danger,
            ),
            const SizedBox(width: 10),
            Text(ok ? 'Write Successful' : 'Write Failed'),
          ]),
          content: Text(ok
              ? 'The value was written to the meter successfully.'
              : 'The meter did not accept the write request.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    }
  }

  String _friendlyError(Object e) => extractGrpcMessage(e);

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    final appState = ref.watch(appControllerProvider);
    final canRead = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Get', FeatureKeys.modemConfig);
    final canWrite = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Set', FeatureKeys.modemConfig);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modem Config'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(
                key: Key(ModemConfigKeys.modemConfigTab),
                text: 'Modem Configuration'),
            Tab(
                key: Key(ModemConfigKeys.autoConnectTab),
                text: 'Auto Connect'),
            Tab(
                key: Key(ModemConfigKeys.autoAnswerTab),
                text: 'Auto Answer'),
            Tab(
                key: Key(ModemConfigKeys.tcpUdpTab),
                text: 'TCP/UDP Setup'),
          ],
        ),
        actions: [
          RefreshAppBarButton(
              key: const Key(ModemConfigKeys.refreshBtn),
              onPressed: _readCurrentTab),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Breadcrumb(segments: ['Menu', 'P2P Setup', 'Modem Config']),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (_error != null) _buildErrorBanner(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildModemConfigTab(canRead, canWrite),
                          _buildAutoConnectTab(canRead, canWrite),
                          _buildAutoAnswerTab(canRead, canWrite),
                          _buildTcpUdpSetupTab(canRead, canWrite),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Lottie.asset(
                          'assets/animations/data.json',
                          width: 200,
                          height: 200,
                          errorBuilder: (context, err, stack) =>
                              const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: DesignTokens.danger,
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child: Text(_error!, style: const TextStyle(color: Colors.white))),
        IconButton(
          key: const Key(ModemConfigKeys.dismissErrorBtn),
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => setState(() => _error = null),
        ),
      ]),
    );
  }

  // --------------------------------------------------------------------------
  // Shared section builders (same style as sim_config_page)
  // --------------------------------------------------------------------------

  Card _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(children: [
              Icon(icon, size: 20, color: DesignTokens.primary600),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, Widget control,
      {Widget? readBtn, Widget? writeBtn}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 148,
          child: Text(label,
              style:
                  TextStyle(fontSize: 13, color: DesignTokens.textSecondary)),
        ),
        Expanded(child: control),
        if (readBtn != null) ...[const SizedBox(width: 6), readBtn],
        if (writeBtn != null) ...[const SizedBox(width: 6), writeBtn],
      ]),
    );
  }

  String _formatDt(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}T'
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDateTime(void Function(DateTime) onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Widget _buildDateTimePickerRow(
      String label, DateTime? value, void Function(DateTime?) onChanged) {
    return _buildFieldRow(
      label,
      Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(
                  color: value != null
                      ? DesignTokens.primary600
                      : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Text(
              value != null ? _formatDt(value) : 'Not set',
              style: TextStyle(
                  fontSize: 13,
                  color: value != null
                      ? DesignTokens.textPrimary
                      : Colors.grey.shade500),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => _pickDateTime((dt) => onChanged(dt)),
          icon: const Icon(Icons.calendar_month_outlined),
          tooltip: 'Pick date & time',
          color: DesignTokens.primary600,
          splashRadius: 20,
        ),
        if (value != null)
          IconButton(
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.clear, size: 18),
            tooltip: 'Clear',
            color: Colors.grey,
            splashRadius: 20,
          ),
      ]),
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed,
      {Color? color, Key? key}) {
    final isWrite = label == 'Write';
    return AppButton(
      key: key,
      label: label,
      icon: isWrite ? AppIcons.write : AppIcons.read,
      variant: isWrite ? AppButtonVariant.primary : AppButtonVariant.secondary,
      onPressed: onPressed,
    );
  }

  Widget _textField(TextEditingController ctrl,
      {Key? key,
      bool readOnly = false,
      TextInputType? keyboardType,
      int maxLines = 1,
      String? hint}) {
    return TextField(
      key: key,
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: readOnly ? DesignTokens.surfaceAltOf(context) : DesignTokens.surfaceOf(context),
        filled: true,
      ),
    );
  }

  Widget _enumDropdown<T>(
      T value, Map<T, String> labels, ValueChanged<T?>? onChanged, {Key? key}) {
    final effectiveValue =
        labels.containsKey(value) ? value : labels.keys.first;
    return DropdownButtonFormField<T>(
      key: key,
      initialValue: effectiveValue,
      isExpanded: true,
      items: labels.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: onChanged == null ? DesignTokens.surfaceAltOf(context) : DesignTokens.surfaceOf(context),
        filled: true,
      ),
    );
  }

  Widget _th(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textPrimaryOf(context))),
    );
  }

  Widget _tCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: child,
    );
  }

  // ── small delete icon button for table rows ──
  Widget _deleteBtn(VoidCallback onTap) {
    return IconButton(
      icon: Icon(Icons.delete_outline, size: 18, color: DesignTokens.danger),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 1 – Modem Configuration
  // --------------------------------------------------------------------------

  Widget _buildModemConfigTab(bool canRead, bool canWrite) {
    final bool mcWriteSpeed = canWrite && _mcCanWrite(2);
    final bool mcWriteProfile = canWrite && _mcCanWrite(4);
    final bool mcWriteInit = canWrite && _mcCanWrite(3);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildSection('Communication Speed', Icons.speed, [
          _buildFieldRow(
            'Comm Speed',
            DropdownButtonFormField<int>(
              key: const Key(ModemConfigKeys.commSpeedDropdown),
              value: _commSpeedIndex,
              isExpanded: true,
              items: List.generate(
                _speedLabels.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(_speedLabels[i],
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
              onChanged: mcWriteSpeed
                  ? (v) => setState(() => _commSpeedIndex = v ?? 5)
                  : null,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                fillColor: mcWriteSpeed ? DesignTokens.surfaceOf(context) : DesignTokens.surfaceAltOf(context),
                filled: true,
              ),
            ),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadModemConfig) : null,
                key: const Key(ModemConfigKeys.commSpeedReadBtn)),
            writeBtn: _actionButton(
              'Write',
              mcWriteSpeed
                  ? () => _writeAndReport(
                      () => _client.setCommSpeed(_commSpeedIndex))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.commSpeedWriteBtn),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('Modem Profile', Icons.text_snippet_outlined, [
          _buildFieldRow(
            'Profile',
            _textField(_modemProfileCtrl, key: const Key(ModemConfigKeys.profileField), maxLines: 4),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadModemConfig) : null,
                key: const Key(ModemConfigKeys.profileReadBtn)),
            writeBtn: _actionButton(
              'Write',
              mcWriteProfile
                  ? () => _writeAndReport(
                      () => _client.setModemProfile(_modemProfileCtrl.text))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.profileWriteBtn),
            ),
          ),
        ]),
        if (_showInitString) ...[
          const SizedBox(height: 16),
          _buildSection('Initialization Strings', Icons.list_alt, [
            _buildInitStringTable(mcWriteInit),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (mcWriteInit)
                AppButton.primary(
                  key: const Key(ModemConfigKeys.initAddRowBtn),
                  onPressed: () => setState(() {
                    _initStrings = List.from(_initStrings)
                      ..add(ModemInitStringEntry(
                          request: '', expected: '', delayMs: 0));
                  }),
                  icon: Icons.add,
                  label: 'Add Row',
                ),
              const SizedBox(width: 8),
              _actionButton('Read',
                  canRead ? () => _readAndReport(_doReadModemConfig) : null,
                  key: const Key(ModemConfigKeys.initStringsReadBtn)),
              const SizedBox(width: 8),
              _actionButton(
                'Write',
                mcWriteInit
                    ? () => _writeAndReport(
                        () => _client.setInitStrings(_initStrings))
                    : null,
                color: DesignTokens.success,
                key: const Key(ModemConfigKeys.initStringsWriteBtn),
              ),
            ]),
          ]),
        ],
      ]),
    );
  }

  Widget _buildInitStringTable(bool canWrite) {
    final controllers = List.generate(
      _initStrings.length,
      (i) => [
        TextEditingController(text: _initStrings[i].request),
        TextEditingController(text: _initStrings[i].expected),
        TextEditingController(text: _initStrings[i].delayMs.toString()),
      ],
    );
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: IntrinsicColumnWidth(),
      },
      border: TableBorder.all(
          color: DesignTokens.borderOf(context),
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08)),
          children: [
            _th('Request (AT cmd)'),
            _th('Expected response'),
            _th('Delay (ms)'),
            _th(''),
          ],
        ),
        for (int i = 0; i < _initStrings.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i.isOdd ? DesignTokens.surfaceAltOf(context) : DesignTokens.surfaceOf(context)),
            children: [
              _tCell(TextField(
                key: Key(ModemConfigKeys.initRequestField(i)),
                controller: controllers[i][0],
                readOnly: !canWrite,
                onChanged: (v) =>
                    setState(() => _initStrings[i] = ModemInitStringEntry(
                          request: v,
                          expected: _initStrings[i].expected,
                          delayMs: _initStrings[i].delayMs,
                        )),
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero),
              )),
              _tCell(TextField(
                key: Key(ModemConfigKeys.initExpectedField(i)),
                controller: controllers[i][1],
                readOnly: !canWrite,
                onChanged: (v) =>
                    setState(() => _initStrings[i] = ModemInitStringEntry(
                          request: _initStrings[i].request,
                          expected: v,
                          delayMs: _initStrings[i].delayMs,
                        )),
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero),
              )),
              _tCell(TextField(
                key: Key(ModemConfigKeys.initDelayField(i)),
                controller: controllers[i][2],
                readOnly: !canWrite,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    setState(() => _initStrings[i] = ModemInitStringEntry(
                          request: _initStrings[i].request,
                          expected: _initStrings[i].expected,
                          delayMs: int.tryParse(v) ?? 0,
                        )),
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero),
              )),
              _tCell(canWrite
                  ? _deleteBtn(() => setState(() =>
                      _initStrings = List.from(_initStrings)..removeAt(i)))
                  : const SizedBox.shrink()),
            ],
          ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Tab 2 – Auto Connect
  // --------------------------------------------------------------------------

  Widget _buildAutoConnectTab(bool canRead, bool canWrite) {
    // Per-attr write guard: true if rights not yet loaded (optimistic) or attr allows set.
    bool ac(int attr) =>
        canWrite &&
        (_class29WriteRights.isEmpty || (_class29WriteRights[attr] ?? false));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildSection('Connection Settings', Icons.cell_tower, [
          _buildFieldRow(
            'Mode',
            _enumDropdown<int>(
              _autoConnectMode,
              _autoConnectModeLabels,
              canWrite
                  ? (v) => setState(() => _autoConnectMode = v ?? 101)
                  : null,
              key: const Key(ModemConfigKeys.autoConnectModeDropdown),
            ),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoConnect) : null,
                key: const Key(ModemConfigKeys.autoConnectModeReadBtn)),
            writeBtn: _actionButton(
              'Write',
              ac(2)
                  ? () => _writeAndReport(() => _client.setAutoConnect(
                        SetAutoConnectRequest(
                          mode: _autoConnectMode,
                          repetitions: int.tryParse(_repetitionsCtrl.text) ?? 0,
                          repetitionDelay:
                              int.tryParse(_repetitionDelayCtrl.text) ?? 0,
                          callingWindow: _callingWindow,
                        ),
                      ))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.autoConnectModeWriteBtn),
            ),
          ),
          _buildFieldRow(
            'Repetitions',
            _textField(_repetitionsCtrl,
                key: const Key(ModemConfigKeys.repetitionsField),
                readOnly: !canWrite, keyboardType: TextInputType.number),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoConnect) : null,
                key: const Key(ModemConfigKeys.repetitionsReadBtn)),
            writeBtn: _actionButton(
              'Write',
              ac(3)
                  ? () => _writeAndReport(() => _client.setAutoConnect(
                        SetAutoConnectRequest(
                          mode: _autoConnectMode,
                          repetitions: int.tryParse(_repetitionsCtrl.text) ?? 0,
                          repetitionDelay:
                              int.tryParse(_repetitionDelayCtrl.text) ?? 0,
                          callingWindow: _callingWindow,
                        ),
                      ))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.repetitionsWriteBtn),
            ),
          ),
          _buildFieldRow(
            'Repetition Delay (s)',
            _textField(_repetitionDelayCtrl,
                key: const Key(ModemConfigKeys.repetitionDelayField),
                readOnly: !canWrite, keyboardType: TextInputType.number),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoConnect) : null,
                key: const Key(ModemConfigKeys.repetitionDelayReadBtn)),
            writeBtn: _actionButton(
              'Write',
              ac(4)
                  ? () => _writeAndReport(() => _client.setAutoConnect(
                        SetAutoConnectRequest(
                          mode: _autoConnectMode,
                          repetitions: int.tryParse(_repetitionsCtrl.text) ?? 0,
                          repetitionDelay:
                              int.tryParse(_repetitionDelayCtrl.text) ?? 0,
                          callingWindow: _callingWindow,
                        ),
                      ))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.repetitionDelayWriteBtn),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('Destination List (read-only)', Icons.dns_outlined, [
          _buildDestinationTable(),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoConnect) : null,
                key: const Key(ModemConfigKeys.destinationReadBtn)),
          ]),
        ]),
        const SizedBox(height: 16),
        _buildSection('Calling Window', Icons.schedule_outlined, [
          if (canWrite) ...[
            _buildDateTimePickerRow(
              'Start Time',
              _newCwStart,
              (dt) => setState(() => _newCwStart = dt),
            ),
            _buildDateTimePickerRow(
              'End Time',
              _newCwEnd,
              (dt) => setState(() => _newCwEnd = dt),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              AppButton.primary(
                key: const Key(ModemConfigKeys.callingWindowAddBtn),
                onPressed: (_newCwStart != null || _newCwEnd != null)
                    ? () {
                        setState(() {
                          _callingWindow = List.from(_callingWindow)
                            ..add(CallingWindowEntry(
                              startTime: _newCwStart != null
                                  ? _formatDt(_newCwStart!)
                                  : '',
                              endTime: _newCwEnd != null
                                  ? _formatDt(_newCwEnd!)
                                  : '',
                            ));
                          _newCwStart = null;
                          _newCwEnd = null;
                        });
                      }
                    : null,
                icon: Icons.add,
                label: 'Add to list',
              ),
            ]),
            const Divider(height: 24),
          ],
          _buildCallingWindowTable(
            entries: _callingWindow,
            canWrite: canWrite,
            onUpdate: (list) => setState(() => _callingWindow = list),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoConnect) : null,
                key: const Key(ModemConfigKeys.callingWindowReadBtn)),
            const SizedBox(width: 8),
            _actionButton(
              'Write',
              ac(5)
                  ? () => _writeAndReport(() => _client.setAutoConnect(
                        SetAutoConnectRequest(
                          mode: _autoConnectMode,
                          repetitions: int.tryParse(_repetitionsCtrl.text) ?? 0,
                          repetitionDelay:
                              int.tryParse(_repetitionDelayCtrl.text) ?? 0,
                          callingWindow: _callingWindow,
                        ),
                      ))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.callingWindowWriteBtn),
            ),
          ]),
        ]),
        const SizedBox(height: 16),
        _buildSection('Immediate Connection', Icons.wifi_tethering, [
          const Text(
            'Trigger an immediate connection to the Data Center regardless of mode or calling window.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          if (_autoConnectMode != 103 && _autoConnectMode != 104)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Connect method is only available in mode 103 or 104 (current: $_autoConnectMode).',
                style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.danger,
                    fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 12),
          AppButton.primary(
            key: const Key(ModemConfigKeys.connectBtn),
            onPressed: (canWrite &&
                    (_autoConnectMode == 103 || _autoConnectMode == 104))
                ? () => _writeAndReport(() => _client.modemConnect())
                : null,
            icon: Icons.cast_connected,
            label: 'Connect',
          ),
        ]),
      ]),
    );
  }

  Widget _buildDestinationTable() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08)),
          children: [_th('IP Address'), _th('Port')],
        ),
        if (_destinationList.isEmpty)
          TableRow(
            children: [
              _tCell(Text('No destinations',
                  style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                      fontStyle: FontStyle.italic))),
              _tCell(Text('—',
                  style: TextStyle(
                      fontSize: 12, color: DesignTokens.textSecondary))),
            ],
          ),
        for (int i = 0; i < _destinationList.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i.isOdd ? Colors.grey.shade50 : Colors.white),
            children: [
              _tCell(Text(_destinationList[i].ipAddress,
                  style: TextStyle(
                      fontSize: 12, color: DesignTokens.textPrimary))),
              _tCell(Text(_destinationList[i].port.toString(),
                  style: TextStyle(
                      fontSize: 12, color: DesignTokens.textPrimary))),
            ],
          ),
      ],
    );
  }

  Widget _buildCallingWindowTable({
    required List<CallingWindowEntry> entries,
    required bool canWrite,
    required void Function(List<CallingWindowEntry>) onUpdate,
  }) {
    if (entries.isEmpty) {
      return Center(
        child: Text('No entries',
            style: TextStyle(color: DesignTokens.textSecondary, fontSize: 13)),
      );
    }
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(4),
        2: IntrinsicColumnWidth(),
      },
      border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08)),
          children: [_th('Start time'), _th('End time'), _th('')],
        ),
        for (int i = 0; i < entries.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i.isOdd ? Colors.grey.shade50 : Colors.white),
            children: [
              _tCell(_inlineTextField(
                entries[i].startTime,
                readOnly: !canWrite,
                onChanged: (v) {
                  final list = List<CallingWindowEntry>.from(entries);
                  list[i] = CallingWindowEntry(
                      startTime: v, endTime: entries[i].endTime);
                  onUpdate(list);
                },
              )),
              _tCell(_inlineTextField(
                entries[i].endTime,
                readOnly: !canWrite,
                onChanged: (v) {
                  final list = List<CallingWindowEntry>.from(entries);
                  list[i] = CallingWindowEntry(
                      startTime: entries[i].startTime, endTime: v);
                  onUpdate(list);
                },
              )),
              _tCell(canWrite
                  ? _deleteBtn(() {
                      final list = List<CallingWindowEntry>.from(entries)
                        ..removeAt(i);
                      onUpdate(list);
                    })
                  : const SizedBox.shrink()),
            ],
          ),
      ],
    );
  }

  /// Like [_buildCallingWindowTable] but displays DLMS hex times as
  /// human-readable dates when in read-only mode.
  Widget _buildListeningWindowTable({
    required List<CallingWindowEntry> entries,
    required bool canWrite,
    required void Function(List<CallingWindowEntry>) onUpdate,
  }) {
    if (entries.isEmpty) {
      return Center(
        child: Text('No entries',
            style: TextStyle(color: DesignTokens.textSecondary, fontSize: 13)),
      );
    }
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(4),
        2: IntrinsicColumnWidth(),
      },
      border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08)),
          children: [_th('Start time'), _th('End time'), _th('')],
        ),
        for (int i = 0; i < entries.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: i.isOdd ? Colors.grey.shade50 : Colors.white),
            children: [
              _tCell(canWrite
                  ? _inlineTextField(
                      entries[i].startTime,
                      readOnly: false,
                      onChanged: (v) {
                        final list = List<CallingWindowEntry>.from(entries);
                        list[i] = CallingWindowEntry(
                            startTime: v, endTime: entries[i].endTime);
                        onUpdate(list);
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      child: Text(_parseDlmsHexToDisplay(entries[i].startTime),
                          style: const TextStyle(fontSize: 12)),
                    )),
              _tCell(canWrite
                  ? _inlineTextField(
                      entries[i].endTime,
                      readOnly: false,
                      onChanged: (v) {
                        final list = List<CallingWindowEntry>.from(entries);
                        list[i] = CallingWindowEntry(
                            startTime: entries[i].startTime, endTime: v);
                        onUpdate(list);
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      child: Text(_parseDlmsHexToDisplay(entries[i].endTime),
                          style: const TextStyle(fontSize: 12)),
                    )),
              _tCell(canWrite
                  ? _deleteBtn(() {
                      final list = List<CallingWindowEntry>.from(entries)
                        ..removeAt(i);
                      onUpdate(list);
                    })
                  : const SizedBox.shrink()),
            ],
          ),
      ],
    );
  }

  Widget _inlineTextField(String initialValue,
      {bool readOnly = false, void Function(String)? onChanged}) {
    final ctrl = TextEditingController(text: initialValue);
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12),
      decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 3 – Auto Answer
  // --------------------------------------------------------------------------

  // Returns true if Class 28 attribute [attrId] has write rights according to
  // the rights fetched from the meter. Defaults to false so buttons start
  // grayed out and only become active after a Read confirms write access.
  bool _aaCanWrite(int attrId) => _class30WriteRights[attrId] ?? false;

  /// Converts a 12-byte DLMS DateTime hex string (e.g. '07D001010600000000800000')
  /// to a human-readable string 'YYYY-MM-DD HH:MM:SS'. Returns the original
  /// value unchanged if it cannot be parsed.
  static String _parseDlmsHexToDisplay(String hex) {
    final s = hex.trim();
    if (s.length != 24) return s;
    try {
      final bytes = List.generate(
          12, (i) => int.parse(s.substring(i * 2, i * 2 + 2), radix: 16));
      final year = (bytes[0] << 8) | bytes[1];
      final month = bytes[2];
      final day = bytes[3];
      final hour = bytes[5];
      final minute = bytes[6];
      final second = bytes[7];
      return '${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')} '
          '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}:'
          '${second.toString().padLeft(2, '0')}';
    } catch (_) {
      return s;
    }
  }

  Widget _buildAutoAnswerTab(bool canRead, bool canWrite) {
    // Per-attribute write permission: class 28 attr 2=mode/ncalls/rings,
    // attr 3=listening_window, attr 7=allowed_callers.
    final bool aaWriteSettings = canWrite && _aaCanWrite(2);
    final bool aaWriteCallers = canWrite && _aaCanWrite(7);
    final bool aaWriteLw = canWrite && _aaCanWrite(3);
    SetAutoAnswerRequest buildReq() => SetAutoAnswerRequest(
          mode: _autoAnswerMode,
          numberOfCalls: int.tryParse(_numberOfCallsCtrl.text) ?? 0,
          ringsInWindow: int.tryParse(_ringsInWindowCtrl.text) ?? 0,
          ringsOutWindow: int.tryParse(_ringsOutWindowCtrl.text) ?? 0,
          allowedCallers: _allowedCallers,
          listeningWindow: _listeningWindow,
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildSection('Answer Settings', Icons.phone_in_talk_outlined, [
          _buildFieldRow(
            'Mode',
            _enumDropdown<int>(
              _autoAnswerMode,
              _autoAnswerModeLabels,
              aaWriteSettings
                  ? (v) => setState(() => _autoAnswerMode = v ?? 0)
                  : null,
              key: const Key(ModemConfigKeys.autoAnswerModeDropdown),
            ),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.autoAnswerModeReadBtn)),
            writeBtn: _actionButton(
              'Write',
              aaWriteSettings
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.autoAnswerModeWriteBtn),
            ),
          ),
          _buildFieldRow(
            'Number of Calls',
            _textField(_numberOfCallsCtrl,
                key: const Key(ModemConfigKeys.nbCallsField),
                readOnly: !aaWriteSettings, keyboardType: TextInputType.number),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.nbCallsReadBtn)),
            writeBtn: _actionButton(
              'Write',
              aaWriteSettings
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.nbCallsWriteBtn),
            ),
          ),
          _buildFieldRow(
            'Rings in Window',
            _textField(_ringsInWindowCtrl,
                key: const Key(ModemConfigKeys.ringsInField),
                readOnly: !aaWriteSettings, keyboardType: TextInputType.number),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.ringsInReadBtn)),
            writeBtn: _actionButton(
              'Write',
              aaWriteSettings
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.ringsInWriteBtn),
            ),
          ),
          _buildFieldRow(
            'Rings out Window',
            _textField(_ringsOutWindowCtrl,
                key: const Key(ModemConfigKeys.ringsOutField),
                readOnly: !aaWriteSettings, keyboardType: TextInputType.number),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.ringsOutReadBtn)),
            writeBtn: _actionButton(
              'Write',
              aaWriteSettings
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.ringsOutWriteBtn),
            ),
          ),
          // Status is DLMS Class 28 attr 4 — always read-only.
          _buildFieldRow(
            'Status',
            _enumDropdown<int>(
              _autoAnswerStatus,
              _autoAnswerStatusLabels,
              null,
              key: const Key(ModemConfigKeys.autoAnswerStatusDropdown),
            ),
            readBtn: _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.autoAnswerStatusReadBtn)),
            writeBtn: _actionButton('Write', null, color: DesignTokens.success),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('Allowed Callers', Icons.contacts_outlined, [
          _buildAllowedCallersTable(aaWriteCallers),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (aaWriteCallers) ...[
              AppButton.primary(
                key: const Key(ModemConfigKeys.allowedCallersAddBtn),
                onPressed: () => setState(() =>
                    _allowedCallers = List.from(_allowedCallers)
                      ..add(AllowedCallerEntry(callerId: '', callType: 0))),
                icon: Icons.add,
                label: 'Add',
              ),
              const SizedBox(width: 8),
            ],
            _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.allowedCallersReadBtn)),
            const SizedBox(width: 8),
            _actionButton(
              'Write',
              aaWriteCallers
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.allowedCallersWriteBtn),
            ),
          ]),
        ]),
        const SizedBox(height: 16),
        _buildSection('Listening Window', Icons.hearing_outlined, [
          if (aaWriteLw) ...[
            _buildDateTimePickerRow(
              'Start Time',
              _newLwStart,
              (dt) => setState(() => _newLwStart = dt),
            ),
            _buildDateTimePickerRow(
              'End Time',
              _newLwEnd,
              (dt) => setState(() => _newLwEnd = dt),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              AppButton.primary(
                key: const Key(ModemConfigKeys.listeningWindowAddBtn),
                onPressed: (_newLwStart != null || _newLwEnd != null)
                    ? () {
                        setState(() {
                          _listeningWindow = List.from(_listeningWindow)
                            ..add(CallingWindowEntry(
                              startTime: _newLwStart != null
                                  ? _formatDt(_newLwStart!)
                                  : '',
                              endTime: _newLwEnd != null
                                  ? _formatDt(_newLwEnd!)
                                  : '',
                            ));
                          _newLwStart = null;
                          _newLwEnd = null;
                        });
                      }
                    : null,
                icon: Icons.add,
                label: 'Add to list',
              ),
            ]),
            const Divider(height: 24),
          ],
          _buildListeningWindowTable(
            entries: _listeningWindow,
            canWrite: aaWriteLw,
            onUpdate: (list) => setState(() => _listeningWindow = list),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _actionButton('Read',
                canRead ? () => _readAndReport(_doReadAutoAnswer) : null,
                key: const Key(ModemConfigKeys.listeningWindowReadBtn)),
            const SizedBox(width: 8),
            _actionButton(
              'Write',
              aaWriteLw
                  ? () =>
                      _writeAndReport(() => _client.setAutoAnswer(buildReq()))
                  : null,
              color: DesignTokens.success,
              key: const Key(ModemConfigKeys.listeningWindowWriteBtn),
            ),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildAllowedCallersTable(bool canWrite) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(2),
        2: IntrinsicColumnWidth(),
      },
      border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: DesignTokens.primary600.withValues(alpha: 0.08)),
          children: [_th('Caller ID'), _th('Call Type'), _th('')],
        ),
        if (_allowedCallers.isEmpty)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text('No allowed callers',
                        style: TextStyle(
                            color: DesignTokens.textSecondary, fontSize: 13)),
                  ),
                ),
              ),
              const TableCell(child: SizedBox.shrink()),
              const TableCell(child: SizedBox.shrink()),
            ],
          )
        else
          for (int i = 0; i < _allowedCallers.length; i++)
            TableRow(
              decoration: BoxDecoration(
                  color: i.isOdd ? Colors.grey.shade50 : Colors.white),
              children: [
                _tCell(_inlineTextField(
                  _allowedCallers[i].callerId,
                  readOnly: !canWrite,
                  onChanged: (v) => setState(() {
                    final list = List<AllowedCallerEntry>.from(_allowedCallers);
                    list[i] = AllowedCallerEntry(
                        callerId: v, callType: _allowedCallers[i].callType);
                    _allowedCallers = list;
                  }),
                )),
                _tCell(_inlineTextField(
                  _allowedCallers[i].callType.toString(),
                  readOnly: !canWrite,
                  onChanged: (v) => setState(() {
                    final list = List<AllowedCallerEntry>.from(_allowedCallers);
                    list[i] = AllowedCallerEntry(
                        callerId: _allowedCallers[i].callerId,
                        callType: int.tryParse(v) ?? 0);
                    _allowedCallers = list;
                  }),
                )),
                _tCell(canWrite
                    ? _deleteBtn(() => setState(() {
                          _allowedCallers = List.from(_allowedCallers)
                            ..removeAt(i);
                        }))
                    : const SizedBox.shrink()),
              ],
            ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Tab 4 – TCP/UDP Setup
  // --------------------------------------------------------------------------

  Widget _buildTcpUdpSetupTab(bool canRead, bool canWrite) {
    final bool tudWritePort = canWrite && _tudCanWrite(2);
    // attr 3 = IP_reference is always read-only
    final bool tudWriteMss = canWrite && _tudCanWrite(4);
    final bool tudWriteNb = canWrite && _tudCanWrite(5);
    final bool tudWriteTimeout = canWrite && _tudCanWrite(6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSection('TCP/UDP Parameters', Icons.lan_outlined, [
        _buildFieldRow(
          'TCP-UDP Port',
          _textField(_tcpPortCtrl,
              key: const Key(ModemConfigKeys.tcpPortField),
              readOnly: !tudWritePort, keyboardType: TextInputType.number),
          readBtn: _actionButton('Read',
              canRead ? () => _readAndReport(_doReadTcpUdpSetup) : null,
              key: const Key(ModemConfigKeys.tcpPortReadBtn)),
          writeBtn: _actionButton(
            'Write',
            tudWritePort
                ? () => _writeAndReport(() => _client.setTcpUdpSetup(
                      SetTcpUdpSetupRequest(
                        port: int.tryParse(_tcpPortCtrl.text) ?? 4059,
                        mss: int.tryParse(_mssCtrl.text) ?? 0,
                        nbConnections:
                            int.tryParse(_nbConnectionsCtrl.text) ?? 1,
                        inactivityTimeout:
                            int.tryParse(_inactivityTimeoutCtrl.text) ?? 0,
                      ),
                    ))
                : null,
            color: DesignTokens.success,
            key: const Key(ModemConfigKeys.tcpPortWriteBtn),
          ),
        ),
        _buildFieldRow(
          'IP Reference',
          _textField(_ipReferenceCtrl, key: const Key(ModemConfigKeys.ipReferenceField), readOnly: true),
          readBtn: _actionButton('Read',
              canRead ? () => _readAndReport(_doReadTcpUdpSetup) : null,
              key: const Key(ModemConfigKeys.ipReferenceReadBtn)),
          writeBtn: _actionButton('Write', null, color: DesignTokens.success),
        ),
        _buildFieldRow(
          'MSS',
          _textField(_mssCtrl,
              key: const Key(ModemConfigKeys.mssField),
              readOnly: !tudWriteMss, keyboardType: TextInputType.number),
          readBtn: _actionButton('Read',
              canRead ? () => _readAndReport(_doReadTcpUdpSetup) : null,
              key: const Key(ModemConfigKeys.mssReadBtn)),
          writeBtn: _actionButton(
            'Write',
            tudWriteMss
                ? () => _writeAndReport(() => _client.setTcpUdpSetup(
                      SetTcpUdpSetupRequest(
                        port: int.tryParse(_tcpPortCtrl.text) ?? 4059,
                        mss: int.tryParse(_mssCtrl.text) ?? 0,
                        nbConnections:
                            int.tryParse(_nbConnectionsCtrl.text) ?? 1,
                        inactivityTimeout:
                            int.tryParse(_inactivityTimeoutCtrl.text) ?? 0,
                      ),
                    ))
                : null,
            color: DesignTokens.success,
            key: const Key(ModemConfigKeys.mssWriteBtn),
          ),
        ),
        _buildFieldRow(
          'NB of SIM Conn',
          _textField(_nbConnectionsCtrl,
              key: const Key(ModemConfigKeys.nbConnectionsField),
              readOnly: !tudWriteNb, keyboardType: TextInputType.number),
          readBtn: _actionButton('Read',
              canRead ? () => _readAndReport(_doReadTcpUdpSetup) : null,
              key: const Key(ModemConfigKeys.nbConnectionsReadBtn)),
          writeBtn: _actionButton(
            'Write',
            tudWriteNb
                ? () => _writeAndReport(() => _client.setTcpUdpSetup(
                      SetTcpUdpSetupRequest(
                        port: int.tryParse(_tcpPortCtrl.text) ?? 4059,
                        mss: int.tryParse(_mssCtrl.text) ?? 0,
                        nbConnections:
                            int.tryParse(_nbConnectionsCtrl.text) ?? 1,
                        inactivityTimeout:
                            int.tryParse(_inactivityTimeoutCtrl.text) ?? 0,
                      ),
                    ))
                : null,
            color: DesignTokens.success,
            key: const Key(ModemConfigKeys.nbConnectionsWriteBtn),
          ),
        ),
        _buildFieldRow(
          'Inactivity Timeout',
          _textField(_inactivityTimeoutCtrl,
              key: const Key(ModemConfigKeys.inactivityTimeoutField),
              readOnly: !tudWriteTimeout, keyboardType: TextInputType.number),
          readBtn: _actionButton('Read',
              canRead ? () => _readAndReport(_doReadTcpUdpSetup) : null,
              key: const Key(ModemConfigKeys.inactivityTimeoutReadBtn)),
          writeBtn: _actionButton(
            'Write',
            tudWriteTimeout
                ? () => _writeAndReport(() => _client.setTcpUdpSetup(
                      SetTcpUdpSetupRequest(
                        port: int.tryParse(_tcpPortCtrl.text) ?? 4059,
                        mss: int.tryParse(_mssCtrl.text) ?? 0,
                        nbConnections:
                            int.tryParse(_nbConnectionsCtrl.text) ?? 1,
                        inactivityTimeout:
                            int.tryParse(_inactivityTimeoutCtrl.text) ?? 0,
                      ),
                    ))
                : null,
            color: DesignTokens.success,
            key: const Key(ModemConfigKeys.inactivityTimeoutWriteBtn),
          ),
        ),
      ]),
    );
  }
}
