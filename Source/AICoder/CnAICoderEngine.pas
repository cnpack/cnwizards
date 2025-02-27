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

unit CnAICoderEngine;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的引擎管理单元
* 单元作者：CnPack 开发组
* 备    注：与 API 服务端通讯时如返回错误码 12022 一般是连接超时
*           12029 一般是 SSL 版本过低导致无法建立连接
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10/11 + Delphi/C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, Contnrs, Windows, CnNative, CnContainers, CnJSON, CnWizConsts,
  CnInetUtils, {$IFNDEF STAND_ALONE} CnWizOptions, {$ENDIF} CnAICoderConfig,
  CnThreadPool, CnAICoderNetClient;

const
  CN_RESP_DATA_DONE = 'data:[DONE]';

type
  TCnAIAnswerObject = class(TPersistent)
  {* 封装的 AI 应答结果}
  private
    FSendId: Integer;
    FAnswer: TBytes;
    FSuccess: Boolean;
    FPartly: Boolean;
    FCallback: TCnAIAnswerCallback;
    FRequestType: TCnAIRequestType;
    FErrorCode: Cardinal;
    FTag: TObject;
    FStreamMode: Boolean;
  public
    property StreamMode: Boolean read FStreamMode write FStreamMode;
    property Partly: Boolean read FPartly write FPartly;

    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property RequestType: TCnAIRequestType read FRequestType write FRequestType;
    property ErrorCode: Cardinal read FErrorCode write FErrorCode;
    property Answer: TBytes read FAnswer write FAnswer;
    property Tag: TObject read FTag write FTag;
    property Callback: TCnAIAnswerCallback read FCallback write FCallback;
  end;

  TCnAIBaseEngine = class
  {* 处理特定 AI 服务提供者的引擎基类，有自身的特定配置，
    并有添加请求任务、发起网络请求、获得结果并回调的典型功能}
  private
    FPoolRef: TCnThreadPool; // 从 Manager 处拿来持有的线程池对象引用
    FOption: TCnAIEngineOption;
    FAnswerQueue: TCnObjectQueue;
    FProcessingDataObj: TCnAINetRequestDataObject;
    FProcessingThread: TCnPoolingThread;
    procedure CheckOptionPool;
    procedure HttpProgressData(Sender: TObject; TotalSize, CurrSize: Integer;
      Data: Pointer; DataLen: Integer; var Abort: Boolean);
  protected
    procedure DeleteAuthorizationHeader(Headers: TStringList);
    {* 供子类按需使用的，删除请求头里的 Authorization 字段，以备其他认证方式}

    procedure TalkToEngine(Sender: TCnThreadPool; DataObj: TCnTaskDataObject;
      Thread: TCnPoolingThread); virtual;
    {* 有默认实现且子类可重载的、与 AI 服务提供者进行网络通讯获取结果的实现函数
      是第一步组装好数据扔给线程池后，由线程池调度后在具体工作线程中被调用
      在一次完整的 AI 网络通讯过程中属于第三步，内部会根据结果回调 OnAINetDataResponse 事件}

    procedure OnAINetDataResponse(Success, Partly: Boolean; Thread: TCnPoolingThread;
      DataObj: TCnAINetRequestDataObject; Data: TBytes); virtual;
    {* AI 服务提供者进行网络通讯的结果回调，是在子线程中被调用的，内部应 Sync 给请求调用者
      Success 返回成功与否，成功则 Data 中是数据
      在一次完整的 AI 网络通讯过程中属于第四步}

    procedure SyncCallback;
    {* 被上述第四步通过 Synchronize 的方式调用，之前已将应答对象推入 FAnswerQueue 队列
      在一次完整的 AI 网络通讯过程中属于第五步}

    // 以下四过程，子类看接口情况重载
    function GetRequestURL(DataObj: TCnAINetRequestDataObject): string; virtual;
    {* 请求发送前，给子类一个处理自定义 URL  的机会}

    procedure PrepareRequestHeader(Headers: TStringList); virtual;
    {* 请求发送前，给子类一个处理自定义 HTTP 头的机会}

    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string): TBytes; virtual;
    {* 根据请求类型与原始代码，组装 Post 的数据，一般是 JSON 格式}

    function ParseResponse(StreamMode, Partly: Boolean; var Success: Boolean; var ErrorCode: Cardinal;
      RequestType: TCnAIRequestType; const Response: TBytes): string; virtual;
    {* 根据请求类型与原始回应，解析回应数据，一般是 JSON 格式，返回字符串给调用者，
      同时允许根据返回的错误信息更改成功与否。
      StreamMode 是请求发起时是否支持流式，姑且认为服务端会同样多次返回拼接。
      Partly 为 True 表示此次数据是服务器返回的中间数据，注意数据过短时可能等于完整数据。
      内部机制确保了不会在 StreamMode 为 False 时来 Partly 为 True 的数据，不会在 StreamMode 为 True 时来完整数据}
  public
    class function EngineName: string; virtual;
    {* 子类必须有个名字}
    class function EngineID: string;
    {* 引擎的 ID，供存储保存用，根据类名运算而来}
    class function OptionClass: TCnAIEngineOptionClass; virtual;
    {* 引擎配置所对应的类，默认为基类 TCnAIEngineOption}
    class function NeedApiKey: Boolean; virtual;
    {* 引擎是否需要提供 API Key 才能调用，默认 True}

    constructor Create(ANetPool: TCnThreadPool); virtual;
    destructor Destroy; override;

    procedure InitOption;
    {* 根据引擎名去设置管理类中取自身的设置对象}

    function AskAIEngine(const Text: TBytes; Tag: TObject;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 用户调用的与 AI 通讯的过程，传入原始通讯数据，内部会组装成请求对象扔给线程池，返回一个请求 ID
      在一次完整的 AI 网络通讯过程中属于第一步；第二步是线程池调度的 ProcessRequest 转发}

    function AskAIEngineForCode(const Code: string; Tag: TObject; RequestType: TCnAIRequestType;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 进一步封装的用户调用的解释代码或检查代码的过程，内部将 Code 转换为 JSON 后调用 AskAIEngine，也算第一步}

    property Option: TCnAIEngineOption read FOption;
    {* 引擎配置，根据名字从配置管理器中取来的引用}
  end;

  TCnAIBaseEngineClass = class of TCnAIBaseEngine;
  {* AI 引擎类及其子类}

  TCnAIEngineManager = class
  {* 所有提供 AI 服务的引擎的管理类，管理引擎实例列表}
  private
    FPool: TCnThreadPool; // 持有的线程池对象
    FCurrentIndex: Integer;
    FEngines: TObjectList;
    function GetCurrentEngine: TCnAIBaseEngine;
    function GetEnginCount: Integer;
    function GetEngine(Index: Integer): TCnAIBaseEngine;
    procedure SetCurrentIndex(const Value: Integer);
    function GetCurrentEngineName: string;
    procedure SetCurrentEngineName(const Value: string);
  protected
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
    function FindEngineIndexByName(const EngineName: string): Integer;
    {* 根据特定引擎名查找内部索引号，供设置 CurrentIndex 使用}
  public
    constructor Create; virtual;
    {* 构造函数，传入外部的网络线程池引用，供分配给 AI 引擎使用}
    destructor Destroy; override;

    procedure LoadFromDirectory(const Dir, BaseFileFmt: string);
    {* 独立运行时的加载总入口，从指定目录及基础文件名加载所有配置}
    procedure SaveToDirectory(const Dir, BaseFileFmt: string);
    {* 独立运行时的保存总入口，将所有配置根据基础文件名存入指定目录}

    function GetEngineByOption(Option: TCnAIEngineOption): TCnAIBaseEngine;
    {* 根据选项对象查找对应引擎}

