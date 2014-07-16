{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnWizClasses;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards 基础类定义单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元为 CnWizards 框架的一部分，定义了所有专家的基础类。
*           要注册一个已实现的专家，请在实现该专家的单元 initialization 节调用
*           RegisterCnWizard 来注册一个专家类引用。
*         - TCnBaseWizard
*           所有 CnWizard 最底层的抽象基类。
*           - TCnIconWizard
*             带图标的抽象基类。
*             - TCnIDEEnhanceWizard
*               IDE 功能扩展专家基类。
*             - TCnActionWizard
*               带 IDE Action 的抽象基类，可用来派生出有快捷键的专家。
*               - TCnMenuWizard
*                 带菜单的的抽象基类，可用来派生出通过菜单调用的专家。
*                 - TCnSubMenuWizard
*                   带子菜单项的抽象基类，可用来派生出通过子菜单项调用的专家。
*             - TCnRepositoryWizard
*               抽象 Repository 专家基类。
*               - TCnFormWizard
*                 用来产生窗体单元文件的模板向导基类，包括单独的 Pas 单元。
*               - TCnProjectWizard
*                 用来产生应用程序工程的模板向导基类。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.06.01 V1.8
*               LiuXiao 调整 TCnSubMenuWizard.OnPopup 方法，在弹出菜单中加入子菜单。
*           2004.04.27 V1.7
*               beta 给 TCnSubMenuWizard 增加了一个方法：AddSubMenuWizard，
*               并调整了相应的方法，以提供对多级子菜单专家的支持。
*           2003.12.12 V1.6
*               给 TCnUnitWizard 增加 IOTAFormWizard 接口。
*           2003.06.22 V1.5
*               增加抽象类 TCnIconWizard，以代表带图标的专家。
*               增加基础类 TCnIDEEnhanceWizard，以代表 IDE 功能扩展基础类。
*           2003.05.02 V1.4
*               实现了 TCnSubMenuWizard.ShowShortCutDialog 方法
*           2003.04.15 V1.3
*               修正子菜单专家产生的按钮状态不能自动更新的问题
*           2003.02.27 V1.2
*               为子菜单专家增加工具条按钮支持，点击时弹出下拉框
*           2002.10.26 V1.1
*               新增 CnSubMenuWizard 基类
*           2002.09.17 V1.0
*               创建单元，实现基本功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Classes, Sysutils, Graphics, Menus, ActnList, IniFiles, ToolsAPI,
  Registry, ComCtrls, Forms, CnWizShortCut, CnWizMenuAction, CnIni, CnWizConsts,
  CnPopupMenu;

type

//==============================================================================
// 专家包专家抽象基类
//==============================================================================

{ TCnBaseWizard }

{$M+}

  TCnBaseWizard = class(TNotifierObject, IOTAWizard)
  {* CnWizard 专家抽象基类，定义了专家最基本的公共内容 }
  private
    FActive: Boolean;
    FWizardIndex: Integer;
  protected
    procedure SetActive(Value: Boolean); virtual;
    {* Active 属性写方法，子类重载该方法处理 Active 属性变更事件 }
    function GetHasConfig: Boolean; virtual;
    {* HasConfig 属性读方法，子类重载该方法返回是否存在可配置内容 }
    function GetIcon: TIcon; virtual; abstract;
    {* Icon 属性读方法，子类重载该方法返回返回专家图标，用户专家通常不需自己处理 }

    // IOTAWizard methods
    function GetIDString: string;
    function GetName: string; virtual;
  public
    constructor Create; virtual;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
    class function WizardName: string;
    {* 取专家名称，可以是支持本地化的字符串 }
    function GetAuthor: string; virtual;
    function GetComment: string; virtual;
    procedure DebugComand(Cmds: TStrings; Results: TStrings); virtual;
    {* 处理 Debug 输出命令并将结果放置入 Results 中，供内部调试用}

    // IOTAWizard methods
    function GetState: TWizardState; virtual;
    {* 返回专家状态，IOTAWizard 方法，子类重载该方法返回专家状态 }
    procedure Execute; virtual; abstract;
    {* 专家执行体方法，IOTAWizard 抽象方法，子类必须实现。
       当用户执行一个专家时，将调用该方法。 }

    procedure Loaded; virtual;
    {* IDE 启动完成后调用该方法}

    class function IsInternalWizard: Boolean; virtual;
    {* 该专家是否属于内部专家，不显示、不可配置 }
    
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string);
      virtual; {$IFNDEF BCB}abstract;{$ENDIF BCB}
    {* 取专家信息，用于提供专家的说明和版权信息。抽象方法，子类必须实现。
     |<PRE>
       var AName: string      - 专家名称，可以是支持本地化的字符串
       var Author: string     - 专家作者，如果有多个作者，用分号分隔
       var Email: string      - 专家作者邮箱，如果有多个作者，用分号分隔
       var Comment: string    - 专家说明，可以是支持本地化带换行符的字符串
     |</PRE> }
    procedure Config; virtual;
    {* 专家配置方法，由专家管理器在专家配置界面中调用，当 HasConfig 为真时有效 }
    procedure LanguageChanged(Sender: TObject); virtual;
    {* 专家在多语的语言发生改变的时候的处理，子类重载此过程处理语言字符串 }
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* 装载专家设置方法，子类重载此方法从 INI 对象中读取专家参数 }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* 保存专家设置方法，子类重载此方法将专家参数保存到 INI 对象中 }

    class function GetIDStr: string;
    {* 返回专家唯一标识符，供管理器使用 }
    class function CreateIniFile(CompilerSection: Boolean = False): TCustomIniFile;
    {* 返回一个用于存取专家设置参数的 INI 对象，用户使用后须自己释放 }
    procedure DoLoadSettings;
    {* 装载专家设置 }
    procedure DoSaveSettings;
    {* 装载专家设置 }

    property Active: Boolean read FActive write SetActive;
    {* 活跃属性，表明专家当前是否可用 }
    property HasConfig: Boolean read GetHasConfig;
    {* 表示专家是否存在配置界面的属性 }
    property WizardIndex: Integer read FWizardIndex write FWizardIndex;
    {* 专家注册后由 IDE 返回的索引号，在释放专家时使用，请不要修改该值 }
    property Icon: TIcon read GetIcon;
    {* 专家图标属性 }
  end;
  
