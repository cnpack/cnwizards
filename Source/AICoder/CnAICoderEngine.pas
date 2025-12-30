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
  CnInetUtils, CnWizOptions, CnAICoderConfig, CnThreadPool, CnAICoderNetClient,
  CnHashMap, CnConsts;

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
    FIsStreamEnd: Boolean;
  public
    property StreamMode: Boolean read FStreamMode write FStreamMode;
    property Partly: Boolean read FPartly write FPartly;

    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property IsStreamEnd: Boolean read FIsStreamEnd write FIsStreamEnd;
    property RequestType: TCnAIRequestType read FRequestType write FRequestType;
    property ErrorCode: Cardinal read FErrorCode write FErrorCode;
    property Answer: TBytes read FAnswer write FAnswer;
    property Tag: TObject read FTag write FTag;
    property Callback: TCnAIAnswerCallback read FCallback write FCallback;
  end;

  TCnAIBaseEngine = class
  {* 处理特定 AI 服务提供者的引擎基类，有自身的特定配置，并有添加请求任务、
     发起网络请求、获得结果并回调的典型功能。其中组装发送格式及接收数据解析格式
     参照了目前最为广泛的 OpenAI 兼容格式为实现规则，子类则可能另有实现}
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
    FPrevRespRemainMap: TCnStrToStrHashMap;

    procedure DeleteAuthorizationHeader(Headers: TStringList);
    {* 供子类按需使用的，删除请求头里的 Authorization 字段，以备其他认证方式}

    procedure TalkToEngine(Sender: TCnThreadPool; DataObj: TCnTaskDataObject;
      Thread: TCnPoolingThread); virtual;
    {* 有默认实现且子类可重载的、与 AI 服务提供者进行网络通讯获取结果的实现函数
      是第一步组装好数据扔给线程池后，由线程池调度后在具体工作线程中被调用
      在一次完整的 AI 网络通讯过程中属于第三步，内部会根据结果回调 OnAINetDataResponse 事件}

    procedure OnAINetDataResponse(Success, Partly: Boolean; Thread: TCnPoolingThread;
      DataObj: TCnAINetRequestDataObject; Data: TBytes; ErrCode: Cardinal); virtual;
    {* AI 服务提供者进行网络通讯的结果回调，是在子线程中被调用的，内部应 Sync 给请求调用者
      Success 返回成功与否，成功则 Data 中是数据
      在一次完整的 AI 网络通讯过程中属于第四步}

    procedure SyncCallback;
    {* 被上述第四步通过 Synchronize 的方式调用，之前已将应答对象推入 FAnswerQueue 队列
      在一次完整的 AI 网络通讯过程中属于第五步}

    // 以下四过程，子类看接口情况重载
    function GetRequestURL(DataObj: TCnAINetRequestDataObject): string; virtual;
    {* 请求发送前，给子类一个处理自定义 URL  的机会}

    procedure PrepareRequestHeader(const ApiKey: string; Headers: TStringList); virtual;
    {* 请求发送前，给子类一个处理自定义 HTTP 头的机会。ApiKey 是发起请求时指定的，
      有可能特殊场合和 FOptions 里的 ApiKey 不同，优先以此为准。}

    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string = '';
      History: TStrings = nil): TBytes; virtual;
    {* 根据请求类型与原始代码及历史信息，组装 Post 的数据，一般是 JSON 格式}

    function ParseResponse(SendId: Integer; StreamMode, Partly: Boolean; var Success: Boolean;
      var ErrorCode: Cardinal; var IsStreamEnd: Boolean; RequestType: TCnAIRequestType; const Response: TBytes): string; virtual;
    {* 根据请求类型与原始回应，解析回应数据，一般是 JSON 格式，返回字符串给调用者，
      同时允许根据返回的错误信息更改成功与否。SendId 是发送时产生的随机标识符用来区分会话，
      StreamMode 是请求发起时是否支持流式，姑且认为服务端会同样多次返回拼接。
      Partly 为 True 表示此次数据是服务器返回的中间数据，注意数据过短时可能等于完整数据。
      内部机制确保了不会在 StreamMode 为 False 时来 Partly 为 True 的数据，不会在 StreamMode 为 True 时来完整数据
      IsStreamEnd 由内部解析后返回流模式下本次回应是否是结尾数据}

    function ParseModelList(ResponseRoot: TCnJSONObject): string; virtual;
    {* 单独挑出 ModelList 的应答解析过程，子类按需重载，如引擎不支持，直接返回空字符串即可}

    class function GetModelListURL(const OrigURL: string): string; virtual;
    {* 从 API 调用地址获取 ModelList 调用地址，不同提供商可能有不同规则。
      如引擎不支持，直接返回空字符串即可}
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

    function AskAIEngine(const URL: string; const Text: TBytes; StreamMode: Boolean;
      RequestType: TCnAIRequestType; const ApiKey: string; Tag: TObject;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 用户调用的与 AI 通讯的过程，传入原始通讯数据，内部会组装成请求对象扔给线程池，返回一个请求 ID
      在一次完整的 AI 网络通讯过程中属于第一步；第二步是线程池调度的 ProcessRequest 转发}

    function AskAIEngineForCode(const Code: string; History: TStrings; Tag: TObject;
      RequestType: TCnAIRequestType; AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 进一步封装的用户调用的解释代码或检查代码的过程，内部将 Code 转换为 JSON 后调用 AskAIEngine，也算第一步}

    function AskAIEngineForModelList(Tag: TObject; AlterOption: TCnAIEngineOption = nil;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 进一步封装的设置界面由用户调用的获取模型列表的过程，内部组装调整后调用 AskAIEngine，也算第一步
       加一 AlterOption 参数的目的是为了允许临时指定参数，不用本 Engine 默认参数以适合灵活场合}

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

    procedure LoadFromWizOptions;
    {* 专家包中运行时的加载总入口，动态加载所有配置，内部会分辨不同目录}
    procedure SaveToWizOptions;
    {* 专家包中运行时的保存总入口，动态保存所有配置到用户目录}
    procedure ResetWizOptions;
    {* 该专家的重置入口}

    property CurrentEngineName: string read GetCurrentEngineName write SetCurrentEngineName;
    {* 获得及设置当前引擎名称，前者从当前引擎中取，后者会切换引擎。
       注意在 FPC 下，该字符串编码是 Utf8}
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

