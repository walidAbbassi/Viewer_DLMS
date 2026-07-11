// This is a generated file - do not edit.
//
// Generated from logger.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'logger.pb.dart' as $1;

export 'logger.pb.dart';

/// Service pour streamer les logs en temps réel
@$pb.GrpcServiceName('logs.LogService')
class LogServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LogServiceClient(super.channel, {super.options, super.interceptors});

  /// Appel gRPC de type server-streaming
  $grpc.ResponseStream<$1.LogLine> streamLogs(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamLogs, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$streamLogs = $grpc.ClientMethod<$0.Empty, $1.LogLine>(
      '/logs.LogService/StreamLogs',
      ($0.Empty value) => value.writeToBuffer(),
      $1.LogLine.fromBuffer);
}

@$pb.GrpcServiceName('logs.LogService')
abstract class LogServiceBase extends $grpc.Service {
  $core.String get $name => 'logs.LogService';

  LogServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.LogLine>(
        'StreamLogs',
        streamLogs_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.LogLine value) => value.writeToBuffer()));
  }

  $async.Stream<$1.LogLine> streamLogs_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* streamLogs($call, await $request);
  }

  $async.Stream<$1.LogLine> streamLogs(
      $grpc.ServiceCall call, $0.Empty request);
}
