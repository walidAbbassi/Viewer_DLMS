import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
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

class SimConfigPage extends ConsumerStatefulWidget {
  const SimConfigPage({super.key});

  @override
  ConsumerState<SimConfigPage> createState() => _SimConfigPageState();
}

class _SimConfigPageState extends ConsumerState<SimConfigPage> {
  late IMeterClient _client;

  // ---- global state ----
  bool _isLoading = false;
  String? _error;

  // ---- Group 1 – Modem Config ----
  final _apnCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _pppUserCtrl = TextEditingController();
  final _pppPassCtrl = TextEditingController();

  // ---- Group 2 – IP Address ----
  bool _isIpv6 = false;
  final _ipCtrl = TextEditingController();

  // ---- Group 3 – Cellular Diagnostics ----
  final _operatorCtrl = TextEditingController();
  int _statusVal = 0;
  int _csAttachmentVal = 0;
  int _psStatusVal = 0;
  bool _showCellInfo = false;
  bool _showQos = false;
  bool _isLteMode = false;

  // ---- Group 4a – Cell Info GPRS (Class 47 attr 6) ----
  List<CellInfoEntry> _cellInfoGprsEntries = [];
  int? _selectedGprsIndex;
  final _gprsValueCtrl = TextEditingController();

  // ---- Group 5 – QoS ----
  List<QosEntry> _qosProfiles = [];
  int? _selectedQosIndex;
  final _precCtrl = TextEditingController();
  final _delayCtrl = TextEditingController();
  final _relCtrl = TextEditingController();
  final _peakCtrl = TextEditingController();
  final _meanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(appControllerProvider).isConnected) {
        _readAll();
      }
    });
  }

  @override
  void dispose() {
    _apnCtrl.dispose();
    _pinCtrl.dispose();
    _pppUserCtrl.dispose();
    _pppPassCtrl.dispose();
    _ipCtrl.dispose();
    _operatorCtrl.dispose();
    _gprsValueCtrl.dispose();
    _precCtrl.dispose();
    _delayCtrl.dispose();
    _relCtrl.dispose();
    _peakCtrl.dispose();
    _meanCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Read helpers
  // --------------------------------------------------------------------------

  Future<void> _readAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _doReadModemConfig();
      await _doReadIpAddress();
      await _doReadCellularDiag();
      if (_showCellInfo) {
        await _doReadCellInfo();
      }
      if (_showQos) {
        await _doReadQos();
      }
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _doReadModemConfig() async {
    final r = await _client.getModemConfig();
    setState(() {
      _apnCtrl.text = r.apn;
      _pinCtrl.text = r.pinCode.toString();
      _pppUserCtrl.text = r.pppUsername;
      _pppPassCtrl.text = r.pppPassword;
    });
  }

  Future<void> _doReadIpAddress() async {
    final r = await _client.getIpAddress();
    setState(() {
      _isIpv6 = r.isIpv6;
      _ipCtrl.text = r.address;
    });
  }

  Future<void> _doReadCellularDiag() async {
    final r = await _client.getCellularDiag();
    if (!mounted) return;
    setState(() {
      _operatorCtrl.text = r.operatorName;
      _statusVal = r.status;
      _csAttachmentVal = r.csAttachment;
      _psStatusVal = r.psStatus;
      _showCellInfo = r.showCellInfo;
      _showQos = r.showQos;
      _isLteMode = r.isLteMode;
    });
  }

  Future<void> _doReadCellInfo() async {
    try {
      final r = await _client.getCellInfo();
      if (!mounted) return;
      setState(() {
        _cellInfoGprsEntries = List.from(r.entries);
        _selectedGprsIndex = null;
        _gprsValueCtrl.clear();
      });
    } catch (_) {
      // cell info unavailable
    }
  }

  Future<void> _doReadQos() async {
    final r = await _client.getQos();
    setState(() {
      _qosProfiles = List.from(r.profiles);
      _selectedQosIndex = null;
      _clearQosFields();
    });
  }

  void _clearQosFields() {
    _precCtrl.clear();
    _delayCtrl.clear();
    _relCtrl.clear();
    _peakCtrl.clear();
    _meanCtrl.clear();
  }

  void _populateQosFields(QosEntry e) {
    _precCtrl.text = e.precedence.toString();
    _delayCtrl.text = e.delay.toString();
    _relCtrl.text = e.reliability.toString();
    _peakCtrl.text = e.peakThroughput.toString();
    _meanCtrl.text = e.meanThroughput.toString();
  }

  // --------------------------------------------------------------------------
  // Read / Write report helpers
  // --------------------------------------------------------------------------

  Future<void> _readAndReport(Future<void> Function() action) async {
    setState(() => _error = null);
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
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Icon(Icons.error_outline, color: DesignTokens.danger),
            const SizedBox(width: 10),
            const Text('Write Failed'),
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
    }
  }

  String _friendlyError(Object e) => extractGrpcMessage(e);

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);
    final canRead = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Get', FeatureKeys.simConfig);
    final canWrite = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Set', FeatureKeys.simConfig);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM Config'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [RefreshAppBarButton(onPressed: _readAll)],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_error != null) _buildErrorBanner(),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1024;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: isDesktop
                        ? _buildDesktopLayout(canRead, canWrite)
                        : _buildMobileLayout(canRead, canWrite),
                  );
                }),
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
          key: const Key(SimConfigKeys.dismissErrorBtn),
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => setState(() => _error = null),
        ),
      ]),
    );
  }

  Widget _buildDesktopLayout(bool canRead, bool canWrite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(children: [
            _buildModemConfigSection(canRead, canWrite),
            const SizedBox(height: 16),
            _buildIpAddressSection(canRead, canWrite),
            if (_showQos) ...[
              const SizedBox(height: 16),
              _buildQosSection(canRead, canWrite),
            ],
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(children: [
            _buildCellularDiagSection(canRead, canWrite),
            if (_showCellInfo) ...[
              const SizedBox(height: 16),
              _buildCellInfoSection(canRead),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool canRead, bool canWrite) {
    return Column(children: [
      _buildModemConfigSection(canRead, canWrite),
      const SizedBox(height: 16),
      _buildIpAddressSection(canRead, canWrite),
      const SizedBox(height: 16),
      _buildCellularDiagSection(canRead, canWrite),
      if (_showCellInfo) ...[
        const SizedBox(height: 16),
        _buildCellInfoSection(canRead),
      ],
      if (_showQos) ...[
        const SizedBox(height: 16),
        _buildQosSection(canRead, canWrite),
      ],
    ]);
  }

  // --------------------------------------------------------------------------
  // Section builders
  // --------------------------------------------------------------------------

  Card _buildSection(String title, IconData icon, List<Widget> children) {
    final bool isDark = DesignTokens.isDark(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: DesignTokens.surfaceOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.primary600.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                  bottom: BorderSide(
                      color: DesignTokens.borderOf(context), width: 1)),
            ),
            child: Row(children: [
              Icon(icon,
                  size: 20,
                  color: isDark
                      ? DesignTokens.darkFocus
                      : DesignTokens.primary600),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context))),
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
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
        ),
        Expanded(child: control),
        if (readBtn != null) ...[const SizedBox(width: 6), readBtn],
        if (writeBtn != null) ...[const SizedBox(width: 6), writeBtn],
      ]),
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed, {Color? color, Key? key}) {
    final isWrite = label == 'Write';
    return FilledButton.icon(
      key: key,
      onPressed: onPressed,
      icon: Icon(isWrite ? Icons.edit : Icons.visibility, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor:
            isWrite ? const Color(0xFF1976D2) : const Color(0xFFFF9800),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  // ---- Enum label maps ----

  static const _statusLabels = <int, String>{
    0: 'not registered',
    1: 'registered, home network',
    2: 'not registered, searching',
    3: 'registration denied',
    4: 'unknown',
    5: 'registered, roaming',
    6: 'reserved',
  };

  static const _csAttachmentLabels = <int, String>{
    0: 'inactive',
    1: 'incoming call',
    2: 'active',
    3: 'reserved',
  };

  static const _psStatusLabels = <int, String>{
    0: 'inactive',
    1: 'GPRS',
    2: 'EDGE',
    3: 'UMTS',
    4: 'HSDPA',
    5: 'LTE',
    6: 'CDMA',
    7: 'LTE Cat M1',
    8: 'LTE NB-IoT',
  };

  Widget _enumDropdown(
      int value, Map<int, String> labels, ValueChanged<int?>? onChanged, {Key? key}) {
    final effectiveValue =
        labels.containsKey(value) ? value : labels.keys.first;
    return DropdownButtonFormField<int>(
      key: key,
      value: effectiveValue,
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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
                color: DesignTokens.isDark(context)
                    ? DesignTokens.darkFocus
                    : DesignTokens.primary600,
                width: 1.2)),
        fillColor: onChanged == null
            ? (DesignTokens.isDark(context)
                ? DesignTokens.darkSurfaceAlt
                : Colors.grey.shade100)
            : DesignTokens.surfaceOf(context),
        filled: true,
      ),
    );
  }

  Widget _textField(TextEditingController ctrl,
      {Key? key, bool readOnly = false, TextInputType? keyboardType}) {
    final dark = DesignTokens.isDark(context);
    return TextField(
      key: key,
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style:
          TextStyle(fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
                color: dark ? DesignTokens.darkFocus : DesignTokens.primary600,
                width: 1.2)),
        fillColor: readOnly
            ? (dark ? DesignTokens.darkSurfaceAlt : Colors.grey.shade100)
            : DesignTokens.surfaceOf(context),
        filled: true,
      ),
    );
  }

  // ---- Group 1 ----

  Widget _buildModemConfigSection(bool canRead, bool canWrite) {
    return _buildSection(
        'Configuration (APN / PIN / PPP)', Icons.settings_cell, [
      _buildFieldRow(
        'APN',
        _textField(_apnCtrl, key: const Key(SimConfigKeys.apnField)),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadModemConfig) : null,
            key: const Key(SimConfigKeys.apnReadBtn)),
        writeBtn: _actionButton(
            'Write',
            canWrite
                ? () => _writeAndReport(() => _client.setApn(_apnCtrl.text))
                : null,
            color: DesignTokens.success,
            key: const Key(SimConfigKeys.apnWriteBtn)),
      ),
      _buildFieldRow(
        'PIN Code',
        _textField(_pinCtrl, key: const Key(SimConfigKeys.pinField), keyboardType: TextInputType.number),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadModemConfig) : null,
            key: const Key(SimConfigKeys.pinReadBtn)),
        writeBtn: _actionButton(
            'Write',
            canWrite
                ? () => _writeAndReport(
                    () => _client.setPinCode(int.tryParse(_pinCtrl.text) ?? 0))
                : null,
            color: DesignTokens.success,
            key: const Key(SimConfigKeys.pinWriteBtn)),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Text('PPP Authentication',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      // Auth User Name – invisible buttons keep field width = APN/PIN width
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 148,
            child: Text('Auth User Name',
                style: TextStyle(
                    fontSize: 13,
                    color: DesignTokens.textSecondaryOf(context))),
          ),
          Expanded(child: _textField(_pppUserCtrl, key: const Key(SimConfigKeys.pppUserField))),
          const SizedBox(width: 6),
          Opacity(
              opacity: 0,
              child: IgnorePointer(child: _actionButton('Read', null))),
          const SizedBox(width: 6),
          Opacity(
              opacity: 0,
              child: IgnorePointer(
                  child: _actionButton('Write', null,
                      color: DesignTokens.success))),
        ]),
      ),
      // Real buttons – centered between Auth User Name and Auth Password
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(width: 148),
          const Expanded(child: SizedBox()),
          const SizedBox(width: 6),
          _actionButton('Read',
              canRead ? () => _readAndReport(_doReadModemConfig) : null,
              key: const Key(SimConfigKeys.pppReadBtn)),
          const SizedBox(width: 6),
          _actionButton(
            'Write',
            canWrite
                ? () => _writeAndReport(() =>
                    _client.setPppAuth(_pppUserCtrl.text, _pppPassCtrl.text))
                : null,
            color: DesignTokens.success,
            key: const Key(SimConfigKeys.pppWriteBtn),
          ),
        ]),
      ),
      // Auth Password – invisible buttons keep field width = APN/PIN width
      _buildFieldRow(
        'Auth Password',
        _textField(_pppPassCtrl, key: const Key(SimConfigKeys.pppPassField)),
        readBtn: Opacity(
            opacity: 0,
            child: IgnorePointer(child: _actionButton('Read', null))),
        writeBtn: Opacity(
            opacity: 0,
            child: IgnorePointer(
                child:
                    _actionButton('Write', null, color: DesignTokens.success))),
      ),
    ]);
  }

  // ---- Group 2 ----

  Widget _buildIpAddressSection(bool canRead, bool canWrite) {
    return _buildSection('IP Address', Icons.lan, [
      _buildFieldRow(
        _isIpv6 ? 'IPv6 Address' : 'IPv4 Address',
        _textField(_ipCtrl, key: const Key(SimConfigKeys.ipField)),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadIpAddress) : null,
            key: const Key(SimConfigKeys.ipReadBtn)),
        writeBtn: _actionButton(
            'Write',
            canWrite
                ? () => _writeAndReport(
                    () => _client.setIpAddress(_ipCtrl.text, _isIpv6))
                : null,
            color: DesignTokens.success,
            key: const Key(SimConfigKeys.ipWriteBtn)),
      ),
      if (_isIpv6)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('IPv6 mode (Class 48)',
              style: TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSecondaryOf(context),
                  fontStyle: FontStyle.italic)),
        ),
    ]);
  }

  // ---- Group 3 ----

  Widget _buildCellularDiagSection(bool canRead, bool canWrite) {
    return _buildSection(
        _isLteMode ? 'LTE Diagnostic' : 'GPRS Diagnostic', Icons.cell_tower, [
      _buildFieldRow(
        'Operator',
        _textField(_operatorCtrl, key: const Key(SimConfigKeys.operatorField), readOnly: true),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadCellularDiag) : null,
            key: const Key(SimConfigKeys.operatorReadBtn)),
        writeBtn: _actionButton('Write', null, color: DesignTokens.success),
      ),
      _buildFieldRow(
        'Status',
        _enumDropdown(_statusVal, _statusLabels, null,
            key: const Key(SimConfigKeys.statusDropdown)),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadCellularDiag) : null,
            key: const Key(SimConfigKeys.statusReadBtn)),
        writeBtn: _actionButton('Write', null, color: DesignTokens.success),
      ),
      _buildFieldRow(
        'CS Attachment',
        _enumDropdown(_csAttachmentVal, _csAttachmentLabels, null,
            key: const Key(SimConfigKeys.csAttachmentDropdown)),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadCellularDiag) : null,
            key: const Key(SimConfigKeys.csAttachmentReadBtn)),
        writeBtn: _actionButton('Write', null, color: DesignTokens.success),
      ),
      _buildFieldRow(
        'PS Status',
        _enumDropdown(_psStatusVal, _psStatusLabels, null,
            key: const Key(SimConfigKeys.psStatusDropdown)),
        readBtn: _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadCellularDiag) : null,
            key: const Key(SimConfigKeys.psStatusReadBtn)),
        writeBtn: _actionButton('Write', null, color: DesignTokens.success),
      ),
    ]);
  }

  // ---- Group 4a – Cell Info GPRS ----

  Widget _buildCellInfoSection(bool canRead) {
    return _buildSection('Cell Info', Icons.signal_cellular_alt, [
      _buildCellInfoTable(
        entries: _cellInfoGprsEntries,
        selectedIndex: _selectedGprsIndex,
        onSelect: (i) => setState(() {
          _selectedGprsIndex = i;
          _gprsValueCtrl.text = _cellInfoGprsEntries[i].value;
        }),
      ),
      const SizedBox(height: 12),
      _buildCellInfoEditRow(
        ctrl: _gprsValueCtrl,
        canRead: canRead,
        canWrite: false,
        onRead: _doReadCellInfo,
        onWrite: () async {},
        fieldKey: const Key(SimConfigKeys.cellInfoValueField),
        readBtnKey: const Key(SimConfigKeys.cellInfoReadBtn),
        writeBtnKey: const Key(SimConfigKeys.cellInfoWriteBtn),
      ),
    ]);
  }

  Widget _buildCellInfoTable({
    required List<CellInfoEntry> entries,
    required int? selectedIndex,
    required void Function(int) onSelect,
  }) {
    if (entries.isEmpty) {
      return Center(
          child: Text('No data — press Read to load',
              style: TextStyle(
                  color: DesignTokens.textSecondaryOf(context), fontSize: 13)));
    }
    final bool isDark = DesignTokens.isDark(context);
    return Table(
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
      border: TableBorder.all(
          color: DesignTokens.borderOf(context),
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.primary600.withOpacity(0.08)),
          children: [
            _th('Name'),
            _th('Value'),
          ],
        ),
        for (int i = 0; i < entries.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: selectedIndex == i
                    ? DesignTokens.primary600.withOpacity(0.15)
                    : (i.isOdd
                        ? (isDark
                            ? DesignTokens.darkSurfaceAlt
                            : Colors.grey.shade50)
                        : (isDark ? DesignTokens.darkSurface : Colors.white))),
            children: [
              _tCell(entries[i].name, onTap: () => onSelect(i)),
              _tCell(entries[i].value, onTap: () => onSelect(i)),
            ],
          ),
      ],
    );
  }

  Widget _buildCellInfoEditRow({
    required TextEditingController ctrl,
    required bool canRead,
    required bool canWrite,
    required Future<void> Function() onRead,
    required Future<void> Function() onWrite,
    Key? fieldKey,
    Key? readBtnKey,
    Key? writeBtnKey,
  }) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text('Value:',
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
      ),
      Expanded(child: _textField(ctrl, key: fieldKey)),
      const SizedBox(width: 6),
      _actionButton('Read', canRead ? () => _readAndReport(onRead) : null, key: readBtnKey),
      const SizedBox(width: 6),
      _actionButton('Write', canWrite ? onWrite : null,
          color: DesignTokens.success, key: writeBtnKey),
    ]);
  }

  // ---- Group 5 ----

  Widget _buildQosSection(bool canRead, bool canWrite) {
    return _buildSection('Quality of Service', Icons.speed, [
      _buildQosTable(),
      const SizedBox(height: 16),
      _buildQosEditFields(),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _actionButton(
            'Read', canRead ? () => _readAndReport(_doReadQos) : null,
            key: const Key(SimConfigKeys.qosReadBtn)),
        const SizedBox(width: 8),
        _actionButton(
            'Write',
            (canWrite && _selectedQosIndex != null)
                ? () => _writeAndReport(() => _client.setQos(
                    QosEntry(
                      precedence: int.tryParse(_precCtrl.text) ?? 0,
                      delay: int.tryParse(_delayCtrl.text) ?? 0,
                      reliability: int.tryParse(_relCtrl.text) ?? 0,
                      peakThroughput: int.tryParse(_peakCtrl.text) ?? 0,
                      meanThroughput: int.tryParse(_meanCtrl.text) ?? 0,
                    ),
                    _selectedQosIndex!))
                : null,
            color: DesignTokens.success,
            key: const Key(SimConfigKeys.qosWriteBtn)),
      ]),
    ]);
  }

  Widget _buildQosTable() {
    if (_qosProfiles.isEmpty) {
      return Center(
          child: Text('No QoS data',
              style: TextStyle(
                  color: DesignTokens.textSecondaryOf(context), fontSize: 13)));
    }
    final bool isDark = DesignTokens.isDark(context);
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      border: TableBorder.all(
          color: DesignTokens.borderOf(context),
          width: 1,
          borderRadius: BorderRadius.circular(6)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.primary600.withOpacity(0.08)),
          children: [
            _th('Precedence'),
            _th('Delay'),
            _th('Reliability'),
            _th('Peak Thru.'),
            _th('Mean Thru.'),
          ],
        ),
        for (int i = 0; i < _qosProfiles.length; i++)
          TableRow(
            decoration: BoxDecoration(
                color: _selectedQosIndex == i
                    ? DesignTokens.primary600.withOpacity(0.15)
                    : (i.isOdd
                        ? (isDark
                            ? DesignTokens.darkSurfaceAlt
                            : Colors.grey.shade50)
                        : (isDark ? DesignTokens.darkSurface : Colors.white))),
            children: [
              _tCell(_qosProfiles[i].precedence.toString(),
                  onTap: () => _selectQos(i)),
              _tCell(_qosProfiles[i].delay.toString(),
                  onTap: () => _selectQos(i)),
              _tCell(_qosProfiles[i].reliability.toString(),
                  onTap: () => _selectQos(i)),
              _tCell(_qosProfiles[i].peakThroughput.toString(),
                  onTap: () => _selectQos(i)),
              _tCell(_qosProfiles[i].meanThroughput.toString(),
                  onTap: () => _selectQos(i)),
            ],
          ),
      ],
    );
  }

  void _selectQos(int i) {
    setState(() {
      _selectedQosIndex = i;
      _populateQosFields(_qosProfiles[i]);
    });
  }

  Widget _buildQosEditFields() {
    return Column(
      children: [
        _buildFieldRow('Precedence',
            _textField(_precCtrl, key: const Key(SimConfigKeys.qosPrecedenceField), keyboardType: TextInputType.number)),
        _buildFieldRow('Delay (s)',
            _textField(_delayCtrl, key: const Key(SimConfigKeys.qosDelayField), keyboardType: TextInputType.number)),
        _buildFieldRow('Reliability',
            _textField(_relCtrl, key: const Key(SimConfigKeys.qosReliabilityField), keyboardType: TextInputType.number)),
        _buildFieldRow('Peak Throughput',
            _textField(_peakCtrl, key: const Key(SimConfigKeys.qosPeakField), keyboardType: TextInputType.number)),
        _buildFieldRow('Mean Throughput',
            _textField(_meanCtrl, key: const Key(SimConfigKeys.qosMeanField), keyboardType: TextInputType.number)),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Table cell helpers
  // --------------------------------------------------------------------------

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

  Widget _tCell(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(text,
            style: TextStyle(
                fontSize: 12, color: DesignTokens.textPrimaryOf(context))),
      ),
    );
  }
}
