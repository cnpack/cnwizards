unit op;
{ Generated automatically from c:\prg\codes\src\opdata4.cmd, 31.05.2012 18:10:47 }

interface

uses DAsmDefs, DAsmUtil;

const
  hn_ = $0 or nf;
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
  hnSPL = $11 or nf;
  hnBPL = $12 or nf;
  hnSIL = $13 or nf;
  hnDIL = $14 or nf;
  hnR8B = $15 or nf;
  hnR9B = $16 or nf;
  hnR10B = $17 or nf;
  hnR11B = $18 or nf;
  hnR12B = $19 or nf;
  hnR13B = $1A or nf;
  hnR14B = $1B or nf;
  hnR15B = $1C or nf;
  hnAX = $1D or nf;
  hnCX = $1E or nf;
  hnDX = $1F or nf;
  hnBX = $20 or nf;
  hnSP = $21 or nf;
  hnBP = $22 or nf;
  hnSI = $23 or nf;
  hnDI = $24 or nf;
  hnR8W = $25 or nf;
  hnR9W = $26 or nf;
  hnR10W = $27 or nf;
  hnR11W = $28 or nf;
  hnR12W = $29 or nf;
  hnR13W = $2A or nf;
  hnR14W = $2B or nf;
  hnR15W = $2C or nf;
  hnEAX = $2D or nf;
  hnECX = $2E or nf;
  hnEDX = $2F or nf;
  hnEBX = $30 or nf;
  hnESP = $31 or nf;
  hnEBP = $32 or nf;
  hnESI = $33 or nf;
  hnEDI = $34 or nf;
  hnR8D = $35 or nf;
  hnR9D = $36 or nf;
  hnR10D = $37 or nf;
  hnR11D = $38 or nf;
  hnR12D = $39 or nf;
  hnR13D = $3A or nf;
  hnR14D = $3B or nf;
  hnR15D = $3C or nf;
  hnRAX = $3D or nf;
  hnRCX = $3E or nf;
  hnRDX = $3F or nf;
  hnRBX = $40 or nf;
  hnRSP = $41 or nf;
  hnRBP = $42 or nf;
  hnRSI = $43 or nf;
  hnRDI = $44 or nf;
  hnR8 = $45 or nf;
  hnR9 = $46 or nf;
  hnR10 = $47 or nf;
  hnR11 = $48 or nf;
  hnR12 = $49 or nf;
  hnR13 = $4A or nf;
  hnR14 = $4B or nf;
  hnR15 = $4C or nf;
  hnO = $4D or nf;
  hnNO = $4E or nf;
  hnB = $4F or nf;
  hnNB = $50 or nf;
  hnE = $51 or nf;
  hnNE = $52 or nf;
  hnBE = $53 or nf;
  hnA = $54 or nf;
  hnS = $55 or nf;
  hnNS = $56 or nf;
  hnP = $57 or nf;
  hnNP = $58 or nf;
  hnL = $59 or nf;
  hnGE = $5A or nf;
  hnLE = $5B or nf;
  hnG = $5C or nf;
  hnADD = $5D or nf;
  hnOR = $5E or nf;
  hnADC = $5F or nf;
  hnSBB = $60 or nf;
  hnAND = $61 or nf;
  hnSUB = $62 or nf;
  hnXOR = $63 or nf;
  hnCMP = $64 or nf;
  hnDAA = $65 or nf;
  hnDAS = $66 or nf;
  hnAAA = $67 or nf;
  hnAAS = $68 or nf;
  hnINC = $69 or nf;
  hnDEC = $6A or nf;
  hnPUSH = $6B or nf;
  hnPOP = $6C or nf;
  hnMOVS_ = $6D or nf;
  hnCMPS_ = $6E or nf;
  hnSTOS_ = $6F or nf;
  hnLODS_ = $70 or nf;
  hnSCAS_ = $71 or nf;
  hnW = $72 or nf;
  hnD = $73 or nf;
  hnQ = $74 or nf;
  hnROL = $75 or nf;
  hnROR = $76 or nf;
  hnRCL = $77 or nf;
  hnRCR = $78 or nf;
  hnSHL = $79 or nf;
  hnSHR = $7A or nf;
  hnSAR = $7B or nf;
  hnBT = $7C or nf;
  hnBTS = $7D or nf;
  hnBTR = $7E or nf;
  hnBTC = $7F or nf;
  hnES = $80 or nf;
  hnCS = $81 or nf;
  hnSS = $82 or nf;
  hnDS = $83 or nf;
  hnFS = $84 or nf;
  hnGS = $85 or nf;
  hnNEAR = $86 or nf;
  hnFAR = $87 or nf;
  hnTEST = $88 or nf;
  hnNOT = $89 or nf;
  hnNEG = $8A or nf;
  hnMUL = $8B or nf;
  hnIMUL = $8C or nf;
  hnDIV = $8D or nf;
  hnIDIV = $8E or nf;
  hnSLDT = $8F or nf;
  hnSTR = $90 or nf;
  hnLLDT = $91 or nf;
  hnLTR = $92 or nf;
  hnVERR = $93 or nf;
  hnVERW = $94 or nf;
  hnSGDT = $95 or nf;
  hnSIDT = $96 or nf;
  hnLGDT = $97 or nf;
  hnLIDT = $98 or nf;
  hnSMSW = $99 or nf;
  hnLMSW = $9A or nf;
  hnINVLPG = $9B or nf;
  hnCBW = $9C or nf;
  hnCWDE = $9D or nf;
  hnCDQE = $9E or nf;
  hnCWD = $9F or nf;
  hnCDQ = $A0 or nf;
  hnCQO = $A1 or nf;
  hnINSW = $A2 or nf;
  hnINSD = $A3 or nf;
  hnOUTSW = $A4 or nf;
  hnOUTSD = $A5 or nf;
  hnPUSHA = $A6 or nf;
  hnPUSHAD = $A7 or nf;
  hnPOPA = $A8 or nf;
  hnPOPAD = $A9 or nf;
  hnPUSHF = $AA or nf;
  hnPUSHFD = $AB or nf;
  hnPUSHFQ = $AC or nf;
  hnPOPF = $AD or nf;
  hnPOPFD = $AE or nf;
  hnPOPFQ = $AF or nf;
  hnCR0 = $B0 or nf;
  hnCR2 = $B1 or nf;
  hnCR3 = $B2 or nf;
  hnCR8 = $B3 or nf;
  hnDR0 = $B4 or nf;
  hnDR1 = $B5 or nf;
  hnDR2 = $B6 or nf;
  hnDR3 = $B7 or nf;
  hnDR6 = $B8 or nf;
  hnDR7 = $B9 or nf;
  hnTR3 = $BA or nf;
  hnTR4 = $BB or nf;
  hnTR5 = $BC or nf;
  hnTR6 = $BD or nf;
  hnTR7 = $BE or nf;
  hnMM0 = $BF or nf;
  hnMM1 = $C0 or nf;
  hnMM2 = $C1 or nf;
  hnMM3 = $C2 or nf;
  hnMM4 = $C3 or nf;
  hnMM5 = $C4 or nf;
  hnMM6 = $C5 or nf;
  hnMM7 = $C6 or nf;
  hnBW = $C7 or nf;
  hnWD = $C8 or nf;
  hnDQ = $C9 or nf;
  hnPSRL_ = $CA or nf;
  hnPSRA_ = $CB or nf;
  hnPSLL_ = $CC or nf;
  hnFXSAVE = $CD or nf;
  hnFXRSTOR = $CE or nf;
  hnXMM0 = $CF or nf;
  hnXMM1 = $D0 or nf;
  hnXMM2 = $D1 or nf;
  hnXMM3 = $D2 or nf;
  hnXMM4 = $D3 or nf;
  hnXMM5 = $D4 or nf;
  hnXMM6 = $D5 or nf;
  hnXMM7 = $D6 or nf;
  hnXMM8 = $D7 or nf;
  hnXMM9 = $D8 or nf;
  hnXMM10 = $D9 or nf;
  hnXMM11 = $DA or nf;
  hnXMM12 = $DB or nf;
  hnXMM13 = $DC or nf;
  hnXMM14 = $DD or nf;
  hnXMM15 = $DE or nf;
  hnLAR = $DF or nf;
  hnLSL = $E0 or nf;
  hnLOADALL = $E1 or nf;
  hnCLTS = $E2 or nf;
  hnINVD = $E3 or nf;
  hnWBINVD = $E4 or nf;
  hnUD2 = $E5 or nf;
  hnMOV = $E6 or nf;
  hnWRMSR = $E7 or nf;
  hnRDTSC = $E8 or nf;
  hnRDMSR = $E9 or nf;
  hnRDPMC = $EA or nf;
  hnSYSENTER = $EB or nf;
  hnSYSEXIT = $EC or nf;
  hnCMOV_ = $ED or nf;
  hnPUNPCKL_ = $EE or nf;
  hnPACKSSWB = $EF or nf;
  hnPACKUSWB = $F0 or nf;
  hnPCMPGT_ = $F1 or nf;
  hnPACKSSDW = $F2 or nf;
  hnPUNPCKH_ = $F3 or nf;
  hnMOVD = $F4 or nf;
  hnMOVQ = $F5 or nf;
  hnEMMS = $F6 or nf;
  hnPCMPEQ_ = $F7 or nf;
  hnPMULLW = $F8 or nf;
  hnPSUBUS_ = $F9 or nf;
  hnPAND = $FA or nf;
  hnPADDUS_ = $FB or nf;
  hnPANDN = $FC or nf;
  hnPMULHUW = $FD or nf;
  hnPMULHW = $FE or nf;
  hnPSUBS_ = $FF or nf;
  hnPOR = $100 or nf;
  hnPADDS_ = $101 or nf;
  hnPXOR = $102 or nf;
  hnPMADDWD = $103 or nf;
  hnPSUB_ = $104 or nf;
  hnPADD_ = $105 or nf;
  hnSET_ = $106 or nf;
  hnCPUID = $107 or nf;
  hnSHLD = $108 or nf;
  hnCMPXCHG = $109 or nf;
  hnRSM = $10A or nf;
  hnSHRD = $10B or nf;
  hnLSS = $10C or nf;
  hnLFS = $10D or nf;
  hnLGS = $10E or nf;
  hnMOVZX = $10F or nf;
  hnILLEG1 = $110 or nf;
  hnBSF = $111 or nf;
  hnBSR = $112 or nf;
  hnMOVSX = $113 or nf;
  hnXADD = $114 or nf;
  hnBSWAP = $115 or nf;
  hnST = $116 or nf;
  hnST1 = $117 or nf;
  hnST2 = $118 or nf;
  hnST3 = $119 or nf;
  hnST4 = $11A or nf;
  hnST5 = $11B or nf;
  hnST6 = $11C or nf;
  hnST7 = $11D or nf;
  hnCOM = $11E or nf;
  hnCOMP = $11F or nf;
  hnSUBR = $120 or nf;
  hnDIVR = $121 or nf;
  hnLD = $122 or nf;
  hnSTP = $123 or nf;
  hnFLDENV = $124 or nf;
  hnFLDCW = $125 or nf;
  hnFSTENV = $126 or nf;
  hnFSTCW = $127 or nf;
  hnFLD = $128 or nf;
  hnFXCH = $129 or nf;
  hnFNOP = $12A or nf;
  hnFSTP = $12B or nf;
  hnFCHS = $12C or nf;
  hnFABS = $12D or nf;
  hnFTST = $12E or nf;
  hnFXAM = $12F or nf;
  hnFLD1 = $130 or nf;
  hnFLDL2T = $131 or nf;
  hnFLDL2E = $132 or nf;
  hnFLDPI = $133 or nf;
  hnFLDLG2 = $134 or nf;
  hnFLDLN2 = $135 or nf;
  hnFLDZ = $136 or nf;
  hnF2XM1 = $137 or nf;
  hnFYL2X = $138 or nf;
  hnFPTAN = $139 or nf;
  hnFPATAN = $13A or nf;
  hnFXTRACT = $13B or nf;
  hnFPREM1 = $13C or nf;
  hnFDECSTP = $13D or nf;
  hnFINCSTP = $13E or nf;
  hnFPREM = $13F or nf;
  hnFYL2XP1 = $140 or nf;
  hnFSQRT = $141 or nf;
  hnFSINCOS = $142 or nf;
  hnFRNDINT = $143 or nf;
  hnFSCALE = $144 or nf;
  hnFSIN = $145 or nf;
  hnFCOS = $146 or nf;
  hnFST = $147 or nf;
  hnFENI = $148 or nf;
  hnFDISI = $149 or nf;
  hnFCLEX = $14A or nf;
  hnFINIT = $14B or nf;
  hnFSETPM = $14C or nf;
  hnFSTOR = $14D or nf;
  hnFSAVE = $14E or nf;
  hnFSTSW = $14F or nf;
  hnFFREE = $150 or nf;
  hnFUCOM = $151 or nf;
  hnFUCOMP = $152 or nf;
  hnFBLD = $153 or nf;
  hnFILD = $154 or nf;
  hnFBSTP = $155 or nf;
  hnFISTP = $156 or nf;
  hnU = $157 or nf;
  hnF = $158 or nf;
  hnFI = $159 or nf;
  hnFCMOV_ = $15A or nf;
  hnFUCOMPP = $15B or nf;
  hnFCMOVN_ = $15C or nf;
  hnFUCOMI = $15D or nf;
  hnFCOMI = $15E or nf;
  hnFUCOMIP = $15F or nf;
  hnFCOMIP = $160 or nf;
  hnFWAIT = $161 or nf;
  hnBOUND = $162 or nf;
  hnARPL = $163 or nf;
  hnMOVSXD = $164 or nf;
  hnINSB = $165 or nf;
  hnOUTSB = $166 or nf;
  hnXCHG = $167 or nf;
  hnLEA = $168 or nf;
  hnNOP = $169 or nf;
  hnWAIT = $16A or nf;
  hnSAHF = $16B or nf;
  hnLAHF = $16C or nf;
  hnLES = $16D or nf;
  hnLDS = $16E or nf;
  hnENTER = $16F or nf;
  hnLEAVE = $170 or nf;
  hnINT = $171 or nf;
  hnINTO = $172 or nf;
  hnIRET = $173 or nf;
  hnAAM = $174 or nf;
  hnAAD = $175 or nf;
  hnXLAT = $176 or nf;
  hnESC = $177 or nf;
  hnIN = $178 or nf;
  hnOUT = $179 or nf;
  hnLOCK = $17A or nf;
  hnREPNE = $17B or nf;
  hnREPE = $17C or nf;
  hnHALT = $17D or nf;
  hnCMC = $17E or nf;
  hnCLC = $17F or nf;
  hnSTC = $180 or nf;
  hnCLI = $181 or nf;
  hnSTI = $182 or nf;
  hnCLD = $183 or nf;
  hnSTD = $184 or nf;

