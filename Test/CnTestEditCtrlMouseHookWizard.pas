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

unit CnTestEditCtrlMouseHookWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试编辑器控件的鼠标动作挂接单元
* 单元作者：CnPack 开发组
* 备    注：挂接 MouseDown/Up/Move 方法并支持分发
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.07.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnEventHook, CnCommon, CnWizClasses, CnWizUtils,
  CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// 测试挂接 EditControl 鼠标事件的菜单专家
//==============================================================================

{ TCnTestEditCtrlMouseHookWizard }

  TCnTestEditCtrlMouseHookWizard = class(TCnMenuWizard)
  private
    FInScrollBar: Boolean;
    FScrollBarWidthGot: Boolean;
    FScrollBarLeft: Integer;
    FScrollbarRight: Integer;
    procedure HookMouseUp(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure HookMouseDown(Editor: TEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure HookMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure HookMouseLeave(Editor: TEditorObject; IsNC: Boolean);
    procedure OnNcPaint(Editor: TEditorObject);
    procedure OnVScroll(Editor: TEditorObject);

    procedure SetInScrollBar(const Value: Boolean);
    procedure DrawNc(Edit: TWinControl);
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    property InScrollBar: Boolean read FInScrollBar write SetInScrollBar;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 测试挂接 EditControl 鼠标事件的菜单专家
//==============================================================================

{ TCnTestEditCtrlMouseHookWizard }

procedure TCnTestEditCtrlMouseHookWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditCtrlMouseHookWizard.Create;
begin
  inherited;

end;

destructor TCnTestEditCtrlMouseHookWizard.Destroy;
begin
  EditControlWrapper.RemoveEditorMouseDownNotifier(HookMouseDown);
  EditControlWrapper.RemoveEditorMouseUpNotifier(HookMouseUp);
  EditControlWrapper.RemoveEditorMouseMoveNotifier(HookMouseMove);
  EditControlWrapper.RemoveEditorMouseLeaveNotifier(HookMouseLeave);

  EditControlWrapper.RemoveEditorNcPaintNotifier(OnNcPaint);
  EditControlWrapper.RemoveEditorVScrollNotifier(OnVScroll);
  inherited;
end;

procedure TCnTestEditCtrlMouseHookWizard.DrawNc(Edit: TWinControl);
var
  Canvas: TCanvas;
  Handle: THandle;
  ScrollWidth: Integer;
begin
  Canvas := TCanvas.Create;
  Handle := Edit.Handle;

  try
    Canvas.Handle := GetWindowDC(Handle) ;
    Canvas.Pen.Color := clNavy;
    Canvas.Pen.Width := 2;
    Canvas.Brush.Color := clRed;
    Canvas.Brush.Style := bsSolid;

    ScrollWidth := Edit.Width - Edit.ClientWidth;
    CnDebugger.TraceFmt('DrawNc ScrollBar Width %d.', [ScrollWidth]);

    Canvas.Rectangle(Rect(Edit.ClientWidth, 40, Edit.Width, 80) );
  finally
    ReleaseDC(Handle, Canvas.Handle) ;
    Canvas.Free;
  end;
end;

procedure TCnTestEditCtrlMouseHookWizard.Execute;
begin
  EditControlWrapper.AddEditorMouseDownNotifier(HookMouseDown);
  EditControlWrapper.AddEditorMouseUpNotifier(HookMouseUp);
  EditControlWrapper.AddEditorMouseMoveNotifier(HookMouseMove);
  EditControlWrapper.AddEditorMouseLeaveNotifier(HookMouseLeave);

  EditControlWrapper.AddEditorNcPaintNotifier(OnNcPaint);
  EditControlWrapper.AddEditorVScrollNotifier(OnVScroll);
  InfoDlg('Mouse Event Hooked.');
end;

function TCnTestEditCtrlMouseHookWizard.GetCaption: string;
begin
  Result := 'Test EditControl Mouse Hook';
end;

function TCnTestEditCtrlMouseHookWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditCtrlMouseHookWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditCtrlMouseHookWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditCtrlMouseHookWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditCtrlMouseHookWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControl Mouse Hook Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for EditControl Mouse Hook';
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseDown(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  Tme: TTrackMouseEvent;
begin
  CnDebugger.TraceFmt('MouseDown at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
  if IsNC then
  begin
    Tme.cbSize := SizeOf(TTrackMouseEvent);
    Tme.dwFlags := TME_LEAVE;
    Tme.hwndTrack := TWinControl(Editor.EditControl).Handle;
    TrackMouseEvent(Tme);
  end;

  if (Button = mbLeft) and (ssCtrl in Shift) then
  begin
    CnDebugger.TraceMsg('Mouse Down Left Button with Ctrl Pressed.');
    if Editor.EditControl.Cursor = crHandPoint then
      CnDebugger.TraceMsg('Mouse Down with HandPoint.');
  end;
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseLeave(
  Editor: TEditorObject; IsNC: Boolean);
begin
  CnDebugger.TraceFmt('Mouse Leave Edit Control. Is from NC: %d', [Integer(IsNc)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  SBI: TScrollBarInfo;
  PL, PR: TPoint;
begin
  CnDebugger.TraceFmt('MouseMove at X %d, Y %d. Is in NC: %d', [X, Y, Integer(IsNc)]);
  if not FScrollBarWidthGot then
  begin
    FillChar(SBI, 0, SizeOf(TScrollBarInfo));
    SBI.cbSize := SizeOf(TScrollBarInfo);
    if not GetScrollBarInfo(TWinControl(Editor.EditControl).Handle, OBJID_VSCROLL, SBI) then
    begin
      CnDebugger.TraceMsg('Can NOT Get ScrollBar Info from EditControl. ' + GetLastErrorMsg(True));
      Exit;
    end;

    CnDebugger.TraceRect(SBI.rcScrollBar, 'Current EditControl ScrollBar Rect at Screen.');
    PL.x := SBI.rcScrollBar.Left;
    PL.y := 0;
    PR.x := SBI.rcScrollBar.Right;
    PR.y := 0;

    PL := Editor.EditControl.ScreenToClient(PL);
    PR := Editor.EditControl.ScreenToClient(PR);

    FScrollBarLeft := PL.x;
    FScrollbarRight := PR.x;

    CnDebugger.TraceFmt('EditControl ScrollBar Left %d, Right %d. ClientWidth %d.',
      [FScrollBarLeft, FScrollbarRight, Editor.EditControl.ClientWidth]);
    FScrollBarWidthGot := True;
  end;

  InScrollBar := FScrollBarWidthGot and (X >= FScrollBarLeft) and (X <= FScrollbarRight);
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseUp(Editor: TEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin
  CnDebugger.TraceFmt('MouseUp at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlMouseHookWizard.OnNcPaint(Editor: TEditorObject);
begin
  CnDebugger.TraceMsg('Editor NcPaint.');
  if not (Editor.EditControl is TWinControl) then
    Exit;

  DrawNc(TWinControl(Editor.EditControl));
end;

procedure TCnTestEditCtrlMouseHookWizard.OnVScroll(Editor: TEditorObject);
begin
  CnDebugger.TraceMsg('Editor VScroll.');
  if not (Editor.EditControl is TWinControl) then
    Exit;

  DrawNc(TWinControl(Editor.EditControl));
end;

procedure TCnTestEditCtrlMouseHookWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlMouseHookWizard.SetInScrollBar(
  const Value: Boolean);
begin
  if FInScrollBar <> Value then
  begin
    FInScrollBar := Value;
    CnDebugger.TraceBoolean(FInScrollBar, 'InScrollBar Changed to');
  end;
end;

initialization
  RegisterCnWizard(TCnTestEditCtrlMouseHookWizard); // 注册此测试专家

end.
