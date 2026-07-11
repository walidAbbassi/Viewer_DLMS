// This is a generated file - do not edit.
//
// Generated from meter.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $3;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $2;

import 'meter.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'meter.pbenum.dart';

/// ==========================
/// XML/XDR translation (NEW)
/// ==========================
class TranslateDataItemRequest extends $pb.GeneratedMessage {
  factory TranslateDataItemRequest({
    $core.String? data,
    $core.bool? isXdrInput,
  }) {
    final result = create();
    if (data != null) result.data = data;
    if (isXdrInput != null) result.isXdrInput = isXdrInput;
    return result;
  }

  TranslateDataItemRequest._();

  factory TranslateDataItemRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateDataItemRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateDataItemRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'data')
    ..aOB(2, _omitFieldNames ? '' : 'isXdrInput')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataItemRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataItemRequest copyWith(
          void Function(TranslateDataItemRequest) updates) =>
      super.copyWith((message) => updates(message as TranslateDataItemRequest))
          as TranslateDataItemRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateDataItemRequest create() => TranslateDataItemRequest._();
  @$core.override
  TranslateDataItemRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateDataItemRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateDataItemRequest>(create);
  static TranslateDataItemRequest? _defaultInstance;

  /// Input data as string (can be XML or XDR).
  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);

  /// true  -> input is XDR, server returns XML
  /// false -> input is XML, server returns XDR
  @$pb.TagNumber(2)
  $core.bool get isXdrInput => $_getBF(1);
  @$pb.TagNumber(2)
  set isXdrInput($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsXdrInput() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsXdrInput() => $_clearField(2);
}

