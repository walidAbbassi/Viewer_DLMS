"""
manual_dlms/interfaces.py
=========================
Abstract interfaces and shared data models for the Manual DLMS feature.

These types form the contract between:
  - ManualDlmsCore  (business logic)
  - DlmsAdapter     (DLMS protocol stack – real or mock)
  - XdrCodec        (XML ↔ XDR conversion)

No dependency on gRPC, wxPython, or any specific implementation.
"""

from __future__ import annotations

import warnings
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Optional


# ---------------------------------------------------------------------------
# Domain exceptions
# ---------------------------------------------------------------------------

class ManualDlmsError(Exception):
    """Base exception for all Manual DLMS errors."""


class InvalidInputError(ManualDlmsError):
    """Raised when input is too short or has incorrect format."""


class XmlParseError(ManualDlmsError):
    """Raised when XML input cannot be parsed."""


class EncodingError(ManualDlmsError):
    """Raised when XDR encoding or decoding fails."""


class DlmsOverSizeError(ManualDlmsError):
    """Raised when a PDU exceeds the allowed maximum size (~110 bytes).

    Mirrors the legacy DLMS_OverSize error code from Dialog_ManualCmd.
    """


class UnsupportedFrameTagWarning(UserWarning):
    """Emitted (as a warning, not an exception) when a raw frame tag is not
    one of the expected DLMS response tags: C0, C1, C3."""


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclass
class DlmsResult:
    """Result of a single DLMS operation (GET, SET, or ACTION)."""

    success: bool
    xdr: str = ""         # Raw XDR payload as uppercase hex (GET/ACTION responses)
    xml: str = ""         # XML representation of the XDR payload
    error: str = ""       # Human-readable error name (e.g. "SCOPE_OF_ACCESS_VIOLATED")
    error_code: int = 0   # Numeric error code from DataAccessResult


@dataclass
class WithListResult:
    """Aggregated result for a WITH-LIST batch operation."""

    items: list[DlmsResult] = field(default_factory=list)
    global_success: bool = True
    error: str = ""       # Top-level error (e.g., pre-encode failure, transport error)


# ---------------------------------------------------------------------------
# XdrCodec interface
# ---------------------------------------------------------------------------

class XdrCodec(ABC):
    """
    Abstraction over XML ↔ XDR (hex) conversion.

    Implementations must handle the DLMS/COSEM data-type XML format used by
    the ng_sdk (e.g. <Unsigned8>42</Unsigned8>, <Structure>…</Structure>).
    """

    @abstractmethod
    def encode(self, xml_input: str) -> str:
        """Convert an XML representation to an uppercase XDR hex string.

        Raises:
            EncodingError: if the XML cannot be converted.
        """

    @abstractmethod
    def decode(self, hex_input: str) -> str:
        """Convert an XDR hex string to a pretty-printed XML string.

        Raises:
            EncodingError: if the hex cannot be decoded.
        """


# ---------------------------------------------------------------------------
# DlmsAdapter interface
# ---------------------------------------------------------------------------

class DlmsAdapter(ABC):
    """
    Abstraction over the DLMS protocol stack.

    All methods are synchronous (blocking).  The gRPC service layer is
    responsible for running them in a thread pool (asyncio.to_thread) so
    that the asyncio event loop stays responsive.
    """

    # ---- Single-object operations ----------------------------------------

    @abstractmethod
    def cosem_get(self, class_id: int, obis: str, attribute: int) -> DlmsResult:
        """Execute a COSEM GET request.

        Args:
            class_id:  DLMS/COSEM class identifier.
            obis:      Logical name as a hex string (e.g. "0000010000FF").
            attribute: Attribute index (≥ 1).

        Returns:
            DlmsResult with xdr/xml populated on success.
        """

    @abstractmethod
    def cosem_set(
        self, class_id: int, obis: str, attribute: int, xdr_hex: str
    ) -> DlmsResult:
        """Execute a COSEM SET request.

        Args:
            xdr_hex: XDR payload as uppercase hex (already encoded).
        """

    @abstractmethod
    def cosem_action(
        self, class_id: int, obis: str, attribute: int, xdr_hex: str
    ) -> DlmsResult:
        """Execute a COSEM ACTION request.

        Args:
            xdr_hex: Method parameter as XDR hex. Pass empty string for
                     methods that take no parameter.
        """

    # ---- Batch (WITH-LIST) operations -------------------------------------

    @abstractmethod
    def cosem_get_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """Execute a GET-WITH-LIST for multiple objects in a single PDU.

        Each dict in *requests* must have keys:
            "class_id" (int), "obis" (str), "attribute" (int)
        """

    @abstractmethod
    def cosem_set_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """Execute a SET-WITH-LIST.

        Each dict must have keys:
            "class_id", "obis", "attribute", "xdr_hex" (str, already encoded)

        Raises:
            DlmsOverSizeError: when the PDU exceeds the maximum allowed size.
        """

    @abstractmethod
    def cosem_action_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """Execute an ACTION-WITH-LIST.

        Each dict must have keys:
            "class_id", "obis", "attribute", "xdr_hex" (str or empty str)

        Raises:
            DlmsOverSizeError: when the PDU exceeds the maximum allowed size.
        """

    # ---- Raw frame --------------------------------------------------------

    @abstractmethod
    def send_frame(self, hex_frame: str) -> str:
        """Send a raw DLMS APDU frame and return the response as an uppercase
        hex string.

        The caller is responsible for the tag-validation warning
        (UnsupportedFrameTagWarning) before calling this method.
        """
