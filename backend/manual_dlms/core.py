"""
manual_dlms/core.py
===================
ManualDlmsCore – central business-logic service for Manual DLMS operations.

This class is the single source of truth for:
  - XML ↔ HEX input detection and auto-conversion  (mirrors Send_Command_ToMeter)
  - COSEM GET / SET / ACTION (normal and WITH-LIST)
  - XDR encode / decode
  - Raw APDU frame sending

It has ZERO knowledge of gRPC, protobuf, wxPython, or any transport layer.
All heavy work is delegated to injected collaborators:
  - DlmsAdapter  for DLMS protocol execution
  - XdrCodec     for XML ↔ XDR conversion

Usage example
-------------
    from manual_dlms.core import ManualDlmsCore
    from manual_dlms.dlms_adapter import NgSdkDlmsAdapter
    from manual_dlms.xdr_codec import NgSdkXdrCodec
    from meter_context import MeterContext

    adapter = NgSdkDlmsAdapter(
        MeterContext.frame_executor,
        MeterContext.communication,
    )
    codec = NgSdkXdrCodec()
    service = ManualDlmsCore(adapter, codec)

    result = service.get(class_id=1, obis="0000010000FF", attribute=2)
    result = service.set(class_id=1, obis="0000010000FF", attribute=2,
                         input_data="<Unsigned8>42</Unsigned8>")
"""

from __future__ import annotations

import warnings
import xml.etree.ElementTree as _ET

from manual_dlms.interfaces import (
    DlmsAdapter,
    DlmsResult,
    EncodingError,
    InvalidInputError,
    ManualDlmsError,
    UnsupportedFrameTagWarning,
    WithListResult,
    XdrCodec,
    XmlParseError,
)

# Minimum meaningful input length (2 hex nibbles = 1 byte, or any XML start).
_MIN_INPUT_LEN = 2

# APDU start tags recognised as valid DLMS responses.
# C0 = GET-response, C1 = SET-response, C3 = ACTION-response
_KNOWN_FRAME_TAGS = frozenset({"C0", "C1", "C3"})

# Default error-response hex returned when the meter sends an empty response.
# This matches the legacy Dialog_ManualCmd behaviour ("D80101").
_EMPTY_RESPONSE_FALLBACK = "D80101"


