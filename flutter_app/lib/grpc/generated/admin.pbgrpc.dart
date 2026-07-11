// This is a generated file - do not edit.
//
// Generated from admin.proto.

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

import 'admin.pb.dart' as $0;

export 'admin.pb.dart';

/// Simple authenticated shutdown
@$pb.GrpcServiceName('admin.Admin')
class AdminClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AdminClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ShutdownReply> shutdown(
    $0.ShutdownRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$shutdown, request, options: options);
  }

  // method descriptors

  static final _$shutdown =
      $grpc.ClientMethod<$0.ShutdownRequest, $0.ShutdownReply>(
          '/admin.Admin/Shutdown',
          ($0.ShutdownRequest value) => value.writeToBuffer(),
          $0.ShutdownReply.fromBuffer);
}

@$pb.GrpcServiceName('admin.Admin')
abstract class AdminServiceBase extends $grpc.Service {
  $core.String get $name => 'admin.Admin';

  AdminServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ShutdownRequest, $0.ShutdownReply>(
        'Shutdown',
        shutdown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ShutdownRequest.fromBuffer(value),
        ($0.ShutdownReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.ShutdownReply> shutdown_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ShutdownRequest> $request) async {
    return shutdown($call, await $request);
  }

  $async.Future<$0.ShutdownReply> shutdown(
      $grpc.ServiceCall call, $0.ShutdownRequest request);
}
