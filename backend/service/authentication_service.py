from importlib.metadata import files
import os
import shutil
from logging import getLogger
from os.path import exists

from google.protobuf import empty_pb2

from gen import authentication_grpc, authentication_pb2
from license.aes_cipher import AESCipher
from license.parser import (
    get_universally_unique_identifier,
    get_key_licence,
    decrypt_file_licence,
    encrypt_file_licence,
)
from license.xml_validate import validate_xml_with_xsd
from util.constants import LICENSE_FOLDER
from util.grpc_exception import grpc_exception_handler
import xml.etree.ElementTree as ET
from session.session_manager import SESSION
from xsd.licence_xsd import XSD_LICENSE_DATA

logger = getLogger()
class AuthenticationService(authentication_grpc.AuthenticationServiceBase):

    @grpc_exception_handler
    async def ImportLicense(self, stream):
        front_request = await stream.recv_message()
        license_path = front_request.license_path
        # verify if file exists
        if not os.path.exists(license_path):
            raise Exception("File not found: " + license_path)

        uuid_str = get_universally_unique_identifier()
        ciphered_uuid_str, hex_ciphered_uuid_str = get_key_licence(uuid_str)
        license_xml = decrypt_file_licence(hex_ciphered_uuid_str, license_path)
        # decrypt returns raw bytes — decode and strip space-padding
        if isinstance(license_xml, bytes):
            license_xml = license_xml.decode("utf-8", errors="replace").rstrip()
        logger.debug("DEBUG license_xml[:200]:"+repr(license_xml[:200]))
        result, message = validate_xml_with_xsd(license_xml, XSD_LICENSE_DATA)
        if not result:
            raise Exception(message)
        # Create all directories in the destination path if they don't exist
        os.makedirs(LICENSE_FOLDER, exist_ok=True)
        # Copy the file into the destination folder
        shutil.copy(license_path, LICENSE_FOLDER)
        await stream.send_message(
            authentication_pb2.ImportLicenseResponse(success=True, error="")
        )

    @grpc_exception_handler
    async def Connexion(self, stream):
        front_request = await stream.recv_message()

        # Get all files (exclude directories)
        files = [
            f
            for f in os.listdir(LICENSE_FOLDER)
            if os.path.isfile(os.path.join(LICENSE_FOLDER, f))
        ]

        if not files:
            raise Exception("License not found. Import a license")

        # Sort by modification date (newest first)
        files.sort(
            key=lambda f: os.path.getmtime(os.path.join(LICENSE_FOLDER, f)),
            reverse=True,
        )

        authenticated = False

        # ✅ Loop over all license files
        for file_name in files:
            license_path = os.path.join(LICENSE_FOLDER, file_name)

            try:
                uuid_str = get_universally_unique_identifier()
                _, hex_ciphered_uuid_str = get_key_licence(uuid_str)

                license_xml = decrypt_file_licence(
                    hex_ciphered_uuid_str, license_path
                )

                # Decode if bytes
                if isinstance(license_xml, bytes):
                    license_xml = license_xml.decode(
                        "utf-8", errors="replace"
                    ).rstrip()

                # ✅ Validate XML
                result, message = validate_xml_with_xsd(
                    license_xml, XSD_LICENSE_DATA
                )
                if not result:
                    logger.debug(f"Invalid XSD in file {file_name}: {message}")
                    continue  # skip bad file

                root = ET.fromstring(license_xml)
                users_node = root.find("Users")
                if users_node is None:
                    continue

                # ✅ Loop over all users (User0, User1, ...)
                for user_node in users_node:
                    username = user_node.findtext("UserName", "").strip()
                    password = user_node.findtext("Password", "").strip()

                    if (
                            username == front_request.username
                            and password == front_request.password
                    ):
                        authenticated = True

                        # --- Extract user data ---
                        role = (
                                user_node.findtext("Role", "") or ""
                        ).strip()

                        right_list = _get_list_from_text_node(
                            user_node, "Right"
                        )
                        exclude_list = _get_list_from_text_node(
                            user_node, "ExcludeRightXml"
                        )
                        disable_list = _get_list_from_text_node(
                            user_node, "DisableFeatureXml"
                        )

                        trial_start = (
                                user_node.findtext("Trial_Period_Start", "") or ""
                        ).strip()

                        trial_end = (
                                user_node.findtext("Trial_Period_END", "") or ""
                        ).strip()

                        enterprise = (
                                user_node.findtext("Enterprise", "") or ""
                        ).strip()

                        # --- Store session ---
                        SESSION.set_user_role(role)
                        SESSION.set_right_list(right_list)
                        SESSION.set_exclude_right_list(exclude_list)
                        SESSION.set_disable_feature_list(disable_list)
                        SESSION.set_trial_period(trial_start, trial_end)
                        SESSION.set_enterprise(enterprise)

                        # --- Response ---
                        await stream.send_message(
                            authentication_pb2.ConnexionResponse(
                                success=True,
                                message="",
                                role=role,
                                rights=right_list,
                                disable_features=disable_list,
                                enterprise=enterprise,
                                trial_period_start=trial_start,
                                trial_period_end=trial_end,
                                exclude_rights=exclude_list,
                            )
                        )

                        return  # ✅ STOP everything after success

            except Exception as e:
                # ✅ Never crash on bad license
                logger.error(f"Error processing file {file_name}: {e}")
                continue

        # ✅ If no user matched across ALL files
        await stream.send_message(
            authentication_pb2.ConnexionResponse(
                success=False,
                message="username or password incorrect",
            )
        )
            # -----------------------------
            # User Role
            # ----------------------------

    @grpc_exception_handler
    async def ChangePassword(self, stream):
        front_request = await stream.recv_message()

        license_path = os.path.join(LICENSE_FOLDER, front_request.license)
        uuid_str = get_universally_unique_identifier()
        ciphered_uuid_str, hex_ciphered_uuid_str = get_key_licence(uuid_str)
        license_xml = decrypt_file_licence(hex_ciphered_uuid_str, license_path)

        # decrypt returns raw bytes — decode and strip space-padding
        if isinstance(license_xml, bytes):
            license_xml = license_xml.decode("utf-8", errors="replace").rstrip()
        result, message = validate_xml_with_xsd(
            license_xml, XSD_LICENSE_DATA
        )
        if not result:
            raise Exception(f"Invalid XSD in file : {message}")

        # Charger l'arbre XML
        root = ET.fromstring(license_xml)

        # Parcourir tous les utilisateurs
        for user_elem in root.findall(".//Users/*"):
            user_name = user_elem.find("UserName").text
            if user_name == front_request.username:
                current_password = (user_elem.find("Password").text or "").strip()
                if current_password == front_request.old_password:
                    user_elem.find("Password").text = front_request.new_password
                    logger.debug(
                        f"Mot de passe de '{front_request.username}' changé avec succès !"
                    )
                    license_xml = ET.tostring(root, encoding="unicode")
                    encrypt_file_licence(
                        hex_ciphered_uuid_str, license_xml, license_path
                    )
                    await stream.send_message(
                        authentication_pb2.ChangePasswordResponse(
                            success=True, message=""
                        )
                    )
                else:
                    await stream.send_message(
                        authentication_pb2.ChangePasswordResponse(
                            success=False, message="Old password incorrect"
                        )
                    )

                break
        else:
            raise Exception("User not found")

    async def CheckLicense(self, stream):
        exists = os.path.isdir(LICENSE_FOLDER) and bool(os.listdir(LICENSE_FOLDER))
        identifier = ""
        licenses = []


        if not exists:
            uuid_str = get_universally_unique_identifier()
            aesCipher = AESCipher("0889504708895047")
            encrypted = aesCipher.encrypt(uuid_str)
            identifier = encrypted.decode("utf-8")
        else:
            files = [
                f
                for f in os.listdir(LICENSE_FOLDER)
                if os.path.isfile(os.path.join(LICENSE_FOLDER, f))
            ]

            for file_name in files:
                file_path = os.path.join(LICENSE_FOLDER, file_name)

                # You can decide what "label" means
                # Example: use filename without extension
                label = os.path.splitext(file_name)[0]

                licenses.append(
                    authentication_pb2.LicenseInfo(
                        label=label,
                        file=file_name  # or file_path if you want full path
                    )
                )
        await stream.send_message(
            authentication_pb2.CheckLicenseResponse(
                exists=exists, identifier=identifier,licenses = licenses
            )
        )

    @grpc_exception_handler
    async def DeleteLicenses(self, stream):
        front_request = await stream.recv_message()

        files = [
            f
            for f in os.listdir(LICENSE_FOLDER)
            if os.path.isfile(os.path.join(LICENSE_FOLDER, f))
        ]

        if not files:
            raise Exception("License not found. Import a license")

        # Sort newest first
        files.sort(
            key=lambda f: os.path.getmtime(os.path.join(LICENSE_FOLDER, f)),
            reverse=True,
        )

        # ✅ Loop over files
        for file_name in files:
            license_path = os.path.join(LICENSE_FOLDER, file_name)

            try:
                uuid_str = get_universally_unique_identifier()
                _, hex_ciphered_uuid_str = get_key_licence(uuid_str)

                license_xml = decrypt_file_licence(
                    hex_ciphered_uuid_str, license_path
                )

                # Decode
                if isinstance(license_xml, bytes):
                    license_xml = license_xml.decode(
                        "utf-8", errors="replace"
                    ).rstrip()

                # ✅ Validate XML
                result, message = validate_xml_with_xsd(
                    license_xml, XSD_LICENSE_DATA
                )
                if not result:
                    logger.debug(f"Invalid XSD in file {file_name}: {message}")
                    continue

                root = ET.fromstring(license_xml)
                users_node = root.find("Users")
                if users_node is None:
                    continue

                # ✅ Loop over users
                for user_node in users_node:
                    username = user_node.findtext("UserName", "").strip()
                    password = user_node.findtext("Password", "").strip()

                    if (
                            username == front_request.username
                            and password == front_request.password
                    ):
                        # ✅ MATCH FOUND → delete files
                        for filename in os.listdir(LICENSE_FOLDER):
                            file_path = os.path.join(LICENSE_FOLDER, filename)
                            if os.path.isfile(file_path):
                                os.remove(file_path)
                        await stream.send_message(empty_pb2.Empty())
                        return  # ✅ EXIT everything immediately

            except Exception as e:
                logger.error(f"Error processing {file_name}: {e}")
                continue

        # ✅ No match found
        raise Exception("User not found")


def _get_list_from_text_node(user_node, tag_name: str):
    """
    Lit un noeud texte contenant un tableau style: "[Get,Set,Action]"
    Ex: tag_name="Right" | "ExcludeRightXml" | "DisableFeatureXml"
    Retourne une liste de strings en minuscules standards côté comparaison.
    """
    node = user_node.find(tag_name)
    if node is None or node.text is None:
        return []

    text = node.text.strip()
    # Supprimer crochets et espaces superflus
    text = text.replace("[", "").replace("]", "")
    if not text:
        return []

    items = []
    for item in text.split(","):
        val = item.strip()
        if val:
            items.append(
                val
            )  # on garde la casse d’origine; .lower() au moment des comparaisons
    return items
