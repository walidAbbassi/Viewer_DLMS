"""
LoadProfileHandler — GetLoadProfile, GetLoadProfileParam, SetLoadProfileParam.
SRP : lecture et configuration du profil de charge (classe DLMS 7).
"""
import asyncio
import math
import time
import threading

from h2.exceptions import StreamClosedError
from grpclib.exceptions import StreamTerminatedError

from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.data_type.abstract_dlms_type import DLMS_TYPE_REGISTRY
from ng_sdk.frame_builder.dlms.xdlms.data_type.date_time import DateTime
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_32 import Unsigned32
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.set.request.dlms_set_request_normal import DLMSSetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.selective_access.capture_object_definition import CaptureObjectDefinition
from ng_sdk.frame_builder.dlms.xdlms.selective_access.entry_selective_access import EntrySelectiveAccess
from ng_sdk.frame_builder.dlms.xdlms.selective_access.range_selective_access import RangeSelectiveAccess
from ng_sdk.util.bytes_util import encode_variable_integer
from ng_sdk.util.dlms_time import get_optional_value, utc_offset_minutes

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from service.helpers.dlms_helpers import dlms_unit_to_string, obis_short
from session.session_manager import SESSION
from util.grpc_exception import grpc_exception_handler

_frame_executor_lock = threading.Lock()


