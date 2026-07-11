"""
tools/ci/flutter_to_codequality.py
Convert 'flutter analyze' text output to GitLab Code Quality JSON.

Usage:
    python tools/ci/flutter_to_codequality.py <input_txt> <output_json>

Defaults:
    input  : flutter_app/flutter_analyze.txt
    output : flutter_app/flutter_codequality.json
"""

import re
import sys
import json
import hashlib
import pathlib

input_path = pathlib.Path(
    sys.argv[1] if len(sys.argv) > 1 else "flutter_app/flutter_analyze.txt"
)
output_path = pathlib.Path(
    sys.argv[2] if len(sys.argv) > 2 else "flutter_app/flutter_codequality.json"
)

lines = input_path.read_text(encoding="utf-8", errors="replace").splitlines()

# Flutter analyze output line format (dot separator may be a UTF-8 bullet):
#   error   • <message> • <file>:<line>:<col> • <rule>
# or plain ASCII: error - message - file:line:col - rule
SEP = r"(?:\s+\u2022\s+|\s+-\s+|\s+\xb7\s+|\s+\xe2\x80\xa2\s+)"
PAT = re.compile(
    r"^\s*(error|warning|info)" + SEP + r"(.+?)" + SEP + r"(.+?):(\d+):(\d+)" + SEP + r"(\S+)\s*$"
)

SEV_MAP = {"error": "major", "warning": "minor", "info": "info"}

issues = []
for line in lines:
    m = PAT.match(line)
    if not m:
        continue
    sev, msg, path, row, col, rule = m.groups()
    fp = hashlib.md5(f"{path}:{row}:{col}:{rule}".encode()).hexdigest()
    issues.append(
        {
            "description": msg.strip(),
            "check_name": rule.strip(),
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
print(f"[flutter-cq] {len(issues)} issues written to {output_path}")
