unit FastcodeCPUID;

{***** BEGIN LICENSE BLOCK *****
 Version: MPL 1.1

 The contents of this file are subject to the Mozilla Public License Version 1.1
 (the "License"); you may not use this file except in compliance with the
 License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 the specific language governing rights and limitations under the License.

 The Original Code is the FastCode CPUID code.

 The Initial Developer of the Original Code is
 Roelof Engelbrecht <roelof@cox-internet.com>. Portions created by
 the Initial Developer are Copyright (C) 2004 by the Initial Developer.
 All Rights Reserved.

 Contributor(s): Dennis Passmore <Dennis_Passmore@ ultimatesoftware.com>,
                 Dennis Christensen <marianndkc@home3.gvdnet.dk>,
                 Jouni Turunen <jouni.turunen@NOSPAM.xenex.fi>.

***** END LICENSE BLOCK *****

Version  Changes
-------  ------
 3.0.3   30 Aug 2006 : Official 2006 computed targets, uses Fastcode.inc now (reads FastcodeSizePenalties define)
 3.0.2   27 Apr 2006 : AMD X2 text changed from 'AMD_64_SSE3' to 'AMD_64X2'
 3.0.1   18 Apr 2006 : Bug in Yohan fctPMY target fixed, was incorrectly set to fctPMD
 3.0.0   27 Feb 2006 : Added new 2006 computed targets. Added Yonah and Presler
                       Removed Prescott, Banias, AMD XP                    (JT)

}

{$IFDEF VER170}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 18.0}
    {$WARN UNSAFE_CAST OFF}
  {$IFEND}
{$ENDIF}



interface

{$I Fastcode.inc}

type
  TVendor = (cvUnknown, cvAMD, cvCentaur, cvCyrix, cvIntel,
    cvTransmeta, cvNexGen, cvRise, cvUMC, cvNSC, cvSiS);
  {Note: when changing TVendor, also change VendorStr array below}

  TInstructions =
    (isFPU, {80x87}
    isTSC, {RDTSC}
    isCX8, {CMPXCHG8B}
    isSEP, {SYSENTER/SYSEXIT}
    isCMOV, {CMOVcc, and if isFPU, FCMOVcc/FCOMI}
    isMMX, {MMX}
    isFXSR, {FXSAVE/FXRSTOR}
    isSSE, {SSE}
    isSSE2, {SSE2}
    isSSE3, {SSE3*}
    isMONITOR, {MONITOR/MWAIT*}
    isCX16, {CMPXCHG16B*}
    isX64, {AMD AMD64* or Intel EM64T*}
    isExMMX, {MMX+ - AMD only}
    isEx3DNow, {3DNow!+ - AMD only}
    is3DNow); {3DNow! - AMD only}

  {Note: when changing TInstruction, also change InstructionSupportStr below
         * - instruction(s) not supported in Delphi 7 assembler}
  TInstructionSupport = set of TInstructions;

  TCPU = record
    Vendor: TVendor;
    Signature: Cardinal;
    EffFamily: Byte; {ExtendedFamily + Family}
    EffModel: Byte; {(ExtendedModel shl 4) + Model}
    EffModelBasic: Byte; {Just Model (not ExtendedModel shl 4) + Model)}
    CodeL1CacheSize, {KB or micro-ops for Pentium 4}
      DataL1CacheSize, {KB}
      L2CacheSize, {KB}
      L3CacheSize: Word; {KB}
    InstructionSupport: TInstructionSupport;
  end;

  TFastCodeTarget =
    (fctIA32,            {not specific to any CPU}
     fctIA32SizePenalty, {not specific to any CPU, In library routines with size penalties used This target was called "fctRTLReplacement" earlier}
     fctMMX,             {not specific to any CPU, requires FPU, MMX and CMOV  "Old fctBlended target"}
     fctSSE,             {not specific to any CPU, requires FPU, MMX, CMOV and SSE}
     fctSSESizePenalty,  {not specific to any CPU, requires FPU, MMX, CMOV and SSE. In library routines with size penalties used}
     fctSSE2,            {not specific to any CPU, requires FPU, MMX, CMOV, SSE, SSE2}
     fctPascal,           {use Pascal routines in library}
     fctPascalSizePenalty,{use Pascal routines with size penalty in library}
     fctPMD, {Dothan}
     fctPMY, {Yonah}
     fctP4N, {Northwood}
     fctP4R, {Presler}
     fctAmd64, {AMD 64}
     fctAmd64_SSE3); {X2/Opteron/Athlon FX/Athlon 64 with SSE3}
  {Note: when changing TFastCodeTarget, also change FastCodeTargetStr array
         below}


