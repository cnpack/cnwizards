unit FastcodeCompareMemUnit;

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
 * Pierre le Riche
 * Dennis Kjaer Christensen
 * Aleksandr Sharahov
 *
 * BV Version: 2.01
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeCompareMemFunction = function(const p1, p2: pointer; const length: integer): boolean;

{Functions shared between Targets}
function CompareMem_JOH_IA32_1(const P1, P2: pointer; const Length: integer): boolean;
function CompareMem_PLR_IA32_1(const P1, P2: pointer; const Length: integer): boolean;
function CompareMem_PLR_IA32_2(const P1, P2: pointer; const Length: integer): boolean;
function CompareMem_Sha_Pas_4(const p1, p2: pointer; const length: integer): boolean;

{Functions not shared between Targets}
function CompareMem_DKC_SSE3_2(const P1, P2: Pointer; const Length: Integer): Boolean;
function CompareMem_DKC_SSE2_1(const P1, P2: Pointer; const Length: Integer): Boolean;
function CompareMem_DKC_SSE2_6(const P1, P2: Pointer; const Length: Integer): Boolean;

{Functions}

const
  FastcodeCompareMemP4R: FastcodeCompareMemFunction = CompareMem_DKC_SSE3_2;
  FastcodeCompareMemP4N: FastcodeCompareMemFunction = CompareMem_DKC_SSE2_1;
  FastcodeCompareMemPMY: FastcodeCompareMemFunction = CompareMem_JOH_IA32_1;
  FastcodeCompareMemPMD: FastcodeCompareMemFunction = CompareMem_JOH_IA32_1;
  FastcodeCompareMemAMD64: FastcodeCompareMemFunction = CompareMem_PLR_IA32_1;
  FastcodeCompareMemAMD64_SSE3: FastcodeCompareMemFunction = CompareMem_PLR_IA32_1;
  FastCodeCompareMemIA32SizePenalty: FastCodeCompareMemFunction = CompareMem_PLR_IA32_2;
  FastcodeCompareMemIA32: FastcodeCompareMemFunction = CompareMem_PLR_IA32_2;
  FastcodeCompareMemMMX: FastcodeCompareMemFunction = CompareMem_PLR_IA32_2;
  FastCodeCompareMemSSESizePenalty: FastCodeCompareMemFunction = CompareMem_PLR_IA32_2;
  FastcodeCompareMemSSE: FastcodeCompareMemFunction = CompareMem_PLR_IA32_2;
  FastcodeCompareMemSSE2: FastcodeCompareMemFunction = CompareMem_DKC_SSE2_6;
  FastCodeCompareMemPascalSizePenalty: FastCodeCompareMemFunction = CompareMem_Sha_Pas_4;
  FastCodeCompareMemPascal: FastCodeCompareMemFunction = CompareMem_Sha_Pas_4;

procedure CompareMemStub;

implementation

uses
  SysUtils;

function CompareMem_DKC_SSE3_2(const P1, P2: Pointer; const Length: Integer): Boolean;
asm
   push     esi
   push     edi
   test     ecx,ecx
   jle      @ResultTrueExit1
   cmp      ecx,4
   jnl      @MediumCompares
   mov      esi,edx
   lea      edi,[ecx+eax]
 @Loop1Start :
   movzx    edx,[eax]
   cmp      dl,[esi]
   jnz      @ResultFalseExit1
   add      eax,1
   cmp      edi,eax
   jbe      @Loop1End
   add      esi,1
   movzx    edx,[eax]
   cmp      dl,[esi]
   jnz      @ResultFalseExit1
   add      eax,1
   add      esi,1
   cmp      edi,eax
   jnbe     @Loop1Start
 @Loop1End :
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   ret
 @MediumCompares :
   cmp      ecx,256
   jnl      @BigCompares
   sub      ecx,4
   xor      esi,esi
 @MediumCompareLoop :
   mov      edi,[eax+esi]
   cmp      edi,[edx+esi]
   jnz      @ResultFalseExit1
   add      esi,4
   cmp      esi,ecx
   jb       @MediumCompareLoop
   mov      edi,[eax+ecx]
   cmp      edi,[edx+ecx]
   jnz      @ResultFalseExit1
 @ResultTrueExit1 :
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   ret
 @BigCompares :
   push     ebx
   mov      edi,eax
   mov      esi,edx
   lea      eax,[ecx+eax]
   mov      edx,edi
   and      edx,15
   mov      eax,16
   sub      eax,edx
   mov      ebx,edi
   mov      edx,[edi]
   cmp      edx,[esi]
   jnz      @ResultFalseExit
   mov      edx,[edi+4]
   cmp      edx,[esi+4]
   jnz      @ResultFalseExit
   mov      edx,[edi+8]
   cmp      edx,[esi+8]
   jnz      @ResultFalseExit
   mov      edx,[edi+12]
   cmp      edx,[esi+12]
   jnz      @ResultFalseExit
   add      edi,eax
   add      esi,eax
   add      ecx,ebx
   sub      ecx,16
 @Loop3Start :
   //lddqu    xmm0,[esi]
   db $F2 db $0F db $F0 db $06
   pcmpeqb  xmm0,[edi]
   pmovmskb ebx,xmm0
   cmp      ebx,$0000FFFF
   jnz      @ResultFalseExit
   add      edi,16
   add      esi,16
   cmp      edi,ecx
   jle      @Loop3Start
   add      ecx,16
   cmp      edi,ecx
   jnl      @ResultTrueExit
 @Loop4Start :
   movzx    edx,[edi]
   cmp      dl,[esi]
   jnz      @ResultFalseExit
   add      edi,1
   add      esi,1
   cmp      ecx,edi
   jnbe     @Loop4Start
 @ResultTrueExit :
   xor      eax,eax
   add      eax,1
   pop      ebx
   pop      edi
   pop      esi
   ret
 @ResultFalseExit :
   xor      eax,eax
   pop      ebx
   pop      edi
   pop      esi
   ret
 @ResultFalseExit1 :
   xor      eax,eax
   pop      edi
   pop      esi
   ret
