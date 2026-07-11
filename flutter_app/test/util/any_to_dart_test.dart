import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/util/any_to_dart.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $any;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $w;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $s;
import 'package:fixnum/fixnum.dart';

void main() {
  group('anyToDart', () {
    test('unpacks StringValue to String', () {
      final stringValue = $w.StringValue()..value = 'Hello World';
      final any = $any.Any.pack(stringValue);
      
      final result = anyToDart(any);
      expect(result, equals('Hello World'));
    });

    test('unpacks Int64Value to int', () {
      final intValue = $w.Int64Value()..value = Int64(42);
      final any = $any.Any.pack(intValue);
      
      final result = anyToDart(any);
      expect(result, equals(42));
    });

    test('unpacks DoubleValue to double', () {
      final doubleValue = $w.DoubleValue()..value = 3.14159;
      final any = $any.Any.pack(doubleValue);
      
      final result = anyToDart(any);
      expect(result, equals(3.14159));
    });

    test('unpacks BoolValue to bool', () {
      final boolValue = $w.BoolValue()..value = true;
      final any = $any.Any.pack(boolValue);
      
      final result = anyToDart(any);
      expect(result, isTrue);
    });

    test('unpacks BytesValue to Uint8List', () {
      final bytes = [0x48, 0x65, 0x6C, 0x6C, 0x6F];
      final bytesValue = $w.BytesValue()..value = bytes;
      final any = $any.Any.pack(bytesValue);
      
      final result = anyToDart(any);
      expect(result, isA<Uint8List>());
      expect(result, equals(Uint8List.fromList(bytes)));
    });

    test('unpacks Struct to Map', () {
      final struct = $s.Struct()
        ..fields['name'] = ($s.Value()..stringValue = 'John')
        ..fields['age'] = ($s.Value()..numberValue = 30)
        ..fields['active'] = ($s.Value()..boolValue = true);
      final any = $any.Any.pack(struct);
      
      final result = anyToDart(any);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], equals('John'));
      expect(result['age'], equals(30));
      expect(result['active'], isTrue);
    });

    test('unpacks ListValue to List', () {
      final listValue = $s.ListValue()
        ..values.add($s.Value()..stringValue = 'first')
        ..values.add($s.Value()..numberValue = 42)
        ..values.add($s.Value()..boolValue = false);
      final any = $any.Any.pack(listValue);
      
      final result = anyToDart(any);
      expect(result, isA<List>());
      expect(result, hasLength(3));
      expect(result[0], equals('first'));
      expect(result[1], equals(42));
      expect(result[2], isFalse);
    });

    test('unpacks nested Struct', () {
      final innerStruct = $s.Struct()
        ..fields['city'] = ($s.Value()..stringValue = 'Paris');
      
      final outerStruct = $s.Struct()
        ..fields['name'] = ($s.Value()..stringValue = 'John')
        ..fields['address'] = ($s.Value()..structValue = innerStruct);
      
      final any = $any.Any.pack(outerStruct);
      
      final result = anyToDart(any);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], equals('John'));
      expect(result['address'], isA<Map<String, dynamic>>());
      expect(result['address']['city'], equals('Paris'));
    });

    test('returns Any for unknown message type', () {
      final any = $any.Any()
        ..typeUrl = 'type.googleapis.com/unknown.Message'
        ..value = [1, 2, 3];
      
      final result = anyToDart(any);
      expect(result, isA<$any.Any>());
      expect(result.typeUrl, equals('type.googleapis.com/unknown.Message'));
    });
  });

  group('bytesToHex', () {
    test('converts bytes to uppercase hex string', () {
      final bytes = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      final result = bytesToHex(bytes);
      expect(result, equals('48656C6C6F'));
    });

    test('converts bytes to lowercase hex string', () {
      final bytes = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      final result = bytesToHex(bytes, uppercase: false);
      expect(result, equals('48656c6c6f'));
    });

    test('handles single byte', () {
      final bytes = Uint8List.fromList([0xFF]);
      final result = bytesToHex(bytes);
      expect(result, equals('FF'));
    });

    test('handles zero byte', () {
      final bytes = Uint8List.fromList([0x00]);
      final result = bytesToHex(bytes);
      expect(result, equals('00'));
    });

    test('handles empty bytes', () {
      final bytes = Uint8List.fromList([]);
      final result = bytesToHex(bytes);
      expect(result, equals(''));
    });

    test('pads single digit with zero', () {
      final bytes = Uint8List.fromList([0x01, 0x0F]);
      final result = bytesToHex(bytes);
      expect(result, equals('010F'));
    });
  });
}
