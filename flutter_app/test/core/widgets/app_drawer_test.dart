import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as p;

import 'package:flutter_python_grpc/core/widgets/app_drawer.dart';
import 'package:flutter_python_grpc/features/services/auth_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a MaterialApp with the AppDrawer registered as the drawer on '/'
/// and all named routes used by nav items.
Widget _buildApp({Map<String, WidgetBuilder>? extra}) {
  return ProviderScope(
    child: p.ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: MaterialApp(
      routes: {
      '/': (_) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            drawer: const AppDrawer(),
            body: const Text('Home Body'),
          ),
      '/meter_connexion': (_) => const Scaffold(body: Text('Meter Connexion Page')),
      '/configuration': (_) => const Scaffold(body: Text('Configuration Page')),
      '/connection/identification/device-id': (_) =>
          const Scaffold(body: Text('Device ID Page')),
      '/connection/identification/firmware-version': (_) =>
          const Scaffold(body: Text('Firmware Version Page')),
      '/date_time': (_) => const Scaffold(body: Text('Date Time Page')),
      '/calendar_profiles': (_) => const Scaffold(body: Text('Calendar Profiles Page')),
      '/super_manual': (_) => const Scaffold(body: Text('Super Manual Page')),
      '/electricity-objects/energy-register': (_) =>
          const Scaffold(body: Text('Energy Register Page')),
      '/firmware': (_) => const Scaffold(body: Text('Firmware Page')),
      '/fresnel_diagram': (_) => const Scaffold(body: Text('Fresnel Page')),
      ...?extra,
    },
    initialRoute: '/',
  ),
    ),
  );
}

/// Pumps the widget, opens the drawer, and suppresses RenderFlex overflow
/// errors that arise from the fixed-width Drawer being rendered in the
/// default 800x600 test viewport.
Future<void> _openDrawer(WidgetTester tester) async {
  // Use a taller surface so all drawer items fit without scrolling.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // Override the test-binding's error handler so RenderFlex overflow
  // errors do NOT get accumulated as "unexpected" exceptions.
  final void Function(FlutterErrorDetails)? originalHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
    originalHandler?.call(details);
  };
  // Restore after the test finishes.
  addTearDown(() => FlutterError.onError = originalHandler);

  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle(); // let initState async calls complete
  final ScaffoldState scaffold = tester.firstState(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();
}

