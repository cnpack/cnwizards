unit x86Reg;
(*
The register tables used by the 80x86 disassembler based upon the XML specification
from http://ref.x86asm.net/.
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
interface

{$IFDEF OpSem}
uses
  SemExpr{,
  SemX86};
{$ENDIF}

const
  MaxRegCount = 16;

type
  TRegTblIndex = (rtNone,rtRQ,rtRD,rtRW,rtRB64,rtRB,rtSeg,rtCR,rtDR,rtTR,rtFP,rtMMX{64-bit},rtXMM{128-bit},rtOther);

  TRegNum = 0..MaxRegCount-1;

  TRegInfo = record
    Name: AnsiString;
    hReg: TRegNum; //The parent register
    Base: Byte; //Bit offset in Reg
  end ;

  TRegTblInfo = record
    Name: AnsiString;
    Size: Byte;
    Cnt: Byte;
    hParent: TRegTblIndex;
    hSibling: TRegTblIndex;
    Reg: array[TRegNum]of TRegInfo;
  end ;

const
  RegTblInfo: array[TRegTblIndex] of TRegTblInfo = (
    (),
    (Name:'RQ'; Size:64; Cnt: 16; Reg: (
      (Name:'RAX'),(Name:'RCX'),(Name:'RDX'),(Name:'RBX'),(Name:'RSP'),(Name:'RBP'),(Name:'RSI'),(Name:'RDI'),
      (Name:'R8'),(Name:'R9'),(Name:'R10'),(Name:'R11'),(Name:'R12'),(Name:'R13'),(Name:'R14'),(Name:'R15'))),
    (Name:'RD'; Size:32; Cnt: 16; hParent: rtRQ; Reg: (
      (Name:'EAX'; hReg:0),(Name:'ECX'; hReg:1),(Name:'EDX'; hReg:2),(Name:'EBX'; hReg:3),
      (Name:'ESP'; hReg:4),(Name:'EBP'; hReg:5),(Name:'ESI'; hReg:6),(Name:'EDI'; hReg:7),
      (Name:'R8d'; hReg:8),(Name:'R9d'; hReg:9),(Name:'R10d'; hReg:10),(Name:'R11d'; hReg:11),
      (Name:'R12d'; hReg:12),(Name:'R13d'; hReg:13),(Name:'R14d'; hReg:14),(Name:'R15d'; hReg:15))),
    (Name:'RW'; Size:16; Cnt: 16; hParent: rtRQ; Reg: (
      (Name:'AX'; hReg:0),(Name:'CX'; hReg:1),(Name:'DX'; hReg:2),(Name:'BX'; hReg:3),
      (Name:'SP'; hReg:4),(Name:'BP'; hReg:5),(Name:'SI'; hReg:6),(Name:'DI'; hReg:7),
      (Name:'R8w'; hReg:8),(Name:'R9w'; hReg:9),(Name:'R10w'; hReg:10),(Name:'R11w'; hReg:11),
      (Name:'R12w'; hReg:12),(Name:'R13w'; hReg:13),(Name:'R14w'; hReg:14),(Name:'R15w'; hReg:15))),
    (Name:'RB64'; Size:8; Cnt: 16; hParent: rtRQ; Reg: (
      (Name:'AL'; hReg:0),(Name:'CL'; hReg:1),(Name:'DL'; hReg:2),(Name:'BL'; hReg:3),
      (Name:'SPL'; hReg:4),(Name:'BPL'; hReg:5),(Name:'SIL'; hReg:6),(Name:'DIL'; hReg:7),
      (Name:'R8b'; hReg:8),(Name:'R9b'; hReg:9),(Name:'R10b'; hReg:10),(Name:'R11b'; hReg:11),
      (Name:'R12b'; hReg:12),(Name:'R13b'; hReg:13),(Name:'R14b'; hReg:14),(Name:'R15b'; hReg:15))),
    (Name:'RB'; Size:8; Cnt: 8; hParent: rtRQ; hSibling: rtRB64; Reg: (
      (Name:'AL'; hReg:0),(Name:'CL'; hReg:1),(Name:'DL'; hReg:2),(Name:'BL'; hReg:3),
      (Name:'AH'; hReg:4; Base:8),(Name:'CH'; hReg:5; Base:8),(Name:'DH'; hReg:6; Base:8),(Name:'BH'; hReg:7; Base:8),
      (),(),(),(),(),(),(),())),
    (Name:'Seg'; Size:16; Cnt: 8; Reg: (
      (Name:'ES'),(Name:'CS'),(Name:'SS'),(Name:'DS'),(Name:'FS'),(Name:'GS'),(),(),
      (),(),(),(),(),(),(),())),
    (Name:'CR'; Size:32; Cnt: 16; Reg: (
      (Name:'CR0'),(),(Name:'CR2'),(Name:'CR3'),(),(),(),(),
      (Name:'CR8'),(),(),(),(),(),(),())),
    (Name:'DR'; Size:32; Cnt: 8; Reg: (
      (Name:'DR0'),(Name:'DR1'),(Name:'DR2'),(Name:'DR3'),(),(),(Name:'DR6'),(Name:'DR7'),
      (),(),(),(),(),(),(),())),
    (Name:'TR'; Size:32; Cnt: 8; Reg: (
      (),(),(),(Name:'TR3'),(Name:'TR4'),(Name:'TR5'),(Name:'TR6'),(Name:'TR7'),
      (),(),(),(),(),(),(),())),
    (Name:'FP'; Size:80; Cnt: 8; Reg: (
      (Name:'ST'),(Name:'ST(1)'),(Name:'ST(2)'),(Name:'ST(3)'),(Name:'ST(4)'),(Name:'ST(5)'),(Name:'ST(6)'),(Name:'ST(7)'),
      (),(),(),(),(),(),(),())),
    (Name:'MMX'; Size:64; Cnt: 8; Reg: (
      (Name:'MM0'),(Name:'MM1'),(Name:'MM2'),(Name:'MM3'),(Name:'MM4'),(Name:'MM5'),(Name:'MM6'),(Name:'MM7'),
      (),(),(),(),(),(),(),())),
    (Name:'XMM'; Size:128; Cnt: 16; Reg: (
      (Name:'XMM0'),(Name:'XMM1'),(Name:'XMM2'),(Name:'XMM3'),(Name:'XMM4'),(Name:'XMM5'),(Name:'XMM6'),(Name:'XMM7'),
      (Name:'XMM8'),(Name:'XMM9'),(Name:'XMM10'),(Name:'XMM11'),(Name:'XMM12'),(Name:'XMM13'),(Name:'XMM14'),(Name:'XMM15'))),
    (Name:'Other'; Size:32; Cnt: 1; Reg: (
      (Name:'rFlags'),(),(),(),(),(),(),(),
      (),(),(),(),(),(),(),()))
  );


const
  hbRQ = Ord(rtRQ)shl 8;
  nbRD = Ord(rtRD)shl 8;
  nbRW = Ord(rtRW)shl 8;
  nbRB64 = Ord(rtRB64)shl 8;
  nbRB = Ord(rtRB)shl 8;
  nbSeg = Ord(rtSeg)shl 8;
  nbXMM = Ord(rtXMM)shl 8;

  nbMask = $FF00;
  nbMaskRegIndex = $FF;

//Results of EncodeRegIndex
  hnRax = hbRQ+0;
  hnRcx = hbRQ+1;
  hnRdx = hbRQ+2;
  hnRbx = hbRQ+3;
  hnRsp = hbRQ+4;
  hnRbp = hbRQ+5;
  hnRsi = hbRQ+6;
  hnRdi = hbRQ+7;
  hnR8  = hbRQ+8;
  hnR9  = hbRQ+9;
  hnR10 = hbRQ+10;
  hnR11 = hbRQ+11;
  hnR12 = hbRQ+12;
  hnR13 = hbRQ+13;
  hnR14 = hbRQ+14;
  hnR15 = hbRQ+15;

  hnEax = nbRD+0;
  hnEcx = nbRD+1;
  hnEdx = nbRD+2;
  hnEbx = nbRD+3;
  hnEsp = nbRD+4;
  hnEbp = nbRD+5;
  hnEsi = nbRD+6;
  hnEdi = nbRD+7;
  hnR8d = nbRD+8;
  hnR9d = nbRD+9;
  hnR10d = nbRD+10;
  hnR11d = nbRD+11;
  hnR12d = nbRD+12;
  hnR13d = nbRD+13;
  hnR14d = nbRD+14;
  hnR15d = nbRD+15;

  hnax = nbRW+0;
  hncx = nbRW+1;
  hndx = nbRW+2;
  hnbx = nbRW+3;
  hnsp = nbRW+4;
  hnbp = nbRW+5;
  hnsi = nbRW+6;
  hndi = nbRW+7;
  hnR8w = nbRW+8;
  hnR9w = nbRW+9;
  hnR10w = nbRW+10;
  hnR11w = nbRW+11;
  hnR12w = nbRW+12;
  hnR13w = nbRW+13;
  hnR14w = nbRW+14;
  hnR15w = nbRW+15;

  hnal = nbRB64+0;
  hncl = nbRB64+1;
  hndl = nbRB64+2;
  hnbl = nbRB64+3;
  hnspl = nbRB64+4;
  hnbpl = nbRB64+5;
  hnsil = nbRB64+6;
  hndil = nbRB64+7;
  hnR8b = nbRB64+8;
  hnR9b = nbRB64+9;
  hnR10b = nbRB64+10;
  hnR11b = nbRB64+11;
  hnR12b = nbRB64+12;
  hnR13b = nbRB64+13;
  hnR14b = nbRB64+14;
  hnR15b = nbRB64+15;

  hnAH = nbRB+4;
  hnCH = nbRB+5;
  hnDH = nbRB+6;
  hnBH = nbRB+7;

type
  TRegIndex = Integer;
  DecodeRegIndex = Byte; //To be used as a function

function EncodeRegIndex(Tbl: TRegTblIndex; hReg: TRegNum): TRegIndex;
function DecodeRegTbl(RegCode: TRegIndex): TRegTblIndex;

function GetRegName0(Tbl: TRegTblIndex; hReg: TRegNum): AnsiString;
function GetRegName(RegCode: TRegIndex): AnsiString;

function GetRegLoPartBySize(hReg: TRegIndex; Sz: Integer): TRegIndex;

{$IFDEF OpSem}
function GetRegisterExpr0(Tbl: TRegTblIndex; hReg: TRegNum): TSemReg;
function GetRegisterExpr(RegCode: TRegIndex): TSemReg;
{$ENDIF}

implementation

function EncodeRegIndex(Tbl: TRegTblIndex; hReg: TRegNum): TRegIndex;
begin
  if (Tbl=rtRB){(RegTblInfo[Tbl].hSibling<>rtNone)}and(hReg<4) then
    Tbl := rtRB64; //Make the encoding unique for AL,etc
  Result := Ord(Tbl)shl 8+hReg;
end ;

function DecodeRegTbl(RegCode: TRegIndex): TRegTblIndex;
begin
  Result := TRegTblIndex(RegCode shr 8);
end ;

function GetRegName0(Tbl: TRegTblIndex; hReg: TRegNum): AnsiString;
begin
  if hReg>=RegTblInfo[Tbl].Cnt then begin
    Result := '';
    Exit;
  end ;
  Result := RegTblInfo[Tbl].Reg[hReg].Name;
end ;

function GetRegName(RegCode: TRegIndex): AnsiString;
begin
  Result := GetRegName0(DecodeRegTbl(RegCode),DecodeRegIndex(RegCode));
end ;

function GetRegLoPartBySize(hReg: TRegIndex; Sz: Integer): TRegIndex;
begin
  case Sz of
   1: Result := nbRB64;
   2: Result := nbRW;
   3,4: Result := nbRD;
   5..8: Result := hbRQ;
  else
    Result := hReg; //Something is wrong - leave unchanged
    Exit;
  end;
  Result := Result + (hReg and nbMaskRegIndex);
end;


{$IFDEF OpSem}
var
  RegTblMem: array[TRegTblIndex] of array[TRegNum]of TSemReg;

function GetRegisterExpr0(Tbl: TRegTblIndex; hReg: TRegNum): TSemReg;
begin
  if hReg>=RegTblInfo[Tbl].Cnt then begin
    Result := Nil;
    Exit;
  end ;
  Result := RegTblMem[Tbl][hReg];
end ;

function GetRegisterExpr(RegCode: TRegIndex): TSemReg;
begin
  Result := GetRegisterExpr0(DecodeRegTbl(RegCode),DecodeRegIndex(RegCode));
end ;

procedure InitRegisters;
var
  rt: TRegTblIndex;
  i: Integer;
  R: TSemReg;
begin
  FillChar(RegTblMem,SizeOf(RegTblMem),0);
  for rt := Succ(Low(TRegTblIndex)) to High(TRegTblIndex) do
   with RegTblInfo[rt] do begin
     for i := 0 to Cnt-1 do begin
       with Reg[i] do begin
         R := Nil;
         if hSibling>rtNone then begin
           R := RegTblMem[hSibling][i]; //Indices of the same register in the sibling tables coincide
           if R.Name<>Name then
             R := Nil;
         end ;
         if R<>Nil then
         else if hParent>rtNone then
           R := TSemRegPart.Create(Name,RegTblMem[hParent][hReg],Base,Size)
         else
           R := TSemReg.Create(Name,Size);
       end ;
       RegTblMem[rt][i] := R;
       R.SetInfiniteLife{AddRef};
     end ;
   end ;
end ;

procedure DoneRegisters;
var
  rt: TRegTblIndex;
  i: Integer;
begin
  for rt := High(TRegTblIndex) downto Succ(Low(TRegTblIndex)) do
    for i := 0 to RegTblInfo[rt].Cnt-1 do
      RegTblMem[rt][i].DeRef;
end ;
{$ENDIF}


{$IFDEF OpSem}
initialization
  InitRegisters;
finalization
  DoneRegisters;
{$ENDIF}
end.
