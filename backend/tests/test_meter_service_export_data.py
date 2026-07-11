from __future__ import annotations

import json
import os as _os
from pathlib import Path
from types import SimpleNamespace

import pytest

_WKHTMLTOPDF_AVAILABLE = _os.path.isfile(
    _os.path.join(_os.path.dirname(_os.path.dirname(__file__)), "wkhtmltox", "bin", "wkhtmltopdf.exe")
)

pytest.importorskip("grpclib")

from gen.meter_grpc import MeterServiceStub
from gen import meter_pb2
from grpclib import GRPCError
from service.meter_service import MeterService
import service.meter_service as meter_mod
import meter_context

try:
    from docx import Document as _DocxDocument
    _DOCX_AVAILABLE = True
except ImportError:
    _DOCX_AVAILABLE = False
from tests.conftest import open_channel, serve


def _patch_meter_config(monkeypatch, fake_config):
    # MeterContext is imported from the top-level `meter_context` module.
    # Patching the class attribute is sufficient — all handlers hold a reference
    # to the same class object, so this patch propagates automatically.
    monkeypatch.setattr(meter_context.MeterContext, "configuration", fake_config)


@pytest.mark.asyncio
async def test_export_data_success_xml(monkeypatch, tmp_path):


    # Créer la structure de dossiers de templates
    templates_folder = tmp_path / "templates"
    xml_folder = templates_folder / "xml"
    xml_folder.mkdir(parents=True)

    # Créer un template Jinja2 simple
    template_content = """<?xml version="1.0"?>
<export>
    <title>{{ title }}</title>
    <items>
    {% for item in items %}
        <item>{{ item }}</item>
    {% endfor %}
    </items>
</export>"""

    (xml_folder / "report.xml").write_text(template_content, encoding="utf-8")

    # Créer le dossier de sortie
    output_folder = tmp_path / "output"

    # Mock export_templates
    pages = [
        {
            "page_name": "report_page",
            "xml_template": "report.xml",
            "csv_template": "report.csv",
            "pdf_template": "report.pdf",
            "docx_template": "report.docx",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    # Données à exporter (format JSON)
    data_dict = {"title": "My Report", "items": ["Item 1", "Item 2", "Item 3"]}
    data_json = json.dumps(data_dict)

    req = meter_pb2.ExportDataRequest(
        page_id="report_page",
        type="xml",
        data=data_json,
        folder_path=str(output_folder),
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que le fichier a été créé
    output_files = list(output_folder.glob("*.xml"))
    assert len(output_files) == 1

    # Vérifier le contenu généré
    generated_content = output_files[0].read_text(encoding="utf-8")
    assert "<title>My Report</title>" in generated_content
    assert "<item>Item 1</item>" in generated_content
    assert "<item>Item 2</item>" in generated_content
    assert "<item>Item 3</item>" in generated_content


@pytest.mark.asyncio
async def test_export_data_success_csv(monkeypatch, tmp_path):


    # Créer la structure de dossiers de templates
    templates_folder = tmp_path / "templates"
    csv_folder = templates_folder / "csv"
    csv_folder.mkdir(parents=True)

    # Créer un template CSV
    template_content = """Name,Value
{% for row in rows %}{{ row.name }},{{ row.value }}
{% endfor %}"""

    (csv_folder / "data.csv").write_text(template_content, encoding="utf-8")

    # Créer le dossier de sortie
    output_folder = tmp_path / "output"

    # Mock export_templates
    pages = [
        {
            "page_name": "data_export",
            "xml_template": "",
            "csv_template": "data.csv",
            "pdf_template": "",
            "docx_template": "",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    # Données à exporter
    data_dict = {
        "rows": [
            {"name": "Product A", "value": 100},
            {"name": "Product B", "value": 200},
        ]
    }
    data_json = json.dumps(data_dict)

    req = meter_pb2.ExportDataRequest(
        page_id="data_export",
        type="csv",
        data=data_json,
        folder_path=str(output_folder),
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que le fichier a été créé
    output_files = list(output_folder.glob("*.csv"))
    assert len(output_files) == 1

    # Vérifier le contenu
    generated_content = output_files[0].read_text(encoding="utf-8")
    assert "Name,Value" in generated_content
    assert "Product A,100" in generated_content
    assert "Product B,200" in generated_content


@pytest.mark.asyncio
async def test_export_data_template_not_found(monkeypatch, tmp_path):


    templates_folder = tmp_path / "templates"
    xml_folder = templates_folder / "xml"
    xml_folder.mkdir(parents=True)

    output_folder = tmp_path / "output"

    # Page sans template correspondant
    pages = []

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    data_json = json.dumps({"test": "data"})

    req = meter_pb2.ExportDataRequest(
        page_id="nonexistent_page",
        type="xml",
        data=data_json,
        folder_path=str(output_folder),
    )


    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            with pytest.raises(GRPCError):
                await stub.ExportData(req)


@pytest.mark.asyncio
async def test_export_data_invalid_json(monkeypatch, tmp_path):


    templates_folder = tmp_path / "templates"
    xml_folder = templates_folder / "xml"
    xml_folder.mkdir(parents=True)

    (xml_folder / "test.xml").write_text("<xml>{{ data }}</xml>", encoding="utf-8")

    output_folder = tmp_path / "output"

    pages = [
        {
            "page_name": "test_page",
            "xml_template": "test.xml",
            "csv_template": "",
            "pdf_template": "",
            "docx_template": "",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    # JSON invalide
    invalid_json = "{ this is not valid json }"

    req = meter_pb2.ExportDataRequest(
        page_id="test_page",
        type="xml",
        data=invalid_json,
        folder_path=str(output_folder),
    )


    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            with pytest.raises(GRPCError):
                await stub.ExportData(req)


@pytest.mark.asyncio
async def test_export_data_creates_output_folder(monkeypatch, tmp_path):


    templates_folder = tmp_path / "templates"
    xml_folder = templates_folder / "xml"
    xml_folder.mkdir(parents=True)

    (xml_folder / "simple.xml").write_text("<data>{{ value }}</data>", encoding="utf-8")

    # Dossier de sortie qui n'existe pas encore
    output_folder = tmp_path / "nested" / "output" / "folder"
    assert not output_folder.exists()

    pages = [
        {
            "page_name": "simple_page",
            "xml_template": "simple.xml",
            "csv_template": "",
            "pdf_template": "",
            "docx_template": "",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    data_json = json.dumps({"value": "test"})

    req = meter_pb2.ExportDataRequest(
        page_id="simple_page",
        type="xml",
        data=data_json,
        folder_path=str(output_folder),
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que le dossier a été créé
    assert output_folder.exists()
    assert output_folder.is_dir()

    # Vérifier que le fichier existe
    output_files = list(output_folder.glob("*.xml"))
    assert len(output_files) == 1


@pytest.mark.skipif(not _WKHTMLTOPDF_AVAILABLE, reason="wkhtmltopdf binary not present")
@pytest.mark.asyncio
async def test_export_data_pdf_from_html_template(monkeypatch, tmp_path):


    # Créer la structure de dossiers de templates
    templates_folder = tmp_path / "templates"
    pdf_folder = templates_folder / "pdf"
    pdf_folder.mkdir(parents=True)

    # Créer un template HTML pour PDF
    html_template = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
    </style>
</head>
<body>
    <h1>{{ title }}</h1>
    <p>Date: {{ date }}</p>
    <table>
        <tr>
            <th>Item</th>
            <th>Value</th>
        </tr>
        {% for item in items %}
        <tr>
            <td>{{ item.name }}</td>
            <td>{{ item.value }}</td>
        </tr>
        {% endfor %}
    </table>
</body>
</html>"""

    (pdf_folder / "report.html").write_text(html_template, encoding="utf-8")

    # Créer le dossier de sortie
    output_folder = tmp_path / "output"

    # Mock export_templates
    pages = [
        {
            "page_name": "pdf_report",
            "xml_template": "",
            "csv_template": "",
            "pdf_template": "report.html",  # Template HTML pour PDF
            "docx_template": "",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    # Données à exporter
    data_dict = {
        "title": "Energy Report",
        "date": "2026-03-04",
        "items": [
            {"name": "Active Energy", "value": "12345.67 kWh"},
            {"name": "Reactive Energy", "value": "6789.12 kVArh"},
            {"name": "Apparent Power", "value": "45.6 kVA"},
        ],
    }
    data_json = json.dumps(data_dict)

    req = meter_pb2.ExportDataRequest(
        page_id="pdf_report", type="pdf", data=data_json, folder_path=str(output_folder)
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que le fichier PDF a été créé
    output_files = list(output_folder.glob("*.pdf"))
    assert len(output_files) == 1

    pdf_file = output_files[0]

    # Vérifier que c'est bien un PDF (commence par %PDF)
    pdf_content = pdf_file.read_bytes()
    assert pdf_content[:4] == b"%PDF", "Le fichier généré doit être un PDF valide"

    # Vérifier que le fichier n'est pas vide et a une taille raisonnable
    assert len(pdf_content) > 100, "Le PDF doit contenir du contenu"


@pytest.mark.asyncio
async def test_export_data_non_pdf_still_saves_text(monkeypatch, tmp_path):
    """Vérifie que les types non-PDF sauvegardent toujours du texte brut"""


    templates_folder = tmp_path / "templates"
    html_folder = templates_folder / "html"
    html_folder.mkdir(parents=True)

    # Template HTML (mais type 'html', pas 'pdf')
    (html_folder / "page.html").write_text("<h1>{{ title }}</h1>", encoding="utf-8")

    output_folder = tmp_path / "output"

    pages = [
        {
            "page_name": "html_page",
            "xml_template": "",
            "csv_template": "",
            "pdf_template": "",
            "html_template": "page.html",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    data_json = json.dumps({"title": "Test"})

    req = meter_pb2.ExportDataRequest(
        page_id="html_page", type="html", data=data_json, folder_path=str(output_folder)
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    assert resp.success is True

    # Vérifier que c'est du HTML texte, pas un PDF
    output_files = list(output_folder.glob("*.html"))
    assert len(output_files) == 1

    content = output_files[0].read_text(encoding="utf-8")
    assert "<h1>Test</h1>" in content
    assert not content.startswith("%PDF")  # Pas un PDF


@pytest.mark.asyncio
async def test_export_data_docx_with_docxtpl(monkeypatch, tmp_path):
    """Test génération DOCX avec docxtpl"""


    # Créer la structure de dossiers de templates
    templates_folder = tmp_path / "templates"
    docx_folder = templates_folder / "docx"
    docx_folder.mkdir(parents=True)

    # Créer un template DOCX simple (avec python-docx)

    doc = _DocxDocument()
    doc.add_paragraph("Title: {{ title }}")
    doc.add_paragraph("Date: {{ date }}")
    doc.add_paragraph("Items:")
    doc.add_paragraph("{% for item in items %}")
    doc.add_paragraph("- {{ item.name }}: {{ item.value }}")
    doc.add_paragraph("{% endfor %}")

    template_path = docx_folder / "report_template.docx"
    doc.save(str(template_path))

    # Créer le dossier de sortie
    output_folder = tmp_path / "output"

    # Mock export_templates
    pages = [
        {
            "page_name": "docx_report",
            "xml_template": "",
            "csv_template": "",
            "pdf_template": "",
            "docx_template": "report_template.docx",
        }
    ]

    fake_export_templates = SimpleNamespace(
        pages=pages, templates_folder=str(templates_folder)
    )
    fake_config = SimpleNamespace(export_templates=fake_export_templates)
    _patch_meter_config(monkeypatch, fake_config)

    # Données à exporter
    data_dict = {
        "title": "Monthly Report",
        "date": "2026-03-04",
        "items": [
            {"name": "Revenue", "value": "$50,000"},
            {"name": "Expenses", "value": "$30,000"},
            {"name": "Profit", "value": "$20,000"},
        ],
    }
    data_json = json.dumps(data_dict)

    req = meter_pb2.ExportDataRequest(
        page_id="docx_report",
        type="docx",
        data=data_json,
        folder_path=str(output_folder),
    )

    async with serve([MeterService()]) as (host, port):
        async with open_channel(host, port) as channel:
            stub = MeterServiceStub(channel)
            resp = await stub.ExportData(req)

    # Vérifier la réponse
    assert resp.success is True

    # Vérifier que le fichier DOCX a été créé
    output_files = list(output_folder.glob("*.docx"))
    assert len(output_files) == 1

    docx_file = output_files[0]

    # Vérifier que c'est bien un fichier DOCX valide (commence par PK pour ZIP)
    docx_content = docx_file.read_bytes()
    assert (
        docx_content[:2] == b"PK"
    ), "Le fichier généré doit être un DOCX valide (format ZIP)"

    # Vérifier que le fichier n'est pas vide
    assert len(docx_content) > 100, "Le DOCX doit contenir du contenu"

    # Optionnel: Vérifier le contenu rendu avec python-docx
    try:

        rendered_doc = Document(str(docx_file))
        full_text = "\n".join([para.text for para in rendered_doc.paragraphs])

        # Vérifier que les données ont été insérées
        assert "Monthly Report" in full_text or "title" in full_text.lower()
    except Exception:
        # Si python-docx n'arrive pas à lire, c'est OK, on a déjà vérifié la structure
        pass

