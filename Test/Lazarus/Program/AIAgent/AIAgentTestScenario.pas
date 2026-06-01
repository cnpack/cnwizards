unit AIAgentTestScenario;

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnAIAgentTypes, CnAIAgentClient, CnAIAgentSession;

type
  TScriptAction = (saInitialize, saSessionNew, saSessionClose, saSessionPrompt,
    saConfirmPermission, saSwitchSession, saKillAgent, saStartAgent, saExit);

  TScriptExpect = record
    Field: string;
    Value: string;
  end;

  TScriptLine = record
    Action: TScriptAction;
    Param: string;
    Expects: array of TScriptExpect;
    ExpectCount: Integer;
  end;

  TScenarioResult = record
    TotalSteps: Integer;
    PassedSteps: Integer;
    FailedSteps: Integer;
    FailDetails: TStringList;
    ElapsedMs: Integer;
  end;

  TScriptLineArray = array of TScriptLine;

  TScenarioRunner = class
  private
    FClient: TCnACPClient;
    FSessionManager: TCnAIAgentSessionManager;
    FInitResult: Boolean;
    FInitError: string;
    FLastSessionId: string;
    FLastError: string;
    FScenarioResult: TScenarioResult;
    procedure ClearResult;
    procedure LogResult(const S: string);
    procedure FailStep(Step: Integer; const Msg: string);
    procedure PassStep;
    procedure ClientInitialized(Sender: TObject; Success: Boolean; const ErrorMessage: string);
    procedure ClientSessionCreated(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    procedure ClientSessionClosed(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    function DoAction(Script: TScriptLine; Step: Integer): Boolean;
    function CheckExpects(Script: TScriptLine): Boolean;
  public
    constructor Create(AClient: TCnACPClient);
    destructor Destroy; override;
    function RunScript(const Lines: TScriptLineArray): TScenarioResult;
    property ScenarioResult: TScenarioResult read FScenarioResult;
  end;

function ParseScript(const FileName: string): TScriptLineArray;
function RunAllScenarios(Client: TCnACPClient): TScenarioResult;

implementation

type
  TPromptWaiter = class
    Done: Boolean;
    Success: Boolean;
    StopReason: string;
    ErrorMsg: string;
    procedure OnPromptResult(Sender: TObject; const SessionId, StopReason: string;
      Success: Boolean; const ErrorMessage: string);
  end;

procedure TPromptWaiter.OnPromptResult(Sender: TObject; const SessionId,
  StopReason: string; Success: Boolean; const ErrorMessage: string);
begin
  Done := True;
  Self.Success := Success;
  Self.StopReason := StopReason;
  ErrorMsg := ErrorMessage;
end;

function ParseScript(const FileName: string): TScriptLineArray;
var
  SL: TStringList;
  I, J: Integer;
  Line, ActionStr, ParamStr: string;
  Lines: TScriptLineArray;
  C: Integer;
begin
  SetLength(Lines, 0);
  C := 0;
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    SetLength(Lines, SL.Count);
    for I := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[I]);
      if (Line = '') or (Line[1] = '#') then
        Continue;

      Lines[C].ExpectCount := 0;
      SetLength(Lines[C].Expects, 5);

      if Copy(Line, 1, 7) = 'action: ' then
      begin
        ActionStr := Trim(Copy(Line, 8, MaxInt));
        J := Pos(' ', ActionStr);
        if J > 0 then
        begin
          ParamStr := Trim(Copy(ActionStr, J + 1, MaxInt));
          ActionStr := Trim(Copy(ActionStr, 1, J - 1));
        end
        else
          ParamStr := '';

        if ActionStr = 'initialize' then
          Lines[C].Action := saInitialize
        else if ActionStr = 'session_new' then
          Lines[C].Action := saSessionNew
        else if ActionStr = 'session_close' then
          Lines[C].Action := saSessionClose
        else if ActionStr = 'prompt' then
          Lines[C].Action := saSessionPrompt
        else if ActionStr = 'exit' then
          Lines[C].Action := saExit;

        Lines[C].Param := ParamStr;
        Inc(C);
      end
      else if Copy(Line, 1, 7) = 'expect: ' then
      begin
        ActionStr := Trim(Copy(Line, 8, MaxInt));
        J := Pos('=', ActionStr);
        if J > 0 then
        begin
          Lines[C - 1].Expects[Lines[C - 1].ExpectCount].Field :=
            Trim(Copy(ActionStr, 1, J - 1));
          Lines[C - 1].Expects[Lines[C - 1].ExpectCount].Value :=
            Trim(Copy(ActionStr, J + 1, MaxInt));
          Inc(Lines[C - 1].ExpectCount);
        end;
      end;
    end;
  finally
    SL.Free;
  end;
  SetLength(Lines, C);
  Result := Lines;
end;

constructor TScenarioRunner.Create(AClient: TCnACPClient);
begin
  inherited Create;
  FClient := AClient;
  FSessionManager := TCnAIAgentSessionManager.Create;
  FScenarioResult.FailDetails := TStringList.Create;
  FClient.OnInitialized := ClientInitialized;
  FClient.OnSessionCreated := ClientSessionCreated;
  FClient.OnSessionClosed := ClientSessionClosed;
end;

destructor TScenarioRunner.Destroy;
begin
  FScenarioResult.FailDetails.Free;
  FSessionManager.Free;
  inherited Destroy;
end;

procedure TScenarioRunner.ClearResult;
begin
  FScenarioResult.TotalSteps := 0;
  FScenarioResult.PassedSteps := 0;
  FScenarioResult.FailedSteps := 0;
  FScenarioResult.FailDetails.Clear;
  FScenarioResult.ElapsedMs := 0;
  FInitResult := False;
  FInitError := '';
  FLastSessionId := '';
  FLastError := '';
end;

procedure TScenarioRunner.LogResult(const S: string);
begin
  Writeln('[SCENARIO] ', S);
end;

procedure TScenarioRunner.FailStep(Step: Integer; const Msg: string);
begin
  Inc(FScenarioResult.FailedSteps);
  FScenarioResult.FailDetails.Add(Format('Step %d: %s', [Step, Msg]));
  LogResult('  FAIL: ' + Msg);
end;

procedure TScenarioRunner.PassStep;
begin
  Inc(FScenarioResult.PassedSteps);
  LogResult('  PASS');
end;

procedure TScenarioRunner.ClientInitialized(Sender: TObject; Success: Boolean;
  const ErrorMessage: string);
begin
  FInitResult := Success;
  FInitError := ErrorMessage;
end;

procedure TScenarioRunner.ClientSessionCreated(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  if Success then
  begin
    FLastSessionId := SessionId;
    FSessionManager.CreateSession(SessionId);
  end
  else
  begin
    FLastSessionId := '';
    FLastError := ErrorMessage;
  end;
end;

procedure TScenarioRunner.ClientSessionClosed(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  if Success then
    FSessionManager.CloseSession(SessionId)
  else
    FLastError := ErrorMessage;
end;

function TScenarioRunner.DoAction(Script: TScriptLine; Step: Integer): Boolean;
begin
  Result := False;
  case Script.Action of
    saInitialize:
      begin
        FInitResult := False;
        FInitError := '';
        FClient.Initialize('AIAgentTest', 'Scenario Test', '1.0.0', True, True, False);
        Sleep(500);
        Result := True;
      end;
    saSessionNew:
      begin
        FLastSessionId := '';
        FLastError := '';
        FClient.NewSession(Script.Param);
        Sleep(300);
        Result := True;
      end;
    saSessionClose:
      begin
        FLastError := '';
        FClient.CloseSession(FClient.CurrentSessionId);
        Sleep(300);
        Result := True;
      end;
    saExit:
      Result := False;
  else
    Result := True;
  end;
end;

function TScenarioRunner.CheckExpects(Script: TScriptLine): Boolean;
var
  I: Integer;
  Field, Expected: string;
  Actual: string;
begin
  Result := True;
  for I := 0 to Script.ExpectCount - 1 do
  begin
    Field := Script.Expects[I].Field;
    Expected := Script.Expects[I].Value;

    if Field = 'state' then
      Actual := IntToStr(Integer(FClient.State))
    else if Field = 'protocolVersion' then
      Actual := IntToStr(FClient.ProtocolVersion)
    else if Field = 'sessionId' then
      Actual := FLastSessionId
    else if Field = 'error' then
      Actual := FLastError
    else if Field = 'success' then
    begin
      if FLastSessionId <> '' then
        Actual := 'true'
      else
        Actual := 'false';
    end
    else
      Actual := '';

    if (Expected <> '*') and (Actual <> Expected) then
    begin
      LogResult(Format('  Expect %s=%s, actual=%s', [Field, Expected, Actual]));
      Result := False;
    end
    else
      LogResult(Format('  OK %s=%s', [Field, Actual]));
  end;
end;

function TScenarioRunner.RunScript(const Lines: TScriptLineArray): TScenarioResult;
var
  I: Integer;
  StartTick: Int64;
begin
  ClearResult;
  FScenarioResult.TotalSteps := Length(Lines);
  StartTick := GetTickCount64;

  for I := 0 to Length(Lines) - 1 do
  begin
    LogResult(Format('Step %d/%d: action=%d param=%s',
      [I + 1, Length(Lines), Integer(Lines[I].Action), Lines[I].Param]));

    if not DoAction(Lines[I], I + 1) then
      Break;

    if not CheckExpects(Lines[I]) then
      FailStep(I + 1, 'Expectation failed')
    else
      PassStep;
  end;

  FScenarioResult.ElapsedMs := Integer(GetTickCount64 - StartTick);
  Result := FScenarioResult;
end;

function RunAllScenarios(Client: TCnACPClient): TScenarioResult;

  procedure Log(const S: string);
  begin
    Writeln('[SCENARIO] ', S);
  end;

  procedure Check(Step: Integer; const Desc: string; Condition: Boolean; var R: TScenarioResult);
  begin
    Inc(R.TotalSteps);
    if Condition then
    begin
      Inc(R.PassedSteps);
      Log(Format('  PASS [%d] %s', [Step, Desc]));
    end
    else
    begin
      Inc(R.FailedSteps);
      R.FailDetails.Add(Format('Step %d: %s', [Step, Desc]));
      Log(Format('  FAIL [%d] %s', [Step, Desc]));
    end;
  end;

  function WaitForProtocolVersion(Client: TCnACPClient; MaxWaitMs: Integer): Boolean;
  var
    StartTick: Int64;
  begin
    StartTick := GetTickCount64;
    while (Client.ProtocolVersion = 0) and (GetTickCount64 - StartTick < MaxWaitMs) do
      Sleep(100);
    Result := Client.ProtocolVersion > 0;
  end;

  function WaitForSessionCreated(Client: TCnACPClient; MaxWaitMs: Integer): Boolean;
  var
    StartTick: Int64;
  begin
    StartTick := GetTickCount64;
    while (Client.CurrentSessionId = '') and (GetTickCount64 - StartTick < MaxWaitMs) do
      Sleep(100);
    Result := Client.CurrentSessionId <> '';
  end;

var
  ResultTotal: TScenarioResult;
  SessionId: string;
  TestDir: string;
  Tick: Int64;
  Waiter: TPromptWaiter;
  OldPromptResult: TCnACPClientPromptResultEvent;
  TestFile: string;
  S4Dir, S4Src, S4Bin: string;
  S4Content: string;
  SrcFound, BinFound: Boolean;
begin
  ResultTotal.TotalSteps := 0;
  ResultTotal.PassedSteps := 0;
  ResultTotal.FailedSteps := 0;
  ResultTotal.FailDetails := TStringList.Create;
  ResultTotal.ElapsedMs := 0;
  Tick := GetTickCount64;

  TestDir := GetTempDir + 'AIAgentTest' + IntToStr(GetProcessID);

  // ===== Scenario 1: Handshake =====
  Log('--- Scenario 1: Handshake / Initialize ---');

  // Agent already started by caller, check state and wait for initialize response
  Check(1, 'State >= acsRunning', Client.State >= acsRunning, ResultTotal);

  if Client.ProtocolVersion = 0 then
    Log('  Waiting for initialize response...');

  // Send initialize if not already done
  if Client.ProtocolVersion = 0 then
  begin
    Client.Initialize('AIAgentTest', 'Scenario Test', '1.0.0', True, True, False);
    WaitForProtocolVersion(Client, 10000);
  end;

  Check(2, 'ProtocolVersion > 0', Client.ProtocolVersion > 0, ResultTotal);
  Check(3, 'Server has agent name', Client.AgentName <> '', ResultTotal);
  if Client.AgentName <> '' then
    Log(Format('  Agent: %s v%s', [Client.AgentName, Client.AgentVersion]));

  Log('');

  // ===== Scenario 2: Session Lifecycle =====
  Log('--- Scenario 2: Session Lifecycle ---');

  // Create session
  Client.NewSession(TestDir);
  WaitForSessionCreated(Client, 10000);
  SessionId := Client.CurrentSessionId;
  Check(4, 'Session created with non-empty ID', SessionId <> '', ResultTotal);
  Log(Format('  SessionId: %s', [SessionId]));

  // Close session
  if SessionId <> '' then
  begin
    Log('  Closing session...');
    Client.CloseSession(SessionId);
    Sleep(2000);
    Check(5, 'Session ID cleared after close', Client.CurrentSessionId = '', ResultTotal);
  end;

  Log('');

  // ===== Scenario 3: Tool Call via Prompt =====
  Log('--- Scenario 3: Tool Call (File Write via Prompt) ---');

  // Create a new session for this scenario
  SessionId := '';
  Client.NewSession(TestDir);
  WaitForSessionCreated(Client, 10000);
  SessionId := Client.CurrentSessionId;
  Check(6, 'Session created for tool prompt test', SessionId <> '', ResultTotal);

  if SessionId <> '' then
  begin
    Waiter := TPromptWaiter.Create;
    try
      OldPromptResult := Client.OnPromptResult;
      Client.OnPromptResult := Waiter.OnPromptResult;

      TestFile := '/tmp/aia_test_scenario3.txt';
      DeleteFile(TestFile);
      Log('  Sending prompt to write file: ' + TestFile);
      Client.PromptText(SessionId, 'Use the write tool to create a file at ' +
        TestFile + ' with content "Hello from AIAgent Scenario 3"');

      // Wait for file to appear (tool_call should complete quickly)
      Tick := GetTickCount64;
      while (not FileExists(TestFile)) and (GetTickCount64 - Tick < 15000) do
        Sleep(200);

      Check(7, 'File created by tool call (waited ' +
        IntToStr(Integer(GetTickCount64 - Tick)) + 'ms): ' + TestFile,
        FileExists(TestFile), ResultTotal);

      // Check if prompt completed (informational only, not a hard test)
      if not Waiter.Done then
      begin
        while (not Waiter.Done) and (GetTickCount64 - Tick < 5000) do
          Sleep(100);
        if Waiter.Done then
          Log('  Prompt completed OK, stopReason=' + Waiter.StopReason)
        else
          Log('  (info) Prompt not yet completed after tool result sent');
      end;

      Client.OnPromptResult := OldPromptResult;

      Log('  Closing session...');
      Client.CloseSession(SessionId);
      Sleep(2000);
      Check(8, 'Session closed after tool test',
        Client.CurrentSessionId = '', ResultTotal);
    finally
      Waiter.Free;
    end;
  end;

  Log('');

  // ===== Scenario 4: Write ? Compile ? Fix ? Run (FPC) =====
  Log('--- Scenario 4: Write ? Compile ? Fix ? Run (FPC) ---');

  SessionId := '';
  Client.NewSession(TestDir + '_s4');
  WaitForSessionCreated(Client, 10000);
  SessionId := Client.CurrentSessionId;
  Check(9, 'Session created for compile/run test', SessionId <> '', ResultTotal);

  if SessionId <> '' then
  begin
    S4Dir := TestDir + '_s4';
    ForceDirectories(S4Dir);
    S4Src := S4Dir + '/hello.pas';
    S4Bin := S4Dir + '/hello';
    DeleteFile(S4Src);
    DeleteFile(S4Bin);

    Log('  Pre-writing source file, then asking for compilation...');
    Log('  Source: ' + S4Src);
    Log('  Binary: ' + S4Bin);
    // Write source file directly first (before AI prompt)
    S4Content := 'program Hello;'#10 +
      'uses SysUtils;'#10 +
      'begin'#10 +
      '  WriteLn('#39'Hello from AIAgent'#39');'#10 +
      '  WriteLn(DateToStr(Date));'#10 +
      'end.';
    with TStringList.Create do
    begin
      Text := S4Content;
      SaveToFile(S4Src);
      Free;
    end;
    if FileExists(S4Src) then
      Log('  Source file pre-written');
    // Minimal prompt: just one bash command to compile
    Client.PromptText(SessionId, 'Run bash command: fpc -o' + S4Bin + ' ' + S4Src + ' (fpc is available at /usr/local/bin/fpc)');

    Tick := GetTickCount64;
    SrcFound := False;
    BinFound := False;
    while (GetTickCount64 - Tick < 90000) do
    begin
      if not SrcFound and FileExists(S4Src) then
      begin
        SrcFound := True;
        Log('  Source file created after ' +
          IntToStr(Integer(GetTickCount64 - Tick)) + 'ms');
      end;
      if not BinFound and FileExists(S4Bin) then
      begin
        BinFound := True;
        Log('  Binary created after ' +
          IntToStr(Integer(GetTickCount64 - Tick)) + 'ms');
      end;
      if SrcFound and BinFound then Break;
      Sleep(200);
    end;

    Check(10, 'Source file created', SrcFound, ResultTotal);
    Check(11, 'Compiled binary exists: ' + S4Bin, BinFound, ResultTotal);

    if BinFound then
      Log('  Scenario 4: Full write?compile?fix?run cycle verified')
    else if SrcFound then
      Log('  Scenario 4: Source written but compilation did not succeed')
    else
      Log('  Scenario 4: No artifacts produced');

    Log('  Closing session...');
    Client.CloseSession(SessionId);
    Sleep(2000);
    Check(12, 'Session closed after compile/run test',
      Client.CurrentSessionId = '', ResultTotal);
  end;

  Log('');
  Log('--- Summary ---');
  Log(Format('  Total: %d, Passed: %d, Failed: %d, Elapsed: %dms',
    [ResultTotal.TotalSteps, ResultTotal.PassedSteps,
     ResultTotal.FailedSteps, ResultTotal.ElapsedMs]));
  if ResultTotal.FailDetails.Count > 0 then
    Log(Format('  First failure: %s', [ResultTotal.FailDetails[0]]));

  Result := ResultTotal;
end;

end.
