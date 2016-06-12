{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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
* 单元标识：$Id$
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
  CnRestoreSystemMenu,
  CnWizClasses, CnWizConsts, CnWizMenuAction, CnLangMgr, CnWizIdeHooks;

const
  BootShortCutKey = VK_LSHIFT; // 快捷键为 左 Shift，用户可以在启动 Delphi 时
                               // 按下该键来开启专家引导工具

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
    FRestoreSysMenu: TCnRestoreSystemMenu;
    FMenu: TMenuItem;
    FToolsMenu: TMenuItem;
    FWizards: TList;
    FMenuWizards: TList;
    FIDEEnhanceWizards: TList;
    FRepositoryWizards: TList;
    FTipTimer: TTimer;
    FSepMenu: TMenuItem;
    FConfigAction: TCnWizMenuAction;
    FWizMultiLang: TCnMenuWizard;
    FWizAbout: TCnMenuWizard;
    FOffSet: array[0..3] of Integer;
    FSettingsLoaded: Boolean;
    FMainFormOnShow: TNotifyEvent;
  {$IFDEF BDS}
    FSplashBmp: TBitmap;
    FAboutBmp: TBitmap;
  {$ENDIF}
    procedure InstallMainFormOnShowHook;
    procedure OnMainFormOnShow(Sender: TObject);
    procedure DoLaterLoad(Sender: TObject);

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
{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}
    procedure CheckKeyMappingEnhModulesSequence;
{$ENDIF}
    function GetWizards(Index: Integer): TCnBaseWizard;
    function GetWizardCount: Integer;
    function GetMenuWizardCount: Integer;
    function GetMenuWizards(Index: Integer): TCnMenuWizard;
    function GetRepositoryWizardCount: Integer;
    function GetRepositoryWizards(Index: Integer): TCnRepositoryWizard;
    procedure OnConfig(Sender: TObject);
    procedure OnIdeLoaded(Sender: TObject);
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
    function WizardByClassName(AClassName: string): TCnBaseWizard;
    {* 根据专家类名字符串返回专家实例，如果找不到专家，返回为 nil}
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
  CnWizardMgr: TCnWizardMgr;
  {* TCnWizardMgr 主专家实例}

  InitSplashProc: TProcedure = nil;
  {* 处理封面窗口图片等内容的外挂模块}

procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
{* 注册一个设计器右键菜单的执行对象实例，应该在专家创建时注册
  注意此方法调用后，Executor 便由此处统一管理并负责释放，请勿外部先行释放它}

procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
{* 注册一个设计器右键菜单的执行对象实例的另一形式}

procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
{* 注册一个编辑器右键菜单的执行对象实例，应该在专家创建时注册}

function GetEditorMenuExecutorCount: Integer;
{* 返回已注册的编辑器右键菜单条目数量，供编辑器扩展实现自定义编辑器菜单用}

function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
{* 返回已注册的编辑器右键菜单条目，供编辑器扩展实现自定义编辑器菜单用}

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

const
  csCnWizFreeMutex = 'CnWizFreeMutex';
  csMaxWaitFreeTick = 5000;

var
  CnDesignExecutorList: TObjectList = nil; // 设计器右键菜单执行对象列表

  CnEditorExecutorList: TObjectList = nil; // 编辑器右键菜单执行对象列表

// 注册一个设计器右键菜单的执行对象实例，应该在专家创建时注册
procedure RegisterBaseDesignMenuExecutor(Executor: TCnBaseMenuExecutor);
begin
  Assert(CnDesignExecutorList <> nil, 'CnDesignExecutorList is nil!');
  if CnDesignExecutorList.IndexOf(Executor) < 0 then
    CnDesignExecutorList.Add(Executor);
end;

// 注册一个设计器右键菜单的执行对象实例的另一形式
procedure RegisterDesignMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  RegisterBaseDesignMenuExecutor(Executor);
end;

// 注册一个编辑器右键菜单的执行对象实例，应该在专家创建时注册
procedure RegisterEditorMenuExecutor(Executor: TCnContextMenuExecutor);
begin
  Assert(CnEditorExecutorList <> nil, 'CnEditorExecutorList is nil!');
  if CnEditorExecutorList.IndexOf(Executor) < 0 then
    CnEditorExecutorList.Add(Executor);
end;

// 返回已注册的编辑器右键菜单条目数量，供编辑器扩展实现自定义编辑器菜单用
function GetEditorMenuExecutorCount: Integer;
begin
  Result := CnEditorExecutorList.Count;
end;

// 返回已注册的编辑器右键菜单条目，供编辑器扩展实现自定义编辑器菜单用
function GetEditorMenuExecutor(Index: Integer): TCnContextMenuExecutor;
begin
  Result := TCnContextMenuExecutor(CnEditorExecutorList[Index]);
end;

//==============================================================================
// TCnWizardMgr 主专家类
//==============================================================================

{ TCnWizardMgr }

procedure TCnWizardMgr.InternalCreate;
begin
  FWizards := TList.Create;
  FMenuWizards := TList.Create;
  FIDEEnhanceWizards := TList.Create;
  FRepositoryWizards := TList.Create;
{$IFNDEF CNWIZARDS_MINIMUM}
  dmCnSharedImages := TdmCnSharedImages.Create(nil);
{$ENDIF}

{$IFDEF BDS}
  FSplashBmp := TBitmap.Create;
  CnWizLoadBitmap(FSplashBmp, SCnSplashBmp);
  FAboutBmp := TBitmap.Create;
  CnWizLoadBitmap(FAboutBmp, SCnAboutBmp);
{$ENDIF}
  RegisterPluginInfo;

{$IFNDEF CNWIZARDS_MINIMUM}
  CheckIDEVersion;
{$ENDIF}

  CreateIDEMenu;

  InstallWizards;

  LoadSettings;

  // 根据 MenuOrder 来进行排序然后插入菜单
  CreateMiscMenu;

  // 创建完菜单项后再插入到 IDE 中，以解决 D7 下菜单点需要点击才能下拉的问题
  InstallIDEMenu;

  InstallPropEditors;
  InstallCompEditors;

{$IFNDEF CNWIZARDS_MINIMUM}
  // 重刷新语言条目，与语言改变时的处理类似。
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil) then
  begin
    // 注意，无需 Languages 条目存在，由被调用者判断。当前语言索引可为 -1
    RefreshLanguage;
    ChangeWizardLanguage;
    CnDesignEditorMgr.LanguageChanged(CnLanguageManager);
  end;
{$ENDIF}

  // 文件通知
  CnWizNotifierServices.AddFileNotifier(OnFileNotify);

  // IDE 启动完成后调用 Loaded
  CnWizNotifierServices.ExecuteOnApplicationIdle(OnIdeLoaded);
