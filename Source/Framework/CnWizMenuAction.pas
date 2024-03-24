{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnWizMenuAction;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE Action 封装类和管理器实现单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元为 CnWizards 框架的一部分，实现了扩展的 IDE Action 类和 Action
*           列表管理的功能。这部分功能主要供 TCnActionWizard 专家及子类使用。
*             - 如果需要在 IDE 环境中创建一个 Action，使用 WizActionMgr.Add(...)
*               来创建一个 IDE Action 对象，注意两个版本的 Add 返回不同的对象。
*             - 当不再需要 Action 时，调用 WizActionMgr.Delete(...) 来删除，绝对
*               不要自己去释放 Action 对象。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2012.09.19 by shenloqi
*               移植到 Delphi XE3
*           2002.09.17 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, SysUtils, Graphics, Menus, Forms, ActnList, ToolsAPI, 
  {$IFDEF DELPHIXE3_UP} Actions,{$ENDIF}
  {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList, {$ENDIF}
  CnCommon, CnWizConsts, CnWizShortCut;

type
//==============================================================================
// CnWizards IDE Action 封装类
//==============================================================================

{ TCnWizAction }

  TCnWizAction = class(TAction)
  {* 用于 CnWizards 专家中的 Action 类，增加了 IDE 快捷键封装、图标等功能。
     请不要直接创建和释放该类的实例，而应该使用 Action 管理器 WizActionMgr
     的 Add 和 Delete 方法来实现。需要注意的是，TCnWizAction 重新定义了
     ShortCut 属性，如果将该类的实例转换为 TAction 来写 ShortCut 是不会成功的。}
  private
    FCommand: string;
    FWizShortCut: TCnWizShortCut;
    FIcon: TIcon;
    FUpdating: Boolean;
    FLastUpdateTick: Cardinal;
    procedure SetInheritedShortCut;
    function GetShortCut: TShortCut;
    procedure {$IFDEF DelphiXE3_UP}_CnSetShortCut{$ELSE}SetShortCut{$ENDIF}(const Value: TShortCut);
    {* Delphi XE3 引入了 SetShortCut 基方法，为避免同名带入的问题，故将此方法改名}
    procedure OnShortCut(Sender: TObject);
  protected
    procedure Change; override;
    property WizShortCut: TCnWizShortCut read FWizShortCut;
  public
    constructor Create(AOwner: TComponent); override;
    {* 类构造器，请不要直接调用该方法创建类实例，而应该用 Action 管理器
       WizActionMgr.Add 来创建，并用它的 Delete 来删除。}
    destructor Destroy; override;
    {* 类析构器，请不要直接释放该类的实例，而应该用 Action 管理器
       WizShortCutMgr.Delete 来删除一个 Action 对象。}
    function Update: Boolean; override;
    {* 更新 Action 状态。}
    property Command: string read FCommand;
    {* Action 命令字符串，用来唯一标识一个 Action，同时也是快捷键对象的名字}
    property Icon: TIcon read FIcon;
    {* Action 关联的图标，加载时 16x16，可在其它地方使用，但请不要更改图标内容}
    property ShortCut: TShortCut read GetShortCut write {$IFDEF DelphiXE3_UP}_CnSetShortCut{$ELSE}SetShortCut{$ENDIF};
    {* Action 关联的快捷键}
  end;

//==============================================================================
// 带菜单项的 CnWizards IDE Action 封装类
//==============================================================================

{ TCnWizMenuAction }

  TCnWizMenuAction = class(TCnWizAction)
  {* 带菜单项用于 CnMenuWizards 专家中的 Action 类，在 TCnWizAction 的基础上增
     加了菜单项属性。}
  private
    FMenu: TMenuItem;
  public
    constructor Create(AOwner: TComponent); override;
    {* 类构造器，请不要直接调用该方法创建类实例，而应该用 Action 管理器
       WizActionMgr.Add 来创建，并用它的 Delete 来删除。}
    destructor Destroy; override;
    {* 类析构器，请不要直接释放该类的实例，而应该用 Action 管理器
       WizShortCutMgr.Delete 来删除一个 Action 对象。}
    property Menu: TMenuItem read FMenu;
    {* Action 关联的菜单项，可在其它地方使用}
  end;

//==============================================================================
// CnWizards IDE Action 管理器类
//==============================================================================

{ TCnWizActionMgr }

  TCnWizActionMgr = class(TComponent)
  {* IDE Action 管理器类，用于维护创建到 IDE 中的 Action 列表。
     请不要直接创建该类的实例，应使用 WizActionMgr 来获得当前的管理器实例。}
  private
    FWizActions: TList;
    FWizMenuActions: TList;
    FMoreAction: TAction;
    FDeleting: Boolean;
    function GetIdeActions(Index: Integer): TContainedAction;
    function GetWizActions(Index: Integer): TCnWizAction;
    function GetWizMenuActions(Index: Integer): TCnWizMenuAction;
    function GetIdeActionCount: Integer;
    function GetWizActionCount: Integer;
    function GetWizMenuActionCount: Integer;
    procedure MoreActionExecute(Sender: TObject);
  protected
    procedure InitAction(AWizAction: TCnWizAction; const ACommand,
      ACaption: string; OnExecute: TNotifyEvent; OnUpdate: TNotifyEvent;
      const IcoName, AHint: string; UseDefaultIcon: Boolean = False);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    {* 类构造器，请不要直接创建该类的实例，应使用 WizActionMgr 来获得当前
       的管理器实例。}
    destructor Destroy; override;
    {* 类析构器。}
    function AddAction(const ACommand, ACaption: string; AShortCut: TShortCut;
      OnExecute: TNotifyEvent; const IcoName: string;
      const AHint: string = ''; UseDefaultIcon: Boolean = False): TCnWizAction;
    {* 创建并返回一个 CnWizards Action 对象，同时将其增加到列表中。
       使用 Add 创建的对象应调用 Delete 方法来释放。
     |<PRE>
       ACommand: string         - Action 命令字，必须为一个唯一的字符串值
       ACaption: string         - Action 的标题
       AShortCut: TShortCut     - Action 的默认快捷键，实际使用的键值会从注册表中读取
       OnExecute: TNotifyEvent  - 执行通知事件
       IcoName: string          - Action 关联的图标的名字，创建时会自动从资源和文件中查找装载
       AHint: string            - Action 的提示信息
       UseDefaultIcon: Boolean  - Action 找不到图标时是否使用默认图标
       Result: TCnWizAction     - 返回结果为一个 TCnWizAction 实例
     |</PRE>}
    function AddMenuAction(const ACommand, ACaption, AMenuName: string; AShortCut: TShortCut;
      OnExecute: TNotifyEvent; const IcoName: string;
      const AHint: string = ''; UseDefaultIcon: Boolean = False): TCnWizMenuAction;
    {* 创建并返回一个带菜单的 CnWizards Action 对象，同时将其增加到列表中。
       使用 Add 创建的对象应调用 Delete 方法来释放。
     |<PRE>
       ACommand: string         - Action 命令字，必须为一个唯一的字符串值
       ACaption: string         - Action 的标题
       AMenuName: string        - 菜单项的名字，必须为一个唯一的字符串值，可以与 ACommand 相同
       AShortCut: TShortCut     - Action 的默认快捷键，实际使用的键值会从注册表中读取
       OnExecute: TNotifyEvent  - 执行通知事件
       IcoName: string          - Action 关联的图标的名字，创建时会自动从资源和文件中查找装载
       AHint: string            - Action 的提示信息
       UseDefaultIcon: Boolean  - Action 找不到图标时是否使用默认图标
       Result: TCnWizMenuAction - 返回结果为一个 TCnWizMenuAction 实例
     |</PRE>}
    procedure Delete(Index: Integer);
    {* 删除指定索引号的 Action 对象，另见 Add。}
    procedure DeleteAction(var AWizAction: TCnWizAction);
    {* 删除指定的 Action 对象，完成后将对象参数置为 nil，另见 Add。
       用 Add 创建的 TCnWizMenuAction 对象也使用该方法来删除。}
    procedure Clear;
    {* 清空所有的 Action 对象，包括 TCnWizAction 和 TCnWizMenuAction 的实例。}
    function IndexOfAction(AWizAction: TCnWizAction): Integer;
    {* 返回指定的 Action 对象在列表中的索引号，参数可以是 TCnWizAction 和
       TCnWizMenuAction 对象。返回的索引号只能在 WizActions 数组对象中使用。}
    function IndexOfCommand(const ACommand: string): Integer;
    {* 根据 Action 命令名查找索引号，返回的索引号只能在 WizActions 数组对象中使用。}
    function IndexOfShortCut(AShortCut: TShortCut): Integer; 
    {* 根据快捷键键值查找索引号，返回的索引号只能在 WizActions 数组对象中使用。}
    procedure ArrangeMenuItems(RootItem: TMenuItem; MaxItems: Integer = 0);
    {* 为过长的菜单增加分隔菜单项 }

    property IdeActionCount: Integer read GetIdeActionCount;
    {* 整个 IDE 的主 ActionList 包含的项目数}
    property WizActionCount: Integer read GetWizActionCount;
    {* 管理器列表中 TCnWizAction 对象和 TCnWizMenuAction 对象的总数}
    property WizMenuActionCount: Integer read GetWizMenuActionCount;
    {* 管理器列表中 TCnWizMenuAction 对象的项目数}
    property IdeActions[Index: Integer]: TContainedAction read GetIdeActions;
    {* 整个 IDE 的主 ActionList 包含的 Action 数组，包含了 WizActions 和
       WizMenuActions 所包含的对象}
    property WizActions[Index: Integer]: TCnWizAction read GetWizActions;
    {* 管理器列表中 TCnWizAction 及子类对象数组，也包含了 TCnWizMenuAction 对象}
    property WizMenuActions[Index: Integer]: TCnWizMenuAction read GetWizMenuActions;
    {* 管理器列表中 TCnWizMenuAction 对象数组}
    property MoreAction: TAction read FMoreAction;
    {* 用于解决菜单过长而设置的分隔菜单 Action }
  end;

function WizActionMgr: TCnWizActionMgr;
{* 返回当前的 IDE Action 管理器实例。如果需要使用 IDE Action 管理器，请不要直接
   创建 TCnWizActionMgr 的实例，而应该用该函数来访问。}

procedure FreeWizActionMgr;
{* 释放管理器实例}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizUtils, CnWizIdeUtils;

const
  csUpdateInterval = 100;

//==============================================================================
// CnWizards IDE Action 封装类
//==============================================================================

{ TCnWizAction }

// 类构造器
constructor TCnWizAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommand := '';
  FIcon := TIcon.Create;
  FWizShortCut := nil;
  FUpdating := False;
end;

// 类析构器
destructor TCnWizAction.Destroy;
begin
  if Assigned(FWizShortCut) then
    WizShortCutMgr.DeleteShortCut(FWizShortCut);
  FIcon.Free;
  inherited Destroy;
end;

// 更新 Action 状态
function TCnWizAction.Update: Boolean;
begin
  if GetTickCount - FLastUpdateTick > csUpdateInterval then
  begin
    Result := inherited Update;
    FLastUpdateTick := GetTickCount;
  end
  else
    Result := True;  
end;

// 属性变更通知
procedure TCnWizAction.Change;
var
  NotifyEvent: TNotifyEvent;
begin
  if FUpdating then Exit;

  if Assigned(FWizShortCut) then
  begin
    // 防止继承来的快捷键被修改
    if inherited ShortCut <> ShortCut then
    begin
      SetInheritedShortCut;
      Exit;
    end;
  end;

  inherited Change;
  NotifyEvent := OnShortCut;
  if Assigned(FWizShortCut) then
    FWizShortCut.KeyProc := OnShortCut;
end;

// 快捷键调用过程
procedure TCnWizAction.OnShortCut(Sender: TObject);
begin
  if Assigned(OnExecute) then
    OnExecute(Self);
end;

// 设置从 TAction 继承来的 ShortCut 属性
procedure TCnWizAction.SetInheritedShortCut;
begin
  Assert(Assigned(FWizShortCut));
  FUpdating := True;
  try
    inherited ShortCut := FWizShortCut.ShortCut;
  finally
    FUpdating := False;
  end;
end;

// ShortCut 属性读方法
function TCnWizAction.GetShortCut: TShortCut;
begin
  Assert(Assigned(FWizShortCut));
  Result := FWizShortCut.ShortCut;
end;

// ShortCut 属性写方法
procedure TCnWizAction.{$IFDEF DelphiXE3_UP}_CnSetShortCut{$ELSE}SetShortCut{$ENDIF}(const Value: TShortCut);
begin
  Assert(Assigned(FWizShortCut));
  if FWizShortCut.ShortCut <> Value then
  begin
    FWizShortCut.ShortCut := Value;
    SetInheritedShortCut;
  end;
end;

//==============================================================================
// 带菜单项的 CnWizards IDE Action 封装类
//==============================================================================

{ TCnWizMenuAction }

// 类构造器
constructor TCnWizMenuAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMenu := nil;
end;

// 类析构器
destructor TCnWizMenuAction.Destroy;
begin
  if Assigned(FMenu) then
    FreeAndNil(FMenu);
  inherited Destroy;
end;

{ TCnWizActionMgr }

//==============================================================================
// CnWizards IDE Action 管理器类
//==============================================================================

// 类构造器
constructor TCnWizActionMgr.Create(AOwner: TComponent);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizActionMgr.Create');
{$ENDIF}
  inherited Create(AOwner);
  FWizActions := TList.Create;
  FWizMenuActions := TList.Create;
  FMoreAction := TAction.Create(nil);
  FMoreAction.Caption := SCnMoreMenu;
  FMoreAction.Hint := StripHotkey(SCnMoreMenu);
  FMoreAction.OnExecute := MoreActionExecute;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizActionMgr.Create');
{$ENDIF}
end;

// 类析构器
destructor TCnWizActionMgr.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizActionMgr.Destroy');
{$ENDIF}
  Clear;
  FMoreAction.Free;
  FWizActions.Free;
  FWizMenuActions.Free;
  inherited Destroy;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizActionMgr.Destroy');
{$ENDIF}
end;

// 子对象释放通知
procedure TCnWizActionMgr.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if FDeleting then Exit;
  
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizActionMgr.Notification: (%s: %s)',
    [AComponent.Name, AComponent.ClassName]);
{$ENDIF}
  for i := 0 to FWizActions.Count - 1 do
    if FWizActions[i] = AComponent then
    begin
      FWizActions.Delete(i);
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnWizActionMgr FWizActions.Delete.');
      {$ENDIF}
      Exit;
    end;

  for i := 0 to FWizMenuActions.Count - 1 do
    if FWizMenuActions[i] = AComponent then
    begin
      FWizMenuActions.Delete(i);
      {$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnWizActionMgr FWizMenuActions.Delete.');
      {$ENDIF}
      Exit;
    end
    else if TCnWizMenuAction(FWizMenuActions[i]).FMenu = AComponent then
    begin
      TCnWizMenuAction(FWizMenuActions[i]).FMenu := nil;
      Exit;
    end;
end;

//------------------------------------------------------------------------------
// 列表项目操作
//------------------------------------------------------------------------------

// 初始化 Action 对象
procedure TCnWizActionMgr.InitAction(AWizAction: TCnWizAction;
  const ACommand, ACaption: string; OnExecute: TNotifyEvent; OnUpdate: TNotifyEvent;
  const IcoName, AHint: string; UseDefaultIcon: Boolean);
var
  Svcs40: INTAServices40;
  NewName: string;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  if Trim(ACommand) <> '' then
  begin
    NewName := SCnActionPrefix + Trim(ACommand);
    if Svcs40.ActionList.FindComponent(NewName) = nil then
    begin
      try
        AWizAction.Name := NewName;
      except
      {$IFDEF DEBUG}
        CnDebugger.LogMsgWithType('Rename action error: ' + NewName, cmtError);
      {$ENDIF}
      end;
    end
    else
    {$IFDEF DEBUG}
      CnDebugger.LogMsgWithType('Component is already exists: ' + NewName, cmtError);
    {$ENDIF}
  end;
  AWizAction.Caption := ACaption;
  AWizAction.Hint := AHint;
  AWizAction.Category := SCnWizardsActionCategory;
  AWizAction.OnExecute := OnExecute;
  AWizAction.OnUpdate := OnUpdate;
  
  AWizAction.ActionList := Svcs40.ActionList;
  if CnWizLoadIcon(nil, AWizAction.FIcon, IcoName, UseDefaultIcon) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Load Icon %s OK with %dx%d', [IcoName, AWizAction.FIcon.Width,
      AWizAction.FIcon.Height]);
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
    AWizAction.ImageIndex := AddGraphicToVirtualImageList(AWizAction.FIcon, Svcs40.ImageList as TVirtualImageList)
{$ELSE}
    AWizAction.ImageIndex := AddIconToImageList(AWizAction.FIcon, Svcs40.ImageList, False)
{$ENDIF}
  end
  else
    AWizAction.ImageIndex := -1;
  AWizAction.FCommand := ACommand;
