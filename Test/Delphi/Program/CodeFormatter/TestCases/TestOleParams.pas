unit TestOleParams;

{ AFS 11 July 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

implementation

uses ComObj;

procedure WordUp;
var
  MSWord: Variant;
begin
  MsWord := CreateOleObject('Word.Basic');

  MsWord.AppShow;
  MSWord.FileNew;
  MSWord.Insert('Foo');
  MSWord.LineUp(2, 1);

  { Ack! }
  MSWord.TextToTable(ConvertFrom := 2, NumColumns := 3);
end;

procedure W_App;
var
  WordApp: Variant;
begin
 WordApp := CreateOleObject('Word.Application');
 WordApp.Documents.Open('foo',,,,'bar');
end;

end.
