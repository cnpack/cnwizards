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

unit EditLangUnit;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, CnCommon, ExtCtrls, StdCtrls, ComCtrls, Grids, ToolWin, ImgList,
  ActnList, Clipbrd;

const
  LANG_DIR = 'Lang\';

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
    btn2: TToolButton;
    actTSortLeft: TAction;
    actTSortRight: TAction;
    btnTSortLeft: TToolButton;
    btnTSortRight: TToolButton;
    btn3: TToolButton;
    actCopyLeftEmpty: TAction;
    actCopyRightEmpty: TAction;
    actSearchLeftToRight: TAction;
    actSearchRightToLeft: TAction;
    btnCopyLeftEmpty: TToolButton;
    btnCopyRightEmpty: TToolButton;
    btn4: TToolButton;
    btnSearchLeftToRight: TToolButton;
    btnSearchRightToLeft: TToolButton;
    actSearchAllLeftToRight: TAction;
    actSearchAllRightToLeft: TAction;
    btn5: TToolButton;
    btnSearchAllLeftToRight: TToolButton;
    btnSearchAllRightPartToLeft: TToolButton;
    actPastToLeftByRight: TAction;
    actPasteToRightByLeft: TAction;
    btnPastToLeftByRight: TToolButton;
    btn7: TToolButton;
    btnPasteToRightByLeft: TToolButton;
    btn6: TToolButton;
    btnPasteMultiLineLeft: TToolButton;
    btnPasteMultiLineRight: TToolButton;
    actPasteMultiLineLeft: TAction;
    actPasteMultiLineRight: TAction;
    ToolButton1: TToolButton;
    actInsertItems: TAction;
    btnInsertItems: TToolButton;
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
    procedure actTSortLeftExecute(Sender: TObject);
    procedure actTSortRightExecute(Sender: TObject);
    procedure actCopyLeftEmptyExecute(Sender: TObject);
    procedure actCopyRightEmptyExecute(Sender: TObject);
    procedure actSearchLeftToRightExecute(Sender: TObject);
    procedure actSearchRightToLeftExecute(Sender: TObject);
    procedure actSearchAllLeftToRightExecute(Sender: TObject);
    procedure actSearchAllRightToLeftExecute(Sender: TObject);
    procedure actPastToLeftByRightExecute(Sender: TObject);
    procedure actPasteToRightByLeftExecute(Sender: TObject);
    procedure actPasteMultiLineLeftExecute(Sender: TObject);
    procedure actPasteMultiLineRightExecute(Sender: TObject);
    procedure actInsertItemsExecute(Sender: TObject);
  private
    FLangRoot: string;
    FLangDirs: TStrings;
    FLeftFileName: string;
    FRightFileName: string;
    FLeftLangFiles: TStrings;
    FRightLangFiles: TStrings;
    FLeftContent: TStrings;  // 左边文件的内容
    FRightContent: TStrings; // 右边文件的内容
    FLeftDisplay: TStrings;  // 左边文件的内容插入对齐后的空行的内容，用于塞入 Grid，Grid 编辑后不一致
    FRightDisplay: TStrings; // 右边文件的内容插入对齐后的空行的内容，用于塞入 Grid，Grid 编辑后不一致
    function SaveLinesToFile(Lines: TStrings; const FileName: string): Boolean;
    procedure SyncLeftGridToDisplay;
    procedure SyncRightGridToDisplay;
    procedure ChangeGridColumnSize;
    function LineEqual(const S1: string; const S2: string): Boolean;
    procedure RearrangeDisplays;
    // 根据 LeftContent/RightContent 实施对比，把对齐结果放到 LeftDisplay/RightDisplay 中
    procedure UpdateToGrid;
    procedure StringsTSort(Lines: TStrings);
    procedure SearchLeftToRight(Line: Integer);
    procedure SearchRightToLeft(Line: Integer);
  public
    procedure PasteToGridMultiLine(Col: Integer);
  end;

procedure SearchLangFiles(const Dir: string; List: TStrings; IsDir: Boolean);

var
  EditLangForm: TEditLangForm;

implementation

{$R *.DFM}

uses
  InsertUnit;

const
  LEFT_EDITING_COL = 1;
  RIGHT_EDITING_COL = 4;

