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

unit CnSrcEditorNav;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器前进后退扩展单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2013.08.05
*               加入对 BDS 的支持
*           2005.01.03
*               创建单元，从原 CnEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Math, CnCommon, ActnList, ImgList,
  {$IFDEF BDS}
  ActnMan,
  {$ENDIF}
  CnWizUtils, CnConsts, CnWizIdeUtils, CnWizConsts, CnMenuHook, CnWizNotifier,
  CnEditControlWrapper, CnWizShareImages, CnPopupMenu, CnWizClasses, CnWizManager,
  CnWizMenuAction, CnNative;

type

//==============================================================================
// 代码编辑器前进后退扩展功能
//==============================================================================

{ TCnSrcEditorNav }

  TCnSrcEditorNavMgr = class;

  TCnSrcEditorNav = class(TComponent)
  private
    FFileName: string;
    FLine: Integer;
    FUpdating: Boolean;
    FPause: Boolean;
    FNavMgr: TCnSrcEditorNavMgr;
    FEditControl: TControl;
    FOldBackMenu: Menus.TPopupMenu;
    FOldForwardMenu: Menus.TPopupMenu;
    FOldBackAction: TBasicAction;
    FOldForwardAction: TBasicAction;
    FOldBackShortCut: TShortCut;
    FOldForwardShortCut: TShortCut;
    FOldBackImageIndex: Integer;
    FOldForwardImageIndex: Integer;
    FOldImageList: TCustomImageList;
    FLastUpdateTick: Cardinal;
    FBackMenu: TPopupMenu;
    FForwardMenu: TPopupMenu;
    FBackAction: TAction;
    FForwardAction: TAction;
    FBackList: TStringList;    // 用 Objects 属性存行号，64 位和 32 位下均可 Integer 转换
    FForwardList: TStringList;
    FAllowAlt: Boolean;
    function ActionEnabled(AAction: TBasicAction): Boolean;
    function MenuEnabled(AMenu: Menus.TPopupMenu): Boolean;
    procedure DoMenuPopup(AMenu: Menus.TPopupMenu; AList: TStringList; AOnItem, AOnIDE:
      TNotifyEvent; const AIDECaption, AIDEListCaption: string; AOldAction:
      TBasicAction; AOldMenu: Menus.TPopupMenu);
    procedure BackMenuPopup(Sender: TObject);
    procedure ForwardMenuPopup(Sender: TObject);
    procedure BackMenuClick(Sender: TObject);
    procedure ForwardMenuClick(Sender: TObject);
    procedure OnIDEBack(Sender: TObject);
    procedure OnIDEForward(Sender: TObject);
    procedure OnIDEListClick(Sender: TObject);
    procedure OnPauseClick(Sender: TObject);
    procedure BackActionExecute(Sender: TObject);
    procedure ForwardActionExecute(Sender: TObject);

    procedure GotoSourceLine(Idx: Integer; SrcList, DstList: TStringList);
    procedure AppIdle(Sender: TObject); // 针对每个 EditControl 的检查
    procedure AddItem(AList: TStringList; const AFileName: string; ALine: Integer);
{$IFDEF BDS}
    function FindActionByNameFromActionManager(ActionManager: TActionManager; AName: string): TBasicAction;
{$ENDIF}

    procedure HookMouseDown(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
  protected
    procedure OnEnhConfig(Sender: TObject);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Install;
    procedure Uninstall;
    procedure UpdateControls;

    procedure InternalUpdateAction;
    procedure ActionUpdate(Sender: TObject);

    property BackAction: TAction read FBackAction;
    property ForwardAction: TAction read FForwardAction;

    property AllowAlt: Boolean read FAllowAlt write FAllowAlt;
    {* 由外界控制的，是否允许 Alt 按下时跑}
  end;

{ TCnSrcEditorNavMgr }

  TCnSrcEditorNavMgr = class(TPersistent)
  private
    FActive: Boolean;
    FList: TList;
    FExtendForwardBack: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FMinLineDiff: Integer;
    FMaxItems: Integer;

    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SetExtendForwardBack(const Value: Boolean);
    procedure AppCommand(var Msg: TMsg; var Handled: Boolean);
  protected
    procedure SetActive(Value: Boolean);

    // 往 EditWindow 里安装，注意 BDS 下可能安装失败但组件实例仍附在里头
    procedure DoUpdateInstall(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);

    procedure DoEnhConfig;
  public
    constructor Create;
    destructor Destroy; override;

    // D567 那种安装到独立的编辑器窗口中
    procedure UpdateInstall;
{$IFDEF BDS}
    // 高版本 Delphi 中安装到主窗体的工具栏上
    procedure DoUpdateInstallInAppBuilder(Sender: TObject);
    procedure FixButtonArrowInComplete(Sender: TObject);
{$ENDIF}
    procedure UpdateControls;
    function GetMainNavigatorOrFromEditControl(EditControl: TControl): TCnSrcEditorNav;
    // 查找 EditControl 对应的 Nav，或者主 Nav

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);
  published
    property ExtendForwardBack: Boolean read FExtendForwardBack write SetExtendForwardBack;
    property MinLineDiff: Integer read FMinLineDiff write FMinLineDiff;
    property MaxItems: Integer read FMaxItems write FMaxItems;
    property Active: Boolean read FActive write SetActive;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  SBackToolButtonName = 'BackToolButton';
  SForwardToolButtonName = 'ForwardToolButton';
  SCnSrcEditorNavName = 'CnSrcEditorNav';
  SBrowserToolBarName = 'BrowserToolBar';
  SBackCommandActionName = 'BackCommand';
  SForwardCommandActionName = 'ForwardCommand';
  SBrowserToolBarImageListName = 'ImageList1';
  SIDEActionManagerName = 'ActionList1';

  SCnBackActionName = 'CnBackAction';
  SCnForwardActionName = 'CnForwardAction';
  csUpdateInterval = 100;

  csDefMinLineDiff = 5;
  csDefMaxItems = 20;

