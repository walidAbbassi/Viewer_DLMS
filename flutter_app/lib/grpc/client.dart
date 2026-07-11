// lib/grpc/client.dart
import 'package:grpc/grpc.dart';
import 'generated/echo.pb.dart';
import 'generated/echo.pbgrpc.dart';

class RpcClient {
  final String host;
  final int port;

  late final ClientChannel _channel;
  late final EchoClient _stub;

  RpcClient({
    this.host = '127.0.0.1',
    this.port = 50051,
  }) {
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        // You can tweak these if needed:
        // connectionTimeout: Duration(seconds: 5),
        // idleTimeout: Duration(minutes: 5),
        // userAgent: 'flutter-python-grpc',
      ),
    );
    _stub = EchoClient(_channel);
  }

  /// Echo a message through the Python server.
  Future<String> say(String message) async {
    final resp = await _stub.say(EchoRequest(message: message));
    return resp.message;
  }

  /// Sum numbers on the Python server.
  Future<int> sum(Iterable<int> numbers) async {
    final req = SumRequest(numbers: numbers.map((e) => e));
    final resp = await _stub.sum(req);
    return resp.sum.toInt();
  }

  
  
}
