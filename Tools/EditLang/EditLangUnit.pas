unit EditLangUnit;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, CnCommon, ExtCtrls, StdCtrls, ComCtrls, Grids, ToolWin, ImgList,
  ActnList;

type
  TEditLangForm = class(TForm)
    statMain: TStatusBar;
    pnlTop: TPanel;
    pnlLeftTop: TPanel;
    cbbLeftDir: TComboBox;
    cbbLeftFile: TComboBox;
    spl1: TSplitter;
    pnlRightTop: TPanel;
    cbbRightDir: TComboBox;
    cbbRightFile: TComboBox;
    StringGrid: TStringGrid;
    tlbEdit: TToolBar;
    actlstMain: TActionList;
    actNextDiff: TAction;
    actPrevDiff: TAction;
    actSaveLeft: TAction;
    actSaveRight: TAction;
    ilMain: TImageList;
    btnNextDiff: TToolButton;
    btnPrevDiff: TToolButton;
    btn1: TToolButton;
    btnSaveLeft: TToolButton;
    btnSaveRight: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbbLeftDirChange(Sender: TObject);
    procedure cbbRightDirChange(Sender: TObject);
    procedure cbbLeftFileChange(Sender: TObject);
    procedure cbbRightFileChange(Sender: TObject);
    procedure spl1Moved(Sender: TObject);
    procedure actNextDiffExecute(Sender: TObject);
    procedure actPrevDiffExecute(Sender: TObject);
    procedure actSaveLeftExecute(Sender: TObject);
    procedure actSaveRightExecute(Sender: TObject);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FLangRoot: string;
    FLangDirs: TStrings;
    FLeftFileName: string;
    FRightFileName: string;
    FLeftLangFiles: TStrings;
    FRightLangFiles: TStrings;
    FLeftContent: TStrings;
    FRightContent: TStrings;
    FLeftDisplay: TStrings;
    FRightDisplay: TStrings;
    function SaveLinesToFile(Lines: TStrings; const FileName: string): Boolean;
    procedure SyncLeftGridToDisplay;
    procedure SyncRightGridToDisplay;
    procedure ChangeGridColumnSize;
    function LineEqual(const S1: string; const S2: string): Boolean;
    procedure SearchLangFiles(const Dir: string; List: TStrings; IsDir: Boolean);
    procedure RearrangeDisplays;
    procedure UpdateToGrid;
  public
    { Public declarations }
  end;

var
  EditLangForm: TEditLangForm;

implementation

{$R *.DFM}

const
  LANG_DIR = 'Lang\';

  LEFT_EDITING_COL = 1;
  RIGHT_EDITING_COL = 4;

procedure TEditLangForm.FormCreate(Sender: TObject);
begin
{$IFNDEF UNICODE}
  ShowMessage('Must Run under Unicode Environment.');
  Application.Terminate;
{$ENDIF}

{$IFNDEF TSTRINGS_HAS_WRITEBOM}
  ShowMessage('NO BOM Support. Be Careful when Saving.');
{$ENDIF}

  FLangRoot := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + LANG_DIR;
  FLangDirs := TStringList.Create;

  SearchLangFiles(FLangRoot, FLangDirs, True);

  cbbLeftDir.Items.Assign(FLangDirs);
  cbbRightDir.Items.Assign(FLangDirs);

  FLeftContent := TStringList.Create;
  FRightContent := TStringList.Create;
  FLeftDisplay := TStringList.Create;
  FRightDisplay := TStringList.Create;

//  mmoLeft := TCnMemo.Create(Self);
//  with mmoLeft do
//  begin
//    Align := alClient;
//    ShowLineNumber := True;
//    Parent := pnlLeft;
//    ScrollBars := ssBoth;
//  end;
//
//  mmoRight := TCnMemo.Create(Self);
//  with mmoRight do
//  begin
//    Align := alClient;
//    ShowLineNumber := True;
//    Parent := pnlRight;
//    ScrollBars := ssBoth;
//  end;
end;

procedure TEditLangForm.FormDestroy(Sender: TObject);
begin
  FLeftDisplay.Free;
  FRightDisplay.Free;
  FLeftContent.Free;
  FRightContent.Free;
  FLangDirs.Free;
  FLeftLangFiles.Free;
  FRightLangFiles.Free;
end;

function TEditLangForm.SaveLinesToFile(Lines: TStrings;
  const FileName: string): Boolean;
var
  I: Integer;
  Sl: TStringList;
begin
  Result := False;
  if (FileName <> '') and (Lines.Count > 0) then
  begin
    Sl := TStringList.Create;
    Sl.DefaultEncoding := TEncoding.UTF8;
    Sl.WriteBOM := True;
    try
      for I := 0 to Lines.Count - 1 do
        Sl.Add(Lines[I]);

      for I := Sl.Count - 1 downto 0 do
        if Sl[I] = '' then
          Sl.Delete(I);

      if Sl.Count > 0 then
      begin
        Sl.SaveToFile(FileName);
        Result := True;
      end;
    finally
      Sl.Free;
    end;
  end;
