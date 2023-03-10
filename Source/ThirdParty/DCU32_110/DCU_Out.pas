unit DCU_Out;

interface

(*
  The output module of the DCU32INT utility by Alexei Hmelnov.
  (Pay attention on the SoftNL technique for pretty-printing.)
  ----------------------------------------------------------------------------
  E-Mail: alex@icc.ru
  http://hmelnov.icc.ru/DCU/
  ----------------------------------------------------------------------------

  See the file "readme.txt" for more details.

  ------------------------------------------------------------------------
  IMPORTANT NOTE:
  This software is provided 'as-is', without any expressed or implied warranty.
  In no event will the author be held liable for any damages arising from the
  use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  1. The origin of this software must not be misrepresented, you must not
  claim that you wrote the original software.
  2. Altered source versions must be plainly marked as such, and must not
  be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
  distribution.
*)
uses
  {$IFDEF UNICODE}AnsiStrings, {$ENDIF}SysUtils, FixUp;

type
  TIncPtr = PAnsiChar;
  TDasmMode = (dasmSeq, dasmCtlFlow, dasmDataFlow);
  TOutFmt = (ofmtText, ofmtHTM);

const
  DefaultExt: array [TOutFmt] of String = ('.int', '.htm');

  { Options: }
var
  InterfaceOnly: boolean = false;
  ShowImpNames: boolean = true;
  ShowTypeTbl: boolean = false;
  ShowAddrTbl: boolean = false;
  ShowDataBlock: boolean = false;
  ShowFixupTbl: boolean = false;
  ShowLocVarTbl: boolean = false;
  ShowFileOffsets: boolean = false;
  ShowAuxValues: boolean = false;
  ResolveMethods: boolean = true;
  ResolveConsts: boolean = true;
  FixCommentChars: boolean = true;
  ShowDotTypes: boolean = false;
  ShowSelf: boolean = false;
  ShowVMT: boolean = false;
  ShowHeuristicRefs: boolean = true;
  ShowImpNamesUnits: boolean = false;
  DasmMode: TDasmMode = dasmSeq;
  OutFmt: TOutFmt = ofmtText;

var
  GenVarCAsVars: boolean = false;

var
  NoNamePrefix: AnsiString = '_N%_';
  DotNamePrefix: AnsiString = '_D%_';

procedure SetShowAll;

procedure PutCh(ch: Char);
procedure PutS(const S: AnsiString);
procedure PutSFmt(const Fmt: AnsiString; const Args: array of const);
function ShiftNLOfs(d: Integer): Integer { Old NLOfs };
procedure NL;
procedure NLAux;
procedure SoftNL;
procedure PutSpace;

procedure SetShowAuxValues(V: boolean);
procedure OpenAux;
procedure CloseAux;
function HideAux: Integer; // Aux0
procedure RestoreAux(Aux0: Integer);

procedure RemOpen0;
procedure RemOpen;
procedure RemClose0;
procedure RemClose;
procedure AuxRemOpen;
procedure AuxRemClose;
procedure PutSFmtRem(const Fmt: AnsiString; const Args: array of const);
procedure PutSFmtRemAux(const Fmt: AnsiString; const Args: array of const);

procedure PutKW(const S: AnsiString);
procedure PutKWSp(const S: AnsiString);

procedure PutStrConst(const S: AnsiString);
procedure PutStrConstQ(const S: AnsiString);

procedure PutAddrDefStr(const S: AnsiString; hDef: Integer);
procedure PutMemRefStr(const S: AnsiString; Ofs: Integer);

procedure PutHexOffset(Ofs: LongInt);
procedure PutInt(i: LongInt);
procedure PutHex(i: LongInt);

procedure MarkDefStart(hDef: Integer);
procedure MarkMemOfs(Ofs: Integer);

function CharDumpStr(var V; N: Integer): ShortString;
function DumpStr(var V; N: Integer): AnsiString;

function IntLStr(DP: Pointer; Sz: Cardinal; Neg: boolean): AnsiString;

function CharStr(ch: AnsiChar): AnsiString;
function WCharStr(WCh: WideChar): AnsiString;
function BoolStr(DP: Pointer; DS: Cardinal): AnsiString;
function StrConstStr(CP: PAnsiChar; L: Integer): AnsiString;
function ShowStrConst(DP: Pointer; DS: Cardinal): Integer { Size used };
function ShowUnicodeStrConst(DP: Pointer; DS: Cardinal): Integer { Size used }; // Ver >=verD12
function ShowUnicodeResStrConst(DP: Pointer; DS: Cardinal): Integer { Size used }; // Ver >=verD12
function TryShowPCharConst(DP: PAnsiChar; DS: Cardinal): Integer { Size used };
function FixFloatToStr(const E: Extended): AnsiString;

const
  cSoftNL = #0;
  // cSepCh=#1;
  MaxOutWidth: Cardinal = 75;
  MaxNLOfs: Cardinal = 31 { Should be < Ord(' ') };

type
  TStrInfoRec = packed record
    Ofs: Word;
    Inf: SmallInt;
    DP: Pointer;
  end;