function GetOpName(hName: THBMName):TBMOpRec;

const
  ntregB: array[0..8-1]of THBMName = (
    hnAL, hnCL, hnDL, hnBL, hnAH, hnCH, hnDH, hnBH
  );

const
  ntreg16: array[0..16-1]of THBMName = (
    hnAX, hnCX, hnDX, hnBX, hnSP, hnBP, hnSI, hnDI, hnR8W, hnR9W, hnR10W, hnR11W, hnR12W, hnR13W, hnR14W, hnR15W
  );

const
  ntreg32: array[0..16-1]of THBMName = (
    hnEAX, hnECX, hnEDX, hnEBX, hnESP, hnEBP, hnESI, hnEDI, hnR8D, hnR9D, hnR10D, hnR11D, hnR12D, hnR13D, hnR14D, hnR15D
  );

function readOP: boolean;

implementation

const
  BMNames: array[0..389-1] of TBMOpRec = (
    {0x0}'?','RET','JMP','J_','LOOP','LOOPE','LOOPNE','JCXZ',
    {0x8}'CALL','AL','CL','DL','BL','AH','CH','DH',
    {0x10}'BH','SPL','BPL','SIL','DIL','R8B','R9B','R10B',
    {0x18}'R11B','R12B','R13B','R14B','R15B','AX','CX','DX',
    {0x20}'BX','SP','BP','SI','DI','R8W','R9W','R10W',
    {0x28}'R11W','R12W','R13W','R14W','R15W','EAX','ECX','EDX',
    {0x30}'EBX','ESP','EBP','ESI','EDI','R8D','R9D','R10D',
    {0x38}'R11D','R12D','R13D','R14D','R15D','RAX','RCX','RDX',
    {0x40}'RBX','RSP','RBP','RSI','RDI','R8','R9','R10',
    {0x48}'R11','R12','R13','R14','R15','O','NO','B',
    {0x50}'NB','E','NE','BE','A','S','NS','P',
    {0x58}'NP','L','GE','LE','G','ADD','OR','ADC',
    {0x60}'SBB','AND','SUB','XOR','CMP','DAA','DAS','AAA',
    {0x68}'AAS','INC','DEC','PUSH','POP','MOVS_','CMPS_','STOS_',
    {0x70}'LODS_','SCAS_','W','D','Q','ROL','ROR','RCL',
    {0x78}'RCR','SHL','SHR','SAR','BT','BTS','BTR','BTC',
    {0x80}'ES','CS','SS','DS','FS','GS','NEAR','FAR',
    {0x88}'TEST','NOT','NEG','MUL','IMUL','DIV','IDIV','SLDT',
    {0x90}'STR','LLDT','LTR','VERR','VERW','SGDT','SIDT','LGDT',
    {0x98}'LIDT','SMSW','LMSW','INVLPG','CBW','CWDE','CDQE','CWD',
    {0xA0}'CDQ','CQO','INSW','INSD','OUTSW','OUTSD','PUSHA','PUSHAD',
    {0xA8}'POPA','POPAD','PUSHF','PUSHFD','PUSHFQ','POPF','POPFD','POPFQ',
    {0xB0}'CR0','CR2','CR3','CR8','DR0','DR1','DR2','DR3',
    {0xB8}'DR6','DR7','TR3','TR4','TR5','TR6','TR7','MM0',
    {0xC0}'MM1','MM2','MM3','MM4','MM5','MM6','MM7','BW',
    {0xC8}'WD','DQ','PSRL_','PSRA_','PSLL_','FXSAVE','FXRSTOR','XMM0',
    {0xD0}'XMM1','XMM2','XMM3','XMM4','XMM5','XMM6','XMM7','XMM8',
    {0xD8}'XMM9','XMM10','XMM11','XMM12','XMM13','XMM14','XMM15','LAR',
    {0xE0}'LSL','LOADALL','CLTS','INVD','WBINVD','UD2','MOV','WRMSR',
    {0xE8}'RDTSC','RDMSR','RDPMC','SYSENTER','SYSEXIT','CMOV_','PUNPCKL_','PACKSSWB',
    {0xF0}'PACKUSWB','PCMPGT_','PACKSSDW','PUNPCKH_','MOVD','MOVQ','EMMS','PCMPEQ_',
    {0xF8}'PMULLW','PSUBUS_','PAND','PADDUS_','PANDN','PMULHUW','PMULHW','PSUBS_',
    {0x100}'POR','PADDS_','PXOR','PMADDWD','PSUB_','PADD_','SET_','CPUID',
    {0x108}'SHLD','CMPXCHG','RSM','SHRD','LSS','LFS','LGS','MOVZX',
    {0x110}'ILLEG1','BSF','BSR','MOVSX','XADD','BSWAP','ST','ST1',
    {0x118}'ST2','ST3','ST4','ST5','ST6','ST7','COM','COMP',
    {0x120}'SUBR','DIVR','LD','STP','FLDENV','FLDCW','FSTENV','FSTCW',
    {0x128}'FLD','FXCH','FNOP','FSTP','FCHS','FABS','FTST','FXAM',
    {0x130}'FLD1','FLDL2T','FLDL2E','FLDPI','FLDLG2','FLDLN2','FLDZ','F2XM1',
    {0x138}'FYL2X','FPTAN','FPATAN','FXTRACT','FPREM1','FDECSTP','FINCSTP','FPREM',
    {0x140}'FYL2XP1','FSQRT','FSINCOS','FRNDINT','FSCALE','FSIN','FCOS','FST',
    {0x148}'FENI','FDISI','FCLEX','FINIT','FSETPM','FSTOR','FSAVE','FSTSW',
    {0x150}'FFREE','FUCOM','FUCOMP','FBLD','FILD','FBSTP','FISTP','U',
    {0x158}'F','FI','FCMOV_','FUCOMPP','FCMOVN_','FUCOMI','FCOMI','FUCOMIP',
    {0x160}'FCOMIP','FWAIT','BOUND','ARPL','MOVSXD','INSB','OUTSB','XCHG',
    {0x168}'LEA','NOP','WAIT','SAHF','LAHF','LES','LDS','ENTER',
    {0x170}'LEAVE','INT','INTO','IRET','AAM','AAD','XLAT','ESC',
    {0x178}'IN','OUT','LOCK','REPNE','REPE','HALT','CMC','CLC',
    {0x180}'STC','CLI','STI','CLD','STD'
  );

