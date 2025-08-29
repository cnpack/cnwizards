program TestAnsiUniLength;

uses
  Forms,
  TestAnsiUniLengthUnit in 'TestAnsiUniLengthUnit.pas' {TestAnsiUniForm},
  CnCommon in '..\..\..\..\..\cnvcl\Source\Common\CnCommon.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestAnsiUniForm, TestAnsiUniForm);
  Application.Run;
end.
