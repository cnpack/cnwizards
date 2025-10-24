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

unit CnScript_AsRegExpr;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ű���չ AsRegExpr ע����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�� UnitParser v0.7 �Զ����ɵ��ļ��޸Ķ���
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2010.05.11 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$DEFINE UNICODE}

uses
  Windows, SysUtils, Classes, AsRegExpr, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_AsRegExpr = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_AsRegExpr(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_AsRegExpr_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_AsRegExpr(CL: TPSPascalCompiler);
begin
{$IFDEF UNICODE}
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
procedure RIRegister_AsRegExpr_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@ExecRegExpr, 'ExecRegExpr', cdRegister);
  S.RegisterDelphiFunction(@SplitRegExpr, 'SplitRegExpr', cdRegister);
  S.RegisterDelphiFunction(@ReplaceRegExpr, 'ReplaceRegExpr', cdRegister);
  S.RegisterDelphiFunction(@QuoteRegExprMetaChars, 'QuoteRegExprMetaChars', cdRegister);
  S.RegisterDelphiFunction(@RegExprSubExpressions, 'RegExprSubExpressions', cdRegister);
end;

 
 
{ TPSImport_AsRegExpr }
(*----------------------------------------------------------------------------*)
procedure TPSImport_AsRegExpr.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_AsRegExpr(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_AsRegExpr.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_AsRegExpr_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)

end.

