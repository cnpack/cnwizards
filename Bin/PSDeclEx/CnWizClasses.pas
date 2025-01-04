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
{            网站地址：https://www.cnpack.org                                  }
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
* 修改记录：2002.09.17 V1.0
*               创建单元，实现基本功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Classes, Sysutils, Graphics, Menus, ActnList, IniFiles, ToolsAPI,
  Registry, ComCtrls, Forms, CnHashMap, CnWizIni,
  CnWizShortCut, CnWizMenuAction, CnIni, CnWizConsts, CnPopupMenu;

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
    FDefaultsMap: TCnStrToVariantHashMap;
  protected
    procedure SetActive(Value: Boolean); virtual;
    {* Active 属性写方法，子类重载该方法处理 Active 属性变更事件 }
    function GetHasConfig: Boolean; virtual;
    {* HasConfig 属性读方法，子类重载该方法返回是否存在可配置内容 }
    function GetIcon: TIcon; virtual; abstract;
    {* Icon 属性读方法，子类重载该方法返回返回专家图标，用户专家通常不需自己处理 }
    function GetBigIcon: TIcon; virtual; abstract;
    {* 大尺寸 Icon 属性读方法，子类重载该方法返回返回专家图标，用户专家通常不需自己处理 }

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
    {* 返回作者}
    function GetComment: string; virtual;
    {* 返回注释}
    function GetSearchContent: string; virtual;
    {* 返回供搜索的字符串，可以是以半角逗号分割的中英文关键词，均要求小写}
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

    procedure LaterLoaded; virtual;
    {* IDE 启动完成更迟一些后调用该方法，用于高版本 IDE 中处理 IDE 菜单项加载太迟的场合}

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
    {* 装载专家设置方法，子类重载此方法从 INI 对象中读取专家参数。
       注意此方法可能在专家一次生命周期中被调用多次，因此需要子类做好
       防止重复加载导致多余内容的问题。 }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* 保存专家设置方法，子类重载此方法将专家参数保存到 INI 对象中 }
    procedure ResetSettings(Ini: TCustomIniFile); virtual;
    {* 重置专家设置方法，子类如有 INI 对象之外的保存动作，需要重载此方法 }

    class function GetIDStr: string;
    {* 返回专家唯一标识符，供管理器使用 }
    function CreateIniFile(CompilerSection: Boolean = False): TCustomIniFile;
    {* 返回一个用于存取专家设置参数的 INI 对象，用户使用后须自己释放 }
    procedure DoLoadSettings;
    {* 装载专家设置 }
    procedure DoSaveSettings;
    {* 保存专家设置 }
    procedure DoResetSettings;
    {* 重置专家设置}

    property Active: Boolean read FActive write SetActive;
    {* 活跃属性，表明专家当前是否可用 }
    property HasConfig: Boolean read GetHasConfig;
    {* 表示专家是否存在配置界面的属性 }
    property WizardIndex: Integer read FWizardIndex write FWizardIndex;
    {* 专家注册后由 IDE 返回的索引号，在释放专家时使用，请不要修改该值 }
    property Icon: TIcon read GetIcon;
    {* 专家图标属性，大小由子类决定，比如 ActionWizard 及以下是 16x16，而 IconWizard 默认 32x32 }
    property BigIcon: TIcon read GetBigIcon;
    {* 专家大图标，如果有的话}
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
    {* 返回该类专家的图标，子类可重载此过程返回其它的 Icon 对象
       FIcon 使用系统默认尺寸，一般是 32 * 32 的}
    function GetBigIcon: TIcon; override;
    {* 返回该类专家的大图标，32 * 32 的}
    procedure InitIcon(AIcon, ASmallIcon: TIcon); virtual;
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
  {* 带 Action 和快捷键的 CnWizard 专家抽象基类，从该类起，Icon 是 16x16 }
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
    {* 返回专家的 Hint 提示 }
    function GetDefShortCut: TShortCut; virtual;
    {* 返回专家的默认快捷键，实际使用时专家的快捷键会可能由管理器来设定，这里
       只需要返回默认的就行了。 }
  public
    constructor Create; override;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }
    function GetSearchContent: string; override;
    {* 返回供搜索的字符串，把标题与 Hint 塞进去 }
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
    FPopupAction: TCnWizAction; // 用于放置到工具栏上时弹出的按钮对应的 Action，和主 Action 图标重复
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
    procedure SetActive(Value: Boolean); override;
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
    function GetSearchContent: string; override;
    {* 返回供搜索的字符串，把所有子菜单的标题与 Hint 塞进去 }
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;
    {* 调试时打印子菜单以及 Action 等的信息}
    procedure Execute; override;
    {* 执行体什么都不做 }
    function EnableShortCut: Boolean; override;
    {* 返回是否可以用快捷键调用 False }
    procedure AcquireSubActions; virtual;
    {* 子类重载此过程，内部调用 RegisterASubAction 创建子菜单项。
        此过程在多语切换时会被重复调用。 }
    procedure ClearSubActions; virtual;
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
    function ActionByCommand(const ACommand: string): TCnWizAction;
    {* 根据指定命令字查找子 Action，无则返回 nil}
  end;

