import 'package:grpc/grpc.dart';
import 'generated/admin.pb.dart';
import 'generated/admin.pbgrpc.dart';

class AdminRpc {
  final ClientChannel _channel;
  final AdminClient _stub;

  AdminRpc(String host, int port)
      : _channel = ClientChannel(
          host,
          port: port,
          options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
        ),
        _stub = AdminClient(ClientChannel(
          host,
          port: port,
          options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
        ));

  Future<bool> shutdown(String token) async {
    try {
      final resp = await _stub.shutdown(ShutdownRequest()..token = token);
      return resp.ok;
    } catch (_) {
      return false;
    } finally {
      await _channel.shutdown();
    }
  }
}
