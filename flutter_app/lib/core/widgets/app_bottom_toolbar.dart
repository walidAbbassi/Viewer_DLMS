import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widget_keys.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import '../../grpc/meter_client.dart';

/// Permanent bottom toolbar with quick access buttons for all main screens
class AppBottomToolbar extends StatelessWidget {
  final Future<void> Function()? onDisconnect;
  final bool isConnected;

  const AppBottomToolbar({
    super.key,
    this.onDisconnect,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurface : DesignTokens.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? DesignTokens.darkBorder : DesignTokens.gray200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ToolbarButton(
              key: const Key(AppBottomToolbarKeys.datetimeBtn),
              icon: Icons.access_time,
              label: 'Date/Time',
              onPressed: () => _onGetMeterTime(context),
            ),
            _ToolbarButton(
              key: const Key(AppBottomToolbarKeys.superManualBtn),
              icon: Icons.menu_book_outlined,
              label: 'Super Manual',
              onPressed: () => AppRoutes.navigatorKey.currentState
                  ?.pushReplacementNamed(AppRoutes.superManual),
            ),
            _ToolbarButton(
              key: const Key(AppBottomToolbarKeys.manualDlmsBtn),
              icon: Icons.terminal,
              label: 'Manual DLMS',
              onPressed: () => AppRoutes.navigatorKey.currentState
                  ?.pushReplacementNamed(AppRoutes.manualDlms),
            ),
            _ToolbarButton(
              key: const Key(AppBottomToolbarKeys.configurationBtn),
              icon: Icons.settings_outlined,
              label: 'Configuration',
              onPressed: () => AppRoutes.navigatorKey.currentState
                  ?.pushNamed(AppRoutes.configuration),
            ),
            _ToolbarButton(
              key: const Key(AppBottomToolbarKeys.disconnectBtn),
              icon: Icons.power_settings_new,
              label: 'Disconnect',
              onPressed: isConnected && onDisconnect != null
                  ? () => _onDisconnect(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGetMeterTime(BuildContext context) async {
    try {
      // Afficher un loading snackbar
      ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Reading clock from meter...'),
            ],
          ),
          backgroundColor: DesignTokens.primary600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );

      // Appeler GetClock depuis le meter
      final client = meterClientFactory();
      final meterTime = await client.getClock();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Meter Clock: $meterTime',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: DesignTokens.success,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to read meter clock: ${e.toString()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: DesignTokens.danger,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
      }
    }
  }

  Future<void> _onDisconnect(BuildContext context) async {
    if (onDisconnect != null) {
      try {
        await onDisconnect!();
        if (context.mounted) {
          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Disconnected successfully'),
                ],
              ),
              backgroundColor: DesignTokens.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disconnect error: ${error.toString()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: DesignTokens.danger,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
        }
      }
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeIcon  = isDark ? DesignTokens.darkFocus        : DesignTokens.primary600;
    final inactiveIcon= isDark ? DesignTokens.darkHint         : DesignTokens.gray400;
    final activeTxt   = isDark ? DesignTokens.darkTextPrimary  : DesignTokens.textPrimary;
    final inactiveTxt = isDark ? DesignTokens.darkHint         : DesignTokens.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(activeIcon),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 24,
                    color: enabled ? activeIcon : inactiveIcon,
                  ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: enabled ? activeTxt : inactiveTxt,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
