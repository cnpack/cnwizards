program EditLang;

uses
  Forms,
  EditLangUnit in 'EditLangUnit.pas' {EditLangForm};

{$R *.RES}
{$R ..\WindowsXP.RES}

begin
  Application.Initialize;
  Application.CreateForm(TEditLangForm, EditLangForm);
  Application.Run;
end.
