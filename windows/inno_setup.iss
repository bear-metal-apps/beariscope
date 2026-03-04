#define MyAppName "Beariscope"
#define MyAppPublisher "Bear Metal (frc2046)"
#define MyAppURL "scout.bearmet.al"
#define MyAppExeName "beariscope.exe"

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

[Setup]
AppId={{E71D4BAE-9CAD-4723-87C2-CCF854B68176}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
OutputDir=..\build\inno_setup
OutputBaseFilename=beariscope-installer
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\windows\redist\VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "..\windows\redist\VC_redist.x86.exe"; DestDir: "{tmp}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; Check: NeedsVC2015x64; StatusMsg: "Installing Visual C++ 2015-2022 x64..."
Filename: "{tmp}\VC_redist.x86.exe"; Parameters: "/install /quiet /norestart"; Check: NeedsVC2015x86; StatusMsg: "Installing Visual C++ 2015-2022 x86..."
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Checks if Visual C++ 2015-2022 x64 redistributable is installed
function NeedsVC2015x64(): Boolean;
begin
  Result := not RegKeyExists(HKLM, 'Software\Classes\Installer\Dependencies\{d992c12e-cab2-426f-bde3-fb8c53950b0d}');
end;

// Checks if Visual C++ 2015–2022 x86 redistributable is installed
function NeedsVC2015x86(): Boolean;
begin
  Result := not RegKeyExists(HKLM, 'Software\Classes\Installer\Dependencies\{9e6f43f2-e9f2-4f0e-a46e-160be1b9f0b4}');
end;
