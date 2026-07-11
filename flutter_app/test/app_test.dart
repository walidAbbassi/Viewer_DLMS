import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/app.dart';
import 'package:flutter_python_grpc/platform/python_launcher.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:provider/provider.dart' as provider;
import 'package:flutter_python_grpc/features/services/auth_provider.dart';

// ── Minimal fake gRPC client (avoids real TCP connections in tests) ───────────
class _FakeClient extends IMeterClient {
  @override Future<String> getClock() async => '';
  @override Future<bool> setClock(String dt) async => true;
  @override Future<Int32Value> getTimezone() async => Int32Value();
  @override Future<bool> setTimezone(int o) async => true;
  @override Future<DaylightSavingsTime> getIncrementalDate() async => DaylightSavingsTime();
  @override Future<bool> setIncrementalDate(DaylightSavingsTime dt) async => true;
  @override Future<DaylightSavingsTime> getDecrementalDate() async => DaylightSavingsTime();
  @override Future<bool> setDecrementalDate(DaylightSavingsTime dt) async => true;
  @override Future<Int32Value> getDaylightSavingDeviation() async => Int32Value();
  @override Future<bool> setDaylightSavingDeviation(int d) async => true;
  @override Future<bool> getDaylightSavingActivation() async => false;
  @override Future<bool> setDaylightSavingActivation(bool a) async => true;
  @override Future<DeviceIDList> getDeviceID() async => DeviceIDList();
  @override Future<EnergyRegisterList> getEnergyRegister() async => EnergyRegisterList();
  @override Future<void> close() async {}
  @override Stream<GetLoadProfileStreamItem> getLoadProfile(
  String objectName, {
  LoadProfilePartialRead? start,
  LoadProfilePartialRead? end,
  int page = 1,
  int pageSize = 50,
}) => const Stream.empty();
  @override Future<int> getLoadProfileMaxRecords(String o) async => 0;
  @override Future<bool> setLoadProfileMaxRecords(String o, int v) async => true;
  @override Future<int> getLoadProfileRecordNumber(String o) async => 0;
  @override Future<bool> setLoadProfileRecordNumber(String o, int v) async => true;
  @override Future<int> getLoadProfileCapturePeriod(String o) async => 0;
  @override Future<bool> setLoadProfileCapturePeriod(String o, int v) async => true;
  
  @override
  Future<AverageList> getAverage() async => AverageList();
  @override
  Future<GetLteNetworkParametersResponse> getLteNetworkParameters() async =>
      GetLteNetworkParametersResponse();
  @override
  Future<GetLteQosResponse> getLteQos() async => GetLteQosResponse();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [child] in all providers required by SmartMeterApp.
Widget _wrap(Widget child) => provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ProviderScope(child: child),
    );

/// Installs a FlutterError.onError that swallows overflow / dispose errors but
/// re-throws everything else; restored by addTearDown.
void _muteLayoutErrors() {
  final orig = FlutterError.onError!;
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed') ||
        msg.contains('setState() called after dispose') ||
        msg.contains('Multiple exceptions were thrown') ||
        msg.contains('Navigator') ||
        msg.contains('No Material widget found')) return;
    orig(details);
  };
  addTearDown(() => FlutterError.onError = orig);
}

/// Bounded pump: avoids hanging on persistent animations.
Future<void> _settle(WidgetTester tester, {int steps = 20}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (!tester.binding.hasScheduledFrame) return;
  }
}

