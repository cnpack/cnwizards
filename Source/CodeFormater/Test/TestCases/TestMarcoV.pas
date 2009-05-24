unit TestMarcoV;

{ AFS 27 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code is test cases submitted by Marco van de Voort [marcov@stack.nl]
}

interface

var
bigs, storesc, searchdepth, mcount, rrate, hyva, huonoja, viimeksi, wmat, bmat, bonus, movesmade, posvalue: integer;
kpos, positions, pos2:                  longint;
mwk, mbk, mwra, mbra, mwrh, mbrh, viewscores, analysis, keskeyta, opening, stopcalc: boolean;

implementation 

procedure fred;
var 
  s: string;
  i: integer;
begin 
  s := 'a very very long string that is indeed much more than 80 chars in its total length and will break in an ugly manner';
  i := 12;
  
  if ((i < 1) and (i < 2) and (i < 3) and (i < 4) and (i < 5) and (i < 6) and (i < 7)) then
  begin 
  end;
end;

end.