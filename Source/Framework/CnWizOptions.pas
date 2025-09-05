{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizOptions;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards ���������൥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��Lazarus ��û��ר�Ұ� DLL �ĸ���Ĵ�ע��������װ·��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6 + Lazarus 4.0
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.06.23 V1.2
*               ����� Lazarus ��֧��
*           2018.06.30 V1.1
*               �������������ָ���û��洢Ŀ¼��֧��
*           2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, IniFiles,
  FileCtrl, Forms, Registry, ComCtrls {$IFDEF DELPHI_OTA} , ToolsAPI {$ENDIF}
  {$IFDEF COMPILER6_UP}, SHFolder {$ENDIF};

const
  csLargeImageListHeight = 24;
  csLargeImageListWidth = 24;
  csButtonWidth = 20;
  csButtonHeight = 20;
  csLargeButtonWidth = 32;
  csLargeButtonHeight = 32;
  csLargeToolbarHeightDelta = 8;
  csLargeComboFontSize = 14;
  csLargeToolbarHeight = 33;
  csLargeToolbarButtonWidth = 31;
  csLargeToolbarButtonHeight = 30;

type
//==============================================================================
// ר�ҹ���������
//==============================================================================

{ TCnWizOptions }

  TCnWizUpgradeStyle = (usDisabled, usAllUpgrade, usUserDefine);
  {* ���¼������}

  TCnWizUpgradeContent = set of (ucNewFeature, ucBigBugFixed);
  {* ��������}

  TCnWizSizeEnlarge = (wseOrigin, wsOneQuarter, wseAddHalf, wseDouble, wseDoubleHalf, wseTriple);
  {* ��Ļ����Ŵ�����1��1.25��1.5��2��2.5��3}

  TCnWizOptions = class(TObject)
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
    FCppExt: string;
    FLazarusExt: string;
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
    FUseCmdUserDir: Boolean;
    FUseOneCPUCore: Boolean;
    FUseLargeIcon: Boolean;
    FSizeEnlarge: TCnWizSizeEnlarge;
    FDisableIcons: Boolean;
    FTempForceDisableIco: Boolean;
    FUseSearchCombo: Boolean;
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
    procedure SetUseLargeIcon(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadSettings;
    procedure SaveSettings(Manual: Boolean = False);
    // Manual Ϊ True ʱ��ʾ�ӽ��汣������ǽ���ʱ�Զ�����

{$IFNDEF CNWIZARDS_MINIMUM}
    procedure ResetToolbarWithLargeIcons(AToolBar: TToolBar);
    {* ��װ�ĸ����Ƿ�ʹ�ô�ͼ����������ͨ�����ϲ��Ĺ������ķ�����Ҳ�����ڱ༭��������
      ǰ���� AToolbar �Ѿ������ Parent ���� Scale ��}
{$ENDIF}

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

    function GetDataFileName(const FileName: string): string;
    {* ���ذ�װʱ�Դ���ԭʼ�����ļ������������û������ļ���
      �������Ҫ��ȷ����ԭʼ�����ļ�ʱʹ�ã������°�ѡ��ϲ�}
    function GetUserFileName(const FileName: string; IsRead: Boolean; FileNameDef:
      string = ''): string;
    {* �����û������ļ�������� UserPath �µ��ļ������ڣ����� DataPath �е��ļ���}
    function GetAbsoluteUserFileName(const FileName: string): string;
    {* ���� UserPath �µ��ļ��������۴������}
    function CheckUserFile(const FileName: string; FileNameDef: string = ''):
      Boolean;
    {* ����û������ļ������ UserPath �µ��ļ��� DataPath �µ�һ�£�ɾ��
       UserPath �µ��ļ����Ա�֤ DataPath �µ��ļ�������ʹ��Ĭ�����õ�
       �û����Ի�ø��¡�������ļ�һ�£����� True}
    function CleanUserFile(const FileName: string): Boolean;
    {* ɾ���û������ļ�}
    function LoadUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* װ���û��ļ����ַ����б� }
    function SaveUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* �����ַ����б��û��ļ� }
    procedure DoFixThreadLocale;

    class function CalcIntEnlargedValue(AEnlarge: TCnWizSizeEnlarge; Value: Integer): Integer;
    {* ����ԭʼ�ߴ���Ŵ�������Ŵ��ĳߴ磬�������õģ��ñ�֤�������Ӧ}
    class function CalcIntUnEnlargedValue(AEnlarge: TCnWizSizeEnlarge;Value: Integer): Integer;
    {* ���ݷŴ��ĳߴ���Ŵ�������ԭʼ�ߴ磬�������õģ��ñ�֤�������Ӧ}

    procedure DumpToStrings(Infos: TStrings);
    {* ��ӡ�ڲ���Ϣ}

    // ר�� DLL ����
    property DllName: string read FDllName;
    {* ר�� DLL �����ļ�����Lazarus ��Ϊ��}
    property DllPath: string read FDllPath;
    {* ר�� DLL ���ڵ�Ŀ¼��Lazarus ��Ϊר�Ұ���װĿ¼}
    property CompilerPath: string read FCompilerPath;
    {* ר�Ҷ�Ӧ�� IDE �Ŀ�ִ���ļ�����·�������Ǳ����� dcc32 ����}

    // ר��ʹ�õ�����
    property CurrentLangID: Cardinal read FCurrentLangID write SetCurrentLangID;
    {* ��ǰ���� ID}

    // ר��ʹ�õ�Ŀ¼��
    property LangPath: string read FLangPath;
    {* �����Դ洢�ļ�Ŀ¼}
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
    {* ������ IDE ʹ�õ�ע���·������ Lazarus ��Ϊ��}

    // �û�����
    property DelphiExt: string read FDelphiExt write FDelphiExt;
    {* �û������ Delphi �ļ���չ��}
    property CppExt: string read FCppExt write FCppExt;
    {* �û������ C/C++ �ļ���չ��}
    property LazarusExt: string read FLazarusExt write FLazarusExt;
    {* �û������ Lazarus �ļ���չ��}
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
    {* �ڶ� CPU ��ֻʹ��һ�� CPU �ںˣ��Խ������������}
    property UseLargeIcon: Boolean read FUseLargeIcon write SetUseLargeIcon;
    {* �Ƿ��ڹ������ȴ�ʹ�ô�ߴ�ͼ�꣬ע�������ڳ������ô����ⲻҪ�ı��ֵ���������ͼ�겻һ�¡�}
    property SizeEnlarge: TCnWizSizeEnlarge read FSizeEnlarge write FSizeEnlarge;
    {* ������ֺ���ߴ�Ŵ���ö��}
    property DisableIcons: Boolean read FDisableIcons write FDisableIcons;
    {* ����ͼ���Լ��� GDI ��Դռ�ã���δ���⿪����Ϊ������ͼ�겻����}

    property UseCustomUserDir: Boolean read FUseCustomUserDir write SetUseCustomUserDir;
    {* �Ƿ�ʹ��ָ���� User Ŀ¼}
    property CustomUserDir: string read FCustomUserDir write SetCustomUserDir;
    {* Vista / Win7 ��ʹ��ָ���� User Ŀ¼������Ȩ������}

    property UseSearchCombo: Boolean read FUseSearchCombo write FUseSearchCombo;
    {* ����ʹ�� ComboBox ��������ѡ��ĳ��ϣ��Ƿ���� CnSearchCombo}
  end;

