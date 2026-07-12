import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';

/// Shared breadcrumb trail (`Menu > Group > Page`), so pages that show one
/// all look the same instead of each page hand-rolling its own trail style.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.segments});

  final List<String> segments;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Icon(Icons.chevron_right, size: 16, color: colors.onSurfaceVariant),
          Text(
            segments[i],
            style: TextStyle(
              fontSize: 13,
              fontWeight: i == segments.length - 1 ? FontWeight.w600 : FontWeight.w400,
              color: i == segments.length - 1 ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
