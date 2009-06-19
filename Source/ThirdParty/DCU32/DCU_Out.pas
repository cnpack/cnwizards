unit DCU_Out;

{$WARNINGS OFF}
{$HINTS OFF}

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
  SysUtils, FixUp;

type
  TDasmMode = (dasmSeq,dasmCtlFlow);

{ Options: }
var
  InterfaceOnly: boolean=false;
  ShowImpNames: boolean=true;
  ShowTypeTbl: boolean=false;
  ShowAddrTbl: boolean=false;
  ShowDataBlock: boolean=false;
  ShowFixupTbl: boolean=false;
  ShowLocVarTbl: boolean=false;
  ShowFileOffsets: boolean=false;
  ShowAuxValues: boolean=false;
  ResolveMethods: boolean=true;
  ResolveConsts: boolean=true;
  ShowDotTypes: boolean=false;
  ShowVMT: boolean=false;
  ShowImpNamesUnits: boolean=false;
  DasmMode: TDasmMode = dasmSeq;

var
  AuxLevel: integer=0;

var
  GenVarCAsVars: boolean = false;

var
  NoNamePrefix: String = '_N%_';
  DotNamePrefix: String = '_D%_';

procedure SetShowAll;

procedure PutS(S: String);
procedure PutSFmt(Fmt: String; Args: array of const);
procedure NL;
procedure SoftNL;
procedure InitOut;
procedure FlushOut;

function CharDumpStr(var V;N : integer): ShortString;
function DumpStr(var V;N : integer): String;

function IntLStr(DP: Pointer; Sz: Cardinal; Neg: boolean): String;

function CharStr(Ch: Char): String;
function WCharStr(WCh: WideChar): String;
function BoolStr(DP: Pointer; DS: Cardinal): String;
function StrConstStr(CP: PChar; L: integer): String;

const
  cSoftNL=#0;
  MaxOutWidth: Cardinal = 75;
  MaxNLOfs: Cardinal = 31 {Should be < Ord(' ')};

var
  NLOfs: cardinal;
  OutLineNum: integer = 0 {Read only};
  FRes: TextFile;

procedure ShowDump(DP,DPFile0: PChar; FileSize,SizeDispl,Size: Cardinal;
  Ofs0Displ,Ofs0,WMin: Cardinal; FixCnt: integer; FixTbl: PFixupTbl;
  FixUpNames: boolean);

implementation

uses
  DCU32{CurUnit}, DCU_In;

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
  ShowDotTypes := true;
  ShowVMT := true;
  ShowImpNamesUnits := true;
end ;

var
  BufNLOfs: Cardinal;
  BufLen: cardinal;
  Buf: array[0..$800-1] of Char;

procedure FillNL(NLOfs: Cardinal);
var
  S: ShortString;
  W: integer;
begin
  W := NLOfs;
  if W<0 then
    W := 0
  else if W>MaxNLOfs then
    W := MaxNLOfs;
  S[0] := AnsiChar(Chr(W));
  FillChar(S[1],W,' ');
  Write(FRes,S);
end ;

function GetSoftNLOfs(var ResNLOfs: Cardinal): integer;
var
  i,iMin: integer;
  MinOfs,Ofs: integer;
begin
  MinOfs := Ord(' ');
  Result := BufLen;
  for i:=BufLen-1 downto 0 do begin
    Ofs := Ord(Buf[i]);
    if Ofs<MinOfs then begin
      MinOfs := Ofs;
      Result := i;
    end ;
  end ;
  if MinOfs<Ord(' ') then
    ResNLOfs := MinOfs
  else
    ResNLOfs := NLOfs;
end ;

procedure FlushBufPart(W,NLOfs: integer);
var
  i: integer;
//  S: String;
  SaveCh: Char;
begin
  if W>0 then begin
    for i:=0 to W-1 do
     if Buf[i]<' ' then
       Buf[i] := ' ';
    FillNL(BufNLOfs);
