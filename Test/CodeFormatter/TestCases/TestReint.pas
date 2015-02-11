unit TestReint;

interface

type

  TFoo = class(TObject)
  public
    procedure Foo;
    virtual;
  end;

  TBar = class(TFoo)
  public
    procedure Foo; reintroduce;
  end;

  TLineBreak = class(TFoo)
  public
    procedure Foo;
    reintroduce;
  end;


implementation

{ TFoo }

procedure TFoo.Foo;
begin
  // dummy
end;

{ TBar }

procedure TBar.Foo;
begin
  // dummy
end;

{ TLineBreak }

procedure TLineBreak.Foo;
begin
  // dummy
end;

end.