const
  VendorStr: array[Low(TVendor)..High(TVendor)] of ShortString =
  ('Unknown', 'AMD', 'Centaur (VIA)', 'Cyrix', 'Intel', 'Transmeta',
    'NexGen', 'Rise', 'UMC', 'National Semiconductor', 'SiS');

  InstructionSupportStr:
  array[Low(TInstructions)..High(TInstructions)] of ShortString =
    ('FPU', 'TSC', 'CX8', 'SEP', 'CMOV', 'MMX', 'FXSR', 'SSE', 'SSE2', 'SSE3',
    'MONITOR', 'CX16', 'X64', 'MMX+', '3DNow!+', '3DNow!');

  FastCodeTargetStr:
  array[Low(TFastCodeTarget)..High(TFastCodeTarget)] of ShortString =
    ('IA32', 'IA32_SizePenalty', 'MMX', 'SSE', 'SSE_SizePenalty', 'SSE2', 'Pascal', 'Pascal_SizePenalty',
    'Dothan', 'Yonah', 'Northwood', 'Presler', 'AMD_64', 'AMD_64X2');

var
  CPU: TCPU;
  FastCodeTarget: TFastCodeTarget;

implementation

type
  TRegisters = record
    EAX,
      EBX,
      ECX,
      EDX: Cardinal;
  end;

  TVendorStr = string[12];

  TCpuFeatures =
    ({in EDX}
    cfFPU, cfVME, cfDE, cfPSE, cfTSC, cfMSR, cfPAE, cfMCE,
    cfCX8, cfAPIC, cf_d10, cfSEP, cfMTRR, cfPGE, cfMCA, cfCMOV,
    cfPAT, cfPSE36, cfPSN, cfCLFSH, cf_d20, cfDS, cfACPI, cfMMX,
    cfFXSR, cfSSE, cfSSE2, cfSS, cfHTT, cfTM, cfIA_64, cfPBE,
    {in ECX}
    cfSSE3, cf_c1, cf_c2, cfMON, cfDS_CPL, cf_c5, cf_c6, cfEIST,
    cfTM2, cf_c9, cfCID, cf_c11, cf_c12, cfCX16, cfxTPR, cf_c15,
    cf_c16, cf_c17, cf_c18, cf_c19, cf_c20, cf_c21, cf_c22, cf_c23,
    cf_c24, cf_c25, cf_c26, cf_c27, cf_c28, cf_c29, cf_c30, cf_c31);
  TCpuFeatureSet = set of TCpuFeatures;

  TCpuExtendedFeatures =
    (cefFPU, cefVME, cefDE, cefPSE, cefTSC, cefMSR, cefPAE, cefMCE,
    cefCX8, cefAPIC, cef_10, cefSEP, cefMTRR, cefPGE, cefMCA, cefCMOV,
    cefPAT, cefPSE36, cef_18, ceMPC, ceNX, cef_21, cefExMMX, cefMMX,
    cefFXSR, cef_25, cef_26, cef_27, cef_28, cefLM, cefEx3DNow, cef3DNow);
  TCpuExtendedFeatureSet = set of TCpuExtendedFeatures;

