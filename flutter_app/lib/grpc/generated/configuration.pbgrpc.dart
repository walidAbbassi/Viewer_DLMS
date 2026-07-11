// This is a generated file - do not edit.
//
// Generated from configuration.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'configuration.pb.dart' as $0;

export 'configuration.pb.dart';

@$pb.GrpcServiceName('config.ConfigService')
class ConfigServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ConfigServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SetConfigResponse> setConfig(
    $0.SetConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetConfigResponse> getConfig(
    $0.GetConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListModulesResponse> listModules(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listModules, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetExportTemplatesResponse> setExportTemplates(
    $0.SetExportTemplatesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setExportTemplates, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetExportTemplatesResponse> getExportTemplates(
    $0.GetExportTemplatesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getExportTemplates, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListExportTemplateFilesResponse>
      listExportTemplateFiles(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listExportTemplateFiles, request,
        options: options);
  }

  // method descriptors

  static final _$setConfig =
      $grpc.ClientMethod<$0.SetConfigRequest, $0.SetConfigResponse>(
          '/config.ConfigService/SetConfig',
          ($0.SetConfigRequest value) => value.writeToBuffer(),
          $0.SetConfigResponse.fromBuffer);
  static final _$getConfig =
      $grpc.ClientMethod<$0.GetConfigRequest, $0.GetConfigResponse>(
          '/config.ConfigService/GetConfig',
          ($0.GetConfigRequest value) => value.writeToBuffer(),
          $0.GetConfigResponse.fromBuffer);
  static final _$listModules =
      $grpc.ClientMethod<$1.Empty, $0.ListModulesResponse>(
          '/config.ConfigService/ListModules',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ListModulesResponse.fromBuffer);
  static final _$setExportTemplates = $grpc.ClientMethod<
          $0.SetExportTemplatesRequest, $0.SetExportTemplatesResponse>(
      '/config.ConfigService/SetExportTemplates',
      ($0.SetExportTemplatesRequest value) => value.writeToBuffer(),
      $0.SetExportTemplatesResponse.fromBuffer);
  static final _$getExportTemplates = $grpc.ClientMethod<
          $0.GetExportTemplatesRequest, $0.GetExportTemplatesResponse>(
      '/config.ConfigService/GetExportTemplates',
      ($0.GetExportTemplatesRequest value) => value.writeToBuffer(),
      $0.GetExportTemplatesResponse.fromBuffer);
  static final _$listExportTemplateFiles =
      $grpc.ClientMethod<$1.Empty, $0.ListExportTemplateFilesResponse>(
          '/config.ConfigService/ListExportTemplateFiles',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ListExportTemplateFilesResponse.fromBuffer);
}

@$pb.GrpcServiceName('config.ConfigService')
abstract class ConfigServiceBase extends $grpc.Service {
  $core.String get $name => 'config.ConfigService';

  ConfigServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SetConfigRequest, $0.SetConfigResponse>(
        'SetConfig',
        setConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetConfigRequest.fromBuffer(value),
        ($0.SetConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetConfigRequest, $0.GetConfigResponse>(
        'GetConfig',
        getConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetConfigRequest.fromBuffer(value),
        ($0.GetConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListModulesResponse>(
        'ListModules',
        listModules_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListModulesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetExportTemplatesRequest,
            $0.SetExportTemplatesResponse>(
        'SetExportTemplates',
        setExportTemplates_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetExportTemplatesRequest.fromBuffer(value),
        ($0.SetExportTemplatesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetExportTemplatesRequest,
            $0.GetExportTemplatesResponse>(
        'GetExportTemplates',
        getExportTemplates_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetExportTemplatesRequest.fromBuffer(value),
        ($0.GetExportTemplatesResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.Empty, $0.ListExportTemplateFilesResponse>(
            'ListExportTemplateFiles',
            listExportTemplateFiles_Pre,
            false,
            false,
            ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
            ($0.ListExportTemplateFilesResponse value) =>
                value.writeToBuffer()));
  }

  $async.Future<$0.SetConfigResponse> setConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetConfigRequest> $request) async {
    return setConfig($call, await $request);
  }

  $async.Future<$0.SetConfigResponse> setConfig(
      $grpc.ServiceCall call, $0.SetConfigRequest request);

  $async.Future<$0.GetConfigResponse> getConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetConfigRequest> $request) async {
    return getConfig($call, await $request);
  }

  $async.Future<$0.GetConfigResponse> getConfig(
      $grpc.ServiceCall call, $0.GetConfigRequest request);

  $async.Future<$0.ListModulesResponse> listModules_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listModules($call, await $request);
  }

  $async.Future<$0.ListModulesResponse> listModules(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.SetExportTemplatesResponse> setExportTemplates_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetExportTemplatesRequest> $request) async {
    return setExportTemplates($call, await $request);
  }

  $async.Future<$0.SetExportTemplatesResponse> setExportTemplates(
      $grpc.ServiceCall call, $0.SetExportTemplatesRequest request);

  $async.Future<$0.GetExportTemplatesResponse> getExportTemplates_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetExportTemplatesRequest> $request) async {
    return getExportTemplates($call, await $request);
  }

  $async.Future<$0.GetExportTemplatesResponse> getExportTemplates(
      $grpc.ServiceCall call, $0.GetExportTemplatesRequest request);

  $async.Future<$0.ListExportTemplateFilesResponse> listExportTemplateFiles_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listExportTemplateFiles($call, await $request);
  }

  $async.Future<$0.ListExportTemplateFilesResponse> listExportTemplateFiles(
      $grpc.ServiceCall call, $1.Empty request);
}
