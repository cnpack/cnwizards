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

unit CnCodeFormatterImpl;
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
  CnFormatterIntf, SysUtils, Classes, Windows;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;

exports
  GetCodeFormatterProvider;

implementation

uses
  CnCodeFormatter;

type
  TCnCodeFormatProvider = class(TInterfacedObject, ICnPascalFormatterIntf)
  private
    FResult: PAnsiChar;
    procedure AdjustResultLength(Len: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD; TabSpace:
      DWORD; SpaceBeforeOperator: DWORD; SpaceAfterOperator: DWORD; SpaceBeforeAsm:
      DWORD; SpaceTabAsm: DWORD; LineWrapWidth: DWORD; UsesSingleLine: LongBool);

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;

    function FormatPascalBlock(StartType: DWORD; StartIndent: DWORD;
      Input: PAnsiChar; Len: DWORD): PAnsiChar;
  end;

var
  FCodeFormatProvider: TCnCodeFormatProvider = nil;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;
begin
  if FCodeFormatProvider = nil then
    FCodeFormatProvider := TCnCodeFormatProvider.Create;
  Result := FCodeFormatProvider;
end;

{ FCodeFormatProvider }

procedure TCnCodeFormatProvider.AdjustResultLength(Len: DWORD);
begin
  if FResult <> nil then
  begin
    StrDispose(FResult);
    FResult := nil;
  end;

  if Len > 0 then
  begin
    FResult := StrAlloc(Len);
    ZeroMemory(FResult, Len);
  end;
end;

constructor TCnCodeFormatProvider.Create;
begin
  inherited;
  
end;

destructor TCnCodeFormatProvider.Destroy;
begin
  AdjustResultLength(0);
  inherited;
end;

function TCnCodeFormatProvider.FormatPascalBlock(StartType, StartIndent: DWORD;
  Input: PAnsiChar; Len: DWORD): PAnsiChar;
begin
  AdjustResultLength(0);
  Result := FResult;
end;

function TCnCodeFormatProvider.FormatOnePascalUnit(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
var
  Stream: TStream;
  CodeFor: TCnPascalCodeFormatter;
begin
  AdjustResultLength(0);
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  Stream := TMemoryStream.Create;
  Stream.Write(Input^, Len);
  CodeFor := TCnPascalCodeFormatter.Create(Stream);

  try
    try
      CodeFor.FormatCode;
    finally
      CodeFor.SaveToStream(Stream);
    end;

    if Stream.Size > 0 then
    begin
      AdjustResultLength(Stream.Size + 1);
      Stream.Position := 0;
      Stream.Read(FResult^, Stream.Size);
    end;
  finally
    Stream.Free;
    CodeFor.Free;
  end;
  Result := FResult;
end;

procedure TCnCodeFormatProvider.SetPascalFormatRule(DirectiveMode, KeywordStyle,
  TabSpace, SpaceBeforeOperator, SpaceAfterOperator, SpaceBeforeAsm,
  SpaceTabAsm, LineWrapWidth: DWORD; UsesSingleLine: LongBool);
begin

end;

initialization

finalization
  FreeAndNil(FCodeFormatProvider);

end.
