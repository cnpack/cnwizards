{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizOptions;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards ���������൥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, ToolsAPI, IniFiles,
  FileCtrl, Forms, Registry{$IFDEF COMPILER6_UP}, SHFolder{$ENDIF};

type

//==============================================================================
// ר�ҹ���������
//==============================================================================

{ TCnWizOptions }

  TCnWizUpgradeStyle = (usDisabled, usAllUpgrade, usUserDefine);
  TCnWizUpgradeContent = set of (ucNewFeature, ucBigBugFixed);

  TCnWizOptions = class (TObject)
  {* ר�һ���������}
  private
    FDataPath: string;
    FDllName: string;
    FDllPath: string;
    FCompilerPath: string;
    FIconPath: string;
    FTemplatePath: string;
    FHelpPath: string;
    FLangPath: string;
    FRegBase: string;
    FRegPath: string;
    FUserPath: string;
    FPropEditorRegPath: string;
    FCompEditorRegPath: string;
    FCompilerRegPath: string;
    FIdeEhnRegPath: string;
    FShowHint: Boolean;
    FShowWizComment: Boolean;
    FDelphiExt: string;
    FCExt: string;
    FCompilerName: string;
    FCompilerID: string;
    FUpgradeReleaseOnly: Boolean;
    FUpgradeURL: string;
    FNightlyBuildURL: string;
    FUpgradeContent: TCnWizUpgradeContent;
    FUpgradeStyle: TCnWizUpgradeStyle;
    FUpgradeLastDate: TDateTime;
    FBuildDate: TDateTime;
    FCurrentLangID: Cardinal;
    FShowTipOfDay: Boolean;
    FUseToolsMenu: Boolean;
    FFixThreadLocale: Boolean;
    FCustomUserDir: string;
    FUseCustomUserDir: Boolean;
    FUseOneCPUCore: Boolean;
    procedure SetCurrentLangID(const Value: Cardinal);
    function GetUpgradeCheckDate: TDateTime;
    procedure SetUpgradeCheckDate(const Value: TDateTime);
    function GetUseToolsMenu: Boolean;
    procedure SetUseToolsMenu(const Value: Boolean);
    procedure SetFixThreadLocale(const Value: Boolean);
    function GetUpgradeCheckMonth: TDateTime;
    procedure SetUpgradeCheckMonth(const Value: TDateTime);
    procedure SetCustomUserDir(const Value: string);
    procedure SetUseCustomUserDir(const Value: Boolean);
    procedure SetUseOneCPUCore(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadSettings;
    procedure SaveSettings;

    // ������д����
    function CreateRegIniFile: TCustomIniFile; overload;
    {* ����һ��ר�Ұ���·���� INI ����}
    function CreateRegIniFile(const APath: string;
      CompilerSection: Boolean = False): TCustomIniFile; overload;
    {* ����һ��ָ��·���� INI ����CompilerSection ��ʾ�Ƿ�ʹ�ñ�������صĺ�׺}
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    {* ��ר�Ұ���·���� INI �����ж�ȡ Bool ֵ}
    function ReadInteger(const Section, Ident: string; Default: Integer): Integer;
    {* ��ר�Ұ���·���� INI �����ж�ȡ Integer ֵ}
    function ReadString(const Section, Ident: string; Default: string): string;
    {* ��ר�Ұ���·���� INI �����ж�ȡ String ֵ}
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    {* ��ר�Ұ���·���� INI ������д Bool ֵ}
    procedure WriteInteger(const Section, Ident: string; Value: Integer);
    {* ��ר�Ұ���·���� INI ������д Integer ֵ}
    procedure WriteString(const Section, Ident: string; Value: string);
    {* ��ר�Ұ���·���� INI ������д String ֵ}

    function IsDelphiSource(const FileName: string): Boolean;
    {* �ж�ָ���ļ��Ƿ� Delphi Դ�ļ���ʹ�����û����õ���չ���б��ж�}
    function IsCSource(const FileName: string): Boolean;
    {* �ж�ָ���ļ��Ƿ� C Դ�ļ���ʹ�����û����õ���չ���б��ж�}

    function GetUserFileName(const FileName: string; IsRead: Boolean; FileNameDef:
      string = ''): string;
    {* �����û������ļ�������� UserPath �µ��ļ������ڣ����� DataPath �е��ļ���}
    function CheckUserFile(const FileName: string; FileNameDef: string = ''):
      Boolean;
    {* ����û������ļ������ UserPath �µ��ļ��� DataPath �µ�һ�£�ɾ��
       UserPath �µ��ļ����Ա�֤ DataPath �µ��ļ�������ʹ��Ĭ�����õ�
       �û����Ի�ø��¡�������ļ�һ�£����� True}
    function LoadUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* װ���û��ļ����ַ����б� }
    function SaveUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* �����ַ����б��û��ļ� }
    procedure DoFixThreadLocale;

    // ר�� DLL ����
    property DllName: string read FDllName;
    {* ר�� DLL �ļ���}
    property DllPath: string read FDllPath;
    {* ר�� DLL ���ڵ�Ŀ¼}
    property CompilerPath: string read FCompilerPath;

    // ��ǰ���� ID
    property CurrentLangID: Cardinal read FCurrentLangID write SetCurrentLangID;

    // ר��ʹ�õ�Ŀ¼��
    property LangPath: string read FLangPath;
    {* �����Դ洢�ļ�Ŀ¼ }
    property IconPath: string read FIconPath;
    {* ͼ��Ŀ¼}
    property DataPath: string read FDataPath;
    {* ϵͳ����Ŀ¼�������ֻ���������ļ�������������ݻᱻ����}
    property TemplatePath: string read FTemplatePath;
    {* ֻ����ϵͳģ���ļ����Ŀ¼����������Ŀ¼֮�� }
    property UserPath: string read FUserPath;
    {* �û�����Ŀ¼��������б����û����ݺ����õ��ļ���ţ�����װʱ��ѡ��ɾ����Ŀ¼}
    property HelpPath: string read FHelpPath;
    {* �����ļ�Ŀ¼�����ר�Ұ������ļ�}

    // ע���·��
    property RegBase: string read FRegBase;
    {* CnPack ע����·��������ͨ�� -cnregXXXX ָ�� }
    property RegPath: string read FRegPath;
    {* ר�Ұ�ʹ�õ�ע���·��}
    property PropEditorRegPath: string read FPropEditorRegPath;
    {* ר�Ұ����Ա༭������ʹ�õ�ע���·��}
    property CompEditorRegPath: string read FCompEditorRegPath;
    {* ר�Ұ�����༭������ʹ�õ�ע���·��}
    property IdeEhnRegPath: string read FIdeEhnRegPath;
    {* ר�Ұ� IDE ��չ����ʹ�õ�ע���·��}

    // ��������ز���
    property CompilerName: string read FCompilerName;
    {* ���������ƣ��� Delphi 5}
    property CompilerID: string read FCompilerID;
    {* ��������д���� D5}
    property CompilerRegPath: string read FCompilerRegPath;
    {* ������ IDE ʹ�õ�ע���·��}

    // �û�����
    property DelphiExt: string read FDelphiExt write FDelphiExt;
    {* �û������ Delphi �ļ���չ��}
    property CExt: string read FCExt write FCExt;
    {* �û������ C �ļ���չ��}
    property ShowHint: Boolean read FShowHint write FShowHint;
    {* �Ƿ���ʾ�ؼ� Hint��������Ӧ�� Create ʱ���� TForm.ShowHint ���ڸ�ֵ}
    property ShowWizComment: Boolean read FShowWizComment write FShowWizComment;
    {* �Ƿ���ʾ������ʾ����}
    property ShowTipOfDay: Boolean read FShowTipOfDay write FShowTipOfDay;
    {* �Ƿ���ʾÿ��һ�� }

    // �����������
    property BuildDate: TDateTime read FBuildDate;
    {* ר�� Build ����}
    property UpgradeURL: string read FUpgradeURL;
    property NightlyBuildURL: string read FNightlyBuildURL;
    {* ר����������ַ}
    property UpgradeStyle: TCnWizUpgradeStyle read FUpgradeStyle write FUpgradeStyle;
    {* ר��������ⷽʽ}
    property UpgradeContent: TCnWizUpgradeContent read FUpgradeContent write FUpgradeContent;
    {* ר�������������}
    property UpgradeReleaseOnly: Boolean read FUpgradeReleaseOnly write FUpgradeReleaseOnly;
    {* �Ƿ�ֻ���ǵ��԰��ר������}
    property UpgradeLastDate: TDateTime read FUpgradeLastDate write FUpgradeLastDate;
    {* ���һ�μ�����������}
    property UpgradeCheckDate: TDateTime read GetUpgradeCheckDate write SetUpgradeCheckDate;
    property UpgradeCheckMonth: TDateTime read GetUpgradeCheckMonth write SetUpgradeCheckMonth;
    property UseToolsMenu: Boolean read GetUseToolsMenu write SetUseToolsMenu;
    {* ���˵��Ƿ񼯳ɵ� Tools �˵��� }
    property FixThreadLocale: Boolean read FFixThreadLocale write SetFixThreadLocale;
    {* ʹ�� SetThreadLocale ���� Vista / Win7 ��������������}
    property UseOneCPUCore: Boolean read FUseOneCPUCore write SetUseOneCPUCore;
    {* �ڶ�CPU��ֻʹ��һ��CPU�ںˣ��Խ������������}

    property UseCustomUserDir: Boolean read FUseCustomUserDir write SetUseCustomUserDir;
    property CustomUserDir: string read FCustomUserDir write SetCustomUserDir;
    {* Vista / Win7 ��ʹ��ָ���� User Ŀ¼������Ȩ������ }
  end;

