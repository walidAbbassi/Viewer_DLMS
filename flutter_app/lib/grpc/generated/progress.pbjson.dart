// This is a generated file - do not edit.
//
// Generated from progress.proto.

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

@$core.Deprecated('Use queryRequestDescriptor instead')
const QueryRequest$json = {
  '1': 'QueryRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `QueryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryRequestDescriptor =
    $convert.base64Decode('CgxRdWVyeVJlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5');

@$core.Deprecated('Use progressUpdateDescriptor instead')
const ProgressUpdate$json = {
  '1': 'ProgressUpdate',
  '2': [
    {'1': 'percent', '3': 1, '4': 1, '5': 5, '10': 'percent'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ProgressUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List progressUpdateDescriptor = $convert.base64Decode(
    'Cg5Qcm9ncmVzc1VwZGF0ZRIYCgdwZXJjZW50GAEgASgFUgdwZXJjZW50EhgKB21lc3NhZ2UYAi'
    'ABKAlSB21lc3NhZ2U=');
