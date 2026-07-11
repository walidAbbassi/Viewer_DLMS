import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/core/user_rights.dart';
import 'package:flutter_python_grpc/features/widgets/partial_read_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _section(String title) {
  return find
      .ancestor(of: find.text(title), matching: find.byType(Container))
      .first;
}

Finder _dateTapTarget(String sectionTitle) {
  final section = _section(sectionTitle);
  final icon = find.descendant(of: section, matching: find.byIcon(Icons.calendar_today));
  return find.ancestor(of: icon, matching: find.byType(InkWell)).first;
}

Finder _timeTapTarget(String sectionTitle) {
  final section = _section(sectionTitle);
  final icon = find.descendant(of: section, matching: find.byIcon(Icons.access_time));
  return find.ancestor(of: icon, matching: find.byType(InkWell)).first;
}

Finder _deviationField(String sectionTitle) {
  final section = _section(sectionTitle);
  return find.descendant(of: section, matching: find.byType(TextField)).first;
}

Finder _statusDropdown(String sectionTitle) {
  final section = _section(sectionTitle);
  return find.descendant(of: section, matching: find.byType(DropdownButtonFormField<String>)).first;
}

void main() {
  group('PartialReadWidget', () {
    setUp(() {
      userRights.reset();
      userRights.rights = ['Get'];
    });

    tearDown(() {
      userRights.reset();
    });

    Future<void> _setLargeSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    testWidgets('renders and expands/collapses', (tester) async {
      await _setLargeSurface(tester);
      await tester.pumpWidget(
        _wrap(const PartialReadWidget(initiallyExpanded: false, featureKey: '',)),
      );

      expect(find.text('Partial Read Configuration'), findsOneWidget);
      expect(find.text('Start Date & Time'), findsNothing);

      await tester.tap(find.text('Partial Read Configuration'));
      await tester.pump();

      expect(find.text('Start Date & Time'), findsOneWidget);

      await tester.tap(find.text('Partial Read Configuration'));
      await tester.pump();

      expect(find.text('Start Date & Time'), findsNothing);
    });

    testWidgets('Read button invokes onRead', (tester) async {
      await _setLargeSurface(tester);
      var calls = 0;
      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            onRead: () => calls += 1, featureKey: '',
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      final readButton = find
          .ancestor(
            of: find.byIcon(Icons.visibility),
            matching: find.byWidgetPredicate((w) => w is ElevatedButton),
          )
          .first;
      await tester.tap(readButton);
      await tester.pump();

      expect(calls, equals(1));
    });

    testWidgets('date picker null does not call callbacks', (tester) async {
      await _setLargeSurface(tester);
      var startCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            datePicker: (context, initial) async => null,
            onStartChanged: (dt, dev, status) => startCalls += 1, featureKey: '',
          ),
        ),
      );

      await tester.tap(_dateTapTarget('Start Date & Time'));
      await tester.pump();

      expect(startCalls, equals(0));
    });

    testWidgets('date picker updates start date and triggers onStartChanged', (tester) async {
      await _setLargeSurface(tester);
      DateTime? captured;
      String? capturedDev;
      String? capturedStatus;

      final fixedNow = DateTime(2020, 1, 8, 10, 11, 12);

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            startDate: fixedNow,
            datePicker: (context, initial) async => DateTime(2020, 2, 3),
            onStartChanged: (dt, dev, status) {
              captured = dt;
              capturedDev = dev;
              capturedStatus = status;
            }, featureKey: '',
          ),
        ),
      );

      await tester.tap(_dateTapTarget('Start Date & Time'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.year, equals(2020));
      expect(captured!.month, equals(2));
      expect(captured!.day, equals(3));
      // time preserved
      expect(captured!.hour, equals(10));
      expect(captured!.minute, equals(11));
      expect(captured!.second, equals(12));
      expect(capturedDev, isNotNull);
      expect(capturedStatus, equals('Default'));
    });

    testWidgets('date picker updates end date and triggers onEndChanged', (tester) async {
      await _setLargeSurface(tester);
      DateTime? captured;
      String? capturedDev;
      String? capturedStatus;

      final fixedEnd = DateTime(2020, 1, 8, 10, 11, 12);

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            endDate: fixedEnd,
            datePicker: (context, initial) async => DateTime(2020, 2, 3),
            onEndChanged: (dt, dev, status) {
              captured = dt;
              capturedDev = dev;
              capturedStatus = status;
            }, featureKey: '',
          ),
        ),
      );

      await tester.tap(_dateTapTarget('End Date & Time'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.year, equals(2020));
      expect(captured!.month, equals(2));
      expect(captured!.day, equals(3));
      // time preserved
      expect(captured!.hour, equals(10));
      expect(captured!.minute, equals(11));
      expect(captured!.second, equals(12));
      expect(capturedDev, isNotNull);
      expect(capturedStatus, equals('Default'));
    });

    testWidgets('time picker null does nothing', (tester) async {
      await _setLargeSurface(tester);
      var endCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            timePicker: (context, initial) async => null,
            onEndChanged: (dt, dev, status) => endCalls += 1, featureKey: '',
          ),
        ),
      );

      await tester.tap(_timeTapTarget('End Date & Time'));
      await tester.pump();

      expect(endCalls, equals(0));
    });

    testWidgets('time picker + seconds picker updates end date time', (tester) async {
      await _setLargeSurface(tester);
      DateTime? captured;

      final end = DateTime(2020, 1, 8, 1, 2, 3);

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            endDate: end,
            timePicker: (context, initial) async => const TimeOfDay(hour: 4, minute: 5),
            secondsPicker: (context, initialSeconds) async => 6,
            onEndChanged: (dt, dev, status) => captured = dt, featureKey: '',
          ),
        ),
      );

      await tester.tap(_timeTapTarget('End Date & Time'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured, equals(DateTime(2020, 1, 8, 4, 5, 6)));
    });

    testWidgets('time picker + seconds picker updates start date time', (tester) async {
      await _setLargeSurface(tester);
      DateTime? captured;

      final start = DateTime(2020, 1, 8, 1, 2, 3);

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            startDate: start,
            timePicker: (context, initial) async => const TimeOfDay(hour: 4, minute: 5),
            secondsPicker: (context, initialSeconds) async => 6,
            onStartChanged: (dt, dev, status) => captured = dt, featureKey: '',
          ),
        ),
      );

      await tester.tap(_timeTapTarget('Start Date & Time'));
      await tester.pump();
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured, equals(DateTime(2020, 1, 8, 4, 5, 6)));
    });

    testWidgets('time picker guard: does not crash if widget unmounted mid-await', (tester) async {
      await _setLargeSurface(tester);
      final completer = Completer<TimeOfDay?>();

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            timePicker: (context, initial) => completer.future,
            secondsPicker: (context, initialSeconds) async => 1, featureKey: '',
          ),
        ),
      );

      await tester.tap(_timeTapTarget('Start Date & Time'));
      await tester.pump();

      // Unmount widget before the future completes.
      await tester.pumpWidget(const SizedBox.shrink());

      completer.complete(const TimeOfDay(hour: 1, minute: 2));
      await tester.pump();

      // If we get here without exceptions, guard worked.
      expect(find.byType(PartialReadWidget), findsNothing);
    });

    testWidgets('deviation enforces hex-only and calls callbacks', (tester) async {
      await _setLargeSurface(tester);
      String? lastDev;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            onStartChanged: (dt, dev, status) => lastDev = dev, featureKey: '',
          ),
        ),
      );

      await tester.enterText(_deviationField('Start Date & Time'), '1G');
      await tester.pump();

      final tf = tester.widget<TextField>(_deviationField('Start Date & Time'));
      expect(tf.controller!.text, equals('1'));
      expect(lastDev, equals('1'));
    });

    testWidgets('end deviation calls onEndChanged', (tester) async {
      await _setLargeSurface(tester);
      String? lastDev;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            onEndChanged: (dt, dev, status) => lastDev = dev, featureKey: '',
          ),
        ),
      );

      await tester.enterText(_deviationField('End Date & Time'), 'AB');
      await tester.pump();

      expect(lastDev, equals('AB'));
    });

    testWidgets('status dropdown change calls the correct callback', (tester) async {
      await _setLargeSurface(tester);
      String? lastStatus;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            onEndChanged: (dt, dev, status) => lastStatus = status, featureKey: '',
          ),
        ),
      );

      await tester.tap(_statusDropdown('End Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Winter').last);
      await tester.pump();

      expect(lastStatus, equals('Winter'));
    });

    testWidgets('start status dropdown change calls onStartChanged', (tester) async {
      await _setLargeSurface(tester);
      String? lastStatus;

      await tester.pumpWidget(
        _wrap(
          PartialReadWidget(
            onStartChanged: (dt, dev, status) => lastStatus = status, featureKey: '',
          ),
        ),
      );

      await tester.tap(_statusDropdown('Start Date & Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Summer').last);
      await tester.pump();

      expect(lastStatus, equals('Summer'));
    });
  });
}
