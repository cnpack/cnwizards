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

unit CnScanners;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：Object Pascal 词法分析器
* 单元作者：CnPack开发组
* 备    注：该单元实现了 Object Pascal 词法分析器
*    缓冲区机制：一块固定长度的缓冲区，读入代码内容后找到最后一个换行，以此为结尾。
*    扫描至结尾后，重新 ReadBuffer，把本区域结尾到缓冲区尾的内容重新填回缓冲区首，
*    再在其后跟读满缓冲区，再找最后一个换行并标记结尾。
*    但问题的极端情况是，当结尾是块注释中的行末时，未能有效重新 ReadBuffer，
*    即使在处理注释块内部碰到 #0 时加入 ReadBuffer 的处理，也会因为可能的
*    ”整个缓冲区全是注释“导致 FSourcePtr 没有步进从而无法读入新内容的情况。
*           唯一办法：使用足够大的单块缓冲区！
*           另外，Unicode 编译器中，才支持 Unicode 标识符和全角空格
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2007-10-13 V1.0
*               完善一些功能
*           2004-1-14 V0.5
*               加入标签(Bookmark)功能，可以方便的向前看 N 个 Token
*           2003-12-16 V0.4
*               建立。目前自动跳过空格和注释。注释不应该跳过，但是还需要处理。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Contnrs, CnFormatterIntf, CnNative,
  CnParseConsts, CnTokens, CnCodeGenerators, CnCodeFormatRules;

