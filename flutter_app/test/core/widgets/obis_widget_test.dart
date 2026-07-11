import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/widgets/obis_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

ObisWidget _widget({ObisWidgetData? data, VoidCallback? onDelete}) =>
    ObisWidget(data: data ?? ObisWidgetData(), onDelete: onDelete);

void main() {
  // -------------------------------------------------------------------------
  // ObisWidgetData
  // -------------------------------------------------------------------------
  group('ObisWidgetData', () {
    test('creates three independent TextEditingControllers', () {
      final d = ObisWidgetData();
      expect(d.classController, isA<TextEditingController>());
      expect(d.obisController, isA<TextEditingController>());
      expect(d.attributeController, isA<TextEditingController>());
    });

    test('controllers are initially empty', () {
      final d = ObisWidgetData();
      expect(d.classController.text, '');
      expect(d.obisController.text, '');
      expect(d.attributeController.text, '');
    });

    test('controllers are distinct objects', () {
      final d = ObisWidgetData();
      expect(d.classController, isNot(same(d.obisController)));
      expect(d.obisController, isNot(same(d.attributeController)));
      expect(d.classController, isNot(same(d.attributeController)));
    });

    test('writing to one controller does not affect the others', () {
      final d = ObisWidgetData();
      d.classController.text = '42';
      expect(d.obisController.text, '');
      expect(d.attributeController.text, '');
    });
  });

  // -------------------------------------------------------------------------
  // Rendering
  // -------------------------------------------------------------------------
  group('ObisWidget – rendering', () {
    testWidgets('renders a Card containing three TextFields and one IconButton',
        (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('Class field has correct label', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      expect(find.text('Class'), findsOneWidget);
    });

    testWidgets('OBIS Code field has correct label', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      expect(find.text('OBIS Code (Hex)'), findsOneWidget);
    });

    testWidgets('Attribute field has correct label', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      expect(find.text('Attribute'), findsOneWidget);
    });

    testWidgets('delete icon is Icons.delete with red color', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete));
      expect(icon.color, equals(Colors.red));
    });

    testWidgets('pre-filled controllers show values in TextFields', (tester) async {
      final data = ObisWidgetData();
      data.classController.text = '7';
      data.obisController.text = 'AABBCC';
      data.attributeController.text = '2';

      await tester.pumpWidget(_wrap(_widget(data: data)));

      expect(find.widgetWithText(TextField, '7'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'AABBCC'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    });

    testWidgets('widget uses OutlineInputBorder for all three fields', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      for (final field in fields) {
        expect(field.decoration?.border, isA<OutlineInputBorder>());
      }
    });

    testWidgets('Card has vertical margin of 8', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.symmetric(vertical: 8));
    });
  });

  // -------------------------------------------------------------------------
  // Input formatting
  // -------------------------------------------------------------------------
  group('ObisWidget – OBIS Code Hex field filtering', () {
    testWidgets('accepts valid hex characters', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      final hexField = find.widgetWithText(TextField, 'OBIS Code (Hex)').first;
      await tester.tap(find.byType(TextField).at(1));
      await tester.enterText(find.byType(TextField).at(1), '0123456789abcdefABCDEF');
      await tester.pump();

      expect(data.obisController.text, '0123456789abcdefABCDEF');
    });

    testWidgets('rejects non-hex characters (e.g. g, z, @)', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      await tester.enterText(find.byType(TextField).at(1), 'gzXYZ@!');
      await tester.pump();

      // FilteringTextInputFormatter removes non-hex chars
      expect(data.obisController.text, isEmpty);
    });

    testWidgets('Class field has numeric keyboard type', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      final classField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(classField.keyboardType, TextInputType.number);
    });

    testWidgets('Attribute field has numeric keyboard type', (tester) async {
      await tester.pumpWidget(_wrap(_widget()));
      final attrField = tester.widget<TextField>(find.byType(TextField).at(2));
      expect(attrField.keyboardType, TextInputType.number);
    });
  });

  // -------------------------------------------------------------------------
  // onDelete callback
  // -------------------------------------------------------------------------
  group('ObisWidget – onDelete callback', () {
    testWidgets('tapping delete button calls onDelete callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(_wrap(_widget(onDelete: () => called = true)));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('tapping delete button with onDelete=null does not throw',
        (tester) async {
      await tester.pumpWidget(_wrap(_widget(onDelete: null)));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      // No crash expected
    });

    testWidgets('onDelete is called once per tap', (tester) async {
      int count = 0;
      await tester.pumpWidget(_wrap(_widget(onDelete: () => count++)));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(count, 2);
    });
  });

  // -------------------------------------------------------------------------
  // Controller interaction
  // -------------------------------------------------------------------------
  group('ObisWidget – controller interaction', () {
    testWidgets('typing in Class field updates classController', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      await tester.enterText(find.byType(TextField).at(0), '15');
      await tester.pump();

      expect(data.classController.text, '15');
    });

    testWidgets('typing in OBIS Code field updates obisController', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      await tester.enterText(find.byType(TextField).at(1), 'FF00AA');
      await tester.pump();

      expect(data.obisController.text, 'FF00AA');
    });

    testWidgets('typing in Attribute field updates attributeController', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      await tester.enterText(find.byType(TextField).at(2), '3');
      await tester.pump();

      expect(data.attributeController.text, '3');
    });

    testWidgets('external controller change reflects in widget', (tester) async {
      final data = ObisWidgetData();
      await tester.pumpWidget(_wrap(_widget(data: data)));

      data.classController.text = '99';
      await tester.pump();

      expect(find.widgetWithText(TextField, '99'), findsOneWidget);
    });
  });
}
