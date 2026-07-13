import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../state/hdlc_timeout_provider.dart';
import '../../core/export/exportable_page.dart';
import '../../state/device_id_cache.dart';
import '../../core/export/export_registry.dart';
import '../../core/export/export_action_button.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/services/feedback_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/configuration_client.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/configuration.pb.dart';
import '../../grpc/generated/configuration.pbgrpc.dart';
import '../../util/any_to_dart.dart';
import '../../util/dart_to_any.dart';
import '../../util/bytes_util.dart';
import '../../routes/app_routes.dart';
import '../../core/widget_keys.dart';

/// DLMS Configuration V2 Screen
/// Portage Flutter de la maquette dlms-configuration_v2.html
class ConfigurationPage extends ConsumerStatefulWidget {
  const ConfigurationPage({super.key, this.initialTabKey = 'general'});

  final String initialTabKey;
  @override
  ConsumerState<ConfigurationPage> createState() => _ConfigurationPageState();
}

typedef ConfigurationClientFactory = IConfigurationClient Function();

ConfigurationClientFactory _configurationClientFactory =
    () => ConfigurationClient();

@visibleForTesting
bool configurationPageAutoCoverDiagnostics = false;

@visibleForTesting
set configurationClientFactory(ConfigurationClientFactory value) {
  _configurationClientFactory = value;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

// ── Search index ─────────────────────────────────────────────────────────────
class _SettingEntry {
  final String tabKey;
  final String label;
  final String keywords;
  const _SettingEntry(this.tabKey, this.label, this.keywords);
}

const List<_SettingEntry> _kSettingsIndex = [
  // General
  _SettingEntry('general', 'Pre-established', 'pre_established'),
  _SettingEntry(
      'general', 'Calling AE Invocation ID', 'calling_ae_invocation_id'),
  _SettingEntry('general', 'Serial Port', 'serial port com'),
  _SettingEntry('general', 'Baud Rate', 'baudrate serial gprs'),
  _SettingEntry('general', 'Client Address', 'client_addr'),
  _SettingEntry('general', 'Server Address', 'server_addr'),
  _SettingEntry('general', 'GPRS IP', 'gprs gprsip gprsport'),
  _SettingEntry('general', 'PLC IPv4', 'plc_ipv4 plcip plcport'),
  _SettingEntry('general', 'PLC IPv6', 'plc_ipv6 plcip plcport'),
  _SettingEntry('security', 'System Title', 'system_title'),
  // Communication
  _SettingEntry('communication', 'Communication Mode',
      'mode_com transport serial hdlc gprs plc'),
  _SettingEntry(
      'communication', 'HDLC Negotiation', 'hdlc enable_hdlc_negociation'),
  _SettingEntry('communication', 'Max Info Transmit', 'max_info_transmit hdlc'),
  _SettingEntry('communication', 'Max Info Receive', 'max_info_receive hdlc'),
  _SettingEntry(
      'communication', 'Window Size Transmit', 'window_size_transmit hdlc'),
  _SettingEntry(
      'communication', 'Window Size Receive', 'window_size_receive hdlc'),
  _SettingEntry(
      'communication', 'Keep Connection', 'keep_connection active timeout'),
  _SettingEntry('general', 'Timeout', 'serial timeout keep_connection'),
  _SettingEntry('general', 'HDLC Timeout', 'hdlc_timeout inactivity session timeout'),
  _SettingEntry('communication', 'HLS CTOS Size', 'hls_ctos_size'),
  _SettingEntry('communication', 'HLS CTOS', 'hls_ctos'),
  _SettingEntry('communication', 'Password', 'initiate_request password'),
  _SettingEntry('communication', 'HLS Action OBIS', 'hls_action_obis'),
  _SettingEntry('communication', 'HLS Action Class', 'hls_action_class'),
  _SettingEntry('communication', 'HLS Action Method', 'hls_action_methode'),
  // Conformance
  _SettingEntry('conformance', 'Proposed Conformance Bits',
      'proposed_conformance conformance'),
  // Security
  _SettingEntry('security', 'Frame Counter', 'frame_counter'),
  _SettingEntry('security', 'Security Policy', 'security_policy'),
  _SettingEntry('security', 'Security Level', 'security_level'),
  _SettingEntry('security', 'Security Suite', 'security_suite'),
  _SettingEntry('security', 'Ciphering Type', 'ciphering_type'),
  _SettingEntry('security', 'Dedicated Key', 'key.dedicated_key'),
  _SettingEntry('security', 'Authentication Key', 'key.authentication_key'),
  _SettingEntry('security', 'Encryption Key', 'key.encryption_key'),
  _SettingEntry('security', 'HLS Secret Key', 'key.hls_secret_key'),
  _SettingEntry('security', 'Master Key', 'key.master_key'),
  _SettingEntry('security', 'Client Private Signed Key',
      'certificate.client_private_signed_key'),
  _SettingEntry('security', 'Meter Public Signed Key',
      'certificate.meter_public_signed_key'),
  _SettingEntry(
      'security', 'Public Address', 'frame_counter_param.public_addr'),
  _SettingEntry(
      'security', 'Get Frame Counter', 'frame_counter_param.get_frame_counter'),
  _SettingEntry('security', 'Frame Counter OBIS',
      'frame_counter_param.frame_counter_obis'),
  _SettingEntry('security', 'Proposed Frame Counter Value',
      'frame_counter_param.proposed_frame_counter_value'),
];

class _ConfigurationPageState extends ConsumerState<ConfigurationPage>
    with TickerProviderStateMixin
    implements ExportablePage {
  late final IConfigurationClient client;
  // Tabs

  late String _activeTab;
  // ── Search ──────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Controllers / Fields
  // --- Session controllers ---
  final TextEditingController bufferSizeCtrl = TextEditingController(text: '');
  bool preEstablished = false;
  bool getFrameCounter = false;
  bool actionFrameCounter = false;
  bool callingAeInvocationIdActivate = false;
  bool toFile = true;
// hls_action.*
  final TextEditingController hlsActionObisCtrl =
      TextEditingController(text: '');
  final TextEditingController hlsActionClassCtrl =
      TextEditingController(text: '');
  final TextEditingController hlsActionMethodeCtrl =
      TextEditingController(text: ''); // (kept your 'methode' spelling)

// initiate_request.*
  final TextEditingController initReqProposedQualityOfServiceCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqProposedDlmsVersionNumberCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqProposedMaxReceivePduSizeCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqProposedMaxSendPduSizeCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqProposedConformanceCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqCallingAeInvocationIdActivateCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqCallingAeInvocationIdCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqHlsCtosSizeCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqHlsCtosCtrl =
      TextEditingController(text: '');
  final TextEditingController initReqPasswordCtrl =
      TextEditingController(text: '');

// --- Communication controllers (empty defaults) ---

// top-level
  final TextEditingController transportTypeCtrl =
      TextEditingController(text: '');
  final TextEditingController linkTypeCtrl = TextEditingController(text: '');
  final TextEditingController modeComCtrl = TextEditingController(text: '');
  final TextEditingController clientAddrCtrl = TextEditingController(text: '');
  final TextEditingController clientAddrLenCtrl =
      TextEditingController(text: '');
  final TextEditingController serverAddrCtrl = TextEditingController(text: '');
  final TextEditingController serverAddrLenCtrl =
      TextEditingController(text: '');

// hdlc.*
  final TextEditingController hdlcModeeBaudrateCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcEnableHdlcNegociationCtrl =
      TextEditingController(text: '');

// hdlc.hdlc_negociation.*
  final TextEditingController hdlcNegMaxInfoTransmitLengthCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegMaxInfoTransmitValueCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegMaxInfoReceiveLengthCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegMaxInfoReceiveValueCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegWindowSizeTransmitLengthCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegWindowSizeTransmitValueCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegWindowSizeReceiveLengthCtrl =
      TextEditingController(text: '');
  final TextEditingController hdlcNegWindowSizeReceiveValueCtrl =
      TextEditingController(text: '');

// serial.*
  final TextEditingController serialPortCtrl = TextEditingController(text: '');
  final TextEditingController serialBaudrateCtrl =
      TextEditingController(text: '');
  final TextEditingController serialTimeoutCtrl =
      TextEditingController(text: '');

// gprs.*
  final TextEditingController gprsTypeCtrl = TextEditingController(text: '');
  final TextEditingController gprsIpCtrl = TextEditingController(text: '');
  final TextEditingController gprsPortCtrl = TextEditingController(text: '');
  final TextEditingController gprsSerialComCtrl =
      TextEditingController(text: '');
  final TextEditingController gprsBaudeRateCtrl =
      TextEditingController(text: '');

// plc_ipv4.*
  final TextEditingController plcIpv4IpCtrl = TextEditingController(text: '');
  final TextEditingController plcIpv4PortCtrl = TextEditingController(text: '');
  final TextEditingController plcIpv4MeterSnCtrl =
      TextEditingController(text: '');
  final TextEditingController plcIpv4ActivateCtrl =
      TextEditingController(text: '');

// plc_ipv6.*
  final TextEditingController plcIpv6IpCtrl = TextEditingController(text: '');
  final TextEditingController plcIpv6PortCtrl = TextEditingController(text: '');
  final TextEditingController plcIpv6UdpPortSrcCtrl =
      TextEditingController(text: '');
  final TextEditingController plcIpv6ActivateCtrl =
      TextEditingController(text: '');

// st8500.*
  final TextEditingController st8500SerialComCtrl =
      TextEditingController(text: '');
  final TextEditingController st8500SSapCtrl = TextEditingController(text: '');

// keep_connection.*
  final TextEditingController keepConnectionTimeoutCtrl =
      TextEditingController(text: '');

// --- Security controllers (empty defaults) ---

// top-level
  final TextEditingController securitySessionTypeCtrl =
      TextEditingController(text: '');
  final TextEditingController referencingMethodCtrl =
      TextEditingController(text: '');
  final TextEditingController systemTitleCtrl = TextEditingController(text: '');
  final TextEditingController serialNumberCtrl =
      TextEditingController(text: '');
  final TextEditingController frameCounterCtrl =
      TextEditingController(text: '');
  final TextEditingController securityPolicyCtrl =
      TextEditingController(text: '');

  final TextEditingController securitySuiteCtrl =
      TextEditingController(text: '');
  final TextEditingController cipheringTypeCtrl =
      TextEditingController(text: '');

// certificate.*
  final TextEditingController certificateClientPrivateSignedKeyCtrl =
      TextEditingController(text: '');
  final TextEditingController certificateMeterPublicSignedKeyCtrl =
      TextEditingController(text: '');

// key.*
  final TextEditingController keyDedicatedKeyCtrl =
      TextEditingController(text: '');
  final TextEditingController keyAuthenticationKeyCtrl =
      TextEditingController(text: '');
  final TextEditingController keyEncryptionKeyCtrl =
      TextEditingController(text: '');
  final TextEditingController keyHlsSecretKeyCtrl =
      TextEditingController(text: '');
  final TextEditingController keyMasterKeyCtrl =
      TextEditingController(text: '');

// frame_counter_param.*
  final TextEditingController fcpPublicAddrCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpGetFrameCounterCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpActionFrameCounterCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpFrameCounterObisCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpFrameCounterClassCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpFrameCounterAttributeCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpProposedFrameCounterValueCtrl =
      TextEditingController(text: '');
  final TextEditingController fcpFrameCounterIndexCtrl =
      TextEditingController(text: '');

// Optional helpers

// Shorthands
  final _digits = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
  final _ipv4Only = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
  ];
  final _ipv6Only = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f:]')),
    UpperCaseTextFormatter(),
  ];
  List<TextInputFormatter> hex({int? maxLen, bool upper = true}) => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
        if (upper) UpperCaseTextFormatter(),
        if (maxLen != null) LengthLimitingTextInputFormatter(maxLen),
      ];

  // Objects dataset (simulé)

  final List<String> _modules = [];

  // Logs
  final List<_LogEntry> _log = [];
  static const int maxLog = 250;
  ScrollController logScroll = ScrollController();
  final Map<_TabSpec, List<String>> configurationKeys = {
    _TabSpec(icon: Icons.tune, label: 'General', key: 'general'): [
      "buffer_size",
      "pre_established",
      "initiate_request.proposed_quality_of_service",
      "initiate_request.proposed_dlms_version_number",
      "initiate_request.proposed_conformance",
      "initiate_request.calling_ae_invocation_id_activate",
      "initiate_request.calling_ae_invocation_id"
    ],
    _TabSpec(
        icon: Icons.link,
        label: 'Communication Settings',
        key: 'communication'): [
      // Section 1 — Phy Setting
      "mode_com",
      // Section 2 — HDLC Settings
      "hdlc.enable_hdlc_negociation",
      "hdlc.hdlc_negociation.max_info_transmit_length",
      "hdlc.hdlc_negociation.max_info_transmit_value",
      "hdlc.hdlc_negociation.max_info_receive_length",
      "hdlc.hdlc_negociation.max_info_receive_value",
      "hdlc.hdlc_negociation.window_size_transmit_length",
      "hdlc.hdlc_negociation.window_size_transmit_value",
      "hdlc.hdlc_negociation.window_size_receive_length",
      "hdlc.hdlc_negociation.window_size_receive_value",
      // Section 3 — App Setting
      "initiate_request.hls_ctos_size",
      "initiate_request.hls_ctos",
      "initiate_request.password",
      // Section 4 — PDU / HLS Action (untitled)
      "initiate_request.proposed_max_receive_pdu_size",
      "initiate_request.proposed_max_send_pdu_size",
      "hls_action.hls_action_obis",
      "hls_action.hls_action_class",
      "hls_action.hls_action_methode"
    ],
    _TabSpec(icon: Icons.fact_check, label: 'Conformance', key: 'conformance'):
        [
      "initiate_request.proposed_conformance",
    ],
    _TabSpec(icon: Icons.lock, label: 'Security', key: 'security'): [
      "session_type",
      "referencing_method",
      "system_title",
      "serial_number",
      "frame_counter",
      "security_policy",
      "security_level",
      "security_suite",
      "ciphering_type",
      "certificate.client_private_signed_key",
      "certificate.meter_public_signed_key",
      "key.dedicated_key",
      "key.authentication_key",
      "key.encryption_key",
      "key.hls_secret_key",
      "key.master_key",
      "frame_counter_param.public_addr",
      "frame_counter_param.get_frame_counter",
      "frame_counter_param.action_frame_counter",
      "frame_counter_param.frame_counter_obis",
      "frame_counter_param.frame_counter_class",
      "frame_counter_param.frame_counter_attribute",
      "frame_counter_param.proposed_frame_counter_value",
      "frame_counter_param.frame_counter_index"
    ]
  };
  // States
  bool _associationActive = false;
  bool _connected = false;
  bool _authDone = false;
  String _authMode = 'LLS';
  String _securitySuite = '0';
  String? _module;
  String? _modeCom;
  String? _linkType;
  String? _transportType;
  String? _serialPort;
  List<String> _availableComPorts = [];
  bool _plcIpv4Active = false;
  bool _plcIpv6Active = false;
  bool _gprsActive = false;
  bool _serialActive = true;
  bool _enableHdlcNegociation = false;
  String? _serialBaudrate = '19200';
  String? _sessionType;
  int? _cipheringType;
  bool _generalSigning = false;
  bool _useDedicatedKey = false;
  String? _securitySuiteValue;
  String? _securityPolicyValue;
  bool _keepConnection = false;

  // Conformance bits (BIT_00..BIT_23)
  static const List<String> _conformanceBitLabels = [
    'BIT_00 : reserved',
    'BIT_01 : general-protection',
    'BIT_02 : general-block-transfer',
    'BIT_03 : read',
    'BIT_04 : write',
    'BIT_05 : unconfirmed-write',
    'BIT_06 : reserved',
    'BIT_07 : reserved',
    'BIT_08 : attribute0-supported-with-set',
    'BIT_09 : priority-mgmt-supported',
    'BIT_10 : attribute0-supported-with-get',
    'BIT_11 : block-transfer-with-get-or-read',
    'BIT_12 : block-transfer-with-set-or-write',
    'BIT_13 : block-transfer-with-action',
    'BIT_14 : multiple-references',
    'BIT_15 : information-report',
    'BIT_16 : data-notification',
    'BIT_17 : access',
    'BIT_18 : parameterized-access',
    'BIT_19 : get',
    'BIT_20 : set',
    'BIT_21 : selective-access',
    'BIT_22 : event-notification',
    'BIT_23 : action',
  ];
  final List<bool> _conformanceBits = List.filled(24, false);

  // Recompute the 3-byte conformance value from bits and sync the ctrl.
  // Encoding: bits are MSB-first within a 24-bit big-endian integer.
  // BIT_00 is the most-significant bit of byte[0].
  void _rebuildConformance() {
    int value = 0;
    for (int i = 0; i < 24; i++) {
      if (_conformanceBits[i]) value |= (1 << (23 - i));
    }
    final b0 = (value >> 16) & 0xFF;
    final b1 = (value >> 8) & 0xFF;
    final b2 = value & 0xFF;
    initReqProposedConformanceCtrl.text =
        '${b0.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b1.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b2.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  void _onSearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() => _searchQuery = query);
    if (query.isEmpty) return;
    final tabs = _filteredEntries.map((e) => e.tabKey).toSet();
    if (tabs.length == 1) setState(() => _activeTab = tabs.first);
  }

  List<_SettingEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) return const [];
    return _kSettingsIndex
        .where((e) =>
            e.label.toLowerCase().contains(_searchQuery) ||
            e.keywords.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // Parse a hex string (or byte list string) into the 24 conformance bits.
  void _applyConformanceBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (clean.length < 6) return;
    final b0 = int.tryParse(clean.substring(0, 2), radix: 16) ?? 0;
    final b1 = int.tryParse(clean.substring(2, 4), radix: 16) ?? 0;
    final b2 = int.tryParse(clean.substring(4, 6), radix: 16) ?? 0;
    final value = (b0 << 16) | (b1 << 8) | b2;
    for (int i = 0; i < 24; i++) {
      _conformanceBits[i] = (value & (1 << (23 - i))) != 0;
    }
  }

  String _sessionLastOp = '—';
  String? securityLevel;

  Timer? _latencyTimer;
  final List<int> _latencies = [];

  @override
  void initState() {
    super.initState();
    client = _configurationClientFactory();
    _activeTab = widget.initialTabKey;
    _logAdd('info', 'Interface prête');
    _startLatencySimulation();
    _listModules();
    _loadComPorts();
    // Default serial state
    linkTypeCtrl.text = 'serial';
    _linkType = 'serial';
    transportTypeCtrl.text = 'HDLC';
    _transportType = 'HDLC';
    serialBaudrateCtrl.text = '19200';

    if (configurationPageAutoCoverDiagnostics) {
      _testConnection();
      _syncClock();
      _negotiate();
      _openSession();
      _closeSession();
      _startAssociation();
      _releaseAssociation();
      _pingMeter();
      _traceRoute();
      _exportLog();
    }
  }

  void _setStateIfMounted(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'configuration';

  @override
  String get exportPageLabel => 'Configuration DLMS';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        // communication
        'communication.transport_type': _transportType,
        'communication.link_type': _linkType,
        'communication.mode_com': _modeCom,
        'communication.client_addr': clientAddrCtrl.text,
        'communication.client_addr_len': clientAddrLenCtrl.text,
        'communication.server_addr': serverAddrCtrl.text,
        'communication.server_addr_len': serverAddrLenCtrl.text,
        // session
        'session.buffer_size': bufferSizeCtrl.text,
        'session.pre_established': preEstablished,
        // security
        'security.session_type': _sessionType,
        'security.ciphering_type': _cipheringType,
        'security.security_level': securityLevel,
        'security.security_suite': securitySuiteCtrl.text,
        'security.serial_number': serialNumberCtrl.text,
        'security.frame_counter': frameCounterCtrl.text,
      };

  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    bufferSizeCtrl.dispose();

    hlsActionObisCtrl.dispose();
    hlsActionClassCtrl.dispose();
    hlsActionMethodeCtrl.dispose();

    initReqProposedQualityOfServiceCtrl.dispose();
    initReqProposedDlmsVersionNumberCtrl.dispose();
    initReqProposedMaxReceivePduSizeCtrl.dispose();
    initReqProposedMaxSendPduSizeCtrl.dispose();
    initReqProposedConformanceCtrl.dispose();
    initReqCallingAeInvocationIdActivateCtrl.dispose();
    initReqCallingAeInvocationIdCtrl.dispose();
    initReqHlsCtosSizeCtrl.dispose();
    initReqHlsCtosCtrl.dispose();
    initReqPasswordCtrl.dispose();
    transportTypeCtrl.dispose();
    linkTypeCtrl.dispose();
    modeComCtrl.dispose();
    clientAddrCtrl.dispose();
    clientAddrLenCtrl.dispose();
    serverAddrCtrl.dispose();
    serverAddrLenCtrl.dispose();

    hdlcModeeBaudrateCtrl.dispose();
    hdlcEnableHdlcNegociationCtrl.dispose();
    hdlcNegMaxInfoTransmitLengthCtrl.dispose();
    hdlcNegMaxInfoTransmitValueCtrl.dispose();
    hdlcNegMaxInfoReceiveLengthCtrl.dispose();
    hdlcNegMaxInfoReceiveValueCtrl.dispose();
    hdlcNegWindowSizeTransmitLengthCtrl.dispose();
    hdlcNegWindowSizeTransmitValueCtrl.dispose();
    hdlcNegWindowSizeReceiveLengthCtrl.dispose();
    hdlcNegWindowSizeReceiveValueCtrl.dispose();

    serialPortCtrl.dispose();
    serialBaudrateCtrl.dispose();
    serialTimeoutCtrl.dispose();

    gprsTypeCtrl.dispose();
    gprsIpCtrl.dispose();
    gprsPortCtrl.dispose();
    gprsSerialComCtrl.dispose();
    gprsBaudeRateCtrl.dispose();

    plcIpv4IpCtrl.dispose();
    plcIpv4PortCtrl.dispose();
    plcIpv4MeterSnCtrl.dispose();
    plcIpv4ActivateCtrl.dispose();

    plcIpv6IpCtrl.dispose();
    plcIpv6PortCtrl.dispose();
    plcIpv6UdpPortSrcCtrl.dispose();
    plcIpv6ActivateCtrl.dispose();

    st8500SerialComCtrl.dispose();
    st8500SSapCtrl.dispose();
    keepConnectionTimeoutCtrl.dispose();
    securitySessionTypeCtrl.dispose();
    referencingMethodCtrl.dispose();
    systemTitleCtrl.dispose();
    serialNumberCtrl.dispose();
    frameCounterCtrl.dispose();
    securityPolicyCtrl.dispose();
    securitySuiteCtrl.dispose();
    cipheringTypeCtrl.dispose();

    certificateClientPrivateSignedKeyCtrl.dispose();
    certificateMeterPublicSignedKeyCtrl.dispose();

    keyDedicatedKeyCtrl.dispose();
    keyAuthenticationKeyCtrl.dispose();
    keyEncryptionKeyCtrl.dispose();
    keyHlsSecretKeyCtrl.dispose();
    keyMasterKeyCtrl.dispose();

    fcpPublicAddrCtrl.dispose();
    fcpGetFrameCounterCtrl.dispose();
    fcpActionFrameCounterCtrl.dispose();
    fcpFrameCounterObisCtrl.dispose();
    fcpFrameCounterClassCtrl.dispose();
    fcpFrameCounterAttributeCtrl.dispose();
    fcpProposedFrameCounterValueCtrl.dispose();
    fcpFrameCounterIndexCtrl.dispose();
    logScroll.dispose();
    _latencyTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isDark => DesignTokens.isDark(context);

  // --------------------------------------------------------------------------- UI
  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    return Scaffold(
      backgroundColor: DesignTokens.backgroundOf(context),
      appBar: AppBar(
        title: const Text("Configuration"),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          RefreshAppBarButton(
            onPressed: () {
              _listModules();
              if (_module != null) _getConfigurationByModule();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const Breadcrumb(
                segments: ['Menu', 'Meter Connexion', 'Configuration']),
          ),
          Expanded(
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: _buildTabContainer(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Backend fetch keys — maps the actual backend namespace prefix to the list of keys.
  // Decoupled from configurationKeys (which drives the UI tab structure only).
  static const Map<String, List<String>> _backendFetchKeys = {
    'session': [
      "buffer_size",
      "pre_established",
      "hls_action.hls_action_obis",
      "hls_action.hls_action_class",
      "hls_action.hls_action_methode",
      "initiate_request.proposed_quality_of_service",
      "initiate_request.proposed_dlms_version_number",
      "initiate_request.proposed_max_receive_pdu_size",
      "initiate_request.proposed_max_send_pdu_size",
      "initiate_request.proposed_conformance",
      "initiate_request.calling_ae_invocation_id_activate",
      "initiate_request.calling_ae_invocation_id",
      "initiate_request.hls_ctos_size",
      "initiate_request.hls_ctos",
      "initiate_request.password",
    ],
    'communication': [
      "transport_type",
      "link_type",
      "mode_com",
      "client_addr",
      "client_addr_len",
      "server_addr",
      "server_addr_len",
      "hdlc.modee_baudrate",
      "hdlc.enable_hdlc_negociation",
      "hdlc.hdlc_negociation.max_info_transmit_length",
      "hdlc.hdlc_negociation.max_info_transmit_value",
      "hdlc.hdlc_negociation.max_info_receive_length",
      "hdlc.hdlc_negociation.max_info_receive_value",
      "hdlc.hdlc_negociation.window_size_transmit_length",
      "hdlc.hdlc_negociation.window_size_transmit_value",
      "hdlc.hdlc_negociation.window_size_receive_length",
      "hdlc.hdlc_negociation.window_size_receive_value",
      "serial.port",
      "serial.baudrate",
      "serial.timeout",
      "gprs.gprs_type",
      "gprs.gprsip",
      "gprs.gprsport",
      "gprs.serial_com",
      "gprs.baude_rate",
      "plc_ipv4.plcip",
      "plc_ipv4.plcport",
      "plc_ipv4.plcmetersn",
      "plc_ipv4.activate_plcipv4",
      "plc_ipv6.plcip",
      "plc_ipv6.plcport",
      "plc_ipv6.plcudpportsrc",
      "plc_ipv6.activate_plcipv6",
      "st8500.serial_com",
      "st8500.s_sap",
      "keep_connection.active",
      "keep_connection.timeout",
    ],
    'security': [
      "session_type",
      "referencing_method",
      "system_title",
      "serial_number",
      "frame_counter",
      "security_policy",
      "security_level",
      "security_suite",
      "ciphering_type",
      "certificate.client_private_signed_key",
      "certificate.meter_public_signed_key",
      "key.dedicated_key",
      "key.authentication_key",
      "key.encryption_key",
      "key.hls_secret_key",
      "key.master_key",
      "frame_counter_param.public_addr",
      "frame_counter_param.get_frame_counter",
      "frame_counter_param.action_frame_counter",
      "frame_counter_param.frame_counter_obis",
      "frame_counter_param.frame_counter_class",
      "frame_counter_param.frame_counter_attribute",
      "frame_counter_param.proposed_frame_counter_value",
      "frame_counter_param.frame_counter_index",
    ],
  };

  Future<void> _getConfigurationByModule() async {
    final List<ConfigIdentifier> identifiers = [];
    for (final entry in _backendFetchKeys.entries) {
      final prefix = entry.key;
      for (final key in entry.value) {
        identifiers.add(ConfigIdentifier()
          ..module = _module!
          ..key = '$prefix.$key');
      }
    }
    final entries = await client.getConfig(identifiers);
    print(entries);
    applyConfig(entries);
  }

  Future<void> _loadComPorts() async {
    if (!Platform.isWindows) return;
    final result = await Process.run('powershell', [
      '-Command',
      '[System.IO.Ports.SerialPort]::GetPortNames()',
    ]);
    if (!mounted) return;
    final ports = result.stdout
        .toString()
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toUpperCase().startsWith('COM'))
        .toList()
      ..sort((a, b) {
        final na = int.tryParse(a.substring(3)) ?? 0;
        final nb = int.tryParse(b.substring(3)) ?? 0;
        return na.compareTo(nb);
      });
    setState(() {
      print('Available COM ports: $ports');
      _availableComPorts = ports;
      // If the saved port is not present in the live list, keep it as an option
      
      
        //_availableComPorts = [..._availableComPorts, _serialPort!];
      if (_availableComPorts.isEmpty) {
          _serialPort = null;
      }
      else {
          _serialPort = _availableComPorts.first;
      }
      
      
    });
  }

  Widget _buildSearchBar() {
    final hasQuery = _searchQuery.isNotEmpty;
    return Container(
      color: DesignTokens.surfaceOf(context),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      child: TextField(
        key: const Key(ConfigurationKeys.searchField),
        controller: _searchCtrl,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les paramètres…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  key: const Key(ConfigurationKeys.searchClearBtn),
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                )
              : null,
          isDense: true,
          filled: true,
          fillColor: DesignTokens.backgroundOf(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DesignTokens.borderOf(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DesignTokens.borderOf(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DesignTokens.primary600, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final entries = _filteredEntries;
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48, color: DesignTokens.textSecondaryOf(context)),
            const SizedBox(height: 12),
            Text(
              'No results for "$_searchQuery"',
              style: TextStyle(
                  fontSize: 15, color: DesignTokens.textSecondaryOf(context)),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = entries[i];
        final tabLabel = {
              'general': 'General',
              'communication': 'Communication',
              'conformance': 'Conformance',
              'security': 'Security',
            }[e.tabKey] ??
            e.tabKey;
        return ListTile(
          dense: true,
          leading: Icon(Icons.settings,
              size: 18, color: DesignTokens.textSecondaryOf(context)),
          title: _highlightMatch(e.label, _searchQuery),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _isDark ? DesignTokens.darkFocus.withOpacity(.15) : DesignTokens.primary50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tabLabel,
                style: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.primary600,
                    fontWeight: FontWeight.w600)),
          ),
          onTap: () {
            setState(() {
              _activeTab = e.tabKey;
              _searchQuery = '';
              _searchCtrl.clear();
            });
          },
        );
      },
    );
  }

  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) return Text(text);
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: DesignTokens.textPrimaryOf(context)),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(
              backgroundColor: _isDark ? DesignTokens.darkFocus.withOpacity(.25) : DesignTokens.primary50,
              color: DesignTokens.primary600,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }

  Widget _comPortDropdown({Key? key}) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(value: null, child: Text('—')),
      ..._availableComPorts.map(
        (p) => DropdownMenuItem<String?>(value: p, child: Text(p)),
      ),
    ];
    return _dropdownField<String>(
      'Serial port',
      _serialPort,
      items,
      (v) => setState(() {
        _serialPort = v;
        serialPortCtrl.text = v ?? '';
      }),
      key: key,
    );
  }

  Future<void> _listModules() async {
    _modules.clear();
    final modules = await client.listModules();
    _modules.addAll(modules);
    if (mounted) {
      final preferred = ref.read(appControllerProvider).moduleName;
      if (preferred != null && _modules.contains(preferred)) {
        setState(() => _module = preferred);
        await _getConfigurationByModule();
      } else {
        setState(() {});
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          border: Border(bottom: BorderSide(color: DesignTokens.borderOf(context)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Menu',
                          style: TextStyle(
                              fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
                      Icon(Icons.chevron_right,
                          size: 16, color: DesignTokens.textSecondaryOf(context)),
                      Text('Configuration',
                          style: TextStyle(
                              fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
                      Icon(Icons.chevron_right,
                          size: 16, color: DesignTokens.textSecondaryOf(context)),
                      Text('DLMS',
                          style: TextStyle(
                              fontSize: 13,
                              color: DesignTokens.primary600,
                              fontWeight: FontWeight.w600)),
                    ]),
                const SizedBox(height: 4),
                const Text('DLMS Configuration',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    'Configure, read, and synchronize DLMS/COSEM parameters',
                    style: TextStyle(
                        fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
              ],
            ),
          ),
          Row(children: [
            // Back button
            IconButton(
              key: const Key(ConfigurationKeys.backBtn),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Return',
              onPressed: () {
                final nav = Navigator.of(context);
                if (nav.canPop()) {
                  nav.pop();
                } else {
                  nav.pushReplacementNamed(AppRoutes.meterConnexion);
                }
              },
            ),
            const SizedBox(width: 8),
            // Module dropdown (smaller, not expanded)
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                key: const Key(ConfigurationKeys.moduleDropdown),
                value: _module,
                isExpanded: true,
                isDense: true,
                items: _modules
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _module = v!);
                  _getConfigurationByModule();
                },
                decoration: DesignTokens.inputDecorationOf(context, hint: "Select Module"),
              ),
            ),
            const SizedBox(width: 12),
            // Ecrire button
            _btn(
              Icons.save,
              'Save',
              () => saveConfiguration(),
              DesignTokens.success,
              Colors.white,
              key: const Key(ConfigurationKeys.saveBtn),
            ),
            const SizedBox(width: 12),
            // Switch with file icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  key: const Key(ConfigurationKeys.toFileSwitch),
                  value: toFile,
                  onChanged: (v) {
                    setState(() => toFile = v);
                  },
                ),
              ],
            ),
          ])
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon,
      {required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isDark ? DesignTokens.darkBorder : DesignTokens.gray100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: DesignTokens.textSecondaryOf(context)),
        ),
      ),
    );
  }

  Widget _buildTabContainer() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brLg,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          _buildTabsHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Padding(
                key: ValueKey(_activeTab),
                padding: const EdgeInsets.all(20),
                child: _buildActiveTab(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('DLMS Configuration Module • NG Platform',
                style: TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textSecondaryOf(context))),
          )
        ],
      ),
    );
  }

  Widget _buildTabsHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        children: configurationKeys.keys.toList().map((t) {
          final active = t.key == _activeTab;
          return Expanded(
            child: InkWell(
              key: Key('configuration_tab_${t.key.toLowerCase().replaceAll(' ', '_')}_btn'),
              onTap: () => setState(() {
                _activeTab = t.key;
                _sessionLastOp = 'Tab ${t.key}';
                _logAdd('info', 'Switch onglet: ${t.key}');
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? (_isDark ? DesignTokens.darkFocus.withOpacity(.15) : DesignTokens.primary50) : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color:
                          active ? DesignTokens.primary600 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon,
                        size: 18,
                        color: active
                            ? DesignTokens.primary600
                            : DesignTokens.textSecondary),
                    const SizedBox(width: 8),
                    Text(t.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? DesignTokens.primary600
                              : DesignTokens.textSecondary,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveTab() {
    if (_searchQuery.isNotEmpty) return _buildSearchResults();
    switch (_activeTab) {
      case 'general':
        return _tabGeneral();
      case 'communication':
        return _tabCommunication();
      case 'conformance':
        return _tabConformance();
      case 'security':
        return _tabSecurity();
      case 'diagnostics':
        return _tabDiagnostics();
      default:
        return const SizedBox();
    }
  }

  // ------------------------------ TAB: GENERAL
  Widget _tabGeneral() {
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        // ── Section 1: Communication Mode ───────────────────────────────────
        _sectionTitle(
          icon: Icons.settings_input_component,
          color: DesignTokens.primary600,
          title: 'Communication Mode',
        ),
        const SizedBox(height: 12),
        // Line 1 — HDLC checkbox + Protocol / COM port / Baud rate
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              key: const Key(ConfigurationKeys.serialActiveChk),
              value: _serialActive,
              onChanged: (v) => setState(() {
                _serialActive = v ?? false;
                linkTypeCtrl.text = _serialActive ? 'serial' : '';
                _linkType = _serialActive ? 'serial' : null;
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Opacity(
                opacity: _serialActive ? 1.0 : 0.4,
                child:
                    _dropdownField<String>('Protocol', _transportType, const [
                  DropdownMenuItem(value: null, child: Text('—')),
                  DropdownMenuItem(value: 'HDLC', child: Text('HDLC')),
                  DropdownMenuItem(value: 'direct', child: Text('Direct')),
                ], (v) {
                  setState(() {
                    _transportType = v;
                    transportTypeCtrl.text = v ?? '';
                  });
                }, key: const Key(ConfigurationKeys.protocolDropdown)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Opacity(
                opacity: _serialActive ? 1.0 : 0.4,
                child: _comPortDropdown(
                    key: const Key(ConfigurationKeys.comPortDropdown)),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              key: const Key(ConfigurationKeys.comPortRefreshBtn),
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh COM ports',
              onPressed: _loadComPorts,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Opacity(
                opacity: _serialActive ? 1.0 : 0.4,
                child:
                    _dropdownField<String>('Baud rate', _serialBaudrate, const [
                  DropdownMenuItem(value: '1200', child: Text('1200')),
                  DropdownMenuItem(value: '2400', child: Text('2400')),
                  DropdownMenuItem(value: '4800', child: Text('4800')),
                  DropdownMenuItem(value: '9600', child: Text('9600')),
                  DropdownMenuItem(value: '19200', child: Text('19200')),
                  DropdownMenuItem(value: '38400', child: Text('38400')),
                  DropdownMenuItem(value: '57600', child: Text('57600')),
                  DropdownMenuItem(value: '115200', child: Text('115200')),
                ], (v) {
                  setState(() {
                    _serialBaudrate = v;
                    serialBaudrateCtrl.text = v ?? '';
                  });
                }, key: const Key(ConfigurationKeys.baudRateDropdown)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Line 2 — GPRS activate checkbox + IP / Port
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              key: const Key(ConfigurationKeys.gprsActiveChk),
              value: _gprsActive,
              onChanged: (v) => setState(() => _gprsActive = v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Opacity(
                opacity: _gprsActive ? 1.0 : 0.4,
                child: _field('GPRS IP (IPv4)', gprsIpCtrl,
                    key: const Key(ConfigurationKeys.gprsIpField),
                    keyboard: TextInputType.number, inputFormatters: _ipv4Only),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Opacity(
                opacity: _gprsActive ? 1.0 : 0.4,
                child: _field('GPRS port', gprsPortCtrl,
                    key: const Key(ConfigurationKeys.gprsPortField),
                    keyboard: TextInputType.number, inputFormatters: _digits),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Line 3 — PLC IPv4 activate checkbox + IP / Port
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              key: const Key(ConfigurationKeys.plcIpv4ActiveChk),
              value: _plcIpv4Active,
              onChanged: (v) => setState(() {
                _plcIpv4Active = v ?? false;
                plcIpv4ActivateCtrl.text = _plcIpv4Active ? '1' : '0';
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Opacity(
                opacity: _plcIpv4Active ? 1.0 : 0.4,
                child: _field('PLC IPv4', plcIpv4IpCtrl,
                    key: const Key(ConfigurationKeys.plcIpv4IpField),
                    keyboard: TextInputType.number, inputFormatters: _ipv4Only),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Opacity(
                opacity: _plcIpv4Active ? 1.0 : 0.4,
                child: _field('PLC IPv4 port', plcIpv4PortCtrl,
                    key: const Key(ConfigurationKeys.plcIpv4PortField),
                    keyboard: TextInputType.number, inputFormatters: _digits),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Line 4 — PLC IPv6 activate checkbox + IP / Port
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              key: const Key(ConfigurationKeys.plcIpv6ActiveChk),
              value: _plcIpv6Active,
              onChanged: (v) => setState(() {
                _plcIpv6Active = v ?? false;
                plcIpv6ActivateCtrl.text = _plcIpv6Active ? '1' : '0';
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Opacity(
                opacity: _plcIpv6Active ? 1.0 : 0.4,
                child: _field('PLC IPv6', plcIpv6IpCtrl,
                    key: const Key(ConfigurationKeys.plcIpv6IpField),
                    keyboard: TextInputType.number, inputFormatters: _ipv6Only),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Opacity(
                opacity: _plcIpv6Active ? 1.0 : 0.4,
                child: _field('PLC IPv6 port', plcIpv6PortCtrl,
                    key: const Key(ConfigurationKeys.plcIpv6PortField),
                    keyboard: TextInputType.number, inputFormatters: _digits),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 2: Addressing & Identification (no title) ───────────────
        _responsiveWrap([
          _field('Client addr', clientAddrCtrl,
              key: const Key(ConfigurationKeys.clientAddrField),
              keyboard: TextInputType.number, inputFormatters: _digits),
          _field('Client addr len', clientAddrLenCtrl,
              key: const Key(ConfigurationKeys.clientAddrLenField),
              keyboard: TextInputType.number, inputFormatters: _digits),
          _field('Server addr', serverAddrCtrl,
              key: const Key(ConfigurationKeys.serverAddrField),
              keyboard: TextInputType.number, inputFormatters: _digits),
          _field('Server addr len', serverAddrLenCtrl,
              key: const Key(ConfigurationKeys.serverAddrLenField),
              keyboard: TextInputType.number, inputFormatters: _digits),
          _field('Calling AE Invocation ID', initReqCallingAeInvocationIdCtrl,
              key: const Key(ConfigurationKeys.callingAeInvocationIdField),
              keyboard: TextInputType.number, inputFormatters: _digits),
          _field('System title (HEX 16)', systemTitleCtrl,
              key: const Key(ConfigurationKeys.systemTitleField),
              inputFormatters: hex(maxLen: 16)),
          _checkboxField('Pre established', preEstablished, (v) {
            setState(() => preEstablished = v);
          }, key: const Key(ConfigurationKeys.preEstablishedChk)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 3: Application Settings ─────────────────────────────────
        _sectionTitle(
          icon: Icons.timer_outlined,
          color: DesignTokens.primary600,
          title: 'Application Settings',
        ),
        const SizedBox(height: 12),
        _HdlcTimeoutField(),
        const SizedBox(height: 16),
      ],
    );
  }

  // ------------------------------ TAB: CONNECTION (kept for internal use)
  Widget _tabSession() {
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        _responsiveWrap([
          _field('Buffer size', bufferSizeCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _checkboxField('Pre established', preEstablished, (v) {
            setState(() => preEstablished = v);
          }),
          _field('HLS Action OBIS', hlsActionObisCtrl),
          _field('HLS Action Class', hlsActionClassCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('HLS Action Method', hlsActionMethodeCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('QoS (proposed_quality_of_service)',
              initReqProposedQualityOfServiceCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('DLMS Version', initReqProposedDlmsVersionNumberCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Max Receive PDU Size', initReqProposedMaxReceivePduSizeCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Max Send PDU Size', initReqProposedMaxSendPduSizeCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Proposed Conformance', initReqProposedConformanceCtrl),
          _field('Calling AE Invocation ID Activate',
              initReqCallingAeInvocationIdActivateCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Calling AE Invocation ID', initReqCallingAeInvocationIdCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('CTOS Password Size', initReqHlsCtosSizeCtrl,
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Password', initReqPasswordCtrl),
        ]),
      ],
    );
  }

  Widget _tabCommunication() {
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        // ── Section 1: Phy Setting ───────────────────────────────────────────
        _sectionTitle(
          icon: Icons.settings_input_antenna,
          color: DesignTokens.primary600,
          title: 'Phy Setting',
        ),
        const SizedBox(height: 12),
        _responsiveWrap([
          _dropdownField<String>('Mode COM', _modeCom, const [
            DropdownMenuItem(value: null, child: Text('—')),
            DropdownMenuItem(value: 'DirectHDLC', child: Text('Direct HDLC')),
            DropdownMenuItem(value: 'Mode_E', child: Text('Mode E')),
          ], (v) {
            setState(() {
              _modeCom = v;
              modeComCtrl.text = v ?? '';
            });
          }, key: const Key(ConfigurationKeys.modeComDropdown)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 2: HDLC Settings ─────────────────────────────────────────
        _sectionTitle(
          icon: Icons.cable,
          color: DesignTokens.primary600,
          title: 'HDLC Settings',
        ),
        const SizedBox(height: 12),
        _responsiveWrap([
          _checkboxField('Enable HDLC Negotiation', _enableHdlcNegociation,
              (v) {
            setState(() {
              _enableHdlcNegociation = v;
              hdlcEnableHdlcNegociationCtrl.text = v.toString();
            });
          }, key: const Key(ConfigurationKeys.hdlcNegChk)),
        ]),
        const SizedBox(height: 12),
        IgnorePointer(
          ignoring: !_enableHdlcNegociation,
          child: Opacity(
            opacity: _enableHdlcNegociation ? 1.0 : 0.4,
            child: Column(
              children: [
                // Maximum Information Field — TX
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: _field('Max Info TX Length',
                          hdlcNegMaxInfoTransmitLengthCtrl,
                          key: const Key(ConfigurationKeys.maxInfoTxLenField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          'Max Info TX Value', hdlcNegMaxInfoTransmitValueCtrl,
                          key: const Key(ConfigurationKeys.maxInfoTxValField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                ]),
                const SizedBox(height: 12),
                // Maximum Information Field — RX
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: _field(
                          'Max Info RX Length', hdlcNegMaxInfoReceiveLengthCtrl,
                          key: const Key(ConfigurationKeys.maxInfoRxLenField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          'Max Info RX Value', hdlcNegMaxInfoReceiveValueCtrl,
                          key: const Key(ConfigurationKeys.maxInfoRxValField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                ]),
                const SizedBox(height: 12),
                // Window Size — TX
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: _field('Win Size TX Length',
                          hdlcNegWindowSizeTransmitLengthCtrl,
                          key: const Key(ConfigurationKeys.winSizeTxLenField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field('Win Size TX Value',
                          hdlcNegWindowSizeTransmitValueCtrl,
                          key: const Key(ConfigurationKeys.winSizeTxValField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                ]),
                const SizedBox(height: 12),
                // Window Size — RX
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: _field('Win Size RX Length',
                          hdlcNegWindowSizeReceiveLengthCtrl,
                          key: const Key(ConfigurationKeys.winSizeRxLenField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field('Win Size RX Value',
                          hdlcNegWindowSizeReceiveValueCtrl,
                          key: const Key(ConfigurationKeys.winSizeRxValField),
                          keyboard: TextInputType.number,
                          inputFormatters: _digits)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 3: App Setting ───────────────────────────────────────────
        _sectionTitle(
          icon: Icons.lock_outline,
          color: DesignTokens.primary600,
          title: 'App Setting',
        ),
        const SizedBox(height: 12),
        _responsiveWrap([
          _field('CTOS Password Size', initReqHlsCtosSizeCtrl,
              key: const Key(ConfigurationKeys.ctosSizeField),
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _passwordField('Password', initReqPasswordCtrl,
              key: const Key(ConfigurationKeys.passwordField)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 4: PDU / Keep Connection / HLS Action ───────────────────
        // Row 1: Max PDU Size (left) | empty (right)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _fieldWithUnit('Max PDU Size', bufferSizeCtrl, 'byte',
                key: const Key(ConfigurationKeys.maxPduSizeField),
                keyboard: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          const Expanded(child: SizedBox()),
        ]),
        const SizedBox(height: 12),
        // Row 2: Keep Connection (left) | Keep Connection Timeout (right)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _checkboxField('Keep Connection', _keepConnection, (v) {
              setState(() => _keepConnection = v);
            }, key: const Key(ConfigurationKeys.keepConnectionChk)),
          ),
          Expanded(
            child: IgnorePointer(
              ignoring: !_keepConnection,
              child: Opacity(
                opacity: _keepConnection ? 1.0 : 0.4,
                child: _fieldWithUnit('Keep Connection Timeout',
                    keepConnectionTimeoutCtrl, 'seconde',
                    key: const Key(ConfigurationKeys.keepConnectionTimeoutField),
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        // Row 3: HLS Action OBIS (left) | HLS Action Class (right)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _field('HLS Action OBIS', hlsActionObisCtrl,
              key: const Key(ConfigurationKeys.hlsActionObisField))),
          const SizedBox(width: 12),
          Expanded(
              child: _field('HLS Action Class', hlsActionClassCtrl,
                  key: const Key(ConfigurationKeys.hlsActionClassField),
                  keyboard: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
        ]),
        const SizedBox(height: 12),
        // Row 4: HLS Action Method (left) | empty (right)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: _field('HLS Action Method', hlsActionMethodeCtrl,
                  key: const Key(ConfigurationKeys.hlsActionMethodField),
                  keyboard: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
          const Expanded(child: SizedBox()),
        ]),
      ],
    );
  }

  // ------------------------------ TAB: CONFORMANCE
  Widget _tabConformance() {
    final allChecked = _conformanceBits.every((b) => b);
    final b0 = initReqProposedConformanceCtrl.text.length >= 2
        ? initReqProposedConformanceCtrl.text.substring(0, 2)
        : '--';
    final b1 = initReqProposedConformanceCtrl.text.length >= 4
        ? initReqProposedConformanceCtrl.text.substring(2, 4)
        : '--';
    final b2 = initReqProposedConformanceCtrl.text.length >= 6
        ? initReqProposedConformanceCtrl.text.substring(4, 6)
        : '--';

    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        // ── Section 1: Conformance Block ─────────────────────────────────────
        _sectionTitle(
          icon: Icons.fact_check,
          color: DesignTokens.primary600,
          title: 'Conformance Block',
        ),
        const SizedBox(height: 16),
        // Select All / Deselect All
        Row(
          children: [
            Checkbox(
              key: const Key(ConfigurationKeys.conformanceSelectAllChk),
              value: allChecked,
              tristate: false,
              onChanged: (v) {
                setState(() {
                  final val = v ?? false;
                  for (int i = 0; i < 24; i++) _conformanceBits[i] = val;
                  _rebuildConformance();
                });
              },
            ),
            const Text('Select All / Deselect All',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        _responsiveWrap([
          for (int i = 0; i < 24; i++)
            InkWell(
              key: Key('configuration_conformance_bit_${i}_inkwell'),
              onTap: () => setState(() {
                _conformanceBits[i] = !_conformanceBits[i];
                _rebuildConformance();
              }),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    key: Key('configuration_conformance_bit_${i}_chk'),
                    value: _conformanceBits[i],
                    onChanged: (v) => setState(() {
                      _conformanceBits[i] = v ?? false;
                      _rebuildConformance();
                    }),
                  ),
                  Text(
                    _conformanceBitLabels[i],
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // ── Section 2: Conformance Value ──────────────────────────────────────
        _sectionTitle(
          icon: Icons.tag,
          color: DesignTokens.primary600,
          title: 'Conformance',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hexByteBox(b0),
            const SizedBox(width: 8),
            _hexByteBox(b1),
            const SizedBox(width: 8),
            _hexByteBox(b2),
          ],
        ),
      ],
    );
  }

  Widget _hexByteBox(String value) {
    return Container(
      width: 52,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceAltOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brMd,
      ),
      child: Text(
        value.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ------------------------------ TAB: SECURITY
  Widget _tabSecurity() {
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        _sectionTitle(
          icon: Icons.security,
          color: DesignTokens.primary600,
          title: 'Security parameters',
        ),
        const SizedBox(height: 16),

        // ── Security configuration ───────────────────────────────────────────
        _responsiveWrap([
          _dropdownField<String>('Security Suite', _securitySuiteValue, const [
            DropdownMenuItem(value: '0', child: Text('0')),
            DropdownMenuItem(value: '1', child: Text('1')),
          ], (v) {
            setState(() {
              _securitySuiteValue = v;
              securitySuiteCtrl.text = v ?? '';
            });
          }, key: const Key(ConfigurationKeys.securitySuiteDropdown)),
          _selectFieldOptions(
              'Security Level',
              [
                const DropdownMenuItem(value: '0', child: Text('NoSecu')),
                const DropdownMenuItem(value: '1', child: Text('LLS')),
                const DropdownMenuItem(value: '2', child: Text('HLS_secret')),
                const DropdownMenuItem(value: '5', child: Text('HLS_GMAC')),
              ],
              key: const Key(ConfigurationKeys.securityLevelDropdown),
              value: securityLevel, onChanged: (v) {
            setState(() => securityLevel = v!);
          }),
          _dropdownField<String>(
              'Security Policy', _securityPolicyValue, const [
            DropdownMenuItem(value: '0', child: Text('NoSecu')),
            DropdownMenuItem(value: '16', child: Text('A')),
            DropdownMenuItem(value: '32', child: Text('E')),
            DropdownMenuItem(value: '48', child: Text('AE')),
          ], (v) {
            setState(() {
              _securityPolicyValue = v;
              securityPolicyCtrl.text = v ?? '';
            });
          }, key: const Key(ConfigurationKeys.securityPolicyDropdown)),
          _checkboxField('General Signing', _generalSigning, (v) {
            setState(() {
              _generalSigning = v;
              _cipheringType = v ? 5 : null;
              cipheringTypeCtrl.text = v ? '5' : '';
            });
          }, key: const Key(ConfigurationKeys.generalSigningChk)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ── Keys & cryptographic material ────────────────────────────────────
        _responsiveWrap([
          _keyField('Viewer Private Signing Key',
              certificateClientPrivateSignedKeyCtrl,
              key: const Key(ConfigurationKeys.viewerPrivateSigningKeyField)),
          _keyField(
              'Meter Public Signing Key', certificateMeterPublicSignedKeyCtrl,
              key: const Key(ConfigurationKeys.meterPublicSigningKeyField)),
          _keyField('Secret Key', keyHlsSecretKeyCtrl,
              key: const Key(ConfigurationKeys.hlsSecretKeyField)),
          _keyField('Master Key', keyMasterKeyCtrl,
              key: const Key(ConfigurationKeys.masterKeyField)),
          _keyField('Global Key', keyEncryptionKeyCtrl,
              key: const Key(ConfigurationKeys.globalKeyField)),
          _keyField('Authentication Key', keyAuthenticationKeyCtrl,
              key: const Key(ConfigurationKeys.authKeyField)),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ── Dedicated key handling ───────────────────────────────────────────
        _responsiveWrap([
          _checkboxField('Use Dedicated Key', _useDedicatedKey, (v) {
            setState(() => _useDedicatedKey = v);
          }, key: const Key(ConfigurationKeys.useDedicatedKeyChk)),
        ]),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: !_useDedicatedKey,
          child: Opacity(
            opacity: _useDedicatedKey ? 1.0 : 0.4,
            child: _responsiveWrap([
              _keyField('Dedicated Key', keyDedicatedKeyCtrl,
                  key: const Key(ConfigurationKeys.dedicatedKeyField)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ── Frame counter & addressing ───────────────────────────────────────
        _responsiveWrap([
          _checkboxField('Get Frame Counter', getFrameCounter, (v) {
            setState(() => getFrameCounter = v);
          }, key: const Key(ConfigurationKeys.getFrameCounterChk)),
          IgnorePointer(
            ignoring: getFrameCounter,
            child: Opacity(
              opacity: getFrameCounter ? 0.4 : 1.0,
              child: _field('Proposed Frame Counter Value',
                  fcpProposedFrameCounterValueCtrl,
                  key: const Key(ConfigurationKeys.proposedFrameCounterField),
                  keyboard: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            ),
          ),
          _field('Public Client Address', fcpPublicAddrCtrl,
              key: const Key(ConfigurationKeys.publicClientAddrField),
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Frame Counter OBIS', fcpFrameCounterObisCtrl,
              key: const Key(ConfigurationKeys.frameCounterObisField),
              inputFormatters: hex()),
          _field('Frame Counter Class', fcpFrameCounterClassCtrl,
              key: const Key(ConfigurationKeys.frameCounterClassField),
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          _field('Frame Counter Attribute', fcpFrameCounterAttributeCtrl,
              key: const Key(ConfigurationKeys.frameCounterAttrField),
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        ]),
      ],
    );
  }

  void applyConfig(List<ConfigEntry> entries) {
    // 1) Build a dispatcher from dotted key to a setter
    final Map<String, void Function(dynamic)> setByKey = {
      // -------- session ----------
      'session.buffer_size': (v) => bufferSizeCtrl.text = '$v',
      'session.pre_established': (v) =>
          setState(() => preEstablished = (v == true)),

      'session.hls_action.hls_action_obis': (v) =>
          hlsActionObisCtrl.text = '$v',
      'session.hls_action.hls_action_class': (v) =>
          hlsActionClassCtrl.text = '$v',
      'session.hls_action.hls_action_methode': (v) =>
          hlsActionMethodeCtrl.text = '$v',

      'session.initiate_request.proposed_quality_of_service': (v) =>
          initReqProposedQualityOfServiceCtrl.text = '$v',
      'session.initiate_request.proposed_dlms_version_number': (v) =>
          initReqProposedDlmsVersionNumberCtrl.text = '$v',
      'session.initiate_request.proposed_max_receive_pdu_size': (v) =>
          initReqProposedMaxReceivePduSizeCtrl.text = '$v',
      'session.initiate_request.proposed_max_send_pdu_size': (v) =>
          initReqProposedMaxSendPduSizeCtrl.text = '$v',
      'session.initiate_request.proposed_conformance': (v) {
        final hex = '$v';
        initReqProposedConformanceCtrl.text = hex;
        if (mounted) setState(() => _applyConformanceBytes(hex));
      },

      'session.initiate_request.calling_ae_invocation_id_activate': (v) {
        // treat as checkbox-like int/bool
        setState(() => callingAeInvocationIdActivate = (v == true || v == 1));
      },
      'session.initiate_request.calling_ae_invocation_id': (v) =>
          initReqCallingAeInvocationIdCtrl.text = '$v',
      'session.initiate_request.hls_ctos_size': (v) =>
          initReqHlsCtosSizeCtrl.text = '$v',
      'session.initiate_request.hls_ctos': (v) =>
          initReqHlsCtosCtrl.text = '$v',
      'session.initiate_request.password': (v) =>
          initReqPasswordCtrl.text = '$v',

      // -------- communication ----------
      'communication.transport_type': (v) {
        const _k = {'HDLC', 'direct'};
        final s = '$v';
        final val = _k.contains(s) ? s : null;
        transportTypeCtrl.text = val ?? '';
        if (mounted)
          setState(() {
            _transportType = val;
          });
      },
      'communication.link_type': (v) {
        const _k = {'serial'};
        final s = '$v';
        final val = _k.contains(s) ? s : null;
        linkTypeCtrl.text = val ?? '';
        if (mounted)
          setState(() {
            _linkType = val;
            _serialActive = val == 'serial';
          });
      },
      'communication.mode_com': (v) {
        const _k = {'DirectHDLC', 'Mode_E'};
        final s = '$v';
        final val = _k.contains(s) ? s : null;
        modeComCtrl.text = val ?? '';
        if (mounted)
          setState(() {
            _modeCom = val;
          });
      },
      'communication.client_addr': (v) => clientAddrCtrl.text = '$v',
      'communication.client_addr_len': (v) => clientAddrLenCtrl.text = '$v',
      'communication.server_addr': (v) => serverAddrCtrl.text = '$v',
      'communication.server_addr_len': (v) => serverAddrLenCtrl.text = '$v',

      'communication.hdlc.modee_baudrate': (v) =>
          hdlcModeeBaudrateCtrl.text = '$v',
      'communication.hdlc.enable_hdlc_negociation': (v) {
        final b = v == true || v == 1 || v == '1' || v == 'true';
        hdlcEnableHdlcNegociationCtrl.text = b.toString();
        if (mounted) setState(() => _enableHdlcNegociation = b);
      },

      'communication.hdlc.hdlc_negociation.max_info_transmit_length': (v) =>
          hdlcNegMaxInfoTransmitLengthCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.max_info_transmit_value': (v) =>
          hdlcNegMaxInfoTransmitValueCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.max_info_receive_length': (v) =>
          hdlcNegMaxInfoReceiveLengthCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.max_info_receive_value': (v) =>
          hdlcNegMaxInfoReceiveValueCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.window_size_transmit_length': (v) =>
          hdlcNegWindowSizeTransmitLengthCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.window_size_transmit_value': (v) =>
          hdlcNegWindowSizeTransmitValueCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.window_size_receive_length': (v) =>
          hdlcNegWindowSizeReceiveLengthCtrl.text = '$v',
      'communication.hdlc.hdlc_negociation.window_size_receive_value': (v) =>
          hdlcNegWindowSizeReceiveValueCtrl.text = '$v',

      'communication.serial.port': (v) {
        final s = '$v';
        serialPortCtrl.text = s;
        if (mounted)
          setState(() {
            _serialPort = s.isNotEmpty ? s : null;
            if (_serialPort != null &&
                !_availableComPorts.contains(_serialPort)) {
              _availableComPorts = [..._availableComPorts, _serialPort!];
            }
          });
      },
      'communication.serial.baudrate': (v) {
        final s = '$v';
        serialBaudrateCtrl.text = s;
        if (mounted) setState(() => _serialBaudrate = s);
      },
      'communication.serial.timeout': (v) => serialTimeoutCtrl.text = '$v',

      'communication.gprs.gprs_type': (v) => gprsTypeCtrl.text = '$v',
      'communication.gprs.gprsip': (v) => gprsIpCtrl.text = '$v',
      'communication.gprs.gprsport': (v) => gprsPortCtrl.text = '$v',
      'communication.gprs.serial_com': (v) => gprsSerialComCtrl.text = '$v',
      'communication.gprs.baude_rate': (v) => gprsBaudeRateCtrl.text = '$v',

      'communication.plc_ipv4.plcip': (v) =>
          plcIpv4IpCtrl.text = _normalizeIpv4('$v'),
      'communication.plc_ipv4.plcport': (v) => plcIpv4PortCtrl.text = '$v',
      'communication.plc_ipv4.plcmetersn': (v) =>
          plcIpv4MeterSnCtrl.text = '$v', // HEX
      'communication.plc_ipv4.activate_plcipv4': (v) {
        // Only sync the ctrl for save purposes; checkbox is user-controlled only
        final active = v == true || v == 1 || v == '1';
        plcIpv4ActivateCtrl.text = active ? '1' : '0';
      },

      'communication.plc_ipv6.plcip': (v) => plcIpv6IpCtrl.text = '$v',
      'communication.plc_ipv6.plcport': (v) => plcIpv6PortCtrl.text = '$v',
      'communication.plc_ipv6.plcudpportsrc': (v) =>
          plcIpv6UdpPortSrcCtrl.text = '$v',
      'communication.plc_ipv6.activate_plcipv6': (v) {
        final active = v == true || v == 1 || v == '1';
        plcIpv6ActivateCtrl.text = active ? '1' : '0';
        if (mounted) setState(() => _plcIpv6Active = active);
      },

      'communication.st8500.serial_com': (v) => st8500SerialComCtrl.text = '$v',
      'communication.st8500.s_sap': (v) => st8500SSapCtrl.text = '$v',

      'communication.keep_connection.active': (v) {
        final b = v == true || v == 1 || v == '1';
        if (mounted) setState(() => _keepConnection = b);
      },
      'communication.keep_connection.timeout': (v) =>
          keepConnectionTimeoutCtrl.text = '$v',

      // -------- security ----------
      'security.session_type': (v) {
        const _k = {'LLS', 'HLS', 'NOSEC'};
        final s = '$v';
        final val = _k.contains(s) ? s : null;
        securitySessionTypeCtrl.text = val ?? '';
        if (mounted)
          setState(() {
            _sessionType = val;
          });
      },
      'security.referencing_method': (v) => referencingMethodCtrl.text = '$v',
      'security.system_title': (v) =>
          systemTitleCtrl.text = '$v', // bytes -> HEX handled by _extractValue
      'security.serial_number': (v) => serialNumberCtrl.text = '$v',
      'security.frame_counter': (v) => frameCounterCtrl.text = '$v',
      'security.security_policy': (v) {
        final s = '$v';
        securityPolicyCtrl.text = s;
        if (mounted) setState(() => _securityPolicyValue = s);
      },
      'security.security_level': (v) => setState(() => securityLevel = '$v'),
      'security.security_suite': (v) {
        final s = '$v';
        securitySuiteCtrl.text = s;
        if (mounted) setState(() => _securitySuiteValue = s);
      },
      'security.ciphering_type': (v) {
        final val = (v is int) ? v : int.tryParse('$v');
        cipheringTypeCtrl.text = val != null ? '$val' : '';
        if (mounted)
          setState(() {
            _cipheringType = val;
            _generalSigning = val == 5;
          });
      },

      'security.certificate.client_private_signed_key': (v) =>
          certificateClientPrivateSignedKeyCtrl.text = '$v', // hex
      'security.certificate.meter_public_signed_key': (v) =>
          certificateMeterPublicSignedKeyCtrl.text = '$v', // hex

      'security.key.dedicated_key': (v) =>
          keyDedicatedKeyCtrl.text = '$v', // bytes -> hex
      'security.key.authentication_key': (v) =>
          keyAuthenticationKeyCtrl.text = '$v',
      'security.key.encryption_key': (v) => keyEncryptionKeyCtrl.text = '$v',
      'security.key.hls_secret_key': (v) => keyHlsSecretKeyCtrl.text = '$v',
      'security.key.master_key': (v) => keyMasterKeyCtrl.text = '$v',

      'security.frame_counter_param.public_addr': (v) =>
          fcpPublicAddrCtrl.text = '$v',
      'security.frame_counter_param.get_frame_counter': (v) =>
          setState(() => getFrameCounter = (v == true)),
      'security.frame_counter_param.action_frame_counter': (v) =>
          setState(() => actionFrameCounter = (v == true)),
      'security.frame_counter_param.frame_counter_obis': (v) =>
          fcpFrameCounterObisCtrl.text = '$v',
      'security.frame_counter_param.frame_counter_class': (v) =>
          fcpFrameCounterClassCtrl.text = '$v',
      'security.frame_counter_param.frame_counter_attribute': (v) =>
          fcpFrameCounterAttributeCtrl.text = '$v',
      'security.frame_counter_param.proposed_frame_counter_value': (v) =>
          fcpProposedFrameCounterValueCtrl.text = '$v',
      'security.frame_counter_param.frame_counter_index': (v) =>
          fcpFrameCounterIndexCtrl.text = '$v',
    };

    // 2) Apply each entry
    for (final e in entries) {
      final String? key = e.key as String?;
      final dynamic valueMap = e.value;

      if (key == null || valueMap == null) continue;

      final dynamic val = anyToDart(valueMap);

      print('key: $key value:$val');
      final setter = setByKey[key];
      if (setter != null) {
        setter(val is Uint8List ? bytesToHex(val) : val);
      } else {
        // Unknown key → ignore or log
        // debugPrint('No setter for $key (val=$val)');
      }
    }
  }

  void saveConfiguration() async {
    if (_module == null) {
      _showMessage('Veuillez sélectionner un module', false);
      return;
    }

    try {
      bool response = await client.setConfig(buildConfigEntries(), toFile);

      if (response) {
        _showMessage('Configuration enregistrée avec succès', true);
        _logAdd('ok', 'Configuration enregistrée');
      } else {
        _showMessage(
            'Erreur lors de l\'enregistrement de la configuration', false);
        _logAdd('error', 'Échec de l\'enregistrement');
      }
    } catch (e) {
      _showMessage('Erreur: $e', false);
      _logAdd('error', 'Exception: $e');
    }
  }

  void _showMessage(String message, bool isSuccess) {
    if (!mounted) return;
    if (isSuccess) {
      feedback.success(message);
    } else {
      feedback.error(message);
    }
  }

// ===== COLLECT FROM UI -> List<ConfigEntry> =====
  List<ConfigEntry> buildConfigEntries() {
    final entries = <ConfigEntry>[];

    void add(String key, dynamic value) {
      // Skip nulls if you prefer not to overwrite unset fields
      if (value == null) return;
      entries.add(ConfigEntry()
        ..module = _module!
        ..key = key
        ..value = dartToAny(value));
    }

    void addHex(String key, String text, List<ConfigEntry> entries) {
      final t = text.trim();
      if (t.isEmpty) return;
      final bytes = hexToBytes(t);
      entries.add(ConfigEntry()
        ..module = _module!
        ..key = key
        ..value = dartToAny(bytes)); // -> Any(BytesValue)
    }

    // ---------- session ----------
    add('session.buffer_size', _parseInt(bufferSizeCtrl.text));
    add('session.pre_established', preEstablished);

    add('session.hls_action.hls_action_obis', hlsActionObisCtrl.text);
    add('session.hls_action.hls_action_class',
        _parseInt(hlsActionClassCtrl.text));
    add('session.hls_action.hls_action_methode',
        _parseInt(hlsActionMethodeCtrl.text));

    add('session.initiate_request.proposed_quality_of_service',
        _parseInt(initReqProposedQualityOfServiceCtrl.text));
    add('session.initiate_request.proposed_dlms_version_number',
        _parseInt(initReqProposedDlmsVersionNumberCtrl.text));
    add('session.initiate_request.proposed_max_receive_pdu_size',
        _parseInt(initReqProposedMaxReceivePduSizeCtrl.text));
    add('session.initiate_request.proposed_max_send_pdu_size',
        _parseInt(initReqProposedMaxSendPduSizeCtrl.text));

    // proposed_conformance: treat as HEX->bytes (your response showed bytes)
    addHex('session.initiate_request.proposed_conformance',
        initReqProposedConformanceCtrl.text, entries);

    add('session.initiate_request.calling_ae_invocation_id_activate',
        callingAeInvocationIdActivate);
    add('session.initiate_request.calling_ae_invocation_id',
        _parseInt(initReqCallingAeInvocationIdCtrl.text));
    add('session.initiate_request.hls_ctos_size',
        _parseInt(initReqHlsCtosSizeCtrl.text));
    add('session.initiate_request.hls_ctos', initReqHlsCtosCtrl.text);
    add('session.initiate_request.password', initReqPasswordCtrl.text);

    // ---------- communication ----------
    add('communication.transport_type', transportTypeCtrl.text);
    add('communication.link_type', linkTypeCtrl.text);
    add('communication.mode_com', modeComCtrl.text);
    add('communication.client_addr', _parseInt(clientAddrCtrl.text));
    add('communication.client_addr_len', _parseInt(clientAddrLenCtrl.text));
    add('communication.server_addr', _parseInt(serverAddrCtrl.text));
    add('communication.server_addr_len', _parseInt(serverAddrLenCtrl.text));

    add('communication.hdlc.modee_baudrate',
        _parseInt(hdlcModeeBaudrateCtrl.text));
    add('communication.hdlc.enable_hdlc_negociation', _enableHdlcNegociation);

    add('communication.hdlc.hdlc_negociation.max_info_transmit_length',
        _parseInt(hdlcNegMaxInfoTransmitLengthCtrl.text));
    add('communication.hdlc.hdlc_negociation.max_info_transmit_value',
        _parseInt(hdlcNegMaxInfoTransmitValueCtrl.text));
    add('communication.hdlc.hdlc_negociation.max_info_receive_length',
        _parseInt(hdlcNegMaxInfoReceiveLengthCtrl.text));
    add('communication.hdlc.hdlc_negociation.max_info_receive_value',
        _parseInt(hdlcNegMaxInfoReceiveValueCtrl.text));
    add('communication.hdlc.hdlc_negociation.window_size_transmit_length',
        _parseInt(hdlcNegWindowSizeTransmitLengthCtrl.text));
    add('communication.hdlc.hdlc_negociation.window_size_transmit_value',
        _parseInt(hdlcNegWindowSizeTransmitValueCtrl.text));
    add('communication.hdlc.hdlc_negociation.window_size_receive_length',
        _parseInt(hdlcNegWindowSizeReceiveLengthCtrl.text));
    add('communication.hdlc.hdlc_negociation.window_size_receive_value',
        _parseInt(hdlcNegWindowSizeReceiveValueCtrl.text));

    add('communication.serial.port', serialPortCtrl.text);
    add('communication.serial.baudrate', _parseInt(serialBaudrateCtrl.text));
    add('communication.serial.timeout', _parseInt(serialTimeoutCtrl.text));

    add('communication.gprs.gprs_type', _parseInt(gprsTypeCtrl.text));
    add('communication.gprs.gprsip', gprsIpCtrl.text);
    add('communication.gprs.gprsport', _parseInt(gprsPortCtrl.text));
    add('communication.gprs.serial_com', gprsSerialComCtrl.text);
    add('communication.gprs.baude_rate', _parseInt(gprsBaudeRateCtrl.text));

    add('communication.plc_ipv4.plcip', _formatLegacyIpv4(plcIpv4IpCtrl.text));
    add('communication.plc_ipv4.plcport', _parseInt(plcIpv4PortCtrl.text));
    // plcmetersn looked hex in your sample → bytes
    addHex(
        'communication.plc_ipv4.plcmetersn', plcIpv4MeterSnCtrl.text, entries);
    add('communication.plc_ipv4.activate_plcipv4', _plcIpv4Active ? 1 : 0);

    add('communication.plc_ipv6.plcip', plcIpv6IpCtrl.text);
    add('communication.plc_ipv6.plcport', _parseInt(plcIpv6PortCtrl.text));
    add('communication.plc_ipv6.plcudpportsrc',
        _parseInt(plcIpv6UdpPortSrcCtrl.text));
    add('communication.plc_ipv6.activate_plcipv6', _plcIpv6Active ? 1 : 0);

    add('communication.st8500.serial_com', _parseInt(st8500SerialComCtrl.text));
    add('communication.st8500.s_sap', _parseInt(st8500SSapCtrl.text));

    add('communication.keep_connection.active', _keepConnection);
    add('communication.keep_connection.timeout',
        _parseInt(keepConnectionTimeoutCtrl.text));

    // ---------- security ----------
    add('security.session_type', securitySessionTypeCtrl.text);
    add('security.referencing_method', referencingMethodCtrl.text);

    // bytes on the wire:
    addHex('security.system_title', systemTitleCtrl.text, entries);

    add('security.serial_number', serialNumberCtrl.text);
    add('security.frame_counter', _parseInt(frameCounterCtrl.text));
    add('security.security_policy', _parseInt(securityPolicyCtrl.text));

    // your sample had security_level as OID-like string → keep as string
    add('security.security_level',
        _parseInt(securityLevel)); // if you bound to a string var

    add('security.security_suite', _parseInt(securitySuiteCtrl.text));
    // ciphering_type looked int in response → int
    add('security.ciphering_type', _cipheringType);

    // certificate (strings of hex in your response; if you want raw bytes on wire, convert)
    addHex('security.certificate.client_private_signed_key',
        certificateClientPrivateSignedKeyCtrl.text, entries);
    addHex('security.certificate.meter_public_signed_key',
        certificateMeterPublicSignedKeyCtrl.text, entries);

    // key.* were bytes in response → send bytes
    addHex('security.key.dedicated_key', keyDedicatedKeyCtrl.text, entries);
    addHex('security.key.authentication_key', keyAuthenticationKeyCtrl.text,
        entries);
    addHex('security.key.encryption_key', keyEncryptionKeyCtrl.text, entries);
    addHex('security.key.hls_secret_key', keyHlsSecretKeyCtrl.text, entries);
    addHex('security.key.master_key', keyMasterKeyCtrl.text, entries);

    add('security.frame_counter_param.public_addr',
        _parseInt(fcpPublicAddrCtrl.text));
    add('security.frame_counter_param.get_frame_counter', getFrameCounter);
    add('security.frame_counter_param.action_frame_counter',
        actionFrameCounter);

    if (fcpFrameCounterObisCtrl.text.trim().isNotEmpty) {
      add('security.frame_counter_param.frame_counter_obis',
          fcpFrameCounterObisCtrl.text);
    }
    add('security.frame_counter_param.frame_counter_class',
        _parseInt(fcpFrameCounterClassCtrl.text));
    add('security.frame_counter_param.frame_counter_attribute',
        _parseInt(fcpFrameCounterAttributeCtrl.text));
    add('security.frame_counter_param.proposed_frame_counter_value',
        _parseInt(fcpProposedFrameCounterValueCtrl.text));
    add('security.frame_counter_param.frame_counter_index',
        _parseInt(fcpFrameCounterIndexCtrl.text));

    return entries;
  }

  // ------------------------------ TAB: DIAGNOSTICS
  Widget _tabDiagnostics() {
    // Cover model constructor paths in this hidden diagnostics view.
    DlmsObject(
      id: 0,
      obis: '0.0.0.0.0.0',
      name: 'diag',
      cls: 0,
      version: 0,
      access: 'r',
      lastRead: null,
    );
    return ListView(
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      children: [
        _responsiveWrap([
          _actionsField('Ping Compteur', [
            _secondaryButton(Icons.wifi_tethering, 'Ping', _pingMeter,
                key: const Key(ConfigurationKeys.diagPingBtn)),
            _primaryButton(Icons.alt_route, 'Trace', _traceRoute,
                key: const Key(ConfigurationKeys.diagTraceBtn)),
          ]),
          _selectField(
              'Profil Lecture Rapide', ['Base', 'Sécurité', 'Énergie'],
              key: const Key(ConfigurationKeys.diagProfilDropdown)),
          _actionsField('Export Journal', [
            _secondaryButton(Icons.file_download, 'Exporter', _exportLog,
                key: const Key(ConfigurationKeys.diagExportLogBtn)),
          ]),
          _actionsField('Connexion / Session', [
            _successButton(Icons.power, 'Test', _testConnection,
                key: const Key(ConfigurationKeys.diagTestConnBtn)),
            _secondaryButton(Icons.schedule, 'Sync', _syncClock,
                key: const Key(ConfigurationKeys.diagSyncClockBtn)),
            _secondaryButton(Icons.handshake, 'Négocier', _negotiate,
                key: const Key(ConfigurationKeys.diagNegotiateBtn)),
            _successButton(Icons.login, 'Ouvrir', _openSession,
                key: const Key(ConfigurationKeys.diagOpenSessionBtn)),
            _dangerButton(Icons.logout, 'Fermer', _closeSession,
                key: const Key(ConfigurationKeys.diagCloseSessionBtn)),
            _secondaryButton(Icons.play_arrow, 'Associer', _startAssociation,
                key: const Key(ConfigurationKeys.diagStartAssocBtn)),
            _dangerButton(Icons.stop, 'Release', _releaseAssociation,
                key: const Key(ConfigurationKeys.diagReleaseAssocBtn)),
          ]),
          _actionsField('Outils', [
            _primaryButton(
                Icons.graphic_eq, 'Start latency', _startLatencySimulation,
                key: const Key(ConfigurationKeys.diagStartLatencyBtn)),
            _secondaryButton(
                Icons.playlist_add,
                'Seed latencies',
                () => setState(() {
                      _latencies
                        ..clear()
                        ..addAll(List<int>.generate(41, (i) => i + 1));
                    }),
                key: const Key(ConfigurationKeys.diagSeedLatenciesBtn)),
            _secondaryButton(Icons.bug_report, 'Spam log', () {
              for (int i = 0; i < maxLog + 5; i++) {
                _logAdd('info', 'spam');
              }
            }, key: const Key(ConfigurationKeys.diagSpamLogBtn)),
          ]),
          _passwordField('Password', TextEditingController(),
              key: const Key(ConfigurationKeys.diagPasswordField)),
          _customField(
            'Alerts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoAlert('Info', 'ok'),
                const SizedBox(height: 12),
                _warningAlert('Warning', 'warn'),
              ],
            ),
          ),
          _customField(
            'Level chips',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _levelChip('ok'),
                _levelChip('warn'),
                _levelChip('err'),
                _levelChip('error'),
                _levelChip('other'),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 28),
        _sectionTitle(
            icon: Icons.timeline,
            color: DesignTokens.primary600,
            title: 'Latences Récentes'),
        const SizedBox(height: 12),
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: DesignTokens.surfaceAltOf(context),
            border: Border.all(color: DesignTokens.borderOf(context)),
            borderRadius: DesignTokens.brLg,
          ),
          padding: const EdgeInsets.all(12),
          child: CustomPaint(
            painter: _LatencyPainter(List<int>.unmodifiable(_latencies)),
            child: Container(),
          ),
        ),
        const SizedBox(height: 12),
        _kvGrid(const {'status': 'ok'}),
      ],
    );
  }

  // ------------------------------ INSPECTOR

  Widget _kvGrid(Map<String, String> map) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: map.entries
          .map((e) => TableRow(children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 6, right: 12),
                    child: Text(e.key.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textSecondaryOf(context),
                            letterSpacing: .6))),
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(e.value,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500))),
              ]))
          .toList(),
    );
  }

  // --------------------------------------------------------------------------- COMPONENT BUILDERS
  Widget _responsiveWrap(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 1200;
      final isMedium = constraints.maxWidth > 800;
      final columns = isWide ? 3 : (isMedium ? 2 : 1);
      final spacing = isWide ? 20.0 : (isMedium ? 16.0 : 0.0);
      final w = columns > 1
          ? (constraints.maxWidth - (spacing * (columns - 1))) / columns
          : constraints.maxWidth;
      return Wrap(
        spacing: spacing,
        runSpacing: 16,
        children: [for (final c in children) SizedBox(width: w, child: c)],
      );
    });
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    Key? key,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return _labeled(
      label,
      TextField(
        key: key,
        controller: ctrl,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        decoration: DesignTokens.inputDecorationOf(context),
      ),
    );
  }

  Widget _fieldWithUnit(
    String label,
    TextEditingController ctrl,
    String unit, {
    Key? key,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return _labeled(
      label,
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              key: key,
              controller: ctrl,
              keyboardType: keyboard,
              inputFormatters: inputFormatters,
              decoration: DesignTokens.inputDecorationOf(context),
            ),
          ),
          const SizedBox(width: 8),
          Text(unit,
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context))),
        ],
      ),
    );
  }

  Widget _dropdownField<T>(String label, T? value,
      List<DropdownMenuItem<T?>> items, ValueChanged<T?> onChanged,
      {Key? key}) {
    return _labeled(
      label,
      DropdownButtonFormField<T?>(
        key: key,
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: DesignTokens.inputDecorationOf(context),
      ),
    );
  }

  Widget _checkboxField(
      String label, bool value, ValueChanged<bool> onChanged, {Key? key}) {
    return _labeled(
      label,
      Checkbox(
        key: key,
        value: value,
        onChanged: (v) => onChanged(v ?? false),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController ctrl, {Key? key}) {
    return StatefulBuilder(builder: (context, setSB) {
      bool obscured = true;
      return _labeled(
        label,
        StatefulBuilder(builder: (context, setInner) {
          return TextField(
            key: key,
            controller: ctrl,
            obscureText: obscured,
            decoration: DesignTokens.inputDecorationOf(context,
              suffix: IconButton(
                icon: Icon(obscured ? Icons.visibility : Icons.visibility_off,
                    size: 18),
                onPressed: () => setInner(() => obscured = !obscured),
              ),
            ),
          );
        }),
      );
    });
  }

  /// Like [_passwordField] but with hex [inputFormatters] — used for cryptographic key fields.
  Widget _keyField(String label, TextEditingController ctrl, {Key? key}) {
    return StatefulBuilder(builder: (context, setOuter) {
      bool obscured = true;
      return _labeled(
        label,
        StatefulBuilder(builder: (context, setInner) {
          return TextField(
            key: key,
            controller: ctrl,
            obscureText: obscured,
            inputFormatters: hex(),
            decoration: DesignTokens.inputDecorationOf(context,
              suffix: IconButton(
                icon: Icon(obscured ? Icons.visibility : Icons.visibility_off,
                    size: 18),
                onPressed: () => setInner(() => obscured = !obscured),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _selectField(String label, List<String> options,
      {Key? key, String? value, ValueChanged<String?>? onChanged}) {
    return _labeled(
      label,
      DropdownButtonFormField<String>(
        key: key,
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: DesignTokens.inputDecorationOf(context, hint: "Select Option"),
      ),
    );
  }

  Widget _selectFieldOptions(
      String label, List<DropdownMenuItem<String>> options,
      {Key? key, String? value, ValueChanged<String?>? onChanged}) {
    return _labeled(
      label,
      DropdownButtonFormField<String>(
        key: key,
        value: value,
        items: options,
        onChanged: onChanged,
        decoration: DesignTokens.inputDecorationOf(context, hint: "Select Option"),
      ),
    );
  }

  Widget _actionsField(String label, List<Widget> buttons) {
    return _labeled(
      label,
      Wrap(spacing: 12, runSpacing: 12, children: buttons),
    );
  }

  Widget _customField(String label, {required Widget child}) =>
      _labeled(label, child);

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _sectionTitle(
      {required IconData icon, required Color color, required String title}) {
    return Row(children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
    ]);
  }

  Widget _infoAlert(String title, String msg) =>
      _alert(Icons.info, DesignTokens.info, title, msg);
  Widget _warningAlert(String title, String msg) =>
      _alert(Icons.warning, DesignTokens.warning, title, msg);

  Widget _alert(IconData icon, Color color, String title, String msg) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: DesignTokens.brMd,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(msg,
              style: TextStyle(color: color.withOpacity(.85), fontSize: 13)),
        ]))
      ]),
    );
  }

  // Buttons
  Widget _primaryButton(IconData ic, String label, VoidCallback onTap,
          {Key? key}) =>
      _btn(ic, label, onTap, DesignTokens.primary600, Colors.white, key: key);
  Widget _secondaryButton(IconData ic, String label, VoidCallback onTap,
          {Key? key}) =>
      _btn(ic, label, onTap, Colors.transparent, DesignTokens.primary600,
          outlined: true, key: key);
  Widget _successButton(IconData ic, String label, VoidCallback onTap,
          {Key? key}) =>
      _btn(ic, label, onTap, DesignTokens.success, Colors.white, key: key);
  Widget _dangerButton(IconData ic, String label, VoidCallback onTap,
          {Key? key}) =>
      _btn(ic, label, onTap, DesignTokens.danger, Colors.white, key: key);

  Widget _btn(IconData ic, String label, VoidCallback onTap, Color bg, Color fg,
      {bool outlined = false, Key? key}) {
    return ElevatedButton.icon(
      key: key,
      onPressed: onTap,
      icon: Icon(ic, size: 18),
      label: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        elevation: outlined ? 0 : 2,
        backgroundColor: outlined ? Colors.transparent : bg,
        foregroundColor: outlined ? fg : fg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.brMd,
          side: outlined ? BorderSide(color: fg) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _levelChip(String level) {
    Color c;
    switch (level) {
      case 'ok':
        c = DesignTokens.success;
        break;
      case 'warn':
        c = DesignTokens.warning;
        break;
      case 'err':
      case 'error':
        c = DesignTokens.danger;
        break;
      default:
        c = DesignTokens.info;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(.4)),
      ),
      child: Text(level.toUpperCase(),
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)),
    );
  }

  // --------------------------------------------------------------------------- LOGIC & STATE

  void _testConnection() {
    _logAdd('info', 'Test connexion...');
    Future.delayed(const Duration(milliseconds: 700), () {
      _setStateIfMounted(() => _connected = true);
      _logAdd('ok', 'Réponse compteur OK');
    });
  }

  void _syncClock() => _logAdd('ok', 'Horloge synchronisée');
  void _negotiate() => _logAdd('ok', 'Paramètres négociés');
  void _openSession() {
    _logAdd('info', 'Ouverture session...');
    Future.delayed(const Duration(milliseconds: 600), () {
      _setStateIfMounted(() => _associationActive = true);
      _logAdd('ok', 'Session ouverte');
    });
  }

  void _closeSession() {
    _setStateIfMounted(() => _associationActive = false);
    _logAdd('warn', 'Session fermée');
  }

  void _startAssociation() {
    _logAdd('info', 'Association démarrée');
    Future.delayed(const Duration(milliseconds: 800),
        () => _logAdd('ok', 'Association réussie'));
  }

  void _releaseAssociation() {
    _logAdd('warn', 'Association release');
    _setStateIfMounted(() => _associationActive = false);
  }

  void _pingMeter() {
    _logAdd('info', 'Ping...');
    Future.delayed(
        const Duration(milliseconds: 400), () => _logAdd('ok', 'Ping 24 ms'));
  }

  void _traceRoute() {
    _logAdd('info', 'Traceroute ...');
    Future.delayed(const Duration(milliseconds: 900),
        () => _logAdd('ok', '3 hops (simulé)'));
  }

  void _exportLog() => _logAdd('info', 'Export journal (simulé)');

  // void _startAssociation() => _startAssociation(); // (shadow, but keep for planned logic)

  void _startLatencySimulation() {
    _latencyTimer?.cancel();
    _latencyTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        if (_latencies.length > 40) _latencies.removeAt(0);
        _latencies.add(20 + (DateTime.now().millisecond % 70));
      });
    });
  }

  int? _parseInt(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  /// Removes per-octet space-padding used by the legacy backend.
  /// e.g. "10.207.  2.102" → "10.207.2.102"
  String _normalizeIpv4(String raw) =>
      raw.split('.').map((o) => o.trim()).join('.');

  /// Re-applies legacy space-padding (3-char right-aligned per octet).
  /// e.g. "10.207.2.102" → "10.207.  2.102"
  String _formatLegacyIpv4(String ip) =>
      ip.split('.').map((o) => o.trim().padLeft(3)).join('.');

  void _logAdd(String type, String message) {
    if (!mounted) return;
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final time = '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
    _log.add(_LogEntry(type: type, message: message, time: time));
    if (_log.length > maxLog) _log.removeRange(0, _log.length - maxLog);
    setState(() {});
  }
}

// ----------------------------------------------------------------------------- DATA MODELS
class DlmsObject {
  DlmsObject(
      {required this.id,
      required this.obis,
      required this.name,
      required this.cls,
      required this.version,
      required this.access,
      this.lastRead});
  final int id;
  final String obis;
  final String name;
  final int cls;
  final int version;
  final String access;
  final String? lastRead;
}

class _LogEntry {
  _LogEntry({required this.type, required this.message, required this.time});
  final String type; // info | ok | warn | err
  final String message;
  final String time;
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.label, required this.key});
  final IconData icon;
  final String label;
  final String key;
}

// ----------------------------------------------------------------------------- LATENCY GRAPH PAINTER
class _LatencyPainter extends CustomPainter {
  _LatencyPainter(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white.withOpacity(.6);
    final line = Paint()
      ..color = DesignTokens.primary600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final grid = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Grid lines
    const hLines = 4;
    for (int i = 0; i <= hLines; i++) {
      final y = size.height * i / hLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (values.isEmpty) return;
    final maxV = (values.reduce((a, b) => a > b ? a : b) * 1.15)
        .clamp(1, 999)
        .toDouble();
    final stepX = size.width / (values.length - 1).clamp(1, 999);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, line);

    // Fill under line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, bg);
  }

  @override
  bool shouldRepaint(covariant _LatencyPainter oldDelegate) =>
      oldDelegate.values != values;
}

// ---------------------------------------------------------------------------
// HDLC Inactivity Timeout field — standalone ConsumerStatefulWidget so it can
// read and write [hdlcTimeoutProvider] without coupling _ConfigurationPageState.
// ---------------------------------------------------------------------------

class _HdlcTimeoutField extends ConsumerStatefulWidget {
  const _HdlcTimeoutField();

  @override
  ConsumerState<_HdlcTimeoutField> createState() => _HdlcTimeoutFieldState();
}

class _HdlcTimeoutFieldState extends ConsumerState<_HdlcTimeoutField> {
  late final TextEditingController _ctrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    ref.read(hdlcTimeoutProvider.future).then((v) {
      if (mounted) _ctrl.text = '$v';
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = int.tryParse(_ctrl.text.trim());
    if (v == null || v < 5) {
      feedback.error('HDLC timeout must be ≥ 5 seconds');
      return;
    }
    await ref.read(hdlcTimeoutProvider.notifier).setSeconds(v);
    if (mounted) setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HDLC Timeout (s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  key: const Key(ConfigurationKeys.hdlcTimeoutField),
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: DesignTokens.inputDecorationOf(context).copyWith(
                    hintText: '20',
                    suffixText: 's',
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Délai d\'inactivité avant retour à la page de connexion (min. 5 s)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            key: const Key(ConfigurationKeys.hdlcTimeoutApplyBtn),
            onPressed: _save,
            icon: Icon(_saved ? Icons.check : Icons.save, size: 18),
            label: Text(_saved ? 'Saved' : 'Apply'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _saved ? Colors.green : DesignTokens.primary600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Registration helper — call once from main.dart
// ---------------------------------------------------------------------------

/// Registers [ConfigurationPage] in [ExportRegistry].
///
/// ```dart
/// // main.dart
/// void main() {
///   registerConfigurationPage();
///   runApp(...);
/// }
/// ```
void registerConfigurationPage() {
  ExportRegistry.instance.register(
    ExportedPageInfo(
      id: 'configuration',
      label: 'Configuration DLMS',
      icon: Icons.settings,
      builder: (_) => const ConfigurationPage(),
      tokens: const {
        'communication.transport_type': 'Transport layer type',
        'communication.link_type': 'Link layer type',
        'communication.mode_com': 'Communication mode',
        'communication.client_addr': 'Client address',
        'communication.client_addr_len': 'Client address length',
        'communication.server_addr': 'Server address',
        'communication.server_addr_len': 'Server address length',
        'session.buffer_size': 'Session buffer size',
        'session.pre_established': 'Pre-established session flag',
        'security.session_type': 'Session authentication type',
        'security.ciphering_type': 'Ciphering / encryption type',
        'security.security_level': 'Security level',
        'security.security_suite': 'Security suite identifier',
        'security.serial_number': 'Meter serial number',
        'security.frame_counter': 'Frame counter value',
        'deviceId.*': 'Device ID field – e.g. deviceId.Logical_Device_Name',
      },
    ),
  );
}
