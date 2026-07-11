import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../grpc/generated/meter.pb.dart';
import '../grpc/meter_client.dart';
import 'app_controller.dart';

/// Streams retry status updates from the backend.
/// Active only while the app is connected to a meter.
final retryStatusProvider =
    StreamProvider.autoDispose<RetryStatusUpdate>((ref) {
  final isConnected = ref.watch(appControllerProvider).isConnected;
  if (!isConnected) return const Stream.empty();
  final client = MeterClient();
  ref.onDispose(client.close);
  return client.watchRetryStatus();
});
