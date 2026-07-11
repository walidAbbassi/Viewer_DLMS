import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/grpc/configuration_client.dart';
import 'package:flutter_python_grpc/grpc/generated/configuration.pb.dart';

void main() {
  // -------------------------------------------------------------------------
  // ConfigurationClient – constructor
  // -------------------------------------------------------------------------
  group('ConfigurationClient – constructor', () {
    test('creates client with default host and port', () {
      final client = ConfigurationClient();
      expect(client.host, equals('127.0.0.1'));
      expect(client.port, equals(50051));
    });

    test('creates client with custom host', () {
      final client = ConfigurationClient(host: '192.168.1.50');
      expect(client.host, equals('192.168.1.50'));
      expect(client.port, equals(50051));
    });

    test('creates client with custom port', () {
      final client = ConfigurationClient(port: 9000);
      expect(client.host, equals('127.0.0.1'));
      expect(client.port, equals(9000));
    });

    test('creates client with custom host and port', () {
      final client = ConfigurationClient(host: '10.0.0.5', port: 8080);
      expect(client.host, equals('10.0.0.5'));
      expect(client.port, equals(8080));
    });

    test('default instance implements IConfigurationClient', () {
      final client = ConfigurationClient();
      expect(client, isA<IConfigurationClient>());
    });
  });

  // -------------------------------------------------------------------------
  // IConfigurationClient – interface
  // -------------------------------------------------------------------------
  group('IConfigurationClient – interface', () {
    test('fake implementation satisfies the interface', () {
      final IConfigurationClient client = _FakeConfigClient();
      expect(client, isA<IConfigurationClient>());
    });

    test('fake setConfig returns a bool', () async {
      final client = _FakeConfigClient();
      final result = await client.setConfig([], false);
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    test('fake setConfig with toFile=true returns true', () async {
      final client = _FakeConfigClient();
      final result = await client.setConfig(
          [ConfigEntry()..module = 'mod'..key = 'k'],
          true);
      expect(result, isTrue);
    });

    test('fake getConfig returns a list of ConfigEntry', () async {
      final client = _FakeConfigClient();
      final result = await client.getConfig([ConfigIdentifier()..module = 'mod'..key = 'k']);
      expect(result, isA<List<ConfigEntry>>());
    });

    test('fake listModules returns a list of strings', () async {
      final client = _FakeConfigClient();
      final result = await client.listModules();
      expect(result, isA<List<String>>());
      expect(result, equals(['module1', 'module2']));
    });

    test('fake getConfig with multiple identifiers returns entries', () async {
      final client = _FakeConfigClient();
      final ids = [
        ConfigIdentifier()..module = 'a',
        ConfigIdentifier()..module = 'b',
      ];
      final result = await client.getConfig(ids);
      expect(result, isA<List<ConfigEntry>>());
      expect(result.length, equals(2));
    });
  });
}

// ---------------------------------------------------------------------------
// Fake implementation of IConfigurationClient used for interface tests
// ---------------------------------------------------------------------------
class _FakeConfigClient implements IConfigurationClient {
  @override
  Future<bool> setConfig(List<ConfigEntry> entries, bool toFile) async => true;

  @override
  Future<List<ConfigEntry>> getConfig(List<ConfigIdentifier> identifiers) async =>
      identifiers.map((_) => ConfigEntry()).toList();

  @override
  Future<List<String>> listModules() async => ['module1', 'module2'];
  
  @override
  Future<GetExportTemplatesResponse> getExportTemplates(String pageName) {
    // TODO: implement getExportTemplates
    throw UnimplementedError();
  }
  
  @override
  Future<List<ExportTemplateFileEntry>> listExportTemplateFiles() {
    // TODO: implement listExportTemplateFiles
    throw UnimplementedError();
  }
  
  @override
  Future<bool> setExportTemplates({required String pageName, String xmlTemplate="", String csvTemplate="", String pdfTemplate="", String docxTemplate=""}) {
    // TODO: implement setExportTemplates
    throw UnimplementedError();
  }
}
