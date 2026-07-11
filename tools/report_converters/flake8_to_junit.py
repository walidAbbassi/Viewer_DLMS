"""
tools/ci/flake8_to_junit.py
Convert a flake8 text report (--tee --output-file) to JUnit XML.

Usage:
    python tools/ci/flake8_to_junit.py <input_txt> <output_xml>

Defaults:
    input  : backend/reports/flake8_report.txt
    output : backend/reports/flake8_junit.xml
"""

import re
import sys
import pathlib
import xml.etree.ElementTree as ET

input_path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "backend/reports/flake8_report.txt")
output_path = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else "backend/reports/flake8_junit.xml")

lines = input_path.read_text(encoding="utf-8", errors="replace").splitlines()

suite = ET.Element("testsuite", name="flake8")
failures = 0
pat = re.compile(r"^(.+?):(\d+):(\d+):\s+([A-Z]\d+)\s+(.+)$")

for line in lines:
    m = pat.match(line)
    if not m:
        continue
    path, row, col, code, msg = m.groups()
    tc = ET.SubElement(
        suite,
        "testcase",
        name=f"{code} @ {path}:{row}:{col}",
        classname=code,
    )
    ET.SubElement(tc, "failure", message=msg, type=code).text = (
        f"{path}:{row}:{col}: {code} {msg}"
    )
    failures += 1

suite.set("tests", str(failures))
suite.set("failures", str(failures))

root = ET.Element("testsuites")
root.append(suite)
tree = ET.ElementTree(root)
ET.indent(tree, space="  ")
output_path.parent.mkdir(parents=True, exist_ok=True)
tree.write(str(output_path), encoding="utf-8", xml_declaration=True)
print(f"[flake8-junit] {failures} violations written to {output_path}")
