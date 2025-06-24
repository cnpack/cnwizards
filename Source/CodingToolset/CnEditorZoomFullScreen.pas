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

unit CnEditorZoomFullScreen;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码窗口全屏幕切换工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2008.05.08 V1.3
*               增加对 BDS 的支持
*           2005.02.22 V1.2
*               增加代码窗口最大化时自动隐藏主窗口的功能
*           2003.03.06 V1.1
*               IDE 启动后代码窗口最大化
*           2002.12.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, ToolsAPI, CnWizIdeUtils, CnConsts, CnCommon,
  CnWizConsts, CnCodingToolsetWizard, CnWizUtils, CnWizMultiLang;

type
  TCnEditorZoomFullScreenForm = class(TCnTranslateForm)
    GroupBox1: TGroupBox;
    cbAutoZoom: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    chkAutoHideMainForm: TCheckBox;
    chkRestoreNormal: TCheckBox;
  private

  public

  end;

//==============================================================================
// 代码窗口全屏幕切换工具类
//==============================================================================

{ TCnEditorZoomFullScreen }

  TCnEditorZoomFullScreen = class(TCnBaseCodingToolset)
  private
    // Save main IDE top
    MainIDETop: Integer;
    FTimer: TTimer;
    FUpdating: Boolean;
    FAutoZoom: Boolean;
    FAutoHideMainForm: Boolean;
    FLastAutoHideMainForm: Boolean;
    FRestoreNormal: Boolean;
    FStayedTop: Boolean;
    procedure AdjustEditorForm(FullScreen: Boolean);
    procedure SetAutoHideMainForm(const Value: Boolean);
    procedure UpdateAutoHide;
    procedure UpdateMainFormPos(AShow: Boolean);
    function CheckMousePos(var AMouseEnter: Boolean): Boolean;
    procedure OnTimer(Sender: TObject);
    function GetFullScreen: Boolean;
    procedure SetFullScreen(const Value: Boolean);
  protected
    function GetHasConfig: Boolean; override;
    function NeedAutoHide: Boolean;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    function GetState: TWizardState; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Loaded; override;
    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Config; override;

    property FullScreen: Boolean read GetFullScreen write SetFullScreen;
  published
    property AutoZoom: Boolean read FAutoZoom write FAutoZoom default False;
    property AutoHideMainForm: Boolean read FAutoHideMainForm write SetAutoHideMainForm default True;
    property RestoreNormal: Boolean read FRestoreNormal write FRestoreNormal default False;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

//==============================================================================
// 代码窗口全屏幕切换工具类
//==============================================================================

{ TCnEditorZoomFullScreen }

const
  csZoomFullScreen = 'ZoomFullScreen';
  csBarWidth = 4;

constructor TCnEditorZoomFullScreen.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FAutoZoom := False;
  FRestoreNormal := False;
  FUpdating := False;
  FLastAutoHideMainForm := False;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 200;
  FTimer.OnTimer := OnTimer;
  // 手工触发内部的改变
  AutoHideMainForm := True;
end;

destructor TCnEditorZoomFullScreen.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TCnEditorZoomFullScreen.AdjustEditorForm(FullScreen: Boolean);
var
  EditorForm, IdeMainForm: TCustomForm;
  IdeBottom: Integer;
  i: Integer;
begin
  EditorForm := nil;
  for i := 0 to Screen.CustomFormCount - 1 do
  begin
    if (Screen.CustomForms[i].Parent = nil) and IsIdeEditorForm(Screen.CustomForms[i]) then
    begin
      EditorForm := Screen.CustomForms[i];
      if EditorForm.WindowState = wsNormal then // 未最大化时直接最大化
        EditorForm.WindowState := wsMaximized
      else
      begin
        if FullScreen then              // 全屏方式下直接设置为工作区域
          with GetWorkRect do
            SetWindowPos(EditorForm.Handle, HWND_TOP, Left, Top, Right - Left,
              Bottom - Top, SWP_SHOWWINDOW)
        else
        begin
          if RestoreNormal then
            EditorForm.WindowState := wsNormal
          else
          begin
            IdeMainForm := GetIDEMainForm;
            if Assigned(IdeMainForm) then     // 找到 IDE 主窗口时设置在主窗口下方
            begin
              IdeBottom := IdeMainForm.Top + IdeMainForm.Height;
              with GetWorkRect do
                SetWindowPos(EditorForm.Handle, HWND_TOP, Left, IdeBottom,
                Right - Left, Bottom - IdeBottom, SWP_SHOWWINDOW);
            end
            else
            begin                         // 没办法，只好先常规化再最大化
              EditorForm.WindowState := wsNormal;
              EditorForm.WindowState := wsMaximized;
            end;
          end;
        end;
      end;
      Exit;
    end;
  end;

  if EditorForm = nil then
    ErrorDlg(SCnEditorZoomFullScreenNoEditor);
