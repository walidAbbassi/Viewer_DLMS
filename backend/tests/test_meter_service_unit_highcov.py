from __future__ import annotations

import asyncio
import grpclib
import importlib
import logging
import math
import sys
import types
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path

try:
    from h2.exceptions import StreamClosedError
except ImportError:
    StreamClosedError = Exception  # type: ignore

import pytest


@pytest.fixture(autouse=True)
def _cleanup_fake_meter_service_imports():
    """Remove fake module graph imported by these tests to avoid leakage."""
    # Pre-cleanup: remove service handler modules that may have been loaded by other
    # test files (e.g. smoke tests) so this file always imports them fresh with fakes.
    sys.modules.pop("service.meter_service", None)
    sys.modules.pop("util.grpc_exception", None)
    for _pre_name in list(sys.modules):
        if _pre_name.startswith("service.handlers.") or _pre_name.startswith("service."):
            sys.modules.pop(_pre_name, None)

    yield

    # service.meter_service is imported with fake dependencies in this file.
    # Drop it after each test so other test files re-import it with real deps.
    sys.modules.pop("service.meter_service", None)
    sys.modules.pop("util.grpc_exception", None)

    # Also remove service.handlers.* — they hold references to fake ng_sdk objects
    # and must be re-imported fresh with each test's fake modules.
    for module_name in list(sys.modules):
        if module_name.startswith("service.handlers.") or module_name.startswith("service."):
            sys.modules.pop(module_name, None)

    # logger.logging_setup imports from fake gen/ng_sdk; remove so next test
    # re-imports it with fresh fakes.
    for module_name in ["logger", "logger.logging_setup"]:
        mod = sys.modules.get(module_name)
        if mod is not None and getattr(mod, "__file__", None) is None:
            sys.modules.pop(module_name, None)
    sys.modules.pop("logger.logging_setup", None)
    sys.modules.pop("logger", None)

    # If this file installed fake top-level modules, remove them as well.
    for module_name in [
        "meter_context",
        "translator",
        "session",
        "license",
        "ng_sdk",
        "gen",
    ]:
        mod = sys.modules.get(module_name)
        if mod is not None and getattr(mod, "__file__", None) is None:
            sys.modules.pop(module_name, None)

    for module_name in list(sys.modules):
        if module_name.startswith(
            ("translator.", "session.", "license.", "ng_sdk.", "gen.")
        ):
            mod = sys.modules.get(module_name)
            if mod is not None and getattr(mod, "__file__", None) is None:
                sys.modules.pop(module_name, None)


class _OneofMixin:
    def WhichOneof(self, name: str):
        return getattr(self, "_which_oneof", None)


@dataclass
class _Timestamp:
    dt: datetime

    def ToDatetime(self) -> datetime:
        return self.dt


@dataclass
class _DateTimeWrapper:
    datetime: _Timestamp


@dataclass
class _LoadProfilePartialRead:
    datetime: _Timestamp
    deviation_hex: str = "8000"


@dataclass
class _GetLoadProfileRequest:
    objectName: str
    start: _LoadProfilePartialRead | None = None
    end: _LoadProfilePartialRead | None = None

    def HasField(self, name: str) -> bool:
        return getattr(self, name) is not None


@dataclass
class _TranslateDataItemRequest:
    data: str
    is_xdr_input: bool


@dataclass
class _TranslateDataRequest:
    requests: list[_TranslateDataItemRequest]


@dataclass
class _EntrySelector:
    entry_from: int
    entry_to: int
    selected_from: int
    selected_to: int


@dataclass
class _DateTimeRangeSelector:
    start: _Timestamp
    end: _Timestamp


@dataclass
class _GetRequest(_OneofMixin):
    class_: int
    obiscode: str
    attribute: int
    datetime_selector: _DateTimeRangeSelector | None = None
    entry_selector: _EntrySelector | None = None


@dataclass
class _SetRequest:
    class_: int
    obiscode: str
    attribute: int
    payload: str


@dataclass
class _ActionRequest:
    class_: int
    obiscode: str
    attribute: int
    payload: str = ""


@dataclass
class _RequestList:
    requests: list
    with_list: bool = False


@dataclass
class _Int32Value:
    value: int


@dataclass
class _BoolValue:
    value: bool


@dataclass
class _StringValue:
    value: str


@dataclass
class _StringList:
    items: list[str]


@dataclass
class _TransferUpdate:
    block_number: int
    message: str


@dataclass
class _VerifyTransfertResponse:
    chunks_ok: list[bool]


@dataclass
class _ActivateFirmwareResponse:
    success: bool
    message: str


@dataclass
class _ActivationDateTime:
    year: int
    month: int
    day: int
    hour: int
    minute: int
    second: int


@dataclass
class _DatamodelObject:
    name: str
    classId: int
    logicalName: str
    logicalName_hex: str
    description: str | None = None


@dataclass
class _GetDatamodelObjectsResponse:
    objects: list[_DatamodelObject]


@dataclass
class _DatamodelAttribute:
    id: int
    name: str
    description: str
    accessRights: str
    type: str


@dataclass
class _GetDatamodelAttributesByObjectNameRequest:
    objectName: str
    clientName: str


@dataclass
class _GetDatamodelAttributesByObjectNameResponse:
    attributes: list[_DatamodelAttribute]


@dataclass
class _TranslateDataItemResponse:
    input: str
    output: str
    is_xdr_input: bool
    success: bool
    error: str


@dataclass
class _TranslateDataResponse:
    items: list[_TranslateDataItemResponse]


@dataclass
class _AbstractFrameRequest:
    get_request: _GetRequest | None = None
    set_request: _SetRequest | None = None
    action_request: _ActionRequest | None = None


@dataclass
class _FrameExecutionItem:
    request: _AbstractFrameRequest
    xdr: str
    xml_xdr: str
    success: bool
    error: str


@dataclass
class _FrameExecutionList:
    items: list[_FrameExecutionItem]


@dataclass
class _ApplicationResponse:
    request: _AbstractFrameRequest
    value: object
    error: str
    status_code: int


@dataclass
class _ApplicationResponseList:
    responses: list[_ApplicationResponse]


@dataclass
class _ExecutionProgress:
    message: str


@dataclass
class _DownloadProgress:
    rows_total: int
    percent: int
    bytes_total: int
    bytes_read: int
    rate_bytes_per_sec: float


@dataclass
@dataclass
class _GetLoadProfileResponse:
    headerTypes: list[str] = field(default_factory=list)
    values: list[_StringList] = field(default_factory=list)
    stream_items: list = field(default_factory=list)
    status: str = ""
    total_entries: int = 0
    total_pages: int = 0
    current_page: int = 0

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)


@dataclass
class _GetLoadProfileStreamItem:
    exec: _ExecutionProgress | None = None
    download: _DownloadProgress | None = None
    result: _GetLoadProfileResponse | None = None


@dataclass
class _PhaseData:
    u: float
    i: float
    phi: float


@dataclass
class _FresnelResponse:
    phases: list[_PhaseData]


@dataclass
class _DeviceIDResponse:
    name: str
    value: str


@dataclass
class _DeviceIDList:
    items: list[_DeviceIDResponse]


@dataclass
class _FirmwareVersionResponse:
    name: str
    value: str


@dataclass
class _FirmwareVersionList:
    items: list[_FirmwareVersionResponse]


@dataclass
class _EnergyRegisterResponse:
    description: str
    value: str


@dataclass
class _EnergyRegisterList:
    items: list[_EnergyRegisterResponse]


@dataclass
class _DaylightSavingsTime:
    day: int | None
    month: int | None
    hour: int
    minute: int
    second: int
    dayOfWeek: int | None


class _LoadProfileParam:
    LOAD_PROFILE_PARAM_UNSPECIFIED = 0
    MAX_RECORD = 1
    RECORD_NUMBER = 2
    CAPTURE_PERIOD = 3


@dataclass
class _GetLoadProfileParamRequest:
    objectName: str
    param: int


@dataclass
class _SetLoadProfileParamRequest:
    objectName: str
    param: int
    value: int


@dataclass
class _LoadDatamodelRequest:
    datamodel: str


@dataclass
class _GetDatamodelObjectsRequest:
    withAttributes: bool


@dataclass
class _InitMeterContextRequest:
    modulename: str


class _FakeStream:
    def __init__(self, request):
        self._request = request
        self.sent: list[object] = []

    async def recv_message(self):
        return self._request

    async def send_message(self, message):
        self.sent.append(message)


class _DA(Enum):
    SUCCESS = 0
    OTHER = 1


class _AbstractFrameResponse:
    pass


class _DLMSExceptionResponse(_AbstractFrameResponse):
    def __init__(self, service_error: str = "SE", state_error: str = "ST"):
        self.service_error = types.SimpleNamespace(name=service_error)
        self.state_error = types.SimpleNamespace(name=state_error)


class _Data:
    def __init__(self, value):
        self.value = value

    def to_python(self):
        return self.value

    def to_bytes(self) -> bytes:
        if isinstance(self.value, (bytes, bytearray)):
            return bytes(self.value)
        if isinstance(self.value, str):
            return self.value.encode("utf-8")
        if isinstance(self.value, int):
            return self.value.to_bytes(4, "big", signed=True)
        return b""

    def to_xml(self):
        root = ET.Element("v")
        root.text = str(self.value)
        return root


class _OctetStringData(_Data):
    def to_python(self):
        return bytes(self.value)


class _StructureData(_Data):
    def to_python(self):
        return list(self.value)


class _ArrayData(_Data):
    pass


class _BooleanData(_Data):
    def to_bytes(self) -> bytes:
        return b"\x01" if self.value else b"\x00"


class _Unsigned32:
    LENGTH = 4

    def __init__(self, value: int):
        self.value = int(value)

    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(4, "big", signed=False)


class _Unsigned16:
    LENGTH = 2

    def __init__(self, value: int):
        self.value = int(value)

    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(2, "big", signed=False)


class _Unsigned8:
    LENGTH = 1

    def __init__(self, value: int):
        self.value = int(value)

    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(1, "big", signed=False)


class _Integer8(_Unsigned8):
    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(1, "big", signed=True)


class _Integer16(_Unsigned16):
    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(2, "big", signed=True)


class _Integer32(_Unsigned32):
    def to_bytes(self) -> bytes:
        return int(self.value).to_bytes(4, "big", signed=True)


class _DateTime:
    def __init__(self, value):
        self._value = value

    @classmethod
    def from_bytes(cls, _b: bytes):
        return cls((datetime(2020, 1, 2, 3, 4, 5), None))

    def to_python(self):
        if (
            isinstance(self._value, tuple)
            and len(self._value) == 2
            and isinstance(self._value[0], datetime)
        ):
            return self._value
        return (datetime(2020, 1, 1), None)

    def to_octet_string(self):
        return _OctetStringData(b"\x00" * 12)


class _DLMSGetRequestNormal:
    def __init__(self, class_id, obis_code, attribute, access_selector=None):
        self.class_id = class_id
        self.obis_code = obis_code
        self.attribute = attribute
        self.access_selector = access_selector


class _DLMSSetRequestNormal:
    def __init__(self, class_id, obis_code, attribute, payload: bytes):
        self.class_id = class_id
        self.obis_code = obis_code
        self.attribute = attribute
        self.payload = payload


