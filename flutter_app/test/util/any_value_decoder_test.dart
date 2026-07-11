import 'dart:convert' show base64;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/util/any_value_decoder.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $any;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $s;

void main() {
  group('AnyValueDecoder.fromAny', () {
    test('returns raw Any.value when typeUrl mismatches google.protobuf.Value', () {
      final any = $any.Any()
        ..typeUrl = 'type.googleapis.com/google.protobuf.StringValue'
        ..value = [1, 2, 3];

      final result = AnyValueDecoder.fromAny(any);
      expect(result, equals([1, 2, 3]));
    });

    test('unpacks nullValue to null', () {
      final v = $s.Value()..nullValue = $s.NullValue.NULL_VALUE;
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isNull);
    });

    test('unpacks numberValue to double', () {
      final v = $s.Value()..numberValue = 42;
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, equals(42.0));
    });

    test('unpacks stringValue to String', () {
      final v = $s.Value()..stringValue = 'Hello';
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, equals('Hello'));
    });

    test('decodes stringValue with base64: prefix to bytes', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3, 254, 255]);
      final v = $s.Value()..stringValue = 'base64:${base64.encode(bytes)}';
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isA<Uint8List>());
      expect(result, equals(bytes));
    });

    test('unpacks boolValue to bool', () {
      final v = $s.Value()..boolValue = true;
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isTrue);
    });

    test('unpacks structValue to Map<String, dynamic> (nested)', () {
      final inner = $s.Struct()..fields['city'] = ($s.Value()..stringValue = 'Paris');
      final outer = $s.Struct()
        ..fields['name'] = ($s.Value()..stringValue = 'John')
        ..fields['age'] = ($s.Value()..numberValue = 30)
        ..fields['active'] = ($s.Value()..boolValue = true)
        ..fields['address'] = ($s.Value()..structValue = inner);

      final any = $any.Any.pack($s.Value()..structValue = outer);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], equals('John'));
      expect(result['age'], equals(30.0));
      expect(result['active'], isTrue);
      expect(result['address'], isA<Map<String, dynamic>>());
      expect(result['address']['city'], equals('Paris'));
    });

    test('unpacks listValue to List<dynamic> (mixed)', () {
      final lv = $s.ListValue()
        ..values.add($s.Value()..stringValue = 'first')
        ..values.add($s.Value()..numberValue = 2)
        ..values.add($s.Value()..boolValue = false)
        ..values.add($s.Value()..nullValue = $s.NullValue.NULL_VALUE);

      final any = $any.Any.pack($s.Value()..listValue = lv);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isA<List<dynamic>>());
      expect(result, equals(['first', 2.0, false, null]));
    });

    test('returns null for Value with kind notSet', () {
      final v = $s.Value();
      final any = $any.Any.pack(v);

      final result = AnyValueDecoder.fromAny(any);
      expect(result, isNull);
    });

    test('falls back to mergeFromBuffer when Any cannot unpack into Value', () {
      // An Any with empty typeUrl will typically fail canUnpackInto().
      // The decoder should then merge from the raw buffer.
      final v = $s.Value()..stringValue = 'via-merge';
      final any = $any.Any()..value = v.writeToBuffer();

      final result = AnyValueDecoder.fromAny(any);
      expect(result, equals('via-merge'));
    });
  });

  group('AnyValueDecoder.coerceNumbers', () {
    test('coerces whole doubles to ints and preserves fractional doubles', () {
      expect(AnyValueDecoder.coerceNumbers(1.0), equals(1));
      expect(AnyValueDecoder.coerceNumbers(-2.0), equals(-2));
      expect(AnyValueDecoder.coerceNumbers(3.14), equals(3.14));
    });

    test('coerces recursively for lists and maps', () {
      final input = <String, dynamic>{
        'a': 2.0,
        'b': [1.0, 1.5, {'c': 4.0}],
        'd': 'x',
      };

      final result = AnyValueDecoder.coerceNumbers(input);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['a'], equals(2));
      expect(result['b'], equals([1, 1.5, {'c': 4}]));
      expect(result['d'], equals('x'));
    });

    test('leaves non-list/map/double values unchanged', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      // Uint8List implements List<int>, so coerceNumbers() will treat it as a
      // List and return a new List with the same contents.
      expect(AnyValueDecoder.coerceNumbers(bytes), equals(bytes));
      expect(AnyValueDecoder.coerceNumbers(true), isTrue);
      expect(AnyValueDecoder.coerceNumbers(null), isNull);
    });
  });
}