type
  TBaseWriter = class
    protected
      FAuxLevel: Integer;
      FRemLevel: Integer;
      FOutLineNum: Integer;
      FNLOfs: Cardinal;
      BufNLOfs: Cardinal;
      BufLen: Cardinal;
      WasSoftNL: boolean;
      StrInfoCnt: Integer;
      StrInfoOfsLast: Integer;
      Buf: array [0 .. $800 - 1] of AnsiChar;
      StrInfoTbl: array [0 .. $7F] of TStrInfoRec;
      procedure PutStrInfo(Info: Integer; Data: Pointer);
      function GetSoftNLOfs(var ResNLOfs: Cardinal): Integer;
      procedure FlushBufRange(Start, W: Integer);
      procedure FlushStrInfo(Info: Integer; Data: Pointer);
      procedure FillNL(ANLOfs: Cardinal);
      procedure FlushBufPart(W, ANLOfs: Integer);
      function FlushSoftNL(W: Cardinal): boolean;
      procedure BufChars(CP: PAnsiChar; Len: Integer);
    protected
      FInfo: Integer;
      FData: Pointer;
      FStarted: boolean;
      procedure WriteEnd; virtual;
      procedure WriteCP(CP: PAnsiChar; Len: Integer); virtual; abstract;
      procedure NL; virtual; abstract;
      function OpenStrInfo(Info: Integer; Data: Pointer): boolean; virtual;
      procedure CloseStrInfo; virtual;
      procedure MarkDefStart(hDef: Integer); virtual;
      procedure MarkMemOfs(Ofs: Integer); virtual;
      procedure Flush; virtual;
    public
      constructor Create;
      destructor Destroy; override;
      procedure WriteStart; virtual;
      procedure Reset; virtual;
      property OutLineNum: Integer read FOutLineNum;
      property AuxLevel: Integer read FAuxLevel;
      property RemLevel: Integer read FRemLevel;
      property NLOfs: Cardinal read FNLOfs write FNLOfs;
  end;

  TTextFileWriter = class(TBaseWriter)
    protected
      FRes: TextFile;
      procedure WriteCP(CP: PAnsiChar; Len: Integer); override;
      procedure NL; override;
      procedure Flush; override;
    public
      constructor Create(const FNRes: String);
      destructor Destroy; override;
  end;

  THTMWriter = class(TTextFileWriter)
    public
      procedure WriteStart; override;
    protected
      FWasStr: boolean;
      procedure WriteEnd; override;
      procedure WriteCP(CP: PAnsiChar; Len: Integer); override;
      procedure NL; override;
      function OpenStrInfo(Info: Integer; Data: Pointer): boolean; override;
      procedure CloseStrInfo; override;
      procedure MarkDefStart(hDef: Integer); override;
      procedure MarkMemOfs(Ofs: Integer); override;
  end;

  TStringWriter = class(TBaseWriter)
    protected
      FPrev: TBaseWriter;
      FBuf: AnsiString;
      FPos: Integer;
      procedure WriteCP(CP: PAnsiChar; Len: Integer); override;
      procedure NL; override;
    public
      function GetResult: AnsiString;
      procedure Reset; override;
  end;

var
  Writer: TBaseWriter = Nil;

function InitOut(const FNRes: String): TBaseWriter;
// procedure DoneOut;
procedure FlushOut;
procedure ReportExc(const Msg: AnsiString);

function ReplaceWriter(W: TBaseWriter): TBaseWriter;
function SetStringWriter: TStringWriter;
procedure RestorePrevWriter;

const
  siEnd = 0;
  siRem = 1;
  siKeyWord = 2;
  siStrConst = 3;
  siAddrDef = 4;
  siMemRef = 5;
  siMaxRange = 5;
  siDefStart = 6;
  siMemOfs = 7;
  siMax = 8;

procedure ShowDump(DP, DPFile0: TIncPtr; FileSize, SizeDispl, Size: Cardinal;
  Ofs0Displ, Ofs0, WMin: Cardinal; FixCnt: Integer; FixTbl: PFixupTbl;
  FixUpNames, ShowFileOfs: boolean);

implementation

uses
  DCU32 {CurUnit} , DCU_In;

procedure SetShowAll;
  begin
    ShowImpNames := true;
    ShowTypeTbl := true;
    ShowAddrTbl := true;
    ShowDataBlock := true;
    ShowFixupTbl := true;
    ShowLocVarTbl := true;
    ShowFileOffsets := true;
    ShowAuxValues := true;
    ResolveMethods := true;
    ResolveConsts := true;
    FixCommentChars := false;
    ShowDotTypes := true;
    ShowSelf := true;
    ShowVMT := true;
    ShowImpNamesUnits := true;
  end;

{ TBaseWriter. }
constructor TBaseWriter.Create;
  begin
    inherited Create;
    Reset;
  end;

destructor TBaseWriter.Destroy;
  begin
    if FStarted then
        WriteEnd;
    inherited Destroy;
  end;

procedure TBaseWriter.Reset;
  // Restore the initial state of the writer (as if it was just created)
  begin
    FNLOfs := 0;
    BufLen := 0;
    BufNLOfs := FNLOfs;
    FOutLineNum := 0;
    WasSoftNL := false;

    FAuxLevel := 0;
    FRemLevel := 0;
    StrInfoCnt := 0;
    StrInfoOfsLast := 0;
    FInfo := 0;
    FData := Nil;
    FStarted := false;
  end;

procedure TBaseWriter.WriteStart;
  begin
    FStarted := true;
  end;

procedure TBaseWriter.WriteEnd;
  begin
    FStarted := false;
  end;

function TBaseWriter.OpenStrInfo(Info: Integer; Data: Pointer): boolean;
  begin
    if Info <= siMaxRange then begin
        FInfo := Info;
        FData := Data;
        Result := true;
        Exit;
      end;
    Result := false;
    case Info of
      siDefStart: MarkDefStart(Integer(Data));
      siMemOfs: MarkMemOfs(Integer(Data));
    end;
  end;

procedure TBaseWriter.CloseStrInfo;
  begin
    FInfo := 0;
    FData := Nil;
  end;