{$M-}

type
  TCnWizardClass = class of TCnBaseWizard;

//==============================================================================
// 带图标属性的基础类
//==============================================================================

{ TCnIconWizard }

  TCnIconWizard = class(TCnBaseWizard)
  {* IDE 带图标属性的基础类 }
  private
    FIcon: TIcon;
  protected
    function GetIcon: TIcon; override;
    {* 返回该类专家的图标，子类可重载此过程返回其它的 Icon 对象 }
    procedure InitIcon(AIcon: TIcon); virtual;
    {* 根据类名初始化图标，对象创建时调用，子类可重载此过程重新处理 FIcon }
    class function GetIconName: string; virtual;
    {* 返回图标文件名 }
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
  end;

//==============================================================================
// IDE 功能扩展基础类
//==============================================================================

{ TCnIDEEnhanceWizard }

  TCnIDEEnhanceWizard = class(TCnIconWizard);
  {* IDE 功能扩展基础类 }
  
//==============================================================================
// 带 Action 和快捷键的抽象专家类
//==============================================================================

{ TCnActionWizard }

  TCnActionWizard = class(TCnIDEEnhanceWizard)
  {* 带 Action 和快捷键的 CnWizard 专家抽象基类 }
  private
    FAction: TCnWizAction;
    function GetImageIndex: Integer;
  protected
    function GetIcon: TIcon; override;
    procedure OnActionUpdate(Sender: TObject); virtual;
    function CreateAction: TCnWizAction; virtual;
    procedure Click(Sender: TObject); virtual;
    function GetCaption: string; virtual; abstract;
    {* 返回专家的标题 }
    function GetHint: string; virtual;
    {* 返回专家的Hint提示 }
    function GetDefShortCut: TShortCut; virtual;
    {* 返回专家的默认快捷键，实际使用时专家的快捷键会可能由管理器来设定，这里
       只需要返回默认的就行了。 }
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
    property ImageIndex: Integer read GetImageIndex;
    {* 专家图标在 IDE 的主 ImageList 中的索引号 }
    property Action: TCnWizAction read FAction;
    {* 专家 Action 属性 }
    function EnableShortCut: Boolean; virtual;
    {* 返回专家是否可以用快捷键调用 }
    procedure RefreshAction; virtual;
    {* 重新更新 Action 的内容 }
  end;

//==============================================================================
// 带菜单的抽象专家类
//==============================================================================

{ TCnMenuWizard }

type
  TCnMenuWizard = class(TCnActionWizard)
  {* 带菜单的 CnWizard 专家抽象基类 }
  private
    FMenuOrder: Integer;
    function GetAction: TCnWizMenuAction;
    function GetMenu: TMenuItem;
    procedure SetMenuOrder(const Value: Integer);
  protected
    function CreateAction: TCnWizAction; override;
  public
    constructor Create; override;
    function EnableShortCut: Boolean; override;
    {* 返回专家是否可以用快捷键调用 }
    property Menu: TMenuItem read GetMenu;
    {* 专家的菜单属性 }
    property Action: TCnWizMenuAction read GetAction;
    {* 专家 Action 属性 }
    property MenuOrder: Integer read FMenuOrder write SetMenuOrder;
  end;

//==============================================================================
// 带子菜单项的抽象专家类
//==============================================================================

