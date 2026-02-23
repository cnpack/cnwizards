{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizOptions;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards 公共参数类单元
* 单元作者：CnPack 开发组
* 备    注：Lazarus 下没有专家包 DLL 的概念，改从注册表里读安装路径
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6 + Lazarus 4.0
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.06.23 V1.2
*               加入对 Lazarus 的支持
*           2018.06.30 V1.1
*               加入对命令行中指定用户存储目录的支持
*           2002.11.07 V1.0
*               创建单元
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
// 专家公共参数类
//==============================================================================

{ TCnWizOptions }

  TCnWizUpgradeStyle = (usDisabled, usAllUpgrade, usUserDefine);
  {* 更新检查设置}

  TCnWizUpgradeContent = set of (ucNewFeature, ucBigBugFixed);
  {* 更新类型}

  TCnWizSizeEnlarge = (wseOrigin, wsOneQuarter, wseAddHalf, wseDouble, wseDoubleHalf, wseTriple);
  {* 屏幕字体放大倍数，1、1.25、1.5、2、2.5、3}

  TCnWizOptions = class(TObject)
  {* 专家环境参数类}
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
    FTranslateUI: Boolean;
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
    // Manual 为 True 时表示从界面保存而不是结束时自动保存

{$IFNDEF CNWIZARDS_MINIMUM}
    procedure ResetToolbarWithLargeIcons(AToolBar: TToolBar);
    {* 封装的根据是否使用大图标来调整普通窗体上部的工具栏的方法，也可用于编辑器工具栏
      前提是 AToolbar 已经设好了 Parent 并且 Scale 过}
{$ENDIF}

    // 参数读写方法
    function CreateRegIniFile: TCustomIniFile; overload;
    {* 创建一个专家包根路径的 INI 对象}
    function CreateRegIniFile(const APath: string;
      CompilerSection: Boolean = False): TCustomIniFile; overload;
    {* 创建一个指定路径的 INI 对象，CompilerSection 表示是否使用编译器相关的后缀}
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    {* 在专家包根路径的 INI 对象中读取 Bool 值}
    function ReadInteger(const Section, Ident: string; Default: Integer): Integer;
    {* 在专家包根路径的 INI 对象中读取 Integer 值}
    function ReadString(const Section, Ident: string; Default: string): string;
    {* 在专家包根路径的 INI 对象中读取 String 值}
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    {* 在专家包根路径的 INI 对象中写 Bool 值}
    procedure WriteInteger(const Section, Ident: string; Value: Integer);
    {* 在专家包根路径的 INI 对象中写 Integer 值}
    procedure WriteString(const Section, Ident: string; Value: string);
    {* 在专家包根路径的 INI 对象中写 String 值}

    function IsDelphiSource(const FileName: string): Boolean;
    {* 判断指定文件是否 Delphi 源文件，使用由用户设置的扩展名列表判断}
    function IsCSource(const FileName: string): Boolean;
    {* 判断指定文件是否 C 源文件，使用由用户设置的扩展名列表判断}

    function GetDataFileName(const FileName: string): string;
    {* 返回安装时自带的原始数据文件，无论有无用户数据文件，
      供外界需要明确处理原始数据文件时使用，比如新版选项合并}
    function GetUserFileName(const FileName: string; IsRead: Boolean; FileNameDef:
      string = ''): string;
    {* 返回用户数据文件名，如果 UserPath 下的文件不存在，返回 DataPath 中的文件名}
    function GetAbsoluteUserFileName(const FileName: string): string;
    {* 返回 UserPath 下的文件名，无论存在与否}
    function CheckUserFile(const FileName: string; FileNameDef: string = ''):
      Boolean;
    {* 检查用户数据文件，如果 UserPath 下的文件与 DataPath 下的一致，删除
       UserPath 下的文件，以保证 DataPath 下的文件升级后，使用默认设置的
       用户可以获得更新。如果两文件一致，返回 True}
    function CleanUserFile(const FileName: string): Boolean;
    {* 删除用户数据文件}
    function LoadUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* 装载用户文件到字符串列表 }
    function SaveUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* 保存字符串列表到用户文件 }
    procedure DoFixThreadLocale;

    class function CalcIntEnlargedValue(AEnlarge: TCnWizSizeEnlarge; Value: Integer): Integer;
    {* 根据原始尺寸与放大倍数计算放大后的尺寸，给子类用的，得保证和下面对应}
    class function CalcIntUnEnlargedValue(AEnlarge: TCnWizSizeEnlarge;Value: Integer): Integer;
    {* 根据放大后的尺寸与放大倍数计算原始尺寸，给子类用的，得保证和上面对应}

    procedure DumpToStrings(Infos: TStrings);
    {* 打印内部信息}

    // 专家 DLL 属性
    property DllName: string read FDllName;
    {* 专家 DLL 完整文件名，Lazarus 下为空}
    property DllPath: string read FDllPath;
    {* 专家 DLL 所在的目录，Lazarus 下为专家包安装目录}
    property CompilerPath: string read FCompilerPath;
    {* 专家对应的 IDE 的可执行文件所在路径，并非编译器 dcc32 那种}

    // 专家使用的语言
    property CurrentLangID: Cardinal read FCurrentLangID write SetCurrentLangID;
    {* 当前语言 ID}
    property TranslateUI: Boolean read FTranslateUI write FTranslateUI;
    {* 是否翻译界面主要是菜单}

    // 专家使用的目录名
    property LangPath: string read FLangPath;
    {* 多语言存储文件目录}
    property IconPath: string read FIconPath;
    {* 图标目录}
    property DataPath: string read FDataPath;
    {* 系统数据目录，仅存放只读的数据文件，升级后该数据会被覆盖}
    property TemplatePath: string read FTemplatePath;
    {* 只读的系统模板文件存放目录，居于数据目录之下 }
    property UserPath: string read FUserPath;
    {* 用户数据目录，存放所有保存用户数据和配置的文件存放，反安装时可选择不删除该目录}
    property HelpPath: string read FHelpPath;
    {* 帮助文件目录，存放专家包帮助文件}

    // 注册表路径
    property RegBase: string read FRegBase;
    {* CnPack 注册表根路径，允许通过 -cnregXXXX 指定 }
    property RegPath: string read FRegPath;
    {* 专家包使用的注册表路径}
    property PropEditorRegPath: string read FPropEditorRegPath;
    {* 专家包属性编辑器部分使用的注册表路径}
    property CompEditorRegPath: string read FCompEditorRegPath;
    {* 专家包组件编辑器部分使用的注册表路径}
    property IdeEhnRegPath: string read FIdeEhnRegPath;
    {* 专家包 IDE 扩展部分使用的注册表路径}

    // 编译器相关参数
    property CompilerName: string read FCompilerName;
    {* 编译器名称，如 Delphi 5}
    property CompilerID: string read FCompilerID;
    {* 编译器缩写，如 D5}
    property CompilerRegPath: string read FCompilerRegPath;
    {* 编译器 IDE 使用的注册表路径，在 Lazarus 下为空}

    // 用户设置
    property DelphiExt: string read FDelphiExt write FDelphiExt;
    {* 用户定义的 Delphi 文件扩展名}
    property CppExt: string read FCppExt write FCppExt;
    {* 用户定义的 C/C++ 文件扩展名}
    property LazarusExt: string read FLazarusExt write FLazarusExt;
    {* 用户定义的 Lazarus 文件扩展名}
    property ShowHint: Boolean read FShowHint write FShowHint;
    {* 是否显示控件 Hint，各窗体应在 Create 时设置 TForm.ShowHint 等于该值}
    property ShowWizComment: Boolean read FShowWizComment write FShowWizComment;
    {* 是否显示功能提示窗口}
    property ShowTipOfDay: Boolean read FShowTipOfDay write FShowTipOfDay;
    {* 是否显示每日一帖 }

    // 升级相关设置
    property BuildDate: TDateTime read FBuildDate;
    {* 专家 Build 日期}
    property UpgradeURL: string read FUpgradeURL;
    property NightlyBuildURL: string read FNightlyBuildURL;
    {* 专家升级检测地址}
    property UpgradeStyle: TCnWizUpgradeStyle read FUpgradeStyle write FUpgradeStyle;
    {* 专家升级检测方式}
    property UpgradeContent: TCnWizUpgradeContent read FUpgradeContent write FUpgradeContent;
    {* 专家升级检测内容}
    property UpgradeReleaseOnly: Boolean read FUpgradeReleaseOnly write FUpgradeReleaseOnly;
    {* 是否只检测非调试版的专家升级}
    property UpgradeLastDate: TDateTime read FUpgradeLastDate write FUpgradeLastDate;
    {* 最后一次检测的升级日期}
    property UpgradeCheckDate: TDateTime read GetUpgradeCheckDate write SetUpgradeCheckDate;
    property UpgradeCheckMonth: TDateTime read GetUpgradeCheckMonth write SetUpgradeCheckMonth;
    property UseToolsMenu: Boolean read GetUseToolsMenu write SetUseToolsMenu;
    {* 主菜单是否集成到 Tools 菜单下 }
    property FixThreadLocale: Boolean read FFixThreadLocale write SetFixThreadLocale;
    {* 使用 SetThreadLocale 修正 Vista / Win7 下中文乱码问题}
    property UseOneCPUCore: Boolean read FUseOneCPUCore write SetUseOneCPUCore;
    {* 在多 CPU 中只使用一个 CPU 内核，以解决兼容性问题}
    property UseLargeIcon: Boolean read FUseLargeIcon write SetUseLargeIcon;
    {* 是否在工具栏等处使用大尺寸图标，注意运行期除了设置窗口外不要改变此值，避免与大图标不一致。}
    property SizeEnlarge: TCnWizSizeEnlarge read FSizeEnlarge write FSizeEnlarge;
    {* 窗体的字号与尺寸放大倍数枚举}
    property DisableIcons: Boolean read FDisableIcons write FDisableIcons;
    {* 禁用图标以减少 GDI 资源占用，暂未对外开放因为工具栏图标不好整}

    property UseCustomUserDir: Boolean read FUseCustomUserDir write SetUseCustomUserDir;
    {* 是否使用指定的 User 目录}
    property CustomUserDir: string read FCustomUserDir write SetCustomUserDir;
    {* Vista / Win7 下使用指定的 User 目录来避免权限问题}

    property UseSearchCombo: Boolean read FUseSearchCombo write FUseSearchCombo;
    {* 部分使用 ComboBox 进行下拉选择的场合，是否改用 CnSearchCombo}
  end;

