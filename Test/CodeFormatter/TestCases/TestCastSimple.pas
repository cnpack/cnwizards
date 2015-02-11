unit TestCastSimple;


{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests simple type casts
}

interface

uses Classes, StdCtrls;

var
  lcStrings: TStringList;
  lcObj: TObject;
  lcButton: TButton;

implementation

procedure TestDot;
var
  lc: TObject;
begin
  //this works as qualified identifier in an expr
  lc := lcButton.Owner;
  // this doesn't
  lc := (lcObj as TComponent).Owner;
end;


procedure Test1;
begin
  (lcButton as TObject).Free;
  (lcObj as TStringList).Free;
  (lcStrings as TObject).Free;
end;

procedure TestSurplusBrackets;
begin
  // surplus brackets in casts
  ((lcButton as TObject)).Free;
  (((lcObj as TStringList))).Free;
  ((((lcStrings as TObject)))).Free;
end;

procedure TestSurplusBrackets2;
begin
  // just brackets, no casts
  lcButton.Parent.Parent.Owner.Free;
  (lcButton.Parent.Parent).Owner.Free;
  ((lcButton.Parent).Parent).Owner.Free;
  (((lcButton).Parent).Parent).Owner.Free;
  ((((lcButton).Parent).Parent).Owner).Free;
end;


procedure Test2;
var
  lc: TObject;
begin
  lc := (lcButton as TObject);
  lc := (lcObj as TStringList);
  lc := (lcStrings as TObject);

  lc := (lcStrings);
end;


procedure Test3;
begin
   if lcObj is TStrings then
    (lcObj as TStrings).ClassName;

    if lcObj is TStrings then
    begin
      ((lcObj as TStrings)).ClassName;
    end;
end;

procedure Test4;
var
  lc: TObject;
begin
  // left recursive it is
  lc := (lcObj as TComponent).Owner;
  lc := ((lcObj as TComponent).Owner as TButton);
  lc := (((lcObj as TComponent).Owner as TButton).Owner as TButton);
  lc := ((((lcObj as TComponent).Owner as TButton).Owner as TButton).Owner as TButton);

  // nested it is
  lc := ((lcObj as TObject) as TComponent);
  lc := (((lcObj as TButton) as TObject) as TComponent);

  // both
  lc := ((lcObj as TComponent).Owner as TComponent);
  lc := (((lcObj as TButton) as TObject).Owner as TComponent);

  // surplus brackets
  lc := ((((((lcObj as TButton)) as TObject)).Owner as TComponent));

  // complex on the left
  lc := (lcButton.Parent as TComponent).Owner;
  lc := (lcButton.Parent.Parent as TComponent).Owner;

  // just brackets 
  lc := (lcButton.Parent.Parent).Owner;
  lc := ((lcButton.Parent).Parent).Owner;
  lc := (((lcButton).Parent).Parent).Owner;
  lc := ((((lcButton).Parent).Parent).Owner);
end;

end.