end;

function CompareMem_DKC_SSE2_1(const P1, P2: Pointer; const Length: Integer): Boolean;
asm
   push     ebx
   push     esi
   push     edi
   test     ecx,ecx
   jle      @ResultTrueExit
   mov      edi,eax
   mov      esi,edx
   lea      eax,[ecx+edi]
   cmp      ecx,32
   jnl      @IfEnd2
 @Loop1Start :
   movzx    edx,[edi]
   cmp      dl,[esi]
   jnz      @ResultFalseExit
   add      edi,1
   add      esi,1
   cmp      eax,edi
   jnbe     @Loop1Start
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   pop      ebx
   ret
 @IfEnd2 :
   mov      edx,edi
   and      edx,15
   mov      eax,16
   sub      eax,edx
   mov      ebx,edi
   mov      edx,[edi]
   cmp      edx,[esi]
   jnz      @ResultFalseExit
   mov      edx,[edi+4]
   cmp      edx,[esi+4]
   jnz      @ResultFalseExit
   mov      edx,[edi+8]
   cmp      edx,[esi+8]
   jnz      @ResultFalseExit
   mov      edx,[edi+12]
   cmp      edx,[esi+12]
   jnz      @ResultFalseExit
   add      edi,eax
   add      esi,eax
   add      ecx,ebx
   sub      ecx,16
 @Loop3Start :
   movdqu   xmm0,[esi]
   pcmpeqb  xmm0,[edi]
   pmovmskb ebx,xmm0
   cmp      bx,$FFFF
   jnz      @ResultFalseExit
   add      edi,16
   add      esi,16
   cmp      edi,ecx
   jle      @Loop3Start
   add      ecx,16
   cmp      edi,ecx
   jnl      @ResultTrueExit
 @Loop4Start :
   movzx    edx,[edi]
   cmp      dl,[esi]
   jnz      @ResultFalseExit
   add      edi,1
   add      esi,1
   cmp      ecx,edi
   jnbe     @Loop4Start
 @ResultTrueExit :
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   pop      ebx
   ret
 @ResultFalseExit :
   xor      eax,eax
   pop      edi
   pop      esi
   pop      ebx
   ret
end;