function GetOpName(hName: THBMName):TBMOpRec;
begin
  hName := hName and nm;
  if (hName<0)or(hName>High(BMNames)) then
    Result := ''
  else
    Result := BMNames[hName];
end ;

const
  ntregB64: array[0..16-1]of THBMName = (
    hnAL, hnCL, hnDL, hnBL, hnSPL, hnBPL, hnSIL, hnDIL, hnR8B, hnR9B, hnR10B, hnR11B, hnR12B, hnR13B, hnR14B, hnR15B
  );

const
  ntreg64: array[0..16-1]of THBMName = (
    hnRAX, hnRCX, hnRDX, hnRBX, hnRSP, hnRBP, hnRSI, hnRDI, hnR8, hnR9, hnR10, hnR11, hnR12, hnR13, hnR14, hnR15
  );

function RegW(R: integer; var RN: integer): boolean;
var
  OS: integer;
begin
  Result := false;
  OS := getOS;
  case OS of
    $0: RN := ntreg16[R];
    $1: RN := ntreg32[R];
    else Exit;
  end;
  Result := true;
end ;

function Reg(W,R: integer; var RN: integer): boolean;
begin
  Result := false;
  case W of
    $0: RN := ntregB[R];
    $1: if not RegW(R,RN) then Exit;
    else Exit;
  end;
  Result := true;
end ;

function regBX(R: integer; var RN: integer): boolean;
var
  WR: integer;
