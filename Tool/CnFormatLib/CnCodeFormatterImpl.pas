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

unit CnCodeFormatterImpl;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：代码格式化对外接口
* 单元作者：CnPack开发组
* 备    注：该单元实现代码格式化的对外接口，Ansi 版供 D5~7 使用
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
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
  CnCodeFormatter, CnParseConsts, CnCodeFormatRules {$IFDEF DEBUG} , CnDebug {$ENDIF} ;

type
  TCnCodeFormatProvider = class(TInterfacedObject, ICnPascalFormatterIntf)
  private
    FResult: PAnsiChar;
    procedure AdjustResultLength(Len: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD;
      BeginStyle: DWORD; WrapMode: DWORD; TabSpace: DWORD; SpaceBeforeOperator: DWORD;
      SpaceAfterOperator: DWORD; SpaceBeforeAsm: DWORD; SpaceTabAsm: DWORD;
      LineWrapWidth: DWORD; NewLineWrapWidth: DWORD; UsesSingleLine: LongBool;
      UseIgnoreArea: LongBool; UsesLineWrapWidth: DWORD; KeepUserLineBreak: LongBool);
    procedure SetPreIdentifierNames(Names: PLPSTR);
    procedure SetInputLineMarks(Marks: PDWORD);

    function FormatOnePascalUnit(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    function FormatOnePascalUnitUtf8(Input: PAnsiChar; Len: DWORD): PAnsiChar;
    function FormatOnePascalUnitW(Input: PWideChar; Len: DWORD): PWideChar;

    function FormatPascalBlock(Input: PAnsiChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PAnsiChar;
    function FormatPascalBlockUtf8(Input: PAnsiChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PAnsiChar;
    function FormatPascalBlockW(Input: PWideChar; Len: DWORD; StartOffset: DWORD;
      EndOffset: DWORD): PWideChar;

    function RetrieveOutputLinkMarks: PDWORD;

    function RetrievePascalLastError(out SourceLine: Integer; out SourceCol: Integer;
      out SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
  end;

var
  FCodeFormatProvider: ICnPascalFormatterIntf = nil;
  FPreNameList: TStrings = nil;

  FInputLineMarks: PDWORD = nil;
  FOutputLineMarks: PDWORD = nil;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;
begin
  if FCodeFormatProvider = nil then
    FCodeFormatProvider := TCnCodeFormatProvider.Create;
  Result := FCodeFormatProvider;
end;

procedure ClearInputLineMarks;
begin
  if FInputLineMarks <> nil then
  begin
    FreeMemory(FInputLineMarks);
    FInputLineMarks := nil;
  end;
end;

procedure ClearOutputLineMarks;
begin
  if FOutputLineMarks <> nil then
  begin
    FreeMemory(FOutputLineMarks);
    FOutputLineMarks := nil;
  end;
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

function TCnCodeFormatProvider.FormatOnePascalUnit(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
var
  InStream, OutStream: TMemoryStream;
  CodeFor: TCnPascalCodeFormatter;
  ResPtr: PAnsiChar;
begin
  AdjustResultLength(0);
  ClearPascalError;
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write(Input^, Len);
  CodeFor := TCnPascalCodeFormatter.Create(InStream, CN_MATCHED_INVALID, CN_MATCHED_INVALID,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);

  try
    try
      CodeFor.FormatCode;
      CodeFor.SaveToStream(OutStream);
    except
      ; // 出错了，返回 nil 的结果
    end;

    // GetTextStr 会导致在输出 Strings 最后一行是回车换行时又多出个回车换行，移除
    if OutStream.Size >= 4 * SizeOf(Char) then
    begin
      ResPtr := PAnsiChar(Integer(OutStream.Memory) + OutStream.Size - 4);
      if (ResPtr[0] = #13) and (ResPtr[1] = #10) and (ResPtr[2] = #13) and (ResPtr[3] = #10) then
        OutStream.Size := OutStream.Size - 2 * SizeOf(Char); 
    end;

    if OutStream.Size > 0 then
    begin
      AdjustResultLength(OutStream.Size + SizeOf(Char));
      OutStream.Position := 0;
      OutStream.Read(FResult^, OutStream.Size);
    end;

    ClearOutputLineMarks;
    CodeFor.SaveOutputLineMarks(FOutputLineMarks);
  finally
    CodeFor.Free;
    InStream.Free;
    OutStream.Free;
  end;
  Result := FResult;
end;

procedure TCnCodeFormatProvider.SetPascalFormatRule(DirectiveMode, KeywordStyle,
  BeginStyle, WrapMode, TabSpace, SpaceBeforeOperator, SpaceAfterOperator, SpaceBeforeAsm,
  SpaceTabAsm, LineWrapWidth, NewLineWrapWidth: DWORD; UsesSingleLine, UseIgnoreArea: LongBool;
  UsesLineWrapWidth: DWORD; KeepUserLineBreak: LongBool);
begin
  case DirectiveMode of
    CN_RULE_DIRECTIVE_MODE_ASCOMMENT:
      CnPascalCodeForRule.CompDirectiveMode := cdmAsComment;
    CN_RULE_DIRECTIVE_MODE_ONLYFIRST:
      CnPascalCodeForRule.CompDirectiveMode := cdmOnlyFirst;
  end;

  case KeywordStyle of
    CN_RULE_KEYWORD_STYLE_UPPER:
      CnPascalCodeForRule.KeywordStyle := ksUpperCaseKeyword;
    CN_RULE_KEYWORD_STYLE_LOWER:
      CnPascalCodeForRule.KeywordStyle := ksLowerCaseKeyword;
    CN_RULE_KEYWORD_STYLE_UPPERFIRST:
      CnPascalCodeForRule.KeywordStyle := ksPascalKeyword;
    CN_RULE_KEYWORD_STYLE_NOCHANGE:
      CnPascalCodeForRule.KeywordStyle := ksNoChange;
  end;

  case BeginStyle of
    CN_RULE_BEGIN_STYLE_NEXTLINE:
      CnPascalCodeForRule.BeginStyle := bsNextLine;
    CN_RULE_BEGIN_STYLE_SAMELINE:
      CnPascalCodeForRule.BeginStyle := bsSameLine;
  end;

  case WrapMode of
    CN_RULE_CODE_WRAP_MODE_NONE:
      CnPascalCodeForRule.CodeWrapMode := cwmNone;
    CN_RULE_CODE_WRAP_MODE_SIMPLE:
      CnPascalCodeForRule.CodeWrapMode := cwmSimple;
    CN_RULE_CODE_WRAP_MODE_ADVANCED:
      CnPascalCodeForRule.CodeWrapMode := cwmAdvanced;
  end;
  
  CnPascalCodeForRule.TabSpaceCount := TabSpace;
  CnPascalCodeForRule.SpaceBeforeOperator := SpaceBeforeOperator;
  CnPascalCodeForRule.SpaceAfterOperator := SpaceAfterOperator;
  CnPascalCodeForRule.SpaceBeforeASM := SpaceBeforeAsm;
  CnPascalCodeForRule.SpaceTabASMKeyword := SpaceTabAsm;
  CnPascalCodeForRule.WrapWidth := LineWrapWidth;
  CnPascalCodeForRule.WrapNewLineWidth := NewLineWrapWidth;
  CnPascalCodeForRule.UsesUnitSingleLine := UsesSingleLine;
  CnPascalCodeForRule.UseIgnoreArea := UseIgnoreArea;
  CnPascalCodeForRule.UsesLineWrapWidth := UsesLineWrapWidth;
  CnPascalCodeForRule.KeepUserLineBreak := KeepUserLineBreak;
end;

function TCnCodeFormatProvider.RetrievePascalLastError(out SourceLine, SourceCol,
  SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
begin
  Result := PascalErrorRec.ErrorCode;
  SourceLine := PascalErrorRec.SourceLine;
  SourceCol := PascalErrorRec.SourceCol;
  SourcePos := PascalErrorRec.SourcePos;
  CurrentToken := PAnsiChar(PascalErrorRec.CurrentToken);
end;

function TCnCodeFormatProvider.FormatOnePascalUnitUtf8(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := FResult;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
end;

function TCnCodeFormatProvider.FormatOnePascalUnitW(Input: PWideChar;
  Len: DWORD): PWideChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := nil;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
end;

function TCnCodeFormatProvider.FormatPascalBlockUtf8(Input: PAnsiChar; Len,
  StartOffset, EndOffset: DWORD): PAnsiChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := FResult;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
end;

function TCnCodeFormatProvider.FormatPascalBlockW(Input: PWideChar; Len,
  StartOffset, EndOffset: DWORD): PWideChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := nil;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
end;

function TCnCodeFormatProvider.FormatPascalBlock(Input: PAnsiChar; Len,
  StartOffset, EndOffset: DWORD): PAnsiChar;
var
  InStream, OutStream: TStream;
  CodeFor: TCnPascalCodeFormatter;
  Res: string;
begin
  ClearPascalError;
  AdjustResultLength(0);
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Start %d, End %d', [StartOffset, EndOffset]);
  CnDebugger.LogRawString(Copy(Input, StartOffset + 1, EndOffset - StartOffset));
{$ENDIF}

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write(Input^, Len);
  // Formatter 内部的偏移量以 0 开始，而传入的 Offset 也以 0 开始，无需转换
  CodeFor := TCnPascalCodeFormatter.Create(InStream, StartOffset, EndOffset,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);
  CodeFor.SliceMode := True;

  try
    try
      CodeFor.FormatCode;
    except
      ; // 出错了，先屏蔽，看看后面有无结果
    end;

    Res := CodeFor.CopyMatchedSliceResult;
    if Res = '' then
    begin
      Result := nil;
      Exit;
    end;

    ClearOutputLineMarks;
    CodeFor.SaveOutputLineMarks(FOutputLineMarks);

    OutStream.Write(PChar(Res)^, Length(Res));
    if OutStream.Size > 0 then
    begin
      AdjustResultLength(OutStream.Size + SizeOf(Char));
      OutStream.Position := 0;
      OutStream.Read(FResult^, OutStream.Size);
    end;
  finally
    CodeFor.Free;
    InStream.Free;
    OutStream.Free;
  end;
  Result := FResult;
end;

procedure TCnCodeFormatProvider.SetPreIdentifierNames(Names: PLPSTR);
var
  S: string;
begin
  if FPreNameList = nil then
    FPreNameList := TStringList.Create
  else
    FPreNameList.Clear;

  if Names <> nil then
  begin
    while Names^ <> nil do
    begin
      S := StrNew(Names^);
      FPreNameList.Add(S);
      Inc(Names);
    end;
  end;
end;

function TCnCodeFormatProvider.RetrieveOutputLinkMarks: PDWORD;
begin
  Result := FOutputLineMarks;
end;

procedure TCnCodeFormatProvider.SetInputLineMarks(Marks: PDWORD);
var
  Len: Integer;
  M: PDWORD;
begin
  ClearInputLineMarks;
  if (Marks <> nil) and (Marks^ <> 0) then
  begin
    M := Marks;
    Len := 0;

    while M^ <> 0 do
    begin
      Inc(Len);
      Inc(M);
    end;

    // Len 是有效内容的长度
    FInputLineMarks := PDWORD(GetMemory((Len + 1) * SizeOf(DWORD)));
    CopyMemory(FInputLineMarks, Marks, (Len + 1) * SizeOf(DWORD));
  end;
end;

initialization

finalization
  FCodeFormatProvider := nil;
  FPreNameList.Free;
  ClearInputLineMarks;
  ClearOutputLineMarks;

end.
