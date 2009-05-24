unit CnFastCode;

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
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

uses
  FastMove,
  FastcodeCPUID,
  FastcodePatch,
  FastcodeAnsiStringReplaceUnit,
  FastcodePosUnit,
  {$IFDEF Delphi7Plus}
  FastcodePosExUnit,
  {$ENDIF}
  FastcodeLowerCaseUnit,
  FastcodeUpperCaseUnit,
  FastcodeCompareStrUnit,
  FastcodeCompareMemUnit,
  FastcodeCompareTextUnit,
  FastcodeStrCompUnit,
  FastcodeStrCopyUnit,
  FastcodeStrICompUnit,
  FastcodeStrLenUnit,
  FastcodeFillCharUnit,
  FastcodeStrToInt32Unit;

const
  FastCodeRTLVersion = '0.6.4';

procedure InstallFastCode;

procedure UninstallFastCode;

var
  FastcodeAnsiStringReplace: FastcodeAnsiStringReplaceFunction = nil;
  FastcodeCompareMem: FastcodeCompareMemFunction = nil;
  FastcodeCompareStr: FastcodeCompareStrFunction = nil;
  FastcodeCompareText: FastcodeCompareTextFunction = nil;
  FastcodeFillChar: FastcodeFillCharFunction = nil;
  FastcodeLowerCase: FastcodeLowerCaseFunction = nil;
  FastcodePos: FastcodePosFunction = nil;
  {$IFDEF Delphi7Plus}
  FastcodePosEx: FastcodePosExFunction = nil;
  {$ENDIF}
  FastcodeStrComp: FastcodeStrCompFunction = nil;
  FastcodeStrCopy: FastcodeStrCopyFunction = nil;
  FastcodeStrIComp: FastcodeStrICompFunction = nil;
  FastcodeStrLen: FastcodeStrLenFunction = nil;
  FastcodeStrToInt32: FastcodeStrToInt32Function = nil;
  FastcodeUpperCase: FastcodeUpperCaseFunction = nil;

implementation

uses
  Windows, SysUtils, Contnrs,
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}  
  CnWizMethodHook;

var
  FHookList: TObjectList = nil;

procedure MoveStub;
asm
  call System.Move;
end;

procedure CreateHook(const ASource, ADestination: Pointer);
var
  P: PByte;
begin
  P := FastcodeGetAddress(ASource);
  P := GetBplMethodAddress(P);
  if P^ <> $E9 then // 防止重复补丁与 DelphiSpeedUp 等冲突
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('FastCode CreateHook: %.8x => %.8x', [Integer(P),
      Integer(ADestination)]);
  {$ENDIF}    
    FHookList.Add(TCnMethodHook.Create(P, ADestination));
  end;
end;

procedure InstallFastCode;
begin
  if FHookList = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('InstallFastCode');
  {$ENDIF}
    FHookList := TObjectList.Create;
    CreateHook(@MoveStub, @FastMove.Move);
    CreateHook(@AnsiStringReplaceStub, @FastcodeAnsiStringReplace);
    CreateHook(@CompareMemStub, @FastcodeCompareMem);
    CreateHook(@CompareStrStub, @FastcodeCompareStr);
    // FastcodeCompareText 好象存在 Bug
    // CreateHook(@CompareTextStub, @FastcodeCompareText);
    CreateHook(@FillCharStub, @FastcodeFillChar);
    CreateHook(@LowerCaseStub, @FastcodeLowerCase);
    CreateHook(@PosStub, @FastcodePos);
    {$IFDEF Delphi7}
    CreateHook(@PosExStub, @FastcodePosEx);
    {$ENDIF}
    CreateHook(@StrCompStub, @FastcodeStrComp);
    CreateHook(@StrCopyStub, @FastcodeStrCopy);
    CreateHook(@StrICompStub, @FastcodeStrIComp);
    CreateHook(@StrLenStub, @FastcodeStrLen);
    CreateHook(@StrToInt32Stub, @FastcodeStrToInt32);
    CreateHook(@UpperCaseStub, @FastcodeUpperCase);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('InstallFastCode succ');
  {$ENDIF}    
  end;
