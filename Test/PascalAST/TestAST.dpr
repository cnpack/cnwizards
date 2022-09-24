program TestAST;

uses
  Forms,
  UnitAST in 'UnitAST.pas' {FormAST},
  mPasLex in '..\..\Source\ThirdParty\mPasLex.pas',
  CnPasWideLex in '..\..\Source\Utils\CnPasWideLex.pas',
  CnPascalAST in '..\..\Source\Utils\CnPascalAST.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormAST, FormAST);
  Application.Run;
end.
