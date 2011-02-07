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

unit RegExpr;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 RegExpr 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：
* 本 地 化：
* 单元标识：$Id: ScriptEvent.pas 418 2010-02-08 04:53:54Z zhoujingyu $
* 修改记录：2010.05.11 V1.0
*               创建单元
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