function CompareMem_DKC_SSE2_6(const P1, P2: Pointer; const Length: Integer): Boolean;
asm
   push     esi
   push     edi
   test     ecx,ecx
   jle      @ResultTrueExit1
   cmp      ecx,32
   jnl      @IfEnd2
   mov      esi,edx
   lea      edi,[ecx+eax]
 @Loop1Start :
   movzx    edx,[eax]
   cmp      dl,[esi]
   jnz      @ResultFalseExit1
   add      eax,1
   cmp      edi,eax
   jbe      @Loop1End
   add      esi,1
   movzx    edx,[eax]
   cmp      dl,[esi]
   jnz      @ResultFalseExit1
   add      eax,1
   add      esi,1
   cmp      edi,eax
   jnbe     @Loop1Start
 @Loop1End :
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   ret
 @IfEnd2 :
   push     ebx
   mov      edi,eax
   mov      esi,edx
   lea      eax,[ecx+eax]
   mov      edx,edi
   and      edx,15
   mov      eax,16
   sub      eax,edx
   mov      ebx,edi
   mov      edx,[edi]
   cmp      edx,[esi]
   jnz      @ResultFalseExit
   mov      edx,[edi+4]
   cmp      edx,[esi+4]
   jnz      @ResultFalseExit
   mov      edx,[edi+8]
   cmp      edx,[esi+8]
   jnz      @ResultFalseExit
   mov      edx,[edi+12]
   cmp      edx,[esi+12]
   jnz      @ResultFalseExit
   add      edi,eax
   add      esi,eax
   add      ecx,ebx
   sub      ecx,16
 @Loop3Start :
   movdqu   xmm0,[esi]
   pcmpeqb  xmm0,[edi]
   pmovmskb ebx,xmm0
   cmp      ebx,$0000FFFF
   jnz      @ResultFalseExit
   add      edi,16
   add      esi,16
   cmp      edi,ecx
   jle      @Loop3Start
   add      ecx,16
   cmp      edi,ecx
   jnl      @ResultTrueExit
 @Loop4Start :
   movzx    edx,[edi]
   cmp      dl,[esi]
   jnz      @ResultFalseExit
   add      edi,1
   add      esi,1
   cmp      ecx,edi
   jnbe     @Loop4Start
 @ResultTrueExit :
   xor      eax,eax
   add      eax,1
   pop      ebx
   pop      edi
   pop      esi
   ret
 @ResultFalseExit :
   xor      eax,eax
   pop      ebx
   pop      edi
   pop      esi
   ret
 @ResultTrueExit1 :
   xor      eax,eax
   add      eax,1
   pop      edi
   pop      esi
   ret
 @ResultFalseExit1 :
   xor      eax,eax
   pop      edi
   pop      esi
   ret
end;

// ** //

function CompareMem_JOH_IA32_1(const P1, P2: pointer; const Length: integer): boolean;
asm
  push  ebx
  sub   ecx, 8
  jl    @@Small
  mov   ebx, [eax]         {Compare First 4 Bytes}
  cmp   ebx, [edx]
  jne   @@False
  lea   ebx, [eax+ecx]     {Compare Last 8 Bytes}
  add   edx, ecx
  mov   eax, [ebx]
  cmp   eax, [edx]
  jne   @@False
  mov   eax, [ebx+4]
  cmp   eax, [edx+4]
  jne   @@False
  sub   ecx, 4
  jle   @@True             {All Bytes already Compared}
  neg   ecx                {-(Length-12)}
  add   ecx, ebx           {DWORD Align Reads}
  and   ecx, -4
  sub   ecx, ebx
@@LargeLoop:               {Compare 8 Bytes per Loop}
  mov   eax, [ebx+ecx]
  cmp   eax, [edx+ecx]
  jne   @@False
  mov   eax, [ebx+ecx+4]
  cmp   eax, [edx+ecx+4]
  jne   @@False
  add   ecx, 8
  jl    @@LargeLoop
@@True:
  mov   eax, 1
  pop   ebx
  ret
@@Small:
  add   ecx, 8
  jle   @@True             {Length <= 0}
@@SmallLoop:
  mov   bl, [eax]
  cmp   bl, [edx]
  jne   @@False
  inc   eax
  inc   edx
  dec   ecx
  jnz   @@SmallLoop
  jmp   @@True
@@False:
  xor   eax, eax
  pop   ebx
end;

// ** //

function CompareMem_PLR_IA32_1(const P1, P2: pointer; const Length: integer): boolean;
asm
  {Subtract 8 from the count}
  sub ecx, 8
  jl @SmallCompare
  {Save registers}
  push ebx
  push esi
  {Compare the first 4 and last 8 bytes}
  mov ebx, [eax]
  xor ebx, [edx]
  {Point to the last 8 bytes}
  add eax, ecx
  add edx, ecx
  {Compare the last 8}
  mov esi, [eax]
  xor esi, [edx]
  or ebx, esi
  mov esi, [eax + 4]
  xor esi, [edx + 4]
  or ebx, esi
  jnz @Mismatch
  {Less than 12 to compare?}
  sub ecx, 4
  jle @Match
  {DWord align reads from P1 (P2 reads are not aligned)}
  neg ecx
  add ecx, eax
  and ecx, -4
  sub ecx, eax
  {Read chunks of 8 bytes at a time}
@CompareLoop:
  mov ebx, [eax + ecx]
  mov esi, [eax + ecx + 4]
  xor ebx, [edx + ecx]
  xor esi, [edx + ecx + 4]
  or ebx, esi
  jnz @Mismatch
  add ecx, 8
  jl @CompareLoop
