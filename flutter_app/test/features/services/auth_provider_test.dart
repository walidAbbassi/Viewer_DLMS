import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/features/services/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    test('initial state', () {
      final p = AuthProvider();
      expect(p.username, isNull);
      expect(p.isLoggedIn, isFalse);
    });

    test('login failure keeps state unchanged when backend is unavailable', () async {
      final p = AuthProvider();
      var notifications = 0;
      p.addListener(() => notifications += 1);

      final error = await p.login('alice', 'secret');

      expect(error, isNotNull);
      expect(p.username, isNull);
      expect(p.isLoggedIn, isFalse);
      expect(notifications, equals(0));
    });

    test('login with empty credentials does nothing (no notify)', () {
      final p = AuthProvider();
      var notifications = 0;
      p.addListener(() => notifications += 1);

      p.login('', 'secret');
      p.login('alice', '');
      p.login('', '');

      expect(p.username, isNull);
      expect(p.isLoggedIn, isFalse);
      expect(notifications, equals(0));
    });

    test('logout clears state and notifies', () async {
      final p = AuthProvider();
      var notifications = 0;
      p.addListener(() => notifications += 1);

      await p.login('alice', 'secret');
      p.logout();

      expect(p.username, isNull);
      expect(p.isLoggedIn, isFalse);
      expect(notifications, equals(1));
    });
  });
}