{$IFNDEF SUPPORT_APPCOMMAND}
  // D5 6 未定义
  WM_APPCOMMAND = $0319;

  // D2006 及以下未定义
  APPCOMMAND_BROWSER_BACKWARD = 1;
  APPCOMMAND_BROWSER_FORWARD  = 2;

function GET_APPCOMMAND_LPARAM(const lParam: LongInt): Shortint; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  Result := LongRec(lParam).Hi and not $F000;
end;

{$ENDIF}

{ TCnSrcEditorNav }

constructor TCnSrcEditorNav.Create(AOwner: TComponent);
begin
  inherited;
  FBackMenu := TPopupMenu.Create(Self);
  FForwardMenu := TPopupMenu.Create(Self);
  FBackAction := TAction.Create(Self);
  FForwardAction := TAction.Create(Self);

  FBackMenu.OnPopup := BackMenuPopup;
  FForwardMenu.OnPopup := ForwardMenuPopup;
  FBackAction.OnExecute := BackActionExecute;
  FBackAction.OnUpdate := ActionUpdate;
  FBackAction.ImageIndex := 0;

  FBackAction.Name := SCnBackActionName;
  FForwardAction.OnExecute := ForwardActionExecute;
  FForwardAction.OnUpdate := ActionUpdate;
  FForwardAction.ImageIndex := 1;
  FForwardAction.Name := SCnForwardActionName;

  FBackList := TStringList.Create;
  FForwardList := TStringList.Create;

  CnWizNotifierServices.AddApplicationIdleNotifier(AppIdle);
  EditControlWrapper.AddEditorMouseDownNotifier(HookMouseDown);
end;

destructor TCnSrcEditorNav.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationIdleNotifier(AppIdle);
  EditControlWrapper.RemoveEditorMouseDownNotifier(HookMouseDown);

  Uninstall;
  FBackList.Free;
  FForwardList.Free;
  FNavMgr.FList.Remove(Self);
  inherited;
end;

procedure TCnSrcEditorNav.AddItem(AList: TStringList;
  const AFileName: string; ALine: Integer);
begin
  if AFileName = '' then
    Exit;

  if (AList.Count > 0) and (AList[AList.Count - 1] = AFileName) and
    (TCnNativeInt(AList.Objects[AList.Count - 1]) = ALine) then
    Exit;

  AList.AddObject(AFileName, TObject(ALine));
  UpdateControls;
end;

procedure TCnSrcEditorNav.AppIdle(Sender: TObject);
var
  View: IOTAEditView;

  function IsSelectingBlock: Boolean;
  var
    EPos, EPos1, EPos2: TOTAEditPos;
    CPos, CPos1, CPos2: TOTACharPos;
  begin
    Result := False;
    if View.Block.IsValid then
    begin
      EPos := View.CursorPos;
      View.ConvertPos(True, EPos, CPos);
      EPos1 := OTAEditPos(View.Block.StartingColumn, View.Block.StartingRow);
      EPos2 := OTAEditPos(View.Block.EndingColumn, View.Block.EndingRow);
      View.ConvertPos(True, EPos1, CPos1);
      View.ConvertPos(True, EPos2, CPos2);
      if (CPos.Line = CPos1.Line) and (CPos.CharIndex = CPos1.CharIndex) or
        (CPos.Line = CPos2.Line) and (CPos.CharIndex = CPos2.CharIndex) then
        Result := True;
    end;
  end;

  procedure RecordCurrent;
  begin
    FFileName := View.Buffer.FileName;
    FLine := View.CursorPos.Line;
  end;

begin
  if not FUpdating and not FPause and Assigned(Owner) and
    TCustomForm(Owner).Active then
  begin
    View := EditControlWrapper.GetEditView(FEditControl);
    if Assigned(View) then
    begin
      if FFileName = '' then
      begin
        RecordCurrent;
        Exit;
      end;

      if not SameText(View.Buffer.FileName, FFileName) then
      begin
        // 文件不同，记下来
        AddItem(FBackList, FFileName, FLine);
        RecordCurrent;
      end
      else if (Abs(View.CursorPos.Line - FLine) > FNavMgr.MinLineDiff) and
        not IsSelectingBlock then
      begin
        // 位置足够远且不在拖动选择时，记下来
        AddItem(FBackList, FFileName, FLine);
        RecordCurrent;
      end;
    end;
  end;
