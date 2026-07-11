import 'package:flutter/material.dart';
import '../core/user_rights.dart';
import '../features/pages/connexion_page.dart';
import '../features/pages/ct_vt_management_page.dart' show CtVtManagementPage;
import '../features/pages/date_time_page.dart';
import '../features/pages/meter_connexion_page.dart';
import '../features/pages/firmware_download_page.dart';
import '../features/pages/super_manual_tool_page.dart';
import '../features/pages/dlms_translator_page.dart';
import '../features/pages/configuration_page.dart';
import '../features/pages/calendar_profiles_page.dart';
import '../features/pages/event_logs_page.dart';
import '../features/pages/fresnel_diagram_page.dart';
import '../features/pages/load_profile_page.dart';
import '../features/pages/load_profile_status_page.dart';
import '../features/pages/quality_page.dart';
import '../features/load_profile/load_profile_config.dart';
import '../features/load_profile/load_profile_service.dart';
import '../features/quality/quality_config.dart';
import '../features/quality/quality_service.dart';
import '../features/event_logs/event_logs_config.dart';
import '../features/event_logs/event_logs_service.dart';
import '../features/pages/device_id_page.dart';
import '../core/widgets/app_shell.dart';
import '../features/pages/firmware_version_page.dart';
import '../features/pages/energy_register_page.dart';
import '../features/pages/average_page.dart';
import '../features/pages/template_config_page.dart';
import '../features/pages/push_setup_page.dart';
import '../features/pages/push_action_page.dart';
import '../features/push_setups/push_setups_config.dart';
import '../features/push_setups/push_setups_service.dart';
import '../features/push_setups/push_actions_config.dart';
import '../features/push_setups/push_actions_service.dart';
import '../features/pages/script_table_page.dart';
import '../features/pages/push_selective_page.dart';
import '../features/pages/push_recovery_page.dart';
import '../features/push_setups/script_table_config.dart';
import '../features/push_setups/script_table_service.dart';
import '../features/push_setups/push_selective_config.dart';
import '../features/push_setups/push_selective_service.dart';
import '../features/push_setups/push_recovery_config.dart';
import '../features/push_setups/push_recovery_service.dart';
import '../features/pages/sim_config_page.dart';
import '../features/pages/push_setup_server_page.dart';
import '../features/pages/modem_config_page.dart';
import '../features/pages/mobile_network_id_page.dart';
import '../features/pages/manual_dlms_page.dart';