//==============================================================================
// 抽象 Repository 专家基类
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
// 设计器或编辑器右键菜单执行条目的基类，子类可重载相应方法实现功能
//==============================================================================

{ TCnBaseMenuExecutor }

  TCnBaseMenuExecutor = class(TObject)
  {* 设计器或编辑器右键菜单执行条目的基类，可从属于某一专家实例}
  private
    FTag: Integer;
    FWizard: TCnBaseWizard;
  public
    constructor Create(OwnWizard: TCnBaseWizard); virtual;
    {* 类构造器 }
    destructor Destroy; override;
    {* 类析构器 }

    function GetActive: Boolean; virtual;
    {* 控制条目是否显示，调用顺序排第三}
    function GetCaption: string; virtual;
    {* 条目显示的标题，调用顺序排第一}
    function GetHint: string; virtual;
    {* 条目的提示}
    function GetEnabled: Boolean; virtual;
    {* 控制条目是否使能，调用顺序排第四}
    procedure Prepare; virtual;
    {* PrepareItem 时被调用，调用顺序排第二}
    function Execute: Boolean; virtual;
    {* 条目执行方法，基类默认什么都不做}

    property Wizard: TCnBaseWizard read FWizard;
    {* 所属 Wizard 实例}
    property Tag: Integer read FTag write FTag;
    {* 挂一个 Tag}
  end;

//==============================================================================
// 设计器或编辑器右键菜单执行条目的另一形式的基类，可用属性与事件来指定执行参数
//==============================================================================

{ TCnContextMenuExecutor }

  TCnContextMenuExecutor = class(TCnBaseMenuExecutor)
  {* 设计器或编辑器右键菜单执行条目的另一形式的基类，可用属性与事件来指定执行参数}
  private
    FActive: Boolean;
    FEnabled: Boolean;
    FCaption: string;
    FHint: string;
    FOnExecute: TNotifyEvent;
  protected
    procedure DoExecute; virtual;
  public
    constructor Create; reintroduce; virtual;

    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;

    property Caption: string read FCaption write FCaption;
    {* 条目显示的标题}
    property Hint: string read FHint write FHint;
    {* 条目显示的提示}
    property Active: Boolean read FActive write FActive;
    {* 控制条目是否显示}
    property Enabled: Boolean read FEnabled write FEnabled;
    {* 控制条目是否使能}
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    {* 条目执行方法，执行时触发}
  end;

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

function GetCnWizardTypeNameFromClass(AClass: TClass): string;
{* 根据专家类名取专家类型名称 }

function GetCnWizardTypeName(AWizard: TCnBaseWizard): string;
{* 根据专家实例名取指定的专家类引用 }

procedure GetCnWizardInfoStrs(AWizard: TCnBaseWizard; Infos: TStrings);
{* 获取专家实例的描述字符串列表，供信息输出用}

implementation

uses
  CnWizUtils, CnWizOptions, CnCommon, CnWizCommentFrm, CnWizSubActionShortCutFrm;

procedure RegisterCnWizard(const AClass: TCnWizardClass);
begin
end;

function GetCnWizardClass(const ClassName: string): TCnWizardClass;
begin
end;

function GetCnWizardClassCount: Integer;
begin
end;

