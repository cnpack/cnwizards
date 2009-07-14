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

unit CnPaletteEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件面板扩展单元
* 单元作者：刘啸（LiuXiao）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.09.11 V1.4 by LiuXiao
*               增加查找组件的功能
*           2005.05.31 V1.4 by LiuXiao
*               增加自动设置 D7 以上 IDE 的主菜单下划线的功能
*           2005.03.09 V1.3 by LiuXiao
*               增加自动调整其他窗口位置的功能
*           2003.10.28 V1.2 by 何清(QSoft)
*               解决单行/多行方式切换时不接受鼠标滚轮事件的问题
*           2003.06.23 V1.1
*               修改为专家注册方式
*           2003.05.14 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, Contnrs, StdCtrls, Buttons,
  CnCommon, CnWizUtils, CnWizNotifier, CnWizIdeUtils, CnWizConsts, CnMenuHook,
  CnConsts, CnCompUtils, CnWizClasses,
  {$IFDEF COMPILER7_UP}
  ActnMenus,
  {$ENDIF}
  CnWizOptions;

type

//==============================================================================
// 主窗体扩展专家（原组件面板扩展专家）
//==============================================================================

{ TCnPaletteEnhanceWizard }

  TCnPaletteEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
  {$IFNDEF COMPILER8_UP}
    FMultiLine: Boolean;
    FButtonStyle: Boolean;
    FTabsMenu: Boolean;
    FHooked: Boolean;
    FMenuHook: TCnMenuHook;
  {$IFDEF COMPILER5}
    FTabMenuItem: TCnMenuItemDef;
  {$ENDIF COMPILER5}
    FMultiLineMenuItem: TCnMenuItemDef;
    FSepMenuItem: TCnSepMenuItemDef;
  {$ENDIF COMPILER8_UP}
    FMenuLine: Boolean;
    FLockToolbar: Boolean;
    FHookedToolbarMouseDown: Boolean;
    FOldMouseDown: TMouseEvent;
    FMainControlBar: TControlBar;
    FControlBarMenuHook: TCnMenuHook;
    FLockMenuItem: TCnMenuItemDef;
    FComponentPalette: TTabControl;
    
  {$IFDEF COMPILER7_UP}
    FMenuBar: TActionMainMenuBar;
  {$ENDIF COMPILER7_UP}

    FEnableWizMenu: Boolean;
    FWizMenuNames: TStringList;
    FWizMenu: TMenuItem;
    FWizOptionMenu: TMenuItem;
    FWizSepMenu: TMenuItem;
  {$IFNDEF COMPILER8_UP}
    FDivTab: Boolean;
    FCompFilter: Boolean;
    FCompFilterPnl: TPanel;
    FCompFilterBtn: TSpeedButton;

    FShowPrefix: Boolean;
    FUseSmallImg: Boolean;
    FShowDetails: Boolean;
    FAutoSelect: Boolean;
  {$IFDEF COMPILER6_UP}
    FTabPopupItem: TMenuItem;
    FTabOnClick: TNotifyEvent;

  {$ENDIF COMPILER6_UP}
  {$ENDIF COMPILER8_UP}

  {$IFNDEF COMPILER8_UP}
    procedure SetFCompFilter(const Value: Boolean);
    procedure UpdateCompFilterButton;
    procedure OnCompFilterBtnClick(Sender: TObject);
    procedure OnCompFilterStyleChanged(Sender: TObject);
    procedure OnSettingChanged(Sender: TObject);
    procedure OnActiveFormChanged(Sender: TObject);
    procedure DoUpdateComponentPalette(AMultiLine: Boolean; AButtonStyle: Boolean);
    procedure OnMultiLineItemClick(Sender: TObject);
  {$IFDEF COMPILER5}
    procedure OnMenuItemClick(Sender: TObject);
    procedure OnTabMenuCreated(Sender: TObject; MenuItem: TMenuItem);
  {$ELSE}
    procedure OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
  {$ENDIF COMPILER5}
    procedure OnMultiLineMenuCreated(Sender: TObject; MenuItem: TMenuItem);

    // 使用类方法是因为该方法可能会在对象被释放后调用
    class procedure ResizeComponentPalette(Sender: TObject);

    procedure RegisterUserMenuItems;
    procedure SetTabsMenu(const Value: Boolean);
    procedure UpdateOtherWindows(OldHeight: Integer);
  {$ENDIF COMPILER8_UP}
    function GetComponentPalette: TTabControl;
    procedure OnIdle(Sender: TObject);
    procedure OnLockMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnLockToolbarItemClick(Sender: TObject);
  {$IFDEF COMPILER7_UP}
    procedure InitMenuBar;
    procedure FinalMenuBar;
  {$ENDIF COMPILER7_UP}

    procedure DoConfig(Sender: TObject);
    procedure OnConfig(Sender: TObject);
    function GetMenuInsertIndex: Integer;
    procedure InitWizMenus;
    procedure FinalWizMenus;
    procedure RestoreWizMenus;
    procedure AdjustMainMenuBar;
    procedure UpdateWizMenus;
    procedure InitControlBarMenu;
    procedure SetLockToolbar(const Value: Boolean);
    procedure UpdateToolbarLock;
    procedure MainControlBarOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    property ComponentPalette: TTabControl read GetComponentPalette;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Loaded; override;
    class procedure GetWizardInfo(var Name, Author, Email,
      Comment: string); override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;
    procedure UpdateCompPalette;

  {$IFNDEF COMPILER8_UP}
    property TabsMenu: Boolean read FTabsMenu write SetTabsMenu;
    property MultiLine: Boolean read FMultiLine write FMultiLine;
    property ButtonStyle: Boolean read FButtonStyle write FButtonStyle;
    property DivTab: Boolean read FDivTab write FDivTab;
    property CompFilter: Boolean read FCompFilter write SetFCompFilter;

    property ShowPrefix: Boolean read FShowPrefix write FShowPrefix;
    property UseSmallImg: Boolean read FUseSmallImg write FUseSmallImg;
    property ShowDetails: Boolean read FShowDetails write FShowDetails;
    property AutoSelect: Boolean read FAutoSelect write FAutoSelect;

  {$ENDIF COMPILER8_UP}
    property MenuLine: Boolean read FMenuLine write FMenuLine;
    property LockToolbar: Boolean read FLockToolbar write SetLockToolbar;
  end;

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPALETTEENHANCEWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnPaletteEnhanceFrm
{$IFNDEF COMPILER8_UP}
  , CnCompFilterFrm
{$ENDIF}
  ;

