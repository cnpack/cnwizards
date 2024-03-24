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

unit CnTestDesignMsgWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestDesignMsgWizard
* 单元作者：CnPack 开发组
* 备    注：测试拦截设计器消息与方法的用例，确定结论：
*           DoDragCreate：选中控件板上的控件并在窗体上拖动来创建控件时松开鼠标后调用。
*           DoDragMove：拖动被选中控件时松开鼠标左键后调用。
*           DoDragSelect：拖动框来选中控件时松开鼠标左键后调用，不拖动时单纯点击也会调用（似乎用于取消选择）。
*           DoDragSize：拖动控件边缘改变控件大小时松开鼠标左键后调用。
*           DragTo是会在拖动过程中被调用。
* 开发平台：Windows 7 + Delphi 6/7
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2017.01.03 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizMethodHook,
  CnWizCompilerConst, CnWizNotifier {$IFDEF COMPILER6_UP}, DesignIntf,
  DesignEditors, ComponentDesigner {$ENDIF};

type

//==============================================================================
// CnTestDesignMsgWizard 菜单专家
//==============================================================================

{ TCnTestDesignMsgWizard }

  TCnTestDesignMsgWizard = class(TCnMenuWizard)
  private
    FHook: TCnMethodHook;
    FDesignIdeModule: HMODULE;
    procedure InitRoutines;
    procedure ActiveFormChanged(Sender: TObject);
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
  end;

implementation

uses
  CnDebug;

const
  STDesignerDoDragCreate = '@Designer@TDesigner@DoDragCreate$qqrv';
  STDesignerDoDragMove = '@Designer@TDesigner@DoDragMove$qqrv';
  STDesignerDoDragSelect = '@Designer@TDesigner@DoDragSelect$qqrv';
  STDesignerDoDragSize = '@Designer@TDesigner@DoDragSize$qqrv';

  STDesignerDragBoxesMoveTo = '@Designer@TDesigner@DragBoxesMoveTo$qqrrx11Types@TRect';

  STDesignerDragBegin = '@Designer@TDesigner@DragBegin$qqrii';
  STDesignerDragEnd = '@Designer@TDesigner@DragEnd$qqriio';
  STDesignerDragBoxesOn = '@Designer@TDesigner@DragBoxesOn$qqrv';
  STDesignerDragBoxesOff = '@Designer@TDesigner@DragBoxesOff$qqrv';
  STDesignerDragTo = '@Designer@TDesigner@DragTo$qqrii';

type
  TControlHack = class(TControl);

  TDesignerDoDragCreate = procedure(Self: TObject);
  TDesignerDoDragMove = procedure(Self: TObject);
  TDesignerDoDragSelect = procedure(Self: TObject);
  TDesignerDoDragSize = procedure(Self: TObject);
  TDesignerDragBoxesMoveTo = procedure(Self: TObject; ARect: PRect);

  TDesignerDragBegin = procedure(Self: TObject; X, Y: Integer);
  TDesignerDragEnd = procedure(Self: TObject; X, Y: Integer; Arg: Boolean);
  TDesignerDragBoxesOn = procedure(Self: TObject);
  TDesignerDragBoxesOff = procedure(Self: TObject);
  TDesignerDragTo = procedure(Self: TObject; X, Y: Integer);

  TPaintGrid = procedure(Self: TObject);

