import 'dart:typed_data';
import 'dart:convert' show base64;
import 'package:fixnum/fixnum.dart' as $i64;

import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $any;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $w;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $s;
import 'package:protobuf/protobuf.dart' show GeneratedMessage;

/// Build an Any from a generated protobuf message (compatible with protobuf 4.x).
$any.Any _anyFromMessage(GeneratedMessage msg, {String prefix = 'type.googleapis.com'}) {
  // In protobuf 4.x, BuilderInfo has `qualifiedMessageName`
  final fullName = msg.info_.qualifiedMessageName; // e.g. "google.protobuf.StringValue"
  return $any.Any()
    ..typeUrl = '$prefix/$fullName'
    ..value = msg.writeToBuffer();
}

/// Dart value -> google.protobuf.Any (recursive), without using Any.pack()
$any.Any dartToAny(dynamic v) {
  // null -> google.protobuf.Value(null)
  if (v == null) {
    final val = $s.Value()..nullValue = $s.NullValue.NULL_VALUE;
    return _anyFromMessage(val);
  }

  // bytes (top-level) -> BytesValue
  if (v is Uint8List) {
    return _anyFromMessage($w.BytesValue()..value = v);
  }
  if (v is List<int>) {
    return _anyFromMessage($w.BytesValue()..value = Uint8List.fromList(v));
  }

  // primitives
  if (v is bool)   return _anyFromMessage($w.BoolValue()..value = v);
  if (v is int)    return _anyFromMessage($w.Int64Value()..value = $i64.Int64(v));
  if (v is double) return _anyFromMessage($w.DoubleValue()..value = v);
  if (v is String) return _anyFromMessage($w.StringValue()..value = v);

  // containers (recursive) -> Struct/ListValue
  if (v is Map<String, dynamic>) {
    return _anyFromMessage(_toStruct(v));
  }
  if (v is List) {
    return _anyFromMessage(_toListValue(v));
  }

  // fallback: stringify
  return _anyFromMessage($w.StringValue()..value = v.toString());
}

/// Map -> Struct (recursive)
$s.Struct _toStruct(Map<String, dynamic> m) {
  final s = $s.Struct();
  m.forEach((k, v) => s.fields[k] = _toValue(v));
  return s;
}

/// List -> ListValue (recursive)
$s.ListValue _toListValue(List list) {
  final lv = $s.ListValue();
  for (final item in list) {
    lv.values.add(_toValue(item));
  }
  return lv;
}

/// dynamic -> google.protobuf.Value (for elements inside Struct/ListValue)
$s.Value _toValue(dynamic v) {
  if (v == null)   return $s.Value()..nullValue = $s.NullValue.NULL_VALUE;
  if (v is bool)   return $s.Value()..boolValue = v;
  if (v is num)    return $s.Value()..numberValue = v.toDouble();
  if (v is String) return $s.Value()..stringValue = v;

  // NOTE: Struct/ListValue cannot hold raw bytes; encode as base64 string
  if (v is Uint8List) return $s.Value()..stringValue = base64.encode(v);
  if (v is List<int>) return $s.Value()..stringValue = base64.encode(Uint8List.fromList(v));

  if (v is Map<String, dynamic>) return $s.Value()..structValue = _toStruct(v);
  if (v is List)                 return $s.Value()..listValue  = _toListValue(v);

  return $s.Value()..stringValue = v.toString();
}