const
  SCnCompFilterBtnName = 'CnCompFilterBtn';
  
  csPalEnhActive = 'PalEnhActive';
  csTabsMenuActive = 'TabsMenuActive';
  csPalMultiLine = 'PaletteMultiLine';
  csPalButtonStyle = 'PaletteButtonStyle';
  csIDEMenuLine = 'IDEMenuLine';
  csEnableWizMenu = 'EnableWizMenu';
  csWizMenuNames = 'WizMenuNames';
  csWizMenuCaption = 'WizMenuCaption';
  csDivTabMenu = 'DivTabMenu';
  csLockToolbar = 'LockToolbar';

  csCompFilter = 'CompFilter';
  csShowPrefix = 'ShowPrefix';
  csUseSmallImg = 'UseSmallImg';
  csShowDetails = 'ShowDetails';
  csAutoSelect = 'AutoSelect';

type
  TControlHack = class(TControl);

//==============================================================================
// 组件面板扩展专家
//==============================================================================

{ TCnPaletteEnhanceWizard }

constructor TCnPaletteEnhanceWizard.Create;
begin
  inherited;
  InitWizMenus;
  InitControlBarMenu;
{$IFNDEF COMPILER8_UP}
  FMenuHook := TCnMenuHook.Create(nil);
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChanged);
{$IFDEF COMPILER6_UP}
  FDivTab := True;
{$ENDIF}
{$ENDIF COMPILER8_UP}

  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);
end;

destructor TCnPaletteEnhanceWizard.Destroy;
begin
{$IFDEF COMPILER7_UP}
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);
  FinalMenuBar;
{$ENDIF COMPILER7_UP}
{$IFNDEF COMPILER8_UP}
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChanged);
  FMenuHook.Free;
{$ENDIF COMPILER8_UP}
  FControlBarMenuHook.Free;
  FinalWizMenus;
  inherited;
end;

function TCnPaletteEnhanceWizard.GetComponentPalette: TTabControl;
begin
  if not Assigned(FComponentPalette) then
    FComponentPalette := GetComponentPaletteTabControl;

  Assert(Assigned(FComponentPalette));
  Result := FComponentPalette;
end;

//------------------------------------------------------------------------------
// 组件面板多行切换
//------------------------------------------------------------------------------

{$IFNDEF COMPILER8_UP}
procedure TCnPaletteEnhanceWizard.OnActiveFormChanged(Sender: TObject);
var
  PopupMenu: TPopupMenu;
begin
  if FHooked then Exit;

  PopupMenu := GetComponentPalettePopupMenu;
  Assert(Assigned(PopupMenu));

  // 挂接组件面板右键菜单
  if not FMenuHook.IsHooked(PopupMenu) then
  begin
    FMenuHook.HookMenu(PopupMenu);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Hooked ComponentPalette''s PopupMenu.');
  {$ENDIF DEBUG}
  end;

  UpdateCompPalette;
  FHooked := True;
end;

class procedure TCnPaletteEnhanceWizard.ResizeComponentPalette(Sender: TObject);
var
  h : Integer;
begin
  with (Sender as TTabControl) do
  begin
    h := Height + DisplayRect.Top - DisplayRect.Bottom + 29;
    Constraints.MinHeight := h;
    Parent.Constraints.MaxHeight := h;
  end;
end;

procedure TCnPaletteEnhanceWizard.DoUpdateComponentPalette(AMultiLine: Boolean;
  AButtonStyle: Boolean);
var
  H: Integer;
  AForm: TCustomForm;
