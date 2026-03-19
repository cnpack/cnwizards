unit AICoderUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnThreadPool, CnInetUtils, CnNative, CnContainers, CnJSON,
  CnAICoderConfig, CnAICoderEngine, CnWideStrings, FileCtrl, CnChatBox, CnRichEdit,
  CnMarkDown, ExtCtrls, Menus, Clipbrd, Contnrs;

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
    tsChat: TTabSheet;
    pnlChat: TPanel;
    btnAddInfo: TButton;
    btnAddMyMsg: TButton;
    btnAddYouMsg: TButton;
    btnAddYouLongMsg: TButton;
    btnAddMyLongMsg: TButton;
    pnlAIChat: TPanel;
    btnReviewCode: TButton;
    btnFuncCall: TButton;
    pmChat: TPopupMenu;
    Copy1: TMenuItem;
    pmAIChat: TPopupMenu;
    CopyCode1: TMenuItem;
    chkMarkDown: TCheckBox;
    CopyAll1: TMenuItem;
    btnAddYourStream: TButton;
    tmrSteam: TTimer;
    btnModelList: TButton;
    btnChatFont: TButton;
    dlgFont1: TFontDialog;
    lblMe: TLabel;
    edtChatMessage: TEdit;
    btnInlineComplete: TButton;
    btnRefactorCode: TButton;
    btnFixCode: TButton;
    btnExtractContext: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddHttpsClick(Sender: TObject);
    procedure btnAIConfigSaveClick(Sender: TObject);
    procedure btnAIConfigLoadClick(Sender: TObject);
    procedure btnLoadAIConfigClick(Sender: TObject);
    procedure cbbAIEnginesChange(Sender: TObject);
    procedure btnSaveAIConfigClick(Sender: TObject);
    procedure btnExplainCodeClick(Sender: TObject);
    procedure btnAddInfoClick(Sender: TObject);
    procedure btnAddMyMsgClick(Sender: TObject);
    procedure btnAddYouMsgClick(Sender: TObject);
    procedure btnAddYouLongMsgClick(Sender: TObject);
    procedure btnAddMyLongMsgClick(Sender: TObject);
    procedure btnReviewCodeClick(Sender: TObject);
    procedure btnFuncCallClick(Sender: TObject);
    procedure chkMarkDownClick(Sender: TObject);
    procedure CopyAll1Click(Sender: TObject);
    procedure pmChatPopup(Sender: TObject);
    procedure pmAIChatPopup(Sender: TObject);
    procedure CopyCode1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure btnAddYourStreamClick(Sender: TObject);
    procedure tmrSteamTimer(Sender: TObject);
    procedure btnModelListClick(Sender: TObject);
    procedure btnChatFontClick(Sender: TObject);
    procedure edtChatMessageKeyPress(Sender: TObject; var Key: Char);
    procedure btnInlineCompleteClick(Sender: TObject);
    procedure btnRefactorCodeClick(Sender: TObject);
    procedure btnFixCodeClick(Sender: TObject);
    procedure btnExtractContextClick(Sender: TObject);
  private
    FNetPool: TCnThreadPool;
    FResQueue: TCnObjectQueue;
    FAIConfig: TCnAIEngineOptionManager;
    FChatBox: TCnChatBox;
    FChatItem: TCnChatItem;
    FAIChatBox: TCnChatBox;
    FAIChatItem: TCnChatItem;
    FRender: TCnRichEditRender;
    FRtfStream: TMemoryStream;
    FStreamMsg: TCnChatMessage;
    FStreamCnt: Integer;

    class function ExtractCode(Item: TCnChatMessage): string;

    procedure AIGetItemTextRect(Sender: TObject; Item: TCnChatItem; Canvas: TCanvas;
      var ItemTextRect: TRect; var DefaultCalc: Boolean);
    procedure AIDrawItemText(Sender: TObject; Item: TCnChatItem; Canvas: TCanvas;
     var ItemTextRect: TRect; var DefaultDraw: Boolean);

    // 以下是综合测试
    procedure AIOnExplainCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnReviewCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnFuncCallAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnRawAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnModelListAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnInlineCompleteAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnRefactorCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
    procedure AIOnFixCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
      const Answer: string; ErrorCode: Cardinal; Tag: TObject);
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
  CnDebug, CnAICoderNetClient;

