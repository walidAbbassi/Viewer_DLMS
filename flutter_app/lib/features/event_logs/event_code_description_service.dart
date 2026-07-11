import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Singleton service that loads event-code → description mappings from
/// `assets/config/event_code_descriptions.json`.
///
/// Usage:
/// ```dart
/// await EventCodeDescriptionService.instance.load();
/// final desc = EventCodeDescriptionService.instance.describe(21);
/// // → "End of nn-peridic billing interval (optinal)"
/// ```
class EventCodeDescriptionService {
  EventCodeDescriptionService._();
  static final EventCodeDescriptionService instance =
      EventCodeDescriptionService._();

  static const String _assetPath =
      'assets/config/event_code_descriptions.json';

  Map<String, String> _codes = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Loads the JSON mapping from assets. No-op if already loaded unless
  /// [force] is `true`.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final Map<String, dynamic> codesMap =
          jsonData['eventCodes'] as Map<String, dynamic>? ?? {};
      _codes = codesMap.map((key, value) {
        final String desc;
        if (value is String) {
          desc = value;
        } else if (value is Map<String, dynamic>) {
          desc = value['description'] as String? ?? '';
        } else {
          desc = '';
        }
        return MapEntry(key, desc);
      });
      _loaded = true;
    } catch (e) {
      // Graceful degradation — raw code shown in table if file unavailable.
      debugPrint('[EventCodeDescriptionService] Failed to load $_assetPath: $e');
      _codes = {};
      _loaded = false;
    }
  }

  /// Returns the description for [code], or `'Unknown event code <code>'`.
  String describe(int code) =>
      _codes[code.toString()] ?? 'Unknown event code $code';

  /// Convenience for table cells: formats a raw string value.
  /// Returns `'<description> (<code>)'` when parseable, otherwise the raw value.
  String formatCell(String value) {
    final code = int.tryParse(value);
    if (code == null) return value;
    return '${describe(code)} ($code)';
  }
}
