unit FastcodeUpperCaseUnit;

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
 * Dennis Kjaer Christensen
 *
 * BV Version: 3.65
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

uses
  SysUtils;

type
  FastcodeUpperCaseFunction = function(const s: string): string;

{Functions shared between Targets}
function UpperCase_JOH_SSE2_2(const S: string): string;
function UpperCase_JOH_SSE_2(const S: string): string;
function UpperCase_JOH_MMX_3(const S: string): string;
function UpperCase_JOH_IA32_5(const S: string): string;
function UpperCase_DKC_Pas_32(const S: string): string;

{Functions not shared between Targets}

{Functions}

const
  FastcodeUpperCaseP4R: FastcodeUpperCaseFunction = UpperCase_JOH_SSE2_2;
  FastcodeUpperCaseP4N: FastcodeUpperCaseFunction = UpperCase_JOH_SSE_2;
  FastcodeUpperCasePMY: FastcodeUpperCaseFunction = UpperCase_JOH_MMX_3;
  FastcodeUpperCasePMD: FastcodeUpperCaseFunction = UpperCase_JOH_MMX_3;
  FastcodeUpperCaseAMD64: FastcodeUpperCaseFunction = UpperCase_JOH_MMX_3;
  FastcodeUpperCaseAMD64_SSE3: FastcodeUpperCaseFunction = UpperCase_JOH_SSE_2;
  FastCodeUpperCaseIA32SizePenalty: FastCodeUpperCaseFunction = UpperCase_JOH_IA32_5;
  FastcodeUpperCaseIA32: FastcodeUpperCaseFunction = SysUtils.UpperCase;
  FastcodeUpperCaseMMX: FastcodeUpperCaseFunction = UpperCase_JOH_MMX_3;
  FastCodeUpperCaseSSESizePenalty: FastCodeUpperCaseFunction = UpperCase_JOH_IA32_5;
  FastcodeUpperCaseSSE: FastcodeUpperCaseFunction = UpperCase_JOH_SSE_2;
  FastcodeUpperCaseSSE2: FastcodeUpperCaseFunction = UpperCase_JOH_SSE_2;
  FastCodeUpperCasePascalSizePenalty: FastCodeUpperCaseFunction = UpperCase_DKC_Pas_32;
  FastCodeUpperCasePascal: FastCodeUpperCaseFunction = UpperCase_DKC_Pas_32;

procedure UpperCaseStub;

implementation

var
 LookUpTable : array of Char;

function UpperCase_JOH_SSE2_2(const S: string): string;
const
  B05 : array[1..2] of Int64 = ($0505050505050505, $0505050505050505);
  B65 : array[1..2] of Int64 = ($6565656565656565, $6565656565656565);
  B20 : array[1..2] of Int64 = ($2020202020202020, $2020202020202020);
asm
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
  cmp     ebx, 32
  jg      @@Large
@@Small:
  mov     eax, [esi+ebx-4]       {Convert the Last 4 Characters of String}
  mov     ecx, $7f7f7f7f         {Note - For Strings of Length 1, 2 or 3, 
this}
  mov     edx, eax               {will Read/Write the last 1, 2 or 3 bytes 
of }
  not     edx                    {the Length Preaamble, but since these 
bytes }
  and     ecx, eax               {will always contain 0 in these cases, 
hey  }
  and     edx, $80808080         {will never be modified}
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx-4], eax
  sub     ebx, 1
  and     ebx, -4
  jz      @@Done                 {Exit if Length <= 4}
  add     esi, ebx
  add     edi, ebx
  neg     ebx
@@SmallLoop:                     {Loop converting 4 Character per Loop}
  mov     eax, [esi+ebx]
  mov     ecx, $7f7f7f7f
  mov     edx, eax
  not     edx
  and     ecx, eax
  and     edx, $80808080
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx], eax
  add     ebx, 4
  jnz     @@SmallLoop
@@Done:
  pop     esi
  pop     edi
  pop     ebx
  ret
@@Null:
  pop     esi
  pop     edi
  pop     ebx
  jmp     System.@LStrClr
@@Large:
  movdqu  xmm2, B05
  movdqu  xmm3, B65
  movdqu  xmm4, B20
  movdqu  xmm0, [esi]            {Translate First 16 Chars}
  movdqu  xmm1, xmm0
  paddb   xmm1, xmm2
  pcmpgtb xmm1, xmm3
  pand    xmm1, xmm4
  psubb   xmm0, xmm1
  movdqu  [edi], xmm0
  sub     ebx, 16
  movdqu  xmm0, [esi+ebx]        {Translate Last 16 Chars}
  movdqu  xmm1, xmm0
  paddb   xmm1, xmm2
  pcmpgtb xmm1, xmm3
  pand    xmm1, xmm4
  psubb   xmm0, xmm1
  movdqu  [edi+ebx], xmm0
  mov     ecx, edi               {Align Writes}
  add     esi, ebx
  add     ebx, edi
  and     edi, -16
  sub     ebx, edi
  add     edi, ebx
  sub     ebx, 16
  neg     ebx