{$IFNDEF STAND_ALONE}
    procedure LoadFromWizOptions;
    {* 专家包的加载总入口，动态加载所有配置，内部会分辨不同目录}
    procedure SaveToWizOptions;
    {* 专家包的保存总入口，动态保存所有配置到用户目录}
{$ENDIF}

    property CurrentEngineName: string read GetCurrentEngineName write SetCurrentEngineName;
    {* 获得及设置当前引擎名称，前者从当前引擎中取，后者会切换引擎}
    property CurrentIndex: Integer read FCurrentIndex write SetCurrentIndex;
    {* 当前活动引擎的索引号，供外界切换设置}
    property CurrentEngine: TCnAIBaseEngine read GetCurrentEngine;
    {* 当前活动引擎}

    property EngineCount: Integer read GetEnginCount;
    {* 引擎数量}
    property Engines[Index: Integer]: TCnAIBaseEngine read GetEngine; default;
    {* 根据索引取 AI 引擎实例}
  end;

procedure RegisterAIEngine(AIEngineClass: TCnAIBaseEngineClass);
{* 注册一个 AI 引擎}

function CnAIEngineManager: TCnAIEngineManager;
{* 返回一全局 AI 引擎管理对象}

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CRLF = #13#10;
  LF = #10;

type
  TThreadHack = class(TThread);

