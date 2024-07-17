{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnAICoderEngineImpl;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的引擎实现单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10/11 + Delphi/C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.04 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, CnNative, CnJSON, CnAICoderEngine, CnAICoderNetClient;

type
  TCnOpenAIAIEngine = class(TCnAIBaseEngine)
  {* OpenAI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnQWenAIEngine = class(TCnAIBaseEngine)
  {* 通义千问 AI 引擎}
  protected
    // 通义千问的 HTTP 接口的 JSON 格式和其他几个有所不同
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
  end;

  TCnMoonshotAIEngine = class(TCnAIBaseEngine)
  {* 月之暗面 AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnChatGLMAIEngine = class(TCnAIBaseEngine)
  {* 智谱清言 AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnBaiChuanAIEngine = class(TCnAIBaseEngine)
  {* 百川 AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnDeepSeekAIEngine = class(TCnAIBaseEngine)
  {* 深度求索 AI 引擎}
  public
    class function EngineName: string; override;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

const
  CRLF = #13#10;
  LF = #10;

{ TCnOpenAIEngine }

class function TCnOpenAIAIEngine.EngineName: string;
begin
  Result := 'OpenAI';
end;

{ TCnQWenAIEngine }

function TCnQWenAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Input, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('temperature', Option.Temperature);

    Input := TCnJSONObject.Create;
    ReqRoot.AddPair('input', Input);
    Arr := Input.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'system');
    Msg.AddPair('content', Option.SystemMessage);
    Arr.AddValue(Msg);

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    Msg.AddPair('content', Option.ExplainCodePrompt + #13#10 + Code);

    Arr.AddValue(Msg);

    Input := TCnJSONObject.Create;
    ReqRoot.AddPair('parameters', Input);
    Input.AddPair('result_format', 'message');

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnQWenAIEngine.EngineName: string;
begin
  Result := '通义千问';
end;

function TCnQWenAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Output, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // 一类原始错误，如账号达到最大并发等
    Result := BytesToAnsi(Response);
  end
  else
  begin
    try
      // 正常回应
      if (RespRoot['output'] <> nil) and (RespRoot['output'] is TCnJSONObject) then
      begin
        Output := TCnJSONObject(RespRoot['output']);
        if (Output['choices'] <> nil) and (Output['choices'] is TCnJSONArray) then
        begin
          Arr := TCnJSONArray(Output['choices']);
          if (Arr.Count > 0) and (Arr[0]['message'] <> nil) and (Arr[0]['message'] is TCnJSONObject) then
          begin
            Msg := TCnJSONObject(Arr[0]['message']);
            Result := Msg['content'].AsString;
          end;
        end;
      end;

      if Result = '' then
      begin
        // 只要没有正常回应，就说明出错了
        Success := False;

        // 一类业务错误，比如 Key 无效等
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // 一类网络错误，比如 URL 错了等
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
        if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONString) then
        begin
          if Result = '' then
            Result := RespRoot['message'].AsString
          else
            Result := Result + ', ' + RespRoot['message'].AsString;
        end;
      end;
    finally
      RespRoot.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

{ TCnMoonshotAIEngine }

class function TCnMoonshotAIEngine.EngineName: string;
begin
  Result := '月之暗面';
end;

{ TCnChatGLMAIEngine }

class function TCnChatGLMAIEngine.EngineName: string;
begin
  Result := '智谱清言';
end;

{ TCnBaiChuanAIEngine }

class function TCnBaiChuanAIEngine.EngineName: string;
begin
  Result := '百川智能';
end;

{ TCnDeepSeekAIEngine }

class function TCnDeepSeekAIEngine.EngineName: string;
begin
  Result := 'DeepSeek';
end;

initialization
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnQWenAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);
  RegisterAIEngine(TCnDeepSeekAIEngine);

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