type
  TScannerBookmark = packed record
    OriginBookmark: Longint;
    TokenBookmark: TPascalToken;
    TokenPtrBookmark: PChar;
    SourcePtrBookmark: PChar;
    SourceLineBookmark: Integer;
    BlankLinesBeforeBookmark: Integer;
    BlankLinesAfterBookmark: Integer;
    PrevBlankLinesBookmark: Boolean;
    SourceColBookmark: Integer;
    InIgnoreAreaBookmark: Boolean;
    NewSourceColBookmark: Integer;
    OldSourceColPtrBookmark: PChar;
    PrevTokenBookmark: TPascalToken;
    PrevEffectiveeTokenBookmark: TPascalToken;
  end;

  TGetBooleanEvent = function(Sender: TObject): Boolean of object;

  TAbstractScanner = class(TObject)
  private
    FStream: TStream;
    FBookmarks: TObjectList;

    // 缓冲区机制的问题见头部注释
    FOrigin: Longint;  // 表示缓冲区本块内容开头在整个流中的线性位置
    FBuffer: PChar;    // 一块固定长度的缓冲区的开始地址
    FBufSize: Cardinal;
    FBufPtr: PChar;
    FBufEnd: PChar;
    FSourcePtr: PChar; // 用于步进，在外部始终指向当前 Token 尾部
    FSourceEnd: PChar; // 读入内容至缓冲区后，用 LineStart 找到的最后一个换行，作为本次扫描的结尾，而不是缓冲区尾

    FTokenPtr: PChar;  // 用于步进，在外部始终指向当前 Token 头部
    FOldSourceColPtr: PChar; // 用于步进，在外部始终指向上一个列开始计算的位置
    FStringPtr: PChar;
    FSourceLine: Integer;
    FSaveChar: Char;
    FPrevToken: TPascalToken;              // 保存步进时上一个 Token
    FPrevEffectiveToken: TPascalToken;     // 保存步进时上一个有效 Token，也就是非空白非注释 Token
    FToken: TPascalToken;
    FFloatType: Char;
    FWideStr: WideString;
    FBackwardToken: TPascalToken;
    // FBackwardNonBlankToken: TPascalToken;

    FBlankStringBegin: PChar;  // 用于步进，在外部始终指向当前空白的头部
    FBlankStringEnd: PChar;    // 用于步进，在外部始终指向当前空白的尾部
    FBlankLines, FBlankLinesAfterComment: Integer;
    FBlankLinesBefore: Integer;
    FBlankLinesAfter: Integer;
    FASMMode: Boolean;
    FFirstCommentInBlock: Boolean;
    FPreviousIsComment: Boolean;
    FInDirectiveNestSearch: Boolean;
    FKeepOneBlankLine: Boolean;
    FPrevBlankLines: Boolean;
    FNewSourceCol: Integer; // 用于步进，指向下一个 Token 的列
    FSourceCol: Integer;
    FInIgnoreArea: Boolean;
    FOnLineBreak: TNotifyEvent;
    FIdentContainsDot: Boolean;
    FIsForwarding: Boolean;
    FOnGetCanLineBreak: TGetBooleanEvent;
    FJustWroteBlockComment: Boolean;
    procedure ReadBuffer;
    procedure SetOrigin(AOrigin: Longint);
    procedure SkipBlanks; // 越过空白和回车换行
    procedure DoBlankLinesWhenSkip(BlankLines: Integer); virtual;
    {* SkipBlanks 时遇到连续换行时被调用}
    function ErrorTokenString: string;
    procedure NewLine(ImmediatelyDoBreak: Boolean = True);
{$IFDEF UNICODE}
    procedure FixStreamBom;
{$ENDIF}
  protected
    procedure OnMoreBlankLinesWhenSkip; virtual; abstract;
    procedure DoLineBreak; virtual;
    function GetCanLineBreakFromOut: Boolean; virtual;
  public
    constructor Create(Stream: TStream); virtual;
    destructor Destroy; override;
    procedure CheckToken(T: TPascalToken);
    procedure CheckTokenSymbol(const S: string);
    procedure Error(const Ident: Integer);
    procedure ErrorFmt(const Ident: Integer; const Args: array of const);
    procedure ErrorStr(const Message: string);

    function IsInStatement: Boolean;
    {* 判断当前是否在语句内部}

    function IsInOpStatement: Boolean;
    {* 判断当前是否在语句内部，不包括开头，大概算是开区间}

    function NextToken: TPascalToken; virtual; abstract;
    function SourcePos: LongInt;
    // 当前 Token 在整个源码中的偏移量，0 开始
    function BlankStringPos: LongInt;
    // 当前空白在整个源码中的偏移量，0 开始

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
    procedure LoadBookmark(var Bookmark: TScannerBookmark);

    function ForwardToken(Count: Integer = 1): TPascalToken; virtual;
    {* 不产生实际作用地往前提前找一个 Token，包括注释，找完后所有状态均保持现状不动}
    function ForwardActualToken(Count: Integer = 0): TPascalToken; virtual;
    {* 不产生实际作用地往前提前找一个除注释、空白外的有效 Token，找完后所有状态均保持现状不动
      这里 Count 可以是 0，表示当前如果是有效 Token 就返回当前 Token，否则找下一个 Token}

    property FloatType: Char read FFloatType;
    property SourceLine: Integer read FSourceLine;  // 行，以 1 开始
    property SourceCol: Integer read FSourceCol;    // 列，以 1 开始

    property Token: TPascalToken read FToken;
    property TokenPtr: PChar read FTokenPtr;

    property ASMMode: Boolean read FASMMode write FASMMode;
    {* 用来控制是否将回车当作空白以及其他解析，asm 块中需要此选项}

    property IsForwarding: Boolean read FIsForwarding;
    {* Scanner 是否在脱离真实输出的情形下往前找}

    property BlankLinesBefore: Integer read FBlankLinesBefore write FBlankLinesBefore;
    {* SkipBlank 碰到一注释时，注释和前面有效内容隔的行数，用来控制分行。
      0 表示在同一行，1 表示注释在紧邻的下一行，2 表示注释和前面的内容隔一个空行}
    property BlankLinesAfter: Integer read FBlankLinesAfter write FBlankLinesAfter;
    {* SkipBlank 跳过一注释后，注释和后面有效内容隔的行数，用来控制分行。
      0 表示在同一行，1 表示后续内容在紧邻的下一行，2 表示注释和后续内容隔一个空行}

    property PrevBlankLines: Boolean read FPrevBlankLines write FPrevBlankLines;
    {* 记录上一次是否输出了连续空行合并成的一个空行}

    property KeepOneBlankLine: Boolean read FKeepOneBlankLine write FKeepOneBlankLine;
    {* 由外界设置是否在格式化的过程中保持语句间的空行，无须用 Bookmark 保存
       目的：源语句中有多于一个的连续换行就只输出一个换行，注意该标志并不等于保留换行}

    property IdentContainsDot: Boolean read FIdentContainsDot write FIdentContainsDot;
    {* 由外界设置是否允许标识符里含有点号，用于单元名，无须用 Bookmark 保存}

    property InIgnoreArea: Boolean read FInIgnoreArea write FInIgnoreArea;
    {* 由内部前进 Token 时解析设置当前是否忽略格式化标记，供外界使用}

    property JustWroteBlockComment: Boolean read FJustWroteBlockComment;
    {* 是否刚输出块注释}

    property OnLineBreak: TNotifyEvent read FOnLineBreak write FOnLineBreak;
    {* 遇到源文件换行时的事件}
    property OnGetCanLineBreak: TGetBooleanEvent read FOnGetCanLineBreak write FOnGetCanLineBreak;
    {* 需要获取 Formatter 的当前位置是否允许保留换行的标志事件}
  end;

  TScanner = class(TAbstractScanner)
  private
    FStream: TStream;
    FCodeGen: TCnCodeGenerator;
    FCompDirectiveMode: TCnCompDirectiveMode;
    FNestedIsComment: Boolean;
    procedure StorePrevEffectiveToken(AToken: TPascalToken);
  protected
    procedure OnMoreBlankLinesWhenSkip; override;    
  public
    constructor Create(AStream: TStream); overload; override;
    constructor Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
      ACompDirectiveMode: TCnCompDirectiveMode); reintroduce; overload;
    destructor Destroy; override;
    function NextToken: TPascalToken; override;
    function ForwardToken(Count: Integer = 1): TPascalToken; override;
    function ForwardActualToken(Count: Integer = 1): TPascalToken; override;
    property CompDirectiveMode: TCnCompDirectiveMode read FCompDirectiveMode;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  MIN_SCAN_BUF_SIZE = 512 * 1024 {512KB};
  MAX_SCAN_BUF_SIZE = 32 * 1024 * 1024 {32MB};

{ TAbstractScaner }

constructor TAbstractScanner.Create(Stream: TStream);
begin
  FStream := Stream;
{$IFDEF UNICODE}
  FixStreamBom;
{$ENDIF}
  FBookmarks := TObjectList.Create;

  if Stream.Size < MIN_SCAN_BUF_SIZE then
    FBufSize := MIN_SCAN_BUF_SIZE
  else if Stream.Size > MAX_SCAN_BUF_SIZE then
    FBufSize := MAX_SCAN_BUF_SIZE
  else
    FBufSize := Stream.Size;

  GetMem(FBuffer, FBufSize);
  FBuffer[0] := #0;
  FBufPtr := FBuffer;
  FBufEnd := FBuffer + FBufSize div SizeOf(Char); // PChar 运算以 Char 为单位，所以得除以 Char 的大小
  FSourcePtr := FBuffer;
  FSourceEnd := FBuffer;
  FTokenPtr := FBuffer;
  FOldSourceColPtr := FBuffer;
  FSourceLine := 1;
  FSourceCol := 1;
  FNewSourceCol := 1;
  FBackwardToken := tokNoToken;

  // NextToken;  Let outside call it.
end;

{$IFDEF UNICODE}

