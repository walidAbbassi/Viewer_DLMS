// core/services/feedback_service.dart
//
// Point unique pour tout message utilisateur (SnackBar).
// RÈGLE : la couleur découle du TYPE de message, jamais d'un paramètre.
// Un refus / une erreur n'est JAMAIS vert. Corrige « Authorization: Denied »
// affiché en vert (Firmware Download, Fraud Detection Log).

import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';

enum FeedbackType { success, error, warning, info }

class FeedbackService {
  FeedbackService(this.messengerKey);

  /// GlobalKey<ScaffoldMessengerState> déclarée dans
  /// MaterialApp(scaffoldMessengerKey: …) — voir [appMessengerKey].
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  void success(String msg) => _show(msg, FeedbackType.success);
  void error(String msg) => _show(msg, FeedbackType.error);
  void warning(String msg) => _show(msg, FeedbackType.warning);
  void info(String msg) => _show(msg, FeedbackType.info);

  void _show(String msg, FeedbackType type) {
    final messenger = messengerKey.currentState;
    final context = messengerKey.currentContext;
    if (messenger == null || context == null) return;
    final c = SemanticColors.of(context);

    final (Color bg, IconData icon) = switch (type) {
      FeedbackType.success => (c.success, Icons.check_circle),
      FeedbackType.error => (c.error, Icons.error),
      FeedbackType.warning => (c.warning, Icons.warning_amber),
      FeedbackType.info => (c.info, Icons.info),
    };

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: type == FeedbackType.error ? 6 : 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(msg, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
  }
}

/// App-wide scaffold messenger key — wire into
/// `MaterialApp(scaffoldMessengerKey: appMessengerKey)`.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// App-wide feedback instance. Usage: `feedback.error('Authorization: Denied')`
/// — no BuildContext needed at the call site, and the color is always derived
/// from the message type.
final FeedbackService feedback = FeedbackService(appMessengerKey);
