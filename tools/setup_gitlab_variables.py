"""
setup_gitlab_variables.py — Idempotent initialiser for Viewer NG GitLab CI/CD variables.

Reads GITLAB_TOKEN from environment or from a .env file, then creates or updates
every project-level CI variable so that .gitlab-ci.yml contains no hardcoded values.

Usage:
    python tools/setup_gitlab_variables.py [--dry-run] [--force] [--env-file PATH]

Flags:
    --dry-run    Print what would happen without touching GitLab.
    --force      Also update variables that already exist (default: skip if same value).
    --env-file   Path to a .env file containing GITLAB_TOKEN= (default: auto-detect).

Skip list:
    GITLAB_TOKEN and COPILOT_GITHUB_TOKEN are never created/updated by this script
    (they are masked secrets managed manually in the GitLab UI).
"""

import argparse
import os
import sys
from pathlib import Path

import httpx

# ── Configuration ──────────────────────────────────────────────────────────────

GITLAB_URL = "https://gitlab-produits.rmm.scom"
PROJECT_ID = 2202

# Variables to skip (managed manually as masked secrets in GitLab UI)
SKIP_VARS = {"GITLAB_TOKEN", "COPILOT_GITHUB_TOKEN"}

# All CI/CD variables to register — edit here to change defaults.
# Format: (key, value, protected, masked, description)
VARIABLES: list[tuple[str, str, bool, bool, str]] = [
    # ── Runner ──────────────────────────────────────────────────────────────
    ("RUNNER_TAG",              "viewerng_local",                       False, False, "GitLab runner tag used by all jobs"),
    # ── Toolchain paths ─────────────────────────────────────────────────────
    ("PYTHON_BIN",              r"C:\Python314_2\python.exe",           False, False, "Python executable used in all backend jobs"),
    ("FLUTTER_BIN",             r"C:\flutter\bin\flutter.bat",          False, False, "Flutter executable used in frontend jobs"),
    ("FLUTTER_SAFE_DIR",        r"C:\flutter",                          False, False, "Directory added to git safe.directory for Flutter"),
    ("JGENHTML_BIN",            r"C:\jgenhtml-master\jgenhtml.bat",     False, False, "jgenhtml executable for lcov→HTML conversion"),
    # ── Dependencies ────────────────────────────────────────────────────────
    ("NG_SDK_WHL",              "ng_sdk_whl/ng_sdk-0.1.0-py3-none-any.whl", False, False, "Path to ng_sdk wheel (relative to repo root)"),
    ("BACKEND_REQUIREMENTS",    "backend/requirements.txt",             False, False, "Path to backend pip requirements file"),
    ("FLUTTER_PUBSPEC",         "flutter_app/pubspec.yaml",             False, False, "Path to Flutter pubspec.yaml"),
    # ── Network / proxy ─────────────────────────────────────────────────────
    ("HTTP_PROXY",              "http://10.207.14.250:8080",            False, False, "Corporate HTTP proxy"),
    ("HTTPS_PROXY",             "http://10.207.14.250:8080",            False, False, "Corporate HTTPS proxy"),
    ("NO_PROXY",                "gitlab-produits.rmm.scom,localhost,127.0.0.1", False, False, "Hosts that bypass the proxy"),
    ("PIP_RETRIES",             "8",                                    False, False, "Number of pip install retries"),
    ("PIP_TIMEOUT",             "120",                                  False, False, "pip install timeout in seconds"),
    ("GIT_SSL_NO_VERIFY",       "true",                                 False, False, "Disable SSL verification for git (corporate cert chain)"),
    # ── Quality gates / thresholds ──────────────────────────────────────────
    ("FLAKE8_MAX_LINE_LENGTH",  "120",                                  False, False, "Max line length for flake8 linting"),
    ("BACKEND_COV_THRESHOLD",   "50",                                   False, False, "Minimum backend test coverage percentage"),
    ("FLUTTER_COV_THRESHOLD",   "30",                                   False, False, "Minimum Flutter test coverage percentage"),
    # ── AI / Copilot ────────────────────────────────────────────────────────
    ("COPILOT_MODEL",           "claude-sonnet-4.6",                    False, False, "Default Copilot/AI model for review agents"),
    # ── Python runtime ──────────────────────────────────────────────────────
    ("PYTHONUTF8",              "1",                                    False, False, "Force UTF-8 mode for Python"),
    ("PYTHONIOENCODING",        "utf-8",                                False, False, "Force UTF-8 I/O encoding for Python"),
]

