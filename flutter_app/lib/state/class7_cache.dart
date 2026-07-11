/// Holds cached Class 7 (Profile Generic) buffer data for a single object.
class Class7CacheEntry {
  final List<String> headers;
  final List<List<String>> data;
  Class7CacheEntry({required this.headers, required this.data});
}

/// Global in-memory cache for Class 7 data.
///
/// Survives page navigation (pages are disposed/recreated on route change)
/// because the cache lives in a static [Map], not in widget state.
class Class7Cache {
  static final Map<String, Class7CacheEntry> _store = {};

  /// Returns cached data for [objectName], or `null` if not cached.
  static Class7CacheEntry? get(String objectName) => _store[objectName];

  /// Stores (or replaces) the cached data for [objectName].
  static void put(
      String objectName, List<String> headers, List<List<String>> data) {
    _store[objectName] = Class7CacheEntry(headers: headers, data: data);
  }

  /// Removes a single entry.
  static void invalidate(String objectName) => _store.remove(objectName);

  /// Clears all cached data (e.g. on disconnect).
  static void clear() => _store.clear();
}