class _DLMSActionRequestNormal:
    def __init__(self, class_id, obis_code, attribute, payload: bytes | None):
        self.class_id = class_id
        self.obis_code = obis_code
        self.attribute = attribute
        self.payload = payload


class _DLMSGetResponseNormal(_AbstractFrameResponse):
    def __init__(self, ok: bool, data=None):
        self.data_access_result = _DA.SUCCESS if ok else _DA.OTHER
        self.data = data

    def is_success(self) -> bool:
        return self.data_access_result == _DA.SUCCESS


class _DLMSSetResponseNormal(_AbstractFrameResponse):
    def __init__(self, ok: bool):
        self.data_access_result = _DA.SUCCESS if ok else _DA.OTHER

    def is_success(self) -> bool:
        return self.data_access_result == _DA.SUCCESS


class _DLMSActionResponseNormal(_AbstractFrameResponse):
    def __init__(self, ok: bool, data=None):
        self._ok = ok
        self.return_parameter = types.SimpleNamespace(data=data)
        self.data_access_result = _DA.SUCCESS if ok else _DA.OTHER

    def is_success(self) -> bool:
        return self._ok


class _DLMSGetResponseWithList:
    def __init__(self, result):
        self.result = result


class _DLMSSetResponseWithList:
    def __init__(self, result):
        self.result = result


class _DLMSActionResponseWithList:
    def __init__(self, list_of_responses):
        self.list_of_responses = list_of_responses


@dataclass
class _ListActionItem:
    result: _DA
    return_parameter: object


@dataclass
class _ListGetItem:
    data_access_result: _DA
    data: object


@dataclass
class _ListSetItem:
    name: str


@dataclass
class _FakeAppResponse:
    request: object
    value: object
    error: str = ""
    status_code: int = 0


class _FakeFrameExecutor:
    def __init__(self, data_model):
        self._data_model = data_model
        self._keepalive = False
        # Fake rows attribute for simulation mode (used by InitMeterContext).
        # Provides minimal SimulationDLMSExecutor-like interface.
        self.rows = [
            {"LogicName": "0100200700FF", "Attribute": "2", "Value": "test"},
            {"LogicName": "0000010000FF", "Attribute": "2", "Value": "1970-01-01"},
        ]

    def start_keepalive(self):
        self._keepalive = True

    def stop_keepalive(self):
        self._keepalive = False

    def execute_list(self, requests):
        if requests and isinstance(requests[0], _DLMSGetRequestNormal):
            items = [_ListGetItem(_DA.SUCCESS, _Data("ok")) for _ in requests]
            return _DLMSGetResponseWithList(items)
        if requests and isinstance(requests[0], _DLMSSetRequestNormal):
            return _DLMSSetResponseWithList([_DA.SUCCESS for _ in requests])
        if requests and isinstance(requests[0], _DLMSActionRequestNormal):
            items = []
            for _ in requests:
                items.append(
                    types.SimpleNamespace(
                        result=_DA.SUCCESS,
                        return_parameter=types.SimpleNamespace(data=_Data("ret")),
                    )
                )
            return _DLMSActionResponseWithList(items)
        raise AssertionError("unexpected execute_list")

    def advanced_execute(self, request):
        return _FakeAppResponse(
            request=request, value={"ok": True}, error="", status_code=200
        )

    def advanced_execute_list(self, requests):
        return [self.advanced_execute(r) for r in requests]

    def execute(self, request, progress_callback=None, cancel_event=None):
        # Used by a lot of methods; return per attribute.
        if isinstance(request, _DLMSGetRequestNormal):
            if request.class_id == 8:
                # Clock values used by a number of helpers.
                if request.attribute == 3:
                    return _DLMSGetResponseNormal(True, _Data(60))
                if request.attribute in (5, 6):
                    # Octet-string datetime: YY YY MM DD DOW hh mm ss
                    return _DLMSGetResponseNormal(
                        True, _Data(b"\xff\xff\x01\x02\x03\x04\x05\x06")
                    )
                if request.attribute == 7:
                    return _DLMSGetResponseNormal(True, _Data(60))
                if request.attribute == 8:
                    return _DLMSGetResponseNormal(True, _Data(True))

            if request.attribute == 2:
                if request.class_id == 7:
                    # buffer read: list of rows
                    rows = [
                        [b"\x00" * 12],
                        [b"\x01" * 12],
                    ]
                    if progress_callback:
                        progress_callback(10, 50, False)
                        progress_callback(20, 100, True)
                    return _DLMSGetResponseNormal(True, _Data(rows))
                if request.attribute == 3 and request.class_id == 3:
                    # scaler_unit
                    return _DLMSGetResponseNormal(True, _StructureData([0, 30]))
                return _DLMSGetResponseNormal(True, _Data(42))
            if request.attribute == 3:
                # capture objects for load profile, or image transfer status
                if request.class_id == 7:
                    structures = [
                        [8, bytes.fromhex("0000010000FF"), 2, 0],
                    ]
                    return _DLMSGetResponseNormal(True, _Data(structures))
                # image transfer status bitstring
                return _DLMSGetResponseNormal(True, _Data("1" * 2048))
            if request.attribute == 4:
                if request.class_id == 8:
                    # Clock datetime structure: [[time_bytes, date_bytes]]
                    # where time_bytes=[h,m,s] and date_bytes=[year_hi, year_lo, month, day]
                    return _DLMSGetResponseNormal(
                        True, _Data([[[3, 4, 5], b"\x07\xe4\x01\x02"]])
                    )
                return _DLMSGetResponseNormal(True, _Data(900))
            if request.attribute == 5:
                return _DLMSGetResponseNormal(True, _Data(True))
            if request.attribute == 7:
                return _DLMSGetResponseNormal(True, _Data(2))
            if request.attribute == 8:
                return _DLMSGetResponseNormal(True, _Data(12))
            return _DLMSGetResponseNormal(True, _Data(0))

        if isinstance(request, _DLMSSetRequestNormal):
            return _DLMSSetResponseNormal(True)

        if isinstance(request, _DLMSActionRequestNormal):
            return _DLMSActionResponseNormal(True, _Data("ok"))

        raise AssertionError(f"unexpected request type: {type(request)}")


class _FakeDatamodelEntry:
    def __init__(self, objects):
        self.objects = objects


class _FakeDatamodel:
    def __init__(self, objects_map):
        self._map = objects_map

    def files(self):
        return list(self._map.keys())

    def __getitem__(self, name):
        return self._map[name]


class _FakeMappingProxy:
    def __init__(self, mappings: dict[str, list[dict]]):
        self._mappings = mappings

    def __getitem__(self, key):
        return types.SimpleNamespace(items=self._mappings.get(key, []))


@dataclass
class _FakeConfig:
    association: object
    datamodel: _FakeDatamodel
    meter_identification: _FakeMappingProxy
    image_transfert: object


def _install_module(monkeypatch: pytest.MonkeyPatch, name: str) -> types.ModuleType:
    mod = types.ModuleType(name)
    monkeypatch.setitem(sys.modules, name, mod)
    return mod


