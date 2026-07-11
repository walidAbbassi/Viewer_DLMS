from google.protobuf import empty_pb2
from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.data_type.abstract_dlms_type import DLMS_TYPE_REGISTRY
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.grpc_exception import grpc_exception_handler


class QualityHandler(BaseHandler):

    @grpc_exception_handler
    async def GetQualityObjects(self, stream):
        request  = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        dlms_requests = []
        for obj in request.objects:
            data_model_obj = next((item for item in data_model if item["name"] == obj), None)
            if data_model_obj is  None:
                raise Exception(f"{obj}: object not found in datamodel")
            # get value
            dlms_requests.append(DLMSGetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 2))
            # get scaler unit
            dlms_requests.append(DLMSGetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 3))

        dlms_response = await self._run(
            MeterContext.frame_executor.execute_list,
            dlms_requests,
        )

        response = []
        counter = 0
        for i, obj in enumerate(request.objects):
            result = dlms_response.result[i+counter]
            counter = counter + 1
            scaler_unit = dlms_response.result[i+counter]

            value = -1
            unit = "unknown"
            scaler_ = 0
            if result.data_access_result == DataAccessResult.SUCCESS and result.data is not None:
                value = result.data.to_python()
                if scaler_unit.data_access_result == DataAccessResult.SUCCESS and scaler_unit.data is not None:

                    elements = scaler_unit.data.to_python()
                    if len(elements) >= 2:
                        scaler, unit_code = elements[0], elements[1]
                        scaler_ = scaler
                        if isinstance(value, (int, float)):
                            value = value * (10 ** scaler)
                        unit = MeterContext.configuration.units.get(str(unit_code), unit)
            else :
                unit = result.data_access_result.name
            response.append(meter_pb2.QualityObject(name = obj,value = value,unit = unit,scaler=scaler_ ))
        await stream.send_message(meter_pb2.GetQualityObjectsResponse(objects=response))

    @grpc_exception_handler
    async def UpdateQualityObject(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        data_model_obj = next((item for item in data_model if item["name"] == request.datasource), None)
        if data_model_obj is None:
            raise Exception(f"{request.datasource}: object not found in datamodel")
        value = int(round(request.value * (10 ** -request.scaler)))
        dlms_response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 2,Unsigned16(value=value).to_bytes()),
        )
        self._verify_set_response(dlms_response)
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def ReadQualityConfig(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        data_model_obj = next((item for item in data_model if item["name"] == request.data_source), None)
        if data_model_obj is None:
            raise Exception(f"{request.data_source}: object not found in datamodel")

        dlms_response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 2)
        )
        self._verify_get_response(dlms_response)
        if isinstance(dlms_response.data,StructureData):
            values = []
            for item in dlms_response.data.value:
                values.append(meter_pb2.QualityConfigValue(value = item.to_python(),type = item.XML_TAG))
            await stream.send_message(meter_pb2.ReadQualityConfigResponse(values = meter_pb2.QualityConfigValues(values =values)))
        else :
            await stream.send_message(meter_pb2.ReadQualityConfigResponse(value = meter_pb2.QualityConfigValue(value = dlms_response.data.to_python(),type = dlms_response.data.XML_TAG)))

    @grpc_exception_handler
    async def WriteQualityConfig(self, stream):
        request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        data_model_obj = next((item for item in data_model if item["name"] == request.data_source), None)
        if data_model_obj is None:
            raise Exception(f"{request.data_source}: object not found in datamodel")
        field = request.WhichOneof("payload")
        if field == "value":
            cls = DLMS_TYPE_REGISTRY.get(request.value.type)
            value = cls(value=request.value.value)
            dlms_response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 2,value.to_bytes())
            )
            self._verify_set_response(dlms_response)
        elif field == "values":
            values = []
            for item in request.values.values:
                cls = DLMS_TYPE_REGISTRY.get(item.type)
                value = cls(value=item.value)
                values.append(value)
            dlms_response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(data_model_obj["classId"], data_model_obj["logicalName_hex"], 2, StructureData(value=values).to_bytes())
            )
            self._verify_set_response(dlms_response)
        await stream.send_message(empty_pb2.Empty())










