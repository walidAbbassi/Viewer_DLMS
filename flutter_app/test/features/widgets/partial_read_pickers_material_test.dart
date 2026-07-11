import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/features/widgets/partial_read_pickers_material.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _textCaseInsensitive(String text) {
  final lower = text.toLowerCase();
  return find.byWidgetPredicate(
    (w) => w is Text && (w.data ?? '').toLowerCase() == lower,
  );
}

void main() {
  group('MaterialPartialReadPickers', () {
    testWidgets('pickDate opens date picker and can be cancelled', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final localizations = MaterialLocalizations.of(context);

      final future = const MaterialPartialReadPickers().pickDate(
        context,
        DateTime(2020, 1, 2),
      );

      await tester.pumpAndSettle();

      // Cancel out of the dialog to complete the Future.
      await tester.tap(_textCaseInsensitive(localizations.cancelButtonLabel).last);
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });

    testWidgets('pickTime24h opens time picker (builder runs) and can be cancelled', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final localizations = MaterialLocalizations.of(context);

      final future = const MaterialPartialReadPickers().pickTime24h(
        context,
        const TimeOfDay(hour: 1, minute: 2),
      );

      await tester.pumpAndSettle();

      await tester.tap(_textCaseInsensitive(localizations.cancelButtonLabel).last);
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });

    testWidgets('pickSeconds dialog cancel returns null', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = const MaterialPartialReadPickers().pickSeconds(context, 1);
      await tester.pumpAndSettle();

      expect(find.text('Select Seconds'), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await future, isNull);
    });

    testWidgets('pickSeconds dialog OK returns updated seconds after scroll', (tester) async {
      // Larger surface helps keep the dialog layout stable.
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      const initialSeconds = 1;
      final future = const MaterialPartialReadPickers().pickSeconds(context, initialSeconds);
      await tester.pumpAndSettle();

      // Drag enough to guarantee the selected index changes.
      await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, isNotNull);
      expect(result, isNot(equals(initialSeconds)));
    });
  });
}
