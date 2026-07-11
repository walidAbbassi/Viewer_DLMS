from __future__ import annotations

from types import SimpleNamespace

import pytest

pytest.importorskip("grpclib")

ng_sdk = pytest.importorskip("ng_sdk")

import google.protobuf.empty_pb2

from gen.meter_grpc import MeterServiceStub
from gen import meter_pb2
from service.meter_service import MeterService
import service.meter_service as meter_mod
import service.handlers.connection_handler as _conn_handler
import meter_context
from tests.conftest import open_channel, serve


@pytest.mark.asyncio
async def test_meter_connect_disconnect_in_simulation_mode(monkeypatch):



    sim = SimpleNamespace(enabled=True, path="")
    public = SimpleNamespace(simulation=sim)
    assoc = SimpleNamespace(Public=public)
    fake_config = SimpleNamespace(association=assoc)

    # Patch MeterContext via the source module (meter_context).
    # service.meter_service does NOT import MeterContext directly;
    # all handlers reference meter_context.MeterContext, so one patch suffices.
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)
    # SimulationDLMSExecutor is imported in connection_handler, not meter_service.
    monkeypatch.setattr(
        _conn_handler, "SimulationDLMSExecutor", lambda _path: SimpleNamespace(rows=[])
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)

            init = await stub.InitMeterContext(
                meter_pb2.InitMeterContextRequest(modulename="Any")
            )
            assert init.value is True

            ok = await stub.Connect(google.protobuf.empty_pb2.Empty())
            assert ok.value is True

            ok2 = await stub.Disconnect(google.protobuf.empty_pb2.Empty())
            assert ok2.value is True