end;

procedure TCnSrcEditorNav.GotoSourceLine(Idx: Integer; SrcList, DstList:
  TStringList);
var
  I: Integer;
  AFileName: string;
  ALine: Integer;
  EditPos: TOTAEditPos;
begin
  if (Idx >= 0) and (Idx < SrcList.Count) then
  begin
    FUpdating := True;
    try
      AddItem(DstList, FFileName, FLine);

      AFileName := SrcList[Idx];
      ALine := Integer(SrcList.Objects[Idx]);
      for I := SrcList.Count - 1 downto Idx + 1 do
      begin
        AddItem(DstList, SrcList[I], Integer(SrcList.Objects[I]));
        SrcList.Delete(I);
      end;
      SrcList.Delete(Idx);

      CnOtaMakeSourceVisible(AFileName);
      EditPos.Col := 1;
      EditPos.Line := ALine;
      CnOtaGotoEditPos(EditPos, nil, False);
      FFileName := AFileName;
      FLine := ALine;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorNav.BackActionExecute(Sender: TObject);
var
  State: TShiftState;
begin
  if FAllowAlt then
    State := [ssShift, ssCtrl]
  else
    State := [ssShift, ssAlt, ssCtrl];

  if not FPause and (GetShiftState * State = []) and
    (FBackList.Count > 0) then
    GotoSourceLine(FBackList.Count - 1, FBackList, FForwardList)
  else
    OnIDEBack(nil);
end;

procedure TCnSrcEditorNav.ForwardActionExecute(Sender: TObject);
var
  State: TShiftState;
begin
  if FAllowAlt then
    State := [ssShift, ssCtrl]
  else
    State := [ssShift, ssAlt, ssCtrl];

  if not FPause and (GetShiftState * State = []) and
    (FForwardList.Count > 0) then
    GotoSourceLine(FForwardList.Count - 1, FForwardList, FBackList)
  else
    OnIDEForward(nil);
end;

procedure TCnSrcEditorNav.ActionUpdate(Sender: TObject);
begin
  if GetTickCount - FLastUpdateTick > csUpdateInterval then
  begin
    InternalUpdateAction;
    FLastUpdateTick := GetTickCount;
  end;
end;

function TCnSrcEditorNav.ActionEnabled(AAction: TBasicAction): Boolean;
begin
  if AAction <> nil then
  begin
    if AAction is TCustomAction then
      Result := TCustomAction(AAction).Enabled
    else
      Result := True;
  end
  else
    Result := False;
end;

function TCnSrcEditorNav.MenuEnabled(AMenu: Menus.TPopupMenu): Boolean;
begin
  if AMenu <> nil then
  begin
    AMenu.OnPopup(AMenu);
    Result := AMenu.Items.Count > 0;
  end
  else
    Result := False;
end;

procedure TCnSrcEditorNav.DoMenuPopup(AMenu: Menus.TPopupMenu; AList: TStringList;
  AOnItem, AOnIDE: TNotifyEvent; const AIDECaption, AIDEListCaption: string;
  AOldAction: TBasicAction; AOldMenu: Menus.TPopupMenu);
var
  I: Integer;
  Item: TMenuItem;
{$IFDEF COMPILER7_UP}
  MaxItems: Integer;
  ScreenRect: TRect;
  ScreenHeight: Integer;
{$ENDIF}
begin
  AMenu.Items.Clear;

  if ActionEnabled(AOldAction) and MenuEnabled(AOldMenu) then
  begin
    AddMenuItem(AMenu.Items, AIDECaption, AOnIDE);
    Item := AddMenuItem(AMenu.Items, AIDEListCaption, nil);
    for I := 0 to AOldMenu.Items.Count - 1 do
    begin
      with AOldMenu.Items[I] do
      begin
        AddMenuItem(Item, Caption, OnIDEListClick, nil, ShortCut, Hint,
          TCnNativeInt(AOldMenu.Items[I]));
      end;
    end;
    AddSepMenuItem(AMenu.Items);
  end;

  for I := AList.Count - 1 downto 0 do
  begin
    AddMenuItem(AMenu.Items, Format('%s %d', [AList[I],
      TCnNativeInt(AList.Objects[I])]), AOnItem, nil, 0, '', I);
  end;

  AddSepMenuItem(AMenu.Items);
  AddMenuItem(AMenu.Items, SCnSrcEditorNavPause, OnPauseClick).Checked := FPause;
  AddMenuItem(AMenu.Items, SCnEditorEnhanceConfig, OnEnhConfig);

{$IFDEF COMPILER7_UP}
  ScreenRect := GetWorkRect(GetIDEMainForm);
  ScreenHeight := ScreenRect.Bottom - ScreenRect.Top - 200; // 去除 IDE 主窗体高度
  MaxItems := ScreenHeight div GetMainMenuItemHeight;
  if MaxItems < 8 then MaxItems := 8;
  WizActionMgr.ArrangeMenuItems(AMenu.Items, MaxItems);
{$ENDIF}
end;

