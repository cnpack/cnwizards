unit TestRaise;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
 to test the 'raise' keyword }

interface

implementation

uses SysUtils;

{ inspired by code in inifiles }
function Test1: TDateTime;
var
  DateStr: string;
begin
  DateStr := 'Fooo';
  Result := 0.0;

  try
    Result := StrToDate(DateStr);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function Test1_2: TDateTime;
var
  DateStr: string;
begin
  DateStr := 'Fooo';
  Result := 0.0;

  try
    Result := StrToDate(DateStr);
  except
      // Ignore EConvertError exceptions
    on EConvertError do
      ;
    // and math errors
    on EMathError do
    else
      raise;
  end;
end;

function Test2: TDateTime;
var
  DateStr: string;
begin
  DateStr := 'Fooo';
  Result := Now;

  try
    Result := StrToDate(DateStr);
  except
    on EConvertError do
      if DateStr = '' then
        raise
      else
  end;
end;

function Test3: TDateTime;
var
  DateStr: string;
begin
  DateStr := 'Fooo';
  Result := Now;

  try
    Result := StrToDate(DateStr);
  except
    on EConvertError do
      if DateStr = '' then
        raise
      else
        raise
  end;
end;

function Test4: TDateTime;
var
  DateStr: string;
begin
  DateStr := 'Fooo';
  Result := Now;

  try
    Result := StrToDate(DateStr);
  except
    on EConvertError do
      if DateStr = '' then
        raise
      else if DateStr = 'foo' then
      begin
        raise
      end
      else
        raise
  end;
end;

procedure TestIf(const pi: integer);
begin
  if pi > 4 then
  else
  begin    
  end;
end;

end.
