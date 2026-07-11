import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

const _kPrefKey = 'hdlc_inactivity_timeout_seconds';
const _kDefaultTimeout = 20;

/// Stores the HDLC inactivity timeout (in seconds) in SharedPreferences.
/// Default is 20 s. When the user is idle longer than this duration on any
/// authenticated page the app navigates back to the connexion screen.
class HdlcTimeoutNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPrefKey) ?? _kDefaultTimeout;
  }

  Future<void> setSeconds(int seconds) async {
    final clamped = seconds.clamp(5, 3600);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefKey, clamped);
    state = AsyncData(clamped);
  }
}

final hdlcTimeoutProvider =
    AsyncNotifierProvider<HdlcTimeoutNotifier, int>(HdlcTimeoutNotifier.new);

// ---------------------------------------------------------------------------
// Idle timer controller — a singleton held by the provider so that any widget
// can call [IdleTimerController.reset()] to postpone the timeout.
// ---------------------------------------------------------------------------

class IdleTimerController {
  static final IdleTimerController _instance = IdleTimerController._();
  factory IdleTimerController() => _instance;
  IdleTimerController._();

  Timer? _timer;
  Duration _duration = const Duration(seconds: _kDefaultTimeout);
  bool _active = false;

  /// Start (or restart) the idle countdown.
  void reset() {
    if (!_active) return;
    _timer?.cancel();
    _timer = Timer(_duration, _onIdle);
  }

  /// Update the timeout duration and restart if running.
  void updateDuration(int seconds) {
    _duration = Duration(seconds: seconds.clamp(5, 3600));
    if (_active) reset();
  }

  /// Activate idle watching (call when the user logs in).
  void activate() {
    _active = true;
    reset();
  }

  /// Deactivate idle watching (call when the user logs out or is on connexion).
  void deactivate() {
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onIdle() async {
    final nav = AppRoutes.navigatorKey.currentState;
    if (nav == null) return;
    await onIdle?.call();
    nav.pushNamedAndRemoveUntil(AppRoutes.meterConnexion, (_) => false);
  }

  /// Optional async callback invoked just before navigation (e.g. to disconnect
  /// from the meter and reset state). Errors are propagated to [_onIdle].
  Future<void> Function()? onIdle;
}

final idleTimerController = IdleTimerController();
