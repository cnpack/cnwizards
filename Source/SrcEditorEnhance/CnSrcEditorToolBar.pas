
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
* 修改记录：2004.12.25
*               创建单元，从原 CnSrcEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms, CnIni,
  ComCtrls, ToolWin, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} IniFiles,
  CnEditControlWrapper, CnWizNotifier, CnWizManager, CnWizMenuAction, CnWizClasses,
  CnWizIni, CnWizIdeUtils, CnPopupMenu, CnConsts, CnNative;

type

//==============================================================================
// 代码编辑器工具栏
//==============================================================================

{ TCnBaseSrcEditorToolBar }

  TCnBaseSrcEditorToolBar = class(TToolBar)
  protected
{$IFDEF BDS}
    procedure SetEnabled(Value: Boolean); override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitControls; virtual;
    function CanShow(APage: TCnSrcEditorPage): Boolean; virtual;
  end;

{ TCnSrcEditorToolButton }

  TCnSrcEditorToolButton = class(TToolButton)
  private
    FIDEMenu: TPopupMenu;
    FLastTick: Cardinal;
    procedure OnPopup(Sender: TObject);
    procedure DoClick(Sender: TObject);
  public
    procedure InitiateAction; override;
    procedure Click; override;

    property IDEMenu: TPopupMenu read FIDEMenu write FIDEMenu;
  end;

