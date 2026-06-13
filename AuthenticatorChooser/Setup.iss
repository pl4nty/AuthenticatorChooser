; Inno Setup script for AuthenticatorChooser, compiled in CI.
; ISCC is invoked with /DArch=win-x64|win-arm64, /DSourceExe=<absolute path to signed exe> and /DAppVersion=<version>.

#define AppName "AuthenticatorChooser"
#define AppExeName "AuthenticatorChooser.exe"
#define AppPublisher "Ben Hutchison"

#if Arch == "win-arm64"
  #define ArchId "arm64"
#else
  #define ArchId "x64compatible"
#endif

[Setup]
AppId={{ce8383a4-bdac-4d97-b0a6-8fc582b4c102}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
; Program Files is a "secure location", which (together with the Authenticode signature) is required for Windows to
; grant the uiAccess privilege declared in app.manifest, so installing here is what lets the app run without admin.
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed={#ArchId}
ArchitecturesInstallIn64BitMode={#ArchId}
UninstallDisplayIcon={app}\{#AppExeName}
OutputDir=bin\installer
OutputBaseFilename={#AppName}-{#AppVersion}-{#Arch}-Setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "{#SourceExe}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Start on logon via a Startup shortcut (the simpler alternative to a scheduled task). No elevation: Explorer launches
; the signed exe from Program Files and the OS grants uiAccess automatically.
Name: "{userstartup}\{#AppName}"; Filename: "{app}\{#AppExeName}"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Start {#AppName} now"; Flags: nowait runascurrentuser

[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/im {#AppExeName} /f"; Flags: runhidden; RunOnceId: "StopApp"
