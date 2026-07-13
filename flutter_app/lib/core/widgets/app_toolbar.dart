// core/widgets/app_toolbar.dart
//
// Persistent shared toolbar (SWEEP STEP7, Phase 1): title + tool shortcuts +
// meter model chip + connection-status/language cluster + refresh, mounted
// once from AppScaffoldWrapper on every route except connexion/meter_connexion.
//
// Deviations from the design spec, all deliberate (see
// Claude_Design/STATUS_FROM_CLAUDE_CODE.md for the full writeup):
// - Disconnect is preserved here (was AppHeader's only job) — the spec's
//   action list omitted it, but removing it would break disconnect on every
//   route except Meter Connexion.
// - The log-panel toggle is preserved from RefreshAppBarButton for the same
//   reason — dropping it removes working functionality with no replacement.
// - Refresh here does not reload any page's data — that needs per-page
//   wiring Phase 2 will add once each page's own AppBar is actually
//   retired. Tapping it explains that instead of silently doing nothing.
// - The language selector is visual-only — no localeProvider exists yet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grpc/meter_client.dart';
import '../../routes/app_routes.dart';
import '../../state/app_controller.dart';
import '../../state/device_id_cache.dart';
import '../navigation/app_route_observer.dart';
import '../services/feedback_service.dart';
import '../theme/app_icons.dart';
import '../theme/semantic_colors.dart';
import 'language_selector_widget.dart';
import 'log_panel.dart';

/// Route → static page title, for pages whose AppBar title is a fixed
/// string. Pages with a dynamic title (load profiles, event logs, quality,
/// push setups/actions/selective/recovery, script tables) are intentionally
/// left out — the toolbar falls back to an empty title for those rather
/// than guessing a runtime value it doesn't have access to here.
const Map<String, String> _routeTitles = {
  AppRoutes.identificationDeviceId: 'Device ID',
  AppRoutes.identificationFirmware: 'Firmware Version',
  AppRoutes.dateTime: 'Date Time',
  AppRoutes.calendarProfiles: 'Activity Calendars',
  AppRoutes.energyRegister: 'Energy Register',
  AppRoutes.ctvtManagement: 'CT VT Management',
  AppRoutes.fresnelDiagram: 'Fresnel Diagram',
  AppRoutes.average: 'Average',
  AppRoutes.firmware: 'Firmware Upgrade',
  AppRoutes.simConfig: 'SIM Config',
  AppRoutes.modemConfig: 'Modem Config',
  AppRoutes.mobileNetworkId: 'Mobile Network Identifier',
  AppRoutes.pushSetupServer: 'Push Setup Server',
  AppRoutes.templateConfig: 'Export Templates',
  AppRoutes.guruxTranslator: 'DLMS Translator',
  AppRoutes.manualDlms: 'Manual DLMS',
  AppRoutes.configuration: 'Configuration',
  AppRoutes.superManual: 'Super Manual Tool',
};

class AppToolbar extends ConsumerWidget {
  const AppToolbar({super.key, this.onDisconnect});

  final Future<void> Function()? onDisconnect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SemanticColors.of(context);
    final isConnected = ref.watch(appControllerProvider).isConnected;
    final logVisible = ref.watch(logPanelVisibleProvider);
    final title = _routeTitles[currentRouteNotifier.value] ?? '';
    final model = DeviceIdCache.data['Model'] ?? '';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_manual_dlms_btn'),
                    icon: AppIcons.manualDlms,
                    tooltip: 'Manual DLMS',
                    colors: colors,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.manualDlms),
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_super_manual_btn'),
                    icon: AppIcons.superManual,
                    tooltip: 'Super Manual',
                    colors: colors,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.superManual),
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_get_meter_time_btn'),
                    icon: AppIcons.clock,
                    tooltip: isConnected ? 'Get Meter Time' : 'Not connected',
                    colors: colors,
                    onPressed: isConnected
                        ? () async {
                            try {
                              final time =
                                  await meterClientFactory().getClock();
                              feedback.success('Meter time: $time');
                            } catch (_) {
                              feedback.error('Failed to read meter time');
                            }
                          }
                        : null,
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_configuration_btn'),
                    icon: AppIcons.configuration,
                    tooltip: 'Configuration',
                    colors: colors,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.configuration),
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_export_btn'),
                    icon: AppIcons.export,
                    tooltip: 'Export',
                    colors: colors,
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.templateConfig),
                  ),
                  const SizedBox(width: 6),
                  _ToolbarIconButton(
                    toolbarKey: const Key('toolbar_help_btn'),
                    icon: AppIcons.help,
                    tooltip: 'Help',
                    colors: colors,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Viewer_NG'),
                        content: const Text(
                            'DLMS/COSEM smart meter client.\nFor support, contact your system administrator.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (model.isNotEmpty) ...[
            Icon(AppIcons.meter, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(model,
                style:
                    TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            const SizedBox(width: 12),
          ],
          _ToolbarIconButton(
            toolbarKey: const Key('toolbar_logs_btn'),
            icon: AppIcons.logs,
            tooltip: logVisible ? 'Hide logs' : 'Show logs',
            colors: colors,
            iconColorOverride: logVisible ? colors.primary : null,
            onPressed: () => LogPanel.show(context),
          ),
          const SizedBox(width: 8),
          Icon(
            isConnected ? AppIcons.connected : AppIcons.disconnected,
            size: 16,
            color: isConnected ? colors.success : colors.error,
          ),
          const SizedBox(width: 4),
          const LanguageSelectorWidget(),
          const SizedBox(width: 6),
          _ToolbarIconButton(
            toolbarKey: const Key('toolbar_disconnect_btn'),
            icon: AppIcons.disconnect,
            tooltip: isConnected ? 'Disconnect' : 'Not connected',
            colors: colors,
            onPressed: (isConnected && onDisconnect != null)
                ? () => onDisconnect!()
                : null,
          ),
          const SizedBox(width: 6),
          _ToolbarIconButton(
            toolbarKey: const Key('toolbar_refresh_btn'),
            icon: AppIcons.refresh,
            tooltip: 'Refresh',
            colors: colors,
            onPressed: () => feedback.info(
                'Use the Refresh button on the page itself to reload its data.'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.colors,
    required this.onPressed,
    this.toolbarKey,
    this.iconColorOverride,
  });

  final IconData icon;
  final String tooltip;
  final SemanticColors colors;
  final VoidCallback? onPressed;
  final Key? toolbarKey;
  final Color? iconColorOverride;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: toolbarKey,
        icon: Icon(icon, size: 19),
        color: iconColorOverride ??
            (disabled
                ? colors.onSurfaceVariant.withOpacity(0.4)
                : colors.onSurfaceVariant),
        onPressed: onPressed,
      ),
    );
  }
}
