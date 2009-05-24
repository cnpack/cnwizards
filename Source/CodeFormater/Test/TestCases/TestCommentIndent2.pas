unit TestCommentIndent2;

{ AFS 17 April 2004
  Test the comment indenting options

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface
// a comment
uses
// a comment
  SysUtils;
// a comment

// a comment
const
// a comment
 foo = 3;
// a comment
var
// a comment
  lb: boolean;
// a comment
type
// a comment
 AnInteger = integer;
// a comment
 TFooClass = class
// a comment
  public
// a comment
  procedure Bar;
// a comment
end;
// a comment

implementation
// a comment

uses
// a comment
  dialogs,
// a comment
  classes;
// a comment

{ TFooClass }

// a comment
procedure TFooClass.Bar;
// a comment
const
// a comment
  LIMIT = 99;
// a comment
var
// a comment
  liCounter: integer;
// a comment
begin
// a comment
  for liCounter := 0 to LIMIT do
// a comment
  begin
// a comment
    lb := not lb;
// a comment
  end;
// a comment
end;
// a comment

// a comment
procedure TestTry;
// a comment
begin
// a comment
  try
// a comment
    lb := not lb;
// a comment
  except
// a comment
    ;
// a comment
  end;
// a comment
  try
// a comment
    lb := not lb;
// a comment
  except
// a comment
    on E: exception do
// a comment
      ShowMessage('Era');
// a comment
  end;
// a comment
end;
// a comment

// a comment
initialization
// a comment
  lb := False;
begin
// a comment
  lb := not lb;
// a comment
end;
// a comment
finalization
// a comment
  lb := False;
// a comment
end.
