// This is a generated file - do not edit.
//
// Generated from configuration.proto.

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

@$core.Deprecated('Use configEntryDescriptor instead')
const ConfigEntry$json = {
  '1': 'ConfigEntry',
  '2': [
    {'1': 'module', '3': 1, '4': 1, '5': 9, '10': 'module'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'value'
    },
  ],
};

/// Descriptor for `ConfigEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configEntryDescriptor = $convert.base64Decode(
    'CgtDb25maWdFbnRyeRIWCgZtb2R1bGUYASABKAlSBm1vZHVsZRIQCgNrZXkYAiABKAlSA2tleR'
    'IqCgV2YWx1ZRgDIAEoCzIULmdvb2dsZS5wcm90b2J1Zi5BbnlSBXZhbHVl');

@$core.Deprecated('Use setConfigRequestDescriptor instead')
const SetConfigRequest$json = {
  '1': 'SetConfigRequest',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.ConfigEntry',
      '10': 'entries'
    },
    {'1': 'to_file', '3': 2, '4': 1, '5': 8, '10': 'toFile'},
  ],
};

/// Descriptor for `SetConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setConfigRequestDescriptor = $convert.base64Decode(
    'ChBTZXRDb25maWdSZXF1ZXN0Ei0KB2VudHJpZXMYASADKAsyEy5jb25maWcuQ29uZmlnRW50cn'
    'lSB2VudHJpZXMSFwoHdG9fZmlsZRgCIAEoCFIGdG9GaWxl');

@$core.Deprecated('Use setConfigResponseDescriptor instead')
const SetConfigResponse$json = {
  '1': 'SetConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setConfigResponseDescriptor = $convert.base64Decode(
    'ChFTZXRDb25maWdSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2'
    'UYAiABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use configIdentifierDescriptor instead')
