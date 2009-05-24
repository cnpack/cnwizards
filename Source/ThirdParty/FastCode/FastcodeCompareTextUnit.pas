unit FastcodeCompareTextUnit;

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
 * BV Version: 1.53
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeCompareTextFunction = function(const S1, S2: string): Integer;

{Functions shared between Targets}
function CompareText_Sha_IA32_3(const S1, S2: string): Integer;
function CompareText_JOH_IA32_5(const S1, S2: string): Integer;
function CompareText_JOH_IA32_6(const S1, S2: string): Integer;
function CompareText_Sha_IA32_4(const S1, S2: string): integer;
function CompareText_Sha_Pas_5(const S1, S2: string): integer;

{Functions not shared between Targets}

{Functions}

const
  FastcodeCompareTextP4R: FastcodeCompareTextFunction = CompareText_JOH_IA32_6;
  FastcodeCompareTextP4N: FastcodeCompareTextFunction = CompareText_JOH_IA32_6;
  FastcodeCompareTextPMY: FastcodeCompareTextFunction = CompareText_Sha_IA32_3;
  FastcodeCompareTextPMD: FastcodeCompareTextFunction = CompareText_Sha_IA32_3;
  FastcodeCompareTextAMD64: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastcodeCompareTextAMD64_SSE3: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastCodeCompareTextIA32SizePenalty: FastCodeCompareTextFunction = CompareText_Sha_IA32_4;
  FastcodeCompareTextIA32: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastcodeCompareTextMMX: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastCodeCompareTextSSESizePenalty: FastCodeCompareTextFunction = CompareText_Sha_IA32_4;
  FastcodeCompareTextSSE: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastcodeCompareTextSSE2: FastcodeCompareTextFunction = CompareText_JOH_IA32_5;
  FastCodeCompareTextPascalSizePenalty: FastCodeCompareTextFunction = CompareText_Sha_Pas_5;
  FastCodeCompareTextPascal: FastCodeCompareTextFunction = CompareText_Sha_Pas_5;

procedure CompareTextStub;

implementation

uses
  SysUtils;

function CompareText_JOH_IA32_6(const S1, S2: string): Integer;
asm
  cmp     eax, edx
  je      @@Same             {S1 = S2}
  test    eax, edx
  jnz     @@Compare
  test    eax, eax
  jz      @FirstNil          {S1 = NIL}
  test    edx, edx
  jnz     @@Compare          {S1 <> NIL and S2 <> NIL}
  mov     eax, [eax-4]       {S2 = NIL, Result = Length(S1)}
  ret
@@Same:
  xor     eax, eax
  ret
@FirstNil:
  sub     eax, [edx-4]       {S1 = NIL, Result = -Length(S2)}
  ret
@@Compare:
  push    ebx
  push    ebp
  push    edi
  push    esi
  mov     ebx, [eax-4]       {Length(S1)}
  sub     ebx, [edx-4]       {Default Result if All Compared Characters Match}
  push    ebx                {Save Default Result}
  sbb     ebp, ebp
  and     ebp, ebx
  sub     ebp, [eax-4]       {-Min(Length(S1),Length(S2))}
  sub     eax, ebp           {End of S1}
  sub     edx, ebp           {End of S2}
@@MainLoop:                  {Compare 4 Characters per Loop}
  mov     ebx, [eax+ebp]
  mov     ecx, [edx+ebp]
  cmp     ebx, ecx
  je      @@Next
  mov     esi, ebx           {Convert 4 Chars in EBX into Uppercase}
  or      ebx, $80808080
  mov     edi, ebx
  sub     ebx, $7B7B7B7B
  xor     edi, esi
  or      ebx, $80808080
  sub     ebx, $66666666
  and     ebx, edi
  shr     ebx, 2
  xor     ebx, esi
  mov     esi, ecx           {Convert 4 Chars in ECX into Uppercase}
  or      ecx, $80808080
  mov     edi, ecx
  sub     ecx, $7B7B7B7B
  xor     edi, esi
  or      ecx, $80808080
  sub     ecx, $66666666
  and     ecx, edi
  shr     ecx, 2
  xor     ecx, esi
  cmp     ebx, ecx
  jne     @@CheckDiff
