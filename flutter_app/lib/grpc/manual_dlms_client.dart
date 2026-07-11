import 'package:grpc/grpc.dart';
import 'generated/manual_dlms.pb.dart';
import 'generated/manual_dlms.pbgrpc.dart';

/// Thin wrapper around the generated [ManualDlmsServiceClient].
///
/// Each method maps directly to one gRPC RPC defined in manual_dlms.proto.
/// Errors are left as [GrpcError] so callers can display them with
/// [extractGrpcMessage].
class ManualDlmsClient {
  ManualDlmsClient({String host = '127.0.0.1', int port = 50051})
      : _channel = ClientChannel(
          host,
          port: port,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
          ),
        ) {
    _stub = ManualDlmsServiceClient(_channel);
  }

  final ClientChannel _channel;
  late final ManualDlmsServiceClient _stub;

  Future<void> close() => _channel.shutdown();

  // ── Single-object ──────────────────────────────────────────────────────────

  Future<ManualDlmsResult> cosemGet({
    required int classId,
    required String obis,
    required int attribute,
  }) =>
      _stub.cosemGet(CosemGetRequest(
        classId: classId,
        obis: obis,
        attribute: attribute,
      ));

  Future<ManualDlmsResult> cosemSet({
    required int classId,
    required String obis,
    required int attribute,
    required String inputData,
  }) =>
      _stub.cosemSet(CosemSetRequest(
        classId: classId,
        obis: obis,
        attribute: attribute,
        inputData: inputData,
      ));

  Future<ManualDlmsResult> cosemAction({
    required int classId,
    required String obis,
    required int attribute,
    String inputData = '',
  }) =>
      _stub.cosemAction(CosemActionRequest(
        classId: classId,
        obis: obis,
        attribute: attribute,
        inputData: inputData,
      ));

  // ── WITH-LIST ──────────────────────────────────────────────────────────────

  Future<WithListResult> getWithList(List<WithListGetItem> items) =>
      _stub.getWithList(WithListGetRequest(items: items));

  Future<WithListResult> setWithList(List<WithListSetItem> items) =>
      _stub.setWithList(WithListSetRequest(items: items));

  Future<WithListResult> actionWithList(List<WithListActionItem> items) =>
      _stub.actionWithList(WithListActionRequest(items: items));

  // ── Codec ──────────────────────────────────────────────────────────────────

  Future<CodecResult> encode(String xmlInput) =>
      _stub.encode(EncodeRequest(xmlInput: xmlInput));

  Future<CodecResult> decode(String hexInput) =>
      _stub.decode(DecodeRequest(hexInput: hexInput));

  // ── Raw frame ──────────────────────────────────────────────────────────────

  Future<ManualDlmsResult> sendRawFrame(String hexFrame) =>
      _stub.sendRawFrame(SendRawFrameRequest(hexFrame: hexFrame));
}

/// Factory so tests can swap the real client for a mock.
ManualDlmsClient Function() manualDlmsClientFactory =
    () => ManualDlmsClient();