var
  DesignerDoDragCreate: TDesignerDoDragCreate = nil;
  DesignerDoDragMove: TDesignerDoDragMove = nil;
  DesignerDoDragSelect: TDesignerDoDragSelect = nil;
  DesignerDoDragSize: TDesignerDoDragSize = nil;
  DesignerDragBoxesMoveTo: TDesignerDragBoxesMoveTo = nil;

  DesignerDragBegin: TDesignerDragBegin = nil;
  DesignerDragEnd: TDesignerDragEnd = nil;
  DesignerDragBoxesOn: TDesignerDragBoxesOn = nil;
  DesignerDragBoxesOff: TDesignerDragBoxesOff = nil;
  DesignerDragTo: TDesignerDragTo = nil;

  // =========================================================================//

  HookDesignerDoDragCreate: TCnMethodHook = nil;
  HookDesignerDoDragMove: TCnMethodHook = nil;
  HookDesignerDoDragSelect: TCnMethodHook = nil;
  HookDesignerDoDragSize: TCnMethodHook = nil;
  HookDesignerDragBoxesMoveTo: TCnMethodHook = nil;

  HookDesignerDragBegin: TCnMethodHook = nil;
  HookDesignerDragEnd: TCnMethodHook = nil;
  HookDesignerDragBoxesOn: TCnMethodHook = nil;
  HookDesignerDragBoxesOff: TCnMethodHook = nil;
  HookDesignerDragTo: TCnMethodHook = nil;

  HookPaintGrid: TCnMethodHook = nil;

var
  PaintGridProc: Pointer = nil;

  AddressPrinted: Boolean = False;
  PrevIsMouseMove: Boolean = False;