var
  WizOptions: TCnWizOptions = nil;
  {* 专家环境参数对象}

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
// 专家公共参数类
//==============================================================================

{ TCnWizOptions }

const
  csLangID = 'CurrentLangID';
  csTranslateUI = 'TranslateUI';
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
  // Lazarus 因没 DLL 存在，改从注册表里读安装程序写入的 InstallDir
  Reg := TRegistry.Create; // 创建注册表对象
  try
    Reg.RootKey := HKEY_CURRENT_USER; // 设置根键为 HKCU

    if Reg.OpenKeyReadOnly('Software\CnPack\CnWizards') then
    begin
      // 检查键是否存在并读取
      if Reg.ValueExists('InstallDir') then
      begin
        FDllPath := Reg.ReadString('InstallDir');
        if FDllPath <> '' then
          FDllPath := MakePath(FDllPath);  // 确保尾部有斜杠
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
    FTranslateUI := ReadBool(SCnOptionSection, csTranslateUI, False);
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

    if FUseCustomUserDir or FUseCmdUserDir then // 使用指定用户目录时需要保证该目录有效
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
    WriteBool(SCnOptionSection, csTranslateUI, FTranslateUI);
    WriteBool(SCnOptionSection, csShowHint, FShowHint);
    WriteBool(SCnOptionSection, csShowWizComment, FShowWizComment);
    WriteBool(SCnOptionSection, csShowTipOfDay, FShowTipOfDay);
    WriteString(SCnOptionSection, csDelphiExt, FDelphiExt);
    WriteString(SCnOptionSection, csCppExt, FCppExt);
    WriteString(SCnOptionSection, csLazarusExt, FLazarusExt);
    WriteBool(SCnOptionSection, csUseToolsMenu, FUseToolsMenu);
    WriteBool(SCnOptionSection, csFixThreadLocale, FFixThreadLocale);

    if Manual then // 该选项只在手工保存时保存
      WriteBool(SCnOptionSection, csUseLargeIcon, FUseLargeIcon);

    WriteInteger(SCnOptionSection, csSizeEnlarge, Ord(FSizeEnlarge));
    if not FTempForceDisableIco then
      WriteBool(SCnOptionSection, csDisableIcons, FDisableIcons);

    WriteBool(SCnOptionSection, csUseCustomUserDir, FUseCustomUserDir);
    if not FUseCmdUserDir then // 不是命令行中指定目录时才保存目录名，避免命令行指定的目录覆盖掉设置目录
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

// 每次语言变更后进行保存
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
// 用户数据文件处理
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
    // 两个文件不相等
    if GetFileSize(SrcFile) <> GetFileSize(DstFile) then
      Exit;

    // 比较两个文件的内容
    SrcStream := nil;
    DstStream := nil;
    try
      SrcStream := TMemoryStream.Create;
      DstStream := TMemoryStream.Create;
      SrcStream.LoadFromFile(SrcFile);
      DstStream.LoadFromFile(DstFile);
      Result := (SrcStream.Size = DstStream.Size) and
        CompareMem(SrcStream.Memory, DstStream.Memory, SrcStream.Size);

      // 文件相同时删除用户数据文件
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
// INI 对象操作
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
    // TODO: CnWizardMgr 对 Lazarus 支持好后再启用此处
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
