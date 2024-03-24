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

unit CnWizSearch;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：文本查找单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元修改自 GExperts 1.2a Src GX_Search.pas ，仅移植了查找基类
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2021.02.24 V1.1
*               增加检查 CRLF 的函数
*           2003.03.03 V1.0
*               移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnCommon, CnWizConsts, CnWizEditFiler;

type
  TSearchOption = (soCaseSensitive, soWholeWord, soRegEx);

  TSearchOptions = set of TSearchOption;

  TFoundEvent = procedure(Sender: TObject; LineNo: Integer; LineOffset: Integer;
    const Line: string; SPos, EPos: Integer) of object;

  ELineTooLong = class(Exception);
  EPatternError = class(Exception);

  TCnSearcher = class(TObject)
  private
    FOnFound: TFoundEvent;
    FOnStartSearch: TNotifyEvent;
    procedure SetANSICompatible(const Value: Boolean);
    procedure SetBufSize(New: Integer);
  protected
    procedure SignalStartSearch; virtual;
    procedure SignalFoundMatch(LineNo: Integer; const Line: string; SPos,
      FEditReaderPos: Integer); virtual;
  protected
    BLine: PAnsiChar; // 当前查找的文本行，已经做过大小写转换了
    OrgLine: PAnsiChar; // 当前查找的原始文本行
    FLineNo: Integer;
    FEof: Boolean;
    FSearchBuffer: PAnsiChar;
    FBufStartPos: Integer;
    FLineStartPos: Integer;
    FBufSize: Integer;
    FBufferSearchPos: Integer;
    FBufferDataCount: Integer;
    FSearchOptions: TSearchOptions;
    FPattern: PAnsiChar;
    FFileName: string;
    LoCase: function(const Ch: AnsiChar): AnsiChar;
    procedure FillBuffer(Stream: TStream);
    procedure PatternMatch;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetPattern(const ASource: string);
    procedure Search(Stream: TStream);

    property FileName: string read FFileName write FFileName;
    property ANSICompatible: Boolean write SetANSICompatible;
    property BufSize: Integer read FBufSize write SetBufSize;
    property Pattern: PAnsiChar read FPattern;
    property SearchOptions: TSearchOptions read FSearchOptions write FSearchOptions;
    property OnFound: TFoundEvent read FOnFound write FOnFound;
    property OnStartSearch: TNotifyEvent read FOnStartSearch write FOnStartSearch;
  end;

function CheckFileCRLF(const FileName: string; out CRLFCount, LFCount: Integer): Boolean;
{* 检查一个文件中有多少 CRLF，以及有多少单独的 LF，返回检测是否成功}

function CorrectFileCRLF(const FileName: string; out CorrectCount: Integer): Boolean;
{* 修复一个文件中的 CRLF，也即将 LF 全转变为 CRLF，返回转换是否成功，
  注意如果返回的 CorrectCount 是 0，将不实施保存动作，但返回值仍是成功}

implementation

const
  // Pattern matching tokens
  opChar = AnsiChar(1);
  opBOL = AnsiChar(2);
  opEOL = AnsiChar(3);
  opAny = AnsiChar(4);
  opClass = AnsiChar(5);
  opNClass = AnsiChar(6);
  opAlpha = AnsiChar(7);
  opDigit = AnsiChar(8);
  opAlphaNum = AnsiChar(9);
  opPunct = AnsiChar(10);
  opRange = AnsiChar(11);
  opEndPat = AnsiChar(12);

  LastPatternChar = opEndPat;

  GrepPatternSize = 512;
  SearchLineSize = 1024;
  DefaultBufferSize = 2048;

{ Generic routines }

{$IFDEF UNICODE}
function StrAlloc(Size: Cardinal): PAnsiChar;
begin
  Result := AnsiStrAlloc(Size);
end;
{$ENDIF}

function ANSILoCase(const Ch: AnsiChar): AnsiChar;
var
  w: WORD;
begin
  w := MakeWord(Ord(Ch), 0);
  CharLower(PChar(@w));
  Result := AnsiChar(Lo(w));
end;

function ASCIILoCase(const Ch: AnsiChar): AnsiChar;
begin
  if Ch in ['A'..'Z'] then
    Result := AnsiChar(Ord(Ch) + 32)
  else
    Result := Ch;
end;

{ TCnSearcher }

