from xml.etree.ElementTree import Element

from ng_sdk.frame_builder.dlms.acse.aare_apdu import AARE
from ng_sdk.frame_builder.dlms.acse.aarq_apdu import AARQ
from ng_sdk.frame_builder.dlms.acse.models.acse_tag import AcseTag
from ng_sdk.frame_builder.dlms.acse.models.conformance import Conformance
from ng_sdk.frame_builder.dlms.acse.models.association_result import AssociationResult
from ng_sdk.frame_builder.dlms.acse.models.initiate_request import InitiateRequest
from ng_sdk.frame_builder.dlms.acse.models.initiate_response import InitiateResponse
from ng_sdk.frame_builder.dlms.acse.models.object_identifier import ObjectIdentifier
from ng_sdk.frame_builder.dlms.acse.models.result_source_diagnostics import (
    ResultSourceDiagnostics,
)
from ng_sdk.frame_builder.dlms.acse.models.user_information_response import (
    UserInformationResponse,
)
from ng_sdk.frame_builder.dlms.acse.rlre_apdu import RLRE
from ng_sdk.frame_builder.dlms.acse.rlrq_apdu import RLRQ
from ng_sdk.frame_builder.dlms.acse.models.release_reason import (
    ReleaseResponseReason,
    ReleaseRequestReason,
)

from translator.abstract_translator import AbstractTranslator

CIPHERED_TAGS = (
    AcseTag.GLO_INITIATE_RESPONSE.value,
    AcseTag.DED_INITIATE_RESPONSE.value,
    UserInformationResponse.GENERAL_TAG,
)

CIPHERED_REQUEST_TAGS = (
    AcseTag.GLO_INITIATE_REQUEST.value,
    AcseTag.DED_INITIATE_REQUEST.value,
    InitiateRequest.GENERAL_CIPHERING,
)

AARQ_PARSE_TAGS = {
    0x80: "protocol_version",
    0xA1: "application_context_name",
    0xA2: "called_ap_title",
    0xA3: "called_ae_qualifier",
    0xA4: "called_ap_invocation_id",
    0xA5: "called_ae_invocation_id",
    0xA6: "calling_ap_title",
    0xA7: "calling_ae_qualifier",
    0xA8: "calling_ap_invocation_id",
    0xA9: "calling_ae_invocation_id",
    0x8A: "sender_acse_requirements",
    0x8B: "mechanism_name",
    0xAC: "calling_authentication_value",
    0xBD: "implementation_information",
    0xBE: "user_information",
}

APPLICATION_CONTEXT_NAMES = {
    "2.16.756.5.8.1.1": "LN_REFERENCING_WITH_NO_CIPHERING",
    "2.16.756.5.8.1.2": "SN_REFERENCING_WITH_NO_CIPHERING",
    "2.16.756.5.8.1.3": "LN_REFERENCING_WITH_CIPHERING",
    "2.16.756.5.8.1.4": "SN_REFERENCING_WITH_CIPHERING",
}


