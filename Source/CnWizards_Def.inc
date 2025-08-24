//==============================================================================
// 功能设置
//==============================================================================

{$IFDEF FPC}
  // 专家包编译时如果是 FPC 则表示要安装到 Lazarus 里，但 cnvcl 不是
  {$DEFINE LAZARUS}
{$ENDIF}

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
  // 暂时只在 64 位的 D120 下使用 11.3 之后新增的 ToolsAPI.Editor 接口，未来 13 再加
  {$DEFINE USE_CODEEDITOR_SERVICE}
  {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF DELPHI}
  // 非独立的 Delphi 编译，表示有 OTA 接口
  {$DEFINE DELPHI_OTA}
{$ENDIF}

{$IFDEF STAND_ALONE}
  {$UNDEF USE_CODEEDITOR_SERVICE}
  // 独立的则表示没有 OTA 接口
  {$UNDEF DELPHI_OTA}
{$ENDIF}
