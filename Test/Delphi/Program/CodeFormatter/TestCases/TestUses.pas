unit TestUses;

{ AFS 28 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests comments the uses clause
}

interface

uses { as usual } SysUtils, { some delphi stuff } Comctrls,
  { a multi-line comment
    in the uses clause
    for testing
  }
Classes, // a single line comment
{ another unit } Windows
  ;


implementation

uses
{ delphi } ActiveX,
{ local } TestClassLines,
TestCast;


end.