var
  WizOptions: TCnWizOptions;
  {* ר�һ�����������}
  
implementation

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  CnWizUtils, CnWizConsts, CnCommon, CnWizManager, CnConsts, CnWizCompilerConst,
  CnNativeDecl;

//==============================================================================
// ר�ҹ���������
//==============================================================================

{ TCnWizOptions }

const
  csLangID = 'CurrentLangID';
  csShowHint = 'ShowHint';
  csShowWizComment = 'ShowWizComment';
  csShowTipOfDay = 'ShowTipOfDay';
  csDelphiExt = 'DelphiExt';
  csCExt = 'CExt';
  csUseToolsMenu = 'UseToolsMenu';
  csFixThreadLocale = 'FixThreadLocale';
  csUseOneCPUCore = 'UseOneCPUCore';
{$IFDEF BDS}
  csUseOneCPUDefault = False;
{$ELSE}
  csUseOneCPUDefault = False;
{$ENDIF}

  csDelphiExtDefault = '.pas;.dpr;.inc';
  csCExtDefault = '.c;.cpp;.h;.hpp;.cc;.hh';

  csUpgradeURL = 'URL';
  csNightlyBuildURL = 'URL';
  csUpgradeReleaseOnly = 'ReleaseOnly';
  csUpgradeStyle = 'UpgradeStyle';
  csNewFeature = 'NewFeature';
  csBigBugFixed = 'BigBugFixed';
  csUpgradeLastDate = 'LastDate';
  csUpgradeCheckDate = 'CheckDate';
  csUpgradeCheckMonth = 'CheckMonth';

  csUseCustomUserDir = 'UseCustomUserDir';
  csCustomUserDir = 'CustomUserDir';

