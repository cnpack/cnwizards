unit CnFmxViewMain;
{ CnMacDebugViewer 主窗体：模仿 CnDebugViewer 的 CnViewMain（VCL/MDI 版），
  以 FMX TabControl 管理多个 TCnFmxMdiView 子视图。
  去除了 OutputDebugString 捕获、托盘图标、全局热键等 Mac 上无意义的功能，
  数据通道复用 CnMsgClasses / CnMsgFiler / CnViewCore。 }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Layouts, FMX.ListBox, FMX.TabControl, FMX.StdCtrls, FMX.Platform,
  CnMsgClasses, CnDebugIntf, CnMsgFiler, CnFmxMdiView, CnViewCore,
  CnGetThread, CnFmxFilterFrm, CnFmxViewOption, CnFmxUdpThread, CnCRC32;

type
  TCnRunState = (crsStopped, crsRunning, crsPaused);

type
  TCnFmxMainViewer = class(TForm)
    MenuBar1: TMenuBar;
    mniFile: TMenuItem;
    mniFileNew: TMenuItem;
    mniFileOpen: TMenuItem;
    mniFileClose: TMenuItem;
    mniFileSave: TMenuItem;
    mniFileExport: TMenuItem;
    mniFileSep1: TMenuItem;
    mniFileExit: TMenuItem;
    mniEdit: TMenuItem;
    mniEditClear: TMenuItem;
    mniEditClearTime: TMenuItem;
    mniEditCopy: TMenuItem;
    mniEditSep1: TMenuItem;
    mniEditBmToggle: TMenuItem;
    mniEditBmPrev: TMenuItem;
    mniEditBmNext: TMenuItem;
    mniEditBmClear: TMenuItem;
    mniEditSep2: TMenuItem;
    mniEditFind: TMenuItem;
    mniEditFindNext: TMenuItem;
    mniView: TMenuItem;
    mniViewTime: TMenuItem;
    mniViewDetail: TMenuItem;
    mniViewSep1: TMenuItem;
    mniViewFirst: TMenuItem;
    mniViewPrev: TMenuItem;
    mniViewNext: TMenuItem;
    mniViewLast: TMenuItem;
    mniControl: TMenuItem;
    mniCtrlStart: TMenuItem;
    mniCtrlPause: TMenuItem;
    mniCtrlStop: TMenuItem;
    mniOption: TMenuItem;
    mniOptionOptions: TMenuItem;
    mniOptionFilter: TMenuItem;
    mniOptionSep1: TMenuItem;
    mniOptionLanguage: TMenuItem;
    mniWindow: TMenuItem;
    mniWinNone: TMenuItem;
    mniHelp: TMenuItem;
    mniHelpAbout: TMenuItem;
    ToolBar1: TToolBar;
    sbNew: TSpeedButton;
    sbOpen: TSpeedButton;
    sbSave: TSpeedButton;
    sbSep1: TLayout;   // FMX 无 TSeparator，用空 TLayout 占位
    sbCopy: TSpeedButton;
    sbClear: TSpeedButton;
    sbSep2: TLayout;
    sbBookmark: TSpeedButton;
    TabControl1: TTabControl;
    LayoutStatus: TLayout;
    lblStatusLeft: TLabel;
    lblStatusRight: TLabel;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    dlgSaveExport: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FileNewClick(Sender: TObject);
    procedure FileOpenClick(Sender: TObject);
    procedure FileSaveClick(Sender: TObject);
    procedure FileCloseClick(Sender: TObject);
    procedure FileExitClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditClearClick(Sender: TObject);
    procedure EditClearTimeClick(Sender: TObject);
    procedure ViewDetailClick(Sender: TObject);
    procedure ViewTimeClick(Sender: TObject);
    procedure ViewFindClick(Sender: TObject);
    procedure ViewFindNextClick(Sender: TObject);
    procedure BmToggleClick(Sender: TObject);
    procedure BmPrevClick(Sender: TObject);
    procedure BmNextClick(Sender: TObject);
    procedure BmClearClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure OptionsFilterClick(Sender: TObject);
    procedure OptionsOptionsClick(Sender: TObject);
    procedure ActStartClick(Sender: TObject);
    procedure ActPauseClick(Sender: TObject);
    procedure ActStopClick(Sender: TObject);
    procedure ViewFirstClick(Sender: TObject);
    procedure ViewPrevClick(Sender: TObject);
    procedure ViewNextClick(Sender: TObject);
    procedure ViewLastClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
  private
    FMsgManager: TCnMsgManager;
    FGetThread: TGetDebugThread;    // shm 共享内存读取线程
    FUdpThread: TCnUdpGetThread;    // UDP 接收线程
    FRunState: TCnRunState;
    // Window 菜单项池：运行时只切换 Visible，绝不 Free 原生菜单栏中注册过的菜单项
    // （macOS Cocoa 菜单层持有 TMenuItem 指针，Free 会造成悬空指针 → EInvalidCast）
    FWinMenuItems: array[0..15] of TMenuItem; // 上限与 CnMaxTabCount 一致
    procedure StopThreads;
    procedure CreateWindowMenuPool;
    procedure RestoreWindowPlacement;
    procedure UpdateStoreNotify(Sender: TObject);
    procedure NewStoreNotify(AStore: TCnMsgStore);
    procedure UdpMsgNotify(Sender: TObject; const FromIP: string;
      Port: Integer; Buffer: Pointer; Len: Integer);
    function CurrentView: TCnFmxMdiView;
    function OptionsFileName: string;
    procedure CreateTabForStore(Store: TCnMsgStore);
    procedure UpdateTabCaption(TabItem: TTabItem; View: TCnFmxMdiView);
    procedure ProcessInfoChanged(Sender: TObject);
    procedure UpdateMenuAndStatus;
    procedure RebuildWindowMenu;
    procedure WindowItemClick(Sender: TObject);
    procedure CopyTextToClipboard(const AText: string);
  end;

