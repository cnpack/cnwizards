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

unit CnCppToken;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 词法令牌
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

type
  TCnCppTokenKind = (ctkUnknown, ctkEOF, ctkIdentifier, ctkNumber,
    ctkString, ctkChar, ctkLineComment, ctkBlockComment, ctkPreprocessor,
    ctkNewLine, ctkSymbol, ctkOperator);

  TCnCppToken = class
  private
    FKind: TCnCppTokenKind;
    FText: string;
    FLine: Integer;
    FColumn: Integer;
    FPosition: Integer;
    FHadLineBreak: Boolean;
  public
    constructor Create(AKind: TCnCppTokenKind; const AText: string;
      ALine, AColumn, APosition: Integer);
    property Kind: TCnCppTokenKind read FKind write FKind;
    property Text: string read FText;
    property Line: Integer read FLine;
    property Column: Integer read FColumn;
    property Position: Integer read FPosition;
    property HadLineBreak: Boolean read FHadLineBreak write FHadLineBreak;
  end;

function CnCppIsWordToken(Token: TCnCppToken): Boolean;

function CnCppIsBinaryOperator(const S: string): Boolean;

function CnCppIsUnaryOperator(const S: string): Boolean;

implementation

constructor TCnCppToken.Create(AKind: TCnCppTokenKind; const AText: string;
  ALine, AColumn, APosition: Integer);
begin
  inherited Create;
  FKind := AKind;
  FText := AText;
  FLine := ALine;
  FColumn := AColumn;
  FPosition := APosition;
end;

function CnCppIsWordToken(Token: TCnCppToken): Boolean;
begin
  Result := (Token <> nil) and (Token.Kind in [ctkIdentifier, ctkNumber,
    ctkString, ctkChar]);
end;

function CnCppIsBinaryOperator(const S: string): Boolean;
begin
  Result := (S = '=') or (S = '+') or (S = '-') or (S = '*') or (S = '/') or
    (S = '%') or (S = '==') or (S = '!=') or (S = '<') or (S = '>') or
    (S = '<=') or (S = '>=') or (S = '&&') or (S = '||') or (S = '&') or
    (S = '|') or (S = '^') or (S = '<<') or (S = '>>') or (S = '+=') or
    (S = '-=') or (S = '*=') or (S = '/=') or (S = '%=') or (S = '&=') or
    (S = '|=') or (S = '^=') or (S = '<<=') or (S = '>>=') or
    (S = '->*') or (S = '.*');
end;

function CnCppIsUnaryOperator(const S: string): Boolean;
begin
  Result := (S = '!') or (S = '~') or (S = '++') or (S = '--');
end;

end.
