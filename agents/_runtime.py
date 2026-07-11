"""Runtime helpers shared across every CI agent.

Provides ``crash_wrap``: execute an agent's ``main()`` impl with a global
try/except that prints the traceback and writes a minimal Markdown CRASH
report to the agent's ``--output`` path so downstream consumers (Atlas
aggregator, CI script) always see a file and a non-zero exit code.
"""
from __future__ import annotations

import sys
import traceback
from pathlib import Path
from typing import Callable


def _extract_output_path(argv: list[str]) -> str | None:
    """Pull the value of ``--output PATH`` or ``--output=PATH`` from argv.

    Returns None if no --output flag is present.
    """
    for i, arg in enumerate(argv):
        if arg == "--output" and i + 1 < len(argv):
            return argv[i + 1]
        if arg.startswith("--output="):
            return arg.split("=", 1)[1]
    return None


def _write_crash_report(output_path: str, agent_title: str, exc: BaseException) -> None:
    """Best-effort write of a minimal CRASH MD report (never raises)."""
    try:
        path = Path(output_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            f"## {agent_title} — CRASH\n\n"
            f"⚠ `{type(exc).__name__}: {exc}`\n\n"
            "See CI job log for the full traceback.\n",
            encoding="utf-8",
        )
    except Exception:  # noqa: BLE001 - intentional swallow: never block on the fallback
        pass


def crash_wrap(main_impl: Callable[[], int | None],
               agent_title: str,
               argv: list[str] | None = None) -> int:
    """Run ``main_impl`` with a global try/except wrapper.

    * On normal completion: returns ``int(main_impl() or 0)``.
    * On any uncaught Exception:
        - prints the full traceback to stderr
        - writes a CRASH MD report to the ``--output`` path (if any) so Atlas
          aggregation always finds the file
        - returns 1, so callers that ``sys.exit(crash_wrap(...))`` propagate
          a failed status to GitLab CI.

    ``SystemExit`` and ``KeyboardInterrupt`` are NOT caught — they bubble up
    so the original control-flow semantics are preserved.
    """
    argv = argv if argv is not None else sys.argv
    try:
        result = main_impl()
        return int(result) if result is not None else 0
    except (SystemExit, KeyboardInterrupt):
        raise
    except Exception as exc:  # noqa: BLE001
        traceback.print_exc()
        out = _extract_output_path(argv)
        if out:
            _write_crash_report(out, agent_title, exc)
        return 1
