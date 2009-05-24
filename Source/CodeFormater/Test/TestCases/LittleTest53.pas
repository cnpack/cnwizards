unit LittleTest53;

interface

implementation


{$IFDEF REDDWARF}
procedure Cat;
asm

{$IFDEF FISH}
        call    TroutALaCreme
{$ELSE}
        pop MealStack
{$ENDIF}
      call  __EnjoyYourMeal
@@ret:
end;
{$ENDIF}


end.
 