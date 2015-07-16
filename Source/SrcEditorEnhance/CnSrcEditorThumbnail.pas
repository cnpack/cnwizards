{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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

unit CnSrcEditorThumbnail;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展预览缩略图实现单元
* 单元作者：刘啸 (liuxiuao@cnpack.org)
* 备    注：
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.07.16
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  IniFiles, Forms, ExtCtrls, Menus, StdCtrls, CnCommon,
  CnWizUtils, CnWizIdeUtils, CnWizNotifier, CnEditControlWrapper, CnWizClasses;

const
  WM_NCMOUSELEAVE       = $02A2;

type
  TCnSrcEditorThumbnail = class;

  TCnSrcThumbnailForm = class(TCustomMemo)
  private
    FMouseIn: Boolean;
    FThumbnail: TCnSrcEditorThumbnail;
    FPopup: TPopupMenu;
    FTopLine: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;

    procedure MouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure MouseDblClick(var Msg: TWMMouse); message WM_LBUTTONDBLCLK;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetPos(X, Y: Integer);
    procedure SetTopLine(const Value: Integer; UseRelative: Boolean);

    property Thumbnail: TCnSrcEditorThumbnail read FThumbnail write FThumbnail;
    property TopLine: Integer read FTopLine; // 显示的顶行行号，0 开始
  end;

//==============================================================================
// 代码编辑器扩展缩略图功能
//==============================================================================

{ TCnSrcEditorThumbnail }

  TCnSrcEditorThumbnail = class(TObject)
  private
    FActive: Boolean;
    FThumbForm: TCnSrcThumbnailForm;
    // FThumbMemo: TMemo;
    FInScroll: Boolean;
    FEditControl: TWinControl;
    FPoint: TPoint; // 根据这儿存储的鼠标位置来显示窗体，x、y 是 FEditControl 内的坐标
    FShowTimer: TTimer;
    FHideTimer: TTimer;
    FShowThumbnail: Boolean;
    procedure EditControlMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure EditControlMouseLeave(Editor: TEditorObject; IsNC: Boolean);

    procedure OnShowTimer(Sender: TObject);
    procedure OnHideTimer(Sender: TObject);

    procedure CheckCreateForm;
    procedure UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
    procedure SetShowThumbnail(const Value: Boolean);
    // 加载内容、设置缩略图窗口的位置滚动点、显示缩略图窗口

    procedure CheckNotifiers;
  protected
    procedure SetActive(Value: Boolean);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property Active: Boolean read FActive write SetActive;
    property ShowThumbnail: Boolean read FShowThumbnail write SetShowThumbnail;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug;
{$ENDIF}

const
  SHOW_INTERVAL = 1000;

  CS_DROPSHADOW = $20000;

  csThumbnail = 'Thumbnail';                   
  csShowThumbnail = 'ShowThumbnail';

//==============================================================================
// 代码编辑器扩展缩略图
//==============================================================================

{ TCnSrcEditorThumbnail }

procedure TCnSrcEditorThumbnail.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  if (Msg.message = WM_MOUSEWHEEL) and FThumbForm.Visible then
  begin
    SendMessage(FThumbForm.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
    Handled := True;
  end
  else if FThumbForm.Visible and (Msg.hwnd = FThumbForm.Handle) and
   (Msg.message > WM_MOUSEFIRST) and (Msg.message < WM_MOUSELAST) then
  begin
    // 屏蔽除 MOUSEMOVE 与 MOUSEWHEEL 之外的一切鼠标消息
    // 但双击还是处理为跳转
    if Msg.message = WM_LBUTTONDBLCLK then
      SendMessage(FThumbForm.Handle, WM_LBUTTONDBLCLK, Msg.wParam, Msg.lParam);
    Handled := True;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckCreateForm;
var
  AFont: TFont;
  Canvas: TControlCanvas;
begin
  if FThumbForm = nil then
  begin
    FThumbForm := TCnSrcThumbnailForm.Create(nil);
    FThumbForm.Thumbnail := Self;
    FThumbForm.DoubleBuffered := True;
    FThumbForm.ReadOnly := True;
    FThumbForm.Parent := Application.MainForm;
    FThumbForm.Visible := False;
    FThumbForm.BorderStyle := bsSingle;
    FThumbForm.Color := clInfoBk;
    FThumbForm.Width := 500;
    FThumbForm.Height := 200;
    // FThumbForm.ScrollBars := ssVertical;

    AFont := TFont.Create;
    AFont.Name := 'Courier New';  {Do NOT Localize}
    AFont.Size := 10;

    GetIDERegistryFont('', AFont);
    FThumbForm.Font := AFont;
    Canvas := TControlCanvas.Create;
    Canvas.Control := FThumbForm;
    Canvas.Font := AFont;
    FThumbForm.Width := Canvas.TextWidth(Spc(82));
    Canvas.Free;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckNotifiers;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceCurrentStack;
  CnDebugger.TraceBoolean(Active);
  CnDebugger.TraceBoolean(ShowThumbnail);
{$ENDIF}
  if Active and ShowThumbnail then
  begin
    EditControlWrapper.AddEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.AddEditorMouseLeaveNotifier(EditControlMouseLeave);
  end
  else
  begin
    EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);
  end;
end;

constructor TCnSrcEditorThumbnail.Create;
begin
  inherited;
  // FShowThumbnail := True;

  FShowTimer := TTimer.Create(nil);
  FShowTimer.Enabled := False;
  FShowTimer.Interval := SHOW_INTERVAL;
  FShowTimer.OnTimer := OnShowTimer;

  FHideTimer := TTimer.Create(nil);
  FHideTimer.Enabled := False;
  FHideTimer.Interval := SHOW_INTERVAL;
  FHideTimer.OnTimer := OnHideTimer;

  CheckCreateForm;
  CheckNotifiers;
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
end;

destructor TCnSrcEditorThumbnail.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
  EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);

  FHideTimer.Free;
  FShowTimer.Free;

  FThumbForm.Free;
  inherited;