begin
  if Assigned(ComponentPalette) then
  begin
    H := 0;
    AForm := GetIdeMainForm;
    if AForm <> nil then
      H := AForm.Height;

    if FButtonStyle <> (ComponentPalette.Style = tsFlatButtons) then
    begin
      if FButtonStyle then
        ComponentPalette.Style := tsFlatButtons
      else
        ComponentPalette.Style := tsTabs;

      UpdateOtherWindows(H);        
    end;

    if ComponentPalette.MultiLine <> AMultiLine then
    begin
      ComponentPalette.MultiLine := AMultiLine;

      if AMultiLine then
      begin
        ComponentPalette.OnResize := ResizeComponentPalette;
        ComponentPalette.OnResize(ComponentPalette);
      end
      else
        ComponentPalette.OnResize := nil;

      UpdateOtherWindows(H);
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMultiLineItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    MultiLine := not MultiLine;
    (Sender as TMenuItem).Checked := MultiLine;
    DoUpdateComponentPalette(MultiLine, FButtonStyle);

    // 解决单行/多行方式切换时不接受鼠标滚轮事件的问题
    if ComponentPalette.Visible and ComponentPalette.Enabled then
      ComponentPalette.SetFocus;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMultiLineMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Checked := MultiLine;
end;

procedure TCnPaletteEnhanceWizard.UpdateOtherWindows(OldHeight: Integer);
const
  WinClasses: array[0..2] of string = ('TObjectTreeView',
    'TPropertyInspector', 'TEditWindow');
var
  AForm: TCustomForm;
  I, J, MainTop, HeightDelta: Integer;
begin
  AForm := GetIdeMainForm;
  if AForm = nil then Exit;
  HeightDelta := AForm.Height - OldHeight;
  if HeightDelta = 0 then Exit;
  MainTop := AForm.Top;

  for I := Low(WinClasses) to High(WinClasses) do
  begin
    for J := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[J].ClassNameIs(WinClasses[I]) then
      begin
        AForm := Screen.CustomForms[J];
        if Abs(AForm.Top - (MainTop + OldHeight)) < 10 then // 窗体原来紧挨离 IDE 主窗体下面
        begin
          AForm.Top := AForm.Top + HeightDelta;
          AForm.Height := AForm.Height - HeightDelta;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 新增 Tabs 菜单项
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.RegisterUserMenuItems;
begin
  FSepMenuItem := TCnSepMenuItemDef.Create(ipFirst, '');
  FMenuHook.AddMenuItemDef(FSepMenuItem);

  FMultiLineMenuItem := TCnMenuItemDef.Create(SCnPaletteMutiLineMenuName,
    SCnPaletteMultiLineMenuCaption, OnMultiLineItemClick, ipFirst, '');
  FMultiLineMenuItem.OnCreated := OnMultiLineMenuCreated;
  FMenuHook.AddMenuItemDef(FMultiLineMenuItem);

  {$IFDEF COMPILER5}
  FTabMenuItem := TCnMenuItemDef.Create(SCnPaletteTabsMenuName,
    SCnPaletteTabsMenuCaption, nil, ipFirst, '');
  FTabMenuItem.OnCreated := OnTabMenuCreated;
  FMenuHook.AddMenuItemDef(FTabMenuItem);
  {$ELSE}
  FMenuHook.OnAfterPopup := OnMenuAfterPopup;
  {$ENDIF COMPILER5}
end;

{$IFDEF COMPILER5}
procedure TCnPaletteEnhanceWizard.OnTabMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
var
  I: Integer;
  AItem: TMenuItem;
  List: TStringList;
  Tab: string;
  IndexTab, DivCount: Integer;
begin
  MenuItem.Visible := TabsMenu;
  DivCount := (Screen.Height - TForm(GetIdeMainForm).Height) div GetMainMenuItemHeight;
  if TabsMenu then
  begin
    List := TStringList.Create;
    try
      List.Assign(ComponentPalette.Tabs);
      for I := 0 to ComponentPalette.Tabs.Count - 1 do
        List.Objects[I] := TObject(I);

      Tab := List.Strings[ComponentPalette.TabIndex];
      List.Sort;
      IndexTab := List.IndexOf(Tab);

      for I := 0 to List.Count - 1 do
      begin
        AItem := TMenuItem.Create(nil);
        AItem.Caption := List[I];
        AItem.Tag := Integer(List.Objects[I]);
        if I = IndexTab then
          AItem.Checked := True;

        if FDivTab and (I > 0) and (I mod DivCount = 0) then
          AItem.Break := mbBarBreak;
        AItem.OnClick := OnMenuItemClick;
        MenuItem.Add(AItem);
      end;
    finally
    List.Free;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnMenuItemClick(Sender: TObject);
begin
  ComponentPalette.TabIndex := (Sender as TMenuItem).Tag;
  if Assigned(ComponentPalette.OnChange) then
    ComponentPalette.OnChange(ComponentPalette);
end;

{$ELSE}

procedure TCnPaletteEnhanceWizard.OnMenuAfterPopup(Sender: TObject;
  Menu: TPopupMenu);
