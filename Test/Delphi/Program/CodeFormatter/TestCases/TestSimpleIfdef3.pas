unit TestSimpleIfdef3;

{ AFS 23 August 2002
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

{$UNDEF FOO}

  {$IFDEF FOO}
    A little piece of text 
  {$ELSE}

  {$ENDIF}

end.
