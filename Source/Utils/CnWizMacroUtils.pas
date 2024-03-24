{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from GExperts 1.2                                    }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizMacroUtils;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：编辑器专家辅助函数单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元主要移植自 GExperts 1.12 Src
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.09.26 V1.1 何清(QSoft)
*               修正编码工具集中的加入过程头时，对 Class methods 处理错误的 BUG 
*           2002.12.04 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, ToolsAPI;

{$I CnWizards.inc}

type
  TEditorInsertPos = (ipCurrPos, ipBOL, ipEOL, ipBOF, ipEOF, ipProcHead);

  TCnProcArgument = record
    ArgKind: string;
    ArgName: string;
    ArgType: string;
    ArgDefault: string;
  end;
  TCnProcArguments = array of TCnProcArgument;

const
  csArgKind = '$k';
  csArgName = '$n';
  csArgType = '$t';
  csArgDefault = '$d';
  csRetType = '$t';

function EdtGetProjectDir: string;
function EdtGetProjectName: string;
function EdtGetProjectGroupDir: string;
function EdtGetProjectGroupName: string;
function EdtGetUnitName: string;
function EdtGetUnitPath: string;
function EdtGetProcName: string;
function EdtGetCurrProcName: string;
function EdtGetResult: string;
function EdtGetArguments: string;
function EdtGetArgList(FormatStr: string): string;
function EdtGetRetType(FormatStr: string): string;
function EdtGetUser: string;
function EdtGetCodeLines: string;

function EdtGetProcInfo(var Name: string; var Args: TCnProcArguments;
  var ResultType: string): Boolean;
{* 从当前光标往后找第一个函数的声明内容}

procedure EdtInsertTextToCurSource(const AContent: string;
  InsertPos: TEditorInsertPos; ASavePos: Boolean; PosInText: Integer = 0);
{* AContent 是待插入的内容；InsertPos是待插入的位置
   ASavePos 是否插入后光标回到原处，如为 False，则根据 PosInText 调整光标位置}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCommon, CnWizUtils, CnWizConsts, CnWizIdeUtils, mPasLex;

function IsParseSource: Boolean;
begin
  Result := CurrentIsDelphiSource;
end;

procedure GetNameArgsResult(var Name, Args, ResultType: string;
  RetEmpty: Boolean = False; IgnoreCompDir: Boolean = False);
var
  Parser: TCnGeneralWidePasLex; // Ansi/Utf16/Utf16
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

  MemStream := TMemoryStream.Create;
  try
    CnGeneralSaveEditorToStream(nil, MemStream, True); // Ansi/Utf16/Utf16
    Parser := TCnGeneralWidePasLex.Create;
    try
      Parser.Origin := MemStream.Memory;
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
      end;
    finally
      Parser.Free;
    end;
  finally
    MemStream.Free;
  end;
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
  Result := _CnExtractFilePath(CnOtaGetProjectGroupFileName);
  if Result = '' then
    Result := SCnUnknownNameResult;
end;

function EdtGetProjectGroupName: string;
begin
  Result := _CnExtractFileName(CnOtaGetProjectGroupFileName);
  if Result = '' then
    Result := SCnUnknownNameResult
  else
    Result := _CnChangeFileExt(Result, '');
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

function EdtGetCurrProcName: string;
begin
  Result := CnOtaGetCurrentProcedure;
  if Result = '' then
    Result := SCnUnknownNameResult;
end;

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
  i: Integer;
begin
  Result := '';
  if (FormatStr <> '') and EdtGetProcInfo(Name, Args, RetType) then
  begin
    for i := Low(Args) to High(Args) do
    begin
      Text := FormatStr;
      Text := StringReplace(Text, csArgKind, Args[i].ArgKind, [rfReplaceAll]);
      Text := StringReplace(Text, csArgName, Args[i].ArgName, [rfReplaceAll]);
      Text := StringReplace(Text, csArgType, Args[i].ArgType, [rfReplaceAll]);
      Text := StringReplace(Text, csArgDefault, Args[i].ArgDefault, [rfReplaceAll]);
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
  ISourceEditor: IOTASourceEditor;
