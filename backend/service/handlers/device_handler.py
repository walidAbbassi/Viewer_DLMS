"""
DeviceHandler — GetDeviceID, GetFirmwareVersion, GetBitStatus.
SRP : lecture des identifiants et du firmware du compteur.
"""
import contextvars
import json

from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.grpc_exception import grpc_exception_handler


class DeviceHandler(BaseHandler):
    """Gère GetDeviceID, GetFirmwareVersion et GetBitStatus."""

    @grpc_exception_handler
    async def GetDeviceID(self, stream):
        await stream.recv_message()
        mapping_proxy = MeterContext.configuration.meter_identification
        mapping = mapping_proxy[MeterContext.datamodel + "_device_mapping"].items

        if not mapping:
            await stream.send_message(meter_pb2.DeviceIDList(items=[]))
            return

        groups = {}
        for entry in mapping:
            obj_name = entry["objectName"]
            groups.setdefault(obj_name, []).append(entry)

        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        object_results = {}

        for object_name, entries in groups.items():
            obj = next((item for item in data_model if item["name"] == object_name), None)
            if obj is None:
                object_results[object_name] = []
                continue
            try:
                request = DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2)
                response = await self._run(MeterContext.frame_executor.execute, request)
                self._verify_get_response(response)
                raw = response.data
                if isinstance(raw, OctetStringData):
                    decoded = (
                        raw.to_python().decode("ascii", errors="ignore").rstrip("\x00\xff")
                    )
                else:
                    decoded = raw.to_python()
                object_results[object_name] = decoded
            except (ConnectionResetError, BrokenPipeError, TimeoutError,
                    ConnectionRefusedError, IndexError, PermissionError):
                raise
            except Exception:
                object_results[object_name] = []

        response_fields = []
        for entry in mapping:
            obj_name = entry["objectName"]
            idx = entry.get("index", None)
            field_name = entry.get("name")
            if not field_name:
                continue
            value = object_results.get(obj_name, None)
            if idx is not None:
                if value:
                    first = value[0]
                    try:
                        if 0 <= idx < len(first):
                            value = first[idx]
                    except Exception:
                        pass
            if isinstance(value, (bytes, bytearray)):
                value = value.decode("ascii", errors="ignore").rstrip("\x00\xff")
            response_fields.append(meter_pb2.DeviceIDResponse(
                name=field_name, value=str(value) if value else ""
            ))

        await stream.send_message(meter_pb2.DeviceIDList(items=response_fields))

    @grpc_exception_handler
    async def GetFirmwareVersion(self, stream):
        await stream.recv_message()
        mapping_proxy = MeterContext.configuration.meter_identification
        mapping = mapping_proxy[MeterContext.datamodel + "_firmware_mapping"].items

        if not mapping:
            await stream.send_message(meter_pb2.FirmwareVersionList(items=[]))
            return

        groups = {}
        for entry in mapping:
            obj_name = entry["objectName"]
            groups.setdefault(obj_name, []).append(entry)

        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        data_model_map = {o["name"]: o for o in data_model}
        object_results = {}

        for object_name, entries in groups.items():
            obj = data_model_map.get(object_name)
            if obj is None:
                object_results[object_name] = []
                continue
            try:
                request = DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2)
                response = await self._run(MeterContext.frame_executor.execute, request)
                self._verify_get_response(response)
                raw = response.data
                if isinstance(raw, OctetStringData):
                    decoded = (
                        raw.to_python().decode("ascii", errors="ignore").rstrip("\x00\xff")
                    )
                else:
                    decoded = raw.to_python()
                object_results[object_name] = decoded
            except (ConnectionResetError, BrokenPipeError, TimeoutError,
                    ConnectionRefusedError, IndexError, PermissionError):
                raise
            except Exception:
                object_results[object_name] = []

        response_fields = []
        for entry in mapping:
            obj_name = entry["objectName"]
            idx = entry.get("index", None)
            field_name = entry.get("name")
            if not field_name or not isinstance(field_name, str):
                field_name = f"field_{idx if idx is not None else 'unknown'}"
            value = object_results.get(obj_name, None)
            if idx is not None:
                if value:
                    first = value[0]
                    try:
                        if 0 <= idx < len(first):
                            value = first[idx]
                    except Exception:
                        pass
            if isinstance(value, (bytes, bytearray)):
                value = value.decode("ascii", errors="ignore").rstrip("\x00\xff")
            response_fields.append(meter_pb2.FirmwareVersionResponse(
                name=str(field_name), value=str(value) if value else ""
            ))

        await stream.send_message(meter_pb2.FirmwareVersionList(items=response_fields))

    @grpc_exception_handler
    async def GetBitStatus(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        status_object = next(
            (item for item in data_model if item["name"] == request.dataSource), None
        )
        if status_object is None:
            raise Exception("Object not found")
        get_request = DLMSGetRequestNormal(
            status_object["classId"], status_object["logicalName_hex"], 2
        )
        get_response = await self._run(MeterContext.frame_executor.execute, get_request)
        self._verify_get_response(get_response)
        status_value = get_response.data.to_python()
        description_json = json.loads(request.descriptionJson)
        result = []
        for item in description_json:
            bit_val = int(item["bitValue"], 16)
            is_active = bool(status_value & bit_val)
            result.append(meter_pb2.BitStatus(
                mask=item["mask"],
                bitValue=item["bitValue"],
                description=item["description"],
                isActive=is_active,
            ))
        await stream.send_message(meter_pb2.BitStatusResponse(bits=result))