procedure TCnSrcEditorNav.BackMenuPopup(Sender: TObject);
begin
  DoMenuPopup(FBackMenu, FBackList, BackMenuClick, OnIDEBack,
    SCnSrcEditorNavIDEBack, SCnSrcEditorNavIDEBackList, FOldBackAction,
    FOldBackMenu);
end;

procedure TCnSrcEditorNav.ForwardMenuPopup(Sender: TObject);
begin
  DoMenuPopup(FForwardMenu, FForwardList, ForwardMenuClick, OnIDEForward,
    SCnSrcEditorNavIDEForward, SCnSrcEditorNavIDEForwardList, FOldForwardAction,
    FOldForwardMenu);
end;

procedure TCnSrcEditorNav.BackMenuClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    GotoSourceLine(TMenuItem(Sender).Tag, FBackList, FForwardList);
end;

procedure TCnSrcEditorNav.ForwardMenuClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    GotoSourceLine(TMenuItem(Sender).Tag, FForwardList, FBackList);
end;

procedure TCnSrcEditorNav.OnIDEBack(Sender: TObject);
begin
  if ActionEnabled(FOldBackAction) then
  begin
    Uninstall;
    try
      FOldBackAction.Execute;
    finally
      Install;
    end;
  end;
end;

procedure TCnSrcEditorNav.OnIDEForward(Sender: TObject);
begin
  if ActionEnabled(FOldForwardAction) then
  begin
    Uninstall;
    try
      FOldForwardAction.Execute;
    finally
      Install;
    end;
  end;
end;

procedure TCnSrcEditorNav.OnIDEListClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    Uninstall;
    try
      TMenuItem(TMenuItem(Sender).Tag).Click;
    finally
      Install;
    end;
  end;
end;

procedure TCnSrcEditorNav.OnPauseClick(Sender: TObject);
begin
  FPause := not FPause;
end;

procedure TCnSrcEditorNav.Install;
var
  BackButton: TToolButton;
  ForwardButton: TToolButton;
{$IFDEF BDS}
  BrowserToolbar: TToolBar;
{$ENDIF}
begin
  // 注意 Owner 在低版本里是 EditWindow，高版本里是 MainForm
  if Assigned(Owner) then
  begin
    BackButton := TToolButton(Owner.FindComponent(SBackToolButtonName));
    if Assigned(BackButton) and (BackButton.Action <> FBackAction) then
    begin
      FOldImageList := TToolBar(BackButton.Parent).Images;
      TToolBar(BackButton.Parent).Images := dmCnSharedImages.ilBackForward;
      FOldBackAction := BackButton.Action;

      if FOldBackAction <> nil then
      begin
        if FOldBackAction is TCustomAction then
          FOldBackShortCut := (FOldBackAction as TCustomAction).ShortCut
        else
          FOldBackShortCut := 0;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TCnSrcEditorNav.Install. Old Back %s with Shortcut %s',
          [FOldBackAction.Name, ShortCutToText(FOldBackShortCut)]);
{$ENDIF}
      end;

      FOldBackMenu := BackButton.DropdownMenu;
      FOldBackImageIndex := BackButton.ImageIndex;
      BackButton.Action := FBackAction;
      BackButton.DropdownMenu := FBackMenu;

      // 快捷键也抢过来
      if FOldBackShortCut <> 0 then
      begin
        (FOldBackAction as TCustomAction).ShortCut := 0;
        FBackAction.ShortCut := FOldBackShortCut;
      end;
    end;

    ForwardButton := TToolButton(Owner.FindComponent(SForwardToolButtonName));
    if Assigned(ForwardButton) and (ForwardButton.Action <> FForwardAction) then
    begin
      FOldForwardAction := ForwardButton.Action;
      FOldForwardMenu := ForwardButton.DropdownMenu;

      if FOldForwardAction <> nil then
      begin
        if FOldForwardAction is TCustomAction then
          FOldForwardShortCut := (FOldForwardAction as TCustomAction).ShortCut
        else
          FOldForwardShortCut := 0;
{$IFDEF DEBUG}
        CnDebugger.LogFmt('TCnSrcEditorNav.Install. Old Forward %s with Shortcut %s',
          [FOldForwardAction.Name, ShortCutToText(FOldForwardShortCut)]);
{$ENDIF}
      end;

      FOldForwardImageIndex := ForwardButton.ImageIndex;
      ForwardButton.Action := FForwardAction;
      ForwardButton.DropdownMenu := FForwardMenu;

      // 快捷键也抢过来
      if FOldForwardShortCut <> 0 then
      begin
        (FOldForwardAction as TCustomAction).ShortCut := 0;
        FForwardAction.ShortCut := FOldForwardShortCut;
      end;
    end;

