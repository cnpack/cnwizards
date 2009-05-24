unit op;
{ Generated automatically from D:\PROLOG\CODES\Opdata2.cmd, 27.10.2002 21:57:36 }

interface

uses DAsmDefs, DAsmUtil;

{$WARNINGS OFF}
{$HINTS OFF}

const
  hnQ = $0 or nf;
  hnRET = $1 or nf;
  hnJMP = $2 or nf;
  hnJ_ = $3 or nf;
  hnLOOP = $4 or nf;
  hnLOOPE = $5 or nf;
  hnLOOPNE = $6 or nf;
  hnJCXZ = $7 or nf;
  hnCALL = $8 or nf;
  hnAL = $9 or nf;
  hnCL = $A or nf;
  hnDL = $B or nf;
  hnBL = $C or nf;
  hnAH = $D or nf;
  hnCH = $E or nf;
  hnDH = $F or nf;
  hnBH = $10 or nf;
  hnAX = $11 or nf;
  hnCX = $12 or nf;
  hnDX = $13 or nf;
  hnBX = $14 or nf;
  hnSP = $15 or nf;
  hnBP = $16 or nf;
  hnSI = $17 or nf;
  hnDI = $18 or nf;
  hnEAX = $19 or nf;
  hnECX = $1A or nf;
  hnEDX = $1B or nf;
  hnEBX = $1C or nf;
  hnESP = $1D or nf;
  hnEBP = $1E or nf;
  hnESI = $1F or nf;
  hnEDI = $20 or nf;
  hnO = $21 or nf;
  hnNO = $22 or nf;
  hnB = $23 or nf;
  hnNB = $24 or nf;
  hnE = $25 or nf;
  hnNE = $26 or nf;
  hnBE = $27 or nf;
  hnA = $28 or nf;
  hnS = $29 or nf;
  hnNS = $2A or nf;
  hnP = $2B or nf;
  hnNP = $2C or nf;
  hnL = $2D or nf;
  hnGE = $2E or nf;
  hnLE = $2F or nf;
  hnG = $30 or nf;
  hnADD = $31 or nf;
  hnOR = $32 or nf;
  hnADC = $33 or nf;
  hnSBB = $34 or nf;
  hnAND = $35 or nf;
  hnSUB = $36 or nf;
  hnXOR = $37 or nf;
  hnCMP = $38 or nf;
  hnDAA = $39 or nf;
  hnDAS = $3A or nf;
  hnAAA = $3B or nf;
  hnAAS = $3C or nf;
  hnINC = $3D or nf;
  hnDEC = $3E or nf;
  hnPUSH = $3F or nf;
  hnPOP = $40 or nf;
  hnMOVSB = $41 or nf;
  hnMOVSW = $42 or nf;
  hnCMPSB = $43 or nf;
  hnCMPSW = $44 or nf;
  hnSTOSB = $45 or nf;
  hnSTOSW = $46 or nf;
  hnLODSB = $47 or nf;
  hnLODSW = $48 or nf;
  hnSCASB = $49 or nf;
  hnSCASW = $4A or nf;
  hnROL = $4B or nf;
  hnROR = $4C or nf;
  hnRCL = $4D or nf;
  hnRCR = $4E or nf;
  hnSHL = $4F or nf;
  hnSHR = $50 or nf;
  hnRAR = $51 or nf;
  hnBT = $52 or nf;
  hnBTS = $53 or nf;
  hnBTR = $54 or nf;
  hnBTC = $55 or nf;
  hnES = $56 or nf;
  hnCS = $57 or nf;
  hnSS = $58 or nf;
  hnDS = $59 or nf;
  hnFS = $5A or nf;
  hnGS = $5B or nf;
  hnNEAR = $5C or nf;
  hnFAR = $5D or nf;
  hnTEST = $5E or nf;
  hnNOT = $5F or nf;
  hnNEG = $60 or nf;
  hnMUL = $61 or nf;
  hnIMUL = $62 or nf;
  hnDIV = $63 or nf;
  hnIDIV = $64 or nf;
  hnSLDT = $65 or nf;
  hnSTR = $66 or nf;
  hnLLDT = $67 or nf;
  hnLTR = $68 or nf;
  hnVERR = $69 or nf;
  hnVERW = $6A or nf;
  hnSGDT = $6B or nf;
  hnSIDT = $6C or nf;
  hnLGDT = $6D or nf;
  hnLIDT = $6E or nf;
  hnSMSW = $6F or nf;
  hnLMSW = $70 or nf;
  hnINVLPG = $71 or nf;
  hnCR0 = $72 or nf;
  hnCR2 = $73 or nf;
  hnCR3 = $74 or nf;
  hnDR0 = $75 or nf;
  hnDR1 = $76 or nf;
  hnDR2 = $77 or nf;
  hnDR3 = $78 or nf;
  hnDR6 = $79 or nf;
  hnDR7 = $7A or nf;
  hnTR3 = $7B or nf;
  hnTR4 = $7C or nf;
  hnTR5 = $7D or nf;
  hnTR6 = $7E or nf;
  hnTR7 = $7F or nf;
  hnLAR = $80 or nf;
  hnLSL = $81 or nf;
  hnLOADALL = $82 or nf;
  hnCLTS = $83 or nf;
  hnINVD = $84 or nf;
  hnWBINVD = $85 or nf;
  hnILLEGAL = $86 or nf;
  hnMOV = $87 or nf;
  hnWRMSR = $88 or nf;
  hnRDTSC = $89 or nf;
  hnRDMSR = $8A or nf;
  hnRDPMC = $8B or nf;
  hnCMOV_ = $8C or nf;
  hnSET_ = $8D or nf;
  hnCPUID = $8E or nf;
  hnSHLD = $8F or nf;
  hnCMPXCHG = $90 or nf;
  hnRSM = $91 or nf;
  hnSHRD = $92 or nf;
  hnLSS = $93 or nf;
  hnLFS = $94 or nf;
  hnLGS = $95 or nf;
  hnMOVZX = $96 or nf;
  hnILLEG1 = $97 or nf;
  hnBSF = $98 or nf;
  hnBSR = $99 or nf;
  hnMOVSX = $9A or nf;
  hnXADD = $9B or nf;
  hnBSWAP = $9C or nf;
  hnST = $9D or nf;
  hnST1 = $9E or nf;
  hnST2 = $9F or nf;
  hnST3 = $A0 or nf;
  hnST4 = $A1 or nf;
  hnST5 = $A2 or nf;
  hnST6 = $A3 or nf;
  hnST7 = $A4 or nf;
  hnCOM = $A5 or nf;
  hnCOMP = $A6 or nf;
  hnSUBR = $A7 or nf;
  hnDIVR = $A8 or nf;
  hnLD = $A9 or nf;
  hnSTP = $AA or nf;
  hnFLDENV = $AB or nf;
  hnFLDCW = $AC or nf;
  hnFSTENV = $AD or nf;
  hnFSTCW = $AE or nf;
  hnFLD = $AF or nf;
  hnFXCH = $B0 or nf;
  hnFNOP = $B1 or nf;
  hnFSTP = $B2 or nf;
  hnFCHS = $B3 or nf;
  hnFABS = $B4 or nf;
  hnFTST = $B5 or nf;
  hnFXAM = $B6 or nf;
  hnFLD1 = $B7 or nf;
  hnFLDL2T = $B8 or nf;
  hnFLDL2E = $B9 or nf;
  hnFLDPI = $BA or nf;
  hnFLDLG2 = $BB or nf;
  hnFLDLN2 = $BC or nf;
  hnFLDZ = $BD or nf;
  hnF2XM1 = $BE or nf;
  hnFYL2X = $BF or nf;
  hnFPTAN = $C0 or nf;
  hnFPATAN = $C1 or nf;
  hnFXTRACT = $C2 or nf;
  hnFPREM = $C3 or nf;
  hnFDECSTP = $C4 or nf;
  hnFINCSTP = $C5 or nf;
  hnFYL2XP1 = $C6 or nf;
  hnFSQRT = $C7 or nf;
  hnFSINCOS = $C8 or nf;
  hnFRNDINT = $C9 or nf;
  hnFSCALE = $CA or nf;
  hnFSIN = $CB or nf;
  hnFCOS = $CC or nf;
  hnFST = $CD or nf;
  hnFENI = $CE or nf;
  hnFDISI = $CF or nf;
  hnFCLEX = $D0 or nf;
  hnFINIT = $D1 or nf;
  hnFSETPM = $D2 or nf;
  hnFSTOR = $D3 or nf;
  hnFSAVE = $D4 or nf;
  hnFSTSW = $D5 or nf;
  hnFFREE = $D6 or nf;
  hnFUCOM = $D7 or nf;
  hnFUCOMP = $D8 or nf;
  hnFBLD = $D9 or nf;
  hnFILD = $DA or nf;
  hnFBSTP = $DB or nf;
  hnFISTP = $DC or nf;
  hnU = $DD or nf;
  hnF = $DE or nf;
  hnFI = $DF or nf;
  hnFCMOV_ = $E0 or nf;
  hnFUCOMPP = $E1 or nf;
  hnFCMOVN_ = $E2 or nf;
  hnFUCOMI = $E3 or nf;
  hnFCOMI = $E4 or nf;
  hnFUCOMIP = $E5 or nf;
  hnFCOMIP = $E6 or nf;
  hnFWAIT = $E7 or nf;
  hnPUSHA = $E8 or nf;
  hnPOPA = $E9 or nf;
  hnBOUND = $EA or nf;
  hnARPL = $EB or nf;
  hnINSB = $EC or nf;
  hnINSW = $ED or nf;
  hnOUTSB = $EE or nf;
  hnOUTSW = $EF or nf;
  hnXCHG = $F0 or nf;
  hnLEA = $F1 or nf;
  hnNOP = $F2 or nf;
  hnCBW = $F3 or nf;
  hnCWD = $F4 or nf;
  hnWAIT = $F5 or nf;
  hnPUSHF = $F6 or nf;
  hnPOPF = $F7 or nf;
  hnSAHF = $F8 or nf;
  hnLAHF = $F9 or nf;
  hnLES = $FA or nf;
  hnLDS = $FB or nf;
  hnENTER = $FC or nf;
  hnLEAVE = $FD or nf;
  hnINT = $FE or nf;
  hnINTO = $FF or nf;
  hnIRET = $100 or nf;
  hnAAM = $101 or nf;
  hnAAD = $102 or nf;
  hnXLAT = $103 or nf;
  hnESC = $104 or nf;
  hnIN = $105 or nf;
  hnOUT = $106 or nf;
  hnLOCK = $107 or nf;
  hnREPNE = $108 or nf;
  hnREPE = $109 or nf;
  hnHALT = $10A or nf;
  hnCMC = $10B or nf;
  hnCLC = $10C or nf;
  hnSTC = $10D or nf;
  hnCLI = $10E or nf;
  hnSTI = $10F or nf;
  hnCLD = $110 or nf;
  hnSTD = $111 or nf;

