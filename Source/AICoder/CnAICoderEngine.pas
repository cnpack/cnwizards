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

unit CnAICoderEngine;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的引擎管理单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10/11 + Delphi/C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, Windows, CnContainers,
  CnNative, CnInetUtils, CnAICoderConfig, CnThreadPool, CnAICoderNetClient;

type
  TCnAIAnswerObject = class(TPersistent)
  {* 封装的 AI 应答结果}
  private
    FSendId: Integer;
    FAnswer: TBytes;
    FSuccess: Boolean;
    FCallback: TCnAIAnswerCallback;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property Answer: TBytes read FAnswer write FAnswer;
    property Callback: TCnAIAnswerCallback read FCallback write FCallback;
  end;

  TCnAIBaseEngine = class
  {* 处理特定 AI 服务提供者的引擎基类，有自身的特定配置，
   并有添加请求任务、发起网络请求、获得结果并回调的典型功能}
  private
    FPoolRef: TCnThreadPool; // 从 Manager 处拿来持有的线程池对象引用
    FOption: TCnAIEngineOption;
    FAnswerQueue: TCnObjectQueue;
    procedure CheckOptionPool;
  protected
    class function EngineName: string; virtual; abstract;
    {* 子类必须有个名字}

    procedure TalkToEngine(Sender: TCnThreadPool; DataObj: TCnTaskDataObject;
      Thread: TCnPoolingThread); virtual;
    {* 有默认实现且子类可重载的、与 AI 服务提供者进行网络通讯获取结果的实现函数
      是第一步组装好数据扔给线程池后，由线程池调度后在具体工作线程中被调用
      在一次完整的 AI 网络通讯过程中属于第三步，内部会根据结果回调 OnAINetDataResponse 事件}
    procedure OnAINetDataResponse(Success: Boolean; Thread: TCnPoolingThread;
      DataObj: TCnAINetRequestDataObject; Data: TBytes); virtual;
    {* AI 服务提供者进行网络通讯的结果回调，是在子线程中被调用的，内部应 Sync 给请求调用者
      Success 返回成功与否，成功则 Data 中是数据
      在一次完整的 AI 网络通讯过程中属于第四步}
    procedure SyncCallback;
    {* 被上述第四步通过 Synchronize 的方式调用，之前已将应答对象推入 FAnswerQueue 队列
      在一次完整的 AI 网络通讯过程中属于第五步}
  public
    constructor Create(ANetPool: TCnThreadPool); virtual;
    destructor Destroy; override;

    procedure InitOption;
    {* 根据引擎名去设置管理类中取自身的设置对象}

    function AskAIEngineExplainCode(const Code: string;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* 用户调用的解释代码过程，内部会封装请求数据组装成请求对象扔给线程池，返回一个请求 ID
      在一次完整的 AI 网络通讯过程中属于第一步；第二步是线程池调度的 ProcessRequest 转发}

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
  protected
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
  public
    constructor Create; virtual;
    {* 构造函数，传入外部的网络线程池引用，供分配给 AI 引擎使用}
    destructor Destroy; override;

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

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

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

function TCnAIEngineManager.GetCurrentEngine: TCnAIBaseEngine;
begin
  if (FCurrentIndex >= 0) and (FCurrentIndex < FEngines.Count) then
    Result := TCnAIBaseEngine(FEngines[FCurrentIndex])
  else
    raise Exception.Create('NO Engine Selected.');
end;

function TCnAIEngineManager.GetEnginCount: Integer;
begin
  Result := FEngines.Count;
end;

function TCnAIEngineManager.GetEngine(Index: Integer): TCnAIBaseEngine;
begin
  Result := TCnAIBaseEngine(FEngines[Index]);
end;

procedure TCnAIEngineManager.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
begin
  CurrentEngine.TalkToEngine(Sender, DataObj, Thread);
end;

