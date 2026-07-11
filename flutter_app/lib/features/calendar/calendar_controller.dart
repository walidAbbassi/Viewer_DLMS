import 'dart:math';

import 'package:flutter/material.dart';

import 'calendar_models.dart';

/// Holds all in-memory state and business logic for Calendar & Profiles.
/// The widget layer is responsible only for calling these methods inside
/// setState() and for wiring TextEditingController / UI concerns.
class CalendarProfilesController {
  // --- Core collections (in-memory dataset) ---

  final List<DayProfile> dayProfiles = [
    DayProfile(
      id: 1,
      name: 'Base',
      slots: [
        DaySlot(startHour: 0, endHour: 7, label: 'Off-Peak', tariff: 'T1'),
        DaySlot(startHour: 7, endHour: 19, label: 'Day', tariff: 'T2'),
        DaySlot(startHour: 19, endHour: 24, label: 'Peak', tariff: 'T3'),
      ],
    ),
  ];

  final List<WeekProfile> weekProfiles = [
    WeekProfile(
      id: 1,
      name: 'Standard',
      dayProfileIds: {
        DateTime.monday: 1,
        DateTime.tuesday: 1,
        DateTime.wednesday: 1,
        DateTime.thursday: 1,
        DateTime.friday: 1,
        DateTime.saturday: 1,
        DateTime.sunday: 1,
      },
    ),
  ];

  final List<SeasonProfile> seasons = [
    SeasonProfile(
      id: 1,
      name: 'Winter',
      start: DateTime(DateTime.now().year, 1, 1),
      weekProfileId: 1,
    ),
  ];

  final List<SpecialDay> specialDays = [
    SpecialDay(
      id: 1,
      date: DateTime(DateTime.now().year, 12, 25),
      name: 'Noel',
      dayProfileId: 1,
    ),
  ];

  // --- UI-related state (but still pure data) ---

  DateTime focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  DayProfile? editingDayProfile;
  WeekProfile? editingWeekProfile;
  SeasonProfile? editingSeason;
  SpecialDay? editingSpecialDay;

  // --- CRUD: Day Profiles ---

  void addDayProfile() {
    final nextId =
        (dayProfiles.map((e) => e.id).fold<int>(0, max)) + 1;
    final profile = DayProfile(
      id: nextId,
      name: 'Day$nextId',
      slots: [],
    );
    dayProfiles.add(profile);
    editingDayProfile = profile;
  }

  void editDayProfile(DayProfile profile) {
    editingDayProfile = profile;
  }

  /// Returns `false` if the operation is not allowed (at least one required).
  bool deleteDayProfile(DayProfile profile) {
    if (dayProfiles.length == 1) {
      return false;
    }
    dayProfiles.remove(profile);
    if (editingDayProfile == profile) {
      editingDayProfile = null;
    }
    return true;
  }

  // --- CRUD: Week Profiles ---

  void addWeekProfile() {
    final nextId =
        (weekProfiles.map((e) => e.id).fold<int>(0, max)) + 1;
    final firstDayId = dayProfiles.first.id;
    final week = WeekProfile(
      id: nextId,
      name: 'Week$nextId',
      dayProfileIds: {
        DateTime.monday: firstDayId,
        DateTime.tuesday: firstDayId,
        DateTime.wednesday: firstDayId,
        DateTime.thursday: firstDayId,
        DateTime.friday: firstDayId,
        DateTime.saturday: firstDayId,
        DateTime.sunday: firstDayId,
      },
    );
    weekProfiles.add(week);
    editingWeekProfile = week;
  }

  void editWeekProfile(WeekProfile week) {
    editingWeekProfile = week;
  }

  bool deleteWeekProfile(WeekProfile week) {
    if (weekProfiles.length == 1) {
      return false;
    }
    weekProfiles.remove(week);
    if (editingWeekProfile == week) {
      editingWeekProfile = null;
    }
    return true;
  }

  // --- CRUD: Seasons ---

  void addSeason() {
    final nextId =
        (seasons.map((e) => e.id).fold<int>(0, max)) + 1;
    final s = SeasonProfile(
      id: nextId,
      name: 'Season$nextId',
      start: DateTime(DateTime.now().year, focusedMonth.month, 1),
      weekProfileId: weekProfiles.first.id,
    );
    seasons.add(s);
    editingSeason = s;
  }

  void editSeason(SeasonProfile season) {
    editingSeason = season;
  }

  bool deleteSeason(SeasonProfile season) {
    if (seasons.length == 1) {
      return false;
    }
    seasons.remove(season);
    if (editingSeason == season) {
      editingSeason = null;
    }
    return true;
  }

  // --- CRUD: Special Days ---

  void addSpecialDay() {
    final nextId =
        (specialDays.map((e) => e.id).fold<int>(0, max)) + 1;
    final sd = SpecialDay(
      id: nextId,
      date: DateTime.now(),
      name: 'Special$nextId',
      dayProfileId: dayProfiles.first.id,
    );
    specialDays.add(sd);
    editingSpecialDay = sd;
  }

  void editSpecialDay(SpecialDay day) {
    editingSpecialDay = day;
  }

  void deleteSpecialDay(SpecialDay day) {
    specialDays.remove(day);
    if (editingSpecialDay == day) {
      editingSpecialDay = null;
    }
  }

  // --- Date helpers ---

  SeasonProfile? findSeason(DateTime date) {
    if (seasons.isEmpty) return null;
    final sorted = [...seasons]..sort((a, b) => a.start.compareTo(b.start));
    SeasonProfile? current;
    for (final s in sorted) {
      if (!date
          .isBefore(DateTime(s.start.year, s.start.month, s.start.day))) {
        current = s;
      } else {
        break;
      }
    }
    return current;
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }

  // --- Colors ---

  Color seasonColor(int id) {
    const palette = [
      Color(0xFF1E88E5), // blue
      Color(0xFF43A047), // green
      Color(0xFFFB8C00), // orange
      Color(0xFF8E24AA), // purple
      Color(0xFF6D4C41), // brown
      Color(0xFF00897B), // teal
    ];
    return palette[(id - 1) % palette.length];
  }
}








