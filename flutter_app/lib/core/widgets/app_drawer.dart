import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../../state/app_controller.dart';
import '../../core/navigation/app_route_observer.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../routes/app_routes.dart';
import '../../features/services/auth_provider.dart';
import '../../features/load_profile/load_profile_config.dart';
import '../../features/load_profile/load_profile_service.dart';
import '../../features/event_logs/event_logs_config.dart';
import '../../features/event_logs/event_logs_service.dart';
import '../../features/quality/quality_config.dart';
import '../../features/quality/quality_service.dart';
import '../../features/push_setups/push_setups_config.dart';
import '../../features/push_setups/push_setups_service.dart';
import '../../features/push_setups/push_actions_config.dart';
import '../../features/push_setups/push_actions_service.dart';
import '../../features/push_setups/script_table_config.dart';
import '../../features/push_setups/script_table_service.dart';
import '../../features/push_setups/push_selective_config.dart';
import '../../features/push_setups/push_selective_service.dart';
import '../../features/push_setups/push_recovery_config.dart';
import '../../features/push_setups/push_recovery_service.dart';

/// Permanent side-navigation panel (used by [AppShell]).
class AppSideNav extends ConsumerStatefulWidget {
  const AppSideNav({this.onToggle, this.isCollapsed = false, super.key});

  /// Called when the user presses the toggle button.
  final VoidCallback? onToggle;

  /// When true the panel renders as a narrow icon rail.
  final bool isCollapsed;

  @override
  ConsumerState<AppSideNav> createState() => _AppSideNavState();
}

/// Legacy drawer wrapper – kept so existing tests that use
/// `drawer: const AppDrawer()` continue to compile unchanged.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: AppSideNav());
  }
}

class _AppSideNavState extends ConsumerState<AppSideNav> {
  // Persists scroll offset and category expanded state across route replacements
  // (pushReplacementNamed destroys and recreates the state each time).
  static double _savedScrollOffset = 0.0;

  final TextEditingController _filterController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _filterText = '';
  String? _currentRoute;
  List<LoadProfileConfig> _loadProfiles = [];
  bool _loadProfilesLoaded = false;
  List<EventLogsConfig> _eventLogsConfigs = [];
  bool _eventLogsLoaded = false;
  List<QualityConfig> _qualityConfigs = [];
  bool _qualityLoaded = false;
  List<PushSetupConfig> _pushSetupConfigs = [];
  bool _pushSetupsLoaded = false;
  List<PushActionConfig> _pushActionConfigs = [];
  bool _pushActionsLoaded = false;
  List<ScriptTableConfig> _scriptTableConfigs = [];
  bool _scriptTablesLoaded = false;
  List<PushSelectiveConfig> _pushSelectiveConfigs = [];
  bool _pushSelectivesLoaded = false;
  List<PushRecoveryConfig> _pushRecoveryConfigs = [];
  bool _pushRecoveriesLoaded = false;
  static final Map<String, bool> _categoryExpanded = {};

