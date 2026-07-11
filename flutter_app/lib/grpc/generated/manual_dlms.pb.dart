// This is a generated file - do not edit.
//
// Generated from manual_dlms.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CosemGetRequest extends $pb.GeneratedMessage {
  factory CosemGetRequest({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    return result;
  }

  CosemGetRequest._();

  factory CosemGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CosemGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CosemGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemGetRequest copyWith(void Function(CosemGetRequest) updates) =>
      super.copyWith((message) => updates(message as CosemGetRequest))
          as CosemGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CosemGetRequest create() => CosemGetRequest._();
  @$core.override
  CosemGetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CosemGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CosemGetRequest>(create);
  static CosemGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);
}

class CosemSetRequest extends $pb.GeneratedMessage {
  factory CosemSetRequest({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
    $core.String? inputData,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    if (inputData != null) result.inputData = inputData;
    return result;
  }

  CosemSetRequest._();

  factory CosemSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CosemSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CosemSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'inputData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemSetRequest copyWith(void Function(CosemSetRequest) updates) =>
      super.copyWith((message) => updates(message as CosemSetRequest))
          as CosemSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CosemSetRequest create() => CosemSetRequest._();
  @$core.override
  CosemSetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CosemSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CosemSetRequest>(create);
  static CosemSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inputData => $_getSZ(3);
  @$pb.TagNumber(4)
  set inputData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInputData() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputData() => $_clearField(4);
}

class CosemActionRequest extends $pb.GeneratedMessage {
  factory CosemActionRequest({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
    $core.String? inputData,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    if (inputData != null) result.inputData = inputData;
    return result;
  }

  CosemActionRequest._();

  factory CosemActionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CosemActionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CosemActionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'inputData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemActionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemActionRequest copyWith(void Function(CosemActionRequest) updates) =>
      super.copyWith((message) => updates(message as CosemActionRequest))
          as CosemActionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CosemActionRequest create() => CosemActionRequest._();
  @$core.override
  CosemActionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CosemActionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CosemActionRequest>(create);
  static CosemActionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inputData => $_getSZ(3);
  @$pb.TagNumber(4)
  set inputData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInputData() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputData() => $_clearField(4);
}

class WithListGetItem extends $pb.GeneratedMessage {
  factory WithListGetItem({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    return result;
  }

  WithListGetItem._();

  factory WithListGetItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListGetItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListGetItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListGetItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListGetItem copyWith(void Function(WithListGetItem) updates) =>
      super.copyWith((message) => updates(message as WithListGetItem))
          as WithListGetItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListGetItem create() => WithListGetItem._();
  @$core.override
  WithListGetItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListGetItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListGetItem>(create);
  static WithListGetItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);
}

class WithListSetItem extends $pb.GeneratedMessage {
  factory WithListSetItem({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
    $core.String? inputData,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    if (inputData != null) result.inputData = inputData;
    return result;
  }

  WithListSetItem._();

  factory WithListSetItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListSetItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListSetItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'inputData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListSetItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListSetItem copyWith(void Function(WithListSetItem) updates) =>
      super.copyWith((message) => updates(message as WithListSetItem))
          as WithListSetItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListSetItem create() => WithListSetItem._();
  @$core.override
  WithListSetItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListSetItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListSetItem>(create);
  static WithListSetItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inputData => $_getSZ(3);
  @$pb.TagNumber(4)
  set inputData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInputData() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputData() => $_clearField(4);
}

class WithListActionItem extends $pb.GeneratedMessage {
  factory WithListActionItem({
    $core.int? classId,
    $core.String? obis,
    $core.int? attribute,
    $core.String? inputData,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obis != null) result.obis = obis;
    if (attribute != null) result.attribute = attribute;
    if (inputData != null) result.inputData = inputData;
    return result;
  }

  WithListActionItem._();