function GetOpName(hName: THBMName):TBMOpRec;

const
  ntRegB: array[0..8-1]of THBMName = (
    hnAL, hnCL, hnDL, hnBL, hnAH, hnCH, hnDH, hnBH
  );

const
  ntReg16: array[0..8-1]of THBMName = (
    hnAX, hnCX, hnDX, hnBX, hnSP, hnBP, hnSI, hnDI
  );

const
  ntReg32: array[0..8-1]of THBMName = (
    hnEAX, hnECX, hnEDX, hnEBX, hnESP, hnEBP, hnESI, hnEDI
  );

function readOP: boolean;

implementation

const
  BMNames: array[0..274-1] of TBMOpRec = (
    {0x0}'?','RET','JMP','J_','LOOP','LOOPE','LOOPNE','JCXZ',
    {0x8}'CALL','AL','CL','DL','BL','AH','CH','DH',
    {0x10}'BH','AX','CX','DX','BX','SP','BP','SI',
    {0x18}'DI','EAX','ECX','EDX','EBX','ESP','EBP','ESI',
    {0x20}'EDI','O','NO','B','NB','E','NE','BE',
    {0x28}'A','S','NS','P','NP','L','GE','LE',
    {0x30}'G','ADD','OR','ADC','SBB','AND','SUB','XOR',
    {0x38}'CMP','DAA','DAS','AAA','AAS','INC','DEC','PUSH',
    {0x40}'POP','MOVSB','MOVSW','CMPSB','CMPSW','STOSB','STOSW','LODSB',
    {0x48}'LODSW','SCASB','SCASW','ROL','ROR','RCL','RCR','SHL',
    {0x50}'SHR','RAR','BT','BTS','BTR','BTC','ES','CS',
    {0x58}'SS','DS','FS','GS','NEAR','FAR','TEST','NOT',
    {0x60}'NEG','MUL','IMUL','DIV','IDIV','SLDT','STR','LLDT',
    {0x68}'LTR','VERR','VERW','SGDT','SIDT','LGDT','LIDT','SMSW',
    {0x70}'LMSW','INVLPG','CR0','CR2','CR3','DR0','DR1','DR2',
    {0x78}'DR3','DR6','DR7','TR3','TR4','TR5','TR6','TR7',
    {0x80}'LAR','LSL','LOADALL','CLTS','INVD','WBINVD','ILLEGAL','MOV',
    {0x88}'WRMSR','RDTSC','RDMSR','RDPMC','CMOV_','SET_','CPUID','SHLD',
    {0x90}'CMPXCHG','RSM','SHRD','LSS','LFS','LGS','MOVZX','ILLEG1',
    {0x98}'BSF','BSR','MOVSX','XADD','BSWAP','ST','ST1','ST2',
    {0xA0}'ST3','ST4','ST5','ST6','ST7','COM','COMP','SUBR',
    {0xA8}'DIVR','LD','STP','FLDENV','FLDCW','FSTENV','FSTCW','FLD',
    {0xB0}'FXCH','FNOP','FSTP','FCHS','FABS','FTST','FXAM','FLD1',
    {0xB8}'FLDL2T','FLDL2E','FLDPI','FLDLG2','FLDLN2','FLDZ','F2XM1','FYL2X',
    {0xC0}'FPTAN','FPATAN','FXTRACT','FPREM','FDECSTP','FINCSTP','FYL2XP1','FSQRT',
    {0xC8}'FSINCOS','FRNDINT','FSCALE','FSIN','FCOS','FST','FENI','FDISI',
    {0xD0}'FCLEX','FINIT','FSETPM','FSTOR','FSAVE','FSTSW','FFREE','FUCOM',
    {0xD8}'FUCOMP','FBLD','FILD','FBSTP','FISTP','U','F','FI',
    {0xE0}'FCMOV_','FUCOMPP','FCMOVN_','FUCOMI','FCOMI','FUCOMIP','FCOMIP','FWAIT',
    {0xE8}'PUSHA','POPA','BOUND','ARPL','INSB','INSW','OUTSB','OUTSW',
    {0xF0}'XCHG','LEA','NOP','CBW','CWD','WAIT','PUSHF','POPF',
    {0xF8}'SAHF','LAHF','LES','LDS','ENTER','LEAVE','INT','INTO',
    {0x100}'IRET','AAM','AAD','XLAT','ESC','IN','OUT','LOCK',
    {0x108}'REPNE','REPE','HALT','CMC','CLC','STC','CLI','STI',
    {0x110}'CLD','STD'
  );

