"""
CI/CD Agent — diagnoses pipeline failures and posts root-cause analysis.
Reads the last job log (passed via file or stdin) and calls claude-sonnet-4.6.
Symbolic name: 🤖🔥 Phoenix — Architecte pipeline.
"""
import argparse
import os
import sys
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import render_exec_block

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")


def _fetch_job_log(project_id: str, job_id: str) -> str:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/jobs/{job_id}/trace"
    resp = httpx.get(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
                     verify=False, timeout=30)
    if resp.status_code == 200:
        return resp.text[-4000:]  # last 4 KB
    return ""


def _extract_errors(log: str) -> list[str]:
    error_lines = []
    for line in log.splitlines():
        lower = line.lower()
        if any(kw in lower for kw in ("error", "fail", "exception", "traceback", "assert")):
            error_lines.append(line.strip()[:200])
    return error_lines[:30]


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> None:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    httpx.post(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
               json={"body": body}, verify=False, timeout=30).raise_for_status()


def _deterministic_exec(error_count: int, error_lines: list[str]) -> dict:
    top = error_lines[0] if error_lines else ""
    if error_count == 0:
        summary = "No error lines detected in the job log."
    else:
        summary = f"Pipeline failure: {error_count} error line(s) detected in job log."
    key_points = [
        f"{error_count} error/exception line(s) extracted",
    ]
    if top:
        key_points.append(f"Top error: {top[:100]}")
    notes = ["AI unavailable — see raw error lines below."]
    actions = [
        "Inspect the raw error lines and the failing stage in the pipeline.",
        "Reproduce the failure locally before merging.",
    ]
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": notes,
        "recommended_actions": actions,
    }


def _exec_context(error_count: int, error_lines: list[str]) -> str:
    head = f"Errors detected: {error_count}"
    sample = "\n".join(f"- {ln}" for ln in error_lines[:15])
    return f"{head}\n\nSample error lines:\n{sample}"[:4000]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid")
    parser.add_argument("--job-id")
    parser.add_argument("--log-file")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--output")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    if args.log_file:
        log = Path(args.log_file).read_text(encoding="utf-8", errors="replace")[-4000:]
    elif args.job_id:
        log = _fetch_job_log(args.project_id, args.job_id)
    else:
        log = sys.stdin.read()[-4000:]

    if not log.strip():
        print("⚠ No job log available — CI/CD agent skipped")
        return 0

    error_lines = _extract_errors(log)
    copilot = CopilotClient()

    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(
            _exec_context(len(error_lines), error_lines), scope="cicd"
        )

    ai_text = None
    if copilot.is_available():
        lines_str = "\n".join(f"- {ln}" for ln in error_lines[:15])
        ai_text = copilot.suggest_fix(count=len(error_lines), lines=lines_str)

    report_lines = ["## 🔧 CI/CD Agent — Failure Diagnosis — 🤖🔥 Phoenix\n",
                    f"*Mode: {copilot.mode}*\n",
                    render_exec_block(ai_exec, _deterministic_exec(len(error_lines), error_lines))]
    if error_lines:
        report_lines.append("**Detected error lines:**\n")
        report_lines.append("```")
        report_lines.extend(error_lines[:10])
        report_lines.append("```")
    if ai_text:
        report_lines.append("\n### 🤖 AI Root-Cause Analysis (claude-sonnet-4.6)\n")
        report_lines.append(ai_text)

    report = "\n".join(report_lines)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "CI/CD Diagnosis \u2014 \U0001f916\U0001f525 Phoenix", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("\u2714 MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "CI/CD Diagnosis"))
