import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:math' as math;
import '../../util/profile_status.dart';
import '../../core/theme/design_tokens.dart';

/// Bar chart for Class 7 (Event Log / Profile Generic) data.
///
/// - X-axis : Clock() timestamps extracted from the profile buffer.
/// - Y-axis : A selectable numeric measurement column (kWh, V, A, Wh …).
///
/// The widget auto-detects which column carries the timestamp (by looking for
/// "clock", "time", "date", or "timestamp" in the header name) and lists every
/// other numeric column in the selector dropdown.
class EventLogBarChartWidget extends StatefulWidget {
  final List<String> columns;
  final List<List<String>> data;
  final String? statColumnName;
  final Map<int, Color>? eventColorMap;

  const EventLogBarChartWidget({
    super.key,
    required this.columns,
    required this.data,
    this.statColumnName,
    this.eventColorMap,

  });

  @override
  State<EventLogBarChartWidget> createState() =>
      _EventLogBarChartWidgetState();
}

class _EventLogBarChartWidgetState extends State<EventLogBarChartWidget> {
  int _clockColIdx = -1;
  List<int> _numericColIndices = [];
  int _selectedColIdx = -1;

  // Optional: index of the bar that the user last tapped (for a tooltip).
  int? _hoveredBarIdx;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _detectColumns(widget.columns, widget.data);
  }

  @override
  void didUpdateWidget(EventLogBarChartWidget old) {
    super.didUpdateWidget(old);
    if (old.columns != widget.columns || old.data != widget.data) {
      setState(() {
        _hoveredBarIdx = null;
        _detectColumns(widget.columns, widget.data);
      });
    }
  }

  // ── Column detection ──────────────────────────────────────────────────────

  void _detectColumns(List<String> cols, List<List<String>> rows) {
    // 1. Find the Clock / timestamp column.
    _clockColIdx = -1;
    for (int i = 0; i < cols.length; i++) {
      final lower = cols[i].toLowerCase();
      if (lower.contains('clock') ||
          lower.contains('timestamp') ||
          lower.contains('time') ||
          lower.contains('date')) {
        _clockColIdx = i;
        break;
      }
    }
    if (_clockColIdx < 0 && cols.isNotEmpty) _clockColIdx = 0;

    // 2. Find numeric measurement columns (skip clock & DLMS status bitmask).
    final profileStatusIdx = findProfileStatusColumnIndex(cols);
    final numeric = <int>[];
    for (int i = 0; i < cols.length; i++) {
      if (i == _clockColIdx) continue;
      if (i == profileStatusIdx) continue;
      for (final row in rows.take(20)) {
        if (i < row.length) {
          final clean = row[i].replaceAll(',', '.').trim();
          if (double.tryParse(clean) != null) {
            numeric.add(i);
            break;
          }
        }
      }
    }

    _numericColIndices = numeric;

    if (numeric.isEmpty) {
      _selectedColIdx = -1;
    } else if (numeric.contains(_selectedColIdx)) {
      // keep the previous selection
    } else {
      _selectedColIdx = numeric.first;
    }
  }

  // ── Data building ─────────────────────────────────────────────────────────

  List<_BarPoint> _buildPoints() {
    // Detect the stat (event code) column index for color lookup.
    int statColIdx = -1;
    if (widget.statColumnName != null) {
      statColIdx = widget.columns.indexWhere((h) => h == widget.statColumnName);
      if (statColIdx < 0) {
        statColIdx = widget.columns.indexWhere(
            (h) => h.trim().startsWith(widget.statColumnName!.trim()));
      }
    }

    final result = <_BarPoint>[];
    for (final row in widget.data) {
      if (_clockColIdx < 0 || _clockColIdx >= row.length) continue;
      if (_selectedColIdx < 0 || _selectedColIdx >= row.length) continue;
      final dt = _parseDateTime(row[_clockColIdx]);
      final val =
          double.tryParse(row[_selectedColIdx].replaceAll(',', '.').trim());
      Color? barColor;
      if (statColIdx >= 0 && statColIdx < row.length) {
        final code = int.tryParse(row[statColIdx].trim());
        if (code != null) barColor = widget.eventColorMap?[code];
      }
      if (dt != null && val != null) result.add(_BarPoint(dt, val, color: barColor));
    }
    result.sort((a, b) => a.x.compareTo(b.x));
    return result;
  }

  /// Tries several common DLMS / ISO timestamp formats.
  DateTime? _parseDateTime(String raw) {
    final s = raw.trim();
    final fast = DateTime.tryParse(s);
    if (fast != null) return fast;
    for (final fmt in const [
      'dd/MM/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'dd-MM-yyyy HH:mm:ss',
      'dd.MM.yyyy HH:mm:ss',
    ]) {
      try {
        return DateFormat(fmt).parseStrict(s);
      } catch (_) {}
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final emptyIconColor = isDark ? DesignTokens.gray600 : DesignTokens.gray400;
    final emptyTextColor = isDark ? DesignTokens.darkTextSecondary : DesignTokens.textSecondary;

    if (widget.columns.isEmpty || widget.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: emptyIconColor),
            const SizedBox(height: 16),
            Text(
              'No event data loaded.\n'
              'Load the event log first to see the chart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: emptyTextColor, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_numericColIndices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No numeric measurement columns found in this event log.',
            textAlign: TextAlign.center,
            style: TextStyle(color: emptyTextColor, fontSize: 15),
          ),
        ),
      );
    }

    final points = _buildPoints();
    final colName =
        _selectedColIdx >= 0 ? widget.columns[_selectedColIdx] : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: title + column selector ──────────────────────────
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF1976D2), size: 20),
              const SizedBox(width: 8),
              Text(
                'Event Log Bar Chart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimaryOf(context),
                ),
              ),
              const Spacer(),
              Text(
                'Series:',
                style: TextStyle(fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
              ),
              const SizedBox(width: 8),
              // ── Measurement dropdown ──────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? DesignTokens.darkSurfaceAlt : DesignTokens.primary50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? DesignTokens.darkBorder : const Color(0xFF90CAF9)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedColIdx,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: isDark ? DesignTokens.darkSurface : Colors.white,
                    items: _numericColIndices.map((idx) {
                      return DropdownMenuItem<int>(
                        value: idx,
                        child: Text(widget.columns[idx]),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedColIdx = v;
                          _hoveredBarIdx = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Subtitle ─────────────────────────────────────────────────────
          Text(
            'X-axis: Clock() timestamp  •  Y-axis: $colName'
            '  •  ${points.length} bar${points.length == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 11, color: DesignTokens.textSecondaryOf(context)),
          ),
          const SizedBox(height: 12),
          // ── Chart canvas ─────────────────────────────────────────────────
          Expanded(
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No parseable data for the selected column.',
                      style: TextStyle(color: DesignTokens.textSecondaryOf(context)),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          _handleTap(
                              details.localPosition, constraints.biggest,
                              points);
                        },
                        child: CustomPaint(
                          size: constraints.biggest,
                          painter: _BarChartPainter(
                            points: points,
                            yLabel: colName,
                            hoveredIdx: _hoveredBarIdx,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // ── Tooltip for tapped bar ────────────────────────────────────────
          if (_hoveredBarIdx != null &&
              _hoveredBarIdx! < points.length) ...[
            const SizedBox(height: 8),
            _BarTooltip(
              point: points[_hoveredBarIdx!],
              colName: colName,
              index: _hoveredBarIdx!,
              onDismiss: () => setState(() => _hoveredBarIdx = null),
            ),
          ],
        ],
      ),
    );
  }

  void _handleTap(Offset pos, Size size, List<_BarPoint> points) {
    if (points.isEmpty) return;
    const double lPad = 72.0;
    const double rPad = 20.0;
    const double tPad = 28.0;
    const double bPad = 68.0;
    final cL = lPad;
    final cR = size.width - rPad;
    final cW = cR - cL;
    final cB = size.height - bPad;

    final n = points.length;
    final barSlotW = cW / n;
    final gapRatio = n > 50 ? 0.1 : (n > 20 ? 0.2 : 0.3);
    final barW = barSlotW * (1 - gapRatio);

    for (int i = 0; i < n; i++) {
      final cx = cL + (i + 0.5) * barSlotW;
      final x0 = cx - barW / 2;
      final x1 = cx + barW / 2;
      if (pos.dx >= x0 && pos.dx <= x1 && pos.dy <= cB) {
        setState(() => _hoveredBarIdx = (_hoveredBarIdx == i) ? null : i);
        return;
      }
    }
    // Tapped outside all bars → dismiss tooltip.
    setState(() => _hoveredBarIdx = null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip strip shown when a bar is tapped
// ─────────────────────────────────────────────────────────────────────────────

class _BarTooltip extends StatelessWidget {
  final _BarPoint point;
  final String colName;
  final int index;
  final VoidCallback onDismiss;

  const _BarTooltip({
    required this.point,
    required this.colName,
    required this.index,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('dd/MM/yyyy  HH:mm:ss').format(point.x);
    final valStr = _fmtVal(point.y);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Bar #${index + 1}  •  $ts  •  $colName: $valStr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  static String _fmtVal(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e9) return v.toInt().toString();
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats bar
// ─────────────────────────────────────────────────────────────────────────────

class _BarStatsBar extends StatelessWidget {
  final List<_BarPoint> points;
  final String colName;

  const _BarStatsBar({required this.points, required this.colName});

  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e9) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final values = points.map((p) => p.y).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final avg = values.fold(0.0, (s, v) => s + v) / values.length;
    final isDark = DesignTokens.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurfaceAlt : DesignTokens.primary50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? DesignTokens.darkBorder : const Color(0xFF90CAF9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              label: 'Bars', value: '${points.length}', icon: Icons.bar_chart),
          _StatItem(label: 'Min', value: _fmt(minVal), icon: Icons.south),
          _StatItem(label: 'Max', value: _fmt(maxVal), icon: Icons.north),
          _StatItem(
              label: 'Average', value: _fmt(avg), icon: Icons.show_chart),
          _StatItem(
              label: 'Series', value: colName, icon: Icons.label_outline),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final accentColor = isDark ? DesignTokens.darkFocus : const Color(0xFF1976D2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: accentColor),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: DesignTokens.textSecondaryOf(context)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _BarPoint {
  final DateTime x;
  final double y;
  final Color? color;
  _BarPoint(this.x, this.y, {this.color});
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter – draws the vertical bar chart
// ─────────────────────────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<_BarPoint> points;
  final String yLabel;
  final int? hoveredIdx;
  final bool isDark;

  // Layout constants
  static const double _lPad = 72.0;
  static const double _rPad = 20.0;
  static const double _tPad = 28.0;
  static const double _bPad = 68.0;

  // Palette (aligned with the rest of the app)
  static const Color _barColor      = Color(0xFF1976D2);
  static const Color _barHover      = Color(0xFF0D47A1);
  static const Color _baselineColor = Color(0xFF90CAF9);

  const _BarChartPainter({
    required this.points,
    required this.yLabel,
    this.hoveredIdx,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final cL = _lPad;
    final cR = size.width - _rPad;
    final cT = _tPad;
    final cB = size.height - _bPad;
    final cW = cR - cL;
    final cH = cB - cT;

    if (cW <= 0 || cH <= 0) return;

    // ── Y range ────────────────────────────────────────────────────────────
    final rawYMin = points.map((p) => p.y).reduce(math.min);
    final rawYMax = points.map((p) => p.y).reduce(math.max);
    final ySpan =
        rawYMax == rawYMin ? (rawYMax.abs() * 0.2 + 1.0) : (rawYMax - rawYMin);

    // Ensure the baseline (0) is always included in the Y-axis range.
    final yMin = math.min(rawYMin - ySpan * 0.05, 0.0);
    final yMax = rawYMax + ySpan * 0.15;

    double py(double y) {
      if (yMax == yMin) return cT + cH / 2;
      return cB - (y - yMin) / (yMax - yMin) * cH;
    }

    final baseline = py(0.0).clamp(cT, cB);

    // ── Background (theme-aware) ───────────────────────────────────────────
    final bgColor = isDark ? DesignTokens.darkSurface : Colors.white;
    final gridColor = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final axisColor = isDark ? const Color(0xFF64748B) : const Color(0xFFBDBDBD);
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF757575);
    final titleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF546E7A);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // ── Grid lines + Y labels ──────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.2;

    for (final tick in _niceYTicks(yMin, yMax, 6)) {
      if (tick < yMin - ySpan * 0.02 || tick > yMax + ySpan * 0.02) continue;
      final y = py(tick);
      canvas.drawLine(Offset(cL, y), Offset(cR, y), gridPaint);
      _drawLabel(canvas, _fmtY(tick), Offset(cL - 6, y), right: true, labelColor: labelColor);
    }

    // ── Baseline (y = 0) emphasized ────────────────────────────────────────
    if (baseline > cT && baseline < cB) {
      canvas.drawLine(
        Offset(cL, baseline),
        Offset(cR, baseline),
        Paint()
          ..color = _baselineColor
          ..strokeWidth = 1.6,
      );
    }

    // ── Bars ───────────────────────────────────────────────────────────────
    final n = points.length;
    final barSlotW = cW / n;

    // Gap ratio: fewer bars → wider gap so bars don't look too thick.
    final gapRatio = n > 50 ? 0.1 : (n > 20 ? 0.2 : 0.3);
    final barW = barSlotW * (1 - gapRatio);
    const barRadius = Radius.circular(3);

    for (int i = 0; i < n; i++) {
      final p = points[i];
      final cx = cL + (i + 0.5) * barSlotW;
      final x0 = cx - barW / 2;
      final top = py(p.y);
      final bot = baseline;

      final isHovered = hoveredIdx == i;
      final baseColor = p.color ?? _barColor;
      final fillColor = isHovered ? _darkenColor(baseColor, 0.15) : baseColor;

      // Bar body
      final rect = Rect.fromLTRB(x0, math.min(top, bot),
          x0 + barW, math.max(top, bot));

      if (p.y >= 0) {
        // Positive bar: round only the top corners.
        canvas.drawRRect(
          RRect.fromRectAndCorners(rect,
              topLeft: barRadius, topRight: barRadius),
          Paint()
            ..color = fillColor.withOpacity(isHovered ? 1.0 : 0.82)
            ..style = PaintingStyle.fill,
        );
      } else {
        // Negative bar: round only the bottom corners.
        canvas.drawRRect(
          RRect.fromRectAndCorners(rect,
              bottomLeft: barRadius, bottomRight: barRadius),
          Paint()
            ..color = fillColor.withOpacity(isHovered ? 1.0 : 0.82)
            ..style = PaintingStyle.fill,
        );
      }

      // Highlight ring on hover
      if (isHovered) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            rect.inflate(1.5),
            topLeft: barRadius,
            topRight: barRadius,
            bottomLeft: barRadius,
            bottomRight: barRadius,
          ),
          Paint()
            ..color = _darkenColor(p.color ?? _barColor, 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }

    // ── X-axis tick marks + labels ─────────────────────────────────────────
    final ticks = _pickXTicks(points, 8);
    // Build a reverse lookup: point → index in points list.
    final tickIdxMap = <_BarPoint, int>{};
    for (int i = 0; i < points.length; i++) {
      tickIdxMap[points[i]] = i;
    }

    for (final tick in ticks) {
      final i = tickIdxMap[tick] ?? 0;
      final cx = cL + (i + 0.5) * barSlotW;
      canvas.drawLine(Offset(cx, cB), Offset(cx, cB + 5), axisPaint);
      _drawRotated(
        canvas,
        _fmtX(tick.x, points.first.x, points.last.x),
        Offset(cx, cB + 10),
        -math.pi / 4,
        TextStyle(fontSize: 10, color: labelColor),
      );
    }

    // ── Axis lines ─────────────────────────────────────────────────────────
    canvas.drawLine(Offset(cL, cT), Offset(cL, cB), axisPaint);
    canvas.drawLine(Offset(cL, cB), Offset(cR, cB), axisPaint);

    // ── Y-axis title (rotated 90°) ─────────────────────────────────────────
    _drawRotated(
      canvas,
      yLabel,
      Offset(13, cT + cH / 2),
      -math.pi / 2,
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
    );
  }
  static Color _darkenColor(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
  // ── Drawing helpers ────────────────────────────────────────────────────────

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    bool right = false,
    Color labelColor = const Color(0xFF757575),
    TextStyle? style,
  }) {
    style ??= TextStyle(fontSize: 10, color: labelColor);
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: right ? TextAlign.right : TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _lPad - 2);
    final dx = right ? pos.dx - tp.width : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  void _drawRotated(
    Canvas canvas,
    String text,
    Offset pivot,
    double angle,
    TextStyle style,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 180);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  // ── Tick helpers ───────────────────────────────────────────────────────────

  List<double> _niceYTicks(double lo, double hi, int n) {
    if ((hi - lo).abs() < 1e-10) {
      final spread = math.max(lo.abs() * 0.1, 1.0);
      return _niceYTicks(lo - spread, hi + spread, n);
    }
    final step = _niceStep((hi - lo) / (n - 1));
    final start = (lo / step).floor() * step;
    final ticks = <double>[];
    var t = start;
    while (t <= hi + step * 0.5) {
      if (t >= lo - step * 0.5) ticks.add(t);
      t += step;
    }
    return ticks;
  }

  double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final exp = (math.log(raw) / math.ln10).floor();
    final mag = math.pow(10, exp).toDouble();
    final norm = raw / mag;
    if (norm <= 1.0) return mag;
    if (norm <= 2.0) return 2 * mag;
    if (norm <= 5.0) return 5 * mag;
    return 10 * mag;
  }

  List<_BarPoint> _pickXTicks(List<_BarPoint> pts, int maxTicks) {
    if (pts.length <= maxTicks) return pts;
    final step = (pts.length / maxTicks).ceil();
    return [for (int i = 0; i < pts.length; i += step) pts[i]];
  }

  // ── Formatters ─────────────────────────────────────────────────────────────

  String _fmtY(double v) {
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}k';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _fmtX(DateTime dt, DateTime xFirst, DateTime xLast) {
    final rangeDays = xLast.difference(xFirst).inMilliseconds / 86400000.0;
    if (rangeDays > 365) return DateFormat('MM/yy').format(dt);
    if (rangeDays > 30) return DateFormat('dd/MM').format(dt);
    if (rangeDays > 1) return DateFormat('dd/MM HH:mm').format(dt);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.points != points ||
      old.yLabel != yLabel ||
      old.hoveredIdx != hoveredIdx ||
      old.isDark != isDark;
}
