#!/usr/bin/env python3
"""
Parse Flutter test JSON reporter (--reporter json) output -> JUnit XML.
Also parses lcov.info for line-coverage statistics.

Usage:
  flutter_test_to_junit.py <jsonl_input> <junit_output> [lcov_info]

Stdout:
  TEST_STATS: total=N passed=P failed=F error=E skipped=S duration=Xs
  LCOV_STATS: lines_found=N lines_hit=M coverage=X.XX%   (if lcov provided)
"""
import json
import sys
import pathlib
import xml.etree.ElementTree as ET


# ---------------------------------------------------------------------------
# Parse Dart/Flutter test protocol (JSONL)
# ---------------------------------------------------------------------------

def parse_flutter_jsonl(path: str) -> dict:
    """Parse Flutter --reporter json JSONL output into a structured dict."""
    tests: dict[int, dict] = {}
    suites: dict[int, str] = {}      # suite_id -> file path
    errors: dict[int, list] = {}     # test_id -> list of {error, trace}
    start_time: int | None = None
    end_time: int | None = None

    try:
        content = pathlib.Path(path).read_text(encoding="utf-8", errors="replace")
    except Exception:
        return {"tests": {}, "suites": {}, "errors": {}, "total_duration": 0.0}

    for raw in content.splitlines():
        raw = raw.strip()
        if not raw or not raw.startswith("{"):
            continue
        try:
            ev = json.loads(raw)
        except json.JSONDecodeError:
            continue

        etype = ev.get("type", "")
        t = ev.get("time", 0)

        if etype == "start":
            start_time = t

        elif etype == "suite":
            s = ev.get("suite", {})
            sid = s.get("id")
            if sid is not None:
                suites[sid] = s.get("path", "")

        elif etype == "testStart":
            test = ev.get("test", {})
            tid = test.get("id")
            if tid is not None:
                tests[tid] = {
                    "name": test.get("name", f"test_{tid}"),
                    "suite_id": test.get("suiteID"),
                    "url": test.get("url", ""),
                    "line": test.get("line"),
                    "start_ms": t,
                    "end_ms": t,
                    "result": "success",
                    "skipped": test.get("metadata", {}).get("skip", False),
                    "hidden": False,
                }

        elif etype == "testDone":
            tid = ev.get("testID")
            if tid in tests:
                tests[tid]["end_ms"] = t
                tests[tid]["result"] = ev.get("result", "success")
                if ev.get("skipped", False):
                    tests[tid]["skipped"] = True
                if ev.get("hidden", False):
                    tests[tid]["hidden"] = True

        elif etype == "error":
            tid = ev.get("testID")
            if tid is not None:
                errors.setdefault(tid, []).append(
                    {
                        "error": ev.get("error", ""),
                        "trace": ev.get("stackTrace", ev.get("trace", "")),
                    }
                )

        elif etype == "done":
            end_time = t

    total_ms = (end_time or 0) - (start_time or 0)
    return {
        "tests": tests,
        "suites": suites,
        "errors": errors,
        "total_duration": max(0.0, total_ms / 1000.0),
    }


# ---------------------------------------------------------------------------
# Build JUnit XML
# ---------------------------------------------------------------------------

