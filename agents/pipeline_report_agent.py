"""
Pipeline Report Agent — aggregates all agent reports into a single consolidated MR comment.
Reads report files from the artifacts folder (backend/reports/*.md).
Symbolic name: 🤖🌍 Atlas — Synthétiseur global.
"""
import argparse
import datetime
import html
import os
import re
import sys
from pathlib import Path

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient
from agents.mr_format import (
    agent_header,
    details,
    executive_summary,
    footer,
    kpi_card,
    mermaid_bar,
    mermaid_pie,
    status_badge,
)

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")
CI_PIPELINE_URL = os.environ.get("CI_PIPELINE_URL", "")
CI_COMMIT_SHORT_SHA = os.environ.get("CI_COMMIT_SHORT_SHA", "?")
CI_PIPELINE_ID = os.environ.get("CI_PIPELINE_ID", "")
CI_JOB_TOKEN = os.environ.get("CI_JOB_TOKEN", "")

EXECUTION_ORDER = [
    "code_reviewer",
    "code_explainer",
    "license_compliance_agent",
    "flutter_analyzer_agent",
    "flutter_coverage_agent",
    "test_coverage_agent",
    "dependency_audit_agent",
    "security_scanner",
    "documentation_agent",
    "pipeline_report_agent",
    "cicd_agent",
]

ORDERED_REPORT_STEMS = [
    "code_reviewer",
    "code_explainer",
    "license_compliance",
    "flutter_analyzer",
    "flutter_coverage",
    "test_coverage",
    "dependency_audit",
    "security_scanner",
    "documentation",
    "pipeline_report",
    "cicd_diagnosis",
]


# Icons used in the Agent Leaderboard and Per-Agent Reports sections.
# Covers the full status set produced by the GitLab-aware _scorecard.
_VERDICT_ICON = {
    "PASS":    "✅",
    "WARN":    "🟡",
    "FAIL":    "🔴",
    "RUNNING": "🔄",
    "SKIPPED": "⏭",
    "OTHER":   "❓",
}


AGENT_TITLES = {
    "code_reviewer":      ("🔍", "Code Reviewer",       "Osiris"),
    "code_explainer":     ("💡", "Code Explainer",      "Rosetta"),
    "license_compliance": ("⚖️",  "License Compliance",  "Themis"),
    "flutter_analyzer":   ("🦋", "Flutter Analyzer",    "Vostok"),
    "flutter_coverage":   ("🦋", "Flutter Coverage",    "Laika-Flutter"),
    "test_coverage":      ("🧪", "Test Coverage",       "TIA-Python"),
    "dependency_audit":   ("🔎", "Dependency Audit",    "Cassandra"),
    "security_scanner":   ("🔒", "Security Scanner",    "Anubis"),
    "documentation":      ("📖", "Documentation",       "Hermes"),
    "cicd_diagnosis":     ("🔧", "CI/CD Diagnosis",     "Phoenix"),
}


def _status_bucket(status: str) -> str:
    s = (status or "").lower().strip()
    if s in {"success", "passed"}:
        return "PASS"
    if s in {"failed", "canceled", "cancelled"}:
        return "FAIL"
    if s in {"running", "pending", "preparing"}:
        return "RUNNING"
    if s in {"manual", "created", "waiting_for_resource"}:
        return "WAITING"
    if s in {"skipped"}:
        return "SKIPPED"
    return "OTHER"


def _pct(numerator: int | float, denominator: int | float) -> float:
    if not denominator:
        return 0.0
    return round((float(numerator) / float(denominator)) * 100, 1)


def _fetch_pipeline_jobs(project_id: str, pipeline_id: str) -> list[dict]:
    """Fetch full job list for the current pipeline; fallback to empty on API failures."""
    if not project_id or not pipeline_id:
        return []

    headers: dict[str, str] = {}
    if GITLAB_TOKEN:
        headers["PRIVATE-TOKEN"] = GITLAB_TOKEN
    elif CI_JOB_TOKEN:
        headers["JOB-TOKEN"] = CI_JOB_TOKEN
    else:
        return []

    jobs: list[dict] = []
    page = 1
    while True:
        url = f"{GITLAB_URL}/api/v4/projects/{project_id}/pipelines/{pipeline_id}/jobs"
        try:
            resp = httpx.get(
                url,
                headers=headers,
                params={"per_page": 100, "page": page},
                verify=False,
                timeout=30,
            )
            resp.raise_for_status()
            chunk = resp.json()
            if not chunk:
                break
            jobs.extend(chunk)
            if len(chunk) < 100:
                break
            page += 1
        except Exception:
            return []
    return jobs


