from __future__ import annotations

from pathlib import Path
import sys

import pytest


def _ensure_gen_on_syspath() -> None:
    backend_dir = Path(__file__).resolve().parents[1]
    gen_dir = backend_dir / "gen"
    sys.path.insert(0, str(gen_dir))


pytest.importorskip("google.protobuf")
pytest.importorskip("grpc")
_ensure_gen_on_syspath()
import meter_pb2_grpc as pb2_grpc  # type: ignore
import meter_pb2 as pb2  # type: ignore
from google.protobuf import empty_pb2


class _FakeChannel:
    def __init__(self):
        self.calls: list[tuple[str, str]] = []

    def unary_unary(self, path, **_kwargs):
        self.calls.append(("unary_unary", path))
        return ("unary_unary", path)

    def unary_stream(self, path, **_kwargs):
        self.calls.append(("unary_stream", path))
        return ("unary_stream", path)


class _FakeServer:
    def __init__(self):
        self.generic_handlers = []
        self.registered = []

    def add_generic_rpc_handlers(self, handlers):
        self.generic_handlers.extend(list(handlers))

    def add_registered_method_handlers(self, service_name, method_handlers):
        self.registered.append((service_name, method_handlers))


def test_meter_pb2_grpc_stub_initializes_all_methods():

    channel = _FakeChannel()
    stub = pb2_grpc.MeterServiceStub(channel)

    expected = [
        ("InitMeterContext", "unary_unary"),
        ("Connect", "unary_unary"),
        ("Disconnect", "unary_unary"),
        ("ExecuteAdvancedGet", "unary_unary"),
        ("ExecuteAdvancedSet", "unary_unary"),
        ("ExecuteAdvancedAction", "unary_unary"),
        ("ExecuteGet", "unary_unary"),
        ("ExecuteSet", "unary_unary"),
        ("ExecuteAction", "unary_unary"),
        ("GetBlockSize", "unary_unary"),
        ("SetBlockSize", "unary_unary"),
        ("EnableImageTransfer", "unary_unary"),
        ("InitiateTransfer", "unary_unary"),
        ("TransferFile", "unary_stream"),
        ("VerifyTransfert", "unary_unary"),
        ("ResendMissingChunks", "unary_stream"),
        ("ActivateFirmware", "unary_unary"),
        ("GetDatamodelObjects", "unary_unary"),
        ("GetDatamodelAttributesByObjectName", "unary_unary"),
        ("TranslateData", "unary_unary"),
        ("GetClock", "unary_unary"),
        ("SetClock", "unary_unary"),
        ("GetDatamodels", "unary_unary"),
        ("LoadDatamodel", "unary_unary"),
        ("GetLoadProfile", "unary_stream"),
        ("GetLoadProfileParam", "unary_unary"),
        ("SetLoadProfileParam", "unary_unary"),
        ("GetFresnelData", "unary_unary"),
        ("GetDeviceID", "unary_unary"),
        ("GetFirmwareVersion", "unary_unary"),
        ("GetImageTransfertActivationDateTime", "unary_unary"),
        ("SetImageTransfertActivationDateTime", "unary_unary"),
        ("GetIncrementalDate", "unary_unary"),
        ("SetIncrementalDate", "unary_unary"),
        ("GetDecrementalDate", "unary_unary"),
        ("SetDecrementalDate", "unary_unary"),
        ("GetDaylightSavingDeviation", "unary_unary"),
        ("SetDaylightSavingDeviation", "unary_unary"),
        ("GetDaylightSavingActivation", "unary_unary"),
        ("SetDaylightSavingActivation", "unary_unary"),
        ("GetTimezone", "unary_unary"),
        ("SetTimezone", "unary_unary"),
        ("GetEnergyRegister", "unary_unary"),
    ]

    for method_name, kind in expected:
        assert hasattr(stub, method_name)
        assert getattr(stub, method_name)[0] == kind

    # Ensure the constructor called through the channel for at least the expected baseline.
    # New proto methods can increase this count over time.
    assert len(channel.calls) >= len(expected)


def test_meter_pb2_grpc_add_servicer_registers_handlers():

    # Use the generated base class with UNIMPLEMENTED methods.
    servicer = pb2_grpc.MeterServiceServicer()
    server = _FakeServer()

    pb2_grpc.add_MeterServiceServicer_to_server(servicer, server)

    assert server.generic_handlers, "Expected at least one generic handler"
    assert server.registered, "Expected registered method handlers"

    service_name, handlers = server.registered[0]
    assert service_name == "meter.MeterService"

    # A few spot checks to ensure expected method keys exist
    for name in ["InitMeterContext", "TransferFile", "GetEnergyRegister"]:
        assert name in handlers


