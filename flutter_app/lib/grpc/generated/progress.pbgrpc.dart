// This is a generated file - do not edit.
//
// Generated from progress.proto.

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

import 'progress.pb.dart' as $0;

export 'progress.pb.dart';

/// Service definition
@$pb.GrpcServiceName('progress.QueryService')
class QueryServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  QueryServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.ProgressUpdate> runQuery(
    $0.QueryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$runQuery, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$runQuery =
      $grpc.ClientMethod<$0.QueryRequest, $0.ProgressUpdate>(
          '/progress.QueryService/RunQuery',
          ($0.QueryRequest value) => value.writeToBuffer(),
          $0.ProgressUpdate.fromBuffer);
}

@$pb.GrpcServiceName('progress.QueryService')
abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'progress.QueryService';

  QueryServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.QueryRequest, $0.ProgressUpdate>(
        'RunQuery',
        runQuery_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.QueryRequest.fromBuffer(value),
        ($0.ProgressUpdate value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ProgressUpdate> runQuery_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.QueryRequest> $request) async* {
    yield* runQuery($call, await $request);
  }

  $async.Stream<$0.ProgressUpdate> runQuery(
      $grpc.ServiceCall call, $0.QueryRequest request);
}
