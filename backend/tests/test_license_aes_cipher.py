from __future__ import annotations

import binascii

import pytest

pytest.importorskip("cryptography")
from license import aes_cipher as ac
from license.aes_cipher import AESCipher


def test_pad_and_unpad_roundtrip_for_str():
    # unpad() is implemented for str (uses ord on the last character)
    raw = "abc"
    padded = ac.pad(raw)
    assert isinstance(padded, str)
    assert len(padded) % ac.BS == 0

    unpadded = ac.unpad(padded)
    assert unpadded == raw


def test_encrypt_returns_base64_bytes_and_is_deterministic():

    cipher = AESCipher("0889504708895047")  # 16 chars -> 16 bytes in Windows-1252

    enc1 = cipher.encrypt("hello")
    enc2 = cipher.encrypt("hello")
    enc3 = cipher.encrypt("hello2")

    assert isinstance(enc1, (bytes, bytearray))
    assert enc1 == enc2
    assert enc1 != enc3


def test_encrypt_raises_for_non_windows1252_chars():

    cipher = AESCipher("0889504708895047")

    # Emoji cannot be encoded in Windows-1252
    with pytest.raises(UnicodeEncodeError):
        cipher.encrypt("hello 😀")


@pytest.mark.parametrize(
    "raw",
    [
        "hello",
        "Caf\u00e9 \u20ac",  # 'Café €' is representable in Windows-1252
    ],
)
def test_decrypt_roundtrip_decodes_windows1252(raw: str):

    cipher = AESCipher("0889504708895047")
    enc = cipher.encrypt(raw)
    assert cipher.decrypt(enc) == raw


def test_decrypt_rejects_invalid_base64_input():

    cipher = AESCipher("0889504708895047")

    with pytest.raises((binascii.Error, ValueError)):
        cipher.decrypt(b"not base64!!")


def test_encrypt_rejects_invalid_key_length():

    cipher = AESCipher("short")
    with pytest.raises(ValueError):
        cipher.encrypt("abc")
