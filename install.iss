#define ApplicationName 'MC-DPM'
#define ExeName ApplicationName + '.exe'
#define ExeFile './dist/main.dist/' + ExeName
#define ApplicationVersion GetVersionNumbersString(ExeFile)
#define GroupName 'CNSCAN'

[Setup]
AppName={#ApplicationName}
DefaultGroupName={#GroupName}
AppVersion={#ApplicationVersion}
WizardStyle=modern
DefaultDirName={autopf}\{#ApplicationName}
UninstallDisplayIcon={app}\{#ExeName}
Compression=lzma2
SolidCompression=yes
SourceDir=./dist/main.dist
OutputDir=../../dist
OutputBaseFilename={#ApplicationName}_setup-v{#ApplicationVersion}
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: zh; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Files]
Source: "*"; DestDir: "{app}"; Flags: recursesubdirs
Source: "../../driver/*"; DestDir: "{tmp}"; Flags: recursesubdirs

[Run]
Filename: "{app}\driver\DPInst64.exe"; Flags: waituntilterminated  
//Filename: "{app}\{#ExeName}"; Description: "{cm:LaunchProgram,My Application}"; Flags: nowait postinstall skipifsilent

[Icons]
Name: "{group}\{#ApplicationName}"; Filename: "{app}\{#ExeName}"
Name: "{commondesktop}\{#ApplicationName}"; Filename: "{app}\{#ExeName}"
