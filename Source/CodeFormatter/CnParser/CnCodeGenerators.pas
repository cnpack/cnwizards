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

unit CnCodeGenerators;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化结果操作代理类 CnCodeGenerators
* 单元作者：CnPack开发组
* 备    注：该单元实现了代码格式化结果的操作代理类
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2015.10.12 V1.1
*               由于注释后的换行已由外部写入，此处不再分析写入内容是否注释与换行结尾。
*           2007.10.13 V1.0
*               加入换行的部分设置处理，但不完善。
*           2003.12.16 V0.1
*               建立。简单的代理代码的写入以及保存操作。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnCodeFormatRules;

type
  TCnAfterWriteEvent = procedure (Sender: TObject; IsWriteBlank: Boolean;
    IsWriteln: Boolean; PrefixSpaces: Integer) of object;
  TCnGetInIgnoreEvent = function (Sender: TObject): Boolean of object;

  TCnCodeGenerator = class
  private
    FCode: TStrings;                // 存储输出内容，内容中可能有注释引入的回车换行
    FActualLines: TStrings;         // 存储规范了的输出内容，也就是不包含回车换行
    FActualWriteHelper: TStrings;
    FLock: Word;
    FColumnPos: Integer;            // 当前列值，注意它和实际情况不一定一致，因为 FCode 中的字符串可能带回车换行
    FActualColumn: Integer;         // 当前实际列值，等于 FCode 最后一行最后一个 #13#10 后的内容
    FCodeWrapMode: TCnCodeWrapMode;
    FPrevStr: string;
    FPrevRow: Integer;
    FPrevColumn: Integer;
    FLastExceedPosition: Integer; // 本行超出 WrapWidth 的点，供行尾超长时回溯重新换行使用
    FAutoWrapLines: TList;        // 记录自动换行的行号，用来搜寻最近一次非自动换行的行缩进。
    // 注意行号存储的是规范行。

    FEnsureEmptyLine: Boolean;

    FOnAfterWrite: TCnAfterWriteEvent;
    FAutoWrapButNoIndent: Boolean;
    FWritingBlank: Boolean;
    FWritingCommentEndLn: Boolean;
    FJustWrittenCommentEndLn: Boolean;
    FKeepLineBreak: Boolean;
    FKeepLineBreakIndentWritten: Boolean;
    FOnGetInIgnore: TCnGetInIgnoreEvent;
    function GetCurIndentSpace: Integer;
    function GetLockedCount: Word;
    function GetPrevColumn: Integer;
    function GetPrevRow: Integer;
    function GetCurrColumn: Integer;
    function GetCurrRow: Integer;
    function GetLastIndentSpaceWithOutComments: Integer;
    function GetActualRow: Integer;
    function GetLastLine: string;
    function GetNextOutputWillbeLineHead: Boolean;
    function LineIsEmptyOrComment(const Str: string): Boolean;
    procedure RecordAutoWrapLines(Line: Integer);

