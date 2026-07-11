"""Copilot Client — SDK wrapper with CLI fallback for AI-powered analysis.

Provides Layer 2 (AI) analysis for all Viewer_NG CI agents.
Three modes in priority order:

    1. **SDK** — ``github-copilot-sdk`` (``from copilot import CopilotClient``)
       Communicates with Copilot CLI server via JSON-RPC.  Async internally,
       sync public API via a dedicated ``asyncio`` event loop.
    2. **CLI** — ``gh copilot explain`` subprocess (fallback when SDK unavailable)
    3. **Disabled** — Layer 1 regex only (when neither SDK nor CLI available)

Model: ``claude-sonnet-4.6`` via GitHub Copilot API (COPILOT_GITHUB_TOKEN).

Environment variables:
    COPILOT_ENABLED      — Set to ``0`` to force-disable Copilot (default: enabled)
    COPILOT_SDK_TIMEOUT  — Timeout in seconds for SDK calls (default: 600 = 10 min)
    COPILOT_CLI_TIMEOUT  — Timeout in seconds for CLI calls (default: 900 = 15 min)
    COPILOT_MODEL        — Model name (default: claude-sonnet-4.6)
    COPILOT_MAX_WORKERS  — Max parallel threads for review_multiple_files (default: 3)
"""

from __future__ import annotations

import asyncio
import logging
import os
import re
import shutil
import subprocess
import sys
import textwrap
import time
import traceback
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import TimeoutError as FuturesTimeoutError
from concurrent.futures import as_completed
from pathlib import Path

from agents.config import AgentConfig
from agents.config import Prompts
from agents.mr_format import AUTO_COLLAPSE_THRESHOLD

logger = logging.getLogger(__name__)


def _ci_ts() -> int:
    import time
    return int(time.time())


def _print_banner(icon: str, title: str) -> None:
    """Python equivalent of the PowerShell Banner function (╔═╗ style)."""
    C = "\x1b[36m"  # cyan
    B = "\x1b[1m"   # bold
    X = "\x1b[0m"   # reset
    w = 64
    inner = f"  {icon}  {title}"
    pad = " " * max(1, w - len(inner))
    print(f"\n{C}╔{'═' * w}╗{X}", flush=True)
    print(f"{C}║{X}{B}{inner}{X}{pad}{C}║{X}", flush=True)
    print(f"{C}╚{'═' * w}╝{X}\n", flush=True)


def _print_info(label: str, value: str) -> None:
    """Python equivalent of the PowerShell Info function."""
    D = "\x1b[2m"   # dim
    X = "\x1b[0m"   # reset
    print(f"  {D}{label}{X}  {value}", flush=True)


def _ci_section_end(name: str) -> None:
    """Emit a GitLab CI section_end marker."""
    print(f"\x1b[0Ksection_end:{_ci_ts()}:{name}\r\x1b[0K", flush=True)


def _ci_section_start(name: str, title: str = "", collapsed: bool = True) -> None:
    """Emit a GitLab CI section_start marker."""
    flag = "[collapsed=true]" if collapsed else ""
    line = f"\x1b[0Ksection_start:{_ci_ts()}:{name}{flag}\r\x1b[0K"
    if title:
        line += f"\x1b[2m  {title}\x1b[0m"
    print(line, flush=True)


def _print_boxline(title: str, content: str) -> None:
    """Print a ┌─ ... ─┐ box to stdout without CI section markers."""
    BAR = 72
    bar_right = "─" * max(2, BAR - len(title) - 3)
    print(f"\x1b[36m  ┌─ {title} {bar_right}┐\x1b[0m", flush=True)
    for raw_line in content.splitlines():
        # Word-wrap lines longer than BAR to prevent visual overflow in GitLab UI
        for wrapped in textwrap.wrap(raw_line, width=BAR, break_long_words=True, break_on_hyphens=False) or [""]:
            print(f"\x1b[36m  │\x1b[0m  {wrapped}", flush=True)
    print(f"\x1b[36m  └─{'─' * BAR}┘\x1b[0m", flush=True)


def _log_ci_section(name: str, content: str, collapsed: bool = True, title: str = "") -> None:
    """Print a GitLab CI collapsible section to stdout with optional BoxLine.

    Sections appear in the job log as collapsed blocks (▶) that can be
    expanded with a single click — useful for long prompts / AI responses.
    """
    _ci_section_start(name, collapsed=collapsed)
    if title:
        _print_boxline(title, content)
    else:
        print(content, flush=True)
    _ci_section_end(name)


def _sdk_allow_all(request: object, invocation: object) -> dict:
    """Auto-approve all Copilot permission requests."""
    return {"decision": "allow"}


_DEFAULT_SDK_TIMEOUT = AgentConfig.COPILOT_SDK_TIMEOUT
_DEFAULT_CLI_TIMEOUT = AgentConfig.COPILOT_CLI_TIMEOUT
_DEFAULT_MODEL = AgentConfig.COPILOT_MODEL
_MAX_PROMPT_LEN = AgentConfig.MAX_PROMPT_LEN
_MAX_DIFF_LINES = AgentConfig.MAX_DIFF_LINES

# Patterns that must be sanitized before sending to Copilot
_SECRET_PATTERNS: list[tuple[str, str]] = [
    (r"(LICENCE_AES_KEY\s*=\s*)['\"][^'\"]+['\"]", r"\1'***MASKED***'"),
    (r"(GITLAB_TOKEN\s*=\s*)['\"][^'\"]+['\"]", r"\1'***MASKED***'"),
    (r"(PRIVATE.TOKEN\s*:\s*)['\"][^'\"]+['\"]", r"\1'***MASKED***'"),
    (r"(WEBHOOK_SECRET\s*=\s*)['\"][^'\"]+['\"]", r"\1'***MASKED***'"),
    (r"(password\s*=\s*)['\"][^'\"]+['\"]", r"\1'***MASKED***'"),
]


