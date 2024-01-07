//==============================================================================
// π¶ƒ‹…Ë÷√
//==============================================================================

{$IFDEF COMPILER5_UP}
  {$DEFINE SUPPORT_PASCAL_SCRIPT}
{$ENDIF}

{$IFNDEF IS_MASTER}
  {$UNDEF SUPPORT_PASCAL_SCRIPT}
{$ENDIF}

{$IFDEF DELPHI2007_UP}
  {$UNDEF CNWIZARDS_CNFASTCODEWIZARD}
{$ENDIF}

{$IFDEF COMPILER9_UP}
  {$DEFINE USE_DDETOURS_HOOK}
{$ENDIF}

{$IFDEF BDS2010_UP}
  {$DEFINE SUPPORT_PALETTE_ENHANCE}     // CnPack Supports 2010 New Style Component Palette Enhancement
{$ELSE}
  {$IFNDEF COMPILER8_UP}
    {$DEFINE SUPPORT_PALETTE_ENHANCE}   // CnPack Supports 7 old Style Component Palette Enhancement
  {$ENDIF}
{$ENDIF}