const
  DBG_TAG = 'NET';
  AI_FILE_FMT = 'AICoderConfig%s.json';

procedure TFormAITest.FormCreate(Sender: TObject);
const
  BK_COLOR = $71EA9A;
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

  FChatBox := TCnChatBox.Create(Self);
  FChatBox.Color := clWhite;
  FChatBox.Parent := pnlChat;
  FChatBox.Align := alClient;
  FChatBox.ScrollBarVisible := True;
  FChatBox.ShowDownButton := True;
  FChatBox.ColorSelection := BK_COLOR;
  FChatBox.ColorScrollButton := clRed;
  FChatBox.ColorYou := BK_COLOR;
  FChatBox.ColorMe := BK_COLOR;
  FChatBox.PopupMenu := pmChat;

  FAIChatBox := TCnChatBox.Create(Self);
  FAIChatBox.Color := clWhite;
  FAIChatBox.Parent := pnlAIChat;
  FAIChatBox.Align := alClient;
  FAIChatBox.ScrollBarVisible := True;
  FAIChatBox.ShowDownButton := True;
  FAIChatBox.ColorSelection := BK_COLOR;
  FAIChatBox.ColorScrollButton := clRed;
  FAIChatBox.ColorYou := BK_COLOR;
  FAIChatBox.ColorMe := BK_COLOR;
  FAIChatBox.PopupMenu := pmAIChat;

  FRender := TCnRichEditRender.Create;
  FRtfStream := TMemoryStream.Create;
end;

procedure TFormAITest.FormDestroy(Sender: TObject);
begin
  FRtfStream.Free;
  FRender.Free;
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
  S: string;
begin
  if SelectDirectory('', '', S) then
  begin
    CnAIEngineManager.LoadFromDirectory(IncludeTrailingBackslash(S), AI_FILE_FMT);
    mmoAI.Lines.Add(CnUtf8ToAnsi(CnAIEngineOptionManager.SaveToJSON));

    cbbAIEngines.Items.Clear;
    for I := 0 to CnAIEngineManager.EngineCount - 1 do
      cbbAIEngines.Items.Add(CnAIEngineManager.Engines[I].EngineName);

    CnAIEngineManager.CurrentEngineName := CnAIEngineOptionManager.ActiveEngine;
    cbbAIEngines.ItemIndex := CnAIEngineManager.CurrentIndex;

    edtProxy.Text := CnAIEngineOptionManager.ProxyServer;

    for I := 0 to CnAIEngineManager.EngineCount - 1 do
      mmoAI.Lines.Add(CnUtf8ToAnsi(CnAIEngineManager.Engines[I].Option.SaveToJSON));
  end;
end;

procedure TFormAITest.cbbAIEnginesChange(Sender: TObject);
begin
  CnAIEngineOptionManager.ActiveEngine := cbbAIEngines.Text;
  CnAIEngineManager.CurrentEngineName := cbbAIEngines.Text;
end;

