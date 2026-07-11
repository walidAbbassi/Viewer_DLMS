"""
Security Scanner Agent — Layer 1: 10 Python + 7 Dart security rules, Layer 2: claude-sonnet-4.6 CWE mapping.
Scans backend/ (Python) and flutter_app/lib/ (Dart) for security issues.
HIGH severity blocks the pipeline.
Symbolic name: 🤖⚖️ Anubis — Gardien des menaces.
"""
import argparse
import datetime
import os
import re
import sys
from collections import Counter
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import agent_header, details, kpi_card, mermaid_pie, render_exec_block, sev_badge

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")

RULES = [
    ("SEC-001", "HIGH",   re.compile(r'(?i)(aes_key|licence_aes_key|secret_key)\s*=\s*["\'][^"\']{8,}'), "Hardcoded AES/secret key"),
    ("SEC-002", "HIGH",   re.compile(r'(?i)(password|passwd|pwd)\s*=\s*["\'][^"\']+["\']'), "Hardcoded password"),
    ("SEC-003", "HIGH",   re.compile(r'\beval\s*\('), "Use of eval() — code injection risk"),
    ("SEC-004", "HIGH",   re.compile(r'\bexec\s*\('), "Use of exec() — code injection risk"),
    ("SEC-005", "HIGH",   re.compile(r'(?i)\bexecute\s*\(\s*["\']?\s*(?:select|insert|update|delete)\b'), "Potential SQL injection"),
    ("SEC-006", "MEDIUM", re.compile(r'\bsubprocess\b.*shell\s*=\s*True'), "subprocess shell=True — injection risk"),
    ("SEC-007", "MEDIUM", re.compile(r'(?i)(token|api_key|private_token)\s*=\s*["\'][a-zA-Z0-9_\-]{10,}'), "Hardcoded token/API key"),
    ("SEC-008", "LOW",    re.compile(r'# TODO.*security|# FIXME.*security|# HACK', re.IGNORECASE), "Security-related TODO"),
    ("SEC-009", "LOW",    re.compile(r'\bassert\b(?!.*test)'), "assert in production code — disabled with -O"),
    ("SEC-010", "LOW",    re.compile(r'except\s*:'), "Bare except — masks errors silently"),
]

EXCLUDED_DIRS = {"gen", "tests", "__pycache__", ".venv"}
DART_EXCLUDED = {".dart_tool", "build", "generated", "__pycache__"}

DART_RULES = [
    ("DART-001", "HIGH",   re.compile(r'(?i)(apiKey|secretKey|password|aesKey|privateKey|token)\s*=\s*["\'][^"\']{8,}'), "Hardcoded secret/key in Dart"),
    ("DART-002", "HIGH",   re.compile(r'http://(?!localhost|127\.0\.0\.1|10\.|192\.168\.)'), "Plaintext HTTP (non-local URL) — CWE-319"),
    ("DART-003", "HIGH",   re.compile(r'Process\.(run|start)\s*\('), "Process spawning — shell injection risk — CWE-78"),
    ("DART-004", "MEDIUM", re.compile(r'\.badCertificateCallback\s*=|onBadCertificate\s*:'), "TLS certificate validation disabled — CWE-295"),
    ("DART-005", "MEDIUM", re.compile(r'catch\s*\(\w+\)\s*\{\s*\}'), "Empty catch block — masks errors silently"),
    ("DART-006", "LOW",    re.compile(r'\bprint\s*\('), "print() in production code — CWE-532"),
    ("DART-007", "LOW",    re.compile(r'// TODO.*security|// FIXME.*security|// HACK', re.IGNORECASE), "Security-related TODO/FIXME"),
]


def _scan_dart_file(path: Path) -> list[dict]:
    findings = []
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings
    for rule_id, severity, pattern, message in DART_RULES:
        for i, line in enumerate(source.splitlines(), 1):
            if pattern.search(line):
                findings.append({
                    "rule": rule_id, "severity": severity,
                    "file": str(path), "line": i,
                    "message": message, "snippet": line.strip()[:120],
                })
    return findings


