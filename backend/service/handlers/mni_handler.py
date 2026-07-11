"""
MniHandler — GetMobileNetworkIdentifiers, SetImsi/Msisdn/Imei/Iccid, GetMniRights.
SRP : identifiants réseau mobile (DEER meter).
"""
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler


class MniHandler(BaseHandler):
    _MNI_OBIS = {"imsi": "0000600C06FF", "msisdn": "0001600C06FF", "imei": "0002600C06FF", "iccid": "0003600C06FF"}
    _MNI_CLASS_ID = 1
    _MNI_ATTR = 2

    async def _read_mni_field(self, obis_hex: str) -> str:
        resp = await self._run_optional(MeterContext.frame_executor.execute,
                                        DLMSGetRequestNormal(self._MNI_CLASS_ID, obis_hex, self._MNI_ATTR))
        if isinstance(resp, DLMSGetResponseNormal) and resp.data is not None:
            raw = resp.data.to_python()
            if isinstance(raw, (bytes, bytearray)):
                return raw.decode("ascii", errors="ignore").rstrip("\x00\xff")
            return str(raw)
        return ""

    async def _write_mni_field(self, obis_hex: str, value: str, max_len: int) -> bool:
        if not value.isdigit():
            raise Exception("Invalid value: only numeric characters (0-9) are accepted.")
        if len(value) > max_len:
            raise Exception(f"Value exceeds maximum length of {max_len} characters.")
        payload = OctetStringData(value=value.encode("ascii"))
        resp = await self._run(MeterContext.frame_executor.execute,
                               DLMSSetRequestNormal(self._MNI_CLASS_ID, obis_hex, self._MNI_ATTR, payload.to_bytes()))
        return resp.is_success()

    @grpc_exception_handler
    async def GetMobileNetworkIdentifiers(self, stream):
        await stream.recv_message()
        imsi = await self._read_mni_field(self._MNI_OBIS["imsi"])
        msisdn = await self._read_mni_field(self._MNI_OBIS["msisdn"])
        imei = await self._read_mni_field(self._MNI_OBIS["imei"])
        iccid = await self._read_mni_field(self._MNI_OBIS["iccid"])
        await stream.send_message(meter_pb2.MobileNetworkIdentifiersResponse(imsi=imsi, msisdn=msisdn, imei=imei, iccid=iccid))

    @grpc_exception_handler
    async def SetImsi(self, stream):
        if SESSION.get_effective_right("SET") == "NO": raise Exception("User not allowed to execute SET operations")
        req = await stream.recv_message()
        await stream.send_message(meter_pb2.BoolValue(value=await self._write_mni_field(self._MNI_OBIS["imsi"], req.value, 15)))

    @grpc_exception_handler
    async def SetMsisdn(self, stream):
        if SESSION.get_effective_right("SET") == "NO": raise Exception("User not allowed to execute SET operations")
        req = await stream.recv_message()
        await stream.send_message(meter_pb2.BoolValue(value=await self._write_mni_field(self._MNI_OBIS["msisdn"], req.value, 20)))

    @grpc_exception_handler
    async def SetImei(self, stream):
        if SESSION.get_effective_right("SET") == "NO": raise Exception("User not allowed to execute SET operations")
        req = await stream.recv_message()
        await stream.send_message(meter_pb2.BoolValue(value=await self._write_mni_field(self._MNI_OBIS["imei"], req.value, 15)))

    @grpc_exception_handler
    async def SetIccid(self, stream):
        if SESSION.get_effective_right("SET") == "NO": raise Exception("User not allowed to execute SET operations")
        req = await stream.recv_message()
        await stream.send_message(meter_pb2.BoolValue(value=await self._write_mni_field(self._MNI_OBIS["iccid"], req.value, 22)))

    @grpc_exception_handler
    async def GetMniRights(self, stream):
        await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        module = (MeterContext.module_name or "").lower()

        def _rights(obis_hex):
            obj = next((o for o in data_model if o.get("logicalName_hex") == obis_hex), None)
            if obj is None: return False, False
            attr2 = next((a for a in obj.get("dlmsAttribute", []) if str(a.get("id")) == "2"), None)
            if attr2 is None or not module: return False, False
            for entry in attr2.get("accessRights", {}).values():
                if entry.get("name", "").lower() == module:
                    ar = entry.get("accessRights", "").lower()
                    return ("get" in ar), ("set" in ar)
            return False, False

        def _modem_rights(class_id):
            obj = next((o for o in data_model if o.get("classId") == class_id), None)
            if obj is None or not module: return False, False
            can_get = can_set = False
            for attr in obj.get("dlmsAttribute", []):
                for entry in attr.get("accessRights", {}).values():
                    if entry.get("name", "").lower() == module:
                        ar = entry.get("accessRights", "").lower()
                        if "get" in ar: can_get = True
                        if "set" in ar: can_set = True
            return can_get, can_set

        ig, is_ = _rights(self._MNI_OBIS["imsi"])
        mg, ms_ = _rights(self._MNI_OBIS["msisdn"])
        eig, eis = _rights(self._MNI_OBIS["imei"])
        cg, cs = _rights(self._MNI_OBIS["iccid"])
        dmg, dms = _modem_rights(45)
        await stream.send_message(meter_pb2.MniRightsResponse(
            imsi_get=ig, imsi_set=is_, msisdn_get=mg, msisdn_set=ms_,
            imei_get=eig, imei_set=eis, iccid_get=cg, iccid_set=cs,
            modem_get=dmg, modem_set=dms,
        ))
