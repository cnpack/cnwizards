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

unit CnCodeFormatterImplW;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������ӿ�
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ�ִ����ʽ���Ķ���ӿڣ�Unicode �湩 D2005~2007��UTF8�棩
*           �Լ� 2009 ���ϣ�Utf16�棩ʹ�á��� D2009 ����
*           ���� 64 λ Unicode �湩 64 λר�Ұ��� IDE ʹ��
* ����ƽ̨��WinXP + Delphi 2009
* ���ݲ��ԣ�
* �� �� ����
* �޸ļ�¼��2025.02.16 V1.1
*               ���� 64 λ��֧��
*           2015.04.04 V1.0
*               ������Ԫ��
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  CnFormatterIntf, SysUtils, Classes, Windows, CnNative;

function GetCodeFormatterProvider: ICnPascalFormatterIntf; stdcall;

exports
  GetCodeFormatterProvider;

implementation

uses
  CnCodeFormatter, CnParseConsts, CnCodeFormatRules {$IFDEF DEBUG} , CnDebug {$ENDIF} ;

type
  TCnCodeFormatProvider = class(TInterfacedObject, ICnPascalFormatterIntf)
  private
    FResult: PChar;
    FUtf8Result: PAnsiChar;
    // �������������ȣ�Len ��λΪ�ַ�
    procedure AdjustResultLength(Len: DWORD);
    procedure AdjustUtf8ResultLength(Len: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetPascalFormatRule(DirectiveMode: DWORD; KeywordStyle: DWORD;
      BeginStyle: DWORD; ElseAfterEndStyle: DWORD; WrapMode: DWORD; TabSpace: DWORD;
      SpaceBeforeOperator: DWORD; SpaceAfterOperator: DWORD; SpaceBeforeAsm: DWORD;
      SpaceTabAsm: DWORD; LineWrapWidth: DWORD; NewLineWrapWidth: DWORD; UsesSingleLine: LongBool;
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
    ZeroMemory(FResult, Len * SizeOf(Char));
  end;
end;

constructor TCnCodeFormatProvider.Create;
begin
  inherited;
  
end;

destructor TCnCodeFormatProvider.Destroy;
begin
  AdjustResultLength(0);
  AdjustUtf8ResultLength(0);
  inherited;
end;

function TCnCodeFormatProvider.FormatPascalBlock(Input: PAnsiChar; Len,
  StartOffset, EndOffset: DWORD): PAnsiChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := nil;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
end;

function TCnCodeFormatProvider.FormatPascalBlockUtf8(Input: PAnsiChar; Len,
  StartOffset, EndOffset: DWORD): PAnsiChar;
var
  InStream, OutStream: TStream;
  CodeFor: TCnPascalCodeFormatter;
  UInput, Res: string;
  Utf8Res: AnsiString;
begin
  ClearPascalError;
  AdjustResultLength(0);

  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  // Utf8 �ַ����� Utf8 ƫ����ȫ��ת���� Unicode ��
  UInput := UTF8ToUnicodeString(Input);
  Len := Length(UInput);

  StartOffset := Length(UTF8Decode(Copy(Input, 1, StartOffset + 1))) - 1;
  EndOffset := Length(UTF8Decode(Copy(Input, 1, EndOffset + 1))) - 1;

{$IFDEF DEBUG}
  CnDebugger.LogRawString(Copy(UInput, StartOffset + 1, EndOffset - StartOffset));
{$ENDIF}

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write((PChar(UInput))^, Len * SizeOf(Char));
  CodeFor := TCnPascalCodeFormatter.Create(InStream, StartOffset, EndOffset,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);
  CodeFor.SliceMode := True;

  try
    try
      CodeFor.FormatCode;
    except
      ; // �����ˣ������Σ����濴�����޽��
    end;

    Res := CodeFor.CopyMatchedSliceResult;
    if Res = '' then
    begin
      Result := nil;
      Exit;
    end;

    OutStream.Write(PChar(Res)^, Length(Res) * SizeOf(Char));
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

  if FResult <> nil then
  begin
    Utf8Res := UTF8Encode(FResult);
    Len := Length(Utf8Res);
    AdjustUtf8ResultLength(Len + SizeOf(Char));
    CopyMemory(FUtf8Result, @(Utf8Res[1]), Len);

    Result := FUtf8Result;
  end
  else
    Result := nil;

  AdjustResultLength(0);
end;

function TCnCodeFormatProvider.FormatPascalBlockW(Input: PWideChar; Len,
  StartOffset, EndOffset: DWORD): PWideChar;
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
  CnDebugger.LogRawString(Copy(Input, StartOffset + 1, EndOffset - StartOffset));
{$ENDIF}

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write(Input^, Len * SizeOf(Char));
  // Formatter �ڲ���ƫ������ 0 ��ʼ������� Offset Ҳ�� 0 ��ʼ
  CodeFor := TCnPascalCodeFormatter.Create(InStream, StartOffset, EndOffset,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);
  CodeFor.SliceMode := True;

  try
    try
      CodeFor.FormatCode;
    except
      ; // �����ˣ������Σ����濴�����޽��
    end;

    Res := CodeFor.CopyMatchedSliceResult;
    if Res = '' then
    begin
      Result := nil;
      Exit;
    end;

    OutStream.Write(PChar(Res)^, Length(Res) * SizeOf(Char));
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

function TCnCodeFormatProvider.FormatOnePascalUnit(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
begin
  ClearPascalError;
  AdjustResultLength(0);
  Result := nil;

  PascalErrorRec.ErrorCode := CN_ERRCODE_PASCAL_NOT_SUPPORT;
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

    // Len ����Ч���ݵĳ���
    FInputLineMarks := PDWORD(GetMemory((Len + 1) * SizeOf(DWORD)));
    CopyMemory(FInputLineMarks, Marks, (Len + 1) * SizeOf(DWORD));
  end;
end;

procedure TCnCodeFormatProvider.SetPascalFormatRule(DirectiveMode, KeywordStyle,
  BeginStyle, ElseAfterEndStyle, WrapMode, TabSpace, SpaceBeforeOperator, SpaceAfterOperator,
  SpaceBeforeAsm, SpaceTabAsm, LineWrapWidth, NewLineWrapWidth: DWORD;
  UsesSingleLine, UseIgnoreArea: LongBool; UsesLineWrapWidth: DWORD; KeepUserLineBreak: LongBool);
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

  case ElseAfterEndStyle of
    CN_RULE_ELSEAFTEREND_STYLE_NEXTLINE:
      CnPascalCodeForRule.ElseAfterEndStyle := eaeNextLine;
    CN_RULE_ELSEAFTEREND_STYLE_SAMELINE:
      CnPascalCodeForRule.ElseAfterEndStyle := eaeSameLine;
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
      S := StrNew(PChar(string(Names^)));
      FPreNameList.Add(S);
      Inc(Names);
    end;
  end;
end;

function TCnCodeFormatProvider.RetrieveOutputLinkMarks: PDWORD;
begin
  Result := FOutputLineMarks;
end;

function TCnCodeFormatProvider.RetrievePascalLastError(out SourceLine, SourceCol,
  SourcePos: Integer; out CurrentToken: PAnsiChar): Integer;
begin
  Result := PascalErrorRec.ErrorCode;
  SourceLine := PascalErrorRec.SourceLine;
  SourceCol := PascalErrorRec.SourceCol;
  SourcePos := PascalErrorRec.SourcePos;
  CurrentToken := PAnsiChar(AnsiString(PascalErrorRec.CurrentToken));
end;

function TCnCodeFormatProvider.FormatOnePascalUnitUtf8(Input: PAnsiChar;
  Len: DWORD): PAnsiChar;
var
  InStream, OutStream: TMemoryStream;
  CodeFor: TCnPascalCodeFormatter;
  UInput: string;
  Utf8Res: AnsiString;
  ResPtr: PWideChar;
begin
  AdjustResultLength(0);
  AdjustUtf8ResultLength(0);

  ClearPascalError;
  if (Input = nil) or (Len = 0) then
  begin
    Result := nil;
    Exit;
  end;

  UInput := UTF8ToUnicodeString(Input);
  Len := Length(UInput);

  InStream := TMemoryStream.Create;
  OutStream := TMemoryStream.Create;

  InStream.Write((PChar(UInput))^, Len * SizeOf(Char));
  CodeFor := TCnPascalCodeFormatter.Create(InStream, CN_MATCHED_INVALID, CN_MATCHED_INVALID,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);

  try
    try
      CodeFor.FormatCode;
      CodeFor.SaveToStream(OutStream);
    except
      ; // �����ˣ����� nil �Ľ��
    end;

    // GetTextStr �ᵼ������� Strings ���һ���ǻس�����ʱ�ֶ�����س����У��Ƴ�\
    // 4 ��Ϊ�ж�ʹ�ã��� Uincode �Լ� Win64 �޹�
    if OutStream.Size >= 4 * SizeOf(Char) then
    begin
      ResPtr := PWideChar(TCnNativeInt(OutStream.Memory) + OutStream.Size - 4 * SizeOf(Char));
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

  if FResult <> nil then
  begin
    Utf8Res := UTF8Encode(FResult);
    Len := Length(Utf8Res);
    AdjustUtf8ResultLength(Len + SizeOf(Char));
    CopyMemory(FUtf8Result, @(Utf8Res[1]), Len);

    Result := FUtf8Result;
  end
  else
    Result := nil;

  AdjustResultLength(0);
end;

function TCnCodeFormatProvider.FormatOnePascalUnitW(Input: PWideChar;
  Len: DWORD): PWideChar;
var
  InStream, OutStream: TMemoryStream;
  CodeFor: TCnPascalCodeFormatter;
  ResPtr: PWideChar;
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

  InStream.Write(Input^, Len * SizeOf(Char));
  CodeFor := TCnPascalCodeFormatter.Create(InStream, CN_MATCHED_INVALID, CN_MATCHED_INVALID,
    CnPascalCodeForRule.CompDirectiveMode);
  CodeFor.SpecifyIdentifiers(FPreNameList);
  CodeFor.SpecifyLineMarks(FInputLineMarks);

  try
    try
      CodeFor.FormatCode;
      CodeFor.SaveToStream(OutStream);
    except
      ; // �����ˣ����� nil �Ľ��
    end;

    // GetTextStr �ᵼ������� Strings ���һ���ǻس�����ʱ�ֶ�����س����У��Ƴ�
    if OutStream.Size >= 4 * SizeOf(Char) then
    begin
      ResPtr := PWideChar(TCnNativeInt(OutStream.Memory) + OutStream.Size - 4 * SizeOf(Char));
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

procedure TCnCodeFormatProvider.AdjustUtf8ResultLength(Len: DWORD);
begin
  if FUtf8Result <> nil then
  begin
    StrDispose(FUtf8Result);
    FUtf8Result := nil;
  end;

  if Len > 0 then
  begin
    FUtf8Result := AnsiStrAlloc(Len);
    ZeroMemory(FUtf8Result, Len * SizeOf(AnsiChar));
  end;
end;

initialization

finalization
  FCodeFormatProvider := nil;
  FPreNameList.Free;
  ClearInputLineMarks;
  ClearOutputLineMarks;

end.
