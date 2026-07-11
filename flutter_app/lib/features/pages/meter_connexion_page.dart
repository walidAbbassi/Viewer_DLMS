import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/obis_widget.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/widgets/app_bottom_toolbar.dart';
import '../../grpc/generated/configuration.pb.dart' show ConfigEntry;
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/generated/meter.pbgrpc.dart';
import 'package:lottie/lottie.dart';
import '../../routes/app_routes.dart';
import '../../util/any_value_decoder.dart';
import '../../grpc/configuration_client.dart';
import '../../core/theme/design_tokens.dart';
import '../../state/app_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;

import '../../util/dart_to_any.dart';
import '../../core/widget_keys.dart';

typedef MeterConnexionConfigClientFactory = IConfigurationClient Function();
MeterConnexionConfigClientFactory _meterConnexionConfigClientFactory =
    // coverage:ignore-next-line
    () => ConfigurationClient();
@visibleForTesting
set meterConnexionConfigClientFactory(MeterConnexionConfigClientFactory v) {
  _meterConnexionConfigClientFactory = v;
}

class MeterConnexionPage extends ConsumerStatefulWidget {
  const MeterConnexionPage({super.key});

  @override
  ConsumerState<MeterConnexionPage> createState() => _MeterConnexionPageState();
}

class _MeterConnexionPageState extends ConsumerState<MeterConnexionPage> {
  List<ObisWidgetData> widgetsData = [];
  late IMeterClient client;
  String _dlmsClient = 'Public';
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _hex = false;
  late IConfigurationClient configClient;
  bool isExecuting = false;
  final headers = ["Index", "Request", "Result"];
  Map<String, String> loaders = {
    "connecting": "assets/animations/connecting.json",
    "disconnecting": "assets/animations/disconnecting.json",
    "data": "assets/animations/data.json",
    "sablier": "assets/animations/sablier.json",
  };
  String loader = "";
  String _animationText = "";
  List<List<String>> values = List<List<String>>.empty(growable: true);
  // connection states
  bool isConnected = false;
  bool isConnecting = false;

  List<String> _modules = [];
  List<String> _datamodels = [];
  String? _module;
  String? _datamodel;

  @override
  void initState() {
    super.initState();
    client = meterClientFactory();
    configClient = _meterConnexionConfigClientFactory();
    widgetsData.add(ObisWidgetData());
    isConnected = ref.read(appControllerProvider).isConnected;
    _module = ref.read(appControllerProvider).moduleName;
    _datamodel = ref.read(appControllerProvider).datamodel;
    _listModules(); // start with one widget
    _listDatamodels();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();

    super.dispose();
  }

  static const _keyLastModule = 'last_dlms_association';