end;

procedure TCnSrcEditorThumbnail.EditControlMouseLeave(
  Editor: TEditorObject; IsNC: Boolean);
begin
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;
{$IFDEF DEBUG}
  CnDebugger.TraceFmt('MouseLeave. Is from NC: %d', [Integer(IsNc)]);
{$ENDIF}

  FInScroll := False;
  FShowTimer.Enabled := False; // 离开了的话，准备显示的就停了
  FHideTimer.Enabled := True;  // 准备隐藏
end;

procedure TCnSrcEditorThumbnail.EditControlMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  InRightScroll: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d. Is in NC: %d', [X, Y, Integer(IsNc)]);
{$ENDIF}
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;

  // 判断当前是否在需要显示缩略图的区域里。逻辑为：X 大于 ClientWidth 并且 IsNC
  InRightScroll := (IsNC and (X >= Editor.EditControl.ClientWidth));
  FEditControl := TWinControl(Editor.EditControl);

  CheckCreateForm;
  if not FInScroll and InRightScroll then // 第一次进入了滚动条区
  begin
    // 只有第一次进入了滚动条区，才要求捕获 MouseLeave
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll.');
{$ENDIF}
    FPoint.x := X;
    FPoint.y := Y;
    if not FThumbForm.Visible then
    begin
      // 第一次进，才启动显示 Thumbnail Form 的定时器
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll. enable timer');
{$ENDIF}
      FShowTimer.Enabled := True;
    end
    else
    begin
      // 调整已显示的 Thumbnail 的位置并更新内容位置
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('First enter scroll. Update position');
{$ENDIF}
      UpdateThumbnailForm(False, False);
    end;
  end
  else if InRightScroll then
  begin
    FPoint.x := X;
    FPoint.y := Y;
    // 在内部，并且已经显示 Thumbnail 了，则立即更新内容
    if FThumbForm.Visible then
    begin
      FHideTimer.Enabled := False;
      UpdateThumbnailForm(False, True);
    end;
  end;

  FInScroll := InRightScroll;
end;

procedure TCnSrcEditorThumbnail.LanguageChanged(Sender: TObject);
begin

end;

procedure TCnSrcEditorThumbnail.LoadSettings(Ini: TCustomIniFile);
begin
  ShowThumbnail := Ini.ReadBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.OnHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  if FThumbForm <> nil then
    FThumbForm.Hide;
end;

procedure TCnSrcEditorThumbnail.OnShowTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('OnShowTimer');
{$ENDIF}
  FShowTimer.Enabled := False;
  UpdateThumbnailForm(True, False);
end;

