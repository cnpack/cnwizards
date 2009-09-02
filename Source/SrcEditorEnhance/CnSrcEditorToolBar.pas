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

unit CnSrcEditorToolBar;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器工具栏单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.12.25
*               创建单元，从原 CnSrcEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms, CnIni,
  ComCtrls, ToolWin, ToolsAPI, IniFiles, CnEditControlWrapper, CnWizNotifier,
  CnWizIni;

type

//==============================================================================
// 代码编辑器工具栏
//==============================================================================

{ TCnSrcEditorToolButton }

  TCnSrcEditorToolButton = class(TToolButton)
  private
    FMenu: TPopupMenu;
    procedure OnPopup(Sender: TObject);
    procedure DoClick(Sender: TObject);
  public
    procedure Click; override;
  end;

{ TCnSrcEditorToolBar }

  TCnSrcEditorToolBarMgr = class;

  TCnSrcEditorToolBar = class(TToolBar)
  private
    FMenu: TPopupMenu;
    FToolBarMgr: TCnSrcEditorToolBarMgr;
    procedure OnConfig(Sender: TObject);
    procedure OnClose(Sender: TObject);
    procedure OnEnhConfig(Sender: TObject);
  protected
{$IFDEF BDS}
    procedure SetEnabled(Value: Boolean); override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitControls;
    procedure RecreateButtons;
    procedure InitPopupMenu;
    procedure LanguageChanged(Sender: TObject);
    property Menu: TPopupMenu read FMenu;
  end;

  TCnExternalSrcEditorToolBar = class(TToolBar)
  private
    procedure InitControls;
  protected
{$IFDEF BDS}
    procedure SetEnabled(Value: Boolean); override;
{$ENDIF}
  end;

//==============================================================================
// 代码编辑器工具栏管理器
//==============================================================================

{ TCnSrcEditorToolBarMgr }

  TCnSrcEditorToolBarMgr = class
  private
    FShowToolBar: Boolean;
    FToolBarActions: TStringList;
    FActive: Boolean;
    FList: TList;
    FOnEnhConfig: TNotifyEvent;
    FWrapable: Boolean;
{$IFDEF BDS}
    FShowInDesign: Boolean;
    procedure SetShowInDesign(const Value: Boolean);
{$ENDIF}
    procedure LoadToolBarActions(const FileName: string);
    procedure SaveToolBarActions(const FileName: string);
    procedure SetShowToolBar(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    procedure DoInstallToolBars(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetCount: Integer;
    function GetToolBar(Index: Integer): TCnSrcEditorToolBar;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SetWrapable(Value: Boolean);
  protected
    procedure DoEnhConfig;
    function CanShowToolBar: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure InstallToolBars;
    procedure UpdateToolBars;
    procedure ConfigToolBar;
    procedure LanguageChanged(Sender: TObject);
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);

    property Count: Integer read GetCount;
    property ToolBars[Index: Integer]: TCnSrcEditorToolBar read GetToolBar;

    property ShowToolBar: Boolean read FShowToolBar write SetShowToolBar;
{$IFDEF BDS}
    property ShowInDesign: Boolean read FShowInDesign write SetShowInDesign;
{$ENDIF}
    property Wrapable: Boolean read FWrapable write SetWrapable;
    property Active: Boolean read FActive write SetActive;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ELSE}

uses
  SysUtils, Classes, Controls;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