class CopilotClient:
    """Copilot SDK / CLI wrapper with 3-level graceful fallback.

    Fallback chain: SDK → CLI → disabled.

    Optimizations:
    - Separate SDK timeout (10 min) and CLI timeout (15 min)
    - Filters only added lines (+) from diffs before sending to SDK
    - Parallel analysis of multiple files via ThreadPoolExecutor
    - Secret sanitization before sending to Copilot

    Usage:
        copilot = CopilotClient()
        if copilot.available:
            result = copilot.ask(prompt)
        copilot.close()  # optional — cleans up SDK resources
    """

    def __init__(self) -> None:
        self.available: bool = False
        self.mode: str = "disabled"
        self.sdk_timeout: int = int(os.environ.get("COPILOT_SDK_TIMEOUT", str(_DEFAULT_SDK_TIMEOUT)))
        self.cli_timeout: int = int(os.environ.get("COPILOT_CLI_TIMEOUT", str(_DEFAULT_CLI_TIMEOUT)))
        self._model: str = os.environ.get("COPILOT_MODEL", _DEFAULT_MODEL)
        self._max_workers: int = int(os.environ.get("COPILOT_MAX_WORKERS", "3"))
        self._sdk_client: object | None = None
        self._sdk_session: object | None = None
        self._loop: asyncio.AbstractEventLoop | None = None

        if os.environ.get("COPILOT_ENABLED", "1") == "0":
            logger.info("[COPILOT] Force-disabled via COPILOT_ENABLED=0")
            return

        if self._try_sdk():
            self.mode = "SDK"
            self.available = True
            logger.info("[COPILOT] SDK mode - model=%s (timeout=%ds)", self._model, self.sdk_timeout)
            return

        if self._try_cli():
            self.mode = "CLI"
            self.available = True
            logger.info("[COPILOT] CLI mode - gh copilot explain (timeout=%ds)", self.cli_timeout)
            return

        logger.info("[COPILOT] Not available - Layer 1 regex-only mode")

    # ------------------------------------------------------------------
    # Initialization helpers
    # ------------------------------------------------------------------

    def _try_sdk(self) -> bool:
        """Try to initialize the Copilot SDK (github-copilot-sdk).
        SDK reads COPILOT_GITHUB_TOKEN from os.environ automatically.
        In CI/CD: set COPILOT_GITHUB_TOKEN as a GitLab CI/CD secret.
        """
        try:
            from copilot import CopilotClient as _SDKClient  # type: ignore
        except ImportError:
            logger.error("[COPILOT] SDK not installed (pip install github-copilot-sdk)")
            return False

        token = os.environ.get("COPILOT_GITHUB_TOKEN")
        if not token:
            logger.warning("[COPILOT] SDK skipped - COPILOT_GITHUB_TOKEN not set")
            return False

        logger.info("[COPILOT] SDK: COPILOT_GITHUB_TOKEN found, initializing...")

        try:
            self._loop = asyncio.new_event_loop()
            self._sdk_client = _SDKClient()
            self._loop.run_until_complete(self._sdk_client.start())
            self._sdk_session = self._loop.run_until_complete(
                self._sdk_client.create_session(
                    on_permission_request=_sdk_allow_all,
                    github_token=token,
                    model=self._model,
                )
            )
            actual_model = getattr(self._sdk_session, "model", self._model)
            logger.info("[COPILOT] SDK session created OK - model=%s", actual_model)
            return True
        except Exception as exc:
            logger.error("[COPILOT] SDK initialization failed: %s: %s", type(exc).__name__, exc)
            logger.debug("[COPILOT] SDK init traceback:\n%s", traceback.format_exc())
            self._cleanup_sdk()
            return False

    @staticmethod
    def _try_cli() -> bool:
        """Probe for gh CLI, authentication, and copilot extension."""
        if not shutil.which("gh"):
            logger.warning("[COPILOT] gh CLI not found on PATH")
            return False

        token = os.environ.get("COPILOT_GITHUB_TOKEN")
        if token:
            try:
                subprocess.run(
                    ["gh", "auth", "login", "--with-token"],
                    input=token,
                    capture_output=True,
                    text=True,
                    timeout=15,
                )
                logger.info("[COPILOT] CLI: gh auth login --with-token done")
            except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as exc:
                logger.error("[COPILOT] CLI: gh auth login failed: %s", exc)

        try:
            result = subprocess.run(
                ["gh", "auth", "status"],
                capture_output=True, text=True, timeout=10, stdin=subprocess.DEVNULL,
            )
            if result.returncode != 0:
                cleaned = False
                for line in (result.stderr or "").splitlines():
                    if "Failed to log in" in line and "(keyring)" in line:
                        try:
                            user = line.split("account ")[1].split(" (")[0].strip()
                            subprocess.run(
                                ["gh", "auth", "logout", "-h", "github.com", "-u", user],
                                capture_output=True, text=True, timeout=10,
                            )
                            logger.info("[COPILOT] CLI: removed broken keyring account: %s", user)
                            cleaned = True
                        except (IndexError, subprocess.TimeoutExpired, OSError):
                            pass
                if cleaned:
                    result = subprocess.run(
                        ["gh", "auth", "status"],
                        capture_output=True, text=True, timeout=10, stdin=subprocess.DEVNULL,
                    )
                if result.returncode != 0:
                    logger.warning("[COPILOT] gh not authenticated: %s", result.stderr[:200])
                    return False
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as exc:
            logger.error("[COPILOT] gh auth check failed: %s", exc)
            return False

        try:
            result = subprocess.run(
                ["gh", "copilot", "--version"],
                capture_output=True, text=True, timeout=10, stdin=subprocess.DEVNULL,
            )
            if result.returncode != 0:
                logger.warning("[COPILOT] gh copilot extension not installed")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as exc:
            logger.error("[COPILOT] gh copilot check failed: %s", exc)
            return False

        return True

    # ------------------------------------------------------------------
    # Cleanup
    # ------------------------------------------------------------------

    def _cleanup_sdk(self) -> None:
        """Release SDK resources (session, client, event loop)."""
        try:
            if self._sdk_session and self._loop and not self._loop.is_closed():
                self._loop.run_until_complete(self._sdk_session.destroy())
        except Exception:
            pass
        try:
            if self._sdk_client and self._loop and not self._loop.is_closed():
                self._loop.run_until_complete(self._sdk_client.stop())
        except (Exception, KeyboardInterrupt):
            pass
        if self._loop and not self._loop.is_closed():
            self._loop.close()
        self._sdk_session = None
        self._sdk_client = None
        self._loop = None

    def close(self) -> None:
        """Explicitly clean up SDK resources. Safe to call multiple times."""
        if self.mode == "SDK":
            self._cleanup_sdk()
            self.mode = "disabled"
            self.available = False

    def __del__(self) -> None:
        self.close()

    # ------------------------------------------------------------------
    # Sanitization
    # ------------------------------------------------------------------

    @staticmethod
    def _sanitize(text: str) -> str:
        """Remove potential secrets from text before sending to Copilot."""
        sanitized = text
        for pattern, replacement in _SECRET_PATTERNS:
            sanitized = re.sub(pattern, replacement, sanitized, flags=re.IGNORECASE)
        return sanitized

    # ------------------------------------------------------------------
    # Diff filtering
    # ------------------------------------------------------------------

    @staticmethod
    def _filter_added_lines(diff_text: str, max_lines: int = _MAX_DIFF_LINES) -> str:
        """Extract only lines starting with '+' (added lines) from a unified diff."""
        added_lines = []
        for line in diff_text.split("\n"):
            if line.startswith("+") and not line.startswith("+++"):
                added_lines.append(line[1:])
        filtered = "\n".join(added_lines[:max_lines])
        if len(added_lines) > max_lines:
            filtered += f"\n... ({len(added_lines) - max_lines} more added lines)"
        logger.info("[COPILOT] Filtered diff: %d added lines -> %d sent", len(added_lines), min(len(added_lines), max_lines))
        return filtered

    # ------------------------------------------------------------------
    # SDK transport
    # ------------------------------------------------------------------

    def _send_sdk(self, prompt: str) -> str | None:
        """Send prompt to the SDK session and return the response text."""
        if not self._sdk_session or not self._loop:
            return None
        try:
            return self._loop.run_until_complete(self._send_sdk_async(prompt))
        except Exception as exc:
            logger.warning(
                "[COPILOT] SDK send failed: %s: %s",
                type(exc).__name__,
                exc or "(no message - check COPILOT_GITHUB_TOKEN and gh auth login)",
            )
            return None

    async def _send_sdk_async(self, prompt: str) -> str | None:
        """Async helper: send prompt via send_and_wait, return text.

        Retries once with a fresh session if TimeoutError occurs.
        """
        for attempt in range(2):
            try:
                response = await self._sdk_session.send_and_wait(prompt, timeout=self.sdk_timeout)
                if response and response.data:
                    content = response.data.content
                    if content:
                        actual_model = getattr(response.data, "model", None) or self._model
                        logger.info("[COPILOT] SDK responded OK (%d chars) model=%s", len(content), actual_model)
                        self._last_actual_model = actual_model
                        return content
                    logger.warning(
                        "[COPILOT] send_and_wait returned response.data with no content (type=%s)",
                        type(response.data).__name__,
                    )
                elif response is not None:
                    logger.warning(
                        "[COPILOT] send_and_wait returned response with no .data (type=%s, repr=%r)",
                        type(response).__name__,
                        response,
                    )
                else:
                    logger.warning("[COPILOT] send_and_wait returned None (attempt %d)", attempt + 1)
                return None
            except TimeoutError:
                if attempt == 0:
                    logger.warning("[COPILOT] send_and_wait timeout after %ds - recreating session...", self.sdk_timeout)
                    try:
                        await self._sdk_session.destroy()
                    except Exception:
                        pass
                    _token = os.environ.get("COPILOT_GITHUB_TOKEN") or ""
                    self._sdk_session = await self._sdk_client.create_session(
                        on_permission_request=_sdk_allow_all,
                        github_token=_token,
                        model=self._model,
                    )
                else:
                    logger.warning("[COPILOT] Retry also timed out after %ds - giving up", self.sdk_timeout)
                    return None
        return None

    # ------------------------------------------------------------------
    # CLI transport (fallback)
    # ------------------------------------------------------------------

    def _run_explain(self, prompt: str) -> str | None:
        """Run gh copilot explain with the given prompt (CLI fallback)."""
        safe_prompt = self._sanitize(prompt[:_MAX_PROMPT_LEN])
        try:
            result = subprocess.run(
                ["gh", "copilot", "-p", safe_prompt],
                capture_output=True, text=True, encoding="utf-8", errors="replace",
                timeout=self.cli_timeout, stdin=subprocess.DEVNULL,
                env={**os.environ, "GH_PROMPT_DISABLED": "1"},
            )
            if result.returncode != 0:
                logger.warning("[COPILOT] explain returned %d: %s", result.returncode, result.stderr[:200])
                return None
            response = result.stdout.strip()
            if not response:
                logger.warning("[COPILOT] explain returned empty response")
                return None
            logger.info("[COPILOT] CLI responded OK (%d chars)", len(response))
            return response
        except subprocess.TimeoutExpired:
            logger.warning("[COPILOT] explain timed out after %ds", self.cli_timeout)
            return None
        except (FileNotFoundError, OSError) as exc:
            logger.warning("[COPILOT] explain failed: %s", exc)
            return None

    # ------------------------------------------------------------------
    # CI log helpers — separate concerns, customisable per agent
    # ------------------------------------------------------------------

    def _log_prompt_section(self, safe_prompt: str) -> None:
        """Section 1/3 — render the prompt exactly once.

        Layout (always emitted, regardless of prompt size):
          - 🧠 banner outside the GitLab CI section (visible header)
          - Info line outside the section
          - copilot_prompt section: collapsed when prompt > AUTO_COLLAPSE_THRESHOLD,
            visible otherwise; contains a single boxline with the sanitised prompt.
        """
        _print_banner("🧠", "Prompt Agent")
        _print_info("Prompt", "Layer 1 (regex) + Layer 2 (Copilot SDK/CLI fallback)")
        collapsed = len(safe_prompt) > AUTO_COLLAPSE_THRESHOLD
        _ci_section_start("copilot_prompt", collapsed=collapsed)
        _print_boxline(
            f"🧠 Prompt → {self.mode} ({len(safe_prompt)} chars)",
            safe_prompt,
        )
        _ci_section_end("copilot_prompt")

    def _log_summary_section(self, prompt_len: int, result_len: int,
                             latency: float, ok: bool) -> None:
        """Section 2/3 — metadata only (never contains prompt or result body).

        Always visible: the summary is short by construction (~6 lines) so the
        AUTO_COLLAPSE_THRESHOLD does not apply here.
        """
        _print_banner("📊", "Execution Summary")
        _ci_section_start("copilot_summary", collapsed=False)
        status = "✅ OK" if ok else "❌ FAIL"
        summary_body = "\n".join([
            f"Mode      : {self.mode}",
            f"Model     : {self._last_actual_model}",
            f"Prompt    : {prompt_len} chars",
            f"Result    : {result_len} chars",
            f"Latency   : {latency:.1f}s",
            f"Status    : {status}",
        ])
        _print_boxline("📊 Summary", summary_body)
        _ci_section_end("copilot_summary")

    def _log_result_section(self, result: str) -> None:
        """Section 3/3 — render the result exactly once.

        Layout:
          - 📋 banner outside the GitLab CI section (visible header)
          - copilot_response section: collapsed when result > AUTO_COLLAPSE_THRESHOLD,
            visible otherwise; contains a single boxline with the model output.
        """
        _print_banner("📋", "Result Prompt Agent")
        collapsed = len(result) > AUTO_COLLAPSE_THRESHOLD
        _ci_section_start("copilot_response", collapsed=collapsed)
        _print_boxline(
            f"📋 Result ← {self.mode} | model={self._last_actual_model} ({len(result)} chars)",
            result,
        )
        _ci_section_end("copilot_response")

    def _call_model(self, safe_prompt: str) -> str | None:
        """Dispatch to SDK or CLI and return the raw response."""
        self._last_actual_model = self._model
        if self.mode == "SDK":
            return self._send_sdk(safe_prompt)
        if self.mode == "CLI":
            return self._run_explain(safe_prompt)
        return None

    # ------------------------------------------------------------------
    # Unified dispatcher
    # ------------------------------------------------------------------

    def _ask(self, prompt: str) -> str | None:
        """Send prompt via SDK or CLI and emit three deduplicated CI log sections.

        Each of the three sections (prompt / summary / response) renders its
        content exactly once. The summary section reports metadata only —
        never the prompt or result body.
        """
        if not self.available:
            return None
        safe_prompt = self._sanitize(prompt[:_MAX_PROMPT_LEN])

        self._log_prompt_section(safe_prompt)

        t0 = time.perf_counter()
        result = self._call_model(safe_prompt)
        latency = time.perf_counter() - t0

        self._log_summary_section(
            prompt_len=len(safe_prompt),
            result_len=len(result or ""),
            latency=latency,
            ok=bool(result),
        )

        if result:
            self._log_result_section(result)
        return result

    # ------------------------------------------------------------------
    # Parallel analysis
    # ------------------------------------------------------------------

    def review_multiple_files(self, diffs: dict[str, str]) -> dict[str, str | None]:
        """Analyze multiple file diffs in parallel using ThreadPoolExecutor."""
        if not self.available:
            return {filename: None for filename in diffs}
        logger.info("[COPILOT] Starting parallel review of %d files (max_workers=%d)", len(diffs), self._max_workers)
        results: dict[str, str | None] = {}
        with ThreadPoolExecutor(max_workers=self._max_workers) as executor:
            futures = {executor.submit(self.review_code, diff): fname for fname, diff in diffs.items()}
            for future in as_completed(futures):
                fname = futures[future]
                try:
                    review = future.result(timeout=self.sdk_timeout * 2)
                    results[fname] = review
                    if review:
                        logger.info("[COPILOT] [%s] review OK (%d chars)", fname, len(review))
                    else:
                        logger.warning("[COPILOT] [%s] review empty", fname)
                except FuturesTimeoutError:
                    logger.warning("[COPILOT] [%s] timeout after %ss", fname, self.sdk_timeout * 2)
                    results[fname] = None
                except Exception as exc:
                    logger.error("[COPILOT] [%s] review failed: %s", fname, exc)
                    results[fname] = None
        return results

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def ask(self, prompt: str, timeout: int | None = None) -> str | None:
        """Send a prompt to the AI backend. Returns None if unavailable."""
        return self._ask(prompt)

    def review_code(self, diff_text: str) -> str | None:
        """Ask Copilot to review a code diff. Filters to added lines only."""
        filtered_diff = self._filter_added_lines(diff_text, max_lines=_MAX_DIFF_LINES)
        if not filtered_diff.strip():
            return None
        return self._ask(Prompts.CODE_REVIEW.format(diff_text=filtered_diff))

    def review_findings(self, count: int = 0, issues: str = "") -> str | None:
        """Ask Copilot to review summarized Layer 1 code findings."""
        if not issues.strip():
            return None
        return self._ask(load_prompt("code_reviewer", count=str(count), issues=issues))

    def analyze_security(self, count: int = 0, high_count: int = 0, findings: str = "") -> str | None:
        """Ask Copilot to analyze code for security vulnerabilities."""
        return self._ask(load_prompt("security_scanner", count=str(count), high_count=str(high_count), findings=findings))

    def suggest_fix(self, count: int = 0, lines: str = "") -> str | None:
        """Ask Copilot to suggest a fix for a CI/CD error."""
        return self._ask(load_prompt("cicd_agent", count=str(count), lines=lines))

    def suggest_tests(self, threshold: int = 80, total: float = 0.0, files: str = "", source_context: str = "") -> str | None:
        """Ask Copilot to suggest test cases for uncovered code."""
        return self._ask(load_prompt("test_coverage_agent", threshold=str(threshold), total=str(total), files=files, source_context=source_context))

    def explain_code(self, diff: str = "") -> str | None:
        """Ask Copilot to explain a code snippet or MR diff."""
        return self._ask(load_prompt("code_explainer", diff=diff))

    def audit_dependencies(self, vulns: str = "") -> str | None:
        """Ask Copilot for dependency vulnerability remediation guidance."""
        return self._ask(load_prompt("dependency_audit_agent", vulns=vulns))

    def suggest_documentation(self, items: str = "") -> str | None:
        """Ask Copilot to suggest docstrings for undocumented symbols."""
        return self._ask(load_prompt("documentation_agent", items=items))

    def analyze_flutter(self, errors: str = "") -> str | None:
        """Ask Copilot to diagnose Flutter analyzer errors."""
        return self._ask(load_prompt("flutter_analyzer_agent", errors=errors))

    def suggest_flutter_tests(self, threshold: int = 80, total: float = 0.0, files: str = "", source_context: str = "") -> str | None:
        """Ask Copilot to suggest Flutter widget test cases."""
        return self._ask(load_prompt("flutter_coverage_agent", threshold=str(threshold), total=str(total), files=files, source_context=source_context))

    def check_licenses(self, packages: str = "") -> str | None:
        """Ask Copilot to check license compliance."""
        return self._ask(load_prompt("license_compliance_agent", packages=packages))

    def generate_report(self, reports: str = "") -> str | None:
        """Ask Copilot to generate a pipeline executive summary."""
        return self._ask(load_prompt("pipeline_report_agent", reports=reports))

    def generate_executive_summary(
        self,
        context: str,
        scope: str,
    ) -> dict[str, str | list[str]] | None:
        """Ask Copilot for the 4-section AI Executive Summary block.

        Returns a dict with keys ``summary`` (str), ``key_points`` (list[str]),
        ``reviewer_notes`` (list[str]), ``recommended_actions`` (list[str]).
        Returns ``None`` if the AI is unavailable, the call fails, or the
        response cannot be parsed into the four required sections.
        """
        if not self.available:
            return None
        # Cap context to ~4 KB to stay under prompt limits.
        ctx = (context or "").strip()
        if len(ctx) > 4000:
            ctx = ctx[:4000] + "\n…(truncated)"
        try:
            raw = self._ask(load_prompt("executive_summary", scope=scope, context=ctx))
        except Exception as exc:  # noqa: BLE001
            logger.warning("[COPILOT] generate_executive_summary failed: %s", exc)
            return None
        if not raw:
            return None
        return _parse_exec_sections(raw)

    def validate_ci_yaml(self, yaml_content: str) -> str | None:
        """Ask Copilot to validate a .gitlab-ci.yml configuration."""
        return self._ask(Prompts.CICD_YAML_VALIDATE.format(yaml_content=yaml_content))

    def test_model_response(self) -> bool:
        """Quick health-check used by CI to verify model availability."""
        if not self.available:
            return False
        response = self._ask(Prompts.HEALTH_CHECK)
        return bool(response and "COPILOT_OK" in response)

    def is_available(self) -> bool:
        return self.available

    def __repr__(self) -> str:
        return f"CopilotClient(mode={self.mode})"