def _pipeline_metrics(jobs: list[dict]) -> dict:
    stage_map: dict[str, dict] = {}
    status_counts: dict[str, int] = {}
    durations: list[float] = []
    allow_failure_count = 0

    for job in jobs:
        stage = str(job.get("stage", "unknown"))
        status = str(job.get("status", "unknown"))
        status_counts[status] = status_counts.get(status, 0) + 1
        bucket = _status_bucket(status)
        if job.get("allow_failure", False):
            allow_failure_count += 1

        st = stage_map.setdefault(stage, {
            "total": 0,
            "pass": 0,
            "fail": 0,
            "running": 0,
            "waiting": 0,
            "skipped": 0,
            "other": 0,
            "duration": 0.0,
        })
        st["total"] += 1
        if bucket == "PASS":
            st["pass"] += 1
        elif bucket == "FAIL":
            st["fail"] += 1
        elif bucket == "RUNNING":
            st["running"] += 1
        elif bucket == "WAITING":
            st["waiting"] += 1
        elif bucket == "SKIPPED":
            st["skipped"] += 1
        else:
            st["other"] += 1

        dur = job.get("duration")
        if isinstance(dur, (int, float)):
            st["duration"] += float(dur)
            durations.append(float(dur))

    total = len(jobs)
    pass_count = sum(1 for j in jobs if _status_bucket(str(j.get("status", ""))) == "PASS")
    fail_count = sum(1 for j in jobs if _status_bucket(str(j.get("status", ""))) == "FAIL")
    run_count = sum(1 for j in jobs if _status_bucket(str(j.get("status", ""))) == "RUNNING")
    wait_count = sum(1 for j in jobs if _status_bucket(str(j.get("status", ""))) == "WAITING")
    skip_count = sum(1 for j in jobs if _status_bucket(str(j.get("status", ""))) == "SKIPPED")

    pass_ratio = round((pass_count / total) * 100, 1) if total else 0.0
    avg_duration = round(sum(durations) / len(durations), 1) if durations else 0.0

    top_slow_jobs = sorted(
        [
            {
                "name": str(j.get("name", "?")),
                "stage": str(j.get("stage", "?")),
                "duration": float(j.get("duration", 0.0) or 0.0),
                "status": str(j.get("status", "?")),
            }
            for j in jobs
            if isinstance(j.get("duration"), (int, float))
        ],
        key=lambda x: x["duration"],
        reverse=True,
    )[:8]

    stage_risk_index = {
        stage: round(data["fail"] * 3 + data["running"] * 1.5 + data["waiting"] * 1.0 + data["other"] * 1.0, 1)
        for stage, data in stage_map.items()
    }

    return {
        "total": total,
        "pass": pass_count,
        "fail": fail_count,
        "running": run_count,
        "waiting": wait_count,
        "skipped": skip_count,
        "pass_ratio": pass_ratio,
        "avg_duration": avg_duration,
        "allow_failure": allow_failure_count,
        "ratios": {
            "fail_ratio": _pct(fail_count, total),
            "active_ratio": _pct(run_count, total),
            "waiting_ratio": _pct(wait_count, total),
            "skip_ratio": _pct(skip_count, total),
            "allow_failure_ratio": _pct(allow_failure_count, total),
            "stability_ratio": _pct(pass_count, max(1, pass_count + fail_count)),
        },
        "top_slow_jobs": top_slow_jobs,
        "stage_risk_index": stage_risk_index,
        "status_counts": status_counts,
        "stages": stage_map,
    }


def _important_points(metrics: dict, scorecards: list[tuple[dict, dict]]) -> list[str]:
    pts: list[str] = []
    if metrics["fail"]:
        pts.append(f"{metrics['fail']} pipeline job(s) are failing and blocking a full green run")
    if metrics["running"] or metrics["waiting"]:
        pts.append(
            f"{metrics['running']} running + {metrics['waiting']} waiting/manual job(s) indicate pipeline still in progress"
        )
    if metrics["pass_ratio"] < 80 and metrics["total"]:
        pts.append(f"Pipeline pass ratio is {metrics['pass_ratio']}%, below 80% target")

    failing_agents = [r["name"] for r, s in scorecards if s["status"] == "FAIL"]
    if failing_agents:
        pts.append("Failing agent reports detected: " + ", ".join(failing_agents[:4]))

    if not pts:
        pts.append("No major blockers detected from current pipeline and agent evidence")
    return pts


def _action_propositions(metrics: dict, scorecards: list[tuple[dict, dict]]) -> dict[str, list[str]]:
    immediate: list[str] = []
    quality: list[str] = []
    optim: list[str] = []

    if metrics["fail"]:
        immediate.append("Resolve failed lint/test/review jobs before merge approval")
    if metrics["running"] or metrics["waiting"]:
        immediate.append("Wait for running/manual jobs completion before final decision")

    high_total = sum(s["high"] for _, s in scorecards)
    warn_total = sum(s["warn"] for _, s in scorecards)
    if high_total:
        quality.append(f"Triage {high_total} HIGH-severity findings from agent reports")
    if warn_total:
        quality.append(f"Review {warn_total} WARN signals and convert recurrent items into backlog tasks")
    if metrics["pass_ratio"] < 90 and metrics["total"]:
        quality.append("Increase stage quality gates to improve global pass ratio")

    optim.append("Keep copilot-check as central artifact hub for deterministic downstream analysis")
    optim.append("Publish this executive HTML as single entry point for stakeholders")

    return {
        "Immediate blockers": immediate,
        "Quality debt": quality,
        "Optimization opportunities": optim,
    }


