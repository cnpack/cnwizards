program BuildLauncher;

uses
  Forms,
  UnitBuild in 'UnitBuild.pas' {AppBuillder};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAppBuillder, AppBuillder);
  Application.Run;
end.
