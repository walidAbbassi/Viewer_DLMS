// This is a generated file - do not edit.
//
// Generated from manual_dlms.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use cosemGetRequestDescriptor instead')
const CosemGetRequest$json = {
  '1': 'CosemGetRequest',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
  ],
};

/// Descriptor for `CosemGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cosemGetRequestDescriptor = $convert.base64Decode(
    'Cg9Db3NlbUdldFJlcXVlc3QSGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2JpcxgCIA'
    'EoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZQ==');

@$core.Deprecated('Use cosemSetRequestDescriptor instead')
const CosemSetRequest$json = {
  '1': 'CosemSetRequest',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'input_data', '3': 4, '4': 1, '5': 9, '10': 'inputData'},
  ],
};

/// Descriptor for `CosemSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cosemSetRequestDescriptor = $convert.base64Decode(
    'Cg9Db3NlbVNldFJlcXVlc3QSGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2JpcxgCIA'
    'EoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZRIdCgppbnB1dF9kYXRhGAQg'
    'ASgJUglpbnB1dERhdGE=');

@$core.Deprecated('Use cosemActionRequestDescriptor instead')
const CosemActionRequest$json = {
  '1': 'CosemActionRequest',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'input_data', '3': 4, '4': 1, '5': 9, '10': 'inputData'},
  ],
};

/// Descriptor for `CosemActionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cosemActionRequestDescriptor = $convert.base64Decode(
    'ChJDb3NlbUFjdGlvblJlcXVlc3QSGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2Jpcx'
    'gCIAEoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZRIdCgppbnB1dF9kYXRh'
    'GAQgASgJUglpbnB1dERhdGE=');

@$core.Deprecated('Use withListGetItemDescriptor instead')
const WithListGetItem$json = {
  '1': 'WithListGetItem',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
  ],
};

/// Descriptor for `WithListGetItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListGetItemDescriptor = $convert.base64Decode(
    'Cg9XaXRoTGlzdEdldEl0ZW0SGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2JpcxgCIA'
    'EoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZQ==');

@$core.Deprecated('Use withListSetItemDescriptor instead')
const WithListSetItem$json = {
  '1': 'WithListSetItem',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'input_data', '3': 4, '4': 1, '5': 9, '10': 'inputData'},
  ],
};

/// Descriptor for `WithListSetItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListSetItemDescriptor = $convert.base64Decode(
    'Cg9XaXRoTGlzdFNldEl0ZW0SGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2JpcxgCIA'
    'EoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZRIdCgppbnB1dF9kYXRhGAQg'
    'ASgJUglpbnB1dERhdGE=');

@$core.Deprecated('Use withListActionItemDescriptor instead')
const WithListActionItem$json = {
  '1': 'WithListActionItem',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis', '3': 2, '4': 1, '5': 9, '10': 'obis'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'input_data', '3': 4, '4': 1, '5': 9, '10': 'inputData'},
  ],
};

/// Descriptor for `WithListActionItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListActionItemDescriptor = $convert.base64Decode(
    'ChJXaXRoTGlzdEFjdGlvbkl0ZW0SGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSEgoEb2Jpcx'
    'gCIAEoCVIEb2JpcxIcCglhdHRyaWJ1dGUYAyABKAVSCWF0dHJpYnV0ZRIdCgppbnB1dF9kYXRh'
    'GAQgASgJUglpbnB1dERhdGE=');