end;

// BDS 下注册插件产品信息
procedure TCnWizardMgr.RegisterPluginInfo;
{$IFDEF BDS}
var
  AboutSvcs: IOTAAboutBoxServices;
{$ENDIF}
begin
{$IFDEF BDS}
  if Assigned(SplashScreenServices) then
  begin
    SplashScreenServices.AddPluginBitmap(SCnWizardCaption, FSplashBmp.Handle);
  end;

  if QuerySvcs(BorlandIDEServices, IOTAAboutBoxServices, AboutSvcs) then
  begin
    AboutSvcs.AddPluginInfo(SCnWizardCaption, SCnWizardDesc, FAboutBmp.Handle,
      False, SCnWizardLicense);
  end;
{$ENDIF}
end;


procedure TCnWizardMgr.InstallMainFormOnShowHook;
begin
  FMainFormOnShow := Application.MainForm.OnShow;
  Application.MainForm.OnShow := OnMainFormOnShow;
end;

procedure TCnWizardMgr.OnMainFormOnShow(Sender: TObject);
begin
  Application.MainForm.OnShow := FMainFormOnShow;
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoLaterLoad);
end;

procedure TCnWizardMgr.DoLaterLoad(Sender: TObject);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('DoLaterLoad');
{$ENDIF}

  for I := 0 to WizardCount - 1 do
  try
    Wizards[I].LaterLoaded;
  except
    DoHandleException(Wizards[I].ClassName + '.OnLaterLoad');
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('DoLaterLoad');
{$ENDIF}
end;

// 类构造器
constructor TCnWizardMgr.Create;
begin
{$IFDEF Debug}
  CnDebugger.LogEnter('TCnWizardMgr.Create');
{$ENDIF}
  inherited Create;
  
  // 让专家可以在 Create 和其他过程中能够访问 CnWizardMgr 中的其他属性。
  CnWizardMgr := Self;
  WizOptions := TCnWizOptions.Create;
  // 处理封面窗口
  if @InitSplashProc <> nil then
    InitSplashProc();

{$IFNDEF CNWIZARDS_MINIMUM}
  // 提前初始化多语
  CreateLanguageManager;
  if CnLanguageManager <> nil then
    InitLangManager;

  CnTranslateConsts(nil);

{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}
  CheckKeyMappingEnhModulesSequence;
{$ENDIF}
{$ENDIF}

  InstallMainFormOnShowHook;

  WizShortCutMgr.BeginUpdate;
  CnListBeginUpdate;
  try
    InternalCreate;
  finally
    CnListEndUpdate;
    WizShortCutMgr.EndUpdate;
  end;
  
  ConstructSortedMenu;

  FRestoreSysMenu := TCnRestoreSystemMenu.Create(nil);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.Create');
  CnDebugger.LogSeparator;
{$ENDIF}
end;

// 类析构器
destructor TCnWizardMgr.Destroy;
var
  hMutex: THandle;
begin
{$IFDEF DEBUG}
  CnDebugger.LogSeparator;
  CnDebugger.LogEnter('TCnWizardMgr.Destroy');
{$ENDIF}

  // 防止多个IDE实例同时释放时保存设置冲突
  hMutex := CreateMutex(nil, False, csCnWizFreeMutex);
{$IFDEF DEBUG}
  if GetLastError = ERROR_ALREADY_EXISTS then
    CnDebugger.LogMsg('Waiting for another instance');
{$ENDIF}
  WaitForSingleObject(hMutex, csMaxWaitFreeTick);

  try
    // 防止意外中断时保存无效的设置
    if FSettingsLoaded then
      SaveSettings;

    CnWizNotifierServices.RemoveFileNotifier(OnFileNotify);

    WizShortCutMgr.BeginUpdate;
    try
      FreeMiscMenu;
      FreeWizards;
    finally
      WizShortCutMgr.EndUpdate;
    end;

    FreeMenu;
{$IFNDEF CNWIZARDS_MINIMUM}
    FreeAndNil(dmCnSharedImages);
{$ENDIF}
  {$IFDEF BDS}
    FreeAndNil(FSplashBmp);
    FreeAndNil(FAboutBmp);
  {$ENDIF}

    FreeAndNil(FRepositoryWizards);
    FreeAndNil(FIDEEnhanceWizards);
    FreeAndNil(FMenuWizards);
    FreeAndNil(FWizards);
    FreeWizActionMgr;
    FreeWizShortCutMgr;
    FreeAndNil(WizOptions);
    FreeAndNil(FTipTimer);
    FreeAndNil(FRestoreSysMenu);
    inherited Destroy;
  finally
    if hMutex <> 0 then
    begin
      ReleaseMutex(hMutex);
      CloseHandle(hMutex);
    end;
  end;          

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.Destroy');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 专家设置相关方法
//------------------------------------------------------------------------------

