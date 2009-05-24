unit FastMove;

(*
Copyright (c) 2006, John O'Harrow (john@elmcrest.demon.co.uk)

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the
use of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
   that you wrote the original software. If you use this software in a product,
   an acknowledgment in the product documentation would be appreciated but is
   not required.

2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.

-------------------------------------------------------------------------------

Version: 3.03 : 06-MAR-2006

How to use:

  Include this unit in any uses clause - Thats It!

What is Does:

  This unit replaces all calls to system.move with calls to a faster move
  procedure (Up to 3 times faster).  The code will automatically detect and
  use MMX, SSE, SSE2 or SSE3 where available.

Version  Change
-------  ------
2.00     Updated all Moves to use Move_JOH_XXX_6 (better code alignment).
2.10     VirtualProtect modified to use PAGE_EXECUTE_READWRITE to prevent
         error under WinXP SP2 with AMD64 running DEP.
2.20     Added Check for "Already Patched" to prevent error when using.
         Packages in both DLL's and EXE.
2.30     PrefetchLimit initialization moved outside of ReplaceMove.
3.00     Updated all Moves to use latest Move_JOH_XXX_10 procedures and added
         SSE2 and SSE3 optimized moves.
         Extra VirtualProtect removed.  PatchSystemMove Directive added.
         Local Move Procedure added for direct calling of fastest Move.
3.01     {$D-} Added to prevent stepping into the Move BASM Code
         Badly Names PrefetchLimit renamed CacheLimit
3.02     Incorrect DB equivalents of lddqu instruction corrected
3.03     Compiler Directives for D2006 Added
         Contact Email address corrected
*)

{.$D-} {Prevent Steppping into Move Code}

{.$DEFINE PatchSystemMove} {Enable Patching of System.Move}

{$IFDEF VER170}
  {$DEFINE SSE2Basm}
  {$WARN UNSAFE_CODE OFF}
{$ENDIF}

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 18.0}
    {$DEFINE SSE2Basm}
    {$WARN UNSAFE_CODE OFF}
  {$IFEND}
{$ENDIF}

interface

var
  Move : procedure(const Source; var Dest; Count : Integer); {Fastest Move}

{Procedures interfaced only for testing and validation purposes}
  procedure MoveJOH_PAS_10 (const Source; var Dest; Count : Integer);
  procedure MoveJOH_IA32_10(const Source; var Dest; Count : Integer);
  procedure MoveJOH_MMX_10 (const Source; var Dest; Count : Integer);
  procedure MoveJOH_SSE_10 (const Source; var Dest; Count : Integer);
  procedure MoveJOH_SSE2_10(const Source; var Dest; Count : Integer);
  procedure MoveJOH_SSE3_10(const Source; var Dest; Count : Integer);

implementation

uses
  Windows, SysUtils, FastcodeCPUID;

var
  CacheLimit : Integer; {Used within SSE Moves}

{-------------------------------------------------------------------------}
{Move without using any BASM Code}
procedure MoveJOH_PAS_10(const Source; var Dest; Count : Integer);
var
  S, D       : Cardinal;
  Temp, C, I : Integer;
  L          : PInteger;
begin
  S := Cardinal(@Source);
  D := Cardinal(@Dest);
  if S = D then
    Exit;
  if Count <= 4 then
    case Count of
      1 : PByte(@Dest)^ := PByte(S)^;
      2 : PWord(@Dest)^ := PWord(S)^;
      3 : if D > S then
            begin
              PByte(Integer(@Dest)+2)^ := PByte(S+2)^;
              PWord(@Dest)^ := PWord(S)^;
            end
          else
            begin
              PWord(@Dest)^ := PWord(S)^;
              PByte(Integer(@Dest)+2)^ := PByte(S+2)^;
            end;
      4 : PInteger(@Dest)^ := PInteger(S)^
      else Exit; {Count <= 0}
    end
  else
    if D > S then
      begin
        Temp := PInteger(S)^;
        I := Integer(@Dest);
        C := Count - 4;
        L := PInteger(Integer(@Dest) + C);
        Inc(S, C);
        repeat
          L^ := PInteger(S)^;
          if Count <= 8 then
            Break;
          Dec(Count, 4);
          Dec(S, 4);
          Dec(L);
        until False;
        PInteger(I)^ := Temp;
      end
    else
      begin
        C := Count - 4;
        Temp := PInteger(S + Cardinal(C))^;
        I := Integer(@Dest) + C;
        L := @Dest;
        repeat
          L^ := PInteger(S)^;
          if Count <= 8 then
            Break;
          Dec(Count, 4);
          Inc(S, 4);
          Inc(L);
        until False;
        PInteger(I)^ := Temp;
      end;
end; {MoveJOH_PAS}

