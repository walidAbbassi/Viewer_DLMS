"""
Flutter Coverage Agent — parses lcov.info from flutter test, posts per-file coverage table.
Threshold: 60%. Layer 2: claude-sonnet-4.6 suggests Dart test cases for low-coverage widgets.
NEW: no reference equivalent — specific to Viewer NG Flutter frontend.
Symbolic name: 🤖🐾 Laika-Flutter — Mesureur de couverture Flutter.
"""
import argparse
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
THRESHOLD = 60.0

# Source injection limits — stay within Copilot API token budget.
_SRC_MAX_FILES = 5
_SRC_MAX_CHARS = 2000


def _read_source_context(low_files: list[dict], max_files: int = _SRC_MAX_FILES,
                         max_chars: int = _SRC_MAX_CHARS) -> str:
    """Read the actual source code of low-coverage Dart files and return a formatted block.

    Files are read locally (no LLM tool call) to avoid 'filesystem access blocked' errors
    in the Copilot API sandbox. Only files that exist on disk are included.
    """
    blocks: list[str] = []
    for entry in low_files[:max_files]:
        path = Path(entry["file"])
        if not path.exists():
            continue
        try:
            content = path.read_text(encoding="utf-8", errors="replace")[:max_chars]
            blocks.append(f"### {path} ({entry['coverage']}% coverage)\n```dart\n{content}\n```")
        except OSError:
            pass
    return "\n\n".join(blocks) if blocks else "(source files not available)"


def _parse_lcov(lcov_path: Path) -> tuple[float, list[dict]]:
    """
    Parse lcov.info and return (total_pct, per_file_list).
    lcov format:
      SF:<source_file>
      DA:<line>,<hit_count>
      end_of_record
    """
    files = []
    current: dict = {}
    try:
        with open(lcov_path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if line.startswith("SF:"):
                    current = {"file": line[3:], "lines": 0, "hit": 0}
                elif line.startswith("DA:"):
                    parts = line[3:].split(",")
                    if len(parts) >= 2:
                        current["lines"] = current.get("lines", 0) + 1
                        if parts[1].strip() != "0":
                            current["hit"] = current.get("hit", 0) + 1
                elif line == "end_of_record" and current:
                    pct = round(current["hit"] / current["lines"] * 100, 1) if current["lines"] else 100.0
                    files.append({
                        "file": current["file"],
                        "lines": current["lines"],
                        "hit": current["hit"],
                        "coverage": pct,
                    })
                    current = {}
    except OSError:
        pass

    total_lines = sum(f["lines"] for f in files)
    total_hit = sum(f["hit"] for f in files)
    total_pct = round(total_hit / total_lines * 100, 1) if total_lines else 0.0
    return total_pct, files


def _deterministic_exec(total: float, files: list[dict]) -> dict:
    ok = total >= THRESHOLD
    low = sorted([f for f in files if f["coverage"] < THRESHOLD], key=lambda x: x["coverage"])
    summary = (
        f"Flutter coverage {total}% ({'PASS' if ok else 'FAIL'} ≥ {THRESHOLD}%) — "
        f"{len(files)} file(s), {len(low)} below threshold."
    )
    key_points = [
        f"Total coverage: {total}% (threshold {THRESHOLD}%)",
        f"{len(files)} Dart file(s) measured",
        f"{len(low)} file(s) below threshold",
    ]
    if low:
        worst = low[0]
        key_points.append(f"Lowest: {Path(worst['file']).name} ({worst['coverage']}%)")
    reviewer_notes = ["AI unavailable — see report below."]
    if not ok:
        reviewer_notes.append("Coverage below threshold — add Dart tests before merge.")
    else:
        reviewer_notes.append("Coverage threshold met.")
    recommended_actions: list[str] = []
    if not ok:
        recommended_actions.append(f"Raise Flutter coverage from {total}% to ≥ {THRESHOLD}%")
    if low:
        recommended_actions.append(f"Add tests for the {len(low)} low-coverage Dart file(s)")
    if not recommended_actions:
        recommended_actions.append("Coverage gate green — no action required")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(total: float, files: list[dict]) -> str:
    low = sorted([f for f in files if f["coverage"] < THRESHOLD], key=lambda x: x["coverage"])
    lines = [
        f"Flutter total coverage: {total}% (threshold {THRESHOLD}%)",
        f"Files measured: {len(files)} — below threshold: {len(low)}",
        "",
        "Top low-coverage Dart files:",
    ]
    for f in low[:10]:
        lines.append(f"- {Path(f['file']).name}: {f['coverage']}% ({f['hit']}/{f['lines']} lines)")
    return "\n".join(lines)


def _build_report(total: float, files: list[dict], ai_text: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    ok = total >= THRESHOLD
    low = sorted([f for f in files if f["coverage"] < THRESHOLD], key=lambda x: x["coverage"])
    blocks: list[str] = []
    blocks.append(agent_header("🦋", "Flutter Coverage", "🤖🐾 Laika-Flutter", mode,
                               subtitle=f"threshold {THRESHOLD}%"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(total, files)))
    blocks.append(kpi_card([
        ("🇳 Total",  f"{status_badge(ok)} {total}%"),
        ("📂 Files",  str(len(files))),
        ("⚠️ Low",     str(len(low))),
    ]))
    blocks.append("")
    blocks.append(f"**Flutter frontend coverage:** {progress_bar(total)}\n")

    if low:
        labels = [Path(f['file']).name for f in low[:10]]
        values = [f['coverage'] for f in low[:10]]
        blocks.append(mermaid_bar("Lowest-coverage Dart files", labels, values, "Coverage %"))
        blocks.append("")
        rows = [f"| `{Path(f['file']).name}` | {progress_bar(f['coverage'], width=10)} | {f['hit']}/{f['lines']} |" for f in low]
        blocks.append(collapsible_table("📂 Low-coverage files",
                                        ["| File | Coverage | Lines |", "|------|----------|-------|"],
                                        rows, visible_count=10))
        blocks.append("")
    else:
        blocks.append("✅ All files meet coverage threshold.\n")

    if ai_text:
        blocks.append(details("🤖 AI Test Suggestions — claude-sonnet-4.6", ai_text))
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
    parser.add_argument("--lcov-file", default="flutter_app/coverage/lcov.info")
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    lcov_path = Path(args.lcov_file)
    if not lcov_path.exists():
        print(f"⚠ lcov file not found: {lcov_path} — skipping", file=sys.stderr)
        return 0

    total, files = _parse_lcov(lcov_path)
    low = [f for f in files if f["coverage"] < THRESHOLD]

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(_exec_context(total, files), scope="flutter-coverage")
    ai_text = None
    if copilot.is_available() and low:
        files_str = "\n".join(
            f"- {f['file']}: {f['coverage']}% ({f['hit']}/{f['lines']} lines)" for f in low[:8]
        )
        source_context = _read_source_context(low)
        ai_text = copilot.suggest_flutter_tests(
            threshold=int(THRESHOLD), total=total, files=files_str,
            source_context=source_context,
        )

    report = _build_report(total, files, ai_text, copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Flutter Coverage \u2014 \U0001f916\U0001f43e Laika-Flutter", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Flutter Coverage"))
