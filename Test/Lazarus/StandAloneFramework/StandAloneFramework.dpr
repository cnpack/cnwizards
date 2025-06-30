program StandAloneFramework;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  StandAloneFrameworkUnit in 'StandAloneFrameworkUnit.pas' {FormFramework};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
