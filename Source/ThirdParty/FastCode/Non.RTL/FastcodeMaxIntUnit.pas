unit FastcodeMaxIntUnit;

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
 * Lars Blok Gravengaard
 * Aleksandr Sharahov
 *
 * BV Version: 1.81
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

type
  FastcodeMaxIntFunction = function(const A, B : Integer) : Integer;

{Functions shared between Targets}
function Max_LBG_IA32_1(const A, B : Integer) : Integer;
function Max_Sha_Pas_1(const a, b: integer): integer;

{Functions not shared between Targets}

{Functions}

const
  FastcodeMaxIntP4R: FastcodeMaxIntFunction = Max_Sha_Pas_1;
  FastcodeMaxIntP4N: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntPMY: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntPMD: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntAMD64: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntAMD64_SSE3: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntIA32SizePenalty: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntIA32: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntMMX: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntSSESizePenalty: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntSSE: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntSSE2: FastcodeMaxIntFunction = Max_LBG_IA32_1;
  FastcodeMaxIntPascalSizePenalty: FastcodeMaxIntFunction = Max_Sha_Pas_1;
  FastcodeMaxIntPascal: FastcodeMaxIntFunction = Max_Sha_Pas_1;

implementation

function Max_LBG_IA32_1(const A, B : Integer) : Integer;
asm
                    // A in EAX
                    // B in EDX
   CMP EDX,EAX      // Is edx > eax  ?
   CMOVG EAX,EDX    // Conditional move if greater
                    // Does not affect the destination operand if the condition is false.
end;

{$UNDEF SaveQ}
{$IFOPT Q+} {$DEFINE SaveQ} {$Q-} {$ENDIF}
function Max_Sha_Pas_1(const a, b: integer): integer;
begin;
  Result:=a + (b-a) and (ord(a>b) - 1);
  end;
{$IFDEF SaveQ} {$UNDEF SaveQ} {$Q+} {$ENDIF}

end.
