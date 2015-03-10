program CnTestGroupReplace;

uses
  Forms,
  CnTestGroupReplaceUnit in 'CnTestGroupReplaceUnit.pas' {GroupReplaceForm},
  CnGroupReplace in '..\..\Source\Utils\CnGroupReplace.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TGroupReplaceForm, GroupReplaceForm);
  Application.Run;
end.
