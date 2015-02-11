unit TestWith;

{ AFS 28 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests the with statement
 I don't like the with statement myself and avoid using it
}

interface

type

TRecordOne = record
  Foo: integer;
  Bar: string;
end;

TRecordTwo = record
  Baz: integer;
  Fish: string;
  Wibble: TRecordOne;
end;

TRecordThree = record
  Spon: integer;
  Plud: string;
  Monkey: TRecordOne;
  Soy: TRecordTwo;
end;

TRecordFour = record
  Kirk: integer;
  Spock: string;
  Picard: TRecordTwo;
  Data: TRecordThree;
end;

TRecordFive = record
  Worf: integer;
  Troy: string;
  Riker: TRecordTwo;
  Q: TRecordThree;
  Borg: TRecordFour;
end;



implementation

procedure TestWithStatement1;
var
  LocalRecord1: TRecordOne;
  LocalRecord2: TRecordTwo;
  Localrecord3: TRecordThree;
  LocalRecord4: TRecordFour;
  LocalRecord5: TRecordFive;
begin

  { this is a test of line breaking and trailing line indentation
    as the with expression list gets longer}
  with LocalRecord1 do
  begin
  end;

  with LocalRecord1, LocalRecord2 do
  begin
  end;

  with LocalRecord1, LocalRecord2, Localrecord3 do
  begin
  end;

  with LocalRecord1, LocalRecord2, Localrecord3, Localrecord4 do
  begin
  end;

  with LocalRecord1, LocalRecord2, Localrecord3, LocalRecord4, LocalRecord5 do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3, LocalRecord4, LocalRecord5 do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy, LocalRecord4, LocalRecord5 do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy, LocalRecord4.Data, LocalRecord5 do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy, LocalRecord4.Data, LocalRecord5.Borg do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data, LocalRecord5.Borg do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data.Soy, LocalRecord5.Borg do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data.Soy.Wibble, LocalRecord5.Borg do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data.Soy.Wibble, LocalRecord5.Borg.Data  do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data.Soy.Wibble, LocalRecord5.Borg.Data.Soy  do
  begin
  end;

  with LocalRecord1, LocalRecord2.Wibble, Localrecord3.Soy.Wibble, LocalRecord4.Data.Soy.Wibble, LocalRecord5.Borg.Data.Soy.Wibble do
  begin
  end;
end;

end.
