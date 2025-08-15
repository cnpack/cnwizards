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

unit CnCodeGenerators;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ���ʽ��������������� CnCodeGenerators
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ���˴����ʽ������Ĳ���������
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* �޸ļ�¼��2015.10.12 V1.1
*               ����ע�ͺ�Ļ��������ⲿд�룬�˴����ٷ���д�������Ƿ�ע���뻻�н�β��
*           2007.10.13 V1.0
*               ���뻻�еĲ������ô����������ơ�
*           2003.12.16 V0.1
*               �������򵥵Ĵ�������д���Լ����������
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
    FCode: TStrings;                // �洢������ݣ������п�����ע������Ļس�����
    FActualLines: TStrings;         // �洢�淶�˵�������ݣ�Ҳ���ǲ������س�����
    FActualWriteHelper: TStrings;
    FLock: Word;
    FColumnPos: Integer;            // ��ǰ��ֵ��ע������ʵ�������һ��һ�£���Ϊ FCode �е��ַ������ܴ��س�����
    FActualColumn: Integer;         // ��ǰʵ����ֵ������ FCode ���һ�����һ�� #13#10 �������
    FCodeWrapMode: TCnCodeWrapMode;
    FPrevStr: string;
    FPrevRow: Integer;
    FPrevColumn: Integer;
    FLastExceedPosition: Integer; // ���г��� WrapWidth �ĵ㣬����β����ʱ�������»���ʹ��
    FAutoWrapLines: TList;        // ��¼�Զ����е��кţ�������Ѱ���һ�η��Զ����е���������
    // ע���кŴ洢���ǹ淶�С�

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
    // �� IsWriteln Ϊ True ʱ��PrefixSpaces ��ʾ����д��س������д�Ŀո���������Ϊ 0
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Write(const Text: string; BeforeSpaceCount:Word = 0;
      AfterSpaceCount: Word = 0; NeedPadding: Boolean = False; NeedUnIndent: Boolean = False);
    procedure WriteOneSpace;
    // ����ʽ��д����еĵ����ָ��ո��ã����ж��Ƿ�����ע�ʹ����Ŀո�������Ƿ�дһ���ո�
    // NeedUnIndent ָ�ⲿ��Ҫ���˿ո񣬽��� NeedPadding Ϊ True ʱ��Ч

    procedure WriteBlank(const Text: string);
    procedure InternalWriteln;
    procedure Writeln;
    procedure WriteCommentEndln;
    procedure CheckAndWriteOneEmptyLine;
    function SourcePos: Word;
    {* ���һ�й��������������δʹ��}
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: string);
    procedure SaveToStrings(AStrings: TStrings);

    function CopyPartOut(StartRow, StartColumn, EndRow, EndColumn: Integer): string;
    {* �������ָ����ֹλ�ø������ݳ�����ֱ��ʹ�� Row/Column �������
       �߼��ϣ����Ʒ�Χ�ڵ����ݲ����� EndColumn ��ָ���ַ�}

    procedure BackSpaceLastSpaces;
    {* �����һ�е���β�ո�ɾ��һ����������Ϊ�Ѿ�����˴��ո�����ݣ�������βע�ͺ��Ƶ�����
      ע�� Scanner �ں�����ʱ��Ҫ���ã�����������Ŀո���ʧ}
    procedure TrimLastEmptyLine;
    {* ������һ����ȫ�ո���������е����пո����ڱ������еĳ���}
    procedure BackSpaceEmptyLines;
    {* ������� Directive �޾�ĩ�ֺŶ�д�ģ�ɾ��β�����д��ո��еķ��������ϸ�����ʹ���Ա��⸱����}
    procedure BackSpaceSpaceLineIndent(Indent: Integer = 2);
    {* ������һ��ȫ�ǿո��ҿո����� Indent �࣬����� Indent ���ո�
      ������Ա�������ʱ�������õ�ĩ���Ŷ��Եģ����ϸ�����ʹ���Ա��⸱����}

    function IsLastLineEmpty: Boolean;
    {* ���һ���Ƿ����һ����ȫ�Ŀ��У�����س�����}
    function IsLastLineSpaces: Boolean;
    {* ���һ���Ƿ�Ϳո�� Tab������س�����}
    function IsLast2LineEmpty: Boolean;
    {* ��������Ƿ�������س��������������Ҳ���� False}

    procedure LockOutput;
    procedure UnLockOutput;

    procedure ClearOutputLock;
    {* ֱ�ӽ������������}

    property LockedCount: Word read GetLockedCount;
    {* �������}
    property ColumnPos: Integer read FColumnPos;
    {* ��ǰ���ĺ���λ�ã����ڻ��С�ֵΪ��ǰ�г��ȣ���ǰ�иջ���������ʱΪ 0��
       �������Ϊָ��ǰ�Ѿ�������ݵĽ��ں��λ�á�����Ϊ StartCol ʱ�ü�һ��
       ����Ϊ EndCol ʱ����Ϊ��ǰ���ַ����±��һ��ʼ�ĵ� FColumnPos ���ַ���
       ������ CopyPartout �����һ���ַ�����������һ}
    property CurIndentSpace: Integer read GetCurIndentSpace;
    {* ��ǰ����ǰ��Ŀո���}
    property LastIndentSpaceWithOutComments: Integer read GetLastIndentSpaceWithOutComments;
    {* ��һ�����Զ����Լ���ע�͵��е���ǰ��Ŀո�����ע���ڱ�������ʱ��׼ȷ}
    property CodeWrapMode: TCnCodeWrapMode read FCodeWrapMode write FCodeWrapMode;
    {* ���뻻�е�����}
    property KeepLineBreak: Boolean read FKeepLineBreak write FKeepLineBreak;
    {* ��������õı������б�ǣ�Ϊ True ʱ���账���Զ�����}
    property KeepLineBreakIndentWritten: Boolean read FKeepLineBreakIndentWritten write FKeepLineBreakIndentWritten;
    {* ��������õġ��������к�д����ǰ���ո�ı�ǣ����Լ����}
    property PrevRow: Integer read GetPrevRow;
    {* һ�� Write �ɹ���д֮ǰ�Ĺ���кţ�0 ��ʼ��
      ������ʵ�������������Ϊ Write ��������д�س����з�}
    property PrevColumn: Integer read GetPrevColumn;
    {* һ�� Write �ɹ���д֮ǰ�Ĺ���кţ�0 ��ʼ}
    property CurrRow: Integer read GetCurrRow;
    {* һ�� Write �ɹ���д֮��Ĺ���кţ�0 ��ʼ��
      ������ʵ�������������Ϊ Write ��������д�س����з�}
    property CurrColumn: Integer read GetCurrColumn;
    {* һ�� Write �ɹ���д֮��Ĺ���кţ�0 ��ʼ}

    property ActualRow: Integer read GetActualRow;
    {* һ�� Write �ɹ���д֮���ʵ�ʹ���кţ��س������ѻ��㣬�� 1 ��ʼ}

    property LastLine: string read GetLastLine;
    {* �����������һ������}
    property NextOutputWillbeLineHead: Boolean read GetNextOutputWillbeLineHead;
    {* ��һ����������Ƿ�������һ�У���ʵ�����ж� Trim(GetLastLine) �Ƿ�Ϊ�� }

    property AutoWrapButNoIndent: Boolean read FAutoWrapButNoIndent write FAutoWrapButNoIndent;
    {* ����ʱ�Զ�����ʱ�Ƿ��������������ƣ��� uses ���� True}
    property OnAfterWrite: TCnAfterWriteEvent read FOnAfterWrite write FOnAfterWrite;
    {* д����һ�γɹ��󱻵���}
    property OnGetInIgnore: TCnGetInIgnoreEvent read FOnGetInIgnore write FOnGetInIgnore;
    {* �������� Scaner �Ƿ��ں�����ʱ����}
{$IFDEF DEBUG}
    property DebugCodeString: string read GetDebugCodeString;
    {* ����ģʽ�·��� FCode ��ȫ������}
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

  Inc(StartColumn); // �Ƿ��һ�� FColumnPos ��ע��
  // Inc(EndColumn);

  if EndRow = StartRow then
    Result := Copy(FCode[StartRow], StartColumn, EndColumn - StartColumn + 1) // ��һ����Ϊ StartColumn ����һ
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
  Result := List.Count; // ActualRow �� 1 ��ʼ
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
    // ע��˴� IsAutoWrapLineNumber ���ж��ڱ�������Ϊ True ʱ��������ʵ�������
    // ��������ʱ���������û���Զ����м�¼����� IsAutoWrapLineNumber �᷵�� False
    // ���������������лᱻ����ص������д������º�����һ��������
    // ���Ըú����ⲿ�������ж��Լ���һ�β���Ҫ������
    if (FActualLines[I] <> '') and not IsAutoWrapLineNumber(I) and not
      LineIsEmptyOrComment(FActualLines[I]) then
    begin
      S := FActualLines[I];
      Break;
    end;
  end;

  if S = '' then
    Exit;

  // ��ʱ S �����һ�������ݵĲ��Ҳ���ע�͵Ĳ��Ҳ����Զ����е��У��� S ����߿ո񳤶�������
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
      // ��ǰ��������������ע���ڵĻ�
      if (Line[I] = '/') and ((I < Length(Line)) and (Line[I + 1] = '/')) then
      begin
        // ����������ע��
        Result := True;
        Exit;
      end;

      if Line[I] >= ' ' then // �зǿհ��ַ���ֱ�ӷ��� False
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

  // ���һ���ַ������һ�еĳ���
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

  // ���һ���ַ������һ�еĳ���
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

  // ĳЩ�����ַ���������ͷ
  function StrCanBeHead(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineHeadChars) then
      Result := False;
  end;

  // ĳЩ�����ַ���������β
  function StrCanBeTail(const S: string): Boolean;
  begin
    Result := True;
    if (Length(S) = 1) and (S[1] in NOTLineTailChars) then
      Result := False;
  end;

  // �Ƿ��ַ�����������һ���س����в�������ֻ�����ո�� Tab
  function IsTextCRLFSpace(const S: string; out TrailBlanks: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    TrailBlanks := 0;
    I := Pos(CRLF, S);
    if I <= 0 then // �޻س����У����� False
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

  // �ַ���ͷ�������Ŀո���
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

  // �ⲿ��������ʱ����ͷ����ǿո����������β�д���������������ֻ���Կո�Ϊ 1 �������
  if FKeepLineBreak and FKeepLineBreakIndentWritten and (BeforeSpaceCount = 1) then
    BeforeSpaceCount := 0;
  FKeepLineBreakIndentWritten := False;

  Str := Format('%s%s%s', [StringOfChar(' ', BeforeSpaceCount), Text,
    StringOfChar(' ', AfterSpaceCount)]);

{$IFDEF UNICODE}
  Len := AnsiActualColumn(AnsiString(TrimRight(Str))); // Unicode ģʽ�£�ת�� Ansi ���Ȳŷ���һ�����
{$ELSE}
  Len := ActualColumn(TrimRight(Str)); // Ansi ģʽ�£�����ֱ�ӷ���һ�����
{$ENDIF}

  FPrevRow := FCode.Count - 1;
  InIgnore := False;
  if Assigned(FOnGetInIgnore) then
    InIgnore := FOnGetInIgnore(Self);

  if (FCodeWrapMode = cwmNone) or FKeepLineBreak or InIgnore then
  begin
    // ���Զ�����ʱ���账��
  end
  else if (FCodeWrapMode = cwmSimple) or ( (FCodeWrapMode = cwmAdvanced) and
    (CnPascalCodeForRule.WrapWidth >= CnPascalCodeForRule.WrapNewLineWidth) ) then
  begin
    if FCodeWrapMode = cwmSimple then // ��ģʽ�£��� uses ����ʹ�õ����Ŀ������
      TmpWrapWidth := CnPascalCodeForRule.UsesLineWrapWidth
    else
      TmpWrapWidth := CnPascalCodeForRule.WrapWidth;

    // �򵥻��У����ӻ��е���ֵ���ò��ԣ��ͼ��ж��Ƿ񳬳����
    if (FPrevStr <> '.') and ExceedLineWrap(TmpWrapWidth)
      and ThisCanBeHead and PrevCanBeTail then // Dot in unitname should not new line.
    begin
      // ���ϴ�������ַ�������β���ұ���������ַ�������ͷ���Ż���
      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(Str);
        // ����ԭ�е���������Ҫֱ��������һ�񣬱��� uses �����ֲ���Ҫ��������
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpaceWithOutComments + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(Str); // �Զ����к����ԭ�еĿո�Ͳ���Ҫ��
        // �ҳ���һ�η��Զ������������������Ǽ򵥵���һ������ֵ�������������
      end;
      InternalWriteln;
      RecordAutoWrapLines(FActualLines.Count - 1); // �Զ����е��к�Ҫ��¼
    end;
  end
  else if FCodeWrapMode = cwmAdvanced then
  begin
    // �߼����������к󣬻��ݵ���С�д���ʼ����
    if ExceedLineWrap(CnPascalCodeForRule.WrapWidth)
      and ThisCanBeHead and PrevCanBeTail and (FLastExceedPosition = 0) then
    begin
      // ��һ�γ�С��ʱ�����ҡ��ϴ�������ַ�������β���ұ���������ַ�������ͷ��ʱ���ճ��������¼���ǰС�д����ݵ�λ��
      // ����ַ���������β����˴�������
      FLastExceedPosition := FColumnPos;
    end
    else if (FPrevStr <> '.') and (FLastExceedPosition > 0) and // �пɻ���֮���Ż�
      ExceedLineWrap(CnPascalCodeForRule.WrapNewLineWidth) then
    begin
      WrapStr := Copy(FCode[FCode.Count - 1], FLastExceedPosition + 1, MaxInt);
      Tmp := FCode[FCode.Count - 1];
      Delete(Tmp, FLastExceedPosition + 1, MaxInt);
      FCode[FCode.Count - 1] := Tmp;

      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(WrapStr) + Str;
        // ����ԭ�е���������Ҫֱ��������һ�񣬱��� uses �����ֲ���Ҫ��������
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpaceWithOutComments + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(WrapStr) + Str; // �Զ����к����ԭ�еĿո�Ͳ���Ҫ��
        // �ҳ���һ�η��Զ������������������Ǽ򵥵���һ������ֵ�������������
        // Ȼ����һ�η��Զ������������������������һ�еĴ����е�ע�����룬
        // ��ܿ��ܲ������Զ����е��������򣬻��ǻ������в���Ҫ�Ķ�������
      end;
      InternalWriteln;
      RecordAutoWrapLines(FActualLines.Count - 1); // �Զ����е��к�Ҫ��¼
    end;
  end;

  // �����һ�������������//��βע�Ͱ����س���β��������ͷҪ�� Padding��
  // ���ұ���������ͷ���ո�̫�٣������ĳ��������������������������һ�з���
  // ���������ģ����Զ����е��У��Ǳ������������У��Ǵ�ע���С�
  IsAfterCommentAuto := False;
  if NeedPadding and FJustWrittenCommentEndLn then
  begin
    LastSpaces := LastIndentSpaceWithOutComments;
    if (HeadSpaceCount(Str) < LastSpaces) or (LastSpaces = 0) then
    begin
      if (FCodeWrapMode = cwmSimple) or KeepLineBreak then // uses �������һ������
        I := LastSpaces     // ע�⣺LastIndentSpaceWithOutComments ���ж����뱣������Ϊ True ��ͻ���ú���һ������
      else
        I := LastSpaces + CnPascalCodeForRule.TabSpaceCount;

      if NeedUnIndent then
        Dec(I, CnPascalCodeForRule.TabSpaceCount);

      // ����ֱ�Ӽ��� Tab ���ո񣬻��ÿ���ĩβ���Ѿ���д����һ���ո�����
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
    // �������д��������лس����У����ϴθû��е�λ������
    FLastExceedPosition := 0;

    // ����ֱ���� TStringList �� Text ��ֵ��ת�أ�����ɿ����Լ���ͷβ��ʧ
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
  // ͬ������ FCode �� FActualLines

  // �����Ϻ󣬼�¼���б���һ��ע�͵��������������� LastIndentSpace�����Զ����е��к�
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
  // ��������������� WriteCommentEndln�����©����һ�Σ����ƺ�û���ֳ�����
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

  // �ж� FCode ��β�����ǲ����������س�����
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

  // �����һ�������ע�Ϳ�Ľ�β���У��ұ��β������ע��β���򱾴� Writeln ����
  if not FWritingCommentEndLn and FJustWrittenCommentEndLn then
  begin
    FJustWrittenCommentEndLn := False;
  end
  else if FEnsureEmptyLine and HasLastOneEmptyLine then // ����Ѿ���һ�������ˣ��������Ҫ��֤һ�����У������
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

  // �����һ���ǿո������
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

  // д��ո���Ҫ��Ӱ����һ�й����Ƿ�����ע�ͽ�β���ж�
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
