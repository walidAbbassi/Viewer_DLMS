import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/theme/design_tokens.dart';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> values;

  /// Viewport height so vertical scrolling can happen
  final double height;

  /// Min/max column width clamps. When content exceeds maxColWidth, it wraps.
  final double minColWidth;
  final double maxColWidth;

  /// Padding inside each cell (used in width calc too)
  final EdgeInsets cellPadding;

  /// If true, we attempt to break very long “unbreakable” tokens by inserting zero-width spaces.
  final bool breakLongWords;

  const CustomTable({
    super.key,
    required this.headers,
    required this.values,
    this.height = 360,
    this.minColWidth = 80,
    this.maxColWidth = 360,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.breakLongWords = true,
  });

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    final cellStyle = DefaultTextStyle.of(context).style;

    final widths = _computeColumnWidths(
      context: context,
      headers: headers,
      values: values,
      headerStyle: headerStyle,
      cellStyle: cellStyle,
      padding: cellPadding,
      minW: minColWidth,
      maxW: maxColWidth,
    );

    final columnWidths = <int, TableColumnWidth>{
      for (int i = 0; i < widths.length; i++) i: FixedColumnWidth(widths[i]),
    };

    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? DesignTokens.darkBorder   : const Color(0xFFE0E0E0);
    final headerBg    = isDark ? const Color(0xFF1E3A5F)   : const Color(0xFFDCEEFB);
    final headerText  = isDark ? DesignTokens.darkFocus    : DesignTokens.primary600;
    final evenRowBg   = isDark ? const Color(0xFF1E293B)   : Colors.white;
    final oddRowBg    = isDark ? const Color(0xFF16202E)   : const Color(0xFFF8FAFC);
    final cellText    = isDark ? DesignTokens.darkTextPrimary : DesignTokens.textPrimary;

    final styledHeaderStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: headerText,
    );
    final styledCellStyle = TextStyle(
      fontSize: 13,
      color: cellText,
    );

    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: borderColor, width: 1),
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: headerBg),
              children: [
                for (int c = 0; c < headers.length; c++)
                  Padding(
                    padding: cellPadding,
                    child: SizedBox(
                      width: widths[c],
                      child: Text(
                        headers[c],
                        style: styledHeaderStyle,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
              ],
            ),
            // Data rows — alternating background
            for (int r = 0; r < values.length; r++)
              TableRow(
                decoration: BoxDecoration(
                  color: r.isEven ? evenRowBg : oddRowBg,
                ),
                children: [
                  for (int c = 0; c < headers.length; c++)
                    Padding(
                      padding: cellPadding,
                      child: SizedBox(
                        width: widths[c],
                        child: Text(
                          _maybeBreak(values[r].length > c ? values[r][c] : ''),
                          style: styledCellStyle,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<double> _computeColumnWidths({
    required BuildContext context,
    required List<String> headers,
    required List<List<String>> values,
    required TextStyle headerStyle,
    required TextStyle cellStyle,
    required EdgeInsets padding,
    required double minW,
    required double maxW,
  }) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final colCount = headers.length;
    final maxByCol = List<double>.filled(colCount, 0);

    double measure(String text, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaleFactor: textScale,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return tp.size.width;
    }

    // Start with header widths
    for (int c = 0; c < colCount; c++) {
      maxByCol[c] = measure(headers[c], headerStyle);
    }

    // Measure cells (single-line width); we'll clamp to maxColWidth so long text wraps
    for (final row in values) {
      for (int c = 0; c < colCount && c < row.length; c++) {
        final w = measure(row[c], cellStyle);
        if (w > maxByCol[c]) maxByCol[c] = w;
      }
    }

    final horizontalPad = padding.left + padding.right;

    // Add padding and clamp. If wider than maxW, the text will wrap inside that width.
    return maxByCol
        .map((w) => (w + horizontalPad).clamp(minW, maxW).toDouble())
        .toList();
  }

  /// Inserts zero-width spaces into very long unbreakable tokens,
  /// so they can wrap even without spaces/hyphens.
  String _maybeBreak(String s) {
    if (!breakLongWords) return s;
    // If there are spaces or hyphens, wrapping is fine already.
    if (s.contains(' ') || s.contains('-')) return s;

    // Break tokens longer than 24 chars by inserting ZWSP every 8 chars.
    if (s.length < 24) return s;
    const zwsp = '\u200B';
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      if ((i + 1) % 8 == 0) buffer.write(zwsp);
    }
    return buffer.toString();
  }
}
