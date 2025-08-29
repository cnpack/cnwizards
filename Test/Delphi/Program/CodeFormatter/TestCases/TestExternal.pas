unit TestExternal;

{ AFS 11 March 2K   Test external definitions

  This code is test cases for the code-formating utility


  This stuff doesn't compile, but is copied from delphi units
  So is out of context here
}


interface

uses Windows;

procedure Fred;
  CDecl;

procedure FloatToDecimal(var Result: integer; const Value;
  ValueType: integer; Precision, Decimals: Integer); external;

function FloatToText(Buffer: PChar; const Value; ValueType: integer;
  Format: integer; Precision, Digits: Integer): Integer; external;


function AddAtomA: Atom; external kernel32 name 'AddAtomA';
function AreFileApisANSI: bool; external kernel32 name 'AreFileApisANSI';
function Beep: bool; external kernel32 name 'Beep';

{ with line breaks }
function Fooo: string;
  external kernel32 name 'Fish';


function Wibble: Boolean;
  external;

implementation

uses Dialogs;

{ in the imp. section }

procedure Spon; external;
procedure Spon2; external;

procedure Fred;
begin
  ShowMessage('Fred');
end;

procedure Spon3; external;

end.
