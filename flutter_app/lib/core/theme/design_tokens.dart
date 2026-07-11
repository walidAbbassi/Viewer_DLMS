import 'package:flutter/material.dart';

/// Centralisation des tokens de design (alignés sur firmware + DLMS v2 maquette)
class DesignTokens {
  // Brand / Primary
  static const Color primary600 = Color(0xFF1976D2);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary50 = Color(0xFFE3F2FD);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0x1A4CAF50); // 10%
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0x1AFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color dangerLight = Color(0x1AF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0x1A2196F3);

  // Neutral / Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Surfaces
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF5F7FA);

  // Dark mode surfaces & borders (public — use via helpers below or directly)
  static const Color darkBackground    = Color(0xFF0F172A);
  static const Color darkSurface       = Color(0xFF1E293B);
  static const Color darkSurfaceAlt    = Color(0xFF1E3A5F);
  static const Color darkBorder        = Color(0xFF334155);
  static const Color darkHint          = Color(0xFF64748B);
  static const Color darkFocus         = Color(0xFF60A5FA);
  static const Color darkFill          = Color(0xFF1E3A5F);
  static const Color darkTextPrimary   = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Radii
  static const double radiusSm = 6;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  // Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Spacing scale
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  static BorderRadius brSm = BorderRadius.circular(radiusSm);
  static BorderRadius brMd = BorderRadius.circular(radiusMd);
  static BorderRadius brLg = BorderRadius.circular(radiusLg);
  static BorderRadius brXl = BorderRadius.circular(radiusXl);

  // ---- Dark-aware helpers (use these from pages instead of duplicating
  // `Theme.of(context).brightness == Brightness.dark` ternaries everywhere)

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext c)       => isDark(c) ? darkSurface       : surface;
  static Color surfaceAltOf(BuildContext c)    => isDark(c) ? darkSurfaceAlt    : surfaceAlt;
  static Color backgroundOf(BuildContext c)    => isDark(c) ? darkBackground    : background;
  static Color borderOf(BuildContext c)        => isDark(c) ? darkBorder        : gray300;
  static Color textPrimaryOf(BuildContext c)   => isDark(c) ? darkTextPrimary   : textPrimary;
  static Color textSecondaryOf(BuildContext c) => isDark(c) ? darkTextSecondary : textSecondary;

  static InputDecoration inputDecoration({String? hint, Widget? suffix, bool isDark = false}) {
    final fill   = isDark ? darkFill   : surface;
    final border = isDark ? darkBorder : gray300;
    final hint_  = isDark ? darkHint   : gray600;
    final focus  = isDark ? darkFocus  : primary600;
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      hintStyle: TextStyle(fontSize: 14, color: hint_),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: brMd,
        borderSide: BorderSide(color: border, width: .9),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: brMd,
        borderSide: BorderSide(color: border, width: .9),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: brMd,
        borderSide: BorderSide(color: focus, width: 1.2),
      ),
    );
  }

  /// Context-aware variant — automatically detects dark/light from [BuildContext].
  static InputDecoration inputDecorationOf(
    BuildContext context, {
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    final dark = isDark(context);
    return inputDecoration(hint: hint, suffix: suffix, isDark: dark).copyWith(
      prefixIcon: prefix,
    );
  }

  // ── Card / container helpers ─────────────────────────────────────────────

  /// Returns a [BoxDecoration] for a standard content card, adapted to the
  /// current brightness.
  static BoxDecoration cardDecoration(BuildContext context, {
    double radius = radiusMd,
    bool elevated = false,
  }) {
    final dark = isDark(context);
    return BoxDecoration(
      color:        dark ? darkSurface : surface,
      border:       Border.all(color: dark ? darkBorder : gray200),
      borderRadius: BorderRadius.circular(radius),
      boxShadow:    elevated ? (dark ? _darkShadowSm : shadowSm) : null,
    );
  }

  static const List<BoxShadow> _darkShadowSm = [
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // ── Semantic color helpers ───────────────────────────────────────────────

  /// Returns the correct accent/primary color for the current brightness.
  static Color accentOf(BuildContext context) =>
      isDark(context) ? darkFocus : primary600;

  static Color hintOf(BuildContext context) =>
      isDark(context) ? darkHint : gray600;
}

/// Badge style helper
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, this.icon, this.compact = false});
  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fg = color;
    final bg = color.withOpacity(.12);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: compact ? 10 : 12, fontWeight: FontWeight.w600, color: fg, letterSpacing: .4)),
        ],
      ),
    );
  }
}
