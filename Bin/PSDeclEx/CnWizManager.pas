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

unit CnWizManager;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizardMgr 专家管理器实现单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元为 CnWizards 框架的一部分，定义了 CnWizardMgr 专家管理器。
*           单元实现了专家 DLL 的入口导出函数，创建专家管理并初始化所有的专家。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2015.05.19 V1.3 by liuxiao
*               增加 D6 以上版本的注册设计器右键菜单执行项的机制
*           2003.10.03 V1.2 by 何清(QSoft)
*               增加专家引导工具
*           2003.08.02 V1.1
*               LiuXiao 加入 WizardCanCreate 属性。
*           2002.09.17 V1.0
*               创建单元，实现基本功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF IDE_INTEGRATE_CASTALIA}
  {$IFNDEF DELPHI101_BERLIN_UP}
    {$DEFINE CASTALIA_KEYMAPPING_CONFLICT_BUG}
  {$ENDIF}
{$ENDIF}

uses
  Windows, Messages, Classes, Graphics, Controls, Sysutils, Menus, ActnList,
  Forms, ImgList, ExtCtrls, IniFiles, Dialogs, Registry, ToolsAPI, Contnrs,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, DesignMenus,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  CnWizClasses, CnWizConsts, CnWizMenuAction
  {$IFNDEF CNWIZARDS_MINIMUM}, CnLangMgr, CnRestoreSystemMenu, CnWizIdeHooks {$ENDIF};

const
  BootShortCutKey = VK_LSHIFT; // 快捷键为 左 Shift，用户可以在启动 Delphi 时
                               // 按下该键来开启专家引导工具

  // 设置改变时通知出去，通知里放置的粗略的改变内容，
  // 包括专家使能、属性/组件编辑器使能、其他等
  CNWIZARDS_SETTING_WIZARDS_CHANGED            = 1;
  CNWIZARDS_SETTING_PROPERTY_EDITORS_CHANGED   = 2;
  CNWIZARDS_SETTING_COMPONENT_EDITORS_CHANGED  = 4;
  CNWIZARDS_SETTING_OTHERS_CHANGED             = 8;

const
  KEY_MAPPING_REG = '\Editor\Options\Known Editor Enhancements';

type

//==============================================================================
// TCnWizardMgr 主专家类
//==============================================================================

