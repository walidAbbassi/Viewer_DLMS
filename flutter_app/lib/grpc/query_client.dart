import 'package:grpc/grpc.dart';
import 'generated/progress.pb.dart';
import 'generated/progress.pbgrpc.dart';

class QueryClient {
  final String host;
  final int port;

  late final ClientChannel _channel;
  late final QueryServiceClient _stub;

  QueryClient({
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
    _stub = QueryServiceClient(_channel);
  }

  /// Run query with progress streaming
  Stream<ProgressUpdate> runQuery(String query) {
    final req = QueryRequest()..query = query;
    return _stub.runQuery(req);
  }

  
}