def _install_fake_deps(monkeypatch: pytest.MonkeyPatch, tmp_path: Path):
    # Fake grpclib to avoid external dependency; used by util.grpc_exception.
    if "grpclib" not in sys.modules:
        grpclib_mod = _install_module(monkeypatch, "grpclib")

        class Status:
            INTERNAL = "INTERNAL"

        class GRPCError(Exception):
            def __init__(self, status, message=""):
                super().__init__(message)
                self.status = status
                self.message = message

        grpclib_mod.Status = Status
        grpclib_mod.GRPCError = GRPCError

    # Fake session.session_manager to grant permissions in tests.
    session_pkg = _install_module(monkeypatch, "session")
    session_manager_mod = _install_module(monkeypatch, "session.session_manager")

    class _FakeSession:
        def get_effective_right(self, enum_right: str) -> str:
            # Grant all rights for testing (GET, SET, ACTION, SETGET all allowed).
            return (
                enum_right.upper()
                if enum_right.upper() in ("GET", "SET", "ACTION", "SETGET")
                else "NO"
            )

    session_manager_mod.SESSION = _FakeSession()

    # Fake utils_any to avoid protobuf dependency (google.protobuf).
    utils_any_mod = _install_module(monkeypatch, "utils_any")

    def _python_to_any_noop(value):
        return value

    def _read_file_chunks(file_path, chunk_size):
        with open(file_path, "rb") as f:
            while True:
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                yield chunk

    utils_any_mod.python_to_any = _python_to_any_noop
    utils_any_mod.read_file_chunks = _read_file_chunks

    # Fake license.parser to avoid win32 deps.
    license_pkg = _install_module(monkeypatch, "license")
    parser_mod = _install_module(monkeypatch, "license.parser")
    parser_mod.get_universally_unique_identifier = lambda: "UUID"
    parser_mod.get_key_licence = lambda data_str, key_str="": (b"x" * 64, "0" * 32)
    parser_mod.decrypt_file_licence = (
        lambda hex_ciphered_key_str, file_licence_path: b"<xml/>"
    )

    # Fake ng_sdk tree (only what meter_service imports/uses).
    ng_sdk = _install_module(monkeypatch, "ng_sdk")

    def pkg(path: str):
        parts = path.split(".")
        for i in range(1, len(parts) + 1):
            n = ".".join(parts[:i])
            if n not in sys.modules:
                _install_module(monkeypatch, n)

    imports = [
        "ng_sdk.frame_builder.abstract_frame_response",
        "ng_sdk.frame_builder.dlms.dlms_enums",
        "ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal",
        "ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal",
        "ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_list",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.abstract_dlms_type",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.array",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.boolean",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.date_time",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.dlms_parser",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.enum",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.integer_16",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.integer_32",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8",
        "ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification",
        "ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification_confirm",
        "ng_sdk.frame_builder.dlms.xdlms.get_dlms_cipher",
        "ng_sdk.push_data_server.tcp_server",
        "ng_sdk.push_data_server.udp_server",
        "ng_sdk.transport.tcp.tcp_transport",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.null_data",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.structure",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32",
        "ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_8",
        "ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response",
        "ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_list",
        "ng_sdk.frame_builder.dlms.xdlms.get_data_result",
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.capture_object_definition",
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.entry_selective_access",
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.range_selective_access",
        "ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal",
        "ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal",
        "ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_with_list",
        "ng_sdk.frame_executor.dlms.gbt_dlms_executor",
        "ng_sdk.frame_executor.dlms.simulation_dlms_executor",
        "ng_sdk.util.bytes_util",
        "ng_sdk.util.dlms_time",
        "ng_sdk.util.xml_data_type_parser",
        "ng_sdk.communication.abstract_communication",
        "ng_sdk.communication.hdlc_communication",
        "ng_sdk.communication.hdlc_mode_e_communication",
        "ng_sdk.communication.lower.serial_communication",
        "ng_sdk.configuration.config_manager",
        "ng_sdk.frame_builder.dlms.dlms_frame_builder",
        "ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal",
        "ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal",
        "ng_sdk.frame_executor.dlms.dlms_executor",
        "ng_sdk.frame_executor.models.application_response",
        "ng_sdk.security.security_context",
        "ng_sdk.session.abstract_session",
        "ng_sdk.session.dlms_hls_session",
        "ng_sdk.session.dlms_password_session",
        "ng_sdk.session.dlms_session",
        "ng_sdk.transport.hdlc.hdlc_control",
        "ng_sdk.transport.hdlc.snrm_data",
        "ng_sdk.transport.hdlc.hdlc_transport",
    ]
    for m in imports:
        pkg(m)

    sys.modules[
        "ng_sdk.frame_builder.abstract_frame_response"
    ].AbstractFrameResponse = _AbstractFrameResponse
    sys.modules["ng_sdk.frame_builder.dlms.dlms_enums"].DataAccessResult = _DA
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal"
    ].DLMSActionRequestNormal = _DLMSActionRequestNormal
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal"
    ].DLMSActionResponseNormal = _DLMSActionResponseNormal
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_list"
    ].DLMSActionResponseWithList = _DLMSActionResponseWithList

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.data_type.abstract_dlms_type"
    ].DLMS_TYPE_REGISTRY = {"Unsigned32": _Unsigned32}
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.array"].ArrayData = (
        _ArrayData
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.boolean"].BooleanData = (
        _BooleanData
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.date_time"].DateTime = (
        _DateTime
    )

    class _EnumData:
        def __init__(self, value):
            self._value = value

        def to_python(self):
            return self._value

    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.enum"].EnumData = _EnumData

    class _Parser:
        def parse(self, data: bytes, *_args):
            return [_Data(data.hex())]

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.data_type.dlms_parser"
    ].DlmsDataParser = _Parser

    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.integer_16"].Integer16 = (
        _Integer16
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.integer_32"].Integer32 = (
        _Integer32
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8"].Integer8 = (
        _Integer8
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.null_data"].NullData = object
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string"
    ].OctetStringData = _OctetStringData
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.structure"].StructureData = (
        _StructureData
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16"].Unsigned16 = (
        _Unsigned16
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32"].Unsigned32 = (
        _Unsigned32
    )
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_8"].Unsigned8 = (
        _Unsigned8
    )

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response"
    ].DLMSExceptionResponse = _DLMSExceptionResponse
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_list"
    ].DLMSGetResponseWithList = _DLMSGetResponseWithList
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.get_data_result"].GetDataResult = (
        object
    )

    class _CaptureObjectDefinition:
        def __init__(self, class_id, obis_code, attribute, data_index):
            self.class_id = class_id
            self.obis_code = obis_code
            self.attribute = attribute
            self.data_index = data_index

    class _EntrySelectiveAccess:
        def __init__(self, entry_from, entry_to, selected_from, selected_to):
            self.entry_from = entry_from
            self.entry_to = entry_to
            self.selected_from = selected_from
            self.selected_to = selected_to

    class _RangeSelectiveAccess:
        def __init__(self, start, end, capture_object_definition):
            self.start = start
            self.end = end
            self.capture_object_definition = capture_object_definition

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.capture_object_definition"
    ].CaptureObjectDefinition = _CaptureObjectDefinition
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.entry_selective_access"
    ].EntrySelectiveAccess = _EntrySelectiveAccess
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.selective_access.range_selective_access"
    ].RangeSelectiveAccess = _RangeSelectiveAccess

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal"
    ].DLMSSetRequestNormal = _DLMSSetRequestNormal
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal"
    ].DLMSSetResponseNormal = _DLMSSetResponseNormal
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_with_list"
    ].DLMSSetResponseWithList = _DLMSSetResponseWithList

    sys.modules["ng_sdk.frame_executor.dlms.gbt_dlms_executor"].GBTDLMSExecutor = (
        lambda *args, **kwargs: (_FakeFrameExecutor([]))
    )
    sys.modules[
        "ng_sdk.frame_executor.dlms.simulation_dlms_executor"
    ].SimulationDLMSExecutor = lambda _path: _FakeFrameExecutor([])

    sys.modules["ng_sdk.util.bytes_util"].encode_variable_integer = lambda n: b"\x01"
    sys.modules["ng_sdk.util.bytes_util"].encode_length = lambda n: b""

    def _get_optional_value(value, sentinel, signed=False, replace_with=None):
        if isinstance(sentinel, (bytes, bytearray)):
            # comparing to sentinel bytes is not used in tests; just treat as "missing" if exact.
            return (
                None
                if value == int.from_bytes(sentinel, "big", signed=signed)
                else value
            )
        return value

    sys.modules["ng_sdk.util.dlms_time"].get_optional_value = _get_optional_value
    sys.modules["ng_sdk.util.dlms_time"].utc_offset_minutes = lambda _m: None
    sys.modules["ng_sdk.util.dlms_time"].date_from_bytes = lambda _b: None
    sys.modules["ng_sdk.util.dlms_time"].time_from_bytes = lambda _b: None

    sys.modules["ng_sdk.util.xml_data_type_parser"].parse_dlms_xml = lambda xml: _Data(
        "parsed"
    )

    # Communication/session/security placeholders
    sys.modules["ng_sdk.communication.abstract_communication"].AbstractCommunication = (
        object
    )

    class _Serial:
        def __init__(self, _cfg):
            self.cfg = _cfg

        def set_retry_hooks(self, **kwargs):
            pass

    sys.modules[
        "ng_sdk.communication.lower.serial_communication"
    ].SerialCommunication = _Serial
    sys.modules["ng_sdk.communication.hdlc_communication"].HDLCCommunication = (
        lambda *a, **k: _Serial(a[0])
    )
    sys.modules[
        "ng_sdk.communication.hdlc_mode_e_communication"
    ].HDLCModeECommunication = lambda *a, **k: _Serial(a[0])

    class ConfigModuleProxy:
        pass

    class ConfigManager:
        def __init__(self, _path):
            self.association = None

    sys.modules["ng_sdk.configuration.config_manager"].ConfigManager = ConfigManager
    sys.modules["ng_sdk.configuration.config_manager"].ConfigModuleProxy = (
        ConfigModuleProxy
    )

    sys.modules["ng_sdk.frame_builder.dlms.dlms_frame_builder"].DLMSFrameBuilder = (
        lambda *a, **k: object()
    )

    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal"
    ].DLMSGetRequestNormal = _DLMSGetRequestNormal
    sys.modules[
        "ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal"
    ].DLMSGetResponseNormal = _DLMSGetResponseNormal

    sys.modules["ng_sdk.frame_executor.dlms.dlms_executor"].DLMSExecutor = (
        lambda *a, **k: _FakeFrameExecutor([])
    )

    sys.modules[
        "ng_sdk.frame_executor.models.application_response"
    ].ApplicationResponse = _FakeAppResponse

    class SecurityContext:
        def __init__(self, _cfg):
            self.cfg = _cfg

    sys.modules["ng_sdk.security.security_context"].SecurityContext = SecurityContext

    sys.modules["ng_sdk.session.abstract_session"].AbstractSession = object

    class _Session:
        def __init__(self, *_a, **_k):
            self.is_established = False
            self.configuration = types.SimpleNamespace(
                security=types.SimpleNamespace(
                    frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0),
                    frame_counter=0,
                ),
                communication=types.SimpleNamespace(
                    keep_connection=types.SimpleNamespace(enabled=True)
                ),
            )

        def open(self):
            self.is_established = True

        def close(self):
            self.is_established = False

        def get_frame_counter(self, _cfg):
            return 1

    sys.modules["ng_sdk.session.dlms_session"].DLMSSession = _Session
    sys.modules["ng_sdk.session.dlms_password_session"].DLMSPasswordSession = _Session
    sys.modules["ng_sdk.session.dlms_hls_session"].DLMSHlsSession = _Session

    class _HDLCControl:
        SNRM = object()
        DISC = object()

    class _FrameType:
        INFORMATION = object()

    class _SnrmData:
        def to_hex(self):
            return ""

    sys.modules["ng_sdk.transport.hdlc.hdlc_control"].HDLCControl = _HDLCControl
    sys.modules["ng_sdk.transport.hdlc.hdlc_control"].FrameType = _FrameType
    sys.modules["ng_sdk.transport.hdlc.snrm_data"].SnrmData = _SnrmData
    sys.modules["ng_sdk.transport.hdlc.hdlc_transport"].HDLCTransport = (
        types.SimpleNamespace(hdlc_complete=True)
    )

    # Stubs for push_server_handler and TCP transport (class stubs — not exercised in unit tests).
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification"].DlmsDataNotification = object
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification_confirm"].DlmsDataNotificationConfirm = object
    sys.modules["ng_sdk.frame_builder.dlms.xdlms.get_dlms_cipher"].GetDlmsCipher = object
    sys.modules["ng_sdk.push_data_server.tcp_server"].TcpServer = object
    sys.modules["ng_sdk.push_data_server.udp_server"].UdpServer = object
    sys.modules["ng_sdk.transport.tcp.tcp_transport"].TCPUDPTransport = object

    # Translator stub to avoid importing full translator stack (which depends on additional ng_sdk constants).
    _install_module(monkeypatch, "translator")
    dlms_translator_mod = _install_module(monkeypatch, "translator.dlms_translator")

    class _DLMSTranslator:
        def bytes_to_xml(self, _data):
            return "<xml/>"

        def xml_to_bytes(self, _xml):
            return b""

    dlms_translator_mod.DLMSTranslator = _DLMSTranslator

    # Fake gen.meter_grpc + gen.meter_pb2 + gen.logger_pb2
    # gen.logger_pb2 is needed by logger/logging_setup.py (top-level import).
    gen_pkg = _install_module(monkeypatch, "gen")
    _install_module(monkeypatch, "gen.logger_pb2")  # stub — logging_setup imports it
    meter_grpc = _install_module(monkeypatch, "gen.meter_grpc")
    meter_grpc.MeterServiceBase = object

    meter_pb2 = _install_module(monkeypatch, "gen.meter_pb2")

    # Fake ng_sdk.logger.logger needed by logger/logging_setup.py top-level import.
    # Must be installed before any import of service.meter_service (which triggers
    # logger/logging_setup.py via base_handler.py).
    ng_sdk_logger_pkg = _install_module(monkeypatch, "ng_sdk.logger")
    ng_sdk_logger_mod = _install_module(monkeypatch, "ng_sdk.logger.logger")
    ng_sdk_logger_mod.get_logger = lambda: logging.getLogger("fake_meter")
    for name, obj in {
        "BoolValue": _BoolValue,
        "Int32Value": _Int32Value,
        "StringValue": _StringValue,
        "StringList": _StringList,
        "TransferUpdate": _TransferUpdate,
        "VerifyTransfertResponse": _VerifyTransfertResponse,
        "ActivateFirmwareResponse": _ActivateFirmwareResponse,
        "ActivationDateTime": _ActivationDateTime,
        "DatamodelObject": _DatamodelObject,
        "GetDatamodelObjectsResponse": _GetDatamodelObjectsResponse,
        "DatamodelAttribute": _DatamodelAttribute,
        "GetDatamodelAttributesByObjectNameRequest": _GetDatamodelAttributesByObjectNameRequest,
        "GetDatamodelAttributesByObjectNameResponse": _GetDatamodelAttributesByObjectNameResponse,
        "TranslateDataItemRequest": _TranslateDataItemRequest,
        "TranslateDataRequest": _TranslateDataRequest,
        "TranslateDataItemResponse": _TranslateDataItemResponse,
        "TranslateDataResponse": _TranslateDataResponse,
        "GetRequest": _GetRequest,
        "SetRequest": _SetRequest,
        "ActionRequest": _ActionRequest,
        "AbstractFrameRequest": _AbstractFrameRequest,
        "FrameExecutionItem": _FrameExecutionItem,
        "FrameExecutionList": _FrameExecutionList,
        "GetRequestList": _RequestList,
        "SetRequestList": _RequestList,
        "ActionRequestList": _RequestList,
        "ApplicationResponse": _ApplicationResponse,
        "ApplicationResponseList": _ApplicationResponseList,
        "ExecutionProgress": _ExecutionProgress,
        "DownloadProgress": _DownloadProgress,
        "GetLoadProfileRequest": _GetLoadProfileRequest,
        "GetLoadProfileResponse": _GetLoadProfileResponse,
        "GetLoadProfileStreamItem": _GetLoadProfileStreamItem,
        "PhaseData": _PhaseData,
        "FresnelResponse": _FresnelResponse,
        "DeviceIDResponse": _DeviceIDResponse,
        "DeviceIDList": _DeviceIDList,
        "FirmwareVersionResponse": _FirmwareVersionResponse,
        "FirmwareVersionList": _FirmwareVersionList,
        "EnergyRegisterResponse": _EnergyRegisterResponse,
        "EnergyRegisterList": _EnergyRegisterList,
        "DaylightSavingsTime": _DaylightSavingsTime,
        "LoadProfileParam": _LoadProfileParam,
        "GetLoadProfileParamRequest": _GetLoadProfileParamRequest,
        "SetLoadProfileParamRequest": _SetLoadProfileParamRequest,
        "LoadDatamodelRequest": _LoadDatamodelRequest,
        "GetDatamodelObjectsRequest": _GetDatamodelObjectsRequest,
        "InitMeterContextRequest": _InitMeterContextRequest,
    }.items():
        setattr(meter_pb2, name, obj)