type
  TCnEditorToolBarTypeIndex = Integer;
  TCnEditorToolBarCreateEvent = procedure (EditControl: TControl; Sender: TObject) of object;
  TCnEditorToolBarInitEvent = procedure (EditControl: TControl; Sender: TObject) of object;
  TCnEditorToolBarRemoveEvent = procedure (EditControl: TControl; Sender: TObject) of object;

  ICnEditorToolBarService = interface
  ['{BF6B4399-270A-4E24-8137-587162D12497}']
    function RegisterToolBarType(const ToolBarType: string;
      CreateEvent: TCnEditorToolBarCreateEvent;
      InitEvent: TCnEditorToolBarInitEvent;
      RemoveEvent: TCnEditorToolBarRemoveEvent): TCnEditorToolBarTypeIndex;
    {* 允许外部模块注册一工具栏类型并提供回调函数供创建、初始化与删除，
       返回此类工具栏的索引号}
    procedure SetVisible(ToolBarTypeIndex: TCnEditorToolBarTypeIndex;
      AParent: TControl; Visible: Boolean; Forced: Boolean);
    {* 设置某类工具栏是否全部可见或全部不可见，如果 ToolBarTypeIndex 是 -1，
       则表示所有类都设置，如 AParent 不为空，表示设置与该 AParent 相关的
       ToolBar, Forced 用于 BDS 表示强制设置，不管 EditControl 等的相关条件}
    function GetVisible(ToolBarTypeIndex: TCnEditorToolBarTypeIndex): Boolean;
    {* 获得某类工具栏是否可见}
    procedure CheckEditorToolbarEnable;
    {* 由外部 Timer 定时调用，检查 BDS 下的工具栏是否应该在界面切换时切换 Visible}
    procedure LanguageChanged;
    {* 供外部调用的语言改变通知}
  end;

var
  CnEditorToolBarService: ICnEditorToolBarService = nil;
  {* 编辑器工具栏服务提供者}
  CreateEditorToolBarServiceProc: TProcedure = nil;
  {* 创建编辑器工具栏服务的入口}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Math, TypInfo, CnCommon, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnWizShareImages, CnFlatToolbarConfigFrm, CnWizOptions;

const
  SCnSrcEditorToolBar = 'CnSrcEditorToolBar';

  csToolBar = 'ToolBar';
  csShowToolBar = 'ShowToolBar';
  csShowInDesign = 'ShowInDesign';
  csWrapable = 'Wrapable';

type
  TCnEditorToolBarObj = class(TComponent)
  {* 用以描述一类工具栏与其所有实例，包含回调函数与对 EditControl 的引用}
  private
    FCreateEvent: TCnEditorToolBarCreateEvent;
    FToolBars: TList;
    FEditControls: TList;
    FInitEvent: TCnEditorToolBarInitEvent;
    FRemoveEvent: TCnEditorToolBarRemoveEvent;
    FToolBarVisible: Boolean;
    function GetToolBars(Index: Integer): TControl;
    function GetToolBarCount: Integer;
    function GetEditControls(Index: Integer): TControl;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddToolBar(AToolBar: TControl; EditControl: TControl);
    procedure RemoveEditControlFromIndex(Index: Integer);

    property CreateEvent: TCnEditorToolBarCreateEvent read FCreateEvent write FCreateEvent;
    property InitEvent: TCnEditorToolBarInitEvent read FInitEvent write FInitEvent;
    property RemoveEvent: TCnEditorToolBarRemoveEvent read FRemoveEvent write FRemoveEvent;
    property EditControls[Index: Integer]: TControl read GetEditControls;
    property ToolBars[Index: Integer]: TControl read GetToolBars;
    property ToolBarCount: Integer read GetToolBarCount;
    property ToolBarVisible: Boolean read FToolBarVisible write FToolBarVisible;
  end;

  TCnExternalEditorToolBarMgr = class(TInterfacedObject, ICnEditorToolBarService)
  private
    FToolBarTypes: TStrings;
    procedure DoInstallToolBars(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
  protected
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure InstallToolBars;
    function RegisterToolBarType(const ToolBarType: string;
      CreateEvent: TCnEditorToolBarCreateEvent;
      InitEvent: TCnEditorToolBarInitEvent;
      RemoveEvent: TCnEditorToolBarRemoveEvent): TCnEditorToolBarTypeIndex;
    procedure SetVisible(ToolBarTypeIndex: TCnEditorToolBarTypeIndex;
      AParent: TControl; Visible: Boolean; Forced: Boolean);
    function GetVisible(ToolBarTypeIndex: TCnEditorToolBarTypeIndex): Boolean;
    procedure CheckEditorToolbarEnable;
    procedure LanguageChanged;
  end;

//==============================================================================
// 代码编辑器工具栏
//==============================================================================

{ TCnSrcEditorToolButton }

procedure TCnSrcEditorToolButton.Click;
begin
  // 有时候按钮点击执行的操作中将 ToolBar 释放了，会导致出错。如点击“打开”按钮
  // 打开一个新的工程会释放当前编辑器重建一个。此处将 Click 事件转到 OnIdle 时去
  // 执行，以修正此类问题。
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoClick)
end;