{$IFNDEF COMPILER6_UP}
const
  SHFolderDll = 'SHFolder.dll';

  CSIDL_PERSONAL = $0005; { My Documents }
  CSIDL_FLAG_CREATE = $8000; { new for Win2K, or this in to force creation of folder }

function SHGetFolderPath(hwnd: HWND; csidl: Integer; hToken: THandle;
  dwFlags: DWord; pszPath: PAnsiChar): HRESULT; stdcall;
  external SHFolderDll name 'SHGetFolderPathA';
{$ENDIF}

constructor TCnWizOptions.Create;
begin
  inherited;
  LoadSettings;
end;

destructor TCnWizOptions.Destroy;
begin
  SaveSettings;
  inherited;
end;

procedure TCnWizOptions.LoadSettings;
const
  SCnSoftwareRegPath = '\Software\';
var
  ModuleName, SHUserDir: array[0..MAX_Path - 1] of Char;
  DefDir: string;
  Svcs: IOTAServices;
  i: Integer;
  s: string;
begin
  inherited;
  Svcs := BorlandIDEServices as IOTAServices;
  Assert(Assigned(Svcs));
  FCompilerRegPath := Svcs.GetBaseRegistryKey;
  GetModuleFileName(hInstance, ModuleName, MAX_PATH);
  FDllName := ModuleName;
  FDllPath := _CnExtractFilePath(FDllName);
  FCompilerPath := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));

  FLangPath := MakePath(FDllPath + SCnWizLangPath);
  FDataPath := MakePath(FDllPath + SCnWizDataPath);
  FTemplatePath := MakePath(FDllPath + SCnWizTemplatePath);
  FIconPath := MakePath(FDllPath + SCnWizIconPath);
  FHelpPath := MakePath(FDllPath + SCnWizHelpPath);

  FRegBase := SCnPackRegPath;
  for i := 1 to ParamCount do
  begin
    s := ParamStr(i);
    if (Length(s) > Length(SCnUserRegSwitch) + 1) and CharInSet(s[1], ['-', '/']) and
      SameText(Copy(s, 2, Length(SCnUserRegSwitch)), SCnUserRegSwitch) then
    begin
      FRegBase := MakePath(SCnSoftwareRegPath +
        Copy(s, Length(SCnUserRegSwitch) + 2, MaxInt));
      Break;
    end;
  end;
{$IFDEF Debug}
  CnDebugger.LogMsg('Registry Base Path: ' + FRegBase);
{$ENDIF Debug}
  FRegPath := MakePath(MakePath(FRegBase) + SCnWizardRegPath);
  FPropEditorRegPath := MakePath(MakePath(FRegBase) + SCnPropEditorRegPath);
  FCompEditorRegPath := MakePath(MakePath(FRegBase) + SCnCompEditorRegPath);
  FIdeEhnRegPath := MakePath(FRegPath + SCnIdeEnhancementsRegPath);
  FCompilerName := CnWizCompilerConst.CompilerName;
  FCompilerID := CompilerShortName;
  FBuildDate := CnStrToDate(SCnWizardBuildDate);
  
