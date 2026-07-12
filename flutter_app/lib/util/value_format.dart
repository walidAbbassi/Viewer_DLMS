/// Formats a numeric meter value for display: `—` when it hasn't been read
/// yet (`raw == null`), otherwise the value with its resolved unit — never
/// a placeholder like "0 unknown" leaking into the UI.
///
/// [decimals], when given, fixes the number of decimal places (matching the
/// meter's scaler); omit it for integer-scaled values.
String formatValue(num? raw, String? unit, {int? decimals}) {
  if (raw == null) return '—';
  final valueText =
      decimals != null ? raw.toStringAsFixed(decimals) : '$raw';
  final unitText = (unit ?? '').trim();
  return unitText.isEmpty ? valueText : '$valueText $unitText';
}
