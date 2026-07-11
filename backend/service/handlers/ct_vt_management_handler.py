from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_32 import Integer32
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from google.protobuf import empty_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.grpc_exception import grpc_exception_handler
from gen import meter_pb2

class CTVTManagementHandler(BaseHandler):
    @grpc_exception_handler
    # object name PrimaryValueCT
    async def GetPrimaryCt(self, stream):
        obj = self._get_object_from_datamodel("PrimaryValueCT")
        value_attr = self._get_attribute_from_object(obj,"value")

        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"])),
        )

        self._verify_get_response(response)
        await stream.send_message(
                meter_pb2.Int32Value(value=response.data.to_python())
        )

    @grpc_exception_handler
    async def SetPrimaryCt(self, stream):
        obj = self._get_object_from_datamodel("PrimaryValueCT")
        value_attr = self._get_attribute_from_object(obj, "value")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"]),Integer32(value=front_request.value).to_bytes()),
        )
        self._verify_set_response(response)
        await stream.send_message(
            empty_pb2.Empty()
        )

    @grpc_exception_handler
    # object name PrimaryValueCT
    async def GetSecondaryCt(self, stream):
        obj = self._get_object_from_datamodel("SecondaryValueCT")
        value_attr = self._get_attribute_from_object(obj, "value")

        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"])),
        )

        self._verify_get_response(response)
        await stream.send_message(
            meter_pb2.Int32Value(value=response.data.to_python())
        )

    @grpc_exception_handler
    async def SetSecondaryCt(self, stream):
        obj = self._get_object_from_datamodel("SecondaryValueCT")
        value_attr = self._get_attribute_from_object(obj, "value")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"]),
                                 Integer32(value=front_request.value).to_bytes()),
        )
        self._verify_set_response(response)
        await stream.send_message(
            empty_pb2.Empty()
        )


    @grpc_exception_handler
    # object name PrimaryValueCT
    async def GetPrimaryVt(self, stream):
        obj = self._get_object_from_datamodel("PrimaryValuevT")
        value_attr = self._get_attribute_from_object(obj, "value")

        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"])),
        )

        self._verify_get_response(response)
        await stream.send_message(
            meter_pb2.Int32Value(value=response.data.to_python())
        )

    @grpc_exception_handler
    async def SetPrimaryVt(self, stream):
        obj = self._get_object_from_datamodel("PrimaryValuevT")
        value_attr = self._get_attribute_from_object(obj, "value")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"]),
                                 Integer32(value=front_request.value).to_bytes()),
        )
        self._verify_set_response(response)
        await stream.send_message(
            empty_pb2.Empty()
        )

    @grpc_exception_handler
    # object name PrimaryValueCT
    async def GetRatioValueVt(self, stream):
        obj = self._get_object_from_datamodel("SecondaryValueVT")
        value_attr = self._get_attribute_from_object(obj, "value")

        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"])),
        )

        self._verify_get_response(response)
        await stream.send_message(
            meter_pb2.Int32Value(value=response.data.to_python())
        )

    @grpc_exception_handler
    async def SetRatioValueVt(self, stream):
        obj = self._get_object_from_datamodel("SecondaryValueVT")
        value_attr = self._get_attribute_from_object(obj, "value")
        front_request = await stream.recv_message()
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], int(value_attr["id"]),
                                 Integer32(value=front_request.value).to_bytes()),
        )
        self._verify_set_response(response)
        await stream.send_message(
            empty_pb2.Empty()
        )


