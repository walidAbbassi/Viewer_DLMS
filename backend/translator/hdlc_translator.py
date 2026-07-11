from xml.etree.ElementTree import Element

from ng_sdk.constant.hdlc.constant import (
    HDLC_FLAG,
    FRAME_FORMAT_LENGTH,
    CONTROL_LENGTH,
    HCS_LENGTH,
    DATA_SERVER_PREFIX,
    FCS_LENGTH,
    SEG_MASK,
)
from ng_sdk.transport.hdlc.hdlc_address import HdlcAddress
from ng_sdk.transport.hdlc.hdlc_control import HDLCControl, FrameType
from ng_sdk.transport.hdlc.hdlc_crc import HDLCCrc
from ng_sdk.transport.hdlc.snrm_data import SnrmData

from translator.abstract_translator import AbstractTranslator


class HDLCTranslator(AbstractTranslator):
    """Translator for HDL (Hardware Description Language) data to XML elements."""

    def translate(self, input_data: bytes) -> Element:
        data = input_data
        """
        Translate HDL input bytes data to an XML element.

        Args:
            input_data: The input bytes containing HDL data to be translated

        Returns:
            An XML Element representing the translated HDL data
        """
        # TODO: Implement HDL translation logic

        # Validate the presence of HDLC flags
        if data[0] != HDLC_FLAG or data[-1] != HDLC_FLAG:
            raise ValueError("Invalid HDLC frame: missing flags")
        data = data[1:-1]  # Remove the flags
        root = Element("hdlc")
        # Extract and validate the frame format field
        frame_format = data[:FRAME_FORMAT_LENGTH]
        frame_length = self.__extract_frame_length(frame_format)
        segmentation = self.__extract_segmentation(int.from_bytes(frame_format, "big"))
        segmentation_element = Element("segmentation")
        segmentation_element.text = str(segmentation)
        root.append(segmentation_element)
        if len(data) != frame_length:
            error = Element("error")
            error.text = f"Incorrect frame length: len(data)={len(data)} != frame_length={frame_length}"
            root.append(error)
            return root

        # Decode destination and source addresses
        current_index = FRAME_FORMAT_LENGTH
        dest_addr, dest_length = HdlcAddress.decode_hdlc_address(data[current_index:])
        current_index += dest_length
        dest_element = Element("destination_address")
        dest_addr_element = Element("dest_addr")
        dest_addr_element.text = str(dest_addr)
        dest_length_element = Element("dest_length")
        dest_length_element.text = str(dest_length)
        dest_element.append(dest_addr_element)
        dest_element.append(dest_length_element)
        root.append(dest_element)

        src_addr, src_length = HdlcAddress.decode_hdlc_address(data[current_index:])
        current_index += src_length
        src_element = Element("source_address")
        src_addr_element = Element("src_addr")
        src_addr_element.text = str(src_addr)
        src_length_element = Element("src_length")
        src_length_element.text = str(src_length)
        src_element.append(src_addr_element)
        src_element.append(src_length_element)
        root.append(src_element)

        # Extract and validate the control field
        control = HDLCControl.decode(data[current_index])
        current_index += CONTROL_LENGTH

        control_element = Element("control")
        frame_type_element = Element("frame_type")
        frame_type_element.text = str(control.frame_type.value)
        frame_type_name_element = Element("frame_type_name")
        frame_type_name_element.text = control.frame_type.name
        ns_element = Element("ns")
        ns_element.text = str(control.ns) if control.ns is not None else "N/A"
        nr_element = Element("nr")
        nr_element.text = str(control.nr) if control.nr is not None else "N/A"
        pf_element = Element("pf")
        pf_element.text = str(control.pf)
        with_suffix_element = Element("with_suffix")
        with_suffix_element.text = str(control.with_suffix)
        control_element.append(frame_type_element)
        control_element.append(frame_type_name_element)
        control_element.append(ns_element)
        control_element.append(nr_element)
        control_element.append(pf_element)
        control_element.append(with_suffix_element)
        root.append(control_element)

        # Validate the Header Check Sequence (HCS)
        hcs = int.from_bytes(data[current_index : current_index + HCS_LENGTH], "big")
        current_index += HCS_LENGTH
        hcs_computed = HDLCCrc.crc16_ccitt(data[: current_index - HCS_LENGTH])
        hcs_element = Element("hcs")
        hcs_value_element = Element("value")
        hcs_value_element.text = f"0x{hcs:04X}"
        hcs_computed_element = Element("computed")
        hcs_computed_element.text = f"0x{hcs_computed:04X}"
        hcs_element.append(hcs_value_element)
        hcs_element.append(hcs_computed_element)
        if hcs != hcs_computed:
            hcs_error_element = Element("error")
            hcs_error_element.text = (
                f"Invalid HCS: received=0x{hcs:04X} != computed=0x{hcs_computed:04X}"
            )
            hcs_element.append(hcs_error_element)
        root.append(hcs_element)

        if data[current_index:-FCS_LENGTH].startswith(
            bytes.fromhex(DATA_SERVER_PREFIX)
        ):
            current_index += len(DATA_SERVER_PREFIX) // 2

        # Extract the information field and validate the Frame Check Sequence (FCS)
        info = data[current_index:-FCS_LENGTH]
        fcs = int.from_bytes(data[-FCS_LENGTH:], "big")
        fcs_computed = HDLCCrc.crc16_ccitt(data[:-FCS_LENGTH])
        fcs_element = Element("fcs")
        fcs_value_element = Element("value")
        fcs_value_element.text = f"0x{fcs:04X}"
        fcs_computed_element = Element("computed")
        fcs_computed_element.text = f"0x{fcs_computed:04X}"
        fcs_element.append(fcs_value_element)
        fcs_element.append(fcs_computed_element)
        if fcs != fcs_computed:
            fcs_error_element = Element("error")
            fcs_error_element.text = (
                f"Invalid FCS: received=0x{fcs:04X} != computed=0x{fcs_computed:04X}"
            )
            fcs_element.append(fcs_error_element)
        root.append(fcs_element)

        # If UA frame and info is not empty, try to decode with SnrmData else hex raw
        if control.frame_type == FrameType.UA and info:
            snrm_data = Element("snrm_data")
            try:
                snrm = SnrmData.from_bytes(info)
                if snrm.maximum_information_field_length_value_transmit is not None:
                    el = Element("max_info_length_transmit")
                    el.text = str(snrm.maximum_information_field_length_value_transmit)
                    snrm_data.append(el)
                if snrm.maximum_information_field_length_value_receive is not None:
                    el = Element("max_info_length_receive")
                    el.text = str(snrm.maximum_information_field_length_value_receive)
                    snrm_data.append(el)
                if snrm.window_size_value_transmit is not None:
                    el = Element("window_size_transmit")
                    el.text = str(snrm.window_size_value_transmit)
                    snrm_data.append(el)
                if snrm.window_size_value_receive is not None:
                    el = Element("window_size_receive")
                    el.text = str(snrm.window_size_value_receive)
                    snrm_data.append(el)
                root.append(snrm_data)
            except Exception:
                # Add data element with info as hex string
                data_element = Element("data")
                data_element.text = info.hex().upper()
                root.append(data_element)
        else:
            # Add data element with info as hex string
            data_element = Element("data")
            data_element.text = info.hex().upper()
            root.append(data_element)

        return root

    def __extract_frame_length(self, frame_format: bytes) -> int:
        """
        Extract the frame length from the frame format field.
        """
        return (((frame_format[0] & 0x0F) << 8) | frame_format[1]) & 0x07FF

    def __validate_crc(self, data: bytes, expected_crc: int) -> bool:
        """
        Validate the CRC for the given data.
        """
        return HDLCCrc.crc16_ccitt(data) == expected_crc

    def __extract_segmentation(self, frame_format: int) -> int:
        # isolate bit 11, then shift it to LSB
        return (frame_format & SEG_MASK) >> 11
