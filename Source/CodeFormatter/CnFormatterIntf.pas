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

unit CnFormatterIntf;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：代码格式化对外接口
* 单元作者：CnPack开发组
* 备    注：该单元实现代码格式化的对外接口
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 单元标识：$Id$
* 修改记录：2015.02.11 V1.0
*               创建单元。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows;

const
  // 遇见 IFDEF ELSE ENDIF 时的处理模式
  CN_RULE_DIRECTIVE_MODE_ASCOMMENT  = 1;
  {* 当作注释处理}
  CN_RULE_DIRECTIVE_MODE_ONLYFIRST  = 2;
  {* 只处理第一部分}
  CN_RULE_DIRECTIVE_MODE_DEFAULT    = CN_RULE_DIRECTIVE_MODE_ASCOMMENT;

  // 关键字大小写规则
  CN_RULE_KEYWORD_STYLE_UPPER       = 1;
  {* 全大写}
  CN_RULE_KEYWORD_STYLE_LOWER       = 2;
  {* 全小写}
  CN_RULE_KEYWORD_STYLE_UPPERFIRST  = 3;
  {* 首字母大写}
  CN_RULE_KEYWORD_STYLE_DEFAULT     = CN_RULE_KEYWORD_STYLE_LOWER;

  // 默认缩进空格数
  CN_RULE_TABSPACE_DEFAULT          = 2;

  // 双目运算符前的默认空格数
  CN_RULE_SPACE_BEFORE_OPERATOR      = 1;

  // 双目运算符后的默认空格数
  CN_RULE_SPACE_AFTER_OPERATOR       = 1;

  // 汇编指令行首默认缩进
  CN_RULE_SPACE_BEFORE_ASM           = 8;

  // 汇编指令 Tab 宽度
  CN_RULE_SPACE_TAB_ASM              = 8;

  // 默认换行超出此宽度
  CN_RULE_LINE_WRAP_WIDTH            = 80;

  // 由外部指定的起始元素类型
  CN_START_UNKNOWN_ALL               = 0;
  CN_START_USES                      = 1;
  CN_START_CONST                     = 2;
  CN_START_TYPE                      = 3;
  CN_START_VAR                       = 4;
  CN_START_PROC                      = 5;
  CN_START_STATEMENT                 = 6;

type
  ICnPascalFormatterIntf = interface
    ['{0CC0F874-227A-4516-9D17-6331EA86CBCA}']
    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD; TabSpace:
      DWORD; SpaceBeforeOperator: DWORD; SpaceAfterOperator: DWORD; SpaceBeforeAsm:
      DWORD; SpaceTabAsm: DWORD; LineWrapWidth: DWORD; UsesSingleLine: LongBool);
    {* 设置格式化选项}

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* 格式化一整个 Pascal 文件内容，代码以 AnsiString 格式传入。
       返回结果存储的 AnsiString 字符内容的指针，用完后无须释放}

    function FormatPascalBlock(StartType: DWORD; StartIndent: DWORD;
      Input: PAnsiChar; Len: DWORD): PAnsiChar;
    {* 格式化一块代码。需要指定起始代码类型以及起始缩进。
       代码以 AnsiString 格式传入，返回结果存储的 AnsiString 字符内容的指针，
       用完后无须释放}
  end;

  TCnGetFormatterProvider = function: ICnPascalFormatterIntf; stdcall;
  {* DLL 中的函数类型}

implementation

end.
