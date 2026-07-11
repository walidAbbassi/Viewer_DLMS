from typing import Any as _Any, Mapping, Sequence
import base64
from google.protobuf.any_pb2 import Any as AnyMsg
from google.protobuf.empty_pb2 import Empty
from google.protobuf import wrappers_pb2 as w
from google.protobuf import struct_pb2
from google.protobuf.message import Message as PbMessage


def pack_str(s: str) -> AnyMsg:
    a = AnyMsg()
    a.Pack(w.StringValue(value=s))
    return a


def pack_i64(n: int) -> AnyMsg:
    a = AnyMsg()
    a.Pack(w.Int64Value(value=n))
    return a


def pack_bool(b: bool) -> AnyMsg:
    a = AnyMsg()
    a.Pack(w.BoolValue(value=b))
    return a


def pack_bytes(bs: bytes) -> AnyMsg:
    a = AnyMsg()
    a.Pack(w.BytesValue(value=bs))
    return a


def python_to_any(value: _Any) -> AnyMsg:
    """
    Recursively convert a Python value to google.protobuf.Any using Pack():
      - str/int/float/bool -> wrapper types
      - bytes/bytearray/memoryview -> BytesValue
      - list/tuple -> ListValue (each element converted recursively)
      - dict/mapping -> Struct (each value converted recursively)
      - protobuf Message -> packed directly
      - fallback -> StringValue(str(value))
    """
    a = AnyMsg()
    if value is None:
        a.Pack(Empty())
        return a

    # Already a protobuf message
    if isinstance(value, PbMessage):
        a.Pack(value)
        return a

    # Bytes-like -> BytesValue
    if isinstance(value, (bytes, bytearray, memoryview)):
        a.Pack(w.BytesValue(value=bytes(value)))
        return a

    # Primitives
    if isinstance(value, bool):
        a.Pack(w.BoolValue(value=value))
        return a
    if isinstance(value, int):
        a.Pack(w.Int64Value(value=int(value)))
        return a
    if isinstance(value, float):
        a.Pack(w.DoubleValue(value=float(value)))
        return a
    if isinstance(value, str):
        a.Pack(w.StringValue(value=value))
        return a

    # Dict -> Struct (recursive)
    if isinstance(value, Mapping):
        s = _to_struct(value)
        a.Pack(s)
        return a

    # Sequence -> ListValue (recursive)
    if isinstance(value, Sequence) and not isinstance(
        value, (str, bytes, bytearray, memoryview)
    ):
        lv = _to_listvalue(value)
        a.Pack(lv)
        return a

    # Fallback
    a.Pack(w.StringValue(value=str(value)))
    return a


# ------------ recursive helpers for Struct/ListValue ------------


def _to_struct(d: Mapping) -> struct_pb2.Struct:
    s = struct_pb2.Struct()
    for k, v in d.items():
        s.fields[k].CopyFrom(_to_value(v))
    return s


def _to_listvalue(seq: Sequence) -> struct_pb2.ListValue:
    lv = struct_pb2.ListValue()
    for item in seq:
        lv.values.append(_to_value(item))  # recursive
    return lv


def _to_value(v: _Any) -> struct_pb2.Value:
    # Mirrors python_to_any, but produces a Struct/ListValue Value node
    if v is None:
        return struct_pb2.Value(null_value=struct_pb2.NullValue.NULL_VALUE)
    if isinstance(v, bool):
        return struct_pb2.Value(bool_value=v)
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return struct_pb2.Value(number_value=float(v))
    if isinstance(v, str):
        return struct_pb2.Value(string_value=v)
    if isinstance(v, (bytes, bytearray, memoryview)):
        return struct_pb2.Value(string_value=base64.b64encode(bytes(v)).decode("ascii"))
    if isinstance(v, Mapping):
        return struct_pb2.Value(struct_value=_to_struct(v))
    if isinstance(v, Sequence) and not isinstance(
        v, (str, bytes, bytearray, memoryview)
    ):
        return struct_pb2.Value(list_value=_to_listvalue(v))
    if isinstance(v, PbMessage):
        # Represent embedded messages inside Struct as a tiny map with type+bytes (optional pattern)
        any_msg = AnyMsg()
        any_msg.Pack(v)
        return struct_pb2.Value(
            struct_value=_to_struct(
                {
                    "@type": any_msg.type_url,
                    "@bytes_hex": any_msg.value.hex(),
                }
            )
        )
    return struct_pb2.Value(string_value=str(v))


def any_to_python(a: AnyMsg) -> _Any:
    """Unpack google.protobuf.Any into plain Python types (recursive for Struct/ListValue)."""

    # 1) Try well-known wrapper types (primitives)
    for typ in (w.StringValue, w.Int64Value, w.DoubleValue, w.BoolValue, w.BytesValue):
        msg = typ()
        if a.Is(msg.DESCRIPTOR):
            a.Unpack(msg)
            # Int64Value returns Python int; BytesValue returns bytes
            if isinstance(msg, w.BytesValue):
                return bytes(msg.value)
            if isinstance(msg, w.Int64Value):
                return int(msg.value)
            return msg.value

    # 2) Struct -> dict (recursive)
    s = struct_pb2.Struct()
    if a.Is(s.DESCRIPTOR):
        a.Unpack(s)
        return _struct_to_py(s)

    # 3) ListValue -> list (recursive)
    lv = struct_pb2.ListValue()
    if a.Is(lv.DESCRIPTOR):
        a.Unpack(lv)
        return _listvalue_to_py(lv)

    # 4) Unknown/custom message: give back the unpacked proto message if possible,
    #    else return the Any as-is.
    #    (We need the concrete class to unpack; without a registry we just return Any.)
    return a


# ---------------- helpers for Struct/ListValue ----------------


def _struct_to_py(s: struct_pb2.Struct) -> dict:
    out = {}
    for k, v in s.fields.items():
        out[k] = _value_to_py(v)
    return out


def _listvalue_to_py(lv: struct_pb2.ListValue) -> list:
    return [_value_to_py(v) for v in lv.values]


def _value_to_py(v: struct_pb2.Value):
    kind = v.WhichOneof("kind")
    if kind == "null_value":
        return None
    if kind == "number_value":
        return v.number_value  # float
    if kind == "string_value":
        return v.string_value
    if kind == "bool_value":
        return v.bool_value
    if kind == "struct_value":
        return _struct_to_py(v.struct_value)
    if kind == "list_value":
        return _listvalue_to_py(v.list_value)
    return None


def read_file_chunks(file_path, chunk_size):
    with open(file_path, "rb") as file:
        while True:
            chunk = file.read(chunk_size)
            if not chunk:
                break
            yield chunk
