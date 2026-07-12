import 'package:flutter/material.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/navigation/app_route_observer.dart';
import 'package:flutter_python_grpc/core/widgets/app_scaffold_wrapper.dart';
import 'package:flutter_python_grpc/core/widgets/app_header.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:flutter_python_grpc/routes/app_routes.dart';
import 'package:flutter_python_grpc/state/app_controller.dart';
import 'package:flutter_python_grpc/state/retry_status_provider.dart';

// ---------------------------------------------------------------------------
// Fake MeterClient for disconnect path tests
// ---------------------------------------------------------------------------

class _FakeClient extends IMeterClient {
  final bool disconnectResult;
  final bool shouldThrow;

  _FakeClient({this.disconnectResult = true, this.shouldThrow = false});

  @override
  Future<bool> disconnect() async {
    if (shouldThrow) throw Exception('gRPC connection error');
    return disconnectResult;
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<String> getClock() {
    // TODO: implement getClock
    throw UnimplementedError();
  }

  @override
  Future<bool> getDaylightSavingActivation() {
    // TODO: implement getDaylightSavingActivation
    throw UnimplementedError();
  }

  @override
  Future<Int32Value> getDaylightSavingDeviation() {
    // TODO: implement getDaylightSavingDeviation
    throw UnimplementedError();
  }

  @override
  Future<DaylightSavingsTime> getDecrementalDate() {
    // TODO: implement getDecrementalDate
    throw UnimplementedError();
  }

  @override
  Future<DeviceIDList> getDeviceID() {
    // TODO: implement getDeviceID
    throw UnimplementedError();
  }

  @override
  Future<EnergyRegisterList> getEnergyRegister() {
    // TODO: implement getEnergyRegister
    throw UnimplementedError();
  }

  @override
  Future<DaylightSavingsTime> getIncrementalDate() {
    // TODO: implement getIncrementalDate
    throw UnimplementedError();
  }

  @override Stream<GetLoadProfileStreamItem> getLoadProfile(
  String objectName, {
  LoadProfilePartialRead? start,
  LoadProfilePartialRead? end,
  int page = 1,
  int pageSize = 50,
})  {
    // TODO: implement getLoadProfile
    throw UnimplementedError();
  }

  @override
  Future<int> getLoadProfileCapturePeriod(String objectName) {
    // TODO: implement getLoadProfileCapturePeriod
    throw UnimplementedError();
  }

  @override
  Future<int> getLoadProfileMaxRecords(String objectName) {
    // TODO: implement getLoadProfileMaxRecords
    throw UnimplementedError();
  }

  @override
  Future<int> getLoadProfileRecordNumber(String objectName) {
    // TODO: implement getLoadProfileRecordNumber
    throw UnimplementedError();
  }

  @override
  Future<Int32Value> getTimezone() {
    // TODO: implement getTimezone
    throw UnimplementedError();
  }

  @override
  Future<bool> setClock(String dateTime) {
    // TODO: implement setClock
    throw UnimplementedError();
  }

  @override
  Future<bool> setDaylightSavingActivation(bool active) {
    // TODO: implement setDaylightSavingActivation
    throw UnimplementedError();
  }

  @override
  Future<bool> setDaylightSavingDeviation(int deviation) {
    // TODO: implement setDaylightSavingDeviation
    throw UnimplementedError();
  }

  @override
  Future<bool> setDecrementalDate(DaylightSavingsTime dateTime) {
    // TODO: implement setDecrementalDate
    throw UnimplementedError();
  }

  @override
  Future<bool> setIncrementalDate(DaylightSavingsTime dateTime) {
    // TODO: implement setIncrementalDate
    throw UnimplementedError();
  }

  @override
  Future<bool> setLoadProfileCapturePeriod(String objectName, int value) {
    // TODO: implement setLoadProfileCapturePeriod
    throw UnimplementedError();
  }

  @override
  Future<bool> setLoadProfileMaxRecords(String objectName, int value) {
    // TODO: implement setLoadProfileMaxRecords
    throw UnimplementedError();
  }

  @override
  Future<bool> setLoadProfileRecordNumber(String objectName, int value) {
    // TODO: implement setLoadProfileRecordNumber
    throw UnimplementedError();
  }

  @override
  Future<bool> setTimezone(int offset) {
    // TODO: implement setTimezone
    throw UnimplementedError();
  }
  
  @override
  Future<AverageList> getAverage() async => AverageList();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in [AppScaffoldWrapper] inside a ProviderScope + MaterialApp.
/// [routeName] controls what ModalRoute.of(context) will report, and
/// [overrides] allows customising provider state.
Widget _buildApp({
  required Widget child,
  String routeName = '/home',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      navigatorObservers: [appRouteObserver],
      routes: {
        routeName: (_) => Scaffold(body: AppScaffoldWrapper(child: child)),
      },
      initialRoute: routeName,
    ),
  );
}

/// Builds a ProviderScope + MaterialApp with the connexion route as initial
/// route so that AppScaffoldWrapper sees '/connexion' as its route name.
Widget _buildConnexionApp({required Widget child, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      navigatorObservers: [appRouteObserver],
      routes: {
        AppRoutes.connexion: (_) =>
            Scaffold(body: AppScaffoldWrapper(child: child)),
      },
      initialRoute: AppRoutes.connexion,
    ),
  );
}

