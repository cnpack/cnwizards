unit TestTry;

{ AFS March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests layout of try..except and try..finally blocks
}

interface

implementation

uses Dialogs, SysUtils, Math;

procedure TestRaise;
begin
  raise Exception.Create('Monkey error: please insert soy');
end;


procedure TestRaiseAt;
begin
  raise Exception.Create('Shatner error: please insert toupee') at @TestRaiseAt;
end;

procedure TestTryRaise;
begin

try
  ShowMessage ('Start'); 
 except 
  ShowMessage ('except'); 
  raise
 end;

end;


procedure TestTryProc;
begin

try ShowMessage ('Start'); try ShowMessage ('trying');
try ShowMessage ('still trying'); finally ShowMessage ('going...'); end;
except ShowMessage ('except'); end;
finally ShowMessage ('Finally!'); end;

end;

procedure Simple;
begin

try
TesttryProc;
except
end;

try
TesttryProc;
except
SHowMessage('It Failed');
end;


end;


procedure ExceptBlock;
begin
try
TesttryProc;
except
on E: Exception do
begin
ShowMessage('There was an exception: ' + E.Message);
end;

end;
end;

procedure complex;
var
liLoop: integer;
begin
try
liLoop := 0;
while liLoop < 10 do
begin
TesttryProc;
inc(liloop);
end;
except
on E: Exception do
begin
ShowMessage('There was an exception: ' + E.Message);
end;

end;
end;

procedure TestSimpleElse;
begin
  try
    TestTryProc;
  except
    on E2: EInvalidArgument do
      ShowMessage('There was an invalid arg exception: ' + E2.Message);
    else
      Raise;
  end;

  try
    TestTryProc;
  except
    on E: EMathError do
    begin
      ShowMessage('There was a math error: ' + E.Message);
    end
    else
    begin
      Raise;
    end;
  end;

  try
    TestTryProc;
  except
    on E: EMathError do
    begin
      ShowMessage('There was a math error: ' + E.Message);
    end
    else ;
  end;

  try
    TestTryProc;
  except
    on E: EMathError do
    begin
      ShowMessage('There was a math error: ' + E.Message);
    end
    else
    begin
    end;
  end;

end;


procedure MoreComplexExceptionHandler;
var
  liLoop: integer;
begin
  try
    TesttryProc;
  except
    on E2: EInvalidArgument do
      ShowMessage('There was an invalid arg exception: ' + E2.Message);
    on E: EMathError do
    begin
      ShowMessage('There was an exception: ' + E.Message);
    end;
    on EOverflow	do
      ShowMessage('There was an underflow exception');
    else
      Raise;
  end;
end;

procedure TestReraise;
begin
  try
    TesttryProc;
  except
    ShowMessage('There was an exception');
    Raise;
  end;
end;

procedure TestReraise2;
var
  li: integer;
begin
  try
    TesttryProc;
  except
    ShowMessage('There was an exception');
    // whole buncha statements
    ShowMessage('There was an exception');
    li := 0;
    ShowMessage('There was an exception');
    for li := 0 to 10 do
      ShowMessage('There was an exception');
    begin
      TesttryProc;
    end;
    Raise;
  end;
end;

procedure TestBigFinally;
var
  li: integer;
begin
  try
    TesttryProc;
  finally
    ShowMessage('There was an exception');
    // whole buncha statements
    ShowMessage('There was an exception');
    li := 0;
    ShowMessage('There was an exception');
    for li := 0 to 10 do
      ShowMessage('There was an exception');
    begin
      TesttryProc;
    end;
  end;
end;

end.
