"""
tools/ci/radon_metrics.py
Parse radon JSON outputs (CC + MI) and print KPI lines for CI consumption.

Usage:
    python tools/ci/radon_metrics.py [cc_json] [mi_json]

Defaults:
    cc_json : backend/reports/radon_cc.json
    mi_json : backend/reports/radon_mi.json

Output (stdout, one line each, consumed by the CI KPI block):
    CC_STATS: total=N avg=X.XX complex_gt10=M ranks=[A:n B:n ...]
    MI_STATS: total=N avg=X.XX low_mi_files=K
"""

import json
import sys
import pathlib
import statistics

cc_path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "backend/reports/radon_cc.json")
mi_path = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else "backend/reports/radon_mi.json")


def safe_load(p: pathlib.Path):
    try:
        return json.loads(p.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return {}


cc_data = safe_load(cc_path)
mi_data = safe_load(mi_path)

# ── Cyclomatic Complexity ──────────────────────────────────────────────────
all_blocks = [b for f in cc_data.values() for b in (f if isinstance(f, list) else [])]
all_cc = [b["complexity"] for b in all_blocks if "complexity" in b]
complex_gt10 = len([c for c in all_cc if c > 10])
avg_cc = round(statistics.mean(all_cc), 2) if all_cc else 0.0

rank_counts: dict[str, int] = {}
for b in all_blocks:
    r = b.get("rank", "?")
    rank_counts[r] = rank_counts.get(r, 0) + 1
ranks_str = "  ".join(f"{k}:{v}" for k, v in sorted(rank_counts.items()))

print(f"CC_STATS: total={len(all_cc)} avg={avg_cc} complex_gt10={complex_gt10} ranks=[{ranks_str}]")

# ── Maintainability Index ──────────────────────────────────────────────────
all_mi = [v.get("mi", 0) for v in mi_data.values() if isinstance(v, dict) and "mi" in v]
avg_mi = round(statistics.mean(all_mi), 2) if all_mi else 0.0
low_mi_files = len([v for v in mi_data.values() if isinstance(v, dict) and v.get("mi", 100) < 20])

print(f"MI_STATS: total={len(all_mi)} avg={avg_mi} low_mi_files={low_mi_files}")
