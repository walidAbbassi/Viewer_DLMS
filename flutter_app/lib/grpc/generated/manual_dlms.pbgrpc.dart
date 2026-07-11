// This is a generated file - do not edit.
//
// Generated from manual_dlms.proto.

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

import 'manual_dlms.pb.dart' as $0;

export 'manual_dlms.pb.dart';

@$pb.GrpcServiceName('manual_dlms.ManualDlmsService')
class ManualDlmsServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ManualDlmsServiceClient(super.channel, {super.options, super.interceptors});

  /// Perform a COSEM GET (read) request.
  $grpc.ResponseFuture<$0.ManualDlmsResult> cosemGet(
    $0.CosemGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cosemGet, request, options: options);
  }

  /// Perform a COSEM SET (write) request.
  /// The payload field accepts either XML or a raw XDR hex string.
  $grpc.ResponseFuture<$0.ManualDlmsResult> cosemSet(
    $0.CosemSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cosemSet, request, options: options);
  }

  /// Perform a COSEM ACTION (method invoke) request.
  /// The payload field accepts either XML or a raw XDR hex string.
  $grpc.ResponseFuture<$0.ManualDlmsResult> cosemAction(
    $0.CosemActionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cosemAction, request, options: options);
  }

  /// Perform GET-WITH-LIST (multiple reads in one PDU).
  $grpc.ResponseFuture<$0.WithListResult> getWithList(
    $0.WithListGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getWithList, request, options: options);
  }

  /// Perform SET-WITH-LIST (multiple writes in one PDU).
  $grpc.ResponseFuture<$0.WithListResult> setWithList(
    $0.WithListSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setWithList, request, options: options);
  }

  /// Perform ACTION-WITH-LIST (multiple invocations in one PDU).
  $grpc.ResponseFuture<$0.WithListResult> actionWithList(
    $0.WithListActionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$actionWithList, request, options: options);
  }

  /// Convert an XML data-type tree to an uppercase XDR hex string.
  $grpc.ResponseFuture<$0.CodecResult> encode(
    $0.EncodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$encode, request, options: options);
  }

  /// Convert an XDR hex string to a pretty-printed XML string.
  $grpc.ResponseFuture<$0.CodecResult> decode(
    $0.DecodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$decode, request, options: options);
  }

  /// Send a raw DLMS APDU frame and return the response.
  $grpc.ResponseFuture<$0.ManualDlmsResult> sendRawFrame(
    $0.SendRawFrameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendRawFrame, request, options: options);
  }

  // method descriptors

  static final _$cosemGet =
      $grpc.ClientMethod<$0.CosemGetRequest, $0.ManualDlmsResult>(
          '/manual_dlms.ManualDlmsService/CosemGet',
          ($0.CosemGetRequest value) => value.writeToBuffer(),
          $0.ManualDlmsResult.fromBuffer);
  static final _$cosemSet =
      $grpc.ClientMethod<$0.CosemSetRequest, $0.ManualDlmsResult>(
          '/manual_dlms.ManualDlmsService/CosemSet',
          ($0.CosemSetRequest value) => value.writeToBuffer(),
          $0.ManualDlmsResult.fromBuffer);
  static final _$cosemAction =
      $grpc.ClientMethod<$0.CosemActionRequest, $0.ManualDlmsResult>(
          '/manual_dlms.ManualDlmsService/CosemAction',
          ($0.CosemActionRequest value) => value.writeToBuffer(),
          $0.ManualDlmsResult.fromBuffer);
  static final _$getWithList =
      $grpc.ClientMethod<$0.WithListGetRequest, $0.WithListResult>(
          '/manual_dlms.ManualDlmsService/GetWithList',
          ($0.WithListGetRequest value) => value.writeToBuffer(),
          $0.WithListResult.fromBuffer);
  static final _$setWithList =
      $grpc.ClientMethod<$0.WithListSetRequest, $0.WithListResult>(
          '/manual_dlms.ManualDlmsService/SetWithList',
          ($0.WithListSetRequest value) => value.writeToBuffer(),
          $0.WithListResult.fromBuffer);
  static final _$actionWithList =
      $grpc.ClientMethod<$0.WithListActionRequest, $0.WithListResult>(
          '/manual_dlms.ManualDlmsService/ActionWithList',
          ($0.WithListActionRequest value) => value.writeToBuffer(),
          $0.WithListResult.fromBuffer);
  static final _$encode = $grpc.ClientMethod<$0.EncodeRequest, $0.CodecResult>(
      '/manual_dlms.ManualDlmsService/Encode',
      ($0.EncodeRequest value) => value.writeToBuffer(),
      $0.CodecResult.fromBuffer);
  static final _$decode = $grpc.ClientMethod<$0.DecodeRequest, $0.CodecResult>(
      '/manual_dlms.ManualDlmsService/Decode',
      ($0.DecodeRequest value) => value.writeToBuffer(),
      $0.CodecResult.fromBuffer);
  static final _$sendRawFrame =
      $grpc.ClientMethod<$0.SendRawFrameRequest, $0.ManualDlmsResult>(
          '/manual_dlms.ManualDlmsService/SendRawFrame',
          ($0.SendRawFrameRequest value) => value.writeToBuffer(),
          $0.ManualDlmsResult.fromBuffer);
}

