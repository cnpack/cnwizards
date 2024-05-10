unit AICoderUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnThreadPool, CnInetUtils, CnNative, CnContainers, CnJSON,
  CnAICoderConfig, CnAICoderEngine, CnWideStrings;

type
  TFormAITest = class(TForm)
    dlgSave1: TSaveDialog;
    dlgOpen1: TOpenDialog;
    pgcAICoder: TPageControl;
    tsHTTP: TTabSheet;
    mmoHTTP: TMemo;
    btnAddHttps: TButton;
    tsAIConfig: TTabSheet;
    btnAIConfigSave: TButton;
    btnAIConfigLoad: TButton;
    mmoConfig: TMemo;
    tsEngine: TTabSheet;
    btnLoadAIConfig: TButton;
    lblAIName: TLabel;
    cbbAIEngines: TComboBox;
    btnSaveAIConfig: TButton;
    btnExplainCode: TButton;
    mmoAI: TMemo;
    lblProxy: TLabel;
    edtProxy: TEdit;
    lblTestProxy: TLabel;
    edtTestProxy: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddHttpsClick(Sender: TObject);
    procedure btnAIConfigSaveClick(Sender: TObject);
    procedure btnAIConfigLoadClick(Sender: TObject);
    procedure btnLoadAIConfigClick(Sender: TObject);
    procedure cbbAIEnginesChange(Sender: TObject);
    procedure btnSaveAIConfigClick(Sender: TObject);
    procedure btnExplainCodeClick(Sender: TObject);
  private
    FNetPool: TCnThreadPool;
    FResQueue: TCnObjectQueue;
    FAIConfig: TCnAIEngineOptionManager;

    // 以下是综合测试
    procedure AIOnExplainCodeAnswer(Success: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal);
  protected
    procedure ShowData;
  public
    procedure ProcessRequest(Sender: TCnThreadPool;
      DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
    procedure MyResponse(Success: Boolean; Thread: TCnPoolingThread;
      SendId: Integer; Data: TBytes);
  end;

  TSendThread = class(TCnPoolingThread)
  private
    FData: TBytes;
    FSendId: Integer;
  public
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
  end;

  TSendDataResponse = procedure(Success: Boolean; Thread: TCnPoolingThread;
    SendId: Integer; Data: TBytes) of object;
  {* 网络请求的回调，告诉成功与否，成功则 Data 中是数据}

  TSendDataObject = class(TCnTaskDataObject)
  {* 代表网络请求的任务类，由发起者根据网络请求参数创建，并扔给线程池
    有结果时线程会回调 OnResponse 事件}
  private
    FURL: string;
    FSendId: Integer;
    FOnResponse: TSendDataResponse;
  public
    function Clone: TCnTaskDataObject; override;

    property SendId: Integer read FSendId write FSendId;
    property URL: string read FURL write FURL;

    property OnResponse: TSendDataResponse read FOnResponse write FOnResponse;
    {* 收到网络数据时的回调事件，注意是在子线程中被调用的，处理时如需 Synchronize 到主线程则需及时保存数据}
  end;

  TResponseDataObject = class(TObject)
  {* 网络回调结果的封装，用于递给主线程供处理}
  private
    FSendId: Integer;
    FData: TBytes;
    FSuccess: Boolean;
    FErrorCode: Cardinal;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property SendId: Integer read FSendId write FSendId;
    property Data: TBytes read FData write FData;
    property ErrorCode: Cardinal read FErrorCode write FErrorCode;
  end;

var
  FormAITest: TFormAITest;

implementation

{$R *.DFM}

uses
  CnDebug;

const
  DBG_TAG = 'NET';

procedure TFormAITest.FormCreate(Sender: TObject);
begin
  FNetPool := TCnThreadPool.CreateSpecial(nil, TSendThread);

  FNetPool.OnProcessRequest := ProcessRequest;
  FNetPool.AdjustInterval := 5 * 1000;
  FNetPool.MinAtLeast := False;
  FNetPool.ThreadDeadTimeout := 10 * 1000;
  FNetPool.ThreadsMinCount := 0;
  FNetPool.ThreadsMaxCount := 5;
  FNetPool.TerminateWaitTime := 2 * 1000;
  FNetPool.ForceTerminate := True; // 允许强制结束

  FResQueue := TCnObjectQueue.Create(True);

  FAIConfig := TCnAIEngineOptionManager.Create;
end;

procedure TFormAITest.FormDestroy(Sender: TObject);
begin
  FAIConfig.Free;

  FNetPool.Free;

  while not FResQueue.IsEmpty do
    FResQueue.Pop.Free;

  FResQueue.Free;
end;

type
  TThreadHack = class(TThread);

procedure TFormAITest.ProcessRequest(Sender: TCnThreadPool;
  DataObj: TCnTaskDataObject; Thread: TCnPoolingThread);
var
  HTTP: TCnHTTP;
  Stream: TMemoryStream;
begin
  HTTP := TCnHTTP.Create;
  if Trim(edtTestProxy.Text) <> '' then
  begin
    HTTP.ProxyMode := pmProxy;
    HTTP.ProxyServer := edtTestProxy.Text;
  end;

  Stream := TMemoryStream.Create;

  try
    CnDebugger.LogMsgWithTag('*** HTTP To Request.', DBG_TAG);
    Sleep(2000 + Random(5000));
    if HTTP.GetStream(TSendDataObject(DataObj).URL, Stream) then
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size), DBG_TAG);

      // 这里要把结果送给 UI 供处理，结果不能依赖于本线程，因为 UI 主线程的调用处理结果的时刻是不确定的，
      // 而离了本方法，Thread 的状态就未知了，搁 Thread 里的内容可能会因 Thread 被池子调度而被冲掉
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(True, Thread, TSendDataObject(DataObj).SendId, StreamToBytes(Stream));
    end
    else
    begin
      CnDebugger.LogMsgWithTag('*** HTTP Request Fail.', DBG_TAG);
      if Assigned(TSendDataObject(DataObj).OnResponse) then
        TSendDataObject(DataObj).OnResponse(False, Thread, TSendDataObject(DataObj).SendId, nil);
    end;
  finally
    Stream.Free;
    HTTP.Free;
  end;
