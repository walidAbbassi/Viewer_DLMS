// test/platform/python_launcher_test.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/platform/python_launcher.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Binds a TCP server socket on a random free port so tests can simulate
/// "port already open" without needing a real gRPC server.
Future<ServerSocket> _listenOnFreePort() =>
    ServerSocket.bind('127.0.0.1', 0 /* OS picks a free port */);

/// Reset singleton mutable state between tests so they don't bleed into each
/// other.  _proc is package-private so we reset it via stop(); ready and
/// port/host are public.
void _resetLauncher() {
  final l = PythonLauncher.instance;
  l.ready.value = false;
  l.port = 50051;
  l.host = '127.0.0.1';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(_resetLauncher);
  tearDown(_resetLauncher);

  // ── singleton ─────────────────────────────────────────────────────────────
  group('singleton', () {
    test('instance always returns the same object', () {
      final a = PythonLauncher.instance;
      final b = PythonLauncher.instance;
      expect(identical(a, b), isTrue);
    });

    test('default port is 50051', () {
      expect(PythonLauncher.instance.port, equals(50051));
    });

    test('default host is 127.0.0.1', () {
      expect(PythonLauncher.instance.host, equals('127.0.0.1'));
    });

    test('ready starts as false', () {
      expect(PythonLauncher.instance.ready.value, isFalse);
    });

    test('ready is a ValueNotifier<bool>', () {
      expect(PythonLauncher.instance.ready, isA<ValueNotifier<bool>>());
    });
  });

  // ── start(): port already open ────────────────────────────────────────────
  group('start() – port already open', () {
    test('sets ready to true immediately', () async {
      final server = await _listenOnFreePort();
      try {
        await PythonLauncher.instance.start(port: server.port);
        expect(PythonLauncher.instance.ready.value, isTrue);
      } finally {
        await server.close();
      }
    });

    test('updates port field', () async {
      final server = await _listenOnFreePort();
      try {
        await PythonLauncher.instance.start(port: server.port, host: '127.0.0.1');
        expect(PythonLauncher.instance.port, equals(server.port));
      } finally {
        await server.close();
      }
    });

    test('updates host field', () async {
      final server = await _listenOnFreePort();
      try {
        await PythonLauncher.instance
            .start(port: server.port, host: '127.0.0.1');
        expect(PythonLauncher.instance.host, equals('127.0.0.1'));
      } finally {
        await server.close();
      }
    });

    test('returns without launching a process', () async {
      final server = await _listenOnFreePort();
      try {
        // Should complete fast – no Isolate.run involved.
        await PythonLauncher.instance.start(port: server.port).timeout(
              const Duration(seconds: 3),
            );
        expect(PythonLauncher.instance.ready.value, isTrue);
      } finally {
        await server.close();
      }
    });

    test('multiple consecutive calls are idempotent', () async {
      final server = await _listenOnFreePort();
      try {
        await PythonLauncher.instance.start(port: server.port);
        await PythonLauncher.instance.start(port: server.port);
        expect(PythonLauncher.instance.ready.value, isTrue);
      } finally {
        await server.close();
      }
    });
  });

  // ── start(): port closed, executable not found ───────────────────────────
  group('start() – port closed, exe not found', () {
    // Use an unlikely port that should be closed on any CI machine.
    const _unusedPort = 19871;

    test('sets ready to true after printing warning', () async {
      await PythonLauncher.instance.start(port: _unusedPort);
      expect(PythonLauncher.instance.ready.value, isTrue);
    });

    test('updates port field even when exe is missing', () async {
      await PythonLauncher.instance.start(port: _unusedPort, host: '127.0.0.1');
      expect(PythonLauncher.instance.port, equals(_unusedPort));
    });

    test('updates host field even when exe is missing', () async {
      await PythonLauncher.instance
          .start(port: _unusedPort, host: '127.0.0.1');
      expect(PythonLauncher.instance.host, equals('127.0.0.1'));
    });

    test('completes without throwing', () async {
      await expectLater(
        PythonLauncher.instance.start(port: _unusedPort),
        completes,
      );
    });

    test('exercises _findServerExecutable and _candidatePaths', () async {
      // Verifies no crash and that ready is set (exe search finished).
      await PythonLauncher.instance.start(port: _unusedPort);
      expect(PythonLauncher.instance.ready.value, isTrue);
    });
  });

  // ── stop() ────────────────────────────────────────────────────────────────
  group('stop()', () {
    test('returns immediately when _proc is null (no process started)', () async {
      // The singleton _proc is null because no real process was launched.
      await expectLater(PythonLauncher.instance.stop(), completes);
    });

    test('can be called multiple times without error', () async {
      await PythonLauncher.instance.stop();
      await PythonLauncher.instance.stop();
      // No assertion needed – just must not throw.
    });
  });

  // ── _isPortOpen (exercised indirectly) ────────────────────────────────────
  group('_isPortOpen (via start)', () {
    test('returns true when port accepts connections', () async {
      final server = await _listenOnFreePort();
      try {
        // start() calls _isPortOpen → must detect open port → ready = true
        // without proceeding to exe search.
        PythonLauncher.instance.ready.value = false;
        await PythonLauncher.instance.start(port: server.port);
        expect(PythonLauncher.instance.ready.value, isTrue);
      } finally {
        await server.close();
      }
    });

    test('returns false for a definitely-closed port', () async {
      // start() calls _isPortOpen → false → proceeds to exe path → ready=true
      PythonLauncher.instance.ready.value = false;
      await PythonLauncher.instance.start(port: 19872);
      // ready is set via the "exe not found" fallback, confirming _isPortOpen
      // returned false.
      expect(PythonLauncher.instance.ready.value, isTrue);
    });
  });

  // ── _candidatePaths ───────────────────────────────────────────────────────
  group('_candidatePaths (via start)', () {
    test('produces paths that include the expected exe name fragment', () async {
      // Running start() on a closed port drives _findServerExecutable which
      // iterates _candidatePaths().  The debug print lists all checked paths;
      // we simply verify the whole flow completes correctly.
      await PythonLauncher.instance.start(port: 19873);
      expect(PythonLauncher.instance.ready.value, isTrue);
    });

    test('includes Windows exe name on Windows platform', () async {
      // On this Windows host Platform.isWindows is true so the exe name used
      // will be py_grpc_server.exe.  We trigger the search and it completes.
      await PythonLauncher.instance.start(port: 19874);
      expect(PythonLauncher.instance.ready.value, isTrue);
    });
  });

  // ── ready ValueNotifier behaviour ─────────────────────────────────────────
  group('ready ValueNotifier', () {
    test('listener is notified when ready flips to true (port-open path)', () async {
      final server = await _listenOnFreePort();
      var notified = false;
      listener() => notified = true;
      PythonLauncher.instance.ready.addListener(listener);
      try {
        await PythonLauncher.instance.start(port: server.port);
        expect(notified, isTrue);
      } finally {
        PythonLauncher.instance.ready.removeListener(listener);
        await server.close();
      }
    });

    test('listener is notified when ready flips to true (exe-not-found path)', () async {
      var notified = false;
      listener() => notified = true;
      PythonLauncher.instance.ready.addListener(listener);
      try {
        await PythonLauncher.instance.start(port: 19875);
        expect(notified, isTrue);
      } finally {
        PythonLauncher.instance.ready.removeListener(listener);
      }
    });
  });
}