procedure TCnSrcEditorToolButton.DoClick(Sender: TObject);
begin
  inherited Click;
end;

procedure TCnSrcEditorToolButton.OnPopup(Sender: TObject);
var
  Menu: Menus.TPopupMenu;
begin
  if (Sender <> nil) and (Sender is Menus.TPopupMenu) then
  begin
    Menu := Menus.TPopupMenu((Sender as TComponent).Tag);
    if Menu <> nil then
    begin
      FMenu.Items.Clear;
      if Assigned(Menu.OnPopup) then
        Menu.OnPopup(Menu); // 触发一下原始的 Menu 的弹出
      // 从 Menu 中复制所有 Items 过来
      CloneMenuItem(Menu.Items, FMenu.Items);
    end;
  end;  
end;

{ TCnSrcEditorToolBar }

constructor TCnSrcEditorToolBar.Create(AOwner: TComponent);
begin
  inherited;
  FMenu := TPopupMenu.Create(Self);
end;

destructor TCnSrcEditorToolBar.Destroy;
begin
  FToolBarMgr.FList.Remove(Self);
  inherited;
end;

//------------------------------------------------------------------------------
// 工具栏初始化及更新
//------------------------------------------------------------------------------

{$IFDEF BDS}
procedure TCnSrcEditorToolBar.SetEnabled(Value: Boolean);
begin
// 什么也不做，以阻挡 BDS 下切换页面时 Disable 工具栏的操作
end;
{$ENDIF}

procedure TCnSrcEditorToolBar.InitControls;
begin
  InitPopupMenu;
  Caption := '';
  AutoSize := True;
  Align := alTop;
  EdgeBorders := [ebBottom];
  Flat := True;
  DockSite := False;
  Wrapable := FToolBarMgr.Wrapable;
  Images := GetIDEImageList;
  ShowHint := True;
  PopupMenu := FMenu;
  RecreateButtons;
end;

procedure TCnSrcEditorToolBar.InitPopupMenu;
begin
  FMenu.Items.Clear;
  AddMenuItem(FMenu.Items, SCnMenuFlatFormCustomizeCaption, OnConfig);
  AddSepMenuItem(Menu.Items);
  AddMenuItem(FMenu.Items, SCnEditorEnhanceConfig, OnEnhConfig);
  AddMenuItem(FMenu.Items, SCnToolBarClose, OnClose);
end;

procedure TCnSrcEditorToolBar.RecreateButtons;
var
  i: Integer;
  Btn: TCnSrcEditorToolButton;
  IDEBtn: TToolButton;
  MenuObj: TObject;
  Act: TBasicAction;
  Actions: TStringList;
  Svcs40: INTAServices40;
  IDEToolBarParent: TWinControl;

  // 查找 IDE 中的相应的 ToolButton
  function FindIDEToolButton(AAction: TBasicAction): TToolButton;
  var
    i, j: Integer;
  begin
    Result := nil;
    if IDEToolBarParent <> nil then
    begin
      for i := 0 to IDEToolBarParent.ControlCount - 1 do
        if IDEToolBarParent.Controls[i] is TToolBar then
        with IDEToolBarParent.Controls[i] as TToolBar do
          for j := 0 to ButtonCount - 1 do
            if Buttons[j].Action = AAction then
            begin
              Result := Buttons[j];
              Exit;
            end;
    end;
  end;