constructor TCnSearcher.Create;
begin
  inherited Create;

  FBufSize := DefaultBufferSize;
  BLine := StrAlloc(SearchLineSize);
  OrgLine := StrAlloc(SearchLineSize);
  FPattern := StrAlloc(GrepPatternSize);
  LoCase := ASCIILoCase;
end;

destructor TCnSearcher.Destroy;
begin
  StrDispose(FSearchBuffer);
  FSearchBuffer := nil;

  StrDispose(BLine);
  BLine := nil;

  StrDispose(OrgLine);
  OrgLine := nil;

  StrDispose(FPattern);
  FPattern := nil;

  inherited Destroy;
end;

procedure TCnSearcher.SetANSICompatible(const Value: Boolean);
begin
  if Value then
    LoCase := ANSILoCase
  else
    LoCase := ASCIILoCase;
end;

procedure TCnSearcher.FillBuffer(Stream: TStream);
var
  AmountOfBytesToRead: Integer;
  SkippedCharactersCount: Integer;
  LineEndScanner: PAnsiChar;
begin
  if FSearchBuffer = nil then
    FSearchBuffer := StrAlloc(FBufSize);
  FSearchBuffer[0] := #0;

  // Read at most (FBufSize - 1) bytes
  AmountOfBytesToRead := FBufSize - 1;

  FBufStartPos := Stream.Position;
  FBufferDataCount := Stream.Read(FSearchBuffer^, AmountOfBytesToRead);
  FEof := (FBufferDataCount = 0);

  // Reset buffer position to zero
  FBufferSearchPos := 0;

  // If we filled our buffer completely, there is a chance that
  // the last line was read only partially.
  // Since our search algorithm is line-based,
  // skip back to the end of the last completely read line.
  if FBufferDataCount = AmountOfBytesToRead then
  begin
    // Get pointer on last character of read data
    LineEndScanner := FSearchBuffer + FBufferDataCount - 1;
    // We have not skipped any characters yet
    SkippedCharactersCount := 0;
    // While we still have data in the buffer,
    // do scan for a line break as characterised
    // by a #13#10 or #10#13 or a single #10.
    // Which sequence exactly we hit is not important,
    // we just need to find and line terminating
    // sequence.
    while FBufferDataCount > 0 do
    begin
      if LineEndScanner^ = #10 then
      begin
        Stream.Seek(-SkippedCharactersCount, soFromCurrent);

        // Done with finding last complete line
        Break;
      end;

      Inc(SkippedCharactersCount);
      Dec(FBufferDataCount);
      Dec(LineEndScanner);
    end;

    // With FBufferPos = 0 we have scanned back in our
    // buffer and not found any line break; this means
    // that we cannot employ our pattern matcher on a
    // complete line -> Internal Error.
    if FBufferDataCount = 0 then
      raise ELineTooLong.CreateFmt(SCnLineLengthError, [FBufSize - 1, FFileName]);
  end;

  // Cut off everything beyond the line break
  // Assert(FBufferDataCount >= 0);
  FSearchBuffer[FBufferDataCount] := #0;
end;

procedure TCnSearcher.Search(Stream: TStream);
var
  i: Integer;
  LPos: Integer;
begin
  SignalStartSearch;

  FEof := False;
  FLineNo := 0;
  FBufStartPos := 0;
  FLineStartPos := 0;
  FBufferSearchPos := 0;
  FBufferDataCount := 0;
  LPos := 0;

  while not FEof do
  begin
    // Read new data in
    if (FBufferSearchPos >= FBufferDataCount) or (FBufferDataCount = 0) then
    begin
      try
        FillBuffer(Stream);
      except on E: ELineTooLong do
        begin
          ErrorDlg(E.Message);
          Exit;
        end;
      end;
    end;
    
    if FEof then Exit;
    
    i := FBufferSearchPos;
    FLineStartPos := FBufStartPos + FBufferSearchPos;
    while i < FBufferDataCount do
    begin
      case FSearchBuffer[i] of
        #0:
          begin
            FBufferSearchPos := FBufferDataCount + 1;
            Break;
          end;
        #10:
          begin
            FBufferSearchPos := i + 1;
            Break;
          end;
        #13:
          begin
            FBufferSearchPos := i + 1;
            if FSearchBuffer[FBufferSearchPos] = #10 then Inc(FBufferSearchPos);
            Break;
          end;
      end;

      if not (soCaseSensitive in SearchOptions) then
      begin
        BLine[LPos] := LoCase(FSearchBuffer[i]);
        OrgLine[LPos] := FSearchBuffer[i];
      end
      else
        BLine[LPos] := FSearchBuffer[i];
        
      Inc(LPos);
      if LPos >= SearchLineSize - 1 then // Enforce maximum line length constraint
        Exit;                         // Binary, not text file
      Inc(i);
    end;
    
    if FSearchBuffer[i] <> #0 then Inc(FLineNo);
    
    BLine[LPos] := #0;
    OrgLine[LPos] := #0;
    
    if BLine[0] <> #0 then PatternMatch;
    
    LPos := 0;
    if FBufferSearchPos < i then FBufferSearchPos := i;
  end;
