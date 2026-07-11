from xml.etree.ElementTree import Element

from ng_sdk.frame_builder.dlms.xdlms.action_dlms_cipher import ActionDlmsCipher
from ng_sdk.frame_builder.dlms.xdlms.get_dlms_cipher import GetDlmsCipher
from ng_sdk.frame_builder.dlms.xdlms.set_dlms_cipher import SetDlmsCipher
from ng_sdk.security.security_constant import DlmsCipheringType
from ng_sdk.util.bytes_util import extract_length

from util.constants import (
    GLO_GET_RESPONSE,
    GLO_SET_RESPONSE,
    GLO_ACTION_RESPONSE,
    DED_GET_RESPONSE,
    DED_SET_RESPONSE,
    DED_ACTION_RESPONSE,
)

from translator.abstract_translator import AbstractTranslator

RESPONSE_TAG_MAP = {
    GLO_GET_RESPONSE: "global_ciphering_get_response",
    GLO_SET_RESPONSE: "global_ciphering_set_response",
    GLO_ACTION_RESPONSE: "global_ciphering_action_response",
    DED_GET_RESPONSE: "dedicated_ciphering_get_response",
    DED_SET_RESPONSE: "dedicated_ciphering_set_response",
    DED_ACTION_RESPONSE: "dedicated_ciphering_action_response",
}


class CipheredXDLMSTranslator(AbstractTranslator):
    def translate(self, input_data: bytes) -> Element:
        frame = bytearray(input_data)
        tag = frame.pop(0)
        if tag == GetDlmsCipher.GLOBAL_CIPHERING:
            root = Element("global_ciphering_get_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root
        if tag == GetDlmsCipher.DEDICATED_CIPHERING:
            root = Element("dedicated_ciphering_get_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root

        if tag == SetDlmsCipher.GLOBAL_CIPHERING:
            root = Element("global_ciphering_set_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root
        if tag == SetDlmsCipher.DEDICATED_CIPHERING:
            root = Element("dedicated_ciphering_set_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root

        if tag == ActionDlmsCipher.GLOBAL_CIPHERING:
            root = Element("global_ciphering_action_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root
        if tag == ActionDlmsCipher.DEDICATED_CIPHERING:
            root = Element("dedicated_ciphering_action_request")
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root
        if tag == ActionDlmsCipher.GENERAL_CIPHERING:
            root = Element("general_global_ciphering")
            sys_title_length, data = extract_length(frame)
            frame = bytearray(data)
            system_title_element = Element("system_title")
            system_title_element.text = frame[:sys_title_length].hex().upper()
            root.append(system_title_element)
            del frame[:sys_title_length]
            ciphered_data_length, ciphered_data = extract_length(frame)
            ciphered_data_element = Element("ciphered_data")
            ciphered_data_element.text = ciphered_data.hex().upper()
            root.append(ciphered_data_element)
            return root

        if tag in RESPONSE_TAG_MAP:
            root = Element(RESPONSE_TAG_MAP[tag])
            length, data = extract_length(frame)
            length_element = Element("length")
            length_element.text = str(length)
            root.append(length_element)
            data_element = Element("data")
            data_element.text = data.hex().upper()
            root.append(data_element)
            return root

        return Element("unknown")