begin
  for i := ButtonCount - 1 downto 0 do
    Buttons[i].Free;

  Actions := FToolBarMgr.FToolBarActions;
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  if Svcs40.ToolBar[sStandardToolBar] <> nil then
    IDEToolBarParent := Svcs40.ToolBar[sStandardToolBar].Parent;
  for i := Actions.Count - 1 downto 0 do
  begin
    if Actions[i] = '-' then
    begin
      Btn := TCnSrcEditorToolButton.Create(Self);
      Btn.Style := tbsSeparator;
      if Align in [alTop, alBottom] then
        Btn.Width := 4
      else
        Btn.Height := 4;
      Btn.SetToolBar(Self);
    end
    else
    begin
      Act := FindIDEAction(Actions[i]);
      if Act <> nil then
      begin
        Btn := TCnSrcEditorToolButton.Create(Self);
        Btn.Action := Act;
        if Btn.ImageIndex < 0 then
          Btn.ImageIndex := dmCnSharedImages.IdxUnknownInIDE;
        if Btn.Caption = '' then
          Btn.Caption := Btn.Name;
        if Btn.Hint = '' then
          Btn.Hint := StripHotkey(Btn.Caption);

        // 处理带下拉菜单的按钮
        IDEBtn := FindIDEToolButton(Act);
        if IDEBtn <> nil then
        begin
          // 直接用属性取得的始终是空，估计 IDE 的 TCommandButton 重定义了这个属性
          MenuObj := GetObjectProp(IDEBtn, 'DropdownMenu');
          if (MenuObj <> nil) and (MenuObj is Menus.TPopupMenu) then
          begin
            Btn.Style := tbsDropDown;
            if Btn.FMenu <> nil then
              FreeAndNil(Btn.FMenu);
            Btn.FMenu := TPopupMenu.Create(Btn);
            Btn.FMenu.Tag := Integer(MenuObj);
            Btn.FMenu.OnPopup := Btn.OnPopup;
            Btn.DropdownMenu := Btn.FMenu;
          end;
        end;
        Btn.SetToolBar(Self);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 事件处理
//------------------------------------------------------------------------------

procedure TCnSrcEditorToolBar.OnConfig(Sender: TObject);
begin
  FToolBarMgr.ConfigToolBar;
end;

procedure TCnSrcEditorToolBar.OnClose(Sender: TObject);
begin
  InfoDlg(SCnToolBarCloseHint);
  FToolBarMgr.ShowToolBar := False;
end;

procedure TCnSrcEditorToolBar.OnEnhConfig(Sender: TObject);
begin
  FToolBarMgr.DoEnhConfig;
end;

procedure TCnSrcEditorToolBar.LanguageChanged(Sender: TObject);
begin
  InitPopupMenu;
end;

//==============================================================================
// 代码编辑器工具栏管理器
//==============================================================================

{ TCnSrcEditorToolBarMgr }

constructor TCnSrcEditorToolBarMgr.Create;
begin
  inherited;
  FWrapable := True;
  FShowToolBar := True;
  FActive := True;

  FToolBarActions := TStringList.Create;
  FList := TList.Create;
  
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  InstallToolBars;
end;

destructor TCnSrcEditorToolBarMgr.Destroy;
var
  i: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for i := FList.Count - 1 downto 0 do
    TCnSrcEditorToolBar(FList[i]).Free;
  FList.Free;
  FToolBarActions.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 工具条安装及更新
//------------------------------------------------------------------------------

function TCnSrcEditorToolBarMgr.CanShowToolBar: Boolean;
begin
  Result := Active and ShowToolBar;
end;

