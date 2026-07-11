"""
Test Coverage Agent — parses Cobertura XML from pytest (Python backend) + lcov.info (Flutter frontend).
Threshold: 60%. Layer 2: claude-sonnet-4.6 suggests missing test cases.
Symbolic name: 🤖🧪 TIA-Python — Mesureur de couverture.
"""
import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import (
    agent_header, collapsible_table, details, kpi_card, mermaid_bar,
    mermaid_pie, progress_bar, render_exec_block, status_badge,
)

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")
THRESHOLD = 60.0

# Source injection limits — stay within Copilot API token budget.
_SRC_MAX_FILES = 5
_SRC_MAX_CHARS = 2000


def _read_radon_context(radon_cc_path: Path, low_files: list[dict]) -> str:
    """Extract high-complexity functions from low-coverage files using radon_cc.json.

    Correlating low coverage with high complexity identifies the highest-priority
    test targets: complex + untested = highest risk.
    """
    if not radon_cc_path.exists():
        return ""
    try:
        data = json.loads(radon_cc_path.read_text(encoding="utf-8", errors="replace"))
    except Exception:  # noqa: BLE001
        return ""

    low_names = {Path(f["file"]).name for f in low_files}
    blocks: list[str] = []
    for filepath, entries in data.items():
        # radon JSON values can occasionally be objects, strings, or other non-list
        # shapes when the underlying file failed to parse. Skip those defensively.
        if not isinstance(entries, list):
            continue
        if Path(filepath).name not in low_names:
            continue
        complex_fns = [
            f"  - {e['name']}() CC={e['complexity']} rank={e['rank']} (line {e['lineno']})"
            for e in entries
            # Each entry must be a dict; rank check uses .get to tolerate missing keys.
            if isinstance(e, dict) and e.get("rank", "A") >= "C"  # C, D, E, F = moderate to alarming
        ]
        if complex_fns:
            blocks.append(f"{filepath}:")
            blocks.extend(complex_fns[:5])
    if not blocks:
        return ""
    return "Complex functions in low-coverage files (priority test targets):\n" + "\n".join(blocks)


