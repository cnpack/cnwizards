unit TestRunOnLine;

{ AFS 15 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 test runon line indentation
 some of this code swiped from a real app

 Note: any programmer who actually codes like this should be shot
 In real life, use intermediate vars & functions, dammit!
 This code is useful as a test case of just how complex a single condition can be.

 As far as I can think, there are a few cases in which run-on lines can occur
 - Calling a procedure with lots of parameters,
    or a complex expression for one or more of the parameters
 - complex expression between if ... then, likewise while..do, repeat..until, case..of
 - complex expression on the RHS of an asign operator

 in any case, a run-on line is a line-break in one of these situations:
 - inside brackets (parameter list)
 - between := and ; or until and ;
 - between if and then or while and do or case and of
}

interface

implementation

{ functions used to build up complex expressions }
function RandomInt: integer;
begin
  Result := Random (20);
end;

function RandomBoolean: Boolean;
begin
  Result := (Random (2) = 0);
end;

function HasLotsOfArguments (b1, b2, b3, b4, b5: Boolean): Boolean;
begin
  Result := (b1 or b2 or b3 or b4 or b5 and RandomBoolean) or RandomBoolean;
end;

procedure tempTest2;
var
  b1, b2, b3, b4, b5: Boolean;
begin
  { big while condition and the like }
  while
    (RandomBoolean and b1 and HasLotsOfArguments(b1, b2, b3, b4, b5)) or (RandomBoolean and b2 and HasLotsOfArguments(b1, b2, b3, b4, b5)) or
    (RandomBoolean xor b3 xor HasLotsOfArguments(b1, b2, b3, b4, b5)) or
    (RandomBoolean and b4 and HasLotsOfArguments(b1, b2, b3, b4, b5)) or
    (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean) do
end;

procedure tempTest;
var
  b1, b2, b3, b4, b5: Boolean;
begin
  { big while condition and the like }
  while (RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean) do
  begin
    break;
  end;

end;




procedure HasLongStatements;
var
  b1, b2, b3, b4, b5, b6: Boolean;
begin
  { initialize }
  b1 := RandomBoolean;
  b2 := RandomBoolean;
  b3 := RandomBoolean;
  b4 := RandomBoolean;
  b5 := HasLotsOfArguments (b1, b2, b3, b4, b5);

  { long expresssion after := }
  b5 := RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean and (b1 xor b2 and RandomBoolean);

  { long argument list }
  b6 := HasLotsOfArguments (
    RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5), RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5),
    RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5), RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5),
    RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean);

  { even longer by cutting & pasting the last 2 together }
  b1 := RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean and
    (b1 xor b2 and RandomBoolean) or HasLotsOfArguments (
    RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5), RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5),
    RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5), RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5),
    RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean);

  { long if Statement }
  if (RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean) then
  begin
    b1 := False;
  end;

  { big while condition and the like }
  while (RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean) do
  begin
    break;
  end;

  repeat
    b1 := not b1;
  until
  (RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean);

  case (RandomBoolean and b1 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean or b2 or HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean xor b3 xor HasLotsOfArguments (b1, b2, b3, b4, b5)) or
    (RandomBoolean and b4 and HasLotsOfArguments (b1, b2, b3, b4, b5)) or (RandomBoolean or RandomBoolean or RandomBoolean or RandomBoolean) of

  True: b3 := False;
  False: b4 := False;
  end;

end;


{ progressively longer expressions. When and where will they break? }
procedure Progressive;
var
  b1, b2, b3, b4, b5, b6: Boolean;
begin
  { initialize }
  b1 := RandomBoolean;
  b2 := RandomBoolean;
  b3 := RandomBoolean;
  b4 := RandomBoolean;
  b5 := HasLotsOfArguments (b1, b2, b3, b4, b5);

  b1 := b2;
  b1 := b2 or b3 or b1;
  b1 := (b2 or b3) and b1;
  b1 := (b2 or b3) and (b4 or b1);
  b1 := (b2 or b3) and (b4 or b5) and b1;
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and b1;
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3);
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and b1;
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2);
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or b1;
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or (b1 or b3);
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or (b1 or b3) and (b2 or b3);

  { same line, different bracketing }
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or ((b1 or b3) and (b2 or b3));
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and ((b1 or b2) or (b1 or b3)) and (b2 or b3);
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and ((b1 or b3) and (b1 or b2)) or (b1 or b3) and (b2 or b3);
  b1 := (b2 or b3) and (b4 or b5) and (b4 or b1) and ((b1 or b3) and (b1 or b2) or (b1 or b3) and (b2 or b3));


  if b2 then
    b1 := True;

  if b2 or b3 or b1 then
    b1 := True;

  if (b2 or b3) and b1 then
    b1 := True;

  if (b2 or b3) and (b4 or b1) then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and b1 then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and b1 then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and b1 then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or b1 then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or (b1 or b3) then
    b1 := True;

  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or (b1 or b3) and (b1 xor b3) then
    b1 := True;

  { same line, different bracketing }
  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and (b1 or b2) or ((b1 or b3) and (b1 xor b3)) then
    b1 := True;
  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and ((b1 or b2) or (b1 or b3)) and (b1 xor b3) then
    b1 := True;
  if (b2 or b3) and (b4 or b5) and (b4 or b1) and ((b1 or b3) and (b1 or b2)) or (b1 or b3) and (b1 xor b3) then
    b1 := True;
  if (b2 or b3) and (b4 or b5) and (b4 or b1) and (b1 or b3) and ((b1 or b2) or (b1 or b3) and (b1 xor b3)) then
    b1 := True;
  if (b2 or b3) and (b4 or b5) and (b4 or b1) and ((b1 or b3) and (b1 or b2) or (b1 or b3) and (b1 xor b3)) then
    b1 := True;

end;

{ code ripped from a real app
 (names have been  munged to obscure irrelevant details of a client's business).
 Don't expect it to compile out of context
 If the unit compiles up to here, that is good enough
}
procedure TCSomeBusinessObject.InvestIV (const pciPCO: IParrotCommentObject;
  const lciIVChoice: IIvyChoice);
var
  lsSQL: string;
  ldPercentage: Double;
begin

  lsSQL := 'InvestTransfer ' +
    IntToStr (Id) + ' ,' +
    IntToStr (ThingdId) + ' , ' +
    IntToStr (pciPCO.Id) + ' , ' +
    FloatToStr (ldPercentage) + ' , ' +
    DoubleQuote (CoreObject.LoginName) +
    FormatDateTime ('dd mmm yyyy', CoreObject.CurrentDate);

  CoreObject.ExecSQL (lsSQL);

  { should break this line ? }
  edtAllocationType.Text := FindingManager.FindItemByCode (LOOKUP_INCOMING_PAYMENT_ALLOCATION, IncomingPaymentAllocation.AllocationType) + 12;

end;

end.
