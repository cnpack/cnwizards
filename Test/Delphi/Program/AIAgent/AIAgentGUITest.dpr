program AIAgentGUITest;

uses
  Forms,
  UnitAIAgentTestMain in 'UnitAIAgentTestMain.pas' {AIAgentTestForm},
  CnAIAgentTypes in '..\..\..\..\Source\AIAgent\CnAIAgentTypes.pas',
  CnAIAgentJsonRpc in '..\..\..\..\Source\AIAgent\CnAIAgentJsonRpc.pas',
  CnAIAgentStdioTransport in '..\..\..\..\Source\AIAgent\CnAIAgentStdioTransport.pas',
  CnAIAgentClient in '..\..\..\..\Source\AIAgent\CnAIAgentClient.pas',
  CnAIAgentTools in '..\..\..\..\Source\AIAgent\CnAIAgentTools.pas',
  CnAIAgentSession in '..\..\..\..\Source\AIAgent\CnAIAgentSession.pas',
  AIAgentTestToolMocks in '..\..\..\Lazarus\Program\AIAgent\AIAgentTestToolMocks.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAIAgentTestForm, AIAgentTestForm);
  Application.Run;
end.
