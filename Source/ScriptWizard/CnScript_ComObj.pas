{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnScript_ComObj;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ComObj 注册类
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
  Windows, SysUtils, ComObj, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_ComObj = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_ComObj(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ComObj_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_ComObj(CL: TPSPascalCompiler);
begin
  CL.AddDelphiFunction('Function CreateComObject( const ClassID : TGUID) : IUnknown');
  CL.AddDelphiFunction('Function CreateRemoteComObject( const MachineName : WideString; const ClassID : TGUID) : IUnknown');
  CL.AddDelphiFunction('Function CreateOleObject( const ClassName : string) : IDispatch');
  CL.AddDelphiFunction('Function GetActiveOleObject( const ClassName : string) : IDispatch');
  CL.AddDelphiFunction('Procedure OleError( ErrorCode : HResult)');
  CL.AddDelphiFunction('Procedure OleCheck( Result : HResult)');
  CL.AddDelphiFunction('Function StringToGUID( const S : string) : TGUID');
  CL.AddDelphiFunction('Function GUIDToString( const ClassID : TGUID) : string');
  CL.AddDelphiFunction('Function ProgIDToClassID( const ProgID : string) : TGUID');
  CL.AddDelphiFunction('Function ClassIDToProgID( const ClassID : TGUID) : string');
  CL.AddDelphiFunction('Procedure CreateRegKey( const Key, ValueName, Value : string)');
  CL.AddDelphiFunction('Procedure DeleteRegKey( const Key : string)');
  CL.AddDelphiFunction('Function GetRegStringValue( const Key, ValueName : string) : string');
  CL.AddDelphiFunction('Function CreateClassID : string');
end;

(* === run-time registration functions === *)

procedure RIRegister_ComObj_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@CreateComObject, 'CreateComObject', cdRegister);
  S.RegisterDelphiFunction(@CreateRemoteComObject, 'CreateRemoteComObject', cdRegister);
  S.RegisterDelphiFunction(@CreateOleObject, 'CreateOleObject', cdRegister);
  S.RegisterDelphiFunction(@GetActiveOleObject, 'GetActiveOleObject', cdRegister);
  S.RegisterDelphiFunction(@OleError, 'OleError', cdRegister);
  S.RegisterDelphiFunction(@OleCheck, 'OleCheck', cdRegister);
  S.RegisterDelphiFunction(@StringToGUID, 'StringToGUID', cdRegister);
  S.RegisterDelphiFunction(@GUIDToString, 'GUIDToString', cdRegister);
  S.RegisterDelphiFunction(@ProgIDToClassID, 'ProgIDToClassID', cdRegister);
  S.RegisterDelphiFunction(@ClassIDToProgID, 'ClassIDToProgID', cdRegister);
  S.RegisterDelphiFunction(@CreateRegKey, 'CreateRegKey', cdRegister);
  S.RegisterDelphiFunction(@DeleteRegKey, 'DeleteRegKey', cdRegister);
  S.RegisterDelphiFunction(@GetRegStringValue, 'GetRegStringValue', cdRegister);
  S.RegisterDelphiFunction(@CreateClassID, 'CreateClassID', cdRegister);
end;

{ TPSImport_ComObj }

procedure TPSImport_ComObj.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ComObj(CompExec.Comp);
end;

procedure TPSImport_ComObj.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ComObj_Routines(CompExec.Exec); // comment it if no routines
end;

end.

