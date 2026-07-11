/// Holds device ID key-value pairs retrieved from the meter.
///
/// Keys are normalised (spaces replaced with underscores) so they are safe
/// to use as XML element names, CSV column headers, etc.
///
/// Lives as a static singleton – survives page navigation just like
/// [Class7Cache] – and is populated by [DeviceIdPage] on successful read.
class DeviceIdCache {
  static Map<String, String> _data = {};

  /// Unmodifiable snapshot of the currently cached device ID fields.
  static Map<String, String> get data => Map.unmodifiable(_data);

  /// Stores [values], normalising every key by replacing spaces with `_`.
  static void set(Map<String, String> values) {
    _data = {
      for (final e in values.entries)
        e.key.replaceAll(' ', '_'): e.value,
    };
  }

  /// Clears all cached data (call on disconnect).
  static void clear() => _data = {};
}