def _conclusion_text(metrics: dict) -> str:
    if metrics["fail"] > 0:
        return (
            "Global conclusion: pipeline not ready for merge yet. "
            "Resolve failing jobs first, then re-evaluate quality debt and operational stability."
        )
    if metrics["running"] > 0 or metrics["waiting"] > 0:
        return (
            "Global conclusion: pipeline is in-progress. "
            "Decision should be deferred until running/manual jobs complete."
        )
    if metrics["pass_ratio"] >= 90:
        return (
            "Global conclusion: pipeline is healthy with high pass ratio. "
            "Merge can proceed after standard reviewer verification."
        )
    return (
        "Global conclusion: pipeline is mostly stable but improvement opportunities remain. "
        "Prioritize recurring warnings and slowest jobs to raise reliability."
    )


# KPI-cell regex patterns: match numeric values that sit next to the literal
# HIGH/WARN markers in a markdown table cell ("| 4 | HIGH |") or in a "KEY: N"
# pair ("HIGH: 4"). These deliberately ignore prose mentions ("highlight",
# "no failures detected") and decorative emoji.
_HIGH_CELL_RE = re.compile(r"(?:^|\|)\s*(\d+)\s*HIGH\b|HIGH[:\s]+(\d+)")
_WARN_CELL_RE = re.compile(r"(?:^|\|)\s*(\d+)\s*WARN\b|WARN[:\s]+(\d+)")

# Legacy fallback used only when no GitLab job_status is provided (e.g. tests
# or reports inspected outside the pipeline).
_LEGACY_HIGH_RE = re.compile(r"\b(HIGH|ERROR|FAIL|\u274c|\ud83d\udd34)\b")
_LEGACY_WARN_RE = re.compile(r"\b(WARN(ING)?|MEDIUM|\u26a0|\ud83d\udfe1)\b")


def _count_kpi_cells(text: str) -> tuple[int, int]:
    """Return (high, warn) counts extracted strictly from KPI table cells."""
    high = sum(int(g1 or g2) for g1, g2 in _HIGH_CELL_RE.findall(text))
    warn = sum(int(g1 or g2) for g1, g2 in _WARN_CELL_RE.findall(text))
    return high, warn


def _scorecard(report_text: str, job_status: str | None = None,
               allow_failure: bool = False) -> dict:
    """Derive PASS / WARN / FAIL / RUNNING / SKIPPED from the GitLab job status.

    When ``job_status`` is provided it is the source of truth; falling back to
    the legacy content-based regex only when status is unknown (None). HIGH and
    WARN counts come from refined KPI-cell patterns by default; the legacy
    regex is reused as fallback when no GitLab status is supplied so any
    historical caller that inspects MD files outside the pipeline still gets
    a usable verdict.
    """
    if job_status is not None:
        js = job_status.lower().strip()
        if js in ("success", "passed"):
            status = "PASS"
        elif js == "failed":
            status = "WARN" if allow_failure else "FAIL"
        elif js in ("running", "pending"):
            status = "RUNNING"
        elif js == "skipped":
            status = "SKIPPED"
        else:
            status = "OTHER"
        high, warn = _count_kpi_cells(report_text)
        return {"status": status, "high": high, "warn": warn,
                "job_status": job_status, "allow_failure": allow_failure}

    # Legacy fallback: no job context provided.
    high = len(_LEGACY_HIGH_RE.findall(report_text))
    warn = len(_LEGACY_WARN_RE.findall(report_text))
    if high > 0:
        status = "FAIL"
    elif warn > 0:
        status = "WARN"
    else:
        status = "PASS"
    return {"status": status, "high": high, "warn": warn,
            "job_status": None, "allow_failure": False}


def _load_reports(reports_dir: Path) -> list[dict]:
    reports = []
    report_by_stem = {}
    for md_file in sorted(reports_dir.glob("*.md")):
        content = md_file.read_text(encoding="utf-8", errors="replace")
        report_by_stem[md_file.stem] = {"name": md_file.stem, "content": content}

    for stem in ORDERED_REPORT_STEMS:
        if stem in report_by_stem:
            reports.append(report_by_stem[stem])

    for stem in sorted(report_by_stem):
        if stem not in ORDERED_REPORT_STEMS:
            reports.append(report_by_stem[stem])

    return reports


