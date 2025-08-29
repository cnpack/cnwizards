unit TestLineBreaking;

{ AFS 5 May 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests line breaking
 so the code aims to take up space in creative ways
}

interface

implementation

uses SysUtils;

procedure ThisIsAJobForReturnInsertion; var a,b: integer; begin a := 10; b := 2 * a; end;

function DoubleString(const ps: string): string;
begin
  Result := ps + ps;
end;


procedure ThisIsAJobForReturnRemoval
;
var a,b
: integer;
begin
  a
  := 10;
  b := 2 * a
  ;
end;


procedure TestTweaks;
var
  a, b: integer;
begin
  a := Random(20);

  if a < 10 then        // don't move this comment
  begin
    b :=                // don't move this comment
      a * 2;
  end;

  if b < 10 then        // don't move this comment
    a :=                // don't move this comment
      b * 2;

  if b < 10 then        { don't move this comment }
    a :=                { don't move this comment }
      b * 2;

  a := a * 2;           // don't move this comment
  a := a * 2;           { don't move this comment }

end;

// easy pieces for the line breaker
function ThisFunctionNameIsFourty_Characters_Long(const ps1, ps2: string): string;
begin
  Result := ps1 + ps2;
end;

function AddFloats(const pf1, pf2: extended): extended;
begin
  Result := pf1 + pf2;
end;

// easy pieces for the line breaker
procedure EasyPieces;
var
  ls1, ls2, ls3: string;
  lf: Extended;
begin
  // string concat
  ls1 := 'this string is fourty characters long ' + 'this string is fourty characters long ' + 'this string is fourty characters long ';
  ls1 := 'this string is not fourty characters' + 'this string is not fourty characters' + 'this string is not fourty characters ';
  ls1 := 'this string is not fourty chars' + 'this string is not fourty chars' + 'this string is not fourty chars';
  ls1 := 'this string is not chars' + 'this string is not chars' + 'this string is not chars';
  ls1 := 'this string is not' + 'this string is not' + 'this string is not';
  ls1 := 'this string is' + 'this string is' + 'this string is';

  // expressions with brackets
  lf := (1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890);
  lf := (1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890) * -12.34567890;
  lf := (1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890);
  lf := (1.23456789 + 2.34567890) * -12.34567890 + ((1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890));
  lf := (1.23456789 + 2.34567890) * (-12.34567890 + (1.23456789 + 2.34567890) * -12.34567890) + (1.23456789 + 2.34567890) * -12.34567890 + (1.23456789 + 2.34567890) * -12.34567890;
  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890) * -12.34567890);

  // function call with long strings
  ls2 := ThisFunctionNameIsFourty_Characters_Long('this string is fourty characters long ', 'this string is fourty characters long ');
  ls2 := ThisFunctionNameIsFourty_Characters_Long('this string is characters long ', 'this string is characters long ');
  ls2 := ThisFunctionNameIsFourty_Characters_Long('this string is long ', 'this string is long ');
  ls2 := ThisFunctionNameIsFourty_Characters_Long('this string', 'this string');
  ls2 := ThisFunctionNameIsFourty_Characters_Long('this', 'this');

  // test breaking in & around the function call
  ls1 := 'this string is ' + FloatToStrF(12.3456789012, ffExponent, 8, 9);
  ls1 := 'this string is getting ' + FloatToStrF(12.3456789012, ffExponent, 8, 9);
  ls1 := 'this string is getting longer ' + FloatToStrF(12.3456789012, ffExponent, 8, 9);
  ls1 := 'this string is getting longer and longer ' + FloatToStrF(12.3456789012, ffExponent, 8, 9);
  ls1 := 'this string is getting longer and longer and longer ' + FloatToStrF(12.3456789012, ffExponent, 8, 9);

  { this comment }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));
  { this comment  will }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));
  { this comment  will affect }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));
  { this comment  will affect line }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));
  { this comment  will affect line spacing }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));
  { this comment  will affect line spacing in some way }  lf := ((1.23456789 + 2.34567890) * -12.34567890) + ((1.23456789 + 2.34567890));


  // expressions in params
  lf := AddFloats(2, 2);
  lf := AddFloats(1.2345678901, 1.2345678901);
  lf := AddFloats(1.2345678901 * -47, 1.2345678901 + 12 * -12);
  lf := AddFloats((1.2345678901 * -47) + 12.1234567890, 1.2345678901 + (12.0987654321 * -12.987654321));
  lf := AddFloats(((1.2345678901 * -47) + 12.1234567890) * (1.2345678901 + (12.0987654321 * -12.987654321)), 3);
  lf := AddFloats(((1.2345678901 * -47) + 12.1234567890) * (1.2345678901 + (12.0987654321 * -12.987654321)), 3 * ((1.2345678901 * -47) + 12.1234567890) * (1.2345678901 + (12.0987654321 * -12.987654321)));

  // nested function calls
  lf := AddFloats(1.234, 5.678);
  lf := AddFloats(AddFloats(1.234, 5.678), AddFloats(1.234, 5.678));
  lf := AddFloats(AddFloats(AddFloats(1.234, 5.678), AddFloats(1.234, 5.678)),AddFloats(AddFloats(1.234, 5.678), AddFloats(1.234, 5.678)));
  lf := AddFloats(AddFloats(AddFloats(1.234 * AddFloats(1.234, 5.678), 5.678 - AddFloats(1.234, 5.678)), AddFloats(1.234, 5.678)),AddFloats(AddFloats(1.234, 5.678), AddFloats(1.234, 5.678)));
