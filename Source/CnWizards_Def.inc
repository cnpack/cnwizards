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

{$IFDEF OTA_CODEEDITOR_SERVICE}
  {$IFDEF DELPHI120_ATHENS}
  {$IFDEF WIN64}
    // 在 64 位的 D120 使用 11.3 之后新增的 ToolsAPI.Editor 接口
    {$DEFINE USE_CODEEDITOR_SERVICE}
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DELPHI130_FLORENCE_UP}
    // 在 D130 及以上版本使用 11.3 之后新增的 ToolsAPI.Editor 接口，无论 32 位还是 64 位
    {$DEFINE USE_CODEEDITOR_SERVICE}
  {$ENDIF}
{$ENDIF}

{$IFDEF DELPHI}
  // 非独立的 Delphi 编译，表示有 OTA 接口
  {$DEFINE DELPHI_OTA}
{$ENDIF}

{$IFDEF BCB5OR6}
  // 非独立的 BCB5/6 编译，也表示有 OTA 接口
  {$DEFINE DELPHI_OTA}
{$ENDIF}

{$IFDEF STAND_ALONE}
  {$UNDEF USE_CODEEDITOR_SERVICE}
  // 独立的则表示没有 OTA 接口
  {$UNDEF DELPHI_OTA}
  // 独立的表示没有 LAZARUS 接口
  {$UNDEF LAZARUS}
{$ENDIF}

{$IFDEF FPC}
  // 非独立的 FPC 编译，表示有 Lazarus 接口
  {$DEFINE LAZARUS}
  // Lazarus 下也支持 HDPI，包括独立程序
  {$DEFINE IDE_SUPPORT_HDPI}
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}
  {$DEFINE DELPHI_IDE_WITH_HDPI}
{$ENDIF}
{$IFDEF LAZARUS}
  {$DEFINE LAZARUS_IDE_WITH_HDPI}
{$ENDIF}
{$ENDIF}
