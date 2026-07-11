import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../core/theme/design_tokens.dart';
import 'app_drawer.dart';

/// A layout shell that shows [AppSideNav] as a permanent left panel and
/// renders [child] (typically a [Scaffold]) in the remaining space.
/// The panel is open by default and can be collapsed to a narrow icon rail.
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(appControllerProvider).isSideNavOpen;
    final ctrl = ref.read(appControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox.expand(
      child: Material(
        color: isDark ? const Color(0xFF0f172a) : DesignTokens.background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              width: isOpen ? 280 : 56,
              child: AppSideNav(
                isCollapsed: !isOpen,
                onToggle: () => ctrl.setSideNavOpen(!isOpen),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
