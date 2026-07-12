import 'package:flutter/material.dart';

/// Single source of truth for Viewer_NG's semantic colors (see docs/SPECS_UI.md).
///
/// Rule: no hardcoded `Color(0xFF…)` in pages for feedback/buttons — always go
/// through `SemanticColors.of(context)`. Green and red are reserved for
/// STATUS only (never repurposed as a "read" or "action" button color), and
/// there is no orange in the palette.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color surface;
  final Color surfaceVariant;
  final Color background;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;

  const SemanticColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.surface,
    required this.surfaceVariant,
    required this.background,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
  });

  static const light = SemanticColors(
    primary: Color(0xFF1565C0),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF0277BD),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFE65100),
    error: Color(0xFFB00020),
    info: Color(0xFF0277BD),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F5F5),
    background: Color(0xFFF7F9FC),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFE0E0E0),
  );

  static const dark = SemanticColors(
    primary: Color(0xFF90CAF9),
    onPrimary: Color(0xFF003C8F),
    secondary: Color(0xFF81D4FA),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFCF6679),
    info: Color(0xFF81D4FA),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF243044),
    background: Color(0xFF0F172A),
    onSurface: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFFCBD5E1),
    outline: Color(0xFF334155),
  );

  static SemanticColors of(BuildContext context) =>
      Theme.of(context).extension<SemanticColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  SemanticColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? surface,
    Color? surfaceVariant,
    Color? background,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
  }) {
    return SemanticColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      background: background ?? this.background,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}
