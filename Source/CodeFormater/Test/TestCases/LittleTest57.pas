Unit LittleTest57;

{ AFS Nov 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

{$ifdef FOO}
procedure Bar;
var
  b, s: Boolean;
begin
    if b then
{$IFDEF BIGFISH}
      s := b
    else
      s := '';
{$ELSE}
  {$IFNDEF FISHDANCE}
    if b then
    begin
       s := b;
    end
    else
    begin
      s := b;
    end
    else
    if s <> b then
    begin
       S := b;
    end else
    begin
      S := b;
    end;
  {$ELSE}
    begin
      S := b;
    end
    else
    begin
      S := b;
    end;
  {$ENDIF}
{$ENDIF}

end;

{$ENDIF}

end.


