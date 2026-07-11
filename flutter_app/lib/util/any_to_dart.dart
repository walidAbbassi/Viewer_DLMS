import 'dart:typed_data';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $any;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $w;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $s;
dynamic anyToDart($any.Any a) {
  // 1) Wrapper types (primitives)
  {
    final msg = $w.StringValue();
    if (a.canUnpackInto(msg)) { a.unpackInto(msg); return msg.value; }
  }
  {
    final msg = $w.Int64Value();
    if (a.canUnpackInto(msg)) { a.unpackInto(msg); return msg.value.toInt(); }
  }
  {
    final msg = $w.DoubleValue();
    if (a.canUnpackInto(msg)) { a.unpackInto(msg); return msg.value; }
  }
  {
    final msg = $w.BoolValue();
    if (a.canUnpackInto(msg)) { a.unpackInto(msg); return msg.value; }
  }
  {
    final msg = $w.BytesValue();
    if (a.canUnpackInto(msg)) { a.unpackInto(msg); return Uint8List.fromList(msg.value); }
  }

  // 2) JSON-like containers (Struct / ListValue), recursively to Map/List
  {
    final msg = $s.Struct();
    if (a.canUnpackInto(msg)) { 
      a.unpackInto(msg); 
      return _structToMap(msg); 
    }
  }
  {
    final msg = $s.ListValue();
    if (a.canUnpackInto(msg)) { 
      a.unpackInto(msg); 
      return _listToList(msg); 
    }
  }

  // 3) Unknown embedded message → return the Any so caller can inspect typeUrl
  return a;
}

Map<String, dynamic> _structToMap($s.Struct s) {
  final out = <String, dynamic>{};
  s.fields.forEach((k, v) => out[k] = _valueToDart(v));
  return out;
}

List<dynamic> _listToList($s.ListValue lv) =>
    lv.values.map(_valueToDart).toList();

dynamic _valueToDart($s.Value v) {
  switch (v.whichKind()) {
    case $s.Value_Kind.stringValue: return v.stringValue;
    case $s.Value_Kind.numberValue: return v.numberValue; // double
    case $s.Value_Kind.boolValue:   return v.boolValue;
    case $s.Value_Kind.structValue: return _structToMap(v.structValue);
    case $s.Value_Kind.listValue:   return _listToList(v.listValue);
    case $s.Value_Kind.nullValue:   return null;
    case $s.Value_Kind.notSet:      return null;
  }
}

String bytesToHex(Uint8List bytes, {bool uppercase = true}) {
  final StringBuffer sb = StringBuffer();
  for (final b in bytes) {
    sb.write((b & 0xFF).toRadixString(16).padLeft(2, '0'));
  }
  final s = sb.toString();
  return uppercase ? s.toUpperCase() : s;
}
