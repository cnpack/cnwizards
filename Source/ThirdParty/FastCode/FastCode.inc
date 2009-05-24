// Fastcode Library definitions //

// Define this if you want to use fctIA32SizePenalty instead of 
// fctIA32, fctSSESizePenalty instead of fctSSE, 
// FastcodePascalSizePenalty instead of FastcodePascal}
{.$DEFINE FastcodeSizePenalty}

// Define this to disable RTL Patching}
{.$DEFINE FastcodeNoRtlPatch}

// Define either FastcodeCPUID or one of next five}
{$IFNDEF DisableFastCode}
  {$DEFINE FastcodeCPUID}
  {.$DEFINE FastcodeIA32}
  {.$DEFINE FastcodeMMX}
  {.$DEFINE FastcodeSSE}
  {.$DEFINE FastcodeSSE2}
  {.$DEFINE FastcodePascal}
{$ENDIF}

// Default to FastcodeIA32 / FastcodeIA32SizePenalty if No Fastcode 
// Compile Option Selected
{$IFNDEF FastcodeIA32}
 {$IFNDEF FastcodeMMX}
  {$IFNDEF FastcodeSSE}
   {$IFNDEF FastcodeSSE2}
    {$IFNDEF FastcodePascal}
     {$IFNDEF FastcodeCPUID}
       {$DEFINE FastcodeIA32}
     {$ENDIF}
    {$ENDIF}
   {$ENDIF}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

// Ensure Only One Fastcode Compile Option (Best) is Selected
{$IFDEF FastcodeCPUID}
  {$UNDEF FastcodeMMX}
  {$UNDEF FastcodeSSE}
  {$UNDEF FastcodeSSE2}
  {$UNDEF FastcodeIA32}
  {$UNDEF FastcodePascal}
{$ENDIF}

{$IFDEF FastcodeSSE2}
  {$UNDEF FastcodeIA32}
  {$UNDEF FastcodePascal}
  {$UNDEF FastcodeMMX}
  {$UNDEF FastcodeSSE}
  {$UNDEF FastcodeCPUID}
{$ENDIF}

{$IFDEF FastcodeSSE}
  {$UNDEF FastcodeIA32}
  {$UNDEF FastcodePascal}
  {$UNDEF FastcodeMMX}
  {$UNDEF FastcodeSSE2}
  {$UNDEF FastcodeCPUID}
{$ENDIF}

{$IFDEF FastcodeMMX}
  {$UNDEF FastcodeIA32}
  {$UNDEF FastcodePascal}
  {$UNDEF FastcodeIA32}
  {$UNDEF FastcodeSSE}
  {$UNDEF FastcodeSSE2}
  {$UNDEF FastcodeCPUID}
{$ENDIF}

{$IFDEF FastcodeIA32}
  {$UNDEF FastcodePascal}
  {$UNDEF FastcodeMMX}
  {$UNDEF FastcodeSSE}
  {$UNDEF FastcodeSSE2}
  {$UNDEF FastcodeCPUID}
{$ENDIF}

// Delphi Version definitions

{$IFDEF Ver80}
  {$DEFINE Delphi1}
{$ENDIF}

{$IFDEF Ver90}
  {$DEFINE Delphi2}
{$ENDIF}

{$IFDEF Ver100}
  {$DEFINE Delphi3}
{$ENDIF}

{$IFDEF Ver120}
  {$DEFINE Delphi4}
{$ENDIF}

{$IFDEF Ver130}
  {$DEFINE Delphi5}
{$ENDIF}

{$IFDEF Ver140}
  {$DEFINE Delphi6}
{$ENDIF}

{$IFDEF Ver150}
  {$DEFINE Delphi7}
{$ENDIF}

{$IFDEF Ver160}
  {$DEFINE Delphi8}
{$ENDIF}

{$IFDEF Ver170}
  {$DEFINE Delphi2005}
{$ENDIF}

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF (CompilerVersion >= 18.0) and (CompilerVersion < 19.0)}
     {$DEFINE Delphi2006}
     {$DEFINE INLINE}
  {$IFEND}
  {$IF (CompilerVersion >= 19.0) and (CompilerVersion < 20.0)}
     {$DEFINE Delphi2007}
     {$DEFINE INLINE}
  {$IFEND}
{$ENDIF}

{$IFDEF Delphi2007}
  {$DEFINE Delphi2007Plus}
{$ENDIF}

{$IFDEF Delphi2007Plus}
  {$DEFINE Delphi2006Plus}
{$ENDIF}

{$IFDEF Delphi2006}
  {$DEFINE Delphi2006Plus}
{$ENDIF}

{$IFDEF Delphi2006Plus}
  {$DEFINE Delphi2005Plus}
{$ENDIF}

{$IFDEF Delphi2005}
  {$DEFINE Delphi2005Plus}
{$ENDIF}

{$IFDEF Delphi2005Plus}
  {$DEFINE Delphi7Plus}
{$ENDIF}

{$IFDEF Delphi7}
  {$DEFINE Delphi7Plus}
{$ENDIF}

{$IFDEF Delphi7Plus}
  {$DEFINE Delphi6Plus}
{$ENDIF}

{$IFDEF Delphi6}
  {$DEFINE Delphi6Plus}
{$ENDIF}

{$IFDEF Delphi6Plus}
  {$DEFINE Delphi5Plus}
{$ENDIF}

{$IFDEF Delphi5}
  {$DEFINE Delphi5Plus}
{$ENDIF}

{$IFDEF Delphi5Plus}
  {$DEFINE Delphi4Plus}
{$ENDIF}

{$IFDEF Delphi4}
  {$DEFINE Delphi4Plus}
{$ENDIF}

{$IFDEF Delphi4Plus}
  {$DEFINE Delphi3Plus}
{$ENDIF}

{$IFDEF Delphi3}
  {$DEFINE Delphi3Plus}
{$ENDIF}

{$IFDEF Delphi3Plus}
  {$DEFINE Delphi2Plus}
{$ENDIF}

{$IFDEF Delphi2}
  {$DEFINE Delphi2Plus}
{$ENDIF}

{$IFDEF Delphi2Plus}
  {$DEFINE Delphi1Plus}
{$ENDIF}

{$IFDEF Delphi1}
  {$DEFINE Delphi1Plus}
{$ENDIF}
