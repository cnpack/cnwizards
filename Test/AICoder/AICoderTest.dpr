program AICoderTest;

uses
  Forms,
  AICoderUnit in 'AICoderUnit.pas' {FormAITest},
  CnAICoderConfig in '..\..\Source\AICoder\CnAICoderConfig.pas',
  CnAICoderEngine in '..\..\Source\AICoder\CnAICoderEngine.pas',
  CnAICoderNetClient in '..\..\Source\AICoder\CnAICoderNetClient.pas',
  CnAICoderEngineImpl in '..\..\Source\AICoder\CnAICoderEngineImpl.pas',
  CnChatBox in '..\..\Source\Utils\CnChatBox.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormAITest, FormAITest);
  Application.Run;
end.
