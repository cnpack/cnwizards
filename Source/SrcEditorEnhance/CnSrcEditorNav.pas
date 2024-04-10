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
  CnWizMenuAction;

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
    FOldImageList: TCustomImageList;
    FLastUpdateTick: Cardinal;
    FBackMenu: TPopupMenu;
    FForwardMenu: TPopupMenu;
    FBackAction: TAction;
    FForwardAction: TAction;
    FBackList: TStringList;
    FForwardList: TStringList;
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
    procedure ActionUpdate(Sender: TObject);
    procedure GotoSourceLine(Idx: Integer; SrcList, DstList: TStringList);
    procedure AppIdle(Sender: TObject);
    procedure AddItem(AList: TStringList; const AFileName: string; ALine: Integer);
{$IFDEF BDS}
    function FindActionByNameFromActionManager(ActionManager: TActionManager; AName: string): TBasicAction;
{$ENDIF}

    procedure HookMouseDown(Editor: TEditorObject; Button: TMouseButton;
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
  protected
    procedure SetActive(Value: Boolean); 
    procedure DoUpdateInstall(EditWindow: TCustomForm; EditControl: TControl;
      Context: Pointer);
    procedure DoEnhConfig;
  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateInstall;
{$IFDEF BDS}
    procedure DoUpdateInstallInAppBuilder(Sender: TObject);
    procedure FixButtonArrowInComplete(Sender: TObject);
{$ENDIF}
    procedure UpdateControls;

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
    (Integer(AList.Objects[AList.Count - 1]) = ALine) then
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

begin
  if not FUpdating and not FPause and Assigned(Owner) and
    TCustomForm(Owner).Active then
  begin
    View := EditControlWrapper.GetEditView(FEditControl);
    if Assigned(View) then
    begin
      if FFileName = '' then
      begin
        FFileName := View.Buffer.FileName;
        FLine := View.CursorPos.Line;
      end
      else if (not SameText(View.Buffer.FileName, FFileName) or
        (Abs(View.CursorPos.Line - FLine) > FNavMgr.MinLineDiff)) and
        not IsSelectingBlock then
      begin
        AddItem(FBackList, FFileName, FLine);
        FFileName := View.Buffer.FileName;
        FLine := View.CursorPos.Line;
      end;
    end;
  end;
end;

procedure TCnSrcEditorNav.GotoSourceLine(Idx: Integer; SrcList, DstList:
  TStringList);
var
  i: Integer;
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
      for i := SrcList.Count - 1 downto Idx + 1 do
      begin
        AddItem(DstList, SrcList[i], Integer(SrcList.Objects[i]));
        SrcList.Delete(i);
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
begin
  if not FPause and (GetShiftState * [ssShift, ssAlt, ssCtrl] = []) and
    (FBackList.Count > 0) then
    GotoSourceLine(FBackList.Count - 1, FBackList, FForwardList)
  else
    OnIDEBack(nil);
end;

procedure TCnSrcEditorNav.ForwardActionExecute(Sender: TObject);
begin
  if not FPause and (GetShiftState * [ssShift, ssAlt, ssCtrl] = []) and
    (FForwardList.Count > 0) then
    GotoSourceLine(FForwardList.Count - 1, FForwardList, FBackList)
  else
    OnIDEForward(nil);
end;

procedure TCnSrcEditorNav.ActionUpdate(Sender: TObject);
begin
  if GetTickCount - FLastUpdateTick > csUpdateInterval then
  begin
    FBackAction.Enabled := (not FPause and (FBackList.Count > 0)) or
      MenuEnabled(FOldBackMenu);
    FForwardAction.Enabled := (not FPause and (FForwardList.Count > 0)) or
      MenuEnabled(FOldForwardMenu);
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
      with AOldMenu.Items[I] do
      begin
        AddMenuItem(Item, Caption, OnIDEListClick, nil, ShortCut, Hint,
          Integer(AOldMenu.Items[I]));
      end;
    AddSepMenuItem(AMenu.Items);
  end;

  for I := AList.Count - 1 downto 0 do
    AddMenuItem(AMenu.Items, Format('%s %d', [AList[I],
      Integer(AList.Objects[I])]), AOnItem, nil, 0, '', I);

  AddSepMenuItem(AMenu.Items);
  AddMenuItem(AMenu.Items, SCnSrcEditorNavPause, OnPauseClick).Checked := FPause;
  AddMenuItem(AMenu.Items, SCnEditorEnhanceConfig, OnEnhConfig);

{$IFDEF COMPILER7_UP}
  ScreenRect := GetWorkRect(GetIdeMainForm);
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
      BackButton.Action := FBackAction;
      BackButton.DropdownMenu := FBackMenu;
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

      ForwardButton.Action := FForwardAction;
      ForwardButton.DropdownMenu := FForwardMenu;
    end;

{$IFDEF BDS}
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

          BackButton.Action := FBackAction;
          BackButton.DropdownMenu := FBackMenu;
{$IFDEF IDE_SUPPORT_HDPI}
          BackButton.ImageIndex := FBackAction.ImageIndex;
{$ENDIF}
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

          ForwardButton.Action := FForwardAction;
          ForwardButton.DropdownMenu := FForwardMenu;
{$IFDEF IDE_SUPPORT_HDPI}
          ForwardButton.ImageIndex := FForwardAction.ImageIndex;
{$ENDIF}
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
    end;

    ForwardButton := TToolButton(Owner.FindComponent(SForwardToolButtonName));
    if Assigned(ForwardButton) and (ForwardButton.Action = FForwardAction) then
    begin
      ForwardButton.Action := FOldForwardAction;
      ForwardButton.DropdownMenu := FOldForwardMenu;
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
          end;

          if Assigned(ForwardButton) and (ForwardButton.Action = FForwardAction) then
          begin
            ForwardButton.Action := FindActionByNameFromActionManager(ActionMgr, SForwardCommandActionName);
            ForwardButton.DropdownMenu := FOldForwardMenu;
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

procedure TCnSrcEditorNav.HookMouseDown(Editor: TEditorObject;
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
  UpdateInstall;
end;

destructor TCnSrcEditorNavMgr.Destroy;
var
  i: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for i := FList.Count - 1 downto 0 do
    TCnSrcEditorNav(FList[i]).Free;
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
      EditorNav.Install;
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
  EditorNav := TCnSrcEditorNav(FindComponentByClass(GetIdeMainForm,
    TCnSrcEditorNav, SCnSrcEditorNavName));
  if Active and ExtendForwardBack then
  begin
    if not Assigned(EditorNav) then
    begin
      EditorNav := TCnSrcEditorNav.Create(GetIdeMainForm);
      EditorNav.Name := SCnSrcEditorNavName;
      EditorNav.FNavMgr := Self;
      EditorNav.FEditControl := nil;
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
    EditorNav := TCnSrcEditorNav(FindComponentByClass(GetIdeMainForm,
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

procedure TCnSrcEditorNavMgr.EditControlNotify(EditControl: TControl; EditWindow:
  TCustomForm; Operation: TOperation);
begin
  if Operation = opInsert then
    UpdateInstall;
end;

procedure TCnSrcEditorNavMgr.UpdateControls;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    TCnSrcEditorNav(FList[i]).UpdateControls;
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
