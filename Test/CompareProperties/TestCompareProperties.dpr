program TestCompareProperties;

uses
  Forms,
  CnPropertyCompareFrm in '..\..\Source\DesignWizard\CnPropertyCompareFrm.pas' {CnPropertyCompareForm},
  UnitCompareProperties in 'UnitCompareProperties.pas' {FormTestCompare},
  CnWizShareImages in '..\..\Source\Misc\CnWizShareImages.pas' {dmCnSharedImages: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormTestCompare, FormTestCompare);
  Application.CreateForm(TdmCnSharedImages, dmCnSharedImages);
  Application.Run;
end.
