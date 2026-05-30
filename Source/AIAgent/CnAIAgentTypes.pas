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

unit CnAIAgentTypes;

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnJSON;

const
  CN_ACP_PROTOCOL_VERSION = 1;

  // Core methods
  CN_ACP_METHOD_INITIALIZE = 'initialize';
  CN_ACP_METHOD_AUTHENTICATE = 'authenticate';
  CN_ACP_METHOD_SESSION_NEW = 'session/new';
  CN_ACP_METHOD_SESSION_LOAD = 'session/load';
  CN_ACP_METHOD_SESSION_RESUME = 'session/resume';
  CN_ACP_METHOD_SESSION_CLOSE = 'session/close';
  CN_ACP_METHOD_SESSION_PROMPT = 'session/prompt';
  CN_ACP_METHOD_SESSION_CANCEL = 'session/cancel';
  CN_ACP_METHOD_SESSION_UPDATE = 'session/update';
  CN_ACP_METHOD_SESSION_TOOL_RESULT = 'session/tool_result';
  CN_ACP_METHOD_SESSION_REQUEST_PERMISSION = 'session/request_permission';

  CN_ACP_METHOD_FS_READ_TEXT_FILE = 'fs/read_text_file';
  CN_ACP_METHOD_FS_WRITE_TEXT_FILE = 'fs/write_text_file';

  // Session update kinds
  CN_ACP_UPDATE_USER_MESSAGE_CHUNK = 'user_message_chunk';
  CN_ACP_UPDATE_AGENT_MESSAGE_CHUNK = 'agent_message_chunk';
  CN_ACP_UPDATE_AGENT_THOUGHT_CHUNK = 'agent_thought_chunk';
  CN_ACP_UPDATE_TOOL_CALL = 'tool_call';
  CN_ACP_UPDATE_TOOL_CALL_UPDATE = 'tool_call_update';
  CN_ACP_UPDATE_PLAN = 'plan';
  CN_ACP_UPDATE_AVAILABLE_COMMANDS_UPDATE = 'available_commands_update';
  CN_ACP_UPDATE_CURRENT_MODE_UPDATE = 'current_mode_update';

  // Prompt stop reasons
  CN_ACP_STOP_END_TURN = 'end_turn';
  CN_ACP_STOP_MAX_TOKENS = 'max_tokens';
  CN_ACP_STOP_MAX_TURN_REQUESTS = 'max_turn_requests';
  CN_ACP_STOP_REFUSAL = 'refusal';
  CN_ACP_STOP_CANCELLED = 'cancelled';

  // JSON-RPC common error codes
  CN_ACP_ERR_PARSE_ERROR = -32700;
  CN_ACP_ERR_INVALID_REQUEST = -32600;
  CN_ACP_ERR_METHOD_NOT_FOUND = -32601;
  CN_ACP_ERR_INVALID_PARAMS = -32602;
  CN_ACP_ERR_INTERNAL_ERROR = -32603;

type
  TCnACPConnectionState = (acsIdle, acsStarting, acsRunning, acsClosed, acsError);

function ACPBuildClientCapabilities(FSReadText, FSWriteText, Terminal: Boolean;
  ToolDescriptions: TCnJSONArray = nil): TCnJSONObject;
function ACPBuildClientInfo(const Name, Title, Version: string): TCnJSONObject;
function ACPBuildInitializeParams(const Name, Title, Version: string;
  FSReadText, FSWriteText, Terminal: Boolean;
  ToolDescriptions: TCnJSONArray = nil): TCnJSONObject;

function ACPBuildTextContent(const Text: string): TCnJSONObject;
function ACPBuildPromptTextArray(const Text: string): TCnJSONArray;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

function ACPBuildClientCapabilities(FSReadText, FSWriteText,
  Terminal: Boolean; ToolDescriptions: TCnJSONArray): TCnJSONObject;
var
  FSObj: TCnJSONObject;
begin
  Result := TCnJSONObject.Create;
  FSObj := TCnJSONObject.Create;
  FSObj.AddPair('readTextFile', FSReadText);
  FSObj.AddPair('writeTextFile', FSWriteText);
  Result.AddPair('fs', FSObj);
  Result.AddPair('terminal', Terminal);
  if ToolDescriptions <> nil then
    Result.AddPair('tools', ToolDescriptions);
end;

function ACPBuildClientInfo(const Name, Title, Version: string): TCnJSONObject;
begin
  Result := TCnJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('title', Title);
  Result.AddPair('version', Version);
end;

function ACPBuildInitializeParams(const Name, Title, Version: string;
  FSReadText, FSWriteText, Terminal: Boolean;
  ToolDescriptions: TCnJSONArray): TCnJSONObject;
begin
  Result := TCnJSONObject.Create;
  Result.AddPair('protocolVersion', CN_ACP_PROTOCOL_VERSION);
  Result.AddPair('clientCapabilities',
    ACPBuildClientCapabilities(FSReadText, FSWriteText, Terminal, ToolDescriptions));
  Result.AddPair('clientInfo', ACPBuildClientInfo(Name, Title, Version));
end;

function ACPBuildTextContent(const Text: string): TCnJSONObject;
begin
  Result := TCnJSONObject.Create;
  Result.AddPair('type', 'text');
  Result.AddPair('text', Text);
end;

function ACPBuildPromptTextArray(const Text: string): TCnJSONArray;
begin
  Result := TCnJSONArray.Create;
  Result.AddValue(ACPBuildTextContent(Text));
end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

end.
