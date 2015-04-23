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

unit CnScaners;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：Object Pascal 词法分析器
* 单元作者：CnPack开发组
* 备    注：该单元实现了Object Pascal 词法分析器
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 单元标识：$Id$
* 修改记录：2007-10-13 V1.0
*               完善一些功能
*           2004-1-14 V0.5
*               加入标签(Bookmark)功能，可以方便的向前看N个TOKEN
*           2003-12-16 V0.4
*               建立。目前自动跳过空格和注释。注释不应该跳过，但是还需要处理。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Contnrs, CnFormatterIntf,
  CnParseConsts, CnTokens, CnCodeGenerators, CnCodeFormatRules;

type
  TScannerBookmark = class(TObject)
  private
    FOriginBookmark: Longint;
    FTokenBookmark: TPascalToken;
    FTokenPtrBookmark: PChar;
    FSourcePtrBookmark: PChar;
    FSourceLineBookmark: Integer;
    FBlankLinesBeforeBookmark: Integer;
    FBlankLinesAfterBookmark: Integer;
    FPrevBlankLinesBookmark: Boolean;
    FSourceColBookmark: Integer;
    FInIgnoreAreaBookmark: Boolean;
  protected
    property OriginBookmark: Longint read FOriginBookmark write FOriginBookmark;
    property TokenBookmark: TPascalToken read FTokenBookmark write FTokenBookmark;
    property TokenPtrBookmark: PChar read FTokenPtrBookmark write FTokenPtrBookmark;
    property SourcePtrBookmark: PChar read FSourcePtrBookmark write FSourcePtrBookmark;
    property SourceLineBookmark: Integer read FSourceLineBookmark write FSourceLineBookmark;
    property SourceColBookmark: Integer read FSourceColBookmark write FSourceColBookmark;
    property BlankLinesBeforeBookmark: Integer read FBlankLinesBeforeBookmark write FBlankLinesBeforeBookmark;
    property BlankLinesAfterBookmark: Integer read FBlankLinesAfterBookmark write FBlankLinesAfterBookmark;
    property PrevBlankLinesBookmark: Boolean read FPrevBlankLinesBookmark write FPrevBlankLinesBookmark;
    property InIgnoreAreaBookmark: Boolean read FInIgnoreAreaBookmark write FInIgnoreAreaBookmark;
  end;

  TAbstractScaner = class(TObject)
  private
    FStream: TStream;
    FBookmarks: TObjectList;
    FOrigin: Longint;
    FBuffer: PChar;
    FBufPtr: PChar;
    FBufEnd: PChar;
    FSourcePtr: PChar;
    FSourceEnd: PChar;
    FTokenPtr: PChar;
    FStringPtr: PChar;
    FSourceLine: Integer;
    FSaveChar: Char;
    FToken: TPascalToken;
    FFloatType: Char;
    FWideStr: WideString;
    FBackwardToken: TPascalToken;

    FBlankStringBegin, FBlankStringEnd: PChar;
    FBlankLines, FBlankLinesAfterComment: Integer;
    FBlankLinesBefore: Integer;
    FBlankLinesAfter: Integer;
    FASMMode: Boolean;
    FFirstCommentInBlock: Boolean;
    FPreviousIsComment: Boolean;
    FInDirectiveNestSearch: Boolean;
    FKeepOneBlankLine: Boolean;
    FPrevBlankLines: Boolean;
    FSourceCol: Integer;
    FInIgnoreArea: Boolean;
    procedure ReadBuffer;
    procedure SetOrigin(AOrigin: Longint);
    procedure SkipBlanks;
    procedure DoBlankLinesWhenSkip(BlankLines: Integer); virtual;
    {* SkipBlanks 时遇到连续换行时被调用}
    function ErrorTokenString: string;
    procedure NewLine;

