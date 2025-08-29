program AICoderTest;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  AICoderUnit in 'AICoderUnit.pas' {FormAITest},
  CnAICoderConfig, CnAICoderEngine, CnAICoderNetClient, CnAICoderEngineImpl;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormAITest, FormAITest);
  Application.Run;
end.
