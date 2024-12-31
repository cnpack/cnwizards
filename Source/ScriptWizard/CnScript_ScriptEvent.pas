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

unit CnScript_ScriptEvent;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ScriptEvent 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2007.09.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Dialogs, CnScriptFrm, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_ScriptEvent = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TCnScriptFormEditorNotify(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptSourceEditorNotify(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptAfterCompile(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptBeforeCompile(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptFileNotify(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptIDELoaded(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptManual(CL: TPSPascalCompiler);
procedure SIRegister_TCnScriptEvent(CL: TPSPascalCompiler);
procedure SIRegister_ScriptEvent(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ScriptEvent_Routines(S: TPSExec);
procedure RIRegister_TCnScriptFormEditorNotify(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptSourceEditorNotify(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptAfterCompile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptBeforeCompile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptFileNotify(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptIDELoaded(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptManual(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnScriptEvent(CL: TPSRuntimeClassImporter);
procedure RIRegister_ScriptEvent(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TCnScriptFormEditorNotify(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptFormEditorNotify') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptFormEditorNotify) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptSourceEditorNotify(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptSourceEditorNotify') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptSourceEditorNotify) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptAfterCompile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptAfterCompile') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptAfterCompile) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptApplicationEventNotify(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptApplicationEventNotify') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptApplicationEventNotify) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptActiveFormChanged(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptActiveFormChanged') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptActiveFormChanged) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptBeforeCompile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptBeforeCompile') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptBeforeCompile) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptFileNotify(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptFileNotify') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptFileNotify) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptIDELoaded(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptIDELoaded') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptIDELoaded) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptManual(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnScriptEvent', 'TCnScriptManual') do
  with CL.AddClass(CL.FindClass('TCnScriptEvent'), TCnScriptManual) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCnScriptEvent(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TCnScriptEvent') do
  with CL.AddClass(CL.FindClass('TOBJECT'), TCnScriptEvent) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_ScriptEvent(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCnScriptMode', '( smManual, smIDELoaded, smFileNotify, smBefore'
    + 'Compile, smAfterCompile, smSourceEditorNotify, smFormEditorNotify, '
    + 'smApplicationEvent, smActiveFormChanged)');
  CL.AddTypeS('TCnScriptModeSet', 'set of TCnScriptMode');
  SIRegister_TCnScriptEvent(CL);
  SIRegister_TCnScriptManual(CL);
  SIRegister_TCnScriptIDELoaded(CL);
  SIRegister_TCnScriptFileNotify(CL);
  SIRegister_TCnScriptBeforeCompile(CL);
  SIRegister_TCnScriptAfterCompile(CL);
  CL.AddTypeS('TCnWizAppEventType', '( aeActivate, aeDeactivate, aeMinimize,'
    + ' aeRestore, aeHint )');
  SIRegister_TCnScriptApplicationEventNotify(CL);
  SIRegister_TCnScriptActiveFormChanged(CL);
  CL.AddTypeS('TCnWizSourceEditorNotifyType', '( setOpened, setClosing, setModi'
    + 'fied, setEditViewInsert, setEditViewRemove, setEditViewActivated )');
  SIRegister_TCnScriptSourceEditorNotify(CL);
  CL.AddTypeS('TCnWizFormEditorNotifyType', '( fetOpened, fetClosing, fetModifi'
    + 'ed, fetActivated, fetSaving, fetComponentCreating, fetComponentCreated, '
    + 'fetComponentDestorying, fetComponentRenamed )');
  SIRegister_TCnScriptFormEditorNotify(CL);
  CL.AddDelphiFunction('Function Event : TCnScriptEvent;');
end;

(* === run-time registration functions === *)

function Event_P: TCnScriptEvent;
begin
  Result := CnScriptFrm.ScriptEvent;
end;

procedure RIRegister_ScriptEvent_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Event_P, 'Event', cdRegister);
end;

procedure RIRegister_TCnScriptApplicationEventNotify(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptApplicationEventNotify) do
  begin
  end;
end;

procedure RIRegister_TCnScriptActiveFormChanged(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptActiveFormChanged) do
  begin
  end;
end;

procedure RIRegister_TCnScriptFormEditorNotify(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptFormEditorNotify) do
  begin
  end;
end;

procedure RIRegister_TCnScriptSourceEditorNotify(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptSourceEditorNotify) do
  begin
  end;
end;

procedure RIRegister_TCnScriptAfterCompile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptAfterCompile) do
  begin
  end;
end;

procedure RIRegister_TCnScriptBeforeCompile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptBeforeCompile) do
  begin
  end;
end;

procedure RIRegister_TCnScriptFileNotify(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptFileNotify) do
  begin
  end;
end;

procedure RIRegister_TCnScriptIDELoaded(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptIDELoaded) do
  begin
  end;
end;

procedure RIRegister_TCnScriptManual(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptManual) do
  begin
  end;
end;

procedure RIRegister_TCnScriptEvent(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnScriptEvent) do
  begin
  end;
end;

procedure RIRegister_ScriptEvent(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnScriptEvent(CL);
  RIRegister_TCnScriptManual(CL);
  RIRegister_TCnScriptIDELoaded(CL);
  RIRegister_TCnScriptFileNotify(CL);
  RIRegister_TCnScriptBeforeCompile(CL);
  RIRegister_TCnScriptAfterCompile(CL);
  RIRegister_TCnScriptSourceEditorNotify(CL);
  RIRegister_TCnScriptFormEditorNotify(CL);
  RIRegister_TCnScriptApplicationEventNotify(CL);
  RIRegister_TCnScriptActiveFormChanged(CL);
end;

{ TPSImport_ScriptEvent }

procedure TPSImport_ScriptEvent.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ScriptEvent(CompExec.Comp);
end;

procedure TPSImport_ScriptEvent.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ScriptEvent(ri);
  RIRegister_ScriptEvent_Routines(CompExec.Exec); // comment it if no routines
end;

end.

