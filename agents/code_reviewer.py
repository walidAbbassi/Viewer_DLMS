"""
Code Reviewer Agent — Layer 1: regex patterns, Layer 2: claude-sonnet-4.6 via GitHub Copilot API.
Analyses Python files in backend/ and Dart files in flutter_app/lib/, posts findings as an MR comment.
Symbolic name: 🤖🏺 Osiris — Juge du code.
"""
import argparse
import ast
import os
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import (
    AUTO_COLLAPSE_THRESHOLD,
    agent_header,
    auto_details,
    details,
    kpi_card,
    mermaid_pie,
    render_exec_block,
    sev_badge,
)

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")

# Layer 1 patterns (id, severity, regex, message)
L1_PATTERNS = [
    ("CR-001", "WARN", re.compile(r"\bprint\s*\("), "Use logger instead of print()"),
    ("CR-002", "WARN", re.compile(r"^import .+,.+", re.MULTILINE), "Avoid grouped imports"),
    ("CR-003", "INFO", re.compile(r"\b[a-z]\b\s*="), "Single-char variable name"),
    ("CR-004", "WARN", re.compile(r"# TODO|# FIXME|# HACK"), "Unresolved TODO/FIXME/HACK"),
    ("CR-005", "INFO", re.compile(r"python_requires.*[<>]=?\s*[23]\.[0-9]"), "Check Python version constraint"),
    ("CR-006", "WARN", re.compile(r"except\s*:"), "Bare except clause — use specific exception"),
]

DART_EXCLUDED = {".dart_tool", "build", "generated", "__pycache__"}

# Dart Layer 1 patterns
DART_PATTERNS = [
    ("CR-D001", "WARN", re.compile(r"\bprint\s*\("), "Use logger instead of print()"),
    ("CR-D002", "WARN", re.compile(r"// TODO|// FIXME|// HACK"), "Unresolved TODO/FIXME/HACK"),
    ("CR-D003", "INFO", re.compile(r"\bvar\b(?!\s+\w+\s*=\s*\[)"), "Prefer explicit types over var"),
    ("CR-D004", "WARN", re.compile(r"catch\s*\(\s*\w+\s*\)\s*\{\s*\}"), "Empty catch block — masks errors silently"),
    ("CR-D005", "WARN", re.compile(r"http://(?!localhost|127\.0\.0\.1)"), "Unencrypted HTTP (non-local)"),
]


_AI_DISCLAIMER_RE = re.compile(
    r"(?im)^\s*(?:i\s*(?:am|'m)|i\s+do\s+not|i\s+cannot|i\s+can'?t).{0,220}"
    r"(?:filesystem|file\s*access|permissions|runner\s+environment|sandbox).*$"
)

# Paths excluded from MR-diff scanning. Mirrors the existing repo-scan exclusion
# set plus the Flutter / proto generated-stub directories.
_DIFF_EXCLUDED = {"gen", "tests", "__pycache__", ".venv", ".dart_tool", "build", "generated"}