{ TCnSubMenuWizard }

  TCnSubMenuWizard = class(TCnMenuWizard)
  {* 带子菜单项的 CnWizard 专家抽象基类 }
  private
    FList: TList;
    FPopupMenu: TPopupMenu;
    FPopupAction: TCnWizAction;
    FExecuting: Boolean;
    FRefreshing: Boolean;
    procedure FreeSubMenus;
    procedure OnExecute(Sender: TObject);
    procedure OnUpdate(Sender: TObject);
    procedure OnPopup(Sender: TObject);
    function GetSubActions(Index: Integer): TCnWizMenuAction;
    function GetSubActionCount: Integer;
    function GetSubMenus(Index: Integer): TMenuItem;
  protected
    procedure OnActionUpdate(Sender: TObject); override;
    function CreateAction: TCnWizAction; override;
    procedure Click(Sender: TObject); override;
    function IndexOf(SubAction: TCnWizMenuAction): Integer;
    {* 返回指定子 Action 在列表中的索引号 }
    function RegisterASubAction(const ACommand, ACaption: string;
      AShortCut: TShortCut = 0; const AHint: string = '';
      const AIconName: string = ''): Integer;
    {* 注册一个子 Action，返回索引号。
     |<PRE>
       ACommand: string         - Action 命令字，必须为一个唯一的字符串值
       ACaption: string         - Action 的标题
       AShortCut: TShortCut     - Action 的默认快捷键，实际使用的键值会从注册表中读取
       AHint: string            - Action 的提示信息
       Result: Integer          - 返回列表中的索引号
     |</PRE> }
    procedure AddSubMenuWizard(SubMenuWiz: TCnSubMenuWizard);
    {* 为本专家挂接一个子菜单专家 }
    procedure AddSepMenu;
    {* 增加一个分隔菜单 }
    procedure DeleteSubAction(Index: Integer);
    {* 删除指定的子 Action }

    function ShowShortCutDialog(const HelpStr: string): Boolean;
    {* 显示子 Action 快捷键设置对话框 }

    procedure SubActionExecute(Index: Integer); virtual;
    {* 子菜单项执行方法，参数为子菜单的索引号，专家类重载该方法处理 Action 执行事件 }
    procedure SubActionUpdate(Index: Integer); virtual;
    {* 子菜单项更新方法，参数为子菜单的索引号，专家类重载该方法更新 Action 状态 }
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
    procedure Execute; override;
    {* 执行体什么都不做 }
    procedure AcquireSubActions; virtual;
    {* 子类重载此过程，内部调用 RegisterASubAction 创建子菜单项。
        此过程在多语切换时会被重复调用。 }
    procedure ClearSubActions;
    {* 删除所有的子 Action，包括子菜单中的分隔线 }
    procedure RefreshAction; override;
    {* 重载的刷新 Action 的方法，除了继承刷新菜单项外，还刷新子菜单 Action }
    procedure RefreshSubActions; virtual;
    {* 重新载入子 Action，子类可以重载此方法以阻止子 Action 重载 }
    property SubActionCount: Integer read GetSubActionCount;
    {* 专家子 Action 总数 }
    property SubMenus[Index: Integer]: TMenuItem read GetSubMenus;
    {* 专家的子菜单数组属性 }
    property SubActions[Index: Integer]: TCnWizMenuAction read GetSubActions;
    {* 专家的子 Action 数组属性 }
  end;

//==============================================================================
// 抽象Repository专家基类
//==============================================================================

{ TCnRepositoryWizard }

  TCnRepositoryWizard = class(TCnIconWizard, IOTARepositoryWizard)
  {* CnWizard 模板向导抽象基类 }
  protected
    FIconHandle: HICON;
    function GetName: string; override;
    {* 重载 GetName 方法，返回 WizardName 作为显示的字符串。  }
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }

    // IOTARepositoryWizard methods
    function GetPage: string;
    {$IFDEF COMPILER6_UP}
    function GetGlyph: Cardinal;
    {$ELSE}
    function GetGlyph: HICON;
    {$ENDIF}
  end;

//==============================================================================
// 单元模板向导基类
//==============================================================================

{ TCnUnitWizard }

  TCnUnitWizard = class(TCnRepositoryWizard, {$IFDEF DELPHI10_UP}IOTAProjectWizard{$ELSE}IOTAFormWizard{$ENDIF});
  {* 必须实现 IOTAFormWizard 才能在 New 对话框中出现, BDS2006 则要求 IOTAProjectWizard}

//==============================================================================
// 窗体模板向导基类
//==============================================================================

{ TCnFormWizard }

  TCnFormWizard = class(TCnRepositoryWizard, IOTAFormWizard);

//==============================================================================
// 工程模板向导基类
//==============================================================================

{ TCnProjectWizard }

  TCnProjectWizard = class(TCnRepositoryWizard, IOTAProjectWizard);

//==============================================================================
// 专家类列表相关过程
//==============================================================================

procedure RegisterCnWizard(const AClass: TCnWizardClass);
{* 注册一个 CnBaseWizard 专家类引用，每个专家实现单元应在该单元的 initialization
   节调用该过程注册专家类 }

function GetCnWizardClass(const ClassName: string): TCnWizardClass;
{* 根据专家类名取指定的专家类引用 }

function GetCnWizardClassCount: Integer;
{* 返回已注册的专家类总数 }

