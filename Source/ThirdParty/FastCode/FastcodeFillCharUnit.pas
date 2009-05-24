unit FastcodeFillCharUnit;

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
 * Portions created by the Initial Developer are Copyright (C) 2002-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Charalabos Michael <chmichael@creationpower.com>
 * John O'Harrow <john@elmcrest.demon.co.uk>
 * Dennis Kjaer Christensen
 * Chris Grant
 *
 * BV Version: 1.63
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeFillCharFunction = procedure(var Dest; count: Integer; Value: Char);

{Functions shared between Targets}
procedure FillChar_DKC_SSE2_10(var Dest; count: Integer; Value: Char);
procedure FillChar_JOH_SSE2_1(var Dest; count: Integer; Value: Char);
procedure FillChar_JOH_MMX_4(var Dest; count: Integer; Value: Char);
procedure FillChar_JOH_IA32_2(var Dest; count: Integer; Value: Char);
procedure FillChar_JOH_SSE_1(var Dest; count: Integer; Value: Char);

{Functions not shared between Targets}
procedure FillChar_JOH_PAS_1(var Dest; count: Integer; Value: Char);
procedure FillChar_CJG_Pas_5(var Dest; count: Integer; Value: Char);

{Functions}

const
  FastcodeFillCharP4R: FastcodeFillCharFunction = FillChar_DKC_SSE2_10;
  FastcodeFillCharP4N: FastcodeFillCharFunction = FillChar_JOH_SSE2_1;
  FastcodeFillCharPMY: FastcodeFillCharFunction = FillChar_JOH_MMX_4;
  FastcodeFillCharPMD: FastcodeFillCharFunction = FillChar_JOH_MMX_4;
  FastcodeFillCharAMD64: FastcodeFillCharFunction = FillChar_DKC_SSE2_10;
  FastcodeFillCharAMD64_SSE3: FastcodeFillCharFunction = FillChar_JOH_SSE2_1;
  FastCodeFillCharIA32SizePenalty: FastCodeFillCharFunction = FillChar_JOH_IA32_2;
  FastcodeFillCharIA32: FastcodeFillCharFunction = FillChar_JOH_IA32_2;
  FastcodeFillCharMMX: FastcodeFillCharFunction = FillChar_JOH_MMX_4;
  FastCodeFillCharSSESizePenalty: FastCodeFillCharFunction = FillChar_JOH_SSE_1;
  FastcodeFillCharSSE: FastcodeFillCharFunction = FillChar_JOH_SSE_1;
  FastcodeFillCharSSE2: FastcodeFillCharFunction = FillChar_JOH_SSE2_1;
  FastCodeFillCharPascalSizePenalty: FastCodeFillCharFunction = FillChar_JOH_PAS_1;
  FastCodeFillCharPascal: FastCodeFillCharFunction = FillChar_CJG_Pas_5;

procedure FillCharStub;

implementation

uses
  SysUtils;

procedure FillChar_DKC_SSE2_10(var Dest; count: Integer; Value: Char);
asm
   test edx,edx
   jle  @Exit2
   //case Count of
   cmp  edx,31
   jnbe @CaseElse
   jmp  dword ptr [edx*4+@Case1JmpTable]
 @CaseCount0 :
   ret
 @CaseCount1 :
   mov  [eax],cl
   ret
 @CaseCount2 :
   mov  ch,cl
   mov  [eax],cx
   ret
 @CaseCount3 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cl
   ret
 @CaseCount4 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   ret
 @CaseCount5 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cl
   ret
 @CaseCount6 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   ret
 @CaseCount7 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cl
   ret
 @CaseCount8 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   ret
 @CaseCount9 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cl
   ret
 @CaseCount10 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   ret
 @CaseCount11 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cl
   ret
 @CaseCount12 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   ret
 @CaseCount13 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cl
   ret
 @CaseCount14 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   ret
 @CaseCount15 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cl
   ret
 @CaseCount16 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   ret
 @CaseCount17 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cl
   ret
 @CaseCount18 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   ret
 @CaseCount19 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   mov  [eax+18],cl
   ret
 @CaseCount20 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   ret
 @CaseCount21 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cl
   ret
 @CaseCount22 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   ret
 @CaseCount23 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cl
   ret
 @CaseCount24 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   ret
 @CaseCount25 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cl
   ret
 @CaseCount26 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   ret
 @CaseCount27 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cl
   ret
 @CaseCount28 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   ret
 @CaseCount29 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cl
   ret
 @CaseCount30 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   ret
 @CaseCount31 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   mov   [eax+30],cl
   ret
   nop
   nop
   nop
   nop
   nop
 @CaseElse :
   //Need at least 32 bytes here. Max 16 for alignment and 16 for loop
   push    esi
   push    edi
   //Broadcast value
   mov     ch, cl
   movd    xmm0, ecx
   pshuflw xmm0, xmm0, 0
   pshufd  xmm0, xmm0, 0
   //Fill first 16 non aligned bytes
   movdqu  [eax],xmm0
   //StopP2 := P + Count;
   lea     ecx,[eax+edx]
   //16 byte Align
   mov     edi,eax
   and     edi,$F
   mov     esi,16
   sub     esi,edi
   add     eax,esi
   sub     edx,esi
   //I := 0;
   xor     esi,esi
   sub     edx,15
   cmp     edx,1048576
   ja      @Repeat4
 @Repeat1 :
   movdqa  [eax+esi],xmm0
   add     esi,16
   cmp     esi,edx
   jl      @Repeat1
   jmp     @Repeat4End
   nop
   nop
 @Repeat4 :
   movntdq [eax+esi],xmm0
   add     esi,16
   cmp     esi,edx
   jl      @Repeat4
 @Repeat4End :
   {movdq2q mm0,xmm0
   movntq  [ecx-16],mm0
   movntq  [ecx-8], mm0
   emms}
   //Fill the rest
   movdqu [ecx-16],xmm0
 @Exit1 :
   pop   edi
   pop   esi
 @Exit2 :
   ret
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop

@Case1JmpTable:
 dd @CaseCount0
 dd @CaseCount1
 dd @CaseCount2
 dd @CaseCount3
 dd @CaseCount4
 dd @CaseCount5
 dd @CaseCount6
 dd @CaseCount7
 dd @CaseCount8
 dd @CaseCount9
 dd @CaseCount10
 dd @CaseCount11
 dd @CaseCount12
 dd @CaseCount13
 dd @CaseCount14
 dd @CaseCount15
 dd @CaseCount16
 dd @CaseCount17
 dd @CaseCount18
 dd @CaseCount19
 dd @CaseCount20
 dd @CaseCount21
 dd @CaseCount22
 dd @CaseCount23
 dd @CaseCount24
 dd @CaseCount25
 dd @CaseCount26
 dd @CaseCount27
 dd @CaseCount28
 dd @CaseCount29
 dd @CaseCount30
 dd @CaseCount31
end;

procedure FillChar_JOH_SSE2_1(var Dest; count: Integer; Value: Char);
asm {Size = 161 Bytes}
  cmp       edx, 32
  mov       ch, cl                {Copy Value into both Bytes of CX}
  jl        @@Small
  sub       edx, 16
  movd      xmm0, ecx
  pshuflw   xmm0, xmm0, 0
  pshufd    xmm0, xmm0, 0
  movups    [eax], xmm0           {Fill First 16 Bytes}
  movups    [eax+edx], xmm0       {Fill Last 16 Bytes}
  mov       ecx, eax              {16-Byte Align Writes}
  and       ecx, 15
  sub       ecx, 16
  sub       eax, ecx
  add       edx, ecx
  add       eax, edx
  neg       edx
  cmp       edx, -512*1024
  jb        @@Large
