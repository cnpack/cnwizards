//==============================================================================
// 功能设置
//==============================================================================

{$IFDEF COMPILER5_UP}
  {$DEFINE SUPPORT_PASCAL_SCRIPT}
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

{$IFDEF DELPHI103_RIO_UP}
  {$DEFINE FULL_IOTADEBUGGERVISUALIZER_250}
  // IOTADebuggerVisualizer250 是 D102T Update 包（可能是 10.2.2）中引入的，不支持低版本的如 10.2.1 与 10.2
  // 因而为了保险起见，定义 10.3 或以上才支持该接口
{$ENDIF}

