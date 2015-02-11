unit TestSimpleIfDef6;

interface

implementation

{$DEFINE FOO}

{$IFDEF MSWINDOWS}
uses Windows;
{$ELSE}
   { even if it's not parsed, the block starts and ends must match
     the unparsed block ends at the *second* endif }
  {$IFDEF FOO} 
    warrawak1
  {$ENDIF}
    warrawak2
{$ENDIF}

end.
