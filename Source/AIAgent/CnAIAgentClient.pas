{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAIAgentClient;

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnJSON, CnAIAgentTypes, CnAIAgentJsonRpc, CnAIAgentStdioTransport, CnAIAgentTools;

type
  TCnACPClientLogEvent = procedure(Sender: TObject; const Text: string) of object;
  TCnACPClientStateEvent = procedure(Sender: TObject; State: TCnACPConnectionState) of object;
  TCnACPClientInitializedEvent = procedure(Sender: TObject; Success: Boolean;
    const ErrorMessage: string) of object;
  TCnACPClientAuthenticatedEvent = procedure(Sender: TObject; Success: Boolean;
    const ErrorMessage: string) of object;
  TCnACPClientSessionCreatedEvent = procedure(Sender: TObject; const SessionId: string;
    Success: Boolean; const ErrorMessage: string) of object;
  TCnACPClientSessionLoadedEvent = procedure(Sender: TObject; const SessionId: string;
    Success: Boolean; const ErrorMessage: string) of object;
  TCnACPClientSessionResumedEvent = procedure(Sender: TObject; const SessionId: string;
    Success: Boolean; const ErrorMessage: string) of object;
  TCnACPClientSessionClosedEvent = procedure(Sender: TObject; const SessionId: string;
    Success: Boolean; const ErrorMessage: string) of object;
  TCnACPClientPromptResultEvent = procedure(Sender: TObject; const SessionId, StopReason: string;
    Success: Boolean; const ErrorMessage: string) of object;
  TCnACPClientSessionUpdateEvent = procedure(Sender: TObject; const SessionId, UpdateJson: string) of object;

  // Agent -> Client callbacks
  TCnACPReadTextFileEvent = procedure(Sender: TObject; const SessionId, FileName: string;
    Line, Limit: Integer; var Content: string; var Handled: Boolean) of object;
  TCnACPWriteTextFileEvent = procedure(Sender: TObject; const SessionId, FileName, Content: string;
    var Handled: Boolean; var ErrorMessage: string) of object;
  TCnACPRequestPermissionEvent = procedure(Sender: TObject; const SessionId, ToolCallJson,
    OptionsJson: string; var Outcome, OptionId: string; var Handled: Boolean) of object;

  TCnACPPendingCall = class(TPersistent)
  public
    RequestID: string;
    MethodName: string;
    SessionId: string;
  end;

  TCnACPClient = class(TObject)
  private
    FTransport: TCnACPStdioTransport;
    FState: TCnACPConnectionState;
    FPending: TStringList;
    FReqSeq: Integer;
    FCurrentSessionId: string;
    FProtocolVersion: Integer;
    FCanLoadSession: Boolean;
    FCanResumeSession: Boolean;
    FCanCloseSession: Boolean;
    FAuthMethodIds: TStringList;
    FAgentName: string;
    FAgentTitle: string;
    FAgentVersion: string;
    FToolManager: TCnAIAgentToolManager;

    FOnLog: TCnACPClientLogEvent;
    FOnStateChanged: TCnACPClientStateEvent;
    FOnInitialized: TCnACPClientInitializedEvent;
    FOnAuthenticated: TCnACPClientAuthenticatedEvent;
    FOnSessionCreated: TCnACPClientSessionCreatedEvent;
    FOnSessionLoaded: TCnACPClientSessionLoadedEvent;
    FOnSessionResumed: TCnACPClientSessionResumedEvent;
    FOnSessionClosed: TCnACPClientSessionClosedEvent;
    FOnPromptResult: TCnACPClientPromptResultEvent;
    FOnSessionUpdate: TCnACPClientSessionUpdateEvent;
    FOnReadTextFile: TCnACPReadTextFileEvent;
    FOnWriteTextFile: TCnACPWriteTextFileEvent;
    FOnRequestPermission: TCnACPRequestPermissionEvent;

    procedure SetState(Value: TCnACPConnectionState);
    function NextRequestID: string;
    function AddPending(const AID, AMethod, ASessionId: string): TCnACPPendingCall;
    function FindPending(const AID: string): TCnACPPendingCall;
    procedure RemovePending(const AID: string);
    procedure ClearPending;

    procedure TransportLog(Sender: TObject; const Text: string);
    procedure TransportRunningChanged(Sender: TObject; Running: Boolean);
    procedure TransportLine(Sender: TObject; const Line: AnsiString);

    procedure HandleResponse(const Msg: TCnACPParsedMessage);
    procedure HandleNotification(const Msg: TCnACPParsedMessage);
    procedure HandleRequest(const Msg: TCnACPParsedMessage);

    function SendRequest(const Method: string; Params: TCnJSONValue;
      const SessionIdForPending: string = ''): string;
    function SendNotification(const Method: string; Params: TCnJSONValue): Boolean;
    function SendResult(const RequestID: string; ResultValue: TCnJSONValue = nil): Boolean;
    function SendError(const RequestID: string; ErrorCode: Integer; const ErrorMessage: string;
      ErrorData: TCnJSONValue = nil): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ConfigureTransport(const ApplicationName, CommandLine, WorkingDirectory: string);
    function StartAgent: Boolean;
    procedure StopAgent;
    function SendToolResult(const ToolCallId, SessionId: string;
      ResultObj: TCnJSONObject): Boolean;

    function Initialize(const ClientName, ClientTitle, ClientVersion: string;
      FSReadText, FSWriteText, Terminal: Boolean): string;
    function Authenticate(const MethodId: string): string;
    function NewSession(const Cwd: string; MCPServers: TCnJSONArray = nil): string;
    function LoadSession(const SessionId, Cwd: string; MCPServers: TCnJSONArray = nil): string;
    function ResumeSession(const SessionId, Cwd: string; MCPServers: TCnJSONArray = nil): string;
    function CloseSession(const SessionId: string): string;
    function Prompt(const SessionId: string; PromptBlocks: TCnJSONArray): string;
    function PromptText(const SessionId, Text: string): string;
    function Cancel(const SessionId: string): Boolean;

    property State: TCnACPConnectionState read FState;
    property CurrentSessionId: string read FCurrentSessionId;
    property ProtocolVersion: Integer read FProtocolVersion;
    property CanLoadSession: Boolean read FCanLoadSession;
    property CanResumeSession: Boolean read FCanResumeSession;
    property CanCloseSession: Boolean read FCanCloseSession;
    property AuthMethodIds: TStringList read FAuthMethodIds;
    property AgentName: string read FAgentName;
    property AgentTitle: string read FAgentTitle;
    property AgentVersion: string read FAgentVersion;
    property ToolManager: TCnAIAgentToolManager read FToolManager write FToolManager;

    property OnLog: TCnACPClientLogEvent read FOnLog write FOnLog;
    property OnStateChanged: TCnACPClientStateEvent read FOnStateChanged write FOnStateChanged;
    property OnInitialized: TCnACPClientInitializedEvent read FOnInitialized write FOnInitialized;
    property OnAuthenticated: TCnACPClientAuthenticatedEvent read FOnAuthenticated write FOnAuthenticated;
    property OnSessionCreated: TCnACPClientSessionCreatedEvent read FOnSessionCreated write FOnSessionCreated;
    property OnSessionLoaded: TCnACPClientSessionLoadedEvent read FOnSessionLoaded write FOnSessionLoaded;
    property OnSessionResumed: TCnACPClientSessionResumedEvent read FOnSessionResumed write FOnSessionResumed;
    property OnSessionClosed: TCnACPClientSessionClosedEvent read FOnSessionClosed write FOnSessionClosed;
    property OnPromptResult: TCnACPClientPromptResultEvent read FOnPromptResult write FOnPromptResult;
    property OnSessionUpdate: TCnACPClientSessionUpdateEvent read FOnSessionUpdate write FOnSessionUpdate;

    property OnReadTextFile: TCnACPReadTextFileEvent read FOnReadTextFile write FOnReadTextFile;
    property OnWriteTextFile: TCnACPWriteTextFileEvent read FOnWriteTextFile write FOnWriteTextFile;
    property OnRequestPermission: TCnACPRequestPermissionEvent read FOnRequestPermission write FOnRequestPermission;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

function JsonValueToString(V: TCnJSONValue): string;
begin
  if V = nil then
    Result := ''
  else if V is TCnJSONString then
    Result := V.AsString
  else
    Result := V.AsString;
end;

function JsonValueToIntDef(V: TCnJSONValue; Def: Integer): Integer;
begin
  if (V <> nil) and (V is TCnJSONNumber) then
    Result := V.AsInteger
  else
    Result := Def;
end;

function JsonValueToBoolDef(V: TCnJSONValue; Def: Boolean): Boolean;
begin
  if V is TCnJSONTrue then
    Result := True
  else if V is TCnJSONFalse then
    Result := False
  else
    Result := Def;
end;

constructor TCnACPClient.Create;
begin
  inherited Create;
  FPending := TStringList.Create;
  FAuthMethodIds := TStringList.Create;
  FReqSeq := 0;
  FState := acsIdle;
  FProtocolVersion := 0;
  FCanLoadSession := False;
  FCanResumeSession := False;
  FCanCloseSession := False;

  FTransport := TCnACPStdioTransport.Create;
  FTransport.OnLog := TransportLog;
  FTransport.OnMessageLine := TransportLine;
  FTransport.OnRunningChanged := TransportRunningChanged;
end;

destructor TCnACPClient.Destroy;
begin
  StopAgent;
  ClearPending;
  FAuthMethodIds.Free;
  FPending.Free;
  FTransport.Free;
  inherited Destroy;
end;

procedure TCnACPClient.SetState(Value: TCnACPConnectionState);
begin
  if FState <> Value then
  begin
    FState := Value;
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self, FState);
  end;