end;

// 创建并返回一个带菜单的 CnWizards Action 对象，同时将其增加到列表中
function TCnWizActionMgr.AddMenuAction(const ACommand, ACaption, AMenuName: string;
  AShortCut: TShortCut; OnExecute: TNotifyEvent; const IcoName,
  AHint: string; UseDefaultIcon: Boolean): TCnWizMenuAction;
var
  Svcs40: INTAServices40;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizActionMgr.Add WizMenuAction: %s', [ACommand]);
{$ENDIF}
  if IndexOfCommand(ACommand) >= 0 then
    raise ECnDuplicateCommand.CreateFmt(SCnDuplicateCommand, [ACommand]);
    
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := TCnWizMenuAction.Create(Svcs40.ActionList);
  Result.FreeNotification(Self);

  Result.FUpdating := True;         // 开始更新
  try
    InitAction(Result, ACommand, ACaption, OnExecute, nil, IcoName, AHint, UseDefaultIcon);
    Result.FMenu := TMenuItem.Create(nil);
    Result.FMenu.FreeNotification(Self);
    Result.FMenu.Name := AMenuName;
    Result.FMenu.Action := Result;
    Result.FMenu.AutoHotkeys := maManual;
    Result.FWizShortCut := WizShortCutMgr.Add(ACommand, AShortCut, Result.OnShortCut,
      AMenuName, 0, Result);

    Result.SetInheritedShortCut;
    FWizMenuActions.Add(Result);
  finally
    Result.FUpdating := False;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizActionMgr.Add WizMenuAction: %s Complete.', [ACommand]);
{$ENDIF}
end;