@@Loop:
  movaps    [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  add       edx, 16
  jl        @@Loop
  ret
@@Large:
  movntdq    [eax+edx], xmm0      {Fill 16 Bytes per Loop}
  add       edx, 16
  jl        @@Large
  ret
@@Small:
  test      edx, edx
  jle       @@Done
  mov       [eax+edx-1], cl       {Fill Last Byte}
  and       edx, -2               {No. of Words to Fill}
  neg       edx
  lea       edx, [@@SmallFill + 60 + edx * 2]
  jmp       edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov       [eax+28], cx
  mov       [eax+26], cx
  mov       [eax+24], cx
  mov       [eax+22], cx
  mov       [eax+20], cx
  mov       [eax+18], cx
  mov       [eax+16], cx
  mov       [eax+14], cx
  mov       [eax+12], cx
  mov       [eax+10], cx
  mov       [eax+ 8], cx
  mov       [eax+ 6], cx
  mov       [eax+ 4], cx
  mov       [eax+ 2], cx
  mov       [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure FillChar_JOH_MMX_4(var Dest; count: Integer; Value: Char);
asm
  cmp       edx, 32
  mov       ch, cl                {Copy Value into both Bytes of CX}
  jl        @@Small
  movd      mm0, ecx
  mov       ecx, eax
  sub       edx, 16
  punpcklwd mm0, mm0
  punpckldq mm0, mm0              {Copy Value into all 8 Bytes of MM0}
  movq      [eax], mm0            {Fill First 8 Bytes}
  movq      [eax+edx], mm0        {Fill Last 16 Bytes}
  movq      [eax+edx+8], mm0
  add       eax, edx              {Qword align writes}
  and       ecx, 7
  sub       ecx, 8
  add       edx, ecx
  neg       edx
@@Loop:
  movq      [eax+edx], mm0        {Fill 16 Bytes per Loop}
  movq      [eax+edx+8], mm0
  add       edx, 16
  jl        @@Loop
  emms
  ret
@@Small:
  test      edx, edx
  jle       @@Done
  mov       [eax+edx-1], cl       {Fill Last Byte}
  and       edx, -2               {Byte Pairs to Fill}
  neg       edx
  lea       edx, [@@Fill + 60 + edx * 2]
  jmp       edx
@@Fill:
  mov       [eax+28], cx
  mov       [eax+26], cx
  mov       [eax+24], cx
  mov       [eax+22], cx
  mov       [eax+20], cx
  mov       [eax+18], cx
  mov       [eax+16], cx
  mov       [eax+14], cx
  mov       [eax+12], cx
  mov       [eax+10], cx
  mov       [eax+ 8], cx
  mov       [eax+ 6], cx
  mov       [eax+ 4], cx
  mov       [eax+ 2], cx
  mov       [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure FillChar_JOH_IA32_2(var Dest; count: Integer; Value: Char);
asm {Size = 153 Bytes}
  cmp   edx, 32
  mov   ch, cl                    {Copy Value into both Bytes of CX}
  jl    @@Small
  mov   [eax  ], cx               {Fill First 8 Bytes}
  mov   [eax+2], cx
  mov   [eax+4], cx
  mov   [eax+6], cx
  sub   edx, 16
  fld   qword ptr [eax]
  fst   qword ptr [eax+edx]       {Fill Last 16 Bytes}
  fst   qword ptr [eax+edx+8]
  mov   ecx, eax
  and   ecx, 7                    {8-Byte Align Writes}
  sub   ecx, 8
  sub   eax, ecx
  add   edx, ecx
  add   eax, edx
  neg   edx
@@Loop:
  fst   qword ptr [eax+edx]       {Fill 16 Bytes per Loop}
  fst   qword ptr [eax+edx+8]
  add   edx, 16
  jl    @@Loop
  ffree st(0)
  ret
  nop
  nop
  nop
@@Small:
  test  edx, edx
  jle   @@Done
  mov   [eax+edx-1], cl       {Fill Last Byte}
  and   edx, -2               {No. of Words to Fill}
  neg   edx
  lea   edx, [@@SmallFill + 60 + edx * 2]
  jmp   edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov   [eax+28], cx
  mov   [eax+26], cx
  mov   [eax+24], cx
  mov   [eax+22], cx
  mov   [eax+20], cx
  mov   [eax+18], cx
  mov   [eax+16], cx
  mov   [eax+14], cx
  mov   [eax+12], cx
  mov   [eax+10], cx
  mov   [eax+ 8], cx
  mov   [eax+ 6], cx
  mov   [eax+ 4], cx
  mov   [eax+ 2], cx
  mov   [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure FillChar_JOH_SSE_1(var Dest; count: Integer; Value: Char);
asm {Size = 161 Bytes}
  cmp       edx, 32
  mov       ch, cl                {Copy Value into both Bytes of CX}
  jl        @@Small
  sub       edx, 16
  mov       [eax], cx             {Fill First 4 Bytes}
  mov       [eax+2], cx
  movss     xmm0, [eax]           {Set each byte of XMM0 to Value}
  shufps    xmm0, xmm0, 0
  movups    [eax], xmm0           {Fill First 16 Bytes}
  movups    [eax+edx], xmm0       {Fill Last 16 Bytes}
  mov       ecx, eax              {16-Byte Align Writes}
  and       ecx, 15
  sub       ecx, 16
  sub       eax, ecx
  add       edx, ecx
  add       eax, edx
  neg       edx
  cmp       edx, -512*1024
  jb        @@Large
@@Loop:
  movaps    [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  add       edx, 16
  jl        @@Loop
  ret
@@Large:
  movntps   [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  add       edx, 16
  jl        @@Large
  ret
@@Small:
  test      edx, edx
  jle       @@Done
  mov       [eax+edx-1], cl       {Fill Last Byte}
  and       edx, -2               {No. of Words to Fill}
  neg       edx
  lea       edx, [@@SmallFill + 60 + edx * 2]
  jmp       edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov       [eax+28], cx
  mov       [eax+26], cx
  mov       [eax+24], cx
  mov       [eax+22], cx
  mov       [eax+20], cx
  mov       [eax+18], cx
  mov       [eax+16], cx
  mov       [eax+14], cx
  mov       [eax+12], cx
  mov       [eax+10], cx
  mov       [eax+ 8], cx
  mov       [eax+ 6], cx
  mov       [eax+ 4], cx
  mov       [eax+ 2], cx
  mov       [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure FillChar_JOH_PAS_1(var Dest; count: Integer; Value: Char);
var {Size = 132 Byte}
  I, J, K : Integer;
  P       : PByte;
begin
  I := Count;
  P := @Dest;
  if I >= 8 then
    begin
      J := Byte(Value);
      J := J or (J shl  8);
      J := J or (J shl 16);
      PInteger(P)^ := J;
      if I > 128 then
        begin {Alligned Fill 16 Chars per Loop}
          K := (Integer(P) and 3) - 20;
          Inc(P, I - 16);
          Inc(I, K);
          PintegerArray(P)[0] := J;
          PintegerArray(P)[1] := J;
          PintegerArray(P)[2] := J;
          PintegerArray(P)[3] := J;
          repeat
            PintegerArray(Integer(P)-I)[0] := J;
            PintegerArray(Integer(P)-I)[1] := J;
            PintegerArray(Integer(P)-I)[2] := J;
            PintegerArray(Integer(P)-I)[3] := J;
            Dec(I, 16);
          until I <= 0;
        end
      else
        begin {Fill 4 Chars per Loop}
          Inc(P, I);
          PInteger(Integer(P)-4)^ := J;
          repeat
            PInteger(Integer(P)-I)^ := J;
            Dec(I, 4);
          until I <= 4;
        end;
    end
  else
    if I > 0 then
      repeat
        Dec(I);
        PByteArray(P)[I] := Ord(Value);
      until I = 0;
end;

procedure FillChar_CJG_Pas_5(var Dest; count: Integer; Value: Char);
var
  I, J, K : Integer;
  P    : Pointer;
  Label P01, P02, P03, P04, P05, P06, P07, P08, P09, P10, P11, P12;
begin
  if Count > 0 then
    begin
      P := @Dest;
      If Count >= 12 then
        begin
          J := Byte(Value);
          J := J or (J shl  8);
          J := J or (J shl 16);

          PInteger(P)^ := J;
          PInteger(Integer(P) + Count - 4)^ := J;

          I := Count shr 2;

          if Count >= 256 then
            begin
              if count < 448 then
                begin
                  PIntegerArray(P)[1] := J;
                  PIntegerArray(P)[2] := J;
                  PIntegerArray(P)[3] := J;

                  repeat
                    Dec(I,4);
                    PIntegerArray(P)[I]   := J;
                    PIntegerArray(P)[I+1] := J;
                    PIntegerArray(P)[I+2] := J;
                    PIntegerArray(P)[I+3] := J;
                  until I < 4;
                end
              else
                begin
                  I := Count;
                  K := (Integer(P) and 3) - 4;
                  Dec(I, 16);
                  Dec(PByte(P), K);
                  Inc(I, K);
                  Inc(PByte(P), I);
                  PintegerArray(P)[0] := J;
                  PintegerArray(P)[1] := J;
                  PintegerArray(P)[2] := J;
                  PintegerArray(P)[3] := J;
                  repeat
                    PintegerArray(Integer(P)-I)[0] := J;
                    PintegerArray(Integer(P)-I)[1] := J;
                    PintegerArray(Integer(P)-I)[2] := J;
                    PintegerArray(Integer(P)-I)[3] := J;
                    Dec(I, 16);
                  until I <= 0;
                end
             end
          else
            begin
              repeat
                Dec(I,2);
                PIntegerArray(P)[I] := J;
                PIntegerArray(P)[I+1] := J;
              until I < 2;
            end
        end
      else
        begin
          case Count of
            1:  goto P01;
            2:  goto P02;
            3:  goto P03;
            4:  goto P04;
            5:  goto P05;
            6:  goto P06;
            7:  goto P07;
            8:  goto P08;
            9:  goto P09;
            10: goto P10;
            11: goto P11;
            12: goto P12;
          end;
          P12: PByteArray(P)[11] := Byte(Value);
          P11: PByteArray(P)[10] := Byte(Value);
          P10: PByteArray(P)[09] := Byte(Value);
          P09: PByteArray(P)[08] := Byte(Value);
          P08: PByteArray(P)[07] := Byte(Value);
          P07: PByteArray(P)[06] := Byte(Value);
          P06: PByteArray(P)[05] := Byte(Value);
          P05: PByteArray(P)[04] := Byte(Value);
          P04: PByteArray(P)[03] := Byte(Value);
          P03: PByteArray(P)[02] := Byte(Value);
          P02: PByteArray(P)[01] := Byte(Value);
          P01: PByteArray(P)[00] := Byte(Value);

        end
    end;
end;

procedure FillCharStub;
asm
  call SysUtils.@FillChar;
end;

end.
