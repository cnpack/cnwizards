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

unit CnScript_IdeInstComp;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元注册了 IDE 中安装的所有组件
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnWizIdeUtils, CnScriptClasses,
  uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_IdeInstComp = class(TCnPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
    procedure CompOnUses1(CompExec: TPSScript); override;
  end;

  { compile-time registration functions }
procedure SIRegister_IdeInstComp(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_IdeInstComp(CL: TPSRuntimeClassImporter);

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}  

(* === compile-time registration functions === *)

procedure SIRegister_IdeInstComp(CL: TPSPascalCompiler);
var
  List: TStringList;
  i: Integer;

  function DoRegisterClass(AClass: TClass): TPSCompileTimeClass;
  begin
    Result := nil;
    if AClass <> nil then
    begin
      Result := CL.FindClass(AnsiString(UpperCase(AClass.ClassName)));
      if Result = nil then
      begin
        Result := CL.AddClass(DoRegisterClass(AClass.ClassParent), AClass);
        Result.RegisterPublishedProperties;
      end;
    end;
  end;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('SIRegister_IdeInstComp');
{$ENDIF}
  List := TStringList.Create;
  try
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetInstalledComponents');
  {$ENDIF}
    GetInstalledComponents(nil, List);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(List.Text);
  {$ENDIF}
    for i := 0 to List.Count - 1 do
    begin
      DoRegisterClass(GetClass(List[i]));
    end;
  finally
    List.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('SIRegister_IdeInstComp');
{$ENDIF}
end;

(* === run-time registration functions === *)

procedure RIRegister_IdeInstComp(CL: TPSRuntimeClassImporter);
var
  List: TStringList;
  i: Integer;

  function DoRegisterClass(AClass: TClass): TPSRuntimeClass;
  begin
    Result := nil;
    if AClass <> nil then
    begin
      Result := CL.FindClass(AnsiString(UpperCase(AClass.ClassName)));
      if Result = nil then
      begin
        DoRegisterClass(AClass.ClassParent);
        Result := CL.Add(AClass);
      end;
    end;
  end;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('RIRegister_IdeInstComp');
{$ENDIF}
  List := TStringList.Create;
  try
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetInstalledComponents');
  {$ENDIF}
    GetInstalledComponents(nil, List);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(List.Text);
  {$ENDIF}
    for i := 0 to List.Count - 1 do
    begin
      DoRegisterClass(GetClass(List[i]));
    end;  
  finally
    List.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('RIRegister_IdeInstComp');
{$ENDIF}
end;

{ TPSImport_IdeInstComp }

procedure TPSImport_IdeInstComp.CompileImport1(CompExec: TPSScript);
begin

end;

procedure TPSImport_IdeInstComp.CompOnUses1(CompExec: TPSScript);
begin
  // 由于该操作较慢，只在用户实际使用 uses IdeInstComp 时才注册
  SIRegister_IdeInstComp(CompExec.Comp);
end;

procedure TPSImport_IdeInstComp.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_IdeInstComp(ri);
end;

end.



