//==============================================================================
// π¶ƒ‹…Ë÷√
//==============================================================================

{$IFDEF COMPILER5_UP}
  {$DEFINE SUPPORT_PASCAL_SCRIPT}
  {$DEFINE SUPPORT_PRJ_BACKUP}
{$ENDIF}

{$IFNDEF IS_MASTER}
  {$UNDEF SUPPORT_PASCAL_SCRIPT}
{$ENDIF}

{$IFDEF DELPHI2007_UP}
  {$UNDEF CNWIZARDS_CNFASTCODEWIZARD}
{$ENDIF}