function GetCnWizardClassByIndex(const Index: Integer): TCnWizardClass;
{* 根据索引号取指定的专家类引用 }

function GetCnWizardTypeNameFromClass(AClass: TClass): String; 
{* 根据专家类名取专家类型名称 }

function GetCnWizardTypeName(AWizard: TCnBaseWizard): String;
{* 根据专家实例名取指定的专家类引用 }

implementation

uses
  CnWizUtils, CnWizOptions, CnCommon, CnWizCommentFrm, CnWizSubActionShortCutFrm
  {$IFDEF Debug}, CnDebug{$ENDIF Debug};

//==============================================================================
// 专家类列表相关过程
//==============================================================================

var
  CnWizardClassList: TList = nil; // 专家类引用列表

// 注册一个CnBaseWizard专家类引用
procedure RegisterCnWizard(const AClass: TCnWizardClass);
begin
  Assert(CnWizardClassList <> nil, 'CnWizardClassList is nil!');
  if CnWizardClassList.IndexOf(AClass) < 0 then
    CnWizardClassList.Add(AClass);
end;

// 根据专家类名取指定的专家类引用
function GetCnWizardClass(const ClassName: string): TCnWizardClass;
var
  i: Integer;
begin
  for i := 0 to CnWizardClassList.Count - 1 do
  begin
    Result := CnWizardClassList[i];
    if Result.ClassNameIs(ClassName) then Exit;
  end;
  Result := nil;
end;

// 返回已注册的专家类总数
function GetCnWizardClassCount: Integer;
begin
  Result := CnWizardClassList.Count;
end;

// 根据索引号取指定的专家类引用
function GetCnWizardClassByIndex(const Index: Integer): TCnWizardClass;
begin
  Result := nil;
  if (Index >= 0) and (Index <= CnWizardClassList.Count - 1) then
    Result := CnWizardClassList[Index];
end;

// 根据专家类名取专家类型名称
function GetCnWizardTypeNameFromClass(AClass: TClass): String;
begin
  if AClass.InheritsFrom(TCnProjectWizard) then
    Result := SCnProjectWizardName
  else if AClass.InheritsFrom(TCnFormWizard) then
    Result := SCnFormWizardName
  else if AClass.InheritsFrom(TCnUnitWizard) then
    Result := SCnUnitWizardName
  else if AClass.InheritsFrom(TCnRepositoryWizard) then
    Result := SCnRepositoryWizardName
  else if AClass.InheritsFrom(TCnSubMenuWizard) then
    Result := SCnSubMenuWizardName
  else if AClass.InheritsFrom(TCnMenuWizard) then
    Result := SCnMenuWizardName
  else if AClass.InheritsFrom(TCnActionWizard) then
    Result := SCnActionWizardName
  else if AClass.InheritsFrom(TCnIDEEnhanceWizard) then
    Result := SCnIDEEnhanceWizardName
  else
    Result := SCnBaseWizardName;
end;

// 根据专家实例名取指定的专家类引用
function GetCnWizardTypeName(AWizard: TCnBaseWizard): String;
begin
  Result := GetCnWizardTypeNameFromClass(AWizard.ClassType);
end;

//==============================================================================
// 专家包专家基础类
//==============================================================================

{ TCnBaseWizard }

// 类构造器
constructor TCnBaseWizard.Create;
begin
  inherited Create;
  FWizardIndex := -1;
end;

// 类析构器
destructor TCnBaseWizard.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF BCB}
class procedure TCnBaseWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin

end;
{$ENDIF BCB}

// 取专家名称
class function TCnBaseWizard.WizardName: string;
var
  Author, Email, Comment: string;
begin
  GetWizardInfo(Result, Author, Email, Comment);
end;

// 返回专家唯一标识符，供管理器使用
class function TCnBaseWizard.GetIDStr: string;
begin
  Result := RemoveClassPrefix(ClassName);
end;

// 返回专家作者
function TCnBaseWizard.GetAuthor: string;
var
  Name, Email, Comment: string;
begin
  GetWizardInfo(Name, Result, Email, Comment);
end;

// 返回专家注释
function TCnBaseWizard.GetComment: string;
var
  Name, Author, Email: string;
begin
  GetWizardInfo(Name, Author, Email, Result);
end;

// 该专家是否属于内部专家，不显示、不可配置
class function TCnBaseWizard.IsInternalWizard: Boolean;
begin
  Result := False;
end;

// 处理 Debug 输出命令并将结果放置入 Results 中，供内部调试用
procedure TCnBaseWizard.DebugComand(Cmds: TStrings; Results: TStrings);
begin
  if Results <> nil then
    Results.Add(ClassName + ' Debug Command Not Implemented.');
end;

//------------------------------------------------------------------------------
// 参数配置方法
//------------------------------------------------------------------------------

// 返回一个用于存取专家设置参数的 INI 对象，用户使用后须自己释放
class function TCnBaseWizard.CreateIniFile(CompilerSection: Boolean): TCustomIniFile;
var
  Path: string;