class ManualDlmsCore:
    """
    Central service for Manual DLMS operations.

    All public methods are **synchronous** (blocking).  The gRPC layer wraps
    them in asyncio.to_thread() so that the event loop stays responsive.

    Public API
    ----------
    Single-object:
        get(class_id, obis, attribute) -> DlmsResult
        set(class_id, obis, attribute, input_data) -> DlmsResult
        action(class_id, obis, attribute, input_data) -> DlmsResult

    Codec:
        encode(xml_input) -> str
        decode(hex_input) -> str

    WITH-LIST batch:
        get_with_list(object_list) -> WithListResult
        set_with_list(object_list) -> WithListResult
        action_with_list(object_list) -> WithListResult

    Raw frame:
        send_raw_frame(hex_frame) -> DlmsResult
    """

    def __init__(self, adapter: DlmsAdapter, codec: XdrCodec) -> None:
        """
        Args:
            adapter: Concrete DlmsAdapter (e.g., NgSdkDlmsAdapter).
            codec:   Concrete XdrCodec  (e.g., NgSdkXdrCodec).
        """
        self._adapter = adapter
        self._codec = codec

    # ==========================================================================
    # Single-object DLMS operations
    # ==========================================================================

    def get(self, class_id: int, obis: str, attribute: int) -> DlmsResult:
        """Execute a COSEM GET request.

        Returns a DlmsResult with .xdr (raw hex) and .xml (pretty XML).
        """
        return self._adapter.cosem_get(class_id, obis, attribute)

    def set(
        self, class_id: int, obis: str, attribute: int, input_data: str
    ) -> DlmsResult:
        """Execute a COSEM SET request.

        input_data may be:
          - An XML string  → auto-encoded to XDR hex before sending.
          - A raw XDR hex string → sent as-is.

        Raises:
            InvalidInputError: input is too short.
            XmlParseError:     XML is malformed.
            EncodingError:     XML-to-XDR encoding failed.
        """
        xdr_hex = self._resolve_input_to_hex(input_data)
        return self._adapter.cosem_set(class_id, obis, attribute, xdr_hex)

    def action(
        self, class_id: int, obis: str, attribute: int, input_data: str
    ) -> DlmsResult:
        """Execute a COSEM ACTION request.

        input_data follows the same XML-or-HEX convention as set().
        Pass an empty string for methods that require no parameter.

        Raises:
            InvalidInputError: input is too short (when non-empty).
            XmlParseError:     XML is malformed.
            EncodingError:     XML-to-XDR encoding failed.
        """
        xdr_hex = self._resolve_input_to_hex(input_data) if input_data.strip() else ""
        return self._adapter.cosem_action(class_id, obis, attribute, xdr_hex)

    # ==========================================================================
    # XDR encode / decode
    # ==========================================================================

    def encode(self, xml_input: str) -> str:
        """Convert an XML data-type tree to an uppercase XDR hex string.

        The input MUST contain '<' and '>' characters (XML markers).

        Raises:
            InvalidInputError: input is too short.
            XmlParseError:     input does not look like XML.
            EncodingError:     XDR encoding failed.
        """
        xml_input = xml_input.strip()
        if len(xml_input) < _MIN_INPUT_LEN:
            raise InvalidInputError("Input too short to be valid XML.")
        if "<" not in xml_input or ">" not in xml_input:
            raise XmlParseError(
                "Input does not look like XML (missing '<' or '>'). "
                "Encode only accepts XML input."
            )
        return self._codec.encode(xml_input)

    def decode(self, hex_input: str) -> str:
        """Convert an XDR hex string to a pretty-printed XML string.

        Raises:
            InvalidInputError: input is too short.
            EncodingError:     hex is malformed or type is unknown.
        """
        hex_input = hex_input.strip()
        if len(hex_input) < _MIN_INPUT_LEN:
            raise InvalidInputError("Input too short to be valid XDR hex.")
        if "<" in hex_input or ">" in hex_input:
            raise EncodingError(
                "Input looks like XML, not XDR hex. Already decoded?"
            )
        return self._codec.decode(hex_input)

    # ==========================================================================
    # WITH-LIST batch operations
    # ==========================================================================

    def get_with_list(self, object_list: list[dict]) -> WithListResult:
        """Execute GET-WITH-LIST for multiple COSEM objects in a single PDU.

        Args:
            object_list: List of dicts, each with keys:
                "class_id" (int), "obis" (str), "attribute" (int)

        Returns:
            WithListResult with per-object DlmsResult items.
            Results preserve the same order as *object_list*.
        """
        if not object_list:
            return WithListResult(items=[], global_success=True)
        try:
            items = self._adapter.cosem_get_with_list(object_list)
            global_success = all(r.success for r in items)
            return WithListResult(items=items, global_success=global_success)
        except ManualDlmsError:
            raise
        except Exception as exc:
            return WithListResult(
                items=[], global_success=False, error=str(exc)
            )

    def set_with_list(self, object_list: list[dict]) -> WithListResult:
        """Execute SET-WITH-LIST.

        Args:
            object_list: List of dicts, each with keys:
                "class_id" (int), "obis" (str), "attribute" (int),
                "input_data" (str)  – XML or raw XDR hex.

        All input_data values are pre-encoded to XDR hex before sending.
        If any pre-encoding fails the entire operation is aborted (no partial
        writes), faithfully mirroring the legacy behaviour.

        Raises:
            InvalidInputError / XmlParseError / EncodingError:
                on pre-encode failure for any item.
        """
        if not object_list:
            return WithListResult(items=[], global_success=True)

        prepared: list[dict] = []
        for item in object_list:
            xdr_hex = self._resolve_input_to_hex(item.get("input_data", ""))
            prepared.append({**item, "xdr_hex": xdr_hex})

        try:
            items = self._adapter.cosem_set_with_list(prepared)
            global_success = all(r.success for r in items)
            return WithListResult(items=items, global_success=global_success)
        except ManualDlmsError:
            raise
        except Exception as exc:
            return WithListResult(
                items=[], global_success=False, error=str(exc)
            )

    def action_with_list(self, object_list: list[dict]) -> WithListResult:
        """Execute ACTION-WITH-LIST.

        Args:
            object_list: List of dicts, each with keys:
                "class_id" (int), "obis" (str), "attribute" (int),
                "input_data" (str)  – XML or raw XDR hex (or empty str for
                                      methods that take no parameter).

        Raises:
            InvalidInputError / XmlParseError / EncodingError:
                on pre-encode failure for any non-empty item.
        """
        if not object_list:
            return WithListResult(items=[], global_success=True)

        prepared: list[dict] = []
        for item in object_list:
            raw = item.get("input_data", "").strip()
            xdr_hex = self._resolve_input_to_hex(raw) if raw else ""
            prepared.append({**item, "xdr_hex": xdr_hex})

        try:
            items = self._adapter.cosem_action_with_list(prepared)
            global_success = all(r.success for r in items)
            return WithListResult(items=items, global_success=global_success)
        except ManualDlmsError:
            raise
        except Exception as exc:
            return WithListResult(
                items=[], global_success=False, error=str(exc)
            )

    # ==========================================================================
    # Raw frame
    # ==========================================================================

    def send_raw_frame(self, hex_frame: str) -> DlmsResult:
        """Send a raw DLMS APDU frame and return the response.

        Business rules (mirrors OnButton_Cmd_SendButton in Dialog_ManualCmd):
          1. Input must be non-empty (>= 2 hex chars).
          2. If the tag (first byte) is not C0, C1, or C3 a
             UnsupportedFrameTagWarning is emitted, but the frame is still sent.
          3. If the meter returns an empty response the fallback "D80101" is
             used (legacy behaviour).

        Args:
            hex_frame: Raw APDU as a hex string (spaces are stripped).

        Returns:
            DlmsResult with .xdr set to the response hex on success.

        Raises:
            InvalidInputError: frame is empty or too short.
        """
        hex_frame = hex_frame.strip().upper().replace(" ", "")
        if len(hex_frame) < _MIN_INPUT_LEN:
            raise InvalidInputError(
                "Raw frame too short. Minimum is 2 hex characters (1 byte)."
            )

        tag = hex_frame[:2]
        if tag not in _KNOWN_FRAME_TAGS:
            warnings.warn(
                f"Frame tag 0x{tag} is not a recognised DLMS response tag "
                f"(expected one of: {', '.join(sorted(_KNOWN_FRAME_TAGS))}). "
                "The frame will be sent anyway.",
                UnsupportedFrameTagWarning,
                stacklevel=2,
            )

        try:
            response_hex = self._adapter.send_frame(hex_frame)
        except Exception as exc:
            return DlmsResult(success=False, error=str(exc))

        if not response_hex:
            response_hex = _EMPTY_RESPONSE_FALLBACK

        return DlmsResult(success=True, xdr=response_hex)

    # ==========================================================================
    # Private helpers
    # ==========================================================================

    def _resolve_input_to_hex(self, input_data: str) -> str:
        """Detect whether *input_data* is XML or raw XDR hex and normalise it.

        Logic mirrors Dialog_ManualCmd.Send_Command_ToMeter():
            - Strip whitespace.
            - Reject if length < 2.
            - If '<' or '>' present → parse XML, then encode to XDR hex.
            - Otherwise            → treat as raw XDR hex (normalise to upper).

        Raises:
            InvalidInputError: input too short.
            XmlParseError:     XML cannot be parsed.
            EncodingError:     XML-to-XDR encoding failed.
        """
        input_data = input_data.strip()
        if len(input_data) < _MIN_INPUT_LEN:
            raise InvalidInputError(
                "Input is too short. Minimum length is 2 characters "
                "(e.g. a single hex byte '11' or a minimal XML tag '<Null/>')."
            )

        if "<" in input_data or ">" in input_data:
            # ---- XML path ----
            try:
                _ET.fromstring(input_data)  # validate before encoding
            except _ET.ParseError as exc:
                raise XmlParseError(
                    f"XML format error, cannot encode: {exc}"
                ) from exc

            encoded = self._codec.encode(input_data)
            if not encoded:
                raise EncodingError(
                    "XML format parameter encoding returned an empty result."
                )
            return encoded

        # ---- HEX path ----
        normalised = input_data.upper().replace(" ", "")
        return normalised
