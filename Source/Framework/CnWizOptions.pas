{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizOptions;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards 公共参数类单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnWizOptions.pas,v 1.17 2009/04/22 13:19:22 zjy Exp $
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, ToolsAPI, IniFiles,
  Forms;

type

//==============================================================================
// 专家公共参数类
//==============================================================================

{ TCnWizOptions }

  TCnWizUpgradeStyle = (usDisabled, usAllUpgrade, usUserDefine);
  TCnWizUpgradeContent = set of (ucNewFeature, ucBigBugFixed);

  TCnWizOptions = class (TObject)
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
    procedure SetCurrentLangID(const Value: Cardinal);
    function GetUpgradeCheckDate: TDateTime;
    procedure SetUpgradeCheckDate(const Value: TDateTime);
    function GetUseToolsMenu: Boolean;
    procedure SetUseToolsMenu(const Value: Boolean);
    procedure SetFixThreadLocale(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadSettings;
    procedure SaveSettings;

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

    function GetUserFileName(const FileName: string; IsRead: Boolean; FileNameDef:
      string = ''): string;
    {* 返回用户数据文件名，如果 UserPath 下的文件不存在，返回 DataPath 中的文件名}
    function CheckUserFile(const FileName: string; FileNameDef: string = ''):
      Boolean;
    {* 检查用户数据文件，如果 UserPath 下的文件与 DataPath 下的一致，删除
       UserPath 下的文件，以保证 DataPath 下的文件升级后，使用默认设置的
       用户可以获得更新。如果两文件一致，返回 True}
    function LoadUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* 装载用户文件到字符串列表 }
    function SaveUserFile(Lines: TStrings; const FileName: string; FileNameDef:
      string = ''; DoTrim: Boolean = True): Boolean;
    {* 保存字符串列表到用户文件 }
    procedure DoFixThreadLocale;

    // 专家 DLL 属性
    property DllName: string read FDllName;
    {* 专家 DLL 文件名}
    property DllPath: string read FDllPath;
    {* 专家 DLL 所在的目录}
    property CompilerPath: string read FCompilerPath;

    // 当前语言 ID
    property CurrentLangID: Cardinal read FCurrentLangID write SetCurrentLangID;

    // 专家使用的目录名
    property LangPath: string read FLangPath;
    {* 多语言存储文件目录 }
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
    {* 编译器 IDE 使用的注册表路径}

    // 用户设置
    property DelphiExt: string read FDelphiExt write FDelphiExt;
    {* 用户定义的 Delphi 文件扩展名}
    property CExt: string read FCExt write FCExt;
    {* 用户定义的 C 文件扩展名}
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
    property UseToolsMenu: Boolean read GetUseToolsMenu write SetUseToolsMenu;
    {* 主菜单是否集成到 Tools 菜单下 }
    property FixThreadLocale: Boolean read FFixThreadLocale write SetFixThreadLocale;
    {* 使用 SetThreadLocale 修正 Vista / Win7 下中文乱码问题}
  end;

var
  WizOptions: TCnWizOptions;
  {* 专家环境参数对象}
  
implementation

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  CnWizUtils, CnWizConsts, CnCommon, CnWizManager, CnConsts, CnWizCompilerConst,
  Registry;

//==============================================================================
// 专家公共参数类
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

  csDelphiExtDefault = '.pas;.dpr;.inc';
  csCExtDefault = '.c;.cpp;.h;.hpp';

  csUpgradeURL = 'URL';
  csNightlyBuildURL = 'URL';
  csUpgradeReleaseOnly = 'ReleaseOnly';
  csUpgradeStyle = 'UpgradeStyle';
  csNewFeature = 'NewFeature';
  csBigBugFixed = 'BigBugFixed';
  csUpgradeLastDate = 'LastDate';
  csUpgradeCheckDate = 'CheckDate';

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
  ModuleName: array[0..MAX_Path - 1] of Char;
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
  FDllPath := ExtractFilePath(FDllName);
  FCompilerPath := ExtractFilePath(ExtractFileDir(Application.ExeName));

  FLangPath := MakePath(FDllPath + SCnWizLangPath);
  FDataPath := MakePath(FDllPath + SCnWizDataPath);
  FTemplatePath := MakePath(FDllPath + SCnWizTemplatePath);
  FIconPath := MakePath(FDllPath + SCnWizIconPath);
  FHelpPath := MakePath(FDllPath + SCnWizHelpPath);
  FUserPath := MakePath(FDllPath + SCnWizUserPath);
  CreateDirectory(PChar(FUserPath), nil);

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
    FixThreadLocale := ReadBool(SCnOptionSection, csFixThreadLocale, True);

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

    WriteBool(SCnUpgradeSection, csUpgradeReleaseOnly, FUpgradeReleaseOnly);
    WriteBool(SCnUpgradeSection, csNewFeature, ucNewFeature in FUpgradeContent);
    WriteBool(SCnUpgradeSection, csBigBugFixed, ucBigBugFixed in FUpgradeContent);
    WriteInteger(SCnUpgradeSection, csUpgradeStyle, Ord(FUpgradeStyle));
    WriteDate(SCnUpgradeSection, csUpgradeLastDate, FUpgradeLastDate);
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

function TCnWizOptions.IsCSource(const FileName: string): Boolean;
begin
  Result := FileMatchesExts(FileName, FCExt);
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
// INI 对象操作
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
