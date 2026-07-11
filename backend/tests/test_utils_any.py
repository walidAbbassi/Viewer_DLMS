from __future__ import annotations

import base64

import pytest

pytest.importorskip("google.protobuf")
from google.protobuf import empty_pb2
from google.protobuf import struct_pb2
from google.protobuf import wrappers_pb2
from google.protobuf.any_pb2 import Any as AnyMsg
import utils_any as ua


def test_pack_helpers_pack_expected_wrapper_types():
    pytest.importorskip("google.protobuf")



    a = ua.pack_str("hello")
    msg = wrappers_pb2.StringValue()
    assert a.Is(msg.DESCRIPTOR)
    a.Unpack(msg)
    assert msg.value == "hello"

    a = ua.pack_i64(42)
    msg_i64 = wrappers_pb2.Int64Value()
    assert a.Is(msg_i64.DESCRIPTOR)
    a.Unpack(msg_i64)
    assert int(msg_i64.value) == 42

    a = ua.pack_bool(True)
    msg_b = wrappers_pb2.BoolValue()
    assert a.Is(msg_b.DESCRIPTOR)
    a.Unpack(msg_b)
    assert msg_b.value is True

    a = ua.pack_bytes(b"abc")
    msg_bytes = wrappers_pb2.BytesValue()
    assert a.Is(msg_bytes.DESCRIPTOR)
    a.Unpack(msg_bytes)
    assert bytes(msg_bytes.value) == b"abc"


@pytest.mark.parametrize(
    "value, expected",
    [
        ("x", "x"),
        (True, True),
        (12, 12),
        (3.5, 3.5),
        (b"\x01\x02", b"\x01\x02"),
        (bytearray(b"ab"), b"ab"),
        (memoryview(b"zz"), b"zz"),
    ],
)
def test_python_to_any_roundtrip_primitives(value, expected):
    pytest.importorskip("google.protobuf")


    any_msg = ua.python_to_any(value)
    assert ua.any_to_python(any_msg) == expected


@pytest.mark.parametrize(
    "value, expected",
    [
        ([1, True, "x"], [1.0, True, "x"]),
        ((2, False, "y"), [2.0, False, "y"]),
    ],
)
def test_python_to_any_top_level_sequence_packs_listvalue(value, expected):
    pytest.importorskip("google.protobuf")



    any_msg = ua.python_to_any(value)
    assert any_msg.Is(struct_pb2.ListValue.DESCRIPTOR)
    assert ua.any_to_python(any_msg) == expected


def test_python_to_any_packs_existing_protobuf_message_directly():
    pytest.importorskip("google.protobuf")



    msg = wrappers_pb2.StringValue(value="already proto")
    any_msg = ua.python_to_any(msg)

    assert any_msg.Is(wrappers_pb2.StringValue.DESCRIPTOR)
    unpacked = wrappers_pb2.StringValue()
    any_msg.Unpack(unpacked)
    assert unpacked == msg


def test_python_to_any_none_packs_empty_and_any_to_python_returns_any():
    pytest.importorskip("google.protobuf")



    any_msg = ua.python_to_any(None)
    empty = empty_pb2.Empty()
    assert any_msg.Is(empty.DESCRIPTOR)

    # Current behavior: Empty isn't specially handled, so any_to_python returns the Any.
    out = ua.any_to_python(any_msg)
    assert out is any_msg


def test_python_to_any_recursive_struct_and_list_value_conversions():
    pytest.importorskip("google.protobuf")



    embedded = wrappers_pb2.StringValue(value="embedded")
    embedded_any = AnyMsg()
    embedded_any.Pack(embedded)

    value = {
        "s": "str",
        "i": 7,
        "f": 1.25,
        "b": False,
        "n": None,
        "bytes": b"hi",
        "list": [1, True, "x", b"k"],
        "nested": {"k": 2},
        "msg": embedded,
        "obj": object(),
    }

    any_msg = ua.python_to_any(value)
    out = ua.any_to_python(any_msg)

    assert isinstance(out, dict)
    assert out["s"] == "str"

    # ints in Struct/ListValue become JSON numbers -> floats
    assert out["i"] == 7.0
    assert out["f"] == 1.25
    assert out["b"] is False
    assert out["n"] is None

    assert out["bytes"] == base64.b64encode(b"hi").decode("ascii")

    assert out["list"][0] == 1.0
    assert out["list"][1] is True
    assert out["list"][2] == "x"
    assert out["list"][3] == base64.b64encode(b"k").decode("ascii")

    assert out["nested"]["k"] == 2.0

    # PbMessage values inside Struct are encoded as a small map with type+bytes.
    assert out["msg"]["@type"] == embedded_any.type_url
    assert out["msg"]["@bytes_hex"] == embedded_any.value.hex()

    # Unknown objects inside Struct become their string representation.
    assert isinstance(out["obj"], str)
    assert out["obj"].startswith("<object object")


def test_python_to_any_fallback_for_unknown_top_level_value():
    pytest.importorskip("google.protobuf")


    any_msg = ua.python_to_any({1})  # set is neither Mapping nor Sequence
    out = ua.any_to_python(any_msg)
    assert isinstance(out, str)
    assert "1" in out


def test_any_to_python_returns_any_for_unknown_non_struct_non_list_types():
    pytest.importorskip("google.protobuf")



    any_msg = AnyMsg()
    any_msg.Pack(empty_pb2.Empty())

    out = ua.any_to_python(any_msg)
    assert out is any_msg


def test_value_to_py_unset_kind_returns_none():
    pytest.importorskip("google.protobuf")



    v = struct_pb2.Value()  # no kind set
    assert ua._value_to_py(v) is None


def test_read_file_chunks_yields_all_bytes(tmp_path):
    pytest.importorskip("google.protobuf")

    p = tmp_path / "data.bin"
    p.write_bytes(b"abcdef")

    chunks = list(ua.read_file_chunks(p, 2))
    assert chunks == [b"ab", b"cd", b"ef"]
