// This is a generated file - do not edit.
//
// Generated from authentication.proto.

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

import 'authentication.pb.dart' as $0;

export 'authentication.pb.dart';

/// ==========================
/// Service
/// ==========================
@$pb.GrpcServiceName('authentication.AuthenticationService')
class AuthenticationServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthenticationServiceClient(super.channel,
      {super.options, super.interceptors});

  /// Import license file into the system
  $grpc.ResponseFuture<$0.ImportLicenseResponse> importLicense(
    $0.ImportLicenseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importLicense, request, options: options);
  }

  /// Connexion
  $grpc.ResponseFuture<$0.ConnexionResponse> connexion(
    $0.ConnexionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$connexion, request, options: options);
  }

  /// Change password
  $grpc.ResponseFuture<$0.ChangePasswordResponse> changePassword(
    $0.ChangePasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changePassword, request, options: options);
  }

  /// Check if a license exists (no input)
  $grpc.ResponseFuture<$0.CheckLicenseResponse> checkLicense(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkLicense, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteLicenses(
    $0.DeleteLicensesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteLicenses, request, options: options);
  }

  // method descriptors

  static final _$importLicense =
      $grpc.ClientMethod<$0.ImportLicenseRequest, $0.ImportLicenseResponse>(
          '/authentication.AuthenticationService/ImportLicense',
          ($0.ImportLicenseRequest value) => value.writeToBuffer(),
          $0.ImportLicenseResponse.fromBuffer);
  static final _$connexion =
      $grpc.ClientMethod<$0.ConnexionRequest, $0.ConnexionResponse>(
          '/authentication.AuthenticationService/Connexion',
          ($0.ConnexionRequest value) => value.writeToBuffer(),
          $0.ConnexionResponse.fromBuffer);
  static final _$changePassword =
      $grpc.ClientMethod<$0.ChangePasswordRequest, $0.ChangePasswordResponse>(
          '/authentication.AuthenticationService/ChangePassword',
          ($0.ChangePasswordRequest value) => value.writeToBuffer(),
          $0.ChangePasswordResponse.fromBuffer);
  static final _$checkLicense =
      $grpc.ClientMethod<$1.Empty, $0.CheckLicenseResponse>(
          '/authentication.AuthenticationService/CheckLicense',
          ($1.Empty value) => value.writeToBuffer(),
          $0.CheckLicenseResponse.fromBuffer);
  static final _$deleteLicenses =
      $grpc.ClientMethod<$0.DeleteLicensesRequest, $1.Empty>(
          '/authentication.AuthenticationService/DeleteLicenses',
          ($0.DeleteLicensesRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('authentication.AuthenticationService')
abstract class AuthenticationServiceBase extends $grpc.Service {
  $core.String get $name => 'authentication.AuthenticationService';

  AuthenticationServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.ImportLicenseRequest, $0.ImportLicenseResponse>(
            'ImportLicense',
            importLicense_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ImportLicenseRequest.fromBuffer(value),
            ($0.ImportLicenseResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConnexionRequest, $0.ConnexionResponse>(
        'Connexion',
        connexion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConnexionRequest.fromBuffer(value),
        ($0.ConnexionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePasswordRequest,
            $0.ChangePasswordResponse>(
        'ChangePassword',
        changePassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangePasswordRequest.fromBuffer(value),
        ($0.ChangePasswordResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.CheckLicenseResponse>(
        'CheckLicense',
        checkLicense_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.CheckLicenseResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteLicensesRequest, $1.Empty>(
        'DeleteLicenses',
        deleteLicenses_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteLicensesRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.ImportLicenseResponse> importLicense_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportLicenseRequest> $request) async {
    return importLicense($call, await $request);
  }

  $async.Future<$0.ImportLicenseResponse> importLicense(
      $grpc.ServiceCall call, $0.ImportLicenseRequest request);

  $async.Future<$0.ConnexionResponse> connexion_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ConnexionRequest> $request) async {
    return connexion($call, await $request);
  }

  $async.Future<$0.ConnexionResponse> connexion(
      $grpc.ServiceCall call, $0.ConnexionRequest request);

  $async.Future<$0.ChangePasswordResponse> changePassword_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ChangePasswordRequest> $request) async {
    return changePassword($call, await $request);
  }

  $async.Future<$0.ChangePasswordResponse> changePassword(
      $grpc.ServiceCall call, $0.ChangePasswordRequest request);

  $async.Future<$0.CheckLicenseResponse> checkLicense_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return checkLicense($call, await $request);
  }

  $async.Future<$0.CheckLicenseResponse> checkLicense(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> deleteLicenses_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteLicensesRequest> $request) async {
    return deleteLicenses($call, await $request);
  }

  $async.Future<$1.Empty> deleteLicenses(
      $grpc.ServiceCall call, $0.DeleteLicensesRequest request);
}
