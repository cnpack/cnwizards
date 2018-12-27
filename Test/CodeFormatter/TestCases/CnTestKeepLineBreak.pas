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
end;

end.