{$IFDEF Debug}
  CnDebugger.LogMsg('CompilerPath: ' + FCompilerPath);
  CnDebugger.LogMsg('CompilerRegPath: ' + FCompilerRegPath);
  CnDebugger.LogMsg('WizardDllName: ' + FDllName);
  CnDebugger.LogMsg('WizardRegPath: ' + FRegPath);
{$ENDIF Debug}

  with CreateRegIniFile do
  try
    FCurrentLangID := ReadInteger(SCnOptionSection, csLangID, GetSystemDefaultLCID);
    FShowHint := ReadBool(SCnOptionSection, csShowHint, True);
    FShowWizComment := ReadBool(SCnOptionSection, csShowWizComment, True);
    FShowTipOfDay := ReadBool(SCnOptionSection, csShowTipOfDay, True);
    FDelphiExt := ReadString(SCnOptionSection, csDelphiExt, csDelphiExtDefault);
    if FDelphiExt = '' then FDelphiExt := csDelphiExtDefault;
    FCExt := ReadString(SCnOptionSection, csCExt, csCExtDefault);
    if FCExt = '' then FCExt := csCExtDefault;
    FUseToolsMenu := ReadBool(SCnOptionSection, csUseToolsMenu, False);
    FixThreadLocale := ReadBool(SCnOptionSection, csFixThreadLocale, False);

    FUseCustomUserDir := ReadBool(SCnOptionSection, csUseCustomUserDir, CheckWinVista);
    SHGetFolderPath(0, CSIDL_PERSONAL or CSIDL_FLAG_CREATE, 0, 0, SHUserDir);
    DefDir := MakePath(SHUserDir) + SCnWizCustomUserPath;
    FCustomUserDir := ReadString(SCnOptionSection, csCustomUserDir, DefDir);
    if FUseCustomUserDir then // ʹ��ָ���û�Ŀ¼ʱ��Ҫ��֤��Ŀ¼��Ч
    begin
      if (FCustomUserDir <> '') and not DirectoryExists(FCustomUserDir) then
        CreateDirectory(PChar(FCustomUserDir), nil);
      if (FCustomUserDir = '') or not DirectoryExists(FCustomUserDir) then
        FCustomUserDir := DefDir;
    end;

    FUpgradeReleaseOnly := ReadBool(SCnUpgradeSection, csUpgradeReleaseOnly, True);
    FUpgradeContent := [];
    if ReadBool(SCnUpgradeSection, csNewFeature, True) then
      Include(FUpgradeContent, ucNewFeature);
    if ReadBool(SCnUpgradeSection, csBigBugFixed, True) then
      Include(FUpgradeContent, ucBigBugFixed);
    FUpgradeStyle := TCnWizUpgradeStyle(ReadInteger(SCnUpgradeSection,
      csUpgradeStyle, Ord(usAllUpgrade)));
    FUpgradeLastDate := ReadDate(SCnUpgradeSection, csUpgradeLastDate, 0);
  finally
    Free;
  end;

  with CreateRegIniFile(FRegPath, True) do
  try
    UseOneCPUCore := ReadBool(SCnOptionSection, csUseOneCPUCore, csUseOneCPUDefault);
  finally
    Free;
  end;

  if FUseCustomUserDir then
    FUserPath := MakePath(FCustomUserDir)
  else
    FUserPath := MakePath(FDllPath + SCnWizUserPath);
  CreateDirectory(PChar(FUserPath), nil);
{$IFDEF Debug}
  CnDebugger.LogMsg('User Path: ' + FUserPath);
{$ENDIF Debug}

  with TMemIniFile.Create(FDataPath + SCnWizUpgradeIniFile) do
  try
    FUpgradeURL := ReadString(SCnUpgradeSection, csUpgradeURL, SCnWizDefUpgradeURL);
    FNightlyBuildUrl := ReadString(SCnUpgradeSection, csNightlyBuildURL, SCnWizDefNightlyBuildUrl);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.SaveSettings;