end;

procedure UninstallFastCode;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('UninstallFastCode');
{$ENDIF}
  if FHookList <> nil then
    FreeAndNil(FHookList);
end;  

initialization
{$IFDEF FastcodeCPUID}
  case FastcodeTarget of
           fctIA32: begin
                      {$IFDEF FastcodeSizePenalty}
                        FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceIA32SizePenalty;
                        FastcodeCompareMem := FastcodeCompareMemIA32SizePenalty;
                        FastcodeCompareStr := FastcodeCompareStrIA32SizePenalty;
                        FastcodeCompareText := FastcodeCompareTextIA32SizePenalty;
                        FastcodeFillChar := FastcodeFillCharIA32SizePenalty;
                        FastcodeLowerCase := FastcodeLowerCaseIA32SizePenalty;
                        FastcodePos := FastcodePosIA32SizePenalty;
                        {$IFDEF Delphi7Plus}
                        FastcodePosEx := FastcodePosExIA32SizePenalty;
                        {$ENDIF}
                        FastcodeStrComp := FastcodeStrCompIA32SizePenalty;
                        FastcodeStrCopy := FastcodeStrCopyIA32SizePenalty;
                        FastcodeStrIComp := FastcodeStrICompIA32SizePenalty;
                        FastcodeStrLen := FastcodeStrLenIA32SizePenalty;
                        FastcodeStrToInt32 := FastcodeStrToInt32IA32SizePenalty
                        FastcodeUpperCase := FastcodeUpperCaseIA32SizePenalty;
                      {$ELSE}
                        FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceIA32;
                        FastcodeCompareMem := FastcodeCompareMemIA32;
                        FastcodeCompareStr := FastcodeCompareStrIA32;
                        FastcodeCompareText := FastcodeCompareTextIA32;
                        FastcodeFillChar := FastcodeFillCharIA32;
                        FastcodeLowerCase := FastcodeLowerCaseIA32;
                        FastcodePos := FastcodePosIA32;
                        {$IFDEF Delphi7Plus}
                        FastcodePosEx := FastcodePosExIA32;
                        {$ENDIF}
                        FastcodeStrComp := FastcodeStrCompIA32;
                        FastcodeStrCopy := FastcodeStrCopyIA32;
                        FastcodeStrIComp := FastcodeStrICompIA32;
                        FastcodeStrLen := FastcodeStrLenIA32;
                        FastcodeStrToInt32 := FastcodeStrToInt32IA32;
                        FastcodeUpperCase := FastcodeUpperCaseIA32;
                      {$ENDIF}
                    end;
            fctMMX: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceMMX;
                      FastcodeCompareMem := FastcodeCompareMemMMX;
                      FastcodeCompareStr := FastcodeCompareStrMMX;
                      FastcodeCompareText := FastcodeCompareTextMMX;
                      FastcodeFillChar := FastcodeFillCharMMX;
                      FastcodeLowerCase := FastcodeLowerCaseMMX;
                      FastcodePos := FastcodePosMMX;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExMMX;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompMMX;
                      FastcodeStrCopy := FastcodeStrCopyMMX;
                      FastcodeStrIComp := FastcodeStrICompMMX;
                      FastcodeStrLen := FastcodeStrLenMMX;
                      FastcodeStrToInt32 := FastcodeStrToInt32MMX;
                      FastcodeUpperCase := FastcodeUpperCaseMMX;
                    end;
            fctSSE: begin
                      {$IFDEF FastcodeSizePenalty}
                        FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceSSESizePenalty;
                        FastcodeCompareMem := FastcodeCompareMemSSESizePenalty;
                        FastcodeCompareStr := FastcodeCompareStrSSESizePenalty;
                        FastcodeCompareText := FastcodeCompareTextSSESizePenalty;
                        FastcodeFillChar := FastcodeFillCharSSESizePenalty;
                        FastcodeLowerCase := FastcodeLowerCaseSSESizePenalty;
                        FastcodePos := FastcodePosSSESizePenalty;
                        {$IFDEF Delphi7Plus}
                        FastcodePosEx := FastcodePosExSSESizePenalty;
                        {$ENDIF}
                        FastcodeStrComp := FastcodeStrCompSSESizePenalty;
                        FastcodeStrCopy := FastcodeStrCopySSESizePenalty;
                        FastcodeStrIComp := FastcodeStrICompSSESizePenalty;
                        FastcodeStrLen := FastcodeStrLenSSESizePenalty;
                        FastcodeStrToInt32 := FastcodeStrToInt32SSESizePenalty
                        FastcodeUpperCase := FastcodeUpperCaseSSESizePenalty;
                      {$ELSE}
                        FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceSSE;
                        FastcodeCompareMem := FastcodeCompareMemSSE;
                        FastcodeCompareStr := FastcodeCompareStrSSE;
                        FastcodeCompareText := FastcodeCompareTextSSE;
                        FastcodeFillChar := FastcodeFillCharSSE;
                        FastcodeLowerCase := FastcodeLowerCaseSSE;
                        FastcodePos := FastcodePosSSE;
                        {$IFDEF Delphi7Plus}
                        FastcodePosEx := FastcodePosExSSE;
                        {$ENDIF}
                        FastcodeStrComp := FastcodeStrCompSSE;
                        FastcodeStrCopy := FastcodeStrCopySSE;
                        FastcodeStrIComp := FastcodeStrICompSSE;
                        FastcodeStrLen := FastcodeStrLenSSE;
                        FastcodeStrToInt32 := FastcodeStrToInt32SSE;
                        FastcodeUpperCase := FastcodeUpperCaseSSE;
                      {$ENDIF}
                    end;
           fctSSE2: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceSSE2;
                      FastcodeCompareMem := FastcodeCompareMemSSE2;
                      FastcodeCompareStr := FastcodeCompareStrSSE2;
                      FastcodeCompareText := FastcodeCompareTextSSE2;
                      FastcodeFillChar := FastcodeFillCharSSE2;
                      FastcodeLowerCase := FastcodeLowerCaseSSE2;
                      FastcodePos := FastcodePosSSE2;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExSSE2;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompSSE2;
                      FastcodeStrCopy := FastcodeStrCopySSE2;
                      FastcodeStrIComp := FastcodeStrICompSSE2;
                      FastcodeStrLen := FastcodeStrLenSSE2;
                      FastcodeStrToInt32 := FastcodeStrToInt32SSE2;
                      FastcodeUpperCase := FastcodeUpperCaseSSE2;
                    end;
            fctPMD: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplacePMD;
                      FastcodeCompareMem := FastcodeCompareMemPMD;
                      FastcodeCompareStr := FastcodeCompareStrPMD;
                      FastcodeCompareText := FastcodeCompareTextPMD;
                      FastcodeFillChar := FastcodeFillCharPMD;
                      FastcodeLowerCase := FastcodeLowerCasePMD;
                      FastcodePos := FastcodePosPMD;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExPMD;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompPMD;
                      FastcodeStrCopy := FastcodeStrCopyPMD;
                      FastcodeStrIComp := FastcodeStrICompPMD;
                      FastcodeStrLen := FastcodeStrLenPMD;
                      FastcodeStrToInt32 := FastcodeStrToInt32PMD;
                      FastcodeUpperCase := FastcodeUpperCasePMD;
                    end;
            fctPMY: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplacePMY;
                      FastcodeCompareMem := FastcodeCompareMemPMY;
                      FastcodeCompareStr := FastcodeCompareStrPMY;
                      FastcodeCompareText := FastcodeCompareTextPMY;
                      FastcodeFillChar := FastcodeFillCharPMY;
                      FastcodeLowerCase := FastcodeLowerCasePMY;
                      FastcodePos := FastcodePosPMY;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExPMY;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompPMY;
                      FastcodeStrCopy := FastcodeStrCopyPMY;
                      FastcodeStrIComp := FastcodeStrICompPMY;
                      FastcodeStrLen := FastcodeStrLenPMY;
                      FastcodeStrToInt32 := FastcodeStrToInt32PMY;
                      FastcodeUpperCase := FastcodeUpperCasePMY;
                    end;
            fctP4N: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceP4N;
                      FastcodeCompareMem := FastcodeCompareMemP4N;
                      FastcodeCompareStr := FastcodeCompareStrP4N;
                      FastcodeCompareText := FastcodeCompareTextP4N;
                      FastcodeFillChar := FastcodeFillCharP4N;
                      FastcodeLowerCase := FastcodeLowerCaseP4N;
                      FastcodePos := FastcodePosP4N;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExP4N;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompP4N;
                      FastcodeStrCopy := FastcodeStrCopyP4N;
                      FastcodeStrIComp := FastcodeStrICompP4N;
                      FastcodeStrLen := FastcodeStrLenP4N;
                      FastcodeStrToInt32 := FastcodeStrToInt32P4N;
                      FastcodeUpperCase := FastcodeUpperCaseP4N;
                    end;
            fctP4R: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceP4R;
                      FastcodeCompareMem := FastcodeCompareMemP4R;
                      FastcodeCompareStr := FastcodeCompareStrP4R;
                      FastcodeCompareText := FastcodeCompareTextP4R;
                      FastcodeFillChar := FastcodeFillCharP4R;
                      FastcodeLowerCase := FastcodeLowerCaseP4R;
                      FastcodePos := FastcodePosP4R;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExP4R;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompP4R;
                      FastcodeStrCopy := FastcodeStrCopyP4R;
                      FastcodeStrIComp := FastcodeStrICompP4R;
                      FastcodeStrLen := FastcodeStrLenP4R;
                      FastcodeStrToInt32 := FastcodeStrToInt32P4R;
                      FastcodeUpperCase := FastcodeUpperCaseP4R;
                    end;
          fctAmd64: begin
                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceAmd64;
                      FastcodeCompareMem := FastcodeCompareMemAmd64;
                      FastcodeCompareStr := FastcodeCompareStrAmd64;
                      FastcodeCompareText := FastcodeCompareTextAmd64;
                      FastcodeFillChar := FastcodeFillCharAmd64;
                      FastcodeLowerCase := FastcodeLowerCaseAmd64;
                      FastcodePos := FastcodePosAmd64;
                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExAmd64;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompAmd64;
                      FastcodeStrCopy := FastcodeStrCopyAmd64;
                      FastcodeStrIComp := FastcodeStrICompAmd64;
                      FastcodeStrLen := FastcodeStrLenAmd64;
                      FastcodeStrToInt32 := FastcodeStrToInt32Amd64;
                      FastcodeUpperCase := FastcodeUpperCaseAmd64;
                    end;
     fctAmd64_SSE3: begin

                      FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceAmd64_SSE3;

                      FastcodeCompareMem := FastcodeCompareMemAmd64_SSE3;

                      FastcodeCompareStr := FastcodeCompareStrAmd64_SSE3;

                      FastcodeCompareText := FastcodeCompareTextAmd64_SSE3;

                      FastcodeFillChar := FastcodeFillCharAmd64_SSE3;

                      FastcodeLowerCase := FastcodeLowerCaseAmd64_SSE3;

                      FastcodePos := FastcodePosAmd64_SSE3;

                      {$IFDEF Delphi7Plus}
                      FastcodePosEx := FastcodePosExAmd64_SSE3;
                      {$ENDIF}
                      FastcodeStrComp := FastcodeStrCompAmd64_SSE3;
                      FastcodeStrCopy := FastcodeStrCopyAmd64_SSE3;
                      FastcodeStrIComp := FastcodeStrICompAmd64_SSE3;
                      FastcodeStrLen := FastcodeStrLenAmd64_SSE3;
                      FastcodeStrToInt32 := FastcodeStrToInt32Amd64_SSE3;
                      FastcodeUpperCase := FastcodeUpperCaseAmd64_SSE3;
                    end;

  end;

