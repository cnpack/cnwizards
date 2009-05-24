unit FastcodeStrCopyUnit;

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
 * BV Version: 3.80
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeStrCopyFunction = function(Dest: PChar; const Source: PChar): PChar;

{Functions shared between Targets}
function StrCopy_JOH_MMX_1(Dest: PChar; const Source: PChar): PChar;
function StrCopy_Sha_IA32_4(Dest: PChar; const Source: PChar): PChar;
function StrCopy_Sha_IA32_3(Dest: PChar; const Source: PChar): PChar;
function StrCopy_Sha_Pas_1(Dest: PChar; const Source: PChar): PChar;

{Functions not shared between Targets}
function StrCopy_JOH_PAS_4(Dest: PChar; const Source: PChar): PChar; {$IFDEF INLINE} inline; {$ENDIF}

{Functions}

const
  FastcodeStrCopyP4R: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastcodeStrCopyP4N: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastcodeStrCopyPMY: FastcodeStrCopyFunction = StrCopy_JOH_MMX_1;
  FastcodeStrCopyPMD: FastcodeStrCopyFunction = StrCopy_JOH_MMX_1;
  FastcodeStrCopyAMD64: FastcodeStrCopyFunction = StrCopy_Sha_Pas_1;
  FastcodeStrCopyAMD64_SSE3: FastcodeStrCopyFunction = StrCopy_JOH_MMX_1;
  FastCodeStrCopyIA32SizePenalty: FastCodeStrCopyFunction = StrCopy_Sha_IA32_4;
  FastcodeStrCopyIA32: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastcodeStrCopyMMX: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastCodeStrCopySSESizePenalty: FastCodeStrCopyFunction = StrCopy_Sha_IA32_4;
  FastcodeStrCopySSE: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastcodeStrCopySSE2: FastcodeStrCopyFunction = StrCopy_Sha_IA32_3;
  FastCodeStrCopyPascalSizePenalty: FastCodeStrCopyFunction = StrCopy_JOH_PAS_4;
  FastCodeStrCopyPascal: FastCodeStrCopyFunction = StrCopy_Sha_Pas_1;

procedure StrCopyStub;

implementation

uses
  SysUtils;

function StrCopy_JOH_MMX_1(Dest: PChar; const Source: PChar): PChar;
asm {Size = 270 Bytes}
  push     eax
  mov      ecx, edx
  sub      ecx, eax
  cmp      ecx, 8
  jb       @@Overlap            {Source/Dest Overlap}
  movzx    ecx, [edx]
  mov      [eax], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+1]
  mov      [eax+1], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+2]
  mov      [eax+2], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+3]
  mov      [eax+3], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+4]
  mov      [eax+4], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+5]
  mov      [eax+5], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+6]
  mov      [eax+6], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+7]
  mov      [eax+7], cl
  test      cl, cl
  jz       @@Done
  mov      ecx, edx             {QWORD Align Reads}
  and      edx, -8
  sub      ecx, edx
  sub      eax, ecx
@@Loop:
  add      edx, 8               {8 Chars per Loop}
  add      eax, 8
  pxor     mm0, mm0
  movq     mm1, [edx]
  pcmpeqb  mm0, mm1
  packsswb mm0, mm0
  movd     ecx, mm0
  test     ecx, ecx
  jnz      @@Remainder
  movq     [eax], mm1
  jmp      @@Loop               {Loop until any #0 Found}
@@Remainder:
  emms
  movzx    ecx, [edx]
  mov      [eax], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+1]
  mov      [eax+1], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+2]
  mov      [eax+2], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+3]
  mov      [eax+3], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+4]
  mov      [eax+4], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+5]
  mov      [eax+5], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+6]
  mov      [eax+6], cl
  test     cl, cl
  jz       @@Done
  movzx    ecx, [edx+7]
  mov      [eax+7], cl
@@Done:
  pop      eax
  ret
@@Overlap:
  movzx    ecx, [edx]
  mov      [eax], cl
  add      eax, 1
  add      edx, 1
  test     cl, cl
  jnz      @@Overlap
  pop      eax
end;

function StrCopy_Sha_IA32_3(Dest: PChar; const Source: PChar): PChar;
asm
  sub edx,eax;
  test eax, 1;
  push eax;
  jz @loop;
  movzx ecx,byte ptr[eax+edx+00]; test cl, cl; mov [eax+00],cl; jz @ret;
  add eax, 1;
@loop:
  movzx ecx,byte ptr[eax+edx+00]; test cl, cl; jz @ret00;
  movzx ecx,word ptr[eax+edx+00]; cmp ecx,255; mov [eax+00],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+02]; test cl, cl; jz @ret02;
  movzx ecx,word ptr[eax+edx+02]; cmp ecx,255; mov [eax+02],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+04]; test cl, cl; jz @ret04;
  movzx ecx,word ptr[eax+edx+04]; cmp ecx,255; mov [eax+04],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+06]; test cl, cl; jz @ret06;
  movzx ecx,word ptr[eax+edx+06]; cmp ecx,255; mov [eax+06],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+08]; test cl, cl; jz @ret08;
  movzx ecx,word ptr[eax+edx+08]; cmp ecx,255; mov [eax+08],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+10]; test cl, cl; jz @ret10;
  movzx ecx,word ptr[eax+edx+10]; cmp ecx,255; mov [eax+10],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+12]; test cl, cl; jz @ret12;
  movzx ecx,word ptr[eax+edx+12]; cmp ecx,255; mov [eax+12],cx; jbe @ret;
  movzx ecx,byte ptr[eax+edx+14]; test cl, cl; jz @ret14;
  movzx ecx,word ptr[eax+edx+14]; mov [eax+14],cx;
  add eax,16;
  cmp ecx,255; ja @loop;
