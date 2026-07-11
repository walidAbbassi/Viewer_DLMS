import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/features/widgets/partial_read_pickers.dart';

class _FakePickers implements PartialReadPickers {
  DateTime? dateResult;
  TimeOfDay? timeResult;
  int? secondsResult;

  BuildContext? lastContext;
  DateTime? lastInitialDate;
  TimeOfDay? lastInitialTime;
  int? lastInitialSeconds;

  @override
  Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) async {
    lastContext = context;
    lastInitialDate = initialDate;
    return dateResult;
  }

  @override
  Future<TimeOfDay?> pickTime24h(BuildContext context, TimeOfDay initialTime) async {
    lastContext = context;
    lastInitialTime = initialTime;
    return timeResult;
  }

  @override
  Future<int?> pickSeconds(BuildContext context, int initialSeconds) async {
    lastContext = context;
    lastInitialSeconds = initialSeconds;
    return secondsResult;
  }
}

void main() {
  group('partial_read_pickers', () {
    testWidgets('default pickers delegate to injected PartialReadPickers', (tester) async {
      final original = partialReadPickers;
      final fake = _FakePickers()
        ..dateResult = DateTime(2020, 2, 3)
        ..timeResult = const TimeOfDay(hour: 4, minute: 5)
        ..secondsResult = 6;

      addTearDown(() {
        partialReadPickers = original;
      });

      partialReadPickers = fake;

      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final date = await partialReadDefaultDatePicker(capturedContext, DateTime(2001, 1, 2));
      expect(date, equals(DateTime(2020, 2, 3)));
      expect(fake.lastInitialDate, equals(DateTime(2001, 1, 2)));

      final time = await partialReadDefaultTimePicker24h(
        capturedContext,
        const TimeOfDay(hour: 1, minute: 2),
      );
      expect(time, equals(const TimeOfDay(hour: 4, minute: 5)));
      expect(fake.lastInitialTime, equals(const TimeOfDay(hour: 1, minute: 2)));

      final seconds = await partialReadDefaultSecondsPickerDialog(capturedContext, 7);
      expect(seconds, equals(6));
      expect(fake.lastInitialSeconds, equals(7));

      // Ensure we're passing through the same BuildContext.
      expect(fake.lastContext, same(capturedContext));
    });
  });
}