begin
  if CompilerSection then
    Path := MakePath(MakePath(WizOptions.RegPath) + GetIDStr) + WizOptions.CompilerID
  else
    Path := MakePath(WizOptions.RegPath) + GetIDStr;
  Result := TRegistryIniFile.Create(Path, KEY_ALL_ACCESS);
end;

procedure TCnBaseWizard.DoLoadSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
  {$IFDEF Debug}
    CnDebugger.LogMsg('Loading settings: ' + ClassName);
  {$ENDIF Debug}
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TCnBaseWizard.DoSaveSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
  {$IFDEF Debug}
    CnDebugger.LogMsg('Saving settings: ' + ClassName);
  {$ENDIF Debug}
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TCnBaseWizard.Config;
begin
  // do nothing
end;

procedure TCnBaseWizard.LanguageChanged(Sender: TObject);
begin
  // do nothing
end;

procedure TCnBaseWizard.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    ReadObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseWizard.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnBaseWizard.Loaded;
begin
  // do nothing
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// HasConfig 属性读方法
function TCnBaseWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

// Active  属性写方法
procedure TCnBaseWizard.SetActive(Value: Boolean);
begin
  FActive := Value;
end;

//------------------------------------------------------------------------------
// 必须实现的 IOTAWizard 方法
//------------------------------------------------------------------------------

{ TCnBaseWizard.IOTAWizard }

function TCnBaseWizard.GetIDString: string;
begin
  Result := SCnWizardsNamePrefix + '.' + GetIDStr;
end;

function TCnBaseWizard.GetName: string;
begin
  Result := SCnWizardsNamePrefix + ' ' + GetIDStr;
end;

function TCnBaseWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

//==============================================================================
// 带图标属性的基础类
//==============================================================================

{ TCnIconWizard }

constructor TCnIconWizard.Create;
begin
  inherited;
  FActive := True;
  FIcon := TIcon.Create;
  InitIcon(FIcon);
end;

destructor TCnIconWizard.Destroy;
begin
  inherited;
  if FIcon <> nil then
    FIcon.Free;
end;

// 返回 Icon 属性，如使用其他图标，可重载。
function TCnIconWizard.GetIcon: TIcon;
begin
  Result := FIcon;
end;

// 返回图标文件名
class function TCnIconWizard.GetIconName: string;
begin
  Result := ClassName;
end;

// 根据类名初始化图标，可重载。
procedure TCnIconWizard.InitIcon(AIcon: TIcon);
begin
  if AIcon <> nil then
    CnWizLoadIcon(FIcon, GetIconName);
end;

//==============================================================================
// 带 Action 和快捷键的抽象专家类
//==============================================================================

{ TCnActionWizard }

// 类构造器
constructor TCnActionWizard.Create;
begin
  inherited Create;
  FActive := True;
  FAction := CreateAction;
  FAction.OnUpdate := OnActionUpdate;
end;

// 类析构器
destructor TCnActionWizard.Destroy;
begin
  if Assigned(FAction) then
    WizActionMgr.DeleteAction(FAction);
  inherited Destroy;
end;

// 重新更新 Action 的内容
procedure TCnActionWizard.RefreshAction;
begin
  if FAction <> nil then
  begin
    FAction.Caption := GetCaption;
    FAction.Hint := GetHint;
  end;
end;

//------------------------------------------------------------------------------
// 虚拟方法
//------------------------------------------------------------------------------

// Action 点击事件
procedure TCnActionWizard.Click(Sender: TObject);
begin
  try
    if Active and Action.Enabled and (IsInternalWizard or
      ShowCnWizCommentForm(Self)) then
      Execute;
  except
    DoHandleException(ClassName + '.Click');
  end;
end;

// 状态更新事件
procedure TCnActionWizard.OnActionUpdate(Sender: TObject);
var
  State: TWizardState;
begin
  State := GetState;
  FAction.Visible := FActive;
  FAction.Enabled := FActive and (wsEnabled in State);
  FAction.Checked := wsChecked in State;
  // 某些情况下不允许存在快捷键，如带子菜单的菜单项
  if not EnableShortCut then
    FAction.ShortCut := 0;
end;

// 创建 Action
function TCnActionWizard.CreateAction: TCnWizAction;
begin
  Result := WizActionMgr.AddAction(GetIDStr, GetCaption, GetDefShortCut, Click,
    GetIconName, GetHint);
end;

// 取默认快捷键方法
function TCnActionWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

// 取专家是否可以用快捷键调用
function TCnActionWizard.EnableShortCut: Boolean;
begin
  Result := True;
end;

// 取Hint提示方法
function TCnActionWizard.GetHint: string;
begin
  Result := ''
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// Icon 属性读方法
function TCnActionWizard.GetIcon: TIcon;
begin
  Assert(Assigned(FAction));
  Result := FAction.Icon;
end;

// ImageIndex 属性读方法
function TCnActionWizard.GetImageIndex: Integer;
begin
  Assert(Assigned(FAction));
  Result := FAction.ImageIndex;
end;