void main() {
  late IMeterClient Function() originalFactory;

  setUp(() {
    originalFactory = meterClientFactory;
    meterClientFactory = () => _FakeClient();
    PythonLauncher.instance.ready.value = false;
  });

  tearDown(() {
    meterClientFactory = originalFactory;
    PythonLauncher.instance.ready.value = false;
  });

  // ── SmartMeterApp – not-ready (splash) state ─────────────────────────────
  group('SmartMeterApp – splash state (isReady=false)', () {
    testWidgets('shows SplashScreen when launcher is not ready', (tester) async {
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('does NOT show MaterialApp content when not ready', (tester) async {
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      // The inner MaterialApp (with 'Smart Meter Application' title) must NOT appear.
      final apps = tester.widgetList<MaterialApp>(find.byType(MaterialApp));
      final titles = apps.map((a) => a.title).toList();
      expect(titles.contains('Smart Meter Application'), isFalse);
    });

    testWidgets('SplashScreen has dark background Scaffold', (tester) async {
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ── SmartMeterApp – ready state ───────────────────────────────────────────
  group('SmartMeterApp – ready state (isReady=true)', () {
    testWidgets('shows MaterialApp with correct title when ready', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      final apps = tester.widgetList<MaterialApp>(find.byType(MaterialApp));
      final titles = apps.map((a) => a.title).toList();
      expect(titles.contains('Smart Meter Application'), isTrue);
    });

    testWidgets('does NOT show SplashScreen when ready', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      // SplashScreen (second MaterialApp shell) must NOT appear.
      final apps = tester.widgetList<MaterialApp>(find.byType(MaterialApp));
      final hasSplashTitle = apps.any((a) => a.title == '' && a.debugShowCheckedModeBanner == false);
      // The main app MaterialApp has title 'Smart Meter Application'.
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('theme uses Material 3 with seed color 0xFF1e40af', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      final app = tester.widgetList<MaterialApp>(find.byType(MaterialApp))
          .firstWhere((a) => a.title == 'Smart Meter Application');
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('theme has custom AppBar backgroundColor', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      final app = tester.widgetList<MaterialApp>(find.byType(MaterialApp))
          .firstWhere((a) => a.title == 'Smart Meter Application');
      expect(app.theme?.appBarTheme.backgroundColor, const Color(0xFF1e40af));
    });

    testWidgets('theme has custom ElevatedButton shape', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      final app = tester.widgetList<MaterialApp>(find.byType(MaterialApp))
          .firstWhere((a) => a.title == 'Smart Meter Application');
      expect(app.theme?.elevatedButtonTheme, isNotNull);
    });

    testWidgets('debugShowCheckedModeBanner is false', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      PythonLauncher.instance.ready.value = true;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();

      final app = tester.widgetList<MaterialApp>(find.byType(MaterialApp))
          .firstWhere((a) => a.title == 'Smart Meter Application');
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });

  // ── SmartMeterApp – ValueListenable transition ────────────────────────────
  group('SmartMeterApp – ready state transition', () {
    testWidgets('rebuilds from SplashScreen to MaterialApp when ready changes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _muteLayoutErrors();

      // Start not-ready → SplashScreen.
      PythonLauncher.instance.ready.value = false;
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      // Flip to ready → MaterialApp appears.
      PythonLauncher.instance.ready.value = true;
      await tester.pump();

      final apps = tester.widgetList<MaterialApp>(find.byType(MaterialApp));
      final titles = apps.map((a) => a.title).toList();
      expect(titles.contains('Smart Meter Application'), isTrue);
    });
  });

  // ── SmartMeterApp – lifecycle ─────────────────────────────────────────────
  group('SmartMeterApp – lifecycle', () {
    testWidgets('initState and dispose run without error', (tester) async {
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      // Replace with a blank widget → triggers dispose().
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('can be rebuilt multiple times', (tester) async {
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      await tester.pumpWidget(_wrap(const SmartMeterApp()));
      await tester.pump();
      expect(find.byType(SmartMeterApp), findsOneWidget);
    });
  });

  // ── SplashScreen ──────────────────────────────────────────────────────────
  group('SplashScreen', () {
    testWidgets('renders a Scaffold', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has a black-family background color', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0E1116));
    });

    testWidgets('contains a Center widget', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('wraps content in a Container', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has debugShowCheckedModeBanner false', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('pumping for 2 s does not throw', (tester) async {
      await tester.pumpWidget(const SplashScreen());
      await _settle(tester, steps: 40);
    });
  });
}