def test_meter_service_high_coverage(monkeypatch: pytest.MonkeyPatch, tmp_path: Path):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects = [
            {
                "name": "ImageTransfer",
                "classId": 18,
                "logicalName": "0-0:44.0.0.255",
                "logicalName_hex": "00002C0000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}}
                ],
            },
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "5", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "6", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "8", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "4", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "8", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "ER",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
            },
            {
                "name": "ER2",
                "classId": 4,
                "logicalName": "1-0:2.8.0.255",
                "logicalName_hex": "0100020800FF",
            },
        ]

        for name in [
            "InstantaneousVoltageL1",
            "InstantaneousCurrentL1",
            "Instantaneous_Active_Export_power_L1",
            "Instantaneous_Reactive_Export_power_L1",
        ]:
            objects.append(
                {
                    "name": name,
                    "classId": 3,
                    "logicalName_hex": "00",
                    "logicalName": "x",
                }
            )

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {
                "dm_device_mapping": [
                    {"objectName": "Clock", "index": None, "name": "clock"}
                ],
                "dm_firmware_mapping": [
                    {"objectName": "Clock", "index": None, "name": "fw"}
                ],
            }
        )

        sim = types.SimpleNamespace(enabled=True, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim, security=types.SimpleNamespace(frame_counter=0, frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0))
        )
        association = types.SimpleNamespace(
            Public=assoc_public, Any=types.SimpleNamespace()
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class _SessionCtx:
            def __init__(self):
                self.is_established = False
                self.configuration = types.SimpleNamespace(
                    security=types.SimpleNamespace(
                        frame_counter_param=types.SimpleNamespace(
                            get_frame_counter=False, proposed_frame_counter_value=0
                        ),
                        frame_counter=0,
                        session_type="LLS",
                        ciphering_type="NO_CIPHERING",
                    ),
                    communication=types.SimpleNamespace(
                        transport_type="HDLC",
                        mode_com="Mode_E",
                        keep_connection=types.SimpleNamespace(enabled=True),
                    ),
                    features_activation=types.SimpleNamespace(
                        general_block_transfer=False
                    ),
                )

            def open(self):
                self.is_established = True

            def close(self):
                self.is_established = False

        class MeterContext:
            configuration = cfg
            communication = None
            security = None
            security_context = None
            session = _SessionCtx()
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}
            datamodel = "dm"
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")

        monkeypatch.setattr(sys.modules["service.handlers.dlms_execution_handler"], "python_to_any", lambda v: v)

        async def _inline_to_thread(fn, *args, **kwargs):
            return fn(*args, **kwargs)

        monkeypatch.setattr(asyncio, "to_thread", _inline_to_thread)

        svc = meter_service.MeterService()

        stream = _FakeStream(_InitMeterContextRequest(modulename="Any"))
        await svc.InitMeterContext(stream)
        assert stream.sent and isinstance(stream.sent[-1], _BoolValue)

        # Switch off simulation after initialization so we cover more branches.
        MeterContext.configuration.association.Public.simulation.enabled = False

        stream = _FakeStream(object())
        await svc.Connect(stream)

        stream = _FakeStream(object())
        await svc.Disconnect(stream)

        g1 = _GetRequest(class_=1, obiscode="00", attribute=2)
        g1._which_oneof = "datetime_selector"
        g1.datetime_selector = _DateTimeRangeSelector(
            _Timestamp(datetime(2020, 1, 1)),
            _Timestamp(datetime(2020, 1, 2)),
        )
        g2 = _GetRequest(class_=1, obiscode="00", attribute=2)
        g2._which_oneof = "entry_selector"
        g2.entry_selector = _EntrySelector(0, 1, 0, 1)

        stream = _FakeStream(_RequestList([g1, g2], with_list=True))
        await svc.ExecuteGet(stream)
        assert isinstance(stream.sent[-1], _FrameExecutionList)

        stream = _FakeStream(_RequestList([g1], with_list=False))
        await svc.ExecuteGet(stream)

        sreq = _SetRequest(class_=1, obiscode="00", attribute=2, payload="AA")
        stream = _FakeStream(_RequestList([sreq], with_list=True))
        await svc.ExecuteSet(stream)

        areq = _ActionRequest(class_=1, obiscode="00", attribute=2, payload="")
        stream = _FakeStream(_RequestList([areq], with_list=True))
        await svc.ExecuteAction(stream)

        stream = _FakeStream(_RequestList([g1], with_list=True))
        await svc.ExecuteAdvancedGet(stream)

        stream = _FakeStream(_RequestList([areq], with_list=False))
        await svc.ExecuteAdvancedAction(stream)

        stream = _FakeStream(_RequestList([sreq], with_list=False))
        await svc.ExecuteAdvancedSet(stream)

        stream = _FakeStream(object())
        await svc.GetBlockSize(stream)

        stream = _FakeStream(_Int32Value(value=64))
        await svc.SetBlockSize(stream)

        stream = _FakeStream(object())
        await svc.EnableImageTransfer(stream)

        test_file = tmp_path / "f.bin"
        test_file.write_bytes(b"0123456789")

        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), imageId="00", block_size=4)
        )
        await svc.InitiateTransfer(stream)

        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), block_size=4)
        )
        await svc.TransferFile(stream)

        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), block_size=4)
        )
        await svc.VerifyTransfert(stream)

        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), block_size=4)
        )
        await svc.ResendMissingChunks(stream)

        stream = _FakeStream(object())
        await svc.ActivateFirmware(stream)

        stream = _FakeStream(object())
        await svc.GetImageTransfertActivationDateTime(stream)

        stream = _FakeStream(
            _ActivationDateTime(year=2020, month=1, day=2, hour=3, minute=4, second=5)
        )
        await svc.SetImageTransfertActivationDateTime(stream)

        stream = _FakeStream(_GetDatamodelObjectsRequest(withAttributes=False))
        await svc.GetDatamodelObjects(stream)

        obj_with_attr = {
            "name": "Obj",
            "classId": 1,
            "logicalName": "x",
            "logicalName_hex": "00",
            "dlmsAttribute": [
                {
                    "id": "1",
                    "name": "a",
                    "accessRights": {"k": {"name": "client", "accessRights": "R"}},
                    "dlmsType": {"type": "Unsigned32"},
                }
            ],
        }
        MeterContext.configuration.datamodel._map["dm"].objects.append(obj_with_attr)

        stream = _FakeStream(
            _GetDatamodelAttributesByObjectNameRequest(
                objectName="Obj", clientName="client"
            )
        )
        await svc.GetDatamodelAttributesByObjectName(stream)

        stream = _FakeStream(
            _TranslateDataRequest(
                requests=[
                    _TranslateDataItemRequest("AA", True),
                    _TranslateDataItemRequest("<x/>", False),
                ]
            )
        )
        await svc.TranslateData(stream)

        stream = _FakeStream(object())
        await svc.GetClock(stream)

        stream = _FakeStream(_StringValue(value=datetime(2020, 1, 1).isoformat()))
        await svc.SetClock(stream)

        stream = _FakeStream(object())
        await svc.GetDatamodels(stream)

        stream = _FakeStream(_LoadDatamodelRequest(datamodel="dm"))
        await svc.LoadDatamodel(stream)

        stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
        await svc.GetLoadProfile(stream)

        stream = _FakeStream(
            _GetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.MAX_RECORD
            )
        )
        await svc.GetLoadProfileParam(stream)
        stream = _FakeStream(
            _GetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.RECORD_NUMBER
            )
        )
        await svc.GetLoadProfileParam(stream)
        stream = _FakeStream(
            _GetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.CAPTURE_PERIOD
            )
        )
        await svc.GetLoadProfileParam(stream)

        stream = _FakeStream(
            _SetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.MAX_RECORD, value=1
            )
        )
        await svc.SetLoadProfileParam(stream)
        stream = _FakeStream(
            _SetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.RECORD_NUMBER, value=1
            )
        )
        await svc.SetLoadProfileParam(stream)
        stream = _FakeStream(
            _SetLoadProfileParamRequest(
                objectName="LP", param=_LoadProfileParam.CAPTURE_PERIOD, value=1
            )
        )
        await svc.SetLoadProfileParam(stream)

        stream = _FakeStream(object())
        await svc.GetDeviceID(stream)
        stream = _FakeStream(object())
        await svc.GetFirmwareVersion(stream)
        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        stream = _FakeStream(object())
        await svc.GetFresnelData(stream)

        stream = _FakeStream(object())
        await svc.GetIncrementalDate(stream)
        stream = _FakeStream(
            _DaylightSavingsTime(
                day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
            )
        )
        await svc.SetIncrementalDate(stream)

        stream = _FakeStream(object())
        await svc.GetDecrementalDate(stream)
        stream = _FakeStream(
            _DaylightSavingsTime(
                day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
            )
        )
        await svc.SetDecrementalDate(stream)

    asyncio.run(_run())


def test_meter_service_connect_disconnect_simulation_mode_returns_true(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        sim = types.SimpleNamespace(enabled=True, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        cfg = types.SimpleNamespace(association=association)

        class MeterContext:
            configuration = cfg

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        stream = _FakeStream(object())
        await svc.Connect(stream)
        assert isinstance(stream.sent[-1], _BoolValue)
        assert stream.sent[-1].value is True

        stream = _FakeStream(object())
        await svc.Disconnect(stream)
        assert isinstance(stream.sent[-1], _BoolValue)
        assert stream.sent[-1].value is True

    asyncio.run(_run())


def test_meter_service_get_load_profile_header_fallback_and_unknown_dlms_type(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        # Datamodel contains the load profile plus one capture object with an
        # unknown DLMS type (not present in DLMS_TYPE_REGISTRY).
        unknown_capture_hex = "DEADBEEF"
        objects: list[dict] = [
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "Mystery",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": unknown_capture_hex,
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "NoSuchType", "size": 1}},
                ],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            communication = None
            security = None
            security_context = None
            session = None
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        # Fresh import so it picks up this MeterContext.
        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        # Override executor to control capture objects and buffer rows.
        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 3
            ):
                # Two capture objects:
                # - unknown logicalName_hex (not in datamodel) -> header fallback to hex
                # - known Mystery object with unknown DLMS type -> cls None branch in entry_size
                structures = [
                    [1, bytes.fromhex("AABBCCDD"), 2, 0],
                    [1, bytes.fromhex(unknown_capture_hex), 2, 0],
                ]
                return _DLMSGetResponseNormal(True, _Data(structures))

            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 2
            ):
                # Buffer rows with two columns to match two headers.
                rows = [[b"\x00" * 12, b"\x01" * 12]]
                if progress_callback:
                    progress_callback(1, 50, False)
                    progress_callback(2, 100, True)
                return _DLMSGetResponseNormal(True, _Data(rows))

            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
        await svc.GetLoadProfile(stream)

    asyncio.run(_run())


