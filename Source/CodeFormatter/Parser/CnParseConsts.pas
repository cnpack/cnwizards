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

unit CnParseConsts;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：运行期错误提示资源
* 单元作者：CnPack开发组
* 备    注：运行期错误提示资源
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：should be work
* 修改记录：
*   2003-12-16 V0.1
        建立。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  CnFormatterIntf;

const
  SIdentifierExpected: PAnsiChar = 'Identifier expected';
  SStringExpected: PAnsiChar = 'String expected';
  SNumberExpected: PAnsiChar = 'Number expected';
  SCharExpected: PAnsiChar = '''''%d'''' expected';
  SSymbolExpected: PAnsiChar = '%s expected, but "%s" found';
  SParseError: PAnsiChar = '%s on line %d:%d';
  SInvalidBinary: PAnsiChar = 'Invalid binary value';
  SInvalidString: PAnsiChar = 'Invalid string constant';
  SInvalidBookmark: PAnsiChar = 'Invalid Bookmark';
  SLineTooLong: PAnsiChar = 'Line too long';
  SEndOfCommentExpected: PAnsiChar = 'Comment end ''}'' or ''*)'' expected';
  SNotSurpport: PAnsiChar = 'Not Surport %s now';

  SErrorDirective: PAnsiChar = 'Error Directive';
  SMethodHeadingExpected: PAnsiChar = 'Method head expected';
  SStructTypeExpected: PAnsiChar = 'Struct type expected';
  STypedConstantExpected: PAnsiChar = 'Typed constant expected';
  SEqualColonExpected: PAnsiChar = ' = or : expected';
  SDeclSectionExpected: PAnsiChar = 'Declare section expected';
  SProcFuncExpected: PAnsiChar = 'Procedure or function expected';
  SUnknownGoal: PAnsiChar = 'Unknown file type';
  SErrorInterface: PAnsiChar = 'Interface part error';
  SErrorStatement: PAnsiChar = 'Statement part error';

  SUnknownErrorStr: PAnsiChar = 'Unknown Error String';

type
  PPAnsiChar = ^PAnsiChar;

  TCnPascalErrorRec = packed record
    ErrorCode: Integer;
    ErrorMessage: string;
    SourceLine: Integer; // 出错时当前行，1 开始
    SourceCol: Integer;  // 出错时当前列，1 开始
    SourcePos: Integer;  // 出错时当前总偏移
    CurrentToken: string;
  end;

var
  ErrorStrings: array[CN_ERRCODE_START..CN_ERRCODE_END] of PPAnsiChar =
    (
      @SIdentifierExpected, @SStringExpected, @SNumberExpected, @SCharExpected,
      @SSymbolExpected, @SParseError, @SInvalidBinary, @SInvalidString,
      @SInvalidBookmark, @SLineTooLong, @SEndOfCommentExpected, @SNotSurpport,
      @SErrorDirective, @SMethodHeadingExpected, @SStructTypeExpected,
      @STypedConstantExpected, @SEqualColonExpected, @SDeclSectionExpected,
      @SProcFuncExpected, @SUnknownGoal, @SErrorInterface, @SErrorStatement
    );

  // 供全局设置错误信息
  PascalErrorRec: TCnPascalErrorRec = (
    ErrorCode: 0;
    ErrorMessage: '';
    SourceLine: 0;
    SourceCol: 0;
    SourcePos: 0;
    CurrentToken: '';
  );

procedure ClearPascalError;

function RetrieveFormatErrorString(const Ident: Integer): PAnsiChar;

implementation

procedure ClearPascalError;
begin
  with PascalErrorRec do
  begin
    ErrorCode := 0;
    ErrorMessage := '';
    SourceLine := 0;
    SourceCol := 0;
    SourcePos := 0;
    CurrentToken := '';
  end;
end;

function RetrieveFormatErrorString(const Ident: Integer): PAnsiChar;
begin
  if Ident in [Low(ErrorStrings)..High(ErrorStrings)] then
    Result := ErrorStrings[Ident]^
  else
    Result := SUnknownErrorStr;
end;

end.