{ TCnWizardMgr }

  TCnWizardMgr = class(TNotifierObject, IOTAWizard)
  {* CnWizardMgr 专家管理器类，用于维护专家列表。
     请不要直接创建该类的实例，该类的实例在专家 DLL 注册时自动创建，请使用全局
     变量 CnWizardMgr 来访问管理器实例。}
  private
{$IFNDEF CNWIZARDS_MINIMUM}
    FRestoreSysMenu: TCnRestoreSystemMenu;
{$ENDIF}
    FMenu: TMenuItem;
    FToolsMenu: TMenuItem;
    FWizards: TList;
    FMenuWizards: TList;
    FIDEEnhanceWizards: TList;
    FRepositoryWizards: TList;
    FTipTimer: TTimer;
    FLaterLoadTimer: TTimer;
    FSepMenu: TMenuItem;
    FConfigAction: TCnWizMenuAction;
    FWizMultiLang: TCnMenuWizard;
    FWizAbout: TCnMenuWizard;
    FOffSet: array[0..3] of Integer;
    FSettingsLoaded: Boolean;
  {$IFDEF BDS}
    FSplashBmp: TBitmap;
    FAboutBmp: TBitmap;
  {$ENDIF}
    procedure DoLaterLoad(Sender: TObject);
    procedure DoFreeLaterLoadTimer(Sender: TObject);

    procedure CreateIDEMenu;
    procedure InstallIDEMenu;
    procedure FreeMenu;
    procedure InstallWizards;
    procedure FreeWizards;
    procedure CreateMiscMenu;
    procedure InstallMiscMenu;
    procedure EnsureNoParent(Menu: TMenuItem);
    procedure FreeMiscMenu;

    procedure RegisterPluginInfo;
    procedure InternalCreate;
    procedure InstallPropEditors;
    procedure InstallCompEditors;
    procedure SetTipShowing;
    procedure ShowTipofDay(Sender: TObject);
    procedure CheckIDEVersion;
{$IFNDEF CNWIZARDS_MINIMUM}
{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}
    procedure CheckKeyMappingEnhModulesSequence;
{$ENDIF}
{$ENDIF}
    function GetWizards(Index: Integer): TCnBaseWizard;
    function GetWizardCount: Integer;
    function GetMenuWizardCount: Integer;
    function GetMenuWizards(Index: Integer): TCnMenuWizard;
    function GetRepositoryWizardCount: Integer;
    function GetRepositoryWizards(Index: Integer): TCnRepositoryWizard;
    procedure OnConfig(Sender: TObject);
    procedure OnIdleLoaded(Sender: TObject);
    procedure OnFileNotify(NotifyCode: TOTAFileNotification; const FileName: string);
    function GetIDEEnhanceWizardCount: Integer;
    function GetIDEEnhanceWizards(Index: Integer): TCnIDEEnhanceWizard;
    function GetWizardCanCreate(WizardClassName: string): Boolean;
    procedure SetWizardCanCreate(WizardClassName: string;
      const Value: Boolean);
    function GetOffSet(Index: Integer): Integer;
  public
    constructor Create;
    {* 类构造器}
    destructor Destroy; override;
    {* 类析构器}

    // IOTAWizard methods
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;

    procedure LoadSettings;
    {* 装载所有专家的设置}
    procedure SaveSettings;
    {* 保存所有专家的设置}
    procedure ConstructSortedMenu;
    {* 重建排序后的菜单 }
    procedure UpdateMenuPos(UseToolsMenu: Boolean);
    {* 重新设置主菜单的位置，判断在主菜单栏还是 Tools 下 }
    procedure RefreshLanguage;
    {* 重新读入专家的各种语言字符串，包括 Action 标题 }
    procedure ChangeWizardLanguage;
    {* 触发专家的语言改变事件，设置专家的语言 }
    function WizardByName(const WizardName: string): TCnBaseWizard;
    {* 根据专家名称返回专家实例，如果找不到专家，返回为 nil}
    function WizardByClass(AClass: TCnWizardClass): TCnBaseWizard;
    {* 根据专家类名返回专家实例，如果找不到专家，返回为 nil}
    function WizardByClassName(const AClassName: string): TCnBaseWizard;
    {* 根据专家类名字符串返回专家实例，如果找不到专家，返回为 nil}
    function ImageIndexByClassName(const AClassName: string): Integer;
    {* 根据专家类名字符串返回专家的图标索引，如果找不到专家或无图标索引，返回为 -1}
    function ActionByWizardClassNameAndCommand(const AClassName: string;
      const ACommand: string): TCnWizAction;
    {* 根据专家类名字符串与命令字返回该子菜单专家的指定子 Action，无则返回 nil}
    function ImageIndexByWizardClassNameAndCommand(const AClassName: string;
      const ACommand: string): Integer;
    {* 根据专家类名字符串与命令字返回该子菜单专家的指定子 Action 的 ImageIndex，无则返回 -1}
    function IndexOf(Wizard: TCnBaseWizard): Integer;
    {* 根据专家实例查找其在专家列表中的索引号}
    procedure DispatchDebugComand(Cmd: string; Results: TStrings);
    {* 分发处理 Debug 输出命令并将结果放置入 Results 中，供内部调试用}
    property Menu: TMenuItem read FMenu;
    {* 插入到 IDE 主菜单中的菜单项}
    property WizardCount: Integer read GetWizardCount;
    {* TCnBaseWizard 及其子类专家的总数，包含了所有的专家}
    property MenuWizardCount: Integer read GetMenuWizardCount;
    {* TCnMenuWizard 菜单专家及其子类的总数}
    property IDEEnhanceWizardCount: Integer read GetIDEEnhanceWizardCount;
    {* TCnIDEEnhanceWizard 专家及其子类的总数}
    property RepositoryWizardCount: Integer read GetRepositoryWizardCount;
    {* TCnRepositoryWizard 模板向导专家及其子类的总数}
    property Wizards[Index: Integer]: TCnBaseWizard read GetWizards; default;
    {* 专家数组，包含了管理器维护的所有专家}
    property MenuWizards[Index: Integer]: TCnMenuWizard read GetMenuWizards;
    {* 菜单专家数组，包含了 TCnMenuWizard 及其子类专家}
    property IDEEnhanceWizards[Index: Integer]: TCnIDEEnhanceWizard
      read GetIDEEnhanceWizards;
    {* IDE 功能扩展专家数组，包含了 TCnIDEEnhanceWizard 及其子类专家}
    property RepositoryWizards[Index: Integer]: TCnRepositoryWizard
      read GetRepositoryWizards;
    {* 模板向导专家数组，包含了 TCnRepositoryWizard 及其子类专家}

    property WizardCanCreate[WizardClassName: string]: Boolean read GetWizardCanCreate
      write SetWizardCanCreate;
    {* 指定专家是否创建 }
    property OffSet[Index: Integer]: Integer read GetOffSet;
  end;

