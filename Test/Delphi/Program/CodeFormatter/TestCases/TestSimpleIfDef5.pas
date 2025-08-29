unit TestSimpleIfDef5;

interface

implementation

{$IFDEF MSWINDOWS}
uses Windows;
{$ELSE}
  {$IF FOO}
  uses LibFoo;
  {$IFEND}
{$ENDIF}

end.
