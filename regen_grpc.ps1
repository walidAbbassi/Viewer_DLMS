<#
.SYNOPSIS
    Regenerate gRPC stubs (Python + Dart) from protos/meter.proto
    Works on any dev machine regardless of tool installation paths.

.DESCRIPTION
    Proxy autodetect (3 levels, no param needed on corp network):
      1. $ENV:HTTP_PROXY / $ENV:HTTPS_PROXY already set in session
      2. Windows Internet Settings (HKCU registry - used by IE/Edge/Chrome)
      3. WinHTTP system proxy (netsh winhttp)
    If none found: direct connection (no proxy).

.PARAMETER Proxy
    Optional. Override proxy manually: -Proxy "http://host:port"
    Use -Proxy "none" to force no proxy even if one is detected.

.EXAMPLE
    # Auto-detect proxy (standard on corp PCs)
    .\regen_grpc.ps1

    # Override proxy manually
    .\regen_grpc.ps1 -Proxy "http://10.207.14.250:8080"

    # Force no proxy
    .\regen_grpc.ps1 -Proxy "none"
#>
param([string]$Proxy = "")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ROOT = $PSScriptRoot

# --- Proto discovery ----------------------------------------------------------
$protoDir   = Join-Path $ROOT "protos"
$protoNames = Get-ChildItem $protoDir -Filter *.proto | ForEach-Object { $_.BaseName }
# grpcio stubs (*_pb2_grpc.py) are kept only for services covered by smoke tests
$grpcioServices = @("meter", "authentication")

