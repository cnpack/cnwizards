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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizMacroUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭��ר�Ҹ���������Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ��Ҫ��ֲ�� GExperts 1.12 Src
*           ��ԭʼ������ GExperts License �ı���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.09.26 V1.1 ����(QSoft)
*               �������빤�߼��еļ������ͷʱ���� Class methods �������� BUG 
*           2002.12.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes {$IFDEF DELPHI_OTA}, ToolsAPI {$ENDIF};

type
  TCnEditorInsertPos = (ipCurrPos, ipBOL, ipEOL, ipBOF, ipEOF, ipProcHead);

  TCnProcArgument = record
    ArgKind: string;
    ArgName: string;
    ArgType: string;
    ArgDefault: string;
  end;
  TCnProcArguments = array of TCnProcArgument;

function EdtGetProjectDir: string;
function EdtGetProjectName: string;
function EdtGetProjectGroupDir: string;
function EdtGetProjectGroupName: string;
function EdtGetUnitName: string;
function EdtGetUnitPath: string;
function EdtGetProcName: string;
{$IFDEF DELPHI_OTA}
function EdtGetCurrProcName: string;
{$ENDIF}
function EdtGetResult: string;
function EdtGetArguments: string;
function EdtGetArgList(FormatStr: string): string;
function EdtGetRetType(FormatStr: string): string;
function EdtGetUser: string;
function EdtGetCodeLines: string;

function EdtGetProcInfo(var Name: string; var Args: TCnProcArguments;
  var ResultType: string): Boolean;
{* �ӵ�ǰ��������ҵ�һ����������������}

procedure EdtInsertTextToCurSource(const AContent: string;
  InsertPos: TCnEditorInsertPos; ASavePos: Boolean; PosInText: Integer = 0);
{* AContent �Ǵ���������ݣ�InsertPos �Ǵ������λ��
   ASavePos �Ƿ�������ص�ԭ������Ϊ False������� PosInText �������λ��}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnNative, CnCommon, CnWizUtils, CnWizConsts, CnWizIdeUtils, mPasLex, CnIDEStrings;

const
  csArgKind = '$k';
  csArgName = '$n';
  csArgType = '$t';
  csArgDefault = '$d';
  csRetType = '$t';

function IsParseSource: Boolean;
begin
  Result := CurrentIsDelphiSource;
end;

// �� Ansi/Utf16/Utf16 ��Դ���ַ��ʼ��������Ĺ��̺������������б�����ֵ
function ParseNameArgsResult(Source: Pointer; var Name, Args, ResultType: string;
  IgnoreCompDir: Boolean = False): Integer;
var
  Parser: TCnGeneralWidePasLex; // Ansi/Utf16/Utf16
begin
  Result := 0;
  Parser := TCnGeneralWidePasLex.Create;
  try
    Parser.Origin := Source;
    while not (Parser.TokenID in [tkNull, tkProcedure, tkFunction, tkConstructor, tkDestructor]) do
      Parser.NextNoJunk;
    if Parser.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
    begin
      Parser.NextNoJunk; // Get the proc/class identifier
      if Parser.TokenID in [tkIdentifier, tkRegister] then
        Name := string(Parser.Token);
      Parser.NextNoJunk; // Skip to the open paren or the '.'
      if Parser.TokenID = tkPoint then
      begin
        Parser.NextNoJunk; // Get the proc identifier
        Name := Name + '.' + string(Parser.Token);
        Parser.NextNoJunk; // skip past the procedure identifier
      end;

      if Parser.TokenID = tkRoundOpen then
      begin
        Parser.NextNoJunk;
        Args := '';
        while not (Parser.TokenID in [tkNull, tkRoundClose]) do
        begin
          if Parser.TokenID in [tkCRLF, tkCRLFCo, tkSlashesComment,
            tkBorComment, tkAnsiComment, tkSpace] then
            Args := Args + ' '
          else if IgnoreCompDir and (Parser.TokenID = tkCompDirect) then
            Args := Args + ' '
          else
            Args := Args + string(Parser.Token);
          Parser.Next;
        end;
        Args := CompressWhiteSpace(Args);
        // Skip to the colon or semicolon after the ')'
        Parser.NextNoJunk;
      end;
      if Parser.TokenID in [tkAnsiComment, tkBorComment, tkCRLF, tkCRLFCo, tkSpace] then
        Parser.NextNoJunk;
      // If a colon is found, find the next token
      if Parser.TokenID = tkColon then
      begin
        Parser.NextNoJunk;
        ResultType := string(Parser.Token);
      end;

      // �������һ�� Token ��β���� Source �е������ַ�λ��
      Result := Parser.TokenPos + Parser.TokenLength;
    end;
  finally
    Parser.Free;
  end;
