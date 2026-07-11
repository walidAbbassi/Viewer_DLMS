"""
Flutter Analyzer Agent — parses `flutter analyze` output and posts MR comment.
Layer 2: claude-sonnet-4.6 explains critical Dart lint issues.
NEW: no reference equivalent — specific to Viewer NG Flutter frontend.
Symbolic name: 🤖🚀 Vostok — Analyste Flutter.
"""
import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import (
    agent_header, collapsible_table, details, kpi_card, mermaid_pie,
    render_exec_block, sev_badge, status_badge,
)

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")
FLUTTER_BIN = os.environ.get("FLUTTER_BIN", r"C:\flutter\bin\flutter.bat")

# Severities emitted by flutter analyze
_ISSUE_RE = re.compile(
    r"^\s*(?P<severity>error|warning|info)\s*[•\-]\s*(?P<message>[^\(]+)\s*"
    r"(?:\((?P<rule>[^)]+)\))?\s*(?:at\s+)?(?P<file>[^\s:]+):(?P<line>\d+)"
    r"|"
    r"^\s+(?P<file2>[^\s]+\.dart):(?P<line2>\d+):\d+\s*[•\-]\s+(?P<message2>.+?)\s+(?P<rule2>\w+)$",
    re.MULTILINE,
)


def _run_flutter_analyze(flutter_app_dir: str) -> tuple[str, list[dict]]:
    try:
        result = subprocess.run(
            [FLUTTER_BIN, "analyze", "--no-fatal-warnings"],
            capture_output=True, text=True, timeout=120,
            cwd=flutter_app_dir,
        )
        output = result.stdout + result.stderr
    except Exception as exc:
        print(f"⚠ flutter analyze failed: {exc}", file=sys.stderr)
        return "", []

    issues = []
    # Simple line-by-line parse of the standard output format:
    #   • rule_name at lib/file.dart:12:3
    for line in output.splitlines():
        # Match format:   severity • message • rule_name • file:line:col
        m = re.match(
            r"^\s+(?P<severity>error|warning|info)\s+[•\-]\s+(?P<message>.+?)\s+[•\-]\s+(?P<rule>\S+)\s+[•\-]\s+(?P<file>[^\s:]+):(?P<line>\d+):\d+",
            line, re.IGNORECASE
        )
        if m:
            issues.append({
                "severity": m.group("severity").upper(),
                "message": m.group("message").strip(),
                "rule": m.group("rule"),
                "file": m.group("file"),
                "line": m.group("line"),
            })
    return output, issues


def _deterministic_exec(issues: list[dict]) -> dict:
    errors = sum(1 for i in issues if i["severity"] == "ERROR")
    warnings = sum(1 for i in issues if i["severity"] == "WARNING")
    infos = sum(1 for i in issues if i["severity"] not in ("ERROR", "WARNING"))
    files = len({i["file"] for i in issues})
    ok = not errors and not warnings
    summary = (
        f"Flutter analyze: {len(issues)} issue(s) across {files} file(s) — "
        f"{errors} error(s), {warnings} warning(s), {infos} info. "
        f"Status: {'PASS' if ok else 'FAIL/WARN'}."
    )
    key_points = [
        f"Errors: {errors}",
        f"Warnings: {warnings}",
        f"Info: {infos}",
        f"Files impacted: {files}",
    ]
    reviewer_notes = ["AI unavailable — see report below."]
    if errors:
        reviewer_notes.append("Errors detected — must be fixed before merge.")
    elif warnings:
        reviewer_notes.append("Warnings present — review before merge.")
    else:
        reviewer_notes.append("No analyzer issues detected.")
    recommended_actions: list[str] = []
    if errors:
        recommended_actions.append(f"Fix the {errors} Dart error(s)")
    if warnings:
        recommended_actions.append(f"Resolve the {warnings} Dart warning(s)")
    if infos:
        recommended_actions.append(f"Review the {infos} info-level lint(s)")
    if not recommended_actions:
        recommended_actions.append("Flutter analyze gate green — no action required")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(issues: list[dict]) -> str:
    errors = [i for i in issues if i["severity"] == "ERROR"]
    warnings = [i for i in issues if i["severity"] == "WARNING"]
    lines = [
        f"Flutter analyze: {len(issues)} issue(s) — {len(errors)} error, {len(warnings)} warning.",
        "",
        "Top errors:",
    ]
    for i in errors[:6]:
        lines.append(f"- [{i['rule']}] {Path(i['file']).name}:{i['line']} — {i['message']}")
    if warnings:
        lines.append("")
        lines.append("Top warnings:")
        for i in warnings[:6]:
            lines.append(f"- [{i['rule']}] {Path(i['file']).name}:{i['line']} — {i['message']}")
    return "\n".join(lines)


