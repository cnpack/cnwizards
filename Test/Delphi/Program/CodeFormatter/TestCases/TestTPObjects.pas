unit TestTPObjects;

{ AFS 5 Feb 2001

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  This unit tests Turbo-pascal style objects
  It is not recommended that you use these -
  they are for backward compatibility with TP6&7 or thereabouts only
  }

interface


type

TFoo = object end;

TBar = object
private
protected
public
end;

TBaz = object
li1: integer;
private
li2: integer;
protected
li3: integer;
public
li4: integer;
end;

TFish = object(TBar) procedure Swim; end;


implementation

{ TFish }

procedure TFish.Swim;
begin
  // swiminy fishee!
end;

end.