@ret:
  pop eax; ret;
@ret00:
  mov [eax+00],cl; pop eax; ret;
@ret02:
  mov [eax+02],cl; pop eax; ret;
@ret04:
  mov [eax+04],cl; pop eax; ret;
@ret06:
  mov [eax+06],cl; pop eax; ret;
@ret08:
  mov [eax+08],cl; pop eax; ret;
@ret10:
  mov [eax+10],cl; pop eax; ret;
@ret12:
  mov [eax+12],cl; pop eax; ret;
@ret14:
  mov [eax+14],cl; pop eax; //ret;
end;

function StrCopy_Sha_IA32_4(Dest: PChar; const Source: PChar): PChar;
asm
  sub   edx, eax
  test  eax, 1
  push  eax
  jz    @loop
  movzx ecx, byte ptr[eax+edx]
  mov   [eax], cl
  test  ecx, ecx
  jz    @ret
  inc   eax
@loop:
  movzx ecx, byte ptr[eax+edx]
  test  ecx, ecx
  jz    @move0
  movzx ecx, word ptr[eax+edx]
  mov   [eax], cx
  add   eax, 2
  cmp   ecx, 255
  ja    @loop
@ret:
  pop   eax
  ret
@move0:
  mov   [eax], cl
  pop   eax
end;

function StrCopy_JOH_PAS_4(Dest: PChar; const Source: PChar): PChar; {$IFDEF INLINE} inline; {$ENDIF}
var
  Src, Dst: PByte;
  I, J, K: Integer;
begin
  Result := Dest;
  Src := Pointer(Source);
  Dst := Pointer(Dest);
  if LongWord(Integer(Src) - Integer(Dst)) >= 4 then
    begin
      repeat
        Dst^ := Src^;
        if Dst^ = 0 then Exit;
        Inc(Dst);
        Inc(Src);
      until (Integer(Src) and 3) = 0;
      repeat
        I := PInteger(Src)^;
        K := I;
        J := I - $01010101;
        I := not(I);
        I := I and J;
        if (I and $80808080) <> 0 then
          Break;
        PInteger(Dst)^ := K;
        Inc(Dst, 4);
        Inc(Src, 4);
      until False;
   end;
  repeat
    Dst^ := Src^;
    if Dst^ = 0 then Exit;
    Inc(Dst);
    Inc(Src);
  until False;
end;

function StrCopy_Sha_Pas_1(Dest: PChar; const Source: PChar): PChar;
var
  d: integer;
  ch: char;
begin
  d:=integer(Source);
  Result:=Dest;
  dec(d,integer(Dest));
  repeat
    ch:=Dest[d+00]; Dest[00]:=ch; if ch=#0 then break;
    ch:=Dest[d+01]; Dest[01]:=ch; if ch=#0 then break;
    ch:=Dest[d+02]; Dest[02]:=ch; if ch=#0 then break;
    ch:=Dest[d+03]; Dest[03]:=ch; if ch=#0 then break;
    ch:=Dest[d+04]; Dest[04]:=ch; if ch=#0 then break;
    ch:=Dest[d+05]; Dest[05]:=ch; if ch=#0 then break;
    ch:=Dest[d+06]; Dest[06]:=ch; if ch=#0 then break;
    ch:=Dest[d+07]; Dest[07]:=ch; if ch=#0 then break;
    ch:=Dest[d+08]; Dest[08]:=ch; if ch=#0 then break;
    ch:=Dest[d+09]; Dest[09]:=ch; if ch=#0 then break;
    ch:=Dest[d+10]; Dest[10]:=ch; if ch=#0 then break;
    ch:=Dest[d+11]; Dest[11]:=ch; if ch=#0 then break;
    ch:=Dest[d+12]; Dest[12]:=ch; if ch=#0 then break;
    ch:=Dest[d+13]; Dest[13]:=ch; if ch=#0 then break;
    ch:=Dest[d+14]; Dest[14]:=ch; if ch=#0 then break;
    ch:=Dest[d+15]; Dest[15]:=ch; if ch=#0 then break;
    ch:=Dest[d+16]; Dest[16]:=ch; if ch=#0 then break;
    ch:=Dest[d+17]; Dest[17]:=ch; if ch=#0 then break;
    ch:=Dest[d+18]; Dest[18]:=ch; if ch=#0 then break;
    ch:=Dest[d+19]; Dest[19]:=ch; if ch=#0 then break;
    ch:=Dest[d+20]; Dest[20]:=ch; if ch=#0 then break;
    ch:=Dest[d+21]; Dest[21]:=ch; if ch=#0 then break;
    ch:=Dest[d+22]; Dest[22]:=ch; if ch=#0 then break;
    ch:=Dest[d+23]; Dest[23]:=ch; if ch=#0 then break;
    ch:=Dest[d+24]; Dest[24]:=ch; if ch=#0 then break;
    ch:=Dest[d+25]; Dest[25]:=ch; if ch=#0 then break;
    ch:=Dest[d+26]; Dest[26]:=ch; if ch=#0 then break;
    ch:=Dest[d+27]; Dest[27]:=ch; if ch=#0 then break;
    ch:=Dest[d+28]; Dest[28]:=ch; if ch=#0 then break;
    ch:=Dest[d+29]; Dest[29]:=ch; if ch=#0 then break;
    ch:=Dest[d+30]; Dest[30]:=ch; if ch=#0 then break;
    ch:=Dest[d+31]; Dest[31]:=ch;
    inc(Dest,32);
  until ch=#0;
end;

procedure StrCopyStub;
asm
  call SysUtils.StrCopy;
end;

end.