//    SetString(S,Buf,W);
//    Write(FRes,S);
    SaveCh := Buf[W];
    Buf[W] := #0;
    Write(FRes,Buf);
    Buf[W] := SaveCh;
  end ;
  Writeln(FRes);
  Inc(OutLineNum);
  while (W<BufLen)and(Buf[W]<=' ') do
    Inc(W);
  if W<BufLen then
    move(Buf[W],Buf,BufLen-W);
  BufLen := BufLen-W;
  BufNLOfs := NLOfs;
end ;

function FlushSoftNL(W: Cardinal): boolean;
var
  Split: integer;
  ResNLOfs: Cardinal;
begin
  Result := false;
  while ((BufNLOfs+BufLen+W)>MaxOutWidth)and(BufLen>0) do begin
    Split := GetSoftNLOfs(ResNLOfs);
   {Break only at the soft NL splits: }
    if Split>=BufLen then
      Break;
    FlushBufPart(Split,ResNLOfs);
  end ;
  Result := (BufNLOfs+BufLen+W)<= MaxOutWidth;
end ;

procedure BufChars(CP: PChar; Len: integer);
var
  i: integer;
  ch: Char;
begin
//  FlushSoftNL(Len);
  While Len>0 do begin
    if BufLen>=High(Buf) then
      Exit {Just in case};
    ch := CP^;
    Inc(CP);
    Dec(Len);
    if ch<' ' then begin
      if NLOfs>MaxNLOfs then
        Ch := Chr(MaxNLOfs)
      else
        Ch := Chr(NLOfs);
    end ;
    Buf[BufLen] := Ch;
    Inc(BufLen);
    if (ch<' ') then
      FlushSoftNL(0);
  end ;
  FlushSoftNL(0);
//  move(S[1],Buf[BufLen],Length(S));
//  Inc(BufLen,Length(S));
{  if FlushSoftNL(Length(S)) then begin
    move(S[1],Buf[BufLen],Length(S));
    Inc(BufLen,Length(S));
   end
  else begin
    FillNL(BufNLOfs);
    Write(FRes,S);
    Writeln(FRes);
  end ;}
end ;

procedure PutS(S: String);
begin
  if AuxLevel>0 then
    Exit;
  if S='' then
    Exit;
  BufChars(PChar(S),Length(S));
end ;

procedure PutSFmt(Fmt: String; Args: array of const);
begin
  if AuxLevel>0 then
    Exit;
  PutS(Format(Fmt,Args));
end ;

procedure FlushOut;
begin
  FlushBufPart(BufLen,NLOfs);
end ;

procedure NL;
begin
  if AuxLevel>0 then
    Exit;
  FlushOut;
end ;

procedure SoftNL;
var
  Ch: Char;
begin
  if AuxLevel>0 then
    Exit;
  Ch := cSoftNL;
  BufChars(@Ch,1);
end ;

procedure InitOut;
begin
  NLOfs := 0;
  BufLen := 0;
  BufNLOfs := NLOfs;
  OutLineNum := 0;
end ;

function CharDumpStr(var V;N : integer): ShortString;
var
  C : array[1..255]of AnsiChar absolute V;
  i : integer ;
  S: ShortString;
  Ch: Char;
  TstAbs: byte absolute S;
begin
  if N>255 then
    N := 255;
  CharDumpStr[0] := AnsiChar(Chr(N));
  for i := 1 to N do
    if C[i] < ' ' then
      CharDumpStr[i] := '.'
    else
      CharDumpStr[i] := C[i] ;
end ;

function CharNStr(Ch: Char;N : integer): ShortString;
begin
  SetLength(Result,N);
  FillChar(Result[1],N,Ch);
end ;

type
  TByteChars = packed record Ch0,Ch1: AnsiChar end;

const
  Digit : array[0..15] of AnsiChar = AnsiString('0123456789ABCDEF');

function ByteChars(B: Byte): Word;
var
  Ch: TByteChars;
begin
  Ch.Ch0 := Digit[B shr 4];
  Ch.Ch1 := Digit[B and $f];
  ByteChars := Word(Ch);
end ;

function DumpStr(var V;N : integer): String;
var
  i : integer ;
  BP: ^Byte;
  P: Pointer;
