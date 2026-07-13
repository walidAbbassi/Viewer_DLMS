import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_python_grpc/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../state/retry_status_provider.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/meter_client.dart';
import '../../core/navigation/app_route_observer.dart';
import '../services/feedback_service.dart';
import 'app_toolbar.dart';
import 'log_panel.dart';
import 'refresh_action_button.dart';

/// Wrapper qui ajoute automatiquement AppToolbar si la page n'en a pas
class AppScaffoldWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppScaffoldWrapper({super.key, required this.child});

  @override
  ConsumerState<AppScaffoldWrapper> createState() => _AppScaffoldWrapperState();
}

class _AppScaffoldWrapperState extends ConsumerState<AppScaffoldWrapper> {
  final ValueNotifier<String> _retryMessage = ValueNotifier('');
  bool _retryDialogVisible = false;
  BuildContext? _retryDialogContext; // context of the open dialog

  /// Safety-net: if no allFailed/success arrives within 7 s after the last
  /// attempt, the operation succeeded silently → close the spinner.
  static const _kAutoCloseDelay = Duration(seconds: 7);
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    currentRouteNotifier.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    currentRouteNotifier.removeListener(_onRouteChanged);
    _autoCloseTimer?.cancel();
    _retryMessage.dispose();
    super.dispose();
  }

  /// Shows a snackbar whenever the user navigates to a Viewer page
  /// while the meter is not connected.
  void _onRouteChanged() {
    final route = currentRouteNotifier.value;
    if (route == null) return;
    if (route == AppRoutes.connexion ||
        route == AppRoutes.meterConnexion ||
        route == AppRoutes.configuration) return;
    final isConnected = ref.read(appControllerProvider).isConnected;
    if (isConnected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      feedback.warning('Not connected — please connect to a meter first.');
    });
  }

  void _dismissRetryDialog() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    if (_retryDialogVisible) {
      _retryDialogVisible = false;
      final ctx = _retryDialogContext;
      _retryDialogContext = null;
      if (ctx != null && Navigator.of(ctx).canPop()) {
        Navigator.of(ctx).pop();
      } else {
        AppRoutes.navigatorKey.currentState?.maybePop();
      }
    }
  }

  void _showOrUpdateRetryDialog(String message) {
    _retryMessage.value = message;
    // Reset safety-net timer on each attempt.
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(_kAutoCloseDelay, _dismissRetryDialog);

    if (_retryDialogVisible) return;

    final navState = AppRoutes.navigatorKey.currentState;
    if (navState == null || navState.overlay == null) return;

    _retryDialogVisible = true;
    showDialog<void>(
      context: navState.overlay!.context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _retryDialogContext = dialogContext;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Communication Warning'),
            content: ValueListenableBuilder<String>(
              valueListenable: _retryMessage,
              builder: (_, msg, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _dismissRetryDialog,
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    ).then((_) => _retryDialogVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(appControllerProvider).isConnected;
    final client = MeterClient();

    // Listen to retry status updates.
    // Attempt 1/2/3 → spinner dialog visible with live counter.
    // allFailed    → spinner closes, navigate to meter_connexion.
    ref.listen<AsyncValue<RetryStatusUpdate>>(retryStatusProvider, (_, next) {
      next.when(
        loading: () => debugPrint('[retryStatus] loading'),
        error: (err, _) => debugPrint('[retryStatus] stream error: $err'),
        data: (update) {
          debugPrint(
              '[retryStatus] data: attempt=${update.attempt} allFailed=${update.allFailed}');
          if (!mounted) return;
          if (update.allFailed) {
            // All retries exhausted — close spinner, disconnect and navigate.
            // The isConnected listener above will show the snackbar.
            _dismissRetryDialog();
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Backend already sent DISC in _close_session().
              // Do NOT call client.disconnect() here — it would send RLRQ
              // to an unreachable meter and block for 3×5 s.
              ref.read(appControllerProvider.notifier).setIsConnected(false);
              AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                AppRoutes.meterConnexion,
                (_) => false,
              );
            });
          } else if (update.attempt == 0) {
            // Success sentinel: cable reconnected, retry succeeded.
            _dismissRetryDialog();
          } else {
            // Attempt 1/2/3: show / update spinner.
            _showOrUpdateRetryDialog(
              'Attempt ${update.attempt} / ${update.maxAttempts}\n'
              'No response from meter. Retrying…',
            );
          }
        },
      );
    });

    // Si le child est un Scaffold avec bottomNavigationBar, ne pas ajouter de toolbar
    if (widget.child is Scaffold) {
      final scaffold = widget.child as Scaffold;
      if (scaffold.bottomNavigationBar != null) {
        return widget.child; // La page a déjà sa toolbar
      }
    }

    // Wrap in Overlay so LogPanel's Tooltips can find an Overlay ancestor
    // (MaterialApp.builder runs above the Navigator, which normally owns the Overlay).
    // The OverlayEntry builder is made fully reactive via Consumer + ValueListenableBuilder
    // so it responds to provider and route changes after the initial mount.
    return Overlay(
      initialEntries: [
        OverlayEntry(
          opaque: true,
          maintainState: true,
          builder: (_) => Consumer(
            builder: (context, ref, _) {
              final logVisible = ref.watch(logPanelVisibleProvider);
              return ValueListenableBuilder<String?>(
                valueListenable: currentRouteNotifier,
                builder: (context, currentRoute, _) {
                  return Column(
                    children: [
                      // ✅ Toolbar visible partout sauf sur la page Sign In (connexion) et meterConnexion
                      if (currentRoute != AppRoutes.connexion &&
                          currentRoute != AppRoutes.meterConnexion)
                        AppToolbar(
                          onDisconnect: () async {
                            final success = await client.disconnect();
                            if (success) {
                              ref
                                  .read(appControllerProvider.notifier)
                                  .setIsConnected(false);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                AppRoutes.navigatorKey.currentState
                                    ?.pushNamedAndRemoveUntil(
                                  AppRoutes.meterConnexion,
                                  (_) => false,
                                );
                              });
                            }
                          },
                        ),
                      Expanded(child: widget.child),

                      // ✅ Persistent log panel — always above toolbar, never blocks page interaction
                      if (logVisible && currentRoute != AppRoutes.connexion)
                        const LogPanel(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
