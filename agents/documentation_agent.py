"""
Documentation Agent — AST docstring coverage scan on Python modules + Dart `///` coverage.
Threshold: 70%. Layer 2: claude-sonnet-4.6 suggests docstrings for undocumented functions.
Symbolic name: 🤖📜 Hermes — Transmetteur du savoir.
"""
import argparse
import ast
import os
import re
import sys
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import (
    agent_header, collapsible_table, details, kpi_card, mermaid_bar,
    progress_bar, render_exec_block, status_badge,
)

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")
MIN_COVERAGE = 70.0


def _scan_file(path: Path) -> dict:
    try:
        source = path.read_text(encoding="utf-8", errors="replace")
        tree = ast.parse(source)
    except (OSError, SyntaxError):
        return {"file": str(path), "total": 0, "documented": 0, "missing": []}

    total = 0
    documented = 0
    missing = []

    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            total += 1
            if (ast.get_docstring(node)):
                documented += 1
            else:
                missing.append({"name": node.name, "line": node.lineno,
                                 "type": "class" if isinstance(node, ast.ClassDef) else "function"})
    return {
        "file": str(path),
        "total": total,
        "documented": documented,
        "missing": missing,
    }


DART_FUNC_RE = re.compile(
    r'^\s*(?:(?:static|abstract|override|async)\s+)*'
    r'(?:Future|void|String|int|bool|double|List|Map|Set|Widget|State|'
    r'dynamic|Object|Uint8List|Stream|Iterable|[A-Z][a-zA-Z0-9_]*)'
    r'(?:<[^>]+>)?\s+(\w+)\s*\(',
)
DART_CLASS_RE = re.compile(r'^\s*(?:abstract\s+)?(?:class|mixin|enum|extension)\s+(\w+)')
DART_EXCLUDED_DIRS = {".dart_tool", "build", "generated", "__pycache__"}


def _scan_dart_file(path: Path) -> dict:
    try:
        raw_lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return {"file": str(path), "total": 0, "documented": 0, "missing": []}

    total = 0
    documented = 0
    missing = []

    for i, line in enumerate(raw_lines):
        class_m = DART_CLASS_RE.match(line)
        func_m = DART_FUNC_RE.match(line)
        name = None
        kind = None
        if class_m:
            name = class_m.group(1)
            kind = "class"
        elif func_m:
            name = func_m.group(1)
            kind = "function"

        if name and kind:
            total += 1
            # Check preceding non-empty line for ///
            j = i - 1
            while j >= 0 and raw_lines[j].strip() == "":
                j -= 1
            if j >= 0 and raw_lines[j].strip().startswith("///"):
                documented += 1
            else:
                missing.append({"name": name, "line": i + 1, "type": kind})

    return {"file": str(path), "total": total, "documented": documented, "missing": missing}


def _deterministic_exec(results: list[dict], min_cov: float) -> dict:
    total_all = sum(r["total"] for r in results)
    doc_all = sum(r["documented"] for r in results)
    pct = round(doc_all / total_all * 100, 1) if total_all else 100.0
    ok = pct >= min_cov
    undocumented = total_all - doc_all
    low = [
        r for r in results
        if r["total"] > 0 and r["documented"] / r["total"] * 100 < min_cov
    ]
    summary = (
        f"Docstring coverage {pct}% ({'PASS' if ok else 'FAIL'} ≥ {min_cov}%) — "
        f"{doc_all}/{total_all} symbols documented, {len(low)} low-coverage file(s)."
    )
    key_points = [
        f"Coverage: {pct}% (threshold {min_cov}%)",
        f"Documented: {doc_all}/{total_all} symbols",
        f"Undocumented: {undocumented} symbol(s)",
        f"{len(low)} file(s) below threshold",
    ]
    reviewer_notes = ["AI unavailable — see report below."]
    if not ok:
        reviewer_notes.append("Docstring coverage below threshold — add docstrings before merge.")
    else:
        reviewer_notes.append("Documentation threshold met.")
    recommended_actions: list[str] = []
    if undocumented:
        recommended_actions.append(f"Add docstrings to the {undocumented} undocumented symbol(s)")
    if low:
        recommended_actions.append(f"Prioritise the {len(low)} low-coverage file(s)")
    if not recommended_actions:
        recommended_actions.append("Documentation gate green — no action required")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(results: list[dict], min_cov: float) -> str:
    total_all = sum(r["total"] for r in results)
    doc_all = sum(r["documented"] for r in results)
    pct = round(doc_all / total_all * 100, 1) if total_all else 100.0
    low = sorted(
        [r for r in results if r["total"] > 0 and r["documented"] / r["total"] * 100 < min_cov],
        key=lambda x: x["documented"] / max(x["total"], 1),
    )
    lines = [
        f"Docstring coverage: {pct}% (threshold {min_cov}%)",
        f"Documented: {doc_all}/{total_all}; missing: {total_all - doc_all}",
        "",
        "Top low-coverage files:",
    ]
    for r in low[:10]:
        file_pct = round(r["documented"] / r["total"] * 100, 1)
        lines.append(f"- {Path(r['file']).name}: {file_pct}% ({len(r['missing'])} missing)")
    return "\n".join(lines)