const
  TINYSIZE = 36;

{-------------------------------------------------------------------------}
{Perform Forward Move of 0..36 Bytes}
{On Entry, ECX = Count, EAX = Source+Count, EDX = Dest+Count.  Destroys ECX}
procedure SmallForwardMove_10;
asm
  jmp     dword ptr [@@FwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@FwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Fwd01, @@Fwd02, @@Fwd03, @@Fwd04, @@Fwd05, @@Fwd06, @@Fwd07, @@Fwd08
  dd      @@Fwd09, @@Fwd10, @@Fwd11, @@Fwd12, @@Fwd13, @@Fwd14, @@Fwd15, @@Fwd16
  dd      @@Fwd17, @@Fwd18, @@Fwd19, @@Fwd20, @@Fwd21, @@Fwd22, @@Fwd23, @@Fwd24
  dd      @@Fwd25, @@Fwd26, @@Fwd27, @@Fwd28, @@Fwd29, @@Fwd30, @@Fwd31, @@Fwd32
  dd      @@Fwd33, @@Fwd34, @@Fwd35, @@Fwd36
@@Fwd36:
  mov     ecx, [eax-36]
  mov     [edx-36], ecx
@@Fwd32:
  mov     ecx, [eax-32]
  mov     [edx-32], ecx
@@Fwd28:
  mov     ecx, [eax-28]
  mov     [edx-28], ecx
@@Fwd24:
  mov     ecx, [eax-24]
  mov     [edx-24], ecx
@@Fwd20:
  mov     ecx, [eax-20]
  mov     [edx-20], ecx
@@Fwd16:
  mov     ecx, [eax-16]
  mov     [edx-16], ecx
@@Fwd12:
  mov     ecx, [eax-12]
  mov     [edx-12], ecx
@@Fwd08:
  mov     ecx, [eax-8]
  mov     [edx-8], ecx
@@Fwd04:
  mov     ecx, [eax-4]
  mov     [edx-4], ecx
  ret
  nop
@@Fwd35:
  mov     ecx, [eax-35]
  mov     [edx-35], ecx
@@Fwd31:
  mov     ecx, [eax-31]
  mov     [edx-31], ecx
@@Fwd27:
  mov     ecx, [eax-27]
  mov     [edx-27], ecx
@@Fwd23:
  mov     ecx, [eax-23]
  mov     [edx-23], ecx
@@Fwd19:
  mov     ecx, [eax-19]
  mov     [edx-19], ecx
@@Fwd15:
  mov     ecx, [eax-15]
  mov     [edx-15], ecx
@@Fwd11:
  mov     ecx, [eax-11]
  mov     [edx-11], ecx
@@Fwd07:
  mov     ecx, [eax-7]
  mov     [edx-7], ecx
  mov     ecx, [eax-4]
  mov     [edx-4], ecx
  ret
  nop
@@Fwd03:
  movzx   ecx, word ptr [eax-3]
  mov     [edx-3], cx
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1], cl
  ret
@@Fwd34:
  mov     ecx, [eax-34]
  mov     [edx-34], ecx
@@Fwd30:
  mov     ecx, [eax-30]
  mov     [edx-30], ecx
@@Fwd26:
  mov     ecx, [eax-26]
  mov     [edx-26], ecx
@@Fwd22:
  mov     ecx, [eax-22]
  mov     [edx-22], ecx
@@Fwd18:
  mov     ecx, [eax-18]
  mov     [edx-18], ecx
@@Fwd14:
  mov     ecx, [eax-14]
  mov     [edx-14], ecx
@@Fwd10:
  mov     ecx, [eax-10]
  mov     [edx-10], ecx
@@Fwd06:
  mov     ecx, [eax-6]
  mov     [edx-6], ecx
@@Fwd02:
  movzx   ecx, word ptr [eax-2]
  mov     [edx-2], cx
  ret
  nop
  nop
  nop
@@Fwd33:
  mov     ecx, [eax-33]
  mov     [edx-33], ecx
@@Fwd29:
  mov     ecx, [eax-29]
  mov     [edx-29], ecx
@@Fwd25:
  mov     ecx, [eax-25]
  mov     [edx-25], ecx
@@Fwd21:
  mov     ecx, [eax-21]
  mov     [edx-21], ecx
@@Fwd17:
  mov     ecx, [eax-17]
  mov     [edx-17], ecx
@@Fwd13:
  mov     ecx, [eax-13]
  mov     [edx-13], ecx
@@Fwd09:
  mov     ecx, [eax-9]
  mov     [edx-9], ecx
@@Fwd05:
  mov     ecx, [eax-5]
  mov     [edx-5], ecx
@@Fwd01:
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1], cl
  ret
@@Done:
end; {SmallForwardMove}

