unit TestArray;

{ AFS 23 May 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests array decls
}

interface

type
  TSomeEnum = (eFoo, eBar, eBaz, eFish, eWibble, eSpon, eMonkey, eSoy, eShatner);

  TMyArray = array[0..100] of integer;
  TFunnythreeD = array[112..456, TSomeEnum, Boolean] of integer;

var
  foo: TMyArray;
  Puppy: array[12..120] of integer;
  BoolArray: array[Boolean] of Boolean;
  SomeMap: array[TSomeEnum] of integer;

  twoD: array[1..100, 1..100] of integer;
  threeD: array[1..100, 1..100, 1..100] of integer;
  FunnythreeD: array[112..456, TSomeEnum, Boolean] of integer;

implementation

end.
