from __future__ import annotations
from util.constants import LICENSE_FOLDER


def test_license_folder_constant_is_relative_path():
    # Contrat: chemin relatif sous configuration/, avec séparateurs Windows comme dans le code.
    assert LICENSE_FOLDER
    assert LICENSE_FOLDER.startswith("configuration")
    assert "license" in LICENSE_FOLDER.lower()
