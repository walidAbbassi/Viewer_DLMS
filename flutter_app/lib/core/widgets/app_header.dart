import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';
import '../theme/app_icons.dart';
import 'app_button.dart';

/// Replaces the old [AppBottomToolbar]. The side rail is already the single
/// navigation surface (Date/Time, Super Manual, Manual DLMS and
/// Configuration are all reachable from it), so this bar only carries what
/// isn't duplicated elsewhere: the live connection status and a global
/// Disconnect action.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.isConnected,
    this.onDisconnect,
  });

  final bool isConnected;
  final Future<void> Function()? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? AppIcons.connected : AppIcons.disconnected,
            size: 16,
            color: isConnected ? colors.success : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Connected' : 'Not connected',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
          const Spacer(),
          AppButton.danger(
            label: 'Disconnect',
            icon: AppIcons.disconnect,
            onPressed: (isConnected && onDisconnect != null)
                ? () => onDisconnect!()
                : null,
          ),
        ],
      ),
    );
  }
}
