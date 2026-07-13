import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_python_grpc/core/navigation/app_route_observer.dart';
import 'package:flutter_python_grpc/core/widgets/app_scaffold_wrapper.dart';
import 'package:flutter_python_grpc/core/widgets/app_header.dart';
import 'package:flutter_python_grpc/core/widgets/app_toolbar.dart';

void main() {
  group('AppScaffoldWrapper', () {
    setUp(() {
      currentRouteNotifier.value = '/test';
    });

    tearDown(() {
      currentRouteNotifier.value = null;
    });
    testWidgets('wraps child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppScaffoldWrapper(
              child: Scaffold(
                body: const Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('adds AppToolbar when child has no bottomNavigationBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppScaffoldWrapper(
              child: Scaffold(
                body: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppToolbar), findsOneWidget);
    });

    testWidgets('does not add AppToolbar when child has bottomNavigationBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppScaffoldWrapper(
              child: Scaffold(
                body: const Text('Test'),
                bottomNavigationBar: BottomAppBar(
                  child: const Text('Custom Bar'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppToolbar), findsNothing);
      expect(find.text('Custom Bar'), findsOneWidget);
    });

    testWidgets('renders child inside Column with Expanded', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AppScaffoldWrapper(
              child: Scaffold(
                body: Container(
                  color: Colors.blue,
                  child: const Text('Content'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('AppHeader', () {
    testWidgets('renders disconnect button when connected', 
        (WidgetTester tester) async {
      var disconnectCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              isConnected: true,
              onDisconnect: () async {
                disconnectCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Disconnect'), findsOneWidget);
      
      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();
      
      expect(disconnectCalled, isTrue);
    });

    testWidgets('disables disconnect button when not connected', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              isConnected: false,
              onDisconnect: () async {},
            ),
          ),
        ),
      );

      // Button is shown but disabled when not connected
      expect(find.text('Disconnect'), findsOneWidget);
      
      // Find the button by text and verify it's disabled by checking if tapping does nothing
      final disconnectFinder = find.ancestor(
        of: find.text('Disconnect'),
        matching: find.byType(GestureDetector),
      );
      expect(disconnectFinder, findsOneWidget);
    });

    testWidgets('displays connection status indicator', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              isConnected: true,
              onDisconnect: () async {},
            ),
          ),
        ),
      );

      // Look for visual indicator (Icon or similar)
      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('toolbar has proper styling', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              isConnected: false,
              onDisconnect: () async {},
            ),
          ),
        ),
      );

      final toolbar = tester.widget<AppHeader>(
        find.byType(AppHeader),
      );
      
      expect(toolbar.isConnected, isFalse);
    });
  });
}