// 创建专家包菜单项
procedure TCnWizardMgr.CreateIDEMenu;
begin
  FMenu := TMenuItem.Create(nil);
  Menu.Name := SCnWizardsMenuName;
  Menu.Caption := SCnWizardsMenuCaption;
  Menu.AutoHotkeys := maManual;
end;

// 安装 IDE 菜单项
procedure TCnWizardMgr.InstallIDEMenu;
var
  MainMenu: TMainMenu;
begin
  MainMenu := GetIDEMainMenu; // IDE主菜单
  if MainMenu <> nil then
  begin
    FToolsMenu := GetIDEToolsMenu;
    if WizOptions.UseToolsMenu and Assigned(FToolsMenu) then
      FToolsMenu.Insert(0, Menu)
    else if Assigned(FToolsMenu) then // 新菜单插在 Tools 菜单后面
      MainMenu.Items.Insert(MainMenu.Items.IndexOf(FToolsMenu) + 1, Menu)
    else
      MainMenu.Items.Add(Menu);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Install menu succeed');
  {$ENDIF}
  end;
end;

// 重新读入专家的各种语言字符串，包括 Action 标题
procedure TCnWizardMgr.RefreshLanguage;
var
  i: Integer;
begin
  FConfigAction.Caption := SCnWizConfigCaption;
  FConfigAction.Hint := SCnWizConfigHint;
  FWizAbout.RefreshAction;
  
  WizActionMgr.MoreAction.Caption := SCnMoreMenu;
  WizActionMgr.MoreAction.Hint := StripHotkey(SCnMoreMenu);
  
  for i := 0 to WizardCount - 1 do
    if Wizards[i] is TCnActionWizard then
      TCnActionWizard(Wizards[i]).RefreshAction;
end;

// 调用专家的语言改变事件，由专家自己处理语言变化
procedure TCnWizardMgr.ChangeWizardLanguage;
var
  i: Integer;
begin
  for i := 0 to WizardCount - 1 do
    Wizards[i].LanguageChanged(CnLanguageManager);
end;

// 创建其他菜单项
procedure TCnWizardMgr.CreateMiscMenu;
begin
  FSepMenu := TMenuItem.Create(nil);
  FSepMenu.Caption := '-';
  FConfigAction := WizActionMgr.AddMenuAction(SCnWizConfigCommand, SCnWizConfigCaption,
    SCnWizConfigMenuName, 0, OnConfig, SCnWizConfigIcon, SCnWizConfigHint);
{$IFNDEF CNWIZARDS_MINIMUM}
  FWizMultiLang := TCnWizMultiLang.Create;
  FWizAbout := TCnWizAbout.Create;
{$ENDIF}
end;

// 根据菜单专家列表和父菜单项重建菜单。
procedure TCnWizardMgr.ConstructSortedMenu;
var
  List: TList;
  I: Integer;
begin
  if (FMenuWizards = nil) or (Menu = nil) then Exit;

  List := TList.Create;
  try
    for I := 0 to FMenuWizards.Count - 1 do
    begin
      List.Add(FMenuWizards.Items[I]);
      EnsureNoParent(TCnMenuWizard(FMenuWizards.Items[I]).Menu);
    end;

    for I := Menu.Count - 1 downto 0 do
      Menu.Delete(I);

    SortListByMenuOrder(List);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ConstructSortedMenu. Before Insert: %d', [Menu.Count]);
{$ENDIF}

    for I := 0 to List.Count - 1 do
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('ConstructSortedMenu. Insert %s', [TCnMenuWizard(List.Items[I]).Menu.Caption]);
{$ENDIF}
      Menu.Add(TCnMenuWizard(List.Items[I]).Menu);
    end;  

    InstallMiscMenu;
  finally
    List.Free;
  end;

  WizActionMgr.ArrangeMenuItems(Menu);
end;

procedure TCnWizardMgr.UpdateMenuPos(UseToolsMenu: Boolean);
var
  MainMenu: TMainMenu;
  Svcs40: INTAServices40;
begin
  if FToolsMenu <> nil then
  begin
    if not QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40) then
      Exit;

    MainMenu := Svcs40.MainMenu; // IDE主菜单
    if UseToolsMenu then
    begin
      MainMenu.Items.Remove(FMenu);
      FToolsMenu.Insert(0, FMenu);
    end
    else
    begin
      FToolsMenu.Remove(FMenu);
      MainMenu.Items.Insert(FToolsMenu.MenuIndex + 1, FMenu);
    end;
  end;
end;

// 返回 TCnIDEEnhanceWizard 专家及其子类的总数
function TCnWizardMgr.GetIDEEnhanceWizardCount: Integer;
begin
  Result := FIDEEnhanceWizards.Count;
end;

