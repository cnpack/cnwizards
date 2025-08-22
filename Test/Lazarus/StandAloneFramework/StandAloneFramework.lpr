program StandAloneFramework;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms, CnMessageBoxWizard, CnAICoderChatFrm, CnAICoderConfig, CnAICoderEngine,
  CnAICoderEngineImpl, CnAICoderNetClient, CnFrmAICoderOption, CnAICoderWizard,
  StandAloneFrameworkUnit {FormFramework};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
