import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../grpc/generated/meter.pb.dart';

/// In-memory cache of the last successfully loaded Activity Calendar data.
/// Survives page navigation and disconnection so the user never loses their
/// last-seen / last-programmed state.
class CalendarCache {
  final ActivityCalendarData? activeCalendar;
  final ActivityCalendarData? passiveCalendar;
  final SpecialDayTable?      activeSpecialDays;
  final SpecialDayTable?      passiveSpecialDays;

  const CalendarCache({
    this.activeCalendar,
    this.passiveCalendar,
    this.activeSpecialDays,
    this.passiveSpecialDays,
  });

  bool get hasData =>
      activeCalendar != null || passiveCalendar != null ||
      activeSpecialDays != null || passiveSpecialDays != null;

  CalendarCache withUpdates({
    ActivityCalendarData? activeCalendar,
    ActivityCalendarData? passiveCalendar,
    SpecialDayTable?      activeSpecialDays,
    SpecialDayTable?      passiveSpecialDays,
  }) =>
      CalendarCache(
        activeCalendar:   activeCalendar   ?? this.activeCalendar,
        passiveCalendar:  passiveCalendar  ?? this.passiveCalendar,
        activeSpecialDays:  activeSpecialDays  ?? this.activeSpecialDays,
        passiveSpecialDays: passiveSpecialDays ?? this.passiveSpecialDays,
      );
}

class CalendarCacheNotifier extends StateNotifier<CalendarCache> {
  static File? _storageFile;

  CalendarCacheNotifier() : super(const CalendarCache()) {
    _initStorage();
    _loadFromDisk();
  }

  // ── Disk persistence ──────────────────────────────────────────────────────

  static void _initStorage() {
    if (_storageFile != null) return;
    try {
      final base = Platform.environment['LOCALAPPDATA']   // Windows
                ?? Platform.environment['XDG_DATA_HOME']  // Linux
                ?? Platform.environment['HOME']           // Linux / macOS
                ?? '.';
      final dir = Directory('$base${Platform.pathSeparator}ViewerNG');
      dir.createSync(recursive: true);
      _storageFile = File(
          '${dir.path}${Platform.pathSeparator}passive_calendar.json');
    } catch (e) {
      print('[CalendarCache] Storage init failed: $e');
    }
  }

  void _loadFromDisk() {
    try {
      if (_storageFile == null || !_storageFile!.existsSync()) return;
      final raw = _storageFile!.readAsStringSync();
      if (raw.isEmpty) return;
      final cal = ActivityCalendarData()..mergeFromJson(raw);
      state = state.withUpdates(passiveCalendar: cal);
      print('[CalendarCache] Restored passive calendar from disk '
            '(${cal.dayProfiles.length} day, '
            '${cal.weekProfiles.length} week, '
            '${cal.seasonProfiles.length} season profiles)');
    } catch (e) {
      print('[CalendarCache] Could not restore from disk: $e');
    }
  }

  void _saveToDisk(ActivityCalendarData data) {
    try {
      _storageFile?.writeAsStringSync(data.writeToJson());
    } catch (e) {
      print('[CalendarCache] Disk save failed: $e');
    }
  }

  /// Persist the current in-memory passive calendar to disk immediately.
  /// Call this after local structural edits (add / remove profile / slot) so
  /// that un-written changes also survive a disconnect + relaunch.
  void flushPassive() {
    final cal = state.passiveCalendar;
    if (cal != null) _saveToDisk(cal);
  }

  // ── State update ──────────────────────────────────────────────────────────

  /// Update one or more cached calendars (null arguments keep existing values).
  /// Automatically persists the passive calendar to disk when provided.
  void update({
    ActivityCalendarData? activeCalendar,
    ActivityCalendarData? passiveCalendar,
    SpecialDayTable?      activeSpecialDays,
    SpecialDayTable?      passiveSpecialDays,
  }) {
    state = state.withUpdates(
      activeCalendar:    activeCalendar,
      passiveCalendar:   passiveCalendar,
      activeSpecialDays:  activeSpecialDays,
      passiveSpecialDays: passiveSpecialDays,
    );
    if (passiveCalendar != null) {
      _saveToDisk(passiveCalendar);
    }
  }

  void clear() => state = const CalendarCache();
}

final calendarCacheProvider =
    StateNotifierProvider<CalendarCacheNotifier, CalendarCache>(
  (ref) => CalendarCacheNotifier(),
);
