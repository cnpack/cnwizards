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

unit CnWizEdtTabSetHook;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器 TabSet 挂接单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元用于扩展IDE源码编辑器的TabSet标签
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Classes, Messages, SysUtils, Graphics, Controls, ComCtrls, ExtCtrls,
  Forms, CommCtrl, Tabs, ToolsAPI, CnWizNotifier, CnWizIdeUtils, CnWizEdtTabSetFrm,
  CnWizUtils, CnCommon;

type
  TCnWizEdtTabSetHook = class
  private
    FClasses: TList;
    procedure OnActiveFormChange(Sender: TObject);
    procedure UpdateHook;
    procedure Unhook;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddEditPage(AClass: TCnWizEdtTabSetFormClass);
    procedure RemoveEditPage(AClass: TCnWizEdtTabSetFormClass);
  end;

function EditorTabSetHook: TCnWizEdtTabSetHook;

implementation

{$IFDEF Debug}
uses
  CnDebug;
{$ENDIF}

const
  csEditControlClassName = 'TEditControl';
  csEditControlName = 'Editor';
  csStatusBarName = 'StatusBar';
  csStatusBarHeight = 22;
  csIDETabSetName = 'ViewBar';
  csTabControlClassName = 'TXTabControl';
  csTabControlName = 'TabControl';
  csLastPanelWidth = 50;
  csTabCodeCaption = 'Code';
  SB_GETRECT = WM_USER + 10;

var
  FEditorTabSetHook: TCnWizEdtTabSetHook;

function EditorTabSetHook: TCnWizEdtTabSetHook;
begin
  if FEditorTabSetHook = nil then
    FEditorTabSetHook := TCnWizEdtTabSetHook.Create;
  Result := FEditorTabSetHook;
end;

type

{ TCnWizEdtTabSetHookComp }

  TCnWizEdtTabSetHookComp = class(TComponent)
  private
  {$IFDEF COMPILER5}
    FSaveHeight: Integer;
  {$ENDIF}
    FChanging: Boolean;
    FHook: TCnWizEdtTabSetHook;
    FForm: TForm;
    FTabSet: TTabSet;
    FIDETabSet: TTabSet;
    FList: TList;
    FStatusBar: TStatusBar;
    FTabControl: TTabControl;
    FEditControl: TWinControl;
    procedure DoUpdateTabSet(Sender: TObject);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnTabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure OnStatusBarResize(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateHook;
    procedure UpdateTabSet;
    property Form: TForm read FForm;
    property Hook: TCnWizEdtTabSetHook read FHook;
    property TabSet: TTabSet read FTabSet;
    property TabControl: TTabControl read FTabControl;
    property IDETabSet: TTabSet read FIDETabSet;
    property StatusBar: TStatusBar read FStatusBar;
    property EditControl: TWinControl read FEditControl;
  end;

{ TCnWizEdtTabSetHookComp }

constructor TCnWizEdtTabSetHookComp.Create(AOwner: TComponent);
var
  pnlTabSet: TPanel;
begin
  inherited;
  Assert(AOwner is TForm);
  FForm := TForm(AOwner);
  FList := TList.Create;

  FStatusBar := TStatusBar(FindComponentByClass(Form, TStatusBar,
    csStatusBarName));
  Assert(FStatusBar <> nil);
  FTabControl := TTabControl(FindComponentByClassName(Form,
    csTabControlClassName, csTabControlName));
  Assert(FTabControl <> nil);
  FEditControl := TWinControl(FindComponentByClassName(Form,
    csEditControlClassName, csEditControlName));
  Assert(FEditControl <> nil);
  
{$IFDEF COMPILER6_UP}
  FIDETabSet := TTabSet(FindComponentByClass(Form, TTabSet, csIDETabSetName));
  Assert(FIDETabSet <> nil);
  FIDETabSet.Visible := False;
{$ELSE}
  FIDETabSet := nil;
  StatusBar.Parent := FEditControl.Parent.Parent;
  FSaveHeight := StatusBar.Height;
  StatusBar.Height := csStatusBarHeight;
  StatusBar.Panels[StatusBar.Panels.Count - 1].Width := csLastPanelWidth;
  StatusBar.Panels.Add;
{$ENDIF}

  pnlTabSet := TPanel.Create(Self);
  pnlTabSet.BevelInner := bvNone;
  pnlTabSet.BevelOuter := bvNone;
  pnlTabSet.Caption := '';
  pnlTabSet.Name := 'CnEditorTabSetPanel';
  pnlTabSet.Parent := StatusBar;

  FTabSet := TTabSet.Create(Self);
  FTabSet.DitherBackground := False;
  FTabSet.StartMargin := 0;
  FTabSet.EndMargin := 0;
  FTabSet.Parent := pnlTabSet;
  FTabSet.OnChange := OnTabSetChange;
  FTabSet.Name := 'CnEditorTabSet';

  StatusBar.OnResize := OnStatusBarResize;
  OnStatusBarResize(StatusBar);

  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet,
    [TCM_INSERTITEM, TCM_DELETEITEM, TCM_DELETEALLITEMS, CN_NOTIFY]);