// 取指定的 IDE 功能扩展专家
function TCnWizardMgr.GetIDEEnhanceWizards(Index: Integer): TCnIDEEnhanceWizard;
begin
  if (Index >= 0) and (Index <= FIDEEnhanceWizards.Count - 1) then
    Result := TCnIDEEnhanceWizard(FIDEEnhanceWizards[Index])
  else
    Result := nil;
end;

// 根据专家类名返回专家实例，如果找不到专家，返回为 nil
function TCnWizardMgr.WizardByClass(AClass: TCnWizardClass): TCnBaseWizard;
var
  i: Integer;
begin
  for i := 0 to WizardCount - 1 do
    if Wizards[i] is AClass then
    begin
      Result := Wizards[i];
      Exit;
    end;
  Result := nil;
end;

function TCnWizardMgr.WizardByClassName(AClassName: string): TCnBaseWizard;
var
  i: Integer;
begin
  for i := 0 to WizardCount - 1 do
    if Wizards[i].ClassNameIs(AClassName) then
    begin
      Result := Wizards[i];
      Exit;
    end;
  Result := nil;
end;

// 根据专家实例查找其在专家列表中的索引号
function TCnWizardMgr.IndexOf(Wizard: TCnBaseWizard): Integer;
var
  I: Integer;
begin
  for I := 0 to WizardCount - 1 do
    if Wizards[I] = Wizard then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

// 根据专家名称返回专家实例，如果找不到专家，返回为 nil
function TCnWizardMgr.WizardByName(const WizardName: string): TCnBaseWizard;
var
  i: Integer;
begin
  for i := 0 to WizardCount - 1 do
    if SameText(Wizards[i].WizardName, WizardName) then
    begin
      Result := Wizards[i];
      Exit;
    end;
  Result := nil;
end;

// 释放菜单项
procedure TCnWizardMgr.FreeMenu;
begin
  if Menu <> nil then
  begin
    while Menu.Count > 0 do
      Menu[0].Free;
    FreeAndNil(FMenu);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Free menu succeed');
{$ENDIF}
  end;
end;

// 安装专家列表
procedure TCnWizardMgr.InstallWizards;
var
  i: Integer;
  Wizard: TCnBaseWizard;
  MenuWizard: TCnMenuWizard;
  IDEEnhanceWizard: TCnIDEEnhanceWizard;
  RepositoryWizard: TCnRepositoryWizard;
  WizardSvcs: IOTAWizardServices;
{$IFNDEF CNWIZARDS_MINIMUM}
  frmBoot: TCnWizBootForm;
  KeyState: TKeyboardState;
{$ENDIF}
  bUserBoot: boolean;
  BootList: array of boolean;
begin
  if not QuerySvcs(BorlandIDEServices, IOTAWizardServices, WizardSvcs) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('Query IOTAWizardServices fail', cmtError);
  {$ENDIF}
    Exit;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin installing wizards');
{$ENDIF}

  bUserBoot := False;

{$IFNDEF CNWIZARDS_MINIMUM}
  GetKeyboardState(KeyState);

  if (KeyState[BootShortCutKey] and $80 <> 0) or // 是否由用户引导专家
    FindCmdLineSwitch(SCnShowBootFormSwitch, ['/', '-'], True) then
  begin
    frmBoot := TCnWizBootForm.Create(Application);
    try
      if frmBoot.ShowModal = mrOK then
      begin
        bUserBoot := True;
        SetLength(BootList, GetCnWizardClassCount);
        frmBoot.GetBootList(BootList);
      end;
    finally
      frmBoot.Free;
    end;
  end;
{$ENDIF}

  for i := 0 to GetCnWizardClassCount - 1 do
  begin
    if ((not bUserBoot) and WizardCanCreate[TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName]) or
       (bUserBoot and BootList[i]) then
    begin
      try
        Wizard := TCnWizardClass(GetCnWizardClassByIndex(i)).Create;
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard Created: ' + Wizard.ClassName);
      {$ENDIF}
      except
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('Wizard Create Fail: ' +
          TCnWizardClass(GetCnWizardClassByIndex(i)).ClassName);
      {$ENDIF}
        Wizard := nil;
      end;

      if Wizard = nil then Continue;

      if Wizard is TCnRepositoryWizard then
      begin
        RepositoryWizard := TCnRepositoryWizard(Wizard);
        FRepositoryWizards.Add(RepositoryWizard);
        RepositoryWizard.WizardIndex := WizardSvcs.AddWizard(RepositoryWizard);
      end
      else if Wizard is TCnMenuWizard then // 菜单类专家
      begin
        MenuWizard := TCnMenuWizard(Wizard);
        FMenuWizards.Add(MenuWizard);
      end
      else if Wizard is TCnIDEEnhanceWizard then  // IDE 功能扩展专家
      begin
        IDEEnhanceWizard := TCnIDEEnhanceWizard(Wizard);
        FIDEEnhanceWizards.Add(IDEEnhanceWizard);
      end
      else
        FWizards.Add(Wizard);

    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Wizard [%d] installed: %s', [i, Wizard.ClassName]);
    {$ENDIF}
    end;
  end;

//初始化偏移量
  FOffSet[0] := FWizards.Count;
  FOffSet[1] := FOffSet[0] + FMenuWizards.Count;
  FOffSet[2] := FOffSet[1] + FIDEEnhanceWizards.Count;
  FOffSet[3] := FOffSet[2] + FRepositoryWizards.Count;
  if bUserBoot then SetLength(BootList, 0);
end;

function TCnWizardMgr.GetOffSet(Index: Integer): Integer;
begin
  Result := FOffSet[Index];