end;

procedure GetNameArgsResult(var Name, Args, ResultType: string;
  RetEmpty: Boolean = False; IgnoreCompDir: Boolean = False);
var
  MemStream: TMemoryStream;
begin
  if RetEmpty then
  begin
    Name := '';
    Args := '';
    ResultType := '';
  end
  else
  begin
    Name := SCnUnknownNameResult;
    Args := SCnNoneResult;
    ResultType := SCnNoneResult;
  end;

{$IFNDEF STAND_ALONE}
  MemStream := TMemoryStream.Create;
  try
    CnGeneralSaveEditorToStream(nil, MemStream, True); // Ansi/Utf16/Utf16
    ParseNameArgsResult(MemStream.Memory, Name, Args, ResultType, IgnoreCompDir);
  finally
    MemStream.Free;
  end;
{$ENDIF}
end;

function EdtGetProjectDir: string;
begin
  Result := _CnExtractFilePath(CnOtaGetCurrentProjectFileName);
  if Result = '' then
    Result := SCnUnknownNameResult;
end;

function EdtGetProjectName: string;
begin
  Result := _CnExtractFileName(CnOtaGetCurrentProjectFileName);
  if Result = '' then
    Result := SCnUnknownNameResult
  else
    Result := _CnChangeFileExt(Result, '');
end;

function EdtGetProjectGroupDir: string;
begin
{$IFDEF DELPHI_OTA}
  Result := _CnExtractFilePath(CnOtaGetProjectGroupFileName);
  if Result = '' then
    Result := SCnUnknownNameResult;
{$ELSE}
  Result := '';
{$ENDIF}
end;

function EdtGetProjectGroupName: string;
begin
{$IFDEF DELPHI_OTA}
  Result := _CnExtractFileName(CnOtaGetProjectGroupFileName);
  if Result = '' then
    Result := SCnUnknownNameResult
  else
    Result := _CnChangeFileExt(Result, '');
{$ELSE}
  Result := '';
{$ENDIF}
end;

function EdtGetUnitName: string;
begin
  Result := _CnExtractFileName(CnOtaGetCurrentSourceFile);
  if Result = '' then
    Result := SCnUnknownNameResult;
end;

function EdtGetUnitPath: string;
begin
  Result := _CnExtractFileDir(CnOtaGetCurrentSourceFile);
  if Result = '' then
    Result := SCnUnknownNameResult;
  if CurrentIsDelphiSource then
    Result := QuotedStr(Result)
  else
    Result := '"' + Result + '"';
end;

function EdtGetProcName: string;
var
  ProcName, ProcArgs, ProcResult: string;
begin
  if IsParseSource then
  begin
    GetNameArgsResult(ProcName, ProcArgs, ProcResult);
    Result := ProcName;
  end
  else
    Result := SCnUnknownNameResult;
end;

{$IFDEF DELPHI_OTA}

function EdtGetCurrProcName: string;
var
  Stream: TMemoryStream;
  CurrLinear, LastProcLinear, EndPos: Integer;
  Parser: TCnGeneralWidePasLex; // Ansi/Utf16/Utf16
  Name, Args, ResultType: string;
  P: Pointer;
