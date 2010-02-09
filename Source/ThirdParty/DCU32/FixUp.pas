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
  DCU_In;

const {Fixup type constants}
  fxAddr = 1;
  fxJmpAddr = 2;
  fxDataAddr = 3;

  fxStart20 = 3;
  fxEnd20 = 4;
  fxStart30 = 5;
  fxEnd30 = 6;
  fxStart70 = 6;
  fxEnd70 = 7;

  fxStartMSIL = $0B;
  fxEndMSIL = $0C;

  fxStart100 = $0C;
  fxEnd100 = $0D;

var
  fxStart: Byte = fxStart30;
  fxEnd: Byte = fxEnd30;

const
  FixOfsMask = $FFFFFF;

type

TByte4=array[0..3]of Byte;

PFixupRec = ^TFixupRec;
TFixupRec = record
  OfsF: integer;{Low 3 bytes - ofs, high 1 byte - B1}
  Ndx: TNDX;
end ;

PFixupTbl = ^TFixupTbl;
TFixupTbl = array[Word] of TFixupRec;

{Fixup variables and procedures used in the DAsmUtil and DCU32 units}
var
  CodeBase,CodeEnd: PChar;
  CodeStart, FixUpEnd: PChar;
  FixUnit: Pointer{TUnit};

procedure SetCodeRange(ACodeStart,ACodeBase: Pointer; ABlSz: Cardinal);
procedure SetFixupInfo(ACodeFixupCnt: integer; ACodeFixups: PFixupRec;
  AFixUnit: Pointer{TUnit});
procedure ClearFixupInfo;

type
  TFixupState = record
    FixCnt: integer;
    Fix: PFixupRec;
    FixEnd: Pointer;
    FixUnit: Pointer {TUnit};
  end ;

  TFixupMemState = record
    Fx: TFixupState;
    CodeBase,CodeEnd: PChar;
    CodeStart: PChar;
  end ;

procedure SaveFixupState(var S:TFixupState);
procedure RestoreFixupState(const S:TFixupState);

procedure SaveFixupMemState(var S:TFixupMemState);
procedure RestoreFixupMemState(const S:TFixupMemState);

procedure SkipFixups(Ofs: Cardinal);

function ChkNoFixupIn(CodePtr:PChar; Size: Cardinal): boolean;
function GetFixupFor(CodePtr:PChar; Size: Cardinal; StartOk: boolean;
  var Fix: PFixupRec): boolean;

function FixupOk(Fix: PFixupRec): boolean;
function ReportFixup(Fix: PFixupRec; Ofs: LongInt): boolean;

implementation

uses
  DCU_Out, DCU32, DCURecs;

var
  CodeFixupCnt: integer;
  CodeFixups: PFixupRec;

procedure SetCodeRange(ACodeStart,ACodeBase: Pointer; ABlSz: Cardinal);
begin
  ClearFixupInfo;
  CodeStart := ACodeStart;
  CodeBase := ACodeBase;
  CodeEnd := CodeBase+ABlSz;
  FixUpEnd := CodeBase;
end ;

procedure SetFixupInfo(ACodeFixupCnt: integer; ACodeFixups: PFixupRec;
  AFixUnit: Pointer{TUnit});
begin
  CodeFixupCnt := ACodeFixupCnt;
  CodeFixups := ACodeFixups;
  FixUnit := AFixUnit;
end ;

procedure ClearFixupInfo;
begin
  CodeFixupCnt := 0;
  CodeFixups := Nil;
  FixUnit := Nil;
end ;

procedure SaveFixupState(var S:TFixupState);
begin
  S.FixCnt := CodeFixupCnt;
  S.Fix := CodeFixups;
  S.FixEnd := FixUpEnd;
  S.FixUnit := FixUnit;
end ;

procedure RestoreFixupState(const S:TFixupState);
begin
  CodeFixupCnt := S.FixCnt;
  CodeFixups := S.Fix;
  FixUpEnd := S.FixEnd;
  FixUnit := S.FixUnit;
end ;

procedure SaveFixupMemState(var S:TFixupMemState);
begin
  SaveFixupState(S.Fx);
  S.CodeBase := CodeBase;
  S.CodeEnd := CodeEnd;
  S.CodeStart := CodeStart;
end ;

procedure RestoreFixupMemState(const S:TFixupMemState);
begin
  RestoreFixupState(S.Fx);
  CodeBase := S.CodeBase;
  CodeEnd := S.CodeEnd;
  CodeStart := S.CodeStart;
end ;

procedure SetFixEnd;
{Set FixUpEnd to the max(FixUpEnd,CodeFixups^.Ofs+4)
 if CodeFixups^.F is not fxStart or fxEnd}
var
  CurOfs: Cardinal;
  F: Byte;
  EP: PChar;
