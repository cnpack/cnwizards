unit AIAgentTestReplay;

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnAIAgentTypes, CnAIAgentClient;

type
  TReplayMode = (rmInteractive, rmScript, rmReplay);

  TReplayEngine = class
  private
    FClient: TCnACPClient;
    FMode: TReplayMode;
    FScriptFile: string;
    FLogLines: TStringList;
    procedure Log(const S: string);
    procedure PrintPrompt;
    function ReadCommand: string;
    function ProcessCommand(const Cmd: string): Boolean;
    function WaitForSession(MaxWaitMs: Integer): Boolean;
    procedure DoNew(const Param: string);
    procedure DoPrompt(const Param: string);
    procedure DoSessions;
    procedure DoSwitch(const Param: string);
    procedure DoClose(const Param: string);
    procedure DoWait(const Param: string);
    procedure DoHelp;
  public
    constructor Create(AClient: TCnACPClient);
    destructor Destroy; override;
    procedure RunInteractive;
    procedure RunScript(const FileName: string);
    procedure RunReplay(const FileName: string);
    property LogLines: TStringList read FLogLines;
  end;

implementation

constructor TReplayEngine.Create(AClient: TCnACPClient);
begin
  inherited Create;
  FClient := AClient;
  FLogLines := TStringList.Create;
end;

destructor TReplayEngine.Destroy;
begin
  FLogLines.Free;
  inherited Destroy;
end;

procedure TReplayEngine.Log(const S: string);
begin
  FLogLines.Add(S);
  Writeln(S);
end;

procedure TReplayEngine.PrintPrompt;
begin
  Write('AIAgent> ');
end;

function TReplayEngine.ReadCommand: string;
var
  S: string;
begin
  if Eof then
  begin
    Result := '/quit';
    Exit;
  end;
  Readln(S);
  Result := Trim(S);
end;

function TReplayEngine.WaitForSession(MaxWaitMs: Integer): Boolean;
var
  Tick: Int64;
begin
  Tick := GetTickCount64;
  while (FClient.CurrentSessionId = '') and (GetTickCount64 - Tick < MaxWaitMs) do
    Sleep(50);
  Result := FClient.CurrentSessionId <> '';
end;

function TReplayEngine.ProcessCommand(const Cmd: string): Boolean;
var
  Parts: TStringList;
  Action, Param: string;
begin
  Result := True;
  if Cmd = '' then
    Exit;

  Parts := TStringList.Create;
  try
    Parts.DelimitedText := Cmd;
    if Parts.Count = 0 then
      Exit;

    Action := LowerCase(Trim(Parts[0]));
    Param := '';
    if Parts.Count > 1 then
      Param := Copy(Cmd, Pos(' ', Cmd) + 1, MaxInt);

    if Action = '/new' then
      DoNew(Param)
    else if Action = '/prompt' then
      DoPrompt(Param)
    else if Action = '/sessions' then
      DoSessions
    else if Action = '/switch' then
      DoSwitch(Param)
    else if Action = '/close' then
      DoClose(Param)
    else if Action = '/wait' then
      DoWait(Param)
    else if (Action = '/quit') or (Action = '/exit') then
      Result := False
    else if Action = '/help' then
      DoHelp
    else
      Log('Unknown command: ' + Action + '  Type /help for commands.');
  finally
    Parts.Free;
  end;
end;

procedure TReplayEngine.DoNew(const Param: string);
var
  Cwd: string;
begin
  if Param <> '' then
    Cwd := Param
  else
    Cwd := GetCurrentDir;
  Log('Creating session with cwd: ' + Cwd);
  if Assigned(FClient) then
  begin
    FClient.NewSession(Cwd);
    if WaitForSession(10000) then
      Log('Session created: ' + FClient.CurrentSessionId)
    else
      Log('Session creation timed out');
  end;
end;

procedure TReplayEngine.DoPrompt(const Param: string);
begin
  if Param = '' then
  begin
    Log('Usage: /prompt <text>');
    Exit;
  end;
  Log('Sending prompt: ' + Param);
  if Assigned(FClient) and (FClient.CurrentSessionId <> '') then
    FClient.PromptText(FClient.CurrentSessionId, Param)
  else
    Log('No active session. Use /new first.');
end;

procedure TReplayEngine.DoSessions;
begin
  Log('Current session: ' + FClient.CurrentSessionId);
  Log('State: ' + IntToStr(Integer(FClient.State)));
end;

procedure TReplayEngine.DoSwitch(const Param: string);
begin
  if Param = '' then
    Log('Usage: /switch <sessionId>')
  else
    Log('Switch to session: ' + Param + '  (stub)');
end;

procedure TReplayEngine.DoClose(const Param: string);
var
  Id: string;
begin
  if Param <> '' then
    Id := Param
  else
    Id := FClient.CurrentSessionId;
  if Id <> '' then
  begin
    Log('Closing session: ' + Id);
    FClient.CloseSession(Id);
  end
  else
    Log('No session to close.');
end;

procedure TReplayEngine.DoHelp;
begin
  Log('Available commands:');
  Log('  /new [dir]       Create new session');
  Log('  /prompt <text>   Send prompt to current session');
  Log('  /sessions        List sessions');
  Log('  /switch <id>     Switch active session');
  Log('  /close [id]      Close session');
  Log('  /wait <ms>       Wait for milliseconds');
  Log('  /quit            Exit');
  Log('  /help            This help');
end;

procedure TReplayEngine.DoWait(const Param: string);
var
  Ms: Integer;
begin
  Ms := StrToIntDef(Param, 5000);
  if Ms <= 0 then Ms := 5000;
  if Ms > 30000 then Ms := 30000;
  Log('Waiting ' + IntToStr(Ms) + 'ms...');
  Sleep(Ms);
end;

procedure TReplayEngine.RunInteractive;
var
  Running: Boolean;
  Cmd: string;
begin
  Log('AIAgent Test Console - Type /help for commands');
  Running := True;
  while Running do
  begin
    PrintPrompt;
    Cmd := ReadCommand;
    Running := ProcessCommand(Cmd);
  end;
  Log('Goodbye.');
end;

procedure TReplayEngine.RunScript(const FileName: string);
begin
  Log('Script mode not yet implemented: ' + FileName);
end;

procedure TReplayEngine.RunReplay(const FileName: string);
begin
  Log('Replay mode not yet implemented: ' + FileName);
end;

end.