const
  VendorIDString: array[Low(TVendor)..High(TVendor)] of TVendorStr =
  ('',
    'AuthenticAMD', 'CentaurHauls', 'CyrixInstead', 'GenuineIntel',
    'GenuineTMx86', 'NexGenDriven', 'RiseRiseRise', 'UMC UMC UMC ',
    'Geode by NSC', 'SiS SiS SiS');

  {CPU signatures}

  IntelLowestSEPSupportSignature = $633;
  K7DuronA0Signature = $630;
  C3Samuel2EffModel = 7;
  C3EzraEffModel = 8;
  PMBaniasEffModel = 9;
  PMDothanEffModel = $D;
  PMYonahEffModel = $E;
  P3LowestEffModel = 7;

function IsCPUID_Available: Boolean; register;
asm
  PUSHFD                 {save EFLAGS to stack}
  POP     EAX            {store EFLAGS in EAX}
  MOV     EDX, EAX       {save in EDX for later testing}
  XOR     EAX, $200000;  {flip ID bit in EFLAGS}
  PUSH    EAX            {save new EFLAGS value on stack}
  POPFD                  {replace current EFLAGS value}
  PUSHFD                 {get new EFLAGS}
  POP     EAX            {store new EFLAGS in EAX}
  XOR     EAX, EDX       {check if ID bit changed}
  JZ      @exit          {no, CPUID not available}
  MOV     EAX, True      {yes, CPUID is available}
@exit:
end;

function IsFPU_Available: Boolean;
var
  _FCW, _FSW: Word;
asm
  MOV     EAX, False     {initialize return register}
  MOV     _FSW, $5A5A    {store a non-zero value}
  FNINIT                 {must use non-wait form}
  FNSTSW  _FSW           {store the status}
  CMP     _FSW, 0        {was the correct status read?}
  JNE     @exit          {no, FPU not available}
  FNSTCW  _FCW           {yes, now save control word}
  MOV     DX, _FCW       {get the control word}
  AND     DX, $103F      {mask the proper status bits}
  CMP     DX, $3F        {is a numeric processor installed?}
  JNE     @exit          {no, FPU not installed}
  MOV     EAX, True      {yes, FPU is installed}
@exit:
end;

procedure GetCPUID(Param: Cardinal; var Registers: TRegisters);
asm
  PUSH    EBX                         {save affected registers}
  PUSH    EDI
  MOV     EDI, Registers
  XOR     EBX, EBX                    {clear EBX register}
  XOR     ECX, ECX                    {clear ECX register}
  XOR     EDX, EDX                    {clear EDX register}
  DB $0F, $A2                         {CPUID opcode}
  MOV     TRegisters(EDI).&EAX, EAX   {save EAX register}
  MOV     TRegisters(EDI).&EBX, EBX   {save EBX register}
  MOV     TRegisters(EDI).&ECX, ECX   {save ECX register}
  MOV     TRegisters(EDI).&EDX, EDX   {save EDX register}
  POP     EDI                         {restore registers}
  POP     EBX
end;

procedure GetCPUVendor;
var
  VendorStr: TVendorStr;
  Registers: TRegisters;
begin
  {call CPUID function 0}
  GetCPUID(0, Registers);

  {get vendor string}
  SetLength(VendorStr, 12);
  Move(Registers.EBX, VendorStr[1], 4);
  Move(Registers.EDX, VendorStr[5], 4);
  Move(Registers.ECX, VendorStr[9], 4);

  {get CPU vendor from vendor string}
  CPU.Vendor := High(TVendor);
  while (VendorStr <> VendorIDString[CPU.Vendor]) and
    (CPU.Vendor > Low(TVendor)) do
    Dec(CPU.Vendor);
end;

procedure GetCPUFeatures;
{preconditions: 1. maximum CPUID must be at least $00000001
                2. GetCPUVendor must have been called}
type
  _Int64 = packed record
    Lo: Longword;
    Hi: Longword;
  end;
var
  Registers: TRegisters;
  CpuFeatures: TCpuFeatureSet;
