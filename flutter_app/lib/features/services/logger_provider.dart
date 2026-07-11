import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../grpc/logger_client.dart';
import '../../grpc/generated/logger.pb.dart';

// Maximum time between UI refreshes while logs are streaming.
const Duration _kThrottleDuration = Duration(milliseconds: 100);

/// Holds a reference to the shared mutable log list plus connection metadata.
/// The list is intentionally mutable and shared — consumers must NOT cache the
/// length between builds; instead they should use [version] to detect changes.
class LoggerState {
  /// All accumulated log messages. Exposed as unmodifiable to prevent
  /// accidental mutation from the UI layer.
  final UnmodifiableListView<String> messages;

  /// Incremented every time the notifier pushes a new state, so widgets can
  /// detect a change without comparing the (potentially huge) list itself.
  final int version;

  final bool isConnected;
  final String? error;

  const LoggerState({
    required this.messages,
    this.version = 0,
    this.isConnected = false,
    this.error,
  });
}

class LoggerNotifier extends StateNotifier<LoggerState> {
  LoggerNotifier()
      : _messages = [],
        super(LoggerState(
          messages: UnmodifiableListView(const []),
        )) {
    start();
  }

  // The single backing list — never replaced, only mutated.
  final List<String> _messages;

  final LoggerClient _client = LoggerClient();
  StreamSubscription<LogLine>? _subscription;

  // Throttle: schedule at most one rebuild per _kThrottleDuration.
  Timer? _throttleTimer;
  bool _pendingFlush = false;

  void _onLine(String message) {
    _messages.add(message);
    if (!_pendingFlush) {
      _pendingFlush = true;
      _throttleTimer = Timer(_kThrottleDuration, _flush);
    }
  }

  void _flush() {
    _pendingFlush = false;
    if (!mounted) return;
    // Emit a new state wrapping the SAME list — no copy.
    state = LoggerState(
      messages: UnmodifiableListView(_messages),
      version: state.version + 1,
      isConnected: state.isConnected,
      error: state.error,
    );
  }

  /// Start streaming logs from the gRPC server.
  void start() {
    if (_subscription != null) return; // already running
    _subscription = _client.streamLogs().listen(
      (line) => _onLine(line.message),
      onError: (Object e) {
        _throttleTimer?.cancel();
        _pendingFlush = false;
        state = LoggerState(
          messages: UnmodifiableListView(_messages),
          version: state.version + 1,
          isConnected: false,
          error: e.toString(),
        );
        _subscription = null;
      },
      onDone: () {
        _throttleTimer?.cancel();
        _pendingFlush = false;
        _flush();
        state = LoggerState(
          messages: UnmodifiableListView(_messages),
          version: state.version + 1,
          isConnected: false,
        );
        _subscription = null;
      },
      cancelOnError: true,
    );
    state = LoggerState(
      messages: UnmodifiableListView(_messages),
      version: state.version + 1,
      isConnected: true,
    );
  }

  /// Stop streaming.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _throttleTimer?.cancel();
    _pendingFlush = false;
    state = LoggerState(
      messages: UnmodifiableListView(_messages),
      version: state.version + 1,
      isConnected: false,
    );
  }

  /// Clear all in-memory logs.
  void clear() {
    _messages.clear();
    _throttleTimer?.cancel();
    _pendingFlush = false;
    state = LoggerState(
      messages: UnmodifiableListView(_messages),
      version: state.version + 1,
      isConnected: state.isConnected,
    );
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final loggerProvider =
    StateNotifierProvider<LoggerNotifier, LoggerState>(
  (ref) => LoggerNotifier(),
);