end;

procedure TEditLangForm.SearchLangFiles(const Dir: string; List: TStrings; IsDir: Boolean);
var
  SearchRec: TSearchRec;
  F: Integer;
begin
  F := FindFirst(IncludeTrailingPathDelimiter(Dir) + '*.*', faAnyFile, SearchRec);
  List.Clear;
  while F = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.name <> '..') then
    begin
      if not IsDir and (SearchRec.Attr and faDirectory <> faDirectory) then
        List.Add(ExtractFileName(SearchRec.Name))
      else if IsDir and (SearchRec.Attr and faDirectory = faDirectory) then
        List.Add(ExtractFileName(SearchRec.Name));
    end;
    F := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure TEditLangForm.spl1Moved(Sender: TObject);
begin
  ChangeGridColumnSize;
end;

procedure TEditLangForm.StringGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ACol in [LEFT_EDITING_COL, RIGHT_EDITING_COL] then
    StringGrid.Options := StringGrid.Options + [goEditing]
  else
    StringGrid.Options := StringGrid.Options - [goEditing];
end;

procedure TEditLangForm.SyncLeftGridToDisplay;
begin
  FLeftDisplay.Assign(StringGrid.Cols[LEFT_EDITING_COL]);
end;

procedure TEditLangForm.SyncRightGridToDisplay;
begin
  FRightDisplay.Assign(StringGrid.Cols[RIGHT_EDITING_COL]);
end;

procedure TEditLangForm.UpdateToGrid;
var
  I, C: Integer;
begin
  C := FLeftDisplay.Count;
  if C < FRightDisplay.Count then
    C := FRightDisplay.Count;

  StringGrid.RowCount := C;
  C := 1;
  for I := 0 to FLeftDisplay.Count - 1 do
  begin
    if FLeftDisplay[I] <> '' then
    begin
      StringGrid.Cells[0, I] := IntToStr(C);
      StringGrid.Cells[1, I] := FLeftDisplay[I];
      Inc(C);
    end
    else
    begin
      StringGrid.Cells[0, I] := '';
      StringGrid.Cells[1, I] := FLeftDisplay[I];
    end;
  end;

  C := 1;
  for I := 0 to FRightDisplay.Count - 1 do
  begin
    if FRightDisplay[I] <> '' then
    begin
      StringGrid.Cells[3, I] := IntToStr(C);
      StringGrid.Cells[4, I] := FRightDisplay[I];
      Inc(C);
    end
    else
    begin
      StringGrid.Cells[3, I] := '';
      StringGrid.Cells[4, I] := FRightDisplay[I];
    end;
  end;
end;

procedure TEditLangForm.FormResize(Sender: TObject);
const
  MARGIN = 10;
begin
  ChangeGridColumnSize;
  statMain.Panels[0].Width := Width div 2 - MARGIN;
end;

function TEditLangForm.LineEqual(const S1, S2: string): Boolean;
var
  P1, P2: Integer;
  H1, H2: string;
begin
  P1 := Pos('=', S1);
  P2 := Pos('=', S2);

  if (P1 <= 0) and (P2 <= 0) then
    Result := S1 = S2
  else if (P1 <= 0) or (P2 <= 0) then
    Result := False // 一个有等号一个没等号
  else // 都有等号
  begin
    H1 := Copy(S1, 1, P1 - 1);
    H2 := Copy(S2, 1, P2 - 1);
    Result := H1 = H2;
  end;
end;

procedure TEditLangForm.RearrangeDisplays;
var
  I, J, L, R, LS, RS, LAC, RAC: Integer;
  Matched: Boolean;
