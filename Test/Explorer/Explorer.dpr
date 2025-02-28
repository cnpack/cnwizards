program Explorer;

uses
  Forms,
  UnitExplorer in 'UnitExplorer.pas' {Form5};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
