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

unit CnIDEStrings;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ص��ַ��������봦��Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫ���Ҫ�� IDE ��������ϵ��������������
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2024.08.01
*               ������Ԫ�����������������˴�
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, CnWideStrings, mPasLex, CnPasWideLex, mwBCBTokenList,
  CnBCBWideTokenList, CnPasCodeParser, CnCppCodeParser, CnWidePasParser,
  CnWideCppParser;

type
{$IFDEF LAZARUS}
  TCnIdeTokenString = UnicodeString; // UnicodeString for Utf8 Conversion
  PCnIdeTokenChar = PWideChar;
  TCnIdeTokenChar = WideChar;
  TCnIdeStringList = TCnWideStringList;
  TCnIdeTokenInt = Word;
{$ELSE}
{$IFDEF IDE_STRING_ANSI_UTF8}
  TCnIdeTokenString = WideString; // WideString for Utf8 Conversion
  PCnIdeTokenChar = PWideChar;
  TCnIdeTokenChar = WideChar;
  TCnIdeStringList = TCnWideStringList;
  TCnIdeTokenInt = Word;
{$ELSE}
  TCnIdeTokenString = string;     // Ansi/Utf16
  PCnIdeTokenChar = PChar;
  TCnIdeTokenChar = Char;
  TCnIdeStringList = TStringList;
  {$IFDEF UNICODE}
  TCnIdeTokenInt = Word;
  {$ELSE}
  TCnIdeTokenInt = Byte;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
  PCnIdeTokenInt = ^TCnIdeTokenInt;

  // Ansi/Utf16/Utf16/Utf16(Lazarus)����� CnGeneralSaveEditorToStream ϵ��ʹ�ã���Ӧ Ansi/Utf16/Utf16/Utf16(Lazarus)
{$IFDEF LAZARUS}
  TCnGeneralPasToken = TCnWidePasToken;
  TCnGeneralCppToken = TCnWideCppToken;
  TCnGeneralPasStructParser = TCnWidePasStructParser;
  TCnGeneralCppStructParser = TCnWideCppStructParser;
  TCnGeneralWidePasLex = TCnPasWideLex;
  TCnGeneralWideBCBTokenList = TCnBCBWideTokenList;
{$ELSE}
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}  // 2005 ����
  TCnGeneralPasToken = TCnWidePasToken;
  TCnGeneralCppToken = TCnWideCppToken;
  TCnGeneralPasStructParser = TCnWidePasStructParser;
  TCnGeneralCppStructParser = TCnWideCppStructParser;
  TCnGeneralWidePasLex = TCnPasWideLex;
  TCnGeneralWideBCBTokenList = TCnBCBWideTokenList;
{$ELSE}                               // 5 6 7
  TCnGeneralPasToken = TCnPasToken;
  TCnGeneralCppToken = TCnCppToken;
  TCnGeneralPasStructParser = TCnPasStructureParser;
  TCnGeneralCppStructParser = TCnCppStructureParser;
  TCnGeneralWidePasLex = TmwPasLex;
  TCnGeneralWideBCBTokenList = TBCBTokenList;
{$ENDIF}
{$ENDIF}

{$IFDEF UNICODE}
  TCnGeneralPasLex = TCnPasWideLex;             // TCnGeneralPasLex �� 2005~2007 ������ TmwPasLex
  TCnGeneralBCBTokenList = TCnBCBWideTokenList; // TCnGeneralBCBTokenList Ҳ����
{$ELSE}
  TCnGeneralPasLex = TmwPasLex;                 // ��� EditFilerSaveFileToStream ϵ��ʹ�ã�Ansi/Ansi/Utf16
  TCnGeneralBCBTokenList = TBCBTokenList;
{$ENDIF}

{$IFDEF NO_DELPHI_OTA}

  // �������л� Lazarus �У��� ToolsAPI ���һЩ����������ƹ���

  TOTAEditPos = packed record
    Col: SmallInt;       // 1 ��ʼ
    Line: Longint;       // 1 ��ʼ
  end;

  TOTACharPos = packed record
    CharIndex: SmallInt; // 0 ��ʼ
    Line: Longint;       // 1 ��ʼ
  end;

{$ENDIF}

function IDEWideCharIsWideLength(const AWChar: WideChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* �����ж�һ�� Unicode ���ַ��Ƿ�ռ�����ַ���ȣ���Ϊ������ IDE ����}

function GetTokenAnsiEditCol(AToken: TCnGeneralPasToken): Integer;
{* ��ȡһ�� GeneralPasToken �� AnsiCol�������� C/C++ �� TCnGeneralCppToken}

procedure RemovePasMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
{* ɾ��һ Pascal Token �б�����Ե�С���Ż������ţ�IsSmall ��ʾС���Ż������ţ�
  IsReverse Ϊ False ��ʾ��������ջ������������ɾ��True ��֮}