{$IFDEF UNICODE}
    procedure FixStreamBom;
{$ENDIF}
  protected
    procedure OnMoreBlankLinesWhenSkip; virtual; abstract;
  public
    constructor Create(Stream: TStream); virtual;
    destructor Destroy; override;
    procedure CheckToken(T: TPascalToken);
    procedure CheckTokenSymbol(const S: string);
    procedure Error(const Ident: Integer);
    procedure ErrorFmt(const Ident: Integer; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure HexToBinary(Stream: TStream);

    function NextToken: TPascalToken; virtual; abstract;
    function SourcePos: Longint;
    // 当前 Token 在整个源码中的偏移量，0 开始
    function TokenComponentIdent: string;
    function TokenFloat: Extended;
{$IFDEF DELPHI5}
    function TokenInt: Integer;
{$ELSE}
    function TokenInt: Int64;
{$ENDIF}
    function BlankString: string;
    {* 当前空白区域的字符串值}
    function BlankStringLength: Integer;
    {* 当前空白区域的字符长度}
    function TokenString: string;
    {* 当前 Token 的字符串值}
    function TokenStringLength: Integer;
    {* 当前 Token 的字符长度}
    function TrimBlank(const Str: string): string;
    {* 处理 BlankString，如果上次曾经多输出了一个分隔的空行，则本次 BlankString
       需要去掉前导空行（是去掉一个以保持原有空行数量呢，还是去掉所有前导保持一个空行？}
    function TokenChar: Char;
    function TokenWideString: WideString;
    function TokenSymbolIs(const S: string): Boolean;

    procedure SaveBookmark(var Bookmark: TScannerBookmark);
    procedure LoadBookmark(var Bookmark: TScannerBookmark; Clear: Boolean = True);
    procedure ClearBookmark(var Bookmark: TScannerBookmark);

    function ForwardToken(Count: Integer = 1): TPascalToken; virtual;

    property FloatType: Char read FFloatType;
    property SourceLine: Integer read FSourceLine;  // 行，以 1 开始
    property SourceCol: Integer read FSourceCol;    // 列，以 1 开始

    property Token: TPascalToken read FToken;
    property TokenPtr: PChar read FTokenPtr;

    property ASMMode: Boolean read FASMMode write FASMMode;
    {* 用来控制是否将回车当作空白，asm 块中需要此选项}

    property BlankLinesBefore: Integer read FBlankLinesBefore write FBlankLinesBefore;
    {* SkipBlank 碰到一注释时，注释和前面有效内容隔的行数，用来控制分行}
    property BlankLinesAfter: Integer read FBlankLinesAfter write FBlankLinesAfter;
    {* SkipBlank 跳过一注释后，注释和后面有效内容隔的行数，用来控制分行}
    property PrevBlankLines: Boolean read FPrevBlankLines write FPrevBlankLines;
    {* 记录上一次是否输出了连续空行合并成的一个空行}

    property KeepOneBlankLine: Boolean read FKeepOneBlankLine write FKeepOneBlankLine;
    {* 由外界设置是否在格式化的过程中保持空行，无须用 Bookmark 保存}

    property InIgnoreArea: Boolean read FInIgnoreArea write FInIgnoreArea;
    {* 由内部前进 Token 时解析设置当前是否忽略格式化标记，供外界使用}
  end;

  TScaner = class(TAbstractScaner)
  private
    FStream: TStream;
    FCodeGen: TCnCodeGenerator;
    FCompDirectiveMode: TCompDirectiveMode;
  protected
    procedure OnMoreBlankLinesWhenSkip; override;    
  public
    constructor Create(AStream: TStream); overload; override;
    constructor Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
      ACompDirectiveMode: TCompDirectiveMode); reintroduce; overload;
    destructor Destroy; override;
    function NextToken: TPascalToken; override;
    function ForwardToken(Count: Integer = 1): TPascalToken; override;

    property CompDirectiveMode: TCompDirectiveMode read FCompDirectiveMode;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  ScanBufferSize = 512 * 1024 {KB};

procedure BinToHex(Buffer, Text: PChar; BufSize: Integer); 
const
  Convert: array[0..15] of Char = '0123456789ABCDEF';
var
  I: Integer;
begin
  for I := 0 to BufSize - 1 do
  begin
    Text[0] := Convert[Byte(Buffer[I]) shr 4];
    Text[1] := Convert[Byte(Buffer[I]) and $F];
    Inc(Text, 2);
  end;
end;
{asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB      '0123456789ABCDEF'
@@1:    LODSB
        MOV     DL,AL
        AND     DL,0FH
        MOV     AH,@@0.Byte[EDX]
        MOV     DL,AL
        SHR     DL,4
        MOV     AL,@@0.Byte[EDX]
        STOSW
        DEC     ECX
        JNE     @@1
        POP     EDI
        POP     ESI
end;}

function HexToBin(Text, Buffer: PChar; BufSize: Integer): Integer;
const
  Convert: array['0'..'f'] of SmallInt =
    ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15);
var
  I: Integer;
begin
  I := BufSize;
  while I > 0 do
  begin
    if not (Text[0] in ['0'..'f']) or not (Text[1] in ['0'..'f']) then Break;
    Buffer[0] := Char((Convert[Text[0]] shl 4) + Convert[Text[1]]);
    Inc(Buffer);
    Inc(Text, 2);
    Dec(I);
  end;
  Result := BufSize - I;
end;

{asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB       0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15
@@1:    LODSW
        CMP     AL,'0'
        JB      @@2
        CMP     AL,'f'
        JA      @@2
        MOV     DL,AL
        MOV     AL,@@0.Byte[EDX-'0']
        CMP     AL,-1
        JE      @@2
        SHL     AL,4
        CMP     AH,'0'
        JB      @@2
        CMP     AH,'f'
        JA      @@2
        MOV     DL,AH
        MOV     AH,@@0.Byte[EDX-'0']
        CMP     AH,-1
        JE      @@2
        OR      AL,AH
        STOSB
        DEC     ECX
        JNE     @@1
@@2:    MOV     EAX,EDI
        SUB     EAX,EBX
        POP     EBX
        POP     EDI
        POP     ESI
end;}

{ TAbstractScaner }

constructor TAbstractScaner.Create(Stream: TStream);
begin
  FStream := Stream;
{$IFDEF UNICODE}
  FixStreamBom;
{$ENDIF}
  FBookmarks := TObjectList.Create;
    
  GetMem(FBuffer, ScanBufferSize);
  FBuffer[0] := #0;
  FBufPtr := FBuffer;
  FBufEnd := FBuffer + ScanBufferSize;
  FSourcePtr := FBuffer;
  FSourceEnd := FBuffer;
  FTokenPtr := FBuffer;
  FSourceLine := 1;
  FSourceCol := 1;
  FBackwardToken := tokNoToken;

  // NextToken;  Let outside call it.
end;

{$IFDEF UNICODE}

procedure TAbstractScaner.FixStreamBom;
var
  Bom: array[0..1] of AnsiChar;
  TS: TMemoryStream;
begin
  if (FStream <> nil) and (FStream.Size > 2) then
  begin
    FStream.Seek(0, soBeginning);
    FStream.Read(Bom, SizeOf(Bom));
    if (Bom[0] = #$FF) and (Bom[1] = #$FE) then
    begin
      // Has Utf16 BOM, remove
      TS := TMemoryStream.Create;
      try
        TS.CopyFrom(FStream, FStream.Size - SizeOf(Bom));
        FStream.Position := 0;
        FStream.Size := 0;
        FStream.CopyFrom(TS, 0);
      finally
        TS.Free;
      end;
    end;
    FStream.Position := 0;
  end;
end;

{$ENDIF}

destructor TAbstractScaner.Destroy;
begin
  if FBuffer <> nil then
  begin
    FStream.Seek(Longint(FTokenPtr) - Longint(FBufPtr), 1);
    FreeMem(FBuffer, ScanBufferSize);
  end;

  FBookmarks.Free;
end;

procedure TAbstractScaner.CheckToken(T: TPascalToken);
begin
  if Token <> T then
    case T of
      tokSymbol:
        Error(CN_ERRCODE_PASCAL_IDENT_EXP);
      tokString, tokWString:
        Error(CN_ERRCODE_PASCAL_STRING_EXP);
      tokInteger, tokFloat:
        Error(CN_ERRCODE_PASCAL_NUMBER_EXP);
    else
      ErrorFmt(CN_ERRCODE_PASCAL_CHAR_EXP, [Integer(T)]);
    end;
end;

procedure TAbstractScaner.CheckTokenSymbol(const S: string);
begin
  if not TokenSymbolIs(S) then ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [S]);
end;

procedure TAbstractScaner.Error(const Ident: Integer);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TAbstractScaner.ErrorFmt(const Ident: Integer; const Args: array of const);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;  
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;
  
  ErrorStr(Format(RetrieveFormatErrorString(Ident), Args));
end;

procedure TAbstractScaner.ErrorStr(const Message: string);
begin
  raise EParserError.CreateFmt(SParseError, [Message, FSourceLine, SourcePos]);
end;

procedure TAbstractScaner.HexToBinary(Stream: TStream);
var
  Count: Integer;
  Buffer: array[0..255] of Char;
begin
  SkipBlanks;
  while FSourcePtr^ <> '}' do
  begin
    Count := HexToBin(FSourcePtr, Buffer, SizeOf(Buffer));
    if Count = 0 then Error(CN_ERRCODE_PASCAL_INVALID_BIN);
    Stream.Write(Buffer, Count);
    Inc(FSourcePtr, Count * 2);
    SkipBlanks;
  end;
  NextToken;
end;

procedure TAbstractScaner.ReadBuffer;
var
  Count: Integer;
begin
  Inc(FOrigin, FSourcePtr - FBuffer);
  FSourceEnd[0] := FSaveChar;
  Count := FBufPtr - FSourcePtr;
  if Count <> 0 then Move(FSourcePtr[0], FBuffer[0], Count);
  FBufPtr := FBuffer + Count;
  Inc(FBufPtr, FStream.Read(FBufPtr[0], FBufEnd - FBufPtr));
  FSourcePtr := FBuffer;
  FSourceEnd := FBufPtr;
  if FSourceEnd = FBufEnd then
  begin
    FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
    if FSourceEnd = FBuffer then Error(CN_ERRCODE_PASCAL_LINE_TOOLONG);
  end;
  FSaveChar := FSourceEnd[0];
  FSourceEnd[0] := #0;
