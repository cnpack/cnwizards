program TestCaptionButton;

uses
  Forms,
  TestCapBtnUnit in 'TestCapBtnUnit.pas' {TestCaptionButtonForm},
  mxCaptionBarButtons in '..\..\Source\ThirdParty\mxCaptionBarButtons.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestCaptionButtonForm, TestCaptionButtonForm);
  Application.Run;
end.
