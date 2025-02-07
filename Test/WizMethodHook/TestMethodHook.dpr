program TestMethodHook;

uses
  Vcl.Forms,
  UnitHook in 'UnitHook.pas' {FormHook};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormHook, FormHook);
  Application.Run;
end.