const
  csTabsItem = 'TabsItem';
var
  I, DivCount: Integer;
{$IFDEF DELPHI7}
  J, TabArrayLen: Integer;
  RemovedItem: TMenuItem;
  TabStartArray, TabEndArray: array of Integer;
  MoreItems, SepItems: array of TMenuItem;
{$ENDIF}
begin
  if FTabPopupItem = nil then
    for I := 0 to Menu.Items.Count - 1 do
      if Menu.Items.Items[I].Name = csTabsItem then
        FTabPopupItem := Menu.Items.Items[I];

  if FTabPopupItem = nil then
    Exit;

  if FDivTab then
  begin
    if Assigned(FTabPopupItem.OnClick) then // Old Item
    begin
      FTabOnClick := FTabPopupItem.OnClick;
      FTabPopupItem.OnClick := nil;
    end;
    FTabOnClick(FTabPopupItem);
    // 此步骤后，Tabs 子菜单已创建，注意如果有其他专家也挂接此事件，则冲突
    DivCount := (Screen.Height - TForm(GetIdeMainForm).Height - 75) div GetMainMenuItemHeight - 1;

    if FTabPopupItem.Count > DivCount then // 分页
    begin
{$IFDEF DELPHI7}
      TabArrayLen := (FTabPopupItem.Count div DivCount) + 1;
      SetLength(MoreItems, TabArrayLen - 1);
      SetLength(SepItems, TabArrayLen - 1);

      SetLength(TabStartArray, TabArrayLen);
      SetLength(TabEndArray, TabArrayLen);

      // 记录需要分组的起始位置，无需分页时 TabArrayLen = 1
      for I := 0 to TabArrayLen - 1 do
      begin
        // TabArrayLen 个分组，从 0 到 TabArrayLen - 1
        TabStartArray[I] := I * DivCount;
        if I < TabArrayLen - 1 then
          TabEndArray[I] := (I + 1) * DivCount - 1
        else
          TabEndArray[I] := FTabPopupItem.Count - 1;

        // TabArrayLen - 1 个分组，从 0 到 TabArrayLen - 2
        if I <= High(MoreItems) then
        begin
          MoreItems[I] := TMenuItem.Create(Application);
          MoreItems[I].Caption := SCnPaletteMoreCaption;

          SepItems[I] := TMenuItem.Create(Application);
          SepItems[I].Caption := '-';
        end;
      end;

      for I := TabArrayLen - 1 downto 1 do
      begin
        // Start[I] 和 End[I] 间的菜单移动到 More[I-1] 里头去
        for J := TabEndArray[I] downto TabStartArray[I] do
        begin
          RemovedItem := FTabPopupItem.Items[J];
          FTabPopupItem.Remove(RemovedItem);
          MoreItems[I - 1].Insert(0, RemovedItem);
        end;
      end;

      // 组装 More 菜单
      for I := 0 to High(MoreItems) - 1 do
      begin
        MoreItems[I].Insert(0, SepItems[I + 1]);
        MoreItems[I].Insert(0, MoreItems[I + 1]);
      end;

      // 然后把 More 和 Sep 加到子菜单里头
      FTabPopupItem.Insert(0, SepItems[0]);
      FTabPopupItem.Insert(0, MoreItems[0]);

      SetLength(TabStartArray, 0);
      SetLength(TabEndArray, 0);
      SetLength(MoreItems, 0);
      SetLength(SepItems, 0);

{$ELSE}  // Delphi 6 or BCB 6, 直接改 Break 属性
      for I := 1 to FTabPopupItem.Count div DivCount do
        FTabPopupItem.Items[I * DivCount].Break := mbBarBreak;
          // 想不到 D7 设置 Break 后无效，非得像上面一样折腾
{$ENDIF}
    end;
  end
  else
  begin
    if not Assigned(FTabPopupItem.OnClick) then
      FTabPopupItem.OnClick := FTabOnClick;
  end;
end;

{$ENDIF COMPILER5}

procedure TCnPaletteEnhanceWizard.SetTabsMenu(const Value: Boolean);
begin
  FTabsMenu := Value;
end;

{$ENDIF COMPILER8_UP}

//------------------------------------------------------------------------------
// 增加菜单下划线
//------------------------------------------------------------------------------

{$IFDEF COMPILER7_UP}
procedure TCnPaletteEnhanceWizard.InitMenuBar;
var
  AForm: TCustomForm;
  I: Integer;
begin
  AForm := GetIdeMainForm;
  FMenuBar := nil;
  if AForm <> nil then
  begin
    for I := 0 to AForm.ComponentCount - 1 do
    begin
      if AForm.Components[I] is TActionMainMenuBar then
      begin
        FMenuBar := TActionMainMenuBar(AForm.Components[I]);
        Break;
      end;
    end;
  end;
  AddComponentFreeNotify(TComponent(FMenuBar), nil);
end;

procedure TCnPaletteEnhanceWizard.FinalMenuBar;
begin
  RemoveComponentFreeNotify(TComponent(FMenuBar));
