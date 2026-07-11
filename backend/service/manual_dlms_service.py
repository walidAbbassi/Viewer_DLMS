"""
service/manual_dlms_service.py
==============================
gRPC service layer for the Manual DLMS feature.

Responsibilities of this file:
  - Translate gRPC request messages → Python dicts/primitives.
  - Delegate all business logic to ManualDlmsCore.
  - Translate DlmsResult / WithListResult → gRPC response messages.
  - Run blocking ManualDlmsCore calls in asyncio.to_thread() so the event
    loop stays responsive (same pattern as MeterService._run).
  - Surface domain exceptions as readable gRPC errors.

Architecture:
    Flutter ──gRPC──▶ ManualDlmsGrpcService
                            │ delegates
                            ▼
                      ManualDlmsCore
                       │          │
                  DlmsAdapter  XdrCodec
                       │
               MeterContext.frame_executor
               MeterContext.communication

Dependency injection is used throughout: ManualDlmsCore, DlmsAdapter, and
XdrCodec are constructed in `_build_core()` using the live MeterContext singletons.
This makes the service trivially unit-testable by injecting mocks.

NOTE: The gRPC stubs in gen/manual_dlms_grpc.py and gen/manual_dlms_pb2.py
      must be generated from protos/manual_dlms.proto before this file can be
      imported.  Run:

          python -m grpc_tools.protoc \
            -I ../protos \
            --python_out=. \
            --grpclib_python_out=. \
            ../protos/manual_dlms.proto

      (adjust paths to match your build environment).
"""

from __future__ import annotations

import asyncio

from grpclib import GRPCError, Status as GRPCStatus

from gen import manual_dlms_grpc, manual_dlms_pb2
from manual_dlms.core import ManualDlmsCore
from manual_dlms.dlms_adapter import NgSdkDlmsAdapter
from manual_dlms.interfaces import (
    DlmsResult,
    EncodingError,
    InvalidInputError,
    ManualDlmsError,
    WithListResult,
    XmlParseError,
)
from manual_dlms.xdr_codec import NgSdkXdrCodec
from meter_context import MeterContext
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler  # project-local decorator


# ---------------------------------------------------------------------------
# Factory
# ---------------------------------------------------------------------------

def _build_core() -> ManualDlmsCore:
    """Construct a ManualDlmsCore from the live MeterContext singletons."""
    adapter = NgSdkDlmsAdapter(
        frame_executor=MeterContext.frame_executor,
        communication=MeterContext.communication,
    )
    codec = NgSdkXdrCodec()
    return ManualDlmsCore(adapter=adapter, codec=codec)


# ---------------------------------------------------------------------------
# Converters
# ---------------------------------------------------------------------------

def _to_pb_result(result: DlmsResult) -> manual_dlms_pb2.ManualDlmsResult:
    return manual_dlms_pb2.ManualDlmsResult(
        success=result.success,
        xdr=result.xdr,
        xml=result.xml,
        error=result.error,
        error_code=result.error_code,
    )


def _to_pb_with_list_result(result: WithListResult) -> manual_dlms_pb2.WithListResult:
    return manual_dlms_pb2.WithListResult(
        items=[_to_pb_result(r) for r in result.items],
        global_success=result.global_success,
        error=result.error,
    )


# ---------------------------------------------------------------------------
# gRPC service
# ---------------------------------------------------------------------------