class ACSETranslator(AbstractTranslator):
    """Translator for ACSE frames (AARQ, AARE, RLRQ, RLRE) to XML elements."""

    def translate(self, input_data: bytes) -> Element:
        tag = input_data[0]
        if tag == AARE.TAG:
            return self._translate_aare(input_data)
        if tag == AARQ.TAG:
            return self._translate_aarq(input_data)
        if tag == RLRQ.TAG:
            return self._translate_rlrq(input_data)
        if tag == RLRE.TAG:
            return self._translate_rlre(input_data)
        return Element("unknown")

    def _translate_aare(self, data: bytes) -> Element:
        root = Element("aare")
        aare_data = bytearray(data)

        aare_tag = aare_data.pop(0)
        if aare_tag != AARE.TAG:
            error = Element("error")
            error.text = f"Not an AARE APDU, tag={aare_tag:#04x}"
            root.append(error)
            return root

        aare_length = aare_data.pop(0)

        while len(aare_data) > 0:
            object_tag = aare_data.pop(0)
            object_length = aare_data.pop(0)
            object_data = bytes(aare_data[:object_length])
            del aare_data[:object_length]

            object_desc = AARE.PARSE_TAGS.get(object_tag)
            if object_desc is None:
                continue

            field_name = object_desc[0]
            field_class = object_desc[1]

            if field_name == "application_context_name":
                el = Element("application_context_name")
                try:
                    oid = ObjectIdentifier.from_bytes(object_data)

                    el.text = APPLICATION_CONTEXT_NAMES.get(oid.oid_str, oid.oid_str)
                except Exception:
                    el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "result":
                try:
                    result = AssociationResult.from_bytes(object_data)
                    el = Element("result")
                    el.text = result.result.name
                    root.append(el)
                except Exception:
                    el = Element("result")
                    el.text = object_data.hex().upper()
                    root.append(el)

            elif field_name == "result_source_diagnostic":
                try:
                    diagnostic = ResultSourceDiagnostics.from_bytes(object_data)
                    el = Element("result_source_diagnostic")
                    el.text = diagnostic.result.name
                    root.append(el)
                except Exception:
                    el = Element("result_source_diagnostic")
                    el.text = object_data.hex().upper()
                    root.append(el)

            elif field_name == "responding_ap_title":
                el = Element("responding_ap_title")
                el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "responder_acse_requirements":
                el = Element("responder_acse_requirements")
                el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "mechanism_name":
                el = Element("mechanism_name")
                el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "responding_authentication_value":
                el = Element("responding_authentication_value")
                el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "implementation_information":
                el = Element("implementation_information")
                el.text = object_data.hex().upper()
                root.append(el)

            elif field_name == "user_information":
                user_info_element = Element("user_information")
                # object_data starts with 0x04 (octet string tag) + length + content
                inner = bytearray(object_data)
                inner.pop(0)  # octet string tag 0x04
                inner.pop(0)  # length
                content_tag = inner[0] if inner else None
                if content_tag in CIPHERED_TAGS:
                    # ciphered: just put hex bytes
                    el = Element("data")
                    el.text = bytes(inner).hex().upper()
                    user_info_element.append(el)
                else:
                    # plain InitiateResponse: decode and add fields
                    try:
                        initiate = InitiateResponse.from_bytes(bytes(inner))
                        el = Element("negotiated_dlms_version_number")
                        el.text = str(initiate.negotiated_dlms_version_number)
                        user_info_element.append(el)
                        el = Element("negotiated_quality_of_service")
                        el.text = str(initiate.negotiated_quality_of_service)
                        user_info_element.append(el)
                        el = Element("server_max_receive_pdu_size")
                        el.text = str(initiate.server_max_receive_pdu_size)
                        user_info_element.append(el)
                        if initiate.negotiated_conformance is not None:
                            conformance_element = Element("negotiated_conformance")
                            for attr in Conformance.conformance_bit_position.keys():
                                conf_el = Element(attr)
                                conf_el.text = str(
                                    getattr(initiate.negotiated_conformance, attr)
                                )
                                conformance_element.append(conf_el)
                            user_info_element.append(conformance_element)
                    except Exception:
                        el = Element("data")
                        el.text = bytes(inner).hex().upper()
                        user_info_element.append(el)
                root.append(user_info_element)

        return root

    def _translate_aarq(self, data: bytes) -> Element:
        root = Element("aarq")
        aarq_data = bytearray(data)

        aarq_tag = aarq_data.pop(0)
        if aarq_tag != AARQ.TAG:
            error = Element("error")
            error.text = f"Not an AARQ APDU, tag={aarq_tag:#04x}"
            root.append(error)
            return root

        aarq_data.pop(0)  # length

        while len(aarq_data) > 0:
            object_tag = aarq_data.pop(0)
            object_length = aarq_data.pop(0)
            object_data = bytes(aarq_data[:object_length])
            del aarq_data[:object_length]

            field_name = AARQ_PARSE_TAGS.get(object_tag)
            if field_name is None:
                continue

            if field_name == "application_context_name":
                el = Element("application_context_name")
                try:
                    oid = ObjectIdentifier.from_bytes(object_data)
                    el.text = APPLICATION_CONTEXT_NAMES.get(oid.oid_str, oid.oid_str)
                except Exception:
                    el.text = object_data.hex().upper()
                root.append(el)
            elif field_name == "user_information":
                user_info_element = Element("user_information")
                inner = bytearray(object_data)
                inner.pop(0)  # octet string tag 0x04
                inner.pop(0)  # length
                content_tag = inner[0] if inner else None
                if content_tag in CIPHERED_REQUEST_TAGS:
                    el = Element("data")
                    el.text = bytes(inner).hex().upper()
                    user_info_element.append(el)
                else:
                    try:
                        inner_data = bytearray(inner)
                        inner_data.pop(0)  # TAG (0x01)
                        # dedicated_key: 0x00 = no key, else TLV
                        dedicated_key_flag = inner_data.pop(0)
                        if dedicated_key_flag != 0x00:
                            dedicated_key_length = inner_data.pop(0)
                            del inner_data[:dedicated_key_length]
                        # response_allowed: 0x00 = none, 0x01 = one byte follows
                        response_allowed_len = inner_data.pop(0)
                        if response_allowed_len > 0:
                            del inner_data[:response_allowed_len]
                        # quality_of_service
                        proposed_quality_of_service = inner_data.pop(0)
                        # dlms_version
                        proposed_dlms_version_number = inner_data.pop(0)
                        # conformance tag+length (5F 1F 04)
                        del inner_data[:3]
                        # conformance (4 bytes: 0x00 + 3 data bytes)
                        conformance_bytes = bytes(inner_data[:4])
                        del inner_data[:4]
                        # max PDU size (2 bytes)
                        client_max_receive_pdu_size = int.from_bytes(
                            inner_data[:2], "big"
                        )

                        el = Element("proposed_dlms_version_number")
                        el.text = str(proposed_dlms_version_number)
                        user_info_element.append(el)
                        el = Element("proposed_quality_of_service")
                        el.text = str(proposed_quality_of_service)
                        user_info_element.append(el)
                        el = Element("client_max_receive_pdu_size")
                        el.text = str(client_max_receive_pdu_size)
                        user_info_element.append(el)
                        conformance = Conformance.from_bytes(conformance_bytes)
                        conformance_element = Element("proposed_conformance")
                        for attr in Conformance.conformance_bit_position.keys():
                            conf_el = Element(attr)
                            conf_el.text = str(getattr(conformance, attr))
                            conformance_element.append(conf_el)
                        user_info_element.append(conformance_element)
                    except Exception:
                        el = Element("data")
                        el.text = bytes(inner).hex().upper()
                        user_info_element.append(el)
                root.append(user_info_element)
            else:
                el = Element(field_name)
                el.text = object_data.hex().upper()
                root.append(el)

        return root

    def _translate_rlrq(self, data: bytes) -> Element:
        root = Element("rlrq")
        rlrq_data = bytearray(data)

        rlrq_tag = rlrq_data.pop(0)
        if rlrq_tag != RLRQ.TAG:
            error = Element("error")
            error.text = f"Not an RLRQ APDU, tag={rlrq_tag:#04x}"
            root.append(error)
            return root

        rlrq_data.pop(0)  # length

        while len(rlrq_data) > 0:
            object_tag = rlrq_data.pop(0)
            object_length = rlrq_data.pop(0)
            object_data = bytes(rlrq_data[:object_length])
            del rlrq_data[:object_length]

            if object_tag == 0x80:
                # reason
                try:
                    reason_value = int.from_bytes(object_data, "big")
                    reason = ReleaseRequestReason(reason_value)
                    el = Element("reason")
                    el.text = reason.name
                    root.append(el)
                except Exception:
                    el = Element("reason")
                    el.text = object_data.hex().upper()
                    root.append(el)

            elif object_tag == 0xBE:
                # user_information
                user_info_element = Element("user_information")
                inner = bytearray(object_data)
                inner.pop(0)  # octet string tag 0x04
                inner.pop(0)  # length
                content_tag = inner[0] if inner else None
                if content_tag in CIPHERED_REQUEST_TAGS:
                    el = Element("data")
                    el.text = bytes(inner).hex().upper()
                    user_info_element.append(el)
                else:
                    try:
                        initiate = (
                            InitiateRequest.from_bytes(bytes(inner))
                            if hasattr(InitiateRequest, "from_bytes")
                            else None
                        )
                        if initiate is not None:
                            el = Element("proposed_dlms_version_number")
                            el.text = str(initiate.proposed_dlms_version_number)
                            user_info_element.append(el)
                            el = Element("proposed_quality_of_service")
                            el.text = str(initiate.proposed_quality_of_service)
                            user_info_element.append(el)
                            el = Element("client_max_receive_pdu_size")
                            el.text = str(initiate.client_max_receive_pdu_size)
                            user_info_element.append(el)
                            if initiate.proposed_conformance is not None:
                                el = Element("proposed_conformance")
                                el.text = (
                                    initiate.proposed_conformance.to_bytes()
                                    .hex()
                                    .upper()
                                )
                                user_info_element.append(el)
                        else:
                            el = Element("data")
                            el.text = bytes(inner).hex().upper()
                            user_info_element.append(el)
                    except Exception:
                        el = Element("data")
                        el.text = bytes(inner).hex().upper()
                        user_info_element.append(el)
                root.append(user_info_element)

        return root

    def _translate_rlre(self, data: bytes) -> Element:
        root = Element("rlre")
        rlre_data = bytearray(data)

        rlre_tag = rlre_data.pop(0)
        if rlre_tag != RLRE.TAG:
            error = Element("error")
            error.text = f"Not an RLRE APDU, tag={rlre_tag:#04x}"
            root.append(error)
            return root

        rlre_data.pop(0)  # length

        while len(rlre_data) > 0:
            object_tag = rlre_data.pop(0)
            object_length = rlre_data.pop(0)
            object_data = bytes(rlre_data[:object_length])
            del rlre_data[:object_length]

            if object_tag == RLRE.PARSE_TAGS.get(0x80, [None])[0] or object_tag == 0x80:
                # reason
                try:
                    reason_value = int.from_bytes(object_data, "big")
                    reason = ReleaseResponseReason.from_value(reason_value)
                    el = Element("reason")
                    el.text = reason.name if reason is not None else str(reason_value)
                    root.append(el)
                except Exception:
                    el = Element("reason")
                    el.text = object_data.hex().upper()
                    root.append(el)

            elif object_tag == 0xBE:
                # user_information
                user_info_element = Element("user_information")
                inner = bytearray(object_data)
                inner.pop(0)  # octet string tag 0x04
                inner.pop(0)  # length
                content_tag = inner[0] if inner else None
                if content_tag in CIPHERED_TAGS:
                    el = Element("data")
                    el.text = bytes(inner).hex().upper()
                    user_info_element.append(el)
                else:
                    try:
                        initiate = InitiateResponse.from_bytes(bytes(inner))
                        el = Element("negotiated_dlms_version_number")
                        el.text = str(initiate.negotiated_dlms_version_number)
                        user_info_element.append(el)
                        el = Element("negotiated_quality_of_service")
                        el.text = str(initiate.negotiated_quality_of_service)
                        user_info_element.append(el)
                        el = Element("server_max_receive_pdu_size")
                        el.text = str(initiate.server_max_receive_pdu_size)
                        user_info_element.append(el)
                        if initiate.negotiated_conformance is not None:
                            el = Element("negotiated_conformance")
                            el.text = (
                                initiate.negotiated_conformance.to_bytes().hex().upper()
                            )
                            user_info_element.append(el)
                    except Exception:
                        el = Element("data")
                        el.text = bytes(inner).hex().upper()
                        user_info_element.append(el)
                root.append(user_info_element)

        return root
