import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'generated/logger.pb.dart';
import 'generated/logger.pbgrpc.dart';

class LoggerClient {
  final String host;
  final int port;

  late final ClientChannel _channel;
  late final LogServiceClient _stub;

  LoggerClient({
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
    _stub = LogServiceClient(_channel);
  }

  /// Run query with progress streaming
  Stream<LogLine> streamLogs() {
    final req = Empty();
    return _stub.streamLogs(req);
  }

  
}
