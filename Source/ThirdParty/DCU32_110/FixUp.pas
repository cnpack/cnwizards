unit FixUp;

(*
  The DCU Fixup information module of the DCU32INT utility by Alexei Hmelnov.
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
  DCU_In, SysUtils;

const { Fixup type constants }
  fxAddr = 1;
  fxJmpAddr0 = 2;
  fxDataAddr = 3;
  fxJmpAddrXE = 5;

  fxStart20 = 3;
  fxEnd20 = 4;
  fxStart30 = 5;
  fxEnd30 = 6;
  fxStart70 = 6;
  fxEnd70 = 7;

  fxVirtMethodMSIL = $0A;
  fxStartMSIL = $0B;
  fxEndMSIL = $0C;

  fxStart100 = $0C;
  fxEnd100 = $0D;

  fxMaxXE = $0F;
  fxMax = $17 { $0F }; // Max over all Delphi versions;

  // XE2 64-bit mode
  fxAddr64 = $13;
  fxAddrLo32 = $17;

  fxStart2010 = 0;
  fxEnd2010 = 1;

type
  TFxSizeTbl = array [0 .. fxMax] of SmallInt;

const
  fxSizeXE64: TFxSizeTbl = (
    { 0: } 0, 0, -1, -1, 4, 4, 4, -1, { 8: } 4, -1, -1, -1, -1, -1, 8, -1,
    { 10: } -1, 8, -1 { 4 for 32-bit } , 8, 0, 4, -1, 4);
  fxSizeXE32: TFxSizeTbl = (
    { 0: } 0, 0, -1, -1, 4, 4, 4, -1, { 8: } 4, -1, -1, -1, -1, -1, 8, -1,
    { 10: } -1, -1, 4, -1, -1, -1, -1, -1);

var
  fxStart: Byte = fxStart30;
  fxEnd: Byte = fxEnd30;
  fxJmpAddr: Byte = fxJmpAddr0;
  fxValid: set of 0 .. fxMax = [0 .. fxStart30 - 1];
  fxSize: TFxSizeTbl;
  fx8Byte: Boolean;

const
  FixOfsMask = $FFFFFF;
  FixOfsShift = 24;

type

  TByte4 = array [0 .. 3] of Byte;

  PFixupRec = ^TFixupRec;

  TFixupRec = record
    OfsF: integer; { Low 3 bytes - ofs, high 1 byte - B1 }
    Ndx: TNDX;
  end;

  PFixupTbl = ^TFixupTbl;
  TFixupTbl = array [Word] of TFixupRec;

  { Fixup variables and procedures used in the DAsmUtil and DCU32 units }
var
  CodeBase, CodeEnd, CodeMemBase: TIncPtr;
  CodeStart, FixUpEnd: TIncPtr;
  FixUnit: Pointer { TUnit };

procedure SetCodeRange(ACodeStart, ACodeBase: Pointer; ABlSz: Cardinal);
procedure SetFixupInfo(ACodeFixupCnt: integer; ACodeFixups: PFixupRec;
  AFixUnit: Pointer { TUnit } );
procedure ClearFixupInfo;

type
  TFixupState = record
    FixCnt: integer;
    Fix: PFixupRec;
    FixEnd: Pointer;
    FixUnit: Pointer { TUnit };
  end;

  TFixupMemState = record
    Fx: TFixupState;
    CodeBase, CodeEnd: TIncPtr;
    CodeStart: TIncPtr;
  end;

procedure SaveFixupState(var S: TFixupState);
procedure RestoreFixupState(const S: TFixupState);

procedure SaveFixupMemState(var S: TFixupMemState);
procedure RestoreFixupMemState(const S: TFixupMemState);

procedure SkipFixups(Ofs: Cardinal);

function ChkNoFixupIn(CodePtr: TIncPtr; Size: Cardinal): Boolean;
function GetFixupFor(CodePtr: TIncPtr; Size: Cardinal; StartOk: Boolean;
  var Fix: PFixupRec): Boolean;

function FixupOk(Fix: PFixupRec): Boolean;
function ReportFixup(Fix: PFixupRec; Ofs: LongInt; UseHAl: Boolean): Boolean;

type
  { The code was added for reading .pdata of Win64 }
  TFixUpChkRec = record
    Ofs: Word;
    K: ShortInt;
    Optional: Boolean;
  end;

  PPFixupTbl = ^TPFixupTbl;
  TPFixupTbl = array [Word] of PFixupRec;

  TFixUpReader = object
    protected
      function CheckSize(Sz: ULong): Boolean;
      function SkipData0(Sz: ULong): Boolean;
      function GetFixupAt(iFix: integer; Ofs: ULong; var Fix: PFixupRec): integer { iFix next or -1 };
    public
      DP: TIncPtr;
      DS: Cardinal;
      FixCnt: integer;
      FixTbl: PFixupRec;
      procedure Init(ADP: Pointer; ADS: Cardinal);
      function SkipStartFixup: Boolean;
      function GetULong(Ofs: ULong; var Res: ULong): Boolean;
      function ReadULong(var Res: ULong; var Fix: PFixupRec): Boolean;
      function ReadULongNoFix(var Res: ULong): Boolean;
      function ReadULongFix(var Res: ULong; var Fix: PFixupRec): Boolean;
      function SkipNoFixData(Sz: ULong): Boolean;
      function SkipMayBeFixData(Sz: ULong): Boolean;
      function CheckFixups(Sz: ULong; const Fixups: array of TFixUpChkRec; ResTbl: PPFixupTbl): Boolean;
  end;

implementation

uses
  DCU_Out, DCU32, DCURecs;

var
  CodeFixupCnt: integer;
  CodeFixups: PFixupRec;

procedure SetCodeRange(ACodeStart, ACodeBase: Pointer; ABlSz: Cardinal);
  begin
    ClearFixupInfo;
    CodeStart := ACodeStart;
    CodeBase := ACodeBase;
    CodeEnd := CodeBase + ABlSz;
    FixUpEnd := CodeBase;
  end;

procedure SetFixupInfo(ACodeFixupCnt: integer; ACodeFixups: PFixupRec;
  AFixUnit: Pointer { TUnit } );
  begin
    CodeFixupCnt := ACodeFixupCnt;
    CodeFixups := ACodeFixups;
    FixUnit := AFixUnit;
    FixUpEnd := CodeBase;
  end;

procedure ClearFixupInfo;
  begin
    CodeFixupCnt := 0;
    CodeFixups := Nil;
    FixUnit := Nil;
  end;

procedure SaveFixupState(var S: TFixupState);
  begin
    S.FixCnt := CodeFixupCnt;
    S.Fix := CodeFixups;
    S.FixEnd := FixUpEnd;
    S.FixUnit := FixUnit;
  end;

procedure RestoreFixupState(const S: TFixupState);
  begin
    CodeFixupCnt := S.FixCnt;
    CodeFixups := S.Fix;
    FixUpEnd := S.FixEnd;
    FixUnit := S.FixUnit;
  end;

procedure SaveFixupMemState(var S: TFixupMemState);
  begin
    SaveFixupState(S.Fx);
    S.CodeBase := CodeBase;
    S.CodeEnd := CodeEnd;
    S.CodeStart := CodeStart;
  end;

procedure RestoreFixupMemState(const S: TFixupMemState);
  begin
    RestoreFixupState(S.Fx);
    CodeBase := S.CodeBase;
    CodeEnd := S.CodeEnd;
    CodeStart := S.CodeStart;
  end;

procedure SetFixEnd;
  { Set FixUpEnd to the max(FixUpEnd,CodeFixups^.Ofs+fxSize)
    if CodeFixups^.F is not fxStart or fxEnd }
  var
    CurOfs: Cardinal;
    F: Byte;
    Sz: integer;
    EP: TIncPtr;
  begin
    CurOfs := CodeFixups^.OfsF;
    F := TByte4(CurOfs)[3];
    CurOfs := CurOfs and FixOfsMask;
    if F in fxValid { F<fxStart } then begin
        Sz := fxSize[F];
        if Sz >= 0 then begin
            EP := CodeStart + CurOfs + Sz { 4 };
            if EP > FixUpEnd then
                FixUpEnd := EP;
          end;
      end;
  end;

procedure SkipFixups(Ofs: Cardinal);
  { Move CodeFixups to the next fixup with Offset>=Ofs }
  begin
    while CodeFixupCnt > 0 do begin
        if (CodeFixups^.OfsF and FixOfsMask) >= Ofs then
            Break;
        SetFixEnd;
        Inc(CodeFixups);
        Dec(CodeFixupCnt);
      end;
  end;

function CurFixup(Ofs: Cardinal): PFixupRec;
  { If CodeFixups^ has the Offset=Ofs return it, else - Nil }
  begin
    if (CodeFixupCnt > 0) and ((CodeFixups^.OfsF and FixOfsMask) = Ofs) then
        Result := CodeFixups
    else
        Result := Nil;
  end;

function NextFixup(Ofs: Cardinal): Boolean;
  { Move CodeFixups to the next fixup, Return true
    if the next fixup has the Offset<=Ofs }
  begin
    Result := false;
    if CodeFixupCnt <= 0 then
        Exit;
    SetFixEnd;
    Inc(CodeFixups);
    Dec(CodeFixupCnt);
    if CodeFixupCnt <= 0 then
        Exit;
    if (CodeFixups^.OfsF and FixOfsMask) > Ofs then
        Exit;
    Result := true;
  end;

function ChkNoFixupIn(CodePtr: TIncPtr; Size: Cardinal): Boolean;
  { Result: false - something wrong, true - Ok }
  var
    Ofs: Cardinal;
  begin
    Result := false;
    if CodePtr + Size > CodeEnd then
        Exit { Memory block finished };
    Ofs := CodePtr - CodeStart;
    SkipFixups(Ofs + Size);
    if CodePtr < FixUpEnd then
        Exit { Code can't be inside FixUp };
    Result := true;
  end;

function GetFixupFor(CodePtr: TIncPtr; Size: Cardinal; StartOk: Boolean;
  var Fix: PFixupRec): Boolean;
  { Result: false - something wrong, true - Ok, but Fix may be Nil and may be not }
  var
    Fx: PFixupRec;
    F: Byte;
    Ofs: Cardinal;
  begin
    Result := false;
    Fix := Nil;
    if CodePtr + Size > CodeEnd then
        Exit { Memory block finished };
    Ofs := CodePtr - CodeStart;
    if (Size = 4 { All fixups are 4 byte } ) or fx8Byte and (Size = 8) then begin
        SkipFixups(Ofs);
        if CodePtr < FixUpEnd then
            Exit { Can't intersect with some previous FixUp };
        repeat
          Fx := CurFixup(Ofs);
          if Fx = Nil then
              Break;
          F := TByte4(Fx^.OfsF)[3];
          if F in fxValid { F<fxStart } then begin
              if Fix <> Nil then
                  Exit { Paranoic - can't happen, but i trust no one };
              { The difference between fxAddr and fxJmpAddr could also be taken into account }
              Fix := Fx;
            end
          else if not((F = fxStart) and StartOk) then
              Exit { Can't be inside a command };
        until not NextFixup(Ofs);
        FixUpEnd := CodePtr { Dummy - for the next test };
      end;
    SkipFixups(Ofs + Size);
    if CodePtr < FixUpEnd then
        Exit { Immed data can't intersect [another] FixUp };
    Result := true;
  end;

function FixupOk(Fix: PFixupRec): Boolean;
  begin
    Result := (Fix <> Nil) and (FixUnit <> Nil);
  end;

function ReportFixup(Fix: PFixupRec; Ofs: LongInt; UseHAl: Boolean): Boolean;
  var
    U: TUnit;
    K: Byte;
    D: TDCURec;
    hDT: integer;
    DP: Pointer;
    Sz: Cardinal;
    L: integer;
  var
    TD: TBaseDef { TTypeDef };
    Member: TDCURec;
  begin
    Result := false;
    if (Fix = Nil) or (FixUnit = Nil) then
        Exit;
    // !!!  OpenAux; - temp - debug fixups
    K := TByte4(Fix^.OfsF)[3];
    PutSFmt('&K%x ', [K]);
    // !!!  CloseAux;
    // if Ofs<>0 then begin
    D := TUnit(FixUnit).GetGlobalAddrDef(Fix^.Ndx, U);
    hDT := -1;
    L := -1;
    if D <> Nil then begin
        if D is TVarDecl then
            hDT := TVarDecl(D).hDT
        else if UseHAl and (Ofs > 0 { 0 Ofs usually means just call } ) and (D is TMemBlockRef) then begin
            DP := TUnit(FixUnit).GetBlockMem(TMemBlockRef(D).Ofs, TMemBlockRef(D).Sz, Sz);
            if (DP <> Nil) and (Ofs <= Sz) then begin
                if Ofs >= 8 then
                    L := ShowStrConst(PAnsiChar(DP) + Ofs - 8, Sz - Ofs + 8);
                if L < 0 then
                    L := TryShowPCharConst(PAnsiChar(DP) + Ofs, Sz - Ofs);
              end;
          end;
      end;
    if L > 0 then
        PutS(' {');
    // PutS(TUnit(FixUnit).GetAddrStr(Fix^.NDX,true{ShowNDX}));
    TUnit(FixUnit).PutAddrStr(Fix^.Ndx, true { ShowNDX } );
    { D := TUnit(FixUnit).GetAddrDef(Fix^.NDX);
      PutS(GetDCURecStr(D,Fix^.NDX,true)); }
    if TUnit(FixUnit).IsMSIL and (K = fxVirtMethodMSIL) then begin
        Member := Nil;
        if (D <> Nil) and (D is TTypeDecl) then
            hDT := TTypeDecl(D).hDef;
        TD := Nil;
        if hDT >= 0 then
            TD := U.GetTypeDef(hDT);
        if TD <> Nil then begin
            PutCh('.');
            if (TD <> Nil) and (TD is TRecBaseDef) then begin
                Member := TRecBaseDef(TD).GetMemberByNum(Ofs - 1);
                if Member <> Nil then
                    Member.ShowName;
              end;
          end;
        if Member = Nil then
            PutS('(?field)');
      end
    else
        PutS(U.GetOfsQualifier(hDT, Ofs));
    if L > 0 then
        PutS('}');
    // end ;
    Result := true;
  end;

{ TFixUpReader. }
procedure TFixUpReader.Init(ADP: Pointer; ADS: Cardinal);
  var
    Fix0: integer;
  begin
    DP := ADP;
    DS := ADS;
    FixCnt := CurUnit.GetFixupsFor(ADP, ADS, FixTbl);
  end;

function TFixUpReader.SkipStartFixup: Boolean;
  { Skip the fixup, which marks the start of the procedure or const data }
  begin
    Result := false;
    if FixCnt <= 0 then
        Exit;
    if FixTbl^.OfsF <> DP - CurUnit.DataBlPtr then
        Exit { K=0,Ofs=BlOfs };
    Inc(FixTbl);
    Dec(FixCnt);
    Result := true;
  end;

function TFixUpReader.CheckSize(Sz: ULong): Boolean;
  begin
    Result := Sz <= DS;
    // Use quiet mode, no exceptions  raise Exception.CreateFmt('Error reading extra $%x bytes',[Sz-DS]);
  end;

function TFixUpReader.GetULong(Ofs: ULong; var Res: ULong): Boolean;
  begin
    Result := false;
    if not CheckSize(Ofs + SizeOf(ULong)) then
        Exit;
    Res := PULong(DP + Ofs)^;
    Result := true;
  end;

function TFixUpReader.GetFixupAt(iFix: integer; Ofs: ULong; var Fix: PFixupRec): integer { iFix next or -1 };
  var
    F: PFixupRec;
    FixOfs: ULong;
  begin
    Fix := Nil;
    Result := iFix;
    if FixCnt <= iFix then
        Exit;
    F := FixTbl;
    Inc(F, iFix);
    FixOfs := F^.OfsF and FixOfsMask;
    if FixOfs < Ofs then begin
        Result := -1 { Error };
        Exit;
      end;
    if FixOfs = Ofs then begin
        Fix := F;
        Inc(Result);
      end
    else
        Fix := Nil;
  end;

function TFixUpReader.ReadULong(var Res: ULong; var Fix: PFixupRec): Boolean;
  var
    Ofs, FixOfs: ULong;
  begin
    Result := false;
    if not CheckSize(SizeOf(ULong)) then
        Exit;
    Ofs := DP - CurUnit.DataBlPtr;
    Fix := Nil;
    if FixCnt > 0 then begin
        FixOfs := FixTbl^.OfsF and FixOfsMask;
        if FixOfs < Ofs then
            Exit;
        if FixOfs = Ofs then begin
            Fix := FixTbl;
            Inc(FixTbl);
            Dec(FixCnt);
          end;
      end;
    Res := PULong(DP)^;
    Result := SkipData0(SizeOf(ULong));
  end;

function TFixUpReader.ReadULongNoFix(var Res: ULong): Boolean;
  var
    Fix: PFixupRec;
  begin
    if ReadULong(Res, Fix) then
        Result := Fix = Nil
    else
        Result := false;
  end;

function TFixUpReader.ReadULongFix(var Res: ULong; var Fix: PFixupRec): Boolean;
  begin
    if ReadULong(Res, Fix) then
        Result := Fix <> Nil
    else
        Result := false;
  end;

function TFixUpReader.SkipData0(Sz: ULong): Boolean;
  var
    EndOfs: ULong;
  begin
    Result := true;
    EndOfs := DP - CurUnit.DataBlPtr + Sz;
    if FixCnt <= 0 then
        Exit;
    if FixTbl^.OfsF and FixOfsMask < EndOfs then
        Result := false;
    // raise Exception.CreateFmt('Fixup in data at $%x bytes to the end of block',[DS-Sz]);
    Inc(DP, Sz);
    Dec(DS, Sz);
  end;

function TFixUpReader.SkipNoFixData(Sz: ULong): Boolean;
  begin
    Result := CheckSize(Sz) and SkipData0(Sz);
  end;

function TFixUpReader.SkipMayBeFixData(Sz: ULong): Boolean;
  var
    EndOfs: ULong;
  begin
    Result := false;
    if not CheckSize(Sz) then
        Exit;
    if not SkipData0(Sz) then begin
        EndOfs := DP - CurUnit.DataBlPtr;
        while (FixCnt > 0) and (FixTbl^.OfsF and FixOfsMask < EndOfs) do begin
            Inc(FixTbl);
            Dec(FixCnt);
          end;
      end;
    Result := true;
  end;

function TFixUpReader.CheckFixups(Sz: ULong; const Fixups: array of TFixUpChkRec; ResTbl: PPFixupTbl): Boolean;
  var
    Base: ULong;
    i, iFix: integer;
    Fix: PFixupRec;
    fxKind: integer;
  begin
    Result := false;
    if not CheckSize(Sz) then
        Exit;
    Base := DP - CurUnit.DataBlPtr;
    iFix := 0;
    for i := Low(Fixups) to High(Fixups) do begin
        iFix := GetFixupAt(iFix, Base + Fixups[i].Ofs, Fix);
        if iFix < 0 then
            Exit { Error };
        if Fix <> Nil then begin
            fxKind := Fixups[i].K;
            if (fxKind >= 0) and (fxKind <> Fix^.OfsF shr FixOfsShift) then
                Exit;
          end
        else if not Fixups[i].Optional then
            Exit;
        if ResTbl <> Nil then
            ResTbl^[i] := Fix;
      end;
    Inc(DP, Sz);
    Dec(DS, Sz);
    Inc(FixTbl, iFix);
    Dec(FixCnt, iFix);
    Result := true;
  end;

end.
