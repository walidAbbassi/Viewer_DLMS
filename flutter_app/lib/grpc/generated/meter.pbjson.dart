// This is a generated file - do not edit.
//
// Generated from meter.proto.

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

@$core.Deprecated('Use loadProfileParamDescriptor instead')
const LoadProfileParam$json = {
  '1': 'LoadProfileParam',
  '2': [
    {'1': 'LOAD_PROFILE_PARAM_UNSPECIFIED', '2': 0},
    {'1': 'MAX_RECORD', '2': 1},
    {'1': 'RECORD_NUMBER', '2': 2},
    {'1': 'CAPTURE_PERIOD', '2': 3},
  ],
};

/// Descriptor for `LoadProfileParam`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loadProfileParamDescriptor = $convert.base64Decode(
    'ChBMb2FkUHJvZmlsZVBhcmFtEiIKHkxPQURfUFJPRklMRV9QQVJBTV9VTlNQRUNJRklFRBAAEg'
    '4KCk1BWF9SRUNPUkQQARIRCg1SRUNPUkRfTlVNQkVSEAISEgoOQ0FQVFVSRV9QRVJJT0QQAw==');

@$core.Deprecated('Use translateDataItemRequestDescriptor instead')
const TranslateDataItemRequest$json = {
  '1': 'TranslateDataItemRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
    {'1': 'is_xdr_input', '3': 2, '4': 1, '5': 8, '10': 'isXdrInput'},
  ],
};

/// Descriptor for `TranslateDataItemRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateDataItemRequestDescriptor =
    $convert.base64Decode(
        'ChhUcmFuc2xhdGVEYXRhSXRlbVJlcXVlc3QSEgoEZGF0YRgBIAEoCVIEZGF0YRIgCgxpc194ZH'
        'JfaW5wdXQYAiABKAhSCmlzWGRySW5wdXQ=');

@$core.Deprecated('Use translateDataRequestDescriptor instead')
const TranslateDataRequest$json = {
  '1': 'TranslateDataRequest',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.TranslateDataItemRequest',
      '10': 'requests'
    },
  ],
};

/// Descriptor for `TranslateDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateDataRequestDescriptor = $convert.base64Decode(
    'ChRUcmFuc2xhdGVEYXRhUmVxdWVzdBI7CghyZXF1ZXN0cxgBIAMoCzIfLm1ldGVyLlRyYW5zbG'
    'F0ZURhdGFJdGVtUmVxdWVzdFIIcmVxdWVzdHM=');

@$core.Deprecated('Use translateDataItemResponseDescriptor instead')
const TranslateDataItemResponse$json = {
  '1': 'TranslateDataItemResponse',
  '2': [
    {'1': 'input', '3': 1, '4': 1, '5': 9, '10': 'input'},
    {'1': 'output', '3': 2, '4': 1, '5': 9, '10': 'output'},
    {'1': 'is_xdr_input', '3': 3, '4': 1, '5': 8, '10': 'isXdrInput'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `TranslateDataItemResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateDataItemResponseDescriptor = $convert.base64Decode(
    'ChlUcmFuc2xhdGVEYXRhSXRlbVJlc3BvbnNlEhQKBWlucHV0GAEgASgJUgVpbnB1dBIWCgZvdX'
    'RwdXQYAiABKAlSBm91dHB1dBIgCgxpc194ZHJfaW5wdXQYAyABKAhSCmlzWGRySW5wdXQSGAoH'
    'c3VjY2VzcxgEIAEoCFIHc3VjY2VzcxIUCgVlcnJvchgFIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use translateDataResponseDescriptor instead')
const TranslateDataResponse$json = {
  '1': 'TranslateDataResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.TranslateDataItemResponse',
      '10': 'items'
    },
  ],
};

/// Descriptor for `TranslateDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List translateDataResponseDescriptor = $convert.base64Decode(
    'ChVUcmFuc2xhdGVEYXRhUmVzcG9uc2USNgoFaXRlbXMYASADKAsyIC5tZXRlci5UcmFuc2xhdG'
    'VEYXRhSXRlbVJlc3BvbnNlUgVpdGVtcw==');

@$core.Deprecated('Use dlmsTranslateRequestDescriptor instead')
const DlmsTranslateRequest$json = {
  '1': 'DlmsTranslateRequest',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
    {'1': 'isxml', '3': 2, '4': 1, '5': 8, '10': 'isxml'},
  ],
};

/// Descriptor for `DlmsTranslateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dlmsTranslateRequestDescriptor = $convert.base64Decode(
    'ChREbG1zVHJhbnNsYXRlUmVxdWVzdBISCgRkYXRhGAEgASgJUgRkYXRhEhQKBWlzeG1sGAIgAS'
    'gIUgVpc3htbA==');

@$core.Deprecated('Use getRequestDescriptor instead')
const GetRequest$json = {
  '1': 'GetRequest',
  '2': [
    {'1': 'class_', '3': 1, '4': 1, '5': 5, '10': 'class'},
    {'1': 'obiscode', '3': 2, '4': 1, '5': 9, '10': 'obiscode'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {
      '1': 'datetime_selector',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.meter.DateTimeRangeSelector',
      '9': 0,
      '10': 'datetimeSelector'
    },
    {
      '1': 'entry_selector',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.meter.EntrySelector',
      '9': 0,
      '10': 'entrySelector'
    },
  ],
  '8': [
    {'1': 'access_selector'},
  ],
};

/// Descriptor for `GetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRequestDescriptor = $convert.base64Decode(
    'CgpHZXRSZXF1ZXN0EhUKBmNsYXNzXxgBIAEoBVIFY2xhc3MSGgoIb2Jpc2NvZGUYAiABKAlSCG'
    '9iaXNjb2RlEhwKCWF0dHJpYnV0ZRgDIAEoBVIJYXR0cmlidXRlEksKEWRhdGV0aW1lX3NlbGVj'
    'dG9yGAQgASgLMhwubWV0ZXIuRGF0ZVRpbWVSYW5nZVNlbGVjdG9ySABSEGRhdGV0aW1lU2VsZW'
    'N0b3ISPQoOZW50cnlfc2VsZWN0b3IYBSABKAsyFC5tZXRlci5FbnRyeVNlbGVjdG9ySABSDWVu'
    'dHJ5U2VsZWN0b3JCEQoPYWNjZXNzX3NlbGVjdG9y');

@$core.Deprecated('Use dateTimeRangeSelectorDescriptor instead')
const DateTimeRangeSelector$json = {
  '1': 'DateTimeRangeSelector',
  '2': [
    {
      '1': 'start',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'start'
    },
    {
      '1': 'end',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'end'
    },
  ],
};

/// Descriptor for `DateTimeRangeSelector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateTimeRangeSelectorDescriptor = $convert.base64Decode(
    'ChVEYXRlVGltZVJhbmdlU2VsZWN0b3ISMAoFc3RhcnQYASABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgVzdGFydBIsCgNlbmQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0'
    'YW1wUgNlbmQ=');

@$core.Deprecated('Use entrySelectorDescriptor instead')
const EntrySelector$json = {
  '1': 'EntrySelector',
  '2': [
    {'1': 'entry_from', '3': 1, '4': 1, '5': 5, '10': 'entryFrom'},
    {'1': 'entry_to', '3': 2, '4': 1, '5': 5, '10': 'entryTo'},
    {'1': 'selected_from', '3': 3, '4': 1, '5': 5, '10': 'selectedFrom'},
    {'1': 'selected_to', '3': 4, '4': 1, '5': 5, '10': 'selectedTo'},
  ],
};

/// Descriptor for `EntrySelector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entrySelectorDescriptor = $convert.base64Decode(
    'Cg1FbnRyeVNlbGVjdG9yEh0KCmVudHJ5X2Zyb20YASABKAVSCWVudHJ5RnJvbRIZCghlbnRyeV'
    '90bxgCIAEoBVIHZW50cnlUbxIjCg1zZWxlY3RlZF9mcm9tGAMgASgFUgxzZWxlY3RlZEZyb20S'
    'HwoLc2VsZWN0ZWRfdG8YBCABKAVSCnNlbGVjdGVkVG8=');

@$core.Deprecated('Use setRequestDescriptor instead')
const SetRequest$json = {
  '1': 'SetRequest',
  '2': [
    {'1': 'class_', '3': 1, '4': 1, '5': 5, '10': 'class'},
    {'1': 'obiscode', '3': 2, '4': 1, '5': 9, '10': 'obiscode'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'payload', '3': 4, '4': 1, '5': 9, '10': 'payload'},
  ],
};

/// Descriptor for `SetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRequestDescriptor = $convert.base64Decode(
    'CgpTZXRSZXF1ZXN0EhUKBmNsYXNzXxgBIAEoBVIFY2xhc3MSGgoIb2Jpc2NvZGUYAiABKAlSCG'
    '9iaXNjb2RlEhwKCWF0dHJpYnV0ZRgDIAEoBVIJYXR0cmlidXRlEhgKB3BheWxvYWQYBCABKAlS'
    'B3BheWxvYWQ=');

@$core.Deprecated('Use actionRequestDescriptor instead')
const ActionRequest$json = {
  '1': 'ActionRequest',
  '2': [
    {'1': 'class_', '3': 1, '4': 1, '5': 5, '10': 'class'},
    {'1': 'obiscode', '3': 2, '4': 1, '5': 9, '10': 'obiscode'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'payload', '3': 4, '4': 1, '5': 9, '10': 'payload'},
  ],
};

/// Descriptor for `ActionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionRequestDescriptor = $convert.base64Decode(
    'Cg1BY3Rpb25SZXF1ZXN0EhUKBmNsYXNzXxgBIAEoBVIFY2xhc3MSGgoIb2Jpc2NvZGUYAiABKA'
    'lSCG9iaXNjb2RlEhwKCWF0dHJpYnV0ZRgDIAEoBVIJYXR0cmlidXRlEhgKB3BheWxvYWQYBCAB'
    'KAlSB3BheWxvYWQ=');

@$core.Deprecated('Use abstractFrameRequestDescriptor instead')
const AbstractFrameRequest$json = {
  '1': 'AbstractFrameRequest',
  '2': [
    {
      '1': 'get_request',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.GetRequest',
      '9': 0,
      '10': 'getRequest'
    },
    {
      '1': 'set_request',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.SetRequest',
      '9': 0,
      '10': 'setRequest'
    },
    {
      '1': 'action_request',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meter.ActionRequest',
      '9': 0,
      '10': 'actionRequest'
    },
  ],
  '8': [
    {'1': 'request'},
  ],
};

/// Descriptor for `AbstractFrameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abstractFrameRequestDescriptor = $convert.base64Decode(
    'ChRBYnN0cmFjdEZyYW1lUmVxdWVzdBI0CgtnZXRfcmVxdWVzdBgBIAEoCzIRLm1ldGVyLkdldF'
    'JlcXVlc3RIAFIKZ2V0UmVxdWVzdBI0CgtzZXRfcmVxdWVzdBgCIAEoCzIRLm1ldGVyLlNldFJl'
    'cXVlc3RIAFIKc2V0UmVxdWVzdBI9Cg5hY3Rpb25fcmVxdWVzdBgDIAEoCzIULm1ldGVyLkFjdG'
    'lvblJlcXVlc3RIAFINYWN0aW9uUmVxdWVzdEIJCgdyZXF1ZXN0');

@$core.Deprecated('Use applicationResponseDescriptor instead')
const ApplicationResponse$json = {
  '1': 'ApplicationResponse',
  '2': [
    {
      '1': 'request',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.AbstractFrameRequest',
      '10': 'request'
    },
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'value'
    },
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
    {'1': 'status_code', '3': 4, '4': 1, '5': 5, '10': 'statusCode'},
  ],
};

/// Descriptor for `ApplicationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applicationResponseDescriptor = $convert.base64Decode(
    'ChNBcHBsaWNhdGlvblJlc3BvbnNlEjUKB3JlcXVlc3QYASABKAsyGy5tZXRlci5BYnN0cmFjdE'
    'ZyYW1lUmVxdWVzdFIHcmVxdWVzdBIqCgV2YWx1ZRgCIAEoCzIULmdvb2dsZS5wcm90b2J1Zi5B'
    'bnlSBXZhbHVlEhQKBWVycm9yGAMgASgJUgVlcnJvchIfCgtzdGF0dXNfY29kZRgEIAEoBVIKc3'
    'RhdHVzQ29kZQ==');

@$core.Deprecated('Use frameExecutionItemDescriptor instead')
const FrameExecutionItem$json = {
  '1': 'FrameExecutionItem',
  '2': [
    {
      '1': 'request',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.AbstractFrameRequest',
      '10': 'request'
    },
    {'1': 'xml_xdr', '3': 2, '4': 1, '5': 9, '10': 'xmlXdr'},
    {'1': 'xdr', '3': 3, '4': 1, '5': 9, '10': 'xdr'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FrameExecutionItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List frameExecutionItemDescriptor = $convert.base64Decode(
    'ChJGcmFtZUV4ZWN1dGlvbkl0ZW0SNQoHcmVxdWVzdBgBIAEoCzIbLm1ldGVyLkFic3RyYWN0Rn'
    'JhbWVSZXF1ZXN0UgdyZXF1ZXN0EhcKB3htbF94ZHIYAiABKAlSBnhtbFhkchIQCgN4ZHIYAyAB'
    'KAlSA3hkchIYCgdzdWNjZXNzGAQgASgIUgdzdWNjZXNzEhQKBWVycm9yGAUgASgJUgVlcnJvcg'
    '==');

@$core.Deprecated('Use frameExecutionListDescriptor instead')
const FrameExecutionList$json = {
  '1': 'FrameExecutionList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.FrameExecutionItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `FrameExecutionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List frameExecutionListDescriptor = $convert.base64Decode(
    'ChJGcmFtZUV4ZWN1dGlvbkxpc3QSLwoFaXRlbXMYASADKAsyGS5tZXRlci5GcmFtZUV4ZWN1dG'
    'lvbkl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use boolValueDescriptor instead')
const BoolValue$json = {
  '1': 'BoolValue',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `BoolValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boolValueDescriptor =
    $convert.base64Decode('CglCb29sVmFsdWUSFAoFdmFsdWUYASABKAhSBXZhbHVl');

@$core.Deprecated('Use int32ValueDescriptor instead')
const Int32Value$json = {
  '1': 'Int32Value',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `Int32Value`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List int32ValueDescriptor =
    $convert.base64Decode('CgpJbnQzMlZhbHVlEhQKBXZhbHVlGAEgASgFUgV2YWx1ZQ==');

@$core.Deprecated('Use stringValueDescriptor instead')
const StringValue$json = {
  '1': 'StringValue',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `StringValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringValueDescriptor =
    $convert.base64Decode('CgtTdHJpbmdWYWx1ZRIUCgV2YWx1ZRgBIAEoCVIFdmFsdWU=');

@$core.Deprecated('Use stringListDescriptor instead')
const StringList$json = {
  '1': 'StringList',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 9, '10': 'items'},
  ],
};

/// Descriptor for `StringList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringListDescriptor =
    $convert.base64Decode('CgpTdHJpbmdMaXN0EhQKBWl0ZW1zGAEgAygJUgVpdGVtcw==');

@$core.Deprecated('Use getRequestListDescriptor instead')
const GetRequestList$json = {
  '1': 'GetRequestList',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.GetRequest',
      '10': 'requests'
    },
    {'1': 'with_list', '3': 2, '4': 1, '5': 8, '10': 'withList'},
  ],
};

/// Descriptor for `GetRequestList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRequestListDescriptor = $convert.base64Decode(
    'Cg5HZXRSZXF1ZXN0TGlzdBItCghyZXF1ZXN0cxgBIAMoCzIRLm1ldGVyLkdldFJlcXVlc3RSCH'
    'JlcXVlc3RzEhsKCXdpdGhfbGlzdBgCIAEoCFIId2l0aExpc3Q=');

@$core.Deprecated('Use setRequestListDescriptor instead')
const SetRequestList$json = {
  '1': 'SetRequestList',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.SetRequest',
      '10': 'requests'
    },
    {'1': 'with_list', '3': 2, '4': 1, '5': 8, '10': 'withList'},
  ],
};

/// Descriptor for `SetRequestList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRequestListDescriptor = $convert.base64Decode(
    'Cg5TZXRSZXF1ZXN0TGlzdBItCghyZXF1ZXN0cxgBIAMoCzIRLm1ldGVyLlNldFJlcXVlc3RSCH'
    'JlcXVlc3RzEhsKCXdpdGhfbGlzdBgCIAEoCFIId2l0aExpc3Q=');

@$core.Deprecated('Use actionRequestListDescriptor instead')
const ActionRequestList$json = {
  '1': 'ActionRequestList',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.ActionRequest',
      '10': 'requests'
    },
    {'1': 'with_list', '3': 2, '4': 1, '5': 8, '10': 'withList'},
  ],
};