procedure TAbstractScanner.FixStreamBom;
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

destructor TAbstractScanner.Destroy;
begin
  if FBuffer <> nil then
  begin
    FStream.Seek(Longint(FTokenPtr) - Longint(FBufPtr), 1);
    FreeMem(FBuffer);
  end;

  FBookmarks.Free;
end;

procedure TAbstractScanner.CheckToken(T: TPascalToken);
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

procedure TAbstractScanner.CheckTokenSymbol(const S: string);
begin
  if not TokenSymbolIs(S) then ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [S]);
end;

procedure TAbstractScanner.Error(const Ident: Integer);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TAbstractScanner.ErrorFmt(const Ident: Integer; const Args: array of const);
begin
  // 出错入口
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;  
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;
  
  ErrorStr(Format(RetrieveFormatErrorString(Ident), Args));
end;

procedure TAbstractScanner.ErrorStr(const Message: string);
begin
  raise EParserError.CreateFmt(SParseError, [Message, FSourceLine, SourcePos]);
end;

procedure TAbstractScanner.ReadBuffer;
var
  Count: Integer;
begin
  Inc(FOrigin, TCnNativeInt(FSourcePtr) - TCnNativeInt(FBuffer));
  FSourceEnd[0] := FSaveChar;
  Count := TCnNativeInt(FBufPtr) - TCnNativeInt(FSourcePtr);
  if Count <> 0 then
    Move(FSourcePtr[0], FBuffer[0], Count);
  FBufPtr := PChar(TCnNativeInt(FBuffer) + Count);

  Count := FStream.Read(FBufPtr[0], (TCnNativeInt(FBufEnd) - TCnNativeInt(FBufPtr))); // 读进来的 Byte 数
  FBufPtr := PChar(TCnNativeInt(FBufPtr) + Count);

  FSourcePtr := FBuffer;
  FSourceEnd := FBufPtr;
  if FSourceEnd = FBufEnd then
  begin
    FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
    if FSourceEnd = FBuffer then
      Error(CN_ERRCODE_PASCAL_LINE_TOOLONG);
  end;
  FSaveChar := FSourceEnd[0];
  FSourceEnd[0] := #0;
end;

procedure TAbstractScanner.SetOrigin(AOrigin: Integer);
var
  Count: Integer;
begin
  if AOrigin <> FOrigin then
  begin
    FOrigin := AOrigin;
    FSourceEnd[0] := FSaveChar;
    FStream.Seek(AOrigin, soFromBeginning);
    FBufPtr := FBuffer;

    Count := FStream.Read(FBuffer[0], FBufSize);
    FBufPtr := PChar(TCnNativeInt(FBufPtr) + Count);

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

procedure TAbstractScanner.SkipBlanks;
var
  EmptyLines: Integer;
begin
  FBlankStringBegin := FSourcePtr;
  FBlankStringEnd := FBlankStringBegin;
  FBlankLines := 0;

  EmptyLines := 0;
  while True do
  begin
{$IFDEF UNICODE}  // Unicode 版本下，支持将全角空格作为空格来处理
    if FSourcePtr^ = '　' then
    begin
      Inc(FSourcePtr);
      FBackwardToken := tokBlank;
      Continue;
    end;
{$ENDIF}

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
          FOldSourceColPtr := FSourcePtr;
          Inc(FOldSourceColPtr);
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
          DoBlankLinesWhenSkip(EmptyLines);  // 这里容易多输出回车

          Exit;
        end;
    end;
    
    Inc(FSourcePtr);
    FBackwardToken := tokBlank;
  end;
end;

function TAbstractScanner.SourcePos: Longint;
begin
  Result := FOrigin + (FTokenPtr - FBuffer);
end;

function TAbstractScanner.BlankStringPos: Longint;
begin
  Result := FOrigin + (FBlankStringBegin - FBuffer);
end;

function TAbstractScanner.TokenFloat: Extended;
begin
  if FFloatType <> #0 then Dec(FSourcePtr);
  Result := StrToFloat(TokenString);
  if FFloatType <> #0 then Inc(FSourcePtr);
end;

{$IFDEF DELPHI5}
function TAbstractScanner.TokenInt: Integer;
begin
  Result := StrToInt(TokenString);
end;
{$ELSE}
function TAbstractScanner.TokenInt: Int64;
begin
  Result := StrToInt64(TokenString);
end;
{$ENDIF}

function TAbstractScanner.TokenString: string;
var
  L: Integer;
begin
  if FToken = tokString then
    L := FStringPtr - FTokenPtr
  else
    L := FSourcePtr - FTokenPtr;
  SetString(Result, FTokenPtr, L);
end;

function TAbstractScanner.TokenWideString: WideString;
begin
  if FToken = tokString then
    Result := TokenString
  else
    Result := FWideStr;
end;

function TAbstractScanner.TokenSymbolIs(const S: string): Boolean;
begin
  Result := SameText(S, TokenString);
end;

function TAbstractScanner.TokenComponentIdent: string;
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

function TAbstractScanner.TokenChar: Char;
begin
  if Length(TokenString) > 0 then
    Result := TokenString[1]
  else
    Result := #0;
end;

procedure TAbstractScanner.LoadBookmark(var Bookmark: TScannerBookmark);
begin
  with Bookmark do
  begin
    if Assigned(SourcePtrBookmark) and Assigned(TokenPtrBookmark) then
    begin
      if OriginBookmark <> FOrigin then
        SetOrigin(OriginBookmark);
      FSourcePtr := SourcePtrBookmark;
      FTokenPtr := TokenPtrBookmark;
      FOldSourceColPtr := OldSourceColPtrBookmark;
      FPrevToken := PrevTokenBookmark;
      FPrevEffectiveToken := PrevEffectiveeTokenBookmark;
      FToken := TokenBookmark;
      FSourceLine := SourceLineBookmark;
      FSourceCol := SourceColBookmark;
      FNewSourceCol := NewSourceColBookmark;
      FBlankLinesBefore := BlankLinesBeforeBookmark;
      FBlankLinesAfter := BlankLinesAfterBookmark;
      FPrevBlankLines := PrevBlankLinesBookmark;
      FInIgnoreArea := InIgnoreAreaBookmark;
    end
    else
      Error(CN_ERRCODE_PASCAL_INVALID_BOOKMARK);
  end;