procedure TBaseWriter.MarkDefStart(hDef: Integer);
  begin
  end;

procedure TBaseWriter.MarkMemOfs(Ofs: Integer);
  begin
  end;

procedure TBaseWriter.Flush;
  begin
  end;

{ ----- }

procedure TBaseWriter.PutStrInfo(Info: Integer; Data: Pointer);
  begin
    if (RemLevel > 0) and (Info <= siMaxRange { Embedded ranges are not allowed } ) then
        Exit;
    if StrInfoCnt > High(StrInfoTbl) then
        Exit;
    with StrInfoTbl[StrInfoCnt] do begin
        Ofs := BufLen - StrInfoOfsLast;
        Inf := Info;
        DP := Data;
      end;
    StrInfoOfsLast := BufLen;
    Inc(StrInfoCnt);
  end;

function TBaseWriter.GetSoftNLOfs(var ResNLOfs: Cardinal): Integer;
  var
    i: Integer;
    MinOfs, Ofs: Integer;
  begin
    MinOfs := Ord(' ');
    Result := BufLen;
    for i := BufLen - 1 downto 0 do begin
        Ofs := Ord(Buf[i]);
        if Ofs < MinOfs then begin
            MinOfs := Ofs;
            Result := i;
          end;
      end;
    if MinOfs < Ord(' ') then
        ResNLOfs := MinOfs
    else
        ResNLOfs := FNLOfs;
  end;

procedure TBaseWriter.FlushBufRange(Start, W: Integer);
  var
    DP: PAnsiChar;
    SaveCh: AnsiChar;
  begin
    if W <= 0 then
        Exit;
    DP := Buf + Start;
    SaveCh := DP[W];
    DP[W] := #0;
    WriteCP(DP, W); // Write(FRes,DP);
    DP[W] := SaveCh;
  end;

procedure TBaseWriter.FlushStrInfo(Info: Integer; Data: Pointer);
  begin
    if Info = 0 then
        CloseStrInfo
    else
        OpenStrInfo(Info, Data);
  end;

procedure TBaseWriter.FillNL(ANLOfs: Cardinal);
  var
    S: array [Byte] of AnsiChar { ShortString };
    W: Integer;
  begin
    W := ANLOfs;
    if W < 0 then
        W := 0
    else if W > MaxNLOfs then
        W := MaxNLOfs;
    { S[0] := Chr(W);
      FillChar(S[1],W,' '); }
    FillChar(S[0], W, ' ');
    S[W] := #0;
    WriteCP(S, W);
  end;

procedure TBaseWriter.FlushBufPart(W, ANLOfs: Integer);
  var
    i, hSI: Integer;
    // S: String;
    SIOfs { ,SIW } : Integer;

    procedure FlushSI(Skip: boolean);
      var
        SIW: Integer;
      begin
        while hSI < StrInfoCnt do begin
            SIW := StrInfoTbl[hSI].Ofs;
            if SIOfs + SIW > W then
                break;
            if not Skip then
                FlushBufRange(SIOfs, SIW);
            Inc(SIOfs, SIW);
            with StrInfoTbl[hSI] do
                FlushStrInfo(Inf, DP);
            Inc(hSI);
          end;
      end;

  begin
    SIOfs := 0;
    hSI := 0;
    if W > 0 then begin
        for i := 0 to W - 1 do
          if Buf[i] < ' ' then
              Buf[i] := ' ';
        FillNL(BufNLOfs);
        // SetString(S,Buf,W);
        // Write(FRes,S);
        FlushSI(false { Skip } );
        if SIOfs < W then
            FlushBufRange(SIOfs, W - SIOfs);
      end;
    NL; // Writeln(FRes);
    Inc(FOutLineNum);
    while (W < BufLen) and (Buf[W] <= ' ') do
        Inc(W);
    FlushSI(true { Skip } );
    if W < BufLen then
        move(Buf[W], Buf, BufLen - W);
    BufLen := BufLen - W;
    BufNLOfs := ANLOfs;
    if hSI >= StrInfoCnt then
        StrInfoCnt := 0
    else begin
        if hSI > 0 then begin
            Dec(StrInfoCnt, hSI);
            move(StrInfoTbl[hSI], StrInfoTbl[0], StrInfoCnt * SizeOf(TStrInfoRec));
          end;
        if StrInfoCnt > 0 then
            Dec(StrInfoTbl[0].Ofs, W - SIOfs);
      end;
    if StrInfoCnt > 0 then
        Dec(StrInfoOfsLast, W)
    else
        StrInfoOfsLast := 0;
  end;

function TBaseWriter.FlushSoftNL(W: Cardinal): boolean;
  var
    Split: Integer;
    ResNLOfs: Cardinal;
  begin
    while ((BufNLOfs + BufLen + W) > MaxOutWidth) and (BufLen > 0) do begin
        Split := GetSoftNLOfs(ResNLOfs);
        { Break only at the soft NL splits: }
        if Split >= BufLen then
            break;
        FlushBufPart(Split, ResNLOfs);
        WasSoftNL := true;
      end;
    Result := (BufNLOfs + BufLen + W) <= MaxOutWidth;
  end;

