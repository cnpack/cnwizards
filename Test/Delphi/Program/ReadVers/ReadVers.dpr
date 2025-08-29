program ReadVers;

uses
  Forms,
  UnitVers in 'UnitVers.pas' {FormVers};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormVers, FormVers);
  Application.Run;
end.