procedure MyDesignerDoDragCreate(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDoDragCreate Called.');

  HookDesignerDoDragCreate.UnhookMethod;
  try
    DesignerDoDragCreate(Self);
  finally
    HookDesignerDoDragCreate.HookMethod;
  end;
end;

procedure MyDesignerDoDragMove(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDoDragMove Called.');

  HookDesignerDoDragMove.UnhookMethod;
  try
    DesignerDoDragMove(Self);
  finally
    HookDesignerDoDragMove.HookMethod;
  end;
end;

procedure MyDesignerDoDragSelect(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDoDragSelect Called.');

  HookDesignerDoDragSelect.UnhookMethod;
  try
    DesignerDoDragSelect(Self);
  finally
    HookDesignerDoDragSelect.HookMethod;
  end;
end;

procedure MyDesignerDoDragSize(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDoDragSize Called.');

  HookDesignerDoDragSize.UnhookMethod;
  try
    DesignerDoDragSize(Self);
  finally
    HookDesignerDoDragSize.HookMethod;
  end;
end;

procedure MyDesignerDragBoxesMoveTo(Self: TObject; ARect: PRect);
begin
  CnDebugger.LogFmt('DragBoxesMoveTo Left %d, Top %d - Right %d, Bottom %d',
    [ARect^.Left, ARect^.Top, ARect^.Right, ARect^.Bottom]);
  CnDebugger.WatchFmt('DragBoxesMoveTo', 'Left %d, Top %d - Right %d, Bottom %d',
    [ARect^.Left, ARect^.Top, ARect^.Right, ARect^.Bottom]);

  HookDesignerDragBoxesMoveTo.UnhookMethod;
  try
    DesignerDragBoxesMoveTo(Self, ARect);
  finally
    HookDesignerDragBoxesMoveTo.HookMethod;
  end;
end;

procedure MyDesignerDragBegin(Self: TObject; X, Y: Integer);
begin
  CnDebugger.LogFmt('DesignerDragBegin Called. X %d, Y %d. ', [X, Y]);

  HookDesignerDragBegin.UnhookMethod;
  try
    DesignerDragBegin(Self, X, Y);
  finally
    HookDesignerDragBegin.HookMethod;
  end;
end;

procedure MyDesignerDragEnd(Self: TObject; X, Y: Integer; Arg: Boolean);
begin
  CnDebugger.LogFmt('DesignerDragEnd Called. X %d, Y %d. Arg %d.',
    [X, Y, Integer(Arg)]);

  HookDesignerDragEnd.UnhookMethod;
  try
    DesignerDragEnd(Self, X, Y, Arg);
  finally
    HookDesignerDragEnd.HookMethod;
  end;
end;

procedure MyDesignerDragBoxesOn(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDragBoxesOn Called.');

  HookDesignerDragBoxesOn.UnhookMethod;
  try
    DesignerDragBoxesOn(Self);
  finally
    HookDesignerDragBoxesOn.HookMethod;
  end;
end;

procedure MyDesignerDragBoxesOff(Self: TObject);
begin
  CnDebugger.LogMsg('DesignerDragBoxesOff Called.');
  CnDebugger.WatchClear('DragTo');

  HookDesignerDragBoxesOff.UnhookMethod;
  try
    DesignerDragBoxesOff(Self);
  finally
    HookDesignerDragBoxesOff.HookMethod;
  end;
end;

procedure MyDesignerDragTo(Self: TObject; X, Y: Integer);
begin
//  CnDebugger.LogFmt('DesignerDragTo Called. X %d, Y %d. ', [X, Y]);
  CnDebugger.WatchFmt('DragTo', 'X %d, Y %d.', [X, Y]);

  HookDesignerDragTo.UnhookMethod;
  try
    DesignerDragTo(Self, X, Y);
  finally
    HookDesignerDragTo.HookMethod;
  end;
end;

procedure MyPaintGrid(Self: TObject);
begin
  CnDebugger.LogMsg('MyPaintGrid Called.');

  // If Original not called, grid will disappear.
  HookPaintGrid.UnhookMethod;
  try
    TPaintGrid(PaintGridProc)(Self);
  finally
    HookPaintGrid.HookMethod;
  end;
end;

procedure MyControlWndProc(Self: TControlHack; var Message: TMessage);
var
  Form: TCustomForm;
  KeyState: TKeyboardState;  
  WheelMsg: TCMMouseWheel;
begin
  if (csDesigning in Self.ComponentState) then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and (Form.Designer <> nil) and
      Form.Designer.IsDesignMsg(Self, Message) then
      begin
        if not AddressPrinted then
        begin
          CnDebugger.LogInterface(Form.Designer);

          CnDebugger.LogPointer(PPointer(PPointer(Form.Designer)^)^);               // QueryInterface
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 4)^);  // _AddRef
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 8)^);  // _Release
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 12)^); // Modified
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 16)^); // Notification
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 20)^); // GetCustomForm
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 24)^); // SetCustomForm
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 28)^); // GetIsControl
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 32)^); // SetIsControl
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 36)^); // IsDesignMsg
          CnDebugger.LogPointer(PPointer(Integer(PPointer(Form.Designer)^) + 40)^); // PaintGrid

          AddressPrinted := True;
        end;

        if (Message.Msg <> WM_MOUSEMOVE) or not PrevIsMouseMove then
          CnDebugger.LogFmt('IsDesignMsg, Ignored: %8.8x.', [Message.Msg]);

        PrevIsMouseMove := Message.Msg = WM_MOUSEMOVE;
        Exit;
      end;
  end;
  if (Message.Msg >= WM_KEYFIRST) and (Message.Msg <= WM_KEYLAST) then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and Form.WantChildKey(Self, Message) then Exit;
  end
  else if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then
  begin
    if not (csDoubleClicks in Self.ControlStyle) then
      case Message.Msg of
        WM_LBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_MBUTTONDBLCLK:
          Dec(Message.Msg, WM_LBUTTONDBLCLK - WM_LBUTTONDOWN);
      end;
    case Message.Msg of
      WM_MOUSEMOVE: Application.HintMouseMessage(Self, Message);
      WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
        begin
          if Self.DragMode = dmAutomatic then
          begin
            Self.BeginAutoDrag;
            Exit;
          end;
          Self.ControlState := Self.ControlState + [csLButtonDown];
        end;
      WM_LBUTTONUP:
        Self.ControlState := Self.ControlState - [csLButtonDown];
    else
      with Mouse do
        if WheelPresent and (RegWheelMessage <> 0) and
          (Message.Msg = RegWheelMessage) then
        begin
          GetKeyboardState(KeyState);
          with WheelMsg do
          begin
            Msg := Message.Msg;
            ShiftState := KeyboardStateToShiftState(KeyState);
            WheelDelta := Message.WParam;
            Pos := TSmallPoint(Message.LParam);
          end;
          Self.MouseWheelHandler(TMessage(WheelMsg));
          Exit;
        end;
    end;
  end
  else if Message.Msg = CM_VISIBLECHANGED then
    with Message do
      Self.SendDockNotification(Msg, WParam, LParam);
  Self.Dispatch(Message);
