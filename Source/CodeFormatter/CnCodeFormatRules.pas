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

unit CnCodeFormatRules;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：代码格式化规则
* 单元作者：CnPack开发组
* 备    注：该单元实现代码格式化规则
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2003.12.16 V0.1
*               建立。目前包括 缩进空格数、操作符前后空格数、关键字大小写 的设置。
                代码风格未实现。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

type
  TCnCodeStyle = (fsNone);

  TCnCodeStyles = set of TCnCodeStyle;

  TCnKeywordStyle = (ksLowerCaseKeyword, ksUpperCaseKeyword, ksPascalKeyword, ksNoChange);

  TCnBeginStyle = (bsNextLine, bsSameLine);

  TCnCodeWrapMode = (cwmNone, cwmSimple, cwmAdvanced);
  {* 代码换行的设置，不自动换行、简单的超过就换行，高级的超过多了才从少的地方换行}

  TCnTypeIDStyle = (tisUpperFirst, tisNoChange); // 类型标识符的处理方式，首字母大写或不变

  TCnCompDirectiveMode = (cdmAsComment, cdmOnlyFirst, cdmNone); // None 表示扔给外面处理

  TCnPascalCodeFormatRule = record
    ContinueAfterError: Boolean;
    CodeStyle: TCnCodeStyles;

    CompDirectiveMode: TCnCompDirectiveMode;  // 此项不开放
    KeywordStyle: TCnKeywordStyle;
    BeginStyle: TCnBeginStyle;
    CodeWrapMode: TCnCodeWrapMode;
    TypeIDStyle: TCnTypeIDStyle;    // 此项无法处理标识符内的分词，意义不大，暂不对外开放
    TabSpaceCount: Byte;
    SpaceBeforeOperator: Byte;
    SpaceAfterOperator: Byte;
    SpaceBeforeASM: Byte;
    SpaceTabASMKeyword: Byte;
    WrapWidth: Integer;
    WrapNewLineWidth: Integer;
    UsesUnitSingleLine: Boolean;
    SingleStatementToBlock: Boolean; // if while for case 等单个语句是否加 begin end，也暂不对外开放
    UseIgnoreArea: Boolean;
    UsesLineWrapWidth: Integer;
    KeepUserLineBreak: Boolean;
  end;

const
  CnPascalCodeForVCLRule: TCnPascalCodeFormatRule =
  (
    ContinueAfterError: False;
    CodeStyle: [];

    CompDirectiveMode: cdmAsComment;
    KeywordStyle: ksLowerCaseKeyword;
    BeginStyle: bsNextLine;
    CodeWrapMode: cwmNone;
    TypeIDStyle: tisNoChange;
    TabSpaceCount: 2;
    SpaceBeforeOperator: 1;
    SpaceAfterOperator: 1;
    SpaceBeforeASM: 8;
    SpaceTabASMKeyword: 8;
    WrapWidth: 80;
    WrapNewLineWidth: 90;
    UsesUnitSingleLine: False;
    SingleStatementToBlock: False;
    UseIgnoreArea: True;
    UsesLineWrapWidth: 90;
    KeepUserLineBreak: False;
  );

var
  CnPascalCodeForRule: TCnPascalCodeFormatRule;

implementation

initialization
  // Default Setting
  CnPascalCodeForRule := CnPascalCodeForVCLRule;

end.