/// Descriptor for `ActionRequestList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionRequestListDescriptor = $convert.base64Decode(
    'ChFBY3Rpb25SZXF1ZXN0TGlzdBIwCghyZXF1ZXN0cxgBIAMoCzIULm1ldGVyLkFjdGlvblJlcX'
    'Vlc3RSCHJlcXVlc3RzEhsKCXdpdGhfbGlzdBgCIAEoCFIId2l0aExpc3Q=');

@$core.Deprecated('Use applicationResponseListDescriptor instead')
const ApplicationResponseList$json = {
  '1': 'ApplicationResponseList',
  '2': [
    {
      '1': 'responses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.ApplicationResponse',
      '10': 'responses'
    },
  ],
};

/// Descriptor for `ApplicationResponseList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applicationResponseListDescriptor =
    $convert.base64Decode(
        'ChdBcHBsaWNhdGlvblJlc3BvbnNlTGlzdBI4CglyZXNwb25zZXMYASADKAsyGi5tZXRlci5BcH'
        'BsaWNhdGlvblJlc3BvbnNlUglyZXNwb25zZXM=');

@$core.Deprecated('Use initMeterContextRequestDescriptor instead')
const InitMeterContextRequest$json = {
  '1': 'InitMeterContextRequest',
  '2': [
    {'1': 'modulename', '3': 1, '4': 1, '5': 9, '10': 'modulename'},
  ],
};

/// Descriptor for `InitMeterContextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initMeterContextRequestDescriptor =
    $convert.base64Decode(
        'ChdJbml0TWV0ZXJDb250ZXh0UmVxdWVzdBIeCgptb2R1bGVuYW1lGAEgASgJUgptb2R1bGVuYW'
        '1l');

@$core.Deprecated('Use initiateTransferRequestDescriptor instead')
const InitiateTransferRequest$json = {
  '1': 'InitiateTransferRequest',
  '2': [
    {'1': 'path_file', '3': 1, '4': 1, '5': 9, '10': 'pathFile'},
    {'1': 'imageId', '3': 2, '4': 1, '5': 9, '10': 'imageId'},
  ],
};

/// Descriptor for `InitiateTransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateTransferRequestDescriptor =
    $convert.base64Decode(
        'ChdJbml0aWF0ZVRyYW5zZmVyUmVxdWVzdBIbCglwYXRoX2ZpbGUYASABKAlSCHBhdGhGaWxlEh'
        'gKB2ltYWdlSWQYAiABKAlSB2ltYWdlSWQ=');

@$core.Deprecated('Use transferFileRequestDescriptor instead')
const TransferFileRequest$json = {
  '1': 'TransferFileRequest',
  '2': [
    {'1': 'path_file', '3': 1, '4': 1, '5': 9, '10': 'pathFile'},
    {'1': 'block_size', '3': 2, '4': 1, '5': 5, '10': 'blockSize'},
  ],
};

/// Descriptor for `TransferFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferFileRequestDescriptor = $convert.base64Decode(
    'ChNUcmFuc2ZlckZpbGVSZXF1ZXN0EhsKCXBhdGhfZmlsZRgBIAEoCVIIcGF0aEZpbGUSHQoKYm'
    'xvY2tfc2l6ZRgCIAEoBVIJYmxvY2tTaXpl');

@$core.Deprecated('Use transferUpdateDescriptor instead')
const TransferUpdate$json = {
  '1': 'TransferUpdate',
  '2': [
    {'1': 'block_number', '3': 1, '4': 1, '5': 5, '10': 'blockNumber'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `TransferUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferUpdateDescriptor = $convert.base64Decode(
    'Cg5UcmFuc2ZlclVwZGF0ZRIhCgxibG9ja19udW1iZXIYASABKAVSC2Jsb2NrTnVtYmVyEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use verifyTransfertRequestDescriptor instead')
const VerifyTransfertRequest$json = {
  '1': 'VerifyTransfertRequest',
  '2': [
    {'1': 'path_file', '3': 1, '4': 1, '5': 9, '10': 'pathFile'},
    {'1': 'block_size', '3': 2, '4': 1, '5': 5, '10': 'blockSize'},
  ],
};

/// Descriptor for `VerifyTransfertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTransfertRequestDescriptor =
    $convert.base64Decode(
        'ChZWZXJpZnlUcmFuc2ZlcnRSZXF1ZXN0EhsKCXBhdGhfZmlsZRgBIAEoCVIIcGF0aEZpbGUSHQ'
        'oKYmxvY2tfc2l6ZRgCIAEoBVIJYmxvY2tTaXpl');

@$core.Deprecated('Use verifyTransfertResponseDescriptor instead')
const VerifyTransfertResponse$json = {
  '1': 'VerifyTransfertResponse',
  '2': [
    {'1': 'chunks_ok', '3': 1, '4': 3, '5': 8, '10': 'chunksOk'},
  ],
};

/// Descriptor for `VerifyTransfertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTransfertResponseDescriptor =
    $convert.base64Decode(
        'ChdWZXJpZnlUcmFuc2ZlcnRSZXNwb25zZRIbCgljaHVua3Nfb2sYASADKAhSCGNodW5rc09r');

@$core.Deprecated('Use resendMissingChunksRequestDescriptor instead')
const ResendMissingChunksRequest$json = {
  '1': 'ResendMissingChunksRequest',
  '2': [
    {'1': 'path_file', '3': 1, '4': 1, '5': 9, '10': 'pathFile'},
    {'1': 'block_size', '3': 2, '4': 1, '5': 5, '10': 'blockSize'},
  ],
};

/// Descriptor for `ResendMissingChunksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resendMissingChunksRequestDescriptor =
    $convert.base64Decode(
        'ChpSZXNlbmRNaXNzaW5nQ2h1bmtzUmVxdWVzdBIbCglwYXRoX2ZpbGUYASABKAlSCHBhdGhGaW'
        'xlEh0KCmJsb2NrX3NpemUYAiABKAVSCWJsb2NrU2l6ZQ==');

@$core.Deprecated('Use resumeTransferRequestDescriptor instead')
const ResumeTransferRequest$json = {
  '1': 'ResumeTransferRequest',
  '2': [
    {'1': 'path_file', '3': 1, '4': 1, '5': 9, '10': 'pathFile'},
    {'1': 'block_size', '3': 2, '4': 1, '5': 5, '10': 'blockSize'},
    {'1': 'start_block', '3': 3, '4': 1, '5': 5, '10': 'startBlock'},
  ],
};

/// Descriptor for `ResumeTransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resumeTransferRequestDescriptor = $convert.base64Decode(
    'ChVSZXN1bWVUcmFuc2ZlclJlcXVlc3QSGwoJcGF0aF9maWxlGAEgASgJUghwYXRoRmlsZRIdCg'
    'pibG9ja19zaXplGAIgASgFUglibG9ja1NpemUSHwoLc3RhcnRfYmxvY2sYAyABKAVSCnN0YXJ0'
    'QmxvY2s=');

@$core.Deprecated('Use activateFirmwareResponseDescriptor instead')
const ActivateFirmwareResponse$json = {
  '1': 'ActivateFirmwareResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ActivateFirmwareResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activateFirmwareResponseDescriptor =
    $convert.base64Decode(
        'ChhBY3RpdmF0ZUZpcm13YXJlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCg'
        'dtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use getDatamodelObjectsRequestDescriptor instead')
const GetDatamodelObjectsRequest$json = {
  '1': 'GetDatamodelObjectsRequest',
  '2': [
    {'1': 'withAttributes', '3': 1, '4': 1, '5': 8, '10': 'withAttributes'},
  ],
};

/// Descriptor for `GetDatamodelObjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDatamodelObjectsRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXREYXRhbW9kZWxPYmplY3RzUmVxdWVzdBImCg53aXRoQXR0cmlidXRlcxgBIAEoCFIOd2'
        'l0aEF0dHJpYnV0ZXM=');

@$core.Deprecated('Use pushObjectRestrictionDateRangeDescriptor instead')
const PushObjectRestrictionDateRange$json = {
  '1': 'PushObjectRestrictionDateRange',
  '2': [
    {'1': 'from_date', '3': 1, '4': 1, '5': 9, '10': 'fromDate'},
    {'1': 'to_date', '3': 2, '4': 1, '5': 9, '10': 'toDate'},
  ],
};

/// Descriptor for `PushObjectRestrictionDateRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushObjectRestrictionDateRangeDescriptor =
    $convert.base64Decode(
        'Ch5QdXNoT2JqZWN0UmVzdHJpY3Rpb25EYXRlUmFuZ2USGwoJZnJvbV9kYXRlGAEgASgJUghmcm'
        '9tRGF0ZRIXCgd0b19kYXRlGAIgASgJUgZ0b0RhdGU=');

@$core.Deprecated('Use pushObjectRestrictionEntryRangeDescriptor instead')
const PushObjectRestrictionEntryRange$json = {
  '1': 'PushObjectRestrictionEntryRange',
  '2': [
    {'1': 'from_entry', '3': 1, '4': 1, '5': 5, '10': 'fromEntry'},
    {'1': 'to_entry', '3': 2, '4': 1, '5': 5, '10': 'toEntry'},
  ],
};

/// Descriptor for `PushObjectRestrictionEntryRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushObjectRestrictionEntryRangeDescriptor =
    $convert.base64Decode(
        'Ch9QdXNoT2JqZWN0UmVzdHJpY3Rpb25FbnRyeVJhbmdlEh0KCmZyb21fZW50cnkYASABKAVSCW'
        'Zyb21FbnRyeRIZCgh0b19lbnRyeRgCIAEoBVIHdG9FbnRyeQ==');

@$core.Deprecated('Use pushObjectItemDescriptor instead')
const PushObjectItem$json = {
  '1': 'PushObjectItem',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'attribute_index', '3': 2, '4': 1, '5': 5, '10': 'attributeIndex'},
    {'1': 'logical_name', '3': 3, '4': 1, '5': 9, '10': 'logicalName'},
    {'1': 'object_name', '3': 4, '4': 1, '5': 9, '10': 'objectName'},
    {'1': 'data_index', '3': 5, '4': 1, '5': 5, '10': 'dataIndex'},
    {'1': 'restriction_type', '3': 6, '4': 1, '5': 5, '10': 'restrictionType'},
    {
      '1': 'date_range',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.meter.PushObjectRestrictionDateRange',
      '9': 0,
      '10': 'dateRange'
    },
    {
      '1': 'entry_range',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.meter.PushObjectRestrictionEntryRange',
      '9': 0,
      '10': 'entryRange'
    },
  ],
  '8': [
    {'1': 'restriction_value'},
  ],
};

/// Descriptor for `PushObjectItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushObjectItemDescriptor = $convert.base64Decode(
    'Cg5QdXNoT2JqZWN0SXRlbRIZCghjbGFzc19pZBgBIAEoBVIHY2xhc3NJZBInCg9hdHRyaWJ1dG'
    'VfaW5kZXgYAiABKAVSDmF0dHJpYnV0ZUluZGV4EiEKDGxvZ2ljYWxfbmFtZRgDIAEoCVILbG9n'
    'aWNhbE5hbWUSHwoLb2JqZWN0X25hbWUYBCABKAlSCm9iamVjdE5hbWUSHQoKZGF0YV9pbmRleB'
    'gFIAEoBVIJZGF0YUluZGV4EikKEHJlc3RyaWN0aW9uX3R5cGUYBiABKAVSD3Jlc3RyaWN0aW9u'
    'VHlwZRJGCgpkYXRlX3JhbmdlGAcgASgLMiUubWV0ZXIuUHVzaE9iamVjdFJlc3RyaWN0aW9uRG'
    'F0ZVJhbmdlSABSCWRhdGVSYW5nZRJJCgtlbnRyeV9yYW5nZRgIIAEoCzImLm1ldGVyLlB1c2hP'
    'YmplY3RSZXN0cmljdGlvbkVudHJ5UmFuZ2VIAFIKZW50cnlSYW5nZUITChFyZXN0cmljdGlvbl'
    '92YWx1ZQ==');

@$core.Deprecated('Use getPushObjectListRequestDescriptor instead')
const GetPushObjectListRequest$json = {
  '1': 'GetPushObjectListRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetPushObjectListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushObjectListRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRQdXNoT2JqZWN0TGlzdFJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIAEoCVIKZGF0YXNvdX'
        'JjZQ==');

@$core.Deprecated('Use getPushObjectListResponseDescriptor instead')
const GetPushObjectListResponse$json = {
  '1': 'GetPushObjectListResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.PushObjectItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `GetPushObjectListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushObjectListResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRQdXNoT2JqZWN0TGlzdFJlc3BvbnNlEisKBWl0ZW1zGAEgAygLMhUubWV0ZXIuUHVzaE'
        '9iamVjdEl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use setPushObjectListRequestDescriptor instead')
const SetPushObjectListRequest$json = {
  '1': 'SetPushObjectListRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {
      '1': 'items',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.PushObjectItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `SetPushObjectListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPushObjectListRequestDescriptor =
    $convert.base64Decode(
        'ChhTZXRQdXNoT2JqZWN0TGlzdFJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIAEoCVIKZGF0YXNvdX'
        'JjZRIrCgVpdGVtcxgCIAMoCzIVLm1ldGVyLlB1c2hPYmplY3RJdGVtUgVpdGVtcw==');

@$core.Deprecated('Use getRandomisationStartIntervalRequestDescriptor instead')
const GetRandomisationStartIntervalRequest$json = {
  '1': 'GetRandomisationStartIntervalRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetRandomisationStartIntervalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRandomisationStartIntervalRequestDescriptor =
    $convert.base64Decode(
        'CiRHZXRSYW5kb21pc2F0aW9uU3RhcnRJbnRlcnZhbFJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIA'
        'EoCVIKZGF0YXNvdXJjZQ==');

@$core.Deprecated('Use getRandomisationStartIntervalResponseDescriptor instead')
const GetRandomisationStartIntervalResponse$json = {
  '1': 'GetRandomisationStartIntervalResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 5, '10': 'result'},
  ],
};

/// Descriptor for `GetRandomisationStartIntervalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRandomisationStartIntervalResponseDescriptor =
    $convert.base64Decode(
        'CiVHZXRSYW5kb21pc2F0aW9uU3RhcnRJbnRlcnZhbFJlc3BvbnNlEhYKBnJlc3VsdBgBIAEoBV'
        'IGcmVzdWx0');

@$core.Deprecated('Use setRandomisationStartIntervalRequestDescriptor instead')
const SetRandomisationStartIntervalRequest$json = {
  '1': 'SetRandomisationStartIntervalRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `SetRandomisationStartIntervalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRandomisationStartIntervalRequestDescriptor =
    $convert.base64Decode(
        'CiRTZXRSYW5kb21pc2F0aW9uU3RhcnRJbnRlcnZhbFJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIA'
        'EoCVIKZGF0YXNvdXJjZRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU=');

@$core.Deprecated('Use getNumberOfRetriesRequestDescriptor instead')
const GetNumberOfRetriesRequest$json = {
  '1': 'GetNumberOfRetriesRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetNumberOfRetriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNumberOfRetriesRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXROdW1iZXJPZlJldHJpZXNSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
        'VyY2U=');

@$core.Deprecated('Use getNumberOfRetriesResponseDescriptor instead')
const GetNumberOfRetriesResponse$json = {
  '1': 'GetNumberOfRetriesResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 5, '10': 'result'},
  ],
};

/// Descriptor for `GetNumberOfRetriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNumberOfRetriesResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXROdW1iZXJPZlJldHJpZXNSZXNwb25zZRIWCgZyZXN1bHQYASABKAVSBnJlc3VsdA==');

@$core.Deprecated('Use setNumberOfRetriesRequestDescriptor instead')
const SetNumberOfRetriesRequest$json = {
  '1': 'SetNumberOfRetriesRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `SetNumberOfRetriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setNumberOfRetriesRequestDescriptor =
    $convert.base64Decode(
        'ChlTZXROdW1iZXJPZlJldHJpZXNSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
        'VyY2USFAoFdmFsdWUYAiABKAVSBXZhbHVl');

@$core.Deprecated('Use getRepetitionDelayRequestDescriptor instead')
const GetRepetitionDelayRequest$json = {
  '1': 'GetRepetitionDelayRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetRepetitionDelayRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRepetitionDelayRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRSZXBldGl0aW9uRGVsYXlSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
        'VyY2U=');

@$core.Deprecated('Use getRepetitionDelayResponseDescriptor instead')
const GetRepetitionDelayResponse$json = {
  '1': 'GetRepetitionDelayResponse',
  '2': [
    {'1': 'min', '3': 1, '4': 1, '5': 5, '10': 'min'},
    {'1': 'exponent', '3': 2, '4': 1, '5': 5, '10': 'exponent'},
    {'1': 'max', '3': 3, '4': 1, '5': 5, '10': 'max'},
  ],
};

/// Descriptor for `GetRepetitionDelayResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRepetitionDelayResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRSZXBldGl0aW9uRGVsYXlSZXNwb25zZRIQCgNtaW4YASABKAVSA21pbhIaCghleHBvbm'
        'VudBgCIAEoBVIIZXhwb25lbnQSEAoDbWF4GAMgASgFUgNtYXg=');

@$core.Deprecated('Use setRepetitionDelayRequestDescriptor instead')
const SetRepetitionDelayRequest$json = {
  '1': 'SetRepetitionDelayRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'min', '3': 2, '4': 1, '5': 5, '10': 'min'},
    {'1': 'exponent', '3': 3, '4': 1, '5': 5, '10': 'exponent'},
    {'1': 'max', '3': 4, '4': 1, '5': 5, '10': 'max'},
  ],
};

