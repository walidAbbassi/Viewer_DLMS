import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/grpc/authentication_client.dart';
import 'package:flutter_python_grpc/grpc/generated/authentication.pb.dart';

void main() {
  // -------------------------------------------------------------------------
  // connexionClientFactory
  // -------------------------------------------------------------------------
  group('connexionClientFactory', () {
    test('default factory returns an AuthenticationClient instance', () {
      final client = connexionClientFactory();
      expect(client, isA<AuthenticationClient>());
    });

    test('factory can be overridden and restored', () {
      final original = connexionClientFactory;
      addTearDown(() => connexionClientFactory = original);

      final fake = _FakeAuthClient();
      connexionClientFactory = () => fake;
      expect(connexionClientFactory(), same(fake));
    });
  });

  // -------------------------------------------------------------------------
  // AuthenticationClient – constructor
  // -------------------------------------------------------------------------
  group('AuthenticationClient – constructor', () {
    test('creates client with default host and port', () {
      final client = AuthenticationClient();
      expect(client.host, equals('127.0.0.1'));
      expect(client.port, equals(50051));
    });

    test('creates client with custom host', () {
      final client = AuthenticationClient(host: '192.168.1.10');
      expect(client.host, equals('192.168.1.10'));
      expect(client.port, equals(50051));
    });

    test('creates client with custom port', () {
      final client = AuthenticationClient(port: 9090);
      expect(client.host, equals('127.0.0.1'));
      expect(client.port, equals(9090));
    });

    test('creates client with custom host and port', () {
      final client = AuthenticationClient(host: '10.0.0.1', port: 8080);
      expect(client.host, equals('10.0.0.1'));
      expect(client.port, equals(8080));
    });

    test('default instance implements IAuthenticationClient', () {
      final client = AuthenticationClient();
      expect(client, isA<IAuthenticationClient>());
    });
  });

  // -------------------------------------------------------------------------
  // IAuthenticationClient – interface
  // -------------------------------------------------------------------------
  group('IAuthenticationClient – interface', () {
    test('fake implementation satisfies the interface', () {
      final IAuthenticationClient client = _FakeAuthClient();
      expect(client, isA<IAuthenticationClient>());
    });

    test('fake connexion returns a ConnexionResponse', () async {
      final client = _FakeAuthClient();
      final result = await client.connexion('user', 'pass');
      expect(result, isA<ConnexionResponse>());
    });

    test('fake changePassword returns a ChangePasswordResponse', () async {
      final client = _FakeAuthClient();
      final result = await client.changePassword('user', 'old', 'new','admin');
      expect(result, isA<ChangePasswordResponse>());
    });

    test('fake importLicense returns a bool', () async {
      final client = _FakeAuthClient();
      final result = await client.importLicense('/path/to/license');
      expect(result, isA<bool>());
    });
  });
}

// ---------------------------------------------------------------------------
// Fake implementation of IAuthenticationClient (for interface tests)
// ---------------------------------------------------------------------------
class _FakeAuthClient implements IAuthenticationClient {
  @override
  Future<ConnexionResponse> connexion(String username, String password) async =>
      ConnexionResponse();

  @override
  Future<ChangePasswordResponse> changePassword(
          String username, String oldPassword, String newPassword,String license) async =>
      ChangePasswordResponse();

  @override
  Future<bool> importLicense(String licensePath) async => true;
  
  @override
  Future<CheckLicenseResponse> checkLicense() {
    // TODO: implement checkLicense
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteLicenses(String username, String password) {
    // TODO: implement deleteLicenses
    throw UnimplementedError();
  }
}
