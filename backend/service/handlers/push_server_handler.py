"""
PushServerHandler — StartPushSetupServer, StopPushSetupServer,
                    SendTestNotification, WatchRetryStatus.
SRP : gestion du serveur TCP/UDP de réception des push notifications.
"""
import asyncio
import queue as _queue
import traceback
import xml.etree.ElementTree as ET
from datetime import datetime, timezone

from google.protobuf import empty_pb2

from ng_sdk.communication.abstract_communication import AbstractCommunication
from ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification import DlmsDataNotification
from ng_sdk.frame_builder.dlms.xdlms.data_notification.dlms_data_notification_confirm import DlmsDataNotificationConfirm
from ng_sdk.frame_builder.dlms.xdlms.get_dlms_cipher import GetDlmsCipher
from ng_sdk.logger.logger import get_logger as _get_sdk_logger
from ng_sdk.push_data_server.tcp_server import TcpServer
from ng_sdk.push_data_server.udp_server import UdpServer
from ng_sdk.security.security_context import SecurityContext
from ng_sdk.session.dlms_session import DLMSSession
from ng_sdk.transport.tcp.tcp_transport import TCPUDPTransport
from ng_sdk.util.bytes_util import encode_length

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from logger.logging_setup import retry_queue
from util.grpc_exception import grpc_exception_handler

_logger = _get_sdk_logger()


