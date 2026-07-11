"""
DlmsExecutionHandler — ExecuteGet/Set/Action (simple & avancé), BlockSize,
TranslateData, GetDatamodel*, GetDatamodels, LoadDatamodel, GetObjectWriteRights.
SRP : toutes les opérations DLMS génériques passées directement par le frontend.
"""
import json
import xml.etree.ElementTree as ET

from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import DLMSActionRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_list import DLMSActionResponseWithList
from ng_sdk.frame_builder.dlms.xdlms.data_type.date_time import DateTime
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32 import Unsigned32
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_list import DLMSGetResponseWithList
from ng_sdk.frame_builder.dlms.xdlms.selective_access.capture_object_definition import CaptureObjectDefinition
from ng_sdk.frame_builder.dlms.xdlms.selective_access.entry_selective_access import EntrySelectiveAccess
from ng_sdk.frame_builder.dlms.xdlms.selective_access.range_selective_access import RangeSelectiveAccess
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_with_list import DLMSSetResponseWithList
from ng_sdk.frame_executor.models.application_response import ApplicationResponse
from ng_sdk.util.xml_data_type_parser import parse_dlms_xml
from ng_sdk.frame_builder.dlms.xdlms.data_type.dlms_parser import DlmsDataParser
from ng_sdk.configuration.config_manager import ConfigModuleProxy

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler
from utils_any import python_to_any
from utils_configuration import get_configuration_value