begin
  Result := CnOtaGetCurrentProcedure;
  if Result = '' then
  begin
    Parser := nil;
    Stream := nil;

    // ���������������ڵ����Ρ�ȫ Save �� MemStream �У���ͷ Parse��
    // ��ǰ�ҵ����һ�� function/procedure/constructor/destructor �ٿ��Һ�����β��
    // ���Ƿ񳬹��˹�괦��������˵��������������������

    try
      Stream := TMemoryStream.Create;
      CnGeneralSaveEditorToStream(nil, Stream); // Ansi/Utf16/Utf16
      CurrLinear := CnGeneralGetCurrLinearPos;

      Parser := TCnGeneralWidePasLex.Create;
      Parser.Origin := Stream.Memory;

      LastProcLinear := 0;
      while (Parser.TokenID <> tkNull) and (Parser.TokenPos <= CurrLinear) do
      begin
        if Parser.TokenID in [tkProcedure, tkFunction, tkConstructor, tkDestructor] then
          LastProcLinear := Parser.TokenPos;
        Parser.NextNoJunk;
      end;

      if LastProcLinear > 0 then
      begin
        // �ҵ������һ�����Ӵ˴��ٽ��������Һ�����β�������Ƿ񳬹����
{$IFDEF BDS}
        P := Pointer(TCnNativeInt(Stream.Memory) + LastProcLinear * SizeOf(Char));
{$ELSE}
        P := Pointer(TCnNativeInt(Stream.Memory) + LastProcLinear);
{$ENDIF}
        EndPos := LastProcLinear + ParseNameArgsResult(P, Name, Args, ResultType);

        if EndPos >= CurrLinear then
        begin
          Result := Name;
          Exit;
        end;
      end;
    finally
      Stream.Free;
      Parser.Free;
    end;
  end;

  if Result = '' then
    Result := SCnUnknownNameResult;
end;

{$ENDIF}

function EdtGetResult: string;
var
  ProcName, ProcArgs, ProcResult: string;
begin
  if IsParseSource then
  begin
    GetNameArgsResult(ProcName, ProcArgs, ProcResult);
    Result := ProcResult;
  end
  else
    Result := SCnUnknownNameResult;
end;

function EdtGetArguments: string;
var
  ProcName, ProcArgs, ProcResult: string;
begin
  if IsParseSource then
  begin
    GetNameArgsResult(ProcName, ProcArgs, ProcResult);
    Result := ProcArgs;
  end
  else
    Result := SCnUnknownNameResult;
end;

function EdtGetArgList(FormatStr: string): string;
var
  Name: string;
  Args: TCnProcArguments;
  RetType: string;
  Text: string;
  I: Integer;
begin
  Result := '';
  if (FormatStr <> '') and EdtGetProcInfo(Name, Args, RetType) then
  begin
    for I := Low(Args) to High(Args) do
    begin
      Text := FormatStr;
      Text := StringReplace(Text, csArgKind, Args[I].ArgKind, [rfReplaceAll]);
      Text := StringReplace(Text, csArgName, Args[I].ArgName, [rfReplaceAll]);
      Text := StringReplace(Text, csArgType, Args[I].ArgType, [rfReplaceAll]);
      Text := StringReplace(Text, csArgDefault, Args[I].ArgDefault, [rfReplaceAll]);
      Result := Result + Text;
    end;
  end;
end;

function EdtGetRetType(FormatStr: string): string;
var
  Name: string;
  Args: TCnProcArguments;
  RetType: string;
begin
  Result := '';
  if (FormatStr <> '') and EdtGetProcInfo(Name, Args, RetType) and
    (RetType <> '') then
  begin
    Result := StringReplace(FormatStr, csRetType, RetType, [rfReplaceAll]);
  end;
end;
  
function EdtGetUser: string;
var
  NameBufferSize: DWORD;
  NameBuffer: array[0..256] of Char;
begin
  NameBufferSize := SizeOf(NameBuffer);
  if Windows.GetUserName(NameBuffer, NameBufferSize) then
    Result := NameBuffer
  else
    Result := SCnUnknownNameResult;
end;

function EdtGetCodeLines: string;
var
  ISourceEditor: TCnSourceEditorInterface;
begin
  ISourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(ISourceEditor) then
  begin
{$IFDEF LAZARUS}
    Result := IntToStr(ISourceEditor.Lines.Count);
{$ENDIF}
{$IFDEF DELPHI_OTA}
    Result := IntToStr(ISourceEditor.GetLinesInBuffer);
{$ENDIF}
  end
  else
    Result := SCnUnknownNameResult;
end;

