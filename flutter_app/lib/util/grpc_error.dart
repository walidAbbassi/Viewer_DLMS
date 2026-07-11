import 'package:grpc/grpc.dart' show GrpcError;

/// Extracts a human-readable message from any exception.
/// Prefers [GrpcError.message] (the backend-supplied text) over the raw
/// `toString()` representation, which is cryptic for gRPC errors.
String extractGrpcMessage(dynamic e) {
  if (e is GrpcError) {
    final msg = e.message;
    if (msg != null && msg.isNotEmpty) return msg;
  }
  return e.toString().replaceFirst('Exception: ', '');
}
