program AIAgentTest;

{$I CnPack.inc}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils, Classes,
  CnAIAgentTypes, CnAIAgentJsonRpc, CnAIAgentStdioTransport, CnAIAgentClient,
  CnAIAgentTools, CnAIAgentSession,
  AIAgentTestConsts, AIAgentTestReplay, AIAgentTestToolMocks,
  AIAgentTestScenario;

type
  TEventHandler = class
  public
    procedure Log(Sender: TObject; const Text: string);
    procedure StateChanged(Sender: TObject; State: TCnACPConnectionState);
    procedure Initialized(Sender: TObject; Success: Boolean;
      const ErrorMessage: string);
    procedure Authenticated(Sender: TObject; Success: Boolean;
      const ErrorMessage: string);
    procedure SessionCreated(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    procedure SessionClosed(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    procedure SessionUpdate(Sender: TObject; const SessionId,
      UpdateJson: string);
  end;

var
  Client: TCnACPClient;
  Engine: TReplayEngine;
  Handler: TEventHandler;
  ToolManager: TCnAIAgentToolManager;
  MockData: TMockData;
  SessionManager: TCnAIAgentSessionManager;
  AgentPath, AgentArgs: string;
  Mode: string;
  I: Integer;
  R: TScenarioResult;

procedure TEventHandler.Log(Sender: TObject; const Text: string);
begin
  Writeln('[LOG] ', Text);
end;

procedure TEventHandler.StateChanged(Sender: TObject; State: TCnACPConnectionState);
begin
  Writeln('[STATE] ', Integer(State));
end;

procedure TEventHandler.Initialized(Sender: TObject; Success: Boolean;
  const ErrorMessage: string);
begin
  if Success then
    Writeln('[INIT] ACP initialized OK. Protocol v', Client.ProtocolVersion,
      ' Agent: ', Client.AgentName, ' ', Client.AgentVersion)
  else
    Writeln('[INIT] Failed: ', ErrorMessage);
end;

procedure TEventHandler.Authenticated(Sender: TObject; Success: Boolean;
  const ErrorMessage: string);
begin
  if Success then
    Writeln('[AUTH] Authenticated OK')
  else
    Writeln('[AUTH] Failed: ', ErrorMessage);
end;

procedure TEventHandler.SessionCreated(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  if Success then
  begin
    Writeln('[SESSION] Created: ', SessionId);
    SessionManager.CreateSession(SessionId);
  end
  else
    Writeln('[SESSION] Create failed: ', ErrorMessage);
end;

procedure TEventHandler.SessionClosed(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  if Success then
  begin
    Writeln('[SESSION] Closed: ', SessionId);
    SessionManager.CloseSession(SessionId);
  end
  else
    Writeln('[SESSION] Close failed: ', ErrorMessage);
end;

procedure TEventHandler.SessionUpdate(Sender: TObject;
  const SessionId, UpdateJson: string);
begin
  Writeln('[UPDATE] Session=', SessionId, ' Data=', UpdateJson);
end;

begin
  AgentPath := DEFAULT_AGENT_PATH;
  AgentArgs := DEFAULT_AGENT_ARGS;
  Mode := 'interactive';

  I := 1;
  while I <= ParamCount do
  begin
    if ParamStr(I) = '--agent' then
    begin
      Inc(I);
      if I <= ParamCount then AgentPath := ParamStr(I);
    end
    else if ParamStr(I) = '--args' then
    begin
      Inc(I);
      if I <= ParamCount then AgentArgs := ParamStr(I);
    end
    else if ParamStr(I) = '--script' then
    begin
      Inc(I);
      if I <= ParamCount then
      begin
        Mode := 'script';
        AgentArgs := ParamStr(I);
      end;
    end
    else if ParamStr(I) = '--replay' then
    begin
      Inc(I);
      if I <= ParamCount then
      begin
        Mode := 'replay';
        AgentArgs := ParamStr(I);
      end;
    end
    else if ParamStr(I) = '--run-all' then
    begin
      Mode := 'runall';
    end;
    Inc(I);
  end;

  Client := TCnACPClient.Create;
  Handler := TEventHandler.Create;
  ToolManager := TCnAIAgentToolManager.Create;
  MockData := CreateDefaultMockData;
  SessionManager := TCnAIAgentSessionManager.Create;
  try
    ToolManager.RegisterAllDefaultTools;
    RegisterMockTools(ToolManager, MockData);
    Client.ToolManager := ToolManager;

    Client.OnLog := Handler.Log;
    Client.OnStateChanged := Handler.StateChanged;
    Client.OnInitialized := Handler.Initialized;
    Client.OnAuthenticated := Handler.Authenticated;
    Client.OnSessionCreated := Handler.SessionCreated;
    Client.OnSessionClosed := Handler.SessionClosed;
    Client.OnSessionUpdate := Handler.SessionUpdate;

    Client.ConfigureTransport(AgentPath, AgentArgs, '');
    Writeln('Starting agent: ', AgentPath, ' ', AgentArgs);
    if not Client.StartAgent then
    begin
      Writeln('Failed to start agent');
      Halt(1);
    end;

    Client.Initialize('AIAgentTest', 'AIAgent Test Console', '1.0.0',
      True, True, False);

    Engine := TReplayEngine.Create(Client);
    try
      if Mode = 'interactive' then
        Engine.RunInteractive
      else if Mode = 'script' then
        Engine.RunScript(AgentArgs)
      else if Mode = 'replay' then
        Engine.RunReplay(AgentArgs)
      else if Mode = 'runall' then
      begin
        Writeln('Running all scenarios...');
        R := RunAllScenarios(Client);
        Writeln;
        Writeln('Results: ', R.PassedSteps, '/', R.TotalSteps, ' passed, ',
          R.FailedSteps, ' failed in ', R.ElapsedMs, 'ms');
        if R.FailDetails.Count > 0 then
        begin
          Writeln('Failures:');
          for I := 0 to R.FailDetails.Count - 1 do
            Writeln('  ', R.FailDetails[I]);
        end;
      end;
    finally
      Engine.Free;
    end;

    Client.StopAgent;
  finally
    SessionManager.Free;
    MockData.Free;
    ToolManager.Free;
    Handler.Free;
    Client.Free;
  end;
end.