{$ENDIF}

{$IFDEF FastcodeIA32}
  {$IFDEF FastcodeSizePenalty}
    FastcodeAnsiStringReplace := FastCodeAnsiStringReplaceIA32SizePenalty;
    FastcodeCompareMem := FastcodeCompareMemIA32SizePenalty;

    FastcodeCompareStr := FastcodeCompareStrIA32SizePenalty;

    FastcodeCompareText := FastcodeCompareTextIA32SizePenalty;

    FastcodeFillChar := FastcodeFillCharIA32SizePenalty;

    FastcodeLowerCase := FastcodeLowerCaseIA32SizePenalty;

    FastcodePos := FastcodePosIA32SizePenalty;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExIA32SizePenalty;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompIA32SizePenalty;
    FastcodeStrCopy := FastcodeStrCopyIA32SizePenalty;
    FastcodeStrIComp := FastcodeStrICompIA32SizePenalty;
    FastcodeStrLen := FastcodeStrLenIA32SizePenalty;
    FastcodeStrStrToInt32 := FastcodeStrToInt32IA32SizePenalty;
    FastcodeUpperCase := FastcodeUpperCaseIA32SizePenalty;
  {$ELSE}
    FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceIA32;
    FastcodeCompareMem := FastcodeCompareMemIA32;

    FastcodeCompareStr := FastcodeCompareStrIA32;

    FastcodeCompareText := FastcodeCompareTextIA32;

    FastcodeFillChar := FastcodeFillCharIA32;

    FastcodeLowerCase := FastcodeLowerCaseIA32;

    FastcodePos := FastcodePosIA32;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExIA32;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompIA32;
    FastcodeStrCopy := FastcodeStrCopyIA32;
    FastcodeStrIComp := FastcodeStrICompIA32;
    FastcodeStrLen := FastcodeStrLenIA32;
    FastcodeStrToInt32 := FastcodeStrStrToInt32IA32;
    FastcodeUpperCase := FastcodeUpperCaseIA32;
  {$ENDIF}
{$ENDIF}

