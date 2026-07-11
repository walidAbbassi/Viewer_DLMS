from __future__ import annotations

import pytest

pytest.importorskip("google.protobuf")
from gen import configuration_pb2 as pb2


def test_configuration_pb2_import_and_descriptor():
    assert pb2.DESCRIPTOR.name == "configuration.proto"
    assert pb2.DESCRIPTOR.package == "config"


def test_configuration_pb2_messages_exist_and_fields():
    # Message symbols exist
    for name in [
        "ConfigEntry",
        "SetConfigRequest",
        "SetConfigResponse",
        "ConfigIdentifier",
        "GetConfigRequest",
        "GetConfigResponse",
        "ListModulesResponse",
    ]:
        assert hasattr(pb2, name), f"Missing message: {name}"

    # Field sanity
    entry_desc = pb2.ConfigEntry.DESCRIPTOR
    assert (
        entry_desc.fields_by_name["module"].type
        == entry_desc.fields_by_name["module"].TYPE_STRING
    )
    assert (
        entry_desc.fields_by_name["key"].type
        == entry_desc.fields_by_name["key"].TYPE_STRING
    )
    assert (
        entry_desc.fields_by_name["value"].message_type.full_name
        == "google.protobuf.Any"
    )

    set_req_desc = pb2.SetConfigRequest.DESCRIPTOR
    assert (
        set_req_desc.fields_by_name["entries"].label
        == set_req_desc.fields_by_name["entries"].LABEL_REPEATED
    )
    assert (
        set_req_desc.fields_by_name["entries"].message_type.full_name
        == "config.ConfigEntry"
    )
    assert (
        set_req_desc.fields_by_name["to_file"].type
        == set_req_desc.fields_by_name["to_file"].TYPE_BOOL
    )


def test_configuration_pb2_service_descriptor_methods():
    svc = pb2.DESCRIPTOR.services_by_name.get("ConfigService")
    assert svc is not None

    methods = {m.name: m for m in svc.methods}
    assert {"SetConfig", "GetConfig", "ListModules"}.issubset(set(methods.keys()))

    assert methods["SetConfig"].input_type.full_name == "config.SetConfigRequest"
    assert methods["SetConfig"].output_type.full_name == "config.SetConfigResponse"

    assert methods["GetConfig"].input_type.full_name == "config.GetConfigRequest"
    assert methods["GetConfig"].output_type.full_name == "config.GetConfigResponse"

    assert methods["ListModules"].input_type.full_name == "google.protobuf.Empty"
    assert methods["ListModules"].output_type.full_name == "config.ListModulesResponse"
