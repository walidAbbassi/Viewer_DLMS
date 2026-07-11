import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/user_rights.dart';
import '../../features/services/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';

/// Permanent toolbar widget with quick access buttons
class AppToolbar extends StatefulWidget {
  final VoidCallback? onGetMeterTime;
  
  const AppToolbar({
    super.key,
    this.onGetMeterTime,
  });

  @override
  State<AppToolbar> createState() => _AppToolbarState();
}

class _AppToolbarState extends State<AppToolbar> {
  String _currentTime = '';
  
  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every second
    Future.delayed(const Duration(seconds: 1), _updateTimeLoop);
  }
  
  void _updateTimeLoop() {
    if (mounted) {
      _updateTime();
      Future.delayed(const Duration(seconds: 1), _updateTimeLoop);
    }
  }
  
  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? DesignTokens.darkSurface    : DesignTokens.surface;
    final border    = isDark ? DesignTokens.darkBorder      : DesignTokens.gray200;
    final badgeBg   = isDark ? const Color(0xFF1E3A5F)      : DesignTokens.primary50;
    final badgeBdr  = isDark ? DesignTokens.darkFocus.withOpacity(.35)
                             : DesignTokens.primary600.withOpacity(0.3);
    final iconColor = isDark ? DesignTokens.darkFocus        : DesignTokens.primary600;
    final btnBorder = isDark ? DesignTokens.darkBorder       : DesignTokens.gray300;
    final btnIcon   = isDark ? DesignTokens.darkTextSecondary: DesignTokens.textSecondary;
    final textPri   = isDark ? DesignTokens.darkTextPrimary  : DesignTokens.primary600;
    final textSec   = isDark ? DesignTokens.darkTextSecondary: DesignTokens.textSecondary;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Date Time Display
            Container(
              key: const Key('toolbar_datetime_display'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeBdr),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    _currentTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Get Meter Time Button
            _toolbarButton(
              key: const Key('toolbar_get_meter_time_btn'),
              icon: Icons.schedule,
              tooltip: 'Get Meter Time',
              border: btnBorder,
              iconColor: btnIcon,
              onPressed: () {
                if (widget.onGetMeterTime != null) {
                  widget.onGetMeterTime!();
                } else {
                  ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                    const SnackBar(content: Text('Getting meter time...')),
                  );
                }
              },
            ),

            const SizedBox(width: 8),

            // Super Manual Button
            _toolbarButton(
              key: const Key('toolbar_supermanual_btn'),
              icon: Icons.book,
              tooltip: 'Super Manual',
              border: btnBorder,
              iconColor: btnIcon,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.superManual),
            ),

            const SizedBox(width: 8),

            // Manual DLMS Button
            _toolbarButton(
              icon: Icons.terminal,
              tooltip: 'Manual DLMS',
              border: btnBorder,
              iconColor: btnIcon,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.manualDlms),
            ),

            const SizedBox(width: 8),

            // Configuration Button
            _toolbarButton(
              key: const Key('toolbar_configuration_btn'),
              icon: Icons.settings,
              tooltip: 'Configuration',
              border: btnBorder,
              iconColor: btnIcon,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.configuration),
            ),

            const Spacer(),

            // Role + Logout
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final role = userRights.role;
                final username = auth.username ?? '';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (username.isNotEmpty || role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeBdr),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 16, color: iconColor),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (username.isNotEmpty)
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textPri,
                                    ),
                                  ),
                                if (role.isNotEmpty)
                                  Text(
                                    role,
                                    style: TextStyle(
                                        fontSize: 10, color: textSec),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Sign out',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('toolbar_signout_btn'),
                          onTap: () {
                            auth.logout();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.connexion, (_) => false);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: btnBorder),
                            ),
                            child: Icon(Icons.logout, size: 20, color: btnIcon),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color border,
    required Color iconColor,
  }) {
    return Tooltip(
      key: key,
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}