{$IFDEF FastcodeMMX}
  FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceMMX;
  FastcodeCompareMem := FastcodeCompareMemMMX;

  FastcodeCompareStr := FastcodeCompareStrMMX;

  FastcodeCompareText := FastcodeCompareTextMMX;

  FastcodeFillChar := FastcodeFillCharMMX;

  FastcodeLowerCase := FastcodeLowerCaseMMX;

  FastcodePos := FastcodePosMMX;

  {$IFDEF Delphi7Plus}
  FastcodePosEx := FastcodePosExMMX;
  {$ENDIF}
  FastcodeStrComp := FastcodeStrCompMMX;
  FastcodeStrCopy := FastcodeStrCopyMMX;
  FastcodeStrIComp := FastcodeStrICompMMX;
  FastcodeStrLen := FastcodeStrLenMMX;
  FastcodeStrToInt32 := FastcodeStrToInt32MMX;
  FastcodeUpperCase := FastcodeUpperCaseMMX;
{$ENDIF}

{$IFDEF FastcodeSSE}
  {$IFDEF FastcodeSizePenalty}
    FastcodeAnsiStringReplace := FastCodeAnsiStringReplaceSSESizePenalty;
    FastcodeCompareMem := FastcodeCompareMemSSESizePenalty;

    FastcodeCompareStr := FastcodeCompareStrSSESizePenalty;

    FastcodeCompareText := FastcodeCompareTextSSESizePenalty;

    FastcodeFillChar := FastcodeFillCharSSESizePenalty;

    FastcodeLowerCase := FastcodeLowerCaseSSESizePenalty;

    FastcodePos := FastcodePosSSESizePenalty;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExSSESizePenalty;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompSSESizePenalty;
    FastcodeStrCopy := FastcodeStrCopySSESizePenalty;
    FastcodeStrIComp := FastcodeStrICompSSESizePenalty;
    FastcodeStrLen := FastcodeStrLenSSESizePenalty;
    FastcodeStrToInt32 := FastcodeStrToInt32SSESizePenalty;
    FastcodeUpperCase := FastcodeUpperCaseSSESizePenalty;
  {$ELSE}
    FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceSSE;
    FastcodeCompareMem := FastcodeCompareMemSSE;

    FastcodeCompareStr := FastcodeCompareStrSSE;

    FastcodeCompareText := FastcodeCompareTextSSE;

    FastcodeFillChar := FastcodeFillCharSSE;

    FastcodeLowerCase := FastcodeLowerCaseSSE;

    FastcodePos := FastcodePosSSE;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExSSE;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompSSE;
    FastcodeStrCopy := FastcodeStrCopySSE;
    FastcodeStrIComp := FastcodeStrICompSSE;
    FastcodeStrLen := FastcodeStrLenSSE;
    FastcodeStrToInt32 := FastcodeStrToInt32SSE;
    FastcodeUpperCase := FastcodeUpperCaseSSE;
  {$ENDIF}
{$ENDIF}