end;

procedure TCnSearcher.SetBufSize(New: Integer);
begin
  if (FSearchBuffer = nil) and (New <> FBufSize) then
    FBufSize := New;
end;

procedure TCnSearcher.SetPattern(const ASource: string);
var
  Source: AnsiString;
  PatternCharIndex: Integer;
  SourceCharIndex: Integer;

  procedure Store(Ch: AnsiChar);
  begin
    Assert(PatternCharIndex < GrepPatternSize, 'Buffer overrun!');
    if not (soCaseSensitive in SearchOptions) then
      FPattern[PatternCharIndex] := LoCase(Ch)
    else
      FPattern[PatternCharIndex] := Ch;
    Inc(PatternCharIndex);
  end;

  procedure cclass;
  var
    cstart: Integer;
  begin
    cstart := SourceCharIndex;
    Inc(SourceCharIndex);
    if Source[SourceCharIndex] = '^' then
      Store(opNClass)
    else
      Store(opClass);

    while (SourceCharIndex <= Length(Source)) and (Source[SourceCharIndex] <> ']') do
    begin
      if (Source[SourceCharIndex] = '-') and
        (SourceCharIndex - cstart > 1) and
        (Source[SourceCharIndex + 1] <> ']') and
        (SourceCharIndex < Length(Source)) then
      begin
        Dec(PatternCharIndex, 2);
        Store(opRange);
        Store(Source[SourceCharIndex - 1]);
        Store(Source[SourceCharIndex + 1]);
        Inc(SourceCharIndex, 2);
      end
      else
      begin
        Store(Source[SourceCharIndex]);
        Inc(SourceCharIndex);
      end;
    end;

    if (Source[SourceCharIndex] <> ']') or (SourceCharIndex > Length(Source)) then
      raise EPatternError.CreateFmt(SCnClassNotTerminated, [cstart]);

    Inc(SourceCharIndex);               // To push past close bracket
  end;

