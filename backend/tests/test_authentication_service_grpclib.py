from __future__ import annotations

import os
from pathlib import Path

import pytest

pytest.importorskip("grpclib")

from grpclib import GRPCError, Status

from gen.authentication_grpc import AuthenticationServiceStub
from gen import authentication_pb2
from service.authentication_service import AuthenticationService
import service.authentication_service as auth_mod
from tests.conftest import open_channel, serve


def _license_xml(username: str = "admin", password: str = "pw") -> str:
    return (
        "<License>"
        "<Users>"
        "<User0>"
        f"<UserName>{username}</UserName>"
        f"<Password>{password}</Password>"
        "<Role>LocalAdmin</Role>"
        "<Right>[Get,Set,Action]</Right>"
        "<ExcludeRightXml>[metera]</ExcludeRightXml>"
        "<DisableFeatureXml>[FWUpdate]</DisableFeatureXml>"
        "<Trial_Period_Start>2026-01-01</Trial_Period_Start>"
        "<Trial_Period_END>2026-12-31</Trial_Period_END>"
        "<Enterprise>TestCorp</Enterprise>"
        "</User0>"
        "</Users>"
        "</License>"
    )


def _license_xml_no_users() -> str:
    return "<License></License>"


def _license_xml_empty_users() -> str:
    return "<License><Users></Users></License>"


@pytest.mark.asyncio
async def test_import_license_success(tmp_path, monkeypatch):


    license_src = tmp_path / "src.lic"
    license_src.write_bytes(b"dummy")

    license_dst_dir = tmp_path / "license_store"
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))

    called = {"decrypt": 0}

    def _decrypt(hex_key: str, path: str):
        assert hex_key == "hex"
        assert path == str(license_src)
        called["decrypt"] += 1
        return _license_xml()

    monkeypatch.setattr(auth_mod, "decrypt_file_licence", _decrypt)

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            resp = await stub.ImportLicense(
                authentication_pb2.ImportLicenseRequest(license_path=str(license_src))
            )

    assert resp.success is True
    assert resp.error == ""
    assert called["decrypt"] == 1
    copied = license_dst_dir / license_src.name
    assert copied.exists(), f"Expected copied license at {copied}"


@pytest.mark.asyncio
async def test_import_license_missing_file_returns_internal(monkeypatch, tmp_path):


    license_dst_dir = tmp_path / "license_store"
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            with pytest.raises(GRPCError) as exc:
                await stub.ImportLicense(
                    authentication_pb2.ImportLicenseRequest(
                        license_path=str(tmp_path / "does_not_exist.lic")
                    )
                )

    assert exc.value.status == Status.INTERNAL
    assert "File not found:" in (exc.value.message or "")


@pytest.mark.asyncio
async def test_connexion_no_license_returns_internal(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            with pytest.raises(GRPCError) as exc:
                await stub.Connexion(
                    authentication_pb2.ConnexionRequest(username="u", password="p")
                )

    assert exc.value.status == Status.INTERNAL
    assert "License not found" in (exc.value.message or "")


@pytest.mark.asyncio
async def test_connexion_success_and_failure(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    (license_dst_dir / "a.lic").write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod,
        "decrypt_file_licence",
        lambda _hex, _path: _license_xml("admin", "pw"),
    )

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)

            ok = await stub.Connexion(
                authentication_pb2.ConnexionRequest(username="admin", password="pw")
            )
            bad = await stub.Connexion(
                authentication_pb2.ConnexionRequest(username="admin", password="wrong")
            )

    assert ok.success is True
    assert ok.message == ""
    assert ok.role == "LocalAdmin"
    assert list(ok.rights) == ["Get", "Set", "Action"]
    assert list(ok.disable_features) == ["FWUpdate"]
    assert ok.enterprise == "TestCorp"
    assert ok.trial_period_start == "2026-01-01"
    assert ok.trial_period_end == "2026-12-31"
    assert bad.success is False
    assert "incorrect" in bad.message


@pytest.mark.asyncio
async def test_connexion_missing_users_node_returns_internal(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    (license_dst_dir / "a.lic").write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod, "decrypt_file_licence", lambda _hex, _path: _license_xml_no_users()
    )

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            resp = await stub.Connexion(
                authentication_pb2.ConnexionRequest(username="u", password="p")
            )

    # Service now returns success=False when license XML fails XSD validation
    # (no <Users> element causes XSD failure → continue → no match found)
    assert resp.success is False
    assert "incorrect" in (resp.message or "")