function GetOpName(hName: THBMName):TBMOpRec;
begin
  hName := hName and nm;
  if (hName<0)or(hName>High(BMNames)) then
    Result := ''
  else
    Result := BMNames[hName];
end ;

function RegW(R: integer; var RN: integer): boolean;
var
  OS: integer;
begin
  Result := false;
  OS := getOS;
  case OS of
    $0: RN := ntReg16[R];
    $1: RN := ntReg32[R];
    else Exit;
  end;
  Result := true;
end ;

function Reg(W,R: integer; var RN: integer): boolean;
begin
  Result := false;
  case W of
    $0: RN := ntRegB[R];
    $1: if not RegW(R,RN) then Exit;
    else Exit;
  end;
  Result := true;
end ;

function JmpOfsW: boolean;
begin
  Result := false;
  if not jmpOfs(1+getOS) then Exit;
  Result := true;
end ;

const
  ntJmpCond: array[0..16-1]of THBMName = (
    hnO, hnNO, hnB, hnNB, hnE, hnNE, hnBE, hnA, hnS, hnNS, hnP, hnNP, hnL, hnGE, hnLE, hnG
  );

const
  ntArOp: array[0..8-1]of THBMName = (
    hnADD, hnOR, hnADC, hnSBB, hnAND, hnSUB, hnXOR, hnCMP
  );

const
  ntDecArOp: array[0..4-1]of THBMName = (
    hnDAA, hnDAS, hnAAA, hnAAS
  );

const
  ntIDPPS: array[0..4-1]of THBMName = (
    hnINC, hnDEC, hnPUSH, hnPOP
  );

const
  ntStrOp1: array[0..4-1]of THBMName = (
    hnMOVSB, hnMOVSW, hnCMPSB, hnCMPSW
  );

const
  ntStrOp2: array[0..8-1]of THBMName = (
    hnQ, hnQ, hnSTOSB, hnSTOSW, hnLODSB, hnLODSW, hnSCASB, hnSCASW
  );

const
  ntShftOp: array[0..8-1]of THBMName = (
    hnROL, hnROR, hnRCL, hnRCR, hnSHL, hnSHR, hnQ, hnRAR
  );

const
  ntBtOp: array[0..8-1]of THBMName = (
    hnQ, hnQ, hnQ, hnQ, hnBT, hnBTS, hnBTR, hnBTC
  );

const
  ntSReg: array[0..8-1]of THBMName = (
    hnES, hnCS, hnSS, hnDS, hnFS, hnGS, hnQ, hnQ
  );

const
  ntcallDist: array[0..2-1]of THBMName = (
    hnNEAR, hnFAR
  );

const
  ntLoopS: array[0..4-1]of THBMName = (
    hnLOOPNE, hnLOOPE, hnLOOP, hnJCXZ
  );

const
  ntGr1Op: array[0..8-1]of THBMName = (
    hnTEST, hnQ, hnNOT, hnNEG, hnMUL, hnIMUL, hnDIV, hnIDIV
  );

const
  ntGr2Op: array[0..4-1]of THBMName = (
    hnQ, hnCALL, hnJMP, hnQ
  );

const
  ntGr3Op: array[0..2-1]of THBMName = (
    hnINC, hnDEC
  );