{$IFDEF DEBUG}
    function GetDebugCodeString: string;
{$ENDIF}
  protected
    procedure DoAfterWrite(IsWriteln: Boolean; PrefixSpaces: Integer = 0); virtual;
    // 当 IsWriteln 为 True 时，PrefixSpaces 表示本次写入回车后可能写的空格数，否则为 0
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Write(const Text: string; BeforeSpaceCount:Word = 0;
      AfterSpaceCount: Word = 0; NeedPadding: Boolean = False; NeedUnIndent: Boolean = False);
    procedure WriteOneSpace;
    // 供格式化写语句中的单个分隔空格用，会判断是否已有注释带来的空格而决定是否写一个空格
    // NeedUnIndent 指外部需要回退空格，仅当 NeedPadding 为 True 时有效

    procedure WriteBlank(const Text: string);
    procedure InternalWriteln;
    procedure Writeln;
    procedure WriteCommentEndln;
    procedure CheckAndWriteOneEmptyLine;
    function SourcePos: Word;
    {* 最后一行光标所在列数，暂未使用}
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: string);
    procedure SaveToStrings(AStrings: TStrings);

    function CopyPartOut(StartRow, StartColumn, EndRow, EndColumn: Integer): string;
    {* 从输出中指定起止位置复制内容出来，直接使用 Row/Column 相关属性
       逻辑上，复制范围内的内容不包括 EndColumn 所指的字符}

    procedure BackSpaceLastSpaces;
    {* 把最后一行的行尾空格删掉一个，避免因为已经输出了带空格的内容，导致行尾注释后移的问题
      注意 Scanner 在忽略区时不要调用，免得引起额外的空格消失}
    procedure TrimLastEmptyLine;
    {* 如果最后一行是全空格，则清除此行的所有空格，用于保留换行的场合}
    procedure BackSpaceEmptyLines;
    {* 单独针对 Directive 无句末分号而写的，删除尾部所有纯空格行的方法，需严格限制使用以避免副作用}
    procedure BackSpaceSpaceLineIndent(Indent: Integer = 2);
    {* 如果最后一行全是空格，且空格数比 Indent 多，则清除 Indent 个空格，
      单独针对保留换行时函数调用的末括号而言的，需严格限制使用以避免副作用}

    function IsLastLineEmpty: Boolean;
    {* 最后一行是否就是一个完全的空行，不算回车换行}
    function IsLastLineSpaces: Boolean;
    {* 最后一行是否就空格和 Tab，不算回车换行}
    function IsLast2LineEmpty: Boolean;
    {* 最后两行是否就两个回车，如果行数不够也返回 False}

    procedure LockOutput;
    procedure UnLockOutput;

    procedure ClearOutputLock;
    {* 直接将输出锁定置零}

    property LockedCount: Word read GetLockedCount;
    {* 输出锁数}
    property ColumnPos: Integer read FColumnPos;
    {* 当前光标的横向位置，用于换行。值为当前行长度，当前行刚换行无内容时为 0，
       可以理解为指向当前已经输出内容的紧邻后的位置。它作为 StartCol 时得加一，
       而作为 EndCol 时，因为当前行字符串下标从一开始的第 FColumnPos 个字符，
       是属于 CopyPartout 的最后一个字符，因此无需加一}
    property CurIndentSpace: Integer read GetCurIndentSpace;
    {* 当前行最前面的空格数}
    property LastIndentSpaceWithOutComments: Integer read GetLastIndentSpaceWithOutComments;
    {* 上一个非自动换以及非注释的行的最前面的空格数，注意在保留换行时不准确}
    property CodeWrapMode: TCnCodeWrapMode read FCodeWrapMode write FCodeWrapMode;
    {* 代码换行的设置}
    property KeepLineBreak: Boolean read FKeepLineBreak write FKeepLineBreak;
    {* 由外界设置的保留换行标记，为 True 时无需处理自动换行}
    property KeepLineBreakIndentWritten: Boolean read FKeepLineBreakIndentWritten write FKeepLineBreakIndentWritten;
    {* 由外界设置的、保留换行后写过行前导空格的标记，由自己清除}
    property PrevRow: Integer read GetPrevRow;
    {* 一次 Write 成功后，写之前的光标行号，0 开始。
      可能与实际情况不符，因为 Write 可能自行写回车换行符}
    property PrevColumn: Integer read GetPrevColumn;
    {* 一次 Write 成功后，写之前的光标列号，0 开始}
    property CurrRow: Integer read GetCurrRow;
    {* 一次 Write 成功后，写之后的光标行号，0 开始。
      可能与实际情况不符，因为 Write 可能自行写回车换行符}
    property CurrColumn: Integer read GetCurrColumn;
    {* 一次 Write 成功后，写之后的光标列号，0 开始}

    property ActualRow: Integer read GetActualRow;
    {* 一次 Write 成功后，写之后的实际光标行号，回车换行已换算，从 1 开始}

    property LastLine: string read GetLastLine;
    {* 获得最后输出的一行内容}
    property NextOutputWillbeLineHead: Boolean read GetNextOutputWillbeLineHead;
    {* 下一个输出内容是否是新起一行，其实就是判断 Trim(GetLastLine) 是否为空 }

    property AutoWrapButNoIndent: Boolean read FAutoWrapButNoIndent write FAutoWrapButNoIndent;
    {* 超宽时自动换行时是否缩进，供外界控制，如 uses 区用 True}
    property OnAfterWrite: TCnAfterWriteEvent read FOnAfterWrite write FOnAfterWrite;
    {* 写内容一次成功后被调用}
    property OnGetInIgnore: TCnGetInIgnoreEvent read FOnGetInIgnore write FOnGetInIgnore;
    {* 欲获得外界 Scaner 是否在忽略区时调用}
{$IFDEF DEBUG}
    property DebugCodeString: string read GetDebugCodeString;
    {* 调试模式下返回 FCode 的全部内容}
{$ENDIF}
  end;

implementation

{ TCnCodeGenerator }

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CRLF = #13#10;
  NOTLineHeadChars: set of Char = ['.', ',', ':', ')', ']', ';'];
  NOTLineTailChars: set of Char = ['.', '(', '[', '@', '&'];