begin
  with CreateRegIniFile do
  try
    WriteInteger(SCnOptionSection, csLangID, FCurrentLangID);
    WriteBool(SCnOptionSection, csShowHint, FShowHint);
    WriteBool(SCnOptionSection, csShowWizComment, FShowWizComment);
    WriteBool(SCnOptionSection, csShowTipOfDay, FShowTipOfDay);
    WriteString(SCnOptionSection, csDelphiExt, FDelphiExt);
    WriteString(SCnOptionSection, csCExt, FCExt);
    WriteBool(SCnOptionSection, csUseToolsMenu, FUseToolsMenu);
    WriteBool(SCnOptionSection, csFixThreadLocale, FFixThreadLocale);
    WriteBool(SCnOptionSection, csUseCustomUserDir, FUseCustomUserDir);
    WriteString(SCnOptionSection, csCustomUserDir, FCustomUserDir);

    WriteBool(SCnUpgradeSection, csUpgradeReleaseOnly, FUpgradeReleaseOnly);
    WriteBool(SCnUpgradeSection, csNewFeature, ucNewFeature in FUpgradeContent);
    WriteBool(SCnUpgradeSection, csBigBugFixed, ucBigBugFixed in FUpgradeContent);
    WriteInteger(SCnUpgradeSection, csUpgradeStyle, Ord(FUpgradeStyle));
    WriteDate(SCnUpgradeSection, csUpgradeLastDate, FUpgradeLastDate);
  finally
    Free;
  end;

  with CreateRegIniFile(FRegPath, True) do
  try
    if UseOneCPUCore = csUseOneCPUDefault then
      DeleteKey(SCnOptionSection, csUseOneCPUCore)
    else
      WriteBool(SCnOptionSection, csUseOneCPUCore, UseOneCPUCore);
  finally
    Free;
  end;