const
  ntGr6Op: array[0..8-1]of THBMName = (
    hnSLDT, hnSTR, hnLLDT, hnLTR, hnVERR, hnVERW, hnQ, hnQ
  );

const
  ntGr7Op: array[0..8-1]of THBMName = (
    hnSGDT, hnSIDT, hnLGDT, hnLIDT, hnSMSW, hnQ, hnLMSW, hnINVLPG
  );

const
  ntCReg: array[0..8-1]of THBMName = (
    hnCR0, hnQ, hnCR2, hnCR3, hnQ, hnQ, hnQ, hnQ
  );

const
  ntDReg: array[0..8-1]of THBMName = (
    hnDR0, hnDR1, hnDR2, hnDR3, hnQ, hnQ, hnDR6, hnDR7
  );

const
  ntTReg: array[0..8-1]of THBMName = (
    hnQ, hnQ, hnQ, hnTR3, hnTR4, hnTR5, hnTR6, hnTR7
  );

function getEAV(W: integer; var M,A: integer): boolean;
begin
  Result := false;
  case W and $1 of
    $0: ;
    else W := 1+getOS;
  end;
  if not getEA(W,M,A) then Exit;
  Result := true;
end ;

function readEA(W: integer; var M: integer): boolean;
var
  A: integer;
begin
  Result := false;
  if not getEAV(W,M,A) then Exit;
  SetCmdArg(A);
  Result := true;
end ;

function imW(W: integer): boolean;
begin
  Result := false;
  case W and $1 of
    $0: if not ImmedBW(0) then Exit;
    else if not ImmedBW(1+getOS) then Exit;
  end;
  Result := true;
end ;

function imSignExt(S,W: integer): boolean;
begin
  Result := false;
  case S of
    $0: if not imW(W) then Exit;
    $1: if not imInt(0) then Exit;
    else Exit;
  end;
  Result := true;
end ;

function xchgArg(D,A1,A2: integer): boolean;
begin
  Result := false;
  case D of
    $0: begin
        SetCmdArg(A1);
        SetCmdArg(A2);
      end;
    $1: begin
        SetCmdArg(A2);
        SetCmdArg(A1);
      end;
    else Exit;
  end;
  Result := true;
end ;

function readRMD(W: integer): boolean;
var
  R,A: integer;
var
  _1: integer;
begin
  Result := false;
  if not getEAV(W,R,A) then Exit;
  if not Reg(W,R,_1) then Exit;
  SetCmdArg(_1);
  SetCmdArg(A);
  Result := true;
end ;

function readRMR(W: integer): boolean;
var
  R,A: integer;
var
  _1: integer;
begin
  Result := false;
  if not getEAV(W,R,A) then Exit;
  SetCmdArg(A);
  if not Reg(W,R,_1) then Exit;
  SetCmdArg(_1);
  Result := true;
end ;

function readRM(R,W: integer): boolean;
begin
  Result := false;
  case R of
    $0: if not readRMR(W) then Exit;
    $1: if not readRMD(W) then Exit;
    else Exit;
  end;
  Result := true;
end ;

function readSRM(Rev: integer): boolean;
var
  R,A: integer;
begin
  Result := false;
  if not getEA(1,R,A) then Exit;
  case Rev of
    $0: begin
        SetCmdArg(A);
        SetCmdArg(ntSReg[R]);
      end;
    $1: begin
        SetCmdArg(ntSReg[R]);
        SetCmdArg(A);
      end;
    else Exit;
  end;
  Result := true;
end ;

function ReadRMWD(W: integer): boolean;
var
  R,A: integer;
var
  _1: integer;
begin
  Result := false;
  if not getEA(W,R,A) then Exit;
  if not RegW(R,_1) then Exit;
  SetCmdArg(_1);
  SetCmdArg(A);
  Result := true;
end ;

function ReadMIm(W: integer): boolean;
var
  R,A: integer;
begin
  Result := false;
  if not getEAV(W,R,A) then Exit;
  SetCmdArg(A);
  if not imW(W) then Exit;
  Result := true;
end ;

function CurSeg: boolean;
var
  S: integer;
begin
  Result := false;
  S := getSeg;
  case S and $F of
    $8: ;
    else SetCmdArg(ntSReg[S]);
  end;
  Result := true;
end ;

function ReadPM: boolean;
var
  B0,M,A,B1,C,R,D,W: integer;
var
  _1: integer;

const
  _C0: array[0..$FF] of integer = (
    {0x00}  0,  1,  2,  3, 50,  4,  5, 50,  6,  7, 50,  8, 50, 50, 50, 50,
    {0x10} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x20}  9, 10, 11, 12, 13, 50, 14, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x30} 15, 16, 17, 18, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x40} 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
    {0x50} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x60} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x70} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x80} 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
    {0x90} 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    {0xA0} 22, 23, 24, 25, 26, 27, 28, 28, 29, 30, 31, 32, 33, 34, 50, 35,
    {0xB0} 36, 36, 37, 38, 39, 40, 41, 41, 50, 42, 43, 44, 45, 46, 47, 47,
    {0xC0} 48, 48, 50, 50, 50, 50, 50, 50, 49, 49, 49, 49, 49, 49, 49, 49,
    {0xD0} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0xE0} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0xF0} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50
  );