begin
  {call CPUID function $00000001}
  GetCPUID($00000001, Registers);

  {get CPU signature}
  CPU.Signature := Registers.EAX;

  {extract effective processor family and model}
  CPU.EffFamily := CPU.Signature and $00000F00 shr 8;
  CPU.EffModel := CPU.Signature and $000000F0 shr 4;
  CPU.EffModelBasic := CPU.EffModel;
  if CPU.EffFamily = $F then
  begin
    CPU.EffFamily := CPU.EffFamily + (CPU.Signature and $0FF00000 shr 20);
    CPU.EffModel := CPU.EffModel + (CPU.Signature and $000F0000 shr 12);
  end;

  {get CPU features}
  Move(Registers.EDX, _Int64(CpuFeatures).Lo, 4);
  Move(Registers.ECX, _Int64(CpuFeatures).Hi, 4);

  {get instruction support}
  if cfFPU in CpuFeatures then
    Include(CPU.InstructionSupport, isFPU);
  if cfTSC in CpuFeatures then
    Include(CPU.InstructionSupport, isTSC);
  if cfCX8 in CpuFeatures then
    Include(CPU.InstructionSupport, isCX8);
  if cfSEP in CpuFeatures then
  begin
    Include(CPU.InstructionSupport, isSEP);
    {for Intel CPUs, qualify the processor family and model to ensure that the
     SYSENTER/SYSEXIT instructions are actually present - see Intel Application
     Note AP-485}
    if (CPU.Vendor = cvIntel) and
      (CPU.Signature and $0FFF3FFF < IntelLowestSEPSupportSignature) then
      Exclude(CPU.InstructionSupport, isSEP);
  end;
  if cfCMOV in CpuFeatures then
    Include(CPU.InstructionSupport, isCMOV);
  if cfFXSR in CpuFeatures then
    Include(CPU.InstructionSupport, isFXSR);
  if cfMMX in CpuFeatures then
    Include(CPU.InstructionSupport, isMMX);
  if cfSSE in CpuFeatures then
    Include(CPU.InstructionSupport, isSSE);
  if cfSSE2 in CpuFeatures then
    Include(CPU.InstructionSupport, isSSE2);
  if cfSSE3 in CpuFeatures then
    Include(CPU.InstructionSupport, isSSE3);
  if (CPU.Vendor = cvIntel) and (cfMON in CpuFeatures) then
    Include(CPU.InstructionSupport, isMONITOR);
  if cfCX16 in CpuFeatures then
    Include(CPU.InstructionSupport, isCX16);
end;

procedure GetCPUExtendedFeatures;
{preconditions: maximum extended CPUID >= $80000001}
var
  Registers: TRegisters;
  CpuExFeatures: TCpuExtendedFeatureSet;
begin
  {call CPUID function $80000001}
  GetCPUID($80000001, Registers);

  {get CPU extended features}
  CPUExFeatures := TCPUExtendedFeatureSet(Registers.EDX);

  {get instruction support}
  if cefLM in CpuExFeatures then
    Include(CPU.InstructionSupport, isX64);
  if cefExMMX in CpuExFeatures then
    Include(CPU.InstructionSupport, isExMMX);
  if cefEx3DNow in CpuExFeatures then
    Include(CPU.InstructionSupport, isEx3DNow);
  if cef3DNow in CpuExFeatures then
    Include(CPU.InstructionSupport, is3DNow);
end;

procedure GetProcessorCacheInfo;
{preconditions: 1. maximum CPUID must be at least $00000002
                2. GetCPUVendor must have been called}
type
  TConfigDescriptor = packed array[0..15] of Byte;
var
  Registers: TRegisters;
  i, j: Integer;
  QueryCount: Byte;