@@Next:
  add     ebp, 4
  jl      @@MainLoop         {Loop until all required Characters Compared}
  pop     eax                {Default Result}
  jmp     @@Done
@@CheckDiff:
  pop     eax                {Default Result}
@@DiffLoop:
  cmp     bl, cl
  jne     @@SetResult
  add     ebp, 1
  jz      @@Done             {Difference after Compare Length}
  shr     ecx, 8
  shr     ebx, 8
  jmp     @@DiffLoop
@@SetResult:
  movzx   eax, bl            {Set Result from Character Difference}
  and     ecx, $ff
  sub     eax, ecx
@@Done:
  pop     esi
  pop     edi
  pop     ebp
  pop     ebx
end;

function CompareText_JOH_IA32_5(const S1, S2: string): Integer;
asm
  cmp     eax, edx
  je      @@Same             {S1 = S2}
  test    eax, edx
  jnz     @@Compare
  test    eax, eax
  jz      @FirstNil          {S1 = NIL}
  test    edx, edx
  jnz     @@Compare          {S1 <> NIL and S2 <> NIL}
  mov     eax, [eax-4]       {S2 = NIL, Result = Length(S1)}
  ret
@@Same:
  xor     eax, eax
  ret
@FirstNil:
  sub     eax, [edx-4]       {S1 = NIL, Result = -Length(S2)}
  ret
@@Compare:
  push    ebx
  push    ebp
  push    edi
  push    esi
  mov     ebx, [eax-4]       {Length(S1)}
  sub     ebx, [edx-4]       {Default Result if All Compared Characters Match}
  push    ebx                {Save Default Result}
  sbb     ebp, ebp
  and     ebp, ebx
  add     ebp, [edx-4]       {Compare Length = Min(Length(S1),Length(S2))}
  add     eax, ebp           {End of S1}
  add     edx, ebp           {End of S2}
  neg     ebp                {Negate Compare Length}
@@MainLoop:                  {Compare 4 Characters per Loop}
  mov     ebx, [eax+ebp]
  mov     ecx, [edx+ebp]
  cmp     ebx, ecx
  je      @@Next
  mov     esi, ebx           {Convert 4 Chars in EBX into Uppercase}
  or      ebx, $80808080
  mov     edi, ebx
  sub     ebx, $7B7B7B7B
  xor     edi, esi
  or      ebx, $80808080
  sub     ebx, $66666666
  and     ebx, edi
  shr     ebx, 2
  xor     ebx, esi
  mov     esi, ecx           {Convert 4 Chars in ECX into Uppercase}
  or      ecx, $80808080
  mov     edi, ecx
  sub     ecx, $7B7B7B7B
  xor     edi, esi
  or      ecx, $80808080
  sub     ecx, $66666666
  and     ecx, edi
  shr     ecx, 2
  xor     ecx, esi
  cmp     ebx, ecx
  jne     @@CheckDiff
@@Next:
  add     ebp, 4
  jl      @@MainLoop         {Loop until all required Characters Compared}
  pop     eax                {Default Result}
  jmp     @@Done
@@CheckDiff:
  pop     eax                {Default Result}
@@DiffLoop:
  cmp     cl, bl
  jne     @@SetResult
  add     ebp, 1
  jz      @@Done             {Difference after Compare Length}
  shr     ecx, 8
  shr     ebx, 8
  jmp     @@DiffLoop
@@SetResult:
  movzx   eax, bl            {Set Result from Character Difference}
  and     ecx, $ff
  sub     eax, ecx
@@Done:
  pop     esi
  pop     edi
  pop     ebp
  pop     ebx
end;

function CompareText_Sha_IA32_3(const S1, S2: string): Integer;
asm
         test  eax, eax
         jz    @nil1
         test  edx, edx
         jnz   @ptrok