{$IFDEF BDS}
    // 高版本里如果 EditWindow 里没找到，则当成 MainForm 找
    if (BackButton = nil) and (ForwardButton = nil) then
    begin
      // In AppBuilder, install it to Toolbar.
      BrowserToolbar := TToolBar(Owner.FindComponent(SBrowserToolBarName));
      if BrowserToolbar <> nil then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnSrcEditorNav.Install. Got BrowserToolbar.');
{$ENDIF}
        BackButton := BrowserToolbar.Buttons[0];
        ForwardButton := BrowserToolbar.Buttons[1];

        if Assigned(BackButton) and (BackButton.Parent <> nil) and (BackButton.Action <> FBackAction) then
        begin
          FOldImageList := TToolBar(BackButton.Parent).Images;
{$IFDEF IDE_SUPPORT_HDPI}
          TToolBar(BackButton.Parent).Images := IdeGetVirtualImageListFromOrigin(dmCnSharedImages.ilBackForwardBDS, nil, True);
{$ELSE}
          TToolBar(BackButton.Parent).Images := dmCnSharedImages.ilBackForwardBDS;
{$ENDIF}

          FOldBackAction := BackButton.Action;
          FOldBackMenu := BackButton.DropdownMenu;

          if FOldBackAction <> nil then
          begin
            if FOldBackAction is TCustomAction then
              FOldBackShortCut := (FOldBackAction as TCustomAction).ShortCut
            else
              FOldBackShortCut := 0;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('TCnSrcEditorNav.Install in BDS. Old Back %s with Shortcut %s',
              [FOldBackAction.Name, ShortCutToText(FOldBackShortCut)]);
{$ENDIF}
          end;

          FOldBackImageIndex := BackButton.ImageIndex;
          BackButton.Action := FBackAction;
          BackButton.DropdownMenu := FBackMenu;
{$IFDEF IDE_SUPPORT_HDPI}
          BackButton.ImageIndex := FBackAction.ImageIndex;
{$ENDIF}

          // 快捷键也抢过来
          if FOldBackShortCut <> 0 then
          begin
            (FBackAction as TCustomAction).ShortCut := 0;
            FBackAction.ShortCut := FOldBackShortCut;
          end;
        end;

        if Assigned(ForwardButton) and (ForwardButton.Action <> FForwardAction) then
        begin
          FOldForwardAction := ForwardButton.Action;
          FOldForwardMenu := ForwardButton.DropdownMenu;

          if FOldForwardAction <> nil then
          begin
            if FOldForwardAction is TCustomAction then
              FOldForwardShortCut := (FOldForwardAction as TCustomAction).ShortCut
            else
              FOldForwardShortCut := 0;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('TCnSrcEditorNav.Install in BDS. Old Forward %s with Shortcut %s',
              [FOldForwardAction.Name, ShortCutToText(FOldForwardShortCut)]);
{$ENDIF}
          end;

          FOldForwardImageIndex := ForwardButton.ImageIndex;
          ForwardButton.Action := FForwardAction;
          ForwardButton.DropdownMenu := FForwardMenu;
{$IFDEF IDE_SUPPORT_HDPI}
          ForwardButton.ImageIndex := FForwardAction.ImageIndex;
{$ENDIF}

          // 快捷键也抢过来
          if FOldForwardShortCut <> 0 then
          begin
            (FOldForwardAction as TCustomAction).ShortCut := 0;
            FForwardAction.ShortCut := FOldForwardShortCut;
          end;
        end;
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnSrcEditorNav.Install. Buttons Hooked.');
{$ENDIF}
      end;
    end;
{$ENDIF}
  end;
end;

procedure TCnSrcEditorNav.Uninstall;
var
  BackButton: TToolButton;
  ForwardButton: TToolButton;
{$IFDEF BDS}
  BrowserToolbar: TToolBar;
  ActionMgr: TActionManager;
{$ENDIF}
begin
  if Assigned(Owner) then
  begin
    BackButton := TToolButton(Owner.FindComponent(SBackToolButtonName));
    if Assigned(BackButton) and (BackButton.Action = FBackAction) then
    begin
      TToolBar(BackButton.Parent).Images := FOldImageList;
      BackButton.Action := FOldBackAction;
      BackButton.DropdownMenu := FOldBackMenu;
      if BackButton.ImageIndex = -1 then
        BackButton.ImageIndex := FOldBackImageIndex;

      // 恢复快捷键
      if FOldBackShortCut <> 0 then
      begin
        (FOldBackAction as TCustomAction).ShortCut := FOldBackShortCut;
        FBackAction.ShortCut := 0;
      end;
    end;

    ForwardButton := TToolButton(Owner.FindComponent(SForwardToolButtonName));
    if Assigned(ForwardButton) and (ForwardButton.Action = FForwardAction) then
    begin
      ForwardButton.Action := FOldForwardAction;
      ForwardButton.DropdownMenu := FOldForwardMenu;
      if ForwardButton.ImageIndex = -1 then
        ForwardButton.ImageIndex := FOldForwardImageIndex;

      // 恢复快捷键
      if FOldForwardShortCut <> 0 then
      begin
        (FOldForwardAction as TCustomAction).ShortCut := FOldForwardShortCut;
        FForwardAction.ShortCut := 0;
      end;
    end;