end;

function TCnWizOptions.GetUpgradeCheckDate: TDateTime;
begin
  with CreateRegIniFile do
  try
    Result := ReadDate(SCnUpgradeSection, csUpgradeCheckDate, Date - 1);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.SetUpgradeCheckDate(const Value: TDateTime);
begin
  with CreateRegIniFile do
  try
    WriteDate(SCnUpgradeSection, csUpgradeCheckDate, Value);
  finally
    Free;
  end;
end;

function TCnWizOptions.GetUpgradeCheckMonth: TDateTime;
begin
  with CreateRegIniFile do
  try
    Result := ReadDate(SCnUpgradeSection, csUpgradeCheckMonth, 0);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.SetUpgradeCheckMonth(const Value: TDateTime);
begin
  with CreateRegIniFile do
  try
    WriteDate(SCnUpgradeSection, csUpgradeCheckMonth, Value);
  finally
    Free;
  end;
end;

function TCnWizOptions.IsCSource(const FileName: string): Boolean;
begin
  Result := FileMatchesExts(FileName, FCExt);
end;

function TCnWizOptions.IsDelphiSource(const FileName: string): Boolean;
begin
  Result := FileMatchesExts(FileName, FDelphiExt);
end;

// ÿ�����Ա������б���
procedure TCnWizOptions.SetCurrentLangID(const Value: Cardinal);
begin
  FCurrentLangID := Value;
  WriteInteger(SCnOptionSection, csLangID, FCurrentLangID);
end;

procedure TCnWizOptions.SetUseCustomUserDir(const Value: Boolean);
begin
  FUseCustomUserDir := Value;
end;

procedure TCnWizOptions.SetUseOneCPUCore(const Value: Boolean);
var
  AMask,
  SysMask: NativeUInt;
begin
  FUseOneCPUCore := Value;
  if GetProcessAffinityMask(GetCurrentProcess, AMask, SysMask) then
  begin
    if FUseOneCPUCore then
      SetProcessAffinityMask(GetCurrentProcess, $0001)
    else
      SetProcessAffinityMask(GetCurrentProcess, SysMask);
  end;
end;

procedure TCnWizOptions.SetCustomUserDir(const Value: string);
begin
  FCustomUserDir := Value;
end;

//------------------------------------------------------------------------------
// �û������ļ�����
//------------------------------------------------------------------------------

function TCnWizOptions.CheckUserFile(const FileName: string; FileNameDef: 
  string = ''): Boolean;
var
  SrcFile, DstFile: string;
  SrcStream, DstStream: TMemoryStream;
begin
  if FileNameDef = '' then
    FileNameDef := FileName;
  Result := False;
  try
    SrcFile := DataPath + FileNameDef;
    DstFile := UserPath + FileName;
    // �����ļ������
    if GetFileSize(SrcFile) <> GetFileSize(DstFile) then
      Exit;

    // �Ƚ������ļ�������
    SrcStream := nil;
    DstStream := nil;
    try
      SrcStream := TMemoryStream.Create;
      DstStream := TMemoryStream.Create;
      SrcStream.LoadFromFile(SrcFile);
      DstStream.LoadFromFile(DstFile);
      Result := (SrcStream.Size = DstStream.Size) and
        CompareMem(SrcStream.Memory, DstStream.Memory, SrcStream.Size);

      // �ļ���ͬʱɾ���û������ļ�
      if Result then
        DeleteFile(DstFile);
    finally
      if Assigned(SrcStream) then SrcStream.Free;
      if Assigned(DstStream) then DstStream.Free;
    end;
  except
    ;
  end;