end;

procedure TAbstractScanner.SaveBookmark(var Bookmark: TScannerBookmark);
begin
  with Bookmark do
  begin
    OriginBookmark := FOrigin;
    SourcePtrBookmark := FSourcePtr;
    PrevTokenBookmark := FPrevToken;
    PrevEffectiveeTokenBookmark := FPrevEffectiveToken;
    TokenBookmark := FToken;
    TokenPtrBookmark := FTokenPtr;
    OldSourceColPtrBookmark := FOldSourceColPtr;
    SourceLineBookmark := FSourceLine;
    SourceColBookmark := FSourceCol;
    NewSourceColBookmark := FNewSourceCol;
    BlankLinesBeforeBookmark := FBlankLinesBefore;
    BlankLinesAfterBookmark := FBlankLinesAfter;
    PrevBlankLinesBookmark := FPrevBlankLines;
    InIgnoreAreaBookmark := FInIgnoreArea;
  end;
end;

function TAbstractScanner.ForwardToken(Count: Integer): TPascalToken;
var
  Bookmark: TScannerBookmark;
  I: Integer;
begin
  Result := Token;

  SaveBookmark(Bookmark);
  FIsForwarding := True;
  try
    for I := 0 to Count - 1 do
    begin
      Result := NextToken;
      if Result = tokEOF then
        Exit;
    end;
  finally
    FIsForwarding := False;
  end;

  LoadBookmark(Bookmark);
end;

function TAbstractScanner.ForwardActualToken(Count: Integer): TPascalToken;
var
  Bookmark: TScannerBookmark;
  I: Integer;
begin
  Result := Token;
  // 0 时如果当前 Token 有效，直接返回
  if (Count = 0) and not (Result in NonEffectiveTokens + [tokEOF]) then
    Exit;

  SaveBookmark(Bookmark);
  FIsForwarding := True;

  // 此时 Result 在注释等 Token 上
  try
    I := 0;

    repeat
      repeat
        Result := NextToken;
      until (Result = tokEOF) or not (Result in NonEffectiveTokens);

      if Result = tokEOF then
        Exit;

      Inc(I);
    until I >= Count;
  finally
    LoadBookmark(Bookmark);
    FIsForwarding := False;
  end;
end;

function TAbstractScanner.BlankString: string;
var
  L: Integer;
begin
  L := FBlankStringEnd - FBlankStringBegin;
  SetString(Result, FBlankStringBegin, L);
end;

function TAbstractScanner.ErrorTokenString: string;
begin
  Result := TokenToString(Token);
  if Result = '' then
    Result := TokenString;
end;

procedure TAbstractScanner.DoBlankLinesWhenSkip(BlankLines: Integer);
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

procedure TAbstractScanner.DoLineBreak;
begin
  if Assigned(FOnLineBreak) then
    FOnLineBreak(Self);
end;

function TAbstractScanner.TrimBlank(const Str: string): string;
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

procedure TAbstractScanner.NewLine(ImmediatelyDoBreak: Boolean);
begin
  Inc(FSourceLine);
{$IFDEF DEBUG}
//  CnDebugger.LogMsg('Scaner NewLine: SourceLine: ' + IntToStr(FSourceLine));
{$ENDIF}
  FNewSourceCol := 1;
  if ImmediatelyDoBreak then
    DoLineBreak;
end;

function TAbstractScanner.TokenStringLength: Integer;
begin
  if FToken = tokString then
    Result := FStringPtr - FTokenPtr
  else
    Result := FSourcePtr - FTokenPtr;
end;

function TAbstractScanner.BlankStringLength: Integer;
begin
  Result := FBlankStringEnd - FBlankStringBegin;
end;

function TAbstractScanner.IsInStatement: Boolean;
begin
  // 判定当前 Token 是否语句内部，上一个是分号或组合语句或双目运算符（真正的语句内部），作为语句内换行的额外判断补充。
  // 当前 Token 可能是空白注释之类的，此时前一个有效 Token 是分号或一些关键字，就说明当前位置已在语句外
  // 如果前一个有效 Token 是标识符，就得判断当前或靠后（如果当前的是注释）的有效 Token 是不是 End 和 Else
  // 如果靠后一个是，表示语句已经结束，现状已经在语句外了。以应对 End 或 Else 前的语句无分号的问题
  if not FIsForwarding then
    Result := (FPrevEffectiveToken in [tokSemicolon, tokKeywordFinally, tokKeywordExcept,
      tokKeywordOf, tokKeywordElse, tokKeywordDo] + StructStmtTokens +
      RelOpTokens + AddOPTokens + MulOpTokens + ShiftOpTokens)
      or not (ForwardActualToken() in [tokKeywordEnd, tokKeywordElse]) // 这句对性能有所影响
  else
    Result := FPrevEffectiveToken in [tokSemicolon] + StructStmtTokens;
  // 在 ForwardToken 调用中不要再重入了
end;

function TAbstractScanner.IsInOpStatement: Boolean;
const
  OpTokens = RelOpTokens + AddOPTokens + MulOpTokens + ShiftOpTokens
    + [tokAssign];
