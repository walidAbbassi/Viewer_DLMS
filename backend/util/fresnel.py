import numpy as np


def calculate_phi(
    inst_reactive_import,
    inst_reactive_export,
    inst_active_import,
    inst_active_export,
    inst_voltage_l,
    inst_current_l,
):
    try:
        dividend_sin = inst_reactive_import - inst_reactive_export
        dividend_cos = inst_active_import - inst_active_export
        divisor = inst_voltage_l * inst_current_l

    except:
        return 0  # type returned unmatched to apply float --> float("undefined object") not applicable
    if divisor == 0:
        return 0
    cos_phi = dividend_cos / np.sqrt((dividend_cos**2) + (dividend_sin**2))
    phi = np.rad2deg(np.arccos(limited(cos_phi, -1, 1)))
    if np.isnan(phi):
        cos_phi = dividend_cos / divisor

    phi = np.rad2deg(np.arccos(limited(cos_phi, -1, 1)))
    if np.isnan(phi):
        cos_phi = dividend_cos / divisor
        phi = np.rad2deg(np.arccos(limited(cos_phi, -1, 1)))

    if dividend_sin < 0:
        phi = -phi

    return phi


def limited(n, minn, max_n):
    if n < minn:
        return minn
    elif n > max_n:
        return max_n
    else:
        return n