class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const connexion = '/connexion';
  static const meterConnexion = '/meter_connexion';
  static const firmware = '/firmware';
  static const superManual = '/super_manual';
  static const guruxTranslator = '/gurux_translator';
  static const configuration = '/configuration';
  static const calendarProfiles = '/calendar_profiles';
  static const dateTime = '/date_time';
  static const fresnelDiagram = '/fresnel_diagram';
  static const loadProfileBase = '/load_profile';
  static const qualityBase = '/quality_cfg';
  static const eventLogsBase = '/event_logs_cfg';
  static const pushSetupBase = '/push_setup';
  static const pushActionBase = '/push_action';
  static const scriptTableBase = '/script_table';
  static const pushSelectiveBase = '/push_selective';
  static const pushRecoveryBase = '/push_recovery';
  static const identificationDeviceId = '/connection/identification/device-id';
  static const identificationFirmware =
      '/connection/identification/firmware-version';
  static const energyRegister = '/electricity-objects/energy-register';
  static const average = '/electricity-objects/average';
  static const templateConfig = '/template_config';
  static const simConfig = '/p2p-setup/sim-config';
  static const pushSetupServer = '/push_setup_server';
  static const modemConfig = '/p2p-setup/modem-config';
  static const mobileNetworkId = '/p2p-setup/mobile-network-id';
  static const manualDlms = '/manual_dlms';
  static const ctvtManagement = '/electricity-objects/ct_vt_management';

  static Map<String, WidgetBuilder> routes = {
    connexion: (context) => const ConnexionPage(),
    meterConnexion: (context) => AppShell(child: const MeterConnexionPage()),
    firmware: (context) => AppShell(child: const FirmwareDownloadPage()),
    superManual: (context) => AppShell(child: const SuperManualToolPage()),
    guruxTranslator: (context) => AppShell(child: const DlmsTranslatorPage()),
    configuration: (context) => AppShell(child: const ConfigurationPage()),
    calendarProfiles: (context) =>
        AppShell(child: const CalendarProfilesPage()),
    dateTime: (context) => AppShell(child: const DateTimePage()),
    fresnelDiagram: (context) => AppShell(child: const FresnelDiagramPage()),
    identificationDeviceId: (context) => AppShell(child: const DeviceIdPage()),
    identificationFirmware: (context) =>
        AppShell(child: const FirmwareVersionPage()),
    energyRegister: (context) => AppShell(child: const EnergyRegisterPage()),
    average: (context) => AppShell(child: const AveragePage()),
    templateConfig: (context) => AppShell(child: const TemplateConfigPage()),
    simConfig: (context) => AppShell(child: const SimConfigPage()),
    pushSetupServer: (context) => AppShell(child: const PushSetupServerPage()),
    modemConfig: (context) => AppShell(child: const ModemConfigPage()),
    mobileNetworkId: (context) => AppShell(child: const MobileNetworkIdPage()),
    manualDlms: (context) => AppShell(child: const ManualDlmsPage()),
    ctvtManagement: (context) => AppShell(child: const CtVtManagementPage()),
  };

  /// Generate route for load profile pages dynamically
  static String loadProfileRoute(String profileId) =>
      '$loadProfileBase/$profileId';

  /// Generate route for configurable quality pages dynamically
  static String qualityRoute(String qualityId) => '$qualityBase/$qualityId';

  /// Generate route for configurable event logs pages dynamically
  static String eventLogsRoute(String logId) => '$eventLogsBase/$logId';

  /// Generate route for push setup pages dynamically
  static String pushSetupRoute(String setupId) => '$pushSetupBase/$setupId';

  /// Generate route for push action pages dynamically
  static String pushActionRoute(String actionId) => '$pushActionBase/$actionId';

  /// Generate route for script table pages dynamically
  static String scriptTableRoute(String tableId) => '$scriptTableBase/$tableId';

  /// Generate route for push selective pages dynamically
  static String pushSelectiveRoute(String selectiveId) =>
      '$pushSelectiveBase/$selectiveId';

  /// Generate route for push recovery pages dynamically
  static String pushRecoveryRoute(String recoveryId) =>
      '$pushRecoveryBase/$recoveryId';

  /// Map routes to their feature key — if the feature is disabled, the route
  /// is blocked and the user is redirected to the home page.
  static const Map<String, String> _routeFeatureMap = {
    firmware: 'FW_Update',
    identificationDeviceId: 'Device_ID',
    identificationFirmware: 'FW_Version',
    dateTime: 'clock',
    calendarProfiles: 'Activity_Calendar',
    energyRegister: 'Energy_Register',
    average: 'Average',
    fresnelDiagram: 'Fresnel',
    simConfig: 'SIM_Config',
    superManual: 'super_manual',
    mobileNetworkId: 'Mobile_Network_Id',
    guruxTranslator: 'DLMS_Translator',
    templateConfig: 'Export_Templates',
    ctvtManagement: 'CT_VT_Management',
  };

  /// Handle dynamic load profile routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Auth guard: redirect to /connexion if not authenticated
    if (settings.name != connexion && userRights.role.isEmpty) {
      return MaterialPageRoute(
        builder: (context) => const ConnexionPage(),
        settings: const RouteSettings(name: connexion),
      );
    }

    // Feature guard: redirect to home if the feature is disabled by license
    final featureKey = _routeFeatureMap[settings.name];
    if (featureKey != null && userRights.isFeatureDisabled(featureKey)) {
      return MaterialPageRoute(
        builder: (context) => const MeterConnexionPage(),
        settings: const RouteSettings(name: meterConnexion),
      );
    }

    // Handle load profile routes
    if (settings.name?.startsWith(loadProfileBase) ?? false) {
      if (userRights.isFeatureDisabled('Load_Profile')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final profileId =
          settings.name?.replaceFirst('$loadProfileBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _LoadProfileRouteBuilder(profileId: profileId)),
        settings: settings,
      );
    }

    // Handle configurable event logs routes
    if (settings.name?.startsWith(eventLogsBase) ?? false) {
      if (userRights.isFeatureDisabled('Event_Logs')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final logId = settings.name?.replaceFirst('$eventLogsBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _EventLogsRouteBuilder(logId: logId)),
        settings: settings,
      );
    }

    // Handle configurable quality routes
    if (settings.name?.startsWith(qualityBase) ?? false) {
      final qualityId = settings.name?.replaceFirst('$qualityBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _QualityRouteBuilder(qualityId: qualityId)),
        settings: settings,
      );
    }

    // Handle push setup routes
    if (settings.name?.startsWith(pushSetupBase) ?? false) {
      if (userRights.isFeatureDisabled('Push_Setups')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final setupId = settings.name?.replaceFirst('$pushSetupBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _PushSetupRouteBuilder(setupId: setupId)),
        settings: settings,
      );
    }

    // Handle push action routes
    if (settings.name?.startsWith(pushActionBase) ?? false) {
      if (userRights.isFeatureDisabled('Push_Setups')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final actionId =
          settings.name?.replaceFirst('$pushActionBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _PushActionRouteBuilder(actionId: actionId)),
        settings: settings,
      );
    }

    // Handle script table routes
    if (settings.name?.startsWith(scriptTableBase) ?? false) {
      if (userRights.isFeatureDisabled('Script_Tables')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final tableId =
          settings.name?.replaceFirst('$scriptTableBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _ScriptTableRouteBuilder(tableId: tableId)),
        settings: settings,
      );
    }

    // Handle push selective routes
    if (settings.name?.startsWith(pushSelectiveBase) ?? false) {
      if (userRights.isFeatureDisabled('Push_Selective')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final selectiveId =
          settings.name?.replaceFirst('$pushSelectiveBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) => AppShell(
            child: _PushSelectiveRouteBuilder(selectiveId: selectiveId)),
        settings: settings,
      );
    }

    // Handle push recovery routes
    if (settings.name?.startsWith(pushRecoveryBase) ?? false) {
      if (userRights.isFeatureDisabled('Push_Recovery')) {
        return MaterialPageRoute(
          builder: (context) => const MeterConnexionPage(),
          settings: const RouteSettings(name: meterConnexion),
        );
      }
      final recoveryId =
          settings.name?.replaceFirst('$pushRecoveryBase/', '') ?? '';
      return MaterialPageRoute(
        builder: (context) =>
            AppShell(child: _PushRecoveryRouteBuilder(recoveryId: recoveryId)),
        settings: settings,
      );
    }

    return null;
  }
}

/// Widget builder for configurable quality pages that loads config asynchronously
class _QualityRouteBuilder extends StatefulWidget {
  final String qualityId;

  const _QualityRouteBuilder({required this.qualityId});

  @override
  State<_QualityRouteBuilder> createState() => _QualityRouteBuilderState();
}

class _QualityRouteBuilderState extends State<_QualityRouteBuilder> {
  QualityConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final pages = await QualityService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <QualityConfig>[],
      );

      QualityConfig? config;
      for (final p in pages) {
        if (p.id == widget.qualityId) {
          config = p;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Quality configuration not found'),
        ),
      );
    }

    return QualityPage(config: _config!);
  }
}