# ── Helpers ────────────────────────────────────────────────────────────────────

ENV_FILE_CANDIDATES = [
    r"C:\workspace\server_mcp\.env",
    Path(__file__).parent.parent / ".env",
    Path.home() / ".env",
]


def load_token(env_file: str | None) -> str:
    """Load GITLAB_TOKEN from environment or .env file."""
    if token := os.environ.get("GITLAB_TOKEN"):
        return token.strip()

    candidates = [Path(env_file)] if env_file else ENV_FILE_CANDIDATES
    for path in candidates:
        path = Path(path)
        if path.exists():
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.startswith("GITLAB_TOKEN="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")

    print("ERROR: GITLAB_TOKEN not found in environment or any .env file.", file=sys.stderr)
    print("Set GITLAB_TOKEN env var or provide --env-file PATH.", file=sys.stderr)
    sys.exit(1)


def get_existing_variables(client: httpx.Client) -> dict[str, str]:
    """Return {key: value} for all existing project CI variables."""
    existing: dict[str, str] = {}
    page = 1
    while True:
        resp = client.get(
            f"/api/v4/projects/{PROJECT_ID}/variables",
            params={"per_page": 100, "page": page},
        )
        resp.raise_for_status()
        data = resp.json()
        if not data:
            break
        for var in data:
            existing[var["key"]] = var["value"]
        if len(data) < 100:
            break
        page += 1
    return existing


def create_variable(client: httpx.Client, key: str, value: str, protected: bool, masked: bool) -> None:
    resp = client.post(
        f"/api/v4/projects/{PROJECT_ID}/variables",
        json={"key": key, "value": value, "protected": protected, "masked": masked, "variable_type": "env_var"},
    )
    resp.raise_for_status()


def update_variable(client: httpx.Client, key: str, value: str, protected: bool, masked: bool) -> None:
    resp = client.put(
        f"/api/v4/projects/{PROJECT_ID}/variables/{key}",
        json={"value": value, "protected": protected, "masked": masked, "variable_type": "env_var"},
    )
    resp.raise_for_status()


# ── Main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Initialise GitLab CI/CD variables for Viewer NG (idempotent).")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without touching GitLab.")
    parser.add_argument("--force", action="store_true", help="Update existing variables even if value is the same.")
    parser.add_argument("--env-file", metavar="PATH", help="Path to .env file containing GITLAB_TOKEN=.")
    args = parser.parse_args()

    token = load_token(args.env_file)

    client = httpx.Client(
        base_url=GITLAB_URL,
        headers={"PRIVATE-TOKEN": token},
        verify=False,  # corporate self-signed cert
        timeout=30,
    )

    print(f"{'[DRY-RUN] ' if args.dry_run else ''}Connecting to {GITLAB_URL} (project {PROJECT_ID}) …")

    existing = get_existing_variables(client)
    print(f"  Found {len(existing)} existing variable(s) in GitLab.\n")

    created = updated = skipped = skipped_secret = 0

    for key, value, protected, masked, description in VARIABLES:
        if key in SKIP_VARS:
            print(f"  ⏭  SKIP    {key:30s}  (managed secret — never overwritten)")
            skipped_secret += 1
            continue

        if key in existing:
            if existing[key] == value and not args.force:
                print(f"  ✔  SAME    {key:30s}  (no change)")
                skipped += 1
            else:
                action = "UPDATE"
                print(f"  {'[DRY] ' if args.dry_run else ''}↑  {action}  {key:30s}  = {value!r}")
                if not args.dry_run:
                    update_variable(client, key, value, protected, masked)
                updated += 1
        else:
            print(f"  {'[DRY] ' if args.dry_run else ''}+  CREATE  {key:30s}  = {value!r}  # {description}")
            if not args.dry_run:
                create_variable(client, key, value, protected, masked)
            created += 1

    print()
    print("─" * 60)
    print(f"  Created : {created}")
    print(f"  Updated : {updated}")
    print(f"  Skipped (same value) : {skipped}")
    print(f"  Skipped (secret)     : {skipped_secret}")
    if args.dry_run:
        print("\n  [DRY-RUN] No changes were made to GitLab.")
    else:
        print("\n  ✅ Done — GitLab CI/CD variables are up to date.")


if __name__ == "__main__":
    main()