end;

procedure TAbstractScaner.SetOrigin(AOrigin: Integer);
begin
  if AOrigin <> FOrigin then
  begin
    FOrigin := AOrigin;
    FSourceEnd[0] := FSaveChar;
    FStream.Seek(AOrigin, soFromBeginning);
    FBufPtr := FBuffer;
    Inc(FBufPtr, FStream.Read(FBuffer[0], ScanBufferSize));
    FSourcePtr := FBuffer;
    FSourceEnd := FBufPtr;
    if FSourceEnd = FBufEnd then
    begin
      FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
      if FSourceEnd = FBuffer then Error(CN_ERRCODE_PASCAL_LINE_TOOLONG);
    end;
    FSaveChar := FSourceEnd[0];
    FSourceEnd[0] := #0;
  end;
end;

procedure TAbstractScaner.SkipBlanks;
var
  EmptyLines: Integer;
begin
  FBlankStringBegin := FSourcePtr;
  FBlankStringEnd := FBlankStringBegin;
  FBlankLines := 0;

  EmptyLines := 0;
  while True do
  begin
    case FSourcePtr^ of
      #0:
        begin
          ReadBuffer;
          if FSourcePtr^ = #0 then
          begin
            DoBlankLinesWhenSkip(EmptyLines);
            Exit;
          end;
          Continue;
        end;
      #10:
        begin
          NewLine;
          Inc(FBlankLines);

          if FASMMode then // 需要检测回车的标志
          begin
            FBlankStringEnd := FSourcePtr;
            DoBlankLinesWhenSkip(EmptyLines);
            Exit; // Do not exit for Inc FSourcePtr?
          end;
          Inc(EmptyLines);
        end;
      #33..#255:
        begin
          FBlankStringEnd := FSourcePtr;
          DoBlankLinesWhenSkip(EmptyLines);

          Exit;
        end;
    end;
    
    Inc(FSourcePtr);
    FBackwardToken := tokBlank;
  end;
end;

function TAbstractScaner.SourcePos: Longint;
begin
  Result := FOrigin + (FTokenPtr - FBuffer);
end;

function TAbstractScaner.TokenFloat: Extended;
begin
  if FFloatType <> #0 then Dec(FSourcePtr);
  Result := StrToFloat(TokenString);
  if FFloatType <> #0 then Inc(FSourcePtr);
end;

{$IFDEF DELPHI5}
function TAbstractScaner.TokenInt: Integer;
begin
  Result := StrToInt(TokenString);
end;
{$ELSE}
function TAbstractScaner.TokenInt: Int64;
begin
  Result := StrToInt64(TokenString);
end;
{$ENDIF}

function TAbstractScaner.TokenString: string;
var
  L: Integer;
begin
  if FToken = tokString then
    L := FStringPtr - FTokenPtr
  else
    L := FSourcePtr - FTokenPtr;
  SetString(Result, FTokenPtr, L);
end;

function TAbstractScaner.TokenWideString: WideString;
begin
  if FToken = tokString then
    Result := TokenString
  else
    Result := FWideStr;
end;

function TAbstractScaner.TokenSymbolIs(const S: string): Boolean;
begin
  Result := SameText(S, TokenString);
end;

function TAbstractScaner.TokenComponentIdent: string;
var
  P: PChar;
