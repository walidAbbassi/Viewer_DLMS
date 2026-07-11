"""
ExportHandler — ExportData, DlmsTranslate.
SRP : export de données (PDF/DOCX/XML/CSV) et traduction DLMS binaire → XML.
"""
import base64 as _base64
import io
import json
import os
import sys
import shutil
import tempfile
from datetime import datetime
from pathlib import Path
from xml.etree.ElementTree import tostring
import xml.etree.ElementTree as ET

from docxtpl import DocxTemplate
from docx.shared import Inches
from jinja2 import Environment, FileSystemLoader, TemplateNotFound
import pdfkit

from gen import meter_pb2
from meter_context import MeterContext
from service.handlers.base_handler import BaseHandler
from translator.dlms_translator import DLMSTranslator
from util.grpc_exception import grpc_exception_handler


class ExportHandler(BaseHandler):
    """Gère ExportData et DlmsTranslate."""

    @grpc_exception_handler
    async def ExportData(self, stream):
        request = await stream.recv_message()

        pages = MeterContext.configuration.export_templates.pages
        template_filename = None
        for page in pages:
            if page.get("page_name") == request.page_id:
                template_key = f"{request.type}_template"
                template_filename = page.get(template_key)
                break

        if not template_filename:
            fallback_ext = ".html" if request.type == "pdf" else f".{request.type}"
            template_filename = f"{request.page_type}{fallback_ext}"

        try:
            data_dict = json.loads(request.data)
        except json.JSONDecodeError as e:
            raise Exception(f"Invalid JSON data: {str(e)}")

        output_folder = Path(request.folder_path)
        output_folder.mkdir(parents=True, exist_ok=True)

        extension_map = {"xml": ".xml", "csv": ".csv", "pdf": ".pdf", "docx": ".docx", "html": ".html", "txt": ".txt"}
        extension = extension_map.get(request.type, f".{request.type}")
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        suffix = getattr(request, "file_name_suffix", "")
        output_filename = f"{request.page_id}_{suffix}_{timestamp}{extension}" if suffix else f"{request.page_id}_{timestamp}{extension}"
        output_path = output_folder / output_filename

        templates_folder = Path(MeterContext.configuration.export_templates.templates_folder)
        if not templates_folder.is_absolute():
            templates_folder = Path(os.path.abspath(templates_folder))
        template_type_folder = templates_folder / request.type

        if request.type == "docx":
            template_path = template_type_folder / template_filename
            if not template_path.exists():
                raise Exception(f"DOCX template file not found: {template_path}")
            doc = DocxTemplate(str(template_path.absolute()))
            doc.render(data_dict)
            chart_b64 = data_dict.get("chart_image_base64")
            if chart_b64:
                try:
                    img_bytes = _base64.b64decode(chart_b64)
                    doc.docx.add_page_break()
                    doc.docx.add_heading("Chart", level=2)
                    doc.docx.add_picture(io.BytesIO(img_bytes), width=Inches(6))
                except Exception as _chart_err:
                    print(f"[ExportData] Could not embed chart in DOCX: {_chart_err}")
            doc.save(str(output_path))

        elif request.type == "pdf":
            if not template_type_folder.exists():
                raise Exception(f"Template folder not found: {template_type_folder}")
            env = Environment(loader=FileSystemLoader(str(template_type_folder)))
            try:
                template = env.get_template(template_filename)
            except TemplateNotFound:
                raise Exception(f"Template file not found: {template_filename} in {template_type_folder}")

            temp_dir = None
            chart_b64 = data_dict.get("chart_image_base64")
            if chart_b64:
                try:
                    temp_dir = Path(tempfile.mkdtemp(prefix="viewer_pdf_"))
                    chart_path = temp_dir / "chart.png"
                    chart_path.write_bytes(_base64.b64decode(chart_b64))
                    data_dict["chart_image_src"] = "chart.png"
                except Exception as _chart_err:
                    temp_dir = None

            rendered_content = template.render(**data_dict)

            if getattr(sys, "frozen", False):
                base_path = sys._MEIPASS
            else:
                base_path = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            wkhtmltopdf_path = os.path.join(base_path, "wkhtmltox", "bin", "wkhtmltopdf.exe")
            config = pdfkit.configuration(wkhtmltopdf=wkhtmltopdf_path)
            options = {"encoding": "UTF-8", "enable-local-file-access": None}

            if temp_dir is not None:
                html_temp = temp_dir / "report.html"
                try:
                    html_temp.write_text(rendered_content, encoding="utf-8")
                    pdfkit.from_file(str(html_temp), str(output_path), configuration=config, options=options)
                finally:
                    shutil.rmtree(temp_dir, ignore_errors=True)
            else:
                pdfkit.from_string(rendered_content, str(output_path), configuration=config, options=options)

        else:
            if not template_type_folder.exists():
                raise Exception(f"Template folder not found: {template_type_folder}")
            env = Environment(loader=FileSystemLoader(str(template_type_folder)))
            try:
                template = env.get_template(template_filename)
            except TemplateNotFound:
                raise Exception(f"Template file not found: {template_filename} in {template_type_folder}")
            output_path.write_text(template.render(**data_dict), encoding="utf-8")

        await stream.send_message(meter_pb2.ExportDataResponse(success=True))

    @grpc_exception_handler
    async def DlmsTranslate(self, stream):
        request = await stream.recv_message()
        translator = DLMSTranslator()
        data = bytes.fromhex(request.data) if not request.isxml else request.data
        xml_element = translator.translate(data)
        ET.indent(xml_element, space="  ")
        xml_string = tostring(xml_element, encoding="unicode")
        await stream.send_message(meter_pb2.StringValue(value=xml_string))

