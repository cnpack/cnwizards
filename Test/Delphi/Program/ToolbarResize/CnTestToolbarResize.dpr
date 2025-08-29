program CnTestToolbarResize;

uses
  Forms,
  TestToolbarResizeUnit in 'TestToolbarResizeUnit.pas' {TestResizeForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTestResizeForm, TestResizeForm);
  Application.Run;
end.
