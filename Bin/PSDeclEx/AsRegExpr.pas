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

unit AsRegExpr;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ڽű���ʹ�õ� AsRegExpr ��Ԫ����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�
* �� �� ����
* �޸ļ�¼��2010.05.11 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

{
 This is a declare unit for CnScript. The original file is RegExpr:

     TRegExpr class library
     Delphi Regular Expressions

 Copyright (c) 1999-2004 Andrey V. Sorokin, St.Petersburg, Russia
}

interface

uses
  Windows, Messages, Classes, SysUtils;

type
 {$IFDEF UniCode}
 RegExprString = WideString;
 {$ELSE}
 RegExprString = AnsiString; //###0.952 was string
 {$ENDIF}

function ExecRegExpr (const ARegExpr, AInputStr : RegExprString) : boolean;
// true if string AInputString match regular expression ARegExpr
// ! will raise exeption if syntax errors in ARegExpr

procedure SplitRegExpr (const ARegExpr, AInputStr : RegExprString; APieces : TStrings);
// Split AInputStr into APieces by r.e. ARegExpr occurencies

function ReplaceRegExpr (const ARegExpr, AInputStr, AReplaceStr : RegExprString;
      AUseSubstitution : boolean{$IFDEF DefParam}= False{$ENDIF}) : RegExprString; //###0.947
// Returns AInputStr with r.e. occurencies replaced by AReplaceStr
// If AUseSubstitution is true, then AReplaceStr will be used
// as template for Substitution methods.
// For example:
//  ReplaceRegExpr ('({-i}block|var)\s*\(\s*([^ ]*)\s*\)\s*',
//   'BLOCK( test1)', 'def "$1" value "$2"', True)
//  will return:  def 'BLOCK' value 'test1'
//  ReplaceRegExpr ('({-i}block|var)\s*\(\s*([^ ]*)\s*\)\s*',
//   'BLOCK( test1)', 'def "$1" value "$2"')
//   will return:  def "$1" value "$2"

function QuoteRegExprMetaChars (const AStr : RegExprString) : RegExprString;
// Replace all metachars with its safe representation,
// for example 'abc$cd.(' converts into 'abc\$cd\.\('
// This function usefull for r.e. autogeneration from
// user input

function RegExprSubExpressions (const ARegExpr : string;
 ASubExprs : TStrings; AExtendedSyntax : boolean{$IFDEF DefParam}= False{$ENDIF}) : integer;
// Makes list of subexpressions found in ARegExpr r.e.
// In ASubExps every item represent subexpression,
// from first to last, in format:
//  String - subexpression text (without '()')
//  low word of Object - starting position in ARegExpr, including '('
//   if exists! (first position is 1)
//  high word of Object - length, including starting '(' and ending ')'
//   if exist!
// AExtendedSyntax - must be True if modifier /m will be On while
// using the r.e.
// Usefull for GUI editors of r.e. etc (You can find example of using
// in TestRExp.dpr project)
// Returns
//  0      Success. No unbalanced brackets was found;
//  -1     There are not enough closing brackets ')';
//  -(n+1) At position n was found opening '[' without  //###0.942
//         corresponding closing ']';
//  n      At position n was found closing bracket ')' without
//         corresponding opening '('.
// If Result <> 0, then ASubExpr can contain empty items or illegal ones

implementation

function ExecRegExpr (const ARegExpr, AInputStr : RegExprString) : boolean;
begin

end;

procedure SplitRegExpr (const ARegExpr, AInputStr : RegExprString; APieces : TStrings);
begin

end;

function ReplaceRegExpr (const ARegExpr, AInputStr, AReplaceStr : RegExprString;
      AUseSubstitution : boolean{$IFDEF DefParam}= False{$ENDIF}) : RegExprString; //###0.947
begin

end;

function QuoteRegExprMetaChars (const AStr : RegExprString) : RegExprString;
begin

end;

function RegExprSubExpressions (const ARegExpr : string;
 ASubExprs : TStrings; AExtendedSyntax : boolean{$IFDEF DefParam}= False{$ENDIF}) : integer;
begin

end;

end.