end;

procedure TCnACPClient.ConfigureTransport(const ApplicationName, CommandLine,
  WorkingDirectory: string);
begin
  FTransport.Configure(ApplicationName, CommandLine, WorkingDirectory);
end;

function TCnACPClient.StartAgent: Boolean;
begin
  SetState(acsStarting);
  Result := FTransport.Start;
  if Result then
    SetState(acsRunning)
  else
    SetState(acsError);
end;

procedure TCnACPClient.StopAgent;
begin
  FTransport.Stop;
  ClearPending;
  FCurrentSessionId := '';
  SetState(acsClosed);
end;

function TCnACPClient.NextRequestID: string;
begin
  Inc(FReqSeq);
  Result := IntToStr(FReqSeq);
end;

function TCnACPClient.AddPending(const AID, AMethod,
  ASessionId: string): TCnACPPendingCall;
begin
  Result := TCnACPPendingCall.Create;
  Result.RequestID := AID;
  Result.MethodName := AMethod;
  Result.SessionId := ASessionId;
  FPending.AddObject(AID, Result);
end;

function TCnACPClient.FindPending(const AID: string): TCnACPPendingCall;
var
  I: Integer;
begin
  I := FPending.IndexOf(AID);
  if I >= 0 then
    Result := TCnACPPendingCall(FPending.Objects[I])
  else
    Result := nil;