end;

procedure TCnEditorZoomFullScreen.Execute;
begin
  FullScreen := not FullScreen;
  UpdateAutoHide;
  AdjustEditorForm(FullScreen);
end;

procedure TCnEditorZoomFullScreen.Loaded;
begin
  if Active and FAutoZoom then
  begin
    AdjustEditorForm(FullScreen);
  end;
end;

function TCnEditorZoomFullScreen.GetFullScreen: Boolean;
var
  Options: IOTAEnvironmentOptions;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Assigned(Options) then
    Result := Options.GetOptionValue(csZoomFullScreen)
  else
    Result := False;
end;

procedure TCnEditorZoomFullScreen.SetFullScreen(const Value: Boolean);
var
  Options: IOTAEnvironmentOptions;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Assigned(Options) then
    Options.SetOptionValue(csZoomFullScreen, Value);
end;

function TCnEditorZoomFullScreen.GetCaption: string;
begin
  Result := SCnEditorZoomFullScreenMenuCaption;
end;

function TCnEditorZoomFullScreen.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnEditorZoomFullScreen.GetHint: string;
begin
  Result := SCnEditorZoomFullScreenMenuHint;
end;

procedure TCnEditorZoomFullScreen.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorZoomFullScreen;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

function TCnEditorZoomFullScreen.GetState: TWizardState;
begin
  Result := [];

  if Active and (wsEnabled in inherited GetState) then
    Include(Result, wsEnabled);

  if FullScreen then
    Include(Result, wsChecked);
end;

//------------------------------------------------------------------------------
// 主窗体自动隐藏
//------------------------------------------------------------------------------

function TCnEditorZoomFullScreen.NeedAutoHide: Boolean;
var
  IdeMainForm: TCustomForm;

  function IsEditorMaximized: Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to Screen.CustomFormCount - 1 do
      if IsIdeEditorForm(Screen.CustomForms[i]) then
      begin
        Result := (Screen.CustomForms[i].WindowState = wsMaximized)
          and (Screen.CustomForms[i].Top <= 0);
        // 最大化的判断，不光是WindowState，也要窗体Top到位才行。
        if Result then // 只要找到有一个最大化的 Edit 窗口就退出
          Exit;
      end;
  end;

begin
  IdeMainForm := GetIDEMainForm;
  // 代码窗口全屏最大化且主窗口没有最大化时才自动隐藏
  Result := Active and FAutoHideMainForm and Assigned(IdeMainForm) and
    (IdeMainForm.WindowState = wsNormal) and FullScreen and IsEditorMaximized;
end;

procedure TCnEditorZoomFullScreen.SetAutoHideMainForm(
  const Value: Boolean);
begin
  FAutoHideMainForm := Value;
  FTimer.Enabled := Value;
  UpdateAutoHide;
end;

procedure TCnEditorZoomFullScreen.OnTimer(Sender: TObject);
begin
  UpdateAutoHide;
end;

function TCnEditorZoomFullScreen.CheckMousePos(var AMouseEnter: Boolean):
  Boolean;
var
  MousePos: TPoint;
  IdeMainForm: TCustomForm;
begin
  Result := False;
  if GetCursorPos(MousePos) then
  begin
    IdeMainForm := GetIDEMainForm;
    if Assigned(IdeMainForm) then
    begin
      with IdeMainForm do
        AMouseEnter := PtInRect(Bounds(Left, Top - MainIDETop, Width, Height + MainIDETop), MousePos) or
          (Top = -Height) and PtInRect(Bounds(Left, 0, Width, csBarWidth), MousePos);
      Result := GetShiftState * [ssLeft, ssRight, ssMiddle, ssDouble] = [];
{$IFDEF DEBUG}
      if MousePos.Y = 0 then // 鼠标在最顶
      begin
        CnDebugger.LogBoolean(AMouseEnter, 'FullScreen: Mouse enter');
        with IdeMainForm do
        begin
          CnDebugger.LogRect(Bounds(Left, Top - MainIDETop, Width, Height + MainIDETop), 'FullScreen Rect1');
          CnDebugger.LogRect(Bounds(Left, 0, Width, csBarWidth), 'FullScreen Rect2');
        end;
      end;
{$ENDIF}
    end;
  end;
