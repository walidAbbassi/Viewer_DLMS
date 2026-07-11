"""
ModemHandler - All modem operations.
COSEM Classes 27/28/29/41/42/44/45/47/48.
SRP: only modem-related COSEM object operations.
"""
import socket as _socket
from datetime import datetime as _dt

from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.data_type.array import ArrayData
from ng_sdk.frame_builder.dlms.xdlms.data_type.enum import EnumData
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8 import Integer8
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_8 import Unsigned8
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32 import Unsigned32
from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import DLMSActionRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import DLMSActionResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from grpclib import GRPCError

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from service.helpers.dlms_helpers import has_cell_info_rights, has_qos_rights
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler


class ModemHandler(BaseHandler):
    """Handles COSEM classes 27, 28, 29, 41, 42, 44, 45, 47, 48."""

    @staticmethod
    def _window_str_to_bytes(s: str) -> bytes:
        s = s.strip()
        if len(s) >= 2 and len(s) % 2 == 0 and all(c in "0123456789ABCDEFabcdef" for c in s):
            try:
                return bytes.fromhex(s)
            except ValueError:
                pass
        try:
            d = _dt.fromisoformat(s)
            out = bytearray()
            out += d.year.to_bytes(2, "big")
            out += bytes([d.month, d.day, 0xFF])
            out += bytes([d.hour, d.minute, d.second, 0x00])
            out += bytes([0x00, 0x80, 0x00, 0x00])
            return bytes(out)
        except Exception:
            pass
        return s.encode("utf-8")

    @grpc_exception_handler
    async def GetModemConfig(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj45 = next((o for o in data_model if o.get("classId") == 45), None)
        obj44 = next((o for o in data_model if o.get("classId") == 44), None)
        apn = ""
        pin_code = 0
        ppp_username = ppp_password = ""
        request_map = []
        if obj45:
            request_map.append(("apn", 2, obj45))
            request_map.append(("pin", 3, obj45))
        if obj44:
            request_map.append(("ppp", 5, obj44))
        if request_map:
            try:
                resp = await self._run(
                    MeterContext.frame_executor.execute_list,
                    [DLMSGetRequestNormal(o["classId"], o["logicalName_hex"], a) for _, a, o in request_map],
                )
                for (tag, _, _obj), result in zip(request_map, resp.result):
                    if result.data_access_result != DataAccessResult.SUCCESS or result.data is None:
                        continue
                    raw = result.data.to_python()
                    if tag == "apn":
                        apn = (raw.decode("utf-8", errors="ignore").rstrip("\x00\xff")
                               if isinstance(raw, (bytes, bytearray)) else str(raw))
                    elif tag == "pin":
                        pin_code = int(raw)
                    elif tag == "ppp":
                        if isinstance(raw, (list, tuple)) and len(raw) >= 2:
                            ppp_username = (raw[0].decode("utf-8", errors="ignore").rstrip("\x00")
                                            if isinstance(raw[0], (bytes, bytearray)) else str(raw[0]))
                            ppp_password = (raw[1].decode("utf-8", errors="ignore").rstrip("\x00")
                                            if isinstance(raw[1], (bytes, bytearray)) else str(raw[1]))
            except GRPCError:
                raise
            except Exception as e:
                print(f"[GetModemConfig] error: {e}")
        await stream.send_message(meter_pb2.ModemConfigResponse(
            apn=apn, pin_code=pin_code, ppp_username=ppp_username, ppp_password=ppp_password
        ))

    @grpc_exception_handler
    async def SetApn(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 45), None)
        if obj is None:
            raise Exception("COSEM Class 45 object not found in datamodel")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 2,
                                 OctetStringData(value=front_request.value.encode("utf-8")).to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def SetPinCode(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 45), None)
        if obj is None:
            raise Exception("COSEM Class 45 object not found in datamodel")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 3,
                                 Unsigned16(value=int(front_request.pin_code)).to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def SetPppAuth(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 44), None)
        if obj is None:
            raise Exception("COSEM Class 44 object not found in datamodel")
        payload = StructureData(value=[
            OctetStringData(value=front_request.username.encode("utf-8")),
            OctetStringData(value=front_request.password.encode("utf-8")),
        ])
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 5, payload.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetIpAddress(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj_ipv4 = next((o for o in data_model if o.get("classId") == 42), None)
        obj_ipv6 = next((o for o in data_model if o.get("classId") == 48), None)
        if obj_ipv4:
            resp = await self._run_optional(MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj_ipv4["classId"], obj_ipv4["logicalName_hex"], 3))
            if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                raw_int = int(resp.data.to_python())
                ip_str = ".".join([str((raw_int >> s) & 0xFF) for s in (24, 16, 8, 0)])
                await stream.send_message(meter_pb2.IpAddressResponse(is_ipv6=False, address=ip_str))
                return
        if obj_ipv6:
            resp = await self._run_optional(MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj_ipv6["classId"], obj_ipv6["logicalName_hex"], 4))
            if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                raw = resp.data.to_python()
                if isinstance(raw, (bytes, bytearray)):
                    hex_str = raw.hex()
                    groups = [hex_str[i:i+4] for i in range(0, 32, 4)]
                    await stream.send_message(meter_pb2.IpAddressResponse(is_ipv6=True, address=":".join(groups)))
                    return
        await stream.send_message(meter_pb2.IpAddressResponse(is_ipv6=False, address=""))

    @grpc_exception_handler
    async def SetIpAddress(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        if not front_request.is_ipv6:
            obj = next((o for o in data_model if o.get("classId") == 42), None)
            if obj is None:
                raise Exception("COSEM Class 42 object not found in datamodel")
            ip_int = int.from_bytes(_socket.inet_aton(front_request.address), "big")
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 3,
                                     Unsigned32(value=ip_int).to_bytes()))
        else:
            obj = next((o for o in data_model if o.get("classId") == 48), None)
            if obj is None:
                raise Exception("COSEM Class 48 object not found in datamodel")
            ip_bytes = _socket.inet_pton(_socket.AF_INET6, front_request.address)
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4,
                                     OctetStringData(value=ip_bytes).to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetCellularDiag(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = (next((o for o in data_model if o["name"] == "GSMDiagnostics"), None)
               or next((o for o in data_model if o["name"] == "GSMDiagnostic"), None))
        if obj is None:
            await stream.send_message(meter_pb2.CellularDiagResponse())
            return
        operator_name = ""
        status = cs_attachment = ps_status = 0
        for attr_id, target_name in [(2, "operator"), (3, "status"), (4, "cs"), (5, "ps")]:
            try:
                resp = await self._run_optional(MeterContext.frame_executor.execute,
                    DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], attr_id))
                if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                    val = resp.data.to_python()
                    if target_name == "operator":
                        operator_name = (val.decode("utf-8", errors="ignore").rstrip("\x00")
                                         if isinstance(val, (bytes, bytearray)) else str(val))
                    elif target_name == "status":
                        status = int(val)
                    elif target_name == "cs":
                        cs_attachment = int(val)
                    elif target_name == "ps":
                        ps_status = int(val)
            except GRPCError:
                raise
            except Exception as e:
                print(f"[GetCellularDiag] attr {attr_id} error: {e}")
        show_cell_info = has_cell_info_rights(obj, MeterContext.module_name or "")
        obj_gprs = next((o for o in data_model if o["name"] == "GprsModemSetup"), None)
        show_qos = has_qos_rights(obj_gprs, MeterContext.module_name or "")
        gprs_type = 0
        try:
            if MeterContext.module_name:
                gprs_type = MeterContext.configuration.association[MeterContext.module_name].communication.gprs.gprs_type
        except Exception:
            pass
        await stream.send_message(meter_pb2.CellularDiagResponse(
            operator_name=operator_name, status=status,
            cs_attachment=cs_attachment, ps_status=ps_status,
            show_cell_info=show_cell_info, show_qos=show_qos,
            is_lte_mode=(gprs_type == 0),
        ))

    @grpc_exception_handler
    async def SetCellularField(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 47), None)
        if obj is None:
            raise Exception("COSEM Class 47 object not found in datamodel")
        attr = front_request.attribute
        if attr == 2:
            payload = OctetStringData(value=front_request.string_value.encode("utf-8"))
        elif attr in (3, 4, 5):
            payload = Unsigned8(value=int(front_request.enum_value))
        else:
            raise Exception(f"Unsupported attribute {attr} for SetCellularField")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], attr, payload.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetCellInfo(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = (next((o for o in data_model if o["name"] == "GSMDiagnostics"), None)
               or next((o for o in data_model if o["name"] == "GSMDiagnostic"), None))
        if obj is None:
            await stream.send_message(meter_pb2.CellInfoResponse(entries=[], is_lte=False))
            return
        attr_def = next((a for a in obj.get("dlmsAttribute", []) if str(a.get("id")) == "6"), None)
        field_names = ([f.get("name", f"field_{i}") for i, f in
                        enumerate(attr_def.get("dlmsType", {}).get("fields", []))]
                       if attr_def else [])
        entries = []
        try:
            resp = await self._run_optional(MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 6))
            if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                raw = resp.data.to_python()
                items = raw if isinstance(raw, (list, tuple)) else [raw]
                for i, val in enumerate(items):
                    name = field_names[i] if i < len(field_names) else f"field_{i}"
                    display = val.hex().upper() if isinstance(val, (bytes, bytearray)) else str(val)
                    entries.append(meter_pb2.CellInfoEntry(name=name, value=display))
        except GRPCError:
            raise
        except Exception as e:
            print(f"[GetCellInfo] error: {e}")
        await stream.send_message(meter_pb2.CellInfoResponse(entries=entries, is_lte=False))

    @grpc_exception_handler
    async def SetCellInfoEntry(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = (next((o for o in data_model if o["name"] == "GSMDiagnostics"), None)
               or next((o for o in data_model if o["name"] == "GSMDiagnostic"), None))
        if obj is None:
            raise Exception("GSMDiagnostics object not found in datamodel")
        read_resp = await self._run(MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 6))
        if not isinstance(read_resp, DLMSGetResponseNormal) or read_resp.data is None:
            raise Exception("Could not read current Cell Info structure")
        raw_list = list(read_resp.data.to_python())
        idx = front_request.entry_index
        if idx < 0 or idx >= len(raw_list):
            raise Exception(f"Entry index {idx} out of range")
        try:
            raw_list[idx] = int(front_request.value)
        except ValueError:
            raw_list[idx] = front_request.value
        structure = StructureData(value=[
            OctetStringData(value=v.encode("utf-8")) if isinstance(v, str) else Unsigned8(value=int(v))
            for v in raw_list
        ])
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 6, structure.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetQos(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o["name"] == "GprsModemSetup"), None)
        if obj is None:
            await stream.send_message(meter_pb2.GetQosResponse(profiles=[]))
            return
        profiles = []
        try:
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 4))
            if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                raw = resp.data.to_python()
                entries = (raw if (isinstance(raw, (list, tuple)) and raw
                                   and isinstance(raw[0], (list, tuple))) else [raw])
                for entry in entries:
                    if isinstance(entry, (list, tuple)) and len(entry) >= 5:
                        profiles.append(meter_pb2.QosEntry(
                            precedence=int(entry[0]), delay=int(entry[1]),
                            reliability=int(entry[2]), peak_throughput=int(entry[3]),
                            mean_throughput=int(entry[4]),
                        ))
        except Exception as e:
            print(f"[GetQos] error: {e}")
        await stream.send_message(meter_pb2.GetQosResponse(profiles=profiles))

    @grpc_exception_handler
    async def SetQos(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o["name"] == "GprsModemSetup"), None)
        if obj is None:
            raise Exception("GprsModemSetup object not found in datamodel")
        p = front_request.profile
        structure = StructureData(value=[
            Unsigned8(value=int(p.precedence)), Unsigned8(value=int(p.delay)),
            Unsigned8(value=int(p.reliability)), Unsigned8(value=int(p.peak_throughput)),
            Unsigned8(value=int(p.mean_throughput)),
        ])
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4, structure.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetModemStatus(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 45), None)
        if obj is None:
            await stream.send_message(meter_pb2.ModemStatusResponse(is_active=False))
            return
        try:
            obj_gsm = next((o for o in data_model if o.get("classId") == 47), None)
            if obj_gsm:
                resp = await self._run_optional(MeterContext.frame_executor.execute,
                    DLMSGetRequestNormal(obj_gsm["classId"], obj_gsm["logicalName_hex"], 3))
                if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
                    is_active = int(resp.data.to_python()) in (1, 5)
                    await stream.send_message(meter_pb2.ModemStatusResponse(is_active=is_active))
                    return
        except Exception as e:
            print(f"[GetModemStatus] error: {e}")
        await stream.send_message(meter_pb2.ModemStatusResponse(is_active=False))

    @grpc_exception_handler
    async def SetModemStatus(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        req = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 45), None)
        if obj is None:
            raise Exception("GprsModemSetup (Class 45) not found in datamodel")
        payload = OctetStringData(value=b"\x01" if req.value else b"\x00")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 6, payload.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def RestartModem(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to execute ACTION operations")
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 45), None)
        if obj is None:
            raise Exception("GprsModemSetup (Class 45) not found in datamodel")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 1, None))
        success = isinstance(resp, DLMSActionResponseNormal) and resp.is_success()
        await stream.send_message(meter_pb2.BoolValue(value=success))

    @grpc_exception_handler
    async def GetModemConfigSettings(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 27), None)
        comm_speed = 5
        modem_profile = ""
        init_strings = []
        show_init_string = True
        if obj is None:
            await stream.send_message(meter_pb2.ModemConfigSettingsResponse(
                comm_speed=comm_speed, modem_profile=modem_profile,
                init_strings=[], show_init_string=show_init_string))
            return
        r2 = r3 = r4 = None
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], a) for a in (2, 3, 4)],
            )
            r2, r3, r4 = resp.result
        except Exception as e:
            print(f"[GetModemConfigSettings] execute_list error: {e}")
        if r2 is not None and r2.data_access_result == DataAccessResult.SUCCESS and r2.data is not None:
            try:
                comm_speed = int(r2.data.to_python())
            except Exception:
                pass
        if r3 is not None and r3.data_access_result == DataAccessResult.SUCCESS and r3.data is not None:
            try:
                raw = r3.data.to_python()
                for item in (raw if isinstance(raw, (list, tuple)) else []):
                    parts = item if isinstance(item, (list, tuple)) else [item]
                    req_str = (parts[0].decode("utf-8", errors="ignore").rstrip("\x00")
                               if len(parts) > 0 and isinstance(parts[0], (bytes, bytearray))
                               else str(parts[0]) if parts else "")
                    exp_str = (parts[1].decode("utf-8", errors="ignore").rstrip("\x00")
                               if len(parts) > 1 and isinstance(parts[1], (bytes, bytearray))
                               else str(parts[1]) if len(parts) > 1 else "")
                    delay = int(parts[2]) if len(parts) > 2 else 0
                    init_strings.append(meter_pb2.ModemInitStringEntry(
                        request=req_str, expected=exp_str, delay_ms=delay))
            except Exception:
                pass
        if r4 is not None and r4.data_access_result == DataAccessResult.SUCCESS and r4.data is not None:
            try:
                raw = r4.data.to_python()

                def _decode_item(x):
                    try:
                        return bytes(x).decode("utf-8", errors="ignore").rstrip("\x00")
                    except Exception:
                        return str(x)

                if isinstance(raw, (list, tuple)):
                    parts = []
                    for item in raw:
                        if isinstance(item, (list, tuple)):
                            for sub in item:
                                parts.append(_decode_item(sub))
                        else:
                            parts.append(_decode_item(item))
                    modem_profile = "\n".join(p for p in parts if p)
                else:
                    modem_profile = _decode_item(raw)
            except Exception:
                pass
        try:
            if MeterContext.module_name:
                cfg = MeterContext.configuration.association[MeterContext.module_name]
                init_flag = getattr(getattr(cfg.communication, "gprs", None), "init_string", 1)
                show_init_string = bool(init_flag)
        except Exception:
            pass
        await stream.send_message(meter_pb2.ModemConfigSettingsResponse(
            comm_speed=comm_speed, modem_profile=modem_profile,
            init_strings=init_strings, show_init_string=show_init_string,
        ))

    @grpc_exception_handler
    async def SetCommSpeed(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 27), None)
        if obj is None:
            raise Exception("COSEM Class 27 object not found in datamodel")
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 2,
                                 Unsigned8(value=int(front_request.speed_index)).to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def SetModemProfile(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 27), None)
        if obj is None:
            raise Exception("COSEM Class 27 object not found in datamodel")
        payload = ArrayData(value=[
            OctetStringData(value=line.encode("utf-8"))
            for line in front_request.profile.splitlines() if line
        ])
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 4, payload.to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def SetInitStrings(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 27), None)
        if obj is None:
            raise Exception("COSEM Class 27 object not found in datamodel")
        entries = [StructureData(value=[
            OctetStringData(value=e.request.encode("utf-8")),
            OctetStringData(value=e.expected.encode("utf-8")),
            Unsigned16(value=int(e.delay_ms)),
        ]) for e in front_request.entries]
        resp = await self._run(MeterContext.frame_executor.execute,
            DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 3,
                                 ArrayData(value=entries).to_bytes()))
        await stream.send_message(meter_pb2.BoolValue(value=resp.is_success()))

    @grpc_exception_handler
    async def GetAutoConnect(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 29), None)
        if obj is None:
            await stream.send_message(meter_pb2.AutoConnectResponse())
            return
        mode = 101
        repetitions = repetition_delay = 0
        calling_window = []
        destination_list = []
        attr_defs = [(2, "mode"), (3, "rep"), (4, "delay"), (5, "cw"), (6, "dst")]
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], a) for a, _ in attr_defs],
            )
            for (attr_id, target), result in zip(attr_defs, resp.result):
                if result.data_access_result != DataAccessResult.SUCCESS or result.data is None:
                    continue
                raw = result.data.to_python()
                try:
                    if target == "mode":
                        mode = int(raw)
                    elif target == "rep":
                        repetitions = int(raw)
                    elif target == "delay":
                        repetition_delay = int(raw)
                    elif target == "cw":
                        for item in (raw if isinstance(raw, (list, tuple)) else []):
                            parts = item if isinstance(item, (list, tuple)) else [item]
                            start = (parts[0].hex().upper()
                                     if isinstance(parts[0], (bytes, bytearray)) else str(parts[0]))
                            end = (parts[1].hex().upper()
                                   if len(parts) > 1 and isinstance(parts[1], (bytes, bytearray))
                                   else str(parts[1]) if len(parts) > 1 else "")
                            calling_window.append(
                                meter_pb2.CallingWindowEntry(start_time=start, end_time=end))
                    elif target == "dst":
                        for item in (raw if isinstance(raw, (list, tuple)) else []):
                            parts = item if isinstance(item, (list, tuple)) else [item]
                            raw_ip = parts[0] if parts else b""
                            if isinstance(raw_ip, (bytes, bytearray)) and len(raw_ip) == 4:
                                ip = ".".join(str(b) for b in raw_ip)
                            elif isinstance(raw_ip, (bytes, bytearray)) and len(raw_ip) == 16:
                                ip = _socket.inet_ntop(_socket.AF_INET6, bytes(raw_ip))
                            elif isinstance(raw_ip, (bytes, bytearray)):
                                ip = raw_ip.decode("utf-8", errors="ignore").rstrip("\x00")
                            else:
                                ip = str(raw_ip)
                            port = int(parts[1]) if len(parts) > 1 else 0
                            destination_list.append(
                                meter_pb2.DestinationEntry(ip_address=ip, port=port))
                except Exception as e:
                    print(f"[GetAutoConnect] attr {attr_id} error: {e}")
        except Exception as e:
            print(f"[GetAutoConnect] error: {e}")
        await stream.send_message(meter_pb2.AutoConnectResponse(
            mode=mode, repetitions=repetitions, repetition_delay=repetition_delay,
            calling_window=calling_window, destination_list=destination_list,
        ))

    @grpc_exception_handler
    async def SetAutoConnect(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 29), None)
        if obj is None:
            raise Exception("COSEM Class 29 object not found in datamodel")
        mode_payload = EnumData(value=int(front_request.mode))
        rep_payload = Unsigned8(value=int(front_request.repetitions))
        delay_payload = Unsigned16(value=int(front_request.repetition_delay))
        cw_entries = [StructureData(value=[
            OctetStringData(value=self._window_str_to_bytes(cw.start_time)),
            OctetStringData(value=self._window_str_to_bytes(cw.end_time)),
        ]) for cw in front_request.calling_window]
        cw_payload = ArrayData(value=cw_entries)
        attrs_to_write = [(2, mode_payload), (3, rep_payload), (4, delay_payload)]
        if front_request.calling_window:
            attrs_to_write.append((5, cw_payload))
        success = True
        for attr_id, payload in attrs_to_write:
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], attr_id, payload.to_bytes()))
            if not resp.is_success():
                success = False
        await stream.send_message(meter_pb2.BoolValue(value=success))

    @grpc_exception_handler
    async def ModemConnect(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((o for o in data_model if o.get("classId") == 29), None)
        if obj is None:
            await stream.send_message(meter_pb2.BoolValue(value=False))
            return
        try:
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 1,
                                        Integer8(value=0).to_bytes()))
            success = isinstance(resp, DLMSActionResponseNormal) and resp.is_success()
        except Exception as e:
            print(f"[ModemConnect] error: {e}")
            success = False
        await stream.send_message(meter_pb2.BoolValue(value=success))

    @grpc_exception_handler
    async def GetAutoAnswer(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj28 = next((o for o in data_model if o.get("classId") == 28), None)
        if obj28 is None:
            await stream.send_message(meter_pb2.AutoAnswerResponse())
            return
        mode = number_of_calls = rings_in_window = rings_out_window = status = 0
        allowed_callers = []
        listening_window = []
        attr_defs = [(2, "mode"), (3, "lw"), (4, "status"), (5, "ncalls"), (6, "rings"), (7, "callers")]
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(28, obj28["logicalName_hex"], a) for a, _ in attr_defs],
            )
            for (attr_id, target), result in zip(attr_defs, resp.result):
                if result.data_access_result != DataAccessResult.SUCCESS or result.data is None:
                    continue
                raw = result.data.to_python()
                try:
                    if target == "mode":
                        mode = int(raw)
                    elif target == "status":
                        status = int(raw)
                    elif target == "ncalls":
                        number_of_calls = int(raw)
                    elif target == "rings":
                        parts = raw if isinstance(raw, (list, tuple)) else [raw]
                        rings_in_window = int(parts[0]) if parts else 0
                        rings_out_window = int(parts[1]) if len(parts) > 1 else 0
                    elif target == "callers":
                        for item in (raw if isinstance(raw, (list, tuple)) else []):
                            p = item if isinstance(item, (list, tuple)) else [item]
                            caller_id = (p[0].decode("utf-8", errors="ignore").rstrip("\x00")
                                         if isinstance(p[0], (bytes, bytearray)) else str(p[0]))
                            call_type = int(p[1]) if len(p) > 1 else 0
                            allowed_callers.append(
                                meter_pb2.AllowedCallerEntry(caller_id=caller_id, call_type=call_type))
                    elif target == "lw":
                        for item in (raw if isinstance(raw, (list, tuple)) else []):
                            p = item if isinstance(item, (list, tuple)) else [item]
                            start = (p[0].hex().upper()
                                     if isinstance(p[0], (bytes, bytearray)) else str(p[0]))
                            end = (p[1].hex().upper()
                                   if len(p) > 1 and isinstance(p[1], (bytes, bytearray))
                                   else str(p[1]) if len(p) > 1 else "")
                            listening_window.append(
                                meter_pb2.CallingWindowEntry(start_time=start, end_time=end))
                except Exception as e:
                    print(f"[GetAutoAnswer] attr {attr_id} error: {e}")
        except Exception as e:
            print(f"[GetAutoAnswer] error: {e}")
        await stream.send_message(meter_pb2.AutoAnswerResponse(
            mode=mode, number_of_calls=number_of_calls,
            rings_in_window=rings_in_window, rings_out_window=rings_out_window,
            status=status, allowed_callers=allowed_callers, listening_window=listening_window,
        ))

    @grpc_exception_handler
    async def SetAutoAnswer(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj28 = next((o for o in data_model if o.get("classId") == 28), None)
        if obj28 is None:
            raise Exception("COSEM Class 28 (Auto Answer) object not found in datamodel")
        mode_payload = EnumData(value=int(front_request.mode))
        ncalls_payload = Unsigned8(value=int(front_request.number_of_calls))
        rings_payload = StructureData(value=[
            Unsigned8(value=int(front_request.rings_in_window)),
            Unsigned8(value=int(front_request.rings_out_window)),
        ])
        callers_payload = ArrayData(value=[StructureData(value=[
            OctetStringData(value=c.caller_id.encode("utf-8")),
            EnumData(value=int(c.call_type)),
        ]) for c in front_request.allowed_callers])
        lw_payload = ArrayData(value=[StructureData(value=[
            OctetStringData(value=self._window_str_to_bytes(w.start_time)),
            OctetStringData(value=self._window_str_to_bytes(w.end_time)),
        ]) for w in front_request.listening_window])
        attrs_to_write = [(2, mode_payload), (5, ncalls_payload), (6, rings_payload)]
        if front_request.allowed_callers:
            attrs_to_write.append((7, callers_payload))
        if front_request.listening_window:
            attrs_to_write.append((3, lw_payload))
        success = True
        for attr_id, payload in attrs_to_write:
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(28, obj28["logicalName_hex"], attr_id, payload.to_bytes()))
            if not resp.is_success():
                success = False
        await stream.send_message(meter_pb2.BoolValue(value=success))

    @grpc_exception_handler
    async def GetTcpUdpSetup(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj41 = next((o for o in data_model if o.get("classId") == 41), None)
        if obj41 is None:
            await stream.send_message(meter_pb2.TcpUdpSetupResponse())
            return
        port = 4059
        ip_reference = ""
        mss = 0
        nb_connections = 1
        inactivity_timeout = 0
        attr_defs = [(2, "port"), (3, "ip_ref"), (4, "mss"), (5, "nb"), (6, "timeout")]
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(41, obj41["logicalName_hex"], a) for a, _ in attr_defs],
            )
            for (attr_id, target), result in zip(attr_defs, resp.result):
                if result.data_access_result != DataAccessResult.SUCCESS or result.data is None:
                    continue
                val = result.data.to_python()
                try:
                    if target == "port":
                        port = int(val)
                    elif target == "ip_ref":
                        try:
                            ip_reference = ".".join(str(b) for b in bytes(val))
                        except Exception:
                            ip_reference = str(val)
                    elif target == "mss":
                        mss = int(val)
                    elif target == "nb":
                        nb_connections = int(val)
                    elif target == "timeout":
                        inactivity_timeout = int(val)
                except Exception as e:
                    print(f"[GetTcpUdpSetup] attr {attr_id} error: {e}")
        except Exception as e:
            print(f"[GetTcpUdpSetup] error: {e}")
        await stream.send_message(meter_pb2.TcpUdpSetupResponse(
            port=port, ip_reference=ip_reference, mss=mss,
            nb_connections=nb_connections, inactivity_timeout=inactivity_timeout,
        ))

    @grpc_exception_handler
    async def SetTcpUdpSetup(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to execute SET operations")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj41 = next((o for o in data_model if o.get("classId") == 41), None)
        if obj41 is None:
            raise Exception("COSEM Class 41 object not found in datamodel")
        success = True
        for attr_id, payload in [
            (2, Unsigned16(value=int(front_request.port))),
            (4, Unsigned16(value=int(front_request.mss))),
            (5, Unsigned8(value=int(front_request.nb_connections))),
            (6, Unsigned16(value=int(front_request.inactivity_timeout))),
        ]:
            resp = await self._run(MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(41, obj41["logicalName_hex"], attr_id, payload.to_bytes()))
            if not resp.is_success():
                success = False
        await stream.send_message(meter_pb2.BoolValue(value=success))
