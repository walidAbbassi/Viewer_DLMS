#!/usr/bin/env python3
"""
Parse pytest-cov coverage.json -> per-module breakdown table + KPI lines.

Usage:
  pytest_coverage_breakdown.py [coverage_json] [threshold]

Defaults:
  coverage_json : backend/reports/coverage.json
  threshold     : 50  (warn if module coverage < threshold %)

Stdout:
  COVERAGE_TOTAL: pct=XX.XX% lines=N/M branches=N/M
  COVERAGE_LOW: file1.py=X%  file2.py=Y%  ...
  (markdown-style table of worst 20 modules sorted by coverage % ascending)
"""

import json
import sys
import pathlib


def main(cov_json: str = "backend/reports/coverage.json", threshold: float = 50.0) -> None:
    data = json.loads(pathlib.Path(cov_json).read_text(encoding="utf-8", errors="replace"))

    totals = data.get("totals", {})
    total_stmts = totals.get("num_statements", 0)
    covered_stmts = totals.get("covered_lines", 0)
    total_branches = totals.get("num_branches", 0)
    covered_branches = totals.get("covered_branches", 0)
    pct = round(totals.get("percent_covered", 0.0), 2)

    print(
        f"COVERAGE_TOTAL: pct={pct}%  lines={covered_stmts}/{total_stmts}"
        f"  branches={covered_branches}/{total_branches}"
    )

    # Per-file breakdown
    files = data.get("files", {})
    rows: list[tuple[str, float, int, int]] = []
    for filepath, info in files.items():
        summary = info.get("summary", {})
        file_pct = round(summary.get("percent_covered", 0.0), 2)
        file_stmts = summary.get("num_statements", 0)
        file_covered = summary.get("covered_lines", 0)
        rows.append((filepath, file_pct, file_covered, file_stmts))

    # Sort by coverage % ascending (worst first)
    rows.sort(key=lambda x: x[1])

    low = [f"{pathlib.Path(r[0]).name}={r[1]}%" for r in rows if r[1] < threshold]
    if low:
        print(f"COVERAGE_LOW: {' '.join(low[:10])}")
    else:
        print(f"COVERAGE_LOW: none (all modules >= {threshold}%)")

    # Per-module table (plain text, worst 20)
    print("")
    print(f"{'Module':<55} {'Stmts':>6} {'Covered':>8} {'Coverage':>10}")
    print("-" * 82)
    for filepath, file_pct, covered, stmts in rows[:20]:
        name = pathlib.Path(filepath).name
        bar = "#" * int(file_pct / 5) + "." * (20 - int(file_pct / 5))
        print(f"{name:<55} {stmts:>6} {covered:>8} {file_pct:>8.1f}%  [{bar}]")


if __name__ == "__main__":
    args = sys.argv[1:]
    cov_json_path = args[0] if len(args) > 0 else "backend/reports/coverage.json"
    threshold_val = float(args[1]) if len(args) > 1 else 50.0
    try:
        main(cov_json_path, threshold_val)
    except FileNotFoundError:
        print(f"COVERAGE_TOTAL: pct=? lines=?/?  branches=?/?  (file not found: {cov_json_path})")
        print("COVERAGE_LOW: unknown")
    except Exception as exc:
        print(f"COVERAGE_TOTAL: pct=? lines=?/?  branches=?/?  (parse error: {exc})")
        print("COVERAGE_LOW: unknown")