procedure TCnAIEngineManager.SetCurrentIndex(const Value: Integer);
begin
  if FCurrentIndex <> Value then
  begin
    FCurrentIndex := Value;
    // 记录引擎改变了
  end;
end;

{ TCnAIBaseEngine }

function TCnAIBaseEngine.AskAIEngineExplainCode(const Code: string;
  AnswerCallback: TCnAIAnswerCallback): Integer;
var
  Obj: TCnAINetRequestDataObject;
begin
  CheckOptionPool;
  Result := 0;

  if Code <> '' then
  begin
    Obj := TCnAINetRequestDataObject.Create;
    Obj.URL := FOption.URL;
    Obj.SendId := 10000000 + Random(100000000);
    Obj.Engine := EngineName;

    // TODO: 拼装 JSON 格式的请求作为 Post 的负载内容搁 Data 里

    Obj.OnAnswer := AnswerCallback;
    Obj.OnResponse := OnAINetDataResponse;
    FPoolRef.AddRequest(Obj);
    Result := Obj.SendId;
  end;
end;

procedure TCnAIBaseEngine.CheckOptionPool;
begin
  // 检查 Pool、Option 等内容是否合法
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

procedure TCnAIBaseEngine.OnAINetDataResponse(Success: Boolean;
  Thread: TCnPoolingThread; DataObj: TCnAINetRequestDataObject; Data: TBytes);
var
  AnswerObj: TCnAIAnswerObject;
begin
  // 网络线程里拿到数据或结果后本事件被直接调用，适当包装后 Synchronize 返回给宿主
  if (DataObj <> nil) and Assigned(TCnAINetRequestDataObject(DataObj).OnAnswer) then
    TCnAINetRequestDataObject(DataObj).OnAnswer(Success, TCnAINetRequestDataObject(DataObj).SendId, Data);

  AnswerObj := TCnAIAnswerObject.Create;
  AnswerObj.Success := Success;
  AnswerObj.SendId := TCnAINetRequestDataObject(DataObj).SendId;
  AnswerObj.Answer := Data; // 引用但有计数，不会随便释放

  FAnswerQueue.Push(AnswerObj);
  TThreadHack(Thread).Synchronize(SyncCallback);
end;

procedure TCnAIBaseEngine.SyncCallback;
var
  AnswerObj: TCnAIAnswerObject;
begin
  AnswerObj := TCnAIAnswerObject(FAnswerQueue.Pop);
  if AnswerObj <> nil then
  begin
    if Assigned(AnswerObj.Callback) then
      AnswerObj.Callback(AnswerObj.Success, AnswerObj.SendId, AnswerObj.Answer);
    AnswerObj.Free;
  end;
end;

procedure TCnAIBaseEngine.TalkToEngine(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
begin
  HTTP := nil;
  Stream := nil;

  try
    HTTP := TCnHTTP.Create;
    Stream := TMemoryStream.Create;

    if HTTP.GetStream(TCnAINetRequestDataObject(DataObj).URL, Stream) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size));
{$ENDIF}

      // 这里要把结果送给 UI 供处理，结果不能依赖于本线程，因为 UI 主线程的调用处理结果的时刻是不确定的，
      // 而离了本方法，Thread 的状态就未知了，搁 Thread 里的内容可能会因 Thread 被池子调度而被冲掉
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(True, Thread, TCnAINetRequestDataObject(DataObj), StreamToBytes(Stream));
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request Fail. ' + IntToStr(GetLastError));
{$ENDIF}
      if Assigned(TCnAINetRequestDataObject(DataObj).OnResponse) then
        TCnAINetRequestDataObject(DataObj).OnResponse(False, Thread, TCnAINetRequestDataObject(DataObj), nil);
    end;
  finally
    Stream.Free;
    HTTP.Free;
  end;
end;

initialization
  FAIEngines := TClassList.Create;

finalization
  FAIEngineManager.Free;
  FAIEngines.Free;

end.
