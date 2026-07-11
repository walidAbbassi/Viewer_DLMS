import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/core/widgets/app_operation_feedback.dart';

// ---------------------------------------------------------------------------
// Minimal fake that exposes a `.message` field, matching the GrpcError shape
// that `_friendlyError` inspects.
// ---------------------------------------------------------------------------
class _FakeError {
  _FakeError(this.message);
  final String? message;
  @override
  String toString() => message ?? 'null';
}

// Helper: show a read-error dialog and return the displayed message text.
// Scopes the search to the Dialog widget to avoid picking up the trigger
// button or other chrome (READ/WRITE badge, title, OK action).
Future<String?> _captureErrorMessage(WidgetTester tester, dynamic error) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => AppOperationFeedback.showReadError(ctx, error),
          child: const Text('trigger'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('trigger'));
  await tester.pumpAndSettle();

  const _chrome = {
    'READ', 'WRITE', 'OK',
    'Read Failed', 'Write Failed',
    'Read Successful', 'Write Successful',
  };
  final dialog = find.byType(Dialog);
  if (dialog.evaluate().isEmpty) return null;

  final texts = tester
      .widgetList<Text>(find.descendant(of: dialog, matching: find.byType(Text)))
      .map((t) => t.data ?? '')
      .where((s) => s.isNotEmpty && !_chrome.contains(s))
      .toList();

  return texts.isNotEmpty ? texts.first : null;
}

void main() {
  group('AppOperationFeedback – _friendlyError / _mapMessage', () {
    testWidgets('"list index out of range" maps to connection-lost message',
        (tester) async {
      final msg = await _captureErrorMessage(
        tester,
        _FakeError('list index out of range'),
      );
      expect(msg, contains('Connection lost'));
    });

    testWidgets('"pop from empty list" maps to connection-lost message',
        (tester) async {
      final msg = await _captureErrorMessage(
        tester,
        _FakeError('pop from empty list'),
      );
      expect(msg, contains('Connection lost'));
    });

    testWidgets('normal gRPC message is displayed unchanged', (tester) async {
      const normal = 'Object not found in datamodel';
      final msg = await _captureErrorMessage(tester, _FakeError(normal));
      expect(msg, normal);
    });

    testWidgets(
        'error without .message field falls back to toString, still mapped',
        (tester) async {
      // An object whose toString contains the cryptic pattern
      final msg = await _captureErrorMessage(
        tester,
        Exception('index out of range'),
      );
      expect(msg, contains('Connection lost'));
    });

    testWidgets(
        'error without .message field falls back to toString unchanged '
        'when no mapping applies', (tester) async {
      final msg = await _captureErrorMessage(
        tester,
        Exception('some unrelated error'),
      );
      expect(msg, isNotNull);
      expect(msg, isNot(contains('Connection lost')));
    });

    testWidgets('"could not open port" maps to serial port unavailable message',
        (tester) async {
      final msg = await _captureErrorMessage(
        tester,
        _FakeError(
            "could not open port COM4: [Errno 2] No such file or directory: 'COM4'"),
      );
      expect(msg, contains('Serial port unavailable'));
    });
  });
}
