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

unit CnScript_CnWizClasses;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本类 CnWizClasses 注册类，有部分 CnWizManager 内容
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 7.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.05.22 V1.0
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
  TPSImport_CnWizClasses = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TCnDesignSelectionExecutor2(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
procedure RIRegister_TCnDesignSelectionExecutor2(CL: TPSRuntimeClassImporter);

implementation

uses
   Windows
  ,Graphics
  ,Menus
  ,ActnList
  ,IniFiles
  ,ToolsAPI
  ,Registry
  ,ComCtrls
  ,Forms
  ,CnWizShortCut
  ,CnWizMenuAction
  ,CnIni
  ,CnWizConsts
  ,CnPopupMenu
  ,CnWizClasses
  ,CnWizManager
  ;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnDesignSelectionExecutor2(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnDesignSelectionExecutor', 'TCnDesignSelectionExecutor2') do
  with CL.AddClassN(CL.FindClass('TCnDesignSelectionExecutor'),'TCnDesignSelectionExecutor2') do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('OnExecute', 'TNotifyEvent', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CnWizClasses(CL: TPSPascalCompiler);
begin
  SIRegister_TCnDesignSelectionExecutor2(CL);
  CL.AddDelphiFunction('Procedure RegisterDesignSelectionExecutor2( Executor : TCnDesignSelectionExecutor2)');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2OnExecute_W(Self: TCnDesignSelectionExecutor2; const T: TNotifyEvent);
begin Self.OnExecute := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2OnExecute_R(Self: TCnDesignSelectionExecutor2; var T: TNotifyEvent);
begin T := Self.OnExecute; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Enabled_W(Self: TCnDesignSelectionExecutor2; const T: Boolean);
begin Self.Enabled := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Enabled_R(Self: TCnDesignSelectionExecutor2; var T: Boolean);
begin T := Self.Enabled; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Active_W(Self: TCnDesignSelectionExecutor2; const T: Boolean);
begin Self.Active := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Active_R(Self: TCnDesignSelectionExecutor2; var T: Boolean);
begin T := Self.Active; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Hint_W(Self: TCnDesignSelectionExecutor2; const T: string);
begin Self.Hint := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Hint_R(Self: TCnDesignSelectionExecutor2; var T: string);
begin T := Self.Hint; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Caption_W(Self: TCnDesignSelectionExecutor2; const T: string);
begin Self.Caption := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnDesignSelectionExecutor2Caption_R(Self: TCnDesignSelectionExecutor2; var T: string);
begin T := Self.Caption; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@RegisterDesignSelectionExecutor2, 'RegisterDesignSelectionExecutor2', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnDesignSelectionExecutor2(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnDesignSelectionExecutor2) do
  begin
    RegisterVirtualConstructor(@TCnDesignSelectionExecutor2.Create, 'Create');
    RegisterPropertyHelper(@TCnDesignSelectionExecutor2Caption_R,@TCnDesignSelectionExecutor2Caption_W,'Caption');
    RegisterPropertyHelper(@TCnDesignSelectionExecutor2Hint_R,@TCnDesignSelectionExecutor2Hint_W,'Hint');
    RegisterPropertyHelper(@TCnDesignSelectionExecutor2Active_R,@TCnDesignSelectionExecutor2Active_W,'Active');
    RegisterPropertyHelper(@TCnDesignSelectionExecutor2Enabled_R,@TCnDesignSelectionExecutor2Enabled_W,'Enabled');
    RegisterPropertyHelper(@TCnDesignSelectionExecutor2OnExecute_R,@TCnDesignSelectionExecutor2OnExecute_W,'OnExecute');
  end;
end;


(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnDesignSelectionExecutor2(CL);
end;

 
 
{ TPSImport_CnWizClasses }
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizClasses(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizClasses(ri);
  RIRegister_CnWizClasses_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)
 
 
end.