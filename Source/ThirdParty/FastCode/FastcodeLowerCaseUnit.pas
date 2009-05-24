unit FastcodeLowerCaseUnit;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Fastcode
 *
 * The Initial Developer of the Original Code is Fastcode
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Charalabos Michael <chmichael@creationpower.com>
 * John O'Harrow <john@elmcrest.demon.co.uk>
 * Aleksandr Sharahov
 *
 * BV Version: 3.52
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeLowerCaseFunction = function(const s: string): string;

{Functions shared between Targets}
function LowerCase_JOH_MMX_2(const S: string): string;
function LowerCase_JOH_IA32_5(const S: string): string;
function LowerCase_Sha_Pas_2(const s: string): string;

{Functions not shared between Targets}

{Functions}

const
  FastcodeLowerCaseP4R: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastcodeLowerCaseP4N: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastcodeLowerCasePMY: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastcodeLowerCasePMD: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastcodeLowerCaseAMD64: FastcodeLowerCaseFunction = LowerCase_JOH_IA32_5;
  FastcodeLowerCaseAMD64_SSE3: FastcodeLowerCaseFunction = LowerCase_JOH_IA32_5;
  FastCodeLowerCaseIA32SizePenalty: FastCodeLowerCaseFunction = LowerCase_JOH_IA32_5;
  FastcodeLowerCaseIA32: FastcodeLowerCaseFunction = LowerCase_JOH_IA32_5;
  FastcodeLowerCaseMMX: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastCodeLowerCaseSSESizePenalty: FastCodeLowerCaseFunction = LowerCase_JOH_IA32_5;
  FastcodeLowerCaseSSE: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastcodeLowerCaseSSE2: FastcodeLowerCaseFunction = LowerCase_JOH_MMX_2;
  FastCodeLowerCasePascalSizePenalty: FastCodeLowerCaseFunction = LowerCase_Sha_Pas_2;
  FastCodeLowerCasePascal: FastCodeLowerCaseFunction = LowerCase_Sha_Pas_2;

procedure LowerCaseStub;

implementation

uses
  SysUtils;