function EdtGetProcInfo(var Name: string; var Args: TCnProcArguments;
  var ResultType: string): Boolean;
var
  ProcArgs: string;
  Lines, Params: TStringList;

  function ParseArgs(DoAdd: Boolean): Integer;
  var
    I, J, Idx: Integer;
    Text, ArgKind, ArgType, ArgDefault: string;
  begin
    Result := 0;
    Lines.Text := StringReplace(ProcArgs, ';', CRLF, [rfReplaceAll]);
    for I := 0 to Lines.Count - 1 do
    begin
      Text := Trim(Lines[I]);
    {$IFDEF DEBUG}
      if DoAdd then
        CnDebugger.LogFmt('Line: %s', [Text]);
    {$ENDIF}

      // ȡ��������
      ArgType := '';
      ArgDefault := '';
      Idx := AnsiPos(':', Text);
      if Idx > 0 then
      begin
        ArgType := Trim(Copy(Text, Idx + 1, MaxInt));
        Text := Trim(Copy(Text, 1, Idx - 1));

        // ����Ĭ��ֵ
        Idx := AnsiPos('=', ArgType);
        if Idx > 0 then
        begin
          ArgDefault := Trim(Copy(ArgType, Idx + 1, MaxInt));
          ArgType := Trim(Copy(ArgType, 1, Idx - 1));
        end;  
      end;

      // ȡ������ʽ
      Idx := 1;
      ArgKind := '';
      while Idx < Length(Text) do
      begin
        if Text[Idx] = ' ' then
        begin
          ArgKind := Trim(Copy(Text, 1, Idx - 1));
          Text := Trim(Copy(Text, Idx + 1, MaxInt));
          Break;
        end
        else if not IsValidIdentChar(Text[Idx]) then
        begin
          Break;
        end;
        Inc(Idx);
      end;
    {$IFDEF DEBUG}
      if DoAdd then
        CnDebugger.LogFmt('Kind: %s, Type: %s, Default: %s, Text: %s',
          [ArgKind, ArgType, ArgDefault, Text]);
    {$ENDIF}

      // ȡ������
      Params.Text := StringReplace(Text, ',', CRLF, [rfReplaceAll]);
      for J := 0 to Params.Count - 1 do
      begin
        if DoAdd then
        begin
          Args[Result].ArgKind := ArgKind;
          Args[Result].ArgName := Trim(Params[J]);
          Args[Result].ArgType := ArgType;
          Args[Result].ArgDefault := ArgDefault;
        end;
        Inc(Result);
      end;
    end;
  end;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('EdtGetProcInfo');
{$ENDIF}
  Name := '';
  Args := nil;
  ResultType := '';
  if IsParseSource then
  begin
    GetNameArgsResult(Name, ProcArgs, ResultType, True, True);
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('Name: %s, Args: %s, Result: %s', [Name, ProcArgs, ResultType]);
  {$ENDIF}
    Lines := nil;
    Params := nil;
    try
      Lines := TStringList.Create;
      Params := TStringList.Create;
      SetLength(Args, ParseArgs(False));
      ParseArgs(True);
    finally
      Lines.Free;
      Params.Free;
    end;
    Result := True;
  end
  else
    Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('EdtGetProcInfo');
{$ENDIF}
end;