var
  CnFmxMainViewer: TCnFmxMainViewer;

implementation

{$R *.fmx}

const
  // 原 CnMaxProcessCount 定义在 VCL 版 CnMdiView 中，FMX 工程不引用它，这里本地定义
  CnMaxTabCount = 16;

{ TCnFmxMainViewer }

procedure TCnFmxMainViewer.FormCreate(Sender: TObject);
begin
  FMsgManager := CnMsgManager;
  InitializeCore; // 全局临界区、CPUClock 等核心初始化
  if CnViewerOptions = nil then
    CnViewerOptions := TCnViewerOptions.Create;
  LoadOptions(OptionsFileName);
  RestoreWindowPlacement;
  CreateWindowMenuPool;
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopThreads;
  if CnViewerOptions <> nil then
  begin
    // 记录窗口位置与状态（对照 Win 版 FormDestroy）
    if CnViewerOptions.SaveFormPosition then
    begin
      CnViewerOptions.WinState := Ord(WindowState);
      if WindowState = TWindowState.wsNormal then
      begin
        CnViewerOptions.Top := Round(Top);
        CnViewerOptions.Left := Round(Left);
        CnViewerOptions.Height := Round(Height);
        CnViewerOptions.Width := Round(Width);
      end;
    end;
    SaveOptions(OptionsFileName);
  end;
  Action := TCloseAction.caFree;
end;

procedure TCnFmxMainViewer.RestoreWindowPlacement;
begin
  // 对照 Win 版 FormCreate 的窗口还原逻辑（含单显示器防越界）
  if CnViewerOptions = nil then
    Exit;

  if not CnViewerOptions.SaveFormPosition then
    Exit;

  case CnViewerOptions.WinState of
    0:
      begin
        Position := TFormPosition.Designed;
        Top := CnViewerOptions.Top;
        Left := CnViewerOptions.Left;
        Height := CnViewerOptions.Height;
        Width := CnViewerOptions.Width;

        // 超出桌面范围时归零，防止窗口找不到（FMX 无 MonitorCount，用桌面总尺寸判断）
        if Top > Screen.DesktopHeight - 40 then
          Top := 0;
        if Left > Screen.DesktopWidth then
          Left := 0;
        if Top + Height < 0 then
          Top := 0;
        if Left + Width < 0 then
          Left := 0;
      end;
    1: WindowState := TWindowState.wsMinimized;
    2: WindowState := TWindowState.wsMaximized; // 上次最大化，启动即最大化
  end;
end;

function TCnFmxMainViewer.OptionsFileName: string;
begin
  Result := TPath.Combine(TPath.GetDocumentsPath, 'CnMacDebugViewerOptions.xml');
end;

function TCnFmxMainViewer.CurrentView: TCnFmxMdiView;
begin
  if (TabControl1.ActiveTab <> nil) and (TabControl1.ActiveTab.TagObject is TCnFmxMdiView) then
    Result := TabControl1.ActiveTab.TagObject as TCnFmxMdiView
  else
    Result := nil;
