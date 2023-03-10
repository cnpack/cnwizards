unit DasmUtil;

(*
  The main i80x86 disassembler module of the DCU32INT utility by Alexei Hmelnov.
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

uses
  DasmDefs, FixUp, {$IFNDEF XMLx86}DasmOpT{$ELSE}x86Reg, x86Dasm{$ENDIF};

function Identic(I: integer): integer;
function ReadByte(var B: integer): boolean;
function SeeNextCodeByte: integer { -1 => Error };
procedure SkipByte; // Call after SeeNextCodeByte only - no checks inside
function UnReadByte: boolean;
{$IFNDEF XMLx86}
procedure SetPrefix(V: integer);
procedure SetSuffix(V: integer);
procedure SetOpName(V: integer);
procedure SetOpPrefix(V: integer);
procedure setEAMod3Tbl(const Tbl: array of TRegIndex);
{$ELSE}
procedure setEAMod3Tbl(Tbl: TRegTblIndex);
{$ENDIF}
procedure SetCmdArg(V: integer);
procedure SetSeg(V: integer);
function GetSeg: integer;
function imPtr: boolean;
// function im(DS: integer): boolean;
function ImmedBW(DS: integer): boolean;
// function imSExt(DS: integer): boolean;
function imInt(DS: integer): boolean;
function jmpOfs(DS: integer): boolean;
function getEA(W: integer; var M, A: integer): boolean;
function getImmOfsEA(W: integer; var A: integer): boolean;
procedure setEASize(DS: integer);
procedure setOS;
procedure setAS;
function GetAS: integer;
function GetOS: integer;
function GetMode: integer;

// 64-bit support
{$IFDEF I64}
// function mode64: integer; replaced by absolute var
procedure setREX(W, V: integer);
function GetOS64: integer;
function wasREX: integer;
function wasRexW: integer;
function addREXBit(V, hPlace: integer): integer;
{$ENDIF}
function ReportImmed(IsInt, SignRq: boolean; DSF, hDSize, SegN, Ofs: Byte;
  Fix: PFixupRec): LongInt;

type
  PBMTblProc = ^TBMTblProc;
  TBMTblProc = array [Byte] of THBMName;

const
  { Command arguments }
  caReg = 1;
  caEffAdr = 2;
  caImmed = 3;
  caVal = 4;
  caJmpOfs = 5;
  caInt = 6;
  caMask = $F;

const
  dsByte = 1;
  dsWord = 2;
  dsDbl = 3;
  dsQWord = 4;
  dsTWord = 5;
  dsPtr = 6;
  dsPtr6b = 7;
  dsMax = 7;
  dsMask = $7;
  dsIPOfs = 8; // for TEffAddr.dOfs only
  dsRIPOfs = 9; // for TEffAddr.dOfs only
  dsToSize: array [0 .. 9] of Cardinal = (0, 1, 2, 4, 8, 10, 4, 6, 4, 4);

const
  hAX = 0;
  hCX = 1;
  hDX = 2;
  hBX = 3;
  hSP = 4;
  hBP = 5;
  hSI = 6;
  hDI = 7;
  hPresent = $80;
  regcSzB = $00;
  regcSzW = $20;
  regcSzD = $40;
  regcSzQ = $60;
  hPresent2b = hPresent + regcSzW;
  hWReg = $10;
  hRegHasRex = $10;
  hRegSizeShift = 5;
  hRegSizeMask = $3;
  dOfsSizeShift = 4 { 5 (4 is enough because all the commands must fit in 15 bytes) };
  dOfsOfsMask = (1 shl dOfsSizeShift) - 1;

const
  hBXF = hBX + hPresent2b;
  hBPF = hBP + hPresent2b;
  hSIF = (hSI + hPresent2b) { shl 4 };
  hDIF = (hDI + hPresent2b) { shl 4 };

const
  RMSL: array [0 .. 7] of Byte = (
    hBXF,
    hBXF,
    hBPF,
    hBPF,
    0,
    0,
    hBPF,
    hBXF
    );
  RMSR: array [0 .. 7] of Byte = (
    hSIF,
    hDIF,
    hSIF,
    hDIF,
    hSIF,
    hDIF,
    0,
    0
    );

const
  hES = 0;
  hCS = 1;
  hSS = 2;
  hDS = 3;
  hFS = 4;
  hGS = 5;

  hNoSeg = 7;
  hDefSeg = 8;

  DefEASeg: array [0 .. 7] of Byte = (
    hDS, hDS, hSS, hSS, hDS, hDS, hDS, hDS);
  DefRegSeg: array [0 .. 7] of Byte = (
    hDS, hDS, hDS, hDS, hSS, hSS, hDS, hDS);

type
  // TRegNum=0..7;
  TRegCode = Byte;
  PEffAddr = ^TEffAddr;

  TEffAddr = object
    // protected required for other modules, which extend DasmUtils
    hSeg: Byte;
    DataSize: Byte; // dsXXX
    // hBase:Byte;{Index4,Base4}
    hBaseOnly: TRegCode; { Base4,HasRex1,dSize2,hPresent1 }
    hIndex: TRegCode; { Index4,HasRex1,dSize2,hPresent1 }
    dOfs: Byte; { OfsSize3,Ofs5 }
    SS: Byte;
    Fix: PFixupRec;
    // public
  end;

  TCmArg = record
    CmdKind: Byte;
    DSize: Byte;
{$IFDEF XMLx86}
    nArg: Byte; // In the list of TOpcodeArg`s
{$ENDIF}
    Inf: integer { Byte };
    Fix: PFixupRec;
  end;

  PCmdInfo = ^TCmdInfo;

  TCmdInfo = record
    PrefSize: Byte;
    hCmd: TCmdIndex;
    EA: TEffAddr;
    Cnt: Byte;
    Arg: array [1 .. 3] of TCmArg;
  end;

var
  OpSeg: Byte;
  Cmd: TCmdInfo;
{$IFNDEF XMLx86}
  CmdPrefix, CmdSuffix: integer;
  PrefixCnt: integer;
  PrefixTbl: array [0 .. 10] of integer;
{$ENDIF}


var
  AdrIs32Deft: boolean = true;
  OpIs32Deft: boolean = true;
  // {$IFDEF XMLx86}
  ShowX86DasmExtraInfo: boolean = false;
  // {$ENDIF}

{$IFDEF I64}


const
  WordSize: array [0 .. 2] of Byte = (2, 4, 8);
  rexfW = $8;
  rexfPresent = $10;

var
  modeI64: boolean = false;
  mode64: Byte absolute modeI64;

var
  CurREX: Byte;
{$ELSE}


const
  WordSize: array [0 .. 1] of Byte = (2, 4);
{$ENDIF}

  // procedure ClearCommand;

function ReadCommand: boolean;

procedure ShowCommand;

{$IFNDEF XMLx86}


var
{$IFDEF I64}
  RegTbl: array [boolean { with REX } ] of array [0 .. 3] of PBMTblProc;
{$ELSE}
  RegTbl: array [0 .. 2] of PBMTblProc;
{$ENDIF}
  SegRegTbl: PBMTblProc;
{$ELSE}


const
  RegTbl: array [boolean { with REX } ] of array [0 .. 3] of TRegTblIndex = ((rtRB, rtRW, rtRD, rtRQ), (rtRB64, rtRW, rtRD, rtRQ));
{$ENDIF}

function GetIntData(hDSize, Ofs: Byte; var I: LongInt): boolean;

implementation

uses
{$IFDEF UNICODE}AnsiStrings{$ELSE}SysUtils{$ENDIF},
{$IFNDEF XMLx86}op{$ELSE}x86Defs, x86Op, TypInfo{$ENDIF}, {DCU_In,} DCU_Out;

var
  AdrIs32: boolean;
  OpIs32: boolean;

{$IFNDEF XMLx86}
  EAMod3TblProc: PBMTblProc;
  EAMod3TblProcCnt: integer;
{$ELSE}
  EAMod3TblProc: TRegTblIndex;
{$ENDIF}


var { For unread }
  fxState0: TFixupState;

procedure ClearCommand;
  begin
    PrevCodePtr := CodePtr;
    fillChar(Cmd, SizeOf(Cmd), 0);
    OpSeg := hDefSeg;
{$IFNDEF XMLx86}
    CmdPrefix := 0;
    CmdSuffix := 0;
    PrefixCnt := 0;
{$ENDIF}
    AdrIs32 := AdrIs32Deft;
    OpIs32 := OpIs32Deft;
{$IFNDEF XMLx86}
    EAMod3TblProc := Nil;
    EAMod3TblProcCnt := 0;
{$ELSE}
    EAMod3TblProc := rtNone;
{$ENDIF}
{$IFDEF I64}
    CurREX := 0;
{$ENDIF}
    SaveFixupState(fxState0);
  end;

(*
  function ReadCodeByte(var B: Byte): boolean;
  { This procedure can use fixup information to prevent parsing commands }
  { which contradict fixups }
  var
  Fx: PFixupRec;
  F: Byte;
  begin
  Result := false;
  if CodePtr>=CodeEnd then
  Exit {Memory block finished};
  SkipFixups(CodePtr-CodeStart);
  if CodePtr<FixUpEnd then
  Exit {Code can't be inside FixUp};
  repeat
  Fx := CurFixup(CodePtr-CodeStart);
  if Fx=Nil then
  Break;
  F := TByte4(Fx^.OfsF)[3];
  if F<fxStart then begin
  SetFixEnd;
  Exit {Code can't be inside FixUp};
  end ;
  if F=fxStart then begin
  if CodePtr>PrevCodePtr then
  Exit {Can't be inside a command};
  end
  else {if F=fxEnd then}
  Exit {Can't be inside a code};
  until not NextFixup(CodePtr-CodeStart);
  B := Byte(CodePtr^);
  Inc(CodePtr);
  Result := true;
  end ;
*)

function ReadCodeByte(var B: Byte): boolean;
  { This procedure can use fixup information to prevent parsing commands }
  { which contradict fixups }
  begin
    Result := ChkNoFixupIn(CodePtr, 1);
    if not Result then
        Exit;
    B := Byte(CodePtr^);
    Inc(CodePtr);
    Result := true;
  end;

function SeeNextCodeByte: integer { -1 => Error };
  { This procedure can use fixup information to prevent parsing commands }
  { which contradict fixups }
  begin
    if not ChkNoFixupIn(CodePtr, 1) then begin
        Result := -1;
        Exit;
      end;
    Result := Byte(CodePtr^);
  end;

procedure SkipByte;
  begin
    Inc(CodePtr);
  end;

function ReadImmedData(Size: Cardinal; var Res: Byte; var Fix: PFixupRec): boolean;
  begin
    Result := GetFixupFor(CodePtr, Size, false, Fix);
    if not Result then
        Exit;
    Res := CodePtr - PrevCodePtr;
    Inc(CodePtr, Size);
  end;

function Identic(I: integer): integer;
  begin
    Result := I;
  end;

function ReadByte(var B: integer): boolean;
  var
    B0: Byte;
  begin
    Result := ReadCodeByte(B0);
    B := B0;
  end;

function UnReadByte: boolean;
  begin
    Result := false;
    if CodePtr <= PrevCodePtr then
        Exit;
    Dec(CodePtr);
    { May be it's not necessary here, but it will be safer to playback fixups: }
    RestoreFixupState(fxState0);
    SkipFixups(CodePtr - CodeStart);
    Result := true;
  end;

{$IFNDEF XMLx86}


procedure SetPrefix(V: integer);
  begin
    CmdPrefix := V;
  end;

procedure SetSuffix(V: integer);
  begin
    CmdSuffix := V;
  end;

procedure SetOpName(V: integer);
  begin
    Cmd.hCmd := V;
  end;

procedure SetOpPrefix(V: integer);
  begin
    PrefixTbl[PrefixCnt] := V;
    Inc(PrefixCnt);
  end;

procedure setEAMod3Tbl(const Tbl: array of TRegIndex);
  begin
    EAMod3TblProc := @Tbl;
    EAMod3TblProcCnt := High(Tbl) + 1;
  end;

{$ELSE XMLx86}


procedure setEAMod3Tbl(Tbl: TRegTblIndex);
  begin
    EAMod3TblProc := Tbl;
  end;
{$ENDIF}


procedure SetCmdArg(V: integer);
  begin
    // Result := false;
    if Cmd.Cnt >= 3 then
        Exit;
    Inc(Cmd.Cnt);
    with Cmd.Arg[Cmd.Cnt] do begin
        DSize := 0;
        if V = hEA then
            CmdKind := caEffAdr
        else
          if (V and {$IFNDEF XMLx86}nf{$ELSE}nbMask{$ENDIF}) <> 0 then begin
              CmdKind := caReg;
              Inf := V and nm;
            end
          else { if (V and $FFFFFF00)=0 then } begin
              CmdKind := caVal;
              Inf := V;
            end
            { else
              Exit };
      end;
  end;

procedure SetSeg(V: integer);
  begin
    OpSeg := V;
  end;

function GetSeg: integer;
  begin
    Result := OpSeg;
  end;

function im(DSize: integer): boolean;
  { const
    SizeTbl: array[1..6] of Cardinal = (
    SizeOf(Byte),
    SizeOf(Word),
    SizeOf(LongInt),
    8,
    10,
    SizeOf(Pointer)
    );
    PtrSize: array[boolean] of integer = (4,6); }
  var
    DSz, Size: Cardinal;
    imOfs: Byte;
  begin
    Result := false;
    if Cmd.Cnt >= 3 then
        Exit;
    DSz := DSize;
    if (DSz = dsPtr) and OpIs32 then
        DSz := dsPtr6b;
    Size := dsToSize[DSz];

    Inc(Cmd.Cnt);
    { if DSize=dsPtr then
      Size := PtrSize[OpIs32]
      else
      Size := SizeTbl[DSize]; }
    with Cmd.Arg[Cmd.Cnt] do begin
        CmdKind := caImmed;
        DSize := DSz;
        if not ReadImmedData(Size, imOfs, Fix) then
            Exit;
        Inf := imOfs;
      end;
    Result := true;
  end;

function imPtr: boolean;
  begin
    Result := im(dsPtr);
  end;

function ImmedBW(DS: integer): boolean;
  const
    BWTbl: array [0 .. 3] of Byte = (dsByte, dsWord, dsDbl, dsQWord);
  begin
    Result := im(BWTbl[DS and 3]);
  end;
(*
  function imSExt(S,W: integer): boolean;
  const
  BWTbl: array[0..1] of Byte = (dsByte,dsWord);
  var
  SExt: Byte;
  begin
  Result := false;
  SExt := S and $1;
  if not im(BWTbl[(W and 1)and not (SExt){При SExt - используется непоср. байт}])
  then
  Exit;
  if SExt<>0 then
  with Cmd.Arg[Cmd.Cnt] do
  Kind := Kind and not caMask or caInt;
  Result := true;
  end ;
*)

function imInt(DS: integer): boolean;
  begin
    Result := ImmedBW(DS);
    if Result then
      with Cmd.Arg[Cmd.Cnt] do begin
          CmdKind := caInt; // DSize is not changed //+(Kind and not caMask);
        end;
  end;

function jmpOfs(DS: integer): boolean;
  begin
    Result := ImmedBW(DS);
    if Result then
      with Cmd.Arg[Cmd.Cnt] do
          CmdKind := caJmpOfs; // DSize is not changed //+(Kind and not caMask);
  end;

function getEA(W: integer; var M, A: integer): boolean;
  var
    CurB, Up2, Lo3, SIB: Byte;
    OpSize: Byte;
    imOfs: Byte;
{$IFNDEF XMLx86}
    TblProc: PBMTblProc;
{$ELSE}
    RegCnt: integer;
    TblProc: TRegTblIndex;
{$ENDIF}
{$IFDEF I64}
  var
    SzF, OfsSzF: Byte;
{$ELSE}
  const
    SzF = regcSzD;
    OfsSzF = dsDbl;
{$ENDIF}
  begin
    Result := false;
    { if W>dsMax then
      W := dsMax;
      OpSize := W; }
    OpSize := (W and 3);
    // Prevents from describing MMX commands
    // if (OpSize>=3){$IFDEF I64}and not modeI64{$ENDIF} then
    // Exit;
    if not ReadCodeByte(CurB) then
        Exit;
    Up2 := CurB shr 6;
    Lo3 := CurB and $7;
    M := (CurB shr 3) and $7;
    if Up2 = 3 then begin
{$IFDEF I64}
        if CurREX > 0 then
            Lo3 := Lo3 or (CurREX and $1) shl 3;
{$ENDIF}
{$IFNDEF XMLx86}
        if EAMod3TblProc <> Nil then begin
            TblProc := EAMod3TblProc;
            if Lo3 >= EAMod3TblProcCnt then
                Lo3 := Lo3 mod EAMod3TblProcCnt; // Just in case
          end
        else
            TblProc := RegTbl{$IFDEF I64}[CurREX > 0]{$ENDIF}[OpSize];
        A := TblProc^[Lo3]
{$ELSE}
        if EAMod3TblProc <> rtNone then
            TblProc := EAMod3TblProc
        else
            TblProc := RegTbl[CurREX > 0][OpSize];
        RegCnt := RegTblInfo[TblProc].Cnt;
        if Lo3 >= RegCnt then
            Lo3 := Lo3 mod RegCnt; // Just in case
        A := EncodeRegIndex(TblProc, Lo3);
{$ENDIF}
      end
    else begin
        A := hEA;
        if {$IFDEF I64}modeI64 or {$ENDIF} AdrIs32 then begin
{$IFDEF I64}
            SzF := regcSzD;
            if modeI64 and AdrIs32 { In fact means 64 bit } then
                SzF := regcSzQ;
{$ENDIF}
            if Lo3 = hSP then begin { SIB }
                if not ReadCodeByte(SIB) then
                    Exit;
                Cmd.EA.SS := SIB shr 6;
                Lo3 := SIB and 7;
                if (Lo3 = hBP) and (Up2 = 0) then begin
                    Up2 := 2;
                    Lo3 := 0;
                    { Base=EBP & mod=0 => Base=None & disp32 }
                  end
                else
                    Inc(Lo3, hPresent);
                SIB := (SIB shr 3) and 7 { Index };
                if SIB <> hSP then
                    SIB := SIB + hPresent
                else
                    SIB := 0;
{$IFDEF I64}
                if CurREX > 0 then begin
                    if Lo3 and hPresent <> 0 then
                        Lo3 := Lo3 or hRegHasRex or (CurREX and $1) shl 3;
                    if SIB and hPresent <> 0 then
                        SIB := SIB or hRegHasRex or (CurREX and $2) shl 2;
                  end;
{$ENDIF}
                { Cmd.EA.hBaseOnly := Lo3+SIB shl 4; }
                Cmd.EA.hBaseOnly := Lo3 or SzF;
                Cmd.EA.hIndex := SIB or SzF;
              end
            else { No SIB } begin
                if (Up2 = 0) and (Lo3 = hBP) then begin
                    Cmd.EA.hBaseOnly := 0;
                    Cmd.EA.hIndex := 0;
                    if not ReadImmedData(SizeOf(LongInt), imOfs, Cmd.EA.Fix) then
                        Exit;
{$IFDEF I64}
                    if modeI64 then { RIP based }
                        OfsSzF := dsIPOfs + Ord(AdrIs32)
                    else
                        OfsSzF := dsDbl;
{$ENDIF}
                    Cmd.EA.dOfs := OfsSzF shl dOfsSizeShift or imOfs;
                    Lo3 := 0; { For OpSeg }
                  end
                else begin
{$IFDEF I64}
                    if CurREX > 0 then
                        Lo3 := Lo3 or hRegHasRex or (CurREX and $1) shl 3;
{$ENDIF}
                    Cmd.EA.hBaseOnly := Lo3 or hPresent or SzF;
                    Cmd.EA.hIndex := 0;
                  end;
              end;
            if OpSeg = hDefSeg then
                OpSeg := hDefSeg or DefRegSeg[Lo3 and 7];
          end
        else { not AdrIs32 } begin
            if (Up2 = 0) and (Lo3 = 6) then begin
                Cmd.EA.hBaseOnly := 0;
                Cmd.EA.hIndex := 0;
                if not ReadImmedData(SizeOf(Word), imOfs, Cmd.EA.Fix) then
                    Exit;
                Cmd.EA.dOfs := dsWord shl dOfsSizeShift or imOfs;
                Lo3 := 0; { For OpSeg }
              end
            else begin
                Cmd.EA.hBaseOnly := RMSL[Lo3];
                Cmd.EA.hIndex := RMSR[Lo3];
              end;
            if OpSeg = hDefSeg then
                OpSeg := hDefSeg or DefEASeg[Lo3 and 7];
          end;
        Case Up2 of
          1: begin
              if not ReadImmedData(SizeOf(Byte), imOfs, Cmd.EA.Fix) then
                  Exit;
              Cmd.EA.dOfs := dsByte shl dOfsSizeShift or imOfs;
            end;
          2: begin
              if not ReadImmedData(WordSize[Ord({$IFDEF I64}modeI64 or {$ENDIF}AdrIs32)], imOfs, Cmd.EA.Fix) then
                  Exit;
              Cmd.EA.dOfs := (dsWord + Ord({$IFDEF I64}modeI64 or {$ENDIF}AdrIs32)) { dsWord } shl dOfsSizeShift or imOfs;
            end;
        End;
        { GetMemStr := GetSegStr+'['+MS+']' ; }
        Cmd.EA.hSeg := OpSeg;
        Cmd.EA.DataSize := W + 1;
      end;
    Result := CodePtr <= CodeEnd;
  end;

function getImmOfsEA(W: integer; var A: integer): boolean;
  var
    OpSize: Byte;
    imOfs: Byte;
  begin
    Result := false;
    OpSize := W and $1;
    if OpSize > 0 then
        OpSize := 1 + Ord(OpIs32);
    A := hEA;
    if not ReadImmedData(WordSize[Ord(AdrIs32)], imOfs, Cmd.EA.Fix) then
        Exit;
    Cmd.EA.dOfs := (dsWord + Ord(AdrIs32)) { dsWord } shl dOfsSizeShift or imOfs;
    if OpSeg = hDefSeg then
        OpSeg := hDefSeg or hDS;
    Cmd.EA.hSeg := OpSeg;
    Cmd.EA.DataSize := OpSize + 1;
    Result := CodePtr <= CodeEnd;
  end;

procedure setEASize(DS: integer);
  var
    S: Byte;
  begin
    S := DS;
    if S >= dsMax then
        Exit;
    Cmd.EA.DataSize := S;
  end;

procedure setOS;
  begin
    OpIs32 := not OpIs32Deft;
  end;

procedure setAS;
  begin
    AdrIs32 := not AdrIs32Deft;
  end;

function GetAS: integer;
  begin
    Result := Ord(AdrIs32);
  end;

function GetOS: integer;
  begin
    Result := Ord(OpIs32);
  end;

function GetMode: integer;
  begin
    Result := Ord(AdrIs32Deft){$IFDEF I64} * (1 + Ord(modeI64)){$ENDIF};
  end;

// 64-bit support
{$IFDEF I64}


procedure setREX(W, V: integer);
  begin
    CurREX := V and $7 + (W and $1) * rexfW + rexfPresent;
  end;

function GetOS64: integer;
  begin
    if CurREX and rexfW <> 0 then
        Result := 2 // 64-bit
    else
        Result := Ord(OpIs32);
  end;

function wasREX: integer;
  begin
    Result := Ord(CurREX <> 0);
  end;

function wasRexW: integer;
  begin
    Result := Ord(CurREX and rexfW <> 0);
  end;

function addREXBit(V, hPlace: integer): integer;
  begin
    V := V and $7; // Paranoic
    hPlace := hPlace and $3; // Paranoic
    if (CurREX <> 0 { was REX } ) and (hPlace > 0 { 0 means Independent of REX } ) and (CurREX and (1 shl (hPlace - 1)) <> 0 { The bit is 1 } ) then
        V := V or $8;
    Result := V;
  end;

{$ENDIF}


function ReadCommand: boolean;
  begin
    ClearCommand;
    Result := ReadOp;
  end;

{$IFNDEF XMLx86}


procedure WriteBMOpName(hN: THBMName);
  begin
    PutKW(GetOpName(hN));
  end;
{$ENDIF}


procedure WriteInt(I: integer);
  begin
    PutSFmt('%d', [I]);
  end;

procedure WriteRegVarInfo(hReg: TRegIndex; Ofs, Size: integer; IsFirst: boolean);
  var
    S: AnsiString;
    hDecl: integer;
    ProcOfs: integer;
  begin
    if not Assigned(GetRegVarInfo) then
        Exit;
    if IsFirst then { i.e. It may be an assignment target }
        ProcOfs := CodePtr - CodeBase
    else
        ProcOfs := PrevCodePtr - CodeBase;
    S := GetRegVarInfo(ProcOfs, hReg, Ofs, Size, hDecl);
    if S <> '' then begin
        PutCh('{');
        PutAddrDefStr(S, hDecl);
        PutCh('}');
      end;
  end;

procedure WriteRegName(hN: TRegIndex);
  begin
    PutKW(GetRegName(hN));
  end;

procedure WriteRegNameInf(hN: TRegIndex; IsFirst: boolean);
  begin
    WriteRegName(hN);
    WriteRegVarInfo(hN, 0 { Ofs } , 0 { Size: auto } , IsFirst);
  end;

function WriteImmed(hDSize, Ofs: Byte; MayBeAddr: boolean; Fix: PFixupRec): LongInt;
  var
    DP, DP1: Pointer;
    DS: Byte;
    { IsAddr: boolean;
      A: Pointer; }
    Fixed: boolean;
  begin
    Result := 0;
    DP := PrevCodePtr + Ofs;
    DS := hDSize and dsMask;
    Case DS of
      dsByte: Result := Byte(DP^);
      dsWord: Result := Word(DP^);
      dsDbl: Result := LongInt(DP^);
    End;
    Fixed := ReportFixUp(Fix, Result, ShowHeuristicRefs);
    {
      //  if (ReportFixUp(Cardinal(DP)-Cardinal(CodeStart),hDSize and dsMask,DP)=0)
      //  then begin
      IsAddr := MayBeAddr and((Ord(AdrIs32Deft)+dsWord)=hDSize);
      if IsAddr then begin
      if hDSize=dsWord then
      LongInt(A) := Word(DP^)
      else
      LongInt(A) := LongInt(DP^);
      //      StartStrInfo(siDataAddr,A);
      end ;
    }
    if Fixed then begin
        if (DS = dsDbl) { and(Result=0) } then
            Exit;
        PutS('{+');
      end;
    Case DS of
      dsByte: PutSFmt('$%2.2x', [Result]);
      dsWord: PutSFmt('$%4.4x', [Result]);
      dsDbl: PutSFmt('$%8.8x', [Result]);
      dsPtr: begin
          Result := LongInt(DP^);
          PutSFmt('$%8.8x', [Result])
        end;
      dsPtr6b: begin
          DP1 := DP;
          Inc(TIncPtr(DP1), 4);
          PutSFmt('$%4.4x:$%8.8x', [Word(DP1^), LongInt(DP^)]);
        end;
      { dsPtr:
        if not OpIs32 then begin
        Result := LongInt(DP^);
        PutSFmt('$%8.8x',[Result])
        end
        else begin
        DP1 := DP;
        Inc(integer(DP1),4);
        PutSFmt('$%4.4x:$%8.8x',[Word(DP1^),LongInt(DP^)]);
        end ; }
      dsQWord: PutS(CharDumpStr(DP^, 8));
      dsTWord: PutS(CharDumpStr(DP^, 10));
    else
      PutS('?Immed');
    End;
    if Fixed then
        PutS('}');
    // if IsAddr then
    // EndStrInfo;
    // end ;
  end;

function WriteIntData(SignRq, FixSignRq, IsJmpOfs: boolean; hDSize, Ofs: Byte; Fix: PFixupRec): LongInt;
  var
    DP: Pointer;
    DS: Byte;
    Fixed: boolean;
  begin
    DP := PrevCodePtr + Ofs;
    DS := hDSize and dsMask;
    Case DS of
      dsByte: Result := ShortInt(DP^);
      dsWord: Result := SmallInt(DP^);
      dsDbl: begin
          Result := LongInt(DP^);
          if IsJmpOfs then // The referenced address is computed from the command end (CodePtr)
              Inc(Result, (CodePtr - TIncPtr(DP)) - SizeOf(LongInt)); // required for IP-relative addressing in 64-bit mode
        end;
    else
      PutS('?Int');
      Result := 0;
      Exit;
    End;
    if SignRq and ((Result > 0) or FixSignRq and FixupOk(Fix)) then
        PutS('+');
    // if (ReportFixUp(Cardinal(DP)-Cardinal(CodeStart),hDSize and dsMask,DP)=0{<>0})
    // then
    Fixed := ReportFixUp(Fix, Result, ShowHeuristicRefs);
    if Fixed then begin
        if (DS = dsDbl) { and(Result=0) } then
            Exit;
      end;
    if SignRq and (Result = 0) then
        Exit;
    if Fixed then
        PutS('{+');
    WriteInt(Result);
    if Fixed then
        PutS('}');
  end;

procedure WriteJmpOfs(hDSize, Ofs: Byte; Fix: PFixupRec);
  var
    dOfs: LongInt;
  begin
    dOfs := WriteIntData(true, false, true { IsJmpOfs } , hDSize, Ofs, Fix);
    if Fix = Nil then begin
        PutS(' (');
        PutMemRefStr(Format('0x%x', [(CodePtr - CodeBase) + dOfs]), CodePtr - CodeMemBase + dOfs);
        PutS(')');
      end;
  end;

function ReportImmed(IsInt, SignRq: boolean; DSF, hDSize, SegN, Ofs: Byte;
  Fix: PFixupRec): LongInt;
  { var
    RepRes: Byte; }
  begin
    { if ReportDataRefsOn then
      RepRes := ReportDataRefs(SignRq,DSF,hDSize,SegN,Ofs)
      else }
    { RepRes := 0;
      if RepRes>1 then
      PutS('{'); }
    if (not IsInt) { or(RepRes>0) } then begin
        if SignRq then
            PutS('+');
        Result := WriteImmed(hDSize, Ofs, { RepRes>0 } false { MayBeAddr } , Fix);
      end
    else
        Result := WriteIntData(SignRq, true, false { IsJmpOfs } , hDSize, Ofs, Fix);
    // if RepRes>1 then
    // PutS('}');
    // ReportImmed := RepRes>1;
  end;

procedure WriteEA;
  var
    SegN, DSF: Byte;
    Cnt, Sz: integer;
    hLastReg: TRegIndex;

    procedure Plus;
      begin
        if Cnt > 0 then
            PutS('+');
        Inc(Cnt);
      end;

    procedure WriteReg(hReg, SS: Byte; ShowVar: boolean);
      const
        ScaleStr: array [0 .. 3] of String[3] = ('', '2*', '4*', '8*');
      var
        iReg: TRegIndex;
      begin
        if hReg and hPresent = 0 then
            Exit;
{$IFNDEF XMLx86}
        iReg := RegTbl{$IFDEF I64}[hReg and hRegHasRex <> 0]{$ENDIF}
          [(hReg shr hRegSizeShift) and hRegSizeMask]^[hReg and $F];
{$ELSE}
          iReg := EncodeRegIndex(RegTbl[hReg and hRegHasRex <> 0][(hReg shr hRegSizeShift) and hRegSizeMask], hReg and $F);
{$ENDIF}
        if SS = 0 then
            hLastReg := iReg;
        Plus;
        if (SS > 0) and (SS <= 3) then
            PutS(ScaleStr[SS]);
        if ShowVar and (SS = 0) then
            WriteRegNameInf(iReg, false { IsFirst } )
        else
            WriteRegName(iReg);
      end;

  var
    hR1, hR2: Byte;
    Fixed, AsExpr: boolean;
    D: LongInt;
  begin
    DSF := Cmd.EA.DataSize;
    Case DSF of
      0:;
      dsByte: PutS('BYTE');
      dsWord: PutS('WORD');
      dsDbl: PutS('DWORD');
      dsPtr: PutS('DWORD');
      dsPtr6b: PutS('FWORD');
      dsQWord: PutS('QWORD');
      dsTWord: PutS('TBYTE');
    else
      PutS('?');
    End;
    if DSF <> 0 then
        PutS(' PTR ')
      { else
        PutS(' ') };
    SegN := Cmd.EA.hSeg;
    if SegN < hDefSeg then begin
{$IFNDEF XMLx86}
        WriteRegName(SegRegTbl^[SegN]);
{$ELSE}
        WriteRegName(nbSeg + SegN);
{$ENDIF}
        PutS(':');
      end;
    Cnt := 0;
    PutS('[');
    Fixed := FixupOk(Cmd.EA.Fix);
    hR1 := Cmd.EA.hBaseOnly;
    hR2 := Cmd.EA.hIndex;
    AsExpr := (not Fixed) and ((hR1 and hPresent <> 0) <> (hR2 and hPresent <> 0)
      and (Cmd.EA.SS = 0));
    WriteReg(hR1, 0, not AsExpr);
    WriteReg(hR2, Cmd.EA.SS, not AsExpr);
    if Cmd.EA.dOfs <> 0 then begin
        Sz := Cmd.EA.dOfs shr dOfsSizeShift;
        if Sz >= dsIPOfs then begin
            PutS('.');
            WriteJmpOfs(dsDbl, Cmd.EA.dOfs and dOfsOfsMask, Cmd.EA.Fix);
            D := 0; // !!!Temp
          end
        else
            D := ReportImmed(Cnt > 0 { IsInt } , Cnt > 0 { SignRq } , DSF, Sz { hDSize } ,
            SegN and $7, Cmd.EA.dOfs and dOfsOfsMask { Ofs } , Cmd.EA.Fix)
      end
    else
        D := 0;
    if AsExpr then
        WriteRegVarInfo(hLastReg, D { Ofs } , dsToSize[DSF] { Size } , false { IsFirst } );
    PutS(']');
  end;

procedure WriteArg(const A: TCmArg; IsDest: boolean);
  begin
    Case A.CmdKind { and caMask } of
      caReg: WriteRegNameInf(A.Inf, IsDest);
      caEffAdr: WriteEA;
      caVal: PutSFmt('$%x', [A.Inf]);
      caImmed: ReportImmed(false, false, 0, A.DSize { A.Kind shr 4 } , hCS, A.Inf, A.Fix);
      { WriteImmed(A.Kind shr 4,A.Inf,false); }
      caJmpOfs: WriteJmpOfs(A.DSize { A.Kind shr 4 } , A.Inf, A.Fix);
      caInt: ReportImmed(true, false, 0, A.DSize { A.Kind shr 4 } , hCS, A.Inf, A.Fix);
      { WriteIntData(false,falseA.Kind shr 4,A.Inf); }
    else
      PutS('?');
    End;
  end;

{$IFDEF XMLx86}


procedure WriteMnem(Mnem: TOpcodeMnem);
  var
    S: String;
  begin
    S := GetEnumName(TypeInfo(TOpcodeMnem), Ord(Mnem));
    System.Delete(S, 1, 3);
    PutKW(S);
  end;

procedure ShowCmdPrefixes(PP: TIncPtr; UsedPfx: integer);
  { !!! valid PrevCodePtr is required }
  var
    EP: POpcodeEntry;
    PE: TIncPtr;
    B: Byte;
    Mnem: TOpcodeMnem;
  begin
    with OpTables[Cmd.hCmd.hEntry and efTwoByte <> 0] do
        EP := @Entries^[Cmd.hCmd.hEntry and efEntryIndex];
    PE := PP + Cmd.PrefSize;
    while PP < PE do begin
        B := Byte(PP^);
        Inc(PP);
        if (UsedPfx and 1 = 0) and (B <> $0F) then begin
            Mnem := GetPrefixMnemonics(EP, B);
            if Mnem <> oc_None then begin
                WriteMnem(Mnem);
                PutSpace;
              end;
          end;
        UsedPfx := UsedPfx shr 1;
      end;
  end;

function WriteCmdName(const Cmd: TCmdInfo; var Entry: POpcodeEntry): POpcodeArgs;
  var
    EP: POpcodeEntry;
    SP: POpcodeSyntax;
  begin
    with OpTables[Cmd.hCmd.hEntry and efTwoByte <> 0] do begin
        EP := @Entries^[Cmd.hCmd.hEntry and efEntryIndex];
        if (EP^.Count <= 0) or (Cmd.hCmd.hSyntax < 0) then begin
            Entry := Nil;
            Result := Nil;
            Exit { Paranoic };
          end;
        SP := @Syntaxes[EP^.Base + Cmd.hCmd.hSyntax];
        WriteMnem(SP^.Mnem);
        Result := @Args^[SP^.Base];
        Entry := EP;
      end;
    // PutKW(GetOpName(hN));
  end;

function ProcFlagsToStr(Flags: TProcessorFlags): String;
  var
    F: TProcessorFlag0;
  begin
    Result := '';
    for F := Low(TProcessorFlag) to High(TProcessorFlag) do begin
        if F in Flags then
            Result := Result + FlagChars[F];
      end;
  end;

type
  TExtraInfo = object
    HasInfo: boolean;
    procedure Init;
    procedure Open0;
    procedure Open;
    procedure Close;
  end;

procedure TExtraInfo.Init;
  begin
    HasInfo := false;
  end;

procedure TExtraInfo.Open0;
  begin
    if HasInfo then
        Exit;
    HasInfo := true;
    RemOpen;
  end;

procedure TExtraInfo.Open;
  begin
    if HasInfo then
        PutSpace
    else
        Open0;
  end;

procedure TExtraInfo.Close;
  begin
    if not HasInfo then
        Exit;
    HasInfo := false;
    RemClose;
  end;

procedure ShowCmdExtraInfo(Entry: POpcodeEntry);
  var
    ExtraInfo: TExtraInfo;

    procedure ShowGrInfo(EnumTI: PTypeInfo; V: integer);
      var
        S: String;
      begin
        if V = 0 { g?_none } then
            Exit;
        ExtraInfo.Open;
        S := GetEnumName(EnumTI, V);
        System.Delete(S, 1, 3);
        PutS(S);
      end;

    procedure ShowProcFlags(const Prefix: String; Flags: TProcessorFlags);
      begin
        if Flags = [] then
            Exit;
        ExtraInfo.Open;
        PutS(Prefix);
        PutS(ProcFlagsToStr(Flags));
      end;

    procedure ShowCoProcFlags(const Prefix: String; Flags: TCoprocessorFlags);
      var
        I: integer;
      begin
        if Flags = 0 then
            Exit;
        ExtraInfo.Open;
        PutS(Prefix);
        for I := 0 to 3 do
          if (1 shl I) and Flags <> 0 then
              PutCh(Chr(Ord('1') + I));
      end;

  begin
    ExtraInfo.Init;
    ShowGrInfo(TypeInfo(TEntryIExt), Ord(Entry^.iExt));
    ShowGrInfo(TypeInfo(TEntryGrp1), Ord(Entry^.grp1));
    ShowGrInfo(TypeInfo(TEntryGrp2), Ord(Entry^.grp2));
    ShowGrInfo(TypeInfo(TEntryGrp3), Ord(Entry^.grp3));
    ShowProcFlags('test:', Entry^.TestF);
    ShowProcFlags('def:', Entry^.DefF);
    ShowProcFlags('0=', Entry^.Vals0F);
    ShowProcFlags('1=', Entry^.Vals1F);
    // ShowProcFlags('modif:',Entry^.ModifF); in fact ModifF=DefF+UndefF
    ShowProcFlags('undef:', Entry^.UndefF);
    ShowCoProcFlags('def:', Entry^.CDefF);
    ShowCoProcFlags('0=', Entry^.CVals0F);
    ShowCoProcFlags('undef:', Entry^.CUndefF);
    ExtraInfo.Close;
  end;

procedure ShowArgExtraInfo(const Arg: TOpcodeArg);
  const
    ArgFlagName: array [TArgFlagBit] of String = ('<-', '~', '*');
  var
    Flags: TArgFlags;
    F: TArgFlagBit;
    ExtraInfo: TExtraInfo;
  begin
    if Arg.Flags * [Low(TArgFlagBit) .. High(TArgFlagBit)] = [] then
        Exit;
    ExtraInfo.Init;
    Flags := Arg.Flags;
    if afDst in Flags then begin
        ExtraInfo.Open0;
        if afNoDepend in Flags then begin
            Exclude(Flags, afNoDepend);
            PutS('<-');
          end
        else
            PutS('<=');
      end;
    for F := Succ(Low(TArgFlagBit)) to High(TArgFlagBit) do
      if F in Flags then begin
          ExtraInfo.Open0;
          PutS(ArgFlagName[F]);
        end;
    ExtraInfo.Close;
  end;
{$ENDIF}


procedure ShowCommand;
  var
    I: integer;
    OpName: String[10];
    SeprChar: AnsiChar;
{$IFDEF XMLx86}
    Entry: POpcodeEntry;
    Args: POpcodeArgs;
{$ENDIF}
  begin
{$IFNDEF XMLx86}
    // ReportCommandMem;
    for I := 0 to PrefixCnt - 1 do begin
        WriteBMOpName(PrefixTbl[I]);
        PutCh(' ');
      end;
    OpName := GetOpName(Cmd.hCmd);
    SeprChar := ' ';
    if OpName[Length(OpName)] = '_' then
        Dec(Byte(OpName[0]))
    else begin
        if CmdSuffix = 0 then begin
            Inc(Byte(OpName[0]));
            OpName[Length(OpName)] := ' ';
          end;
        SeprChar := ',';
      end;
    if CmdPrefix <> 0 then
        WriteBMOpName(CmdPrefix);
    PutKW(OpName);
    if CmdSuffix <> 0 then begin
        WriteBMOpName(CmdSuffix);
        PutS(' ');
      end;
{$ELSE}
    SeprChar := ',';
    if Cmd.PrefSize > 0 then
        ShowCmdPrefixes(PrevCodePtr, Cmd.hCmd.FPrefix);
    Args := WriteCmdName(Cmd, Entry);
    if ShowX86DasmExtraInfo then
        ShowCmdExtraInfo(Entry);
    PutSpace;
{$ENDIF}
    for I := 1 to Cmd.Cnt do begin
        if I > 1 then begin
            PutS(SeprChar);
            SeprChar := ',';
          end;
        WriteArg(Cmd.Arg[I], {$IFNDEF XMLx86}I = 1{$ELSE}afDst in Args^[Cmd.Arg[I].nArg].Flags{$ENDIF}{ IsFirst } );
{$IFDEF XMLx86}
        if ShowX86DasmExtraInfo then
            ShowArgExtraInfo(Args^[Cmd.Arg[I].nArg]);
{$ENDIF}
      end;
  end;

function GetIntData(hDSize, Ofs: Byte; var I: LongInt): boolean;
  var
    DP: Pointer;
  begin
    DP := PrevCodePtr;
    Inc(TIncPtr(DP), Ofs);
    Case hDSize and dsMask of
      dsByte: I := ShortInt(DP^);
      dsWord: I := SmallInt(DP^);
      dsDbl: I := LongInt(DP^);
    else
      GetIntData := false;
      Exit;
    End;
    GetIntData := true;
  end;

end.
