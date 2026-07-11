"""
manual_dlms/xdr_codec.py
========================
XdrCodec implementation backed by the ng_sdk DLMS data-type library.

The ng_sdk uses an XML format where element tags are PascalCase type names
and element text (or child elements) carry the value:

    <Unsigned8>42</Unsigned8>
    <Structure>
        <Unsigned8>1</Unsigned8>
        <OctetString>00;01;02</OctetString>
    </Structure>

This is functionally equivalent to the legacy A_XDR.py format but uses
ng_sdk's own serialisation so that new DLMS types are supported automatically.
"""

from __future__ import annotations

import xml.dom.minidom as _minidom
import xml.etree.ElementTree as _ET
from xml.etree.ElementTree import tostring as _tostring

from ng_sdk.frame_builder.dlms.xdlms.data_type.dlms_parser import DlmsDataParser
from ng_sdk.util.xml_data_type_parser import parse_dlms_xml

from manual_dlms.interfaces import EncodingError, XdrCodec


class NgSdkXdrCodec(XdrCodec):
    """
    XdrCodec implementation using ng_sdk's DlmsDataParser and
    AbstractDlmsType serialisation.

    Thread-safety: instances are stateless between calls; each call creates
    a fresh DlmsDataParser, so this class is safe to share across threads.
    """

    # ------------------------------------------------------------------
    # Encode  (XML → XDR hex)
    # ------------------------------------------------------------------

    def encode(self, xml_input: str) -> str:
        """Convert an XML data-type tree to an uppercase XDR hex string.

        The XML must use ng_sdk PascalCase tags, e.g.:
            <Unsigned8>42</Unsigned8>

        Raises:
            EncodingError: on any parse or serialisation failure.
        """
        xml_input = xml_input.strip()
        try:
            dlms_type = parse_dlms_xml(xml_input)
        except ValueError as exc:
            raise EncodingError(f"Unknown DLMS type in XML: {exc}") from exc
        except _ET.ParseError as exc:
            raise EncodingError(f"XML parse error: {exc}") from exc
        except Exception as exc:
            raise EncodingError(f"XML-to-DLMS conversion failed: {exc}") from exc

        try:
            return dlms_type.to_bytes().hex().upper()
        except Exception as exc:
            raise EncodingError(f"DLMS type serialisation failed: {exc}") from exc

    # ------------------------------------------------------------------
    # Decode  (XDR hex → XML)
    # ------------------------------------------------------------------

    def decode(self, hex_input: str) -> str:
        """Convert an XDR hex string to a pretty-printed XML string.

        Raises:
            EncodingError: when the hex is malformed or the type is unknown.
        """
        hex_input = hex_input.strip().upper().replace(" ", "")
        try:
            raw_bytes = bytes.fromhex(hex_input)
        except ValueError as exc:
            raise EncodingError(f"Invalid hex input: {exc}") from exc

        try:
            parser = DlmsDataParser()
            parsed = parser.parse(raw_bytes, limit=1)
        except Exception as exc:
            raise EncodingError(f"XDR decoding failed: {exc}") from exc

        if not parsed:
            raise EncodingError("XDR decode returned no data.")

        try:
            xml_element = parsed[0].to_xml()
            raw_xml = _tostring(xml_element, encoding="unicode")
            return self._pretty_print(raw_xml)
        except Exception as exc:
            raise EncodingError(f"XML serialisation of decoded data failed: {exc}") from exc

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _pretty_print(raw_xml: str) -> str:
        """Return a pretty-printed XML string (without the XML declaration)."""
        try:
            dom = _minidom.parseString(raw_xml)
            pretty = dom.toprettyxml(indent="  ")
            # Strip the XML declaration added by toprettyxml
            lines = pretty.splitlines(keepends=True)
            if lines and lines[0].startswith("<?xml"):
                lines = lines[1:]
            return "".join(lines)
        except Exception:
            # Fallback: simple newline after each closing/opening tag
            return raw_xml.replace(">", ">\n")