end;
{$ENDIF COMPILER7_UP}

procedure TCnPaletteEnhanceWizard.OnIdle(Sender: TObject);
begin
{$IFDEF COMPILER7_UP}
  if Active and MenuLine and Assigned(FMenuBar) then
  begin
    if not FMenuBar.PersistentHotKeys then
      FMenuBar.PersistentHotKeys := True;
  end;
{$ENDIF COMPILER7_UP}

{$IFNDEF COMPILER8_UP}
  if Active and FCompFilter and (FCompFilterBtn <> nil)
    and (CnCompFilterForm <> nil) then
    FCompFilterBtn.Down := not (CnCompFilterForm.FilterFormStyle = fsHidden);
{$ENDIF}
end;


//------------------------------------------------------------------------------
// 移动专家菜单项
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.InitWizMenus;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InitWizMenus');
{$ENDIF DEBUG}
  FEnableWizMenu := False;
  FWizMenuNames := TStringList.Create;
  FWizMenu := TMenuItem.Create(nil);
  FWizMenu.Name := SCnWizMenuName;
  FWizMenu.Caption := SCnDefWizMenuCaption;
  FWizSepMenu := AddSepMenuItem(FWizMenu);
  FWizOptionMenu := AddMenuItem(FWizMenu, SCnWizConfigCaption, OnConfig);
  FWizOptionMenu.Name := SCnWizOptionMenuName;
end;

procedure TCnPaletteEnhanceWizard.FinalWizMenus;
begin
  RestoreWizMenus;
  FWizSepMenu.Free;
  FWizOptionMenu.Free;
  FWizMenu.Free;
  FWizMenuNames.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('FinalWizMenus');
{$ENDIF DEBUG}
end;

function TCnPaletteEnhanceWizard.GetMenuInsertIndex: Integer;
var
  MainMenu: TMainMenu;
  ToolsMenu: TMenuItem;
begin
  Result := 0;
  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) then
  begin
    ToolsMenu := GetIDEToolsMenu;
    if Assigned(ToolsMenu) then
      Result := MainMenu.Items.IndexOf(ToolsMenu)
    else
      Result := MainMenu.Items.Count - 1;
  end;      
end;

procedure TCnPaletteEnhanceWizard.RestoreWizMenus;
var
  MainMenu: TMainMenu;
  MenuItem: TMenuItem;
  Idx: Integer;
begin
  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('RestoreWizMenus');
  {$ENDIF DEBUG}
    Idx := GetMenuInsertIndex;
    while FWizMenu.Count > 2 do
    begin
      MenuItem := FWizMenu[0];
      FWizMenu.Remove(MenuItem);
      MainMenu.Items.Insert(Idx + 1, MenuItem);
    end;
    if FWizMenu.Parent = MainMenu.Items then
      MainMenu.Items.Remove(FWizMenu);
  end;    
end;

procedure TCnPaletteEnhanceWizard.AdjustMainMenuBar;
const
  sMenuBar = 'MenuBar';
var
  List: TList;
  i, j: Integer;
  ViewBar, MenuBar: TToolBar;
  ControlBar: TControlBar;
  LeftCtrl: TControl;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('AdjustMainMenuBar');
{$ENDIF DEBUG}

  ViewBar := (BorlandIDEServices as INTAServices).ToolBar[sViewToolBar];
  if Assigned(ViewBar) and (ViewBar.Parent is TControlBar) then
  begin
    ControlBar := TControlBar(ViewBar.Parent);
    MenuBar := nil;
    for i := 0 to ControlBar.ControlCount - 1 do
      if SameText(ControlBar.Controls[i].Name, sMenuBar) then
      begin
        MenuBar := TToolBar(ControlBar.Controls[i]);
        Break;
      end;

    if not Assigned(MenuBar) then
      Exit;

    List := TList.Create;
    try
      for i := 0 to ControlBar.ControlCount - 1 do
        if (ControlBar.Controls[i] <> MenuBar) and
          (ControlBar.Controls[i].Top = MenuBar.Top) then
        begin
          j := 0;
          while (j < List.Count) and (ControlBar.Controls[i].Left >
            TControl(List[j]).Left) do
            Inc(j);
          List.Insert(j, ControlBar.Controls[i]);
        end;

      for i := 0 to List.Count - 1 do
      begin
        if i = 0 then
          LeftCtrl := MenuBar
        else
          LeftCtrl := TControl(List[i - 1]);
        TControl(List[i]).Left := LeftCtrl.Left + LeftCtrl.Width;
      end;  
    finally
      List.Free;
    end;                  
  end;
end;

procedure TCnPaletteEnhanceWizard.UpdateWizMenus;
var
  MainMenu: TMainMenu;
  i: Integer;

  procedure DoInsertMenu(AMenu: TMenuItem; const AName: string);
  var
    i: Integer;
    MenuItem: TMenuItem;
  begin
    for i := MainMenu.Items.Count - 1 downto 0 do
      if SameText(MainMenu.Items[i].Name, AName) then
      begin
        MenuItem := MainMenu.Items[i];
        MainMenu.Items.Remove(MenuItem);
        AMenu.Insert(0, MenuItem);
        Break;
      end;
  end;