function GetCnWizardClassByIndex(const Index: Integer): TCnWizardClass;
begin
end;

function GetCnWizardTypeNameFromClass(AClass: TClass): string;
begin
end;

function GetCnWizardTypeName(AWizard: TCnBaseWizard): string;
begin
end;

procedure GetCnWizardInfoStrs(AWizard: TCnBaseWizard; Infos: TStrings);
begin
end;

constructor TCnBaseWizard.Create;
begin
end;

destructor TCnBaseWizard.Destroy;
begin
end;

class procedure TCnBaseWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
end;

class function TCnBaseWizard.WizardName: string;
begin
end;

class function TCnBaseWizard.GetIDStr: string;
begin
end;

function TCnBaseWizard.GetAuthor: string;
begin
end;

function TCnBaseWizard.GetComment: string;
begin
end;

function TCnBaseWizard.GetSearchContent: string;
begin
end;

class function TCnBaseWizard.IsInternalWizard: Boolean;
begin
end;

procedure TCnBaseWizard.DebugComand(Cmds: TStrings; Results: TStrings);
begin
end;

function TCnBaseWizard.CreateIniFile(CompilerSection: Boolean): TCustomIniFile;
begin
end;

procedure TCnBaseWizard.DoLoadSettings;
begin
end;

procedure TCnBaseWizard.DoSaveSettings;
begin
end;

procedure TCnBaseWizard.DoResetSettings;
begin
end;

procedure TCnBaseWizard.Config;
begin
end;

procedure TCnBaseWizard.LanguageChanged(Sender: TObject);
begin
end;

procedure TCnBaseWizard.LoadSettings(Ini: TCustomIniFile);
begin
end;

procedure TCnBaseWizard.SaveSettings(Ini: TCustomIniFile);
begin
end;

procedure TCnBaseWizard.ResetSettings(Ini: TCustomIniFile);
begin
end;

procedure TCnBaseWizard.Loaded;
begin
end;

procedure TCnBaseWizard.LaterLoaded;
begin
end;

function TCnBaseWizard.GetHasConfig: Boolean;
begin
end;

procedure TCnBaseWizard.SetActive(Value: Boolean);
begin
end;

function TCnBaseWizard.GetIDString: string;
begin
end;

function TCnBaseWizard.GetName: string;
begin
end;

function TCnBaseWizard.GetState: TWizardState;
begin
end;

constructor TCnIconWizard.Create;
begin
end;

destructor TCnIconWizard.Destroy;
begin
end;

function TCnIconWizard.GetIcon: TIcon;
begin
end;

function TCnIconWizard.GetBigIcon: TIcon;
begin
end;

class function TCnIconWizard.GetIconName: string;
begin
end;

procedure TCnIconWizard.InitIcon(AIcon, ASmallIcon: TIcon);
begin
end;

constructor TCnActionWizard.Create;
begin
end;

destructor TCnActionWizard.Destroy;
begin
end;

procedure TCnActionWizard.RefreshAction;
begin
end;

procedure TCnActionWizard.Click(Sender: TObject);
begin
end;

procedure TCnActionWizard.OnActionUpdate(Sender: TObject);
begin
end;

function TCnActionWizard.CreateAction: TCnWizAction;
begin
end;

function TCnActionWizard.GetDefShortCut: TShortCut;
begin
end;

function TCnActionWizard.EnableShortCut: Boolean;
begin
end;

function TCnActionWizard.GetHint: string;
begin
end;

function TCnActionWizard.GetSearchContent: string;
begin
end;

function TCnActionWizard.GetIcon: TIcon;
begin
end;

function TCnActionWizard.GetImageIndex: Integer;
begin
end;

constructor TCnMenuWizard.Create;
begin
end;

procedure TCnMenuWizard.SetMenuOrder(const Value: Integer);
begin
end;

function TCnMenuWizard.CreateAction: TCnWizAction;
begin
end;

function TCnMenuWizard.GetAction: TCnWizMenuAction;
begin
end;

function TCnMenuWizard.GetMenu: TMenuItem;
begin
end;

function TCnMenuWizard.EnableShortCut: Boolean;
begin
end;

constructor TCnSubMenuWizard.Create;
begin
end;

destructor TCnSubMenuWizard.Destroy;
begin
end;

