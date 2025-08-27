{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestEditCtrlMouseHookWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���ؼ�����궯���ҽӵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���ҽ� MouseDown/Up/Move ������֧�ַַ�
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.07.11 V1.0
*               ������Ԫ
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
// ���Թҽ� EditControl ����¼��Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlMouseHookWizard }

  TCnTestEditCtrlMouseHookWizard = class(TCnMenuWizard)
  private
    FInScrollBar: Boolean;
    FScrollBarWidthGot: Boolean;
    FScrollBarLeft: Integer;
    FScrollbarRight: Integer;
    procedure HookMouseUp(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure HookMouseDown(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure HookMouseMove(Editor: TCnEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure HookMouseLeave(Editor: TCnEditorObject; IsNC: Boolean);
    procedure OnNcPaint(Editor: TCnEditorObject);
    procedure OnVScroll(Editor: TCnEditorObject);

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
// ���Թҽ� EditControl ����¼��Ĳ˵�ר��
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

procedure TCnTestEditCtrlMouseHookWizard.HookMouseDown(Editor: TCnEditorObject;
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
  Editor: TCnEditorObject; IsNC: Boolean);
begin
  CnDebugger.TraceFmt('Mouse Leave Edit Control. Is from NC: %d', [Integer(IsNc)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.HookMouseMove(Editor: TCnEditorObject;
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

procedure TCnTestEditCtrlMouseHookWizard.HookMouseUp(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
begin
  CnDebugger.TraceFmt('MouseUp at X %d, Y %d. Button %d.', [X, Y, Ord(Button)]);
end;

procedure TCnTestEditCtrlMouseHookWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlMouseHookWizard.OnNcPaint(Editor: TCnEditorObject);
begin
  CnDebugger.TraceMsg('Editor NcPaint.');
  if not (Editor.EditControl is TWinControl) then
    Exit;

  DrawNc(TWinControl(Editor.EditControl));
end;

procedure TCnTestEditCtrlMouseHookWizard.OnVScroll(Editor: TCnEditorObject);
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
  RegisterCnWizard(TCnTestEditCtrlMouseHookWizard); // ע��˲���ר��

end.
