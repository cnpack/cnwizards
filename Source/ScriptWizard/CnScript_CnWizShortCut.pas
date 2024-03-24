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

unit CnScript_CnWizShortCut;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本类 CnWizShortCut 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 7.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2017.05.18 V1.0
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
  TPSImport_CnWizShortCut = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_TCnWizShortCutMgr(CL: TPSPascalCompiler);
procedure SIRegister_TCnKeyBinding(CL: TPSPascalCompiler);
procedure SIRegister_TCnWizShortCut(CL: TPSPascalCompiler);
procedure SIRegister_CnWizShortCut(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnWizShortCut_Routines(S: TPSExec);
procedure RIRegister_TCnWizShortCutMgr(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnKeyBinding(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnWizShortCut(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnWizShortCut(CL: TPSRuntimeClassImporter);

procedure Register;

implementation

uses
   Windows
  ,Messages
  ,Menus
  ,ExtCtrls
  ,ToolsAPI
  ,CnWizConsts
  ,CnCommon
  ,CnWizShortCut
  ;

procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_CnWizShortCut]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnWizShortCutMgr(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnWizShortCutMgr') do
  with CL.AddClassN(CL.FindClass('TObject'),'TCnWizShortCutMgr') do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Function IndexOfShortCut( AWizShortCut : TCnWizShortCut) : Integer');
    RegisterMethod('Function IndexOfName( const AName : string) : Integer');
    RegisterMethod('Function Add( const AName : string; AShortCut : TShortCut; AKeyProc : TNotifyEvent; const AMenuName : string; ATag : Integer) : TCnWizShortCut');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure DeleteShortCut( var AWizShortCut : TCnWizShortCut)');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function Updating : Boolean');
    RegisterMethod('Procedure UpdateBinding');
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('ShortCuts', 'TCnWizShortCut Integer', iptr);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnKeyBinding(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TNotifierObject', 'TCnKeyBinding') do
  with CL.AddClassN(CL.FindClass('TNotifierObject'),'TCnKeyBinding') do
  begin
    RegisterMethod('Constructor Create( AOwner : TCnWizShortCutMgr)');
    RegisterMethod('Function GetBindingType : TBindingType');
    RegisterMethod('Function GetDisplayName : string');
    RegisterMethod('Function GetName : string');
    RegisterMethod('Procedure BindKeyboard( const BindingServices : IOTAKeyBindingServices)');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnWizShortCut(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnWizShortCut') do
  with CL.AddClassN(CL.FindClass('TObject'),'TCnWizShortCut') do
  begin
    RegisterMethod('Constructor Create( AOwner : TCnWizShortCutMgr; const AName : string; AShortCut : TShortCut; AKeyProc : TNotifyEvent; const AMenuName : string; ATag : Integer)');
    RegisterProperty('Name', 'string', iptr);
    RegisterProperty('ShortCut', 'TShortCut', iptrw);
    RegisterProperty('KeyProc', 'TNotifyEvent', iptrw);
    RegisterProperty('MenuName', 'string', iptrw);
    RegisterProperty('Tag', 'Integer', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CnWizShortCut(CL: TPSPascalCompiler);
begin
  CL.AddClassN(CL.FindClass('TOBJECT'),'TCnWizShortCutMgr');
  SIRegister_TCnWizShortCut(CL);
  SIRegister_TCnKeyBinding(CL);
  SIRegister_TCnWizShortCutMgr(CL);
  CL.AddDelphiFunction('Function WizShortCutMgr : TCnWizShortCutMgr');
  // CL.AddDelphiFunction('Procedure FreeWizShortCutMgr');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutMgrShortCuts_R(Self: TCnWizShortCutMgr; var T: TCnWizShortCut; const t1: Integer);
begin T := Self.ShortCuts[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutMgrCount_R(Self: TCnWizShortCutMgr; var T: Integer);
begin T := Self.Count; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutTag_W(Self: TCnWizShortCut; const T: Integer);
begin Self.Tag := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutTag_R(Self: TCnWizShortCut; var T: Integer);
begin T := Self.Tag; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutMenuName_W(Self: TCnWizShortCut; const T: string);
begin Self.MenuName := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutMenuName_R(Self: TCnWizShortCut; var T: string);
begin T := Self.MenuName; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutKeyProc_W(Self: TCnWizShortCut; const T: TNotifyEvent);
begin Self.KeyProc := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutKeyProc_R(Self: TCnWizShortCut; var T: TNotifyEvent);
begin T := Self.KeyProc; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutShortCut_W(Self: TCnWizShortCut; const T: TShortCut);
begin Self.ShortCut := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutShortCut_R(Self: TCnWizShortCut; var T: TShortCut);
begin T := Self.ShortCut; end;

(*----------------------------------------------------------------------------*)
procedure TCnWizShortCutName_R(Self: TCnWizShortCut; var T: string);
begin T := Self.Name; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizShortCut_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@WizShortCutMgr, 'WizShortCutMgr', cdRegister);
  // S.RegisterDelphiFunction(@FreeWizShortCutMgr, 'FreeWizShortCutMgr', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnWizShortCutMgr(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnWizShortCutMgr) do
  begin
    RegisterConstructor(@TCnWizShortCutMgr.Create, 'Create');
    RegisterMethod(@TCnWizShortCutMgr.IndexOfShortCut, 'IndexOfShortCut');
    RegisterMethod(@TCnWizShortCutMgr.IndexOfName, 'IndexOfName');
    RegisterMethod(@TCnWizShortCutMgr.Add, 'Add');
    RegisterMethod(@TCnWizShortCutMgr.Delete, 'Delete');
    RegisterMethod(@TCnWizShortCutMgr.DeleteShortCut, 'DeleteShortCut');
    RegisterMethod(@TCnWizShortCutMgr.Clear, 'Clear');
    RegisterMethod(@TCnWizShortCutMgr.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TCnWizShortCutMgr.EndUpdate, 'EndUpdate');
    RegisterMethod(@TCnWizShortCutMgr.Updating, 'Updating');
    RegisterMethod(@TCnWizShortCutMgr.UpdateBinding, 'UpdateBinding');
    RegisterPropertyHelper(@TCnWizShortCutMgrCount_R,nil,'Count');
    RegisterPropertyHelper(@TCnWizShortCutMgrShortCuts_R,nil,'ShortCuts');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnKeyBinding(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnKeyBinding) do
  begin
    RegisterConstructor(@TCnKeyBinding.Create, 'Create');
    RegisterMethod(@TCnKeyBinding.GetBindingType, 'GetBindingType');
    RegisterMethod(@TCnKeyBinding.GetDisplayName, 'GetDisplayName');
    RegisterMethod(@TCnKeyBinding.GetName, 'GetName');
    RegisterMethod(@TCnKeyBinding.BindKeyboard, 'BindKeyboard');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnWizShortCut(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnWizShortCut) do
  begin
    RegisterConstructor(@TCnWizShortCut.Create, 'Create');
    RegisterPropertyHelper(@TCnWizShortCutName_R,nil,'Name');
    RegisterPropertyHelper(@TCnWizShortCutShortCut_R,@TCnWizShortCutShortCut_W,'ShortCut');
    RegisterPropertyHelper(@TCnWizShortCutKeyProc_R,@TCnWizShortCutKeyProc_W,'KeyProc');
    RegisterPropertyHelper(@TCnWizShortCutMenuName_R,@TCnWizShortCutMenuName_W,'MenuName');
    RegisterPropertyHelper(@TCnWizShortCutTag_R,@TCnWizShortCutTag_W,'Tag');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizShortCut(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnWizShortCutMgr) do
  RIRegister_TCnWizShortCut(CL);
  RIRegister_TCnKeyBinding(CL);
  RIRegister_TCnWizShortCutMgr(CL);
end;

{ TPSImport_CnWizShortCut }
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizShortCut.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizShortCut(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizShortCut.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizShortCut(ri);
  RIRegister_CnWizShortCut_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)

end.