end;

procedure TCnACPClient.RemovePending(const AID: string);
var
  I: Integer;
begin
  I := FPending.IndexOf(AID);
  if I >= 0 then
  begin
    FPending.Objects[I].Free;
    FPending.Delete(I);
  end;
end;

procedure TCnACPClient.ClearPending;
var
  I: Integer;
begin
  for I := 0 to FPending.Count - 1 do
    FPending.Objects[I].Free;
  FPending.Clear;
end;

procedure TCnACPClient.TransportLog(Sender: TObject; const Text: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, Text);
end;

procedure TCnACPClient.TransportRunningChanged(Sender: TObject; Running: Boolean);
begin
  if Running then
    SetState(acsRunning)
  else if FState <> acsError then
    SetState(acsClosed);
end;

procedure TCnACPClient.TransportLine(Sender: TObject; const Line: AnsiString);
var
  Msg: TCnACPParsedMessage;
  S: AnsiString;
begin
  S := Line;
  while (Length(S) > 0) and ((S[Length(S)] = #13) or (S[Length(S)] = #10)) do
    Delete(S, Length(S), 1);
  if Trim(string(S)) = '' then
    Exit;

  Msg := TCnACPParsedMessage.Create;
  try
    if not ACPParseMessage(S, Msg) then
    begin
      TransportLog(Self, 'ACP parse failed for line: ' + string(S));
      Exit;
    end;

    case Msg.Kind of
      amkResponse:
        HandleResponse(Msg);
      amkNotification:
        HandleNotification(Msg);
      amkRequest:
        HandleRequest(Msg);
    end;
  finally
    Msg.Free;
  end;
end;

procedure TCnACPClient.HandleResponse(const Msg: TCnACPParsedMessage);
var
  Pending: TCnACPPendingCall;
  Success: Boolean;
  ErrMsg, StopReason, SessionId: string;
  V: TCnJSONValue;
  RootObj, C, A: TCnJSONObject;
  Arr: TCnJSONArray;
  I: Integer;
begin
  Pending := FindPending(Msg.ID);
  if Pending = nil then
    Exit;

  Success := Msg.ErrorObj = nil;
  ErrMsg := '';
  if not Success then
  begin
    if Msg.ErrorObj.ValueByName['message'] <> nil then
      ErrMsg := Msg.ErrorObj.ValueByName['message'].AsString
    else
      ErrMsg := 'Unknown ACP error';
  end;

  if Pending.MethodName = CN_ACP_METHOD_INITIALIZE then
  begin
    if Success and (Msg.ResultValue is TCnJSONObject) then
    begin
      RootObj := TCnJSONObject(Msg.ResultValue);
      V := RootObj.ValueByName['protocolVersion'];
      FProtocolVersion := JsonValueToIntDef(V, 0);

      FCanLoadSession := False;
      FCanResumeSession := False;
      FCanCloseSession := False;
      FAuthMethodIds.Clear;
      FAgentName := '';
      FAgentTitle := '';
      FAgentVersion := '';

      if RootObj.ValueByName['agentCapabilities'] is TCnJSONObject then
      begin
        A := TCnJSONObject(RootObj.ValueByName['agentCapabilities']);
        FCanLoadSession := JsonValueToBoolDef(A.ValueByName['loadSession'], False);
        if A.ValueByName['sessionCapabilities'] is TCnJSONObject then
        begin
          C := TCnJSONObject(A.ValueByName['sessionCapabilities']);
          FCanResumeSession := C.ValueByName['resume'] <> nil;
          FCanCloseSession := C.ValueByName['close'] <> nil;
        end;
      end;

      if RootObj.ValueByName['agentInfo'] is TCnJSONObject then
      begin
        A := TCnJSONObject(RootObj.ValueByName['agentInfo']);
        FAgentName := JsonValueToString(A.ValueByName['name']);
        FAgentTitle := JsonValueToString(A.ValueByName['title']);
        FAgentVersion := JsonValueToString(A.ValueByName['version']);
      end;

      if RootObj.ValueByName['authMethods'] is TCnJSONArray then
      begin
        Arr := TCnJSONArray(RootObj.ValueByName['authMethods']);
        for I := 0 to Arr.Count - 1 do
        begin
          if Arr[I] is TCnJSONObject then
          begin
            A := TCnJSONObject(Arr[I]);
            SessionId := JsonValueToString(A.ValueByName['id']);
            if SessionId <> '' then
              FAuthMethodIds.Add(SessionId);
          end
          else if Arr[I] is TCnJSONString then
            FAuthMethodIds.Add(Arr[I].AsString);
        end;
      end;
    end;
    if Assigned(FOnInitialized) then
      FOnInitialized(Self, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_AUTHENTICATE then
  begin
    if Assigned(FOnAuthenticated) then
      FOnAuthenticated(Self, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_SESSION_NEW then
  begin
    SessionId := '';
    if Success and (Msg.ResultValue is TCnJSONObject) then
    begin
      V := TCnJSONObject(Msg.ResultValue).ValueByName['sessionId'];
      SessionId := JsonValueToString(V);
      if SessionId <> '' then
        FCurrentSessionId := SessionId;
    end;
    if Assigned(FOnSessionCreated) then
      FOnSessionCreated(Self, SessionId, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_SESSION_LOAD then
  begin
    SessionId := Pending.SessionId;
    if Success and (SessionId <> '') then
      FCurrentSessionId := SessionId;
    if Assigned(FOnSessionLoaded) then
      FOnSessionLoaded(Self, SessionId, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_SESSION_RESUME then
  begin
    SessionId := Pending.SessionId;
    if Success and (SessionId <> '') then
      FCurrentSessionId := SessionId;
    if Assigned(FOnSessionResumed) then
      FOnSessionResumed(Self, SessionId, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_SESSION_CLOSE then
  begin
    SessionId := Pending.SessionId;
    if Success and (SessionId = FCurrentSessionId) then
      FCurrentSessionId := '';
    if Assigned(FOnSessionClosed) then
      FOnSessionClosed(Self, SessionId, Success, ErrMsg);
  end
  else if Pending.MethodName = CN_ACP_METHOD_SESSION_PROMPT then
  begin
    StopReason := '';
    if Success and (Msg.ResultValue is TCnJSONObject) then
    begin
      V := TCnJSONObject(Msg.ResultValue).ValueByName['stopReason'];
      StopReason := JsonValueToString(V);
    end;
    if Assigned(FOnPromptResult) then
      FOnPromptResult(Self, Pending.SessionId, StopReason, Success, ErrMsg);
  end;

  RemovePending(Msg.ID);
end;

procedure TCnACPClient.HandleNotification(const Msg: TCnACPParsedMessage);
var
  SessionId, UpdateType, ToolName, ToolCallId: string;
  Obj, ToolArgs: TCnJSONObject;
  ToolResult: TCnAIAgentToolExecuteResult;
  V: TCnJSONValue;
begin
  if Msg.Method = CN_ACP_METHOD_SESSION_UPDATE then
  begin
    SessionId := '';
    if Msg.Params is TCnJSONObject then
    begin
      Obj := TCnJSONObject(Msg.Params);
      if Obj.ValueByName['sessionId'] <> nil then
        SessionId := Obj.ValueByName['sessionId'].AsString;

      UpdateType := '';
      V := Obj.ValueByName['type'];
      if V <> nil then
        UpdateType := V.AsString;

      if UpdateType = CN_ACP_UPDATE_TOOL_CALL then
      begin
        ToolName := '';
        ToolCallId := '';
        if Obj.ValueByName['name'] <> nil then
          ToolName := Obj.ValueByName['name'].AsString;
        if Obj.ValueByName['toolCallId'] <> nil then
          ToolCallId := Obj.ValueByName['toolCallId'].AsString;

        if (ToolName <> '') and (ToolCallId <> '') and (FToolManager <> nil) then
        begin
          ToolArgs := nil;
          if Obj.ValueByName['args'] is TCnJSONObject then
            ToolArgs := TCnJSONObject(Obj.ValueByName['args'])
          else
            ToolArgs := TCnJSONObject.Create;

          ToolResult := FToolManager.ExecuteTool(ToolName, ToolArgs, nil);
          SendToolResult(ToolCallId, SessionId, ToolResult.ResultData);
        end;
      end
      else
      begin
        if Assigned(FOnSessionUpdate) then
          FOnSessionUpdate(Self, SessionId, Obj.ToJSON(False, 0));
      end;
    end;
  end;
end;

procedure TCnACPClient.HandleRequest(const Msg: TCnACPParsedMessage);
var
  P: TCnJSONObject;
  SessionId, Path, Content, Outcome, OptionId, ErrorMessage: string;
  Line, Limit: Integer;
  Handled: Boolean;
  R, O: TCnJSONObject;
  A: TCnJSONArray;
begin
  if not (Msg.Params is TCnJSONObject) then
  begin
    SendError(Msg.ID, CN_ACP_ERR_INVALID_PARAMS, 'Invalid params');
    Exit;
  end;

  P := TCnJSONObject(Msg.Params);
  SessionId := JsonValueToString(P.ValueByName['sessionId']);

  if Msg.Method = CN_ACP_METHOD_FS_READ_TEXT_FILE then
  begin
    Path := JsonValueToString(P.ValueByName['path']);
    Line := JsonValueToIntDef(P.ValueByName['line'], 0);
    Limit := JsonValueToIntDef(P.ValueByName['limit'], 0);
    Content := '';
    Handled := False;
    if Assigned(FOnReadTextFile) then
      FOnReadTextFile(Self, SessionId, Path, Line, Limit, Content, Handled);
    if Handled then
    begin
      R := TCnJSONObject.Create;
      try
        R.AddPair('content', Content);
        SendResult(Msg.ID, R);
      finally
        R.Free;
      end;
    end
    else
      SendError(Msg.ID, CN_ACP_ERR_METHOD_NOT_FOUND, 'fs/read_text_file not handled');
  end
  else if Msg.Method = CN_ACP_METHOD_FS_WRITE_TEXT_FILE then
  begin
    Path := JsonValueToString(P.ValueByName['path']);
    Content := JsonValueToString(P.ValueByName['content']);
    Handled := False;
    ErrorMessage := '';
    if Assigned(FOnWriteTextFile) then
      FOnWriteTextFile(Self, SessionId, Path, Content, Handled, ErrorMessage);
    if Handled then
      SendResult(Msg.ID, TCnJSONNull.Create)
    else
      SendError(Msg.ID, CN_ACP_ERR_METHOD_NOT_FOUND,
        'fs/write_text_file not handled. ' + ErrorMessage);
  end
  else if Msg.Method = CN_ACP_METHOD_SESSION_REQUEST_PERMISSION then
  begin
    Outcome := 'cancelled';
    OptionId := '';
    Handled := False;
    if Assigned(FOnRequestPermission) then
    begin
      if P.ValueByName['toolCall'] is TCnJSONObject then
        R := TCnJSONObject(P.ValueByName['toolCall'])
      else
        R := nil;
      if P.ValueByName['options'] is TCnJSONArray then
        A := TCnJSONArray(P.ValueByName['options'])
      else
        A := nil;
      if R <> nil then
        Path := R.ToJSON(False, 0)
      else
        Path := '{}';
      if A <> nil then
        Content := A.ToJSON(False, 0)
      else
        Content := '[]';
      FOnRequestPermission(Self, SessionId, Path, Content, Outcome, OptionId, Handled);
    end;

    R := TCnJSONObject.Create;
    try
      O := TCnJSONObject.Create;
      O.AddPair('outcome', Outcome);
      if (Outcome = 'selected') and (OptionId <> '') then
        O.AddPair('optionId', OptionId);
      R.AddPair('outcome', O);
      SendResult(Msg.ID, R);
    finally
      R.Free;
    end;
  end
  else
    SendError(Msg.ID, CN_ACP_ERR_METHOD_NOT_FOUND, 'Method not handled: ' + Msg.Method);
end;

function TCnACPClient.SendRequest(const Method: string; Params: TCnJSONValue;
  const SessionIdForPending: string): string;
var
  ID: string;
begin
  ID := NextRequestID;
  AddPending(ID, Method, SessionIdForPending);
  FTransport.SendLine(ACPBuildRequest(ID, Method, Params));
  Result := ID;
end;

function TCnACPClient.SendNotification(const Method: string;
  Params: TCnJSONValue): Boolean;
begin
  Result := FTransport.SendLine(ACPBuildNotification(Method, Params));
end;

function TCnACPClient.SendResult(const RequestID: string;
  ResultValue: TCnJSONValue): Boolean;
begin
  Result := FTransport.SendLine(ACPBuildResultResponse(RequestID, ResultValue));
end;

function TCnACPClient.SendError(const RequestID: string; ErrorCode: Integer;
  const ErrorMessage: string; ErrorData: TCnJSONValue): Boolean;
begin
  Result := FTransport.SendLine(ACPBuildErrorResponse(RequestID, ErrorCode,
    ErrorMessage, ErrorData));
end;

function TCnACPClient.Initialize(const ClientName, ClientTitle,
  ClientVersion: string; FSReadText, FSWriteText, Terminal: Boolean): string;
var
  Params: TCnJSONObject;
begin
  Params := ACPBuildInitializeParams(ClientName, ClientTitle, ClientVersion,
    FSReadText, FSWriteText, Terminal);
  try
    Result := SendRequest(CN_ACP_METHOD_INITIALIZE, Params);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.Authenticate(const MethodId: string): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('methodId', MethodId);
    Result := SendRequest(CN_ACP_METHOD_AUTHENTICATE, Params);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.NewSession(const Cwd: string;
  MCPServers: TCnJSONArray): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('cwd', Cwd);
    if MCPServers <> nil then
      Params.AddPair('mcpServers', MCPServers.Clone)
    else
      Params.AddPair('mcpServers', TCnJSONArray.Create);
    Result := SendRequest(CN_ACP_METHOD_SESSION_NEW, Params);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.LoadSession(const SessionId, Cwd: string;
  MCPServers: TCnJSONArray): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('sessionId', SessionId);
    Params.AddPair('cwd', Cwd);
    if MCPServers <> nil then
      Params.AddPair('mcpServers', MCPServers.Clone)
    else
      Params.AddPair('mcpServers', TCnJSONArray.Create);
    Result := SendRequest(CN_ACP_METHOD_SESSION_LOAD, Params, SessionId);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.ResumeSession(const SessionId, Cwd: string;
  MCPServers: TCnJSONArray): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('sessionId', SessionId);
    Params.AddPair('cwd', Cwd);
    if MCPServers <> nil then
      Params.AddPair('mcpServers', MCPServers.Clone)
    else
      Params.AddPair('mcpServers', TCnJSONArray.Create);
    Result := SendRequest(CN_ACP_METHOD_SESSION_RESUME, Params, SessionId);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.CloseSession(const SessionId: string): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('sessionId', SessionId);
    Result := SendRequest(CN_ACP_METHOD_SESSION_CLOSE, Params, SessionId);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.Prompt(const SessionId: string;
  PromptBlocks: TCnJSONArray): string;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('sessionId', SessionId);
    if PromptBlocks <> nil then
      Params.AddPair('prompt', PromptBlocks.Clone)
    else
      Params.AddPair('prompt', TCnJSONArray.Create);
    Result := SendRequest(CN_ACP_METHOD_SESSION_PROMPT, Params, SessionId);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.PromptText(const SessionId, Text: string): string;
var
  A: TCnJSONArray;
begin
  A := ACPBuildPromptTextArray(Text);
  try
    Result := Prompt(SessionId, A);
  finally
    A.Free;
  end;
end;

function TCnACPClient.Cancel(const SessionId: string): Boolean;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('sessionId', SessionId);
    Result := SendNotification(CN_ACP_METHOD_SESSION_CANCEL, Params);
  finally
    Params.Free;
  end;
end;

function TCnACPClient.SendToolResult(const ToolCallId, SessionId: string;
  ResultObj: TCnJSONObject): Boolean;
var
  Params: TCnJSONObject;
begin
  Params := TCnJSONObject.Create;
  try
    Params.AddPair('toolCallId', ToolCallId);
    if ResultObj <> nil then
      Params.AddPair('result', ResultObj.Clone)
    else
      Params.AddPair('result', TCnJSONNull.Create);
    if SessionId <> '' then
      Params.AddPair('sessionId', SessionId);
    Result := SendNotification(CN_ACP_METHOD_SESSION_TOOL_RESULT, Params);
  finally
    Params.Free;
  end;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

end.
