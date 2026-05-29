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

unit CnAIAgentJsonRpc;

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnJSON, CnAIAgentTypes;

const
  CN_ACP_JSONRPC_VERSION = '2.0';

type
  TCnACPMessageKind = (amkUnknown, amkRequest, amkResponse, amkNotification);

  TCnACPParsedMessage = class(TPersistent)
  private
    FKind: TCnACPMessageKind;
    FMethod: string;
    FID: string;
    FHasID: Boolean;
    FParams: TCnJSONValue;
    FResultValue: TCnJSONValue;
    FErrorObj: TCnJSONObject;
    procedure SetParams(const Value: TCnJSONValue);
    procedure SetResultValue(const Value: TCnJSONValue);
    procedure SetErrorObj(const Value: TCnJSONObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property Kind: TCnACPMessageKind read FKind write FKind;
    property Method: string read FMethod write FMethod;
    property ID: string read FID write FID;
    property HasID: Boolean read FHasID write FHasID;
    property Params: TCnJSONValue read FParams write SetParams;
    property ResultValue: TCnJSONValue read FResultValue write SetResultValue;
    property ErrorObj: TCnJSONObject read FErrorObj write SetErrorObj;
  end;

function ACPBuildRequest(const ID, Method: string; Params: TCnJSONValue = nil): AnsiString;
function ACPBuildNotification(const Method: string; Params: TCnJSONValue = nil): AnsiString;
function ACPBuildResultResponse(const ID: string; ResultValue: TCnJSONValue = nil): AnsiString;
function ACPBuildErrorResponse(const ID: string; ErrorCode: Integer;
  const ErrorMessage: string; ErrorData: TCnJSONValue = nil): AnsiString;

function ACPParseMessage(const JsonLine: AnsiString; Msg: TCnACPParsedMessage): Boolean;
function ACPExtractIDAsString(const Obj: TCnJSONObject; const Name: string;
  out ID: string; out HasID: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

function ACPExtractIDAsString(const Obj: TCnJSONObject; const Name: string;
  out ID: string; out HasID: Boolean): Boolean;
var
  V: TCnJSONValue;
begin
  Result := False;
  HasID := False;
  ID := '';
  if Obj = nil then
    Exit;

  V := Obj.ValueByName[Name];
  if V = nil then
  begin
    Result := True;
    Exit;
  end;

  HasID := True;
  if V is TCnJSONString then
    ID := V.AsString
  else if V is TCnJSONNumber then
    ID := V.AsString
  else
    ID := V.AsString;
  Result := True;
end;

constructor TCnACPParsedMessage.Create;
begin
  inherited Create;
  Clear;
end;

destructor TCnACPParsedMessage.Destroy;
begin
  FParams.Free;
  FResultValue.Free;
  FErrorObj.Free;
  inherited Destroy;
end;

procedure TCnACPParsedMessage.Clear;
begin
  FKind := amkUnknown;
  FMethod := '';
  FID := '';
  FHasID := False;
  FreeAndNil(FParams);
  FreeAndNil(FResultValue);
  FreeAndNil(FErrorObj);
end;

procedure TCnACPParsedMessage.SetErrorObj(const Value: TCnJSONObject);
begin
  if FErrorObj <> Value then
  begin
    FreeAndNil(FErrorObj);
    FErrorObj := Value;
  end;
end;

procedure TCnACPParsedMessage.SetParams(const Value: TCnJSONValue);
begin
  if FParams <> Value then
  begin
    FreeAndNil(FParams);
    FParams := Value;
  end;
end;

procedure TCnACPParsedMessage.SetResultValue(const Value: TCnJSONValue);
begin
  if FResultValue <> Value then
  begin
    FreeAndNil(FResultValue);
    FResultValue := Value;
  end;
end;

function ACPBuildRequest(const ID, Method: string; Params: TCnJSONValue): AnsiString;
var
  Root: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    Root.AddPair('jsonrpc', CN_ACP_JSONRPC_VERSION);
    Root.AddPair('id', ID);
    Root.AddPair('method', Method);
    if Params <> nil then
      Root.AddPair('params', Params.Clone)
    else
      Root.AddPair('params', TCnJSONObject.Create);
    Result := Root.ToJSON(False, 0);
  finally
    Root.Free;
  end;
end;

function ACPBuildNotification(const Method: string; Params: TCnJSONValue): AnsiString;
var
  Root: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    Root.AddPair('jsonrpc', CN_ACP_JSONRPC_VERSION);
    Root.AddPair('method', Method);
    if Params <> nil then
      Root.AddPair('params', Params.Clone)
    else
      Root.AddPair('params', TCnJSONObject.Create);
    Result := Root.ToJSON(False, 0);
  finally
    Root.Free;
  end;
end;

function ACPBuildResultResponse(const ID: string; ResultValue: TCnJSONValue): AnsiString;
var
  Root: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    Root.AddPair('jsonrpc', CN_ACP_JSONRPC_VERSION);
    Root.AddPair('id', ID);
    if ResultValue <> nil then
      Root.AddPair('result', ResultValue.Clone)
    else
      Root.AddPair('result', TCnJSONNull.Create);
    Result := Root.ToJSON(False, 0);
  finally
    Root.Free;
  end;
end;

function ACPBuildErrorResponse(const ID: string; ErrorCode: Integer;
  const ErrorMessage: string; ErrorData: TCnJSONValue): AnsiString;
var
  Root, ErrObj: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    Root.AddPair('jsonrpc', CN_ACP_JSONRPC_VERSION);
    Root.AddPair('id', ID);
    ErrObj := TCnJSONObject.Create;
    ErrObj.AddPair('code', ErrorCode);
    ErrObj.AddPair('message', ErrorMessage);
    if ErrorData <> nil then
      ErrObj.AddPair('data', ErrorData.Clone);
    Root.AddPair('error', ErrObj);
    Result := Root.ToJSON(False, 0);
  finally
    Root.Free;
  end;
end;

function ACPParseMessage(const JsonLine: AnsiString; Msg: TCnACPParsedMessage): Boolean;
var
  Root: TCnJSONObject;
  V: TCnJSONValue;
begin
  Result := False;
  if Msg = nil then
    Exit;

  Msg.Clear;
  Root := CnJSONParse(JsonLine);
  if Root = nil then
    Exit;

  try
    // Basic shape validation
    V := Root.ValueByName['jsonrpc'];
    if (V = nil) or (V.AsString <> CN_ACP_JSONRPC_VERSION) then
      Exit;

    ACPExtractIDAsString(Root, 'id', Msg.FID, Msg.FHasID);

    if Root.ValueByName['method'] <> nil then
    begin
      Msg.Method := Root.ValueByName['method'].AsString;
      if Root.ValueByName['params'] <> nil then
        Msg.Params := Root.ValueByName['params'].Clone;

      if Msg.HasID then
        Msg.Kind := amkRequest
      else
        Msg.Kind := amkNotification;
    end
    else if Root.ValueByName['result'] <> nil then
    begin
      Msg.Kind := amkResponse;
      Msg.ResultValue := Root.ValueByName['result'].Clone;
    end
    else if (Root.ValueByName['error'] <> nil) and (Root.ValueByName['error'] is TCnJSONObject) then
    begin
      Msg.Kind := amkResponse;
      Msg.ErrorObj := TCnJSONObject(Root.ValueByName['error'].Clone);
    end
    else
      Exit;

    Result := True;
  finally
    Root.Free;
  end;
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

end.