begin
  CurOfs := CodeFixups^.OfsF;
  F := TByte4(CurOfs)[3];
  CurOfs := CurOfs and FixOfsMask;
  if F<fxStart then begin
    EP := CodeStart+CurOfs+4;
    if EP>FixUpEnd then
      FixUpEnd := EP;
  end ;
end ;

procedure SkipFixups(Ofs: Cardinal);
{Move CodeFixups to the next fixup with Offset>=Ofs}
begin
  while CodeFixupCnt>0 do begin
    if (CodeFixups^.OfsF and FixOfsMask)>= Integer(Ofs) then
      Break;
    SetFixEnd;
    Inc(CodeFixups);
    Dec(CodeFixupCnt);
  end ;
end ;

function CurFixup(Ofs: Cardinal): PFixupRec;
{If CodeFixups^ has the Offset=Ofs return it, else - Nil}
begin
  if (CodeFixupCnt>0)and((CodeFixups^.OfsF and FixOfsMask)= Integer(Ofs)) then
    Result := CodeFixups
  else
    Result := Nil;
end ;

function NextFixup(Ofs: Cardinal): boolean;
{Move CodeFixups to the next fixup, Return true
 if the next fixup has the Offset<=Ofs}
begin
  Result := false;
  if CodeFixupCnt<=0 then
    Exit;
  SetFixEnd;
  Inc(CodeFixups);
  Dec(CodeFixupCnt);
  if CodeFixupCnt<=0 then
    Exit;
  if (CodeFixups^.OfsF and FixOfsMask)> Integer(Ofs) then
    Exit;
  Result := true;
end ;

function ChkNoFixupIn(CodePtr:PChar; Size: Cardinal): boolean;
{Result: false - something wrong, true - Ok}
var
  Ofs: Cardinal;
begin
  Result := false;
  if CodePtr+Size>CodeEnd then
    Exit {Memory block finished};
  Ofs := CodePtr-CodeStart;
  SkipFixups(Ofs+Size);
  if CodePtr<FixUpEnd then
    Exit {Code can't be inside FixUp};
  Result := true;
end ;

function GetFixupFor(CodePtr:PChar; Size: Cardinal; StartOk: boolean;
  var Fix: PFixupRec): boolean;
{Result: false - something wrong, true - Ok, but Fix may be Nil and may be not}
var
  Fx: PFixupRec;
  F: Byte;
  Ofs: Cardinal;
begin
  Result := false;
  Fix := Nil;
  if CodePtr+Size>CodeEnd then
    Exit {Memory block finished};
  Ofs := CodePtr-CodeStart;
  if Size=4 {All fixups are 4 byte} then begin
    SkipFixups(Ofs);
    if CodePtr<FixUpEnd then
      Exit {Can't intersect with some previous FixUp};
    repeat
      Fx := CurFixup(Ofs);
      if Fx=Nil then
        Break;
      F := TByte4(Fx^.OfsF)[3];
      if F<fxStart then begin
        if Fix<>Nil then
          Exit {Paranoic - can't happen, but i trust no one};
       {The difference between fxAddr and fxJmpAddr could also be taken into account}
        Fix := Fx;
       end
      else if not((F=fxStart)and StartOk) then
        Exit {Can't be inside a command};
    until not NextFixup(Ofs);
    FixUpEnd := CodePtr {Dummy - for the next test};
  end ;
  SkipFixups(Ofs+Size);
  if CodePtr<FixUpEnd then
    Exit {Immed data can't intersect [another] FixUp};
  Result := true;
end ;

function FixupOk(Fix: PFixupRec): boolean;
begin
  Result := (Fix<>Nil)and(FixUnit<>Nil);
end ;

function ReportFixup(Fix: PFixupRec; Ofs: LongInt): boolean;
var
  U: TUnit;
  D: TDCURec;
  hDT: integer;
begin
  Result := false;
  if (Fix=Nil)or(FixUnit=Nil) then
    Exit;
  Inc(AuxLevel);
  PutSFmt('K%x ',[TByte4(Fix^.OfsF)[3]]);
  Dec(AuxLevel);
  PutS(TUnit(FixUnit).GetAddrStr(Fix^.NDX,true{ShowNDX}));
  {D := TUnit(FixUnit).GetAddrDef(Fix^.NDX);
  PutS(GetDCURecStr(D,Fix^.NDX,true));}
 // if Ofs<>0 then begin
    D := TUnit(FixUnit).GetGlobalAddrDef(Fix^.NDX,U);
    hDT := -1;
    if D<>Nil then begin
      if D is TVarDecl then
        hDT := TVarDecl(D).hDT;
    end ;
    PutS(U.GetOfsQualifier(hDT,Ofs));
 // end ;
  Result := true;
end ;

end.
