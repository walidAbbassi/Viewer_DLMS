

MapEntry<String, String>? parseSingleElement(String xml) {
  // Accepte éventuellement des attributs après le nom de tag, ex: <tag attr="...">
  // Groupes :
  // 1: nom du tag
  // 2: (facultatif) chaîne d'attributs
  // 3: contenu entre balises
  final pattern = RegExp(
    r'<\s*([A-Za-z_][A-Za-z0-9._-]*)\b[^>]*>(.*?)<\s*/\s*\1\s*>',
    dotAll: true,
  );

  final m = pattern.firstMatch(xml);
  if (m == null) return null;

  final tag = m.group(1)!;
  final value = _xmlUnescape(m.group(2) ?? '');
  return MapEntry(tag, value);
}


/// Decodes common XML entities (&amp; &lt; &gt; &quot; &apos;)
/// and numeric entities (e.g., &#169; or &#xA9;).
String _xmlUnescape(String s) {
  if (s.isEmpty) return s;

  // First handle the five predefined XML entities.
  var out = s
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&'); // NOTE: do &amp; last to avoid double-unescaping

  // Then handle numeric character references: &#DDD; or &#xHHH;
  // We use a RegExp and replaceAllMapped.
  final numericEntity = RegExp(r'&#(x?[0-9A-Fa-f]+);');
  out = out.replaceAllMapped(numericEntity, (m) {
    final raw = m.group(1)!;
    try {
      final codePoint = raw.startsWith('x') || raw.startsWith('X')
          ? int.parse(raw.substring(1), radix: 16)
          : int.parse(raw, radix: 10);
      return String.fromCharCode(codePoint);
    } catch (_) {
      // If parsing fails, keep the original entity
      return m.group(0)!;
    }
  });

  return out;
}
