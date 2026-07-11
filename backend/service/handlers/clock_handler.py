"""
ClockHandler — GetClock, SetClock, GetIncrementalDate, SetIncrementalDate,
               GetDecrementalDate, SetDecrementalDate, GetDaylightSavingDeviation,
               SetDaylightSavingDeviation, GetDaylightSavingActivation,
               SetDaylightSavingActivation, GetTimezone, SetTimezone.
SRP : toutes les opérations sur l'objet COSEM Clock (Class 8).
"""
from datetime import datetime

from ng_sdk.frame_builder.dlms.xdlms.data_type.boolean import BooleanData
from ng_sdk.frame_builder.dlms.xdlms.data_type.date_time import DateTime
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8 import Integer8
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_16 import Integer16
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal import DLMSSetResponseNormal
from ng_sdk.util.dlms_time import get_optional_value

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler


class ClockHandler(BaseHandler):
    """Gère toutes les opérations sur l'objet COSEM Clock (Class 8)."""

    def _get_clock_object(self):
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        return next((item for item in data_model if item["name"] == "Clock"), None)

    @grpc_exception_handler
    async def GetClock(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is not None:
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 2),
            )
            if isinstance(response, DLMSGetResponseNormal) and response.data is not None:
                dt, _ = DateTime.from_bytes(response.data.value).to_python()
                await stream.send_message(
                    meter_pb2.StringValue(value=dt.strftime("%Y-%m-%d %H:%M:%S"))
                )
                return
        await stream.send_message(meter_pb2.StringValue(value="ERROR"))

    @grpc_exception_handler
    async def SetClock(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to set clock")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        set_clock_response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 2,
                DateTime(value=(datetime.fromisoformat(front_request.value), None))
                .to_octet_string().to_bytes(),
            ),
        )
        await stream.send_message(meter_pb2.BoolValue(value=set_clock_response.is_success()))

    @grpc_exception_handler
    async def GetIncrementalDate(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock object not found in datamodel")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 5),
        )
        if not isinstance(response, DLMSGetResponseNormal) or response.data is None:
            raise Exception("Failed to read incremental date from meter")
        datetime_structure = response.data.to_python()
        year = get_optional_value(int.from_bytes(datetime_structure[:2], "big"), b"\xff\xff")
        month = get_optional_value(datetime_structure[2], b"\xff")
        day_of_month = get_optional_value(datetime_structure[3], b"\xff")
        day_of_week = get_optional_value(datetime_structure[4], b"\xff")
        hour = get_optional_value(datetime_structure[5], b"\xff", replace_with=0)
        minute = get_optional_value(datetime_structure[6], b"\xff", replace_with=0)
        seconds = get_optional_value(datetime_structure[7], b"\xff", replace_with=0)
        await stream.send_message(meter_pb2.DaylightSavingsTime(
            day=day_of_month, month=month, hour=hour,
            minute=minute, second=seconds, dayOfWeek=day_of_week,
        ))

    @grpc_exception_handler
    async def SetIncrementalDate(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify meter configuration")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        incremental_date = bytearray()
        incremental_date.extend(b"\xff\xff")
        incremental_date.extend(front_request.month.to_bytes(1, byteorder="big"))
        incremental_date.extend(front_request.day.to_bytes(1, byteorder="big"))
        incremental_date.extend(front_request.dayOfWeek.to_bytes(1, byteorder="big"))
        incremental_date.extend(front_request.hour.to_bytes(1, byteorder="big"))
        incremental_date.extend(front_request.minute.to_bytes(1, byteorder="big"))
        incremental_date.extend(front_request.second.to_bytes(1, byteorder="big"))
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 5,
                OctetStringData(value=incremental_date).to_bytes(),
            ),
        )
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

    @grpc_exception_handler
    async def GetDecrementalDate(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock object not found in datamodel")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 6),
        )
        if not isinstance(response, DLMSGetResponseNormal) or response.data is None:
            raise Exception("Failed to read decremental date from meter")
        datetime_structure = response.data.to_python()
        year = get_optional_value(int.from_bytes(datetime_structure[:2], "big"), b"\xff\xff")
        month = get_optional_value(datetime_structure[2], b"\xff")
        day_of_month = get_optional_value(datetime_structure[3], b"\xff")
        day_of_week = get_optional_value(datetime_structure[4], b"\xff")
        hour = get_optional_value(datetime_structure[5], b"\xff", replace_with=0)
        minute = get_optional_value(datetime_structure[6], b"\xff", replace_with=0)
        seconds = get_optional_value(datetime_structure[7], b"\xff", replace_with=0)
        await stream.send_message(meter_pb2.DaylightSavingsTime(
            day=day_of_month, month=month, hour=hour,
            minute=minute, second=seconds, dayOfWeek=day_of_week,
        ))

    @grpc_exception_handler
    async def SetDecrementalDate(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify meter configuration")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        decremental_date = bytearray()
        decremental_date.extend(b"\xff\xff")
        decremental_date.extend(front_request.month.to_bytes(1, byteorder="big"))
        decremental_date.extend(front_request.day.to_bytes(1, byteorder="big"))
        decremental_date.extend(front_request.dayOfWeek.to_bytes(1, byteorder="big"))
        decremental_date.extend(front_request.hour.to_bytes(1, byteorder="big"))
        decremental_date.extend(front_request.minute.to_bytes(1, byteorder="big"))
        decremental_date.extend(front_request.second.to_bytes(1, byteorder="big"))
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 6,
                OctetStringData(value=decremental_date).to_bytes(),
            ),
        )
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

    @grpc_exception_handler
    async def GetDaylightSavingDeviation(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 7),
        )
        if not isinstance(response, DLMSGetResponseNormal) or not response.is_success():
            raise Exception("Failed to read deviation from meter")
        await stream.send_message(meter_pb2.Int32Value(value=response.data.to_python()))

    @grpc_exception_handler
    async def SetDaylightSavingDeviation(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify meter configuration")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 7,
                Integer8(value=front_request.value).to_bytes(),
            ),
        )
        if not isinstance(response, DLMSSetResponseNormal):
            raise Exception("Failed to set deviation on meter")
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

    @grpc_exception_handler
    async def GetDaylightSavingActivation(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 8),
        )
        if not isinstance(response, DLMSGetResponseNormal) or not response.is_success():
            raise Exception("Failed to read DST activation from meter")
        await stream.send_message(meter_pb2.BoolValue(value=response.data.to_python()))

    @grpc_exception_handler
    async def SetDaylightSavingActivation(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify meter configuration")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 8,
                BooleanData(value=front_request.value).to_bytes(),
            ),
        )
        if not isinstance(response, DLMSSetResponseNormal):
            raise Exception("Failed to set DST activation on meter")
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

    @grpc_exception_handler
    async def GetTimezone(self, stream):
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(clock_object["classId"], clock_object["logicalName_hex"], 3),
        )
        if not isinstance(response, DLMSGetResponseNormal) or not response.is_success():
            raise Exception("Failed to read timezone from meter")
        await stream.send_message(meter_pb2.Int32Value(value=response.data.to_python()))

    @grpc_exception_handler
    async def SetTimezone(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify meter configuration")
        clock_object = self._get_clock_object()
        if clock_object is None:
            raise Exception("Clock not found")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                clock_object["classId"], clock_object["logicalName_hex"], 3,
                Integer16(value=front_request.value).to_bytes(),
            ),
        )
        if not isinstance(response, DLMSSetResponseNormal):
            raise Exception("Failed to set timezone on meter")
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

