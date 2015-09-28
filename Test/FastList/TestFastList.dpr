program TestFastList;

uses
  Forms,
  UnitTestFastList in 'UnitTestFastList.pas' {TestFastListForm},
  CnFastList in '..\..\Source\Utils\CnFastList.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTestFastListForm, TestFastListForm);
  Application.Run;
end.
