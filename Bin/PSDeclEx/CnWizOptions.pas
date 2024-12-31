{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, IniFiles, Forms;

type

//==============================================================================
// 专家公共参数类
//==============================================================================

{ TCnWizOptions }

  TCnWizUpgradeStyle = (usDisabled, usAllUpgrade, usUserDefine);
  TCnWizUpgradeContentE = (ucNewFeature, ucBigBugFixed);
  TCnWizUpgradeContent = set of TCnWizUpgradeContentE;

  TCnWizOptions = class (TObject)
  {* 专家环境参数类}
  private
    FShowHint: Boolean;
    FUpgradeReleaseOnly: Boolean;
    FShowTipOfDay: Boolean;
    FShowWizComment: Boolean;
    FCurrentLangID: Cardinal;
    FRegPath: string;
    FHelpPath: string;
    FCompEditorRegPath: string;
    FCompilerPath: string;
    FDllPath: string;
    FDllName: string;
    FCompilerName: string;
    FIconPath: string;
    FPropEditorRegPath: string;
    FDelphiExt: string;
    FUpgradeURL: string;
    FIdeEhnRegPath: string;
    FCppExt: string;
    FLangPath: string;
    FDataPath: string;
    FUserPath: string;
    FNightlyBuildURL: string;
    FCompilerRegPath: string;
    FRegBase: string;
    FTemplatePath: string;
    FCompilerID: string;
    FUpgradeContent: TCnWizUpgradeContent;
    FUpgradeStyle: TCnWizUpgradeStyle;
    FUpgradeLastDate: TDateTime;
    FBuildDate: TDateTime;
    function GetUpgradeCheckDate: TDateTime;
    function GetUseToolsMenu: Boolean;
    procedure SetCurrentLangID(const Value: Cardinal);
    procedure SetUpgradeCheckDate(const Value: TDateTime);
    procedure SetUseToolsMenu(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadSettings;
    procedure SaveSettings;

    // 参数读写方法
    function CreateRegIniFile: TCustomIniFile; overload;
    {* 创建一个专家包根路径的 INI 对象}
    function CreateRegIniFileEx(const APath: string;
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
    property CppExt: string read FCppExt write FCppExt;
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
    {* 主菜单是否集成到 Tools 菜单下 }
    property UseToolsMenu: Boolean read GetUseToolsMenu write SetUseToolsMenu;
  end;

function WizOptions: TCnWizOptions; overload;
{* 专家环境参数对象}
  
implementation

{ TCnWizOptions }

function TCnWizOptions.CheckUserFile(const FileName: string;
  FileNameDef: string): Boolean;
begin

end;

constructor TCnWizOptions.Create;
begin

end;

function TCnWizOptions.CreateRegIniFile: TCustomIniFile;
begin

end;

function TCnWizOptions.CreateRegIniFileEx(const APath: string;
  CompilerSection: Boolean): TCustomIniFile;
begin

end;

destructor TCnWizOptions.Destroy;
begin

  inherited;
end;

function TCnWizOptions.GetUpgradeCheckDate: TDateTime;
begin

end;

function TCnWizOptions.GetUserFileName(const FileName: string;
  IsRead: Boolean; FileNameDef: string): string;
begin

end;

function TCnWizOptions.GetUseToolsMenu: Boolean;
begin

end;

function TCnWizOptions.IsCSource(const FileName: string): Boolean;
begin

end;

function TCnWizOptions.IsDelphiSource(const FileName: string): Boolean;
begin

end;

procedure TCnWizOptions.LoadSettings;
begin

end;

function TCnWizOptions.LoadUserFile(Lines: TStrings;
  const FileName: string; FileNameDef: string; DoTrim: Boolean): Boolean;
begin

end;

function TCnWizOptions.ReadBool(const Section, Ident: string;
  Default: Boolean): Boolean;
begin

end;

function TCnWizOptions.ReadInteger(const Section, Ident: string;
  Default: Integer): Integer;
begin

end;

function TCnWizOptions.ReadString(const Section, Ident: string;
  Default: string): string;
begin

end;

procedure TCnWizOptions.SaveSettings;
begin

end;

function TCnWizOptions.SaveUserFile(Lines: TStrings;
  const FileName: string; FileNameDef: string; DoTrim: Boolean): Boolean;
begin

end;

procedure TCnWizOptions.SetCurrentLangID(const Value: Cardinal);
begin
  FCurrentLangID := Value;
end;

procedure TCnWizOptions.SetUpgradeCheckDate(const Value: TDateTime);
begin

end;

procedure TCnWizOptions.SetUseToolsMenu(const Value: Boolean);
begin

end;

procedure TCnWizOptions.WriteBool(const Section, Ident: string;
  Value: Boolean);
begin

end;

procedure TCnWizOptions.WriteInteger(const Section, Ident: string;
  Value: Integer);
begin

end;

procedure TCnWizOptions.WriteString(const Section, Ident: string;
  Value: string);
begin

end;

function WizOptions: TCnWizOptions;
begin

end;

end.
