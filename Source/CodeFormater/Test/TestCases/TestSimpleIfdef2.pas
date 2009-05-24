unit TestSimpleIfdef2;

{ AFS 22 August 2002
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

uses
{$IFDEF MSWINDOWS}
SysUtils
{$ELSE}
FooLinux
{$ENDIF}
;

end.
