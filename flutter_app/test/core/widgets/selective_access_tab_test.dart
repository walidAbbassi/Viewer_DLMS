import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/widgets/selective_access_tab.dart';
import 'package:flutter_python_grpc/core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// Helper – wraps a widget in MaterialApp+Scaffold for rendering
// ---------------------------------------------------------------------------
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  // -------------------------------------------------------------------------
  // TerminalLine data class
  // -------------------------------------------------------------------------
  group('TerminalLine', () {
    test('stores all fields correctly', () {
      final line = TerminalLine(
        timestamp: '12:00:00',
        tag: 'REQ',
        message: 'Hello world',
        kind: 'req',
      );
      expect(line.timestamp, '12:00:00');
      expect(line.tag, 'REQ');
      expect(line.message, 'Hello world');
      expect(line.kind, 'req');
    });

    test('distinct instances are independent', () {
      final a = TerminalLine(timestamp: 't1', tag: 'A', message: 'm1', kind: 'req');
      final b = TerminalLine(timestamp: 't2', tag: 'B', message: 'm2', kind: 'err');
      expect(a.timestamp, isNot(b.timestamp));
      expect(a.kind, isNot(b.kind));
    });
  });

  // -------------------------------------------------------------------------
  // buildReadonlyField
  // -------------------------------------------------------------------------
  group('buildReadonlyField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('MyLabel', 'MyValue')));
      expect(find.text('MyLabel'), findsOneWidget);
    });

    testWidgets('renders value in a TextField', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('L', 'TestValue')));
      expect(find.widgetWithText(TextField, 'TestValue'), findsOneWidget);
    });

    testWidgets('TextField is readOnly', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('L', 'V')));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.readOnly, isTrue);
    });

    testWidgets('TextField has OutlineInputBorder', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('L', 'V')));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('TextField is filled with surfaceAlt color', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('L', 'V')));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.filled, isTrue);
      expect(tf.decoration?.fillColor, equals(DesignTokens.surfaceAlt));
    });

    testWidgets('label has correct text style', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('MyLabel', 'V')));
      final label = tester.widget<Text>(find.text('MyLabel'));
      expect(label.style?.fontSize, 12.0);
      expect(label.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('TextField text style is fontSize 13', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('L', 'V')));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.style?.fontSize, 13.0);
    });

    testWidgets('empty value renders empty TextField', (tester) async {
      await tester.pumpWidget(_wrap(buildReadonlyField('Label', '')));
      expect(find.text('Label'), findsOneWidget);
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, '');
    });
  });

  // -------------------------------------------------------------------------
  // buildNumberField
  // -------------------------------------------------------------------------
  group('buildNumberField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('Count', 5, (_) {})));
      expect(find.text('Count'), findsOneWidget);
    });

    testWidgets('renders initial value as string in TextField', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('Count', 42, (_) {})));
      expect(find.widgetWithText(TextField, '42'), findsOneWidget);
    });

    testWidgets('has numeric keyboard type', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (_) {})));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.keyboardType, TextInputType.number);
    });

    testWidgets('label has correct text style', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('MyNum', 1, (_) {})));
      final label = tester.widget<Text>(find.text('MyNum'));
      expect(label.style?.fontSize, 12.0);
      expect(label.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('onChanged called with parsed int when valid number entered',
        (tester) async {
      int? received;
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (v) => received = v)));
      await tester.enterText(find.byType(TextField), '99');
      await tester.pump();
      expect(received, 99);
    });

    testWidgets('onChanged not called when non-numeric text entered',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (_) => callCount++)));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(callCount, 0);
    });

    testWidgets('onChanged called with correct value for each valid input',
        (tester) async {
      int? last;
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (v) => last = v)));
      await tester.enterText(find.byType(TextField), '7');
      await tester.pump();
      expect(last, 7);
    });

    testWidgets('TextField style is fontSize 13', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (_) {})));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.style?.fontSize, 13.0);
    });

    testWidgets('has OutlineInputBorder', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (_) {})));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('zero initial value renders 0', (tester) async {
      await tester.pumpWidget(
          _wrap(buildNumberField('N', 0, (_) {})));
      expect(find.widgetWithText(TextField, '0'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // buildPanel
  // -------------------------------------------------------------------------
  group('buildPanel', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'My Panel', children: [])));
      expect(find.text('My Panel'), findsOneWidget);
    });

    testWidgets('title has correct style', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'Title', children: [])));
      final title = tester.widget<Text>(find.text('Title'));
      expect(title.style?.fontSize, 15.0);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(title.style?.color, DesignTokens.primary600);
    });

    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(
        title: 'P',
        children: [
          const Text('Child A'),
          const Text('Child B'),
        ],
      )));
      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    });

    testWidgets('renders with no children without crash', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'Empty', children: [])));
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('wraps content in a Container', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'T', children: [])));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('container has correct border radius', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'T', children: [])));
      final container = tester.widget<Container>(
        find.ancestor(of: find.text('T'), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('container has surface background color', (tester) async {
      await tester.pumpWidget(_wrap(buildPanel(title: 'T', children: [])));
      final container = tester.widget<Container>(
        find.ancestor(of: find.text('T'), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, DesignTokens.surface);
    });
  });

  // -------------------------------------------------------------------------
  // buildButton
  // -------------------------------------------------------------------------
  group('buildButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(buildButton('Save', Colors.blue, () {})));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('returns an ElevatedButton', (tester) async {
      await tester.pumpWidget(_wrap(buildButton('Go', Colors.green, () {})));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester
          .pumpWidget(_wrap(buildButton('Click', Colors.red, () => pressed = true)));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('onPressed called multiple times on multiple taps', (tester) async {
      int count = 0;
      await tester
          .pumpWidget(_wrap(buildButton('Btn', Colors.orange, () => count++)));
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(count, 2);
    });

    testWidgets('label has correct text style', (tester) async {
      await tester.pumpWidget(_wrap(buildButton('Lbl', Colors.purple, () {})));
      final txt = tester.widget<Text>(find.text('Lbl'));
      expect(txt.style?.fontSize, 13.0);
      expect(txt.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('background color is applied via ElevatedButton style',
        (tester) async {
      const myColor = Colors.teal;
      await tester.pumpWidget(_wrap(buildButton('B', myColor, () {})));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final bg = btn.style?.backgroundColor?.resolve({});
      expect(bg, myColor);
    });
  });

  // -------------------------------------------------------------------------
  // buildOutlineButton
  // -------------------------------------------------------------------------
  group('buildOutlineButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(buildOutlineButton('Export', () {})));
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('returns an OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(buildOutlineButton('Export', () {})));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester
          .pumpWidget(_wrap(buildOutlineButton('Go', () => pressed = true)));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('label has correct text style', (tester) async {
      await tester.pumpWidget(_wrap(buildOutlineButton('Lbl', () {})));
      final txt = tester.widget<Text>(find.text('Lbl'));
      expect(txt.style?.fontSize, 13.0);
      expect(txt.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('foreground color is primary600', (tester) async {
      await tester.pumpWidget(_wrap(buildOutlineButton('B', () {})));
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final fg = btn.style?.foregroundColor?.resolve({});
      expect(fg, DesignTokens.primary600);
    });

    testWidgets('border side uses primary600', (tester) async {
      await tester.pumpWidget(_wrap(buildOutlineButton('B', () {})));
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final side = btn.style?.side?.resolve({});
      expect(side?.color, DesignTokens.primary600);
    });
  });

  // -------------------------------------------------------------------------
  // buildTerminalLine
  // -------------------------------------------------------------------------
  group('buildTerminalLine – req kind', () {
    testWidgets('renders timestamp', (tester) async {
      final line = TerminalLine(
          timestamp: '08:30:00', tag: 'GET', message: 'msg', kind: 'req');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      expect(find.text('[08:30:00]'), findsOneWidget);
    });

    testWidgets('renders tag text', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'SEND', message: 'msg', kind: 'req');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      expect(find.text('SEND'), findsOneWidget);
    });

    testWidgets('renders message text', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'T', message: 'Hello response', kind: 'req');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      expect(find.text('Hello response'), findsOneWidget);
    });

    testWidgets('req kind tag badge uses color 0xFF312E81 background', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'GET', message: 'msg', kind: 'req');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      // Find the Container holding the tag badge
      final badge = tester.widget<Container>(
        find
            .ancestor(of: find.text('GET'), matching: find.byType(Container))
            .first,
      );
      final dec = badge.decoration as BoxDecoration;
      expect(dec.color, const Color(0xFF312E81));
    });

    testWidgets('req kind tag text uses color 0xFFC7D2FE', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'GET', message: 'msg', kind: 'req');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final tagText = tester.widget<Text>(find.text('GET'));
      expect(tagText.style?.color, const Color(0xFFC7D2FE));
    });
  });

  group('buildTerminalLine – err kind', () {
    testWidgets('err kind tag badge uses color 0xFF7F1D1D background', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'ERR', message: 'failed', kind: 'err');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final badge = tester.widget<Container>(
        find
            .ancestor(of: find.text('ERR'), matching: find.byType(Container))
            .first,
      );
      final dec = badge.decoration as BoxDecoration;
      expect(dec.color, const Color(0xFF7F1D1D));
    });

    testWidgets('err kind tag text uses color 0xFFFCA5A5', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'ERR', message: 'failed', kind: 'err');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final tagText = tester.widget<Text>(find.text('ERR'));
      expect(tagText.style?.color, const Color(0xFFFCA5A5));
    });

    testWidgets('err kind renders timestamp, tag and message', (tester) async {
      final line = TerminalLine(
          timestamp: '09:00:00', tag: 'ERR', message: 'Something broke', kind: 'err');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      expect(find.text('[09:00:00]'), findsOneWidget);
      expect(find.text('ERR'), findsOneWidget);
      expect(find.text('Something broke'), findsOneWidget);
    });
  });

  group('buildTerminalLine – default (resp) kind', () {
    testWidgets('default kind tag badge uses color 0xFF1E3A8A background',
        (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'RSP', message: 'ok', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final badge = tester.widget<Container>(
        find
            .ancestor(of: find.text('RSP'), matching: find.byType(Container))
            .first,
      );
      final dec = badge.decoration as BoxDecoration;
      expect(dec.color, const Color(0xFF1E3A8A));
    });

    testWidgets('default kind tag text uses color 0xFF93C5FD', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'RSP', message: 'ok', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final tagText = tester.widget<Text>(find.text('RSP'));
      expect(tagText.style?.color, const Color(0xFF93C5FD));
    });

    testWidgets('default kind renders timestamp, tag and message', (tester) async {
      final line = TerminalLine(
          timestamp: '10:00:00', tag: 'RSP', message: 'Done', kind: 'other');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      expect(find.text('[10:00:00]'), findsOneWidget);
      expect(find.text('RSP'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('timestamp text color is 0xFF64748B', (tester) async {
      final line = TerminalLine(
          timestamp: '11:11:11', tag: 'X', message: 'm', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final tsText = tester.widget<Text>(find.text('[11:11:11]'));
      expect(tsText.style?.color, const Color(0xFF64748B));
    });

    testWidgets('message text color is 0xFFD1E3F8', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'X', message: 'payload data', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final msgText = tester.widget<Text>(find.text('payload data'));
      expect(msgText.style?.color, const Color(0xFFD1E3F8));
    });

    testWidgets('tag badge has circular border radius of 12', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'TAG', message: 'm', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final badge = tester.widget<Container>(
        find
            .ancestor(of: find.text('TAG'), matching: find.byType(Container))
            .first,
      );
      final dec = badge.decoration as BoxDecoration;
      expect(dec.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('tag text has fontWeight w700 and fontSize 10', (tester) async {
      final line = TerminalLine(
          timestamp: 't', tag: 'TAG', message: 'm', kind: 'resp');
      await tester.pumpWidget(_wrap(buildTerminalLine(line)));
      final tagText = tester.widget<Text>(find.text('TAG'));
      expect(tagText.style?.fontWeight, FontWeight.w700);
      expect(tagText.style?.fontSize, 10.0);
    });
  });
}