procedure QuickSortStrings(Lines: TStrings; L, R: Integer);
var
  I, J, P: Integer;

  function CompareStrBeforeEqual(const S1, S2: string): Integer;
  var
    P: Integer;
    P1, P2: string;
  begin
    P := Pos('=', S1);
    if P > 0 then
      P1 := Copy(S1, 1, P - 1)
    else
      P1 := S1;

    P := Pos('=', S2);
    if P > 0 then
      P2 := Copy(S2, 1, P - 1)
    else
      P2 := S1;

    Result := CompareStr(P1, P2);
  end;

begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while CompareStrBeforeEqual(Lines[I], Lines[P]) < 0 do Inc(I);
      while CompareStrBeforeEqual(Lines[J], Lines[P]) > 0 do Dec(J);
      if I <= J then
      begin
        if I <> J then
          Lines.Exchange(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSortStrings(Lines, L, J);
    L := I;
  until I >= R;
end;

function EndWithStr(const S, SubFix: string): Boolean;
var
  P: Integer;
begin
  Result := False;
  if (S = '') or (SubFix = '') then
    Exit;

  P := Pos(SubFix, S);
  Result := (P > 0) and (P + Length(SubFix) - 1 = Length(S));
end;

procedure SearchLangFiles(const Dir: string; List: TStrings; IsDir: Boolean);
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

procedure TEditLangForm.SearchLeftToRight(Line: Integer);
var
  L, P: Integer;
  Left, Right, Root: string;
begin
  // 针对选中的左侧条目，找等号后原文在其他地方的索引，找对应译文的等号后的部分，拼起来
  if Line < 0 then
    Exit;

  Left := StringGrid.Cells[LEFT_EDITING_COL, Line];
  Right := StringGrid.Cells[RIGHT_EDITING_COL, Line];

  if (Right <> '') and (Right[Length(Right)] <> '=') then
    Exit;
  L := Pos('=', Left);
  if L < 0 then
    Exit;

  Root := Copy(Left, 1, L - 1); // 不要 =
  Left := Copy(Left, L, MaxInt); // 要 =
  if Left = '=' then
    Exit;

  // 在 StringGrid.Cols[LEFT_EDITING_COL] 里找 Left 结尾的序号
  for L := 0 to StringGrid.RowCount - 1 do
  begin
    if EndWithStr(StringGrid.Cells[LEFT_EDITING_COL, L], Left) then // 找到了原文
    begin
      Right := StringGrid.Cells[RIGHT_EDITING_COL, L];
      P := Pos('=', Right);
      if P < 0 then
        Continue;

      Right := Copy(Right, P + 1, MaxInt); // 找到了译文
      if Right <> '' then
      begin
        StringGrid.Cells[RIGHT_EDITING_COL, Line] := Root + '=' + Right;
        Exit;
      end;
    end;
  end;
end;

procedure TEditLangForm.SearchRightToLeft(Line: Integer);
var
  L, P: Integer;
  Left, Right, Root: string;
begin
  // 针对选中的右侧条目，找等号后原文在其他地方的索引，找对应译文的等号后的部分，拼起来
  if Line < 0 then
    Exit;

  Left := StringGrid.Cells[LEFT_EDITING_COL, Line];
  Right := StringGrid.Cells[RIGHT_EDITING_COL, Line];

  if (Left <> '') and (Left[Length(Left)] <> '=') then
    Exit;
  L := Pos('=', Right);
  if L < 0 then
    Exit;

  Root := Copy(Right, 1, L - 1); // 不要 =
  Right := Copy(Right, L, MaxInt); // 要 =
  if Right = '=' then
    Exit;

  // 在 StringGrid.Cols[RIGHT_EDITING_COL] 里找 Right 结尾的序号
  for L := 0 to StringGrid.RowCount - 1 do
  begin
    if EndWithStr(StringGrid.Cells[RIGHT_EDITING_COL, L], Right) then // 找到了原文
    begin
      Left := StringGrid.Cells[LEFT_EDITING_COL, L];
      P := Pos('=', Left);
      if P < 0 then
        Continue;

      Left := Copy(Left, P + 1, MaxInt); // 找到了译文
      if Left <> '' then
      begin
        StringGrid.Cells[LEFT_EDITING_COL, Line] := Root + '=' + Left;
        Exit;
      end;
    end;
  end;
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

procedure TEditLangForm.StringsTSort(Lines: TStrings);
var
  I, L, R, P: Integer;
  S, OldPre, Pre: string;
begin
  if Lines.Count < 2 then
    Exit;

  I := 0;
  L := 0;
  R := 0;
  OldPre := '';
  while I < Lines.Count do
  begin
    S := Lines[I];
    if S = '' then
    begin
      Inc(I);
      Continue;
    end;

    if S[1] <> 'T' then
    begin
      Inc(I);
      Continue;
    end;

    P := Pos('=', S);
    if P <= 0 then
    begin
      Inc(I);
      Continue;
    end;

    P := Pos('.', S);
    if P <= 0 then
    begin
      Inc(I);
      Continue;
    end;

    Pre := Copy(S, 1, P - 1);
    if OldPre = '' then
    begin
      OldPre := Pre;
      L := I;
      R := I;
      Continue;
    end
    else if OldPre = Pre then
    begin
      Inc(R);
      Inc(I);
      Continue;
    end
    else if OldPre <> Pre then
    begin
      QuickSortStrings(Lines, L, R);
      OldPre := Pre;
      L := I;
      R := I;
      Inc(I);
      Continue;
    end;
  end;
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
  pnlLeftTop.Width := pnlTop.Width div 2 - 10;
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

procedure TEditLangForm.PasteToGridMultiLine(Col: Integer);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Text := Clipboard.AsText;
    if (SL.Count <= 0) or (Trim(SL[0]) = '') then
      Exit;

    if Trim(SL[SL.Count - 1]) = '' then
      SL.Delete(SL.Count - 1);

    for I := 0 to SL.Count - 1 do
    begin
      if StringGrid.Cells[Col, StringGrid.Row + I] <> '' then
      begin
        InfoDlg('Destination Cells NOT Empty. Can NOT Paste');
        Exit;
      end;
    end;

    for I := 0 to SL.Count - 1 do
      StringGrid.Cells[Col, StringGrid.Row + I] := SL[I];
  finally
    SL.Free;
  end;
end;

procedure TEditLangForm.RearrangeDisplays;
var
  I, L, R, LS, RS, LAC, RAC: Integer;
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
        // 左不动，右边找到了，左边加 RAC 个空行后加L，右边加 R 一直加到 RS
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
        // 右不动，左边找到了，右边加 LAC 个空行后加 R，左边加L一直加到 LS
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

procedure TEditLangForm.actCopyLeftEmptyExecute(Sender: TObject);
var
  I: Integer;
  List: TStringList;
begin
  // Copy Right Lines that has NO Corresponding Lines at Left Side to Clipboard.
  List := TStringList.Create;
  try
    for I := 0 to StringGrid.RowCount - 1 do
    begin
      if (StringGrid.Cells[LEFT_EDITING_COL, I] = '') or
        EndWithStr(StringGrid.Cells[LEFT_EDITING_COL, I], '=') then
        if StringGrid.Cells[RIGHT_EDITING_COL, I] <> '' then
          List.Add(StringGrid.Cells[RIGHT_EDITING_COL, I]);
    end;

    if List.Count > 0 then
    begin
      Clipboard.AsText := List.Text;
      ShowMessage(IntToStr(List.Count) + ' Line(s) Copied.');
    end
    else
      ShowMessage('No Content to Copy.');
  finally
    List.Free;
  end;
end;

procedure TEditLangForm.actCopyRightEmptyExecute(Sender: TObject);
var
  I: Integer;
  List: TStringList;
begin
  // Copy Left Lines that has NO Corresponding Lines at Right Side to Clipboard.
  List := TStringList.Create;
  try
    for I := 0 to StringGrid.RowCount - 1 do
    begin
      if (StringGrid.Cells[RIGHT_EDITING_COL, I] = '') or
        EndWithStr(StringGrid.Cells[RIGHT_EDITING_COL, I], '=') then
        if StringGrid.Cells[LEFT_EDITING_COL, I] <> '' then
          List.Add(StringGrid.Cells[LEFT_EDITING_COL, I]);
    end;

    if List.Count > 0 then
    begin
      Clipboard.AsText := List.Text;
      ShowMessage(IntToStr(List.Count) + ' Line(s) Copied.');
    end
    else
      ShowMessage('No Content to Copy.');
  finally
    List.Free;
  end;
end;

procedure TEditLangForm.actInsertItemsExecute(Sender: TObject);
begin
  // Show a Form to Insert Items
  with TInsertItemsForm.Create(nil) do
  begin
    ShowModal;
    Free;
  end
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

procedure TEditLangForm.actPasteMultiLineLeftExecute(Sender: TObject);
begin
  // 从左侧当前行、可编辑列多行竖向粘贴
  PasteToGridMultiLine(LEFT_EDITING_COL);
end;

procedure TEditLangForm.actPasteMultiLineRightExecute(Sender: TObject);
begin
  // 从右侧当前行、可编辑列多行竖向粘贴
  PasteToGridMultiLine(RIGHT_EDITING_COL);
end;

procedure TEditLangForm.actPasteToRightByLeftExecute(Sender: TObject);
var
  I, J, P, Sum: Integer;
  Sl: TStringList;
  S: string;
begin
  Sl := TStringList.Create;
  try
    Sl.Text := Clipboard.AsText;
    if Sl.Count = 0 then
      Exit;

    Sum := 0;
    for I := 0 to Sl.Count - 1 do
    begin
      S := Sl[I];
      P := Pos('=', S);
      if P > 0 then
      begin
        Delete(S, P + 1, MaxInt); // 只留=和左边的，拿着在左侧搜索

        for J := 0 to StringGrid.RowCount - 1 do
        begin
          if Pos(S, StringGrid.Cells[LEFT_EDITING_COL, J]) = 1  then
          begin
            if (StringGrid.Cells[RIGHT_EDITING_COL, J] = '') or
              EndWithStr(StringGrid.Cells[RIGHT_EDITING_COL, J], '=') then
            begin
              StringGrid.Cells[RIGHT_EDITING_COL, J] := Sl[I];
              Inc(Sum);
            end;
          end;
        end;
      end;
    end;
    ShowMessage('Paste ' + IntToStr(Sum) + ' Lines into Right.');
  finally
    Sl.Free;
  end;
end;

procedure TEditLangForm.actPastToLeftByRightExecute(Sender: TObject);
var
  I, J, P, Sum: Integer;
  Sl: TStringList;
  S: string;
begin
  Sl := TStringList.Create;
  try
    Sl.Text := Clipboard.AsText;
    if Sl.Count = 0 then
      Exit;

    Sum := 0;
    for I := 0 to Sl.Count - 1 do
    begin
      S := Sl[I];
      P := Pos('=', S);
      if P > 0 then
      begin
        Delete(S, P + 1, MaxInt); // 只留=和左边的，拿着在右侧搜索

        for J := 0 to StringGrid.RowCount - 1 do
        begin
          if Pos(S, StringGrid.Cells[RIGHT_EDITING_COL, J]) = 1  then
          begin
            if (StringGrid.Cells[LEFT_EDITING_COL, J] = '') or
              EndWithStr(StringGrid.Cells[LEFT_EDITING_COL, J], '=') then
            begin
              StringGrid.Cells[LEFT_EDITING_COL, J] := Sl[I];
              Inc(Sum);
            end;
          end;
        end;
      end;
    end;
    ShowMessage('Paste ' + IntToStr(Sum) + ' Lines into Left.');
  finally
    Sl.Free;
  end;
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
  if SaveLinesToFile(StringGrid.Cols[LEFT_EDITING_COL], FLeftFileName) then
    InfoDlg('Save Success. ' + FLeftFileName);
end;

procedure TEditLangForm.actSaveRightExecute(Sender: TObject);
begin
  if SaveLinesToFile(StringGrid.Cols[RIGHT_EDITING_COL], FRightFileName) then
    InfoDlg('Save Success. ' + FRightFileName);
end;

procedure TEditLangForm.actSearchAllLeftToRightExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to StringGrid.RowCount - 1 do
    SearchLeftToRight(I);
end;

procedure TEditLangForm.actSearchAllRightToLeftExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to StringGrid.RowCount - 1 do
    SearchRightToLeft(I);
end;

procedure TEditLangForm.actSearchLeftToRightExecute(Sender: TObject);
begin
  SearchLeftToRight(StringGrid.Row);
end;

procedure TEditLangForm.actSearchRightToLeftExecute(Sender: TObject);
begin
  SearchRightToLeft(StringGrid.Row);
end;

procedure TEditLangForm.actTSortLeftExecute(Sender: TObject);
begin
  StringsTSort(FLeftContent); // StringGrid.Cols[LEFT_EDITING_COL]);
  RearrangeDisplays;
  UpdateToGrid;
end;

procedure TEditLangForm.actTSortRightExecute(Sender: TObject);
begin
  StringsTSort(FRightContent); //StringGrid.Cols[RIGHT_EDITING_COL]);
  RearrangeDisplays;
  UpdateToGrid;
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

