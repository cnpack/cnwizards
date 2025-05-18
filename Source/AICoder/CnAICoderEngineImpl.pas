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
* 备    注：就 Claude/Gemini 两个怪胎不支持 OpenAI 兼容格式
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10/11 + Delphi/C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.04 V1.0
*               通义千问兼容基类 API 接口格式
*           2024.05.04 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, Contnrs, CnNative, CnJSON, CnAICoderEngine,
  CnAICoderNetClient, CnAICoderConfig;

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
    class function GetModelListURL(const OrigURL: string): string; override;

    // Claude 的身份验证头信息和其他几个不同
    procedure PrepareRequestHeader(const APIKey: string; Headers: TStringList); override;

    // Claude 的 HTTP 接口的 JSON 格式和其他几个有所不同
    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string;
      History: TStrings = nil): TBytes; override;

    // Claude 的信息返回格式也不同
    function ParseResponse(SendId: Integer; StreamMode, Partly: Boolean; var Success: Boolean;
      var ErrorCode: Cardinal; var IsStreamEnd: Boolean; RequestType: TCnAIRequestType;
      const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
    class function OptionClass: TCnAIEngineOptionClass; override;
  end;

  TCnGeminiAIEngine = class(TCnAIBaseEngine)
  {* Gemini 引擎。现阶段号称已改成兼容 OpenAI 了}
  public
    class function EngineName: string; override;
  end;

  TCnQWenAIEngine = class(TCnAIBaseEngine)
  {* 通义千问 AI 引擎}
  protected
    class function GetModelListURL(const OrigURL: string): string; override;
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
  protected
    class function GetModelListURL(const OrigURL: string): string; override;
  public
    class function EngineName: string; override;
  end;

  TCnBaiChuanAIEngine = class(TCnAIBaseEngine)
  {* 百川智能 AI 引擎}
  protected
    function ParseModelList(ResponseRoot: TCnJSONObject): string; override;
  public
    class function EngineName: string; override;
  end;

  TCnDeepSeekAIEngine = class(TCnAIBaseEngine)
  {* DeepSeek（深度求索）AI 引擎}
  public
    class function EngineName: string; override;
  end;

  TCnVolceAIEngine = class(TCnAIBaseEngine)
  {* 火山引擎}
  protected
    class function GetModelListURL(const OrigURL: string): string; override;
  public
    class function EngineName: string; override;
  end;

  TCnOllamaAIEngine = class(TCnAIBaseEngine)
  {* 本地或私有化部署的集成 Ollama 引擎}
  protected
    class function GetModelListURL(const OrigURL: string): string; override;
    function ParseModelList(ResponseRoot: TCnJSONObject): string; override;

    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string;
      History: TStrings = nil): TBytes; override;
    function ParseResponse(SendId: Integer; StreamMode, Partly: Boolean; var Success: Boolean;
      var ErrorCode: Cardinal; var IsStreamEnd: Boolean; RequestType: TCnAIRequestType;
      const Response: TBytes): string; override;
  public
    class function EngineName: string; override;
    class function NeedApiKey: Boolean; override;
  end;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  CnCommon;

const
  CRLF = #13#10;
  LF = #10;

{ TCnOpenAIEngine }

class function TCnOpenAIAIEngine.EngineName: string;
begin
  Result := 'OpenAI';
end;

{ TCnQWenAIEngine }

class function TCnQWenAIEngine.GetModelListURL(const OrigURL: string): string;
begin
  Result := ''; // 通义千问不支持模型列表获取操作
end;

class function TCnQWenAIEngine.EngineName: string;
begin
  Result := '通义千问';
end;

{ TCnMoonshotAIEngine }

class function TCnMoonshotAIEngine.EngineName: string;
begin
  Result := '月之暗面';
end;

{ TCnChatGLMAIEngine }

class function TCnChatGLMAIEngine.GetModelListURL(const OrigURL: string): string;
begin
  Result := ''; // 智谱清言不支持模型列表获取操作
end;

class function TCnChatGLMAIEngine.EngineName: string;
begin
  Result := '智谱清言';
end;

{ TCnBaiChuanAIEngine }

function TCnBaiChuanAIEngine.ParseModelList(ResponseRoot: TCnJSONObject): string;
var
  I: Integer;
  Arr: TCnJSONArray;
