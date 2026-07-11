import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

// =============================================================================
//  Profile Status Bitmask — DLMS/COSEM Blue Book (IEC 62056)
//
//  Byte layout (LSB → MSB):
//    Bit 0 : PDN  – Power Down
//    Bit 1 : (reserved)
//    Bit 2 : CAD  – Clock Adjusted
//    Bit 3 : (reserved)
//    Bit 4 : DST  – Daylight Saving Time
//    Bit 5 : DNV  – Data Not Valid
//    Bit 6 : CIV  – Clock Invalid
//    Bit 7 : ERR  – Error
// =============================================================================

// ──────────────────────────── Model ────────────────────────────

class ProfileStatusInfo {
  final String name;
  final Color color;
  final String tooltip;

  const ProfileStatusInfo({
    required this.name,
    required this.color,
    required this.tooltip,
  });
}

// ──────────────────────────── Flags registry ────────────────────────────

class ProfileStatusFlags {
  static final Map<String, ProfileStatusInfo> _flags = {
    'PDN': ProfileStatusInfo(
      name: 'Power Down',
      color: DesignTokens.danger,
      tooltip:
          'PDN – Power Down\nBit 0 ',
    ),
    'CAD': ProfileStatusInfo(
      name: 'Clock Adjusted',
      color: DesignTokens.info,
      tooltip:
          'CAD – Clock Adjusted\nBit 2',
    ),
    'DST': ProfileStatusInfo(
      name: 'Daylight Saving Time',
      color: const Color(0xFF9C27B0),
      tooltip:
          'DST – Daylight Saving Time\nBit 4',
    ),
    'DNV': ProfileStatusInfo(
      name: 'Data Not Valid',
      color: DesignTokens.warning,
      tooltip:
          'DNV – Data Not Valid\nBit 5',
    ),
    'CIV': ProfileStatusInfo(
      name: 'Clock Invalid',
      color: const Color(0xFFFF5722),
      tooltip:
          'CIV – Clock Invalid\nBit 6',
    ),
    'ERR': ProfileStatusInfo(
      name: 'Error',
      color: const Color(0xFF757575),
      tooltip:
          'ERR – Error\nBit 7',
    ),
  };

  /// All known flag keys (PDN, CAD, DST, DNV, CIV, ERR).
  static List<String> get allKeys => _flags.keys.toList();

  /// Returns info for a given flag key, or a grey fallback for unknown flags.
  static ProfileStatusInfo getInfo(String flag) {
    return _flags[flag] ??
        ProfileStatusInfo(
          name: flag,
          color: Colors.grey,
          tooltip: 'Unknown flag',
        );
  }
}

// ──────────────────────────── Decode logic ────────────────────────────

/// Decodes a DLMS Profile Status byte into a list of active flag keys.
///
/// Example: `decodeProfileStatusBitmask(136)` → `['ERR']`  (136 = 0x88 → bit 3 reserved + bit 7)
List<String> decodeProfileStatusBitmask(int value) {
  return [
    if (value & (1 << 0) != 0) 'PDN',
    if (value & (1 << 2) != 0) 'CAD',
    if (value & (1 << 4) != 0) 'DST',
    if (value & (1 << 5) != 0) 'DNV',
    if (value & (1 << 6) != 0) 'CIV',
    if (value & (1 << 7) != 0) 'ERR',
  ];
}

// ──────────────────────────── Column detection ────────────────────────────

/// Scans a list of column headers and returns the index of the first one
/// whose name contains both "profile" and "status" (case-insensitive).
///
/// Returns -1 if no match is found.
int findProfileStatusColumnIndex(List<String> headers) {
  for (int i = 0; i < headers.length; i++) {
    final lower = headers[i].toLowerCase();
    if (lower.contains('profile') && (lower.contains('status') || lower.contains('code'))) {
      return i;
    }
  }
  return -1;
}

// ──────────────────────────── Widgets ────────────────────────────

/// Colored badge for a single Profile Status flag (e.g. "PDN" in red).
class ProfileStatusBadge extends StatelessWidget {
  final String flag;

  const ProfileStatusBadge({super.key, required this.flag});

  @override
  Widget build(BuildContext context) {
    final info = ProfileStatusFlags.getInfo(flag);

    return Tooltip(
      message: info.tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: info.color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          flag,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Full cell widget: parses raw string value, decodes the bitmask,
/// renders colored badges or a green "OK" if no flags are set.
class ProfileStatusCell extends StatelessWidget {
  final String value;

  const ProfileStatusCell({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final statusValue = int.tryParse(value);
    if (statusValue == null) {
      return Text(value);
    }

    final activeFlags = decodeProfileStatusBitmask(statusValue);

    if (activeFlags.isEmpty) {
      return const Text(
        'OK',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: activeFlags.map((f) => ProfileStatusBadge(flag: f)).toList(),
    );
  }
}