begin
  CheckToken(tokSymbol);
  P := FSourcePtr;
  while P^ = '.' do
  begin
    Inc(P);
    if not (P^ in ['A'..'Z', 'a'..'z', '_']) then
      Error(CN_ERRCODE_PASCAL_IDENT_EXP);
    repeat
      Inc(P)
    until not (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_']);
  end;
  FSourcePtr := P;
  Result := TokenString;
end;

function TAbstractScaner.TokenChar: Char;
begin
  if Length(TokenString) > 0 then
    Result := TokenString[1]
  else
    Result := #0;
end;

procedure TAbstractScaner.LoadBookmark(var Bookmark: TScannerBookmark; Clear:
  Boolean = True);
begin
  if FBookmarks.IndexOf(Bookmark) >= 0 then
  begin
    with Bookmark do
    begin
      if Assigned(SourcePtrBookmark) and Assigned(TokenPtrBookmark) then
      begin
        if OriginBookmark <> FOrigin then
          SetOrigin(OriginBookmark);
        FSourcePtr := SourcePtrBookmark;
        FTokenPtr := TokenPtrBookmark;
        FToken := TokenBookmark;
        FSourceLine := SourceLineBookmark;
        FSourceCol := SourceColBookmark;
        FBlankLinesBefore := BlankLinesBeforeBookmark;
        FBlankLinesAfter := BlankLinesAfterBookmark;
        FPrevBlankLines := PrevBlankLinesBookmark;
        FInIgnoreArea := InIgnoreAreaBookmark;
      end
      else
        Error(CN_ERRCODE_PASCAL_INVALID_BOOKMARK);
    end;
  end
  else
    Error(CN_ERRCODE_PASCAL_INVALID_BOOKMARK);

  if Clear then
    ClearBookmark(Bookmark);
end;

procedure TAbstractScaner.SaveBookmark(var Bookmark: TScannerBookmark);
begin
  Bookmark := TScannerBookmark.Create;
  with Bookmark do
  begin
    OriginBookmark := FOrigin;
    SourcePtrBookmark := FSourcePtr;
    TokenBookmark := FToken;
    TokenPtrBookmark := FTokenPtr;
    SourceLineBookmark := FSourceLine;
    SourceColBookmark := FSourceCol;
    BlankLinesBeforeBookmark := FBlankLinesBefore;
    BlankLinesAfterBookmark := FBlankLinesAfter;
    PrevBlankLinesBookmark := FPrevBlankLines;
    InIgnoreAreaBookmark := FInIgnoreArea;
  end;
  FBookmarks.Add(Bookmark);
end;

procedure TAbstractScaner.ClearBookmark(var Bookmark: TScannerBookmark);
begin
  Bookmark := TScannerBookmark(FBookmarks.Extract(Bookmark));
  if Assigned(Bookmark) then
    FreeAndNil(Bookmark);
end;

function TAbstractScaner.ForwardToken(Count: Integer): TPascalToken;
var
  Bookmark: TScannerBookmark;
  I: Integer;
begin
  Result := Token;

  SaveBookmark(Bookmark);

  for I := 0 to Count - 1 do
  begin
    Result := NextToken;
    if Result = tokEOF then
      Exit;
  end;

  LoadBookmark(Bookmark);
end;

function TAbstractScaner.BlankString: string;
var
  L: Integer;
begin
  L := FBlankStringEnd - FBlankStringBegin;
  SetString(Result, FBlankStringBegin, L);
end;

function TAbstractScaner.ErrorTokenString: string;
begin
  Result := TokenToString(Token);
  if Result = '' then
    Result := TokenString;
end;

procedure TAbstractScaner.DoBlankLinesWhenSkip(BlankLines: Integer);
begin
  if FKeepOneBlankLine and (BlankLines > 1) then
  begin
    FPrevBlankLines := True;
    OnMoreBlankLinesWhenSkip;
  end
  else
  begin
    FPrevBlankLines := False;
  end;
end;

function TAbstractScaner.TrimBlank(const Str: string): string;
begin
  Result := Str;
  if PrevBlankLines and (Length(Str) >= 2) then
  begin
    if Str[1] = #10 then
      Delete(Result, 1, 1)
    else if Str[2] = #10 then
      Delete(Result, 1, 2);
  end;
end;

procedure TAbstractScaner.NewLine;
begin
  Inc(FSourceLine);
  FSourceCol := 1;
end;

function TAbstractScaner.TokenStringLength: Integer;
begin
  if FToken = tokString then
    Result := FStringPtr - FTokenPtr
  else
    Result := FSourcePtr - FTokenPtr;
end;

function TAbstractScaner.BlankStringLength: Integer;
begin
  Result := FBlankStringEnd - FBlankStringBegin;
end;

{ TScaner }

constructor TScaner.Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
  ACompDirectiveMode: TCompDirectiveMode);
begin
  AStream.Seek(0, soFromBeginning);
  FStream := AStream;
  FCodeGen := ACodeGen;

  FCompDirectiveMode := ACompDirectiveMode; // Set CompDirective Process Mode
  inherited Create(AStream);
end;

constructor TScaner.Create(AStream: TStream);
begin
  Create(AStream, nil, CnPascalCodeForRule.CompDirectiveMode); //TCnCodeGenerator.Create);
end;

destructor TScaner.Destroy;
begin

  inherited;
end;

function TScaner.ForwardToken(Count: Integer): TPascalToken;
begin
  if FCodeGen <> nil then
    FCodeGen.LockOutput;
  try
    Result := inherited ForwardToken(Count);
  finally
    if FCodeGen <> nil then
      FCodeGen.UnLockOutput;
  end;
end;

