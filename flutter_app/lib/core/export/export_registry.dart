import 'package:flutter/material.dart';

/// Descriptor stored in [ExportRegistry] for every exportable page.
class ExportedPageInfo {
  const ExportedPageInfo({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    this.tokens = const {},
  });

  /// Must match [ExportablePage.exportPageId].
  final String id;

  /// Human-readable label.
  final String label;

  /// Icon shown in [TemplateConfigPage].
  final IconData icon;

  /// Factory that creates a fresh navigable [Widget] instance.
  final WidgetBuilder builder;

  /// Tokens available in export templates for this page.
  /// Key = token path (e.g. `'name'`, `'deviceId.*'`),
  /// Value = human-readable description.
  final Map<String, String> tokens;
}

/// Singleton registry that collects all exportable pages.
///
/// Call [register] once per page (typically in `main.dart`) before the app
/// renders. Use [availablePages] to list them and [build] to instantiate one.
class ExportRegistry {
  ExportRegistry._();

  static final ExportRegistry instance = ExportRegistry._();

  final List<ExportedPageInfo> _pages = [];

  // --------------------------------------------------------------------------

  /// Register a page descriptor.
  /// Safe to call multiple times; duplicate ids are silently ignored.
  void register(ExportedPageInfo info) {
    final alreadyRegistered = _pages.any((p) => p.id == info.id);
    if (!alreadyRegistered) {
      _pages.add(info);
    }
  }

  /// Ordered list of all registered pages. Unmodifiable.
  List<ExportedPageInfo> get availablePages => List.unmodifiable(_pages);

  /// Creates and returns the navigable [Widget] for [id], or `null` if unknown.
  Widget? build(BuildContext context, String id) {
    final info = _findById(id);
    return info?.builder(context);
  }

  ExportedPageInfo? _findById(String id) {
    try {
      return _pages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears all registrations (useful for tests).
  void reset() => _pages.clear();
}