begin
  if FPrevEffectiveToken = tokSemicolon then // 分号说明不在语句内
  begin
    Result := False;
    Exit;
  end;

  Result := FPrevEffectiveToken in OpTokens + [tokLB, tokSLB, tokKeywordVar];
  // 双目运算符后，或左括号后。或 inline var 的 var 后

  if not Result and not FIsForwarding then
    Result := ForwardActualToken() in OpTokens + [tokSemicolon, tokRB, tokSRB,
      tokKeywordDo, tokKeywordOf, tokKeywordThen];  // 或者下一个是双目运算符或分号或右括号几个其他语句结束关键字
  // 可能还有其他判断
end;

function TAbstractScanner.GetCanLineBreakFromOut: Boolean;
begin
  Result := False;
  if Assigned(FOnGetCanLineBreak) then
    Result := FOnGetCanLineBreak(Self);
end;

{ TScaner }

constructor TScanner.Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
  ACompDirectiveMode: TCnCompDirectiveMode);
begin
  AStream.Seek(0, soFromBeginning);
  FStream := AStream;
  FCodeGen := ACodeGen;

  FCompDirectiveMode := ACompDirectiveMode; // Set CompDirective Process Mode
  inherited Create(AStream);
end;

constructor TScanner.Create(AStream: TStream);
begin
  Create(AStream, nil, CnPascalCodeForRule.CompDirectiveMode);
end;

destructor TScanner.Destroy;
begin

  inherited;
end;

function TScanner.ForwardActualToken(Count: Integer): TPascalToken;
begin
  if FCodeGen <> nil then
    FCodeGen.LockOutput;
  try
    Result := inherited ForwardActualToken(Count);
  finally
    if FCodeGen <> nil then
      FCodeGen.UnLockOutput;
  end;
end;

function TScanner.ForwardToken(Count: Integer): TPascalToken;
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

