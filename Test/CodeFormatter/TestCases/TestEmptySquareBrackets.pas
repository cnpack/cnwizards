unit TestEmptySquareBrackets;

{ AFS August 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

type
  TMonkey = (gibbon, baboon, vervet, mandril);
  TBarrelOfMonkeys = set of TMonkey;

const
  TFoo: TBarrelOfMonkeys = [];

implementation

end.