/// Descriptor for `SetRepetitionDelayRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRepetitionDelayRequestDescriptor = $convert.base64Decode(
    'ChlTZXRSZXBldGl0aW9uRGVsYXlSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
    'VyY2USEAoDbWluGAIgASgFUgNtaW4SGgoIZXhwb25lbnQYAyABKAVSCGV4cG9uZW50EhAKA21h'
    'eBgEIAEoBVIDbWF4');

@$core.Deprecated('Use getLastConfirmationDatetimeRequestDescriptor instead')
const GetLastConfirmationDatetimeRequest$json = {
  '1': 'GetLastConfirmationDatetimeRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetLastConfirmationDatetimeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLastConfirmationDatetimeRequestDescriptor =
    $convert.base64Decode(
        'CiJHZXRMYXN0Q29uZmlybWF0aW9uRGF0ZXRpbWVSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKA'
        'lSCmRhdGFzb3VyY2U=');

@$core.Deprecated('Use getLastConfirmationDatetimeResponseDescriptor instead')
const GetLastConfirmationDatetimeResponse$json = {
  '1': 'GetLastConfirmationDatetimeResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 9, '10': 'result'},
  ],
};

/// Descriptor for `GetLastConfirmationDatetimeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLastConfirmationDatetimeResponseDescriptor =
    $convert.base64Decode(
        'CiNHZXRMYXN0Q29uZmlybWF0aW9uRGF0ZXRpbWVSZXNwb25zZRIWCgZyZXN1bHQYASABKAlSBn'
        'Jlc3VsdA==');

@$core.Deprecated('Use setLastConfirmationDatetimeRequestDescriptor instead')
const SetLastConfirmationDatetimeRequest$json = {
  '1': 'SetLastConfirmationDatetimeRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SetLastConfirmationDatetimeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setLastConfirmationDatetimeRequestDescriptor =
    $convert.base64Decode(
        'CiJTZXRMYXN0Q29uZmlybWF0aW9uRGF0ZXRpbWVSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKA'
        'lSCmRhdGFzb3VyY2USFAoFdmFsdWUYAiABKAlSBXZhbHVl');

@$core.Deprecated('Use getSendDestinationRequestDescriptor instead')
const GetSendDestinationRequest$json = {
  '1': 'GetSendDestinationRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetSendDestinationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSendDestinationRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRTZW5kRGVzdGluYXRpb25SZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
        'VyY2U=');

@$core.Deprecated('Use getSendDestinationResponseDescriptor instead')
const GetSendDestinationResponse$json = {
  '1': 'GetSendDestinationResponse',
  '2': [
    {'1': 'tcp_service', '3': 1, '4': 1, '5': 5, '10': 'tcpService'},
    {'1': 'destination', '3': 2, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'message', '3': 3, '4': 1, '5': 5, '10': 'message'},
  ],
};

/// Descriptor for `GetSendDestinationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSendDestinationResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRTZW5kRGVzdGluYXRpb25SZXNwb25zZRIfCgt0Y3Bfc2VydmljZRgBIAEoBVIKdGNwU2'
        'VydmljZRIgCgtkZXN0aW5hdGlvbhgCIAEoCVILZGVzdGluYXRpb24SGAoHbWVzc2FnZRgDIAEo'
        'BVIHbWVzc2FnZQ==');

@$core.Deprecated('Use setSendDestinationRequestDescriptor instead')
const SetSendDestinationRequest$json = {
  '1': 'SetSendDestinationRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'tcp_service', '3': 2, '4': 1, '5': 5, '10': 'tcpService'},
    {'1': 'destination', '3': 3, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'message', '3': 4, '4': 1, '5': 5, '10': 'message'},
  ],
};

/// Descriptor for `SetSendDestinationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setSendDestinationRequestDescriptor = $convert.base64Decode(
    'ChlTZXRTZW5kRGVzdGluYXRpb25SZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
    'VyY2USHwoLdGNwX3NlcnZpY2UYAiABKAVSCnRjcFNlcnZpY2USIAoLZGVzdGluYXRpb24YAyAB'
    'KAlSC2Rlc3RpbmF0aW9uEhgKB21lc3NhZ2UYBCABKAVSB21lc3NhZ2U=');

@$core.Deprecated('Use communicationWindowEntryDescriptor instead')
const CommunicationWindowEntry$json = {
  '1': 'CommunicationWindowEntry',
  '2': [
    {'1': 'start_time', '3': 1, '4': 1, '5': 9, '10': 'startTime'},
    {'1': 'end_time', '3': 2, '4': 1, '5': 9, '10': 'endTime'},
  ],
};

/// Descriptor for `CommunicationWindowEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List communicationWindowEntryDescriptor =
    $convert.base64Decode(
        'ChhDb21tdW5pY2F0aW9uV2luZG93RW50cnkSHQoKc3RhcnRfdGltZRgBIAEoCVIJc3RhcnRUaW'
        '1lEhkKCGVuZF90aW1lGAIgASgJUgdlbmRUaW1l');

@$core.Deprecated('Use getCommunicationWindowRequestDescriptor instead')
const GetCommunicationWindowRequest$json = {
  '1': 'GetCommunicationWindowRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetCommunicationWindowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommunicationWindowRequestDescriptor =
    $convert.base64Decode(
        'Ch1HZXRDb21tdW5pY2F0aW9uV2luZG93UmVxdWVzdBIeCgpkYXRhc291cmNlGAEgASgJUgpkYX'
        'Rhc291cmNl');

@$core.Deprecated('Use getCommunicationWindowResponseDescriptor instead')
const GetCommunicationWindowResponse$json = {
  '1': 'GetCommunicationWindowResponse',
  '2': [
    {
      '1': 'windows',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.CommunicationWindowEntry',
      '10': 'windows'
    },
  ],
};

/// Descriptor for `GetCommunicationWindowResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommunicationWindowResponseDescriptor =
    $convert.base64Decode(
        'Ch5HZXRDb21tdW5pY2F0aW9uV2luZG93UmVzcG9uc2USOQoHd2luZG93cxgBIAMoCzIfLm1ldG'
        'VyLkNvbW11bmljYXRpb25XaW5kb3dFbnRyeVIHd2luZG93cw==');

@$core.Deprecated('Use cosemDateTimeEntryDescriptor instead')
const CosemDateTimeEntry$json = {
  '1': 'CosemDateTimeEntry',
  '2': [
    {'1': 'day', '3': 1, '4': 1, '5': 5, '10': 'day'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'year', '3': 3, '4': 1, '5': 5, '10': 'year'},
    {'1': 'weekday', '3': 4, '4': 1, '5': 5, '10': 'weekday'},
    {'1': 'hour', '3': 5, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'minute', '3': 6, '4': 1, '5': 5, '10': 'minute'},
    {'1': 'second', '3': 7, '4': 1, '5': 5, '10': 'second'},
  ],
};

/// Descriptor for `CosemDateTimeEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cosemDateTimeEntryDescriptor = $convert.base64Decode(
    'ChJDb3NlbURhdGVUaW1lRW50cnkSEAoDZGF5GAEgASgFUgNkYXkSFAoFbW9udGgYAiABKAVSBW'
    '1vbnRoEhIKBHllYXIYAyABKAVSBHllYXISGAoHd2Vla2RheRgEIAEoBVIHd2Vla2RheRISCgRo'
    'b3VyGAUgASgFUgRob3VyEhYKBm1pbnV0ZRgGIAEoBVIGbWludXRlEhYKBnNlY29uZBgHIAEoBV'
    'IGc2Vjb25k');

@$core.Deprecated('Use setCommunicationWindowEntryDescriptor instead')
const SetCommunicationWindowEntry$json = {
  '1': 'SetCommunicationWindowEntry',
  '2': [
    {
      '1': 'start_time',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.CosemDateTimeEntry',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.CosemDateTimeEntry',
      '10': 'endTime'
    },
  ],
};

/// Descriptor for `SetCommunicationWindowEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCommunicationWindowEntryDescriptor =
    $convert.base64Decode(
        'ChtTZXRDb21tdW5pY2F0aW9uV2luZG93RW50cnkSOAoKc3RhcnRfdGltZRgBIAEoCzIZLm1ldG'
        'VyLkNvc2VtRGF0ZVRpbWVFbnRyeVIJc3RhcnRUaW1lEjQKCGVuZF90aW1lGAIgASgLMhkubWV0'
        'ZXIuQ29zZW1EYXRlVGltZUVudHJ5UgdlbmRUaW1l');

@$core.Deprecated('Use setCommunicationWindowRequestDescriptor instead')
const SetCommunicationWindowRequest$json = {
  '1': 'SetCommunicationWindowRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {
      '1': 'windows',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.SetCommunicationWindowEntry',
      '10': 'windows'
    },
  ],
};

/// Descriptor for `SetCommunicationWindowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCommunicationWindowRequestDescriptor =
    $convert.base64Decode(
        'Ch1TZXRDb21tdW5pY2F0aW9uV2luZG93UmVxdWVzdBIeCgpkYXRhc291cmNlGAEgASgJUgpkYX'
        'Rhc291cmNlEjwKB3dpbmRvd3MYAiADKAsyIi5tZXRlci5TZXRDb21tdW5pY2F0aW9uV2luZG93'
        'RW50cnlSB3dpbmRvd3M=');

@$core.Deprecated('Use getExecutionTimeRequestDescriptor instead')
const GetExecutionTimeRequest$json = {
  '1': 'GetExecutionTimeRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetExecutionTimeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExecutionTimeRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRFeGVjdXRpb25UaW1lUmVxdWVzdBIeCgpkYXRhc291cmNlGAEgASgJUgpkYXRhc291cm'
        'Nl');

@$core.Deprecated('Use setExecutionTimeRequestDescriptor instead')
const SetExecutionTimeRequest$json = {
  '1': 'SetExecutionTimeRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {
      '1': 'times',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.CosemDateTimeEntry',
      '10': 'times'
    },
  ],
};

/// Descriptor for `SetExecutionTimeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setExecutionTimeRequestDescriptor = $convert.base64Decode(
    'ChdTZXRFeGVjdXRpb25UaW1lUmVxdWVzdBIeCgpkYXRhc291cmNlGAEgASgJUgpkYXRhc291cm'
    'NlEi8KBXRpbWVzGAIgAygLMhkubWV0ZXIuQ29zZW1EYXRlVGltZUVudHJ5UgV0aW1lcw==');

@$core.Deprecated('Use getPushActionTypeRequestDescriptor instead')
const GetPushActionTypeRequest$json = {
  '1': 'GetPushActionTypeRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetPushActionTypeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushActionTypeRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRQdXNoQWN0aW9uVHlwZVJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIAEoCVIKZGF0YXNvdX'
        'JjZQ==');

@$core.Deprecated('Use getPushActionExecutedScriptRequestDescriptor instead')
const GetPushActionExecutedScriptRequest$json = {
  '1': 'GetPushActionExecutedScriptRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetPushActionExecutedScriptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushActionExecutedScriptRequestDescriptor =
    $convert.base64Decode(
        'CiJHZXRQdXNoQWN0aW9uRXhlY3V0ZWRTY3JpcHRSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKA'
        'lSCmRhdGFzb3VyY2U=');

@$core.Deprecated('Use getPushActionExecutedScriptResponseDescriptor instead')
const GetPushActionExecutedScriptResponse$json = {
  '1': 'GetPushActionExecutedScriptResponse',
  '2': [
    {'1': 'script_selector', '3': 1, '4': 1, '5': 5, '10': 'scriptSelector'},
    {'1': 'script_table', '3': 2, '4': 1, '5': 9, '10': 'scriptTable'},
  ],
};

/// Descriptor for `GetPushActionExecutedScriptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushActionExecutedScriptResponseDescriptor =
    $convert.base64Decode(
        'CiNHZXRQdXNoQWN0aW9uRXhlY3V0ZWRTY3JpcHRSZXNwb25zZRInCg9zY3JpcHRfc2VsZWN0b3'
        'IYASABKAVSDnNjcmlwdFNlbGVjdG9yEiEKDHNjcmlwdF90YWJsZRgCIAEoCVILc2NyaXB0VGFi'
        'bGU=');

@$core.Deprecated('Use setPushActionExecutedScriptRequestDescriptor instead')
const SetPushActionExecutedScriptRequest$json = {
  '1': 'SetPushActionExecutedScriptRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'script_selector', '3': 2, '4': 1, '5': 5, '10': 'scriptSelector'},
    {'1': 'script_table', '3': 3, '4': 1, '5': 9, '10': 'scriptTable'},
  ],
};

/// Descriptor for `SetPushActionExecutedScriptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPushActionExecutedScriptRequestDescriptor =
    $convert.base64Decode(
        'CiJTZXRQdXNoQWN0aW9uRXhlY3V0ZWRTY3JpcHRSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKA'
        'lSCmRhdGFzb3VyY2USJwoPc2NyaXB0X3NlbGVjdG9yGAIgASgFUg5zY3JpcHRTZWxlY3RvchIh'
        'CgxzY3JpcHRfdGFibGUYAyABKAlSC3NjcmlwdFRhYmxl');

@$core.Deprecated('Use getScriptTableRequestDescriptor instead')
const GetScriptTableRequest$json = {
  '1': 'GetScriptTableRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetScriptTableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScriptTableRequestDescriptor = $convert.base64Decode(
    'ChVHZXRTY3JpcHRUYWJsZVJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIAEoCVIKZGF0YXNvdXJjZQ'
    '==');

@$core.Deprecated('Use executeScriptTableRequestDescriptor instead')
const ExecuteScriptTableRequest$json = {
  '1': 'ExecuteScriptTableRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `ExecuteScriptTableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeScriptTableRequestDescriptor =
    $convert.base64Decode(
        'ChlFeGVjdXRlU2NyaXB0VGFibGVSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYASABKAlSCmRhdGFzb3'
        'VyY2U=');

@$core.Deprecated('Use captureObjectEntryDescriptor instead')
const CaptureObjectEntry$json = {
  '1': 'CaptureObjectEntry',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'obis_code', '3': 2, '4': 1, '5': 9, '10': 'obisCode'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'attribute_index', '3': 4, '4': 1, '5': 5, '10': 'attributeIndex'},
    {'1': 'data_index', '3': 5, '4': 1, '5': 5, '10': 'dataIndex'},
  ],
};

/// Descriptor for `CaptureObjectEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List captureObjectEntryDescriptor = $convert.base64Decode(
    'ChJDYXB0dXJlT2JqZWN0RW50cnkSGQoIY2xhc3NfaWQYASABKAVSB2NsYXNzSWQSGwoJb2Jpc1'
    '9jb2RlGAIgASgJUghvYmlzQ29kZRISCgRuYW1lGAMgASgJUgRuYW1lEicKD2F0dHJpYnV0ZV9p'
    'bmRleBgEIAEoBVIOYXR0cmlidXRlSW5kZXgSHQoKZGF0YV9pbmRleBgFIAEoBVIJZGF0YUluZG'
    'V4');

