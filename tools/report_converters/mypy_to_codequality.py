"""
tools/ci/mypy_to_codequality.py
Convert mypy text output to GitLab Code Quality JSON.

Usage:
    python tools/ci/mypy_to_codequality.py <input_txt> <output_json>

Defaults:
    input  : backend/reports/mypy_report.txt
    output : backend/reports/mypy_codequality.json
"""

import re
import sys
import json
import hashlib
import pathlib

input_path = pathlib.Path(
    sys.argv[1] if len(sys.argv) > 1 else "backend/reports/mypy_report.txt"
)
output_path = pathlib.Path(
    sys.argv[2] if len(sys.argv) > 2 else "backend/reports/mypy_codequality.json"
)

lines = input_path.read_text(encoding="utf-8", errors="replace").splitlines()

PAT = re.compile(r"^(.+?):(\d+):\s+(error|warning|note):\s+(.+)$")
SEV_MAP = {"error": "major", "warning": "minor", "note": "info"}

issues = []
for line in lines:
    m = PAT.match(line.strip())
    if not m:
        continue
    path, row, sev, msg = m.groups()
    fp = hashlib.md5(f"{path}:{row}:{sev}:{msg[:80]}".encode()).hexdigest()
    issues.append(
        {
            "description": msg.strip(),
            "check_name": "mypy",
            "fingerprint": fp,
            "severity": SEV_MAP.get(sev, "info"),
            "location": {
                "path": path.replace("\\", "/"),
                "lines": {"begin": int(row)},
            },
        }
    )

output_path.parent.mkdir(parents=True, exist_ok=True)
output_path.write_text(json.dumps(issues, indent=2), encoding="utf-8")
print(f"[mypy-cq] {len(issues)} issues written to {output_path}")