procedure TCnSrcEditorToolBarMgr.DoInstallToolBars(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
var
  ToolBar: TCnSrcEditorToolBar;
begin
  ToolBar := TCnSrcEditorToolBar(EditWindow.FindComponent(SCnSrcEditorToolBar));
  if CanShowToolBar then
  begin
    if ToolBar = nil then
    begin
      ToolBar := TCnSrcEditorToolBar.Create(EditWindow);
      ToolBar.FToolBarMgr := Self;
      ToolBar.Name := SCnSrcEditorToolBar;
      ToolBar.Parent := EditControl.Parent;
      ToolBar.InitControls;
      FList.Add(ToolBar);
    end;
  end
  else if ToolBar <> nil then
  begin
    ToolBar.Free;
  end;
end;

procedure TCnSrcEditorToolBarMgr.InstallToolBars;
begin
  EnumEditControl(DoInstallToolBars, nil);
end;

procedure TCnSrcEditorToolBarMgr.UpdateToolBars;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    ToolBars[I].RecreateButtons;
    ToolBars[I].InitPopupMenu;
  end; 
end;

procedure TCnSrcEditorToolBarMgr.EditControlNotify(EditControl: TControl;
  EditWindow: TCustomForm; Operation: TOperation);
begin
  if Operation = opInsert then
    InstallToolBars;
end;

//------------------------------------------------------------------------------
// 工具条配置相关
//------------------------------------------------------------------------------

procedure TCnSrcEditorToolBarMgr.LoadToolBarActions(const FileName: string);
var
  Value: string;
  i: Integer;
begin
  FToolBarActions.Clear;
  with TMemIniFile.Create(FileName) do
  try
    i := 0;
    while ValueExists(csToolBar, csButton + IntToStr(i)) do
    begin
      Value := Trim(ReadString(csToolBar, csButton + IntToStr(i), ''));
      if Value <> '' then
        FToolBarActions.Add(Value);
      Inc(i);
    end;
  finally
    Free;
  end;
end;

procedure TCnSrcEditorToolBarMgr.SaveToolBarActions(const FileName: string);
var
  i: Integer;
begin
  with TMemIniFile.Create(FileName) do
  try
    EraseSection(csToolBar);
    for i := 0 to FToolBarActions.Count - 1 do
      WriteString(csToolBar, csButton + IntToStr(i), FToolBarActions[i]);
  finally
    UpdateFile;
    Free;
  end;
end;

procedure TCnSrcEditorToolBarMgr.ConfigToolBar;
begin
  with TCnFlatToolbarConfigForm.Create(nil) do
  try
    SetStyle(tbsEditor, SCnEditorToolBarDataName, 'CnSrcEditorToolbarConfigForm');
    ToolbarActions := FToolBarActions;
    if ShowModal = mrOk then
    begin
      FToolBarActions.Assign(ToolbarActions);

      SaveToolBarActions(WizOptions.GetUserFileName(SCnEditorToolBarDataName, False));
      WizOptions.CheckUserFile(SCnEditorToolBarDataName);
      UpdateToolBars;
    end;
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// 参数设置相关
//------------------------------------------------------------------------------

procedure TCnSrcEditorToolBarMgr.LanguageChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    ToolBars[I].InitPopupMenu;
end;

procedure TCnSrcEditorToolBarMgr.LoadSettings(Ini: TCustomIniFile);
begin
  ShowToolBar := Ini.ReadBool(csToolBar, csShowToolBar, FShowToolBar);
{$IFDEF BDS}
  ShowInDesign := Ini.ReadBool(csToolBar, csShowInDesign, False);
{$ENDIF}
  Wrapable := Ini.ReadBool(csToolBar, csWrapable, FWrapable);
  LoadToolBarActions(WizOptions.GetUserFileName(SCnEditorToolBarDataName, True));
end;

procedure TCnSrcEditorToolBarMgr.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csToolBar, csShowToolBar, FShowToolBar);
{$IFDEF BDS}
  Ini.WriteBool(csToolBar, csShowInDesign, FShowInDesign);
{$ENDIF}
  Ini.WriteBool(csToolBar, csWrapable, FWrapable);
  SaveToolBarActions(WizOptions.GetUserFileName(SCnEditorToolBarDataName, False));
  WizOptions.CheckUserFile(SCnEditorToolBarDataName);
end;

procedure TCnSrcEditorToolBarMgr.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

function TCnSrcEditorToolBarMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnSrcEditorToolBarMgr.GetToolBar(Index: Integer): TCnSrcEditorToolBar;
begin
  Result := TCnSrcEditorToolBar(FList[Index]);
end;