def test_meter_service_get_load_profile_finally_cleanup_handles_errors(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            communication = None
            security = None
            security_context = None
            session = None
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")

        # Force exceptions in the finally cleanup:
        # - queue.put(None) raises
        # - awaiting sender_task raises
        class _ExplodingQueue:
            def __init__(self, maxsize=0):
                self._items: list[object] = []
                self.maxsize = maxsize

            async def put(self, item):
                if item is None:
                    raise RuntimeError("boom put")
                self._items.append(item)

            def put_nowait(self, item):
                if item is None:
                    raise RuntimeError("boom put_nowait")
                self._items.append(item)

            async def get(self):
                if self._items:
                    return self._items.pop(0)
                await asyncio.sleep(0)
                return None

        monkeypatch.setattr(sys.modules["service.handlers.load_profile_handler"].asyncio, "Queue", _ExplodingQueue)

        def _create_task_raises(_coro):
            try:
                _coro.close()
            except Exception:
                pass
            fut = asyncio.get_running_loop().create_future()
            fut.set_exception(RuntimeError("boom sender"))
            return fut

        monkeypatch.setattr(sys.modules["service.handlers.load_profile_handler"].asyncio, "create_task", _create_task_raises)

        svc = meter_service.MeterService()
        stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
        await svc.GetLoadProfile(stream)

    asyncio.run(_run())


def test_meter_service_get_load_profile_sender_stream_closed_exits_silently(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 3
            ):
                raise grpclib.GRPCError(grpclib.Status.INTERNAL, "stop")
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        class _StreamClosedOnSend(_FakeStream):
            async def send_message(self, message):
                raise StreamClosedError(1)

        with pytest.raises(grpclib.GRPCError):
            stream = _StreamClosedOnSend(_GetLoadProfileRequest(objectName="LP"))
            await svc.GetLoadProfile(stream)

    asyncio.run(_run())


def test_meter_service_get_load_profile_sender_cancelled_exits_silently(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 3
            ):
                raise grpclib.GRPCError(grpclib.Status.INTERNAL, "stop")
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        class _CancelledOnSend(_FakeStream):
            async def send_message(self, message):
                raise asyncio.CancelledError()

        with pytest.raises(grpclib.GRPCError):
            stream = _CancelledOnSend(_GetLoadProfileRequest(objectName="LP"))
            await svc.GetLoadProfile(stream)

    asyncio.run(_run())


def test_meter_service_get_load_profile_progress_queue_full_is_dropped(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")

        class _QueueFullOnNowait:
            def __init__(self, maxsize=0):
                self._items: list[object] = []
                self.maxsize = maxsize

            async def put(self, item):
                self._items.append(item)

            def put_nowait(self, item):
                raise asyncio.QueueFull()

            async def get(self):
                while not self._items:
                    await asyncio.sleep(0)
                return self._items.pop(0)

        monkeypatch.setattr(sys.modules["service.handlers.load_profile_handler"].asyncio, "Queue", _QueueFullOnNowait)

        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 3
            ):
                structures = [[8, bytes.fromhex("0000010000FF"), 2, 0]]
                return _DLMSGetResponseNormal(True, _Data(structures))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 7
            ):
                return _DLMSGetResponseNormal(True, _Data(1))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 2
            ):
                if progress_callback:
                    progress_callback(1, 50, False)
                rows = [[b"\x00" * 12]]
                return _DLMSGetResponseNormal(True, _Data(rows))
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
        await svc.GetLoadProfile(stream)
        assert stream.sent, "Expected stream output despite QueueFull progress drop"

    asyncio.run(_run())


def test_meter_service_get_load_profile_enqueue_cancelled_is_ignored(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")

        class _CancelledPutQueue:
            def __init__(self, maxsize=0):
                self._items: list[object] = []
                self.maxsize = maxsize

            async def put(self, item):
                if item is None:
                    self._items.append(item)
                    return
                raise asyncio.CancelledError()

            def put_nowait(self, item):
                self._items.append(item)

            async def get(self):
                while not self._items:
                    await asyncio.sleep(0)
                return self._items.pop(0)

        monkeypatch.setattr(sys.modules["service.handlers.load_profile_handler"].asyncio, "Queue", _CancelledPutQueue)

        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            # Force an early error after enqueue() was called.
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 7
                and req.attribute == 3
            ):
                raise grpclib.GRPCError(grpclib.Status.INTERNAL, "stop")
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        with pytest.raises(grpclib.GRPCError):
            stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
            await svc.GetLoadProfile(stream)

    asyncio.run(_run())


def test_meter_service_get_load_profile_object_not_found_and_wrong_class_id_raise(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        # Only includes a non-profile object.
        objects: list[dict] = [
            {
                "name": "NotLP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [],
            },
            {
                "name": "BadLP",
                "classId": 1,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(Exception) as exc:
            stream = _FakeStream(_GetLoadProfileRequest(objectName="LP"))
            await svc.GetLoadProfile(stream)
        assert "Object not found" in str(exc.value)

        with pytest.raises(Exception) as exc:
            stream = _FakeStream(_GetLoadProfileRequest(objectName="BadLP"))
            await svc.GetLoadProfile(stream)
        assert "Class id must be 7" in str(exc.value)

    asyncio.run(_run())


def test_meter_service_get_device_id_mapping_branches(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {"name": "ObjA", "classId": 1, "logicalName": "x", "logicalName_hex": "AA"},
            {
                "name": "ObjBoom",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "BB",
            },
            {
                "name": "ObjLenFail",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "CC",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {
                "dm_device_mapping": [
                    {"objectName": "ObjA", "index": 0, "name": "field_a"},
                    {"objectName": "ObjA", "index": None, "name": ""},
                    {
                        "objectName": "MissingObj",
                        "index": None,
                        "name": "field_missing",
                    },
                    {"objectName": "ObjBoom", "index": None, "name": "field_boom"},
                    {"objectName": "ObjLenFail", "index": 0, "name": "field_len"},
                ],
                "dm_firmware_mapping": [],
            }
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "AA"
                and req.attribute == 2
            ):
                # decoded is a list -> hits `object_results[object_name] = decoded`
                return _DLMSGetResponseNormal(True, _Data([[b"ABC\x00\xff"]]))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "BB"
                and req.attribute == 2
            ):
                raise RuntimeError("boom")
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "CC"
                and req.attribute == 2
            ):
                # Keep branch coverage with an indexable payload shape expected by current implementation.
                return _DLMSGetResponseNormal(True, _Data([b"\x07"]))
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(object())
        await svc.GetDeviceID(stream)
        assert isinstance(stream.sent[-1], _DeviceIDList)

    asyncio.run(_run())


def test_meter_service_set_load_profile_param_object_not_found_and_wrong_class_id_raise(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "BadLP",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "00",
                "dlmsAttribute": [],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="Missing", param=_LoadProfileParam.MAX_RECORD, value=1
                )
            )
            await svc.SetLoadProfileParam(stream)
        assert "Object not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="BadLP", param=_LoadProfileParam.MAX_RECORD, value=1
                )
            )
            await svc.SetLoadProfileParam(stream)
        assert "Class id must be 7" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

    asyncio.run(_run())


def test_meter_service_set_load_profile_param_missing_attributes_raise(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "LP_BAD_ATTRS",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS",
                    param=_LoadProfileParam.MAX_RECORD,
                    value=1,
                )
            )
            await svc.SetLoadProfileParam(stream)
        assert "Attribute 8 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS",
                    param=_LoadProfileParam.RECORD_NUMBER,
                    value=1,
                )
            )
            await svc.SetLoadProfileParam(stream)
        assert "Attribute 7 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS",
                    param=_LoadProfileParam.CAPTURE_PERIOD,
                    value=1,
                )
            )
            await svc.SetLoadProfileParam(stream)
        assert "Attribute 4 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

    asyncio.run(_run())


def test_meter_service_get_firmware_version_mapping_branches(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "FWObjA",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "11",
            },
            {
                "name": "FWBoom",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "22",
            },
            {
                "name": "FWLenFail",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "33",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {
                "dm_device_mapping": [],
                "dm_firmware_mapping": [
                    {"objectName": "FWObjA", "index": 0, "name": "fw_a"},
                    {"objectName": "FWMissing", "index": None, "name": "fw_missing"},
                    {"objectName": "FWBoom", "index": None, "name": "fw_boom"},
                    {"objectName": "FWLenFail", "index": 0, "name": "fw_len"},
                ],
            }
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "11"
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, _Data([[b"FW\x00\xff"]]))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "22"
                and req.attribute == 2
            ):
                raise RuntimeError("boom")
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "33"
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, _Data([b"\x09"]))
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(object())
        await svc.GetFirmwareVersion(stream)
        assert isinstance(stream.sent[-1], _FirmwareVersionList)

    asyncio.run(_run())


def test_meter_service_energy_register_bytes_and_other_types_cover_value_str(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "ERBytes",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
                "description": "bytes",
            },
            {
                "name": "EROther",
                "classId": 4,
                "logicalName": "1-0:2.8.0.255",
                "logicalName_hex": "0100020800FF",
                "description": "other",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "0100010800FF"
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, _Data(b"CAB\x00\xff"))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "0100020800FF"
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, _Data({"x": 1}))
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        assert isinstance(stream.sent[-1], _EnergyRegisterList)
        assert len(stream.sent[-1].items) == 2

    asyncio.run(_run())


