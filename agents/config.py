"""Central configuration for all Viewer_NG CI agents.

Single source of truth for:
    - Copilot model and timeouts
    - Environment variable names (tokens, proxy, feature flags)
    - All prompts used by the hybrid 2-layer agents

Usage::

    from agents.config import AgentConfig
    from agents.config import Prompts

    model  = AgentConfig.COPILOT_MODEL
    prompt = Prompts.DEPENDENCY_AUDIT.format(vulnerabilities=text)
"""

from __future__ import annotations

import os


# ─────────────────────────────────────────────────────────────────────────────
# Runtime configuration — read once at import time from environment
# ─────────────────────────────────────────────────────────────────────────────


class AgentConfig:
    """All tunable parameters for the agent layer.

    Override any value by setting the corresponding environment variable
    before launching the Python process (or in the GitLab CI variable).
    """

    # ── Copilot model ────────────────────────────────────────────────────────
    COPILOT_MODEL: str = os.environ.get("COPILOT_MODEL", "claude-sonnet-4.6")

    # ── Timeouts (seconds) ───────────────────────────────────────────────────
    COPILOT_SDK_TIMEOUT: int = int(os.environ.get("COPILOT_SDK_TIMEOUT", "600"))   # 10 min
    COPILOT_CLI_TIMEOUT: int = int(os.environ.get("COPILOT_CLI_TIMEOUT", "900"))   # 15 min
    GITLAB_HTTP_TIMEOUT: int = int(os.environ.get("GITLAB_HTTP_TIMEOUT", "30"))
    PIP_AUDIT_TIMEOUT: int = int(os.environ.get("PIP_AUDIT_TIMEOUT", "120"))

    # ── Copilot prompt limits ─────────────────────────────────────────────────
    MAX_PROMPT_LEN: int = int(os.environ.get("COPILOT_MAX_PROMPT_LEN", "32000"))
    MAX_DIFF_LINES: int = int(os.environ.get("COPILOT_MAX_DIFF_LINES", "100"))

    # ── Feature flags ────────────────────────────────────────────────────────
    COPILOT_ENABLED: bool = os.environ.get("COPILOT_ENABLED", "1") != "0"
    FAIL_ON_HIGH: bool = os.environ.get("FAIL_ON_HIGH", "0") == "1"

    # ── Coverage threshold ───────────────────────────────────────────────────
    COVERAGE_THRESHOLD: float = float(os.environ.get("COVERAGE_THRESHOLD", "60.0"))

    # ── GitLab ───────────────────────────────────────────────────────────────
    GITLAB_URL: str = os.environ.get("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
    GITLAB_TOKEN: str = os.environ.get("GITLAB_TOKEN", "")

    # ── Proxy (corporate) ────────────────────────────────────────────────────
    HTTP_PROXY: str = os.environ.get("HTTP_PROXY", "")
    HTTPS_PROXY: str = os.environ.get("HTTPS_PROXY", "")
    NO_PROXY: str = os.environ.get("NO_PROXY", "")


# ─────────────────────────────────────────────────────────────────────────────
# Prompts — all str templates, use .format(**kwargs) to fill placeholders
# ─────────────────────────────────────────────────────────────────────────────


class Prompts:
    """All prompts sent to Copilot by the hybrid 2-layer agents.

    Each constant is a ``str.format()`` template.
    Placeholders are documented inline with ``{name}`` notation.
    """

    # ── code_reviewer.py ─────────────────────────────────────────────────────
    # {diff_text}  — filtered added lines from git diff
    CODE_REVIEW = (
        "Review this Python code diff for the Viewer_NG gRPC backend. "
        "Check for: style issues, naming conventions, complexity, "
        "no print() (use logger), one import per line, Python 3.13, "
        "no hardcoded secrets, DLMS/COSEM protocol correctness. Be concise.\n\n"
        "{diff_text}"
    )

    # {findings_text}  — summarized Layer 1 findings from the backend scan
    # LEGACY: fallback for load_prompt("code_reviewer") when .md file is missing
    CODE_REVIEW_FINDINGS = (
        "Review these Python code review findings for the Viewer_NG gRPC backend. "
        "Highlight the most important issues, likely false positives, and the top "
        "fixes to prioritize first. Be concise.\n\n"
        "{findings_text}"
    )

    # ── security_scanner.py ──────────────────────────────────────────────────
    # {code_snippet}  — file content or finding snippets to analyse
    # LEGACY: fallback for load_prompt("security_scanner") when .md file is missing
    SECURITY_SCAN = (
        "Analyze this Python code for security vulnerabilities: "
        "injection risks, path traversal, insecure crypto, hardcoded secrets, "
        "race conditions, insecure deserialization. Map each finding to a CWE ID. "
        "Be concise.\n\n"
        "{code_snippet}"
    )

    # ── cicd_agent.py ─────────────────────────────────────────────────────────
    # {error_message}  — CI pipeline error text
    # LEGACY: fallback for load_prompt("cicd_agent") when .md file is missing
    CICD_FIX = (
        "Diagnose this CI/CD pipeline error and suggest a fix. "
        "The project uses Python 3.13 on Windows, GitLab CI with PowerShell shell executor, "
        "pytest, flake8, black. Be concise.\n\n"
        "{error_message}"
    )

    # ── test_coverage_agent.py ────────────────────────────────────────────────
    # {uncovered_code}  — uncovered lines / function names
    # LEGACY: fallback for load_prompt("test_coverage_agent") when .md file is missing
    COVERAGE_SUGGESTIONS = (
        "Suggest pytest test cases for these uncovered Python code lines "
        "in the Viewer_NG gRPC backend. "
        "Give test function names and brief descriptions. "
        "Follow naming convention test_<function>_<scenario>. Be concise.\n\n"
        "{uncovered_code}"
    )

    # ── flutter_coverage_agent.py ─────────────────────────────────────────────
    # {uncovered_code}  — uncovered Dart widget/function names
    # LEGACY: fallback for load_prompt("flutter_coverage_agent") when .md file is missing
    FLUTTER_COVERAGE_SUGGESTIONS = (
        "Suggest flutter_test widget test cases for these uncovered Dart code lines "
        "in the Viewer_NG Flutter frontend. "
        "Use pumpWidget and mockito patterns. Be concise.\n\n"
        "{uncovered_code}"
    )

    # ── code_explainer.py ─────────────────────────────────────────────────────
    # {code_snippet}  — MR diff to explain
    # LEGACY: fallback for load_prompt("code_explainer") when .md file is missing
    CODE_EXPLAIN = (
        "Explain this Viewer_NG merge request diff in plain English for tech leads and QA. "
        "Highlight breaking changes and potential risks. Be concise.\n\n"
        "{code_snippet}"
    )

    # ── dependency_audit_agent.py ─────────────────────────────────────────────
    # {vulnerabilities}  — bullet summary of CVE findings
    # LEGACY: fallback for load_prompt("dependency_audit_agent") when .md file is missing
    DEPENDENCY_AUDIT = (
        "Analyze these Python dependency vulnerabilities for the Viewer_NG project "
        "(deployed in isolated industrial network, no internet access):\n"
        "1. Impact assessment for each CVE\n"
        "2. Recommended pip upgrade path\n"
        "3. Whether each is exploitable in this context\n\n"
        "{vulnerabilities}"
    )

    # ── license_compliance_agent.py ───────────────────────────────────────────
    # {licenses}  — bullet summary of detected licences
    # LEGACY: fallback for load_prompt("license_compliance_agent") when .md file is missing
    LICENSE_COMPLIANCE = (
        "Analyze these Python dependency licenses for Viewer_NG (Sagemcom proprietary software).\n"
        "State whether each license is compatible with proprietary distribution.\n"
        "Classify risk level (HIGH/MEDIUM/LOW) and suggest permissive alternatives.\n\n"
        "{licenses}"
    )

    # ── documentation_agent.py ────────────────────────────────────────────────
    # {missing_docstrings}  — list of functions / classes missing docstrings
    # LEGACY: fallback for load_prompt("documentation_agent") when .md file is missing
    DOCUMENTATION = (
        "These Python functions/classes in the Viewer_NG gRPC backend are missing docstrings.\n"
        "Suggest concise, Google-style docstrings for each.\n"
        "Include Args, Returns, and Raises sections where appropriate.\n\n"
        "{missing_docstrings}"
    )

    # ── flutter_analyzer_agent.py ─────────────────────────────────────────────
    # {errors}  — flutter analyze output errors
    # LEGACY: fallback for load_prompt("flutter_analyzer_agent") when .md file is missing
    FLUTTER_ANALYZE = (
        "Diagnose these Flutter analyzer errors and warnings for the Viewer_NG frontend. "
        "Explain Dart root causes and provide concrete fixes. Be concise.\n\n"
        "{errors}"
    )

    # ── pipeline_report_agent.py ──────────────────────────────────────────────
    # {reports}  — aggregated agent reports
    # LEGACY: fallback for load_prompt("pipeline_report_agent") when .md file is missing
    PIPELINE_REPORT = (
        "Aggregate these CI agent reports for the Viewer_NG merge request "
        "into a single executive summary with traffic-light quality rating "
        "(🟢 PASS / 🟡 WARN / 🔴 FAIL) and prioritized action items. Be concise.\n\n"
        "{reports}"
    )

    # ── health check ──────────────────────────────────────────────────────────
    HEALTH_CHECK = "Reply with exactly: COPILOT_OK | DAY OF WEEK | DATE"
