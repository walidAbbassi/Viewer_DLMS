import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../grpc/generated/meter.pb.dart';

/// Holds original/current values and index for an attribute row.
class AttrState {
  AttrState({
    required this.original,
    required this.current,
    required this.index,
  });

  String original;
  String current;
  final int index;
}

/// Simple terminal line entry.
class TermEntry {
  TermEntry(this.tag, this.msg, this.kind);

  final String tag;
  final String msg;
  final String kind;
}

/// Metadata for a selective access object (profil load, etc.).
class SelectiveObj {
  SelectiveObj(this.name, this.logical, this.max, this.num, this.period);

  final String name;
  final String logical;
  final int max;
  final int num;
  final int period;
}

/// Optimized list item widget for better dictionary scrolling performance.
class DictionaryListItem extends StatelessWidget {
  final DatamodelObject object;
  final bool active;
  final VoidCallback onTap;

  const DictionaryListItem({
    super.key,
    required this.object,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: active
            ? (DesignTokens.isDark(context) ? DesignTokens.darkSurfaceAlt : DesignTokens.primary100)
            : DesignTokens.surfaceOf(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              object.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    active ? DesignTokens.primary600 : DesignTokens.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              object.logicalName,
              style: TextStyle(
                fontSize: 11,
                color: DesignTokens.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


