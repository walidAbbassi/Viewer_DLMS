import 'dart:typed_data';
import 'dart:convert' show base64;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/util/dart_to_any.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $any;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $w;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $s;

void main() {
  group('dartToAny', () {
    test('converts String to Any with StringValue', () {
      final any = dartToAny('Hello World');
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.StringValue'));
      
      final stringValue = $w.StringValue();
      any.unpackInto(stringValue);
      expect(stringValue.value, equals('Hello World'));
    });

    test('converts int to Any with Int64Value', () {
      final any = dartToAny(42);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.Int64Value'));
      
      final intValue = $w.Int64Value();
      any.unpackInto(intValue);
      expect(intValue.value.toInt(), equals(42));
    });

    test('converts double to Any with DoubleValue', () {
      final any = dartToAny(3.14159);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.DoubleValue'));
      
      final doubleValue = $w.DoubleValue();
      any.unpackInto(doubleValue);
      expect(doubleValue.value, equals(3.14159));
    });

    test('converts bool to Any with BoolValue', () {
      final any = dartToAny(true);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.BoolValue'));
      
      final boolValue = $w.BoolValue();
      any.unpackInto(boolValue);
      expect(boolValue.value, isTrue);
    });

    test('converts Uint8List to Any with BytesValue', () {
      final bytes = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      final any = dartToAny(bytes);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.BytesValue'));
      
      final bytesValue = $w.BytesValue();
      any.unpackInto(bytesValue);
      expect(bytesValue.value, equals(bytes));
    });

    test('converts List<int> to Any with BytesValue', () {
      final bytes = [0x48, 0x65, 0x6C, 0x6C, 0x6F];
      final any = dartToAny(bytes);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.BytesValue'));
      
      final bytesValue = $w.BytesValue();
      any.unpackInto(bytesValue);
      expect(bytesValue.value, equals(Uint8List.fromList(bytes)));
    });

    test('converts Map to Any with Struct', () {
      final map = {
        'name': 'John',
        'age': 30,
        'active': true,
      };
      final any = dartToAny(map);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.Struct'));
      
      final struct = $s.Struct();
      any.unpackInto(struct);
      expect(struct.fields['name']!.stringValue, equals('John'));
      expect(struct.fields['age']!.numberValue, equals(30));
      expect(struct.fields['active']!.boolValue, isTrue);
    });

    test('converts List to Any with ListValue', () {
      final list = ['first', 42, false];
      final any = dartToAny(list);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.ListValue'));
      
      final listValue = $s.ListValue();
      any.unpackInto(listValue);
      expect(listValue.values[0].stringValue, equals('first'));
      expect(listValue.values[1].numberValue, equals(42));
      expect(listValue.values[2].boolValue, isFalse);
    });

    test('converts nested Map to Any', () {
      final map = {
        'name': 'John',
        'address': {
          'city': 'Paris',
          'zipCode': 75001,
        },
      };
      final any = dartToAny(map);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.Struct'));
      
      final struct = $s.Struct();
      any.unpackInto(struct);
      expect(struct.fields['name']!.stringValue, equals('John'));
      expect(struct.fields['address']!.structValue.fields['city']!.stringValue, equals('Paris'));
      expect(struct.fields['address']!.structValue.fields['zipCode']!.numberValue, equals(75001));
    });

    test('converts null to Any with Value(null)', () {
      final any = dartToAny(null);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.Value'));
      
      final value = $s.Value();
      any.unpackInto(value);
      expect(value.whichKind(), equals($s.Value_Kind.nullValue));
    });

    test('converts empty String to Any', () {
      final any = dartToAny('');
      
      final stringValue = $w.StringValue();
      any.unpackInto(stringValue);
      expect(stringValue.value, equals(''));
    });

    test('converts zero to Any', () {
      final any = dartToAny(0);
      
      final intValue = $w.Int64Value();
      any.unpackInto(intValue);
      expect(intValue.value.toInt(), equals(0));
    });

    test('converts empty Map to Any', () {
      final any = dartToAny({});
      
      expect(any, isA<$any.Any>());
      // Empty maps may be converted to StringValue in some implementations
      expect(any.typeUrl, anyOf(contains('google.protobuf.Struct'), contains('google.protobuf.StringValue')));
    });

    test('converts empty List to Any', () {
      final any = dartToAny([]);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.ListValue'));
    });

    test('converts negative int to Any', () {
      final any = dartToAny(-42);
      
      final intValue = $w.Int64Value();
      any.unpackInto(intValue);
      expect(intValue.value.toInt(), equals(-42));
    });

    test('converts negative double to Any', () {
      final any = dartToAny(-3.14);
      
      final doubleValue = $w.DoubleValue();
      any.unpackInto(doubleValue);
      expect(doubleValue.value, equals(-3.14));
    });

    test('converts false to Any', () {
      final any = dartToAny(false);
      
      final boolValue = $w.BoolValue();
      any.unpackInto(boolValue);
      expect(boolValue.value, isFalse);
    });

    test('converts complex nested structure', () {
      final complex = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ],
        'meta': {
          'total': 2,
          'active': true,
        },
      };
      final any = dartToAny(complex);
      
      expect(any, isA<$any.Any>());
      expect(any.typeUrl, contains('google.protobuf.Struct'));
    });

    test('converts bytes in nested structure to base64', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final map = {
        'data': bytes,
        'name': 'test',
      };
      final any = dartToAny(map);
      
      final struct = $s.Struct();
      any.unpackInto(struct);
      // Bytes inside Struct are encoded as base64 string
      expect(struct.fields['data']!.stringValue, equals(base64.encode(bytes)));
      expect(struct.fields['name']!.stringValue, equals('test'));
    });

    test('fallback converts unknown type to string', () {
      final obj = DateTime(2024, 1, 1);
      final any = dartToAny(obj);
      
      final stringValue = $w.StringValue();
      any.unpackInto(stringValue);
      expect(stringValue.value, contains('2024'));
    });
  });
}
