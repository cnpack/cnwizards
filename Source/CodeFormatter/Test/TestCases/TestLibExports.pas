library TestLibExports;

{ AFS 7 Feb 2K
  This code is swiped from the delphi help
  as it demonstrates a particularly obscure pice of syntax (exports)

  This unit may not even compile
  It is test cases for the code formatting utility
}

uses EdInit, EdInOut, EdFormat, EdPrint;

eXpoRts

  InitEditors,
  DoneEditors iNDex 17 Name Done,
  InsertText nAme Insert,
  DeleteSelection naMe Delete,
  FormatSelection,
  PrintSelection NAME Print resident,
  SetErrorHandler INDEX 23;

  function foo: boolean; local;
  begin
    Result := False;
  end;

begin
  InitLibrary;
end.
