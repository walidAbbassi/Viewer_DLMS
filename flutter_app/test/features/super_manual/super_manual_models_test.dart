import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/core/theme/design_tokens.dart';
import 'package:flutter_python_grpc/features/super_manual/super_manual_models.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('super_manual_models', () {
    test('AttrState holds mutable original/current and index', () {
      final state = AttrState(original: 'a', current: 'b', index: 3);

      expect(state.original, equals('a'));
      expect(state.current, equals('b'));
      expect(state.index, equals(3));

      state.original = 'x';
      state.current = 'y';

      expect(state.original, equals('x'));
      expect(state.current, equals('y'));
    });

    test('TermEntry holds tag/message/kind', () {
      final entry = TermEntry('tag', 'msg', 'kind');
      expect(entry.tag, equals('tag'));
      expect(entry.msg, equals('msg'));
      expect(entry.kind, equals('kind'));
    });

    test('SelectiveObj holds its metadata fields', () {
      final obj = SelectiveObj('name', 'logical', 10, 2, 60);
      expect(obj.name, equals('name'));
      expect(obj.logical, equals('logical'));
      expect(obj.max, equals(10));
      expect(obj.num, equals(2));
      expect(obj.period, equals(60));
    });

    testWidgets('DictionaryListItem renders inactive styles and calls onTap', (tester) async {
      var taps = 0;
      final object = DatamodelObject(name: 'Obj', logicalName: '1.0.0.0.0.255');

      await tester.pumpWidget(
        _wrap(
          DictionaryListItem(
            object: object,
            active: false,
            onTap: () => taps += 1,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(DictionaryListItem), matching: find.byType(Container)).first,
      );
      expect(container.color, equals(Colors.white));

      final nameText = tester.widget<Text>(find.text('Obj'));
      expect(nameText.style, isNotNull);
      expect(nameText.style!.color, equals(DesignTokens.textPrimary));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(taps, equals(1));
    });

    testWidgets('DictionaryListItem renders active styles', (tester) async {
      final object = DatamodelObject(name: 'Obj', logicalName: '1.0.0.0.0.255');

      await tester.pumpWidget(
        _wrap(
          DictionaryListItem(
            object: object,
            active: true,
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(DictionaryListItem), matching: find.byType(Container)).first,
      );
      expect(container.color, equals(DesignTokens.primary100));

      final nameText = tester.widget<Text>(find.text('Obj'));
      expect(nameText.style, isNotNull);
      expect(nameText.style!.color, equals(DesignTokens.primary600));
    });
  });
}