// 创建并返回一个 CnWizards Action 对象，同时将其增加到列表中
function TCnWizActionMgr.AddAction(const ACommand, ACaption: string;
  AShortCut: TShortCut; OnExecute: TNotifyEvent; const IcoName,
  AHint: string; UseDefaultIcon: Boolean): TCnWizAction;
var
  Svcs40: INTAServices40;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizActionMgr.Add WizAction: %s', [ACommand]);
{$ENDIF}
  if IndexOfCommand(ACommand) >= 0 then
    raise ECnDuplicateCommand.CreateFmt(SCnDuplicateCommand, [ACommand]);
    
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := TCnWizAction.Create(Svcs40.ActionList);
  Result.FreeNotification(Self);

  Result.FUpdating := True;         // 开始更新
  try
    InitAction(Result, ACommand, ACaption, OnExecute, nil, IcoName, AHint, UseDefaultIcon);
    Result.FWizShortCut := WizShortCutMgr.Add(ACommand, AShortCut, Result.OnShortCut, '', 0, Result);
    Result.SetInheritedShortCut;
    FWizActions.Add(Result);
  finally
    Result.FUpdating := False;
  end;
end;

// 清空列表
procedure TCnWizActionMgr.Clear;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizActionMgr.Clear');
{$ENDIF}
  WizShortCutMgr.BeginUpdate;       // 开始更新
  try
    while WizActionCount > 0 do
      Delete(0);
  finally
    WizShortCutMgr.EndUpdate;       // 结束更新，重新绑定快捷键
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizActionMgr.Clear');
{$ENDIF}
end;

