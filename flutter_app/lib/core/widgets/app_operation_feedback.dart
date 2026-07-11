import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppOperationFeedback
//
// Centralises all Read / Write success & failure dialogs across every page.
// Usage:
//   await AppOperationFeedback.showReadSuccess(context);
//   await AppOperationFeedback.showReadError(context, error);
//   await AppOperationFeedback.showWriteSuccess(context);
//   await AppOperationFeedback.showWriteError(context, error);
//   await AppOperationFeedback.showWriteResult(context, ok: true);
//
// Helper wrappers:
//   await AppOperationFeedback.runRead(context, () async { ... });
//   await AppOperationFeedback.runWrite(context, () async { ... });
// ─────────────────────────────────────────────────────────────────────────────

class AppOperationFeedback {
  AppOperationFeedback._();

  // ── Low-level show helpers ─────────────────────────────────────────────────

  static Future<void> showReadSuccess(
    BuildContext context, {
    String? message,
  }) =>
      _show(
        context,
        type: _FeedbackType.readSuccess,
        message: message ?? 'The values were read from the meter successfully.',
      );

  static Future<void> showReadError(
    BuildContext context,
    dynamic error, {
    String? message,
  }) =>
      _show(
        context,
        type: _FeedbackType.readError,
        message: message ?? _friendlyError(error),
      );

  static Future<void> showWriteSuccess(
    BuildContext context, {
    String? message,
  }) =>
      _show(
        context,
        type: _FeedbackType.writeSuccess,
        message: message ?? 'The value was written to the meter successfully.',
      );

  static Future<void> showWriteError(
    BuildContext context,
    dynamic error, {
    String? message,
  }) =>
      _show(
        context,
        type: _FeedbackType.writeError,
        message: message ?? _friendlyError(error),
      );

  /// Shows success or failure depending on [ok]. Handy for gRPC calls that
  /// return a boolean acknowledgement.
  static Future<void> showWriteResult(
    BuildContext context, {
    required bool ok,
    String? successMessage,
    String? failureMessage,
  }) =>
      ok
          ? showWriteSuccess(context, message: successMessage)
          : _show(
              context,
              type: _FeedbackType.writeError,
              message: failureMessage ??
                  'The meter did not accept the write request.',
            );

  // ── High-level wrappers ────────────────────────────────────────────────────

  /// Runs [action], then shows the appropriate success / error dialog.
  /// Returns `true` if the action succeeded.
  static Future<bool> runRead(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) return true;
      await showReadSuccess(context, message: successMessage);
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      await showReadError(context, e, message: errorMessage);
      return false;
    }
  }

  /// Runs [action] (which should return a bool acknowledgement),
  /// then shows the appropriate dialog.
  static Future<bool> runWrite(
    BuildContext context,
    Future<bool> Function() action, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      final ok = await action();
      if (!context.mounted) return ok;
      await showWriteResult(
        context,
        ok: ok,
        successMessage: successMessage,
        failureMessage: errorMessage,
      );
      return ok;
    } catch (e) {
      if (!context.mounted) return false;
      await showWriteError(context, e, message: errorMessage);
      return false;
    }
  }

  /// Variant for write actions that return void (fire-and-forget gRPC calls).
  static Future<bool> runWriteVoid(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) return true;
      await showWriteSuccess(context, message: successMessage);
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      await showWriteError(context, e, message: errorMessage);
      return false;
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _show(
    BuildContext context, {
    required _FeedbackType type,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _FeedbackDialog(type: type, message: message),
    );
  }

  static String _friendlyError(dynamic e) {
    try {
      final msg = (e as dynamic).message as String?;
      if (msg != null && msg.isNotEmpty) return _mapMessage(msg);
    } catch (_) {}
    return _mapMessage(e.toString());
  }

  /// Maps low-level/cryptic error messages to user-friendly equivalents.
  static String _mapMessage(String msg) {
    final l = msg.toLowerCase();
    if (l.contains('index out of range') ||
        l.contains('pop from empty') ||
        l.contains('connection lost') ||
        l.contains('incomplete')) {
      return 'Connection lost. The meter response was incomplete. '
          'Reconnect and try again.';
    }
    if (l.contains('could not open port') ||
        l.contains('serial port unavailable')) {
      return 'Serial port unavailable. Check the cable and COM port setting.';
    }
    if (l.contains('access denied') || l.contains('permission denied')) {
      return 'Serial port access denied. '
          'Close any application using this port and retry.';
    }
    if (l.contains('timed out') || l.contains('no response from the meter')) {
      return 'No response from the meter. Check the connection and retry.';
    }
    if (l.contains('connection refused')) {
      return 'Connection refused. Verify the IP address, port, and meter power.';
    }
    if (l.contains('connection interrupted') ||
        l.contains('connection reset') ||
        l.contains('broken pipe')) {
      return 'Connection interrupted. Check the link and reconnect.';
    }
    if (l.contains('unreachable')) {
      return 'Meter unreachable. Check the network configuration.';
    }
    if (l.contains('invocation counter') ||
        l.contains('setup association failed') ||
        l.contains('frame counter incorrect')) {
      return 'Frame counter incorrect. Check the frame counter configuration.';
    }
    return msg;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal enum
// ─────────────────────────────────────────────────────────────────────────────

enum _FeedbackType { readSuccess, readError, writeSuccess, writeError }

extension _FeedbackTypeX on _FeedbackType {
  bool get isSuccess =>
      this == _FeedbackType.readSuccess || this == _FeedbackType.writeSuccess;

  bool get isRead =>
      this == _FeedbackType.readSuccess || this == _FeedbackType.readError;

  IconData get icon =>
      isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

  Color get color => isSuccess ? DesignTokens.success : DesignTokens.danger;

  String get title {
    switch (this) {
      case _FeedbackType.readSuccess:
        return 'Read Successful';
      case _FeedbackType.readError:
        return 'Read Failed';
      case _FeedbackType.writeSuccess:
        return 'Write Successful';
      case _FeedbackType.writeError:
        return 'Write Failed';
    }
  }

  Color get bgColor => isSuccess
      ? DesignTokens.success.withOpacity(.10)
      : DesignTokens.danger.withOpacity(.10);
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog widget
// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackDialog extends StatelessWidget {
  const _FeedbackDialog({
    required this.type,
    required this.message,
  });

  final _FeedbackType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final color = type.color;
    final bgColor = isDark ? color.withOpacity(.15) : color.withOpacity(.08);
    final surfaceColor = DesignTokens.surfaceOf(context);
    final borderColor = isDark ? DesignTokens.darkBorder : DesignTokens.gray200;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, minWidth: 280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon badge + title ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Icon(type.icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Operation type label (READ / WRITE)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.isRead ? 'READ' : 'WRITE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.textPrimaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Divider ───────────────────────────────────────────────────
              Divider(
                  height: 1,
                  color:
                      isDark ? DesignTokens.darkBorder : DesignTokens.gray200),
              const SizedBox(height: 16),

              // ── Message ───────────────────────────────────────────────────
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: DesignTokens.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 24),

              // ── OK button ─────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMd)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