def test_meter_pb2_grpc_experimental_api_calls_into_grpc_experimental(monkeypatch):
    grpc = pytest.importorskip("grpc")
    if not hasattr(grpc, "experimental"):
        pytest.skip("grpc.experimental API not available in this grpcio version")
    if not hasattr(grpc.experimental, "unary_unary") or not hasattr(
        grpc.experimental, "unary_stream"
    ):
        pytest.skip("grpc.experimental unary_unary/unary_stream not available")
    _ensure_gen_on_syspath()
    calls = []

    def _fake_unary_unary(request, target, path, *_args, **_kwargs):
        calls.append(("unary_unary", path))
        return ("unary_unary", path)

    def _fake_unary_stream(request, target, path, *_args, **_kwargs):
        calls.append(("unary_stream", path))
        return ("unary_stream", path)

    monkeypatch.setattr(grpc.experimental, "unary_unary", _fake_unary_unary)
    monkeypatch.setattr(grpc.experimental, "unary_stream", _fake_unary_stream)

    # Drive as many static methods as possible (best-effort coverage of generated lines)
    meter = pb2_grpc.MeterService

    unary_unary_requests = {
        "InitMeterContext": pb2.InitMeterContextRequest(modulename="M"),
        "Connect": empty_pb2.Empty(),
        "Disconnect": empty_pb2.Empty(),
        "ExecuteAdvancedGet": pb2.GetRequestList(with_list=False),
        "ExecuteAdvancedSet": pb2.SetRequestList(with_list=False),
        "ExecuteAdvancedAction": pb2.ActionRequestList(with_list=False),
        "ExecuteGet": pb2.GetRequestList(with_list=False),
        "ExecuteSet": pb2.SetRequestList(with_list=False),
        "ExecuteAction": pb2.ActionRequestList(with_list=False),
        "GetBlockSize": empty_pb2.Empty(),
        "SetBlockSize": pb2.Int32Value(value=1),
        "EnableImageTransfer": empty_pb2.Empty(),
        "InitiateTransfer": pb2.InitiateTransferRequest(path_file="p", imageId="i"),
        "VerifyTransfert": pb2.VerifyTransfertRequest(path_file="p", block_size=1),
        "ActivateFirmware": empty_pb2.Empty(),
        "GetDatamodelObjects": pb2.GetDatamodelObjectsRequest(withAttributes=False),
        "GetDatamodelAttributesByObjectName": pb2.GetDatamodelAttributesByObjectNameRequest(
            objectName="o", clientName="c"
        ),
        "TranslateData": pb2.TranslateDataRequest(requests=[]),
        "GetClock": empty_pb2.Empty(),
        "SetClock": pb2.StringValue(value="t"),
        "GetDatamodels": empty_pb2.Empty(),
        "LoadDatamodel": pb2.LoadDatamodelRequest(datamodel="d"),
        "GetLoadProfileParam": pb2.GetLoadProfileParamRequest(
            objectName="o", param=pb2.LoadProfileParam.MAX_RECORD
        ),
        "SetLoadProfileParam": pb2.SetLoadProfileParamRequest(
            objectName="o", param=pb2.LoadProfileParam.MAX_RECORD, value=1
        ),
        "GetFresnelData": empty_pb2.Empty(),
        "GetDeviceID": empty_pb2.Empty(),
        "GetFirmwareVersion": empty_pb2.Empty(),
        "GetImageTransfertActivationDateTime": empty_pb2.Empty(),
        "SetImageTransfertActivationDateTime": pb2.ActivationDateTime(
            year=2024, month=1, day=1, hour=0, minute=0, second=0
        ),
        "GetIncrementalDate": empty_pb2.Empty(),
        "SetIncrementalDate": pb2.DaylightSavingsTime(
            day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
        ),
        "GetDecrementalDate": empty_pb2.Empty(),
        "SetDecrementalDate": pb2.DaylightSavingsTime(
            day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
        ),
        "GetDaylightSavingDeviation": empty_pb2.Empty(),
        "SetDaylightSavingDeviation": pb2.Int32Value(value=1),
        "GetDaylightSavingActivation": empty_pb2.Empty(),
        "SetDaylightSavingActivation": pb2.BoolValue(value=True),
        "GetTimezone": empty_pb2.Empty(),
        "SetTimezone": pb2.Int32Value(value=0),
        "GetEnergyRegister": empty_pb2.Empty(),
    }

    unary_stream_requests = {
        "TransferFile": pb2.TransferFileRequest(path_file="p", block_size=1),
        "ResendMissingChunks": pb2.ResendMissingChunksRequest(
            path_file="p", block_size=1
        ),
        "GetLoadProfile": pb2.GetLoadProfileRequest(objectName="o"),
    }

    for name, req in unary_unary_requests.items():
        fn = getattr(meter, name)
        res = fn(req, target="127.0.0.1:1", insecure=True)
        assert res[0] == "unary_unary"

    for name, req in unary_stream_requests.items():
        fn = getattr(meter, name)
        res = fn(req, target="127.0.0.1:1", insecure=True)
        assert res[0] == "unary_stream"

    # Basic sanity: we should have recorded a lot of calls.
    assert len(calls) >= (len(unary_unary_requests) + len(unary_stream_requests))