var
  AsciiLowerCase : array[Char] of Char = (
    #$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,#$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
    #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,#$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
    #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,#$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
    #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,#$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
    #$40,#$61,#$62,#$63,#$64,#$65,#$66,#$67,#$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
    #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,#$78,#$79,#$7A,#$5B,#$5C,#$5D,#$5E,#$5F,
    #$60,#$61,#$62,#$63,#$64,#$65,#$66,#$67,#$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
    #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,#$78,#$79,#$7A,#$7B,#$7C,#$7D,#$7E,#$7F,
    #$80,#$81,#$82,#$83,#$84,#$85,#$86,#$87,#$88,#$89,#$8A,#$8B,#$8C,#$8D,#$8E,#$8F,
    #$90,#$91,#$92,#$93,#$94,#$95,#$96,#$97,#$98,#$99,#$9A,#$9B,#$9C,#$9D,#$9E,#$9F,
    #$A0,#$A1,#$A2,#$A3,#$A4,#$A5,#$A6,#$A7,#$A8,#$A9,#$AA,#$AB,#$AC,#$AD,#$AE,#$AF,
    #$B0,#$B1,#$B2,#$B3,#$B4,#$B5,#$B6,#$B7,#$B8,#$B9,#$BA,#$BB,#$BC,#$BD,#$BE,#$BF,
    #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,#$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
    #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,#$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF,
    #$E0,#$E1,#$E2,#$E3,#$E4,#$E5,#$E6,#$E7,#$E8,#$E9,#$EA,#$EB,#$EC,#$ED,#$EE,#$EF,
    #$F0,#$F1,#$F2,#$F3,#$F4,#$F5,#$F6,#$F7,#$F8,#$F9,#$FA,#$FB,#$FC,#$FD,#$FE,#$FF);

function LowerCase_JOH_MMX_2(const S: string): string;
const
  B25 : Int64 = $2525252525252525;
  B65 : Int64 = $6565656565656565;
  B20 : Int64 = $2020202020202020;
asm
  xchg    eax, edx
  test    edx, edx              {Test for S = ''}
  jz      system.@LStrSetLength {Return Empty String}
  mov     ecx, edx              {Addr(S)}
  mov     edx, [edx-4]
  push    ebx
  push    edi
  push    esi
  mov     edi, ecx              {Addr(S)}
  mov     esi, edx              {Length}
  mov     ebx, eax              {Addr(Result)}
  call    system.@LStrSetLength {Create Result String}
  mov     ecx, esi              {Length}
  mov     eax, edi              {Addr(S)}
  sub     ecx, 16
  mov     edx, [ebx]            {Result}
  jl      @@Small
  movq    mm4, B25
  movq    mm5, B65
  movq    mm6, B20
  add     eax, ecx
  add     edx, ecx
  neg     ecx
@@LargeLoop:
  movq    mm0, [eax+ecx  ]
  movq    mm1, [eax+ecx+8]
  movq    mm2, mm0
  movq    mm3, mm1
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  paddb   mm0, mm2
  paddb   mm1, mm3
  movq    [edx+ecx  ], mm0
  movq    [edx+ecx+8], mm1
  add     ecx, 16
  jle     @@LargeLoop
  emms
  neg     ecx
  sub     eax, ecx
  sub     edx, ecx
@@Small:
  add     ecx, 16
  lea     edi, AsciiLowerCase
  jz      @@Done
@@SmallLoop:
  sub     ecx, 1
  movzx   esi, [eax+ecx]
  movzx   ebx, [edi+esi]
  mov     [edx+ecx], bl
  jg      @@SmallLoop
@@Done:
  pop     esi
  pop     edi
  pop     ebx
end;

function LowerCase_JOH_IA32_5(const S: string): string;
asm {Size = 134 Bytes}
  push    ebx
  push    edi
  push    esi
  test    eax, eax               {Test for S = NIL}
  mov     esi, eax               {@S}
  mov     edi, edx               {@Result}
  mov     eax, edx               {@Result}
  jz      @@Null                 {S = NIL}
  mov     edx, [esi-4]           {Length(S)}
  test    edx, edx
  je      @@Null                 {Length(S) = 0}
  mov     ebx, edx
  call    system.@LStrSetLength  {Create Result String}
  mov     edi, [edi]             {@Result}
  mov     eax, [esi+ebx-4]       {Convert the Last 4 Characters of String}
  mov     ecx, eax               {4 Original Bytes}
  or      eax, $80808080         {Set High Bit of each Byte}
  mov     edx, eax               {Comments Below apply to each Byte...}
  sub     eax, $5B5B5B5B         {Set High Bit if Original <= Ord('Z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('A')}
  and     eax, edx               {80h if Orig in 'A'..'Z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  add     ecx, eax               {Set Bit 5 if Original in 'A'..'Z'}
  mov     [edi+ebx-4], ecx
  sub     ebx, 1
  and     ebx, -4
  jmp     @@CheckDone
@@Null:
  pop     esi
  pop     edi
  pop     ebx
  jmp     System.@LStrClr
@@Loop:                          {Loop converting 4 Character per Loop}
  mov     eax, [esi+ebx]
  mov     ecx, eax               {4 Original Bytes}
  or      eax, $80808080         {Set High Bit of each Byte}
  mov     edx, eax               {Comments Below apply to each Byte...}
  sub     eax, $5B5B5B5B         {Set High Bit if Original <= Ord('Z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('A')}
  and     eax, edx               {80h if Orig in 'A'..'Z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  add     ecx, eax               {Set Bit 5 if Original in 'A'..'Z'}
  mov     [edi+ebx], ecx
@@CheckDone:
  sub     ebx, 4
  jnc     @@Loop
  pop     esi
  pop     edi
  pop     ebx
end;

function LowerCase_Sha_Pas_2(const s: string): string;
var
  ch1, ch2, ch3, dist, term: integer;
  p: pchar;
label
  loop, last;
begin
  if s='' then begin;
    Result:=''; exit;
    end;

  p:=pointer(s);

  //If need pure Pascal change the next line to term:=Length(s);
  term:=pinteger(@p[-4])^;

  SetLength(Result,term);

  if term<>0 then begin;
    dist:=integer(Result);
    term:=integer(p+term);
    dist:=dist-integer(p)-4;

loop:
    ch1:=pinteger(p)^;
    ch3:=$7F7F7F7F;

    ch2:=ch1;
    ch3:=ch3 and ch1;

    ch2:=ch2 xor (-1);
    ch3:=ch3 + $25252525;

    ch2:=ch2 and $80808080;
    ch3:=ch3 and $7F7F7F7F;

    ch3:=ch3 + $1A1A1A1A;
    inc(p,4);

    ch3:=ch3 and ch2;
    if cardinal(p)>=cardinal(term) then goto last;

    ch3:=ch3 shr 2;
    ch1:=ch1 + ch3;
    pinteger(p+dist)^:=ch1;
    goto loop;

last:
    ch3:=ch3 shr 2;
    term:=term-integer(p);
    p:=p+dist;
    ch1:=ch1 + ch3;
    if term<-1
      then pword(p)^:=word(ch1)
      else pinteger(p)^:=ch1;
    end;
end;

procedure LowerCaseStub;
asm
  call SysUtils.LowerCase;
end;

end.
