unit FastcodePosIExUnit;

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
 * Dennis Kjaer Christensen <marianndkc@home3.gvdnet.dk>
 *
 * BV Version: 1.31
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodePosIExFunction = function(const SubStr, S: string; Offset: Integer = 1): Integer;

{Functions shared between Targets}
function PosIEx_JOH_IA32_1(const SubStr, S: string; Offset: Integer = 1): Integer;
function PosIEx_DKC_Pas_24(const SubStr, S: string; Offset: Integer = 1): Integer;

{Functions not shared between Targets}

{Functions}

const
  FastcodePosIExP4R: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExP4N: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExPMY: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExPMD: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExAMD64: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExAMD64_SSE3: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExIA32SizePenalty: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExIA32: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExMMX: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExSSESizePenalty: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExSSE: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExSSE2: FastcodePosIExFunction = PosIEx_JOH_IA32_1;
  FastcodePosIExPascalSizePenalty: FastcodePosIExFunction = PosIEx_DKC_Pas_24;
  FastcodePosIExPascal: FastcodePosIExFunction = PosIEx_DKC_Pas_24;

implementation

uses
  SysUtils;
  
var
 LookUpTable: array of Char;

function PosIEx_JOH_IA32_1(const SubStr, S: string; Offset: Integer = 1): Integer;
const
  LocalsSize = 32;
  _ebx =  0;
  _edi =  4;
  _esi =  8;
  _ebp = 12;
  _edx = 16;
  _ecx = 20;
  _end = 24;
  _tmp = 28;
asm
  sub     esp, LocalsSize  {Setup Local Storage}
  mov     [esp._ebx], ebx
  cmp     eax, 1
  sbb     ebx, ebx         {-1 if SubStr = '' else 0}
  sub     edx, 1           {-1 if S = ''}
  sbb     ebx, 0           {Negative if S = '' or SubStr = '' else 0}
  sub     ecx, 1           {Offset - 1}
  or      ebx, ecx         {Negative if S = '' or SubStr = '' or Offset < 1}
  jl      @@InvalidInput
  mov     [esp._edi], edi
  mov     [esp._esi], esi
  mov     [esp._ebp], ebp
  mov     [esp._edx], edx
  mov     edi, [eax-4]     {Length(SubStr)}
  mov     esi, [edx-3]     {Length(S)}
  add     ecx, edi
  cmp     ecx, esi
  jg      @@NotFound       {Offset to High for a Match}
  test    edi, edi
  jz      @@NotFound       {Length(SubStr = 0)}
  add     esi, edx         {Last Character Position in S}
  add     eax, edi         {Last Character Position in SubStr + 1}
  mov     [esp._end], eax  {Save SubStr End Positiom}
  add     edx, ecx         {Search Start Position in S for Last Character}
  movzx   eax, [eax-1]     {Last Character of SubStr}
  mov     bl, al           {Convert Character into Uppercase}
  add     bl, $9f
  sub     bl, $1a
  jnb     @@UC1
  sub     al, $20
@@UC1:
  mov     ah, al
  neg     edi              {-Length(SubStr)}
  mov     ecx, eax
  shl     eax, 16
  or      ecx, eax         {All 4 Bytes = Uppercase Last Character of 
SubStr}
@@MainLoop:
  add     edx, 4
  cmp     edx, esi
  ja      @@Remainder      {1 to 4 Positions Remaining}
  mov     eax, [edx-4]     {Check Next 4 Bytes of S}
  mov     ebx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  xor     eax, ecx         {Zero Byte at each Matching Position}
  lea     ebx, [eax-$01010101]
  not     eax
  and     eax, ebx
  and     eax, $80808080   {Set Byte to $80 at each Match Position else $00}
  jz      @@MainLoop       {Loop Until any Match on Last Character Found}
  bsf     eax, eax         {Find First Match Bit}
  shr     eax, 3           {Byte Offset of First Match (0..3)}
  lea     edx, [eax+edx-3] {Address of First Match on Last Character + 1}
