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

unit CnAIAgentStdioTransport;

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnNative, CnJSON, CnAIAgentTypes
  {$IFDEF MSWINDOWS}
  , CnStdio
  {$ENDIF}
  ;

type
  TCnACPStdioLogEvent = procedure(Sender: TObject; const Text: string) of object;
  TCnACPStdioLineEvent = procedure(Sender: TObject; const Line: AnsiString) of object;
  TCnACPStdioStateEvent = procedure(Sender: TObject; Running: Boolean) of object;

  TCnACPStdioTransport = class(TObject)
  private
    FCmdLine: string;
    FWorkDir: string;
    FAppName: string;
    FOnLog: TCnACPStdioLogEvent;
    FOnMessageLine: TCnACPStdioLineEvent;
    FOnRunningChanged: TCnACPStdioStateEvent;
    FOutRemain: AnsiString;
    {$IFDEF MSWINDOWS}
    FProc: TCnStdioProcess;
    procedure ProcRawData(Sender: TObject; StreamKind: TCnStdioStreamKind; const Data: TBytes);
    procedure ProcExited(Sender: TObject; ExitCode: Cardinal);
    procedure ProcError(Sender: TObject; const Stage: string; ErrorCode: Cardinal;
      const ErrorMessage: string);
    {$ELSE}
    FProcess: Pointer;
    FReaderThread: Pointer;
    FStopped: Boolean;
    {$ENDIF}
    procedure EmitLog(const S: string);
    procedure EmitMessageLine(const Line: AnsiString);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Configure(const ApplicationName, CommandLine, WorkingDirectory: string);
    function Start: Boolean;
    procedure Stop;
    function Running: Boolean;

    function SendLine(const Line: AnsiString): Boolean;

    property OnLog: TCnACPStdioLogEvent read FOnLog write FOnLog;
    property OnMessageLine: TCnACPStdioLineEvent read FOnMessageLine write FOnMessageLine;
    property OnRunningChanged: TCnACPStdioStateEvent read FOnRunningChanged write FOnRunningChanged;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

{$IFNDEF MSWINDOWS}
uses
  Process, BaseUnix, Unix;
{$ENDIF}

const
  ACP_LF: AnsiChar = #10;

{$IFDEF MSWINDOWS}

constructor TCnACPStdioTransport.Create;
begin
  inherited Create;
  FProc := TCnStdioProcess.Create;
  FProc.CreateNoWindow := True;
  FProc.OnRawData := ProcRawData;
  FProc.OnExited := ProcExited;
  FProc.OnError := ProcError;
end;

destructor TCnACPStdioTransport.Destroy;
begin
  Stop;
  FProc.Free;
  inherited Destroy;
end;

procedure TCnACPStdioTransport.Configure(const ApplicationName, CommandLine,
  WorkingDirectory: string);
begin
  FAppName := ApplicationName;
  FCmdLine := CommandLine;
  FWorkDir := WorkingDirectory;
end;

function TCnACPStdioTransport.Start: Boolean;
begin
  FOutRemain := '';
  FProc.ApplicationName := FAppName;
  FProc.CommandLine := FCmdLine;
  FProc.WorkingDirectory := FWorkDir;
  Result := FProc.Start;
  if Assigned(FOnRunningChanged) then
    FOnRunningChanged(Self, Result);
end;

procedure TCnACPStdioTransport.Stop;
begin
  if FProc <> nil then
  begin
    FProc.Terminate;
    FProc.WaitFor(2000);
    if Assigned(FOnRunningChanged) then
      FOnRunningChanged(Self, False);
  end;
end;

function TCnACPStdioTransport.Running: Boolean;
begin
  Result := (FProc <> nil) and FProc.Running;
end;

procedure TCnACPStdioTransport.ProcRawData(Sender: TObject;
  StreamKind: TCnStdioStreamKind; const Data: TBytes);
var
  S: AnsiString;
  P: Integer;
begin
  if Length(Data) = 0 then
    Exit;

  SetLength(S, Length(Data));
  Move(Data[0], S[1], Length(Data));

  if StreamKind = cskStdErr then
  begin
    EmitLog(string(S));
    Exit;
  end;

  FOutRemain := FOutRemain + S;
  P := Pos(ACP_LF, FOutRemain);
  while P > 0 do
  begin
    EmitMessageLine(Copy(FOutRemain, 1, P - 1));
    Delete(FOutRemain, 1, P);
    P := Pos(ACP_LF, FOutRemain);
  end;
end;

procedure TCnACPStdioTransport.ProcExited(Sender: TObject; ExitCode: Cardinal);
begin
  EmitLog('ACP agent exited with code ' + IntToStr(Integer(ExitCode)));
  if Assigned(FOnRunningChanged) then
    FOnRunningChanged(Self, False);
end;

procedure TCnACPStdioTransport.ProcError(Sender: TObject; const Stage: string;
  ErrorCode: Cardinal; const ErrorMessage: string);
begin
  EmitLog(Format('ACP stdio error at %s: %d %s', [Stage, ErrorCode, ErrorMessage]));
end;

function TCnACPStdioTransport.SendLine(const Line: AnsiString): Boolean;
var
  B: TBytes;
  Payload: AnsiString;
begin
  Payload := Line + ACP_LF;
  SetLength(B, Length(Payload));
  if Length(Payload) > 0 then
    Move(Payload[1], B[0], Length(Payload));
  Result := FProc.WriteBytes(B);
end;

