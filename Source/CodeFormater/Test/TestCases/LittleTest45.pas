unit LittleTest45;

interface

{ test out params and params called out }

function Foo1(Out: integer): integer; stdcall; overload; external 'FooDll' name 'Bargle';
function Foo2(Out, Bar: integer): integer; stdcall; overload; external 'FooDll' name 'Snargle';
function Foo3(out Out, bar: integer): integer; stdcall; overload; external 'FooDll' name 'Fargle';
function Foo4(out Out: integer): integer; stdcall; overload; external 'FooDll' name 'Gargle';
function Foo5(out bar: integer): integer; stdcall; overload; external 'FooDll' name 'Zargle';


implementation

end.