{$IFDEF BDS}
    if (BackButton = nil) and (ForwardButton = nil) then
    begin
      // In AppBuilder, uninstall it from Toolbar.
      BrowserToolbar := TToolBar(Owner.FindComponent(SBrowserToolBarName));
      if BrowserToolbar <> nil then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnSrcEditorNav.UnInstall. Got BrowserToolbar.');
{$ENDIF}
        BackButton := BrowserToolbar.Buttons[0];
        ForwardButton := BrowserToolbar.Buttons[1];

        ActionMgr := TActionManager(Owner.FindComponent(SIDEActionManagerName));
        if ActionMgr <> nil then
        begin
          if Assigned(BackButton) and (BackButton.Action = FBackAction) then
          begin
            TToolBar(BackButton.Parent).Images := TImageList(Owner.FindComponent(SBrowserToolBarImageListName));

            BackButton.Action := FindActionByNameFromActionManager(ActionMgr, SBackCommandActionName);
            BackButton.DropdownMenu := FOldBackMenu;
            if BackButton.ImageIndex = -1 then
              BackButton.ImageIndex := FOldBackImageIndex;

            // 恢复快捷键
            if (FOldBackShortCut <> 0) and (BackButton.Action <> nil) then
            begin
              (BackButton.Action as TCustomAction).ShortCut := FOldBackShortCut;
              FBackAction.ShortCut := 0;
            end;
          end;

          if Assigned(ForwardButton) and (ForwardButton.Action = FForwardAction) then
          begin
            ForwardButton.Action := FindActionByNameFromActionManager(ActionMgr, SForwardCommandActionName);
            ForwardButton.DropdownMenu := FOldForwardMenu;
            if ForwardButton.ImageIndex = -1 then
              ForwardButton.ImageIndex := FOldForwardImageIndex;

            // 恢复快捷键
            if (FOldForwardShortCut <> 0) and (ForwardButton.Action <> nil) then
            begin
              (ForwardButton.Action as TCustomAction).ShortCut := FOldForwardShortCut;
              FForwardAction.ShortCut := 0;
            end;
          end;
        end;
      end;
    end;
{$ENDIF}
  end;
end;

procedure TCnSrcEditorNav.UpdateControls;
begin
  while (FBackList.Count > 0) and (FBackList.Count > FNavMgr.MaxItems) do
    FBackList.Delete(0);
  while (FForwardList.Count > 0) and (FForwardList.Count > FNavMgr.MaxItems) do
    FForwardList.Delete(0);
end;

procedure TCnSrcEditorNav.OnEnhConfig(Sender: TObject);
begin
  FNavMgr.DoEnhConfig;
end;

procedure TCnSrcEditorNav.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FOldBackMenu then
      FOldBackMenu := nil
    else if AComponent = FOldForwardMenu then
      FOldForwardMenu := nil
    else if AComponent = FOldBackAction then
      FOldBackAction := nil
    else if AComponent = FOldForwardAction then
      FOldForwardAction := nil;
  end;
end;

{$IFDEF BDS}

function TCnSrcEditorNav.FindActionByNameFromActionManager(
  ActionManager: TActionManager; AName: string): TBasicAction;
var
  I: Integer;
begin
  Result := nil;
  if ActionManager = nil then
    Exit;

  for I := 0 to ActionManager.ActionCount - 1 do
  begin
    if ActionManager.Actions[I].Name = AName then
    begin
      Result := ActionManager.Actions[I];
      Exit;
    end;
  end;
end;

{$ENDIF}