{ TCnSrcEditorToolBar }

  TCnSrcEditorToolBarMgr = class;

  TCnSrcEditorToolBarType = (tbtCode, tbtDesign);

  TCnSrcEditorToolBar = class(TCnBaseSrcEditorToolBar)
  private
    FMenu: TPopupMenu;
    FToolBarMgr: TCnSrcEditorToolBarMgr;
    FToolBarType: TCnSrcEditorToolBarType;
    procedure OnConfig(Sender: TObject);
    procedure OnClose(Sender: TObject);
    procedure OnEnhConfig(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitControls; override;
    function CanShow(APage: TCnSrcEditorPage): Boolean; override;
    procedure RecreateButtons;
    procedure InitPopupMenu;
    procedure LanguageChanged(Sender: TObject);
    property Menu: TPopupMenu read FMenu;
    property ToolBarType: TCnSrcEditorToolBarType read FToolBarType write FToolBarType;
  end;

  TCnSrcEditorCanShowEvent = procedure (Sender: TObject; APage: TCnSrcEditorPage;
    var ACanShow: Boolean) of object;

  TCnExternalSrcEditorToolBar = class(TCnBaseSrcEditorToolBar)
  private
    FOnCanShow: TCnSrcEditorCanShowEvent;
  public
    procedure InitControls; override;
    function CanShow(APage: TCnSrcEditorPage): Boolean; override;
    property OnCanShow: TCnSrcEditorCanShowEvent read FOnCanShow write FOnCanShow;
  end;

//==============================================================================
// 代码编辑器工具栏管理器
//==============================================================================

{ TCnSrcEditorToolBarMgr }

  TCnSrcEditorToolBarMgr = class(TPersistent)
  private
    FShowToolBar: Boolean;
    FToolBarActions: TStringList;
    FShowDesignToolBar: Boolean;
    FDesignToolBarActions: TStringList;
    FActive: Boolean;
    FList: TList;
    FOnEnhConfig: TNotifyEvent;
    FWrapable: Boolean;
    procedure LoadToolBarActions(Actions: TStrings; const FileName: string);
    procedure SaveToolBarActions(Actions: TStrings; const FileName: string);
    procedure SetShowToolBar(const Value: Boolean);
    procedure SetShowDesignToolBar(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    procedure DoInstallToolBars(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    procedure DoGetEditList(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetCount: Integer;
    function GetToolBar(Index: Integer): TCnSrcEditorToolBar;
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SetWrapable(Value: Boolean);
  protected
{$IFDEF DELPHI_OTA}
    procedure ThemeChanged(Sender: TObject);
{$ENDIF}
    procedure DoEnhConfig;
    function CanShowToolBar: Boolean;
    function CanShowDesignToolBar: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure InstallToolBars;
    procedure UpdateToolBars;
    procedure ConfigToolBar(AType: TCnSrcEditorToolBarType);
    procedure CheckToolBarEnable;
    procedure LanguageChanged(Sender: TObject);
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);

    property Count: Integer read GetCount;
    property ToolBars[Index: Integer]: TCnSrcEditorToolBar read GetToolBar;

  published
    property ShowToolBar: Boolean read FShowToolBar write SetShowToolBar;
    property ShowDesignToolBar: Boolean read FShowDesignToolBar write SetShowDesignToolBar;
    property Wrapable: Boolean read FWrapable write SetWrapable;
    property Active: Boolean read FActive write SetActive;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ELSE}

uses
  SysUtils, Classes, ComCtrls, Controls;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

type
  TCnEditorToolBarEvent = procedure (const ToolBarType: string;
     EditControl: TControl; ToolBar: TToolBar) of object;

  ICnEditorToolBarService = interface
  ['{BF6B4399-270A-4E24-8137-587162D12497}']
    procedure RegisterToolBarType(const ToolBarType: string;
      CreateEvent: TCnEditorToolBarEvent;
      InitEvent: TCnEditorToolBarEvent;
      RemoveEvent: TCnEditorToolBarEvent);
    {* 允许外部模块注册一工具栏类型并提供回调函数供创建、
       初始化（包括多语切换时，因此可能重复调用）与删除}
    procedure RemoveToolBarType(const ToolBarType: string);
    {* 移除工具栏类型注册}
    procedure SetVisible(const ToolBarType: string; Visible: Boolean);
    {* 设置某类工具栏是否全部可见或全部不可见，如果 ToolBarType 是空，
       则表示所有类都设置}
    function GetVisible(const ToolBarType: string): Boolean;
    {* 获得某类工具栏是否可见}
    procedure LanguageChanged;
    {* 供外部调用的语言改变通知}
  end;

var
  CnEditorToolBarService: ICnEditorToolBarService = nil;
  {* 编辑器工具栏服务提供者}
  CreateEditorToolBarServiceProc: TProcedure = nil;
  {* 创建编辑器工具栏服务的入口}

procedure InitSizeIfLargeIcon(Toolbar: TToolBar; LargeImageList: TImageList);
{* 根据是否大尺寸而设置编辑器工具栏的尺寸，不用于其他工具栏}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  Math, TypInfo, CnCommon, CnWizUtils, CnWizConsts,
  CnWizShareImages, CnFlatToolbarConfigFrm, CnWizOptions;

const
  SCnSrcEditorToolBar = 'CnSrcEditorToolBar';
  SCnSrcEditorDesignToolBar = 'CnSrcEditorDesignToolBar';

  csToolBar = 'ToolBar';
  csButton = 'Button';
  csShowToolBar = 'ShowToolBar';
  csShowDesignToolBar = 'ShowDesignToolBar';
  csWrapable = 'Wrapable';

  csUpdateMinInterval = 500;

type
  TCnEditorToolBarObj = class(TComponent)
  {* 用以描述一类工具栏与其所有实例，包含回调函数与对 EditControl 的引用}
  private
    FToolBars: TList;
    FEditControls: TList;
    FToolBarType: string;
    FToolBarVisible: Boolean;
    FCreateEvent: TCnEditorToolBarEvent;
    FInitEvent: TCnEditorToolBarEvent;
    FRemoveEvent: TCnEditorToolBarEvent;
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

    property CreateEvent: TCnEditorToolBarEvent read FCreateEvent write FCreateEvent;
    property InitEvent: TCnEditorToolBarEvent read FInitEvent write FInitEvent;
    property RemoveEvent: TCnEditorToolBarEvent read FRemoveEvent write FRemoveEvent;
    property EditControls[Index: Integer]: TControl read GetEditControls;
    property ToolBars[Index: Integer]: TControl read GetToolBars;
    property ToolBarCount: Integer read GetToolBarCount;
    property ToolBarVisible: Boolean read FToolBarVisible write FToolBarVisible;
    property ToolBarType: string read FToolBarType write FToolBarType;
  end;

  TCnExternalEditorToolBarMgr = class(TInterfacedObject, ICnEditorToolBarService)
  private
    FToolBarTypes: TStrings;
    procedure DoInstallToolBars(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    procedure DoUpdateToolbarTheme(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    function GetToolBarObj(ToolBarType: string): TCnEditorToolBarObj;
  protected
    procedure ThemeChanged(Sender: TObject);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure InstallToolBars;
    procedure RegisterToolBarType(const ToolBarType: string;
      CreateEvent: TCnEditorToolBarEvent;
      InitEvent: TCnEditorToolBarEvent;
      RemoveEvent: TCnEditorToolBarEvent);
    procedure RemoveToolBarType(const ToolBarType: string);
    procedure SetVisible(const ToolBarType: string; Visible: Boolean);
    function GetVisible(const ToolBarType: string): Boolean;
    procedure LanguageChanged;
    property ToolBarObj[ToolBarType: string]: TCnEditorToolBarObj read GetToolBarObj;
  end;

var
  ExternalEditorToolBarMgr: TCnExternalEditorToolBarMgr;
  CnSrcEditorToolBarMgr: TCnSrcEditorToolBarMgr;

procedure InitSizeIfLargeIcon(Toolbar: TToolBar; LargeImageList: TImageList);
begin
  if (Toolbar <> nil) and WizOptions.UseLargeIcon then
  begin
    Toolbar.Height := IdeGetScaledPixelsFromOrigin(csLargeToolbarHeight, Toolbar);
    Toolbar.ButtonWidth := IdeGetScaledPixelsFromOrigin(csLargeToolbarButtonWidth, Toolbar);
    Toolbar.ButtonHeight := IdeGetScaledPixelsFromOrigin(csLargeToolbarButtonHeight, Toolbar);
    if LargeImageList <> nil then
      Toolbar.Images := LargeImageList;

{$IFDEF DEBUG}
    if LargeImageList <> nil then
      CnDebugger.LogMsg('SrcEditorToolbar InitSizeIfLargeIcon. LargeIcons: '
        + IntToStr(LargeImageList.Count));
{$ENDIF}
  end;
end;

//==============================================================================
// 代码编辑器工具栏
//==============================================================================

{ TCnBaseSrcEditorToolBar }

constructor TCnBaseSrcEditorToolBar.Create(AOwner: TComponent);
{$IFDEF BDS2006_UP}
var
  barStdTool: TToolBar;
{$ENDIF}
begin
  inherited;
  Caption := '';
  DockSite := False;
  ShowHint := True;
  EdgeBorders := [ebBottom];
  Flat := True;
{$IFDEF DELPHI_OTA}
  ApplyThemeOnToolBar(Self);
{$ENDIF}

{$IFDEF BDS2006_UP}
  barStdTool := (BorlandIDEServices as INTAServices).ToolBar[sStandardToolBar];
  if Assigned(barStdTool) then
  begin
    DrawingStyle := barStdTool.DrawingStyle;
    GradientDirection := barStdTool.GradientDirection;
    GradientDrawingOptions := barStdTool.GradientDrawingOptions;
    GradientStartColor := barStdTool.GradientStartColor;
    GradientEndColor := barStdTool.GradientEndColor;
  end;
{$ENDIF}
end;

{$IFDEF BDS}
procedure TCnBaseSrcEditorToolBar.SetEnabled(Value: Boolean);
begin
// 什么也不做，以阻挡 BDS 下切换页面时 Disable 工具栏的操作
end;
{$ENDIF}

procedure TCnBaseSrcEditorToolBar.InitControls;
begin

end;

function TCnBaseSrcEditorToolBar.CanShow(APage: TCnSrcEditorPage): Boolean;
begin
  Result := False;
end;

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

procedure TCnSrcEditorToolButton.InitiateAction;
begin
  // 减少调用次数，降低 CPU 占用率
  if Abs(GetTickCount - FLastTick) > csUpdateMinInterval then
  begin
    inherited InitiateAction;
    FLastTick := GetTickCount;
  end;
end;

procedure TCnSrcEditorToolButton.OnPopup(Sender: TObject);
var
  Menu: Menus.TPopupMenu;
begin
  if (Sender <> nil) and (Sender is Menus.TPopupMenu) then
  begin
    Menu := Menus.TPopupMenu((Sender as TComponent).Tag);
    if (Menu <> nil) and (FIDEMenu <> nil) then
    begin
      FIDEMenu.Items.Clear;
      if Assigned(Menu.OnPopup) then
        Menu.OnPopup(Menu); // 触发一下原始的 Menu 的弹出
      // 从 Menu 中复制所有 Items 过来
      CloneMenuItem(Menu.Items, FIDEMenu.Items);
    end;
  end;  
end;

{ TCnSrcEditorToolBar }

constructor TCnSrcEditorToolBar.Create(AOwner: TComponent);
begin
  inherited;
  FMenu := TPopupMenu.Create(Self);
  FMenu.Images := dmCnSharedImages.GetMixedImageList;
end;

destructor TCnSrcEditorToolBar.Destroy;
begin
  FToolBarMgr.FList.Remove(Self);
  inherited;
end;

//------------------------------------------------------------------------------
// 工具栏初始化及更新
//------------------------------------------------------------------------------

procedure TCnSrcEditorToolBar.InitControls;
begin
  inherited;
  AutoSize := True;
  Top := -1;
  Align := alTop;
  Images := GetIDEImageList;
{$IFDEF DELPHI_IDE_WITH_HDPI}
  InitSizeIfLargeIcon(Self, TImageList(dmCnSharedImages.IDELargeVirtualImages));
{$ELSE}
  InitSizeIfLargeIcon(Self, dmCnSharedImages.IDELargeImages);
{$ENDIF}

  InitPopupMenu;
  Wrapable := FToolBarMgr.Wrapable;
  PopupMenu := FMenu;
  RecreateButtons;
  Visible := CanShow(GetCurrentTopEditorPage(Parent));
end;

procedure TCnSrcEditorToolBar.InitPopupMenu;
var
  AItem: TMenuItem;
begin
  FMenu.Items.Clear;
  AItem := AddMenuItem(FMenu.Items, SCnMenuFlatFormCustomizeCaption, OnConfig);
  AItem.ImageIndex := dmCnSharedImages.CalcMixedImageIndex(92);
  AddSepMenuItem(Menu.Items);
  AItem := AddMenuItem(FMenu.Items, SCnEditorEnhanceConfig, OnEnhConfig);

  AItem.ImageIndex := CnWizardMgr.ImageIndexByWizardClassNameAndCommand(
    'TCnIdeEnhanceMenuWizard', SCnIdeEnhanceMenuCommand + 'TCnSrcEditorEnhance');

  AItem := AddMenuItem(FMenu.Items, SCnToolBarClose, OnClose);
  AItem.ImageIndex := dmCnSharedImages.CalcMixedImageIndex(13);
end;

function TCnSrcEditorToolBar.CanShow(APage: TCnSrcEditorPage): Boolean;
begin
  if APage in [epCode, epCPU] then
    Result := FToolBarType = tbtCode
  else if APage in [epDesign] then
    Result := FToolBarType = tbtDesign
  else
    Result := False;
end;
  
procedure TCnSrcEditorToolBar.RecreateButtons;
var
  I: Integer;
  Btn: TCnSrcEditorToolButton;
  IDEBtn: TToolButton;
  MenuObj: TObject;
  Act: TBasicAction;
  Actions: TStringList;
{$IFDEF DELPHI_OTA}
  Svcs40: INTAServices40;
{$ENDIF}
  IDEToolBarParent: TWinControl;

  // 查找 IDE 中的相应的 ToolButton
  function FindIDEToolButton(AAction: TBasicAction): TToolButton;
  var
    I, J: Integer;
  begin
    Result := nil;
    if IDEToolBarParent <> nil then
    begin
      for I := 0 to IDEToolBarParent.ControlCount - 1 do
      begin
        if IDEToolBarParent.Controls[I] is TToolBar then
        begin
          with IDEToolBarParent.Controls[I] as TToolBar do
          begin
            for J := 0 to ButtonCount - 1 do
            begin
              if Buttons[J].Action = AAction then
              begin
                Result := Buttons[J];
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  for I := ButtonCount - 1 downto 0 do
    Buttons[I].Free;

  if FToolBarType = tbtCode then
    Actions := FToolBarMgr.FToolBarActions
  else
    Actions := FToolBarMgr.FDesignToolBarActions;

  IDEToolBarParent := nil;
{$IFDEF DELPHI_OTA}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  if Svcs40.ToolBar[sStandardToolBar] <> nil then
    IDEToolBarParent := Svcs40.ToolBar[sStandardToolBar].Parent;
{$ENDIF}

  for I := Actions.Count - 1 downto 0 do
  begin
    if Actions[I] = '-' then
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
      Act := FindIDEAction(Actions[I]);
      if Act <> nil then
      begin
        Btn := TCnSrcEditorToolButton.Create(Self);
        Btn.Action := Act;
        if Btn.ImageIndex < 0 then
          Btn.ImageIndex := dmCnSharedImages.IdxUnknownInIDE; // 确保有个图标

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
            if Btn.IDEMenu <> nil then
              FreeAndNil(Btn.FIDEMenu);
            Btn.IDEMenu := TPopupMenu.Create(Btn);
            Btn.IDEMenu.Tag := TCnNativeInt(MenuObj);
            Btn.IDEMenu.OnPopup := Btn.OnPopup;
            Btn.DropdownMenu := Btn.IDEMenu;
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
  FToolBarMgr.ConfigToolBar(FToolBarType);
end;

procedure TCnSrcEditorToolBar.OnClose(Sender: TObject);
begin
  InfoDlg(SCnToolBarCloseHint);
  if FToolBarType = tbtCode then
    FToolBarMgr.ShowToolBar := False
  else
    FToolBarMgr.ShowDesignToolBar := False;
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
  CnSrcEditorToolBarMgr := Self;

  FWrapable := True;
  FShowToolBar := True;
  FShowDesignToolBar := True;
  FActive := True;

  FToolBarActions := TStringList.Create;
  FDesignToolBarActions := TStringList.Create;
  FList := TList.Create;
{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.AddAfterThemeChangeNotifier(ThemeChanged);
{$ENDIF}
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  InstallToolBars;
end;

destructor TCnSrcEditorToolBarMgr.Destroy;
var
  I: Integer;
begin
  CnSrcEditorToolBarMgr := nil;
{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.RemoveAfterThemeChangeNotifier(ThemeChanged);
{$ENDIF}
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for I := FList.Count - 1 downto 0 do
    TCnSrcEditorToolBar(FList[I]).Free;

  FList.Free;
  FToolBarActions.Free;
  FDesignToolBarActions.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 工具条安装及更新
//------------------------------------------------------------------------------

function TCnSrcEditorToolBarMgr.CanShowToolBar: Boolean;
begin
  Result := Active and ShowToolBar;
end;

function TCnSrcEditorToolBarMgr.CanShowDesignToolBar: Boolean;
begin
  Result := Active and ShowDesignToolBar and IdeGetIsEmbeddedDesigner;
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
      ToolBar.FToolBarType := tbtCode;
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
{$IFDEF BDS}
  ToolBar := TCnSrcEditorToolBar(EditWindow.FindComponent(SCnSrcEditorDesignToolBar));
  if CanShowDesignToolBar then
  begin
    if ToolBar = nil then
    begin
      ToolBar := TCnSrcEditorToolBar.Create(EditWindow);
      ToolBar.FToolBarType := tbtDesign;
      ToolBar.FToolBarMgr := Self;
      ToolBar.Name := SCnSrcEditorDesignToolBar;
      ToolBar.Parent := EditControl.Parent;
      ToolBar.InitControls;
      FList.Add(ToolBar);
    end;
  end
  else if ToolBar <> nil then
  begin
    ToolBar.Free;
  end;
{$ENDIF}
end;

procedure TCnSrcEditorToolBarMgr.DoGetEditList(EditWindow: TCustomForm; EditControl: TControl;
  Context: Pointer);
begin
  if (EditControl <> nil) and (TList(Context).IndexOf(EditControl.Parent) <= 0) then
    TList(Context).Add(EditControl.Parent);
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

procedure TCnSrcEditorToolBarMgr.LoadToolBarActions(Actions: TStrings;
  const FileName: string);
var
  Value: string;
  I: Integer;
begin
  Actions.Clear;
  with TMemIniFile.Create(FileName) do
  try
    I := 0;
    while ValueExists(csToolBar, csButton + IntToStr(I)) do
    begin
      Value := Trim(ReadString(csToolBar, csButton + IntToStr(I), ''));
      if Value <> '' then
        Actions.Add(Value);
      Inc(I);
    end;
  finally
    Free;
  end;
end;

procedure TCnSrcEditorToolBarMgr.SaveToolBarActions(Actions: TStrings;
  const FileName: string);
var
  I: Integer;
begin
  with TMemIniFile.Create(FileName) do
  try
    EraseSection(csToolBar);
    for I := 0 to Actions.Count - 1 do
      WriteString(csToolBar, csButton + IntToStr(I), Actions[I]);
  finally
    UpdateFile;
    Free;
  end;
end;

procedure TCnSrcEditorToolBarMgr.ConfigToolBar(AType: TCnSrcEditorToolBarType);
var
  List: TStringList;
  FileName: string;
begin
{$IFDEF CNWIZARDS_CNFORMENHANCEWIZARD}
  with TCnFlatToolbarConfigForm.Create(nil) do
  try
    if AType = tbtCode then
    begin
      List := FToolBarActions;
      FileName := SCnEditorToolBarDataName;
    end
    else
    begin
      List := FDesignToolBarActions;
      FileName := SCnEditorDesignToolBarDataName;
    end;
    SetStyle(tbsEditor, FileName, 'CnSrcEditorToolbarConfigForm');
    ToolbarActions := List;
    if ShowModal = mrOk then
    begin
      List.Assign(ToolbarActions);

      SaveToolBarActions(List, WizOptions.GetUserFileName(FileName, False));
      WizOptions.CheckUserFile(FileName);
      UpdateToolBars;
    end;
  finally
    Free;
  end;
{$ELSE}
  ErrorDlg(SCnError);
{$ENDIF}
end;

procedure TCnSrcEditorToolBarMgr.CheckToolBarEnable;
var
  I, J, K: Integer;
  APage: TCnSrcEditorPage;
  ATop: Integer;
  AControl: TWinControl;
  EditorList: TList;
  VisibleList, InvisibleList: TList;
  TBObj: TCnEditorToolBarObj;
  ExToolBar: TCnExternalSrcEditorToolBar;
begin
  EditorList := TList.Create;
  VisibleList := TList.Create;
  InvisibleList := TList.Create;
  try
    // Build EditorControl.Parent List
    EnumEditControl(DoGetEditList, EditorList);
    for I := 0 to EditorList.Count - 1 do
    begin
      AControl := TWinControl(EditorList[I]);
      APage := GetCurrentTopEditorPage(AControl);
      VisibleList.Clear;
      InvisibleList.Clear;

      // Build Visible and Invisible ToolBar List
      for J := 0 to Count - 1 do
      begin
        if ToolBars[J].Parent = AControl then
          if ToolBars[J].CanShow(APage) then
            VisibleList.Add(ToolBars[J])
          else
            InvisibleList.Add(ToolBars[J]);
      end;

      if ExternalEditorToolBarMgr <> nil then
      begin
        with ExternalEditorToolBarMgr do
        begin
          for J := 0 to FToolBarTypes.Count - 1 do
          begin
            TBObj := TCnEditorToolBarObj(FToolBarTypes.Objects[J]);
            for K := 0 to TBObj.FToolBars.Count - 1 do
            begin
              ExToolBar := TCnExternalSrcEditorToolBar(TBObj.FToolBars[K]);
              if ExToolBar.Parent = AControl then
                if TBObj.ToolBarVisible and ExToolBar.CanShow(APage) then
                  VisibleList.Add(ExToolBar)
                else
                  InvisibleList.Add(ExToolBar);
            end;
          end;
        end;
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('CheckToolBarEnable Should Visible %d, Invisible %d',
        [VisibleList.Count, InvisibleList.Count]);
{$ENDIF}

      // Hide Invisible ToolBars
      for J := InvisibleList.Count - 1 downto 0 do
      begin
        try
          TToolBar(InvisibleList[J]).Visible := False;
        except
          ; // Some times cause AV when Editor Resizing.
        end;
      end;

      // Show Visible ToolBars
      ATop := -1;
      for J := 0 to VisibleList.Count - 1 do
      begin
        try
          TToolBar(VisibleList[J]).Visible := True;
        except
          ; // Some times cause AV when Editor Resizing.
        end;
        TToolBar(VisibleList[J]).Top := ATop;
        ATop := ATop + TToolBar(VisibleList[J]).Height;
      end;  
    end;
  finally
    EditorList.Free;
    VisibleList.Free;
    InvisibleList.Free;
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
  ShowToolBar := Ini.ReadBool(csToolBar, csShowToolBar, True);
  ShowDesignToolBar := Ini.ReadBool(csToolBar, csShowDesignToolBar, True);
  Wrapable := Ini.ReadBool(csToolBar, csWrapable, True);
  LoadToolBarActions(FToolBarActions, WizOptions.GetUserFileName(SCnEditorToolBarDataName, True));
  LoadToolBarActions(FDesignToolBarActions, WizOptions.GetUserFileName(SCnEditorDesignToolBarDataName, True));
end;

procedure TCnSrcEditorToolBarMgr.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csToolBar, csShowToolBar, FShowToolBar);
  Ini.WriteBool(csToolBar, csShowDesignToolBar, FShowDesignToolBar);
  Ini.WriteBool(csToolBar, csWrapable, FWrapable);
  SaveToolBarActions(FToolBarActions, WizOptions.GetUserFileName(SCnEditorToolBarDataName, False));
  WizOptions.CheckUserFile(SCnEditorToolBarDataName);
  SaveToolBarActions(FDesignToolBarActions, WizOptions.GetUserFileName(SCnEditorDesignToolBarDataName, False));
  WizOptions.CheckUserFile(SCnEditorDesignToolBarDataName);
end;

procedure TCnSrcEditorToolBarMgr.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnEditorToolBarDataName);
  WizOptions.CleanUserFile(SCnEditorDesignToolBarDataName);
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

procedure TCnSrcEditorToolBarMgr.SetShowDesignToolBar(const Value: Boolean);
begin
  if FShowDesignToolBar <> Value then
  begin
    FShowDesignToolBar := Value;
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

{$IFDEF DELPHI_OTA}

procedure TCnSrcEditorToolBarMgr.ThemeChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    ApplyThemeOnToolBar(ToolBars[I]);
end;

{$ENDIF}

{ TCnExternalEditorToolBarMgr }

constructor TCnExternalEditorToolBarMgr.Create;
begin
  inherited;
  ExternalEditorToolBarMgr := Self;
  FToolBarTypes := TStringList.Create;

  CnWizNotifierServices.AddAfterThemeChangeNotifier(ThemeChanged);
  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  InstallToolBars;
end;

destructor TCnExternalEditorToolBarMgr.Destroy;
var
  I: Integer;
begin
  ExternalEditorToolBarMgr := nil;
  CnWizNotifierServices.RemoveAfterThemeChangeNotifier(ThemeChanged);
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
      ToolBar.Tag := TCnNativeInt(EditControl); // 用 Tag 记录和其对应的 EditoControl

      ToolBar.Parent := EditControl.Parent;
      (ToolBar as TCnExternalSrcEditorToolBar).InitControls;

      if Assigned(Obj.CreateEvent) then
        Obj.CreateEvent(Obj.ToolBarType, EditControl, ToolBar);
      if Assigned(Obj.InitEvent) then
        Obj.InitEvent(Obj.ToolBarType, EditControl, ToolBar);

      ToolBar.Visible := Obj.ToolBarVisible;
      if Obj.ToolBarVisible then
        ToolBar.Update;
      Obj.AddToolBar(ToolBar, EditControl);
    end;
  end;
end;

function TCnExternalEditorToolBarMgr.GetToolBarObj(ToolBarType: string): TCnEditorToolBarObj;
var
  Idx: Integer;
begin
  Idx := FToolBarTypes.IndexOf(ToolBarType);
  if Idx >= 0 then
    Result := TCnEditorToolBarObj(FToolBarTypes.Objects[Idx])
  else
    Result := nil;
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
    CnDebugger.LogMsg('TCnEditorToolBarObj EditControl Removed.');
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

function TCnExternalEditorToolBarMgr.GetVisible(const ToolBarType: string): Boolean;
var
  Obj: TCnEditorToolBarObj;
begin
  Result := False;
  Obj := ToolBarObj[ToolBarType];
  if Obj <> nil then
  begin
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
          Obj.InitEvent(Obj.ToolBarType, Obj.EditControls[J], TToolBar(Obj.ToolBars[J]));
          Obj.ToolBars[J].Update;
        end;
  end;
end;

procedure TCnExternalEditorToolBarMgr.RegisterToolBarType(const ToolBarType:
  string; CreateEvent, InitEvent, RemoveEvent: TCnEditorToolBarEvent);
var
  Obj: TCnEditorToolBarObj;
begin
  if ToolBarType <> '' then
  begin
    Obj := ToolBarObj[ToolBarType];
    if Obj = nil then
    begin
      Obj := TCnEditorToolBarObj.Create(nil);
      FToolBarTypes.AddObject(ToolBarType, Obj);
    end;
    Obj.ToolBarVisible := True;
    Obj.ToolBarType := ToolBarType;
    Obj.CreateEvent := CreateEvent;
    Obj.InitEvent := InitEvent;
    Obj.RemoveEvent := RemoveEvent;
    InstallToolBars;
  end;
end;

procedure TCnExternalEditorToolBarMgr.RemoveToolBarType(const ToolBarType: string);
var
  Obj: TCnEditorToolBarObj;
  I: Integer;
begin
  Obj := ToolBarObj[ToolBarType];
  if Obj <> nil then
  begin
    for I := Obj.ToolBarCount - 1 downto 0 do
      Obj.ToolBars[I].Free;
    Obj.Free;
  end;
  FToolBarTypes.Delete(FToolBarTypes.IndexOf(ToolBarType));
end;

procedure TCnExternalEditorToolBarMgr.SetVisible(const ToolBarType: string;
  Visible: Boolean);
var
  I: Integer;
  TBObj: TCnEditorToolBarObj;
begin
  for I := 0 to FToolBarTypes.Count - 1 do
  begin
    TBObj := TCnEditorToolBarObj(FToolBarTypes.Objects[I]);
    if (ToolBarType = '') or SameText(TBObj.ToolBarType, ToolBarType) then
    begin
      TBObj.ToolBarVisible := Visible;
    end;
  end;
  if CnSrcEditorToolBarMgr <> nil then
    CnSrcEditorToolBarMgr.CheckToolBarEnable;
end;

procedure TCnExternalEditorToolBarMgr.ThemeChanged(Sender: TObject);
begin
  EnumEditControl(DoUpdateToolbarTheme, nil);
end;


procedure TCnExternalEditorToolBarMgr.DoUpdateToolbarTheme(
  EditWindow: TCustomForm; EditControl: TControl; Context: Pointer);
{$IFDEF DELPHI_OTA}
var
  I: Integer;
  ToolBar: TToolBar;
{$ENDIF}
begin
{$IFDEF DELPHI_OTA}
  for I := 0 to FToolBarTypes.Count - 1 do
  begin
    ToolBar := TToolBar(EditWindow.FindComponent(FToolBarTypes[I]));

    if ToolBar <> nil then
      ApplyThemeOnToolBar(ToolBar);
  end;
{$ENDIF}
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
  begin
    for I := ToolBarCount - 1 downto 0 do
    begin
      if AComponent = FToolBars[I] then
      begin
        // 删除 ToolBar 时，调用 RemoveEvent 通知释放其它东西
        if Assigned(FRemoveEvent)
          and (AComponent.Tag <> 0) and (TObject(AComponent.Tag) is TControl) then
          FRemoveEvent(ToolBarType, TObject(AComponent.Tag) as TControl,
            AComponent as TToolBar);

        // 从列表中直接删除
        FToolBars.Delete(I);
        FEditControls.Delete(I);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TCnEditorToolBarObj Notification: ToolBar %d Removed.', [I]);
{$ENDIF}
      end;
    end;
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
  inherited;
  AutoSize := True;
  Align := alTop;
  Images := GetIDEImageList;
{$IFDEF DELPHI_IDE_WITH_HDPI}
  InitSizeIfLargeIcon(Self, TImageList(dmCnSharedImages.IDELargeVirtualImages));
{$ELSE}
  InitSizeIfLargeIcon(Self, dmCnSharedImages.IDELargeImages);
{$ENDIF}
end;

function TCnExternalSrcEditorToolBar.CanShow(APage: TCnSrcEditorPage): Boolean; 
begin
  Result := inherited CanShow(APage);
  if Assigned(FOnCanShow) then
    FOnCanShow(Self, APage, Result);
end;

initialization
  CreateEditorToolBarServiceProc := CreateEditorToolBarService;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnSrcEditorToolBar.');
{$ENDIF}

finalization
  CnEditorToolBarService := nil;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