@pytest.mark.asyncio
async def test_connexion_empty_users_returns_internal(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    (license_dst_dir / "a.lic").write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod, "decrypt_file_licence", lambda _hex, _path: _license_xml_empty_users()
    )

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            resp = await stub.Connexion(
                authentication_pb2.ConnexionRequest(username="u", password="p")
            )

    # Service now returns success=False when no matching user found
    assert resp.success is False
    assert "incorrect" in (resp.message or "")


@pytest.mark.asyncio
async def test_change_password_success_updates_xml(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    license_path = license_dst_dir / "a.lic"
    license_path.write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod,
        "decrypt_file_licence",
        lambda _hex, _path: _license_xml("admin", "old"),
    )

    captured = {}

    def _encrypt(hex_key: str, xml: str, path: str):
        captured["hex"] = hex_key
        captured["xml"] = xml
        captured["path"] = path

    monkeypatch.setattr(auth_mod, "encrypt_file_licence", _encrypt)

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            resp = await stub.ChangePassword(
                authentication_pb2.ChangePasswordRequest(
                    username="admin", old_password="old", new_password="new",
                    license="a.lic"
                )
            )

    assert resp.success is True
    assert resp.message == ""
    assert captured["hex"] == "hex"
    assert captured["path"] == str(license_path)
    assert "<Password>new</Password>" in captured["xml"]


@pytest.mark.asyncio
async def test_change_password_old_password_incorrect(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    (license_dst_dir / "a.lic").write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod,
        "decrypt_file_licence",
        lambda _hex, _path: _license_xml("admin", "old"),
    )

    called = {"encrypt": 0}
    monkeypatch.setattr(
        auth_mod,
        "encrypt_file_licence",
        lambda *_args, **_kwargs: called.__setitem__("encrypt", called["encrypt"] + 1),
    )

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            resp = await stub.ChangePassword(
                authentication_pb2.ChangePasswordRequest(
                    username="admin", old_password="wrong", new_password="new"
                )
            )

    assert resp.success is False
    assert "Old password" in resp.message
    assert called["encrypt"] == 0


@pytest.mark.asyncio
async def test_change_password_user_not_found_returns_internal(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    (license_dst_dir / "a.lic").write_bytes(b"dummy")
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    monkeypatch.setattr(auth_mod, "get_universally_unique_identifier", lambda: "uuid")
    monkeypatch.setattr(auth_mod, "get_key_licence", lambda _uuid: ("cipher", "hex"))
    monkeypatch.setattr(
        auth_mod,
        "decrypt_file_licence",
        lambda _hex, _path: _license_xml("someoneelse", "pw"),
    )

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            with pytest.raises(GRPCError) as exc:
                await stub.ChangePassword(
                    authentication_pb2.ChangePasswordRequest(
                        username="admin", old_password="old", new_password="new"
                    )
                )

    assert exc.value.status == Status.INTERNAL
    assert (exc.value.message or "") == "User not found"


@pytest.mark.asyncio
async def test_change_password_no_license_returns_internal(tmp_path, monkeypatch):


    license_dst_dir = tmp_path / "license_store"
    license_dst_dir.mkdir()
    monkeypatch.setattr(auth_mod, "LICENSE_FOLDER", str(license_dst_dir))

    async with serve([AuthenticationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = AuthenticationServiceStub(channel)
            with pytest.raises(GRPCError) as exc:
                await stub.ChangePassword(
                    authentication_pb2.ChangePasswordRequest(
                        username="admin", old_password="old", new_password="new",
                        license="nonexistent.lic"
                    )
                )

    assert exc.value.status == Status.INTERNAL
    # Service fails to read/decrypt nonexistent license (no match found or invalid file)
    assert exc.value.message is not None


# ------------------------------------------------------------------
# Tests for _get_list_from_text_node (sync helper, no longer async)
# ------------------------------------------------------------------
import xml.etree.ElementTree as ET
from service.authentication_service import _get_list_from_text_node


def test_get_list_from_text_node_returns_list():
    """_get_list_from_text_node must return a plain list, not a coroutine."""
    xml_str = "<User><Right>[Get,Set,Action]</Right></User>"
    user_node = ET.fromstring(xml_str)
    result = _get_list_from_text_node(user_node, "Right")
    assert isinstance(result, list), f"Expected list, got {type(result)}"
    assert result == ["Get", "Set", "Action"]


def test_get_list_from_text_node_missing_tag():
    xml_str = "<User></User>"
    user_node = ET.fromstring(xml_str)
    result = _get_list_from_text_node(user_node, "Right")
    assert result == []


def test_get_list_from_text_node_empty_text():
    xml_str = "<User><Right></Right></User>"
    user_node = ET.fromstring(xml_str)
    result = _get_list_from_text_node(user_node, "Right")
    assert result == []
