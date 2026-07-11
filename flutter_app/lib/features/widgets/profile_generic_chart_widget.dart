import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:math' as math;
import '../../util/profile_status.dart';
import '../../core/theme/design_tokens.dart';

/// Time-series chart for Class 7 (Profile Generic) data.
///
/// By default **all** numeric series are drawn simultaneously, each with its
/// own colour.  The dropdown lets the user filter to a single series.
class ProfileGenericChartWidget extends StatefulWidget {
  final List<String> columns;
  final List<List<String>> data;

  const ProfileGenericChartWidget({
    super.key,
    required this.columns,
    required this.data,
  });

  @override
  State<ProfileGenericChartWidget> createState() =>
      _ProfileGenericChartWidgetState();
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Colour palette for multi-series
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const List<Color> _kSeriesColors = [
  Color(0xFF1976D2), // blue
  Color(0xFFE53935), // red
  Color(0xFF43A047), // green
  Color(0xFFFB8C00), // orange
  Color(0xFF8E24AA), // purple
  Color(0xFF00ACC1), // cyan
  Color(0xFFFFB300), // amber
  Color(0xFF6D4C41), // brown
  Color(0xFF546E7A), // blue-grey
  Color(0xFFEC407A), // pink
];

Color _seriesColor(int index) => _kSeriesColors[index % _kSeriesColors.length];

/// Sentinel value meaning "show all series".
const int _kAllSeries = -1;

class _ProfileGenericChartWidgetState
    extends State<ProfileGenericChartWidget> {
  int _clockColIdx = -1;
  List<int> _numericColIndices = [];

  /// Currently selected column index, or [_kAllSeries] to show all.
  int _selectedColIdx = _kAllSeries;

  // â”€â”€ Lifecycle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  void initState() {
    super.initState();
    _detectColumns(widget.columns, widget.data);
  }

  @override
  void didUpdateWidget(ProfileGenericChartWidget old) {
    super.didUpdateWidget(old);
    if (old.columns != widget.columns || old.data != widget.data) {
      setState(() => _detectColumns(widget.columns, widget.data));
    }
  }

  // â”€â”€ Column detection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _detectColumns(List<String> cols, List<List<String>> rows) {
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

