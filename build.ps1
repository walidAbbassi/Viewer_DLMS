$ErrorActionPreference = 'Stop'

Write-Host '============================'
Write-Host '   STARTING BUILD PROCESS   '
Write-Host '============================'

# Paths
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildFolder     = Join-Path $root 'build'
$backendFolder   = Join-Path $root 'backend'
$flutterFolder   = Join-Path $root 'flutter_app'
$wkhtmlFolder    = Join-Path $root 'wkhtmltox'
$templatesFolder = Join-Path $root 'templates'
$configFolder    = Join-Path $backendFolder 'configuration'

# ------------------------------
# CLEAN + CREATE BUILD FOLDER
# ------------------------------
Write-Host ''
Write-Host '[1/11] Cleaning build folder...'

if (Test-Path $buildFolder) {
    Remove-Item $buildFolder -Force -Recurse
}

New-Item -ItemType Directory -Path $buildFolder | Out-Null
Write-Host '✔ Build folder ready.'


# ------------------------------
# BACKEND BUILD
# ------------------------------
Write-Host ''
Write-Host '[2/11] Building backend with PyInstaller...'

Set-Location $backendFolder


# ACTIVATE PYTHON .venv
Write-Host '[X] Activating Python virtual environment...'

$venvActivate = Join-Path $backendFolder '.venv\Scripts\Activate.ps1'

if (Test-Path $venvActivate) {
    & $venvActivate
    Write-Host '✔ .venv activated.'
} else {
    Write-Host '❌ ERROR: .venv not found. Expected at backend/.venv'
    exit 1
}

# RUN PYINSTALLER USING THE VENV PYTHON
Write-Host 'Running PyInstaller inside the virtual environment...'


