unit Win64SEH;
(*
The structured exception handling data structures module of
the DCU32INT utility by Alexei Hmelnov.
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
  SysUtils, FixUp, DCU_In, DCU_Out;

const
  UnwindVerMask = $7;
  //UNW_FLAG_NHANDLER=0;
  UNW_FLAG_EHANDLER=1*8;
  UNW_FLAG_UHANDLER=2*8;
  //UNW_FLAG_FHANDLER=3; // inofficial
  UNW_FLAG_CHAININFO=4*8;

//UNWIND_OP_CODES
  UWOP_PUSH_NONVOL = 0;     // info == register number
  UWOP_ALLOC_LARGE = 1;     // no info, alloc size in next 2 slots
  UWOP_ALLOC_SMALL = 2;     // info == size of allocation / 8 - 1
  UWOP_SET_FPREG   = 3;     // no info, FP = RSP + UNWIND_INFO.FPRegOffset*16
  UWOP_SAVE_NONVOL = 4;     // info == register number, offset in next slot
  UWOP_SAVE_NONVOL_FAR = 5; // info == register number, offset in next 2 slots
  UWOP_SAVE_XMM128 = 6;     // info == XMM reg number, offset in next slot
  UWOP_SAVE_XMM128_FAR = 7; // info == XMM reg number, offset in next 2 slots
  UWOP_PUSH_MACHFRAME = 8;  // info == 0: no error-code, 1: error-code

type
  TUnwindCode = packed record
    CodeOffset: Byte;
    OpInf: Byte; //UBYTE:4 UnwindOp, UBYTE:4 OpInfo
  end ;

  TUnwindCodes = array[Byte] of TUnwindCode;

  PUNWIND_INFO = ^TUNWIND_INFO;
  TUNWIND_INFO = packed record
    VerFlags: Byte; //UBYTE:3 Version, UBYTE:5 Flags
    SzProlog: Byte; //Size of prolog
    UnwindCodeCount: Byte; //Count of unwind codes
    FPRegOffset: Byte; //UBYTE:4 Frame Register, UBYTE:4 Frame Register offset (scaled)
    UnwindCode: TUnwindCodes; //Unwind codes array
  end ;

  PPDataRec = ^TPDataRec;
  TPDataRec = packed record
    Ofs0,Ofs1,OfsUnwind: LongInt;
  end ;
{ //Chained Unwind Info
 PCHAINED_UNWIND_INFO = ^TCHAINED_UNWIND_INFO;
 TCHAINED_UNWIND_INFO = packed record
   StartAdr: ULONG; //Function start address
   EndAdr: ULONG; //Function end address
   Next: ULONG; //Unwind info address
 end ;}

type //Copied from System.pas of XE 2 for the earlier and 32-bit versions of Delphi
  PExcDescEntry = ^TExcDescEntry;
  TExcDescEntry = record
    VTable:  ULong; // 32 bit RVA
    Handler: ULong; // 32 bit RVA
  end;
  PExcDesc = ^TExcDesc;
  TExcDesc = record
    DescCount: Integer;
    DescTable: array [0..0{DescCount-1}] of TExcDescEntry;
  end;

  PExcScope = ^TExcScope;
  TExcScope = record
    BeginOffset:  ULong;  // 32 bit RVA
    EndOffset:    ULong;  // 32 bit RVA
    TableOffset:  ULong;  // 32 bit RVA. 0:TargetOffset=finally block
                             //             1:TargetOffset=safecall catch block
                             //             2:TargetOffset=catch block
                             //             other:TableOffset=TExcDesc
    TargetOffset: ULong;  // 32 bit RVA. start of finally/catch block.
                             //   TableOffset=0: signature is _TDelphiFinallyHandlerProc
                             //   TableOffset=1: signature is _TDelphiSafeCallCatchHandlerProc
                             //   TableOffset=2: Location to the catch block
                             //   other: TargetOffset=0
  end;

const //Auxiliarry metadata structure
  ChkPDataRecTbl: array[0..2]of TFixUpChkRec = ((Ofs:0; K:$15),(Ofs:4; K:$15),(Ofs:8; K:$15));

type
  TPDataIterator = object
   protected
    Ofs: integer;
    PDataFixTbl: PFixupTbl;
    FixRd: TFixUpReader;
    CurOfs: ulong;
    UI: PUNWIND_INFO;
    UIExcCnt: ulong;
   public
    DR: PPDataRec;
    hProc,hUnwind: TNDX;
   public {Scope enumeration}
    ExcScope: PExcScope;
    hScopeProc,hScopeTable,hScopeTarget: TNDX;
    function NextExcScope: Boolean;
   private{ExcDesc enumeration}
    ExcDescRest: Integer;
    ExcFixRd: TFixUpReader;
   public{ExcDesc enumeration}
    ExcDescCnt: Integer;
    ExcDesc: PExcDescEntry;
    hExcVTable,hExcHandler: TNDX;
    function NextExcDesc: Boolean;
  end ;

  PWin64UnwindInfo = ^TWin64UnwindInfo;
  TWin64UnwindInfo = object
   protected
    PDataDP: Pointer; PDataDS: Cardinal; DP: Pointer; DS: Cardinal;
    UnwindNdx,ProcNdx: TNDX;
    UnwindDR,ProcDR: TObject{TDCURec};
    FPDataFixTbl: PFixupTbl;
    procedure Clear;
    function Init0(APDataDP: Pointer; APDataDS: Cardinal; ADP: Pointer; ADS: Cardinal): Boolean;
   public
    function InitXData(hPData: TNDX; ADP: Pointer; ADS: Cardinal): Boolean;
    function InitPData(hPData: TNDX): Boolean;
    function Show: Boolean;
    procedure SetPDataLinks(hDecl: TNDX); //Called from TVarCDecl.SetSegKind
    function FirstPDataRec(var Iter: TPDataIterator): Boolean;
    function NextPDataRec(var Iter: TPDataIterator): Boolean;
  end ;

function CheckPDataRec(var FixRd: TFixUpReader): Boolean;
procedure ShowPDataRec0(DP: Pointer; FixTbl: PFixupTbl);
function ShowPDataRec(DP: Pointer; DS: Cardinal): Boolean;

implementation

uses
  DCU32, DCURecs;

function CheckPDataRec(var FixRd: TFixUpReader): Boolean;
var
  ProcNdx: TNDX;
  FxRes: array[0..2]of PFixupRec;
begin
  Result := false;
  if not FixRd.CheckFixups(12,ChkPDataRecTbl,@FxRes) then
    Exit;
  (*BlOfs := TIncPtr(DP)-FDataBlPtr;
  if (FixTbl^[0].OfsF)<>BlOfs+($15 shl FixOfsShift) then
    Exit {K=$15,Ofs=BlOfs};
  if (FixTbl^[1].OfsF)<>(BlOfs+4)+($15 shl FixOfsShift) then
    Exit {K=$15,Ofs=BlOfs+4};
  if (FixTbl^[2].OfsF)<>(BlOfs+8)+($15 shl FixOfsShift) then
    Exit {K=$15,Ofs=BlOfs+8};*)
  ProcNdx := FxRes[0]^.Ndx;
  if (ProcNdx<>FxRes[1]^.Ndx) then
    Exit;
  Result := true;
end ;

procedure ShowPDataRec0(DP: Pointer; FixTbl: PFixupTbl);
//Decompiler magic for .pdata
//Show the PData section
var
  BlOfs: Cardinal;
begin
  CurUnit.PutAddrStr(FixTbl^[0].Ndx,true{ShowNDX});
  PutSFmt('[$%x..$%x)',[PPDataRec(DP)^.Ofs0,PPDataRec(DP)^.Ofs1]);
  PutS(','+cSoftNL);
  PutS('unwind ');
  CurUnit.PutAddrStr(FixTbl^[2].Ndx,true{ShowNDX});
  PutHexOffset(PPDataRec(DP)^.OfsUnwind);
end ;

function CheckPData(DP: Pointer; DS: Cardinal): PFixupTbl{The fixups of PData records, 3 per record};
var
  i,N: Integer;
  FixRd: TFixUpReader;
  FixTbl: PFixupTbl;
begin
  Result := Nil;
  if (DS mod 12)<>0 then
    Exit;
  N := DS div 12;
  if not CurUnit.HasFixups then
    Exit{Paranoic};
  FixRd.Init(DP,DS);
  if FixRd.FixCnt<1+3*N then
    Exit;
  if not FixRd.SkipStartFixup then
    Exit;
  PFixupRec(FixTbl) := FixRd.FixTbl;
  for i := 0 to n-1 do
    if not CheckPDataRec(FixRd) then
      Exit;
  Result := FixTbl;
end ;

function ShowPDataRec(DP: Pointer; DS: Cardinal): Boolean;
//Decompiler magic for .pdata
//Show the PData section
var
  i,N: Integer;
  DR: PPDataRec;
  FixTbl: PFixupTbl;
begin
  Result := false;
  N := DS div 12;
  FixTbl := CheckPData(DP,DS);
  if FixTbl=Nil then
    Exit;
  ShiftNLOfs(2);
  try
    PutS('(.pdata of'+cSoftNL);
    DR := DP;
    for i := 0 to N-1 do begin
      if i>0 then
        PutS(';'+cSoftNL);
      ShowPDataRec0(DR,FixTbl);
      Inc(PFixupRec(FixTbl),3);
      Inc(DR);
    end ;
  finally
    ShiftNLOfs(-2);
  end ;
  PutS(')');
  Result := true;
end ;

const
  sDelphiExcHandler='@DelphiExceptionHandler';
  ExcScopeChkTbl: array[0..3]of TFixUpChkRec = ((Ofs:0; K:$15),(Ofs:4; K:$15),
    (Ofs:8; K:$15; Optional: true),(Ofs:12; K:$15; Optional: true));

function ShowUnwindRec(var FixRd: TFixUpReader; DP: Pointer; DS: Cardinal): ulong{0 => error};
//Decompiler magic for .xdata - unwind records
const
  sReg64: array[0..$F]of AnsiString = (
    'RAX','RCX','RDX','RBX','RSP','RBP','RSI','RDI',
    'R8','R9','R10','R11','R12','R13','R14','R15');
var
  UI: PUNWIND_INFO;
  {BlOfs,}HdrSz: Cardinal;
  i{,Fix0,FixCnt}: Integer;
  //FixTbl: PFixupTbl;
  ChkFixRd: TFixUpReader;
  Ofs,ExcCnt: DCU_In.ULong;
  Fix: PFixupRec;
  hHandler: TNDX;
  HandlerName: PName;
  S: String;
  C: TUnwindCode;
  Inf: Integer;
  VP: ^LongInt;
  V: LongInt;
  Stop: Boolean;
  FxRes: array[0..3]of PFixupRec;
  ExcScope: PExcScope;
begin
  Result := 0;
  UI := DP;
  if UI^.VerFlags and UnwindVerMask<>1 then
    Exit{Wrong version};
  if DS<SizeOf(TUNWIND_INFO)-SizeOf(TUnwindCodes) then
    Exit;
  HdrSz := SizeOf(TUNWIND_INFO)-SizeOf(TUnwindCodes)+((UI^.UnwindCodeCount+1)and not 1)*SizeOf(TUnwindCode);
  ChkFixRd := FixRd;
  if not ChkFixRd.SkipNoFixData(HdrSz) then
    Exit;
  if (UI^.VerFlags and UNW_FLAG_CHAININFO)<>0 then begin
    if UI^.VerFlags<>UNW_FLAG_CHAININFO+1 then
      Exit {No other flags allowed};
    if not CheckPDataRec(ChkFixRd) then
      Exit;
   end
  else if (UI^.VerFlags and(UNW_FLAG_EHANDLER or UNW_FLAG_UHANDLER))<>0 then begin
    if not ChkFixRd.ReadULongFix(Ofs,Fix) then
      Exit;
  end ;
  ShiftNLOfs(2);
  try
    PutSFmt('(unwind[%x,prolog:$%x,FPReg:$%x]',[UI^.VerFlags shr 3,UI^.SzProlog,UI^.FPRegOffset]);
    if UI^.UnwindCodeCount>0 then begin
      S := cSoftNL+'(';
      i := 0;
      while i<UI^.UnwindCodeCount do begin
        PutS(S);
        C := UI^.UnwindCode[i];
        PutSFmt('$%x ',[C.CodeOffset]);
        Inf := C.OpInf shr 4;
        case C.OpInf and $F of
         UWOP_PUSH_NONVOL: PutSFmt('PUSH_NONVOL %s',[sReg64[Inf]]); // info == register number
         UWOP_ALLOC_LARGE: begin
           PutSFmt('ALLOC_LARGE $%x',[PULong(@UI^.UnwindCode[i+1])^]); // no info, alloc size in next 2 slots
           Inc(i,2);
          end ;
         UWOP_ALLOC_SMALL: PutSFmt('ALLOC_SMALL $%x',[(Inf+1)*8]); // info == size of allocation / 8 - 1
         UWOP_SET_FPREG: PutSFmt('SET_FPREG RSP+$%x',[UI^.FPRegOffset*16]); // no info, FP = RSP + UNWIND_INFO.FPRegOffset*16
         UWOP_SAVE_NONVOL: begin
           PutSFmt('SAVE_NONVOL %s,$%x',[sReg64[Inf],Word(UI^.UnwindCode[i+1])]); // info == register number, offset in next slot
           Inc(i);
          end ;
         UWOP_SAVE_NONVOL_FAR: begin
           PutSFmt('SAVE_NONVOL_FAR %s,$%x',[sReg64[Inf],PUlong(@UI^.UnwindCode[i+1])^]); // info == register number, offset in next 2 slots
           Inc(i,2);
          end ;
         UWOP_SAVE_XMM128: begin
           PutSFmt('SAVE_XMM128 XMM%d,$%x',[Inf,Word(UI^.UnwindCode[i+1])]); // info == XMM reg number, offset in next slot
           Inc(i);
         end ;
         UWOP_SAVE_XMM128_FAR: begin
           PutSFmt('SAVE_XMM128_FAR XMM%d,$%x',[Inf,PUlong(@UI^.UnwindCode[i+1])^]); // info == XMM reg number, offset in next 2 slots
           Inc(i,2);
         end ;
         UWOP_PUSH_MACHFRAME: PutSFmt('PUSH_MACHFRAME %d',[Inf]);  // info == 0: no error-code, 1: error-code
        else
          PutSFmt('?$%x $%x',[C.OpInf and $F,Inf]);
        end ;
        S := ','+cSoftNL;
        Inc(i);
      end ;
      PutS(')');
    end ;
    Stop := true;
    if (UI^.VerFlags and UNW_FLAG_CHAININFO)<>0 then begin
      PutS(cSoftNL+'next:'+cSoftNL);
      ShowPDataRec0(TIncPtr(DP)+HdrSz,PFixupTbl(FixRd.FixTbl));
      Inc(HdrSz,12);
      Stop := false;
      {Dec(FixCnt,3);
      Inc(PFixupRec(FixTbl),3);}
     end
    else if (UI^.VerFlags and(UNW_FLAG_EHANDLER or UNW_FLAG_UHANDLER))<>0 then begin
      if UI^.VerFlags and UNW_FLAG_EHANDLER<>0 then
        PutS(cSoftNL+'except');
      if UI^.VerFlags and UNW_FLAG_UHANDLER<>0 then
        PutS(cSoftNL+'finally');
      SoftNL;
      hHandler := Fix{Tbl^[0]}^.Ndx;
      CurUnit.PutAddrStr(hHandler,true{ShowNDX});
      //TIncPtr(VP) := TIncPtr(DP)+HdrSz;
      PutHexOffset(Ofs{VP^});
      Inc(HdrSz,4);
      HandlerName := CurUnit.AddrName[hHandler];
      {Dec(FixCnt);
      Inc(PFixupRec(FixTbl));}
      if (HandlerName<>Nil)and HandlerName^.EqS(sDelphiExcHandler)and
        ChkFixRd.ReadULongNoFix(ExcCnt){(FixCnt>1)and(FixTbl^[0].OfsF and FixOfsMask>=BlOfs+HdrSz+4)}
      then begin
       {The format of variable data is known}
        //ExcCnt := PDWORD(TIncPtr(DP)+HdrSz)^;
        if (ExcCnt>0)and(HdrSz+4+ExcCnt*SizeOf(TExcScope)<=DS) then begin
          Stop := false;
          FixRd := ChkFixRd;
          for i:=1 to ExcCnt do begin
            Stop := true;
            if not ChkFixRd.CheckFixups(16,ExcScopeChkTbl,@FxRes) then
              break;
            if FxRes[0]^.Ndx<>FxRes[1]^.Ndx then
              break;
            Stop := false;
          end ;
          if not Stop then begin
            ShiftNLOfs(2);
            for i:=1 to ExcCnt do begin
              ExcScope := Pointer(FixRd.DP);
              FixRd.CheckFixups(16,ExcScopeChkTbl,@FxRes);
              PutS(cSoftNL+'(');
              CurUnit.PutAddrStr(FxRes[0]^.Ndx,true{ShowNDX});
              PutSFmt('[$%x..$%x]'+cSoftNL,[ExcScope^.BeginOffset,ExcScope^.EndOffset]);
              if FxRes[2]=Nil then begin
                case ExcScope^.TableOffset of
                 0: S := 'finally';
                 1: S := 'safecall';
                 2: S := 'catch';
                else
                  S := Format('Unknown %d',[ExcScope^.TableOffset]);
                end;
                PutS(S);
               end
              else begin
                PutS('other ');
                CurUnit.PutAddrStr(FxRes[2]^.Ndx,true{ShowNDX});
                PutHexOffset(ExcScope^.TableOffset);
              end ;
              if FxRes[3]=Nil then begin
                if (ExcScope^.TargetOffset<>0) then
                  PutSFmt(cSoftNL+'?target $%x',[ExcScope^.TargetOffset]);
               end
              else begin
                PutS(cSoftNL+'target ');
                CurUnit.PutAddrStr(FxRes[3]^.Ndx,true{ShowNDX});
                PutHexOffset(ExcScope^.TargetOffset);
              end ;
              PutS(')');
            end ;
            ShiftNLOfs(-2);
            //Inc(HdrSz,4+ExcCnt*SizeOf(TExcScope));
            HdrSz := FixRd.DP-DP;
          end ;
        end ;
      end ;
    end ;
    Result := HdrSz;
  finally
    ShiftNLOfs(-2);
  end ;
  PutS(')');
end ;

{ TWin64UnwindInfo. }
procedure TWin64UnwindInfo.Clear;
begin
  FillChar(Self,0,SizeOf(TWin64UnwindInfo));
end ;

function TWin64UnwindInfo.Init0(APDataDP: Pointer; APDataDS: Cardinal; ADP: Pointer; ADS: Cardinal): Boolean;
begin
  Result := false;
  if APDataDP=Nil then
    Exit;
  PDataDP := APDataDP;
  PDataDS := APDataDS;
  DP := ADP;
  DS := ADS;
  Result := true;
end ;

function GetPDataMem(hPData: TNDX; var DS: Cardinal): Pointer;
var
  PDataRec: TDCURec;
begin
  Result := Nil;
  DS := 0;
  PDataRec := CurUnit.GetAddrDef(hPData);
  if (PDataRec<>Nil)and(PDataRec is TVarCDecl) then
    Result := CurUnit.GetBlockMem(TVarCDecl(PDataRec).Ofs,TVarCDecl(PDataRec).Sz,DS);
end ;

function TWin64UnwindInfo.InitXData(hPData: TNDX; ADP: Pointer; ADS: Cardinal): Boolean;
var
  APDataDP: Pointer;
  APDataDS: Cardinal;
begin
  Clear;
  APDataDP := GetPDataMem(hPData,APDataDS);
  Result := Init0(APDataDP,APDataDS,ADP,ADS);
end ;

function TWin64UnwindInfo.InitPData(hPData: TNDX): Boolean;
var
  APDataDP,ADP: Pointer;
  APDataDS,ADS: Cardinal;
  FixRd: TFixUpReader;
  FxRes: array[0..2]of PFixupRec;
begin
  Clear;
  Result := false;
  APDataDP := GetPDataMem(hPData,APDataDS);
  if APDataDP=Nil then
    Exit;
  FixRd.Init(APDataDP,APDataDS);
  if FixRd.FixCnt<4 then
    Exit;
  if not FixRd.SkipStartFixup then
    Exit;
  if not FixRd.CheckFixups(12,ChkPDataRecTbl,@FxRes) then
    Exit;
  ProcNdx := FxRes[0]^.Ndx;
  if (ProcNdx<>FxRes[1]^.Ndx) then
    Exit;
  UnwindNdx := FxRes[2]^.Ndx;
  UnwindDR := CurUnit.GetAddrDef(UnwindNdx);
  if (UnwindDR=Nil)or not(UnwindDR is TVarCDecl) then
    Exit;
  if (TVarCDecl(UnwindDR).FSeg<>seg_xdata) then
    Exit;
  ProcDR := CurUnit.GetAddrDef(ProcNdx);
  if (ProcDR=Nil)or not(ProcDR is TProcDecl) then
    Exit;
  ADP := CurUnit.GetBlockMem(TVarCDecl(UnwindDR).Ofs,TVarCDecl(UnwindDR).Sz,ADS);
  Result := Init0(APDataDP,APDataDS,ADP,ADS);
end ;

procedure TWin64UnwindInfo.SetPDataLinks(hDecl: TNDX);
begin
  TProcDecl(ProcDR).AddModifier(TAddrRefDeclModifier.Create(hDecl));
  TVarCDecl(UnwindDR).AddModifier(TAddrRefDeclModifier.Create(hDecl));
end ;

function TWin64UnwindInfo.Show: Boolean;
//Decompiler magic for .xdata - unwind records
var
  PDataFixTbl: PFixupTbl;
  DR: PPDataRec;
  FixRd: TFixUpReader;
  N,i: Integer;
  Ofs,CurOfs,HdrSz: ulong;
begin
  Result := false;
  if not CurUnit.HasFixups then
    Exit{Paranoic};
  FixRd.Init(DP,DS);
  if not FixRd.SkipStartFixup then
    Exit;
  ShiftNLOfs(2);
  try
    PutS('(');
    PDataFixTbl := CheckPData(PDataDP,PDataDS);
    if PDataFixTbl=Nil then
      CurOfs := ShowUnwindRec(FixRd,DP,DS)
    else begin
      CurOfs := 0;
      N := PDataDS div SizeOf(TPDataRec);
      DR := PDataDP;
      for i := 0 to N-1 do begin
        if i>0 then
          PutS(';'+cSoftNL);
        Ofs := DR^.OfsUnwind;
        if Ofs>DS then
          break{Paranoic};
        if Ofs>CurOfs then begin
          NL;
          CurUnit.ShowDataBlP(DP,Ofs,CurOfs{Ofs0});
          FixRd.SkipMayBeFixData(Ofs-CurOfs);
          CurOfs := Ofs;
        end ;
        ShowPDataRec0(DR,PDataFixTbl);
        Inc(PFixupRec(PDataFixTbl),3);
        Inc(DR);
        HdrSz := ShowUnwindRec(FixRd,TIncPtr(DP)+CurOfs,DS);
        if HdrSz=0 then
          break;
        Inc(CurOfs,HdrSz);
      end ;
    end ;
    if CurOfs<DS then begin
      PutS(cSoftNL+'rest:');
      NL;
      CurUnit.ShowDataBlP(DP,DS,CurOfs{Ofs0});
    end ;
  finally
    ShiftNLOfs(-2);
  end ;
  PutS(')');
  Result := true;
end ;

{ TPDataIterator. }
function TPDataIterator.NextExcScope: Boolean;
var
  FxRes: array[0..3]of PFixupRec;
begin
  Result := false;
  ExcDescRest := 0;
  ExcDescCnt := 0;
  if UIExcCnt<=0 then
    Exit;
  Dec(UIExcCnt);
  ExcScope := Pointer(FixRd.DP);
  if not FixRd.CheckFixups(16,ExcScopeChkTbl,@FxRes) then
    Exit;
  hScopeProc := FxRes[0]^.NDX;
  if FxRes[2]<>Nil then begin
    hScopeTable := FxRes[2]^.NDX;
    ExcDescRest := -1; //ExcDesc present
   end
  else
    hScopeTable := -1;
  if FxRes[3]<>Nil then
    hScopeTarget := FxRes[3]^.NDX
  else
    hScopeTarget := -1;
  Result := true;
end ;

function TPDataIterator.NextExcDesc: Boolean;
var
  D: TDCURec;
  DP: TIncPtr;
  DS,ExcOfs: Cardinal;
  U: DCU_In.ulong;
  Fix: PFixupRec;
begin
  Result := false;
  if (ExcDescRest=0)or(hScopeTable<0) then
    Exit;
  if ExcDescRest=-1 then begin
    ExcDescRest := 0;
    D := CurUnit.GetAddrDef(hScopeTable);
    if (D=Nil)or not(D is TProcDecl) then
      Exit;
    ExcOfs := ExcScope^.TableOffset;
    if (ExcOfs<0)or(ExcOfs+SizeOf(ulong)>=TProcDecl(D).Sz) then
      Exit;
    DP := CurUnit.GetBlockMem(TProcDecl(D).Ofs+ExcOfs,TProcDecl(D).Sz-ExcOfs,DS);
    ExcFixRd.Init(DP,DS);
    if not ExcFixRd.ReadULongNoFix(U) then
      Exit;
    if U<=0 then
      Exit;
    ExcDescRest := U;
    ExcDescCnt := U;
  end ;
  Dec(ExcDescRest);
  ExcDesc := Pointer(ExcFixRd.DP);
  if not ExcFixRd.ReadULongFix(U,Fix) then
    Exit;
  hExcVTable := Fix^.Ndx;
  if not ExcFixRd.ReadULongFix(U,Fix) then
    Exit;
  hExcHandler := Fix^.Ndx;
  Result := true;
end ;

function TWin64UnwindInfo.FirstPDataRec(var Iter: TPDataIterator): Boolean;
begin
  Result := false;
  if not CurUnit.HasFixups then
    Exit{Paranoic};
  Iter.PDataFixTbl := CheckPData(PDataDP,PDataDS);
  if Iter.PDataFixTbl=Nil then
    Exit;
  Iter.DR := PDataDP;
  Dec(Iter.DR);
  Iter.Ofs := 0;
  Iter.FixRd.Init(DP,DS);
  if not Iter.FixRd.SkipStartFixup then
    Exit;
  Iter.CurOfs := 0;
  Result := NextPDataRec(Iter);
end ;

function TWin64UnwindInfo.NextPDataRec(var Iter: TPDataIterator): Boolean;
var
  Ofs,HdrSz,HandlerOfs,ExcCnt: DCU_In.ULong;
  UI: PUNWIND_INFO;
  HandlerFix,Fix: PFixupRec;
  HandlerName: PName;
begin
  Result := false;
  Inc(Iter.Ofs,SizeOf(TPDataRec));
  if Iter.Ofs>PDataDS then
    Exit;
  Inc(Iter.DR);
  Iter.hProc := Iter.PDataFixTbl^[0].Ndx;
  Iter.hUnwind := Iter.PDataFixTbl^[2].Ndx;
  Ofs := Iter.DR^.OfsUnwind;
  Iter.UI := Nil;
  Iter.UIExcCnt := 0;
  if Ofs<DS then begin
    if Ofs>Iter.CurOfs then begin
      Iter.FixRd.SkipMayBeFixData(Ofs-Iter.CurOfs);
      Iter.CurOfs := Ofs;
    end ;
    TIncPtr(UI) := TIncPtr(DP)+Ofs;
    if (UI^.VerFlags and UnwindVerMask=1)and(SizeOf(TUNWIND_INFO)-SizeOf(TUnwindCodes)<=DS) then begin
      HdrSz := SizeOf(TUNWIND_INFO)-SizeOf(TUnwindCodes)+((UI^.UnwindCodeCount+1)and not 1)*SizeOf(TUnwindCode);
      if Iter.FixRd.SkipNoFixData(HdrSz) then begin
        if ((UI^.VerFlags and UNW_FLAG_CHAININFO)=0{May be not used by Delphi - Ignored by now})
          and((UI^.VerFlags and(UNW_FLAG_EHANDLER or UNW_FLAG_UHANDLER))<>0)
          and Iter.FixRd.ReadULongFix(HandlerOfs,HandlerFix)
        then begin
          HandlerName := CurUnit.AddrName[HandlerFix^.Ndx];
          if (HandlerName<>Nil)and HandlerName^.EqS(sDelphiExcHandler)
            and Iter.FixRd.ReadULongNoFix(ExcCnt){(FixCnt>1)and(FixTbl^[0].OfsF and FixOfsMask>=BlOfs+HdrSz+4)}
            and(ExcCnt>0)and(HdrSz+4+ExcCnt*SizeOf(TExcScope)<=DS)
          then begin
            Iter.UIExcCnt := ExcCnt;
            Iter.UI := UI;
          end ;
        end ;
      end ;
    end ;
  end ;
  Inc(PFixupRec(Iter.PDataFixTbl),3);
  Result := true;
end ;

end.