procedure EdtInsertTextToCurSource(const AContent: string;
  InsertPos: TCnEditorInsertPos; ASavePos: Boolean; PosInText: Integer);
{$IFNDEF STAND_ALONE}
var
  EditView: TCnEditViewSourceInterface;
  SavePos: Integer;
  Position: Integer;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  LineText, S: string;
  DummyIdx1, DummyIdx2: Integer;

  procedure MovePosToProcHead;
  label BeginFindProcHead;

  var
    Parser: TCnGeneralWidePasLex; // Ansi/Utf16/Utf16;
    MemStream: TMemoryStream;
    ClassPos: Integer;
  begin
    MemStream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(nil, MemStream, True); // Ansi/Utf16/Utf16
      Parser := TCnGeneralWidePasLex.Create;
      try
        Parser.Origin := MemStream.Memory;

  BeginFindProcHead: // ��ʼ�ҹ���ͷ
        while not (Parser.TokenID in [tkNull, tkClass, tkProcedure, tkFunction,
          tkConstructor, tkDestructor]) do
          Parser.NextNoJunk;

        // ���� class proceduer classfunc ���͵Ĺ��̶���
        if Parser.TokenID = tkClass then
        begin
          ClassPos := Parser.TokenPos; // �ȼ�¼ class �����ֵĿ�ʼλ��
          Parser.NextNoJunk;
          if Parser.TokenID in [tkProcedure, tkFunction] then
            CnOtaGotoPosition(CnOtaGetCurrLinearPos + ClassPos, nil, False)
          else // class �����ֺ�δ���� procedure �� function���������ҹ���ͷ
            goto BeginFindProcHead;  
        end
        else if Parser.TokenID in [tkProcedure, tkFunction,
          tkConstructor, tkDestructor] then
          CnOtaGotoPosition(CnOtaGetCurrLinearPos + Parser.TokenPos, nil, False);
      finally
        Parser.Free;
      end;
    finally
      MemStream.Free;
    end;
  end;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  SavePos := CnOtaGetCurrLinearPos;
  case InsertPos of
    ipBOL:
      begin
        CnOtaMovePosInCurSource(ipLineHead, 0, 0);
        Inc(SavePos, Length(AContent));
      end;
    ipEOL:
      CnOtaMovePosInCurSource(ipLineEnd, 0, 0);
    ipBOF:
      begin
        CnOtaMovePosInCurSource(ipFileHead, 0, 0);
        Inc(SavePos, Length(AContent));
      end;
    ipEOF:
      CnOtaMovePosInCurSource(ipFileEnd, 0, 0);
    ipProcHead:
      MovePosToProcHead;
  end;

  EditView := CnOtaGetTopMostEditView;
  Assert(Assigned(EditView));

{$IFDEF LAZARUS}
  Position := EditView.SelStart;
  CnOtaInsertTextIntoEditorAtPos(AContent, Position);

  if ASavePos then
    CnOtaGotoPosition(SavePos, EditView, False)
  else
  begin
    if PosInText > 0 then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('EdtInsertTextToCurSource Position %d, PosInText %d.',
        [Position, PosInText]);
{$ENDIF}
      CnOtaGotoPosition(Position + PosInText, EditView, False); // ����� 1�����Ҵ�ֱ�����ϲ�ǿ�ƾ���
    end;
    CnLazSourceEditorCenterLine(EditView, EditView.CursorTextXY.Y);
  end;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Position := EditView.CharPosToPos(CharPos);

  // ������ڿ��з�����ʱ��Position ָ��������ף������ƫ���Ҫ����
  S := AContent;
  if (EditPos.Col > 1) and CnNtaGetCurrLineText(LineText, DummyIdx1, DummyIdx2) then
  begin
    if Trim(LineText) = '' then
    begin
      // ���У���Ҫ������Ҳ�������ӿո�ע�ⲻ�ܼ� Position�����ܵ���һ��ȥ
      S := Spc(EditPos.Col - 1) + S;

      // ���λ��ҲҪ��Ӧ������
      if PosInText > 0 then
        Inc(PosInText, EditPos.Col - 1);
    end;
  end;

  // EditPosition.InsertText ���ڶ����ı��������ֲ���Ҫ���������û��� CnOtaInsertTextIntoEditorAtPos
{$IFDEF UNICODE}
  CnOtaInsertTextIntoEditorAtPosW(S, Position);
{$ELSE}
  CnOtaInsertTextIntoEditorAtPos(S, Position);
{$ENDIF}

  if ASavePos then
    CnOtaGotoPosition(SavePos, EditView, False)
  else
  begin
    if PosInText > 0 then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('EdtInsertTextToCurSource Position %d, PosInText %d.',
        [Position, PosInText]);
{$ENDIF}
      CnOtaGotoPosition(Position + PosInText, EditView, False); // ����� 1�����Ҵ�ֱ�����ϲ�ǿ�ƾ���
    end;
    EditView.MoveViewToCursor;
  end;
  EditView.Paint;
{$ENDIF}

  BringIdeEditorFormToFront;
{$ENDIF}
end;

end.