uses
  CnCommon {$IFDEF DEBUG}, CnDebug{$ENDIF};

const
  CRLF = #13#10;
  LF = #10;
  RESP_DATA_DONE = 'data: [DONE]';

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

  // 加载收藏的词儿
  S := WizOptions.GetUserFileName(SCnAICoderFavoritesFile, True);
  if FileExists(S) then
  begin
    CnAIEngineOptionManager.LoadFavorite(S);
    CnAIEngineOptionManager.ShrinkFavorite;
  end;

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
  // OptionManager 保存基本设置
  F := Format(SCnAICoderEngineOptionFileFmt, ['']);
  S := WizOptions.GetUserFileName(F, False);
  CnAIEngineOptionManager.SaveToFile(S);
  WizOptions.CheckUserFile(F);

  // 保存收藏的词儿
  S := WizOptions.GetUserFileName(SCnAICoderFavoritesFile, False);
  CnAIEngineOptionManager.ShrinkFavorite;
  CnAIEngineOptionManager.SaveFavorite(S);

  // 挨个根据引擎 ID，修改文件名，保存其对应 Option
  for I := 0 to EngineCount - 1 do
  begin
    F := Format(SCnAICoderEngineOptionFileFmt, [Engines[I].EngineID]);
    S := WizOptions.GetUserFileName(F, False);
    CnAIEngineOptionManager.SaveOptionToFile(Engines[I].EngineName, S);
    WizOptions.CheckUserFile(F);
  end;
end;

procedure TCnAIEngineManager.ResetWizOptions;
var
  I: Integer;
  F: string;
begin
  WizOptions.CleanUserFile(Format(SCnAICoderEngineOptionFileFmt, ['']));
  WizOptions.CleanUserFile(SCnAICoderFavoritesFile);

  for I := 0 to EngineCount - 1 do
  begin
    F := Format(SCnAICoderEngineOptionFileFmt, [Engines[I].EngineID]);
    WizOptions.CleanUserFile(F);
  end;