begin
  // 从 RespRoot 中解析出模型列表，拼成逗号分隔的字符串并直接返回
  // 该引擎该接口的字段名是 model_show_name 而不是 id
  if (ResponseRoot['data'] <> nil) and (ResponseRoot['data'] is TCnJSONArray) then
  begin
    Arr := TCnJSONArray(ResponseRoot['data']);
    if Arr.Count > 0 then
    begin
      for I := 0 to Arr.Count - 1 do
      begin
        if (Arr[I]['model_show_name'] <> nil) and (Arr[I]['model_show_name'] is TCnJSONString) then
        begin
          if I = 0 then
            Result := Arr[I]['model_show_name'].AsString
          else
            Result := Result + ',' + Arr[I]['model_show_name'].AsString;
        end;
      end;
    end;
  end;
end;

class function TCnBaiChuanAIEngine.EngineName: string;
begin
  Result := '百川智能';
end;

{ TCnDeepSeekAIEngine }

class function TCnDeepSeekAIEngine.EngineName: string;
begin
  Result := 'DeepSeek';
end;

{ TCnVolceAIEngine }

class function TCnVolceAIEngine.GetModelListURL(const OrigURL: string): string;
begin
  Result := ''; // 火山引擎不支持模型列表获取操作
end;

class function TCnVolceAIEngine.EngineName: string;
begin
  Result := '火山引擎';
end;

{ TCnMistralAIAIEngine }

class function TCnMistralAIAIEngine.EngineName: string;
begin
  Result := 'MistralAI';
end;

{ TCnClaudeAIEngine }

function TCnClaudeAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string; History: TStrings): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
  I: Integer;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('stream', Option.Stream);
    ReqRoot.AddPair('temperature', Option.Temperature);
    ReqRoot.AddPair('max_tokens', (Option as TCnClaudeAIEngineOption).MaxTokens);

    ReqRoot.AddPair('system', Option.SystemMessage); // Claude 额外放 System 消息
    Arr := ReqRoot.AddArray('messages');

    // 先加历史
    if (RequestType = artRaw) and (History <> nil) and (History.Count > 0) then
    begin
      for I := History.Count - 1 downto 0 do
      begin
        if Trim(History[I]) <> '' then
        begin
          Msg := TCnJSONObject.Create;
          Msg.AddPair('role', 'user');
          Msg.AddPair('content', History[I]);
          Arr.AddValue(Msg);
        end;
      end;
    end;

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

class function TCnClaudeAIEngine.GetModelListURL(
  const OrigURL: string): string;
const
  MSGS = 'messages';
  MODEL = 'models';
begin
  // 采取古怪规则拼接 ModelList 的 URL
  Result := OrigURL;
  if StrEndWith(Result, MSGS) then
  begin
    Delete(Result, Pos(MSGS, Result), MaxInt);
    Result := Result + MODEL;
  end;
end;

class function TCnClaudeAIEngine.OptionClass: TCnAIEngineOptionClass;
begin
  Result := TCnClaudeAIEngineOption;
end;

