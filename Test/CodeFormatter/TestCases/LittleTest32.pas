unit LittleTest32;

interface

{ this is legal for vars but not consts }
var
  Foo: Boolean platform = False;
  Bar: Boolean library = False;
  Fish: Boolean deprecated = False;
  Wibble: Boolean platform library = False;
  Spon: Boolean platform library deprecated = False;

implementation

end.
