program CnFixStart;

uses
  Forms,
  CnFixStartUnit in 'CnFixStartUnit.pas' {FormStartFix},
  CnWizCompilerConst in '..\..\Source\Framework\CnWizCompilerConst.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormStartFix, FormStartFix);
  Application.Run;
end.
