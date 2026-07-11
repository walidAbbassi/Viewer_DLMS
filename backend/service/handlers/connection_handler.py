"""
ConnectionHandler — InitMeterContext, Connect, Disconnect.
SRP : uniquement responsable du cycle de vie de la connexion DLMS.
"""
from ng_sdk.communication.abstract_communication import AbstractCommunication
from ng_sdk.communication.hdlc_communication import HDLCCommunication
from ng_sdk.communication.hdlc_mode_e_communication import HDLCModeECommunication
from ng_sdk.communication.lower.serial_communication import SerialCommunication
from ng_sdk.configuration.config_manager import ConfigModuleProxy
from ng_sdk.frame_builder.dlms.dlms_frame_builder import DLMSFrameBuilder
from ng_sdk.frame_executor.dlms.dlms_executor import DLMSExecutor
from ng_sdk.frame_executor.dlms.gbt_dlms_executor import GBTDLMSExecutor
from ng_sdk.frame_executor.dlms.simulation_dlms_executor import SimulationDLMSExecutor
from ng_sdk.security.security_context import SecurityContext
from ng_sdk.session.abstract_session import AbstractSession
from ng_sdk.session.dlms_hls_session import DLMSHlsSession
from ng_sdk.session.dlms_password_session import DLMSPasswordSession
from ng_sdk.session.dlms_session import DLMSSession
from ng_sdk.transport.hdlc.hdlc_transport import HDLCTransport

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.grpc_exception import grpc_exception_handler
from logger.logging_setup import retry_queue, _suppress_retry_lock, _had_retry
from logger import logging_setup as _ls


def _retry_hook_on_retry(attempt: int, max_retries: int) -> None:
    """Called by SerialCommunication on each retry."""
    with _suppress_retry_lock:
        if _ls._suppress_retry_count > 0:
            return
    _had_retry.set()
    display_attempt = attempt - 1
    try:
        retry_queue.put_nowait({
            "attempt": display_attempt,
            "max_attempts": max_retries,
            "all_failed": False,
            "message": f"Attempt {display_attempt}/{max_retries}: no response from meter",
        })
    except Exception:
        pass


def _retry_hook_on_meter_unreachable(max_retries: int) -> None:
    """Called by SerialCommunication when all retries are exhausted."""
    with _suppress_retry_lock:
        if _ls._suppress_retry_count > 0:
            return
    try:
        retry_queue.put_nowait({
            "attempt": max_retries,
            "max_attempts": max_retries,
            "all_failed": True,
            "message": f"All {max_retries} attempts failed, meter not responding",
        })
    except Exception:
        pass


class ConnectionHandler(BaseHandler):
    """Gère InitMeterContext, Connect et Disconnect."""

    @grpc_exception_handler
    async def InitMeterContext(self, stream):
        configuration = MeterContext.configuration.association
        init_request = await stream.recv_message()
        module_name = init_request.modulename
        MeterContext.module_name = module_name

        if configuration.Public.simulation.enabled:
            MeterContext.frame_executor = SimulationDLMSExecutor(
                configuration.Public.simulation.path
            )
        else:
            MeterContext.communication = self.__init_communication(configuration[module_name])
            MeterContext.communication.set_retry_hooks(
                on_retry=_retry_hook_on_retry,
                on_meter_unreachable=_retry_hook_on_meter_unreachable,
            )
            MeterContext.security_context = self.__init_security(configuration[module_name])
            MeterContext.session = self.__init_session(
                configuration[module_name],
                MeterContext.security_context,
                MeterContext.communication,
            )
            if configuration[module_name].features_activation.general_block_transfer:
                MeterContext.frame_executor = GBTDLMSExecutor(
                    MeterContext.communication,
                    DLMSFrameBuilder(configuration[module_name], MeterContext.security_context),
                    configuration[module_name],
                )
            else:
                MeterContext.frame_executor = DLMSExecutor(
                    MeterContext.communication,
                    DLMSFrameBuilder(configuration[module_name], MeterContext.security_context),
                    configuration[module_name],
                )
        await stream.send_message(meter_pb2.BoolValue(value=True))

    @grpc_exception_handler
    async def Connect(self, stream):
        if MeterContext.configuration.association.Public.simulation.enabled:
            await stream.send_message(meter_pb2.BoolValue(value=True))
            return

        if MeterContext.session.configuration.security.frame_counter_param.get_frame_counter:
            public_communication = self.__init_communication(
                MeterContext.configuration.association.Public
            )
            public_session = DLMSSession(
                MeterContext.configuration.association.Public, public_communication
            )
            public_session.open()
            public_session.get_frame_counter(MeterContext.session.configuration)
            public_session.close()
            MeterContext.session.configuration.security.frame_counter = (
                MeterContext.configuration.association.Public.security.frame_counter
            )
        else:
            MeterContext.session.configuration.security.frame_counter = (
                MeterContext.session.configuration.security.frame_counter_param.proposed_frame_counter_value
            )

        MeterContext.session.open()
        if (
            MeterContext.session.is_established
            and MeterContext.session.configuration.communication.keep_connection.enabled
        ):
            MeterContext.frame_executor.start_keepalive()
        await stream.send_message(
            meter_pb2.BoolValue(value=MeterContext.session.is_established)
        )

    @grpc_exception_handler
    async def Disconnect(self, stream):
        if MeterContext.configuration.association.Public.simulation.enabled:
            await stream.send_message(meter_pb2.BoolValue(value=True))
            return

        if MeterContext.session.configuration.communication.keep_connection.enabled:
            MeterContext.frame_executor.stop_keepalive()
        MeterContext.session.close()
        await stream.send_message(
            meter_pb2.BoolValue(value=not MeterContext.session.is_established)
        )

    # ── Private helpers ──────────────────────────────────────────────────────

    def __init_communication(self, configuration: ConfigModuleProxy) -> AbstractCommunication:
        communication = SerialCommunication(configuration)
        is_hdlc = configuration.communication.transport_type == "HDLC"
        is_mode_e = configuration.communication.mode_com == "Mode_E"
        if is_hdlc:
            if is_mode_e:
                communication = HDLCModeECommunication(
                    configuration, communication, is_complete=HDLCTransport.hdlc_complete
                )
            else:
                communication = HDLCCommunication(
                    configuration, communication, is_complete=HDLCTransport.hdlc_complete
                )
        return communication

    def __init_security(self, configuration: ConfigModuleProxy) -> SecurityContext:
        if configuration.security.ciphering_type == "NO_CIPHERING":
            return None
        return SecurityContext(configuration)

    def __init_session(
        self,
        configuration: ConfigModuleProxy,
        security_context: SecurityContext,
        communication: AbstractCommunication,
    ) -> AbstractSession:
        session_type = configuration.security.session_type
        if session_type == "LLS":
            return DLMSPasswordSession(configuration, communication)
        elif session_type == "HLS":
            return DLMSHlsSession(communication, security_context, configuration)
        else:
            return DLMSSession(configuration, communication)