{$IFDEF FastcodeSSE2}
  FastcodeAnsiStringReplace := FastcodeAnsiStringReplaceSSE2;
  FastcodeCompareMem := FastcodeCompareMemSSE2;

  FastcodeCompareStr := FastcodeCompareStrSSE2;

  FastcodeCompareText := FastcodeCompareTextSSE2;

  FastcodeFillChar := FastcodeFillCharSSE2;

  FastcodeLowerCase := FastcodeLowerCaseSSE2;

  FastcodePos := FastcodePosSSE2;

  {$IFDEF Delphi7Plus}
  FastcodePosEx := FastcodePosExSSE2;
  {$ENDIF}
  FastcodeStrComp := FastcodeStrCompSSE2;
  FastcodeStrCopy := FastcodeStrCopySSE2;
  FastcodeStrIComp := FastcodeStrICompSSE2;
  FastcodeStrLen := FastcodeStrLenSSE2;
  FastcodeStrToInt32 := FastcodeStrToInt32SSE2;
  FastcodeUpperCase := FastcodeUpperCaseSSE2;
{$ENDIF}

{$IFDEF FastcodePascal}
  {$IFDEF FastcodeSizePenalty}
    FastcodeAnsiStringReplace := FastCodeAnsiStringReplacePascalSizePenalty;
    FastcodeCompareMem := FastcodeCompareMemPascalSizePenalty;

    FastcodeCompareStr := FastcodeCompareStrPascalSizePenalty;

    FastcodeCompareText := FastcodeCompareTextPascalSizePenalty;

    FastcodeFillChar := FastcodeFillCharPascalSizePenalty;

    FastcodeLowerCase := FastcodeLowerCasePascalSizePenalty;

    FastcodePos := FastcodePosPascalSizePenalty;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExPascalSizePenalty;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompPascalSizePenalty;
    FastcodeStrCopy := FastcodeStrCopyPascalSizePenalty;
    FastcodeStrIComp := FastcodeStrICompPascalSizePenalty;
    FastcodeStrLen := FastcodeStrLenPascalSizePenalty;
    FastcodeStrToInt32 := FastcodeStrToInt32PascalSizePenalty;
    FastcodeUpperCase := FastcodeUpperCasePascalSizePenalty;
  {$ELSE}
    FastcodeAnsiStringReplace := FastcodeAnsiStringReplacePascal;
    FastcodeCompareMem := FastcodeCompareMemPascal;

    FastcodeCompareStr := FastcodeCompareStrPascal;

    FastcodeCompareText := FastcodeCompareTextPascal;

    FastcodeFillChar := FastcodeFillCharPascal;

    FastcodeLowerCase := FastcodeLowerCasePascal;

    FastcodePos := FastcodePosPascal;

    {$IFDEF Delphi7Plus}
    FastcodePosEx := FastcodePosExPascal;
    {$ENDIF}
    FastcodeStrComp := FastcodeStrCompPascal;
    FastcodeStrCopy := FastcodeStrCopyPascal;
    FastcodeStrIComp := FastcodeStrICompPascal;
    FastcodeStrLen := FastcodeStrLenPascal;
    FastcodeStrToInt32 := FastcodeStrToInt32Pascal;
    FastcodeUpperCase := FastcodeUpperCasePascal;
  {$ENDIF}
{$ENDIF}

finalization
  UninstallFastCode;

end.