begin
  Result := false;
  if not ReadByte(B0) then Exit;
  case _C0[B0 and $FF] of
    0: begin
        if not getEA(1,M,A) then Exit;
        SetOpName(ntGr6Op[M]);
        SetCmdArg(A);
      end;
    1: begin
        if not getEA(1,M,A) then Exit;
        SetOpName(ntGr7Op[M]);
        SetCmdArg(A);
      end;
    2: begin
        SetOpName(hnLAR);
        if not readRMD(1) then Exit;
      end;
    3: begin
        SetOpName(hnLSL);
        if not readRMD(1) then Exit;
      end;
    4: SetOpName(hnLOADALL);
    5: SetOpName(hnCLTS);
    6: SetOpName(hnINVD);
    7: SetOpName(hnWBINVD);
    8: SetOpName(hnILLEGAL);
    9: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntReg32[R]);
        SetCmdArg(ntCReg[C]);
      end;
    10: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntReg32[R]);
        SetCmdArg(ntDReg[C]);
      end;
    11: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntCReg[C]);
        SetCmdArg(ntReg32[R]);
      end;
    12: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntDReg[C]);
        SetCmdArg(ntReg32[R]);
      end;
    13: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntReg32[R]);
        SetCmdArg(ntTReg[C]);
      end;
    14: begin
        if not ReadByte(B1) then Exit;
        case B1 and $C0 of
          $C0: begin
              C := (B1 and $38)shr 3;
              R := B1 and $7;
            end;
          else Exit;
        end;
        SetOpName(hnMOV);
        SetCmdArg(ntTReg[C]);
        SetCmdArg(ntReg32[R]);
      end;
    15: SetOpName(hnWRMSR);
    16: SetOpName(hnRDTSC);
    17: SetOpName(hnRDMSR);
    18: SetOpName(hnRDPMC);
    19: begin
        D := B0 and $F;
        SetOpName(hnCMOV_);
        SetCmdArg(ntJmpCond[D]);
        if not readRMD(1) then Exit;
      end;
    20: begin
        D := B0 and $F;
        SetOpName(hnJ_);
        SetCmdArg(ntJmpCond[D]);
        if not JmpOfsW then Exit;
      end;
    21: begin
        D := B0 and $F;
        SetOpName(hnSET_);
        SetCmdArg(ntJmpCond[D]);
        if not readEA(0,M) then Exit;
      end;
    22: begin
        SetOpName(hnPUSH);
        SetCmdArg(hnFS);
      end;
    23: begin
        SetOpName(hnPOP);
        SetCmdArg(hnFS);
      end;
    24: SetOpName(hnCPUID);
    25: begin
        SetOpName(hnBT);
        if not readRMD(1) then Exit;
      end;
    26: begin
        SetOpName(hnSHLD);
        if not readRMR(1) then Exit;
        if not ImmedBW(0) then Exit;
      end;
    27: begin
        SetOpName(hnSHLD);
        if not readRMR(1) then Exit;
        SetCmdArg(hnCL);
      end;
    28: begin
        D := B0 and $1;
        SetOpName(hnCMPXCHG);
        if not readRMD(D) then Exit;
      end;
    29: begin
        SetOpName(hnPUSH);
        SetCmdArg(hnGS);
      end;
    30: begin
        SetOpName(hnPOP);
        SetCmdArg(hnGS);
      end;
    31: SetOpName(hnRSM);
    32: begin
        SetOpName(hnBTS);
        if not readRMR(1) then Exit;
      end;
    33: begin
        SetOpName(hnSHRD);
        if not readRMR(1) then Exit;
        if not ImmedBW(0) then Exit;
      end;
    34: begin
        SetOpName(hnSHRD);
        if not readRMR(1) then Exit;
        SetCmdArg(hnCL);
      end;
    35: begin
        SetOpName(hnIMUL);
        if not readRMD(1) then Exit;
      end;
    36: begin
        D := B0 and $1;
        SetOpName(hnCMPXCHG);
        if not readRMD(D) then Exit;
      end;
    37: begin
        SetOpName(hnLSS);
        if not ReadRMWD(2) then Exit;
      end;
    38: begin
        SetOpName(hnBTR);
        if not readRMR(1) then Exit;
      end;
    39: begin
        SetOpName(hnLFS);
        if not ReadRMWD(2) then Exit;
      end;
    40: begin
        SetOpName(hnLGS);
        if not ReadRMWD(2) then Exit;
      end;
    41: begin
        W := B0 and $1;
        SetOpName(hnMOVZX);
        if not ReadRMWD(W) then Exit;
      end;
    42: SetOpName(hnILLEG1);
    43: begin
        if not readEA(1,_1) then Exit;
        SetOpName(ntBtOp[_1]);
        if not ImmedBW(0) then Exit;
      end;
    44: begin
        SetOpName(hnBTC);
        if not readRMR(1) then Exit;
      end;
    45: begin
        SetOpName(hnBSF);
        if not readRMD(1) then Exit;
      end;
    46: begin
        SetOpName(hnBSR);
        if not readRMD(1) then Exit;
      end;
    47: begin
        W := B0 and $1;
        SetOpName(hnMOVSX);
        if not ReadRMWD(W) then Exit;
      end;
    48: begin
        W := B0 and $1;
        SetOpName(hnXADD);
        if not readRMD(W) then Exit;
      end;
    49: begin
        R := B0 and $7;
        SetOpName(hnBSWAP);
        if not RegW(R,_1) then Exit;
        SetCmdArg(_1);
      end;
    else SetOpName(hnQ);
  end;
  Result := true;
end ;

const
  ntFPReg: array[0..8-1]of THBMName = (
    hnST, hnST1, hnST2, hnST3, hnST4, hnST5, hnST6, hnST7
  );

const
  ntfops: array[0..8-1]of THBMName = (
    hnADD, hnMUL, hnCOM, hnCOMP, hnSUB, hnSUBR, hnDIV, hnDIVR
  );

const
  ntflsops: array[0..4-1]of THBMName = (
    hnLD, hnQ, hnST, hnSTP
  );

const
  ntfEsc1s: array[0..4-1]of THBMName = (
    hnFLDENV, hnFLDCW, hnFSTENV, hnFSTCW
  );

const
  ntfEsc1s1: array[0..4-1]of THBMName = (
    hnFLD, hnFXCH, hnFNOP, hnFSTP
  );

const
  ntfEsc1s2: array[0..32-1]of THBMName = (
    hnFCHS, hnFABS, hnQ, hnQ, hnFTST, hnFXAM, hnQ, hnQ, hnFLD1, hnFLDL2T, hnFLDL2E, hnFLDPI, hnFLDLG2, hnFLDLN2, hnFLDZ, hnQ, hnF2XM1, hnFYL2X, hnFPTAN, hnFPATAN, hnFXTRACT, hnFPREM, hnFDECSTP, hnFINCSTP, hnFPREM, hnFYL2XP1, hnFSQRT, hnFSINCOS, hnFRNDINT, hnFSCALE, hnFSIN, hnFCOS
  );

const
  ntfEsc3s: array[0..4-1]of THBMName = (
    hnQ, hnFLD, hnQ, hnFST
  );

const
  ntfEsc3s1: array[0..8-1]of THBMName = (
    hnFENI, hnFDISI, hnFCLEX, hnFINIT, hnFSETPM, hnQ, hnQ, hnQ
  );

