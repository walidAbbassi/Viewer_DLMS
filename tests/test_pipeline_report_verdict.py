"""Tests for the GitLab-aware verdict logic in pipeline_report_agent._scorecard."""
from __future__ import annotations

import agents.pipeline_report_agent as pra


# ── GitLab-status-driven verdicts ──────────────────────────────────────────────

def test_success_is_pass():
    s = pra._scorecard("any text", job_status="success", allow_failure=False)
    assert s["status"] == "PASS"
    assert s["job_status"] == "success"


def test_passed_is_pass():
    s = pra._scorecard("any text", job_status="passed", allow_failure=False)
    assert s["status"] == "PASS"


def test_failed_blocking_is_fail():
    s = pra._scorecard("any text", job_status="failed", allow_failure=False)
    assert s["status"] == "FAIL"


def test_failed_allow_failure_is_warn():
    """Per design.md Decision 6: failed + allow_failure=True → WARN, not FAIL."""
    s = pra._scorecard("any text", job_status="failed", allow_failure=True)
    assert s["status"] == "WARN"
    assert s["allow_failure"] is True


def test_running_status():
    s = pra._scorecard("any text", job_status="running")
    assert s["status"] == "RUNNING"


def test_pending_status_is_running():
    s = pra._scorecard("any text", job_status="pending")
    assert s["status"] == "RUNNING"


def test_skipped_status():
    s = pra._scorecard("any text", job_status="skipped")
    assert s["status"] == "SKIPPED"


def test_unknown_status_is_other():
    s = pra._scorecard("any text", job_status="weird_state")
    assert s["status"] == "OTHER"


# ── Legacy fallback when no job_status is provided ─────────────────────────────

def test_legacy_fallback_with_high_returns_fail():
    s = pra._scorecard("4 HIGH findings detected")
    assert s["status"] == "FAIL"
    assert s["high"] >= 1
    assert s["job_status"] is None


def test_legacy_fallback_with_warn_returns_warn():
    s = pra._scorecard("some MEDIUM signal noted")
    assert s["status"] == "WARN"


def test_legacy_fallback_clean_returns_pass():
    s = pra._scorecard("All green, no issues found.")
    assert s["status"] == "PASS"


# ── KPI-cell regex precision ──────────────────────────────────────────────────

def test_kpi_cell_high_extracts_number():
    text = (
        "| **🟠 WARN** | **🔵 INFO** | **📋 Total** |\n"
        "| --- | --- | --- |\n"
        "| 5 | 3 | 8 |\n"
        "Findings: HIGH: 4 issues detected.\n"
    )
    s = pra._scorecard(text, job_status="success", allow_failure=False)
    # HIGH: 4 → 4 ; no HIGH cell in the table → just that one match
    assert s["high"] == 4


def test_kpi_cell_warn_from_table_cell():
    text = "| Rule | 5 WARN | 3 INFO |"
    s = pra._scorecard(text, job_status="success", allow_failure=False)
    assert s["warn"] == 5


def test_kpi_cell_ignores_prose_mentions():
    text = (
        "Highlight the most important issues to triage; no failures detected.\n"
        "🔴 critical priority emoji should be ignored too.\n"
    )
    s = pra._scorecard(text, job_status="success", allow_failure=False)
    # No KPI-cell pattern matched → both counters at zero
    assert s["high"] == 0
    assert s["warn"] == 0


def test_kpi_cell_handles_named_pair_form():
    text = "Counters — HIGH: 12 (top), WARN: 7 (low)"
    s = pra._scorecard(text, job_status="success", allow_failure=False)
    assert s["high"] == 12
    assert s["warn"] == 7


# ── Verdict icon map covers new statuses ──────────────────────────────────────

def test_verdict_icon_includes_running_and_skipped():
    assert pra._VERDICT_ICON["PASS"] == "✅"
    assert pra._VERDICT_ICON["WARN"] == "🟡"
    assert pra._VERDICT_ICON["FAIL"] == "🔴"
    assert pra._VERDICT_ICON["RUNNING"] == "🔄"
    assert pra._VERDICT_ICON["SKIPPED"] == "⏭"