  factory WithListActionItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListActionItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListActionItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obis')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'inputData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListActionItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListActionItem copyWith(void Function(WithListActionItem) updates) =>
      super.copyWith((message) => updates(message as WithListActionItem))
          as WithListActionItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListActionItem create() => WithListActionItem._();
  @$core.override
  WithListActionItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListActionItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListActionItem>(create);
  static WithListActionItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obis => $_getSZ(1);
  @$pb.TagNumber(2)
  set obis($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObis() => $_has(1);
  @$pb.TagNumber(2)
  void clearObis() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inputData => $_getSZ(3);
  @$pb.TagNumber(4)
  set inputData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInputData() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputData() => $_clearField(4);
}

class WithListGetRequest extends $pb.GeneratedMessage {
  factory WithListGetRequest({
    $core.Iterable<WithListGetItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  WithListGetRequest._();

  factory WithListGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..pPM<WithListGetItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: WithListGetItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListGetRequest copyWith(void Function(WithListGetRequest) updates) =>
      super.copyWith((message) => updates(message as WithListGetRequest))
          as WithListGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListGetRequest create() => WithListGetRequest._();
  @$core.override
  WithListGetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListGetRequest>(create);
  static WithListGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WithListGetItem> get items => $_getList(0);
}

class WithListSetRequest extends $pb.GeneratedMessage {
  factory WithListSetRequest({
    $core.Iterable<WithListSetItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  WithListSetRequest._();

  factory WithListSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..pPM<WithListSetItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: WithListSetItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListSetRequest copyWith(void Function(WithListSetRequest) updates) =>
      super.copyWith((message) => updates(message as WithListSetRequest))
          as WithListSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListSetRequest create() => WithListSetRequest._();
  @$core.override
  WithListSetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListSetRequest>(create);
  static WithListSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WithListSetItem> get items => $_getList(0);
}

class WithListActionRequest extends $pb.GeneratedMessage {
  factory WithListActionRequest({
    $core.Iterable<WithListActionItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  WithListActionRequest._();

  factory WithListActionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListActionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListActionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..pPM<WithListActionItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: WithListActionItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListActionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListActionRequest copyWith(
          void Function(WithListActionRequest) updates) =>
      super.copyWith((message) => updates(message as WithListActionRequest))
          as WithListActionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListActionRequest create() => WithListActionRequest._();
  @$core.override
  WithListActionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListActionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListActionRequest>(create);
  static WithListActionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WithListActionItem> get items => $_getList(0);
}

class EncodeRequest extends $pb.GeneratedMessage {
  factory EncodeRequest({
    $core.String? xmlInput,
  }) {
    final result = create();
    if (xmlInput != null) result.xmlInput = xmlInput;
    return result;
  }

  EncodeRequest._();

  factory EncodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xmlInput')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeRequest copyWith(void Function(EncodeRequest) updates) =>
      super.copyWith((message) => updates(message as EncodeRequest))
          as EncodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeRequest create() => EncodeRequest._();
  @$core.override
  EncodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncodeRequest>(create);
  static EncodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xmlInput => $_getSZ(0);
  @$pb.TagNumber(1)
  set xmlInput($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXmlInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearXmlInput() => $_clearField(1);
}

class DecodeRequest extends $pb.GeneratedMessage {
  factory DecodeRequest({
    $core.String? hexInput,
  }) {
    final result = create();
    if (hexInput != null) result.hexInput = hexInput;
    return result;
  }

  DecodeRequest._();

  factory DecodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hexInput')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeRequest copyWith(void Function(DecodeRequest) updates) =>
      super.copyWith((message) => updates(message as DecodeRequest))
          as DecodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeRequest create() => DecodeRequest._();
  @$core.override
  DecodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeRequest>(create);
  static DecodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hexInput => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexInput($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHexInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexInput() => $_clearField(1);
}

class SendRawFrameRequest extends $pb.GeneratedMessage {
  factory SendRawFrameRequest({
    $core.String? hexFrame,
  }) {
    final result = create();
    if (hexFrame != null) result.hexFrame = hexFrame;
    return result;
  }

  SendRawFrameRequest._();

  factory SendRawFrameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendRawFrameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendRawFrameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hexFrame')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawFrameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRawFrameRequest copyWith(void Function(SendRawFrameRequest) updates) =>
      super.copyWith((message) => updates(message as SendRawFrameRequest))
          as SendRawFrameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendRawFrameRequest create() => SendRawFrameRequest._();
  @$core.override
  SendRawFrameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendRawFrameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendRawFrameRequest>(create);
  static SendRawFrameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hexFrame => $_getSZ(0);
  @$pb.TagNumber(1)
  set hexFrame($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHexFrame() => $_has(0);
  @$pb.TagNumber(1)
  void clearHexFrame() => $_clearField(1);
}

/// Result of a single DLMS operation (GET, SET, or ACTION).
class ManualDlmsResult extends $pb.GeneratedMessage {
  factory ManualDlmsResult({
    $core.bool? success,
    $core.String? xdr,
    $core.String? xml,
    $core.String? error,
    $core.int? errorCode,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (xdr != null) result.xdr = xdr;
    if (xml != null) result.xml = xml;
    if (error != null) result.error = error;
    if (errorCode != null) result.errorCode = errorCode;
    return result;
  }

  ManualDlmsResult._();

  factory ManualDlmsResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ManualDlmsResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ManualDlmsResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'xdr')
    ..aOS(3, _omitFieldNames ? '' : 'xml')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aI(5, _omitFieldNames ? '' : 'errorCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManualDlmsResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManualDlmsResult copyWith(void Function(ManualDlmsResult) updates) =>
      super.copyWith((message) => updates(message as ManualDlmsResult))
          as ManualDlmsResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ManualDlmsResult create() => ManualDlmsResult._();
  @$core.override
  ManualDlmsResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ManualDlmsResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ManualDlmsResult>(create);
  static ManualDlmsResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xdr => $_getSZ(1);
  @$pb.TagNumber(2)
  set xdr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXdr() => $_has(1);
  @$pb.TagNumber(2)
  void clearXdr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get xml => $_getSZ(2);
  @$pb.TagNumber(3)
  set xml($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXml() => $_has(2);
  @$pb.TagNumber(3)
  void clearXml() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get errorCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set errorCode($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasErrorCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearErrorCode() => $_clearField(5);
}

/// Aggregated result of a WITH-LIST batch operation.
class WithListResult extends $pb.GeneratedMessage {
  factory WithListResult({
    $core.Iterable<ManualDlmsResult>? items,
    $core.bool? globalSuccess,
    $core.String? error,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (globalSuccess != null) result.globalSuccess = globalSuccess;
    if (error != null) result.error = error;
    return result;
  }

  WithListResult._();

  factory WithListResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithListResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithListResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..pPM<ManualDlmsResult>(1, _omitFieldNames ? '' : 'items',
        subBuilder: ManualDlmsResult.create)
    ..aOB(2, _omitFieldNames ? '' : 'globalSuccess')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithListResult copyWith(void Function(WithListResult) updates) =>
      super.copyWith((message) => updates(message as WithListResult))
          as WithListResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithListResult create() => WithListResult._();
  @$core.override
  WithListResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WithListResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithListResult>(create);
  static WithListResult? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ManualDlmsResult> get items => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get globalSuccess => $_getBF(1);
  @$pb.TagNumber(2)
  set globalSuccess($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGlobalSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearGlobalSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
}

/// Result of an encode or decode operation.
class CodecResult extends $pb.GeneratedMessage {
  factory CodecResult({
    $core.bool? success,
    $core.String? output,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (output != null) result.output = output;
    if (error != null) result.error = error;
    return result;
  }

  CodecResult._();

  factory CodecResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CodecResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CodecResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'manual_dlms'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'output')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodecResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodecResult copyWith(void Function(CodecResult) updates) =>
      super.copyWith((message) => updates(message as CodecResult))
          as CodecResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CodecResult create() => CodecResult._();
  @$core.override
  CodecResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CodecResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CodecResult>(create);
  static CodecResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get output => $_getSZ(1);
  @$pb.TagNumber(2)
  set output($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutput() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutput() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
