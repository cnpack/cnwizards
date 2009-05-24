unit TestGoto;


{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests use of label & goto statements
 which you should NEVER HAVE TO USE!
}
interface

function JumpAllAround: integer;
procedure ForLoop;
procedure UntilLoop;

implementation

uses SysUtils, Dialogs;

label fred;

{ spagetti code }
function JumpAllAround: integer;
label
  ProcStart, ProcMid, ProcEnd;
begin
  Result := 0;

  Goto ProcMid;

  ProcStart: inc (Result);

  ProcMid: Result := Result + Random (10) - Random (9);

  if Result < 10 then
    Goto ProcStart;

  if Result > 20 then
    Goto ProcEnd
  else
    goto procMid;

  ProcEnd:;
end;

procedure ForLoop;
label
  LoopStart;
var
  liLoop: integer;
label
  Loopend;
const
  LOOPMAX = 20;
begin
  liLoop := 0;
  LoopStart:
  begin
    ShowMessage ('Loop # ' + IntToStr (liLoop));
    inc (liLoop);

    if liLoop > LOOPMAX then
      goto LoopEnd
    else
      goto LoopStart;
  end;

  LoopEnd:;

end;

procedure UntilLoop;
label
  LoopStart;
var
  liLoop: integer;
const
  LOOPMAX = 20;
begin
  liLoop := 0;
  LoopStart:

  ShowMessage ('Loop # ' + IntToStr (liLoop));
  inc (liLoop);

  if (liLoop < LOOPMAX) or (random (10) = 3) then
    goto LoopStart;

end;

procedure TestLabelUntil;
var
  i: integer;
  b: boolean;
label
  lbl;
begin
  repeat

    if b then
     goto lbl;

    lbl:
  until b;
end;

label Jim;
begin
  Goto Jim;

  Fred: ShowMessage ('Fred was here ');

  Jim:;
end.