procedure TBaseWriter.BufChars(CP: PAnsiChar; Len: Integer);
  var
    ch: AnsiChar;
  begin
    // FlushSoftNL(Len);
    While Len > 0 do begin
        if BufLen >= High(Buf) then
            Exit { Just in case };
        ch := CP^;
        Inc(CP);
        Dec(Len);
        if ch < ' ' then begin
            if FNLOfs > MaxNLOfs then
                ch := AnsiChar(MaxNLOfs)
            else
                ch := AnsiChar(FNLOfs);
          end
        else if (RemLevel > 0) and FixCommentChars then begin
            if ch = '{' then
                ch := '('
            else if ch = '}' then
                ch := ')';
          end;
        Buf[BufLen] := ch;
        Inc(BufLen);
        if ch < ' ' then
            FlushSoftNL(0);
      end;
    FlushSoftNL(0);
    // move(S[1],Buf[BufLen],Length(S));
    // Inc(BufLen,Length(S));
    { if FlushSoftNL(Length(S)) then begin
      move(S[1],Buf[BufLen],Length(S));
      Inc(BufLen,Length(S));
      end
      else begin
      FillNL(BufNLOfs);
      Write(FRes,S);
      Writeln(FRes);
      end ; }
  end;

{ TTextFileWriter. }
constructor TTextFileWriter.Create(const FNRes: String);
  begin
    inherited Create;
    AssignFile(FRes, FNRes);
    TTextRec(FRes).Mode := fmClosed;
    Rewrite(FRes); // Test whether the FNRes is a correct file name
  end;

destructor TTextFileWriter.Destroy;
  begin
    if TTextRec(FRes).Mode <> fmClosed then begin
        WriteEnd;
        Close(FRes);
      end;
    inherited Destroy;
  end;

procedure TTextFileWriter.WriteCP(CP: PAnsiChar; Len: Integer);
  begin
    Write(FRes, CP);
  end;

procedure TTextFileWriter.NL;
  begin
    Writeln(FRes);
  end;

procedure TTextFileWriter.Flush;
  begin
    System.Flush(FRes);
  end;

{ THTMWriter. }
procedure THTMWriter.WriteStart;
  begin
    inherited WriteStart;
    Writeln(FRes, '<HTML><HEAD><STYLE TYPE="text/css"> I {color: #008080} ' +
      'EM {color: #008000} A:link, A:visited, A:active {text-decoration: none; color: #800000} ' +
      'A:hover { text-decoration: underline; color: #C08000 }</STYLE></HEAD><BODY><PRE>');
  end;

procedure THTMWriter.WriteEnd;
  begin
    Writeln(FRes, '</PRE></BODY></HTML>');
    inherited WriteEnd;
  end;