var
  FAIEngineManager: TCnAIEngineManager = nil;

  FAIEngines: TClassList = nil;

procedure RegisterAIEngine(AIEngineClass: TCnAIBaseEngineClass);
begin
  if FAIEngines.IndexOf(AIEngineClass) < 0 then
    FAIEngines.Add(AIEngineClass);
end;

function CnAIEngineManager: TCnAIEngineManager;
begin
  if FAIEngineManager = nil then
    FAIEngineManager := TCnAIEngineManager.Create;
  Result := FAIEngineManager;
end;

{ TCnAIEngineManager }

constructor TCnAIEngineManager.Create;
var
  I: Integer;
  Clz: TCnAIBaseEngineClass;
  Engine: TCnAIBaseEngine;
begin
  inherited Create;
  FEngines := TObjectList.Create(True);
  FPool := TCnThreadPool.CreateSpecial(nil, TCnAINetRequestThread);

  // 初始化网络线程池
  FPool.OnProcessRequest := ProcessRequest;
  FPool.AdjustInterval := 5 * 1000;
  FPool.MinAtLeast := False;
  FPool.ThreadDeadTimeout := 10 * 1000;
  FPool.ThreadsMinCount := 0;
  FPool.ThreadsMaxCount := 2;
  FPool.TerminateWaitTime := 2 * 1000;
  FPool.ForceTerminate := True; // 允许强制结束

  // 创建各 AI 引擎实例
  for I := 0 to FAIEngines.Count - 1 do
  begin
    Clz := TCnAIBaseEngineClass(FAIEngines[I]);
    if Clz <> nil then
    begin
      Engine := TCnAIBaseEngine(Clz.NewInstance);
      Engine.Create(FPool);

      FEngines.Add(Engine);
    end;
  end;
end;

destructor TCnAIEngineManager.Destroy;
begin
  inherited;
  FPool.Free;
  FEngines.Free;
end;

