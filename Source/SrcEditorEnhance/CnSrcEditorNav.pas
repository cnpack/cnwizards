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
* 单元标识：$Id$
* 修改记录：2005.01.03
*               创建单元，从原 CnEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFNDEF BDS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Math, CnCommon, ActnList, ImgList,
  CnWizUtils, CnConsts, CnWizIdeUtils, CnWizConsts, CnMenuHook, CnWizNotifier,
  CnEditControlWrapper, CnWizShareImages, CnPopupMenu;

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

  TCnSrcEditorNavMgr = class(TObject)
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
    procedure UpdateControls;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property ExtendForwardBack: Boolean read FExtendForwardBack write SetExtendForwardBack;
    property MinLineDiff: Integer read FMinLineDiff write FMinLineDiff;
    property MaxItems: Integer read FMaxItems write FMaxItems;
    property Active: Boolean read FActive write SetActive;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

implementation

const
  SBackToolButtonName = 'BackToolButton';
  SForwardToolButtonName = 'ForwardToolButton';
  SCnSrcEditorNavName = 'CnSrcEditorNav';
  csUpdateInterval = 100;

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
  FForwardAction.OnExecute := ForwardActionExecute;
  FForwardAction.OnUpdate := ActionUpdate;
  FForwardAction.ImageIndex := 1;
  
  FBackList := TStringList.Create;
  FForwardList := TStringList.Create;

  CnWizNotifierServices.AddApplicationIdleNotifier(AppIdle);
end;

destructor TCnSrcEditorNav.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationIdleNotifier(AppIdle);
  
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
      CnOtaGotoEditPos(EditPos, nil, True);
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
  i: Integer;
  Item: TMenuItem;
begin
  AMenu.Items.Clear;

  if ActionEnabled(AOldAction) and MenuEnabled(AOldMenu) then
  begin
    AddMenuItem(AMenu.Items, AIDECaption, AOnIDE);
    Item := AddMenuItem(AMenu.Items, AIDEListCaption, nil);
    for i := 0 to AOldMenu.Items.Count - 1 do
      with AOldMenu.Items[i] do
      begin
        AddMenuItem(Item, Caption, OnIDEListClick, nil, ShortCut, Hint,
          Integer(AOldMenu.Items[i]));
      end;
    AddSepMenuItem(AMenu.Items);
  end;

  for i := AList.Count - 1 downto 0 do
    AddMenuItem(AMenu.Items, Format('%s %d', [AList[i],
      Integer(AList.Objects[i])]), AOnItem, nil, 0, '', i);

  AddSepMenuItem(AMenu.Items);
  AddMenuItem(AMenu.Items, SCnSrcEditorNavPause, OnPauseClick).Checked := FPause;
  AddMenuItem(AMenu.Items, SCnEditorEnhanceConfig, OnEnhConfig);
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
begin
  if Assigned(Owner) then
  begin
    BackButton := TToolButton(Owner.FindComponent(SBackToolButtonName));
    if Assigned(BackButton) and (BackButton.Action <> FBackAction) then
    begin
      FOldImageList := TToolBar(BackButton.Parent).Images;
      TToolBar(BackButton.Parent).Images := dmCnSharedImages.ilBackForward;
      FOldBackAction := BackButton.Action;
      FOldBackMenu := BackButton.DropdownMenu;
      BackButton.Action := FBackAction;
      BackButton.DropdownMenu := FBackMenu;
    end;

    ForwardButton := TToolButton(Owner.FindComponent(SForwardToolButtonName));
    if Assigned(ForwardButton) and (ForwardButton.Action <> FForwardAction) then
    begin
      FOldForwardAction := ForwardButton.Action;
      FOldForwardMenu := ForwardButton.DropdownMenu;
      ForwardButton.Action := FForwardAction;
      ForwardButton.DropdownMenu := FForwardMenu;
    end;
  end;
end;

procedure TCnSrcEditorNav.Uninstall;
var
  BackButton: TToolButton;
  ForwardButton: TToolButton;
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

{ TCnSrcEditorNavMgr }

constructor TCnSrcEditorNavMgr.Create;
begin
  inherited;
  FMinLineDiff := 5;
  FMaxItems := 20;
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

procedure TCnSrcEditorNavMgr.UpdateInstall;
begin
  EnumEditControl(DoUpdateInstall, nil);
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
  FMinLineDiff := Ini.ReadInteger(csEditorNav, csMinLineDiff, FMinLineDiff);
  FMaxItems := Ini.ReadInteger(csEditorNav, csMaxItems, FMaxItems);
end;

procedure TCnSrcEditorNavMgr.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csEditorNav, csExtendForwardBack, FExtendForwardBack);
  Ini.WriteInteger(csEditorNav, csMinLineDiff, FMinLineDiff);
  Ini.WriteInteger(csEditorNav, csMaxItems, FMaxItems);
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

{$ELSE}

implementation

{$ENDIF}

end.