procedure TCnSrcEditorToolBarMgr.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    InstallToolBars;
  end;
end;

procedure TCnSrcEditorToolBarMgr.SetShowToolBar(const Value: Boolean);
begin
  if FShowToolBar <> Value then
  begin
    FShowToolBar := Value;
    InstallToolBars;
  end;
end;

procedure TCnSrcEditorToolBarMgr.SetWrapable(Value: Boolean);
var
  I: Integer;
begin
  if FWrapable <> Value then
  begin
    FWrapable := Value;
    for I := 0 to Count - 1 do
      ToolBars[I].Wrapable := Value;
  end;
end;

{$IFDEF BDS}

procedure TCnSrcEditorToolBarMgr.SetShowInDesign(const Value: Boolean);
begin
  FShowInDesign := Value;
end;

{$ENDIF}

{ TCnExternalEditorToolBarMgr }

constructor TCnExternalEditorToolBarMgr.Create;
begin
  inherited;
  FToolBarTypes := TStringList.Create;

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  InstallToolBars;
end;

destructor TCnExternalEditorToolBarMgr.Destroy;
var
  I: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  
  for I := FToolBarTypes.Count - 1 downto 0 do
    TObject(FToolBarTypes.Objects[I]).Free;
  FToolBarTypes.Free;
  inherited;
end;

procedure TCnExternalEditorToolBarMgr.DoInstallToolBars(
  EditWindow: TCustomForm; EditControl: TControl; Context: Pointer);
var
  I: Integer;
  ToolBar: TToolBar;
  Obj: TCnEditorToolBarObj;
begin
  for I := 0 to FToolBarTypes.Count - 1 do
  begin
    ToolBar := TToolBar(EditWindow.FindComponent(FToolBarTypes[I]));
    Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[I]);
    if ToolBar = nil then
    begin
      ToolBar := TCnExternalSrcEditorToolBar.Create(EditWindow);
      ToolBar.Name := FToolBarTypes[I];
      ToolBar.Tag := Integer(EditControl); // 用 Tag 记录和其对应的 EditoControl

      ToolBar.Parent := EditControl.Parent;
      (ToolBar as TCnExternalSrcEditorToolBar).InitControls;

      if Assigned(Obj.CreateEvent) then
        Obj.CreateEvent(EditControl, ToolBar);
      if Assigned(Obj.InitEvent) then
        Obj.InitEvent(EditControl, ToolBar);

      ToolBar.Visible := Obj.ToolBarVisible;
      if Obj.ToolBarVisible then
        ToolBar.Update;
      Obj.AddToolBar(ToolBar, EditControl);
    end;
  end;
end;

procedure TCnExternalEditorToolBarMgr.EditControlNotify(
  EditControl: TControl; EditWindow: TCustomForm; Operation: TOperation);
var
  I, J: Integer;
  Obj: TCnEditorToolBarObj;
begin
  if Operation = opInsert then
    DoInstallToolBars(EditWindow, EditControl, nil)
  else if Operation = opRemove then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnEditorToolBarObj EditControl Removed: %8.8x.',
      [Integer(EditControl)]);
{$ENDIF}
    for I := FToolBarTypes.Count - 1 downto 0 do
    begin
      Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[I]);
      for J := Obj.ToolBarCount - 1 downto 0 do
      begin
        if Obj.EditControls[J] = EditControl then
        begin
          // 为了避免出现 EditControl 释放而 ToolBar 没有释放的情况，此处手工释放掉。
          // 由 ToolBar 释放的 Notification 通知来处理剩下的事情。
          Obj.ToolBars[J].Free;
        end;
      end;
    end;
  end;
end;

function TCnExternalEditorToolBarMgr.GetVisible(
  ToolBarTypeIndex: TCnEditorToolBarTypeIndex): Boolean;
var
  Obj: TCnEditorToolBarObj;
begin
  Result := False;
  if (ToolBarTypeIndex >= 0) and (ToolBarTypeIndex < FToolBarTypes.Count) then
  begin
    Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[ToolBarTypeIndex]);
    Result := Obj.ToolBarVisible;
  end;