begin
  Result := false;
  WR := wasREX;
  case WR of
    $0: RN := ntregB[R];
    $1: RN := ntregB64[R];
    else Exit;
  end;
  Result := true;
end ;

function regWX(R,P: integer; var RN: integer): boolean;
var
  OS,RX: integer;
begin
  Result := false;
  OS := getOS64;
  RX := addREXBit(R,P);
  case OS of
    $0: RN := ntreg16[RX];
    $1: RN := ntreg32[RX];
    $2: RN := ntreg64[RX];
    else Exit;
  end;
  Result := true;
end ;

function RegWM(R: integer; var RN: integer): boolean;
var
  OS,M: integer;
begin
  Result := false;
  OS := getOS;
  case OS of
    $0: RN := ntreg16[R];
    $1: begin
        M := mode64;
        case M of
          $0: RN := ntreg32[R];
          $1: RN := ntreg64[R];
          else Exit;
        end;
      end;
    else Exit;
  end;
  Result := true;
end ;

function regX(W,R,P: integer; var RN: integer): boolean;
begin
  Result := false;
  case W of
    $0: if not regBX(R,RN) then Exit;
    $1: if not regWX(R,P,RN) then Exit;
    else Exit;
  end;
  Result := true;
end ;

function JmpOfsW: boolean;
var
  M,S: integer;
begin
  Result := false;
  M := mode64;
  case M of
    $0: S := getOS;
    $1: S := Identic(1);
    else Exit;
  end;
  if not jmpOfs(1+S) then Exit;
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
  ntincDec: array[0..2-1]of THBMName = (
    hnINC, hnDEC
  );

const
  ntpushPop: array[0..2-1]of THBMName = (
    hnPUSH, hnPOP
  );

const
  ntStrOp1: array[0..2-1]of THBMName = (
    hnMOVS_, hnCMPS_
  );

const
  ntStrOp2: array[0..4-1]of THBMName = (
    hn_, hnSTOS_, hnLODS_, hnSCAS_
  );

const
  ntsWD: array[0..3-1]of THBMName = (
    hnW, hnD, hnQ
  );

const
  ntShftOp: array[0..8-1]of THBMName = (
    hnROL, hnROR, hnRCL, hnRCR, hnSHL, hnSHR, hn_, hnSAR
  );

const
  ntBtOp: array[0..8-1]of THBMName = (
    hn_, hn_, hn_, hn_, hnBT, hnBTS, hnBTR, hnBTC
  );

const
  ntSReg: array[0..8-1]of THBMName = (
    hnES, hnCS, hnSS, hnDS, hnFS, hnGS, hn_, hn_
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
    hnTEST, hn_, hnNOT, hnNEG, hnMUL, hnIMUL, hnDIV, hnIDIV
  );

const
  ntGr2Op: array[0..4-1]of THBMName = (
    hn_, hnCALL, hnJMP, hn_
  );

const
  ntGr3Op: array[0..2-1]of THBMName = (
    hnINC, hnDEC
  );

const
  ntGr6Op: array[0..8-1]of THBMName = (
    hnSLDT, hnSTR, hnLLDT, hnLTR, hnVERR, hnVERW, hn_, hn_
  );

const
  ntGr7Op: array[0..8-1]of THBMName = (
    hnSGDT, hnSIDT, hnLGDT, hnLIDT, hnSMSW, hn_, hnLMSW, hnINVLPG
  );

const
  ntcbwOp: array[0..3-1]of THBMName = (
    hnCBW, hnCWDE, hnCDQE
  );

const
  ntcwdOp: array[0..3-1]of THBMName = (
    hnCWD, hnCDQ, hnCQO
  );

const
  ntinswOp: array[0..2-1]of THBMName = (
    hnINSW, hnINSD
  );

const
  ntoutswOp: array[0..2-1]of THBMName = (
    hnOUTSW, hnOUTSD
  );

const
  ntpushaOp: array[0..2-1]of THBMName = (
    hnPUSHA, hnPUSHAD
  );

const
  ntpopaOp: array[0..2-1]of THBMName = (
    hnPOPA, hnPOPAD
  );

const
  ntpushfOp: array[0..3-1]of THBMName = (
    hnPUSHF, hnPUSHFD, hnPUSHFQ
  );

const
  ntpopfOp: array[0..3-1]of THBMName = (
    hnPOPF, hnPOPFD, hnPOPFQ
  );

const
  ntCReg: array[0..16-1]of THBMName = (
    hnCR0, hn_, hnCR2, hnCR3, hn_, hn_, hn_, hn_, hnCR8, hn_, hn_, hn_, hn_, hn_, hn_, hn_
  );

const
  ntDReg: array[0..16-1]of THBMName = (
    hnDR0, hnDR1, hnDR2, hnDR3, hn_, hn_, hnDR6, hnDR7, hn_, hn_, hn_, hn_, hn_, hn_, hn_, hn_
  );

const
  ntTReg: array[0..8-1]of THBMName = (
    hn_, hn_, hn_, hnTR3, hnTR4, hnTR5, hnTR6, hnTR7
  );

function getEAV(W: integer; var M,A: integer): boolean;
begin
  Result := false;
  if (W and $1)<>$0 then W := 1+getOS;
  if not getEA(W,M,A) then Exit;
  Result := true;
end ;

function getEAV64(W: integer; var M,A: integer): boolean;
begin
  Result := false;
  if (W and $1)<>$0 then W := 1+getOS64;
  if not getEA(W,M,A) then Exit;
  Result := true;
end ;

function getEAVM(W: integer; var M,A: integer): boolean;
begin
  Result := false;
  if (W and $1)<>$0 then W := 1+mode64;
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

function readEAM(W: integer; var M: integer): boolean;
var
  A: integer;
begin
  Result := false;
  if not getEAVM(W,M,A) then Exit;
  SetCmdArg(A);
  Result := true;
end ;

function readEA64(W: integer; var M: integer): boolean;
var
  A: integer;
begin
  Result := false;
  if not getEAV64(W,M,A) then Exit;
  SetCmdArg(A);
  Result := true;
end ;

function imW(W: integer): boolean;
begin
  Result := false;
  if (W and $1)=$0 then begin
     if not ImmedBW(0) then Exit;
   end
  else if not ImmedBW(1+getOS) then Exit;
  Result := true;
end ;

function imW64(W: integer): boolean;
begin
  Result := false;
  if (W and $1)=$0 then begin
     if not ImmedBW(0) then Exit;
   end
  else if not ImmedBW(1+getOS64) then Exit;
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

function readRMD64(W: integer): boolean;
var
  R,A: integer;
var
  _1: integer;
begin
  Result := false;
  if not getEAV64(W,R,A) then Exit;
  if not regX(W,R,3,_1) then Exit;
  SetCmdArg(_1);
  SetCmdArg(A);
  Result := true;
end ;

function readRMR64(W: integer): boolean;
var
  R,A: integer;
var
  _1: integer;
begin
  Result := false;
  if not getEAV64(W,R,A) then Exit;
  SetCmdArg(A);
  if not regX(W,R,3,_1) then Exit;
  SetCmdArg(_1);
  Result := true;
end ;

function readRM64(R,W: integer): boolean;
begin
  Result := false;
  case R of
    $0: if not readRMR64(W) then Exit;
    $1: if not readRMD64(W) then Exit;
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
  if not regWX(R,3,_1) then Exit;
  SetCmdArg(_1);
  SetCmdArg(A);
  Result := true;
end ;

function ReadFarPtr: boolean;
var
  W,R,A: integer;
var
  _1: integer;