procedure TCnSrcEditorNav.HookMouseDown(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  Line: Integer;
  P: TPoint;
begin
  if (Button = mbLeft) and (ssCtrl in Shift) then
  begin
    if Editor.EditControl.Cursor = crHandPoint then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Mouse Down with HandPoint. IDE Find Declaration Jump Found.');
{$ENDIF}
      // 获取光标下的当前行，并判断并记录入历史记录
      P.x := X;
      P.y := Y;
      Line := EditControlWrapper.GetLineFromPoint(P, Editor.EditControl, Editor.EditView);

{$IFDEF DEBUG}
      CnDebugger.LogMsg('IDE Find Declaration Jump From ' + IntToStr(Line));
{$ENDIF}

      if FFileName = '' then
      begin
        FFileName := Editor.EditView.Buffer.FileName;
        FLine := Line;
      end
      else if (not SameText(Editor.EditView.Buffer.FileName, FFileName) or
        (Abs(Line - FLine) > FNavMgr.MinLineDiff)) then
      begin
        AddItem(FBackList, FFileName, FLine);
        FFileName := Editor.EditView.Buffer.FileName;
        FLine := Line;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Add IDE Find Declaration Jump to History.');
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnSrcEditorNav.InternalUpdateAction;
begin
  FBackAction.Enabled := (not FPause and (FBackList.Count > 0)) or
    MenuEnabled(FOldBackMenu);
  FForwardAction.Enabled := (not FPause and (FForwardList.Count > 0)) or
    MenuEnabled(FOldForwardMenu);
end;

{ TCnSrcEditorNavMgr }

constructor TCnSrcEditorNavMgr.Create;
begin
  inherited;
  FMinLineDiff := csDefMinLineDiff;
  FMaxItems := csDefMaxItems;
  FExtendForwardBack := True;
  FActive := True;
  FList := TList.Create;

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  CnWizNotifierServices.AddApplicationMessageNotifier(AppCommand);
  UpdateInstall;
end;

destructor TCnSrcEditorNavMgr.Destroy;
var
  I: Integer;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(AppCommand);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for I := FList.Count - 1 downto 0 do
    TCnSrcEditorNav(FList[I]).Free;
  FList.Free;
  inherited;
end;

procedure TCnSrcEditorNavMgr.DoUpdateInstall(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
var
  EditorNav: TCnSrcEditorNav;
begin
  EditorNav := TCnSrcEditorNav(FindComponentByClass(EditWindow,
    TCnSrcEditorNav, SCnSrcEditorNavName));
  if Active and ExtendForwardBack then
  begin
    if not Assigned(EditorNav) then
    begin
      EditorNav := TCnSrcEditorNav.Create(EditWindow);
      EditorNav.Name := SCnSrcEditorNavName;
      EditorNav.FNavMgr := Self;
      EditorNav.FEditControl := EditControl;
      EditorNav.Install; // 注意高版本 Delphi 里头 Install 可能失败但还存在
      FList.Add(EditorNav);
    end;
  end
  else if Assigned(EditorNav) then
  begin
    EditorNav.Free;
  end;
end;

{$IFDEF BDS}

procedure TCnSrcEditorNavMgr.DoUpdateInstallInAppBuilder(Sender: TObject);
var
  EditorNav: TCnSrcEditorNav;
begin
  EditorNav := TCnSrcEditorNav(FindComponentByClass(GetIDEMainForm,
    TCnSrcEditorNav, SCnSrcEditorNavName));
  if Active and ExtendForwardBack then
  begin
    if not Assigned(EditorNav) then
    begin
      EditorNav := TCnSrcEditorNav.Create(GetIDEMainForm);
      EditorNav.Name := SCnSrcEditorNavName;
      EditorNav.FNavMgr := Self;
      EditorNav.FEditControl := nil; // 主工具栏上，暂无当前 EditControl
      EditorNav.Install;
      FList.Add(EditorNav);

      CnWizNotifierServices.ExecuteOnApplicationIdle(FixButtonArrowInComplete);
    end;
  end
  else if Assigned(EditorNav) then
  begin
    EditorNav.Free;
  end;
end;

procedure TCnSrcEditorNavMgr.FixButtonArrowInComplete(Sender: TObject);
var
  EditorNav: TCnSrcEditorNav;
  BrowserToolbar: TToolBar;
  ToolbarParent: TWinControl;
  P: TPoint;
  Wizard: TCnBaseWizard;
begin
  if Active and ExtendForwardBack then
  begin
    EditorNav := TCnSrcEditorNav(FindComponentByClass(GetIDEMainForm,
      TCnSrcEditorNav, SCnSrcEditorNavName));
    if EditorNav <> nil then
    begin
      // Send Drag Message to Fix its Icon Showing Problem.
      BrowserToolbar := TToolBar(EditorNav.Owner.FindComponent(SBrowserToolBarName));
      if BrowserToolbar <> nil then
      begin
        ToolbarParent := BrowserToolbar.Parent;
        if ToolbarParent <> nil then
        begin
          P.X := 5;
          P.Y := BrowserToolbar.Height div 2;
          P := BrowserToolbar.ClientToParent(P);

          Wizard := CnWizardMgr.WizardByClassName('TCnPaletteEnhanceWizard');
          if Wizard <> nil then
          try
            SetPropValue(Wizard, 'TempDisableLock', True);
          except
            ;
          end;

          SendMessage(ToolbarParent.Handle, WM_LBUTTONDOWN, 0, MakeLParam(P.X, P.Y));
          SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X + 1, P.Y));
          SendMessage(ToolbarParent.Handle, WM_MOUSEMOVE, 0, MakeLParam(P.X, P.Y));
          SendMessage(ToolbarParent.Handle, WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y));

          if Wizard <> nil then
          try
            SetPropValue(Wizard, 'TempDisableLock', False);
          except
            ;
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

procedure TCnSrcEditorNavMgr.UpdateInstall;
begin
  EnumEditControl(DoUpdateInstall, nil);
{$IFDEF BDS}
  // 必须放 Idle 里，因为第一次执行到此时，BDS 中的俩 Button 所在的工具栏还没创建
  CnWizNotifierServices.ExecuteOnApplicationIdle(DoUpdateInstallInAppBuilder);
{$ENDIF}
  UpdateControls;
end;

procedure TCnSrcEditorNavMgr.AppCommand(var Msg: TMsg; var Handled: Boolean);
var
  V: Integer;
  EditorNav: TCnSrcEditorNav;