end;

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

function TCnAIBaseEngine.AskAIEngine(const URL: string; const Text: TBytes;
  StreamMode: Boolean; RequestType: TCnAIRequestType; const ApiKey: string;
  Tag: TObject; AnswerCallback: TCnAIAnswerCallback): Integer;
var
  Obj: TCnAINetRequestDataObject;
begin
  CheckOptionPool;

  Obj := TCnAINetRequestDataObject.Create;
  Obj.URL := URL;
  Obj.Tag := Tag;
  Obj.RequestType := RequestType;
  Obj.ApiKey := ApiKey;
  Randomize;
  Obj.SendId := 10000000 + Random(100000000);

  // 拼装 JSON 格式的请求作为 Post 的负载内容搁 Data 里
  Obj.Data := Text;
  Obj.StreamMode := StreamMode;

  Obj.OnAnswer := AnswerCallback;
  Obj.OnResponse := OnAINetDataResponse;
  FPoolRef.AddRequest(Obj);

  Result := Obj.SendId;
end;

function TCnAIBaseEngine.AskAIEngineForCode(const Code: string; History: TStrings;
  Tag: TObject; RequestType: TCnAIRequestType; AnswerCallback: TCnAIAnswerCallback): Integer;
begin
  Result := AskAIEngine(FOption.URL, ConstructRequest(RequestType, Code, History),
    FOption.Stream, RequestType, FOption.ApiKey, Tag, AnswerCallback);
end;

function TCnAIBaseEngine.AskAIEngineForModelList(Tag: TObject;
  AlterOption: TCnAIEngineOption; AnswerCallback: TCnAIAnswerCallback): Integer;
var
  URL: string;
begin
  if AlterOption = nil then
    AlterOption := FOption;

  URL := GetModelListURL(AlterOption.URL);
  if Trim(URL) = '' then
  begin
    if Assigned(AnswerCallback) then
      AnswerCallback(False, False, False, True, 0, SCnNotSupport, 0, nil);
    Result := 0;
    Exit;
  end;

  Result := AskAIEngine(URL, ConstructRequest(artModelList),
    AlterOption.Stream, artModelList, AlterOption.ApiKey, Tag, AnswerCallback);
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
          NewBytesFromMemory(Data, DataLen), 0);
      end;
    end;
  end;
end;

function TCnAIBaseEngine.ConstructRequest(RequestType: TCnAIRequestType;
  const Code: string; History: TStrings): TBytes;
var
  ReqRoot, Msg: TCnJSONObject;
  Arr: TCnJSONArray;
  S: AnsiString;
  I: Integer;
