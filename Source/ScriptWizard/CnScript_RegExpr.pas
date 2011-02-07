{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnScript_RegExpr;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 RegExpr 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id: CnScript_CnWizIdeUtils.pas 418 2010-02-08 04:53:54Z zhoujingyu $
* 修改记录：2010.05.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$DEFINE UniCode}

uses
  Windows, SysUtils, Classes, RegExpr, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_RegExpr = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_RegExpr(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_RegExpr_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_RegExpr(CL: TPSPascalCompiler);
begin
{$IFDEF UniCode}
  CL.AddTypeS('RegExprString', 'WideString');
{$ELSE}
  CL.AddTypeS('RegExprString', 'AnsiString');
{$ENDIF}
  CL.AddDelphiFunction('Function ExecRegExpr( const ARegExpr, AInputStr : RegExprString) : boolean');
  CL.AddDelphiFunction('Procedure SplitRegExpr( const ARegExpr, AInputStr : RegExprString; APieces : TStrings)');
  CL.AddDelphiFunction('Function ReplaceRegExpr( const ARegExpr, AInputStr, AReplaceStr : RegExprString; AUseSubstitution : boolean) : RegExprString');
  CL.AddDelphiFunction('Function QuoteRegExprMetaChars( const AStr : RegExprString) : RegExprString');
  CL.AddDelphiFunction('Function RegExprSubExpressions( const ARegExpr : string; ASubExprs : TStrings; AExtendedSyntax : boolean) : integer');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure RIRegister_RegExpr_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@ExecRegExpr, 'ExecRegExpr', cdRegister);
  S.RegisterDelphiFunction(@SplitRegExpr, 'SplitRegExpr', cdRegister);
  S.RegisterDelphiFunction(@ReplaceRegExpr, 'ReplaceRegExpr', cdRegister);
  S.RegisterDelphiFunction(@QuoteRegExprMetaChars, 'QuoteRegExprMetaChars', cdRegister);
  S.RegisterDelphiFunction(@RegExprSubExpressions, 'RegExprSubExpressions', cdRegister);
end;

 
 
{ TPSImport_RegExpr }
(*----------------------------------------------------------------------------*)
procedure TPSImport_RegExpr.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_RegExpr(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_RegExpr.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_RegExpr_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)

end.