end;

procedure TCnFmxMainViewer.UpdateTabCaption(TabItem: TTabItem; View: TCnFmxMdiView);
var
  S: string;
begin
  if (TabItem = nil) or (View = nil) then
    Exit;

  if View.ProcName = '' then
    S := SCnNoneProcName
  else
    S := ExtractFileName(View.ProcName);

  if (View.ProcessID <> 0) and (View.ProcessID <> CnInvalidFileProcId) then
    TabItem.Text := ' ' + S + ' $' + IntToHex(View.ProcessID, 2) + ' '
  else
    TabItem.Text := ' ' + S + ' ';
end;

procedure TCnFmxMainViewer.CreateTabForStore(Store: TCnMsgStore);
var
  TabItem: TTabItem;
  View: TCnFmxMdiView;
begin
  if Store = nil then
    Exit;

  TabItem := TabControl1.Add;
  View := TCnFmxMdiView.Create(TabItem);
  View.Parent := TabItem;
  View.Align := TAlignLayout.Client;
  View.MsgStore := Store;
  View.OnProcessInfoChanged := ProcessInfoChanged;
  TabItem.TagObject := View;

  UpdateTabCaption(TabItem, View);
  TabControl1.ActiveTab := TabItem;
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.ProcessInfoChanged(Sender: TObject);
var
  I: Integer;
  View: TCnFmxMdiView;
begin
  if Sender is TCnFmxMdiView then
  begin
    View := Sender as TCnFmxMdiView;
    for I := 0 to TabControl1.TabCount - 1 do
      if TabControl1.Tabs[I].TagObject = View then
        UpdateTabCaption(TabControl1.Tabs[I], View);
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.FileNewClick(Sender: TObject);
var
  Store: TCnMsgStore;
begin
  if TabControl1.TabCount >= CnMaxTabCount then
    Exit;

  // 原版 actNew 只建空子窗口不建 Store；AddStore 拒绝空名（返回 nil），
  // 故用占位名创建空 Store，等价原版空窗口（不会自动接收消息）
  Store := FMsgManager.AddStore(0,
    Format('New Window %d', [TabControl1.TabCount + 1]));
  CreateTabForStore(Store);
end;

procedure TCnFmxMainViewer.FileOpenClick(Sender: TObject);
var
  Filer: ICnMsgFiler;
  Store: TCnMsgStore;
begin
  if not dlgOpen.Execute then
    Exit;

  Store := FMsgManager.AddStore(CnInvalidFileProcId, ExtractFileName(dlgOpen.FileName));

  if SameText(ExtractFileExt(dlgOpen.FileName), '.xml') then
    Filer := TCnMsgXMLFiler.Create
  else
    Filer := TCnMsgJSONFiler.Create;

  try
    Store.LoadFromFile(Filer, dlgOpen.FileName);
  except
    on E: Exception do
    begin
      ErrorDlg('Load file failed: ' + E.Message);
      FMsgManager.RemoveStore(Store);
      Exit;
    end;
  end;

  CreateTabForStore(Store);
end;

procedure TCnFmxMainViewer.FileSaveClick(Sender: TObject);
var
  View: TCnFmxMdiView;
  Filer: ICnMsgFiler;
  FN: string;
begin
  View := CurrentView;
  if (View = nil) or (View.MsgStore = nil) then
    Exit;

  if not dlgSave.Execute then
    Exit;

  FN := dlgSave.FileName;
  if ExtractFileExt(FN) = '' then
    FN := ChangeFileExt(FN, '.xml');

  if SameText(ExtractFileExt(FN), '.xml') then
    Filer := TCnMsgXMLFiler.Create
  else
    Filer := TCnMsgJSONFiler.Create;

  View.MsgStore.SaveToFile(Filer, FN);
end;

procedure TCnFmxMainViewer.FileCloseClick(Sender: TObject);
var
  View: TCnFmxMdiView;
  Store: TCnMsgStore;
  TabItem: TTabItem;
begin
  TabItem := TabControl1.ActiveTab;
  if TabItem = nil then
    Exit;

  View := CurrentView;
  if View <> nil then
  begin
    Store := View.MsgStore;
    View.MsgStore := nil; // 断开 OnChange 并清空显示
    if Store <> nil then
      FMsgManager.RemoveStore(Store);
  end;

  TabControl1.Delete(TabControl1.TabIndex);
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.FileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TCnFmxMainViewer.CopyTextToClipboard(const AText: string);
begin
  if (AText <> '') and
     TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService) then
    (TPlatformServices.Current.GetPlatformService(IFMXClipboardService) as
      IFMXClipboardService).SetClipboard(AText);