@@Compare:
  cmp     edi, -4
  jle     @@Large
  cmp     edi, -1
  je      @@SetResult      {Exit with Match if Lenght(SubStr) = 1}
  mov     eax, [esp._end]  {SubStr End Position}
  movzx   eax, word ptr [edi+eax] {Last Char Matches - Compare First 2 
Chars}
  cmp     ax, [edi+edx]
  je      @@SetResult      {Same - Skip Uppercase Conversion}
  mov     ebx, eax         {Convert Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  mov     [esp._tmp], eax  {Save Converted Characters}
  movzx   eax, word ptr [edi+edx]
  mov     ebx, eax         {Convert Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  cmp     eax, [esp._tmp]
  jne     @@MainLoop       {No Match on First 2 Characters}
@@SetResult:               {Full Match}
  lea     eax, [edx+edi]   {Calculate and Return Result}
  sub     eax, [esp._edx]  {Subtract Start Position}
  jmp     @@Done
@@NotFound:
  xor     eax, eax         {No Match Found - Return 0}
@@Done:
  mov     ebx, [esp._ebx]
  mov     edi, [esp._edi]
  mov     esi, [esp._esi]
  mov     ebp, [esp._ebp]
  add     esp, LocalsSize  {Release Local Storage}
  ret
@@Large:
  mov     eax, [esp._end]  {SubStr End Position}
  mov     eax, [eax-4]     {Compare Last 4 Characters of S and SubStr}
  cmp     eax, [edx-4]
  je      @@LargeCompare   {Same - Skip Uppercase Conversion}
  mov     ebx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  mov     [esp._tmp], eax  {Save Converted Characters}
  mov     eax, [edx-4]
  mov     ebx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  cmp     eax, [esp._tmp]  {Compare Converted Characters}
  jne     @@MainLoop       {No Match on Last 4 Characters}
@@LargeCompare:
  mov     ebx, edi         {Offset}
  mov     [esp._ecx], ecx  {Save ECX}
@@CompareLoop:             {Compare Remaining Characters}
  add     ebx, 4           {Compare 4 Characters per Loop}
  jge     @@SetResult      {All Characters Matched}
  mov     eax, [esp._end]  {SubStr End Positiob}
  mov     eax, [ebx+eax-4]
  cmp     eax, [ebx+edx-4]
  je      @@CompareLoop    {Same - Skip Uppercase Conversion}
  mov     ecx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ecx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ecx
  mov     [esp._tmp], eax
  mov     eax, [ebx+edx-4]
  mov     ecx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ecx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ecx
  cmp     eax, [esp._tmp]
  je      @@CompareLoop    {Match on Next 4 Characters}
  mov     ecx, [esp._ecx]  {Restore ECX for Next Main Loop}
  jmp     @@MainLoop       {No Match}
@@Remainder:               {Check Last 1 to 4 Characters}
  mov     eax, [esi-3]     {Last 4 Characters of S - May include Length 
Bytes}
  mov     ebx, eax         {Convert All 4 Characters into Uppercase}
  or      eax, $80808080
  mov     ebp, eax
  sub     eax, $7B7B7B7B
  xor     ebp, ebx
  or      eax, $80808080
  sub     eax, $66666666
  and     eax, ebp
  shr     eax, 2
  xor     eax, ebx
  xor     eax, ecx         {Zero Byte at each Matching Position}
  lea     ebx, [eax-$01010101]
  not     eax
  and     eax, ebx
  and     eax, $80808080   {Set Byte to $80 at each Match Position else $00}
  jz      @@NotFound       {No Match Possible}
  sub     edx, 3           {Start Position for Next Loop}
  movzx   eax, [edx-1]
  mov     bl, al           {Convert Character into Uppercase}
  add     bl, $9f
  sub     bl, $1a
  jnb     @@UC2
  sub     al, $20
@@UC2:
  cmp     al, cl
  je      @@Compare        {Match}
  cmp     edx, esi
  ja      @@NotFound
  add     edx, 1
  movzx   eax, [edx-1]
  mov     bl, al           {Convert Character in AL into Uppercase}
  add     bl, $9f
  sub     bl, $1a
  jnb     @@UC3
  sub     al, $20
@@UC3:
  cmp     al, cl
  je      @@Compare        {Match}
  cmp     edx, esi
  ja      @@NotFound
  add     edx, 1
  movzx   eax, [edx-1]
  mov     bl, al           {Convert Character in AL into Uppercase}
  add     bl, $9f
  sub     bl, $1a
  jnb     @@UC4
  sub     al, $20
@@UC4:
  cmp     al, cl
  je      @@Compare        {Match}
  cmp     edx, esi
  ja      @@NotFound
  add     edx, 1
  jmp     @@Compare        {Match}
@@InvalidInput:
  xor     eax, eax         {Return 0}
  mov     ebx, [esp._ebx]
  add     esp, LocalsSize  {Release Local Storage}
end; {PosIEx}

function PosIEx_DKC_Pas_24(const SubStr, S: string; Offset: Integer = 1): Integer;
var
 I2, SubStrLength, StrLength : Integer;
 SubStrFirstCharUpper : Char;

begin
 Result := 0;
 if (Offset <= 0) then
  Exit;
 if S <> '' then
  StrLength := PInteger(Integer(S)-4)^
 else
  Exit;
 if SubStr <> '' then
  SubStrLength := PInteger(Integer(SubStr)-4)^
 else
  Exit;
 if (SubStrLength <= 0) then
  Exit;
 if (StrLength <= 0) then
  Exit;
 if (Integer(Offset) > StrLength) then
  Exit;
 if (StrLength - Integer(Offset) + 1 < SubStrLength) then //No room for match
  Exit;
 Result := Offset;
 SubStrFirstCharUpper := LookUpTable[Ord(SubStr[1])];
 repeat
  if SubStrFirstCharUpper = LookUpTable[Ord(S[Result])] then
   begin
    if Result + SubStrLength - 1 > StrLength then
     begin
      Result := 0;
      Exit;
     end;
    I2 := 1;
    repeat
     if (I2 >= SubStrLength) then
      Exit;
     if S[Result+I2] <> SubStr[I2+1] then
      if LookUpTable[Ord(S[Result+I2])] <> LookUpTable[Ord(SubStr[I2+1])] then
       Break;
     Inc(I2);
    until(False);
   end;
  Inc(Result);
 until(Result > StrLength);
 Result := 0;
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

initialization
  InitializeLookUpTable;
end.
