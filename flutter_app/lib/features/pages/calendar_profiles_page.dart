import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../util/grpc_error.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../state/app_controller.dart';
import '../../state/app_state.dart';
import '../../state/calendar_state_provider.dart';
import 'package:grpc/grpc.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../core/widget_keys.dart';
import 'package:flutter/services.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/breadcrumb.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

/// Activity Calendar page – Active / Passive calendars, Special Days,
/// Day / Week / Season profile editors, all backed by real gRPC calls.
class CalendarProfilesPage extends ConsumerStatefulWidget {
  const CalendarProfilesPage({super.key});

  @override
  ConsumerState<CalendarProfilesPage> createState() =>
      _CalendarProfilesPageState();
}

class _CalendarProfilesPageState extends ConsumerState<CalendarProfilesPage>
    with TickerProviderStateMixin {
  // ── tab controllers ──────────────────────────────────────────────────────
  late TabController _outerTab; // Active | Passive | Special Days
  late TabController
      _innerActive; // Day Profile | Week | Season (Active, read-only)
  late TabController _innerPassive; // Day | Week | Season (Passive, editable)

  // ── gRPC data ─────────────────────────────────────────────────────────────
  ActivityCalendarData? _activeCalendar;
  ActivityCalendarData? _passiveCalendar;
  SpecialDayTable _specialDays = SpecialDayTable();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _loading = false;
  bool _isConnected = false;
  String? _calendarError;
  String? _specialDaysError;

  // Calendar grid
  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate; // day tapped in the grid
  bool _showYearlyOverview =
      true; // true = 12-month overview, false = single month
  bool _showPassiveYearlyOverview = true; // same for Passive tab

  // Passive editing state
  CalendarDayProfile? _editingDayProfile;
  CalendarWeekProfile? _editingWeekProfile;
  CalendarSeasonProfile? _editingSeason;

  // Special Day form state
  int _spFormYear = DateTime.now().year;
  int _spFormMonth = 1;
  int _spFormDay = 1;
  int _spFormWeekDay = 1; // 1 = Mon … 7 = Sun (DLMS dayOfWeek)
  int _spFormProfile = 1;
  int? _spSelectedIndex; // index of the selected row in the holidays table

  // Passive calendar – spec conformance tracking
  bool _passiveReadFromMeter =
      false; // true after a fresh read from the meter in this session
  bool _passiveCalendarDirty =
      false; // true when local UI edits have not yet been written to the meter

  // Local profile names (not in protobuf, stored in-session)
  final Map<int, String> _dayProfileNames = {};

  // Form controllers
  final _nameCtrl = TextEditingController(); // week profile name
  final _seasonNameCtrl = TextEditingController(); // season profile name

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _outerTab = TabController(length: 3, vsync: this);
    _innerActive = TabController(length: 3, vsync: this);
    _innerPassive = TabController(length: 3, vsync: this);

    // Restore last-known state so the page is immediately usable even when
    // disconnected, or after a navigate-away / reconnect cycle.
    final cache = ref.read(calendarCacheProvider);
    if (cache.activeCalendar != null) {
      _activeCalendar = cache.activeCalendar;
      _normalizeSeasonYears(_activeCalendar);
    }
    if (cache.passiveCalendar != null) {
      _passiveCalendar = cache.passiveCalendar;
      _normalizeSeasonYears(_passiveCalendar);
    }

    // Only fetch from the meter if the session is already open.
    // If disconnected the cached data above is enough; _loadAll will be
    // triggered automatically when the session reconnects (see ref.listen).
    if (ref.read(appControllerProvider).isConnected) _loadAll();
  }

  @override
  void dispose() {
    _outerTab.dispose();
    _innerActive.dispose();
    _innerPassive.dispose();
    _nameCtrl.dispose();
    _seasonNameCtrl.dispose();
    _client.close();
    super.dispose();
  }

  // ── data loading ──────────────────────────────────────────────────────────

  late IMeterClient _client;

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      // Only show the full blocking spinner when there is nothing to display yet.
      // When the cache already has data, the refresh is silent (no spinner).
      if (_activeCalendar == null && _passiveCalendar == null) _loading = true;
      _calendarError = null;
      _specialDaysError = null;
    });

    // Run the three RPCs independently so a failure in one doesn't blank the others.
    ActivityCalendarData? newActive;
    ActivityCalendarData? newPassive;
    SpecialDayTable? newSpecialDays;
    String? calErr;
    String? sdErr;

    // The passive calendar is the user's local workspace (like the legacy
    // viewer). Only read it from the meter on the very first load (when we
    // have no local data). On reconnect we keep the in-memory/disk copy so
    // local edits (renamed profiles, new slots …) are never overwritten by
    // a fresh meter read.
    // Passive calendar is always read from the meter on the first connection.
    // On reconnection, preserve local edits (disk/memory cache is kept).
    final hasLocalPassive = _passiveReadFromMeter;

    // Run RPCs sequentially to avoid concurrent serial port access.
    try {
      newActive = await _client.getActiveCalendar();
    } catch (e) {
      calErr = extractGrpcMessage(e);
    }
    if (mounted) {
      try {
        newSpecialDays = await _client.getSpecialDays();
      } catch (e) {
        sdErr = extractGrpcMessage(e);
      }
    }
    if (mounted && !hasLocalPassive) {
      try {
        newPassive = await _client.getPassiveCalendar();
      } catch (e) {
        calErr ??= extractGrpcMessage(e);
      }
    }

    if (!mounted) return;
    setState(() {
      if (newActive != null) {
        _activeCalendar = newActive;
        _normalizeSeasonYears(_activeCalendar);
      }
      if (newPassive != null) {
        _passiveCalendar = newPassive;
        _normalizeSeasonYears(_passiveCalendar);
        _passiveReadFromMeter = true;
        _passiveCalendarDirty = false;
      }
      if (newSpecialDays != null) {
        _specialDays = newSpecialDays!;
        // Clear the selection so the index cannot point to a stale entry.
        _spSelectedIndex = null;
      }
      _calendarError = calErr;
      _specialDaysError = sdErr;
      _loading = false;
    });

    // Persist fresh data to the in-memory cache so it survives disconnection
    // and page navigation without needing another meter read.
    // NOTE: passive calendar is only persisted on explicit user writes/edits,
    // not on meter reads, to avoid overwriting local changes.
    ref.read(calendarCacheProvider.notifier).update(
          activeCalendar: newActive,
          // Pass passive only if we actually read it (first load only).
          passiveCalendar: newPassive,
        );
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  /// Replaces the DLMS "not specified" year value (65535) with the current
  /// year in all season start dates so they never display as '****'.
  void _normalizeSeasonYears(ActivityCalendarData? cal) {
    if (cal == null) return;
    final now = DateTime.now().year;
    for (final s in cal.seasonProfiles) {
      if (s.seasonStart.year == 65535) s.seasonStart.year = now;
    }
  }

  String _fmtTime(CalendarTimeValue? t) {
    if (t == null) return '--:--:--';
    final h = t.hour == 255 ? '**' : t.hour.toString().padLeft(2, '0');
    final m = t.minute == 255 ? '**' : t.minute.toString().padLeft(2, '0');
    final s = t.second == 255 ? '**' : t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Strips null bytes / non-printable characters then keeps only the last word.
  String _cleanName(String raw) {
    final clean = raw.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
    if (clean.isEmpty) return '--';
    return clean.split(RegExp(r'\s+')).last;
  }

  String _fmtDate(CalendarDateValue? d) {
    if (d == null) return '----/--/--';
    final y = d.year == 65535 ? '****' : d.year.toString();
    final mo = d.month.toString().padLeft(2, '0');
    final day = d.dayOfMonth.toString().padLeft(2, '0');
    return '$y/$mo/$day';
  }

  String _dayName(int dow) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (dow >= 1 && dow <= 7) ? days[dow] : '--';
  }

  Color _seasonColor(int idx) {
    const palette = [
      Color(0xFF42A5F5),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFFFF7043),
      Color(0xFF66BB6A),
    ];
    return palette[idx % palette.length];
  }

  // Find season active for a given date, using passiveCalendar season list
  CalendarSeasonProfile? _findSeason(DateTime date, ActivityCalendarData? cal) {
    if (cal == null || cal.seasonProfiles.isEmpty) return null;
    // Sort by start date ascending
    final sorted = List<CalendarSeasonProfile>.from(cal.seasonProfiles)
      ..sort((a, b) {
        final ad = DateTime(
            a.seasonStart.year, a.seasonStart.month, a.seasonStart.dayOfMonth);
        final bd = DateTime(
            b.seasonStart.year, b.seasonStart.month, b.seasonStart.dayOfMonth);
        return ad.compareTo(bd);
      });
    CalendarSeasonProfile? active;
    for (final s in sorted) {
      final start = DateTime(
          s.seasonStart.year, s.seasonStart.month, s.seasonStart.dayOfMonth);
      if (!date.isBefore(start)) active = s;
    }
    return active;
  }

  bool _isSameDay(CalendarDateValue d, DateTime date) {
    return d.year == date.year &&
        d.month == date.month &&
        d.dayOfMonth == date.day;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(appControllerProvider).isConnected;
    _isConnected = isConnected;

    // Reload from the meter whenever the session reconnects while this page
    // is open.  The refresh is silent if we already have cached data.
    ref.listen<AppState>(appControllerProvider, (prev, next) {
      if (prev?.isConnected == false && next.isConnected == true) {
        _loadAll();
      }
    });

    final sc = SemanticColors.of(context);
    return Scaffold(
      backgroundColor: sc.background,
      appBar: AppBar(
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity Calendars',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          RefreshAppBarButton(onPressed: _loadAll),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _outerTab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
                icon: Icon(Icons.lock_clock, size: 18),
                text: 'Active Calendar'),
            Tab(
                icon: Icon(Icons.edit_calendar, size: 18),
                text: 'Passive Calendar'),
            Tab(icon: Icon(Icons.star, size: 18), text: 'Special Days'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const Breadcrumb(
                segments: ['Menu', 'Tariff Management', 'Activity Calendars']),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _outerTab,
                    children: [
                      _buildActiveCalendarTab(),
                      _buildPassiveCalendarTab(),
                      _buildSpecialDaysTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── error banner ──────────────────────────────────────────────────────────

  Widget _buildErrorBanner(String message, VoidCallback onRetry) {
    final sc = SemanticColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: sc.error, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: sc.error),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1 – Active Calendar (read-only)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveCalendarTab() {
    final sc = SemanticColors.of(context);
    if (_calendarError != null)
      return _buildErrorBanner(_calendarError!, _loadAll);
    final cal = _activeCalendar;
    final targetDay = _selectedDate ?? DateTime.now();

    return Column(
      children: [
        // ── Top row: calendar grid left  |  profile panels right ──────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT: yearly overview or monthly calendar grid ─────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: _showYearlyOverview
                      ? Column(
                          children: [
                            _calendarHeader(cal),
                            const SizedBox(height: 10),
                            _buildYearlyNavRow(),
                            const SizedBox(height: 8),
                            Expanded(
                                child: _buildYearlyOverview(cal, _specialDays,
                                    onSelect: () =>
                                        _showYearlyOverview = false)),
                            const SizedBox(height: 8),
                            _calendarLegend(cal),
                          ],
                        )
                      : Column(
                          children: [
                            // ← Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                key: const Key(CalendarProfilesKeys.activeBackAllMonthsBtn),
                                onPressed: () =>
                                    setState(() => _showYearlyOverview = true),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('All months'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : sc.primary,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _calendarHeader(cal),
                            const SizedBox(height: 10),
                            _calendarNavRow(),
                            const SizedBox(height: 8),
                            Expanded(
                                child: _buildCalendarGrid(cal, _specialDays)),
                            const SizedBox(height: 8),
                            _calendarLegend(cal),
                          ],
                        ),
                ),
              ),
              const VerticalDivider(width: 1),
              // ── RIGHT: same profile panels as Passive, but read-only ──
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    TabBar(
                      controller: _innerActive,
                      labelColor:
                          sc.primary,
                      indicatorColor:
                          sc.primary,
                      unselectedLabelColor:
                          sc.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Day Profiles'),
                        Tab(text: 'Week Profiles'),
                        Tab(text: 'Season Profiles'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _innerActive,
                        children: [
                          _buildDayProfilesView(cal, readOnly: true),
                          _buildWeekProfilesView(cal, readOnly: true),
                          _buildSeasonProfilesView(cal, readOnly: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // ── Bottom: Calendar Status bar ───────────────────────────────────
        _buildCalendarStatusBar(cal, targetDay),
      ],
    );
  }

  // ── Calendar header ───────────────────────────────────────────────────────

  Widget _calendarHeader(ActivityCalendarData? cal) {
    final sc = SemanticColors.of(context);
    return Row(
      children: [
        Icon(Icons.event, color: sc.info),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            cal != null
                ? 'Active: "${_cleanName(cal.calendarName)}"'
                : 'Active Calendar',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  // ── Month / year navigation ───────────────────────────────────────────────

  Widget _calendarNavRow() {
    return Row(
      children: [
        _navBtn(
            Icons.chevron_left,
            () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                }),
            key: const Key(CalendarProfilesKeys.navPrevMonthBtn)),
        const SizedBox(width: 6),
        DropdownButton<int>(
          key: const Key(CalendarProfilesKeys.navMonthDropdown),
          value: _focusedMonth.month,
          isDense: true,
          items: List.generate(
              12,
              (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_monthName(i + 1),
                      style: const TextStyle(fontSize: 13)))),
          onChanged: (v) => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, v ?? 1, 1);
          }),
        ),
        const SizedBox(width: 6),
        DropdownButton<int>(
          key: const Key(CalendarProfilesKeys.navYearDropdown),
          value: _focusedMonth.year,
          isDense: true,
          items: List.generate(
              16,
              (i) => DropdownMenuItem(
                  value: 2020 + i,
                  child: Text('${2020 + i}',
                      style: const TextStyle(fontSize: 13)))),
          onChanged: (v) => setState(() {
            _focusedMonth =
                DateTime(v ?? DateTime.now().year, _focusedMonth.month, 1);
          }),
        ),
        const Spacer(),
        _outlinedBtn(context,
            label: 'Today',
            key: const Key(CalendarProfilesKeys.navTodayBtn),
            onPressed: () => setState(() {
                  final now = DateTime.now();
                  _focusedMonth = DateTime(now.year, now.month, 1);
                  _selectedDate = now;
                })),
        const SizedBox(width: 4),
        _navBtn(
            Icons.chevron_right,
            () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                }),
            key: const Key(CalendarProfilesKeys.navNextMonthBtn)),
      ],
    );
  }

  // ── Calendar grid ─────────────────────────────────────────────────────────

  Widget _buildCalendarGrid(
      ActivityCalendarData? cal, SpecialDayTable specialDays) {
    final sc = SemanticColors.of(context);
    final month = _focusedMonth;
    final firstDow = (month.weekday + 6) % 7; // 0 = Mon
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    const dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final cells = <Widget>[];
    // day-of-week headers
    cells.addAll(dayHeaders.map((h) => Container(
          color: sc.primary,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(h,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        )));
    // empty leading cells
    for (int i = 0; i < firstDow; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final season = _findSeason(date, cal);
      final isToday = DateUtils.isSameDay(date, DateTime.now());
      final isSelected =
          _selectedDate != null && DateUtils.isSameDay(date, _selectedDate!);
      final special = specialDays.entries.firstWhere(
          (e) => _isSameDay(e.specialDayDate, date),
          orElse: () => SpecialDayEntry()..index = -1);
      final isSpecial = special.index != -1;
      final isTouChange = cal != null &&
          cal.seasonProfiles.any((s) =>
              s.seasonStart.year == date.year &&
              s.seasonStart.month == date.month &&
              s.seasonStart.dayOfMonth == date.day);

      cells.add(_calCell(
        day: d,
        date: date,
        isToday: isToday,
        isSelected: isSelected,
        isSpecial: isSpecial,
        isTouChange: isTouChange,
        season: season,
        cal: cal,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.82,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: cells,
    );
  }

  Widget _calCell({
    required int day,
    required DateTime date,
    required bool isToday,
    required bool isSelected,
    required bool isSpecial,
    required bool isTouChange,
    required CalendarSeasonProfile? season,
    required ActivityCalendarData? cal,
  }) {
    final sc = SemanticColors.of(context);
    final idx = (cal != null && season != null)
        ? cal.seasonProfiles.indexOf(season)
        : -1;
    final seasonColor =
        (season != null && idx >= 0) ? _seasonColor(idx) : sc.surfaceVariant;

    final borderColor = isSelected
        ? sc.primary
        : isToday
            ? sc.info
            : sc.outline;
    final borderWidth = (isSelected || isToday) ? 2.0 : 0.5;
    final leftColor = isSpecial
        ? sc.warning
        : isTouChange
            ? sc.info
            : Colors.transparent;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        decoration: BoxDecoration(
          color: isSpecial
              ? sc.warning.withOpacity(.06)
              : isTouChange
                  ? sc.info.withOpacity(.06)
                  : Colors.white,
          border: Border(
            top: BorderSide(color: borderColor, width: borderWidth),
            right: BorderSide(color: borderColor, width: borderWidth),
            bottom: BorderSide(color: borderColor, width: borderWidth),
            left: BorderSide(
                color:
                    leftColor != Colors.transparent ? leftColor : borderColor,
                width: leftColor != Colors.transparent ? 3 : borderWidth),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: (isToday || isSelected)
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: isSelected
                      ? sc.primary
                      : isToday
                          ? sc.info
                          : Colors.black87,
                )),
            const Spacer(),
            if (isSpecial) _calBadge('Special', sc.warning),
            if (isTouChange && !isSpecial) _calBadge('TOU', sc.info),
            if (season != null && !isSpecial && !isTouChange)
              _calBadge(
                season.seasonProfileName.isEmpty
                    ? '--'
                    : season.seasonProfileName,
                seasonColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _calBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.7),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _calendarLegend(ActivityCalendarData? cal) {
    final sc = SemanticColors.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if (cal != null)
          ...cal.seasonProfiles.asMap().entries.map((e) {
            final color = _seasonColor(e.key);
            return _legendItem(e.value.seasonProfileName, color);
          }),
        _legendItem('Special Day', sc.warning),
        _legendItem('TOU Change', sc.info),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color.withOpacity(.2),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }

  // ── Yearly overview navigation row ────────────────────────────────────────

  Widget _buildYearlyNavRow() {
    return Row(
      children: [
        _navBtn(
            Icons.chevron_left,
            () => setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year - 1, 1, 1);
                }),
            key: const Key(CalendarProfilesKeys.yearlyPrevYearBtn)),
        const SizedBox(width: 6),
        DropdownButton<int>(
          key: const Key(CalendarProfilesKeys.yearlyNavYearDropdown),
          value: _focusedMonth.year,
          isDense: true,
          items: List.generate(
              16,
              (i) => DropdownMenuItem(
                  value: 2020 + i,
                  child: Text('${2020 + i}',
                      style: const TextStyle(fontSize: 13)))),
          onChanged: (v) => setState(() {
            _focusedMonth = DateTime(v ?? DateTime.now().year, 1, 1);
          }),
        ),
        const Spacer(),
        _navBtn(
            Icons.chevron_right,
            () => setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year + 1, 1, 1);
                }),
            key: const Key(CalendarProfilesKeys.yearlyNextYearBtn)),
        const SizedBox(width: 4),
        _outlinedBtn(context,
            label: 'Today',
            key: const Key(CalendarProfilesKeys.yearlyNavTodayBtn),
            onPressed: () => setState(() {
                  final now = DateTime.now();
                  _focusedMonth = DateTime(now.year, now.month, 1);
                  _selectedDate = now;
                })),
      ],
    );
  }

  // ── Mini month card (used in yearly overview) ─────────────────────────────

  static const _miniDayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Widget _buildMiniMonthCard(
    int month,
    ActivityCalendarData? cal,
    SpecialDayTable specialDays, {
    required VoidCallback onSelect,
  }) {
    final sc = SemanticColors.of(context);
    final year = _focusedMonth.year;
    final firstDay = DateTime(year, month, 1);
    final firstDow = (firstDay.weekday + 6) % 7; // 0 = Mon
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;

    // Build tiny day cell widgets
    final cells = <Widget>[];
    // Day-of-week header row
    for (final h in _miniDayHeaders) {
      cells.add(Center(
        child: Text(h,
            style: TextStyle(
                fontSize: 7, fontWeight: FontWeight.w700, color: sc.primary)),
      ));
    }
    // Leading empty cells
    for (int i = 0; i < firstDow; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final season = _findSeason(date, cal);
      final idx = (cal != null && season != null)
          ? cal.seasonProfiles.indexOf(season)
          : -1;
      final bgColor = idx >= 0 ? _seasonColor(idx) : Colors.grey.shade100;
      final isToday = year == now.year && month == now.month && d == now.day;
      final isSpecial =
          specialDays.entries.any((e) => _isSameDay(e.specialDayDate, date));

      cells.add(Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: isSpecial
              ? sc.warning.withOpacity(0.35)
              : bgColor.withOpacity(0.55),
          shape: isToday ? BoxShape.circle : BoxShape.rectangle,
          border: isToday ? Border.all(color: sc.info, width: 1.5) : null,
          borderRadius: isToday ? null : BorderRadius.circular(1),
        ),
        child: Center(
          child: Text(
            '$d',
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
              color: isToday ? sc.info : Colors.black87,
            ),
          ),
        ),
      ));
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isCurrentMonth
            ? BorderSide(color: sc.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() {
          _focusedMonth = DateTime(year, month, 1);
          onSelect();
        }),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Month title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: isCurrentMonth ? sc.primary : sc.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _monthName(month),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isCurrentMonth ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Calendar cells grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cells,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Yearly overview grid ──────────────────────────────────────────────────

  Widget _buildYearlyOverview(
      ActivityCalendarData? cal, SpecialDayTable specialDays,
      {required VoidCallback onSelect}) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.9,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(
          12,
          (i) =>
              _buildMiniMonthCard(i + 1, cal, specialDays, onSelect: onSelect)),
    );
  }

  // ── Right panel: day profile for selected date ────────────────────────────

  Widget _buildDayProfileViewer(ActivityCalendarData? cal, DateTime date) {
    final sc = SemanticColors.of(context);
    if (cal == null) {
      return _emptyPlaceholder('No data loaded');
    }

    final season = _findSeason(date, cal);
    final weekPro = season != null
        ? cal.weekProfiles.firstWhere(
            (w) => w.weekProfileName == season.weekProfileName,
            orElse: CalendarWeekProfile.create)
        : null;
    final dowId = weekPro != null ? _dayIdForDow(weekPro, date.weekday) : 0;

    final special = _specialDays.entries.firstWhere(
        (e) => _isSameDay(e.specialDayDate, date),
        orElse: () => SpecialDayEntry()..index = -1);
    final effectiveDayId = (special.index != -1) ? special.dayId : dowId;

    final dayPro = effectiveDayId > 0
        ? cal.dayProfiles.firstWhere((d) => d.dayId == effectiveDayId,
            orElse: CalendarDayProfile.create)
        : CalendarDayProfile.create();

    final isSelectedToday = DateUtils.isSameDay(date, DateTime.now());
    final now = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Row(children: [
          Icon(Icons.access_time, color: sc.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Day Profile — ${_fmtDateShort(date)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        // Context pills
        Wrap(spacing: 6, runSpacing: 4, children: [
          if (season != null) _pill(season.seasonProfileName, sc.warning),
          if (weekPro != null && weekPro.weekProfileName.isNotEmpty)
            _pill(weekPro.weekProfileName, sc.primary),
          if (special.index != -1)
            _pill('Special Day #${special.index}', sc.warning),
          _pill(effectiveDayId > 0 ? 'Day ID $effectiveDayId' : 'No profile',
              sc.info),
        ]),
        const SizedBox(height: 12),
        // Day profile selector chips
        if (cal.dayProfiles.isNotEmpty) ...[
          Text('Day Profiles',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: sc.onSurfaceVariant)),
          const SizedBox(height: 4),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cal.dayProfiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) {
                final dp = cal.dayProfiles[i];
                final active = dp.dayId == effectiveDayId;
                return ChoiceChip(
                  label: Text('Day ${dp.dayId}',
                      style: TextStyle(
                          fontSize: 11,
                          color: active ? Colors.white : sc.primary)),
                  selected: active,
                  selectedColor: sc.primary,
                  backgroundColor: sc.surfaceVariant,
                  onSelected: (_) {},
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
        const Divider(height: 1),
        const SizedBox(height: 8),
        // Time slot list
        Expanded(
          child: dayPro.daySchedule.isEmpty
              ? _emptyPlaceholder('No time slots for this day profile')
              : ListView.builder(
                  itemCount: dayPro.daySchedule.length,
                  itemBuilder: (ctx, i) {
                    final slot = dayPro.daySchedule[i];
                    final nextSlot = i + 1 < dayPro.daySchedule.length
                        ? dayPro.daySchedule[i + 1]
                        : null;

                    final slotMins =
                        slot.startTime.hour * 60 + slot.startTime.minute;
                    final nextMins = nextSlot != null
                        ? nextSlot.startTime.hour * 60 +
                            nextSlot.startTime.minute
                        : 24 * 60;

                    final isActiveTou = isSelectedToday &&
                        nowMins >= slotMins &&
                        nowMins < nextMins;

                    final sel = slot.scriptSelector;
                    final rateColor = sc.primary;
                    final rateLabel = 'T$sel';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color:
                            isActiveTou ? rateColor.withOpacity(.08) : sc.surfaceVariant,
                        border: Border(
                          left: BorderSide(color: rateColor, width: 3),
                          top: BorderSide(color: sc.outline, width: 0.5),
                          right: BorderSide(color: sc.outline, width: 0.5),
                          bottom: BorderSide(color: sc.outline, width: 0.5),
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(_fmtTime(slot.startTime),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              if (nextSlot != null) ...[
                                Text(' → ',
                                    style: TextStyle(
                                        fontSize: 11, color: sc.onSurfaceVariant)),
                                Text(_fmtTime(nextSlot.startTime),
                                    style: TextStyle(
                                        fontSize: 12, color: sc.onSurfaceVariant)),
                              ],
                            ]),
                            const SizedBox(height: 2),
                            Text('Script: ${slot.scriptLogicalName}',
                                style: TextStyle(
                                    fontSize: 11, color: sc.onSurfaceVariant)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: rateColor.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(rateLabel,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: rateColor,
                                        fontWeight: FontWeight.w700)),
                              ),
                              if (isActiveTou) ...[
                                const SizedBox(height: 4),
                                Text('▶ Active now',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: sc.success,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ]),
                      ]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _fmtDateShort(DateTime d) =>
      '${_dayName(d.weekday)} ${d.day} ${_monthName(d.month)} ${d.year}';

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  // ── Bottom full-width status bar ──────────────────────────────────────────

  Widget _buildCalendarStatusBar(
      ActivityCalendarData? cal, DateTime targetDay) {
    final sc = SemanticColors.of(context);
    final now = DateTime.now();
    final season = _findSeason(now, cal);

    final weekPro = (cal != null && season != null)
        ? cal.weekProfiles.firstWhere(
            (w) => w.weekProfileName == season.weekProfileName,
            orElse: CalendarWeekProfile.create)
        : null;
    final dowId = weekPro != null ? _dayIdForDow(weekPro, now.weekday) : 0;
    final dayPro = (cal != null && dowId > 0)
        ? cal.dayProfiles.firstWhere((d) => d.dayId == dowId,
            orElse: CalendarDayProfile.create)
        : CalendarDayProfile.create();

    // Find current TOU slot
    final nowMins = now.hour * 60 + now.minute;
    DayProfileAction? currentSlot;
    DayProfileAction? nextSlot;
    for (int i = 0; i < dayPro.daySchedule.length; i++) {
      final s = dayPro.daySchedule[i];
      final slotMins = s.startTime.hour * 60 + s.startTime.minute;
      final nextMins = i + 1 < dayPro.daySchedule.length
          ? dayPro.daySchedule[i + 1].startTime.hour * 60 +
              dayPro.daySchedule[i + 1].startTime.minute
          : 24 * 60;
      if (nowMins >= slotMins && nowMins < nextMins) {
        currentSlot = s;
        nextSlot = i + 1 < dayPro.daySchedule.length
            ? dayPro.daySchedule[i + 1]
            : null;
        break;
      }
    }

    final touLabel =
        currentSlot == null ? '--' : 'T${currentSlot.scriptSelector}';
    final touColor = currentSlot == null ? sc.onSurfaceVariant : sc.primary;
    final nextChangeLabel = nextSlot != null
        ? '${_fmtTime(nextSlot.startTime)} → T${nextSlot.scriptSelector}'
        : '--';

    return Container(
      color: sc.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _statusChip(
              'Active Season', season?.seasonProfileName ?? '--', sc.warning),
          const SizedBox(width: 12),
          _statusChip(
              'Week Profile', season?.weekProfileName ?? '--', sc.primary),
          const SizedBox(width: 12),
          _statusChip('Day Profile', dowId > 0 ? 'ID $dowId' : '--', sc.info),
          const SizedBox(width: 12),
          _statusChip('Current TOU', touLabel, touColor),
          const SizedBox(width: 12),
          _statusChip('Next Change', nextChangeLabel, sc.success),
          const Spacer(),
          _outlinedBtn(context,
              label: 'Sync', icon: Icons.sync, key: const Key(CalendarProfilesKeys.statusSyncBtn), onPressed: _loadAll),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value, Color color) {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: sc.onSurfaceVariant)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(.4)),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  int _dayIdForDow(CalendarWeekProfile w, int dow) {
    switch (dow) {
      case DateTime.monday:
        return w.monday;
      case DateTime.tuesday:
        return w.tuesday;
      case DateTime.wednesday:
        return w.wednesday;
      case DateTime.thursday:
        return w.thursday;
      case DateTime.friday:
        return w.friday;
      case DateTime.saturday:
        return w.saturday;
      case DateTime.sunday:
        return w.sunday;
      default:
        return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2 – Passive Calendar (read/write + activate)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPassiveCalendarTab() {
    final sc = SemanticColors.of(context);
    if (_calendarError != null)
      return _buildErrorBanner(_calendarError!, _loadAll);
    final cal = _passiveCalendar;

    return Column(
      children: [
        // ── Top: action bar ─────────────────────────────────────────────
        _buildPassiveActionBar(),
        const Divider(height: 1),
        // ── Left / Right split ──────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT: yearly overview or monthly calendar grid ────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: _showPassiveYearlyOverview
                      ? Column(
                          children: [
                            _buildYearlyNavRow(),
                            const SizedBox(height: 8),
                            Expanded(
                                child: _buildYearlyOverview(cal, _specialDays,
                                    onSelect: () =>
                                        _showPassiveYearlyOverview = false)),
                            const SizedBox(height: 8),
                            _calendarLegend(cal),
                          ],
                        )
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                key: const Key(CalendarProfilesKeys.passiveBackAllMonthsBtn),
                                onPressed: () => setState(
                                    () => _showPassiveYearlyOverview = true),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('All months'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : sc.primary,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _calendarNavRow(),
                            const SizedBox(height: 8),
                            Expanded(
                                child: _buildCalendarGrid(cal, _specialDays)),
                            const SizedBox(height: 8),
                            _calendarLegend(cal),
                          ],
                        ),
                ),
              ),
              const VerticalDivider(width: 1),
              // ── RIGHT: profile editors (editable) ────────────────────
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    TabBar(
                      controller: _innerPassive,
                      labelColor:
                          sc.primary,
                      indicatorColor:
                          sc.primary,
                      unselectedLabelColor:
                          sc.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Day Profiles'),
                        Tab(text: 'Week Profiles'),
                        Tab(text: 'Season Profiles'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _innerPassive,
                        children: [
                          _buildDayProfilesView(_passiveCalendar,
                              readOnly: false),
                          _buildWeekProfilesView(_passiveCalendar,
                              readOnly: false),
                          _buildSeasonProfilesView(_passiveCalendar,
                              readOnly: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassiveActionBar() {
    final sc = SemanticColors.of(context);
    final cal = _passiveCalendar;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.edit_calendar, color: sc.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cal != null
                  ? 'Passive: "${_cleanName(cal.calendarName)}"'
                  : 'Passive Calendar',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          _actionBtn(
            key: const Key(CalendarProfilesKeys.passiveActivateBtn),
            icon: Icons.play_arrow,
            label: 'Activate Now',
            color: sc.success,
            onPressed:
                _passiveCalendar != null ? _activatePassiveCalendar : null,
          ),
        ],
      ),
    );
  }

  /// Explicitly read the passive calendar from the meter, overwriting any
  /// local edits.  Only called when the user presses "Read from Meter".
  Future<void> _loadPassiveFromMeter() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _calendarError = null;
    });
    try {
      final cal = await _client.getPassiveCalendar();
      if (!mounted) return;
      setState(() {
        _passiveCalendar = cal;
        _loading = false;
        _passiveReadFromMeter = true;
        _passiveCalendarDirty = false;
      });
      ref.read(calendarCacheProvider.notifier).update(passiveCalendar: cal);
      _snack('Passive calendar refreshed from meter.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calendarError = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _savePassiveCalendar() async {
    if (_passiveCalendar == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final ok = await _client.setPassiveCalendar(_passiveCalendar!);
      if (!mounted) return;
      if (ok) {
        if (mounted) setState(() => _passiveCalendarDirty = false);
        await _showWriteSuccess();
      } else {
        _showWriteError(
          title: 'Write Failed',
          detail: 'The meter returned failure (BoolValue = false).\n\n'
              'The server accepted the gRPC call but rejected the data.\n'
              'Check that all season start dates and week profile names are valid.',
        );
      }
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail: 'Code : ${e.code} (${e.codeName})\n'
            'Message: ${e.message ?? "(none)"}\n'
            '${e.details != null && e.details!.isNotEmpty ? "Details: ${e.details}" : ""}',
      );
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Future<void> _savePassiveDayProfiles() async {
    if (_passiveCalendar == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final ok = await _client.setPassiveDayProfiles(_passiveCalendar!);
      if (!mounted) return;
      if (ok) {
        if (mounted) setState(() => _passiveCalendarDirty = false);
        ref.read(calendarCacheProvider.notifier).flushPassive();
        await _showWriteSuccess();
      } else {
        _showWriteError(
          title: 'Write Failed — Day Profiles',
          detail: 'The meter rejected the Day Profiles write (Attr 9).\n\n'
              'Check that all Day IDs are valid and time slots are correctly defined.',
        );
      }
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail:
            'Code : ${e.code} (${e.codeName})\nMessage: ${e.message ?? "(none)"}',
      );
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Future<void> _savePassiveWeekProfiles() async {
    if (_passiveCalendar == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final ok = await _client.setPassiveWeekProfiles(_passiveCalendar!);
      if (!mounted) return;
      if (ok) {
        if (mounted) setState(() => _passiveCalendarDirty = false);
        ref.read(calendarCacheProvider.notifier).flushPassive();
        await _showWriteSuccess();
      } else {
        _showWriteError(
          title: 'Write Failed — Week Profiles',
          detail: 'The meter rejected the Week Profiles write (Attr 8).\n\n'
              'Check that all referenced Day IDs exist and profile names are valid.',
        );
      }
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail:
            'Code : ${e.code} (${e.codeName})\nMessage: ${e.message ?? "(none)"}',
      );
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Future<void> _savePassiveSeasonProfiles() async {
    if (_passiveCalendar == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final ok = await _client.setPassiveSeasonProfiles(_passiveCalendar!);
      if (!mounted) return;
      if (ok) {
        _snack('Season Profiles written to meter (Attrs 6+7).');
        if (mounted) setState(() => _passiveCalendarDirty = false);
        ref.read(calendarCacheProvider.notifier).flushPassive();
      } else {
        _showWriteError(
          title: 'Write Failed — Season Profiles',
          detail:
              'The meter rejected the Season Profiles write (Attrs 6+7).\n\n'
              'Check that all season start dates and week profile names are valid.',
        );
      }
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail:
            'Code : ${e.code} (${e.codeName})\nMessage: ${e.message ?? "(none)"}',
      );
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  // ── Per-section Read methods ───────────────────────────────────────────────

  Future<void> _readPassiveDayProfiles() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _calendarError = null;
    });
    try {
      final cal = await _client.getPassiveDayProfiles();
      if (!mounted) return;
      setState(() {
        _passiveCalendar ??= ActivityCalendarData();
        _passiveCalendar!.dayProfiles
          ..clear()
          ..addAll(cal.dayProfiles);
        _editingDayProfile = null;
        _passiveReadFromMeter = true;
        _loading = false;
      });
      ref
          .read(calendarCacheProvider.notifier)
          .update(passiveCalendar: _passiveCalendar);
      _snack('Day Profiles read from meter (Attr 9).');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calendarError = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _readPassiveWeekProfiles() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _calendarError = null;
    });
    try {
      final cal = await _client.getPassiveWeekProfiles();
      if (!mounted) return;
      setState(() {
        _passiveCalendar ??= ActivityCalendarData();
        _passiveCalendar!.weekProfiles
          ..clear()
          ..addAll(cal.weekProfiles);
        _editingWeekProfile = null;
        _passiveReadFromMeter = true;
        _loading = false;
      });
      ref
          .read(calendarCacheProvider.notifier)
          .update(passiveCalendar: _passiveCalendar);
      _snack('Week Profiles read from meter (Attr 8).');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calendarError = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _readPassiveSeasonProfiles() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _calendarError = null;
    });
    try {
      final cal = await _client.getPassiveSeasonProfiles();
      if (!mounted) return;
      setState(() {
        _passiveCalendar ??= ActivityCalendarData();
        _passiveCalendar!.seasonProfiles
          ..clear()
          ..addAll(cal.seasonProfiles);
        _normalizeSeasonYears(_passiveCalendar);
        _editingSeason = null;
        _passiveReadFromMeter = true;
        _loading = false;
      });
      ref
          .read(calendarCacheProvider.notifier)
          .update(passiveCalendar: _passiveCalendar);
      _snack('Season Profiles read from meter (Attr 7).');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calendarError = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  void _showWriteError({required String title, required String detail}) {
    final sc = SemanticColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.error_outline, color: sc.error, size: 32),
        title: Text(title, style: TextStyle(color: sc.error)),
        content: SelectableText(
          detail,
          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWriteSuccess() {
    final sc = SemanticColors.of(context);
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.check_circle, color: sc.success),
          const SizedBox(width: 10),
          const Text('Write Successful'),
        ]),
        content: const Text('The value was written to the meter successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _activatePassiveCalendar() async {
    final sc = SemanticColors.of(context);
    // Warn the user if there are local edits that have not been written to the meter yet.
    if (_passiveCalendarDirty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          icon: Icon(Icons.warning_amber_rounded,
              color: sc.warning, size: 36),
          title: const Text('Unwritten Changes'),
          content: const Text(
            'The passive calendar has local modifications that have not been '
            'written to the meter yet.\n\n'
            'Activation will use the last version written to the meter, '
            'not your current edits.\n\n'
            'Tip: press “Write to Meter” first, then activate.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: sc.warning),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activate Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Activate Passive Calendar?'),
        content: const Text(
            'The passive calendar will immediately replace the active calendar on the meter.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sc.success),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _loading = true;
    });
    bool ok = false;
    try {
      ok = await _client.activatePassiveCalendar();
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail: 'Code : ${e.code} (${e.codeName})\n'
            'Message: ${e.message ?? "(none)"}\n'
            '${e.details != null && e.details!.isNotEmpty ? "Details: ${e.details}" : ""}',
      );
      return;
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
      return;
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
    if (!mounted) return;
    if (ok) {
      _snack('Passive calendar activated successfully.');
      _passiveReadFromMeter =
          false; // force fresh passive read from meter to confirm state
      // Reload is best-effort: activation already succeeded on the meter.
      try {
        await _loadAll();
      } catch (_) {}
      if (mounted)
        _outerTab
            .animateTo(0); // switch to Active tab to show promoted calendar
    } else {
      _showWriteError(
        title: 'Activation Failed',
        detail: 'The meter returned failure (BoolValue = false).\n\n'
            'The server accepted the gRPC call but the meter rejected the action.\n'
            'Check that a valid passive calendar is staged and that the session '
            'has ACTION rights.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Shared profile views
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Day Profiles ──────────────────────────────────────────────────────────

  Widget _buildDayProfilesView(ActivityCalendarData? cal,
      {required bool readOnly}) {
    if (cal == null) return _emptyPlaceholder('No data loaded');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: _card(child: _dayProfileListPanel(cal, readOnly)),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _card(child: _dayProfileEditorPanel(cal, readOnly)),
        ),
      ],
    );
  }

  // ── LEFT PANEL: Liste des Profils ─────────────────────────────────────────

  Widget _dayProfileListPanel(ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                  child: _sectionHeader(
                      Icons.view_day, sc.primary, 'Day Profile List')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Column headers
        Container(
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            border: Border(
              top: BorderSide(
                  color: sc.outline),
              bottom: BorderSide(
                  color: sc.outline),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Nom',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              sc.onSurfaceVariant))),
              Expanded(
                  flex: 2,
                  child: Text('Slots',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              sc.onSurfaceVariant))),
              Expanded(
                  flex: 4,
                  child: Text('Tarifs',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              sc.onSurfaceVariant))),
              if (!readOnly)
                SizedBox(
                    width: 60,
                    child: Text('Actions',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sc.onSurfaceVariant))),
            ],
          ),
        ),
        // Rows
        Expanded(
          child: cal.dayProfiles.isEmpty
              ? _emptyPlaceholder('No profiles defined')
              : ListView.separated(
                  itemCount: cal.dayProfiles.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: sc.outline),
                  itemBuilder: (ctx, i) {
                    final d = cal.dayProfiles[i];
                    final selected = _editingDayProfile?.dayId == d.dayId;
                    final tarifs = _dayProfileTariffSummary(d);
                    return InkWell(
                      onTap: () => setState(() => _editingDayProfile = d),
                      child: Container(
                        color: selected ? sc.surfaceVariant : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                _dayProfileNames[d.dayId]?.isNotEmpty == true
                                    ? _dayProfileNames[d.dayId]!
                                    : 'Profile ${d.dayId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected ? sc.primary : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                d.daySchedule.isEmpty
                                    ? '—'
                                    : '${d.daySchedule.length}',
                                style: TextStyle(
                                    fontSize: 12, color: sc.onSurfaceVariant),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                tarifs,
                                style: TextStyle(
                                    fontSize: 11, color: sc.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!readOnly)
                              SizedBox(
                                width: 60,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () =>
                                      setState(() => _editingDayProfile = d),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit,
                                          size: 13, color: sc.primary),
                                      const SizedBox(width: 3),
                                      Text('Edit',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: sc.primary)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (!readOnly) ...[
                Expanded(
                  child: _primaryBtn(
                    key: const Key(CalendarProfilesKeys.dayProfileAddBtn),
                    icon: Icons.add,
                    label: 'Add',
                    onPressed: () => setState(() {
                      final newId = cal.dayProfiles.isEmpty
                          ? 1
                          : cal.dayProfiles.map((d) => d.dayId).reduce(max) + 1;
                      final np = CalendarDayProfile()..dayId = newId;
                      cal.dayProfiles.add(np);
                      _editingDayProfile = np;
                      _dayProfileNames[newId] = '';
                      _passiveCalendarDirty = true;
                      ref.read(calendarCacheProvider.notifier).flushPassive();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.dayProfilesReadBtn),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sc.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected ? _readPassiveDayProfiles : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.dayProfilesWriteBtn),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Write'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected && _passiveCalendar != null
                        ? _savePassiveDayProfiles
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _dayProfileTariffSummary(CalendarDayProfile d) {
    if (d.daySchedule.isEmpty) return '—';
    final selectors =
        d.daySchedule.map((s) => s.scriptSelector).toSet().toList()..sort();
    return selectors.map((s) => 'T$s').join(', ');
  }

  // ── RIGHT PANEL: Éditeur de Profil ────────────────────────────────────────

  Widget _dayProfileEditorPanel(ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    final d = _editingDayProfile;
    if (d == null) {
      return _emptyPlaceholder(
        readOnly ? 'Select a profile to view' : 'Select or create a profile',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: _sectionHeader(Icons.edit_calendar, sc.info, 'Profile Editor'),
        ),
        const SizedBox(height: 12),
        // Profile name display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile name',
                  style: TextStyle(
                      fontSize: 11,
                      color: sc.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                key: const Key(CalendarProfilesKeys.dayProfileNameField),
                initialValue: _dayProfileNames[d.dayId]?.isNotEmpty == true
                    ? _dayProfileNames[d.dayId]!
                    : '',
                decoration: InputDecoration(
                  hintText: 'Profile ${d.dayId}',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                enabled: !readOnly,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => setState(() {
                  _dayProfileNames[d.dayId] = v.trim();
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Time slots heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _sectionHeader(Icons.access_time, sc.primary, 'Time Slots'),
        ),
        const SizedBox(height: 6),
        // Slot column headers
        Container(
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            border: Border(
              top: BorderSide(
                  color: sc.outline),
              bottom: BorderSide(
                  color: sc.outline),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Text('Time Range',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              sc.onSurfaceVariant))),
              Expanded(
                  flex: 3,
                  child: Text('Label',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              sc.onSurfaceVariant))),
              if (!readOnly)
                SizedBox(
                    width: 72,
                    child: Text('Actions',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sc.onSurfaceVariant))),
            ],
          ),
        ),
        // Slot rows
        Expanded(
          child: d.daySchedule.isEmpty
              ? _emptyPlaceholder('No time slots')
              : ListView.separated(
                  itemCount: d.daySchedule.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: sc.outline),
                  itemBuilder: (ctx, i) {
                    final action = d.daySchedule[i];
                    final nextAction = i + 1 < d.daySchedule.length
                        ? d.daySchedule[i + 1]
                        : null;
                    final endLabel = nextAction != null
                        ? _fmtTimeHM(nextAction.startTime)
                        : '24:00';
                    final sel = action.scriptSelector;
                    final rateColor = sc.primary;
                    final rateLabel = 'T$sel';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${_fmtTimeHM(action.startTime)} – $endLabel',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: rateColor.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: rateColor.withOpacity(.35)),
                                ),
                                child: Text(
                                  rateLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: rateColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!readOnly)
                            SizedBox(
                              width: 72,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.edit,
                                        size: 16, color: sc.info),
                                    tooltip: 'Edit',
                                    onPressed: () => _showSlotDialog(d, i),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.delete_outline,
                                        size: 16, color: sc.error),
                                    tooltip: 'Delete',
                                    onPressed: () => setState(() {
                                      d.daySchedule.removeAt(i);
                                      _passiveCalendarDirty = true;
                                      ref
                                          .read(calendarCacheProvider.notifier)
                                          .flushPassive();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (!readOnly) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _outlinedBtn(
              context,
              label: 'Add Time Slot',
              icon: Icons.add,
              key: const Key(CalendarProfilesKeys.dayProfileAddSlotBtn),
              onPressed: () => _showSlotDialog(d, null),
            ),
          ),
        ],
        if (!readOnly) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                key: const Key(CalendarProfilesKeys.dayProfileDeleteBtn),
                onPressed: () => setState(() {
                  cal.dayProfiles.removeWhere((p) => p.dayId == d.dayId);
                  _editingDayProfile = null;
                  _passiveCalendarDirty = true;
                  ref
                      .read(calendarCacheProvider.notifier)
                      .flushPassive();
                }),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Delete Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sc.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _fmtTimeHM(CalendarTimeValue? t) {
    if (t == null) return '--:--';
    final h = t.hour == 255 ? '**' : t.hour.toString().padLeft(2, '0');
    final m = t.minute == 255 ? '**' : t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showSlotDialog(CalendarDayProfile d, int? editIndex) {
    final sc = SemanticColors.of(context);
    final existing = editIndex != null ? d.daySchedule[editIndex] : null;

    // ── Start time ───────────────────────────────────────────────────────────
    int selHour = existing?.startTime.hour ?? 0;
    int selMinute = existing?.startTime.minute ?? 0;
    int selSecond = existing?.startTime.second ?? 0;

    // ── End time: taken from the next slot's startTime (if it exists) ───────
    final hasNextSlot =
        editIndex != null && editIndex + 1 < d.daySchedule.length;
    final nextSlot = hasNextSlot ? d.daySchedule[editIndex! + 1] : null;
    int endHour = nextSlot?.startTime.hour ?? 0; // 00:00:00 = midnight
    int endMinute = nextSlot?.startTime.minute ?? 0;
    int endSecond = nextSlot?.startTime.second ?? 0;

    final scriptCtrl =
        TextEditingController(text: existing?.scriptLogicalName ?? '');
    final selectorCtrl =
        TextEditingController(text: '${existing?.scriptSelector ?? 1}');
    int selector = existing?.scriptSelector ?? 1;

    void disposeAll() {
      selectorCtrl.dispose();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(editIndex == null ? 'Add Time Slot' : 'Edit Time Slot'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Start Time ──────────────────────────────────────────
                  _drumSection(
                    label: 'Start Time',
                    selHour: selHour,
                    selMinute: selMinute,
                    selSecond: selSecond,
                    color: sc.primary,
                    onHourChanged: (v) => setLocal(() => selHour = v),
                    onMinuteChanged: (v) => setLocal(() => selMinute = v),
                    onSecondChanged: (v) => setLocal(() => selSecond = v),
                  ),
                  const SizedBox(height: 14),
                  // Separator arrow
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_downward,
                            size: 16, color: sc.onSurfaceVariant),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── End Time ────────────────────────────────────────────
                  _drumSection(
                    label: hasNextSlot
                        ? 'End Time  ·  sets next slot\'s start'
                        : (endHour == 0 && endMinute == 0 && endSecond == 0)
                            ? 'End Time  ·  00:00 = runs until midnight'
                            : 'End Time  ·  a new slot will start here',
                    selHour: endHour,
                    selMinute: endMinute,
                    selSecond: endSecond,
                    color: sc.info,
                    onHourChanged: (v) => setLocal(() => endHour = v),
                    onMinuteChanged: (v) => setLocal(() => endMinute = v),
                    onSecondChanged: (v) => setLocal(() => endSecond = v),
                  ),
                  const SizedBox(height: 16),
                  // ── Script LN ───────────────────────────────────────────
                  TextField(
                    controller: scriptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Script LN (hex, e.g. 0000060100FF)',
                      hintText: '0000060100FF',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Tariff ──────────────────────────────────────────────
                  TextFormField(
                    controller: selectorCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tariff (numéro)',
                      hintText: '1',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final parsed = int.tryParse(v.trim());
                      if (parsed != null && parsed >= 1) {
                        setLocal(() => selector = parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                disposeAll();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAction = DayProfileAction()
                  ..startTime = (CalendarTimeValue()
                    ..hour = selHour
                    ..minute = selMinute
                    ..second = selSecond
                    ..hundredths = 0)
                  ..scriptLogicalName = scriptCtrl.text
                      .trim()
                      .toUpperCase()
                      .replaceFirst(RegExp(r'^0X'), '')
                  ..scriptSelector = selector;
                setState(() {
                  if (editIndex == null) {
                    d.daySchedule.add(newAction);
                    // If user set a non-midnight end time on a new last slot,
                    // insert an extra slot starting at that end time.
                    if (endHour != 0 || endMinute != 0 || endSecond != 0) {
                      d.daySchedule.add(DayProfileAction()
                        ..startTime = (CalendarTimeValue()
                          ..hour = endHour
                          ..minute = endMinute
                          ..second = endSecond
                          ..hundredths = 0)
                        ..scriptLogicalName = newAction.scriptLogicalName
                        ..scriptSelector = selector);
                    }
                  } else {
                    d.daySchedule[editIndex] = newAction;
                    if (hasNextSlot) {
                      // Propagate end time → existing next slot's start time
                      d.daySchedule[editIndex + 1].startTime
                        ..hour = endHour
                        ..minute = endMinute
                        ..second = endSecond
                        ..hundredths = 0;
                    } else if (endHour != 0 ||
                        endMinute != 0 ||
                        endSecond != 0) {
                      // Last slot: user chose an end time → insert a new slot there
                      d.daySchedule.insert(
                          editIndex + 1,
                          DayProfileAction()
                            ..startTime = (CalendarTimeValue()
                              ..hour = endHour
                              ..minute = endMinute
                              ..second = endSecond
                              ..hundredths = 0)
                            ..scriptLogicalName = newAction.scriptLogicalName
                            ..scriptSelector = selector);
                    }
                  }
                  _passiveCalendarDirty = true;
                  ref.read(calendarCacheProvider.notifier).flushPassive();
                });
                disposeAll();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeDrum({
    required int value,
    required int count,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    final sc = SemanticColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 0),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: sc.onSurfaceVariant)),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => onChanged((value - 1 + count) % count),
                child: Icon(Icons.keyboard_arrow_up,
                    size: 22, color: sc.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: () => onChanged((value + 1) % count),
                child: Icon(Icons.keyboard_arrow_down,
                    size: 22, color: sc.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _drumColon() {
    final sc = SemanticColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Text(':',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: sc.onSurfaceVariant,
              height: 1)),
    );
  }

  /// A labelled drum-picker container (HH:MM:SS) with a live readout below.
  /// When [readOnly] is true the wheels are disabled and shown in grey.
  Widget _drumSection({
    required String label,
    required int selHour,
    required int selMinute,
    required int selSecond,
    required Color color,
    bool readOnly = false,
    required ValueChanged<int> onHourChanged,
    required ValueChanged<int> onMinuteChanged,
    required ValueChanged<int> onSecondChanged,
  }) {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: readOnly ? sc.onSurfaceVariant : color)),
        const SizedBox(height: 6),
        Container(
          height: 148,
          decoration: BoxDecoration(
            color: readOnly ? sc.surfaceVariant : sc.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: readOnly ? sc.outline : color.withOpacity(.45)),
          ),
          child: IgnorePointer(
            ignoring: readOnly,
            child: Row(
              children: [
                Expanded(
                    child: _timeDrum(
                        value: selHour,
                        count: 24,
                        label: 'HH',
                        onChanged: onHourChanged)),
                _drumColon(),
                Expanded(
                    child: _timeDrum(
                        value: selMinute,
                        count: 60,
                        label: 'MM',
                        onChanged: onMinuteChanged)),
                _drumColon(),
                Expanded(
                    child: _timeDrum(
                        value: selSecond,
                        count: 60,
                        label: 'SS',
                        onChanged: onSecondChanged)),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '${selHour.toString().padLeft(2, '0')}:'
              '${selMinute.toString().padLeft(2, '0')}:'
              '${selSecond.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: readOnly ? sc.onSurfaceVariant : color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Week Profiles ─────────────────────────────────────────────────────────

  Widget _buildWeekProfilesView(ActivityCalendarData? cal,
      {required bool readOnly}) {
    final sc = SemanticColors.of(context);
    if (cal == null) return _emptyPlaceholder('No data loaded');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Info box ─────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sc.primary.withOpacity(.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: sc.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Week Profiles — Associate a Day Profile with each day of the week.',
                  style: TextStyle(fontSize: 12, color: sc.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Main card ────────────────────────────────────────────────────────
        Expanded(
          child: _card(child: _weekProfileTablePanel(cal, readOnly)),
        ),
      ],
    );
  }

  Widget _weekProfileTablePanel(ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    String _resolveLabel(ActivityCalendarData cal, int dayId) {
      if (dayId <= 0) return '--';
      final name = _dayProfileNames[dayId];
      return (name != null && name.isNotEmpty) ? name : 'Profile $dayId';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: title + Read/Write ───────────────────────────────────────
        Row(
          children: [
            Expanded(
                child: _sectionHeader(
                    Icons.calendar_view_week, sc.primary, 'Configuration')),
          ],
        ),
        const SizedBox(height: 8),
        // ── Column headers ───────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            border: Border(
              top: BorderSide(color: sc.outline),
              bottom: BorderSide(color: sc.outline),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: Text('Week Profile',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              ...days.map((d) => Expanded(
                    child: Text(d,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sc.onSurfaceVariant),
                        textAlign: TextAlign.center),
                  )),
              if (!readOnly)
                SizedBox(
                  width: 60,
                  child: Text('Actions',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sc.onSurfaceVariant)),
                ),
            ],
          ),
        ),
        // ── Rows ─────────────────────────────────────────────────────────────
        Expanded(
          child: cal.weekProfiles.isEmpty
              ? _emptyPlaceholder('No week profiles')
              : ListView.separated(
                  itemCount: cal.weekProfiles.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: sc.outline),
                  itemBuilder: (ctx, i) {
                    final w = cal.weekProfiles[i];
                    final selected = _editingWeekProfile != null &&
                        _editingWeekProfile!.weekProfileName ==
                            w.weekProfileName;
                    final dayIds = [
                      w.monday,
                      w.tuesday,
                      w.wednesday,
                      w.thursday,
                      w.friday,
                      w.saturday,
                      w.sunday
                    ];
                    return Container(
                      color: selected ? sc.surfaceVariant : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 160,
                            child: Text(
                              w.weekProfileName.isEmpty
                                  ? '--'
                                  : w.weekProfileName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? sc.primary : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...dayIds.map((id) => Expanded(
                                child: Text(
                                  _resolveLabel(cal, id),
                                  style: TextStyle(
                                      fontSize: 11, color: sc.info),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                          if (!readOnly)
                            SizedBox(
                              width: 60,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => setState(() {
                                  _editingWeekProfile = w;
                                  _nameCtrl.text = w.weekProfileName;
                                }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit,
                                        size: 13, color: sc.primary),
                                    const SizedBox(width: 3),
                                    Text('Edit',
                                        style: TextStyle(
                                            fontSize: 11, color: sc.primary)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // ── Inline editor ─────────────────────────────────────────────────────
        if (_editingWeekProfile != null)
          _weekProfileInlineEditor(_editingWeekProfile!, cal, readOnly),
        const Divider(height: 1),
        // ── Bottom buttons ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (!readOnly) ...[
                Expanded(
                  child: _primaryBtn(
                    key: const Key(CalendarProfilesKeys.weekProfileAddBtn),
                    icon: Icons.add,
                    label: 'Add',
                    onPressed: () => setState(() {
                      final np = CalendarWeekProfile()
                        ..weekProfileName = ''
                        ..monday = 1
                        ..tuesday = 1
                        ..wednesday = 1
                        ..thursday = 1
                        ..friday = 1
                        ..saturday = 1
                        ..sunday = 1;
                      cal.weekProfiles.add(np);
                      _editingWeekProfile = np;
                      _nameCtrl.text = '';
                      _passiveCalendarDirty = true;
                      ref.read(calendarCacheProvider.notifier).flushPassive();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.weekProfilesReadBtn),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sc.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected ? _readPassiveWeekProfiles : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.weekProfilesWriteBtn),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Write'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected && _passiveCalendar != null
                        ? _savePassiveWeekProfiles
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _weekProfileInlineEditor(
      CalendarWeekProfile w, ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayIds = [
      w.monday,
      w.tuesday,
      w.wednesday,
      w.thursday,
      w.friday,
      w.saturday,
      w.sunday
    ];

    void _setDay(int i, int v) {
      switch (i) {
        case 0:
          w.monday = v;
          break;
        case 1:
          w.tuesday = v;
          break;
        case 2:
          w.wednesday = v;
          break;
        case 3:
          w.thursday = v;
          break;
        case 4:
          w.friday = v;
          break;
        case 5:
          w.saturday = v;
          break;
        case 6:
          w.sunday = v;
          break;
      }
    }

    final seen = <int>{};
    final availableDayIds = cal.dayProfiles
        .where((d) => seen.add(d.dayId))
        .map((d) => d.dayId)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: sc.surfaceVariant,
        border: Border(
          top: BorderSide(color: sc.primary.withOpacity(.25)),
          bottom: BorderSide(color: sc.primary.withOpacity(.25)),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, size: 16, color: sc.info),
              const SizedBox(width: 6),
              Text(
                readOnly
                    ? 'Week Profile: ${w.weekProfileName}'
                    : 'Editing: ${w.weekProfileName}',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                key: const Key(CalendarProfilesKeys.weekProfileEditorCloseBtn),
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Close',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _editingWeekProfile = null),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!readOnly) ...[
            SizedBox(
              width: 240,
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Week Name',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  setState(() => w.weekProfileName = v);
                  _passiveCalendarDirty = true;
                  ref.read(calendarCacheProvider.notifier).flushPassive();
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Day dropdowns in a single row
          Row(
            children: List.generate(7, (i) {
              final dayId = dayIds[i];
              // Build a fresh DropdownMenuItem list per dropdown — sharing one
              // list across multiple DropdownButtonFormField widgets causes the
              // "value matches multiple items" Flutter assertion.
              final items = availableDayIds.map((id) {
                final name = _dayProfileNames[id];
                final label =
                    (name != null && name.isNotEmpty) ? name : 'Profile $id';
                return DropdownMenuItem<int>(
                    value: id,
                    child: Text(label, style: const TextStyle(fontSize: 12)));
              }).toList();
              final safeValue = items.any((m) => m.value == dayId)
                  ? dayId
                  : (items.isNotEmpty ? items.first.value : null);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(days[i],
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sc.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      readOnly
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              decoration: BoxDecoration(
                                color: sc.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: sc.outline),
                              ),
                              child: Text(() {
                                final name = _dayProfileNames[dayId];
                                return (name != null && name.isNotEmpty)
                                    ? name
                                    : 'Profile $dayId';
                              }(),
                                  style: TextStyle(
                                      fontSize: 11, color: sc.info)),
                            )
                          : items.isEmpty
                              ? const Text('--', style: TextStyle(fontSize: 11))
                              : DropdownButtonFormField<int>(
                                  value: safeValue,
                                  isDense: true,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                  ),
                                  items: items,
                                  onChanged: (v) => setState(() {
                                    if (v != null) _setDay(i, v);
                                  }),
                                ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (!readOnly) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  key: const Key(CalendarProfilesKeys.weekProfileEditorDeleteBtn),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sc.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => setState(() {
                    cal.weekProfiles.remove(w);
                    _editingWeekProfile = null;
                    _passiveCalendarDirty = true;
                    ref.read(calendarCacheProvider.notifier).flushPassive();
                  }),
                ),
                const Spacer(),
                TextButton(
                  key: const Key(CalendarProfilesKeys.weekProfileEditorCancelBtn),
                  onPressed: () => setState(() => _editingWeekProfile = null),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Season Profiles ───────────────────────────────────────────────────────

  Widget _buildSeasonProfilesView(ActivityCalendarData? cal,
      {required bool readOnly}) {
    final sc = SemanticColors.of(context);
    if (cal == null) return _emptyPlaceholder('No data loaded');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Info banner ──────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sc.primary.withOpacity(.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: sc.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Season Profiles — Define seasonal periods by linking a Week Profile '
                  'to an activation date range. Each season activates on its Start Date '
                  'and ends the day before the next season begins.',
                  style: TextStyle(fontSize: 12, color: sc.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Two-panel layout ─────────────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 380,
                child: _card(child: _seasonList(cal, readOnly)),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                  child: _card(
                      child: _seasonEditor(_editingSeason, cal, readOnly))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seasonList(ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                  child: _sectionHeader(
                      Icons.park, sc.success, 'Season Profile List')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── Column headers ────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            border: Border(
              top: BorderSide(color: sc.outline),
              bottom: BorderSide(color: sc.outline),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Name',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              Expanded(
                flex: 4,
                child: Text('Start Date',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              Expanded(
                flex: 3,
                child: Text('Week Profile',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              if (!readOnly)
                SizedBox(
                  width: 60,
                  child: Text('Actions',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sc.onSurfaceVariant)),
                ),
            ],
          ),
        ),
        // ── Rows ─────────────────────────────────────────────────────────────
        Expanded(
          child: cal.seasonProfiles.isEmpty
              ? _emptyPlaceholder('No season profiles defined')
              : ListView.separated(
                  itemCount: cal.seasonProfiles.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: sc.outline),
                  itemBuilder: (ctx, i) {
                    final s = cal.seasonProfiles[i];
                    final selected = identical(_editingSeason, s);
                    final dotColor = _seasonColor(i);
                    return InkWell(
                      key: ObjectKey(s),
                      onTap: () => setState(() {
                        _editingSeason = s;
                        _seasonNameCtrl.text = s.seasonProfileName;
                        if (s.seasonStart.year == 65535) {
                          s.seasonStart.year = DateTime.now().year;
                        }
                      }),
                      child: Container(
                        color: selected ? sc.surfaceVariant : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Name + colour dot
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      s.seasonProfileName.isEmpty
                                          ? '--'
                                          : s.seasonProfileName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected ? sc.primary : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Start date
                            Expanded(
                              flex: 4,
                              child: Text(
                                _fmtDate(s.seasonStart),
                                style: TextStyle(
                                    fontSize: 12, color: sc.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Week profile
                            Expanded(
                              flex: 3,
                              child: Text(
                                s.weekProfileName.isEmpty
                                    ? '--'
                                    : s.weekProfileName,
                                style: TextStyle(
                                    fontSize: 12, color: sc.info),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Edit button (passive only)
                            if (!readOnly)
                              SizedBox(
                                width: 60,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => setState(() {
                                    _editingSeason = s;
                                    _seasonNameCtrl.text = s.seasonProfileName;
                                    if (s.seasonStart.year == 65535) {
                                      s.seasonStart.year = DateTime.now().year;
                                    }
                                  }),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit,
                                          size: 13, color: sc.primary),
                                      const SizedBox(width: 3),
                                      Text('Edit',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: sc.primary)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        // ── Bottom buttons ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (!readOnly) ...[
                Expanded(
                  child: _primaryBtn(
                    key: const Key(CalendarProfilesKeys.seasonProfileAddBtn),
                    icon: Icons.add,
                    label: 'Add',
                    onPressed: () => setState(() {
                      final np = CalendarSeasonProfile()
                        ..seasonProfileName = ''
                        ..seasonStart = (CalendarDateValue()
                          ..year = DateTime.now().year
                          ..month = 1
                          ..dayOfMonth = 1
                          ..dayOfWeek = 255)
                        ..weekProfileName = cal.weekProfiles.isNotEmpty
                            ? cal.weekProfiles.first.weekProfileName
                            : '';
                      cal.seasonProfiles.add(np);
                      _editingSeason = np;
                      _seasonNameCtrl.text = '';
                      _passiveCalendarDirty = true;
                      ref.read(calendarCacheProvider.notifier).flushPassive();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.seasonProfilesReadBtn),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sc.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected ? _readPassiveSeasonProfiles : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key(CalendarProfilesKeys.seasonProfilesWriteBtn),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Write'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isConnected && _passiveCalendar != null
                        ? _savePassiveSeasonProfiles
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _seasonEditor(
      CalendarSeasonProfile? s, ActivityCalendarData cal, bool readOnly) {
    final sc = SemanticColors.of(context);
    if (s == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park, size: 52, color: sc.outline),
            const SizedBox(height: 12),
            Text('Select a season to view or edit',
                style: TextStyle(color: sc.onSurfaceVariant, fontSize: 13)),
            if (!readOnly) ...[
              const SizedBox(height: 6),
              Text('or tap "+ Add Season" to create one',
                  style: TextStyle(color: sc.onSurfaceVariant, fontSize: 12)),
            ],
          ],
        ),
      );
    }

    // Compute end date (day before next season start, sorted by start date).
    final sorted = List<CalendarSeasonProfile>.from(cal.seasonProfiles)
      ..sort((a, b) {
        final ad = DateTime(
            a.seasonStart.year == 65535 ? 9999 : a.seasonStart.year,
            a.seasonStart.month,
            a.seasonStart.dayOfMonth);
        final bd = DateTime(
            b.seasonStart.year == 65535 ? 9999 : b.seasonStart.year,
            b.seasonStart.month,
            b.seasonStart.dayOfMonth);
        return ad.compareTo(bd);
      });
    final sortedIdx = sorted.indexWhere((x) => identical(x, s));
    String endDateStr = '∞';
    DateTime? endDateDt;
    CalendarSeasonProfile? nextSeasonProfile;
    if (sortedIdx >= 0 && sortedIdx + 1 < sorted.length) {
      nextSeasonProfile = sorted[sortedIdx + 1];
      final next = nextSeasonProfile.seasonStart;
      try {
        final nextDt = DateTime(
            next.year == 65535 ? 9999 : next.year, next.month, next.dayOfMonth);
        endDateDt = nextDt.subtract(const Duration(days: 1));
        endDateStr = '${endDateDt.year.toString().padLeft(4, '0')}'
            '/${endDateDt.month.toString().padLeft(2, '0')}'
            '/${endDateDt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final origIdx = cal.seasonProfiles.indexOf(s);
    final cardColor = origIdx >= 0 ? _seasonColor(origIdx) : sc.info;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ───────────────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_calendar, color: sc.info, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                readOnly
                    ? 'Season: ${s.seasonProfileName.isEmpty ? "--" : s.seasonProfileName}'
                    : 'Editing: ${s.seasonProfileName.isEmpty ? "New Season" : s.seasonProfileName}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Season Name ────────────────────────────────────────────────
                Text('Season Name',
                    style: TextStyle(
                        fontSize: 11,
                        color: sc.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (readOnly)
                  _infoDisplayBox(
                      s.seasonProfileName.isEmpty ? '--' : s.seasonProfileName)
                else
                  TextField(
                    controller: _seasonNameCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      hintText: 'e.g. 1',
                    ),
                    onChanged: (v) => setState(() => s.seasonProfileName = v),
                  ),
                const SizedBox(height: 14),
                // ── Week Profile ───────────────────────────────────────────────
                Text('Week Profile',
                    style: TextStyle(
                        fontSize: 11,
                        color: sc.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (readOnly)
                  _infoDisplayBox(
                      s.weekProfileName.isEmpty ? '--' : s.weekProfileName)
                else if (cal.weekProfiles.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: cal.weekProfiles
                            .any((w) => w.weekProfileName == s.weekProfileName)
                        ? s.weekProfileName
                        : null,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      hintText: 'Select a week profile',
                    ),
                    isExpanded: true,
                    items: cal.weekProfiles
                        .map((w) => DropdownMenuItem(
                            value: w.weekProfileName,
                            child: Text(w.weekProfileName,
                                style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setState(
                        () => s.weekProfileName = v ?? s.weekProfileName),
                  )
                else
                  TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      hintText: 'Enter week profile name',
                      suffixIcon: const Icon(Icons.arrow_drop_down, size: 18),
                    ),
                    controller: TextEditingController(text: s.weekProfileName),
                    onChanged: (v) => setState(() => s.weekProfileName = v),
                  ),
                const SizedBox(height: 14),
                // ── Start Date ─────────────────────────────────────────────────
                Text('Start Date',
                    style: TextStyle(
                        fontSize: 11,
                        color: sc.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (readOnly)
                  _infoDisplayBox(_fmtDate(s.seasonStart))
                else
                  _datePickerField(
                    date: DateTime(
                      (s.seasonStart.year >= 2000 && s.seasonStart.year <= 2060)
                          ? s.seasonStart.year
                          : DateTime.now().year,
                      s.seasonStart.month.clamp(1, 12),
                      s.seasonStart.dayOfMonth.clamp(1, 28),
                    ),
                    onPicked: (picked) => setState(() {
                      s.seasonStart
                        ..year = picked.year
                        ..month = picked.month
                        ..dayOfMonth = picked.day;
                      _passiveCalendarDirty = true;
                      ref.read(calendarCacheProvider.notifier).flushPassive();
                    }),
                  ),
                const SizedBox(height: 14),
                // ── End Date ───────────────────────────────────────────────────
                Row(
                  children: [
                    Text('End Date',
                        style: TextStyle(
                            fontSize: 11,
                            color: sc.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    if (nextSeasonProfile == null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sc.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('last season',
                            style: TextStyle(
                                fontSize: 9,
                                color: sc.onSurfaceVariant,
                                fontWeight: FontWeight.w600)),
                      )
                    else if (!readOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sc.info.withOpacity(.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('adjusts next season start',
                            style: TextStyle(
                                fontSize: 9,
                                color: sc.info,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (readOnly || nextSeasonProfile == null)
                  _infoDisplayBox(endDateStr,
                      note: nextSeasonProfile == null
                          ? 'Last season — no upper bound'
                          : 'Day before next season\'s start date')
                else
                  _datePickerField(
                    date: endDateDt ?? DateTime(DateTime.now().year, 12, 31),
                    onPicked: (picked) => setState(() {
                      final nextStart = picked.add(const Duration(days: 1));
                      nextSeasonProfile!.seasonStart
                        ..year = nextStart.year
                        ..month = nextStart.month
                        ..dayOfMonth = nextStart.day;
                      _passiveCalendarDirty = true;
                      ref.read(calendarCacheProvider.notifier).flushPassive();
                    }),
                    note:
                        '"${nextSeasonProfile.seasonProfileName}" will start on the following day',
                  ),
              ],
            ),
          ),
        ),
        // ── Delete ───────────────────────────────────────────────────────────
        if (!readOnly) ...[
          const Divider(height: 1),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key(CalendarProfilesKeys.seasonProfileDeleteBtn),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: sc.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => setState(() {
              cal.seasonProfiles.remove(s);
              _editingSeason = null;
              _passiveCalendarDirty = true;
              ref.read(calendarCacheProvider.notifier).flushPassive();
            }),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3 – Special Days
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSpecialDaysTab() {
    final sc = SemanticColors.of(context);
    if (_specialDaysError != null)
      return _buildErrorBanner(_specialDaysError!, _loadAll);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Info Banner ──────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sc.primary.withOpacity(.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sc.primary.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_rounded,
                    color: sc.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Days — Holidays',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: sc.primary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Define holidays by date, weekday and profile. '
                      'Special Days take highest priority over Season and Week Profiles.',
                      style: TextStyle(fontSize: 12, color: sc.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── Two-panel body ───────────────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT panel – form
              SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                  child: _card(child: _spFormPanel()),
                ),
              ),
              // RIGHT panel – table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                  child: _card(child: _spTablePanel()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── LEFT panel – Holiday input form ───────────────────────────────────────

  Widget _spFormPanel() {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: _sectionHeader(
              Icons.add_circle_outline, sc.primary, 'Holiday Details'),
        ),
        const SizedBox(height: 16),
        // Fields
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Year
                Text('Year',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc.onSurfaceVariant)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  key: const Key(CalendarProfilesKeys.spYearDropdown),
                  value: _spFormYear,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: List.generate(
                    26,
                    (i) => DropdownMenuItem(
                      value: 2020 + i,
                      child: Text('${2020 + i}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _spFormYear = v ?? _spFormYear),
                ),
                const SizedBox(height: 12),
                // Month
                Text('Month',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc.onSurfaceVariant)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  key: const Key(CalendarProfilesKeys.spMonthDropdown),
                  value: _spFormMonth,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${(i + 1).toString().padLeft(2, '0')} — ${_monthName(i + 1)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _spFormMonth = v ?? _spFormMonth),
                ),
                const SizedBox(height: 12),
                // Day
                Text('Day',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc.onSurfaceVariant)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  key: const Key(CalendarProfilesKeys.spDayDropdown),
                  value: _spFormDay,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: List.generate(
                    31,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        (i + 1).toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _spFormDay = v ?? _spFormDay),
                ),
                const SizedBox(height: 12),
                // Week Day
                Text('Week Day',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc.onSurfaceVariant)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  key: const Key(CalendarProfilesKeys.spWeekdayDropdown),
                  value: _spFormWeekDay,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: List.generate(
                    7,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${(i + 1).toString().padLeft(2, '0')} — ${_dayName(i + 1)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _spFormWeekDay = v ?? _spFormWeekDay),
                ),
                const SizedBox(height: 12),
                // Profile
                Text('Profile',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sc.onSurfaceVariant)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  key: const Key(CalendarProfilesKeys.spProfileDropdown),
                  value: _spFormProfile,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: List.generate(
                    16,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _spFormProfile = v ?? _spFormProfile),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        // Add / Remove actions
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                key: const Key(CalendarProfilesKeys.specialDayAddBtn),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add holiday to list'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sc.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isConnected ? _spAddEntry : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                key: const Key(CalendarProfilesKeys.specialDayRemoveBtn),
                icon: const Icon(Icons.remove_circle_outline, size: 16),
                label: const Text('Remove holiday from list'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isConnected && _spSelectedIndex != null)
                      ? sc.error
                      : sc.outline,
                  foregroundColor: (_isConnected && _spSelectedIndex != null)
                      ? Colors.white
                      : sc.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: (_isConnected && _spSelectedIndex != null)
                    ? _spRemoveSelected
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RIGHT panel – Holidays table ──────────────────────────────────────────

  Widget _spTablePanel() {
    final sc = SemanticColors.of(context);
    final entries = _specialDays.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Read / Write
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: _sectionHeader(
                    Icons.list_alt, sc.primary, 'Holidays List'),
              ),
              _actionBtn(
                key: const Key(CalendarProfilesKeys.specialDaysWriteBtn),
                icon: Icons.edit,
                label: 'Write',
                color: const Color(0xFF1976D2),
                onPressed:
                    _specialDays.entries.isNotEmpty ? _saveSpecialDays : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Column headers
        Container(
          decoration: BoxDecoration(
            color: sc.surfaceVariant,
            border: Border(
              top: BorderSide(color: sc.outline),
              bottom: BorderSide(color: sc.outline),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('Date Holiday (dd/MM/yyyy)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              Expanded(
                flex: 2,
                child: Text('Week Day',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
              Expanded(
                flex: 2,
                child: Text('Profile',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sc.onSurfaceVariant)),
              ),
            ],
          ),
        ),
        // Rows
        Expanded(
          child: entries.isEmpty
              ? _emptyPlaceholder(
                  'No holidays defined.\nFill the form and tap "Add holiday to list".')
              : ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: sc.outline),
                  itemBuilder: (ctx, i) {
                    final e = entries[i];
                    final selected = _spSelectedIndex == i;
                    final d = e.specialDayDate;
                    final dateStr =
                        '${d.dayOfMonth.toString().padLeft(2, '0')}/'
                        '${d.month.toString().padLeft(2, '0')}/'
                        '${d.year == 65535 ? '****' : d.year.toString().padLeft(4, '0')}';
                    final wdStr = (d.dayOfWeek >= 1 && d.dayOfWeek <= 7)
                        ? d.dayOfWeek.toString().padLeft(2, '0')
                        : '--';

                    return InkWell(
                      onTap: () => setState(() {
                        if (_spSelectedIndex == i) {
                          // Deselect on second tap
                          _spSelectedIndex = null;
                        } else {
                          _spSelectedIndex = i;
                          // Populate form from selected entry
                          _spFormYear = (d.year >= 2020 && d.year <= 2045)
                              ? d.year
                              : DateTime.now().year;
                          _spFormMonth =
                              (d.month >= 1 && d.month <= 12) ? d.month : 1;
                          _spFormDay = (d.dayOfMonth >= 1 && d.dayOfMonth <= 31)
                              ? d.dayOfMonth
                              : 1;
                          _spFormWeekDay =
                              (d.dayOfWeek >= 1 && d.dayOfWeek <= 7)
                                  ? d.dayOfWeek
                                  : 1;
                          _spFormProfile =
                              (e.dayId >= 1 && e.dayId <= 16) ? e.dayId : 1;
                        }
                      }),
                      child: Container(
                        color: selected ? sc.surfaceVariant : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: selected ? sc.primary : null,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                wdStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected ? sc.primary : sc.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${e.dayId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected ? sc.primary : sc.info,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Special Day helpers & actions ─────────────────────────────────────────

  /// Returns YYYY-MM-DD formatted date from a CalendarDateValue.
  String _fmtSpDate(CalendarDateValue d) {
    if (d.year == 0 && d.month == 0 && d.dayOfMonth == 0) return '----/--/--';
    final y = d.year == 65535 ? '****' : d.year.toString().padLeft(4, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final dy = d.dayOfMonth.toString().padLeft(2, '0');
    return '$y-$mo-$dy';
  }

  /// Add a new holiday from the current form values.
  void _spAddEntry() {
    // Reject duplicates on the same date.
    final duplicate = _specialDays.entries.any((e) =>
        e.specialDayDate.year == _spFormYear &&
        e.specialDayDate.month == _spFormMonth &&
        e.specialDayDate.dayOfMonth == _spFormDay);
    if (duplicate) {
      _snack('A holiday for this date already exists.');
      return;
    }
    final newIdx = _specialDays.entries.isEmpty
        ? 0
        : _specialDays.entries
                .map((e) => e.index)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final newEntry = SpecialDayEntry()
      ..index = newIdx
      ..specialDayDate = (CalendarDateValue()
        ..year = _spFormYear
        ..month = _spFormMonth
        ..dayOfMonth = _spFormDay
        ..dayOfWeek = _spFormWeekDay)
      ..dayId = _spFormProfile;
    setState(() {
      _specialDays.entries.add(newEntry);
      _spSelectedIndex = _specialDays.entries.length - 1;
    });
    _snack('Holiday added.');
  }

  /// Remove the currently selected holiday from the list.
  void _spRemoveSelected() {
    final idx = _spSelectedIndex;
    if (idx == null || idx >= _specialDays.entries.length) return;
    setState(() {
      _specialDays.entries.removeAt(idx);
      _spSelectedIndex = null;
    });
    _snack('Holiday removed.');
  }

  Future<void> _saveSpecialDays() async {
    setState(() {
      _loading = true;
    });
    try {
      final ok = await _client.setPassiveSpecialDays(_specialDays);
      if (!mounted) return;
      if (ok) {
        await _showWriteSuccess();
      } else {
        _showWriteError(
          title: 'Write Failed',
          detail: 'The meter returned failure (BoolValue = false).\n\n'
              'Check that all entries are valid and the session has SET rights.',
        );
      }
    } on GrpcError catch (e) {
      if (!mounted) return;
      _showWriteError(
        title: 'gRPC Error ${e.code}',
        detail: 'Code : ${e.code} (${e.codeName})\n'
            'Message: ${e.message ?? "(none)"}',
      );
    } catch (e) {
      if (mounted)
        _showWriteError(title: 'Unexpected Error', detail: e.toString());
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsets? margin}) {
    final sc = SemanticColors.of(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: sc.surface,
        border:
            Border.all(color: sc.outline),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 4)],
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  Widget _sectionHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _emptyPlaceholder(String msg) {
    final sc = SemanticColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear,
              color: sc.outline, size: 36),
          const SizedBox(height: 8),
          Text(msg,
              style: TextStyle(
                  color: sc.onSurfaceVariant,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final sc = SemanticColors.of(context);
    final display = value.trim().isEmpty ? '--' : value;
    final secColor = sc.onSurfaceVariant;
    return Row(
      children: [
        SizedBox(
            width: 110,
            child:
                Text(label, style: TextStyle(fontSize: 12, color: secColor))),
        Expanded(
            child: Text(display,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: display == '--' ? secColor : sc.onSurface))),
      ],
    );
  }

  /// A styled read-only display box for a single field value.
  Widget _datePickerField({
    required DateTime date,
    required ValueChanged<DateTime> onPicked,
    String? note,
  }) {
    final sc = SemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2060),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sc.primary.withOpacity(.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: sc.primary),
                const SizedBox(width: 10),
                Text(
                  '${date.day.toString().padLeft(2, '0')} '
                  '${_monthName(date.month)} '
                  '${date.year}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sc.primary),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down,
                    color: sc.primary.withOpacity(.6)),
              ],
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note, style: TextStyle(fontSize: 10, color: sc.onSurfaceVariant)),
        ],
      ],
    );
  }

  Widget _infoDisplayBox(String value, {String? note}) {
    final sc = SemanticColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: sc.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: sc.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(note, style: TextStyle(fontSize: 10, color: sc.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }

  Widget _numField(String label, int value, void Function(int) onChanged) {
    final ctrl = TextEditingController(text: '$value');
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, isDense: true),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final i = int.tryParse(v);
        if (i != null) onChanged(i);
      },
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onPressed, {Key? key}) {
    final sc = SemanticColors.of(context);
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        key: key,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: sc.outline),
        ),
        child: Icon(icon, size: 18, color: sc.primary),
      ),
    );
  }

  Widget _primaryBtn(
      {required IconData icon,
      required String label,
      required VoidCallback? onPressed,
      Key? key}) {
    return ElevatedButton.icon(
      key: key,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF1976D2)),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _outlinedBtn(BuildContext context,
      {required String label,
      IconData? icon,
      Key? key,
      required VoidCallback? onPressed}) {
    final sc = SemanticColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnColor = isDark ? Colors.white : sc.primary;
    return OutlinedButton.icon(
      key: key,
      icon: Icon(icon ?? Icons.check, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: btnColor,
        side: BorderSide(color: btnColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    Key? key,
  }) {
    final isConnected = ref.read(appControllerProvider).isConnected;
    return ElevatedButton.icon(
      key: key,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: isConnected ? onPressed : null,
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[m];
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }
}