end;

procedure TFormAITest.btnAddHttpsClick(Sender: TObject);
const
  A_URL = 'http://www.baidu.com/s?wd=CnPack';
var
  I: Integer;
  Obj: TSendDataObject;
begin
  // mmoHTTP.Lines.Clear;
  CnDebugger.LogMsgWithTag('*** Button Click.', DBG_TAG);
  for I := 1 to 20 do
  begin
    Obj := TSendDataObject.Create;
    Obj.URL := A_URL;
    Obj.SendId := 1000 + Random(10000);
    Obj.OnResponse := MyResponse;

    FNetPool.AddRequest(Obj);
  end;
end;

{ TSendDataObject }

function TSendDataObject.Clone: TCnTaskDataObject;
begin
  Result := TSendDataObject.Create;
  TSendDataObject(Result).URL := FURL;
  TSendDataObject(Result).SendId := FSendId;
  TSendDataObject(Result).OnResponse := FOnResponse;
end;

{ TSendThread }

procedure TFormAITest.MyResponse(Success: Boolean; Thread: TCnPoolingThread;
  SendId: Integer; Data: TBytes);
var
  Res: TResponseDataObject;
begin
  // 该事件是在子线程中调用的。
  // 如需 Synchronize 去主线程，则需保存 SendId 及 Data 后扔过去
  // 这个保存估计得用队列，这边入，主线程取
  if Success and (Length(Data) > 0) then
  begin
    Res := TResponseDataObject.Create;
    Res.Success := True;
    Res.SendId := SendId;
    Res.Data := Data;
    Res.ErrorCode := 0;

    FResQueue.Push(Res);
    TThreadHack(Thread).Synchronize(ShowData);
  end
  else
  begin
    Res := TResponseDataObject.Create;
    Res.Success := False;
    Res.SendId := SendId;
    Res.Data := Data;
    Res.ErrorCode := GetLastError;

    FResQueue.Push(Res);
    TThreadHack(Thread).Synchronize(ShowData);
  end;
