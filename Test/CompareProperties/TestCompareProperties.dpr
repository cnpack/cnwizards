program TestCompareProperties;

uses
  Forms,
  CnPropertyCompareFrm in '..\..\Source\DesignWizard\CnPropertyCompareFrm.pas' {CnPropertyCompareForm},
  UnitCompareProperties in 'UnitCompareProperties.pas' {FormTestCompare};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormTestCompare, FormTestCompare);
  Application.Run;
end.