begin
  {call CPUID function 2}
  GetCPUID($00000002, Registers);
  QueryCount := Registers.EAX and $FF;
  for i := 1 to QueryCount do
  begin
    for j := 1 to 15 do
      with CPU do
        {decode configuration descriptor byte}
        case TConfigDescriptor(Registers)[j] of
          $06: CodeL1CacheSize := 8;
          $08: CodeL1CacheSize := 16;
          $0A: DataL1CacheSize := 8;
          $0C: DataL1CacheSize := 16;
          $22: L3CacheSize := 512;
          $23: L3CacheSize := 1024;
          $25: L3CacheSize := 2048;
          $29: L3CacheSize := 4096;
          $2C: DataL1CacheSize := 32;
          $30: CodeL1CacheSize := 32;
          $39: L2CacheSize := 128;
          $3B: L2CacheSize := 128;
          $3C: L2CacheSize := 256;
          $40: {no 2nd-level cache or, if processor contains a valid 2nd-level
                cache, no 3rd-level cache}
            if L2CacheSize <> 0 then
              L3CacheSize := 0;
          $41: L2CacheSize := 128;
          $42: L2CacheSize := 256;
          $43: L2CacheSize := 512;
          $44: L2CacheSize := 1024;
          $45: L2CacheSize := 2048;
          $60: DataL1CacheSize := 16;
          $66: DataL1CacheSize := 8;
          $67: DataL1CacheSize := 16;
          $68: DataL1CacheSize := 32;
          $70: if not (CPU.Vendor in [cvCyrix, cvNSC]) then
              CodeL1CacheSize := 12; {K micro-ops}
          $71: CodeL1CacheSize := 16; {K micro-ops}
          $72: CodeL1CacheSize := 32; {K micro-ops}
          $78: L2CacheSize := 1024;
          $79: L2CacheSize := 128;
          $7A: L2CacheSize := 256;
          $7B: L2CacheSize := 512;
          $7C: L2CacheSize := 1024;
          $7D: L2CacheSize := 2048;
          $7F: L2CacheSize := 512;
          $80: if CPU.Vendor in [cvCyrix, cvNSC] then
            begin {Cyrix and NSC only - 16 KB unified L1 cache}
              CodeL1CacheSize := 8;
              DataL1CacheSize := 8;
            end;
          $82: L2CacheSize := 256;
          $83: L2CacheSize := 512;
          $84: L2CacheSize := 1024;
          $85: L2CacheSize := 2048;
          $86: L2CacheSize := 512;
          $87: L2CacheSize := 1024;
        end;
    if i < QueryCount then
      GetCPUID(2, Registers);
  end;
end;

procedure GetExtendedProcessorCacheInfo;
{preconditions: 1. maximum extended CPUID must be at least $80000006
                2. GetCPUVendor and GetCPUFeatures must have been called}
var
  Registers: TRegisters;
begin
  {call CPUID function $80000005}
  GetCPUID($80000005, Registers);

  {get L1 cache size}
  {Note: Intel does not support function $80000005 for L1 cache size, so ignore.
         Cyrix returns CPUID function 2 descriptors (already done), so ignore.}
  if not (CPU.Vendor in [cvIntel, cvCyrix]) then
  begin
    CPU.CodeL1CacheSize := Registers.EDX shr 24;
    CPU.DataL1CacheSize := Registers.ECX shr 24;
  end;

  {call CPUID function $80000006}
  GetCPUID($80000006, Registers);

  {get L2 cache size}
  if (CPU.Vendor = cvAMD) and (CPU.Signature and $FFF = K7DuronA0Signature) then
    {workaround for AMD Duron Rev A0 L2 cache size erratum - see AMD Technical
     Note TN-13}
    CPU.L2CacheSize := 64
  else if (CPU.Vendor = cvCentaur) and (CPU.EffFamily = 6) and
    (CPU.EffModel in [C3Samuel2EffModel, C3EzraEffModel]) then
    {handle VIA (Centaur) C3 Samuel 2 and Ezra non-standard encoding}
    CPU.L2CacheSize := Registers.ECX shr 24
  else {standard encoding}
    CPU.L2CacheSize := Registers.ECX shr 16;
end;