end;

procedure TCnFmxMainViewer.EditCopyClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    CopyTextToClipboard(View.GetSelectedContent);
end;

procedure TCnFmxMainViewer.EditClearClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.ClearStores;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.EditClearTimeClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.ClearTimes;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.ViewDetailClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.DetailPanelVisible := not View.DetailPanelVisible;
    mniViewDetail.IsChecked := View.DetailPanelVisible;
  end;
end;

procedure TCnFmxMainViewer.ViewTimeClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.TimePanelVisible := not View.TimePanelVisible;
    mniViewTime.IsChecked := View.TimePanelVisible;
  end;
end;

procedure TCnFmxMainViewer.ViewFindClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.SetSearchFocus;
end;

procedure TCnFmxMainViewer.ViewFindNextClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.FindNextMessage;
end;

procedure TCnFmxMainViewer.ViewFirstClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoRow(0);
end;

procedure TCnFmxMainViewer.ViewPrevClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoNeighbor(-1);
end;

procedure TCnFmxMainViewer.ViewNextClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoNeighbor(1);
end;

procedure TCnFmxMainViewer.ViewLastClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoRow(MaxInt);
end;

procedure TCnFmxMainViewer.BmToggleClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.ToggleBookmark;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.BmPrevClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoPrevBookmark;
end;

procedure TCnFmxMainViewer.BmNextClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
    View.GotoNextBookmark;
end;

procedure TCnFmxMainViewer.BmClearClick(Sender: TObject);
var
  View: TCnFmxMdiView;
begin
  View := CurrentView;
  if View <> nil then
  begin
    View.ClearAllBookmarks;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.ExportClick(Sender: TObject);
const
  CRLF = #13#10;
var
  View: TCnFmxMdiView;
  FN, Msg: string;
  I, Kind: Integer;
  AMsgItem: TCnMsgItem;
  SB: TStringBuilder;
