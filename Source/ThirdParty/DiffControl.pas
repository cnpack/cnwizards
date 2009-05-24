unit DiffControl;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ShellAPI;

type

  TDropFilesEvent = procedure(Sender: TObject;
    dropHandle: Integer; var DropHandled: Boolean) of object;

  TDiffLines = class(TStringList)
  private
    function GetClrIndex(Index: Integer): Integer;
    procedure SetClrIndex(Index, NewClrIndex: Integer);
    function GetLineNum(Index: Integer): Integer;
    procedure SetLineNum(Index, NewLineNum: Integer);
  public
    function AddLineInfo(const S: string; LineNum, ClrIndex: Integer): Integer;
    procedure InsertLineInfo(Index: Integer; const S: string; LineNum, ClrIndex:
      Integer);
    property ColorIndex[Index: Integer]: Integer read GetClrIndex write SetClrIndex;
    property LineNum[Index: Integer]: Integer read GetLineNum write SetLineNum;
  end;

  TDiffControl = class(TCustomControl)
  private
    fAveCharWidth: Integer;
    fLineHeight: Integer;
    fVertDelta, fHorzDelta: Integer;
    fVertExponent: Integer;
    fNumWidth: Integer;
    FLines: TDiffLines;
    fUseFocusRect: Boolean;
    fFocusStart,
      fFocusEnd: Integer;
    fColors: array[0..15] of TColor;
    fOnScroll: TNotifyEvent;
    fOnDropFiles: TDropFilesEvent;
    procedure VertKey(Key: WORD);
    procedure HorzKey(Key: WORD);
    function GetTopLine: Integer;
    procedure SetTopLine(TopLine: Integer);
    function GetHorzScroll: Integer;
    procedure SetHorzScroll(HorzScroll: Integer);
    function GetVisibleLines: Integer;
    function GetColor(Index: Integer): TColor;
    procedure SetColor(Index: Integer; NewColor: TColor);
    procedure SetMaxLineNum(MaxLineNum: Integer);
    procedure SetFocusStart(FocusStart: Integer);
    function GetFocusLength: Integer;
    procedure UpdateScrollbars;
    procedure UpdateFocus(FromTop: Boolean);
    function NextVisibleFocus: Boolean;
    function PriorVisibleFocus: Boolean;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure LinesChanged(Sender: TObject);
    procedure KeyDown(var Key: WORD; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSetFont(var message: TMessage); message WM_SETFONT;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMVScroll(var message: TWMScroll); message WM_VSCROLL;
    procedure WMHScroll(var message: TWMScroll); message WM_HSCROLL;
    procedure WMSetFocus(var message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMSize(var message: TWMSize); message WM_SIZE;
    procedure WMMouseWheel(var message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMDropFiles(var message: TWMDropFiles); message WM_DROPFILES;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure KillFocus;
    function ClientPtToTextPoint(pt: TPoint): TPoint;
    function GotoNextDiff: Boolean;
    function GotoPrioDiff: Boolean;
    property LineHeight: Integer read fLineHeight;
    property TopVisibleLine: Integer read GetTopLine write SetTopLine;
    //HorzScroll - horizontal pixel offset
    property HorzScroll: Integer read GetHorzScroll write SetHorzScroll;
    property VisibleLines: Integer read GetVisibleLines;
    //LineColors - array of up to 15 background colors ...
    property LineColors[Index: Integer]: TColor read GetColor write SetColor;
    //FocusStart - index of first focused line...
    property FocusStart: Integer read fFocusStart write SetFocusStart;
    property FocusLength: Integer read GetFocusLength;
  published
    property Align;
    property Ctl3D;
    property Color;
    property Font;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property Lines: TDiffLines read FLines;
    property UseFocusRect: Boolean read fUseFocusRect write fUseFocusRect;
    //MaxLineNum - maximum *displayed* line number ...
    property MaxLineNum: Integer write SetMaxLineNum;
    property OnScroll: TNotifyEvent read fOnScroll write fOnScroll;
    property OnDropFiles: TDropFilesEvent read fOnDropFiles write fOnDropFiles;
  end;

const
  DIFF_COLOR_MASK = $F0000000;
  DIFF_NUM_MASK = not DIFF_COLOR_MASK;

procedure Register;

function Min(a, b: Integer): Integer;
function Max(a, b: Integer): Integer;

implementation

const
  LEFTOFFSET = 4;
  TOPOFFSET = 2;

  csWheelLines = 3;                     // 鼠标轮滚动的行数
  csDiffTopLines = 3;                   // 在差异块中跳转时页首保留的行数

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..(MaxInt div SizeOf(Integer)) - 1] of Integer;

resourcestring
  s_out_of_range_error = 'DiffControl: Index is out of range.';

procedure Register;
begin
  RegisterComponents('Samples', [TDiffControl]);
end;

//--------------------------------------------------------------------------
// Miscellaneous functions ...
//--------------------------------------------------------------------------

function GetNumWidth(Int: Integer): Integer;
begin
  Result := 1;
  while Int > 9 do
  begin
    Inc(Result);
    Int := Int div 10;
  end;
end;
//--------------------------------------------------------------------------

function Max(a, b: Integer): Integer;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;
//--------------------------------------------------------------------------

function Min(a, b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

//--------------------------------------------------------------------------
// TDiffLines class methods ...                                            .
//--------------------------------------------------------------------------

function TDiffLines.GetClrIndex(Index: Integer): Integer;
begin
  if (Index < 0) or (Index > Count) then Exception.Create(s_out_of_range_error);
  Result := Integer(objects[Index]) shr 28;
end;
//--------------------------------------------------------------------------

procedure TDiffLines.SetClrIndex(Index, NewClrIndex: Integer);
begin
  if (Index < 0) or (Index > Count) then Exception.Create(s_out_of_range_error);
  objects[Index] :=
    Pointer((Integer(objects[Index]) and DIFF_NUM_MASK) or ((NewClrIndex and $F) shl 28));
end;
//--------------------------------------------------------------------------

function TDiffLines.GetLineNum(Index: Integer): Integer;
begin
  if (Index < 0) or (Index > Count) then Exception.Create(s_out_of_range_error);
  Result := Integer(objects[Index]) and DIFF_NUM_MASK;
end;
//--------------------------------------------------------------------------

procedure TDiffLines.SetLineNum(Index, NewLineNum: Integer);
begin
  if (Index < 0) or (Index > Count) then Exception.Create(s_out_of_range_error);
  objects[Index] :=
    Pointer((Integer(objects[Index]) and Integer(DIFF_COLOR_MASK)) or (NewLineNum));
end;
//--------------------------------------------------------------------------

function TDiffLines.AddLineInfo(const S: string; LineNum, ClrIndex: Integer):
  Integer;
begin
  if (ClrIndex > $F) then Exception.Create(s_out_of_range_error);
  Result := Add(S);
  objects[Result] := Pointer(LineNum or (ClrIndex shl 28));
end;
//--------------------------------------------------------------------------

procedure TDiffLines.InsertLineInfo(Index: Integer;
  const S: string; LineNum, ClrIndex: Integer);
begin
  if (ClrIndex > $F) then Exception.Create(s_out_of_range_error);
  insert(Index, S);
  objects[Index] := Pointer(LineNum or (ClrIndex shl 28));
end;
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// TDiffControl class methods ...                                          .
//--------------------------------------------------------------------------

constructor TDiffControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csOpaque, csClickEvents, csDoubleClicks];
  SetBounds(Left, Top, 180, 90);
  ParentFont := True;
  ParentColor := False;
  tabstop := True;
  FLines := TDiffLines.Create;
  TStringList(FLines).OnChange := LinesChanged;
  fNumWidth := 1;
  fLineHeight := 10;                    //avoids divideByZero error
end;
//--------------------------------------------------------------------------

procedure TDiffControl.CreateWnd;
begin
  inherited CreateWnd;
  if Assigned(fOnDropFiles) then DragAcceptFiles(Handle, True);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.DestroyWnd;
begin
  if Assigned(fOnDropFiles) then DragAcceptFiles(Handle, False);
  inherited DestroyWnd;
end;
//--------------------------------------------------------------------------

destructor TDiffControl.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_VSCROLL or WS_HSCROLL or WS_TABSTOP;
    if NewStyleControls and Ctl3D then
      ExStyle := ExStyle or WS_EX_CLIENTEDGE
    else
      Style := Style or WS_BORDER;
  end;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMSetFont(var message: TMessage);
var
  dc: HDC;
  oldFont: HFont;
  tm: TTextMetric;
begin
  inherited;
  Canvas.Font := Font;
  oldFont := 0;
  dc := GetDC(Handle);
  try
    oldFont := SelectObject(dc, Canvas.Font.Handle);
    GetTextMetrics(dc, tm);
  finally
    SelectObject(dc, oldFont);
    ReleaseDC(Handle, dc);
  end;
  fAveCharWidth := tm.tmAveCharWidth;
  fLineHeight := tm.tmHeight + tm.tmExternalLeading;
  UpdateScrollbars;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.UpdateScrollbars;
var
  si: TScrollInfo;
begin
  if not handleallocated then Exit;
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_RANGE or SIF_POS or SIF_PAGE;
  si.nMin := 0;

  fVertExponent := 0;
  si.nMax := FLines.Count - 1;
  while si.nMax >= $7FFF do             //ie: nMax <= $7FFF
  begin
    si.nMax := si.nMax div 2;
    Inc(fVertExponent);
  end;

  si.nPage := (ClientHeight div fLineHeight) shr fVertExponent;
  si.nPos := fVertDelta shr fVertExponent;
  SetScrollInfo(Handle, SB_VERT, si, True);
  si.nMax := fAveCharWidth * 256 - 1;   //fix this!!!
  si.nPage := ClientWidth;
  si.nPos := fHorzDelta;
  SetScrollInfo(Handle, SB_HORZ, si, True);
end;
//--------------------------------------------------------------------------

function TDiffControl.NextVisibleFocus: Boolean;
var
  i, ci: Integer;
begin
  Result := False;
  if not fUseFocusRect then Exit;
  i := Max(fFocusStart, fVertDelta);
  if (i >= FLines.Count) then Exit;
  //skip current focus block...
  ci := FLines.GetClrIndex(i);
  while (i < FLines.Count) and (FLines.GetClrIndex(i) = ci) do
    Inc(i);
  //if next block is non-colored then skip it too...
  while (i < FLines.Count) and (FLines.GetClrIndex(i) = 0) do
    Inc(i);
  if (i >= FLines.Count) or (i >= fVertDelta + VisibleLines) then Exit;
  SetFocusStart(i);
  Result := True;
end;
//--------------------------------------------------------------------------

function TDiffControl.PriorVisibleFocus: Boolean;
var
  i, ci: Integer;
begin
  Result := False;
  if not fUseFocusRect then Exit;
  i := Min(fFocusStart, fVertDelta + VisibleLines - 1);
  if (i <= fVertDelta) or (i >= FLines.Count) then Exit;
  //skip current focus block...
  ci := FLines.GetClrIndex(i);
  while (i >= fVertDelta) and (FLines.GetClrIndex(i) = ci) do
    Dec(i);
  //if prior block is non-colored then skip it too...
  while (i >= fVertDelta) and (FLines.GetClrIndex(i) = 0) do
    Dec(i);
  if (i < fVertDelta) then Exit;
  SetFocusStart(i);
  Result := True;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.UpdateFocus(FromTop: Boolean);
var
  i: Integer;
begin
  Invalidate;
  if not fUseFocusRect or ((fFocusStart >= fVertDelta) and
    (fFocusStart < fVertDelta + VisibleLines)) then Exit; //focus is already OK
  if FLines.Count = 0 then
    i := 0
  else if FromTop then
  begin
    i := fVertDelta;
    while (i < FLines.Count) and (i < fVertDelta + VisibleLines) and
      (FLines.ColorIndex[i] = 0) do
      Inc(i);
  end
  else
  begin
    i := Min(fVertDelta + VisibleLines, FLines.Count) - 1;
    while (i >= 0) and (i >= fVertDelta) and
      (FLines.ColorIndex[i] = 0) do
      Dec(i);
  end;
  if (i >= FLines.Count) or (i < 0) or (FLines.ColorIndex[i] = 0) then
    FocusStart := -1
  else
    FocusStart := i;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMSize(var message: TWMSize);
begin
  inherited;
  UpdateScrollbars;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMVScroll(var message: TWMScroll);
var
  si: TScrollInfo;
  oldVertDelta, VisibleLines: Integer;
  goingDown: Boolean;
begin
  VisibleLines := ClientHeight div fLineHeight;
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  GetScrollInfo(Handle, SB_VERT, si);
  oldVertDelta := fVertDelta;
  case message.ScrollCode of
    SB_PAGEUP: Dec(fVertDelta, VisibleLines);
    SB_PAGEDOWN: Inc(fVertDelta, VisibleLines);
    SB_LINEUP: Dec(fVertDelta, 1);
    SB_LINEDOWN: Inc(fVertDelta, 1);
    SB_THUMBTRACK: fVertDelta := message.Pos shl fVertExponent;
  end;
  if fVertDelta < 0 then
    fVertDelta := 0
  else if fVertDelta > FLines.Count - VisibleLines then
    fVertDelta := Max(FLines.Count - VisibleLines, 0);

  if fVertDelta = oldVertDelta then
  begin
    if (fVertDelta = 0) or (fVertDelta = FLines.Count - VisibleLines) then
    begin
      fFocusStart := -1;
      UpdateFocus(fVertDelta = 0);
    end;
    Exit;
  end;
  goingDown := oldVertDelta < fVertDelta;
  si.nPos := fVertDelta shr fVertExponent;
  SetScrollInfo(Handle, SB_VERT, si, True);
  UpdateFocus(goingDown);
  if Assigned(fOnScroll) then fOnScroll(Self);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMHScroll(var message: TWMScroll);
var
  si: TScrollInfo;
  oldHorzDelta: Integer;
begin
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  GetScrollInfo(Handle, SB_HORZ, si);
  oldHorzDelta := fHorzDelta;
  case message.ScrollCode of
    SB_PAGEUP: Dec(fHorzDelta, ClientWidth - fAveCharWidth);
    SB_PAGEDOWN: Inc(fHorzDelta, ClientWidth - fAveCharWidth);
    SB_LINEUP: Dec(fHorzDelta, fAveCharWidth);
    SB_LINEDOWN: Inc(fHorzDelta, fAveCharWidth);
    SB_THUMBTRACK: fHorzDelta := message.Pos;
  end;
  if fHorzDelta < 0 then
    fHorzDelta := 0
  else if fHorzDelta > si.nMax - ClientWidth then
    fHorzDelta := Max(0, si.nMax - ClientWidth);
  if fHorzDelta = oldHorzDelta then Exit;
  si.nPos := fHorzDelta;
  SetScrollInfo(Handle, SB_HORZ, si, True);
  Refresh;
  if Assigned(fOnScroll) then fOnScroll(Self);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMMouseWheel(var message: TWMMouseWheel);
var
  Msg: TWMScroll;
  i: Integer;
begin
  if GetKeyState(VK_CONTROL) < 0 then
  begin
    if message.WheelDelta > 0 then
      Msg.ScrollCode := SB_PAGEUP
    else
      Msg.ScrollCode := SB_PAGEDOWN;
    WMVScroll(Msg);
  end
  else
  begin
    if message.WheelDelta > 0 then
      Msg.ScrollCode := SB_LINEUP
    else
      Msg.ScrollCode := SB_LINEDOWN;

    for i := 0 to csWheelLines - 1 do
      WMVScroll(Msg);
  end;
end;

function TDiffControl.GetTopLine: Integer;
begin
  Result := fVertDelta;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.SetTopLine(TopLine: Integer);
begin
  if TopLine = fVertDelta then
    Exit
  else if TopLine < 0 then
    fVertDelta := 0
  else if TopLine > FLines.Count - VisibleLines then
    fVertDelta := Max(FLines.Count - VisibleLines, 0)
  else
    fVertDelta := TopLine;
  UpdateScrollbars;
  UpdateFocus(True);
  if Assigned(fOnScroll) then fOnScroll(Self);
end;
//--------------------------------------------------------------------------

function TDiffControl.GetHorzScroll: Integer;
begin
  Result := fHorzDelta;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.SetHorzScroll(HorzScroll: Integer);
begin
  if HorzScroll = fHorzDelta then
    Exit
  else if HorzScroll < 0 then
    fHorzDelta := 0
  else if fHorzDelta > fAveCharWidth * 256 - ClientWidth - 1 then
    fHorzDelta := Max(fAveCharWidth * 256 - ClientWidth - 1, 0)
  else
    fHorzDelta := HorzScroll;
  Invalidate;
  UpdateScrollbars;
end;
//--------------------------------------------------------------------------

function TDiffControl.GetVisibleLines: Integer;
begin
  Result := ClientHeight div fLineHeight;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.Paint;
var
  numRec, textRec: TRect;
  i, colorIndex, visibleLines: Integer;
  numColor: TColor;
  FocusNeeded: Boolean;
begin
  numRec := ClientRect;
  textRec := numRec;
  if focused then
    numColor := $D9D9D9
  else
    numColor := clSilver;
  with Canvas do
  begin
    //get the width of the line numbers border...
    numRec.Right := TextWidth('0') * fNumWidth + (LEFTOFFSET * 2) + 2;
    //get the rect where the text will be displayed...
    Inc(textRec.Left, numRec.Right);
    //brush fill in the top offset...
    textRec.Bottom := textRec.Top + TOPOFFSET;
    brush.Color := Color;
    FillRect(textRec);
    //color fill the line number edge ...
    brush.Color := numColor;
    FillRect(numRec);
    pen.Color := clGray;
    Dec(numRec.Right);
    MoveTo(numRec.Right, 0);
    LineTo(numRec.Right, ClientHeight);
    pen.Color := clWhite;
    Dec(numRec.Right);
    MoveTo(numRec.Right, 0);
    LineTo(numRec.Right, ClientHeight);
    pen.Color := clSilver;
    Dec(numRec.Right);
    MoveTo(numRec.Right, 0);
    LineTo(numRec.Right, ClientHeight);
    //color each visible line according to its color mask ...
    visibleLines := ClientHeight div fLineHeight;

    FocusNeeded := False;
    if FLines.Count > 0 then
      for i := fVertDelta to FLines.Count - 1 do
        if (i - fVertDelta > visibleLines) then
          Break
        else
        begin
          if UseFocusRect and focused and
            (i >= fFocusStart) and (i < fFocusEnd) then
            FocusNeeded := True;
          colorIndex := FLines.ColorIndex[i];
          if colorIndex = 0 then
            brush.Color := Color
          else
            brush.Color := fColors[colorIndex];
          //textout for each line ...
          textRec.Top := (i - fVertDelta) * fLineHeight + TOPOFFSET;
          textRec.Bottom := textRec.Top + fLineHeight + 1;
          TextRect(textRec, textRec.Left - fHorzDelta + LEFTOFFSET,
            (i - fVertDelta) * fLineHeight + TOPOFFSET, FLines[i]);
          //number lines using the line numbers stored in fLines.objects[] ...
          brush.Color := numColor;
          numRec.Top := textRec.Top;
          numRec.Bottom := textRec.Bottom;
          if Integer(FLines.objects[i]) and DIFF_NUM_MASK <> 0 then
            TextRect(numRec, LEFTOFFSET, TOPOFFSET + (i - fVertDelta) * fLineHeight,
              Format('%*.*d', [fNumWidth, fNumWidth,
              Integer(FLines.objects[i]) and DIFF_NUM_MASK]))
          else
            FillRect(numRec);
        end;
    //fill any remaining area below lines ...
    if textRec.Bottom < ClientHeight then
    begin
      brush.Color := Color;
      textRec.Top := textRec.Bottom;
      textRec.Bottom := ClientHeight;
      FillRect(textRec);
    end;
    if FocusNeeded then
    begin
      textRec.Top := (fFocusStart - fVertDelta) * fLineHeight + TOPOFFSET;
      textRec.Bottom := (fFocusEnd - fVertDelta) * fLineHeight + TOPOFFSET;
      drawFocusRect(textRec);
    end;
  end;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMSetFocus(var message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMKillFocus(var message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.WMDropFiles(var message: TWMDropFiles);
var
  DropHandled: Boolean;
begin
  inherited;
  if Assigned(fOnDropFiles) then
  begin
    DropHandled := False;
    fOnDropFiles(Self, message.Drop, DropHandled);
    message.Result := Integer(DropHandled);
  end;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.LinesChanged(Sender: TObject);
begin
  UpdateScrollbars;
  Invalidate;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.VertKey(Key: WORD);
var
  Msg: TWMScroll;
begin
  case Key of
    VK_UP:
      if PriorVisibleFocus then
        Exit
      else
        Msg.ScrollCode := SB_LINEUP;
    VK_DOWN:
      if NextVisibleFocus then
        Exit
      else
        Msg.ScrollCode := SB_LINEDOWN;

    VK_PRIOR: Msg.ScrollCode := SB_PAGEUP;
    VK_NEXT: Msg.ScrollCode := SB_PAGEDOWN;
    VK_HOME:
      begin
        Msg.ScrollCode := SB_THUMBTRACK;
        Msg.Pos := 0;
      end;
    VK_END:
      begin
        Msg.ScrollCode := SB_THUMBTRACK;
        Msg.Pos := FLines.Count;
      end;
  end;
  WMVScroll(Msg);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.HorzKey(Key: WORD);
var
  Msg: TWMScroll;
begin
  case Key of
    VK_LEFT: Msg.ScrollCode := SB_LINEUP;
    VK_RIGHT: Msg.ScrollCode := SB_LINEDOWN;
  end;
  WMHScroll(Msg);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.KeyDown(var Key: WORD; Shift: TShiftState);
begin
  inherited;
  if Assigned(OnKeyDown) then OnKeyDown(Self, Key, Shift);
  case Key of
    VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END: VertKey(Key);
    VK_LEFT, VK_RIGHT: HorzKey(Key);
  end;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if not (csDesigning in ComponentState) and CanFocus then
  begin
    if ValidParentForm(Self).Visible and not Focused then
    begin
      SetFocus;
      if ValidParentForm(Self).ActiveControl <> Self then
      begin
        MouseCapture := False;
        Exit;
      end;
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;
//--------------------------------------------------------------------------

function TDiffControl.GetColor(Index: Integer): TColor;
begin
  if (Index < 1) or (Index > 15) then Exception.Create(s_out_of_range_error);
  Result := fColors[Index];
end;
//--------------------------------------------------------------------------

procedure TDiffControl.SetColor(Index: Integer; NewColor: TColor);
begin
  if (Index < 1) or (Index > 15) then Exit;
  fColors[Index] := NewColor;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.SetMaxLineNum(MaxLineNum: Integer);
begin
  fNumWidth := GetNumWidth(MaxLineNum);
end;
//--------------------------------------------------------------------------

procedure TDiffControl.KillFocus;
begin
  if fFocusEnd <> fFocusStart then Invalidate;
  fFocusEnd := 0;
  fFocusStart := 0;
end;
//--------------------------------------------------------------------------

procedure TDiffControl.SetFocusStart(FocusStart: Integer);
var
  clrIdx: Integer;
  OldStart, OldEnd: Integer;
begin
  OldStart := fFocusStart;
  OldEnd := fFocusEnd;
  fFocusEnd := 0;
  fFocusStart := 0;
  if not UseFocusRect or (FocusStart < 0) or (FocusStart >= FLines.Count) then Exit;
  fFocusStart := FocusStart;
  fFocusEnd := FocusStart + 1;
  clrIdx := FLines.ColorIndex[FocusStart];
  while (fFocusStart > 0) and (FLines.ColorIndex[fFocusStart - 1] = clrIdx) do
    Dec(fFocusStart);
  while (fFocusEnd <= FLines.Count - 1) and (FLines.ColorIndex[fFocusEnd] = clrIdx)
    do
    Inc(fFocusEnd);
  if (OldStart <> fFocusStart) or (OldEnd <> fFocusEnd) then Invalidate;
end;
//--------------------------------------------------------------------------

function TDiffControl.GetFocusLength: Integer;
begin
  Result := fFocusEnd - fFocusStart;
end;
//--------------------------------------------------------------------------

//GetCharOffsets() assumes ints is a
//memory allocated array of [0..length(line)] of integers...
function GetCharOffsets(dc: HDC; const Line: string; ints: PIntArray): Boolean;
var
  gcpResults: TgcpResults;
  gcpFlags, LineLen: DWORD;
begin
  //nb: modifications for tabs will be needed
  LineLen := Length(Line);
  FillChar(gcpResults, SizeOf(TgcpResults), 0);
  gcpResults.lStructSize := SizeOf(TgcpResults);
  gcpResults.lpCaretPos := Pointer(ints);
  gcpResults.nGlyphs := LineLen;
  gcpFlags := GetFontLanguageInfo(dc) and not FLI_GLYPHS;
{$IFDEF COMPILER7}
  ints[LineLen] := GetCharacterPlacement(dc, PChar(Line),
    LineLen, 0, gcpResults, gcpFlags) and $FFFF;
{$ELSE}
  {$IFDEF COMPILER10_UP}
  ints[LineLen] := GetCharacterPlacement(dc, PChar(Line),
    LineLen, 0, gcpResults, gcpFlags) and $FFFF;
  {$ELSE}
  ints[LineLen] := GetCharacterPlacement(dc, PChar(Line),
    LongBool(LineLen), LongBool(0), gcpResults, gcpFlags) and $FFFF;
  {$ENDIF COMPILER10_UP}
{$ENDIF COMPILER7}
  Result := ints[LineLen] > 0;
end;
//--------------------------------------------------------------------------

function TDiffControl.ClientPtToTextPoint(pt: TPoint): TPoint;
var
  LineLen, leftMarginOffset: Integer;
  IntArray: PIntArray;
begin
  Result.y := fVertDelta + ((pt.y - TOPOFFSET) div LineHeight);
  Result.x := 0;
  if (Result.y < 0) or (Result.y >= FLines.Count) then
  begin
    Result.y := fVertDelta + Min(FLines.Count - fVertDelta, VisibleLines) div 2;
    Exit;
  end;
  
  LineLen := Length(FLines[Result.y]);
  if LineLen = 0 then Exit;
  GetMem(IntArray, (LineLen + 1) * SizeOf(Integer));
  try
    //the following function will also handle proportional fonts...
    if not GetCharOffsets(Canvas.Handle, FLines[Result.y], IntArray) then Exit;
    leftMarginOffset :=
      Canvas.TextWidth('0') * fNumWidth + (LEFTOFFSET * 3) + 2 - fHorzDelta;
    Dec(pt.x, leftMarginOffset);
    while (Result.x < LineLen) do
      if pt.x <= intArray[Result.x] then
        Break
      else
        Inc(Result.x);
  finally
    FreeMem(IntArray);
  end;
end;
//--------------------------------------------------------------------------

function TDiffControl.GotoNextDiff: Boolean;
var
  i, ci: Integer;
begin
  Result := False;
  if fUseFocusRect then
    i := fFocusStart
  else if fVertDelta + VisibleLines < FLines.Count then
    i := fVertDelta + csDiffTopLines
  else
    Exit;

  // 跳过当前差异块
  ci := FLines.GetClrIndex(i);
  while (i < FLines.Count) and (FLines.GetClrIndex(i) = ci) do
    Inc(i);

  // 跳过空白块
  while (i < FLines.Count) and (FLines.GetClrIndex(i) = 0) do
    Inc(i);
  if i >= FLines.Count then Exit;

  if fUseFocusRect then SetFocusStart(i);

  TopVisibleLine := i - csDiffTopLines;
  Result := True;
end;

function TDiffControl.GotoPrioDiff: Boolean;
var
  i, ci: Integer;
begin
  Result := False;
  if fUseFocusRect then
    i := fFocusStart
  else if fVertDelta > 0 then
    i := fVertDelta + csDiffTopLines
  else
    Exit;

  // 跳过当前差异块
  ci := FLines.GetClrIndex(i);
  if ci <> 0 then
    while (i >= 0) and (FLines.GetClrIndex(i) = ci) do
      Dec(i);

  // 跳过空白块
  while (i >= 0) and (FLines.GetClrIndex(i) = 0) do
    Dec(i);
  if i < 0 then Exit;

  // 找到上一差异块头部
  ci := FLines.GetClrIndex(i);
  while (i >= 0) and (FLines.GetClrIndex(i) = ci) do
    Dec(i);
  Inc(i);

  if fUseFocusRect then SetFocusStart(i);

  TopVisibleLine := i - csDiffTopLines;
  Result := True;
end;

end.

