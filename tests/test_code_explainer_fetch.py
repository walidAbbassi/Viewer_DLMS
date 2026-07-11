"""Tests for paginated / prioritised / capped diff fetching in code_explainer."""
from __future__ import annotations

from typing import Any

import agents.code_explainer as ce


class _FakeResp:
    def __init__(self, status: int, payload: Any) -> None:
        self.status_code = status
        self._payload = payload

    def json(self) -> Any:
        return self._payload


def _make_diff(path: str, body_size: int = 100) -> dict:
    return {"new_path": path, "diff": "x" * body_size}


def _install_paginated_get(monkeypatch, pages: list[list[dict]]):
    """Patch httpx.get so successive calls return successive pages."""
    state = {"calls": []}

    def fake_get(url, *, headers=None, verify=True, timeout=30, params=None):
        state["calls"].append(dict(params or {}))
        page_idx = (params or {}).get("page", 1) - 1
        if page_idx < len(pages):
            return _FakeResp(200, pages[page_idx])
        return _FakeResp(200, [])

    monkeypatch.setattr(ce.httpx, "get", fake_get)
    return state


# ── Pagination ─────────────────────────────────────────────────────────────────

def test_pagination_walks_until_empty(monkeypatch):
    page1 = [_make_diff(f"backend/f{i}.py") for i in range(ce.PER_PAGE)]
    page2 = [_make_diff(f"backend/g{i}.py") for i in range(50)]
    state = _install_paginated_get(monkeypatch, [page1, page2])
    _, total = ce._fetch_mr_diff("2202", "51")
    assert total == ce.PER_PAGE + 50  # 150 files
    # At least two requests issued (pages 1 and 2)
    assert any(call.get("page") == 1 for call in state["calls"])
    assert any(call.get("page") == 2 for call in state["calls"])


def test_pagination_stops_when_batch_smaller_than_page_size(monkeypatch):
    only_page = [_make_diff(f"backend/f{i}.py") for i in range(10)]
    state = _install_paginated_get(monkeypatch, [only_page])
    _, total = ce._fetch_mr_diff("2202", "51")
    assert total == 10
    # Only the first page was needed (no page=2 fetch)
    pages_requested = [c.get("page") for c in state["calls"]]
    assert pages_requested == [1]


# ── Per-file truncation ────────────────────────────────────────────────────────

def test_per_file_diff_truncated_at_cap(monkeypatch):
    big_body = "X" * (ce.PER_FILE_CAP * 3)
    _install_paginated_get(monkeypatch, [[{"new_path": "backend/a.py", "diff": big_body}]])
    diff_text, _ = ce._fetch_mr_diff("2202", "51")
    # The diff body in the rendered prompt is at most PER_FILE_CAP X's
    assert "X" * ce.PER_FILE_CAP in diff_text
    assert "X" * (ce.PER_FILE_CAP + 1) not in diff_text


def test_short_file_diff_kept_whole(monkeypatch):
    _install_paginated_get(monkeypatch, [[{"new_path": "backend/a.py", "diff": "small"}]])
    diff_text, _ = ce._fetch_mr_diff("2202", "51")
    assert "small" in diff_text


# ── Total cap + skipped trailer ────────────────────────────────────────────────

def test_total_cap_triggers_skipped_trailer(monkeypatch):
    # Each file ~ PER_FILE_CAP + framing ≈ 3050 chars. 25 files ≈ 76 KB → cap at 60 KB.
    huge_files = [_make_diff(f"backend/f{i}.py", ce.PER_FILE_CAP) for i in range(25)]
    _install_paginated_get(monkeypatch, [huge_files])
    diff_text, total = ce._fetch_mr_diff("2202", "51")
    assert total == 25
    assert "more file(s) truncated" in diff_text
    # Body should not exceed cap + the trailer line (~80 chars)
    assert len(diff_text) <= ce.TOTAL_CAP + 200


def test_no_trailer_when_all_fit(monkeypatch):
    small_files = [_make_diff(f"backend/f{i}.py", 200) for i in range(5)]
    _install_paginated_get(monkeypatch, [small_files])
    diff_text, _ = ce._fetch_mr_diff("2202", "51")
    assert "more file(s) truncated" not in diff_text


# ── Generated-file priority ───────────────────────────────────────────────────

def test_human_files_come_before_generated(monkeypatch):
    payload = [
        _make_diff("gen/foo_pb2.py", 200),
        _make_diff("backend/server.py", 200),
        _make_diff("ng_sdk_whl/extracted/x.py", 200),
        _make_diff("tools/notify.py", 200),
    ]
    _install_paginated_get(monkeypatch, [payload])
    diff_text, _ = ce._fetch_mr_diff("2202", "51")
    idx_server = diff_text.find("### backend/server.py")
    idx_notify = diff_text.find("### tools/notify.py")
    idx_gen = diff_text.find("### gen/foo_pb2.py")
    idx_extracted = diff_text.find("### ng_sdk_whl/extracted/x.py")
    assert idx_server >= 0 and idx_notify >= 0
    assert idx_gen >= 0 and idx_extracted >= 0
    assert idx_server < idx_gen and idx_server < idx_extracted
    assert idx_notify < idx_gen and idx_notify < idx_extracted


def test_is_generated_helper():
    assert ce._is_generated("gen/foo.py") is True
    assert ce._is_generated("backend/gen/foo_pb2.py") is True
    assert ce._is_generated("backend/server_pb2.py") is True
    assert ce._is_generated("flutter_app/lib/grpc/generated/foo.dart") is True
    assert ce._is_generated("ng_sdk_whl/extracted/x.py") is True
    assert ce._is_generated("backend/server.py") is False
    assert ce._is_generated("tools/notify.py") is False


# ── Failure modes ─────────────────────────────────────────────────────────────

def test_empty_diff_returns_zero(monkeypatch):
    _install_paginated_get(monkeypatch, [[]])
    diff_text, total = ce._fetch_mr_diff("2202", "51")
    assert diff_text == ""
    assert total == 0


def test_non_200_status_returns_zero(monkeypatch):
    def fake_get(*args, **kwargs):
        return _FakeResp(403, None)
    monkeypatch.setattr(ce.httpx, "get", fake_get)
    diff_text, total = ce._fetch_mr_diff("2202", "51")
    assert diff_text == ""
    assert total == 0