# Hunk header regex: @@ -old[,old_len] +new[,new_len] @@
_HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def _run_git(args: list[str]) -> str:
    """Run a git command, return stdout (empty string on any failure)."""
    try:
        result = subprocess.run(
            ["git", *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=30,
            stdin=subprocess.DEVNULL,
        )
        if result.returncode == 0:
            return result.stdout
    except (OSError, subprocess.TimeoutExpired):
        pass
    return ""


def _diff_base() -> str:
    """Resolve the MR diff base SHA, falling back to HEAD~1 for push pipelines."""
    return os.environ.get("CI_MERGE_REQUEST_DIFF_BASE_SHA", "") or "HEAD~1"


def _changed_files_from_diff(diff_base: str, scan_dirs: list[str]) -> list[Path]:
    """Return changed files (vs diff_base) under one of ``scan_dirs``, excluded paths filtered."""
    raw = _run_git(["diff", "--name-only", f"{diff_base}...HEAD"])
    if not raw:
        return []
    scan_paths = [Path(d) for d in scan_dirs]
    result: list[Path] = []
    seen: set[str] = set()
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        path = Path(line)
        if any(part in _DIFF_EXCLUDED for part in path.parts):
            continue
        if path.suffix not in (".py", ".dart"):
            continue
        # Must be under one of the scan directories
        for d in scan_paths:
            try:
                path.resolve().relative_to(d.resolve())
                break
            except (ValueError, OSError):
                # Fallback: textual prefix check (covers relative paths that don't exist on disk)
                if path.as_posix().startswith(d.as_posix() + "/"):
                    break
        else:
            continue
        key = path.as_posix()
        if key in seen:
            continue
        seen.add(key)
        result.append(path)
    return result


def _added_line_set(diff_base: str) -> dict[str, set[int]]:
    """Parse `git diff $diff_base...HEAD` and return added/modified line numbers per file.

    Keys are POSIX-style paths (forward-slash) so callers can normalise their lookup.
    """
    raw = _run_git(["diff", f"{diff_base}...HEAD", "--unified=0"])
    if not raw:
        return {}
    by_file: dict[str, set[int]] = {}
    current_file: str | None = None
    current_line: int = 0
    for line in raw.splitlines():
        if line.startswith("+++ "):
            path_part = line[4:].strip()
            if path_part.startswith("b/"):
                path_part = path_part[2:]
            current_file = None if path_part == "/dev/null" else path_part
            current_line = 0
            continue
        if line.startswith("---"):
            continue
        if line.startswith("@@"):
            m = _HUNK_RE.match(line)
            if m and current_file is not None:
                current_line = int(m.group(1))
            continue
        if current_file is None:
            continue
        if line.startswith("+"):
            by_file.setdefault(current_file, set()).add(current_line)
            current_line += 1
        elif line.startswith("-"):
            # Deletion: does not advance the new-file pointer
            continue
        elif line.startswith("\\"):
            # "\ No newline at end of file" — ignore
            continue
        else:
            # Context line (only present with non-zero --unified context)
            current_line += 1
    return by_file


def _split_findings(findings: list[dict],
                    added_lines: dict[str, set[int]]) -> tuple[list[dict], list[dict]]:
    """Split findings into (primary, supplementary) based on whether (file, line)
    falls inside the added/modified line set of the MR diff.
    """
    primary: list[dict] = []
    supplementary: list[dict] = []
    if not added_lines:
        # No diff base context — treat everything as primary (push pipeline behaviour).
        return list(findings), []
    for f in findings:
        posix_path = Path(f["file"]).as_posix()
        lineset = added_lines.get(posix_path)
        if lineset is None:
            # Try matching by suffix (handles Windows backslash + relative-path variants)
            for key, val in added_lines.items():
                if posix_path.endswith(key) or key.endswith(posix_path):
                    lineset = val
                    break
        if lineset and f["line"] in lineset:
            primary.append(f)
        else:
            supplementary.append(f)
    return primary, supplementary


def _read_lines(path: Path, limit: int = 400) -> list[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()[:limit]
    except OSError:
        return []


def _collect_ci_lint_signals(ci_inputs_dir: Path) -> list[str]:
    """Collect top actionable lint/test signals from ci_inputs artifacts."""
    signals: list[str] = []

    mypy_lines = _read_lines(ci_inputs_dir / "mypy_report.txt", limit=800)
    mypy_hits = [ln.strip() for ln in mypy_lines if ": error:" in ln][:5]
    if mypy_hits:
        signals.append("Mypy errors:")
        signals.extend(f"- {ln}" for ln in mypy_hits)

    pylint_lines = _read_lines(ci_inputs_dir / "pylint_report.txt", limit=800)
    pylint_hits = [ln.strip() for ln in pylint_lines if re.match(r"^[EFW]:", ln.strip())][:5]
    if pylint_hits:
        signals.append("Pylint issues:")
        signals.extend(f"- {ln}" for ln in pylint_hits)

    flake8_lines = _read_lines(ci_inputs_dir / "flake8_report.txt", limit=1200)
    flake8_hits = [
        ln.strip() for ln in flake8_lines
        if re.search(r":\d+:\d+:\s+[A-Z]\d+\s+", ln)
    ][:5]
    if flake8_hits:
        signals.append("Flake8 issues:")
        signals.extend(f"- {ln}" for ln in flake8_hits)

    # Black: files needing reformatting
    black_lines = _read_lines(ci_inputs_dir / "black_diff.txt", limit=500)
    black_hits = [ln.strip() for ln in black_lines if ln.strip().startswith("would reformat")][:5]
    if black_hits:
        signals.append("Black formatting (files to reformat):")
        signals.extend(f"- {ln}" for ln in black_hits)

    # Radon CC: high-complexity functions (rank E or F)
    radon_path = ci_inputs_dir / "radon_cc.json"
    if radon_path.exists():
        try:
            import json
            radon_data = json.loads(radon_path.read_text(encoding="utf-8", errors="replace"))
            radon_hits: list[str] = []
            for filepath, entries in radon_data.items():
                for entry in entries:
                    if entry.get("rank") in ("E", "F"):
                        radon_hits.append(
                            f"- {Path(filepath).name}:{entry.get('lineno','?')} "
                            f"{entry.get('name','?')} (CC={entry.get('complexity','?')}, rank={entry.get('rank','?')})"
                        )
            if radon_hits:
                signals.append("High-complexity functions (rank E/F — refactor candidates):")
                signals.extend(radon_hits[:5])
        except Exception:  # noqa: BLE001
            pass

    return signals


def _scan_file(path: Path) -> list[dict]:
    findings = []
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings

    for rule_id, severity, pattern, message in L1_PATTERNS:
        for i, line in enumerate(source.splitlines(), 1):
            if pattern.search(line):
                findings.append({
                    "rule": rule_id,
                    "severity": severity,
                    "file": str(path),
                    "line": i,
                    "message": message,
                    "snippet": line.strip()[:120],
                })

    # AST complexity check
    try:
        tree = ast.parse(source)
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                stmts = sum(1 for _ in ast.walk(node))
                if stmts > 80:
                    findings.append({
                        "rule": "CR-007",
                        "severity": "WARN",
                        "file": str(path),
                        "line": node.lineno,
                        "message": f"Function '{node.name}' is complex ({stmts} AST nodes)",
                        "snippet": f"def {node.name}(...)",
                    })
    except SyntaxError:
        pass

    return findings


def _scan_dart_file(path: Path) -> list[dict]:
    findings = []
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings
    for rule_id, severity, pattern, message in DART_PATTERNS:
        for i, line in enumerate(source.splitlines(), 1):
            if pattern.search(line):
                findings.append({
                    "rule": rule_id, "severity": severity,
                    "file": str(path), "line": i,
                    "message": message, "snippet": line.strip()[:120],
                })
    return findings


def _deterministic_exec(findings: list[dict]) -> dict:
    warns = sum(1 for f in findings if f["severity"] == "WARN")
    infos = sum(1 for f in findings if f["severity"] == "INFO")
    files = len({f["file"] for f in findings})
    rules = Counter(f["rule"] for f in findings)
    top_rule = rules.most_common(1)[0][0] if rules else "—"
    summary = (
        f"Code review: {len(findings)} Layer-1 finding(s) across {files} file(s) — "
        f"{warns} WARN, {infos} INFO. Top rule: {top_rule}."
    )
    key_points = [
        f"{warns} WARN-level finding(s)",
        f"{infos} INFO-level finding(s)",
        f"Top rule: {top_rule}",
        f"{files} file(s) impacted",
    ]
    reviewer_notes = ["AI unavailable — see report below."]
    if warns:
        reviewer_notes.append("WARN findings should be addressed before merge.")
    elif infos:
        reviewer_notes.append("Only INFO findings — advisory.")
    else:
        reviewer_notes.append("No Layer-1 findings detected.")
    recommended_actions: list[str] = []
    if warns:
        recommended_actions.append(f"Resolve the {warns} WARN finding(s)")
    if infos:
        recommended_actions.append(f"Review the {infos} INFO finding(s)")
    if not recommended_actions:
        recommended_actions.append("No code-quality blockers — proceed with review")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(findings: list[dict], ci_signals: list[str] | None = None) -> str:
    warns = sum(1 for f in findings if f["severity"] == "WARN")
    infos = sum(1 for f in findings if f["severity"] == "INFO")
    rules = Counter(f["rule"] for f in findings).most_common(5)
    lines = [
        f"Code review: {len(findings)} finding(s) — {warns} WARN, {infos} INFO.",
        "Top rules: " + ", ".join(f"{r}({c})" for r, c in rules) if rules else "Top rules: none",
        "",
        "Top findings:",
    ]
    for f in findings[:10]:
        lines.append(f"- [{f['severity']}] {f['rule']} {Path(f['file']).name}:{f['line']} — {f['message']}")
    if ci_signals:
        lines.append("")
        lines.append("CI lint/test evidence:")
        lines.extend(ci_signals)
    return "\n".join(lines)


def _sanitize_ai_analysis(text: str | None) -> str | None:
    """Remove non-actionable environment disclaimers from model output."""
    if not text:
        return text
    cleaned_lines: list[str] = []
    for line in text.splitlines():
        if _AI_DISCLAIMER_RE.match(line.strip()):
            continue
        cleaned_lines.append(line)
    cleaned = "\n".join(cleaned_lines).strip()
    return cleaned or None


def _render_findings_table(findings: list[dict], cap: int = 80) -> str:
    """Render a markdown findings table (existing 5-column layout preserved)."""
    rows = ["| Rule | Severity | File | Line | Message |",
            "|------|----------|------|------|---------|"]
    for f in findings[:cap]:
        fname = Path(f["file"]).name
        rows.append(
            f"| `{f['rule']}` | {sev_badge(f['severity'])} | "
            f"`{fname}` | {f['line']} | {f['message']} |"
        )
    if len(findings) > cap:
        rows.append(f"| … | | | | *{len(findings) - cap} more — see artifact* |")
    return "\n".join(rows)


def _build_report(primary: list[dict], supplementary: list[dict],
                  ai_analysis: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    """Render the two-tier code-review report.

    The primary table (findings on diff-added lines) is rendered inline (or
    auto-collapsed via the universal 800-char rule). The supplementary table
    (findings in touched files but on unchanged lines) is always rendered
    inside a separately-labeled closed <details> block.
    """
    warns = [f for f in primary if f["severity"] == "WARN"]
    infos = [f for f in primary if f["severity"] == "INFO"]

    blocks: list[str] = []
    subtitle = f"{len(primary)} MR-diff finding(s)"
    if supplementary:
        subtitle += f" · {len(supplementary)} supplementary in touched files"
    blocks.append(agent_header("🔍", "Code Review", "🤖🏺 Osiris", mode,
                               subtitle=subtitle))
    # The executive block is built from the primary bucket only (Copilot sees only primary).
    blocks.append(render_exec_block(exec_block, _deterministic_exec(primary)))

    # KPI card — 4 cells (WARN / INFO / Total MR diff / Supplementary)
    blocks.append(kpi_card([
        ("🟠 WARN",          str(len(warns))),
        ("🔵 INFO",          str(len(infos))),
        ("📋 Total MR diff", str(len(primary))),
        ("📎 Supplementary", str(len(supplementary))),
    ]))
    blocks.append("")

    # Mermaid pie + top-rule KPI use primary findings (the actual MR signal).
    if primary:
        rule_counts = Counter(f["rule"] for f in primary)
        blocks.append(mermaid_pie("Findings by rule", dict(rule_counts.most_common(8))))
        blocks.append("")
        blocks.append(kpi_card([(rule, str(cnt)) for rule, cnt in rule_counts.most_common(5)]))
        blocks.append("")

    # Primary findings table — inline if short, auto-collapse if > 800 chars.
    if primary:
        primary_table = _render_findings_table(primary)
        blocks.append("### 📌 Findings — MR diff (lines + only)")
        blocks.append("")
        blocks.append(
            auto_details(
                f"📋 {len(primary)} MR-diff finding(s) — click to expand",
                primary_table,
                threshold=AUTO_COLLAPSE_THRESHOLD,
            )
        )
        blocks.append("")
    else:
        blocks.append("✅ No Layer-1 issues on the MR diff.\n")

    # Supplementary findings — always inside a closed <details>, never sent to Copilot.
    if supplementary:
        supp_table = _render_findings_table(supplementary)
        blocks.append(
            details(
                f"📎 {len(supplementary)} supplementary finding(s) in touched files — click to expand",
                supp_table,
            )
        )
        blocks.append("")

    # AI analysis — auto-collapse via universal rule (long AI text → closed by default).
    if ai_analysis:
        blocks.append(
            auto_details(
                "🤖 AI Analysis — claude-sonnet-4.6",
                ai_analysis,
                threshold=AUTO_COLLAPSE_THRESHOLD,
            )
        )
        blocks.append("")

    return "\n".join(blocks)


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> None:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    resp = httpx.post(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
                      json={"body": body}, verify=False, timeout=30)
    resp.raise_for_status()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid")
    parser.add_argument("--scan-dir", nargs="+", default=["backend", "flutter_app/lib"])
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    current_encoding = str(getattr(sys.stdout, 'encoding', '') or '').lower()
    if hasattr(sys.stdout, 'reconfigure') and current_encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    scan_excluded = {"gen", "tests", "__pycache__", ".venv"}

    # Compute file set + per-file added lines from the MR diff when applicable.
    diff_base = _diff_base()
    use_diff_scope = bool(args.mr_iid)
    added_lines: dict[str, set[int]] = {}
    if use_diff_scope:
        changed = _changed_files_from_diff(diff_base, args.scan_dir)
        added_lines = _added_line_set(diff_base)
        files_to_scan: list[Path] = changed
    else:
        files_to_scan = []
        for scan_dir in args.scan_dir:
            scan_path = Path(scan_dir)
            if not scan_path.exists():
                continue
            for f in scan_path.rglob("*.py"):
                if any(part in scan_excluded for part in f.parts):
                    continue
                files_to_scan.append(f)
            for f in scan_path.rglob("*.dart"):
                if any(part in DART_EXCLUDED for part in f.parts):
                    continue
                files_to_scan.append(f)

    findings: list[dict] = []
    for path in files_to_scan:
        if path.suffix == ".py":
            findings.extend(_scan_file(path))
        elif path.suffix == ".dart":
            findings.extend(_scan_dart_file(path))

    primary, supplementary = _split_findings(findings, added_lines)

    ci_signals = _collect_ci_lint_signals(Path("backend/reports/ci_inputs"))

    copilot = CopilotClient()
    # Copilot only ever sees the primary bucket — supplementary findings stay
    # local context, never sent to the model.
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(
            _exec_context(primary, ci_signals),
            scope="code-review",
        )
    ai_text = None
    if copilot.is_available() and primary:
        issues_lines = [
            f"- [{f['rule']}] {f['file']}:{f['line']} — {f['message']}"
            for f in primary[:10]
        ]
        if ci_signals:
            issues_lines.append("")
            issues_lines.append("Additional CI lint/test evidence:")
            issues_lines.extend(ci_signals)
        issues_str = "\n".join(issues_lines)[:4000]
        ai_text = copilot.review_findings(count=len(primary), issues=issues_str)
        ai_text = _sanitize_ai_analysis(ai_text)

    report = _build_report(primary, supplementary, ai_text,
                           copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(report, encoding="utf-8")
        _html = output_path.with_suffix(".html")
        _html.write_text(
            markdown_to_html(report, "Code Reviewer \u2014 \U0001f916\U0001f3fa Osiris", _ts),
            encoding="utf-8",
        )
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")

    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Code Review"))
