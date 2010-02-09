unit DasmMSIL;
(*
The MSIL disassembler main module of the DCU32INT utility
by Alexei Hmelnov.
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
  DasmDefs,FixUp;

type
  PMSILHeader = ^TMSILHeader;
  TMSILHeader = packed record
    F,F1: Word;
    CodeSz: Cardinal;
    L1: LongInt;
  end ;

procedure SetMSILDisassembler;

implementation

uses
  DCU_In,DCU_Out;

const
 {Command argument type}
  atVoid = 0;
  atU1 = 1;
  atU2 = 2;
  atU4 = 3;
  atI1 = 4;
  atI4 = 5;
  atI8 = 6;
  atR4 = 7;
  atR8 = 8;
  atMetadata = 9;
  atCheckKind = 10;
  atJmpofs1 = 11;
  atJmpofs4 = 12;
  atJmpofs4tbl =13;
  atExtTbl = 14;

  atMask = $0F;

 {Command Kind}
  ckPrefix = $80;
  ckStop = $40; //Stops command sequence

const
  argszVariable = -1;
  argszWrong = -2;

  CmdArgSize: array[0..atMask]of integer = (
    0{atVoid = 0},1{atU1 = 1},2{atU2 = 2},4{atU4 = 3},
    1{atI1 = 4},4{atI4 = 5},8{atI8 = 6},4{atR4 = 7},
    8{atR8 = 8},4{atMetadata = 9},1{atCheckKind = 10},1{atJmpofs1 = 11},
    4{atJmpofs4 = 12},argszVariable{atJmpofs4tbl=13},argszVariable{atExtTbl = 14},
    argszWrong);

MetadataTbl: array[$00..$2C] of PChar = (
  'Module' {0x00},
  'TypeRef' {0x01},
  'TypeDef' {0x02},
  '',
  'Field' {0x04},
  '',
  'MethodDef' {0x06},
  '',
  'Param' {0x08},
  'InterfaceImpl' {0x09},
  'MemberRef' {0x0A},
  'Constant' {0x0B},
  'CustomAttribute' {0x0C},
  'FieldMarshal' {0x0D},
  'DeclSecurity' {0x0E},
  'ClassLayout' {0x0F},
  'FieldLayout' {0x10},
  'StandAloneSig' {0x11},
  'EventMap' {0x12},
  '',
  'Event' {0x14},
  'PropertyMap' {0x15},
  '',
  'Property' {0x17},
  'MethodSemantics' {0x18},
  'MethodImpl' {0x19},
  'ModuleRef' {0x1A},
  'TypeSpec' {0x1B},
  'ImplMap' {0x1C},
  'FieldRVA' {0x1D},
  '',
  '',
  'Assembly' {0x20},
  'AssemblyProcessor' {0x21},
  'AssemblyOS' {0x22},
  'AssemblyRef' {0x23},
  'AssemblyRefProcessor' {0x24},
  'AssemblyRefOS' {0x25},
  'File' {0x26},
  'ExportedType' {0x27},
  'ManifestResource' {0x28},
  'NestedClass' {0x29},
  'GenericParam' {0x2A},
  'MethodSpec' {0x2B},
  'GenericParamConstraint' {0x2C}
);

CheckKindTbl: array[$0..$2] of PChar = (
  'typecheck'{0x1},
  'rangecheck'{0x2},
  'nullcheck'{0x4});

type
  PCmdInfo = ^TCmdInfo;
  TCmdInfo = record
    Name: PChar;
    F: integer;
  end ;

  PCmdInfoTbl = ^TCmdInfoTbl;
  TCmdInfoTbl = array[byte]of TCmdInfo;

  PStrTbl = ^TStrTbl;
  TStrTbl = array[byte]of PChar;

const
  CmdTblFE: array[0..$1E] of TCmdInfo = (
    (Name: 'arglist'; {0x00}),
    (Name: 'ceq'; {0x01}),
    (Name: 'cgt'; {0x02}),
    (Name: 'cgt_un'; {0x03}),
    (Name: 'clt'; {0x04}),
    (Name: 'clt_un'; {0x05}),
    (Name: 'ldftn'; F: atMetadata {0x06}),
    (Name: 'ldvirtftn'; F: atMetadata {0x07}),
    (Name: ''; {0x08}),
    (Name: 'ldarg'; {0x09}),
    (Name: 'ldarga'; {0x0A}),
    (Name: 'starg'; {0x0B}),
    (Name: 'ldloc'; {0x0C}),
    (Name: 'ldloca'; {0x0D}),
    (Name: 'stloc'; {0x0E}),
    (Name: 'localloc'; {0x0F}),
    (Name: ''; {0x10}),
    (Name: 'endfilter'; {0x11}),
    (Name: 'unaligned_'; F: atU1 or ckPrefix {0x12}), //prefix - operand may be not aligned on alignment specified
    (Name: 'volatile_'; F: ckPrefix {0x13}), //prefix
    (Name: 'tail_'; F: ckPrefix or ckStop{0x14}), //call terminates current method (like Halt or raise)
    (Name: 'initobj'; F: atMetadata {0x15}),
    (Name: 'constrained_'; F: atMetadata or ckPrefix {0x16}), //prefix for callvirt
    (Name: 'cpblk'; {0x17}),
    (Name: 'initblk'; {0x18}),
    (Name: 'no_'; F: atCheckKind or ckPrefix {0x19}), //prefix - skip check
    (Name: 'rethrow'; {0x1A}),
    (Name: ''; {0x1B}),
    (Name: 'sizeof'; F: atMetadata {0x1C}),
    (Name: 'refanytype'; {0x1D}),
    (Name: 'readonly_'; F: ckPrefix {0x1E}) //prefix
  );


  CmdTbl: array[byte] of TCmdInfo = (
    (Name: 'nop'; {0x00}),
    (Name: 'break'; F: ckStop {0x01}),
    (Name: 'ldarg_0'; {0x02}),
    (Name: 'ldarg_1'; {0x03}),
    (Name: 'ldarg_2'; {0x04}),
    (Name: 'ldarg_3'; {0x05}),
    (Name: 'ldloc_0'; {0x06}),
    (Name: 'ldloc_1'; {0x07}),
    (Name: 'ldloc_2'; {0x08}),
    (Name: 'ldloc_3'; {0x09}),
    (Name: 'stloc_0'; {0x0A}),
    (Name: 'stloc_1'; {0x0B}),
    (Name: 'stloc_2'; {0x0C}),
    (Name: 'stloc_3'; {0x0D}),
    (Name: 'ldarg_s'; F: atU1 {0x0E}),
    (Name: 'ldarga_s'; F: atU1 {0x0F}),
    (Name: 'starg_s'; F: atU1 {0x10}),
    (Name: 'ldloc_s'; F: atU1 {0x11}),
    (Name: 'ldloca_s'; F: atU1 {0x12}),
    (Name: 'stloc_s'; F: atU1 {0x13}),
    (Name: 'ldnull'; {0x14}),
    (Name: 'ldc_i4_m1'; {0x15}),
    (Name: 'ldc_i4_0'; {0x16}),
    (Name: 'ldc_i4_1'; {0x17}),
    (Name: 'ldc_i4_2'; {0x18}),
    (Name: 'ldc_i4_3'; {0x19}),
    (Name: 'ldc_i4_4'; {0x1A}),
    (Name: 'ldc_i4_5'; {0x1B}),
    (Name: 'ldc_i4_6'; {0x1C}),
    (Name: 'ldc_i4_7'; {0x1D}),
    (Name: 'ldc_i4_8'; {0x1E}),
    (Name: 'ldc_i4_s'; F: atI1 {0x1F}),
    (Name: 'ldc_i4'; F: atI4 {0x20}),
    (Name: 'ldc_i8'; F: atI8 {0x21}),
    (Name: 'ldc_r4'; F: atR4 {0x22}),
    (Name: 'ldc_r8'; F: atR8 {0x23}),
    (Name: ''; {0x24}),
    (Name: 'dup'; {0x25}),
    (Name: 'pop'; {0x26}),
    (Name: 'jmp'; F: atMetadata or ckStop{0x27}),
    (Name: 'call'; F: atMetadata {0x28}),
    (Name: 'calli'; F: atMetadata {0x29}),
    (Name: 'ret'; F: ckStop {0x2A}),
    (Name: 'br_s'; F: atJmpofs1 or ckStop {0x2B}),
    (Name: 'brfalse_s'; F: atJmpofs1 {0x2C}),
    (Name: 'brtrue_s'; F: atJmpofs1 {0x2D}),
    (Name: 'beq_s'; F: atJmpofs1 {0x2E}),
    (Name: 'bge_s'; F: atJmpofs1 {0x2F}),
    (Name: 'bgt_s'; F: atJmpofs1 {0x30}),
    (Name: 'ble_s'; F: atJmpofs1 {0x31}),
    (Name: 'blt_s'; F: atJmpofs1 {0x32}),
    (Name: 'bne_un_s'; F: atJmpofs1 {0x33}),
    (Name: 'bge_un_s'; F: atJmpofs1 {0x34}),
    (Name: 'bgt_un_s'; F: atJmpofs1 {0x35}),
    (Name: 'ble_un_s'; F: atJmpofs1 {0x36}),
    (Name: 'blt_un_s'; F: atJmpofs1 {0x37}),
    (Name: 'br'; F: atJmpofs4 or ckStop {0x38}),
    (Name: 'brfalse'; F: atJmpofs4 {0x39}),
    (Name: 'brtrue'; F: atJmpofs4 {0x3A}),
    (Name: 'beq'; F: atJmpofs4 {0x3B}),
    (Name: 'bge'; F: atJmpofs4 {0x3C}),
    (Name: 'bgt'; F: atJmpofs4 {0x3D}),
    (Name: 'ble'; F: atJmpofs4 {0x3E}),
    (Name: 'blt'; F: atJmpofs4 {0x3F}),
    (Name: 'bne_un'; F: atJmpofs4 {0x40}),
    (Name: 'bge_un'; F: atJmpofs4 {0x41}),
    (Name: 'bgt_un'; F: atJmpofs4 {0x42}),
    (Name: 'ble_un'; F: atJmpofs4 {0x43}),
    (Name: 'blt_un'; F: atJmpofs4 {0x44}),
    (Name: 'switch'; F: atJmpofs4tbl {0x45}),
    (Name: 'ldind_i1'; {0x46}),
    (Name: 'ldind_u1'; {0x47}),
    (Name: 'ldind_i2'; {0x48}),
    (Name: 'ldind_u2'; {0x49}),
    (Name: 'ldind_i4'; {0x4A}),
    (Name: 'ldind_u4'; {0x4B}),
    (Name: 'ldind_i8'; {0x4C}),
    (Name: 'ldind_i'; {0x4D}),
    (Name: 'ldind_r4'; {0x4E}),
    (Name: 'ldind_r8'; {0x4F}),
    (Name: 'ldind_ref'; {0x50}),
    (Name: 'stind_ref'; {0x51}),
    (Name: 'stind_i1'; {0x52}),
    (Name: 'stind_i2'; {0x53}),
    (Name: 'stind_i4'; {0x54}),
    (Name: 'stind_i8'; {0x55}),
    (Name: 'stind_r4'; {0x56}),
    (Name: 'stind_r8'; {0x57}),
    (Name: 'add'; {0x58}),
    (Name: 'sub'; {0x59}),
    (Name: 'mul'; {0x5A}),
    (Name: 'div'; {0x5B}),
    (Name: 'div_un'; {0x5C}),
    (Name: 'rem'; {0x5D}),
    (Name: 'rem_un'; {0x5E}),
    (Name: 'and'; {0x5F}),
    (Name: 'or'; {0x60}),
    (Name: 'xor'; {0x61}),
    (Name: 'shl'; {0x62}),
    (Name: 'shr'; {0x63}),
    (Name: 'shr_un'; {0x64}),
    (Name: 'neg'; {0x65}),
    (Name: 'not'; {0x66}),
    (Name: 'conv_i1'; {0x67}),
    (Name: 'conv_i2'; {0x68}),
    (Name: 'conv_i4'; {0x69}),
    (Name: 'conv_i8'; {0x6A}),
    (Name: 'conv_r4'; {0x6B}),
    (Name: 'conv_r8'; {0x6C}),
    (Name: 'conv_u4'; {0x6D}),
    (Name: 'conv_u8'; {0x6E}),
    (Name: 'callvirt'; F: atMetadata {0x6F}),
    (Name: 'cpobj'; F: atMetadata {0x70}),
    (Name: 'ldobj'; F: atMetadata {0x71}),
    (Name: 'ldstr'; F: atMetadata {0x72}),
    (Name: 'newobj'; F: atMetadata {0x73}),
    (Name: 'castclass'; F: atMetadata {0x74}),
    (Name: 'isinst'; F: atMetadata {0x75}),
    (Name: 'conv_r_un'; {0x76}),
    (Name: ''; {0x77}),
    (Name: ''; {0x78}),
    (Name: 'unbox'; F: atMetadata {0x79}),
    (Name: 'throw'; F: ckStop {0x7A}),
    (Name: 'ldfld'; F: atMetadata {0x7B}),
    (Name: 'ldflda'; F: atMetadata {0x7C}),
    (Name: 'stfld'; F: atMetadata {0x7D}),
    (Name: 'ldsfld'; F: atMetadata {0x7E}),
    (Name: 'ldsflda'; F: atMetadata {0x7F}),
    (Name: 'stsfld'; F: atMetadata {0x80}),
    (Name: 'stobj'; F: atMetadata {0x81}),
    (Name: 'conv_ovf_i1_un'; {0x82}),
    (Name: 'conv_ovf_i2_un'; {0x83}),
    (Name: 'conv_ovf_i4_un'; {0x84}),
    (Name: 'conv_ovf_i8_un'; {0x85}),
    (Name: 'conv_ovf_u1_un'; {0x86}),
    (Name: 'conv_ovf_u2_un'; {0x87}),
    (Name: 'conv_ovf_u4_un'; {0x88}),
    (Name: 'conv_ovf_u8_un'; {0x89}),
    (Name: 'conv_ovf_i_un'; {0x8A}),
    (Name: 'conv_ovf_u_un'; {0x8B}),
    (Name: 'box'; F: atMetadata {0x8C}),
    (Name: 'newarr'; F: atMetadata {0x8D}),
    (Name: 'ldlen'; {0x8E}),
    (Name: 'ldelema'; F: atMetadata {0x8F}),
    (Name: 'ldelem_i1'; {0x90}),
    (Name: 'ldelem_u1'; {0x91}),
    (Name: 'ldelem_i2'; {0x92}),
    (Name: 'ldelem_u2'; {0x93}),
    (Name: 'ldelem_i4'; {0x94}),
    (Name: 'ldelem_u4'; {0x95}),
    (Name: 'ldelem_i8'; {0x96}),
    (Name: 'ldelem_i'; {0x97}),
    (Name: 'ldelem_r4'; {0x98}),
    (Name: 'ldelem_r8'; {0x99}),
    (Name: 'ldelem_ref'; {0x9A}),
    (Name: 'stelem_i'; {0x9B}),
    (Name: 'stelem_i1'; {0x9C}),
    (Name: 'stelem_i2'; {0x9D}),
    (Name: 'stelem_i4'; {0x9E}),
    (Name: 'stelem_i8'; {0x9F}),
    (Name: 'stelem_r4'; {0xA0}),
    (Name: 'stelem_r8'; {0xA1}),
    (Name: 'stelem_ref'; {0xA2}),
    (Name: 'ldelem'; F: atMetadata {0xA3}),
    (Name: 'stelem'; F: atMetadata {0xA4}),
    (Name: 'unbox_any'; F: atMetadata {0xA5}),
    (Name: ''; {0xA6}),
    (Name: ''; {0xA7}),
    (Name: ''; {0xA8}),
    (Name: ''; {0xA9}),
    (Name: ''; {0xAA}),
    (Name: ''; {0xAB}),
    (Name: ''; {0xAC}),
    (Name: ''; {0xAD}),
    (Name: ''; {0xAE}),
    (Name: ''; {0xAF}),
    (Name: ''; {0xB0}),
    (Name: ''; {0xB1}),
    (Name: ''; {0xB2}),
    (Name: 'conv_ovf_i1'; {0xB3}),
    (Name: 'conv_ovf_u1'; {0xB4}),
    (Name: 'conv_ovf_i2'; {0xB5}),
    (Name: 'conv_ovf_u2'; {0xB6}),
    (Name: 'conv_ovf_i4'; {0xB7}),
    (Name: 'conv_ovf_u4'; {0xB8}),
    (Name: 'conv_ovf_i8'; {0xB9}),
    (Name: 'conv_ovf_u8'; {0xBA}),
    (Name: ''; {0xBB}),
    (Name: ''; {0xBC}),
    (Name: ''; {0xBD}),
    (Name: ''; {0xBE}),
    (Name: ''; {0xBF}),
    (Name: ''; {0xC0}),
    (Name: ''; {0xC1}),
    (Name: 'refanyval'; F: atMetadata {0xC2}),
    (Name: 'ckfinite'; {0xC3}),
    (Name: ''; {0xC4}),
    (Name: ''; {0xC5}),
    (Name: 'mkrefany'; F: atMetadata {0xC6}),
    (Name: ''; {0xC7}),
    (Name: ''; {0xC8}),
    (Name: ''; {0xC9}),
    (Name: ''; {0xCA}),
    (Name: ''; {0xCB}),
    (Name: ''; {0xCC}),
    (Name: ''; {0xCD}),
    (Name: ''; {0xCE}),
    (Name: ''; {0xCF}),
    (Name: 'ldtoken'; F: atMetadata {0xD0}),
    (Name: 'conv_u2'; {0xD1}),
    (Name: 'conv_u1'; {0xD2}),
    (Name: 'conv_i'; {0xD3}),
    (Name: 'conv_ovf_i'; {0xD4}),
    (Name: 'conv_ovf_u'; {0xD5}),
    (Name: 'add_ovf'; {0xD6}),
    (Name: 'add_ovf_un'; {0xD7}),
    (Name: 'mul_ovf'; {0xD8}),
    (Name: 'mul_ovf_un'; {0xD9}),
    (Name: 'sub_ovf'; {0xDA}),
    (Name: 'sub_ovf_un'; {0xDB}),
    (Name: 'endfinally'; {0xDC}),
    (Name: 'leave'; F: atJmpofs4 {0xDD}),
    (Name: 'leave_s'; F: atJmpofs1 {0xDE}),
    (Name: 'stind_i'; {0xDF}),
    (Name: 'conv_u'; {0xE0}),
    (Name: ''; {0xE1}),
    (Name: ''; {0xE2}),
    (Name: ''; {0xE3}),
    (Name: ''; {0xE4}),
    (Name: ''; {0xE5}),
    (Name: ''; {0xE6}),
    (Name: ''; {0xE7}),
    (Name: ''; {0xE8}),
    (Name: ''; {0xE9}),
    (Name: ''; {0xEA}),
    (Name: ''; {0xEB}),
    (Name: ''; {0xEC}),
    (Name: ''; {0xED}),
    (Name: ''; {0xEE}),
    (Name: ''; {0xEF}),
    (Name: ''; {0xF0}),
    (Name: ''; {0xF1}),
    (Name: ''; {0xF2}),
    (Name: ''; {0xF3}),
    (Name: ''; {0xF4}),
    (Name: ''; {0xF5}),
    (Name: ''; {0xF6}),
    (Name: ''; {0xF7}),
    (Name: ''; {0xF8}),
    (Name: ''; {0xF9}),
    (Name: ''; {0xFA}),
    (Name: ''; {0xFB}),
    (Name: ''; {0xFC}),
    (Name: ''; {0xFD}),
    (Name: '_EXT'; F: atExtTbl {0xFE}),
    (Name: ''; {0xFF})
  );

function ReadCodeByte(var B: Byte): boolean;
{ This procedure can use fixup information to prevent parsing commands }
{ which contradict fixups }
{Was copied here just in case that something is different with MSIL Fixups}
begin
  Result := ChkNoFixupIn(CodePtr,1);
  if not Result then
    Exit;
  B := Byte(CodePtr^);
  Inc(CodePtr);
  Result := true;
end ;

function ReadCodeInt(var V: integer): boolean;
{ This procedure can use fixup information to prevent parsing commands }
{ which contradict fixups }
begin
  Result := ChkNoFixupIn(CodePtr,4);
  if not Result then
    Exit;
  V := integer(Pointer(CodePtr)^);
  Inc(CodePtr,SizeOf(integer));
  Result := true;
end ;

procedure SkipCode(Size: Cardinal);
begin
  Inc(CodePtr,Size);
end ;

type
  TCmdAction = procedure(CI: PCmdInfo; DP: Pointer; IP: Pointer);

function ProcessCommand(Action: TCmdAction; IP: Pointer): boolean;
var
  opC: Byte;
  F,Sz: integer;
  PCmdTbl: PCmdInfoTbl;
  DP: Pointer;
  CmdTblHi: integer;
begin
  Result := false;
  CodePtr := PrevCodePtr;
  PCmdTbl := @CmdTbl;
  CmdTblHi := High(CmdTbl);
  repeat
    if not ReadCodeByte(opC) then
      Exit;
    if opC>CmdTblHi then
      Exit;
    if PCmdTbl^[opC].Name[0]=#0 then
      Exit;
    F := PCmdTbl^[opC].F;
    DP := CodePtr;
    Sz := CmdArgSize[F and atMask];
    if Sz>=0 then
      SkipCode(Sz)
    else begin
      if Sz=argSzWrong then
        Exit;
      case F of
       atJmpofs4tbl: begin
         if not ReadCodeInt(Sz) then
           Exit;
         SkipCode(Sz*SizeOf(integer))
        end ;
       atExtTbl: begin
         PCmdTbl := @CmdTblFE;
         CmdTblHi := High(CmdTblFE);
         Continue;
       end ;
      end ;
    end ;
    if CodePtr>CodeEnd then
      Exit; //Error
    Action(@PCmdTbl^[opC],DP,IP);
    if F and ckPrefix=0 then
      break;
    PCmdTbl := @CmdTbl;
    CmdTblHi := High(CmdTbl);
  until false;
  Result := true;
end ;

procedure DoNothing(CI: PCmdInfo; DP: Pointer; IP: Pointer);
begin
end ;

function ReadCommand: boolean;
begin
  PrevCodePtr := CodePtr;
  Result := ProcessCommand(DoNothing,Nil);
end ;

procedure ReportFlags(Flags: integer; Names: PStrTbl; NHi: integer);
var
  i,F: integer;
begin
  F := 1;
  for i:=0 to NHi do begin
    if Flags=0 then
      Exit;
    if Flags and F<>0 then begin
      Flags := Flags and not F;
      PutsFmt('.%s',[Names^[i]]);
    end ;
    F := F shl 1;
  end ;
  if F<>0 then
    PutsFmt('.$%x',[F]);
end ;

procedure ShowCmdPart(CI: PCmdInfo; DP: Pointer; IP: Pointer);
var
  Cnt,D: integer;
  Sep: Char;
  Fix: PFixupRec;
  Fixed: boolean;
begin
  PutS(CI^.Name);
  case CI^.F and atMask of
   atU1: PutSFmt(' $%2.2x',[Byte(DP^)]);
   atU2: PutSFmt(' $%4.4x',[Word(DP^)]);
   atU4: PutSFmt(' $%8.8x',[Cardinal(DP^)]);
   atI1: PutSFmt(' %d',[ShortInt(DP^)]);
   atI4: PutSFmt(' %d',[Integer(DP^)]);
   atI8: PutSFmt(' $%x%8.8x',[Integer(Pointer(PChar(DP)+4)^),Integer(DP^)]);
   atR4: PutSFmt(' %g',[Single(DP^)]);
   atR8: PutSFmt(' %g',[Double(DP^)]);
   atMetadata: begin
     PutS(' ');
     D := Integer(DP^);
     Fix := Nil;
     Fixed := false;
     if GetFixupFor(DP,SizeOf(integer),false,Fix)and(Fix<>Nil) then begin
       Fixed := ReportFixup(Fix,D);
     end ;
     if (D=0)and(Fix<>Nil) then
       Exit;
     if Fixed then
       PutS('{+');
     PutSFmt('%d',[D]);
     if Fixed then
       PutS('}');
    end ;
   atCheckKind: ReportFlags(Byte(DP^),@CheckKindTbl,High(CheckKindTbl));
   atJmpofs1: PutSFmt(' $%x',[(CodePtr-CodeBase)+ShortInt(DP^)]);
   atJmpofs4: PutSFmt(' $%x',[(CodePtr-CodeBase)+LongInt(DP^)]);
   atJmpofs4tbl: begin
     Cnt := integer(DP^);
     Puts(' ');
     Sep := '[';
     while Cnt>0 do begin
       Inc(PChar(DP),SizeOf(integer));
       PutSFmt('%s$%x',[Sep,(CodePtr-CodeBase)+LongInt(DP^)]);
       Sep := ',';
       Dec(Cnt);
     end ;
     if Sep=',' then
       Puts(']');
    end ;
  end ;
end ;

procedure ShowCommand;
begin
  ProcessCommand(ShowCmdPart,Nil);
end ;

type
  TCmdRefCtx = record
    RegRef: TRegCommandRefProc;
    IPRegRef: Pointer;
    Res: integer;
    CmdOfs: Cardinal;
  end ;

procedure CmdPartRefs(CI: PCmdInfo; DP: Pointer; IP: Pointer);
var
  Cnt: integer;
begin
  with TCmdRefCtx(IP^) do begin
    if CI^.F and ckStop<>0 then
      Res := crJmp;
    case CI^.F and atMask of
     atJmpofs1: begin
       if Res<0 then
         Res := crJCond;
       RegRef(LongInt(CmdOfs)+ShortInt(DP^),Res,IPRegRef);
      end ;
     atJmpofs4: begin
       if Res<0 then
         Res := crJCond;
       RegRef(LongInt(CmdOfs)+LongInt(DP^),Res,IPRegRef);
      end ;
     atJmpofs4tbl: begin
       Res := crJCond;
       Cnt := integer(DP^);
       while Cnt>0 do begin
         Inc(PChar(DP),SizeOf(integer));
         RegRef(LongInt(CmdOfs)+LongInt(DP^),Res,IPRegRef);
         Dec(Cnt);
       end ;
      end ;
    end ;
  end ;
end ;

function CheckCommandRefs(RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
  IP: Pointer): integer;
var
  Ctx: TCmdRefCtx;
begin
  Ctx.RegRef := RegRef;
  Ctx.IPRegRef := IP;
  Ctx.Res := -1;
  Ctx.CmdOfs := CmdOfs;
  ProcessCommand(CmdPartRefs,@Ctx);
  Result := Ctx.Res;
end ;

procedure SetMSILDisassembler;
begin
  SetDisassembler(ReadCommand, ShowCommand,CheckCommandRefs);
end ;

end.