class LoadProfileHandler(BaseHandler):
    """Gère GetLoadProfile, GetLoadProfileParam, SetLoadProfileParam."""


    async def GetLoadProfile(self, stream):
        front_request = await stream.recv_message()
        cancel_event = threading.Event()
        access_selector = None
        is_partial_read = False
        if front_request.HasField("start") and front_request.HasField("end"):
            is_partial_read = True
            start = front_request.start.datetime.ToDatetime()
            deviation = get_optional_value(
                int.from_bytes(bytes.fromhex(front_request.start.deviation_hex), "big", signed=True),
                b"\x80\x00", signed=True,
            )
            if deviation is not None:
                start = start.replace(tzinfo=utc_offset_minutes(deviation))
            end = front_request.end.datetime.ToDatetime()
            deviation = get_optional_value(
                int.from_bytes(bytes.fromhex(front_request.end.deviation_hex), "big", signed=True),
                b"\x80\x00", signed=True,
            )
            if deviation is not None:
                end = end.replace(tzinfo=utc_offset_minutes(deviation))
            capture_object_definition = CaptureObjectDefinition(1, bytes.fromhex("0000010000FF"), 2, 0)
            access_selector = RangeSelectiveAccess(
                DateTime(value=(start, None)).to_octet_string(),
                DateTime(value=(end, None)).to_octet_string(),
                capture_object_definition,
            )

        requested_page = getattr(front_request, "page", 0)
        page_size = getattr(front_request, "page_size", 0)
        page_size = page_size if page_size > 0 else 50

        loop = asyncio.get_running_loop()
        queue: asyncio.Queue = asyncio.Queue(maxsize=256)

        async def sender():
            try:
                while True:
                    item = await queue.get()
                    if item is None:
                        return
                    await stream.send_message(item)
            except (StreamClosedError, StreamTerminatedError, asyncio.CancelledError):

                return

        sender_task = asyncio.create_task(sender())

        def enqueue_from_any_thread(item) -> None:
            def _put_nowait():
                try:
                    queue.put_nowait(item)
                except asyncio.QueueFull:
                    pass
            loop.call_soon_threadsafe(_put_nowait)

        async def enqueue(item) -> None:
            try:
                await queue.put(item)
            except (asyncio.CancelledError, StreamTerminatedError):
                pass

        try:
            data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
            obj = next(
                (item for item in data_model if item["name"] == front_request.objectName), None
            )
            if obj is None:
                raise Exception("Object not found: " + front_request.objectName)
            if obj["classId"] != 7:
                raise Exception("Class id must be 7")

            if is_partial_read:
                _start_key = front_request.start.datetime.ToDatetime().isoformat()
                _end_key = front_request.end.datetime.ToDatetime().isoformat()
                full_cache_key = f"{front_request.objectName}:{_start_key}:{_end_key}"
            else:
                full_cache_key = front_request.objectName

            full_cache = MeterContext.class7_cache.get(full_cache_key)
            if full_cache is not None:
                all_values = full_cache["all_values"]
                cached_headers = full_cache["headers"]
                total_entries = len(all_values)
                total_pages = math.ceil(total_entries / page_size) if page_size > 0 else 1
                page = max(1, min(requested_page if requested_page > 0 else 1, total_pages))
                slice_start = (page - 1) * page_size
                slice_end = min(page * page_size, total_entries)
                await enqueue(meter_pb2.GetLoadProfileStreamItem(
                    result=meter_pb2.GetLoadProfileResponse(
                        headerTypes=cached_headers,
                        values=all_values[slice_start:slice_end],
                        total_entries=total_entries,
                        current_page=page,
                        total_pages=total_pages,
                    )
                ))
                return

            rows_total = None
            total_entries = 0
            total_data_size = 0

            await enqueue(meter_pb2.GetLoadProfileStreamItem(
                exec=meter_pb2.ExecutionProgress(message="Prepare table header")
            ))
            await asyncio.sleep(0)

            get_capture_object_response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3),
            )
            self._verify_get_response(get_capture_object_response)

            headers = []
            entry_size = 0
            for structure in get_capture_object_response.data.to_python():
                object_capture = next(
                    (item for item in data_model if item["logicalName_hex"] == structure[1].hex().upper()),
                    None,
                )
                if object_capture is not None:
                    name = object_capture["name"]
                    obis_code = object_capture.get("logicalName", "")
                    short_obis = obis_short(obis_code) if obis_code else ""
                    unit_label = ""
                    attribute_3 = next(
                        (attr for attr in object_capture["dlmsAttribute"] if attr["id"] == "3"), None
                    )
                    if attribute_3 is not None:
                        class_id = object_capture.get("classId", 0)
                        default_value = attribute_3.get("dlmsType", {}).get("defaultValue", None)
                        if isinstance(default_value, list):
                            if class_id in (3, 4, 5) and len(default_value) >= 2:
                                unit_enum_val = default_value[1]
                            else:
                                unit_enum_val = default_value[0] if len(default_value) > 0 else None
                            if unit_enum_val is not None:
                                unit_label = dlms_unit_to_string(unit_enum_val)
                    header_text = name
                    if short_obis:
                        header_text += f" ( {short_obis} )"
                    if unit_label:
                        header_text += f" {unit_label}"
                    headers.append(header_text)
                    attribute_2 = next(
                        (attr for attr in object_capture["dlmsAttribute"] if attr["id"] == "2"), None
                    )
                    if attribute_2 is not None:
                        if attribute_2["dlmsType"]["size"] > 0:
                            entry_size += attribute_2["dlmsType"]["size"]
                        cls = DLMS_TYPE_REGISTRY.get(attribute_2["dlmsType"]["type"])
                        if cls is not None and cls.LENGTH >= 0:
                            entry_size += cls.LENGTH
                        else:
                            entry_size += 1
                        entry_size += 1
                else:
                    headers.append(structure[1].hex().upper())

            await enqueue(meter_pb2.GetLoadProfileStreamItem(
                exec=meter_pb2.ExecutionProgress(message="Calculating full data size")
            ))
            await asyncio.sleep(0.001)

            try:
                get_entries_in_use_response = await self._run(
                    MeterContext.frame_executor.execute,
                    DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 7),
                )
                self._verify_get_response(get_entries_in_use_response)
                entry_size += 2
                rows_total = get_entries_in_use_response.data.to_python()
                total_data_size = rows_total * entry_size
                total_data_size = total_data_size + len(encode_variable_integer(rows_total)) + 2
                await enqueue(meter_pb2.GetLoadProfileStreamItem(
                    exec=meter_pb2.ExecutionProgress(
                        message=f"Reading ALL {rows_total} entries (entry_size: {entry_size}, total: {total_data_size} bytes)…"
                    )
                ))
                await asyncio.sleep(0.001)
            except Exception as e:
                rows_total = None

            start_time = [None]

            def progress_callback(bytes_read: int, count: int, finished: bool):
                rate_bytes_per_sec = 0
                if start_time[0] is not None:
                    elapsed_time = time.time() - start_time[0]
                    if elapsed_time > 0:
                        rate_bytes_per_sec = int(bytes_read / elapsed_time)
                if rows_total is not None and not is_partial_read:
                    msg = meter_pb2.GetLoadProfileStreamItem(
                        download=meter_pb2.DownloadProgress(
                            rows_total=rows_total,
                            bytes_total=total_data_size,
                            bytes_read=bytes_read,
                            percent=int(100 * bytes_read / total_data_size) if total_data_size else 0,
                            rate_bytes_per_sec=rate_bytes_per_sec,
                        )
                    )
                else:
                    msg = meter_pb2.GetLoadProfileStreamItem(
                        download=meter_pb2.DownloadProgress(
                            rows_total=0, bytes_total=0, bytes_read=0,
                            percent=count, rate_bytes_per_sec=rate_bytes_per_sec,
                        )
                    )
                enqueue_from_any_thread(msg)

            get_buffer_request = DLMSGetRequestNormal(
                obj["classId"], obj["logicalName_hex"], 2, access_selector
            )

            def blocking_execute():
                start_time[0] = time.time()
                with _frame_executor_lock:
                    return MeterContext.frame_executor.execute(get_buffer_request, progress_callback, cancel_event)

            try:
                get_buffer_response = await asyncio.to_thread(blocking_execute)
            except asyncio.CancelledError:
                print("cancel_event.set()")
                cancel_event.set()  # ✅ propagate cancel to thread
                raise  # ✅ let gRPC handle cancellation

            except Exception as e:
                print("except Exception as e",e)
                cancel_event.set()  # ✅ stop worker on error too
                raise

            self._verify_get_response(get_buffer_response)
            print("self._verify_get_response(get_buffer_response)")
            all_values_list = []
            for structure in get_buffer_response.data.to_python():
                values = []
                for idx, value in enumerate(structure):
                    if "Clock" in headers[idx]:
                        dt, clock_status = DateTime.from_bytes(value).to_python()
                        values.append(dt.strftime("%Y-%m-%d %H:%M:%S"))
                    elif isinstance(value, (bytes, bytearray)):
                        values.append(" ".join(f"{b:02X}" for b in value))
                    else:
                        values.append(str(value))
                all_values_list.append(meter_pb2.StringList(items=values))

            clock_col_idx = next(
                (i for i, h in enumerate(headers) if "Clock" in h), None
            )
            if clock_col_idx is not None:
                all_values_list.sort(
                    key=lambda row: row.items[clock_col_idx], reverse=True
                )

            total_entries = len(all_values_list)
            total_pages = math.ceil(total_entries / page_size) if page_size > 0 else 1

            MeterContext.class7_cache[full_cache_key] = {
                "entries_in_use": rows_total if rows_total is not None else total_entries,
                "headers": headers,
                "all_values": all_values_list,
            }

            page = max(1, min(requested_page if requested_page > 0 else 1, total_pages))
            slice_start = (page - 1) * page_size
            slice_end = min(page * page_size, total_entries)

            await enqueue(meter_pb2.GetLoadProfileStreamItem(
                result=meter_pb2.GetLoadProfileResponse(
                    headerTypes=headers,
                    values=all_values_list[slice_start:slice_end],
                    total_entries=total_entries,
                    current_page=page,
                    total_pages=total_pages,
                )
            ))
        except StreamTerminatedError:
            cancel_event.set()
            print("except (asyncio.CancelledError, StreamTerminatedError):")
            pass

        finally:
            try:
                await queue.put(None)
            except BaseException:
                pass
            try:
                await sender_task
            except BaseException:
                pass

    @grpc_exception_handler
    async def GetLoadProfileParam(self, stream):
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == front_request.objectName), None)
        if obj is None:
            raise Exception("Object not found: " + front_request.objectName)
        if obj["classId"] != 7:
            raise Exception("Class id must be 7")

        if front_request.param == meter_pb2.LoadProfileParam.MAX_RECORD:
            attribute_8 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "8"), None)
            if attribute_8 is None:
                raise Exception("Attribute 8 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 8),
            )
            self._verify_get_response(response)
            await stream.send_message(meter_pb2.Int32Value(value=response.data.to_python()))
        elif front_request.param == meter_pb2.LoadProfileParam.RECORD_NUMBER:
            attribute_7 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "7"), None)
            if attribute_7 is None:
                raise Exception("Attribute 7 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 7),
            )
            self._verify_get_response(response)
            await stream.send_message(meter_pb2.Int32Value(value=response.data.to_python()))
        elif front_request.param == meter_pb2.LoadProfileParam.CAPTURE_PERIOD:
            attribute_4 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "4"), None)
            if attribute_4 is None:
                raise Exception("Attribute 4 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 4),
            )
            self._verify_get_response(response)
            await stream.send_message(meter_pb2.Int32Value(value=response.data.to_python()))
        else:
            raise Exception("Unknown load profile request")

    @grpc_exception_handler
    async def SetLoadProfileParam(self, stream):
        if SESSION.get_effective_right("SET") == "NO":
            raise Exception("User not allowed to modify load profile configuration")
        front_request = await stream.recv_message()
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == front_request.objectName), None)
        if obj is None:
            raise Exception("Object not found: " + front_request.objectName)
        if obj["classId"] != 7:
            raise Exception("Class id must be 7")

        if front_request.param == meter_pb2.LoadProfileParam.MAX_RECORD:
            attribute_8 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "8"), None)
            if attribute_8 is None:
                raise Exception("Attribute 8 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 8,
                    Unsigned32(value=front_request.value).to_bytes(),
                ),
            )
            await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))
        elif front_request.param == meter_pb2.LoadProfileParam.RECORD_NUMBER:
            attribute_7 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "7"), None)
            if attribute_7 is None:
                raise Exception("Attribute 7 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 7,
                    Unsigned32(value=front_request.value).to_bytes(),
                ),
            )
            await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))
        elif front_request.param == meter_pb2.LoadProfileParam.CAPTURE_PERIOD:
            attribute_4 = next((attr for attr in obj["dlmsAttribute"] if attr["id"] == "4"), None)
            if attribute_4 is None:
                raise Exception("Attribute 4 not found")
            response = await self._run(
                MeterContext.frame_executor.execute,
                DLMSSetRequestNormal(
                    obj["classId"], obj["logicalName_hex"], 4,
                    Unsigned32(value=front_request.value).to_bytes(),
                ),
            )
            await stream.send_message(meter_pb2.BoolValue(value=response.is_success()))
        else:
            raise Exception("Unknown load profile request")