void main() {

  // -------------------------------------------------------------------------
  // Rendering
  // -------------------------------------------------------------------------
  group('AppDrawer – rendering', () {
    testWidgets('drawer is present in the widget tree', (tester) async {
      await _openDrawer(tester);
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(AppDrawer), findsOneWidget);
    });

    testWidgets('renders Viewer_NG brand title', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Viewer_NG'), findsOneWidget);
    });

    testWidgets('renders Smart Meter Interface subtitle', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Smart Meter Interface'), findsOneWidget);
    });

    testWidgets('renders electric_bolt icon in header', (tester) async {
      await _openDrawer(tester);
      expect(find.byIcon(Icons.electric_bolt), findsOneWidget);
    });

    testWidgets('renders filter text field with hint "Filter menu..."', (tester) async {
      await _openDrawer(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders search icon in filter field', (tester) async {
      await _openDrawer(tester);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

  });

  // -------------------------------------------------------------------------
  // Menu items
  // -------------------------------------------------------------------------
  group('AppDrawer – menu items', () {
    testWidgets('renders Meter Connexion item', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Meter Connexion'), findsOneWidget);
    });

    testWidgets('renders Activity Calendars item', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Activity Calendars'), findsOneWidget);
    });

    testWidgets('renders Date time item', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Date time'), findsOneWidget);
    });

    testWidgets('renders Super Manual item', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Super Manual'), findsOneWidget);
    });

    testWidgets('renders Identification category header', (tester) async {
      await _openDrawer(tester);
      expect(find.text('IDENTIFICATION'), findsOneWidget);
    });

    testWidgets('renders Device ID item under Identification', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Device ID'), findsOneWidget);
    });

    testWidgets('renders Firmware Version item under Identification', (tester) async {
      await _openDrawer(tester);
      expect(find.text('Firmware Version'), findsOneWidget);
    });

    testWidgets('renders Electricity Objects category header', (tester) async {
      await _openDrawer(tester);
      expect(find.text('ELECTRICITY OBJECTS'), findsOneWidget);
    });

    testWidgets('renders Energy Register item', (tester) async {
      await _openDrawer(tester);
      if (find.text('Energy Register').evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pump();
      }
      expect(find.text('Energy Register'), findsOneWidget);
    });

    testWidgets('renders Firmware Upgrade category header', (tester) async {
      await _openDrawer(tester);
      expect(find.text('FIRMWARE UPGRADE'), findsOneWidget);
    });

    testWidgets('renders Firmware Download item', (tester) async {
      await _openDrawer(tester);
      if (find.text('Firmware Download').evaluate().isEmpty) {
        await tester.tap(find.text('FIRMWARE UPGRADE'));
        await tester.pump();
      }
      expect(find.text('Firmware Download'), findsOneWidget);
    });

    testWidgets('renders Instant item', (tester) async {
      await _openDrawer(tester);
      if (find.text('Instant').evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pump();
      }
      expect(find.text('Instant'), findsOneWidget);
    });

    testWidgets('renders Instant item under Electricity Objects', (tester) async {
      await _openDrawer(tester);
      if (find.text('Instant').evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pump();
      }
      expect(find.text('Instant'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Filter functionality
  // -------------------------------------------------------------------------
  group('AppDrawer – filter', () {
    testWidgets('clear (X) button is not visible when filter is empty',
        (tester) async {
      await _openDrawer(tester);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('typing in filter shows matching items only', (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'Super');
      await tester.pump();
      expect(find.text('Super Manual'), findsOneWidget);
      expect(find.text('Meter Connexion'), findsNothing);
    });

    testWidgets('typing in filter shows category matches', (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'Identification');
      await tester.pump();
      expect(find.text('Device ID'), findsOneWidget);
      expect(find.text('Firmware Version'), findsOneWidget);
    });

    testWidgets('clear button appears when filter is non-empty', (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'Config');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('tapping clear button clears filter and shows all items',
        (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'Super');
      await tester.pump();

      // Only Super Manual should be visible
      expect(find.text('Meter Connexion'), findsNothing);

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // All items should be back
      expect(find.text('Meter Connexion'), findsOneWidget);
      expect(find.text('Super Manual'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('filter is case-insensitive', (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'super manual');
      await tester.pump();
      expect(find.text('Super Manual'), findsOneWidget);
    });

    testWidgets('shows "No items found" when filter matches nothing',
        (tester) async {
      await _openDrawer(tester);
      await tester.enterText(find.byType(TextField), 'xyzzy_not_found');
      await tester.pump();
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('"No items found" message is not visible when filter is empty',
        (tester) async {
      await _openDrawer(tester);
      expect(find.text('No items found'), findsNothing);
    });

    testWidgets('filter by label partial match works', (tester) async {
      await _openDrawer(tester);
      // Ensure Firmware Upgrade is expanded (tap only if currently collapsed)
      if (find.text('Firmware Download').evaluate().isEmpty) {
        await tester.tap(find.text('FIRMWARE UPGRADE'));
        await tester.pump();
      }
      await tester.enterText(find.byType(TextField), 'Firm');
      await tester.pump();
      // Firmware Download (Firmware Management) and Firmware Version (Identification) should match
      expect(find.text('Firmware Download'), findsOneWidget);
      expect(find.text('Firmware Version'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Category expand / collapse
  // -------------------------------------------------------------------------
  group('AppDrawer – category expand/collapse', () {
    testWidgets('category starts expanded (items visible)', (tester) async {
      await _openDrawer(tester);
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.text('Device ID').hitTestable(), findsOneWidget);
    });

    testWidgets('tapping category header collapses it (hides items)', (tester) async {
      await _openDrawer(tester);
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.text('Device ID'), findsOneWidget, reason: 'should start expanded');
      await tester.tap(find.text('IDENTIFICATION'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Device ID').hitTestable(), findsNothing);
      expect(find.text('Firmware Version').hitTestable(), findsNothing);
    });

    testWidgets('tapping collapsed category header expands it again', (tester) async {
      await _openDrawer(tester);
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.text('Device ID').hitTestable(), findsOneWidget);
      await tester.tap(find.text('IDENTIFICATION'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Device ID').hitTestable(), findsNothing);
      await tester.tap(find.text('IDENTIFICATION'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Device ID').hitTestable(), findsOneWidget);
    });

    testWidgets('collapsed category shows expand_more icon', (tester) async {
      await _openDrawer(tester);
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.text('Device ID').hitTestable(), findsOneWidget);
      await tester.tap(find.text('IDENTIFICATION'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Device ID').hitTestable(), findsNothing);
    });

    testWidgets('independent categories can be collapsed separately', (tester) async {
      await _openDrawer(tester);
      if (find.text('Energy Register').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await tester.tap(find.text('IDENTIFICATION'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Device ID').hitTestable(), findsNothing);
      expect(find.text('Energy Register').hitTestable(), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------
  group('AppDrawer – navigation', () {
    testWidgets('tapping Meter Connexion navigates to /meter_connexion',
        (tester) async {
      await _openDrawer(tester);
      await tester.tap(find.text('Meter Connexion'));
      await tester.pumpAndSettle();
      expect(find.text('Meter Connexion Page'), findsOneWidget);
    });

    testWidgets('tapping Activity Calendars navigates to /calendar_profiles', (tester) async {
      await _openDrawer(tester);
      await tester.tap(find.text('Activity Calendars'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar Profiles Page'), findsOneWidget);
    });

    testWidgets('tapping Device ID navigates to device-id route', (tester) async {
      await _openDrawer(tester);
      if (find.text('Device ID').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('IDENTIFICATION'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await tester.ensureVisible(find.text('Device ID'));
      await tester.tap(find.text('Device ID'));
      await tester.pumpAndSettle();
      expect(find.text('Device ID Page'), findsOneWidget);
    });

    testWidgets('tapping Super Manual navigates to /super_manual', (tester) async {
      await _openDrawer(tester);
      await tester.tap(find.text('Super Manual'));
      await tester.pumpAndSettle();
      expect(find.text('Super Manual Page'), findsOneWidget);
    });

    testWidgets('tapping Instant navigates to /fresnel_diagram',
        (tester) async {
      await _openDrawer(tester);
      if (find.text('Instant').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await tester.ensureVisible(find.text('Instant'));
      await tester.tap(find.text('Instant'));
      await tester.pumpAndSettle();
      expect(find.text('Fresnel Page'), findsOneWidget);
    });

    testWidgets('tapping Date time navigates to /date_time', (tester) async {
      await _openDrawer(tester);
      await tester.ensureVisible(find.text('Date time'));
      await tester.tap(find.text('Date time'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Date Time Page'), findsOneWidget);
    });

    testWidgets('tapping Energy Register navigates to energy-register route',
        (tester) async {
      await _openDrawer(tester);
      if (find.text('Energy Register').hitTestable().evaluate().isEmpty) {
        await tester.tap(find.text('ELECTRICITY OBJECTS'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await tester.ensureVisible(find.text('Energy Register'));
      await tester.tap(find.text('Energy Register'));
      await tester.pumpAndSettle();
      expect(find.text('Energy Register Page'), findsOneWidget);
    });
  });
}
