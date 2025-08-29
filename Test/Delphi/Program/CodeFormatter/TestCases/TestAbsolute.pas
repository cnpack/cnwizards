unit TestAbsolute;

{ AFS 11 March 2K

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  Test the 'absolute' keyword
}


interface

implementation
                                                      
uses Classes;


{ a hack extracted from a much larger program
  not easy to cast a method pointer without the compiler
  thinking you want to call it

 Double is 8 bytes, same size as a object method pointer
}
function MethodPointerToDouble (pmMethod: TNotifyEvent): double;
var
  lmMethod: TNotifyEvent;
  ldCast: double absolute pmMethod;
begin
  lmMethod := pmMethod;
  Result := ldCast
end;

end.
 