procedure THTMWriter.WriteCP(CP: PAnsiChar; Len: Integer);
  const
    sTags: array [1 .. siMaxRange] of String = ('<I>', '<B>', '<EM>', '', '');
  var
    S: String;
  var
    Buf: ShortString;
    i, j: Integer;
    ch: AnsiChar;

    procedure FlushBuf;
      begin
        Buf[0] := AnsiChar(j);
        Write(FRes, Buf);
        j := 0;
      end;

    procedure PutS(C: PAnsiChar);
      begin
        while C^ <> #0 do begin
            Inc(j);
            Buf[j] := C^;
            Inc(C);
          end;
      end;

  begin
    if not FWasStr and (CP^ <> #0) and (FInfo > 0) then begin
        case FInfo of
          siAddrDef: S := Format('<A HREF="#A%d">', [Integer(FData)]);
          siMemRef: S := Format('<A HREF="#M%x">', [Integer(FData)]);
        else
          S := sTags[FInfo];
        end;
        Write(FRes, S);
        FWasStr := true;
      end;
    j := 0;
    for i := 0 to Len - 1 do begin
        ch := CP[i];
        case ch of
          '<': PutS('&lt;');
          '>': PutS('&gt;');
          '&': PutS('&amp;');
          '"': PutS('&quot;');
        else
          Inc(j);
          Buf[j] := ch;
        end;
        if j > 240 then
            FlushBuf;
      end;
    FlushBuf;
    // inherited WriteCP(CP,Len);
  end;

procedure THTMWriter.NL;
  begin
    Writeln(FRes);
  end;

function THTMWriter.OpenStrInfo(Info: Integer; Data: Pointer): boolean;
  begin
    Result := inherited OpenStrInfo(Info, Data);
    if Result then
        FWasStr := false;
  end;

procedure THTMWriter.CloseStrInfo;
  const
    sTags: array [1 .. siMaxRange] of String = ('</I>', '</B>', '</EM>', '</A>', '</A>');
  begin
    if FWasStr and (FInfo > 0) then
        Write(FRes, sTags[FInfo]);
    inherited CloseStrInfo;
    FWasStr := false;
  end;

procedure THTMWriter.MarkDefStart(hDef: Integer);
  begin
    Write(FRes, Format('<A NAME=A%d>', [hDef]));
  end;

procedure THTMWriter.MarkMemOfs(Ofs: Integer);
  begin
    Write(FRes, Format('<A NAME=M%x>', [Ofs]));
  end;

{ TStringWriter. }
procedure TStringWriter.Reset;
  begin
    inherited Reset;
    FPos := 0;
  end;

procedure TStringWriter.WriteCP(CP: PAnsiChar; Len: Integer);
  var
    P: Integer;
  begin
    if Len <= 0 then
        Exit;
    P := FPos + Len;
    if P > Length(FBuf) then begin
        P := P * 2;
        if P < 256 then
            P := 256;
        SetLength(FBuf, P);
      end;
    move(CP^, FBuf[FPos + 1], Len * SizeOf(AnsiChar));
    Inc(FPos, Len);
  end;

procedure TStringWriter.NL;
  begin
    WriteCP(' ', 1); { replace by space }
  end;

function TStringWriter.GetResult: AnsiString;
  begin
    FlushOut; // !!!
    if FPos <= 0 then
        Result := ''
    else
        SetString(Result, PAnsiChar(FBuf), FPos - 1 { Remove last NL } );
  end;

procedure PutStrInfoEnd;
  begin
    Writer.PutStrInfo(0, Nil);
  end;

procedure PutCh(ch: Char);
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    Writer.BufChars(@ch, 1);
  end;

procedure PutS(const S: AnsiString);
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    if S = '' then
        Exit;
    Writer.BufChars(PAnsiChar(S), Length(S));
  end;

procedure PutSFmt(const Fmt: AnsiString; const Args: array of const);
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    PutS({$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format(Fmt, Args));
  end;

procedure FlushOut;
  begin
    Writer.FlushBufPart(Writer.BufLen, Writer.NLOfs);
  end;

procedure ReportExc(const Msg: AnsiString);
  begin
    if Writer = Nil then
        Exit;
    Writer.NL;
    Writer.WriteCP(PAnsiChar(Msg), Length(Msg));
    Writer.NL;
    Writer.Flush;
  end;

function ReplaceWriter(W: TBaseWriter): TBaseWriter;
  begin
    Result := Writer;
    Writer := W;
  end;

var
  StringWriterList: TStringWriter = Nil;

function SetStringWriter: TStringWriter;
  begin
    if StringWriterList = Nil then
        Result := TStringWriter.Create
    else begin
        Result := StringWriterList;
        StringWriterList := TStringWriter(StringWriterList.FPrev);
        Result.Reset;
      end;
    Result.FPrev := ReplaceWriter(Result);
  end;

procedure RestorePrevWriter;
  var
    SW: TStringWriter;
  begin
    if (Writer = Nil) or not(Writer is TStringWriter) then
        raise Exception.Create('Error restoring previous writer');
    SW := TStringWriter(ReplaceWriter(TStringWriter(Writer).FPrev));
    SW.FPrev := StringWriterList;
    StringWriterList := SW;
  end;

procedure FreeStringWriterList;
  var
    SW: TStringWriter;
  begin
    while StringWriterList <> Nil do begin
        SW := StringWriterList;
        StringWriterList := TStringWriter(StringWriterList.FPrev);
        SW.Free;
      end;
  end;

function ShiftNLOfs(d: Integer): Integer { Old NLOfs };
  begin
    Result := Writer.FNLOfs;
    Writer.FNLOfs := Result + d;
  end;

procedure NL;
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    if not Writer.WasSoftNL or (Writer.BufLen > 0) then
        FlushOut
    else
        Writer.BufNLOfs := Writer.NLOfs;
    Writer.WasSoftNL := false;
  end;

procedure NLAux;
  begin
    Inc(Writer.FAuxLevel);
    NL;
    Dec(Writer.FAuxLevel);
  end;

procedure SoftNL;
  begin
    PutCh(cSoftNL);
  end;

function InitOut(const FNRes: String): TBaseWriter;
  begin
    if Writer = Nil then begin
        case OutFmt of
          ofmtHTM: Writer := THTMWriter.Create(FNRes);
        else
          Writer := TTextFileWriter.Create(FNRes);
        end;
        Writer.WriteStart;
      end;
    Result := Writer;
  end;

{
  procedure DoneOut;
  begin
  if Writer<>Nil then begin
  Writer.WriteEnd;
  Writer.Free;
  Writer := Nil;
  end ;
  end ;
}

function CharDumpStr(var V; N: Integer): ShortString;
  var
    C: array [1 .. 255] of AnsiChar absolute V;
    i: Integer;
  begin
    if N > 255 then
        N := 255;
    CharDumpStr[0] := AnsiChar(N);
    for i := 1 to N do
      if C[i] < ' ' then
          CharDumpStr[i] := '.'
      else
          CharDumpStr[i] := C[i];
  end;

function CharNStr(ch: AnsiChar; N: Integer): ShortString;
  begin
    SetLength(Result, N);
    FillChar(Result[1], N, ch);
  end;

type
  TByteChars = packed record
    Ch0, Ch1: AnsiChar end;

    const
      Digit: array [0 .. 15] of AnsiChar = '0123456789ABCDEF';

      function ByteChars(B: Byte): Word;

    var
      ch: TByteChars;
    begin
      ch.Ch0 := Digit[B shr 4];
      ch.Ch1 := Digit[B and $F];
      ByteChars := Word(ch);
    end;

    function DumpStr(var V; N: Integer): AnsiString;

    var
      i: Integer;
      BP: ^Byte;
      P: Pointer;
    begin
      if N <= 0 then begin
          Result := '';
          Exit;
        end;
      SetLength(Result, N * 3 - 1);
      P := @Result[1];
      BP := @V;
      for i := 1 to N do begin
          Word(P^) := ByteChars(BP^);
          Inc(TIncPtr(P), 2);
          AnsiChar(P^) := ' ';
          Inc(TIncPtr(P));
          Inc(TIncPtr(BP));
        end;
      Dec(TIncPtr(P));
      AnsiChar(P^) := #0;
    end;

    const
      OfsFmtS = '%0.0x: %2:s';
      FileOfsFmtS = '%0.0x_%0.0x: %s';

      function GetNumHexDigits(Sz: Cardinal): Cardinal;
      begin
        Result := 0;
        while Sz > 0 do begin
            Inc(Result);
            Sz := Sz shr 4;
          end;
      end;

      procedure SetHexFmtNumDigits(var FmtS: AnsiString; P: Integer; Sz: Cardinal);

    var
      N: Cardinal;
      LCh: AnsiChar;
    begin
      N := GetNumHexDigits(Sz);
      LCh := AnsiChar(Ord('0') + N);
      FmtS[P] := LCh;
      FmtS[P + 2] := LCh;
    end;

    procedure ShowDump(DP, { File 0 address, show file offsets if present }
      DPFile0: TIncPtr; { Dump address }
      FileSize, SizeDispl { used to calculate display offset digits } ,
      Size { Dump size } : Cardinal;
      Ofs0Displ { initial display offset } ,
      Ofs0 { offset in DCU data block - for fixups } ,
      WMin { Minimal dump width (in bytes) } : Cardinal;
      FixCnt: Integer; FixTbl: PFixupTbl;
      FixUpNames, ShowFileOfs: boolean);

    var
      LP: TIncPtr;
      { LS, } W: Cardinal;
      FmtS, DS, FixS, FS, DumpFmt: AnsiString;
      DSP, CP: PAnsiChar;
      { Sz, } LSz, dOfs: Cardinal;
      // Ch: Char;
      // IsBig: boolean;
      FP: PFixupRec;
      K: Byte;
      // N: PName;
    begin
      if Integer(Size) <= 0 then begin
          PutS('[]');
          Exit;
        end;
      if not ShowFileOfs { DPFile0=Nil } then
          FmtS := OfsFmtS
      else begin
          FmtS := FileOfsFmtS;
          SetHexFmtNumDigits(FmtS, 8, FileSize);
        end;
      if SizeDispl = 0 then
          SizeDispl := Size;
      SetHexFmtNumDigits(FmtS, 2, Ofs0Displ + SizeDispl);
      W := 16;
      LP := DP;
      // IsBig := Size>W;
      if Size < W then begin
          W := Size;
          if W < WMin then
              W := WMin;
        end;
      if WMin > 0 then
          DumpFmt := '|%-' + IntToStr(3 * W - 1) + 's|'
      else
          DumpFmt := '|%s|';
      FP := Pointer(FixTbl);
      if FP = Nil then
          FixCnt := 0 { Just in case };
      repeat
        LSz := W;
        if LSz > Size then
            LSz := Size;
        MarkMemOfs(LP - DPFile0);
        PutSFmt(FmtS, [Ofs0Displ + (LP - DP), LP - DPFile0, CharDumpStr(LP^, LSz)]);
        if (LSz < W) { and IsBig } then
            PutS(CharNStr(' ', W - LSz));
        DS := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format(DumpFmt { '|%s|' } , [DumpStr(LP^, LSz)]);
        DSP := PAnsiChar(DS);
        if FixUpNames then
            FixS := '';
        while FixCnt > 0 do begin
            dOfs := FP^.OfsF and FixOfsMask - Ofs0;
            K := TByte4(FP^.OfsF)[3];
            if (dOfs >= LSz) and not((dOfs = LSz) and (K = { CurUnit. } fxEnd { LSz=Size } )) then
                break;
            CP := DSP + dOfs * 3;
            case CP^ of
              '|': CP^ := '[';
              ' ': CP^ := '(';
              '(', '[': CP^ := '{';
            end;
            if FixUpNames then begin
                FS := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('&K%x %s', [K, CurUnit.GetAddrStr(FP^.NDX, true)]);
                if FixS = '' then
                    FixS := FS
                else
                    FixS := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s, %s', [FixS, FS]);
              end;
            Dec(FixCnt);
            Inc(FP);
          end;
        Inc(Ofs0, LSz);
        PutS(DS);
        if FixUpNames then
            PutS(FixS);
        { PutS('|');
          PutS(DumpStr(LP^,LSz));
          if (LSz<W)and IsBig then
          PutS(CharNStr(' ',3*(W-LSz))); }
        Dec(Size, LSz);
        Inc(LP, LSz);
        if Size > 0 then
            NL;
      until Size <= 0;
    end;

    function IntLStr(DP: Pointer; Sz: Cardinal; Neg: boolean): AnsiString;

    var
      i: Integer;
      BP: ^Byte;
      P: Pointer;
      V: Integer;
      Ok: boolean;
    begin
      if Neg then begin
          Ok := true;
          case Sz of
            1: V := ShortInt(DP^);
            2: V := SmallInt(DP^);
            4: V := LongInt(DP^);
          else
            Ok := false;
            if Sz = 8 then begin
                V := LongInt(DP^);
                Inc(TIncPtr(DP), 4);
                NDXHi := LongInt(DP^);
                Result := NDXToStr(V);
                Exit;
              end;
          end;
          if Ok then begin
              // Result := IntToStr(V);
              // !!!Добавить проверку на более простую запись в десятичном виде
              if V >= 0 then
                  Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('$%x', [V])
              else
                  Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('-$%x', [-V]);
              Exit;
            end;
        end;
      Pointer(BP) := TIncPtr(DP) + Sz - 1;
      SetLength(Result, Sz * 2 + 1);
      P := PAnsiChar(Result);
      AnsiChar(P^) := '$';
      Inc(PAnsiChar(P));
      for i := 1 to Sz do begin
          Word(P^) := ByteChars(BP^);
          Inc(PAnsiChar(P), 2);
          Dec(TIncPtr(BP));
        end;
    end;

    function CharStr(ch: AnsiChar): AnsiString;
    begin
      if ch < ' ' then
          Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('#%d', [Byte(ch)])
      else begin
          Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('''%s''{#$%x}', [ch, Byte(ch)])
          // Result := Format('''*''{#$%x}',[Byte(Ch)]);
          // Result[2] := Ch; //Format works wrong with Ch when Unicode strings are on
        end;
    end;

    function WCharStr(WCh: WideChar): AnsiString;

    var
      WStr: array [0 .. 1] of WideChar;
      S: AnsiString;
      ch: AnsiChar;
    begin
      if Word(WCh) < $100 then
          ch := AnsiChar(WCh)
      else begin
          WStr[0] := WCh;
          Word(WStr[1]) := 0;
          S := WideCharToString(WStr);
          if Length(S) > 0 then
              ch := S[1]
          else
              ch := '.';
        end;
      if ch < ' ' then
          Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('#%d', [Word(WCh)])
      else
          Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('''%s''{#$%x}', [ch, Word(WCh)])
    end;

    function BoolStr(DP: Pointer; DS: Cardinal): AnsiString;

    var
      CP: PAnsiChar;
    begin
      CP := PAnsiChar(DP) + DS - 1;
      while (CP > PAnsiChar(DP)) and (CP^ = #0) do
          Dec(CP);
      if (CP = PAnsiChar(DP)) then begin
          if CP^ = #0 then begin
              Result := 'false';
              Exit;
            end;
          if CP^ = #1 then begin
              Result := 'true';
              Exit;
            end;
        end;
      Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('true{%s}', [IntLStr(DP, DS, false)]);
    end;

    function StrConstStr(CP: PAnsiChar; L: Integer): AnsiString;

    var
      WasCode, Code: boolean;
      ch: AnsiChar;
      LRes: Integer;

      procedure PutCh(ch: AnsiChar);
      begin
        Inc(LRes);
        Result[LRes] := ch;
      end;

      procedure PutStr(const S: AnsiString);
      begin
        move(S[1], Result[LRes + 1], Length(S));
        Inc(LRes, Length(S));
      end;

      procedure PutQuote;
      begin
        PutCh('''');
      end;

      begin
        SetLength(Result, 3 * L + 2);
        LRes := 0;
        Code := true;
        while L > 0 do begin
            ch := CP^;
            Inc(CP);
            Dec(L);
            WasCode := Code;
            Code := ch < ' ';
            if WasCode <> Code then
                PutQuote;
            if Code then
                PutStr(CharStr(ch))
            else begin
                if ch = '''' then
                    PutQuote;
                PutCh(ch);
              end;
          end;
        if not Code then
            PutQuote;
        if LRes = 0 then
            Result := ''''''
        else
            SetLength(Result, LRes);
      end;

      function ShowStrConst(DP: Pointer; DS: Cardinal): Integer { Size used };

    var
      L: Integer;
      VP: Pointer;
    begin
      Result := -1;
      if DS < 9 { Min size } then
          Exit;
      if Integer(DP^) <> -1 then
          Exit { Reference count,-1 => ~infinity };
      VP := TIncPtr(DP) + SizeOf(Integer);
      L := Integer(VP^);
      if (DS - 9 < L) or (L < 0) then
          Exit;
      Inc(TIncPtr(VP), SizeOf(Integer));
      if (PAnsiChar(VP) + L)^ <> #0 then
          Exit;
      Result := L + 9;
      PutStrConst(StrConstStr(VP, L));
    end;

    function ShowUnicodeStrConst(DP: Pointer; DS: Cardinal): Integer { Size used };

    // The unicode string support for ver>=verD12
    // New string header:
    // -12:2 - Code page
    // -10:2 - string item size
    // -8:4 - reference count
    // -4:4 - Length in terms of the string item size
    var
      ElSz: Integer;
      VP: Pointer;
    begin
      Result := -1;
      if DS < 13 { Min size } then
          Exit;
      VP := TIncPtr(DP) + SizeOf(Word);
      ElSz := Word(VP^);
      if ElSz = SizeOf(AnsiChar) then begin // Try to show it as an AnsiString (!!!the code page is ignored by now)
          Result := ShowStrConst(TIncPtr(DP) + 2 * SizeOf(Word), DS - 2 * SizeOf(Word));
          if Result > 0 then
              Inc(Result, 2 * SizeOf(Word));
          Exit;
        end;
      if ElSz <> SizeOf(WideChar) then
          Exit;
      VP := TIncPtr(DP) + SizeOf(Integer);
      if Integer(VP^) <> -1 then
          Exit { Reference count,-1 => ~infinity };
      Inc(TIncPtr(VP), SizeOf(Integer));
      Result := ShowUnicodeResStrConst(VP, DS - 2 * SizeOf(Integer));
      if Result < 0 then
          Exit;
      Inc(Result, 2 * SizeOf(Integer));
    end;

    function ShowUnicodeResStrConst(DP: Pointer; DS: Cardinal): Integer { Size used };

    var
      L: Integer;
      WS: WideString;
      S: AnsiString;
    begin
      Result := -1;
      L := Integer(DP^);
      if (DS - 6 < L * SizeOf(WideChar)) or (L < 0) then
          Exit;
      Inc(TIncPtr(DP), SizeOf(Integer));
      if (PWideChar(DP) + L)^ <> #0 then
          Exit;
      SetString(WS, PWideChar(DP), L);
      S := WS;
      Result := L * SizeOf(WideChar) + 6;
      PutStrConst(StrConstStr(PAnsiChar(S), L));
    end;

    function TryShowPCharConst(DP: PAnsiChar; DS: Cardinal): Integer { Size used };

    { This function should check whether DP points to some valid text
      I know that this algorithm is wrong for multibyte encoding.
      Dear Asian colleagues, Please send me your versions. }
    const
      ValidChars = [#9, #13, #10, ' ' .. #255];

    var
      CP, EP: PAnsiChar;
    begin
      EP := DP + DS;
      Result := -1;
      CP := (DP);
      while (CP < EP) and (CP^ in ValidChars) do
          Inc(CP);
      if (CP >= EP) or (CP^ <> #0) then
          Exit;
      if (DP^ = #$E9) and (CP = DP + 1) then { JMP 0 - got tired of those wrong strings for TRY }
          Exit;
      Result := CP - DP;
      PutS(StrConstStr(DP, Result));
      Inc(Result);
    end;

    {$IFDEF VER100}
    {$DEFINE D3or4}
    {$ENDIF}
    {$IFDEF VER120}
    {$DEFINE D3or4}
    {$ENDIF}
    function FixFloatToStr(const E: Extended): AnsiString;

    type
      TExtBytes = array [0 .. 9] of ShortInt;
    begin
      Result := FloatToStr(E);
      {$IFDEF D3or4}
      if (Result[1] = 'I') and (TExtBytes(E)[9] < 0) then
          Result := '-' + Result;
      {$ENDIF}
    end;

    procedure SetShowAuxValues(V: boolean);
    begin
      if V then
          Writer.FAuxLevel := -MaxInt
      else
          Writer.FAuxLevel := 0;
    end;

    procedure OpenAux;
    begin
      Inc(Writer.FAuxLevel);
    end;

    procedure CloseAux;
    begin
      Dec(Writer.FAuxLevel);
    end;

    function HideAux: Integer; // Aux0
    begin
      Result := Writer.FAuxLevel;
      Writer.FAuxLevel := 0;
    end;

    procedure RestoreAux(Aux0: Integer);
    begin
      Writer.FAuxLevel := Aux0;
    end;

    procedure RemOpen0;
    begin
      if Writer.AuxLevel > 0 then
          Exit;
      if Writer.RemLevel = 0 then
          Writer.PutStrInfo(siRem, Nil);
      Inc(Writer.FRemLevel);
    end;

    procedure RemOpen;

    const
      RemCh: array [boolean] of Char = '{(';
    begin
      if Writer.AuxLevel > 0 then
          Exit;
      if Writer.RemLevel = 0 then
          Writer.PutStrInfo(siRem, Nil);
      PutCh(RemCh[Writer.RemLevel > 0]);
      Inc(Writer.FRemLevel);
    end;

    procedure RemClose0;
    begin
      if Writer.AuxLevel > 0 then
          Exit;
      Dec(Writer.FRemLevel);
      if Writer.RemLevel = 0 then
          PutStrInfoEnd;
    end;

    procedure RemClose;

    const
      RemCh: array [boolean] of Char = '})';
    begin
      if Writer.AuxLevel > 0 then
          Exit;
      Dec(Writer.FRemLevel);
      PutCh(RemCh[Writer.RemLevel > 0]);
      if Writer.RemLevel = 0 then
          PutStrInfoEnd;
    end;

    procedure AuxRemOpen;
    begin
      Inc(Writer.FAuxLevel);
      RemOpen;
    end;

    procedure AuxRemClose;
    begin
      RemClose;
      Dec(Writer.FAuxLevel);
    end;

    procedure PutSFmtRem(const Fmt: AnsiString; const Args: array of const);
    begin
      RemOpen;
      PutSFmt(Fmt, Args);
      RemClose;
    end;

    procedure PutSFmtRemAux(const Fmt: AnsiString; const Args: array of const);
    begin
      Inc(Writer.FAuxLevel);
      PutSFmtRem(Fmt, Args);
      Dec(Writer.FAuxLevel);
    end;

    procedure PutSpace;
    begin
      PutCh(' ');
    end;

    procedure PutKW(const S: AnsiString);
    begin
      Writer.PutStrInfo(siKeyWord, Nil);
      PutS(S);
      PutStrInfoEnd;
    end;

    procedure PutKWSp(const S: AnsiString);
    begin
      PutKW(S);
      PutSpace;
    end;

    procedure PutStrConst(const S: AnsiString);
    begin
      Writer.PutStrInfo(siStrConst, Nil);
      PutS(S);
      PutStrInfoEnd;
    end;

    procedure PutStrConstQ(const S: AnsiString);
    begin
      PutStrConst({$IFDEF UNICODE}AnsiStrings.{$ENDIF}AnsiQuotedStr(S, '''')
        { Format('''%s''',[S]) } );
    end;

    procedure PutAddrDefStr(const S: AnsiString; hDef: Integer);
    begin
      if hDef > 0 then
          Writer.PutStrInfo(siAddrDef, Pointer(hDef));
      PutS(S);
      if hDef > 0 then
          PutStrInfoEnd;
    end;

    procedure PutMemRefStr(const S: AnsiString; Ofs: Integer);
    begin
      if Ofs >= 0 then
          Writer.PutStrInfo(siMemRef, Pointer(Ofs));
      PutS(S);
      if Ofs >= 0 then
          PutStrInfoEnd;
    end;

    procedure PutHexOffset(Ofs: LongInt);
    begin
      if Ofs = 0 then
          Exit;
      if Ofs > 0 then
          PutS('+')
      else begin
          PutS('-');
          Ofs := -Ofs;
        end;
      PutSFmt('$%x', [Ofs]);
    end;

    procedure PutInt(i: LongInt);
    begin
      PutS(IntToStr(i));
    end;

    procedure PutHex(i: LongInt);
    begin
      PutS(IntToHex(i, 1));
    end;

    procedure MarkDefStart(hDef: Integer);
    begin
      if hDef < 0 then
          Exit;
      if Writer.AuxLevel > 0 then
          Exit;
      Writer.PutStrInfo(siDefStart, Pointer(hDef));
    end;

    procedure MarkMemOfs(Ofs: Integer);
    begin
      if Ofs < 0 then
          Exit;
      if Writer.AuxLevel > 0 then
          Exit;
      Writer.PutStrInfo(siMemOfs, Pointer(Ofs));
    end;

initialization

finalization

FreeStringWriterList;

end.
