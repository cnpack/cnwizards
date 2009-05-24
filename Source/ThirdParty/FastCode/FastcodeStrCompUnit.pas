unit FastcodeStrCompUnit;

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
 * BV Version: 2.70
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeStrCompFunction = function(const Str1, Str2: PChar): Integer;

{Functions shared between Targets}
function StrComp_Sha_IA32_7(const Str1, Str2: PChar): Integer;
function StrComp_JOH_IA32_6(const Str1, Str2: PChar): Integer;
function StrComp_JOH_IA32_5(const Str1, Str2: PChar): Integer;

{Functions not shared between Targets}
function StrComp_Sha_Pas_4(const str1, str2: pchar): integer;
function StrComp_Sha_Pas_5(const str1, str2: pchar): integer;

{Functions}

const
  FastcodeStrCompP4R: FastcodeStrCompFunction = StrComp_JOH_IA32_6;
  FastcodeStrCompP4N: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastcodeStrCompPMY: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastcodeStrCompPMD: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastCodeStrCompIA32SizePenalty: FastCodeStrCompFunction = StrComp_JOH_IA32_5;
  FastcodeStrCompIA32: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastcodeStrCompMMX: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastCodeStrCompSSESizePenalty: FastCodeStrCompFunction = StrComp_JOH_IA32_5;
  FastcodeStrCompSSE: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastcodeStrCompSSE2: FastcodeStrCompFunction = StrComp_Sha_IA32_7;
  FastcodeStrCompAMD64: FastcodeStrCompFunction = StrComp_JOH_IA32_6;
  FastcodeStrCompAMD64_SSE3: FastcodeStrCompFunction = StrComp_JOH_IA32_6;
  FastCodeStrCompPascalSizePenalty: FastCodeStrCompFunction = StrComp_Sha_Pas_4;
  FastCodeStrCompPascal: FastCodeStrCompFunction = StrComp_Sha_Pas_5;

procedure StrCompStub;

implementation

uses
  SysUtils;

function StrComp_JOH_IA32_6(const Str1, Str2: PChar): Integer;
asm
  sub   eax, edx
  mov   ecx, eax
  jz    @@Exit
@@Loop:
  movzx eax, [ecx+edx]
  cmp   al, [edx]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+1]
  cmp   al, [edx+1]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+2]
  cmp   al, [edx+2]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+3]
  cmp   al, [edx+3]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+4]
  cmp   al, [edx+4]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+5]
  cmp   al, [edx+5]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+6]
  cmp   al, [edx+6]
  jne   @@SetResult
  test  al, al
  jz    @@Exit
  movzx eax, [ecx+edx+7]
  cmp   al, [edx+7]
  jne   @@SetResult
  add   edx, 8
  test  al, al
  jnz   @@Loop
  ret
@@SetResult:
  sbb   eax, eax
  or    al, 1
@@Exit:
end;

function StrComp_Sha_IA32_7(const Str1, Str2: PChar): Integer;
asm
   sub   eax, edx
   jz    @ret
@loop:
   movzx ecx, [eax+edx]
   cmp   cl, [edx]
   jne   @stop
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+1]
   cmp   cl, [edx+1]
   jne   @stop1
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+2]
   cmp   cl, [edx+2]
   jne   @stop2
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+3]
   cmp   cl, [edx+3]
   jne   @stop3
   add   edx, 4
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx]
   cmp   cl, [edx]
   jne   @stop
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+1]
   cmp   cl, [edx+1]
   jne   @stop1
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+2]
   cmp   cl, [edx+2]
   jne   @stop2
   test  cl, cl
   jz    @eq
   movzx ecx, [eax+edx+3]
   cmp   cl, [edx+3]
   jne   @stop3
   add   edx, 4
   test  cl, cl
   jnz   @loop
@eq:
   xor   eax, eax
@ret:
   ret
@stop3:
   add   edx, 1
@stop2:
   add   edx, 1
@stop1:
   add   edx, 1
@stop:
   mov   eax, ecx
   movzx edx, [edx]
   sub   eax, edx
end;

function StrComp_JOH_IA32_5(const Str1, Str2: PChar): Integer;
asm
  sub   eax, edx
  jz    @@Exit
@@Loop:
  movzx ecx, [eax+edx]
  cmp   cl, [edx]
  jne   @@SetResult
  inc   edx
  test  cl, cl
  jnz   @@Loop
  xor   eax, eax
  ret
@@SetResult:
  sbb   eax, eax
  or    al, 1
@@Exit:
end;

function StrComp_Sha_Pas_4(const str1, str2: pchar): integer;
var
  dist: integer;
  p: pchar;
label
  make;
begin;
   dist:=str1-str2;
   p:=str2;
   repeat;
     Result:=shortint(p[dist]);
     if (Result=0) or (chr(Result)<>p[0]) then goto make;
     Result:=shortint(p[dist+1]);
     inc(p,2);
     until (Result=0) or (chr(Result)<>p[-1]);
   dec(p);
make:
   Result:=byte(Result)-byte(p[0]);
end;

function StrComp_Sha_Pas_5(const str1, str2: pchar): integer;
var
  dist: integer;
  p: pchar;
label
  make, make1, make2;
begin;
   dist:=str1-str2;
   p:=str2;
   repeat;
     Result:=shortint(p[dist]);
     if (Result=0) or (chr(Result)<>p[0]) then goto make;
     Result:=shortint(p[dist+1]);
     if (Result=0) or (chr(Result)<>p[1]) then goto make1;
     Result:=shortint(p[dist+2]);
     if (Result=0) or (chr(Result)<>p[2]) then goto make2;
     Result:=shortint(p[dist+3]);
     inc(p,4);
     until (Result=0) or (chr(Result)<>p[-1]);
   dec(p,3);
make2:
   inc(p);
make1:
   inc(p);
make:
   Result:=byte(Result)-byte(p[0]);
end;

procedure StrCompStub;
asm
  call SysUtils.StrComp;
end;

end.
