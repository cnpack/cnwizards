unit TestPointers;

{ AFS 28 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests pointer operators
}
interface

type
  TFred = record
    fi1: integer;
    fc2: Currency;
    Ganzfeld: string;
  end;

  pTFred = ^TFred;
  ppTFred = ^pTFred;


procedure Stuff;

implementation

procedure Stuff;
var
  f: TFred;
  pf: PTFred;
  ppf: ppTFred;
  li: integer;
begin
pf := @f;
    ppf := @pf;

  pf := ppf^;
   f := pf^;

    f := ppf^^;

pf := @f;
    ppf := @pf;
 li := 3;

end;

end.