function TScanner.NextToken: TPascalToken;
var
  BlankStr: string;
  S: string;
  Idx: Integer;
  LocalJustWroteBlockComment: Boolean;

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

  function IsStringStartWithSpacesCRLF(const Str: string): Boolean;
  var
    I, P: Integer;
  begin
    Result := False;
    P := Pos(#13#10, Str);
    if P <= 0 then  // 无回车返回 False
      Exit;

    for I := 1 to P - 1 do
    begin
      if not (Str[I] in [' ', #9]) then
        Exit;
    end;
    Result := True;
  end;

var
  IsWideStr, FloatStop, IsString, IsMultiLineStr, PrevMulti: Boolean;
  P, IgnoreP, OldP: PChar;
  Directive: TPascalToken;
  DirectiveNest, FloatCount: Integer;
  TmpToken: string;
begin
  FOldSourceColPtr := FSourcePtr;
  LocalJustWroteBlockComment := False;

  SkipBlanks;
  FSourceCol := FNewSourceCol;

  P := FSourcePtr;
  FTokenPtr := P;
  // FTokenPtr 保存了本次步进的原始位置，步进完毕后，P 与 FTokenPtr 的差就是当前 Token 的长度

  // FOldSourceColPtr 保存本次步进的原始列位置，步进完毕后，如未出现换行，P 与 OldColPtr 的差就是 NewSourceCol 需要增加的长度
  // 如出现换行，换行处 SourceCol 被置 1、OldCol 被赋值为换行处，末了仍然是 NewSourceCol += P - OldCol;

  case P^ of
    'A'..'Z', 'a'..'z', '_' {$IFDEF UNICODE}, #$0100..#$FFFF {$ENDIF}:
      begin
        Inc(P);
        if FIdentContainsDot then // 如果外部要求标识符包括点号如单元名等
        begin
          while (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_', '.'])
            {$IFDEF UNICODE} or ((P^ >= #$0100) and (P^ <> '　')) {$ENDIF} do
            Inc(P);
        end
        else  // 注意 Unicode 环境下，Unicode 标识符不包括全角空格，全角空格做半角空格用
        begin
          while (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'])
            {$IFDEF UNICODE} or ((P^ >= #$0100) and (P^ <> '　')) {$ENDIF} do
            Inc(P);
        end;
        Result := tokSymbol;
      end;

    '^':
      begin
        OldP := P;

        Inc(P);
        Result := tokNoToken;

        // 回溯一下，如果 ^ 之前越过空白是字母数字或 )]^，就表示不是字符串而是 Hat
        // 但前面如果是块注释呢？
        if OldP > FBuffer then
        begin
          repeat
            Dec(OldP);

            // 如果 OldP 是块注释尾，跳到块注释头，注意没处理 (* *) 这种格式的块注释，真碰到也认了
            while OldP^ = '}' do
            begin
              repeat
                Dec(OldP);
              until (OldP^ = '{') or (OldP <= FBuffer);

              if OldP^ = '{' then
                Dec(OldP);
            end;

          until (not (OldP^ in [' ', #10, #13, #9])) or (OldP <= FBuffer);

          if OldP^ in ['A'..'Z', 'a'..'z', '0'..'9', '^', ')', ']'] then
            Result := tokHat;
        end;

        OldP := P;
        IsString := False;
        if Result <> tokHat then // 没有确定是 Hat 的情况下，再判断是否是字符串
        begin
          // 目前只处理 ^H^J 这种尖号后单个字符的场合，暂未处理混合 '' 型字符串的情形
          IsString := True;

          repeat // 进入此循环时，P 必定指向 ^ 后的一个字符
            if not (P^ in [#33..#126]) then
            begin // ^ 后字符不对则表示不是字符串，跳出
              IsString := False;
              Break;
            end;

            Inc(P);
            if P^ = '^' then
            begin
              Inc(P);
              Continue;
            end;

            // ^后的字符之后如果不是^，就需要退出，如果同时还是标识符，说明不是字符串，回溯。
            if P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'] then
              IsString := False;

            Break;
          until False;
        end;

        if IsString then
        begin
          Result := tokString;
          FStringPtr := P;
        end
        else
        begin
          P := OldP;
          Result := tokHat;
        end;
      end;

    '#', '''':
      begin
        IsMultiLineStr := False;
        OldP := P;

        if P^ = '''' then       // 第一个单引号
        begin
          Inc(P);
          if P^ = '''' then     // 第二个单引号
          begin
            Inc(P);
            if P^ = '''' then   // 第三个单引号
            begin
              Inc(P);
              if P^ in [#13, #10] then  // 后面得是回车或换行
                IsMultiLineStr := True;
            end;
          end;
        end;

        if IsMultiLineStr then  // 是多行字符串的新语法
        begin
          Result := tokMString;

          // 寻找后面的三个单引号做结尾，此时 P 指向第三个单引号
          Inc(P);
          PrevMulti := False;

          while True do
          begin
            if P^ = #0 then
              Break;

            OldP := P;
            if not PrevMulti and (P^ = '''') then
            begin
              Inc(P);
              if P^ = '''' then
              begin
                Inc(P);
                if P^ = '''' then
                begin
                  Inc(P);
                  if P^ <> '''' then // 碰到仨单引号且后面的不是单引号
                    Break;
                end;
              end;
            end;
            P := OldP;

            PrevMulti := P^ = '''';
            Inc(P);
          end;

        end
        else
        begin
          P := OldP;

          IsWideStr := False;
          // parser string like this: 'abc'#10^M#13'def'#10#13
          while True do
          begin
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
          end;

          FStringPtr := P;

          if IsWideStr then
            Result := tokWString
          else
            Result := tokString;
        end;
      end;
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
        while P^ in ['0'..'9', 'A'..'F', 'a'..'f', '_'] do  // D11 新增 _ 代替分节号
          Inc(P);
        Result := tokInteger;
      end;

    '%':  // D11 新增二进制语法 %100001 这种，以及 _ 代替分节号
      begin
        Inc(P);
        while P^ in ['0', '1', '-'] do
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
          Result := tokBlockComment;
        while ((P^ <> #0) and (P^ <> '}')) do
        begin
          if P^ = #10 then
          begin
            if not FKeepOneBlankLine then // 保持语句间的空行时，块注释中间的换行要忽略，
              NewLine
            else
              NewLine(False);             // 但也必须参与换行计数，否则源目标行数对应会错乱

            FOldSourceColPtr := P;
            Inc(FOldSourceColPtr);
          end;
          Inc(P);
        end;

        if P^ = '}' then
        begin
          // 判断 IgnoreP 与 P 之间是否是 IgnoreFormat 标记
          if (Result = tokBlockComment) and (TCnNativeInt(P) - TCnNativeInt(IgnoreP) = 3 * SizeOf(Char)) then // 3 means '{(*}'
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
              if not FKeepOneBlankLine then // 保持语句间的空行时，块注释末尾的换行要忽略，
                NewLine
              else
                NewLine(False);             // 但也必须参与换行计数，否则源目标行数对应会错乱

              Inc(FBlankLinesAfterComment);
              Inc(P);
              FOldSourceColPtr := P;
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
          Result := tokLineComment;
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
              NewLine(False);  // 行注释结尾的换行暂不参与保留换行选项的处理
              Inc(FBlankLinesAfterComment);
              Inc(P);
              FOldSourceColPtr := P;
            end;
          end
          else if P^ <> #0 then
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
          Result := tokBlockComment;

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
                    if not FKeepOneBlankLine then // 保持语句间的空行时，块注释中间的换行要忽略，
                      NewLine
                    else
                      NewLine(False);             // 但也必须参与换行计数，否则源目标行数对应会错乱

                    Inc(FBlankLinesAfterComment);
                    Inc(P);
                    FOldSourceColPtr := P;
                  end;
                end;

                Break;
              end;
            end
            else
            begin
              if P^ = #10 then
              begin
                if not FKeepOneBlankLine then // 保持语句间的空行时，块注释中间的换行要忽略，
                  NewLine
                else
                  NewLine(False);             // 但也必须参与换行计数，否则源目标行数对应会错乱

                FOldSourceColPtr := P;
                Inc(FOldSourceColPtr);
              end;
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
        FloatStop := False;
        if FASMMode then
        begin
          Inc(P);
          while P^ in ['0'..'9', 'A'..'F', 'a'..'f', 'H', 'h'] do Inc(P);
          Result := tokAsmHex;
        end
        else
        begin
          Inc(P);
          while P^ in ['0'..'9', '_'] do Inc(P); // D11 新增 _ 代替分节号
          Result := tokInteger;
        end;

        if (P^ = '.') and ((P+1)^ <> '.') then
        begin
          OldP := P;
          Inc(P);
          FloatCount := 0;
          while P^ in ['0'..'9', '_'] do // D11 新增 _ 代替分节号
          begin
            Inc(FloatCount);
            Inc(P);
          end;

          // 有小数点并且小数点后有数字才算 Float
          if FloatCount = 0 then
          begin
            P := OldP;
            FloatStop := True;
          end
          else
            Result := tokFloat;
        end;

        if not FloatStop then // 不是 Float 就不用处理了
        begin
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
      end;
    #10:  // 如果有回车则处理，以 #10 为准
      begin
        Result := tokCRLF;
        if not FASMMode then // FSourceLine Inc-ed at another place
        begin
          NewLine;
          FOldSourceColPtr := P;
          Inc(FOldSourceColPtr);
        end;
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
  FPrevToken := FToken;
  StorePrevEffectiveToken(FToken);
  FToken := Result;

  Inc(FNewSourceCol, FSourcePtr - FOldSourceColPtr);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Line: %5.5d: Col %4.4d. Token: %s. InIgnoreArea %d', [FSourceLine,
//    FSourceCol, TokenString, Integer(InIgnoreArea)]);
{$ENDIF}

  if InIgnoreArea and (FCodeGen <> nil) then
    FCodeGen.WriteBlank(BlankString);

  // FCompDirectiveMode = cdmNone 表示忽略，此处啥都不做，供低级扫描使用。

  if FCompDirectiveMode = cdmAsComment then
  begin
    if Result in [tokBlockComment, tokLineComment, tokCompDirective] then // 当前是 Comment
    begin
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
          begin
            FCodeGen.BackSpaceLastSpaces;
            // 如果当前是保留单个空行模式，且不是语句中，则 BlankStr 开头的空格与回车要省略，避免出现多余的换行
            // 如语句中的判断有误，则可能出现该换行的行注释拼到同一行的情况
            // 行注释回车回车块注释，这种模式下写完行注释并第一个回车后，递归到此处写 BlankStr 第二个回车时，该回车会被误删
            // 因而需要用 FNestedIsComment 变量控制，该变量在碰到注释递归进入时会被设置为 True
            if (FKeepOneBlankLine and not FNestedIsComment and IsStringStartWithSpacesCRLF(BlankStr)
              and GetCanLineBreakFromOut and not IsInStatement)
              or (IsInOpStatement and GetCanLineBreakFromOut) then
            begin
              // 另外，如果当前是语句内保留换行模式，且在开区间的语句内部，尤其是双目运算符后回车，
              // 那么这个回车对应换行后，本次会写入换行与注释，导致多一行，也得删掉

              Idx := Pos(#13#10, BlankStr);
              if Idx > 0 then
                Delete(BlankStr, 1, Idx + 1); // -1 + #13#10 的长度 2
              FCodeGen.WriteBlank(BlankStr);  // 省略前面的空格与回车
            end
            else
              FCodeGen.WriteBlank(BlankStr); // 把上回内容尾巴，到现在注释开头的空白部分写入
          end;
        end;

        S := TokenString;
        // 再写注释本身
        if FASMMode and (Length(S) >= 1) and (S[Length(S)] = #13) then
        begin
          // 注意 ASM 下这个注释可能是 #13 结尾，需要砍掉
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 2) and (S[Length(S) - 1] = #13) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S) - 1, 2);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 1) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else
        begin
          FCodeGen.Write(S);
        end;
        LocalJustWroteBlockComment := True;
      end;

      if not FFirstCommentInBlock then // 第一次碰到 Comment 时设置这个
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      FNestedIsComment := Result in [tokBlockComment, tokLineComment, tokCompDirective];
      Result := NextToken;
      FNestedIsComment := False;

      // 记录这次写了块注释，不记录递归结果
      FJustWroteBlockComment := LocalJustWroteBlockComment;

      // 进入递归寻找下一个 Token，
      // 进入后 FFirstCommentInBlock 为 True，因此不会重新记录 FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else
    begin
      // 只要当前不是 Comment 就设置非第一个 Comment 的标记
      FFirstCommentInBlock := False;
      FJustWroteBlockComment := False;

      if FPreviousIsComment then // 上一个是 Comment，记录这个到 上一个Comment的空行数
      begin
        // 最后一块注释的在递归最外层赋值，因此 FBlankLinesAfter 会被层层覆盖，
        // 代表最后一块注释后的空行数
        FBlankLinesAfter := FBlankLines + FBlankLinesAfterComment;
      end
      else // 上一个不是 Comment，当前也不是 Comment。全清 0
      begin
        FBlankLinesAfter := 0;
        FBlankLinesBefore := 0;
        FBlankLines := 0;
      end;

      if not InIgnoreArea and (FCodeGen <> nil) and
        (FBackwardToken in [tokBlockComment, tokLineComment, tokCompDirective]) then // 当前不是 Comment，但前一个是 Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FPrevToken := FToken;
      StorePrevEffectiveToken(FToken);
      FToken := Result;
      FBackwardToken := FToken;
    end;
  end
  else if FCompDirectiveMode = cdmOnlyFirst then
  begin
    if (Result in [tokBlockComment, tokLineComment]) or ((Result = tokCompDirective) and
      (Pos('{$ELSE', UpperCase(TokenString)) = 0) ) then // NOT $ELSE/$ELSEIF
    begin
      if FInDirectiveNestSearch then // In a Nested search for ENDIF/IFEND
        Exit;

      // 当前是 Comment，或非 ELSE 编译指令，当普通注释处理
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
          begin
            FCodeGen.BackSpaceLastSpaces;
            // 如果当前是保留单个空行模式，且不是语句中，则 BlankStr 开头的空格与回车要省略，避免出现多余的换行
            // 如语句中的判断有误，则可能出现该换行的行注释拼到同一行的情况
            // 行注释回车回车块注释，这种模式下写完行注释并第一个回车后，递归到此处写 BlankStr 第二个回车时，该回车会被误删
            // 因而需要用 FNestedIsComment 变量控制，该变量在碰到注释递归进入时会被设置为 True
            if FKeepOneBlankLine and not FNestedIsComment and IsStringStartWithSpacesCRLF(BlankStr)
              and GetCanLineBreakFromOut and not IsInStatement
              or (IsInOpStatement and GetCanLineBreakFromOut) then
            begin
              // 另外，如果当前是语句内保留换行模式，且在开区间的语句内部，尤其是双目运算符后回车，
              // 那么这个回车对应换行后，本次会写入换行与注释，导致多一行，也得删掉

              Idx := Pos(#13#10, BlankStr);
              if Idx > 0 then
                Delete(BlankStr, 1, Idx + 1); // -1 + #13#10 的长度 2
              FCodeGen.WriteBlank(BlankStr);  // 省略前面的空格与回车
            end
            else
              FCodeGen.WriteBlank(BlankStr);  // 把上回内容尾巴，到现在注释开头的空白部分写入
          end;
        end;

        S := TokenString;
        // 再写注释本身
        if FASMMode and (Length(S) >= 1) and (S[Length(S)] = #13) then
        begin
          // 注意 ASM 下这个注释可能是 #13 结尾，需要砍掉
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 2) and (S[Length(S) - 1] = #13) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S) - 1, 2);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 1) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else
        begin
          FCodeGen.Write(S);
        end;
        LocalJustWroteBlockComment := True;
      end;

      if not FFirstCommentInBlock then // 第一次碰到 Comment 时设置这个
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      FNestedIsComment := Result in [tokBlockComment, tokLineComment, tokCompDirective];
      Result := NextToken;
      FNestedIsComment := False;

      // 记录这次写了块注释，不记录递归结果
      FJustWroteBlockComment := LocalJustWroteBlockComment;

      // 进入递归寻找下一个 Token，
      // 进入后 FFirstCommentInBlock 为 True，因此不会重新记录 FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else if (Result = tokCompDirective) and (Pos('{$ELSE', UpperCase(TokenString)) = 1) then // include ELSEIF
    begin
      // 如果本处是 IF/IFEND 或其他，可以不管，
      // 如果是 ELSEIF，则找对应的 IFEND，并跳过两者之间的
      // 但找的过程中要忽略中间其他配对的 IFDEF/IFNDEF/IFOPT 与 ENDIF 以及同级的 ELSE/ELSEIF

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
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
          begin
            FCodeGen.BackSpaceLastSpaces;
            // 如果当前是保留单个空行模式，且不是语句中，则 BlankStr 开头的空格与回车要省略，避免出现多余的换行
            // 如语句中的判断有误，则可能出现该换行的行注释拼到同一行的情况
            if FKeepOneBlankLine and IsStringStartWithSpacesCRLF(BlankStr) and not IsInStatement then
            begin
              Idx := Pos(#13#10, BlankStr);
              if Idx > 0 then
                Delete(BlankStr, 1, Idx + 1); // -1 + #13#10 的长度 2
              FCodeGen.WriteBlank(BlankStr); // 省略前面的空格与回车
            end
            else
              FCodeGen.WriteBlank(BlankStr); // 把上回内容尾巴，到现在注释开头的空白部分写入
          end;
        end;

        FCodeGen.Write(TokenString); // Write ELSE/ELSEIF itself
        LocalJustWroteBlockComment := True;
      end;

      FInDirectiveNestSearch := True;

      DirectiveNest := 1; // 1 means ELSE/ELSEIF itself
      FPreviousIsComment := True;
      Directive := NextToken;
      FPreviousIsComment := False;
      TmpToken := TokenString;

      // 记录这次写了块注释，不记录递归结果
      FJustWroteBlockComment := LocalJustWroteBlockComment;

      try
        while Directive <> tokEOF do
        begin
          if Assigned(FCodeGen) then
          begin
            if not InIgnoreArea then
            begin
              BlankStr := TrimBlank(BlankString);
              if BlankStr <> '' then
              begin
                FCodeGen.BackSpaceLastSpaces;
                // 如果当前是保留单个空行模式，且不是语句中，则 BlankStr 开头的空格与回车要省略，避免出现多余的换行
                // 如语句中的判断有误，则可能出现该换行的行注释拼到同一行的情况
                if FKeepOneBlankLine and IsStringStartWithSpacesCRLF(BlankStr) and not IsInStatement then
                begin
                  Idx := Pos(#13#10, BlankStr);
                  if Idx > 0 then
                    Delete(BlankStr, 1, Idx + 1); // -1 + #13#10 的长度 2
                  FCodeGen.WriteBlank(BlankStr); // 省略前面的空格与回车
                end
                else
                  FCodeGen.WriteBlank(BlankStr); // 把上回内容尾巴，到现在注释开头的空白部分写入
              end;
            end;

            // 特殊处理，{$ENDIF} 这种末尾的换行不写
            if (Pos('{$ENDIF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFEND', UpperCase(TmpToken)) = 1) then
            begin
              if TmpToken[Length(TmpToken)] = #$A then
                Delete(TmpToken, Length(TmpToken), 1);
              if TmpToken[Length(TmpToken)] = #$D then
                Delete(TmpToken, Length(TmpToken), 1);
            end;

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
        FPrevToken := FToken;
        StorePrevEffectiveToken(FToken);
        FToken := Result;
      finally
        FInDirectiveNestSearch := False;
      end;
    end
    else
    begin
      // 只要当前不是 Comment 就设置非第一个 Comment 的标记
      FFirstCommentInBlock := False;
      FJustWroteBlockComment := False;

      if FPreviousIsComment then // 上一个是 Comment，记录这个到 上一个Comment的空行数
      begin
        // 最后一块注释的在递归最外层赋值，因此 FBlankLinesAfter 会被层层覆盖，
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
        (FBackwardToken in [tokBlockComment, tokLineComment]) then // 当前不是 Comment，但前一个是 Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FPrevToken := FToken;
      StorePrevEffectiveToken(FToken);
      FToken := Result;
      FBackwardToken := FToken;
    end;
  end;
end;

procedure TScanner.OnMoreBlankLinesWhenSkip;
begin
  if FCodeGen <> nil then   // 保留换行以及在忽略区时，这里调整空行的机制不起作用
    if not FCodeGen.KeepLineBreak and not InIgnoreArea then
      FCodeGen.Writeln;
end;

procedure TScanner.StorePrevEffectiveToken(AToken: TPascalToken);
begin
  if not (AToken in NonEffectiveTokens) then
    FPrevEffectiveToken := AToken;
end;

end.