begin
  FLeftDisplay.Clear;
  FRightDisplay.Clear;

  if FLeftContent.Count = 0 then
  begin
    FRightDisplay.Text := FRightContent.Text;
    Exit;
  end
  else if FRightContent.Count = 0 then
  begin
    FLeftDisplay.Text := FLeftContent.Text;
    Exit;
  end;

  L := 0; R := 0;
  while (L < FLeftContent.Count) and (R < FRightContent.Count) do
  begin
    if LineEqual(FLeftContent[L], FRightContent[R]) then
    begin
      FLeftDisplay.Add(FLeftContent[L]);
      FRightDisplay.Add(FRightContent[R]);
      Inc(L);
      Inc(R);
    end
    else
    begin
      LAC := 0; RAC := 0;
      // 左不动，往后查右
      RS := R + 1;
      Matched := False;
      while RS < FRightContent.Count do
      begin
        if LineEqual(FLeftContent[L], FRightContent[RS]) then
        begin
          Matched := True;
          Inc(RAC);
          Break;
        end
        else
        begin
          Inc(RS);
          Inc(RAC);
        end;
      end;

      if Matched then
      begin
        // 左不动，右边找到了，左边加RAC个空行后加L，右边加R一直加到RS
        for I := 1 to RAC do
          FLeftDisplay.Add('');
        FLeftDisplay.Add(FLeftContent[L]);
        for I := R to RS do
          FRightDisplay.Add(FRightContent[I]);

        Inc(L);
        R := RS + 1;
        Continue;
      end;

      // 没找到。右不动，往后查左
      LS := L + 1;
      Matched := False;
      while LS < FLeftContent.Count do
      begin
        if LineEqual(FLeftContent[LS], FRightContent[R]) then
        begin
          Matched := True;
          Inc(LAC);
          Break;
        end
        else
        begin
          Inc(LS);
          Inc(LAC);
        end;
      end;

      if Matched then
      begin
        // 右不动，左边找到了，右边加LAC个空行后加R，左边加L一直加到LS
        for I := 1 to LAC do
          FRightDisplay.Add('');
        FRightDisplay.Add(FRightContent[R]);
        for I := L to LS do
          FLeftDisplay.Add(FLeftContent[I]);

        L := LS + 1;
        Inc(R);
        Continue;
      end;

      // 没找到合适的，说明有个到头了，分别加上
      for I := L to FLeftContent.Count - 1 do
      begin
        FLeftDisplay.Add(FLeftContent[I]);
        FRightDisplay.Add('');
      end;
      for I := R to FRightContent.Count - 1 do
      begin
        FLeftDisplay.Add('');
        FRightDisplay.Add(FRightContent[I]);
      end;
      Break;
    end;
  end;
end;

procedure TEditLangForm.actNextDiffExecute(Sender: TObject);
var
  I: Integer;
begin
  I := StringGrid.Row + 1;
  while I < StringGrid.RowCount do
  begin
    if (FLeftDisplay[I] = '') or (FRightDisplay[I] = '') then
      Break;
    Inc(I);
  end;

  if I = StringGrid.RowCount then
    InfoDlg('No Next Different Line.')
  else
    StringGrid.Row := I;
end;

procedure TEditLangForm.actPrevDiffExecute(Sender: TObject);
var
  I: Integer;
begin
  I := StringGrid.Row - 1;
  while I >= 0 do
  begin
    if (FLeftDisplay[I] = '') or (FRightDisplay[I] = '') then
      Break;
    Dec(I);
  end;

  if I < 0 then
    InfoDlg('No Prev Different Line.')
  else
    StringGrid.Row := I;
end;

procedure TEditLangForm.actSaveLeftExecute(Sender: TObject);
begin
  if SaveLinesToFile(StringGrid.Cols[1], FLeftFileName) then
    InfoDlg('Save Success. ' + FLeftFileName);
end;

procedure TEditLangForm.actSaveRightExecute(Sender: TObject);
begin
  if SaveLinesToFile(StringGrid.Cols[4], FRightFileName) then
    InfoDlg('Save Success. ' + FRightFileName);
end;

procedure TEditLangForm.cbbLeftDirChange(Sender: TObject);
begin
  if cbbLeftDir.ItemIndex >= 0 then
    SearchLangFiles(FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbLeftDir.ItemIndex]),
      cbbLeftFile.Items, False);
end;

procedure TEditLangForm.cbbRightDirChange(Sender: TObject);
begin
  if cbbRightDir.ItemIndex >= 0 then
    SearchLangFiles(FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbRightDir.ItemIndex]),
      cbbRightFile.Items, False);
end;

procedure TEditLangForm.cbbRightFileChange(Sender: TObject);
var
  S: string;
begin
  if (cbbRightFile.Items.Count > 0) and (cbbRightFile.ItemIndex >= 0) then
  begin
    S := FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbRightDir.ItemIndex])
      + cbbRightFile.Items[cbbRightFile.ItemIndex];
    if FileExists(S) then
    begin
      FRightContent.LoadFromFile(S);
      FRightFileName := S;
      RearrangeDisplays;
      UpdateToGrid;
      StringGrid.SetFocus;
    end;
  end;
end;

procedure TEditLangForm.ChangeGridColumnSize;
const
  GUTTER_WIDTH = 60;
begin
  StringGrid.ColWidths[0] := GUTTER_WIDTH;
  StringGrid.ColWidths[1] := pnlLeftTop.Width - 6 - GUTTER_WIDTH;
  StringGrid.ColWidths[2] := 8;
  StringGrid.ColWidths[3] := GUTTER_WIDTH;
  StringGrid.ColWidths[4] := pnlRightTop.Width - 26 - GUTTER_WIDTH;
end;

procedure TEditLangForm.cbbLeftFileChange(Sender: TObject);
var
  S: string;
begin
  if (cbbLeftFile.Items.Count > 0) and (cbbLeftFile.ItemIndex >= 0) then
  begin
    S := FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbLeftDir.ItemIndex])
      + cbbLeftFile.Items[cbbLeftFile.ItemIndex];
    if FileExists(S) then
    begin
      FLeftContent.LoadFromFile(S);
      FLeftFileName := S;
      RearrangeDisplays;
      UpdateToGrid;
      StringGrid.SetFocus;
    end;
  end;
end;

end.