/// Widget builder for load profile pages that loads config asynchronously
class _LoadProfileRouteBuilder extends StatefulWidget {
  final String profileId;

  const _LoadProfileRouteBuilder({required this.profileId});

  @override
  State<_LoadProfileRouteBuilder> createState() =>
      _LoadProfileRouteBuilderState();
}

class _LoadProfileRouteBuilderState extends State<_LoadProfileRouteBuilder> {
  LoadProfileConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final profiles = await LoadProfileService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <LoadProfileConfig>[],
      );

      LoadProfileConfig? config;
      for (final p in profiles) {
        if (p.id == widget.profileId) {
          config = p;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Load profile not found'),
        ),
      );
    }

    // Route to the status page when bitDescription is configured,
    // otherwise use the standard load profile table page.
    if (_config!.bitDescription != null) {
      return LoadProfileStatusPage(config: _config!);
    }
    return LoadProfilePage(config: _config!);
  }
}

/// Widget builder for configurable event logs pages that loads config asynchronously
class _EventLogsRouteBuilder extends StatefulWidget {
  final String logId;

  const _EventLogsRouteBuilder({required this.logId});

  @override
  State<_EventLogsRouteBuilder> createState() => _EventLogsRouteBuilderState();
}

class _EventLogsRouteBuilderState extends State<_EventLogsRouteBuilder> {
  EventLogsConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final logs = await EventLogsService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <EventLogsConfig>[],
      );

      EventLogsConfig? config;
      for (final p in logs) {
        if (p.id == widget.logId) {
          config = p;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Event log configuration not found'),
        ),
      );
    }

    return EventLogsPage(config: _config!);
  }
}

