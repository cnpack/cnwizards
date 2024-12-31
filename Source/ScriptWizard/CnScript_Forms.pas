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

unit CnScript_Forms;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Forms 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Graphics, Classes, Controls, Forms, ActnList, MultiMon,
  Menus, uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_Forms = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TApplication(CL: TPSPascalCompiler);
procedure SIRegister_TScreen(CL: TPSPascalCompiler);
procedure SIRegister_TMonitor(CL: TPSPascalCompiler);
procedure SIRegister_TDataModule(CL: TPSPascalCompiler);
procedure SIRegister_TCustomDockForm(CL: TPSPascalCompiler);
procedure SIRegister_TForm(CL: TPSPascalCompiler);
procedure SIRegister_TCustomActiveForm(CL: TPSPascalCompiler);
procedure SIRegister_TCustomForm(CL: TPSPascalCompiler);
procedure SIRegister_IOleForm(CL: TPSPascalCompiler);
procedure SIRegister_IDesignerHook(CL: TPSPascalCompiler);
procedure SIRegister_TFrame(CL: TPSPascalCompiler);
procedure SIRegister_TCustomFrame(CL: TPSPascalCompiler);
procedure SIRegister_TScrollBox(CL: TPSPascalCompiler);
procedure SIRegister_TScrollingWinControl(CL: TPSPascalCompiler);
procedure SIRegister_TControlScrollBar(CL: TPSPascalCompiler);
procedure SIRegister_Forms(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Forms_Routines(S: TPSExec);
procedure RIRegister_TApplication(CL: TPSRuntimeClassImporter);
procedure RIRegister_TScreen(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMonitor(CL: TPSRuntimeClassImporter);
procedure RIRegister_TDataModule(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomDockForm(CL: TPSRuntimeClassImporter);
procedure RIRegister_TForm(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomActiveForm(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomForm(CL: TPSRuntimeClassImporter);
procedure RIRegister_TFrame(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomFrame(CL: TPSRuntimeClassImporter);
procedure RIRegister_TScrollBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TScrollingWinControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TControlScrollBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_Forms(CL: TPSRuntimeClassImporter);

implementation

{$IFNDEF COMPILER6_UP}
type
  IDesignerHook = Forms.IDesigner;
{$ENDIF}

  (* === compile-time registration functions === *)

procedure SIRegister_TApplication(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TApplication') do
  with CL.AddClass(CL.FindClass('TComponent'), TApplication) do
  begin
    RegisterMethod('Procedure ActivateHint( CursorPos : TPoint)');
    RegisterMethod('Procedure BringToFront');
    RegisterMethod('Procedure ControlDestroyed( Control : TControl)');
    RegisterMethod('Procedure CancelHint');
    RegisterMethod('Procedure CreateHandle');
    RegisterMethod('Function ExecuteAction( Action : TBasicAction) : Boolean');
    RegisterMethod('Procedure HandleException( Sender : TObject)');
    RegisterMethod('Procedure HandleMessage');
    RegisterMethod('Function HelpCommand( Command : Integer; Data : Longint) : Boolean');
    RegisterMethod('Function HelpContext( Context : THelpContext) : Boolean');
    RegisterMethod('Function HelpJump( const JumpID : string) : Boolean');
    RegisterMethod('Procedure HideHint');
    RegisterMethod('Procedure HintMouseMessage( Control : TControl; var Message : TMessage)');
    RegisterMethod('Procedure HookMainWindow( Hook : TWindowHook)');
    RegisterMethod('Procedure Initialize');
    RegisterMethod('Function IsRightToLeft : Boolean');
  {$IFDEF UNICODE}
    RegisterMethod('Function MessageBox( const Text, Caption : string; Flags : Longint) : Integer');
  {$ELSE}
    RegisterMethod('Function MessageBox( const Text, Caption : PChar; Flags : Longint) : Integer');
  {$ENDIF}
    RegisterMethod('Procedure Minimize');
    RegisterMethod('Procedure NormalizeAllTopMosts');
    RegisterMethod('Procedure NormalizeTopMosts');
    RegisterMethod('Procedure ProcessMessages');
    RegisterMethod('Procedure Restore');
    RegisterMethod('Procedure RestoreTopMosts');
    RegisterMethod('Procedure Run');
    RegisterMethod('Procedure ShowException( E : Exception)');
    RegisterMethod('Procedure Terminate');
    RegisterMethod('Procedure UnhookMainWindow( Hook : TWindowHook)');
    RegisterMethod('Function UpdateAction( Action : TBasicAction) : Boolean');
    RegisterMethod('Function UseRightToLeftAlignment : Boolean');
    RegisterMethod('Function UseRightToLeftReading : Boolean');
    RegisterMethod('Function UseRightToLeftScrollBar : Boolean');
    RegisterProperty('Active', 'Boolean', iptr);
    RegisterProperty('AllowTesting', 'Boolean', iptrw);
    RegisterProperty('CurrentHelpFile', 'string', iptr);
    RegisterProperty('DialogHandle', 'HWnd', iptrw);
    RegisterProperty('ExeName', 'string', iptr);
    RegisterProperty('Handle', 'HWnd', iptrw);
    RegisterProperty('HelpFile', 'string', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('HintColor', 'TColor', iptrw);
    RegisterProperty('HintHidePause', 'Integer', iptrw);
    RegisterProperty('HintPause', 'Integer', iptrw);
    RegisterProperty('HintShortCuts', 'Boolean', iptrw);
    RegisterProperty('HintShortPause', 'Integer', iptrw);
    RegisterProperty('Icon', 'TIcon', iptrw);
    RegisterProperty('MainForm', 'TForm', iptr);
    RegisterProperty('BiDiMode', 'TBiDiMode', iptrw);
    RegisterProperty('BiDiKeyboard', 'string', iptrw);
    RegisterProperty('NonBiDiKeyboard', 'string', iptrw);
    RegisterProperty('ShowHint', 'Boolean', iptrw);
    RegisterProperty('ShowMainForm', 'Boolean', iptrw);
    RegisterProperty('Terminated', 'Boolean', iptr);
    RegisterProperty('Title', 'string', iptrw);
    RegisterProperty('UpdateFormatSettings', 'Boolean', iptrw);
    RegisterProperty('UpdateMetricSettings', 'Boolean', iptrw);
    RegisterProperty('OnActionExecute', 'TActionEvent', iptrw);
    RegisterProperty('OnActionUpdate', 'TActionEvent', iptrw);
    RegisterProperty('OnActivate', 'TNotifyEvent', iptrw);
    RegisterProperty('OnDeactivate', 'TNotifyEvent', iptrw);
    RegisterProperty('OnIdle', 'TIdleEvent', iptrw);
    RegisterProperty('OnHelp', 'THelpEvent', iptrw);
    RegisterProperty('OnHint', 'TNotifyEvent', iptrw);
    RegisterProperty('OnMessage', 'TMessageEvent', iptrw);
    RegisterProperty('OnMinimize', 'TNotifyEvent', iptrw);
    RegisterProperty('OnRestore', 'TNotifyEvent', iptrw);
    RegisterProperty('OnShortCut', 'TShortCutEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TScreen(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TScreen') do
  with CL.AddClass(CL.FindClass('TComponent'), TScreen) do
  begin
    RegisterMethod('Procedure DisableAlign');
    RegisterMethod('Procedure EnableAlign');
    RegisterMethod('Procedure Realign');
    RegisterMethod('Procedure ResetFonts');
    RegisterProperty('ActiveControl', 'TWinControl', iptr);
    RegisterProperty('ActiveCustomForm', 'TCustomForm', iptr);
    RegisterProperty('ActiveForm', 'TForm', iptr);
    RegisterProperty('CustomFormCount', 'Integer', iptr);
    RegisterProperty('CustomForms', 'TCustomForm Integer', iptr);
    RegisterProperty('Cursor', 'TCursor', iptrw);
    RegisterProperty('Cursors', 'HCURSOR Integer', iptrw);
    RegisterProperty('DataModules', 'TDataModule Integer', iptr);
    RegisterProperty('DataModuleCount', 'Integer', iptr);
    RegisterProperty('MonitorCount', 'Integer', iptr);
    RegisterProperty('Monitors', 'TMonitor Integer', iptr);
    RegisterProperty('DesktopHeight', 'Integer', iptr);
    RegisterProperty('DesktopLeft', 'Integer', iptr);
    RegisterProperty('DesktopTop', 'Integer', iptr);
    RegisterProperty('DesktopWidth', 'Integer', iptr);
    RegisterProperty('HintFont', 'TFont', iptrw);
    RegisterProperty('IconFont', 'TFont', iptrw);
    RegisterProperty('MenuFont', 'TFont', iptrw);
    RegisterProperty('Fonts', 'TStrings', iptr);
    RegisterProperty('FormCount', 'Integer', iptr);
    RegisterProperty('Forms', 'TForm Integer', iptr);
    RegisterProperty('Imes', 'TStrings', iptr);
    RegisterProperty('DefaultIme', 'string', iptr);
    RegisterProperty('DefaultKbLayout', 'HKL', iptr);
    RegisterProperty('Height', 'Integer', iptr);
    RegisterProperty('PixelsPerInch', 'Integer', iptr);
    RegisterProperty('Width', 'Integer', iptr);
    RegisterProperty('OnActiveControlChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnActiveFormChange', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMonitor(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TMonitor') do
  with CL.AddClass(CL.FindClass('TObject'), TMonitor) do
  begin
    RegisterProperty('Handle', 'HMONITOR', iptr);
    RegisterProperty('MonitorNum', 'Integer', iptr);
    RegisterProperty('Left', 'Integer', iptr);
    RegisterProperty('Height', 'Integer', iptr);
    RegisterProperty('Top', 'Integer', iptr);
    RegisterProperty('Width', 'Integer', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TDataModule(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TDataModule') do
  with CL.AddClass(CL.FindClass('TComponent'), TDataModule) do
  begin
    RegisterMethod('Constructor CreateNew( AOwner : TComponent; Dummy : Integer)');
    RegisterProperty('DesignOffset', 'TPoint', iptrw);
    RegisterProperty('DesignSize', 'TPoint', iptrw);
    RegisterProperty('OldCreateOrder', 'Boolean', iptrw);
    RegisterProperty('OnCreate', 'TNotifyEvent', iptrw);
    RegisterProperty('OnDestroy', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomDockForm(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomForm', 'TCustomDockForm') do
  with CL.AddClass(CL.FindClass('TCustomForm'), TCustomDockForm) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TForm(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomForm', 'TForm') do
  with CL.AddClass(CL.FindClass('TCustomForm'), TForm) do
  begin
    RegisterMethod('Procedure ArrangeIcons');
    RegisterMethod('Procedure Cascade');
    RegisterMethod('Procedure Next');
    RegisterMethod('Procedure Previous');
    RegisterMethod('Procedure Tile');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomActiveForm(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomForm', 'TCustomActiveForm') do
  with CL.AddClass(CL.FindClass('TCustomForm'), TCustomActiveForm) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomForm(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TScrollingWinControl', 'TCustomForm') do
  with CL.AddClass(CL.FindClass('TScrollingWinControl'), TCustomForm) do
  begin
    RegisterMethod('Constructor CreateNew( AOwner : TComponent; Dummy : Integer)');
    RegisterMethod('Procedure Close');
    RegisterMethod('Function CloseQuery : Boolean');
    RegisterMethod('Procedure DefocusControl( Control : TWinControl; Removing : Boolean)');
    RegisterMethod('Procedure FocusControl( Control : TWinControl)');
    RegisterMethod('Function GetFormImage : TBitmap');
    RegisterMethod('Procedure Hide');
    RegisterMethod('Function IsShortCut( var Message : TWMKey) : Boolean');
    RegisterMethod('Procedure Print');
    RegisterMethod('Procedure Release');
    RegisterMethod('Procedure SendCancelMode( Sender : TControl)');
    RegisterMethod('Function SetFocusedControl( Control : TWinControl) : Boolean');
    RegisterMethod('Procedure Show');
    RegisterMethod('Function ShowModal : Integer');
    RegisterMethod('Function WantChildKey( Child : TControl; var Message : TMessage) : Boolean');
    RegisterProperty('Active', 'Boolean', iptr);
    RegisterProperty('ActiveControl', 'TWinControl', iptrw);
    RegisterProperty('ActiveOleControl', 'TWinControl', iptrw);
    RegisterProperty('BorderStyle', 'TFormBorderStyle', iptrw);
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Designer', 'IDesignerHook', iptrw);
    RegisterProperty('DropTarget', 'Boolean', iptrw);
    RegisterProperty('FormState', 'TFormState', iptr);
    RegisterProperty('HelpFile', 'string', iptrw);
    RegisterProperty('KeyPreview', 'Boolean', iptrw);
    RegisterProperty('Menu', 'TMainMenu', iptrw);
    RegisterProperty('ModalResult', 'TModalResult', iptrw);
    RegisterProperty('Monitor', 'TMonitor', iptr);
    RegisterProperty('OleFormObject', 'IOleForm', iptrw);
    RegisterProperty('WindowState', 'TWindowState', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_IOleForm(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOleForm') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOleForm, 'IOleForm') do
  begin
    RegisterMethod('Procedure OnDestroy', cdRegister);
    RegisterMethod('Procedure OnResize', cdRegister);
  end;
end;

procedure SIRegister_IDesignerHook(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDesignerNotify', 'IDesignerHook') do
  with CL.AddInterface(CL.FindInterface('IDesignerNotify'), IDesignerHook, 'IDesignerHook') do
  begin
    RegisterMethod('Function GetCustomForm : TCustomForm', cdRegister);
    RegisterMethod('Procedure SetCustomForm( Value : TCustomForm)', cdRegister);
    RegisterMethod('Function GetIsControl : Boolean', cdRegister);
    RegisterMethod('Procedure SetIsControl( Value : Boolean)', cdRegister);
    RegisterMethod('Function IsDesignMsg( Sender : TControl; var Message : TMessage) : Boolean', cdRegister);
    RegisterMethod('Procedure PaintGrid', cdRegister);
    RegisterMethod('Procedure ValidateRename( AComponent : TComponent; const CurName, NewName : string)', cdRegister);
    RegisterMethod('Function UniqueName( const BaseName : string) : string', cdRegister);
    RegisterMethod('Function GetRoot : TComponent', cdRegister);
  end;
end;

procedure SIRegister_TFrame(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomFrame', 'TFrame') do
  with CL.AddClass(CL.FindClass('TCustomFrame'), TFrame) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomFrame(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TScrollingWinControl', 'TCustomFrame') do
  with CL.AddClass(CL.FindClass('TScrollingWinControl'), TCustomFrame) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TScrollBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TScrollingWinControl', 'TScrollBox') do
  with CL.AddClass(CL.FindClass('TScrollingWinControl'), TScrollBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TScrollingWinControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TScrollingWinControl') do
  with CL.AddClass(CL.FindClass('TWinControl'), TScrollingWinControl) do
  begin
    RegisterMethod('Procedure DisableAutoRange');
    RegisterMethod('Procedure EnableAutoRange');
    RegisterMethod('Procedure ScrollInView( AControl : TControl)');
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TControlScrollBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TControlScrollBar') do
  with CL.AddClass(CL.FindClass('TPersistent'), TControlScrollBar) do
  begin
    RegisterMethod('Procedure ChangeBiDiPosition');
    RegisterProperty('Kind', 'TScrollBarKind', iptr);
    RegisterMethod('Function IsScrollBarVisible : Boolean');
    RegisterProperty('ScrollPos', 'Integer', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_Forms(CL: TPSPascalCompiler);
begin
  CL.AddClass(CL.FindClass('TWinControl'), TScrollingWinControl);
  CL.AddClass(CL.FindClass('TScrollingWinControl'), TCustomForm);
  CL.AddClass(CL.FindClass('TCustomForm'), TForm);
  CL.AddClass(CL.FindClass('TObject'), TMonitor);
  CL.AddTypeS('TScrollBarKind', '( sbHorizontal, sbVertical )');
  CL.AddTypeS('TScrollBarInc', 'Integer');
  CL.AddTypeS('TScrollBarStyle', '( ssRegular, ssFlat, ssHotTrack )');
  SIRegister_TControlScrollBar(CL);
  CL.AddTypeS('TWindowState', '( wsNormal, wsMinimized, wsMaximized )');
  SIRegister_TScrollingWinControl(CL);
  CL.AddTypeS('TFormBorderStyle', '( bsNone, bsSingle, bsSizeable, bsDialog, bs'
    + 'ToolWindow, bsSizeToolWin )');
  CL.AddTypeS('TBorderStyle', 'TFormBorderStyle');
  SIRegister_TScrollBox(CL);
  SIRegister_TCustomFrame(CL);
  //CL.AddTypeS('TCustomFrameClass', 'class of TCustomFrame');
  SIRegister_TFrame(CL);
  SIRegister_IDesignerHook(CL);
  SIRegister_IOleForm(CL);
  CL.AddTypeS('TFormStyle', '( fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop )');
  CL.AddTypeS('TBorderIcon', '( biSystemMenu, biMinimize, biMaximize, biHelp )');
  CL.AddTypeS('TBorderIcons', 'set of TBorderIcon');
  CL.AddTypeS('TPosition', '( poDesigned, poDefault, poDefaultPosOnly, poDefaul'
    + 'tSizeOnly, poScreenCenter, poDesktopCenter, poMainFormCenter, poOwnerFormC'
    + 'enter )');
  CL.AddTypeS('TDefaultMonitor', '( dmDesktop, dmPrimary, dmMainForm, dmActiveF'
    + 'orm )');
  CL.AddTypeS('TPrintScale', '( poNone, poProportional, poPrintToFit )');
  CL.AddTypeS('TShowAction', '( saIgnore, saRestore, saMinimize, saMaximize )');
  CL.AddTypeS('TTileMode', '( tbHorizontal, tbVertical )');
  CL.AddTypeS('TModalResult', 'Integer');
  CL.AddTypeS('TCloseAction', '( caNone, caHide, caFree, caMinimize )');
  CL.AddTypeS('TCloseEvent', 'Procedure ( Sender : TObject; var Action : TClose'
    + 'Action)');
  CL.AddTypeS('TCloseQueryEvent', 'Procedure ( Sender : TObject; var CanClose :'
    + ' Boolean)');
  CL.AddTypeS('TFormStateE', '( fsCreating, fsVisible, fsShowing, fsModal, fsCr'
    + 'eatedMDIChild, fsActivated )');
  CL.AddTypeS('TFormState', 'set of TFormStateE');
  CL.AddTypeS('TShortCutEvent', 'Procedure ( var Msg : TWMKey; var Handled : Bo'
    + 'olean)');
  SIRegister_TCustomForm(CL);
  //CL.AddTypeS('TCustomFormClass', 'class of TCustomForm');
  CL.AddTypeS('TActiveFormBorderStyle', '( afbNone, afbSingle, afbSunken, afbRa'
    + 'ised )');
  SIRegister_TCustomActiveForm(CL);
  SIRegister_TForm(CL);
  //CL.AddTypeS('TFormClass', 'class of TForm');
  SIRegister_TCustomDockForm(CL);
  SIRegister_TDataModule(CL);
  CL.AddTypeS('HMONITOR', 'Integer');
  SIRegister_TMonitor(CL);
  SIRegister_TScreen(CL);
  CL.AddTypeS('TMessageEvent', 'Procedure ( var Msg : TMsg; var Handled : Boole'
    + 'an)');
  CL.AddTypeS('TIdleEvent', 'Procedure ( Sender : TObject; var Done : Boolean)');
  CL.AddTypeS('TWindowHook', 'Function ( var Message : TMessage) : Boolean');
  SIRegister_TApplication(CL);
  CL.AddDelphiFunction('Function Application : TApplication;');
  CL.AddDelphiFunction('Function Screen : TScreen;');
  CL.AddDelphiFunction('Function GetParentForm( Control : TControl) : TCustomForm');
  CL.AddDelphiFunction('Function ValidParentForm( Control : TControl) : TCustomForm');
  CL.AddDelphiFunction('Function DisableTaskWindows( ActiveWindow : HWnd) : Pointer');
  CL.AddDelphiFunction('Procedure EnableTaskWindows( WindowList : Pointer)');
  CL.AddDelphiFunction('Function IsAccel( VK : Word; const Str : string) : Boolean');
  CL.AddDelphiFunction('Function KeysToShiftState( Keys : Word) : TShiftState');
  CL.AddDelphiFunction('Function KeyDataToShiftState( KeyData : Longint) : TShiftState');
  CL.AddDelphiFunction('Function ForegroundTask : Boolean');
end;

(* === run-time registration functions === *)

function Screen_P: TScreen;
begin
  Result := Forms.Screen;
end;

function Application_P: TApplication;
begin
  Result := Forms.Application;
end;

procedure TApplicationOnShortCut_W(Self: TApplication; const T: TShortCutEvent);
begin
  Self.OnShortCut := T;
end;

procedure TApplicationOnShortCut_R(Self: TApplication; var T: TShortCutEvent);
begin
  T := Self.OnShortCut;
end;

procedure TApplicationOnRestore_W(Self: TApplication; const T: TNotifyEvent);
begin
  Self.OnRestore := T;
end;

procedure TApplicationOnRestore_R(Self: TApplication; var T: TNotifyEvent);
begin
  T := Self.OnRestore;
end;

procedure TApplicationOnMinimize_W(Self: TApplication; const T: TNotifyEvent);
begin
  Self.OnMinimize := T;
end;

procedure TApplicationOnMinimize_R(Self: TApplication; var T: TNotifyEvent);
begin
  T := Self.OnMinimize;
end;

procedure TApplicationOnMessage_W(Self: TApplication; const T: TMessageEvent);
begin
  Self.OnMessage := T;
end;

procedure TApplicationOnMessage_R(Self: TApplication; var T: TMessageEvent);
begin
  T := Self.OnMessage;
end;

procedure TApplicationOnHint_W(Self: TApplication; const T: TNotifyEvent);
begin
  Self.OnHint := T;
end;

procedure TApplicationOnHint_R(Self: TApplication; var T: TNotifyEvent);
begin
  T := Self.OnHint;
end;

procedure TApplicationOnHelp_W(Self: TApplication; const T: THelpEvent);
begin
  Self.OnHelp := T;
end;

procedure TApplicationOnHelp_R(Self: TApplication; var T: THelpEvent);
begin
  T := Self.OnHelp;
end;

procedure TApplicationOnIdle_W(Self: TApplication; const T: TIdleEvent);
begin
  Self.OnIdle := T;
end;

procedure TApplicationOnIdle_R(Self: TApplication; var T: TIdleEvent);
begin
  T := Self.OnIdle;
end;

procedure TApplicationOnDeactivate_W(Self: TApplication; const T: TNotifyEvent);
begin
  Self.OnDeactivate := T;
end;

procedure TApplicationOnDeactivate_R(Self: TApplication; var T: TNotifyEvent);
begin
  T := Self.OnDeactivate;
end;

procedure TApplicationOnActivate_W(Self: TApplication; const T: TNotifyEvent);
begin
  Self.OnActivate := T;
end;

procedure TApplicationOnActivate_R(Self: TApplication; var T: TNotifyEvent);
begin
  T := Self.OnActivate;
end;

procedure TApplicationOnActionUpdate_W(Self: TApplication; const T: TActionEvent);
begin
  Self.OnActionUpdate := T;
end;

procedure TApplicationOnActionUpdate_R(Self: TApplication; var T: TActionEvent);
begin
  T := Self.OnActionUpdate;
end;

procedure TApplicationOnActionExecute_W(Self: TApplication; const T: TActionEvent);
begin
  Self.OnActionExecute := T;
end;

procedure TApplicationOnActionExecute_R(Self: TApplication; var T: TActionEvent);
begin
  T := Self.OnActionExecute;
end;

procedure TApplicationUpdateMetricSettings_W(Self: TApplication; const T: Boolean);
begin
  Self.UpdateMetricSettings := T;
end;

procedure TApplicationUpdateMetricSettings_R(Self: TApplication; var T: Boolean);
begin
  T := Self.UpdateMetricSettings;
end;

procedure TApplicationUpdateFormatSettings_W(Self: TApplication; const T: Boolean);
begin
  Self.UpdateFormatSettings := T;
end;

procedure TApplicationUpdateFormatSettings_R(Self: TApplication; var T: Boolean);
begin
  T := Self.UpdateFormatSettings;
end;

procedure TApplicationTitle_W(Self: TApplication; const T: string);
begin
  Self.Title := T;
end;

procedure TApplicationTitle_R(Self: TApplication; var T: string);
begin
  T := Self.Title;
end;

procedure TApplicationTerminated_R(Self: TApplication; var T: Boolean);
begin
  T := Self.Terminated;
end;

procedure TApplicationShowMainForm_W(Self: TApplication; const T: Boolean);
begin
  Self.ShowMainForm := T;
end;

procedure TApplicationShowMainForm_R(Self: TApplication; var T: Boolean);
begin
  T := Self.ShowMainForm;
end;

procedure TApplicationShowHint_W(Self: TApplication; const T: Boolean);
begin
  Self.ShowHint := T;
end;

procedure TApplicationShowHint_R(Self: TApplication; var T: Boolean);
begin
  T := Self.ShowHint;
end;

procedure TApplicationNonBiDiKeyboard_W(Self: TApplication; const T: string);
begin
  Self.NonBiDiKeyboard := T;
end;

procedure TApplicationNonBiDiKeyboard_R(Self: TApplication; var T: string);
begin
  T := Self.NonBiDiKeyboard;
end;

procedure TApplicationBiDiKeyboard_W(Self: TApplication; const T: string);
begin
  Self.BiDiKeyboard := T;
end;

procedure TApplicationBiDiKeyboard_R(Self: TApplication; var T: string);
begin
  T := Self.BiDiKeyboard;
end;

procedure TApplicationBiDiMode_W(Self: TApplication; const T: TBiDiMode);
begin
  Self.BiDiMode := T;
end;

procedure TApplicationBiDiMode_R(Self: TApplication; var T: TBiDiMode);
begin
  T := Self.BiDiMode;
end;

procedure TApplicationMainForm_R(Self: TApplication; var T: TForm);
begin
  T := Self.MainForm;
end;

procedure TApplicationIcon_W(Self: TApplication; const T: TIcon);
begin
  Self.Icon := T;
end;

procedure TApplicationIcon_R(Self: TApplication; var T: TIcon);
begin
  T := Self.Icon;
end;

procedure TApplicationHintShortPause_W(Self: TApplication; const T: Integer);
begin
  Self.HintShortPause := T;
end;

procedure TApplicationHintShortPause_R(Self: TApplication; var T: Integer);
begin
  T := Self.HintShortPause;
end;

procedure TApplicationHintShortCuts_W(Self: TApplication; const T: Boolean);
begin
  Self.HintShortCuts := T;
end;

procedure TApplicationHintShortCuts_R(Self: TApplication; var T: Boolean);
begin
  T := Self.HintShortCuts;
end;

procedure TApplicationHintPause_W(Self: TApplication; const T: Integer);
begin
  Self.HintPause := T;
end;

procedure TApplicationHintPause_R(Self: TApplication; var T: Integer);
begin
  T := Self.HintPause;
end;

procedure TApplicationHintHidePause_W(Self: TApplication; const T: Integer);
begin
  Self.HintHidePause := T;
end;

procedure TApplicationHintHidePause_R(Self: TApplication; var T: Integer);
begin
  T := Self.HintHidePause;
end;

procedure TApplicationHintColor_W(Self: TApplication; const T: TColor);
begin
  Self.HintColor := T;
end;

procedure TApplicationHintColor_R(Self: TApplication; var T: TColor);
begin
  T := Self.HintColor;
end;

procedure TApplicationHint_W(Self: TApplication; const T: string);
begin
  Self.Hint := T;
end;

procedure TApplicationHint_R(Self: TApplication; var T: string);
begin
  T := Self.Hint;
end;

procedure TApplicationHelpFile_W(Self: TApplication; const T: string);
begin
  Self.HelpFile := T;
end;

procedure TApplicationHelpFile_R(Self: TApplication; var T: string);
begin
  T := Self.HelpFile;
end;

procedure TApplicationHandle_W(Self: TApplication; const T: HWnd);
begin
  Self.Handle := T;
end;

procedure TApplicationHandle_R(Self: TApplication; var T: HWnd);
begin
  T := Self.Handle;
end;

procedure TApplicationExeName_R(Self: TApplication; var T: string);
begin
  T := Self.ExeName;
end;

procedure TApplicationDialogHandle_W(Self: TApplication; const T: HWnd);
begin
  Self.DialogHandle := T;
end;

procedure TApplicationDialogHandle_R(Self: TApplication; var T: HWnd);
begin
  T := Self.DialogHandle;
end;

procedure TApplicationCurrentHelpFile_R(Self: TApplication; var T: string);
begin
  T := Self.CurrentHelpFile;
end;

procedure TApplicationAllowTesting_W(Self: TApplication; const T: Boolean);
begin
  Self.AllowTesting := T;
end;

procedure TApplicationAllowTesting_R(Self: TApplication; var T: Boolean);
begin
  T := Self.AllowTesting;
end;

procedure TApplicationActive_R(Self: TApplication; var T: Boolean);
begin
  T := Self.Active;
end;

procedure TScreenOnActiveFormChange_W(Self: TScreen; const T: TNotifyEvent);
begin
  Self.OnActiveFormChange := T;
end;

procedure TScreenOnActiveFormChange_R(Self: TScreen; var T: TNotifyEvent);
begin
  T := Self.OnActiveFormChange;
end;

procedure TScreenOnActiveControlChange_W(Self: TScreen; const T: TNotifyEvent);
begin
  Self.OnActiveControlChange := T;
end;

procedure TScreenOnActiveControlChange_R(Self: TScreen; var T: TNotifyEvent);
begin
  T := Self.OnActiveControlChange;
end;

procedure TScreenWidth_R(Self: TScreen; var T: Integer);
begin
  T := Self.Width;
end;

procedure TScreenPixelsPerInch_R(Self: TScreen; var T: Integer);
begin
  T := Self.PixelsPerInch;
end;

procedure TScreenHeight_R(Self: TScreen; var T: Integer);
begin
  T := Self.Height;
end;

procedure TScreenDefaultKbLayout_R(Self: TScreen; var T: HKL);
begin
  T := Self.DefaultKbLayout;
end;

procedure TScreenDefaultIme_R(Self: TScreen; var T: string);
begin
  T := Self.DefaultIme;
end;

procedure TScreenImes_R(Self: TScreen; var T: TStrings);
begin
  T := Self.Imes;
end;

procedure TScreenForms_R(Self: TScreen; var T: TForm; const t1: Integer);
begin
  T := Self.Forms[t1];
end;

procedure TScreenFormCount_R(Self: TScreen; var T: Integer);
begin
  T := Self.FormCount;
end;

procedure TScreenFonts_R(Self: TScreen; var T: TStrings);
begin
  T := Self.Fonts;
end;

procedure TScreenMenuFont_W(Self: TScreen; const T: TFont);
begin
  Self.MenuFont := T;
end;

procedure TScreenMenuFont_R(Self: TScreen; var T: TFont);
begin
  T := Self.MenuFont;
end;

procedure TScreenIconFont_W(Self: TScreen; const T: TFont);
begin
  Self.IconFont := T;
end;

procedure TScreenIconFont_R(Self: TScreen; var T: TFont);
begin
  T := Self.IconFont;
end;

procedure TScreenHintFont_W(Self: TScreen; const T: TFont);
begin
  Self.HintFont := T;
end;

procedure TScreenHintFont_R(Self: TScreen; var T: TFont);
begin
  T := Self.HintFont;
end;

procedure TScreenDesktopWidth_R(Self: TScreen; var T: Integer);
begin
  T := Self.DesktopWidth;
end;

procedure TScreenDesktopTop_R(Self: TScreen; var T: Integer);
begin
  T := Self.DesktopTop;
end;

procedure TScreenDesktopLeft_R(Self: TScreen; var T: Integer);
begin
  T := Self.DesktopLeft;
end;

procedure TScreenDesktopHeight_R(Self: TScreen; var T: Integer);
begin
  T := Self.DesktopHeight;
end;

procedure TScreenMonitors_R(Self: TScreen; var T: TMonitor; const t1: Integer);
begin
  T := Self.Monitors[t1];
end;

procedure TScreenMonitorCount_R(Self: TScreen; var T: Integer);
begin
  T := Self.MonitorCount;
end;

procedure TScreenDataModuleCount_R(Self: TScreen; var T: Integer);
begin
  T := Self.DataModuleCount;
end;

procedure TScreenDataModules_R(Self: TScreen; var T: TDataModule; const t1: Integer);
begin
  T := Self.DataModules[t1];
end;

procedure TScreenCursors_W(Self: TScreen; const T: HCURSOR; const t1: Integer);
begin
  Self.Cursors[t1] := T;
end;

procedure TScreenCursors_R(Self: TScreen; var T: HCURSOR; const t1: Integer);
begin
  T := Self.Cursors[t1];
end;

procedure TScreenCursor_W(Self: TScreen; const T: TCursor);
begin
  Self.Cursor := T;
end;

procedure TScreenCursor_R(Self: TScreen; var T: TCursor);
begin
  T := Self.Cursor;
end;

procedure TScreenCustomForms_R(Self: TScreen; var T: TCustomForm; const t1: Integer);
begin
  T := Self.CustomForms[t1];
end;

procedure TScreenCustomFormCount_R(Self: TScreen; var T: Integer);
begin
  T := Self.CustomFormCount;
end;

procedure TScreenActiveForm_R(Self: TScreen; var T: TForm);
begin
  T := Self.ActiveForm;
end;

procedure TScreenActiveCustomForm_R(Self: TScreen; var T: TCustomForm);
begin
  T := Self.ActiveCustomForm;
end;

procedure TScreenActiveControl_R(Self: TScreen; var T: TWinControl);
begin
  T := Self.ActiveControl;
end;

procedure TMonitorWidth_R(Self: TMonitor; var T: Integer);
begin
  T := Self.Width;
end;

procedure TMonitorTop_R(Self: TMonitor; var T: Integer);
begin
  T := Self.Top;
end;

procedure TMonitorHeight_R(Self: TMonitor; var T: Integer);
begin
  T := Self.Height;
end;

procedure TMonitorLeft_R(Self: TMonitor; var T: Integer);
begin
  T := Self.Left;
end;

procedure TMonitorMonitorNum_R(Self: TMonitor; var T: Integer);
begin
  T := Self.MonitorNum;
end;

procedure TMonitorHandle_R(Self: TMonitor; var T: HMONITOR);
begin
  T := Self.Handle;
end;

procedure TDataModuleOnDestroy_W(Self: TDataModule; const T: TNotifyEvent);
begin
  Self.OnDestroy := T;
end;

procedure TDataModuleOnDestroy_R(Self: TDataModule; var T: TNotifyEvent);
begin
  T := Self.OnDestroy;
end;

procedure TDataModuleOnCreate_W(Self: TDataModule; const T: TNotifyEvent);
begin
  Self.OnCreate := T;
end;

procedure TDataModuleOnCreate_R(Self: TDataModule; var T: TNotifyEvent);
begin
  T := Self.OnCreate;
end;

{$IFNDEF NO_OLDCREATEORDER}

procedure TDataModuleOldCreateOrder_W(Self: TDataModule; const T: Boolean);
begin
  Self.OldCreateOrder := T;
end;

procedure TDataModuleOldCreateOrder_R(Self: TDataModule; var T: Boolean);
begin
  T := Self.OldCreateOrder;
end;

{$ENDIF}

procedure TDataModuleDesignSize_W(Self: TDataModule; const T: TPoint);
begin
  Self.DesignSize := T;
end;

procedure TDataModuleDesignSize_R(Self: TDataModule; var T: TPoint);
begin
  T := Self.DesignSize;
end;

procedure TDataModuleDesignOffset_W(Self: TDataModule; const T: TPoint);
begin
  Self.DesignOffset := T;
end;

procedure TDataModuleDesignOffset_R(Self: TDataModule; var T: TPoint);
begin
  T := Self.DesignOffset;
end;

procedure TCustomFormWindowState_W(Self: TCustomForm; const T: TWindowState);
begin
  Self.WindowState := T;
end;

procedure TCustomFormWindowState_R(Self: TCustomForm; var T: TWindowState);
begin
  T := Self.WindowState;
end;

procedure TCustomFormOleFormObject_W(Self: TCustomForm; const T: IOleForm);
begin
  Self.OleFormObject := T;
end;

procedure TCustomFormOleFormObject_R(Self: TCustomForm; var T: IOleForm);
begin
  T := Self.OleFormObject;
end;

procedure TCustomFormMonitor_R(Self: TCustomForm; var T: TMonitor);
begin
  T := Self.Monitor;
end;

procedure TCustomFormModalResult_W(Self: TCustomForm; const T: TModalResult);
begin
  Self.ModalResult := T;
end;

procedure TCustomFormModalResult_R(Self: TCustomForm; var T: TModalResult);
begin
  T := Self.ModalResult;
end;

procedure TCustomFormMenu_W(Self: TCustomForm; const T: TMainMenu);
begin
  Self.Menu := T;
end;

procedure TCustomFormMenu_R(Self: TCustomForm; var T: TMainMenu);
begin
  T := Self.Menu;
end;

procedure TCustomFormKeyPreview_W(Self: TCustomForm; const T: Boolean);
begin
  Self.KeyPreview := T;
end;

procedure TCustomFormKeyPreview_R(Self: TCustomForm; var T: Boolean);
begin
  T := Self.KeyPreview;
end;

procedure TCustomFormHelpFile_W(Self: TCustomForm; const T: string);
begin
  Self.HelpFile := T;
end;

procedure TCustomFormHelpFile_R(Self: TCustomForm; var T: string);
begin
  T := Self.HelpFile;
end;

procedure TCustomFormFormState_R(Self: TCustomForm; var T: TFormState);
begin
  T := Self.FormState;
end;

procedure TCustomFormDropTarget_W(Self: TCustomForm; const T: Boolean);
begin
  Self.DropTarget := T;
end;

procedure TCustomFormDropTarget_R(Self: TCustomForm; var T: Boolean);
begin
  T := Self.DropTarget;
end;

procedure TCustomFormDesigner_W(Self: TCustomForm; const T: IDesignerHook);
begin
  Self.Designer := T;
end;

procedure TCustomFormDesigner_R(Self: TCustomForm; var T: IDesignerHook);
begin
  T := Self.Designer;
end;

procedure TCustomFormCanvas_R(Self: TCustomForm; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TCustomFormBorderStyle_W(Self: TCustomForm; const T: TFormBorderStyle);
begin
  Self.BorderStyle := T;
end;

procedure TCustomFormBorderStyle_R(Self: TCustomForm; var T: TFormBorderStyle);
begin
  T := Self.BorderStyle;
end;

procedure TCustomFormActiveOleControl_W(Self: TCustomForm; const T: TWinControl);
begin
  Self.ActiveOleControl := T;
end;

procedure TCustomFormActiveOleControl_R(Self: TCustomForm; var T: TWinControl);
begin
  T := Self.ActiveOleControl;
end;

procedure TCustomFormActiveControl_W(Self: TCustomForm; const T: TWinControl);
begin
  Self.ActiveControl := T;
end;

procedure TCustomFormActiveControl_R(Self: TCustomForm; var T: TWinControl);
begin
  T := Self.ActiveControl;
end;

procedure TCustomFormActive_R(Self: TCustomForm; var T: Boolean);
begin
  T := Self.Active;
end;

procedure TControlScrollBarScrollPos_R(Self: TControlScrollBar; var T: Integer);
begin
  T := Self.ScrollPos;
end;

procedure TControlScrollBarKind_R(Self: TControlScrollBar; var T: TScrollBarKind);
begin
  T := Self.Kind;
end;

procedure RIRegister_Forms_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Application_P, 'Application', cdRegister);
  S.RegisterDelphiFunction(@Screen_P, 'Screen', cdRegister);
  S.RegisterDelphiFunction(@GetParentForm, 'GetParentForm', cdRegister);
  S.RegisterDelphiFunction(@ValidParentForm, 'ValidParentForm', cdRegister);
  S.RegisterDelphiFunction(@DisableTaskWindows, 'DisableTaskWindows', cdRegister);
  S.RegisterDelphiFunction(@EnableTaskWindows, 'EnableTaskWindows', cdRegister);
  S.RegisterDelphiFunction(@IsAccel, 'IsAccel', cdRegister);
  S.RegisterDelphiFunction(@KeysToShiftState, 'KeysToShiftState', cdRegister);
  S.RegisterDelphiFunction(@KeyDataToShiftState, 'KeyDataToShiftState', cdRegister);
  S.RegisterDelphiFunction(@ForegroundTask, 'ForegroundTask', cdRegister);
end;

procedure RIRegister_TApplication(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TApplication) do
  begin
    RegisterMethod(@TApplication.ActivateHint, 'ActivateHint');
    RegisterMethod(@TApplication.BringToFront, 'BringToFront');
    RegisterMethod(@TApplication.ControlDestroyed, 'ControlDestroyed');
    RegisterMethod(@TApplication.CancelHint, 'CancelHint');
    RegisterMethod(@TApplication.CreateHandle, 'CreateHandle');
    RegisterMethod(@TApplication.ExecuteAction, 'ExecuteAction');
    RegisterMethod(@TApplication.HandleException, 'HandleException');
    RegisterMethod(@TApplication.HandleMessage, 'HandleMessage');
    RegisterMethod(@TApplication.HelpCommand, 'HelpCommand');
    RegisterMethod(@TApplication.HelpContext, 'HelpContext');
    RegisterMethod(@TApplication.HelpJump, 'HelpJump');
    RegisterMethod(@TApplication.HideHint, 'HideHint');
    RegisterMethod(@TApplication.HintMouseMessage, 'HintMouseMessage');
    RegisterMethod(@TApplication.HookMainWindow, 'HookMainWindow');
    RegisterMethod(@TApplication.Initialize, 'Initialize');
    RegisterMethod(@TApplication.IsRightToLeft, 'IsRightToLeft');
    RegisterMethod(@TApplication.MessageBox, 'MessageBox');
    RegisterMethod(@TApplication.Minimize, 'Minimize');
    RegisterMethod(@TApplication.NormalizeAllTopMosts, 'NormalizeAllTopMosts');
    RegisterMethod(@TApplication.NormalizeTopMosts, 'NormalizeTopMosts');
    RegisterMethod(@TApplication.ProcessMessages, 'ProcessMessages');
    RegisterMethod(@TApplication.Restore, 'Restore');
    RegisterMethod(@TApplication.RestoreTopMosts, 'RestoreTopMosts');
    RegisterMethod(@TApplication.Run, 'Run');
    RegisterMethod(@TApplication.ShowException, 'ShowException');
    RegisterMethod(@TApplication.Terminate, 'Terminate');
    RegisterMethod(@TApplication.UnhookMainWindow, 'UnhookMainWindow');
    RegisterMethod(@TApplication.UpdateAction, 'UpdateAction');
    RegisterMethod(@TApplication.UseRightToLeftAlignment, 'UseRightToLeftAlignment');
    RegisterMethod(@TApplication.UseRightToLeftReading, 'UseRightToLeftReading');
    RegisterMethod(@TApplication.UseRightToLeftScrollBar, 'UseRightToLeftScrollBar');
    RegisterPropertyHelper(@TApplicationActive_R, nil, 'Active');
    RegisterPropertyHelper(@TApplicationAllowTesting_R, @TApplicationAllowTesting_W, 'AllowTesting');
    RegisterPropertyHelper(@TApplicationCurrentHelpFile_R, nil, 'CurrentHelpFile');
    RegisterPropertyHelper(@TApplicationDialogHandle_R, @TApplicationDialogHandle_W, 'DialogHandle');
    RegisterPropertyHelper(@TApplicationExeName_R, nil, 'ExeName');
    RegisterPropertyHelper(@TApplicationHandle_R, @TApplicationHandle_W, 'Handle');
    RegisterPropertyHelper(@TApplicationHelpFile_R, @TApplicationHelpFile_W, 'HelpFile');
    RegisterPropertyHelper(@TApplicationHint_R, @TApplicationHint_W, 'Hint');
    RegisterPropertyHelper(@TApplicationHintColor_R, @TApplicationHintColor_W, 'HintColor');
    RegisterPropertyHelper(@TApplicationHintHidePause_R, @TApplicationHintHidePause_W, 'HintHidePause');
    RegisterPropertyHelper(@TApplicationHintPause_R, @TApplicationHintPause_W, 'HintPause');
    RegisterPropertyHelper(@TApplicationHintShortCuts_R, @TApplicationHintShortCuts_W, 'HintShortCuts');
    RegisterPropertyHelper(@TApplicationHintShortPause_R, @TApplicationHintShortPause_W, 'HintShortPause');
    RegisterPropertyHelper(@TApplicationIcon_R, @TApplicationIcon_W, 'Icon');
    RegisterPropertyHelper(@TApplicationMainForm_R, nil, 'MainForm');
    RegisterPropertyHelper(@TApplicationBiDiMode_R, @TApplicationBiDiMode_W, 'BiDiMode');
    RegisterPropertyHelper(@TApplicationBiDiKeyboard_R, @TApplicationBiDiKeyboard_W, 'BiDiKeyboard');
    RegisterPropertyHelper(@TApplicationNonBiDiKeyboard_R, @TApplicationNonBiDiKeyboard_W, 'NonBiDiKeyboard');
    RegisterPropertyHelper(@TApplicationShowHint_R, @TApplicationShowHint_W, 'ShowHint');
    RegisterPropertyHelper(@TApplicationShowMainForm_R, @TApplicationShowMainForm_W, 'ShowMainForm');
    RegisterPropertyHelper(@TApplicationTerminated_R, nil, 'Terminated');
    RegisterPropertyHelper(@TApplicationTitle_R, @TApplicationTitle_W, 'Title');
    RegisterPropertyHelper(@TApplicationUpdateFormatSettings_R, @TApplicationUpdateFormatSettings_W, 'UpdateFormatSettings');
    RegisterPropertyHelper(@TApplicationUpdateMetricSettings_R, @TApplicationUpdateMetricSettings_W, 'UpdateMetricSettings');
    RegisterPropertyHelper(@TApplicationOnActionExecute_R, @TApplicationOnActionExecute_W, 'OnActionExecute');
    RegisterPropertyHelper(@TApplicationOnActionUpdate_R, @TApplicationOnActionUpdate_W, 'OnActionUpdate');
    RegisterPropertyHelper(@TApplicationOnActivate_R, @TApplicationOnActivate_W, 'OnActivate');
    RegisterPropertyHelper(@TApplicationOnDeactivate_R, @TApplicationOnDeactivate_W, 'OnDeactivate');
    RegisterPropertyHelper(@TApplicationOnIdle_R, @TApplicationOnIdle_W, 'OnIdle');
    RegisterPropertyHelper(@TApplicationOnHelp_R, @TApplicationOnHelp_W, 'OnHelp');
    RegisterPropertyHelper(@TApplicationOnHint_R, @TApplicationOnHint_W, 'OnHint');
    RegisterPropertyHelper(@TApplicationOnMessage_R, @TApplicationOnMessage_W, 'OnMessage');
    RegisterPropertyHelper(@TApplicationOnMinimize_R, @TApplicationOnMinimize_W, 'OnMinimize');
    RegisterPropertyHelper(@TApplicationOnRestore_R, @TApplicationOnRestore_W, 'OnRestore');
    RegisterPropertyHelper(@TApplicationOnShortCut_R, @TApplicationOnShortCut_W, 'OnShortCut');
  end;
end;

procedure RIRegister_TScreen(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TScreen) do
  begin
    RegisterMethod(@TScreen.DisableAlign, 'DisableAlign');
    RegisterMethod(@TScreen.EnableAlign, 'EnableAlign');
    RegisterMethod(@TScreen.Realign, 'Realign');
    RegisterMethod(@TScreen.ResetFonts, 'ResetFonts');
    RegisterPropertyHelper(@TScreenActiveControl_R, nil, 'ActiveControl');
    RegisterPropertyHelper(@TScreenActiveCustomForm_R, nil, 'ActiveCustomForm');
    RegisterPropertyHelper(@TScreenActiveForm_R, nil, 'ActiveForm');
    RegisterPropertyHelper(@TScreenCustomFormCount_R, nil, 'CustomFormCount');
    RegisterPropertyHelper(@TScreenCustomForms_R, nil, 'CustomForms');
    RegisterPropertyHelper(@TScreenCursor_R, @TScreenCursor_W, 'Cursor');
    RegisterPropertyHelper(@TScreenCursors_R, @TScreenCursors_W, 'Cursors');
    RegisterPropertyHelper(@TScreenDataModules_R, nil, 'DataModules');
    RegisterPropertyHelper(@TScreenDataModuleCount_R, nil, 'DataModuleCount');
    RegisterPropertyHelper(@TScreenMonitorCount_R, nil, 'MonitorCount');
    RegisterPropertyHelper(@TScreenMonitors_R, nil, 'Monitors');
    RegisterPropertyHelper(@TScreenDesktopHeight_R, nil, 'DesktopHeight');
    RegisterPropertyHelper(@TScreenDesktopLeft_R, nil, 'DesktopLeft');
    RegisterPropertyHelper(@TScreenDesktopTop_R, nil, 'DesktopTop');
    RegisterPropertyHelper(@TScreenDesktopWidth_R, nil, 'DesktopWidth');
    RegisterPropertyHelper(@TScreenHintFont_R, @TScreenHintFont_W, 'HintFont');
    RegisterPropertyHelper(@TScreenIconFont_R, @TScreenIconFont_W, 'IconFont');
    RegisterPropertyHelper(@TScreenMenuFont_R, @TScreenMenuFont_W, 'MenuFont');
    RegisterPropertyHelper(@TScreenFonts_R, nil, 'Fonts');
    RegisterPropertyHelper(@TScreenFormCount_R, nil, 'FormCount');
    RegisterPropertyHelper(@TScreenForms_R, nil, 'Forms');
    RegisterPropertyHelper(@TScreenImes_R, nil, 'Imes');
    RegisterPropertyHelper(@TScreenDefaultIme_R, nil, 'DefaultIme');
    RegisterPropertyHelper(@TScreenDefaultKbLayout_R, nil, 'DefaultKbLayout');
    RegisterPropertyHelper(@TScreenHeight_R, nil, 'Height');
    RegisterPropertyHelper(@TScreenPixelsPerInch_R, nil, 'PixelsPerInch');
    RegisterPropertyHelper(@TScreenWidth_R, nil, 'Width');
    RegisterPropertyHelper(@TScreenOnActiveControlChange_R, @TScreenOnActiveControlChange_W, 'OnActiveControlChange');
    RegisterPropertyHelper(@TScreenOnActiveFormChange_R, @TScreenOnActiveFormChange_W, 'OnActiveFormChange');
  end;
end;

procedure RIRegister_TMonitor(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMonitor) do
  begin
    RegisterPropertyHelper(@TMonitorHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TMonitorMonitorNum_R, nil, 'MonitorNum');
    RegisterPropertyHelper(@TMonitorLeft_R, nil, 'Left');
    RegisterPropertyHelper(@TMonitorHeight_R, nil, 'Height');
    RegisterPropertyHelper(@TMonitorTop_R, nil, 'Top');
    RegisterPropertyHelper(@TMonitorWidth_R, nil, 'Width');
  end;
end;

procedure RIRegister_TDataModule(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TDataModule) do
  begin
    RegisterVirtualConstructor(@TDataModule.CreateNew, 'CreateNew');
    RegisterPropertyHelper(@TDataModuleDesignOffset_R, @TDataModuleDesignOffset_W, 'DesignOffset');
    RegisterPropertyHelper(@TDataModuleDesignSize_R, @TDataModuleDesignSize_W, 'DesignSize');
{$IFNDEF NO_OLDCREATEORDER}
    RegisterPropertyHelper(@TDataModuleOldCreateOrder_R, @TDataModuleOldCreateOrder_W, 'OldCreateOrder');
{$ENDIF}
    RegisterPropertyHelper(@TDataModuleOnCreate_R, @TDataModuleOnCreate_W, 'OnCreate');
    RegisterPropertyHelper(@TDataModuleOnDestroy_R, @TDataModuleOnDestroy_W, 'OnDestroy');
  end;
end;

procedure RIRegister_TCustomDockForm(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomDockForm) do
  begin
  end;
end;

procedure RIRegister_TForm(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TForm) do
  begin
    RegisterMethod(@TForm.ArrangeIcons, 'ArrangeIcons');
    RegisterMethod(@TForm.Cascade, 'Cascade');
    RegisterMethod(@TForm.Next, 'Next');
    RegisterMethod(@TForm.Previous, 'Previous');
    RegisterMethod(@TForm.Tile, 'Tile');
  end;
end;

procedure RIRegister_TCustomActiveForm(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomActiveForm) do
  begin
  end;
end;

procedure RIRegister_TCustomForm(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomForm) do
  begin
    RegisterVirtualConstructor(@TCustomForm.CreateNew, 'CreateNew');
    RegisterMethod(@TCustomForm.Close, 'Close');
    RegisterVirtualMethod(@TCustomForm.CloseQuery, 'CloseQuery');
    RegisterMethod(@TCustomForm.DefocusControl, 'DefocusControl');
    RegisterMethod(@TCustomForm.FocusControl, 'FocusControl');
    RegisterMethod(@TCustomForm.GetFormImage, 'GetFormImage');
    RegisterMethod(@TCustomForm.Hide, 'Hide');
    RegisterVirtualMethod(@TCustomForm.IsShortCut, 'IsShortCut');
    RegisterMethod(@TCustomForm.Print, 'Print');
    RegisterMethod(@TCustomForm.Release, 'Release');
    RegisterMethod(@TCustomForm.SendCancelMode, 'SendCancelMode');
    RegisterVirtualMethod(@TCustomForm.SetFocusedControl, 'SetFocusedControl');
    RegisterMethod(@TCustomForm.Show, 'Show');
    RegisterVirtualMethod(@TCustomForm.ShowModal, 'ShowModal');
    RegisterVirtualMethod(@TCustomForm.WantChildKey, 'WantChildKey');
    RegisterPropertyHelper(@TCustomFormActive_R, nil, 'Active');
    RegisterPropertyHelper(@TCustomFormActiveControl_R, @TCustomFormActiveControl_W, 'ActiveControl');
    RegisterPropertyHelper(@TCustomFormActiveOleControl_R, @TCustomFormActiveOleControl_W, 'ActiveOleControl');
    RegisterPropertyHelper(@TCustomFormBorderStyle_R, @TCustomFormBorderStyle_W, 'BorderStyle');
    RegisterPropertyHelper(@TCustomFormCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomFormDesigner_R, @TCustomFormDesigner_W, 'Designer');
    RegisterPropertyHelper(@TCustomFormDropTarget_R, @TCustomFormDropTarget_W, 'DropTarget');
    RegisterPropertyHelper(@TCustomFormFormState_R, nil, 'FormState');
    RegisterPropertyHelper(@TCustomFormHelpFile_R, @TCustomFormHelpFile_W, 'HelpFile');
    RegisterPropertyHelper(@TCustomFormKeyPreview_R, @TCustomFormKeyPreview_W, 'KeyPreview');
    RegisterPropertyHelper(@TCustomFormMenu_R, @TCustomFormMenu_W, 'Menu');
    RegisterPropertyHelper(@TCustomFormModalResult_R, @TCustomFormModalResult_W, 'ModalResult');
    RegisterPropertyHelper(@TCustomFormMonitor_R, nil, 'Monitor');
    RegisterPropertyHelper(@TCustomFormOleFormObject_R, @TCustomFormOleFormObject_W, 'OleFormObject');
    RegisterPropertyHelper(@TCustomFormWindowState_R, @TCustomFormWindowState_W, 'WindowState');
  end;
end;

procedure RIRegister_TFrame(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TFrame) do
  begin
  end;
end;

procedure RIRegister_TCustomFrame(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomFrame) do
  begin
  end;
end;

procedure RIRegister_TScrollBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TScrollBox) do
  begin
  end;
end;

procedure RIRegister_TScrollingWinControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TScrollingWinControl) do
  begin
    RegisterMethod(@TScrollingWinControl.DisableAutoRange, 'DisableAutoRange');
    RegisterMethod(@TScrollingWinControl.EnableAutoRange, 'EnableAutoRange');
    RegisterMethod(@TScrollingWinControl.ScrollInView, 'ScrollInView');
  end;
end;

procedure RIRegister_TControlScrollBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TControlScrollBar) do
  begin
    RegisterMethod(@TControlScrollBar.ChangeBiDiPosition, 'ChangeBiDiPosition');
    RegisterPropertyHelper(@TControlScrollBarKind_R, nil, 'Kind');
    RegisterMethod(@TControlScrollBar.IsScrollBarVisible, 'IsScrollBarVisible');
    RegisterPropertyHelper(@TControlScrollBarScrollPos_R, nil, 'ScrollPos');
  end;
end;

procedure RIRegister_Forms(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TScrollingWinControl);
  CL.Add(TCustomForm);
  CL.Add(TForm);
  CL.Add(TMonitor);
  RIRegister_TControlScrollBar(CL);
  RIRegister_TScrollingWinControl(CL);
  RIRegister_TScrollBox(CL);
  RIRegister_TCustomFrame(CL);
  RIRegister_TFrame(CL);
  RIRegister_TCustomForm(CL);
  RIRegister_TCustomActiveForm(CL);
  RIRegister_TForm(CL);
  RIRegister_TCustomDockForm(CL);
  RIRegister_TDataModule(CL);
  RIRegister_TMonitor(CL);
  RIRegister_TScreen(CL);
  RIRegister_TApplication(CL);
end;

{ TPSImport_Forms }

procedure TPSImport_Forms.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Forms(CompExec.Comp);
end;

procedure TPSImport_Forms.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Forms(ri);
  RIRegister_Forms_Routines(CompExec.Exec); // comment it if no routines
end;

end.

