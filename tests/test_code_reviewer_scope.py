"""Tests for the diff-scoped two-tier behaviour of agents.code_reviewer."""
from __future__ import annotations

import agents.code_reviewer as cr


# ── _split_findings ────────────────────────────────────────────────────────────

def test_split_findings_primary_when_line_in_added_set():
    findings = [
        {"rule": "CR-001", "severity": "WARN", "file": "backend/server.py",
         "line": 42, "message": "use logger"},
    ]
    added = {"backend/server.py": {42, 43}}
    primary, supplementary = cr._split_findings(findings, added)
    assert primary == findings
    assert supplementary == []


def test_split_findings_supplementary_when_line_not_in_added_set():
    findings = [
        {"rule": "CR-001", "severity": "WARN", "file": "backend/server.py",
         "line": 100, "message": "use logger"},
    ]
    added = {"backend/server.py": {42, 43}}
    primary, supplementary = cr._split_findings(findings, added)
    assert primary == []
    assert supplementary == findings


def test_split_findings_mixed_buckets():
    findings = [
        {"rule": "CR-001", "severity": "WARN", "file": "backend/server.py",
         "line": 42, "message": "added line"},
        {"rule": "CR-003", "severity": "INFO", "file": "backend/server.py",
         "line": 5, "message": "pre-existing line"},
    ]
    added = {"backend/server.py": {42}}
    primary, supplementary = cr._split_findings(findings, added)
    assert len(primary) == 1 and primary[0]["line"] == 42
    assert len(supplementary) == 1 and supplementary[0]["line"] == 5


def test_split_findings_empty_added_set_treats_all_as_primary():
    """Push-pipeline fallback: no diff base context → every finding is primary."""
    findings = [
        {"rule": "CR-001", "severity": "WARN", "file": "x.py", "line": 1, "message": "m"},
    ]
    primary, supplementary = cr._split_findings(findings, {})
    assert primary == findings
    assert supplementary == []


def test_split_findings_windows_path_normalises():
    findings = [
        {"rule": "CR-001", "severity": "WARN", "file": "backend\\server.py",
         "line": 42, "message": "m"},
    ]
    added = {"backend/server.py": {42}}
    primary, supplementary = cr._split_findings(findings, added)
    assert primary == findings


# ── _added_line_set ────────────────────────────────────────────────────────────

def test_added_line_set_parses_hunk_headers(monkeypatch):
    fake_diff = (
        "diff --git a/backend/server.py b/backend/server.py\n"
        "--- a/backend/server.py\n"
        "+++ b/backend/server.py\n"
        "@@ -10,0 +11,2 @@\n"
        "+print('hello')\n"
        "+print('world')\n"
        "@@ -25 +27,1 @@\n"
        "+changed line\n"
    )
    monkeypatch.setattr(cr, "_run_git", lambda args: fake_diff)
    out = cr._added_line_set("base")
    assert out == {"backend/server.py": {11, 12, 27}}


def test_added_line_set_handles_new_file(monkeypatch):
    fake_diff = (
        "diff --git a/newfile.py b/newfile.py\n"
        "--- /dev/null\n"
        "+++ b/newfile.py\n"
        "@@ -0,0 +1,3 @@\n"
        "+line 1\n"
        "+line 2\n"
        "+line 3\n"
    )
    monkeypatch.setattr(cr, "_run_git", lambda args: fake_diff)
    out = cr._added_line_set("base")
    assert out == {"newfile.py": {1, 2, 3}}


def test_added_line_set_empty_diff(monkeypatch):
    monkeypatch.setattr(cr, "_run_git", lambda args: "")
    assert cr._added_line_set("base") == {}


# ── _build_report rendering ────────────────────────────────────────────────────

def _make(rule: str, file: str, line: int, sev: str = "WARN") -> dict:
    return {"rule": rule, "severity": sev, "file": file, "line": line,
            "message": "m", "snippet": "..."}


