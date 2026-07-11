from lxml import etree

def validate_xml_with_xsd(xml_string: str, xsd: bytes):
    try:
        # Parse XML string
        xml_doc = etree.fromstring(xml_string.encode())

        # Load and parse XSD file

        xsd_doc = etree.XML(xsd)
        schema = etree.XMLSchema(xsd_doc)

        # Validate
        if schema.validate(xml_doc):
            return True, "XML is valid"
        else:
            errors = []
            for error in schema.error_log:
                errors.append(f"Line {error.line}: {error.message}")
            return False, "XML is NOT valid\n" + "\n".join(errors)

    except etree.XMLSyntaxError as e:
        return False, f"XML Syntax Error: {e}"

    except OSError as e:
        return False, f"XSD File Error: {e}"