end;

// 释放专家列表
procedure TCnWizardMgr.FreeWizards;
var
  WizardSvcs: IOTAWizardServices;
begin
  if not QuerySvcs(BorlandIDEServices, IOTAWizardServices, WizardSvcs) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('Query IOTAWizardServices Error', cmtError);
  {$ENDIF}
    Exit;
  end;

  while FWizards.Count > 0 do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(TCnBaseWizard(FWizards[0]).ClassName + '.Free');
  {$ENDIF}
    try
      try
        TCnBaseWizard(FWizards[0]).Free;
      finally
        FWizards.Delete(0);
      end;
    except
      Continue;
    end;
  end;

  while FMenuWizards.Count > 0 do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(TCnMenuWizard(FMenuWizards[0]).ClassName + '.Free');
  {$ENDIF}
    try
      try
        TCnMenuWizard(FMenuWizards[0]).Free;
      finally
        FMenuWizards.Delete(0);
      end;
    except
      Continue;
    end;
  end;

  while FIDEEnhanceWizards.Count > 0 do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(TCnIDEEnhanceWizard(FIDEEnhanceWizards[0]).ClassName + '.Free');
  {$ENDIF}
    try
      try
        TCnIDEEnhanceWizard(FIDEEnhanceWizards[0]).Free;
      finally
        FIDEEnhanceWizards.Delete(0);
      end;
    except
      Continue;
    end;
  end;
  
  while FRepositoryWizards.Count > 0 do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(TCnRepositoryWizard(FRepositoryWizards[0]).ClassName + '.Free');
  {$ENDIF}
    // 移除专家会自动释放掉
    WizardSvcs.RemoveWizard(TCnRepositoryWizard(FRepositoryWizards[0]).WizardIndex);
    FRepositoryWizards.Delete(0);
  end;
end;

// 装载专家设置
procedure TCnWizardMgr.LoadSettings;
var
  i: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizardMgr.LoadSettings');
{$ENDIF}
  with WizOptions.CreateRegIniFile do
  try
    // 载入 MenuOrder
    for i := 0 to MenuWizardCount - 1 do
    begin
      MenuWizards[i].MenuOrder := ReadInteger(SCnMenuOrderSection,
        MenuWizards[i].GetIDStr, i);

      // 此处调用 AcquireSubActions, 让 TCnSubMenuWizard 在 Create 时有空初始化
      if MenuWizards[i] is TCnSubMenuWizard then
      begin
        (MenuWizards[i] as TCnSubMenuWizard).ClearSubActions;
        (MenuWizards[i] as TCnSubMenuWizard).AcquireSubActions;
      end;
    end;

    // 装载专家设置
    for i := 0 to WizardCount - 1 do
    begin
      Wizards[i].DoLoadSettings;
      Wizards[i].Active := ReadBool(SCnActiveSection,
        Wizards[i].GetIDStr, Wizards[i].Active);
    end;
  finally
    Free;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.LoadSettings');
{$ENDIF}
end;

// 保存专家设置
procedure TCnWizardMgr.SaveSettings;
var
  i: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizardMgr.SaveSettings');
{$ENDIF}

  with WizOptions.CreateRegIniFile do
  try
    for i := 0 to WizardCount - 1 do
    begin
      Wizards[i].DoSaveSettings;
      // 保存 Active
      WriteBool(SCnActiveSection, Wizards[i].GetIDStr, Wizards[i].Active);
    end;
    
    // 保存 MenuOrder
    for i := 0 to MenuWizardCount - 1 do
      WriteInteger(SCnMenuOrderSection, MenuWizards[i].GetIDStr,
        MenuWizards[i].MenuOrder);
  finally
    Free;
  end;

{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.CompEditorRegPath) do
  try
    for i := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
    begin
      CnDesignEditorMgr.CompEditors[i].DoSaveSettings;
      with CnDesignEditorMgr.CompEditors[i] do
        WriteBool(SCnActiveSection, IDStr, Active);
    end;
  finally
    Free;
  end;

  with WizOptions.CreateRegIniFile(WizOptions.PropEditorRegPath) do
  try
    for i := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
    begin
      CnDesignEditorMgr.PropEditors[i].DoSaveSettings;
      with CnDesignEditorMgr.PropEditors[i] do
        WriteBool(SCnActiveSection, IDStr, Active);
    end;
  finally
    Free;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizardMgr.SaveSettings');
{$ENDIF}
end;

procedure TCnWizardMgr.EnsureNoParent(Menu: TMenuItem);
begin
  if (Menu <> nil) and (Menu.Parent <> nil) then
    Menu.Parent.Remove(Menu);
end;

// 安装其它辅助菜单
procedure TCnWizardMgr.InstallMiscMenu;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('Install misc menu Entered.');
{$ENDIF}
  if Menu.Count > 0 then
  begin
    EnsureNoParent(FSepMenu);
    Menu.Add(FSepMenu);
  end;

{$IFNDEF CNWIZARDS_MINIMUM}
  EnsureNoParent(FConfigAction.Menu);
  EnsureNoParent(FWizMultiLang.Menu);
  EnsureNoParent(FWizAbout.Menu);

  Menu.Add(FConfigAction.Menu);
  Menu.Add(FWizMultiLang.Menu);
  Menu.Add(FWizAbout.Menu);
{$ENDIF}  
{$IFDEF DEBUG}
  CnDebugger.LogLeave('Install misc menu Leave successed.');
{$ENDIF}
end;