var
  WizOptions: TCnWizOptions = nil;
  {* ר�һ�����������}

function GetFactorFromSizeEnlarge(Enlarge: TCnWizSizeEnlarge): Single;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFNDEF LAZARUS}
{$IFNDEF STAND_ALONE}
  CnWizUtils, CnWizIdeUtils, CnWizManager,
  {$IFNDEF CNWIZARDS_MINIMUM} CnWizShareImages, {$ENDIF}
{$ENDIF}
{$ENDIF}
  CnWizConsts, CnCommon,  CnConsts, CnWizCompilerConst, CnRegIni, CnNative;

function GetFactorFromSizeEnlarge(Enlarge: TCnWizSizeEnlarge): Single;
begin
  Result := 1.0;
  case Enlarge of
    wseOrigin:      Result := 1.0;
    wsOneQuarter:   Result := 1.25;
    wseAddHalf:     Result := 1.5;
    wseDouble:      Result := 2.0;
    wseDoubleHalf:  Result := 2.5;
    wseTriple:      Result := 3.0;
  end;
end;

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
  csCppExt = 'CppExt';
  csLazarusExt = 'LazarusExt';
  csUseToolsMenu = 'UseToolsMenu';
  csFixThreadLocale = 'FixThreadLocale';
  csUseOneCPUCore = 'UseOneCPUCore';
  csUseLargeIcon = 'UseLargeIcon';
  csSizeEnlarge = 'SizeEnlarge';
  csDisableIcons = 'DisableIcons';
{$IFDEF BDS}
  csUseOneCPUDefault = False;
{$ELSE}
  csUseOneCPUDefault = False;
{$ENDIF}

  csDelphiExtDefault = '.pas;.dpr;.inc';
  csCppExtDefault = '.c;.cpp;.h;.hpp;.cc;.hh';
  csLazarusExtDefault = '.pas;.dpr;.inc;.lpr;.pp';

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
  csUseSearchCombo = 'UseSearchCombo';

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
  I: Integer;
  S: string;
{$IFNDEF DELPHI_OTA}
  Reg: TRegistry;
{$ELSE}
  Svcs: IOTAServices;
{$ENDIF}
begin
  inherited;
{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
  Svcs := BorlandIDEServices as IOTAServices;
  Assert(Assigned(Svcs));
  FCompilerRegPath := Svcs.GetBaseRegistryKey;
{$ENDIF}
{$ENDIF}

{$IFNDEF DELPHI_OTA}
  // Lazarus ��û DLL ���ڣ��Ĵ�ע��������װ����д��� InstallDir
  Reg := TRegistry.Create; // ����ע������
  try
    Reg.RootKey := HKEY_CURRENT_USER; // ���ø���Ϊ HKCU

    if Reg.OpenKeyReadOnly('Software\CnPack\CnWizards') then
    begin
      // �����Ƿ���ڲ���ȡ
      if Reg.ValueExists('InstallDir') then
      begin
        FDllPath := Reg.ReadString('InstallDir');
        if FDllPath <> '' then
          FDllPath := MakePath(FDllPath);  // ȷ��β����б��
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Laz WizOption Get Installation Path: ' + FDllPath);
{$ENDIF}
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
{$ELSE}
  GetModuleFileName(hInstance, ModuleName, MAX_PATH);
  FDllName := ModuleName;
  FDllPath := _CnExtractFilePath(FDllName);
{$ENDIF}
  FCompilerPath := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));

  FLangPath := MakePath(FDllPath + SCnWizLangPath);
  FDataPath := MakePath(FDllPath + SCnWizDataPath);
  FTemplatePath := MakePath(FDllPath + SCnWizTemplatePath);
  FIconPath := MakePath(FDllPath + SCnWizIconPath);
  FHelpPath := MakePath(FDllPath + SCnWizHelpPath);

  FRegBase := SCnPackRegPath;
  if FindCmdLineSwitch(SCnNoIcons, ['/', '-'], True) then
    FTempForceDisableIco := True;

  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (Length(S) > Length(SCnUserRegSwitch) + 1) and CharInSet(S[1], ['-', '/']) and
      SameText(Copy(S, 2, Length(SCnUserRegSwitch)), SCnUserRegSwitch) then
    begin
      FRegBase := MakePath(SCnSoftwareRegPath +
        Copy(S, Length(SCnUserRegSwitch) + 2, MaxInt));
    end
    else if (Length(S) > Length(SCnUserDirSwitch) + 1) and CharInSet(S[1], ['-', '/']) and
      SameText(Copy(S, 2, Length(SCnUserDirSwitch)), SCnUserDirSwitch) then
    begin
      FUseCmdUserDir := True;
      FCustomUserDir := Copy(S, Length(SCnUserDirSwitch) + 2, MaxInt);
    end;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Registry Base Path: ' + FRegBase);
  if FUseCmdUserDir then
    CnDebugger.LogMsg('Command Line Set User Path: ' + FCustomUserDir);
{$ENDIF}

  FRegPath := MakePath(MakePath(FRegBase) + SCnWizardRegPath);
  FPropEditorRegPath := MakePath(MakePath(FRegBase) + SCnPropEditorRegPath);
  FCompEditorRegPath := MakePath(MakePath(FRegBase) + SCnCompEditorRegPath);
  FIdeEhnRegPath := MakePath(FRegPath + SCnIdeEnhancementsRegPath);
  FCompilerName := CnWizCompilerConst.CompilerName;
  FCompilerID := CompilerShortName;
  FBuildDate := CnStrToDate(SCnWizardBuildDate);
  