function TCnClaudeAIEngine.ParseResponse(SendId: Integer; StreamMode, Partly: Boolean;
  var Success: Boolean; var ErrorCode: Cardinal; var IsStreamEnd: Boolean;
  RequestType: TCnAIRequestType; const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S, Prev: AnsiString;
  PrevS: string;
  P: PAnsiChar;
  HasPartly: Boolean;
  JsonObjs: TObjectList;
  I, Step: Integer;
begin
// 流格式，省略了复杂的：
// data: {"type": "content_block_start", "index": 0, "content_block": {"type": "text", "text": ""}}
// data: {"type": "content_block_delta", "index": 0, "delta": {"type": "text_delta", "text": "Hello"}}
// data: {"type": "message_stop"}

  Result := '';
  // 根据 SendId 找本次会话中留存的数据
  Prev := '';
  if FPrevRespRemainMap.Find(IntToStr(SendId), PrevS) then
  begin
    Prev := AnsiString(PrevS);
    S := Prev + BytesToAnsi(Response) // 把剩余内容拼上现有内容再次进行解析
  end
  else
    S := BytesToAnsi(Response);

  JsonObjs := TObjectList.Create(True);
  Step := CnJSONParse(PAnsiChar(S), JsonObjs);
  P := PAnsiChar(PAnsiChar(S) + Step);

  if (P <> #0) and (Step < Length(S)) then
  begin
    // 步进没处理完（长度没满足），且不是结束符，说明有剩余内容
    Prev := Copy(S, Step + 1, MaxInt);
  end
  else // 说明没剩余内容
    Prev := '';

  // 有无剩余都存起来
  FPrevRespRemainMap.Add(IntToStr(SendId), Prev);

  RespRoot := nil;
  if JsonObjs.Count > 0 then
    RespRoot := TCnJSONObject(JsonObjs[0]);

  if RespRoot = nil then
  begin
    // 一类原始错误
    Result := string(S);
  end
  else
  begin
    try
      // 正常回应
      HasPartly := False;
      if Partly then
      begin
        // 流式模式下，可能有多个 Obj，并且以 type 来区分
        for I := 0 to JsonObjs.Count - 1 do
        begin
          // 找 delta 中的 text，不判断 type
          RespRoot := TCnJSONObject(JsonObjs[I]);
          if (RespRoot['delta'] <> nil) and (RespRoot['delta'] is TCnJSONObject) then
          begin
            Msg := TCnJSONObject(RespRoot['delta']);
            if (Msg['text'] <> nil) and (Msg['text'] is TCnJSONString) then
            begin
              // 每一块回应拼起来
              Result := Result + Msg['text'].AsString;
              HasPartly := True;
            end;
          end;
          if (RespRoot['content_block'] <> nil) and (RespRoot['content_block'] is TCnJSONObject) then
          begin
            Msg := TCnJSONObject(RespRoot['content_block']);
            if (Msg['text'] <> nil) and (Msg['text'] is TCnJSONString) then
            begin
              // 每一块回应拼起来
              Result := Result + Msg['text'].AsString;
              HasPartly := True;
            end;
          end;

          // 也找结束标记 type
          if (RespRoot['type'] <> nil) and (RespRoot['type'] is TCnJSONString) then
          begin
            if RespRoot['type'].AsString = 'message_stop' then
            begin
              IsStreamEnd := True;
              Exit;
            end;
          end;
        end;
      end
      else // 完整模式下
      begin
        // 正常回应
        if (RespRoot['content'] <> nil) and (RespRoot['content'] is TCnJSONArray) then
        begin
          Arr := TCnJSONArray(RespRoot['content']);
          if (Arr.Count > 0) and (Arr[0]['text'] <> nil) and (Arr[0]['text'] is TCnJSONString) then
            Result := Arr[0]['text'].AsString;
        end;

        if not HasPartly and (Result = '') then
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
      end;

      // 兜底，所有解析都无效就直接用整个 JSON 作为返回信息
      if not HasPartly and (Result = '') then
        Result := string(S);
    finally
      JsonObjs.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

procedure TCnClaudeAIEngine.PrepareRequestHeader(const ApiKey: string; Headers: TStringList);
begin
  inherited;
  DeleteAuthorizationHeader(Headers); // 删除原有的认证头，换新头
  Headers.Add('x-api-key: ' + ApiKey);
  Headers.Add('anthropic-version: ' + (Option as TCnClaudeAIEngineOption).AnthropicVersion);
end;

{ TCnGeminiAIEngine }

class function TCnGeminiAIEngine.EngineName: string;
begin
  Result := 'Gemini';
end;

{ TCnOllamaAIEngine }

class function TCnOllamaAIEngine.GetModelListURL(const OrigURL: string): string;
const
  CHAT = 'api/chat';
  MODEL = 'api/tags';
begin
  // 采取古怪规则拼接 ModelList 的 URL
  Result := OrigURL;
  if StrEndWith(Result, CHAT) then
  begin
    Delete(Result, Pos(CHAT, Result), MaxInt);
    Result := Result + MODEL;
  end;
end;

function TCnOllamaAIEngine.ParseModelList(ResponseRoot: TCnJSONObject): string;
var
  I: Integer;
  Arr: TCnJSONArray;
begin
  // 从 RespRoot 中解析出模型列表，拼成逗号分隔的字符串并直接返回
  // 该引擎该接口的数组名是 models 而不是 data，字段名是 name 而不是 id
  if (ResponseRoot['models'] <> nil) and (ResponseRoot['models'] is TCnJSONArray) then
  begin
    Arr := TCnJSONArray(ResponseRoot['data']);
    if Arr.Count > 0 then
    begin
      for I := 0 to Arr.Count - 1 do
      begin
        if (Arr[I]['name'] <> nil) and (Arr[I]['name'] is TCnJSONString) then
        begin
          if I = 0 then
            Result := Arr[I]['name'].AsString
          else
            Result := Result + ',' + Arr[I]['name'].AsString;
        end;
      end;
    end;
  end;
end;

function TCnOllamaAIEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string; History: TStrings): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
  I: Integer;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', Option.Model);
    ReqRoot.AddPair('stream', Option.Stream);
    Arr := ReqRoot.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'system');
    Msg.AddPair('content', Option.SystemMessage);
    Arr.AddValue(Msg);

    // 先加历史
    if (RequestType = artRaw) and (History <> nil) and (History.Count > 0) then
    begin
      for I := History.Count - 1 downto 0 do
      begin
        if Trim(History[I]) <> '' then
        begin
          Msg := TCnJSONObject.Create;
          Msg.AddPair('role', 'user');
          Msg.AddPair('content', History[I]);
          Arr.AddValue(Msg);
        end;
      end;
    end;

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