def _scan_file(path: Path) -> list[dict]:
    findings = []
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings
    for rule_id, severity, pattern, message in RULES:
        for i, line in enumerate(source.splitlines(), 1):
            if pattern.search(line):
                findings.append({
                    "rule": rule_id, "severity": severity,
                    "file": str(path), "line": i,
                    "message": message, "snippet": line.strip()[:120],
                })
    return findings


def _deterministic_exec(findings: list[dict]) -> dict:
    high = sum(1 for f in findings if f["severity"] == "HIGH")
    medium = sum(1 for f in findings if f["severity"] == "MEDIUM")
    low = sum(1 for f in findings if f["severity"] == "LOW")
    files = len({f["file"] for f in findings})
    rules = Counter(f["rule"] for f in findings)
    top_rule = rules.most_common(1)[0][0] if rules else "—"
    verdict = "BLOCKED" if high else ("WARN" if (medium or low) else "PASS")
    summary = (
        f"Security verdict: {verdict}. {len(findings)} finding(s) across {files} file(s): "
        f"{high} HIGH, {medium} MEDIUM, {low} LOW."
    )
    key_points = [
        f"{high} HIGH-severity finding(s)",
        f"{medium} MEDIUM-severity finding(s)",
        f"{low} LOW-severity finding(s)",
        f"Top rule: {top_rule}",
        f"{files} file(s) impacted",
    ]
    reviewer_notes = ["AI unavailable — see report below."]
    if high:
        reviewer_notes.append("HIGH findings block the pipeline — must be fixed before merge.")
    elif medium or low:
        reviewer_notes.append("Non-blocking findings — review before merge.")
    else:
        reviewer_notes.append("No security issues detected.")
    recommended_actions: list[str] = []
    if high:
        recommended_actions.append(f"Fix the {high} HIGH-severity issue(s) before merging")
    if medium:
        recommended_actions.append(f"Triage the {medium} MEDIUM finding(s)")
    if low:
        recommended_actions.append(f"Review the {low} LOW finding(s) when convenient")
    if not recommended_actions:
        recommended_actions.append("No action required — security gate green")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(findings: list[dict]) -> str:
    high = sum(1 for f in findings if f["severity"] == "HIGH")
    medium = sum(1 for f in findings if f["severity"] == "MEDIUM")
    low = sum(1 for f in findings if f["severity"] == "LOW")
    rules = Counter(f["rule"] for f in findings).most_common(5)
    lines = [
        f"Security scan: {len(findings)} finding(s) — {high} HIGH, {medium} MEDIUM, {low} LOW.",
        "Top rules: " + ", ".join(f"{r}({c})" for r, c in rules) if rules else "Top rules: none",
        "",
        "Top findings:",
    ]
    for f in findings[:10]:
        lines.append(f"- [{f['severity']}] {f['rule']} {Path(f['file']).name}:{f['line']} — {f['message']}")
    return "\n".join(lines)