{$IFDEF DEBUG}
  CnDebugger.LogMsg('CompilerPath: ' + FCompilerPath);
  CnDebugger.LogMsg('CompilerRegPath: ' + FCompilerRegPath);
  CnDebugger.LogMsg('WizardDllName: ' + FDllName);
  CnDebugger.LogMsg('WizardRegPath: ' + FRegPath);
{$ENDIF}

  with CreateRegIniFile do
  try
    FCurrentLangID := ReadInteger(SCnOptionSection, csLangID, GetSystemDefaultLCID);
    FShowHint := ReadBool(SCnOptionSection, csShowHint, True);
    FShowWizComment := ReadBool(SCnOptionSection, csShowWizComment, True);
    FShowTipOfDay := ReadBool(SCnOptionSection, csShowTipOfDay, True);
    FDelphiExt := ReadString(SCnOptionSection, csDelphiExt, csDelphiExtDefault);
    if FDelphiExt = '' then FDelphiExt := csDelphiExtDefault;
    FCppExt := ReadString(SCnOptionSection, csCppExt, csCppExtDefault);
    if FCppExt = '' then FCppExt := csCppExtDefault;
    FLazarusExt := ReadString(SCnOptionSection, csLazarusExt, csLazarusExtDefault);
    if FLazarusExt = '' then FLazarusExt := csLazarusExtDefault;
    FUseToolsMenu := ReadBool(SCnOptionSection, csUseToolsMenu, False);
    FixThreadLocale := ReadBool(SCnOptionSection, csFixThreadLocale, False);
    FUseLargeIcon := ReadBool(SCnOptionSection, csUseLargeIcon, False);
    FSizeEnlarge := TCnWizSizeEnlarge(ReadInteger(SCnOptionSection, csSizeEnlarge, Ord(FSizeEnlarge)));
    FDisableIcons := ReadBool(SCnOptionSection, csDisableIcons, False);
    if FTempForceDisableIco then
      FDisableIcons := True;

    FUseCustomUserDir := ReadBool(SCnOptionSection, csUseCustomUserDir, CheckWinVista);
    SHGetFolderPath(0, CSIDL_PERSONAL or CSIDL_FLAG_CREATE, 0, 0, SHUserDir);
    DefDir := MakePath(SHUserDir) + SCnWizCustomUserPath;

    if not FUseCmdUserDir then
      FCustomUserDir := ReadString(SCnOptionSection, csCustomUserDir, DefDir);

    if FUseCustomUserDir or FUseCmdUserDir then // ʹ��ָ���û�Ŀ¼ʱ��Ҫ��֤��Ŀ¼��Ч
    begin
      if (FCustomUserDir <> '') and not DirectoryExists(FCustomUserDir) then
        CreateDirectory(PChar(FCustomUserDir), nil);
      if (FCustomUserDir = '') or not DirectoryExists(FCustomUserDir) then
        FCustomUserDir := DefDir;
    end;
    FUseSearchCombo := ReadBool(SCnOptionSection, csUseSearchCombo, True);

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

  if FUseCustomUserDir or FUseCmdUserDir then
    FUserPath := MakePath(FCustomUserDir)
  else
    FUserPath := MakePath(FDllPath + SCnWizUserPath);
  CreateDirectory(PChar(FUserPath), nil);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('User Path: ' + FUserPath);
{$ENDIF}

  with TMemIniFile.Create(FDataPath + SCnWizUpgradeIniFile) do
  try
    FUpgradeURL := ReadString(SCnUpgradeSection, csUpgradeURL, SCnWizDefUpgradeURL);
    FNightlyBuildUrl := ReadString(SCnUpgradeSection, csNightlyBuildURL, SCnWizDefNightlyBuildUrl);
  finally
    Free;
  end;
