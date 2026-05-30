program AIAgentTest;

{$I CnPack.inc}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils, Classes, CnJSON,
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

procedure RunToolTests;
var
  LocalTM: TCnAIAgentToolManager;
  LocalMD: TMockData;
  Args, ResultObj: TCnJSONObject;
  ArgsArr: TCnJSONArray;
  TR: TCnAIAgentToolExecuteResult;
  SL: TStringList;
  TestDir, TestFile: string;
begin
  TestDir := GetTempDir + 'AIAgentToolTest_' + IntToStr(GetProcessID);
  TestFile := TestDir + '/testwrite.pas';
  ForceDirectories(TestDir);

  LocalTM := TCnAIAgentToolManager.Create;
  LocalMD := CreateDefaultMockData;
  try
    LocalTM.RegisterAllDefaultTools;
    RegisterMockTools(LocalTM, LocalMD);
    Writeln('Registered ', LocalTM.ToolCount, ' tools');

    // ---- Test 1: fs/write_text_file ----
    Writeln;
    Writeln('--- Test 1: fs/write_text_file ---');
    Args := TCnJSONObject.Create;
    ResultObj := TCnJSONObject.Create;
    try
      Args.AddPair('path', TestFile);
      Args.AddPair('content', 'program Hello;'#10'begin'#10'  Writeln(''Hello'');'#10'end.');
      TR := LocalTM.ExecuteTool('fs/write_text_file', Args, LocalMD);
      if TR.Success then
      begin
        if FileExists(TestFile) then
        begin
          SL := TStringList.Create;
          try
            SL.LoadFromFile(TestFile);
            Writeln('  PASS: File created, content="', Trim(SL.Text), '"');
          finally
            SL.Free;
          end;
        end
        else
          Writeln('  FAIL: tool returned success but file not found');
      end
      else
        Writeln('  FAIL: ', TR.ErrorMessage);
    finally
      Args.Free;
      ResultObj.Free;
    end;

    // ---- Test 2: fs/read_text_file ----
    Writeln;
    Writeln('--- Test 2: fs/read_text_file ---');
    Args := TCnJSONObject.Create;
    try
      Args.AddPair('path', TestFile);
      TR := LocalTM.ExecuteTool('fs/read_text_file', Args, LocalMD);
      if TR.Success then
        Writeln('  PASS: read back content="', TR.ResultData.ValueByName['content'].AsString, '"')
      else
        Writeln('  FAIL: ', TR.ErrorMessage);
    finally
      Args.Free;
    end;

    // ---- Test 3: run/execute_command (fpc --version) ----
    Writeln;
    Writeln('--- Test 3: run/execute_command (fpc --version) ---');
    Args := TCnJSONObject.Create;
    ResultObj := TCnJSONObject.Create;
    try
      Args.AddPair('command', 'fpc');
      ArgsArr := TCnJSONArray.Create;
      ArgsArr.AddValue('--version');
      Args.AddPair('args', ArgsArr);
      Args.AddPair('cwd', TestDir);
      Args.AddPair('timeout', 15000);
      TR := LocalTM.ExecuteTool('run/execute_command', Args, LocalMD);
      if TR.Success then
      begin
        Writeln('  PASS: exitCode=', TR.ResultData.ValueByName['exitCode'].AsString);
        Writeln('  stdout: ', Trim(TR.ResultData.ValueByName['stdout'].AsString));
        Writeln('  stderr: ', Trim(TR.ResultData.ValueByName['stderr'].AsString));
      end
      else
        Writeln('  FAIL: ', TR.ErrorMessage);
    finally
      Args.Free;
      ResultObj.Free;
    end;

    // ---- Test 4: run/execute_command (fpc compile testwrite.pas) ----
    Writeln;
    Writeln('--- Test 4: run/execute_command (fpc compile) ---');
    Args := TCnJSONObject.Create;
    ResultObj := TCnJSONObject.Create;
    try
      Args.AddPair('command', 'fpc');
      ArgsArr := TCnJSONArray.Create;
      ArgsArr.AddValue(TestFile);
      ArgsArr.AddValue('-o' + TestDir + '/testwrite');
      Args.AddPair('args', ArgsArr);
      Args.AddPair('cwd', TestDir);
      Args.AddPair('timeout', 30000);
      TR := LocalTM.ExecuteTool('run/execute_command', Args, LocalMD);
      if TR.Success then
      begin
        Writeln('  exitCode=', TR.ResultData.ValueByName['exitCode'].AsString);
        Writeln('  stdout: ', Trim(TR.ResultData.ValueByName['stdout'].AsString));
        Writeln('  stderr: ', Trim(TR.ResultData.ValueByName['stderr'].AsString));
        if TR.ResultData.ValueByName['exitCode'].AsInteger = 0 then
        begin
          Writeln('  PASS: compilation succeeded');
          if FileExists(TestDir + '/testwrite') or FileExists(TestDir + '/testwrite.exe') then
            Writeln('  PASS: binary exists');
        end
        else
          Writeln('  FAIL: compilation failed');
      end
      else
        Writeln('  FAIL: ', TR.ErrorMessage);
    finally
      Args.Free;
      ResultObj.Free;
    end;

  finally
    LocalTM.Free;
    LocalMD.Free;
  end;
end;

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
    end
    else if ParamStr(I) = '--tooltest' then
    begin
      Mode := 'tooltest';
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
      end
      else if Mode = 'tooltest' then
      begin
        RunToolTests;
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