{-------------------------------------------------------------------------}
{Perform Backward Move of 0..36 Bytes}
{On Entry, ECX = Count, EAX = Source, EDX = Dest.  Destroys ECX}
procedure SmallBackwardMove_10;
asm
  jmp     dword ptr [@@BwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@BwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Bwd01, @@Bwd02, @@Bwd03, @@Bwd04, @@Bwd05, @@Bwd06, @@Bwd07, @@Bwd08
  dd      @@Bwd09, @@Bwd10, @@Bwd11, @@Bwd12, @@Bwd13, @@Bwd14, @@Bwd15, @@Bwd16
  dd      @@Bwd17, @@Bwd18, @@Bwd19, @@Bwd20, @@Bwd21, @@Bwd22, @@Bwd23, @@Bwd24
  dd      @@Bwd25, @@Bwd26, @@Bwd27, @@Bwd28, @@Bwd29, @@Bwd30, @@Bwd31, @@Bwd32
  dd      @@Bwd33, @@Bwd34, @@Bwd35, @@Bwd36
@@Bwd36:
  mov     ecx, [eax+32]
  mov     [edx+32], ecx
@@Bwd32:
  mov     ecx, [eax+28]
  mov     [edx+28], ecx
@@Bwd28:
  mov     ecx, [eax+24]
  mov     [edx+24], ecx
@@Bwd24:
  mov     ecx, [eax+20]
  mov     [edx+20], ecx
@@Bwd20:
  mov     ecx, [eax+16]
  mov     [edx+16], ecx
@@Bwd16:
  mov     ecx, [eax+12]
  mov     [edx+12], ecx
@@Bwd12:
  mov     ecx, [eax+8]
  mov     [edx+8], ecx
@@Bwd08:
  mov     ecx, [eax+4]
  mov     [edx+4], ecx
@@Bwd04:
  mov     ecx, [eax]
  mov     [edx], ecx
  ret
  nop
  nop
  nop
@@Bwd35:
  mov     ecx, [eax+31]
  mov     [edx+31], ecx
@@Bwd31:
  mov     ecx, [eax+27]
  mov     [edx+27], ecx
@@Bwd27:
  mov     ecx, [eax+23]
  mov     [edx+23], ecx
@@Bwd23:
  mov     ecx, [eax+19]
  mov     [edx+19], ecx
@@Bwd19:
  mov     ecx, [eax+15]
  mov     [edx+15], ecx
@@Bwd15:
  mov     ecx, [eax+11]
  mov     [edx+11], ecx
@@Bwd11:
  mov     ecx, [eax+7]
  mov     [edx+7], ecx
@@Bwd07:
  mov     ecx, [eax+3]
  mov     [edx+3], ecx
  mov     ecx, [eax]
  mov     [edx], ecx
  ret
  nop
  nop
  nop
@@Bwd03:
  movzx   ecx, word ptr [eax+1]
  mov     [edx+1], cx
  movzx   ecx, byte ptr [eax]
  mov     [edx], cl
  ret
  nop
  nop
@@Bwd34:
  mov     ecx, [eax+30]
  mov     [edx+30], ecx
@@Bwd30:
  mov     ecx, [eax+26]
  mov     [edx+26], ecx
@@Bwd26:
  mov     ecx, [eax+22]
  mov     [edx+22], ecx
@@Bwd22:
  mov     ecx, [eax+18]
  mov     [edx+18], ecx
@@Bwd18:
  mov     ecx, [eax+14]
  mov     [edx+14], ecx
@@Bwd14:
  mov     ecx, [eax+10]
  mov     [edx+10], ecx
@@Bwd10:
  mov     ecx, [eax+6]
  mov     [edx+6], ecx
@@Bwd06:
  mov     ecx, [eax+2]
  mov     [edx+2], ecx
@@Bwd02:
  movzx   ecx, word ptr [eax]
  mov     [edx], cx
  ret
  nop
@@Bwd33:
  mov     ecx, [eax+29]
  mov     [edx+29], ecx
@@Bwd29:
  mov     ecx, [eax+25]
  mov     [edx+25], ecx
@@Bwd25:
  mov     ecx, [eax+21]
  mov     [edx+21], ecx
@@Bwd21:
  mov     ecx, [eax+17]
  mov     [edx+17], ecx
@@Bwd17:
  mov     ecx, [eax+13]
  mov     [edx+13], ecx
@@Bwd13:
  mov     ecx, [eax+9]
  mov     [edx+9], ecx
@@Bwd09:
  mov     ecx, [eax+5]
  mov     [edx+5], ecx
@@Bwd05:
  mov     ecx, [eax+1]
  mov     [edx+1], ecx
@@Bwd01:
  movzx   ecx, byte ptr[eax]
  mov     [edx], cl
  ret
@@Done:
end; {SmallBackwardMove}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_IA32_10;
asm
  fild    qword ptr [eax] {First 8}
  lea     eax, [eax+ecx-8]
  lea     ecx, [edx+ecx-8]
  push    edx
  push    ecx
  fild    qword ptr [eax] {Last 8}
  neg     ecx {QWORD Align Writes}
  and     edx, -8
  lea     ecx, [ecx+edx+8]
  pop     edx
@@Loop:
  fild    qword ptr [eax+ecx]
  fistp   qword ptr [edx+ecx]
  add     ecx, 8
  jl      @@Loop
  pop     eax
  fistp   qword ptr [edx] {Last 8}
  fistp   qword ptr [eax] {First 8}
end; {Forwards_IA32}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_IA32_10;
asm
  sub     ecx, 8
  fild    qword ptr [eax+ecx] {Last 8}
  fild    qword ptr [eax] {First 8}
  add     ecx, edx {QWORD Align Writes}
  push    ecx
  and     ecx, -8
  sub     ecx, edx
@@Loop:
  fild    qword ptr [eax+ecx]
  fistp   qword ptr [edx+ecx]
  sub     ecx, 8
  jg      @@Loop
  pop     eax
  fistp   qword ptr [edx] {First 8}
  fistp   qword ptr [eax] {Last 8}
end; {Backwards_IA32}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_MMX_10;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE {Size at which using MMX becomes worthwhile}
  jl      Forwards_IA32_10
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  push    ebx
  mov     ebx, edx
  movq    mm0, [eax] {First 8 Bytes}
  add     eax, ecx {QWORD Align Writes}
  add     ecx, edx
  and     edx, -8
  add     edx, 40
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
  nop {Align Loop}
@@FwdLoopMMX:
  movq    mm1, [eax+ecx-32]
  movq    mm2, [eax+ecx-24]
  movq    mm3, [eax+ecx-16]
  movq    mm4, [eax+ecx- 8]
  movq    [edx+ecx-32], mm1
  movq    [edx+ecx-24], mm2
  movq    [edx+ecx-16], mm3
  movq    [edx+ecx- 8], mm4
  add     ecx, 32
  jle     @@FwdLoopMMX
  movq    [ebx], mm0 {First 8 Bytes}
  emms
  pop     ebx
  neg     ecx
  add     ecx, 32
  jmp     SmallForwardMove_10
  nop {Align Loop}
  nop
@@FwdLargeMove:
  push    ebx
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove_10
@@FwdAligned:
  mov     ecx, ebx
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    esi
  push    edi
  mov     esi, eax          {ESI = Source}
  mov     edi, edx          {EDI = Dest}
  mov     eax, ecx          {EAX = Count}
  and     eax, -64          {EAX = No of Bytes to Blocks Moves}
  and     ecx, $3F          {ECX = Remaining Bytes to Move (0..63)}
  add     esi, eax
  add     edi, eax
  neg     eax
@@MMXcopyloop:
  movq    mm0, [esi+eax   ]
  movq    mm1, [esi+eax+ 8]
  movq    mm2, [esi+eax+16]
  movq    mm3, [esi+eax+24]
  movq    mm4, [esi+eax+32]
  movq    mm5, [esi+eax+40]
  movq    mm6, [esi+eax+48]
  movq    mm7, [esi+eax+56]
  movq    [edi+eax   ], mm0
  movq    [edi+eax+ 8], mm1
  movq    [edi+eax+16], mm2
  movq    [edi+eax+24], mm3
  movq    [edi+eax+32], mm4
  movq    [edi+eax+40], mm5
  movq    [edi+eax+48], mm6
  movq    [edi+eax+56], mm7
  add     eax, 64
  jnz     @@MMXcopyloop
  emms                   {Empty MMX State}
  add     ecx, ebx
  shr     ecx, 2
  rep     movsd
  mov     ecx, ebx
  and     ecx, 3
  rep     movsb
  pop     edi
  pop     esi
  pop     ebx
end; {Forwards_MMX}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_MMX_10;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE {Size at which using MMX becomes worthwhile}
  jl      Backwards_IA32_10
  push    ebx
  movq    mm0, [eax+ecx-8] {Get Last QWORD}
  lea     ebx, [edx+ecx] {QWORD Align Writes}
  and     ebx, 7
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
@@BwdLoopMMX:
  movq    mm1, [eax+ecx   ]
  movq    mm2, [eax+ecx+ 8]
  movq    mm3, [eax+ecx+16]
  movq    mm4, [eax+ecx+24]
  movq    [edx+ecx+24], mm4
  movq    [edx+ecx+16], mm3
  movq    [edx+ecx+ 8], mm2
  movq    [edx+ecx   ], mm1
  sub     ecx, 32
  jge     @@BwdLoopMMX
  movq    [edx+ebx-8], mm0 {Last QWORD}
  emms
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove_10
end; {Backwards_MMX}

{-------------------------------------------------------------------------}
procedure LargeAlignedSSEMove;
asm
@@Loop:
  movaps  xmm0, [eax+ecx]
  movaps  xmm1, [eax+ecx+16]
  movaps  xmm2, [eax+ecx+32]
  movaps  xmm3, [eax+ecx+48]
  movaps  [edx+ecx], xmm0 
  movaps  [edx+ecx+16], xmm1
  movaps  [edx+ecx+32], xmm2
  movaps  [edx+ecx+48], xmm3
  movaps  xmm4, [eax+ecx+64]
  movaps  xmm5, [eax+ecx+80]
  movaps  xmm6, [eax+ecx+96]
  movaps  xmm7, [eax+ecx+112]
  movaps  [edx+ecx+64], xmm4
  movaps  [edx+ecx+80], xmm5
  movaps  [edx+ecx+96], xmm6
  movaps  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end; {LargeAlignedSSEMove}

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSEMove;
asm
@@Loop:
  movups  xmm0, [eax+ecx]
  movups  xmm1, [eax+ecx+16]
  movups  xmm2, [eax+ecx+32]
  movups  xmm3, [eax+ecx+48]
  movaps  [edx+ecx], xmm0
  movaps  [edx+ecx+16], xmm1
  movaps  [edx+ecx+32], xmm2
  movaps  [edx+ecx+48], xmm3
  movups  xmm4, [eax+ecx+64]
  movups  xmm5, [eax+ecx+80]
  movups  xmm6, [eax+ecx+96]
  movups  xmm7, [eax+ecx+112]
  movaps  [edx+ecx+64], xmm4
  movaps  [edx+ecx+80], xmm5
  movaps  [edx+ecx+96], xmm6
  movaps  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end; {LargeUnalignedSSEMove}

{-------------------------------------------------------------------------}
procedure HugeAlignedSSEMove;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movaps  xmm0, [eax+ecx]
  movaps  xmm1, [eax+ecx+16]
  movaps  xmm2, [eax+ecx+32]
  movaps  xmm3, [eax+ecx+48]
  movntps [edx+ecx], xmm0
  movntps [edx+ecx+16], xmm1
  movntps [edx+ecx+32], xmm2
  movntps [edx+ecx+48], xmm3
  movaps  xmm4, [eax+ecx+64]
  movaps  xmm5, [eax+ecx+80]
  movaps  xmm6, [eax+ecx+96]
  movaps  xmm7, [eax+ecx+112]
  movntps [edx+ecx+64], xmm4
  movntps [edx+ecx+80], xmm5
  movntps [edx+ecx+96], xmm6
  movntps [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeAlignedSSEMove}

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSEMove;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movups  xmm0, [eax+ecx]
  movups  xmm1, [eax+ecx+16]
  movups  xmm2, [eax+ecx+32]
  movups  xmm3, [eax+ecx+48]
  movntps [edx+ecx], xmm0
  movntps [edx+ecx+16], xmm1
  movntps [edx+ecx+32], xmm2
  movntps [edx+ecx+48], xmm3
  movups  xmm4, [eax+ecx+64]
  movups  xmm5, [eax+ecx+80]
  movups  xmm6, [eax+ecx+96]
  movups  xmm7, [eax+ecx+112]
  movntps [edx+ecx+64], xmm4
  movntps [edx+ecx+80], xmm5
  movntps [edx+ecx+96], xmm6
  movntps [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeUnalignedSSEMove}

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSEMove(const Source; var Dest; Count: Integer);
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSEMove   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSEMove
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSEMove    {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSEMove
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
  movups  xmm0, [eax+ebx]
  movaps  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end; {LargeSSEMove}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE_10;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32_10
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  movups  xmm0, [eax] {First 16 Bytes}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
  nop {Align Loop}
@@FwdLoopSSE:
  movups  xmm1, [eax+ecx-32]
  movups  xmm2, [eax+ecx-16]
  movaps  [edx+ecx-32], xmm1
  movaps  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE
  movups  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove_10
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove_10
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSEMove
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove_10
end; {Forwards_SSE}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE_10;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32_10
  push    ebx
  movups  xmm0, [eax+ecx-16] {Last 16 Bytes}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
@@BwdLoop:
  movups  xmm1, [eax+ecx]
  movups  xmm2, [eax+ecx+16]
  movaps  [edx+ecx], xmm1
  movaps  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movups  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove_10
end; {Backwards_SSE}

{-------------------------------------------------------------------------}
procedure LargeAlignedSSE2Move; {Also used in SSE3 Move}
asm
@@Loop:
  movdqa  xmm0, [eax+ecx]
  movdqa  xmm1, [eax+ecx+16]
  movdqa  xmm2, [eax+ecx+32]
  movdqa  xmm3, [eax+ecx+48]
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
  movdqa  xmm4, [eax+ecx+64]
  movdqa  xmm5, [eax+ecx+80]
  movdqa  xmm6, [eax+ecx+96]
  movdqa  xmm7, [eax+ecx+112]
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end; {LargeAlignedSSE2Move}

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSE2Move;
asm
@@Loop:
  movdqu  xmm0, [eax+ecx]
  movdqu  xmm1, [eax+ecx+16]
  movdqu  xmm2, [eax+ecx+32]
  movdqu  xmm3, [eax+ecx+48]
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
  movdqu  xmm4, [eax+ecx+64]
  movdqu  xmm5, [eax+ecx+80]
  movdqu  xmm6, [eax+ecx+96]
  movdqu  xmm7, [eax+ecx+112]
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end; {LargeUnalignedSSE2Move}

{-------------------------------------------------------------------------}
procedure HugeAlignedSSE2Move; {Also used in SSE3 Move}
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movdqa  xmm0, [eax+ecx]
  movdqa  xmm1, [eax+ecx+16]
  movdqa  xmm2, [eax+ecx+32]
  movdqa  xmm3, [eax+ecx+48]
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
  movdqa  xmm4, [eax+ecx+64]
  movdqa  xmm5, [eax+ecx+80]
  movdqa  xmm6, [eax+ecx+96]
  movdqa  xmm7, [eax+ecx+112]
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeAlignedSSE2Move}

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSE2Move;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movdqu  xmm0, [eax+ecx]
  movdqu  xmm1, [eax+ecx+16]
  movdqu  xmm2, [eax+ecx+32]
  movdqu  xmm3, [eax+ecx+48]
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
  movdqu  xmm4, [eax+ecx+64]
  movdqu  xmm5, [eax+ecx+80]
  movdqu  xmm6, [eax+ecx+96]
  movdqu  xmm7, [eax+ecx+112]
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeUnalignedSSE2Move}

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSE2Move(const Source; var Dest; Count: Integer);
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSE2Move  {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSE2Move
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSE2Move   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSE2Move
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
  movdqu  xmm0, [eax+ebx]
  movdqa  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end; {LargeSSE2Move}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE2_10;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32_10
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  movdqu  xmm0, [eax] {First 16 Bytes}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
@@FwdLoopSSE2:
  movdqu  xmm1, [eax+ecx-32]
  movdqu  xmm2, [eax+ecx-16]
  movdqa  [edx+ecx-32], xmm1
  movdqa  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE2
  movdqu  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove_10
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove_10
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSE2Move
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove_10
end; {Forwards_SSE2}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE2_10;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32_10
  push    ebx
  movdqu  xmm0, [eax+ecx-16] {Last 16 Bytes}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
  add     edi, 0 {3-Byte NOP Equivalent to Align Loop}
@@BwdLoop:
  movdqu  xmm1, [eax+ecx]
  movdqu  xmm2, [eax+ecx+16]
  movdqa  [edx+ecx], xmm1
  movdqa  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movdqu  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove_10
end; {Backwards_SSE2}

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSE3Move;
asm
@@Loop:
{$IFDEF SSE2Basm}
  lddqu   xmm0, [eax+ecx]
  lddqu   xmm1, [eax+ecx+16]
  lddqu   xmm2, [eax+ecx+32]
  lddqu   xmm3, [eax+ecx+48]
{$ELSE}
  DB      $F2,$0F,$F0,$04,$01
  DB      $F2,$0F,$F0,$4C,$01,$10
  DB      $F2,$0F,$F0,$54,$01,$20
  DB      $F2,$0F,$F0,$5C,$01,$30
{$ENDIF}
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
{$IFDEF SSE2Basm}
  lddqu   xmm4, [eax+ecx+64]
  lddqu   xmm5, [eax+ecx+80]
  lddqu   xmm6, [eax+ecx+96]
  lddqu   xmm7, [eax+ecx+112]
{$ELSE}
  DB      $F2,$0F,$F0,$64,$01,$40
  DB      $F2,$0F,$F0,$6C,$01,$50
  DB      $F2,$0F,$F0,$74,$01,$60
  DB      $F2,$0F,$F0,$7C,$01,$70
{$ENDIF}
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end; {LargeUnalignedSSE3Move}

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSE3Move;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
{$IFDEF SSE2Basm}
  lddqu   xmm0, [eax+ecx]
  lddqu   xmm1, [eax+ecx+16]
  lddqu   xmm2, [eax+ecx+32]
  lddqu   xmm3, [eax+ecx+48]
{$ELSE}
  DB      $F2,$0F,$F0,$04,$01
  DB      $F2,$0F,$F0,$4C,$01,$10
  DB      $F2,$0F,$F0,$54,$01,$20
  DB      $F2,$0F,$F0,$5C,$01,$30
{$ENDIF}
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
{$IFDEF SSE2Basm}
  lddqu   xmm4, [eax+ecx+64]
  lddqu   xmm5, [eax+ecx+80]
  lddqu   xmm6, [eax+ecx+96]
  lddqu   xmm7, [eax+ecx+112]
{$ELSE}
  DB      $F2,$0F,$F0,$64,$01,$40
  DB      $F2,$0F,$F0,$6C,$01,$50
  DB      $F2,$0F,$F0,$74,$01,$60
  DB      $F2,$0F,$F0,$7C,$01,$70
{$ENDIF}
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeUnalignedSSE3Move}

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSE3Move(const Source; var Dest; Count: Integer);
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSE2Move  {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSE3Move
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSE2Move   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSE3Move
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
{$IFDEF SSE2Basm}
  lddqu   xmm0, [eax+ebx]
{$ELSE}
  DB      $F2,$0F,$F0,$04,$03 
{$ENDIF}
  movdqa  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end; {LargeSSE3Move}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE3_10;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32_10
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
{$IFDEF SSE2Basm}
  lddqu   xmm0, [eax] {First 16 Bytes}
{$ELSE}
  DB      $F2,$0F,$F0,$00 
{$ENDIF}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
@@FwdLoopSSE3:
{$IFDEF SSE2Basm}
  lddqu   xmm1, [eax+ecx-32]
  lddqu   xmm2, [eax+ecx-16]
{$ELSE}
  DB      $F2,$0F,$F0,$4C,$01,$E0
  DB      $F2,$0F,$F0,$54,$01,$F0
{$ENDIF}
  movdqa  [edx+ecx-32], xmm1
  movdqa  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE3
  movdqu  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove_10
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove_10
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSE3Move
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove_10
end; {Forwards_SSE3}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE3_10;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32_10
  push    ebx
{$IFDEF SSE2Basm}
  lddqu   xmm0, [eax+ecx-16] {Last 16 Bytes}
{$ELSE}
  DB      $F2,$0F,$F0,$44,$01,$F0
{$ENDIF}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
  add     edi, 0 {3-Byte NOP Equivalent to Align Loop}
@@BwdLoop:
{$IFDEF SSE2Basm}
  lddqu   xmm1, [eax+ecx]
  lddqu   xmm2, [eax+ecx+16]
{$ELSE}
  DB      $F2,$0F,$F0,$0C,$01
  DB      $F2,$0F,$F0,$54,$01,$10
{$ENDIF}
  movdqa  [edx+ecx], xmm1
  movdqa  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movdqu  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove_10
end; {Backwards_SSE3}

{-------------------------------------------------------------------------}
{Move using IA32 Instruction Set Only}
procedure MoveJOH_IA32_10(const Source; var Dest; Count : Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove_10
@@SmallCheck:
  jne     SmallBackwardMove_10
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_IA32_10
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_IA32_10
  jmp     Backwards_IA32_10 {Source/Dest Overlap}
@@Done:
end; {MoveJOH_IA32}

{-------------------------------------------------------------------------}
{Move using MMX Instruction Set}
procedure MoveJOH_MMX_10(const Source; var Dest; Count : Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove_10
@@SmallCheck:
  jne     SmallBackwardMove_10
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_MMX_10
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_MMX_10
  jmp     Backwards_MMX_10 {Source/Dest Overlap}
@@Done:
end; {MoveJOH_MMX}

{-------------------------------------------------------------------------}
{Move using SSE Instruction Set}
procedure MoveJOH_SSE_10(const Source; var Dest; Count : Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove_10
@@SmallCheck:
  jne     SmallBackwardMove_10
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_SSE_10
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE_10
  jmp     Backwards_SSE_10 {Source/Dest Overlap}
@@Done:
end; {MoveJOH_SSE}

{-------------------------------------------------------------------------}
{Move using SSE2 Instruction Set}
procedure MoveJOH_SSE2_10(const Source; var Dest; Count : Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove_10
@@SmallCheck:
  jne     SmallBackwardMove_10
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_SSE2_10
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE2_10
  jmp     Backwards_SSE2_10 {Source/Dest Overlap}
@@Done:
end; {MoveJOH_SSE2}

{-------------------------------------------------------------------------}
{Move using SSE3 Instruction Set}
procedure MoveJOH_SSE3_10(const Source; var Dest; Count : Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove_10
@@SmallCheck:
  jne     SmallBackwardMove_10
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_SSE3_10
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE3_10
  jmp     Backwards_SSE3_10 {Source/Dest Overlap}
@@Done:
end; {MoveJOH_SSE3}

{-------------------------------------------------------------------------}

{$IFDEF PurePascal}

procedure PatchMove; {Patch System.Move to Divert Calls to New Move Procedure}
const
  JumpFarId = $E9;
var
  Protect, OldProtect : DWORD;
begin
  VirtualProtect(@System.Move, 256, PAGE_EXECUTE_READWRITE, @OldProtect);
  if PByte(@System.Move)^ <> JumpFarId then {Check if Already Patched}
    begin
      PByte(@System.Move)^ := JumpFarId;
      PInteger(Integer(@System.Move)+1)^ :=
        Integer(@Move) - Integer(@System.Move)-5; {Change Destination}
    end;
  VirtualProtect(@System.Move, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, @System.Move, 256);
end; {PatchMove}

{$ELSE}

procedure PatchMove; {Overwrite System.Move with Main Procedure of New Move}
const
  JumpFarId = $E9;
  JumpPtrId = $25FF;
type {Jump Positions in Move Prodedures Above - Really Horrible but it Works}
  NewMoveType = packed record {Size = 56 Bytes, System.Move Size = 64 Bytes}
    Padding1  : array[1..14] of Byte;
    Jump1Dest : Integer; {jmp SmallForwardMove}
    Padding2  : array[1.. 2] of Byte;
    Jump2Dest : Integer; {jmp SmallBackwardMove}
    Padding3  : array[1.. 7] of Byte;
    Jump3Dest : Integer; {jg  Forwards_XXX}
    Padding4  : array[1..11] of Byte;
    Jump4Dest : Integer; {jg  Backwards_XXX}
    Padding5  : array[1.. 1] of Byte;
    Jump5Dest : Integer; {jmp Forwards_XXX}
    Padding6  : array[1.. 1] of Byte;
  end;
var
  I, Offset  : Integer;
  Src, Dest  : PByteArray;
  NewMove    : NewMoveType;
  Protect,
  OldProtect : DWORD;
begin
  VirtualProtect(@System.Move, 256, PAGE_EXECUTE_READWRITE, @OldProtect);
  if PByte(@System.Move)^ <> JumpFarId then {Check if Already Patched}
    if PWord(@System.Move)^ = JumpPtrId then
      begin {System.Move Starts JMP DWORD PTR [XXXXXXXX] (ie. Using Packages)}
        PByte(@System.Move)^ := JumpFarId;
        PInteger(Integer(@System.Move)+1)^ :=
          Integer(@Move) - Integer(@System.Move)-5; {Change Destination}
      end
    else
      begin {Patch System.Move.  Adjust Jump Destinations in Copied Procedure}
        Move(Pointer(@Move)^, NewMove, SizeOf(NewMove));
        Offset := Integer(@Move) - Integer(@System.Move);
        Inc(NewMove.Jump1Dest, Offset);
        Inc(NewMove.Jump2Dest, Offset);
        Inc(NewMove.Jump3Dest, Offset);
        Inc(NewMove.Jump4Dest, Offset);
        Inc(NewMove.Jump5Dest, Offset);
        Src  := @NewMove;
        Dest := @System.Move;
        for I := 0 to SizeOf(NewMove) - 1 do
          Dest[I] := Src[I]; {Overwrite System.Move}
      end;
  VirtualProtect(@System.Move, 256, OldProtect, @Protect);
  FlushInstructionCache(GetCurrentProcess, @System.Move, SizeOf(NewMove));
end; {PatchMove}

{$ENDIF}

initialization
{$IFDEF PurePascal}
  Move := MoveJOH_PAS_10;
{$ELSE}
  if isSSE3 in CPU.InstructionSupport then
    Move := MoveJOH_SSE3_10 {Processor Supports SSE3}
  else
    if isSSE2 in CPU.InstructionSupport then
      Move := MoveJOH_SSE2_10 {Processor Supports SSE2}
    else
      if isSSE in CPU.InstructionSupport then
        Move := MoveJOH_SSE_10 {Processor Supports SSE}
      else
        if isMMX in CPU.InstructionSupport then
          Move := MoveJOH_MMX_10 {Processor Supports MMX}
        else
          Move := MoveJOH_IA32_10; {Processor does not Support MMX or SSE}
  CacheLimit := CPU.L2CacheSize * -512; {Used within SSE Based Moves}
{$ENDIF}
{$IFDEF PatchSystemMove}
  PatchMove; {Patch Delphi's System.Move}
{$ENDIF}
end.