end;

destructor TCnWizEdtTabSetHookComp.Destroy;
begin
  if not (csDestroying in Form.ComponentState) then
  begin
    StatusBar.OnResize := nil;
  {$IFDEF COMPILER6_UP}
    IDETabSet.Visible := True;
  {$ELSE}
    StatusBar.Panels.Delete(StatusBar.Panels.Count - 1);
    StatusBar.Parent := Form;
    StatusBar.Height := FSaveHeight;
  {$ENDIF}
  end;

  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  
  FList.Free;
  inherited;
end;

procedure TCnWizEdtTabSetHookComp.UpdateHook;
var
  pnlForm: TPanel;
  WizForm: TCnWizEdtTabSetForm;
  i: Integer;

  function HasClassInstance(AClass: TClass): Boolean;
  var
    i: Integer;
  begin
    for i := 0 to FList.Count - 1 do
      if TObject(FList[i]) is AClass then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;
begin
  Assert(Hook <> nil);
  if csDestroying in ComponentState then Exit;

  // 创建新的页面
  for i := 0 to Hook.FClasses.Count - 1 do
    if not HasClassInstance(TClass(Hook.FClasses[i])) then
    begin
      pnlForm := TPanel.Create(Self);
      pnlForm.Align := alClient;
      pnlForm.BevelInner := bvNone;
      pnlForm.BevelOuter := bvNone;
      pnlForm.Caption := '';
      pnlForm.Visible := False;
      pnlForm.Parent := EditControl.Parent;
      WizForm := TCnWizEdtTabSetFormClass(Hook.FClasses[i]).Create(Self);
      WizForm.Align := alClient;
      WizForm.Parent := pnlForm;
      WizForm.Show;
      FList.Add(WizForm);
    end;

  // 删除旧的页面
  for i := FList.Count - 1 downto 0 do
    if Hook.FClasses.IndexOf(TObject(FList[i]).ClassType) < 0 then
    begin
      WizForm := TCnWizEdtTabSetForm(FList[i]);
      pnlForm := TPanel(WizForm.Parent);
      WizForm.Free;
      pnlForm.Free;
      FList.Delete(i);
    end;

  // 更新 TabSet 标签
  UpdateTabSet;
end;

procedure TCnWizEdtTabSetHookComp.UpdateTabSet;
var
  View: IOTAEditView;
  i: Integer;
begin
  if (FChanging) or (csDestroying in ComponentState) then Exit;
  FChanging := True;
  try
  {$IFDEF COMPILER6_UP}
    if (IDETabSet.TabIndex >= 0) and (IDETabSet.TabIndex < TabSet.Tabs.Count) then
      TabSet.TabIndex := IDETabSet.TabIndex;
    TabSet.Tabs.Clear;
    for i := 0 to IDETabSet.Tabs.Count - 1 do
      TabSet.Tabs.AddObject(IDETabSet.Tabs[i], nil);
  {$ELSE}
    if TabSet.Tabs.Count > 0 then
      TabSet.TabIndex := 0;
    TabSet.Tabs.Clear;
    TabSet.Tabs.AddObject(csTabCodeCaption, nil);
  {$ENDIF}

    // todo: 此处应该取得当前 EditWindow 对应的 EditView
    View := CnOtaGetTopMostEditView;
    if View <> nil then
      for i := 0 to FList.Count - 1 do
        with TCnWizEdtTabSetForm(FList[i]) do
          if IsTabVisible(View.Buffer, View) then
            TabSet.Tabs.AddObject(GetTabCaption, FList[i]);

  {$IFDEF COMPILER6_UP}
    if (IDETabSet.TabIndex >= 0) and (IDETabSet.TabIndex < TabSet.Tabs.Count) then
      TabSet.TabIndex := IDETabSet.TabIndex
    else
      TabSet.TabIndex := 0;
  {$ELSE}
    TabSet.TabIndex := 0;
  {$ENDIF}
  finally
    FChanging := False;
  end;
end;

procedure TCnWizEdtTabSetHookComp.OnStatusBarResize(Sender: TObject);
var
  R: TRect;
begin
{$IFDEF COMPILER5}
  StatusBar.Height := csStatusBarHeight;
  // todo: 显示状态栏右边的ReSize块
{$ENDIF}
  StatusBar.Perform(SB_GETRECT, StatusBar.Panels.Count - 1, Integer(@R));
  TabSet.Parent.SetBounds(R.Left + 1, R.Top + 1, R.Right - R.Left - 2,
    R.Bottom - R.Top - 2);
  TabSet.SetBounds(0, -2, TabSet.Parent.Width, TabSet.Parent.Height + 2);
  TabSet.Invalidate;
end;

