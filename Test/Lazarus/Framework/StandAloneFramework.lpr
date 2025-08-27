program StandAloneFramework;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms, CnMessageBoxWizard, CnProcListWizard, CnAICoderChatFrm,
  CnAICoderConfig, CnAICoderEngine, CnAICoderEngineImpl, CnAICoderNetClient,
  CnFrmAICoderOption, CnAICoderWizard, CnProjectViewBaseFrm,
  CnCodingToolsetWizard, CnEditorOpenFile, CnEditorOpenFileFrm,
  StandAloneFrameworkUnit {FormFramework};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormFramework, FormFramework);
  Application.Run;
end.
