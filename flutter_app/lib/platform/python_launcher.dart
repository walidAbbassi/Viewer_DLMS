// lib/platform/python_launcher.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'dart:isolate';

/// Launches the packaged Python gRPC server EXE (Windows/macOS/Linux desktop),
/// waits for the port to open, and provides stop() to kill it on exit.
///
/// Expected EXE name (Windows): py_grpc_server.exe
/// On macOS/Linux, the same logic works with a non-.exe binary.
///
/// DEV layout (typical repo):
///   flutter_app/
///   backend/dist/py_grpc_server.exe   ← searched automatically
///
/// PROD layout (after `flutter build windows`):
///   build/windows/x64/runner/Debug/
///     flutter_app.exe
///     bin/py_grpc_server.exe          ← place EXE here (or same dir as app)
class PythonLauncher {
  PythonLauncher._();
  static final PythonLauncher instance = PythonLauncher._();

  int? _proc;
  int port = 50051;
  String host = '127.0.0.1';
  final ValueNotifier<bool> ready = ValueNotifier<bool>(false);

  /// Start the server if not running yet.
  /// Returns true once the TCP port is accepting connections.
  Future<void> start({int port = 50051, String host = '127.0.0.1'}) async {
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Mobile: handled differently (e.g., Chaquopy on Android) — no-op here.
      ready.value = true; // coverage:ignore-line
    }

    this.port = port;
    this.host = host;
     
    // If already running & healthy, just return.
    if (await _isPortOpen(host, port, timeout: const Duration(milliseconds: 200))) {
      print("Port is already open");
      ready.value = true;
      return;
    }
    
    final exePath = _findServerExecutable();
    if (exePath == null) {
      // You can surface this to the UI if you want
      // ignore: avoid_print
      print('⚠️ py_grpc_server executable not found. See search paths in _candidatePaths().');
      ready.value = true;
      return;
    }

    // coverage:ignore-start
    final env = <String, String>{...Platform.environment};
    env['PY_GRPC_HOST'] = host;
    env['PY_GRPC_PORT'] = '$port';
    
    // Start detached but keep stdio so we can read logs in dev.
    _proc = await Isolate.run<int?>(()async  {
      final proc = await Process.start(
      exePath,
      const [],
      environment: env,
      workingDirectory: p.dirname(exePath),
      mode: ProcessStartMode.detached, // no console; handle not needed
    );
    return proc.pid; // ✅ int is sendable
    
    });

    // Wait until the port is open (retry a few seconds)
    _waitForReady();
    // coverage:ignore-end
  }
  // coverage:ignore-start
  Future<void> kill() async {
    if (Platform.isWindows) {
        // force kill by name
        await Process.run('taskkill', ['/IM', 'py_grpc_server.exe', '/F']);
    } else {
       if(_proc!= null){
        Process.killPid(_proc!, ProcessSignal.sigterm);
       }
        
    }
    // coverage:ignore-end
  }

  /// Attempt to stop the server process (best-effort).
  Future<void> stop() async {
    if (_proc == null) return;
    // coverage:ignore-start
    try {
      // On Windows, SIGTERM doesn't exist; plain kill() works.
      kill();
    } catch (_) {
      try {
        kill();
      } catch (_) {}
    }
    _proc = null;
    // coverage:ignore-end
  }


  /// Poll for port readiness up to ~5 seconds.
  // coverage:ignore-start
  void _waitForReady()  {
    const timeout = Duration(seconds: 12);
    const minStep = Duration(milliseconds: 200);
    const maxStep = Duration(milliseconds: 1200);

    var step = minStep;
    final started = DateTime.now();

    Timer.periodic(minStep, (t) async {
      final ok = await _isPortOpen(host, port, timeout: step);
      if (ok) {
        t.cancel();
        ready.value = true;
        return;
      }
      if (DateTime.now().difference(started) >= timeout) {
        t.cancel();
        ready.value = true;
        return;
      }
      // backoff
      final nextMs = (step.inMilliseconds * 1.5)
          .clamp(minStep.inMilliseconds, maxStep.inMilliseconds);
      step = Duration(milliseconds: nextMs.toInt());
    });
  }
  // coverage:ignore-end

  Future<bool> _isPortOpen(String host, int port, {Duration? timeout}) async {
    try {
      final s = await Socket.connect(host, port, timeout: timeout ?? const Duration(milliseconds: 150));
      await s.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Locate the EXE in common DEV/PROD locations.
  String? _findServerExecutable() {
    final candidates = _candidatePaths();
    for (final c in candidates) {
      if (File(c).existsSync()) return c; // coverage:ignore-line
    }
    // ignore: avoid_print
    print('Checked for py_grpc_server at:\n${candidates.join('\n')}');
    return null;
  }

  List<String> _candidatePaths() {
    final exeName = Platform.isWindows ? 'py_grpc_server.exe' : 'py_grpc_server';
    final cwd = Directory.current.path; // usually <repo>/flutter_app when running `flutter run`

    // DEV path: ../backend/dist/py_grpc_server.exe
    final dev = p.normalize(p.join(cwd, '..', 'backend', 'dist', exeName));

    // PROD (next to app): current dir
    final prodSameDir = p.normalize(p.join(cwd, exeName));

    // PROD recommended: ./bin/py_grpc_server.exe
    final prodBin = p.normalize(p.join(cwd, 'bin', exeName));

    // Sometimes the working dir during packaged run is runner’s dir; also check parent.
    final parentExe = p.normalize(p.join(p.dirname(cwd), exeName));
    final parentBin = p.normalize(p.join(p.dirname(cwd), 'bin', exeName));

    return [dev, prodBin, prodSameDir, parentBin, parentExe];
  }
}