begin
  RestoreWizMenus;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('UpdateWizMenus');
{$ENDIF DEBUG}

  MainMenu := GetIDEMainMenu;
  if Assigned(MainMenu) and Active and FEnableWizMenu and
    (FWizMenuNames.Count > 0) then
  begin
    for i := FWizMenuNames.Count - 1 downto 0 do
    begin
      DoInsertMenu(FWizMenu, FWizMenuNames[i]);
    end;
    MainMenu.Items.Insert(GetMenuInsertIndex + 1, FWizMenu);
  end;

  AdjustMainMenuBar;
end;

//------------------------------------------------------------------------------
// 更新设置
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.UpdateCompPalette;
begin
{$IFNDEF COMPILER8_UP}
  FMenuHook.Active := Active;
  DoUpdateComponentPalette(Active and MultiLine, Active and ButtonStyle);
{$ENDIF COMPILER8_UP}
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

procedure TCnPaletteEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
{$IFNDEF COMPILER8_UP}
  FTabsMenu := Ini.ReadBool('', csTabsMenuActive, True);
  FMultiLine := Ini.ReadBool('', csPalMultiLine, False);
  FButtonStyle := Ini.ReadBool('', csPalButtonStyle, False);
  FDivTab := Ini.ReadBool('', csDivTabMenu, True);
  FCompFilter := Ini.ReadBool('', csCompFilter, True);
  FShowPrefix := Ini.ReadBool('', csShowPrefix, False);
  FUseSmallImg := Ini.ReadBool('', csUseSmallImg, False);
  FShowDetails := Ini.ReadBool('',  csShowDetails, True);
  FAutoSelect := Ini.ReadBool('', csAutoSelect, True);

{$ENDIF COMPILER8_UP}
  FMenuLine := Ini.ReadBool('', csIDEMenuLine, False);
  FLockToolbar := Ini.ReadBool('', csLockToolbar, False);

  FEnableWizMenu := Ini.ReadBool(WizOptions.CompilerID, csEnableWizMenu, FEnableWizMenu);
  FWizMenuNames.CommaText := Ini.ReadString(WizOptions.CompilerID, csWizMenuNames, FWizMenuNames.CommaText);
  FWizMenu.Caption := Ini.ReadString(WizOptions.CompilerID, csWizMenuCaption, FWizMenu.Caption);

  UpdateCompPalette;
  if FLockToolbar then
    UpdateToolbarLock;
end;

procedure TCnPaletteEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFNDEF COMPILER8_UP}
  Ini.WriteBool('', csTabsMenuActive, FMenuHook.Active);
  Ini.WriteBool('', csPalMultiLine, FMultiLine);
  Ini.WriteBool('', csPalButtonStyle, FButtonStyle);
  Ini.WriteBool('', csDivTabMenu, FDivTab);
  Ini.WriteBool('', csCompFilter, FCompFilter);
  Ini.WriteBool('', csShowPrefix, FShowPrefix);
  Ini.WriteBool('', csUseSmallImg, FUseSmallImg);
  Ini.WriteBool('',  csShowDetails, FShowDetails);
  Ini.WriteBool('', csAutoSelect, FAutoSelect);
{$ENDIF COMPILER8_UP}
  Ini.WriteBool('', csIDEMenuLine, FMenuLine);
  Ini.WriteBool('', csLockToolbar, FLockToolbar);

  Ini.WriteBool(WizOptions.CompilerID, csEnableWizMenu, FEnableWizMenu);
  Ini.WriteString(WizOptions.CompilerID, csWizMenuNames, FWizMenuNames.CommaText);
  if SameText(FWizMenu.Caption, SCnDefWizMenuCaption) then
    Ini.DeleteKey(WizOptions.CompilerID, csWizMenuCaption)
  else
    Ini.WriteString(WizOptions.CompilerID, csWizMenuCaption, FWizMenu.Caption);
end;

class procedure TCnPaletteEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnPaletteEnhanceWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnPaletteEnhanceWizardComment;
end;

function TCnPaletteEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnPaletteEnhanceWizard.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnPaletteEnhanceWizard.Config;
begin
  // 如果通过菜单调用该方法，由于未知的原因，FWizMenu.Count 为 0 而无法访问子项
  // 此处改成通过 Idle 来执行 Config 方法以解决该问题
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoConfig);
end;

