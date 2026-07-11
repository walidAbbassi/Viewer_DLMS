// This is a generated file - do not edit.
//
// Generated from echo.proto.

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

import 'echo.pb.dart' as $0;

export 'echo.pb.dart';

/// Simple demo service
@$pb.GrpcServiceName('demo.Echo')
class EchoClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  EchoClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.EchoReply> say(
    $0.EchoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$say, request, options: options);
  }

  $grpc.ResponseFuture<$0.SumReply> sum(
    $0.SumRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sum, request, options: options);
  }

  // method descriptors

  static final _$say = $grpc.ClientMethod<$0.EchoRequest, $0.EchoReply>(
      '/demo.Echo/Say',
      ($0.EchoRequest value) => value.writeToBuffer(),
      $0.EchoReply.fromBuffer);
  static final _$sum = $grpc.ClientMethod<$0.SumRequest, $0.SumReply>(
      '/demo.Echo/Sum',
      ($0.SumRequest value) => value.writeToBuffer(),
      $0.SumReply.fromBuffer);
}

@$pb.GrpcServiceName('demo.Echo')
abstract class EchoServiceBase extends $grpc.Service {
  $core.String get $name => 'demo.Echo';

  EchoServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoReply>(
        'Say',
        say_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SumRequest, $0.SumReply>(
        'Sum',
        sum_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SumRequest.fromBuffer(value),
        ($0.SumReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.EchoReply> say_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EchoRequest> $request) async {
    return say($call, await $request);
  }

  $async.Future<$0.EchoReply> say(
      $grpc.ServiceCall call, $0.EchoRequest request);

  $async.Future<$0.SumReply> sum_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SumRequest> $request) async {
    return sum($call, await $request);
  }

  $async.Future<$0.SumReply> sum($grpc.ServiceCall call, $0.SumRequest request);
}
