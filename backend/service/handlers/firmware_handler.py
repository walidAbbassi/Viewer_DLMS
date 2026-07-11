"""
FirmwareHandler — cycle de vie complet du transfert firmware (Image Transfer Class 18).
SRP : uniquement les opérations liées au firmware.
"""
import os
from time import sleep

from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import DLMSActionRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import DLMSActionResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.data_type.array import ArrayData
from ng_sdk.frame_builder.dlms.xdlms.data_type.boolean import BooleanData
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8 import Integer8
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32 import Unsigned32
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal import DLMSSetResponseNormal
from grpclib import GRPCError, Status as GRPCStatus

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler
from utils_any import read_file_chunks
import asyncio


class FirmwareHandler(BaseHandler):
    """Gère EnableImageTransfer, InitiateTransfer, TransferFile, VerifyTransfert,
    ResendMissingChunks, ResumeTransfer, ActivateFirmware, et les dates d'activation."""

    def _get_image_transfer_object(self):
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == "ImageTransfer"), None)
        return obj

    @grpc_exception_handler
    async def EnableImageTransfer(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to enable image transfer")

        obj = self._get_image_transfer_object()
        response_enable = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(
                obj["classId"], obj["logicalName_hex"], 5,
                BooleanData(value=True).to_bytes(),
            ),
        )
        if not isinstance(response_enable, DLMSSetResponseNormal) or not response_enable.is_success():
            await stream.send_message(meter_pb2.BoolValue(value=False))
            return

        response_check = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(18, "00002C0000FF", 5),
        )
        if isinstance(response_check, DLMSGetResponseNormal):
            await stream.send_message(
                meter_pb2.BoolValue(value=response_check.data.value)
            )
        else:
            await stream.send_message(meter_pb2.BoolValue(value=False))

    @grpc_exception_handler
    async def InitiateTransfer(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to initiate firmware transfer")

        front_request = await stream.recv_message()
        obj = self._get_image_transfer_object()
        initiate_data = StructureData(value=[
            OctetStringData(value=bytes.fromhex(front_request.imageId)),
            Unsigned32(value=os.path.getsize(front_request.path_file)),
        ])
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSActionRequestNormal(
                obj["classId"], obj["logicalName_hex"], 1, initiate_data.to_bytes()
            ),
        )
        if isinstance(response, DLMSActionResponseNormal):
            await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))
        else:
            await stream.send_message(meter_pb2.BoolValue(value=False))

    @grpc_exception_handler
    async def TransferFile(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to transfer firmware blocks")

        front_request = await stream.recv_message()
        obj = self._get_image_transfer_object()
        chunks = read_file_chunks(front_request.path_file, front_request.block_size)
        for i, chunk in enumerate(chunks):
            block_data = StructureData(value=[Unsigned32(value=i), OctetStringData(value=chunk)])
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 2, block_data.to_bytes()
                ),
            )
            if not isinstance(response, DLMSActionResponseNormal) or not response.is_success():
                await stream.send_message(meter_pb2.TransferUpdate(
                    block_number=i + 1, message=f"Error:Failed to send block {i+1}"
                ))
            else:
                await stream.send_message(meter_pb2.TransferUpdate(
                    block_number=i + 1, message=f"Succeeded to send block {i+1}"
                ))
            await asyncio.sleep(0.001)

    @grpc_exception_handler
    async def VerifyTransfert(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to verify transfer")

        front_request = await stream.recv_message()
        obj = self._get_image_transfer_object()
        chunks_ok = []
        chunks = read_file_chunks(front_request.path_file, front_request.block_size)
        response_status = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3),
        )
        if isinstance(response_status, DLMSGetResponseNormal) and response_status.is_success():
            bit_string_result = response_status.data.value
            chunks_as_list = list(chunks)
            for i in range(len(chunks_as_list)):
                if i < len(bit_string_result):
                    chunks_ok.append(bit_string_result[i] == "1")
                else:
                    chunks_ok.append(False)
        await stream.send_message(meter_pb2.VerifyTransfertResponse(chunks_ok=chunks_ok))

    @grpc_exception_handler
    async def ResendMissingChunks(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to resend missing chunks")

        front_request = await stream.recv_message()
        obj = self._get_image_transfer_object()
        response_status = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3),
        )
        if isinstance(response_status, DLMSGetResponseNormal) and response_status.is_success():
            chunks = read_file_chunks(front_request.path_file, front_request.block_size)
            bit_string_result = response_status.data.value
            to_resend = {}
            chunks_as_list = list(chunks)
            for i in range(len(chunks_as_list)):
                if i >= len(bit_string_result) or bit_string_result[i] == "0":
                    to_resend[i] = chunks_as_list[i]
            if not to_resend:
                print("All chunks have been successfully transferred")
            else:
                for key, value in to_resend.items():
                    block_data = StructureData(value=[
                        Unsigned32(value=key), OctetStringData(value=value)
                    ])
                    response = await self._run(
                        MeterContext.frame_executor.execute,
                        DLMSActionRequestNormal(
                            obj["classId"], obj["logicalName_hex"], 2, block_data.to_bytes()
                        ),
                    )
                    if isinstance(response, DLMSActionResponseNormal) and not response.is_success():
                        await stream.send_message(meter_pb2.TransferUpdate(
                            block_number=key + 1,
                            message=f"Error:Failed to send block {key+1}",
                        ))
                    else:
                        await stream.send_message(meter_pb2.TransferUpdate(
                            block_number=key + 1,
                            message=f"Succeeded to send block {key+1}",
                        ))
                    await asyncio.sleep(0.001)

    @grpc_exception_handler
    async def ResumeTransfer(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to resume firmware transfer")

        front_request = await stream.recv_message()
        obj = self._get_image_transfer_object()
        chunks = read_file_chunks(front_request.path_file, front_request.block_size)
        start_block = front_request.start_block
        for i, chunk in enumerate(chunks):
            if i < start_block:
                continue
            block_data = StructureData(value=[Unsigned32(value=i), OctetStringData(value=chunk)])
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 2, block_data.to_bytes()
                ),
            )
            if not isinstance(response, DLMSActionResponseNormal) or not response.is_success():
                await stream.send_message(meter_pb2.TransferUpdate(
                    block_number=i + 1, message=f"Error:Failed to send block {i+1}"
                ))
            else:
                await stream.send_message(meter_pb2.TransferUpdate(
                    block_number=i + 1, message=f"Succeeded to send block {i+1}"
                ))
            await asyncio.sleep(0.001)

    @grpc_exception_handler
    async def ActivateFirmware(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to activate firmware")

        obj = self._get_image_transfer_object()
        if obj is None:
            raise GRPCError(
                GRPCStatus.NOT_FOUND,
                "ImageTransfer object not found in datamodel. Check meter configuration.",
            )
        try:
            response_verify = await self._run(
                MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 3, Integer8(value=0).to_bytes()
                ),
            )
            if not isinstance(response_verify, DLMSActionResponseNormal):
                await stream.send_message(meter_pb2.ActivateFirmwareResponse(
                    success=False,
                    message=f"Image verify failed (Method 3): {response_verify}",
                ))
                return
            if not response_verify.is_success():
                print(
                    f"[ActivateFirmware] image_verify (Method 3) returned non-success — continuing"
                )

            response_activate = await self._run(
                MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 4, Integer8(value=0).to_bytes()
                ),
            )
            if not isinstance(response_activate, DLMSActionResponseNormal):
                print(
                    f"[ActivateFirmware] Method 4 returned non-action response (likely RLRE/reboot)"
                )
                await stream.send_message(meter_pb2.ActivateFirmwareResponse(
                    success=True, message="Meter is rebooting"
                ))
            elif response_activate.return_parameter.data_access_result == DataAccessResult.TEMPORARY_FAILURE:
                # A temporary failure can mean two things:
                #   (a) The meter genuinely rejected the command → image_activation_failed (status 7)
                #   (b) The meter accepted the command and sent a temporary failure response
                #       just before closing the DLMS session for reboot.
                # Read attribute 6 (image_transfer_status) to disambiguate:
                #   • If we CAN read it and status == 7 → real failure, report it.
                #   • If we CAN read it and status == 5/6 → activation in progress/done, treat as reboot.
                #   • If the read raises a comm error → session already closed → meter is rebooting.
                _IMAGE_ACTIVATION_FAILED = 7
                _IMAGE_ACTIVATION_INITIATED = 5
                _IMAGE_ACTIVATION_SUCCESSFUL = 6
                try:
                    _status_resp = await self._run(
                        MeterContext.frame_executor.execute,
                        DLMSGetRequestNormal(object["classId"], object["logicalName_hex"], 6),
                    )
                    if (
                            isinstance(_status_resp, DLMSGetResponseNormal)
                            and _status_resp.is_success()
                            and _status_resp.data is not None
                    ):
                        _status_val = int(_status_resp.data.to_python())
                    else:
                        _status_val = None

                    if _status_val == _IMAGE_ACTIVATION_FAILED:
                        # Meter confirmed failure — not rebooting.
                        print(
                            f"[ActivateFirmware] temporary_failure confirmed as image_activation_failed (status=7)"
                        )
                        await stream.send_message(
                            meter_pb2.ActivateFirmwareResponse(
                                success=False,
                                message=f"Image activation failed (image_activation_failed state): {_status_val}",
                            )
                        )
                    elif _status_val in (_IMAGE_ACTIVATION_INITIATED, _IMAGE_ACTIVATION_SUCCESSFUL):
                        # Activation accepted — meter will reboot shortly.
                        print(
                            f"[ActivateFirmware] temporary_failure but status={_status_val} — treating as reboot"
                        )
                        await stream.send_message(
                            meter_pb2.ActivateFirmwareResponse(
                                success=True, message="Meter is rebooting"
                            )
                        )
                    else:
                        # Unexpected or unreadable status — report original failure.
                        await stream.send_message(
                            meter_pb2.ActivateFirmwareResponse(
                                success=False,
                                message=f"Image activation temporarily failed (Method 4, status={_status_val}): {_status_val}",
                            )
                        )
                except (ConnectionResetError, BrokenPipeError, TimeoutError, OSError, IndexError):
                    # Session already closed → meter is rebooting.
                    print(
                        "[ActivateFirmware] comm error reading status after temporary_failure — treating as reboot"
                    )
                    await stream.send_message(
                        meter_pb2.ActivateFirmwareResponse(
                            success=True, message="Meter is rebooting"
                        )
                    )
            elif response_activate.return_parameter.data_access_result == DataAccessResult.OTHER_REASON:
                # Some meters return "other reason" for image_activate failure instead of "temporary failure" (status 1).
                # Treat as real failure without attempting to disambiguate via status read.
                await stream.send_message(
                    meter_pb2.ActivateFirmwareResponse(
                        success=False,
                        message=f"Image activation failed (Method 4, other reason)",
                    )
                )

            elif not response_activate.is_success():
                await stream.send_message(meter_pb2.ActivateFirmwareResponse(
                    success=False,
                    message=f"Image activation failed (Method 4): {response_activate}",
                ))
            else:
                await stream.send_message(
                    meter_pb2.ActivateFirmwareResponse(success=True, message="")
                )
            # After firmware activation (success or failure), always close the DLMS
            # session so the frontend can return to the connection page with a clean
            # state and reconnect to the rebooted meter.
            try:
                if (
                        MeterContext.session is not None
                        and MeterContext.session.configuration.communication.keep_connection.enabled
                ):
                    MeterContext.frame_executor.stop_keepalive()
            except Exception:
                pass
            try:
                if MeterContext.session is not None:
                    MeterContext.session.close()
            except Exception:
                pass

        except (ConnectionResetError, BrokenPipeError, TimeoutError, OSError,
                IndexError, Exception) as e:
            print(f"[ActivateFirmware] exception after activate ({type(e).__name__}: {e}) — treating as reboot success")
            await stream.send_message(meter_pb2.ActivateFirmwareResponse(
                success=True, message="Meter is rebooting"
            ))

    @grpc_exception_handler
    async def GetImageTransferStatus(self, stream):
        """Read ImageTransfer attribute 6 (image_transfer_status, enum).

        COSEM class 18, attribute 6 returns an unsigned enum:
          0 = image_transfer_not_initiated
          1 = image_transfer_initiated
          2 = image_verification_initiated
          3 = image_verification_successful
          4 = image_verification_failed
          5 = image_activation_initiated
          6 = image_activation_successful
          7 = image_activation_failed
        """
        _STATUS_LABELS = {
            0: "image_transfer_not_initiated",
            1: "image_transfer_initiated",
            2: "image_verification_initiated",
            3: "image_verification_successful",
            4: "image_verification_failed",
            5: "image_activation_initiated",
            6: "image_activation_successful",
            7: "image_activation_failed",
        }
        data_model = MeterContext.configuration.datamodel[
            MeterContext.datamodel
        ].objects
        object = next(
            (item for item in data_model if item["name"] == "ImageTransfer"), None
        )
        if object is None:
            await stream.send_message(
                meter_pb2.ImageTransferStatusResponse(status=-1, label="object_not_found")
            )
            return
        response_status = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(object["classId"], object["logicalName_hex"], 6),
        )
        if (
                isinstance(response_status, DLMSGetResponseNormal)
                and response_status.is_success()
                and response_status.data is not None
        ):
            val = int(response_status.data.to_python())
            label = _STATUS_LABELS.get(val, "unknown")
            await stream.send_message(
                meter_pb2.ImageTransferStatusResponse(status=val, label=label)
            )
        else:
            await stream.send_message(
                meter_pb2.ImageTransferStatusResponse(status=-1, label="read_error")
            )

    @grpc_exception_handler
    async def GetImageTransfertActivationDateTime(self, stream):
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next(
            (item for item in data_model
             if item["name"] == MeterContext.configuration.image_transfert.scheduler),
            None,
        )
        if obj is None:
            raise Exception("Scheduler not found")
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 4),
        )
        if isinstance(response, DLMSGetResponseNormal) and response.data is not None:
            datetime_structure = response.data.to_python()[0]
            await stream.send_message(meter_pb2.ActivationDateTime(
                year=int.from_bytes(datetime_structure[1][:2], "big"),
                month=datetime_structure[1][2],
                day=datetime_structure[1][3],
                hour=datetime_structure[0][0],
                minute=datetime_structure[0][1],
                second=datetime_structure[0][2],
            ))
            return
        raise Exception("Error in reading data")

    @grpc_exception_handler
    async def SetImageTransfertActivationDateTime(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to configure activation datetime")

        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next(
            (item for item in data_model
             if item["name"] == MeterContext.configuration.image_transfert.scheduler),
            None,
        )
        if obj is None:
            raise Exception("Scheduler not found")
        day_week = 0
        date_bytes = bytearray()
        time_bytes = bytearray()
        date_bytes.extend(front_request.year.to_bytes(2, byteorder="big"))
        date_bytes.extend(front_request.month.to_bytes(1, byteorder="big"))
        date_bytes.extend(front_request.day.to_bytes(1, byteorder="big"))
        date_bytes.extend(day_week.to_bytes(1, byteorder="big"))
        time_bytes.extend(front_request.hour.to_bytes(1, byteorder="big"))
        time_bytes.extend(front_request.minute.to_bytes(1, byteorder="big"))
        time_bytes.extend(front_request.second.to_bytes(1, byteorder="big"))
        time_bytes.extend(day_week.to_bytes(1, byteorder="big"))
        datetime_data = ArrayData(value=[StructureData(value=[
            OctetStringData(value=time_bytes),
            OctetStringData(value=date_bytes),
        ])])
        response = await self._run(
            MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4, datetime_data.to_bytes()),
        )
        await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))