end;

procedure TCnWizOptions.SaveSettings(Manual: Boolean);
begin
  with CreateRegIniFile do
  try
    WriteInteger(SCnOptionSection, csLangID, FCurrentLangID);
    WriteBool(SCnOptionSection, csShowHint, FShowHint);
    WriteBool(SCnOptionSection, csShowWizComment, FShowWizComment);
    WriteBool(SCnOptionSection, csShowTipOfDay, FShowTipOfDay);
    WriteString(SCnOptionSection, csDelphiExt, FDelphiExt);
    WriteString(SCnOptionSection, csCppExt, FCppExt);
    WriteString(SCnOptionSection, csLazarusExt, FLazarusExt);
    WriteBool(SCnOptionSection, csUseToolsMenu, FUseToolsMenu);
    WriteBool(SCnOptionSection, csFixThreadLocale, FFixThreadLocale);

    if Manual then // ��ѡ��ֻ���ֹ�����ʱ����
      WriteBool(SCnOptionSection, csUseLargeIcon, FUseLargeIcon);

    WriteInteger(SCnOptionSection, csSizeEnlarge, Ord(FSizeEnlarge));
    if not FTempForceDisableIco then
      WriteBool(SCnOptionSection, csDisableIcons, FDisableIcons);

    WriteBool(SCnOptionSection, csUseCustomUserDir, FUseCustomUserDir);
    if not FUseCmdUserDir then // ������������ָ��Ŀ¼ʱ�ű���Ŀ¼��������������ָ����Ŀ¼���ǵ�����Ŀ¼
      WriteString(SCnOptionSection, csCustomUserDir, FCustomUserDir);

    WriteBool(SCnOptionSection, csUseSearchCombo, FUseSearchCombo);
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
  Result := FileMatchesExts(FileName, FCppExt);
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
  AMask, SysMask: TCnNativeUInt;