@@LargeLoop:
  movdqu  xmm0, [esi+ebx]        {Translate Next 16 Chars}
  movdqa  xmm1, xmm0
  paddb   xmm1, xmm2
  pcmpgtb xmm1, xmm3
  pand    xmm1, xmm4
  psubb   xmm0, xmm1
  movdqa  [edi+ebx], xmm0
  add     ebx, 16
  jl      @@LargeLoop
  pop     esi
  pop     edi
  pop     ebx
end;

function UpperCase_JOH_SSE_2(const S: string): string;
const
  B05 : Int64 = $0505050505050505;
  B65 : Int64 = $6565656565656565;
  B20 : Int64 = $2020202020202020;
asm
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
  cmp     ebx, 32
  jg      @@Large
@@Small:
  mov     eax, [esi+ebx-4]       {Convert the Last 4 Characters of String}
  mov     ecx, $7f7f7f7f         {Note - For Strings of Length 1, 2 or 3,
this}
  mov     edx, eax               {will Read/Write the last 1, 2 or 3 bytes
of }
  not     edx                    {the Length Preaamble, but since these 
bytes }
  and     ecx, eax               {will always contain 0 in these cases, 
hey  }
  and     edx, $80808080         {will never be modified}
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx-4], eax
  sub     ebx, 1
  and     ebx, -4
  jz      @@Done                 {Exit if Length <= 4}
  add     esi, ebx
  add     edi, ebx
  neg     ebx
@@SmallLoop:                     {Loop converting 4 Character per Loop}
  mov     eax, [esi+ebx]
  mov     ecx, $7f7f7f7f
  mov     edx, eax
  not     edx
  and     ecx, eax
  and     edx, $80808080
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx], eax
  add     ebx, 4
  jnz     @@SmallLoop
@@Done:
  pop     esi
  pop     edi
  pop     ebx
  ret
@@Null:
  pop     esi
  pop     edi
  pop     ebx
  jmp     System.@LStrClr
@@Large:
  movq    mm4, B05
  movq    mm5, B65
  movq    mm6, B20
  movq    mm0, [esi  ]           {Translate First 16 Chars}
  movq    mm1, [esi+8]
  pshufw  mm2, mm0, $E4          {Faster Version of movq mm2, mm0}
  pshufw  mm3, mm1, $E4          {Faster Version of movq mm3, mm1}
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi  ], mm0
  movq    [edi+8], mm1
  sub     ebx, 16
  movq    mm0, [esi+ebx ]        {Translate Last 16 Chars}
  movq    mm1, [esi+ebx+8]
  pshufw  mm2, mm0, $E4          {Faster Version of movq mm2, mm0}
  pshufw  mm3, mm1, $E4          {Faster Version of movq mm3, mm1}
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi+ebx  ], mm0
  movq    [edi+ebx+8], mm1
  mov     ecx, edi               {Align Writes}
  add     esi, ebx
  add     ebx, edi
  and     edi, -16
  sub     ebx, edi
  add     edi, ebx
  sub     ebx, 16
  neg     ebx
@@LargeLoop:
  movq    mm0, [esi+ebx  ]       {Translate Next 16 Chars}
  movq    mm1, [esi+ebx+8]
  pshufw  mm2, mm0, $E4          {Faster Version of movq mm2, mm0}
  pshufw  mm3, mm1, $E4          {Faster Version of movq mm3, mm1}
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi+ebx  ], mm0
  movq    [edi+ebx+8], mm1
  add     ebx, 16
  jl      @@LargeLoop
  emms
  pop     esi
  pop     edi
  pop     ebx
end;

function UpperCase_JOH_MMX_3(const S: string): string;
const
  B05 : Int64 = $0505050505050505;
  B65 : Int64 = $6565656565656565;
  B20 : Int64 = $2020202020202020;
asm
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
  cmp     ebx, 32
  jg      @@Large
@@Small:
  mov     eax, [esi+ebx-4]       {Convert the Last 4 Characters of String}
  mov     ecx, $7f7f7f7f         {Note - For Strings of Length 1, 2 or 3, 
this}
  mov     edx, eax               {will Read/Write the last 1, 2 or 3 bytes 
of }
  not     edx                    {the Length Preaamble, but since these 
bytes }
  and     ecx, eax               {will always contain 0 in these cases, 
hey  }
  and     edx, $80808080         {will never be modified}
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx-4], eax
  sub     ebx, 1
  and     ebx, -4
  jz      @@Done                 {Exit if Length <= 4}
  add     esi, ebx
  add     edi, ebx
  neg     ebx