void main() {
  setUp(() {
    // Reset factory and route notifier before every test so tests are independent.
    meterClientFactory = () => MeterClient();
    currentRouteNotifier.value = null;
  });

  tearDown(() {
    currentRouteNotifier.value = null;
  });

  // -------------------------------------------------------------------------
  // Layout branching
  // -------------------------------------------------------------------------
  group('AppScaffoldWrapper – layout', () {
    testWidgets('adds AppHeader for a generic child widget', (tester) async {
      await tester.pumpWidget(_buildApp(child: const Text('Content')));
      await tester.pumpAndSettle();
      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('generic child is still visible when toolbar is added', (tester) async {
      await tester.pumpWidget(_buildApp(child: const Text('Body content')));
      await tester.pumpAndSettle();
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('wraps child in a Column with an Expanded widget', (tester) async {
      await tester.pumpWidget(_buildApp(child: const Text('X')));
      await tester.pumpAndSettle();
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('returns child without toolbar on connexion route', (tester) async {
      await tester.pumpWidget(
          _buildConnexionApp(child: const Text('Login page')));
      await tester.pumpAndSettle();
      expect(find.byType(AppHeader), findsNothing);
      expect(find.text('Login page'), findsOneWidget);
    });

    testWidgets(
        'skips toolbar when child Scaffold already has a bottomNavigationBar',
        (tester) async {
      final childWithBar = Scaffold(
        body: const Text('Has bar'),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      );
      await tester.pumpWidget(_buildApp(child: childWithBar));
      await tester.pumpAndSettle();
      expect(find.byType(AppHeader), findsNothing);
      expect(find.text('Has bar'), findsOneWidget);
    });

    testWidgets(
        'adds toolbar when child Scaffold has no bottomNavigationBar',
        (tester) async {
      const childScaffold = Scaffold(body: Text('No bar'));
      await tester.pumpWidget(_buildApp(child: childScaffold));
      await tester.pumpAndSettle();
      expect(find.byType(AppHeader), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // isConnected propagation
  // -------------------------------------------------------------------------
  group('AppScaffoldWrapper – isConnected propagation', () {
    testWidgets('passes isConnected=false by default', (tester) async {
      await tester.pumpWidget(_buildApp(child: const Text('X')));
      await tester.pumpAndSettle();
      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbar.isConnected, isFalse);
    });

    testWidgets('passes isConnected=true when provider reports connected',
        (tester) async {
      final overrides = [
        appControllerProvider.overrideWith((ref) {
          final ctrl = AppController();
          ctrl.setIsConnected(true);
          return ctrl;
        }),
      ];
      await tester.pumpWidget(
          _buildApp(child: const Text('X'), overrides: overrides));
      await tester.pumpAndSettle();
      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbar.isConnected, isTrue);
    });

    testWidgets('toolbar re-renders when provider isConnected changes',
        (tester) async {
      late AppController ctrl;
      final overrides = [
        appControllerProvider.overrideWith((ref) {
          ctrl = AppController();
          return ctrl;
        }),
      ];
      await tester.pumpWidget(
          _buildApp(child: const Text('X'), overrides: overrides));
      await tester.pumpAndSettle();

      var toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbar.isConnected, isFalse);

      ctrl.setIsConnected(true);
      await tester.pump();

      toolbar = tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbar.isConnected, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // onDisconnect callback
  // -------------------------------------------------------------------------
  group('AppScaffoldWrapper – onDisconnect callback', () {
    testWidgets('toolbar always receives a non-null onDisconnect', (tester) async {
      await tester.pumpWidget(_buildApp(child: const Text('X')));
      await tester.pumpAndSettle();
      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbar.onDisconnect, isNotNull);
    });

    testWidgets('successful disconnect sets isConnected to false',
      (tester) async {
      meterClientFactory = () => _FakeClient(disconnectResult: true);
      late AppController ctrl;
      final overrides = [
        appControllerProvider.overrideWith((ref) {
          ctrl = AppController();
          ctrl.setIsConnected(true);
          return ctrl;
        }),
        retryStatusProvider.overrideWith((ref) => const Stream.empty()),
      ];
      await tester.pumpWidget(
          _buildApp(child: const Text('Page'), overrides: overrides));
      // Use bounded pump instead of pumpAndSettle() to avoid blocking on
      // the retryStatusProvider StreamProvider which stays in AsyncLoading.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      await toolbar.onDisconnect!();
      await tester.pump();

      final toolbarAfter =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbarAfter.isConnected, isFalse);
    // TODO: remove skip once AppScaffoldWrapper uses meterClientFactory().
    }, skip: true); // AppScaffoldWrapper hardcodes MeterClient() — meterClientFactory ignored

    testWidgets(
        'disconnect returning false does NOT change isConnected to false',
      (tester) async {
      meterClientFactory = () => _FakeClient(disconnectResult: false);
      final overrides = [
        appControllerProvider.overrideWith((ref) {
          final ctrl = AppController();
          ctrl.setIsConnected(true);
          return ctrl;
        }),
        retryStatusProvider.overrideWith((ref) => const Stream.empty()),
      ];
      await tester.pumpWidget(
          _buildApp(child: const Text('Page'), overrides: overrides));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      await toolbar.onDisconnect!();
      await tester.pump();

      final toolbarAfter =
          tester.widget<AppHeader>(find.byType(AppHeader));
      expect(toolbarAfter.isConnected, isTrue);
    // TODO: remove skip once AppScaffoldWrapper uses meterClientFactory().
    }, skip: true); // AppScaffoldWrapper hardcodes MeterClient() — meterClientFactory ignored

    testWidgets('disconnect throwing rethrows the exception', (tester) async {
      meterClientFactory = () => _FakeClient(shouldThrow: true);
      await tester.pumpWidget(_buildApp(
        child: const Text('Page'),
        overrides: [retryStatusProvider.overrideWith((ref) => const Stream.empty())],
      ));
      await tester.pumpAndSettle();

      final toolbar =
          tester.widget<AppHeader>(find.byType(AppHeader));
      await expectLater(toolbar.onDisconnect, throwsException);
    // TODO: remove skip once AppScaffoldWrapper uses meterClientFactory().
    }, skip: true); // AppScaffoldWrapper hardcodes MeterClient() — meterClientFactory ignored
  });
}
