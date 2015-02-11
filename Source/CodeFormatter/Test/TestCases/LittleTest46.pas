unit LittleTest46;

interface

{ AFS 20 September 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

{ some pointer types }
type
  PInteger = ^Integer;
  P_Char = ^Char;

  PPtr = ^Pointer;
  PPPTr = ^PPtr;
  PFile = ^File;

  TFoo = (fish, wibble, spon);

  PFoo = ^TFoo;

implementation

end.
