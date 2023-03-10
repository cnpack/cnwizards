unit x86Dasm;

(*
The main module of the i80x86 disassembler, based upon XML specification
x86reference.xml from http://ref.x86asm.net/,
of the DCU32INT utility by Alexei Hmelnov.
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
  DasmDefs,{DasmUtil,}x86Reg,x86Defs,x86Op;

{
function ReadCommand: boolean;

procedure ShowCommand;

}

{type
  TRegIndex = (hnRax,hnRcx,hnRdx,hnRbx,hnRsp,hnRbp,hnRsi,hnRdi,
    hnR8,hnR9,hnR10,hnR11,hnR12,hnR13,hnR14,hnR15,

   //Register parts:
    hnEax,hnEcx,hnEdx,hnEbx,hnEsp,hnEbp,hnEsi,hnEdi,
    hnR8d,hnR9d,hnR10d,hnR11d,hnR12d,hnR13d,hnR14d,hnR15d,

    hnax, hncx, hndx, hnbx, hnsp, hnbp, hnsi, hndi,
    hnR8w,hnR9w,hnR10w,hnR11w,hnR12w,hnR13w,hnR14w,hnR15w,

    hnal, hncl, hndl, hnbl, hnspl, hnbpl, hnsil, hndil,
    hnR8b,hnR9b,hnR10b,hnR11b,hnR12b,hnR13b,hnR14b,hnR15b,

    hnAH,hnCH,hnDH,hnBH);
}
const
  efTwoByte = $8000;
  efEntryIndex = $7FFF;

type
  //TRegIndex = Integer{THBMName};
  TCmdIndex = packed record
    hEntry: Word;
    hSyntax: ShortInt; //+Base required
    FPrefix: Byte; //bit=1 => Should show Prefix
  end ;

function ReadOp: Boolean;

function GetPrefixMnemonics(CmdEP: POpcodeEntry; B: Byte): TOpcodeMnem;

//function GetOpName(hName: THBMName):TBMOpRec;
function GetRegName(hName: THBMName):TBMOpRec;

function CheckCommandRefs(RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
  IP: Pointer): integer;

const
  OpTables: array[Boolean]of TOpcodeTables = (
    (OpCodes: @OneByte;
    EntryCount: High(OneByteEntries)+1; Entries: @OneByteEntries;
    SyntaxCount: High(OneByteSyntaxes)+1; Syntaxes: @OneByteSyntaxes;
    ArgCount: High(OneByteArgs)+1; Args: @OneByteArgs),
    (OpCodes: @TwoByte;
    EntryCount: High(TwoByteEntries)+1; Entries: @TwoByteEntries;
    SyntaxCount: High(TwoByteSyntaxes)+1; Syntaxes: @TwoByteSyntaxes;
    ArgCount: High(TwoByteArgs)+1; Args: @TwoByteArgs)
  );

implementation

uses
  DasmUtil, TypInfo;

const
  I64ToModes: array[Boolean]of TEntryModes = ([ee_r,ee_p],[ee_r,ee_p,ee_e]);

function HasPrefix(Pref: Byte): Integer;
var
  CP: TIncPtr;
begin
  CP := PrevCodePtr;
  Result := 0;
  while CP<CodePtr do begin
    if Byte(CP^)=Pref then
      Exit;
    Inc(Result);
    Inc(CP);
  end ;
  Result := -1;
end ;

function FindSyntax(Syntaxes: POpcodeSyntaxes; Count: Integer; Args: POpcodeArgs): Integer;
var
  i,j,V,MV: Integer;
  SP: POpcodeSyntax;
  AP: POpcodeArg;
  Ok,Exact: Boolean;
begin
  Result := -1;
  SP := POpcodeSyntax(Syntaxes);
  for i:=0 to Count-1 do begin
    Ok := true;
    Exact := true;
    if SP^.Count>0 then begin
      AP := @Args^[SP^.Base];
      for j:=0 to SP^.Count-1 do begin
        if amMemOnly in AddrMethodProps[AP^.A].F then begin
          if SeeNextCodeByte and $C0=$C0 then begin
            Ok := false;
            Break{Register instead of memory};
          end ;
        end ;
        with ArgAddrTypeProps[AP^.T] do begin
          case Factor of
           sfOS: V := GetOS;
           sfOS64: V := GetOS64;
           sfAS: V := GetAS;
           sfStack,sfMode: V := 1+Ord(modeI64);
           sfRexW: V := Ord(CurREX and rexfW<>0);
          else
            V := -1;
          end ;
          if (V>=0) then begin
            MV := (1 shl V);
            if M and MV=0 then begin
              Ok := false;
              break;
            end ;
            if Exact and (M<>MV) then
              Exact := false; //The choice of the syntax is not exact, some more specifix syntax is possible
                //Allows to select MOVSD instead of just MOVS
          end ;
        end ;
        Inc(AP);
      end ;
    end ;
    if Ok then begin
      if Exact or(Result<0) then
        Result := i;
      if Exact then
        Exit;
    end ;
    Inc(SP);
  end ;
end ;

function FindEntry(Entries: POpcodeEntries; Count: Integer; IsTwoByte,zOnly: Boolean;
  var hSyntax,hPrefix: integer): Integer;
var
  EP: POpcodeEntry;
  ValidModes: TEntryModes;
  ModeOk,BestModeOk,ChkArgCnt,BestIsPrefix,IsPrefix: Boolean;
  NextCodeByte,hPrefixCur: Integer;
  i,iBest,hSyntaxBest,hPrefixBest,d,hSyntaxI,ArgCnt,ArgCntBest: Integer;
  Dep,DepBest: TEntryDependences;
  Syntaxes: POpcodeSyntaxes;
begin
  Result := -1;
  ValidModes := I64ToModes[modeI64];
  DepBest := [];
  iBest := -1;
  hSyntaxBest := -1;
  hPrefixBest := -1;
  NextCodeByte := -2;
  ArgCntBest := -1;
  BestModeOk := false;
  BestIsPrefix := false;
  //function SeeNextCodeByte: Integer{-1 => Error};
  for i:=0 to Count-1 do begin
    EP := @Entries^[i];
    ModeOk := false;
    if en_mode in EP^.Flags then begin
      if not(EP^.mode in ValidModes) then
        Continue;
      if not ModeOk then
        ModeOk := true;
    end ;
    if zOnly and not(od_Z in Entries^[i].FData) then
      Continue;
    Dep := EP^.Dep;
    if [ed_OpcdExt,ed_SecOpcd]*Dep<>[] then begin
      if NextCodeByte=-2 then
        NextCodeByte := SeeNextCodeByte;
      if NextCodeByte<0 then
        Continue;
      if ed_SecOpcd in Dep then begin
        if NextCodeByte<>EP^.SecOpcd then
          Continue;
       end
      else if (NextCodeByte shr 3)and $7<>EP^.OpcdExt then
        Continue;
    end ;
    hPrefixCur := -1;
    if ed_Pref in Dep then begin
      hPrefixCur := HasPrefix(EP^.Pref);
      if hPrefixCur<0 then
        Continue;
    end ;
    IsPrefix := EP^.grp1=g1_prefix;
    ChkArgCnt := false;
    if iBest>=0 then begin
      if BestModeOk and not ModeOk then
        Continue;
      if BestModeOk=ModeOk then begin
        D := Ord(ed_SecOpcd in Dep)-Ord(ed_SecOpcd in DepBest);
        if D<0 then
          Continue;
        if D=0 then begin
          if ed_SecOpcd in Dep then
            D := 0
          else begin
            D := Ord(ed_OpcdExt in Dep)-Ord(ed_OpcdExt in DepBest);
            if D<0 then
              Continue;
          end ;
          if D=0 then begin
            D := Ord(ed_Pref in Dep)-Ord(ed_Pref in DepBest);
            if D<0 then
              Continue;
            if BestIsPrefix{For SegXX ignore arg count - use the 1st mentioned} then
              Continue;
            ChkArgCnt := D=0;
          end ;
        end ;
      end ;
    end ;
    hSyntaxI := -1;
    if EP^.Count>0 then begin
      Syntaxes := @OpTables[IsTwoByte].Syntaxes^[EP^.Base];
      hSyntaxI := FindSyntax(Syntaxes,EP^.Count,OpTables[IsTwoByte].Args);
      if hSyntaxI<0 then
        Continue; //Not supported in the current mode;
      ArgCnt := Syntaxes^[hSyntaxI].Count;
      if ChkArgCnt and(ArgCnt>=ArgCntBest) then
        Continue; //Prefer NOP over XCHG EAX,EAX
    end ;
    if (hSyntaxI<0)and(hSyntaxBest>=0) then
      Continue{EP^.Count=0 => Error record};
    BestModeOk := ModeOk;
    DepBest := Dep;
    iBest := i;
    hSyntaxBest := hSyntaxI;
    hPrefixBest := hPrefixCur;
    ArgCntBest := ArgCnt;
    BestIsPrefix := IsPrefix;
  end ;
  Result := iBest;
  if Result<0 then
    Exit;
  hSyntax := hSyntaxBest;
  hPrefix := hPrefixBest;
  if ed_SecOpcd in DepBest then
    SkipByte; //The byte was consumed by the readed
end ;

function FindOpCEntry(IsTwoByte: Boolean; B: Byte; var hSyntax,hPrefix: integer): Integer;
var
  ValidModes: TEntryModes;
  Op: PPrimaryOpcode;
  NBase: Byte;
begin
  ValidModes := I64ToModes[modeI64];
  Op := @OpTables[IsTwoByte].OpCodes^[B];
  hSyntax := -1;
  if (Op^.Count>0)and((Op^.Modes=[]{any mode is Ok})or(Op^.Modes*ValidModes<>[])) then begin
    Result := FindEntry(@OpTables[IsTwoByte].Entries^[Op^.Base],Op^.Count,IsTwoByte,false{zOnly},hSyntax,hPrefix);
    if Result>=0 then begin
      Inc(Result,Op^.Base);
      Exit;
    end ;
  end ;
  if (ed_Z in Op^.Dep) then begin
    NBase := B and not $7;
    if NBase<>B then begin
      Op := @OpTables[IsTwoByte].OpCodes^[NBase];
      if (Op^.Count>0)and((Op^.Modes=[]{any mode is Ok})or(Op^.Modes*ValidModes<>[])) then begin
        Result := FindEntry(@OpTables[IsTwoByte].Entries^[Op^.Base],Op^.Count,IsTwoByte,true{zOnly},hSyntax,hPrefix);
        if Result>=0 then begin
          Inc(Result,Op^.Base);
          Exit;
        end ;
      end ;
    end ;
  end ;
  Result := -1;
end ;

const
  OpSizeDasmCode: array[TOpSize] of Integer = (0{osNone},dsByte{osByte},dsWord{osWord},dsDbl{osDWord},
    dsQWord{osQWord},dsByte{osBCD},dsDbl{osSingle},dsQWord{osDouble},dsTWord{osExtended},
    dsPtr{osPtr16_16},dsPtr6b{osPtr16_32},dsTWord{!!!osPtr16_64},
    0{osEnv16},0{osEnv32},0{osFPUState16},0{osFPUState32},0{osSIMDState});

function ReadOp: Boolean;
var
  IsTwoByte: Boolean;
  B: Integer;
  hEntry,hSyntax,hPrefix,ModRArg,ModRVal: Integer;
  ArgType: TRegTblIndex;
  EP: POpcodeEntry;
  SP: POpcodeSyntax;
  AP,APModR: POpcodeArg;
  DK: TOpcodeDatum;
  SizeF: Integer{TSizeFlagVal};
  OpSize: TOpSize;
  i,A,M: Integer;

  procedure NeedArgType;
  begin
    ArgType := AddrMethodProps[AP^.A].RegT;
    if ArgType=rtNone then
      ArgType := RegTbl[WasRexW<>0][(OpSizeDasmCode[OpSize]-1)and $3{Just in case}];
  end ;

begin
  hEntry := -1;
  EP := Nil;
  IsTwoByte := false;
  Result := false;
  repeat
    if not ReadByte(B) then
      Exit;
    if not IsTwoByte and(B=$0F) then begin
      //en_ref in EP^.Flags may be used after FindOpCEntry, but pop CS hides the entry (ProcStart/ProcEnd should be used)
      Cmd.PrefSize := CodePtr-PrevCodePtr;
      IsTwoByte := true;
      Continue;
    end ;
    hEntry := FindOpCEntry(IsTwoByte,B,hSyntax,hPrefix);
    if hEntry<0 then
      Exit;
    EP := @OpTables[IsTwoByte].Entries^[hEntry];
    if EP^.grp1<>g1_prefix then
      break;
    {Prefix is used in OneByte only, so we don`t check IsTwoByte here}
    Cmd.PrefSize := CodePtr-PrevCodePtr;
    case B of {No attributes in XML for REX and the other prefixes - use opcode instead}
     $40..$4F:{REX} setREX((B shr 3)and $1,B and $7); //Use 2-arg function for compatibility with the prev. disassembler
     $66: setOS;
     $67: setAS;
     $F0: ; //LOCK
     $F2{REPNE},$F3{REP}: ;
    else
      case EP^.grp2 of
       g2_segreg: begin
         if EP^.Attr=ea_null then
           Continue;
         case EP^.Mnem of
          oc_ES: i := hES;
          oc_CS: i := hCS;
          oc_SS: i := hSS;
          oc_DS: i := hDS;
          oc_FS: i := hFS;
          oc_GS: i := hGS;
         else
           Continue{Paranoic};
         end ;
         SetSeg(i);
        end ;
       g2_branch: begin
        end;
       g2_x87fpu: ; //WAIT
       //g2_string: ;//REP
      end ;
    end ;
  until false;
  //EP := @OpTables[IsTwoByte].Entries^[hEntry];
  if EP^.Count<=0 then
    Exit{Paranoic};
  {hSyntax := FindSyntax(@OpTables[IsTwoByte].Syntaxes^[EP^.Base],EP^.Count,OpTables[IsTwoByte].Args);}
  if IsTwoByte then
    hEntry := hEntry or efTwoByte;
  Cmd.hCmd.hEntry := hEntry;
  Cmd.hCmd.hSyntax := hSyntax;
  Cmd.hCmd.FPrefix := 1 shl hPrefix;
  SP := @OpTables[IsTwoByte].Syntaxes^[EP^.Base+hSyntax];
  if SP^.Count>0 then begin
    AP := @OpTables[IsTwoByte].Args^[SP^.Base];
    APModR := Nil;
    A := -1;
    ModRArg := -1;
    ArgType := rtNone;
    ModRVal := -1;
    for i:=0 to SP^.Count-1 do begin
      if not(afNoDispl in AP^.Flags) then begin
        SizeF := 0{sfWord}; //a default value
        with ArgAddrTypeProps[AP^.T] do begin
          case Factor of
           sfOS: SizeF := GetOS;
           sfAS: SizeF := GetAS;
           sfStack: SizeF := GetMode;
          {$IFDEF I64}
           sfOS64: SizeF := GetOS64;
           sfRexW: SizeF := WasRexW;
          {$ENDIF}
           sfDest: ;
           sfMode: SizeF := GetMode;
          end ;
          OpSize := Sz[TSizeFlagVal(SizeF)];
        end ;
        {ArgSz := OpSizeBytes[OpSize];
        if ArgSz>8 then
          ArgSz := 8;}
        Cmd.Arg[Cmd.Cnt+1].nArg := i;
        DK := AddrMethodProps[AP^.A].Data;
        if AP^.Name=an_1 then
          SetCmdArg(1)
        else if AP^.Name=an_3 then
          SetCmdArg(1)
        else if afNr in AP^.Flags then begin
          if AP^.A=am_None then begin
            if AP^.Name=an_ST then
              ArgType := rtFP; //Wasn`t specified correctly
          end ;
          if ArgType=rtNone then
            NeedArgType;
          SetCmdArg(EncodeRegIndex(ArgType,AP^.nr))
         end
        else
          case DK of
           od_Ptr: if not imPtr then
             Exit;
           od_ModR: begin
             NeedArgType;
             if ModRVal>=0 then
               SetCmdArg(EncodeRegIndex(ArgType,DecodeRegIndex(ModRval)))
             else begin
               SetCmdArg(EncodeRegIndex(ArgType,0{reserve the place}));
               ModRArg := Cmd.Cnt;
             end ;
            end;
           od_ModM: begin
             ArgType := AddrMethodProps[AP^.A].RegT;
             if ArgType<>rtNone then
               setEAMod3Tbl(ArgType);
             if not getEA(OpSizeDasmCode[OpSize]-1,M,A) then
               Exit;
             SetCmdArg(A);
             M := addREXBit(M,3);
             if ModRArg>0 then
               Cmd.Arg[ModRArg].Inf := Cmd.Arg[ModRArg].Inf+DecodeRegIndex(M)
             else
               ModRVal := M;
            end ;
           od_I: begin
             if en_sign_ext in EP^.Flags then begin
               if not imInt(OpSizeDasmCode[OpSize]-1) then
                 Exit;
              end
             else if not ImmedBW(OpSizeDasmCode[OpSize]-1) then
               Exit;
           end ;
           od_J: if not jmpOfs(OpSizeDasmCode[OpSize]-1) then
             Exit;
           od_ImOfs: begin
             if not getImmOfsEA(Ord(OpSize<>osByte){W: 0=> Byte, 1=> Word or DWORD},A) then
               Exit;
             SetCmdArg(hEA);
            end ;
           od_Z: begin //The last 3 bits of opcode - register number
             NeedArgType;
             SetCmdArg(EncodeRegIndex(ArgType,B and $7))
            end ;
          end ;
      end ;
      Inc(AP);
    end ;
//od_Ptr,od_ModRM,od_I,od_J,od_ImOfs,od_Z,od_None
  {if od_ModRM in EP^.FData then begin
  end ;}
  end ;
  Result := true;
end ;

function FindPrefixEntry(CmdEP: POpcodeEntry; Entries: POpcodeEntries; Count: Integer): POpcodeEntry;
var
  EP: POpcodeEntry;
  ValidModes: TEntryModes;
  i: Integer;
begin
  Result := Nil;
  ValidModes := I64ToModes[modeI64];
  for i:=0 to Count-1 do begin
    EP := @Entries^[i];
    if en_mode in EP^.Flags then begin
      if not(EP^.mode in ValidModes) then
        Continue;
    end ;
    if EP^.grp1<>g1_prefix then
      Continue;
    if (CmdEP^.grp2=EP^.grp2)and((EP^.grp3=g3_none)or(CmdEP^.grp3=EP^.grp3)) then begin
      Result := EP;
      Exit;
    end ;
    if Result=Nil then
      Result := EP;
  end ;
end ;

function GetPrefixMnemonics(CmdEP: POpcodeEntry; B: Byte): TOpcodeMnem;
var
  ValidModes: TEntryModes;
  Op: PPrimaryOpcode;
  EP: POpcodeEntry;
  Syntax: POpcodeSyntax;
begin
  Result := oc_None;
  if (B=$66{Operand size})or(B=$67{Address size}) then
    Exit;
  ValidModes := I64ToModes[modeI64];
  Op := @OpTables[false{IsTwoByte}].OpCodes^[B];
  if (Op^.Count<=0) then
    Exit{Paranoic};
  if (Op^.Modes<>[]{any mode is Ok})and(Op^.Modes*ValidModes=[]) then
    Exit{Paranoic};
  EP := FindPrefixEntry(CmdEP,@OpTables[false{IsTwoByte}].Entries^[Op^.Base],Op^.Count);
  if EP=Nil then
    Exit;
  if EP^.grp2=g2_rex then
    Exit;
  if EP^.grp2=g2_segreg then
    Exit{Represented by the Cmd.EA};
  Result := EP^.Mnem;
  if (Result<>oc_None)or(EP^.Count<=0{Paranoic}) then
    Exit;
 {Several alternative syntaxes}
  Syntax := @OpTables[false{IsTwoByte}].Syntaxes^[EP^.Base]; //1st mentioned of the alternatives
  Result := Syntax^.Mnem;
end ;

{function GetOpName(hName: THBMName):TBMOpRec;
begin
  Result := '';
end ;}

function GetRegName(hName: THBMName):TBMOpRec;
begin
  Result := x86Reg.GetRegName(hName);
end ;

{function ReadCommand: boolean;
begin
  Result := false;
end ;

procedure ShowCommand;
begin
end ;
}

function CheckCommandRefs(RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
  IP: Pointer): integer{crX};

  function RegisterCodeRef(RefKind: Byte; i: integer): boolean;
  var
    RefP: LongInt;
   // DP: Pointer;
    Ofs: LongInt;
  begin
    Result := false;
    if i>Cmd.Cnt then
      Exit;
    with Cmd.Arg[i{Cmd.Cnt}] do
     Case CmdKind {and caMask} of
       {caImmed: begin
           if (Kind shr 4)and dsMask <> dsPtr then
             Exit;
           DP := PChar(PrevCodePtr)+Inf;
           RefP := LongInt(DP^);
         end ;}
       caJmpOfs: begin
           if Fix<>Nil then
             Exit; //!!!
           if not GetIntData(DSize{Kind shr 4},Inf,Ofs) then
             Exit;
           RefP := CmdOfs+Ofs;
         end;
     else
       Exit;
     End ;
    RegRef(RefP,RefKind,IP);
    Result := true;
  end ;

var
  EP: POpcodeEntry;
  SP: POpcodeSyntax;
  Mnem: TOpcodeMnem;
begin
  Result := -1;
  EP := @OpTables[Cmd.hCmd.hEntry and efTwoByte<>0].Entries^[Cmd.hCmd.hEntry and efEntryIndex];
  {if EP^.grp1<>g1_prefix then
    break;}
  Mnem := EP^.Mnem;
  if EP^.grp2=g2_branch then begin
    if EP^.grp3=g3_cond then
      Result := crJCond
    else
      Result := crJmp;
    RegisterCodeRef(Result,1);
    Exit;
  end ;
  if (Mnem=oc_RETN)or(Mnem=oc_RETF)or(Mnem=oc_IRET)or(Mnem=oc_IRETD)or(Mnem=oc_IRETQ) then begin
    Result := crRet;
    Exit;
  end ;
  if (Mnem=oc_CALL)or(Mnem=oc_CALLF) then begin
    Result := -1;
    RegisterCodeRef(crCall,1);
    Exit;
  end ;
  //grp2:g2_branch
  //grp3:g3_cond
  {case Cmd.hCmd of
   hnRet: begin
     Result := crJmp;
     Exit;
    end ;
   hnCall: begin
     Result := -1;
     RegisterCodeRef(crCall,1);
     RegisterCodeRef(crCall,2);
    end ;
   hnJMP: begin
     Result := crJmp;
     RegisterCodeRef(crJmp,1);
    end ;
   hnJ_: begin
     Result := crJCond;
     RegisterCodeRef(crJCond,2);
    end ;
   hnLOOP, hnLOOPE, hnLOOPNE, hnJCXZ: begin
     Result := crJCond;
     RegisterCodeRef(crJCond,1);
    end ;
  else
    Result := -1;
  end ;}
end ;

end .