# ------------------------------------------------------------------
# Executive Summary parser — strict 4-section regex extractor
# ------------------------------------------------------------------

_EXEC_SECTIONS = ("Global Summary", "Key Points", "Reviewer Notes", "Recommended Actions")
_EXEC_SECTION_RE = re.compile(
    r"^\s*#{1,4}\s*(?:[\W_]*\s*)?(Global Summary|Key Points|Reviewer Notes|Recommended Actions)\s*[\W_]*\s*$",
    re.MULTILINE | re.IGNORECASE,
)
_EXEC_BULLET_RE = re.compile(r"^\s*(?:[-*•]|\d+[.)])\s+(.+?)\s*$")


def _parse_exec_sections(text: str) -> dict[str, str | list[str]] | None:
    """Parse AI executive-summary output into the 4 expected sections.

    Returns a dict with keys ``summary``, ``key_points``, ``reviewer_notes``,
    ``recommended_actions``. Returns ``None`` if any required section is
    missing or empty.
    """
    if not text or not text.strip():
        return None

    matches = list(_EXEC_SECTION_RE.finditer(text))
    if len(matches) < 4:
        return None

    found: dict[str, str] = {}
    for i, m in enumerate(matches):
        name = m.group(1).strip().title().replace("Key Points", "Key Points")  # normalize
        # canonical key
        for canon in _EXEC_SECTIONS:
            if name.lower() == canon.lower():
                name = canon
                break
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        found[name] = text[start:end].strip()

    if any(s not in found for s in _EXEC_SECTIONS):
        return None

    summary = found["Global Summary"].strip()

    def _bullets(block: str) -> list[str]:
        out: list[str] = []
        for line in block.splitlines():
            mm = _EXEC_BULLET_RE.match(line)
            if mm:
                bullet = mm.group(1).strip().rstrip(".")
                if bullet:
                    out.append(bullet)
        return out

    key_points = _bullets(found["Key Points"])
    reviewer_notes = _bullets(found["Reviewer Notes"])
    recommended_actions = _bullets(found["Recommended Actions"])

    if not (summary and key_points and reviewer_notes and recommended_actions):
        return None

    return {
        "summary": summary,
        "key_points": key_points,
        "reviewer_notes": reviewer_notes,
        "recommended_actions": recommended_actions,
    }