end;

function TCnWizOptions.GetUserFileName(const FileName: string; IsRead: Boolean;
  FileNameDef: string = ''): string;
var
  SrcFile, DstFile: string;
begin
  ForceDirectories(UserPath);
  if FileNameDef = '' then
    FileNameDef := FileName;
  SrcFile := DataPath + FileNameDef;
  DstFile := UserPath + FileName;
  if IsRead and (not FileExists(DstFile) or (GetFileSize(DstFile) <= 0)) then
    Result := SrcFile
  else
    Result := DstFile;
end;

function TCnWizOptions.LoadUserFile(Lines: TStrings;
  const FileName: string; FileNameDef: string; DoTrim: Boolean): Boolean;
var
  FName: string;
begin
  Result := False;
  FName := GetUserFileName(FileName, True, FileNameDef);
  if FileExists(FName) then
  begin
    Lines.LoadFromFile(FName);
    if DoTrim then
      TrimStrings(Lines);
    Result := True;
  end;
end;

function TCnWizOptions.SaveUserFile(Lines: TStrings;
  const FileName: string; FileNameDef: string; DoTrim: Boolean): Boolean;
var
  FName: string;
begin
  Result := False;
  FName := GetUserFileName(FileName, False, FileNameDef);
  try
    if DoTrim then
      TrimStrings(Lines);
    Lines.SaveToFile(FName);
    CheckUserFile(FileName, FileNameDef);
    Result := True;
  except
    ;
  end;
end;

//------------------------------------------------------------------------------
// INI �������
//------------------------------------------------------------------------------

function TCnWizOptions.CreateRegIniFile: TCustomIniFile;
begin
  Result := TRegistryIniFile.Create(FRegPath);
end;

function TCnWizOptions.CreateRegIniFile(const APath: string;
  CompilerSection: Boolean): TCustomIniFile;
begin
  if CompilerSection then
    Result := TRegistryIniFile.Create(MakePath(APath) + CompilerID)
  else
    Result := TRegistryIniFile.Create(APath);
end;

function TCnWizOptions.ReadBool(const Section, Ident: string;
  Default: Boolean): Boolean;
begin
  with CreateRegIniFile do
  try
    Result := ReadBool(Section, Ident, Default);
  finally
    Free;
  end;
end;

function TCnWizOptions.ReadInteger(const Section, Ident: string;
  Default: Integer): Integer;
begin
  with CreateRegIniFile do
  try
    Result := ReadInteger(Section, Ident, Default);
  finally
    Free;
  end;
end;

function TCnWizOptions.ReadString(const Section, Ident: string;
  Default: string): string;
begin
  with CreateRegIniFile do
  try
    Result := ReadString(Section, Ident, Default);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.WriteBool(const Section, Ident: string;
  Value: Boolean);
begin
  with CreateRegIniFile do
  try
    WriteBool(Section, Ident, Value);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.WriteInteger(const Section, Ident: string;
  Value: Integer);
begin
  with CreateRegIniFile do
  try
    WriteInteger(Section, Ident, Value);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.WriteString(const Section, Ident: string;
  Value: string);
begin
  with CreateRegIniFile do
  try
    WriteString(Section, Ident, Value);
  finally
    Free;
  end;
end;

function TCnWizOptions.GetUseToolsMenu: Boolean;
begin
  Result := FUseToolsMenu;
end;

procedure TCnWizOptions.SetUseToolsMenu(const Value: Boolean);
begin
  if Value <> FUseToolsMenu then
  begin
    FUseToolsMenu := Value;
    CnWizardMgr.UpdateMenuPos(Value);
  end;
end;

procedure TCnWizOptions.SetFixThreadLocale(const Value: Boolean);
begin
  FFixThreadLocale := Value;
  DoFixThreadLocale;
end;

procedure TCnWizOptions.DoFixThreadLocale;
begin
  if FFixThreadLocale then
    SetThreadLocale(LOCALE_SYSTEM_DEFAULT);
end;

end.