procedure TCnWizEdtTabSetHookComp.OnTabSetChange(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
var
  i: Integer;
  NewCtrl: TCnWizEdtTabSetForm;
  View: IOTAEditView;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TCnWizEdtTabSetForm(FList[i]).Parent.Visible then
    begin
      TCnWizEdtTabSetForm(FList[i]).DoTabHide;
      TCnWizEdtTabSetForm(FList[i]).Parent.Visible := False;
    end;
  end;

  if NewTab < 0 then
    NewTab := 0;

  if (TabSet.Tabs.Count > 0) and (TabSet.Tabs.Objects[NewTab] <> nil) then
  begin
    NewCtrl := TCnWizEdtTabSetForm(TabSet.Tabs.Objects[NewTab]);
    NewCtrl.Parent.Visible := True;
    NewCtrl.Parent.BringToFront;
    View := CnOtaGetTopMostEditView;
    if (View <> nil) and (View.GetEditWindow <> nil) and
      (View.GetEditWindow.Form = TabSet.Owner) then
      NewCtrl.DoTabShow(View.GetBuffer, View);
  end
  else
  begin
  {$IFDEF COMPILER6_UP}
    if TabSet.Tabs.Count > 0 then
      NewTab := IDETabSet.Tabs.IndexOf(TabSet.Tabs[NewTab])
    else
      NewTab := 0;
    if (NewTab < 0) or (NewTab > IDETabSet.Tabs.Count - 1) then
      NewTab := 0;
    IDETabSet.TabIndex := NewTab;
  {$ELSE}
    EditControl.Parent.Visible := True;
    EditControl.Parent.BringToFront;
  {$ENDIF}
  end;
end;

procedure TCnWizEdtTabSetHookComp.DoUpdateTabSet(Sender: TObject);
begin
  UpdateTabSet;
end;

procedure TCnWizEdtTabSetHookComp.OnCallWndProcRet(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
begin
  if (Control = FTabControl) and ((Msg.Msg = TCM_INSERTITEM) or
    (Msg.Msg = TCM_DELETEITEM) or (Msg.Msg = TCM_DELETEALLITEMS) or
    (Msg.Msg = CN_NOTIFY) and (TWMNotify(Msg).NMHdr^.code = TCN_SELCHANGE)) then
  begin
    CnWizNotifierServices.ExecuteOnApplicationIdle(DoUpdateTabSet);
  end;
end;

{ TCnWizEdtTabSetHook }

constructor TCnWizEdtTabSetHook.Create;
begin
  inherited;
  FClasses := TList.Create;
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChange);
end;

destructor TCnWizEdtTabSetHook.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChange);
  Unhook;
  FClasses.Free;
  inherited;
end;

procedure TCnWizEdtTabSetHook.UpdateHook;
var
  i: Integer;

  procedure DoHookEditorForm(AForm: TForm);
  var
    Comp: TCnWizEdtTabSetHookComp;
  begin
    Comp := TCnWizEdtTabSetHookComp(FindComponentByClass(AForm,
      TCnWizEdtTabSetHookComp));
    if Comp = nil then
    begin
      Comp := TCnWizEdtTabSetHookComp.Create(AForm);
      Comp.FHook := Self;
    end;

    Comp.UpdateHook;
  end;
begin
  if FClasses.Count > 0 then
    for i := 0 to Screen.FormCount - 1 do
      if IsIdeEditorForm(Screen.Forms[i]) then
        DoHookEditorForm(Screen.Forms[i]);
end;

procedure TCnWizEdtTabSetHook.Unhook;
var
  i: Integer;

  procedure DoUnhookEditorForm(AForm: TForm);
  var
    Comp: TCnWizEdtTabSetHookComp;
  begin
    Comp := TCnWizEdtTabSetHookComp(FindComponentByClass(AForm,
      TCnWizEdtTabSetHookComp));
    if Comp <> nil then
      Comp.Free;
  end;
begin
  for i := 0 to Screen.FormCount - 1 do
    if IsIdeEditorForm(Screen.Forms[i]) then
      DoUnhookEditorForm(Screen.Forms[i]);
end;

procedure TCnWizEdtTabSetHook.OnActiveFormChange(Sender: TObject);
begin
  UpdateHook;
end;

procedure TCnWizEdtTabSetHook.AddEditPage(AClass: TCnWizEdtTabSetFormClass);
begin
  if FClasses.IndexOf(AClass) < 0 then
  begin
    FClasses.Add(AClass);
    UpdateHook;
  end;
end;

procedure TCnWizEdtTabSetHook.RemoveEditPage(AClass: TCnWizEdtTabSetFormClass);
begin
  if FClasses.IndexOf(AClass) >= 0 then
  begin
    FClasses.Delete(FClasses.IndexOf(AClass));
    if FClasses.Count = 0 then
      Unhook
    else
      UpdateHook;
  end;
end;

initialization

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnEditorTabSetHook finalization.');
{$ENDIF}

  if FEditorTabSetHook <> nil then
    FEditorTabSetHook.Free;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnEditorTabSetHook finalization.');
{$ENDIF}
end.
