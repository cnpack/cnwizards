unit x86Defs;
(*
The data structures used for representation of XML data in the file x86Op.pas
by the 80x86 disassembler based upon the XML specification
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

uses
  x86Reg;

type
  TEntryAttr = (ea_none,ea_acc,ea_delaysint,ea_delaysint_cond,ea_invd,
    ea_nop,ea_null,ea_undef);

  TEntryMod = (em_none,em_mem,em_nomem);
  TEntryMode = (ee_r{real - default},ee_p{protected and 64-bit},ee_e{64-bit},ee_s{SMM});
  TEntryModes = set of TEntryMode;

  (*TEntryNodeAttrExt = ({en_unknown,}en_alias,en_attr,en_direction,en_doc,
    en_doc_part_alias_ref,en_doc_ref,en_doc1632_ref,en_doc64_ref,en_fpop,
    en_fpush,en_is_doc,en_is_undoc,en_lock,en_mem_format,en_mod,en_mode,
    en_op_size,en_part_alias,en_particular,en_r,en_ref,en_ring,en_ring_ref,
    en_sign_ext{sign-ext},en_tttn,
    ed_Pref,ed_OpcdExt,ed_SecOpcd{separate flags for the pesence of the corresponding fields});

  TEntryNodeAttr = en_alias..en_tttn;
  TEntryNodeAttrs = set of TEntryNodeAttrExt;*)

  TEntryNodeAttr = ({en_unknown,}en_alias,en_attr,en_direction,en_doc,
    en_doc_part_alias_ref,en_doc_ref,en_doc1632_ref,en_doc64_ref,en_fpop,
    en_fpush,en_is_doc,en_is_undoc,en_lock,en_mem_format,en_mod,en_mode,
    en_op_size,en_part_alias,en_particular,en_r,en_ref,en_ring,en_ring_ref,
    en_sign_ext{sign-ext},en_tttn);
  TEntryNodeAttrs = set of TEntryNodeAttr;

  TEntryNodeBoolAttr = (ba_direction,ba_doc,ba_fpop,ba_op_size,ba_ring,ba_none);
  TEntryNodeBoolAttrs = set of TEntryNodeBoolAttr;

  TEntrySubNode = (es_def_f,es_def_f_fpu,es_f_vals,es_f_vals_fpu,es_grp1,
    es_grp2,es_grp3,es_instr_ext,es_modif_f,es_modif_f_fpu,es_note,es_opcd_ext,
    es_pref,es_proc_end,es_proc_start,es_sec_opcd,es_syntax,
    es_test_f,es_undef_f,es_undef_f_fpu);
  TEntrySubNodes = set of TEntrySubNode;

  TEntryDependence = (ed_Pref,ed_OpcdExt,ed_SecOpcd{extra - for opcodes:},ed_Z);
  TEntryDependences = set of TEntryDependence;


  TEntryGrp1 = (g1_none,g1_arith,g1_cachect,g1_compar,g1_conver,g1_datamov,g1_fetch,g1_gen,
    g1_logical,g1_mxcsrsm,g1_obsol,g1_order,g1_prefix,g1_pcksclr,g1_pcksp,
    g1_shift,g1_simdfp,g1_simdint,g1_sm,g1_strtxt,g1_sync,g1_system,
    g1_unpack,g1_x87fpu);

  TEntryGrp2 = (g2_none,g2_arith,g2_bit,g2_branch,g2_break,g2_compar,g2_control,g2_conver,
    g2_datamov,g2_flgctrl,g2_inout,g2_ldconst,g2_logical,g2_rex,g2_segreg,g2_shftrot,
    g2_shift,g2_shunpck,g2_stack,g2_string,g2_trans,g2_x87fpu);

  TEntryGrp3 = (g3_none,g3_binary,g3_cond,g3_control,g3_decimal,g3_trans);

  TEntryIExt = (ie_none,ie_mmx,ie_smx,ie_sse1,ie_sse2,ie_sse3,ie_sse41,ie_sse42,ie_ssse3,ie_vmx);

  TProcessorFlag0 = (f_O,f_D,f_I,f_S,f_Z,f_A,f_P,f_C,f_None);
  TProcessorFlag = f_O..f_C;
  TProcessorFlags = set of TProcessorFlag;
  TCoprocessorFlag = 0..3;
  TCoprocessorFlags = Byte; //set of TCoprocessorFlag

  TOpcodeMnem = (oc_None,
    oc_AAA,oc_AAD,oc_AAM,oc_AAS,oc_ADC,oc_ADD,oc_ADX,oc_ALTER,oc_AMX,
    oc_AND,oc_ARPL,oc_BOUND,oc_CALL,oc_CALLF,oc_CBW,oc_CDQ,oc_CDQE,oc_CLC,oc_CLD,
    oc_CLI,oc_CMC,oc_CMP,oc_CMPS,oc_CMPSB,oc_CMPSD,oc_CMPSQ,oc_CMPSW,oc_CQO,oc_CS,
    oc_CWD,oc_CWDE,oc_DAA,oc_DAS,oc_DEC,oc_DIV,oc_DS,oc_ENTER,oc_ES,oc_F2XM1,
    oc_FABS,oc_FADD,oc_FADDP,oc_FBLD,oc_FBSTP,oc_FCHS,oc_FCLEX,oc_FCMOVB,
    oc_FCMOVBE,oc_FCMOVE,oc_FCMOVNB,oc_FCMOVNBE,oc_FCMOVNE,oc_FCMOVNU,oc_FCMOVU,
    oc_FCOM,oc_FCOM2,oc_FCOMI,oc_FCOMIP,oc_FCOMP,oc_FCOMP3,oc_FCOMP5,oc_FCOMPP,
    oc_FCOS,oc_FDECSTP,oc_FDISI,oc_FDIV,oc_FDIVP,oc_FDIVR,oc_FDIVRP,oc_FENI,
    oc_FFREE,oc_FFREEP,oc_FIADD,oc_FICOM,oc_FICOMP,oc_FIDIV,oc_FIDIVR,oc_FILD,
    oc_FIMUL,oc_FINCSTP,oc_FINIT,oc_FIST,oc_FISTP,oc_FISTTP,oc_FISUB,oc_FISUBR,
    oc_FLD,oc_FLD1,oc_FLDCW,oc_FLDENV,oc_FLDL2E,oc_FLDL2T,oc_FLDLG2,oc_FLDLN2,
    oc_FLDPI,oc_FLDZ,oc_FMUL,oc_FMULP,oc_FNCLEX,oc_FNDISI,oc_FNENI,oc_FNINIT,
    oc_FNOP,oc_FNSAVE,oc_FNSETPM,oc_FNSTCW,oc_FNSTENV,oc_FNSTSW,oc_FPATAN,
    oc_FPREM,oc_FPREM1,oc_FPTAN,oc_FRNDINT,oc_FRSTOR,oc_FS,oc_FSAVE,oc_FSCALE,
    oc_FSETPM,oc_FSIN,oc_FSINCOS,oc_FSQRT,oc_FST,oc_FSTCW,oc_FSTENV,oc_FSTP,
    oc_FSTP1,oc_FSTP8,oc_FSTP9,oc_FSTSW,oc_FSUB,oc_FSUBP,oc_FSUBR,oc_FSUBRP,
    oc_FTST,oc_FUCOM,oc_FUCOMI,oc_FUCOMIP,oc_FUCOMP,oc_FUCOMPP,oc_FWAIT,oc_FXAM,
    oc_FXCH,oc_FXCH4,oc_FXCH7,oc_FXTRACT,oc_FYL2X,oc_FYL2XP1,oc_GS,oc_HLT,
    oc_ICEBP,oc_IDIV,oc_IMUL,oc_IN,oc_INC,oc_INS,oc_INSB,oc_INSD,oc_INSW,oc_INT,
    oc_INT1,oc_INTO,oc_IRET,oc_IRETD,oc_IRETQ,oc_JA,oc_JAE,oc_JB,oc_JBE,oc_JC,
    oc_JCXZ,oc_JE,oc_JECXZ,oc_JG,oc_JGE,oc_JL,oc_JLE,oc_JMP,oc_JMPF,oc_JNA,
    oc_JNAE,oc_JNB,oc_JNBE,oc_JNC,oc_JNE,oc_JNG,oc_JNGE,oc_JNL,oc_JNLE,oc_JNO,
    oc_JNP,oc_JNS,oc_JNZ,oc_JO,oc_JP,oc_JPE,oc_JPO,oc_JRCXZ,oc_JS,oc_JZ,oc_LAHF,
    oc_LDS,oc_LEA,oc_LEAVE,oc_LES,oc_LOCK,oc_LODS,oc_LODSB,oc_LODSD,oc_LODSQ,
    oc_LODSW,oc_LOOP,oc_LOOPE,oc_LOOPNE,oc_LOOPNZ,oc_LOOPZ,oc_MOV,oc_MOVS,
    oc_MOVSB,oc_MOVSD,oc_MOVSQ,oc_MOVSW,oc_MOVSXD,oc_MUL,oc_NEG,oc_NOP,oc_NOT,
    oc_NTAKEN,oc_OR,oc_OUT,oc_OUTS,oc_OUTSB,oc_OUTSD,oc_OUTSW,oc_PAUSE,oc_POP,
    oc_POPA,oc_POPAD,oc_POPF,oc_POPFD,oc_POPFQ,oc_PUSH,oc_PUSHA,oc_PUSHAD,
    oc_PUSHF,oc_PUSHFD,oc_PUSHFQ,oc_RCL,oc_RCR,oc_REP,oc_REPE,oc_REPNE,oc_REPNZ,
    oc_REPZ,oc_RETF,oc_RETN,oc_REX,oc_REX_B,oc_REX_R,oc_REX_RB,oc_REX_RX,
    oc_REX_RXB,oc_REX_W,oc_REX_WB,oc_REX_WR,oc_REX_WRB,oc_REX_WRX,oc_REX_WRXB,
    oc_REX_WX,oc_REX_WXB,oc_REX_X,oc_REX_XB,oc_ROL,oc_ROR,oc_SAHF,oc_SAL,oc_SALC,
    oc_SAR,oc_SBB,oc_SCAS,oc_SCASB,oc_SCASD,oc_SCASQ,oc_SCASW,oc_SETALC,oc_SHL,
    oc_SHR,oc_SS,oc_STC,oc_STD,oc_STI,oc_STOS,oc_STOSB,oc_STOSD,oc_STOSQ,oc_STOSW,
    oc_SUB,oc_TAKEN,oc_TEST,oc_WAIT,oc_XCHG,oc_XLAT,oc_XLATB,oc_XOR, oc_ADDPD,
    oc_ADDPS,oc_ADDSD,oc_ADDSS,oc_ADDSUBPD,oc_ADDSUBPS,oc_ANDNPD,oc_ANDNPS,
    oc_ANDPD,oc_ANDPS,oc_BLENDPD,oc_BLENDPS,oc_BLENDVPD,oc_BLENDVPS,oc_BSF,oc_BSR,
    oc_BSWAP,oc_BT,oc_BTC,oc_BTR,oc_BTS,oc_CLFLUSH,oc_CLTS,oc_CMOVA,oc_CMOVAE,
    oc_CMOVB,oc_CMOVBE,oc_CMOVC,oc_CMOVE,oc_CMOVG,oc_CMOVGE,oc_CMOVL,oc_CMOVLE,
    oc_CMOVNA,oc_CMOVNAE,oc_CMOVNB,oc_CMOVNBE,oc_CMOVNC,oc_CMOVNE,oc_CMOVNG,
    oc_CMOVNGE,oc_CMOVNL,oc_CMOVNLE,oc_CMOVNO,oc_CMOVNP,oc_CMOVNS,oc_CMOVNZ,
    oc_CMOVO,oc_CMOVP,oc_CMOVPE,oc_CMOVPO,oc_CMOVS,oc_CMOVZ,oc_CMPPD,oc_CMPPS,
    oc_CMPSS,oc_CMPXCHG,oc_CMPXCHG16B,oc_CMPXCHG8B,oc_COMISD,oc_COMISS,oc_CPUID,
    oc_CRC32,oc_CVTDQ2PD,oc_CVTDQ2PS,oc_CVTPD2DQ,oc_CVTPD2PI,oc_CVTPD2PS,
    oc_CVTPI2PD,oc_CVTPI2PS,oc_CVTPS2DQ,oc_CVTPS2PD,oc_CVTPS2PI,oc_CVTSD2SI,
    oc_CVTSD2SS,oc_CVTSI2SD,oc_CVTSI2SS,oc_CVTSS2SD,oc_CVTSS2SI,oc_CVTTPD2DQ,
    oc_CVTTPD2PI,oc_CVTTPS2DQ,oc_CVTTPS2PI,oc_CVTTSD2SI,oc_CVTTSS2SI,oc_DIVPD,
    oc_DIVPS,oc_DIVSD,oc_DIVSS,oc_DPPD,oc_DPPS,oc_EMMS,oc_EXTRACTPS,oc_FXRSTOR,
    oc_FXSAVE,oc_GETSEC,oc_HADDPD,oc_HADDPS,oc_HINT_NOP,oc_HSUBPD,oc_HSUBPS,
    oc_INSERTPS,oc_INVD,oc_INVEPT,oc_INVLPG,oc_INVVPID,oc_JMPE,oc_LAR,oc_LDDQU,
    oc_LDMXCSR,oc_LFENCE,oc_LFS,oc_LGDT,oc_LGS,oc_LIDT,oc_LLDT,oc_LMSW,oc_LOADALL,
    oc_LSL,oc_LSS,oc_LTR,oc_MASKMOVDQU,oc_MASKMOVQ,oc_MAXPD,oc_MAXPS,oc_MAXSD,
    oc_MAXSS,oc_MFENCE,oc_MINPD,oc_MINPS,oc_MINSD,oc_MINSS,oc_MONITOR,oc_MOVAPD,
    oc_MOVAPS,oc_MOVBE,oc_MOVD,oc_MOVDDUP,oc_MOVDQ2Q,oc_MOVDQA,oc_MOVDQU,
    oc_MOVHLPS,oc_MOVHPD,oc_MOVHPS,oc_MOVLHPS,oc_MOVLPD,oc_MOVLPS,oc_MOVMSKPD,
    oc_MOVMSKPS,oc_MOVNTDQ,oc_MOVNTDQA,oc_MOVNTI,oc_MOVNTPD,oc_MOVNTPS,oc_MOVNTQ,
    oc_MOVQ,oc_MOVQ2DQ,oc_MOVSHDUP,oc_MOVSLDUP,oc_MOVSS,oc_MOVSX,oc_MOVUPD,
    oc_MOVUPS,oc_MOVZX,oc_MPSADBW,oc_MULPD,oc_MULPS,oc_MULSD,oc_MULSS,oc_MWAIT,
    oc_ORPD,oc_ORPS,oc_PABSB,oc_PABSD,oc_PABSW,oc_PACKSSDW,oc_PACKSSWB,
    oc_PACKUSDW,oc_PACKUSWB,oc_PADDB,oc_PADDD,oc_PADDQ,oc_PADDSB,oc_PADDSW,
    oc_PADDUSB,oc_PADDUSW,oc_PADDW,oc_PALIGNR,oc_PAND,oc_PANDN,oc_PAVGB,oc_PAVGW,
    oc_PBLENDVB,oc_PBLENDW,oc_PCMPEQB,oc_PCMPEQD,oc_PCMPEQQ,oc_PCMPEQW,
    oc_PCMPESTRI,oc_PCMPESTRM,oc_PCMPGTB,oc_PCMPGTD,oc_PCMPGTQ,oc_PCMPGTW,
    oc_PCMPISTRI,oc_PCMPISTRM,oc_PEXTRB,oc_PEXTRD,oc_PEXTRQ,oc_PEXTRW,oc_PHADDD,
    oc_PHADDSW,oc_PHADDW,oc_PHMINPOSUW,oc_PHSUBD,oc_PHSUBSW,oc_PHSUBW,oc_PINSRB,
    oc_PINSRD,oc_PINSRQ,oc_PINSRW,oc_PMADDUBSW,oc_PMADDWD,oc_PMAXSB,oc_PMAXSD,
    oc_PMAXSW,oc_PMAXUB,oc_PMAXUD,oc_PMAXUW,oc_PMINSB,oc_PMINSD,oc_PMINSW,
    oc_PMINUB,oc_PMINUD,oc_PMINUW,oc_PMOVMSKB,oc_PMOVSXBD,oc_PMOVSXBQ,oc_PMOVSXBW,
    oc_PMOVSXDQ,oc_PMOVSXWD,oc_PMOVSXWQ,oc_PMOVZXBD,oc_PMOVZXBQ,oc_PMOVZXBW,
    oc_PMOVZXDQ,oc_PMOVZXWD,oc_PMOVZXWQ,oc_PMULDQ,oc_PMULHRSW,oc_PMULHUW,
    oc_PMULHW,oc_PMULLD,oc_PMULLW,oc_PMULUDQ,oc_POPCNT,oc_POR,oc_PREFETCHNTA,
    oc_PREFETCHT0,oc_PREFETCHT1,oc_PREFETCHT2,oc_PSADBW,oc_PSHUFB,oc_PSHUFD,
    oc_PSHUFHW,oc_PSHUFLW,oc_PSHUFW,oc_PSIGNB,oc_PSIGND,oc_PSIGNW,oc_PSLLD,
    oc_PSLLDQ,oc_PSLLQ,oc_PSLLW,oc_PSRAD,oc_PSRAW,oc_PSRLD,oc_PSRLDQ,oc_PSRLQ,
    oc_PSRLW,oc_PSUBB,oc_PSUBD,oc_PSUBQ,oc_PSUBSB,oc_PSUBSW,oc_PSUBUSB,oc_PSUBUSW,
    oc_PSUBW,oc_PTEST,oc_PUNPCKHBW,oc_PUNPCKHDQ,oc_PUNPCKHQDQ,oc_PUNPCKHWD,
    oc_PUNPCKLBW,oc_PUNPCKLDQ,oc_PUNPCKLQDQ,oc_PUNPCKLWD,oc_PXOR,oc_RCPPS,
    oc_RCPSS,oc_RDMSR,oc_RDPMC,oc_RDTSC,oc_RDTSCP,oc_ROUNDPD,oc_ROUNDPS,
    oc_ROUNDSD,oc_ROUNDSS,oc_RSM,oc_RSQRTPS,oc_RSQRTSS,oc_SETA,oc_SETAE,oc_SETB,
    oc_SETBE,oc_SETC,oc_SETE,oc_SETG,oc_SETGE,oc_SETL,oc_SETLE,oc_SETNA,oc_SETNAE,
    oc_SETNB,oc_SETNBE,oc_SETNC,oc_SETNE,oc_SETNG,oc_SETNGE,oc_SETNL,oc_SETNLE,
    oc_SETNO,oc_SETNP,oc_SETNS,oc_SETNZ,oc_SETO,oc_SETP,oc_SETPE,oc_SETPO,oc_SETS,
    oc_SETZ,oc_SFENCE,oc_SGDT,oc_SHLD,oc_SHRD,oc_SHUFPD,oc_SHUFPS,oc_SIDT,oc_SLDT,
    oc_SMSW,oc_SQRTPD,oc_SQRTPS,oc_SQRTSD,oc_SQRTSS,oc_STMXCSR,oc_STR,oc_SUBPD,
    oc_SUBPS,oc_SUBSD,oc_SUBSS,oc_SWAPGS,oc_SYSCALL,oc_SYSENTER,oc_SYSEXIT,
    oc_SYSRET,oc_UCOMISD,oc_UCOMISS,oc_UD,oc_UD2,oc_UNPCKHPD,oc_UNPCKHPS,
    oc_UNPCKLPD,oc_UNPCKLPS,oc_VERR,oc_VERW,oc_VMCALL,oc_VMCLEAR,oc_VMLAUNCH,
    oc_VMPTRLD,oc_VMPTRST,oc_VMREAD,oc_VMRESUME,oc_VMWRITE,oc_VMXOFF,oc_VMXON,
    oc_WBINVD,oc_WRMSR,oc_XADD,oc_XGETBV,oc_XORPD,oc_XORPS,oc_XRSTOR,oc_XSAVE,
    oc_XSETBV,
    oc_Unknown{Utility value});

(*
  TArgName = (an_CESiI_IDII{(ES:)[rDI]},an__rDI_{[rDI]},an_AH,an_AL,an_AX,an_BP,
    an_BX,an_CS,an_CX,an_DI,an_DS,an_DX,an_eAX,an_eBP,an_EBX,an_eCX,an_EDI,an_EDX,
    an_EFlags,an_ES,an_ES__DI_{ES:[DI]},an_ESI,an_Flags,an_rAX,an_rBP,an_rCX,
    an_rDX,an_RFlags,an_SI,an_SS,an_SS__rSP_{SS:[rSP]},an_ST,an_ST1,an_ST2,an_ST3,
    an_ST4,an_ST5,an_ST6,an_ST7,an__DS___rSI_{(DS):[rSI]},
    an__DS___rBXtAL_{(DS:)[rBX+AL]},an__rSI_{[rSI]},an_1,an_3,an_CL,
    an_DS__SI_{DS:[SI]},an_ESP,an_FS,an_GS,an_SP,an__DS___rDI_{(DS:)[rDI]},an_CR0,
    an_DR6,an_DR7,an_GDTR,an_IA32_BIOS_SIGN_ID,an_IA32_KERNEL_GSBASE,an_IDTR,
    an_LDTR,an_MMX0,an_MMX1,an_MMX2,an_MMX3,an_MMX4,an_MMX5,an_MMX6,an_MMX7,
    an_MSR,an_MSW,an_R11,an_RSP,an_TR,an_XCR,an_XMM0,an_XMM1,an_XMM10,an_XMM11,
    an_XMM12,an_XMM13,an_XMM14,an_XMM15,an_XMM2,an_XMM3,an_XMM4,an_XMM5,an_XMM6,
    an_XMM7,an_XMM8,an_XMM9,an__DS___rAX_{(DS:)[rAX]},an_IA32_FMASK,an_IA32_LSTAR,
    an_IA32_STAR,an_IA32_SYSENTER_CS,an_IA32_SYSENTER_EIP,an_IA32_SYSENTER_ESP,
    an_IA32_TIME_STAMP_COUNTER,an_IA32_TSC_AUX,an_PMC,an_RBX);
  TArgName = (an_ÑESiDIrDII{(ES:)[rDI]},an_IrDII{[rDI]},an_AH,an_AL,an_AX,an_BP,
    an_BX,an_CS,an_CX,an_DI,an_DS,an_DX,an_eAX,an_eBP,an_EBX,an_eCX,an_EDI,an_EDX,
    an_EFlags,an_ES,an_ESiIDII{ES:[DI]},an_ESI,an_Flags,an_rAX,an_rBP,an_rCX,
    an_rDX,an_RFlags,an_SI,an_SS,an_SSiIrSPI{SS:[rSP]},an_ST,an_ST1,an_ST2,an_ST3,
    an_ST4,an_ST5,an_ST6,an_ST7,an_ÑDSDiIrSII{(DS):[rSI]},
    an_ÑDSiDIrBXtALI{(DS:)[rBX+AL]},an_ÑDSiDIrSII{(DS:)[rSI]},an_IrSII{[rSI]},
    an_1,an_3,an_CL,an_DSiISII{DS:[SI]},an_ESP,an_FS,an_GS,an_SP,
    an_ÑDSiDIrDII{(DS:)[rDI]},an_CR0,an_DR6,an_DR7,an_GDTR,an_IA32_BIOS_SIGN_ID,
    an_IA32_KERNEL_GSBASE,an_IDTR,an_LDTR,an_MMX0,an_MMX1,an_MMX2,an_MMX3,an_MMX4,
    an_MMX5,an_MMX6,an_MMX7,an_MSR,an_MSW,an_R11,an_RSP,an_TR,an_XCR,an_XMM0,
    an_XMM1,an_XMM10,an_XMM11,an_XMM12,an_XMM13,an_XMM14,an_XMM15,an_XMM2,an_XMM3,
    an_XMM4,an_XMM5,an_XMM6,an_XMM7,an_XMM8,an_XMM9,an_ÑDSiDIrAXI{(DS:)[rAX]},
    an_IA32_FMASK,an_IA32_LSTAR,an_IA32_STAR,an_IA32_SYSENTER_CS,
    an_IA32_SYSENTER_EIP,an_IA32_SYSENTER_ESP,an_IA32_TIME_STAMP_COUNTER,
    an_IA32_TSC_AUX,an_PMC,an_RBX);
*)
  TArgName = (an_None,
    an__ESi_LrDIJ{(ES:)[rDI]},an_LrDIJ{[rDI]},an_AH,an_AL,an_AX,an_BP,
    an_BX,an_CS,an_CX,an_DI,an_DS,an_DX,an_eAX,an_eBP,an_EBX,an_eCX,an_EDI,an_EDX,
    an_EFlags,an_ES,an_ESiLDIJ{ES:[DI]},an_ESI,an_Flags,an_rAX,an_rBP,an_rCX,
    an_rDX,an_RFlags,an_SI,an_SS,an_SSiLrSPJ{SS:[rSP]},an_ST,an_ST1,an_ST2,an_ST3,
    an_ST4,an_ST5,an_ST6,an_ST7,an__DS_iLrSIJ{(DS):[rSI]},
    an__DSi_LrBXtALJ{(DS:)[rBX+AL]},an__DSi_LrSIJ{(DS:)[rSI]},an_LrSIJ{[rSI]},
    an_1,an_3,an_CL,an_DSiLSIJ{DS:[SI]},an_ESP,an_FS,an_GS,an_SP,
    an__DSi_LrDIJ{(DS:)[rDI]},an_CR0,an_DR6,an_DR7,an_GDTR,an_IA32_BIOS_SIGN_ID,
    an_IA32_KERNEL_GSBASE,an_IDTR,an_LDTR,an_MMX0,an_MMX1,an_MMX2,an_MMX3,an_MMX4,
    an_MMX5,an_MMX6,an_MMX7,an_MSR,an_MSW,an_R11,an_RSP,an_TR,an_XCR,an_XMM0,
    an_XMM1,an_XMM10,an_XMM11,an_XMM12,an_XMM13,an_XMM14,an_XMM15,an_XMM2,an_XMM3,
    an_XMM4,an_XMM5,an_XMM6,an_XMM7,an_XMM8,an_XMM9,an__DSi_LrAXJ{(DS:)[rAX]},
    an_IA32_FMASK,an_IA32_LSTAR,an_IA32_STAR,an_IA32_SYSENTER_CS,
    an_IA32_SYSENTER_EIP,an_IA32_SYSENTER_ESP,an_IA32_TIME_STAMP_COUNTER,
    an_IA32_TSC_AUX,an_PMC,an_RBX);

  TOpcodeArgAttr = (aa_address,aa_depend,aa_displayed,aa_group,aa_nr,aa_type);

  TArgFlag = (afDst,afNoDepend,afNoDispl,afNone,afNr);
  TArgFlagBit = afDst..afNoDispl;
  TArgFlags = set of TArgFlag;

  {TArgAddrMethod = (am_None,
    am_E,am_EST,am_G,am_I,am_M,am_O,am_R,am_S,am_Z,am_A,am_ES,am_J,
    am_C,am_D,am_H,am_N,am_P,am_Q,am_T,am_U,am_V,am_W);}

  TArgAddrMethod = (am_None,
    am_A,am_BA,am_BB,am_BD,am_C,am_D,am_E,am_ES,am_EST,am_F,am_G,
    am_H,am_I,am_J,am_M,am_N,am_O,am_P,am_Q,am_R,am_S,am_S2,am_S30,am_S33,am_SC,
    am_T,am_U,am_V,am_W,am_X,am_Y,am_Z);

  TOpcodeDatum = (od_Ptr,od_ModR{reg part},od_ModM{M part}{,od_ModMR{Mod=$3,M is Reg},
    od_I{There may be two args of this kind (ENTER)},od_J,od_ImOfs,od_Z,od_None); //The data following instruction opcodes
  TOpcodeData = set of TOpcodeDatum;

  TOpcodeDataLinks = array[TOpcodeDatum]of TOpcodeData;

  TAddrMethodFlags = set of (amMemOnly);

  TAddrMethodProps = record
    RegT: TRegTblIndex;
    hReg: Byte; //TRegNum+1 //When the particular register is known
    F: TAddrMethodFlags;
    Data: TOpcodeDatum;
  end ;

const
  AddrMethodProps: array[TArgAddrMethod]of TAddrMethodProps = ((Data:od_None{am_None}),
    (Data:od_Ptr{am_A=>at_p}),(hReg:0+1{EAX}; Data:od_None{am_BA=>at_b}),
    (hReg:3+1{EBX}; Data:od_None{am_BB=>at_b}),
    (hReg:7+1{EDI}; Data:od_None{am_BD=>at_q,at_dq}),
    (RegT:rtCR; Data:od_ModR{am_C=>at_d}),
    (RegT:rtDR; Data:od_ModR{am_D=at_d,at_q}),
    (Data:od_ModM{am_E=>*}),
    (RegT:rtFP; Data:od_ModM{am_ES=>at_sr}),
    (RegT:rtFP; Data:od_ModM{am_EST=>at_None}),
    (RegT:rtOther; hReg:0+1{rFlags}; Data:od_None{am_F=>*}),
    (Data:od_ModR{am_G=>*}),(Data:od_ModM{am_H=>at_d,at_q}),(Data:od_I{am_I=>*}),(Data:od_J{am_J=>at_bs,at_vds}),
    (F:[amMemOnly]; Data:od_ModM{am_M}),
    (RegT:rtMMX; Data:od_ModM{am_N}),
    (Data:od_ImOfs{am_O=>at_b,at_vqp}),
    (RegT:rtMMX; Data:od_ModR{am_P}),
    (RegT:rtMMX; Data:od_ModM{am_Q}),
    (Data:od_ModM{od_ModMR}{am_R}),
    (RegT:rtSeg; Data:od_ModR{am_S}),
    (RegT:rtSeg; Data:od_None{am_S2}),
    (RegT:rtSeg; Data:od_None{am_S30}),
    (RegT:rtSeg; Data:od_None{am_S33}),
    (Data:od_None{am_SC}),
    (RegT:rtTR; Data:od_ModR{am_T}),
    (RegT:rtXMM; Data:od_ModM{am_U}),
    (RegT:rtXMM; Data:od_ModR{am_V}),
    (RegT:rtXMM; Data:od_ModM{am_W}),
    (hReg:6+1{ESI}; Data:od_None{am_X}),
    (hReg:7+1{EDI}; Data:od_None{am_Y}),
    (Data:od_Z{am_Z}));

  CompatData: TOpcodeDataLinks = ({od_Ptr}[],[od_ModM,od_I]{od_ModR},
    [od_ModR,od_I]{od_ModM},[od_ModR,od_ModM,od_Z,od_I]{od_I},[]{od_J},[]{od_ImOfs},[od_I]{od_Z},[]{od_None});

  PredData: TOpcodeDataLinks = ({od_Ptr}[],[od_ModM]{od_ModR},
    [od_ModR]{od_ModM},[od_ModR,od_ModM,od_Z,od_I]{od_I},[]{od_J},[]{od_ImOfs},[od_I]{od_Z},[]{od_None});
    //These links allow to check, that the order of all the instruction arguments allows to read
    //the data in the order ModRM|I

type
  TArgAddrType = (at_None,
    at_a,at_b,at_bcd,at_bs,at_bss,at_d,at_da,at_di,at_do,
    at_dp{Added by AX to replace at_do, when at_qp is present},at_dq,
    at_dqa,at_dqp,at_dr,at_e,at_er,at_p,at_pd,at_pi,at_ps,at_psq,at_ptp,at_q,
    at_qa,at_qi,at_qp,at_qs,at_s,at_sd,at_sr,at_ss,at_st,at_stx,at_v,at_va,at_vds,
    at_vq,at_vqp,at_vs,at_w,at_wa,at_wi,at_wo,at_ws);

  TSizeFlagVal = (sfWord,sfDword,sfQWord);
  TOpSize = (osNone,osByte,osWord,osDWord,osQWord,osBCD,
    osSingle,osDouble,osExtended,
    osPtr16_16,osPtr16_32,osPtr16_64,
    osEnv16,osEnv32,osFPUState16,osFPUState32,osSIMDState);

  TOpSizeFactor = (sfNone,sfOS,sfOS64{with REX.W},sfAS,sfStack,sfRexW,sfDest,sfMode{16/32/64});

  TAddrTypeFlag = (atSignExt,atSigned,at32only);
  TAddrTypeFlags = set of TAddrTypeFlag;

  TAddrTypeProps = record
    Sz: array[TSizeFlagVal]of TOpSize; //The operand size for the code
    M: Byte; //Bit mask of supported TSizeFlagVal codes
    Cnt: Byte;
    Factor: TOpSizeFactor; //The attribute used to compute the TSizeFlagVal code
    F: TAddrTypeFlags;
  end ;

const
  {An approximate tables, should be fixed after changing disassembler data structures}
  OpSizeBytes: array[TOpSize] of Integer = (0{osNone},1{osByte},2{osWord},4{osDWord},
    8{osQWord},1{osBCD},4{osSingle},8{osDouble},10{osExtended},
    4{osPtr16_16},6{osPtr16_32},10{osPtr16_64},
    0{osEnv16},0{osEnv32},0{osFPUState16},0{osFPUState32},0{osSIMDState});

  FactorLen: array[TOpSizeFactor]of Byte = (1{sfNone},2{sfOS},3{sfOS64},3{sfAS},3{sfStack},2{sfRexW},1{sfDest},3{sfMode});

  ArgAddrTypeProps: array[TArgAddrType]of TAddrTypeProps = (
   {at_None}(),
   {at_a}(Sz:(osWord,osDWord,osNone{Invalid});M:3;Cnt:2;Factor:sfOS; F:[at32only]), //Two one-word operands in memory or two double-word operands in memory, depending on operand-size attribute (only BOUND)
   {at_b}(Sz:(osByte,osByte,osByte);M:1;Cnt:1), //byte, regardless of operand-size attribute
   {at_bcd}(Sz:(osBCD,osBCD,osBCD);M:1;Cnt:1), //Packed-BCD. Only x87 FPU instructions (for example, FBLD)
   {at_bs}(Sz:(osByte,osByte,osByte);M:1;Cnt:1;Factor:sfDest;F:[atSignExt,atSigned]), //Byte, sign-extended to the size of the destination operand
   {at_bss}(Sz:(osByte,osByte,osByte);M:7;Cnt:1;Factor:sfStack;F:[atSignExt,atSigned]), //Byte, sign-extended to the size of the stack pointer (for example, PUSH (6A))
   {at_d}(Sz:(osDWord,osDWord,osDWord);M:1;Cnt:1), //Doubleword, regardless of operand-size attribute
   {at_da}(Sz:(osNone,osDWord,osNone);M:2;Cnt:1;Factor:sfAS), //Doubleword, according to address-size attribute (only JECXZ instruction)
   {at_di}(Sz:(osDWord,osDWord,osDWord);M:1;Cnt:1;F:[atSigned]), //Doubleword-integer. Only x87 FPU instructions (for example, FIADD)
   {at_do}(Sz:(osNone,osDWord,osNone);M:2;Cnt:1;Factor:sfOS), //Doubleword, according to current operand size (e. g., MOVSD instruction)
   {at_dp}(Sz:(osQWord,osNone,osNone);M:1;Cnt:1;Factor:sfRexW), //Doubleword, when REX.W=0 (Added by AX to replace at_do, when at_qp is present)
   {at_dq}(Sz:(osQWord,osQWord,osQWord);M:1;Cnt:2), //Double-quadword, regardless of operand-size attribute (for example, CMPXCHG16B)
      //!!!In fact depends on REX.W for CMPXCHG16B - the spec. should be fixed
   {at_dqa}(Sz:(osDWord,osQWord,osNone);M:3;Cnt:1;Factor:sfAS;F:[atSignExt,atSigned]), //Doubleword or quadword, according to address-size attribute (only REP and LOOP families)
   {at_dqp}(Sz:(osDWord,osQWord,osNone);M:3;Cnt:1;Factor:sfRexW), //Doubleword, or quadword, promoted by REX.W in 64-bit mode (for example, MOVSXD)
   {at_dr}(Sz:(osDouble,osDouble,osDouble);M:1;Cnt:1), //Double-real. Only x87 FPU instructions (for example, FADD)
   {at_e}(Sz:(osEnv16,osEnv32,osEnv32{?});M:7;Cnt:1;Factor:sfOS{?}), //x87 FPU environment (for example, FSTENV)
   {at_er}(Sz:(osExtended,osExtended,osExtended);M:1;Cnt:1), //Extended-real. Only x87 FPU instructions (for example, FLD)
   {at_p}(Sz:(osPtr16_16,osPtr16_32,osPtr16_32);M:7;Cnt:1;Factor:sfOS), //32-bit or 48-bit pointer, depending on operand-size attribute (for example, CALLF (9A))
   {at_pd}(Sz:(osDouble,osDouble,osDouble);M:1;Cnt:2), //128-bit packed double-precision floating-point data
   {at_pi}(Sz:(osDWord,osDWord,osDWord);M:1;Cnt:2;F:[atSigned]), //Quadword MMX technology data
   {at_ps}(Sz:(osSingle,osSingle,osSingle);M:1;Cnt:4), //128-bit packed single-precision floating-point data
   {at_psq}(Sz:(osSingle,osSingle,osSingle);M:1;Cnt:2), //64-bit packed single-precision floating-point data
   {at_ptp}(Sz:(osPtr16_16,osPtr16_32,osPtr16_64);M:7;Cnt:1;Factor:sfOS64), //32-bit or 48-bit pointer, depending on operand-size attribute, or 80-bit far pointer, promoted by REX.W in 64-bit mode (for example, CALLF (FF /3)).
   {at_q}(Sz:(osQWord,osQWord,osQWord);M:1;Cnt:1), //Quadword, regardless of operand-size attribute (for example, CALL (FF /2)).
   {at_qa}(Sz:(osNone,osQWord,osNone);M:4;Cnt:1;Factor:sfAS), //Quadword, according to address-size attribute (only JRCXZ instruction)
   {at_qi}(Sz:(osQWord,osQWord,osQWord);M:1;Cnt:1;F:[atSigned]), //Qword-integer. Only x87 FPU instructions (for example, FILD)
   {at_qp}(Sz:(osNone,osQWord,osNone);M:2;Cnt:1;Factor:sfRexW), //Quadword, promoted by REX.W (for example, IRETQ).
   {at_qs}(Sz:(osNone,osNone,osQWord);M:4;Cnt:1;Factor:sfStack), //Quadword, according to current stack size (only PUSHFQ and POPFQ instructions)
   {at_s}(Sz:(osPtr16_32,osPtr16_32,osPtr16_64);M:7;Cnt:1;Factor:sfMode), //6-byte pseudo-descriptor, or 10-byte pseudo-descriptor in 64-bit mode (for example, SGDT)
   {at_sd}(Sz:(osDouble,osDouble,osDouble{osDWord,osDWord,osDWord});M:1;Cnt:1;F:[atSigned]), //Scalar element of a 128-bit packed double-precision floating data
   {at_sr}(Sz:(osSingle,osSingle,osSingle);M:1;Cnt:1), //Single-real. Only x87 FPU instructions (for example, FADD).
   {at_ss}(Sz:(osSingle,osSingle,osSingle);M:6;Cnt:1), //Scalar element of a 128-bit packed single-precision floating data
   {at_st}(Sz:(osFPUState16,osFPUState32,osFPUState32{?});M:7;Cnt:1;Factor:sfOS{?}), //x87 FPU state (for example, FSAVE).
   {at_stx}(Sz:(osSIMDState,osSIMDState,osSIMDState);M:1;Cnt:1), //x87 FPU and SIMD state
   {at_v}(Sz:(osWord,osDWord,osQWord);M:7;Cnt:1;Factor:sfOS), //Word or doubleword, depending on operand-size attribute (for example, INC (40), PUSH (50)) - added QWord by AX
   {at_va}(Sz:(osWord,osDWord,osNone);M:3;Cnt:1;Factor:sfAS), //Word or doubleword, according to address-size attribute (only REP and LOOP families)
   {at_vds}(Sz:(osWord,osDWord,osDWord);M:7;Cnt:1;Factor:sfOS64;F:[atSignExt,atSigned]), //Word or doubleword, depending on operand-size attribute, or doubleword, sign-extended to 64 bits for 64-bit operand size
   {at_vq}(Sz:(osWord,osQWord,osNone);M:3;Cnt:1;Factor:sfOS), //Quadword (default) or word if operand-size prefix is used (for example, PUSH (50))
   {at_vqp}(Sz:(osWord,osDWord,osQWord);M:7;Cnt:1;Factor:sfOS64), //Word or doubleword, depending on operand-size attribute, or quadword, promoted by REX.W in 64-bit mode
   {at_vs}(Sz:(osWord,osDWord,osDWord);M:7;Cnt:1;Factor:sfStack;F:[atSignExt,atSigned]), //Word or doubleword sign extended to the size of the stack pointer (for example, PUSH (68))
   {at_w}(Sz:(osWord,osWord,osWord);M:1;Cnt:1), //Word, regardless of operand-size attribute (for example, ENTER)
   {at_wa}(Sz:(osWord,osNone,osNone);M:1;Cnt:1;Factor:sfAS), //Word, according to address-size attribute (only JCXZ instruction)
   {at_wi}(Sz:(osWord,osWord,osWord);M:1;Cnt:1;F:[atSigned]), //Word-integer. Only x87 FPU instructions (for example, FIADD)
   {at_wo}(Sz:(osWord,osNone,osNone);M:1;Cnt:1;Factor:sfOS), //Word, according to current operand size (e. g., MOVSW instruction)
   {at_ws}(Sz:(osNone,osNone,osWord);M:4;Cnt:1;Factor:sfStack) //Word, according to current stack size (only PUSHF and POPF instructions in 64-bit mode)
  );

  {TArgAddrType = (at_None,
    at_a,at_b,at_bcd,at_bs,at_bss,at_d,at_di,at_dr,at_e,at_er,at_p,
    at_ptp,at_q,at_qi,at_sr,at_st,at_v,at_vds,at_vq,at_vqp,at_vs,at_w,at_wi,
    at_dqp,at_dq,at_pd,at_pi,at_ps,at_qp,at_s,at_sd,at_ss,at_stx,at_psq);}

{type
  TAddrMethod = (amUnknown,
    amPtr,amM_DS_EAX,amM_DS_rBX_AL,amM_DS_EDI,amCRn,amDRn,amR_M,
    amSTi_M,amSTi,amRFlags,amR_R,amR_RM,amImm,amRel,amM,
    amMMX_RM,amMOfs, amMMX_R,amMMX_M,amR,amS,amStack,amTRn,
    amXMM_RM,amXMM_R,amXMM_M,amM_DS_SI,amM_ES_DI,amReg,
    amS2,amS30,amS33);
const
  abbrAddrMethod: array[TAddrMethod]of String[3] = ('',
    'A','BA','BB','BD','C','D','E',
    'ES','EST','F','G','H','I','J','M',
    'N','O','P','Q','R','S','SC','T',
    'U','V','W','X','Y','Z',
    'S2','S30','S33');

type
  TOperandType = (otUnknown,
    otBound,otB,otBCD,otBS,otBSQ,otBSS,otC,otD,otDI,otDQ,otDQP,
    otDR,otDS,otE,otER,opP,otPI,otPD,otPS,otPSQ,otPT,otPTP,otQ,otQI,otQP,
    otS,otSR,otSS,otST,otSTX,otT,otV,otVDS,otVQ,otVQP,otVS,otW,otWI,
    otVA,otDQA,otWA,otWO,otWS,otDA,otDO,otQA,otQS
  );
const
  abbrOperandType: array[TOperandType]of String[3] = ('',
    'a','b','bcd','bs','bsq','bss','c','d','di','dq','dqp',
    'dr','ds','e','er','p','pi','pd','ps','psq','pt','ptp','q','qi','qp',
    's','sr','ss','st','stx','t','v','vds','vq','vqp','vs','w','wi',
    'va','dqa','wa','wo','ws','da','do','qa','qs'
  );
}
const
  FlagChars: array[TProcessorFlag]of AnsiChar = 'ODISZAPC';

type
  PPrimaryOpcode = ^TPrimaryOpcode;
  TPrimaryOpcode = record
    Base,Count: Word;
    Mnem: TOpcodeMnem; //Common for all Entries if any
    Dep: TEntryDependences; //Choice of the entries depends on
    Modes: TEntryModes;
  end ;

  PPrimaryOpcodes = ^TPrimaryOpcodes;
  TPrimaryOpcodes = array[byte] of TPrimaryOpcode;

  {TOpcodeEntryFlag = (oeUsed,oeFPush,oeIsDoc,oeIsUndoc,oeLock,oeParticular,oeR,oeSignExt);
  TOpcodeEntryFlags = set of TOpcodeEntryFlag;}

  POpcodeEntry = ^TOpcodeEntry;
  TOpcodeEntry = object
    Base,Count: Word;
   {Attributes}
    Flags: TEntryNodeAttrs;
    Mnem: TOpcodeMnem; //Common for all syntaxes if any
    FVals: TEntryNodeBoolAttrs; //Values for the flags with two possibilities
    Attr: TEntryAttr;
    mem_format: Byte;
    mod_: TEntryMod;
    mode: TEntryMode;
    //tttn: Byte;
   {Subnodes}
    FData: TOpcodeData;
    Dep: TEntryDependences; //Choice of the entry depends on
    Pref,OpcdExt,SecOpcd: Byte;
    ProcStart,ProcEnd: Byte;
    grp1: TEntryGrp1;
    grp2: TEntryGrp2;
    grp3: TEntryGrp3;
    iExt: TEntryIExt;
    DefF,ModifF,TestF,UndefF,Vals0F,Vals1F: TProcessorFlags;
    CDefF,CModifF,CUndefF,CVals0F{,CVals1F-not present in the XML}: TCoprocessorFlags;
    Note: String;
  end ;

  POpcodeEntries = ^TOpcodeEntries;
  TOpcodeEntries = array[Word]of TOpcodeEntry;

  POpcodeSyntax = ^TOpcodeSyntax;
  TOpcodeSyntax = object
    Base,Count: Word;
    Mnem: TOpcodeMnem;
  end ;

  POpcodeSyntaxes = ^TOpcodeSyntaxes;
  TOpcodeSyntaxes = array[byte] of TOpcodeSyntax;

  POpcodeArg = ^TOpcodeArg;
  TOpcodeArg = object
    Name: TArgName;
    Flags: TArgFlags;
    nr: SmallInt;
    A: TArgAddrMethod;
    T: TArgAddrType;
  end ;

  POpcodeArgs = ^TOpcodeArgs;
  TOpcodeArgs = array[Word] of TOpcodeArg;

  TOpcodeTables = record
    OpCodes: PPrimaryOpcodes;
    EntryCount: Integer;
    Entries: POpcodeEntries;
    SyntaxCount: Integer;
    Syntaxes: POpcodeSyntaxes;
    ArgCount: Integer;
    Args: POpcodeArgs;
  end ;

implementation

end.