  Future<void> _listModules() async {
    _modules.clear();
    final modules = await configClient.listModules();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyLastModule);
    setState(() {
      _modules = modules;
      if (modules.isNotEmpty &&
          (_module == null || !modules.contains(_module))) {
        _module =
            (saved != null && modules.contains(saved)) ? saved : modules.first;
        ref.read(appControllerProvider.notifier).setModuleName(_module);
      }
    });
  }

  Future<void> _listDatamodels() async {
    _datamodels.clear();
    final datamodels = await client.getDatamodels();
    setState(() {
      _datamodels = datamodels;
      if (datamodels.isNotEmpty &&
          (_datamodel == null || !datamodels.contains(_datamodel))) {
        _datamodel = datamodels.first;
        ref.read(appControllerProvider.notifier).setDatamodel(_datamodel);
      }
    });
  }

  void _showResultSnackBar(
      BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: Duration(seconds: isSuccess ? 3 : 8),
        ),
      );
  }

  // â”€â”€ Left column cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildConnectionSetupCard() {
    return _card(
      icon: Icons.settings_input_component,
      title: 'Connection Setup',
      children: [
        _fieldLabel('Product Dictionary'),
        DropdownButtonFormField<String>(
          key: const Key(MeterConnexionKeys.datamodelDropdown),
          value: _datamodel,
          items: _datamodels
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() => _datamodel = v!);
            ref.read(appControllerProvider.notifier).setDatamodel(_datamodel);
          },
          decoration: DesignTokens.inputDecoration(
                  isDark: Theme.of(context).brightness == Brightness.dark)
              .copyWith(
            prefixIcon: Icon(Icons.menu,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : DesignTokens.primary600),
          ),
        ),
        const SizedBox(height: 20),
        _fieldLabel('DLMS Association'),
        DropdownButtonFormField<String>(
          key: const Key(MeterConnexionKeys.moduleDropdown),
          value: _module,
          hint: const Text('Select association...'),
          items: _modules
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) async {
            setState(() => _module = v!);
            ref.read(appControllerProvider.notifier).setModuleName(_module);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_keyLastModule, _module!);
          },
          decoration: DesignTokens.inputDecoration(
                  isDark: Theme.of(context).brightness == Brightness.dark)
              .copyWith(
            prefixIcon: Icon(Icons.account_tree,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : DesignTokens.primary600),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticationCard() {
    return _card(
      icon: Icons.lock_outline,
      title: 'Authentication',
      children: [
        _fieldLabel('Password'),
        TextField(
          key: const Key(MeterConnexionKeys.passwordField),
          controller: _passwordCtrl,
          obscureText: true,
          decoration: DesignTokens.inputDecoration(
                  hint: 'Enter password',
                  isDark: Theme.of(context).brightness == Brightness.dark)
              .copyWith(
            prefixIcon: Icon(Icons.vpn_key,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : DesignTokens.primary600),
          ),
        ),
        const SizedBox(height: 12),
        _checkbox('Hexadecimal format', _hex, (v) => setState(() => _hex = v),
            checkboxKey: const Key(MeterConnexionKeys.hexFormatChk)),
      ],
    );
  }

  Widget _buildSimulationCard() {
    final simulation = ref.watch(appControllerProvider).simulation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _card(
      icon: Icons.warning_amber_rounded,
      title: 'Simulation Mode',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Enable simulation',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : DesignTokens.textPrimary)),
            Switch(
              key: const Key(MeterConnexionKeys.simulationSwitch),
              value: simulation,
              activeColor:
                  isDark ? const Color(0xFF60A5FA) : DesignTokens.primary600,
              onChanged: (v) {
                ref.read(appControllerProvider.notifier).setSimulation(v);
              },
            ),
          ],
        ),
        if (simulation) ...[
          const SizedBox(height: 12),
          _fieldLabel('Simulation file'),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : DesignTokens.gray300),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? const Color(0xFF1e293b) : Colors.white,
                  ),
                  child: Text(
                    ref.watch(appControllerProvider).simulationFile ??
                        'No file selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: ref.watch(appControllerProvider).simulationFile !=
                              null
                          ? (isDark
                              ? const Color(0xFFF1F5F9)
                              : DesignTokens.textPrimary)
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : DesignTokens.textSecondary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key(MeterConnexionKeys.simulationBrowseBtn),
                onPressed: _selectSimulationFile,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Browse'),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: DesignTokens.primary600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // â”€â”€ Right column panels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildMeterStatusPanel() {
    final connected = isConnected;
    final startColor =
        connected ? const Color(0xFF1B5E20) : const Color(0xFF7F0000);
    final endColor =
        connected ? const Color(0xFF388E3C) : const Color(0xFFB00020);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('Meter Status',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                connected ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 52,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    connected ? 'Communication active' : 'No active connection',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionInfoPanel() {
    final simulation = ref.watch(appControllerProvider).simulation;
    return _card(
      icon: Icons.info_outline,
      title: 'Connection Info',
      children: [
        _infoRow(Icons.menu, 'Data Model', _datamodel ?? '-'),
        const Divider(height: 1),
        _infoRow(Icons.account_tree, 'Association', _module ?? '-'),
        const Divider(height: 1),
        _infoRow(Icons.warning_amber_rounded, 'Simulation',
            simulation ? 'Enabled' : 'Disabled'),
      ],
    );
  }

  Widget _buildActionsPanel() {
    return _card(
      icon: Icons.bolt,
      title: 'Actions',
      children: [
        Row(
          children: [
            Expanded(
              child: isConnected
                  ? ElevatedButton.icon(
                      key: const Key(MeterConnexionKeys.disconnectBtn),
                      onPressed: () => _handleConnection(),
                      icon: const Icon(Icons.power_off, size: 20),
                      label: const Text('Disconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ElevatedButton.icon(
                      key: const Key(MeterConnexionKeys.connectBtn),
                      onPressed: () => _handleConnection(),
                      icon: const Icon(Icons.power, size: 20),
                      label: const Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key(MeterConnexionKeys.configurationBtn),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.configuration),
                icon: const Icon(Icons.settings, size: 20),
                label: const Text('Configuration'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : DesignTokens.success,
                  side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : DesignTokens.success,
                      width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // â”€â”€ Shared helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _card(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : DesignTokens.surface,
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : DesignTokens.gray200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Icon(icon,
                    size: 22,
                    color: isDark
                        ? const Color(0xFF60A5FA)
                        : DesignTokens.primary600),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFF1F5F9)
                            : DesignTokens.textPrimary)),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : DesignTokens.gray200),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isDark ? const Color(0xFF94A3B8) : DesignTokens.gray600),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : DesignTokens.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : DesignTokens.textPrimary)),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : DesignTokens.textSecondary)),
    );
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool> onChanged,
      {Key? checkboxKey}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(children: [
        Checkbox(
          key: checkboxKey,
          value: value,
          onChanged: (v) => onChanged(v!),
          activeColor:
              isDark ? const Color(0xFF60A5FA) : DesignTokens.primary600,
        ),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : DesignTokens.textSecondary)),
      ]),
    );
  }

  // coverage:ignore-start
  Widget _widgetItem(int index) {
    return ObisWidget(
      data: widgetsData[index],
      onDelete: widgetsData.length > 1
          ? () => setState(() => widgetsData.removeAt(index))
          : null,
    );
  }
  // coverage:ignore-end

  // coverage:ignore-start
  void _onRead() {
    final simulation = ref.read(appControllerProvider).simulation;
    final simulationFile = ref.read(appControllerProvider).simulationFile;
    debugPrint(
        'Read client=$_dlmsClient password=${_hex ? _toHex(_passwordCtrl.text) : 'â€¢â€¢â€¢â€¢'} simulation=$simulation file=$simulationFile');
  }
  // coverage:ignore-end

  Future<void> _selectSimulationFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      // coverage:ignore-start
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        ref
            .read(appControllerProvider.notifier)
            .setSimulationFile(file.path ?? file.name);
      }
      // coverage:ignore-end
      // coverage:ignore-start
    } catch (e) {
      _showResultSnackBar(context, 'Error while selecting file', false);
    }
    // coverage:ignore-end
  }

  // coverage:ignore-next-line
  String _toHex(String s) =>
      s.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0f172a) : DesignTokens.background,
      appBar: AppBar(
        title: const Text("Meter Connection"),
        backgroundColor:
            isDark ? const Color(0xFF1e3a6e) : DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          RefreshAppBarButton(
              key: const Key(MeterConnexionKeys.refreshBtn),
              onPressed: () => setState(() {}), checkConnection: false),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column â€” form cards
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        _buildConnectionSetupCard(),
                        _buildAuthenticationCard(),
                        _buildSimulationCard(),
                      ],
                    ),
                  ),
                ),
                // Right column â€” status panels
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMeterStatusPanel(),
                        const SizedBox(height: 16),
                        _buildConnectionInfoPanel(),
                        const SizedBox(height: 16),
                        _buildActionsPanel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loader != "")
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          loaders[loader]!,
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _animationText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> executeAll() async {
    // Validate inputs
    for (var i = 0; i < widgetsData.length; i++) {
      final data = widgetsData[i];
      if (data.classController.text.isEmpty ||
          data.obisController.text.isEmpty ||
          data.attributeController.text.isEmpty) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text("Please fill all fields in widget ${i + 1}"),
              backgroundColor: Colors.red,
            ),
          );
        return;
      }
    }

    final requests = widgetsData.map((data) {
      return GetRequest()
        ..class_1 = int.parse(data.classController.text)
        ..obiscode = data.obisController.text
        ..attribute = int.parse(data.attributeController.text);
    }).toList();
    setState(() {
      loader = "data";
      isExecuting = true;
    });
    final new_values = List<List<String>>.empty(growable: true);
    try {
      final responses = await client.executeAdvancedGet(requests, true);
      var index = 0;
      for (final response in responses) {
        final value = List<String>.empty(growable: true);
        index++;
        value.add(index.toString());
        value.add(response.request.toString());
        value.add(AnyValueDecoder.fromAny(response.value).toString());
        new_values.add(value);
      }
      setState(() {
        values = new_values;
      });
    } catch (e) {
      _showResultSnackBar(context, _extractErrorMessage(e), false);
    } finally {
      setState(() {
        loader = "";
        isExecuting = false;
      });
    }
  }

  Future<void> _handleConnection() async {
    if (_module == null || _datamodel == null) {
      _showResultSnackBar(
          context, "Please select an association and a data model", false);
      return;
    }
    setState(() {
      isConnecting = true;
      _animationText = "";
      if (!isConnected) {
        loader = "connecting";
      } else {
        loader = "disconnecting";
      }
    });
    final simulation = ref.read(appControllerProvider).simulation;
    final simulationFile = ref.read(appControllerProvider).simulationFile;
    final entries = <ConfigEntry>[];
    entries.add(ConfigEntry()
      ..module = "Public"
      ..key = "simulation.enabled"
      ..value = dartToAny(simulation));
    if (simulation && simulationFile != null)
      entries.add(ConfigEntry()
        ..module = "Public"
        ..key = "simulation.path"
        ..value = dartToAny(simulationFile));
    await configClient.setConfig(entries, false);
    if (!isConnected) {
      try {
        await client.initMeterContext(_module!);
        final success = await client.connect();
        ref.read(appControllerProvider.notifier).setIsConnected(success);
        setState(() {
          isConnected = success;
        });
        if (!success) {
          setState(() {
            loader = "";
            isConnecting = false;
          });
          _showResultSnackBar(context, "Not connected", false);
          return; //bloquer la navigation
        }
        setState(() {
          _animationText = "Loading data model";
          loader = "sablier";
        });

        try {
          final success = await client.loadDatamodel(_datamodel!);
          if (!success) {
            throw GrpcError.unknown('Failed to load data model');
          }
          await client.getDatamodelObjects();
          Navigator.pushReplacementNamed(
              context, AppRoutes.identificationDeviceId);
        } catch (e) {
          _showResultSnackBar(context, _extractErrorMessage(e), false);
        } finally {
          setState(() {
            loader = "";
            _animationText = "";
            isConnecting = false;
          });
        }
      } catch (e) {
        setState(() {
          loader = "";
          isConnecting = false;
        });
        _showResultSnackBar(context, _extractErrorMessage(e), false);
        return;
      }
    } else {
      try {
        final success = await client.disconnect();
        setState(() {
          isConnected = !success;
        });
        ref.read(appControllerProvider.notifier).setIsConnected(!success);
      } catch (e) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      } finally {
        setState(() {
          loader = "";
          isConnecting = false;
        });
      }
    }
  }

  /// Extracts a human-readable message from a gRPC/other exception.
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

  // coverage:ignore-start
  Widget _selectField(String label, List<String> options,
      {String? value, ValueChanged<String?>? onChanged}) {
    return _labeled(
      label,
      DropdownButtonFormField<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: DesignTokens.inputDecoration(
            hint: "Select Option",
            isDark: Theme.of(context).brightness == Brightness.dark),
      ),
    );
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
  // coverage:ignore-end
}