begin
  FUseOneCPUCore := Value;
  if GetProcessAffinityMask(GetCurrentProcess, AMask, SysMask) then
  begin
    if FUseOneCPUCore then
      SetProcessAffinityMask(GetCurrentProcess, $0001)
    else
      SetProcessAffinityMask(GetCurrentProcess, AMask);
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

function TCnWizOptions.GetDataFileName(const FileName: string): string;
begin
  Result := DataPath + FileName;
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

function TCnWizOptions.GetAbsoluteUserFileName(const FileName: string): string;
begin
  ForceDirectories(UserPath);
  Result := UserPath + FileName;
end;

function TCnWizOptions.CleanUserFile(const FileName: string): Boolean;
var
  S: string;
begin
  Result := True;
  S := GetAbsoluteUserFileName(FileName);
  if FileExists(S) then
    Result := DeleteFile(FileName);
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
  Result := TCnRegistryIniFile.Create(FRegPath);
end;

function TCnWizOptions.CreateRegIniFile(const APath: string;
  CompilerSection: Boolean): TCustomIniFile;
begin
  if CompilerSection then
    Result := TCnRegistryIniFile.Create(MakePath(APath) + CompilerID)
  else
    Result := TCnRegistryIniFile.Create(APath);
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
{$IFNDEF STAND_ALONE}
{$IFNDEF LAZARUS}
    // TODO: CnWizardMgr �� Lazarus ֧�ֺú������ô˴�
    CnWizardMgr.UpdateMenuPos(Value);
{$ENDIF}
{$ENDIF}
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

procedure TCnWizOptions.SetUseLargeIcon(const Value: Boolean);
begin
  if FUseLargeIcon <> Value then
  begin
    FUseLargeIcon := Value;
  end;
end;

class function TCnWizOptions.CalcIntEnlargedValue(AEnlarge: TCnWizSizeEnlarge;
  Value: Integer): Integer;
begin
  if AEnlarge = wseOrigin then
    Result := Value
  else
    Result := Round(Value * GetFactorFromSizeEnlarge(AEnlarge));
end;

class function TCnWizOptions.CalcIntUnEnlargedValue(AEnlarge: TCnWizSizeEnlarge;
  Value: Integer): Integer;
begin
  if AEnlarge = wseOrigin then
    Result := Value
  else
    Result := Round(Value / GetFactorFromSizeEnlarge(AEnlarge));
end;

{$IFNDEF CNWIZARDS_MINIMUM}

procedure TCnWizOptions.ResetToolbarWithLargeIcons(AToolBar: TToolBar);
{$IFNDEF LAZARUS}
{$IFDEF IDE_SUPPORT_HDPI}
var
  NeedNew: Boolean;
{$ENDIF}
{$ENDIF}
begin
{$IFNDEF LAZARUS}
  if AToolBar = nil then
    Exit;