procedure TFormAITest.btnSaveAIConfigClick(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory('', '', Dir) then
    CnAIEngineManager.SaveToDirectory(IncludeTrailingBackslash(Dir), AI_FILE_FMT);
end;

procedure TFormAITest.btnExplainCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';
  Msg.Waiting := True;

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode('Application.CreateForm(TForm1, Form1);',
    nil, Msg, artExplainCode, AIOnExplainCodeAnswer);
end;

procedure TFormAITest.AIOnExplainCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Explain Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Explain Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  TCnChatMessage(Tag).Waiting := False;
  if Success then
  begin
    if Partly then
    begin
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
      if IsStreamEnd then
        mmoAI.Lines.Add('End Stream Comes.');
    end
    else
      TCnChatMessage(Tag).Text := Answer;
  end
  else
    TCnChatMessage(Tag).Text := Format('Explain Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.btnAddInfoClick(Sender: TObject);
begin
  with FChatBox.Items.AddInfo do
    Text := 'info ' + IntToStr(FChatBox.Items.Count);
end;

procedure TFormAITest.btnAddMyMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'CnPack';
    FromType := cmtMe;
    Text := 'My Message';
  end;
end;

procedure TFormAITest.btnAddYouMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtYou;
    Text := 'Your Message';
  end;
end;

procedure TFormAITest.btnAddYouLongMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtYou;
    Text := 'Any data compression method involves the reduction of redundancy in the data. '
      + 'Consequently, any corruption of the data is likely to have severe effects and be difficult to correct. '
      + 'Uncompressed text, on the other hand, will probably still be readable despite the presence of some corrupted bytes.';
  end;
end;

procedure TFormAITest.btnAddMyLongMsgClick(Sender: TObject);
begin
  with FChatBox.Items.AddMessage do
  begin
    From := 'AI';
    FromType := cmtMe;
    Text := '低代码开发方式具有丰富的UI界面编辑功能，通过可视化界面开发方式快速构建布局，可有效降低开发者的上手成本并提升开发者构建UI界面的效率。 '
      + '悠悠密西西比泾流经墨西哥，静静地流淌着，滋润着佛罗里达的土地，养育了南北战争中的百姓。这里水陆交通便捷，经济文化发达。' + #13#10
      + '①既往有对机体严重影响的疾病史(如心衰、严重脑梗死、心肌梗死等)；②既往有精神或神经方面疾病史，或有精神类药物依赖史；'
      + '③近期服用过影响大脑神经功能的药物，接受相关测试前24 h内饮用含酒精类饮品；④既往有其他睡眠相关疾病史；'
      + '⑤因各种原因不能配合研究者；⑥数据缺失或不全者。';
  end;
end;

procedure TFormAITest.btnReviewCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode('Application.CreateForm(TForm1, Form1);',
    nil, Msg, artReviewCode, AIOnReviewCodeAnswer);
end;

procedure TFormAITest.AIOnReviewCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Review Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Review Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  if Success then
  begin
    if Partly then
    begin
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
      if IsStreamEnd then
        mmoAI.Lines.Add('End Stream Comes.');
    end
    else
      TCnChatMessage(Tag).Text := Answer;
  end
  else
    TCnChatMessage(Tag).Text := Format('Review Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.chkMarkDownClick(Sender: TObject);
begin
  if chkMarkDown.Checked then
  begin
    FAIChatBox.OnGetItemTextRect := AIGetItemTextRect;
    FAIChatBox.OnDrawItemText := AIDrawItemText;
  end
  else
  begin
    FAIChatBox.OnGetItemTextRect := nil;
    FAIChatBox.OnDrawItemText := nil;
  end;
end;

procedure TFormAITest.AIDrawItemText(Sender: TObject; Item: TCnChatItem;
  Canvas: TCanvas; var ItemTextRect: TRect; var DefaultDraw: Boolean);
var
  Bmp: TBitmap;
begin
  if Item.Attachment <> nil then
  begin
    Bmp := TBitmap(Item.Attachment);
    Canvas.Draw(ItemTextRect.Left, ItemTextRect.Top, Bmp);
    DefaultDraw := False;
  end;
end;

procedure TFormAITest.AIGetItemTextRect(Sender: TObject; Item: TCnChatItem;
  Canvas: TCanvas; var ItemTextRect: TRect; var DefaultCalc: Boolean);
var
  S: AnsiString;
  Bmp: TBitmap;
begin
  FRtfStream.Size := 0;
  S := Item.Text;
  if S <> '' then
  begin
    S := CnMarkDownConvertToRTF(CnParseMarkDownString(S), 9);
    FRtfStream.WriteBuffer(S[1], Length(S));
    FRtfStream.Position := 0;

    if Item.Attachment <> nil then
    begin
      Item.Attachment.Free;
      Item.Attachment := nil;
    end;

    FRender.BackgroundColor := FAIChatBox.ColorYou;
    Bmp := FRender.RenderRtfToBitmap(FRtfStream, ItemTextRect.Right - ItemTextRect.Left);
    if Bmp <> nil then
    begin
      ItemTextRect.Bottom := ItemTextRect.Top + Bmp.Height;
      ItemTextRect.Right := ItemTextRect.Left + Bmp.Width;
      Item.Attachment := Bmp;

      DefaultCalc := False;
    end;
  end;
end;

procedure TFormAITest.CopyAll1Click(Sender: TObject);
begin
  if FAIChatItem <> nil then
  begin
    try
      if FAIChatItem is TCnChatMessage then
      begin
        if TCnChatMessage(FAIChatItem).SelText <> '' then
          Clipboard.AsText := TCnChatMessage(FAIChatItem).SelText
        else
          Clipboard.AsText := TCnChatMessage(FAIChatItem).Text;
      end;
    except
      ; // 弹出时记录的鼠标下的 Item，万一执行时被释放了，就可能出异常，要抓住
    end;
  end;
end;

procedure TFormAITest.pmChatPopup(Sender: TObject);
begin
  FChatItem := FChatBox.GetItemUnderMouse;
end;

procedure TFormAITest.pmAIChatPopup(Sender: TObject);
begin
  FAIChatItem := FAIChatBox.GetItemUnderMouse;
end;

procedure TFormAITest.CopyCode1Click(Sender: TObject);
var
  S: string;
begin
  if FAIChatItem <> nil then
  begin
    try
      if FAIChatItem is TCnChatMessage then
      begin
        S := ExtractCode(TCnChatMessage(FAIChatItem));
        if S <> '' then
        begin
          Clipboard.AsText := Trim(S);
          Exit;
        end;

        ShowMessage('NO Code');
      end;
    except
      ; // 弹出时记录的鼠标下的 Item，万一执行时被释放了，就可能出异常，要抓住
    end;
  end;
end;

class function TFormAITest.ExtractCode(Item: TCnChatMessage): string;
const
  CODE_BLOCK = '```';
  DELPHI_PREFIX = 'delphi' + #13#10;
  PASCAL_PREFIX = 'pascal' + #13#10;
  C_PREFIX = 'c' + #13#10;
  CPP_PREFIX = 'c++' + #13#10;
var
  S: string;
  I1, I2: Integer;
begin
  Result := '';
  if Item = nil then
    Exit;

  S := TCnChatMessage(Item).Text;
  I1 := Pos(CODE_BLOCK, S);
  if I1 > 0 then
  begin
    Delete(S, 1, I1 + Length(CODE_BLOCK) - 1);
    I2 := Pos(CODE_BLOCK, S);
    if I2 > 0 then
    begin
      S := Copy(S, 1, I2 - 1);
      I2 := Pos(DELPHI_PREFIX, LowerCase(S)); // 去除第一个 ``` 后的 delphi
      if I2 = 1 then
        Delete(S, 1, Length(DELPHI_PREFIX));

      I2 := Pos(PASCAL_PREFIX, LowerCase(S)); // 去除第一个 ``` 后的 pascal
      if I2 = 1 then
        Delete(S, 1, Length(PASCAL_PREFIX));

      I2 := Pos(C_PREFIX, LowerCase(S));      // 去除第一个 ``` 后的 C
      if I2 = 1 then
        Delete(S, 1, Length(C_PREFIX));

      I2 := Pos(CPP_PREFIX, LowerCase(S));    // 去除第一个 ``` 后的 C++
      if I2 = 1 then
        Delete(S, 1, Length(CPP_PREFIX));

      Result := Trim(S);
    end;
  end;
end;

procedure TFormAITest.Copy1Click(Sender: TObject);
begin
  if FChatItem <> nil then
  begin
    try
      if FChatItem is TCnChatMessage then
      begin
        if TCnChatMessage(FChatItem).SelText <> '' then
          Clipboard.AsText := TCnChatMessage(FChatItem).SelText
        else
          Clipboard.AsText := TCnChatMessage(FChatItem).Text;
      end;
    except
      ; // 弹出时记录的鼠标下的 Item，万一执行时被释放了，就可能出异常，要抓住
    end;
  end;
end;

procedure TFormAITest.btnAddYourStreamClick(Sender: TObject);
begin
  FStreamMsg := FChatBox.Items.AddMessage;
  FStreamMsg.From := 'AI';
  FStreamMsg.FromType := cmtYou;
  FStreamCnt := 0;

  tmrSteam.Enabled := True;
end;

procedure TFormAITest.tmrSteamTimer(Sender: TObject);
begin
  if FStreamMsg <> nil then
  begin
    FStreamMsg.Text := FStreamMsg.Text + '吃饭喝水 ';
    Inc(FStreamCnt);

    if FStreamCnt >= 100 then
      tmrSteam.Enabled := False;
  end;
end;

procedure TFormAITest.btnModelListClick(Sender: TObject);
begin
  CnAIEngineManager.CurrentEngine.AskAIEngineForModelList(nil, nil, AIOnModelListAnswer);
end;

procedure TFormAITest.AIOnModelListAnswer(StreamMode, Partly, Success,
  IsStreamEnd: Boolean; SendId: Integer; const Answer: string;
  ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Model List OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Model List Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));
end;

procedure TFormAITest.btnChatFontClick(Sender: TObject);
begin
  dlgFont1.Font := FChatBox.Font;
  if dlgFont1.Execute then
  begin
    FAIChatBox.Font := dlgFont1.Font;
    FChatBox.Font := dlgFont1.Font;
  end;
end;

procedure TFormAITest.edtChatMessageKeyPress(Sender: TObject;
  var Key: Char);
var
  Msg: TCnChatMessage;
  His: TStrings;
begin
  if Key = #13 then
  begin
    Key := #0;

    if Trim(edtChatMessage.Text) <> '' then
    begin
      His := TStringList.Create;
      try
        FAIChatBox.GetRecentMessages(His, CnAIEngineOptionManager.HistoryCount);

        // 发出的消息
        Msg := FAIChatBox.Items.AddMessage;
        Msg.From := CnAIEngineManager.CurrentEngineName;
        Msg.Text := edtChatMessage.Text;
        Msg.FromType := cmtMe;

        // 回来的消息
        Msg := FAIChatBox.Items.AddMessage;
        Msg.From := CnAIEngineManager.CurrentEngineName;
        Msg.FromType := cmtYou;
        Msg.Text := '...';

        CnAIEngineManager.CurrentEngine.AskAIEngineForCode(edtChatMessage.Text, His, Msg,
          artRaw, AIOnRawAnswer);

        edtChatMessage.Text := '';
      finally
        His.Free;
      end;
    end;
  end;
end;

procedure TFormAITest.AIOnRawAnswer(StreamMode, Partly, Success,
  IsStreamEnd: Boolean; SendId: Integer; const Answer: string;
  ErrorCode: Cardinal; Tag: TObject);
begin
  if (Tag <> nil) and (Tag is TCnChatMessage) then
  begin
    TCnChatMessage(Tag).Waiting := False;
    if Success then
    begin
      if Partly and (TCnChatMessage(Tag).Text <> '...') then
        TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer
      else
        TCnChatMessage(Tag).Text := Answer;
    end
    else
      TCnChatMessage(Tag).Text := Format('%d %s', [ErrorCode, Answer]);
  end;
end;

procedure TFormAITest.btnFuncCallClick(Sender: TObject);
var
  Msg: TCnChatMessage;
  Tool: TCnAITool;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';
  Msg.Waiting := True;

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  // Register Tools
  CnAIEngineManager.CurrentEngine.Tools.Clear;

  Tool := TCnAITool.Create;
  Tool.Name := 'read_file';
  Tool.Description := 'Read the content of a file.';
  Tool.Parameters := '{"type": "object", "properties": {"path": {"type": "string", "description": "The absolute path to the file"}}, "required": ["path"]}';
  CnAIEngineManager.CurrentEngine.Tools.Add(Tool);

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode('Please read the file ' + ParamStr(0) + ' and tell me its size.',
    nil, Msg, artRaw, AIOnFuncCallAnswer);
end;

procedure TFormAITest.AIOnFuncCallAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
var
  Json: TCnJSONObject;
  Arr: TCnJSONArray;
  ToolCall: TCnJSONObject;
  Args: string;
  FuncArgs: TCnJSONObject;
  JsonObjs: TObjectList;
begin
  if (Tag = nil) or not (Tag is TCnChatMessage) then Exit;

  if not Success then
  begin
    TCnChatMessage(Tag).Text := Format('Error: %d %s', [ErrorCode, Answer]);
    TCnChatMessage(Tag).Waiting := False;
    Exit;
  end;

  // Check if Answer is JSON with tool_calls
  if (Length(Answer) > 0) and (Answer[1] = '{') then
  begin
    JsonObjs := TObjectList.Create(True);
    try
      if CnJSONParse(PAnsiChar(AnsiString(Answer)), JsonObjs) > 0 then
      begin
        if JsonObjs.Count > 0 then
        begin
          Json := TCnJSONObject(JsonObjs[0]);
          if (Json['tool_calls'] <> nil) and (Json['tool_calls'] is TCnJSONArray) then
          begin
             Arr := TCnJSONArray(Json['tool_calls']);
             if Arr.Count > 0 then
             begin
               ToolCall := TCnJSONObject(Arr[0]);
               // Execute Tool
               if (ToolCall['function'] <> nil) then
               begin
                  FuncArgs := TCnJSONObject(ToolCall['function']);
                  Args := FuncArgs['arguments'].AsString;
                  TCnChatMessage(Tag).Text := 'Tool Call: ' + FuncArgs['name'].AsString + ' Args: ' + Args;
                  TCnChatMessage(Tag).Waiting := False;
                  Exit;
               end;
             end;
          end;
        end;
      end;
    finally
      JsonObjs.Free;
    end;
  end;

  // Normal text
  if Partly then
  begin
    if TCnChatMessage(Tag).Text = '...' then
      TCnChatMessage(Tag).Text := Answer
    else
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
  end
  else
    TCnChatMessage(Tag).Text := Answer;

  if IsStreamEnd or not Partly then
    TCnChatMessage(Tag).Waiting := False;
end;

procedure TFormAITest.btnRefactorCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';
  Msg.Waiting := True;

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode(mmoAI.Lines.Text,
    nil, Msg, artRefactorCode, AIOnRefactorCodeAnswer);
end;

procedure TFormAITest.AIOnRefactorCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Refactor Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Refactor Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  TCnChatMessage(Tag).Waiting := False;
  if Success then
  begin
    if Partly then
    begin
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
      if IsStreamEnd then
        mmoAI.Lines.Add('End Stream Comes.');
    end
    else
      TCnChatMessage(Tag).Text := Answer;
  end
  else
    TCnChatMessage(Tag).Text := Format('Refactor Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.btnFixCodeClick(Sender: TObject);
var
  Msg: TCnChatMessage;
begin
  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';
  Msg.Waiting := True;

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode(mmoAI.Lines.Text,
    nil, Msg, artFixCode, AIOnFixCodeAnswer);
end;

procedure TFormAITest.AIOnFixCodeAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Fix Code OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Fix Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  TCnChatMessage(Tag).Waiting := False;
  if Success then
  begin
    if Partly then
    begin
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
      if IsStreamEnd then
        mmoAI.Lines.Add('End Stream Comes.');
    end
    else
      TCnChatMessage(Tag).Text := Answer;
  end
  else
    TCnChatMessage(Tag).Text := Format('Fix Code Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.btnInlineCompleteClick(Sender: TObject);
var
  Msg: TCnChatMessage;
  Context: string;
begin
  Context := ExtractContextWindow(mmoAI.Lines.Text, 5, 100, 50);

  Msg := FAIChatBox.Items.AddMessage;
  Msg.From := 'AI';
  Msg.FromType := cmtYou;
  Msg.Text := '...';
  Msg.Waiting := True;

  if Trim(edtProxy.Text) <> '' then
  begin
    CnAIEngineOptionManager.UseProxy := True;
    CnAIEngineOptionManager.ProxyServer := Trim(edtProxy.Text);
  end
  else
    CnAIEngineOptionManager.UseProxy := False;

  CnAIEngineManager.CurrentEngine.AskAIEngineForCode(Context,
    nil, Msg, artInlineComplete, AIOnInlineCompleteAnswer);
end;

procedure TFormAITest.AIOnInlineCompleteAnswer(StreamMode, Partly, Success, IsStreamEnd: Boolean;
  SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
begin
  if Success then
    mmoAI.Lines.Add(Format('Inline Complete OK for Request %d: %s', [SendId, Answer]))
  else
    mmoAI.Lines.Add(Format('Inline Complete Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]));

  if (Tag = nil) or not (Tag is TCnChatMessage) then
    Exit;

  TCnChatMessage(Tag).Waiting := False;
  if Success then
  begin
    if Partly then
    begin
      TCnChatMessage(Tag).Text := TCnChatMessage(Tag).Text + Answer;
      if IsStreamEnd then
        mmoAI.Lines.Add('End Stream Comes.');
    end
    else
      TCnChatMessage(Tag).Text := Answer;
  end
  else
    TCnChatMessage(Tag).Text := Format('Inline Complete Fail for Request %d: Error Code: %d. Error Msg: %s',
      [SendId, ErrorCode, Answer]);
end;

procedure TFormAITest.btnExtractContextClick(Sender: TObject);
var
  Context: string;
begin
  Context := ExtractContextWindow(mmoAI.Lines.Text, 5, 100, 50);
  mmoAI.Lines.Clear;
  mmoAI.Lines.Add('--- Extract Context Result ---');
  mmoAI.Lines.Add(Context);
end;

end.