class TranslateDataRequest extends $pb.GeneratedMessage {
  factory TranslateDataRequest({
    $core.Iterable<TranslateDataItemRequest>? requests,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    return result;
  }

  TranslateDataRequest._();

  factory TranslateDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<TranslateDataItemRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: TranslateDataItemRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataRequest copyWith(void Function(TranslateDataRequest) updates) =>
      super.copyWith((message) => updates(message as TranslateDataRequest))
          as TranslateDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateDataRequest create() => TranslateDataRequest._();
  @$core.override
  TranslateDataRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateDataRequest>(create);
  static TranslateDataRequest? _defaultInstance;

  /// Multiple items to translate in one call.
  @$pb.TagNumber(1)
  $pb.PbList<TranslateDataItemRequest> get requests => $_getList(0);
}

class TranslateDataItemResponse extends $pb.GeneratedMessage {
  factory TranslateDataItemResponse({
    $core.String? input,
    $core.String? output,
    $core.bool? isXdrInput,
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (input != null) result.input = input;
    if (output != null) result.output = output;
    if (isXdrInput != null) result.isXdrInput = isXdrInput;
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  TranslateDataItemResponse._();

  factory TranslateDataItemResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateDataItemResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateDataItemResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..aOS(2, _omitFieldNames ? '' : 'output')
    ..aOB(3, _omitFieldNames ? '' : 'isXdrInput')
    ..aOB(4, _omitFieldNames ? '' : 'success')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataItemResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataItemResponse copyWith(
          void Function(TranslateDataItemResponse) updates) =>
      super.copyWith((message) => updates(message as TranslateDataItemResponse))
          as TranslateDataItemResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateDataItemResponse create() => TranslateDataItemResponse._();
  @$core.override
  TranslateDataItemResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateDataItemResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateDataItemResponse>(create);
  static TranslateDataItemResponse? _defaultInstance;

  /// Echo of input (optional but useful for debugging).
  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => $_clearField(1);

  /// Translated data (XML or XDR, depending on is_xdr_input).
  @$pb.TagNumber(2)
  $core.String get output => $_getSZ(1);
  @$pb.TagNumber(2)
  set output($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutput() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutput() => $_clearField(2);

  /// Echo of direction to know how it was processed.
  @$pb.TagNumber(3)
  $core.bool get isXdrInput => $_getBF(2);
  @$pb.TagNumber(3)
  set isXdrInput($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsXdrInput() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsXdrInput() => $_clearField(3);

  /// Result status.
  @$pb.TagNumber(4)
  $core.bool get success => $_getBF(3);
  @$pb.TagNumber(4)
  set success($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccess() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
}

class TranslateDataResponse extends $pb.GeneratedMessage {
  factory TranslateDataResponse({
    $core.Iterable<TranslateDataItemResponse>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  TranslateDataResponse._();

  factory TranslateDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslateDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslateDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<TranslateDataItemResponse>(1, _omitFieldNames ? '' : 'items',
        subBuilder: TranslateDataItemResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslateDataResponse copyWith(
          void Function(TranslateDataResponse) updates) =>
      super.copyWith((message) => updates(message as TranslateDataResponse))
          as TranslateDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslateDataResponse create() => TranslateDataResponse._();
  @$core.override
  TranslateDataResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslateDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslateDataResponse>(create);
  static TranslateDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TranslateDataItemResponse> get items => $_getList(0);
}

class DlmsTranslateRequest extends $pb.GeneratedMessage {
  factory DlmsTranslateRequest({
    $core.String? data,
    $core.bool? isxml,
  }) {
    final result = create();
    if (data != null) result.data = data;
    if (isxml != null) result.isxml = isxml;
    return result;
  }

  DlmsTranslateRequest._();

  factory DlmsTranslateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DlmsTranslateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DlmsTranslateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'data')
    ..aOB(2, _omitFieldNames ? '' : 'isxml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DlmsTranslateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DlmsTranslateRequest copyWith(void Function(DlmsTranslateRequest) updates) =>
      super.copyWith((message) => updates(message as DlmsTranslateRequest))
          as DlmsTranslateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DlmsTranslateRequest create() => DlmsTranslateRequest._();
  @$core.override
  DlmsTranslateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DlmsTranslateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DlmsTranslateRequest>(create);
  static DlmsTranslateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isxml => $_getBF(1);
  @$pb.TagNumber(2)
  set isxml($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsxml() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsxml() => $_clearField(2);
}

enum GetRequest_AccessSelector { datetimeSelector, entrySelector, notSet }

/// ==========================
/// Requests
/// ==========================
class GetRequest extends $pb.GeneratedMessage {
  factory GetRequest({
    $core.int? class_1,
    $core.String? obiscode,
    $core.int? attribute,
    DateTimeRangeSelector? datetimeSelector,
    EntrySelector? entrySelector,
  }) {
    final result = create();
    if (class_1 != null) result.class_1 = class_1;
    if (obiscode != null) result.obiscode = obiscode;
    if (attribute != null) result.attribute = attribute;
    if (datetimeSelector != null) result.datetimeSelector = datetimeSelector;
    if (entrySelector != null) result.entrySelector = entrySelector;
    return result;
  }

  GetRequest._();

  factory GetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetRequest_AccessSelector>
      _GetRequest_AccessSelectorByTag = {
    4: GetRequest_AccessSelector.datetimeSelector,
    5: GetRequest_AccessSelector.entrySelector,
    0: GetRequest_AccessSelector.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [4, 5])
    ..aI(1, _omitFieldNames ? '' : 'class', protoName: 'class_')
    ..aOS(2, _omitFieldNames ? '' : 'obiscode')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOM<DateTimeRangeSelector>(4, _omitFieldNames ? '' : 'datetimeSelector',
        subBuilder: DateTimeRangeSelector.create)
    ..aOM<EntrySelector>(5, _omitFieldNames ? '' : 'entrySelector',
        subBuilder: EntrySelector.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRequest copyWith(void Function(GetRequest) updates) =>
      super.copyWith((message) => updates(message as GetRequest)) as GetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRequest create() => GetRequest._();
  @$core.override
  GetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRequest>(create);
  static GetRequest? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  GetRequest_AccessSelector whichAccessSelector() =>
      _GetRequest_AccessSelectorByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearAccessSelector() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get class_1 => $_getIZ(0);
  @$pb.TagNumber(1)
  set class_1($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClass_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearClass_1() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obiscode => $_getSZ(1);
  @$pb.TagNumber(2)
  set obiscode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObiscode() => $_has(1);
  @$pb.TagNumber(2)
  void clearObiscode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  DateTimeRangeSelector get datetimeSelector => $_getN(3);
  @$pb.TagNumber(4)
  set datetimeSelector(DateTimeRangeSelector value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDatetimeSelector() => $_has(3);
  @$pb.TagNumber(4)
  void clearDatetimeSelector() => $_clearField(4);
  @$pb.TagNumber(4)
  DateTimeRangeSelector ensureDatetimeSelector() => $_ensure(3);

  @$pb.TagNumber(5)
  EntrySelector get entrySelector => $_getN(4);
  @$pb.TagNumber(5)
  set entrySelector(EntrySelector value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEntrySelector() => $_has(4);
  @$pb.TagNumber(5)
  void clearEntrySelector() => $_clearField(5);
  @$pb.TagNumber(5)
  EntrySelector ensureEntrySelector() => $_ensure(4);
}

/// Datetime range selector (start/end)
class DateTimeRangeSelector extends $pb.GeneratedMessage {
  factory DateTimeRangeSelector({
    $2.Timestamp? start,
    $2.Timestamp? end,
  }) {
    final result = create();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  DateTimeRangeSelector._();

  factory DateTimeRangeSelector.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DateTimeRangeSelector.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DateTimeRangeSelector',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<$2.Timestamp>(1, _omitFieldNames ? '' : 'start',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'end',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DateTimeRangeSelector clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DateTimeRangeSelector copyWith(
          void Function(DateTimeRangeSelector) updates) =>
      super.copyWith((message) => updates(message as DateTimeRangeSelector))
          as DateTimeRangeSelector;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DateTimeRangeSelector create() => DateTimeRangeSelector._();
  @$core.override
  DateTimeRangeSelector createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DateTimeRangeSelector getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DateTimeRangeSelector>(create);
  static DateTimeRangeSelector? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Timestamp get start => $_getN(0);
  @$pb.TagNumber(1)
  set start($2.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Timestamp ensureStart() => $_ensure(0);

  @$pb.TagNumber(2)
  $2.Timestamp get end => $_getN(1);
  @$pb.TagNumber(2)
  set end($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureEnd() => $_ensure(1);
}

/// Entry selector with two ranges: entry and selected
class EntrySelector extends $pb.GeneratedMessage {
  factory EntrySelector({
    $core.int? entryFrom,
    $core.int? entryTo,
    $core.int? selectedFrom,
    $core.int? selectedTo,
  }) {
    final result = create();
    if (entryFrom != null) result.entryFrom = entryFrom;
    if (entryTo != null) result.entryTo = entryTo;
    if (selectedFrom != null) result.selectedFrom = selectedFrom;
    if (selectedTo != null) result.selectedTo = selectedTo;
    return result;
  }

  EntrySelector._();

  factory EntrySelector.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntrySelector.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntrySelector',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'entryFrom')
    ..aI(2, _omitFieldNames ? '' : 'entryTo')
    ..aI(3, _omitFieldNames ? '' : 'selectedFrom')
    ..aI(4, _omitFieldNames ? '' : 'selectedTo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntrySelector clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntrySelector copyWith(void Function(EntrySelector) updates) =>
      super.copyWith((message) => updates(message as EntrySelector))
          as EntrySelector;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntrySelector create() => EntrySelector._();
  @$core.override
  EntrySelector createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntrySelector getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntrySelector>(create);
  static EntrySelector? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryFrom => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryFrom($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryFrom() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get entryTo => $_getIZ(1);
  @$pb.TagNumber(2)
  set entryTo($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntryTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntryTo() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get selectedFrom => $_getIZ(2);
  @$pb.TagNumber(3)
  set selectedFrom($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSelectedFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearSelectedFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get selectedTo => $_getIZ(3);
  @$pb.TagNumber(4)
  set selectedTo($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSelectedTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearSelectedTo() => $_clearField(4);
}

class SetRequest extends $pb.GeneratedMessage {
  factory SetRequest({
    $core.int? class_1,
    $core.String? obiscode,
    $core.int? attribute,
    $core.String? payload,
  }) {
    final result = create();
    if (class_1 != null) result.class_1 = class_1;
    if (obiscode != null) result.obiscode = obiscode;
    if (attribute != null) result.attribute = attribute;
    if (payload != null) result.payload = payload;
    return result;
  }

  SetRequest._();

  factory SetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'class', protoName: 'class_')
    ..aOS(2, _omitFieldNames ? '' : 'obiscode')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'payload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRequest copyWith(void Function(SetRequest) updates) =>
      super.copyWith((message) => updates(message as SetRequest)) as SetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRequest create() => SetRequest._();
  @$core.override
  SetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRequest>(create);
  static SetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get class_1 => $_getIZ(0);
  @$pb.TagNumber(1)
  set class_1($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClass_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearClass_1() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obiscode => $_getSZ(1);
  @$pb.TagNumber(2)
  set obiscode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObiscode() => $_has(1);
  @$pb.TagNumber(2)
  void clearObiscode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get payload => $_getSZ(3);
  @$pb.TagNumber(4)
  set payload($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);
}

class ActionRequest extends $pb.GeneratedMessage {
  factory ActionRequest({
    $core.int? class_1,
    $core.String? obiscode,
    $core.int? attribute,
    $core.String? payload,
  }) {
    final result = create();
    if (class_1 != null) result.class_1 = class_1;
    if (obiscode != null) result.obiscode = obiscode;
    if (attribute != null) result.attribute = attribute;
    if (payload != null) result.payload = payload;
    return result;
  }

  ActionRequest._();

  factory ActionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'class', protoName: 'class_')
    ..aOS(2, _omitFieldNames ? '' : 'obiscode')
    ..aI(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'payload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionRequest copyWith(void Function(ActionRequest) updates) =>
      super.copyWith((message) => updates(message as ActionRequest))
          as ActionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActionRequest create() => ActionRequest._();
  @$core.override
  ActionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionRequest>(create);
  static ActionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get class_1 => $_getIZ(0);
  @$pb.TagNumber(1)
  set class_1($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClass_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearClass_1() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obiscode => $_getSZ(1);
  @$pb.TagNumber(2)
  set obiscode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObiscode() => $_has(1);
  @$pb.TagNumber(2)
  void clearObiscode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get attribute => $_getIZ(2);
  @$pb.TagNumber(3)
  set attribute($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get payload => $_getSZ(3);
  @$pb.TagNumber(4)
  set payload($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);
}

enum AbstractFrameRequest_Request {
  getRequest,
  setRequest,
  actionRequest,
  notSet
}

/// Polymorphic envelope for a frame request
class AbstractFrameRequest extends $pb.GeneratedMessage {
  factory AbstractFrameRequest({
    GetRequest? getRequest,
    SetRequest? setRequest,
    ActionRequest? actionRequest,
  }) {
    final result = create();
    if (getRequest != null) result.getRequest = getRequest;
    if (setRequest != null) result.setRequest = setRequest;
    if (actionRequest != null) result.actionRequest = actionRequest;
    return result;
  }

  AbstractFrameRequest._();

  factory AbstractFrameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AbstractFrameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AbstractFrameRequest_Request>
      _AbstractFrameRequest_RequestByTag = {
    1: AbstractFrameRequest_Request.getRequest,
    2: AbstractFrameRequest_Request.setRequest,
    3: AbstractFrameRequest_Request.actionRequest,
    0: AbstractFrameRequest_Request.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AbstractFrameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<GetRequest>(1, _omitFieldNames ? '' : 'getRequest',
        subBuilder: GetRequest.create)
    ..aOM<SetRequest>(2, _omitFieldNames ? '' : 'setRequest',
        subBuilder: SetRequest.create)
    ..aOM<ActionRequest>(3, _omitFieldNames ? '' : 'actionRequest',
        subBuilder: ActionRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbstractFrameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AbstractFrameRequest copyWith(void Function(AbstractFrameRequest) updates) =>
      super.copyWith((message) => updates(message as AbstractFrameRequest))
          as AbstractFrameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbstractFrameRequest create() => AbstractFrameRequest._();
  @$core.override
  AbstractFrameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AbstractFrameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AbstractFrameRequest>(create);
  static AbstractFrameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  AbstractFrameRequest_Request whichRequest() =>
      _AbstractFrameRequest_RequestByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearRequest() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetRequest get getRequest => $_getN(0);
  @$pb.TagNumber(1)
  set getRequest(GetRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGetRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearGetRequest() => $_clearField(1);
  @$pb.TagNumber(1)
  GetRequest ensureGetRequest() => $_ensure(0);

  @$pb.TagNumber(2)
  SetRequest get setRequest => $_getN(1);
  @$pb.TagNumber(2)
  set setRequest(SetRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSetRequest() => $_has(1);
  @$pb.TagNumber(2)
  void clearSetRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  SetRequest ensureSetRequest() => $_ensure(1);

  @$pb.TagNumber(3)
  ActionRequest get actionRequest => $_getN(2);
  @$pb.TagNumber(3)
  set actionRequest(ActionRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasActionRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearActionRequest() => $_clearField(3);
  @$pb.TagNumber(3)
  ActionRequest ensureActionRequest() => $_ensure(2);
}

/// ==========================
/// Responses
/// ==========================
class ApplicationResponse extends $pb.GeneratedMessage {
  factory ApplicationResponse({
    AbstractFrameRequest? request,
    $3.Any? value,
    $core.String? error,
    $core.int? statusCode,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (value != null) result.value = value;
    if (error != null) result.error = error;
    if (statusCode != null) result.statusCode = statusCode;
    return result;
  }

  ApplicationResponse._();

  factory ApplicationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplicationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplicationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<AbstractFrameRequest>(1, _omitFieldNames ? '' : 'request',
        subBuilder: AbstractFrameRequest.create)
    ..aOM<$3.Any>(2, _omitFieldNames ? '' : 'value', subBuilder: $3.Any.create)
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aI(4, _omitFieldNames ? '' : 'statusCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplicationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplicationResponse copyWith(void Function(ApplicationResponse) updates) =>
      super.copyWith((message) => updates(message as ApplicationResponse))
          as ApplicationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplicationResponse create() => ApplicationResponse._();
  @$core.override
  ApplicationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplicationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplicationResponse>(create);
  static ApplicationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AbstractFrameRequest get request => $_getN(0);
  @$pb.TagNumber(1)
  set request(AbstractFrameRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequest() => $_clearField(1);
  @$pb.TagNumber(1)
  AbstractFrameRequest ensureRequest() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.Any get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($3.Any value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Any ensureValue() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get statusCode => $_getIZ(3);
  @$pb.TagNumber(4)
  set statusCode($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatusCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatusCode() => $_clearField(4);
}

/// For the new simpler ExecuteGet/Set/Action RPCs
class FrameExecutionItem extends $pb.GeneratedMessage {
  factory FrameExecutionItem({
    AbstractFrameRequest? request,
    $core.String? xmlXdr,
    $core.String? xdr,
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (xmlXdr != null) result.xmlXdr = xmlXdr;
    if (xdr != null) result.xdr = xdr;
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  FrameExecutionItem._();

  factory FrameExecutionItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FrameExecutionItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FrameExecutionItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<AbstractFrameRequest>(1, _omitFieldNames ? '' : 'request',
        subBuilder: AbstractFrameRequest.create)
    ..aOS(2, _omitFieldNames ? '' : 'xmlXdr')
    ..aOS(3, _omitFieldNames ? '' : 'xdr')
    ..aOB(4, _omitFieldNames ? '' : 'success')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameExecutionItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameExecutionItem copyWith(void Function(FrameExecutionItem) updates) =>
      super.copyWith((message) => updates(message as FrameExecutionItem))
          as FrameExecutionItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FrameExecutionItem create() => FrameExecutionItem._();
  @$core.override
  FrameExecutionItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FrameExecutionItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FrameExecutionItem>(create);
  static FrameExecutionItem? _defaultInstance;

  @$pb.TagNumber(1)
  AbstractFrameRequest get request => $_getN(0);
  @$pb.TagNumber(1)
  set request(AbstractFrameRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequest() => $_clearField(1);
  @$pb.TagNumber(1)
  AbstractFrameRequest ensureRequest() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get xmlXdr => $_getSZ(1);
  @$pb.TagNumber(2)
  set xmlXdr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXmlXdr() => $_has(1);
  @$pb.TagNumber(2)
  void clearXmlXdr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get xdr => $_getSZ(2);
  @$pb.TagNumber(3)
  set xdr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXdr() => $_has(2);
  @$pb.TagNumber(3)
  void clearXdr() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get success => $_getBF(3);
  @$pb.TagNumber(4)
  set success($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccess() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
}

class FrameExecutionList extends $pb.GeneratedMessage {
  factory FrameExecutionList({
    $core.Iterable<FrameExecutionItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  FrameExecutionList._();

  factory FrameExecutionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FrameExecutionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FrameExecutionList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<FrameExecutionItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FrameExecutionItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameExecutionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrameExecutionList copyWith(void Function(FrameExecutionList) updates) =>
      super.copyWith((message) => updates(message as FrameExecutionList))
          as FrameExecutionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FrameExecutionList create() => FrameExecutionList._();
  @$core.override
  FrameExecutionList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FrameExecutionList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FrameExecutionList>(create);
  static FrameExecutionList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FrameExecutionItem> get items => $_getList(0);
}

/// ==========================
/// Helper messages
/// ==========================
class BoolValue extends $pb.GeneratedMessage {
  factory BoolValue({
    $core.bool? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BoolValue._();

  factory BoolValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BoolValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoolValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolValue copyWith(void Function(BoolValue) updates) =>
      super.copyWith((message) => updates(message as BoolValue)) as BoolValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BoolValue create() => BoolValue._();
  @$core.override
  BoolValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BoolValue getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoolValue>(create);
  static BoolValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get value => $_getBF(0);
  @$pb.TagNumber(1)
  set value($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Int32Value extends $pb.GeneratedMessage {
  factory Int32Value({
    $core.int? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Int32Value._();

  factory Int32Value.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Int32Value.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Int32Value',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Int32Value clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Int32Value copyWith(void Function(Int32Value) updates) =>
      super.copyWith((message) => updates(message as Int32Value)) as Int32Value;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Int32Value create() => Int32Value._();
  @$core.override
  Int32Value createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Int32Value getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Int32Value>(create);
  static Int32Value? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get value => $_getIZ(0);
  @$pb.TagNumber(1)
  set value($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class StringValue extends $pb.GeneratedMessage {
  factory StringValue({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  StringValue._();

  factory StringValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringValue copyWith(void Function(StringValue) updates) =>
      super.copyWith((message) => updates(message as StringValue))
          as StringValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringValue create() => StringValue._();
  @$core.override
  StringValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StringValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringValue>(create);
  static StringValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class StringList extends $pb.GeneratedMessage {
  factory StringList({
    $core.Iterable<$core.String>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  StringList._();

  factory StringList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'items')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringList copyWith(void Function(StringList) updates) =>
      super.copyWith((message) => updates(message as StringList)) as StringList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringList create() => StringList._();
  @$core.override
  StringList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StringList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringList>(create);
  static StringList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get items => $_getList(0);
}

/// Lists + with_list flag
class GetRequestList extends $pb.GeneratedMessage {
  factory GetRequestList({
    $core.Iterable<GetRequest>? requests,
    $core.bool? withList,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    if (withList != null) result.withList = withList;
    return result;
  }

  GetRequestList._();

  factory GetRequestList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRequestList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRequestList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<GetRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: GetRequest.create)
    ..aOB(2, _omitFieldNames ? '' : 'withList')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRequestList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRequestList copyWith(void Function(GetRequestList) updates) =>
      super.copyWith((message) => updates(message as GetRequestList))
          as GetRequestList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRequestList create() => GetRequestList._();
  @$core.override
  GetRequestList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRequestList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRequestList>(create);
  static GetRequestList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get withList => $_getBF(1);
  @$pb.TagNumber(2)
  set withList($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWithList() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithList() => $_clearField(2);
}

class SetRequestList extends $pb.GeneratedMessage {
  factory SetRequestList({
    $core.Iterable<SetRequest>? requests,
    $core.bool? withList,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    if (withList != null) result.withList = withList;
    return result;
  }

  SetRequestList._();

  factory SetRequestList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRequestList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRequestList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<SetRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: SetRequest.create)
    ..aOB(2, _omitFieldNames ? '' : 'withList')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRequestList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRequestList copyWith(void Function(SetRequestList) updates) =>
      super.copyWith((message) => updates(message as SetRequestList))
          as SetRequestList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRequestList create() => SetRequestList._();
  @$core.override
  SetRequestList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRequestList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRequestList>(create);
  static SetRequestList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SetRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get withList => $_getBF(1);
  @$pb.TagNumber(2)
  set withList($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWithList() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithList() => $_clearField(2);
}

class ActionRequestList extends $pb.GeneratedMessage {
  factory ActionRequestList({
    $core.Iterable<ActionRequest>? requests,
    $core.bool? withList,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    if (withList != null) result.withList = withList;
    return result;
  }

  ActionRequestList._();

  factory ActionRequestList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActionRequestList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionRequestList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<ActionRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: ActionRequest.create)
    ..aOB(2, _omitFieldNames ? '' : 'withList')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionRequestList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionRequestList copyWith(void Function(ActionRequestList) updates) =>
      super.copyWith((message) => updates(message as ActionRequestList))
          as ActionRequestList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActionRequestList create() => ActionRequestList._();
  @$core.override
  ActionRequestList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActionRequestList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionRequestList>(create);
  static ActionRequestList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActionRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get withList => $_getBF(1);
  @$pb.TagNumber(2)
  set withList($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWithList() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithList() => $_clearField(2);
}

class ApplicationResponseList extends $pb.GeneratedMessage {
  factory ApplicationResponseList({
    $core.Iterable<ApplicationResponse>? responses,
  }) {
    final result = create();
    if (responses != null) result.responses.addAll(responses);
    return result;
  }

  ApplicationResponseList._();

  factory ApplicationResponseList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplicationResponseList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplicationResponseList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<ApplicationResponse>(1, _omitFieldNames ? '' : 'responses',
        subBuilder: ApplicationResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplicationResponseList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplicationResponseList copyWith(
          void Function(ApplicationResponseList) updates) =>
      super.copyWith((message) => updates(message as ApplicationResponseList))
          as ApplicationResponseList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplicationResponseList create() => ApplicationResponseList._();
  @$core.override
  ApplicationResponseList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplicationResponseList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplicationResponseList>(create);
  static ApplicationResponseList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApplicationResponse> get responses => $_getList(0);
}

/// ==========================
/// Init context request
/// ==========================
class InitMeterContextRequest extends $pb.GeneratedMessage {
  factory InitMeterContextRequest({
    $core.String? modulename,
  }) {
    final result = create();
    if (modulename != null) result.modulename = modulename;
    return result;
  }

  InitMeterContextRequest._();

  factory InitMeterContextRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitMeterContextRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitMeterContextRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'modulename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitMeterContextRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitMeterContextRequest copyWith(
          void Function(InitMeterContextRequest) updates) =>
      super.copyWith((message) => updates(message as InitMeterContextRequest))
          as InitMeterContextRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitMeterContextRequest create() => InitMeterContextRequest._();
  @$core.override
  InitMeterContextRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitMeterContextRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitMeterContextRequest>(create);
  static InitMeterContextRequest? _defaultInstance;

  /// You asked for this exact field name
  @$pb.TagNumber(1)
  $core.String get modulename => $_getSZ(0);
  @$pb.TagNumber(1)
  set modulename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasModulename() => $_has(0);
  @$pb.TagNumber(1)
  void clearModulename() => $_clearField(1);
}

/// ==========================
/// Firmware/Image transfer
/// ==========================
class InitiateTransferRequest extends $pb.GeneratedMessage {
  factory InitiateTransferRequest({
    $core.String? pathFile,
    $core.String? imageId,
  }) {
    final result = create();
    if (pathFile != null) result.pathFile = pathFile;
    if (imageId != null) result.imageId = imageId;
    return result;
  }

  InitiateTransferRequest._();

  factory InitiateTransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitiateTransferRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateTransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pathFile')
    ..aOS(2, _omitFieldNames ? '' : 'imageId', protoName: 'imageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateTransferRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateTransferRequest copyWith(
          void Function(InitiateTransferRequest) updates) =>
      super.copyWith((message) => updates(message as InitiateTransferRequest))
          as InitiateTransferRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateTransferRequest create() => InitiateTransferRequest._();
  @$core.override
  InitiateTransferRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitiateTransferRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateTransferRequest>(create);
  static InitiateTransferRequest? _defaultInstance;

  /// exact names as requested
  @$pb.TagNumber(1)
  $core.String get pathFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set pathFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPathFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearPathFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get imageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set imageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageId() => $_clearField(2);
}

class TransferFileRequest extends $pb.GeneratedMessage {
  factory TransferFileRequest({
    $core.String? pathFile,
    $core.int? blockSize,
  }) {
    final result = create();
    if (pathFile != null) result.pathFile = pathFile;
    if (blockSize != null) result.blockSize = blockSize;
    return result;
  }

  TransferFileRequest._();

  factory TransferFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pathFile')
    ..aI(2, _omitFieldNames ? '' : 'blockSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferFileRequest copyWith(void Function(TransferFileRequest) updates) =>
      super.copyWith((message) => updates(message as TransferFileRequest))
          as TransferFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferFileRequest create() => TransferFileRequest._();
  @$core.override
  TransferFileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferFileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferFileRequest>(create);
  static TransferFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pathFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set pathFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPathFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearPathFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get blockSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockSize() => $_clearField(2);
}

class TransferUpdate extends $pb.GeneratedMessage {
  factory TransferUpdate({
    $core.int? blockNumber,
    $core.String? message,
  }) {
    final result = create();
    if (blockNumber != null) result.blockNumber = blockNumber;
    if (message != null) result.message = message;
    return result;
  }

  TransferUpdate._();

  factory TransferUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'blockNumber')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferUpdate copyWith(void Function(TransferUpdate) updates) =>
      super.copyWith((message) => updates(message as TransferUpdate))
          as TransferUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferUpdate create() => TransferUpdate._();
  @$core.override
  TransferUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferUpdate>(create);
  static TransferUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blockNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set blockNumber($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// ---- NEW: verification / resend / activation ----
class VerifyTransfertRequest extends $pb.GeneratedMessage {
  factory VerifyTransfertRequest({
    $core.String? pathFile,
    $core.int? blockSize,
  }) {
    final result = create();
    if (pathFile != null) result.pathFile = pathFile;
    if (blockSize != null) result.blockSize = blockSize;
    return result;
  }

  VerifyTransfertRequest._();

  factory VerifyTransfertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyTransfertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyTransfertRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pathFile')
    ..aI(2, _omitFieldNames ? '' : 'blockSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTransfertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTransfertRequest copyWith(
          void Function(VerifyTransfertRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyTransfertRequest))
          as VerifyTransfertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTransfertRequest create() => VerifyTransfertRequest._();
  @$core.override
  VerifyTransfertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyTransfertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyTransfertRequest>(create);
  static VerifyTransfertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pathFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set pathFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPathFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearPathFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get blockSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockSize() => $_clearField(2);
}

/// Array of booleans indicating per-chunk verification result (true = OK).
class VerifyTransfertResponse extends $pb.GeneratedMessage {
  factory VerifyTransfertResponse({
    $core.Iterable<$core.bool>? chunksOk,
  }) {
    final result = create();
    if (chunksOk != null) result.chunksOk.addAll(chunksOk);
    return result;
  }

  VerifyTransfertResponse._();

  factory VerifyTransfertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyTransfertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyTransfertResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..p<$core.bool>(1, _omitFieldNames ? '' : 'chunksOk', $pb.PbFieldType.KB)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTransfertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTransfertResponse copyWith(
          void Function(VerifyTransfertResponse) updates) =>
      super.copyWith((message) => updates(message as VerifyTransfertResponse))
          as VerifyTransfertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTransfertResponse create() => VerifyTransfertResponse._();
  @$core.override
  VerifyTransfertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyTransfertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyTransfertResponse>(create);
  static VerifyTransfertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.bool> get chunksOk => $_getList(0);
}

class ResendMissingChunksRequest extends $pb.GeneratedMessage {
  factory ResendMissingChunksRequest({
    $core.String? pathFile,
    $core.int? blockSize,
  }) {
    final result = create();
    if (pathFile != null) result.pathFile = pathFile;
    if (blockSize != null) result.blockSize = blockSize;
    return result;
  }

  ResendMissingChunksRequest._();

  factory ResendMissingChunksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResendMissingChunksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResendMissingChunksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pathFile')
    ..aI(2, _omitFieldNames ? '' : 'blockSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResendMissingChunksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResendMissingChunksRequest copyWith(
          void Function(ResendMissingChunksRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ResendMissingChunksRequest))
          as ResendMissingChunksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResendMissingChunksRequest create() => ResendMissingChunksRequest._();
  @$core.override
  ResendMissingChunksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResendMissingChunksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResendMissingChunksRequest>(create);
  static ResendMissingChunksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pathFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set pathFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPathFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearPathFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get blockSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockSize() => $_clearField(2);
}

class ResumeTransferRequest extends $pb.GeneratedMessage {
  factory ResumeTransferRequest({
    $core.String? pathFile,
    $core.int? blockSize,
    $core.int? startBlock,
  }) {
    final result = create();
    if (pathFile != null) result.pathFile = pathFile;
    if (blockSize != null) result.blockSize = blockSize;
    if (startBlock != null) result.startBlock = startBlock;
    return result;
  }

  ResumeTransferRequest._();

  factory ResumeTransferRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResumeTransferRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResumeTransferRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pathFile')
    ..aI(2, _omitFieldNames ? '' : 'blockSize')
    ..aI(3, _omitFieldNames ? '' : 'startBlock')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeTransferRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeTransferRequest copyWith(
          void Function(ResumeTransferRequest) updates) =>
      super.copyWith((message) => updates(message as ResumeTransferRequest))
          as ResumeTransferRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResumeTransferRequest create() => ResumeTransferRequest._();
  @$core.override
  ResumeTransferRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResumeTransferRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResumeTransferRequest>(create);
  static ResumeTransferRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pathFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set pathFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPathFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearPathFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get blockSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get startBlock => $_getIZ(2);
  @$pb.TagNumber(3)
  set startBlock($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartBlock() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartBlock() => $_clearField(3);
}

/// For firmware activation result with extra message.
class ActivateFirmwareResponse extends $pb.GeneratedMessage {
  factory ActivateFirmwareResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  ActivateFirmwareResponse._();

  factory ActivateFirmwareResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivateFirmwareResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivateFirmwareResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateFirmwareResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateFirmwareResponse copyWith(
          void Function(ActivateFirmwareResponse) updates) =>
      super.copyWith((message) => updates(message as ActivateFirmwareResponse))
          as ActivateFirmwareResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivateFirmwareResponse create() => ActivateFirmwareResponse._();
  @$core.override
  ActivateFirmwareResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivateFirmwareResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivateFirmwareResponse>(create);
  static ActivateFirmwareResponse? _defaultInstance;

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
/// Datamodel browsing (NEW)
/// ==========================
class GetDatamodelObjectsRequest extends $pb.GeneratedMessage {
  factory GetDatamodelObjectsRequest({
    $core.bool? withAttributes,
  }) {
    final result = create();
    if (withAttributes != null) result.withAttributes = withAttributes;
    return result;
  }

  GetDatamodelObjectsRequest._();

  factory GetDatamodelObjectsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDatamodelObjectsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDatamodelObjectsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'withAttributes',
        protoName: 'withAttributes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelObjectsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelObjectsRequest copyWith(
          void Function(GetDatamodelObjectsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetDatamodelObjectsRequest))
          as GetDatamodelObjectsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDatamodelObjectsRequest create() => GetDatamodelObjectsRequest._();
  @$core.override
  GetDatamodelObjectsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDatamodelObjectsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDatamodelObjectsRequest>(create);
  static GetDatamodelObjectsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get withAttributes => $_getBF(0);
  @$pb.TagNumber(1)
  set withAttributes($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWithAttributes() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithAttributes() => $_clearField(1);
}

class PushObjectRestrictionDateRange extends $pb.GeneratedMessage {
  factory PushObjectRestrictionDateRange({
    $core.String? fromDate,
    $core.String? toDate,
  }) {
    final result = create();
    if (fromDate != null) result.fromDate = fromDate;
    if (toDate != null) result.toDate = toDate;
    return result;
  }

  PushObjectRestrictionDateRange._();

  factory PushObjectRestrictionDateRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushObjectRestrictionDateRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushObjectRestrictionDateRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromDate')
    ..aOS(2, _omitFieldNames ? '' : 'toDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectRestrictionDateRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectRestrictionDateRange copyWith(
          void Function(PushObjectRestrictionDateRange) updates) =>
      super.copyWith(
              (message) => updates(message as PushObjectRestrictionDateRange))
          as PushObjectRestrictionDateRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushObjectRestrictionDateRange create() =>
      PushObjectRestrictionDateRange._();
  @$core.override
  PushObjectRestrictionDateRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushObjectRestrictionDateRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushObjectRestrictionDateRange>(create);
  static PushObjectRestrictionDateRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromDate => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromDate($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set toDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearToDate() => $_clearField(2);
}

class PushObjectRestrictionEntryRange extends $pb.GeneratedMessage {
  factory PushObjectRestrictionEntryRange({
    $core.int? fromEntry,
    $core.int? toEntry,
  }) {
    final result = create();
    if (fromEntry != null) result.fromEntry = fromEntry;
    if (toEntry != null) result.toEntry = toEntry;
    return result;
  }

  PushObjectRestrictionEntryRange._();

  factory PushObjectRestrictionEntryRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushObjectRestrictionEntryRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushObjectRestrictionEntryRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'fromEntry')
    ..aI(2, _omitFieldNames ? '' : 'toEntry')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectRestrictionEntryRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectRestrictionEntryRange copyWith(
          void Function(PushObjectRestrictionEntryRange) updates) =>
      super.copyWith(
              (message) => updates(message as PushObjectRestrictionEntryRange))
          as PushObjectRestrictionEntryRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushObjectRestrictionEntryRange create() =>
      PushObjectRestrictionEntryRange._();
  @$core.override
  PushObjectRestrictionEntryRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushObjectRestrictionEntryRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushObjectRestrictionEntryRange>(
          create);
  static PushObjectRestrictionEntryRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get fromEntry => $_getIZ(0);
  @$pb.TagNumber(1)
  set fromEntry($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromEntry() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get toEntry => $_getIZ(1);
  @$pb.TagNumber(2)
  set toEntry($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToEntry() => $_has(1);
  @$pb.TagNumber(2)
  void clearToEntry() => $_clearField(2);
}

enum PushObjectItem_RestrictionValue { dateRange, entryRange, notSet }

class PushObjectItem extends $pb.GeneratedMessage {
  factory PushObjectItem({
    $core.int? classId,
    $core.int? attributeIndex,
    $core.String? logicalName,
    $core.String? objectName,
    $core.int? dataIndex,
    $core.int? restrictionType,
    PushObjectRestrictionDateRange? dateRange,
    PushObjectRestrictionEntryRange? entryRange,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (attributeIndex != null) result.attributeIndex = attributeIndex;
    if (logicalName != null) result.logicalName = logicalName;
    if (objectName != null) result.objectName = objectName;
    if (dataIndex != null) result.dataIndex = dataIndex;
    if (restrictionType != null) result.restrictionType = restrictionType;
    if (dateRange != null) result.dateRange = dateRange;
    if (entryRange != null) result.entryRange = entryRange;
    return result;
  }

  PushObjectItem._();

  factory PushObjectItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushObjectItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, PushObjectItem_RestrictionValue>
      _PushObjectItem_RestrictionValueByTag = {
    7: PushObjectItem_RestrictionValue.dateRange,
    8: PushObjectItem_RestrictionValue.entryRange,
    0: PushObjectItem_RestrictionValue.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushObjectItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [7, 8])
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aI(2, _omitFieldNames ? '' : 'attributeIndex')
    ..aOS(3, _omitFieldNames ? '' : 'logicalName')
    ..aOS(4, _omitFieldNames ? '' : 'objectName')
    ..aI(5, _omitFieldNames ? '' : 'dataIndex')
    ..aI(6, _omitFieldNames ? '' : 'restrictionType')
    ..aOM<PushObjectRestrictionDateRange>(7, _omitFieldNames ? '' : 'dateRange',
        subBuilder: PushObjectRestrictionDateRange.create)
    ..aOM<PushObjectRestrictionEntryRange>(
        8, _omitFieldNames ? '' : 'entryRange',
        subBuilder: PushObjectRestrictionEntryRange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushObjectItem copyWith(void Function(PushObjectItem) updates) =>
      super.copyWith((message) => updates(message as PushObjectItem))
          as PushObjectItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushObjectItem create() => PushObjectItem._();
  @$core.override
  PushObjectItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushObjectItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushObjectItem>(create);
  static PushObjectItem? _defaultInstance;

  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  PushObjectItem_RestrictionValue whichRestrictionValue() =>
      _PushObjectItem_RestrictionValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  void clearRestrictionValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get attributeIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set attributeIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAttributeIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttributeIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get logicalName => $_getSZ(2);
  @$pb.TagNumber(3)
  set logicalName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLogicalName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLogicalName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get objectName => $_getSZ(3);
  @$pb.TagNumber(4)
  set objectName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasObjectName() => $_has(3);
  @$pb.TagNumber(4)
  void clearObjectName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get dataIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set dataIndex($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDataIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearDataIndex() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get restrictionType => $_getIZ(5);
  @$pb.TagNumber(6)
  set restrictionType($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRestrictionType() => $_has(5);
  @$pb.TagNumber(6)
  void clearRestrictionType() => $_clearField(6);

  @$pb.TagNumber(7)
  PushObjectRestrictionDateRange get dateRange => $_getN(6);
  @$pb.TagNumber(7)
  set dateRange(PushObjectRestrictionDateRange value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDateRange() => $_has(6);
  @$pb.TagNumber(7)
  void clearDateRange() => $_clearField(7);
  @$pb.TagNumber(7)
  PushObjectRestrictionDateRange ensureDateRange() => $_ensure(6);

  @$pb.TagNumber(8)
  PushObjectRestrictionEntryRange get entryRange => $_getN(7);
  @$pb.TagNumber(8)
  set entryRange(PushObjectRestrictionEntryRange value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasEntryRange() => $_has(7);
  @$pb.TagNumber(8)
  void clearEntryRange() => $_clearField(8);
  @$pb.TagNumber(8)
  PushObjectRestrictionEntryRange ensureEntryRange() => $_ensure(7);
}

class GetPushObjectListRequest extends $pb.GeneratedMessage {
  factory GetPushObjectListRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetPushObjectListRequest._();

  factory GetPushObjectListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushObjectListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushObjectListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushObjectListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushObjectListRequest copyWith(
          void Function(GetPushObjectListRequest) updates) =>
      super.copyWith((message) => updates(message as GetPushObjectListRequest))
          as GetPushObjectListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushObjectListRequest create() => GetPushObjectListRequest._();
  @$core.override
  GetPushObjectListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushObjectListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushObjectListRequest>(create);
  static GetPushObjectListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetPushObjectListResponse extends $pb.GeneratedMessage {
  factory GetPushObjectListResponse({
    $core.Iterable<PushObjectItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  GetPushObjectListResponse._();

  factory GetPushObjectListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushObjectListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushObjectListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<PushObjectItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: PushObjectItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushObjectListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushObjectListResponse copyWith(
          void Function(GetPushObjectListResponse) updates) =>
      super.copyWith((message) => updates(message as GetPushObjectListResponse))
          as GetPushObjectListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushObjectListResponse create() => GetPushObjectListResponse._();
  @$core.override
  GetPushObjectListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushObjectListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushObjectListResponse>(create);
  static GetPushObjectListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PushObjectItem> get items => $_getList(0);
}

class SetPushObjectListRequest extends $pb.GeneratedMessage {
  factory SetPushObjectListRequest({
    $core.String? datasource,
    $core.Iterable<PushObjectItem>? items,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (items != null) result.items.addAll(items);
    return result;
  }

  SetPushObjectListRequest._();

  factory SetPushObjectListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPushObjectListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPushObjectListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..pPM<PushObjectItem>(2, _omitFieldNames ? '' : 'items',
        subBuilder: PushObjectItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPushObjectListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPushObjectListRequest copyWith(
          void Function(SetPushObjectListRequest) updates) =>
      super.copyWith((message) => updates(message as SetPushObjectListRequest))
          as SetPushObjectListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPushObjectListRequest create() => SetPushObjectListRequest._();
  @$core.override
  SetPushObjectListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPushObjectListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPushObjectListRequest>(create);
  static SetPushObjectListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<PushObjectItem> get items => $_getList(1);
}

class GetRandomisationStartIntervalRequest extends $pb.GeneratedMessage {
  factory GetRandomisationStartIntervalRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetRandomisationStartIntervalRequest._();

  factory GetRandomisationStartIntervalRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRandomisationStartIntervalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRandomisationStartIntervalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRandomisationStartIntervalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRandomisationStartIntervalRequest copyWith(
          void Function(GetRandomisationStartIntervalRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetRandomisationStartIntervalRequest))
          as GetRandomisationStartIntervalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRandomisationStartIntervalRequest create() =>
      GetRandomisationStartIntervalRequest._();
  @$core.override
  GetRandomisationStartIntervalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRandomisationStartIntervalRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetRandomisationStartIntervalRequest>(create);
  static GetRandomisationStartIntervalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetRandomisationStartIntervalResponse extends $pb.GeneratedMessage {
  factory GetRandomisationStartIntervalResponse({
    $core.int? result,
  }) {
    final result$ = create();
    if (result != null) result$.result = result;
    return result$;
  }

  GetRandomisationStartIntervalResponse._();

  factory GetRandomisationStartIntervalResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRandomisationStartIntervalResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRandomisationStartIntervalResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'result')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRandomisationStartIntervalResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRandomisationStartIntervalResponse copyWith(
          void Function(GetRandomisationStartIntervalResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetRandomisationStartIntervalResponse))
          as GetRandomisationStartIntervalResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRandomisationStartIntervalResponse create() =>
      GetRandomisationStartIntervalResponse._();
  @$core.override
  GetRandomisationStartIntervalResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRandomisationStartIntervalResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetRandomisationStartIntervalResponse>(create);
  static GetRandomisationStartIntervalResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get result => $_getIZ(0);
  @$pb.TagNumber(1)
  set result($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => $_clearField(1);
}

class SetRandomisationStartIntervalRequest extends $pb.GeneratedMessage {
  factory SetRandomisationStartIntervalRequest({
    $core.String? datasource,
    $core.int? value,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (value != null) result.value = value;
    return result;
  }

  SetRandomisationStartIntervalRequest._();

  factory SetRandomisationStartIntervalRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRandomisationStartIntervalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRandomisationStartIntervalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRandomisationStartIntervalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRandomisationStartIntervalRequest copyWith(
          void Function(SetRandomisationStartIntervalRequest) updates) =>
      super.copyWith((message) =>
              updates(message as SetRandomisationStartIntervalRequest))
          as SetRandomisationStartIntervalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRandomisationStartIntervalRequest create() =>
      SetRandomisationStartIntervalRequest._();
  @$core.override
  SetRandomisationStartIntervalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRandomisationStartIntervalRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          SetRandomisationStartIntervalRequest>(create);
  static SetRandomisationStartIntervalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class GetNumberOfRetriesRequest extends $pb.GeneratedMessage {
  factory GetNumberOfRetriesRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetNumberOfRetriesRequest._();

  factory GetNumberOfRetriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNumberOfRetriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNumberOfRetriesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNumberOfRetriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNumberOfRetriesRequest copyWith(
          void Function(GetNumberOfRetriesRequest) updates) =>
      super.copyWith((message) => updates(message as GetNumberOfRetriesRequest))
          as GetNumberOfRetriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNumberOfRetriesRequest create() => GetNumberOfRetriesRequest._();
  @$core.override
  GetNumberOfRetriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNumberOfRetriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNumberOfRetriesRequest>(create);
  static GetNumberOfRetriesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetNumberOfRetriesResponse extends $pb.GeneratedMessage {
  factory GetNumberOfRetriesResponse({
    $core.int? result,
  }) {
    final result$ = create();
    if (result != null) result$.result = result;
    return result$;
  }

  GetNumberOfRetriesResponse._();

  factory GetNumberOfRetriesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNumberOfRetriesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNumberOfRetriesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'result')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNumberOfRetriesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNumberOfRetriesResponse copyWith(
          void Function(GetNumberOfRetriesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetNumberOfRetriesResponse))
          as GetNumberOfRetriesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNumberOfRetriesResponse create() => GetNumberOfRetriesResponse._();
  @$core.override
  GetNumberOfRetriesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNumberOfRetriesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNumberOfRetriesResponse>(create);
  static GetNumberOfRetriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get result => $_getIZ(0);
  @$pb.TagNumber(1)
  set result($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => $_clearField(1);
}

class SetNumberOfRetriesRequest extends $pb.GeneratedMessage {
  factory SetNumberOfRetriesRequest({
    $core.String? datasource,
    $core.int? value,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (value != null) result.value = value;
    return result;
  }

  SetNumberOfRetriesRequest._();

  factory SetNumberOfRetriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetNumberOfRetriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetNumberOfRetriesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNumberOfRetriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNumberOfRetriesRequest copyWith(
          void Function(SetNumberOfRetriesRequest) updates) =>
      super.copyWith((message) => updates(message as SetNumberOfRetriesRequest))
          as SetNumberOfRetriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetNumberOfRetriesRequest create() => SetNumberOfRetriesRequest._();
  @$core.override
  SetNumberOfRetriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetNumberOfRetriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetNumberOfRetriesRequest>(create);
  static SetNumberOfRetriesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class GetRepetitionDelayRequest extends $pb.GeneratedMessage {
  factory GetRepetitionDelayRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetRepetitionDelayRequest._();

  factory GetRepetitionDelayRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRepetitionDelayRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRepetitionDelayRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepetitionDelayRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepetitionDelayRequest copyWith(
          void Function(GetRepetitionDelayRequest) updates) =>
      super.copyWith((message) => updates(message as GetRepetitionDelayRequest))
          as GetRepetitionDelayRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRepetitionDelayRequest create() => GetRepetitionDelayRequest._();
  @$core.override
  GetRepetitionDelayRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRepetitionDelayRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRepetitionDelayRequest>(create);
  static GetRepetitionDelayRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetRepetitionDelayResponse extends $pb.GeneratedMessage {
  factory GetRepetitionDelayResponse({
    $core.int? min,
    $core.int? exponent,
    $core.int? max,
  }) {
    final result = create();
    if (min != null) result.min = min;
    if (exponent != null) result.exponent = exponent;
    if (max != null) result.max = max;
    return result;
  }

  GetRepetitionDelayResponse._();

  factory GetRepetitionDelayResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRepetitionDelayResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRepetitionDelayResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'min')
    ..aI(2, _omitFieldNames ? '' : 'exponent')
    ..aI(3, _omitFieldNames ? '' : 'max')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepetitionDelayResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepetitionDelayResponse copyWith(
          void Function(GetRepetitionDelayResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetRepetitionDelayResponse))
          as GetRepetitionDelayResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRepetitionDelayResponse create() => GetRepetitionDelayResponse._();
  @$core.override
  GetRepetitionDelayResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRepetitionDelayResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRepetitionDelayResponse>(create);
  static GetRepetitionDelayResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get min => $_getIZ(0);
  @$pb.TagNumber(1)
  set min($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMin() => $_has(0);
  @$pb.TagNumber(1)
  void clearMin() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get exponent => $_getIZ(1);
  @$pb.TagNumber(2)
  set exponent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExponent() => $_has(1);
  @$pb.TagNumber(2)
  void clearExponent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get max => $_getIZ(2);
  @$pb.TagNumber(3)
  set max($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMax() => $_has(2);
  @$pb.TagNumber(3)
  void clearMax() => $_clearField(3);
}

class SetRepetitionDelayRequest extends $pb.GeneratedMessage {
  factory SetRepetitionDelayRequest({
    $core.String? datasource,
    $core.int? min,
    $core.int? exponent,
    $core.int? max,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (min != null) result.min = min;
    if (exponent != null) result.exponent = exponent;
    if (max != null) result.max = max;
    return result;
  }

  SetRepetitionDelayRequest._();

  factory SetRepetitionDelayRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRepetitionDelayRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRepetitionDelayRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'min')
    ..aI(3, _omitFieldNames ? '' : 'exponent')
    ..aI(4, _omitFieldNames ? '' : 'max')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepetitionDelayRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepetitionDelayRequest copyWith(
          void Function(SetRepetitionDelayRequest) updates) =>
      super.copyWith((message) => updates(message as SetRepetitionDelayRequest))
          as SetRepetitionDelayRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRepetitionDelayRequest create() => SetRepetitionDelayRequest._();
  @$core.override
  SetRepetitionDelayRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRepetitionDelayRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRepetitionDelayRequest>(create);
  static SetRepetitionDelayRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get min => $_getIZ(1);
  @$pb.TagNumber(2)
  set min($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMin() => $_has(1);
  @$pb.TagNumber(2)
  void clearMin() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get exponent => $_getIZ(2);
  @$pb.TagNumber(3)
  set exponent($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExponent() => $_has(2);
  @$pb.TagNumber(3)
  void clearExponent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get max => $_getIZ(3);
  @$pb.TagNumber(4)
  set max($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMax() => $_has(3);
  @$pb.TagNumber(4)
  void clearMax() => $_clearField(4);
}

class GetLastConfirmationDatetimeRequest extends $pb.GeneratedMessage {
  factory GetLastConfirmationDatetimeRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetLastConfirmationDatetimeRequest._();

  factory GetLastConfirmationDatetimeRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLastConfirmationDatetimeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLastConfirmationDatetimeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLastConfirmationDatetimeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLastConfirmationDatetimeRequest copyWith(
          void Function(GetLastConfirmationDatetimeRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetLastConfirmationDatetimeRequest))
          as GetLastConfirmationDatetimeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLastConfirmationDatetimeRequest create() =>
      GetLastConfirmationDatetimeRequest._();
  @$core.override
  GetLastConfirmationDatetimeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLastConfirmationDatetimeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLastConfirmationDatetimeRequest>(
          create);
  static GetLastConfirmationDatetimeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetLastConfirmationDatetimeResponse extends $pb.GeneratedMessage {
  factory GetLastConfirmationDatetimeResponse({
    $core.String? result,
  }) {
    final result$ = create();
    if (result != null) result$.result = result;
    return result$;
  }

  GetLastConfirmationDatetimeResponse._();

  factory GetLastConfirmationDatetimeResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLastConfirmationDatetimeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLastConfirmationDatetimeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'result')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLastConfirmationDatetimeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLastConfirmationDatetimeResponse copyWith(
          void Function(GetLastConfirmationDatetimeResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetLastConfirmationDatetimeResponse))
          as GetLastConfirmationDatetimeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLastConfirmationDatetimeResponse create() =>
      GetLastConfirmationDatetimeResponse._();
  @$core.override
  GetLastConfirmationDatetimeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLastConfirmationDatetimeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetLastConfirmationDatetimeResponse>(create);
  static GetLastConfirmationDatetimeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get result => $_getSZ(0);
  @$pb.TagNumber(1)
  set result($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => $_clearField(1);
}

class SetLastConfirmationDatetimeRequest extends $pb.GeneratedMessage {
  factory SetLastConfirmationDatetimeRequest({
    $core.String? datasource,
    $core.String? value,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (value != null) result.value = value;
    return result;
  }

  SetLastConfirmationDatetimeRequest._();

  factory SetLastConfirmationDatetimeRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetLastConfirmationDatetimeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetLastConfirmationDatetimeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetLastConfirmationDatetimeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetLastConfirmationDatetimeRequest copyWith(
          void Function(SetLastConfirmationDatetimeRequest) updates) =>
      super.copyWith((message) =>
              updates(message as SetLastConfirmationDatetimeRequest))
          as SetLastConfirmationDatetimeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetLastConfirmationDatetimeRequest create() =>
      SetLastConfirmationDatetimeRequest._();
  @$core.override
  SetLastConfirmationDatetimeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetLastConfirmationDatetimeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetLastConfirmationDatetimeRequest>(
          create);
  static SetLastConfirmationDatetimeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class GetSendDestinationRequest extends $pb.GeneratedMessage {
  factory GetSendDestinationRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetSendDestinationRequest._();

  factory GetSendDestinationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSendDestinationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSendDestinationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSendDestinationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSendDestinationRequest copyWith(
          void Function(GetSendDestinationRequest) updates) =>
      super.copyWith((message) => updates(message as GetSendDestinationRequest))
          as GetSendDestinationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSendDestinationRequest create() => GetSendDestinationRequest._();
  @$core.override
  GetSendDestinationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSendDestinationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSendDestinationRequest>(create);
  static GetSendDestinationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetSendDestinationResponse extends $pb.GeneratedMessage {
  factory GetSendDestinationResponse({
    $core.int? tcpService,
    $core.String? destination,
    $core.int? message,
  }) {
    final result = create();
    if (tcpService != null) result.tcpService = tcpService;
    if (destination != null) result.destination = destination;
    if (message != null) result.message = message;
    return result;
  }

  GetSendDestinationResponse._();

  factory GetSendDestinationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSendDestinationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSendDestinationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'tcpService')
    ..aOS(2, _omitFieldNames ? '' : 'destination')
    ..aI(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSendDestinationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSendDestinationResponse copyWith(
          void Function(GetSendDestinationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetSendDestinationResponse))
          as GetSendDestinationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSendDestinationResponse create() => GetSendDestinationResponse._();
  @$core.override
  GetSendDestinationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSendDestinationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSendDestinationResponse>(create);
  static GetSendDestinationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get tcpService => $_getIZ(0);
  @$pb.TagNumber(1)
  set tcpService($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTcpService() => $_has(0);
  @$pb.TagNumber(1)
  void clearTcpService() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get destination => $_getSZ(1);
  @$pb.TagNumber(2)
  set destination($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDestination() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestination() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get message => $_getIZ(2);
  @$pb.TagNumber(3)
  set message($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class SetSendDestinationRequest extends $pb.GeneratedMessage {
  factory SetSendDestinationRequest({
    $core.String? datasource,
    $core.int? tcpService,
    $core.String? destination,
    $core.int? message,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (tcpService != null) result.tcpService = tcpService;
    if (destination != null) result.destination = destination;
    if (message != null) result.message = message;
    return result;
  }

  SetSendDestinationRequest._();

  factory SetSendDestinationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetSendDestinationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetSendDestinationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'tcpService')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aI(4, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSendDestinationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSendDestinationRequest copyWith(
          void Function(SetSendDestinationRequest) updates) =>
      super.copyWith((message) => updates(message as SetSendDestinationRequest))
          as SetSendDestinationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetSendDestinationRequest create() => SetSendDestinationRequest._();
  @$core.override
  SetSendDestinationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetSendDestinationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetSendDestinationRequest>(create);
  static SetSendDestinationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tcpService => $_getIZ(1);
  @$pb.TagNumber(2)
  set tcpService($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTcpService() => $_has(1);
  @$pb.TagNumber(2)
  void clearTcpService() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get message => $_getIZ(3);
  @$pb.TagNumber(4)
  set message($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);
}

class CommunicationWindowEntry extends $pb.GeneratedMessage {
  factory CommunicationWindowEntry({
    $core.String? startTime,
    $core.String? endTime,
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  CommunicationWindowEntry._();

  factory CommunicationWindowEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommunicationWindowEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommunicationWindowEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'startTime')
    ..aOS(2, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunicationWindowEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommunicationWindowEntry copyWith(
          void Function(CommunicationWindowEntry) updates) =>
      super.copyWith((message) => updates(message as CommunicationWindowEntry))
          as CommunicationWindowEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommunicationWindowEntry create() => CommunicationWindowEntry._();
  @$core.override
  CommunicationWindowEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommunicationWindowEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommunicationWindowEntry>(create);
  static CommunicationWindowEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get startTime => $_getSZ(0);
  @$pb.TagNumber(1)
  set startTime($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get endTime => $_getSZ(1);
  @$pb.TagNumber(2)
  set endTime($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEndTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndTime() => $_clearField(2);
}

class GetCommunicationWindowRequest extends $pb.GeneratedMessage {
  factory GetCommunicationWindowRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetCommunicationWindowRequest._();

  factory GetCommunicationWindowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCommunicationWindowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCommunicationWindowRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCommunicationWindowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCommunicationWindowRequest copyWith(
          void Function(GetCommunicationWindowRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetCommunicationWindowRequest))
          as GetCommunicationWindowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCommunicationWindowRequest create() =>
      GetCommunicationWindowRequest._();
  @$core.override
  GetCommunicationWindowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCommunicationWindowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCommunicationWindowRequest>(create);
  static GetCommunicationWindowRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetCommunicationWindowResponse extends $pb.GeneratedMessage {
  factory GetCommunicationWindowResponse({
    $core.Iterable<CommunicationWindowEntry>? windows,
  }) {
    final result = create();
    if (windows != null) result.windows.addAll(windows);
    return result;
  }

  GetCommunicationWindowResponse._();

  factory GetCommunicationWindowResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCommunicationWindowResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCommunicationWindowResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<CommunicationWindowEntry>(1, _omitFieldNames ? '' : 'windows',
        subBuilder: CommunicationWindowEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCommunicationWindowResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCommunicationWindowResponse copyWith(
          void Function(GetCommunicationWindowResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCommunicationWindowResponse))
          as GetCommunicationWindowResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCommunicationWindowResponse create() =>
      GetCommunicationWindowResponse._();
  @$core.override
  GetCommunicationWindowResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCommunicationWindowResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCommunicationWindowResponse>(create);
  static GetCommunicationWindowResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CommunicationWindowEntry> get windows => $_getList(0);
}

class CosemDateTimeEntry extends $pb.GeneratedMessage {
  factory CosemDateTimeEntry({
    $core.int? day,
    $core.int? month,
    $core.int? year,
    $core.int? weekday,
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
  }) {
    final result = create();
    if (day != null) result.day = day;
    if (month != null) result.month = month;
    if (year != null) result.year = year;
    if (weekday != null) result.weekday = weekday;
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    return result;
  }

  CosemDateTimeEntry._();

  factory CosemDateTimeEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CosemDateTimeEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CosemDateTimeEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'day')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'year')
    ..aI(4, _omitFieldNames ? '' : 'weekday')
    ..aI(5, _omitFieldNames ? '' : 'hour')
    ..aI(6, _omitFieldNames ? '' : 'minute')
    ..aI(7, _omitFieldNames ? '' : 'second')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemDateTimeEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CosemDateTimeEntry copyWith(void Function(CosemDateTimeEntry) updates) =>
      super.copyWith((message) => updates(message as CosemDateTimeEntry))
          as CosemDateTimeEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CosemDateTimeEntry create() => CosemDateTimeEntry._();
  @$core.override
  CosemDateTimeEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CosemDateTimeEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CosemDateTimeEntry>(create);
  static CosemDateTimeEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get day => $_getIZ(0);
  @$pb.TagNumber(1)
  set day($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDay() => $_has(0);
  @$pb.TagNumber(1)
  void clearDay() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get year => $_getIZ(2);
  @$pb.TagNumber(3)
  set year($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYear() => $_has(2);
  @$pb.TagNumber(3)
  void clearYear() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get weekday => $_getIZ(3);
  @$pb.TagNumber(4)
  set weekday($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWeekday() => $_has(3);
  @$pb.TagNumber(4)
  void clearWeekday() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get hour => $_getIZ(4);
  @$pb.TagNumber(5)
  set hour($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHour() => $_has(4);
  @$pb.TagNumber(5)
  void clearHour() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get minute => $_getIZ(5);
  @$pb.TagNumber(6)
  set minute($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinute() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinute() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get second => $_getIZ(6);
  @$pb.TagNumber(7)
  set second($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSecond() => $_has(6);
  @$pb.TagNumber(7)
  void clearSecond() => $_clearField(7);
}

class SetCommunicationWindowEntry extends $pb.GeneratedMessage {
  factory SetCommunicationWindowEntry({
    CosemDateTimeEntry? startTime,
    CosemDateTimeEntry? endTime,
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  SetCommunicationWindowEntry._();

  factory SetCommunicationWindowEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCommunicationWindowEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCommunicationWindowEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<CosemDateTimeEntry>(1, _omitFieldNames ? '' : 'startTime',
        subBuilder: CosemDateTimeEntry.create)
    ..aOM<CosemDateTimeEntry>(2, _omitFieldNames ? '' : 'endTime',
        subBuilder: CosemDateTimeEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommunicationWindowEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommunicationWindowEntry copyWith(
          void Function(SetCommunicationWindowEntry) updates) =>
      super.copyWith(
              (message) => updates(message as SetCommunicationWindowEntry))
          as SetCommunicationWindowEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCommunicationWindowEntry create() =>
      SetCommunicationWindowEntry._();
  @$core.override
  SetCommunicationWindowEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCommunicationWindowEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCommunicationWindowEntry>(create);
  static SetCommunicationWindowEntry? _defaultInstance;

  @$pb.TagNumber(1)
  CosemDateTimeEntry get startTime => $_getN(0);
  @$pb.TagNumber(1)
  set startTime(CosemDateTimeEntry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);
  @$pb.TagNumber(1)
  CosemDateTimeEntry ensureStartTime() => $_ensure(0);

  @$pb.TagNumber(2)
  CosemDateTimeEntry get endTime => $_getN(1);
  @$pb.TagNumber(2)
  set endTime(CosemDateTimeEntry value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEndTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndTime() => $_clearField(2);
  @$pb.TagNumber(2)
  CosemDateTimeEntry ensureEndTime() => $_ensure(1);
}

class SetCommunicationWindowRequest extends $pb.GeneratedMessage {
  factory SetCommunicationWindowRequest({
    $core.String? datasource,
    $core.Iterable<SetCommunicationWindowEntry>? windows,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (windows != null) result.windows.addAll(windows);
    return result;
  }

  SetCommunicationWindowRequest._();

  factory SetCommunicationWindowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCommunicationWindowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCommunicationWindowRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..pPM<SetCommunicationWindowEntry>(2, _omitFieldNames ? '' : 'windows',
        subBuilder: SetCommunicationWindowEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommunicationWindowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommunicationWindowRequest copyWith(
          void Function(SetCommunicationWindowRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetCommunicationWindowRequest))
          as SetCommunicationWindowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCommunicationWindowRequest create() =>
      SetCommunicationWindowRequest._();
  @$core.override
  SetCommunicationWindowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCommunicationWindowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCommunicationWindowRequest>(create);
  static SetCommunicationWindowRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<SetCommunicationWindowEntry> get windows => $_getList(1);
}

class GetExecutionTimeRequest extends $pb.GeneratedMessage {
  factory GetExecutionTimeRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetExecutionTimeRequest._();

  factory GetExecutionTimeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetExecutionTimeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetExecutionTimeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExecutionTimeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExecutionTimeRequest copyWith(
          void Function(GetExecutionTimeRequest) updates) =>
      super.copyWith((message) => updates(message as GetExecutionTimeRequest))
          as GetExecutionTimeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExecutionTimeRequest create() => GetExecutionTimeRequest._();
  @$core.override
  GetExecutionTimeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetExecutionTimeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetExecutionTimeRequest>(create);
  static GetExecutionTimeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class SetExecutionTimeRequest extends $pb.GeneratedMessage {
  factory SetExecutionTimeRequest({
    $core.String? datasource,
    $core.Iterable<CosemDateTimeEntry>? times,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (times != null) result.times.addAll(times);
    return result;
  }

  SetExecutionTimeRequest._();

  factory SetExecutionTimeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetExecutionTimeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetExecutionTimeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..pPM<CosemDateTimeEntry>(2, _omitFieldNames ? '' : 'times',
        subBuilder: CosemDateTimeEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExecutionTimeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetExecutionTimeRequest copyWith(
          void Function(SetExecutionTimeRequest) updates) =>
      super.copyWith((message) => updates(message as SetExecutionTimeRequest))
          as SetExecutionTimeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetExecutionTimeRequest create() => SetExecutionTimeRequest._();
  @$core.override
  SetExecutionTimeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetExecutionTimeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetExecutionTimeRequest>(create);
  static SetExecutionTimeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<CosemDateTimeEntry> get times => $_getList(1);
}

class GetPushActionTypeRequest extends $pb.GeneratedMessage {
  factory GetPushActionTypeRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetPushActionTypeRequest._();

  factory GetPushActionTypeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushActionTypeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushActionTypeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionTypeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionTypeRequest copyWith(
          void Function(GetPushActionTypeRequest) updates) =>
      super.copyWith((message) => updates(message as GetPushActionTypeRequest))
          as GetPushActionTypeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushActionTypeRequest create() => GetPushActionTypeRequest._();
  @$core.override
  GetPushActionTypeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushActionTypeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushActionTypeRequest>(create);
  static GetPushActionTypeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetPushActionExecutedScriptRequest extends $pb.GeneratedMessage {
  factory GetPushActionExecutedScriptRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetPushActionExecutedScriptRequest._();

  factory GetPushActionExecutedScriptRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushActionExecutedScriptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushActionExecutedScriptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionExecutedScriptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionExecutedScriptRequest copyWith(
          void Function(GetPushActionExecutedScriptRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetPushActionExecutedScriptRequest))
          as GetPushActionExecutedScriptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushActionExecutedScriptRequest create() =>
      GetPushActionExecutedScriptRequest._();
  @$core.override
  GetPushActionExecutedScriptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushActionExecutedScriptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushActionExecutedScriptRequest>(
          create);
  static GetPushActionExecutedScriptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetPushActionExecutedScriptResponse extends $pb.GeneratedMessage {
  factory GetPushActionExecutedScriptResponse({
    $core.int? scriptSelector,
    $core.String? scriptTable,
  }) {
    final result = create();
    if (scriptSelector != null) result.scriptSelector = scriptSelector;
    if (scriptTable != null) result.scriptTable = scriptTable;
    return result;
  }

  GetPushActionExecutedScriptResponse._();

  factory GetPushActionExecutedScriptResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushActionExecutedScriptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushActionExecutedScriptResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'scriptSelector')
    ..aOS(2, _omitFieldNames ? '' : 'scriptTable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionExecutedScriptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushActionExecutedScriptResponse copyWith(
          void Function(GetPushActionExecutedScriptResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetPushActionExecutedScriptResponse))
          as GetPushActionExecutedScriptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushActionExecutedScriptResponse create() =>
      GetPushActionExecutedScriptResponse._();
  @$core.override
  GetPushActionExecutedScriptResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushActionExecutedScriptResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetPushActionExecutedScriptResponse>(create);
  static GetPushActionExecutedScriptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get scriptSelector => $_getIZ(0);
  @$pb.TagNumber(1)
  set scriptSelector($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScriptSelector() => $_has(0);
  @$pb.TagNumber(1)
  void clearScriptSelector() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scriptTable => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptTable($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptTable() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptTable() => $_clearField(2);
}

class SetPushActionExecutedScriptRequest extends $pb.GeneratedMessage {
  factory SetPushActionExecutedScriptRequest({
    $core.String? datasource,
    $core.int? scriptSelector,
    $core.String? scriptTable,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (scriptSelector != null) result.scriptSelector = scriptSelector;
    if (scriptTable != null) result.scriptTable = scriptTable;
    return result;
  }

  SetPushActionExecutedScriptRequest._();

  factory SetPushActionExecutedScriptRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPushActionExecutedScriptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPushActionExecutedScriptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'scriptSelector')
    ..aOS(3, _omitFieldNames ? '' : 'scriptTable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPushActionExecutedScriptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPushActionExecutedScriptRequest copyWith(
          void Function(SetPushActionExecutedScriptRequest) updates) =>
      super.copyWith((message) =>
              updates(message as SetPushActionExecutedScriptRequest))
          as SetPushActionExecutedScriptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPushActionExecutedScriptRequest create() =>
      SetPushActionExecutedScriptRequest._();
  @$core.override
  SetPushActionExecutedScriptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPushActionExecutedScriptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPushActionExecutedScriptRequest>(
          create);
  static SetPushActionExecutedScriptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get scriptSelector => $_getIZ(1);
  @$pb.TagNumber(2)
  set scriptSelector($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptSelector() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptSelector() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scriptTable => $_getSZ(2);
  @$pb.TagNumber(3)
  set scriptTable($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScriptTable() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptTable() => $_clearField(3);
}

class GetScriptTableRequest extends $pb.GeneratedMessage {
  factory GetScriptTableRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetScriptTableRequest._();

  factory GetScriptTableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScriptTableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScriptTableRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScriptTableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScriptTableRequest copyWith(
          void Function(GetScriptTableRequest) updates) =>
      super.copyWith((message) => updates(message as GetScriptTableRequest))
          as GetScriptTableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScriptTableRequest create() => GetScriptTableRequest._();
  @$core.override
  GetScriptTableRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScriptTableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScriptTableRequest>(create);
  static GetScriptTableRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class ExecuteScriptTableRequest extends $pb.GeneratedMessage {
  factory ExecuteScriptTableRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  ExecuteScriptTableRequest._();

  factory ExecuteScriptTableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteScriptTableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteScriptTableRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteScriptTableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteScriptTableRequest copyWith(
          void Function(ExecuteScriptTableRequest) updates) =>
      super.copyWith((message) => updates(message as ExecuteScriptTableRequest))
          as ExecuteScriptTableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteScriptTableRequest create() => ExecuteScriptTableRequest._();
  @$core.override
  ExecuteScriptTableRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteScriptTableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteScriptTableRequest>(create);
  static ExecuteScriptTableRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

/// Capture object entry returned by GetCaptureObjects
class CaptureObjectEntry extends $pb.GeneratedMessage {
  factory CaptureObjectEntry({
    $core.int? classId,
    $core.String? obisCode,
    $core.String? name,
    $core.int? attributeIndex,
    $core.int? dataIndex,
  }) {
    final result = create();
    if (classId != null) result.classId = classId;
    if (obisCode != null) result.obisCode = obisCode;
    if (name != null) result.name = name;
    if (attributeIndex != null) result.attributeIndex = attributeIndex;
    if (dataIndex != null) result.dataIndex = dataIndex;
    return result;
  }

  CaptureObjectEntry._();

  factory CaptureObjectEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CaptureObjectEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CaptureObjectEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'classId')
    ..aOS(2, _omitFieldNames ? '' : 'obisCode')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aI(4, _omitFieldNames ? '' : 'attributeIndex')
    ..aI(5, _omitFieldNames ? '' : 'dataIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CaptureObjectEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CaptureObjectEntry copyWith(void Function(CaptureObjectEntry) updates) =>
      super.copyWith((message) => updates(message as CaptureObjectEntry))
          as CaptureObjectEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CaptureObjectEntry create() => CaptureObjectEntry._();
  @$core.override
  CaptureObjectEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CaptureObjectEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CaptureObjectEntry>(create);
  static CaptureObjectEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get obisCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set obisCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObisCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearObisCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get attributeIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set attributeIndex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAttributeIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearAttributeIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get dataIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set dataIndex($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDataIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearDataIndex() => $_clearField(5);
}

class GetPushSelectiveCaptureObjectsRequest extends $pb.GeneratedMessage {
  factory GetPushSelectiveCaptureObjectsRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  GetPushSelectiveCaptureObjectsRequest._();

  factory GetPushSelectiveCaptureObjectsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushSelectiveCaptureObjectsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushSelectiveCaptureObjectsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushSelectiveCaptureObjectsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushSelectiveCaptureObjectsRequest copyWith(
          void Function(GetPushSelectiveCaptureObjectsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetPushSelectiveCaptureObjectsRequest))
          as GetPushSelectiveCaptureObjectsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushSelectiveCaptureObjectsRequest create() =>
      GetPushSelectiveCaptureObjectsRequest._();
  @$core.override
  GetPushSelectiveCaptureObjectsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushSelectiveCaptureObjectsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetPushSelectiveCaptureObjectsRequest>(create);
  static GetPushSelectiveCaptureObjectsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class GetPushSelectiveCaptureObjectsResponse extends $pb.GeneratedMessage {
  factory GetPushSelectiveCaptureObjectsResponse({
    $core.Iterable<CaptureObjectEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  GetPushSelectiveCaptureObjectsResponse._();

  factory GetPushSelectiveCaptureObjectsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushSelectiveCaptureObjectsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushSelectiveCaptureObjectsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<CaptureObjectEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: CaptureObjectEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushSelectiveCaptureObjectsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushSelectiveCaptureObjectsResponse copyWith(
          void Function(GetPushSelectiveCaptureObjectsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetPushSelectiveCaptureObjectsResponse))
          as GetPushSelectiveCaptureObjectsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushSelectiveCaptureObjectsResponse create() =>
      GetPushSelectiveCaptureObjectsResponse._();
  @$core.override
  GetPushSelectiveCaptureObjectsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushSelectiveCaptureObjectsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetPushSelectiveCaptureObjectsResponse>(create);
  static GetPushSelectiveCaptureObjectsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CaptureObjectEntry> get entries => $_getList(0);
}

class GetPushRecoveryObjectsRequestItem extends $pb.GeneratedMessage {
  factory GetPushRecoveryObjectsRequestItem({
    $core.String? datasource,
    $core.int? attribute,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    if (attribute != null) result.attribute = attribute;
    return result;
  }

  GetPushRecoveryObjectsRequestItem._();

  factory GetPushRecoveryObjectsRequestItem.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushRecoveryObjectsRequestItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushRecoveryObjectsRequestItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..aI(2, _omitFieldNames ? '' : 'attribute')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsRequestItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsRequestItem copyWith(
          void Function(GetPushRecoveryObjectsRequestItem) updates) =>
      super.copyWith((message) =>
              updates(message as GetPushRecoveryObjectsRequestItem))
          as GetPushRecoveryObjectsRequestItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsRequestItem create() =>
      GetPushRecoveryObjectsRequestItem._();
  @$core.override
  GetPushRecoveryObjectsRequestItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsRequestItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushRecoveryObjectsRequestItem>(
          create);
  static GetPushRecoveryObjectsRequestItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get attribute => $_getIZ(1);
  @$pb.TagNumber(2)
  set attribute($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAttribute() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttribute() => $_clearField(2);
}

class GetPushRecoveryObjectsRequest extends $pb.GeneratedMessage {
  factory GetPushRecoveryObjectsRequest({
    $core.Iterable<GetPushRecoveryObjectsRequestItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  GetPushRecoveryObjectsRequest._();

  factory GetPushRecoveryObjectsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushRecoveryObjectsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushRecoveryObjectsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<GetPushRecoveryObjectsRequestItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: GetPushRecoveryObjectsRequestItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsRequest copyWith(
          void Function(GetPushRecoveryObjectsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetPushRecoveryObjectsRequest))
          as GetPushRecoveryObjectsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsRequest create() =>
      GetPushRecoveryObjectsRequest._();
  @$core.override
  GetPushRecoveryObjectsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushRecoveryObjectsRequest>(create);
  static GetPushRecoveryObjectsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetPushRecoveryObjectsRequestItem> get items => $_getList(0);
}

class GetPushRecoveryObjectsResponse extends $pb.GeneratedMessage {
  factory GetPushRecoveryObjectsResponse({
    $core.Iterable<$core.String>? results,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    return result;
  }

  GetPushRecoveryObjectsResponse._();

  factory GetPushRecoveryObjectsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPushRecoveryObjectsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPushRecoveryObjectsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'results')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPushRecoveryObjectsResponse copyWith(
          void Function(GetPushRecoveryObjectsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetPushRecoveryObjectsResponse))
          as GetPushRecoveryObjectsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsResponse create() =>
      GetPushRecoveryObjectsResponse._();
  @$core.override
  GetPushRecoveryObjectsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPushRecoveryObjectsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPushRecoveryObjectsResponse>(create);
  static GetPushRecoveryObjectsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get results => $_getList(0);
}

class PushSetupPushRequest extends $pb.GeneratedMessage {
  factory PushSetupPushRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  PushSetupPushRequest._();

  factory PushSetupPushRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushSetupPushRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushSetupPushRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSetupPushRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSetupPushRequest copyWith(void Function(PushSetupPushRequest) updates) =>
      super.copyWith((message) => updates(message as PushSetupPushRequest))
          as PushSetupPushRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushSetupPushRequest create() => PushSetupPushRequest._();
  @$core.override
  PushSetupPushRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushSetupPushRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushSetupPushRequest>(create);
  static PushSetupPushRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class PushSetupResetRequest extends $pb.GeneratedMessage {
  factory PushSetupResetRequest({
    $core.String? datasource,
  }) {
    final result = create();
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  PushSetupResetRequest._();

  factory PushSetupResetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushSetupResetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushSetupResetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSetupResetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushSetupResetRequest copyWith(
          void Function(PushSetupResetRequest) updates) =>
      super.copyWith((message) => updates(message as PushSetupResetRequest))
          as PushSetupResetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushSetupResetRequest create() => PushSetupResetRequest._();
  @$core.override
  PushSetupResetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushSetupResetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushSetupResetRequest>(create);
  static PushSetupResetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datasource => $_getSZ(0);
  @$pb.TagNumber(1)
  set datasource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatasource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatasource() => $_clearField(1);
}

class ScriptTableEntry extends $pb.GeneratedMessage {
  factory ScriptTableEntry({
    $core.int? scriptIdentifier,
    $core.int? serviceId,
    $core.int? classId,
    $core.String? logicalName,
    $core.int? index,
    $core.String? parameter,
  }) {
    final result = create();
    if (scriptIdentifier != null) result.scriptIdentifier = scriptIdentifier;
    if (serviceId != null) result.serviceId = serviceId;
    if (classId != null) result.classId = classId;
    if (logicalName != null) result.logicalName = logicalName;
    if (index != null) result.index = index;
    if (parameter != null) result.parameter = parameter;
    return result;
  }

  ScriptTableEntry._();

  factory ScriptTableEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScriptTableEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScriptTableEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'scriptIdentifier')
    ..aI(2, _omitFieldNames ? '' : 'serviceId')
    ..aI(3, _omitFieldNames ? '' : 'classId')
    ..aOS(4, _omitFieldNames ? '' : 'logicalName')
    ..aI(5, _omitFieldNames ? '' : 'index')
    ..aOS(6, _omitFieldNames ? '' : 'parameter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptTableEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScriptTableEntry copyWith(void Function(ScriptTableEntry) updates) =>
      super.copyWith((message) => updates(message as ScriptTableEntry))
          as ScriptTableEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScriptTableEntry create() => ScriptTableEntry._();
  @$core.override
  ScriptTableEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScriptTableEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScriptTableEntry>(create);
  static ScriptTableEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get scriptIdentifier => $_getIZ(0);
  @$pb.TagNumber(1)
  set scriptIdentifier($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScriptIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearScriptIdentifier() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serviceId => $_getIZ(1);
  @$pb.TagNumber(2)
  set serviceId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServiceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearServiceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get classId => $_getIZ(2);
  @$pb.TagNumber(3)
  set classId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClassId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClassId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get logicalName => $_getSZ(3);
  @$pb.TagNumber(4)
  set logicalName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLogicalName() => $_has(3);
  @$pb.TagNumber(4)
  void clearLogicalName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get index => $_getIZ(4);
  @$pb.TagNumber(5)
  set index($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndex() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get parameter => $_getSZ(5);
  @$pb.TagNumber(6)
  set parameter($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasParameter() => $_has(5);
  @$pb.TagNumber(6)
  void clearParameter() => $_clearField(6);
}

class GetScriptTableResponse extends $pb.GeneratedMessage {
  factory GetScriptTableResponse({
    $core.Iterable<ScriptTableEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  GetScriptTableResponse._();

  factory GetScriptTableResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScriptTableResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScriptTableResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<ScriptTableEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ScriptTableEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScriptTableResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScriptTableResponse copyWith(
          void Function(GetScriptTableResponse) updates) =>
      super.copyWith((message) => updates(message as GetScriptTableResponse))
          as GetScriptTableResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScriptTableResponse create() => GetScriptTableResponse._();
  @$core.override
  GetScriptTableResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScriptTableResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScriptTableResponse>(create);
  static GetScriptTableResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ScriptTableEntry> get entries => $_getList(0);
}

class DatamodelObject extends $pb.GeneratedMessage {
  factory DatamodelObject({
    $core.String? name,
    $core.int? classId,
    $core.String? logicalName,
    $core.String? logicalNameHex,
    $core.String? description,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (classId != null) result.classId = classId;
    if (logicalName != null) result.logicalName = logicalName;
    if (logicalNameHex != null) result.logicalNameHex = logicalNameHex;
    if (description != null) result.description = description;
    return result;
  }

  DatamodelObject._();

  factory DatamodelObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DatamodelObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DatamodelObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'classId', protoName: 'classId')
    ..aOS(3, _omitFieldNames ? '' : 'logicalName', protoName: 'logicalName')
    ..aOS(4, _omitFieldNames ? '' : 'logicalNameHex',
        protoName: 'logicalName_hex')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatamodelObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatamodelObject copyWith(void Function(DatamodelObject) updates) =>
      super.copyWith((message) => updates(message as DatamodelObject))
          as DatamodelObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DatamodelObject create() => DatamodelObject._();
  @$core.override
  DatamodelObject createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DatamodelObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DatamodelObject>(create);
  static DatamodelObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get classId => $_getIZ(1);
  @$pb.TagNumber(2)
  set classId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClassId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClassId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get logicalName => $_getSZ(2);
  @$pb.TagNumber(3)
  set logicalName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLogicalName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLogicalName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get logicalNameHex => $_getSZ(3);
  @$pb.TagNumber(4)
  set logicalNameHex($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLogicalNameHex() => $_has(3);
  @$pb.TagNumber(4)
  void clearLogicalNameHex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);
}

class GetDatamodelObjectsResponse extends $pb.GeneratedMessage {
  factory GetDatamodelObjectsResponse({
    $core.Iterable<DatamodelObject>? objects,
  }) {
    final result = create();
    if (objects != null) result.objects.addAll(objects);
    return result;
  }

  GetDatamodelObjectsResponse._();

  factory GetDatamodelObjectsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDatamodelObjectsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDatamodelObjectsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<DatamodelObject>(1, _omitFieldNames ? '' : 'objects',
        subBuilder: DatamodelObject.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelObjectsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelObjectsResponse copyWith(
          void Function(GetDatamodelObjectsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetDatamodelObjectsResponse))
          as GetDatamodelObjectsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDatamodelObjectsResponse create() =>
      GetDatamodelObjectsResponse._();
  @$core.override
  GetDatamodelObjectsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDatamodelObjectsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDatamodelObjectsResponse>(create);
  static GetDatamodelObjectsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DatamodelObject> get objects => $_getList(0);
}

class GetDatamodelAttributesByObjectNameRequest extends $pb.GeneratedMessage {
  factory GetDatamodelAttributesByObjectNameRequest({
    $core.String? objectName,
    $core.String? clientName,
  }) {
    final result = create();
    if (objectName != null) result.objectName = objectName;
    if (clientName != null) result.clientName = clientName;
    return result;
  }

  GetDatamodelAttributesByObjectNameRequest._();

  factory GetDatamodelAttributesByObjectNameRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDatamodelAttributesByObjectNameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDatamodelAttributesByObjectNameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectName', protoName: 'objectName')
    ..aOS(2, _omitFieldNames ? '' : 'clientName', protoName: 'clientName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelAttributesByObjectNameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelAttributesByObjectNameRequest copyWith(
          void Function(GetDatamodelAttributesByObjectNameRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetDatamodelAttributesByObjectNameRequest))
          as GetDatamodelAttributesByObjectNameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDatamodelAttributesByObjectNameRequest create() =>
      GetDatamodelAttributesByObjectNameRequest._();
  @$core.override
  GetDatamodelAttributesByObjectNameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDatamodelAttributesByObjectNameRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDatamodelAttributesByObjectNameRequest>(create);
  static GetDatamodelAttributesByObjectNameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectName => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectName() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientName => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientName() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientName() => $_clearField(2);
}

class DatamodelAttribute extends $pb.GeneratedMessage {
  factory DatamodelAttribute({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    $core.String? accessRights,
    $core.String? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (accessRights != null) result.accessRights = accessRights;
    if (type != null) result.type = type;
    return result;
  }

  DatamodelAttribute._();

  factory DatamodelAttribute.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DatamodelAttribute.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DatamodelAttribute',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'accessRights', protoName: 'accessRights')
    ..aOS(5, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatamodelAttribute clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatamodelAttribute copyWith(void Function(DatamodelAttribute) updates) =>
      super.copyWith((message) => updates(message as DatamodelAttribute))
          as DatamodelAttribute;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DatamodelAttribute create() => DatamodelAttribute._();
  @$core.override
  DatamodelAttribute createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DatamodelAttribute getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DatamodelAttribute>(create);
  static DatamodelAttribute? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get accessRights => $_getSZ(3);
  @$pb.TagNumber(4)
  set accessRights($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccessRights() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccessRights() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get type => $_getSZ(4);
  @$pb.TagNumber(5)
  set type($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);
}

class GetDatamodelAttributesByObjectNameResponse extends $pb.GeneratedMessage {
  factory GetDatamodelAttributesByObjectNameResponse({
    $core.Iterable<DatamodelAttribute>? attributes,
  }) {
    final result = create();
    if (attributes != null) result.attributes.addAll(attributes);
    return result;
  }

  GetDatamodelAttributesByObjectNameResponse._();

  factory GetDatamodelAttributesByObjectNameResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDatamodelAttributesByObjectNameResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDatamodelAttributesByObjectNameResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<DatamodelAttribute>(1, _omitFieldNames ? '' : 'attributes',
        subBuilder: DatamodelAttribute.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelAttributesByObjectNameResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatamodelAttributesByObjectNameResponse copyWith(
          void Function(GetDatamodelAttributesByObjectNameResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetDatamodelAttributesByObjectNameResponse))
          as GetDatamodelAttributesByObjectNameResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDatamodelAttributesByObjectNameResponse create() =>
      GetDatamodelAttributesByObjectNameResponse._();
  @$core.override
  GetDatamodelAttributesByObjectNameResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDatamodelAttributesByObjectNameResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDatamodelAttributesByObjectNameResponse>(create);
  static GetDatamodelAttributesByObjectNameResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DatamodelAttribute> get attributes => $_getList(0);
}

class ReadQualityConfigRequest extends $pb.GeneratedMessage {
  factory ReadQualityConfigRequest({
    $core.String? dataSource,
  }) {
    final result = create();
    if (dataSource != null) result.dataSource = dataSource;
    return result;
  }

  ReadQualityConfigRequest._();

  factory ReadQualityConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadQualityConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadQualityConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataSource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadQualityConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadQualityConfigRequest copyWith(
          void Function(ReadQualityConfigRequest) updates) =>
      super.copyWith((message) => updates(message as ReadQualityConfigRequest))
          as ReadQualityConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadQualityConfigRequest create() => ReadQualityConfigRequest._();
  @$core.override
  ReadQualityConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadQualityConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadQualityConfigRequest>(create);
  static ReadQualityConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataSource => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataSource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataSource() => $_clearField(1);
}

class QualityConfigValue extends $pb.GeneratedMessage {
  factory QualityConfigValue({
    $core.int? value,
    $core.String? type,
  }) {
    final result = create();
    if (value != null) result.value = value;
    if (type != null) result.type = type;
    return result;
  }

  QualityConfigValue._();

  factory QualityConfigValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QualityConfigValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QualityConfigValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'value')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityConfigValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityConfigValue copyWith(void Function(QualityConfigValue) updates) =>
      super.copyWith((message) => updates(message as QualityConfigValue))
          as QualityConfigValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QualityConfigValue create() => QualityConfigValue._();
  @$core.override
  QualityConfigValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QualityConfigValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QualityConfigValue>(create);
  static QualityConfigValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get value => $_getIZ(0);
  @$pb.TagNumber(1)
  set value($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

class QualityConfigValues extends $pb.GeneratedMessage {
  factory QualityConfigValues({
    $core.Iterable<QualityConfigValue>? values,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    return result;
  }

  QualityConfigValues._();

  factory QualityConfigValues.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QualityConfigValues.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QualityConfigValues',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<QualityConfigValue>(1, _omitFieldNames ? '' : 'values',
        subBuilder: QualityConfigValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityConfigValues clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityConfigValues copyWith(void Function(QualityConfigValues) updates) =>
      super.copyWith((message) => updates(message as QualityConfigValues))
          as QualityConfigValues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QualityConfigValues create() => QualityConfigValues._();
  @$core.override
  QualityConfigValues createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QualityConfigValues getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QualityConfigValues>(create);
  static QualityConfigValues? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<QualityConfigValue> get values => $_getList(0);
}

enum ReadQualityConfigResponse_Result { value, values_, notSet }

class ReadQualityConfigResponse extends $pb.GeneratedMessage {
  factory ReadQualityConfigResponse({
    QualityConfigValue? value,
    QualityConfigValues? values,
  }) {
    final result = create();
    if (value != null) result.value = value;
    if (values != null) result.values = values;
    return result;
  }

  ReadQualityConfigResponse._();

  factory ReadQualityConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadQualityConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ReadQualityConfigResponse_Result>
      _ReadQualityConfigResponse_ResultByTag = {
    1: ReadQualityConfigResponse_Result.value,
    2: ReadQualityConfigResponse_Result.values_,
    0: ReadQualityConfigResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadQualityConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<QualityConfigValue>(1, _omitFieldNames ? '' : 'value',
        subBuilder: QualityConfigValue.create)
    ..aOM<QualityConfigValues>(2, _omitFieldNames ? '' : 'values',
        subBuilder: QualityConfigValues.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadQualityConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadQualityConfigResponse copyWith(
          void Function(ReadQualityConfigResponse) updates) =>
      super.copyWith((message) => updates(message as ReadQualityConfigResponse))
          as ReadQualityConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadQualityConfigResponse create() => ReadQualityConfigResponse._();
  @$core.override
  ReadQualityConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadQualityConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadQualityConfigResponse>(create);
  static ReadQualityConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ReadQualityConfigResponse_Result whichResult() =>
      _ReadQualityConfigResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  QualityConfigValue get value => $_getN(0);
  @$pb.TagNumber(1)
  set value(QualityConfigValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
  @$pb.TagNumber(1)
  QualityConfigValue ensureValue() => $_ensure(0);

  @$pb.TagNumber(2)
  QualityConfigValues get values => $_getN(1);
  @$pb.TagNumber(2)
  set values(QualityConfigValues value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValues() => $_has(1);
  @$pb.TagNumber(2)
  void clearValues() => $_clearField(2);
  @$pb.TagNumber(2)
  QualityConfigValues ensureValues() => $_ensure(1);
}

enum WriteQualityConfigRequest_Payload { value, values_, notSet }

class WriteQualityConfigRequest extends $pb.GeneratedMessage {
  factory WriteQualityConfigRequest({
    $core.String? dataSource,
    QualityConfigValue? value,
    QualityConfigValues? values,
  }) {
    final result = create();
    if (dataSource != null) result.dataSource = dataSource;
    if (value != null) result.value = value;
    if (values != null) result.values = values;
    return result;
  }

  WriteQualityConfigRequest._();

  factory WriteQualityConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WriteQualityConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WriteQualityConfigRequest_Payload>
      _WriteQualityConfigRequest_PayloadByTag = {
    2: WriteQualityConfigRequest_Payload.value,
    3: WriteQualityConfigRequest_Payload.values_,
    0: WriteQualityConfigRequest_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WriteQualityConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'dataSource')
    ..aOM<QualityConfigValue>(2, _omitFieldNames ? '' : 'value',
        subBuilder: QualityConfigValue.create)
    ..aOM<QualityConfigValues>(3, _omitFieldNames ? '' : 'values',
        subBuilder: QualityConfigValues.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteQualityConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WriteQualityConfigRequest copyWith(
          void Function(WriteQualityConfigRequest) updates) =>
      super.copyWith((message) => updates(message as WriteQualityConfigRequest))
          as WriteQualityConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WriteQualityConfigRequest create() => WriteQualityConfigRequest._();
  @$core.override
  WriteQualityConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WriteQualityConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WriteQualityConfigRequest>(create);
  static WriteQualityConfigRequest? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  WriteQualityConfigRequest_Payload whichPayload() =>
      _WriteQualityConfigRequest_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get dataSource => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataSource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataSource() => $_clearField(1);

  @$pb.TagNumber(2)
  QualityConfigValue get value => $_getN(1);
  @$pb.TagNumber(2)
  set value(QualityConfigValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  QualityConfigValue ensureValue() => $_ensure(1);

  @$pb.TagNumber(3)
  QualityConfigValues get values => $_getN(2);
  @$pb.TagNumber(3)
  set values(QualityConfigValues value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasValues() => $_has(2);
  @$pb.TagNumber(3)
  void clearValues() => $_clearField(3);
  @$pb.TagNumber(3)
  QualityConfigValues ensureValues() => $_ensure(2);
}

/// Request to load a specific datamodel by name
class LoadDatamodelRequest extends $pb.GeneratedMessage {
  factory LoadDatamodelRequest({
    $core.String? datamodel,
  }) {
    final result = create();
    if (datamodel != null) result.datamodel = datamodel;
    return result;
  }

  LoadDatamodelRequest._();

  factory LoadDatamodelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadDatamodelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadDatamodelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'datamodel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadDatamodelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadDatamodelRequest copyWith(void Function(LoadDatamodelRequest) updates) =>
      super.copyWith((message) => updates(message as LoadDatamodelRequest))
          as LoadDatamodelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadDatamodelRequest create() => LoadDatamodelRequest._();
  @$core.override
  LoadDatamodelRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadDatamodelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadDatamodelRequest>(create);
  static LoadDatamodelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datamodel => $_getSZ(0);
  @$pb.TagNumber(1)
  set datamodel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDatamodel() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatamodel() => $_clearField(1);
}

/// Progression d’exécution (avant transfert “massif”)
class ExecutionProgress extends $pb.GeneratedMessage {
  factory ExecutionProgress({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  ExecutionProgress._();

  factory ExecutionProgress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecutionProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecutionProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecutionProgress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecutionProgress copyWith(void Function(ExecutionProgress) updates) =>
      super.copyWith((message) => updates(message as ExecutionProgress))
          as ExecutionProgress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecutionProgress create() => ExecutionProgress._();
  @$core.override
  ExecutionProgress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecutionProgress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecutionProgress>(create);
  static ExecutionProgress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

/// Progression de téléchargement des données (pendant la lecture “longue”)
class DownloadProgress extends $pb.GeneratedMessage {
  factory DownloadProgress({
    $fixnum.Int64? rowsTotal,
    $core.int? percent,
    $fixnum.Int64? bytesTotal,
    $fixnum.Int64? bytesRead,
    $core.double? rateBytesPerSec,
  }) {
    final result = create();
    if (rowsTotal != null) result.rowsTotal = rowsTotal;
    if (percent != null) result.percent = percent;
    if (bytesTotal != null) result.bytesTotal = bytesTotal;
    if (bytesRead != null) result.bytesRead = bytesRead;
    if (rateBytesPerSec != null) result.rateBytesPerSec = rateBytesPerSec;
    return result;
  }

  DownloadProgress._();

  factory DownloadProgress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'rowsTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(2, _omitFieldNames ? '' : 'percent')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'bytesTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'bytesRead', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(5, _omitFieldNames ? '' : 'rateBytesPerSec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadProgress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadProgress copyWith(void Function(DownloadProgress) updates) =>
      super.copyWith((message) => updates(message as DownloadProgress))
          as DownloadProgress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadProgress create() => DownloadProgress._();
  @$core.override
  DownloadProgress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadProgress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadProgress>(create);
  static DownloadProgress? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get rowsTotal => $_getI64(0);
  @$pb.TagNumber(1)
  set rowsTotal($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRowsTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearRowsTotal() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get percent => $_getIZ(1);
  @$pb.TagNumber(2)
  set percent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearPercent() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesTotal => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesTotal($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesTotal() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesTotal() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get bytesRead => $_getI64(3);
  @$pb.TagNumber(4)
  set bytesRead($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBytesRead() => $_has(3);
  @$pb.TagNumber(4)
  void clearBytesRead() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get rateBytesPerSec => $_getN(4);
  @$pb.TagNumber(5)
  set rateBytesPerSec($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRateBytesPerSec() => $_has(4);
  @$pb.TagNumber(5)
  void clearRateBytesPerSec() => $_clearField(5);
}

enum GetLoadProfileStreamItem_Item { exec, download, result, notSet }

class GetLoadProfileStreamItem extends $pb.GeneratedMessage {
  factory GetLoadProfileStreamItem({
    ExecutionProgress? exec,
    DownloadProgress? download,
    GetLoadProfileResponse? result,
  }) {
    final result$ = create();
    if (exec != null) result$.exec = exec;
    if (download != null) result$.download = download;
    if (result != null) result$.result = result;
    return result$;
  }

  GetLoadProfileStreamItem._();

  factory GetLoadProfileStreamItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLoadProfileStreamItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetLoadProfileStreamItem_Item>
      _GetLoadProfileStreamItem_ItemByTag = {
    1: GetLoadProfileStreamItem_Item.exec,
    2: GetLoadProfileStreamItem_Item.download,
    3: GetLoadProfileStreamItem_Item.result,
    0: GetLoadProfileStreamItem_Item.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLoadProfileStreamItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<ExecutionProgress>(1, _omitFieldNames ? '' : 'exec',
        subBuilder: ExecutionProgress.create)
    ..aOM<DownloadProgress>(2, _omitFieldNames ? '' : 'download',
        subBuilder: DownloadProgress.create)
    ..aOM<GetLoadProfileResponse>(3, _omitFieldNames ? '' : 'result',
        subBuilder: GetLoadProfileResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileStreamItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileStreamItem copyWith(
          void Function(GetLoadProfileStreamItem) updates) =>
      super.copyWith((message) => updates(message as GetLoadProfileStreamItem))
          as GetLoadProfileStreamItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLoadProfileStreamItem create() => GetLoadProfileStreamItem._();
  @$core.override
  GetLoadProfileStreamItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLoadProfileStreamItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLoadProfileStreamItem>(create);
  static GetLoadProfileStreamItem? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  GetLoadProfileStreamItem_Item whichItem() =>
      _GetLoadProfileStreamItem_ItemByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearItem() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ExecutionProgress get exec => $_getN(0);
  @$pb.TagNumber(1)
  set exec(ExecutionProgress value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasExec() => $_has(0);
  @$pb.TagNumber(1)
  void clearExec() => $_clearField(1);
  @$pb.TagNumber(1)
  ExecutionProgress ensureExec() => $_ensure(0);

  @$pb.TagNumber(2)
  DownloadProgress get download => $_getN(1);
  @$pb.TagNumber(2)
  set download(DownloadProgress value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDownload() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownload() => $_clearField(2);
  @$pb.TagNumber(2)
  DownloadProgress ensureDownload() => $_ensure(1);

  @$pb.TagNumber(3)
  GetLoadProfileResponse get result => $_getN(2);
  @$pb.TagNumber(3)
  set result(GetLoadProfileResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => $_clearField(3);
  @$pb.TagNumber(3)
  GetLoadProfileResponse ensureResult() => $_ensure(2);
}

class ActivationDateTime extends $pb.GeneratedMessage {
  factory ActivationDateTime({
    $core.int? year,
    $core.int? month,
    $core.int? day,
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
  }) {
    final result = create();
    if (year != null) result.year = year;
    if (month != null) result.month = month;
    if (day != null) result.day = day;
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    return result;
  }

  ActivationDateTime._();

  factory ActivationDateTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivationDateTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivationDateTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'year')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'day')
    ..aI(4, _omitFieldNames ? '' : 'hour')
    ..aI(5, _omitFieldNames ? '' : 'minute')
    ..aI(6, _omitFieldNames ? '' : 'second')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivationDateTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivationDateTime copyWith(void Function(ActivationDateTime) updates) =>
      super.copyWith((message) => updates(message as ActivationDateTime))
          as ActivationDateTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivationDateTime create() => ActivationDateTime._();
  @$core.override
  ActivationDateTime createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivationDateTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivationDateTime>(create);
  static ActivationDateTime? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get year => $_getIZ(0);
  @$pb.TagNumber(1)
  set year($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYear() => $_has(0);
  @$pb.TagNumber(1)
  void clearYear() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get day => $_getIZ(2);
  @$pb.TagNumber(3)
  set day($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearDay() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get hour => $_getIZ(3);
  @$pb.TagNumber(4)
  set hour($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHour() => $_has(3);
  @$pb.TagNumber(4)
  void clearHour() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get minute => $_getIZ(4);
  @$pb.TagNumber(5)
  set minute($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinute() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinute() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get second => $_getIZ(5);
  @$pb.TagNumber(6)
  set second($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecond() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecond() => $_clearField(6);
}

class DaylightSavingsTime extends $pb.GeneratedMessage {
  factory DaylightSavingsTime({
    $core.int? day,
    $core.int? month,
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
    $core.int? dayOfWeek,
  }) {
    final result = create();
    if (day != null) result.day = day;
    if (month != null) result.month = month;
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    if (dayOfWeek != null) result.dayOfWeek = dayOfWeek;
    return result;
  }

  DaylightSavingsTime._();

  factory DaylightSavingsTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DaylightSavingsTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DaylightSavingsTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'day')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'hour')
    ..aI(4, _omitFieldNames ? '' : 'minute')
    ..aI(5, _omitFieldNames ? '' : 'second')
    ..aI(6, _omitFieldNames ? '' : 'dayOfWeek', protoName: 'dayOfWeek')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DaylightSavingsTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DaylightSavingsTime copyWith(void Function(DaylightSavingsTime) updates) =>
      super.copyWith((message) => updates(message as DaylightSavingsTime))
          as DaylightSavingsTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DaylightSavingsTime create() => DaylightSavingsTime._();
  @$core.override
  DaylightSavingsTime createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DaylightSavingsTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DaylightSavingsTime>(create);
  static DaylightSavingsTime? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get day => $_getIZ(0);
  @$pb.TagNumber(1)
  set day($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDay() => $_has(0);
  @$pb.TagNumber(1)
  void clearDay() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get hour => $_getIZ(2);
  @$pb.TagNumber(3)
  set hour($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHour() => $_has(2);
  @$pb.TagNumber(3)
  void clearHour() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get minute => $_getIZ(3);
  @$pb.TagNumber(4)
  set minute($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMinute() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinute() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get second => $_getIZ(4);
  @$pb.TagNumber(5)
  set second($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSecond() => $_has(4);
  @$pb.TagNumber(5)
  void clearSecond() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get dayOfWeek => $_getIZ(5);
  @$pb.TagNumber(6)
  set dayOfWeek($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDayOfWeek() => $_has(5);
  @$pb.TagNumber(6)
  void clearDayOfWeek() => $_clearField(6);
}

/// Each phase reading: voltage (u), current (i), phase angle (phi).
class PhaseData extends $pb.GeneratedMessage {
  factory PhaseData({
    $core.double? u,
    $core.double? i,
    $core.double? phi,
  }) {
    final result = create();
    if (u != null) result.u = u;
    if (i != null) result.i = i;
    if (phi != null) result.phi = phi;
    return result;
  }

  PhaseData._();

  factory PhaseData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PhaseData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PhaseData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'u')
    ..aD(2, _omitFieldNames ? '' : 'i')
    ..aD(3, _omitFieldNames ? '' : 'phi')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PhaseData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PhaseData copyWith(void Function(PhaseData) updates) =>
      super.copyWith((message) => updates(message as PhaseData)) as PhaseData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PhaseData create() => PhaseData._();
  @$core.override
  PhaseData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PhaseData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PhaseData>(create);
  static PhaseData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get u => $_getN(0);
  @$pb.TagNumber(1)
  set u($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasU() => $_has(0);
  @$pb.TagNumber(1)
  void clearU() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get i => $_getN(1);
  @$pb.TagNumber(2)
  set i($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasI() => $_has(1);
  @$pb.TagNumber(2)
  void clearI() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get phi => $_getN(2);
  @$pb.TagNumber(3)
  set phi($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhi() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhi() => $_clearField(3);
}

/// Wrap the list to keep response extensible.
class FresnelResponse extends $pb.GeneratedMessage {
  factory FresnelResponse({
    $core.Iterable<PhaseData>? phases,
  }) {
    final result = create();
    if (phases != null) result.phases.addAll(phases);
    return result;
  }

  FresnelResponse._();

  factory FresnelResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FresnelResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FresnelResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<PhaseData>(1, _omitFieldNames ? '' : 'phases',
        subBuilder: PhaseData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FresnelResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FresnelResponse copyWith(void Function(FresnelResponse) updates) =>
      super.copyWith((message) => updates(message as FresnelResponse))
          as FresnelResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FresnelResponse create() => FresnelResponse._();
  @$core.override
  FresnelResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FresnelResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FresnelResponse>(create);
  static FresnelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PhaseData> get phases => $_getList(0);
}

/// ==========================
/// Device Identification (NEW)
/// ==========================
/// New generic pair
class DeviceIDResponse extends $pb.GeneratedMessage {
  factory DeviceIDResponse({
    $core.String? name,
    $core.String? value,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  DeviceIDResponse._();

  factory DeviceIDResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceIDResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceIDResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceIDResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceIDResponse copyWith(void Function(DeviceIDResponse) updates) =>
      super.copyWith((message) => updates(message as DeviceIDResponse))
          as DeviceIDResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceIDResponse create() => DeviceIDResponse._();
  @$core.override
  DeviceIDResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceIDResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceIDResponse>(create);
  static DeviceIDResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

/// New list-based response
class DeviceIDList extends $pb.GeneratedMessage {
  factory DeviceIDList({
    $core.Iterable<DeviceIDResponse>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  DeviceIDList._();

  factory DeviceIDList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceIDList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceIDList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<DeviceIDResponse>(1, _omitFieldNames ? '' : 'items',
        subBuilder: DeviceIDResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceIDList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceIDList copyWith(void Function(DeviceIDList) updates) =>
      super.copyWith((message) => updates(message as DeviceIDList))
          as DeviceIDList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceIDList create() => DeviceIDList._();
  @$core.override
  DeviceIDList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceIDList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceIDList>(create);
  static DeviceIDList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DeviceIDResponse> get items => $_getList(0);
}

/// ==========================
/// Firmware Version (NEW)
/// ==========================
/// New generic pair
class FirmwareVersionResponse extends $pb.GeneratedMessage {
  factory FirmwareVersionResponse({
    $core.String? name,
    $core.String? value,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  FirmwareVersionResponse._();

  factory FirmwareVersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FirmwareVersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirmwareVersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersionResponse copyWith(
          void Function(FirmwareVersionResponse) updates) =>
      super.copyWith((message) => updates(message as FirmwareVersionResponse))
          as FirmwareVersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FirmwareVersionResponse create() => FirmwareVersionResponse._();
  @$core.override
  FirmwareVersionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FirmwareVersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FirmwareVersionResponse>(create);
  static FirmwareVersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

/// New list-based response
class FirmwareVersionList extends $pb.GeneratedMessage {
  factory FirmwareVersionList({
    $core.Iterable<FirmwareVersionResponse>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  FirmwareVersionList._();

  factory FirmwareVersionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FirmwareVersionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirmwareVersionList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<FirmwareVersionResponse>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FirmwareVersionResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersionList copyWith(void Function(FirmwareVersionList) updates) =>
      super.copyWith((message) => updates(message as FirmwareVersionList))
          as FirmwareVersionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FirmwareVersionList create() => FirmwareVersionList._();
  @$core.override
  FirmwareVersionList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FirmwareVersionList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FirmwareVersionList>(create);
  static FirmwareVersionList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FirmwareVersionResponse> get items => $_getList(0);
}

/// ==========================
/// Energy Register (NEW)
/// ==========================
/// New generic pair
class EnergyRegisterResponse extends $pb.GeneratedMessage {
  factory EnergyRegisterResponse({
    $core.String? description,
    $core.String? value,
  }) {
    final result = create();
    if (description != null) result.description = description;
    if (value != null) result.value = value;
    return result;
  }

  EnergyRegisterResponse._();

  factory EnergyRegisterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnergyRegisterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnergyRegisterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'description')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnergyRegisterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnergyRegisterResponse copyWith(
          void Function(EnergyRegisterResponse) updates) =>
      super.copyWith((message) => updates(message as EnergyRegisterResponse))
          as EnergyRegisterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnergyRegisterResponse create() => EnergyRegisterResponse._();
  @$core.override
  EnergyRegisterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnergyRegisterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnergyRegisterResponse>(create);
  static EnergyRegisterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get description => $_getSZ(0);
  @$pb.TagNumber(1)
  set description($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescription() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescription() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

/// New list-based response
class EnergyRegisterList extends $pb.GeneratedMessage {
  factory EnergyRegisterList({
    $core.Iterable<EnergyRegisterResponse>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  EnergyRegisterList._();

  factory EnergyRegisterList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnergyRegisterList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnergyRegisterList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<EnergyRegisterResponse>(1, _omitFieldNames ? '' : 'items',
        subBuilder: EnergyRegisterResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnergyRegisterList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnergyRegisterList copyWith(void Function(EnergyRegisterList) updates) =>
      super.copyWith((message) => updates(message as EnergyRegisterList))
          as EnergyRegisterList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnergyRegisterList create() => EnergyRegisterList._();
  @$core.override
  EnergyRegisterList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnergyRegisterList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnergyRegisterList>(create);
  static EnergyRegisterList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<EnergyRegisterResponse> get items => $_getList(0);
}

/// ==========================
/// Average (NEW)
/// ==========================
class AverageResponse extends $pb.GeneratedMessage {
  factory AverageResponse({
    $core.String? description,
    $core.String? value,
  }) {
    final result = create();
    if (description != null) result.description = description;
    if (value != null) result.value = value;
    return result;
  }

  AverageResponse._();

  factory AverageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AverageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AverageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'description')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AverageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AverageResponse copyWith(void Function(AverageResponse) updates) =>
      super.copyWith((message) => updates(message as AverageResponse))
          as AverageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AverageResponse create() => AverageResponse._();
  @$core.override
  AverageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AverageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AverageResponse>(create);
  static AverageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get description => $_getSZ(0);
  @$pb.TagNumber(1)
  set description($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescription() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescription() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class AverageList extends $pb.GeneratedMessage {
  factory AverageList({
    $core.Iterable<AverageResponse>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  AverageList._();

  factory AverageList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AverageList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AverageList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<AverageResponse>(1, _omitFieldNames ? '' : 'items',
        subBuilder: AverageResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AverageList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AverageList copyWith(void Function(AverageList) updates) =>
      super.copyWith((message) => updates(message as AverageList))
          as AverageList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AverageList create() => AverageList._();
  @$core.override
  AverageList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AverageList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AverageList>(create);
  static AverageList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AverageResponse> get items => $_getList(0);
}

class LoadProfilePartialRead extends $pb.GeneratedMessage {
  factory LoadProfilePartialRead({
    $2.Timestamp? datetime,
    $core.String? deviationHex,
    $core.String? status,
  }) {
    final result = create();
    if (datetime != null) result.datetime = datetime;
    if (deviationHex != null) result.deviationHex = deviationHex;
    if (status != null) result.status = status;
    return result;
  }

  LoadProfilePartialRead._();

  factory LoadProfilePartialRead.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadProfilePartialRead.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadProfilePartialRead',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<$2.Timestamp>(1, _omitFieldNames ? '' : 'datetime',
        subBuilder: $2.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'deviationHex')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadProfilePartialRead clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadProfilePartialRead copyWith(
          void Function(LoadProfilePartialRead) updates) =>
      super.copyWith((message) => updates(message as LoadProfilePartialRead))
          as LoadProfilePartialRead;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadProfilePartialRead create() => LoadProfilePartialRead._();
  @$core.override
  LoadProfilePartialRead createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadProfilePartialRead getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadProfilePartialRead>(create);
  static LoadProfilePartialRead? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Timestamp get datetime => $_getN(0);
  @$pb.TagNumber(1)
  set datetime($2.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDatetime() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatetime() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Timestamp ensureDatetime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get deviationHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviationHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviationHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviationHex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);
}

/// Request: takes the DLMS/COSEM object name (e.g., "profileGeneric_1" or OBIS-linked name)
class GetLoadProfileRequest extends $pb.GeneratedMessage {
  factory GetLoadProfileRequest({
    $core.String? objectName,
    LoadProfilePartialRead? start,
    LoadProfilePartialRead? end,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (objectName != null) result.objectName = objectName;
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetLoadProfileRequest._();

  factory GetLoadProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLoadProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLoadProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectName', protoName: 'objectName')
    ..aOM<LoadProfilePartialRead>(2, _omitFieldNames ? '' : 'start',
        subBuilder: LoadProfilePartialRead.create)
    ..aOM<LoadProfilePartialRead>(3, _omitFieldNames ? '' : 'end',
        subBuilder: LoadProfilePartialRead.create)
    ..aI(10, _omitFieldNames ? '' : 'page')
    ..aI(11, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileRequest copyWith(
          void Function(GetLoadProfileRequest) updates) =>
      super.copyWith((message) => updates(message as GetLoadProfileRequest))
          as GetLoadProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLoadProfileRequest create() => GetLoadProfileRequest._();
  @$core.override
  GetLoadProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLoadProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLoadProfileRequest>(create);
  static GetLoadProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectName => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectName() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectName() => $_clearField(1);

  @$pb.TagNumber(2)
  LoadProfilePartialRead get start => $_getN(1);
  @$pb.TagNumber(2)
  set start(LoadProfilePartialRead value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearStart() => $_clearField(2);
  @$pb.TagNumber(2)
  LoadProfilePartialRead ensureStart() => $_ensure(1);

  @$pb.TagNumber(3)
  LoadProfilePartialRead get end => $_getN(2);
  @$pb.TagNumber(3)
  set end(LoadProfilePartialRead value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEnd() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnd() => $_clearField(3);
  @$pb.TagNumber(3)
  LoadProfilePartialRead ensureEnd() => $_ensure(2);

  @$pb.TagNumber(10)
  $core.int get page => $_getIZ(3);
  @$pb.TagNumber(10)
  set page($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(10)
  $core.bool hasPage() => $_has(3);
  @$pb.TagNumber(10)
  void clearPage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(11)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(11)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(11)
  void clearPageSize() => $_clearField(11);
}

/// Response:
/// - headerTypes: list of header/type names describing each column
/// - values: rows of string values; each row is a StringList (list of strings)
///   Example:
///     headerTypes = ["timestamp", "activeEnergy", "reactiveEnergy"]
///     values[0].items = ["2025-12-25T10:00:00Z", "1234.56", "78.90"]
class GetLoadProfileResponse extends $pb.GeneratedMessage {
  factory GetLoadProfileResponse({
    $core.Iterable<$core.String>? headerTypes,
    $core.Iterable<StringList>? values,
    $core.int? totalEntries,
    $core.int? currentPage,
    $core.int? totalPages,
  }) {
    final result = create();
    if (headerTypes != null) result.headerTypes.addAll(headerTypes);
    if (values != null) result.values.addAll(values);
    if (totalEntries != null) result.totalEntries = totalEntries;
    if (currentPage != null) result.currentPage = currentPage;
    if (totalPages != null) result.totalPages = totalPages;
    return result;
  }

  GetLoadProfileResponse._();

  factory GetLoadProfileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLoadProfileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLoadProfileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'headerTypes', protoName: 'headerTypes')
    ..pPM<StringList>(2, _omitFieldNames ? '' : 'values',
        subBuilder: StringList.create)
    ..aI(10, _omitFieldNames ? '' : 'totalEntries')
    ..aI(11, _omitFieldNames ? '' : 'currentPage')
    ..aI(12, _omitFieldNames ? '' : 'totalPages')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileResponse copyWith(
          void Function(GetLoadProfileResponse) updates) =>
      super.copyWith((message) => updates(message as GetLoadProfileResponse))
          as GetLoadProfileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLoadProfileResponse create() => GetLoadProfileResponse._();
  @$core.override
  GetLoadProfileResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLoadProfileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLoadProfileResponse>(create);
  static GetLoadProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get headerTypes => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<StringList> get values => $_getList(1);

  @$pb.TagNumber(10)
  $core.int get totalEntries => $_getIZ(2);
  @$pb.TagNumber(10)
  set totalEntries($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(10)
  $core.bool hasTotalEntries() => $_has(2);
  @$pb.TagNumber(10)
  void clearTotalEntries() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get currentPage => $_getIZ(3);
  @$pb.TagNumber(11)
  set currentPage($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(11)
  $core.bool hasCurrentPage() => $_has(3);
  @$pb.TagNumber(11)
  void clearCurrentPage() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get totalPages => $_getIZ(4);
  @$pb.TagNumber(12)
  set totalPages($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(12)
  $core.bool hasTotalPages() => $_has(4);
  @$pb.TagNumber(12)
  void clearTotalPages() => $_clearField(12);
}

/// Identify which profile-generic object (by name) and which parameter.
class GetLoadProfileParamRequest extends $pb.GeneratedMessage {
  factory GetLoadProfileParamRequest({
    $core.String? objectName,
    LoadProfileParam? param,
  }) {
    final result = create();
    if (objectName != null) result.objectName = objectName;
    if (param != null) result.param = param;
    return result;
  }

  GetLoadProfileParamRequest._();

  factory GetLoadProfileParamRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLoadProfileParamRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLoadProfileParamRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectName', protoName: 'objectName')
    ..aE<LoadProfileParam>(2, _omitFieldNames ? '' : 'param',
        enumValues: LoadProfileParam.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileParamRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLoadProfileParamRequest copyWith(
          void Function(GetLoadProfileParamRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetLoadProfileParamRequest))
          as GetLoadProfileParamRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLoadProfileParamRequest create() => GetLoadProfileParamRequest._();
  @$core.override
  GetLoadProfileParamRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLoadProfileParamRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLoadProfileParamRequest>(create);
  static GetLoadProfileParamRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectName => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectName() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectName() => $_clearField(1);

  @$pb.TagNumber(2)
  LoadProfileParam get param => $_getN(1);
  @$pb.TagNumber(2)
  set param(LoadProfileParam value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasParam() => $_has(1);
  @$pb.TagNumber(2)
  void clearParam() => $_clearField(2);
}

/// Set a single parameter to an int32 value.
class SetLoadProfileParamRequest extends $pb.GeneratedMessage {
  factory SetLoadProfileParamRequest({
    $core.String? objectName,
    LoadProfileParam? param,
    $core.int? value,
  }) {
    final result = create();
    if (objectName != null) result.objectName = objectName;
    if (param != null) result.param = param;
    if (value != null) result.value = value;
    return result;
  }

  SetLoadProfileParamRequest._();

  factory SetLoadProfileParamRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetLoadProfileParamRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetLoadProfileParamRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectName', protoName: 'objectName')
    ..aE<LoadProfileParam>(2, _omitFieldNames ? '' : 'param',
        enumValues: LoadProfileParam.values)
    ..aI(3, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetLoadProfileParamRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetLoadProfileParamRequest copyWith(
          void Function(SetLoadProfileParamRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetLoadProfileParamRequest))
          as SetLoadProfileParamRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetLoadProfileParamRequest create() => SetLoadProfileParamRequest._();
  @$core.override
  SetLoadProfileParamRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetLoadProfileParamRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetLoadProfileParamRequest>(create);
  static SetLoadProfileParamRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectName => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectName() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectName() => $_clearField(1);

  @$pb.TagNumber(2)
  LoadProfileParam get param => $_getN(1);
  @$pb.TagNumber(2)
  set param(LoadProfileParam value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasParam() => $_has(1);
  @$pb.TagNumber(2)
  void clearParam() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get value => $_getIZ(2);
  @$pb.TagNumber(3)
  set value($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);
}

class BitStatusRequest extends $pb.GeneratedMessage {
  factory BitStatusRequest({
    $core.String? dataSource,
    $core.String? descriptionJson,
  }) {
    final result = create();
    if (dataSource != null) result.dataSource = dataSource;
    if (descriptionJson != null) result.descriptionJson = descriptionJson;
    return result;
  }

  BitStatusRequest._();

  factory BitStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BitStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BitStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataSource', protoName: 'dataSource')
    ..aOS(2, _omitFieldNames ? '' : 'descriptionJson',
        protoName: 'descriptionJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatusRequest copyWith(void Function(BitStatusRequest) updates) =>
      super.copyWith((message) => updates(message as BitStatusRequest))
          as BitStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BitStatusRequest create() => BitStatusRequest._();
  @$core.override
  BitStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BitStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BitStatusRequest>(create);
  static BitStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataSource => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataSource($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataSource() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get descriptionJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set descriptionJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescriptionJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescriptionJson() => $_clearField(2);
}

class BitStatus extends $pb.GeneratedMessage {
  factory BitStatus({
    $core.String? mask,
    $core.String? bitValue,
    $core.String? description,
    $core.bool? isActive,
  }) {
    final result = create();
    if (mask != null) result.mask = mask;
    if (bitValue != null) result.bitValue = bitValue;
    if (description != null) result.description = description;
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  BitStatus._();

  factory BitStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BitStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BitStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mask')
    ..aOS(2, _omitFieldNames ? '' : 'bitValue', protoName: 'bitValue')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOB(4, _omitFieldNames ? '' : 'isActive', protoName: 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatus copyWith(void Function(BitStatus) updates) =>
      super.copyWith((message) => updates(message as BitStatus)) as BitStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BitStatus create() => BitStatus._();
  @$core.override
  BitStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BitStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BitStatus>(create);
  static BitStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mask => $_getSZ(0);
  @$pb.TagNumber(1)
  set mask($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMask() => $_has(0);
  @$pb.TagNumber(1)
  void clearMask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get bitValue => $_getSZ(1);
  @$pb.TagNumber(2)
  set bitValue($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBitValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearBitValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isActive => $_getBF(3);
  @$pb.TagNumber(4)
  set isActive($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsActive() => $_clearField(4);
}

class BitStatusResponse extends $pb.GeneratedMessage {
  factory BitStatusResponse({
    $core.Iterable<BitStatus>? bits,
  }) {
    final result = create();
    if (bits != null) result.bits.addAll(bits);
    return result;
  }

  BitStatusResponse._();

  factory BitStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BitStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BitStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<BitStatus>(1, _omitFieldNames ? '' : 'bits',
        subBuilder: BitStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitStatusResponse copyWith(void Function(BitStatusResponse) updates) =>
      super.copyWith((message) => updates(message as BitStatusResponse))
          as BitStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BitStatusResponse create() => BitStatusResponse._();
  @$core.override
  BitStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BitStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BitStatusResponse>(create);
  static BitStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BitStatus> get bits => $_getList(0);
}

/// Group 1 – Modem Config
class ModemConfigResponse extends $pb.GeneratedMessage {
  factory ModemConfigResponse({
    $core.String? apn,
    $core.int? pinCode,
    $core.String? pppUsername,
    $core.String? pppPassword,
  }) {
    final result = create();
    if (apn != null) result.apn = apn;
    if (pinCode != null) result.pinCode = pinCode;
    if (pppUsername != null) result.pppUsername = pppUsername;
    if (pppPassword != null) result.pppPassword = pppPassword;
    return result;
  }

  ModemConfigResponse._();

  factory ModemConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModemConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModemConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'apn')
    ..aI(2, _omitFieldNames ? '' : 'pinCode', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'pppUsername')
    ..aOS(4, _omitFieldNames ? '' : 'pppPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemConfigResponse copyWith(void Function(ModemConfigResponse) updates) =>
      super.copyWith((message) => updates(message as ModemConfigResponse))
          as ModemConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModemConfigResponse create() => ModemConfigResponse._();
  @$core.override
  ModemConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModemConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModemConfigResponse>(create);
  static ModemConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get apn => $_getSZ(0);
  @$pb.TagNumber(1)
  set apn($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasApn() => $_has(0);
  @$pb.TagNumber(1)
  void clearApn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pinCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set pinCode($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPinCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearPinCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pppUsername => $_getSZ(2);
  @$pb.TagNumber(3)
  set pppUsername($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPppUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearPppUsername() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pppPassword => $_getSZ(3);
  @$pb.TagNumber(4)
  set pppPassword($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPppPassword() => $_has(3);
  @$pb.TagNumber(4)
  void clearPppPassword() => $_clearField(4);
}

class SetApnRequest extends $pb.GeneratedMessage {
  factory SetApnRequest({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  SetApnRequest._();

  factory SetApnRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetApnRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetApnRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetApnRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetApnRequest copyWith(void Function(SetApnRequest) updates) =>
      super.copyWith((message) => updates(message as SetApnRequest))
          as SetApnRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetApnRequest create() => SetApnRequest._();
  @$core.override
  SetApnRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetApnRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetApnRequest>(create);
  static SetApnRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class SetPinCodeRequest extends $pb.GeneratedMessage {
  factory SetPinCodeRequest({
    $core.int? pinCode,
  }) {
    final result = create();
    if (pinCode != null) result.pinCode = pinCode;
    return result;
  }

  SetPinCodeRequest._();

  factory SetPinCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPinCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPinCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pinCode', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPinCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPinCodeRequest copyWith(void Function(SetPinCodeRequest) updates) =>
      super.copyWith((message) => updates(message as SetPinCodeRequest))
          as SetPinCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPinCodeRequest create() => SetPinCodeRequest._();
  @$core.override
  SetPinCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPinCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPinCodeRequest>(create);
  static SetPinCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pinCode => $_getIZ(0);
  @$pb.TagNumber(1)
  set pinCode($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPinCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearPinCode() => $_clearField(1);
}

class SetPppAuthRequest extends $pb.GeneratedMessage {
  factory SetPppAuthRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    return result;
  }

  SetPppAuthRequest._();

  factory SetPppAuthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPppAuthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPppAuthRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPppAuthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPppAuthRequest copyWith(void Function(SetPppAuthRequest) updates) =>
      super.copyWith((message) => updates(message as SetPppAuthRequest))
          as SetPppAuthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPppAuthRequest create() => SetPppAuthRequest._();
  @$core.override
  SetPppAuthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPppAuthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPppAuthRequest>(create);
  static SetPppAuthRequest? _defaultInstance;

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

/// Group 2 – IP Address
class IpAddressResponse extends $pb.GeneratedMessage {
  factory IpAddressResponse({
    $core.bool? isIpv6,
    $core.String? address,
  }) {
    final result = create();
    if (isIpv6 != null) result.isIpv6 = isIpv6;
    if (address != null) result.address = address;
    return result;
  }

  IpAddressResponse._();

  factory IpAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IpAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IpAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isIpv6')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IpAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IpAddressResponse copyWith(void Function(IpAddressResponse) updates) =>
      super.copyWith((message) => updates(message as IpAddressResponse))
          as IpAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IpAddressResponse create() => IpAddressResponse._();
  @$core.override
  IpAddressResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IpAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IpAddressResponse>(create);
  static IpAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isIpv6 => $_getBF(0);
  @$pb.TagNumber(1)
  set isIpv6($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsIpv6() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsIpv6() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);
}

class SetIpAddressRequest extends $pb.GeneratedMessage {
  factory SetIpAddressRequest({
    $core.String? address,
    $core.bool? isIpv6,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (isIpv6 != null) result.isIpv6 = isIpv6;
    return result;
  }

  SetIpAddressRequest._();

  factory SetIpAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetIpAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetIpAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOB(2, _omitFieldNames ? '' : 'isIpv6')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetIpAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetIpAddressRequest copyWith(void Function(SetIpAddressRequest) updates) =>
      super.copyWith((message) => updates(message as SetIpAddressRequest))
          as SetIpAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetIpAddressRequest create() => SetIpAddressRequest._();
  @$core.override
  SetIpAddressRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetIpAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetIpAddressRequest>(create);
  static SetIpAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isIpv6 => $_getBF(1);
  @$pb.TagNumber(2)
  set isIpv6($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsIpv6() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsIpv6() => $_clearField(2);
}

/// Group 3 – Cellular Diagnostics
class CellularDiagResponse extends $pb.GeneratedMessage {
  factory CellularDiagResponse({
    $core.String? operatorName,
    $core.int? status,
    $core.int? csAttachment,
    $core.int? psStatus,
    $core.bool? showCellInfo,
    $core.bool? showQos,
    $core.bool? isLteMode,
  }) {
    final result = create();
    if (operatorName != null) result.operatorName = operatorName;
    if (status != null) result.status = status;
    if (csAttachment != null) result.csAttachment = csAttachment;
    if (psStatus != null) result.psStatus = psStatus;
    if (showCellInfo != null) result.showCellInfo = showCellInfo;
    if (showQos != null) result.showQos = showQos;
    if (isLteMode != null) result.isLteMode = isLteMode;
    return result;
  }

  CellularDiagResponse._();

  factory CellularDiagResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CellularDiagResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CellularDiagResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'operatorName')
    ..aI(2, _omitFieldNames ? '' : 'status', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'csAttachment',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'psStatus', fieldType: $pb.PbFieldType.OU3)
    ..aOB(5, _omitFieldNames ? '' : 'showCellInfo')
    ..aOB(6, _omitFieldNames ? '' : 'showQos')
    ..aOB(7, _omitFieldNames ? '' : 'isLteMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellularDiagResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellularDiagResponse copyWith(void Function(CellularDiagResponse) updates) =>
      super.copyWith((message) => updates(message as CellularDiagResponse))
          as CellularDiagResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CellularDiagResponse create() => CellularDiagResponse._();
  @$core.override
  CellularDiagResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CellularDiagResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CellularDiagResponse>(create);
  static CellularDiagResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get operatorName => $_getSZ(0);
  @$pb.TagNumber(1)
  set operatorName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOperatorName() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperatorName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get status => $_getIZ(1);
  @$pb.TagNumber(2)
  set status($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get csAttachment => $_getIZ(2);
  @$pb.TagNumber(3)
  set csAttachment($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCsAttachment() => $_has(2);
  @$pb.TagNumber(3)
  void clearCsAttachment() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get psStatus => $_getIZ(3);
  @$pb.TagNumber(4)
  set psStatus($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPsStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearPsStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get showCellInfo => $_getBF(4);
  @$pb.TagNumber(5)
  set showCellInfo($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShowCellInfo() => $_has(4);
  @$pb.TagNumber(5)
  void clearShowCellInfo() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get showQos => $_getBF(5);
  @$pb.TagNumber(6)
  set showQos($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasShowQos() => $_has(5);
  @$pb.TagNumber(6)
  void clearShowQos() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isLteMode => $_getBF(6);
  @$pb.TagNumber(7)
  set isLteMode($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsLteMode() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsLteMode() => $_clearField(7);
}

class SetCellularFieldRequest extends $pb.GeneratedMessage {
  factory SetCellularFieldRequest({
    $core.int? attribute,
    $core.String? stringValue,
    $core.int? enumValue,
  }) {
    final result = create();
    if (attribute != null) result.attribute = attribute;
    if (stringValue != null) result.stringValue = stringValue;
    if (enumValue != null) result.enumValue = enumValue;
    return result;
  }

  SetCellularFieldRequest._();

  factory SetCellularFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCellularFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCellularFieldRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'attribute')
    ..aOS(2, _omitFieldNames ? '' : 'stringValue')
    ..aI(3, _omitFieldNames ? '' : 'enumValue', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCellularFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCellularFieldRequest copyWith(
          void Function(SetCellularFieldRequest) updates) =>
      super.copyWith((message) => updates(message as SetCellularFieldRequest))
          as SetCellularFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCellularFieldRequest create() => SetCellularFieldRequest._();
  @$core.override
  SetCellularFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCellularFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCellularFieldRequest>(create);
  static SetCellularFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get attribute => $_getIZ(0);
  @$pb.TagNumber(1)
  set attribute($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttribute() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttribute() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get stringValue => $_getSZ(1);
  @$pb.TagNumber(2)
  set stringValue($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStringValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearStringValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get enumValue => $_getIZ(2);
  @$pb.TagNumber(3)
  set enumValue($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnumValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnumValue() => $_clearField(3);
}

/// Group 4 – Cell Info
class CellInfoEntry extends $pb.GeneratedMessage {
  factory CellInfoEntry({
    $core.String? name,
    $core.String? value,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  CellInfoEntry._();

  factory CellInfoEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CellInfoEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CellInfoEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellInfoEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellInfoEntry copyWith(void Function(CellInfoEntry) updates) =>
      super.copyWith((message) => updates(message as CellInfoEntry))
          as CellInfoEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CellInfoEntry create() => CellInfoEntry._();
  @$core.override
  CellInfoEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CellInfoEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CellInfoEntry>(create);
  static CellInfoEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class CellInfoResponse extends $pb.GeneratedMessage {
  factory CellInfoResponse({
    $core.Iterable<CellInfoEntry>? entries,
    $core.bool? isLte,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (isLte != null) result.isLte = isLte;
    return result;
  }

  CellInfoResponse._();

  factory CellInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CellInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CellInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<CellInfoEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: CellInfoEntry.create)
    ..aOB(2, _omitFieldNames ? '' : 'isLte')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CellInfoResponse copyWith(void Function(CellInfoResponse) updates) =>
      super.copyWith((message) => updates(message as CellInfoResponse))
          as CellInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CellInfoResponse create() => CellInfoResponse._();
  @$core.override
  CellInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CellInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CellInfoResponse>(create);
  static CellInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CellInfoEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get isLte => $_getBF(1);
  @$pb.TagNumber(2)
  set isLte($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsLte() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsLte() => $_clearField(2);
}

class SetCellInfoEntryRequest extends $pb.GeneratedMessage {
  factory SetCellInfoEntryRequest({
    $core.int? entryIndex,
    $core.String? value,
    $core.bool? isLte,
  }) {
    final result = create();
    if (entryIndex != null) result.entryIndex = entryIndex;
    if (value != null) result.value = value;
    if (isLte != null) result.isLte = isLte;
    return result;
  }

  SetCellInfoEntryRequest._();

  factory SetCellInfoEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCellInfoEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCellInfoEntryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'entryIndex')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aOB(3, _omitFieldNames ? '' : 'isLte')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCellInfoEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCellInfoEntryRequest copyWith(
          void Function(SetCellInfoEntryRequest) updates) =>
      super.copyWith((message) => updates(message as SetCellInfoEntryRequest))
          as SetCellInfoEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCellInfoEntryRequest create() => SetCellInfoEntryRequest._();
  @$core.override
  SetCellInfoEntryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCellInfoEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCellInfoEntryRequest>(create);
  static SetCellInfoEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isLte => $_getBF(2);
  @$pb.TagNumber(3)
  set isLte($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsLte() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsLte() => $_clearField(3);
}

/// Group 5 – Quality of Service
class QosEntry extends $pb.GeneratedMessage {
  factory QosEntry({
    $core.int? precedence,
    $core.int? delay,
    $core.int? reliability,
    $core.int? peakThroughput,
    $core.int? meanThroughput,
  }) {
    final result = create();
    if (precedence != null) result.precedence = precedence;
    if (delay != null) result.delay = delay;
    if (reliability != null) result.reliability = reliability;
    if (peakThroughput != null) result.peakThroughput = peakThroughput;
    if (meanThroughput != null) result.meanThroughput = meanThroughput;
    return result;
  }

  QosEntry._();

  factory QosEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QosEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QosEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'precedence', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'delay', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'reliability',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'peakThroughput',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'meanThroughput',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QosEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QosEntry copyWith(void Function(QosEntry) updates) =>
      super.copyWith((message) => updates(message as QosEntry)) as QosEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QosEntry create() => QosEntry._();
  @$core.override
  QosEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QosEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QosEntry>(create);
  static QosEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get precedence => $_getIZ(0);
  @$pb.TagNumber(1)
  set precedence($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrecedence() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrecedence() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get delay => $_getIZ(1);
  @$pb.TagNumber(2)
  set delay($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDelay() => $_has(1);
  @$pb.TagNumber(2)
  void clearDelay() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get reliability => $_getIZ(2);
  @$pb.TagNumber(3)
  set reliability($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReliability() => $_has(2);
  @$pb.TagNumber(3)
  void clearReliability() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get peakThroughput => $_getIZ(3);
  @$pb.TagNumber(4)
  set peakThroughput($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPeakThroughput() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeakThroughput() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get meanThroughput => $_getIZ(4);
  @$pb.TagNumber(5)
  set meanThroughput($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMeanThroughput() => $_has(4);
  @$pb.TagNumber(5)
  void clearMeanThroughput() => $_clearField(5);
}

class GetQosResponse extends $pb.GeneratedMessage {
  factory GetQosResponse({
    $core.Iterable<QosEntry>? profiles,
  }) {
    final result = create();
    if (profiles != null) result.profiles.addAll(profiles);
    return result;
  }

  GetQosResponse._();

  factory GetQosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<QosEntry>(1, _omitFieldNames ? '' : 'profiles',
        subBuilder: QosEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQosResponse copyWith(void Function(GetQosResponse) updates) =>
      super.copyWith((message) => updates(message as GetQosResponse))
          as GetQosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQosResponse create() => GetQosResponse._();
  @$core.override
  GetQosResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetQosResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQosResponse>(create);
  static GetQosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<QosEntry> get profiles => $_getList(0);
}

class SetQosRequest extends $pb.GeneratedMessage {
  factory SetQosRequest({
    QosEntry? profile,
    $core.int? profileIndex,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    if (profileIndex != null) result.profileIndex = profileIndex;
    return result;
  }

  SetQosRequest._();

  factory SetQosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetQosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetQosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<QosEntry>(1, _omitFieldNames ? '' : 'profile',
        subBuilder: QosEntry.create)
    ..aI(2, _omitFieldNames ? '' : 'profileIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetQosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetQosRequest copyWith(void Function(SetQosRequest) updates) =>
      super.copyWith((message) => updates(message as SetQosRequest))
          as SetQosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetQosRequest create() => SetQosRequest._();
  @$core.override
  SetQosRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetQosRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetQosRequest>(create);
  static SetQosRequest? _defaultInstance;

  @$pb.TagNumber(1)
  QosEntry get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(QosEntry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  QosEntry ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get profileIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set profileIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProfileIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileIndex() => $_clearField(2);
}

class MobileNetworkIdentifiersResponse extends $pb.GeneratedMessage {
  factory MobileNetworkIdentifiersResponse({
    $core.String? imsi,
    $core.String? msisdn,
    $core.String? imei,
    $core.String? iccid,
  }) {
    final result = create();
    if (imsi != null) result.imsi = imsi;
    if (msisdn != null) result.msisdn = msisdn;
    if (imei != null) result.imei = imei;
    if (iccid != null) result.iccid = iccid;
    return result;
  }

  MobileNetworkIdentifiersResponse._();

  factory MobileNetworkIdentifiersResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MobileNetworkIdentifiersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MobileNetworkIdentifiersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'imsi')
    ..aOS(2, _omitFieldNames ? '' : 'msisdn')
    ..aOS(3, _omitFieldNames ? '' : 'imei')
    ..aOS(4, _omitFieldNames ? '' : 'iccid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MobileNetworkIdentifiersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MobileNetworkIdentifiersResponse copyWith(
          void Function(MobileNetworkIdentifiersResponse) updates) =>
      super.copyWith(
              (message) => updates(message as MobileNetworkIdentifiersResponse))
          as MobileNetworkIdentifiersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MobileNetworkIdentifiersResponse create() =>
      MobileNetworkIdentifiersResponse._();
  @$core.override
  MobileNetworkIdentifiersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MobileNetworkIdentifiersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MobileNetworkIdentifiersResponse>(
          create);
  static MobileNetworkIdentifiersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get imsi => $_getSZ(0);
  @$pb.TagNumber(1)
  set imsi($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImsi() => $_has(0);
  @$pb.TagNumber(1)
  void clearImsi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msisdn => $_getSZ(1);
  @$pb.TagNumber(2)
  set msisdn($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsisdn() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsisdn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get imei => $_getSZ(2);
  @$pb.TagNumber(3)
  set imei($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImei() => $_has(2);
  @$pb.TagNumber(3)
  void clearImei() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get iccid => $_getSZ(3);
  @$pb.TagNumber(4)
  set iccid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIccid() => $_has(3);
  @$pb.TagNumber(4)
  void clearIccid() => $_clearField(4);
}

/// Single request type reused for all four SET operations
class SetMniFieldRequest extends $pb.GeneratedMessage {
  factory SetMniFieldRequest({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  SetMniFieldRequest._();

  factory SetMniFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMniFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMniFieldRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMniFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMniFieldRequest copyWith(void Function(SetMniFieldRequest) updates) =>
      super.copyWith((message) => updates(message as SetMniFieldRequest))
          as SetMniFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMniFieldRequest create() => SetMniFieldRequest._();
  @$core.override
  SetMniFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetMniFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMniFieldRequest>(create);
  static SetMniFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class ModemStatusResponse extends $pb.GeneratedMessage {
  factory ModemStatusResponse({
    $core.bool? isActive,
  }) {
    final result = create();
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  ModemStatusResponse._();

  factory ModemStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModemStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModemStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemStatusResponse copyWith(void Function(ModemStatusResponse) updates) =>
      super.copyWith((message) => updates(message as ModemStatusResponse))
          as ModemStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModemStatusResponse create() => ModemStatusResponse._();
  @$core.override
  ModemStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModemStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModemStatusResponse>(create);
  static ModemStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isActive => $_getBF(0);
  @$pb.TagNumber(1)
  set isActive($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsActive() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsActive() => $_clearField(1);
}

class MniRightsResponse extends $pb.GeneratedMessage {
  factory MniRightsResponse({
    $core.bool? imsiGet,
    $core.bool? imsiSet,
    $core.bool? msisdnGet,
    $core.bool? msisdnSet,
    $core.bool? imeiGet,
    $core.bool? imeiSet,
    $core.bool? iccidGet,
    $core.bool? iccidSet,
    $core.bool? modemGet,
    $core.bool? modemSet,
  }) {
    final result = create();
    if (imsiGet != null) result.imsiGet = imsiGet;
    if (imsiSet != null) result.imsiSet = imsiSet;
    if (msisdnGet != null) result.msisdnGet = msisdnGet;
    if (msisdnSet != null) result.msisdnSet = msisdnSet;
    if (imeiGet != null) result.imeiGet = imeiGet;
    if (imeiSet != null) result.imeiSet = imeiSet;
    if (iccidGet != null) result.iccidGet = iccidGet;
    if (iccidSet != null) result.iccidSet = iccidSet;
    if (modemGet != null) result.modemGet = modemGet;
    if (modemSet != null) result.modemSet = modemSet;
    return result;
  }

  MniRightsResponse._();

  factory MniRightsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MniRightsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MniRightsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'imsiGet')
    ..aOB(2, _omitFieldNames ? '' : 'imsiSet')
    ..aOB(3, _omitFieldNames ? '' : 'msisdnGet')
    ..aOB(4, _omitFieldNames ? '' : 'msisdnSet')
    ..aOB(5, _omitFieldNames ? '' : 'imeiGet')
    ..aOB(6, _omitFieldNames ? '' : 'imeiSet')
    ..aOB(7, _omitFieldNames ? '' : 'iccidGet')
    ..aOB(8, _omitFieldNames ? '' : 'iccidSet')
    ..aOB(9, _omitFieldNames ? '' : 'modemGet')
    ..aOB(10, _omitFieldNames ? '' : 'modemSet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MniRightsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MniRightsResponse copyWith(void Function(MniRightsResponse) updates) =>
      super.copyWith((message) => updates(message as MniRightsResponse))
          as MniRightsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MniRightsResponse create() => MniRightsResponse._();
  @$core.override
  MniRightsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MniRightsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MniRightsResponse>(create);
  static MniRightsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get imsiGet => $_getBF(0);
  @$pb.TagNumber(1)
  set imsiGet($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImsiGet() => $_has(0);
  @$pb.TagNumber(1)
  void clearImsiGet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get imsiSet => $_getBF(1);
  @$pb.TagNumber(2)
  set imsiSet($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImsiSet() => $_has(1);
  @$pb.TagNumber(2)
  void clearImsiSet() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get msisdnGet => $_getBF(2);
  @$pb.TagNumber(3)
  set msisdnGet($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMsisdnGet() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsisdnGet() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get msisdnSet => $_getBF(3);
  @$pb.TagNumber(4)
  set msisdnSet($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMsisdnSet() => $_has(3);
  @$pb.TagNumber(4)
  void clearMsisdnSet() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get imeiGet => $_getBF(4);
  @$pb.TagNumber(5)
  set imeiGet($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasImeiGet() => $_has(4);
  @$pb.TagNumber(5)
  void clearImeiGet() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get imeiSet => $_getBF(5);
  @$pb.TagNumber(6)
  set imeiSet($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImeiSet() => $_has(5);
  @$pb.TagNumber(6)
  void clearImeiSet() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get iccidGet => $_getBF(6);
  @$pb.TagNumber(7)
  set iccidGet($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIccidGet() => $_has(6);
  @$pb.TagNumber(7)
  void clearIccidGet() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get iccidSet => $_getBF(7);
  @$pb.TagNumber(8)
  set iccidSet($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIccidSet() => $_has(7);
  @$pb.TagNumber(8)
  void clearIccidSet() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get modemGet => $_getBF(8);
  @$pb.TagNumber(9)
  set modemGet($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasModemGet() => $_has(8);
  @$pb.TagNumber(9)
  void clearModemGet() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get modemSet => $_getBF(9);
  @$pb.TagNumber(10)
  set modemSet($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasModemSet() => $_has(9);
  @$pb.TagNumber(10)
  void clearModemSet() => $_clearField(10);
}

/// Onglet 1 – Modem Configuration (Class 27)
class ModemInitStringEntry extends $pb.GeneratedMessage {
  factory ModemInitStringEntry({
    $core.String? request,
    $core.String? expected,
    $core.int? delayMs,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (expected != null) result.expected = expected;
    if (delayMs != null) result.delayMs = delayMs;
    return result;
  }

  ModemInitStringEntry._();

  factory ModemInitStringEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModemInitStringEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModemInitStringEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'request')
    ..aOS(2, _omitFieldNames ? '' : 'expected')
    ..aI(3, _omitFieldNames ? '' : 'delayMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemInitStringEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemInitStringEntry copyWith(void Function(ModemInitStringEntry) updates) =>
      super.copyWith((message) => updates(message as ModemInitStringEntry))
          as ModemInitStringEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModemInitStringEntry create() => ModemInitStringEntry._();
  @$core.override
  ModemInitStringEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModemInitStringEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModemInitStringEntry>(create);
  static ModemInitStringEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get request => $_getSZ(0);
  @$pb.TagNumber(1)
  set request($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequest() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get expected => $_getSZ(1);
  @$pb.TagNumber(2)
  set expected($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpected() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpected() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get delayMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set delayMs($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDelayMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelayMs() => $_clearField(3);
}

class ModemConfigSettingsResponse extends $pb.GeneratedMessage {
  factory ModemConfigSettingsResponse({
    $core.int? commSpeed,
    $core.String? modemProfile,
    $core.Iterable<ModemInitStringEntry>? initStrings,
    $core.bool? showInitString,
  }) {
    final result = create();
    if (commSpeed != null) result.commSpeed = commSpeed;
    if (modemProfile != null) result.modemProfile = modemProfile;
    if (initStrings != null) result.initStrings.addAll(initStrings);
    if (showInitString != null) result.showInitString = showInitString;
    return result;
  }

  ModemConfigSettingsResponse._();

  factory ModemConfigSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModemConfigSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModemConfigSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'commSpeed')
    ..aOS(2, _omitFieldNames ? '' : 'modemProfile')
    ..pPM<ModemInitStringEntry>(3, _omitFieldNames ? '' : 'initStrings',
        subBuilder: ModemInitStringEntry.create)
    ..aOB(4, _omitFieldNames ? '' : 'showInitString')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemConfigSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModemConfigSettingsResponse copyWith(
          void Function(ModemConfigSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ModemConfigSettingsResponse))
          as ModemConfigSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModemConfigSettingsResponse create() =>
      ModemConfigSettingsResponse._();
  @$core.override
  ModemConfigSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ModemConfigSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModemConfigSettingsResponse>(create);
  static ModemConfigSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get commSpeed => $_getIZ(0);
  @$pb.TagNumber(1)
  set commSpeed($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommSpeed() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommSpeed() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get modemProfile => $_getSZ(1);
  @$pb.TagNumber(2)
  set modemProfile($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModemProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearModemProfile() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ModemInitStringEntry> get initStrings => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get showInitString => $_getBF(3);
  @$pb.TagNumber(4)
  set showInitString($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShowInitString() => $_has(3);
  @$pb.TagNumber(4)
  void clearShowInitString() => $_clearField(4);
}

class SetCommSpeedRequest extends $pb.GeneratedMessage {
  factory SetCommSpeedRequest({
    $core.int? speedIndex,
  }) {
    final result = create();
    if (speedIndex != null) result.speedIndex = speedIndex;
    return result;
  }

  SetCommSpeedRequest._();

  factory SetCommSpeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCommSpeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCommSpeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'speedIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommSpeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCommSpeedRequest copyWith(void Function(SetCommSpeedRequest) updates) =>
      super.copyWith((message) => updates(message as SetCommSpeedRequest))
          as SetCommSpeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCommSpeedRequest create() => SetCommSpeedRequest._();
  @$core.override
  SetCommSpeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCommSpeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCommSpeedRequest>(create);
  static SetCommSpeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get speedIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set speedIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpeedIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpeedIndex() => $_clearField(1);
}

class SetModemProfileRequest extends $pb.GeneratedMessage {
  factory SetModemProfileRequest({
    $core.String? profile,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    return result;
  }

  SetModemProfileRequest._();

  factory SetModemProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetModemProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetModemProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'profile')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetModemProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetModemProfileRequest copyWith(
          void Function(SetModemProfileRequest) updates) =>
      super.copyWith((message) => updates(message as SetModemProfileRequest))
          as SetModemProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetModemProfileRequest create() => SetModemProfileRequest._();
  @$core.override
  SetModemProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetModemProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetModemProfileRequest>(create);
  static SetModemProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get profile => $_getSZ(0);
  @$pb.TagNumber(1)
  set profile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
}

class SetInitStringsRequest extends $pb.GeneratedMessage {
  factory SetInitStringsRequest({
    $core.Iterable<ModemInitStringEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  SetInitStringsRequest._();

  factory SetInitStringsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetInitStringsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetInitStringsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<ModemInitStringEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ModemInitStringEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetInitStringsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetInitStringsRequest copyWith(
          void Function(SetInitStringsRequest) updates) =>
      super.copyWith((message) => updates(message as SetInitStringsRequest))
          as SetInitStringsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetInitStringsRequest create() => SetInitStringsRequest._();
  @$core.override
  SetInitStringsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetInitStringsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetInitStringsRequest>(create);
  static SetInitStringsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ModemInitStringEntry> get entries => $_getList(0);
}

/// Onglet 2 – Auto Connect (Class 29)
class CallingWindowEntry extends $pb.GeneratedMessage {
  factory CallingWindowEntry({
    $core.String? startTime,
    $core.String? endTime,
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  CallingWindowEntry._();

  factory CallingWindowEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallingWindowEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallingWindowEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'startTime')
    ..aOS(2, _omitFieldNames ? '' : 'endTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallingWindowEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallingWindowEntry copyWith(void Function(CallingWindowEntry) updates) =>
      super.copyWith((message) => updates(message as CallingWindowEntry))
          as CallingWindowEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallingWindowEntry create() => CallingWindowEntry._();
  @$core.override
  CallingWindowEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallingWindowEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallingWindowEntry>(create);
  static CallingWindowEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get startTime => $_getSZ(0);
  @$pb.TagNumber(1)
  set startTime($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get endTime => $_getSZ(1);
  @$pb.TagNumber(2)
  set endTime($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEndTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndTime() => $_clearField(2);
}

class DestinationEntry extends $pb.GeneratedMessage {
  factory DestinationEntry({
    $core.String? ipAddress,
    $core.int? port,
  }) {
    final result = create();
    if (ipAddress != null) result.ipAddress = ipAddress;
    if (port != null) result.port = port;
    return result;
  }

  DestinationEntry._();

  factory DestinationEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DestinationEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DestinationEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ipAddress')
    ..aI(2, _omitFieldNames ? '' : 'port')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DestinationEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DestinationEntry copyWith(void Function(DestinationEntry) updates) =>
      super.copyWith((message) => updates(message as DestinationEntry))
          as DestinationEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DestinationEntry create() => DestinationEntry._();
  @$core.override
  DestinationEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DestinationEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DestinationEntry>(create);
  static DestinationEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ipAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set ipAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIpAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearIpAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);
}

class AutoConnectResponse extends $pb.GeneratedMessage {
  factory AutoConnectResponse({
    $core.int? mode,
    $core.int? repetitions,
    $core.int? repetitionDelay,
    $core.Iterable<CallingWindowEntry>? callingWindow,
    $core.Iterable<DestinationEntry>? destinationList,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (repetitions != null) result.repetitions = repetitions;
    if (repetitionDelay != null) result.repetitionDelay = repetitionDelay;
    if (callingWindow != null) result.callingWindow.addAll(callingWindow);
    if (destinationList != null) result.destinationList.addAll(destinationList);
    return result;
  }

  AutoConnectResponse._();

  factory AutoConnectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AutoConnectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutoConnectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'mode')
    ..aI(2, _omitFieldNames ? '' : 'repetitions')
    ..aI(3, _omitFieldNames ? '' : 'repetitionDelay')
    ..pPM<CallingWindowEntry>(4, _omitFieldNames ? '' : 'callingWindow',
        subBuilder: CallingWindowEntry.create)
    ..pPM<DestinationEntry>(5, _omitFieldNames ? '' : 'destinationList',
        subBuilder: DestinationEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoConnectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoConnectResponse copyWith(void Function(AutoConnectResponse) updates) =>
      super.copyWith((message) => updates(message as AutoConnectResponse))
          as AutoConnectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoConnectResponse create() => AutoConnectResponse._();
  @$core.override
  AutoConnectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AutoConnectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutoConnectResponse>(create);
  static AutoConnectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mode => $_getIZ(0);
  @$pb.TagNumber(1)
  set mode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get repetitions => $_getIZ(1);
  @$pb.TagNumber(2)
  set repetitions($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRepetitions() => $_has(1);
  @$pb.TagNumber(2)
  void clearRepetitions() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get repetitionDelay => $_getIZ(2);
  @$pb.TagNumber(3)
  set repetitionDelay($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRepetitionDelay() => $_has(2);
  @$pb.TagNumber(3)
  void clearRepetitionDelay() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<CallingWindowEntry> get callingWindow => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<DestinationEntry> get destinationList => $_getList(4);
}

class SetAutoConnectRequest extends $pb.GeneratedMessage {
  factory SetAutoConnectRequest({
    $core.int? mode,
    $core.int? repetitions,
    $core.int? repetitionDelay,
    $core.Iterable<CallingWindowEntry>? callingWindow,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (repetitions != null) result.repetitions = repetitions;
    if (repetitionDelay != null) result.repetitionDelay = repetitionDelay;
    if (callingWindow != null) result.callingWindow.addAll(callingWindow);
    return result;
  }

  SetAutoConnectRequest._();

  factory SetAutoConnectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAutoConnectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAutoConnectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'mode')
    ..aI(2, _omitFieldNames ? '' : 'repetitions')
    ..aI(3, _omitFieldNames ? '' : 'repetitionDelay')
    ..pPM<CallingWindowEntry>(4, _omitFieldNames ? '' : 'callingWindow',
        subBuilder: CallingWindowEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAutoConnectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAutoConnectRequest copyWith(
          void Function(SetAutoConnectRequest) updates) =>
      super.copyWith((message) => updates(message as SetAutoConnectRequest))
          as SetAutoConnectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAutoConnectRequest create() => SetAutoConnectRequest._();
  @$core.override
  SetAutoConnectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAutoConnectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAutoConnectRequest>(create);
  static SetAutoConnectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mode => $_getIZ(0);
  @$pb.TagNumber(1)
  set mode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get repetitions => $_getIZ(1);
  @$pb.TagNumber(2)
  set repetitions($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRepetitions() => $_has(1);
  @$pb.TagNumber(2)
  void clearRepetitions() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get repetitionDelay => $_getIZ(2);
  @$pb.TagNumber(3)
  set repetitionDelay($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRepetitionDelay() => $_has(2);
  @$pb.TagNumber(3)
  void clearRepetitionDelay() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<CallingWindowEntry> get callingWindow => $_getList(3);
}

/// Onglet 3 – Auto Answer (Class 30)
class AllowedCallerEntry extends $pb.GeneratedMessage {
  factory AllowedCallerEntry({
    $core.String? callerId,
    $core.int? callType,
  }) {
    final result = create();
    if (callerId != null) result.callerId = callerId;
    if (callType != null) result.callType = callType;
    return result;
  }

  AllowedCallerEntry._();

  factory AllowedCallerEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllowedCallerEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllowedCallerEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callerId')
    ..aI(2, _omitFieldNames ? '' : 'callType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowedCallerEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowedCallerEntry copyWith(void Function(AllowedCallerEntry) updates) =>
      super.copyWith((message) => updates(message as AllowedCallerEntry))
          as AllowedCallerEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllowedCallerEntry create() => AllowedCallerEntry._();
  @$core.override
  AllowedCallerEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllowedCallerEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AllowedCallerEntry>(create);
  static AllowedCallerEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get callType => $_getIZ(1);
  @$pb.TagNumber(2)
  set callType($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallType() => $_clearField(2);
}

class AutoAnswerResponse extends $pb.GeneratedMessage {
  factory AutoAnswerResponse({
    $core.int? mode,
    $core.int? numberOfCalls,
    $core.int? ringsInWindow,
    $core.int? ringsOutWindow,
    $core.int? status,
    $core.Iterable<AllowedCallerEntry>? allowedCallers,
    $core.Iterable<CallingWindowEntry>? listeningWindow,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (numberOfCalls != null) result.numberOfCalls = numberOfCalls;
    if (ringsInWindow != null) result.ringsInWindow = ringsInWindow;
    if (ringsOutWindow != null) result.ringsOutWindow = ringsOutWindow;
    if (status != null) result.status = status;
    if (allowedCallers != null) result.allowedCallers.addAll(allowedCallers);
    if (listeningWindow != null) result.listeningWindow.addAll(listeningWindow);
    return result;
  }

  AutoAnswerResponse._();

  factory AutoAnswerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AutoAnswerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutoAnswerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'mode')
    ..aI(2, _omitFieldNames ? '' : 'numberOfCalls')
    ..aI(3, _omitFieldNames ? '' : 'ringsInWindow')
    ..aI(4, _omitFieldNames ? '' : 'ringsOutWindow')
    ..aI(5, _omitFieldNames ? '' : 'status')
    ..pPM<AllowedCallerEntry>(6, _omitFieldNames ? '' : 'allowedCallers',
        subBuilder: AllowedCallerEntry.create)
    ..pPM<CallingWindowEntry>(7, _omitFieldNames ? '' : 'listeningWindow',
        subBuilder: CallingWindowEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoAnswerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoAnswerResponse copyWith(void Function(AutoAnswerResponse) updates) =>
      super.copyWith((message) => updates(message as AutoAnswerResponse))
          as AutoAnswerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoAnswerResponse create() => AutoAnswerResponse._();
  @$core.override
  AutoAnswerResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AutoAnswerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutoAnswerResponse>(create);
  static AutoAnswerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mode => $_getIZ(0);
  @$pb.TagNumber(1)
  set mode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get numberOfCalls => $_getIZ(1);
  @$pb.TagNumber(2)
  set numberOfCalls($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumberOfCalls() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumberOfCalls() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get ringsInWindow => $_getIZ(2);
  @$pb.TagNumber(3)
  set ringsInWindow($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRingsInWindow() => $_has(2);
  @$pb.TagNumber(3)
  void clearRingsInWindow() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get ringsOutWindow => $_getIZ(3);
  @$pb.TagNumber(4)
  set ringsOutWindow($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRingsOutWindow() => $_has(3);
  @$pb.TagNumber(4)
  void clearRingsOutWindow() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get status => $_getIZ(4);
  @$pb.TagNumber(5)
  set status($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<AllowedCallerEntry> get allowedCallers => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<CallingWindowEntry> get listeningWindow => $_getList(6);
}

class SetAutoAnswerRequest extends $pb.GeneratedMessage {
  factory SetAutoAnswerRequest({
    $core.int? mode,
    $core.int? numberOfCalls,
    $core.int? ringsInWindow,
    $core.int? ringsOutWindow,
    $core.Iterable<AllowedCallerEntry>? allowedCallers,
    $core.Iterable<CallingWindowEntry>? listeningWindow,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (numberOfCalls != null) result.numberOfCalls = numberOfCalls;
    if (ringsInWindow != null) result.ringsInWindow = ringsInWindow;
    if (ringsOutWindow != null) result.ringsOutWindow = ringsOutWindow;
    if (allowedCallers != null) result.allowedCallers.addAll(allowedCallers);
    if (listeningWindow != null) result.listeningWindow.addAll(listeningWindow);
    return result;
  }

  SetAutoAnswerRequest._();

  factory SetAutoAnswerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAutoAnswerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAutoAnswerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'mode')
    ..aI(2, _omitFieldNames ? '' : 'numberOfCalls')
    ..aI(3, _omitFieldNames ? '' : 'ringsInWindow')
    ..aI(4, _omitFieldNames ? '' : 'ringsOutWindow')
    ..pPM<AllowedCallerEntry>(5, _omitFieldNames ? '' : 'allowedCallers',
        subBuilder: AllowedCallerEntry.create)
    ..pPM<CallingWindowEntry>(6, _omitFieldNames ? '' : 'listeningWindow',
        subBuilder: CallingWindowEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAutoAnswerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAutoAnswerRequest copyWith(void Function(SetAutoAnswerRequest) updates) =>
      super.copyWith((message) => updates(message as SetAutoAnswerRequest))
          as SetAutoAnswerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAutoAnswerRequest create() => SetAutoAnswerRequest._();
  @$core.override
  SetAutoAnswerRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAutoAnswerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAutoAnswerRequest>(create);
  static SetAutoAnswerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mode => $_getIZ(0);
  @$pb.TagNumber(1)
  set mode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get numberOfCalls => $_getIZ(1);
  @$pb.TagNumber(2)
  set numberOfCalls($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumberOfCalls() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumberOfCalls() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get ringsInWindow => $_getIZ(2);
  @$pb.TagNumber(3)
  set ringsInWindow($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRingsInWindow() => $_has(2);
  @$pb.TagNumber(3)
  void clearRingsInWindow() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get ringsOutWindow => $_getIZ(3);
  @$pb.TagNumber(4)
  set ringsOutWindow($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRingsOutWindow() => $_has(3);
  @$pb.TagNumber(4)
  void clearRingsOutWindow() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<AllowedCallerEntry> get allowedCallers => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<CallingWindowEntry> get listeningWindow => $_getList(5);
}

/// Onglet 4 – TCP/UDP Setup (Class 41)
/// attr 2=port, attr 3=IP_reference(read-only), attr 4=MSS, attr 5=nb_of_sim_conn, attr 6=inactivity_timeout
class TcpUdpSetupResponse extends $pb.GeneratedMessage {
  factory TcpUdpSetupResponse({
    $core.int? port,
    $core.String? ipReference,
    $core.int? mss,
    $core.int? nbConnections,
    $core.int? inactivityTimeout,
  }) {
    final result = create();
    if (port != null) result.port = port;
    if (ipReference != null) result.ipReference = ipReference;
    if (mss != null) result.mss = mss;
    if (nbConnections != null) result.nbConnections = nbConnections;
    if (inactivityTimeout != null) result.inactivityTimeout = inactivityTimeout;
    return result;
  }

  TcpUdpSetupResponse._();

  factory TcpUdpSetupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TcpUdpSetupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TcpUdpSetupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'port')
    ..aOS(2, _omitFieldNames ? '' : 'ipReference')
    ..aI(3, _omitFieldNames ? '' : 'mss')
    ..aI(4, _omitFieldNames ? '' : 'nbConnections')
    ..aI(5, _omitFieldNames ? '' : 'inactivityTimeout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TcpUdpSetupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TcpUdpSetupResponse copyWith(void Function(TcpUdpSetupResponse) updates) =>
      super.copyWith((message) => updates(message as TcpUdpSetupResponse))
          as TcpUdpSetupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TcpUdpSetupResponse create() => TcpUdpSetupResponse._();
  @$core.override
  TcpUdpSetupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TcpUdpSetupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TcpUdpSetupResponse>(create);
  static TcpUdpSetupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ipReference => $_getSZ(1);
  @$pb.TagNumber(2)
  set ipReference($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIpReference() => $_has(1);
  @$pb.TagNumber(2)
  void clearIpReference() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get mss => $_getIZ(2);
  @$pb.TagNumber(3)
  set mss($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMss() => $_has(2);
  @$pb.TagNumber(3)
  void clearMss() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get nbConnections => $_getIZ(3);
  @$pb.TagNumber(4)
  set nbConnections($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNbConnections() => $_has(3);
  @$pb.TagNumber(4)
  void clearNbConnections() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get inactivityTimeout => $_getIZ(4);
  @$pb.TagNumber(5)
  set inactivityTimeout($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInactivityTimeout() => $_has(4);
  @$pb.TagNumber(5)
  void clearInactivityTimeout() => $_clearField(5);
}

class SetTcpUdpSetupRequest extends $pb.GeneratedMessage {
  factory SetTcpUdpSetupRequest({
    $core.int? port,
    $core.int? mss,
    $core.int? nbConnections,
    $core.int? inactivityTimeout,
  }) {
    final result = create();
    if (port != null) result.port = port;
    if (mss != null) result.mss = mss;
    if (nbConnections != null) result.nbConnections = nbConnections;
    if (inactivityTimeout != null) result.inactivityTimeout = inactivityTimeout;
    return result;
  }

  SetTcpUdpSetupRequest._();

  factory SetTcpUdpSetupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTcpUdpSetupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTcpUdpSetupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'port')
    ..aI(2, _omitFieldNames ? '' : 'mss')
    ..aI(3, _omitFieldNames ? '' : 'nbConnections')
    ..aI(4, _omitFieldNames ? '' : 'inactivityTimeout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTcpUdpSetupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTcpUdpSetupRequest copyWith(
          void Function(SetTcpUdpSetupRequest) updates) =>
      super.copyWith((message) => updates(message as SetTcpUdpSetupRequest))
          as SetTcpUdpSetupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTcpUdpSetupRequest create() => SetTcpUdpSetupRequest._();
  @$core.override
  SetTcpUdpSetupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTcpUdpSetupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTcpUdpSetupRequest>(create);
  static SetTcpUdpSetupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get mss => $_getIZ(1);
  @$pb.TagNumber(2)
  set mss($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMss() => $_has(1);
  @$pb.TagNumber(2)
  void clearMss() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get nbConnections => $_getIZ(2);
  @$pb.TagNumber(3)
  set nbConnections($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNbConnections() => $_has(2);
  @$pb.TagNumber(3)
  void clearNbConnections() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get inactivityTimeout => $_getIZ(3);
  @$pb.TagNumber(4)
  set inactivityTimeout($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInactivityTimeout() => $_has(3);
  @$pb.TagNumber(4)
  void clearInactivityTimeout() => $_clearField(4);
}

/// Compact time value matching DLMS time octet-string layout.
class CalendarTimeValue extends $pb.GeneratedMessage {
  factory CalendarTimeValue({
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
    $core.int? hundredths,
  }) {
    final result = create();
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    if (hundredths != null) result.hundredths = hundredths;
    return result;
  }

  CalendarTimeValue._();

  factory CalendarTimeValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarTimeValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarTimeValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'hour')
    ..aI(2, _omitFieldNames ? '' : 'minute')
    ..aI(3, _omitFieldNames ? '' : 'second')
    ..aI(4, _omitFieldNames ? '' : 'hundredths')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTimeValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarTimeValue copyWith(void Function(CalendarTimeValue) updates) =>
      super.copyWith((message) => updates(message as CalendarTimeValue))
          as CalendarTimeValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarTimeValue create() => CalendarTimeValue._();
  @$core.override
  CalendarTimeValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarTimeValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarTimeValue>(create);
  static CalendarTimeValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get hour => $_getIZ(0);
  @$pb.TagNumber(1)
  set hour($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHour() => $_has(0);
  @$pb.TagNumber(1)
  void clearHour() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minute => $_getIZ(1);
  @$pb.TagNumber(2)
  set minute($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinute() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinute() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get second => $_getIZ(2);
  @$pb.TagNumber(3)
  set second($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSecond() => $_has(2);
  @$pb.TagNumber(3)
  void clearSecond() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get hundredths => $_getIZ(3);
  @$pb.TagNumber(4)
  set hundredths($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHundredths() => $_has(3);
  @$pb.TagNumber(4)
  void clearHundredths() => $_clearField(4);
}

/// Compact date value matching DLMS date octet-string layout.
class CalendarDateValue extends $pb.GeneratedMessage {
  factory CalendarDateValue({
    $core.int? year,
    $core.int? month,
    $core.int? dayOfMonth,
    $core.int? dayOfWeek,
  }) {
    final result = create();
    if (year != null) result.year = year;
    if (month != null) result.month = month;
    if (dayOfMonth != null) result.dayOfMonth = dayOfMonth;
    if (dayOfWeek != null) result.dayOfWeek = dayOfWeek;
    return result;
  }

  CalendarDateValue._();

  factory CalendarDateValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarDateValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarDateValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'year')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'dayOfMonth')
    ..aI(4, _omitFieldNames ? '' : 'dayOfWeek')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDateValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDateValue copyWith(void Function(CalendarDateValue) updates) =>
      super.copyWith((message) => updates(message as CalendarDateValue))
          as CalendarDateValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarDateValue create() => CalendarDateValue._();
  @$core.override
  CalendarDateValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarDateValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarDateValue>(create);
  static CalendarDateValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get year => $_getIZ(0);
  @$pb.TagNumber(1)
  set year($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYear() => $_has(0);
  @$pb.TagNumber(1)
  void clearYear() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get dayOfMonth => $_getIZ(2);
  @$pb.TagNumber(3)
  set dayOfMonth($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDayOfMonth() => $_has(2);
  @$pb.TagNumber(3)
  void clearDayOfMonth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get dayOfWeek => $_getIZ(3);
  @$pb.TagNumber(4)
  set dayOfWeek($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDayOfWeek() => $_has(3);
  @$pb.TagNumber(4)
  void clearDayOfWeek() => $_clearField(4);
}

/// One timed action within a day profile (maps to DLMS day_profile_action).
class DayProfileAction extends $pb.GeneratedMessage {
  factory DayProfileAction({
    CalendarTimeValue? startTime,
    $core.String? scriptLogicalName,
    $core.int? scriptSelector,
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (scriptLogicalName != null) result.scriptLogicalName = scriptLogicalName;
    if (scriptSelector != null) result.scriptSelector = scriptSelector;
    return result;
  }

  DayProfileAction._();

  factory DayProfileAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DayProfileAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DayProfileAction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOM<CalendarTimeValue>(1, _omitFieldNames ? '' : 'startTime',
        subBuilder: CalendarTimeValue.create)
    ..aOS(2, _omitFieldNames ? '' : 'scriptLogicalName')
    ..aI(3, _omitFieldNames ? '' : 'scriptSelector')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayProfileAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayProfileAction copyWith(void Function(DayProfileAction) updates) =>
      super.copyWith((message) => updates(message as DayProfileAction))
          as DayProfileAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DayProfileAction create() => DayProfileAction._();
  @$core.override
  DayProfileAction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DayProfileAction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DayProfileAction>(create);
  static DayProfileAction? _defaultInstance;

  @$pb.TagNumber(1)
  CalendarTimeValue get startTime => $_getN(0);
  @$pb.TagNumber(1)
  set startTime(CalendarTimeValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);
  @$pb.TagNumber(1)
  CalendarTimeValue ensureStartTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get scriptLogicalName => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptLogicalName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptLogicalName() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptLogicalName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get scriptSelector => $_getIZ(2);
  @$pb.TagNumber(3)
  set scriptSelector($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScriptSelector() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptSelector() => $_clearField(3);
}

/// A single day profile (DLMS day_profile).
class CalendarDayProfile extends $pb.GeneratedMessage {
  factory CalendarDayProfile({
    $core.int? dayId,
    $core.Iterable<DayProfileAction>? daySchedule,
  }) {
    final result = create();
    if (dayId != null) result.dayId = dayId;
    if (daySchedule != null) result.daySchedule.addAll(daySchedule);
    return result;
  }

  CalendarDayProfile._();

  factory CalendarDayProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarDayProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarDayProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'dayId')
    ..pPM<DayProfileAction>(2, _omitFieldNames ? '' : 'daySchedule',
        subBuilder: DayProfileAction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDayProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarDayProfile copyWith(void Function(CalendarDayProfile) updates) =>
      super.copyWith((message) => updates(message as CalendarDayProfile))
          as CalendarDayProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarDayProfile create() => CalendarDayProfile._();
  @$core.override
  CalendarDayProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarDayProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarDayProfile>(create);
  static CalendarDayProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get dayId => $_getIZ(0);
  @$pb.TagNumber(1)
  set dayId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDayId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDayId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<DayProfileAction> get daySchedule => $_getList(1);
}

/// A single week profile (DLMS week_profile_table_entry).
class CalendarWeekProfile extends $pb.GeneratedMessage {
  factory CalendarWeekProfile({
    $core.String? weekProfileName,
    $core.int? monday,
    $core.int? tuesday,
    $core.int? wednesday,
    $core.int? thursday,
    $core.int? friday,
    $core.int? saturday,
    $core.int? sunday,
  }) {
    final result = create();
    if (weekProfileName != null) result.weekProfileName = weekProfileName;
    if (monday != null) result.monday = monday;
    if (tuesday != null) result.tuesday = tuesday;
    if (wednesday != null) result.wednesday = wednesday;
    if (thursday != null) result.thursday = thursday;
    if (friday != null) result.friday = friday;
    if (saturday != null) result.saturday = saturday;
    if (sunday != null) result.sunday = sunday;
    return result;
  }

  CalendarWeekProfile._();

  factory CalendarWeekProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarWeekProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarWeekProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'weekProfileName')
    ..aI(2, _omitFieldNames ? '' : 'monday')
    ..aI(3, _omitFieldNames ? '' : 'tuesday')
    ..aI(4, _omitFieldNames ? '' : 'wednesday')
    ..aI(5, _omitFieldNames ? '' : 'thursday')
    ..aI(6, _omitFieldNames ? '' : 'friday')
    ..aI(7, _omitFieldNames ? '' : 'saturday')
    ..aI(8, _omitFieldNames ? '' : 'sunday')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarWeekProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarWeekProfile copyWith(void Function(CalendarWeekProfile) updates) =>
      super.copyWith((message) => updates(message as CalendarWeekProfile))
          as CalendarWeekProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarWeekProfile create() => CalendarWeekProfile._();
  @$core.override
  CalendarWeekProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarWeekProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarWeekProfile>(create);
  static CalendarWeekProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get weekProfileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set weekProfileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWeekProfileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWeekProfileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get monday => $_getIZ(1);
  @$pb.TagNumber(2)
  set monday($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonday() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonday() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tuesday => $_getIZ(2);
  @$pb.TagNumber(3)
  set tuesday($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTuesday() => $_has(2);
  @$pb.TagNumber(3)
  void clearTuesday() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get wednesday => $_getIZ(3);
  @$pb.TagNumber(4)
  set wednesday($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWednesday() => $_has(3);
  @$pb.TagNumber(4)
  void clearWednesday() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get thursday => $_getIZ(4);
  @$pb.TagNumber(5)
  set thursday($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThursday() => $_has(4);
  @$pb.TagNumber(5)
  void clearThursday() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get friday => $_getIZ(5);
  @$pb.TagNumber(6)
  set friday($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFriday() => $_has(5);
  @$pb.TagNumber(6)
  void clearFriday() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get saturday => $_getIZ(6);
  @$pb.TagNumber(7)
  set saturday($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSaturday() => $_has(6);
  @$pb.TagNumber(7)
  void clearSaturday() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get sunday => $_getIZ(7);
  @$pb.TagNumber(8)
  set sunday($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSunday() => $_has(7);
  @$pb.TagNumber(8)
  void clearSunday() => $_clearField(8);
}

/// A single season profile entry (DLMS season_profile).
class CalendarSeasonProfile extends $pb.GeneratedMessage {
  factory CalendarSeasonProfile({
    $core.String? seasonProfileName,
    CalendarDateValue? seasonStart,
    $core.String? weekProfileName,
  }) {
    final result = create();
    if (seasonProfileName != null) result.seasonProfileName = seasonProfileName;
    if (seasonStart != null) result.seasonStart = seasonStart;
    if (weekProfileName != null) result.weekProfileName = weekProfileName;
    return result;
  }

  CalendarSeasonProfile._();

  factory CalendarSeasonProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarSeasonProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarSeasonProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'seasonProfileName')
    ..aOM<CalendarDateValue>(2, _omitFieldNames ? '' : 'seasonStart',
        subBuilder: CalendarDateValue.create)
    ..aOS(3, _omitFieldNames ? '' : 'weekProfileName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSeasonProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarSeasonProfile copyWith(
          void Function(CalendarSeasonProfile) updates) =>
      super.copyWith((message) => updates(message as CalendarSeasonProfile))
          as CalendarSeasonProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarSeasonProfile create() => CalendarSeasonProfile._();
  @$core.override
  CalendarSeasonProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarSeasonProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarSeasonProfile>(create);
  static CalendarSeasonProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get seasonProfileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set seasonProfileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeasonProfileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeasonProfileName() => $_clearField(1);

  @$pb.TagNumber(2)
  CalendarDateValue get seasonStart => $_getN(1);
  @$pb.TagNumber(2)
  set seasonStart(CalendarDateValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSeasonStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeasonStart() => $_clearField(2);
  @$pb.TagNumber(2)
  CalendarDateValue ensureSeasonStart() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get weekProfileName => $_getSZ(2);
  @$pb.TagNumber(3)
  set weekProfileName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeekProfileName() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeekProfileName() => $_clearField(3);
}

/// Full snapshot of one activity calendar (active or passive, Attr 2-5 or 6-9).
class ActivityCalendarData extends $pb.GeneratedMessage {
  factory ActivityCalendarData({
    $core.String? calendarName,
    $core.Iterable<CalendarSeasonProfile>? seasonProfiles,
    $core.Iterable<CalendarWeekProfile>? weekProfiles,
    $core.Iterable<CalendarDayProfile>? dayProfiles,
  }) {
    final result = create();
    if (calendarName != null) result.calendarName = calendarName;
    if (seasonProfiles != null) result.seasonProfiles.addAll(seasonProfiles);
    if (weekProfiles != null) result.weekProfiles.addAll(weekProfiles);
    if (dayProfiles != null) result.dayProfiles.addAll(dayProfiles);
    return result;
  }

  ActivityCalendarData._();

  factory ActivityCalendarData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivityCalendarData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivityCalendarData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'calendarName')
    ..pPM<CalendarSeasonProfile>(2, _omitFieldNames ? '' : 'seasonProfiles',
        subBuilder: CalendarSeasonProfile.create)
    ..pPM<CalendarWeekProfile>(3, _omitFieldNames ? '' : 'weekProfiles',
        subBuilder: CalendarWeekProfile.create)
    ..pPM<CalendarDayProfile>(4, _omitFieldNames ? '' : 'dayProfiles',
        subBuilder: CalendarDayProfile.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityCalendarData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityCalendarData copyWith(void Function(ActivityCalendarData) updates) =>
      super.copyWith((message) => updates(message as ActivityCalendarData))
          as ActivityCalendarData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivityCalendarData create() => ActivityCalendarData._();
  @$core.override
  ActivityCalendarData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivityCalendarData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivityCalendarData>(create);
  static ActivityCalendarData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get calendarName => $_getSZ(0);
  @$pb.TagNumber(1)
  set calendarName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCalendarName() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalendarName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<CalendarSeasonProfile> get seasonProfiles => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<CalendarWeekProfile> get weekProfiles => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<CalendarDayProfile> get dayProfiles => $_getList(3);
}

/// One entry in the special days table (DLMS Class 11 Attr 2).
class SpecialDayEntry extends $pb.GeneratedMessage {
  factory SpecialDayEntry({
    $core.int? index,
    CalendarDateValue? specialDayDate,
    $core.int? dayId,
  }) {
    final result = create();
    if (index != null) result.index = index;
    if (specialDayDate != null) result.specialDayDate = specialDayDate;
    if (dayId != null) result.dayId = dayId;
    return result;
  }

  SpecialDayEntry._();

  factory SpecialDayEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpecialDayEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpecialDayEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aOM<CalendarDateValue>(2, _omitFieldNames ? '' : 'specialDayDate',
        subBuilder: CalendarDateValue.create)
    ..aI(3, _omitFieldNames ? '' : 'dayId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpecialDayEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpecialDayEntry copyWith(void Function(SpecialDayEntry) updates) =>
      super.copyWith((message) => updates(message as SpecialDayEntry))
          as SpecialDayEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpecialDayEntry create() => SpecialDayEntry._();
  @$core.override
  SpecialDayEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpecialDayEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpecialDayEntry>(create);
  static SpecialDayEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  CalendarDateValue get specialDayDate => $_getN(1);
  @$pb.TagNumber(2)
  set specialDayDate(CalendarDateValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSpecialDayDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpecialDayDate() => $_clearField(2);
  @$pb.TagNumber(2)
  CalendarDateValue ensureSpecialDayDate() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get dayId => $_getIZ(2);
  @$pb.TagNumber(3)
  set dayId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDayId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDayId() => $_clearField(3);
}

/// Full special days table.
class SpecialDayTable extends $pb.GeneratedMessage {
  factory SpecialDayTable({
    $core.Iterable<SpecialDayEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  SpecialDayTable._();

  factory SpecialDayTable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpecialDayTable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpecialDayTable',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<SpecialDayEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: SpecialDayEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpecialDayTable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpecialDayTable copyWith(void Function(SpecialDayTable) updates) =>
      super.copyWith((message) => updates(message as SpecialDayTable))
          as SpecialDayTable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpecialDayTable create() => SpecialDayTable._();
  @$core.override
  SpecialDayTable createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpecialDayTable getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpecialDayTable>(create);
  static SpecialDayTable? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SpecialDayEntry> get entries => $_getList(0);
}

/// Request to set/get the passive calendar activation time (Attr 10 of Class 20).
class CalendarActivationTime extends $pb.GeneratedMessage {
  factory CalendarActivationTime({
    $core.int? year,
    $core.int? month,
    $core.int? day,
    $core.int? hour,
    $core.int? minute,
    $core.int? second,
  }) {
    final result = create();
    if (year != null) result.year = year;
    if (month != null) result.month = month;
    if (day != null) result.day = day;
    if (hour != null) result.hour = hour;
    if (minute != null) result.minute = minute;
    if (second != null) result.second = second;
    return result;
  }

  CalendarActivationTime._();

  factory CalendarActivationTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalendarActivationTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalendarActivationTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'year')
    ..aI(2, _omitFieldNames ? '' : 'month')
    ..aI(3, _omitFieldNames ? '' : 'day')
    ..aI(4, _omitFieldNames ? '' : 'hour')
    ..aI(5, _omitFieldNames ? '' : 'minute')
    ..aI(6, _omitFieldNames ? '' : 'second')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarActivationTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalendarActivationTime copyWith(
          void Function(CalendarActivationTime) updates) =>
      super.copyWith((message) => updates(message as CalendarActivationTime))
          as CalendarActivationTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarActivationTime create() => CalendarActivationTime._();
  @$core.override
  CalendarActivationTime createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalendarActivationTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalendarActivationTime>(create);
  static CalendarActivationTime? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get year => $_getIZ(0);
  @$pb.TagNumber(1)
  set year($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYear() => $_has(0);
  @$pb.TagNumber(1)
  void clearYear() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get day => $_getIZ(2);
  @$pb.TagNumber(3)
  set day($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearDay() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get hour => $_getIZ(3);
  @$pb.TagNumber(4)
  set hour($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHour() => $_has(3);
  @$pb.TagNumber(4)
  void clearHour() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get minute => $_getIZ(4);
  @$pb.TagNumber(5)
  set minute($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinute() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinute() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get second => $_getIZ(5);
  @$pb.TagNumber(6)
  set second($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecond() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecond() => $_clearField(6);
}

/// ==========================
/// Export Data
/// ==========================
class ExportDataRequest extends $pb.GeneratedMessage {
  factory ExportDataRequest({
    $core.String? pageId,
    $core.String? type,
    $core.String? data,
    $core.String? folderPath,
    $core.String? pageType,
    $core.String? fileNameSuffix,
  }) {
    final result = create();
    if (pageId != null) result.pageId = pageId;
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    if (folderPath != null) result.folderPath = folderPath;
    if (pageType != null) result.pageType = pageType;
    if (fileNameSuffix != null) result.fileNameSuffix = fileNameSuffix;
    return result;
  }

  ExportDataRequest._();

  factory ExportDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pageId')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'data')
    ..aOS(4, _omitFieldNames ? '' : 'folderPath')
    ..aOS(5, _omitFieldNames ? '' : 'pageType')
    ..aOS(6, _omitFieldNames ? '' : 'fileNameSuffix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDataRequest copyWith(void Function(ExportDataRequest) updates) =>
      super.copyWith((message) => updates(message as ExportDataRequest))
          as ExportDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportDataRequest create() => ExportDataRequest._();
  @$core.override
  ExportDataRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportDataRequest>(create);
  static ExportDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get data => $_getSZ(2);
  @$pb.TagNumber(3)
  set data($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get folderPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set folderPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFolderPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearFolderPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pageType => $_getSZ(4);
  @$pb.TagNumber(5)
  set pageType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageType() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fileNameSuffix => $_getSZ(5);
  @$pb.TagNumber(6)
  set fileNameSuffix($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFileNameSuffix() => $_has(5);
  @$pb.TagNumber(6)
  void clearFileNameSuffix() => $_clearField(6);
}

class ExportDataResponse extends $pb.GeneratedMessage {
  factory ExportDataResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  ExportDataResponse._();

  factory ExportDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportDataResponse copyWith(void Function(ExportDataResponse) updates) =>
      super.copyWith((message) => updates(message as ExportDataResponse))
          as ExportDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportDataResponse create() => ExportDataResponse._();
  @$core.override
  ExportDataResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportDataResponse>(create);
  static ExportDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

/// ==========================
/// Push Setup Server
/// ==========================
class StartPushSetupServerRequest extends $pb.GeneratedMessage {
  factory StartPushSetupServerRequest({
    $core.String? host,
    $core.int? port,
    $core.String? type,
  }) {
    final result = create();
    if (host != null) result.host = host;
    if (port != null) result.port = port;
    if (type != null) result.type = type;
    return result;
  }

  StartPushSetupServerRequest._();

  factory StartPushSetupServerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartPushSetupServerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartPushSetupServerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'host')
    ..aI(2, _omitFieldNames ? '' : 'port')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPushSetupServerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPushSetupServerRequest copyWith(
          void Function(StartPushSetupServerRequest) updates) =>
      super.copyWith(
              (message) => updates(message as StartPushSetupServerRequest))
          as StartPushSetupServerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartPushSetupServerRequest create() =>
      StartPushSetupServerRequest._();
  @$core.override
  StartPushSetupServerRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartPushSetupServerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartPushSetupServerRequest>(create);
  static StartPushSetupServerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);
}

class PushNotification extends $pb.GeneratedMessage {
  factory PushNotification({
    $core.String? xml,
  }) {
    final result = create();
    if (xml != null) result.xml = xml;
    return result;
  }

  PushNotification._();

  factory PushNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotification copyWith(void Function(PushNotification) updates) =>
      super.copyWith((message) => updates(message as PushNotification))
          as PushNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushNotification create() => PushNotification._();
  @$core.override
  PushNotification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushNotification>(create);
  static PushNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xml => $_getSZ(0);
  @$pb.TagNumber(1)
  set xml($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXml() => $_has(0);
  @$pb.TagNumber(1)
  void clearXml() => $_clearField(1);
}

/// Retry Status Notification
/// ==========================
class RetryStatusUpdate extends $pb.GeneratedMessage {
  factory RetryStatusUpdate({
    $core.int? attempt,
    $core.int? maxAttempts,
    $core.bool? allFailed,
    $core.String? message,
  }) {
    final result = create();
    if (attempt != null) result.attempt = attempt;
    if (maxAttempts != null) result.maxAttempts = maxAttempts;
    if (allFailed != null) result.allFailed = allFailed;
    if (message != null) result.message = message;
    return result;
  }

  RetryStatusUpdate._();

  factory RetryStatusUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RetryStatusUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RetryStatusUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'attempt')
    ..aI(2, _omitFieldNames ? '' : 'maxAttempts')
    ..aOB(3, _omitFieldNames ? '' : 'allFailed')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryStatusUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryStatusUpdate copyWith(void Function(RetryStatusUpdate) updates) =>
      super.copyWith((message) => updates(message as RetryStatusUpdate))
          as RetryStatusUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetryStatusUpdate create() => RetryStatusUpdate._();
  @$core.override
  RetryStatusUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RetryStatusUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetryStatusUpdate>(create);
  static RetryStatusUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get attempt => $_getIZ(0);
  @$pb.TagNumber(1)
  set attempt($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttempt() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttempt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxAttempts => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxAttempts($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxAttempts() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxAttempts() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get allFailed => $_getBF(2);
  @$pb.TagNumber(3)
  set allFailed($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAllFailed() => $_has(2);
  @$pb.TagNumber(3)
  void clearAllFailed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);
}

class GetLteNetworkParametersResponse extends $pb.GeneratedMessage {
  factory GetLteNetworkParametersResponse({
    $core.int? t3402,
    $core.int? t3412,
    $core.int? t3412ext2,
    $core.int? t3324,
    $core.int? tEdrx,
    $core.int? tptw,
    $core.int? qRxlevMin,
    $core.int? qRxlevMinCeR13,
    $core.int? qRxlevMinCe1R13,
  }) {
    final result = create();
    if (t3402 != null) result.t3402 = t3402;
    if (t3412 != null) result.t3412 = t3412;
    if (t3412ext2 != null) result.t3412ext2 = t3412ext2;
    if (t3324 != null) result.t3324 = t3324;
    if (tEdrx != null) result.tEdrx = tEdrx;
    if (tptw != null) result.tptw = tptw;
    if (qRxlevMin != null) result.qRxlevMin = qRxlevMin;
    if (qRxlevMinCeR13 != null) result.qRxlevMinCeR13 = qRxlevMinCeR13;
    if (qRxlevMinCe1R13 != null) result.qRxlevMinCe1R13 = qRxlevMinCe1R13;
    return result;
  }

  GetLteNetworkParametersResponse._();

  factory GetLteNetworkParametersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLteNetworkParametersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLteNetworkParametersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 't3402')
    ..aI(2, _omitFieldNames ? '' : 't3412')
    ..aI(3, _omitFieldNames ? '' : 't3412ext2')
    ..aI(4, _omitFieldNames ? '' : 't3324')
    ..aI(5, _omitFieldNames ? '' : 'tEdrx')
    ..aI(6, _omitFieldNames ? '' : 'tptw')
    ..aI(7, _omitFieldNames ? '' : 'qRxlevMin')
    ..aI(8, _omitFieldNames ? '' : 'qRxlevMinCeR13')
    ..aI(9, _omitFieldNames ? '' : 'qRxlevMinCe1R13')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLteNetworkParametersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLteNetworkParametersResponse copyWith(
          void Function(GetLteNetworkParametersResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetLteNetworkParametersResponse))
          as GetLteNetworkParametersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLteNetworkParametersResponse create() =>
      GetLteNetworkParametersResponse._();
  @$core.override
  GetLteNetworkParametersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLteNetworkParametersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLteNetworkParametersResponse>(
          create);
  static GetLteNetworkParametersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get t3402 => $_getIZ(0);
  @$pb.TagNumber(1)
  set t3402($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasT3402() => $_has(0);
  @$pb.TagNumber(1)
  void clearT3402() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get t3412 => $_getIZ(1);
  @$pb.TagNumber(2)
  set t3412($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasT3412() => $_has(1);
  @$pb.TagNumber(2)
  void clearT3412() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get t3412ext2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set t3412ext2($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasT3412ext2() => $_has(2);
  @$pb.TagNumber(3)
  void clearT3412ext2() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get t3324 => $_getIZ(3);
  @$pb.TagNumber(4)
  set t3324($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasT3324() => $_has(3);
  @$pb.TagNumber(4)
  void clearT3324() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get tEdrx => $_getIZ(4);
  @$pb.TagNumber(5)
  set tEdrx($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTEdrx() => $_has(4);
  @$pb.TagNumber(5)
  void clearTEdrx() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get tptw => $_getIZ(5);
  @$pb.TagNumber(6)
  set tptw($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTptw() => $_has(5);
  @$pb.TagNumber(6)
  void clearTptw() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get qRxlevMin => $_getIZ(6);
  @$pb.TagNumber(7)
  set qRxlevMin($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQRxlevMin() => $_has(6);
  @$pb.TagNumber(7)
  void clearQRxlevMin() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get qRxlevMinCeR13 => $_getIZ(7);
  @$pb.TagNumber(8)
  set qRxlevMinCeR13($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasQRxlevMinCeR13() => $_has(7);
  @$pb.TagNumber(8)
  void clearQRxlevMinCeR13() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get qRxlevMinCe1R13 => $_getIZ(8);
  @$pb.TagNumber(9)
  set qRxlevMinCe1R13($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasQRxlevMinCe1R13() => $_has(8);
  @$pb.TagNumber(9)
  void clearQRxlevMinCe1R13() => $_clearField(9);
}

class GetLteQosResponse extends $pb.GeneratedMessage {
  factory GetLteQosResponse({
    $core.int? nrsrq,
    $core.int? nrsrp,
    $core.int? snr,
    $core.int? coverageEnhancement,
  }) {
    final result = create();
    if (nrsrq != null) result.nrsrq = nrsrq;
    if (nrsrp != null) result.nrsrp = nrsrp;
    if (snr != null) result.snr = snr;
    if (coverageEnhancement != null)
      result.coverageEnhancement = coverageEnhancement;
    return result;
  }

  GetLteQosResponse._();

  factory GetLteQosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLteQosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLteQosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'nrsrq')
    ..aI(2, _omitFieldNames ? '' : 'nrsrp')
    ..aI(3, _omitFieldNames ? '' : 'snr')
    ..aI(4, _omitFieldNames ? '' : 'coverageEnhancement')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLteQosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLteQosResponse copyWith(void Function(GetLteQosResponse) updates) =>
      super.copyWith((message) => updates(message as GetLteQosResponse))
          as GetLteQosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLteQosResponse create() => GetLteQosResponse._();
  @$core.override
  GetLteQosResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLteQosResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLteQosResponse>(create);
  static GetLteQosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nrsrq => $_getIZ(0);
  @$pb.TagNumber(1)
  set nrsrq($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNrsrq() => $_has(0);
  @$pb.TagNumber(1)
  void clearNrsrq() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get nrsrp => $_getIZ(1);
  @$pb.TagNumber(2)
  set nrsrp($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNrsrp() => $_has(1);
  @$pb.TagNumber(2)
  void clearNrsrp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get snr => $_getIZ(2);
  @$pb.TagNumber(3)
  set snr($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnr() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnr() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get coverageEnhancement => $_getIZ(3);
  @$pb.TagNumber(4)
  set coverageEnhancement($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCoverageEnhancement() => $_has(3);
  @$pb.TagNumber(4)
  void clearCoverageEnhancement() => $_clearField(4);
}

/// ImageTransfer attribute 6: image_transfer_status (COSEM class 18 enum).
/// 0=not_initiated 1=initiated 2=verification_initiated 3=verification_successful
/// 4=verification_failed 5=activation_initiated 6=activation_successful 7=activation_failed
class ImageTransferStatusResponse extends $pb.GeneratedMessage {
  factory ImageTransferStatusResponse({
    $core.int? status,
    $core.String? label,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (label != null) result.label = label;
    return result;
  }

  ImageTransferStatusResponse._();

  factory ImageTransferStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageTransferStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageTransferStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageTransferStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageTransferStatusResponse copyWith(
          void Function(ImageTransferStatusResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ImageTransferStatusResponse))
          as ImageTransferStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageTransferStatusResponse create() =>
      ImageTransferStatusResponse._();
  @$core.override
  ImageTransferStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageTransferStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageTransferStatusResponse>(create);
  static ImageTransferStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1)
  set status($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

class GetQualityObjectsRequest extends $pb.GeneratedMessage {
  factory GetQualityObjectsRequest({
    $core.Iterable<$core.String>? objects,
  }) {
    final result = create();
    if (objects != null) result.objects.addAll(objects);
    return result;
  }

  GetQualityObjectsRequest._();

  factory GetQualityObjectsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQualityObjectsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQualityObjectsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'objects')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQualityObjectsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQualityObjectsRequest copyWith(
          void Function(GetQualityObjectsRequest) updates) =>
      super.copyWith((message) => updates(message as GetQualityObjectsRequest))
          as GetQualityObjectsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQualityObjectsRequest create() => GetQualityObjectsRequest._();
  @$core.override
  GetQualityObjectsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetQualityObjectsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQualityObjectsRequest>(create);
  static GetQualityObjectsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get objects => $_getList(0);
}

class GetQualityObjectsResponse extends $pb.GeneratedMessage {
  factory GetQualityObjectsResponse({
    $core.Iterable<QualityObject>? objects,
  }) {
    final result = create();
    if (objects != null) result.objects.addAll(objects);
    return result;
  }

  GetQualityObjectsResponse._();

  factory GetQualityObjectsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQualityObjectsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQualityObjectsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..pPM<QualityObject>(1, _omitFieldNames ? '' : 'objects',
        subBuilder: QualityObject.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQualityObjectsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQualityObjectsResponse copyWith(
          void Function(GetQualityObjectsResponse) updates) =>
      super.copyWith((message) => updates(message as GetQualityObjectsResponse))
          as GetQualityObjectsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQualityObjectsResponse create() => GetQualityObjectsResponse._();
  @$core.override
  GetQualityObjectsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetQualityObjectsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQualityObjectsResponse>(create);
  static GetQualityObjectsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<QualityObject> get objects => $_getList(0);
}

class QualityObject extends $pb.GeneratedMessage {
  factory QualityObject({
    $core.String? name,
    $core.double? value,
    $core.String? unit,
    $core.int? scaler,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    if (scaler != null) result.scaler = scaler;
    return result;
  }

  QualityObject._();

  factory QualityObject.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QualityObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QualityObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..aI(4, _omitFieldNames ? '' : 'scaler')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QualityObject copyWith(void Function(QualityObject) updates) =>
      super.copyWith((message) => updates(message as QualityObject))
          as QualityObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QualityObject create() => QualityObject._();
  @$core.override
  QualityObject createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QualityObject getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QualityObject>(create);
  static QualityObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get scaler => $_getIZ(3);
  @$pb.TagNumber(4)
  set scaler($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScaler() => $_has(3);
  @$pb.TagNumber(4)
  void clearScaler() => $_clearField(4);
}

class UpdateQualityObjectRequest extends $pb.GeneratedMessage {
  factory UpdateQualityObjectRequest({
    $core.double? value,
    $core.int? scaler,
    $core.String? datasource,
  }) {
    final result = create();
    if (value != null) result.value = value;
    if (scaler != null) result.scaler = scaler;
    if (datasource != null) result.datasource = datasource;
    return result;
  }

  UpdateQualityObjectRequest._();

  factory UpdateQualityObjectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateQualityObjectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateQualityObjectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meter'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'value')
    ..aI(2, _omitFieldNames ? '' : 'scaler')
    ..aOS(3, _omitFieldNames ? '' : 'datasource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateQualityObjectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateQualityObjectRequest copyWith(
          void Function(UpdateQualityObjectRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateQualityObjectRequest))
          as UpdateQualityObjectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateQualityObjectRequest create() => UpdateQualityObjectRequest._();
  @$core.override
  UpdateQualityObjectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateQualityObjectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateQualityObjectRequest>(create);
  static UpdateQualityObjectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get scaler => $_getIZ(1);
  @$pb.TagNumber(2)
  set scaler($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScaler() => $_has(1);
  @$pb.TagNumber(2)
  void clearScaler() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get datasource => $_getSZ(2);
  @$pb.TagNumber(3)
  set datasource($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDatasource() => $_has(2);
  @$pb.TagNumber(3)
  void clearDatasource() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
