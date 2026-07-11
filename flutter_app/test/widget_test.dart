import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:provider/provider.dart' as provider;
import 'package:flutter_python_grpc/features/services/auth_provider.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(
      provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const ProviderScope(
          child: SmartMeterApp(),
        ),
      ),
    );

    // Wait for splash screen
    await tester.pump();
    
    // Verify the app is built
    expect(find.byType(SmartMeterApp), findsOneWidget);
  });
  
  testWidgets('SmartMeterApp renders ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const ProviderScope(
          child: SmartMeterApp(),
        ),
      ),
    );

    await tester.pump();
    
    // Verify ProviderScope is present
    expect(find.byType(ProviderScope), findsWidgets);
  });
}