def _build_report(findings: list[dict], ai_text: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    high   = [f for f in findings if f["severity"] == "HIGH"]
    medium = [f for f in findings if f["severity"] == "MEDIUM"]
    low    = [f for f in findings if f["severity"] == "LOW"]

    verdict = "🔴 **BLOCKED** — HIGH severity findings detected" if high else ("🟡 **WARNING** — issues found" if medium or low else "🟢 **PASSED** — no issues")

    blocks: list[str] = []

    # Header
    blocks.append(agent_header("🛡️", "Security Scanner", "🤖⚖️ Anubis", mode,
                               subtitle=f"{len(findings)} finding(s)"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(findings)))
    blocks.append(f"### Verdict: {verdict}\n")

    # KPI card
    blocks.append(kpi_card([
        ("🔴 HIGH",   str(len(high))),
        ("🟡 MEDIUM", str(len(medium))),
        ("🟢 LOW",    str(len(low))),
        ("📋 Total",  str(len(findings))),
    ]))
    blocks.append("")

    # Mermaid pie
    if findings:
        pie_data: dict[str, int] = {}
        if high:   pie_data["HIGH"]   = len(high)
        if medium: pie_data["MEDIUM"] = len(medium)
        if low:    pie_data["LOW"]    = len(low)
        blocks.append(mermaid_pie("Security findings by severity", pie_data))
        blocks.append("")

        # CWE rule distribution
        rule_counts = Counter(f["rule"] for f in findings)
        blocks.append(kpi_card([(rule, str(cnt)) for rule, cnt in rule_counts.most_common(6)]))
        blocks.append("")

    # Findings table (collapsible)
    if findings:
        table_lines = ["| Rule | Severity | File | Line | Issue |",
                       "|------|----------|------|------|-------|"]
        for f in findings[:60]:
            table_lines.append(
                f"| `{f['rule']}` | {sev_badge(f['severity'])} | `{Path(f['file']).name}` | {f['line']} | {f['message']} |"
            )
        if len(findings) > 60:
            table_lines.append(f"| … | | | | *{len(findings) - 60} more findings — see artifact* |")
        label = f"📋 All {len(findings)} finding(s) — click to expand"
        blocks.append(details(label, "\n".join(table_lines)))
        blocks.append("")
    else:
        blocks.append("✅ No security issues found.\n")

    # AI analysis
    if ai_text:
        blocks.append(details("🤖 AI CWE Analysis — claude-sonnet-4.6", ai_text))
        blocks.append("")

    return "\n".join(blocks)


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> bool:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    try:
        resp = httpx.post(
            url,
            headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
            json={"body": body},
            verify=False,
            timeout=30,
        )
        resp.raise_for_status()
        return True
    except httpx.HTTPError as exc:
        # Comment publishing is integration-only; do not fail scanning pipeline on GitLab API issues.
        print(f"⚠ MR comment post failed: {exc}", file=sys.stderr)
        return False


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid")
    parser.add_argument("--scan-dir", nargs="+", default=["backend", "flutter_app/lib"])
    parser.add_argument("--output")
    parser.add_argument("--fail-on-high", action="store_true")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    current_encoding = str(getattr(sys.stdout, 'encoding', '') or '').lower()
    if hasattr(sys.stdout, 'reconfigure') and current_encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    findings = []
    for scan_dir in args.scan_dir:
        scan_path = Path(scan_dir)
        if not scan_path.exists():
            continue
        for f in scan_path.rglob("*.py"):
            if any(part in EXCLUDED_DIRS for part in f.parts):
                continue
            findings.extend(_scan_file(f))
        for f in scan_path.rglob("*.dart"):
            if any(part in DART_EXCLUDED for part in f.parts):
                continue
            findings.extend(_scan_dart_file(f))

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(_exec_context(findings), scope="security")
    ai_text = None
    if copilot.is_available() and findings:
        high_count = sum(1 for f in findings if f.get("severity") == "HIGH")
        findings_str = "\n".join(
            f"- [{f['rule']}] {f['file']}:{f['line']} — {f['message']}" for f in findings[:10]
        )
        ai_text = copilot.analyze_security(
            count=len(findings), high_count=high_count, findings=findings_str
        )

    report = _build_report(findings, ai_text, copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        _ts = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Security Scanner \u2014 \U0001f916\u2696\ufe0f Anubis", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        if not GITLAB_TOKEN:
            print(
                "⚠ GITLAB_TOKEN is empty — MR comment posting may fail (401). "
                "Security scan result remains authoritative.",
                file=sys.stderr,
            )
        if _post_mr_comment(args.project_id, args.mr_iid, report):
            print("✔ MR comment posted")

    high_count = sum(1 for f in findings if f["severity"] == "HIGH")
    if args.fail_on_high and high_count:
        print(f"✘ {high_count} HIGH-severity issue(s) found — blocking pipeline", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Security Scanner"))
