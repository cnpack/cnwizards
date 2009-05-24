unit TestInline;

{ This unit is not semantically meaningfull
 it is test cases for the code formatting utility

 and it doesn't even compile in recent Delphi
 This unit tests obsolete Turbo-pascal syntax
 the 'inline' statement }

interface

implementation

procedure FillWord(var Dest; Count: Word;
  Data: Word);
begin
  inline(
    $C4/E/<Dest/   { LES   DI,Dest[BP] }
    B/E/<Count/  { MOV   CX,Count[BP]}
    B//<Data/   { MOV   AX,Data[BP] }
    $FC/             { CLD               }
    $F3/$AB);        { REP   STOSW       }
end;

end.
