from __future__ import annotations

import importlib
import sys
import types
import xml.etree.ElementTree as ET

import pytest


def _import_parser_with_fakes(
    monkeypatch: pytest.MonkeyPatch,
    *,
    wmi_raises: bool = False,
    uuid: str = "12345678-1234-1234-1234-1234567890AB",
    sid: str = "S-1-5-21-123",
):
    """Import license.parser with fake win32/wmi modules.

    license/parser.py imports win32process, win32security and wmi at import time.
    These are Windows-specific and may be unavailable in CI runners or dev envs.
    """

    # Ensure a fresh import each time (module caches keep references to old fakes).
    sys.modules.pop("license.parser", None)

    win32process = types.ModuleType("win32process")

    def GetCurrentProcess():
        return object()

    win32process.GetCurrentProcess = GetCurrentProcess

    win32security = types.ModuleType("win32security")
    win32security.TOKEN_READ = 0x20008
    win32security.TokenUser = 1

    def OpenProcessToken(handle, access):
        return (handle, access)

    def GetTokenInformation(token, info_class):
        return ("sid-object",)

    def ConvertSidToStringSid(sid_object):
        return sid

    win32security.OpenProcessToken = OpenProcessToken
    win32security.GetTokenInformation = GetTokenInformation
    win32security.ConvertSidToStringSid = ConvertSidToStringSid

    wmi_mod = types.ModuleType("wmi")

    if wmi_raises:

        class WMI:  # noqa: N801 (match external lib style)
            def __init__(self):
                raise RuntimeError("WMI failure")

    else:

        class WMI:  # noqa: N801
            def Win32_ComputerSystemProduct(self):
                obj = types.SimpleNamespace(UUID=uuid)
                return [obj]

    wmi_mod.WMI = WMI

    monkeypatch.setitem(sys.modules, "win32process", win32process)
    monkeypatch.setitem(sys.modules, "win32security", win32security)
    monkeypatch.setitem(sys.modules, "wmi", wmi_mod)

    return importlib.import_module("license.parser")


def test_get_universally_unique_identifier_success(monkeypatch: pytest.MonkeyPatch):
    parser = _import_parser_with_fakes(monkeypatch, uuid="AAAA-BBBB")
    assert parser.get_universally_unique_identifier() == "AAAABBBB"


def test_get_universally_unique_identifier_fallback(monkeypatch: pytest.MonkeyPatch):
    parser = _import_parser_with_fakes(monkeypatch, wmi_raises=True)
    assert (
        parser.get_universally_unique_identifier() == "AAAAAAAABBBBCCCCDDDDEEEEEEEEEEEE"
    )


def test_get_security_identifiers_strips_dashes(monkeypatch: pytest.MonkeyPatch):
    parser = _import_parser_with_fakes(monkeypatch, sid="S-1-2-3")
    assert parser.get_security_identifiers() == "S123"


def test_get_key_licence_builds_expected_hex(monkeypatch: pytest.MonkeyPatch):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    # Use a 32-char payload: pad() will add a full 16-byte block, producing a
    # long enough base64 result for the slicing in get_key_licence().
    ciphered_key, hex_key = parser.get_key_licence("A" * 32)

    assert isinstance(ciphered_key, (bytes, bytearray))
    assert len(ciphered_key) >= 56
    assert isinstance(hex_key, str)
    assert len(hex_key) == 32
    assert hex_key == hex_key.upper()


def test_encrypt_then_decrypt_file_licence_roundtrip(
    monkeypatch: pytest.MonkeyPatch, tmp_path
):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    key = "0" * 32  # 32 bytes after .encode() => AES-256 key
    xml = "<root><a>1</a></root>"
    out = tmp_path / "licence.bin"

    parser.encrypt_file_licence(key, xml, str(out))
    decrypted = parser.decrypt_file_licence(key, str(out))

    assert isinstance(decrypted, (bytes, bytearray))
    assert decrypted.decode().rstrip() == xml


def test_decrypt_file_licence_returns_empty_when_missing(
    monkeypatch: pytest.MonkeyPatch, tmp_path
):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    missing = tmp_path / "missing.bin"
    assert parser.decrypt_file_licence("0" * 32, str(missing)) == ""


def test_decrypt_file_licence_reraises_exceptions(
    monkeypatch: pytest.MonkeyPatch, tmp_path
):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    # Create a malformed file so cryptography CBC() raises (IV length != 16).
    p = tmp_path / "bad_iv.bin"
    p.write_bytes(b"\x00" * 8 + b"\x01")

    with pytest.raises(Exception):
        parser.decrypt_file_licence("0" * 32, str(p))


def test_encrypt_file_licence_raises_on_elementtree_bytes_concat(
    monkeypatch: pytest.MonkeyPatch, tmp_path
):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    key = "0" * 32
    out = tmp_path / "licence.bin"
    root = ET.Element("root")

    with pytest.raises(TypeError):
        parser.encrypt_file_licence(key, root, str(out))


def test_encrypt_file_licence_reraises_exceptions(
    monkeypatch: pytest.MonkeyPatch, tmp_path
):
    pytest.importorskip("cryptography")

    parser = _import_parser_with_fakes(monkeypatch)

    # Bad AES key length should raise inside the try and be re-raised.
    out = tmp_path / "licence.bin"
    with pytest.raises(Exception):
        parser.encrypt_file_licence("0", "<x/>", str(out))
