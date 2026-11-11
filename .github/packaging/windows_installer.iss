; Inno Setup installer script for Lumi (Windows x64)
; Invoked automatically by .github/workflows/release.yml or manually via ISCC.exe:
;   ISCC.exe /DAppVersion=1.0.0 /DNumericVersion=1.0.0.1 /DBuildDir=..\..\build\windows\x64\runner\Release /DOutputDir=..\..\dist windows_installer.iss

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#ifndef NumericVersion
  #define NumericVersion "1.0.0.1"
#endif

#ifndef BuildDir
  #define BuildDir "..\..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

[Setup]
AppId={{B6F84C52-91D4-4F08-A237-7E52E91C1044}
AppName=Lumi
AppVersion={#AppVersion}
AppVerName=Lumi {#AppVersion}
AppPublisher=Vipura Devnak
AppPublisherURL=https://github.com/Vipura/Lumi
AppSupportURL=https://github.com/Vipura/Lumi/issues
VersionInfoVersion={#NumericVersion}
DefaultDirName={autopf}\Lumi
DefaultGroupName=Lumi
AllowNoIcons=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\lumi.exe
OutputDir={#OutputDir}
OutputBaseFilename=Lumi-{#AppVersion}-windows-x64-setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Lumi"; Filename: "{app}\lumi.exe"
Name: "{group}\Uninstall Lumi"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Lumi"; Filename: "{app}\lumi.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\lumi.exe"; Description: "{cm:LaunchProgram,Lumi}"; Flags: nowait postinstall skipifsilent