def _deterministic_exec(scorecards: list[tuple[dict, dict]]) -> dict[str, str | list[str]]:
    """Build a fallback Executive Summary from Layer-1 scorecards (no AI)."""
    pass_count = sum(1 for _, s in scorecards if s["status"] == "PASS")
    warn_count = sum(1 for _, s in scorecards if s["status"] == "WARN")
    fail_count = sum(1 for _, s in scorecards if s["status"] == "FAIL")
    total = len(scorecards)
    high_total = sum(s["high"] for _, s in scorecards)
    warn_total = sum(s["warn"] for _, s in scorecards)

    verdict = "FAIL" if fail_count else ("WARN" if warn_count else "PASS")
    summary = (
        f"Pipeline verdict: {verdict}. {total} agent reports analyzed: "
        f"{pass_count} PASS, {warn_count} WARN, {fail_count} FAIL. "
        f"Aggregated counts: {high_total} HIGH, {warn_total} WARN signals."
    )
    key_points: list[str] = [
        f"{total} agents executed in this pipeline run",
        f"{pass_count} green / {warn_count} amber / {fail_count} red verdicts",
        f"{high_total} HIGH-severity findings across all reports",
    ]
    failing = [r["name"] for r, s in scorecards if s["status"] == "FAIL"]
    if failing:
        key_points.append("Failing agents: " + ", ".join(failing[:3]))

    reviewer_notes: list[str] = ["AI unavailable — see per-agent reports below for full detail."]
    if fail_count:
        reviewer_notes.append("At least one agent reported FAIL — do not merge until resolved.")
    elif warn_count:
        reviewer_notes.append("WARN signals present — review before merging.")
    else:
        reviewer_notes.append("All agents green — safe to merge after manual review.")

    recommended_actions: list[str] = []
    if fail_count:
        recommended_actions.append("Fix the FAIL agent reports listed above before merging")
    if high_total:
        recommended_actions.append(f"Triage the {high_total} HIGH-severity findings")
    if warn_total:
        recommended_actions.append(f"Review the {warn_total} WARN signals")
    if not recommended_actions:
        recommended_actions.append("Proceed with code review — no blocking findings detected")

    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _build_summary(
    reports: list[dict],
    exec_block: dict[str, str | list[str]] | None,
    ai_powered: bool,
    pipeline_jobs: list[dict],
    metrics: dict,
) -> str:
    # Map each report stem to its GitLab job (when present). The conventional
    # name is `agent_<stem>` — e.g. report `code_reviewer` → job `agent_code_reviewer`.
    job_by_name: dict[str, dict] = {j.get("name", ""): j for j in pipeline_jobs}

    def _scorecard_for(r: dict) -> dict:
        job = job_by_name.get(f"agent_{r['name']}")
        if job is None:
            return _scorecard(r["content"])  # legacy fallback
        return _scorecard(
            r["content"],
            job_status=str(job.get("status", "")) or None,
            allow_failure=bool(job.get("allow_failure", False)),
        )

    scorecards = [(r, _scorecard_for(r)) for r in reports]
    pass_count = sum(1 for _, s in scorecards if s["status"] == "PASS")
    warn_count = sum(1 for _, s in scorecards if s["status"] == "WARN")
    fail_count = sum(1 for _, s in scorecards if s["status"] == "FAIL")
    total = len(scorecards)
    overall_ok = fail_count == 0

    if exec_block is None:
        exec_block = _deterministic_exec(scorecards)
        ai_powered = False

    important = _important_points(metrics, scorecards)
    propositions = _action_propositions(metrics, scorecards)

    blocks: list[str] = []
    blocks.append(agent_header("🚀", "Pipeline Report", "🤖🌍 Atlas", "consolidated",
                               subtitle=f"{total} agent reports • commit `{CI_COMMIT_SHORT_SHA}`"))

    blocks.append(executive_summary(
        summary=str(exec_block["summary"]),
        key_points=list(exec_block["key_points"]),
        reviewer_notes=list(exec_block["reviewer_notes"]),
        recommended_actions=list(exec_block["recommended_actions"]),
        ai_powered=ai_powered,
    ))
    blocks.append("")

    blocks.append(kpi_card([
        ("🎯 Overall",  status_badge(overall_ok)),
        ("✅ Pass",     str(pass_count)),
        ("🟡 Warn",     str(warn_count)),
        ("🔴 Fail",     str(fail_count)),
        ("📊 Agents",   str(total)),
    ]))
    blocks.append("")

    blocks.append("## Pipeline KPI and Stats")
    blocks.append("")

    blocks.append("## Advanced Metrics and Ratios")
    blocks.append("")
    blocks.append("| Metric | Value |")
    blocks.append("|---|---:|")
    blocks.append(f"| Pass ratio | {metrics['pass_ratio']}% |")
    blocks.append(f"| Fail ratio | {metrics['ratios']['fail_ratio']}% |")
    blocks.append(f"| Active ratio (running) | {metrics['ratios']['active_ratio']}% |")
    blocks.append(f"| Waiting ratio (manual/created) | {metrics['ratios']['waiting_ratio']}% |")
    blocks.append(f"| Skipped ratio | {metrics['ratios']['skip_ratio']}% |")
    blocks.append(f"| Allow-failure jobs ratio | {metrics['ratios']['allow_failure_ratio']}% |")
    blocks.append(f"| Stability ratio (success vs success+fail) | {metrics['ratios']['stability_ratio']}% |")
    blocks.append("")
    blocks.append(kpi_card([
        ("Jobs", str(metrics["total"])),
        ("Success", str(metrics["pass"])),
        ("Failed", str(metrics["fail"])),
        ("Running", str(metrics["running"])),
        ("Waiting", str(metrics["waiting"])),
        ("Pass Ratio", f"{metrics['pass_ratio']}%"),
    ]))
    blocks.append("")

    if metrics["status_counts"]:
        status_pie = {
            name.upper(): count for name, count in metrics["status_counts"].items() if count
        }
        blocks.append(mermaid_pie("Pipeline job statuses", status_pie))
        blocks.append("")

    if metrics["stages"]:
        stage_names = list(metrics["stages"].keys())[:10]
        stage_success_ratio: list[float] = []
        for st in stage_names:
            data = metrics["stages"][st]
            if data["total"]:
                stage_success_ratio.append(round((data["pass"] / data["total"]) * 100, 1))
            else:
                stage_success_ratio.append(0.0)
        blocks.append(mermaid_bar("Stage success ratio", stage_names, stage_success_ratio, y_axis="Success %"))
        blocks.append("")
        blocks.append("### Stage Success Curve")
        blocks.append("```mermaid")
        blocks.append("xychart-beta")
        blocks.append("    title \"Stage success curve\"")
        blocks.append("    x-axis [" + " ".join(f'\"{x}\"' for x in stage_names) + "]")
        blocks.append("    y-axis \"Success %\" 0 --> 100")
        blocks.append("    line [" + " ".join(str(v) for v in stage_success_ratio) + "]")
        blocks.append("```")
        blocks.append("")

    blocks.append("## Stage Overview")
    blocks.append("")

    if metrics["stage_risk_index"]:
        blocks.append("## Stage Risk Heat")
        blocks.append("")
        blocks.append("| Stage | Risk Index |")
        blocks.append("|---|---:|")
        for stage_name, risk in sorted(metrics["stage_risk_index"].items(), key=lambda kv: kv[1], reverse=True):
            blocks.append(f"| {stage_name} | {risk} |")
        blocks.append("")
    blocks.append("| Stage | Total | Success | Failed | Running | Waiting | Skipped | Avg Duration(s) |")
    blocks.append("|---|---:|---:|---:|---:|---:|---:|---:|")
    for stage_name, data in metrics["stages"].items():
        avg = round(data["duration"] / data["total"], 1) if data["total"] else 0.0
        blocks.append(
            f"| {stage_name} | {data['total']} | {data['pass']} | {data['fail']} | {data['running']} "
            f"| {data['waiting']} | {data['skipped']} | {avg} |"
        )
    blocks.append("")

    if pipeline_jobs:
        blocks.append("## Full Job Matrix")
        blocks.append("")
        blocks.append("| Job ID | Stage | Name | Status | Allow Failure | Duration(s) |")
        blocks.append("|---:|---|---|---|---|---:|")
        for job in pipeline_jobs:
            jid = job.get("id", "?")
            stage = str(job.get("stage", "?"))
            name = str(job.get("name", "?"))
            status = str(job.get("status", "?"))
            allow_fail = "yes" if job.get("allow_failure", False) else "no"
            dur = job.get("duration")
            dur_s = f"{float(dur):.1f}" if isinstance(dur, (int, float)) else "n/a"
            blocks.append(f"| {jid} | {stage} | {name} | {status} | {allow_fail} | {dur_s} |")
        blocks.append("")

    if metrics["top_slow_jobs"]:
        blocks.append("## Performance Curve (Slowest Jobs)")
        blocks.append("")
        slow_labels = [j["name"][:24].replace(" ", "_") for j in metrics["top_slow_jobs"]]
        slow_values = [round(j["duration"], 1) for j in metrics["top_slow_jobs"]]
        blocks.append("```mermaid")
        blocks.append("xychart-beta")
        blocks.append("    title \"Top slow jobs duration curve\"")
        blocks.append("    x-axis [" + " ".join(f'\"{x}\"' for x in slow_labels) + "]")
        blocks.append("    y-axis \"Duration (s)\" 0 --> " + str(max(1, int(max(slow_values) + 1))))
        blocks.append("    line [" + " ".join(str(v) for v in slow_values) + "]")
        blocks.append("```")
        blocks.append("")

        blocks.append("| Job | Stage | Status | Duration(s) |")
        blocks.append("|---|---|---|---:|")
        for j in metrics["top_slow_jobs"]:
            blocks.append(f"| {j['name']} | {j['stage']} | {j['status']} | {round(j['duration'], 1)} |")
        blocks.append("")

    blocks.append("## Important Points")
    for item in important:
        blocks.append(f"- {item}")
    blocks.append("")

    blocks.append("## Action Propositions")
    for category, actions in propositions.items():
        blocks.append(f"### {category}")
        if actions:
            for action in actions:
                blocks.append(f"- {action}")
        else:
            blocks.append("- No action needed")
        blocks.append("")

    blocks.append("## Executive Conclusion")
    blocks.append(_conclusion_text(metrics))
    blocks.append("")

    pie = {k: v for k, v in {"PASS": pass_count, "WARN": warn_count, "FAIL": fail_count}.items() if v}
    if pie:
        blocks.append(mermaid_pie("Agent verdicts", pie))
        blocks.append("")

    blocks.append("### 🏆 Agent Leaderboard\n")
    blocks.append("| # | Agent | Codename | Verdict | High | Warn |")
    blocks.append("|---|-------|----------|---------|------|------|")
    for idx, (r, s) in enumerate(scorecards, 1):
        emoji, title, code = AGENT_TITLES.get(r["name"], ("🤖", r["name"], "—"))
        verdict_icon = _VERDICT_ICON.get(s["status"], "❓")
        blocks.append(f"| {idx} | {emoji} {title} | {code} | {verdict_icon} {s['status']} | {s['high']} | {s['warn']} |")
    blocks.append("")

    blocks.append("### 📂 Per-Agent Reports\n")
    for r, s in scorecards:
        emoji, title, code = AGENT_TITLES.get(r["name"], ("🤖", r["name"], "—"))
        verdict_icon = _VERDICT_ICON.get(s["status"], "❓")
        blocks.append(details(f"{verdict_icon} {emoji} {title} — {code}", r["content"]))
        blocks.append("")

    blocks.append(footer("Atlas", CI_PIPELINE_URL, CI_COMMIT_SHORT_SHA))
    return "\n".join(blocks)