def _build_report(results: list[dict], ai_text: str | None, mode: str, min_cov: float,
                  exec_block: dict | None = None) -> str:
    total_all = sum(r["total"] for r in results)
    doc_all = sum(r["documented"] for r in results)
    pct = round(doc_all / total_all * 100, 1) if total_all else 100.0
    ok = pct >= min_cov
    low = sorted(
        [r for r in results if r["total"] > 0 and r["documented"] / r["total"] * 100 < min_cov],
        key=lambda x: x["documented"] / max(x["total"], 1)
    )

    blocks: list[str] = []
    blocks.append(agent_header("📖", "Documentation", "🤖📜 Hermes", mode,
                               subtitle=f"threshold {min_cov}%"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(results, min_cov)))
    blocks.append(kpi_card([
        ("📊 Coverage", f"{status_badge(ok)} {pct}%"),
        ("📝 Documented", f"{doc_all}/{total_all}"),
        ("⚠️ Low files", str(len(low))),
    ]))
    blocks.append("")
    blocks.append(f"**Overall docstring coverage:** {progress_bar(pct)}\n")

    if low:
        labels = [Path(r['file']).name for r in low[:10]]
        values = [round(r['documented'] / r['total'] * 100, 1) for r in low[:10]]
        blocks.append(mermaid_bar("Lowest-documented files", labels, values, "Coverage %"))
        blocks.append("")
        rows = []
        for r in low:
            file_pct = round(r["documented"] / r["total"] * 100, 1)
            rows.append(f"| `{Path(r['file']).name}` | {progress_bar(file_pct, width=10)} | {len(r['missing'])} |")
        blocks.append(collapsible_table("📂 Low-coverage files",
                                        ["| File | Coverage | Missing |", "|------|----------|---------|"],
                                        rows, visible_count=10))
        blocks.append("")

    if ai_text:
        blocks.append(details("🤖 AI Docstring Suggestions — claude-sonnet-4.6", ai_text))
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
    parser.add_argument("--scan-dir", nargs="+", default=["backend", "flutter_app/lib"])
    parser.add_argument("--min-coverage", type=float, default=MIN_COVERAGE)
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    results = []
    for scan_dir in args.scan_dir:
        scan_path = Path(scan_dir)
        if not scan_path.exists():
            continue
        for f in scan_path.rglob("*.py"):
            results.append(_scan_file(f))
        for f in scan_path.rglob("*.dart"):
            if any(part in DART_EXCLUDED_DIRS for part in f.parts):
                continue
            results.append(_scan_dart_file(f))

    # Collect worst missing items for AI prompt
    all_missing = []
    for r in results:
        for m in r["missing"][:3]:
            all_missing.append(f"{Path(r['file']).name}:{m['line']} — {m['type']} `{m['name']}`")

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(
            _exec_context(results, args.min_coverage), scope="docs"
        )
    ai_text = None
    if copilot.is_available() and all_missing:
        ai_text = copilot.suggest_documentation(
            "\n".join(f"- {m}" for m in all_missing[:10])
        )

    report = _build_report(results, ai_text, copilot.mode, args.min_coverage, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Documentation \u2014 \U0001f916\U0001f4dc Hermes", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Documentation"))
