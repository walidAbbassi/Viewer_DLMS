import os
import random
import secrets
import struct

import win32process
import win32security
import wmi
from typing import Tuple
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from license.aes_cipher import AESCipher
import xml.etree.ElementTree as ET


def decrypt_file_licence(hex_ciphered_key_str: str, file_licence_path):
    """
    Decipher File Licence using AES (CBC mode) with the given key
    :param hex_ciphered_key_str: Key to decipher file
    :param file_licence_path:  path file of licence
    :return: licence_xml_str
    """
    licence_xml_str = ""
    print("hex_ciphered_key_str 2:", hex_ciphered_key_str)
    try:
        if os.path.isfile(file_licence_path):
            with open(file_licence_path, "rb") as file_licence:
                struct.unpack("<Q", file_licence.read(struct.calcsize("Q")))
                iv = file_licence.read(16)

                cipher = Cipher(
                    algorithms.AES(hex_ciphered_key_str.encode()), modes.CBC(iv)
                )
                decryptor = cipher.decryptor()
                licence_xml_str = (
                    decryptor.update(file_licence.read(24 * 1024))
                    + decryptor.finalize()
                )

    except Exception as exception:
        raise exception

    return licence_xml_str


def encrypt_file_licence(hex_ciphered_key_str, parsed_xml, file_licence_path):
    """
    Cipher File Licence
    :param hex_ciphered_key_str: Key to cipher file
    :param parsed_xml: xml licence
    :param file_licence_path:  path file of licence
    :return:
    """
    licence_xml_str = parsed_xml
    try:
        if not isinstance(parsed_xml, str):
            licence_xml_str = ET.tostring(parsed_xml, encoding="utf8", method="xml")
        print("licence_xml_str", licence_xml_str)
        iv = secrets.token_bytes(16)
        print("iv", iv.hex().upper())
        file_size = len(licence_xml_str) + 24
        with open(file_licence_path, "wb") as file_licence:
            file_licence.write(struct.pack("<Q", file_size))
            file_licence.write(iv)
            licence_xml_str += " " * (16 - len(licence_xml_str) % 16)
            cipher = Cipher(
                algorithms.AES(hex_ciphered_key_str.encode()), modes.CBC(iv)
            )
            encryptor = cipher.encryptor()
            licence_data = (
                encryptor.update(licence_xml_str.encode()) + encryptor.finalize()
            )
            file_licence.write(licence_data)
    except Exception as exception:
        raise exception


def get_universally_unique_identifier():
    """
    Launches the command "wmic csproduct get UUID"' windowless without console
    :return:
    """
    try:
        # Create a WMI object
        c = wmi.WMI()

        # Retrieve the UUID of the computer
        uuid = c.Win32_ComputerSystemProduct()[0].UUID

        return str(uuid.replace("-", ""))
    except Exception as e:
        static_uuid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
        return str(static_uuid.replace("-", ""))


def get_security_identifiers():
    """
    Obtains information about SID
    example : whoami /user
    USER INFORMATION
    ----------------

    User Name  SID
    ========== ==============================================


    :return: sid_str
    """
    # Get the current process handle
    handle = win32process.GetCurrentProcess()

    # Get the SID of the current user
    sid_str = win32security.ConvertSidToStringSid(
        win32security.GetTokenInformation(
            win32security.OpenProcessToken(handle, win32security.TOKEN_READ),
            win32security.TokenUser,
        )[0]
    )

    return str(sid_str.replace("-", ""))


def get_key_licence(
    data_str: str, key_str: str = "0889504708895047"
) -> Tuple[bytes, str]:
    """
    Build Key Licence
    :param data_str: data to transform and use to decipher file
    :param key_str: key to transform and use to decipher file
    :return: ciphered_key_str, hex_ciphered_key_str
    """
    # AES initialization
    aes_cipher_object = AESCipher(key_str)
    # Cipher Key Value
    ciphered_key_str = aes_cipher_object.encrypt(str(data_str))
    print("ciphered_key_str: " + ciphered_key_str.hex().upper())
    # new key ciphered licence
    new_ciphered_key_str = ciphered_key_str[8:16] + ciphered_key_str[48:56]
    # raw ciphered key to hex format
    hex_ciphered_key_str = new_ciphered_key_str.hex().upper()
    print("hex_ciphered_key_str: " + hex_ciphered_key_str)
    return ciphered_key_str, hex_ciphered_key_str

    # -----------------------------
    # User Role
    # -----------------------------


def parse_user_node(licence_xml_bytes: bytes, username: str):
    """
    Retourne le node XML User correspondant au username (ou None si non trouvé).
    """
    root = ET.fromstring(licence_xml_bytes)
    users_node = root.find("Users")
    if users_node is None:
        return None

    for user_node in users_node:
        uname = (user_node.findtext("UserName", default="") or "").strip()
        if uname == username:
            return user_node
    return None
