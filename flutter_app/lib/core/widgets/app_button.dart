// core/widgets/app_button.dart
//
// Convention UNIQUE de boutons. Fin des couleurs ad hoc par page (orange, vert
// « action », gris). Règle :
//   - primary   : action principale (Write, Connect, Activate, Prepare…)
//   - secondary : action secondaire, style contour (Read, Configuration…)
//   - danger    : action destructive uniquement (Delete, Reset…)
// Le vert et le rouge NE sont PAS des couleurs de bouton d'action ici : ils
// restent réservés au statut. Pas de orange.
//
// Exception: `success` / `successOutlined` exist solely to match the Meter
// Connection page's original green Connect/Configuration look (see
// docs/SPECS_UI.md). Do not use them elsewhere without updating that doc.

import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';

enum AppButtonVariant { primary, secondary, danger, success, successOutlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool expand;

  const AppButton.primary(
      {Key? key,
      required String label,
      IconData? icon,
      VoidCallback? onPressed,
      bool loading = false,
      bool expand = false})
      : this(
            key: key,
            label: label,
            icon: icon,
            onPressed: onPressed,
            variant: AppButtonVariant.primary,
            loading: loading,
            expand: expand);

  const AppButton.secondary(
      {Key? key,
      required String label,
      IconData? icon,
      VoidCallback? onPressed,
      bool loading = false,
      bool expand = false})
      : this(
            key: key,
            label: label,
            icon: icon,
            onPressed: onPressed,
            variant: AppButtonVariant.secondary,
            loading: loading,
            expand: expand);

  const AppButton.danger(
      {Key? key,
      required String label,
      IconData? icon,
      VoidCallback? onPressed,
      bool loading = false,
      bool expand = false})
      : this(
            key: key,
            label: label,
            icon: icon,
            onPressed: onPressed,
            variant: AppButtonVariant.danger,
            loading: loading,
            expand: expand);

  const AppButton.success(
      {Key? key,
      required String label,
      IconData? icon,
      VoidCallback? onPressed,
      bool loading = false,
      bool expand = false})
      : this(
            key: key,
            label: label,
            icon: icon,
            onPressed: onPressed,
            variant: AppButtonVariant.success,
            loading: loading,
            expand: expand);

  const AppButton.successOutlined(
      {Key? key,
      required String label,
      IconData? icon,
      VoidCallback? onPressed,
      bool loading = false,
      bool expand = false})
      : this(
            key: key,
            label: label,
            icon: icon,
            onPressed: onPressed,
            variant: AppButtonVariant.successOutlined,
            loading: loading,
            expand: expand);

  @override
  Widget build(BuildContext context) {
    final c = SemanticColors.of(context);
    final disabled = onPressed == null || loading;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
        else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8)
        ],
        Text(label),
      ],
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    late final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              padding: padding,
              shape: shape),
          child: child,
        );
      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
              foregroundColor: c.primary,
              side: BorderSide(color: c.primary),
              padding: padding,
              shape: shape),
          child: child,
        );
      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
              backgroundColor: c.error,
              foregroundColor: Colors.white,
              padding: padding,
              shape: shape),
          child: child,
        );
      case AppButtonVariant.success:
        button = FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
              backgroundColor: c.success,
              foregroundColor: Colors.white,
              padding: padding,
              shape: shape),
          child: child,
        );
      case AppButtonVariant.successOutlined:
        button = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
              foregroundColor: c.success,
              side: BorderSide(color: c.success),
              padding: padding,
              shape: shape),
          child: child,
        );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