def test_meter_service_clock_missing_in_dates_dst_timezone_raises(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        # Deliberately omit the Clock object.
        objects: list[dict] = []

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        # GetIncrementalDate / GetDecrementalDate raise "Clock object not found in datamodel".
        for method in [svc.GetIncrementalDate, svc.GetDecrementalDate]:
            with pytest.raises(grpclib.GRPCError) as exc:
                await method(_FakeStream(object()))
            assert "Clock object not found" in (
                getattr(exc.value, "message", "") or str(exc.value)
            )

        # The others raise "Clock not found".
        for method, req in [
            (
                svc.SetIncrementalDate,
                _DaylightSavingsTime(
                    day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
                ),
            ),
            (
                svc.SetDecrementalDate,
                _DaylightSavingsTime(
                    day=1, month=1, hour=0, minute=0, second=0, dayOfWeek=1
                ),
            ),
            (svc.GetDaylightSavingDeviation, object()),
            (svc.SetDaylightSavingDeviation, _Int32Value(value=1)),
            (svc.GetDaylightSavingActivation, object()),
            (svc.SetDaylightSavingActivation, _BoolValue(value=True)),
            (svc.GetTimezone, object()),
            (svc.SetTimezone, _Int32Value(value=1)),
        ]:
            with pytest.raises(grpclib.GRPCError) as exc:
                await method(_FakeStream(req))
            assert "Clock not found" in (
                getattr(exc.value, "message", "") or str(exc.value)
            )

    asyncio.run(_run())


def test_meter_service_date_and_dst_timezone_read_failures_raise(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        association = types.SimpleNamespace(
            Public=types.SimpleNamespace(simulation=sim)
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        prev_execute = MeterContext.frame_executor.execute

        def _execute(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "0000010000FF"
                and req.attribute in (5, 6)
            ):
                # Trigger "...date..." failure checks (data is None).
                return _DLMSGetResponseNormal(True, None)
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "0000010000FF"
                and req.attribute in (3, 7, 8)
            ):
                # Trigger "Failed to read deviation" checks (not success).
                return _DLMSGetResponseNormal(False, _Data(0))
            if (
                isinstance(req, _DLMSSetRequestNormal)
                and req.obis_code == "0000010000FF"
                and req.attribute in (3, 7, 8)
            ):
                # Trigger "Failed to read deviation" set checks (wrong response type).
                return object()
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _execute

        with pytest.raises(grpclib.GRPCError) as exc:
            await svc.GetIncrementalDate(_FakeStream(object()))
        assert "Failed to read incremental date" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            await svc.GetDecrementalDate(_FakeStream(object()))
        assert "Failed to read decremental date" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        for method in [
            svc.GetDaylightSavingDeviation,
            svc.GetDaylightSavingActivation,
            svc.GetTimezone,
        ]:
            with pytest.raises(grpclib.GRPCError) as exc:
                await method(_FakeStream(object()))
            assert "Failed to read" in (
                getattr(exc.value, "message", "") or str(exc.value)
            )

        for method, req in [
            (svc.SetDaylightSavingDeviation, _Int32Value(value=1)),
            (svc.SetDaylightSavingActivation, _BoolValue(value=True)),
            (svc.SetTimezone, _Int32Value(value=1)),
        ]:
            with pytest.raises(grpclib.GRPCError) as exc:
                await method(_FakeStream(req))
            assert "Failed to" in (
                getattr(exc.value, "message", "") or str(exc.value)
            )

    asyncio.run(_run())


def test_meter_service_init_communication_hdlc_non_mode_e_uses_hdlc_communication(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    _install_fake_deps(monkeypatch, tmp_path)

    meter_context = types.ModuleType("meter_context")

    class MeterContext:
        configuration = None
        datamodel = "dm"

    meter_context.MeterContext = MeterContext
    monkeypatch.setitem(sys.modules, "meter_context", meter_context)

    sys.modules.pop("util.grpc_exception", None)
    sys.modules.pop("service.meter_service", None)
    meter_service = importlib.import_module("service.meter_service")

    called = {"hdlc": 0, "mode_e": 0}
    sentinel = object()

    def _hdlc_comm(*_a, **_k):
        called["hdlc"] += 1
        return sentinel

    def _mode_e_comm(*_a, **_k):
        called["mode_e"] += 1
        raise AssertionError("HDLCModeECommunication should not be used")

    monkeypatch.setattr(sys.modules["service.handlers.connection_handler"], "HDLCCommunication", _hdlc_comm)
    monkeypatch.setattr(sys.modules["service.handlers.connection_handler"], "HDLCModeECommunication", _mode_e_comm)

    cfg = types.SimpleNamespace(
        communication=types.SimpleNamespace(
            transport_type="HDLC",
            mode_com="NOT_MODE_E",
        )
    )

    svc = meter_service.MeterService()
    comm = svc._ConnectionHandler__init_communication(cfg)
    assert comm is sentinel
    assert called["hdlc"] == 1
    assert called["mode_e"] == 0


def test_meter_service_set_clock_clock_not_found_raises(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        # Deliberately omit the Clock object.
        objects: list[dict] = [
            {
                "name": "NotClock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(_StringValue(value=datetime(2020, 1, 1).isoformat()))
            await svc.SetClock(stream)
        assert "Clock not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

    asyncio.run(_run())


def test_meter_service_get_load_profile_param_object_not_found_and_wrong_class_id(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "BadLP",
                "classId": 1,
                "logicalName": "x",
                "logicalName_hex": "00",
                "dlmsAttribute": [],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="Missing", param=_LoadProfileParam.MAX_RECORD
                )
            )
            await svc.GetLoadProfileParam(stream)
        assert "Object not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="BadLP", param=_LoadProfileParam.MAX_RECORD
                )
            )
            await svc.GetLoadProfileParam(stream)
        assert "Class id must be 7" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

    asyncio.run(_run())


def test_meter_service_get_load_profile_param_missing_attributes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)


        meter_context = types.ModuleType("meter_context")

        # ClassId=7 object with missing attribute ids 8, 7, and 4.
        objects: list[dict] = [
            {
                "name": "LP_BAD_ATTRS",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS", param=_LoadProfileParam.MAX_RECORD
                )
            )
            await svc.GetLoadProfileParam(stream)
        assert "Attribute 8 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS", param=_LoadProfileParam.RECORD_NUMBER
                )
            )
            await svc.GetLoadProfileParam(stream)
        assert "Attribute 7 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

        with pytest.raises(grpclib.GRPCError) as exc:
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="LP_BAD_ATTRS", param=_LoadProfileParam.CAPTURE_PERIOD
                )
            )
            await svc.GetLoadProfileParam(stream)
        assert "Attribute 4 not found" in (
            getattr(exc.value, "message", "") or str(exc.value)
        )

    asyncio.run(_run())