end;

//==============================================================================
// CnTestDesignMsgWizard 菜单专家
//==============================================================================

{ TCnTestDesignMsgWizard }

procedure TCnTestDesignMsgWizard.ActiveFormChanged(Sender: TObject);
var
  FormDesigner: IDesigner;
  AForm: TCustomForm;
begin
  if PaintGridProc = nil then
  begin
    FormDesigner := CnOtaGetFormDesigner;
    if FormDesigner = nil then
      Exit;

    if FormDesigner.Root is TCustomForm then
    begin
      AForm := TCustomForm(FormDesigner.Root);
      if (AForm <> nil) and (AForm.Designer <> nil) then
      begin
        PaintGridProc := GetInterfaceMethodAddress(AForm.Designer, 10);
        CnDebugger.LogPointer(PaintGridProc, 'PaintGrid Method of Designer.');

        if PaintGridProc <> nil then
          HookPaintGrid := TCnMethodHook.Create(PaintGridProc, @MyPaintGrid, False, False);
      end;
    end;
  end;
end;

procedure TCnTestDesignMsgWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestDesignMsgWizard.Create;
begin
  inherited;
  InitRoutines;

  FHook := TCnMethodHook.Create(GetBplMethodAddress(@TControlHack.WndProc),
    @MyControlWndProc, False, False);

  HookDesignerDoDragCreate := TCnMethodHook.Create(@DesignerDoDragCreate, @MyDesignerDoDragCreate, False, False);
  HookDesignerDoDragMove := TCnMethodHook.Create(@DesignerDoDragMove, @MyDesignerDoDragMove, False, False);
  HookDesignerDoDragSelect := TCnMethodHook.Create(@DesignerDoDragSelect, @MyDesignerDoDragSelect, False, False);
  HookDesignerDoDragSize := TCnMethodHook.Create(@DesignerDoDragSize, @MyDesignerDoDragSize, False, False);
  HookDesignerDragBoxesMoveTo := TCnMethodHook.Create(@DesignerDragBoxesMoveTo, @MyDesignerDragBoxesMoveTo, False, False);

  HookDesignerDragBegin := TCnMethodHook.Create(@DesignerDragBegin, @MyDesignerDragBegin, False, False);
  HookDesignerDragEnd := TCnMethodHook.Create(@DesignerDragEnd, @MyDesignerDragEnd, False, False);
  HookDesignerDragBoxesOn := TCnMethodHook.Create(@DesignerDragBoxesOn, @MyDesignerDragBoxesOn, False, False);
  HookDesignerDragBoxesOff := TCnMethodHook.Create(@DesignerDragBoxesOff, @MyDesignerDragBoxesOff, False, False);
  HookDesignerDragTo := TCnMethodHook.Create(@DesignerDragTo, @MyDesignerDragTo, False, False);

  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
end;

destructor TCnTestDesignMsgWizard.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);

  HookPaintGrid.Free;

  HookDesignerDragBegin.Free;
  HookDesignerDragEnd.Free;
  HookDesignerDragBoxesOn.Free;
  HookDesignerDragBoxesOff.Free;
  HookDesignerDragTo.Free;

  HookDesignerDoDragMove.Free;
  HookDesignerDoDragCreate.Free;
  HookDesignerDoDragSelect.Free;
  HookDesignerDoDragSize.Free;

  FHook.Free;

  FreeLibrary(FDesignIdeModule);
  inherited;
end;