const
  ntfEsc5s: array[0..4-1]of THBMName = (
    hnFSTOR, hnQ, hnFSAVE, hnFSTSW
  );

const
  ntfEsc5s1: array[0..8-1]of THBMName = (
    hnFFREE, hnQ, hnFST, hnFSTP, hnFUCOM, hnFUCOMP, hnQ, hnQ
  );

const
  ntfopEsc6s: array[0..8-1]of THBMName = (
    hnADD, hnMUL, hnQ, hnCOMP, hnSUBR, hnSUB, hnDIVR, hnDIV
  );

const
  ntfEsc7s: array[0..4-1]of THBMName = (
    hnFBLD, hnFILD, hnFBSTP, hnFISTP
  );

const
  ntfcond: array[0..4-1]of THBMName = (
    hnB, hnE, hnBE, hnU
  );

function PutSt(M: integer): boolean;
var
  Y: integer;
begin
  Result := false;
  case M and $6 of
    $2: begin
        Y := M and $1;
      end;
    else SetCmdArg(hnST);
  end;
  Result := true;
end ;

const
  ntFPType: array[0..2-1]of THBMName = (
    hnF, hnFI
  );

function SizeEven(C: integer): boolean;
var
  L: integer;
begin
  Result := false;
  if (C and $4)=$0 then begin
     L := C and $3;
     setEASize(3);
   end
  else if (C and $6)=$4 then begin
     L := C and $1;
     setEASize(4);
   end
  else if (C and $6)=$6 then begin
     L := C and $1;
     setEASize(2);
   end
  else 
    Exit;
  Result := true;
end ;

function readFP(B: integer): boolean;
var
  X,C,NextB,M,R,Y,A,T,N: integer;
begin
  Result := false;
  begin
    X := (B and $F8)shr 3;
    C := B and $7;
  end;
  if not ReadByte(NextB) then Exit;
  case NextB and $C0 of
    $C0: begin
        M := (NextB and $38)shr 3;
        R := NextB and $7;
        case C and $F of
          $0: begin
              SetPrefix(hnF);
              SetOpName(ntfops[M]);
              if not PutSt(M) then Exit;
              SetCmdArg(ntFPReg[R]);
            end;
          $1: case NextB and $E0 of
              $E0: begin
                  Y := NextB and $1F;
                  SetOpName(ntfEsc1s2[Y]);
                end;
              else begin
                  SetOpName(ntfEsc1s1[M]);
                  SetCmdArg(ntFPReg[R]);
                end;
            end;
          $2: if (NextB and $E0)=$C0 then begin
               Y := (NextB and $18)shr 3;
               R := NextB and $7;
               SetOpName(hnFCMOV_);
               SetCmdArg(ntfcond[Y]);
               SetCmdArg(hnST);
               SetCmdArg(ntFPReg[R]);
             end
            else if (NextB and $F8)=$E8 then begin
               Y := NextB and $7;
               SetOpName(hnFUCOMPP);
             end
            else 
              Exit;
          $3: if (NextB and $E0)=$C0 then begin
               Y := (NextB and $18)shr 3;
               R := NextB and $7;
               SetOpName(hnFCMOVN_);
               SetCmdArg(ntfcond[Y]);
               SetCmdArg(hnST);
               SetCmdArg(ntFPReg[R]);
             end
            else if (NextB and $F8)=$E0 then begin
               Y := NextB and $7;
               SetOpName(ntfEsc3s1[Y]);
             end
            else if (NextB and $F8)=$E8 then begin
               R := NextB and $7;
               SetOpName(hnFUCOMI);
               SetCmdArg(hnST);
               SetCmdArg(ntFPReg[R]);
             end
            else if (NextB and $F8)=$F0 then begin
               R := NextB and $7;
               SetOpName(hnFCOMI);
               SetCmdArg(hnST);
               SetCmdArg(ntFPReg[R]);
             end
            else 
              Exit;
          $4: begin
              SetPrefix(hnF);
              SetOpName(ntfops[M]);
              SetCmdArg(ntFPReg[R]);
              if not PutSt(M) then Exit;
            end;
          $5: begin
              SetOpName(ntfEsc5s1[M]);
              SetCmdArg(ntFPReg[R]);
            end;
          $6: begin
              SetPrefix(hnF);
              SetOpName(ntfopEsc6s[M]);
              SetSuffix(hnP);
              SetCmdArg(ntFPReg[R]);
              if not PutSt(M) then Exit;
            end;
          $7: case NextB and $F8 of
              $E0: begin
                  Y := NextB and $7;
                  SetOpName(hnFSTSW);
                  SetCmdArg(ntReg16[R]);
                end;
              $E8: begin
                  R := NextB and $7;
                  SetOpName(hnFUCOMIP);
                  SetCmdArg(hnST);
                  SetCmdArg(ntFPReg[R]);
                end;
              $F0: begin
                  R := NextB and $7;
                  SetOpName(hnFCOMIP);
                  SetCmdArg(hnST);
                  SetCmdArg(ntFPReg[R]);
                end;
              else Exit;
            end;
          else Exit;
        end;
      end;
    else begin
        if not UnReadByte then Exit;
        if not getEA(1,M,A) then Exit;
        setEASize(0);
        SetCmdArg(A);
        case C and $1 of
          $0: begin
              Y := (C and $4)shr 2;
              T := (C and $2)shr 1;
              SetPrefix(ntFPType[T]);
              if not SizeEven(C) then Exit;
              SetOpName(ntfops[M]);
            end;
          else case M and $4 of
              $0: begin
                  N := M and $3;
                  begin
                    Y := C and $1 + (C and $4)shr 1;
                    T := (C and $2)shr 1;
                  end;
                  SetPrefix(ntFPType[T]);
                  if not SizeEven(C) then Exit;
                  SetOpName(ntflsops[M]);
                end;
              $4: begin
                  N := M and $3;
                  begin
                    Y := (C and $6)shr 1;
                    T := C and $1;
                  end;
                  case Y and $F of
                    $0: SetOpName(ntfEsc1s[N]);
                    $1: begin
                        SetOpName(ntfEsc3s[N]);
                        setEASize(5);
                      end;
                    $2: SetOpName(ntfEsc5s[N]);
                    $3: begin
                        SetOpName(ntfEsc7s[N]);
                        case N and $1 of
                          $0: begin
                              Y := (N and $2)shr 1;
                              setEASize(4);
                            end;
                          else setEASize(5);
                        end;
                      end;
                    else Exit;
                  end;
                end;
              else Exit;
            end;
        end;
      end;
  end;
  Result := true;