@Match:
  pop esi
  pop ebx
@MatchSmall:
  mov al, True
  ret
@SmallCompare:
  add ecx, 8
  jle @MatchSmall
@SmallLoop:
  mov ch, [eax]
  xor ch, [edx]
  jnz @MismatchSmall
  add eax, 1
  add edx, 1
  sub cl, 1
  jnz @SmallLoop
  jmp @MatchSmall
@Mismatch:
  pop esi
  pop ebx
@MismatchSmall:
  xor eax, eax
end;

function CompareMem_PLR_IA32_2(const P1, P2: pointer; const Length: integer): boolean;
asm
  {Less than a qword to compare?}
  sub ecx, 8
  jl @VerySmallCompare
  {save ebx}
  push ebx
  {Compare first dword}
  mov ebx, [eax]
  cmp ebx, [edx]
  je @FirstFourMatches
@InitialMismatch:
  xor eax, eax
  pop ebx
  ret
@FirstFourMatches:
  {Point eax and edx to the last 8 bytes}
  add eax, ecx
  add edx, ecx
  {Compare the second last dword}
  mov ebx, [eax]
  cmp ebx, [edx]
  jne @InitialMismatch
  {Compare the last dword}
  mov ebx, [eax + 4]
  cmp ebx, [edx + 4]
  jne @InitialMismatch
  {12 or less bytes to compare?}
  sub ecx, 4
  jle @InitialMatch
  {Save esi}
  push esi
  {DWord align reads from P1 (P2 reads are not aligned)}
  neg ecx
  add ecx, eax
  and ecx, -4
  sub ecx, eax
  {Compare chunks of 8 bytes at a time}
@CompareLoop:
  mov ebx, [eax + ecx]
  mov esi, [eax + ecx + 4]
  xor ebx, [edx + ecx]
  xor esi, [edx + ecx + 4]
  or ebx, esi
  jnz @LargeMismatch
  add ecx, 8
  jl @CompareLoop
  pop esi
@InitialMatch:
  pop ebx
@MatchSmall:
  mov al, True
  ret
@VerySmallCompare:
  add ecx, 8
  jle @MatchSmall
@SmallLoop:
  mov ch, [eax]
  xor ch, [edx]
  jnz @MismatchSmall
  add eax, 1
  add edx, 1
  sub cl, 1
  jnz @SmallLoop
  jmp @MatchSmall
@LargeMismatch:
  pop esi
  pop ebx
@MismatchSmall:
  xor eax, eax
end;

function CompareMem_Sha_Pas_4(const p1, p2: pointer; const length: integer): boolean;
var
  q1, q2: pIntegerArray;
  c: cardinal;
label
  Ret0;
begin;
  c:=length;
  c:=c+cardinal(p1)-8;
  q1:=p1;
  q2:=p2;
  if c>=cardinal(q1) then begin;
    if q1[0]<>q2[0] then goto Ret0;
    inc(cardinal(q1),4);
    inc(cardinal(q2),4);
    dec(cardinal(q2),cardinal(q1));
    cardinal(q1):=cardinal(q1) and -4;
    inc(cardinal(q2),cardinal(q1));
    //if c>=cardinal(q1) then repeat;
    //replaced: compiler creates a copy of cardinal(q1) for statement above
    if pchar(c)>=q1 then repeat;
      if q1[0]<>q2[0] then goto Ret0;
      if q1[1]<>q2[1] then goto Ret0;
      inc(cardinal(q1),8);
      inc(cardinal(q2),8);
      if c<cardinal(q1) then break;
      if q1[0]<>q2[0] then goto Ret0;
      if q1[1]<>q2[1] then goto Ret0;
      inc(cardinal(q1),8);
      inc(cardinal(q2),8);
      until c<cardinal(q1);
    end;
  c:=c-cardinal(q1)+8;
  if integer(c)>=4 then begin;
    if q1[0]<>q2[0] then goto Ret0;
    inc(cardinal(q1),4);
    inc(cardinal(q2),4);
    c:=c-4;
    end;
  if integer(c)>=2 then begin;
    if pword(q1)^<>pword(q2)^ then goto Ret0;
    inc(cardinal(q1),2);
    inc(cardinal(q2),2);
    c:=c-2;
    end;
  if integer(c)>=1 then if pchar(q1)^<>pchar(q2)^ then goto Ret0;
  Result:=true;
  exit;
Ret0:
  Result:=false;
end;

procedure CompareMemStub;
asm
  call SysUtils.CompareMem;
end;

end.
