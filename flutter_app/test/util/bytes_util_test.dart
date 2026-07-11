import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/util/bytes_util.dart';

void main() {
  group('hexToBytes', () {
    test('converts valid hex string to bytes', () {
      final result = hexToBytes('48656C6C6F');
      expect(result, equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])));
    });

    test('handles lowercase hex', () {
      final result = hexToBytes('48656c6c6f');
      expect(result, equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])));
    });

    test('handles hex with separators (spaces)', () {
      final result = hexToBytes('48 65 6C 6C 6F');
      expect(result, equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])));
    });

    test('handles hex with separators (colons)', () {
      final result = hexToBytes('48:65:6C:6C:6F');
      expect(result, equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])));
    });

    test('handles hex with separators (hyphens)', () {
      final result = hexToBytes('48-65-6C-6C-6F');
      expect(result, equals(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F])));
    });

    test('handles odd length by padding with zero', () {
      final result = hexToBytes('123');
      expect(result, equals(Uint8List.fromList([0x01, 0x23])));
    });

    test('handles empty string', () {
      final result = hexToBytes('');
      expect(result, equals(Uint8List(0)));
    });

    test('handles string with only separators', () {
      final result = hexToBytes('   ');
      expect(result, equals(Uint8List(0)));
    });

    test('handles single byte', () {
      final result = hexToBytes('FF');
      expect(result, equals(Uint8List.fromList([0xFF])));
    });

    test('handles zero byte', () {
      final result = hexToBytes('00');
      expect(result, equals(Uint8List.fromList([0x00])));
    });
  });

  group('isHex', () {
    test('returns true for valid hex string', () {
      expect(isHex('48656C6C6F'), isTrue);
    });

    test('returns true for hex with spaces', () {
      expect(isHex('48 65 6C 6C 6F'), isTrue);
    });

    test('returns true for hex with colons', () {
      expect(isHex('48:65:6C:6C:6F'), isTrue);
    });

    test('returns true for hex with hyphens', () {
      expect(isHex('48-65-6C-6C-6F'), isTrue);
    });

    test('returns true for hex with underscores', () {
      expect(isHex('48_65_6C_6C_6F'), isTrue);
    });

    test('returns true for hex with periods', () {
      expect(isHex('48.65.6C.6C.6F'), isTrue);
    });

    test('returns true for lowercase hex', () {
      expect(isHex('abcdef'), isTrue);
    });

    test('returns true for uppercase hex', () {
      expect(isHex('ABCDEF'), isTrue);
    });

    test('returns false for string with invalid characters', () {
      expect(isHex('48G5'), isFalse);
    });

    test('returns false for string with letters outside hex range', () {
      expect(isHex('xyz'), isFalse);
    });

    test('returns true for empty string', () {
      expect(isHex(''), isFalse);
    });

    test('returns true for mixed case hex', () {
      expect(isHex('AaBbCc'), isTrue);
    });
  });
}
