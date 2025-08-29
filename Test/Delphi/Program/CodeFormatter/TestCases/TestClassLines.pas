unit TestClassLines;

{ AFS 23 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit test indentation of run-on-lines in class functions
 and thereby recognition of class functions & class headers
 Rather specialised, isn't it?
}

interface

type

TSomeClass = class
class
function
dink:
boolean;
end;


implementation

{ TSomeClass }

class function TSomeClass.dink: boolean;
begin
  result := False;
end;

end.