def test_build_report_renders_primary_table_inline_when_short():
    primary = [_make("CR-001", "a.py", 1), _make("CR-002", "a.py", 2)]
    report = cr._build_report(primary, [], None, "SDK")
    # Primary heading present
    assert "### 📌 Findings — MR diff" in report
    # No supplementary block (the labelled <details> for supplementary findings)
    assert "supplementary finding(s) in touched files" not in report
    assert "`CR-001`" in report
    assert "`CR-002`" in report


def test_build_report_renders_supplementary_collapsed_block():
    primary = [_make("CR-001", "a.py", 1)]
    supplementary = [_make("CR-003", "a.py", 5, "INFO"), _make("CR-004", "a.py", 6)]
    report = cr._build_report(primary, supplementary, None, "SDK")
    assert "📎 2 supplementary finding(s) in touched files" in report
    assert "<details>" in report
    assert "`CR-003`" in report and "`CR-004`" in report


def test_build_report_kpi_card_has_four_cells():
    primary = [_make("CR-001", "a.py", 1, "WARN"),
               _make("CR-001", "a.py", 2, "WARN"),
               _make("CR-003", "a.py", 3, "INFO")]
    supplementary = [_make("CR-007", "a.py", 5, "WARN")]
    report = cr._build_report(primary, supplementary, None, "SDK")
    # KPI card row carries the 4 named cells
    assert "🟠 WARN" in report
    assert "🔵 INFO" in report
    assert "📋 Total MR diff" in report
    assert "📎 Supplementary" in report


def test_build_report_no_findings_shows_green_message():
    report = cr._build_report([], [], None, "SDK")
    assert "✅ No Layer-1 issues on the MR diff" in report
    # No supplementary <details> block when supplementary list is empty
    assert "supplementary finding(s) in touched files" not in report


def test_build_report_long_primary_table_auto_collapses():
    # Build enough rows so the rendered table exceeds AUTO_COLLAPSE_THRESHOLD chars.
    primary = [_make(f"CR-00{i % 10}", "a_very_long_filename_for_padding.py", i)
               for i in range(50)]
    report = cr._build_report(primary, [], None, "SDK")
    # Look for the auto_details summary text on the primary block
    assert "📋 50 MR-diff finding(s) — click to expand" in report
    # And the block opens with <details> (no open) because the table is long
    assert "<details>\n<summary>📋 50 MR-diff finding(s)" in report


# ── _changed_files_from_diff ───────────────────────────────────────────────────

def test_changed_files_skips_excluded_paths(monkeypatch):
    fake = "backend/server.py\nbackend/gen/foo_pb2.py\ntests/test_foo.py\nflutter_app/lib/main.dart\n"
    monkeypatch.setattr(cr, "_run_git", lambda args: fake)
    files = cr._changed_files_from_diff("base", ["backend", "flutter_app/lib"])
    paths = [p.as_posix() for p in files]
    assert "backend/server.py" in paths
    assert "flutter_app/lib/main.dart" in paths
    assert "backend/gen/foo_pb2.py" not in paths  # gen/ is excluded
    assert "tests/test_foo.py" not in paths       # tests/ is excluded


def test_changed_files_only_keeps_py_and_dart(monkeypatch):
    fake = "backend/server.py\nbackend/config.json5\nflutter_app/lib/main.dart\n"
    monkeypatch.setattr(cr, "_run_git", lambda args: fake)
    files = cr._changed_files_from_diff("base", ["backend", "flutter_app/lib"])
    paths = [p.as_posix() for p in files]
    assert "backend/server.py" in paths
    assert "flutter_app/lib/main.dart" in paths
    assert "backend/config.json5" not in paths


def test_changed_files_returns_empty_on_no_output(monkeypatch):
    monkeypatch.setattr(cr, "_run_git", lambda args: "")
    assert cr._changed_files_from_diff("base", ["backend"]) == []