@@SmallLoop:                     {Loop converting 4 Character per Loop}
  mov     eax, [esi+ebx]
  mov     ecx, $7f7f7f7f
  mov     edx, eax
  not     edx
  and     ecx, eax
  and     edx, $80808080
  add     ecx, $05050505
  and     ecx, $7f7f7f7f
  add     ecx, $1a1a1a1a
  and     ecx, edx
  shr     ecx, 2
  xor     eax, ecx
  mov     [edi+ebx], eax
  add     ebx, 4
  jnz     @@SmallLoop
@@Done:
  pop     esi
  pop     edi
  pop     ebx
  ret
@@Null:
  pop     esi
  pop     edi
  pop     ebx
  jmp     System.@LStrClr
@@Large:
  movq    mm4, B05
  movq    mm5, B65
  movq    mm6, B20
  movq    mm0, [esi  ]           {Translate First 16 Chars}
  movq    mm1, [esi+8]
  movq    mm2, mm0
  movq    mm3, mm1
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi  ], mm0
  movq    [edi+8], mm1
  sub     ebx, 16
  movq    mm0, [esi+ebx ]        {Translate Last 16 Chars}
  movq    mm1, [esi+ebx+8]
  movq    mm2, mm0
  movq    mm3, mm1
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi+ebx  ], mm0
  movq    [edi+ebx+8], mm1
  mov     ecx, edi               {Align Writes}
  add     esi, ebx
  add     ebx, edi
  and     edi, -16
  sub     ebx, edi
  add     edi, ebx
  sub     ebx, 16
  neg     ebx
@@LargeLoop:
  movq    mm0, [esi+ebx  ]       {Translate Next 16 Chars}
  movq    mm1, [esi+ebx+8]
  movq    mm2, mm0
  movq    mm3, mm1
  paddb   mm2, mm4
  paddb   mm3, mm4
  pcmpgtb mm2, mm5
  pcmpgtb mm3, mm5
  pand    mm2, mm6
  pand    mm3, mm6
  psubb   mm0, mm2
  psubb   mm1, mm3
  movq    [edi+ebx  ], mm0
  movq    [edi+ebx+8], mm1
  add     ebx, 16
  jl      @@LargeLoop
  emms
  pop     esi
  pop     edi
  pop     ebx
end;

function UpperCase_JOH_IA32_5(const S: string): string;
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
  sub     eax, $7B7B7B7B         {Set High Bit if Original <= Ord('z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('a')}
  and     eax, edx               {80h if Orig in 'a'..'z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  sub     ecx, eax               {Clear Bit 5 if Original in 'a'..'z'}
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
  sub     eax, $7B7B7B7B         {Set High Bit if Original <= Ord('z')}
  xor     edx, ecx               {80h if Original < 128 else 00h}
  or      eax, $80808080         {Set High Bit}
  sub     eax, $66666666         {Set High Bit if Original >= Ord('a')}
  and     eax, edx               {80h if Orig in 'a'..'z' else 00h}
  shr     eax, 2                 {80h > 20h ('a'-'A')}
  sub     ecx, eax               {Clear Bit 5 if Original in 'a'..'z'}
  mov     [edi+ebx], ecx
@@CheckDone:
  sub     ebx, 4
  jnc     @@Loop
  pop     esi
  pop     edi
  pop     ebx
end;

procedure InitializeLookUpTable;
var
 I : Byte;
 S1, S2 : AnsiString;

begin
 SetLength(LookUpTable, 256);
 for I := 0 to 255 do
  begin
   S1 := Char(I);
   S2 := UpperCase(S1);
   LookUpTable[I] := S2[1];
  end;
end;

function UpperCase_DKC_Pas_32(const S: string): string;
var
 Max, CharNo : Cardinal;
 pResult : PChar;

begin
 Max := Length(S);
 SetLength(Result, Max);
 if Max > 0 then
  begin
   pResult := PChar(Result);
   CharNo := 0;
   repeat
    pResult[CharNo] := LookUpTable[Ord(S[CharNo+1])];
    Inc(CharNo);
    if CharNo >= Max then
     Break;
    pResult[CharNo] := LookUpTable[Ord(S[CharNo+1])];
    Inc(CharNo);
    if CharNo >= Max then
     Break;
    pResult[CharNo] := LookUpTable[Ord(S[CharNo+1])];
    Inc(CharNo);
    if CharNo >= Max then
     Break;
    pResult[CharNo] := LookUpTable[Ord(S[CharNo+1])];
    Inc(CharNo);
   until(CharNo >= Max);
  end;
end;

procedure UpperCaseStub;
asm
  call SysUtils.UpperCase;
end;

initialization
  InitializeLookUpTable;
end.