{$IFDEF COMPILER6_UP}

  TCnDesignSelectionManager = class(TBaseSelectionEditor, ISelectionEditor)
  {* 设计器右键菜单执行项目管理器}
  public
    procedure ExecuteVerb(Index: Integer; const List: IDesignerSelections);
    function GetVerb(Index: Integer): string;
    function GetVerbCount: Integer;
    procedure PrepareItem(Index: Integer; const AItem: IMenuItem);
    procedure RequiresUnits(Proc: TGetStrProc);
  end;

{$ENDIF}

var
  CnWizardMgr: TCnWizardMgr = nil;
  {* TCnWizardMgr 主专家实例}

  InitSplashProc: TProcedure = nil;
  {* 处理封面窗口图片等内容的外挂模块}

procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
{* 注册一个设计器右键菜单的执行对象实例，应该在专家创建时注册
  注意此方法调用后，Executor 便由此处统一管理并负责释放，请勿外部先行释放它}

procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
{* 注册一个设计器右键菜单的执行对象实例的另一形式}

procedure UnRegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
{* 反注册一个设计器右键菜单的执行对象实例，反注册后 Executor 被自动释放}

procedure UnRegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
{* 反注册一个设计器右键菜单的执行对象实例的另一形式，反注册后 Executor 被自动释放}

procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
{* 注册一个编辑器右键菜单的执行对象实例，应该在专家创建时注册}

procedure UnRegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
{* 反注册一个编辑器右键菜单的执行对象实例，反注册后 Executor 被自动释放}

function GetEditorMenuExecutorCount: Integer;
{* 返回已注册的编辑器右键菜单条目数量，供编辑器扩展实现自定义编辑器菜单用}

function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
{* 返回已注册的编辑器右键菜单条目，供编辑器扩展实现自定义编辑器菜单用}

function GetCnWizardMgr: TCnWizardMgr;
{* 封装的返回 TCnWizardMgr 主专家实例的函数，主要给脚本专家使用}

implementation

uses
{$IFDEF DEBUG}
  CnDebug, 
{$ENDIF}
  CnWizUtils, CnWizOptions, CnWizShortCut, CnCommon,
{$IFNDEF CNWIZARDS_MINIMUM}
  CnWizConfigFrm, CnWizAbout, CnWizShareImages,
  CnWizUpgradeFrm, CnDesignEditor, CnWizMultiLang, CnWizBoot,
  CnWizCommentFrm, CnWizTranslate, CnWizTipOfDayFrm, CnIDEVersion,
{$ENDIF}
  CnWizNotifier, CnWizCompilerConst;

function GetCnWizardMgr: TCnWizardMgr;
begin
end;

procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
begin
end;

procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
begin
end;

procedure UnRegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
begin
end;

procedure UnRegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
begin
end;

procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
begin
end;

procedure UnRegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
begin
end;

function GetEditorMenuExecutorCount: Integer;
begin
end;

function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
begin
end;

procedure TCnWizardMgr.InternalCreate;
begin
end;

procedure TCnWizardMgr.RegisterPluginInfo;
begin
end;

procedure TCnWizardMgr.DoFreeLaterLoadTimer(Sender: TObject);
begin
end;

procedure TCnWizardMgr.DoLaterLoad(Sender: TObject);
begin
end;

constructor TCnWizardMgr.Create;
begin
end;

destructor TCnWizardMgr.Destroy;
begin
end;

procedure TCnWizardMgr.CreateIDEMenu;
begin
end;

procedure TCnWizardMgr.InstallIDEMenu;
begin
end;

procedure TCnWizardMgr.RefreshLanguage;
begin
end;

procedure TCnWizardMgr.ChangeWizardLanguage;
begin
end;

procedure TCnWizardMgr.CreateMiscMenu;
begin
end;

procedure TCnWizardMgr.ConstructSortedMenu;
begin
end;