end;

procedure TFormAITest.ShowData;
var
  Obj: TResponseDataObject;
begin
  Obj := TResponseDataObject(FResQueue.Pop);
  if Obj <> nil then
  begin
    if Obj.Success then
      FormAITest.mmoHTTP.Lines.Add(Format('Get Bytes %d from SendId %d', [Length(Obj.Data), Obj.SendId]))
    else
      FormAITest.mmoHTTP.Lines.Add(Format('Get Failed from SendId %d. Error Code %d', [Obj.SendId, Obj.ErrorCode]));
    Obj.Free;
  end;
end;

procedure TFormAITest.btnAIConfigSaveClick(Sender: TObject);
var
  Option: TCnAIEngineOption;
begin
  FAIConfig.Clear;

  Option := TCnAIEngineOption.Create;
  Option.EngineName := 'Moonshot';
  Option.Model := 'moonshot-v1-8k';
  Option.URL := 'https://api.moonshot.cn/v1/chat/completions';
  Option.ApiKey := 'sk-*****************';
  Option.WebAddress := 'https://platform.moonshot.cn/console';
  // Option.SystemMessage := '你是一名 Delphi 专家';
  Option.Temperature := 0.3;
  // Option.ExplainCodePrompt := '请解释以下代码：';

  FAIConfig.AddOption(Option);

  Option := TCnAIEngineOption.Create;
  Option.EngineName := '挨饿的引擎';
  Option.Model := 'cnpack-noai-9.8';
  Option.URL := 'https://upgrade.cnpack.org/';
  Option.ApiKey := '{ACED92D0-6D09-4B88-BEA7-B963A8301CA4}';
  // Option.SystemMessage := '你是一名 C++Builder 专家';
  Option.Temperature := 0.3;
  // Option.ExplainCodePrompt := '请解释以下代码：';

  FAIConfig.AddOption(Option);
  FAIConfig.ActiveEngine := 'Moonshot';

  dlgSave1.FileName := 'AIConfig.json';
  if dlgSave1.Execute then
    FAIConfig.SaveToFile(dlgSave1.FileName);
end;

procedure TFormAITest.btnAIConfigLoadClick(Sender: TObject);
begin
  dlgOpen1.FileName := 'AIConfig.json';
  if dlgOpen1.Execute then
  begin
    FAIConfig.LoadFromFile(dlgOpen1.FileName);
    mmoConfig.Lines.Clear;
    mmoConfig.Lines.Add(FAIConfig.SaveToJSON);
  end;
end;

procedure TFormAITest.btnLoadAIConfigClick(Sender: TObject);
var
  I: Integer;
begin
  if dlgOpen1.Execute then
  begin
    CnAIEngineOptionManager.LoadFromFile(dlgOpen1.FileName);
    cbbAIEngines.Items.Clear;
    for I := 0 to CnAIEngineManager.EngineCount - 1 do
      cbbAIEngines.Items.Add(CnAIEngineManager.Engines[I].EngineName);

    CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
    cbbAIEngines.ItemIndex := CnAIEngineManager.CurrentIndex;

    edtProxy.Text := CnAIEngineOptionManager.ProxyServer;
  end;
end;

procedure TFormAITest.cbbAIEnginesChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbAIEngines.Text;
  CnAIEngineManager.CurrentEngineName := cbbAIEngines.Text;
end;

procedure TFormAITest.btnSaveAIConfigClick(Sender: TObject);
begin
 dlgSave1.FileName := 'AIConfig.json';
  if dlgSave1.Execute then
    CnAIEngineOptionManager.SaveToFile(dlgSave1.FileName);
end;

procedure TFormAITest.btnExplainCodeClick(Sender: TObject);
begin
  CnAIEngineManager.CurrentEngine.AskAIEngineExplainCode('Application.CreateForm(TForm1, Form1);',
    AIOnExplainCodeAnswer);
end;

procedure TFormAITest.AIOnExplainCodeAnswer(Success: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal);
begin
  if Success then
    mmoAI.Lines.Add(Format('Explain Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Explain Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));
end;

end.
