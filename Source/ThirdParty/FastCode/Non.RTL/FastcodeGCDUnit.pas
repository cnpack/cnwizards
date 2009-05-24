unit FastcodeGCDUnit;

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
 * Lars Blok Gravengaard
 *
 * BV Version: 1.42
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeGCDFunction = function( A, B: Cardinal ): Cardinal;

{Functions shared between Targets}
function GCD_JOH_IA32_6( A, B: Cardinal ): Cardinal;
function GCD_JOH_IA32ext_4( A, B: Cardinal ): Cardinal;

{Functions not shared between Targets}
function GCD_JOH_IA32_8( A, B: Cardinal ): Cardinal;
function GCD_LBG_Pas_1( A, B: Cardinal ): Cardinal;
function GCD_JOH_Pas_5( A, B: Cardinal ): Cardinal;

{Functions}

const
  FastcodeGCDP4R: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDP4N: FastcodeGCDFunction = GCD_JOH_IA32_8;
  FastcodeGCDPMY: FastcodeGCDFunction = GCD_JOH_IA32ext_4;
  FastcodeGCDPMD: FastcodeGCDFunction = GCD_JOH_IA32ext_4;
  FastcodeGCDAMD64: FastcodeGCDFunction = GCD_JOH_IA32ext_4;
  FastcodeGCDAMD64_SSE3: FastcodeGCDFunction = GCD_JOH_IA32ext_4;
  FastcodeGCDIA32SizePenalty: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDIA32: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDMMX: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDSSESizePenalty: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDSSE: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDSSE2: FastcodeGCDFunction = GCD_JOH_IA32_6;
  FastcodeGCDPascalSizePenalty: FastcodeGCDFunction = GCD_LBG_Pas_1;
  FastcodeGCDPascal: FastcodeGCDFunction = GCD_JOH_Pas_5;

implementation

function GCD_JOH_IA32_6( A, B: Cardinal ): Cardinal;
asm {56 Bytes}
  push  ebx
  bsf   ecx, edx
  jz    @@Done
  bsf   ebx, eax
  jz    @@Done2
  shr   edx, cl
  cmp   ebx, ecx
  ja    @@Setup
  mov   ecx, ebx
@@Setup:
  push  ecx
  mov   ecx, ebx
@@Loop:
  shr   eax, cl
  mov   ecx, eax
  cmp   eax, edx
  ja    @@1
  je    @@Exit
  mov   eax, edx
  sub   eax, ecx
  mov   edx, ecx
  jmp   @@2
@@1:
  sub   eax, edx
@@2:
  bsf   ecx, eax
  jmp   @@Loop
@@Exit:
  pop   ecx
  pop   ebx
  shl   eax, cl
  ret
@@Done2:
  mov   eax, edx
@@Done:
  pop   ebx
end;

function GCD_JOH_IA32_8( A, B: Cardinal ): Cardinal;
asm {56 Bytes}
  push  ebx
  bsf   ecx, edx
  jz    @@Done1     {B = 0}
  bsf   ebx, eax
  jz    @@Done2     {A = 0}
  shr   edx, cl
  cmp   ebx, ecx
  ja    @@SaveShift
  mov   ecx, ebx
@@SaveShift:
  push  ecx         {Common Shift}
  mov   ecx, ebx
@@Loop:
  shr   eax, cl
  sub   eax, edx
  je    @@Exit
  mov   ebx, eax
  sbb   ecx, ecx
  and   ebx, ecx
  sub   eax, ebx
  add   edx, ebx
  sub   eax, ebx
  bsf   ecx, eax
  jmp   @@Loop
@@Exit:
  mov   eax, edx
  pop   ecx
  pop   ebx
  shl   eax, cl
  ret
@@Done2:
  mov   eax, edx
@@Done1:
  pop   ebx
end;                           

function GCD_JOH_IA32ext_4( A, B: Cardinal ): Cardinal;
asm {56 Bytes}
  bsf   ecx, edx
  jz    @@Done1     {B = 0}
  push  ebx
  push  edi
  bsf   ebx, eax
  jz    @@Done2     {A = 0}
  shr   edx, cl
  mov   edi, ecx
  cmp   ebx, ecx
  mov   ecx, ebx
  cmovb edi, ebx    {Common Shift}
@@Loop:
  shr   eax, cl
  cmp   eax, edx
  mov   ecx, eax
  je    @@Exit
  cmovb eax, edx
  cmovb edx, ecx
  sub   eax, edx
  bsf   ecx, eax
  jmp   @@Loop
@@Exit:
  mov   ecx, edi
  shl   eax, cl
  pop   edi
  pop   ebx
  ret
@@Done2:
  mov   eax, edx
  pop   edi
  pop   ebx
@@Done1:
end;

function GCD_LBG_Pas_1( A, B: Cardinal ): Cardinal;
var
   temp: Cardinal;
begin
   while B <> 0 do
   begin
      Temp := B;
      B := A mod Temp;
      A := Temp;
   end;
   Result := A;
end;

function GCD_JOH_Pas_5( A, B: Cardinal ): Cardinal;
begin {120 Bytes}
  if (B <= 1) then
    begin
      if B = 0 then
        Result := A
      else
        Result := B
    end {B <= 1}
  else
    if (A <= 1) then
      begin
        if A = 0 then
          Result := B
        else
          Result := A
      end {A <= 1}
    else
      begin
        Result := 1;
        while (not Odd(A)) and (not Odd(B)) do
          begin
            A := A shr 1;
            B := B shr 1;
            Result := Result + Result;
          end;
        while not Odd(A) do
          A := A shr 1;
        while not Odd(B) do
          B := B shr 1;
        repeat
          if A < B then
            begin
              B := (B-A) shr 1;
              while not Odd(B) do
                B := B shr 1;
            end
          else
            if A > B then
              begin
                A := (A-B) shr 1;
                while not Odd(A) do
                  A := A shr 1;
              end
            else
              begin
                Result := Result * B; Exit;
              end
        until False;
      end;
end;

end.