begin
  Result := false;
  W := 1+getOS64;
  if not getEA(W,R,A) then Exit;
  if not regWX(R,3,_1) then Exit;
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

function ReadM64Im(W: integer): boolean;
var
  R,A: integer;
begin
  Result := false;
  if not getEAV64(W,R,A) then Exit;
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
  if (S and $F)<>$8 then SetCmdArg(ntSReg[S]);
  Result := true;
end ;

function StrBW(W: integer): boolean;
begin
  Result := false;
  case W of
    $0: SetCmdArg(hnB);
    $1: SetCmdArg(ntsWD[getOS64]);
    else Exit;
  end;
  Result := true;
end ;

const
  ntregMMX: array[0..8-1]of THBMName = (
    hnMM0, hnMM1, hnMM2, hnMM3, hnMM4, hnMM5, hnMM6, hnMM7
  );

const
  ntmmxSz: array[0..2-1]of THBMName = (
    hnD, hnQ
  );

const
  ntmmxGran: array[0..4-1]of THBMName = (
    hnB, hnW, hnD, hnQ
  );

const
  ntmmxUnpkGran: array[0..4-1]of THBMName = (
    hnBW, hnWD, hnDQ, hn_
  );

const
  ntmmxShift: array[0..8-1]of THBMName = (
    hn_, hn_, hnPSRL_, hn_, hnPSRA_, hn_, hnPSLL_, hn_
  );

function readMmxRM(Rev,D: integer): boolean;
var
  R,A: integer;
begin
  Result := false;
  if not getEA(2+D,R,A) then Exit;
  case Rev of
    $0: begin
        SetCmdArg(ntregMMX[R]);
        SetCmdArg(A);
      end;
    $1: begin
        SetCmdArg(A);
        SetCmdArg(ntregMMX[R]);
      end;
    else Exit;
  end;
  Result := true;
end ;

function readMmxMRM(Rev,D: integer): boolean;
begin
  Result := false;
  setEAMod3Tbl(ntregMMX);
  if not readMmxRM(Rev,D) then Exit;
  Result := true;
end ;

const
  ntfxOp: array[0..8-1]of THBMName = (
    hnFXSAVE, hnFXRSTOR, hn_, hn_, hn_, hn_, hn_, hn_
  );

const
  ntregXMM: array[0..16-1]of THBMName = (
    hnXMM0, hnXMM1, hnXMM2, hnXMM3, hnXMM4, hnXMM5, hnXMM6, hnXMM7, hnXMM8, hnXMM9, hnXMM10, hnXMM11, hnXMM12, hnXMM13, hnXMM14, hnXMM15
  );

function readXmmRM(Rev,D: integer): boolean;
var
  R,A,RX: integer;
begin
  Result := false;
  if not getEA(2+D,R,A) then Exit;
  RX := addREXBit(R,3);
  case Rev of
    $0: begin
        SetCmdArg(ntregXMM[RX]);
        SetCmdArg(A);
      end;
    $1: begin
        SetCmdArg(A);
        SetCmdArg(ntregXMM[RX]);
      end;
    else Exit;
  end;
  Result := true;
end ;

function readXmmXRM(Rev,D: integer): boolean;
begin
  Result := false;
  setEAMod3Tbl(ntregXMM);
  if not readXmmRM(Rev,D) then Exit;
  Result := true;
end ;

function ReadPM: boolean;
var
  B0,M,A,B1,C,R,D,G,S,W: integer;
var
  _1: integer;

