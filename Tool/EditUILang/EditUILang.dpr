program EditUILang;

{$IFNDEF UNICODE}
  Error 'Only Unicode'
{$ENDIF}

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