function TCnAIEngineManager.FindEngineIndexByName(
  const EngineName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Trim(EngineName) <> '' then
  begin
    for I := 0 to FEngines.Count - 1 do
    begin
      if (FEngines[I] <> nil) and (TCnAIBaseEngine(FEngines[I]).EngineName = EngineName) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
end;

function TCnAIEngineManager.GetCurrentEngine: TCnAIBaseEngine;
begin
  if (FCurrentIndex >= 0) and (FCurrentIndex < FEngines.Count) then
    Result := TCnAIBaseEngine(FEngines[FCurrentIndex])
  else
    Result := nil;
//  raise Exception.Create('NO Engine Selected.');
end;

function TCnAIEngineManager.GetCurrentEngineName: string;
begin
  Result := CurrentEngine.EngineName;
end;

function TCnAIEngineManager.GetEnginCount: Integer;
begin
  Result := FEngines.Count;
end;

function TCnAIEngineManager.GetEngine(Index: Integer): TCnAIBaseEngine;
begin
  Result := TCnAIBaseEngine(FEngines[Index]);
end;

procedure TCnAIEngineManager.LoadFromDirectory(const Dir,
  BaseFileFmt: string);
var
  I: Integer;
  S: string;
begin
  // OptionManager 加载基本设置
  S := Dir + Format(BaseFileFmt, ['']);
  if FileExists(S) then
    CnAIEngineOptionManager.LoadFromFile(S);

  // 挨个根据引擎 ID，修改文件名，创建并加载其对应 Option
  for I := 0 to EngineCount - 1 do
  begin
    S := Dir + Format(BaseFileFmt, [Engines[I].EngineID]);
    CnAIEngineOptionManager.CreateOptionFromFile(Engines[I].EngineName,
      S, Engines[I].OptionClass);

    Engines[I].InitOption;
  end;
end;

procedure TCnAIEngineManager.SaveToDirectory(const Dir,
  BaseFileFmt: string);
var
  I: Integer;
  S: string;
begin
  // OptionManager 加载基本设置
  S := Format(BaseFileFmt, ['']);
  CnAIEngineOptionManager.SaveToFile(Dir + S);

  // 挨个根据引擎 ID，修改文件名，保存其对应 Option
  for I := 0 to EngineCount - 1 do
  begin
    S := Format(BaseFileFmt, [Engines[I].EngineID]);
    CnAIEngineOptionManager.SaveOptionToFile(Engines[I].EngineName, Dir + S);
  end;
end;

procedure TCnAIEngineManager.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
begin
  CurrentEngine.TalkToEngine(Sender, DataObj, Thread);
end;

procedure TCnAIEngineManager.SetCurrentEngineName(const Value: string);
var
  Idx: Integer;
begin
  Idx := FindEngineIndexByName(Value);
  if Idx >= 0 then
    CurrentIndex := Idx;
//  else
//    raise Exception.CreateFmt('Invalid Engine Name %s', [Value]);
end;

procedure TCnAIEngineManager.SetCurrentIndex(const Value: Integer);
begin
  if FCurrentIndex <> Value then
  begin
    // 旧引擎释放
    FCurrentIndex := Value;
    // 记录引擎改变了，如果需要的话初始化新引擎
  end;
end;

{$IFNDEF STAND_ALONE}

procedure TCnAIEngineManager.LoadFromWizOptions;
var
  I: Integer;
  S: string;
  OrigOption, Option: TCnAIEngineOption;
begin
  // OptionManager 加载基本设置
  S := WizOptions.GetUserFileName(Format(SCnAICoderEngineOptionFileFmt, ['']), True);
  if FileExists(S) then
    CnAIEngineOptionManager.LoadFromFile(S);

  // 挨个根据引擎 ID，修改文件名，创建并加载其对应 Option
  for I := 0 to EngineCount - 1 do
  begin
    S := WizOptions.GetUserFileName(Format(SCnAICoderEngineOptionFileFmt,
      [Engines[I].EngineID]), True);
    Option := CnAIEngineOptionManager.CreateOptionFromFile(Engines[I].EngineName,
      S, Engines[I].OptionClass);

    // 检查原始数据文件
    OrigOption := nil;
    try
      S := WizOptions.GetDataFileName(Format(SCnAICoderEngineOptionFileFmt,
        [Engines[I].EngineID]));
      OrigOption := CnAIEngineOptionManager.CreateOptionFromFile(Engines[I].EngineName,
        S, Engines[I].OptionClass, False); // 注意该原始配置对象无需进行管理

      // OrigOption 中的新的非空选项，要赋值给 Option 的同名的空值的属性，仅几种基本数据类型
      // 该机制用于新版配置增加新的属性时使用，希望嫑有新旧区分有误的问题。
      OrigOption.AssignToEmpty(Option);
    finally
      OrigOption.Free;
    end;

    Engines[I].InitOption;
  end;
end;

procedure TCnAIEngineManager.SaveToWizOptions;
var
  I: Integer;
  S, F: string;
begin
  // OptionManager 加载基本设置
  F := Format(SCnAICoderEngineOptionFileFmt, ['']);
  S := WizOptions.GetUserFileName(F, False);
  CnAIEngineOptionManager.SaveToFile(S);
  WizOptions.CheckUserFile(F);

  // 挨个根据引擎 ID，修改文件名，保存其对应 Option
  for I := 0 to EngineCount - 1 do
  begin
    F := Format(SCnAICoderEngineOptionFileFmt, [Engines[I].EngineID]);
    S := WizOptions.GetUserFileName(F, False);
    CnAIEngineOptionManager.SaveOptionToFile(Engines[I].EngineName, S);
    WizOptions.CheckUserFile(F);
  end;
end;

{$ENDIF}

function TCnAIEngineManager.GetEngineByOption(
  Option: TCnAIEngineOption): TCnAIBaseEngine;
var
  I: Integer;
begin
  for I := 0 to EngineCount - 1 do
  begin
    if Engines[I].Option = Option then
    begin
      Result := Engines[I];
      Exit;
    end;
  end;
  Result := nil;
end;

{ TCnAIBaseEngine }

function TCnAIBaseEngine.AskAIEngine(const Text: TBytes; Tag: TObject;
  AnswerCallback: TCnAIAnswerCallback): Integer;
var
  Obj: TCnAINetRequestDataObject;
begin
  CheckOptionPool;
  Result := 0;

  if Length(Text) > 0 then
  begin
    Obj := TCnAINetRequestDataObject.Create;
    Obj.URL := FOption.URL;
    Obj.Tag := Tag;
    Randomize;
    Obj.SendId := 10000000 + Random(100000000);

    // 拼装 JSON 格式的请求作为 Post 的负载内容搁 Data 里
    Obj.Data := Text;
    Obj.StreamMode := FOption.Stream;

    Obj.OnAnswer := AnswerCallback;
    Obj.OnResponse := OnAINetDataResponse;
    FPoolRef.AddRequest(Obj);

    Result := Obj.SendId;
  end
  else
  begin
    if Assigned(AnswerCallback) then // 没发送的数据就直接回调出错
      AnswerCallback(FOption.Stream, False, False, -1, 'No Message to Send', ERROR_INVALID_DATA, Tag);
  end;
end;

function TCnAIBaseEngine.AskAIEngineForCode(const Code: string; Tag: TObject;
  RequestType: TCnAIRequestType; AnswerCallback: TCnAIAnswerCallback): Integer;
begin
  Result := AskAIEngine(ConstructRequest(RequestType, Code), Tag, AnswerCallback);
end;

procedure TCnAIBaseEngine.CheckOptionPool;
begin
  // 检查 Pool、Option 等内容是否合法
  if FPoolRef = nil then
    raise Exception.Create('No Net Pool');

  if FOption = nil then
    raise Exception.Create('No Options for ' + EngineName);
end;

procedure TCnAIBaseEngine.HttpProgressData(Sender: TObject; TotalSize, CurrSize: Integer;
  Data: Pointer; DataLen: Integer; var Abort: Boolean);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('*** HTTP Request OK Getting Progress ' + IntToStr(CurrSize));
{$ENDIF}
  if (FProcessingDataObj <> nil) and (FProcessingThread <> nil) then
  begin
    if Assigned(FProcessingDataObj.OnResponse) then
    begin
      if (Data <> nil) and (DataLen > 0) then
      begin
        FProcessingDataObj.OnResponse(True, True, FProcessingThread, FProcessingDataObj,
          NewBytesFromMemory(Data, DataLen));
      end;
    end;
  end;
end;

function TCnAIBaseEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    ReqRoot.AddPair('model', FOption.Model);
    ReqRoot.AddPair('temperature', FOption.Temperature);
    ReqRoot.AddPair('stream', FOption.Stream);
    Arr := ReqRoot.AddArray('messages');

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'system');
    Msg.AddPair('content', FOption.SystemMessage);
    Arr.AddValue(Msg);

    Msg := TCnJSONObject.Create;
    Msg.AddPair('role', 'user');
    if RequestType = artExplainCode then
      Msg.AddPair('content', FOption.ExplainCodePrompt + #13#10 + Code)
    else if RequestType = artReviewCode then
      Msg.AddPair('content', FOption.ReviewCodePrompt + #13#10 + Code)
    else if RequestType = artGenTestCase then
      Msg.AddPair('content', FOption.GenTestCasePrompt + #13#10 + Code)
    else if RequestType = artRaw then
      Msg.AddPair('content', Code);

    Arr.AddValue(Msg);

    S := ReqRoot.ToJSON;
    Result := AnsiToBytes(S);
  finally
    ReqRoot.Free;
  end;
end;

function TCnAIBaseEngine.ParseResponse(StreamMode, Partly: Boolean; var Success: Boolean;
  var ErrorCode: Cardinal; RequestType: TCnAIRequestType; const Response: TBytes): string;
var
  RespRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
  HasPartly: Boolean;
  JsonObjs: TObjectList;
  I: Integer;
begin
  Result := '';
  S := BytesToAnsi(Response);

  JsonObjs := TObjectList.Create(True);
  CnJSONParse(S, JsonObjs);

  RespRoot := nil;
  if JsonObjs.Count > 0 then
    RespRoot := TCnJSONObject(JsonObjs[0]);

  if RespRoot = nil then
  begin
    // 流模式下如果单独碰到结束符，表示结束，返回结束符
    if Partly and (Pos(CN_RESP_DATA_DONE, S) = 1) then
    begin
      Result := CN_RESP_DATA_DONE;
      Exit;
    end;

    // 其他情况可能是一类原始错误，如账号达到最大并发等
    Result := S;
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
          if (RespRoot['choices'] <> nil) and (RespRoot['choices'] is TCnJSONArray) then
          begin
            Arr := TCnJSONArray(RespRoot['choices']);
            if (Arr.Count > 0) and (Arr[0]['delta'] <> nil) and (Arr[0]['delta'] is TCnJSONObject) then
            begin
              // 每一块回应拼起来
              Msg := TCnJSONObject(Arr[0]['delta']);
              if  Msg['content'] <> nil then
                Result := Result + Msg['content'].AsString;
              HasPartly := True;
            end;
          end;
        end;
      end
      else // 完整模式下
      begin
        if (RespRoot['choices'] <> nil) and (RespRoot['choices'] is TCnJSONArray) then
        begin
          Arr := TCnJSONArray(RespRoot['choices']);
          if (Arr.Count > 0) and (Arr[0]['message'] <> nil) and (Arr[0]['message'] is TCnJSONObject) then
          begin
            // 整块回应
            Msg := TCnJSONObject(Arr[0]['message']);
            if Msg['content'] <> nil then
              Result := Msg['content'].AsString;
          end;
        end;
      end;

      if not HasPartly and (Result = '') then
      begin
        // 只要没有正常回应，就说明出错了
        Success := False;

        // 一类业务错误，比如 Key 无效等
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // 一类业务返回的网络错误，比如 URL 错了等
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

      // 兜底，整块模式下，所有解析都无效就直接用整个 JSON 作为返回信息
      if not HasPartly and (Result = '') then
        Result := S;
    finally
      JsonObjs.Free;
    end;
  end;

  // 处理一下回车换行
  if Pos(CRLF, Result) <= 0 then
    Result := StringReplace(Result, LF, CRLF, [rfReplaceAll]);
end;

constructor TCnAIBaseEngine.Create(ANetPool: TCnThreadPool);
begin
  inherited Create;
  FPoolRef := ANetPool;

  FAnswerQueue := TCnObjectQueue.Create(True);
  InitOption;
end;

destructor TCnAIBaseEngine.Destroy;
begin
  while not FAnswerQueue.IsEmpty do
    FAnswerQueue.Pop.Free;

  FAnswerQueue.Free;
  inherited;
end;

procedure TCnAIBaseEngine.InitOption;
begin
  FOption := CnAIEngineOptionManager.GetOptionByEngine(EngineName)
end;

procedure TCnAIBaseEngine.OnAINetDataResponse(Success, Partly: Boolean;
  Thread: TCnPoolingThread; DataObj: TCnAINetRequestDataObject; Data: TBytes);
var
  AnswerObj: TCnAIAnswerObject;
begin
  if Success then
  begin
    // 发送时如果声明了非 StreamMode，那么 Partly 返回成功数据时要忽略，等完整返回
    if not TCnAINetRequestDataObject(DataObj).StreamMode and Partly then
      Exit;

    // 发送时如果声明了 StreamMode，那么只处理每次的 Partly 返回数据，不处理完整的
    if TCnAINetRequestDataObject(DataObj).StreamMode and not Partly then
      Exit;
  end;

  // 网络线程里拿到数据或结果后本事件被直接调用，适当包装后 Synchronize 返回给宿主
  AnswerObj := TCnAIAnswerObject.Create;
  AnswerObj.StreamMode := TCnAINetRequestDataObject(DataObj).StreamMode;
  AnswerObj.Partly := Partly;

  AnswerObj.Success := Success;
  AnswerObj.SendId := TCnAINetRequestDataObject(DataObj).SendId;
  AnswerObj.RequestType := TCnAINetRequestDataObject(DataObj).RequestType;
  AnswerObj.Callback := TCnAINetRequestDataObject(DataObj).OnAnswer;
  AnswerObj.Tag := TCnAINetRequestDataObject(DataObj).Tag;
  AnswerObj.Answer := Data; // 引用，但有计数，不会随便释放

  if not Success then
    AnswerObj.ErrorCode := GetLastError;
  // 典型的错误码中，12002 是超时，12029 是无法建立连接可能是 SSL 版本错等

  FAnswerQueue.Push(AnswerObj);
  TThreadHack(Thread).Synchronize(SyncCallback);
end;

procedure TCnAIBaseEngine.SyncCallback;
var
  AnswerObj: TCnAIAnswerObject;
  Answer: string;
begin
  AnswerObj := TCnAIAnswerObject(FAnswerQueue.Pop);
  if AnswerObj <> nil then
  begin
    if Assigned(AnswerObj.Callback) then
    begin
      // SyncCallback 被调用时就确保了不会在 StreamMode 为 False 时来 Partly 数据
      // 以及不会在 StreamMode 为 True 时来完整数据
      Answer := ParseResponse(AnswerObj.StreamMode, AnswerObj.Partly,
        AnswerObj.FSuccess, AnswerObj.FErrorCode, AnswerObj.RequestType, AnswerObj.Answer);
      AnswerObj.Callback(AnswerObj.StreamMode, AnswerObj.Partly, AnswerObj.Success,
        AnswerObj.SendId, Answer, AnswerObj.ErrorCode, AnswerObj.Tag);
    end;
    AnswerObj.Free;
  end;
end;

procedure TCnAIBaseEngine.TalkToEngine(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
  AURL: string;
begin
  HTTP := nil;
  Stream := nil;

  try
    HTTP := TCnHTTP.Create;

    // 设置超时，默认 0 表示按系统来
    HTTP.ConnectTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.SendTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.ReceiveTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.OnProgressData := HttpProgressData;

    // 如有就设置代理
    if CnAIEngineOptionManager.UseProxy then
    begin
      if Trim(CnAIEngineOptionManager.ProxyServer) <> '' then
      begin
        HTTP.ProxyMode := pmProxy;
        HTTP.ProxyServer := CnAIEngineOptionManager.ProxyServer;
        HTTP.ProxyUserName := CnAIEngineOptionManager.ProxyUserName;
        HTTP.ProxyPassword := CnAIEngineOptionManager.ProxyPassword;
      end
      else
        HTTP.ProxyMode := pmIE;
    end;

    if FOption.ApiKey <> '' then
      HTTP.HttpRequestHeaders.Add('Authorization: Bearer ' + FOption.ApiKey);
    // 大多数 AI 引擎的身份验证都是这句。少数不是的，可以在子类的 PrepareRequestHeader 里删掉这句再加

    PrepareRequestHeader(HTTP.HttpRequestHeaders);

    Stream := TMemoryStream.Create;
    AURL := GetRequestURL(TCnAINetRequestDataObject(DataObj));

    // 临时记录 DataObj 的引用，因为 GetStream 过程中有回调需要使用
    FProcessingDataObj := TCnAINetRequestDataObject(DataObj);
    FProcessingThread := Thread;
    if HTTP.GetStream(AURL, Stream, TCnAINetRequestDataObject(DataObj).Data) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size));
{$ENDIF}

      // 这里要把结果送给 UI 供处理，结果不能依赖于本线程，因为 UI 主线程的调用处理结果的时刻是不确定的，
      // 而离了本方法，Thread 的状态就未知了，搁 Thread 里的内容可能会因 Thread 被池子调度而被冲掉
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(True, False, Thread, TCnAINetRequestDataObject(DataObj), StreamToBytes(Stream));
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request Fail.');
{$ENDIF}
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(False, False, Thread, TCnAINetRequestDataObject(DataObj), nil);
    end;
  finally
    FProcessingThread := nil;
    FProcessingDataObj := nil;
    Stream.Free;
    HTTP.Free;
  end;
end;

procedure TCnAIBaseEngine.PrepareRequestHeader(Headers: TStringList);
begin
  Headers.Add('Content-Type: application/json');
end;

class function TCnAIBaseEngine.EngineID: string;
const
  PREFIX = 'TCn';
  SUBFIX = 'AIEngine';
begin
  // TCn***AIEngine 的命名方法
  Result := ClassName;
  if Pos(PREFIX, Result) = 1 then
    Delete(Result, 1, Length(PREFIX));
  if Pos(SUBFIX, Result) = Length(Result) - Length(SUBFIX) + 1 then
    Result := Copy(Result, 1, Length(Result) - Length(SUBFIX));

  if Result = '' then
    Result := 'Default';
end;

class function TCnAIBaseEngine.OptionClass: TCnAIEngineOptionClass;
begin
  Result := TCnAIEngineOption;
end;

class function TCnAIBaseEngine.EngineName: string;
begin
  Result := '<NoName>';
end;

function TCnAIBaseEngine.GetRequestURL(DataObj: TCnAINetRequestDataObject): string;
begin
  Result := DataObj.URL;
end;

class function TCnAIBaseEngine.NeedApiKey: Boolean;
begin
  Result := True;
end;

procedure TCnAIBaseEngine.DeleteAuthorizationHeader(Headers: TStringList);
var
  I: Integer;
begin
  for I := 0 to Headers.Count - 1 do
  begin
    if Pos('Authorization:', Headers[I]) = 1 then
    begin
      Headers.Delete(I);
      Exit;
    end;
  end;
end;

initialization
  FAIEngines := TClassList.Create;

finalization
  FAIEngineManager.Free;
  FAIEngines.Free;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
