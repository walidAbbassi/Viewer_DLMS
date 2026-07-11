// lib/any_value_decoder.dart
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' show Any;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' show Value, ListValue, Struct,Value_Kind;

class AnyValueDecoder {
  /// Unpack an `Any` expected to contain `google.protobuf.Value`
  /// and convert it to native Dart (List/Map/double/bool/String/null).
  static dynamic fromAny(Any any) {
    final v = Value();

    // If typeUrl is present and mismatched, fail early.
    if (any.typeUrl.isNotEmpty &&
        any.typeUrl != 'type.googleapis.com/google.protobuf.Value') {
      return any.value;
    }

    // Prefer the official unpack; fall back to direct merge if necessary.
    if (any.canUnpackInto(v)) {
      any.unpackInto(v);
    } else {
      v.mergeFromBuffer(any.value);
    }
    return _valueToDart(v);
  }

  /// Optional: coerce doubles with no fractional part into ints, recursively.
  static dynamic coerceNumbers(dynamic x) {
    if (x is double) {
      final i = x.toInt();
      return (i.toDouble() == x) ? i : x;
    }
    if (x is List) return x.map(coerceNumbers).toList();
    if (x is Map<String, dynamic>) {
      return x.map((k, v) => MapEntry(k, coerceNumbers(v)));
    }
    return x;
  }

  // ---- internals ----

  static dynamic _valueToDart(Value v) {
    switch (v.whichKind()) {
      case Value_Kind.nullValue:
        return null;
      case Value_Kind.numberValue:
        return v.numberValue; // always double in google.protobuf.Value
      case Value_Kind.stringValue:
        final s = v.stringValue;
        // If you encode raw bytes as "base64:<...>", decode automatically.
        if (s.startsWith('base64:')) {
          final b64 = s.substring('base64:'.length);
          return convert.base64.decode(b64); // Uint8List
        }
        return s;
      case Value_Kind.boolValue:
        return v.boolValue;
      case Value_Kind.structValue:
        return _structToMap(v.structValue);
      case Value_Kind.listValue:
        return _listToList(v.listValue);
      case Value_Kind.notSet:
        return null;
    }
  }

  static Map<String, dynamic> _structToMap(Struct s) {
    final out = <String, dynamic>{};
    s.fields.forEach((k, val) => out[k] = _valueToDart(val));
    return out;
  }

  static List<dynamic> _listToList(ListValue lv) {
    return lv.values.map(_valueToDart).toList();
  }
}
