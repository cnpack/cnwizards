unit TestSimpleIfdef;

{ AFS 22 August 2002
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

{$DEFINE FOO}

{$IFDEF FOO}

{$ELSE}
  for this is not object-pascal, sha la la la la.
{$ENDIF}

end.
