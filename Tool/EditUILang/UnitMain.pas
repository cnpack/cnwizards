unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormMain = class(TForm)
    MemoLeft: TMemo;
    MemoRight: TMemo;
    BtnOpenLeft: TButton;
    BtnOpenRight: TButton;
    BtnSaveRight: TButton;
    BtnXOR: TButton;
    BtnInsert: TButton;
    BtnCompareEqual: TButton;
    BtnSortLeft: TButton;
    BtnAppendEqual: TButton;
    BtnFilterMultiEqual: TButton;
    BtnFilterAmpMismatch: TButton;
    BtnCheckBRCount: TButton;
    BtnCheckAmpCount: TButton;
    ChkDotLogic: TCheckBox;
    BtnTabCopy: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    lblFile1: TLabel;
    lblFile2: TLabel;
    edtInsert: TEdit;
    btnInsertLine: TButton;
    btnSaveLeft: TButton;
    procedure BtnOpenLeftClick(Sender: TObject);
    procedure BtnOpenRightClick(Sender: TObject);
    procedure BtnSaveRightClick(Sender: TObject);
    procedure BtnXORClick(Sender: TObject);
    procedure BtnInsertClick(Sender: TObject);
    procedure BtnCompareEqualClick(Sender: TObject);
    procedure BtnSortLeftClick(Sender: TObject);
    procedure BtnAppendEqualClick(Sender: TObject);
    procedure BtnFilterMultiEqualClick(Sender: TObject);
    procedure BtnFilterAmpMismatchClick(Sender: TObject);
    procedure BtnCheckBRCountClick(Sender: TObject);
    procedure BtnCheckAmpCountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnTabCopyClick(Sender: TObject);
    procedure btnSaveLeftClick(Sender: TObject);
    procedure btnInsertLineClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // 初始化打开对话框
  OpenDialog.Filter := '文本文件 (*.txt)|*.txt|所有文件 (*.*)|*.*';
  OpenDialog.DefaultExt := 'txt';
  SaveDialog.Filter := '文本文件 (*.txt)|*.txt|所有文件 (*.*)|*.*';
  SaveDialog.DefaultExt := 'txt';
end;

procedure TFormMain.BtnOpenLeftClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    MemoLeft.Lines.LoadFromFile(OpenDialog.FileName);
    lblFile1.Caption := OpenDialog.FileName;
  end;
end;

procedure TFormMain.BtnOpenRightClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    MemoRight.Lines.LoadFromFile(OpenDialog.FileName);
    lblFile2.Caption := OpenDialog.FileName;
  end;
end;

procedure TFormMain.btnSaveLeftClick(Sender: TObject);
var
  StringList: TStringList;