{$IFNDEF STAND_ALONE}
  if FUseLargeIcon then
  begin
    AToolBar.ButtonHeight := IdeGetScaledPixelsFromOrigin(csLargeButtonHeight, AToolBar);
    AToolBar.ButtonWidth := IdeGetScaledPixelsFromOrigin(csLargeButtonWidth, AToolBar);
  end;

{$IFDEF IDE_SUPPORT_HDPI}
  NeedNew := True;
  if AToolBar.Images = dmCnSharedImages.Images then
  begin
    if FUseLargeIcon then
      AToolBar.Images := dmCnSharedImages.LargeVirtualImages
    else
      AToolBar.Images := dmCnSharedImages.VirtualImages;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ResetToolbarWithLargeIcons %s with VirtualImages', [AToolBar.Name]);
{$ENDIF}
    NeedNew := False;
  end;
  if AToolBar.DisabledImages = dmCnSharedImages.DisabledImages then
  begin
    if FUseLargeIcon then
      AToolBar.DisabledImages := dmCnSharedImages.DisabledLargeVirtualImages
    else
      AToolBar.DisabledImages := dmCnSharedImages.DisabledVirtualImages;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ResetToolbarWithLargeIcons %s with DisabledVirtualImages', [AToolBar.Name]);
{$ENDIF}
    NeedNew := False;
  end;

  if NeedNew and (AToolBar.Images <> nil) and (AToolBar.Owner = AToolBar.Images.Owner) then
  begin
    AToolBar.Images := IdeGetVirtualImageListFromOrigin(AToolBar.Images);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ResetToolbarWithLargeIcons %s New a VirtualImages', [AToolBar.Name]);
{$ENDIF}
  end;

  if (AToolBar.DisabledImages <> nil) and (AToolBar.Owner = AToolBar.DisabledImages.Owner) then
  begin
    AToolBar.DisabledImages := IdeGetVirtualImageListFromOrigin(AToolBar.DisabledImages);
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ResetToolbarWithLargeIcons %s New a DisabledVirtualImages', [AToolBar.Name]);
{$ENDIF}
  end;

{$ELSE}
  {$IFNDEF STAND_ALONE}
  if FUseLargeIcon then
  begin
    if AToolBar.Images = dmCnSharedImages.Images then
      AToolBar.Images := dmCnSharedImages.LargeImages;
    if AToolBar.DisabledImages = dmCnSharedImages.DisabledImages then
      AToolBar.DisabledImages := dmCnSharedImages.DisabledLargeImages;
  end;
  {$ENDIF}
{$ENDIF}
{$ENDIF}

  if FUseLargeIcon and (AToolBar.Height <= AToolBar.ButtonHeight) then
    AToolBar.Height := AToolBar.ButtonHeight + csLargeToolbarHeightDelta;
{$ENDIF}
end;

{$ENDIF}

procedure TCnWizOptions.DumpToStrings(Infos: TStrings);
begin
  Infos.Add('DllName: ' + DllName);
  Infos.Add('DllPath: ' + DllPath);
  Infos.Add('CompilerPath: ' + CompilerPath);
  Infos.Add('CurrentLangID: ' + IntToStr(CurrentLangID));
  Infos.Add('LangPath: ' + LangPath);
  Infos.Add('IconPath: ' + IconPath);
  Infos.Add('DataPath: ' + DataPath);
  Infos.Add('TemplatePath: ' + TemplatePath);
  Infos.Add('UserPath: ' + UserPath);
  Infos.Add('HelpPath: ' + HelpPath);
  Infos.Add('RegBase: ' + RegBase);
  Infos.Add('RegPath: ' + RegPath);
  Infos.Add('PropEditorRegPath: ' + PropEditorRegPath);
  Infos.Add('CompEditorRegPath: ' + CompEditorRegPath);
  Infos.Add('IdeEhnRegPath: ' + IdeEhnRegPath);
  Infos.Add('CompilerName: ' + CompilerName);
  Infos.Add('CompilerID: ' + CompilerID);
  Infos.Add('CompilerRegPath: ' + CompilerRegPath);
end;

end.