function TCnOllamaAIEngine.ParseResponse(SendId: Integer; StreamMode, Partly: Boolean;
  var Success: Boolean; var ErrorCode: Cardinal; var IsStreamEnd: Boolean;
  RequestType: TCnAIRequestType; const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  S, Prev: AnsiString;
  PrevS: string;
  P: PAnsiChar;
  HasPartly: Boolean;
  JsonObjs: TObjectList;
  I, Step: Integer;
begin
// 流式格式如下：
// {"model":"qwen2.5-coder","created_at":"2025-03-01T12:25:28.461904Z","message":
//   {"role":"assistant","content":"。"},"done":false}
// {"model":"qwen2.5-coder","created_at":"2025-03-01T12:25:29.178563Z","message":
//   {"role":"assistant","content":""},"done_reason":"stop","done":true,"
//   total_duration":104533692025,"load_duration":8214582022,"prompt_eval_count":35,
//   "prompt_eval_duration":21698000000,"eval_count":99,"eval_duration":73967000000}

  Result := '';
  // 根据 SendId 找本次会话中留存的数据
  Prev := '';
  if FPrevRespRemainMap.Find(IntToStr(SendId), PrevS) then
  begin
    Prev := AnsiString(PrevS);
    S := Prev + BytesToAnsi(Response) // 把剩余内容拼上现有内容再次进行解析
  end
  else
    S := BytesToAnsi(Response);

  JsonObjs := TObjectList.Create(True);
  Step := CnJSONParse(PAnsiChar(S), JsonObjs);
  P := PAnsiChar(PAnsiChar(S) + Step);

  if (P <> #0) and (Step < Length(S)) then
  begin
    // 步进没处理完（长度没满足），且不是结束符，说明有剩余内容
    Prev := Copy(S, Step + 1, MaxInt);
  end
  else // 说明没剩余内容
    Prev := '';

  // 有无剩余都存起来
  FPrevRespRemainMap.Add(IntToStr(SendId), Prev);

  RespRoot := nil;
  if JsonObjs.Count > 0 then
    RespRoot := TCnJSONObject(JsonObjs[0]);

  if RespRoot = nil then
  begin
    // 一类原始错误，如账号达到最大并发等，注意流模式下没有单独的 datadone
    Result := string(S);
  end
  else
  begin
    try
      // 正常回应
      HasPartly := False;
      if Partly then
      begin
        // 流式模式下，可能有多个 Obj
        for I := 0 to JsonObjs.Count - 1 do
        begin
          RespRoot := TCnJSONObject(JsonObjs[I]);
          if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONObject) then
          begin
            Msg := TCnJSONObject(RespRoot['message']);
            if  Msg['content'] <> nil then
              Result := Result + Msg['content'].AsString;

            HasPartly := True;
          end;

          // 有 done 字段为 True 表示结尾
          if (RespRoot['done'] <> nil) and (RespRoot['done'] is TCnJSONTrue) then
          begin
            IsStreamEnd := True;
            FPrevRespRemainMap.Delete(IntToStr(SendId)); // 也清理缓存，但因为有数据，不能直接返回
          end;
        end;
      end
      else // 整块模式，其简要格式和流模式有点类似
      begin
        // Ollama 的简要格式，message 下其实还有 role: assistant 但不管
        if (RespRoot['message'] <> nil) and (RespRoot['message'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['message']);
          if Msg['content'] <> nil then
            Result := Msg['content'].AsString;
        end;
      end;

      if not HasPartly and (Result = '') then
      begin
        // Ollama 的简要错误格式
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONString) then
          Result := RespRoot['error'].AsString;
      end;

      // 兜底，所有解析都无效就直接用整个 JSON 作为返回信息
      if Result = '' then
        Result := string(S);
    finally
      JsonObjs.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

initialization
  RegisterAIEngine(TCnDeepSeekAIEngine);
  RegisterAIEngine(TCnOpenAIAIEngine);
  RegisterAIEngine(TCnMistralAIAIEngine);
  RegisterAIEngine(TCnGeminiAIEngine);
  RegisterAIEngine(TCnClaudeAIEngine);
  RegisterAIEngine(TCnQWenAIEngine);
  RegisterAIEngine(TCnVolceAIEngine);
  RegisterAIEngine(TCnMoonshotAIEngine);
  RegisterAIEngine(TCnChatGLMAIEngine);
  RegisterAIEngine(TCnBaiChuanAIEngine);
  RegisterAIEngine(TCnOllamaAIEngine);

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