@$core.Deprecated('Use getPushSelectiveCaptureObjectsRequestDescriptor instead')
const GetPushSelectiveCaptureObjectsRequest$json = {
  '1': 'GetPushSelectiveCaptureObjectsRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `GetPushSelectiveCaptureObjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushSelectiveCaptureObjectsRequestDescriptor =
    $convert.base64Decode(
        'CiVHZXRQdXNoU2VsZWN0aXZlQ2FwdHVyZU9iamVjdHNSZXF1ZXN0Eh4KCmRhdGFzb3VyY2UYAS'
        'ABKAlSCmRhdGFzb3VyY2U=');

@$core
    .Deprecated('Use getPushSelectiveCaptureObjectsResponseDescriptor instead')
const GetPushSelectiveCaptureObjectsResponse$json = {
  '1': 'GetPushSelectiveCaptureObjectsResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.CaptureObjectEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `GetPushSelectiveCaptureObjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushSelectiveCaptureObjectsResponseDescriptor =
    $convert.base64Decode(
        'CiZHZXRQdXNoU2VsZWN0aXZlQ2FwdHVyZU9iamVjdHNSZXNwb25zZRIzCgdlbnRyaWVzGAEgAy'
        'gLMhkubWV0ZXIuQ2FwdHVyZU9iamVjdEVudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use getPushRecoveryObjectsRequestItemDescriptor instead')
const GetPushRecoveryObjectsRequestItem$json = {
  '1': 'GetPushRecoveryObjectsRequestItem',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
    {'1': 'attribute', '3': 2, '4': 1, '5': 5, '10': 'attribute'},
  ],
};

/// Descriptor for `GetPushRecoveryObjectsRequestItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushRecoveryObjectsRequestItemDescriptor =
    $convert.base64Decode(
        'CiFHZXRQdXNoUmVjb3ZlcnlPYmplY3RzUmVxdWVzdEl0ZW0SHgoKZGF0YXNvdXJjZRgBIAEoCV'
        'IKZGF0YXNvdXJjZRIcCglhdHRyaWJ1dGUYAiABKAVSCWF0dHJpYnV0ZQ==');

@$core.Deprecated('Use getPushRecoveryObjectsRequestDescriptor instead')
const GetPushRecoveryObjectsRequest$json = {
  '1': 'GetPushRecoveryObjectsRequest',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.GetPushRecoveryObjectsRequestItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `GetPushRecoveryObjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushRecoveryObjectsRequestDescriptor =
    $convert.base64Decode(
        'Ch1HZXRQdXNoUmVjb3ZlcnlPYmplY3RzUmVxdWVzdBI+CgVpdGVtcxgBIAMoCzIoLm1ldGVyLk'
        'dldFB1c2hSZWNvdmVyeU9iamVjdHNSZXF1ZXN0SXRlbVIFaXRlbXM=');

@$core.Deprecated('Use getPushRecoveryObjectsResponseDescriptor instead')
const GetPushRecoveryObjectsResponse$json = {
  '1': 'GetPushRecoveryObjectsResponse',
  '2': [
    {'1': 'results', '3': 1, '4': 3, '5': 9, '10': 'results'},
  ],
};

/// Descriptor for `GetPushRecoveryObjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPushRecoveryObjectsResponseDescriptor =
    $convert.base64Decode(
        'Ch5HZXRQdXNoUmVjb3ZlcnlPYmplY3RzUmVzcG9uc2USGAoHcmVzdWx0cxgBIAMoCVIHcmVzdW'
        'x0cw==');

@$core.Deprecated('Use pushSetupPushRequestDescriptor instead')
const PushSetupPushRequest$json = {
  '1': 'PushSetupPushRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `PushSetupPushRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushSetupPushRequestDescriptor = $convert.base64Decode(
    'ChRQdXNoU2V0dXBQdXNoUmVxdWVzdBIeCgpkYXRhc291cmNlGAEgASgJUgpkYXRhc291cmNl');

@$core.Deprecated('Use pushSetupResetRequestDescriptor instead')
const PushSetupResetRequest$json = {
  '1': 'PushSetupResetRequest',
  '2': [
    {'1': 'datasource', '3': 1, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `PushSetupResetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushSetupResetRequestDescriptor = $convert.base64Decode(
    'ChVQdXNoU2V0dXBSZXNldFJlcXVlc3QSHgoKZGF0YXNvdXJjZRgBIAEoCVIKZGF0YXNvdXJjZQ'
    '==');

@$core.Deprecated('Use scriptTableEntryDescriptor instead')
const ScriptTableEntry$json = {
  '1': 'ScriptTableEntry',
  '2': [
    {
      '1': 'script_identifier',
      '3': 1,
      '4': 1,
      '5': 5,
      '10': 'scriptIdentifier'
    },
    {'1': 'service_id', '3': 2, '4': 1, '5': 5, '10': 'serviceId'},
    {'1': 'class_id', '3': 3, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'logical_name', '3': 4, '4': 1, '5': 9, '10': 'logicalName'},
    {'1': 'index', '3': 5, '4': 1, '5': 5, '10': 'index'},
    {'1': 'parameter', '3': 6, '4': 1, '5': 9, '10': 'parameter'},
  ],
};

/// Descriptor for `ScriptTableEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scriptTableEntryDescriptor = $convert.base64Decode(
    'ChBTY3JpcHRUYWJsZUVudHJ5EisKEXNjcmlwdF9pZGVudGlmaWVyGAEgASgFUhBzY3JpcHRJZG'
    'VudGlmaWVyEh0KCnNlcnZpY2VfaWQYAiABKAVSCXNlcnZpY2VJZBIZCghjbGFzc19pZBgDIAEo'
    'BVIHY2xhc3NJZBIhCgxsb2dpY2FsX25hbWUYBCABKAlSC2xvZ2ljYWxOYW1lEhQKBWluZGV4GA'
    'UgASgFUgVpbmRleBIcCglwYXJhbWV0ZXIYBiABKAlSCXBhcmFtZXRlcg==');

@$core.Deprecated('Use getScriptTableResponseDescriptor instead')
const GetScriptTableResponse$json = {
  '1': 'GetScriptTableResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.ScriptTableEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `GetScriptTableResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScriptTableResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRTY3JpcHRUYWJsZVJlc3BvbnNlEjEKB2VudHJpZXMYASADKAsyFy5tZXRlci5TY3JpcH'
        'RUYWJsZUVudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use datamodelObjectDescriptor instead')
const DatamodelObject$json = {
  '1': 'DatamodelObject',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'classId', '3': 2, '4': 1, '5': 5, '10': 'classId'},
    {'1': 'logicalName', '3': 3, '4': 1, '5': 9, '10': 'logicalName'},
    {'1': 'logicalName_hex', '3': 4, '4': 1, '5': 9, '10': 'logicalNameHex'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `DatamodelObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List datamodelObjectDescriptor = $convert.base64Decode(
    'Cg9EYXRhbW9kZWxPYmplY3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIYCgdjbGFzc0lkGAIgASgFUg'
    'djbGFzc0lkEiAKC2xvZ2ljYWxOYW1lGAMgASgJUgtsb2dpY2FsTmFtZRInCg9sb2dpY2FsTmFt'
    'ZV9oZXgYBCABKAlSDmxvZ2ljYWxOYW1lSGV4EiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcm'
    'lwdGlvbg==');

@$core.Deprecated('Use getDatamodelObjectsResponseDescriptor instead')
const GetDatamodelObjectsResponse$json = {
  '1': 'GetDatamodelObjectsResponse',
  '2': [
    {
      '1': 'objects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.DatamodelObject',
      '10': 'objects'
    },
  ],
};

/// Descriptor for `GetDatamodelObjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDatamodelObjectsResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXREYXRhbW9kZWxPYmplY3RzUmVzcG9uc2USMAoHb2JqZWN0cxgBIAMoCzIWLm1ldGVyLk'
        'RhdGFtb2RlbE9iamVjdFIHb2JqZWN0cw==');

@$core.Deprecated(
    'Use getDatamodelAttributesByObjectNameRequestDescriptor instead')
const GetDatamodelAttributesByObjectNameRequest$json = {
  '1': 'GetDatamodelAttributesByObjectNameRequest',
  '2': [
    {'1': 'objectName', '3': 1, '4': 1, '5': 9, '10': 'objectName'},
    {'1': 'clientName', '3': 2, '4': 1, '5': 9, '10': 'clientName'},
  ],
};

/// Descriptor for `GetDatamodelAttributesByObjectNameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    getDatamodelAttributesByObjectNameRequestDescriptor = $convert.base64Decode(
        'CilHZXREYXRhbW9kZWxBdHRyaWJ1dGVzQnlPYmplY3ROYW1lUmVxdWVzdBIeCgpvYmplY3ROYW'
        '1lGAEgASgJUgpvYmplY3ROYW1lEh4KCmNsaWVudE5hbWUYAiABKAlSCmNsaWVudE5hbWU=');

@$core.Deprecated('Use datamodelAttributeDescriptor instead')
const DatamodelAttribute$json = {
  '1': 'DatamodelAttribute',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'accessRights', '3': 4, '4': 1, '5': 9, '10': 'accessRights'},
    {'1': 'type', '3': 5, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `DatamodelAttribute`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List datamodelAttributeDescriptor = $convert.base64Decode(
    'ChJEYXRhbW9kZWxBdHRyaWJ1dGUSDgoCaWQYASABKAVSAmlkEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEiIKDGFjY2Vzc1JpZ2h0cxgEIAEo'
    'CVIMYWNjZXNzUmlnaHRzEhIKBHR5cGUYBSABKAlSBHR5cGU=');

@$core.Deprecated(
    'Use getDatamodelAttributesByObjectNameResponseDescriptor instead')
const GetDatamodelAttributesByObjectNameResponse$json = {
  '1': 'GetDatamodelAttributesByObjectNameResponse',
  '2': [
    {
      '1': 'attributes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.DatamodelAttribute',
      '10': 'attributes'
    },
  ],
};

/// Descriptor for `GetDatamodelAttributesByObjectNameResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    getDatamodelAttributesByObjectNameResponseDescriptor =
    $convert.base64Decode(
        'CipHZXREYXRhbW9kZWxBdHRyaWJ1dGVzQnlPYmplY3ROYW1lUmVzcG9uc2USOQoKYXR0cmlidX'
        'RlcxgBIAMoCzIZLm1ldGVyLkRhdGFtb2RlbEF0dHJpYnV0ZVIKYXR0cmlidXRlcw==');

@$core.Deprecated('Use readQualityConfigRequestDescriptor instead')
const ReadQualityConfigRequest$json = {
  '1': 'ReadQualityConfigRequest',
  '2': [
    {'1': 'data_source', '3': 1, '4': 1, '5': 9, '10': 'dataSource'},
  ],
};

/// Descriptor for `ReadQualityConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readQualityConfigRequestDescriptor =
    $convert.base64Decode(
        'ChhSZWFkUXVhbGl0eUNvbmZpZ1JlcXVlc3QSHwoLZGF0YV9zb3VyY2UYASABKAlSCmRhdGFTb3'
        'VyY2U=');

@$core.Deprecated('Use qualityConfigValueDescriptor instead')
const QualityConfigValue$json = {
  '1': 'QualityConfigValue',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `QualityConfigValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List qualityConfigValueDescriptor = $convert.base64Decode(
    'ChJRdWFsaXR5Q29uZmlnVmFsdWUSFAoFdmFsdWUYASABKAVSBXZhbHVlEhIKBHR5cGUYAiABKA'
    'lSBHR5cGU=');

@$core.Deprecated('Use qualityConfigValuesDescriptor instead')
const QualityConfigValues$json = {
  '1': 'QualityConfigValues',
  '2': [
    {
      '1': 'values',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.QualityConfigValue',
      '10': 'values'
    },
  ],
};

/// Descriptor for `QualityConfigValues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List qualityConfigValuesDescriptor = $convert.base64Decode(
    'ChNRdWFsaXR5Q29uZmlnVmFsdWVzEjEKBnZhbHVlcxgBIAMoCzIZLm1ldGVyLlF1YWxpdHlDb2'
    '5maWdWYWx1ZVIGdmFsdWVz');

@$core.Deprecated('Use readQualityConfigResponseDescriptor instead')
const ReadQualityConfigResponse$json = {
  '1': 'ReadQualityConfigResponse',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.QualityConfigValue',
      '9': 0,
      '10': 'value'
    },
    {
      '1': 'values',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.QualityConfigValues',
      '9': 0,
      '10': 'values'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `ReadQualityConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readQualityConfigResponseDescriptor = $convert.base64Decode(
    'ChlSZWFkUXVhbGl0eUNvbmZpZ1Jlc3BvbnNlEjEKBXZhbHVlGAEgASgLMhkubWV0ZXIuUXVhbG'
    'l0eUNvbmZpZ1ZhbHVlSABSBXZhbHVlEjQKBnZhbHVlcxgCIAEoCzIaLm1ldGVyLlF1YWxpdHlD'
    'b25maWdWYWx1ZXNIAFIGdmFsdWVzQggKBnJlc3VsdA==');

@$core.Deprecated('Use writeQualityConfigRequestDescriptor instead')
const WriteQualityConfigRequest$json = {
  '1': 'WriteQualityConfigRequest',
  '2': [
    {'1': 'data_source', '3': 1, '4': 1, '5': 9, '10': 'dataSource'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.QualityConfigValue',
      '9': 0,
      '10': 'value'
    },
    {
      '1': 'values',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meter.QualityConfigValues',
      '9': 0,
      '10': 'values'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `WriteQualityConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeQualityConfigRequestDescriptor = $convert.base64Decode(
    'ChlXcml0ZVF1YWxpdHlDb25maWdSZXF1ZXN0Eh8KC2RhdGFfc291cmNlGAEgASgJUgpkYXRhU2'
    '91cmNlEjEKBXZhbHVlGAIgASgLMhkubWV0ZXIuUXVhbGl0eUNvbmZpZ1ZhbHVlSABSBXZhbHVl'
    'EjQKBnZhbHVlcxgDIAEoCzIaLm1ldGVyLlF1YWxpdHlDb25maWdWYWx1ZXNIAFIGdmFsdWVzQg'
    'kKB3BheWxvYWQ=');

@$core.Deprecated('Use loadDatamodelRequestDescriptor instead')
const LoadDatamodelRequest$json = {
  '1': 'LoadDatamodelRequest',
  '2': [
    {'1': 'datamodel', '3': 1, '4': 1, '5': 9, '10': 'datamodel'},
  ],
};

/// Descriptor for `LoadDatamodelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadDatamodelRequestDescriptor = $convert.base64Decode(
    'ChRMb2FkRGF0YW1vZGVsUmVxdWVzdBIcCglkYXRhbW9kZWwYASABKAlSCWRhdGFtb2RlbA==');

@$core.Deprecated('Use executionProgressDescriptor instead')
const ExecutionProgress$json = {
  '1': 'ExecutionProgress',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ExecutionProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executionProgressDescriptor = $convert.base64Decode(
    'ChFFeGVjdXRpb25Qcm9ncmVzcxIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use downloadProgressDescriptor instead')
const DownloadProgress$json = {
  '1': 'DownloadProgress',
  '2': [
    {'1': 'rows_total', '3': 1, '4': 1, '5': 4, '10': 'rowsTotal'},
    {'1': 'percent', '3': 2, '4': 1, '5': 5, '10': 'percent'},
    {'1': 'bytes_total', '3': 3, '4': 1, '5': 4, '10': 'bytesTotal'},
    {'1': 'bytes_read', '3': 4, '4': 1, '5': 4, '10': 'bytesRead'},
    {
      '1': 'rate_bytes_per_sec',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'rateBytesPerSec'
    },
  ],
};

/// Descriptor for `DownloadProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadProgressDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZFByb2dyZXNzEh0KCnJvd3NfdG90YWwYASABKARSCXJvd3NUb3RhbBIYCgdwZX'
    'JjZW50GAIgASgFUgdwZXJjZW50Eh8KC2J5dGVzX3RvdGFsGAMgASgEUgpieXRlc1RvdGFsEh0K'
    'CmJ5dGVzX3JlYWQYBCABKARSCWJ5dGVzUmVhZBIrChJyYXRlX2J5dGVzX3Blcl9zZWMYBSABKA'
    'FSD3JhdGVCeXRlc1BlclNlYw==');

@$core.Deprecated('Use getLoadProfileStreamItemDescriptor instead')
const GetLoadProfileStreamItem$json = {
  '1': 'GetLoadProfileStreamItem',
  '2': [
    {
      '1': 'exec',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.ExecutionProgress',
      '9': 0,
      '10': 'exec'
    },
    {
      '1': 'download',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.DownloadProgress',
      '9': 0,
      '10': 'download'
    },
    {
      '1': 'result',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meter.GetLoadProfileResponse',
      '9': 0,
      '10': 'result'
    },
  ],
  '8': [
    {'1': 'item'},
  ],
};

/// Descriptor for `GetLoadProfileStreamItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLoadProfileStreamItemDescriptor = $convert.base64Decode(
    'ChhHZXRMb2FkUHJvZmlsZVN0cmVhbUl0ZW0SLgoEZXhlYxgBIAEoCzIYLm1ldGVyLkV4ZWN1dG'
    'lvblByb2dyZXNzSABSBGV4ZWMSNQoIZG93bmxvYWQYAiABKAsyFy5tZXRlci5Eb3dubG9hZFBy'
    'b2dyZXNzSABSCGRvd25sb2FkEjcKBnJlc3VsdBgDIAEoCzIdLm1ldGVyLkdldExvYWRQcm9maW'
    'xlUmVzcG9uc2VIAFIGcmVzdWx0QgYKBGl0ZW0=');

@$core.Deprecated('Use activationDateTimeDescriptor instead')
const ActivationDateTime$json = {
  '1': 'ActivationDateTime',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 5, '10': 'day'},
    {'1': 'hour', '3': 4, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'minute', '3': 5, '4': 1, '5': 5, '10': 'minute'},
    {'1': 'second', '3': 6, '4': 1, '5': 5, '10': 'second'},
  ],
};

/// Descriptor for `ActivationDateTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activationDateTimeDescriptor = $convert.base64Decode(
    'ChJBY3RpdmF0aW9uRGF0ZVRpbWUSEgoEeWVhchgBIAEoBVIEeWVhchIUCgVtb250aBgCIAEoBV'
    'IFbW9udGgSEAoDZGF5GAMgASgFUgNkYXkSEgoEaG91chgEIAEoBVIEaG91chIWCgZtaW51dGUY'
    'BSABKAVSBm1pbnV0ZRIWCgZzZWNvbmQYBiABKAVSBnNlY29uZA==');

@$core.Deprecated('Use daylightSavingsTimeDescriptor instead')
const DaylightSavingsTime$json = {
  '1': 'DaylightSavingsTime',
  '2': [
    {'1': 'day', '3': 1, '4': 1, '5': 5, '10': 'day'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'hour', '3': 3, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'minute', '3': 4, '4': 1, '5': 5, '10': 'minute'},
    {'1': 'second', '3': 5, '4': 1, '5': 5, '10': 'second'},
    {'1': 'dayOfWeek', '3': 6, '4': 1, '5': 5, '10': 'dayOfWeek'},
  ],
};

/// Descriptor for `DaylightSavingsTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List daylightSavingsTimeDescriptor = $convert.base64Decode(
    'ChNEYXlsaWdodFNhdmluZ3NUaW1lEhAKA2RheRgBIAEoBVIDZGF5EhQKBW1vbnRoGAIgASgFUg'
    'Vtb250aBISCgRob3VyGAMgASgFUgRob3VyEhYKBm1pbnV0ZRgEIAEoBVIGbWludXRlEhYKBnNl'
    'Y29uZBgFIAEoBVIGc2Vjb25kEhwKCWRheU9mV2VlaxgGIAEoBVIJZGF5T2ZXZWVr');

@$core.Deprecated('Use phaseDataDescriptor instead')
const PhaseData$json = {
  '1': 'PhaseData',
  '2': [
    {'1': 'u', '3': 1, '4': 1, '5': 1, '10': 'u'},
    {'1': 'i', '3': 2, '4': 1, '5': 1, '10': 'i'},
    {'1': 'phi', '3': 3, '4': 1, '5': 1, '10': 'phi'},
  ],
};

/// Descriptor for `PhaseData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List phaseDataDescriptor = $convert.base64Decode(
    'CglQaGFzZURhdGESDAoBdRgBIAEoAVIBdRIMCgFpGAIgASgBUgFpEhAKA3BoaRgDIAEoAVIDcG'
    'hp');

