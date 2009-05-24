unit FastCodeStrLenUnit;

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
 * Pierre le Riche
 * Lars Blok Gravengaard
 *
 * BV Version: 1.32
 * ***** END LICENSE BLOCK ***** *)

interface

{$I FastCode.inc}

type
  FastCodeStrLenFunction = function(const Str: PChar): Cardinal;

{Functions shared between Targets}
function StrLen_JOH_SSE2_1(const Str: PChar): Cardinal;
function StrLen_JOH_SSE2_2(const Str: PChar): Cardinal;
function StrLen_JOH_IA32_7(const Str: PChar): Cardinal;
function StrLen_PLR_IA32_1(const Str: PChar): Cardinal;

{Functions not shared between Targets}
function StrLen_LBG_PAS_1(const Str:PChar): Cardinal;
function StrLen_JOH_PAS_3(const Str: PChar): Cardinal;

{Functions}

const
  FastCodeStrLenP4R: FastCodeStrLenFunction = StrLen_JOH_SSE2_1;
  FastCodeStrLenP4N: FastCodeStrLenFunction = StrLen_JOH_SSE2_2;
  FastCodeStrLenPMY: FastCodeStrLenFunction = StrLen_JOH_SSE2_1;
  FastCodeStrLenPMD: FastCodeStrLenFunction = StrLen_JOH_SSE2_1;
  FastCodeStrLenAMD64: FastCodeStrLenFunction = StrLen_JOH_SSE2_1;
  FastCodeStrLenAMD64_SSE3: FastCodeStrLenFunction = StrLen_JOH_SSE2_1;
  FastCodeStrLenIA32SizePenalty: FastCodeStrLenFunction = StrLen_PLR_IA32_1;
  FastCodeStrLenIA32: FastCodeStrLenFunction = StrLen_JOH_IA32_7;
  FastCodeStrLenMMX: FastCodeStrLenFunction = StrLen_JOH_IA32_7;
  FastCodeStrLenSSESizePenalty: FastCodeStrLenFunction = StrLen_PLR_IA32_1;
  FastCodeStrLenSSE: FastCodeStrLenFunction = StrLen_JOH_IA32_7;
  FastCodeStrLenSSE2: FastCodeStrLenFunction = StrLen_JOH_SSE2_2;
  FastCodeStrLenPascalSizePenalty: FastCodeStrLenFunction = StrLen_LBG_PAS_1;
  FastCodeStrLenPascal: FastCodeStrLenFunction = StrLen_JOH_PAS_3;

function StrLenStub(const Str: PChar): Cardinal;

implementation

uses
  SysUtils;

function StrLen_JOH_SSE2_1(const Str: PChar): Cardinal;
asm
  lea      ecx, [eax+16]
  test     ecx, $ff0
  jz       @@NearPageEnd
@@WithinPage:
  pxor     xmm0, xmm0
  movdqu   xmm1, [eax]
  add      eax, 16
  pcmpeqb  xmm1, xmm0
  pmovmskb edx, xmm1
  test     edx, edx
  jnz      @@SetResult
  and      eax, -16
@@AlignedLoop:
  movdqa   xmm1, [eax]
  add      eax, 16
  pcmpeqb  xmm1, xmm0
  pmovmskb edx, xmm1
  test     edx, edx
  jz       @@AlignedLoop
@@SetResult:
  bsf      edx, edx
  add      eax, edx
  sub      eax, ecx
  ret
@@NearPageEnd:
  mov      edx, eax
@@Loop:
  cmp      byte ptr [eax], 0
  je       @@SetResult2
  add      eax, 1
  test     eax, 15
  jnz      @@Loop
  jmp      @@WithinPage
@@SetResult2:
  sub      eax, edx
end;

function StrLen_JOH_IA32_7(const Str: PChar): Cardinal;
asm
  cmp   byte ptr [eax], 0
  je    @@0
  cmp   byte ptr [eax+1], 0
  je    @@1
  cmp   byte ptr [eax+2], 0
  je    @@2
  cmp   byte ptr [eax+3], 0
  je    @@3
  push  eax
  and   eax, -4              {DWORD Align Reads}