procedure TCnPaletteEnhanceWizard.DoConfig(Sender: TObject);
begin
  with TCnPalEnhanceForm.Create(nil) do
  try
  {$IFNDEF COMPILER8_UP}
    chkAddTabs.Checked := TabsMenu;
    chkMultiLine.Checked := MultiLine;
    chkButtonStyle.Checked := ButtonStyle;
    chkDivTabMenu.Checked := DivTab;
    chkCompFilter.Checked := CompFilter;
  {$ENDIF COMPILER8_UP}
    chkMenuLine.Checked := MenuLine;
    chkLockToolbar.Checked := LockToolbar;

    chkMoveWizMenus.Checked := FEnableWizMenu;
    edtMoveToUser.Text := FWizMenu.Caption;
    SetWizMenuNames(FWizMenuNames, FWizMenu);

    if ShowModal = mrOK then
    begin
    {$IFNDEF COMPILER8_UP}
      TabsMenu := chkAddTabs.Checked;
      MultiLine := chkMultiLine.Checked;
      ButtonStyle := chkButtonStyle.Checked;
      DivTab := chkDivTabMenu.Checked;
      CompFilter := chkCompFilter.Checked;
    {$ENDIF COMPILER8_UP}
      MenuLine := chkMenuLine.Checked;
      LockToolbar := chkLockToolbar.Checked;

      FEnableWizMenu := chkMoveWizMenus.Checked;
      FWizMenu.Caption := edtMoveToUser.Text;
      GetWizMenuNames(FWizMenuNames);

      DoSaveSettings;

      UpdateCompPalette;
      UpdateWizMenus;
    end;
  finally
    Free;
  end;
end;

procedure TCnPaletteEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateCompPalette;
  UpdateWizMenus;
{$IFNDEF COMPILER8_UP}
  UpdateCompFilterButton;
{$ENDIF}
end;

procedure TCnPaletteEnhanceWizard.LanguageChanged(Sender: TObject);
begin
  FWizOptionMenu.Caption := SCnWizConfigCaption;
{$IFNDEF COMPILER8_UP}
  UpdateCompFilterButton;
  if FMultiLineMenuItem <> nil then
    FMultiLineMenuItem.SetCaption(SCnPaletteMultiLineMenuCaption);
{$ENDIF}
  FWizOptionMenu.Hint := StripHotkey(SCnWizConfigCaption);
  if FLockMenuItem <> nil then
    FLockMenuItem.SetCaption(SCnLockToolbarMenuCaption);
end;

procedure TCnPaletteEnhanceWizard.Loaded;
begin
  inherited;
{$IFNDEF COMPILER8_UP}
  RegisterUserMenuItems;
  UpdateCompFilterButton;
{$ENDIF COMPILER8_UP}

{$IFDEF COMPILER7_UP}
  InitMenuBar;
{$ENDIF COMPILER7_UP}

  UpdateWizMenus;
end;

{$IFNDEF COMPILER8_UP}
procedure TCnPaletteEnhanceWizard.SetFCompFilter(const Value: Boolean);
begin
  if FCompFilter <> Value then
  begin
    FCompFilter := Value;
    UpdateCompFilterButton;
  end;
end;

procedure TCnPaletteEnhanceWizard.UpdateCompFilterButton;
begin
  if Active and FCompFilter then
  begin
    if FCompFilterPnl = nil then
    begin
      FCompFilterPnl := TPanel.Create(Application);
      FCompFilterPnl.Name := 'CnCompFilterPnl';
      FCompFilterPnl.Caption := '';
      FCompFilterPnl.Parent := ComponentPalette;
      FCompFilterPnl.BorderWidth := 0;
      FCompFilterPnl.BevelInner := bvNone;
      FCompFilterPnl.BevelOuter := bvNone;
      FCompFilterPnl.Anchors := [akRight, akBottom];
      FCompFilterPnl.Height := 12;
      FCompFilterPnl.Width := 12;
      FCompFilterPnl.Left := ComponentPalette.Width - FCompFilterPnl.Width - 1;
      FCompFilterPnl.Top := ComponentPalette.Height - FCompFilterPnl.Height - 1;
    end;

    if FCompFilterBtn = nil then
    begin
      FCompFilterBtn := TSpeedButton.Create(Application);
      FCompFilterBtn.Name := 'CnCompFilterBtn';

      FCompFilterBtn.Parent := FCompFilterPnl;
      FCompFilterBtn.Flat := True;
      FCompFilterBtn.OnClick := OnCompFilterBtnClick;
      FCompFilterBtn.Top := 1;
      FCompFilterBtn.Left := 1;
      FCompFilterBtn.Height := 11;
      FCompFilterBtn.Width := 11;
      FCompFilterBtn.GroupIndex := 1;
      FCompFilterBtn.AllowAllUp := True;
      FCompFilterBtn.ShowHint := True;
      FCompFilterBtn.Font.Name := 'Wingdings'; {Do NOT localize.}
      FCompFilterBtn.Font.Size := 8;
      FCompFilterBtn.Font.Color := clTeal;
      FCompFilterBtn.BringToFront;
    end;
    
    FCompFilterBtn.Caption := '';
    CnWizLoadBitmap(FCompFilterBtn.Glyph, SCnCompFilterBtnName);

    FCompFilterBtn.Hint := SCnSearchComponent;
    FCompFilterPnl.BringToFront;
    FCompFilterBtn.Visible := True;
  end
  else
  begin
    if FCompFilterBtn <> nil then
      FCompFilterBtn.Visible := False;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnCompFilterBtnClick(Sender: TObject);
var
  P: TPoint;