// 删除指定索引号的 Action 对象
procedure TCnWizActionMgr.Delete(Index: Integer);
begin
  FDeleting := True;
  try
    if (Index >= 0) and (Index < FWizActions.Count) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnWizActionMgr.Delete(%d Action): %s', [Index,
        TCnWizAction(FWizActions[Index]).Command]);
    {$ENDIF}
      TCnWizAction(FWizActions[Index]).Free;
      FWizActions.Delete(Index);
    end
    else if (Index >= FWizActions.Count) and (Index < FWizActions.Count +
      FWizMenuActions.Count) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnWizActionMgr.Delete(%d MenuAction): %s', [Index,
        TCnWizAction(FWizMenuActions[Index - FWizActions.Count]).Command]);
    {$ENDIF}
      TCnWizMenuAction(FWizMenuActions[Index - FWizActions.Count]).Free;
      FWizMenuActions.Delete(Index - FWizActions.Count);
    end;
  finally
    FDeleting := False;
  end;
end;

// 删除指定的 Action 对象，完成后将对象参数置为 nil
procedure TCnWizActionMgr.DeleteAction(var AWizAction: TCnWizAction);
begin
  Delete(IndexOfAction(AWizAction));
  AWizAction := nil;
end;

// 返回指定的 Action 对象在列表中的索引号
function TCnWizActionMgr.IndexOfAction(AWizAction: TCnWizAction): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to WizActionCount - 1 do
  begin
    if AWizAction = WizActions[I] then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

