from __future__ import annotations

import pytest

from util.hexa import hex_to_int


@pytest.mark.parametrize(
    "value, expected",
    [
        ("0xFF", 255),
        ("ff", 255),
        ("  0X10  ", 16),
        ("00", 0),
    ],
)
def test_hex_to_int_parses_hex_strings(value: str, expected: int):
    assert hex_to_int(value) == expected


@pytest.mark.parametrize("value", ["", "0x", "zz", "0xG1"])
def test_hex_to_int_invalid_raises_value_error(value: str):
    with pytest.raises(ValueError):
        hex_to_int(value)