end ;

function readFPEmul(B: integer): boolean;
var
  B1,C,S,X: integer;
var
  _1: integer;
begin
  Result := false;
  B1 := B-52;
  if (B1 and $F8)=$0 then begin
     C := B1 and $7;
     if not readFP(B1) then Exit;
   end
  else if (B1 and $FF)=$8 then begin
     if not ReadByte(C) then Exit;
     case C and $38 of
       $18: begin
           S := (C and $C0)shr 6;
           X := C and $7;
           setSeg(not(S));
           if not ReadByte(_1) then Exit;
           if not readFP(_1) then Exit;
         end;
       else Exit;
     end;
   end
  else if (B1 and $FF)=$9 then SetOpName(hnFWAIT)
  else 
    Exit;
  Result := true;
end ;

function readOP: boolean;
var
  B1,A,D,W,S,R,C,F,B2,N,L,H: integer;
var
  _1, _2: integer;

const
  _C0: array[0..$FF] of integer = (
    {0x00}  0,  0,  0,  0,  1,  1,  3,  4,  0,  0,  0,  0,  1,  1,  3,  2,
    {0x10}  0,  0,  0,  0,  1,  1,  3,  4,  0,  0,  0,  0,  1,  1,  3,  4,
    {0x20}  0,  0,  0,  0,  1,  1,  5,  6,  0,  0,  0,  0,  1,  1,  5,  6,
    {0x30}  0,  0,  0,  0,  1,  1,  5,  6,  0,  0,  0,  0,  1,  1,  5,  6,
    {0x40}  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
    {0x50}  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
    {0x60}  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 16, 17, 18, 19, 20, 21,
    {0x70} 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
    {0x80} 23, 23, 23, 23, 24, 24, 25, 25, 26, 26, 26, 26, 27, 28, 27, 29,
    {0x90} 30, 31, 31, 31, 31, 31, 31, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    {0xA0} 40, 40, 40, 40, 41, 41, 41, 41, 42, 42, 43, 43, 43, 43, 43, 43,
    {0xB0} 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44,
    {0xC0} 45, 45, 46, 47, 48, 49, 50, 50, 51, 52, 46, 47, 53, 54, 55, 56,
    {0xD0} 57, 57, 58, 58, 59, 60, 85, 61, 62, 62, 62, 62, 62, 62, 62, 62,
    {0xE0} 63, 63, 63, 63, 64, 64, 65, 65, 66, 67, 68, 69, 70, 70, 71, 71,
    {0xF0} 72, 85, 73, 74, 75, 76, 77, 77, 78, 79, 80, 81, 82, 83, 84, 84
  );

