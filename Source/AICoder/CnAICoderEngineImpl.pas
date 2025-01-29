{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
  SysUtils, Classes, CnNative, CnJSON, CnAICoderEngine, CnAICoderNetClient,
  CnAICoderConfig;

type
  TCnOpenAIAIEngine = class(TCnAIBaseEngine)
  {* OpenAI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnMistralAIAIEngine = class(TCnAIBaseEngine)
  {* MistralAI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnClaudeAIEngine = class(TCnAIBaseEngine)
  {* Claude 引擎}
  protected
    // Claude 的身份验证头信息和其他几个不同
    procedure PrepareRequestHeader(Headers: TStringList); override;

    // Claude 的 HTTP 接口的 JSON 格式和其他几个有所不同
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;

    // Claude 的信息返回格式也不同
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
    class function OptionClass: TCnAIEngineOptionClass; override;
  end;

  TCnGeminiAIEngine = class(TCnAIBaseEngine)
  {* Gemini 引擎}
  protected
    // Gemini 的 URL 和其他几个不同
    function GetRequestURL(DataObj: TCnAINetRequestDataObject): string; override;

    // Gemini 的身份验证头信息和其他几个不同
    procedure PrepareRequestHeader(Headers: TStringList); override;

    // Claude 的 HTTP 接口的 JSON 格式和其他几个有所不同
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;

    // Claude 的信息返回格式也不同
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
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
  {* 百川智能 AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnDeepSeekAIEngine = class(TCnAIBaseEngine)
  {* 深度求索 AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnOllamaAIEngine = class(TCnAIBaseEngine)
  {* 本地或私有化部署的集成 Ollama 引擎}
  protected
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; override;
    function ParseResponse(var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
    class function NeedApiKey: Boolean; override;
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
    // 一类原始错误
    Result := string(S);
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
  Result := '深度求索';
end;

{ TCnMistralAIAIEngine }

class function TCnMistralAIAIEngine.EngineName: string;
begin
  Result := 'MistralAI';
end;

{ TCnClaudeAIEngine }

function TCnClaudeAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('temperature', Option.Temperature);
    ReqRoot.AddPair('max_tokens', (Option as TCnClaudeAIEngineOption).MaxTokens);

    ReqRoot.AddPair('system', Option.SystemMessage); // Claude 额外放 System 消息
    Arr := ReqRoot.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    if RequestType = artExplainCode then
      Msg.AddPair('content', Option.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Msg.AddPair('content', Option.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artGenTestCase then
      Msg.AddPair('content', Option.GenTestCasePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Msg.AddPair('content', Code);

    Arr.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnClaudeAIEngine.EngineName: string;
begin
  Result := 'Claude';
end;

class function TCnClaudeAIEngine.OptionClass: TCnAIEngineOptionClass;
begin
  Result := TCnClaudeAIEngineOption;
end;

function TCnClaudeAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // 一类原始错误
    Result := string(S);
  end
  else
  begin
    try
      // 正常回应
      if (RespRoot['content'] <> nil) and (RespRoot['content'] is TCnJSONArray) then
      begin
        Arr := TCnJSONArray(RespRoot['content']);
        if (Arr.Count > 0) and (Arr[0]['text'] <> nil) and (Arr[0]['text'] is TCnJSONString) then
          Result := Arr[0]['text'].AsString;
      end;

      if Result = '' then
      begin
        // 只要没有正常回应，就说明出错了，但 Claude 的文档里没有说明，只能照着其他 AI 引擎写
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

      // 兜底，所有解析都无效就直接用整个 JSON 作为返回信息
      if Result = '' then
        Result := string(S);

    finally
      RespRoot.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

procedure TCnClaudeAIEngine.PrepareRequestHeader(Headers: TStringList);
begin
  inherited;
  DeleteAuthorizationHeader(Headers); // 删除原有的认证头，换新头
  Headers.Add('x-api-key: ' + Option.ApiKey);
  Headers.Add('anthropic-version: ' + (Option as TCnClaudeAIEngineOption).AnthropicVersion);
end;

{ TCnGeminiAIEngine }

function TCnGeminiAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg, Txt: TCnJSONObject;
  Cont, Part: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    Cont := ReqRoot.AddArray('contents');

    // Gemini 不支持 system role，一块搁 user 里
    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    Part := Msg.AddArray('parts');
    Txt := TCnJSONObject.Create;

    if RequestType = artExplainCode then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Option.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Option.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artGenTestCase then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Option.GenTestCasePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Txt.AddPair('text', Option.SystemMessage + #13#10 + Code);

    Part.AddValue(Txt);
    Cont.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnGeminiAIEngine.EngineName: string;
begin
  Result := 'Gemini';
end;

function TCnGeminiAIEngine.GetRequestURL(DataObj: TCnAINetRequestDataObject): string;
begin
  // 模型名和身份验证的 Key 均在 URL 里
  Result := DataObj.URL + Option.Model + ':generateContent?key=' + Option.ApiKey;
end;

function TCnGeminiAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Parts, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // 一类原始错误，如账号达到最大并发等
    Result := string(S);
  end
  else
  begin
    try
      // 正常回应，Gemini 格式
      if (RespRoot['candidates'] <> nil) and (RespRoot['candidates'] is TCnJSONArray) then
      begin
        Arr := TCnJSONArray(RespRoot['candidates']);
        if (Arr.Count > 0) and (Arr[0]['content'] <> nil) and (Arr[0]['content'] is TCnJSONObject) then
        begin
          Parts := TCnJSONObject(Arr[0]['content']);
          if (Parts['parts'] <> nil) and (Parts['parts'] is TCnJSONArray) then
          begin
            Arr := TCnJSONArray(Parts['parts']);
            if (Arr.Count > 0) and (Arr[0]['text'] <> nil) and (Arr[0]['text'] is TCnJSONString) then
            begin
              Msg := TCnJSONObject(Arr[0]);
              Result := Msg['text'].AsString;
            end;
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

      // 兜底，所有解析都无效就直接用整个 JSON 作为返回信息
      if Result = '' then
        Result := string(S);
    finally
      RespRoot.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

procedure TCnGeminiAIEngine.PrepareRequestHeader(Headers: TStringList);
begin
  inherited;
  // 删原有的 Authorization，因为身份认证在 URL 里
  DeleteAuthorizationHeader(Headers);
end;

{ TCnOllamaAIEngine }

function TCnOllamaAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('stream', False);
    Arr := ReqRoot.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'system');
    Msg.AddPair('content', Option.SystemMessage);
    Arr.AddValue(Msg);

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    if RequestType = artExplainCode then
      Msg.AddPair('content', Option.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Msg.AddPair('content', Option.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artGenTestCase then
      Msg.AddPair('content', Option.GenTestCasePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Msg.AddPair('content', Code);

    Arr.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

class function TCnOllamaAIEngine.EngineName: string;
begin
  Result := 'Ollama';
end;

class function TCnOllamaAIEngine.NeedApiKey: Boolean;
begin
  Result := False;
end;

function TCnOllamaAIEngine.ParseResponse(var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType;
  const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  S: AnsiString;
begin
  Result := '';
  S := BytesToAnsi(Response);
  RespRoot := CnJSONParse(S);
  if RespRoot = nil then
  begin
    // 一类原始错误，如账号达到最大并发等
    Result := string(S);
  end
  else
  begin
    try
      // Ollama 的简要格式，message 下其实还有 role: assistant 但不管
      if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONObject) then
      begin
        Msg := TCnJSONObject(RespRoot['message']);
        Result := Msg['content'].AsString;
      end;

      if Result = '' then
      begin
        // Ollama 的简要错误格式
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
      end;

      // 兜底，所有解析都无效就直接用整个 JSON 作为返回信息
      if Result = '' then
        Result := string(S);
    finally
      RespRoot.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

initialization
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnMistralAIAIEngine);
  RegisterAIEngine(TCnGeminiAIEngine);
  RegisterAIEngine(TCnClaudeAIEngine);
  RegisterAIEngine(TCnQWenAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);
  RegisterAIEngine(TCnDeepSeekAIEngine);
  RegisterAIEngine(TCnOllamaAIEngine);

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
