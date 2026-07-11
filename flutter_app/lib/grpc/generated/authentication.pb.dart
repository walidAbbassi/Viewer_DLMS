// This is a generated file - do not edit.
//
// Generated from authentication.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// ==========================
/// License import (NEW)
/// ==========================
class ImportLicenseRequest extends $pb.GeneratedMessage {
  factory ImportLicenseRequest({
    $core.String? licensePath,
  }) {
    final result = create();
    if (licensePath != null) result.licensePath = licensePath;
    return result;
  }

  ImportLicenseRequest._();

  factory ImportLicenseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportLicenseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportLicenseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'licensePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLicenseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLicenseRequest copyWith(void Function(ImportLicenseRequest) updates) =>
      super.copyWith((message) => updates(message as ImportLicenseRequest))
          as ImportLicenseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportLicenseRequest create() => ImportLicenseRequest._();
  @$core.override
  ImportLicenseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportLicenseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportLicenseRequest>(create);
  static ImportLicenseRequest? _defaultInstance;

  /// Absolute or relative path to the license file
  @$pb.TagNumber(1)
  $core.String get licensePath => $_getSZ(0);
  @$pb.TagNumber(1)
  set licensePath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLicensePath() => $_has(0);
  @$pb.TagNumber(1)
  void clearLicensePath() => $_clearField(1);
}

class ImportLicenseResponse extends $pb.GeneratedMessage {
  factory ImportLicenseResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ImportLicenseResponse._();

  factory ImportLicenseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportLicenseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportLicenseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLicenseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLicenseResponse copyWith(
          void Function(ImportLicenseResponse) updates) =>
      super.copyWith((message) => updates(message as ImportLicenseResponse))
          as ImportLicenseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportLicenseResponse create() => ImportLicenseResponse._();
  @$core.override
  ImportLicenseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportLicenseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportLicenseResponse>(create);
  static ImportLicenseResponse? _defaultInstance;

  /// true if license was imported successfully
  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// non-empty if success == false
  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

/// ==========================
/// Connexion service (NEW)
/// ==========================
class ConnexionRequest extends $pb.GeneratedMessage {
  factory ConnexionRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    return result;
  }

  ConnexionRequest._();

  factory ConnexionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnexionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnexionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnexionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnexionRequest copyWith(void Function(ConnexionRequest) updates) =>
      super.copyWith((message) => updates(message as ConnexionRequest))
          as ConnexionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnexionRequest create() => ConnexionRequest._();
  @$core.override
  ConnexionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnexionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnexionRequest>(create);
  static ConnexionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class ConnexionResponse extends $pb.GeneratedMessage {
  factory ConnexionResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? role,
    $core.Iterable<$core.String>? rights,
    $core.Iterable<$core.String>? disableFeatures,
    $core.String? enterprise,
    $core.String? trialPeriodStart,
    $core.String? trialPeriodEnd,
    $core.Iterable<$core.String>? excludeRights,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (role != null) result.role = role;
    if (rights != null) result.rights.addAll(rights);
    if (disableFeatures != null) result.disableFeatures.addAll(disableFeatures);
    if (enterprise != null) result.enterprise = enterprise;
    if (trialPeriodStart != null) result.trialPeriodStart = trialPeriodStart;
    if (trialPeriodEnd != null) result.trialPeriodEnd = trialPeriodEnd;
    if (excludeRights != null) result.excludeRights.addAll(excludeRights);
    return result;
  }

  ConnexionResponse._();