  void _onRouteChanged() {
    if (!mounted) return;
    final newRoute = currentRouteNotifier.value;
    setState(() => _currentRoute = newRoute);
    // When returning to meter connexion (e.g. after disconnect), always scroll
    // back to the top so the "Meter Connection" item is visible.
    if (newRoute == AppRoutes.meterConnexion) {
      _savedScrollOffset = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentRoute = currentRouteNotifier.value;
    currentRouteNotifier.addListener(_onRouteChanged);
    // Set defaults for any category not yet in the map (putIfAbsent so
    // user-toggled categories keep their state across hot restarts).
    _categoryExpanded.putIfAbsent('Identification', () => true);
    _categoryExpanded.putIfAbsent('Push Setups', () => true);
    _categoryExpanded.putIfAbsent('Quality', () => true);
    _categoryExpanded.putIfAbsent('Script Tables', () => true);
    _categoryExpanded.putIfAbsent('Push Selective', () => true);
    _categoryExpanded.putIfAbsent('Push Recovery', () => true);
    // Always expand Push Selective so newly-added config entries are visible.
    _categoryExpanded['Push Selective'] = true;
    _loadLoadProfiles();
    _loadEventLogs();
    _loadQualityConfigs();
    _loadPushSetups();
    _loadPushActions();
    _loadScriptTables();
    _loadPushSelectives();
    _loadPushRecoveries();
    // Restore scroll position after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _savedScrollOffset > 0) {
        _scrollController.jumpTo(_savedScrollOffset);
      }
    });
  }

  @override
  void dispose() {
    currentRouteNotifier.removeListener(_onRouteChanged);
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLoadProfiles() async {
    final profiles = await LoadProfileService.loadConfig();
    if (mounted) {
      setState(() {
        _loadProfiles = profiles;
        _loadProfilesLoaded = true;
      });
    }
  }

  Future<void> _loadEventLogs() async {
    final logs = await EventLogsService.loadConfig();
    if (mounted) {
      setState(() {
        _eventLogsConfigs = logs;
        _eventLogsLoaded = true;
      });
    }
  }

  Future<void> _loadQualityConfigs() async {
    final pages = await QualityService.loadConfig();
    if (mounted) {
      setState(() {
        _qualityConfigs = pages;
        _qualityLoaded = true;
      });
    }
  }

  Future<void> _loadPushSetups() async {
    final setups = await PushSetupsService.loadConfig();
    if (mounted) {
      setState(() {
        _pushSetupConfigs = setups;
        _pushSetupsLoaded = true;
      });
    }
  }

  Future<void> _loadPushActions() async {
    final actions = await PushActionsService.loadConfig();
    if (mounted) {
      setState(() {
        _pushActionConfigs = actions;
        _pushActionsLoaded = true;
      });
    }
  }

  Future<void> _loadScriptTables() async {
    final configs = await ScriptTableService.loadConfig();
    if (mounted) {
      setState(() {
        _scriptTableConfigs = configs;
        _scriptTablesLoaded = true;
      });
    }
  }

  Future<void> _loadPushSelectives() async {
    final selectives = await PushSelectiveService.loadConfig();
    if (mounted) {
      setState(() {
        _pushSelectiveConfigs = selectives;
        _pushSelectivesLoaded = true;
      });
    }
  }

  Future<void> _loadPushRecoveries() async {
    final recoveries = await PushRecoveryService.loadConfig();
    if (mounted) {
      setState(() {
        _pushRecoveryConfigs = recoveries;
        _pushRecoveriesLoaded = true;
      });
    }
  }

  Widget _navCategory(String title, List<Widget> items) {
    final bool expanded = _categoryExpanded[title] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _categoryExpanded[title] = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    size: 16,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
          secondChild: const SizedBox(height: 2),
        ),
      ],
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label,
      {String route = "/meter_connexion",
      bool active = false,
      bool disabled = false}) {
    final keyId = 'nav_item_${route.replaceAll('/', '_').replaceAll('-', '_')}';
    return _HoverNavItem(
      key: Key(keyId),
      active: active,
      disabled: disabled,
      onTap: () {
        if (ref.read(appControllerProvider).isFirmwareDownloading) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Firmware Download in Progress'),
              content: const Text(
                'Navigation is disabled while a firmware download is running.\n'
                'Please wait for the transfer to complete or cancel it first.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
        if (ref.read(appControllerProvider).isMeterOperationInProgress) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Operation in Progress'),
              content: const Text(
                'A meter operation is currently in progress. Leaving this screen may interrupt the communication and cause data loss. Do you want to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_scrollController.hasClients) {
                      _savedScrollOffset = _scrollController.offset;
                    }
                    Navigator.pushReplacementNamed(context, route);
                  },
                  child: const Text('Leave Anyway'),
                ),
              ],
            ),
          );
          return;
        }
        if (_scrollController.hasClients) {
          _savedScrollOffset = _scrollController.offset;
        }
        Navigator.pushReplacementNamed(context, route);
      },
      icon: icon,
      label: label,
    );
  }

  // Primary gradient colour — kept as a local alias for readability in gradient stops.
  static const Color cPrimary600 = Color(0xFF1976D2);

  List<Map<String, dynamic>> get _allMenuItems {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.home,
        'label': 'Meter Connexion',
        'route': '/meter_connexion',
        'category': null,
        'feature': null
      },
      {
        'icon': Icons.badge_outlined,
        'label': 'Device ID',
        'route': '/connection/identification/device-id',
        'category': 'Identification',
        'feature': FeatureKeys.deviceId,
      },
      {
        'icon': Icons.memory,
        'label': 'Firmware Version',
        'route': '/connection/identification/firmware-version',
        'category': 'Identification',
        'feature': FeatureKeys.fwVersion,
      },
      {
        'icon': Icons.lock_clock,
        'label': 'Date time',
        'route': '/date_time',
        'category': 'Clock',
        'feature': FeatureKeys.clock,
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Activity Calendars',
        'route': '/calendar_profiles',
        'category': 'Tariff Management',
        'feature': FeatureKeys.activityCalendar,
      },
    ];

    // Load Profiles après Date time
    if (_loadProfilesLoaded && _loadProfiles.isNotEmpty) {
      for (final profile in _loadProfiles) {
        items.add({
          'icon': Icons.bar_chart,
          'label': profile.name,
          'route': AppRoutes.loadProfileRoute(profile.id),
          'category': 'Load Profiles',
          'feature': FeatureKeys.loadProfile,
        });
      }
    }

    // Event Logs après Load Profiles
    if (_eventLogsLoaded && _eventLogsConfigs.isNotEmpty) {
      for (final logCfg in _eventLogsConfigs) {
        items.add({
          'icon': Icons.event,
          'label': logCfg.name,
          'route': AppRoutes.eventLogsRoute(logCfg.id),
          'category': 'Event Logs',
          'feature': FeatureKeys.eventLogs,
        });
      }
    }

    // Quality pages after Event Logs
    if (_qualityLoaded && _qualityConfigs.isNotEmpty) {
      for (final page in _qualityConfigs) {
        items.add({
          'icon': Icons.tune,
          'label': page.name,
          'route': AppRoutes.qualityRoute(page.id),
          'category': 'Quality',
          'feature': null,
        });
      }
    }

    items.addAll([
      {
        'icon': Icons.electric_meter,
        'label': 'Energy Register',
        'route': '/electricity-objects/energy-register',
        'category': 'Electricity Objects',
        'feature': FeatureKeys.energyRegister,
      },
      {
        'icon': Icons.transform,
        'label': 'CT VT Management',
        'route': '/electricity-objects/ct_vt_management',
        'category': 'Electricity Objects',
        'feature': FeatureKeys.ctvtManagement,
      },
      {
        'icon': Icons.grain,
        'label': 'Instant',
        'route': '/fresnel_diagram',
        'category': 'Electricity Objects',
        'feature': FeatureKeys.fresnel,
      },
      {
        'icon': Icons.calculate,
        'label': 'Average',
        'route': '/electricity-objects/average',
        'category': 'Electricity Objects',
        'feature': FeatureKeys.average,
      },
      {
        'icon': Icons.cloud_download,
        'label': 'Firmware Download',
        'route': '/firmware',
        'category': 'Firmware Upgrade',
        'feature': 'FW_Update'
      },
      {
        'icon': Icons.sim_card,
        'label': 'SIM Config',
        'route': '/p2p-setup/sim-config',
        'category': 'P2P Setup',
        'feature': FeatureKeys.simConfig,
      },
      {
        'icon': Icons.settings_input_antenna,
        'label': 'Modem Config',
        'route': '/p2p-setup/modem-config',
        'category': 'P2P Setup',
        'feature': FeatureKeys.modemConfig,
      },
      {
        'icon': Icons.sim_card_outlined,
        'label': 'Mobile Network ID',
        'route': '/p2p-setup/mobile-network-id',
        'category': 'P2P Setup',
        'feature': FeatureKeys.mobileNetworkId,
      },
    ]);

    // Push Setup Server (static entry)
    items.add({
      'icon': Icons.dns_outlined,
      'label': 'Push Setup Server',
      'route': AppRoutes.pushSetupServer,
      'category': 'Push Setups',
      'feature': FeatureKeys.pushSetupServer,
    });

    // Add Push Setup submenus (configurable) if loaded
    if (_pushSetupsLoaded && _pushSetupConfigs.isNotEmpty) {
      for (final setup in _pushSetupConfigs) {
        items.add({
          'icon': Icons.notifications_active,
          'label': setup.label,
          'route': AppRoutes.pushSetupRoute(setup.id),
          'category': 'Push Setups',
          'feature': FeatureKeys.pushSetups,
        });
      }
    }

    // Add Push Action submenus (configurable) if loaded
    if (_pushActionsLoaded && _pushActionConfigs.isNotEmpty) {
      for (final action in _pushActionConfigs) {
        items.add({
          'icon': Icons.play_circle_outline,
          'label': action.label,
          'route': AppRoutes.pushActionRoute(action.id),
          'category': 'Push Setups',
          'feature': FeatureKeys.pushSetups,
        });
      }
    }

    // Add Script Table menu items if loaded
    if (_scriptTablesLoaded && _scriptTableConfigs.isNotEmpty) {
      for (final table in _scriptTableConfigs) {
        items.add({
          'icon': Icons.code,
          'label': table.label,
          'route': AppRoutes.scriptTableRoute(table.id),
          'category': 'Script Tables',
          'feature': FeatureKeys.scriptTables,
        });
      }
    }

    // Add Push Selective submenus if loaded
    if (_pushSelectivesLoaded && _pushSelectiveConfigs.isNotEmpty) {
      for (final selective in _pushSelectiveConfigs) {
        items.add({
          'icon': Icons.filter_list,
          'label': selective.label,
          'route': AppRoutes.pushSelectiveRoute(selective.id),
          'category': 'Push Selective',
          'feature': FeatureKeys.pushSelective,
        });
      }
    }

    // Add Push Recovery submenus if loaded
    if (_pushRecoveriesLoaded && _pushRecoveryConfigs.isNotEmpty) {
      for (final recovery in _pushRecoveryConfigs) {
        items.add({
          'icon': Icons.restore,
          'label': recovery.label,
          'route': AppRoutes.pushRecoveryRoute(recovery.id),
          'category': 'Push Recovery',
          'feature': FeatureKeys.pushRecovery,
        });
      }
    }

    // Bottom items: tools
    items.addAll([
      {
        'icon': Icons.library_books,
        'label': 'Super Manual',
        'route': '/super_manual',
        'category': null,
        'feature': FeatureKeys.superManual,
      },
      {
        'icon': Icons.layers,
        'label': 'Export Templates',
        'route': '/template_config',
        'category': null,
        'feature': FeatureKeys.exportTemplates,
      },
      {
        'icon': Icons.translate,
        'label': 'DLMS Translator',
        'route': '/gurux_translator',
        'category': null,
        'feature': FeatureKeys.dlmsTranslator,
      },
      {
        'icon': Icons.terminal,
        'label': 'Manual DLMS',
        'route': '/manual_dlms',
        'category': null,
        'feature': FeatureKeys.manualDlms,
      },
    ]);

    return items;
  }

  List<Map<String, dynamic>> get _visibleMenuItems {
    return _allMenuItems.where((item) {
      final feature = item['feature'] as String?;
      if (feature == null) return true;
      return !userRights.isFeatureDisabled(feature);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredMenuItems {
    final visibleItems = _visibleMenuItems;
    if (_filterText.isEmpty) {
      return visibleItems;
    }
    final filterLower = _filterText.toLowerCase();
    return visibleItems.where((item) {
      return item['label'].toString().toLowerCase().contains(filterLower) ||
          (item['category'] != null &&
              item['category'].toString().toLowerCase().contains(filterLower));
    }).toList();
  }

  List<Widget> _buildMenuWidgets(
      BuildContext context, List<Map<String, dynamic>> items) {
    final widgets = <Widget>[];
    final seenCategories = <String>{};
    for (final item in items) {
      final category = item['category'] as String?;
      if (category == null) {
        final itemRoute = item['route'] as String;
        final isConnected = ref.watch(appControllerProvider).isConnected;
        final isDisabled = itemRoute == AppRoutes.meterConnexion && isConnected;
        widgets.add(_navItem(
          context,
          item['icon'] as IconData,
          item['label'] as String,
          route: itemRoute,
          active: itemRoute == _currentRoute,
          disabled: isDisabled,
        ));
      } else if (!seenCategories.contains(category)) {
        seenCategories.add(category);
        final categoryItems =
            items.where((i) => i['category'] == category).toList();
        widgets.add(_navCategory(
          category,
          categoryItems
              .map((i) => _navItem(
                    context,
                    i['icon'] as IconData,
                    i['label'] as String,
                    route: i['route'] as String,
                    active: i['route'] == _currentRoute,
                  ))
              .toList(),
        ));
      }
    }
    return widgets;
  }

  Widget _buildCollapsed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _visibleMenuItems;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E3760), Color(0xFF0F1E35)]
              : const [cPrimary600, Color(0xFF1565C0)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          IconButton(
            key: const Key('drawer_collapsed_open_btn'),
            tooltip: 'Open menu',
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: widget.onToggle,
          ),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: items.map((item) {
                  final bool isActive = item['route'] == _currentRoute;
                  return Tooltip(
                    message: item['label'] as String,
                    preferBelow: false,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.22)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isActive
                            ? const Border(
                                left: BorderSide(color: Colors.white, width: 3),
                              )
                            : null,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.18),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          item['icon'] as IconData,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.75),
                          size: 22,
                        ),
                        onPressed: () {
                          if (ref
                              .read(appControllerProvider)
                              .isFirmwareDownloading) {
                            showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title:
                                    const Text('Firmware Download in Progress'),
                                content: const Text(
                                  'Navigation is disabled while a firmware download is running.\n'
                                  'Please wait for the transfer to complete or cancel it first.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          if (_scrollController.hasClients) {
                            _savedScrollOffset = _scrollController.offset;
                          }
                          Navigator.pushReplacementNamed(
                              context, item['route'] as String);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
          p.Consumer<AuthProvider>(
            builder: (_, auth, __) => Tooltip(
              message: 'Sign out',
              child: IconButton(
                key: const Key('drawer_collapsed_signout_btn'),
                icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                onPressed: () {
                  auth.logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/connexion', (_) => false);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) return _buildCollapsed(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _filteredMenuItems;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E3760), Color(0xFF0F1E35)]
              : const [cPrimary600, Color(0xFF1565C0)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.electric_bolt, size: 36, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Viewer_NG',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20)),
                      Text('Smart Meter Interface',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
                if (widget.onToggle != null)
                  IconButton(
                    key: const Key('drawer_close_btn'),
                    tooltip: 'Close menu',
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: widget.onToggle,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Filter TextField
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                key: const Key('drawer_filter_field'),
                controller: _filterController,
                onChanged: (value) {
                  setState(() {
                    _filterText = value;
                  });
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Filter menu...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.black.withOpacity(0.85)),
                  suffixIcon: _filterText.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Colors.black.withOpacity(0.85)),
                          onPressed: () {
                            _filterController.clear();
                            setState(() {
                              _filterText = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Menu items
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildMenuWidgets(context, filteredItems),
                    if (filteredItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            p.Consumer<AuthProvider>(
              builder: (context, auth, _) => InkWell(
                key: const Key('drawer_signout_btn'),
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  auth.logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/connexion', (_) => false);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [
                            if ((auth.username ?? '').isNotEmpty)
                              auth.username!,
                            if (userRights.role.isNotEmpty)
                              '(${userRights.role})',
                          ].join('  '),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Hover-aware navigation item ──────────────────────────────────────────────

class _HoverNavItem extends StatefulWidget {
  const _HoverNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool disabled;

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool showActive = widget.active;
    final bool showHover = _hovered && !widget.disabled && !widget.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: showActive
                  ? Colors.white.withOpacity(0.22)
                  : showHover
                      ? Colors.white.withOpacity(0.12)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: showActive
                  ? const Border(
                      left: BorderSide(color: Colors.white, width: 3),
                    )
                  : showHover
                      ? Border.all(color: Colors.white.withOpacity(0.15))
                      : null,
              boxShadow: showActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.14),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: showActive ? 1.1 : 1.0,
                  child: Icon(
                    widget.icon,
                    color: showActive || showHover
                        ? Colors.white
                        : Colors.white
                            .withOpacity(widget.disabled ? 0.35 : 0.70),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          showActive ? FontWeight.w700 : FontWeight.w500,
                      color: showActive || showHover
                          ? Colors.white
                          : Colors.white
                              .withOpacity(widget.disabled ? 0.35 : 0.75),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showActive)
                  const Icon(Icons.chevron_right,
                      color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