//==============================================================================
// 带菜单的抽象专家类
//==============================================================================

{ TCnMenuWizard }

// 构造方法
constructor TCnMenuWizard.Create;
begin
  inherited;
  FMenuOrder := -1;
end;

// 设置 MenuOrder 方法
procedure TCnMenuWizard.SetMenuOrder(const Value: Integer);
begin
  FMenuOrder := Value;
end;

// 创建带菜单的 Action
function TCnMenuWizard.CreateAction: TCnWizAction;
begin
  Result := WizActionMgr.AddMenuAction(GetIDStr, GetCaption, GetIDStr, GetDefShortCut, Click,
    GetIconName, GetHint);
end;

// Action 属性读方法
function TCnMenuWizard.GetAction: TCnWizMenuAction;
begin
  Assert(inherited Action is TCnWizMenuAction);
  Result := TCnWizMenuAction(inherited Action);
end;

// Menu 属性读方法
function TCnMenuWizard.GetMenu: TMenuItem;
begin
  Assert(Assigned(Action));
  Result := Action.Menu;
end;

// 返回是否有快捷键
function TCnMenuWizard.EnableShortCut: Boolean;
begin
  Result := (Menu = nil) or (Menu.Count = 0); // 有子菜单项时不允许用快捷键调用
end;

//==============================================================================
// 带子菜单项的抽象专家类
//==============================================================================

{ TCnSubMenuWizard }

// 类构造器
constructor TCnSubMenuWizard.Create;
var
  Svcs40: INTAServices40;
begin
  inherited;
  FList := TList.Create;
  // 当该专家被放到工具栏上时，点击按钮弹出的菜单
  FPopupMenu := TPopupMenu.Create(nil);
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  FPopupMenu.Images := Svcs40.ImageList;
  // 用于关联到工具栏上按钮的 Action
  FPopupAction := WizActionMgr.AddAction(GetIDStr + '1', GetCaption, 0, OnPopup,
    GetIconName, GetHint);
  FPopupAction.OnUpdate := OnActionUpdate;
end;

// 类析构器
destructor TCnSubMenuWizard.Destroy;
begin
  ClearSubActions;
  FreeSubMenus;
  WizActionMgr.DeleteAction(FPopupAction);
  FPopupMenu.Free;
  FList.Free;
  inherited;
end;

procedure TCnSubMenuWizard.AcquireSubActions;
begin
// 基类不添加子菜单。
end;

// 创建专家 Action 项
function TCnSubMenuWizard.CreateAction: TCnWizAction;
begin
  Result := inherited CreateAction;
  Assert(Result is TCnWizMenuAction);
  Result.ActionList := nil; // 防止该 Action 被自动允许加载到 ToolBar 中
  TCnWizMenuAction(Result).Menu.ImageIndex := -1; // 带子菜单的项不显示位图
end;

// 执行体什么也不做
procedure TCnSubMenuWizard.Execute;
begin
// 执行体什么都不做
end;

// 带子菜单专家在刷新 Action 的时候，重载，顺便把子 Action 也刷新一下。
procedure TCnSubMenuWizard.RefreshAction;
begin
  inherited;
  // 刷新用于关联到工具栏上按钮的 Action
  FRefreshing := True;
  try
    if FPopupAction <> nil then
    begin
      FPopupAction.Caption := GetCaption;
      FPopupAction.Hint := GetHint;
    end;
    RefreshSubActions;
  finally
    FRefreshing := False;
  end;
end;

// 刷新子 Action ，如被重载，可不 inherited 以阻止被刷新。
procedure TCnSubMenuWizard.RefreshSubActions;
begin
//  ClearSubActions;
  AcquireSubActions;
  WizActionMgr.ArrangeMenuItems(Menu);
end;

// 登记一个子 Action，返回索引号
function TCnSubMenuWizard.RegisterASubAction(const ACommand, ACaption: string;
  AShortCut: TShortCut; const AHint: string; const AIconName: string): Integer;
var
  NewAction: TCnWizMenuAction;
  IconName: string;
  I: Integer;
begin
  if AIconName = '' then
    IconName := ACommand
  else
    IconName := AIconName;

  if FRefreshing then
  begin
    for I := 0 to FList.Count - 1 do
    begin
      if TCnWizMenuAction(FList[I]).Command = ACommand then
      begin
        TCnWizMenuAction(FList[I]).Caption := ACaption;
        TCnWizMenuAction(FList[I]).Hint := AHint;
        Result := I;
        Exit;
      end;
    end;
  end;

  NewAction := WizActionMgr.AddMenuAction(ACommand, ACaption, ACommand, AShortCut,
    OnExecute, IconName, AHint);
  NewAction.OnUpdate := OnUpdate;
  Menu.Add(NewAction.Menu);
  Result := FList.Add(NewAction);
end;

// 为本专家挂接一个子菜单专家，并返回其 Action 在列表中的索引号
procedure TCnSubMenuWizard.AddSubMenuWizard(SubMenuWiz: TCnSubMenuWizard);
begin
  // 将该子菜单专家的菜单挂入本专家菜单
  Menu.Add(SubMenuWiz.Action.Menu);
  // 一定要保存该子菜单专家的 Action，参见 ClearSubActions 中的说明
  FList.Add(SubMenuWiz.Action);
