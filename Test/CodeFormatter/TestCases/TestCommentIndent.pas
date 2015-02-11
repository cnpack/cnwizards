unit TestCommentIndent;

{ AFS 8 May 2001
  Test the comment indenting options

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

// this is a left-aligned single-line comment
{ this is a left-aligned single-line comment }
(* this is a left-aligned single-line comment *)
  // this is an indented single-line comment
  { this is an indented single-line comment }
  (* this is an indented single-line comment *)
                // this is an extremely indented single-line comment
                { this is an extremely indented single-line comment }
                (* this is an extremely indented single-line comment *)

const
fred = 3;
// a comment
jim = 3;
{ another comment }
spon = 4;
(* last single-line comment *)
  wibble = 67;
  { a comment
    may span
    several lines }
  Fish = 'cod';

procedure Proc1;
  // a comment
  // in two parts
procedure Proc2;
  { another comment }
procedure Proc3;
  (* this is
     a longer comment
     and spans several lines *)
procedure Proc4;


type
  TFred = integer;
// foo!
TBar = integer;
{ a
  long
  comment }
TBaz = integer;

TAClass = class(TObject)
  public
    procedure Proc1;
// an other comment
    procedure Proc2;
{ a
  multiline comment }
    procedure Proc3;
                { single-line comment, out of whack }
    procedure Proc4;

    procedure Proc5(
      // a parameter - this comment should not be pulled up to the previous line
      p1: integer;
      // another param
      p2: string);

    { this one eshould end up on one line}
    procedure Proc6(
      p1
      : integer;
      p2:
      string);
end;

implementation

procedure Test1;
var
  li1, li2: integer;
begin
li1 := 0;
// init to zero
li2 := Random(3);

if li2 > 1 then
begin
li1 := 3;
// a comment
li1 := li1 + Random(3);
{ another comment }
if li1 > 3 then
begin
  li2 := 0;
  (* yet another comment *)
  li2 := li2 + 3;
{  this comment
   has several lines
   but must be correctly formatted
   in any event
}
  li2 := li2 + 3;
end;
end;

end;

procedure Proc1;
begin
end;

procedure Proc2;
begin
end;

procedure Proc3;
begin
end;

procedure Proc4;
begin
end;

{ TAClass }

procedure TAClass.Proc1;
begin

end;

procedure TAClass.Proc2;
begin

end;

procedure TAClass.Proc3;
begin

end;

procedure TAClass.Proc4;
begin

end;

procedure TAClass.Proc5(p1: integer; p2: string);
begin

end;

procedure TAClass.Proc6(p1: integer;
p2: string);
begin

end;

end.