begin
  if lblFile1.Caption = '' then
  begin
    if SaveDialog.Execute then
    begin
      StringList := TStringList.Create;
      try
        StringList.Assign(MemoLeft.Lines);
        StringList.SaveToFile(SaveDialog.FileName, TEncoding.UTF8);
      finally
        StringList.Free;
      end;
    end;
  end
  else if Application.MessageBox(PChar('是否保存至' + lblFile1.Caption),
    PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    StringList := TStringList.Create;
    try
      StringList.Assign(MemoLeft.Lines);
      StringList.SaveToFile(lblFile1.Caption, TEncoding.UTF8);
    finally
      StringList.Free;
    end;
  end;
end;

procedure TFormMain.BtnSaveRightClick(Sender: TObject);
var
  StringList: TStringList;
begin
  if lblFile2.Caption = '' then
  begin
    if SaveDialog.Execute then
    begin
      StringList := TStringList.Create;
      try
        StringList.Assign(MemoRight.Lines);
        StringList.SaveToFile(SaveDialog.FileName, TEncoding.UTF8);
      finally
        StringList.Free;
      end;
    end;
  end
  else if Application.MessageBox(PChar('是否保存至' + lblFile2.Caption),
    PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    StringList := TStringList.Create;
    try
      StringList.Assign(MemoRight.Lines);
      StringList.SaveToFile(lblFile2.Caption, TEncoding.UTF8);
    finally
      StringList.Free;
    end;
  end;
end;

function MySortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareStr(List[Index1], List[Index2]);
end;

procedure TFormMain.BtnSortLeftClick(Sender: TObject);
var
  StringList: TStringList;
  I: Integer;
begin
  StringList := TStringList.Create;
  try
    StringList.Assign(MemoLeft.Lines);
    StringList.CustomSort(MySortCompare);

    // 去重
    for I := StringList.Count - 1 downto 1 do
    begin
      if StringList[I] = StringList[I - 1] then
        StringList.Delete(I);
    end;

    MemoLeft.Lines.Assign(StringList);
  finally
    StringList.Free;
  end;
end;

procedure TFormMain.BtnAppendEqualClick(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  for I := 0 to MemoLeft.Lines.Count - 1 do
  begin
    S := MemoLeft.Lines[I];
    if Pos('=', S) = 0 then
      MemoLeft.Lines[I] := S + '=' + S;
  end;
end;

procedure TFormMain.BtnXORClick(Sender: TObject);
var
  I, J: Integer;
  LeftLine, RightLine: string;
  NeedDelete: Boolean;
  function IsSameLine(const A, B: string): Boolean;
  var
    EqPosA, EqPosB: Integer;
    LeftA, LeftB: string;
    RightA, RightB: string;
  begin
    EqPosA := Pos('=', A);
    EqPosB := Pos('=', B);
    if (EqPosA = 0) or (EqPosB = 0) then
    begin
      Result := A = B;
      Exit;
    end;

    LeftA := Copy(A, 1, EqPosA - 1);
    LeftB := Copy(B, 1, EqPosB - 1);
    RightA := Trim(Copy(A, EqPosA + 1, MaxInt));
    RightB := Trim(Copy(B, EqPosB + 1, MaxInt));
    Result := (LeftA = LeftB) and (RightA = RightB);
  end;
begin
  // 倒序遍历左边Memo的每一行
  for I := MemoLeft.Lines.Count - 1 downto 0 do
  begin
    LeftLine := MemoLeft.Lines[I];

    // 与右边Memo中的每一行去匹配
    NeedDelete := False;
    for J := 0 to MemoRight.Lines.Count - 1 do
    begin
      RightLine := MemoRight.Lines[J];

      // 如果整行相等
      if IsSameLine(LeftLine, RightLine) then
      begin
        NeedDelete := True;
        Break;
      end;
    end;

    // 删掉左边Memo中的这行
    if NeedDelete then
      MemoLeft.Lines.Delete(I);
  end;

  ShowMessage('处理完成！');
end;

procedure TFormMain.BtnInsertClick(Sender: TObject);
var
  I, J, InsertPos: Integer;
  LeftLine: string;
  EqPos: Integer;
  LeftPart: string;
  NeedIgnore: Boolean;
  LeftHasDot: Boolean;   // 左边条目等号前是否含点号
  SearchStart: Integer;  // 右边开始搜索插入位置的起始下标

  function GetPartBeforeEqual(const S: string): string;
  var
    P: Integer;
  begin
    P := Pos('=', S);
    if P > 0 then
      Result := Copy(S, 1, P - 1)
    else
      Result := S;
  end;

  // 判断等号前的部分是否含点号
  function PartBeforeEqualHasDot(const S: string): Boolean;
  var
    P: Integer;
    Part: string;
  begin
    P := Pos('=', S);
    if P > 0 then
      Part := Copy(S, 1, P - 1)
    else
      Part := S;
    Result := Pos('.', Part) > 0;
  end;

begin
  for I := MemoLeft.Lines.Count - 1 downto 0 do
  begin
    LeftLine := MemoLeft.Lines[I];
    NeedIgnore := False;

    EqPos := Pos('=', LeftLine);
    if EqPos > 0 then
    begin
      LeftPart := Copy(LeftLine, 1, EqPos - 1);
      for J := 0 to MemoRight.Lines.Count - 1 do
      begin
        if GetPartBeforeEqual(MemoRight.Lines[J]) = LeftPart then
        begin
          NeedIgnore := True;
          Break;
        end;
      end;
    end;

    if NeedIgnore then
      Continue;

    // 判断左边条目等号前是否有点号
    LeftHasDot := PartBeforeEqualHasDot(LeftLine);

    // 如果勾选了点号逻辑，且左边条目等号前没有点号，则在右边跳过所有等号前有点号的条目，
    // 找到第一条等号前没有点号的条目，再从那里开始搜索字母顺序插入位置
    SearchStart := 0;
    if ChkDotLogic.Checked and not LeftHasDot then
    begin
      // 默认：右边全是有点号条目时，插入到末尾
      SearchStart := MemoRight.Lines.Count;
      for J := 0 to MemoRight.Lines.Count - 1 do
      begin
        if not PartBeforeEqualHasDot(MemoRight.Lines[J]) then
        begin
          SearchStart := J;
          Break;
        end;
      end;
    end;

    InsertPos := MemoRight.Lines.Count;
    for J := SearchStart to MemoRight.Lines.Count - 1 do
    begin
      if AnsiCompareStr(LeftLine, MemoRight.Lines[J]) < 0 then
      begin
        InsertPos := J;
        Break;
      end;
    end;
    MemoRight.Lines.Insert(InsertPos, LeftLine);
    MemoLeft.Lines.Delete(I);
  end;

  ShowMessage('插入完成！');
end;

procedure TFormMain.btnInsertLineClick(Sender: TObject);
var
  InputLine: string;
  EqPos: Integer;
  KeyPart: string;
  LeftLine: string;
  LeftInsertPos: Integer;
  RightInsertPos: Integer;
  I: Integer;
begin
  InputLine := Trim(edtInsert.Text);
  if InputLine = '' then
  begin
    ShowMessage('请输入待插入内容。');
    Exit;
  end;

  EqPos := Pos('=', InputLine);
  if EqPos = 0 then
  begin
    ShowMessage('输入内容必须包含等号。');
    Exit;
  end;

  KeyPart := Copy(InputLine, 1, EqPos - 1);
  LeftLine := KeyPart + '=' + KeyPart;
  LeftInsertPos := MemoLeft.Lines.Count;
  for I := 0 to MemoLeft.Lines.Count - 1 do
  begin
    if CompareStr(LeftLine, MemoLeft.Lines[I]) < 0 then
    begin
      LeftInsertPos := I;
      Break;
    end;
  end;
  MemoLeft.Lines.Insert(LeftInsertPos, LeftLine);

  RightInsertPos := MemoRight.Lines.Count;
  for I := 0 to MemoRight.Lines.Count - 1 do
  begin
    if CompareStr(InputLine, MemoRight.Lines[I]) < 0 then
    begin
      RightInsertPos := I;
      Break;
    end;
  end;
  MemoRight.Lines.Insert(RightInsertPos, InputLine);

  ShowMessage('左侧插入到第 ' + IntToStr(LeftInsertPos + 1) + ' 行，右侧插入到第 ' +
    IntToStr(RightInsertPos + 1) + ' 行。');

  edtInsert.Clear;
end;

procedure TFormMain.BtnCompareEqualClick(Sender: TObject);
var
  I: Integer;
  LeftLine, RightLine: string;
  EqPosLeft, EqPosRight: Integer;
  LeftPart, RightPart: string;
begin
  for I := 0 to MemoLeft.Lines.Count - 1 do
  begin
    if I >= MemoRight.Lines.Count then
    begin
      ShowMessage(IntToStr(I + 1));
      Exit;
    end;

    LeftLine := MemoLeft.Lines[I];
    RightLine := MemoRight.Lines[I];
    EqPosLeft := Pos('=', LeftLine);
    EqPosRight := Pos('=', RightLine);

    if (EqPosLeft = 0) and (EqPosRight = 0) then
    begin
      if LeftLine <> RightLine then
      begin
        ShowMessage(IntToStr(I + 1));
        Exit;
      end;
    end
    else if (EqPosLeft > 0) and (EqPosRight > 0) then
    begin
      LeftPart := Copy(LeftLine, 1, EqPosLeft - 1);
      RightPart := Copy(RightLine, 1, EqPosRight - 1);
      if LeftPart <> RightPart then
      begin
        ShowMessage(IntToStr(I + 1));
        Exit;
      end;
    end
    else
    begin
      ShowMessage(IntToStr(I + 1));
      Exit;
    end;
  end;

  ShowMessage('比较完成，未发现不相等行');
end;

procedure TFormMain.BtnFilterMultiEqualClick(Sender: TObject);
var
  I, EqCount, P: Integer;
  S: string;
begin
  // 只保留含两个或以上等号的行
  for I := MemoLeft.Lines.Count - 1 downto 0 do
  begin
    S := MemoLeft.Lines[I];
    EqCount := 0;
    P := 1;
    while P <= Length(S) do
    begin
      if S[P] = '=' then
        Inc(EqCount);
      Inc(P);
    end;
    if EqCount < 2 then
      MemoLeft.Lines.Delete(I);
  end;
end;

procedure TFormMain.BtnFilterAmpMismatchClick(Sender: TObject);
var
  I, EqPos: Integer;
  S, LeftPart, RightPart: string;
  LeftHasAmp, RightHasAmp: Boolean;
begin
  // 只保留等号左右两边 & 出现情况不一致的行（一边有一边没有）
  // 没有等号的行直接删除
  for I := MemoLeft.Lines.Count - 1 downto 0 do
  begin
    S := MemoLeft.Lines[I];
    EqPos := Pos('=', S);
    if EqPos = 0 then
    begin
      MemoLeft.Lines.Delete(I);
      Continue;
    end;
    LeftPart  := Copy(S, 1, EqPos - 1);
    RightPart := Copy(S, EqPos + 1, MaxInt);
    LeftHasAmp  := Pos('&', LeftPart)  > 0;
    RightHasAmp := Pos('&', RightPart) > 0;
    // 两边一致（都有或都没有）则删除
    if LeftHasAmp = RightHasAmp then
      MemoLeft.Lines.Delete(I);
  end;
end;

procedure TFormMain.BtnCheckBRCountClick(Sender: TObject);
var
  I, J, EqPos: Integer;
  LeftLine, RightLine, Prefix: string;

  function CountBR(const S: string): Integer;
  var
    P: Integer;
    Upper: string;
  begin
    Result := 0;
    Upper := UpperCase(S);
    P := 1;
    while P <= Length(Upper) - 3 do
    begin
      if Copy(Upper, P, 4) = '<BR>' then
      begin
        Inc(Result);
        Inc(P, 4);
      end
      else
        Inc(P);
    end;
  end;

begin
  for I := 0 to MemoLeft.Lines.Count - 1 do
  begin
    LeftLine := MemoLeft.Lines[I];
    EqPos := Pos('=', LeftLine);
    if EqPos = 0 then
      Continue;

    // 等号左边部分加上等号本身，作为匹配前缀
    Prefix := Copy(LeftLine, 1, EqPos);

    // 在右边每一行的行首匹配
    for J := 0 to MemoRight.Lines.Count - 1 do
    begin
      RightLine := MemoRight.Lines[J];
      if Copy(RightLine, 1, Length(Prefix)) = Prefix then
      begin
        // 找到匹配行，检查 <BR> 数量
        if CountBR(LeftLine) <> CountBR(RightLine) then
        begin
          ShowMessage('第 ' + IntToStr(I + 1) + ' 行（左）与右边第 ' +
            IntToStr(J + 1) + ' 行的 <BR> 数量不一致');
          Exit;
        end;
        Break;
      end;
    end;
  end;

  ShowMessage('检查完成，<BR> 数量均一致');
end;

procedure TFormMain.BtnCheckAmpCountClick(Sender: TObject);
var
  I, J, EqPos: Integer;
  LeftLine, RightLine, Prefix: string;

  function CountAmp(const S: string): Integer;
  var
    P: Integer;
  begin
    Result := 0;
    P := 1;
    while P <= Length(S) do
    begin
      if S[P] = '&' then
        Inc(Result);
      Inc(P);
    end;
  end;

begin
  for I := 0 to MemoLeft.Lines.Count - 1 do
  begin
    LeftLine := MemoLeft.Lines[I];
    EqPos := Pos('=', LeftLine);
    if EqPos = 0 then
      Continue;

    Prefix := Copy(LeftLine, 1, EqPos);
    for J := 0 to MemoRight.Lines.Count - 1 do
    begin
      RightLine := MemoRight.Lines[J];
      if Copy(RightLine, 1, Length(Prefix)) = Prefix then
      begin
        Delete(LeftLine, 1, Length(Prefix));
        Delete(RightLine, 1, Length(Prefix));
        if (LeftLine = 'OK') or (LeftLine = 'Cancel') or (LeftLine = 'Help')
          or (LeftLine = 'Save') or (LeftLine = 'Delete') or (LeftLine = 'Close') then
          Continue;

        if CountAmp(LeftLine) <> CountAmp(RightLine) then
        begin
          ShowMessage('第 ' + IntToStr(I + 1) + ' 行（左）与右边第 ' +
            IntToStr(J + 1) + ' 行的 & 数量不一致');
        end;
        Break;
      end;
    end;
  end;

  ShowMessage('检查完成');
end;

procedure TFormMain.BtnTabCopyClick(Sender: TObject);
var
  I, TabPos: Integer;
  S, LeftPart: string;
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Assign(MemoLeft.Lines);
  SL.BeginUpdate;
  for I := SL.Count - 1 downto 0 do
  begin
    S := SL[I];
    TabPos := Pos(#9, S);
    if TabPos > 0 then
    begin
      LeftPart := Copy(S, 1, TabPos - 1);
      SL[I] := LeftPart + '=' + LeftPart;
    end;
  end;
  SL.EndUpdate;
  MemoLeft.Lines.Assign(SL);
  SL.Free;
end;

end.

