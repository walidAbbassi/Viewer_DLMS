import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PushServerState {
  final UnmodifiableListView<PushNotificationEntry> notifications;
  final bool running;
  final bool starting;
  final bool stopping;
  final String? error;
  final String host;
  final int port;
  final String selectedType;

  const PushServerState({
    required this.notifications,
    this.running = false,
    this.starting = false,
    this.stopping = false,
    this.error,
    this.host = '0.0.0.0',
    this.port = 4059,
    this.selectedType = 'TCP',
  });

  PushServerState copyWith({
    UnmodifiableListView<PushNotificationEntry>? notifications,
    bool? running,
    bool? starting,
    bool? stopping,
    String? error,
    bool clearError = false,
    String? host,
    int? port,
    String? selectedType,
  }) {
    return PushServerState(
      notifications: notifications ?? this.notifications,
      running: running ?? this.running,
      starting: starting ?? this.starting,
      stopping: stopping ?? this.stopping,
      error: clearError ? null : (error ?? this.error),
      host: host ?? this.host,
      port: port ?? this.port,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class PushNotificationEntry {
  final DateTime timestamp;
  final String xml;
  const PushNotificationEntry({required this.timestamp, required this.xml});
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PushServerNotifier extends StateNotifier<PushServerState> {
  PushServerNotifier()
      : _notifications = [],
        super(PushServerState(
          notifications: UnmodifiableListView(const []),
        ));

  final List<PushNotificationEntry> _notifications;
  StreamSubscription<PushNotification>? _sub;
  IMeterClient? _client;

  Future<void> start(String host, int port, String type) async {
    if (state.running || state.starting) return;
    state = state.copyWith(starting: true, clearError: true, host: host, port: port, selectedType: type);

    _client ??= meterClientFactory();

    try {
      final stream = _client!.startPushSetupServer(host, port, type);
      _sub = stream.listen(
        (n) {
          _notifications.insert(
            0,
            PushNotificationEntry(timestamp: DateTime.now(), xml: n.xml),
          );
          state = state.copyWith(
            notifications: UnmodifiableListView(_notifications),
          );
        },
        onError: (e) {
          state = state.copyWith(running: false, error: e.toString());
        },
        onDone: () {
          state = state.copyWith(running: false);
        },
      );
      state = state.copyWith(running: true, starting: false);
    } catch (e) {
      state = state.copyWith(starting: false, error: e.toString());
    }
  }

  Future<void> stop() async {
    if (!state.running || state.stopping) return;
    state = state.copyWith(stopping: true, clearError: true);
    try {
      await _client?.stopPushSetupServer();
      await _sub?.cancel();
      _sub = null;
      state = state.copyWith(running: false, stopping: false);
    } catch (e) {
      state = state.copyWith(stopping: false, error: e.toString());
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await _client?.sendTestNotification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearNotifications() {
    _notifications.clear();
    state = state.copyWith(
      notifications: UnmodifiableListView(_notifications),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client?.close();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider — kept alive so state survives navigation
// ---------------------------------------------------------------------------

final pushServerProvider =
    StateNotifierProvider<PushServerNotifier, PushServerState>(
  (ref) => PushServerNotifier(),
);
