
unit uPSR_dateutils;
{$I PascalScript.inc}
interface
uses
  SysUtils, uPSRuntime;



procedure RegisterDateTimeLibrary_R(S: TPSExec);

implementation

function TryEncodeDate(Year, Month, Day: Word; var Date: TDateTime): Boolean;
begin
  try
    Date := EncodeDate(Year, Month, Day);
    Result := true;
  except
    Result := false;
  end;
end;

function TryEncodeTime(Hour, Min, Sec, MSec: Word; var Time: TDateTime): Boolean;
begin
  try
    Time := EncodeTime(hour, Min, Sec, MSec);
    Result := true;
  except
    Result := false;
  end;
end;

function DateTimeToUnix(D: TDateTime): Int64;
begin
  Result := Round((D - 25569) * 86400);
end;

function UnixToDateTime(U: Int64): TDateTime;
begin
  Result := U / 86400 + 25569;
end;

procedure RegisterDateTimeLibrary_R(S: TPSExec);
begin
  S.RegisterDelphiFunction(@EncodeDate, 'ENCODEDATE', cdRegister);
  S.RegisterDelphiFunction(@EncodeTime, 'ENCODETIME', cdRegister);
  S.RegisterDelphiFunction(@TryEncodeDate, 'TRYENCODEDATE', cdRegister);
  S.RegisterDelphiFunction(@TryEncodeTime, 'TRYENCODETIME', cdRegister);
  S.RegisterDelphiFunction(@DecodeDate, 'DECODEDATE', cdRegister);
  S.RegisterDelphiFunction(@DecodeTime, 'DECODETIME', cdRegister);
  S.RegisterDelphiFunction(@DayOfWeek, 'DAYOFWEEK', cdRegister);
  S.RegisterDelphiFunction(@Date, 'DATE', cdRegister);
  S.RegisterDelphiFunction(@Time, 'TIME', cdRegister);
  S.RegisterDelphiFunction(@Now, 'NOW', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToUnix, 'DATETIMETOUNIX', cdRegister);
  S.RegisterDelphiFunction(@UnixToDateTime, 'UNIXTODATETIME', cdRegister);
  S.RegisterDelphiFunction(@DateToStr, 'DATETOSTR', cdRegister);
  S.RegisterDelphiFunction(@FormatDateTime, 'FORMATDATETIME', cdRegister);
  S.RegisterDelphiFunction(@StrToDate, 'STRTODATE', cdRegister);
end;

end.