@$core.Deprecated('Use fresnelResponseDescriptor instead')
const FresnelResponse$json = {
  '1': 'FresnelResponse',
  '2': [
    {
      '1': 'phases',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.PhaseData',
      '10': 'phases'
    },
  ],
};

/// Descriptor for `FresnelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fresnelResponseDescriptor = $convert.base64Decode(
    'Cg9GcmVzbmVsUmVzcG9uc2USKAoGcGhhc2VzGAEgAygLMhAubWV0ZXIuUGhhc2VEYXRhUgZwaG'
    'FzZXM=');

@$core.Deprecated('Use deviceIDResponseDescriptor instead')
const DeviceIDResponse$json = {
  '1': 'DeviceIDResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `DeviceIDResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceIDResponseDescriptor = $convert.base64Decode(
    'ChBEZXZpY2VJRFJlc3BvbnNlEhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdmFsdWUYAiABKAlSBX'
    'ZhbHVl');

@$core.Deprecated('Use deviceIDListDescriptor instead')
const DeviceIDList$json = {
  '1': 'DeviceIDList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.DeviceIDResponse',
      '10': 'items'
    },
  ],
};

/// Descriptor for `DeviceIDList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceIDListDescriptor = $convert.base64Decode(
    'CgxEZXZpY2VJRExpc3QSLQoFaXRlbXMYASADKAsyFy5tZXRlci5EZXZpY2VJRFJlc3BvbnNlUg'
    'VpdGVtcw==');

@$core.Deprecated('Use firmwareVersionResponseDescriptor instead')
const FirmwareVersionResponse$json = {
  '1': 'FirmwareVersionResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `FirmwareVersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firmwareVersionResponseDescriptor =
    $convert.base64Decode(
        'ChdGaXJtd2FyZVZlcnNpb25SZXNwb25zZRISCgRuYW1lGAEgASgJUgRuYW1lEhQKBXZhbHVlGA'
        'IgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use firmwareVersionListDescriptor instead')
const FirmwareVersionList$json = {
  '1': 'FirmwareVersionList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.FirmwareVersionResponse',
      '10': 'items'
    },
  ],
};

/// Descriptor for `FirmwareVersionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firmwareVersionListDescriptor = $convert.base64Decode(
    'ChNGaXJtd2FyZVZlcnNpb25MaXN0EjQKBWl0ZW1zGAEgAygLMh4ubWV0ZXIuRmlybXdhcmVWZX'
    'JzaW9uUmVzcG9uc2VSBWl0ZW1z');

