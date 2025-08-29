unit TestCharLiterals;

{ AFS 30 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests chars and strings }


interface

implementation

uses Dialogs;

procedure Chars;
const
Fred = #80;
LineBreak = #13#10;
SomeChars = #78#79#80;
HEXCHARS = #$12#$2E#60;

DQS_0 = '';
DQS_1 = '''';
DQS_2 = '''''';
DQS_3 = '''''''';
DQS_4 = '''''''''';

var
ls:string;
ls2: string;
begin
ls:=#90+LineBreak+#90#91+SomeChars+#90;
ls2:= #$F#$A;
ls2 := ls + #$1F + HEXCHARS;
end;

procedure Stringchars;
const
  Boo = 'Boo';
  HELLO = 'Hello'#13;
  OLLA = #10'Olla!';
var
  ls: string;
begin
  ls := 'Fred';
  ls := #13;
  ls := #12'Fred'#32'Fred'#22;
end;

{ hat char literals.
  Undocumented, but works.
  Described as "Old-style" - perhaps a Turbo-pascal holdover
 Pointed out by Dimentiy }

const
 str1 = ^M;

  HAT_FOO = ^A;
  HAT_BAR = ^b;
  HAT_FISH = ^F;
  HAT_WIBBLE = ^q;
  HAT_SPON = ^Z;

  HAT_AT = ^@;

  HAT_FROWN = ^[;
  HAT_HMM = ^\;
  HAT_SMILE = ^];
  HAT_HAT = ^^;
  HAT_UNDER = ^_;

  HAT_EQ_NOSPACE=^=;
  HAT_EQ_SPACEAFT=^= ;
  HAT_EQ_LONG=^=^=#0^='foo'^=;

var
  hat1: char = ^h;
  hat2: char = ^j;
  hat3: char = ^m;

procedure HatBaby;
var
 str: string;
 ch: char;
begin
  str := HAT_FOO + ^M;
  ch := ^N;

  str := HAT_FOO + ^@ + ^] + ^^ + ^- + ^\ + ^[;
end;

procedure TestHatCharliteralsInStrings;
var
  Str1: string;
begin
  Str1 := 'prefix'^M + 'substr2';
  Str1 := 'prefix'^M'foo' + 'substr2';
  Str1 := 'prefix'^M'foo'#23 + 'substr2'#56;
  Str1 := 'prefix'^M'foo'^M'bar'^N + 'substr2'^O;
  Str1 := 'prefix'#13^M#12^@'foo'#10^M'bar';

  { these are harder, as the '^' char has other uses }
  Str1 := ^M;
  Str1 := ^M + 'substr2';
  Str1 := ^M'foo' + 'substr2';
  Str1 := ^M^N^@'foo' + 'substr2';
  Str1 := ^M'foo'#23 + 'substr2'#56;
  Str1 := ^M'foo'^M'bar'^N + 'substr2'^O;
  Str1 := #13^M#12^@'foo'#10^M'bar';
end;

procedure HatEquals(const Value: pchar);
const
  { ambiguous.
    same chars lexed differently in if-statement
    Impossble to lex cleanly }
    
  HAT_EQ = ^=;
  HAT_EQ_C = ^='C';
  HAT_EQ_NIL = ^=#0;
  HAT_EQ_C_NIL = ^='C'^=#0^='C'^=#0;
var
  st: string;
begin
  if value^='C' then
    ShowMessage('See')
  else if (Value^=#0) then
    ShowMessage('nil')
  else if (Value^=^=) then
    ShowMessage('terrence, this is stupid stuff');

  { space }
  if value ^='C' then
  { brackets }
  else if ((Value^)=#0) then
    ShowMessage('nil')
  { new line }
  else if (Value
^=^=) then
    ShowMessage('terrence, this is stupid stuff');


  st := value^+value^;
  if (Value^=^=^=) then
    ShowMessage('meep');
  if (Value^=^+^-^^^_) then
    ShowMessage('meep');
end;

end.
