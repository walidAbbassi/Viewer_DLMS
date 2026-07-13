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
// Page â€“ Mobile Network Identifier
// ---------------------------------------------------------------------------

class MobileNetworkIdPage extends ConsumerStatefulWidget {
  const MobileNetworkIdPage({super.key});

  @override
  ConsumerState<MobileNetworkIdPage> createState() =>
      _MobileNetworkIdPageState();
}

class _MobileNetworkIdPageState extends ConsumerState<MobileNetworkIdPage> {
  late IMeterClient _client;

  // ---- global state ----
  bool _isLoading = false;
  String? _error;

  // ---- Identifiers ----
  final _imsiCtrl = TextEditingController();
  final _msisdnCtrl = TextEditingController();
  final _imeiCtrl = TextEditingController();
  final _iccidCtrl = TextEditingController();

  // ---- Modem status ----
  bool _isModemActive = false;
  bool _modemStatusLoaded = false;

  // ---- DLMS per-object rights (loaded after connect) ----
  MniRightsResponse? _mniRights;

  // ---- Validation error messages ----
  String? _imsiError;
  String? _msisdnError;
  String? _imeiError;
  String? _iccidError;

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
    _imsiCtrl.dispose();
    _msisdnCtrl.dispose();
    _imeiCtrl.dispose();
    _iccidCtrl.dispose();
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
      await _doLoadMniRights();
      await _doReadIdentifiers();
      await _doReadModemStatus();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _doLoadMniRights() async {
    try {
      final r = await _client.getMniRights();
      if (!mounted) return;
      setState(() => _mniRights = r);
    } catch (_) {
      // rights unavailable â€“ buttons stay grayed
    }
  }

  Future<void> _doReadIdentifiers() async {
    final r = await _client.getMobileNetworkIdentifiers();
    if (!mounted) return;
    setState(() {
      _imsiCtrl.text = r.imsi;
      _msisdnCtrl.text = r.msisdn;
      _imeiCtrl.text = r.imei;
      _iccidCtrl.text = r.iccid;
    });
  }

  Future<void> _doReadModemStatus() async {
    try {
      final r = await _client.getModemStatus();
      if (!mounted) return;
      setState(() {
        _isModemActive = r.isActive;
        _modemStatusLoaded = true;
      });
    } catch (_) {
      // status unavailable â€“ keep defaults
    }
  }

  // --------------------------------------------------------------------------
  // Validation
  // --------------------------------------------------------------------------

  /// Returns null if valid, otherwise an error message.
  String? _validateField(String value, int maxLen) {
    if (value.isEmpty) return null; // empty = unchanged, allow
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only numeric characters (0â€“9) are accepted.';
    }
    if (value.length > maxLen) {
      return 'Maximum $maxLen characters.';
    }
    return null;
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
              const Text('The value was read from the meter successfully.'),
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

