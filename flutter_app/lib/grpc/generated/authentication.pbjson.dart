// This is a generated file - do not edit.
//
// Generated from authentication.proto.

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

@$core.Deprecated('Use importLicenseRequestDescriptor instead')
const ImportLicenseRequest$json = {
  '1': 'ImportLicenseRequest',
  '2': [
    {'1': 'license_path', '3': 1, '4': 1, '5': 9, '10': 'licensePath'},
  ],
};

/// Descriptor for `ImportLicenseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importLicenseRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRMaWNlbnNlUmVxdWVzdBIhCgxsaWNlbnNlX3BhdGgYASABKAlSC2xpY2Vuc2VQYX'
    'Ro');

@$core.Deprecated('Use importLicenseResponseDescriptor instead')
const ImportLicenseResponse$json = {
  '1': 'ImportLicenseResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ImportLicenseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importLicenseResponseDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRMaWNlbnNlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcn'
    'JvchgCIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use connexionRequestDescriptor instead')
const ConnexionRequest$json = {
  '1': 'ConnexionRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `ConnexionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connexionRequestDescriptor = $convert.base64Decode(
    'ChBDb25uZXhpb25SZXF1ZXN0EhoKCHVzZXJuYW1lGAEgASgJUgh1c2VybmFtZRIaCghwYXNzd2'
    '9yZBgCIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use connexionResponseDescriptor instead')
const ConnexionResponse$json = {
  '1': 'ConnexionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'role', '3': 3, '4': 1, '5': 9, '10': 'role'},
    {'1': 'rights', '3': 4, '4': 3, '5': 9, '10': 'rights'},
    {'1': 'disable_features', '3': 5, '4': 3, '5': 9, '10': 'disableFeatures'},
    {'1': 'enterprise', '3': 6, '4': 1, '5': 9, '10': 'enterprise'},
    {
      '1': 'trial_period_start',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'trialPeriodStart'
    },
    {'1': 'trial_period_end', '3': 8, '4': 1, '5': 9, '10': 'trialPeriodEnd'},
    {'1': 'exclude_rights', '3': 9, '4': 3, '5': 9, '10': 'excludeRights'},
  ],
};

/// Descriptor for `ConnexionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connexionResponseDescriptor = $convert.base64Decode(
    'ChFDb25uZXhpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2'
    'UYAiABKAlSB21lc3NhZ2USEgoEcm9sZRgDIAEoCVIEcm9sZRIWCgZyaWdodHMYBCADKAlSBnJp'
    'Z2h0cxIpChBkaXNhYmxlX2ZlYXR1cmVzGAUgAygJUg9kaXNhYmxlRmVhdHVyZXMSHgoKZW50ZX'
    'JwcmlzZRgGIAEoCVIKZW50ZXJwcmlzZRIsChJ0cmlhbF9wZXJpb2Rfc3RhcnQYByABKAlSEHRy'
    'aWFsUGVyaW9kU3RhcnQSKAoQdHJpYWxfcGVyaW9kX2VuZBgIIAEoCVIOdHJpYWxQZXJpb2RFbm'
    'QSJQoOZXhjbHVkZV9yaWdodHMYCSADKAlSDWV4Y2x1ZGVSaWdodHM=');

@$core.Deprecated('Use changePasswordRequestDescriptor instead')
const ChangePasswordRequest$json = {
  '1': 'ChangePasswordRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'old_password', '3': 2, '4': 1, '5': 9, '10': 'oldPassword'},
    {'1': 'new_password', '3': 3, '4': 1, '5': 9, '10': 'newPassword'},
    {'1': 'license', '3': 4, '4': 1, '5': 9, '10': 'license'},
  ],
};

/// Descriptor for `ChangePasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordRequestDescriptor = $convert.base64Decode(
    'ChVDaGFuZ2VQYXNzd29yZFJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEiEKDG'
    '9sZF9wYXNzd29yZBgCIAEoCVILb2xkUGFzc3dvcmQSIQoMbmV3X3Bhc3N3b3JkGAMgASgJUgtu'
    'ZXdQYXNzd29yZBIYCgdsaWNlbnNlGAQgASgJUgdsaWNlbnNl');

@$core.Deprecated('Use changePasswordResponseDescriptor instead')
const ChangePasswordResponse$json = {
  '1': 'ChangePasswordResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ChangePasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordResponseDescriptor =
    $convert.base64Decode(
        'ChZDaGFuZ2VQYXNzd29yZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbW'
        'Vzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use licenseInfoDescriptor instead')
const LicenseInfo$json = {
  '1': 'LicenseInfo',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'file', '3': 2, '4': 1, '5': 9, '10': 'file'},
  ],
};

/// Descriptor for `LicenseInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List licenseInfoDescriptor = $convert.base64Decode(
    'CgtMaWNlbnNlSW5mbxIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSEgoEZmlsZRgCIAEoCVIEZmlsZQ'
    '==');

@$core.Deprecated('Use checkLicenseResponseDescriptor instead')
const CheckLicenseResponse$json = {
  '1': 'CheckLicenseResponse',
  '2': [
    {'1': 'exists', '3': 1, '4': 1, '5': 8, '10': 'exists'},
    {'1': 'identifier', '3': 2, '4': 1, '5': 9, '10': 'identifier'},
    {
      '1': 'licenses',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.authentication.LicenseInfo',
      '10': 'licenses'
    },
  ],
};

/// Descriptor for `CheckLicenseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkLicenseResponseDescriptor = $convert.base64Decode(
    'ChRDaGVja0xpY2Vuc2VSZXNwb25zZRIWCgZleGlzdHMYASABKAhSBmV4aXN0cxIeCgppZGVudG'
    'lmaWVyGAIgASgJUgppZGVudGlmaWVyEjcKCGxpY2Vuc2VzGAMgAygLMhsuYXV0aGVudGljYXRp'
    'b24uTGljZW5zZUluZm9SCGxpY2Vuc2Vz');

@$core.Deprecated('Use deleteLicensesRequestDescriptor instead')
const DeleteLicensesRequest$json = {
  '1': 'DeleteLicensesRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `DeleteLicensesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteLicensesRequestDescriptor = $convert.base64Decode(
    'ChVEZWxldGVMaWNlbnNlc1JlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCH'
    'Bhc3N3b3JkGAIgASgJUghwYXNzd29yZA==');