/// Widget builder for push setup pages that loads config asynchronously
class _PushSetupRouteBuilder extends StatefulWidget {
  final String setupId;

  const _PushSetupRouteBuilder({required this.setupId});

  @override
  State<_PushSetupRouteBuilder> createState() => _PushSetupRouteBuilderState();
}

class _PushSetupRouteBuilderState extends State<_PushSetupRouteBuilder> {
  PushSetupConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final setups = await PushSetupsService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <PushSetupConfig>[],
      );

      PushSetupConfig? config;
      for (final s in setups) {
        if (s.id == widget.setupId) {
          config = s;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Push setup configuration not found'),
        ),
      );
    }

    return PushSetupPage(config: _config!);
  }
}

/// Widget builder for push action pages that loads config asynchronously
class _PushActionRouteBuilder extends StatefulWidget {
  final String actionId;

  const _PushActionRouteBuilder({required this.actionId});

  @override
  State<_PushActionRouteBuilder> createState() =>
      _PushActionRouteBuilderState();
}

class _PushActionRouteBuilderState extends State<_PushActionRouteBuilder> {
  PushActionConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final actions = await PushActionsService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <PushActionConfig>[],
      );

      PushActionConfig? config;
      for (final a in actions) {
        if (a.id == widget.actionId) {
          config = a;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Push action configuration not found'),
        ),
      );
    }

    return PushActionPage(config: _config!);
  }
}

/// Widget builder for script table pages that loads config asynchronously
class _ScriptTableRouteBuilder extends StatefulWidget {
  final String tableId;

  const _ScriptTableRouteBuilder({required this.tableId});

  @override
  State<_ScriptTableRouteBuilder> createState() =>
      _ScriptTableRouteBuilderState();
}

class _ScriptTableRouteBuilderState extends State<_ScriptTableRouteBuilder> {
  ScriptTableConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final tables = await ScriptTableService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <ScriptTableConfig>[],
      );

      ScriptTableConfig? config;
      for (final t in tables) {
        if (t.id == widget.tableId) {
          config = t;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Script table configuration not found')),
      );
    }
    return ScriptTablePage(config: _config!);
  }
}

/// Widget builder for push selective pages that loads config asynchronously
class _PushSelectiveRouteBuilder extends StatefulWidget {
  final String selectiveId;
  const _PushSelectiveRouteBuilder({required this.selectiveId});

  @override
  State<_PushSelectiveRouteBuilder> createState() =>
      _PushSelectiveRouteBuilderState();
}

class _PushSelectiveRouteBuilderState
    extends State<_PushSelectiveRouteBuilder> {
  PushSelectiveConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final selectives = await PushSelectiveService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <PushSelectiveConfig>[],
      );
      PushSelectiveConfig? config;
      for (final s in selectives) {
        if (s.id == widget.selectiveId) {
          config = s;
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body:
            const Center(child: Text('Push selective configuration not found')),
      );
    }
    return PushSelectivePage(config: _config!);
  }
}

/// Widget builder for push recovery pages that loads config asynchronously
class _PushRecoveryRouteBuilder extends StatefulWidget {
  final String recoveryId;
  const _PushRecoveryRouteBuilder({required this.recoveryId});

  @override
  State<_PushRecoveryRouteBuilder> createState() =>
      _PushRecoveryRouteBuilderState();
}

class _PushRecoveryRouteBuilderState extends State<_PushRecoveryRouteBuilder> {
  PushRecoveryConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final recoveries = await PushRecoveryService.loadConfig().timeout(
        const Duration(seconds: 3),
        onTimeout: () => <PushRecoveryConfig>[],
      );
      PushRecoveryConfig? config;
      for (final r in recoveries) {
        if (r.id == widget.recoveryId) {
          config = r;
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (_) {
      // coverage:ignore-start
      if (!mounted) return;
      setState(() {
        _config = null;
        _isLoading = false;
      });
    } // coverage:ignore-end
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body:
            const Center(child: Text('Push recovery configuration not found')),
      );
    }
    return PushRecoveryPage(config: _config!);
  }
}