function Write-Step { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-OK   { param($msg) Write-Host "  OK  $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "  ERR $msg" -ForegroundColor Red; exit 1 }
function Write-Info { param($msg) Write-Host "  ... $msg" -ForegroundColor Gray }

# --- Proxy auto-detection -----------------------------------------------------
function Get-SystemProxy {
    # 1. Already set in environment
    if ($ENV:HTTP_PROXY)  { return $ENV:HTTP_PROXY }
    if ($ENV:HTTPS_PROXY) { return $ENV:HTTPS_PROXY }

    # 2. Windows Internet Settings registry
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        $settings = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
        if ($settings.ProxyEnable -eq 1 -and $settings.ProxyServer) {
            $srv = $settings.ProxyServer
            # ProxyServer can be "host:port" or "http=host:port;https=host:port"
            if ($srv -match "^http=([^;]+)") { $srv = $Matches[1] }
            if ($srv -notmatch "^https?://")  { $srv = "http://$srv" }
            return $srv
        }
    } catch {}

    # 3. WinHTTP proxy
    try {
        $winhttpOut = netsh winhttp show proxy 2>$null | Out-String
        if ($winhttpOut -match "Proxy Server\(s\)\s*:\s*(.+)") {
            $srv = $Matches[1].Trim()
            if ($srv -and $srv -ne "Direct access (no proxy server).") {
                if ($srv -notmatch "^https?://") { $srv = "http://$srv" }
                return $srv
            }
        }
    } catch {}

    return $null
}

if ($Proxy) {
    Write-Info "Proxy (manual): $Proxy"
} else {
    $detected = Get-SystemProxy
    if ($detected) {
        $Proxy = $detected
        Write-Info "Proxy (auto-detected): $Proxy"
    } else {
        Write-Info "No proxy detected - direct connection"
    }
}

if ($Proxy) {
    $ENV:HTTP_PROXY  = $Proxy
    $ENV:HTTPS_PROXY = $Proxy
    $ENV:NO_PROXY    = "localhost,127.0.0.1"
}

Write-Step "Locating protoc..."
$protocExe = $null
$inPath = Get-Command protoc -ErrorAction SilentlyContinue
if ($inPath) {
    $protocExe = $inPath.Source
    Write-OK "Found in PATH: $protocExe"
} else {
    $candidates = @(
        "C:\protoc\protoc\bin\protoc.exe",
        "C:\tools\protoc\bin\protoc.exe",
        "$ENV:LOCALAPPDATA\protoc\bin\protoc.exe",
        "$ENV:ProgramFiles\protoc\bin\protoc.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $protocExe = $c; break }
    }
    if (-not $protocExe) {
        $found = Get-ChildItem "C:\protoc" -Recurse -Filter "protoc.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $protocExe = $found.FullName }
    }
    if (-not $protocExe) { Write-Fail "protoc.exe not found. Get it from https://github.com/protocolbuffers/protobuf/releases" }
    Write-OK "Found: $protocExe"
}
$protocBin     = Split-Path $protocExe
$protocRoot    = Split-Path $protocBin
$protocInclude = Join-Path $protocRoot "include"
if (-not (Test-Path $protocInclude)) { $protocInclude = $null }

Write-Step "Locating protoc-gen-dart..."
$pubBin  = "$ENV:LOCALAPPDATA\Pub\Cache\bin"
$ENV:PATH = "$ENV:PATH;$pubBin;$protocBin"
# Pin the Dart plugin so generated output is reproducible across dev machines.
# 25.0.0 = version that produced the currently-committed *.pb.dart stubs.
$dartPluginVersion = "25.0.0"
Write-Info "Activating protoc_plugin $dartPluginVersion via dart pub global..."
dart pub global activate protoc_plugin $dartPluginVersion
if ($LASTEXITCODE -ne 0) { Write-Fail "dart pub global activate protoc_plugin $dartPluginVersion failed" }
if (-not (Get-Command protoc-gen-dart -ErrorAction SilentlyContinue)) {
    Write-Fail "protoc-gen-dart not on PATH after activate (check $pubBin)"
}
Write-OK "protoc-gen-dart $dartPluginVersion ready"

Write-Step "Regenerating Python stubs..."
Push-Location (Join-Path $ROOT "backend")
try {
    # grpclib service stubs (*_grpc.py) + messages (*_pb2.py) for every proto
    foreach ($p in $protoNames) {
        python -m grpc_tools.protoc -I../protos --python_out=gen --grpclib_python_out=gen "../protos/$p.proto"
        if ($LASTEXITCODE -ne 0) { Write-Fail "grpclib gen failed: $p" }
    }
    # grpcio stubs (*_pb2_grpc.py) only for services covered by smoke tests
    foreach ($p in $grpcioServices) {
        python -m grpc_tools.protoc -I../protos --python_out=gen --grpc_python_out=gen "../protos/$p.proto"
        if ($LASTEXITCODE -ne 0) { Write-Fail "grpcio gen failed: $p" }
    }
    # Patch grpclib files only: bare `import <name>_pb2` -> `from gen import <name>_pb2`.
    # grpcio *_pb2_grpc.py must stay flat (smoke tests inject gen/ on sys.path).
    Get-ChildItem gen -Filter *_grpc.py |
        Where-Object { $_.Name -notlike "*_pb2_grpc.py" } |
        ForEach-Object {
            (Get-Content $_.FullName) `
                -replace '^import (\w+_pb2)$', 'from gen import $1' |
                Set-Content $_.FullName
        }
    Write-OK "Python stubs generated for $($protoNames.Count) proto(s); grpclib imports patched"
} finally { Pop-Location }

Write-Step "Regenerating Dart stubs..."
Push-Location $ROOT
try {
    foreach ($p in $protoNames) {
        $dargs = @("-I=protos", "--dart_out=grpc:flutter_app/lib/grpc/generated", "protos/$p.proto")
        if ($protocInclude) { $dargs = @("-I=$protocInclude") + $dargs }
        & $protocExe @dargs
        if ($LASTEXITCODE -ne 0) { Write-Fail "dart gen failed: $p" }
    }
    Write-OK "Dart stubs generated for $($protoNames.Count) proto(s)"
} finally { Pop-Location }

Write-Host ""
Write-Host "=== gRPC stubs regenerated (all protos) ===" -ForegroundColor Green
Write-Host "  Protos : $($protoNames -join ', ')" -ForegroundColor Green
Write-Host "  Python : backend/gen/*_grpc.py + *_pb2.py (grpclib); *_pb2_grpc.py for: $($grpcioServices -join ', ')" -ForegroundColor Green
Write-Host "  Dart   : flutter_app/lib/grpc/generated/*.pb*.dart" -ForegroundColor Green