class PushServerHandler(BaseHandler):
    """Gère le serveur de push notifications et le polling WatchRetryStatus."""

    def __init__(self):
        super().__init__()
        self._push_server = None

    @grpc_exception_handler
    async def StartPushSetupServer(self, stream):
        request = await stream.recv_message()
        loop = asyncio.get_event_loop()

        def _notification_handler(
            notification: DlmsDataNotification,
            addr,
            communication: AbstractCommunication,
            source_port: int,
            dest_port: int,
            server_system_title: bytes,
        ):
            ack_sent_at = None
            ack_error = None

            try:
                session = DLMSSession(MeterContext.configuration.association.Public, communication)
                session.open()
                session.get_frame_counter(MeterContext.configuration.association.LocalManagement)
                session.close()
                local_management = MeterContext.configuration.association.LocalManagement
                security_context = SecurityContext(local_management)
                ciphered_data = security_context.cipher(DlmsDataNotificationConfirm(notification.invoke_id).to_bytes())
                system_title = security_context.get_system_title()
                data_to_send = (
                    bytes([GetDlmsCipher.GENERAL_CIPHERING])
                    + encode_length(len(system_title))
                    + system_title
                    + encode_length(len(ciphered_data))
                    + ciphered_data
                )
                old_dest = communication.configuration.communication.tcp.association_id
                old_src = communication.configuration.communication.tcp.device_id
                communication.configuration.communication.tcp.association_id = dest_port
                communication.configuration.communication.tcp.device_id = source_port
                communication.send(data_to_send)
                ack_sent_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S UTC")
                communication.configuration.communication.tcp.association_id = old_dest
                communication.configuration.communication.tcp.device_id = old_src
            except Exception as e:
                ack_error = str(e)
                traceback.print_exc()
                _logger.error(f"[StartPushSetupServer] Notification Ack not sent: {e}")

            try:
                root = ET.Element("push_notification")
                addr_el = ET.SubElement(root, "source")
                addr_el.set("address", str(addr[0]) if isinstance(addr, tuple) else str(addr))
                addr_el.set("source_port", str(source_port) if source_port is not None else "")
                addr_el.set("dest_port", str(dest_port) if dest_port is not None else "")
                if server_system_title:
                    addr_el.set("system_title", server_system_title.hex())

                iip = notification.invoke_id
                iip_el = ET.SubElement(root, "invoked_id_and_priority")
                if iip is not None:
                    ET.SubElement(iip_el, "invoke_id").text = str(iip.invoke_id)
                    ET.SubElement(iip_el, "reserved").text = str(iip.reserved)
                    ET.SubElement(iip_el, "self_descriptive").text = iip.self_descriptive.name
                    ET.SubElement(iip_el, "processing_option").text = iip.processing_option.name
                    ET.SubElement(iip_el, "service_class_confirmed").text = iip.service_class_confirmed.name
                    ET.SubElement(iip_el, "high_priority").text = iip.high_priority.name

                dt_el = ET.SubElement(root, "date_time")
                dt_el.text = str(notification.date_time) if notification.date_time is not None else "not_specified"

                ack_el = ET.SubElement(root, "ack")
                if ack_sent_at is not None:
                    ack_el.set("sent", "true")
                    ET.SubElement(ack_el, "sent_at").text = ack_sent_at
                else:
                    ack_el.set("sent", "false")
                    ET.SubElement(ack_el, "reason").text = ack_error or "Unknown error"

                data_el = ET.SubElement(root, "data")
                if notification.data is not None:
                    try:
                        xml_data = notification.data.to_xml()
                        data_el.append(xml_data)
                    except Exception:
                        data_el.text = bytes(notification.data.to_bytes()).hex() if hasattr(notification.data, "to_bytes") else str(notification.data)

                ET.indent(root, space="  ")
                xml_str = ET.tostring(root, encoding="unicode")
                asyncio.run_coroutine_threadsafe(
                    stream.send_message(meter_pb2.PushNotification(xml=xml_str)),
                    loop,
                )
            except Exception as e:
                _logger.error(f"[StartPushSetupServer] Error building push notification XML: {e}")

        server = None
        if request.type.lower() == "tcp":
            server = TcpServer(
                host=request.host,
                port=request.port,
                configuration=MeterContext.configuration.association[MeterContext.module_name],
                handler=_notification_handler,
                security_context=MeterContext.security_context,
                transport=TCPUDPTransport(MeterContext.configuration.association[MeterContext.module_name]),
            )
        elif request.type.lower() == "udp":
            server = UdpServer(
                host=request.host,
                port=request.port,
                configuration=MeterContext.configuration.association[MeterContext.module_name],
                handler=_notification_handler,
                security_context=MeterContext.security_context,
                transport=TCPUDPTransport(MeterContext.configuration.association[MeterContext.module_name]),
            )
        await server.start()
        self._push_server = server

        try:
            while True:
                await asyncio.sleep(1)
        except (asyncio.CancelledError, Exception):
            pass
        finally:
            self._push_server = None
            if server is not None:
                await server.stop()

    @grpc_exception_handler
    async def StopPushSetupServer(self, stream):
        await stream.recv_message()
        if self._push_server is not None:
            await self._push_server.stop()
            self._push_server = None
        await stream.send_message(empty_pb2.Empty())

    @grpc_exception_handler
    async def SendTestNotification(self, stream):
        await stream.recv_message()
        await stream.send_message(empty_pb2.Empty())

    async def WatchRetryStatus(self, stream):
        await stream.recv_message()
        while True:
            try:
                retry_queue.get_nowait()
            except _queue.Empty:
                break
        while True:
            try:
                await asyncio.sleep(0.1)
                event = retry_queue.get_nowait()
                if event.get("__success__"):
                    await stream.send_message(meter_pb2.RetryStatusUpdate(attempt=0, max_attempts=0, all_failed=False, message=""))
                    continue
                if event["all_failed"]:
                    await stream.send_message(meter_pb2.RetryStatusUpdate(
                        attempt=event["attempt"],
                        max_attempts=event["max_attempts"],
                        all_failed=True,
                        message=event["message"],
                    ))

                    async def _close_session():
                        try:
                            if MeterContext.session.configuration.communication.keep_connection.enabled:
                                MeterContext.frame_executor.stop_keepalive()
                        except Exception:
                            pass
                        try:
                            await asyncio.to_thread(MeterContext.session.close)
                        except Exception:
                            pass

                    asyncio.create_task(_close_session())
                    break
                await stream.send_message(meter_pb2.RetryStatusUpdate(
                    attempt=event["attempt"],
                    max_attempts=event["max_attempts"],
                    all_failed=event["all_failed"],
                    message=event["message"],
                ))
            except _queue.Empty:
                continue
            except asyncio.CancelledError:
                break
            except Exception:
                break