  factory ConnexionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnexionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnexionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'role')
    ..pPS(4, _omitFieldNames ? '' : 'rights')
    ..pPS(5, _omitFieldNames ? '' : 'disableFeatures')
    ..aOS(6, _omitFieldNames ? '' : 'enterprise')
    ..aOS(7, _omitFieldNames ? '' : 'trialPeriodStart')
    ..aOS(8, _omitFieldNames ? '' : 'trialPeriodEnd')
    ..pPS(9, _omitFieldNames ? '' : 'excludeRights')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnexionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnexionResponse copyWith(void Function(ConnexionResponse) updates) =>
      super.copyWith((message) => updates(message as ConnexionResponse))
          as ConnexionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnexionResponse create() => ConnexionResponse._();
  @$core.override
  ConnexionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnexionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnexionResponse>(create);
  static ConnexionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get role => $_getSZ(2);
  @$pb.TagNumber(3)
  set role($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get rights => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get disableFeatures => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get enterprise => $_getSZ(5);
  @$pb.TagNumber(6)
  set enterprise($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEnterprise() => $_has(5);
  @$pb.TagNumber(6)
  void clearEnterprise() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get trialPeriodStart => $_getSZ(6);
  @$pb.TagNumber(7)
  set trialPeriodStart($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTrialPeriodStart() => $_has(6);
  @$pb.TagNumber(7)
  void clearTrialPeriodStart() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get trialPeriodEnd => $_getSZ(7);
  @$pb.TagNumber(8)
  set trialPeriodEnd($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTrialPeriodEnd() => $_has(7);
  @$pb.TagNumber(8)
  void clearTrialPeriodEnd() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get excludeRights => $_getList(8);
}

class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? username,
    $core.String? oldPassword,
    $core.String? newPassword,
    $core.String? license,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (oldPassword != null) result.oldPassword = oldPassword;
    if (newPassword != null) result.newPassword = newPassword;
    if (license != null) result.license = license;
    return result;
  }

  ChangePasswordRequest._();

  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangePasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'oldPassword')
    ..aOS(3, _omitFieldNames ? '' : 'newPassword')
    ..aOS(4, _omitFieldNames ? '' : 'license')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest copyWith(
          void Function(ChangePasswordRequest) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordRequest))
          as ChangePasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  @$core.override
  ChangePasswordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(create);
  static ChangePasswordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get oldPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set oldPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOldPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearOldPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newPassword => $_getSZ(2);
  @$pb.TagNumber(3)
  set newPassword($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get license => $_getSZ(3);
  @$pb.TagNumber(4)
  set license($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLicense() => $_has(3);
  @$pb.TagNumber(4)
  void clearLicense() => $_clearField(4);
}

class ChangePasswordResponse extends $pb.GeneratedMessage {
  factory ChangePasswordResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  ChangePasswordResponse._();

  factory ChangePasswordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePasswordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangePasswordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse copyWith(
          void Function(ChangePasswordResponse) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordResponse))
          as ChangePasswordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse create() => ChangePasswordResponse._();
  @$core.override
  ChangePasswordResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordResponse>(create);
  static ChangePasswordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// ==========================
/// License check (NEW)
/// ==========================
class LicenseInfo extends $pb.GeneratedMessage {
  factory LicenseInfo({
    $core.String? label,
    $core.String? file,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (file != null) result.file = file;
    return result;
  }

  LicenseInfo._();

  factory LicenseInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LicenseInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LicenseInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'file')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LicenseInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LicenseInfo copyWith(void Function(LicenseInfo) updates) =>
      super.copyWith((message) => updates(message as LicenseInfo))
          as LicenseInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LicenseInfo create() => LicenseInfo._();
  @$core.override
  LicenseInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LicenseInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LicenseInfo>(create);
  static LicenseInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get file => $_getSZ(1);
  @$pb.TagNumber(2)
  set file($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearFile() => $_clearField(2);
}

class CheckLicenseResponse extends $pb.GeneratedMessage {
  factory CheckLicenseResponse({
    $core.bool? exists,
    $core.String? identifier,
    $core.Iterable<LicenseInfo>? licenses,
  }) {
    final result = create();
    if (exists != null) result.exists = exists;
    if (identifier != null) result.identifier = identifier;
    if (licenses != null) result.licenses.addAll(licenses);
    return result;
  }

  CheckLicenseResponse._();

  factory CheckLicenseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckLicenseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckLicenseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'exists')
    ..aOS(2, _omitFieldNames ? '' : 'identifier')
    ..pPM<LicenseInfo>(3, _omitFieldNames ? '' : 'licenses',
        subBuilder: LicenseInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckLicenseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckLicenseResponse copyWith(void Function(CheckLicenseResponse) updates) =>
      super.copyWith((message) => updates(message as CheckLicenseResponse))
          as CheckLicenseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckLicenseResponse create() => CheckLicenseResponse._();
  @$core.override
  CheckLicenseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckLicenseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckLicenseResponse>(create);
  static CheckLicenseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get exists => $_getBF(0);
  @$pb.TagNumber(1)
  set exists($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExists() => $_has(0);
  @$pb.TagNumber(1)
  void clearExists() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get identifier => $_getSZ(1);
  @$pb.TagNumber(2)
  set identifier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentifier() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentifier() => $_clearField(2);

  /// ✅ Array of objects
  @$pb.TagNumber(3)
  $pb.PbList<LicenseInfo> get licenses => $_getList(2);
}

class DeleteLicensesRequest extends $pb.GeneratedMessage {
  factory DeleteLicensesRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    return result;
  }

  DeleteLicensesRequest._();

  factory DeleteLicensesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteLicensesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteLicensesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'authentication'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLicensesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLicensesRequest copyWith(
          void Function(DeleteLicensesRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteLicensesRequest))
          as DeleteLicensesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteLicensesRequest create() => DeleteLicensesRequest._();
  @$core.override
  DeleteLicensesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteLicensesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteLicensesRequest>(create);
  static DeleteLicensesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
