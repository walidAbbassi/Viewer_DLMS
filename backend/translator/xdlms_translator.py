from xml.etree.ElementTree import Element

from ng_sdk.frame_builder.dlms.dlms_enums import (
    Command,
    GetResponseType,
    SetResponseType,
    ActionResponseType,
    GetRequestType,
    SetRequestType,
    ActionRequestType,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_next_pblock import (
    DLMSActionResponseNextPblock,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import (
    DLMSActionResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_list import (
    DLMSActionResponseWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_pblock import (
    DLMSActionResponseWithPblock,
)
from ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response import (
    DLMSExceptionResponse,
)
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import (
    DLMSGetResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_datablock import (
    DLMSGetResponseWithDatablock,
)
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_list import (
    DLMSGetResponseWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_datablock import (
    DLMSSetResponseDatablock,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_last_datablock import (
    DLMSSetResponseLastDatablock,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_last_datablock_with_list import (
    DLMSSetResponseLastDatablockWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal import (
    DLMSSetResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_with_list import (
    DLMSSetResponseWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.data_type.dlms_parser import DlmsDataParser

from translator.abstract_translator import AbstractTranslator


class XDLMSTranslator(AbstractTranslator):

    def _decode_selective_access(self, frame: bytearray) -> Element | None:
        has_selective_access = frame.pop(0)
        if has_selective_access != 0x01:
            return None
        access_selector = frame.pop(0)
        selective_access_element = Element("selective_access")
        selector_element = Element("access_selector")
        selector_element.text = str(access_selector)
        selective_access_element.append(selector_element)
        if access_selector == 0x01:
            frame.pop(0)  # structure tag
            frame.pop(0)  # length
            frame.pop(0)  # inner structure tag
            frame.pop(0)  # inner structure length
            restricting_obj_element = Element("restricting_object")
            class_id_val = int.from_bytes(frame[:3], "big") & 0xFFFF
            del frame[:3]
            obis_val = frame[:7]
            del frame[:7]
            attr_val = frame[:2]
            del frame[:2]
            idx_val = int.from_bytes(frame[:3], "big") & 0xFFFF
            del frame[:3]
            ro_class_id = Element("class_id")
            ro_class_id.text = str(class_id_val)
            restricting_obj_element.append(ro_class_id)
            ro_obis = Element("logical_name")
            ro_obis.text = bytes(obis_val[1:]).hex().upper()
            restricting_obj_element.append(ro_obis)
            ro_attr = Element("attribute_index")
            ro_attr.text = str(int.from_bytes(attr_val[1:], "big", signed=True))
            restricting_obj_element.append(ro_attr)
            ro_idx = Element("data_index")
            ro_idx.text = str(idx_val)
            restricting_obj_element.append(ro_idx)
            selective_access_element.append(restricting_obj_element)
            parser = DlmsDataParser()
            parser.parse(bytes(frame), limit=2)
            from_element = Element("from_value")
            from_element.append(parser.data[0].to_xml())
            selective_access_element.append(from_element)
            to_element = Element("to_value")
            to_element.append(parser.data[1].to_xml())
            selective_access_element.append(to_element)
        elif access_selector == 0x02:
            frame.pop(0)  # structure tag
            frame.pop(0)  # length
            parser = DlmsDataParser()
            parser.parse(bytes(frame), limit=4)
            from_entry_element = Element("from_entry")
            from_entry_element.append(parser.data[0].to_xml())
            selective_access_element.append(from_entry_element)
            to_entry_element = Element("to_entry")
            to_entry_element.append(parser.data[1].to_xml())
            selective_access_element.append(to_entry_element)
            from_selected_element = Element("from_selected_value")
            from_selected_element.append(parser.data[2].to_xml())
            selective_access_element.append(from_selected_element)
            to_selected_element = Element("to_selected_value")
            to_selected_element.append(parser.data[3].to_xml())
            selective_access_element.append(to_selected_element)
        return selective_access_element

    def _decode_cosem_descriptor(self, frame: bytearray) -> Element:
        descriptor_element = Element("descriptor")
        class_id_element = Element("class_id")
        class_id_element.text = str(int.from_bytes(frame[:2], "big"))
        del frame[:2]
        descriptor_element.append(class_id_element)
        obis_code_element = Element("obis_code")
        obis_code_element.text = frame[:6].hex().upper()
        del frame[:6]
        descriptor_element.append(obis_code_element)
        attribute_element = Element("attribute")
        attribute_element.text = str(frame.pop(0))
        descriptor_element.append(attribute_element)
        selective_access = self._decode_selective_access(frame)
        if selective_access is not None:
            descriptor_element.append(selective_access)
        return descriptor_element

    def _decode_datablock(self, frame: bytearray) -> Element:
        datablock_element = Element("datablock")
        last_block_element = Element("last_block")
        last_block_element.text = str(bool(frame.pop(0)))
        datablock_element.append(last_block_element)
        block_number_element = Element("block_number")
        block_number_element.text = str(int.from_bytes(frame[:4], "big"))
        del frame[:4]
        datablock_element.append(block_number_element)
        raw_data_length = frame.pop(0)
        raw_data_element = Element("raw_data")
        raw_data_element.text = bytes(frame[:raw_data_length]).hex().upper()
        datablock_element.append(raw_data_element)
        return datablock_element

    def translate(self, input_data: bytes) -> Element:
        frame = bytearray(input_data)
        command_type = Command(frame.pop(0))
        if command_type == Command.EXCEPTION_RESPONSE:
            response = DLMSExceptionResponse(frame)
            root = Element("dlms_exception")
            state_error_element = Element("state_error")
            state_error_element.text = (
                response.state_error.name if response.state_error is not None else "N/A"
            )
            service_error_element = Element("service_error")
            service_error_element.text = (
                response.service_error.name
                if response.service_error is not None
                else "N/A"
            )
            root.append(state_error_element)
            root.append(service_error_element)
            return root
        if command_type == Command.GET_RESPONSE:
            response_get_type = GetResponseType(frame.pop(0))
            match response_get_type:
                case GetResponseType.NORMAL:
                    response = DLMSGetResponseNormal(frame)
                    root = Element("get_response_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    if response.data_access_result is not None:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            response.data_access_result.name
                        )
                        root.append(data_access_result_element)
                    if hasattr(response,"data") and response.data  is not None:
                        root.append(response.data.to_xml())
                    return root
                case GetResponseType.NEXT:
                    response = DLMSGetResponseWithDatablock(frame)
                    root = Element("get_response_with_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    last_block_element = Element("last_block")
                    last_block_element.text = str(response.result.last_block)
                    root.append(last_block_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.result.block_number)
                    root.append(block_number_element)
                    if response.result.data_access_result is not None:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            response.result.data_access_result.name
                        )
                        root.append(data_access_result_element)
                    raw_data_element = Element("raw_data")
                    raw_data_element.text = response.result.raw_data.hex().upper()
                    root.append(raw_data_element)
                    return root
                case GetResponseType.WITH_LIST:
                    response = DLMSGetResponseWithList(frame)
                    root = Element("get_response_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    data_element = Element("data")
                    for item in response.result:
                        item_element = Element("item")
                        if item.data_access_result is not None:
                            data_access_result_element = Element("data_access_result")
                            data_access_result_element.text = (
                                item.data_access_result.name
                            )
                            item_element.append(data_access_result_element)
                        if item.data is not None:
                            item_element.append(item.data.to_xml())
                        data_element.append(item_element)
                    root.append(data_element)
                    return root
        if command_type == Command.SET_RESPONSE:
            response_set_type = SetResponseType(frame.pop(0))
            match response_set_type:
                case SetResponseType.NORMAL:
                    response = DLMSSetResponseNormal(frame)
                    root = Element("set_response_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    if response.data_access_result is not None:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            response.data_access_result.name
                        )
                        root.append(data_access_result_element)
                    return root
                case SetResponseType.WITH_LIST:
                    response = DLMSSetResponseWithList(frame)
                    root = Element("set_response_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    results_element = Element("results")
                    for item in response.result:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            item.name if item is not None else "N/A"
                        )
                        results_element.append(data_access_result_element)
                    root.append(results_element)
                    return root
                case SetResponseType.DATABLOCK:
                    response = DLMSSetResponseDatablock(frame)
                    root = Element("set_response_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.block_number)
                    root.append(block_number_element)
                    return root
                case SetResponseType.LAST_DATABLOCK:
                    response = DLMSSetResponseLastDatablock(frame)
                    root = Element("set_response_last_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.block_number)
                    root.append(block_number_element)
                    if response.data_access_result is not None:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            response.data_access_result.name
                        )
                        root.append(data_access_result_element)
                    return root
                case SetResponseType.LAST_DATABLOCK_WITH_LIST:
                    response = DLMSSetResponseLastDatablockWithList(frame)
                    root = Element("set_response_last_datablock_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.block_number)
                    root.append(block_number_element)
                    results_element = Element("results")
                    for item in response.result:
                        data_access_result_element = Element("data_access_result")
                        data_access_result_element.text = (
                            item.name if item is not None else "N/A"
                        )
                        results_element.append(data_access_result_element)
                    root.append(results_element)
                    return root
        if command_type == Command.ACTION_RESPONSE:
            response_action_type = ActionResponseType(frame.pop(0))
            match response_action_type:
                case ActionResponseType.NORMAL:
                    response = DLMSActionResponseNormal(frame)
                    root = Element("action_response_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    if response.result is not None:
                        result_element = Element("result")
                        result_element.text = response.result.name
                        root.append(result_element)
                    if hasattr(response, 'return_parameter') and response.return_parameter is not None:
                        return_parameter_element = Element("return_parameter")
                        if response.return_parameter.data_access_result is not None:
                            data_access_result_element = Element("data_access_result")
                            data_access_result_element.text = (
                                response.return_parameter.data_access_result.name
                            )
                            return_parameter_element.append(data_access_result_element)
                        if response.return_parameter.data is not None:
                            return_parameter_element.append(
                                response.return_parameter.data.to_xml()
                            )
                        root.append(return_parameter_element)
                    return root
                case ActionResponseType.WITH_LIST:
                    response = DLMSActionResponseWithList(frame)
                    root = Element("action_response_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    list_of_responses_element = Element("list_of_responses")
                    for item in response.list_of_responses:
                        item_element = Element("item")
                        if item.result is not None:
                            result_element = Element("result")
                            result_element.text = item.result.name
                            item_element.append(result_element)
                        if item.return_parameter is not None:
                            return_parameter_element = Element("return_parameter")
                            if item.return_parameter.data_access_result is not None:
                                data_access_result_element = Element(
                                    "data_access_result"
                                )
                                data_access_result_element.text = (
                                    item.return_parameter.data_access_result.name
                                )
                                return_parameter_element.append(
                                    data_access_result_element
                                )
                            if item.return_parameter.data is not None:
                                return_parameter_element.append(
                                    item.return_parameter.data.to_xml()
                                )
                            item_element.append(return_parameter_element)
                        list_of_responses_element.append(item_element)
                    root.append(list_of_responses_element)
                    return root
                case ActionResponseType.WITH_PBLOCK:
                    response = DLMSActionResponseWithPblock(frame)
                    root = Element("action_response_with_pblock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    pblock_element = Element("pblock")
                    last_block_element = Element("last_block")
                    last_block_element.text = str(response.pblock.last_block)
                    pblock_element.append(last_block_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.pblock.block_number)
                    pblock_element.append(block_number_element)
                    raw_data_element = Element("raw_data")
                    raw_data_element.text = response.pblock.raw_data.hex().upper()
                    pblock_element.append(raw_data_element)
                    root.append(pblock_element)
                    return root
                case ActionResponseType.NEXT_PBLOCK:
                    response = DLMSActionResponseNextPblock(frame)
                    root = Element("action_response_next_pblock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(response.invoked_id)
                    root.append(invoked_id_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(response.block_number)
                    root.append(block_number_element)
                    return root
        if command_type == Command.GET_REQUEST:
            request_get_type = GetRequestType(frame.pop(0))
            match request_get_type:
                case GetRequestType.NORMAL:
                    root = Element("get_request_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    class_id_element = Element("class_id")
                    class_id_element.text = str(int.from_bytes(frame[:2], "big"))
                    del frame[:2]
                    root.append(class_id_element)
                    obis_code_element = Element("obis_code")
                    obis_code_element.text = frame[:6].hex().upper()
                    del frame[:6]
                    root.append(obis_code_element)
                    attribute_element = Element("attribute")
                    attribute_element.text = str(frame.pop(0))
                    root.append(attribute_element)
                    selective_access = self._decode_selective_access(frame)
                    if selective_access is not None:
                        root.append(selective_access)
                    return root
                case GetRequestType.NEXT:
                    root = Element("get_request_next")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    block_number_element = Element("block_number")
                    block_number_element.text = str(int.from_bytes(frame[:4], "big"))
                    root.append(block_number_element)
                    return root
                case GetRequestType.WITH_LIST:
                    root = Element("get_request_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    count = frame.pop(0)
                    descriptors_element = Element("cosem_attribute_descriptor_list")
                    for _ in range(count):
                        descriptors_element.append(self._decode_cosem_descriptor(frame))
                    root.append(descriptors_element)
                    return root
        if command_type == Command.SET_REQUEST:
            request_set_type = SetRequestType(frame.pop(0))
            match request_set_type:
                case SetRequestType.NORMAL:
                    root = Element("set_request_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    root.append(self._decode_cosem_descriptor(frame))
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=1)
                    if payload_parser.data:
                        root.append(payload_parser.data[0].to_xml())
                    return root
                case SetRequestType.WITH_DATABLOCK:
                    root = Element("set_request_with_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    root.append(self._decode_datablock(frame))
                    return root
                case SetRequestType.WITH_FIRST_DATABLOCK:
                    root = Element("set_request_with_first_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    root.append(self._decode_cosem_descriptor(frame))
                    root.append(self._decode_datablock(frame))
                    return root
                case SetRequestType.WITH_LIST:
                    root = Element("set_request_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    count = frame.pop(0)
                    descriptors_element = Element("cosem_attribute_descriptor_list")
                    for _ in range(count):
                        descriptors_element.append(self._decode_cosem_descriptor(frame))
                    root.append(descriptors_element)
                    values_count = frame.pop(0)
                    values_element = Element("values")
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=values_count)
                    for value in payload_parser.data:
                        values_element.append(value.to_xml())
                    root.append(values_element)
                    return root
                case SetRequestType.WITH_LIST_AND_FIRST_DATABLOCK:
                    root = Element("set_request_with_list_and_first_datablock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    count = frame.pop(0)
                    descriptors_element = Element("cosem_attribute_descriptor_list")
                    for _ in range(count):
                        descriptors_element.append(self._decode_cosem_descriptor(frame))
                    root.append(descriptors_element)
                    root.append(self._decode_datablock(frame))
                    return root
        if command_type == Command.ACTION_REQUEST:
            request_action_type = ActionRequestType(frame.pop(0))
            match request_action_type:
                case ActionRequestType.NORMAL:
                    root = Element("action_request_normal")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    class_id_element = Element("class_id")
                    class_id_element.text = str(int.from_bytes(frame[:2], "big"))
                    del frame[:2]
                    root.append(class_id_element)
                    obis_code_element = Element("obis_code")
                    obis_code_element.text = frame[:6].hex().upper()
                    del frame[:6]
                    root.append(obis_code_element)
                    method_element = Element("method")
                    method_element.text = str(frame.pop(0))
                    root.append(method_element)
                    has_payload = frame.pop(0)
                    if has_payload == 0x01:
                        payload_parser = DlmsDataParser()
                        payload_parser.parse(bytes(frame), limit=1)
                        if payload_parser.data:
                            root.append(payload_parser.data[0].to_xml())
                    return root
                case ActionRequestType.WITH_FIRST_PBLOCK:
                    root = Element("action_request_with_first_pblock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    class_id_element = Element("class_id")
                    class_id_element.text = str(int.from_bytes(frame[:2], "big"))
                    del frame[:2]
                    root.append(class_id_element)
                    obis_code_element = Element("obis_code")
                    obis_code_element.text = frame[:6].hex().upper()
                    del frame[:6]
                    root.append(obis_code_element)
                    method_element = Element("method")
                    method_element.text = str(frame.pop(0))
                    root.append(method_element)
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=1)
                    if payload_parser.data:
                        root.append(payload_parser.data[0].to_xml())
                    return root
                case ActionRequestType.WITH_PBLOCK:
                    root = Element("action_request_with_pblock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=1)
                    if payload_parser.data:
                        root.append(payload_parser.data[0].to_xml())
                    return root
                case ActionRequestType.WITH_LIST:
                    root = Element("action_request_with_list")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    count = frame.pop(0)
                    descriptors_element = Element("cosem_method_descriptor_list")
                    for _ in range(count):
                        descriptor_element = Element("descriptor")
                        class_id_element = Element("class_id")
                        class_id_element.text = str(int.from_bytes(frame[:2], "big"))
                        del frame[:2]
                        descriptor_element.append(class_id_element)
                        obis_code_element = Element("obis_code")
                        obis_code_element.text = frame[:6].hex().upper()
                        del frame[:6]
                        descriptor_element.append(obis_code_element)
                        method_element = Element("method")
                        method_element.text = str(frame.pop(0))
                        descriptor_element.append(method_element)
                        descriptors_element.append(descriptor_element)
                    root.append(descriptors_element)
                    values_count = frame.pop(0)
                    values_element = Element("values")
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=values_count)
                    for value in payload_parser.data:
                        values_element.append(value.to_xml())
                    root.append(values_element)
                    return root
                case ActionRequestType.WITH_LIST_AND_FIRST_PBLOCK:
                    root = Element("action_request_with_list_and_first_pblock")
                    invoked_id_element = Element("invoked_id")
                    invoked_id_element.text = str(frame.pop(0))
                    root.append(invoked_id_element)
                    count = frame.pop(0)
                    descriptors_element = Element("cosem_method_descriptor_list")
                    for _ in range(count):
                        descriptor_element = Element("descriptor")
                        class_id_element = Element("class_id")
                        class_id_element.text = str(int.from_bytes(frame[:2], "big"))
                        del frame[:2]
                        descriptor_element.append(class_id_element)
                        obis_code_element = Element("obis_code")
                        obis_code_element.text = frame[:6].hex().upper()
                        del frame[:6]
                        descriptor_element.append(obis_code_element)
                        method_element = Element("method")
                        method_element.text = str(frame.pop(0))
                        descriptor_element.append(method_element)
                        descriptors_element.append(descriptor_element)
                    root.append(descriptors_element)
                    payload_parser = DlmsDataParser()
                    payload_parser.parse(bytes(frame), limit=1)
                    if payload_parser.data:
                        root.append(payload_parser.data[0].to_xml())
                    return root
        return Element("unknown")
