unit TestWarnDestroy;

interface

type

TFoo = class

  public
    destructor Destroy; override;

    procedure TestCreate;

end;

implementation

{ TFoo }

destructor TFoo.Destroy;
begin

  // this is not a warning
  inherited Destroy;
end;

procedure TFoo.TestCreate;
var
  lcFoo: TFoo;
begin
  lcFoo := TFoo.Create;

  // this is a warning
  lcFoo.Destroy;
end;

end.