end;

// 增加一个分隔菜单
procedure TCnSubMenuWizard.AddSepMenu;
var
  SepMenu: TMenuItem;
begin
  if not FRefreshing then
  begin
    SepMenu := TMenuItem.Create(Menu);
    SepMenu.Caption := '-';
    Menu.Add(SepMenu);
  end;
end;

// 清空子 Action 列表，包括子菜单中的分隔线
procedure TCnSubMenuWizard.ClearSubActions;
var
  WizAction: TCnWizAction;
begin
  while FList.Count > 0 do
  begin
    WizAction := SubActions[0];
    // 如果该 Action 的菜单有子菜单，说明该 Action 是一个子菜单专家的 Action，
    // 删除该 Action 的工作应该留给它所属的子菜单专家，这里仅仅剥离该子菜单专家
    // 与本专家菜单之间的关联。否则该子菜单专家的 Menu.Parent 始终不为 nil，下次
    // 再将该子菜单专家挂入任何专家时都会出现菜单重复插入的异常；而且本方法后部
    // 的 Menu.Clear 将删除该子菜单专家的菜单，则子菜单专家在释放时再通过删除其
    // 子 Action 删除其子菜单时，由于子菜单已被删除，将出现 AV 异常。
    // LiuXiao: 子菜单专家会释放其 Action，父会重复释放它导致错误。
    try
      if Assigned(WizAction) and (WizAction is TCnWizMenuAction) and
        (TCnWizMenuAction(WizAction).Menu.Count > 0) then
        Menu.Remove(TCnWizMenuAction(WizAction).Menu)
      else
        WizActionMgr.DeleteAction(WizAction);
    except
      ;
    end;
    FList.Delete(0);
  end;
  Menu.Clear; // 删除子菜单中的分隔线
end;

// 删除一个子 Action
procedure TCnSubMenuWizard.DeleteSubAction(Index: Integer);
var
  WizAction: TCnWizAction;
begin
  if (Index >= 0) and (Index < FList.Count) then
  begin
    WizAction := SubActions[Index];
    // 如果该 Action 的菜单有子菜单，说明该 Action 是一个子菜单专家的 Action，
    // 删除该 Action 的工作应该留给它所属的子菜单专家，这里仅仅剥离该子菜单专家
    // 与本专家菜单之间的关联。否则该子菜单专家的 Menu.Parent 始终不为 nil，下次
    // 再将该子菜单专家挂入任何专家时都会出现菜单重复插入的异常。
    if Assigned(WizAction) and (WizAction is TCnWizMenuAction) and
      (TCnWizMenuAction(WizAction).Menu.Count > 0) then
      Menu.Remove(TCnWizMenuAction(WizAction).Menu)
    else
      WizActionMgr.DeleteAction(WizAction);
    FList.Delete(Index);
  end;
end;

// 释放菜单项
procedure TCnSubMenuWizard.FreeSubMenus;
begin
  Menu.Clear;
end;

// 返回指定子 Action 在列表中的索引号
function TCnSubMenuWizard.IndexOf(SubAction: TCnWizMenuAction): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
    if SubActions[i] = SubAction then
    begin
      Result := i;
      Exit;
    end;
end;

// 专家调用方法
procedure TCnSubMenuWizard.Click(Sender: TObject);
begin
  // 不继承调用避免显示功能提示对话框
end;

// Action 执行体
procedure TCnSubMenuWizard.OnExecute(Sender: TObject);
var
  i: Integer;
begin
  if not Active or FExecuting then Exit;
  FExecuting := True;
  try
    for i := 0 to FList.Count - 1 do
      if TObject(FList[i]) = Sender then
      begin
        // 防止通过快捷键调用无效的工具
        SubActions[i].Update;
        if SubActions[i].Enabled then
        begin
          try
            // 内部专家不提示
            if IsInternalWizard or ShowCnWizCommentForm(WizardName + ' - ' +
              GetCaptionOrgStr(SubActions[i].Caption), SubActions[i].Icon,
              SubActions[i].Command) then
              SubActionExecute(i);
          except
            DoHandleException(Format('%s.SubActions[%d].Execute',
              [ClassName, i]));
          end;
        end;

        Exit;
      end;
  finally
    FExecuting := False;
  end;
end;

// Action 更新
procedure TCnSubMenuWizard.OnUpdate(Sender: TObject);
var
  i: Integer;
begin
  OnActionUpdate(nil);
  for i := 0 to FList.Count - 1 do
    if TObject(FList[i]) = Sender then
    begin
      SubActionUpdate(i);
      Exit;
    end;
end;

// 显示快捷键设置对话框
function TCnSubMenuWizard.ShowShortCutDialog(const HelpStr: string): Boolean;
begin
  Result := SubActionShortCutConfig(Self, HelpStr);
