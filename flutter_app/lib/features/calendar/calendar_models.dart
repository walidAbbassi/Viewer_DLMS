import 'package:flutter/material.dart';

// --- MODELS ---

class DayProfile {
  DayProfile({
    required this.id,
    required this.name,
    required this.slots,
  });

  final int id;
  String name;
  final List<DaySlot> slots;
}

class DaySlot {
  DaySlot({
    required this.startHour,
    required this.endHour,
    required this.label,
    required this.tariff,
  });

  int startHour;
  int endHour;
  String label;
  String tariff; // e.g., T1/T2/T3
}

class WeekProfile {
  WeekProfile({
    required this.id,
    required this.name,
    required this.dayProfileIds,
  });

  final int id;
  String name;
  final Map<int, int> dayProfileIds; // weekday -> dayProfileId
}

class SeasonProfile {
  SeasonProfile({
    required this.id,
    required this.name,
    required this.start,
    required this.weekProfileId,
  });

  final int id;
  String name;
  DateTime start;
  int weekProfileId;
}

class SpecialDay {
  SpecialDay({
    required this.id,
    required this.date,
    required this.name,
    required this.dayProfileId,
  });

  final int id;
  DateTime date;
  String name;
  int dayProfileId;

  static SpecialDay none() => SpecialDay(
        id: -1,
        date: DateTime(1970),
        name: '-',
        dayProfileId: -1,
      );
}

// --- EXTENSIONS ---

extension CalendarColorShade on Color {
  Color darken([double amount = .25]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}








