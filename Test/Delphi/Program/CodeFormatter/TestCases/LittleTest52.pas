unit LittleTest52;

{ AFS October 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

implementation

{ do preprocessor statements have to be valid, if they are preprocessed out }

{$UNDEF FOO}

// this condition is false
{$IFDEF FOO}

  // apparently not - this would be 'invalid compier directive' if it was not ifdefed out
 {$WARRAWAK}

{$ENDIF}

end.
