import 'package:grpc/grpc.dart';
import 'generated/configuration.pb.dart';
import 'generated/configuration.pbgrpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

abstract interface class IConfigurationClient {
  Future<bool> setConfig(List<ConfigEntry> entries, bool toFile);
  Future<List<ConfigEntry>> getConfig(List<ConfigIdentifier> identifiers);
  Future<List<String>> listModules();
  Future<bool> setExportTemplates({
    required String pageName,
    String xmlTemplate,
    String csvTemplate,
    String pdfTemplate,
    String docxTemplate,
  });
  Future<GetExportTemplatesResponse> getExportTemplates(String pageName);
  Future<List<ExportTemplateFileEntry>> listExportTemplateFiles();
}

class ConfigurationClient implements IConfigurationClient {
  final String host;
  final int port;

  late final ClientChannel _channel;
  late final ConfigServiceClient _stub;

  ConfigurationClient({
    this.host = '127.0.0.1',
    this.port = 50051,
  }) {
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub = ConfigServiceClient(_channel);
  }

  /// Run query with progress streaming
 // coverage:ignore-start
 @override
 Future<bool> setConfig(List<ConfigEntry> entries,bool to_file) async{
    final req = SetConfigRequest()..entries.addAll(entries)..toFile=to_file;
    final resp = await _stub.setConfig(req);
    return resp.success;
  } // coverage:ignore-end

  // coverage:ignore-start
  @override
  Future<List<ConfigEntry>> getConfig(List<ConfigIdentifier> identifiers) async {
    final req = GetConfigRequest()..identifiers.addAll(identifiers);
    final resp = await _stub.getConfig(req);
    return resp.entries;
  } // coverage:ignore-end


  // coverage:ignore-start
  @override
  Future<List<String>> listModules() async {
    final resp = await _stub.listModules(Empty());
    return resp.modules;
  } // coverage:ignore-end

  // coverage:ignore-start
  @override
  Future<bool> setExportTemplates({
    required String pageName,
    String xmlTemplate = '',
    String csvTemplate = '',
    String pdfTemplate = '',
    String docxTemplate = '',
  }) async {
    final req = SetExportTemplatesRequest()
      ..pageName = pageName
      ..xmlTemplate = xmlTemplate
      ..csvTemplate = csvTemplate
      ..pdfTemplate = pdfTemplate
      ..docxTemplate = docxTemplate;
    final resp = await _stub.setExportTemplates(req);
    return resp.success;
  } // coverage:ignore-end

  // coverage:ignore-start
  @override
  Future<GetExportTemplatesResponse> getExportTemplates(String pageName) async {
    final req = GetExportTemplatesRequest()..pageName = pageName;
    return _stub.getExportTemplates(req);
  } // coverage:ignore-end

  // coverage:ignore-start
  @override
  Future<List<ExportTemplateFileEntry>> listExportTemplateFiles() async {
    final resp = await _stub.listExportTemplateFiles(Empty());
    return resp.entries;
  } // coverage:ignore-end
}