def _post_mr_comment(project_id: str, mr_iid: str, body: str) -> None:
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    httpx.post(url, headers={"PRIVATE-TOKEN": GITLAB_TOKEN},
               json={"body": body}, verify=False, timeout=30).raise_for_status()


def _render_executive_html(
    exec_block: dict[str, str | list[str]],
    metrics: dict,
    pipeline_jobs: list[dict],
    reports: list[dict],
    timestamp: str,
) -> str:
    """Render a premium standalone HTML artifact for executive pipeline reporting."""
    summary = html.escape(str(exec_block.get("summary", "")))
    key_points = [html.escape(str(x)) for x in exec_block.get("key_points", [])]
    important = _important_points(metrics, [])
    propositions = _action_propositions(metrics, [])
    conclusion = _conclusion_text(metrics)

    cards = [
        ("Total Jobs", str(metrics["total"])),
        ("Success", str(metrics["pass"])),
        ("Failed", str(metrics["fail"])),
        ("Running", str(metrics["running"])),
        ("Waiting", str(metrics["waiting"])),
        ("Pass Ratio", f"{metrics['pass_ratio']}%"),
        ("Stability", f"{metrics['ratios']['stability_ratio']}%"),
        ("Fail Ratio", f"{metrics['ratios']['fail_ratio']}%"),
    ]
    cards_html = "".join(
        f"<div class='card'><div class='label'>{html.escape(k)}</div><div class='value'>{html.escape(v)}</div></div>"
        for k, v in cards
    )

    status_total = max(metrics["total"], 1)
    status_rows = []
    for label in ("pass", "fail", "running", "waiting", "skipped"):
        value = int(metrics.get(label, 0))
        pct = round((value / status_total) * 100, 1)
        status_rows.append(
            f"<div class='bar-row'><span>{label.upper()}</span><div class='bar'><i style='width:{pct}%'></i></div><b>{value}</b></div>"
        )
    status_html = "".join(status_rows)

    stage_rows = []
    stage_curve_values: list[float] = []
    for stage_name, data in metrics["stages"].items():
        total = data["total"] or 1
        pct = round((data["pass"] / total) * 100, 1)
        stage_curve_values.append(pct)
        stage_rows.append(
            f"<div class='bar-row'><span>{html.escape(stage_name)}</span><div class='bar'><i style='width:{pct}%'></i></div><b>{pct}%</b></div>"
        )
    stage_html = "".join(stage_rows) if stage_rows else "<p>No stage data available.</p>"

    curve_svg = ""
    if stage_curve_values:
        n = len(stage_curve_values)
        width = 520
        height = 120
        step = width / max(1, n - 1)
        points = []
        for i, value in enumerate(stage_curve_values):
            x = round(i * step, 1)
            y = round(height - (value / 100.0) * height, 1)
            points.append(f"{x},{y}")
        curve_svg = (
            "<svg viewBox='0 0 520 120' class='curve'>"
            "<polyline fill='none' stroke='#70e6ff' stroke-width='3' points='"
            + " ".join(points)
            + "'></polyline></svg>"
        )

    important_html = "".join(f"<li>{html.escape(it)}</li>" for it in important)
    props_html = ""
    for category, actions in propositions.items():
        li = "".join(f"<li>{html.escape(x)}</li>" for x in actions) if actions else "<li>No action needed</li>"
        props_html += f"<h3>{html.escape(category)}</h3><ul>{li}</ul>"

    jobs_preview = pipeline_jobs[:25]
    jobs_rows = "".join(
        "<tr>"
        f"<td>{html.escape(str(j.get('id', '?')))}</td>"
        f"<td>{html.escape(str(j.get('stage', '?')))}</td>"
        f"<td>{html.escape(str(j.get('name', '?')))}</td>"
        f"<td>{html.escape(str(j.get('status', '?')))}</td>"
        f"<td>{'yes' if j.get('allow_failure', False) else 'no'}</td>"
        f"<td>{html.escape(str(j.get('duration', 'n/a')))}</td>"
        "</tr>"
        for j in jobs_preview
    )

    key_points_html = "".join(f"<li>{kp}</li>" for kp in key_points)

    ratio_html = (
        "<ul>"
        f"<li>Active ratio: {metrics['ratios']['active_ratio']}%</li>"
        f"<li>Waiting ratio: {metrics['ratios']['waiting_ratio']}%</li>"
        f"<li>Skipped ratio: {metrics['ratios']['skip_ratio']}%</li>"
        f"<li>Allow-failure ratio: {metrics['ratios']['allow_failure_ratio']}%</li>"
        "</ul>"
    )

    scorecards = [(r, _scorecard(r["content"])) for r in reports]
    agent_rows = "".join(
        "<tr>"
        f"<td>{idx}</td>"
        f"<td>{html.escape(r['name'])}</td>"
        f"<td>{html.escape(s['status'])}</td>"
        f"<td>{s['high']}</td>"
        f"<td>{s['warn']}</td>"
        f"<td><a href='{html.escape(r['name'])}.html'>{html.escape(r['name'])}.html</a></td>"
        "</tr>"
        for idx, (r, s) in enumerate(scorecards, 1)
    )
    agent_details = "".join(
        "<details><summary>"
        f"{html.escape(r['name'])} — {html.escape(s['status'])}"
        "</summary>"
        f"<pre>{html.escape(r['content'][:6000])}</pre>"
        "</details>"
        for r, s in scorecards
    )

    return f"""<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Pipeline Executive Report</title>
    <style>
        :root {{
            --bg: #0b1217;
            --panel: #111b22;
            --panel-soft: #16232d;
            --line: #27414f;
            --txt: #e6f0f5;
            --muted: #9eb1bc;
            --ok: #2dc27f;
            --warn: #f2b84b;
            --bad: #ff6b6b;
            --accent: #54c5eb;
        }}
        * {{ box-sizing: border-box; }}
        body {{ margin: 0; background: radial-gradient(circle at 20% 0%, #173246 0%, var(--bg) 45%); color: var(--txt); font-family: "Segoe UI", "Trebuchet MS", sans-serif; }}
        .wrap {{ max-width: 1220px; margin: 0 auto; padding: 24px; }}
        .hero {{ background: linear-gradient(135deg, #133147, #0f2431); border: 1px solid var(--line); border-radius: 16px; padding: 22px; }}
        .hero h1 {{ margin: 0; font-size: 28px; letter-spacing: .4px; }}
        .hero p {{ margin: 8px 0 0; color: var(--muted); }}
        .grid {{ display: grid; grid-template-columns: repeat(8, minmax(120px, 1fr)); gap: 12px; margin-top: 16px; }}
        .card {{ background: var(--panel); border: 1px solid var(--line); border-radius: 12px; padding: 12px; }}
        .label {{ color: var(--muted); font-size: 12px; text-transform: uppercase; letter-spacing: .6px; }}
        .value {{ font-size: 22px; font-weight: 700; margin-top: 4px; }}
        .section {{ margin-top: 16px; background: var(--panel); border: 1px solid var(--line); border-radius: 14px; padding: 16px; }}
        .section h2 {{ margin: 0 0 10px; font-size: 20px; color: var(--accent); }}
        .bar-row {{ display: grid; grid-template-columns: 140px 1fr 56px; gap: 8px; align-items: center; margin: 8px 0; }}
        .bar {{ width: 100%; background: #0e1820; border: 1px solid var(--line); border-radius: 999px; height: 14px; overflow: hidden; }}
        .bar i {{ display: block; height: 100%; background: linear-gradient(90deg, #3aa2c6, #70e6ff); }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13px; }}
        th, td {{ border: 1px solid var(--line); padding: 8px; text-align: left; }}
        th {{ background: var(--panel-soft); color: var(--accent); }}
        tr:nth-child(even) {{ background: #0f1a21; }}
        ul {{ margin: 6px 0 0 20px; }}
        details {{ margin-top: 8px; border: 1px solid var(--line); border-radius: 10px; padding: 8px; background: #0e1820; }}
        summary {{ cursor: pointer; font-weight: 600; color: var(--accent); }}
        pre {{ white-space: pre-wrap; max-height: 380px; overflow: auto; background: #091116; border: 1px solid var(--line); border-radius: 8px; padding: 10px; }}
        a {{ color: #83e0ff; text-decoration: none; }}
        .small {{ color: var(--muted); font-size: 12px; margin-top: 8px; }}
        .curve {{ width: 100%; background: #0e1820; border: 1px solid var(--line); border-radius: 10px; padding: 8px; }}
        .conclusion {{ background: linear-gradient(135deg, #153a2e, #122a33); border: 1px solid #2a5f65; border-radius: 12px; padding: 12px; }}
        @media (max-width: 980px) {{ .grid {{ grid-template-columns: repeat(2, 1fr); }} .bar-row {{ grid-template-columns: 100px 1fr 44px; }} }}
    </style>
</head>
<body>
    <div class='wrap'>
        <section class='hero'>
            <h1>Pipeline Executive Final Report</h1>
            <p>Commit {html.escape(CI_COMMIT_SHORT_SHA)} • Pipeline {html.escape(CI_PIPELINE_ID or 'n/a')} • Generated {html.escape(timestamp)}</p>
            <p>{summary}</p>
            <ul>{key_points_html}</ul>
        </section>

        <section class='section'>
            <h2>KPI and Stats</h2>
            <div class='grid'>{cards_html}</div>
        </section>

        <section class='section'>
            <h2>Status Chart</h2>
            {status_html}
        </section>

        <section class='section'>
            <h2>Stage Success Graph</h2>
            {stage_html}
            {curve_svg}
        </section>

        <section class='section'>
            <h2>Ratios</h2>
            {ratio_html}
        </section>

        <section class='section'>
            <h2>Important Points</h2>
            <ul>{important_html}</ul>
        </section>

        <section class='section'>
            <h2>Action Propositions</h2>
            {props_html}
        </section>

        <section class='section conclusion'>
            <h2>Conclusion</h2>
            <p>{html.escape(conclusion)}</p>
        </section>

        <section class='section'>
            <h2>Pipeline Jobs Snapshot</h2>
            <table>
                <thead><tr><th>ID</th><th>Stage</th><th>Name</th><th>Status</th><th>Allow Failure</th><th>Duration(s)</th></tr></thead>
                <tbody>{jobs_rows}</tbody>
            </table>
            <p class='small'>Showing first 25 jobs. Full details are available in pipeline markdown report and GitLab UI.</p>
        </section>

        <section class='section'>
            <h2>Agent Consolidation (Included)</h2>
            <table>
                <thead><tr><th>#</th><th>Agent</th><th>Verdict</th><th>High</th><th>Warn</th><th>Individual HTML</th></tr></thead>
                <tbody>{agent_rows}</tbody>
            </table>
            <p class='small'>The final report includes agent summaries below, while individual agent HTML files remain available.</p>
            {agent_details}
        </section>
    </div>
</body>
</html>
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--mr-iid")
    parser.add_argument("--reports-dir", default="backend/reports")
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    _enc = sys.stdout.encoding or ""
    if hasattr(sys.stdout, 'reconfigure') and isinstance(_enc, str) and _enc.lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    reports_dir = Path(args.reports_dir)
    if not reports_dir.exists():
        print(f"⚠ Reports dir not found: {reports_dir}")
        return 0

    reports = _load_reports(reports_dir)
    if not reports:
        print("⚠ No report files found")
        return 0

    copilot = CopilotClient()
    exec_block: dict[str, str | list[str]] | None = None
    ai_powered = False
    if copilot.is_available():
        compact = "\n".join(
            f"### {r['name']}\n{r['content'][:300]}" for r in reports
        )
        exec_block = copilot.generate_executive_summary(compact, scope="pipeline")
        ai_powered = exec_block is not None

    pipeline_jobs = _fetch_pipeline_jobs(args.project_id, CI_PIPELINE_ID)
    metrics = _pipeline_metrics(pipeline_jobs)

    report = _build_summary(reports, exec_block, ai_powered, pipeline_jobs, metrics)
    print(report)

    if args.output:
        _ts = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%d %H:%M UTC")
        out_path = Path(args.output)
        out_path.write_text(report, encoding="utf-8")

        exec_html = out_path.parent / "pipeline_executive_report.html"
        if exec_block is None:
            exec_block = _deterministic_exec([(r, _scorecard(r["content"])) for r in reports])
        exec_html.write_text(
            _render_executive_html(exec_block, metrics, pipeline_jobs, reports, _ts),
            encoding="utf-8",
        )
        print(f"\u2714 Executive HTML report \u2192 {exec_html} ({exec_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ Consolidated MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Pipeline Report"))