begin
  if not Active or not FExtendForwardBack or (Msg.message <> WM_APPCOMMAND) then
    Exit;

  V := GET_APPCOMMAND_LPARAM(Msg.LParam);

  if not (V in [APPCOMMAND_BROWSER_BACKWARD, APPCOMMAND_BROWSER_FORWARD])
    or not IsEditControl(Screen.ActiveControl) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSrcEditorNavMgr.AppCommand on EditControl: Param ' + IntToStr(V));
{$ENDIF}

  EditorNav := TCnSrcEditorNav(FindComponentByClass(CnOtaGetCurrentEditWindow,
    TCnSrcEditorNav, SCnSrcEditorNavName));

{$IFDEF DEBUG}
  if EditorNav <> nil then
    CnDebugger.LogMsg('TCnSrcEditorNavMgr.AppCommand: Get Active SrcEditorNav from EditWindow.')
  else
    CnDebugger.LogMsgWarning('TCnSrcEditorNavMgr.AppCommand: Active SrcEditorNav Not Found in EditWindow.');
{$ENDIF}

  if (EditorNav = nil) or (EditorNav.FOldBackAction = nil) or (EditorNav.FOldForwardAction = nil) then
  begin
    // 当前编辑器窗体里没找到，或找到了但安装失败，则要去 MainForm 里找
    EditorNav := TCnSrcEditorNav(FindComponentByClass(GetIDEMainForm,
      TCnSrcEditorNav, SCnSrcEditorNavName));

{$IFDEF DEBUG}
  if EditorNav <> nil then
    CnDebugger.LogMsg('TCnSrcEditorNavMgr.AppCommand: Get Active SrcEditorNav from AppBuilder.')
  else
    CnDebugger.LogMsgWarning('TCnSrcEditorNavMgr.AppCommand: Active SrcEditorNav Not Found in AppBuilder.');
{$ENDIF}
  end;

  if EditorNav = nil then
    Exit;

  EditorNav.InternalUpdateAction;
  if V = APPCOMMAND_BROWSER_BACKWARD then
  begin
    if EditorNav.BackAction <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnSrcEditorNavMgr.AppCommand: To Execute BackAction. Enabled: %d',
        [Ord(EditorNav.BackAction.Enabled)]);
{$ENDIF}
      EditorNav.BackAction.Execute;
      Handled := True;
    end;
  end
  else if V = APPCOMMAND_BROWSER_FORWARD then
  begin
    if EditorNav.ForwardAction <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnSrcEditorNavMgr.AppCommand: To Execute ForwardAction. Enabled: %d',
        [Ord(EditorNav.ForwardAction.Enabled)]);
{$ENDIF}
      EditorNav.ForwardAction.Execute;
      Handled := True;
    end;
  end;
end;

procedure TCnSrcEditorNavMgr.EditControlNotify(EditControl: TControl; EditWindow:
  TCustomForm; Operation: TOperation);
begin
  if Operation = opInsert then
    UpdateInstall;
end;

procedure TCnSrcEditorNavMgr.UpdateControls;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TCnSrcEditorNav(FList[I]).UpdateControls;
end;

function TCnSrcEditorNavMgr.GetMainNavigatorOrFromEditControl(EditControl: TControl): TCnSrcEditorNav;
var
  I: Integer;
  Nav: TCnSrcEditorNav;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Nav := TCnSrcEditorNav(FList[I]);
    if (Nav <> nil) and ((Nav.FEditControl = EditControl) or (Nav.FEditControl = nil)) then
    begin
      Result := Nav;
      Exit;
    end;
  end;
  Result := nil;
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

const
  csEditorNav = 'EditorNav';
  csExtendForwardBack = 'ExtendForwardBack';
  csMinLineDiff = 'MinLineDiff';
  csMaxItems = 'MaxItems';

procedure TCnSrcEditorNavMgr.LoadSettings(Ini: TCustomIniFile);
begin
  FExtendForwardBack := Ini.ReadBool(csEditorNav, csExtendForwardBack, True);
  FMinLineDiff := Ini.ReadInteger(csEditorNav, csMinLineDiff, csDefMinLineDiff);
  FMaxItems := Ini.ReadInteger(csEditorNav, csMaxItems, csDefMaxItems);
end;

procedure TCnSrcEditorNavMgr.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csEditorNav, csExtendForwardBack, FExtendForwardBack);
  Ini.WriteInteger(csEditorNav, csMinLineDiff, FMinLineDiff);
  Ini.WriteInteger(csEditorNav, csMaxItems, FMaxItems);
end;

procedure TCnSrcEditorNavMgr.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnSrcEditorNavMgr.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

procedure TCnSrcEditorNavMgr.LanguageChanged(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

procedure TCnSrcEditorNavMgr.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UpdateInstall;
  end;
end;

procedure TCnSrcEditorNavMgr.SetExtendForwardBack(const Value: Boolean);
begin
  if FExtendForwardBack <> Value then
  begin
    FExtendForwardBack := Value;
    UpdateInstall;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