end;

procedure TCnSubMenuWizard.OnActionUpdate(Sender: TObject);
begin
  inherited;
  FPopupAction.Visible := Action.Visible;
  FPopupAction.Enabled := Action.Enabled;
  FPopupAction.Checked := Action.Checked;
end;

procedure TCnSubMenuWizard.OnPopup(Sender: TObject);
var
  Point: TPoint;

  procedure AddMenuSubItems(SrcItem, DstItem: TMenuItem);
  var
    MenuItem, SubItem: TMenuItem;
    I, J: Integer;
  begin
    for I := 0 to SrcItem.Count - 1 do
    begin
      MenuItem := TMenuItem.Create(FPopupMenu);
      MenuItem.Action := SrcItem.Items[I].Action;
      if not Assigned(MenuItem.Action) then
        MenuItem.Caption := SrcItem.Items[I].Caption
      else if MenuItem.Action is TCnWizMenuAction then
      begin  // 添加二级子菜单
        for J := 0 to TCnWizMenuAction(MenuItem.Action).Menu.Count - 1 do
        begin
          SubItem := TMenuItem.Create(FPopupMenu);
          SubItem.Action := TCnWizMenuAction(MenuItem.Action).Menu.Items[J].Action;
          if not Assigned(SubItem.Action) then
            SubItem.Caption := TCnWizMenuAction(MenuItem.Action).Menu.Items[J].Caption;
          MenuItem.Add(SubItem);
        end;
      end;
      AddMenuSubItems(SrcItem.Items[I], MenuItem);
      DstItem.Add(MenuItem);
    end;
  end;
begin
  FPopupMenu.Items.Clear;
  AddMenuSubItems(Menu, FPopupMenu.Items);
  GetCursorPos(Point);
  FPopupMenu.Popup(Point.x, Point.y);
end;

//------------------------------------------------------------------------------
// 虚拟方法
//------------------------------------------------------------------------------

// 子菜单项执行方法，参数为子菜单的索引号
procedure TCnSubMenuWizard.SubActionExecute(Index: Integer);
begin

end;

// 子菜单项更新方法，参数为子菜单的索引号
procedure TCnSubMenuWizard.SubActionUpdate(Index: Integer);
begin
  SubActions[Index].Visible := Active;
  SubActions[Index].Enabled := Active and Action.Enabled;
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// SubActionCount 属性读方法
function TCnSubMenuWizard.GetSubActionCount: Integer;
begin
  Result := FList.Count;
end;

// SubActions 属性读方法
function TCnSubMenuWizard.GetSubActions(Index: Integer): TCnWizMenuAction;
begin
  Result := nil;
  if (Index >= 0) and (Index < FList.Count) then
    Result := TCnWizMenuAction(FList[Index]);
end;

// SubMenus 属性读方法
function TCnSubMenuWizard.GetSubMenus(Index: Integer): TMenuItem;
begin
  Result := nil;
  if (Index >= 0) and (Index < FList.Count) then
    Result := TCnWizMenuAction(FList[Index]).Menu; 
end;

//==============================================================================
// 抽象Repository专家基类
//==============================================================================

{ TCnRepositoryWizard }

// 类析构器
constructor TCnRepositoryWizard.Create;
begin
  inherited;
  FIconHandle := 0;
end;

// 类析构器
destructor TCnRepositoryWizard.Destroy;
begin
  if FIcon <> nil then
    FreeAndNil(FIcon);
//  if FIconHandle <> 0 then    // 由 IDE 释放，此处不需要释放，感谢 niaoge 的检查
//    DestroyIcon(FIconHandle);
  inherited;
end;

// 重载 GetName 方法，返回 WizardName 作为显示的字符串。
function TCnRepositoryWizard.GetName: string;
begin
  Result := WizardName;
end;

//------------------------------------------------------------------------------
// 必须实现的 IOTARepositoryWizard 方法
//------------------------------------------------------------------------------

{ TCnRepositoryWizard.IOTARepositoryWizard }

// 返回图标句柄
{$IFDEF COMPILER6_UP}
function TCnRepositoryWizard.GetGlyph: Cardinal;
{$ELSE}
function TCnRepositoryWizard.GetGlyph: HICON;
{$ENDIF}
begin
  // IDE 好象最后会清掉这个图标，如果不使用 CopyIcon 将无法正常显示，并且会
  // 把原有的图标清掉。此处的处理可保证图标正常显示，并且不会产生资源泄漏。
  DestroyIcon(FIconHandle);
  FIconHandle := CopyIcon(Icon.Handle);
  Result := FIconHandle;
end;

// 返回安装页面
function TCnRepositoryWizard.GetPage: string;
begin
  Result := SCnWizardsPage;
end;

initialization
  CnWizardClassList := TList.Create;

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnBaseWizard finalization.');
{$ENDIF Debug}

  FreeAndNil(CnWizardClassList);

{$IFDEF Debug}
  CnDebugger.LogLeave('CnBaseWizard finalization.');
{$ENDIF Debug}

end.




