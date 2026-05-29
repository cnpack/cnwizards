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

unit CnAIAgentSession;

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes;

type
  TCnAIAgentSession = class
  private
    FSessionId: string;
    FCwd: string;
    FProjectFileName: string;
    FCreatedAt: TDateTime;
    FLastActiveAt: TDateTime;
  public
    constructor Create(const ASessionId, ACwd: string);
    property SessionId: string read FSessionId;
    property Cwd: string read FCwd write FCwd;
    property ProjectFileName: string read FProjectFileName write FProjectFileName;
    property CreatedAt: TDateTime read FCreatedAt;
    property LastActiveAt: TDateTime read FLastActiveAt write FLastActiveAt;
  end;

  TCnAIAgentSessionManager = class
  private
    FSessions: TStringList;
    FActiveSessionId: string;
    FNextId: Integer;
    function GenerateSessionId: string;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateSession(const Cwd: string): string;
    function GetSession(const Id: string): TCnAIAgentSession;
    procedure CloseSession(const Id: string);
    function SetActiveSession(const Id: string): Boolean;
    function GetActiveSession: TCnAIAgentSession;
    function SessionCount: Integer;
    procedure CloseAll;
  end;

implementation

constructor TCnAIAgentSession.Create(const ASessionId, ACwd: string);
begin
  inherited Create;
  FSessionId := ASessionId;
  FCwd := ACwd;
  FCreatedAt := Now;
  FLastActiveAt := Now;
end;

constructor TCnAIAgentSessionManager.Create;
begin
  inherited Create;
  FSessions := TStringList.Create;
  FSessions.Sorted := True;
  FSessions.Duplicates := dupError;
  FNextId := 1;
end;

destructor TCnAIAgentSessionManager.Destroy;
begin
  CloseAll;
  FSessions.Free;
  inherited Destroy;
end;

function TCnAIAgentSessionManager.GenerateSessionId: string;
begin
  Result := 'session-' + IntToStr(FNextId);
  Inc(FNextId);
end;

function TCnAIAgentSessionManager.CreateSession(const Cwd: string): string;
var
  Id: string;
  Session: TCnAIAgentSession;
begin
  Id := GenerateSessionId;
  Session := TCnAIAgentSession.Create(Id, Cwd);
  FSessions.AddObject(Id, Session);
  FActiveSessionId := Id;
  Result := Id;
end;

function TCnAIAgentSessionManager.GetSession(const Id: string): TCnAIAgentSession;
var
  I: Integer;
begin
  I := FSessions.IndexOf(Id);
  if I >= 0 then
    Result := TCnAIAgentSession(FSessions.Objects[I])
  else
    Result := nil;
end;

procedure TCnAIAgentSessionManager.CloseSession(const Id: string);
var
  I: Integer;
begin
  I := FSessions.IndexOf(Id);
  if I >= 0 then
  begin
    FSessions.Objects[I].Free;
    FSessions.Delete(I);
    if FActiveSessionId = Id then
      FActiveSessionId := '';
  end;
end;

function TCnAIAgentSessionManager.SetActiveSession(const Id: string): Boolean;
begin
  if FSessions.IndexOf(Id) >= 0 then
  begin
    FActiveSessionId := Id;
    Result := True;
  end
  else
    Result := False;
end;

function TCnAIAgentSessionManager.GetActiveSession: TCnAIAgentSession;
begin
  Result := GetSession(FActiveSessionId);
end;

function TCnAIAgentSessionManager.SessionCount: Integer;
begin
  Result := FSessions.Count;
end;

procedure TCnAIAgentSessionManager.CloseAll;
var
  I: Integer;
begin
  for I := 0 to FSessions.Count - 1 do
    FSessions.Objects[I].Free;
  FSessions.Clear;
  FActiveSessionId := '';
end;

end.