end;

procedure TCnEditorZoomFullScreen.UpdateAutoHide;
var
  MouseEnter: Boolean;
  IdeMainForm: TCustomForm;
begin
  IdeMainForm := GetIDEMainForm;
  if NeedAutoHide then
  begin
    if not FLastAutoHideMainForm then
    begin
      FLastAutoHideMainForm := True;
      UpdateMainFormPos(False);
      if Assigned(IdeMainForm) then
      begin
        StayOnTop(IdeMainForm.Handle, True);
        FStayedTop := True;
      end;
    end
    else
    begin
      if CheckMousePos(MouseEnter) then
      begin
        if not Application.Active or not MouseEnter then
          UpdateMainFormPos(False)
        else if not ScreenHasModalForm then
          UpdateMainFormPos(True);
      end;
    end;
  end
  else if FLastAutoHideMainForm then
  begin
    FLastAutoHideMainForm := False;
    UpdateMainFormPos(True);
    if Assigned(IdeMainForm) then
    begin
      StayOnTop(IdeMainForm.Handle, False);
      FStayedTop := False;
    end;
  end;
end;

procedure TCnEditorZoomFullScreen.UpdateMainFormPos(AShow: Boolean);
var
  WorkRect: TRect;
  IdeMainForm: TCustomForm;
begin
  if FUpdating then
    Exit;

  FUpdating := True;
  try
    IdeMainForm := GetIDEMainForm;
    if Assigned(IdeMainForm) then
    begin
      if IdeMainForm.WindowState = wsNormal then
      begin
        WorkRect := GetWorkRect;
        if IdeMainForm.Left <> WorkRect.Left then
          IdeMainForm.Left := WorkRect.Left;
        if IdeMainForm.Width <> WorkRect.Right - WorkRect.Left then
          IdeMainForm.Width := WorkRect.Right - WorkRect.Left;

        if AShow then
        begin
          if IdeMainForm.Top <> 0 then
          begin
            // 修正由于其他原因导致 MainIDETop 小于0而弹不出主窗体的情况
            if MainIDETop < 0 then
              MainIDETop := 0;
              
            IdeMainForm.Top := MainIDETop;
            IdeMainForm.BringToFront;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('FullScreen. Main IDE Popup.');
{$ENDIF}
            if not FStayedTop then
            begin
              StayOnTop(IdeMainForm.Handle, True);
{$IFDEF BDS}
              (IdeMainForm as TForm).FormStyle := fsStayOnTop;
{$ENDIF}

{$IFDEF DEBUG}
              CnDebugger.LogMsg('FullScreen. Main IDE SetWindowPos to Top.');
{$ENDIF}
              FStayedTop := True;
            end;
          end;
        end
        else
        begin
          FStayedTop := False;
{$IFDEF BDS}
          (IdeMainForm as TForm).FormStyle := fsNormal;
{$ENDIF}
          if IdeMainForm.Top <> -IdeMainForm.Height then
          begin
            MainIDETop := IdeMainForm.Top;
            IdeMainForm.Top := -IdeMainForm.Height;
          end;
        end;
      end;
    end;
  finally
    FUpdating := False;
  end;
end;

//------------------------------------------------------------------------------
// 设置相关
//------------------------------------------------------------------------------

procedure TCnEditorZoomFullScreen.Config;
begin
  with TCnEditorZoomFullScreenForm.Create(nil) do
  try
    cbAutoZoom.Checked := FAutoZoom;
    chkAutoHideMainForm.Checked := FAutoHideMainForm;
    chkRestoreNormal.Checked := FRestoreNormal;

    if ShowModal = mrOk then
    begin
      AutoZoom := cbAutoZoom.Checked;
      AutoHideMainForm := chkAutoHideMainForm.Checked;
      RestoreNormal := chkRestoreNormal.Checked;
    end;
  finally
    Free;
  end;
end;

function TCnEditorZoomFullScreen.GetHasConfig: Boolean;
begin
  Result := True;
end;

initialization
  RegisterCnCodingToolset(TCnEditorZoomFullScreen); // 注册工具

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