@$core.Deprecated('Use energyRegisterResponseDescriptor instead')
const EnergyRegisterResponse$json = {
  '1': 'EnergyRegisterResponse',
  '2': [
    {'1': 'description', '3': 1, '4': 1, '5': 9, '10': 'description'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `EnergyRegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List energyRegisterResponseDescriptor =
    $convert.base64Decode(
        'ChZFbmVyZ3lSZWdpc3RlclJlc3BvbnNlEiAKC2Rlc2NyaXB0aW9uGAEgASgJUgtkZXNjcmlwdG'
        'lvbhIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU=');

@$core.Deprecated('Use energyRegisterListDescriptor instead')
const EnergyRegisterList$json = {
  '1': 'EnergyRegisterList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.EnergyRegisterResponse',
      '10': 'items'
    },
  ],
};

/// Descriptor for `EnergyRegisterList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List energyRegisterListDescriptor = $convert.base64Decode(
    'ChJFbmVyZ3lSZWdpc3Rlckxpc3QSMwoFaXRlbXMYASADKAsyHS5tZXRlci5FbmVyZ3lSZWdpc3'
    'RlclJlc3BvbnNlUgVpdGVtcw==');

@$core.Deprecated('Use averageResponseDescriptor instead')
const AverageResponse$json = {
  '1': 'AverageResponse',
  '2': [
    {'1': 'description', '3': 1, '4': 1, '5': 9, '10': 'description'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `AverageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List averageResponseDescriptor = $convert.base64Decode(
    'Cg9BdmVyYWdlUmVzcG9uc2USIAoLZGVzY3JpcHRpb24YASABKAlSC2Rlc2NyaXB0aW9uEhQKBX'
    'ZhbHVlGAIgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use averageListDescriptor instead')
const AverageList$json = {
  '1': 'AverageList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.AverageResponse',
      '10': 'items'
    },
  ],
};

/// Descriptor for `AverageList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List averageListDescriptor = $convert.base64Decode(
    'CgtBdmVyYWdlTGlzdBIsCgVpdGVtcxgBIAMoCzIWLm1ldGVyLkF2ZXJhZ2VSZXNwb25zZVIFaX'
    'RlbXM=');

@$core.Deprecated('Use loadProfilePartialReadDescriptor instead')
const LoadProfilePartialRead$json = {
  '1': 'LoadProfilePartialRead',
  '2': [
    {
      '1': 'datetime',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'datetime'
    },
    {'1': 'deviation_hex', '3': 2, '4': 1, '5': 9, '10': 'deviationHex'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `LoadProfilePartialRead`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadProfilePartialReadDescriptor = $convert.base64Decode(
    'ChZMb2FkUHJvZmlsZVBhcnRpYWxSZWFkEjYKCGRhdGV0aW1lGAEgASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIIZGF0ZXRpbWUSIwoNZGV2aWF0aW9uX2hleBgCIAEoCVIMZGV2aWF0'
    'aW9uSGV4EhYKBnN0YXR1cxgDIAEoCVIGc3RhdHVz');

@$core.Deprecated('Use getLoadProfileRequestDescriptor instead')
const GetLoadProfileRequest$json = {
  '1': 'GetLoadProfileRequest',
  '2': [
    {'1': 'objectName', '3': 1, '4': 1, '5': 9, '10': 'objectName'},
    {
      '1': 'start',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.LoadProfilePartialRead',
      '9': 0,
      '10': 'start',
      '17': true
    },
    {
      '1': 'end',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meter.LoadProfilePartialRead',
      '9': 1,
      '10': 'end',
      '17': true
    },
    {'1': 'page', '3': 10, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 11, '4': 1, '5': 5, '10': 'pageSize'},
  ],
  '8': [
    {'1': '_start'},
    {'1': '_end'},
  ],
};

/// Descriptor for `GetLoadProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLoadProfileRequestDescriptor = $convert.base64Decode(
    'ChVHZXRMb2FkUHJvZmlsZVJlcXVlc3QSHgoKb2JqZWN0TmFtZRgBIAEoCVIKb2JqZWN0TmFtZR'
    'I4CgVzdGFydBgCIAEoCzIdLm1ldGVyLkxvYWRQcm9maWxlUGFydGlhbFJlYWRIAFIFc3RhcnSI'
    'AQESNAoDZW5kGAMgASgLMh0ubWV0ZXIuTG9hZFByb2ZpbGVQYXJ0aWFsUmVhZEgBUgNlbmSIAQ'
    'ESEgoEcGFnZRgKIAEoBVIEcGFnZRIbCglwYWdlX3NpemUYCyABKAVSCHBhZ2VTaXplQggKBl9z'
    'dGFydEIGCgRfZW5k');

@$core.Deprecated('Use getLoadProfileResponseDescriptor instead')
const GetLoadProfileResponse$json = {
  '1': 'GetLoadProfileResponse',
  '2': [
    {'1': 'headerTypes', '3': 1, '4': 3, '5': 9, '10': 'headerTypes'},
    {
      '1': 'values',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.StringList',
      '10': 'values'
    },
    {'1': 'total_entries', '3': 10, '4': 1, '5': 5, '10': 'totalEntries'},
    {'1': 'current_page', '3': 11, '4': 1, '5': 5, '10': 'currentPage'},
    {'1': 'total_pages', '3': 12, '4': 1, '5': 5, '10': 'totalPages'},
  ],
};

/// Descriptor for `GetLoadProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLoadProfileResponseDescriptor = $convert.base64Decode(
    'ChZHZXRMb2FkUHJvZmlsZVJlc3BvbnNlEiAKC2hlYWRlclR5cGVzGAEgAygJUgtoZWFkZXJUeX'
    'BlcxIpCgZ2YWx1ZXMYAiADKAsyES5tZXRlci5TdHJpbmdMaXN0UgZ2YWx1ZXMSIwoNdG90YWxf'
    'ZW50cmllcxgKIAEoBVIMdG90YWxFbnRyaWVzEiEKDGN1cnJlbnRfcGFnZRgLIAEoBVILY3Vycm'
    'VudFBhZ2USHwoLdG90YWxfcGFnZXMYDCABKAVSCnRvdGFsUGFnZXM=');

@$core.Deprecated('Use getLoadProfileParamRequestDescriptor instead')
const GetLoadProfileParamRequest$json = {
  '1': 'GetLoadProfileParamRequest',
  '2': [
    {'1': 'objectName', '3': 1, '4': 1, '5': 9, '10': 'objectName'},
    {
      '1': 'param',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.meter.LoadProfileParam',
      '10': 'param'
    },
  ],
};

/// Descriptor for `GetLoadProfileParamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLoadProfileParamRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRMb2FkUHJvZmlsZVBhcmFtUmVxdWVzdBIeCgpvYmplY3ROYW1lGAEgASgJUgpvYmplY3'
        'ROYW1lEi0KBXBhcmFtGAIgASgOMhcubWV0ZXIuTG9hZFByb2ZpbGVQYXJhbVIFcGFyYW0=');

@$core.Deprecated('Use setLoadProfileParamRequestDescriptor instead')
const SetLoadProfileParamRequest$json = {
  '1': 'SetLoadProfileParamRequest',
  '2': [
    {'1': 'objectName', '3': 1, '4': 1, '5': 9, '10': 'objectName'},
    {
      '1': 'param',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.meter.LoadProfileParam',
      '10': 'param'
    },
    {'1': 'value', '3': 3, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `SetLoadProfileParamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setLoadProfileParamRequestDescriptor =
    $convert.base64Decode(
        'ChpTZXRMb2FkUHJvZmlsZVBhcmFtUmVxdWVzdBIeCgpvYmplY3ROYW1lGAEgASgJUgpvYmplY3'
        'ROYW1lEi0KBXBhcmFtGAIgASgOMhcubWV0ZXIuTG9hZFByb2ZpbGVQYXJhbVIFcGFyYW0SFAoF'
        'dmFsdWUYAyABKAVSBXZhbHVl');

@$core.Deprecated('Use bitStatusRequestDescriptor instead')
const BitStatusRequest$json = {
  '1': 'BitStatusRequest',
  '2': [
    {'1': 'dataSource', '3': 1, '4': 1, '5': 9, '10': 'dataSource'},
    {'1': 'descriptionJson', '3': 2, '4': 1, '5': 9, '10': 'descriptionJson'},
  ],
};

/// Descriptor for `BitStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bitStatusRequestDescriptor = $convert.base64Decode(
    'ChBCaXRTdGF0dXNSZXF1ZXN0Eh4KCmRhdGFTb3VyY2UYASABKAlSCmRhdGFTb3VyY2USKAoPZG'
    'VzY3JpcHRpb25Kc29uGAIgASgJUg9kZXNjcmlwdGlvbkpzb24=');

@$core.Deprecated('Use bitStatusDescriptor instead')
const BitStatus$json = {
  '1': 'BitStatus',
  '2': [
    {'1': 'mask', '3': 1, '4': 1, '5': 9, '10': 'mask'},
    {'1': 'bitValue', '3': 2, '4': 1, '5': 9, '10': 'bitValue'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'isActive', '3': 4, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `BitStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bitStatusDescriptor = $convert.base64Decode(
    'CglCaXRTdGF0dXMSEgoEbWFzaxgBIAEoCVIEbWFzaxIaCghiaXRWYWx1ZRgCIAEoCVIIYml0Vm'
    'FsdWUSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhoKCGlzQWN0aXZlGAQgASgI'
    'Ughpc0FjdGl2ZQ==');

@$core.Deprecated('Use bitStatusResponseDescriptor instead')
const BitStatusResponse$json = {
  '1': 'BitStatusResponse',
  '2': [
    {
      '1': 'bits',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.BitStatus',
      '10': 'bits'
    },
  ],
};

/// Descriptor for `BitStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bitStatusResponseDescriptor = $convert.base64Decode(
    'ChFCaXRTdGF0dXNSZXNwb25zZRIkCgRiaXRzGAEgAygLMhAubWV0ZXIuQml0U3RhdHVzUgRiaX'
    'Rz');

@$core.Deprecated('Use modemConfigResponseDescriptor instead')
const ModemConfigResponse$json = {
  '1': 'ModemConfigResponse',
  '2': [
    {'1': 'apn', '3': 1, '4': 1, '5': 9, '10': 'apn'},
    {'1': 'pin_code', '3': 2, '4': 1, '5': 13, '10': 'pinCode'},
    {'1': 'ppp_username', '3': 3, '4': 1, '5': 9, '10': 'pppUsername'},
    {'1': 'ppp_password', '3': 4, '4': 1, '5': 9, '10': 'pppPassword'},
  ],
};

/// Descriptor for `ModemConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modemConfigResponseDescriptor = $convert.base64Decode(
    'ChNNb2RlbUNvbmZpZ1Jlc3BvbnNlEhAKA2FwbhgBIAEoCVIDYXBuEhkKCHBpbl9jb2RlGAIgAS'
    'gNUgdwaW5Db2RlEiEKDHBwcF91c2VybmFtZRgDIAEoCVILcHBwVXNlcm5hbWUSIQoMcHBwX3Bh'
    'c3N3b3JkGAQgASgJUgtwcHBQYXNzd29yZA==');

@$core.Deprecated('Use setApnRequestDescriptor instead')
const SetApnRequest$json = {
  '1': 'SetApnRequest',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SetApnRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setApnRequestDescriptor = $convert
    .base64Decode('Cg1TZXRBcG5SZXF1ZXN0EhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use setPinCodeRequestDescriptor instead')
const SetPinCodeRequest$json = {
  '1': 'SetPinCodeRequest',
  '2': [
    {'1': 'pin_code', '3': 1, '4': 1, '5': 13, '10': 'pinCode'},
  ],
};

/// Descriptor for `SetPinCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPinCodeRequestDescriptor = $convert.base64Decode(
    'ChFTZXRQaW5Db2RlUmVxdWVzdBIZCghwaW5fY29kZRgBIAEoDVIHcGluQ29kZQ==');

@$core.Deprecated('Use setPppAuthRequestDescriptor instead')
const SetPppAuthRequest$json = {
  '1': 'SetPppAuthRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `SetPppAuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPppAuthRequestDescriptor = $convert.base64Decode(
    'ChFTZXRQcHBBdXRoUmVxdWVzdBIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3'
    'dvcmQYAiABKAlSCHBhc3N3b3Jk');

@$core.Deprecated('Use ipAddressResponseDescriptor instead')
const IpAddressResponse$json = {
  '1': 'IpAddressResponse',
  '2': [
    {'1': 'is_ipv6', '3': 1, '4': 1, '5': 8, '10': 'isIpv6'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `IpAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ipAddressResponseDescriptor = $convert.base64Decode(
    'ChFJcEFkZHJlc3NSZXNwb25zZRIXCgdpc19pcHY2GAEgASgIUgZpc0lwdjYSGAoHYWRkcmVzcx'
    'gCIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use setIpAddressRequestDescriptor instead')
const SetIpAddressRequest$json = {
  '1': 'SetIpAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'is_ipv6', '3': 2, '4': 1, '5': 8, '10': 'isIpv6'},
  ],
};

/// Descriptor for `SetIpAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setIpAddressRequestDescriptor = $convert.base64Decode(
    'ChNTZXRJcEFkZHJlc3NSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSFwoHaXNfaX'
    'B2NhgCIAEoCFIGaXNJcHY2');

@$core.Deprecated('Use cellularDiagResponseDescriptor instead')
const CellularDiagResponse$json = {
  '1': 'CellularDiagResponse',
  '2': [
    {'1': 'operator_name', '3': 1, '4': 1, '5': 9, '10': 'operatorName'},
    {'1': 'status', '3': 2, '4': 1, '5': 13, '10': 'status'},
    {'1': 'cs_attachment', '3': 3, '4': 1, '5': 13, '10': 'csAttachment'},
    {'1': 'ps_status', '3': 4, '4': 1, '5': 13, '10': 'psStatus'},
    {'1': 'show_cell_info', '3': 5, '4': 1, '5': 8, '10': 'showCellInfo'},
    {'1': 'show_qos', '3': 6, '4': 1, '5': 8, '10': 'showQos'},
    {'1': 'is_lte_mode', '3': 7, '4': 1, '5': 8, '10': 'isLteMode'},
  ],
};

/// Descriptor for `CellularDiagResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cellularDiagResponseDescriptor = $convert.base64Decode(
    'ChRDZWxsdWxhckRpYWdSZXNwb25zZRIjCg1vcGVyYXRvcl9uYW1lGAEgASgJUgxvcGVyYXRvck'
    '5hbWUSFgoGc3RhdHVzGAIgASgNUgZzdGF0dXMSIwoNY3NfYXR0YWNobWVudBgDIAEoDVIMY3NB'
    'dHRhY2htZW50EhsKCXBzX3N0YXR1cxgEIAEoDVIIcHNTdGF0dXMSJAoOc2hvd19jZWxsX2luZm'
    '8YBSABKAhSDHNob3dDZWxsSW5mbxIZCghzaG93X3FvcxgGIAEoCFIHc2hvd1FvcxIeCgtpc19s'
    'dGVfbW9kZRgHIAEoCFIJaXNMdGVNb2Rl');

@$core.Deprecated('Use setCellularFieldRequestDescriptor instead')
const SetCellularFieldRequest$json = {
  '1': 'SetCellularFieldRequest',
  '2': [
    {'1': 'attribute', '3': 1, '4': 1, '5': 5, '10': 'attribute'},
    {'1': 'string_value', '3': 2, '4': 1, '5': 9, '10': 'stringValue'},
    {'1': 'enum_value', '3': 3, '4': 1, '5': 13, '10': 'enumValue'},
  ],
};

/// Descriptor for `SetCellularFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCellularFieldRequestDescriptor = $convert.base64Decode(
    'ChdTZXRDZWxsdWxhckZpZWxkUmVxdWVzdBIcCglhdHRyaWJ1dGUYASABKAVSCWF0dHJpYnV0ZR'
    'IhCgxzdHJpbmdfdmFsdWUYAiABKAlSC3N0cmluZ1ZhbHVlEh0KCmVudW1fdmFsdWUYAyABKA1S'
    'CWVudW1WYWx1ZQ==');

@$core.Deprecated('Use cellInfoEntryDescriptor instead')
const CellInfoEntry$json = {
  '1': 'CellInfoEntry',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `CellInfoEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cellInfoEntryDescriptor = $convert.base64Decode(
    'Cg1DZWxsSW5mb0VudHJ5EhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdmFsdWUYAiABKAlSBXZhbH'
    'Vl');

@$core.Deprecated('Use cellInfoResponseDescriptor instead')
const CellInfoResponse$json = {
  '1': 'CellInfoResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.CellInfoEntry',
      '10': 'entries'
    },
    {'1': 'is_lte', '3': 2, '4': 1, '5': 8, '10': 'isLte'},
  ],
};

/// Descriptor for `CellInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cellInfoResponseDescriptor = $convert.base64Decode(
    'ChBDZWxsSW5mb1Jlc3BvbnNlEi4KB2VudHJpZXMYASADKAsyFC5tZXRlci5DZWxsSW5mb0VudH'
    'J5UgdlbnRyaWVzEhUKBmlzX2x0ZRgCIAEoCFIFaXNMdGU=');

@$core.Deprecated('Use setCellInfoEntryRequestDescriptor instead')
const SetCellInfoEntryRequest$json = {
  '1': 'SetCellInfoEntryRequest',
  '2': [
    {'1': 'entry_index', '3': 1, '4': 1, '5': 5, '10': 'entryIndex'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'is_lte', '3': 3, '4': 1, '5': 8, '10': 'isLte'},
  ],
};

/// Descriptor for `SetCellInfoEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCellInfoEntryRequestDescriptor =
    $convert.base64Decode(
        'ChdTZXRDZWxsSW5mb0VudHJ5UmVxdWVzdBIfCgtlbnRyeV9pbmRleBgBIAEoBVIKZW50cnlJbm'
        'RleBIUCgV2YWx1ZRgCIAEoCVIFdmFsdWUSFQoGaXNfbHRlGAMgASgIUgVpc0x0ZQ==');

@$core.Deprecated('Use qosEntryDescriptor instead')
const QosEntry$json = {
  '1': 'QosEntry',
  '2': [
    {'1': 'precedence', '3': 1, '4': 1, '5': 13, '10': 'precedence'},
    {'1': 'delay', '3': 2, '4': 1, '5': 13, '10': 'delay'},
    {'1': 'reliability', '3': 3, '4': 1, '5': 13, '10': 'reliability'},
    {'1': 'peak_throughput', '3': 4, '4': 1, '5': 13, '10': 'peakThroughput'},
    {'1': 'mean_throughput', '3': 5, '4': 1, '5': 13, '10': 'meanThroughput'},
  ],
};

/// Descriptor for `QosEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List qosEntryDescriptor = $convert.base64Decode(
    'CghRb3NFbnRyeRIeCgpwcmVjZWRlbmNlGAEgASgNUgpwcmVjZWRlbmNlEhQKBWRlbGF5GAIgAS'
    'gNUgVkZWxheRIgCgtyZWxpYWJpbGl0eRgDIAEoDVILcmVsaWFiaWxpdHkSJwoPcGVha190aHJv'
    'dWdocHV0GAQgASgNUg5wZWFrVGhyb3VnaHB1dBInCg9tZWFuX3Rocm91Z2hwdXQYBSABKA1SDm'
    '1lYW5UaHJvdWdocHV0');

@$core.Deprecated('Use getQosResponseDescriptor instead')
const GetQosResponse$json = {
  '1': 'GetQosResponse',
  '2': [
    {
      '1': 'profiles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.QosEntry',
      '10': 'profiles'
    },
  ],
};

/// Descriptor for `GetQosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQosResponseDescriptor = $convert.base64Decode(
    'Cg5HZXRRb3NSZXNwb25zZRIrCghwcm9maWxlcxgBIAMoCzIPLm1ldGVyLlFvc0VudHJ5Ughwcm'
    '9maWxlcw==');

@$core.Deprecated('Use setQosRequestDescriptor instead')
const SetQosRequest$json = {
  '1': 'SetQosRequest',
  '2': [
    {
      '1': 'profile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.QosEntry',
      '10': 'profile'
    },
    {'1': 'profile_index', '3': 2, '4': 1, '5': 5, '10': 'profileIndex'},
  ],
};

/// Descriptor for `SetQosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setQosRequestDescriptor = $convert.base64Decode(
    'Cg1TZXRRb3NSZXF1ZXN0EikKB3Byb2ZpbGUYASABKAsyDy5tZXRlci5Rb3NFbnRyeVIHcHJvZm'
    'lsZRIjCg1wcm9maWxlX2luZGV4GAIgASgFUgxwcm9maWxlSW5kZXg=');

@$core.Deprecated('Use mobileNetworkIdentifiersResponseDescriptor instead')
const MobileNetworkIdentifiersResponse$json = {
  '1': 'MobileNetworkIdentifiersResponse',
  '2': [
    {'1': 'imsi', '3': 1, '4': 1, '5': 9, '10': 'imsi'},
    {'1': 'msisdn', '3': 2, '4': 1, '5': 9, '10': 'msisdn'},
    {'1': 'imei', '3': 3, '4': 1, '5': 9, '10': 'imei'},
    {'1': 'iccid', '3': 4, '4': 1, '5': 9, '10': 'iccid'},
  ],
};

/// Descriptor for `MobileNetworkIdentifiersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mobileNetworkIdentifiersResponseDescriptor =
    $convert.base64Decode(
        'CiBNb2JpbGVOZXR3b3JrSWRlbnRpZmllcnNSZXNwb25zZRISCgRpbXNpGAEgASgJUgRpbXNpEh'
        'YKBm1zaXNkbhgCIAEoCVIGbXNpc2RuEhIKBGltZWkYAyABKAlSBGltZWkSFAoFaWNjaWQYBCAB'
        'KAlSBWljY2lk');

@$core.Deprecated('Use setMniFieldRequestDescriptor instead')
const SetMniFieldRequest$json = {
  '1': 'SetMniFieldRequest',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SetMniFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMniFieldRequestDescriptor = $convert
    .base64Decode('ChJTZXRNbmlGaWVsZFJlcXVlc3QSFAoFdmFsdWUYASABKAlSBXZhbHVl');

@$core.Deprecated('Use modemStatusResponseDescriptor instead')
const ModemStatusResponse$json = {
  '1': 'ModemStatusResponse',
  '2': [
    {'1': 'is_active', '3': 1, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `ModemStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modemStatusResponseDescriptor =
    $convert.base64Decode(
        'ChNNb2RlbVN0YXR1c1Jlc3BvbnNlEhsKCWlzX2FjdGl2ZRgBIAEoCFIIaXNBY3RpdmU=');

@$core.Deprecated('Use mniRightsResponseDescriptor instead')
const MniRightsResponse$json = {
  '1': 'MniRightsResponse',
  '2': [
    {'1': 'imsi_get', '3': 1, '4': 1, '5': 8, '10': 'imsiGet'},
    {'1': 'imsi_set', '3': 2, '4': 1, '5': 8, '10': 'imsiSet'},
    {'1': 'msisdn_get', '3': 3, '4': 1, '5': 8, '10': 'msisdnGet'},
    {'1': 'msisdn_set', '3': 4, '4': 1, '5': 8, '10': 'msisdnSet'},
    {'1': 'imei_get', '3': 5, '4': 1, '5': 8, '10': 'imeiGet'},
    {'1': 'imei_set', '3': 6, '4': 1, '5': 8, '10': 'imeiSet'},
    {'1': 'iccid_get', '3': 7, '4': 1, '5': 8, '10': 'iccidGet'},
    {'1': 'iccid_set', '3': 8, '4': 1, '5': 8, '10': 'iccidSet'},
    {'1': 'modem_get', '3': 9, '4': 1, '5': 8, '10': 'modemGet'},
    {'1': 'modem_set', '3': 10, '4': 1, '5': 8, '10': 'modemSet'},
  ],
};

/// Descriptor for `MniRightsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mniRightsResponseDescriptor = $convert.base64Decode(
    'ChFNbmlSaWdodHNSZXNwb25zZRIZCghpbXNpX2dldBgBIAEoCFIHaW1zaUdldBIZCghpbXNpX3'
    'NldBgCIAEoCFIHaW1zaVNldBIdCgptc2lzZG5fZ2V0GAMgASgIUgltc2lzZG5HZXQSHQoKbXNp'
    'c2RuX3NldBgEIAEoCFIJbXNpc2RuU2V0EhkKCGltZWlfZ2V0GAUgASgIUgdpbWVpR2V0EhkKCG'
    'ltZWlfc2V0GAYgASgIUgdpbWVpU2V0EhsKCWljY2lkX2dldBgHIAEoCFIIaWNjaWRHZXQSGwoJ'
    'aWNjaWRfc2V0GAggASgIUghpY2NpZFNldBIbCgltb2RlbV9nZXQYCSABKAhSCG1vZGVtR2V0Eh'
    'sKCW1vZGVtX3NldBgKIAEoCFIIbW9kZW1TZXQ=');

@$core.Deprecated('Use modemInitStringEntryDescriptor instead')
const ModemInitStringEntry$json = {
  '1': 'ModemInitStringEntry',
  '2': [
    {'1': 'request', '3': 1, '4': 1, '5': 9, '10': 'request'},
    {'1': 'expected', '3': 2, '4': 1, '5': 9, '10': 'expected'},
    {'1': 'delay_ms', '3': 3, '4': 1, '5': 5, '10': 'delayMs'},
  ],
};

/// Descriptor for `ModemInitStringEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modemInitStringEntryDescriptor = $convert.base64Decode(
    'ChRNb2RlbUluaXRTdHJpbmdFbnRyeRIYCgdyZXF1ZXN0GAEgASgJUgdyZXF1ZXN0EhoKCGV4cG'
    'VjdGVkGAIgASgJUghleHBlY3RlZBIZCghkZWxheV9tcxgDIAEoBVIHZGVsYXlNcw==');

@$core.Deprecated('Use modemConfigSettingsResponseDescriptor instead')
const ModemConfigSettingsResponse$json = {
  '1': 'ModemConfigSettingsResponse',
  '2': [
    {'1': 'comm_speed', '3': 1, '4': 1, '5': 5, '10': 'commSpeed'},
    {'1': 'modem_profile', '3': 2, '4': 1, '5': 9, '10': 'modemProfile'},
    {
      '1': 'init_strings',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.meter.ModemInitStringEntry',
      '10': 'initStrings'
    },
    {'1': 'show_init_string', '3': 4, '4': 1, '5': 8, '10': 'showInitString'},
  ],
};

/// Descriptor for `ModemConfigSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modemConfigSettingsResponseDescriptor = $convert.base64Decode(
    'ChtNb2RlbUNvbmZpZ1NldHRpbmdzUmVzcG9uc2USHQoKY29tbV9zcGVlZBgBIAEoBVIJY29tbV'
    'NwZWVkEiMKDW1vZGVtX3Byb2ZpbGUYAiABKAlSDG1vZGVtUHJvZmlsZRI+Cgxpbml0X3N0cmlu'
    'Z3MYAyADKAsyGy5tZXRlci5Nb2RlbUluaXRTdHJpbmdFbnRyeVILaW5pdFN0cmluZ3MSKAoQc2'
    'hvd19pbml0X3N0cmluZxgEIAEoCFIOc2hvd0luaXRTdHJpbmc=');

@$core.Deprecated('Use setCommSpeedRequestDescriptor instead')
const SetCommSpeedRequest$json = {
  '1': 'SetCommSpeedRequest',
  '2': [
    {'1': 'speed_index', '3': 1, '4': 1, '5': 5, '10': 'speedIndex'},
  ],
};

/// Descriptor for `SetCommSpeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCommSpeedRequestDescriptor = $convert.base64Decode(
    'ChNTZXRDb21tU3BlZWRSZXF1ZXN0Eh8KC3NwZWVkX2luZGV4GAEgASgFUgpzcGVlZEluZGV4');

@$core.Deprecated('Use setModemProfileRequestDescriptor instead')
const SetModemProfileRequest$json = {
  '1': 'SetModemProfileRequest',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 9, '10': 'profile'},
  ],
};

/// Descriptor for `SetModemProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setModemProfileRequestDescriptor =
    $convert.base64Decode(
        'ChZTZXRNb2RlbVByb2ZpbGVSZXF1ZXN0EhgKB3Byb2ZpbGUYASABKAlSB3Byb2ZpbGU=');

@$core.Deprecated('Use setInitStringsRequestDescriptor instead')
const SetInitStringsRequest$json = {
  '1': 'SetInitStringsRequest',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.ModemInitStringEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `SetInitStringsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setInitStringsRequestDescriptor = $convert.base64Decode(
    'ChVTZXRJbml0U3RyaW5nc1JlcXVlc3QSNQoHZW50cmllcxgBIAMoCzIbLm1ldGVyLk1vZGVtSW'
    '5pdFN0cmluZ0VudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use callingWindowEntryDescriptor instead')
const CallingWindowEntry$json = {
  '1': 'CallingWindowEntry',
  '2': [
    {'1': 'start_time', '3': 1, '4': 1, '5': 9, '10': 'startTime'},
    {'1': 'end_time', '3': 2, '4': 1, '5': 9, '10': 'endTime'},
  ],
};

/// Descriptor for `CallingWindowEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callingWindowEntryDescriptor = $convert.base64Decode(
    'ChJDYWxsaW5nV2luZG93RW50cnkSHQoKc3RhcnRfdGltZRgBIAEoCVIJc3RhcnRUaW1lEhkKCG'
    'VuZF90aW1lGAIgASgJUgdlbmRUaW1l');

@$core.Deprecated('Use destinationEntryDescriptor instead')
const DestinationEntry$json = {
  '1': 'DestinationEntry',
  '2': [
    {'1': 'ip_address', '3': 1, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'port', '3': 2, '4': 1, '5': 5, '10': 'port'},
  ],
};

/// Descriptor for `DestinationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List destinationEntryDescriptor = $convert.base64Decode(
    'ChBEZXN0aW5hdGlvbkVudHJ5Eh0KCmlwX2FkZHJlc3MYASABKAlSCWlwQWRkcmVzcxISCgRwb3'
    'J0GAIgASgFUgRwb3J0');

@$core.Deprecated('Use autoConnectResponseDescriptor instead')
const AutoConnectResponse$json = {
  '1': 'AutoConnectResponse',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 5, '10': 'mode'},
    {'1': 'repetitions', '3': 2, '4': 1, '5': 5, '10': 'repetitions'},
    {'1': 'repetition_delay', '3': 3, '4': 1, '5': 5, '10': 'repetitionDelay'},
    {
      '1': 'calling_window',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.meter.CallingWindowEntry',
      '10': 'callingWindow'
    },
    {
      '1': 'destination_list',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.meter.DestinationEntry',
      '10': 'destinationList'
    },
  ],
};

/// Descriptor for `AutoConnectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List autoConnectResponseDescriptor = $convert.base64Decode(
    'ChNBdXRvQ29ubmVjdFJlc3BvbnNlEhIKBG1vZGUYASABKAVSBG1vZGUSIAoLcmVwZXRpdGlvbn'
    'MYAiABKAVSC3JlcGV0aXRpb25zEikKEHJlcGV0aXRpb25fZGVsYXkYAyABKAVSD3JlcGV0aXRp'
    'b25EZWxheRJACg5jYWxsaW5nX3dpbmRvdxgEIAMoCzIZLm1ldGVyLkNhbGxpbmdXaW5kb3dFbn'
    'RyeVINY2FsbGluZ1dpbmRvdxJCChBkZXN0aW5hdGlvbl9saXN0GAUgAygLMhcubWV0ZXIuRGVz'
    'dGluYXRpb25FbnRyeVIPZGVzdGluYXRpb25MaXN0');

@$core.Deprecated('Use setAutoConnectRequestDescriptor instead')
const SetAutoConnectRequest$json = {
  '1': 'SetAutoConnectRequest',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 5, '10': 'mode'},
    {'1': 'repetitions', '3': 2, '4': 1, '5': 5, '10': 'repetitions'},
    {'1': 'repetition_delay', '3': 3, '4': 1, '5': 5, '10': 'repetitionDelay'},
    {
      '1': 'calling_window',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.meter.CallingWindowEntry',
      '10': 'callingWindow'
    },
  ],
};

/// Descriptor for `SetAutoConnectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAutoConnectRequestDescriptor = $convert.base64Decode(
    'ChVTZXRBdXRvQ29ubmVjdFJlcXVlc3QSEgoEbW9kZRgBIAEoBVIEbW9kZRIgCgtyZXBldGl0aW'
    '9ucxgCIAEoBVILcmVwZXRpdGlvbnMSKQoQcmVwZXRpdGlvbl9kZWxheRgDIAEoBVIPcmVwZXRp'
    'dGlvbkRlbGF5EkAKDmNhbGxpbmdfd2luZG93GAQgAygLMhkubWV0ZXIuQ2FsbGluZ1dpbmRvd0'
    'VudHJ5Ug1jYWxsaW5nV2luZG93');

@$core.Deprecated('Use allowedCallerEntryDescriptor instead')
const AllowedCallerEntry$json = {
  '1': 'AllowedCallerEntry',
  '2': [
    {'1': 'caller_id', '3': 1, '4': 1, '5': 9, '10': 'callerId'},
    {'1': 'call_type', '3': 2, '4': 1, '5': 5, '10': 'callType'},
  ],
};

/// Descriptor for `AllowedCallerEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allowedCallerEntryDescriptor = $convert.base64Decode(
    'ChJBbGxvd2VkQ2FsbGVyRW50cnkSGwoJY2FsbGVyX2lkGAEgASgJUghjYWxsZXJJZBIbCgljYW'
    'xsX3R5cGUYAiABKAVSCGNhbGxUeXBl');

@$core.Deprecated('Use autoAnswerResponseDescriptor instead')
const AutoAnswerResponse$json = {
  '1': 'AutoAnswerResponse',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 5, '10': 'mode'},
    {'1': 'number_of_calls', '3': 2, '4': 1, '5': 5, '10': 'numberOfCalls'},
    {'1': 'rings_in_window', '3': 3, '4': 1, '5': 5, '10': 'ringsInWindow'},
    {'1': 'rings_out_window', '3': 4, '4': 1, '5': 5, '10': 'ringsOutWindow'},
    {'1': 'status', '3': 5, '4': 1, '5': 5, '10': 'status'},
    {
      '1': 'allowed_callers',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.meter.AllowedCallerEntry',
      '10': 'allowedCallers'
    },
    {
      '1': 'listening_window',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.meter.CallingWindowEntry',
      '10': 'listeningWindow'
    },
  ],
};