end;

procedure TCnExternalEditorToolBarMgr.InstallToolBars;
begin
  EnumEditControl(DoInstallToolBars, nil);
end;

procedure TCnExternalEditorToolBarMgr.LanguageChanged;
var
  I, J: Integer;
  Obj: TCnEditorToolBarObj;
begin
  for I := 0 to FToolBarTypes.Count - 1 do
  begin
    Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[I]);
    for J := 0 to Obj.ToolBarCount - 1 do
      if Obj.ToolBars[J] <> nil then
        if Assigned(Obj.InitEvent) then
        begin
          Obj.InitEvent(Obj.EditControls[J], Obj.ToolBars[J]);
          Obj.ToolBars[J].Update;
        end;
  end;
end;

function TCnExternalEditorToolBarMgr.RegisterToolBarType(const ToolBarType:
  string; CreateEvent: TCnEditorToolBarCreateEvent; InitEvent:
  TCnEditorToolBarInitEvent; RemoveEvent: TCnEditorToolBarRemoveEvent):
  TCnEditorToolBarTypeIndex;
var
  Obj: TCnEditorToolBarObj;
begin
  Result := FToolBarTypes.IndexOf(ToolBarType);
  if (ToolBarType <> '') and (Result = -1) then
  begin
    Obj := TCnEditorToolBarObj.Create(nil);
    Obj.ToolBarVisible := True;
    Obj.CreateEvent := CreateEvent;
    Obj.InitEvent := InitEvent;
    Obj.RemoveEvent := RemoveEvent;
    Result := FToolBarTypes.AddObject(ToolBarType, Obj);

    InstallToolBars;
  end;
end;

procedure TCnExternalEditorToolBarMgr.CheckEditorToolbarEnable;
{$IFDEF BDS}
var
  I, J, K: Integer;
  AControl: TControl;
  Obj: TCnEditorToolBarObj;
{$ENDIF}
begin
{$IFDEF BDS}
  for I := 0 to FToolBarTypes.Count - 1 do
  begin
    Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[I]);
    if not Obj.ToolBarVisible then
      Continue;

    // 检查所有可见的工具栏
    for J := 0 to Obj.ToolBarCount - 1 do
    begin
      if (Obj.ToolBars[J] <> nil) and (Obj.ToolBars[J].Parent <> nil) then
      begin
        for K := Obj.ToolBars[J].Parent.ControlCount - 1 downto 0 do
        begin
          AControl := Obj.ToolBars[J].Parent.Controls[K];
          if AControl.Align = alClient then // 找到第一个 alcient 的 Control
          begin
            // 如果是 EditControl 就可见
            Obj.ToolBars[J].Visible := AControl.ClassNameIs(EditControlClassName);
            Break;
          end;
        end;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnExternalEditorToolBarMgr.SetVisible(
  ToolBarTypeIndex: TCnEditorToolBarTypeIndex; AParent: TControl;
  Visible: Boolean; Forced: Boolean);
var
  Obj: TCnEditorToolBarObj;
  I, J: Integer;
  ActualVisible: Boolean;
