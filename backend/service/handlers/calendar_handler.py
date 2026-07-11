"""
CalendarHandler — GetActiveCalendar, GetPassiveCalendar, SetPassiveCalendar,
                  GetSpecialDays, GetPassiveSpecialDays, SetPassiveSpecialDays,
                  ActivatePassiveCalendar.
SRP : uniquement l'objet COSEM Activity Calendar (Class 20) et Special Days (Class 11).
"""
from ng_sdk.frame_builder.dlms.xdlms.action.request.dlms_action_request_normal import DLMSActionRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.action.response.dlms_action_response_normal import DLMSActionResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.data_type.array import ArrayData
from ng_sdk.frame_builder.dlms.xdlms.data_type.integer_8 import Integer8
from ng_sdk.frame_builder.dlms.xdlms.data_type.octet_string import OctetStringData
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_8 import Unsigned8
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response import DLMSExceptionResponse
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler
import traceback as _tb


class CalendarHandler(BaseHandler):
    """Gère l'Activity Calendar et les Special Days (classes COSEM 20 & 11)."""

    # ── Proto helpers ────────────────────────────────────────────────────────

    @staticmethod
    def _parse_calendar_time(raw) -> "meter_pb2.CalendarTimeValue":
        if not raw or len(raw) < 4:
            return meter_pb2.CalendarTimeValue()
        return meter_pb2.CalendarTimeValue(
            hour=raw[0], minute=raw[1], second=raw[2], hundredths=raw[3]
        )

    @staticmethod
    def _parse_calendar_date(raw) -> "meter_pb2.CalendarDateValue":
        if not raw or len(raw) < 5:
            return meter_pb2.CalendarDateValue()
        year = int.from_bytes(raw[0:2], "big")
        return meter_pb2.CalendarDateValue(year=year, month=raw[2], day_of_month=raw[3], day_of_week=raw[4])

    @staticmethod
    def _parse_calendar_datetime_to_date(raw) -> "meter_pb2.CalendarDateValue":
        if not raw or len(raw) < 5:
            return meter_pb2.CalendarDateValue()
        year = int.from_bytes(raw[0:2], "big")
        return meter_pb2.CalendarDateValue(year=year, month=raw[2], day_of_month=raw[3], day_of_week=raw[4])

    @staticmethod
    def _encode_calendar_time(tv: "meter_pb2.CalendarTimeValue") -> bytes:
        return bytes([tv.hour & 0xFF, tv.minute & 0xFF, tv.second & 0xFF, tv.hundredths & 0xFF])

    @staticmethod
    def _encode_calendar_date(dv: "meter_pb2.CalendarDateValue") -> bytes:
        data = bytearray(5)
        data[0:2] = dv.year.to_bytes(2, "big")
        data[2] = dv.month & 0xFF
        data[3] = dv.day_of_month & 0xFF
        dow = dv.day_of_week & 0xFF
        data[4] = dow if dow != 0 else 0xFF
        return bytes(data)

    @staticmethod
    def _encode_season_start_datetime(dv: "meter_pb2.CalendarDateValue") -> bytes:
        """
        Encode a CalendarDateValue as a DLMS date_time octet-string (12 bytes)
     
        season_start carries date-only information; all time fields are encoded
        as wildcards (0xFF) because no specific time-of-day is implied by the
        DLMS Activity Calendar semantics.

        When ALL date fields also carry their wildcard values
        (year=0xFFFF, month=0xFF, day_of_month=0xFF, day_of_week=0xFF) the
        resulting 12-byte string is a valid DLMS date_time that means
        "the season will never start" per the Blue Book.
        """
        data = bytearray(12)
        # Date fields — wildcard values are passed through unchanged:
        #   proto encodes year=65535 → 0xFFFF, month/day=255 → 0xFF
        data[0:2] = dv.year.to_bytes(2, "big")
        data[2] = dv.month & 0xFF
        data[3] = dv.day_of_month & 0xFF
        dow = dv.day_of_week & 0xFF
        data[4] = dow if dow != 0 else 0xFF  # proto 0 is mapped to wildcard 0xFF
        # Time fields — always wildcarded for season_start (date resolution only)
        data[5] = 0xFF   # hour:        not specified
        data[6] = 0xFF   # minute:      not specified
        data[7] = 0xFF   # second:      not specified
        data[8] = 0xFF   # hundredths:  not specified
        # Deviation 0x8000 = not specified (no UTC offset assumed)
        data[9]  = 0x80
        data[10] = 0x00
        data[11] = 0xFF  # clock_status: not specified
        return bytes(data)

    @staticmethod
    def _season_start_sort_key(dv: "meter_pb2.CalendarDateValue") -> tuple:
        """
        Return a (year, month, day_of_month) tuple for ascending sort of season
        profiles per the Blue Book requirement.

        Wildcard values sort last (treated as the maximum in their domain) so
        that an all-wildcard "never-start" season is always placed at the end
        of the table:
            year 65535 (0xFFFF) > any real year
            month 255  (0xFF)   > 12
            day   255  (0xFF)   > 31
        """
        y = dv.year & 0xFFFF         # preserves 0xFFFF
        m = dv.month & 0xFF          # 0xFF → sorts last
        d = dv.day_of_month & 0xFF   # 0xFF → sorts last
        return (y, m, d)

    @staticmethod
    def _profile_name_to_octet(name: str) -> bytes:
        if not name.isdigit():
            raise Exception(f"Profile name must be numeric: {name}")
        return bytes([int(name)])

    @staticmethod
    def _decode_profile_name(raw) -> str:
        if isinstance(raw, str):
            return raw

        if isinstance(raw, (bytes, bytearray)):
            if len(raw) == 1:
                return str(raw[0])

            try:
                return raw.decode("ascii").strip("\x00")
            except Exception:
                return raw.hex()

        return str(raw)

    @staticmethod
    def _visible_string(s: str) -> bytes:
        b = s.encode("ascii", errors="replace") if s else b""
        if len(b) < 128:
            return bytes([0x0A, len(b)]) + b
        return bytes([0x0A, 0x81, len(b)]) + b

    # ── Internal helpers ─────────────────────────────────────────────────────

    def _get_cal_object(self, name: str):
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == name), None)
        if obj is None:
            raise Exception(f"{name}: object not found in datamodel")
        return obj

    async def _get_cal_attr(self, obj, attr: int):
        resp = await self._run(
            MeterContext.frame_executor.execute,
            DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], attr),
        )
        self._verify_get_response(resp)
        return resp.data

    async def _parse_activity_calendar(self, obj, name_attr, season_attr, week_attr, day_attr):
        name_data = await self._get_cal_attr(obj, name_attr)
        cal_name = ""
        if name_data is not None:
            raw = name_data.to_python()
            cal_name = bytes(raw).decode("ascii", errors="replace").strip("\x00") if isinstance(raw, (bytes, bytearray)) else str(raw).strip("\x00")

        season_data = await self._get_cal_attr(obj, season_attr)
        seasons = []
        if season_data is not None:
            for entry in season_data.to_python():
                def _to_bytes(v):
                    if isinstance(v, (bytes, bytearray)): return bytes(v)
                    if isinstance(v, str): return v.encode("ascii", errors="replace")
                    return bytes([v])
                name_bytes = _to_bytes(entry[0])
                start_bytes = entry[1] if isinstance(entry[1], (bytes, bytearray)) else bytes(entry[1])
                week_bytes = _to_bytes(entry[2])
                seasons.append(meter_pb2.CalendarSeasonProfile(
                    season_profile_name=self._decode_profile_name(entry[0]),
                    season_start=self._parse_calendar_datetime_to_date(start_bytes),
                    week_profile_name=self._decode_profile_name(entry[2]),
                ))

        week_data = await self._get_cal_attr(obj, week_attr)
        weeks = []
        if week_data is not None:
            for entry in week_data.to_python():
                raw_wn = entry[0]
                name_bytes = bytes(raw_wn) if isinstance(raw_wn, (bytes, bytearray)) else raw_wn.encode("ascii", errors="replace") if isinstance(raw_wn, str) else bytes([raw_wn])
                weeks.append(meter_pb2.CalendarWeekProfile(
                    week_profile_name=self._decode_profile_name(entry[0]),
                    monday=entry[1], tuesday=entry[2], wednesday=entry[3],
                    thursday=entry[4], friday=entry[5], saturday=entry[6], sunday=entry[7],
                ))

        day_data = await self._get_cal_attr(obj, day_attr)
        days = []
        if day_data is not None:
            for entry in day_data.to_python():
                day_id = entry[0]
                actions = []
                for sub in (entry[1] if len(entry) > 1 else []):
                    time_bytes = sub[0] if isinstance(sub[0], (bytes, bytearray)) else bytes(sub[0])
                    script_bytes = sub[1] if isinstance(sub[1], (bytes, bytearray)) else bytes(sub[1])
                    selector = sub[2] if len(sub) > 2 else 0
                    actions.append(meter_pb2.DayProfileAction(
                        start_time=self._parse_calendar_time(time_bytes),
                        script_logical_name=script_bytes.hex().upper(),
                        script_selector=int(selector),
                    ))
                days.append(meter_pb2.CalendarDayProfile(day_id=day_id, day_schedule=actions))

        return meter_pb2.ActivityCalendarData(
            calendar_name=cal_name,
            season_profiles=seasons,
            week_profiles=weeks,
            day_profiles=days,
        )

    # ── gRPC methods ─────────────────────────────────────────────────────────

    @grpc_exception_handler
    async def GetActiveCalendar(self, stream):
        obj = self._get_cal_object("ActivityCalendar")
        result = await self._parse_activity_calendar(obj, 2, 3, 4, 5)
        await stream.send_message(result)

    @grpc_exception_handler
    async def GetPassiveCalendar(self, stream):
        obj = self._get_cal_object("ActivityCalendar")
        result = await self._parse_activity_calendar(obj, 6, 7, 8, 9)
        await stream.send_message(result)

    @grpc_exception_handler
    async def GetPassiveDayProfiles(self, stream):
        """Read only Attr 9 (passive day profile table) from the meter."""
        obj = self._get_cal_object("ActivityCalendar")
        day_data = await self._get_cal_attr(obj, 9)
        days = []
        if day_data is not None:
            for entry in day_data.to_python():
                day_id = entry[0]
                actions = []
                for sub in (entry[1] if len(entry) > 1 else []):
                    time_bytes = sub[0] if isinstance(sub[0], (bytes, bytearray)) else bytes(sub[0])
                    script_bytes = sub[1] if isinstance(sub[1], (bytes, bytearray)) else bytes(sub[1])
                    selector = sub[2] if len(sub) > 2 else 0
                    actions.append(meter_pb2.DayProfileAction(
                        start_time=self._parse_calendar_time(time_bytes),
                        script_logical_name=script_bytes.hex().upper(),
                        script_selector=int(selector),
                    ))
                days.append(meter_pb2.CalendarDayProfile(day_id=day_id, day_schedule=actions))
        await stream.send_message(meter_pb2.ActivityCalendarData(day_profiles=days))

    @grpc_exception_handler
    async def GetPassiveWeekProfiles(self, stream):
        """Read only Attr 8 (passive week profile table) from the meter."""
        obj = self._get_cal_object("ActivityCalendar")
        week_data = await self._get_cal_attr(obj, 8)
        weeks = []
        if week_data is not None:
            for entry in week_data.to_python():
                weeks.append(meter_pb2.CalendarWeekProfile(
                    week_profile_name=self._decode_profile_name(entry[0]),
                    monday=entry[1], tuesday=entry[2], wednesday=entry[3],
                    thursday=entry[4], friday=entry[5], saturday=entry[6], sunday=entry[7],
                ))
        await stream.send_message(meter_pb2.ActivityCalendarData(week_profiles=weeks))

    @grpc_exception_handler
    async def GetPassiveSeasonProfiles(self, stream):
        """Read only Attr 7 (passive season profile table) from the meter."""
        obj = self._get_cal_object("ActivityCalendar")
        season_data = await self._get_cal_attr(obj, 7)
        seasons = []
        if season_data is not None:
            for entry in season_data.to_python():
                start_bytes = entry[1] if isinstance(entry[1], (bytes, bytearray)) else bytes(entry[1])
                seasons.append(meter_pb2.CalendarSeasonProfile(
                    season_profile_name=self._decode_profile_name(entry[0]),
                    season_start=self._parse_calendar_datetime_to_date(start_bytes),
                    week_profile_name=self._decode_profile_name(entry[2]),
                ))
        await stream.send_message(meter_pb2.ActivityCalendarData(season_profiles=seasons))

    @grpc_exception_handler
    async def SetPassiveCalendar(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to set passive calendar")
        request: meter_pb2.ActivityCalendarData = await stream.recv_message()
        obj = self._get_cal_object("ActivityCalendar")
        cid = obj["classId"]
        ln = obj["logicalName_hex"]

        actual_name = request.calendar_name
        if actual_name.startswith("#day#"):
            write_name, write_seasons, write_weeks, write_days = False, False, False, True
            actual_name = actual_name[len("#day#"):]
        elif actual_name.startswith("#week#"):
            write_name, write_seasons, write_weeks, write_days = False, False, True, False
            actual_name = actual_name[len("#week#"):]
        elif actual_name.startswith("#season#"):
            write_name, write_seasons, write_weeks, write_days = True, True, False, False
            actual_name = actual_name[len("#season#"):]
        else:
            write_name, write_seasons, write_weeks, write_days = True, True, True, True

        async def _exec_set(attr, payload, label):
            try:
                resp = await self._run(MeterContext.frame_executor.execute, DLMSSetRequestNormal(cid, ln, attr, payload))
                ok = resp is not None and resp.is_success()
                if not ok: print(f"[SetPassiveCalendar] {label} failed: {resp}")
                return resp, ok
            except Exception as ex:
                print(f"[SetPassiveCalendar] {label} exception: {ex}")
                _tb.print_exc()
                return None, False

        class _RawDlmsBytes:
            def __init__(self, data: bytes):
                self._d = data
            def to_bytes(self) -> bytes:
                return self._d

        if write_name:
            actual_name_clean = actual_name.strip("\x00").strip()
            await _exec_set(6, self._visible_string(actual_name_clean), "Attr 6 (calendar name)")

        if write_seasons:
            # ── Validation, conflict detection, and sorting ─────────────────────
            # Performed before constructing the DLMS frame so a clear error can be
            # returned to the caller without touching the meter (requirement 9).
            known_weeks = (
                {wp.week_profile_name for wp in request.week_profiles}
                if request.week_profiles
                else None
            )

            validation_errors = []
            # Maps encoded season_start bytes → season_profile_name for conflict
            # detection.  Two entries mapping to the same bytes would resolve to
            # the same start time (including identical wildcard patterns such as
            # *-06-01 == *-06-01) and are therefore in conflict.
            seen_starts: dict = {}

            for sp in request.season_profiles:
                name = sp.season_profile_name
                week = sp.week_profile_name

                # Requirement 6a: season_profile_name must not be empty.
                if not name.strip():
                    validation_errors.append("season_profile_name must not be empty")
                    continue

                # Encoding constraint: profile names are stored as a single byte.
                if not name.isdigit() or not (0 <= int(name) <= 255):
                    validation_errors.append(
                        f"Season '{name}': season_profile_name must be a numeric value 0-255"
                    )
                    continue

                # Requirement 6b: week_name must reference an existing week profile
                # (validated only when the week-profile list is present in the request).
                if known_weeks is not None and week not in known_weeks:
                    validation_errors.append(
                        f"Season '{name}': week_profile_name '{week}' does not match "
                        f"any week profile in this request"
                    )

                # Requirements 4 & 7: detect conflicting season_start values.
                # Conflict is defined as two different seasons producing identical
                # DLMS date_time bytes.  Wildcard fields compare as equal to
                # themselves (e.g. *-06-01 == *-06-01 → conflict).
                start_bytes = self._encode_season_start_datetime(sp.season_start)
                if start_bytes in seen_starts:
                    validation_errors.append(
                        f"Season '{name}': season_start conflicts with season "
                        f"'{seen_starts[start_bytes]}' "
                        f"(duplicate DLMS encoding: {start_bytes.hex().upper()})"
                    )
                else:
                    seen_starts[start_bytes] = name

            if validation_errors:
                err_detail = " | ".join(validation_errors)
                print(f"[SetPassiveCalendar] Attr 7 validation failed: {err_detail}")
                await stream.send_message(meter_pb2.BoolValue(value=False))
                return

            # Requirement 5: sort season profiles by season_start in ascending order
            # before encoding, as required by the Blue Book.
            sorted_seasons = sorted(
                request.season_profiles,
                key=lambda sp: self._season_start_sort_key(sp.season_start),
            )

            # Requirement 10: build DLMS StructureData array.
            season_entries = [
                StructureData(value=[
                    OctetStringData(value=self._profile_name_to_octet(sp.season_profile_name)),
                    OctetStringData(value=self._encode_season_start_datetime(sp.season_start)),
                    OctetStringData(value=bytes([int(sp.week_profile_name)])),
                ])
                for sp in sorted_seasons
            ]

            _, ok7 = await _exec_set(7, ArrayData(value=season_entries).to_bytes(), "Attr 7 (season profiles)")
            if not ok7:
                await stream.send_message(meter_pb2.BoolValue(value=False))
                return

        week_entries = []
        for wp in request.week_profiles:
            week_entries.append(StructureData(value=[
                OctetStringData(value=self._profile_name_to_octet(wp.week_profile_name)),
                Unsigned8(value=wp.monday), Unsigned8(value=wp.tuesday),
                Unsigned8(value=wp.wednesday), Unsigned8(value=wp.thursday),
                Unsigned8(value=wp.friday), Unsigned8(value=wp.saturday), Unsigned8(value=wp.sunday),
            ]))
        if write_weeks:
            _, ok8 = await _exec_set(8, ArrayData(value=week_entries).to_bytes(), "Attr 8 (week profiles)")
            if not ok8:
                await stream.send_message(meter_pb2.BoolValue(value=False))
                return

        day_entries = []
        for dp in request.day_profiles:
            action_entries = []
            for action in dp.day_schedule:
                raw_ln = action.script_logical_name.strip()
                if raw_ln.lower().startswith("0x"): raw_ln = raw_ln[2:]
                raw_ln = raw_ln.replace(":", "").replace(" ", "").replace("-", "")
                try:
                    if len(raw_ln) % 2 != 0: raw_ln = "0" + raw_ln
                    script_ln_bytes = bytes.fromhex(raw_ln) if raw_ln else b"\x00" * 6
                    if len(script_ln_bytes) < 6: script_ln_bytes = script_ln_bytes.ljust(6, b"\x00")
                    elif len(script_ln_bytes) > 6: script_ln_bytes = script_ln_bytes[:6]
                except ValueError:
                    script_ln_bytes = b"\x00" * 6
                action_entries.append(StructureData(value=[
                    OctetStringData(value=self._encode_calendar_time(action.start_time)),
                    OctetStringData(value=script_ln_bytes),
                    Unsigned16(value=action.script_selector),
                ]))
            day_entries.append(StructureData(value=[Unsigned8(value=dp.day_id), ArrayData(value=action_entries)]))
        if write_days:
            _, ok9 = await _exec_set(9, ArrayData(value=day_entries).to_bytes(), "Attr 9 (day profiles)")
            await stream.send_message(meter_pb2.BoolValue(value=ok9))
        else:
            await stream.send_message(meter_pb2.BoolValue(value=True))

    @grpc_exception_handler
    async def GetSpecialDays(self, stream):
        obj = self._get_cal_object("SpecialDaysTable")
        data = await self._get_cal_attr(obj, 2)
        entries = []
        if data is not None:
            for entry in data.to_python():
                date_raw = entry[1] if isinstance(entry[1], (bytes, bytearray)) else bytes(entry[1])
                entries.append(meter_pb2.SpecialDayEntry(
                    index=entry[0],
                    special_day_date=self._parse_calendar_date(date_raw),
                    day_id=entry[2],
                ))
        await stream.send_message(meter_pb2.SpecialDayTable(entries=entries))

    @grpc_exception_handler
    async def GetPassiveSpecialDays(self, stream):
        obj = self._get_cal_object("SpecialDaysTable")
        data = await self._get_cal_attr(obj, 2)
        entries = []
        if data is not None:
            for entry in data.to_python():
                date_raw = entry[1] if isinstance(entry[1], (bytes, bytearray)) else bytes(entry[1])
                entries.append(meter_pb2.SpecialDayEntry(
                    index=entry[0],
                    special_day_date=self._parse_calendar_date(date_raw),
                    day_id=entry[2],
                ))
        await stream.send_message(meter_pb2.SpecialDayTable(entries=entries))

    @grpc_exception_handler
    async def SetPassiveSpecialDays(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to set special days")
        request: meter_pb2.SpecialDayTable = await stream.recv_message()
        obj = self._get_cal_object("SpecialDaysTable")
        entries = [StructureData(value=[
            Unsigned16(value=e.index),
            OctetStringData(value=self._encode_calendar_date(e.special_day_date)),
            Unsigned8(value=e.day_id),
        ]) for e in request.entries]
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(obj["classId"], obj["logicalName_hex"], 2, ArrayData(value=entries).to_bytes()),
            )
            ok = resp is not None and resp.is_success()
        except Exception as ex:
            print(f"[SetPassiveSpecialDays] Frame error: {ex}")
            _tb.print_exc()
            ok = False
        await stream.send_message(meter_pb2.BoolValue(value=ok))

    @grpc_exception_handler
    async def ActivatePassiveCalendar(self, stream):
        if SESSION.get_effective_right("ACTION") == "NO":
            raise Exception("User not allowed to activate passive calendar")
        obj = self._get_cal_object("ActivityCalendar")
        success = False
        try:
            resp = await self._run(
                MeterContext.frame_executor.execute,
                DLMSActionRequestNormal(obj["classId"], obj["logicalName_hex"], 1, Integer8(value=0).to_bytes()),
            )
            if isinstance(resp, DLMSActionResponseNormal):
                if resp.is_success():
                    success = True
                else:
                    result_name = resp.result.name if hasattr(resp, "result") else str(resp)
                    result_val = resp.result.value if hasattr(resp, "result") else "?"
                    raise Exception(
                        f"Meter rejected activation — ActionResult: {result_name} (code {result_val})."
                    )
            elif isinstance(resp, DLMSExceptionResponse):
                raise Exception(
                    f"Meter returned a service exception — service_error: {resp.service_error.name}, state_error: {resp.state_error.name}"
                )
            else:
                raise Exception(f"Unexpected response from meter: {type(resp).__name__}")
        except RuntimeError as e:
            if "Request not defined" in str(e):
                success = True
            else:
                raise
        await stream.send_message(meter_pb2.BoolValue(value=success))