procedure RemoveCppMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
{* ɾ��һ C/C++ Token �б�����Ե�С���Ż������ţ�IsSmall ��ʾС���Ż������ţ�
  IsReverse Ϊ False ��ʾ��������ջ������������ɾ��True ��֮}

implementation

function IDEWideCharIsWideLength(const AWChar: WideChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
const
  CN_UTF16_ANSI_WIDE_CHAR_SEP = $1100;
var
  C: Integer;
begin
  C := Ord(AWChar);
  Result := C > CN_UTF16_ANSI_WIDE_CHAR_SEP; // ������Ϊ�� $1100 ��� Utf16 �ַ����ƿ�Ȳ�ռ���ֽ�
{$IFDEF DELPHI110_ALEXANDRIA_UP}
  if Result then // ����Щ��������ģ�������������ôд��
  begin
    if ((C >= $1470) and (C <= $14BF)) or
      ((C >= $16A0) and (C <= $16FF)) or
      ((C >= $1D00) and (C <= $1FFF)) or
      ((C >= $20A0) and (C <= $20BF)) or
      ((C >= $2100) and (C <= $24FF)) or  // ��ĸ��ͷ��ѧ���ŵ�
      ((C >= $2550) and (C <= $256D)) or
      ((C >= $25A0) and (C <= $25BF) and (C <> $25B3) and (C <> $25BD)) then
      Result := False;
  end;
{$ENDIF}
end;

// ��ȡһ�� GeneralPasToken �� AnsiCol
function GetTokenAnsiEditCol(AToken: TCnGeneralPasToken): Integer;
begin
{$IFDEF IDE_STRING_ANSI_UTF8}
  Result := AToken.EditAnsiCol;
{$ELSE}
  Result := AToken.EditCol;
{$ENDIF}
end;

procedure RemoveCppMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
var
  T: TCnGeneralCppToken;
  BT, B1, B2: TCTokenKind;
  I: Integer;
  Stack: TStack;
begin
  if (Tokens = nil) or (Tokens.Count <= 1) then
    Exit;

  if IsSmall then
  begin
    B1 := ctkroundopen;
    B2 := ctkroundclose;
  end
  else
  begin
    B1 := ctksquareopen;
    B2 := ctksquareclose;
  end;

  if IsReverse then
  begin
    BT := B1;
    B1 := B2;
    B2 := BT;
  end;

  // �� List �� 0 �����ң��ȼ�¼ B1 ���ջ������ B2 ���жϵ�ջ������������ɾ
  I := 0;
  Stack := TStack.Create;
  try
    while I < Tokens.Count do
    begin
      T := TCnGeneralCppToken(Tokens[I]);
      if T.CppTokenKind = B1 then
        Stack.Push(T)
      else if T.CppTokenKind = B2 then
      begin
        if Stack.Count > 0 then
        begin
          Tokens.Delete(I); // ɾ��һ�������� Inc��
          T := Stack.Pop;
          Tokens.Remove(T); // ��ɾ��֮ǰ��һ�����ǵ��� Inc������ Dec
          Dec(I);
          Continue;
        end;
      end;

      Inc(I);
    end;
  finally
    Stack.Free;
  end;
end;

procedure RemovePasMatchedBraces(Tokens: TList; IsSmall, IsReverse: Boolean);
var
  T: TCnGeneralPasToken;
  BT, B1, B2: TTokenKind;
  I: Integer;
  Stack: TStack;
begin
  if (Tokens = nil) or (Tokens.Count <= 1) then
    Exit;

  if IsSmall then
  begin
    B1 := tkRoundOpen;
    B2 := tkRoundClose;
  end
  else
  begin
    B1 := tkSquareOpen;
    B2 := tkSquareClose;
  end;

  if IsReverse then
  begin
    BT := B1;
    B1 := B2;
    B2 := BT;
  end;

  // �� List �� 0 �����ң��ȼ�¼ B1 ���ջ������ B2 ���жϵ�ջ������������ɾ
  I := 0;
  Stack := TStack.Create;
  try
    while I < Tokens.Count do
    begin
      T := TCnGeneralPasToken(Tokens[I]);
      if T.TokenID = B1 then
        Stack.Push(T)
      else if T.TokenID = B2 then
      begin
        if Stack.Count > 0 then
        begin
          Tokens.Delete(I); // ɾ��һ�������� Inc��
          T := Stack.Pop;
          Tokens.Remove(T); // ��ɾ��֮ǰ��һ�����ǵ��� Inc������ Dec
          Dec(I);
          Continue;
        end;
      end;

      Inc(I);
    end;
  finally
    Stack.Free;
  end;
end;

end.
