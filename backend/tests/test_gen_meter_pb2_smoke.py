from __future__ import annotations

from pathlib import Path
import os
import subprocess
import sys

import pytest


def _ensure_gen_on_syspath() -> None:
    """Ensure backend/gen is on sys.path so grpcio-tools style imports work.

    meter_pb2_grpc.py uses `import meter_pb2` (not `from gen import meter_pb2`).
    Adding backend/gen to sys.path makes `meter_pb2.py` importable as a top-level module.
    """

    backend_dir = Path(__file__).resolve().parents[1]
    gen_dir = backend_dir / "gen"
    sys.path.insert(0, str(gen_dir))


pytest.importorskip("google.protobuf")
_ensure_gen_on_syspath()
import meter_pb2 as pb2  # type: ignore


def test_meter_pb2_import_and_descriptor():
    assert pb2.DESCRIPTOR.name == "meter.proto"
    assert pb2.DESCRIPTOR.package == "meter"


def test_meter_pb2_messages_and_oneofs_exist():

    # A sampling of message symbols that should exist
    for name in [
        "TranslateDataItemRequest",
        "TranslateDataRequest",
        "TranslateDataItemResponse",
        "TranslateDataResponse",
        "GetRequest",
        "DateTimeRangeSelector",
        "EntrySelector",
        "SetRequest",
        "ActionRequest",
        "AbstractFrameRequest",
        "ApplicationResponse",
        "FrameExecutionItem",
        "FrameExecutionList",
        "BoolValue",
        "Int32Value",
        "StringValue",
        "StringList",
        "GetRequestList",
        "SetRequestList",
        "ActionRequestList",
        "ApplicationResponseList",
        "InitMeterContextRequest",
        "TransferUpdate",
        "GetLoadProfileRequest",
        "GetLoadProfileStreamItem",
    ]:
        assert hasattr(pb2, name), f"Missing message: {name}"

    # Oneof presence sanity
    get_req = pb2.GetRequest()
    assert "access_selector" in {o.name for o in get_req.DESCRIPTOR.oneofs}

    afr = pb2.AbstractFrameRequest()
    assert "request" in {o.name for o in afr.DESCRIPTOR.oneofs}


def test_meter_pb2_basic_roundtrip_and_enum_values():

    req = pb2.TranslateDataItemRequest(data="abc", is_xdr_input=True)
    blob = req.SerializeToString()
    req2 = pb2.TranslateDataItemRequest.FromString(blob)
    assert req2.data == "abc"
    assert req2.is_xdr_input is True

    # Enum existence and numeric values
    assert pb2.LoadProfileParam.LOAD_PROFILE_PARAM_UNSPECIFIED == 0
    assert pb2.LoadProfileParam.MAX_RECORD == 1


def test_meter_pb2_executes_python_descriptor_branch(monkeypatch: pytest.MonkeyPatch):
    """Force execution of the `if not _descriptor._USE_C_DESCRIPTORS:` block.

    The generated module contains a large block of assignments guarded by
    `_descriptor._USE_C_DESCRIPTORS`. When C descriptors are enabled (common),
    that code is skipped and coverage appears very low.
    """

    pytest.importorskip("google.protobuf")

    # Force pure-Python protobuf in a subprocess. With upb descriptors, the
    # generated code's `DESCRIPTOR._loaded_options = None` assignment can raise
    # because the underlying object does not allow setting arbitrary attrs.
    backend_dir = Path(__file__).resolve().parents[1]
    gen_dir = backend_dir / "gen"

    env = os.environ.copy()
    env["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python"

    # Do NOT override PYTHONPATH here. pytest-cov uses it to inject a
    # sitecustomize for subprocess coverage tracking.
    code = (
        "import sys\n"
        # Make coverage collection for this subprocess robust:
        # - coverage.process_startup() uses COVERAGE_PROCESS_START (coverage.py standard)
        # - pytest_cov.embed.init() uses COV_CORE_* (pytest-cov)
        "try:\n"
        "    import coverage\n"
        "    coverage.process_startup()\n"
        "except Exception:\n"
        "    pass\n"
        "try:\n"
        "    import pytest_cov.embed\n"
        "    pytest_cov.embed.init()\n"
        "except Exception:\n"
        "    pass\n"
        f"sys.path.insert(0, r'{backend_dir}')\n"
        "from google.protobuf import descriptor as _descriptor\n"
        "_descriptor._USE_C_DESCRIPTORS = False\n"
        "from gen import meter_pb2 as pb2\n"
        "assert pb2.DESCRIPTOR.name == 'meter.proto'\n"
        "assert pb2.DESCRIPTOR.package == 'meter'\n"
        "assert hasattr(pb2, '_GETREQUEST')\n"
        "assert hasattr(pb2._GETREQUEST, '_serialized_start')\n"
        "assert hasattr(pb2, '_METERSERVICE')\n"
        "assert pb2._METERSERVICE._serialized_start > 0\n"
    )

    subprocess.run(
        [sys.executable, "-c", code], env=env, cwd=str(backend_dir), check=True
    )