@$core.Deprecated('Use withListGetRequestDescriptor instead')
const WithListGetRequest$json = {
  '1': 'WithListGetRequest',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.manual_dlms.WithListGetItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `WithListGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListGetRequestDescriptor = $convert.base64Decode(
    'ChJXaXRoTGlzdEdldFJlcXVlc3QSMgoFaXRlbXMYASADKAsyHC5tYW51YWxfZGxtcy5XaXRoTG'
    'lzdEdldEl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use withListSetRequestDescriptor instead')
const WithListSetRequest$json = {
  '1': 'WithListSetRequest',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.manual_dlms.WithListSetItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `WithListSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListSetRequestDescriptor = $convert.base64Decode(
    'ChJXaXRoTGlzdFNldFJlcXVlc3QSMgoFaXRlbXMYASADKAsyHC5tYW51YWxfZGxtcy5XaXRoTG'
    'lzdFNldEl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use withListActionRequestDescriptor instead')
const WithListActionRequest$json = {
  '1': 'WithListActionRequest',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.manual_dlms.WithListActionItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `WithListActionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListActionRequestDescriptor = $convert.base64Decode(
    'ChVXaXRoTGlzdEFjdGlvblJlcXVlc3QSNQoFaXRlbXMYASADKAsyHy5tYW51YWxfZGxtcy5XaX'
    'RoTGlzdEFjdGlvbkl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use encodeRequestDescriptor instead')
const EncodeRequest$json = {
  '1': 'EncodeRequest',
  '2': [
    {'1': 'xml_input', '3': 1, '4': 1, '5': 9, '10': 'xmlInput'},
  ],
};

/// Descriptor for `EncodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encodeRequestDescriptor = $convert.base64Decode(
    'Cg1FbmNvZGVSZXF1ZXN0EhsKCXhtbF9pbnB1dBgBIAEoCVIIeG1sSW5wdXQ=');

@$core.Deprecated('Use decodeRequestDescriptor instead')
const DecodeRequest$json = {
  '1': 'DecodeRequest',
  '2': [
    {'1': 'hex_input', '3': 1, '4': 1, '5': 9, '10': 'hexInput'},
  ],
};

/// Descriptor for `DecodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRequestDescriptor = $convert.base64Decode(
    'Cg1EZWNvZGVSZXF1ZXN0EhsKCWhleF9pbnB1dBgBIAEoCVIIaGV4SW5wdXQ=');

@$core.Deprecated('Use sendRawFrameRequestDescriptor instead')
const SendRawFrameRequest$json = {
  '1': 'SendRawFrameRequest',
  '2': [
    {'1': 'hex_frame', '3': 1, '4': 1, '5': 9, '10': 'hexFrame'},
  ],
};

/// Descriptor for `SendRawFrameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRawFrameRequestDescriptor =
    $convert.base64Decode(
        'ChNTZW5kUmF3RnJhbWVSZXF1ZXN0EhsKCWhleF9mcmFtZRgBIAEoCVIIaGV4RnJhbWU=');

@$core.Deprecated('Use manualDlmsResultDescriptor instead')
const ManualDlmsResult$json = {
  '1': 'ManualDlmsResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'xdr', '3': 2, '4': 1, '5': 9, '10': 'xdr'},
    {'1': 'xml', '3': 3, '4': 1, '5': 9, '10': 'xml'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'error_code', '3': 5, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `ManualDlmsResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List manualDlmsResultDescriptor = $convert.base64Decode(
    'ChBNYW51YWxEbG1zUmVzdWx0EhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSEAoDeGRyGAIgAS'
    'gJUgN4ZHISEAoDeG1sGAMgASgJUgN4bWwSFAoFZXJyb3IYBCABKAlSBWVycm9yEh0KCmVycm9y'
    'X2NvZGUYBSABKAVSCWVycm9yQ29kZQ==');

@$core.Deprecated('Use withListResultDescriptor instead')
const WithListResult$json = {
  '1': 'WithListResult',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.manual_dlms.ManualDlmsResult',
      '10': 'items'
    },
    {'1': 'global_success', '3': 2, '4': 1, '5': 8, '10': 'globalSuccess'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `WithListResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withListResultDescriptor = $convert.base64Decode(
    'Cg5XaXRoTGlzdFJlc3VsdBIzCgVpdGVtcxgBIAMoCzIdLm1hbnVhbF9kbG1zLk1hbnVhbERsbX'
    'NSZXN1bHRSBWl0ZW1zEiUKDmdsb2JhbF9zdWNjZXNzGAIgASgIUg1nbG9iYWxTdWNjZXNzEhQK'
    'BWVycm9yGAMgASgJUgVlcnJvcg==');

@$core.Deprecated('Use codecResultDescriptor instead')
const CodecResult$json = {
  '1': 'CodecResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'output', '3': 2, '4': 1, '5': 9, '10': 'output'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `CodecResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codecResultDescriptor = $convert.base64Decode(
    'CgtDb2RlY1Jlc3VsdBIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhYKBm91dHB1dBgCIAEoCV'
    'IGb3V0cHV0EhQKBWVycm9yGAMgASgJUgVlcnJvcg==');
