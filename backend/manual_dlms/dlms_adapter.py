"""
manual_dlms/dlms_adapter.py
===========================
Concrete DlmsAdapter implementation backed by ng_sdk's AbstractFrameExecutor
and AbstractCommunication.

This adapter is instantiated at runtime and injected into ManualDlmsCore via
the constructor (dependency injection).  It never holds application state
beyond the executor/communication references it receives.
"""

from __future__ import annotations

import warnings
from xml.etree.ElementTree import tostring

from ng_sdk.communication.abstract_communication import AbstractCommunication
from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import (
    DLMSActionRequestNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import (
    DLMSActionResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_with_list import (
    DLMSActionResponseWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import (
    DLMSGetRequestNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import (
    DLMSGetResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_with_list import (
    DLMSGetResponseWithList,
)
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import (
    DLMSSetRequestNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal import (
    DLMSSetResponseNormal,
)
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_with_list import (
    DLMSSetResponseWithList,
)
from ng_sdk.frame_executor.abstract_frame_executor import AbstractFrameExecutor

from manual_dlms.interfaces import (
    DlmsAdapter,
    DlmsOverSizeError,
    DlmsResult,
    UnsupportedFrameTagWarning,
)

# Error code returned by the meter when the PDU is too large.
# Matches the legacy DLMS_OverSize constant.
_OVER_SIZE_ERROR_CODE = 2

# Tags that identify a well-formed DLMS APDU start byte.
_VALID_FRAME_TAGS = frozenset({"C0", "C1", "C3"})


class NgSdkDlmsAdapter(DlmsAdapter):
    """
    Production DlmsAdapter that delegates to:
      - ng_sdk AbstractFrameExecutor  (GET / SET / ACTION, including WITH-LIST)
      - ng_sdk AbstractCommunication  (raw frame transceive)

    Both dependencies are injected via the constructor; neither is looked up
    from the global MeterContext here, keeping this class testable in isolation.
    """

    def __init__(
        self,
        frame_executor: AbstractFrameExecutor,
        communication: AbstractCommunication,
    ) -> None:
        self._executor = frame_executor
        self._communication = communication

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _extract_response_data(response) -> tuple[str, str]:
        """Return (xml_str, xdr_hex) from a successful response.data object.
        Returns ("", "") when response has no data.
        """
        data = getattr(response, "data", None)
        if data is None:
            return "", ""
        try:
            xml_str = tostring(data.to_xml(), encoding="unicode")
            xdr_hex = data.to_bytes().hex().upper()
            return xml_str, xdr_hex
        except Exception:
            return "", ""

    @staticmethod
    def _extract_action_response_data(response) -> tuple[str, str]:
        """Extract return_parameter data from an ACTION response."""
        try:
            rp = response.return_parameter
            if rp is None or rp.data is None:
                return "", ""
            xml_str = tostring(rp.data.to_xml(), encoding="unicode")
            xdr_hex = rp.data.to_bytes().hex().upper()
            return xml_str, xdr_hex
        except Exception:
            return "", ""

    @staticmethod
    def _check_over_size(error_code: int) -> None:
        """Raise DlmsOverSizeError if the error code signals PDU overflow."""
        if error_code == _OVER_SIZE_ERROR_CODE:
            raise DlmsOverSizeError(
                "Operation failed: PDU exceeds maximum allowed size (~110 bytes). "
                "Reduce the number of objects or disable GBT."
            )

    # ------------------------------------------------------------------
    # Single-object operations
    # ------------------------------------------------------------------

    def cosem_get(self, class_id: int, obis: str, attribute: int) -> DlmsResult:
        request = DLMSGetRequestNormal(class_id, obis, attribute)
        response: DLMSGetResponseNormal = self._executor.execute(request)
        success = response.is_success()
        xml_str, xdr_hex = self._extract_response_data(response) if success else ("", "")
        return DlmsResult(
            success=success,
            xdr=xdr_hex,
            xml=xml_str,
            error="" if success else response.data_access_result.name,
            error_code=0 if success else response.data_access_result.value,
        )

    def cosem_set(
        self, class_id: int, obis: str, attribute: int, xdr_hex: str
    ) -> DlmsResult:
        payload = bytes.fromhex(xdr_hex) if xdr_hex else b""
        request = DLMSSetRequestNormal(class_id, obis, attribute, payload)
        response: DLMSSetResponseNormal = self._executor.execute(request)
        success = response.is_success()
        error_code = 0 if success else response.data_access_result.value
        self._check_over_size(error_code)
        return DlmsResult(
            success=success,
            error="" if success else response.data_access_result.name,
            error_code=error_code,
        )

    def cosem_action(
        self, class_id: int, obis: str, attribute: int, xdr_hex: str
    ) -> DlmsResult:
        payload = bytes.fromhex(xdr_hex) if xdr_hex and xdr_hex.strip() else None
        request = DLMSActionRequestNormal(class_id, obis, attribute, payload)
        response: DLMSActionResponseNormal = self._executor.execute(request)
        success = response.is_success()
        xml_str, xdr_out = self._extract_action_response_data(response) if success else ("", "")
        error_code = 0 if success else response.data_access_result.value
        self._check_over_size(error_code)
        return DlmsResult(
            success=success,
            xdr=xdr_out,
            xml=xml_str,
            error="" if success else response.data_access_result.name,
            error_code=error_code,
        )

    # ------------------------------------------------------------------
    # WITH-LIST batch operations
    # ------------------------------------------------------------------

    def cosem_get_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """GET-WITH-LIST.  Each dict: {class_id, obis, attribute}."""
        frame_requests = [
            DLMSGetRequestNormal(r["class_id"], r["obis"], r["attribute"])
            for r in requests
        ]
        with_list_response: DLMSGetResponseWithList = self._executor.execute_list(
            frame_requests
        )
        results: list[DlmsResult] = []
        for item in with_list_response.result:
            success = item.data_access_result == DataAccessResult.SUCCESS
            xml_str, xdr_hex = ("", "")
            if success and item.data is not None:
                xml_str = tostring(item.data.to_xml(), encoding="unicode")
                xdr_hex = item.data.to_bytes().hex().upper()
            results.append(
                DlmsResult(
                    success=success,
                    xdr=xdr_hex,
                    xml=xml_str,
                    error="" if success else item.data_access_result.name,
                    error_code=0 if success else item.data_access_result.value,
                )
            )
        return results

    def cosem_set_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """SET-WITH-LIST.  Each dict: {class_id, obis, attribute, xdr_hex}."""
        frame_requests = [
            DLMSSetRequestNormal(
                r["class_id"],
                r["obis"],
                r["attribute"],
                bytes.fromhex(r.get("xdr_hex") or ""),
            )
            for r in requests
        ]
        with_list_response: DLMSSetResponseWithList = self._executor.execute_list(
            frame_requests
        )
        results: list[DlmsResult] = []
        for item in with_list_response.result:
            # SET-WITH-LIST returns DataAccessResult items directly
            success = item == DataAccessResult.SUCCESS
            error_code = 0 if success else item.value
            self._check_over_size(error_code)
            results.append(
                DlmsResult(
                    success=success,
                    error="" if success else item.name,
                    error_code=error_code,
                )
            )
        return results

    def cosem_action_with_list(self, requests: list[dict]) -> list[DlmsResult]:
        """ACTION-WITH-LIST.  Each dict: {class_id, obis, attribute, xdr_hex}."""
        frame_requests = [
            DLMSActionRequestNormal(
                r["class_id"],
                r["obis"],
                r["attribute"],
                bytes.fromhex(r["xdr_hex"]) if r.get("xdr_hex") else None,
            )
            for r in requests
        ]
        with_list_response: DLMSActionResponseWithList = self._executor.execute_list(
            frame_requests
        )
        results: list[DlmsResult] = []
        for item in with_list_response.list_of_responses:
            success = item.result == DataAccessResult.SUCCESS
            xml_str, xdr_out = ("", "")
            if success:
                xml_str, xdr_out = self._extract_action_response_data(item)
            error_code = 0 if success else item.result.value
            self._check_over_size(error_code)
            results.append(
                DlmsResult(
                    success=success,
                    xdr=xdr_out,
                    xml=xml_str,
                    error="" if success else item.result.name,
                    error_code=error_code,
                )
            )
        return results

    # ------------------------------------------------------------------
    # Raw frame
    # ------------------------------------------------------------------

    def send_frame(self, hex_frame: str) -> str:
        """Transceive a raw APDU over the communication layer.

        Returns the response as an uppercase hex string.
        """
        frame_bytes = bytes.fromhex(hex_frame.strip().upper())
        response_bytes: bytes = self._communication.transceive(frame_bytes)
        return response_bytes.hex().upper()
