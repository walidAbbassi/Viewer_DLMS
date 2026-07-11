#!/usr/bin/env python3
"""
Pipeline Completion Notifier — GitLab API edition.

Posts a summary MR note (job statuses + report links + agent comment links).
GitLab then sends a native email notification via its own SMTP relay.

Usage:
  python notify_pipeline_gitlab.py
    --pipeline-id <CI_PIPELINE_ID>
    --mr-iid      <CI_MERGE_REQUEST_IID>
    --project-id  <CI_PROJECT_ID>
    [--artifacts-dir backend/reports]
    [--dry-run]
"""

import argparse
import os
import sys
from pathlib import Path

import requests

# Ensure GitLab internal host bypasses corporate proxy
os.environ.setdefault("NO_PROXY", "gitlab-produits.rmm.scom,localhost,127.0.0.1")
os.environ.setdefault("no_proxy", "gitlab-produits.rmm.scom,localhost,127.0.0.1")

# Force UTF-8 output (Windows cp1252 can't encode emoji)
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")

AGENT_LABELS = {
    "security_scanner":        "🛡 Anubis — Security Scanner",
    "code_reviewer":           "📝 Osiris — Code Reviewer",
    "code_explainer":          "📖 Themis — Code Explainer",
    "test_coverage":           "🧪 TIA — Test Coverage",
    "flutter_coverage":        "🦋 Laika — Flutter Coverage",
    "flutter_analyzer":        "🔍 Helios — Flutter Analyzer",
    "dependency_audit":        "📦 Cassandra — Dependency Audit",
    "license_compliance":      "⚖️ Themis — License Compliance",
    "documentation":           "📚 Hermes — Documentation",
    "cicd_diagnosis":          "🔧 Hephaestus — CI/CD Diagnosis",
    "pipeline_report":         "🌍 Atlas — Global Report",
}

REPORT_LABELS = {
    "security_scanner":        "🛡 Security Scanner",
    "code_reviewer":           "📝 Code Reviewer",
    "code_explainer":          "📖 Code Explainer",
    "test_coverage":           "🧪 Test Coverage",
    "flutter_coverage":        "🦋 Flutter Coverage",
    "flutter_analyzer":        "🔍 Flutter Analyzer",
    "dependency_audit":        "📦 Dependency Audit",
    "license_compliance":      "⚖️ License Compliance",
    "documentation":           "📚 Documentation",
    "cicd_diagnosis":          "🔧 CI/CD Diagnosis",
    "pipeline_report":         "🌍 Pipeline Report",
}

JOB_STATUS_ICON = {
    "success":  "✅",
    "failed":   "❌",
    "canceled": "⏹️",
    "skipped":  "⏭️",
    "running":  "🔄",
    "pending":  "⏳",
    "manual":   "🖐️",
}


def _headers():
    return {"PRIVATE-TOKEN": GITLAB_TOKEN}


def _fmt_duration(seconds):
    if seconds is None:
        return "—"
    seconds = int(seconds)
    if seconds < 60:
        return f"{seconds}s"
    return f"{seconds // 60}m{seconds % 60:02d}s"


def fetch_pipeline_jobs(project_id, pipeline_id):
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/pipelines/{pipeline_id}/jobs"
    jobs = []
    page = 1
    while True:
        r = requests.get(url, headers=_headers(), params={"per_page": 100, "page": page}, verify=False)
        r.raise_for_status()
        batch = r.json()
        if not batch:
            break
        jobs.extend(batch)
        page += 1
    jobs.sort(key=lambda j: j.get("id", 0))
    return jobs


def upload_artifacts(project_id, artifacts_dir):
    """Upload .md and .html report files. Returns dict stem → {md_url, html_url}."""
    upload_url = f"{GITLAB_URL}/api/v4/projects/{project_id}/uploads"
    reports = {}

    for ext in ("md", "html"):
        for fpath in sorted(Path(artifacts_dir).glob(f"*.{ext}")):
            if fpath.stat().st_size == 0:
                continue
            stem = fpath.stem
            try:
                with open(fpath, "rb") as fh:
                    r = requests.post(
                        upload_url,
                        headers=_headers(),
                        files={"file": (fpath.name, fh)},
                        verify=False,
                    )
                r.raise_for_status()
                full_url = GITLAB_URL + r.json()["url"]
                if stem not in reports:
                    reports[stem] = {}
                reports[stem][ext] = full_url
                print(f"  ✅ Uploaded {fpath.name}")
            except Exception as exc:
                print(f"  ⚠️  Upload failed for {fpath.name}: {exc}")

    return reports


def fetch_agent_notes(project_id, mr_iid):
    """Return list of {label, url} for agent notes already posted on the MR."""
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    notes = []
    page = 1
    while True:
        r = requests.get(url, headers=_headers(), params={"per_page": 100, "page": page}, verify=False)
        r.raise_for_status()
        batch = r.json()
        if not batch:
            break
        notes.extend(batch)
        page += 1

    mr_web_url = f"{GITLAB_URL}/tools/Viewer_NG/-/merge_requests/{mr_iid}"
    found = []
    seen_agents = set()

    for note in sorted(notes, key=lambda n: n.get("id", 0)):
        body = note.get("body", "")
        note_id = note["id"]
        for key, label in AGENT_LABELS.items():
            if key in seen_agents:
                continue
            if key.replace("_", " ") in body.lower() or any(
                kw in body for kw in [label.split("—")[0].strip(), key]
            ):
                found.append({"label": label, "url": f"{mr_web_url}#note_{note_id}"})
                seen_agents.add(key)
                break

    return found


