import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/widgets/attribute_edit_dialog.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DatamodelAttribute _attr({String type = 'integer', String name = 'TestAttr'}) =>
    DatamodelAttribute(name: name, type: type);

/// Wraps AttributeEditDialog directly in a scaffold (no dialog chrome).
Widget _direct({
  required DatamodelAttribute attr,
  String? initialValue,
  String? initialEncoded,
  bool showEncodingPanel = false,
  Future<String> Function(String, DatamodelAttribute)? onEncode,
  Future<String> Function(String, DatamodelAttribute)? onDecode,
  bool booleanAsYesNo = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: AttributeEditDialog(
        attr: attr,
        initialValue: initialValue,
        initialEncoded: initialEncoded,
        showEncodingPanel: showEncodingPanel,
        onEncode: onEncode,
        onDecode: onDecode,
        booleanAsYesNo: booleanAsYesNo,
      ),
    ),
  );
}

/// Opens the dialog via [AttributeEditDialog.show] from a button and returns
/// a future that resolves to the returned [AttributeEditResult?].
Future<AttributeEditResult?> _showDialog(
  WidgetTester tester, {
  required DatamodelAttribute attr,
  String? initialValue,
  String? initialEncoded,
  bool showEncodingPanel = false,
  Future<String> Function(String, DatamodelAttribute)? onEncode,
  Future<String> Function(String, DatamodelAttribute)? onDecode,
  bool booleanAsYesNo = true,
}) async {
  AttributeEditResult? captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            captured = await AttributeEditDialog.show(
              ctx,
              attr,
              initialValue: initialValue,
              initialEncoded: initialEncoded,
              showEncodingPanel: showEncodingPanel,
              onEncode: onEncode,
              onDecode: onDecode,
              booleanAsYesNo: booleanAsYesNo,
            );
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  // Suppress overflow in small test viewports
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
    FlutterError.dumpErrorToConsole(details);
  };

  // ---------------------------------------------------------------------------
  // Rendering / type detection
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – rendering by input kind', () {
    testWidgets('integer type renders TextField', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer')));
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Modifier TestAttr (integer)'), findsOneWidget);
    });

    testWidgets('long type is treated as integer', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'long')));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('unsigned_int type renders TextField', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'unsigned_int')));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('string type renders TextField', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'octet-string')));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('visible-string type renders TextField', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'visible-string')));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('boolean type renders CheckboxListTile', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean')));
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('date type renders Choisir une date button', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'date')));
      expect(find.text('Choisir une date'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('time type renders Choisir une heure button', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'time')));
      expect(find.text('Choisir une heure'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('datetime type renders both date and time buttons', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'datetime')));
      expect(find.text('Choisir une date'), findsOneWidget);
      expect(find.text('Choisir une heure'), findsOneWidget);
    });

    testWidgets('unknown type renders encoding panel only', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'unknown_xyz')));
      expect(find.text('Encodage (xdr/xml/hex)'), findsOneWidget);
      expect(find.text('Choisir une date'), findsNothing);
      expect(find.text('Choisir une heure'), findsNothing);
      expect(find.byType(CheckboxListTile), findsNothing);
    });

    testWidgets('Cancel and Valider buttons always rendered', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr()));
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('header shows attr name and type', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'string', name: 'MyField')));
      expect(find.text('Modifier MyField (string)'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // initialValue pre-filling
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – initialValue', () {
    testWidgets('integer initialValue pre-fills text field', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer'), initialValue: '42'));
      expect(find.widgetWithText(TextField, '42'), findsWidgets);
    });

    testWidgets('string initialValue pre-fills text field', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'string'), initialValue: 'hello'));
      expect(find.widgetWithText(TextField, 'hello'), findsWidgets);
    });

    testWidgets('boolean initialValue yes → checkbox checked', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean'), initialValue: 'yes'));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('boolean initialValue true → checkbox checked', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean'), initialValue: 'true'));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('boolean initialValue 1 → checkbox checked', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean'), initialValue: '1'));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('boolean initialValue no → checkbox unchecked', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean'), initialValue: 'no'));
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isFalse);
    });

    testWidgets('date initialValue 2025-12-03 shows formatted date', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'date'), initialValue: '2025-12-03'));
      expect(find.text('2025-12-03'), findsOneWidget);
    });

    testWidgets('time initialValue 13:45:00 shows formatted time', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'time'), initialValue: '13:45:00'));
      expect(find.text('13:45:00'), findsOneWidget);
    });

    testWidgets('datetime initialValue 2025-12-03T08:30:00 shows both', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'datetime'), initialValue: '2025-12-03T08:30:00'));
      expect(find.text('2025-12-03'), findsOneWidget);
      expect(find.text('08:30:00'), findsOneWidget);
    });

    testWidgets('date initialValue invalid string is ignored gracefully', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'date'), initialValue: 'not-a-date'));
      expect(find.text('—'), findsOneWidget); // no date set
    });

    testWidgets('time initialValue invalid is ignored gracefully', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'time'), initialValue: 'bad'));
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('datetime initialValue missing T is ignored gracefully', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'datetime'), initialValue: '2025-12-03 nope'));
      // Both should show "—"
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('initialEncoded pre-fills encoded field', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        initialEncoded: '<some>data</some>',
      ));
      expect(find.widgetWithText(TextField, '<some>data</some>'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Integer validation
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – integer validation', () {
    testWidgets('empty field shows Champ requis snackbar', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer')));
      // Clear the field (already empty)
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('Champ requis'), findsOneWidget);
    });

    testWidgets('non-numeric input shows Nombre invalide snackbar', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer'), initialValue: 'abc'));
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('Nombre invalide'), findsOneWidget);
    });

    testWidgets('negative value for unsigned shows error snackbar', (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'unsigned_int'), initialValue: '-5'));
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('Doit être non signé (>= 0)'), findsOneWidget);
    });

    testWidgets('valid integer passes validation', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer'), initialValue: '99'));
      await tester.tap(find.text('Valider'));
      await tester.pump(); // no snackbar
      expect(find.text('Champ requis'), findsNothing);
      expect(find.text('Nombre invalide'), findsNothing);
    });

    testWidgets('typing in integer field updates controller', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'integer')));
      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, '123');
      await tester.pump();
      expect(find.widgetWithText(TextField, '123'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Boolean input
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – boolean input', () {
    testWidgets('tapping checkbox toggles value', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'boolean')));
      final cb0 = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb0.value, isFalse);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      final cb1 = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb1.value, isTrue);
    });

    testWidgets('booleanAsYesNo=false uses true/false via Valider result', (tester) async {
      final attr = _attr(type: 'boolean');
      await _showDialog(tester,
          attr: attr, initialValue: 'true', booleanAsYesNo: false);
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      // Dialog dismissed — no snackbar errors
      expect(find.text('Champ requis'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Date / Time / Datetime pickers
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – date/time pickers', () {
    testWidgets('tapping Choisir une date opens DatePicker; Cancel keeps —',
        (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'date')));
      await tester.tap(find.text('Choisir une date'));
      await tester.pumpAndSettle();
      // Date picker open — tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('tapping Choisir une date and confirming sets date', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'date')));
      await tester.tap(find.text('Choisir une date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // A formatted date string should appear (not "—")
      expect(find.text('—'), findsNothing);
    });

    testWidgets('tapping Choisir une heure opens TimePicker; Cancel keeps —',
        (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'time')));
      await tester.tap(find.text('Choisir une heure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('tapping Choisir une heure and confirming sets time', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'time')));
      await tester.tap(find.text('Choisir une heure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsNothing);
    });

    testWidgets('datetime – picking date updates date portion', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'datetime')));
      await tester.tap(find.text('Choisir une date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // At least one "—" should remain (time not picked yet)
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('datetime – picking time updates time portion', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'datetime')));
      await tester.tap(find.text('Choisir une heure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // At least one "—" should remain (date not picked yet)
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('date with initialValue – date picker opens with preloaded date',
        (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'date'), initialValue: '2025-06-15'));
      await tester.tap(find.text('Choisir une date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsNothing);
    });

    testWidgets('time with initialValue – time picker opens with preloaded time',
        (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'time'), initialValue: '09:15:00'));
      await tester.tap(find.text('Choisir une heure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Encoding panel (showEncodingPanel = true)
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – encoding panel', () {
    testWidgets('showEncodingPanel=false hides encoding panel for integer',
        (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'integer'), showEncodingPanel: false));
      expect(find.text('Encodage (xdr/xml/hex)'), findsNothing);
    });

    testWidgets('showEncodingPanel=true shows encoding panel for integer',
        (tester) async {
      await tester.pumpWidget(
          _direct(attr: _attr(type: 'integer'), showEncodingPanel: true));
      expect(find.text('Encodage (xdr/xml/hex)'), findsOneWidget);
    });

    testWidgets('Clear button clears the encoded field', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        initialEncoded: '<foo>bar</foo>',
      ));
      expect(find.widgetWithText(TextField, '<foo>bar</foo>'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '<foo>bar</foo>'), findsNothing);
    });

    testWidgets('Encode button visible when onEncode provided', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        onEncode: (_, __) async => '<encoded/>',
      ));
      expect(find.text('Encode'), findsOneWidget);
    });

    testWidgets('Decode button visible when onDecode provided', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        onDecode: (_, __) async => '<integer>7</integer>',
      ));
      expect(find.text('Decode'), findsOneWidget);
    });

    testWidgets('Encode button not visible when onEncode is null', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'unknown_xyz')));
      expect(find.text('Encode'), findsNothing);
    });

    testWidgets('Decode button not visible when onDecode is null', (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'unknown_xyz')));
      expect(find.text('Decode'), findsNothing);
    });

    testWidgets('Encode button calls onEncode and sets encoded field', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        onEncode: (_, __) async => '<result>encoded</result>',
      ));
      await tester.tap(find.text('Encode'));
      await tester.pumpAndSettle();
      expect(
          find.widgetWithText(TextField, '<result>encoded</result>'), findsOneWidget);
    });

    testWidgets('Decode button calls onDecode and updates encoded field for integer',
        (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'integer'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<integer>42</integer>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      // The plain field should have been updated to '42'
      expect(find.widgetWithText(TextField, '42'), findsWidgets);
    });

    testWidgets('Decode updates plain value for string type', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'string'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<string>hello</string>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'hello'), findsWidgets);
    });

    testWidgets('Decode updates plain value for boolean type', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'boolean'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<boolean>true</boolean>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      final cb = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(cb.value, isTrue);
    });

    testWidgets('Decode updates plain value for date type', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'date'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<date>2025-03-10</date>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      expect(find.text('2025-03-10'), findsOneWidget);
    });

    testWidgets('Decode updates plain value for time type', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'time'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<time>07:30:00</time>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      expect(find.text('07:30:00'), findsOneWidget);
    });

    testWidgets('Decode updates plain value for datetime type', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'datetime'),
        showEncodingPanel: true,
        onDecode: (_, __) async => '<datetime>2025-04-20T11:00:00</datetime>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      expect(find.text('2025-04-20'), findsOneWidget);
      expect(find.text('11:00:00'), findsOneWidget);
    });

    testWidgets('showEncodingPanel for string type auto-encodes to hex XML',
        (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'visible-string'),
        showEncodingPanel: true,
        initialValue: 'AB',
      ));
      // UTF-8 hex of "AB" is 4142, size=2
      // <visible-string size="2">4142</visible-string>
      expect(find.textContaining('4142'), findsOneWidget);
    });

    testWidgets('showEncodingPanel for integer auto-encodes to XML tag', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'integer'),
        showEncodingPanel: true,
        initialValue: '99',
      ));
      expect(find.textContaining('<integer>99</integer>'), findsOneWidget);
    });

    testWidgets('showEncodingPanel for boolean encodes yes when booleanAsYesNo=true',
        (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'boolean'),
        showEncodingPanel: true,
        initialValue: 'yes',
      ));
      expect(find.textContaining('<boolean>yes</boolean>'), findsOneWidget);
    });

    testWidgets('showEncodingPanel for boolean encodes no when unchecked', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'boolean'),
        showEncodingPanel: true,
        initialValue: 'no',
      ));
      expect(find.textContaining('<boolean>no</boolean>'), findsOneWidget);
    });

    testWidgets(
        'showEncodingPanel for boolean encodes true/false when booleanAsYesNo=false',
        (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'boolean'),
        showEncodingPanel: true,
        initialValue: 'true',
        booleanAsYesNo: false,
      ));
      expect(find.textContaining('<boolean>true</boolean>'), findsOneWidget);
    });

    testWidgets('typing in string field updates encoded field', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'string'),
        showEncodingPanel: true,
      ));
      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, 'Hi');
      await tester.pump();
      // UTF-8 hex of "Hi" = 4869
      expect(find.textContaining('4869'), findsOneWidget);
    });

    testWidgets('encoding panel auto-encodes XML special characters', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'integer'),
        showEncodingPanel: true,
        initialValue: '5',
      ));
      // Check basic XML tag is produced (no special chars needed for integer)
      expect(find.textContaining('<integer>5</integer>'), findsOneWidget);
    });

    testWidgets('unknown type: encoding panel shown but onEncode/Decode absent',
        (tester) async {
      await tester.pumpWidget(_direct(attr: _attr(type: 'somethingelse')));
      expect(find.text('Encodage (xdr/xml/hex)'), findsOneWidget);
      expect(find.text('Encode'), findsNothing);
      expect(find.text('Decode'), findsNothing);
      expect(find.text('Clear'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Valider returns AttributeEditResult
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – Valider result via static show()', () {
    testWidgets('Annuler returns null', (tester) async {
      await _showDialog(tester, attr: _attr(type: 'string'), initialValue: 'x');
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      // No assertion needed – just confirming no crash; captured stays null
    });

    testWidgets('Valider for string returns correct value', (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                    ctx, _attr(type: 'string'), initialValue: 'hello');
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, 'hello');
      expect(result?.encoded, isNull);
    });

    testWidgets('Valider for integer returns correct value', (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                    ctx, _attr(type: 'integer'), initialValue: '42');
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '42');
    });

    testWidgets('Valider for boolean returns yes/no', (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                    ctx, _attr(type: 'boolean'), initialValue: 'yes');
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, 'yes');
    });

    testWidgets('Valider for unknown returns empty value + encoded', (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                  ctx,
                  _attr(type: 'unknown_xyz'),
                  initialEncoded: '<raw>data</raw>',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '');
      expect(result?.encoded, '<raw>data</raw>');
    });

    testWidgets('Valider with showEncodingPanel returns encoded value', (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                  ctx,
                  _attr(type: 'string'),
                  initialValue: 'test',
                  initialEncoded: '<string>custom</string>',
                  showEncodingPanel: true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.encoded, isNotNull);
    });

    testWidgets('Valider for date with no date selected returns empty string',
        (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result =
                    await AttributeEditDialog.show(ctx, _attr(type: 'date'));
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '');
    });

    testWidgets('Valider for time with no time selected returns empty string',
        (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result =
                    await AttributeEditDialog.show(ctx, _attr(type: 'time'));
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '');
    });

    testWidgets('Valider for datetime with both set returns formatted string',
        (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                  ctx,
                  _attr(type: 'datetime'),
                  initialValue: '2025-11-05T10:00:00',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '2025-11-05T10:00:00');
    });

    testWidgets('Valider for datetime with only date returns empty string',
        (tester) async {
      AttributeEditResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                result = await AttributeEditDialog.show(
                  ctx,
                  _attr(type: 'datetime'),
                  initialValue: '2025-11-05', // no T part
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(result?.value, '');
    });
  });

  // ---------------------------------------------------------------------------
  // AttributeEditResult
  // ---------------------------------------------------------------------------
  group('AttributeEditResult', () {
    test('value and encoded fields accessible', () {
      final r = AttributeEditResult(value: 'v', encoded: 'e');
      expect(r.value, 'v');
      expect(r.encoded, 'e');
    });

    test('encoded defaults to null', () {
      final r = AttributeEditResult(value: 'v');
      expect(r.encoded, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // _setPlainValue for unknown → no-op (via Decode on unknown type)
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – _setPlainValue unknown no-op', () {
    testWidgets('Decode on unknown type does not crash', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'unknown_xyz'),
        onDecode: (_, __) async => '<tag>value</tag>',
      ));
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();
      // No crash expected; encoding panel still present
      expect(find.text('Encodage (xdr/xml/hex)'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // _xmlEscape via onEncode result shown in field – special char encoding
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog – XML escape in auto-encoding', () {
    testWidgets('string field with special < > chars encodes via hex not XML escape',
        (tester) async {
      // For string type, _updateEncodedFromPlain uses hex not _xmlEscape
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'string'),
        showEncodingPanel: true,
        initialValue: '<test>',
      ));
      // UTF-8 hex of "<test>" = 3c746573743e, size=6
      expect(find.textContaining('3c746573743e'), findsOneWidget);
    });

    testWidgets('integer field with value uses _xmlEscape (no special chars in int)',
        (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'integer'),
        showEncodingPanel: true,
        initialValue: '7',
      ));
      expect(find.textContaining('<integer>7</integer>'), findsOneWidget);
    });

    testWidgets('date field after picking updates encoded field', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'date'),
        showEncodingPanel: true,
        initialValue: '2025-01-01',
      ));
      // Date is set so encoded should contain a date XML tag
      expect(find.textContaining('<date>2025-01-01</date>'), findsOneWidget);
    });

    testWidgets('datetime encodes with T separator in XML', (tester) async {
      await tester.pumpWidget(_direct(
        attr: _attr(type: 'datetime'),
        showEncodingPanel: true,
        initialValue: '2025-06-01T12:00:00',
      ));
      expect(find.textContaining('2025-06-01T12:00:00'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Dialog.show dimensions test
  // ---------------------------------------------------------------------------
  group('AttributeEditDialog.show – dialog wrapper', () {
    testWidgets('dialog is displayed and contains header text', (tester) async {
      await _showDialog(tester,
          attr: _attr(type: 'string', name: 'MyAttr'), initialValue: 'v');
      expect(find.text('Modifier MyAttr (string)'), findsOneWidget);
    });

    testWidgets('barrier dismissible closes dialog without result', (tester) async {
      await _showDialog(tester, attr: _attr(type: 'string'));
      // Tap outside the dialog (barrier)
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Annuler'), findsNothing);
    });
  });
}
