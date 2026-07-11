// This is a generated file - do not edit.
//
// Generated from configuration.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ConfigEntry extends $pb.GeneratedMessage {
  factory ConfigEntry({
    $core.String? module,
    $core.String? key,
    $2.Any? value,
  }) {
    final result = create();
    if (module != null) result.module = module;
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  ConfigEntry._();

  factory ConfigEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'module')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..aOM<$2.Any>(3, _omitFieldNames ? '' : 'value', subBuilder: $2.Any.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigEntry copyWith(void Function(ConfigEntry) updates) =>
      super.copyWith((message) => updates(message as ConfigEntry))
          as ConfigEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigEntry create() => ConfigEntry._();
  @$core.override
  ConfigEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigEntry>(create);
  static ConfigEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get module => $_getSZ(0);
  @$pb.TagNumber(1)
  set module($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasModule() => $_has(0);
  @$pb.TagNumber(1)
  void clearModule() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Any get value => $_getN(2);
  @$pb.TagNumber(3)
  set value($2.Any value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Any ensureValue() => $_ensure(2);
}

class SetConfigRequest extends $pb.GeneratedMessage {
  factory SetConfigRequest({
    $core.Iterable<ConfigEntry>? entries,
    $core.bool? toFile,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (toFile != null) result.toFile = toFile;
    return result;
  }

  SetConfigRequest._();

  factory SetConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..pPM<ConfigEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ConfigEntry.create)
    ..aOB(2, _omitFieldNames ? '' : 'toFile')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetConfigRequest copyWith(void Function(SetConfigRequest) updates) =>
      super.copyWith((message) => updates(message as SetConfigRequest))
          as SetConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetConfigRequest create() => SetConfigRequest._();
  @$core.override
  SetConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetConfigRequest>(create);
  static SetConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConfigEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get toFile => $_getBF(1);
  @$pb.TagNumber(2)
  set toFile($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearToFile() => $_clearField(2);
}

class SetConfigResponse extends $pb.GeneratedMessage {
  factory SetConfigResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  SetConfigResponse._();

  factory SetConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetConfigResponse copyWith(void Function(SetConfigResponse) updates) =>
      super.copyWith((message) => updates(message as SetConfigResponse))
          as SetConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetConfigResponse create() => SetConfigResponse._();
  @$core.override
  SetConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetConfigResponse>(create);
  static SetConfigResponse? _defaultInstance;

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

class ConfigIdentifier extends $pb.GeneratedMessage {
  factory ConfigIdentifier({
    $core.String? module,
    $core.String? key,
  }) {
    final result = create();
    if (module != null) result.module = module;
    if (key != null) result.key = key;
    return result;
  }

  ConfigIdentifier._();

  factory ConfigIdentifier.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigIdentifier.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigIdentifier',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'module')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigIdentifier clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigIdentifier copyWith(void Function(ConfigIdentifier) updates) =>
      super.copyWith((message) => updates(message as ConfigIdentifier))
          as ConfigIdentifier;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigIdentifier create() => ConfigIdentifier._();
  @$core.override
  ConfigIdentifier createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigIdentifier getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigIdentifier>(create);
  static ConfigIdentifier? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get module => $_getSZ(0);
  @$pb.TagNumber(1)
  set module($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasModule() => $_has(0);
  @$pb.TagNumber(1)
  void clearModule() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
}

class GetConfigRequest extends $pb.GeneratedMessage {
  factory GetConfigRequest({
    $core.Iterable<ConfigIdentifier>? identifiers,
  }) {
    final result = create();
    if (identifiers != null) result.identifiers.addAll(identifiers);
    return result;
  }

  GetConfigRequest._();

  factory GetConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..pPM<ConfigIdentifier>(1, _omitFieldNames ? '' : 'identifiers',
        subBuilder: ConfigIdentifier.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest copyWith(void Function(GetConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetConfigRequest))
          as GetConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigRequest create() => GetConfigRequest._();
  @$core.override
  GetConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConfigRequest>(create);
  static GetConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConfigIdentifier> get identifiers => $_getList(0);
}

class GetConfigResponse extends $pb.GeneratedMessage {
  factory GetConfigResponse({
    $core.Iterable<ConfigEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  GetConfigResponse._();

  factory GetConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..pPM<ConfigEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ConfigEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigResponse copyWith(void Function(GetConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetConfigResponse))
          as GetConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigResponse create() => GetConfigResponse._();
  @$core.override
  GetConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConfigResponse>(create);
  static GetConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConfigEntry> get entries => $_getList(0);
}

class ListModulesResponse extends $pb.GeneratedMessage {
  factory ListModulesResponse({
    $core.Iterable<$core.String>? modules,
  }) {
    final result = create();
    if (modules != null) result.modules.addAll(modules);
    return result;
  }

  ListModulesResponse._();

  factory ListModulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListModulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListModulesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'modules')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListModulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListModulesResponse copyWith(void Function(ListModulesResponse) updates) =>
      super.copyWith((message) => updates(message as ListModulesResponse))
          as ListModulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListModulesResponse create() => ListModulesResponse._();
  @$core.override
  ListModulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListModulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListModulesResponse>(create);
  static ListModulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get modules => $_getList(0);
}

class SetExportTemplatesRequest extends $pb.GeneratedMessage {
  factory SetExportTemplatesRequest({
    $core.String? pageName,
    $core.String? xmlTemplate,
    $core.String? csvTemplate,
    $core.String? pdfTemplate,
    $core.String? docxTemplate,
  }) {
    final result = create();
    if (pageName != null) result.pageName = pageName;
    if (xmlTemplate != null) result.xmlTemplate = xmlTemplate;
    if (csvTemplate != null) result.csvTemplate = csvTemplate;
    if (pdfTemplate != null) result.pdfTemplate = pdfTemplate;
    if (docxTemplate != null) result.docxTemplate = docxTemplate;
    return result;
  }

  SetExportTemplatesRequest._();

  factory SetExportTemplatesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetExportTemplatesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetExportTemplatesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pageName')
    ..aOS(2, _omitFieldNames ? '' : 'xmlTemplate')
    ..aOS(3, _omitFieldNames ? '' : 'csvTemplate')
    ..aOS(4, _omitFieldNames ? '' : 'pdfTemplate')
    ..aOS(5, _omitFieldNames ? '' : 'docxTemplate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExportTemplatesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExportTemplatesRequest copyWith(
          void Function(SetExportTemplatesRequest) updates) =>
      super.copyWith((message) => updates(message as SetExportTemplatesRequest))
          as SetExportTemplatesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetExportTemplatesRequest create() => SetExportTemplatesRequest._();
  @$core.override
  SetExportTemplatesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetExportTemplatesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetExportTemplatesRequest>(create);
  static SetExportTemplatesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set pageName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xmlTemplate => $_getSZ(1);
  @$pb.TagNumber(2)
  set xmlTemplate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXmlTemplate() => $_has(1);
  @$pb.TagNumber(2)
  void clearXmlTemplate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get csvTemplate => $_getSZ(2);
  @$pb.TagNumber(3)
  set csvTemplate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCsvTemplate() => $_has(2);
  @$pb.TagNumber(3)
  void clearCsvTemplate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pdfTemplate => $_getSZ(3);
  @$pb.TagNumber(4)
  set pdfTemplate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPdfTemplate() => $_has(3);
  @$pb.TagNumber(4)
  void clearPdfTemplate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get docxTemplate => $_getSZ(4);
  @$pb.TagNumber(5)
  set docxTemplate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDocxTemplate() => $_has(4);
  @$pb.TagNumber(5)
  void clearDocxTemplate() => $_clearField(5);
}

class SetExportTemplatesResponse extends $pb.GeneratedMessage {
  factory SetExportTemplatesResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  SetExportTemplatesResponse._();

  factory SetExportTemplatesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetExportTemplatesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetExportTemplatesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExportTemplatesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExportTemplatesResponse copyWith(
          void Function(SetExportTemplatesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SetExportTemplatesResponse))
          as SetExportTemplatesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetExportTemplatesResponse create() => SetExportTemplatesResponse._();
  @$core.override
  SetExportTemplatesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetExportTemplatesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetExportTemplatesResponse>(create);
  static SetExportTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class GetExportTemplatesRequest extends $pb.GeneratedMessage {
  factory GetExportTemplatesRequest({
    $core.String? pageName,
  }) {
    final result = create();
    if (pageName != null) result.pageName = pageName;
    return result;
  }

  GetExportTemplatesRequest._();

  factory GetExportTemplatesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetExportTemplatesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetExportTemplatesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pageName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExportTemplatesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExportTemplatesRequest copyWith(
          void Function(GetExportTemplatesRequest) updates) =>
      super.copyWith((message) => updates(message as GetExportTemplatesRequest))
          as GetExportTemplatesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExportTemplatesRequest create() => GetExportTemplatesRequest._();
  @$core.override
  GetExportTemplatesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetExportTemplatesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetExportTemplatesRequest>(create);
  static GetExportTemplatesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set pageName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageName() => $_clearField(1);
}

class GetExportTemplatesResponse extends $pb.GeneratedMessage {
  factory GetExportTemplatesResponse({
    $core.String? xmlTemplate,
    $core.String? csvTemplate,
    $core.String? pdfTemplate,
    $core.String? docxTemplate,
  }) {
    final result = create();
    if (xmlTemplate != null) result.xmlTemplate = xmlTemplate;
    if (csvTemplate != null) result.csvTemplate = csvTemplate;
    if (pdfTemplate != null) result.pdfTemplate = pdfTemplate;
    if (docxTemplate != null) result.docxTemplate = docxTemplate;
    return result;
  }

  GetExportTemplatesResponse._();

  factory GetExportTemplatesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetExportTemplatesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetExportTemplatesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xmlTemplate')
    ..aOS(2, _omitFieldNames ? '' : 'csvTemplate')
    ..aOS(3, _omitFieldNames ? '' : 'pdfTemplate')
    ..aOS(4, _omitFieldNames ? '' : 'docxTemplate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExportTemplatesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExportTemplatesResponse copyWith(
          void Function(GetExportTemplatesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetExportTemplatesResponse))
          as GetExportTemplatesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExportTemplatesResponse create() => GetExportTemplatesResponse._();
  @$core.override
  GetExportTemplatesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetExportTemplatesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetExportTemplatesResponse>(create);
  static GetExportTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xmlTemplate => $_getSZ(0);
  @$pb.TagNumber(1)
  set xmlTemplate($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXmlTemplate() => $_has(0);
  @$pb.TagNumber(1)
  void clearXmlTemplate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get csvTemplate => $_getSZ(1);
  @$pb.TagNumber(2)
  set csvTemplate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCsvTemplate() => $_has(1);
  @$pb.TagNumber(2)
  void clearCsvTemplate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pdfTemplate => $_getSZ(2);
  @$pb.TagNumber(3)
  set pdfTemplate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPdfTemplate() => $_has(2);
  @$pb.TagNumber(3)
  void clearPdfTemplate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get docxTemplate => $_getSZ(3);
  @$pb.TagNumber(4)
  set docxTemplate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDocxTemplate() => $_has(3);
  @$pb.TagNumber(4)
  void clearDocxTemplate() => $_clearField(4);
}

class ExportTemplateFileEntry extends $pb.GeneratedMessage {
  factory ExportTemplateFileEntry({
    $core.String? type,
    $core.Iterable<$core.String>? files,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (files != null) result.files.addAll(files);
    return result;
  }

  ExportTemplateFileEntry._();

  factory ExportTemplateFileEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportTemplateFileEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportTemplateFileEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..pPS(2, _omitFieldNames ? '' : 'files')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateFileEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateFileEntry copyWith(
          void Function(ExportTemplateFileEntry) updates) =>
      super.copyWith((message) => updates(message as ExportTemplateFileEntry))
          as ExportTemplateFileEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportTemplateFileEntry create() => ExportTemplateFileEntry._();
  @$core.override
  ExportTemplateFileEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportTemplateFileEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportTemplateFileEntry>(create);
  static ExportTemplateFileEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get files => $_getList(1);
}

class ListExportTemplateFilesResponse extends $pb.GeneratedMessage {
  factory ListExportTemplateFilesResponse({
    $core.Iterable<ExportTemplateFileEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  ListExportTemplateFilesResponse._();

  factory ListExportTemplateFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListExportTemplateFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListExportTemplateFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config'),
      createEmptyInstance: create)
    ..pPM<ExportTemplateFileEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ExportTemplateFileEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExportTemplateFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExportTemplateFilesResponse copyWith(
          void Function(ListExportTemplateFilesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListExportTemplateFilesResponse))
          as ListExportTemplateFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListExportTemplateFilesResponse create() =>
      ListExportTemplateFilesResponse._();
  @$core.override
  ListExportTemplateFilesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListExportTemplateFilesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListExportTemplateFilesResponse>(
          create);
  static ListExportTemplateFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ExportTemplateFileEntry> get entries => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