begin
  View := CurrentView;
  if (View = nil) or (View.MsgStore = nil) then
    Exit;
  if not dlgSaveExport.Execute then
    Exit;

  Kind := dlgSaveExport.FilterIndex;
  FN := dlgSaveExport.FileName;
  case Kind of
    1: FN := ChangeFileExt(FN, '.txt');
    2: FN := ChangeFileExt(FN, '.csv');
    3: FN := ChangeFileExt(FN, '.htm');
  end;

  SB := TStringBuilder.Create;
  try
    case Kind of
      1: // TXT：逐条输出完整描述
        for I := 0 to View.MsgStore.MsgCount - 1 do
        begin
          SB.Append('--------------------------------------------------------------------------------')
            .Append(CRLF);
          SB.Append(View.DescriptionOfMsg(I, View.MsgStore.Msgs[I])).Append(CRLF);
          SB.Append(CRLF);
        end;
      2: // CSV：替换回车与逗号
        begin
          SB.Append(SCnCSVFormatHeader).Append(CRLF);
          for I := 0 to View.MsgStore.MsgCount - 1 do
          begin
            AMsgItem := View.MsgStore.Msgs[I];
            Msg := StringReplace(AMsgItem.Msg, #13#10, ' ', [rfReplaceAll]);
            Msg := StringReplace(Msg, ',', ' ', [rfReplaceAll]);
            SB.Append(Format('%d,%d,%s,$%x,$%x,%s,%s,%s', [I + 1, AMsgItem.Level,
              SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId,
              AMsgItem.Tag, GetLongTimeDesc(AMsgItem), Msg])).Append(CRLF);
          end;
        end;
      3: // HTML：转义尖括号
        begin
          SB.Append(Format(SCnHTMFormatHeader, [SCnHTMFormatStyle, FN, SCnHTMFormatCharset]))
            .Append(CRLF);
          SB.Append(SCnHTMFormatTableHead).Append(CRLF);
          for I := 0 to View.MsgStore.MsgCount - 1 do
          begin
            AMsgItem := View.MsgStore.Msgs[I];
            Msg := StringReplace(AMsgItem.Msg, '<', '&lt;', [rfReplaceAll]);
            Msg := StringReplace(Msg, '>', '&gt;', [rfReplaceAll]);
            Msg := StringReplace(Msg, #13#10, '<BR>', [rfReplaceAll]);
            SB.Append(Format(SCnHTMFormatLine, [I + 1, AMsgItem.Level,
              SCnMsgTypeDescArray[AMsgItem.MsgType]^, AMsgItem.ThreadId, AMsgItem.ProcessId,
              AMsgItem.Tag, GetLongTimeDesc(AMsgItem), Msg])).Append(CRLF);
          end;
          SB.Append(SCnHTMFormatEnd).Append(CRLF);
        end;
    end;
    // Mac 下统一以 UTF-8 落盘
    TFile.WriteAllText(FN, SB.ToString, TEncoding.UTF8);
  finally
    SB.Free;
  end;
end;

procedure TCnFmxMainViewer.AboutClick(Sender: TObject);
begin
  ShowMessage(SCnDebugViewerAbout);
end;

procedure TCnFmxMainViewer.OptionsFilterClick(Sender: TObject);
var
  Frm: TCnFmxFilterFrm;
begin
  Frm := TCnFmxFilterFrm.Create(nil);
  try
    Frm.LoadFromOptions;
    if Frm.ShowModal = mrOk then
      Frm.SaveToOptions;
  finally
    Frm.Free;
  end;
end;

procedure TCnFmxMainViewer.OptionsOptionsClick(Sender: TObject);
var
  Frm: TCnFmxViewOptionFrm;
begin
  Frm := TCnFmxViewOptionFrm.Create(nil);
  try
    Frm.LoadFromOptions;
    if Frm.ShowModal = mrOk then
      Frm.SaveToOptions;
  finally
    Frm.Free;
  end;
end;

procedure TCnFmxMainViewer.ActStartClick(Sender: TObject);
begin
  if FRunState = crsStopped then
  begin
    if FGetThread = nil then
    begin
      FGetThread := TGetDebugThread.Create(False);
      FGetThread.OnUpdateStore := UpdateStoreNotify;
      FGetThread.OnNewStore := NewStoreNotify;
    end;
    if (FUdpThread = nil) and (CnViewerOptions <> nil) and
       CnViewerOptions.EnableUDPMsg then
    begin
      FUdpThread := TCnUdpGetThread.Create(CnViewerOptions.UDPPort);
      FUdpThread.OnUdpMsg := UdpMsgNotify;
    end;
    FRunState := crsRunning;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.ActPauseClick(Sender: TObject);
begin
  if FRunState = crsRunning then
  begin
    FRunState := crsPaused;
    if FGetThread <> nil then
      FGetThread.Paused := True;
  end
  else if FRunState = crsPaused then
  begin
    FRunState := crsRunning;
    if FGetThread <> nil then
      FGetThread.Paused := False;
  end;
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.ActStopClick(Sender: TObject);
begin
  if FRunState <> crsStopped then
  begin
    StopThreads;
    FRunState := crsStopped;
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.StopThreads;
begin
  if FGetThread <> nil then
  begin
    FGetThread.Terminate;
    FGetThread.Paused := False;
    FreeAndNil(FGetThread); // TThread.Destroy 内部 WaitFor
  end;
  if FUdpThread <> nil then
  begin
    FUdpThread.Stop;
    FreeAndNil(FUdpThread);
  end;
end;

procedure TCnFmxMainViewer.UpdateStoreNotify(Sender: TObject);
var
  I: Integer;
begin
  // 共享内存队列读空，触发各 Store 的批量变更通知以刷新界面
  for I := 0 to FMsgManager.Count - 1 do
    FMsgManager.Store[I].FlushPendingNotify;
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.NewStoreNotify(AStore: TCnMsgStore);
begin
  CreateTabForStore(AStore);
end;

procedure TCnFmxMainViewer.UdpMsgNotify(Sender: TObject; const FromIP: string;
  Port: Integer; Buffer: Pointer; Len: Integer);
var
  ProcName: string;
  ProcId: Cardinal;
  AStore: TCnMsgStore;
  ADesc: TCnMsgDesc;
begin
  if (FRunState = crsPaused) or (CnViewerOptions = nil) or
     not CnViewerOptions.EnableUDPMsg then
    Exit;

  // 与原版 CnUDPDataReceived 一致：以 IP:Port 作为进程名
  ProcName := Format('%s:%d', [FromIP, Port]);
  ProcId := StrCRC32(0, ProcName);

  AStore := FMsgManager.FindByProcName(ProcName);
  if AStore = nil then
  begin
    AStore := FMsgManager.AddStore(ProcId, ProcName);
    CreateTabForStore(AStore);
  end;

  FillChar(ADesc, SizeOf(ADesc), 0);
  if Len > CnMaxMsgLength then
    Len := CnMaxMsgLength;
  Move(Buffer^, ADesc.Msg, Len);

  ADesc.Annex.Level := CnDefLevel;
  ADesc.Annex.MsgType := Ord(cmtUDPMsg);
  ADesc.Annex.TimeStampType := Ord(ttDateTime);
  ADesc.Annex.MsgDateTime := Date + Time;
  ADesc.Length := Len + SizeOf(TCnMsgAnnex) + SizeOf(Integer) + 1;

  AStore.AddMsgDesc(@ADesc);
end;

procedure TCnFmxMainViewer.CreateWindowMenuPool;
var
  I: Integer;
begin
  for I := Low(FWinMenuItems) to High(FWinMenuItems) do
  begin
    FWinMenuItems[I] := TMenuItem.Create(Self);
    FWinMenuItems[I].Visible := False;
    FWinMenuItems[I].OnClick := WindowItemClick;
    FWinMenuItems[I].Parent := mniWindow;
  end;
end;

procedure TCnFmxMainViewer.RebuildWindowMenu;
var
  I: Integer;
  Cnt: Integer;
begin
  Cnt := TabControl1.TabCount;
  mniWinNone.Visible := Cnt = 0;

  for I := Low(FWinMenuItems) to High(FWinMenuItems) do
  begin
    FWinMenuItems[I].Visible := I < Cnt;
    if I < Cnt then
    begin
      FWinMenuItems[I].Text := TabControl1.Tabs[I].Text;
      FWinMenuItems[I].Tag := I;
      FWinMenuItems[I].IsChecked := TabControl1.Tabs[I] = TabControl1.ActiveTab;
    end;
  end;

  mniWindow.Enabled := True;
end;

procedure TCnFmxMainViewer.WindowItemClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TComponent).Tag;
  if (Idx >= 0) and (Idx < TabControl1.TabCount) then
  begin
    TabControl1.ActiveTab := TabControl1.Tabs[Idx];
    UpdateMenuAndStatus;
  end;
end;

procedure TCnFmxMainViewer.TabControlChange(Sender: TObject);
begin
  UpdateMenuAndStatus;
end;

procedure TCnFmxMainViewer.UpdateMenuAndStatus;
var
  View: TCnFmxMdiView;
  HasView: Boolean;
begin
  View := CurrentView;
  HasView := View <> nil;

  mniFileSave.Enabled := HasView;
  mniFileClose.Enabled := HasView;
  mniEditCopy.Enabled := HasView;
  mniEditClear.Enabled := HasView;
  mniEditClearTime.Enabled := HasView;
  mniViewDetail.Enabled := HasView;
  mniViewTime.Enabled := HasView;
  mniViewFirst.Enabled := HasView;
  mniViewPrev.Enabled := HasView;
  mniViewNext.Enabled := HasView;
  mniViewLast.Enabled := HasView;
  mniEditFindNext.Enabled := HasView;
  mniFileExport.Enabled := HasView;

  // Control 菜单随捕获状态启停
  mniCtrlStart.Enabled := FRunState = crsStopped;
  mniCtrlPause.Enabled := FRunState <> crsStopped;
  mniCtrlPause.IsChecked := FRunState = crsPaused;
  mniCtrlStop.Enabled := FRunState <> crsStopped;

  mniEditBmToggle.Enabled := HasView;
  mniEditBmPrev.Enabled := HasView and View.HasBookmarks;
  mniEditBmNext.Enabled := HasView and View.HasBookmarks;
  mniEditBmClear.Enabled := HasView and View.HasBookmarks;

  if HasView then
  begin
    mniViewDetail.IsChecked := View.DetailPanelVisible;
    mniViewTime.IsChecked := View.TimePanelVisible;
    if View.ProcName <> '' then
      lblStatusLeft.Text := ExtractFileName(View.ProcName) + ' ($' +
        IntToHex(View.ProcessID, 2) + ')'
    else
      lblStatusLeft.Text := SCnNoneProcName;
    if View.MsgStore <> nil then
      lblStatusRight.Text := Format('%d Messages', [View.MsgStore.MsgCount])
    else
      lblStatusRight.Text := '';
  end
  else
  begin
    lblStatusLeft.Text := '';
    lblStatusRight.Text := '';
  end;

  RebuildWindowMenu;
end;

end.