end;

// something harder
procedure BreakIt;
var
  lsString: string;
begin

  { something must break }
  lsString := DoubleString('a');
  lsString := DoubleString('aa');
  lsString := DoubleString('aaa');
  lsString := DoubleString('aaaa');
  lsString := DoubleString('aaaaa');
  lsString := DoubleString('aaaaaa');
  lsString := DoubleString('aaaaaaa');
  lsString := DoubleString('aaaaaaaa');
  lsString := DoubleString('aaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  lsString := DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
end;

procedure BreakItInBrackets;
var
  lsString: string;
begin

  { something must break }
  lsString := (DoubleString('a'));
  lsString := (DoubleString('aa'));
  lsString := (DoubleString('aaa'));
  lsString := (DoubleString('aaaa'));
  lsString := (DoubleString('aaaaa'));
  lsString := (DoubleString('aaaaaa'));
  lsString := (DoubleString('aaaaaaa'));
  lsString := (DoubleString('aaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
  lsString := (DoubleString('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'));
end;

procedure ManyParams1(a1, b1, c1: integer; const a2, b2, c2: string);
begin
end;


procedure ManyParams2(a1, b1, c1: integer; const a2, b2, c2: string; a3, b3, c3: double);
begin
end;

procedure ManyParams3(a1, b1, c1: integer; const a2, b2, c2: string; a3, b3, c3: double; a4, b4, c4: char);
begin
end;

procedure ManyParams4(a1, b1, c1: integer; const a2, b2, c2: string; a3, b3, c3: double; a4, b4, c4: char; var a5, b5, c5: WideString);
begin
end;

procedure ManyParams5(a1, b1, c1: integer; const a2, b2, c2: string; a3, b3, c3: double; a4, b4, c4: char; var a5, b5, c5: WideString; const a6, b6, d6: pointer);
begin
end;

procedure ManyParams6(a1, b1, c1: integer; const a2, b2, c2: string; a3, b3, c3: double; a4, b4, c4: char; var a5, b5, c5: WideString; const a6, b6, d6: pointer; const a7, a8, a9: array of WideChar);
begin
end;

procedure ManyParams7(a1xxxxx, b1xxxxx, c1xxxxx: integer; const a2xxxxx, b2xxxxx, c2xxxxx: string; a3xxxxx, b3xxxxx, c3xxxxx: double; a4xxxxx, b4xxxxx, c4xxxxx: char; var a5xxxxx, b5xxxxx, c5xxxxx: WideString; const a6xxxxx, b6xxxxx, d6xxxxx: pointer; const a7xxxxx, a8xxxxx, a9xxxxx: array of WideChar);
begin
end;


procedure ManyParams8(a1xxxxxxxxx, b1xxxxxxxxx, c1xxxxxxxxx: integer; const a2xxxxxxxxx, b2xxxxxxxxx, c2xxxxxxxxx: string; a3xxxxxxxxx, b3xxxxxxxxx, c3xxxxxxxxx: double; a4xxxxxxxxx, b4xxxxxxxxx, c4xxxxxxxxx: char; var a5xxxxxxxxx, b5xxxxxxxxx, c5xxxxxxxxx: WideString; const a6xxxxxxxxx, b6xxxxxxxxx, d6xxxxxxxxx: pointer; const a7xxxxxxxxx, a8xxxxxxxxx, a9xxxxxxxxx: array of WideChar);
begin
end;

procedure ManyParams9(a1xxxxxxxxx, b1xxxxxxxxx, c1xxxxxxxxx, a2xxxxxxxxx, b2xxxxxxxxx, c2xxxxxxxxx: string; a3xxxxxxxxx, b3xxxxxxxxx, c3xxxxxxxxx, a4xxxxxxxxx, b4xxxxxxxxx, c4xxxxxxxxx: char; var a5xxxxxxxxx, b5xxxxxxxxx, c5xxxxxxxxx, a6xxxxxxxxx, b6xxxxxxxxx, d6xxxxxxxxx: pointer; const a7xxxxxxxxx, a8xxxxxxxxx, a9xxxxxxxxx: array of WideChar);
begin
end;

function TestFunctionName(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha_more(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha_more_again(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha_more_again_and_again(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha_more_again_and_again_andyetagain(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

function TestFunctionNameLength_hahaha_more_again_and_again_andyetagain_thisis(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;


function TestFunctionNameLength_hahaha_more_again_and_again_andyetagain_thisissilly(a1, b1, c1: integer; const a2, b2, c2: string): integer;
begin
end;

end.
