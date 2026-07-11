from xml.etree.ElementTree import Element

from ng_sdk.constant.hdlc.constant import HDLC_FLAG
from ng_sdk.frame_builder.dlms.acse.aare_apdu import AARE
from ng_sdk.frame_builder.dlms.acse.aarq_apdu import AARQ
from ng_sdk.frame_builder.dlms.acse.rlre_apdu import RLRE
from ng_sdk.frame_builder.dlms.acse.rlrq_apdu import RLRQ
from ng_sdk.frame_builder.dlms.dlms_enums import Command
from ng_sdk.frame_builder.dlms.xdlms.action_dlms_cipher import ActionDlmsCipher
from ng_sdk.frame_builder.dlms.xdlms.get_dlms_cipher import GetDlmsCipher
from ng_sdk.frame_builder.dlms.xdlms.set_dlms_cipher import SetDlmsCipher

from translator.abstract_translator import AbstractTranslator
from translator.acse_translator import ACSETranslator
from translator.ciphered_xdlms_translator import (
    CipheredXDLMSTranslator,
    RESPONSE_TAG_MAP,
)
from translator.hdlc_translator import HDLCTranslator
from translator.xdlms_translator import XDLMSTranslator

ACSE_TAGS = (
    AARQ.TAG,
    AARE.TAG,
    RLRQ.TAG,
    RLRE.TAG,
)

XDLMS_TAGS = (
    Command.GET_REQUEST,
    Command.GET_RESPONSE,
    Command.SET_REQUEST,
    Command.SET_RESPONSE,
    Command.ACTION_REQUEST,
    Command.ACTION_RESPONSE,
    Command.EXCEPTION_RESPONSE,
)

CIPHERED_XDLMS_TAGS = (
    GetDlmsCipher.GLOBAL_CIPHERING,
    GetDlmsCipher.DEDICATED_CIPHERING,
    SetDlmsCipher.GLOBAL_CIPHERING,
    SetDlmsCipher.DEDICATED_CIPHERING,
    ActionDlmsCipher.GLOBAL_CIPHERING,
    ActionDlmsCipher.DEDICATED_CIPHERING,
    ActionDlmsCipher.GENERAL_CIPHERING,
)


class DLMSTranslator(AbstractTranslator):
    """Main DLMS translator that redirects to the correct translator based on the first byte tag."""

    def __init__(self):
        self._acse_translator = ACSETranslator()
        self._xdlms_translator = XDLMSTranslator()
        self._ciphered_xdlms_translator = CipheredXDLMSTranslator()
        self._hdlc_translator = HDLCTranslator()

    def translate(self, input_data: bytes) -> Element:
        if not input_data:
            error = Element("error")
            error.text = "Empty input data"
            return error

        tag = input_data[0]

        if tag == HDLC_FLAG:
            return self._hdlc_translator.translate(input_data)

        if tag in ACSE_TAGS:
            return self._acse_translator.translate(input_data)

        if tag in XDLMS_TAGS:
            return self._xdlms_translator.translate(input_data)

        if tag in CIPHERED_XDLMS_TAGS or tag in RESPONSE_TAG_MAP.keys():
            return self._ciphered_xdlms_translator.translate(input_data)

        unknown = Element("unknown")
        unknown.set("tag", f"0x{tag:02X}")
        return unknown