// 释放其它辅助菜单
procedure TCnWizardMgr.FreeMiscMenu;
begin
  WizActionMgr.DeleteAction(TCnWizAction(FConfigAction));
  FWizMultiLang.Free;
  FWizAbout.Free;
  FSepMenu.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Free misc menu succeed');
{$ENDIF}
end;

// 安装组件编辑器
procedure TCnWizardMgr.InstallCompEditors;
{$IFNDEF CNWIZARDS_MINIMUM}
var
  i: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin installing component editors');
{$ENDIF}
{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.CompEditorRegPath) do
  try
    for i := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
      with CnDesignEditorMgr.CompEditors[i] do
      begin
        Active := ReadBool(SCnActiveSection, IDStr, True);
      {$IFDEF DEBUG}
        if Active then
          CnDebugger.LogMsg('Component editors installed: ' + IDStr);
      {$ENDIF}
        DoLoadSettings;
      end;
  finally
    Free;
  end;
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Installing component editors succeed');
{$ENDIF}
end;

// 安装属性编辑器
procedure TCnWizardMgr.InstallPropEditors;
{$IFNDEF CNWIZARDS_MINIMUM}
var
  i: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Begin installing property editors');
{$ENDIF}
{$IFNDEF CNWIZARDS_MINIMUM}
  with WizOptions.CreateRegIniFile(WizOptions.PropEditorRegPath) do
  try
    for i := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
      with CnDesignEditorMgr.PropEditors[i] do
      begin
        Active := ReadBool(SCnActiveSection, IDStr, True);
      {$IFDEF DEBUG}
        if Active then
          CnDebugger.LogMsg('Property editors installed: ' + IDStr);
      {$ENDIF}
        DoLoadSettings;
      end;
  finally
    Free;
  end;
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Installing property editors succeed');
{$ENDIF}
end;

// 启动每日一帖的延时
procedure TCnWizardMgr.SetTipShowing;
begin
  FTipTimer := TTimer.Create(nil);
  FTipTimer.Interval := 8000;
  FTipTimer.OnTimer := ShowTipofDay;
end;

// 显示每日一帖
procedure TCnWizardMgr.ShowTipofDay(Sender: TObject);
begin
  FreeAndNil(FTipTimer);
{$IFNDEF CNWIZARDS_MINIMUM}
  ShowCnWizTipOfDayForm(False);
{$ENDIF}
end;

// 检查 IDE 版本并提示
procedure TCnWizardMgr.CheckIDEVersion;
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  if not IsIdeVersionLatest then
    ShowSimpleCommentForm('', SCnIDENOTLatest, SCnCheckIDEVersion + CompilerShortName);
{$ENDIF}    
end;

// 文件通知
procedure TCnWizardMgr.OnFileNotify(NotifyCode: TOTAFileNotification;
  const FileName: string);
begin
  // 启动时设置无效，必须在加载包后再设置
  if NotifyCode = ofnPackageInstalled then
    WizOptions.DoFixThreadLocale;
end;

// IDE 已启动事件
procedure TCnWizardMgr.OnIdeLoaded(Sender: TObject);
var
  i: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('OnIdeLoaded');
{$ENDIF}

  WizShortCutMgr.BeginUpdate;
  CnListBeginUpdate;
  try
    for i := 0 to WizardCount - 1 do
    try
      Wizards[i].Loaded;
    except
      DoHandleException(Wizards[i].ClassName + '.Loaded');
    end;

{$IFNDEF CNWIZARDS_MINIMUM}
    // 装载组件编辑器设置
    for i := 0 to CnDesignEditorMgr.CompEditorCount - 1 do
    try
      CnDesignEditorMgr.CompEditors[i].Loaded;
    except
      DoHandleException(CnDesignEditorMgr.CompEditors[i].IDStr + '.Loaded');
    end;

    // 装载属性编辑器设置
    for i := 0 to CnDesignEditorMgr.PropEditorCount - 1 do
    try
      CnDesignEditorMgr.PropEditors[i].Loaded;
    except
      DoHandleException(CnDesignEditorMgr.PropEditors[i].IDStr + '.Loaded');
    end;
{$ENDIF}

  finally
    CnListEndUpdate;
    WizShortCutMgr.UpdateBinding;   // IDE 启动后强制重新绑定一次
    WizShortCutMgr.EndUpdate;
  end;

{$IFNDEF CNWIZARDS_MINIMUM}
  // IDE 启动后再注册编辑器以保证优先级最高
  CnDesignEditorMgr.Register;
{$ENDIF}

  // 全部装载完成置允许保存标志
  FSettingsLoaded := True;

{$IFNDEF CNWIZARDS_MINIMUM}
  // 检查升级
  if (WizOptions.UpgradeStyle = usAllUpgrade) or (WizOptions.UpgradeStyle =
    usUserDefine) and (WizOptions.UpgradeContent <> []) then
    CheckUpgrade(False);

  // 显示每日一帖
  SetTipShowing;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogLeave('OnIdeLoaded');
  CnDebugger.LogSeparator;
{$ENDIF}
end;

// 显示专家设置对话框
procedure TCnWizardMgr.OnConfig(Sender: TObject);
{$IFNDEF CNWIZARDS_MINIMUM}
var
  I: Integer;
{$ENDIF}
begin
{$IFNDEF CNWIZARDS_MINIMUM}
  I := WizActionMgr.IndexOfCommand(SCnWizConfigCommand);
  if I >= 0 then
    ShowCnWizConfigForm(WizActionMgr.WizActions[I].Icon)
  else
    ShowCnWizConfigForm;
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// 取专家总数
function TCnWizardMgr.GetWizardCount: Integer;
begin
  Result := OffSet[3];
