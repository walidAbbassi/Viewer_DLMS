// This is a generated file - do not edit.
//
// Generated from echo.proto.

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

@$core.Deprecated('Use echoRequestDescriptor instead')
const EchoRequest$json = {
  '1': 'EchoRequest',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `EchoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List echoRequestDescriptor = $convert
    .base64Decode('CgtFY2hvUmVxdWVzdBIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use echoReplyDescriptor instead')
const EchoReply$json = {
  '1': 'EchoReply',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `EchoReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List echoReplyDescriptor = $convert
    .base64Decode('CglFY2hvUmVwbHkSGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use sumRequestDescriptor instead')
const SumRequest$json = {
  '1': 'SumRequest',
  '2': [
    {'1': 'numbers', '3': 1, '4': 3, '5': 5, '10': 'numbers'},
  ],
};

/// Descriptor for `SumRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sumRequestDescriptor = $convert
    .base64Decode('CgpTdW1SZXF1ZXN0EhgKB251bWJlcnMYASADKAVSB251bWJlcnM=');

@$core.Deprecated('Use sumReplyDescriptor instead')
const SumReply$json = {
  '1': 'SumReply',
  '2': [
    {'1': 'sum', '3': 1, '4': 1, '5': 3, '10': 'sum'},
  ],
};

/// Descriptor for `SumReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sumReplyDescriptor =
    $convert.base64Decode('CghTdW1SZXBseRIQCgNzdW0YASABKANSA3N1bQ==');
