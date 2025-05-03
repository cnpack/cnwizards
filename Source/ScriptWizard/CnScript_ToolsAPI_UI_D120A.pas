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

unit CnScript_ToolsAPI_UI_D120A;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ToolsAPI.UI 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWin7 + Delphi
* 兼容测试：PWin7/10 + Delphi
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2025.05.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;

type
(*----------------------------------------------------------------------------*)
  TPSImport_ToolsAPI_UI = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_INTAIDEUIServices(CL: TPSPascalCompiler);
procedure SIRegister_INTAIDEUIServices290(CL: TPSPascalCompiler);
procedure SIRegister_ToolsAPI_UI(CL: TPSPascalCompiler);

{ run-time registration functions }

procedure Register;

implementation


uses
   Graphics
  ,Forms
  ,Dialogs
  ,Vcl.TitleBarCtrls
  ,ToolsAPI.UI
  ;


procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_ToolsAPI_UI]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAIDEUIServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAIDEUIServices290', 'INTAIDEUIServices') do
  with CL.AddInterface(CL.FindInterface('INTAIDEUIServices290'),INTAIDEUIServices, 'INTAIDEUIServices') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAIDEUIServices290(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAIDEUIServices290') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAIDEUIServices290, 'INTAIDEUIServices290') do
  begin
    RegisterMethod('Function GetThemeAwareColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetDarkColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetGenericColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Function GetLightColor( ITC : TIDEThemeColors) : TColor', cdRegister);
    RegisterMethod('Procedure SetupTitleBar( AForm : TCustomForm; ATitleBar : TTitleBarPanel; InsertRootPanel : Boolean)', cdRegister);
    RegisterMethod('Function MessageDlg( const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;', cdRegister);
    RegisterMethod('Function MessageDlg1( const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint; DefaultButton : TMsgDlgBtn) : Integer;', cdRegister);
    RegisterMethod('Function InputBox( const ACaption, APrompt, ADefault : string) : string', cdRegister);
    RegisterMethod('Function InputQuery( const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryFunc : TInputCloseQueryFunc) : Boolean;', cdRegister);
    RegisterMethod('Function InputQuery1( const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryEvent : TInputCloseQueryEvent; Context : TObject) : Boolean;', cdRegister);
    RegisterMethod('Function InputQuery2( const ACaption, APrompt : string; var Value : string) : Boolean;', cdRegister);
    RegisterMethod('Procedure ShowMessage( const Msg : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_ToolsAPI_UI(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TIDEThemeColors', '( itcBlue, itcRed, itcYellow, itcGreen, itcVi'
   +'olet, itcGray, itcOrange )');
  SIRegister_INTAIDEUIServices290(CL);
  SIRegister_INTAIDEUIServices(CL);
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery2_P(Self: INTAIDEUIServices290;  const ACaption, APrompt : string; var Value : string) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompt, Value); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery1_P(Self: INTAIDEUIServices290;  const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryEvent : TInputCloseQueryEvent; Context : TObject) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompts, AValues, CloseQueryEvent, Context); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290InputQuery_P(Self: INTAIDEUIServices290;  const ACaption : string; const APrompts : array of string; var AValues : array of string; const CloseQueryFunc : TInputCloseQueryFunc) : Boolean;
Begin Result := Self.InputQuery(ACaption, APrompts, AValues, CloseQueryFunc); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290MessageDlg1_P(Self: INTAIDEUIServices290;  const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint; DefaultButton : TMsgDlgBtn) : Integer;
Begin Result := Self.MessageDlg(Msg, DlgType, Buttons, HelpCtx, DefaultButton); END;

(*----------------------------------------------------------------------------*)
Function INTAIDEUIServices290MessageDlg_P(Self: INTAIDEUIServices290;  const Msg : string; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;
Begin Result := Self.MessageDlg(Msg, DlgType, Buttons, HelpCtx); END;



{ TPSImport_ToolsAPI_UI }
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_UI.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI_UI(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_UI.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
end;
(*----------------------------------------------------------------------------*)


end.