function TScaner.NextToken: TPascalToken;
var
  BlankStr: string;

  procedure SkipTo(var P: PChar; TargetChar: Char);
  begin
    while (P^ <> TargetChar) do
    begin
      Inc(P);

      if (P^ = #0) then
      begin
        ReadBuffer;
        if FSourcePtr^ = #0 then
          Break;
      end;
    end;
  end;

var
  IsWideStr: Boolean;
  P, IgnoreP: PChar;
  Directive: TPascalToken;
  DirectiveNest: Integer;
  TmpToken: string;
begin
  SkipBlanks;
  P := FSourcePtr;
  FTokenPtr := P;

  case P^ of
    'A'..'Z', 'a'..'z', '_':
      begin
        Inc(P);
        while P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do Inc(P);
        Result := tokSymbol;
      end;

    '^':       // if a string starts with ^H, we can't know.
      begin
        Inc(P);
        Result := tokHat;
      end;

    '#', '''':
      begin
        IsWideStr := False;
        // parser string like this: 'abc'#10^M#13'def'#10#13
        while True do
          case P^ of
            '#':
              begin
                IsWideStr := True;
                Inc(P);
                while P^ in ['$', '0'..'9', 'a'..'f', 'A'..'F'] do Inc(P);
              end;
            '''':
              begin
                Inc(P);
                while True do
                  case P^ of
                    #0, #10, #13:
                      Error(CN_ERRCODE_PASCAL_INVALID_STRING);
                    '''':
                      begin
                        Inc(P);
                        Break;
                      end;
                  else
                    Inc(P);
                  end;
              end;
            '^':
              begin
                Inc(P);
                if not (P^ in [#33..#126]) then
                  Error(CN_ERRCODE_PASCAL_INVALID_STRING)
                else
                  Inc(P);
              end;
          else
            Break;
          end; // case P^ of

        FStringPtr := P;

        if IsWideStr then
          Result := tokWString
        else
          Result := tokString;
      end; // '#', '''': while True do

    '"':
      begin
        Inc(P);
        while not (P^ in ['"', #0, #10, #13]) do Inc(P);
        Result := tokString;
        if P^ = '"' then  // 和单引号字符串一样跳过最后一个双引号
          Inc(P);
        FStringPtr := P;
      end;

    '$':
      begin
        Inc(P);
        while P^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
          Inc(P);
        Result := tokInteger;
      end;

    '*':
      begin
        Inc(P);
        Result := tokStar;
      end;

    '{':
      begin
        IgnoreP := P;

        Inc(P);
        { Check Directive sign $}
        if P^ = '$' then
          Result := tokCompDirective
        else
          Result := tokComment;
        while ((P^ <> #0) and (P^ <> '}')) do
        begin
          if P^ = #10 then
            NewLine;
          Inc(P);
        end;

        if P^ = '}' then
        begin
          // 判断 IgnoreP 与 P 之间是否是 IgnoreFormat 标记
          if (Result = tokComment) and (Integer(P) - Integer(IgnoreP) = 3) then // 3 means '{(*}'
          begin
            Inc(IgnoreP);
            if IgnoreP^ = '(' then
            begin
              Inc(IgnoreP);
              if IgnoreP^ = '*' then
                InIgnoreArea := True;            // {(*} start to not format
            end
            else if IgnoreP^ = '*' then
            begin
              Inc(IgnoreP);
              if IgnoreP^ = ')' then
                InIgnoreArea := False;           // {*)} end of not format
            end;
          end;

          FBlankLinesAfterComment := 0;
          Inc(P);
          while P^ in [' ', #9] do
            Inc(P);

          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
          begin
            // ASM 模式下，换行作为语句结束符，不在注释内处理，所以这也不加
            if not FASMMode then
            begin
              NewLine;
              Inc(FBlankLinesAfterComment);
              Inc(P);
            end;
          end;
        end
        else
          Error(CN_ERRCODE_PASCAL_ENDCOMMENT_EXP);
      end;

    '/':
      begin
        Inc(P);

        if P^ = '/' then
        begin
          Result := tokComment;
          while (P^ <> #0) and (P^ <> #13) and (P^ <> #10) do
            Inc(P); // 找行尾

          FBlankLinesAfterComment := 0;

          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
          begin
            // ASM 模式下，换行作为语句结束符，不在注释内处理，所以这也不加
            if not FASMMode then
            begin
              NewLine;
              Inc(FBlankLinesAfterComment);
              Inc(P);
            end;
          end
          else
            Error(CN_ERRCODE_PASCAL_ENDCOMMENT_EXP);
        end
        else
          Result := tokDiv;
      end;

    '(':
      begin
        Inc(P);
        Result := tokLB;

        if P^ = '*' then
        begin
          Result := tokComment;

          Inc(P);
          FBlankLinesAfterComment := 0;
          while P^ <> #0 do
          begin
            if P^ = '*' then
            begin
              Inc(P);
              if P^ = ')' then
              begin
                Inc(P);
                while P^ in [' ', #9] do
                  Inc(P);

                if P^ = #13 then
                  Inc(P);
                if P^ = #10 then
                begin
                  // ASM 模式下，换行作为语句结束符，不在注释内处理，所以这也不加
                  if not FASMMode then
                  begin
                    NewLine;
                    Inc(FBlankLinesAfterComment);
                    Inc(P);
                  end;
                end;

                Break;
              end;
            end
            else
            begin
              if P^ = #10 then
                NewLine;
              Inc(P);
            end;
          end;
        end;
      end;

    ')':
      begin
        Inc(P);
        Result := tokRB;
      end;

    '[':
      begin
        Inc(P);
        Result := tokSLB;
      end;

    ']':
      begin
        Inc(P);
        Result := tokSRB;
      end;

    '=':
      begin
        Inc(P);
        Result := tokEQUAL;
      end;

    ':':
      begin
        Inc(P);
        if (P^ = '=') then
        begin
          Inc(P);
          Result := tokAssign;
        end else
          Result := tokColon;
      end;
      
    ';':
      begin
        Inc(P);
        Result := tokSemicolon;
      end;

    '.':
      begin
        Inc(P);

        if P^ = '.' then
        begin
          Result := tokRange;
          Inc(P);
        end else
          Result := tokDot;
      end;

    ',':
      begin
        Inc(P);
        Result := tokComma;
      end;

    '>':
      begin
        Inc(P);
        Result := tokGreat;

        // >< 不是不等于，原来的代码将其判断成不等于了，去掉
        if P^ = '=' then
        begin
          Result := tokGreatOrEqu;
          Inc(P);
        end;
      end;

    '<':
      begin
        Inc(P);
        Result := tokLess;
        
        if P^ = '=' then
        begin
          Result := tokLessOrEqu;
          Inc(P);
        end
        else if P^ = '>' then
        begin
          Result := tokNotEqual;
          Inc(P);
        end;
      end;

    '@':
      begin
        Inc(P);
        Result := tokAtSign;
      end;

    '&':
      begin
        Inc(P);
        Result := tokAmpersand;
      end;
      
    '+', '-':
      begin
        if P^ = '+' then
          Result := tokPlus
        else
          Result := tokMinus;

        Inc(P);
      end;

    '0'..'9':
      begin
        Inc(P);
        while P^ in ['0'..'9'] do Inc(P);
        Result := tokInteger;

        if (P^ = '.') and ((P+1)^ <> '.') then
        begin
          Inc(P);
          while P^ in ['0'..'9'] do Inc(P);
          Result := tokFloat;
        end;

        if P^ in ['e', 'E'] then
        begin
          Inc(P);
          if P^ in ['-', '+'] then
            Inc(P);
          while P^ in ['0'..'9'] do
            Inc(P);
          Result := tokFloat;
        end;

        if (P^ in ['c', 'C', 'd', 'D', 's', 'S']) then
        begin
          Result := tokFloat;
          FFloatType := P^;
          Inc(P);
        end
        else
          FFloatType := #0;
      end;
    #10:  // 如果有回车则处理，以 #10 为准
      begin
        Result := tokCRLF;
        if not FASMMode then // FSourceLine Inc-ed at another place
          NewLine;
        Inc(P);
      end;
  else
    if P^ = #0 then
      Result := tokEOF
    else
      Result := tokUnknown;

    if Result <> tokEOF then
      Inc(P);
  end;

  FSourcePtr := P;
  FToken := Result;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Line: %5.5d. Token: %s. InIgnoreArea %d', [FSourceLine, TokenString,
    Integer(InIgnoreArea)]);
{$ENDIF}

  if InIgnoreArea and (FCodeGen <> nil) then
    FCodeGen.Write(BlankString);

  // FCompDirectiveMode = cdmNone 表示忽略，此处啥都不做，供低级扫描使用。

  if FCompDirectiveMode = cdmAsComment then
  begin
    if (Result = tokComment) or (Result = tokCompDirective) then // 当前是 Comment
    begin
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
            FCodeGen.Write(BlankStr); // 把上回内容尾巴，到现在注释开头的空白部分写入
        end;
        FCodeGen.Write(TokenString); // 再写注释本身
      end;

      if not FFirstCommentInBlock then // 第一次碰到 Comment 时设置这个
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      Result := NextToken;
      // 进入递归寻找下一个 Token，
      // 进入后 FFirstCommentInBlock 为 True，因此不会重新记录 FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else
    begin
      // 只要当前不是 Comment 就设置非第一个 Comment 的标记
      FFirstCommentInBlock := False;

      if FPreviousIsComment then // 上一个是 Comment，记录这个到 上一个Comment的空行数
      begin
        // 最后一块注释的在递归最外层赋值，因此FBlankLinesAfter会被层层覆盖，
        // 代表最后一块注释后的空行数
        FBlankLinesAfter := FBlankLines + FBlankLinesAfterComment;
      end
      else // 上一个不是 Comment，当前也不是 Comment。全清0
      begin
        FBlankLinesAfter := 0;
        FBlankLinesBefore := 0;
        FBlankLines := 0;
      end;

      if not InIgnoreArea and (FCodeGen <> nil) and
        (FBackwardToken = tokComment) or (FBackwardToken = tokCompDirective) then // 当前不是 Comment，但前一个是 Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FToken := Result;
      FBackwardToken := FToken;
    end;
  end
  else if FCompDirectiveMode = cdmOnlyFirst then
  begin
    if (Result = tokComment) or ((Result = tokCompDirective) and
      (Pos('{$ELSE', UpperCase(TokenString)) = 0) ) then // NOT $ELSE/$ELSEIF
    begin
      if FInDirectiveNestSearch then // In a Nested search for ENDIF/IFEND
        Exit;

      // 当前是 Comment，或非ELSE编译指令，当普通注释处理
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
            FCodeGen.Write(BlankStr); // 把上回内容尾巴，到现在注释开头的空白部分写入
        end;
        FCodeGen.Write(TokenString); // 再写注释本身
      end;

      if not FFirstCommentInBlock then // 第一次碰到 Comment 时设置这个
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      Result := NextToken;
      // 进入递归寻找下一个 Token，
      // 进入后 FFirstCommentInBlock 为 True，因此不会重新记录 FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else if (Result = tokCompDirective) and (Pos('{$ELSE', UpperCase(TokenString)) = 1) then // include ELSEIF
    begin
      // 如果本处是IF/IFEND或其他，可以不管，
      // 如果是ELSEIF，则找对应的IFEND，并跳过两者之间的
      // 但找的过程中要忽略中间其他配对的IFDEF/IFNDEF/IFOPT与ENDIF以及同级的ELSE/ELSEIF

      if FInDirectiveNestSearch then // In a Nested search for ENDIF/IFEND
        Exit;

      if not FFirstCommentInBlock then // 第一次碰到 Comment 时设置这个
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
          FCodeGen.Write(BlankString);
        FCodeGen.Write(TokenString); // Write ELSE/ELSEIF itself
      end;

      FInDirectiveNestSearch := True;

      DirectiveNest := 1; // 1 means ELSE/ELSEIF itself
      FPreviousIsComment := True;
      Directive := NextToken;
      FPreviousIsComment := False;
      TmpToken := TokenString;

      try
        while Directive <> tokEOF do
        begin
          if Assigned(FCodeGen) then
          begin
            if not InIgnoreArea then
              FCodeGen.Write(BlankString);
            FCodeGen.Write(TmpToken);
          end;

          if Directive = tokCompDirective then
          begin
            if (Pos('{$IFDEF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFNDEF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IF ', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFOPT', UpperCase(TmpToken)) = 1) then
            begin
              Inc(DirectiveNest);
            end
            else if (Pos('{$ENDIF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFEND', UpperCase(TmpToken)) = 1) then
            begin
              Dec(DirectiveNest);
              if DirectiveNest = 0 then
              begin
                FInDirectiveNestSearch := False;
                // 已经顺利找到了，再往后按原有的跳过注释的规矩找下一个Token
                // 避免下一个又是IFDEF时出问题。
                FPreviousIsComment := True;
                Result := NextToken;
                FPreviousIsComment := False;
                Exit;
              end;
            end;
          end;
          FPreviousIsComment := True;
          Directive := NextToken;
          FPreviousIsComment := False;
          TmpToken := TokenString;
        end;
        Result := tokEOF;
        FToken := Result;
      finally
        FInDirectiveNestSearch := False;
      end;
    end
    else
    begin
      // 只要当前不是 Comment 就设置非第一个 Comment 的标记
      FFirstCommentInBlock := False;

      if FPreviousIsComment then // 上一个是 Comment，记录这个到 上一个Comment的空行数
      begin
        // 最后一块注释的在递归最外层赋值，因此FBlankLinesAfter会被层层覆盖，
        // 代表最后一块注释后的空行数
        FBlankLinesAfter := FBlankLines + FBlankLinesAfterComment;
      end
      else // 上一个不是 Comment，当前也不是 Comment。全清0
      begin
        FBlankLinesAfter := 0;
        FBlankLinesBefore := 0;
        FBlankLines := 0;
      end;

      if not InIgnoreArea and (FCodeGen <> nil) and
        (FBackwardToken = tokComment) then // 当前不是 Comment，但前一个是 Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FToken := Result;
      FBackwardToken := FToken;
    end;
  end;
end;

procedure TScaner.OnMoreBlankLinesWhenSkip;
begin
  if FCodeGen <> nil then
    FCodeGen.Writeln;
end;

end.
