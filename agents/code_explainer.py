"""
Code Explainer Agent — explains the MR diff in plain English for reviewers.
Fetches the MR diff from GitLab API and passes it to claude-sonnet-4.6.
Symbolic name: 🤖🪨 Rosetta — Traducteur de code.
"""
import argparse
import os
import sys
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import agent_header, details, kpi_card, render_exec_block

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")


# ── Diff fetching limits ──────────────────────────────────────────────────────
PER_FILE_CAP = 3000      # per-file diff truncation (chars)
TOTAL_CAP = 60_000       # total assembled diff cap (chars) — well under MAX_PROMPT_LEN
PER_PAGE = 100           # GitLab API max page size for /diffs

# Path suffixes / fragments identifying machine-generated files. These are
# rendered last so the cap preferentially truncates them, not human code.
_GENERATED_FRAGMENTS = (
    "gen/",
    "_pb2.py",
    "_pb2_grpc.py",
    "ng_sdk_whl/extracted/",
    "flutter_app/lib/grpc/generated/",
)


def _is_generated(path: str) -> bool:
    """Return True when ``path`` matches any of the generated-file markers."""
    return any(fragment in path for fragment in _GENERATED_FRAGMENTS)


def _fetch_mr_diff(project_id: str, mr_iid: str) -> tuple[str, int]:
    """Fetch the MR diff with pagination, human-file priority, and size caps.

    Returns ``(diff_text, total_files_from_api)`` where:
      * ``diff_text`` is a markdown-fenced concatenation of per-file diffs,
        each truncated to PER_FILE_CAP chars, with the total cumulative size
        bounded by TOTAL_CAP. Generated files are appended last and may be
        truncated/skipped first.
      * ``total_files_from_api`` is the total number of files reported by the
        GitLab API, preserving the KPI accuracy even when some files were
        omitted from the prompt due to caps.
    """
    base_url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/diffs"
    all_diffs: list[dict] = []
    page = 1
    while True:
        resp = httpx.get(
            base_url,
            headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
            verify=False,
            timeout=30,
            params={"per_page": PER_PAGE, "page": page},
        )
        if resp.status_code != 200:
            break
        batch = resp.json()
        if not batch:
            break
        all_diffs.extend(batch)
        if len(batch) < PER_PAGE:
            break
        page += 1

    if not all_diffs:
        return "", 0

    # Sort so non-generated files come first; the cap then preferentially
    # truncates the generated tail rather than human-authored content.
    sorted_diffs = sorted(
        all_diffs,
        key=lambda d: (_is_generated(d.get("new_path", "")), d.get("new_path", "")),
    )

    chunks: list[str] = []
    total_size = 0
    files_included = 0
    for d in sorted_diffs:
        path = d.get("new_path", "?")
        diff_body = d.get("diff", "")[:PER_FILE_CAP]
        chunk = f"### {path}\n```diff\n{diff_body}\n```"
        if total_size + len(chunk) > TOTAL_CAP:
            break
        chunks.append(chunk)
        total_size += len(chunk)
        files_included += 1

    skipped = len(all_diffs) - files_included
    if skipped > 0:
        chunks.append(
            f"\n*({skipped} more file(s) truncated — see GitLab Changes tab)*"
        )

    return "\n\n".join(chunks), len(all_diffs)


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> None:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    httpx.post(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
               json={"body": body}, verify=False, timeout=30).raise_for_status()


def _deterministic_exec(file_count: int, added_lines: int, ai_ok: bool) -> dict:
    summary = (
        f"Code explainer: MR touches {file_count} file(s) with ~{added_lines} added line(s). "
        f"AI explanation: {'available' if ai_ok else 'unavailable'}."
    )
    key_points = [
        f"Files touched: {file_count}",
        f"Added lines (truncated diff): {added_lines}",
        f"AI explanation: {'available' if ai_ok else 'unavailable'}",
    ]
    reviewer_notes = ["AI unavailable — see report below."]
    if ai_ok:
        reviewer_notes.append("Use the AI explanation alongside the raw diff for context.")
    else:
        reviewer_notes.append("AI explanation skipped — inspect the raw diff manually.")
    recommended_actions = [
        "Read the AI explanation to understand intent" if ai_ok else "Inspect the raw diff to understand the change",
        "Cross-check the diff against the MR description and linked ticket",
    ]
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(file_count: int, added_lines: int, diff_text: str) -> str:
    snippet = diff_text[:2000]
    return (
        f"MR diff summary: {file_count} file(s), ~{added_lines} added line(s).\n\n"
        f"Diff excerpt (truncated):\n{snippet}"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid", required=False, default=None)
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--output")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    if not args.mr_iid:
        print("⚠ No MR IID provided — code explainer skipped (push pipeline, not a merge request)")
        return 0

    copilot = CopilotClient()
    if not copilot.is_available():
        print("⚠ Copilot not available — code explainer skipped")
        return 0

    diff_text, file_count = _fetch_mr_diff(args.project_id, args.mr_iid)
    if not diff_text:
        print("⚠ No diff found for this MR")
        return 0

    explanation = copilot.explain_code(diff_text)
    added_lines = sum(
        1 for line in diff_text.splitlines()
        if line.startswith("+") and not line.startswith("+++")
    )
    ai_exec = copilot.generate_executive_summary(
        _exec_context(file_count, added_lines, diff_text), scope="explain"
    )

    blocks: list[str] = []
    blocks.append(agent_header("💡", "Code Explainer", "🤖🪸 Rosetta", copilot.mode,
                               subtitle="plain-English MR summary"))
    blocks.append(render_exec_block(
        ai_exec, _deterministic_exec(file_count, added_lines, ai_ok=explanation is not None)
    ))
    blocks.append(kpi_card([
        ("📄 Files", str(file_count)),
        ("🧠 Model", "claude-sonnet-4.6"),
    ]))
    blocks.append("")
    blocks.append(explanation)
    blocks.append("")
    blocks.append(details("🔍 Raw diff (truncated)", diff_text))
    report = "\n".join(blocks)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Code Explainer \u2014 \U0001f916\U0001fab8 Rosetta", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("\u2714 MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Code Explainer"))