procedure TCnCodeGenerator.BackSpaceLastSpaces;
var
  S: string;
  Len: Integer;
begin
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    Len := Length(S);
    if (Len > 0) and (S[Len] = ' ') then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('CodeGen: BackSpaceLastSpaces');
{$ENDIF}
      FCode[FCode.Count - 1] := TrimRight(S);
    end;
  end;
  if FActualLines.Count > 0 then
  begin
    S := FActualLines[FActualLines.Count - 1];
    Len := Length(S);
    if (Len > 0) and (S[Len] = ' ') then
      FActualLines[FActualLines.Count - 1] := TrimRight(S);
  end;
end;

procedure TCnCodeGenerator.BackSpaceEmptyLines;
begin
  while IsLastLineSpaces do
  begin
    if FCode.Count > 0 then
      FCode.Delete(FCode.Count - 1);
    if FActualLines.Count > 0 then
      FActualLines.Delete(FActualLines.Count - 1);
  end;
end;

procedure TCnCodeGenerator.TrimLastEmptyLine;
var
  S: string;
  I, Len: Integer;
begin
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    Len := Length(S);
    if Len > 0 then
    begin
      for I := 1 to Len do
      begin
        if S[I] <> ' ' then
          Exit;
      end;

      FCode[FCode.Count - 1] := '';
{$IFDEF DEBUG}
      CnDebugger.LogFmt('GodeGen: TrimLastEmptyLine %d Spaces.', [Len]);
{$ENDIF}

      S := FActualLines[FActualLines.Count - 1];
      Len := Length(S);
      if Len > 0 then
      begin
        for I := 1 to Len do
        begin
          if S[I] <> ' ' then
            Exit;
        end;

        FActualLines[FActualLines.Count - 1] := '';
{$IFDEF DEBUG}
        CnDebugger.LogFmt('GodeGen: FActualLines TrimLastEmptyLine %d Spaces.', [Len]);
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnCodeGenerator.BackSpaceSpaceLineIndent(Indent: Integer);
var
  S: string;
  I, Len: Integer;
begin
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    Len := Length(S);
    if Len > Indent then
    begin
      for I := 1 to Len do
      begin
        if S[I] <> ' ' then
          Exit;
      end;

      FCode[FCode.Count - 1] := Copy(S, 1, Len - Indent);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('GodeGen: BackSpaceSpaceLineIndent %d Spaces.', [Indent]);
{$ENDIF}

      S := FActualLines[FActualLines.Count - 1];
      Len := Length(S);
      if Len > Indent then
      begin
        for I := 1 to Len do
        begin
          if S[I] <> ' ' then
            Exit;
        end;

        FActualLines[FActualLines.Count - 1] := Copy(S, 1, Len - Indent);
{$IFDEF DEBUG}
        CnDebugger.LogFmt('GodeGen: FActualLines TrimLastEmptyLine %d Spaces.', [Len]);
{$ENDIF}
      end;
    end;
  end;
end;

function TCnCodeGenerator.IsLastLineEmpty: Boolean;
begin
  if FCode.Count > 0 then
    Result := FCode[FCode.Count - 1] = ''
  else
    Result := False
end;

procedure TCnCodeGenerator.CheckAndWriteOneEmptyLine;
begin
  FEnsureEmptyLine := True;
  Writeln;
  FEnsureEmptyLine := False;
end;

procedure TCnCodeGenerator.ClearOutputLock;
begin
  FLock := 0;
end;

function TCnCodeGenerator.CopyPartOut(StartRow, StartColumn, EndRow,
  EndColumn: Integer): string;
var
  I: Integer;
begin
  Result := '';
  if EndRow > FCode.Count - 1 then
    EndRow := FCode.Count - 1;

  if EndRow < StartRow then Exit;
  if (EndRow = StartRow) and (EndColumn < StartColumn) then Exit;

  Inc(StartColumn); // 是否加一见 FColumnPos 的注释
  // Inc(EndColumn);

  if EndRow = StartRow then
    Result := Copy(FCode[StartRow], StartColumn, EndColumn - StartColumn + 1) // 加一是因为 StartColumn 加了一
  else
  begin
    for I := StartRow to EndRow do
    begin
      if I = StartRow then
        Result := Result + Copy(FCode[StartRow], StartColumn, MaxInt) + CRLF
      else if I = EndRow then
        Result := Result + Copy(FCode[EndRow], 1, EndColumn)
      else
        Result := Result + FCode[I] + CRLF;
    end;
  end;
end;

