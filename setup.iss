[Setup]
AppName=Viewer_NG_DEER
AppVersion=1.0.2
DefaultDirName={commonpf}\SAGEMCOM\Viewer_NG_DEER
DefaultGroupName=Viewer_NG_DEER
OutputBaseFilename=Viewer_NG_DEER_1.0.2
Compression=lzma
SolidCompression=yes
SetupIconFile=C:\Workspace_NG\Viewer_NG\flutter_app\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Viewer_NG_DEER.exe

[Dirs]
Name: "{app}\configuration"; Permissions: users-modify
[Dirs]
Name: "{app}\logs"; Permissions: users-modify

[Files]
; === Flutter app ===
Source: "Viewer_NG_DEER.exe"; DestDir: "{app}"; Flags: ignoreversion

; === gRPC server ===
Source: "py_grpc_server.exe"; DestDir: "{app}"; Flags: ignoreversion

; === DLLs ===
Source: "*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

; === JSON config files (installed under config\) ===
Source: "data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; === JSON config files (installed under config\) ===
Source: "configuration\*"; DestDir: "{app}\configuration"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Internal Python runtime ===
Source: "_internal\*"; DestDir: "{app}\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Templates ===
Source: "templates\*"; DestDir: "{app}\templates"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Pdf converter ===
Source: "wkhtmltox\*"; DestDir: "{app}\_internal\wkhtmltox"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Desktop shortcut
Name: "{userdesktop}\Viewer_NG_DEER_1.0.2"; Filename: "{app}\Viewer_NG_DEER.exe"; IconFilename: "{app}\Viewer_NG_DEER.exe"

; Start menu shortcut
Name: "{group}\Viewer_NG_DEER_1.0.2"; Filename: "{app}\Viewer_NG_DEER.exe"; IconFilename: "{app}\Viewer_NG_DEER.exe"

[Run]
; Launch main app after install
Filename: "{app}\Viewer_NG_DEER.exe"; Description: "Launch Viewer_NG_DEER"; Flags: nowait postinstall skipifsilent
