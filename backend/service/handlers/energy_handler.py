"""
EnergyHandler — GetEnergyRegister, GetAverage, GetFresnelData.
SRP : lectures énergétiques (registres, moyennes, diagramme de Fresnel).
"""
import math

from ng_sdk.frame_builder.dlms.dlms_enums import DataAccessResult
from ng_sdk.frame_builder.dlms.xdlms.data_type.structure import StructureData
from ng_sdk.frame_builder.dlms.xdlms.data_type.unsigned_16 import Unsigned16
from ng_sdk.frame_builder.dlms.xdlms.get.request.dlms_get_request_normal import DLMSGetRequestNormal
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from util.fresnel import calculate_phi
from util.grpc_exception import grpc_exception_handler


class EnergyHandler(BaseHandler):
    """Gère GetEnergyRegister, GetAverage, GetFresnelData."""

    @grpc_exception_handler
    async def GetEnergyRegister(self, stream):
        await stream.recv_message()
        try:
            data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
            energy_objects = [
                obj for obj in data_model
                if obj.get("classId") in [3, 4]
                and obj.get("logicalName", "").startswith("1-0:")
                and ".8.0" in obj.get("logicalName", "")
            ]
            if not energy_objects:
                await stream.send_message(meter_pb2.EnergyRegisterList(items=[]))
                return

            class3_objects = [obj for obj in energy_objects if obj["classId"] == 3]
            value_response = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2) for obj in energy_objects],
            )
            scaler_response = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3) for obj in class3_objects],
            )
            value_results = value_response.result
            scaler_results = scaler_response.result
            scaler_map = {
                obj["logicalName_hex"]: scaler_results[i]
                for i, obj in enumerate(class3_objects)
            }
            unit_map = {30: "Wh", 32: "varh", 33: "VAh"}
            response_items = []
            for i, obj in enumerate(energy_objects):
                val_result = value_results[i]
                if val_result.data_access_result != DataAccessResult.SUCCESS or val_result.data is None:
                    continue
                raw_value = val_result.data.to_python()
                value_str = raw_value.decode("ascii", errors="ignore").rstrip("\x00\xff") \
                    if isinstance(raw_value, (bytes, bytearray)) else str(raw_value)
                description = obj.get("description", obj.get("name", obj["logicalName"]))
                unit = ""
                if obj["classId"] == 3 and obj["logicalName_hex"] in scaler_map:
                    sc = scaler_map[obj["logicalName_hex"]]
                    if sc.data_access_result == DataAccessResult.SUCCESS and sc.data is not None:
                        if isinstance(sc.data, StructureData):
                            elements = sc.data.to_python()
                            if len(elements) >= 2:
                                scaler, unit_code = elements[0], elements[1]
                                if isinstance(raw_value, (int, float)):
                                    value_str = str(raw_value * (10 ** scaler))
                                unit = unit_map.get(unit_code, "")
                response_items.append(meter_pb2.EnergyRegisterResponse(
                    description=description, value=f"{value_str} {unit}".strip()
                ))
            await stream.send_message(meter_pb2.EnergyRegisterList(items=response_items))
        except (ConnectionResetError, BrokenPipeError, TimeoutError,
                ConnectionRefusedError, IndexError, PermissionError):
            raise
        except Exception as e:
            print(f"Error in GetEnergyRegister: {str(e)}")
            await stream.send_message(meter_pb2.EnergyRegisterList(items=[]))

    @grpc_exception_handler
    async def GetAverage(self, stream):
        await stream.recv_message()
        average_c_values = {31, 32, 51, 52, 71, 72}
        try:
            data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
            average_objects = []
            for obj in data_model:
                class_id = obj.get("classId")
                logical_name = obj.get("logicalName", "")
                if class_id != 3 or ".24.0" not in logical_name:
                    continue
                try:
                    obis_part = logical_name.split(":", 1)[1]
                    c_value = int(obis_part.split(".")[0])
                except (IndexError, ValueError):
                    continue
                if c_value in average_c_values:
                    average_objects.append(obj)

            if not average_objects:
                await stream.send_message(meter_pb2.AverageList(items=[]))
                return

            unit_map = {35: "V", 33: "A"}
            value_response = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2) for obj in average_objects],
            )
            scaler_response = await self._run(
                MeterContext.frame_executor.execute_list,
                [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3) for obj in average_objects],
            )
            response_items = []
            for i, obj in enumerate(average_objects):
                val_result = value_response.result[i]
                if val_result.data_access_result != DataAccessResult.SUCCESS or val_result.data is None:
                    continue
                raw_value = val_result.data.to_python()
                value_str = str(raw_value)
                description = obj.get("description", obj.get("name", obj["logicalName"]))
                unit = ""
                sc = scaler_response.result[i]
                if sc.data_access_result == DataAccessResult.SUCCESS and sc.data is not None:
                    if isinstance(sc.data, StructureData):
                        elements = sc.data.to_python()
                        if len(elements) >= 2:
                            scaler, unit_code = elements[0], elements[1]
                            if isinstance(raw_value, (int, float)):
                                value_str = f"{raw_value * (10 ** scaler):.2f}"
                            unit = unit_map.get(unit_code, "")
                response_items.append(meter_pb2.AverageResponse(
                    description=description, value=f"{value_str} {unit}".strip()
                ))
            await stream.send_message(meter_pb2.AverageList(items=response_items))
        except (ConnectionResetError, BrokenPipeError, TimeoutError,
                ConnectionRefusedError, IndexError, PermissionError):
            raise
        except Exception as e:
            print(f"Error in GetAverage: {str(e)}")
            await stream.send_message(meter_pb2.AverageList(items=[]))

    @grpc_exception_handler
    async def GetFresnelData(self, stream):
        fresnel_objects = [
            "InstantaneousActiveImportPowerL1", "InstantaneousActiveImportPowerL2",
            "InstantaneousActiveImportPowerL3", "InstantaneousVoltageL1",
            "InstantaneousVoltageL2", "InstantaneousVoltageL3",
            "InstantaneousCurrentL1", "InstantaneousCurrentL2", "InstantaneousCurrentL3",
            "InstantaneousActiveExportPowerL1", "InstantaneousActiveExportPowerL2",
            "InstantaneousActiveExportPowerL3", "InstantaneousReactiveExportPowerL1",
            "InstantaneousReactiveExportPowerL2", "InstantaneousReactiveExportPowerL3",
            "InstantaneousReactiveImportPowerL1", "InstantaneousReactiveImportPowerL2",
            "InstantaneousReactiveImportPowerL3", "InstantaneousReactiveExportPowerL1",
            "InstantaneousReactiveExportPowerL2", "InstantaneousReactiveExportPowerL3",
        ]
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        fresnel_objects_value = {name: 0 for name in fresnel_objects}
        found = [
            (name, obj)
            for name in fresnel_objects
            for obj in [next((o for o in data_model if o["name"] == name), None)]
            if obj is not None
        ]
        if found:
            try:
                value_response = await self._run(
                    MeterContext.frame_executor.execute_list,
                    [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 2) for _, obj in found],
                )
                scaler_response = await self._run(
                    MeterContext.frame_executor.execute_list,
                    [DLMSGetRequestNormal(obj["classId"], obj["logicalName_hex"], 3) for _, obj in found],
                )
                for j, (name, _) in enumerate(found):
                    try:
                        val_r = value_response.result[j]
                        sc_r = scaler_response.result[j]
                        if (
                            val_r.data_access_result == DataAccessResult.SUCCESS
                            and val_r.data is not None
                            and sc_r.data_access_result == DataAccessResult.SUCCESS
                            and sc_r.data is not None
                        ):
                            fresnel_objects_value[name] = val_r.data.to_python() * (
                                10 ** sc_r.data.to_python()[0]
                            )
                    except Exception:
                        pass
            except Exception:
                pass

        u1 = fresnel_objects_value["InstantaneousVoltageL1"]
        u2 = fresnel_objects_value["InstantaneousVoltageL2"]
        u3 = fresnel_objects_value["InstantaneousVoltageL3"]
        i1 = fresnel_objects_value["InstantaneousCurrentL1"]
        i2 = fresnel_objects_value["InstantaneousCurrentL2"]
        i3 = fresnel_objects_value["InstantaneousCurrentL3"]
        p1 = fresnel_objects_value["InstantaneousActiveImportPowerL1"]
        p2 = fresnel_objects_value["InstantaneousActiveImportPowerL2"]
        p3 = fresnel_objects_value["InstantaneousActiveImportPowerL3"]
        q1 = fresnel_objects_value["InstantaneousReactiveImportPowerL1"]
        q2 = fresnel_objects_value["InstantaneousReactiveImportPowerL2"]
        q3 = fresnel_objects_value["InstantaneousReactiveImportPowerL3"]

        ph1 = self._calculate_phase_angle(p1, q1)
        ph2 = self._calculate_phase_angle(p2, q2)
        ph3 = self._calculate_phase_angle(p3, q3)

        phases = [
            meter_pb2.PhaseData(u=u1, i=i1, phi=ph1),
            meter_pb2.PhaseData(u=u2, i=i2, phi=ph2),
            meter_pb2.PhaseData(u=u3, i=i3, phi=ph3),
        ]
        await stream.send_message(meter_pb2.FresnelResponse(phases=phases))

    def _calculate_phase_angle(self, p, q) -> float:
        phi_rad = math.atan2(q, p)
        phi_deg = math.degrees(phi_rad)
        return 360 + phi_deg if phi_deg < 0 else phi_deg