begin
  SetLength(Result,N*3-1);
  P := @Result[1];
  BP := @V;
  for i := 1 to N do begin
    Word(P^) := ByteChars(BP^);
    Inc(Cardinal(P),2);
    Char(P^) := ' ';
    Inc(Cardinal(P));
    Inc(Cardinal(BP));
  end ;
  Dec(Cardinal(P));
  Char(P^) := #0;
end ;

const
  OfsFmtS='%0.0x: %2:s';
  FileOfsFmtS='%0.0x_%0.0x: %s';

function GetNumHexDigits(Sz: Cardinal): Cardinal;
begin
  Result := 0;
  while Sz>0 do begin
    Inc(Result);
    Sz := Sz shr 4;
  end ;
end ;

procedure SetHexFmtNumDigits(var FmtS: String; p: integer; Sz: Cardinal);
var
  N: Cardinal;
  LCh: Char;
begin
  N := GetNumHexDigits(Sz);
  LCh := Chr(Ord('0')+N);
  FmtS[p] := LCh;
  FmtS[p+2] := LCh;
end ;

procedure ShowDump(DP, {File 0 address, show file offsets if present}
  DPFile0: PChar; {Dump address}
  FileSize,SizeDispl {used to calculate display offset digits},
  Size {Dump size}: Cardinal;
  Ofs0Displ {initial display offset},
  Ofs0 {offset in DCU data block - for fixups},
  WMin{Minimal dump width (in bytes)}: Cardinal;
  FixCnt: integer; FixTbl: PFixupTbl;
  FixUpNames: boolean);
var
  LP: PChar;
  LS,W: Cardinal;
  FmtS,DS,FixS,FS,DumpFmt: String;
  DSP,CP: PChar;
  Sz,LSz,dOfs: Cardinal;
  Ch: Char;
//  IsBig: boolean;
  FP: PFixupRec;
  K: Byte;
  N: PName;
begin
  if integer(Size)<=0 then begin
    PutS('[]');
    Exit;
  end ;
  if DPFile0=Nil then
    FmtS := OfsFmtS
  else begin
    FmtS := FileOfsFmtS;
    SetHexFmtNumDigits(FmtS,8,FileSize);
  end ;
  if SizeDispl=0 then
    SizeDispl := Size;
  SetHexFmtNumDigits(FmtS,2,Ofs0Displ+SizeDispl);
  W := 16;
  LP := DP;
//  IsBig := Size>W;
  if Size<W then begin
    W := Size;
    if W<WMin then
      W := WMin;
  end ;
  if WMin>0 then
    DumpFmt := '|%-'+IntToStr(3*W-1)+'s|'
  else
    DumpFmt := '|%s|';
  FP := Pointer(FixTbl);
  if FP=Nil then
    FixCnt := 0 {Just in case};
  repeat
    LSz := W;
    if LSz>Size then
      LSz := Size;
    PutSFmt(FmtS,[Ofs0Displ+(LP-DP),LP-DPFile0,CharDumpStr(LP^,LSz)]);
    if (LSz<W){and IsBig} then
      PutS(CharNStr(' ',W-LSz));
    DS := Format(DumpFmt{'|%s|'},[DumpStr(LP^,LSz)]);
    DSP := PChar(DS);
    if FixUpNames then
      FixS := '';
    while FixCnt>0 do begin
      dOfs := FP^.OfsF and FixOfsMask-Ofs0;
      K := TByte4(FP^.OfsF)[3];
      if (dOfs>=LSz)and not((dOfs=LSz)and(K={CurUnit.}fxEnd{LSz=Size})) then
        Break;
      CP := DSP+dOfs*3;
      case CP^ of
        '|': CP^ := '[';
        ' ': CP^ := '(';
        '(','[': CP^ := '{';
      end ;
      if FixUpNames then begin
        FS := Format('K%x %s',[K,CurUnit.GetAddrStr(FP^.NDX,true)]);
        if FixS='' then
          FixS := FS
        else
          FixS := Format('%s, %s',[FixS,FS]);
      end ;
      Dec(FixCnt);
      Inc(FP);
    end ;
    Inc(Ofs0,LSz);
    PutS(DS);
    if FixUpNames then
      PutS(FixS);
    {PutS('|');
    PutS(DumpStr(LP^,LSz));
    if (LSz<W)and IsBig then
      PutS(CharNStr(' ',3*(W-LSz)));}
    Dec(Size,LSz);
    Inc(LP,LSz);
    if Size>0 then
      NL;
  until Size<=0;
