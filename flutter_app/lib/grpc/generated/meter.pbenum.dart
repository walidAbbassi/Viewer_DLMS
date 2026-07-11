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

import 'package:protobuf/protobuf.dart' as $pb;

/// Request/Response to get or set a single load profile parameter.
/// We support: MAX_RECORD, RECORD_NUMBER, CAPTURE_PERIOD.
class LoadProfileParam extends $pb.ProtobufEnum {
  static const LoadProfileParam LOAD_PROFILE_PARAM_UNSPECIFIED =
      LoadProfileParam._(
          0, _omitEnumNames ? '' : 'LOAD_PROFILE_PARAM_UNSPECIFIED');
  static const LoadProfileParam MAX_RECORD =
      LoadProfileParam._(1, _omitEnumNames ? '' : 'MAX_RECORD');
  static const LoadProfileParam RECORD_NUMBER =
      LoadProfileParam._(2, _omitEnumNames ? '' : 'RECORD_NUMBER');
  static const LoadProfileParam CAPTURE_PERIOD =
      LoadProfileParam._(3, _omitEnumNames ? '' : 'CAPTURE_PERIOD');

  static const $core.List<LoadProfileParam> values = <LoadProfileParam>[
    LOAD_PROFILE_PARAM_UNSPECIFIED,
    MAX_RECORD,
    RECORD_NUMBER,
    CAPTURE_PERIOD,
  ];

  static final $core.List<LoadProfileParam?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static LoadProfileParam? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LoadProfileParam._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
