unit CnTestKeepLineBreak;

interface
const
  JSON = '{ "o": { '
+ '    "1234567890": {'
+ '    "last use date": "2010-10-17T01:23:20",'
    + '    "create date": "2010-10-17T01:23:20",'
+ '    "name": "iPhone 8s"'
  + '        }'
+ '  },'
+ '  "Index": 0, '
+ '  "Data": {"Index2": 1}, '
+ '  "a": [{'
+ '    "last use date": "2010-10-17T01:23:20",'
     + '    "create date": "2010-11-17T01:23:20",'
+ '    "name": "iPhone 8s",'
+ '    "arr": [1,2,3] '
+ '  }, '
+ '  {'
+ '    "message": "hello"'
+ '  }]'
+ '}';

implementation

procedure Test;
const
  // D2010~D10.4
  DelphiIDEVers: array [21 .. 33] of string = (
  'Delphi 2010',
  'Delphi XE',
     'Delphi XE2',
  'Delphi XE3',
             'Delphi XE4',
  'Delphi XE5',
       'Delphi XE6',
  'Delphi XE7',
  'Delphi XE8',
  'Delphi 10 Seattle',
         'Delphi 10.1 Berlin',
  'Delphi 10.2 Tokyo',
  'Delphi 10.3 Rio');
begin
I:=1+3+(4+6)
+4/5*9+3+3+3+3+3+3+3+3+3+3+3+3+3+3+346+3+3+3+3+3+3+3+3+3+3+3+3+3-
9/232;
if (A = 0) and (B = 0)
and (C=0)and (D=0) and
(E=0) and(F=0)then
if (A = 0) and (B = 0)
and (C=0)and (D=0) and
(E=0) and(F=0)then
begin end;

if Item.Crypted = cvCrypt then
    Value := 0 else if Item.Crypted= cvCompressAndCrypt then
  begin  end;
end;

function TValidator.Number: TRule;
begin
  Result.Func :=Done  (
procedure(Rule: TRule)
    begin      if Field.AsString <> '' then
      begin
        if not True then    begin
          Error := TError.Create('Error.', Field.AsString);        end
      end;
    end, testme,1+3+5+
6+84/5);
end;

function FireDate(): string;
begin
  if True then
  begin
    c.AddRange(b)
  end;
end;
end.

