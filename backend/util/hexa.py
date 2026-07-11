def hex_to_int(s: str):
    s = s.strip()
    if s.lower().startswith("0x"):
        s = s[2:]
    return int(s, 16)
