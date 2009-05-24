unit TestAlign;

{ AFS 27 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code tests the alignment beautifiers
  mostly end-line comment alignment and := used
}

interface

implementation

const
  F1 = 3; // comment in const
  Bar = 4;  // comment to align
  BAZZZZZZ = 12; // comment

procedure WellCommented;
var
  li1, li2, li3: integer; // these vars
  ldLongOne, LongTwo: int64; // are well
  ldLongFortyThreePointSeven: double; // commented
  lsNoComment: string;
begin
  li1 := 2; // endline comment  in test block 1
  ldLongOne := li1 * 2; // another endline comment in test block 1

  ldLongOne := (li1 * 2); //  endline comment in test block 2
  li2 := li1; { endline comment with braces in test block 2 }
  ldLongFortyThreePointSeven := ldLongOne + 2; //endline comment

  ldLongOne := (li2 * 2) + 3; //  endline comment in test block 3
  li1 := 2; { endline comment with braces in test block 3 }
  ldLongFortyThreePointSeven := ldLongOne + 2; (* other style *)
  li3 := 2 + li2; // endline comment in test block 3
  ldLongOne := li1 * 2; // another endline comment in test block 3


  li2 := 2; { endline comment with braces in test block 4}
  li3 := 2 + li2; // endline comment in test block 4
  li3 := li3 + 2; (* other style *)
  ldLongOne := li1 * 2; // another endline comment in test block 4
  ldLongFortyThreePointSeven := ldLongOne + 2; (* other style *)

  li1 := 1; { endline comment with braces in test block 5}
  li2 := 12; // endline comment in test block 5
  li3 := 300; (* other style in block 5 *)
  inc(li1);// endline comment in test block 5
  lsNoComment := 'This string has no comment';
  li1 := li2 + 1; { endline comment with braces in test block 5 }
  li2 := li3 + 11; { endline comment with braces in test block 5 }
  inc(li2); // endline comment in test block 5
  li3 := li1 + 122; { endline comment with braces in test block 5 }

  li1 := 1; { endline comment with braces in test block 5}
  li2 := 12; // endline comment in test block 5
  li3 := 300; (* other style in block 5 *)
  inc(li1);// endline comment in test block 5
  lsNoComment := 'This string has no comment';
  lsNoComment := 'A second statement with no comment. ';
  li1 := li2 + 1; { endline comment with braces in test block 5 }
  li2 := li3 + 11; { endline comment with braces in test block 5 }
  inc(li2); // endline comment in test block 5
  li3 := li1 + 122; { endline comment with braces in test block 5 }

end;

procedure Fred;
var
a: integer;
bee: string;
cee: integer;
deeFgee: integer;
begin
a := 2; // a comment
bee := 'three'; // a blank line follows

cee := 1210; // second block, separate alignment after the blank line
deeFgee := 12; // last comment
end;

procedure FredNoComments;
var
a: integer;
bee: string;
cee: integer;
deeFgee: integer;
begin
a := 2;
bee := 'three';  // sdafadf

cee := 1210;
deeFgee := 12;

end;

end.