// 根据 Action 命令名查找索引号
function TCnWizActionMgr.IndexOfCommand(const ACommand: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if ACommand = '' then Exit;
  for I := 0 to WizActionCount - 1 do
    if WizActions[I].FCommand = ACommand then
    begin
      Result := I;
      Exit;
    end;
end;

// 根据快捷键键值查找索引号
function TCnWizActionMgr.IndexOfShortCut(AShortCut: TShortCut): Integer;
var
  I: Integer;
begin
  Result := -1;
  if AShortCut = 0 then Exit;
  for I := 0 to WizActionCount - 1 do
    if WizActions[I].ShortCut = AShortCut then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TCnWizActionMgr.MoreActionExecute(Sender: TObject);
begin
  // do nothing
end;

procedure TCnWizActionMgr.ArrangeMenuItems(RootItem: TMenuItem;
  MaxItems: Integer);
{$IFDEF COMPILER7_UP}
  function NewMoreItem: TMenuItem;
  begin
    Result := TMenuItem.Create(RootItem);
    Result.Action := MoreAction;
  end;

var
  I: Integer;
  ScreenRect: TRect;
  ScreenHeight: Integer;
  MoreMenuItem: TMenuItem;
  ParentItem: TMenuItem;
  Item: TMenuItem;
  CurrentIndex: Integer;
  MenuItems: array of TMenuItem;
{$ENDIF}
begin
{$IFDEF COMPILER7_UP}
  if MaxItems < 8 then
  begin
    ScreenRect := GetWorkRect(GetIdeMainForm);
    ScreenHeight := ScreenRect.Bottom - ScreenRect.Top - 75;
    MaxItems := ScreenHeight div GetMainMenuItemHeight;
    if MaxItems < 8 then MaxItems := 8;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CnWizActionMgr.ArrangeMenuItems with Max ' + IntToStr(MaxItems));
{$ENDIF}

  SetLength(MenuItems, RootItem.Count);
  try
    for I := RootItem.Count - 1 downto 0 do
      MenuItems[I] := RootItem.Items[I];

    ParentItem := RootItem;
    CurrentIndex := 0;

    for I := 0 to Length(MenuItems) - 1 do
    begin
      Item := MenuItems[I];
      if (CurrentIndex = MaxItems - 1) and (I < (Length(MenuItems) - 1)) then
      begin
        MoreMenuItem := NewMoreItem;
        ParentItem.Add(MoreMenuItem);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CnWizActionMgr.ArrangeMenuItems. Add MoreItem at ' + IntToStr(CurrentIndex));
{$ENDIF}
        ParentItem := MoreMenuItem;
        CurrentIndex := 0;
      end;
      if Item.Parent <> ParentItem then
      begin
        Item.Parent.Remove(Item);
        ParentItem.Add(Item);
      end;
      Item.MenuIndex := CurrentIndex;
      Inc(CurrentIndex);
    end;
  finally
    MenuItems := nil;
  end;          
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// IdeActionCount 属性读方法
function TCnWizActionMgr.GetIdeActionCount: Integer;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ActionList.ActionCount;
end;

// IdeActions 属性读方法
function TCnWizActionMgr.GetIdeActions(Index: Integer): TContainedAction;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.ActionList.Actions[Index];
end;

// WizActionCount 属性读方法
function TCnWizActionMgr.GetWizActionCount: Integer;
begin
  Result := FWizActions.Count + FWizMenuActions.Count;
end;

// WizActions 属性读方法
function TCnWizActionMgr.GetWizActions(Index: Integer): TCnWizAction;
begin
  if (Index >= 0) and (Index < FWizActions.Count) then
    Result := TCnWizAction(FWizActions[Index])
  else if (Index >= FWizActions.Count) and (Index < FWizActions.Count +
    FWizMenuActions.Count) then
    Result := TCnWizAction(FWizMenuActions[Index - FWizActions.Count])
  else
    Result := nil;
end;

// WizMenuActionCount 属性读方法
function TCnWizActionMgr.GetWizMenuActionCount: Integer;
begin
  Result := FWizMenuActions.Count;
end;

// WizMenuActions 属性读方法
function TCnWizActionMgr.GetWizMenuActions(
  Index: Integer): TCnWizMenuAction;
begin
  Result := nil;
  if (Index >= 0) and (Index < FWizMenuActions.Count) then
    Result := TCnWizMenuAction(FWizMenuActions[Index]);
end;

var
  FWizActionMgr: TCnWizActionMgr = nil;

// 返回当前的 IDE Action 管理器实例
function WizActionMgr: TCnWizActionMgr;
begin
  if FWizActionMgr = nil then
    FWizActionMgr := TCnWizActionMgr.Create(nil);
  Result := FWizActionMgr;
end;

// 释放管理器实例
procedure FreeWizActionMgr;
begin
  if FWizActionMgr <> nil then
    FreeAndNil(FWizActionMgr);
end;

end.