end;

// 取指定专家
function TCnWizardMgr.GetWizards(Index: Integer): TCnBaseWizard;
begin
  if Index < 0 then
  begin
    Result := nil;
    Exit;
  end;
  // 结果是普通专家
  if (Index <= OffSet[0] - 1) then
    Result := TCnBaseWizard(FWizards[Index])
  // 结果是菜单专家
  else if (Index <= OffSet[1] - 1) then
    Result := TCnBaseWizard(FMenuWizards[Index - OffSet[0]])
  // 结果是 IDE 功能扩展专家
  else if (Index <= OffSet[2] - 1) then
    Result := TCnBaseWizard(FIDEEnhanceWizards[Index - OffSet[1]])
  // 结果是Repository专家
  else if (Index <= OffSet[3] - 1) then
    Result := TCnBaseWizard(FRepositoryWizards[Index - OffSet[2]])
  else
    Result := nil;
end;

// 取菜单专家总数
function TCnWizardMgr.GetMenuWizardCount: Integer;
begin
  Result := FMenuWizards.Count;
end;

// 取指定菜单专家
function TCnWizardMgr.GetMenuWizards(Index: Integer): TCnMenuWizard;
begin
  if (Index >= 0) and (Index <= FMenuWizards.Count - 1) then
    Result := TCnMenuWizard(FMenuWizards[Index])
  else
    Result := nil;
end;

// 取仓库专家总数
function TCnWizardMgr.GetRepositoryWizardCount: Integer;
begin
  Result := FRepositoryWizards.Count;
end;

// 取指定仓库专家
function TCnWizardMgr.GetRepositoryWizards(
  Index: Integer): TCnRepositoryWizard;
begin
  if (Index >= 0) and (Index <= FRepositoryWizards.Count - 1) then
    Result := TCnRepositoryWizard(FRepositoryWizards[Index])
  else
    Result := nil;
end;

// 取指定专家是否创建
function TCnWizardMgr.GetWizardCanCreate(WizardClassName: string): Boolean;
begin
  Result := WizOptions.ReadBool(SCnCreateSection, WizardClassName, True);
  WizOptions.WriteBool(SCnCreateSection, WizardClassName, Result);
end;

// 写指定专家是否创建
procedure TCnWizardMgr.SetWizardCanCreate(WizardClassName: string;
  const Value: Boolean);
begin
  WizOptions.WriteBool(SCnCreateSection, WizardClassName, Value);
end;

// 分发处理 Debug 输出命令并将结果放置入 Results 中，供内部调试用
procedure TCnWizardMgr.DispatchDebugComand(Cmd: string; Results: TStrings);
{$IFDEF DEBUG}
var
  LocalCmd, ID: string;
  Cmds: TStrings;
  I: Integer;
  Wizard: TCnBaseWizard;
  Matched: Boolean;
{$ENDIF}
begin
  if (Cmd = '') or (Results = nil) then
    Exit;
  Results.Clear;

{$IFDEF DEBUG}
  Cmds := TStringList.Create;
  try
    ExtractStrings([' '], [], PChar(Cmd), Cmds);
    if Cmds.Count = 0 then
      Exit;

    LocalCmd := Cmds[0];
    Matched := False;
    Wizard := nil;
    for I := 0 to GetWizardCount - 1 do
    begin
      Wizard := GetWizards(I);
      ID := Wizard.GetIDStr;
      if Pos(LocalCmd, ID) > 0 then
      begin
        Matched := True;
        Break;
      end;
    end;

    if Matched and (Wizard <> nil) then
    begin
      Cmds.Delete(0);
      Wizard.DebugComand(Cmds, Results);
      Exit;
    end;

    // No Wizard can process this debug command, do other stuff
    Results.Add('Unknown Debug Command ' + Cmd);
  finally
    Cmds.Free;
  end;
{$ELSE}
  Results.Add('CnPack IDE Wizards Debug Command Disabled.');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 必须实现的 IOTAWizard 方法
//------------------------------------------------------------------------------

{ TCnWizardMgr.IOTAWizard }

// 专家执行方法（空方法）
procedure TCnWizardMgr.Execute;
begin
  // do nothing
end;

// 取专家ID
function TCnWizardMgr.GetIDString: string;
begin
  Result := SCnWizardMgrID;
end;

// 取专家名
function TCnWizardMgr.GetName: string;
begin
  Result := SCnWizardMgrName;
end;

// 返回专家状态
function TCnWizardMgr.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

{$IFDEF CASTALIA_KEYMAPPING_CONFLICT_BUG}

procedure TCnWizardMgr.CheckKeyMappingEnhModulesSequence;
const
  PRIORITY_KEY = 'Priority';
  CASTALIA_KEYNAME = 'Castalia';
  CNPACK_KEYNAME = 'CnPack';
var
  List: TStringList;
  Reg: TRegistry;
  I, {MinIdx,} MaxIdx, CnPackIdx, MinValue, MaxValue: Integer;
  Contain: Boolean;
