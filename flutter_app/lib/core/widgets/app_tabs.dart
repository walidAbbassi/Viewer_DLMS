import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';

/// Single pill-style tab bar shared by every page with tabs (Date Time,
/// Manual DLMS, Activity Calendars, …), replacing the assorted full-width
/// blue bands / TabBar defaults previously used ad hoc per page.
class AppTabs extends StatelessWidget implements PreferredSizeWidget {
  const AppTabs({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<AppTabItem> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colors.onPrimary,
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          for (final t in tabs)
            Tab(
              height: 36,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t.icon != null) Icon(t.icon, size: 16),
                  if (t.icon != null) const SizedBox(width: 6),
                  Text(t.label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppTabItem {
  const AppTabItem(this.label, {this.icon});
  final String label;
  final IconData? icon;
}
