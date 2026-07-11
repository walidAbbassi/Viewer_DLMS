from pathlib import Path

from ng_sdk.configuration.config_mapper import load_enum_class

from gen import configuration_grpc, configuration_pb2
from meter_context import MeterContext
from utils_any import python_to_any, any_to_python


class ConfigurationService(configuration_grpc.ConfigServiceBase):
    async def SetConfig(self, stream):
        request = await stream.recv_message()
        index = 0
        for entry in request.entries:
            python_value = any_to_python(entry.value)
            if (
                entry.key in MeterContext.configuration.config_rules
                and MeterContext.configuration.config_rules[entry.key].startswith(
                    "enum_"
                )
            ):
                enum_class = load_enum_class(
                    MeterContext.configuration.config_rules[entry.key].replace(
                        "enum_", ""
                    ),
                    entry.key,
                )
                if isinstance(python_value, str):
                    python_value = enum_class[python_value]
                else:
                    python_value = enum_class(python_value)

            MeterContext.configuration.association[entry.module].set(
                entry.key,
                python_value,
                request.to_file and index == len(request.entries) - 1,
            )
            index += 1
        await stream.send_message(
            configuration_pb2.SetConfigResponse(success=True, message="Config updated")
        )

    async def GetConfig(self, stream):
        configurations = []
        request = await stream.recv_message()
        for entry in request.identifiers:
            value = MeterContext.configuration.association[entry.module].get(
                entry.key, None
            )
            if value is not None:
                configurations.append(
                    configuration_pb2.ConfigEntry(
                        module=entry.module, key=entry.key, value=python_to_any(value)
                    )
                )
        await stream.send_message(
            configuration_pb2.GetConfigResponse(entries=configurations)
        )

    async def ListModules(self, stream):
        modules = MeterContext.configuration.association.files()
        await stream.send_message(
            configuration_pb2.ListModulesResponse(modules=modules)
        )

    async def SetExportTemplates(self, stream):
        request = await stream.recv_message()

        # Récupérer la liste des pages depuis MeterContext
        pages = MeterContext.configuration.export_templates.pages

        # Chercher si un objet avec le même page_name existe déjà
        existing_page = None
        for page in pages:
            if page.get("page_name") == request.page_name:
                existing_page = page
                break

        if existing_page:
            # Mettre à jour l'objet existant
            existing_page["xml_template"] = request.xml_template
            existing_page["csv_template"] = request.csv_template
            existing_page["pdf_template"] = request.pdf_template
            existing_page["docx_template"] = request.docx_template
        else:
            # Ajouter un nouvel objet
            pages.append(
                {
                    "page_name": request.page_name,
                    "xml_template": request.xml_template,
                    "csv_template": request.csv_template,
                    "pdf_template": request.pdf_template,
                    "docx_template": request.docx_template,
                }
            )
        MeterContext.configuration.export_templates.set("pages", pages, True)
        await stream.send_message(
            configuration_pb2.SetExportTemplatesResponse(success=True)
        )

    async def GetExportTemplates(self, stream):
        request = await stream.recv_message()

        # Récupérer la liste des pages depuis MeterContext
        pages = MeterContext.configuration.export_templates.pages

        # Chercher la page correspondante
        page_data = None
        for page in pages:
            if page.get("page_name") == request.page_name:
                page_data = page
                break

        # Construire la réponse avec les templates (chaînes vides si page non trouvée)
        response = configuration_pb2.GetExportTemplatesResponse(
            xml_template=page_data.get("xml_template", "") if page_data else "",
            csv_template=page_data.get("csv_template", "") if page_data else "",
            pdf_template=page_data.get("pdf_template", "") if page_data else "",
            docx_template=page_data.get("docx_template", "") if page_data else "",
        )

        await stream.send_message(response)

    async def ListExportTemplateFiles(self, stream):
        await stream.recv_message()
        templates_folder = Path(
            MeterContext.configuration.export_templates.templates_folder
        )

        entries = []

        # Parcourir les dossiers (types) dans templates_folder
        print(
            "templates_folder.exists()",
            templates_folder.exists(),
            "templates_folder.is_dir()",
            templates_folder.is_dir(),
        )
        if templates_folder.exists() and templates_folder.is_dir():
            for type_folder in templates_folder.iterdir():
                if type_folder.is_dir():
                    # Le nom du dossier correspond au type
                    folder_type = type_folder.name

                    # Lister les fichiers dans ce dossier
                    files = []
                    for file in type_folder.iterdir():
                        if file.is_file():
                            files.append(file.name)

                    # Créer l'entrée avec le type et la liste des fichiers
                    if files:  # N'ajouter que si des fichiers existent
                        entries.append(
                            configuration_pb2.ExportTemplateFileEntry(
                                type=folder_type, files=files
                            )
                        )

        await stream.send_message(
            configuration_pb2.ListExportTemplateFilesResponse(entries=entries)
        )