procedure TCnWizardMgr.UpdateMenuPos(UseToolsMenu: Boolean);
begin
end;

function TCnWizardMgr.GetIDEEnhanceWizardCount: Integer;
begin
end;

function TCnWizardMgr.GetIDEEnhanceWizards(Index: Integer): TCnIDEEnhanceWizard;
begin
end;

function TCnWizardMgr.WizardByClass(AClass: TCnWizardClass): TCnBaseWizard;
begin
end;

function TCnWizardMgr.WizardByClassName(const AClassName: string): TCnBaseWizard;
begin
end;

function TCnWizardMgr.ImageIndexByClassName(const AClassName: string): Integer;
begin
end;

function TCnWizardMgr.ActionByWizardClassNameAndCommand(const AClassName: string;
  const ACommand: string): TCnWizAction;
begin
end;

function TCnWizardMgr.ImageIndexByWizardClassNameAndCommand(const AClassName: string;
  const ACommand: string): Integer;
begin
end;

function TCnWizardMgr.IndexOf(Wizard: TCnBaseWizard): Integer;
begin
end;

function TCnWizardMgr.WizardByName(const WizardName: string): TCnBaseWizard;
begin
end;

procedure TCnWizardMgr.FreeMenu;
begin
end;

procedure TCnWizardMgr.InstallWizards;
begin
end;

function TCnWizardMgr.GetOffSet(Index: Integer): Integer;
begin
end;

procedure TCnWizardMgr.FreeWizards;
begin
end;

procedure TCnWizardMgr.LoadSettings;
begin
end;

procedure TCnWizardMgr.SaveSettings;
begin
end;

procedure TCnWizardMgr.EnsureNoParent(Menu: TMenuItem);
begin
end;

procedure TCnWizardMgr.InstallMiscMenu;
begin
end;

procedure TCnWizardMgr.FreeMiscMenu;
begin
end;

procedure TCnWizardMgr.InstallCompEditors;
begin
end;

procedure TCnWizardMgr.InstallPropEditors;
begin
end;

procedure TCnWizardMgr.SetTipShowing;
begin
end;

procedure TCnWizardMgr.ShowTipofDay(Sender: TObject);
begin
end;

procedure TCnWizardMgr.CheckIDEVersion;
begin
end;

procedure TCnWizardMgr.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
end;

procedure TCnWizardMgr.OnIdleLoaded(Sender: TObject);
begin
end;

procedure TCnWizardMgr.OnConfig(Sender: TObject);
begin
end;

function TCnWizardMgr.GetWizardCount: Integer;
begin
end;

function TCnWizardMgr.GetWizards(Index: Integer): TCnBaseWizard;
begin
end;

function TCnWizardMgr.GetMenuWizardCount: Integer;
begin
end;

function TCnWizardMgr.GetMenuWizards(Index: Integer): TCnMenuWizard;
begin
end;

function TCnWizardMgr.GetRepositoryWizardCount: Integer;
begin
end;

function TCnWizardMgr.GetRepositoryWizards(
  Index: Integer): TCnRepositoryWizard;
begin
end;

function TCnWizardMgr.GetWizardCanCreate(WizardClassName: string): Boolean;
begin
end;

procedure TCnWizardMgr.SetWizardCanCreate(WizardClassName: string;
  const Value: Boolean);
begin
end;

procedure TCnWizardMgr.DispatchDebugComand(Cmd: string; Results: TStrings);
begin
end;

procedure TCnWizardMgr.Execute;
begin
end;

function TCnWizardMgr.GetIDString: string;
begin
end;

function TCnWizardMgr.GetName: string;
begin
end;

function TCnWizardMgr.GetState: TWizardState;
begin
end;

procedure TCnWizardMgr.CheckKeyMappingEnhModulesSequence;
begin
end;

procedure TCnDesignSelectionManager.ExecuteVerb(Index: Integer;
  const List: IDesignerSelections);
begin
end;

function TCnDesignSelectionManager.GetVerb(Index: Integer): string;
begin
end;

function TCnDesignSelectionManager.GetVerbCount: Integer;
begin
end;

procedure TCnDesignSelectionManager.PrepareItem(Index: Integer;
  const AItem: IMenuItem);
begin
end;

procedure TCnDesignSelectionManager.RequiresUnits(Proc: TGetStrProc);
begin
end;

end.