begin
  // Warning: this does not properly protect against pattern overruns
  // A better solution needs to be found for this, possibly by sacrificing
  // a bit of performance for a test in the pattern storage code where a
  // new Assert has been introduced.
{$IFDEF UNICODE}
  Source := AnsiString(ASource);
{$ELSE}
  Source := ASource;
{$ENDIF}
  if Length(Source) > 500 then
    raise EPatternError.Create(SCnPatternTooLong);

  try
    SourceCharIndex := 1;
    PatternCharIndex := 0;
    while SourceCharIndex <= Length(Source) do
    begin
      if not (soRegEx in SearchOptions) then
      begin
        Store(opChar);
        Store(Source[SourceCharIndex]);
        Inc(SourceCharIndex);
      end
      else
      begin
        case Source[SourceCharIndex] of
          '^':
            begin
              Store(opBOL);
              Inc(SourceCharIndex);
            end;

          '$':
            begin
              Store(opEOL);
              Inc(SourceCharIndex);
            end;

          '.':
            begin
              Store(opAny);
              Inc(SourceCharIndex);
            end;

          '[':
            cclass;

          ':':
            begin
              if SourceCharIndex < Length(Source) then
              begin
                case UpCase(Source[SourceCharIndex + 1]) of
                  'A': Store(opAlpha);
                  'D': Store(opDigit);
                  'N': Store(opAlphaNum);
                  ' ': Store(opPunct);
                else
                  Store(opEndPat);
                  raise EPatternError.CreateFmt(SCnInvalidGrepSearchCriteria,
                    [SourceCharIndex]);
                end;
                Inc(SourceCharIndex, 2);
              end
              else
              begin
                Store(opChar);
                Store(Source[SourceCharIndex]);
                Inc(SourceCharIndex);
              end;
            end;

          '\':
            begin
              if SourceCharIndex >= Length(Source) then
                raise EPatternError.Create(SCnSenselessEscape);

              Store(opChar);
              Store(Source[SourceCharIndex + 1]);
              Inc(SourceCharIndex, 2);
            end;
        else
          Store(opChar);
          Store(Source[SourceCharIndex]);
          Inc(SourceCharIndex);
        end;                            // case
      end;
    end;
  finally
    Store(opEndPat);
    Store(#0);
  end;
end;

procedure TCnSearcher.PatternMatch;
var
  l, p: Integer;                        // Line and pattern pointers
  op: AnsiChar;                             // Pattern operation
  LinePos: Integer;

  procedure IsFound;
  var
    S: Integer;
    E: Integer;
    TestChar: AnsiChar;
  begin
    if soWholeWord in SearchOptions then
    begin
      S := LinePos - 2;
      E := l;
      if (S > 0) then
      begin
        TestChar := BLine[S];
        // LiuXiao: 扩展 ASCII 字符不算分词字符
        if IsCharAlphaNumericA(TestChar) or (TestChar = '_') or (Ord(TestChar) > 127) then
          Exit;
      end;
      TestChar := BLine[E];
      if TestChar <> #0 then
      begin
        if IsCharAlphaNumericA(TestChar) or (TestChar = '_') or (Ord(TestChar) > 127) then
          Exit;
      end;
    end;

    if soCaseSensitive in SearchOptions then
      SignalFoundMatch(FLineNo, string(BLine), LinePos, l)
    else
      SignalFoundMatch(FLineNo, string(OrgLine), LinePos, l);
  end;

begin
  if FPattern[0] = opEndPat then
    Exit;
  LinePos := 0;

  // Don't bother pattern matching if first search is opChar, just go to first
  // match directly. This results in about a 5% to 10% speed increase.
  if (FPattern[0] = opChar) and not (soCaseSensitive in SearchOptions) then
    while (FPattern[1] <> BLine[LinePos]) and (BLine[LinePos] <> #0) do
      Inc(LinePos);

  while BLine[LinePos] <> #0 do
  begin
    l := LinePos;
    p := 0;
    op := FPattern[p];
    while op <> opEndPat do
    begin
      case op of
        opChar:
          begin
            if not (BLine[l] = FPattern[p + 1]) then
              Break;
            Inc(p, 2);
          end;

        opBOL:
          begin
            Inc(p);
          end;

        opEOL:
          begin
            if BLine[l] in [#0, #10, #13] then
              Inc(p)
            else
              Break;
          end;

        opAny:
          begin
            if BLine[l] in [#0, #10, #13] then
              Break;
            Inc(p);
          end;

        opClass:
          begin
            Inc(p);
            // Compare letters to find a match
            while (FPattern[p] > LastPatternChar) and (FPattern[p] <> BLine[l]) do
              Inc(p);
            // Was a match found?
            if FPattern[p] <= LastPatternChar then
              Break;
            // Move pattern pointer to next opcode
            while FPattern[p] > LastPatternChar do
              Inc(p);
          end;

        opNClass:
          begin
            Inc(p);
            // Compare letters to find a match
            while (FPattern[p] > LastPatternChar) and (FPattern[p] <> BLine[l]) do
              Inc(p);
            if FPattern[p] > LastPatternChar then
              Break;
          end;

        opAlpha:
          begin
            if not IsCharAlphaA(BLine[l]) then
              Break;
            Inc(p);
          end;

        opDigit:
          begin
            if not (BLine[l] in ['0'..'9']) then
              Break;
            Inc(p);
          end;

        opAlphaNum:
          begin
            if IsCharAlphaNumericA(BLine[l]) then
              Inc(p)
            else
              Break;
          end;

        opPunct:
          begin
            if (BLine[l] = ' ') or (BLine[l] > #64) then
              Break;
            Inc(p);
          end;

        opRange:
          begin
            if (BLine[l] < FPattern[p + 1]) or (BLine[l] > FPattern[p + 2]) then
              Break;
            Inc(p, 3);
          end;
      else
        Inc(p);
      end;                              // case

      if (op = opBOL) and not (BLine[l] in [#9, #32]) then
        Exit;                           // Means that we did not match at start.

      op := FPattern[p];
      Inc(l);
    end;                                // while op <> opEndPat
    Inc(LinePos);
    if op = opEndPat then
      IsFound;
  end;                                  // while BLine[LinePos] <> #0
end;

procedure TCnSearcher.SignalStartSearch;
begin
  if Assigned(FOnStartSearch) then
    FOnStartSearch(Self);
end;

procedure TCnSearcher.SignalFoundMatch(LineNo: Integer; const Line: string;
  SPos, FEditReaderPos: Integer);
begin
  if Assigned(FOnFound) then
    FOnFound(Self, LineNo, FLineStartPos, Line, SPos,
      FEditReaderPos);
end;

function CheckFileCRLF(const FileName: string; out CRLFCount, LFCount: Integer): Boolean;
var
  Stream: TMemoryStream;
  P, PP: PChar;
begin
  Result := False;
  Stream := nil;

  try
    try
      Stream := TMemoryStream.Create;
      EditFilerSaveFileToStream(FileName, Stream, True); // 读出原始格式，Ansi/Ansi/Utf16

      if Stream.Size = 0 then
        Exit;

      CRLFCount := 0;
      LFCount := 0;
      if Stream.Size = SizeOf(Char) then
      begin
        if PChar(Stream.Memory)^ = #$0A then
          Inc(LFCount);
      end
      else
      begin
        PP := PChar(Stream.Memory);
        P := PP;
        Inc(P);

        while P^ <> #0 do
        begin
          if P^ = #$0A then
          begin
            if PP^ = #$0D then
              Inc(CRLFCount)
            else
              Inc(LFCount)
          end;
          Inc(P);
          Inc(PP);
        end;
        Result := True;
      end;
    except
      ;
    end;
  finally
    Stream.Free;
  end;
end;

function CorrectFileCRLF(const FileName: string; out CorrectCount: Integer): Boolean;
var
  SourceStream, DestStream: TMemoryStream;
  P, PP: PChar;
  CCR, CLF, CZ: AnsiChar;
{$IFDEF UNICODE}
  Text: AnsiString;
{$ENDIF}
begin
  Result := False;
  SourceStream := nil;
  DestStream := nil;

  try
    try
      SourceStream := TMemoryStream.Create;
      EditFilerSaveFileToStream(FileName, SourceStream, True); // 读出 Ansi/Ansi/Utf16

      if SourceStream.Size = 0 then
        Exit;

      DestStream := TMemoryStream.Create;
      CorrectCount := 0;
      CCR := #$0D;
      CLF := #$0A;
      CZ := #0;

      if SourceStream.Size = SizeOf(Char) then
      begin
        if PChar(SourceStream.Memory)^ = #$0A then
        begin
          DestStream.Write(CCR, 1);
{$IFDEF UNICODE}
          DestStream.Write(CZ, 1);
{$ENDIF}
          DestStream.Write(CLF, 1);
{$IFDEF UNICODE}
          DestStream.Write(CZ, 1);
{$ENDIF}
        end;
      end
      else
      begin
        PP := PChar(SourceStream.Memory);
        P := PP;
        Inc(P);
        DestStream.Write(PP^, SizeOf(Char));

        while P^ <> #0 do
        begin
          if P^ = #$0A then
          begin
            if PP^ <> #$0D then
            begin
              DestStream.Write(CCR, 1);
{$IFDEF UNICODE}
              DestStream.Write(CZ, 1);
{$ENDIF}
              Inc(CorrectCount);
            end;
          end;
          DestStream.Write(P^, SizeOf(Char));
          Inc(P);
          Inc(PP);
        end;
      end;

      DestStream.Write(CZ, 1);
{$IFDEF UNICODE}
      DestStream.Write(CZ, 1);
{$ENDIF}

      if CorrectCount > 0 then  // 需要 Ansi/Ansi/Utf8
      begin
{$IFDEF UNICODE}
        // DestStream 里做一次 Utf16 到 Utf8 的转换
        Text := Utf8Encode(PChar(DestStream.Memory));
        DestStream.Size := Length(Text) + 1;
        DestStream.Position := 0;
        DestStream.Write(PAnsiChar(Text)^, Length(Text) + 1);
{$ENDIF}
        EditFilerReadStreamToFile(FileName, DestStream); // 写原始格式
      end;
      Result := True;
    except
      ;
    end;
  finally
    SourceStream.Free;
  end;
end;

end.

