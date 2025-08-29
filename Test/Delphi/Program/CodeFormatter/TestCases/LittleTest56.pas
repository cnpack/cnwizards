unit LittleTest56;

{ AFS 28 Oct 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

const Foo = True;

{$IF not Foo}

  warrawak

{$ELSE}

const bar = 3;
{$IFEND}

end.
 