begin
  if CnCompFilterForm = nil then
  begin
    CnCompFilterForm := TCnCompFilterForm.Create(nil);
    CnCompFilterForm.ShowPrefix := FShowPrefix;
    CnCompFilterForm.ShowDetails := FShowDetails;
    CnCompFilterForm.AutoSelect := FAutoSelect;
    CnCompFilterForm.UseSmallImg := FUseSmallImg;

    CnCompFilterForm.OnSettingChanged := OnSettingChanged;
    CnCompFilterForm.OnStyleChanged := OnCompFilterStyleChanged;
  end;

  P.x := FCompFilterBtn.Width;
  P.y := FCompFilterBtn.Height;
  CnCompFilterForm.BasePoint := FCompFilterBtn.ClientToScreen(P);

  case CnCompFilterForm.FilterFormStyle of
    fsDropped:
      begin
        CnCompFilterForm.FilterFormStyle := fsHidden;
      end;
    fsHidden:
      begin
        if not CnCompFilterForm.JustHide then // 关闭后要一定延时才允许打开
        begin
          CnCompFilterForm.FilterFormStyle := fsDropped;
          CnCompFilterForm.edtSearch.SetFocus;
        end;
      end;
    fsFloat:
      begin
        CnCompFilterForm.FilterFormStyle := fsHidden;
      end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnCompFilterStyleChanged(
  Sender: TObject);
begin

end;

procedure TCnPaletteEnhanceWizard.OnSettingChanged(Sender: TObject);
begin
  if CnCompFilterForm <> nil then
  begin
    FShowPrefix := CnCompFilterForm.ShowPrefix;
    FShowDetails := CnCompFilterForm.ShowDetails;
    FAutoSelect := CnCompFilterForm.AutoSelect;
    FUseSmallImg := CnCompFilterForm.UseSmallImg;
  end;
end;
{$ENDIF}

procedure TCnPaletteEnhanceWizard.SetLockToolbar(const Value: Boolean);
begin
  if FLockToolbar <> Value then
  begin
    FLockToolbar := Value;
    UpdateToolbarLock;
  end;
end;

// 更新工具栏的锁定状况
procedure TCnPaletteEnhanceWizard.UpdateToolbarLock;
var
  I: Integer;
  Main: TCustomForm;
begin
  Main := GetIdeMainForm;
  if Main <> nil then
  begin
    for I := 0 to Main.ControlCount - 1 do
    begin
      if Main.Controls[I] is TControlBar then
      begin
        FMainControlBar := (Main.Controls[I] as TControlBar);

        if FLockToolbar then
        begin
          if not FHookedToolbarMouseDown then
          begin
            FOldMouseDown := FMainControlBar.OnMouseDown;
            FMainControlBar.OnMouseDown := MainControlBarOnMouseDown;
            FHookedToolbarMouseDown := True;
          end;
        end
        else
        begin
          if FHookedToolbarMouseDown then
          begin
            FMainControlBar.OnMouseDown := FOldMouseDown;
            FOldMouseDown := nil;
            FHookedToolbarMouseDown := False;
          end;
        end;
        
        // 认为第一个 ControlBar 就是容纳工具栏的 ControlBar
        Exit;
      end;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.MainControlBarOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TControlBar then
  begin
    if FLockToolbar then
      TControlHack(Sender).MouseCapture := False
    else if Assigned(FOldMouseDown) then
      FOldMouseDown(Sender, Button, Shift, X, Y);
  end;
end;

procedure TCnPaletteEnhanceWizard.InitControlBarMenu;
var
  I: Integer;
  Main: TCustomForm;
begin
  Main := GetIdeMainForm;
  if Main <> nil then
  begin
    for I := 0 to Main.ControlCount - 1 do
    begin
      if Main.Controls[I] is TControlBar then
      begin
        FMainControlBar := (Main.Controls[I] as TControlBar);
        if FMainControlBar.PopupMenu <> nil then
        begin
          if FControlBarMenuHook = nil then
            FControlBarMenuHook := TCnMenuHook.Create(nil);
          if not FControlBarMenuHook.IsHooked(FMainControlBar.PopupMenu) then
            FControlBarMenuHook.HookMenu(FMainControlBar.PopupMenu);
          
          FLockMenuItem := TCnMenuItemDef.Create(SCnLockToolbarMenuName,
            SCnLockToolbarMenuCaption, OnLockToolbarItemClick, ipLast, '');
          FLockMenuItem.OnCreated := OnLockMenuCreated;
          FControlBarMenuHook.AddMenuItemDef(FLockMenuItem);
        end;  
        Exit;
      end;
    end;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnLockToolbarItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    LockToolbar := not LockToolbar;
    (Sender as TMenuItem).Checked := FLockToolbar;
  end;
end;

procedure TCnPaletteEnhanceWizard.OnLockMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Checked := FLockToolbar;
end;

initialization
  RegisterCnWizard(TCnPaletteEnhanceWizard);

{$ENDIF CNWIZARDS_CNPALETTEENHANCEWIZARD}
end.