def _read_source_context(low_files: list[dict], max_files: int = _SRC_MAX_FILES,
                         max_chars: int = _SRC_MAX_CHARS) -> str:
    """Read the actual source code of low-coverage Python files and return a formatted block.

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
            blocks.append(f"### {path} ({entry['coverage']}% coverage)\n```python\n{content}\n```")
        except OSError:
            pass
    return "\n\n".join(blocks) if blocks else "(source files not available)"


def _parse_coverage(xml_path: Path) -> tuple[float, list[dict]]:
    """Returns (total_pct, list of low-coverage files)."""
    tree = ET.parse(xml_path)
    root = tree.getroot()
    total = float(root.attrib.get("line-rate", 0)) * 100
    low_files = []
    for pkg in root.iter("package"):
        for cls in pkg.iter("class"):
            rate = float(cls.attrib.get("line-rate", 1)) * 100
            name = cls.attrib.get("filename", cls.attrib.get("name", "?"))
            if rate < THRESHOLD:
                low_files.append({"file": name, "coverage": round(rate, 1)})
    low_files.sort(key=lambda x: x["coverage"])
    return round(total, 1), low_files


def _parse_lcov(lcov_path: Path) -> tuple[float, list[dict]]:
    """Parse lcov.info and return (total_pct, low_coverage_files)."""
    try:
        content = lcov_path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return 0.0, []

    files: dict[str, dict] = {}
    current: str | None = None
    for line in content.splitlines():
        if line.startswith("SF:"):
            current = line[3:].strip()
            files[current] = {"lf": 0, "lh": 0}
        elif line.startswith("LF:") and current:
            files[current]["lf"] = int(line[3:].strip())
        elif line.startswith("LH:") and current:
            files[current]["lh"] = int(line[3:].strip())
        elif line.startswith("end_of_record"):
            current = None

    total_lf = sum(v["lf"] for v in files.values())
    total_lh = sum(v["lh"] for v in files.values())
    total_pct = round((total_lh / total_lf * 100) if total_lf else 0.0, 1)

    low_files = [
        {"file": f, "coverage": round(v["lh"] / v["lf"] * 100, 1)}
        for f, v in files.items() if v["lf"] > 0 and (v["lh"] / v["lf"] * 100) < THRESHOLD
    ]
    low_files.sort(key=lambda x: x["coverage"])
    return total_pct, low_files


def _deterministic_exec(total: float, low_files: list[dict],
                        flutter_total: float | None, flutter_low: list[dict]) -> dict:
    py_ok = total >= THRESHOLD
    fl_ok = flutter_total is not None and flutter_total >= THRESHOLD
    parts = [f"Python coverage {total}% ({'PASS' if py_ok else 'FAIL'} ≥ {THRESHOLD}%)"]
    if flutter_total is not None:
        parts.append(f"Flutter coverage {flutter_total}% ({'PASS' if fl_ok else 'FAIL'} ≥ {THRESHOLD}%)")
    summary = " — ".join(parts) + f". {len(low_files)} Python low-coverage file(s)."
    key_points = [
        f"Python total: {total}% (threshold {THRESHOLD}%)",
        f"{len(low_files)} Python file(s) below threshold",
    ]
    if flutter_total is not None:
        key_points.append(f"Flutter total: {flutter_total}% — {len(flutter_low)} low file(s)")
    if low_files:
        worst = low_files[0]
        key_points.append(f"Lowest Python file: {Path(worst['file']).name} ({worst['coverage']}%)")
    reviewer_notes = ["AI unavailable — see report below."]
    if not py_ok or (flutter_total is not None and not fl_ok):
        reviewer_notes.append("Coverage below threshold — add tests before merge.")
    else:
        reviewer_notes.append("All coverage thresholds met.")
    recommended_actions: list[str] = []
    if not py_ok:
        recommended_actions.append(f"Raise Python coverage from {total}% to ≥ {THRESHOLD}%")
    if flutter_total is not None and not fl_ok:
        recommended_actions.append(f"Raise Flutter coverage from {flutter_total}% to ≥ {THRESHOLD}%")
    if low_files:
        recommended_actions.append(f"Add tests for the {len(low_files)} low-coverage Python file(s)")
    if not recommended_actions:
        recommended_actions.append("Coverage gate green — no action required")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(total: float, low_files: list[dict],
                  flutter_total: float | None, flutter_low: list[dict]) -> str:
    lines = [
        f"Python total coverage: {total}% (threshold {THRESHOLD}%)",
        f"Python low-coverage files: {len(low_files)}",
    ]
    if flutter_total is not None:
        lines.append(f"Flutter total coverage: {flutter_total}% — {len(flutter_low)} low file(s)")
    lines.append("")
    lines.append("Top low-coverage Python files:")
    for f in low_files[:8]:
        lines.append(f"- {Path(f['file']).name}: {f['coverage']}%")
    if flutter_low:
        lines.append("")
        lines.append("Top low-coverage Flutter files:")
        for f in flutter_low[:5]:
            lines.append(f"- {Path(f['file']).name}: {f['coverage']}%")
    return "\n".join(lines)


def _build_report(total: float, low_files: list[dict], flutter_total: float | None, flutter_low: list[dict], ai_text: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    blocks: list[str] = []
    py_ok = total >= THRESHOLD
    blocks.append(agent_header("📊", "Test Coverage", "🤖🧪 TIA-Python", mode,
                               subtitle=f"threshold {THRESHOLD}%"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(total, low_files, flutter_total, flutter_low)))

    # KPI
    kpi: list[tuple[str, str]] = [
        ("🐍 Python", f"{status_badge(py_ok)} {total}%"),
        ("📂 Low Py", str(len(low_files))),
    ]
    if flutter_total is not None:
        fl_ok = flutter_total >= THRESHOLD
        kpi.append(("🇳 Flutter", f"{status_badge(fl_ok)} {flutter_total}%"))
        kpi.append(("📂 Low Dart", str(len(flutter_low))))
    blocks.append(kpi_card(kpi))
    blocks.append("")

    # Progress bars
    blocks.append(f"**🐍 Python backend:** {progress_bar(total)}\n")
    if flutter_total is not None:
        blocks.append(f"**🇳 Flutter frontend:** {progress_bar(flutter_total)}\n")
    else:
        blocks.append("**🇳 Flutter frontend:** ⚠️ `lcov.info` not found — skipped.\n")

    # Bar chart top-10 lowest Python files
    if low_files:
        labels = [Path(f['file']).name for f in low_files[:10]]
        values = [f['coverage'] for f in low_files[:10]]
        blocks.append(mermaid_bar("Python files — lowest coverage", labels, values, "Coverage %"))
        blocks.append("")

    # Bar chart top-10 lowest Flutter files
    if flutter_low:
        labels = [Path(f['file']).name for f in flutter_low[:10]]
        values = [f['coverage'] for f in flutter_low[:10]]
        blocks.append(mermaid_bar("Dart files — lowest coverage", labels, values, "Coverage %"))
        blocks.append("")

    # Tables (collapsible if long)
    if low_files:
        rows = [f"| `{Path(f['file']).name}` | {progress_bar(f['coverage'], width=10)} |" for f in low_files]
        blocks.append("**🐍 Python low-coverage files:**\n")
        blocks.append(collapsible_table("📂 Python files", ["| File | Coverage |", "|------|----------|"], rows, visible_count=10))
        blocks.append("")

    if flutter_low:
        rows = [f"| `{Path(f['file']).name}` | {progress_bar(f['coverage'], width=10)} |" for f in flutter_low]
        blocks.append("**🇳 Flutter low-coverage files:**\n")
        blocks.append(collapsible_table("📂 Dart files", ["| File | Coverage |", "|------|----------|"], rows, visible_count=10))
        blocks.append("")

    if ai_text:
        blocks.append(details("🤖 AI Suggestions — claude-sonnet-4.6", ai_text))
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
    parser.add_argument("--coverage-file", default="backend/reports/coverage.xml")
    parser.add_argument("--flutter-coverage", default="backend/reports/ci_inputs/lcov.info")
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    current_encoding = str(getattr(sys.stdout, 'encoding', '') or '').lower()
    if hasattr(sys.stdout, 'reconfigure') and current_encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    cov_path = Path(args.coverage_file)
    flutter_cov_path = Path(args.flutter_coverage)
    flutter_total: float | None = None
    flutter_low: list[dict] = []

    if not cov_path.exists():
        report = (
            "## 📊 Test Coverage Agent\n\n"
            "*Mode: N/A*\n\n"
            f"⚠ coverage file not found: `{cov_path}` — skipped."
        )
        print(f"⚠ coverage file not found: {cov_path} — skipping", file=sys.stderr)
        print(report)
        if args.output:
            import datetime
            _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
            output_path = Path(args.output)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(report, encoding="utf-8")
            _html = output_path.with_suffix(".html")
            _html.write_text(markdown_to_html(report, "Test Coverage \u2014 \U0001f916\U0001f9ea TIA-Python", _ts), encoding="utf-8")
            print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")
        return 0

    total, low_files = _parse_coverage(cov_path)
    if flutter_cov_path.exists():
        flutter_total, flutter_low = _parse_lcov(flutter_cov_path)

    radon_cc_path = Path("backend/reports/ci_inputs/radon_cc.json")
    radon_context = _read_radon_context(radon_cc_path, low_files)

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        exec_ctx = _exec_context(total, low_files, flutter_total, flutter_low)
        if radon_context:
            exec_ctx += "\n\n" + radon_context
        ai_exec = copilot.generate_executive_summary(exec_ctx, scope="python-coverage")
    ai_text = None
    if copilot.is_available() and (low_files or flutter_low):
        py_part = "\n".join(f"- {f['file']}: {f['coverage']}%" for f in low_files[:8])
        fl_part = "\n".join(f"- {f['file']}: {f['coverage']}%" for f in flutter_low[:8])
        combined = ""
        if py_part:
            combined += f"Python low-coverage files:\n{py_part}\n"
        if fl_part:
            combined += f"Flutter/Dart low-coverage files:\n{fl_part}"
        source_context = _read_source_context(low_files)
        if radon_context:
            source_context += "\n\n" + radon_context
        ai_text = copilot.suggest_tests(
            threshold=int(THRESHOLD), total=total, files=combined.strip(),
            source_context=source_context,
        )

    report = _build_report(total, low_files, flutter_total, flutter_low, ai_text, copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(report, encoding="utf-8")
        _html = output_path.with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Test Coverage \u2014 \U0001f916\U0001f9ea TIA-Python", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Test Coverage"))