const ConfigIdentifier$json = {
  '1': 'ConfigIdentifier',
  '2': [
    {'1': 'module', '3': 1, '4': 1, '5': 9, '10': 'module'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `ConfigIdentifier`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configIdentifierDescriptor = $convert.base64Decode(
    'ChBDb25maWdJZGVudGlmaWVyEhYKBm1vZHVsZRgBIAEoCVIGbW9kdWxlEhAKA2tleRgCIAEoCV'
    'IDa2V5');

@$core.Deprecated('Use getConfigRequestDescriptor instead')
const GetConfigRequest$json = {
  '1': 'GetConfigRequest',
  '2': [
    {
      '1': 'identifiers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.ConfigIdentifier',
      '10': 'identifiers'
    },
  ],
};

/// Descriptor for `GetConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConfigRequestDescriptor = $convert.base64Decode(
    'ChBHZXRDb25maWdSZXF1ZXN0EjoKC2lkZW50aWZpZXJzGAEgAygLMhguY29uZmlnLkNvbmZpZ0'
    'lkZW50aWZpZXJSC2lkZW50aWZpZXJz');

@$core.Deprecated('Use getConfigResponseDescriptor instead')
const GetConfigResponse$json = {
  '1': 'GetConfigResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.ConfigEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `GetConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConfigResponseDescriptor = $convert.base64Decode(
    'ChFHZXRDb25maWdSZXNwb25zZRItCgdlbnRyaWVzGAEgAygLMhMuY29uZmlnLkNvbmZpZ0VudH'
    'J5UgdlbnRyaWVz');

@$core.Deprecated('Use listModulesResponseDescriptor instead')
const ListModulesResponse$json = {
  '1': 'ListModulesResponse',
  '2': [
    {'1': 'modules', '3': 1, '4': 3, '5': 9, '10': 'modules'},
  ],
};

/// Descriptor for `ListModulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listModulesResponseDescriptor =
    $convert.base64Decode(
        'ChNMaXN0TW9kdWxlc1Jlc3BvbnNlEhgKB21vZHVsZXMYASADKAlSB21vZHVsZXM=');

@$core.Deprecated('Use setExportTemplatesRequestDescriptor instead')
const SetExportTemplatesRequest$json = {
  '1': 'SetExportTemplatesRequest',
  '2': [
    {'1': 'page_name', '3': 1, '4': 1, '5': 9, '10': 'pageName'},
    {'1': 'xml_template', '3': 2, '4': 1, '5': 9, '10': 'xmlTemplate'},
    {'1': 'csv_template', '3': 3, '4': 1, '5': 9, '10': 'csvTemplate'},
    {'1': 'pdf_template', '3': 4, '4': 1, '5': 9, '10': 'pdfTemplate'},
    {'1': 'docx_template', '3': 5, '4': 1, '5': 9, '10': 'docxTemplate'},
  ],
};

/// Descriptor for `SetExportTemplatesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setExportTemplatesRequestDescriptor = $convert.base64Decode(
    'ChlTZXRFeHBvcnRUZW1wbGF0ZXNSZXF1ZXN0EhsKCXBhZ2VfbmFtZRgBIAEoCVIIcGFnZU5hbW'
    'USIQoMeG1sX3RlbXBsYXRlGAIgASgJUgt4bWxUZW1wbGF0ZRIhCgxjc3ZfdGVtcGxhdGUYAyAB'
    'KAlSC2NzdlRlbXBsYXRlEiEKDHBkZl90ZW1wbGF0ZRgEIAEoCVILcGRmVGVtcGxhdGUSIwoNZG'
    '9jeF90ZW1wbGF0ZRgFIAEoCVIMZG9jeFRlbXBsYXRl');

@$core.Deprecated('Use setExportTemplatesResponseDescriptor instead')
const SetExportTemplatesResponse$json = {
  '1': 'SetExportTemplatesResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `SetExportTemplatesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setExportTemplatesResponseDescriptor =
    $convert.base64Decode(
        'ChpTZXRFeHBvcnRUZW1wbGF0ZXNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use getExportTemplatesRequestDescriptor instead')
const GetExportTemplatesRequest$json = {
  '1': 'GetExportTemplatesRequest',
  '2': [
    {'1': 'page_name', '3': 1, '4': 1, '5': 9, '10': 'pageName'},
  ],
};

/// Descriptor for `GetExportTemplatesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExportTemplatesRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRFeHBvcnRUZW1wbGF0ZXNSZXF1ZXN0EhsKCXBhZ2VfbmFtZRgBIAEoCVIIcGFnZU5hbW'
        'U=');

@$core.Deprecated('Use getExportTemplatesResponseDescriptor instead')
const GetExportTemplatesResponse$json = {
  '1': 'GetExportTemplatesResponse',
  '2': [
    {'1': 'xml_template', '3': 1, '4': 1, '5': 9, '10': 'xmlTemplate'},
    {'1': 'csv_template', '3': 2, '4': 1, '5': 9, '10': 'csvTemplate'},
    {'1': 'pdf_template', '3': 3, '4': 1, '5': 9, '10': 'pdfTemplate'},
    {'1': 'docx_template', '3': 4, '4': 1, '5': 9, '10': 'docxTemplate'},
  ],
};

/// Descriptor for `GetExportTemplatesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExportTemplatesResponseDescriptor = $convert.base64Decode(
    'ChpHZXRFeHBvcnRUZW1wbGF0ZXNSZXNwb25zZRIhCgx4bWxfdGVtcGxhdGUYASABKAlSC3htbF'
    'RlbXBsYXRlEiEKDGNzdl90ZW1wbGF0ZRgCIAEoCVILY3N2VGVtcGxhdGUSIQoMcGRmX3RlbXBs'
    'YXRlGAMgASgJUgtwZGZUZW1wbGF0ZRIjCg1kb2N4X3RlbXBsYXRlGAQgASgJUgxkb2N4VGVtcG'
    'xhdGU=');

@$core.Deprecated('Use exportTemplateFileEntryDescriptor instead')
const ExportTemplateFileEntry$json = {
  '1': 'ExportTemplateFileEntry',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'files', '3': 2, '4': 3, '5': 9, '10': 'files'},
  ],
};

/// Descriptor for `ExportTemplateFileEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportTemplateFileEntryDescriptor =
    $convert.base64Decode(
        'ChdFeHBvcnRUZW1wbGF0ZUZpbGVFbnRyeRISCgR0eXBlGAEgASgJUgR0eXBlEhQKBWZpbGVzGA'
        'IgAygJUgVmaWxlcw==');

@$core.Deprecated('Use listExportTemplateFilesResponseDescriptor instead')
const ListExportTemplateFilesResponse$json = {
  '1': 'ListExportTemplateFilesResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.ExportTemplateFileEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `ListExportTemplateFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExportTemplateFilesResponseDescriptor =
    $convert.base64Decode(
        'Ch9MaXN0RXhwb3J0VGVtcGxhdGVGaWxlc1Jlc3BvbnNlEjkKB2VudHJpZXMYASADKAsyHy5jb2'
        '5maWcuRXhwb3J0VGVtcGxhdGVGaWxlRW50cnlSB2VudHJpZXM=');
