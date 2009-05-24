unit LittleTest43;

{ AFS 10 Sept 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 code from Adem baba
 }

interface

implementation

uses SysUtils, Forms, Controls, ComObj;

Procedure FooSavetoDOC(filename: String);
Var
fword: Variant;
fdoc: Variant;
ftable: Variant;
frng: Variant;
fcell: Variant;
s, z: Integer;
Begin
Screen.Cursor := crHourGlass;
Try
FWord := CreateOLEObject('word.application');
Except
Screen.Cursor := crDefault;
Raise Exception.Create('Word OLE server not found');
Exit;
end;
 { 'End'?!?! Since when is 'end' a valid identifier!?!?  I cannae believe it capt'n! }
 FRng := FDoc.Range(start := 0, End := 0); {<-- HERE}

 { right, if end works, let's see what other reserved words we can abuse
  amazing. }
 FRng := FDoc.Range(start := 0, begin := 0);
 FRng := FDoc.Range(start := 0, try := 0);
 FRng := FDoc.Range(start := 0, unit := 0);
 FRng := FDoc.Range(start := 0, for := 0);
 FRng := FDoc.Range(start := 0, if := 0);
 FRng := FDoc.Range(start := 0, then := 0);
 FRng := FDoc.Range(start := 0, procedure := 0);
 FRng := FDoc.Range(start := 0, string := 0);
 FRng := FDoc.Range(start := 0, integer := 0);
 FRng := FDoc.Range(start := 0, char := 0);

End;

end.