end ;

function IntLStr(DP: Pointer; Sz: Cardinal; Neg: boolean): String;
var
  i : integer;
  BP: ^Byte;
  P: Pointer;
  V: integer;
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
      if Sz=8 then begin
        V := LongInt(DP^);
        Inc(PChar(DP),4);
        NDXHi := LongInt(DP^);
        Result := NDXToStr(V);
        Exit;
      end ;
    end ;
    if Ok then begin
      //Result := IntToStr(V);
      if V>=0 then
        Result := Format('$%x',[V])
      else
        Result := Format('-$%x',[-V]);
      Exit;
    end ;
  end ;
  Pointer(BP) := PChar(DP)+Sz-1;
  SetLength(Result,Sz*2+1);
  P := PChar(Result);
  Char(P^) := '$';
  Inc(PChar(P));
  for i := 1 to Sz do begin
    Word(P^) := ByteChars(BP^);
    Inc(PChar(P),2);
    Dec(PChar(BP));
  end ;
end ;

function CharStr(Ch: Char): String;
begin
  if Ch<' ' then
    Result := Format('#%d',[Byte(Ch)])
  else
    Result := Format('''%s''{#$%x}',[Ch,Byte(Ch)])
end ;

function WCharStr(WCh: WideChar): String;
var
  WStr: array[0..1]of WideChar;
  S: String;
  Ch: Char;
begin
  if Word(WCh)<$100 then
    Ch := Char(WCh)
  else begin
    WStr[0] := WCh;
    Word(WStr[1]) := 0;
    S := WideCharToString(WStr);
    if Length(S)>0 then
      Ch := S[1]
    else
      Ch := '.';
  end ;
  if Ch<' ' then
    Result := Format('#%d',[Word(WCh)])
  else
    Result := Format('''%s''{#$%x}',[Ch,Word(WCh)])
end ;

function BoolStr(DP: Pointer; DS: Cardinal): String;
var
  S: String;
  CP: PChar;
  All0: boolean;
begin
  CP := PChar(DP)+DS-1;
  while (CP>PChar(DP))and(CP^=#0)do
    Dec(CP);
  if (CP=PChar(DP)) then begin
    if CP^=#0 then begin
      Result := 'false';
      Exit;
    end ;
    if CP^=#1 then begin
      Result := 'true';
      Exit;
    end ;
  end ;
  Result := Format('true{%s}',[IntLStr(DP,DS,false)]);
end ;

function StrConstStr(CP: PChar; L: integer): String;
var
  WasCode,Code: boolean;
  ch: Char;
  LRes: integer;

  procedure PutCh(ch: Char);
  begin
    Inc(LRes);
    Result[LRes] := ch;
  end ;

  procedure PutStr(S: String);
  begin
    move(S[1],Result[LRes+1],Length(S));
    Inc(LRes,Length(S));
  end ;

  procedure PutQuote;
  begin
    PutCh('''');
  end ;

begin
  SetLength(Result,3*L+2);
  LRes := 0;
  Code := true;
  while L>0 do begin
    ch := CP^;
    Inc(CP);
    Dec(L);
    WasCode := Code;
    Code := ch<' ';
    if WasCode<>Code then
      PutQuote;
    if Code then
      PutStr(CharStr(Ch))
    else begin
      if Ch='''' then
        PutQuote;
      PutCh(Ch);
    end ;
  end ;
  if not Code then
    PutQuote;
  if LRes=0 then
    Result := ''''''
  else
    SetLength(Result,LRes);
end ;

end.
