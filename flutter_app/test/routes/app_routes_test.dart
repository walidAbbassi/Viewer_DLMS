import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/core/user_rights.dart';
import 'package:flutter_python_grpc/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('has correct route names', () {
      expect(AppRoutes.connexion, equals('/connexion'));
      expect(AppRoutes.meterConnexion, equals('/meter_connexion'));
      expect(AppRoutes.identificationDeviceId, isNotNull);
      expect(AppRoutes.energyRegister, isNotNull);
      expect(AppRoutes.loadProfileBase, equals('/load_profile'));
      expect(AppRoutes.eventLogsBase, equals('/event_logs_cfg'));
      expect(AppRoutes.dateTime, equals('/date_time'));
      expect(AppRoutes.firmware, equals('/firmware'));
    });

    test('routes map contains all route names', () {
      expect(AppRoutes.routes, isNotEmpty);
      expect(AppRoutes.routes.containsKey(AppRoutes.connexion), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.meterConnexion), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.dateTime), isTrue);
    });

    test('onGenerateRoute redirects unknown routes to connexion when unauthenticated', () {
      userRights.reset();
      final settings = const RouteSettings(name: '/unknown');
      final route = AppRoutes.onGenerateRoute(settings);

      expect(route, isA<MaterialPageRoute>());
      expect(route?.settings.name, equals(AppRoutes.connexion));
    });

    test('onGenerateRoute handles load profile routes', () {
      final settings = RouteSettings(name: '/load_profile/profile1');
      final route = AppRoutes.onGenerateRoute(settings);
      
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    test('onGenerateRoute handles event logs routes', () {
      final settings = RouteSettings(name: '/event_logs_cfg/log1');
      final route = AppRoutes.onGenerateRoute(settings);
      
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    test('loadProfileRoute generates correct path', () {
      final route = AppRoutes.loadProfileRoute('profile123');
      expect(route, equals('/load_profile/profile123'));
    });

    test('eventLogsRoute generates correct path', () {
      final route = AppRoutes.eventLogsRoute('log456');
      expect(route, equals('/event_logs_cfg/log456'));
    });

    test('route names are unique', () {
      final routeNames = [
        AppRoutes.connexion,
        AppRoutes.meterConnexion,
        AppRoutes.identificationDeviceId,
        AppRoutes.energyRegister,
        AppRoutes.loadProfileBase,
        AppRoutes.eventLogsBase,
        AppRoutes.dateTime,
        AppRoutes.firmware,
      ];
      
      final uniqueNames = routeNames.toSet();
      expect(uniqueNames.length, equals(routeNames.length));
    });
  });
}
