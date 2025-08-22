{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAICoderEngine;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ��������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���� API �����ͨѶʱ�緵�ش����� 12022 һ�������ӳ�ʱ
*           12029 һ���� SSL �汾���͵����޷���������
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin7/10/11 + Delphi/C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.01 V1.0
*               ������Ԫ
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
  {* ��װ�� AI Ӧ����}
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
  {* �����ض� AI �����ṩ�ߵ�������࣬��������ض����ã����������������
     �����������󡢻�ý�����ص��ĵ��͹��ܡ�������װ���͸�ʽ���������ݽ�����ʽ
     ������Ŀǰ��Ϊ�㷺�� OpenAI ���ݸ�ʽΪʵ�ֹ����������������ʵ��}
  private
    FPoolRef: TCnThreadPool; // �� Manager ���������е��̳߳ض�������
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
    {* �����ఴ��ʹ�õģ�ɾ������ͷ��� Authorization �ֶΣ��Ա�������֤��ʽ}

    procedure TalkToEngine(Sender: TCnThreadPool; DataObj: TCnTaskDataObject;
      Thread: TCnPoolingThread); virtual;
    {* ��Ĭ��ʵ������������صġ��� AI �����ṩ�߽�������ͨѶ��ȡ�����ʵ�ֺ���
      �ǵ�һ����װ�������Ӹ��̳߳غ����̳߳ص��Ⱥ��ھ��幤���߳��б�����
      ��һ�������� AI ����ͨѶ���������ڵ��������ڲ�����ݽ���ص� OnAINetDataResponse �¼�}

    procedure OnAINetDataResponse(Success, Partly: Boolean; Thread: TCnPoolingThread;
      DataObj: TCnAINetRequestDataObject; Data: TBytes; ErrCode: Cardinal); virtual;
    {* AI �����ṩ�߽�������ͨѶ�Ľ���ص����������߳��б����õģ��ڲ�Ӧ Sync �����������
      Success ���سɹ���񣬳ɹ��� Data ��������
      ��һ�������� AI ����ͨѶ���������ڵ��Ĳ�}

    procedure SyncCallback;
    {* ���������Ĳ�ͨ�� Synchronize �ķ�ʽ���ã�֮ǰ�ѽ�Ӧ��������� FAnswerQueue ����
      ��һ�������� AI ����ͨѶ���������ڵ��岽}

    // �����Ĺ��̣����࿴�ӿ��������
    function GetRequestURL(DataObj: TCnAINetRequestDataObject): string; virtual;
    {* ������ǰ��������һ�������Զ��� URL  �Ļ���}

    procedure PrepareRequestHeader(const ApiKey: string; Headers: TStringList); virtual;
    {* ������ǰ��������һ�������Զ��� HTTP ͷ�Ļ��ᡣApiKey �Ƿ�������ʱָ���ģ�
      �п������ⳡ�Ϻ� FOptions ��� ApiKey ��ͬ�������Դ�Ϊ׼��}

    function ConstructRequest(RequestType: TCnAIRequestType; const Code: string = '';
      History: TStrings = nil): TBytes; virtual;
    {* ��������������ԭʼ���뼰��ʷ��Ϣ����װ Post �����ݣ�һ���� JSON ��ʽ}

    function ParseResponse(SendId: Integer; StreamMode, Partly: Boolean; var Success: Boolean;
      var ErrorCode: Cardinal; var IsStreamEnd: Boolean; RequestType: TCnAIRequestType; const Response: TBytes): string; virtual;
    {* ��������������ԭʼ��Ӧ��������Ӧ���ݣ�һ���� JSON ��ʽ�������ַ����������ߣ�
      ͬʱ������ݷ��صĴ�����Ϣ���ĳɹ����SendId �Ƿ���ʱ�����������ʶ���������ֻỰ��
      StreamMode ��������ʱ�Ƿ�֧����ʽ��������Ϊ����˻�ͬ����η���ƴ�ӡ�
      Partly Ϊ True ��ʾ�˴������Ƿ��������ص��м����ݣ�ע�����ݹ���ʱ���ܵ����������ݡ�
      �ڲ�����ȷ���˲����� StreamMode Ϊ False ʱ�� Partly Ϊ True �����ݣ������� StreamMode Ϊ True ʱ����������
      IsStreamEnd ���ڲ������󷵻���ģʽ�±��λ�Ӧ�Ƿ��ǽ�β����}

    function ParseModelList(ResponseRoot: TCnJSONObject): string; virtual;
    {* �������� ModelList ��Ӧ��������̣����ఴ�����أ������治֧�֣�ֱ�ӷ��ؿ��ַ�������}

    class function GetModelListURL(const OrigURL: string): string; virtual;
    {* �� API ���õ�ַ��ȡ ModelList ���õ�ַ����ͬ�ṩ�̿����в�ͬ����
      �����治֧�֣�ֱ�ӷ��ؿ��ַ�������}
  public
    class function EngineName: string; virtual;
    {* ��������и�����}
    class function EngineID: string;
    {* ����� ID�����洢�����ã����������������}
    class function OptionClass: TCnAIEngineOptionClass; virtual;
    {* ������������Ӧ���࣬Ĭ��Ϊ���� TCnAIEngineOption}
    class function NeedApiKey: Boolean; virtual;
    {* �����Ƿ���Ҫ�ṩ API Key ���ܵ��ã�Ĭ�� True}

    constructor Create(ANetPool: TCnThreadPool); virtual;
    destructor Destroy; override;

    procedure InitOption;
    {* ����������ȥ���ù�������ȡ��������ö���}

    function AskAIEngine(const URL: string; const Text: TBytes; StreamMode: Boolean;
      RequestType: TCnAIRequestType; const ApiKey: string; Tag: TObject;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* �û����õ��� AI ͨѶ�Ĺ��̣�����ԭʼͨѶ���ݣ��ڲ�����װ����������Ӹ��̳߳أ�����һ������ ID
      ��һ�������� AI ����ͨѶ���������ڵ�һ�����ڶ������̳߳ص��ȵ� ProcessRequest ת��}

    function AskAIEngineForCode(const Code: string; History: TStrings; Tag: TObject;
      RequestType: TCnAIRequestType; AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* ��һ����װ���û����õĽ��ʹ���������Ĺ��̣��ڲ��� Code ת��Ϊ JSON ����� AskAIEngine��Ҳ���һ��}

    function AskAIEngineForModelList(Tag: TObject; AlterOption: TCnAIEngineOption = nil;
      AnswerCallback: TCnAIAnswerCallback = nil): Integer; virtual;
    {* ��һ����װ�����ý������û����õĻ�ȡģ���б�Ĺ��̣��ڲ���װ��������� AskAIEngine��Ҳ���һ��
       ��һ AlterOption ������Ŀ����Ϊ��������ʱָ�����������ñ� Engine Ĭ�ϲ������ʺ�����}

    property Option: TCnAIEngineOption read FOption;
    {* �������ã��������ִ����ù�������ȡ��������}
  end;

  TCnAIBaseEngineClass = class of TCnAIBaseEngine;
  {* AI �����༰������}

  TCnAIEngineManager = class
  {* �����ṩ AI ���������Ĺ����࣬��������ʵ���б�}
  private
    FPool: TCnThreadPool; // ���е��̳߳ض���
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
    {* �����ض������������ڲ������ţ������� CurrentIndex ʹ��}
  public
    constructor Create; virtual;
    {* ���캯���������ⲿ�������̳߳����ã�������� AI ����ʹ��}
    destructor Destroy; override;

    procedure LoadFromDirectory(const Dir, BaseFileFmt: string);
    {* ��������ʱ�ļ�������ڣ���ָ��Ŀ¼�������ļ���������������}
    procedure SaveToDirectory(const Dir, BaseFileFmt: string);
    {* ��������ʱ�ı�������ڣ����������ø��ݻ����ļ�������ָ��Ŀ¼}

    function GetEngineByOption(Option: TCnAIEngineOption): TCnAIBaseEngine;
    {* ����ѡ�������Ҷ�Ӧ����}

    procedure LoadFromWizOptions;
    {* ר�Ұ��ļ�������ڣ���̬�����������ã��ڲ���ֱ治ͬĿ¼}
    procedure SaveToWizOptions;
    {* ר�Ұ��ı�������ڣ���̬�����������õ��û�Ŀ¼}

    property CurrentEngineName: string read GetCurrentEngineName write SetCurrentEngineName;
    {* ��ü����õ�ǰ�������ƣ�ǰ�ߴӵ�ǰ������ȡ�����߻��л����档
       ע���� FPC �£����ַ��������� Utf8}
    property CurrentIndex: Integer read FCurrentIndex write SetCurrentIndex;
    {* ��ǰ�����������ţ�������л�����}
    property CurrentEngine: TCnAIBaseEngine read GetCurrentEngine;
    {* ��ǰ�����}

    property EngineCount: Integer read GetEnginCount;
    {* ��������}
    property Engines[Index: Integer]: TCnAIBaseEngine read GetEngine; default;
    {* ��������ȡ AI ����ʵ��}
  end;

procedure RegisterAIEngine(AIEngineClass: TCnAIBaseEngineClass);
{* ע��һ�� AI ����}

function CnAIEngineManager: TCnAIEngineManager;
{* ����һȫ�� AI ����������}

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

  // ��ʼ�������̳߳�
  FPool.OnProcessRequest := ProcessRequest;
  FPool.AdjustInterval := 5 * 1000;
  FPool.MinAtLeast := False;
  FPool.ThreadDeadTimeout := 10 * 1000;
  FPool.ThreadsMinCount := 0;
  FPool.ThreadsMaxCount := 2;
  FPool.TerminateWaitTime := 2 * 1000;
  FPool.ForceTerminate := True; // ����ǿ�ƽ���

  // ������ AI ����ʵ��
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
  // OptionManager ���ػ�������
  S := Dir + Format(BaseFileFmt, ['']);
  if FileExists(S) then
    CnAIEngineOptionManager.LoadFromFile(S);

  // ������������ ID���޸��ļ������������������Ӧ Option
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
  // OptionManager ���ػ�������
  S := Format(BaseFileFmt, ['']);
  CnAIEngineOptionManager.SaveToFile(Dir + S);

  // ������������ ID���޸��ļ������������Ӧ Option
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
    // �������ͷ�
    FCurrentIndex := Value;
    // ��¼����ı��ˣ������Ҫ�Ļ���ʼ��������
  end;
end;

procedure TCnAIEngineManager.LoadFromWizOptions;
var
  I: Integer;
  S: string;
  OrigOption, Option: TCnAIEngineOption;
begin
  // OptionManager ���ػ�������
  S := WizOptions.GetUserFileName(Format(SCnAICoderEngineOptionFileFmt, ['']), True);
  if FileExists(S) then
    CnAIEngineOptionManager.LoadFromFile(S);

  // �����ղصĴʶ�
  S := WizOptions.GetUserFileName(SCnAICoderFavoritesFile, True);
  if FileExists(S) then
  begin
    CnAIEngineOptionManager.LoadFavorite(S);
    CnAIEngineOptionManager.ShrinkFavorite;
  end;

  // ������������ ID���޸��ļ������������������Ӧ Option
  for I := 0 to EngineCount - 1 do
  begin
    S := WizOptions.GetUserFileName(Format(SCnAICoderEngineOptionFileFmt,
      [Engines[I].EngineID]), True);
    Option := CnAIEngineOptionManager.CreateOptionFromFile(Engines[I].EngineName,
      S, Engines[I].OptionClass);

    // ���ԭʼ�����ļ�
    OrigOption := nil;
    try
      S := WizOptions.GetDataFileName(Format(SCnAICoderEngineOptionFileFmt,
        [Engines[I].EngineID]));
      OrigOption := CnAIEngineOptionManager.CreateOptionFromFile(Engines[I].EngineName,
        S, Engines[I].OptionClass, False); // ע���ԭʼ���ö���������й���

      // OrigOption �е��µķǿ�ѡ�Ҫ��ֵ�� Option ��ͬ���Ŀ�ֵ�����ԣ������ֻ�����������
      // �û��������°����������µ�����ʱʹ�ã�ϣ�������¾�������������⡣
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
  // OptionManager �����������
  F := Format(SCnAICoderEngineOptionFileFmt, ['']);
  S := WizOptions.GetUserFileName(F, False);
  CnAIEngineOptionManager.SaveToFile(S);
  WizOptions.CheckUserFile(F);

  // �����ղصĴʶ�
  S := WizOptions.GetUserFileName(SCnAICoderFavoritesFile, False);
  CnAIEngineOptionManager.ShrinkFavorite;
  CnAIEngineOptionManager.SaveFavorite(S);

  // ������������ ID���޸��ļ������������Ӧ Option
  for I := 0 to EngineCount - 1 do
  begin
    F := Format(SCnAICoderEngineOptionFileFmt, [Engines[I].EngineID]);
    S := WizOptions.GetUserFileName(F, False);
    CnAIEngineOptionManager.SaveOptionToFile(Engines[I].EngineName, S);
    WizOptions.CheckUserFile(F);
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

  // ƴװ JSON ��ʽ��������Ϊ Post �ĸ������ݸ� Data ��
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
  // ��� Pool��Option �������Ƿ�Ϸ�
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
      // ��װģ���б�����Ĭ������Ϊ�գ�Ҳ��������������
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

      // �ȼ���ʷ
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
  // ���� SendId �ұ��λỰ�����������
  Prev := '';
  if FPrevRespRemainMap.Find(IntToStr(SendId), PrevS) then
  begin
    Prev := AnsiString(PrevS);
    S := Prev + BytesToAnsi(Response) // ��ʣ������ƴ�����������ٴν��н���
  end
  else
    S := BytesToAnsi(Response);

  JsonObjs := TObjectList.Create(True);
  Step := CnJSONParse(PAnsiChar(S), JsonObjs);
  P := PAnsiChar(PAnsiChar(S) + Step);

  if (P <> #0) and (Step < Length(S)) then
  begin
    // ����û�����꣨����û���㣩���Ҳ��ǽ�������˵����ʣ������
    Prev := Copy(S, Step + 1, MaxInt);
  end
  else // ˵��ûʣ������
    Prev := '';

  // ����ʣ�඼������
  FPrevRespRemainMap.Add(IntToStr(SendId), Prev);

  RespRoot := nil;
  if JsonObjs.Count > 0 then
    RespRoot := TCnJSONObject(JsonObjs[0]);

  if RespRoot = nil then
  begin
    // ��ģʽ��������η��ص����� datadone����ô����ƴ���ٽ����� RespRoot ��Ȼ�� nil��
    // ֻҪ�жϱ��������Ƿ�ֻʣ�½�������������������ؽ�����־�������ݷ���
    if Partly and (Trim(S) = RESP_DATA_DONE) then
    begin
      IsStreamEnd := True;
      FPrevRespRemainMap.Delete(IntToStr(SendId)); // ������
      Exit;
    end;

    // �������������һ��ԭʼ�������˺Ŵﵽ��󲢷���
    Result := S;
  end
  else
  begin
    try
      if RequestType = artModelList then
      begin
        Result := ParseModelList(RespRoot);
        // ע����������Ļس����д�����Ϊ����Ҫ
        if Result <> '' then
          Exit;
      end;

      // ������Ӧ
      HasPartly := False;
      if Partly then
      begin
        // ��ʽģʽ�£������ж�� Obj
        for I := 0 to JsonObjs.Count - 1 do
        begin
          RespRoot := TCnJSONObject(JsonObjs[I]);
          if (RespRoot['choices'] <> nil) and (RespRoot['choices'] is TCnJSONArray) then
          begin
            Arr := TCnJSONArray(RespRoot['choices']);
            if (Arr.Count > 0) and (Arr[0]['delta'] <> nil) and (Arr[0]['delta'] is TCnJSONObject) then
            begin
              // ÿһ���Ӧƴ����
              Msg := TCnJSONObject(Arr[0]['delta']);
              if (Msg['content'] <> nil) and (Msg['content'].AsString <> '') then
                Result := Result + Msg['content'].AsString
              else if Msg['reasoning_content'] <> nil then // Ҳ���������ݿգ�������������
                Result := Result + Msg['reasoning_content'].AsString;
              HasPartly := True;
            end;
          end;
        end;

        // �����Ӧ��ɺ�ʣ�µ� Prev ������ datadone ���������жϲ����ش˱�־
        if Trim(Prev) = RESP_DATA_DONE then
        begin
          IsStreamEnd := True;
          FPrevRespRemainMap.Delete(IntToStr(SendId)); // Ҳ������
          Exit; // �����ݷ��أ��������ֱ�� Exit
        end;
      end
      else // ����ģʽ��
      begin
        if (RespRoot['choices'] <> nil) and (RespRoot['choices'] is TCnJSONArray) then
        begin
          Arr := TCnJSONArray(RespRoot['choices']);
          if (Arr.Count > 0) and (Arr[0]['message'] <> nil) and (Arr[0]['message'] is TCnJSONObject) then
          begin
            // �����Ӧ
            Msg := TCnJSONObject(Arr[0]['message']);
            if (Msg['content'] <> nil) and (Msg['content'].AsString <> '') then
              Result := Msg['content'].AsString
            else if Msg['reasoning_content'] <> nil then // Ҳ������������������
              Result := Result + Msg['reasoning_content'].AsString;
          end;
        end;
      end;

      if not HasPartly and (Result = '') then
      begin
        // ����ģʽ�£�ֻҪû��������Ӧ����˵��������
        Success := False;

        // һ��ҵ����󣬱��� Key ��Ч��
        if (RespRoot['error'] <> nil) and (RespRoot['error'] is TCnJSONObject) then
        begin
          Msg := TCnJSONObject(RespRoot['error']);
          Result := Msg['message'].AsString;
        end;

        // һ��ҵ�񷵻ص�������󣬱��� URL ���˵�
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

      // ���ף�����ģʽ�£����н�������Ч��ֱ�������� JSON ��Ϊ������Ϣ
      if not HasPartly and (Result = '') then
        Result := S;
    finally
      JsonObjs.Free;
    end;
  end;

  // ����һ�»س�����
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
  // �� RespRoot �н�����ģ���б�ƴ�ɶ��ŷָ����ַ�����ֱ�ӷ��أ�
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
          if Pos(MODEL, S) = 1 then   // ��Щ�������ǰ��Ӹ�ǰ׺��ɾ��
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
    // ����ʱ��������˷� StreamMode����ô Partly ���سɹ�����ʱҪ���ԣ�����������
    if not TCnAINetRequestDataObject(DataObj).StreamMode and Partly then
      Exit;

    // ����ʱ��������� StreamMode����ôֻ����ÿ�ε� Partly �������ݣ�������������
    if TCnAINetRequestDataObject(DataObj).StreamMode and not Partly then
      Exit;
  end;

  // �����߳����õ����ݻ������¼���ֱ�ӵ��ã��ʵ���װ�� Synchronize ���ظ�����
  AnswerObj := TCnAIAnswerObject.Create;
  if not Success then
  begin
    AnswerObj.ErrorCode := ErrCode;
    // ���͵Ĵ������У�12002 �ǳ�ʱ��12029 ���޷��������ӿ����� SSL �汾���
  end;

  AnswerObj.StreamMode := TCnAINetRequestDataObject(DataObj).StreamMode;
  AnswerObj.Partly := Partly;

  AnswerObj.Success := Success;
  AnswerObj.SendId := TCnAINetRequestDataObject(DataObj).SendId;
  AnswerObj.IsStreamEnd := False; // ����ģʽ����Ч���ý�����ȷ�������Ƿ��������
  AnswerObj.RequestType := TCnAINetRequestDataObject(DataObj).RequestType;
  AnswerObj.Callback := TCnAINetRequestDataObject(DataObj).OnAnswer;
  AnswerObj.Tag := TCnAINetRequestDataObject(DataObj).Tag;
  AnswerObj.Answer := Data; // ���ã����м�������������ͷ�

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
      // SyncCallback ������ʱ��ȷ���˲����� StreamMode Ϊ False ʱ�� Partly ����
      // �Լ������� StreamMode Ϊ True ʱ����������
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

    // ���ó�ʱ��Ĭ�� 0 ��ʾ��ϵͳ��
    HTTP.ConnectTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.SendTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.ReceiveTimeOut := CnAIEngineOptionManager.TimeoutSec * 1000;
    HTTP.OnProgressData := HttpProgressData;

    // ���о����ô���
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
    // ����� AI ����������֤������䡣�������ǵģ������������ PrepareRequestHeader ��ɾ������ټ�

    PrepareRequestHeader(TCnAINetRequestDataObject(DataObj).ApiKey, HTTP.HttpRequestHeaders);

    Stream := TMemoryStream.Create;
    AURL := GetRequestURL(TCnAINetRequestDataObject(DataObj));

    // ��ʱ��¼ DataObj �����ã���Ϊ GetStream �������лص���Ҫʹ��
    FProcessingDataObj := TCnAINetRequestDataObject(DataObj);
    FProcessingThread := Thread;
    if HTTP.GetStream(AURL, Stream, TCnAINetRequestDataObject(DataObj).Data, @Err) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('*** HTTP Request OK Get Bytes ' + IntToStr(Stream.Size));
{$ENDIF}

      // ����Ҫ�ѽ���͸� UI ������������������ڱ��̣߳���Ϊ UI ���̵߳ĵ��ô�������ʱ���ǲ�ȷ���ģ�
      // �����˱�������Thread ��״̬��δ֪�ˣ��� Thread ������ݿ��ܻ��� Thread �����ӵ��ȶ������
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
  // TCn***AIEngine ����������
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
  // ��ȡ�Źֹ���ƴ�� ModelList �� URL�����������и���취
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