pyinstaller --onedir --noconsole --noconfirm `
    --paths '.venv\Lib\site-packages' `
    --collect-submodules ng_sdk `
    --collect-all numpy `
    --add-data '.venv\Lib\site-packages\ng_sdk\mapper\security_config_map.json5;ng_sdk/mapper' `
    server.py

Write-Host '✔ Backend build complete.'


# ------------------------------
# COPY BACKEND DIST → BUILD
# ------------------------------
Write-Host ''
Write-Host '[3/11] Copying backend output...'

$backendDist = Join-Path $backendFolder 'dist\server'
Copy-Item "$backendDist\*" $buildFolder -Recurse -Force

Write-Host '✔ Backend files copied.'


# Rename backend EXE
$serverExe = Join-Path $buildFolder 'server.exe'
if (Test-Path $serverExe) {
    Rename-Item -Path $serverExe -NewName 'py_grpc_server.exe' -Force
    Write-Host '✔ server.exe renamed to py_grpc_server.exe'
} else {
    Write-Host '⚠ WARNING: server.exe not found after backend copy.'
}


# ------------------------------
# SET PROXY FOR FLUTTER BUILD
# ------------------------------
Write-Host ''
Write-Host '[4/11] Setting HTTP/HTTPS proxy for Flutter build...'

$env:HTTP_PROXY  = 'http://10.207.14.250:8080'
$env:HTTPS_PROXY = 'http://10.207.14.250:8080'

Write-Host '✔ Proxy applied.'


# ------------------------------
# FLUTTER WINDOWS BUILD
# ------------------------------

$releaseFolder = Join-Path $flutterFolder 'build\windows\x64\runner\Release'

if (Test-Path $releaseFolder) {
    Remove-Item $releaseFolder -Recurse -Force
    Write-Host '✔ Release folder removed.'
} else {
    Write-Host '⚠ Release folder not found (already removed or not generated).'
}

Write-Host ''
Write-Host '[5/11] Building Flutter Windows app...'

Set-Location $flutterFolder
flutter build windows --release

Write-Host '✔ Flutter build complete.'


# ------------------------------
# REMOVE PROXY AFTER BUILD
# ------------------------------
Write-Host ''
Write-Host '[6/11] Removing HTTP/HTTPS proxy...'

Remove-Item Env:\HTTP_PROXY  -ErrorAction SilentlyContinue
Remove-Item Env:\HTTPS_PROXY -ErrorAction SilentlyContinue

Write-Host '✔ Proxy removed.'


# ------------------------------
# COPY FLUTTER RUNNER → BUILD
# ------------------------------
Write-Host ''
Write-Host '[7/11] Copying Flutter runner files...'

$flutterRunner = Join-Path $flutterFolder 'build\windows\x64\runner\Release'
Copy-Item "$flutterRunner\*" $buildFolder -Recurse -Force

Write-Host '✔ Flutter files copied.'

# Rename Flutter EXE
$flutterExe = Join-Path $buildFolder 'flutter_python_grpc.exe'
if (Test-Path $flutterExe) {
    Rename-Item -Path $flutterExe -NewName 'Viewer_NG_DEER.exe' -Force
    Write-Host '✔ flutter_python_grpc.exe renamed to Viewer_NG_DEER.exe'
} else {
    Write-Host '⚠ WARNING: flutter_python_grpc.exe not found after Flutter copy.'
}


# ------------------------------
# COPY WKHTMLTOX + TEMPLATES + CONFIG
# ------------------------------
Write-Host ''
Write-Host '[8/11] Copying packages and configuration...'

Copy-Item $wkhtmlFolder $buildFolder -Recurse -Force
Copy-Item $templatesFolder $buildFolder -Recurse -Force
Copy-Item $configFolder $buildFolder -Recurse -Force

Write-Host '✔ Files copied.'


# ------------------------------
# CLEAN LICENSE + LOGS
# ------------------------------
Write-Host ''
Write-Host '[9/11] Cleaning license and logs folders...'

$licenseFolder = Join-Path $buildFolder 'configuration\license'
if (Test-Path $licenseFolder) {
    Remove-Item "$licenseFolder\*" -Force -Recurse
    Write-Host '✔ License folder cleaned.'
}


$logsFolder = Join-Path $buildFolder 'configuration\logger\logs'
if (Test-Path $logsFolder) {
    Remove-Item $logsFolder -Force -Recurse
    Write-Host '✔ Logger/logs folder removed.'
}


Write-Host ''
Write-Host '============================'
Write-Host '   BUILD PROCESS FINISHED   '
Write-Host '============================'
# ------------------------------
# MODIFY JSON: export_templates.json
# ------------------------------
Write-Host ''
Write-Host '[10/11] Updating export_templates.json...'

$jsonFile = Join-Path $buildFolder 'configuration\export_templates.json5'

if (Test-Path $jsonFile) {

    # Load JSON
    $jsonContent = Get-Content $jsonFile -Raw

    # Check & update field
    $jsonContent = $jsonContent -replace 'templates_folder\s*:\s*"\.\.\/templates"', 'templates_folder: "templates"'
    
    [regex]::Replace($jsonContent, '^\uFEFF', '')

    # Write back as UTF-8 **without BOM**
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($jsonFile, $jsonContent, $utf8NoBom)


    
    Write-Host '✔ export_templates.json5 successfully saved.'
}
else {
    Write-Host '❌ ERROR: export_templates.json5 not found.'
}
# ------------------------------
# CREATE INSTALLER WITH INNO SETUP
# ------------------------------
Write-Host ''
Write-Host '[11/11] Creating InnoSetup installer...'

# Return to root folder
Set-Location $root

# Copy setup.iss and app icon to build folder
$setupFile = Join-Path $root 'setup.iss'
if (Test-Path $setupFile) {
    Copy-Item $setupFile $buildFolder -Force
    Write-Host '✔ setup.iss copied to build folder.'
} else {
    Write-Host '❌ ERROR: setup.iss not found in project root.'
    exit 1
}

$iconSource = Join-Path $flutterFolder 'windows\runner\resources\app_icon.ico'
if (Test-Path $iconSource) {
    Copy-Item $iconSource $buildFolder -Force
    Write-Host '✔ app_icon.ico copied to build folder.'
} else {
    Write-Host '⚠ WARNING: app_icon.ico not found at:'
    Write-Host $iconSource
}

# Path to Inno Setup compiler
$innosetup = 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'

if (Test-Path $innosetup) {
    & $innosetup (Join-Path $buildFolder 'setup.iss')
    Write-Host '✔ InnoSetup installer created.'
} else {
    Write-Host '❌ ERROR: Inno Setup compiler not found at:'
    Write-Host $innosetup
    Write-Host 'Please install or update the compiler path.'
    exit 1
}