# ------------------------------------------------------------------
# HTML report generator — Markdown → standalone HTML (stdlib only)
# ------------------------------------------------------------------

def markdown_to_html(md: str, agent_name: str, timestamp: str = "") -> str:
    """Convert a Markdown agent report to a standalone HTML file.

    Pure stdlib implementation — no external dependencies.
    CSS is fully inline; the resulting file is self-contained.

    Args:
        md:          Markdown string (agent report).
        agent_name:  Display name shown in the HTML header.
        timestamp:   Optional UTC timestamp string (e.g. "2026-05-05 14:30 UTC").

    Returns:
        Complete HTML string starting with ``<!DOCTYPE html>``.
    """
    import html as _html
    import re as _re

    CSS = """
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #0d1117; color: #e6edf3;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-size: 14px; line-height: 1.6; padding: 24px;
        }
        .container { max-width: 960px; margin: 0 auto; }
        .header {
            background: linear-gradient(135deg, #161b22 0%, #1c2128 100%);
            border: 1px solid #30363d; border-radius: 8px;
            padding: 20px 24px; margin-bottom: 24px;
        }
        .header h1 { font-size: 20px; color: #58a6ff; margin-bottom: 4px; }
        .header .meta { color: #8b949e; font-size: 12px; }
        .header .brand { color: #3fb950; font-size: 11px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1px; }
        h2 { font-size: 16px; color: #58a6ff; border-bottom: 1px solid #21262d;
            padding-bottom: 6px; margin: 24px 0 12px; }
        h3 { font-size: 14px; color: #79c0ff; margin: 16px 0 8px; }
        p { margin: 8px 0; }
        ul { margin: 8px 0 8px 20px; }
        li { margin: 4px 0; }
        code {
            background: #161b22; border: 1px solid #30363d; border-radius: 3px;
            padding: 1px 6px; font-family: "SFMono-Regular", Consolas, monospace;
            font-size: 13px; color: #ff7b72;
        }
        pre {
            background: #161b22; border: 1px solid #30363d; border-radius: 6px;
            padding: 12px 16px; overflow-x: auto; margin: 12px 0;
        }
        pre code { background: none; border: none; padding: 0;
            color: #e6edf3; font-size: 13px; }
        table {
            width: 100%; border-collapse: collapse; margin: 12px 0;
            font-size: 13px;
        }
        th {
            background: #21262d; color: #79c0ff; padding: 8px 12px;
            text-align: left; border: 1px solid #30363d; font-weight: 600;
        }
        td { padding: 6px 12px; border: 1px solid #21262d; vertical-align: top; }
        tr:nth-child(even) { background: #161b22; }
        tr:nth-child(odd) { background: #0d1117; }
        strong { color: #f0f6fc; font-weight: 600; }
        em { color: #8b949e; }
        hr { border: none; border-top: 1px solid #21262d; margin: 20px 0; }
        .footer {
            margin-top: 32px; padding-top: 12px; border-top: 1px solid #21262d;
            color: #8b949e; font-size: 11px; text-align: center;
        }
    """

    def _escape(text: str) -> str:
        return _html.escape(text, quote=False)

    lines = md.splitlines()
    html_parts: list[str] = []
    in_pre = False
    in_table = False
    in_ul = False
    i = 0

    def _close_context() -> None:
        nonlocal in_table, in_ul
        if in_table:
            html_parts.append("</tbody></table>")
            in_table = False
        if in_ul:
            html_parts.append("</ul>")
            in_ul = False

    def _inline(text: str) -> str:
        """Apply inline formatting: bold, italic, inline code."""
        # inline code (must come first to avoid double-escaping)
        text = _re.sub(r"`([^`]+)`", lambda m: f"<code>{_escape(m.group(1))}</code>", text)
        text = _re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
        text = _re.sub(r"\*(.+?)\*", r"<em>\1</em>", text)
        return text

    while i < len(lines):
        raw = lines[i]

        # Fenced code blocks
        if raw.strip().startswith("```"):
            _close_context()
            if not in_pre:
                in_pre = True
                html_parts.append("<pre><code>")
            else:
                in_pre = False
                html_parts.append("</code></pre>")
            i += 1
            continue

        if in_pre:
            html_parts.append(_escape(raw) + "\n")
            i += 1
            continue

        # Headings
        if raw.startswith("### "):
            _close_context()
            html_parts.append(f"<h3>{_inline(_escape(raw[4:]))}</h3>")
            i += 1
            continue
        if raw.startswith("## "):
            _close_context()
            html_parts.append(f"<h2>{_inline(_escape(raw[3:]))}</h2>")
            i += 1
            continue
        if raw.startswith("# "):
            _close_context()
            html_parts.append(f"<h2>{_inline(_escape(raw[2:]))}</h2>")
            i += 1
            continue

        # Horizontal rule
        if raw.strip() in ("---", "***", "___"):
            _close_context()
            html_parts.append("<hr>")
            i += 1
            continue

        # Table rows
        if raw.strip().startswith("|"):
            cells = [c.strip() for c in raw.strip().strip("|").split("|")]
            # Skip separator rows like |---|---|
            if all(_re.match(r"^[-:]+$", c) for c in cells if c):
                i += 1
                continue
            if not in_table:
                in_ul and html_parts.append("</ul>") or None
                in_ul = False
                in_table = True
                # First row → header
                html_parts.append('<table><thead><tr>')
                for c in cells:
                    html_parts.append(f"<th>{_inline(_escape(c))}</th>")
                html_parts.append("</tr></thead><tbody>")
            else:
                html_parts.append("<tr>")
                for c in cells:
                    html_parts.append(f"<td>{_inline(_escape(c))}</td>")
                html_parts.append("</tr>")
            i += 1
            continue

        # Close table if we were in one
        if in_table:
            html_parts.append("</tbody></table>")
            in_table = False

        # List items
        if raw.startswith("- ") or raw.startswith("* "):
            if not in_ul:
                html_parts.append("<ul>")
                in_ul = True
            html_parts.append(f"<li>{_inline(_escape(raw[2:]))}</li>")
            i += 1
            continue

        # Close ul if we were in one
        if in_ul and raw.strip() == "":
            html_parts.append("</ul>")
            in_ul = False

        # Blank line
        if raw.strip() == "":
            html_parts.append("<br>")
            i += 1
            continue

        # Regular paragraph line
        html_parts.append(f"<p>{_inline(_escape(raw))}</p>")
        i += 1

    _close_context()

    body = "\n".join(html_parts)
    ts_display = _escape(timestamp) if timestamp else "—"
    agent_display = _escape(agent_name)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{agent_display} — Viewer_NG CI Report</title>
