import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/util/xml_util.dart';

void main() {
  group('parseSingleElement', () {
    test('parses simple XML element', () {
      const xml = '<name>Test</name>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('name'));
      expect(result.value, equals('Test'));
    });

    test('parses element with spaces', () {
      const xml = '<  tag  >Value<  /  tag  >';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('tag'));
      expect(result.value, equals('Value'));
    });

    test('parses element with attributes', () {
      const xml = '<item type="test" id="123">Value</item>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('item'));
      expect(result.value, equals('Value'));
    });

    test('parses element with hyphenated tag name', () {
      const xml = '<my-tag>Content</my-tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('my-tag'));
      expect(result.value, equals('Content'));
    });

    test('parses element with dotted tag name', () {
      const xml = '<my.tag>Content</my.tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('my.tag'));
      expect(result.value, equals('Content'));
    });

    test('parses element with underscore in tag name', () {
      const xml = '<my_tag>Content</my_tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('my_tag'));
      expect(result.value, equals('Content'));
    });

    test('unescapes XML entities in content', () {
      const xml = '<tag>Test &lt;&gt;&amp;&quot;&apos;</tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, equals('Test <>&"\''));
    });

    test('unescapes numeric character references (decimal)', () {
      const xml = '<tag>&#169; Copyright</tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, equals('© Copyright'));
    });

    test('unescapes numeric character references (hexadecimal)', () {
      const xml = '<tag>&#xA9; Copyright</tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, equals('© Copyright'));
    });

    test('handles empty element', () {
      const xml = '<tag></tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('tag'));
      expect(result.value, equals(''));
    });

    test('handles multiline content', () {
      const xml = '''<tag>Line 1
Line 2
Line 3</tag>''';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, contains('Line 1'));
      expect(result.value, contains('Line 2'));
      expect(result.value, contains('Line 3'));
    });

    test('returns null for malformed XML', () {
      const xml = '<tag>Unclosed';
      final result = parseSingleElement(xml);
      
      expect(result, isNull);
    });

    test('returns null for empty string', () {
      const xml = '';
      final result = parseSingleElement(xml);
      
      expect(result, isNull);
    });

    test('returns null for text without tags', () {
      const xml = 'Just plain text';
      final result = parseSingleElement(xml);
      
      expect(result, isNull);
    });

    test('parses first matching element in complex XML', () {
      const xml = '<root><tag>First</tag><tag>Second</tag></root>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('root'));
    });

    test('handles nested content', () {
      const xml = '<outer>Some <inner>nested</inner> text</outer>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.key, equals('outer'));
      expect(result.value, contains('Some'));
      expect(result.value, contains('nested'));
      expect(result.value, contains('text'));
    });

    test('preserves invalid numeric entities', () {
      const xml = '<tag>&#invalid;</tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, contains('&#invalid;'));
    });

    test('handles multiple XML entities in sequence', () {
      const xml = '<tag>&lt;&lt;&lt;</tag>';
      final result = parseSingleElement(xml);
      
      expect(result, isNotNull);
      expect(result!.value, equals('<<<'));
    });
  });
}