@nil2:   mov   eax, [eax-4]
         ret
@nil1:   test  edx, edx
         jz    @nil0
         sub   eax, [edx-4]
@nil0:   ret

@ptrok:  push  edi
         push  ebx
         xor   edi, edi
         mov   ebx, [eax-4]
         mov   ecx, ebx
         sub   ebx, [edx-4]
         adc   edi, -1
         push  ebx
         and   ebx, edi
         mov   edi, eax
         sub   ebx, ecx
         jge   @len

@lenok:  sub   edi, ebx
         sub   edx, ebx

@loop:   mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]
         cmp   eax, ecx
         jne   @byte0
@same:   add   ebx, 4
         jl    @loop

@len:    pop   eax
         pop   ebx
         pop   edi
         ret

@loop2:  mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]
         cmp   eax, ecx
         je    @same

@byte0:  cmp   al, cl
         je    @byte1

         and   eax, $FF
         and   ecx, $FF
         sub   eax, 'a'
         sub   ecx, 'a'
         cmp   al, 'z'-'a'
         ja    @up0a
         sub   eax, 'a'-'A'
@up0a:   cmp   cl, 'z'-'a'
         ja    @up0c
         sub   ecx, 'a'-'A'
@up0c:   sub   eax, ecx
         jnz   @done

         mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]

@byte1:  cmp   ah, ch
         je    @byte2

         and   eax, $FF00
         and   ecx, $FF00
         sub   eax, 'a'*256
         sub   ecx, 'a'*256
         cmp   ah, 'z'-'a'
         ja    @up1a
         sub   eax, ('a'-'A')*256
@up1a:   cmp   ch, 'z'-'a'
         ja    @up1c
         sub   ecx, ('a'-'A')*256
@up1c:   sub   eax, ecx
         jnz   @done

         mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]

@byte2:  add   ebx, 2
         jnl   @len2
         shr   eax, 16
         shr   ecx, 16
         cmp   al, cl
         je    @byte3

         and   eax, $FF
         and   ecx, $FF
         sub   eax, 'a'
         sub   ecx, 'a'
         cmp   al, 'z'-'a'
         ja    @up2a
         sub   eax, 'a'-'A'
@up2a:   cmp   cl, 'z'-'a'
         ja    @up2c
         sub   ecx, 'a'-'A'
@up2c:   sub   eax, ecx
         jnz   @done

         movzx eax, word ptr [ebx+edi]
         movzx ecx, word ptr [ebx+edx]

@byte3:  cmp   ah, ch
         je    @byte4

         and   eax, $FF00
         and   ecx, $FF00
         sub   eax, 'a'*256
         sub   ecx, 'a'*256
         cmp   ah, 'z'-'a'
         ja    @up3a
         sub   eax, ('a'-'A')*256
@up3a:   cmp   ch, 'z'-'a'
         ja    @up3c
         sub   ecx, ('a'-'A')*256
@up3c:   sub   eax, ecx
         jnz   @done

@byte4:  add   ebx, 2
         jl    @loop2
@len2:   pop   eax
         pop   ebx
         pop   edi
         ret

@done:   pop   ecx
         pop   ebx
         pop   edi
end;

function CompareText_Sha_IA32_4(const S1, S2: string): integer;
asm
         test  eax, eax
         jz    @nil1
         test  edx, edx
         jnz   @ptrok

@nil2:   mov   eax, [eax-4]
         ret
@nil1:   test  edx, edx
         jz    @nil0
         sub   eax, [edx-4]
@nil0:   ret

@ptrok:  push  edi
         push  ebx
         xor   edi, edi
         mov   ebx, [eax-4]
         mov   ecx, ebx
         sub   ebx, [edx-4]
         adc   edi, -1
         push  ebx
         and   ebx, edi
         mov   edi, eax
         sub   ebx, ecx        //ebx := -min(Length(s1),Length(s2))
         jge   @len

@lenok:  sub   edi, ebx
         sub   edx, ebx

@loop:   mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]
         xor   eax, ecx
         jne   @differ