function TCnSubMenuWizard.GetSearchContent: string;
begin
end;

procedure TCnSubMenuWizard.DebugComand(Cmds: TStrings; Results: TStrings);
begin
end;

procedure TCnSubMenuWizard.AcquireSubActions;
begin
end;

function TCnSubMenuWizard.CreateAction: TCnWizAction;
begin
end;

procedure TCnSubMenuWizard.Execute;
begin
end;

function TCnSubMenuWizard.EnableShortCut: Boolean;
begin
end;

procedure TCnSubMenuWizard.RefreshAction;
begin
end;

procedure TCnSubMenuWizard.RefreshSubActions;
begin
end;

function TCnSubMenuWizard.RegisterASubAction(const ACommand, ACaption: string;
  AShortCut: TShortCut; const AHint: string; const AIconName: string): Integer;
begin
end;

procedure TCnSubMenuWizard.AddSubMenuWizard(SubMenuWiz: TCnSubMenuWizard);
begin
end;

procedure TCnSubMenuWizard.AddSepMenu;
begin
end;

procedure TCnSubMenuWizard.ClearSubActions;
begin
end;

procedure TCnSubMenuWizard.DeleteSubAction(Index: Integer);
begin
end;

procedure TCnSubMenuWizard.FreeSubMenus;
begin
end;

function TCnSubMenuWizard.IndexOf(SubAction: TCnWizMenuAction): Integer;
begin
end;

function TCnSubMenuWizard.ActionByCommand(const ACommand: string): TCnWizAction;
begin
end;

procedure TCnSubMenuWizard.Click(Sender: TObject);
begin
end;

procedure TCnSubMenuWizard.OnExecute(Sender: TObject);
begin
end;

procedure TCnSubMenuWizard.OnUpdate(Sender: TObject);
begin
end;

function TCnSubMenuWizard.ShowShortCutDialog(const HelpStr: string): Boolean;
begin
end;

procedure TCnSubMenuWizard.SetActive(Value: Boolean);
begin
end;

procedure TCnSubMenuWizard.OnActionUpdate(Sender: TObject);
begin
end;

procedure TCnSubMenuWizard.OnPopup(Sender: TObject);
begin
end;

procedure TCnSubMenuWizard.SubActionExecute(Index: Integer);
begin
end;

procedure TCnSubMenuWizard.SubActionUpdate(Index: Integer);
begin
end;

function TCnSubMenuWizard.GetSubActionCount: Integer;
begin
end;

function TCnSubMenuWizard.GetSubActions(Index: Integer): TCnWizMenuAction;
begin
end;

function TCnSubMenuWizard.GetSubMenus(Index: Integer): TMenuItem;
begin
end;

constructor TCnRepositoryWizard.Create;
begin
end;

destructor TCnRepositoryWizard.Destroy;
begin
end;

function TCnRepositoryWizard.GetName: string;
begin
end;

function TCnRepositoryWizard.GetGlyph: Cardinal;
begin
end;

function TCnRepositoryWizard.GetPage: string;
begin
end;

constructor TCnBaseMenuExecutor.Create(OwnWizard: TCnBaseWizard);
begin
end;

destructor TCnBaseMenuExecutor.Destroy;
begin
end;

procedure TCnBaseMenuExecutor.Prepare;
begin
end;

function TCnBaseMenuExecutor.Execute: Boolean;
begin
end;

function TCnBaseMenuExecutor.GetActive: Boolean;
begin
end;

function TCnBaseMenuExecutor.GetCaption: string;
begin
end;

function TCnBaseMenuExecutor.GetEnabled: Boolean;
begin
end;

function TCnBaseMenuExecutor.GetHint: string;
begin
end;

constructor TCnContextMenuExecutor.Create;
begin
end;

procedure TCnContextMenuExecutor.DoExecute;
begin
end;

function TCnContextMenuExecutor.Execute: Boolean;
begin
end;

function TCnContextMenuExecutor.GetActive: Boolean;
begin
end;

function TCnContextMenuExecutor.GetCaption: string;
begin
end;

function TCnContextMenuExecutor.GetEnabled: Boolean;
begin
end;

function TCnContextMenuExecutor.GetHint: string;
begin
end;

end.