const
  _C0: array[0..$FF] of integer = (
    {0x00}  0,  1,  2,  3, 81,  4,  5, 81,  6,  7, 81,  8, 81, 81, 81, 81,
    {0x10} 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81,
    {0x20}  9, 10, 11, 12, 13, 81, 14, 81, 81, 81, 81, 81, 81, 81, 81, 81,
    {0x30} 15, 16, 17, 18, 19, 20, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81,
    {0x40} 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    {0x50} 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81,
    {0x60} 22, 22, 22, 22, 25, 25, 25, 24, 27, 27, 27, 26, 81, 81, 28, 29,
    {0x70} 30, 30, 30, 30, 32, 32, 32, 31, 81, 81, 81, 81, 81, 81, 28, 29,
    {0x80} 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    {0x90} 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51,
    {0xA0} 52, 53, 54, 55, 56, 57, 58, 58, 59, 60, 61, 62, 63, 64, 65, 66,
    {0xB0} 67, 67, 68, 69, 70, 71, 72, 72, 81, 73, 74, 75, 76, 77, 78, 78,
    {0xC0} 79, 79, 81, 81, 81, 81, 81, 81, 80, 80, 80, 80, 80, 80, 80, 80,
    {0xD0} 33, 33, 33, 33, 81, 34, 81, 81, 35, 35, 81, 36, 37, 37, 81, 38,
    {0xE0} 39, 39, 39, 39, 40, 41, 81, 81, 42, 42, 81, 43, 44, 44, 81, 45,
    {0xF0} 46, 46, 46, 46, 81, 47, 81, 81, 48, 48, 48, 48, 49, 49, 49, 49
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
    8: SetOpName(hnUD2);
    9: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        M := mode64;
        if (M and $1)=$0 then begin
           SetCmdArg(ntreg32[R]);
           SetCmdArg(ntCReg[C]);
         end
        else begin
           SetCmdArg(ntreg64[addREXBit(R,3)]);
           SetCmdArg(ntCReg[addREXBit(C,1)]);
         end;
      end;
    10: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        M := mode64;
        if (M and $1)=$0 then begin
           SetCmdArg(ntreg32[R]);
           SetCmdArg(ntDReg[C]);
         end
        else begin
           SetCmdArg(ntreg64[addREXBit(R,3)]);
           SetCmdArg(ntDReg[addREXBit(C,1)]);
         end;
      end;
    11: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        M := mode64;
        if (M and $1)=$0 then begin
           SetCmdArg(ntCReg[C]);
           SetCmdArg(ntreg32[R]);
         end
        else begin
           SetCmdArg(ntCReg[addREXBit(C,1)]);
           SetCmdArg(ntreg64[addREXBit(R,3)]);
         end;
      end;
    12: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        M := mode64;
        if (M and $1)=$0 then begin
           SetCmdArg(ntDReg[C]);
           SetCmdArg(ntreg32[R]);
         end
        else begin
           SetCmdArg(ntDReg[addREXBit(C,1)]);
           SetCmdArg(ntreg64[addREXBit(R,3)]);
         end;
      end;
    13: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        SetCmdArg(ntreg32[R]);
        SetCmdArg(ntTReg[C]);
      end;
    14: begin
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           C := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(hnMOV);
        SetCmdArg(ntTReg[C]);
        SetCmdArg(ntreg32[R]);
      end;
    15: SetOpName(hnWRMSR);
    16: SetOpName(hnRDTSC);
    17: SetOpName(hnRDMSR);
    18: SetOpName(hnRDPMC);
    19: SetOpName(hnSYSENTER);
    20: SetOpName(hnSYSEXIT);
    21: begin
        D := B0 and $F;
        SetOpName(hnCMOV_);
        SetCmdArg(ntJmpCond[D]);
        if not readRMD64(1) then Exit;
      end;
    22: begin
        G := B0 and $3;
        SetOpName(hnPUNPCKL_);
        SetCmdArg(ntmmxUnpkGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    23: begin
        SetOpName(hnPACKSSWB);
        if not readMmxMRM(0,0) then Exit;
      end;
    24: begin
        SetOpName(hnPACKUSWB);
        if not readMmxMRM(0,0) then Exit;
      end;
    25: begin
        G := B0 and $3;
        SetOpName(hnPCMPGT_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    26: begin
        SetOpName(hnPACKSSDW);
        if not readMmxMRM(0,1) then Exit;
      end;
    27: begin
        G := B0 and $3;
        SetOpName(hnPUNPCKH_);
        SetCmdArg(ntmmxUnpkGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    28: begin
        D := (B0 and $10)shr 4;
        SetOpName(hnMOVD);
        if not readMmxRM(D,0) then Exit;
      end;
    29: begin
        D := (B0 and $10)shr 4;
        SetOpName(hnMOVQ);
        if not readMmxMRM(D,1) then Exit;
      end;
    30: begin
        G := B0 and $3;
        if not ReadByte(B1) then Exit;
        if (B1 and $C0)=$C0 then begin
           S := (B1 and $38)shr 3;
           R := B1 and $7;
         end
        else 
          Exit;
        SetOpName(ntmmxShift[S]);
        SetCmdArg(ntmmxGran[G]);
        SetCmdArg(ntregMMX[R]);
        if not ImmedBW(0) then Exit;
      end;
    31: SetOpName(hnEMMS);
    32: begin
        G := B0 and $3;
        SetOpName(hnPCMPEQ_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    33: begin
        G := B0 and $3;
        SetOpName(hnPSRL_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    34: begin
        SetOpName(hnPMULLW);
        if not readMmxMRM(0,1) then Exit;
      end;
    35: begin
        G := B0 and $1;
        SetOpName(hnPSUBUS_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    36: begin
        SetOpName(hnPAND);
        if not readMmxMRM(0,1) then Exit;
      end;
    37: begin
        G := B0 and $1;
        SetOpName(hnPADDUS_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    38: begin
        SetOpName(hnPANDN);
        if not readMmxMRM(0,1) then Exit;
      end;
    39: begin
        G := B0 and $3;
        SetOpName(hnPSRA_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    40: begin
        SetOpName(hnPMULHUW);
        if not readMmxMRM(0,1) then Exit;
      end;
    41: begin
        SetOpName(hnPMULHW);
        if not readMmxMRM(0,1) then Exit;
      end;
    42: begin
        G := B0 and $1;
        SetOpName(hnPSUBS_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    43: begin
        SetOpName(hnPOR);
        if not readMmxMRM(0,1) then Exit;
      end;
    44: begin
        G := B0 and $1;
        SetOpName(hnPADDS_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    45: begin
        SetOpName(hnPXOR);
        if not readMmxMRM(0,1) then Exit;
      end;
    46: begin
        G := B0 and $3;
        SetOpName(hnPSLL_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    47: begin
        SetOpName(hnPMADDWD);
        if not readMmxMRM(0,1) then Exit;
      end;
    48: begin
        G := B0 and $3;
        SetOpName(hnPSUB_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    49: begin
        G := B0 and $3;
        SetOpName(hnPADD_);
        SetCmdArg(ntmmxGran[G]);
        if not readMmxMRM(0,1) then Exit;
      end;
    50: begin
        D := B0 and $F;
        SetOpName(hnJ_);
        SetCmdArg(ntJmpCond[D]);
        if not JmpOfsW then Exit;
      end;
    51: begin
        D := B0 and $F;
        SetOpName(hnSET_);
        SetCmdArg(ntJmpCond[D]);
        if not readEA64(0,M) then Exit;
      end;
    52: begin
        SetOpName(hnPUSH);
        SetCmdArg(hnFS);
      end;
    53: begin
        SetOpName(hnPOP);
        SetCmdArg(hnFS);
      end;
    54: SetOpName(hnCPUID);
    55: begin
        SetOpName(hnBT);
        if not readRMD64(1) then Exit;
      end;
    56: begin
        SetOpName(hnSHLD);
        if not readRMR64(1) then Exit;
        if not ImmedBW(0) then Exit;
      end;
    57: begin
        SetOpName(hnSHLD);
        if not readRMR64(1) then Exit;
        SetCmdArg(hnCL);
      end;
    58: begin
        D := B0 and $1;
        SetOpName(hnCMPXCHG);
        if not readRMD(D) then Exit;
      end;
    59: begin
        SetOpName(hnPUSH);
        SetCmdArg(hnGS);
      end;
    60: begin
        SetOpName(hnPOP);
        SetCmdArg(hnGS);
      end;
    61: SetOpName(hnRSM);
    62: begin
        SetOpName(hnBTS);
        if not readRMR64(1) then Exit;
      end;
    63: begin
        SetOpName(hnSHRD);
        if not readRMR64(1) then Exit;
        if not ImmedBW(0) then Exit;
      end;
    64: begin
        SetOpName(hnSHRD);
        if not readRMR64(1) then Exit;
        SetCmdArg(hnCL);
      end;
    65: begin
        if not readEA(0,_1) then Exit;
        SetOpName(ntfxOp[_1]);
      end;
    66: begin
        SetOpName(hnIMUL);
        if not readRMD64(1) then Exit;
      end;
    67: begin
        D := B0 and $1;
        SetOpName(hnCMPXCHG);
        if not readRMD64(D) then Exit;
      end;
    68: begin
        SetOpName(hnLSS);
        if not ReadFarPtr then Exit;
      end;
    69: begin
        SetOpName(hnBTR);
        if not readRMR64(1) then Exit;
      end;
    70: begin
        SetOpName(hnLFS);
        if not ReadFarPtr then Exit;
      end;
    71: begin
        SetOpName(hnLGS);
        if not ReadFarPtr then Exit;
      end;
    72: begin
        W := B0 and $1;
        SetOpName(hnMOVZX);
        if not ReadRMWD(W) then Exit;
      end;
    73: SetOpName(hnILLEG1);
    74: begin
        if not readEA64(1,_1) then Exit;
        SetOpName(ntBtOp[_1]);
        if not ImmedBW(0) then Exit;
      end;
    75: begin
        SetOpName(hnBTC);
        if not readRMR64(1) then Exit;
      end;
    76: begin
        SetOpName(hnBSF);
        if not readRMD64(1) then Exit;
      end;
    77: begin
        SetOpName(hnBSR);
        if not readRMD64(1) then Exit;
      end;
    78: begin
        W := B0 and $1;
        SetOpName(hnMOVSX);
        if not ReadRMWD(W) then Exit;
      end;
    79: begin
        W := B0 and $1;
        SetOpName(hnXADD);
        if not readRMD64(W) then Exit;
      end;
    80: begin
        R := B0 and $7;
        SetOpName(hnBSWAP);
        if not regWX(R,1,_1) then Exit;
        SetCmdArg(_1);
      end;
    else SetOpName(hn_);
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
    hnLD, hn_, hnST, hnSTP
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
    hnFCHS, hnFABS, hn_, hn_, hnFTST, hnFXAM, hn_, hn_, hnFLD1, hnFLDL2T, hnFLDL2E, hnFLDPI, hnFLDLG2, hnFLDLN2, hnFLDZ, hn_, hnF2XM1, hnFYL2X, hnFPTAN, hnFPATAN, hnFXTRACT, hnFPREM1, hnFDECSTP, hnFINCSTP, hnFPREM, hnFYL2XP1, hnFSQRT, hnFSINCOS, hnFRNDINT, hnFSCALE, hnFSIN, hnFCOS
  );

const
  ntfEsc3s: array[0..4-1]of THBMName = (
    hn_, hnFLD, hn_, hnFST
  );

const
  ntfEsc3s1: array[0..8-1]of THBMName = (
    hnFENI, hnFDISI, hnFCLEX, hnFINIT, hnFSETPM, hn_, hn_, hn_
  );

const
  ntfEsc5s: array[0..4-1]of THBMName = (
    hnFSTOR, hn_, hnFSAVE, hnFSTSW
  );

const
  ntfEsc5s1: array[0..8-1]of THBMName = (
    hnFFREE, hn_, hnFST, hnFSTP, hnFUCOM, hnFUCOMP, hn_, hn_
  );

const
  ntfopEsc6s: array[0..8-1]of THBMName = (
    hnADD, hnMUL, hn_, hnCOMP, hnSUBR, hnSUB, hnDIVR, hnDIV
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
begin
  Result := false;
  if (M and $6)<>$2 then SetCmdArg(hnST);
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
  if (NextB and $C0)=$C0 then begin
     M := (NextB and $38)shr 3;
     R := NextB and $7;
     case C and $F of
       $0: begin
           SetPrefix(hnF);
           SetOpName(ntfops[M]);
           if not PutSt(M) then Exit;
           SetCmdArg(ntFPReg[R]);
         end;
       $1: if (NextB and $E0)=$E0 then begin
            Y := NextB and $1F;
            SetOpName(ntfEsc1s2[Y]);
          end
         else begin
            SetOpName(ntfEsc1s1[M]);
            SetCmdArg(ntFPReg[R]);
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
               SetCmdArg(ntreg16[R]);
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
   end
  else begin
     if not UnReadByte then Exit;
     if not getEA(1,M,A) then Exit;
     setEASize(0);
     SetCmdArg(A);
     if (C and $1)=$0 then begin
        Y := (C and $4)shr 2;
        T := (C and $2)shr 1;
        SetPrefix(ntFPType[T]);
        if not SizeEven(C) then Exit;
        SetOpName(ntfops[M]);
      end
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
                  if (N and $1)=$0 then begin
                     Y := (N and $2)shr 1;
                     setEASize(5);
                   end
                  else setEASize(4);
                end;
              else Exit;
            end;
          end;
        else Exit;
      end;
   end;
  Result := true;
end ;

function readFPEmul(B: integer): boolean;
var
  B1,C,S,X,S1: integer;
begin
  Result := false;
  B1 := B-52;
  if (B1 and $F8)=$0 then begin
     C := B1 and $7;
     if not readFP(B1) then Exit;
   end
  else if (B1 and $FF)=$8 then begin
     if not ReadByte(C) then Exit;
     if (C and $38)=$18 then begin
        S := (C and $C0)shr 6;
        X := C and $7;
        S1 := 3-S;
        setSeg(S1);
        if not readFP(X) then Exit;
      end
     else 
       Exit;
   end
  else if (B1 and $FF)=$9 then SetOpName(hnFWAIT)
  else 
    Exit;
  Result := true;
end ;

function readOP: boolean;
var
  B1,A,D,W,S,M,R,C,F,B2,N,L,H: integer;
var
  _1, _2: integer;

const
  _C0: array[0..$FF] of integer = (
    {0x00}  0,  0,  0,  0,  1,  1,  3,  4,  0,  0,  0,  0,  1,  1,  3,  2,
    {0x10}  0,  0,  0,  0,  1,  1,  3,  4,  0,  0,  0,  0,  1,  1,  3,  4,
    {0x20}  0,  0,  0,  0,  1,  1,  5,  6,  0,  0,  0,  0,  1,  1,  5,  6,
    {0x30}  0,  0,  0,  0,  1,  1,  5,  6,  0,  0,  0,  0,  1,  1,  5,  6,
    {0x40}  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
    {0x50}  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    {0x60}  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 17, 18, 19, 20, 21, 22,
    {0x70} 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23,
    {0x80} 24, 24, 24, 24, 25, 25, 26, 26, 27, 27, 27, 27, 28, 29, 28, 30,
    {0x90} 31, 32, 32, 32, 32, 32, 32, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    {0xA0} 41, 41, 41, 41, 42, 42, 42, 42, 43, 43, 44, 44, 44, 44, 44, 44,
    {0xB0} 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45,
    {0xC0} 46, 46, 47, 48, 49, 50, 51, 51, 52, 53, 47, 48, 54, 55, 56, 57,
    {0xD0} 58, 58, 59, 59, 60, 61, 86, 62, 63, 63, 63, 63, 63, 63, 63, 63,
    {0xE0} 64, 64, 64, 64, 65, 65, 66, 66, 67, 68, 69, 70, 71, 71, 72, 72,
    {0xF0} 73, 86, 74, 75, 76, 77, 78, 78, 79, 80, 81, 82, 83, 84, 85, 85
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
        if not readRM64(D,W) then Exit;
      end;
    1: begin
        A := (B1 and $38)shr 3;
        W := B1 and $1;
        SetOpName(ntArOp[A]);
        if not regX(W,0,0,_1) then Exit;
        SetCmdArg(_1);
        if not imW(W) then Exit;
      end;
    2: if not ReadPM then Exit;
    3: begin
        S := (B1 and $18)shr 3;
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnPUSH);
           SetCmdArg(ntSReg[S]);
         end
        else SetOpName(hn_);
      end;
    4: begin
        S := (B1 and $18)shr 3;
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnPOP);
           SetCmdArg(ntSReg[S]);
         end
        else SetOpName(hn_);
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
        A := (B1 and $8)shr 3;
        R := B1 and $7;
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(ntincDec[A]);
           if not RegW(R,_1) then Exit;
           SetCmdArg(_1);
         end
        else begin
           setREX(A,R);
           if not readOP then Exit;
         end;
      end;
    8: begin
        A := (B1 and $8)shr 3;
        R := B1 and $7;
        SetOpName(ntpushPop[A]);
        if not RegWM(R,_1) then Exit;
        SetCmdArg(_1);
      end;
    9: begin
        M := mode64;
        if (M and $1)=$0 then SetOpName(ntpushaOp[getOS])
        else SetOpName(hn_);
      end;
    10: begin
        M := mode64;
        if (M and $1)=$0 then SetOpName(ntpopaOp[getOS])
        else SetOpName(hn_);
      end;
    11: begin
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnBOUND);
           if not readRMD(1) then Exit;
         end
        else SetOpName(hn_);
      end;
    12: begin
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnARPL);
           if not readRMD(1) then Exit;
         end
        else begin
           SetOpName(hnMOVSXD);
           if not ReadRMWD(2) then Exit;
         end;
      end;
    13: begin
        setSeg(4);
        if not readOP then Exit;
      end;
    14: begin
        setSeg(5);
        if not readOP then Exit;
      end;
    15: begin
        setOS;
        if not readOP then Exit;
      end;
    16: begin
        setAS;
        if not readOP then Exit;
      end;
    17: begin
        W := (B1 and $2)shr 1;
        SetOpName(hnPUSH);
        if not imW(not(W)) then Exit;
      end;
    18: begin
        W := (B1 and $2)shr 1;
        SetOpName(hnIMUL);
        if not ReadM64Im(not(W)) then Exit;
      end;
    19: SetOpName(hnINSB);
    20: SetOpName(ntinswOp[getOS]);
    21: SetOpName(hnOUTSB);
    22: SetOpName(ntoutswOp[getOS]);
    23: begin
        D := B1 and $F;
        SetOpName(hnJ_);
        SetCmdArg(ntJmpCond[D]);
        if not jmpOfs(0) then Exit;
      end;
    24: begin
        S := (B1 and $2)shr 1;
        W := B1 and $1;
        if not readEA64(W,_1) then Exit;
        SetOpName(ntArOp[_1]);
        if not imSignExt(S,W) then Exit;
      end;
    25: begin
        W := B1 and $1;
        SetOpName(hnTEST);
        if not readRMR64(W) then Exit;
      end;
    26: begin
        W := B1 and $1;
        SetOpName(hnXCHG);
        if not readRMD64(W) then Exit;
      end;
    27: begin
        D := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(hnMOV);
        if not readRM64(D,W) then Exit;
      end;
    28: begin
        D := (B1 and $2)shr 1;
        SetOpName(hnMOV);
        if not readSRM(D) then Exit;
      end;
    29: begin
        SetOpName(hnLEA);
        if not readRMD64(1) then Exit;
      end;
    30: begin
        SetOpName(hnPOP);
        if not readEAM(1,C) then Exit;
      end;
    31: SetOpName(hnNOP);
    32: begin
        R := B1 and $7;
        SetOpName(hnXCHG);
        if not regWX(0,0,_1) then Exit;
        SetCmdArg(_1);
        if not regWX(R,1,_1) then Exit;
        SetCmdArg(_1);
      end;
    33: SetOpName(ntcbwOp[getOS64]);
    34: SetOpName(ntcwdOp[getOS64]);
    35: begin
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnCALL);
           if not imPtr then Exit;
         end
        else SetOpName(hn_);
      end;
    36: SetOpName(hnWAIT);
    37: SetOpName(ntpushfOp[getOS64]);
    38: SetOpName(ntpopfOp[getOS64]);
    39: SetOpName(hnSAHF);
    40: SetOpName(hnLAHF);
    41: begin
        D := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(hnMOV);
        if not regX(W,0,0,_1) then Exit;
        if not getImmOfsEA(W,_2) then Exit;
        if not xchgArg(D,_1,_2) then Exit;
      end;
    42: begin
        A := (B1 and $2)shr 1;
        W := B1 and $1;
        SetOpName(ntStrOp1[A]);
        if not StrBW(W) then Exit;
        if not CurSeg then Exit;
      end;
    43: begin
        W := B1 and $1;
        SetOpName(hnTEST);
        if not regX(W,0,0,_1) then Exit;
        SetCmdArg(_1);
        if not imW(W) then Exit;
      end;
    44: begin
        A := (B1 and $6)shr 1;
        W := B1 and $1;
        SetOpName(ntStrOp2[A]);
        if not StrBW(W) then Exit;
        if not CurSeg then Exit;
      end;
    45: begin
        W := (B1 and $8)shr 3;
        R := B1 and $7;
        SetOpName(hnMOV);
        if not regX(W,R,1,_1) then Exit;
        SetCmdArg(_1);
        if not imW64(W) then Exit;
      end;
    46: begin
        W := B1 and $1;
        if not readEA64(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        if not ImmedBW(0) then Exit;
      end;
    47: begin
        F := (B1 and $8)shr 3;
        SetOpName(hnRET);
        SetCmdArg(ntcallDist[F]);
        if not imInt(1) then Exit;
      end;
    48: begin
        F := (B1 and $8)shr 3;
        SetOpName(hnRET);
        SetCmdArg(ntcallDist[F]);
      end;
    49: begin
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnLES);
           if not ReadFarPtr then Exit;
         end
        else SetOpName(hn_);
      end;
    50: begin
        M := mode64;
        if (M and $1)=$0 then begin
           SetOpName(hnLDS);
           if not ReadFarPtr then Exit;
         end
        else SetOpName(hn_);
      end;
    51: begin
        W := B1 and $1;
        SetOpName(hnMOV);
        if not ReadM64Im(W) then Exit;
      end;
    52: begin
        SetOpName(hnENTER);
        if not imInt(1) then Exit;
        if not imInt(0) then Exit;
      end;
    53: SetOpName(hnLEAVE);
    54: begin
        SetOpName(hnINT);
        SetCmdArg(3);
      end;
    55: begin
        if not ReadByte(B2) then Exit;
        if {***}not(readFPEmul(B2)) then begin
          SetOpName(hnINT);
          SetCmdArg(B2);
        end;
      end;
    56: SetOpName(hnINTO);
    57: SetOpName(hnIRET);
    58: begin
        W := B1 and $1;
        if not readEA64(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        SetCmdArg(1);
      end;
    59: begin
        W := B1 and $1;
        if not readEA64(W,_1) then Exit;
        SetOpName(ntShftOp[_1]);
        SetCmdArg(hnCL);
      end;
    60: SetOpName(hnAAM);
    61: SetOpName(hnAAD);
    62: SetOpName(hnXLAT);
    63: begin
        N := B1 and $7;
        if {***}not(readFP(N)) then begin
          SetOpName(hnESC);
          SetCmdArg(N);
        end;
      end;
    64: begin
        L := B1 and $3;
        SetOpName(ntLoopS[L]);
        if not jmpOfs(0) then Exit;
      end;
    65: begin
        W := B1 and $1;
        SetOpName(hnIN);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        if not ImmedBW(0) then Exit;
      end;
    66: begin
        W := B1 and $1;
        SetOpName(hnOUT);
        if not ImmedBW(0) then Exit;
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
      end;
    67: begin
        SetOpName(hnCALL);
        if not JmpOfsW then Exit;
      end;
    68: begin
        SetOpName(hnJMP);
        if not JmpOfsW then Exit;
      end;
    69: begin
        SetOpName(hnJMP);
        if not imPtr then Exit;
      end;
    70: begin
        SetOpName(hnJMP);
        if not jmpOfs(0) then Exit;
      end;
    71: begin
        W := B1 and $1;
        SetOpName(hnIN);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
        SetCmdArg(hnDX);
      end;
    72: begin
        W := B1 and $1;
        SetOpName(hnOUT);
        SetCmdArg(hnDX);
        if not Reg(W,0,_1) then Exit;
        SetCmdArg(_1);
      end;
    73: begin
        SetOpPrefix(hnLOCK);
        if not readOP then Exit;
      end;
    74: begin
        SetOpPrefix(hnREPNE);
        if not readOP then Exit;
      end;
    75: begin
        SetOpPrefix(hnREPE);
        if not readOP then Exit;
      end;
    76: SetOpName(hnHALT);
    77: SetOpName(hnCMC);
    78: begin
        W := B1 and $1;
        if not readEA64(W,C) then Exit;
        SetOpName(ntGr1Op[C]);
        if (C and $F)=$0 then begin
           if not imW(W) then Exit;
         end;
      end;
    79: SetOpName(hnCLC);
    80: SetOpName(hnSTC);
    81: SetOpName(hnCLI);
    82: SetOpName(hnSTI);
    83: SetOpName(hnCLD);
    84: SetOpName(hnSTD);
    85: begin
        W := B1 and $1;
        if not readEA64(W,C) then Exit;
         begin
           H := (C and $6)shr 1;
           L := C and $1;
         end;
        case H and $3 of
          $0: SetOpName(ntGr3Op[L]);
          $3: if (W and $1)=$0 then SetOpName(hn_)
            else if (L and $1)=$0 then SetOpName(hnPUSH)
             else SetOpName(hn_);
          else if (W and $1)=$0 then SetOpName(hn_)
            else begin
               SetOpName(ntGr2Op[H]);
               SetCmdArg(ntcallDist[L]);
             end;
        end;
      end;
    else SetOpName(hn_);
  end;
  Result := true;
end ;

begin
  SegRegTbl := @ntSReg;
  RegTbl[false][0] := @ntRegB;
  RegTbl[false][1] := @ntReg16;
  RegTbl[false][2] := @ntReg32;
  RegTbl[false][3] := @ntReg64;
  RegTbl[true][0] := @ntRegB64;
  RegTbl[true][1] := RegTbl[false][1];
  RegTbl[true][2] := RegTbl[false][2];
  RegTbl[true][3] := RegTbl[false][3];
end .