begin
  ReqRoot := TCnJSONObject.Create;
  try
    if RequestType = artModelList then
    begin
      // 组装模型列表请求，默认内容为空，也就是无需额外参数
      Result := nil;
    end
    else
    begin
      ReqRoot.AddPair('model', FOption.Model);
      ReqRoot.AddPair('temperature', FOption.Temperature);
      ReqRoot.AddPair('stream', FOption.Stream);
      Arr := ReqRoot.AddArray('messages');

      Msg := TCnJSONObject.Create;
      Msg.AddPair('role', 'system');
      Msg.AddPair('content', FOption.SystemMessage);
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
        Msg.AddPair('content', FOption.ExplainCodePrompt + #13#10 + Code)
      else if RequestType = artReviewCode then
        Msg.AddPair('content', FOption.ReviewCodePrompt + #13#10 + Code)
      else if RequestType = artGenTestCase then
        Msg.AddPair('content', FOption.GenTestCasePrompt + #13#10 + Code)
      else if RequestType = artContinueCoding then
        Msg.AddPair('content', FOption.ContinueCodingPrompt + #13#10 + Code)
      else if RequestType = artRaw then
        Msg.AddPair('content', Code);

      Arr.AddValue(Msg);

      S := ReqRoot.ToJSON;
      Result := AnsiToBytes(S);
    end;
  finally
    ReqRoot.Free;
  end;
end;

function TCnAIBaseEngine.ParseResponse(SendId: Integer; StreamMode, Partly: Boolean;
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
    // 流模式下如果本次返回单独的 datadone，那么上面拼好再解析后 RespRoot 必然是 nil，
    // 只要判断本次数据是否只剩下结束符，是则结束并返回结束标志，无内容返回
    if Partly and (Trim(S) = RESP_DATA_DONE) then
    begin
      IsStreamEnd := True;
      FPrevRespRemainMap.Delete(IntToStr(SendId)); // 清理缓存
      Exit;
    end;

    // 其他情况可能是一类原始错误，如账号达到最大并发等
    Result := S;
  end
  else
  begin
    try
      if RequestType = artModelList then
      begin
        Result := ParseModelList(RespRoot);
        // 注意会跳过最后的回车换行处理因为不需要
        if Result <> '' then
          Exit;
      end;

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
              if (Msg['content'] <> nil) and (Msg['content'].AsString <> '') then
                Result := Result + Msg['content'].AsString
              else if Msg['reasoning_content'] <> nil then // 也可能是内容空，先来推理数据
                Result := Result + Msg['reasoning_content'].AsString;
              HasPartly := True;
            end;
          end;
        end;

        // 多个回应完成后，剩下的 Prev 可能是 datadone 结束符，判断并返回此标志
        if Trim(Prev) = RESP_DATA_DONE then
        begin
          IsStreamEnd := True;
          FPrevRespRemainMap.Delete(IntToStr(SendId)); // 也清理缓存
          Exit; // 无数据返回，因而可以直接 Exit
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
            if (Msg['content'] <> nil) and (Msg['content'].AsString <> '') then
              Result := Msg['content'].AsString
            else if Msg['reasoning_content'] <> nil then // 也可能是先来推理数据
              Result := Result + Msg['reasoning_content'].AsString;
          end;
        end;
      end;

      if not HasPartly and (Result = '') then
      begin
        // 整块模式下，只要没有正常回应，就说明出错了
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

function TCnAIBaseEngine.ParseModelList(ResponseRoot: TCnJSONObject): string;
const
  MODEL = 'models/';
var
  I: Integer;
  Arr: TCnJSONArray;
  S: string;
begin
  // 从 RespRoot 中解析出模型列表，拼成逗号分隔的字符串并直接返回，
  if (ResponseRoot['data'] <> nil) and (ResponseRoot['data'] is TCnJSONArray) then
  begin
    Arr := TCnJSONArray(ResponseRoot['data']);
    if Arr.Count > 0 then
    begin
      for I := 0 to Arr.Count - 1 do
      begin
        if (Arr[I]['id'] <> nil) and (Arr[I]['id'] is TCnJSONString) then
        begin
          S := Arr[I]['id'].AsString;
          if Pos(MODEL, S) = 1 then   // 有些引擎会在前面加个前缀，删掉
            Delete(S, 1, Length(MODEL));

          if I = 0 then
            Result := S
          else
            Result := Result + ',' + S;
        end;
      end;
    end;
  end;
end;

constructor TCnAIBaseEngine.Create(ANetPool: TCnThreadPool);
begin
  inherited Create;
  FPoolRef := ANetPool;

  FAnswerQueue := TCnObjectQueue.Create(True);
  FPrevRespRemainMap := TCnStrToStrHashMap.Create;
  InitOption;
end;

destructor TCnAIBaseEngine.Destroy;
begin
  while not FAnswerQueue.IsEmpty do
    FAnswerQueue.Pop.Free;

  FPrevRespRemainMap.Free;
  FAnswerQueue.Free;
  inherited;
end;

procedure TCnAIBaseEngine.InitOption;
begin
  FOption := CnAIEngineOptionManager.GetOptionByEngine(EngineName)
end;

procedure TCnAIBaseEngine.OnAINetDataResponse(Success, Partly: Boolean; Thread: TCnPoolingThread;
  DataObj: TCnAINetRequestDataObject; Data: TBytes; ErrCode: Cardinal);
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
  if not Success then
  begin
    AnswerObj.ErrorCode := ErrCode;
    // 典型的错误码中，12002 是超时，12029 是无法建立连接可能是 SSL 版本错等
  end;

  AnswerObj.StreamMode := TCnAINetRequestDataObject(DataObj).StreamMode;
  AnswerObj.Partly := Partly;

  AnswerObj.Success := Success;
  AnswerObj.SendId := TCnAINetRequestDataObject(DataObj).SendId;
  AnswerObj.IsStreamEnd := False; // 仅流模式下有效，让解析器确定本次是否结束数据
  AnswerObj.RequestType := TCnAINetRequestDataObject(DataObj).RequestType;
  AnswerObj.Callback := TCnAINetRequestDataObject(DataObj).OnAnswer;
  AnswerObj.Tag := TCnAINetRequestDataObject(DataObj).Tag;
  AnswerObj.Answer := Data; // 引用，但有计数，不会随便释放

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
      Answer := ParseResponse(AnswerObj.SendId, AnswerObj.StreamMode, AnswerObj.Partly,
        AnswerObj.FSuccess, AnswerObj.FErrorCode, AnswerObj.FIsStreamEnd,
        AnswerObj.RequestType, AnswerObj.Answer);

      AnswerObj.Callback(AnswerObj.StreamMode, AnswerObj.Partly, AnswerObj.Success,
        AnswerObj.IsStreamEnd, AnswerObj.SendId, Answer, AnswerObj.ErrorCode, AnswerObj.Tag);
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
  Err: DWORD;
begin
  HTTP := nil;
  Stream := nil;
  Err := 0;

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

    if TCnAINetRequestDataObject(DataObj).ApiKey <> '' then
      HTTP.HttpRequestHeaders.Add('Authorization: Bearer ' + TCnAINetRequestDataObject(DataObj).ApiKey);
    // 大多数 AI 引擎的身份验证都是这句。少数不是的，可以在子类的 PrepareRequestHeader 里删掉这句再加

    PrepareRequestHeader(TCnAINetRequestDataObject(DataObj).ApiKey, HTTP.HttpRequestHeaders);

    Stream := TMemoryStream.Create;
    AURL := GetRequestURL(TCnAINetRequestDataObject(DataObj));

    // 临时记录 DataObj 的引用，因为 GetStream 过程中有回调需要使用
    FProcessingDataObj := TCnAINetRequestDataObject(DataObj);
    FProcessingThread := Thread;
    if HTTP.GetStream(AURL, Stream, TCnAINetRequestDataObject(DataObj).Data, @Err) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size));
{$ENDIF}

      // 这里要把结果送给 UI 供处理，结果不能依赖于本线程，因为 UI 主线程的调用处理结果的时刻是不确定的，
      // 而离了本方法，Thread 的状态就未知了，搁 Thread 里的内容可能会因 Thread 被池子调度而被冲掉
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(Stream.Size > 0, False, Thread,
          TCnAINetRequestDataObject(DataObj), StreamToBytes(Stream), Err);
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request Fail: ' + IntToStr(Err));
{$ENDIF}
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(False, False, Thread,
          TCnAINetRequestDataObject(DataObj), nil, Err);
    end;
  finally
    FProcessingThread := nil;
    FProcessingDataObj := nil;
    Stream.Free;
    HTTP.Free;
  end;
end;

procedure TCnAIBaseEngine.PrepareRequestHeader(const ApiKey: string; Headers: TStringList);
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

class function TCnAIBaseEngine.GetModelListURL(const OrigURL: string): string;
const
  CHAT_COMP = 'chat/completions';
  MODEL = 'models';
begin
  // 采取古怪规则拼接 ModelList 的 URL，可能子类有更多办法
  Result := OrigURL;
  if StrEndWith(Result, CHAT_COMP) then
  begin
    Delete(Result, Pos(CHAT_COMP, Result), MaxInt);
    Result := Result + MODEL;
  end;
end;

initialization
  FAIEngines := TClassList.Create;

finalization
  FAIEngineManager.Free;
  FAIEngines.Free;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
