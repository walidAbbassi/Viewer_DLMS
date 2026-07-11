import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StableTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  const StableTooltip({super.key, required this.message, required this.child});

  bool get _useHover =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS; // hover off on desktop

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: ValueKey<String>(message),                // stable key
      message: message,
      triggerMode: _useHover
          ? TooltipTriggerMode.longPress             // mobile: long-press
          : TooltipTriggerMode.tap,                  // desktop: tap (avoid hover overlays)
      waitDuration: const Duration(milliseconds: 300),
      showDuration: const Duration(seconds: 3),
      preferBelow: true,
      child: child,
    );
  }
}
