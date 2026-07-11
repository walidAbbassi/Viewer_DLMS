"""
Module-level DLMS utility functions shared across all service handlers.
SRP: only pure data-transformation helpers — no I/O, no gRPC, no DLMS calls.
"""


def dlms_unit_to_string(unit_enum: int) -> str:
    DLMS_UNITS = {
        0: "",
        1: "a",
        2: "mo",
        3: "wk",
        4: "d",
        5: "h",
        6: "min",
        7: "s",
        27: "W",
        28: "VA",
        29: "var",
        30: "Wh",
        31: "VAh",
        32: "varh",
        33: "A",
        35: "V",
        38: "Ω",
        44: "Hz",
        255: "",
    }
    return DLMS_UNITS.get(unit_enum, "")


def obis_short(obis_code: str) -> str:
    """Return the C.D.E part of an OBIS code (drops A-B: prefix and .F suffix)."""
    if ":" in obis_code:
        obis_code = obis_code.split(":", 1)[1]
    parts = obis_code.split(".")
    if len(parts) >= 3:
        return ".".join(parts[:3])
    return obis_code


def has_cell_info_rights(obj_gsm: dict, module_name: str) -> bool:
    """Return True if the current association has GET or SET on cell_info (attr 6 of GSMDiagnostic)."""
    if obj_gsm is None or not module_name:
        return False
    attr6 = next(
        (a for a in obj_gsm.get("dlmsAttribute", []) if str(a.get("id")) == "6"), None
    )
    if attr6 is None:
        return False
    for entry in attr6.get("accessRights", {}).values():
        if entry.get("name", "").lower() == module_name.lower():
            ar = entry.get("accessRights", "").lower()
            return bool(ar and ("get" in ar or "set" in ar))
    return False


def has_qos_rights(obj_gprs: dict, module_name: str) -> bool:
    """Return True if the current association has GET or SET on quality_of_service (attr 4 of GprsModemSetup)."""
    if obj_gprs is None or not module_name:
        return False
    attr4 = next(
        (a for a in obj_gprs.get("dlmsAttribute", []) if str(a.get("id")) == "4"), None
    )
    if attr4 is None:
        return False
    for entry in attr4.get("accessRights", {}).values():
        if entry.get("name", "").lower() == module_name.lower():
            ar = entry.get("accessRights", "").lower()
            return bool(ar and ("get" in ar or "set" in ar))
    return False