procedure TCnSrcEditorThumbnail.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnSrcEditorThumbnail.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.SetActive(Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    CheckNotifiers;

    if not FActive then
      if FThumbForm <> nil then
        FThumbForm.Hide;
  end;
end;

procedure TCnSrcEditorThumbnail.SetShowThumbnail(const Value: Boolean);
begin
  if FShowThumbnail <> Value then
  begin
    FShowThumbnail := Value;
    CheckNotifiers;

    if FThumbForm <> nil then
      FreeAndNil(FThumbForm);
  end;
end;

procedure TCnSrcEditorThumbnail.UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
var
  P: TPoint;
  ThisLine: Integer;
begin
  CheckCreateForm;

  // 加载内容、设置缩略图窗口的位置滚动点、显示缩略图窗口
  if IsShow or (FThumbForm.Lines.Text = '') then
    FThumbForm.Lines.Text := CnOtaGetCurrentEditorSource;

  // FPoint 是要弹出时的 FEditControl 内的鼠标位置 ，以此为准设置窗口位置
  P := FPoint;
  P.x := FEditControl.Width;
  P := FEditControl.ClientToScreen(P);

  P.x := P.x - FThumbForm.Width - 20;
  P.y := P.y - FThumbForm.Height div 2;

  // 避免超出屏幕
  if P.x < 0 then
    P.x := 0;
  if P.y < 0 then
    P.y := 0;

  if P.x + FThumbForm.Width > Screen.Width then
    P.x := Screen.Width - FThumbForm.Width;
  if P.y + FThumbForm.Height > Screen.Height then
    P.y := Screen.Height - FThumbForm.Height;

  FThumbForm.SetPos(P.x, P.y) ;

  // 根据位置滚动行
  ThisLine := FThumbForm.Lines.Count * FPoint.y div FEditControl.ClientHeight;
  FThumbForm.SetTopLine(ThisLine, UseRelative);

  if IsShow then
    FThumbForm.Visible := True;
end;

{ TCnSrcThumbnailForm }

constructor TCnSrcThumbnailForm.Create(AOwner: TComponent);
begin
  inherited;
  FPopup := TPopupMenu.Create(Self);
  PopupMenu := FPopup;  // 取代并屏蔽自带的右键菜单
end;

procedure TCnSrcThumbnailForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW {or WS_SIZEBOX} or WS_MAXIMIZEBOX
    or WS_BORDER;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnSrcThumbnailForm.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);

  SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN, 5);
  SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN, 5);
end;

destructor TCnSrcThumbnailForm.Destroy;
begin
  inherited;

end;

procedure TCnSrcThumbnailForm.MouseDblClick(var Msg: TWMMouse);
var
  View: IOTAEditView;
  P: TOTAEditPos;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Dblclick');
{$ENDIF}

  // 去 TopLine 所标识的地方
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    P.Col := 1;
    P.Line := TopLine + 1; // 0 开始变成 1 开始
    CnOtaGotoEditPos(P, View, True);
  end;

  Hide;
end;

procedure TCnSrcThumbnailForm.MouseLeave(var Msg: TMessage);
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Hover');
{$ENDIF}

  FMouseIn := False;
  FThumbnail.FHideTimer.Enabled := True;
end;

procedure TCnSrcThumbnailForm.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Tme: TTrackMouseEvent;
begin
  inherited;
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Move');
{$ENDIF}
  if not FMouseIn then
  begin
    Tme.cbSize := SizeOf(TTrackMouseEvent);
    Tme.dwFlags := TME_LEAVE;
    Tme.hwndTrack := Handle;
    TrackMouseEvent(Tme);
  end;

  FMouseIn := True;
  FThumbnail.FHideTimer.Enabled := False;
end;

procedure TCnSrcThumbnailForm.MouseWheel(var Msg: TWMMouseWheel);
var
  NewLine: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.TraceMsg('FThumbmail Mouse Wheel ' + IntToStr(Msg.WheelDelta));
{$ENDIF}
  if Msg.WheelDelta > 0 then
    NewLine := TopLine - Mouse.WheelScrollLines
  else
    NewLine := TopLine + Mouse.WheelScrollLines;

  if NewLine < 0 then
    NewLine := 0;
  if NewLine > Lines.Count then
    NewLine := Lines.Count;

  SetTopLine(NewLine, True);
end;

procedure TCnSrcThumbnailForm.SetPos(X, Y: Integer);
begin
  SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure TCnSrcThumbnailForm.SetTopLine(const Value: Integer; UseRelative: Boolean);
begin
  if FTopLine <> Value then
  begin
    if UseRelative then
      SendMessage(Handle, EM_LINESCROLL, 0, Value - FTopLine)
    else
    begin
      SendMessage(Handle, EM_LINESCROLL, 0, -Lines.Count);
      SendMessage(Handle, EM_LINESCROLL, 0, Value);
    end;
    FTopLine := Value;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.