class DlmsExecutionHandler(BaseHandler):
    """Opérations DLMS génériques : Execute*/Advanced*, BlockSize, Datamodel, TranslateData."""

    @grpc_exception_handler
    async def ExecuteGet(self, stream):
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            access_selector = None
            selector = request.WhichOneof("access_selector")
            if selector == "datetime_selector":
                dt_range = request.datetime_selector
                start = dt_range.start.ToDatetime()
                end = dt_range.end.ToDatetime()
                capture_object_definition = CaptureObjectDefinition(
                    1, bytes.fromhex("0000010000FF"), 2, 0
                )
                access_selector = RangeSelectiveAccess(
                    DateTime(value=(start, None)).to_octet_string(),
                    DateTime(value=(end, None)).to_octet_string(),
                    capture_object_definition,
                )
            elif selector == "entry_selector":
                entry = request.entry_selector
                access_selector = EntrySelectiveAccess(
                    Unsigned32(entry.entry_from),
                    Unsigned32(entry.entry_to),
                    Unsigned16(entry.selected_from),
                    Unsigned16(entry.selected_to),
                )
            get_request = DLMSGetRequestNormal(
                request.class_, request.obiscode, request.attribute, access_selector
            )
            requests.append(get_request)

        responses = []
        if front_request.with_list:
            with_list_response: DLMSGetResponseWithList = (
                MeterContext.frame_executor.execute_list(requests)
            )
            for i, response in enumerate(with_list_response.result):
                request = requests[i]
                back_request = meter_pb2.AbstractFrameRequest(
                    get_request=meter_pb2.GetRequest(
                        class_=request.class_id,
                        obiscode=request.obis_code,
                        attribute=request.attribute,
                    )
                )
                xml_xdr = xdr = ""
                if response.data_access_result == DataAccessResult.SUCCESS and response.data is not None:
                    xml_xdr = ET.tostring(response.data.to_xml(), "utf-8")
                    xdr = response.data.to_bytes().hex().upper()
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr=xdr, xml_xdr=xml_xdr,
                    success=response.data_access_result == DataAccessResult.SUCCESS,
                    error="" if response.data_access_result == DataAccessResult.SUCCESS
                    else response.data_access_result.name,
                ))
        else:
            for request in requests:
                application_response: DLMSGetResponseNormal = await self._run(
                    MeterContext.frame_executor.execute, request
                )
                back_request = meter_pb2.AbstractFrameRequest(
                    get_request=meter_pb2.GetRequest(
                        class_=request.class_id,
                        obiscode=request.obis_code,
                        attribute=request.attribute,
                    )
                )
                xml_xdr = xdr = ""
                if application_response.is_success() and application_response.data is not None:
                    xml_xdr = ET.tostring(application_response.data.to_xml(), "utf-8")
                    xdr = application_response.data.to_bytes().hex().upper()
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr=xdr, xml_xdr=xml_xdr,
                    success=application_response.is_success(),
                    error="" if application_response.is_success()
                    else application_response.data_access_result.name,
                ))
        await stream.send_message(meter_pb2.FrameExecutionList(items=responses))

    @grpc_exception_handler
    async def ExecuteSet(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            requests.append(DLMSSetRequestNormal(
                request.class_, request.obiscode, request.attribute,
                bytes.fromhex(request.payload),
            ))
        responses = []
        if front_request.with_list:
            application_responses: DLMSSetResponseWithList = (
                MeterContext.frame_executor.execute_list(requests)
            )
            for i, application_response in enumerate(application_responses.result):
                request = requests[i]
                back_request = meter_pb2.AbstractFrameRequest(
                    set_request=meter_pb2.SetRequest(
                        class_=request.class_id, obiscode=request.obis_code,
                        attribute=request.attribute,
                        payload=request.payload.hex().upper(),
                    )
                )
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr="", xml_xdr="",
                    success=application_response == DataAccessResult.SUCCESS,
                    error="" if application_response == DataAccessResult.SUCCESS
                    else application_response.name,
                ))
        else:
            for request in requests:
                application_response = await self._run(
                    MeterContext.frame_executor.execute, request
                )
                back_request = meter_pb2.AbstractFrameRequest(
                    set_request=meter_pb2.SetRequest(
                        class_=request.class_id, obiscode=request.obis_code,
                        attribute=request.attribute,
                        payload=request.payload.hex().upper(),
                    )
                )
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr="", xml_xdr="",
                    success=application_response.is_success(),
                    error="" if application_response.is_success()
                    else application_response.data_access_result.name,
                ))
        await stream.send_message(meter_pb2.FrameExecutionList(items=responses))

    @grpc_exception_handler
    async def ExecuteAction(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to execute ACTION operations")
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            requests.append(DLMSActionRequestNormal(
                request.class_, request.obiscode, request.attribute,
                None if not (request.payload and request.payload.strip())
                else bytes.fromhex(request.payload),
            ))
        responses = []
        if front_request.with_list:
            application_responses: DLMSActionResponseWithList = (
                MeterContext.frame_executor.execute_list(requests)
            )
            for i, application_response in enumerate(application_responses.list_of_responses):
                request = requests[i]
                back_request = meter_pb2.AbstractFrameRequest(
                    action_request=meter_pb2.ActionRequest(
                        class_=request.class_id, obiscode=request.obis_code,
                        attribute=request.attribute,
                        payload=request.payload.hex().upper() if request.payload else "",
                    )
                )
                xml_xdr = xdr = ""
                if (
                    application_response.result == DataAccessResult.SUCCESS
                    and application_response.return_parameter.data is not None
                ):
                    xml_xdr = ET.tostring(application_response.return_parameter.data.to_xml(), "utf-8")
                    xdr = application_response.return_parameter.data.to_bytes().hex().upper()
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr=xdr, xml_xdr=xml_xdr,
                    success=application_response.result == DataAccessResult.SUCCESS,
                    error="" if application_response.result == DataAccessResult.SUCCESS
                    else application_response.result.name,
                ))
        else:
            for request in requests:
                application_response = await self._run(
                    MeterContext.frame_executor.execute, request
                )
                back_request = meter_pb2.AbstractFrameRequest(
                    action_request=meter_pb2.ActionRequest(
                        class_=request.class_id, obiscode=request.obis_code,
                        attribute=request.attribute,
                        payload=request.payload.hex().upper() if request.payload else "",
                    )
                )
                xml_xdr = xdr = ""
                if (
                    application_response.is_success()
                    and application_response.return_parameter.data is not None
                ):
                    xml_xdr = ET.tostring(application_response.return_parameter.data.to_xml(), "utf-8")
                    xdr = application_response.return_parameter.data.to_bytes().hex().upper()
                responses.append(meter_pb2.FrameExecutionItem(
                    request=back_request, xdr=xdr, xml_xdr=xml_xdr,
                    success=application_response.is_success(),
                    error="" if application_response.is_success()
                    else application_response.data_access_result.name,
                ))
        await stream.send_message(meter_pb2.FrameExecutionList(items=responses))

    @grpc_exception_handler
    async def ExecuteAdvancedGet(self, stream):
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            requests.append(DLMSGetRequestNormal(
                request.class_, request.obiscode, request.attribute
            ))
        application_responses: list[ApplicationResponse] = []
        if front_request.with_list:
            application_responses = MeterContext.frame_executor.advanced_execute_list(requests)
        else:
            for request in requests:
                application_responses.append(MeterContext.frame_executor.advanced_execute(request))
        responses = []
        for ar in application_responses:
            back_request = meter_pb2.AbstractFrameRequest(
                get_request=meter_pb2.GetRequest(
                    class_=ar.request.class_id,
                    obiscode=ar.request.obis_code,
                    attribute=ar.request.attribute,
                )
            )
            responses.append(meter_pb2.ApplicationResponse(
                request=back_request,
                value=python_to_any(ar.value),
                error=ar.error,
                status_code=ar.status_code,
            ))
        await stream.send_message(meter_pb2.ApplicationResponseList(responses=responses))

    @grpc_exception_handler
    async def ExecuteAdvancedAction(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to execute ACTION operations")
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            requests.append(DLMSActionRequestNormal(
                request.class_, request.obiscode, request.attribute,
                None if not request.payload or request.payload.strip()
                else bytes.fromhex(request.payload),
            ))
        application_responses: list[ApplicationResponse] = []
        if front_request.with_list:
            application_responses = MeterContext.frame_executor.advanced_execute_list(requests)
        else:
            for request in requests:
                application_responses.append(MeterContext.frame_executor.advanced_execute(request))
        responses = []
        for ar in application_responses:
            back_request = meter_pb2.AbstractFrameRequest(
                action_request=meter_pb2.ActionRequest(
                    class_=ar.request.class_id,
                    obiscode=ar.request.obis_code,
                    attribute=ar.request.attribute,
                    payload=ar.request.payload.hex().upper() if ar.request.payload else "",
                )
            )
            responses.append(meter_pb2.ApplicationResponse(
                request=back_request,
                value=python_to_any(ar.value),
                error=ar.error,
                status_code=ar.status_code,
            ))
        await stream.send_message(meter_pb2.ApplicationResponseList(responses=responses))

    @grpc_exception_handler
    async def ExecuteAdvancedSet(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        requests = []
        front_request = await stream.recv_message()
        for request in front_request.requests:
            requests.append(DLMSSetRequestNormal(
                request.class_, request.obiscode, request.attribute,
                bytes.fromhex(request.payload),
            ))
        application_responses: list[ApplicationResponse] = []
        if front_request.with_list:
            application_responses = MeterContext.frame_executor.advanced_execute_list(requests)
        else:
            for request in requests:
                application_responses.append(MeterContext.frame_executor.advanced_execute(request))
        responses = []
        for ar in application_responses:
            back_request = meter_pb2.AbstractFrameRequest(
                set_request=meter_pb2.SetRequest(
                    class_=ar.request.class_id,
                    obiscode=ar.request.obis_code,
                    attribute=ar.request.attribute,
                    payload=ar.request.payload.hex().upper(),
                )
            )
            responses.append(meter_pb2.ApplicationResponse(
                request=back_request,
                value=python_to_any(ar.value),
                error=ar.error,
                status_code=ar.status_code,
            ))
        await stream.send_message(meter_pb2.ApplicationResponseList(responses=responses))

    @grpc_exception_handler
    async def GetBlockSize(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to set block size")
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == "ImageTransfer"), None)
        if obj is None:
            raise Exception("SetBlockSize: ImageTransfer Object not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2),
        )
        image_block_size = None
        if isinstance(response, DLMSGetResponseNormal):
            image_block_size = response.data.value
        if image_block_size is None:
            await stream.send_message(meter_pb2.Int32Value(value=0))
        else:
            await stream.send_message(meter_pb2.Int32Value(value=response.data.value))

    @grpc_exception_handler
    async def SetBlockSize(self, stream):
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == "ImageTransfer"), None)
        if obj is None:
            raise Exception("SetBlockSize: ImageTransfer Object not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                obj["classId"], obj["logicalName_hex"], 2,
                Unsigned32(value=front_request.value).to_bytes(),
            ),
        )
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))

    @grpc_exception_handler
    async def GetDatamodelObjects(self, stream):
        await stream.recv_message()
        objects = []
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        for obj in data_model:
            objects.append(meter_pb2.DatamodelObject(
                name=obj["name"],
                classId=obj["classId"],
                logicalName=obj["logicalName"],
                logicalName_hex=obj["logicalName_hex"],
                description=obj.get("description"),
            ))
        await stream.send_message(meter_pb2.GetDatamodelObjectsResponse(objects=objects))

    @grpc_exception_handler
    async def GetDatamodelAttributesByObjectName(self, stream):
        front_request = await stream.recv_message()
        attributes = []
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == front_request.objectName), None)
        for attribute in obj["dlmsAttribute"]:
            access_right = ""
            for key in attribute["accessRights"]:
                option = attribute["accessRights"][key]
                if option["name"] == front_request.clientName:
                    access_right = get_configuration_value(option["accessRights"], "")
            attributes.append(meter_pb2.DatamodelAttribute(
                id=int(attribute["id"]),
                name=attribute["name"],
                description=attribute.get("description", ""),
                type=attribute["dlmsType"]["type"],
                accessRights=access_right,
            ))
        await stream.send_message(
            meter_pb2.GetDatamodelAttributesByObjectNameResponse(attributes=attributes)
        )

    @grpc_exception_handler
    async def TranslateData(self, stream):
        front_request = await stream.recv_message()
        responses = []
        parser: DlmsDataParser = DlmsDataParser()
        for item in front_request.requests:
            if item.is_xdr_input:
                try:
                    parsed_data = parser.parse(bytes.fromhex(item.data), False, 1)
                    responses.append(meter_pb2.TranslateDataItemResponse(
                        input=item.data,
                        output=ET.tostring(parsed_data[0].to_xml(), "utf-8"),
                        is_xdr_input=item.is_xdr_input,
                        success=True, error="",
                    ))
                except Exception as e:
                    responses.append(meter_pb2.TranslateDataItemResponse(
                        input=item.data, output="",
                        is_xdr_input=item.is_xdr_input,
                        success=False, error=str(e),
                    ))
            else:
                try:
                    parsed_data = parse_dlms_xml(item.data)
                    responses.append(meter_pb2.TranslateDataItemResponse(
                        input=item.data,
                        output=parsed_data.to_bytes().hex().upper(),
                        is_xdr_input=item.is_xdr_input,
                        success=True, error="",
                    ))
                except Exception as e:
                    responses.append(meter_pb2.TranslateDataItemResponse(
                        input=item.data, output="",
                        is_xdr_input=item.is_xdr_input,
                        success=False, error=str(e),
                    ))
        await stream.send_message(meter_pb2.TranslateDataResponse(items=responses))

    @grpc_exception_handler
    async def GetDatamodels(self, stream):
        datamodels = MeterContext.configuration.datamodel.files()
        await stream.send_message(meter_pb2.StringList(items=datamodels))

    @grpc_exception_handler
    async def LoadDatamodel(self, stream):
        front_request = await stream.recv_message()
        MeterContext.datamodel = front_request.datamodel
        datamodel = MeterContext.configuration.datamodel[MeterContext.datamodel]
        await stream.send_message(
            meter_pb2.BoolValue(value=not isinstance(datamodel.objects, ConfigModuleProxy))
        )

    @grpc_exception_handler
    async def GetObjectWriteRights(self, stream):
        req = await stream.recv_message()
        class_id = req.value
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == class_id), None)
        rights = {}
        if obj and MeterContext.module_name:
            module_lower = MeterContext.module_name.lower()
            for attr in obj.get("dlmsAttribute", []):
                attr_id = str(attr.get("id", 0))
                for entry in attr.get("accessRights", {}).values():
                    if entry.get("name", "").lower() == module_lower:
                        ar = entry.get("accessRights", "").lower()
                        rights[attr_id] = "set" in ar
                        break
        await stream.send_message(meter_pb2.StringValue(value=json.dumps(rights)))