procedure TCnTestDesignMsgWizard.Execute;
begin
  if not (Compiler in [cnDelphi6, cnDelphi7]) then
  begin
    ShowMessage('NO. Only Delphi6/7 Support.');
    Exit;
  end;

  if not FHook.Hooked then
  begin
    FHook.HookMethod;
    HookDesignerDoDragCreate.HookMethod;
    HookDesignerDoDragMove.HookMethod;
    HookDesignerDoDragSelect.HookMethod;
    HookDesignerDoDragSize.HookMethod;

    HookDesignerDragBegin.HookMethod;
    HookDesignerDragEnd.HookMethod;
    HookDesignerDragBoxesOn.HookMethod;
    HookDesignerDragBoxesOff.HookMethod;
    HookDesignerDragTo.HookMethod;

    HookPaintGrid.HookMethod;

    ShowMessage('Design Message & Routine Hooked.');
  end
  else
  begin
    FHook.UnhookMethod;
    
    HookDesignerDoDragCreate.UnhookMethod;
    HookDesignerDoDragMove.UnhookMethod;
    HookDesignerDoDragSelect.UnhookMethod;
    HookDesignerDoDragSize.UnhookMethod;

    HookDesignerDragBegin.UnhookMethod;
    HookDesignerDragEnd.UnhookMethod;
    HookDesignerDragBoxesOn.UnhookMethod;
    HookDesignerDragBoxesOff.UnhookMethod;
    HookDesignerDragTo.UnhookMethod;

    HookPaintGrid.UnhookMethod;

    ShowMessage('Design Message & Routine Unhooked.');
  end;
end;

function TCnTestDesignMsgWizard.GetCaption: string;
begin
  Result := 'Hook Design Message';
end;

function TCnTestDesignMsgWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDesignMsgWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMsgWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestDesignMsgWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDesignMsgWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Design Message Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Design Message';
end;

procedure TCnTestDesignMsgWizard.InitRoutines;
begin
  FDesignIdeModule := LoadLibrary(DesignIdeLibName);
  Assert(FDesignIdeModule <> 0, 'Failed to load DesignIdeModule');

  DesignerDoDragCreate := GetProcAddress(FDesignIdeModule, STDesignerDoDragCreate);
  Assert(Assigned(DesignerDoDragCreate), 'Failed to Get DesignerDoDragCreate');

  DesignerDoDragMove := GetProcAddress(FDesignIdeModule, STDesignerDoDragMove);
  Assert(Assigned(DesignerDoDragMove), 'Failed to Get DesignerDoDragMove');

  DesignerDoDragSelect := GetProcAddress(FDesignIdeModule, STDesignerDoDragSelect);
  Assert(Assigned(DesignerDoDragSelect), 'Failed to Get DesignerDoDragSelect');

  DesignerDoDragSize := GetProcAddress(FDesignIdeModule, STDesignerDoDragSize);
  Assert(Assigned(DesignerDoDragSize), 'Failed to Get DesignerDoDragSize');

  DesignerDragBoxesMoveTo := GetProcAddress(FDesignIdeModule, STDesignerDragBoxesMoveTo);
  Assert(Assigned(DesignerDragBoxesMoveTo), 'Failed to Get DesignerDragBoxesMoveTo');

  DesignerDragBegin := GetProcAddress(FDesignIdeModule, STDesignerDragBegin);
  Assert(Assigned(DesignerDragBegin), 'Failed to Get DesignerDragBegin');

  DesignerDragEnd := GetProcAddress(FDesignIdeModule, STDesignerDragEnd);
  Assert(Assigned(DesignerDragEnd), 'Failed to Get DesignerDragEnd');

  DesignerDragBoxesOn := GetProcAddress(FDesignIdeModule, STDesignerDragBoxesOn);
  Assert(Assigned(DesignerDragBoxesOn), 'Failed to Get DesignerDragBoxesOn');

  DesignerDragBoxesOff := GetProcAddress(FDesignIdeModule, STDesignerDragBoxesOff);
  Assert(Assigned(DesignerDragBoxesOff), 'Failed to Get DesignerDragBoxesOff');

  DesignerDragTo := GetProcAddress(FDesignIdeModule, STDesignerDragTo);
  Assert(Assigned(DesignerDragTo), 'Failed to Get DesignerDragTo');
end;

procedure TCnTestDesignMsgWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDesignMsgWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestDesignMsgWizard); // 注册此测试专家

end.