def _build_report(issues: list[dict], ai_text: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    errors = [i for i in issues if i["severity"] == "ERROR"]
    warnings = [i for i in issues if i["severity"] == "WARNING"]
    infos = [i for i in issues if i["severity"] not in ("ERROR", "WARNING")]
    ok = not errors and not warnings

    blocks: list[str] = []
    blocks.append(agent_header("🦋", "Flutter Analyzer", "🤖🚀 Vostok", mode,
                               subtitle=f"{len(issues)} issue(s)"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(issues)))
    blocks.append(kpi_card([
        ("✅ Status",   status_badge(ok)),
        ("🔴 Errors",   str(len(errors))),
        ("🟡 Warnings", str(len(warnings))),
        ("🔵 Info",     str(len(infos))),
        ("📊 Total",    str(len(issues))),
    ]))
    blocks.append("")

    if issues:
        pie = {"ERROR": len(errors), "WARNING": len(warnings), "INFO": len(infos)}
        blocks.append(mermaid_pie("Severity distribution", {k: v for k, v in pie.items() if v}))
        blocks.append("")
        rows = []
        for i in issues:
            rows.append(f"| {sev_badge(i['severity'])} | `{Path(i['file']).name}` | {i['line']} | `{i['rule']}` | {i['message']} |")
        blocks.append(collapsible_table("🦋 Dart issues",
                                        ["| Severity | File | Line | Rule | Message |",
                                         "|----------|------|------|------|---------|"],
                                        rows, visible_count=10))
        blocks.append("")
    else:
        blocks.append("✅ No Flutter analysis issues found.\n")

    if ai_text:
        blocks.append(details("🤖 AI Dart Lint Analysis — claude-sonnet-4.6", ai_text))
        blocks.append("")
    return "\n".join(blocks)


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> None:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    httpx.post(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
               json={"body": body}, verify=False, timeout=30).raise_for_status()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid")
    parser.add_argument("--flutter-dir", default="flutter_app")
    parser.add_argument("--analyze-output")     # pre-computed file (for CI artifact reuse)
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    if args.analyze_output and Path(args.analyze_output).exists():
        raw = Path(args.analyze_output).read_text(encoding="utf-8", errors="replace")
        _, issues = _run_flutter_analyze.__wrapped__ if hasattr(_run_flutter_analyze, "__wrapped__") else ("", [])
        # Re-parse from file
        issues = []
        for line in raw.splitlines():
            m = re.match(
                r"^\s+(?P<severity>error|warning|info)\s+[•\-]\s+(?P<message>.+?)\s+[•\-]\s+(?P<rule>\S+)\s+[•\-]\s+(?P<file>[^\s:]+):(?P<line>\d+):\d+",
                line, re.IGNORECASE
            )
            if m:
                issues.append({
                    "severity": m.group("severity").upper(),
                    "message": m.group("message").strip(),
                    "rule": m.group("rule"),
                    "file": m.group("file"),
                    "line": m.group("line"),
                })
    else:
        _, issues = _run_flutter_analyze(args.flutter_dir)

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(_exec_context(issues), scope="flutter-analyzer")
    ai_text = None
    errors = [i for i in issues if i["severity"] == "ERROR"]
    if copilot.is_available() and errors:
        ai_text = copilot.analyze_flutter(
            "\n".join(f"- [{i['rule']}] {i['file']}:{i['line']} — {i['message']}" for i in errors[:8])
        )

    report = _build_report(issues, ai_text, copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Flutter Analyzer \u2014 \U0001f916\U0001f680 Vostok", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Flutter Analyzer"))
