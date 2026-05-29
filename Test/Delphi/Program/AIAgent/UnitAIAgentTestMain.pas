unit UnitAIAgentTestMain;

interface

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus,
  CnAIAgentTypes, CnAIAgentClient, CnAIAgentSession, CnAIAgentTools,
  AIAgentTestToolMocks;

type
  TAIAgentTestForm = class(TForm)
    pnlConnection: TPanel;
    lblAgentPath: TLabel;
    edtAgentPath: TEdit;
    lblAgentArgs: TLabel;
    edtAgentArgs: TEdit;
    btnStart: TButton;
    btnStop: TButton;
    pnlSession: TPanel;
    lblCwd: TLabel;
    edtCwd: TEdit;
    btnNewSession: TButton;
    btnCloseSession: TButton;
    edtSessionId: TEdit;
    lblSessionId: TLabel;
    pnlPrompt: TPanel;
    lblPrompt: TLabel;
    memPrompt: TMemo;
    btnSendPrompt: TButton;
    pnlLog: TPanel;
    memLog: TMemo;
    pnlToolStatus: TPanel;
    tvTools: TTreeView;
    lblState: TLabel;
    stsBar: TStatusBar;
    lblProtocol: TLabel;
    edtProtocol: TEdit;
    pnlSplitter: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnNewSessionClick(Sender: TObject);
    procedure btnCloseSessionClick(Sender: TObject);
    procedure btnSendPromptClick(Sender: TObject);
  private
    FClient: TCnACPClient;
    FSessionManager: TCnAIAgentSessionManager;
    FToolManager: TCnAIAgentToolManager;
    FMockData: TMockData;
    FSyncThread: TThread;

    FSyncMsg: string;
    FSyncSuccess: Boolean;
    FSyncErr: string;
    FSyncSessionId: string;

    procedure SyncLogProc;
    procedure SyncLogUpdate;
    procedure SyncInit;
    procedure SyncSessionCreated;
    procedure SyncSessionClosed;

    procedure Log(const S: string);
    procedure UpdateUIState;

    procedure OnClientLog(Sender: TObject; const Text: string);
    procedure OnClientStateChanged(Sender: TObject; State: TCnACPConnectionState);
    procedure OnClientInitialized(Sender: TObject; Success: Boolean;
      const ErrorMessage: string);
    procedure OnClientAuthenticated(Sender: TObject; Success: Boolean;
      const ErrorMessage: string);
    procedure OnClientSessionCreated(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    procedure OnClientSessionClosed(Sender: TObject; const SessionId: string;
      Success: Boolean; const ErrorMessage: string);
    procedure OnClientSessionUpdate(Sender: TObject; const SessionId,
      UpdateJson: string);
    procedure OnClientPromptResult(Sender: TObject; const SessionId,
      StopReason: string; Success: Boolean; const ErrorMessage: string);

    procedure PopulateToolTree;
  public
  end;

var
  AIAgentTestForm: TAIAgentTestForm;

implementation

{$R *.dfm}

type
  TThreadHack = class(TThread);

procedure TAIAgentTestForm.FormCreate(Sender: TObject);
begin
  FClient := TCnACPClient.Create;
  FSessionManager := TCnAIAgentSessionManager.Create;
  FToolManager := TCnAIAgentToolManager.Create;
  FMockData := CreateDefaultMockData;
  FSyncThread := TThread.Create(True);

  FToolManager.RegisterAllDefaultTools;
  RegisterMockTools(FToolManager, FMockData);
  FClient.ToolManager := FToolManager;

  FClient.OnLog := OnClientLog;
  FClient.OnStateChanged := OnClientStateChanged;
  FClient.OnInitialized := OnClientInitialized;
  FClient.OnAuthenticated := OnClientAuthenticated;
  FClient.OnSessionCreated := OnClientSessionCreated;
  FClient.OnSessionClosed := OnClientSessionClosed;
  FClient.OnSessionUpdate := OnClientSessionUpdate;
  FClient.OnPromptResult := OnClientPromptResult;

  edtAgentPath.Text := 'opencode';
  edtAgentArgs.Text := 'acp';
  edtCwd.Text := GetCurrentDir;

  UpdateUIState;
  PopulateToolTree;
  Log('GUI Test ready. Configure agent path and click Start.');
end;

procedure TAIAgentTestForm.FormDestroy(Sender: TObject);
begin
  FClient.StopAgent;
  FSyncThread.Free;
  FSessionManager.Free;
  FToolManager.Free;
  FMockData.Free;
  FClient.Free;
end;

procedure TAIAgentTestForm.Log(const S: string);
begin
  memLog.Lines.Add(FormatDateTime('[hh:nn:ss.zzz] ', Now) + S);
end;

procedure TAIAgentTestForm.UpdateUIState;
var
  Running: Boolean;
  HasSession: Boolean;
begin
  Running := FClient.State >= acsRunning;
  HasSession := FClient.CurrentSessionId <> '';

  btnStart.Enabled := not Running;
  btnStop.Enabled := Running;
  edtAgentPath.Enabled := not Running;
  edtAgentArgs.Enabled := not Running;

  btnNewSession.Enabled := Running;
  btnCloseSession.Enabled := Running and HasSession;
  edtCwd.Enabled := Running;
  btnSendPrompt.Enabled := Running and HasSession;
  memPrompt.Enabled := Running and HasSession;

  case FClient.State of
    acsIdle: lblState.Caption := 'Idle';
    acsStarting: lblState.Caption := 'Starting...';
    acsRunning: lblState.Caption := 'Running';
    acsClosed: lblState.Caption := 'Closed';
    acsError: lblState.Caption := 'Error';
  else
    lblState.Caption := 'Unknown';
  end;

  edtSessionId.Text := FClient.CurrentSessionId;
  edtProtocol.Text := IntToStr(FClient.ProtocolVersion);
  stsBar.Panels[0].Text := Format('State: %d', [Integer(FClient.State)]);
end;

procedure TAIAgentTestForm.OnClientLog(Sender: TObject; const Text: string);
begin
  FSyncMsg := '[LOG] ' + Text;
  TThreadHack(FSyncThread).Synchronize(SyncLogProc);
end;

procedure TAIAgentTestForm.OnClientStateChanged(Sender: TObject;
  State: TCnACPConnectionState);
begin
  FSyncMsg := '[STATE] ' + IntToStr(Integer(State));
  TThreadHack(FSyncThread).Synchronize(SyncLogUpdate);
end;

procedure TAIAgentTestForm.OnClientInitialized(Sender: TObject;
  Success: Boolean; const ErrorMessage: string);
begin
  FSyncSuccess := Success;
  FSyncErr := ErrorMessage;
  TThreadHack(FSyncThread).Synchronize(SyncInit);
end;

procedure TAIAgentTestForm.OnClientAuthenticated(Sender: TObject;
  Success: Boolean; const ErrorMessage: string);
begin
  if Success then
    FSyncMsg := '[AUTH] OK'
  else
    FSyncMsg := '[AUTH] Failed: ' + ErrorMessage;
  TThreadHack(FSyncThread).Synchronize(SyncLogProc);
end;

procedure TAIAgentTestForm.OnClientSessionCreated(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  FSyncSuccess := Success;
  FSyncErr := ErrorMessage;
  FSyncSessionId := SessionId;
  TThreadHack(FSyncThread).Synchronize(SyncSessionCreated);
end;

procedure TAIAgentTestForm.OnClientSessionClosed(Sender: TObject;
  const SessionId: string; Success: Boolean; const ErrorMessage: string);
begin
  FSyncSuccess := Success;
  FSyncErr := ErrorMessage;
  FSyncSessionId := SessionId;
  TThreadHack(FSyncThread).Synchronize(SyncSessionClosed);
end;

procedure TAIAgentTestForm.OnClientSessionUpdate(Sender: TObject;
  const SessionId, UpdateJson: string);
begin
  FSyncMsg := '[UPDATE] ' + UpdateJson;
  TThreadHack(FSyncThread).Synchronize(SyncLogProc);
end;

procedure TAIAgentTestForm.OnClientPromptResult(Sender: TObject;
  const SessionId, StopReason: string; Success: Boolean;
  const ErrorMessage: string);
begin
  if Success then
    FSyncMsg := Format('[PROMPT] Done. Session=%s, StopReason=%s',
      [SessionId, StopReason])
  else
    FSyncMsg := '[PROMPT] Failed: ' + ErrorMessage;
  TThreadHack(FSyncThread).Synchronize(SyncLogProc);
end;

procedure TAIAgentTestForm.PopulateToolTree;
var
  I: Integer;
  CatNode: TTreeNode;
  Tools: TStringList;
begin
  tvTools.Items.Clear;
  Tools := TStringList.Create;
  try
    if FToolManager <> nil then
      FToolManager.GetAllToolNames(Tools)
    else
      Exit;

    for I := 0 to Tools.Count - 1 do
    begin
      if Pos('/', Tools[I]) > 0 then
      begin
        CatNode := tvTools.Items.GetFirstNode;
        while (CatNode <> nil) and (CatNode.Text <> Copy(Tools[I], 1, Pos('/', Tools[I]) - 1)) do
          CatNode := CatNode.GetNextSibling;

        if CatNode = nil then
          CatNode := tvTools.Items.AddChild(nil,
            Copy(Tools[I], 1, Pos('/', Tools[I]) - 1));

        tvTools.Items.AddChild(CatNode, Tools[I]);
      end
      else
        tvTools.Items.AddChild(nil, Tools[I]);
    end;
  finally
    Tools.Free;
  end;
end;

procedure TAIAgentTestForm.btnStartClick(Sender: TObject);
begin
  if edtAgentPath.Text = '' then
  begin
    MessageDlg('Agent path is required.', mtError, [mbOK], 0);
    Exit;
  end;

  FClient.ConfigureTransport(edtAgentPath.Text, edtAgentArgs.Text, '');
  Log(Format('Starting: %s %s', [edtAgentPath.Text, edtAgentArgs.Text]));

  if not FClient.StartAgent then
  begin
    Log('Failed to start agent process');
    MessageDlg('Failed to start agent process.', mtError, [mbOK], 0);
    Exit;
  end;

  FClient.Initialize('AIAgentGUITest', 'AIAgent GUI Test', '1.0.0',
    True, True, False);
  Log('Initialize sent, waiting for response...');
end;

procedure TAIAgentTestForm.btnStopClick(Sender: TObject);
begin
  Log('Stopping agent...');
  FClient.StopAgent;
  UpdateUIState;
  Log('Agent stopped.');
end;

procedure TAIAgentTestForm.btnNewSessionClick(Sender: TObject);
var
  Cwd: string;
begin
  Cwd := edtCwd.Text;
  if Cwd = '' then
    Cwd := GetCurrentDir;
  Log('Creating session with cwd: ' + Cwd);
  FClient.NewSession(Cwd);
end;

procedure TAIAgentTestForm.btnCloseSessionClick(Sender: TObject);
var
  SessionId: string;
begin
  SessionId := FClient.CurrentSessionId;
  if SessionId <> '' then
  begin
    Log('Closing session: ' + SessionId);
    FClient.CloseSession(SessionId);
  end;
end;

procedure TAIAgentTestForm.btnSendPromptClick(Sender: TObject);
var
  SessionId, Text: string;
begin
  SessionId := FClient.CurrentSessionId;
  Text := Trim(memPrompt.Text);
  if (SessionId = '') or (Text = '') then
    Exit;

  Log('Sending prompt: ' + Text);
  FClient.PromptText(SessionId, Text);
end;

procedure TAIAgentTestForm.SyncLogProc;
begin
  Log(FSyncMsg);
end;

procedure TAIAgentTestForm.SyncLogUpdate;
begin
  Log(FSyncMsg);
  UpdateUIState;
end;

procedure TAIAgentTestForm.SyncInit;
begin
  if FSyncSuccess then
  begin
    Log(Format('[INIT] OK. Protocol v%d, Agent: %s %s',
      [FClient.ProtocolVersion, FClient.AgentName, FClient.AgentVersion]));
    edtProtocol.Text := IntToStr(FClient.ProtocolVersion);
  end
  else
    Log('[INIT] Failed: ' + FSyncErr);
  UpdateUIState;
end;

procedure TAIAgentTestForm.SyncSessionCreated;
begin
  if FSyncSuccess then
  begin
    Log('[SESSION] Created: ' + FSyncSessionId);
    FSessionManager.CreateSession(FSyncSessionId);
  end
  else
    Log('[SESSION] Create failed: ' + FSyncErr);
  UpdateUIState;
end;

procedure TAIAgentTestForm.SyncSessionClosed;
begin
  if FSyncSuccess then
  begin
    Log('[SESSION] Closed: ' + FSyncSessionId);
    FSessionManager.CloseSession(FSyncSessionId);
  end
  else
    Log('[SESSION] Close failed: ' + FSyncErr);
  UpdateUIState;
end;

end.
