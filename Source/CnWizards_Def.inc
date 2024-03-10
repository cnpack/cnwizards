//==============================================================================
// 功能设置
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

  // DEBUG and DDETOURS conflicts under D2007 or below. Don't know why.
  {$IFDEF DEBUG}
    {$IFNDEF COMPILER12_UP}
      {$UNDEF USE_DDETOURS_HOOK}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF BDS2010_UP}
  {$DEFINE SUPPORT_PALETTE_ENHANCE}     // CnPack Supports 2010 New Style Component Palette Enhancement
{$ELSE}
  {$IFNDEF COMPILER8_UP}
    {$DEFINE SUPPORT_PALETTE_ENHANCE}   // CnPack Supports 7 old Style Component Palette Enhancement
  {$ENDIF}
{$ENDIF}

{$IFDEF DELPHIXE_UP}
  {$DEFINE CNWIZARDS_DEBUG_EXTERNALVIEWER}  // Delphi XE 起支持 DebugVisualizer，包括 Replacer 和 External Viewer
{$ENDIF}