begin
  ISourceEditor := CnOtaGetCurrentSourceEditor;
  if Assigned(ISourceEditor) then
    Result := IntToStr(ISourceEditor.GetLinesInBuffer)
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
    i, j, Idx: Integer;
    Text, ArgKind, ArgType, ArgDefault: string;
  begin
    Result := 0;
    Lines.Text := StringReplace(ProcArgs, ';', CRLF, [rfReplaceAll]);
    for i := 0 to Lines.Count - 1 do
    begin
      Text := Trim(Lines[i]);
    {$IFDEF DEBUG}
      if DoAdd then
        CnDebugger.LogFmt('Line: %s', [Text]);
    {$ENDIF}

      // 取参数类型
      ArgType := '';
      ArgDefault := '';
      Idx := AnsiPos(':', Text);
      if Idx > 0 then
      begin
        ArgType := Trim(Copy(Text, Idx + 1, MaxInt));
        Text := Trim(Copy(Text, 1, Idx - 1));

        // 参数默认值
        Idx := AnsiPos('=', ArgType);
        if Idx > 0 then
        begin
          ArgDefault := Trim(Copy(ArgType, Idx + 1, MaxInt));
          ArgType := Trim(Copy(ArgType, 1, Idx - 1));
        end;  
      end;

      // 取参数形式
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

      // 取参数名
      Params.Text := StringReplace(Text, ',', CRLF, [rfReplaceAll]);
      for j := 0 to Params.Count - 1 do
      begin
        if DoAdd then
        begin
          Args[Result].ArgKind := ArgKind;
          Args[Result].ArgName := Trim(Params[j]);
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
  InsertPos: TEditorInsertPos; ASavePos: Boolean; PosInText: Integer);
var
  EditView: IOTAEditView;
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

  BeginFindProcHead: // 开始找过程头
        while not (Parser.TokenID in [tkNull, tkClass, tkProcedure, tkFunction,
          tkConstructor, tkDestructor]) do
          Parser.NextNoJunk;

        // 处理 class proceduer classfunc 类型的过程定义
        if Parser.TokenID = tkClass then
        begin
          ClassPos := Parser.TokenPos; // 先记录 class 保留字的开始位置
          Parser.NextNoJunk;
          if Parser.TokenID in [tkProcedure, tkFunction] then
            CnOtaGotoPosition(CnOtaGetCurrLinePos + ClassPos, nil, False)
          else // class 保留字后未跟有 procedure 或 function，则重新找过程头
            goto BeginFindProcHead;  
        end
        else if Parser.TokenID in [tkProcedure, tkFunction,
          tkConstructor, tkDestructor] then
          CnOtaGotoPosition(CnOtaGetCurrLinePos + Parser.TokenPos, nil, False);
      finally
        Parser.Free;
      end;
    finally
      MemStream.Free;
    end;
  end;
begin
  SavePos := CnOtaGetCurrLinePos;
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
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Position := EditView.CharPosToPos(CharPos);

  // 当光标在空行非行首时，Position 指向空行行首，会造成偏差，需要纠正
  S := AContent;
  if (EditPos.Col > 1) and CnNtaGetCurrLineText(LineText, DummyIdx1, DummyIdx2) then
  begin
    if Trim(LineText) = '' then
    begin
      // 空行，需要纠正，也就是增加空格。注意不能加 Position，会跑到下一行去
      S := Spc(EditPos.Col - 1) + S;

      // 光标位置也要相应往后移
      if PosInText > 0 then
        Inc(PosInText, EditPos.Col - 1);
    end;
  end;

  // EditPosition.InsertText 对于多行文本插入会出现不必要的缩进，得换成 CnOtaInsertTextIntoEditorAtPos
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
      CnOtaGotoPosition(Position + PosInText, EditView, False); // 必须减 1。并且垂直方向上不强制居中
    end;
    EditView.MoveViewToCursor;
  end;
  EditView.Paint;
  BringIdeEditorFormToFront;
end;

end.
