import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grpc/meter_client.dart';
import '../../routes/app_routes.dart';
import '../../state/app_controller.dart';
import '../../state/hdlc_timeout_provider.dart';
import '../navigation/app_route_observer.dart';

/// Wraps the entire application content and resets the idle countdown on any
/// pointer event (tap, mouse move, scroll, key press).
///
/// The timer is only active on authenticated pages (i.e. any route that is
/// NOT [AppRoutes.connexion]).  Navigating to the connexion page deactivates
/// the timer; navigating away from it reactivates it.
class IdleTimeoutWrapper extends ConsumerStatefulWidget {
  const IdleTimeoutWrapper({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<IdleTimeoutWrapper> createState() => _IdleTimeoutWrapperState();
}

class _IdleTimeoutWrapperState extends ConsumerState<IdleTimeoutWrapper> {
  @override
  void initState() {
    super.initState();
    // Register the async callback: disconnect from the meter before navigating
    // so the backend releases the serial port, then reset application state.
    // Disconnect errors are intentionally swallowed — the meter may have already
    // dropped the HDLC link (same pattern as firmware_download_page.dart).
    idleTimerController.onIdle = () async {
      try {
        await MeterClient().disconnect();
      } catch (_) {
        // Meter may have already closed the link — ignore.
      }
      ref.read(appControllerProvider.notifier).resetAll();
    };
    // Pause the idle timer whenever any background process is active (firmware
    // download, bulk export, etc.). No user interaction is expected during
    // these operations and the connection must not be interrupted.
    ref.listenManual(
      appControllerProvider.select((s) => s.activeBackgroundProcesses > 0),
      (_, isBusy) {
        if (isBusy) {
          idleTimerController.deactivate();
        } else {
          // All background processes finished — restore based on current route.
          _onRouteChanged();
        }
      },
    );

    // Sync timeout value into the controller whenever the provider changes.
    ref.listenManual(hdlcTimeoutProvider, (_, next) {
      next.whenData((seconds) => idleTimerController.updateDuration(seconds));
    });

    // Watch route changes to activate / deactivate idle watching.
    currentRouteNotifier.addListener(_onRouteChanged);

    // Load the persisted timeout and configure the controller.
    ref.read(hdlcTimeoutProvider.future).then((seconds) {
      idleTimerController.updateDuration(seconds);
    });
  }

  @override
  void dispose() {
    currentRouteNotifier.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final route = currentRouteNotifier.value;
    if (route == null ||
        route == AppRoutes.connexion ||
        route == AppRoutes.meterConnexion) {
      idleTimerController.deactivate();
    } else {
      idleTimerController.activate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => idleTimerController.reset(),
      onPointerMove: (_) => idleTimerController.reset(),
      onPointerSignal: (_) => idleTimerController.reset(),
      child: KeyboardListener(
        focusNode: FocusNode(canRequestFocus: false),
        onKeyEvent: (_) => idleTimerController.reset(),
        child: widget.child,
      ),
    );
  }
}