def compose_note(pipeline_id, mr_iid, branch, jobs, uploaded, agent_notes, project_id):
    pipeline_url = f"{GITLAB_URL}/tools/Viewer_NG/-/pipelines/{pipeline_id}"
    mr_url = f"{GITLAB_URL}/tools/Viewer_NG/-/merge_requests/{mr_iid}"

    overall_ok = all(
        j["status"] in ("success", "skipped", "manual", "canceled")
        or j.get("allow_failure", False)
        for j in jobs
        if j["status"] not in ("created", "pending", "running")
    )
    header_icon = "🎉" if overall_ok else "⚠️"

    lines = [
        f"## {header_icon} Pipeline #{pipeline_id} — MR !{mr_iid} · `{branch}` → `main`",
        "",
    ]

    # ── Job statuses ──────────────────────────────────────────────────────────
    lines += [
        "### 📊 Job statuses",
        "| Job | Status | Duration |",
        "|-----|--------|----------|",
    ]
    for job in jobs:
        name = job["name"]
        status = job["status"]
        allow_failure = job.get("allow_failure", False)
        icon = JOB_STATUS_ICON.get(status, "❓")
        label = status
        if status == "failed" and allow_failure:
            icon = "⚠️"
            label = "failed *(allow_failure)*"
        duration = _fmt_duration(job.get("duration"))
        lines.append(f"| `{name}` | {icon} {label} | {duration} |")
    lines.append("")

    # ── Reports ───────────────────────────────────────────────────────────────
    if uploaded:
        lines += [
            "### 📎 Reports",
            "| Report | MD | HTML |",
            "|--------|----|------|",
        ]
        for stem, label in REPORT_LABELS.items():
            entry = uploaded.get(stem, {})
            md_link = f"[.md]({entry['md']})" if "md" in entry else "—"
            html_link = f"[.html]({entry['html']})" if "html" in entry else "—"
            if "md" in entry or "html" in entry:
                lines.append(f"| {label} | {md_link} | {html_link} |")
        lines.append("")

    # ── Agent comments ────────────────────────────────────────────────────────
    if agent_notes:
        lines.append("### 🤖 Agent comments on this MR")
        for n in agent_notes:
            lines.append(f"- [{n['label']}]({n['url']})")
        lines.append("")

    # ── Quick access ──────────────────────────────────────────────────────────
    lines += [
        "### 🔗 Quick access",
        f"[View MR]({mr_url}) · [View Pipeline]({pipeline_url})",
        "",
        "---",
        "*Automated notification — Viewer\\_NG CI/CD*",
    ]

    return "\n".join(lines)


def post_mr_note(project_id, mr_iid, body):
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/merge_requests/{mr_iid}/notes"
    r = requests.post(url, headers=_headers(), json={"body": body}, verify=False)
    r.raise_for_status()
    note_id = r.json().get("id")
    print(f"  ✅ Note posted — ID {note_id}")
    return note_id


def main():
    parser = argparse.ArgumentParser(description="Post pipeline summary note on GitLab MR")
    parser.add_argument("--pipeline-id", required=True)
    parser.add_argument("--mr-iid", required=True)
    parser.add_argument("--project-id", required=True)
    parser.add_argument("--artifacts-dir", default="backend/reports")
    parser.add_argument("--dry-run", action="store_true", help="Print note without posting")
    args = parser.parse_args()

    if not GITLAB_TOKEN:
        print("❌ GITLAB_TOKEN is not set")
        sys.exit(1)

    pipeline_id = args.pipeline_id
    mr_iid = args.mr_iid
    project_id = args.project_id

    print(f"🔍 Fetching pipeline #{pipeline_id} jobs ...")
    jobs = fetch_pipeline_jobs(project_id, pipeline_id)
    print(f"   {len(jobs)} jobs found")

    branch = os.environ.get("CI_COMMIT_REF_NAME", "Update_Demo")

    print(f"\n📤 Uploading artifacts from {args.artifacts_dir} ...")
    uploaded = {} if args.dry_run else upload_artifacts(project_id, args.artifacts_dir)
    if args.dry_run:
        print("   [dry-run] skipping uploads")

    print(f"\n🔎 Fetching agent notes on MR !{mr_iid} ...")
    agent_notes = fetch_agent_notes(project_id, mr_iid)
    print(f"   {len(agent_notes)} agent note(s) found")

    print("\n📝 Composing note ...")
    note_body = compose_note(pipeline_id, mr_iid, branch, jobs, uploaded, agent_notes, project_id)

    print("\n" + "─" * 70)
    print(note_body)
    print("─" * 70 + "\n")

    if args.dry_run:
        print("✅ Dry-run complete — note NOT posted")
        sys.exit(0)

    print(f"📬 Posting note to MR !{mr_iid} ...")
    try:
        post_mr_note(project_id, mr_iid, note_body)
        print("✅ Pipeline completion notification sent")
    except Exception as exc:
        print(f"❌ Failed to post note: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