begin
  // 如果 Forced 为 True，则强行设置，ActualVisible := Visible
  // 如果 Forced 为 False，则要看 ToolBar 本身的 ToolBarVisible，按下表：
  // ToolBarVisible Vislble   -> ActualVisible
  // True，         True         True
  // True，         False        False
  // False，        True         False
  // False，        False        False
  // 因此不 Forced 时 ActualVisible := Visible and Obj.ToolBarVisible

  ActualVisible := Visible;

  if ToolBarTypeIndex <> -1 then
  begin
    Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[ToolBarTypeIndex]);
    if not Forced then
      ActualVisible := Visible and Obj.ToolBarVisible
    else
      Obj.ToolBarVisible := Visible;

    for I := 0 to Obj.ToolBarCount - 1 do
      if Obj.ToolBars[I] <> nil then
        if (AParent = nil) or (Obj.ToolBars[I].Parent = AParent) then
          Obj.ToolBars[I].Visible := ActualVisible;
  end
  else
  begin
    if Visible then
    begin
      for J := 0 to FToolBarTypes.Count - 1 do
      begin
        Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[J]);
        if not Forced then
          ActualVisible := Visible and Obj.ToolBarVisible
        else
          Obj.ToolBarVisible := Visible;

        for I := 0 to Obj.ToolBarCount - 1 do
          if Obj.ToolBars[I] <> nil then
            if (AParent = nil) or (Obj.ToolBars[I].Parent = AParent) then
              Obj.ToolBars[I].Visible := ActualVisible;
      end;
    end
    else // 设置可见与不可见时按倒序来，否则工具栏之间可能错位
    begin
      for J := FToolBarTypes.Count - 1 downto 0 do
      begin
        Obj := TCnEditorToolBarObj(FToolBarTypes.Objects[J]);
        if not Forced then
          ActualVisible := Visible and Obj.ToolBarVisible
        else
          Obj.ToolBarVisible := Visible;

        for I := 0 to Obj.ToolBarCount - 1 do
          if Obj.ToolBars[I] <> nil then
            if (AParent = nil) or (Obj.ToolBars[I].Parent = AParent) then
              Obj.ToolBars[I].Visible := ActualVisible;
      end;
    end;
  end;
end;

{ TCnEditorToolBarObj }

procedure TCnEditorToolBarObj.AddToolBar(AToolBar: TControl; EditControl: TControl);
begin
  FToolBars.Add(AToolBar);
  FEditControls.Add(EditControl);
  AToolBar.FreeNotification(Self);
end;

constructor TCnEditorToolBarObj.Create(AOwner: TComponent);
begin
  inherited;
  FToolBars := TList.Create;
  FEditControls := TList.Create;
end;

destructor TCnEditorToolBarObj.Destroy;
begin
  FEditControls.Free;
  FToolBars.Free;
  inherited;
end;

function TCnEditorToolBarObj.GetEditControls(Index: Integer): TControl;
begin
  Result := TControl(FEditControls[Index]);
end;

function TCnEditorToolBarObj.GetToolBarCount: Integer;
begin
  Result := FToolBars.Count;
end;

function TCnEditorToolBarObj.GetToolBars(Index: Integer): TControl;
begin
  Result := TControl(FToolBars[Index]);
end;

procedure CreateEditorToolBarService;
begin
  CnEditorToolBarService := TCnExternalEditorToolBarMgr.Create;
end;

procedure TCnEditorToolBarObj.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if Operation = opRemove then
    for I := ToolBarCount - 1 downto 0 do
      if AComponent = FToolBars[I] then
      begin
        // 删除 ToolBar 时，调用 RemoveEvent 通知释放其它东西
        if Assigned(FRemoveEvent)
          and (AComponent.Tag <> 0) and (TObject(AComponent.Tag) is TControl) then
          FRemoveEvent(TObject(AComponent.Tag) as TControl, AComponent);

        // 从列表中直接删除
        FToolBars.Delete(I);
        FEditControls.Delete(I);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TCnEditorToolBarObj Notification: ToolBar %d %8.8x Removed.',
          [I, Integer(AComponent)]);
{$ENDIF}
      end;
end;

procedure TCnEditorToolBarObj.RemoveEditControlFromIndex(Index: Integer);
begin
  FToolBars.Delete(Index);
  FEditControls.Delete(Index);
end;

{ TCnExternalSrcEditorToolBar }

procedure TCnExternalSrcEditorToolBar.InitControls;
begin
  Caption := '';
  AutoSize := True;
  Align := alTop;
  EdgeBorders := [ebBottom];
  Flat := True;
  DockSite := False;
  ShowHint := True;
end;

{$IFDEF BDS}

procedure TCnExternalSrcEditorToolBar.SetEnabled(Value: Boolean);
begin
// 啥都不做，以避免 BDS 下被误设置为禁用
end;

{$ENDIF}

initialization
  CreateEditorToolBarServiceProc := CreateEditorToolBarService;

finalization
  CnEditorToolBarService := nil;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
