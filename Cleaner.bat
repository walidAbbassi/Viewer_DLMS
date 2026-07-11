
@rem Recursively searches and deletes all __pycache__ folders from the script's directory.
@echo off
setlocal enabledelayedexpansion
:: Get the folder where the script is located
set "ROOT_FOLDER=%~dp0"

echo Searching for __pycache__ folders in %ROOT_FOLDER%...

:: Loop through all __pycache__ folders and delete them
for /d /r "%ROOT_FOLDER%" %%d in (__pycache__) do (
    echo Deleting: %%d
    rmdir /s /q "%%d"
)

echo Done.
pause