constructor TCnCodeGenerator.Create;
begin
  FCode := TStringList.Create;
  FLock := 0;
  FCodeWrapMode := cwmNone;
  FAutoWrapLines := TList.Create;
  FActualLines := TStringList.Create;
  FActualWriteHelper := TStringList.Create;
end;

destructor TCnCodeGenerator.Destroy;
begin
  FActualWriteHelper.Free;
  FActualLines.Free;
  FAutoWrapLines.Free;
  FCode.Free;
  inherited;
end;

procedure TCnCodeGenerator.DoAfterWrite(IsWriteln: Boolean; PrefixSpaces: Integer);
begin
  if Assigned(FOnAfterWrite) then
    FOnAfterWrite(Self, FWritingBlank, IsWriteln, PrefixSpaces);
end;

function TCnCodeGenerator.GetActualRow: Integer;
var
  List: TStrings;
begin
  List := TStringList.Create;
  List.Text := FCode.Text;
  Result := List.Count; // ActualRow 从 1 开始
  List.Free;
end;

function TCnCodeGenerator.GetCurIndentSpace: Integer;
var
  I, Len: Integer;
begin
  Result := 0;
  if FCode.Count > 0 then
  begin
    Len := Length(FCode[FCode.Count - 1]);
    if Len > 0 then
    begin
      for I := 1 to Len do
        if FCode[FCode.Count - 1][I] in [' ', #09] then
          Inc(Result)
        else
          Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetCurrColumn: Integer;
begin
  Result := FColumnPos;
end;

function TCnCodeGenerator.GetCurrRow: Integer;
begin
  Result := FCode.Count - 1;
end;

{$IFDEF DEBUG}

function TCnCodeGenerator.GetDebugCodeString: string;
var
  I: Integer;
begin
  if (FCode = nil) or (FCode.Count = 0) then
  begin
    Result := '<none>';
    Exit;
  end;

  Result := '';
  for I := 0 to FCode.Count - 1 do
  begin
    Result := Result + Format('%d:%s', [I, FCode[I]]);
    if I < FCode.Count - 1 then
      Result := Result + CRLF;
  end;
end;

{$ENDIF}

function TCnCodeGenerator.GetLastIndentSpaceWithOutComments: Integer;
var
  I, Len: Integer;
  S: string;

  function IsAutoWrapLineNumber(Line: Integer): Boolean;
  var
    J: Integer;
  begin
    Result := True;
    for J := FAutoWrapLines.Count - 1 downto 0 do
    begin
      if Integer(FAutoWrapLines[J]) = Line then
        Exit;
    end;

    Result := False;
  end;

begin
  Result := 0;

  S := '';
  for I := FActualLines.Count - 1 downto 0 do
  begin
    // 注意此处 IsAutoWrapLineNumber 的判断在保留换行为 True 时并不符合实际情况，
    // 保留换行时多出来的行没有自动换行记录，因此 IsAutoWrapLineNumber 会返回 False
    // 保留换行新增的行会被错误地当作主行处理，导致后面多出一块缩进。
    // 所以该函数外部进行了判断以减少一次不必要的缩进
    if (FActualLines[I] <> '') and not IsAutoWrapLineNumber(I) and not
      LineIsEmptyOrComment(FActualLines[I]) then
    begin
      S := FActualLines[I];
      Break;
    end;
  end;

  if S = '' then
    Exit;

  // 此时 S 是最后一个有内容的并且不是注释的并且不是自动换行的行，把 S 的左边空格长度整过来
  Len := Length(S);
  if Len > 0 then
  begin
    for I := 1 to Len do
    begin
      if S[I] in [' ', #09] then
        Inc(Result)
      else
        Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetLastLine: string;
begin
  if FActualLines.Count > 0 then
    Result := FActualLines[FActualLines.Count - 1]
  else
    Result := '';
end;

function TCnCodeGenerator.GetLockedCount: Word;
begin
  Result := FLock;
end;

function TCnCodeGenerator.GetNextOutputWillbeLineHead: Boolean;
begin
  Result := Trim(GetLastLine) = '';
end;

function TCnCodeGenerator.GetPrevColumn: Integer;
begin
  Result := FPrevColumn;
end;

function TCnCodeGenerator.GetPrevRow: Integer;
begin
  Result := FPrevRow;
end;

procedure TCnCodeGenerator.InternalWriteln;
begin
  if FLock <> 0 then Exit;

  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FCode.Add('');

  FActualLines[FActualLines.Count - 1] := TrimRight(FActualLines[FActualLines.Count - 1]);
  FActualLines.Add('');

  FColumnPos := 0;
  FActualColumn := 0;
  FLastExceedPosition := 0;
  FJustWrittenCommentEndLn := False;
end;

function TCnCodeGenerator.LineIsEmptyOrComment(const Str: string): Boolean;
var
  Line: string;
  I: Integer;
  InComment1, InComment2: Boolean;
begin
  Result := False;
  Line := Trim(Str);
  if Length(Line) = 0 then
  begin
    Result := True;
    Exit;
  end;

  InComment1 := False;
  InComment2 := False;
  I := 1;
  while I <= Length(Line) do
  begin
    if Line[I] = '{' then
      InComment1 := True
    else if Line[I] = '}' then
      InComment1 := False
    else if (Line[I] = '(') and ((I < Length(Line)) and (Line[I + 1] = '*')) then
    begin
      InComment2 := True;
      Inc(I);
    end
    else if (Line[I] = '*') and ((I < Length(Line)) and (Line[I + 1] = ')')) then
    begin
      InComment2 := False;
      Inc(I);
    end
    else if not InComment1 and not InComment2 then
    begin
      // 当前不是在两种括号注释内的话
      if (Line[I] = '/') and ((I < Length(Line)) and (Line[I + 1] = '/')) then
      begin
        // 后面是整行注释
        Result := True;
        Exit;
      end;

      if Line[I] >= ' ' then // 有非空白字符，直接返回 False
        Exit;
    end;

    Inc(I);
  end;
  Result := True;
end;

procedure TCnCodeGenerator.LockOutput;
begin
  Inc(FLock);
end;

procedure TCnCodeGenerator.RecordAutoWrapLines(Line: Integer);
begin
  if FAutoWrapLines.Count = 0 then
    FAutoWrapLines.Add(Pointer(Line))
  else if FAutoWrapLines[FAutoWrapLines.Count - 1] <> Pointer(Line) then
    FAutoWrapLines.Add(Pointer(Line));
end;

procedure TCnCodeGenerator.Reset;
begin
  FCode.Clear;
  FAutoWrapLines.Clear;
end;

procedure TCnCodeGenerator.SaveToFile(FileName: String);
begin
  FCode.SaveToFile(FileName);
end;

procedure TCnCodeGenerator.SaveToStream(Stream: TStream);
begin
  FCode.SaveToStream(Stream {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});
end;

procedure TCnCodeGenerator.SaveToStrings(AStrings: TStrings);
begin
  AStrings.Assign(FCode);
end;

function TCnCodeGenerator.SourcePos: Word;
begin
  Result := Length(FCode[FCode.Count - 1]);
end;

procedure TCnCodeGenerator.UnLockOutput;
begin
  Dec(FLock);
end;

procedure TCnCodeGenerator.Write(const Text: string; BeforeSpaceCount,
  AfterSpaceCount: Word; NeedPadding: Boolean; NeedUnIndent: Boolean);
var
  Str, WrapStr, Tmp, S: string;
  ThisCanBeHead, PrevCanBeTail, IsCRLFSpace, IsAfterCommentAuto, InIgnore: Boolean;
  Len, Blanks, LastSpaces, CRLFPos, I, TmpWrapWidth: Integer;

  function ExceedLineWrap(Width: Integer): Boolean;
  begin
    Result := ((FActualColumn <= Width) and
      (FActualColumn + Len > Width)) or
      (FActualColumn > Width);
  end;

  // 获得一个字符串最后一行的长度
  function ActualColumn(const S: string): Integer;
  var
    LPos: Integer;
  begin
    if Pos(CRLF, S) > 0 then
    begin
      LPos := LastDelimiter(#10, S);
      Result := Length(S) - LPos;
    end
    else
      Result := Length(S);
  end;

  // 获得一个字符串最后一行的长度
  function AnsiActualColumn(const S: AnsiString): Integer;
  var
    LPos: Integer;
  begin
    if Pos(CRLF, S) > 0 then
    begin
      LPos := LastDelimiter(#10, S);
      Result := Length(S) - LPos;
    end
    else
      Result := Length(S);
  end;

  // 某些单个字符不宜做行头
  function StrCanBeHead(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineHeadChars) then
      Result := False;
  end;

  // 某些单个字符不宜做行尾
  function StrCanBeTail(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineTailChars) then
      Result := False;
  end;

  // 是否字符串包括至少一个回车换行并且其余只包含空格或 Tab
  function IsTextCRLFSpace(const S: string; out TrailBlanks: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    TrailBlanks := 0;
    I := Pos(CRLF, S);
    if I <= 0 then // 无回车换行，返回 False
      Exit;

    for I := 1 to Length(S) do
    begin
      if not (S[I] in [' ', #09, #13, #10]) then
        Exit;
    end;

    Result := True;
    I := LastDelimiter(#10, S);
    TrailBlanks := Length(S) - I;
  end;

  // 字符串头部连续的空格数
  function HeadSpaceCount(const S: string): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    if Length(S) > 0 then
    begin
      for I := 1 to Length(S) do
      begin
        if S[I] = ' ' then
          Inc(Result)
        else
          Exit;
      end;
    end;
  end;

  function IsAllSpace(const S: string): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    if S = '' then
      Exit;

    for K := 1 to Length(S) do
    begin
      if S[K] <> ' ' then
        Exit;
    end;
    Result := True;
  end;

begin
  if FLock <> 0 then Exit;

  if FCode.Count = 0 then
    FCode.Add('');
  if FActualLines.Count = 0 then
    FActualLines.Add('');

  ThisCanBeHead := StrCanBeHead(Text);
  PrevCanBeTail := StrCanBeTail(FPrevStr);

  // 外部保留换行时，行头如果是空格缩进，本次不写多余的缩进（暂且只忽略空格为 1 的情况）
  if FKeepLineBreak and FKeepLineBreakIndentWritten and (BeforeSpaceCount = 1) then
    BeforeSpaceCount := 0;
  FKeepLineBreakIndentWritten := False;

  Str := Format('%s%s%s', [StringOfChar(' ', BeforeSpaceCount), Text,
    StringOfChar(' ', AfterSpaceCount)]);

{$IFDEF UNICODE}
  Len := AnsiActualColumn(AnsiString(TrimRight(Str))); // Unicode 模式下，转成 Ansi 长度才符合一般规则
{$ELSE}
  Len := ActualColumn(TrimRight(Str)); // Ansi 模式下，长度直接符合一般规则
{$ENDIF}

  FPrevRow := FCode.Count - 1;
  InIgnore := False;
  if Assigned(FOnGetInIgnore) then
    InIgnore := FOnGetInIgnore(Self);

  if (FCodeWrapMode = cwmNone) or FKeepLineBreak or InIgnore then
  begin
    // 不自动换行时无需处理，
  end
  else if (FCodeWrapMode = cwmSimple) or ( (FCodeWrapMode = cwmAdvanced) and
    (CnPascalCodeForRule.WrapWidth >= CnPascalCodeForRule.WrapNewLineWidth) ) then
  begin
    if FCodeWrapMode = cwmSimple then // 简单模式下，是 uses 区，使用单独的宽度设置
      TmpWrapWidth := CnPascalCodeForRule.UsesLineWrapWidth
    else
      TmpWrapWidth := CnPascalCodeForRule.WrapWidth;

    // 简单换行，或复杂换行但行值设置不对，就简单判断是否超出宽度
    if (FPrevStr <> '.') and ExceedLineWrap(TmpWrapWidth)
      and ThisCanBeHead and PrevCanBeTail then // Dot in unitname should not new line.
    begin
      // “上次输出的字符串能做尾并且本次输出的字符串能做头”才换行
      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(Str);
        // 加上原有的缩进，不要直接再缩进一格，避免 uses 区出现不必要的缩进。
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpaceWithOutComments + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(Str); // 自动换行后左边原有的空格就不需要了
        // 找出上一次非自动缩进的缩进，而不是简单的上一行缩进值，避免多重缩进
      end;
      InternalWriteln;
      RecordAutoWrapLines(FActualLines.Count - 1); // 自动换行的行号要记录
    end;
  end
  else if FCodeWrapMode = cwmAdvanced then
  begin
    // 高级。超出大行后，回溯到从小行处开始换行
    if ExceedLineWrap(CnPascalCodeForRule.WrapWidth)
      and ThisCanBeHead and PrevCanBeTail and (FLastExceedPosition = 0) then
    begin
      // 第一次超小行时，并且“上次输出的字符串能做尾并且本次输出的字符串能做头”时，照常输出，记录输出前小行待回溯的位置
      // 如果字符不能做行尾，则此处不进入
      FLastExceedPosition := FColumnPos;
    end
    else if (FPrevStr <> '.') and (FLastExceedPosition > 0) and // 有可换行之处才换
      ExceedLineWrap(CnPascalCodeForRule.WrapNewLineWidth) then
    begin
      WrapStr := Copy(FCode[FCode.Count - 1], FLastExceedPosition + 1, MaxInt);
      Tmp := FCode[FCode.Count - 1];
      Delete(Tmp, FLastExceedPosition + 1, MaxInt);
      FCode[FCode.Count - 1] := Tmp;

      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(WrapStr) + Str;
        // 加上原有的缩进，不要直接再缩进一格，避免 uses 区出现不必要的缩进。
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpaceWithOutComments + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(WrapStr) + Str; // 自动换行后左边原有的空格就不需要了
        // 找出上一次非自动缩进的缩进，而不是简单的上一行缩进值，避免多重缩进
        // 然而上一次非自动缩进的缩进如果是由于上上一行的带换行的注释引入，
        // 则很可能不符合自动换行的缩进规则，还是会引起本行不必要的多余缩进
      end;
      InternalWriteln;
      RecordAutoWrapLines(FActualLines.Count - 1); // 自动换行的行号要记录
    end;
  end;

  // 如果上一次输出的内容是//行尾注释包括回车结尾，并且外头要求 Padding，
  // 并且本次输出如果头部空格太少，则根据某基数缩进，这个基数是上面最近一行符合
  // 以下条件的：非自动换行的行，非本行这种缩进行，非纯注释行。
  IsAfterCommentAuto := False;
  if NeedPadding and FJustWrittenCommentEndLn then
  begin
    LastSpaces := LastIndentSpaceWithOutComments;
    if (HeadSpaceCount(Str) < LastSpaces) or (LastSpaces = 0) then
    begin
      if (FCodeWrapMode = cwmSimple) or KeepLineBreak then // uses 区无需进一步缩进
        I := LastSpaces     // 注意：LastIndentSpaceWithOutComments 的判断因与保留换行为 True 冲突，得忽略一次缩进
      else
        I := LastSpaces + CnPascalCodeForRule.TabSpaceCount;

      if NeedUnIndent then
        Dec(I, CnPascalCodeForRule.TabSpaceCount);

      // 不能直接加上 Tab 个空格，还得考虑末尾行已经被写入了一批空格的情况
      if FActualLines.Count > 0 then
      begin
        Tmp := FActualLines[FActualLines.Count - 1];
        if IsAllSpace(Tmp) then
          Dec(I, Length(Tmp));

        if I < 0 then
          I := 0;
      end;
      Str := StringOfChar(' ', I) + TrimLeft(Str);
    end;
    IsAfterCommentAuto := True;
  end;

  FCode[FCode.Count - 1] :=
    Format('%s%s', [FCode[FCode.Count - 1], Str]);

  CRLFPos := Pos(CRLF, Str);
  if CRLFPos > 0 then
  begin
    // 如果本次写入的内容有回车换行，则将上次该换行的位置置零
    FLastExceedPosition := 0;

    // 不能直接用 TStringList 的 Text 赋值再转回，会造成空行以及两头尾丢失
    S := '';
    Tmp := Str;
    FActualWriteHelper.Clear;
    repeat
      S := Copy(Tmp, 1, CRLFPos - 1);
      FActualWriteHelper.Add(S);
      Delete(Tmp, 1, CRLFPos - 1 + Length(CRLF));
      CRLFPos := Pos(CRLF, Tmp);
    until CRLFPos = 0;
    FActualWriteHelper.Add(Tmp);

    FActualLines[FActualLines.Count - 1] :=
      Format('%s%s', [FActualLines[FActualLines.Count - 1], FActualWriteHelper[0]]);

    if FActualWriteHelper.Count > 1 then
    begin
      for I := 1 to FActualWriteHelper.Count - 1 do
        FActualLines.Add(FActualWriteHelper[I]);
    end;
  end
  else
  begin
    FActualLines[FActualLines.Count - 1] :=
      Format('%s%s', [FActualLines[FActualLines.Count - 1], Str]);
  end;
  // 同步更新 FCode 和 FActualLines

  // 输出完毕后，记录本行被上一行注释调整过，不能算作 LastIndentSpace，算自动换行的行号
  if IsAfterCommentAuto then
    RecordAutoWrapLines(FActualLines.Count - 1);

  FPrevColumn := FColumnPos;
  FPrevStr := Text;

  Str := FCode[FCode.Count - 1];
  FColumnPos := Length(Str);
  FActualColumn := ActualColumn(Str);

  IsCRLFSpace := IsTextCRLFSpace(Text, Blanks);

  if not FWritingBlank then
    FJustWrittenCommentEndLn := False;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('GodeGen: String Wrote from %5.5d %5.5d to %5.5d %5.5d: %s', [FPrevRow, FPrevColumn,
    GetCurrRow, GetCurrColumn, Str]);
{$ENDIF}

  DoAfterWrite(IsCRLFSpace, Blanks);

{$IFDEF DEBUG}
//  CnDebugger.LogMsg(CopyPartOut(FPrevRow, FPrevColumn, GetCurrRow, GetCurrColumn));
{$ENDIF}
end;

procedure TCnCodeGenerator.WriteBlank(const Text: string);
begin
  FWritingBlank := True;
  Write(Text);
  FWritingBlank := False;
end;

procedure TCnCodeGenerator.WriteCommentEndln;
begin
  if FLock <> 0 then Exit;

  FWritingCommentEndLn := True;
  Writeln;
  FWritingCommentEndLn := False;
  FJustWrittenCommentEndLn := True;
  // 如果连续调用两次 WriteCommentEndln，则会漏掉后一次，但似乎没这种场景。
end;

procedure TCnCodeGenerator.Writeln;
var
  Wrote: Boolean;

  function TrimRightWithoutCRLF(const S: string): string;
  var
    I: Integer;
  begin
    I := Length(S);
    while (I > 0) and (S[I] <= ' ') and not (S[I] in [#13, #10]) do
      Dec(I);

    Result := Copy(S, 1, I);
  end;

  // 判断 FCode 最尾巴上是不是连续俩回车换行
  function HasLastOneEmptyLine: Boolean;
  var
    C: Integer;
  begin
    Result := False;
    C := FActualLines.Count;
    if (C > 1) and (FActualLines[C - 1] = '') and (FActualLines[C - 2] = '') then
      Result := True;
  end;

begin
  if FLock <> 0 then Exit;
  Wrote := False;
  // Write(S, BeforeSpaceCount, AfterSpaceCount);
  // must delete trailing blanks, but can't use TrimRight for Deleting CRLF at line end.
  FCode[FCode.Count - 1] := TrimRightWithoutCRLF(FCode[FCode.Count - 1]);
  FPrevRow := FCode.Count - 1;

  FActualLines[FActualLines.Count - 1] := TrimRight(FActualLines[FActualLines.Count - 1]);

  // 如果上一个输出是注释块的结尾换行，且本次不是输出注释尾，则本次 Writeln 忽略
  if not FWritingCommentEndLn and FJustWrittenCommentEndLn then
  begin
    FJustWrittenCommentEndLn := False;
  end
  else if FEnsureEmptyLine and HasLastOneEmptyLine then // 如果已经有一个空行了，并且外界要求保证一个空行，则忽略
  begin
    FJustWrittenCommentEndLn := False;
  end
  else
  begin
    FCode.Add('');
    FActualLines.Add('');
    Wrote := True;
  end;

  FPrevColumn := FColumnPos;
  FColumnPos := 0;
  FActualColumn := 0;
  FLastExceedPosition := 0;

  FJustWrittenCommentEndLn := False;

{$IFDEF DEBUG}
  if Wrote then
    CnDebugger.LogFmt('GodeGen: NewLine Wrote from %d %d to %d %d', [FPrevRow, FPrevColumn,
      GetCurrRow, GetCurrColumn]);
{$ENDIF}
  if Wrote then
    DoAfterWrite(True);
end;

procedure TCnCodeGenerator.WriteOneSpace;
var
  S: string;
  Old: Boolean;
begin
  if FLock <> 0 then Exit;

  // 如果上一个是空格，则忽略
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    if (Length(S) > 0) and (S[Length(S)] = ' ') then
      Exit;
  end;

{$IFDEF DEBUG}
  if DebugCodeString = '' then  // Make DebugCodeString useful and not ignored by Linker.
    Exit;
{$ENDIF}

  // 写入空格需要不影响上一行关于是否是行注释结尾的判断
  Old := FJustWrittenCommentEndLn;
  Write(' ');
  FJustWrittenCommentEndLn := Old;
end;

function TCnCodeGenerator.IsLast2LineEmpty: Boolean;
begin
  Result := False;
  if FCode.Count > 1 then
    Result := (FCode[FCode.Count - 1] = '') and (FCode[FCode.Count - 2] = '');
end;

function TCnCodeGenerator.IsLastLineSpaces: Boolean;
var
  S: string;
  Len, I: Integer;
begin
  Result := False;
  if FCode.Count > 0 then
  begin
    S := FCode[FCode.Count - 1];
    Len := Length(S);
    if Len > 0 then
    begin
      for I := 1 to Len do
      begin
        if (S[I] <> ' ') and (S[I] <> #09) then
          Exit;
      end;
    end;
  end;
  Result := True;
end;

end.
