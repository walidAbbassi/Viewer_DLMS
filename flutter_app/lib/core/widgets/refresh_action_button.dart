import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../features/services/logger_provider.dart';
import 'log_panel.dart';

/// A Refresh icon button designed for AppBar actions.
/// By default auto-disables when the meter is disconnected.
/// Pass [checkConnection: false] for pages that do not require a live meter
/// connection (e.g. the connexion page or local-config screens).
/// Place this in [AppBar.actions] to provide a consistent top-right refresh
/// control across every screen in the application.
class RefreshAppBarButton extends ConsumerWidget {
  final VoidCallback onPressed;

  /// When [true] (default) the button is automatically disabled while the
  /// meter is disconnected.  Set to [false] for pages whose refresh action
  /// does not require a meter connection.
  final bool checkConnection;

  const RefreshAppBarButton({
    super.key,
    required this.onPressed,
    this.checkConnection = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected =
        checkConnection ? ref.watch(appControllerProvider).isConnected : true;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            key: const Key('appbar_refresh_btn'),
            icon: const Icon(Icons.refresh),
            tooltip: isConnected ? 'Refresh' : 'Not connected',
            onPressed: isConnected ? onPressed : null,
          ),
        ),
        const SizedBox(width: 4),
        Consumer(
          builder: (context, ref, _) {
            final logVisible = ref.watch(logPanelVisibleProvider);
            final isStreaming = ref.watch(loggerProvider).isConnected;
            final color = isStreaming ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
            return IconButton(
              key: const Key('appbar_logs_btn'),
              icon: Icon(
                logVisible ? Icons.terminal : Icons.terminal_outlined,
                color: color,
              ),
              tooltip: logVisible ? 'Hide logs' : 'Show logs',
              onPressed: () => LogPanel.show(context),
            );
          },
        ),
        const SizedBox(width: 4),
        const MeterStatusIndicator(),
        Tooltip(
          message: 'Change language',
          child: InkWell(
            key: const Key('appbar_language_btn'),
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  'EN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Displays a pulsing miniaturized meter icon (matching the Smart Meter Viewer
/// logo on the Authentication left panel) with a Teams-style status badge
/// overlaid at the bottom-right corner:
///   • green  ✓ when the meter is connected
///   • red    ✗ when the meter is disconnected
/// Reads [appControllerProvider] so it reacts automatically to every
/// connect / disconnect transition regardless of which page is on screen.
class MeterStatusIndicator extends ConsumerStatefulWidget {
  const MeterStatusIndicator({super.key});

  @override
  ConsumerState<MeterStatusIndicator> createState() =>
      _MeterStatusIndicatorState();
}

class _MeterStatusIndicatorState extends ConsumerState<MeterStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(appControllerProvider).isConnected;
    final tooltip = isConnected ? 'Meter connected' : 'Meter disconnected';
    const badgeConnected = Color(0xFF22C55E); // green-500
    const badgeDisconnected = Color(0xFFEF4444); // red-500
    final badgeColor = isConnected ? badgeConnected : badgeDisconnected;
    final badgeIcon = isConnected ? Icons.check : Icons.close;

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) {
            final opacity = 0.80 + 0.20 * _pulseAnim.value;
            return Opacity(
              opacity: opacity,
              // Extra padding bottom-right to leave room for the badge
              child: SizedBox(
                width: 32,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Meter body (scaled from the _glassBadge in connexion_page) ──
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4, right: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF5059C9), // Teams blue
                                Color(0xFF6264A7), // Teams blue-violet
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Column(
                              children: [
                                // LCD screen panel (top half)
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFCBD5E1), // slate-300
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Body panel (bottom half)
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF3B3F8C), // Teams dark
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      size: 9,
                                      color: Color(0xFFFBBF24), // amber-400
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ── Status badge (Teams-style) ──────────────────────────────
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          badgeIcon,
                          size: 7,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