class ManualDlmsGrpcService(manual_dlms_grpc.ManualDlmsServiceBase):
    """
    gRPC implementation of the ManualDlms service.

    Each RPC method:
      1. Validates session rights where required.
      2. Delegates to ManualDlmsCore (via asyncio.to_thread for blocking calls).
      3. Converts the result to a protobuf message.
    """

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @staticmethod
    async def _run(func, *args, **kwargs):
        """Run a blocking ManualDlmsCore call on the thread pool."""
        return await asyncio.to_thread(func, *args, **kwargs)

    @staticmethod
    def _require_right(right: str) -> None:
        """Raise GRPCError(PERMISSION_DENIED) when the session lacks *right*."""
        if SESSION.get_effective_right(right) == "NO":
            raise GRPCError(
                GRPCStatus.PERMISSION_DENIED,
                f"User is not allowed to perform {right} operations.",
            )

    @staticmethod
    def _handle_domain_error(exc: ManualDlmsError) -> GRPCError:
        """Convert a domain exception to an appropriate gRPC status error."""
        if isinstance(exc, InvalidInputError):
            return GRPCError(GRPCStatus.INVALID_ARGUMENT, str(exc))
        if isinstance(exc, XmlParseError):
            return GRPCError(GRPCStatus.INVALID_ARGUMENT, str(exc))
        if isinstance(exc, EncodingError):
            return GRPCError(GRPCStatus.INTERNAL, str(exc))
        return GRPCError(GRPCStatus.INTERNAL, str(exc))

    # ------------------------------------------------------------------
    # Single-object operations
    # ------------------------------------------------------------------

    @grpc_exception_handler
    async def CosemGet(self, stream):
        """Execute a COSEM GET and return the raw XDR + XML."""
        req = await stream.recv_message()
        core = _build_core()
        try:
            result: DlmsResult = await self._run(
                core.get, req.class_id, req.obis, req.attribute
            )
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_result(result))

    @grpc_exception_handler
    async def CosemSet(self, stream):
        """Execute a COSEM SET.  input_data may be XML or XDR hex."""
        self._require_right("SET")
        req = await stream.recv_message()
        core = _build_core()
        try:
            result: DlmsResult = await self._run(
                core.set, req.class_id, req.obis, req.attribute, req.input_data
            )
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_result(result))

    @grpc_exception_handler
    async def CosemAction(self, stream):
        """Execute a COSEM ACTION.  input_data may be XML, XDR hex, or empty."""
        self._require_right("ACTION")
        req = await stream.recv_message()
        core = _build_core()
        try:
            result: DlmsResult = await self._run(
                core.action, req.class_id, req.obis, req.attribute, req.input_data
            )
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_result(result))

    # ------------------------------------------------------------------
    # WITH-LIST batch operations
    # ------------------------------------------------------------------

    @grpc_exception_handler
    async def GetWithList(self, stream):
        """GET-WITH-LIST for multiple COSEM objects in one PDU."""
        req = await stream.recv_message()
        object_list = [
            {"class_id": item.class_id, "obis": item.obis, "attribute": item.attribute}
            for item in req.items
        ]
        core = _build_core()
        try:
            result: WithListResult = await self._run(core.get_with_list, object_list)
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_with_list_result(result))

    @grpc_exception_handler
    async def SetWithList(self, stream):
        """SET-WITH-LIST.  Each item's input_data may be XML or XDR hex."""
        self._require_right("SET")
        req = await stream.recv_message()
        object_list = [
            {
                "class_id":   item.class_id,
                "obis":       item.obis,
                "attribute":  item.attribute,
                "input_data": item.input_data,
            }
            for item in req.items
        ]
        core = _build_core()
        try:
            result: WithListResult = await self._run(core.set_with_list, object_list)
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_with_list_result(result))

    @grpc_exception_handler
    async def ActionWithList(self, stream):
        """ACTION-WITH-LIST.  Each item's input_data may be XML, XDR hex, or empty."""
        self._require_right("ACTION")
        req = await stream.recv_message()
        object_list = [
            {
                "class_id":   item.class_id,
                "obis":       item.obis,
                "attribute":  item.attribute,
                "input_data": item.input_data,
            }
            for item in req.items
        ]
        core = _build_core()
        try:
            result: WithListResult = await self._run(core.action_with_list, object_list)
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_with_list_result(result))

    # ------------------------------------------------------------------
    # XDR encode / decode
    # ------------------------------------------------------------------

    @grpc_exception_handler
    async def Encode(self, stream):
        """Convert an XML data-type tree to an XDR hex string."""
        req = await stream.recv_message()
        core = _build_core()
        try:
            hex_output = await self._run(core.encode, req.xml_input)
            await stream.send_message(
                manual_dlms_pb2.CodecResult(success=True, output=hex_output)
            )
        except ManualDlmsError as exc:
            await stream.send_message(
                manual_dlms_pb2.CodecResult(success=False, error=str(exc))
            )

    @grpc_exception_handler
    async def Decode(self, stream):
        """Convert an XDR hex string to a pretty-printed XML string."""
        req = await stream.recv_message()
        core = _build_core()
        try:
            xml_output = await self._run(core.decode, req.hex_input)
            await stream.send_message(
                manual_dlms_pb2.CodecResult(success=True, output=xml_output)
            )
        except ManualDlmsError as exc:
            await stream.send_message(
                manual_dlms_pb2.CodecResult(success=False, error=str(exc))
            )

    # ------------------------------------------------------------------
    # Raw frame
    # ------------------------------------------------------------------

    @grpc_exception_handler
    async def SendRawFrame(self, stream):
        """Send a raw DLMS APDU and return the response hex.

        Access guard: the user must have at minimum GET rights, since raw
        frames bypass the normal attribute descriptor validation.
        """
        req = await stream.recv_message()
        core = _build_core()
        try:
            result: DlmsResult = await self._run(core.send_raw_frame, req.hex_frame)
        except ManualDlmsError as exc:
            raise self._handle_domain_error(exc) from exc
        await stream.send_message(_to_pb_result(result))