/// Descriptor for `AutoAnswerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List autoAnswerResponseDescriptor = $convert.base64Decode(
    'ChJBdXRvQW5zd2VyUmVzcG9uc2USEgoEbW9kZRgBIAEoBVIEbW9kZRImCg9udW1iZXJfb2ZfY2'
    'FsbHMYAiABKAVSDW51bWJlck9mQ2FsbHMSJgoPcmluZ3NfaW5fd2luZG93GAMgASgFUg1yaW5n'
    'c0luV2luZG93EigKEHJpbmdzX291dF93aW5kb3cYBCABKAVSDnJpbmdzT3V0V2luZG93EhYKBn'
    'N0YXR1cxgFIAEoBVIGc3RhdHVzEkIKD2FsbG93ZWRfY2FsbGVycxgGIAMoCzIZLm1ldGVyLkFs'
    'bG93ZWRDYWxsZXJFbnRyeVIOYWxsb3dlZENhbGxlcnMSRAoQbGlzdGVuaW5nX3dpbmRvdxgHIA'
    'MoCzIZLm1ldGVyLkNhbGxpbmdXaW5kb3dFbnRyeVIPbGlzdGVuaW5nV2luZG93');

@$core.Deprecated('Use setAutoAnswerRequestDescriptor instead')
const SetAutoAnswerRequest$json = {
  '1': 'SetAutoAnswerRequest',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 5, '10': 'mode'},
    {'1': 'number_of_calls', '3': 2, '4': 1, '5': 5, '10': 'numberOfCalls'},
    {'1': 'rings_in_window', '3': 3, '4': 1, '5': 5, '10': 'ringsInWindow'},
    {'1': 'rings_out_window', '3': 4, '4': 1, '5': 5, '10': 'ringsOutWindow'},
    {
      '1': 'allowed_callers',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.meter.AllowedCallerEntry',
      '10': 'allowedCallers'
    },
    {
      '1': 'listening_window',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.meter.CallingWindowEntry',
      '10': 'listeningWindow'
    },
  ],
};

/// Descriptor for `SetAutoAnswerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAutoAnswerRequestDescriptor = $convert.base64Decode(
    'ChRTZXRBdXRvQW5zd2VyUmVxdWVzdBISCgRtb2RlGAEgASgFUgRtb2RlEiYKD251bWJlcl9vZl'
    '9jYWxscxgCIAEoBVINbnVtYmVyT2ZDYWxscxImCg9yaW5nc19pbl93aW5kb3cYAyABKAVSDXJp'
    'bmdzSW5XaW5kb3cSKAoQcmluZ3Nfb3V0X3dpbmRvdxgEIAEoBVIOcmluZ3NPdXRXaW5kb3cSQg'
    'oPYWxsb3dlZF9jYWxsZXJzGAUgAygLMhkubWV0ZXIuQWxsb3dlZENhbGxlckVudHJ5Ug5hbGxv'
    'd2VkQ2FsbGVycxJEChBsaXN0ZW5pbmdfd2luZG93GAYgAygLMhkubWV0ZXIuQ2FsbGluZ1dpbm'
    'Rvd0VudHJ5Ug9saXN0ZW5pbmdXaW5kb3c=');

@$core.Deprecated('Use tcpUdpSetupResponseDescriptor instead')
const TcpUdpSetupResponse$json = {
  '1': 'TcpUdpSetupResponse',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 5, '10': 'port'},
    {'1': 'ip_reference', '3': 2, '4': 1, '5': 9, '10': 'ipReference'},
    {'1': 'mss', '3': 3, '4': 1, '5': 5, '10': 'mss'},
    {'1': 'nb_connections', '3': 4, '4': 1, '5': 5, '10': 'nbConnections'},
    {
      '1': 'inactivity_timeout',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'inactivityTimeout'
    },
  ],
};

/// Descriptor for `TcpUdpSetupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tcpUdpSetupResponseDescriptor = $convert.base64Decode(
    'ChNUY3BVZHBTZXR1cFJlc3BvbnNlEhIKBHBvcnQYASABKAVSBHBvcnQSIQoMaXBfcmVmZXJlbm'
    'NlGAIgASgJUgtpcFJlZmVyZW5jZRIQCgNtc3MYAyABKAVSA21zcxIlCg5uYl9jb25uZWN0aW9u'
    'cxgEIAEoBVINbmJDb25uZWN0aW9ucxItChJpbmFjdGl2aXR5X3RpbWVvdXQYBSABKAVSEWluYW'
    'N0aXZpdHlUaW1lb3V0');

@$core.Deprecated('Use setTcpUdpSetupRequestDescriptor instead')
const SetTcpUdpSetupRequest$json = {
  '1': 'SetTcpUdpSetupRequest',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 5, '10': 'port'},
    {'1': 'mss', '3': 2, '4': 1, '5': 5, '10': 'mss'},
    {'1': 'nb_connections', '3': 3, '4': 1, '5': 5, '10': 'nbConnections'},
    {
      '1': 'inactivity_timeout',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'inactivityTimeout'
    },
  ],
};

/// Descriptor for `SetTcpUdpSetupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTcpUdpSetupRequestDescriptor = $convert.base64Decode(
    'ChVTZXRUY3BVZHBTZXR1cFJlcXVlc3QSEgoEcG9ydBgBIAEoBVIEcG9ydBIQCgNtc3MYAiABKA'
    'VSA21zcxIlCg5uYl9jb25uZWN0aW9ucxgDIAEoBVINbmJDb25uZWN0aW9ucxItChJpbmFjdGl2'
    'aXR5X3RpbWVvdXQYBCABKAVSEWluYWN0aXZpdHlUaW1lb3V0');

@$core.Deprecated('Use calendarTimeValueDescriptor instead')
const CalendarTimeValue$json = {
  '1': 'CalendarTimeValue',
  '2': [
    {'1': 'hour', '3': 1, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'minute', '3': 2, '4': 1, '5': 5, '10': 'minute'},
    {'1': 'second', '3': 3, '4': 1, '5': 5, '10': 'second'},
    {'1': 'hundredths', '3': 4, '4': 1, '5': 5, '10': 'hundredths'},
  ],
};

/// Descriptor for `CalendarTimeValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarTimeValueDescriptor = $convert.base64Decode(
    'ChFDYWxlbmRhclRpbWVWYWx1ZRISCgRob3VyGAEgASgFUgRob3VyEhYKBm1pbnV0ZRgCIAEoBV'
    'IGbWludXRlEhYKBnNlY29uZBgDIAEoBVIGc2Vjb25kEh4KCmh1bmRyZWR0aHMYBCABKAVSCmh1'
    'bmRyZWR0aHM=');

@$core.Deprecated('Use calendarDateValueDescriptor instead')
const CalendarDateValue$json = {
  '1': 'CalendarDateValue',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day_of_month', '3': 3, '4': 1, '5': 5, '10': 'dayOfMonth'},
    {'1': 'day_of_week', '3': 4, '4': 1, '5': 5, '10': 'dayOfWeek'},
  ],
};

/// Descriptor for `CalendarDateValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDateValueDescriptor = $convert.base64Decode(
    'ChFDYWxlbmRhckRhdGVWYWx1ZRISCgR5ZWFyGAEgASgFUgR5ZWFyEhQKBW1vbnRoGAIgASgFUg'
    'Vtb250aBIgCgxkYXlfb2ZfbW9udGgYAyABKAVSCmRheU9mTW9udGgSHgoLZGF5X29mX3dlZWsY'
    'BCABKAVSCWRheU9mV2Vlaw==');

@$core.Deprecated('Use dayProfileActionDescriptor instead')
const DayProfileAction$json = {
  '1': 'DayProfileAction',
  '2': [
    {
      '1': 'start_time',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.meter.CalendarTimeValue',
      '10': 'startTime'
    },
    {
      '1': 'script_logical_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'scriptLogicalName'
    },
    {'1': 'script_selector', '3': 3, '4': 1, '5': 5, '10': 'scriptSelector'},
  ],
};

/// Descriptor for `DayProfileAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dayProfileActionDescriptor = $convert.base64Decode(
    'ChBEYXlQcm9maWxlQWN0aW9uEjcKCnN0YXJ0X3RpbWUYASABKAsyGC5tZXRlci5DYWxlbmRhcl'
    'RpbWVWYWx1ZVIJc3RhcnRUaW1lEi4KE3NjcmlwdF9sb2dpY2FsX25hbWUYAiABKAlSEXNjcmlw'
    'dExvZ2ljYWxOYW1lEicKD3NjcmlwdF9zZWxlY3RvchgDIAEoBVIOc2NyaXB0U2VsZWN0b3I=');

@$core.Deprecated('Use calendarDayProfileDescriptor instead')
const CalendarDayProfile$json = {
  '1': 'CalendarDayProfile',
  '2': [
    {'1': 'day_id', '3': 1, '4': 1, '5': 5, '10': 'dayId'},
    {
      '1': 'day_schedule',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.DayProfileAction',
      '10': 'daySchedule'
    },
  ],
};

/// Descriptor for `CalendarDayProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDayProfileDescriptor = $convert.base64Decode(
    'ChJDYWxlbmRhckRheVByb2ZpbGUSFQoGZGF5X2lkGAEgASgFUgVkYXlJZBI6CgxkYXlfc2NoZW'
    'R1bGUYAiADKAsyFy5tZXRlci5EYXlQcm9maWxlQWN0aW9uUgtkYXlTY2hlZHVsZQ==');

@$core.Deprecated('Use calendarWeekProfileDescriptor instead')
const CalendarWeekProfile$json = {
  '1': 'CalendarWeekProfile',
  '2': [
    {'1': 'week_profile_name', '3': 1, '4': 1, '5': 9, '10': 'weekProfileName'},
    {'1': 'monday', '3': 2, '4': 1, '5': 5, '10': 'monday'},
    {'1': 'tuesday', '3': 3, '4': 1, '5': 5, '10': 'tuesday'},
    {'1': 'wednesday', '3': 4, '4': 1, '5': 5, '10': 'wednesday'},
    {'1': 'thursday', '3': 5, '4': 1, '5': 5, '10': 'thursday'},
    {'1': 'friday', '3': 6, '4': 1, '5': 5, '10': 'friday'},
    {'1': 'saturday', '3': 7, '4': 1, '5': 5, '10': 'saturday'},
    {'1': 'sunday', '3': 8, '4': 1, '5': 5, '10': 'sunday'},
  ],
};

