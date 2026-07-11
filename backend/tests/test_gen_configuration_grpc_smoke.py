from __future__ import annotations

import asyncio

import pytest

pytest.importorskip("grpclib")
import grpclib.client
import grpclib.const
import google.protobuf.empty_pb2
from gen.configuration_grpc import ConfigServiceBase, ConfigServiceStub
from gen import configuration_pb2


def test_configuration_grpc_mapping_contract():

    class _Svc(ConfigServiceBase):
        async def SetConfig(self, stream):
            raise NotImplementedError

        async def GetConfig(self, stream):
            raise NotImplementedError

        async def ListModules(self, stream):
            raise NotImplementedError

        async def SetExportTemplates(self, stream):
            raise NotImplementedError

        async def GetExportTemplates(self, stream):
            raise NotImplementedError

        async def ListExportTemplateFiles(self, stream):
            raise NotImplementedError

    mapping = _Svc().__mapping__()

    assert set(mapping.keys()) == {
        "/config.ConfigService/SetConfig",
        "/config.ConfigService/GetConfig",
        "/config.ConfigService/ListModules",
        "/config.ConfigService/SetExportTemplates",
        "/config.ConfigService/GetExportTemplates",
        "/config.ConfigService/ListExportTemplateFiles",
    }

    set_h = mapping["/config.ConfigService/SetConfig"]
    assert set_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert set_h.request_type is configuration_pb2.SetConfigRequest
    assert set_h.reply_type is configuration_pb2.SetConfigResponse

    get_h = mapping["/config.ConfigService/GetConfig"]
    assert get_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert get_h.request_type is configuration_pb2.GetConfigRequest
    assert get_h.reply_type is configuration_pb2.GetConfigResponse

    list_h = mapping["/config.ConfigService/ListModules"]
    assert list_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert list_h.request_type is google.protobuf.empty_pb2.Empty
    assert list_h.reply_type is configuration_pb2.ListModulesResponse

    set_export_h = mapping["/config.ConfigService/SetExportTemplates"]
    assert set_export_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert set_export_h.request_type is configuration_pb2.SetExportTemplatesRequest
    assert set_export_h.reply_type is configuration_pb2.SetExportTemplatesResponse

    get_export_h = mapping["/config.ConfigService/GetExportTemplates"]
    assert get_export_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert get_export_h.request_type is configuration_pb2.GetExportTemplatesRequest
    assert get_export_h.reply_type is configuration_pb2.GetExportTemplatesResponse

    list_export_h = mapping["/config.ConfigService/ListExportTemplateFiles"]
    assert list_export_h.cardinality == grpclib.const.Cardinality.UNARY_UNARY
    assert list_export_h.request_type is google.protobuf.empty_pb2.Empty
    assert list_export_h.reply_type is configuration_pb2.ListExportTemplateFilesResponse


def test_configuration_grpc_stub_has_methods():

    loop = asyncio.new_event_loop()
    channel = grpclib.client.Channel(host="127.0.0.1", port=1, loop=loop)
    try:
        stub = ConfigServiceStub(channel)
        for name in [
            "SetConfig",
            "GetConfig",
            "ListModules",
            "SetExportTemplates",
            "GetExportTemplates",
            "ListExportTemplateFiles",
        ]:
            assert hasattr(stub, name)
            assert isinstance(getattr(stub, name), grpclib.client.UnaryUnaryMethod)
    finally:
        channel.close()
        loop.close()
