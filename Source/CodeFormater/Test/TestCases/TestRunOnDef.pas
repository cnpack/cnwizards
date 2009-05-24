unit TestRunOnDef;

{ AFS 19 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

this unit tests indentation of class & procedure defs that run on to
 more than one line
 }

interface

type THasLongProcs = class
    public
      procedure DoSomething (var piALongParamter: integer;
      pbAnotherParamter: Boolean;
      pmMoreBetterMoney: Currency );

      { this will be broken up }
      function DoSomethingElseAlthogether (var piALongParamter: integer; pbAnotherParamter: Boolean; pmMoreBetterMoney: Currency ): TObject; virtual; safecall;

      function HasModifiers: integer;
        virtual; safecall;
  end;



type

TVeryExtremelyLongProcedure1
= function (Fred: integer): Currency of object;
TVeryExtremelyLongProcedure2 =
function (Fred: integer): Currency of object;
TVeryExtremelyLongProcedure3 = function
(Fred: integer): Currency of object;
TVeryExtremelyLongProcedure4 = function (Fred: 
integer): Currency of object;
TVeryExtremelyLongProcedure5 = function (Fred: integer): Currency
of object;
DissimilarStuff  = (Apples, Oranges,
Deconstructionism, CompostHeap);


implementation

{ THasLongProcs }

procedure THasLongProcs.DoSomething(var piALongParamter: integer;
  pbAnotherParamter: Boolean; pmMoreBetterMoney: Currency);
begin

end;

function THasLongProcs.DoSomethingElseAlthogether(
  var piALongParamter: integer; pbAnotherParamter: Boolean;
  pmMoreBetterMoney: Currency): TObject;
begin
  Result := nil;
end;

function THasLongProcs.HasModifiers: integer;
begin
  Result := -1;
end;

end.