@$pb.GrpcServiceName('manual_dlms.ManualDlmsService')
abstract class ManualDlmsServiceBase extends $grpc.Service {
  $core.String get $name => 'manual_dlms.ManualDlmsService';

  ManualDlmsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CosemGetRequest, $0.ManualDlmsResult>(
        'CosemGet',
        cosemGet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CosemGetRequest.fromBuffer(value),
        ($0.ManualDlmsResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CosemSetRequest, $0.ManualDlmsResult>(
        'CosemSet',
        cosemSet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CosemSetRequest.fromBuffer(value),
        ($0.ManualDlmsResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CosemActionRequest, $0.ManualDlmsResult>(
        'CosemAction',
        cosemAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CosemActionRequest.fromBuffer(value),
        ($0.ManualDlmsResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WithListGetRequest, $0.WithListResult>(
        'GetWithList',
        getWithList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WithListGetRequest.fromBuffer(value),
        ($0.WithListResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WithListSetRequest, $0.WithListResult>(
        'SetWithList',
        setWithList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WithListSetRequest.fromBuffer(value),
        ($0.WithListResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WithListActionRequest, $0.WithListResult>(
        'ActionWithList',
        actionWithList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WithListActionRequest.fromBuffer(value),
        ($0.WithListResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EncodeRequest, $0.CodecResult>(
        'Encode',
        encode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EncodeRequest.fromBuffer(value),
        ($0.CodecResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DecodeRequest, $0.CodecResult>(
        'Decode',
        decode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DecodeRequest.fromBuffer(value),
        ($0.CodecResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendRawFrameRequest, $0.ManualDlmsResult>(
        'SendRawFrame',
        sendRawFrame_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SendRawFrameRequest.fromBuffer(value),
        ($0.ManualDlmsResult value) => value.writeToBuffer()));
  }

  $async.Future<$0.ManualDlmsResult> cosemGet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CosemGetRequest> $request) async {
    return cosemGet($call, await $request);
  }

  $async.Future<$0.ManualDlmsResult> cosemGet(
      $grpc.ServiceCall call, $0.CosemGetRequest request);

  $async.Future<$0.ManualDlmsResult> cosemSet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CosemSetRequest> $request) async {
    return cosemSet($call, await $request);
  }

  $async.Future<$0.ManualDlmsResult> cosemSet(
      $grpc.ServiceCall call, $0.CosemSetRequest request);

  $async.Future<$0.ManualDlmsResult> cosemAction_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CosemActionRequest> $request) async {
    return cosemAction($call, await $request);
  }

  $async.Future<$0.ManualDlmsResult> cosemAction(
      $grpc.ServiceCall call, $0.CosemActionRequest request);

  $async.Future<$0.WithListResult> getWithList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WithListGetRequest> $request) async {
    return getWithList($call, await $request);
  }

  $async.Future<$0.WithListResult> getWithList(
      $grpc.ServiceCall call, $0.WithListGetRequest request);

  $async.Future<$0.WithListResult> setWithList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WithListSetRequest> $request) async {
    return setWithList($call, await $request);
  }

  $async.Future<$0.WithListResult> setWithList(
      $grpc.ServiceCall call, $0.WithListSetRequest request);

  $async.Future<$0.WithListResult> actionWithList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WithListActionRequest> $request) async {
    return actionWithList($call, await $request);
  }

  $async.Future<$0.WithListResult> actionWithList(
      $grpc.ServiceCall call, $0.WithListActionRequest request);

  $async.Future<$0.CodecResult> encode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EncodeRequest> $request) async {
    return encode($call, await $request);
  }

  $async.Future<$0.CodecResult> encode(
      $grpc.ServiceCall call, $0.EncodeRequest request);

  $async.Future<$0.CodecResult> decode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DecodeRequest> $request) async {
    return decode($call, await $request);
  }

  $async.Future<$0.CodecResult> decode(
      $grpc.ServiceCall call, $0.DecodeRequest request);

  $async.Future<$0.ManualDlmsResult> sendRawFrame_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendRawFrameRequest> $request) async {
    return sendRawFrame($call, await $request);
  }

  $async.Future<$0.ManualDlmsResult> sendRawFrame(
      $grpc.ServiceCall call, $0.SendRawFrameRequest request);
}