  Future<void> _actionAndReport(
    String actionLabel,
    Future<bool> Function() action,
  ) async {
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
            Text(ok ? '$actionLabel Successful' : '$actionLabel Failed'),
          ]),
          content: Text(ok
              ? 'The operation completed successfully.'
              : 'The meter did not accept the request.'),
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
            Text('$actionLabel Failed'),
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
  // Modem control
  // --------------------------------------------------------------------------

  Future<void> _toggleModem(bool canWrite) async {
    if (!canWrite) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _actionAndReport(
        _isModemActive ? 'Deactivate Modem' : 'Activate Modem',
        () => _client.setModemStatus(!_isModemActive),
      );
      await _doReadModemStatus();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restartModem(bool canWrite) async {
    if (!canWrite) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(children: [
          Icon(Icons.restart_alt, color: SemanticColors.of(dialogContext).warning),
          const SizedBox(width: 10),
          const Text('Restart Modem'),
        ]),
        content: const Text('This will restart the cellular modem. Continue?'),
        actions: [
          TextButton(
            key: const Key(MobileNetworkIdKeys.modemRestartCancelBtn),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          AppButton.primary(
            key: const Key(MobileNetworkIdKeys.modemRestartConfirmBtn),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: 'Restart',
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _actionAndReport('Restart Modem', () => _client.restartModem());
      await _doReadModemStatus();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    final appState = ref.watch(appControllerProvider);
    final canRead = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Get', FeatureKeys.mobileNetworkId);
    final canWrite = !appState.simulation &&
        appState.isConnected &&
        userRights.hasRightForFeature('Set', FeatureKeys.mobileNetworkId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Network Identifier'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [RefreshAppBarButton(key: const Key(MobileNetworkIdKeys.refreshBtn), onPressed: _readAll)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Breadcrumb(
                segments: ['Menu', 'P2P Setup', 'Mobile Network Identifier']),
          ),
          Expanded(
            child: Stack(
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
          key: const Key(MobileNetworkIdKeys.dismissErrorBtn),
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
            _buildIdentifiersSection(canRead, canWrite),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(children: [
            _buildModemControlSection(canRead, canWrite),
            const SizedBox(height: 16),
            _buildTechSection(),
          ]),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool canRead, bool canWrite) {
    return Column(children: [
      _buildIdentifiersSection(canRead, canWrite),
      const SizedBox(height: 16),
      _buildModemControlSection(canRead, canWrite),
      const SizedBox(height: 16),
      _buildTechSection(),
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

  Widget _buildFieldRow(
    String label,
    Widget control, {
    Widget? readBtn,
    Widget? writeBtn,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              width: 148,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.textSecondaryOf(context))),
            ),
            Expanded(child: control),
            if (readBtn != null) ...[const SizedBox(width: 6), readBtn],
            if (writeBtn != null) ...[const SizedBox(width: 6), writeBtn],
          ]),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(left: 148, top: 3),
              child: Text(
                hint,
                style: TextStyle(
                    fontSize: 11,
                    color:
                        DesignTokens.textSecondaryOf(context).withOpacity(0.7)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed, {Key? key}) {
    final isWrite = label == 'Write';
    return AppButton(
      key: key,
      label: label,
      icon: isWrite ? AppIcons.write : AppIcons.read,
      variant: isWrite ? AppButtonVariant.primary : AppButtonVariant.secondary,
      onPressed: onPressed,
    );
  }

  // ---- Section 1: Identifiers ----

  Widget _buildIdentifiersSection(bool canRead, bool canWrite) {
    final dlms = _mniRights;
    return _buildSection(
      'Mobile Network Identifiers',
      Icons.sim_card,
      [
        _buildFieldRow(
          'IMSI',
          _buildTextField(
            key: const Key(MobileNetworkIdKeys.imsiField),
            controller: _imsiCtrl,
            errorText: _imsiError,
            onChanged: (v) =>
                setState(() => _imsiError = _validateField(v, 15)),
          ),
          hint: 'ITU-T E.212 â€” max 15 numeric characters',
          readBtn: _actionButton(
            'Read',
            canRead && (dlms?.imsiGet ?? false)
                ? () => _readAndReport(() async {
                      final r = await _client.getMobileNetworkIdentifiers();
                      setState(() => _imsiCtrl.text = r.imsi);
                    })
                : null,
            key: const Key(MobileNetworkIdKeys.imsiReadBtn),
          ),
          writeBtn: _actionButton(
            'Write',
            canWrite &&
                    (dlms?.imsiSet ?? false) &&
                    _imsiError == null &&
                    _imsiCtrl.text.isNotEmpty
                ? () => _writeAndReport(() => _client.setImsi(_imsiCtrl.text))
                : null,
            key: const Key(MobileNetworkIdKeys.imsiWriteBtn),
          ),
        ),
        _buildFieldRow(
          'MSISDN',
          _buildTextField(
            key: const Key(MobileNetworkIdKeys.msisdnField),
            controller: _msisdnCtrl,
            errorText: _msisdnError,
            onChanged: (v) =>
                setState(() => _msisdnError = _validateField(v, 20)),
          ),
          hint: 'ITU-T E.164 â€” max 20 numeric characters',
          readBtn: _actionButton(
            'Read',
            canRead && (dlms?.msisdnGet ?? false)
                ? () => _readAndReport(() async {
                      final r = await _client.getMobileNetworkIdentifiers();
                      setState(() => _msisdnCtrl.text = r.msisdn);
                    })
                : null,
            key: const Key(MobileNetworkIdKeys.msisdnReadBtn),
          ),
          writeBtn: _actionButton(
            'Write',
            canWrite &&
                    (dlms?.msisdnSet ?? false) &&
                    _msisdnError == null &&
                    _msisdnCtrl.text.isNotEmpty
                ? () =>
                    _writeAndReport(() => _client.setMsisdn(_msisdnCtrl.text))
                : null,
            key: const Key(MobileNetworkIdKeys.msisdnWriteBtn),
          ),
        ),
        _buildFieldRow(
          'IMEI',
          _buildTextField(
            key: const Key(MobileNetworkIdKeys.imeiField),
            controller: _imeiCtrl,
            errorText: _imeiError,
            onChanged: (v) =>
                setState(() => _imeiError = _validateField(v, 15)),
          ),
          hint: 'GSMA TS.06 â€” max 15 numeric characters',
          readBtn: _actionButton(
            'Read',
            canRead && (dlms?.imeiGet ?? false)
                ? () => _readAndReport(() async {
                      final r = await _client.getMobileNetworkIdentifiers();
                      setState(() => _imeiCtrl.text = r.imei);
                    })
                : null,
            key: const Key(MobileNetworkIdKeys.imeiReadBtn),
          ),
          writeBtn: _actionButton(
            'Write',
            canWrite &&
                    (dlms?.imeiSet ?? false) &&
                    _imeiError == null &&
                    _imeiCtrl.text.isNotEmpty
                ? () => _writeAndReport(() => _client.setImei(_imeiCtrl.text))
                : null,
            key: const Key(MobileNetworkIdKeys.imeiWriteBtn),
          ),
        ),
        _buildFieldRow(
          'ICCID',
          _buildTextField(
            key: const Key(MobileNetworkIdKeys.iccidField),
            controller: _iccidCtrl,
            errorText: _iccidError,
            onChanged: (v) =>
                setState(() => _iccidError = _validateField(v, 22)),
          ),
          hint: 'ISO/IEC 7816, ITU-T E.118 â€” max 22 numeric characters',
          readBtn: _actionButton(
            'Read',
            canRead && (dlms?.iccidGet ?? false)
                ? () => _readAndReport(() async {
                      final r = await _client.getMobileNetworkIdentifiers();
                      setState(() => _iccidCtrl.text = r.iccid);
                    })
                : null,
            key: const Key(MobileNetworkIdKeys.iccidReadBtn),
          ),
          writeBtn: _actionButton(
            'Write',
            canWrite &&
                    (dlms?.iccidSet ?? false) &&
                    _iccidError == null &&
                    _iccidCtrl.text.isNotEmpty
                ? () => _writeAndReport(() => _client.setIccid(_iccidCtrl.text))
                : null,
            key: const Key(MobileNetworkIdKeys.iccidWriteBtn),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? errorText,
    ValueChanged<String>? onChanged,
    Key? key,
  }) {
    return TextField(
      key: key,
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: DesignTokens.inputDecorationOf(context).copyWith(
        errorText: errorText,
        errorMaxLines: 2,
      ),
      style:
          TextStyle(fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
    );
  }

  // ---- Section 2: Modem Control ----

  Widget _buildModemControlSection(bool canRead, bool canWrite) {
    final dlms = _mniRights;
    final canReadModem = canRead && (dlms?.modemGet ?? false);
    final canWriteModem = canWrite && (dlms?.modemSet ?? false);

    return _buildSection(
      'Modem Control',
      Icons.router,
      [
        // Status banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: !_modemStatusLoaded
                ? DesignTokens.borderOf(context).withOpacity(0.15)
                : _isModemActive
                    ? DesignTokens.success.withOpacity(0.08)
                    : DesignTokens.danger.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(
              !_modemStatusLoaded
                  ? Icons.help_outline
                  : _isModemActive
                      ? Icons.signal_cellular_alt
                      : Icons.signal_cellular_off,
              size: 22,
              color: !_modemStatusLoaded
                  ? DesignTokens.textSecondaryOf(context)
                  : _isModemActive
                      ? DesignTokens.success
                      : DesignTokens.danger,
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Modem Status',
                style: TextStyle(
                  fontSize: 11,
                  color: DesignTokens.textSecondaryOf(context),
                ),
              ),
              Text(
                !_modemStatusLoaded
                    ? 'Unknown'
                    : _isModemActive
                        ? 'Active'
                        : 'Inactive',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: !_modemStatusLoaded
                      ? DesignTokens.textSecondaryOf(context)
                      : _isModemActive
                          ? DesignTokens.success
                          : DesignTokens.danger,
                ),
              ),
            ]),
          ]),
        ),
        // Row 1 â€“ Activate / Deactivate
        Row(children: [
          Expanded(
            child: AppButton.primary(
              key: const Key(MobileNetworkIdKeys.modemActivateBtn),
              onPressed: canWriteModem && !_isModemActive
                  ? () => _toggleModem(canWrite)
                  : null,
              icon: Icons.signal_cellular_alt,
              label: 'Activate',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.danger(
              key: const Key(MobileNetworkIdKeys.modemDeactivateBtn),
              onPressed: canWriteModem && _isModemActive
                  ? () => _toggleModem(canWrite)
                  : null,
              icon: Icons.signal_cellular_off,
              label: 'Deactivate',
            ),
          ),
        ]),
        const SizedBox(height: 10),
        // Row 2 â€“ Restart / Refresh
        Row(children: [
          Expanded(
            child: AppButton.secondary(
              key: const Key(MobileNetworkIdKeys.modemRestartBtn),
              onPressed: canWriteModem ? () => _restartModem(canWrite) : null,
              icon: Icons.restart_alt,
              label: 'Restart',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.secondary(
              key: const Key(MobileNetworkIdKeys.modemRefreshBtn),
              onPressed: canReadModem
                  ? () async {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      try {
                        await _doReadModemStatus();
                      } catch (e) {
                        setState(() => _error = _friendlyError(e));
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  : null,
              icon: AppIcons.refresh,
              label: 'Refresh',
            ),
          ),
        ]),
      ],
    );
  }

  // ---- Section 3: Supported Technologies (read-only) ----

  Widget _buildTechSection() {
    const techs = [
      _TechBadge('GSM', '2G', Icons.cell_tower, Color(0xFF4CAF50)),
      _TechBadge(
          'GPRS', '2G / 2.5G', Icons.signal_cellular_alt, Color(0xFF2196F3)),
      _TechBadge('LTE Cat.M1', '4G', Icons.network_cell, Color(0xFF9C27B0)),
      _TechBadge('NB-IoT', '4G', Icons.wifi_tethering, Color(0xFFFF9800)),
    ];

    return _buildSection(
      'Supported Technologies',
      Icons.signal_cellular_alt,
      [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: techs.map((t) => _buildTechChip(t)).toList(),
        ),
      ],
    );
  }

  Widget _buildTechChip(_TechBadge tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tech.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tech.color.withOpacity(0.35), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(tech.icon, size: 16, color: tech.color),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tech.label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tech.color)),
          Text(tech.generation,
              style: TextStyle(
                  fontSize: 11, color: DesignTokens.textSecondaryOf(context))),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper data class
// ---------------------------------------------------------------------------

class _TechBadge {
  final String label;
  final String generation;
  final IconData icon;
  final Color color;
  const _TechBadge(this.label, this.generation, this.icon, this.color);
}

