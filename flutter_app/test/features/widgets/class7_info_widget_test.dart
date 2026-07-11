import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_python_grpc/core/user_rights.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/features/widgets/class7_info_widget.dart';

Finder _readButtonFor(String label) {
  final readText = find.text('Read').first;
  return find.ancestor(
    of: readText,
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  ).first;
}

Finder _writeButtonFor(String label) {
  final writeText = find.text('Write').first;
  return find.ancestor(
    of: writeText,
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  ).first;
}

int _fieldIndex(String label) {
  switch (label) {
    case 'Max Record':
      return 0;
    case 'Record Number':
      return 1;
    case 'Capture Period':
      return 2;
    default:
      throw ArgumentError('Unknown Class7 field label: $label');
  }
}

Finder _textFieldFor(String label) {
  return find.byType(TextField).at(_fieldIndex(label));
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Class7InfoWidget', () {
    setUp(() {
      userRights.reset();
      userRights.rights = ['Get', 'Set'];
    });

    tearDown(() {
      userRights.reset();
    });

    testWidgets('renders and expands/collapses', (tester) async {
      await tester.pumpWidget(
        _wrap(const Class7InfoWidget(initiallyExpanded: false, featureKey: '',)),
      );

      expect(find.text('Class 7 Information'), findsOneWidget);
      expect(find.text('Max Record'), findsNothing);

      await tester.tap(find.text('Class 7 Information'));
      await tester.pump();

      expect(find.text('Max Record'), findsOneWidget);

      await tester.tap(find.text('Class 7 Information'));
      await tester.pump();

      expect(find.text('Max Record'), findsNothing);
    });

    testWidgets('hides read/write buttons when callbacks are null', (tester) async {
      await tester.pumpWidget(
        _wrap(const Class7InfoWidget(initiallyExpanded: true, featureKey: '',)),
      );

      expect(find.byTooltip('Read'), findsNothing);
      expect(find.byTooltip('Write'), findsNothing);
    });

    testWidgets('read success writes value into the correct field', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadMaxRecord: () async => 5, featureKey: '',
          ),
        ),
      );

      await tester.tap(_readButtonFor('Max Record'));
      await tester.pump();

      final tf = tester.widget<TextField>(_textFieldFor('Max Record'));
      expect(tf.controller!.text, equals('5'));
    });

    testWidgets('read error shows error text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadRecordNumber: () async => throw Exception('nope'), featureKey: '',
          ),
        ),
      );

      expect(find.textContaining('Error:'), findsNothing);

      await tester.tap(_readButtonFor('Record Number'));
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('write ignores non-int input and does not call callback', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onSetCapturePeriod: (value) async {
              calls += 1;
            }, featureKey: '',
          ),
        ),
      );

      await tester.enterText(_textFieldFor('Capture Period'), 'abc');
      await tester.tap(_writeButtonFor('Capture Period'));
      await tester.pump();

      expect(calls, equals(0));
      expect(find.textContaining('Error:'), findsNothing);
    });

    testWidgets('write success calls callback with parsed int', (tester) async {
      int? captured;

      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onSetMaxRecord: (value) async {
              captured = value;
            }, featureKey: '',
          ),
        ),
      );

      await tester.enterText(_textFieldFor('Max Record'), '12');
      await tester.tap(_writeButtonFor('Max Record'));
      await tester.pump();

      expect(captured, equals(12));
    });

    testWidgets('write error shows error text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onSetRecordNumber: (value) async => throw Exception('bad'), featureKey: '',
          ),
        ),
      );

      await tester.enterText(_textFieldFor('Record Number'), '7');
      await tester.tap(_writeButtonFor('Record Number'));
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('shows loading indicator and disables field while reading', (tester) async {
      final completer = Completer<int>();

      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadCapturePeriod: () => completer.future, featureKey: '',
          ),
        ),
      );

      await tester.tap(_readButtonFor('Capture Period'));
      await tester.pump();

      // Button should show progress while loading.
      expect(
        find.descendant(
          of: _readButtonFor('Capture Period'),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      // TextField is disabled while loading.
      final tf = tester.widget<TextField>(_textFieldFor('Capture Period'));
      expect(tf.enabled, isFalse);

      completer.complete(99);
      await tester.pump();

      final tfAfter = tester.widget<TextField>(_textFieldFor('Capture Period'));
      expect(tfAfter.controller!.text, equals('99'));
      expect(tfAfter.enabled, isTrue);
    });

    testWidgets('shows loading indicator and disables field while writing', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onSetCapturePeriod: (value) => completer.future, featureKey: '',
          ),
        ),
      );

      await tester.enterText(_textFieldFor('Capture Period'), '1');
      await tester.tap(_writeButtonFor('Capture Period'));
      await tester.pump();

      expect(
        find.descendant(
          of: _writeButtonFor('Capture Period'),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      final tf = tester.widget<TextField>(_textFieldFor('Capture Period'));
      expect(tf.enabled, isFalse);

      completer.complete();
      await tester.pump();

      final tfAfter = tester.widget<TextField>(_textFieldFor('Capture Period'));
      expect(tfAfter.enabled, isTrue);
    });

    testWidgets('record number read success updates the controller text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadRecordNumber: () async => 42, featureKey: '',
          ),
        ),
      );

      await tester.tap(_readButtonFor('Record Number'));
      await tester.pump();

      final tf = tester.widget<TextField>(_textFieldFor('Record Number'));
      expect(tf.controller!.text, equals('42'));
    });

    testWidgets('max record read+write error branches are surfaced', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadMaxRecord: () async => throw Exception('read-fail'),
            onSetMaxRecord: (value) async => throw Exception('write-fail'), featureKey: '',
          ),
        ),
      );

      await tester.tap(_readButtonFor('Max Record'));
      await tester.pump();
      expect(find.textContaining('Error:'), findsOneWidget);

      await tester.enterText(_textFieldFor('Max Record'), '1');
      await tester.tap(_writeButtonFor('Max Record'));
      await tester.pump();
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('capture period read+write error branches are surfaced', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Class7InfoWidget(
            initiallyExpanded: true,
            onReadCapturePeriod: () async => throw Exception('read-fail'),
            onSetCapturePeriod: (value) async => throw Exception('write-fail'), featureKey: '',
          ),
        ),
      );

      await tester.tap(_readButtonFor('Capture Period'));
      await tester.pump();
      expect(find.textContaining('Error:'), findsOneWidget);

      await tester.enterText(_textFieldFor('Capture Period'), '2');
      await tester.tap(_writeButtonFor('Capture Period'));
      await tester.pump();
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
