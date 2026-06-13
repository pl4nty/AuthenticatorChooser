; Inno Setup script for AuthenticatorChooser, compiled in CI.
; ISCC is invoked with /DArch=win-x64|win-arm64, /DSourceExe=<absolute path to signed exe> and /DAppVersion=<version>.

#define AppName "AuthenticatorChooser"
#define AppExeName "AuthenticatorChooser.exe"
#define AppPublisher "Ben Hutchison"

#if Arch == "win-arm64"
  #define ArchId "arm64"
  #define RuntimeArch "arm64"
#else
  #define ArchId "x64compatible"
  #define RuntimeArch "x64"
#endif

[Setup]
AppId={{ce8383a4-bdac-4d97-b0a6-8fc582b4c102}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed={#ArchId}
ArchitecturesInstallIn64BitMode={#ArchId}
UninstallDisplayIcon={app}\{#AppExeName}
; Emit the installer into the publish folder so it's uploaded alongside the main binary.
OutputDir=bin\Release\net8.0-windows\{#Arch}\publish
OutputBaseFilename={#AppName}-{#AppVersion}-{#Arch}-Setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "{#SourceExe}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{userstartup}\{#AppName}"; Filename: "{app}\{#AppExeName}"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Start {#AppName} now"; Flags: nowait runascurrentuser

[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/im {#AppExeName} /f"; Flags: runhidden; RunOnceId: "StopApp"

[Code]
function IsDotNet8DesktopInstalled: Boolean;
var
  FindRec: TFindRec;
begin
  Result := False;
  if FindFirst(ExpandConstant('{commonpf}\dotnet\shared\Microsoft.WindowsDesktop.App\8.*'), FindRec) then
  try
    repeat
      if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
        Result := True;
    until Result or not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  Installer: String;
  ResultCode: Integer;
begin
  Result := '';
  if IsDotNet8DesktopInstalled then
    Exit;

  Installer := ExpandConstant('{tmp}\windowsdesktop-runtime-8.exe');
  try
    DownloadTemporaryFile('https://aka.ms/dotnet/8.0/windowsdesktop-runtime-{#RuntimeArch}.exe', 'windowsdesktop-runtime-8.exe', '', nil);
  except
    Result := 'Could not download the .NET Desktop Runtime 8: ' + GetExceptionMessage;
    Exit;
  end;

  if not Exec(Installer, '/install /quiet /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    Result := 'Could not run the .NET Desktop Runtime 8 installer.'
  else if ResultCode = 3010 then
    NeedsRestart := True
  else if ResultCode <> 0 then
    Result := Format('The .NET Desktop Runtime 8 installer failed with exit code %d.', [ResultCode]);
end;