def build_junit(data: dict, output_path: str) -> dict:
    """Convert parsed test data to JUnit XML and return count stats."""
    tests = data["tests"]
    suites = data["suites"]
    errors = data["errors"]
    total_duration = data["total_duration"]

    # Filter hidden tests (group-level / loading entries)
    visible = {tid: t for tid, t in tests.items() if not t["hidden"]}

    total = len(visible)
    n_failed = sum(
        1 for t in visible.values() if t["result"] == "failure" and not t["skipped"]
    )
    n_error = sum(
        1 for t in visible.values() if t["result"] == "error" and not t["skipped"]
    )
    n_skipped = sum(1 for t in visible.values() if t["skipped"])
    n_passed = total - n_failed - n_error - n_skipped

    root = ET.Element(
        "testsuites",
        {
            "tests": str(total),
            "failures": str(n_failed),
            "errors": str(n_error),
            "skipped": str(n_skipped),
            "time": f"{total_duration:.3f}",
        },
    )
    suite_el = ET.SubElement(
        root,
        "testsuite",
        {
            "name": "Flutter Tests",
            "tests": str(total),
            "failures": str(n_failed),
            "errors": str(n_error),
            "skipped": str(n_skipped),
            "time": f"{total_duration:.3f}",
        },
    )

    for tid, t in sorted(visible.items()):
        dur = max(0.0, (t["end_ms"] - t["start_ms"]) / 1000.0)
        suite_path = suites.get(t["suite_id"], "")
        classname = pathlib.Path(suite_path).stem if suite_path else "flutter"
        tc = ET.SubElement(
            suite_el,
            "testcase",
            {"name": t["name"], "classname": classname, "time": f"{dur:.3f}"},
        )
        if t["skipped"]:
            ET.SubElement(tc, "skipped")
        elif t["result"] == "failure":
            errs = errors.get(tid, [{}])
            msg = (errs[0].get("error") or "Test failed")[:500]
            trace = "\n".join(e.get("trace", "") for e in errs)
            fail_el = ET.SubElement(tc, "failure", {"message": msg})
            fail_el.text = trace
        elif t["result"] == "error":
            errs = errors.get(tid, [{}])
            msg = (errs[0].get("error") or "Test error")[:500]
            trace = "\n".join(e.get("trace", "") for e in errs)
            err_el = ET.SubElement(tc, "error", {"message": msg})
            err_el.text = trace

    tree = ET.ElementTree(root)
    try:
        ET.indent(tree, space="  ")
    except AttributeError:
        pass
    tree.write(output_path, encoding="utf-8", xml_declaration=True)

    return {
        "total": total,
        "passed": n_passed,
        "failed": n_failed,
        "error": n_error,
        "skipped": n_skipped,
        "duration": total_duration,
    }


# ---------------------------------------------------------------------------
# Parse lcov.info
# ---------------------------------------------------------------------------

def parse_lcov(path: str) -> dict | None:
    """Return line-coverage stats from lcov.info, or None on failure."""
    try:
        lines = pathlib.Path(path).read_text(
            encoding="utf-8", errors="replace"
        ).splitlines()
    except Exception:
        return None

    lf_total = 0
    lh_total = 0
    for line in lines:
        if line.startswith("LF:"):
            try:
                lf_total += int(line[3:].strip())
            except ValueError:
                pass
        elif line.startswith("LH:"):
            try:
                lh_total += int(line[3:].strip())
            except ValueError:
                pass

    if lf_total == 0:
        return None
    return {
        "lines_found": lf_total,
        "lines_hit": lh_total,
        "coverage": round(lh_total / lf_total * 100, 2),
    }


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    args = sys.argv[1:]
    jsonl_input = args[0] if len(args) > 0 else "flutter_test_machine.jsonl"
    junit_output = args[1] if len(args) > 1 else "flutter_test_junit.xml"
    lcov_path = args[2] if len(args) > 2 else None

    data = parse_flutter_jsonl(jsonl_input)
    stats = build_junit(data, junit_output)

    print(
        f"TEST_STATS: total={stats['total']} passed={stats['passed']} "
        f"failed={stats['failed']} error={stats['error']} "
        f"skipped={stats['skipped']} duration={stats['duration']:.2f}s"
    )

    if lcov_path:
        lcov = parse_lcov(lcov_path)
        if lcov:
            print(
                f"LCOV_STATS: lines_found={lcov['lines_found']} "
                f"lines_hit={lcov['lines_hit']} coverage={lcov['coverage']}%"
            )
        else:
            print("LCOV_STATS: N/A (lcov.info not found or empty)")


if __name__ == "__main__":
    main()
