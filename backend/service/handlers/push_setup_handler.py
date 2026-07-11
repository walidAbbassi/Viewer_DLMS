"""
PushSetupHandler — toutes les opérations de configuration de l'objet Push Setup
(PushObjectList, RandomisationStartInterval, NumberOfRetries, RepetitionDelay,
LastConfirmationDatetime, SendDestination, CommunicationWindow, ExecutionTime,
PushActionType, PushActionExecutedScript, ScriptTable, PushSelectiveCaptureObjects,
PushRecoveryObjects, PushSetupPush, PushSetupReset, ExecuteScriptTable).
SRP : uniquement la configuration Push.
"""
from datetime import datetime

from google.protobuf import empty_pb2

from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import DLMSActionRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import DLMSActionResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.data_type.array import ArrayData
from ng_sdk.frame_builder.dlms.xdlms.data_type.date_time import DateTime
from ng_sdk.frame_builder.dlms.xdlms.data_type.enum import EnumData
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8 import Integer8
from ng_sdk.frame_builder.dlms.xdlms.data_type.null_data import NullData
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_8 import Unsigned8
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32 import Unsigned32
from ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response import DLMSExceptionResponse
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal


from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.grpc_exception import grpc_exception_handler


class PushSetupHandler(BaseHandler):
    """Gère la configuration des objets Push Setup COSEM (Class 40)."""

    def _get_push_object(self, datasource: str):
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == datasource), None)
        if obj is None:
            raise Exception("Object not found")
        return obj

    @staticmethod
    def _fmt_cosem_datetime(b: bytes) -> str:
        year = int.from_bytes(b[:2], "big")
        month, dom, wd, hour, minute, second = b[2], b[3], b[4], b[5], b[6], b[7]
        year_s = f"{year:04X}" if year == 0xFFFF else f"{year}"
        month_s = f"{month:02X}" if month == 0xFF else f"{month:02d}"
        dom_s = f"{dom:02X}" if dom == 0xFF else f"{dom:02d}"
        wd_s = f"{wd:02X}" if wd == 0xFF else f"{wd}"
        hour_s = f"{hour:02X}" if hour == 0xFF else f"{hour:02d}"
        min_s = f"{minute:02X}" if minute == 0xFF else f"{minute:02d}"
        sec_s = f"{second:02X}" if second == 0xFF else f"{second:02d}"
        return f"{dom_s}-{month_s}-{year_s} WD:{wd_s} {hour_s}:{min_s}:{sec_s}"

    @grpc_exception_handler
    async def GetPushObjectList(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2))
        self._verify_get_response(resp)
        push_object_items = []
        for object in resp.data.to_python():
            dm_obj = next((item for item in data_model if item["logicalName_hex"].upper() == object[1].hex().upper()), None)
            restriction_type = object[4][0]
            if restriction_type == 1:
                start_time, _ = DateTime.from_bytes(object[4][1][0]).value
                end_time, _ = DateTime.from_bytes(object[4][1][1]).value
                restriction_value = meter_pb2.PushObjectRestrictionDateRange(from_date=start_time.strftime("%Y-%m-%d %H:%M:%S"), to_date=end_time.strftime("%Y-%m-%d %H:%M:%S"))
                push_object_items.append(meter_pb2.PushObjectItem(class_id=object[0], attribute_index=object[2], logical_name=object[1].hex().upper(), object_name="" if dm_obj is None else dm_obj["name"], data_index=object[3], restriction_type=object[4][0], date_range=restriction_value))
            elif restriction_type == 2:
                restriction_value = meter_pb2.PushObjectRestrictionEntryRange(from_entry=object[4][1][0], to_entry=object[4][1][1])
                push_object_items.append(meter_pb2.PushObjectItem(class_id=object[0], attribute_index=object[2], logical_name=object[1].hex().upper(), object_name="" if dm_obj is None else dm_obj["name"], data_index=object[3], restriction_type=object[4][0], entry_range=restriction_value))
            else:
                push_object_items.append(meter_pb2.PushObjectItem(class_id=object[0], attribute_index=object[2], logical_name=object[1].hex().upper(), object_name="" if dm_obj is None else dm_obj["name"], data_index=object[3], restriction_type=object[4][0]))
        await stream.send_message(meter_pb2.GetPushObjectListResponse(items=push_object_items))

    @grpc_exception_handler
    async def SetPushObjectList(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        object_list = []
        for item in request.items:
            if item.restriction_type == 1 and item.HasField("date_range"):
                from_date = DateTime(value=(datetime.strptime(item.date_range.from_date, "%Y-%m-%d %H:%M:%S"), None)).to_octet_string()
                to_date = DateTime(value=(datetime.strptime(item.date_range.to_date, "%Y-%m-%d %H:%M:%S"), None)).to_octet_string()
                restriction = StructureData(value=[from_date, to_date])
            elif item.restriction_type == 2 and item.HasField("entry_range"):
                restriction = StructureData(value=[Unsigned32(value=item.entry_range.from_entry), Unsigned32(value=item.entry_range.to_entry)])
            else:
                restriction = NullData()
            object_list.append(StructureData(value=[
                Unsigned16(value=item.class_id),
                OctetStringData(value=bytes.fromhex(item.logical_name)),
                Integer8(value=item.attribute_index),
                Unsigned16(value=item.data_index),
                StructureData(value=[EnumData(value=item.restriction_type), restriction, ArrayData(value=[])]),
            ]))
        set_resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 2, ArrayData(value=object_list).to_bytes()))
        self._verify_set_response(set_resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetRandomisationStartInterval(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 5))
        self._verify_get_response(resp)
        await stream.send_message(meter_pb2.GetRandomisationStartIntervalResponse(result=resp.data.to_python()))

    @grpc_exception_handler
    async def SetRandomisationStartInterval(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 5, Unsigned16(value=request.value).to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetNumberOfRetries(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 6))
        self._verify_get_response(resp)
        await stream.send_message(meter_pb2.GetNumberOfRetriesResponse(result=resp.data.to_python()))

    @grpc_exception_handler
    async def SetNumberOfRetries(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 6, Unsigned8(value=request.value).to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetRepetitionDelay(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 7))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        await stream.send_message(meter_pb2.GetRepetitionDelayResponse(min=result[0], exponent=result[1], max=result[2]))

    @grpc_exception_handler
    async def SetRepetitionDelay(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 7, StructureData(value=[Unsigned16(value=request.min), Unsigned16(value=request.exponent), Unsigned16(value=request.max)]).to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetLastConfirmationDatetime(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 13))
        self._verify_get_response(resp)
        try:
            dt, _ = DateTime.from_bytes(resp.data.value).value
            await stream.send_message(meter_pb2.GetLastConfirmationDatetimeResponse(result=dt.strftime("%Y-%m-%d %H:%M:%S")))
        except Exception:
            await stream.send_message(meter_pb2.GetLastConfirmationDatetimeResponse(result=datetime.now().strftime("%Y-%m-%d %H:%M:%S")))

    @grpc_exception_handler
    async def SetLastConfirmationDatetime(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 13, DateTime(value=(datetime.strptime(request.value, "%Y-%m-%dT%H:%M:%S.%f"), None)).to_octet_string().to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetSendDestination(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        await stream.send_message(meter_pb2.GetSendDestinationResponse(tcp_service=result[0], destination=result[1].decode("ascii", errors="ignore"), message=result[2]))

    @grpc_exception_handler
    async def SetSendDestination(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        payload = StructureData(value=[EnumData(value=request.tcp_service), OctetStringData(value=request.destination.encode("ascii")), EnumData(value=request.message)])
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 3, payload.to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetCommunicationWindow(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 4))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        windows = []
        for window in result:
            starttime = self._fmt_cosem_datetime(window[0])
            endtime = self._fmt_cosem_datetime(window[1])
            windows.append(meter_pb2.CommunicationWindowEntry(start_time=starttime, end_time=endtime))
        await stream.send_message(meter_pb2.GetCommunicationWindowResponse(windows=windows))

    @grpc_exception_handler
    async def SetCommunicationWindow(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)

        def cosem_dt_to_bytes(dt) -> bytes:
            return (dt.year.to_bytes(2, "big") + bytes([dt.month, dt.day, dt.weekday, dt.hour, dt.minute, dt.second, 0]) + b"\x80\x00" + b"\xff")

        windows_array = []
        for window in request.windows:
            windows_array.append(StructureData(value=[OctetStringData(value=cosem_dt_to_bytes(window.start_time)), OctetStringData(value=cosem_dt_to_bytes(window.end_time))]))
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4, ArrayData(value=windows_array).to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetExecutionTime(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 4))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        items = []
        for entry in result:
            time_bytes = entry[0]
            hour, minute, second, millisecond = time_bytes[0], time_bytes[1], time_bytes[2], time_bytes[3]
            date_bytes = entry[1]
            year = int.from_bytes(date_bytes[:2], "big")
            month, dom, dow = date_bytes[2], date_bytes[3], date_bytes[4]
            year_s = f"{year:04X}" if year == 0xFFFF else f"{year}"
            month_s = f"{month:02X}" if month == 0xFF else f"{month:02d}"
            dom_s = f"{dom:02X}" if dom == 0xFF else f"{dom:02d}"
            wd_s = f"{dow:02X}" if dow == 0xFF else f"{dow}"
            hour_s = f"{hour:02X}" if hour == 0xFF else f"{hour:02d}"
            min_s = f"{minute:02X}" if minute == 0xFF else f"{minute:02d}"
            sec_s = f"{second:02X}" if second == 0xFF else f"{second:02d}"
            ms_s = f"{millisecond:02X}" if millisecond == 0xFF else f"{millisecond:03d}"
            items.append(f"{dom_s}-{month_s}-{year_s} WD:{wd_s} {hour_s}:{min_s}:{sec_s}.{ms_s}")
        await stream.send_message(meter_pb2.StringList(items=items))

    @grpc_exception_handler
    async def SetExecutionTime(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)

        def cosem_time_to_bytes(dt) -> bytes:
            return bytes([dt.hour, dt.minute, dt.second, 0xFF])

        def cosem_date_to_bytes(dt) -> bytes:
            return dt.year.to_bytes(2, "big") + bytes([dt.month, dt.day, dt.weekday])

        times_array = [StructureData(value=[OctetStringData(value=cosem_time_to_bytes(entry)), OctetStringData(value=cosem_date_to_bytes(entry))]) for entry in request.times]
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4, ArrayData(value=times_array).to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetPushActionType(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3))
        self._verify_get_response(resp)
        await stream.send_message(meter_pb2.Int32Value(value=resp.data.to_python()))

    @grpc_exception_handler
    async def GetPushActionExecutedScript(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        script_table_bytes: bytes = result[0]
        script_selector: int = result[1]
        await stream.send_message(meter_pb2.GetPushActionExecutedScriptResponse(
            script_selector=script_selector,
            script_table=";".join(str(b) for b in script_table_bytes),
        ))

    @grpc_exception_handler
    async def SetPushActionExecutedScript(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        script_table_bytes = bytes(int(b) for b in request.script_table.split(";") if b)
        payload = StructureData(value=[OctetStringData(value=script_table_bytes), Unsigned16(value=request.script_selector)])
        resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 2, payload.to_bytes()))
        self._verify_set_response(resp)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def GetScriptTable(self, stream):
        request = await stream.recv_message()
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        entries = []
        for item in result:
            script_identifier = item[0]
            action = item[1][0]
            entries.append(meter_pb2.ScriptTableEntry(
                script_identifier=script_identifier,
                service_id=action[0],
                class_id=action[1],
                logical_name=";".join(str(b) for b in action[2]),
                index=action[3],
                parameter="Null",
            ))
        await stream.send_message(meter_pb2.GetScriptTableResponse(entries=entries))

    @grpc_exception_handler
    async def GetPushSelectiveCaptureObjects(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = self._get_push_object(request.datasource)
        resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3))
        self._verify_get_response(resp)
        result = resp.data.to_python()
        items = []
        for entry in result:
            class_id = entry[0]
            obis_bytes: bytes = entry[1]
            attribute_index = entry[2]
            data_index = entry[3]
            obis_hex = obis_bytes.hex().upper()
            obis_str = ";".join(str(b) for b in obis_bytes)
            dm_obj = next((item for item in data_model if item["logicalName_hex"].upper() == obis_hex), None)
            items.append(meter_pb2.CaptureObjectEntry(class_id=class_id, obis_code=obis_str, attribute_index=attribute_index, data_index=data_index, name="" if dm_obj is None else dm_obj["name"]))
        await stream.send_message(meter_pb2.GetPushSelectiveCaptureObjectsResponse(entries=items))

    @grpc_exception_handler
    async def GetPushRecoveryObjects(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        results = []
        for item in request.items:
            obj = next((dm_item for dm_item in data_model if dm_item["name"] == item.datasource), None)
            if obj is None:
                results.append(f"ERROR: Object not found: {item.datasource}")
                continue
            try:
                resp = await self._run(MeterContext.frame_executor.execute, DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], item.attribute))
                self._verify_get_response(resp)
                results.append(str(resp.data.to_python()))
            except Exception as e:
                results.append(f"ERROR: {str(e)}")
        await stream.send_message(meter_pb2.GetPushRecoveryObjectsResponse(results=results))

    def _push_action(self, method_id: int, datasource: str):
        """Helper : execute action method 1 or 2 on push object."""
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == datasource), None)
        if obj is None:
            raise Exception("Object not found")
        return obj, method_id

    @grpc_exception_handler
    async def PushSetupPush(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == request.datasource), None)
        if obj is None: raise Exception("Object not found")
        response = await self._run(MeterContext.frame_executor.execute, DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 1, Integer8(value=0).to_bytes()))
        if not isinstance(response, DLMSActionResponseNormal) or not response.is_success():
            if isinstance(response, DLMSExceptionResponse):
                raise Exception("Service error: " + response.service_error.name + " State error: " + response.state_error.name)
            elif isinstance(response, DLMSActionResponseNormal):
                raise Exception(response.result.name)
            else:
                raise Exception("Response Error")
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def PushSetupReset(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == request.datasource), None)
        if obj is None: raise Exception("Object not found")
        response = await self._run(MeterContext.frame_executor.execute, DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 2, Integer8(value=0).to_bytes()))
        if not isinstance(response, DLMSActionResponseNormal) or not response.is_success():
            if isinstance(response, DLMSExceptionResponse):
                raise Exception("Service error: " + response.service_error.name + " State error: " + response.state_error.name)
            elif isinstance(response, DLMSActionResponseNormal):
                raise Exception(response.result.name)
            else:
                raise Exception("Response Error")
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def ExecuteScriptTable(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == request.datasource), None)
        if obj is None: raise Exception("Object not found")
        response = await self._run(MeterContext.frame_executor.execute, DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 1, Unsigned16(value=1).to_bytes()))
        if not isinstance(response, DLMSActionResponseNormal) or not response.is_success():
            if isinstance(response, DLMSExceptionResponse):
                raise Exception("Service error: " + response.service_error.name + " State error: " + response.state_error.name)
            elif isinstance(response, DLMSActionResponseNormal):
                raise Exception(response.result.name)
            else:
                raise Exception("Response Error")
        await stream.send_message(empty_pb2.Empty())


