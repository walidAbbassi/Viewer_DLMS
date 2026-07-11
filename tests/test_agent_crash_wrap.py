"""Tests for the agents._runtime.crash_wrap helper."""
from __future__ import annotations

from pathlib import Path

import pytest

from agents._runtime import crash_wrap


def test_successful_main_returns_zero():
    rc = crash_wrap(lambda: 0, "Test Agent", argv=[])
    assert rc == 0


def test_main_returning_none_returns_zero():
    rc = crash_wrap(lambda: None, "Test Agent", argv=[])
    assert rc == 0


def test_main_returning_int_propagates():
    rc = crash_wrap(lambda: 42, "Test Agent", argv=[])
    assert rc == 42


def test_keyerror_returns_one(capfd):
    def boom() -> None:
        raise KeyError("foo")

    rc = crash_wrap(boom, "Test Agent", argv=[])
    assert rc == 1
    err = capfd.readouterr().err
    assert "KeyError" in err
    assert "foo" in err


def test_crash_writes_minimal_md_report(tmp_path: Path):
    out = tmp_path / "crash.md"

    def boom() -> None:
        raise AttributeError("'str' object has no attribute 'get'")

    rc = crash_wrap(boom, "Test Coverage Agent", argv=["--output", str(out)])
    assert rc == 1
    assert out.exists()
    body = out.read_text(encoding="utf-8")
    assert "CRASH" in body
    assert "AttributeError" in body
    assert "Test Coverage Agent" in body


def test_crash_report_with_equals_form(tmp_path: Path):
    out = tmp_path / "agent.md"

    def boom() -> None:
        raise ValueError("bad")

    rc = crash_wrap(boom, "Agent X", argv=[f"--output={out}"])
    assert rc == 1
    assert out.exists()
    assert "ValueError" in out.read_text(encoding="utf-8")


def test_no_output_argument_still_returns_one(capfd, tmp_path: Path):
    def boom() -> None:
        raise RuntimeError("doom")

    rc = crash_wrap(boom, "Agent Y", argv=["--project-id", "2202"])
    assert rc == 1
    # And no file was written anywhere we can check
    assert "doom" in capfd.readouterr().err


def test_system_exit_propagates():
    """SystemExit MUST NOT be caught — preserves --help and other exit flows."""
    def hard_exit() -> None:
        raise SystemExit(7)

    with pytest.raises(SystemExit) as excinfo:
        crash_wrap(hard_exit, "Agent Z", argv=[])
    assert excinfo.value.code == 7


def test_crash_report_writes_even_when_parent_dir_missing(tmp_path: Path):
    """The helper creates intermediate directories rather than failing."""
    out = tmp_path / "deep" / "nested" / "crash.md"

    def boom() -> None:
        raise OSError("missing dir test")

    rc = crash_wrap(boom, "Agent", argv=["--output", str(out)])
    assert rc == 1
    assert out.exists()


def test_crash_helper_does_not_raise_if_output_unwritable(tmp_path: Path):
    """If the CRASH report write itself fails, exit code is still 1."""
    # Point --output at a path under a regular file (not a dir) → mkdir will fail
    bad_parent = tmp_path / "blocker"
    bad_parent.write_text("not a directory")
    bad_out = bad_parent / "child.md"

    def boom() -> None:
        raise RuntimeError("primary")

    rc = crash_wrap(boom, "Agent", argv=["--output", str(bad_out)])
    # Still returns 1 even though we could not write the CRASH file
    assert rc == 1
    assert not bad_out.exists()