@same:   add   ebx, 4
         jl    @loop

@len:    pop   eax
         pop   ebx
         pop   edi
         ret

@loop2:  mov   eax, [ebx+edi]
         mov   ecx, [ebx+edx]
         xor   eax, ecx
         je    @same
@differ: test  eax, $DFDFDFDF  //$00 or $20
         jnz   @find
         add   eax, eax        //$00 or $40
         add   eax, eax        //$00 or $80
         test  eax, ecx
         jnz   @find
         and   ecx, $5F5F5F5F  //$41..$5A
         add   ecx, $3F3F3F3F  //$80..$99
         and   ecx, $7F7F7F7F  //$00..$19
         add   ecx, $66666666  //$66..$7F
         test  ecx, eax
         jnz   @find
         add   ebx, 4
         jl    @loop2

@len2:   pop   eax
         pop   ebx
         pop   edi
         ret

@loop3:  add   ebx, 1
         jge   @len2
@find:   movzx eax, [ebx+edi]
         movzx ecx, [ebx+edx]
         sub   eax, 'a'
         sub   ecx, 'a'
         cmp   al, 'z'-'a'
         ja    @upa
         sub   eax, 'a'-'A'
@upa:    cmp   cl, 'z'-'a'
         ja    @upc
         sub   ecx, 'a'-'A'
@upc:    sub   eax, ecx
         jz    @loop3

@found:  pop   ecx
         pop   ebx
         pop   edi
end;

function CompareText_Sha_Pas_5(const S1, S2: string): integer;
var
  c1, c2, d, q, save: integer;
  p: pIntegerArray;
label
  past, find;
begin;
  d:=integer(@pchar(pointer(s1))[-4]);
  c1:=0;
  c2:=0;
  p:=@pchar(pointer(s2))[-4];
  if d<>-4 then c1:=pinteger(d)^;          //c1 = length of s1
  if p<>pointer(-4) then c2:=pinteger(p)^; //c2 = length of s2
  d:=(d-integer(p)) shr 2;                 //d = distance(s1-s2) div 4
  q:=c1;
  c1:=c1-c2;
  if c1>0 then q:=c2;                      //q = min length
  save:=c1;                    //save result for equal data
  if q<=0 then begin;
    Result:=c1;
    exit;
    end;
  q:=q+integer(p);

  repeat;
    c1:=p[d+1];                            //dword from s1
    c2:=p[1];                              //dword from s2
    inc(integer(p),4);
    c1:=c1 xor c2;
    if c1<>0 then begin;                   //test the difference
      //all bits of each byte must be 0, except bit5 (weight $20)
      if (c1 and integer($DFDFDFDF))<>0 then goto find;

      //bit5 can be 1 for letters only
      c1:=c1 + c1;                         //$00 or $40
      c1:=c1 + c1;                         //$00 or $80
      if (c1 and c2)<>0 then goto find;    //if not letter
      c2:=c2 and $5F5F5F5F;                //$41..$5A
      c2:=c2   + $3F3F3F3F;                //$80..$99
      c2:=c2 and $7F7F7F7F;                //$00..$19
      c2:=c2   + $66666666;                //$66..$7F
      if (c1 and c2)<>0 then goto find;    //if not letter
      end;
    until cardinal(p)>=cardinal(q);
past:
  Result:=save;
  exit;

  repeat; //find mismatched characters
    if cardinal(p)>=cardinal(q+4) then goto past;
find:
    c1:=byte(p[d]);
    c2:=byte(p[0]);
    inc(integer(p));
    c1:=c1-ord('a');
    c2:=c2-ord('a');
    if cardinal(c1)<=ord('z')-ord('a') then c1:=c1-(ord('a')-ord('A'));
    if cardinal(c2)<=ord('z')-ord('a') then c2:=c2-(ord('a')-ord('A'));
    until c1<>c2;
  Result:=c1-c2;
end;

procedure CompareTextStub;
asm
  call SysUtils.CompareText;
end;

end.