<style>{CSS}</style>
</head>
<body>
<div class="container">
  <div class="header">
    <div class="brand">Viewer_NG · CI Agent Report</div>
    <h1>🤖 {agent_display}</h1>
    <div class="meta">Generated: {ts_display} &nbsp;|&nbsp; Model: claude-sonnet-4.6 &nbsp;|&nbsp; Layer 1 + Layer 2 (Copilot SDK)</div>
  </div>
  <div class="content">
{body}
  </div>
  <div class="footer">
    Viewer_NG — Sagemcom &nbsp;·&nbsp; Copilot Agents CI Pipeline &nbsp;·&nbsp; {ts_display}
  </div>
</div>
</body>
</html>"""


# ------------------------------------------------------------------
# Prompt loader (for .md-based prompts in agents/prompts/)
# ------------------------------------------------------------------

_PROMPTS_DIR = Path(__file__).parent / "prompts"

# Fallback mapping: .md name → Prompts.* constant name (used when .md file is missing)
_PROMPT_FALLBACK_MAP: dict[str, str] = {
    "security_scanner": "SECURITY_SCAN",
    "code_reviewer": "CODE_REVIEW_FINDINGS",
    "test_coverage_agent": "COVERAGE_SUGGESTIONS",
    "flutter_coverage_agent": "FLUTTER_COVERAGE_SUGGESTIONS",
    "flutter_analyzer_agent": "FLUTTER_ANALYZE",
    "dependency_audit_agent": "DEPENDENCY_AUDIT",
    "license_compliance_agent": "LICENSE_COMPLIANCE",
    "documentation_agent": "DOCUMENTATION",
    "code_explainer": "CODE_EXPLAIN",
    "cicd_agent": "CICD_FIX",
    "pipeline_report_agent": "PIPELINE_REPORT",
}

_load_prompt_logger = logging.getLogger(__name__)


def load_prompt(name: str, **kwargs: str) -> str:
    """Load a prompt template from agents/prompts/<name>.md and format it with kwargs.

    YAML frontmatter (--- ... ---) is automatically stripped before formatting.
    Falls back to Prompts.* constants if the .md file is not found.
    """
    path = _PROMPTS_DIR / f"{name}.md"
    try:
        template = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        _load_prompt_logger.warning(
            "Prompt file not found: %s — falling back to Prompts.* constant", path
        )
        fallback_attr = _PROMPT_FALLBACK_MAP.get(name)
        if fallback_attr:
            try:
                return getattr(Prompts, fallback_attr).format(**kwargs)
            except (KeyError, AttributeError):
                pass
        raise
    # Strip YAML frontmatter if present (--- ... ---)
    if template.startswith("---"):
        end = template.find("---", 3)
        if end != -1:
            template = template[end + 3:].lstrip("\n")
    return template.format(**kwargs) if kwargs else template


def main() -> int:
    """CLI health-check entry point for CI jobs."""
    import datetime
    import textwrap
    import unicodedata
    
    # Force UTF-8 output on Windows
    if sys.stdout.encoding != 'utf-8':
        sys.stdout.reconfigure(encoding='utf-8')

    W = 58  # box width (inner)
    BOX_TOP    = "╔" + "═" * W + "╗"
    BOX_BOT    = "╚" + "═" * W + "╝"
    BOX_SEP    = "╠" + "═" * W + "╣"
    BOX_MID    = "║"
    SUB_TOP    = "┌" + "─" * W + "┐"
    SUB_BOT    = "└" + "─" * W + "┘"
    SUB_MID    = "│"
    C_CYAN     = "\x1b[36m"
    C_RESET    = "\x1b[0m"

    def _display_width(text: str) -> int:
        width = 0
        for ch in text:
            if ch == "\ufe0f" or unicodedata.combining(ch):
                continue
            width += 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
        return width

    def _truncate_display_width(text: str, max_width: int) -> str:
        if max_width <= 0:
            return ""
        out: list[str] = []
        cur = 0
        for ch in text:
            if ch == "\ufe0f" or unicodedata.combining(ch):
                out.append(ch)
                continue
            ch_w = 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
            if cur + ch_w > max_width:
                break
            out.append(ch)
            cur += ch_w
        return "".join(out)

    def _pad_display(text: str, width: int) -> str:
        trimmed = _truncate_display_width(text, width)
        return trimmed + " " * max(0, width - _display_width(trimmed))

    def _row(text: str = "", width: int = W) -> str:
        return f"{BOX_MID}  {_pad_display(text, width - 2)}{BOX_MID}"

    def _sub_row(text: str = "", width: int = W) -> str:
        return f"{SUB_MID}  {_pad_display(text, width - 2)}{SUB_MID}"

    def _simple_row(text: str = "", width: int = W) -> str:
        return f"  │ {_pad_display(text, width - 1)}│"

    def _center(text: str, width: int = W) -> str:
        return f"{BOX_MID}{text.center(width)}{BOX_MID}"

    def _print_box(line: str) -> None:
        # Avoid per-character ANSI coloring: it can break alignment in GitLab logs.
        stripped = line.lstrip(" ")
        indent = line[: len(line) - len(stripped)]

        if not stripped:
            print(line)
            return

        if stripped[0] in "╔╚╠┌└":
            print(f"{indent}{C_CYAN}{stripped}{C_RESET}")
            return

        if stripped[0] in "║│" and stripped[-1] in "║│" and len(stripped) >= 2:
            print(f"{indent}{C_CYAN}{stripped[0]}{C_RESET}{stripped[1:-1]}{C_CYAN}{stripped[-1]}{C_RESET}")
            return

        print(line)

    # ── Banner with emoji ──────────────────────────────────────────
    print()
    _print_box(BOX_TOP)
    _print_box(_row("🤖  Copilot Availability Check"))
    _print_box(BOX_BOT)

    # ── Environment info ───────────────────────────────────────────
    token = os.environ.get("COPILOT_GITHUB_TOKEN", "")
    token_info = (
        f"✓ SET  (length={len(token)}, prefix={token[:12]}...)" if token else "⚠ NOT SET"
    )
    print()
    _print_box(SUB_TOP)
    _print_box(_sub_row("🧪  COPILOT HEALTH CHECK  ·  Viewer_NG CI Agent"))
    _print_box(_sub_row("⚙️  Environment & Configuration"))
    _print_box(_sub_row(f"🔑 Token   : {token_info}"))
    _print_box(_sub_row(f"📦 Model   : {_DEFAULT_MODEL}"))
    _print_box(_sub_row(f"⏱️ Timeout : {_DEFAULT_SDK_TIMEOUT}s (SDK) / {_DEFAULT_CLI_TIMEOUT}s (CLI)"))
    _print_box(SUB_BOT)

    # ── Initialization steps ───────────────────────────────────────
    print()
    print("  ┄" + "─" * (W - 2))
    print("  📋 Initialization Steps")
    print("  ┄" + "─" * (W - 2))
    print("  [1/4]  ℹ️  Initializing CopilotClient ...")
    client = CopilotClient()

    mode_str = getattr(client, 'mode', 'unknown')
    print(f"  [2/4]  ✓ Mode resolved  →  {mode_str.upper()}  (SDK → CLI → disabled)")
    if mode_str == "disabled":
        print(f"  [3/4]  🔗 Session unavailable  (model target: {_DEFAULT_MODEL})")
    else:
        print(f"  [3/4]  🔗 Session opened with model : {_DEFAULT_MODEL}")

    prompt = Prompts.HEALTH_CHECK
    print(f"  [4/4]  📤 Sending prompt : \"{prompt}\"")
    print("  ┄" + "─" * (W - 2))

    # ── Send ───────────────────────────────────────────────────────
    t0 = datetime.datetime.now(datetime.timezone.utc)
    response = client._ask(prompt) if client.available else None
    t1 = datetime.datetime.now(datetime.timezone.utc)
    latency = round((t1 - t0).total_seconds(), 1)
    ok = bool(response and "COPILOT_OK" in response)

    # ── Response box ───────────────────────────────────────────────
    print()
    _print_box(SUB_TOP)
    _print_box(_sub_row("📤 SDK Response"))
    resp_display = str(response) if response else "None"
    for line in textwrap.wrap(resp_display, width=W - 4) or [resp_display]:
        _print_box(_sub_row(f"  {line}"))
    _print_box(SUB_BOT)

    # ── Summary - Fancy boxes ───────────────────────────────────────
    status_icon = "✅" if ok else "❌"
    status_label = "✓ OK" if ok else "✘ UNAVAILABLE"
    availability = "COPILOT AVAILABLE" if ok else "COPILOT UNAVAILABLE"
    ts = t1.strftime("%Y-%m-%d  %H:%M:%S  UTC")

    print()
    _print_box(BOX_TOP)
    _print_box(_row(f"  {status_icon}  {availability}"))
    _print_box(BOX_SEP)
    _print_box(_row())
    _print_box(_row(f"  📊 Status    :  {status_label}"))
    _print_box(_row(f"  🔄 Mode      :  {mode_str}"))
    _print_box(_row(f"  🤖 Model     :  {_DEFAULT_MODEL}"))
    _print_box(_row(f"  ⚡ Latency   :  {latency}s"))
    _print_box(_row(f"  🕐 Timestamp :  {ts}"))
    _print_box(BOX_BOT)

    # ── Summary - Simple pattern (for CI logs) ────────────────────
    simple_status_icon = "✅" if ok else "❌"
    simple_ts = t1.strftime("%Y-%m-%d %H:%M:%S UTC")
    print()
    _smry_hdr = "─ Copilot Health Summary "
    _smry_top = "┌" + _smry_hdr + "─" * max(0, W - len(_smry_hdr)) + "┐"
    _smry_bot = "└" + "─" * W + "┘"
    _print_box(f"  {_smry_top}")
    _print_box(_simple_row(f"Status    : {simple_status_icon} {status_label}"))
    _print_box(_simple_row("Mode      : SDK → CLI → disabled"))
    _print_box(_simple_row(f"Model     : {_DEFAULT_MODEL}"))
    _print_box(_simple_row(f"Latency   : ⚡ {latency}s"))
    response_label = response if response else "None"
    _print_box(_simple_row(f"Response  : '{response_label}'"))
    _print_box(_simple_row(f"Timestamp : 🕐 {simple_ts}"))
    _print_box(f"  {_smry_bot}")
    print()

    client.close()
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
