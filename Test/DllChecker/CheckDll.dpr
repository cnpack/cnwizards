program CheckDll;

uses
  Forms,
  UnitDll in 'UnitDll.pas' {FormCheck};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormCheck, FormCheck);
  Application.Run;
end.
