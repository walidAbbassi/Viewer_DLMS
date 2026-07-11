import 'dart:typed_data';

Uint8List hexToBytes(String hex, {bool allowSeparators = true}) {
  final cleaned = allowSeparators
      ? hex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '')
      : hex.trim();
  if (cleaned.isEmpty) return Uint8List(0);
  if (cleaned.length.isOdd) {
    // if odd length, left-pad a '0'
    return hexToBytes('0$cleaned', allowSeparators: false);
  }
  final out = Uint8List(cleaned.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(cleaned.substring(2 * i, 2 * i + 2), radix: 16);
  }
  return out;
}

bool isHex(String s) => RegExp(r'^[0-9A-Fa-f\s:._-]+$').hasMatch(s);
