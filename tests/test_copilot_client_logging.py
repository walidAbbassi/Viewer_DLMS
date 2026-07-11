"""Tests for the deduplicated 3-section CI log layout in copilot_client._ask."""
from __future__ import annotations

import io
import re
from contextlib import redirect_stdout

import agents.copilot_client as cc


# ── Helpers ────────────────────────────────────────────────────────────────────

_ANSI_RE = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")


def _strip_ansi(text: str) -> str:
    return _ANSI_RE.sub("", text)


def _build_fake_client(monkeypatch, prompt: str, result: str | None):
    """Construct a CopilotClient bypassing the real SDK/CLI init."""
    client = cc.CopilotClient.__new__(cc.CopilotClient)
    client.available = True
    client.mode = "SDK"
    client.sdk_timeout = 60
    client.cli_timeout = 60
    client._model = "claude-sonnet-4.6"
    client._max_workers = 1
    client._sdk_client = None
    client._sdk_session = None
    client._loop = None
    client._last_actual_model = "claude-sonnet-4.6"

    # _call_model is patched to bypass the real network round-trip.
    monkeypatch.setattr(client, "_call_model",
                        lambda safe_prompt: result, raising=False)
    return client


def _capture_ask(client, prompt: str) -> str:
    buf = io.StringIO()
    with redirect_stdout(buf):
        client._ask(prompt)
    return _strip_ansi(buf.getvalue())


# ── Section count assertions ──────────────────────────────────────────────────

def test_three_sections_each_appear_once(monkeypatch):
    client = _build_fake_client(monkeypatch, "the prompt", "the result")
    out = _capture_ask(client, "the prompt")

    # Each section_start marker emitted exactly once
    assert out.count("section_start:") == 3
    assert out.count("section_end:") == 3

    # And by name
    assert len(re.findall(r"section_start:\d+:copilot_prompt", out)) == 1
    assert len(re.findall(r"section_start:\d+:copilot_summary", out)) == 1
    assert len(re.findall(r"section_start:\d+:copilot_response", out)) == 1


def test_prompt_body_rendered_once(monkeypatch):
    unique_marker = "PROMPT_BODY_MARKER_XYZ"
    client = _build_fake_client(monkeypatch, unique_marker, "result text")
    out = _capture_ask(client, unique_marker)
    assert out.count(unique_marker) == 1


def test_result_body_rendered_once(monkeypatch):
    unique_marker = "RESULT_BODY_MARKER_ABC"
    client = _build_fake_client(monkeypatch, "prompt text", unique_marker)
    out = _capture_ask(client, "prompt text")
    assert out.count(unique_marker) == 1


def test_summary_section_contains_no_prompt_or_result(monkeypatch):
    """Summary section reports metadata only."""
    prompt = "UNIQUE_PROMPT_ZZZ"
    result = "UNIQUE_RESULT_QQQ"
    client = _build_fake_client(monkeypatch, prompt, result)
    out = _capture_ask(client, prompt)

    # Extract just the copilot_summary section by slicing between its markers.
    m_start = re.search(r"section_start:\d+:copilot_summary[^\n]*\n", out)
    m_end = re.search(r"section_end:\d+:copilot_summary", out)
    assert m_start and m_end, "summary section markers not found"
    summary_block = out[m_start.end(): m_end.start()]
    assert prompt not in summary_block, "summary section must not contain the prompt body"
    assert result not in summary_block, "summary section must not contain the result body"

    # Metadata labels must be present
    assert "Mode" in summary_block
    assert "Model" in summary_block
    assert "Latency" in summary_block
    assert "Status" in summary_block


def test_long_prompt_section_is_collapsed(monkeypatch):
    long_prompt = "x" * (cc.AUTO_COLLAPSE_THRESHOLD + 1)
    client = _build_fake_client(monkeypatch, long_prompt, "result")
    out = _capture_ask(client, long_prompt)
    m = re.search(r"section_start:\d+:copilot_prompt(?P<flag>\[[^\]]*\])?",
                  out)
    assert m is not None
    assert m.group("flag") == "[collapsed=true]"


def test_short_result_section_is_visible(monkeypatch):
    short_result = "short result"
    client = _build_fake_client(monkeypatch, "prompt", short_result)
    out = _capture_ask(client, "prompt")
    m = re.search(r"section_start:\d+:copilot_response(?P<flag>\[[^\]]*\])?",
                  out)
    assert m is not None
    # No [collapsed=true] flag when result is short
    assert m.group("flag") is None


def test_failed_call_emits_two_sections_only(monkeypatch):
    """When _call_model returns None, prompt+summary are emitted but no response."""
    client = _build_fake_client(monkeypatch, "prompt", None)
    out = _capture_ask(client, "prompt")
    assert out.count("section_start:") == 2  # prompt + summary
    assert "copilot_response" not in out
    # Status line in summary reports FAIL
    assert "❌ FAIL" in out


def test_unavailable_client_emits_nothing(monkeypatch):
    client = _build_fake_client(monkeypatch, "prompt", "result")
    client.available = False
    out = _capture_ask(client, "prompt")
    assert out == ""


def test_banners_still_printed(monkeypatch):
    """The visual banners (🧠 / 📊 / 📋) must remain — explicit user requirement."""
    client = _build_fake_client(monkeypatch, "prompt", "result")
    out = _capture_ask(client, "prompt")
    assert "Prompt Agent" in out
    assert "Execution Summary" in out
    assert "Result Prompt Agent" in out
