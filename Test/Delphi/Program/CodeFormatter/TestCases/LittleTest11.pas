unit LittleTest11;

interface

{ AFS 8 July 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  test a procedure constant with a value }


uses Classes;

const
  Foo: procedure = nil;
  Bar: function: Boolean of object = nil;
  Fish: procedure (const Monkey: string;
    const Shatner: array of TObject; Soy: TComponentClass) = nil;


implementation

end.