begin
  // 如果上回勾选了不再显示则不再显示。
  if not WizOptions.ReadBool(SCnCommentSection, SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, True) then
    Exit;

  // XE8/10 Seattle 下 IDE 集成的 Castalia 的快捷键和 CnPack 有冲突，
  // 规则：有 Castalia 名字存在，且 CnPack 的 Priority 不是最大，则提示。
  List := TStringList.Create;
  try
    if GetKeysInRegistryKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG, List) then
    begin
      if List.Count <= 1 then
        Exit;

      // List 中存了每个 Key 的名字，Objects 里头存其 Priority 值
      for I := 0 to List.Count - 1 do
      begin
        List.Objects[I] := Pointer(-1);
        Reg := TRegistry.Create(KEY_READ);
        try
          if Reg.OpenKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG + '\' + List[I], False) then
          begin
            List.Objects[I] := Pointer(Reg.ReadInteger(PRIORITY_KEY));
          end;
        finally
          Reg.Free;
        end;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('Key Mapping: %s: Priority %d.', [List[I], Integer(List.Objects[I])]);
{$ENDIF}
      end;

      Contain := False;
      for I := 0 to List.Count - 1 do
      begin
        if Pos(CASTALIA_KEYNAME, List[I]) > 0 then
        begin
          Contain := True;
          Break;
        end;
      end;

      if not Contain then // 如果没 Castalia，大概就没冲突，不处理
        Exit;

      Contain := False;
      CnPackIdx := -1;
      for I := 0 to List.Count - 1 do
      begin
        if Pos(CNPACK_KEYNAME, List[I]) > 0 then
        begin
          Contain := True;
          CnPackIdx := I;
          Break;
        end;
      end;

      if not Contain then // 没 CnPack 的值，可能是第一次运行，只能提示
      begin
        ShowSimpleCommentForm('', Format(SCnKeyMappingConflictsHint, [WizOptions.CompilerRegPath + KEY_MAPPING_REG]),
          SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, False);
        Exit;
      end;

      // Both exist, check the priority of CnPack
      // MinIdx := 0;
      MaxIdx := 0;
      MinValue := Integer(List.Objects[0]);
      MaxValue := Integer(List.Objects[0]);
      for I := 0 to List.Count - 1 do
      begin
        if Integer(List.Objects[I]) < MinValue then
        begin
          //MinIdx := I;
          MinValue := Integer(List.Objects[I]);
        end;

        if Integer(List.Objects[I]) > MaxValue then
        begin
          MaxIdx := I;
          MaxValue := Integer(List.Objects[I]);
        end;
      end;

      if MaxIdx = CnPackIdx then // CnPack 键盘映射顺序已在最下面。
        Exit;

      ShowSimpleCommentForm('', Format(SCnKeyMappingConflictsHint, [WizOptions.CompilerRegPath + KEY_MAPPING_REG]),
        SCnCheckKeyMappingEnhModulesSequence + CompilerShortName, False);

      // 交换最大的值和 CnPack 的值。但未必有效，先不这么整。
//      Reg := TRegistry.Create(KEY_WRITE);
//      try
//        if Reg.OpenKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG + '\' + List[CnPackIdx], False) then
//        begin
//          Reg.WriteInteger(PRIORITY_KEY, Integer(List.Objects[MaxIdx]));
//          Reg.CloseKey;
//        end;
//        if Reg.OpenKey(WizOptions.CompilerRegPath + KEY_MAPPING_REG + '\' + List[MaxIdx], False) then
//        begin
//          Reg.WriteInteger(PRIORITY_KEY, Integer(List.Objects[CnPackIdx]));
//          Reg.CloseKey;
//        end;
//{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Key Mapping Exchange Priority: %s to %d; %s to %d.',
//          [List[MaxIdx], Integer(List.Objects[CnPackIdx]),
//          List[CnPackIdx], Integer(List.Objects[MaxIdx])]);
//{$ENDIF}
//      finally
//        Reg.Free;
//      end;
    end;
  finally
    List.Free;
  end;
end;

{$ENDIF}

{$IFDEF COMPILER6_UP}

//==============================================================================
// 设计器右键菜单执行项目管理器
//==============================================================================

{ TCnDesignSelectionManager }

procedure TCnDesignSelectionManager.ExecuteVerb(Index: Integer;
  const List: IDesignerSelections);
begin
  TCnBaseMenuExecutor(CnDesignExecutorList[Index]).Execute;
end;

function TCnDesignSelectionManager.GetVerb(Index: Integer): string;
begin
  Result := TCnBaseMenuExecutor(CnDesignExecutorList[Index]).GetCaption;
end;

function TCnDesignSelectionManager.GetVerbCount: Integer;
begin
  Result := CnDesignExecutorList.Count;
end;

procedure TCnDesignSelectionManager.PrepareItem(Index: Integer;
  const AItem: IMenuItem);
var
  Executor: TCnBaseMenuExecutor;
begin
  Executor := TCnBaseMenuExecutor(CnDesignExecutorList[Index]);
  AItem.Visible := (Executor <> nil) and
    ((Executor.Wizard = nil) or Executor.Wizard.Active)
    and Executor.GetActive;
  if AItem.Visible then
    AItem.Enabled := Executor.GetEnabled;
end;

procedure TCnDesignSelectionManager.RequiresUnits(Proc: TGetStrProc);
begin

end;

{$ENDIF}

initialization
  CnDesignExecutorList := TObjectList.Create(True);
  CnEditorExecutorList := TObjectList.Create(True);

{$IFDEF COMPILER6_UP}
  RegisterSelectionEditor(TComponent, TCnDesignSelectionManager);
{$ENDIF}

finalization
  FreeAndNil(CnDesignExecutorList);
  FreeAndNil(CnEditorExecutorList);

end.

