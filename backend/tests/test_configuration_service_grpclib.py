from __future__ import annotations

import enum
from types import SimpleNamespace

import pytest

pytest.importorskip("grpclib")

ng_sdk = pytest.importorskip("ng_sdk")

import google.protobuf.empty_pb2

from gen.configuration_grpc import ConfigServiceStub
from gen import configuration_pb2
from service.configuration_service import ConfigurationService
import service.configuration_service as cfg_mod
import meter_context
from tests.conftest import open_channel, serve
from utils_any import any_to_python, python_to_any


class _FakeModule:
    def __init__(self):
        self.values = {}
        self.set_calls = []

    def set(self, key, value, to_file: bool):
        self.set_calls.append((key, value, to_file))
        self.values[key] = value

    def get(self, key, default=None):
        return self.values.get(key, default)


class _FakeAssociation(dict):
    def files(self):
        return sorted(list(self.keys()))


class _FakeConfiguration:
    def __init__(self, association, config_rules):
        self.association = association
        self.config_rules = config_rules


@pytest.mark.asyncio
async def test_set_config_sets_values_and_to_file_only_for_last(monkeypatch):



    module = _FakeModule()
    assoc = _FakeAssociation({"M1": module})

    fake_config = _FakeConfiguration(
        association=assoc,
        config_rules={"mode": "enum_TestEnum"},
    )

    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    class TestEnum(enum.IntEnum):
        AUTO = 1
        MANUAL = 2

    monkeypatch.setattr(cfg_mod, "load_enum_class", lambda _name, _key: TestEnum)

    req = configuration_pb2.SetConfigRequest(
        entries=[
            configuration_pb2.ConfigEntry(
                module="M1", key="mode", value=python_to_any("AUTO")
            ),
            configuration_pb2.ConfigEntry(
                module="M1", key="threshold", value=python_to_any(12)
            ),
        ],
        to_file=True,
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.SetConfig(req)

    assert resp.success is True
    assert "updated" in resp.message.lower()

    assert module.set_calls[0][0] == "mode"
    assert module.set_calls[0][1] == TestEnum.AUTO
    assert module.set_calls[0][2] is False

    assert module.set_calls[1][0] == "threshold"
    assert module.set_calls[1][1] == 12
    assert module.set_calls[1][2] is True


@pytest.mark.asyncio
async def test_set_config_enum_value_from_int_uses_enum_constructor(monkeypatch):



    module = _FakeModule()
    assoc = _FakeAssociation({"M1": module})

    fake_config = _FakeConfiguration(
        association=assoc,
        config_rules={"mode": "enum_TestEnum"},
    )

    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    class TestEnum(enum.IntEnum):
        AUTO = 1
        MANUAL = 2

    monkeypatch.setattr(cfg_mod, "load_enum_class", lambda _name, _key: TestEnum)

    req = configuration_pb2.SetConfigRequest(
        entries=[
            configuration_pb2.ConfigEntry(
                module="M1", key="mode", value=python_to_any(2)
            ),
        ],
        to_file=False,
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.SetConfig(req)

    assert resp.success is True
    assert module.set_calls == [("mode", TestEnum.MANUAL, False)]


@pytest.mark.asyncio
async def test_get_config_returns_only_existing_values(monkeypatch):


    module = _FakeModule()
    module.values["a"] = 123
    assoc = _FakeAssociation({"M1": module})
    fake_config = _FakeConfiguration(association=assoc, config_rules={})

    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    req = configuration_pb2.GetConfigRequest(
        identifiers=[
            configuration_pb2.ConfigIdentifier(module="M1", key="a"),
            configuration_pb2.ConfigIdentifier(module="M1", key="missing"),
        ]
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.GetConfig(req)

    assert len(resp.entries) == 1
    entry = resp.entries[0]
    assert entry.module == "M1"
    assert entry.key == "a"
    assert any_to_python(entry.value) == 123


@pytest.mark.asyncio
async def test_list_modules(monkeypatch):


    assoc = _FakeAssociation({"B": _FakeModule(), "A": _FakeModule()})
    fake_config = _FakeConfiguration(association=assoc, config_rules={})
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.ListModules(google.protobuf.empty_pb2.Empty())

    assert resp.modules == ["A", "B"]


@pytest.mark.asyncio
async def test_list_export_template_files(monkeypatch, tmp_path):


    # Créer une structure de dossiers temporaire pour les templates
    templates_folder = tmp_path / "templates"
    templates_folder.mkdir()

    # Créer des dossiers de types avec des fichiers
    xml_folder = templates_folder / "xml"
    xml_folder.mkdir()
    (xml_folder / "template1.xml").write_text("<xml/>")
    (xml_folder / "template2.xml").write_text("<xml/>")

    csv_folder = templates_folder / "csv"
    csv_folder.mkdir()
    (csv_folder / "data.csv").write_text("col1,col2")

    pdf_folder = templates_folder / "pdf"
    pdf_folder.mkdir()
    (pdf_folder / "report.pdf").write_bytes(b"PDF content")

    # Dossier vide (ne devrait pas apparaître dans les résultats)
    empty_folder = templates_folder / "empty"
    empty_folder.mkdir()

    # Fichier au niveau racine (ne devrait pas apparaître)
    (templates_folder / "root_file.txt").write_text("ignored")

    # Mock export_templates
    fake_export_templates = SimpleNamespace(templates_folder=str(templates_folder))
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.ListExportTemplateFiles(google.protobuf.empty_pb2.Empty())

    # Vérifier les résultats
    assert len(resp.entries) == 3

    # Convertir en dict pour faciliter les assertions
    entries_by_type = {entry.type: list(entry.files) for entry in resp.entries}

    assert "xml" in entries_by_type
    assert set(entries_by_type["xml"]) == {"template1.xml", "template2.xml"}

    assert "csv" in entries_by_type
    assert entries_by_type["csv"] == ["data.csv"]

    assert "pdf" in entries_by_type
    assert entries_by_type["pdf"] == ["report.pdf"]

    # Le dossier vide ne devrait pas apparaître
    assert "empty" not in entries_by_type


@pytest.mark.asyncio
async def test_list_export_template_files_nonexistent_folder(monkeypatch):


    # Mock avec un dossier qui n'existe pas
    fake_export_templates = SimpleNamespace(templates_folder="/nonexistent/path")
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.ListExportTemplateFiles(google.protobuf.empty_pb2.Empty())

    # Devrait retourner une liste vide sans erreur
    assert len(resp.entries) == 0


@pytest.mark.asyncio
async def test_set_export_templates_creates_new_page(monkeypatch):


    # Mock export_templates avec une liste vide de pages
    pages = []

    class _FakeExportTemplates:
        def __init__(self, pages_ref):
            self.pages = pages_ref

        def set(self, key, value, _to_file):
            if key == "pages":
                self.pages = value

    fake_export_templates = _FakeExportTemplates(pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    req = configuration_pb2.SetExportTemplatesRequest(
        page_name="dashboard",
        xml_template="dashboard.xml",
        csv_template="dashboard.csv",
        pdf_template="dashboard.pdf",
        docx_template="dashboard.docx",
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.SetExportTemplates(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que la page a été ajoutée
    assert len(pages) == 1
    assert pages[0]["page_name"] == "dashboard"
    assert pages[0]["xml_template"] == "dashboard.xml"
    assert pages[0]["csv_template"] == "dashboard.csv"
    assert pages[0]["pdf_template"] == "dashboard.pdf"
    assert pages[0]["docx_template"] == "dashboard.docx"


@pytest.mark.asyncio
async def test_set_export_templates_updates_existing_page(monkeypatch):


    # Mock export_templates avec une page existante
    pages = [
        {
            "page_name": "dashboard",
            "xml_template": "old.xml",
            "csv_template": "old.csv",
            "pdf_template": "old.pdf",
            "docx_template": "old.docx",
        }
    ]

    class _FakeExportTemplates:
        def __init__(self, pages_ref):
            self.pages = pages_ref

        def set(self, key, value, _to_file):
            if key == "pages":
                self.pages = value

    fake_export_templates = _FakeExportTemplates(pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    req = configuration_pb2.SetExportTemplatesRequest(
        page_name="dashboard",
        xml_template="new.xml",
        csv_template="new.csv",
        pdf_template="new.pdf",
        docx_template="new.docx",
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.SetExportTemplates(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que la page a été mise à jour (pas de nouvelle page créée)
    assert len(pages) == 1
    assert pages[0]["page_name"] == "dashboard"
    assert pages[0]["xml_template"] == "new.xml"
    assert pages[0]["csv_template"] == "new.csv"
    assert pages[0]["pdf_template"] == "new.pdf"
    assert pages[0]["docx_template"] == "new.docx"


@pytest.mark.asyncio
async def test_set_export_templates_multiple_pages(monkeypatch):


    # Mock export_templates avec plusieurs pages existantes
    pages = [
        {
            "page_name": "page1",
            "xml_template": "p1.xml",
            "csv_template": "p1.csv",
            "pdf_template": "p1.pdf",
            "docx_template": "p1.docx",
        },
        {
            "page_name": "page2",
            "xml_template": "p2.xml",
            "csv_template": "p2.csv",
            "pdf_template": "p2.pdf",
            "docx_template": "p2.docx",
        },
    ]

    class _FakeExportTemplates:
        def __init__(self, pages_ref):
            self.pages = pages_ref

        def set(self, key, value, _to_file):
            if key == "pages":
                self.pages = value

    fake_export_templates = _FakeExportTemplates(pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    # Ajouter une nouvelle page
    req = configuration_pb2.SetExportTemplatesRequest(
        page_name="page3",
        xml_template="p3.xml",
        csv_template="p3.csv",
        pdf_template="p3.pdf",
        docx_template="p3.docx",
    )

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.SetExportTemplates(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que la nouvelle page a été ajoutée sans toucher aux autres
    assert len(pages) == 3
    assert pages[0]["page_name"] == "page1"
    assert pages[1]["page_name"] == "page2"
    assert pages[2]["page_name"] == "page3"
    assert pages[2]["xml_template"] == "p3.xml"


@pytest.mark.asyncio
async def test_get_export_templates_existing_page(monkeypatch):


    # Mock export_templates avec des pages existantes
    pages = [
        {
            "page_name": "dashboard",
            "xml_template": "dash.xml",
            "csv_template": "dash.csv",
            "pdf_template": "dash.pdf",
            "docx_template": "dash.docx",
        },
        {
            "page_name": "report",
            "xml_template": "rep.xml",
            "csv_template": "rep.csv",
            "pdf_template": "rep.pdf",
            "docx_template": "rep.docx",
        },
    ]
    fake_export_templates = SimpleNamespace(pages=pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    req = configuration_pb2.GetExportTemplatesRequest(page_name="dashboard")

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.GetExportTemplates(req)

    # Vérifier que les templates corrects sont retournés
    assert resp.xml_template == "dash.xml"
    assert resp.csv_template == "dash.csv"
    assert resp.pdf_template == "dash.pdf"
    assert resp.docx_template == "dash.docx"


@pytest.mark.asyncio
async def test_get_export_templates_nonexistent_page(monkeypatch):


    # Mock export_templates avec des pages existantes
    pages = [
        {
            "page_name": "dashboard",
            "xml_template": "dash.xml",
            "csv_template": "dash.csv",
            "pdf_template": "dash.pdf",
            "docx_template": "dash.docx",
        }
    ]
    fake_export_templates = SimpleNamespace(pages=pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    # Demander une page qui n'existe pas
    req = configuration_pb2.GetExportTemplatesRequest(page_name="nonexistent")

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.GetExportTemplates(req)

    # Vérifier que des chaînes vides sont retournées
    assert resp.xml_template == ""
    assert resp.csv_template == ""
    assert resp.pdf_template == ""
    assert resp.docx_template == ""


@pytest.mark.asyncio
async def test_get_export_templates_empty_pages_list(monkeypatch):


    # Mock export_templates avec une liste vide
    pages = []
    fake_export_templates = SimpleNamespace(pages=pages)
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)

    req = configuration_pb2.GetExportTemplatesRequest(page_name="any_page")

    async with serve([ConfigurationService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = ConfigServiceStub(channel)
            resp = await stub.GetExportTemplates(req)

    # Vérifier que des chaînes vides sont retournées
    assert resp.xml_template == ""
    assert resp.csv_template == ""
    assert resp.pdf_template == ""
    assert resp.docx_template == ""