    // Reset to "all series" whenever data changes; keep single selection only
    // if the previously-chosen column is still available.
    if (_selectedColIdx != _kAllSeries &&
        !numeric.contains(_selectedColIdx)) {
      _selectedColIdx = _kAllSeries;
    }
  }

  // â”€â”€ Data building â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Returns the indices that should be drawn given current selection.
  List<int> get _visibleIndices => _selectedColIdx == _kAllSeries
      ? _numericColIndices
      : [_selectedColIdx];

  List<_ChartPoint> _buildPoints(int colIdx) {
    final result = <_ChartPoint>[];
    for (final row in widget.data) {
      if (_clockColIdx < 0 || _clockColIdx >= row.length) continue;
      if (colIdx >= row.length) continue;
      final dt = _parseDateTime(row[_clockColIdx]);
      final val =
          double.tryParse(row[colIdx].replaceAll(',', '.').trim());
      if (dt != null && val != null) result.add(_ChartPoint(dt, val));
    }
    result.sort((a, b) => a.x.compareTo(b.x));
    return result;
  }

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

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final textPrimary = DesignTokens.textPrimaryOf(context);
    final textSecondary = DesignTokens.textSecondaryOf(context);
    final accent = isDark ? Colors.white : const Color(0xFF1976D2);

    if (widget.columns.isEmpty || widget.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, size: 64, color: textSecondary),
            const SizedBox(height: 16),
            Text(
              'No profile data loaded.\n'
              'Load the profile first to see the chart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 15),
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
            'No numeric measurement columns found in this profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 15),
          ),
        ),
      );
    }

    // Build series data for all visible columns.
    final seriesData = <int, List<_ChartPoint>>{};
    for (final idx in _visibleIndices) {
      final pts = _buildPoints(idx);
      if (pts.isNotEmpty) seriesData[idx] = pts;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Header: title + dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            children: [
              Icon(Icons.show_chart, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Time-Series Chart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Filter:',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.darkSurfaceAlt
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isDark
                          ? DesignTokens.borderOf(context)
                          : const Color(0xFF90CAF9)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedColIdx,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: DesignTokens.surfaceOf(context),
                    items: [
                      // "All series" option
                      const DropdownMenuItem<int>(
                        value: _kAllSeries,
                        child: Text('All series'),
                      ),
                      // Individual series
                      ..._numericColIndices.asMap().entries.map((e) {
                        final colorDot = _seriesColor(e.key);
                        return DropdownMenuItem<int>(
                          value: e.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colorDot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(widget.columns[e.value]),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedColIdx = v);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // â”€â”€ Subtitle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Text(
            _selectedColIdx == _kAllSeries
                ? 'Showing ${_visibleIndices.length} series  â€¢  X: Clock timestamp'
                : 'X: Clock timestamp  â€¢  Y: ${widget.columns[_selectedColIdx]}',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
          const SizedBox(height: 6),
          // â”€â”€ Legend (all-series mode) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_selectedColIdx == _kAllSeries &&
              _numericColIndices.length > 1) ...[
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: _numericColIndices.asMap().entries.map((e) {
                final color = _seriesColor(e.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.columns[e.value],
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
          ],
          // â”€â”€ Chart canvas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: seriesData.isEmpty
                ? Center(
                    child: Text(
                      'No parseable data for the selected column.',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                : SizedBox.expand(
                    child: CustomPaint(
                      painter: _ChartPainter(
                        seriesData: seriesData,
                        columnNames: {
                          for (final idx in _visibleIndices)
                            idx: widget.columns[idx]
                        },
                        numericIndices: _numericColIndices,
                        isDark: isDark,
                      ),
                    ),
                  ),
          ),
          // â”€â”€ Stats bar (single-series mode only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_selectedColIdx != _kAllSeries &&
              seriesData.containsKey(_selectedColIdx)) ...[
            const SizedBox(height: 12),
            _StatsBar(
              points: seriesData[_selectedColIdx]!,
              colName: widget.columns[_selectedColIdx],
            ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Stats bar (single series)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StatsBar extends StatelessWidget {
  final List<_ChartPoint> points;
  final String colName;

  const _StatsBar({required this.points, required this.colName});

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
        color: isDark
            ? DesignTokens.darkSurfaceAlt
            : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark
                ? DesignTokens.borderOf(context)
                : const Color(0xFF90CAF9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              label: 'Points',
              value: '${points.length}',
              icon: Icons.data_array),
          _StatItem(
              label: 'Min', value: _fmt(minVal), icon: Icons.south),
          _StatItem(
              label: 'Max', value: _fmt(maxVal), icon: Icons.north),
          _StatItem(
              label: 'Average', value: _fmt(avg), icon: Icons.show_chart),
          _StatItem(
              label: 'Series',
              value: colName,
              icon: Icons.label_outline),
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
    final accent = isDark ? Colors.white : const Color(0xFF1976D2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: accent),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 10, color: DesignTokens.textSecondaryOf(context)),
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Data model
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ChartPoint {
  final DateTime x;
  final double y;
  _ChartPoint(this.x, this.y);
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// CustomPainter â€“ draws one or more time-series
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ChartPainter extends CustomPainter {
  /// Map from column index â†’ list of points for that series.
  final Map<int, List<_ChartPoint>> seriesData;

  /// Map from column index â†’ display name.
  final Map<int, String> columnNames;

  /// Ordered list of numeric indices (used to assign stable colour indices).
  final List<int> numericIndices;

  /// Dark-mode flag controlling grid/axis/label/background colours.
  final bool isDark;

  static const double _lPad = 72.0;
  static const double _rPad = 20.0;
  static const double _tPad = 28.0;
  static const double _bPad = 68.0;

  static const Color _gridColorLight  = Color(0xFFE8EDF2);
  static const Color _axisColorLight  = Color(0xFFBDBDBD);
  static const Color _labelColorLight = Color(0xFF757575);
  static const Color _titleColorLight = Color(0xFF546E7A);
  static const Color _gridColorDark   = Color(0xFF334155);
  static const Color _axisColorDark   = Color(0xFF64748B);
  static const Color _labelColorDark  = Color(0xFFCBD5E1);
  static const Color _titleColorDark  = Color(0xFFF1F5F9);
  static const Color _bgLight         = Colors.white;
  static const Color _bgDark          = Color(0xFF0F172A);

  Color get _gridColor  => isDark ? _gridColorDark  : _gridColorLight;
  Color get _axisColor  => isDark ? _axisColorDark  : _axisColorLight;
  Color get _labelColor => isDark ? _labelColorDark : _labelColorLight;
  Color get _titleColor => isDark ? _titleColorDark : _titleColorLight;
  Color get _bgColor    => isDark ? _bgDark         : _bgLight;
  Color get _dotBorderColor => isDark ? _bgDark     : Colors.white;

  _ChartPainter({
    required this.seriesData,
    required this.columnNames,
    required this.numericIndices,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (seriesData.isEmpty) return;

    final cL = _lPad;
    final cR = size.width - _rPad;
    final cT = _tPad;
    final cB = size.height - _bPad;
    final cW = cR - cL;
    final cH = cB - cT;
    if (cW <= 0 || cH <= 0) return;

    // â”€â”€ Global X / Y range across all visible series â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    double xMin = double.infinity, xMax = double.negativeInfinity;
    double rawYMin = double.infinity, rawYMax = double.negativeInfinity;

    for (final pts in seriesData.values) {
      for (final p in pts) {
        final ms = p.x.millisecondsSinceEpoch.toDouble();
        if (ms < xMin) xMin = ms;
        if (ms > xMax) xMax = ms;
        if (p.y < rawYMin) rawYMin = p.y;
        if (p.y > rawYMax) rawYMax = p.y;
      }
    }
    if (xMin == double.infinity) return;

    final ySpan = rawYMax == rawYMin
        ? (rawYMax.abs() * 0.2 + 1.0)
        : (rawYMax - rawYMin);
    final yMin = rawYMin - ySpan * 0.08;
    final yMax = rawYMax + ySpan * 0.15;

    // â”€â”€ Coordinate helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    double px(double xMs) {
      if (xMax == xMin) return cL + cW / 2;
      return cL + (xMs - xMin) / (xMax - xMin) * cW;
    }

    double py(double y) {
      if (yMax == yMin) return cT + cH / 2;
      return cB - (y - yMin) / (yMax - yMin) * cH;
    }

    // â”€â”€ Background (adaptive) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bgColor,
    );

    // â”€â”€ Grid + Y labels â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final gridPaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 1.0;
    final axisPaint = Paint()
      ..color = _axisColor
      ..strokeWidth = 1.2;

    for (final tick in _niceYTicks(yMin, yMax, 6)) {
      if (tick < yMin - ySpan * 0.02 || tick > yMax + ySpan * 0.02) continue;
      final y = py(tick);
      canvas.drawLine(Offset(cL, y), Offset(cR, y), gridPaint);
      _drawLabel(canvas, _fmtY(tick), Offset(cL - 6, y), right: true);
    }

    // â”€â”€ X ticks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final allPoints = seriesData.values.expand((p) => p).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    for (final tick in _pickXTicks(allPoints, 7)) {
      final x = px(tick.x.millisecondsSinceEpoch.toDouble());
      canvas.drawLine(Offset(x, cB), Offset(x, cB + 5), axisPaint);
      _drawRotated(
        canvas,
        _fmtX(tick.x, xMin, xMax),
        Offset(x, cB + 10),
        -math.pi / 4,
        TextStyle(fontSize: 10, color: _labelColor),
      );
    }

    // â”€â”€ Axis lines â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    canvas.drawLine(Offset(cL, cT), Offset(cL, cB), axisPaint);
    canvas.drawLine(Offset(cL, cB), Offset(cR, cB), axisPaint);

    // â”€â”€ Draw each series â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final isSingle = seriesData.length == 1;

    for (final entry in seriesData.entries) {
      final colIdx = entry.key;
      final pts = entry.value;
      if (pts.isEmpty) continue;

      final colorIdx = numericIndices.indexOf(colIdx);
      final color = _seriesColor(colorIdx < 0 ? 0 : colorIdx);
      final alpha20 = Color.fromARGB(
          (color.alpha * 0.2).round(), color.red, color.green, color.blue);
      final alpha02 = Color.fromARGB(
          (color.alpha * 0.04).round(), color.red, color.green, color.blue);

      // Area fill â€” only for single series to avoid visual clutter
      if (isSingle && pts.length > 1) {
        final fillPath = Path()
          ..moveTo(px(pts.first.x.millisecondsSinceEpoch.toDouble()), cB);
        for (final p in pts) {
          fillPath.lineTo(px(p.x.millisecondsSinceEpoch.toDouble()), py(p.y));
        }
        fillPath
          ..lineTo(px(pts.last.x.millisecondsSinceEpoch.toDouble()), cB)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [alpha20, alpha02],
            ).createShader(Rect.fromLTRB(cL, cT, cR, cB)),
        );
      }

      // Line
      if (pts.length > 1) {
        final linePath = Path()
          ..moveTo(
            px(pts.first.x.millisecondsSinceEpoch.toDouble()),
            py(pts.first.y),
          );
        for (int i = 1; i < pts.length; i++) {
          linePath.lineTo(
            px(pts[i].x.millisecondsSinceEpoch.toDouble()),
            py(pts[i].y),
          );
        }
        canvas.drawPath(
          linePath,
          Paint()
            ..color = color
            ..strokeWidth = isSingle ? 2.0 : 1.8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        );
      }

      // Dots (only when few points)
      if (pts.length <= 60) {
        final dotFill = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final dotBorder = Paint()
          ..color = _dotBorderColor
          ..style = PaintingStyle.fill;
        for (final p in pts) {
          final dx = px(p.x.millisecondsSinceEpoch.toDouble());
          final dy = py(p.y);
          canvas.drawCircle(Offset(dx, dy), 4.5, dotBorder);
          canvas.drawCircle(Offset(dx, dy), 3.0, dotFill);
        }
      }
    }

    // â”€â”€ Y-axis title (only single series) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (isSingle) {
      final label = columnNames.values.first;
      _drawRotated(
        canvas,
        label,
        Offset(13, cT + cH / 2),
        -math.pi / 2,
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _titleColor,
        ),
      );
    }
  }

  // â”€â”€ Drawing helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    bool right = false,
    TextStyle? style,
  }) {
    final effectiveStyle =
        style ?? TextStyle(fontSize: 10, color: _labelColor);
    final tp = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
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

  // â”€â”€ Tick calculators â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<double> _niceYTicks(double lo, double hi, int n) {
    if (hi - lo < 1e-10) {
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

  List<_ChartPoint> _pickXTicks(List<_ChartPoint> pts, int maxTicks) {
    if (pts.length <= maxTicks) return pts;
    final step = (pts.length / maxTicks).ceil();
    return [for (int i = 0; i < pts.length; i += step) pts[i]];
  }

  String _fmtY(double v) {
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}k';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _fmtX(DateTime dt, double xMin, double xMax) {
    final rangeDays = (xMax - xMin) / 86400000.0;
    if (rangeDays > 365) return DateFormat('MM/yy').format(dt);
    if (rangeDays > 30)  return DateFormat('dd/MM').format(dt);
    if (rangeDays > 1)   return DateFormat('dd/MM HH:mm').format(dt);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.seriesData != seriesData ||
      old.columnNames != columnNames ||
      old.isDark != isDark;
}