begin
  Result := false;
  if not ReadByte(B1) then Exit;
  case _C0[B1 and $FF] of
    0: begin
        A := (B1 and $38)shr 3;
        D := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(ntArOp[A]);
        if not readRM(D,W) then Exit;
      end;
    1: begin
        A := (B1 and $38)shr 3;
        W := B1 and $1;
        SetOpName(ntArOp[A]);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        if not imW(W) then Exit;
      end;
    2: if not ReadPM then Exit;
    3: begin
        S := (B1 and $18)shr 3;
        SetOpName(hnPUSH);
        SetCmdArg(ntSReg[S]);
      end;
    4: begin
        S := (B1 and $18)shr 3;
        SetOpName(hnPOP);
        SetCmdArg(ntSReg[S]);
      end;
    5: begin
        S := (B1 and $18)shr 3;
        setSeg(S);
        if not readOP then Exit;
      end;
    6: begin
        S := (B1 and $18)shr 3;
        SetOpName(ntDecArOp[S]);
      end;
    7: begin
        A := (B1 and $18)shr 3;
        R := B1 and $7;
        SetOpName(ntIDPPS[A]);
        if not RegW(R,_1) then Exit;
        SetCmdArg(_1);
      end;
    8: SetOpName(hnPUSHA);
    9: SetOpName(hnPOPA);
    10: begin
        SetOpName(hnBOUND);
        if not readRMD(1) then Exit;
      end;
    11: SetOpName(hnARPL);
    12: begin
        setSeg(4);
        if not readOP then Exit;
      end;
    13: begin
        setSeg(5);
        if not readOP then Exit;
      end;
    14: begin
        setOS;
        if not readOP then Exit;
      end;
    15: begin
        setAS;
        if not readOP then Exit;
      end;
    16: begin
        W := (B1 and $2)shr 1;
        SetOpName(hnPUSH);
        if not imW(not(W)) then Exit;
      end;
    17: begin
        W := (B1 and $2)shr 1;
        SetOpName(hnIMUL);
        if not ReadMIm(not(W)) then Exit;
      end;
    18: SetOpName(hnINSB);
    19: SetOpName(hnINSW);
    20: SetOpName(hnOUTSB);
    21: SetOpName(hnOUTSW);
    22: begin
        D := B1 and $F;
        SetOpName(hnJ_);
        SetCmdArg(ntJmpCond[D]);
        if not jmpOfs(0) then Exit;
      end;
    23: begin
        S := (B1 and $2)shr 1;
        W := B1 and $1;
        if not readEA(W,_1) then Exit;
        SetOpName(ntArOp[_1]);
        if not imSignExt(S,W) then Exit;
      end;
    24: begin
        W := B1 and $1;
        SetOpName(hnTEST);
        if not readRMR(W) then Exit;
      end;
    25: begin
        W := B1 and $1;
        SetOpName(hnXCHG);
        if not readRMD(W) then Exit;
      end;
    26: begin
        D := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(hnMOV);
        if not readRM(D,W) then Exit;
      end;
    27: begin
        D := (B1 and $2)shr 1;
        SetOpName(hnMOV);
        if not readSRM(D) then Exit;
      end;
    28: begin
        SetOpName(hnLEA);
        if not readRMD(1) then Exit;
      end;
    29: begin
        SetOpName(hnPOP);
        if not readEA(1,C) then Exit;
      end;
    30: SetOpName(hnNOP);
    31: begin
        R := B1 and $7;
        SetOpName(hnXCHG);
        if not RegW(0,_1) then Exit;
        SetCmdArg(_1);
        if not RegW(R,_1) then Exit;
        SetCmdArg(_1);
      end;
    32: SetOpName(hnCBW);
    33: SetOpName(hnCWD);
    34: begin
        SetOpName(hnCALL);
        if not imPtr then Exit;
      end;
    35: SetOpName(hnWAIT);
    36: SetOpName(hnPUSHF);
    37: SetOpName(hnPOPF);
    38: SetOpName(hnSAHF);
    39: SetOpName(hnLAHF);
    40: begin
        D := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(hnMOV);
        if not Reg(W,0,_1) then Exit;
        if not getImmOfsEA(W,_2) then Exit;
        if not xchgArg(D,_1,_2) then Exit;
      end;
    41: begin
        A := B1 and $3;
        SetOpName(ntStrOp1[A]);
        if not CurSeg then Exit;
      end;
    42: begin
        W := B1 and $1;
        SetOpName(hnTEST);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        if not imW(W) then Exit;
      end;
    43: begin
        A := B1 and $7;
        SetOpName(ntStrOp2[A]);
        if not CurSeg then Exit;
      end;
    44: begin
        W := (B1 and $8)shr 3;
        R := B1 and $7;
        SetOpName(hnMOV);
        if not Reg(W,R,_1) then Exit;
        SetCmdArg(_1);
        if not imW(W) then Exit;
      end;
    45: begin
        W := B1 and $1;
        if not readEA(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        if not ImmedBW(0) then Exit;
      end;
    46: begin
        F := (B1 and $8)shr 3;
        SetOpName(hnRET);
        SetCmdArg(ntcallDist[F]);
        if not imInt(1) then Exit;
      end;
    47: begin
        F := (B1 and $8)shr 3;
        SetOpName(hnRET);
        SetCmdArg(ntcallDist[F]);
      end;
    48: begin
        SetOpName(hnLES);
        if not ReadRMWD(2) then Exit;
      end;
    49: begin
        SetOpName(hnLDS);
        if not ReadRMWD(2) then Exit;
      end;
    50: begin
        W := B1 and $1;
        SetOpName(hnMOV);
        if not ReadMIm(W) then Exit;
      end;
    51: begin
        SetOpName(hnENTER);
        if not imInt(1) then Exit;
        if not imInt(0) then Exit;
      end;
    52: SetOpName(hnLEAVE);
    53: begin
        SetOpName(hnINT);
        SetCmdArg(3);
      end;
    54: begin
        if not ReadByte(B2) then Exit;
        if {***}not(readFPEmul(B2)) then begin
          SetOpName(hnINT);
          SetCmdArg(B2);
        end;
      end;
    55: SetOpName(hnINTO);
    56: SetOpName(hnIRET);
    57: begin
        W := B1 and $1;
        if not readEA(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        SetCmdArg(1);
      end;
    58: begin
        W := B1 and $1;
        if not readEA(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        SetCmdArg(hnCL);
      end;
    59: SetOpName(hnAAM);
    60: SetOpName(hnAAD);
    61: SetOpName(hnXLAT);
    62: begin
        N := B1 and $7;
        if {***}not(readFP(N)) then begin
          SetOpName(hnESC);
          SetCmdArg(N);
        end;
      end;
    63: begin
        L := B1 and $3;
        SetOpName(ntLoopS[L]);
        if not jmpOfs(0) then Exit;
      end;
    64: begin
        W := B1 and $1;
        SetOpName(hnIN);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        if not ImmedBW(0) then Exit;
      end;
    65: begin
        W := B1 and $1;
        SetOpName(hnOUT);
        if not ImmedBW(0) then Exit;
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
      end;
    66: begin
        SetOpName(hnCALL);
        if not JmpOfsW then Exit;
      end;
    67: begin
        SetOpName(hnJMP);
        if not JmpOfsW then Exit;
      end;
    68: begin
        SetOpName(hnJMP);
        if not imPtr then Exit;
      end;
    69: begin
        SetOpName(hnJMP);
        if not jmpOfs(0) then Exit;
      end;
    70: begin
        W := B1 and $1;
        SetOpName(hnIN);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        SetCmdArg(hnDX);
      end;
    71: begin
        W := B1 and $1;
        SetOpName(hnOUT);
        SetCmdArg(hnDX);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
      end;
    72: begin
        SetOpPrefix(hnLOCK);
        if not readOP then Exit;
      end;
    73: begin
        SetOpPrefix(hnREPNE);
        if not readOP then Exit;
      end;
    74: begin
        SetOpPrefix(hnREPE);
        if not readOP then Exit;
      end;
    75: SetOpName(hnHALT);
    76: SetOpName(hnCMC);
    77: begin
        W := B1 and $1;
        if not readEA(W,C) then Exit;
        SetOpName(ntGr1Op[C]);
        case C and $F of
          $0: if not imW(W) then Exit;
          else ;
        end;
      end;
    78: SetOpName(hnCLC);
    79: SetOpName(hnSTC);
    80: SetOpName(hnCLI);
    81: SetOpName(hnSTI);
    82: SetOpName(hnCLD);
    83: SetOpName(hnSTD);
    84: begin
        W := B1 and $1;
        if not readEA(W,C) then Exit;
        begin
          H := (C and $6)shr 1;
          L := C and $1;
        end;
        case H and $3 of
          $0: SetOpName(ntGr3Op[L]);
          $3: case W and $1 of
              $0: SetOpName(hnQ);
              else case L and $1 of
                  $0: SetOpName(hnPUSH);
                  else SetOpName(hnQ);
                end;
            end;
          else case W and $1 of
              $0: SetOpName(hnQ);
              else begin
                  SetOpName(ntGr2Op[H]);
                  SetCmdArg(ntcallDist[L]);
                end;
            end;
        end;
      end;
    else SetOpName(hnQ);
  end;
  Result := true;
end ;

begin
  SegRegTbl := @ntSReg;
  RegTbl[0] := @ntRegB;
  RegTbl[1] := @ntReg16;
  RegTbl[2] := @ntReg32;
end .
