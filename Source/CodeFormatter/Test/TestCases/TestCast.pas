unit TestCast;


{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit test type casts
 Borland style is that there is no space between the type & the bracket
}

interface

function CastNumeric: integer;
procedure MessWithObjects;


implementation

uses Classes, SysUtils, Dialogs, ComCtrls, StdCtrls;

function CastNumeric: integer;
var
  dValue: Double;
  crValue: Currency;
begin
  dValue := Random (100) * PI;
  crValue := Currency (dValue);
  Result := Round (crValue);
end;

procedure MessWithObjects;
var
  lcStrings: TStringList;
  lcObj: TObject;
  lp: Pointer;
  li: integer;
begin
  lcStrings := TStringList.Create;
  try
    lcObj := lcStrings as TObject;
    lp := Pointer (lcObj);
    li := Integer (lp);
    ShowMessage (IntToStr (li));

    { and back }
    lp := Pointer (li);
    lcObj := TObject (Pointer (li));
    lcStrings := TStringList (TObject (Pointer (li)));

  finally
    lcStrings.Free;
  end;
end;


type
  TFred = (eFee, efi, eFo, Fum);
  TJim = (eMing, eMong, mMung, eCorWhatADonga);
  TNumber = integer;

procedure UsertypeCast;
var
  Fred: TFred;
  Jim: TJim;
  li: Integer;
  lj: TNumber;
begin
  li := Random (3);
  Fred := TFred (li);
  Jim := TJim (Fred);
  lj := TNumber (Jim);
end;

{ brackets at the LHS }
procedure HardLeft;
var
  lcStrings: TStringList;
  lcObj: TObject;
begin
  lcStrings := TStringList.Create;
  try
    lcObj := lcStrings;

    if lcObj is TStrings then
    (lcObj as TStrings).ClassName;
    if lcObj is TStrings then
      begin
    (lcObj as TStrings).ClassName;
      end;

   if lcObj is TStrings then
    ((lcObj as TStrings)).ClassName;
    if lcObj is TStrings then
      begin
    ((lcObj as TStrings)).ClassName;
      end;


  finally
    lcStrings.Free;
  end;
end;

procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  ((Sender as TUpDown).Associate as TEdit).Modified := True;
end;


end.
