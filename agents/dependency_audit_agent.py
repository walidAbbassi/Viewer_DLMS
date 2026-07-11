"""
Dependency Audit Agent — runs pip-audit on requirements.txt + parses pubspec.yaml for Flutter deps.
Layer 2: claude-sonnet-4.6 provides remediation paths.
Symbolic name: 🤖🔮 Cassandra — Oracle des risques.
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

import re

import httpx

from agents._runtime import crash_wrap
from agents.copilot_client import CopilotClient, markdown_to_html
from agents.mr_format import agent_header, collapsible_table, details, kpi_card, render_exec_block, status_badge

GITLAB_URL = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
GITLAB_TOKEN = os.environ.get("GITLAB_TOKEN", "")


def _run_pip_audit(requirements: str) -> list[dict]:
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip_audit", "-r", requirements, "--format", "json"],
            capture_output=True, text=True, timeout=120
        )
        data = json.loads(result.stdout or "[]")
        vulns = []
        for pkg in data:
            for v in pkg.get("vulns", []):
                vulns.append({
                    "package": pkg["name"],
                    "version": pkg["version"],
                    "id": v["id"],
                    "description": v.get("description", "")[:200],
                    "fix": v.get("fix_versions", []),
                })
        return vulns
    except Exception as exc:
        print(f"⚠ pip-audit failed: {exc}", file=sys.stderr)
        return []


def _parse_pubspec_deps(pubspec_path: str) -> list[dict]:
    """Parse direct dependencies from pubspec.yaml using regex (no PyYAML required)."""
    try:
        content = Path(pubspec_path).read_text(encoding="utf-8")
    except OSError:
        return []
    deps = []
    in_deps = False
    for line in content.splitlines():
        if re.match(r'^(dependencies|dev_dependencies)\s*:', line):
            in_deps = True
            continue
        if in_deps:
            # A top-level key (non-indented, not a comment) ends the section
            if re.match(r'^[a-zA-Z]', line) and not re.match(r'^\s', line):
                in_deps = False
                continue
            m = re.match(r'^\s{2}([\w_-]+)\s*:\s*(.+)', line)
            if m:
                name = m.group(1)
                version = m.group(2).strip()
                # Skip flutter SDK entries and path/git references
                if name in ('flutter', 'flutter_test') or version.startswith(('{', 'sdk:')):
                    continue
                deps.append({"name": name, "version": version})
    return deps


def _deterministic_exec(vulns: list[dict], flutter_deps: list[dict]) -> dict:
    pkgs_with_vulns = len({v["package"] for v in vulns})
    no_fix = [v for v in vulns if not v.get("fix")]
    summary = (
        f"Dependency audit: {len(vulns)} CVE(s) across {pkgs_with_vulns} package(s); "
        f"{len(no_fix)} without a known fix. {len(flutter_deps)} Flutter package(s) declared."
    )
    key_points = [
        f"Python CVEs: {len(vulns)}",
        f"Affected packages: {pkgs_with_vulns}",
        f"CVEs without known fix: {len(no_fix)}",
        f"Flutter packages declared: {len(flutter_deps)}",
    ]
    if vulns:
        first = vulns[0]
        key_points.append(
            f"First CVE: {first.get('id', '?')} on {first.get('package', '?')} {first.get('version', '?')}"
        )
    reviewer_notes = ["AI unavailable — see report below."]
    if vulns:
        reviewer_notes.append("Known CVEs detected — patch before merge.")
    else:
        reviewer_notes.append("No known Python CVEs detected.")
    recommended_actions: list[str] = []
    if vulns:
        recommended_actions.append(f"Patch the {len(vulns)} CVE(s) using suggested fix versions")
    if no_fix:
        recommended_actions.append(f"Mitigate the {len(no_fix)} CVE(s) without an available fix")
    if flutter_deps:
        recommended_actions.append(f"Cross-check {len(flutter_deps)} Flutter package(s) for known advisories")
    if not recommended_actions:
        recommended_actions.append("Dependency audit gate green — no action required")
    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


def _exec_context(vulns: list[dict], flutter_deps: list[dict]) -> str:
    lines = [
        f"Python CVEs: {len(vulns)} — affected packages: {len({v['package'] for v in vulns})}.",
        f"Flutter packages declared: {len(flutter_deps)}.",
        "",
        "Top CVEs:",
    ]
    for v in vulns[:8]:
        fix = ", ".join(v.get("fix") or []) or "no fix"
        lines.append(
            f"- {v.get('package', '?')} {v.get('version', '?')} — {v.get('id', '?')} (fix: {fix})"
        )
    return "\n".join(lines)


def _build_report(vulns: list[dict], flutter_deps: list[dict], ai_text: str | None, mode: str,
                  exec_block: dict | None = None) -> str:
    blocks: list[str] = []
    blocks.append(agent_header("🔎", "Dependency Audit", "🤖🔮 Cassandra", mode,
                               subtitle=f"{len(vulns)} CVE(s)"))
    blocks.append(render_exec_block(exec_block, _deterministic_exec(vulns, flutter_deps)))
    blocks.append(kpi_card([
        ("🐛 CVEs",       str(len(vulns))),
        ("✅ Status",      status_badge(len(vulns) == 0)),
        ("🐍 Backend",     "pip-audit"),
        ("🇳 Flutter pkg", str(len(flutter_deps))),
    ]))
    blocks.append("")

    if vulns:
        rows = []
        for v in vulns:
            fix = ", ".join(v["fix"]) or "_no fix available_"
            rows.append(f"| `{v['package']}` | {v['version']} | `{v['id']}` | {fix} |")
        blocks.append("### 🐍 Python CVEs\n")
        blocks.append(collapsible_table("🐛 CVE list",
                                        ["| Package | Version | CVE | Fix |", "|---------|---------|-----|-----|"],
                                        rows, visible_count=10))
        blocks.append("")
    else:
        blocks.append("✅ No known Python CVEs found.\n")

    if flutter_deps:
        rows = [f"| `{d['name']}` | {d['version']} |" for d in flutter_deps]
        blocks.append(details(f"🇳 Flutter packages declared ({len(flutter_deps)})",
                              "\n".join(["| Package | Declared Version |", "|---------|-----------------|"] + rows[:40])))
        blocks.append("")

    if ai_text:
        blocks.append(details("🤖 AI Remediation Guidance — claude-sonnet-4.6", ai_text))
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
    parser.add_argument("--requirements", default="backend/requirements.txt")
    parser.add_argument("--pubspec", default="flutter_app/pubspec.yaml")
    parser.add_argument("--output")
    parser.add_argument("--push-mode", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    # Force UTF-8 output on Windows runners (cp1252-safe for Unicode report text).
    if hasattr(sys.stdout, 'reconfigure') and (sys.stdout.encoding or '').lower() != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    vulns = _run_pip_audit(args.requirements)
    flutter_deps = _parse_pubspec_deps(args.pubspec)

    copilot = CopilotClient()
    ai_exec = None
    if copilot.is_available():
        ai_exec = copilot.generate_executive_summary(
            _exec_context(vulns, flutter_deps), scope="dependencies"
        )
    ai_text = None
    if copilot.is_available() and (vulns or flutter_deps):
        pip_part = "\n".join(f"- {v['package']} {v['version']}: {v['id']} — {v['description']}" for v in vulns[:8])
        flutter_part = "\n".join(f"- {d['name']} {d['version']}" for d in flutter_deps[:15])
        combined = ""
        if pip_part:
            combined += f"Python CVEs:\n{pip_part}\n"
        if flutter_part:
            combined += f"Flutter packages (check for known CVEs):\n{flutter_part}"
        ai_text = copilot.audit_dependencies(combined.strip())

    report = _build_report(vulns, flutter_deps, ai_text, copilot.mode, exec_block=ai_exec)
    print(report)

    if args.output:
        import datetime
        _ts = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
        Path(args.output).write_text(report, encoding="utf-8")
        _html = Path(args.output).with_suffix(".html")
        _html.write_text(markdown_to_html(report, "Dependency Audit \u2014 \U0001f916\U0001f52e Cassandra", _ts), encoding="utf-8")
        print(f"\u2714 HTML report \u2192 {_html} ({_html.stat().st_size} bytes)")

    if args.mr_iid and not args.dry_run:
        _post_mr_comment(args.project_id, args.mr_iid, report)
        print("✔ MR comment posted")
    return 0


if __name__ == "__main__":
    sys.exit(crash_wrap(main, "Dependency Audit"))
