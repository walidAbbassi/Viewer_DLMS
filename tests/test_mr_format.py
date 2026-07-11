"""Tests for the auto-collapse rule in agents/mr_format.py."""
from agents.mr_format import (
    AUTO_COLLAPSE_THRESHOLD,
    auto_details,
    executive_summary,
)


def test_threshold_is_800():
    assert AUTO_COLLAPSE_THRESHOLD == 800


def test_auto_details_inline_short_content():
    out = auto_details("Findings", "short body")
    assert out == "short body"
    assert "<details" not in out


def test_auto_details_collapses_long_content():
    body = "x" * (AUTO_COLLAPSE_THRESHOLD + 1)
    out = auto_details("Findings", body)
    assert out.startswith("<details>\n<summary>Findings</summary>")
    assert " open" not in out.splitlines()[0]
    assert body in out
    assert out.endswith("</details>")


def test_auto_details_boundary_inline_at_threshold():
    body = "x" * AUTO_COLLAPSE_THRESHOLD
    out = auto_details("Findings", body)
    assert out == body  # exactly at threshold → still inline


def test_auto_details_custom_threshold():
    out = auto_details("S", "12345", threshold=4)
    assert out.startswith("<details>")


def test_executive_summary_short_body_open():
    out = executive_summary(
        summary="ok",
        key_points=["p1"],
        reviewer_notes=["n1"],
        recommended_actions=["a1"],
        ai_powered=False,
    )
    lines = out.splitlines()
    # Line 0: <details ...> tag ; line 1: <summary> ; the badge sits inside <summary>.
    assert lines[0].startswith("<details open>")
    assert "🧮 Deterministic Summary" in out


def test_executive_summary_long_body_collapsed():
    long_summary = "x" * 1500  # forces body well above threshold
    out = executive_summary(
        summary=long_summary,
        key_points=["p1"],
        reviewer_notes=["n1"],
        recommended_actions=["a1"],
        ai_powered=True,
    )
    lines = out.splitlines()
    assert lines[0] == "<details>"  # closed, no open attribute
    assert "AI Executive Summary" in out


def test_executive_summary_includes_all_sections():
    out = executive_summary(
        summary="s",
        key_points=["kp1"],
        reviewer_notes=["rn1"],
        recommended_actions=["ra1"],
    )
    assert "### 📋 Global Summary" in out
    assert "### 🎯 Key Points" in out
    assert "### 👁️ Reviewer Notes" in out
    assert "### ✅ Recommended Actions" in out
    assert "kp1" in out and "rn1" in out and "ra1" in out