def test_meter_service_energy_register_scaler_unit_read_fails_continues(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "Energy1",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
                "description": "Active energy",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        def _execute_list_scaler_fail(requests):
            items = []
            for r in requests:
                if r.attribute == 3:
                    items.append(_ListGetItem(_DA.OTHER, None))
                else:
                    items.append(_ListGetItem(_DA.SUCCESS, _Data(100)))
            return _DLMSGetResponseWithList(items)

        MeterContext.frame_executor.execute_list = _execute_list_scaler_fail

        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        assert isinstance(stream.sent[-1], _EnergyRegisterList)
        assert len(stream.sent[-1].items) == 1
        assert stream.sent[-1].items[0].description == "Active energy"
        assert stream.sent[-1].items[0].value == "100"

    asyncio.run(_run())


def test_meter_service_energy_register_per_object_error_continues(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "BadEnergy",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
                "description": "Bad energy",
            },
            {
                "name": "GoodEnergy",
                "classId": 4,
                "logicalName": "1-0:2.8.0.255",
                "logicalName_hex": "0100020800FF",
                "description": "Good energy",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = executor

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        def _execute_list_per_obj_error(requests):
            items = []
            for r in requests:
                if r.obis_code == "0100010800FF":
                    items.append(_ListGetItem(_DA.OTHER, None))
                else:
                    items.append(_ListGetItem(_DA.SUCCESS, _Data(5)))
            return _DLMSGetResponseWithList(items)

        MeterContext.frame_executor.execute_list = _execute_list_per_obj_error

        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        assert isinstance(stream.sent[-1], _EnergyRegisterList)
        assert len(stream.sent[-1].items) == 1
        assert stream.sent[-1].items[0].description == "Good energy"
        assert stream.sent[-1].items[0].value == "5"

    asyncio.run(_run())


def test_meter_service_energy_register_outer_exception_sends_empty(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        # Force an exception while trying to access datamodel objects.
        cfg = types.SimpleNamespace(datamodel=None)

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor([])
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        assert isinstance(stream.sent[-1], _EnergyRegisterList)
        assert stream.sent[-1].items == []

    asyncio.run(_run())


def test_meter_service_init_connect_disconnect_nonsimulation_and_helpers(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        public_cfg = types.SimpleNamespace(
            simulation=types.SimpleNamespace(enabled=False, path=str(tmp_path)),
            security=types.SimpleNamespace(
                frame_counter=123,
                ciphering_type="NO_CIPHERING",
                session_type="LLS",
            ),
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=True),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )

        any_cfg = types.SimpleNamespace(
            security=types.SimpleNamespace(
                ciphering_type="CIPHERING", session_type="LLS"
            ),
            communication=types.SimpleNamespace(
                transport_type="HDLC", mode_com="Mode_E"
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=True),
        )

        class _Association:
            def __init__(self, public, any_mod):
                self.Public = public
                self.Any = any_mod

            def __getitem__(self, key):
                return getattr(self, key)

        association = _Association(public_cfg, any_cfg)

        dm_entry = _FakeDatamodelEntry([])
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy({})
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            communication = None
            security = None
            security_context = None
            session = None
            frame_executor = _FakeFrameExecutor([])
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")

        svc = meter_service.MeterService()

        # Cover non-simulation init path.
        stream = _FakeStream(_InitMeterContextRequest(modulename="Any"))
        await svc.InitMeterContext(stream)
        assert MeterContext.communication is not None
        assert MeterContext.frame_executor is not None

        # Cover the non-GBT branch (DLMSExecutor path) in InitMeterContext.
        stream = _FakeStream(_InitMeterContextRequest(modulename="Public"))
        await svc.InitMeterContext(stream)

        # Cover Connect frame-counter branch + keepalive start/stop.
        MeterContext.session.configuration.security.frame_counter_param.get_frame_counter = (
            True
        )
        stream = _FakeStream(object())
        await svc.Connect(stream)
        assert MeterContext.session.is_established is True

        stream = _FakeStream(object())
        await svc.Disconnect(stream)
        assert MeterContext.session.is_established is False

        # Cover internal helper branches directly.
        comm = svc._ConnectionHandler__init_communication(any_cfg)
        assert comm is not None

        assert svc._ConnectionHandler__init_security(public_cfg) is None
        assert svc._ConnectionHandler__init_security(any_cfg) is not None

        any_cfg.security.session_type = "LLS"
        assert svc._ConnectionHandler__init_session(any_cfg, None, comm) is not None
        any_cfg.security.session_type = "HLS"
        assert svc._ConnectionHandler__init_session(any_cfg, None, comm) is not None
        any_cfg.security.session_type = "OTHER"
        assert svc._ConnectionHandler__init_session(any_cfg, None, comm) is not None

        with pytest.raises(Exception):
            svc._MeterService__verify_get_response(_DLMSExceptionResponse())

        with pytest.raises(Exception):
            svc._MeterService__verify_get_response(
                _DLMSGetResponseNormal(False, _Data(0))
            )

        with pytest.raises(Exception):
            svc._MeterService__verify_get_response(object())

    asyncio.run(_run())


def test_meter_service_additional_branches_for_coverage(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects = [
            {
                "name": "ImageTransfer",
                "classId": 18,
                "logicalName": "0-0:44.0.0.255",
                "logicalName_hex": "00002C0000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}}
                ],
            },
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "5", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "6", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "8", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "4", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "8", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "ER",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )

        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(frame_counter=0, frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=True),
            ),
        )
        association = types.SimpleNamespace(
            Public=assoc_public, Any=types.SimpleNamespace()
        )

        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class _SessionCtx:
            def __init__(self):
                self.is_established = False
                self.configuration = types.SimpleNamespace(
                    security=types.SimpleNamespace(
                        frame_counter_param=types.SimpleNamespace(
                            get_frame_counter=False, proposed_frame_counter_value=0
                        ),
                        frame_counter=0,
                        session_type="LLS",
                        ciphering_type="NO_CIPHERING",
                    ),
                    communication=types.SimpleNamespace(
                        transport_type="HDLC",
                        mode_com="Mode_E",
                        keep_connection=types.SimpleNamespace(enabled=True),
                    ),
                    features_activation=types.SimpleNamespace(
                        general_block_transfer=False
                    ),
                )

            def open(self):
                self.is_established = True

            def close(self):
                self.is_established = False

        executor = _FakeFrameExecutor(objects)
        orig_execute = executor.execute

        def _execute_override(req, progress_callback=None, cancel_event=None):
            # GetBlockSize: exercise image_block_size == None branch.
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 18
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, _Data(None))
            # ResendMissingChunks: return a list of ints with some zeros.
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 18
                and req.attribute == 3
            ):
                return _DLMSGetResponseNormal(True, _Data([0, 1, 0, 1, 1, 0, 1, 1]))
            # EnableImageTransfer: make the initial Set fail (sends False), then Get succeeds.
            if (
                isinstance(req, _DLMSSetRequestNormal)
                and req.class_id == 18
                and req.attribute == 5
            ):
                return object()
            # InitiateTransfer: exercise non-DLMSActionResponseNormal path.
            if (
                isinstance(req, _DLMSActionRequestNormal)
                and req.class_id == 18
                and req.attribute == 1
            ):
                return object()
            return orig_execute(req, progress_callback=progress_callback)

        executor.execute = _execute_override

        class MeterContext:
            configuration = cfg
            communication = None
            security = None
            security_context = None
            session = _SessionCtx()
            frame_executor = executor
            datamodel = "dm"
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()


        # Cover remaining advanced-execute branches.
        g = _GetRequest(class_=1, obiscode="00", attribute=2)
        stream = _FakeStream(_RequestList([g], with_list=False))
        await svc.ExecuteAdvancedGet(stream)

        a = _ActionRequest(class_=1, obiscode="00", attribute=2, payload=" ")
        stream = _FakeStream(_RequestList([a], with_list=False))
        await svc.ExecuteAction(stream)

        stream = _FakeStream(_RequestList([a], with_list=True))
        await svc.ExecuteAdvancedAction(stream)

        s = _SetRequest(class_=1, obiscode="00", attribute=2, payload="AA")
        stream = _FakeStream(_RequestList([s], with_list=False))
        await svc.ExecuteSet(stream)

        stream = _FakeStream(_RequestList([s], with_list=True))
        await svc.ExecuteAdvancedSet(stream)

        # Cover GetDatamodelObjects with attributes.
        stream = _FakeStream(_GetDatamodelObjectsRequest(withAttributes=True))
        await svc.GetDatamodelObjects(stream)

        # Cover GetLoadProfile date-range selector path.
        # Use a non-sentinel deviation so the tzinfo replacement lines execute.
        start = _LoadProfilePartialRead(
            datetime=_Timestamp(datetime(2020, 1, 1)), deviation_hex="0001"
        )
        end = _LoadProfilePartialRead(
            datetime=_Timestamp(datetime(2020, 1, 2)), deviation_hex="0001"
        )
        stream = _FakeStream(
            _GetLoadProfileRequest(objectName="LP", start=start, end=end)
        )
        await svc.GetLoadProfile(stream)

        # Cover TranslateData error handling branches.
        monkeypatch.setattr(
            sys.modules["service.handlers.dlms_execution_handler"],
            "parse_dlms_xml",
            lambda _xml: (_ for _ in ()).throw(ValueError("bad xml")),
        )
        stream = _FakeStream(
            _TranslateDataRequest(
                requests=[
                    _TranslateDataItemRequest("GG", True),  # invalid hex
                    _TranslateDataItemRequest("<bad/>", False),
                ]
            )
        )
        await svc.TranslateData(stream)

        # Cover mapping empty early returns.
        stream = _FakeStream(object())
        await svc.GetDeviceID(stream)

        stream = _FakeStream(object())
        await svc.GetFirmwareVersion(stream)

        # Cover GetEnergyRegister empty path.
        prev_objects = MeterContext.configuration.datamodel._map["dm"].objects
        MeterContext.configuration.datamodel._map["dm"].objects = []
        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        MeterContext.configuration.datamodel._map["dm"].objects = prev_objects

        # Cover GetBlockSize image_block_size None branch.
        stream = _FakeStream(object())
        await svc.GetBlockSize(stream)

        # Cover EnableImageTransfer failing Set branch.
        stream = _FakeStream(object())
        await svc.EnableImageTransfer(stream)

        # Cover ResendMissingChunks resend path.
        resend_file = tmp_path / "resend.bin"
        resend_file.write_bytes(b"0123456789")
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(resend_file), block_size=4)
        )
        await svc.ResendMissingChunks(stream)

        # Cover GetClock error branch when clock is missing.
        prev_objects = MeterContext.configuration.datamodel._map["dm"].objects
        MeterContext.configuration.datamodel._map["dm"].objects = [
            o for o in prev_objects if o.get("name") != "Clock"
        ]
        stream = _FakeStream(object())
        await svc.GetClock(stream)
        MeterContext.configuration.datamodel._map["dm"].objects = prev_objects

        # Cover GetClock error branch when response has no data.
        prev_execute = MeterContext.frame_executor.execute

        def _exec_no_data(req, progress_callback=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.obis_code == "0000010000FF"
                and req.attribute == 2
            ):
                return _DLMSGetResponseNormal(True, None)
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _exec_no_data
        stream = _FakeStream(object())
        await svc.GetClock(stream)
        MeterContext.frame_executor.execute = prev_execute

        # Cover GetClock error branch when response is wrong type.
        prev_execute = MeterContext.frame_executor.execute

        def _exec_wrong_type(req, progress_callback=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 8
                and req.attribute == 2
            ):
                return object()
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _exec_wrong_type
        stream = _FakeStream(object())
        await svc.GetClock(stream)
        MeterContext.frame_executor.execute = prev_execute

        # Cover TransferFile error branch when DLMS action returns wrong type.
        prev_execute = MeterContext.frame_executor.execute

        def _exec_action_wrong_type(req, progress_callback=None):
            if isinstance(req, _DLMSActionRequestNormal):
                return object()
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _exec_action_wrong_type
        tf_file = tmp_path / "tf_fail.bin"
        tf_file.write_bytes(b"012345")
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(tf_file), block_size=2)
        )
        await svc.TransferFile(stream)
        MeterContext.frame_executor.execute = prev_execute

        # Cover VerifyTransfert else path (get status not successful).
        prev_execute = MeterContext.frame_executor.execute

        def _exec_verify_fail(req, progress_callback=None):
            if isinstance(req, _DLMSGetRequestNormal) and req.attribute == 3:
                return _DLMSGetResponseNormal(False, _Data("0" * 2048))
            return prev_execute(req, progress_callback)

        MeterContext.frame_executor.execute = _exec_verify_fail
        vf_file = tmp_path / "vf.bin"
        vf_file.write_bytes(b"012345")
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(vf_file), block_size=2)
        )
        await svc.VerifyTransfert(stream)
        MeterContext.frame_executor.execute = prev_execute

        # Cover load profile param unknown-param errors.
        with pytest.raises(grpclib.GRPCError):
            stream = _FakeStream(
                _GetLoadProfileParamRequest(
                    objectName="LP",
                    param=sys.modules["service.handlers.clock_handler"].meter_pb2.LoadProfileParam.LOAD_PROFILE_PARAM_UNSPECIFIED,
                )
            )
            await svc.GetLoadProfileParam(stream)

        with pytest.raises(grpclib.GRPCError):
            stream = _FakeStream(
                _SetLoadProfileParamRequest(
                    objectName="LP",
                    param=sys.modules["service.handlers.clock_handler"].meter_pb2.LoadProfileParam.LOAD_PROFILE_PARAM_UNSPECIFIED,
                    value=1,
                )
            )
            await svc.SetLoadProfileParam(stream)

        # Cover InitiateTransfer failing response type branch.
        test_file = tmp_path / "f2.bin"
        test_file.write_bytes(b"abcd")
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), imageId="00", block_size=4)
        )
        await svc.InitiateTransfer(stream)

    asyncio.run(_run())


def test_meter_service_error_branches_from_coverage_html(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        # Deliberately omit ImageTransfer and Clock so we can hit the explicit
        # error branches (these were highlighted as missing in the HTML report).
        objects: list[dict] = [
            {
                "name": "LP",
                "classId": 7,
                "logicalName": "1-0:99.1.0.255",
                "logicalName_hex": "0100630100FF",
                "dlmsAttribute": [
                    {"id": "4", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "7", "dlmsType": {"type": "Unsigned32", "size": 4}},
                    {"id": "8", "dlmsType": {"type": "Unsigned32", "size": 4}},
                ],
            },
            {
                "name": "SchedulerObj",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "4", "dlmsType": {"type": "Unsigned32", "size": 4}}
                ],
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy({})

        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )

        class _Association:
            def __init__(self, public):
                self.Public = public

            def __getitem__(self, key):
                return getattr(self, key)

        association = _Association(assoc_public)

        image_transfert = types.SimpleNamespace(scheduler="NoSuchScheduler")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}
            communication = None
            security = None
            security_context = None
            session = None

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()


        # Missing ImageTransfer -> explicit exception branches.
        with pytest.raises(grpclib.GRPCError):
            await svc.GetBlockSize(_FakeStream(object()))

        with pytest.raises(grpclib.GRPCError):
            await svc.SetBlockSize(_FakeStream(_Int32Value(value=1)))

        # Missing Clock -> timezone branch error.
        with pytest.raises(grpclib.GRPCError):
            await svc.GetTimezone(_FakeStream(object()))

        # Missing scheduler object -> explicit "Scheduler not found".
        with pytest.raises(grpclib.GRPCError):
            await svc.GetImageTransfertActivationDateTime(_FakeStream(object()))

        # Scheduler exists but reading fails -> "Error in reading data".
        MeterContext.configuration.image_transfert.scheduler = "SchedulerObj"

        def _execute_override(req, progress_callback=None, cancel_event=None):
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 8
                and req.attribute == 4
            ):
                # data is None -> skip the "if isinstance(...) and data is not None" block
                # and hit the explicit "Error in reading data" raise.
                return _DLMSGetResponseNormal(True, None)
            return _DLMSGetResponseNormal(True, None)

        MeterContext.frame_executor.execute = _execute_override

        with pytest.raises(grpclib.GRPCError):
            await svc.GetImageTransfertActivationDateTime(_FakeStream(object()))

        # Also cover SetImageTransfertActivationDateTime scheduler-not-found.
        MeterContext.configuration.image_transfert.scheduler = "StillMissing"
        with pytest.raises(grpclib.GRPCError):
            await svc.SetImageTransfertActivationDateTime(
                _FakeStream(
                    _ActivationDateTime(
                        year=2020, month=1, day=1, hour=0, minute=0, second=0
                    )
                )
            )

    asyncio.run(_run())


