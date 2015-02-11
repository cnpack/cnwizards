Unit TestPropertyInherited;

{ bug #762354 in jcf 2 Beta 5
  reported by adem baba
}

Interface

const
  HAS_BAR = False;
  FIVE = (2 + 2);

type

TCustomFoo = class(TObject)
  private
    function GetFoo: integer;

  protected
    property Foo: integer read GetFoo nodefault;
    property Bar: integer read GetFoo stored HAS_BAR;
    Property Monkey: integer read GetFoo;
    Property Soy: integer read GetFoo;

end;

TFoo = class(TCustomFoo)
 public
  Property Foo;
End;

const
  FOO_DEFAULT = 3;

type
  TMegaFoo = class(TFoo)
  private
    function GetFishes(const piC: integer): integer;
    procedure SetFishes(const piC, Value: integer);
  public
    property Fishes[const piC: integer]: integer read GetFishes write SetFishes; default;

  published
    property Bar default 3;
    property Foo default FOO_DEFAULT + 1;
    property Monkey stored FIVE;
    property Soy stored FIVE + 1 nodefault;
  end;

  { base class with array and scalar property }
  TUserHasDefaults = class(TObject)
  private
    function GetDef1: integer;
  protected
    function GetDef2(const piC: integer): integer; virtual;
    procedure SetDef2(const piC, Value: integer); virtual;
  public
    property Def1: integer read GetDef1;
    property Def2[const piC: integer]: integer read GetDef2 write SetDef2;

  end;

  THasDefaults = class(TUserHasDefaults)
  // two different syntaxes - semicolon in one not other
    property Def1 default 1;
    property Def2; default;

  end;

  TDefHasOverrides = class(TUserHasDefaults)
  protected
    function GetDef2(const piC: integer): integer; override;
    procedure SetDef2(const piC, value: integer); override;

  end;


Implementation

{ TCustomFoo }

function TCustomFoo.GetFoo: integer;
begin
  Result := 3;
end;

{ TMegaFoo }

function TMegaFoo.GetFishes(const piC: integer): integer;
begin
  Result := piC - 1; // overfishing
end;

procedure TMegaFoo.SetFishes(const piC, Value: integer);
begin

end;

{ TUserHasDefaults }

function TUserHasDefaults.GetDef1: integer;
begin
  Result := 0;
end;

procedure TUserHasDefaults.SetDef2(const piC, Value: integer);
begin
  // do nothing
end;

function TUserHasDefaults.GetDef2(const piC: integer): integer;
begin
  Result := piC + 1;
end;


{ TDefHasOverrides }

function TDefHasOverrides.GetDef2(const piC: integer): integer;
begin
  Result := inherited Def2[piC] + inherited Def2[piC + 1] + 2;
end;

procedure TDefHasOverrides.SetDef2(const piC, value: integer);
begin
  inherited Def2[piC] := value;
end;

End.