@@Loop:
  add   eax, 4
  mov   edx, [eax]           {4 Chars per Loop}
  lea   ecx, [edx-$01010101]
  not   edx
  and   edx, ecx
  and   edx, $80808080       {Set Byte to $80 at each #0 Position}
  jz    @@Loop               {Loop until any #0 Found}
@@SetResult:
  pop   ecx
  bsf   edx, edx             {Find First #0 Position}
  shr   edx, 3               {Byte Offset of First #0}
  add   eax, edx             {Address of First #0}
  sub   eax, ecx
  ret
@@0:
  xor   eax, eax
  ret
@@1:
  mov   eax, 1
  ret
@@2:
  mov   eax, 2
  ret
@@3:
  mov   eax, 3
end;

function StrLen_JOH_SSE2_2(const Str: PChar): Cardinal;
asm
  lea      ecx, [eax+16]
  test     ecx, $ff0
  pxor     xmm0, xmm0
  jz       @@NearPageEnd     {Within 16 Bytes of Page End}
@@WithinPage:
  movdqu   xmm1, [eax]       {Check First 16 Bytes for #0}
  add      eax, 16
  pcmpeqb  xmm1, xmm0
  pmovmskb edx, xmm1
  test     edx, edx
  jnz      @@SetResult
  and      eax, -16          {Align Memory Reads}
@@AlignedLoop:
  movdqa   xmm1, [eax]       {Check Next 16 Bytes for #0}
  add      eax, 16
  pcmpeqb  xmm1, xmm0
  pmovmskb edx, xmm1
  test     edx, edx
  jz       @@AlignedLoop
@@SetResult:
  bsf      edx, edx          {#0 Found - Set Result}
  add      eax, edx
  sub      eax, ecx
  ret
@@NearPageEnd:
  mov      edx, eax
@@Loop:
  cmp      byte ptr [eax], 0 {Loop until #0 Found or 16-Byte Aligned}
  je       @@SetResult2
  add      eax, 1
  test     eax, 15
  jnz      @@Loop
  jmp      @@AlignedLoop
@@SetResult2:
  sub      eax, edx
end;

function StrLen_PLR_IA32_1(const Str: PChar): Cardinal;
asm
  {Check the first byte}
  cmp byte ptr [eax], 0
  je @ZeroLength
  {Get the negative of the string start in edx}
  mov edx, eax
  neg edx
  {Word align}
  add eax, 1
  and eax, -2
@ScanLoop:
  mov cx, [eax]
  add eax, 2
  test cl, ch
  jnz @ScanLoop
  test cl, cl
  jz @ReturnLess2
  test ch, ch
  jnz @ScanLoop
  lea eax, [eax + edx - 1]
  ret
@ReturnLess2:
  lea eax, [eax + edx - 2]
  ret
@ZeroLength:
  xor eax, eax
end;

function StrLen_LBG_PAS_1(const Str:PChar): Cardinal;
begin
  Result:=0;
  while Str[Result]<>#0 do Inc(Result)
end;

function StrLen_JOH_PAS_3(const Str: PChar): Cardinal;
var
  P, PStr: PChar;
  I, J: Integer;
begin
  if Str^ = #0 then
    begin
      Result := 0; Exit;
    end;
  if Str[1] = #0 then
    begin
      Result := 1; Exit;
    end;
  if Str[2] = #0 then
    begin
      Result := 2; Exit;
    end;
  if Str[3] = #0 then
    begin
      Result := 3; Exit;
    end;
 P := Pointer(Str);
 PStr := P;
 P := Pointer(Integer(P) and -4);
 repeat
   Inc(P, 4);
   I := PInteger(P)^;
   J := I - $01010101;
   I := not(I);
   I := I and J;
 until (I and $80808080) <> 0;
 Result := P - PStr;
 if I and $80 = 0 then
   if I and $8000 <> 0 then
     Inc(Result)
   else
     if I and $800000 <> 0 then
       Inc(Result, 2)
     else
       Inc(Result, 3)
end;

function StrLenStub(const Str: PChar): Cardinal;
asm
  call SysUtils.StrLen;
end;

end.
