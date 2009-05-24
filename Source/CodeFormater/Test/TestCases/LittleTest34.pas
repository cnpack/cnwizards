unit LittleTest34;

{ AFS 17 Aug 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

{ 'out' is a valid variable name that occurs in tlb generated interfaces }
type
  IAmAnInterface = interface(IDispatch)
    ['{081A08A5-AC8E-4C99-89A4-6175E6320719}']
    procedure Monkey(out Out: OleVariant); safecall;
    procedure Soy(var Out: integer); safecall;
  end;


implementation

end.                     