{$ELSE}  // POSIX (macOS/Linux/FPC)

type
  TACPReaderThread = class(TThread)
  private
    FOwner: TCnACPStdioTransport;
    FProcess: TProcess;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TCnACPStdioTransport; AProcess: TProcess);
  end;

  TPOSIXProcessHolder = class
  public
    Process: TProcess;
    Reader: TACPReaderThread;
  end;

constructor TACPReaderThread.Create(AOwner: TCnACPStdioTransport; AProcess: TProcess);
begin
  FOwner := AOwner;
  FProcess := AProcess;
  FreeOnTerminate := False;  // Owner manages lifetime
  inherited Create(False);
end;

procedure TACPReaderThread.Execute;
var
  Buffer: array[0..4095] of Byte;
  BytesRead: LongInt;
  S: AnsiString;
  P: Integer;
begin
  while not Terminated and (FProcess <> nil) and FProcess.Running do
  begin
    BytesRead := FProcess.Output.Read(Buffer, SizeOf(Buffer));
    if BytesRead > 0 then
    begin
      SetLength(S, BytesRead);
      Move(Buffer[0], S[1], BytesRead);

      FOwner.FOutRemain := FOwner.FOutRemain + S;
      P := Pos(ACP_LF, FOwner.FOutRemain);
      while P > 0 do
      begin
        FOwner.EmitMessageLine(Copy(FOwner.FOutRemain, 1, P - 1));
        Delete(FOwner.FOutRemain, 1, P);
        P := Pos(ACP_LF, FOwner.FOutRemain);
      end;
    end
    else
      Sleep(10);
  end;
end;

constructor TCnACPStdioTransport.Create;
begin
  inherited Create;
  FProcess := nil;
  FReaderThread := nil;
  FStopped := False;
end;

destructor TCnACPStdioTransport.Destroy;
begin
  Stop;
  inherited Destroy;
end;

procedure TCnACPStdioTransport.Configure(const ApplicationName, CommandLine,
  WorkingDirectory: string);
begin
  FAppName := ApplicationName;
  FCmdLine := CommandLine;
  FWorkDir := WorkingDirectory;
end;

function TCnACPStdioTransport.Start: Boolean;
var
  Holder: TPOSIXProcessHolder;
  Proc: TProcess;
  Reader: TACPReaderThread;
begin
  Result := False;
  FStopped := False;
  FOutRemain := '';

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FAppName;
    Proc.Parameters.DelimitedText := FCmdLine;
    if FWorkDir <> '' then
      Proc.CurrentDirectory := FWorkDir;
    Proc.Options := [poUsePipes];
    Proc.Execute;
  except
    Proc.Free;
    EmitLog('Failed to start process: ' + FAppName + ' ' + FCmdLine);
    if Assigned(FOnRunningChanged) then
      FOnRunningChanged(Self, False);
    Exit;
  end;

  Reader := TACPReaderThread.Create(Self, Proc);
  Holder := TPOSIXProcessHolder.Create;
  Holder.Process := Proc;
  Holder.Reader := Reader;
  FProcess := Holder;
  FReaderThread := Reader;

  Result := True;
  if Assigned(FOnRunningChanged) then
    FOnRunningChanged(Self, True);
end;

procedure TCnACPStdioTransport.Stop;
var
  Holder: TPOSIXProcessHolder;
begin
  if FProcess <> nil then
  begin
    Holder := TPOSIXProcessHolder(FProcess);
    // Kill process first so pipes break and reader thread can exit
    if Holder.Process.Running then
    begin
      FpKill(Holder.Process.ProcessID, SIGTERM);
      Sleep(200);
      if Holder.Process.Running then
        FpKill(Holder.Process.ProcessID, SIGKILL);
    end;
    // Now wait for reader thread (pipe reads will return 0/EOF after kill)
    if (Holder.Reader <> nil) and not Holder.Reader.Terminated then
    begin
      Holder.Reader.Terminate;
      Holder.Reader.WaitFor;
      Holder.Reader.Free;
    end;
    Holder.Process.Free;
    Holder.Free;
    FProcess := nil;
    FReaderThread := nil;
    if Assigned(FOnRunningChanged) then
      FOnRunningChanged(Self, False);
  end;
end;

function TCnACPStdioTransport.Running: Boolean;
var
  Holder: TPOSIXProcessHolder;
begin
  if FProcess <> nil then
  begin
    Holder := TPOSIXProcessHolder(FProcess);
    Result := Holder.Process.Running;
  end
  else
    Result := False;
end;

function TCnACPStdioTransport.SendLine(const Line: AnsiString): Boolean;
var
  Payload: AnsiString;
  B: TBytes;
  Holder: TPOSIXProcessHolder;
begin
  Result := False;
  if FProcess = nil then
    Exit;

  Holder := TPOSIXProcessHolder(FProcess);
  Payload := Line + ACP_LF;
  SetLength(B, Length(Payload));
  if Length(Payload) > 0 then
    Move(Payload[1], B[0], Length(Payload));
  try
    Holder.Process.Input.Write(B[0], Length(B));
    Result := True;
  except
    EmitLog('SendLine failed');
  end;
end;

{$ENDIF}

procedure TCnACPStdioTransport.EmitLog(const S: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, S);
end;

procedure TCnACPStdioTransport.EmitMessageLine(const Line: AnsiString);
begin
  if Assigned(FOnMessageLine) then
    FOnMessageLine(Self, Line);
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

end.
