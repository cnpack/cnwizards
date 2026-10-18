unit CnFmxMdiView;
{ CnMacDebugViewer 子视图 Frame：FMX 虚拟多栏列表版本的 CnMdiView。
  数据逻辑完全复用 CnMsgClasses / CnViewCore / CnDebugIntf，
  显示层用 TGrid 虚拟模式（RowCount + OnGetValue + OnDrawColumnCell），
  每条消息恰好对应一行，树形层级以消息列内缩进绘制还原。 }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Rtti,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Memo, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid,
  CnMsgClasses, CnDebugIntf, CnViewCore;

type
  { 条件列表变更类型 }
  TCnFilterUpdate = (fuThreadId, fuTag);
  TCnFilterUpdates = set of TCnFilterUpdate;

  TCnFmxMdiView = class(TFrame)
    LayoutFilter: TLayout;
    cbbLevel: TComboBox;
    cbbType: TComboBox;
    cbbThread: TComboBox;
    cbbTag: TComboBox;
    edtSearch: TEdit;
    btnSearch: TSpeedButton;
    LayoutBottom: TLayout;
    LayoutTime: TLayout;
    GridTime: TGrid;
    ColumnTimeIndex: TIntegerColumn;
    ColumnTimeCnt: TStringColumn;
    ColumnTimeSum: TStringColumn;
    ColumnTimeAve: TStringColumn;
    ColumnTimeMax: TStringColumn;
    ColumnTimeMin: TStringColumn;
    ColumnTimeTag: TStringColumn;
    mmoDetail: TMemo;
    GridMsg: TGrid;
    ColumnIndex: TIntegerColumn;
    ColumnMsg: TStringColumn;
    ColumnType: TStringColumn;
    ColumnLevel: TIntegerColumn;
    ColumnThread: TStringColumn;
    ColumnTag: TStringColumn;
    ColumnTime: TStringColumn;
  private
    FStore: TCnMsgStore;           // 外部（MsgManager）管理的数据源
    FViewStore: TCnMsgStore;       // 过滤后的显示缓存，条目是引用
    FFilter: TCnDisplayFilter;
    FProcessID: DWORD;
    FProcName: string;
    FSelectedIndex: Integer;       // 消息 Grid 当前选中行（ViewStore 索引）
    FTimeSelectedIndex: Integer;   // 时间 Grid 当前选中行
    FBookmarks: array[0..9] of Integer;
    FHasBookmarks: Boolean;
    FTimeVisible: Boolean;
    FDetailVisible: Boolean;
    FOnProcessInfoChanged: TNotifyEvent;

    procedure SetMsgStore(const Value: TCnMsgStore);
    procedure UpdateBottomLayoutHeight;
    procedure SetTimePanelVisible(const Value: Boolean);
    procedure SetDetailPanelVisible(const Value: Boolean);
    procedure MsgStoreChange(Sender: TObject; Operation: TCnStoreChangeType;
      StartIndex, EndIndex: Integer);
    procedure InitControls;
    procedure InitColumns;
    procedure UpdateToViewStore(Source, Dest: TCnMsgStore);
    procedure UpdateConditionsToView(Content: TCnFilterUpdates);
    procedure AddBatchItemToView(AStore: TCnMsgStore; StartIndex, EndIndex: Integer);
    procedure RefreshTime;
    procedure SelectIndex(Index: Integer);
    function GetAnEmptyBookmarkSlot: Integer;
    function GetSlotFromBookmarkLine(ALine: Integer): Integer;
    procedure RefreshHasBookmarks;
    procedure FilterChange(Sender: TObject);
    procedure GridMsgGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
    procedure GridMsgDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure GridMsgSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure GridTimeGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
    procedure GridTimeDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure GridTimeSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure btnSearchClick(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FrameResize(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReloadFromStore;
    procedure ClearStores;
    procedure ClearTimes;
    procedure FindNode(const AText: string; IsDown: Boolean; IsSeperator: Boolean = False);
    function CheckFind(AItem: TCnMsgItem; const AText: string; IsSeperator: Boolean = False): Boolean;
    function DescriptionOfMsg(Index: Integer; AMsgItem: TCnMsgItem): string;
    function DescriptionOfTime(Index: Integer): string;
    procedure ToggleBookmark;
    procedure GotoPrevBookmark;
    procedure GotoNextBookmark;
    procedure ClearAllBookmarks;
    procedure GotoRow(ARow: Integer);
    procedure GotoNeighbor(ADelta: Integer);
    procedure FindNextMessage;
    function GetSelectedContent: string;
    procedure SetSearchFocus;

    property MsgStore: TCnMsgStore read FStore write SetMsgStore;
    property Filter: TCnDisplayFilter read FFilter;
    property ProcessID: DWORD read FProcessID write FProcessID;
    property ProcName: string read FProcName write FProcName;
    property SelectedIndex: Integer read FSelectedIndex;
    property HasBookmarks: Boolean read FHasBookmarks;
    property TimePanelVisible: Boolean read FTimeVisible write SetTimePanelVisible;
    property DetailPanelVisible: Boolean read FDetailVisible write SetDetailPanelVisible;
    property OnProcessInfoChanged: TNotifyEvent read FOnProcessInfoChanged write FOnProcessInfoChanged;
  end;

implementation

{$R *.fmx}

const
  CnBookmarkColor = $FF66CC66;   // 书签行底色（对应 VCL clMoneyGreen 系）
  CnSelectColor   = $FF87CEFA;   // 选中行底色 LightSkyBlue
  CnWarningColor  = $FFFF8C00;   // Warning 文字色 DarkOrange
  CnMsgIndentSize = 16;          // 缩进单位像素
  CnDetailHeight  = 230;

{ TCnFmxMdiView }

constructor TCnFmxMdiView.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  FViewStore := TCnMsgStore.Create(nil, False);
  FFilter := TCnDisplayFilter.Create;
  FSelectedIndex := -1;
  FTimeSelectedIndex := -1;
  FTimeVisible := True;
  FDetailVisible := True;
  for I := Low(FBookmarks) to High(FBookmarks) do
    FBookmarks[I] := CnInvalidLine;

  GridMsg.OnGetValue := GridMsgGetValue;
  GridMsg.OnDrawColumnCell := GridMsgDrawColumnCell;
  GridMsg.OnSelectCell := GridMsgSelectCell;
  GridTime.OnGetValue := GridTimeGetValue;
  GridTime.OnDrawColumnCell := GridTimeDrawColumnCell;
  GridTime.OnSelectCell := GridTimeSelectCell;
  cbbLevel.OnChange := FilterChange;
  cbbType.OnChange := FilterChange;
  cbbThread.OnChange := FilterChange;
  cbbTag.OnChange := FilterChange;
  btnSearch.OnClick := btnSearchClick;
  edtSearch.OnKeyDown := edtSearchKeyDown;
  OnResize := FrameResize;

  InitControls;
  UpdateBottomLayoutHeight;
end;

destructor TCnFmxMdiView.Destroy;
begin
  if FStore <> nil then
    FStore.OnChange := nil;
  FFilter.Free;
  FViewStore.Free;
  inherited;
end;

procedure TCnFmxMdiView.InitControls;
var
  I: Integer;
begin
  cbbLevel.Items.Clear;
  for I := CnDefLevel downto 0 do
    cbbLevel.Items.Add('<=' + IntToStr(I));
  cbbLevel.ItemIndex := 0;

  cbbType.Items.Clear;
  cbbType.Items.Add(SCnMsgTypeNone);
  for I := Low(CnMsgTypesArray) to High(CnMsgTypesArray) do
    cbbType.Items.Add(String(SCnMsgTypesDescArray[I]^));
  cbbType.ItemIndex := 0;

  cbbThread.Items.Clear;
  cbbThread.Items.Add('*');
  cbbThread.ItemIndex := 0;

  cbbTag.Items.Clear;
  cbbTag.Items.Add('');
  cbbTag.ItemIndex := 0;

  InitColumns;
end;

procedure TCnFmxMdiView.InitColumns;
var
  I: Integer;
  Cols: array[0..6] of TColumn;
  TimeCols: array[0..6] of TColumn;
begin
  Cols[0] := ColumnIndex;
  Cols[1] := ColumnMsg;
  Cols[2] := ColumnType;
  Cols[3] := ColumnLevel;
  Cols[4] := ColumnThread;
  Cols[5] := ColumnTag;
  Cols[6] := ColumnTime;
  for I := Low(SCnTreeColumnArray) to High(SCnTreeColumnArray) do
    Cols[I].Header := String(SCnTreeColumnArray[I]^);

  TimeCols[0] := ColumnTimeIndex;
  TimeCols[1] := ColumnTimeCnt;
  TimeCols[2] := ColumnTimeSum;
  TimeCols[3] := ColumnTimeAve;
  TimeCols[4] := ColumnTimeMax;
  TimeCols[5] := ColumnTimeMin;
  TimeCols[6] := ColumnTimeTag;
  for I := Low(SCnTimeColumnArray) to High(SCnTimeColumnArray) do
    TimeCols[I].Header := String(SCnTimeColumnArray[I]^);
end;

procedure TCnFmxMdiView.SetMsgStore(const Value: TCnMsgStore);
begin
  if FStore <> Value then
  begin
    if FStore <> nil then
      FStore.OnChange := nil;

    FStore := Value;
    GridMsg.RowCount := 0;
    GridTime.RowCount := 0;
    FViewStore.ClearMsgs;
    FSelectedIndex := -1;
    FTimeSelectedIndex := -1;
    mmoDetail.Text := '';

    if FStore <> nil then
    begin
      FStore.OnChange := MsgStoreChange;
      FProcessID := FStore.ProcessID;
      FProcName := FStore.ProcName;
      ReloadFromStore;
    end;

    if Assigned(FOnProcessInfoChanged) then
      FOnProcessInfoChanged(Self);
  end;
end;

procedure TCnFmxMdiView.MsgStoreChange(Sender: TObject; Operation: TCnStoreChangeType;
  StartIndex, EndIndex: Integer);
begin
  if Sender is TCnMsgStore then
    case Operation of
      ctProcess:
        begin
          FProcessID := (Sender as TCnMsgStore).ProcessID;
          FProcName := (Sender as TCnMsgStore).ProcName;
          if Assigned(FOnProcessInfoChanged) then
            FOnProcessInfoChanged(Self);
        end;
      ctAdd:
        AddBatchItemToView(Sender as TCnMsgStore, StartIndex, EndIndex);
      ctTimeChanged:
        RefreshTime;
    else
      ;
    end;
end;

procedure TCnFmxMdiView.ReloadFromStore;
begin
  FViewStore.ClearMsgs;
  GridMsg.RowCount := 0;
  if FStore <> nil then
    AddBatchItemToView(FStore, 0, FStore.MsgCount - 1);
  RefreshTime;
end;

procedure TCnFmxMdiView.ClearStores;
begin
  // 先清引用缓存再清源，避免悬挂引用
  FViewStore.ClearMsgs;
  GridMsg.RowCount := 0;
  FSelectedIndex := -1;
  mmoDetail.Text := '';
  if FStore <> nil then
    FStore.ClearMsgs;
end;

procedure TCnFmxMdiView.ClearTimes;
begin
  if FStore <> nil then
    FStore.ClearTimes;
  GridTime.RowCount := 0;
  FTimeSelectedIndex := -1;
end;

procedure TCnFmxMdiView.RefreshTime;
begin
  if FStore = nil then
    GridTime.RowCount := 0
  else
  begin
    GridTime.RowCount := 0;
    GridTime.RowCount := FStore.TimeCount;
  end;
end;

procedure TCnFmxMdiView.UpdateToViewStore(Source, Dest: TCnMsgStore);
var
  I: Integer;
begin
  if (Source = nil) or (Dest = nil) then
    Exit;

  Dest.ClearMsgs;
  for I := 0 to Source.MsgCount - 1 do
    if FFilter.CheckVisible(Source.Msgs[I]) then
      Dest.AddAMsgItem(Source.Msgs[I]);
end;

procedure TCnFmxMdiView.UpdateConditionsToView(Content: TCnFilterUpdates);
var
  I, OldItemIndex: Integer;
  OldOnChange: TNotifyEvent;
begin
  if fuThreadId in Content then
  begin
    OldOnChange := cbbThread.OnChange;
    try
      OldItemIndex := cbbThread.ItemIndex;
      cbbThread.OnChange := nil;
      cbbThread.Items.BeginUpdate;
      cbbThread.Items.Clear;
      cbbThread.Items.Add('*');
      for I := 0 to FFilter.Conditions.ThreadIDs.Count - 1 do
        if FFilter.Conditions.ThreadIDs[I] <> nil then
          cbbThread.Items.Add('$' + IntToHex(Cardinal(NativeUInt(FFilter.Conditions.ThreadIDs[I])), 2));
      if (cbbThread.Items.Count > 0) and (OldItemIndex >= 0)
        and (OldItemIndex < cbbThread.Items.Count) then
        cbbThread.ItemIndex := OldItemIndex;
    finally
      cbbThread.Items.EndUpdate;
      cbbThread.OnChange := OldOnChange;
    end;
  end;

  if fuTag in Content then
  begin
    OldOnChange := cbbTag.OnChange;
    try
      OldItemIndex := cbbTag.ItemIndex;
      if OldItemIndex < 0 then
        OldItemIndex := 0;
      cbbTag.OnChange := nil;
      cbbTag.Items.BeginUpdate;
      cbbTag.Items.Clear;
      for I := 0 to FFilter.Conditions.Tags.Count - 1 do
        cbbTag.Items.Add(FFilter.Conditions.Tags[I]);
      if (cbbTag.Items.Count > 0) and (OldItemIndex < cbbTag.Items.Count) then
        cbbTag.ItemIndex := OldItemIndex;
    finally
      cbbTag.Items.EndUpdate;
      cbbTag.OnChange := OldOnChange;
    end;
  end;
end;

procedure TCnFmxMdiView.AddBatchItemToView(AStore: TCnMsgStore; StartIndex, EndIndex: Integer);
var
  I, Slot: Integer;
  UpdateContent: TCnFilterUpdates;
  AMsgItem: TCnMsgItem;
begin
  if (AStore = nil) or (StartIndex < 0) or (EndIndex < StartIndex) then
    Exit;

  for I := StartIndex to EndIndex do
  begin
    AMsgItem := AStore.Msgs[I];
    if AMsgItem = nil then
      Continue;

    UpdateContent := [];
    if FFilter.Conditions.CheckAndAddThreadID(AMsgItem.ThreadId) then
      Include(UpdateContent, fuThreadId);
    if FFilter.Conditions.CheckAndAddTag(AMsgItem.Tag) then
      Include(UpdateContent, fuTag);
    UpdateConditionsToView(UpdateContent);

    if FFilter.Filtered and not FFilter.CheckVisible(AMsgItem) then
      Continue; // 此条不可见则不处理

    FViewStore.AddAMsgItem(AMsgItem);

    if AMsgItem.Bookmarked then
    begin
      FHasBookmarks := True;
      Slot := GetAnEmptyBookmarkSlot;
      if Slot <> CnInvalidSlot then
        FBookmarks[Slot] := FViewStore.MsgCount - 1; // 书签行号就是 ViewStore 索引
    end;
  end;

  GridMsg.RowCount := FViewStore.MsgCount;
  if CnViewerOptions.AutoScroll and (FViewStore.MsgCount > 0) then
    SelectIndex(FViewStore.MsgCount - 1);
end;

procedure TCnFmxMdiView.FilterChange(Sender: TObject);
begin
  if Sender = cbbType then
  begin
    if (cbbType.ItemIndex >= 0) and (cbbType.ItemIndex <= High(CnMsgTypesArray)) then
      FFilter.MsgTypes := CnMsgTypesArray[cbbType.ItemIndex];
  end
  else if Sender = cbbThread then
  begin
    if cbbThread.ItemIndex <= 0 then
      FFilter.ThreadId := 0
    else if cbbThread.ItemIndex < FFilter.Conditions.ThreadIDs.Count then
      FFilter.ThreadId := Cardinal(NativeUInt(FFilter.Conditions.ThreadIDs[cbbThread.ItemIndex]));
  end
  else if Sender = cbbLevel then
  begin
    if cbbLevel.ItemIndex >= 0 then
      FFilter.Level := CnDefLevel - cbbLevel.ItemIndex;
  end
  else if Sender = cbbTag then
  begin
    // FMX 的 TComboBox 无 Text 属性，用 Selected 取选中项文本
    if (cbbTag.ItemIndex <= 0) or (cbbTag.Selected = nil) then
      FFilter.Tag := ''
    else
      FFilter.Tag := cbbTag.Selected.Text;
  end;

  UpdateToViewStore(FStore, FViewStore);
  GridMsg.RowCount := 0;
  GridMsg.RowCount := FViewStore.MsgCount;
  FSelectedIndex := -1;
  mmoDetail.Text := '';
end;

procedure TCnFmxMdiView.SelectIndex(Index: Integer);
begin
  if (FViewStore = nil) or (Index < 0) or (Index >= FViewStore.MsgCount) then
    Exit;

  FSelectedIndex := Index;
  GridMsg.Row := Index; // 属性赋值会滚动到可见位置
  mmoDetail.Text := DescriptionOfMsg(Index, FViewStore.Msgs[Index]);
end;

procedure TCnFmxMdiView.GotoRow(ARow: Integer);
begin
  if (FViewStore = nil) or (FViewStore.MsgCount = 0) then
    Exit;
  if ARow < 0 then
    ARow := 0;
  if ARow >= FViewStore.MsgCount then
    ARow := FViewStore.MsgCount - 1;
  SelectIndex(ARow);
end;

procedure TCnFmxMdiView.GotoNeighbor(ADelta: Integer);
begin
  if FSelectedIndex < 0 then
    GotoRow(0)
  else
    GotoRow(FSelectedIndex + ADelta);
end;

procedure TCnFmxMdiView.FindNextMessage;
begin
  FindNode(edtSearch.Text, True);
end;

procedure TCnFmxMdiView.GridMsgGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
var
  Item: TCnMsgItem;
begin
  if (FViewStore = nil) or (Row < 0) or (Row >= FViewStore.MsgCount) then
    Exit;
  Item := FViewStore.Msgs[Row];
  if Item = nil then
    Exit;

  case Col of
    0: Value := Row + 1;
    1: Value := Item.Msg;
    2: Value := String(SCnMsgTypeDescArray[Item.MsgType]^);
    3: Value := Item.Level;
    4: Value := '$' + IntToHex(Item.ThreadId, 2);
    5: Value := Item.Tag;
    6: Value := GetTimeDesc(Item);
  else
    Value := '';
  end;
end;

procedure TCnFmxMdiView.GridMsgDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
var
  Item: TCnMsgItem;
  BkColor: TAlphaColor;
  R: TRectF;
  LineY: Single;
begin
  if (FViewStore = nil) or (Row < 0) or (Row >= FViewStore.MsgCount) then
    Exit;
  Item := FViewStore.Msgs[Row];
  if Item = nil then
    Exit;

  if Item.Bookmarked then
    BkColor := CnBookmarkColor
  else if Row = FSelectedIndex then
    BkColor := CnSelectColor
  else
    BkColor := TAlphaColors.White;

  Canvas.Fill.Color := BkColor;
  Canvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  Canvas.Font.Size := 13;
  Canvas.Fill.Color := TAlphaColors.Black;
  case Item.MsgType of
    cmtError:   Canvas.Fill.Color := TAlphaColors.Red;
    cmtWarning: Canvas.Fill.Color := CnWarningColor;
  end;

  if (Item.MsgType = cmtSeparator) and (Column = ColumnMsg) then
  begin
    // Separator 行：画整行红色横线
    LineY := (Bounds.Top + Bounds.Bottom) / 2;
    Canvas.Stroke.Color := TAlphaColors.Red;
    Canvas.Stroke.Thickness := 1.5;
    Canvas.DrawLine(PointF(Bounds.Left + 2, LineY), PointF(Bounds.Right, LineY), 1);
  end
  else
  begin
    R := Bounds;
    if Column = ColumnIndex then
      R.Left := R.Left + 4
    else if Column = ColumnMsg then
      R.Left := R.Left + Item.Indent * CnMsgIndentSize + 2 // 树形层级缩进
    else
      R.Left := R.Left + 4;
    Canvas.FillText(R, Value.ToString, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
  end;
end;

procedure TCnFmxMdiView.GridMsgSelectCell(Sender: TObject; const ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (FViewStore <> nil) and (ARow >= 0) and (ARow < FViewStore.MsgCount) then
  begin
    FSelectedIndex := ARow;
    mmoDetail.Text := DescriptionOfMsg(ARow, FViewStore.Msgs[ARow]);
  end;
  CanSelect := True;
end;

procedure TCnFmxMdiView.GridTimeGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
var
  ATimeItem: TCnTimeItem;
begin
  if (FStore = nil) or (Row < 0) or (Row >= FStore.TimeCount) then
    Exit;
  ATimeItem := FStore.Times[Row];
  if ATimeItem = nil then
    Exit;

  case Col of
    0: Value := Row + 1;
    1: Value := IntToStr(ATimeItem.PassCount);
    2: Value := Format('%f', [ATimeItem.CPUPeriod / CPUClock]);
    3: Value := Format('%f', [ATimeItem.AvePeriod / CPUClock]);
    4: Value := Format('%f', [ATimeItem.MaxPeriod / CPUClock]);
    5: Value := Format('%f', [ATimeItem.MinPeriod / CPUClock]);
    6: Value := ATimeItem.Tag;
  else
    Value := '';
  end;
end;

procedure TCnFmxMdiView.GridTimeDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
var
  R: TRectF;
begin
  if (FStore = nil) or (Row < 0) or (Row >= FStore.TimeCount) then
    Exit;

  if Row = FTimeSelectedIndex then
    Canvas.Fill.Color := CnSelectColor
  else
    Canvas.Fill.Color := TAlphaColors.White;
  Canvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  Canvas.Font.Size := 13;
  Canvas.Fill.Color := TAlphaColors.Black;
  R := Bounds;
  R.Left := R.Left + 4;
  Canvas.FillText(R, Value.ToString, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
end;

procedure TCnFmxMdiView.GridTimeSelectCell(Sender: TObject; const ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (FStore <> nil) and (ARow >= 0) and (ARow < FStore.TimeCount) then
  begin
    FTimeSelectedIndex := ARow;
    mmoDetail.Text := DescriptionOfTime(ARow);
  end;
  CanSelect := True;
end;

procedure TCnFmxMdiView.FrameResize(Sender: TObject);
var
  W: Single;
begin
  // 消息列自动占满剩余宽度
  W := GridMsg.Width - 10
    - ColumnIndex.Width - ColumnType.Width - ColumnLevel.Width
    - ColumnThread.Width - ColumnTag.Width - ColumnTime.Width;
  if W > 80 then
    ColumnMsg.Width := W;
end;

function TCnFmxMdiView.CheckFind(AItem: TCnMsgItem; const AText: string;
  IsSeperator: Boolean): Boolean;
var
  S1, S2: string;
begin
  S1 := UpperCase(AText);
  if IsSeperator then
    Result := (AItem.MsgType = cmtSeparator) and (Pos(S1, UpperCase(AItem.Msg)) > 0)
  else
  begin
    S2 := UpperCase(AItem.Msg);
    Result := Pos(S1, S2) > 0;
    if not Result and (AItem.Tag <> '') then
      Result := Pos(S1, UpperCase(AItem.Tag)) > 0;
  end;
end;

procedure TCnFmxMdiView.FindNode(const AText: string; IsDown: Boolean;
  IsSeperator: Boolean);
var
  I, I0: Integer;
begin
  if (AText = '') or (FViewStore = nil) then
    Exit;

  if IsDown then
  begin
    if FSelectedIndex >= 0 then
      I0 := FSelectedIndex + 1
    else
      I0 := 0;
    for I := I0 to FViewStore.MsgCount - 1 do
      if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
      begin
        SelectIndex(I);
        Exit;
      end;
    for I := 0 to I0 - 1 do
      if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
      begin
        SelectIndex(I);
        Exit;
      end;
  end
  else
  begin
    if FSelectedIndex <= 0 then
      Exit;
    for I := FSelectedIndex - 1 downto 0 do
      if CheckFind(FViewStore.Msgs[I], AText, IsSeperator) then
      begin
        SelectIndex(I);
        Exit;
      end;
  end;

  ErrorDlg(SCnNotFound);
end;

function TCnFmxMdiView.DescriptionOfMsg(Index: Integer; AMsgItem: TCnMsgItem): string;
begin
  if AMsgItem <> nil then
    Result := Format(SCnMsgDescriptionFmt, [Index + 1, AMsgItem.Indent,
      AMsgItem.Level, AMsgItem.ThreadId, AMsgItem.ProcessId, AMsgItem.Tag,
      GetLongTimeDesc(AMsgItem), AMsgItem.Msg])
  else
    Result := '';
end;

function TCnFmxMdiView.DescriptionOfTime(Index: Integer): string;
var
  dTime, aTime, MaxTime, MinTime: Double;
begin
  Result := '';
  if (FStore = nil) or (Index < 0) or (Index >= FStore.TimeCount) then
    Exit;

  dTime := FStore.Times[Index].CPUPeriod / CPUClock;
  aTime := FStore.Times[Index].AvePeriod / CPUClock;
  MaxTime := FStore.Times[Index].MaxPeriod / CPUClock;
  MinTime := FStore.Times[Index].MinPeriod / CPUClock;

  Result := Format(SCnTimeDescriptionFmt, [Index + 1, FStore.Times[Index].PassCount,
    dTime, aTime, MaxTime, MinTime, FStore.Times[Index].Tag]);
end;

function TCnFmxMdiView.GetAnEmptyBookmarkSlot: Integer;
var
  I: Integer;
begin
  Result := CnInvalidSlot;
  for I := Low(FBookmarks) to High(FBookmarks) do
    if FBookmarks[I] = CnInvalidLine then
    begin
      Result := I;
      Exit;
    end;
end;

function TCnFmxMdiView.GetSlotFromBookmarkLine(ALine: Integer): Integer;
var
  I: Integer;
begin
  Result := CnInvalidSlot;
  for I := Low(FBookmarks) to High(FBookmarks) do
    if FBookmarks[I] = ALine then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TCnFmxMdiView.RefreshHasBookmarks;
var
  I: Integer;
begin
  FHasBookmarks := False;
  for I := Low(FBookmarks) to High(FBookmarks) do
    if FBookmarks[I] <> CnInvalidLine then
    begin
      FHasBookmarks := True;
      Exit;
    end;
end;

procedure TCnFmxMdiView.ToggleBookmark;
var
  Slot: Integer;
begin
  if (FViewStore = nil) or (FSelectedIndex < 0) or (FSelectedIndex >= FViewStore.MsgCount) then
    Exit;

  Slot := GetSlotFromBookmarkLine(FSelectedIndex);
  if Slot = CnInvalidSlot then
  begin
    Slot := GetAnEmptyBookmarkSlot;
    if Slot <> CnInvalidSlot then
    begin
      FViewStore.Msgs[FSelectedIndex].Bookmarked := True;
      FBookmarks[Slot] := FSelectedIndex;
      FHasBookmarks := True;
    end
    else
      ErrorDlg(SCnBookmarkFull);
  end
  else
  begin
    if (FBookmarks[Slot] >= 0) and (FBookmarks[Slot] < FViewStore.MsgCount) then
      FViewStore.Msgs[FBookmarks[Slot]].Bookmarked := False;
    FBookmarks[Slot] := CnInvalidLine;
    RefreshHasBookmarks;
  end;

  GridMsg.RowCount := 0;
  GridMsg.RowCount := FViewStore.MsgCount;
  if FSelectedIndex >= 0 then
    GridMsg.Row := FSelectedIndex;
end;

procedure TCnFmxMdiView.GotoPrevBookmark;
var
  I: Integer;
begin
  if (FViewStore = nil) or (FViewStore.MsgCount = 0) then
    Exit;
  if FSelectedIndex <= 0 then
    Exit;

  for I := FSelectedIndex - 1 downto 0 do
    if FViewStore.Msgs[I].Bookmarked then
    begin
      SelectIndex(I);
      Exit;
    end;
end;

procedure TCnFmxMdiView.GotoNextBookmark;
var
  I: Integer;
begin
  if (FViewStore = nil) or (FViewStore.MsgCount = 0) then
    Exit;

  if FSelectedIndex < 0 then
  begin
    for I := 0 to FViewStore.MsgCount - 1 do
      if FViewStore.Msgs[I].Bookmarked then
      begin
        SelectIndex(I);
        Exit;
      end;
  end
  else
    for I := FSelectedIndex + 1 to FViewStore.MsgCount - 1 do
      if FViewStore.Msgs[I].Bookmarked then
      begin
        SelectIndex(I);
        Exit;
      end;
end;

procedure TCnFmxMdiView.ClearAllBookmarks;
var
  I: Integer;
begin
  for I := Low(FBookmarks) to High(FBookmarks) do
  begin
    if (FBookmarks[I] <> CnInvalidLine) and (FViewStore <> nil)
      and (FBookmarks[I] >= 0) and (FBookmarks[I] < FViewStore.MsgCount) then
      FViewStore.Msgs[FBookmarks[I]].Bookmarked := False;
    FBookmarks[I] := CnInvalidLine;
  end;
  FHasBookmarks := False;

  GridMsg.RowCount := 0;
  GridMsg.RowCount := FViewStore.MsgCount;
  if FSelectedIndex >= 0 then
    GridMsg.Row := FSelectedIndex;
end;

procedure TCnFmxMdiView.UpdateBottomLayoutHeight;
begin
  // 底部区域 = 计时面板 + 详情面板，按可见状态调整总高
  LayoutTime.Visible := FTimeVisible;
  if FTimeVisible and FDetailVisible then
    LayoutBottom.Height := CnDetailHeight          // 140 + 90
  else if FTimeVisible then
    LayoutBottom.Height := 140
  else if FDetailVisible then
    LayoutBottom.Height := 90
  else
    LayoutBottom.Height := 0;
end;

procedure TCnFmxMdiView.SetTimePanelVisible(const Value: Boolean);
begin
  if FTimeVisible <> Value then
  begin
    FTimeVisible := Value;
    UpdateBottomLayoutHeight;
  end;
end;

procedure TCnFmxMdiView.SetDetailPanelVisible(const Value: Boolean);
begin
  if FDetailVisible <> Value then
  begin
    FDetailVisible := Value;
    UpdateBottomLayoutHeight;
  end;
end;

function TCnFmxMdiView.GetSelectedContent: string;
begin
  // 优先返回消息详情，其次时间详情（对应原版 SelectedContent/FMemContent）
  if (FViewStore <> nil) and (FSelectedIndex >= 0) and (FSelectedIndex < FViewStore.MsgCount) then
    Result := DescriptionOfMsg(FSelectedIndex, FViewStore.Msgs[FSelectedIndex])
  else if (FStore <> nil) and (FTimeSelectedIndex >= 0) and (FTimeSelectedIndex < FStore.TimeCount) then
    Result := DescriptionOfTime(FTimeSelectedIndex)
  else
    Result := '';
end;

procedure TCnFmxMdiView.SetSearchFocus;
begin
  edtSearch.SetFocus;
end;

procedure TCnFmxMdiView.btnSearchClick(Sender: TObject);
begin
  if Trim(edtSearch.Text) <> '' then
  begin
    FindNode(edtSearch.Text, True);
    AddSearchHistoryItems(edtSearch.Text);
  end;
end;

procedure TCnFmxMdiView.edtSearchKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) or (KeyChar = #13) then
  begin
    btnSearchClick(btnSearch);
    Key := 0;
    KeyChar := #0;
  end;
end;

end.