procedure VerifyOSSupportForXMMRegisters;
begin
  {try a SSE instruction that operates on XMM registers}
  try
    asm
      DB $0F, $54, $C0  // ANDPS XMM0, XMM0
    end
  except
    begin
      {if it fails, assume that none of the SSE instruction sets are available}
      Exclude(CPU.InstructionSupport, isSSE);
      Exclude(CPU.InstructionSupport, isSSE2);
      Exclude(CPU.InstructionSupport, isSSE3);
    end;
  end;
end;

procedure GetCPUInfo;
var
  Registers: TRegisters;
  MaxCPUID: Cardinal;
  MaxExCPUID: Cardinal;
begin
  {initialize - just to be sure}
  FillChar(CPU, SizeOf(CPU), 0);

  try
    if not IsCPUID_Available then
    begin
      if IsFPU_Available then
        Include(CPU.InstructionSupport, isFPU);
    end
    else
    begin
      {get maximum CPUID input value}
      GetCPUID($00000000, Registers);
      MaxCPUID := Registers.EAX;

      {get CPU vendor - Max CPUID will always be >= 0}
      GetCPUVendor;

      {get CPU features if available}
      if MaxCPUID >= $00000001 then
        GetCPUFeatures;

      {get cache info if available}
      if MaxCPUID >= $00000002 then
        GetProcessorCacheInfo;

      {get maximum extended CPUID input value}
      GetCPUID($80000000, Registers);
      MaxExCPUID := Registers.EAX;

      {get CPU extended features if available}
      if MaxExCPUID >= $80000001 then
        GetCPUExtendedFeatures;

      {verify operating system support for XMM registers}
      if isSSE in CPU.InstructionSupport then
        VerifyOSSupportForXMMRegisters;

      {get extended cache features if available}
      {Note: ignore processors that only report L1 cache info,
             i.e. have a MaxExCPUID = $80000005}
      if MaxExCPUID >= $80000006 then
        GetExtendedProcessorCacheInfo;
    end;
  except
      {silent exception - should not occur, just ignore}
  end;
end;

procedure GetFastCodeTarget;
{precondition: GetCPUInfo must have been called}
begin
 {$IFDEF FastcodeSizePenalties}
   FastCodeTarget := fctIA32SizePenalty;
 {$ELSE}
   FastCodeTarget := fctIA32;
 {$ENDIF}

  if (isSSE2 in CPU.InstructionSupport) then
    FastCodeTarget := fctSSE2 else
  if (isSSE in CPU.InstructionSupport) then
   {$IFDEF FastcodeSizePenalties}
    FastCodeTarget := fctSSESizePenalty
   {$ELSE}
    FastCodeTarget := fctSSE
   {$ENDIF}
   else
  if ([isFPU, isMMX, isCMOV] <= CPU.InstructionSupport) then
    FastCodeTarget := fctMMX;

  case CPU.Vendor of
    cvIntel:
      case CPU.EffFamily of
        6: {Intel P6, P2, P3, PM}
           case CPU.EffModel of
            PMDothanEffModel : FastCodeTarget := fctPMD; // Dothan
            PMYonahEffModel  : FastCodeTarget := fctPMY; // Yonah
           end;
        $F: {Intel P4}
           case CPU.EffModel of
            0,1,2 : FastCodeTarget := fctP4N; // Northwood
            6     : FastCodeTarget := fctP4R; // Presler
           end;
      end;
    cvAMD:
      case CPU.EffFamily of
        $F: {AMD K8}
           if ((CPU.EffModelBasic=$B) or (CPU.EffModelBasic=$3)) and (isSSE3 in CPU.InstructionSupport) then
            FastCodeTarget := fctAmd64_SSE3 //AMD X2 dual core CPU
           else
            FastCodeTarget := fctAmd64;
      end;
  end;

 {$IFDEF FastcodePascal}
   FastCodeTarget := fctPascal;
 {$ENDIF}
 {$IFDEF FastcodePascalSizePenalty}
   FastCodeTarget := fctPascalSizePenalty;
 {$ENDIF}

end;

initialization
  GetCPUInfo;
  GetFastCodeTarget;
end.

