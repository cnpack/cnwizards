unit TestEmptyClass;

{ AFS 9 July 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  Test bug reported by  Michael Hieke after empty class;
}

interface

uses Classes;

var
Jim: integer;

type

{ a forward }
TFoo = class;
{another typedef }
counter = integer;
{ make good on the forward - must be in the same type block }
TFoo = class(TPersistent);


{ a sublass that does not extend - Michael spotted that this f's things up in v2.1
  type TFoo = class; is a forward, but type TBar = class(TObject); is a subclass
}
TMyList = class(TList);

var
Cripes: string;

function Oog: integer;

type
TPenguin = class(TObject) liBill: integer;
public
  procedure FeedMe;
end;

type TBar = class(TObject); var Opps: currency;

implementation

type
Foo = class(TObject)
end;

function Oog: integer;
begin
  Result := 3;
end;

{ TPenguin }

procedure TPenguin.FeedMe;
begin
  // do nothing
end;

{ TCormorant }

Type TCormorant = class(TObject);

procedure Foog;
var
  lcTux: TPenguin;
begin
  // do nothing
end;

end.