def test_meter_service_image_transfer_error_paths_from_coverage_html(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "ImageTransfer",
                "classId": 18,
                "logicalName": "0-0:44.0.0.255",
                "logicalName_hex": "00002C0000FF",
                "dlmsAttribute": [
                    {"id": "2", "dlmsType": {"type": "Unsigned32", "size": 4}}
                ],
            }
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy({})

        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )

        class _Association:
            def __init__(self, public):
                self.Public = public

            def __getitem__(self, key):
                return getattr(self, key)

        association = _Association(assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            communication = None
            security = None
            security_context = None
            session = None
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        # Override executor to force the error/edge branches highlighted as missing.
        def _execute(req, progress_callback=None, cancel_event=None):
            # EnableImageTransfer: make the initial Set fail so it sends BoolValue(False).
            if (
                getattr(req, "class_id", None) == 18
                and getattr(req, "attribute", None) == 5
                and hasattr(req, "payload")
            ):
                return object()

            # EnableImageTransfer: subsequent Get returns wrong type -> hit else branch.
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 18
                and req.attribute == 5
            ):
                return object()

            # TransferFile/ResendMissingChunks block transfers: return a failed action response.
            if (
                isinstance(req, _DLMSActionRequestNormal)
                and req.class_id == 18
                and req.attribute == 2
            ):
                return _DLMSActionResponseNormal(False)

            # ResendMissingChunks status read: make every chunk "missing".
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.class_id == 18
                and req.attribute == 3
            ):
                return _DLMSGetResponseNormal(True, _Data("00"))

            # ActivateFirmware: return wrong type to trigger the error response.
            if (
                isinstance(req, _DLMSActionRequestNormal)
                and req.class_id == 18
                and req.attribute == 3
            ):
                return object()

            return _DLMSGetResponseNormal(True, _Data(0))

        MeterContext.frame_executor.execute = _execute

        # EnableImageTransfer should send a False response first.
        stream = _FakeStream(object())
        await svc.EnableImageTransfer(stream)
        assert any(getattr(msg, "value", None) is False for msg in stream.sent)

        # TransferFile should emit an error update when block transfer fails.
        test_file = tmp_path / "img.bin"
        test_file.write_bytes(b"abcdef")
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), block_size=3)
        )
        await svc.TransferFile(stream)
        assert any(
            "Error:Failed to send block" in getattr(msg, "message", "")
            for msg in stream.sent
        )

        # ResendMissingChunks should emit an error update when resend fails.
        stream = _FakeStream(
            types.SimpleNamespace(path_file=str(test_file), block_size=3)
        )
        await svc.ResendMissingChunks(stream)
        assert any(
            "Error:Failed to send block" in getattr(msg, "message", "")
            for msg in stream.sent
        )

        # ActivateFirmware error response path.
        stream = _FakeStream(object())
        await svc.ActivateFirmware(stream)
        assert any(getattr(msg, "success", None) is False for msg in stream.sent)

    asyncio.run(_run())


def test_meter_service_device_id_firmware_and_energy_register_mappings(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects: list[dict] = [
            {
                "name": "DeviceObj",
                "classId": 1,
                "logicalName": "0-0:96.1.0.255",
                "logicalName_hex": "0000600100FF",
            },
            {
                "name": "FWObj",
                "classId": 1,
                "logicalName": "0-0:96.1.2.255",
                "logicalName_hex": "0000600102FF",
            },
            {
                "name": "Energy1",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
                "description": "Active energy",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {
                "dm_device_mapping": [
                    {"objectName": "DeviceObj", "name": "serial", "index": 1},
                    {"objectName": "MissingObj", "name": "missing", "index": 0},
                ],
                "dm_firmware_mapping": [
                    {"objectName": "FWObj", "name": "firmware", "index": 0},
                    {"objectName": "FWObj", "name": None, "index": 0},
                ],
            }
        )

        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(
                frame_counter=0, ciphering_type="NO_CIPHERING", session_type="LLS",
                frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)
            ),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=False),
            ),
            features_activation=types.SimpleNamespace(general_block_transfer=False),
        )
        association = types.SimpleNamespace(Public=assoc_public)
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class MeterContext:
            configuration = cfg
            datamodel = "dm"
            communication = None
            security = None
            security_context = None
            session = None
            frame_executor = _FakeFrameExecutor(objects)
            class7_cache = {}

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        # Override executor so DeviceID/Firmware can take the OctetStringData path,
        # and EnergyRegister can read scaler_unit as StructureData.
        def _execute(req, progress_callback=None, cancel_event=None):
            if isinstance(req, _DLMSGetRequestNormal) and req.attribute == 2:
                if req.obis_code == "0000600100FF":
                    return _DLMSGetResponseNormal(True, _OctetStringData(b"ABCD"))
                if req.obis_code == "0000600102FF":
                    return _DLMSGetResponseNormal(True, _OctetStringData(b"FW1"))
                if req.obis_code == "0100010800FF":
                    return _DLMSGetResponseNormal(True, _Data(100))
            if (
                isinstance(req, _DLMSGetRequestNormal)
                and req.attribute == 3
                and req.class_id == 3
            ):
                return _DLMSGetResponseNormal(True, _StructureData([1, 30]))
            return _DLMSGetResponseNormal(True, _Data(0))

        MeterContext.frame_executor.execute = _execute

        stream = _FakeStream(object())
        await svc.GetDeviceID(stream)
        assert isinstance(stream.sent[-1], _DeviceIDList)
        assert stream.sent[-1].items

        stream = _FakeStream(object())
        await svc.GetFirmwareVersion(stream)
        assert isinstance(stream.sent[-1], _FirmwareVersionList)
        assert stream.sent[-1].items

        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)
        assert isinstance(stream.sent[-1], _EnergyRegisterList)
        assert stream.sent[-1].items

    asyncio.run(_run())


def test_meter_service_energy_fresnel_and_clock_settings(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
):
    async def _run():
        _install_fake_deps(monkeypatch, tmp_path)

        meter_context = types.ModuleType("meter_context")

        objects = [
            {
                "name": "Clock",
                "classId": 8,
                "logicalName": "0-0:1.0.0.255",
                "logicalName_hex": "0000010000FF",
                "dlmsAttribute": [
                    {"id": "3", "dlmsType": {"type": "Integer16", "size": 2}},
                    {"id": "5", "dlmsType": {"type": "OctetString", "size": 12}},
                    {"id": "6", "dlmsType": {"type": "OctetString", "size": 12}},
                    {"id": "7", "dlmsType": {"type": "Integer8", "size": 1}},
                    {"id": "8", "dlmsType": {"type": "Boolean", "size": 1}},
                ],
            },
            {
                "name": "ER",
                "description": "Active energy",
                "classId": 3,
                "logicalName": "1-0:1.8.0.255",
                "logicalName_hex": "0100010800FF",
            },
            # Provide a subset of fresnel objects to exercise both present/missing branches.
            {
                "name": "InstantaneousVoltageL1",
                "classId": 1,
                "logicalName": "1-0:32.7.0.255",
                "logicalName_hex": "0100200700FF",
            },
            {
                "name": "InstantaneousCurrentL1",
                "classId": 1,
                "logicalName": "1-0:31.7.0.255",
                "logicalName_hex": "01001F0700FF",
            },
            {
                "name": "Instantaneous_Active_Export_power_L1",
                "classId": 1,
                "logicalName": "1-0:2.7.0.255",
                "logicalName_hex": "0100020700FF",
            },
            {
                "name": "Instantaneous_Reactive_Export_power_L1",
                "classId": 1,
                "logicalName": "1-0:4.7.0.255",
                "logicalName_hex": "0100040700FF",
            },
        ]

        dm_entry = _FakeDatamodelEntry(objects)
        datamodel = _FakeDatamodel({"dm": dm_entry})
        mapping = _FakeMappingProxy(
            {"dm_device_mapping": [], "dm_firmware_mapping": []}
        )
        sim = types.SimpleNamespace(enabled=False, path=str(tmp_path))
        assoc_public = types.SimpleNamespace(
            simulation=sim,
            security=types.SimpleNamespace(frame_counter=0, frame_counter_param=types.SimpleNamespace(get_frame_counter=False, proposed_frame_counter_value=0)),
            security_context=None,
            communication=types.SimpleNamespace(
                transport_type="HDLC",
                mode_com="Mode_E",
                keep_connection=types.SimpleNamespace(enabled=True),
            ),
        )
        association = types.SimpleNamespace(
            Public=assoc_public, Any=types.SimpleNamespace()
        )
        image_transfert = types.SimpleNamespace(scheduler="Clock")
        cfg = _FakeConfig(
            association=association,
            datamodel=datamodel,
            meter_identification=mapping,
            image_transfert=image_transfert,
        )

        class _SessionCtx:
            def __init__(self):
                self.is_established = True
                self.configuration = types.SimpleNamespace(
                    security=types.SimpleNamespace(
                        frame_counter_param=types.SimpleNamespace(
                            get_frame_counter=False, proposed_frame_counter_value=0
                        ),
                        frame_counter=0,
                        session_type="LLS",
                        ciphering_type="NO_CIPHERING",
                    ),
                    communication=types.SimpleNamespace(
                        transport_type="HDLC",
                        mode_com="Mode_E",
                        keep_connection=types.SimpleNamespace(enabled=True),
                    ),
                    features_activation=types.SimpleNamespace(
                        general_block_transfer=False
                    ),
                )

            def open(self):
                self.is_established = True

            def close(self):
                self.is_established = False

        executor = _FakeFrameExecutor(objects)

        class MeterContext:
            configuration = cfg
            communication = None
            security = None
            security_context = None
            session = _SessionCtx()
            frame_executor = executor
            datamodel = "dm"

        meter_context.MeterContext = MeterContext
        monkeypatch.setitem(sys.modules, "meter_context", meter_context)

        sys.modules.pop("util.grpc_exception", None)
        sys.modules.pop("service.meter_service", None)
        meter_service = importlib.import_module("service.meter_service")
        svc = meter_service.MeterService()

        # Energy register read (including scaler/unit parsing branch).
        stream = _FakeStream(object())
        await svc.GetEnergyRegister(stream)

        # Fresnel data (mix of present and missing objects).
        stream = _FakeStream(object())
        await svc.GetFresnelData(stream)

        # Incremental/decremental date + associated set operations.
        stream = _FakeStream(object())
        await svc.GetIncrementalDate(stream)
        stream = _FakeStream(object())
        await svc.GetDecrementalDate(stream)

        req_dt = sys.modules["service.handlers.clock_handler"].meter_pb2.DaylightSavingsTime(
            day=2, month=3, hour=4, minute=5, second=6, dayOfWeek=1
        )
        stream = _FakeStream(req_dt)
        await svc.SetIncrementalDate(stream)
        stream = _FakeStream(req_dt)
        await svc.SetDecrementalDate(stream)

        # Daylight saving deviation/activation + timezone.
        stream = _FakeStream(object())
        await svc.GetDaylightSavingDeviation(stream)
        stream = _FakeStream(sys.modules["service.handlers.clock_handler"].meter_pb2.Int32Value(value=1))
        await svc.SetDaylightSavingDeviation(stream)

        stream = _FakeStream(object())
        await svc.GetDaylightSavingActivation(stream)
        stream = _FakeStream(sys.modules["service.handlers.clock_handler"].meter_pb2.BoolValue(value=True))
        await svc.SetDaylightSavingActivation(stream)

        stream = _FakeStream(object())
        await svc.GetTimezone(stream)
        stream = _FakeStream(sys.modules["service.handlers.clock_handler"].meter_pb2.Int32Value(value=60))
        await svc.SetTimezone(stream)

    asyncio.run(_run())