/// Descriptor for `CalendarWeekProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarWeekProfileDescriptor = $convert.base64Decode(
    'ChNDYWxlbmRhcldlZWtQcm9maWxlEioKEXdlZWtfcHJvZmlsZV9uYW1lGAEgASgJUg93ZWVrUH'
    'JvZmlsZU5hbWUSFgoGbW9uZGF5GAIgASgFUgZtb25kYXkSGAoHdHVlc2RheRgDIAEoBVIHdHVl'
    'c2RheRIcCgl3ZWRuZXNkYXkYBCABKAVSCXdlZG5lc2RheRIaCgh0aHVyc2RheRgFIAEoBVIIdG'
    'h1cnNkYXkSFgoGZnJpZGF5GAYgASgFUgZmcmlkYXkSGgoIc2F0dXJkYXkYByABKAVSCHNhdHVy'
    'ZGF5EhYKBnN1bmRheRgIIAEoBVIGc3VuZGF5');

@$core.Deprecated('Use calendarSeasonProfileDescriptor instead')
const CalendarSeasonProfile$json = {
  '1': 'CalendarSeasonProfile',
  '2': [
    {
      '1': 'season_profile_name',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'seasonProfileName'
    },
    {
      '1': 'season_start',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.CalendarDateValue',
      '10': 'seasonStart'
    },
    {'1': 'week_profile_name', '3': 3, '4': 1, '5': 9, '10': 'weekProfileName'},
  ],
};

/// Descriptor for `CalendarSeasonProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarSeasonProfileDescriptor = $convert.base64Decode(
    'ChVDYWxlbmRhclNlYXNvblByb2ZpbGUSLgoTc2Vhc29uX3Byb2ZpbGVfbmFtZRgBIAEoCVIRc2'
    'Vhc29uUHJvZmlsZU5hbWUSOwoMc2Vhc29uX3N0YXJ0GAIgASgLMhgubWV0ZXIuQ2FsZW5kYXJE'
    'YXRlVmFsdWVSC3NlYXNvblN0YXJ0EioKEXdlZWtfcHJvZmlsZV9uYW1lGAMgASgJUg93ZWVrUH'
    'JvZmlsZU5hbWU=');

@$core.Deprecated('Use activityCalendarDataDescriptor instead')
const ActivityCalendarData$json = {
  '1': 'ActivityCalendarData',
  '2': [
    {'1': 'calendar_name', '3': 1, '4': 1, '5': 9, '10': 'calendarName'},
    {
      '1': 'season_profiles',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meter.CalendarSeasonProfile',
      '10': 'seasonProfiles'
    },
    {
      '1': 'week_profiles',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.meter.CalendarWeekProfile',
      '10': 'weekProfiles'
    },
    {
      '1': 'day_profiles',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.meter.CalendarDayProfile',
      '10': 'dayProfiles'
    },
  ],
};

/// Descriptor for `ActivityCalendarData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activityCalendarDataDescriptor = $convert.base64Decode(
    'ChRBY3Rpdml0eUNhbGVuZGFyRGF0YRIjCg1jYWxlbmRhcl9uYW1lGAEgASgJUgxjYWxlbmRhck'
    '5hbWUSRQoPc2Vhc29uX3Byb2ZpbGVzGAIgAygLMhwubWV0ZXIuQ2FsZW5kYXJTZWFzb25Qcm9m'
    'aWxlUg5zZWFzb25Qcm9maWxlcxI/Cg13ZWVrX3Byb2ZpbGVzGAMgAygLMhoubWV0ZXIuQ2FsZW'
    '5kYXJXZWVrUHJvZmlsZVIMd2Vla1Byb2ZpbGVzEjwKDGRheV9wcm9maWxlcxgEIAMoCzIZLm1l'
    'dGVyLkNhbGVuZGFyRGF5UHJvZmlsZVILZGF5UHJvZmlsZXM=');

@$core.Deprecated('Use specialDayEntryDescriptor instead')
const SpecialDayEntry$json = {
  '1': 'SpecialDayEntry',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {
      '1': 'special_day_date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meter.CalendarDateValue',
      '10': 'specialDayDate'
    },
    {'1': 'day_id', '3': 3, '4': 1, '5': 5, '10': 'dayId'},
  ],
};

/// Descriptor for `SpecialDayEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List specialDayEntryDescriptor = $convert.base64Decode(
    'Cg9TcGVjaWFsRGF5RW50cnkSFAoFaW5kZXgYASABKAVSBWluZGV4EkIKEHNwZWNpYWxfZGF5X2'
    'RhdGUYAiABKAsyGC5tZXRlci5DYWxlbmRhckRhdGVWYWx1ZVIOc3BlY2lhbERheURhdGUSFQoG'
    'ZGF5X2lkGAMgASgFUgVkYXlJZA==');

@$core.Deprecated('Use specialDayTableDescriptor instead')
const SpecialDayTable$json = {
  '1': 'SpecialDayTable',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.SpecialDayEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `SpecialDayTable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List specialDayTableDescriptor = $convert.base64Decode(
    'Cg9TcGVjaWFsRGF5VGFibGUSMAoHZW50cmllcxgBIAMoCzIWLm1ldGVyLlNwZWNpYWxEYXlFbn'
    'RyeVIHZW50cmllcw==');

@$core.Deprecated('Use calendarActivationTimeDescriptor instead')
const CalendarActivationTime$json = {
  '1': 'CalendarActivationTime',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 5, '10': 'day'},
    {'1': 'hour', '3': 4, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'minute', '3': 5, '4': 1, '5': 5, '10': 'minute'},
    {'1': 'second', '3': 6, '4': 1, '5': 5, '10': 'second'},
  ],
};

/// Descriptor for `CalendarActivationTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarActivationTimeDescriptor = $convert.base64Decode(
    'ChZDYWxlbmRhckFjdGl2YXRpb25UaW1lEhIKBHllYXIYASABKAVSBHllYXISFAoFbW9udGgYAi'
    'ABKAVSBW1vbnRoEhAKA2RheRgDIAEoBVIDZGF5EhIKBGhvdXIYBCABKAVSBGhvdXISFgoGbWlu'
    'dXRlGAUgASgFUgZtaW51dGUSFgoGc2Vjb25kGAYgASgFUgZzZWNvbmQ=');

@$core.Deprecated('Use exportDataRequestDescriptor instead')
const ExportDataRequest$json = {
  '1': 'ExportDataRequest',
  '2': [
    {'1': 'page_id', '3': 1, '4': 1, '5': 9, '10': 'pageId'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    {'1': 'folder_path', '3': 4, '4': 1, '5': 9, '10': 'folderPath'},
    {'1': 'page_type', '3': 5, '4': 1, '5': 9, '10': 'pageType'},
    {'1': 'file_name_suffix', '3': 6, '4': 1, '5': 9, '10': 'fileNameSuffix'},
  ],
};

/// Descriptor for `ExportDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportDataRequestDescriptor = $convert.base64Decode(
    'ChFFeHBvcnREYXRhUmVxdWVzdBIXCgdwYWdlX2lkGAEgASgJUgZwYWdlSWQSEgoEdHlwZRgCIA'
    'EoCVIEdHlwZRISCgRkYXRhGAMgASgJUgRkYXRhEh8KC2ZvbGRlcl9wYXRoGAQgASgJUgpmb2xk'
    'ZXJQYXRoEhsKCXBhZ2VfdHlwZRgFIAEoCVIIcGFnZVR5cGUSKAoQZmlsZV9uYW1lX3N1ZmZpeB'
    'gGIAEoCVIOZmlsZU5hbWVTdWZmaXg=');

@$core.Deprecated('Use exportDataResponseDescriptor instead')
const ExportDataResponse$json = {
  '1': 'ExportDataResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `ExportDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportDataResponseDescriptor =
    $convert.base64Decode(
        'ChJFeHBvcnREYXRhUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use startPushSetupServerRequestDescriptor instead')
const StartPushSetupServerRequest$json = {
  '1': 'StartPushSetupServerRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'port', '3': 2, '4': 1, '5': 5, '10': 'port'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `StartPushSetupServerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startPushSetupServerRequestDescriptor =
    $convert.base64Decode(
        'ChtTdGFydFB1c2hTZXR1cFNlcnZlclJlcXVlc3QSEgoEaG9zdBgBIAEoCVIEaG9zdBISCgRwb3'
        'J0GAIgASgFUgRwb3J0EhIKBHR5cGUYAyABKAlSBHR5cGU=');

@$core.Deprecated('Use pushNotificationDescriptor instead')
const PushNotification$json = {
  '1': 'PushNotification',
  '2': [
    {'1': 'xml', '3': 1, '4': 1, '5': 9, '10': 'xml'},
  ],
};

/// Descriptor for `PushNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushNotificationDescriptor =
    $convert.base64Decode('ChBQdXNoTm90aWZpY2F0aW9uEhAKA3htbBgBIAEoCVIDeG1s');

@$core.Deprecated('Use retryStatusUpdateDescriptor instead')
const RetryStatusUpdate$json = {
  '1': 'RetryStatusUpdate',
  '2': [
    {'1': 'attempt', '3': 1, '4': 1, '5': 5, '10': 'attempt'},
    {'1': 'max_attempts', '3': 2, '4': 1, '5': 5, '10': 'maxAttempts'},
    {'1': 'all_failed', '3': 3, '4': 1, '5': 8, '10': 'allFailed'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RetryStatusUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retryStatusUpdateDescriptor = $convert.base64Decode(
    'ChFSZXRyeVN0YXR1c1VwZGF0ZRIYCgdhdHRlbXB0GAEgASgFUgdhdHRlbXB0EiEKDG1heF9hdH'
    'RlbXB0cxgCIAEoBVILbWF4QXR0ZW1wdHMSHQoKYWxsX2ZhaWxlZBgDIAEoCFIJYWxsRmFpbGVk'
    'EhgKB21lc3NhZ2UYBCABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use getLteNetworkParametersResponseDescriptor instead')
const GetLteNetworkParametersResponse$json = {
  '1': 'GetLteNetworkParametersResponse',
  '2': [
    {'1': 't3402', '3': 1, '4': 1, '5': 5, '10': 't3402'},
    {'1': 't3412', '3': 2, '4': 1, '5': 5, '10': 't3412'},
    {'1': 't3412ext2', '3': 3, '4': 1, '5': 5, '10': 't3412ext2'},
    {'1': 't3324', '3': 4, '4': 1, '5': 5, '10': 't3324'},
    {'1': 't_edrx', '3': 5, '4': 1, '5': 5, '10': 'tEdrx'},
    {'1': 'tptw', '3': 6, '4': 1, '5': 5, '10': 'tptw'},
    {'1': 'q_rxlev_min', '3': 7, '4': 1, '5': 5, '10': 'qRxlevMin'},
    {'1': 'q_rxlev_min_ce_r13', '3': 8, '4': 1, '5': 5, '10': 'qRxlevMinCeR13'},
    {
      '1': 'q_rxlev_min_ce1_r13',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'qRxlevMinCe1R13'
    },
  ],
};

/// Descriptor for `GetLteNetworkParametersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLteNetworkParametersResponseDescriptor = $convert.base64Decode(
    'Ch9HZXRMdGVOZXR3b3JrUGFyYW1ldGVyc1Jlc3BvbnNlEhQKBXQzNDAyGAEgASgFUgV0MzQwMh'
    'IUCgV0MzQxMhgCIAEoBVIFdDM0MTISHAoJdDM0MTJleHQyGAMgASgFUgl0MzQxMmV4dDISFAoF'
    'dDMzMjQYBCABKAVSBXQzMzI0EhUKBnRfZWRyeBgFIAEoBVIFdEVkcngSEgoEdHB0dxgGIAEoBV'
    'IEdHB0dxIeCgtxX3J4bGV2X21pbhgHIAEoBVIJcVJ4bGV2TWluEioKEnFfcnhsZXZfbWluX2Nl'
    'X3IxMxgIIAEoBVIOcVJ4bGV2TWluQ2VSMTMSLAoTcV9yeGxldl9taW5fY2UxX3IxMxgJIAEoBV'
    'IPcVJ4bGV2TWluQ2UxUjEz');

@$core.Deprecated('Use getLteQosResponseDescriptor instead')
const GetLteQosResponse$json = {
  '1': 'GetLteQosResponse',
  '2': [
    {'1': 'nrsrq', '3': 1, '4': 1, '5': 5, '10': 'nrsrq'},
    {'1': 'nrsrp', '3': 2, '4': 1, '5': 5, '10': 'nrsrp'},
    {'1': 'snr', '3': 3, '4': 1, '5': 5, '10': 'snr'},
    {
      '1': 'coverage_enhancement',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'coverageEnhancement'
    },
  ],
};

/// Descriptor for `GetLteQosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLteQosResponseDescriptor = $convert.base64Decode(
    'ChFHZXRMdGVRb3NSZXNwb25zZRIUCgVucnNycRgBIAEoBVIFbnJzcnESFAoFbnJzcnAYAiABKA'
    'VSBW5yc3JwEhAKA3NuchgDIAEoBVIDc25yEjEKFGNvdmVyYWdlX2VuaGFuY2VtZW50GAQgASgF'
    'UhNjb3ZlcmFnZUVuaGFuY2VtZW50');

@$core.Deprecated('Use imageTransferStatusResponseDescriptor instead')
const ImageTransferStatusResponse$json = {
  '1': 'ImageTransferStatusResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 5, '10': 'status'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ImageTransferStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageTransferStatusResponseDescriptor =
    $convert.base64Decode(
        'ChtJbWFnZVRyYW5zZmVyU3RhdHVzUmVzcG9uc2USFgoGc3RhdHVzGAEgASgFUgZzdGF0dXMSFA'
        'oFbGFiZWwYAiABKAlSBWxhYmVs');

@$core.Deprecated('Use getQualityObjectsRequestDescriptor instead')
const GetQualityObjectsRequest$json = {
  '1': 'GetQualityObjectsRequest',
  '2': [
    {'1': 'objects', '3': 1, '4': 3, '5': 9, '10': 'objects'},
  ],
};

/// Descriptor for `GetQualityObjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQualityObjectsRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRRdWFsaXR5T2JqZWN0c1JlcXVlc3QSGAoHb2JqZWN0cxgBIAMoCVIHb2JqZWN0cw==');

@$core.Deprecated('Use getQualityObjectsResponseDescriptor instead')
const GetQualityObjectsResponse$json = {
  '1': 'GetQualityObjectsResponse',
  '2': [
    {
      '1': 'objects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meter.QualityObject',
      '10': 'objects'
    },
  ],
};

/// Descriptor for `GetQualityObjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQualityObjectsResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRRdWFsaXR5T2JqZWN0c1Jlc3BvbnNlEi4KB29iamVjdHMYASADKAsyFC5tZXRlci5RdW'
        'FsaXR5T2JqZWN0UgdvYmplY3Rz');

@$core.Deprecated('Use qualityObjectDescriptor instead')
const QualityObject$json = {
  '1': 'QualityObject',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'scaler', '3': 4, '4': 1, '5': 5, '10': 'scaler'},
  ],
};

/// Descriptor for `QualityObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List qualityObjectDescriptor = $convert.base64Decode(
    'Cg1RdWFsaXR5T2JqZWN0EhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdmFsdWUYAiABKAFSBXZhbH'
    'VlEhIKBHVuaXQYAyABKAlSBHVuaXQSFgoGc2NhbGVyGAQgASgFUgZzY2FsZXI=');

@$core.Deprecated('Use updateQualityObjectRequestDescriptor instead')
const UpdateQualityObjectRequest$json = {
  '1': 'UpdateQualityObjectRequest',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 1, '10': 'value'},
    {'1': 'scaler', '3': 2, '4': 1, '5': 5, '10': 'scaler'},
    {'1': 'datasource', '3': 3, '4': 1, '5': 9, '10': 'datasource'},
  ],
};

/// Descriptor for `UpdateQualityObjectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateQualityObjectRequestDescriptor =
    $convert.base64Decode(
        'ChpVcGRhdGVRdWFsaXR5T2JqZWN0UmVxdWVzdBIUCgV2YWx1ZRgBIAEoAVIFdmFsdWUSFgoGc2'
        'NhbGVyGAIgASgFUgZzY2FsZXISHgoKZGF0YXNvdXJjZRgDIAEoCVIKZGF0YXNvdXJjZQ==');
