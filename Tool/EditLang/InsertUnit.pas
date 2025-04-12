unit InsertUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TInsertItemsForm = class(TForm)
    pnlMain: TPanel;
    lbl2052: TLabel;
    mmo2052: TMemo;
    lbl1028: TLabel;
    mmo1028: TMemo;
    mmo1033: TMemo;
    lbl1033: TLabel;
    mmo1031: TMemo;
    lbl1031: TLabel;
    mmo10281: TMemo;
    lbl1036: TLabel;
    mmo1046: TMemo;
    lbl1046: TLabel;
    mmo1049: TMemo;
    lbl1049: TLabel;
    cbbFiles: TComboBox;
    btnInsert: TButton;
    procedure btnInsertClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLangRoot: string;
    FFiles: TStringList;
    function CheckLines: Boolean;
    function InsertFile(const FileName: string; Memo: TMemo): Boolean;
  public

  end;

var
  InsertItemsForm: TInsertItemsForm;

implementation

{$R *.dfm}

uses
  EditLangUnit;

procedure TInsertItemsForm.btnInsertClick(Sender: TObject);
var
  I: Integer;
  M: TMemo;
  F: string;
begin
  if CheckLines then
  begin
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TMemo then
      begin
        M := Components[I] as TMemo;
        F := FLangRoot + IntToStr(M.Tag) + '\' + cbbFiles.Text;

        if not InsertFile(F, M) then
        begin
          ShowMessage('Insert Failed!');
          Exit;
        end;
      end;
    end;
    ShowMessage('Insert Complete');
  end
  else
    ShowMessage('Line Count Error or NO =');
end;

function TInsertItemsForm.CheckLines: Boolean;
var
  I, J: Integer;
  M: TMemo;
begin
  Result := False;
  // 去掉 Memo 中的每一个空行，并且判断每行都有 = 和 .
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TMemo then
    begin
      M := Components[I] as TMemo;
      for J := M.Lines.Count - 1 downto 0 do
      begin
        if Trim(M.Lines[J]) = '' then
        begin
          M.Lines.Delete(J);
          Continue;
        end;

        if (Pos('=', M.Lines[J]) < 2) or (Pos('.', M.Lines[J]) < 2) then
          Exit;
      end;
    end;
  end;

  // 然后判断是否每个 Memo 的行数相等
  J := 0;
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TMemo then
    begin
      M := Components[I] as TMemo;
      if M.Lines.Count <= 0 then
        Exit;

      if J = 0 then
        J := M.Lines.Count
      else if J <> m.Lines.Count then
        Exit;
    end;
  end;

  Result := True;
end;

procedure TInsertItemsForm.FormCreate(Sender: TObject);
var
  Idx: Integer;
begin
  FLangRoot := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + LANG_DIR;
  FFiles := TStringList.Create;
  SearchLangFiles(FLangRoot + '2052\', FFiles, False);
  cbbFiles.Items.Assign(FFiles);

  Idx := cbbFiles.Items.IndexOf('CnWizards.txt');
  if Idx >= 0 then
    cbbFiles.ItemIndex := Idx;
end;

procedure TInsertItemsForm.FormDestroy(Sender: TObject);
begin
  FFiles.Free;
end;

function TInsertItemsForm.InsertFile(const FileName: string; Memo: TMemo): Boolean;
var
  I: Integer;
  SL: TStringList;

  function InsertOneLine(const Line: string): Boolean;
  var
    J, Idx, Start, Res, P: Integer;
    H: string;
  begin
    Result := False;

    H := Copy(Line, 1, Pos('.', Line) - 1); // T 开头的窗体名
    Idx := -1;
    for J := 0 to SL.Count - 1 do
    begin
      if Pos(H, SL[J]) = 1 then
      begin
        Idx := J;
        Break;
      end;
    end;

    if Idx < 0 then  // 没找到这窗体名，不能自动插入
      Exit;

    for J := Idx to SL.Count - 1 do
    begin
      Res := CompareStr(SL[J], Line);
      if Res > 0 then
      begin
        SL.Insert(J, Line);
        Result := True;
        Exit;
      end;
    end;
  end;

begin
  SL := TStringList.Create;
  try
    SL.Clear;
    SL.LoadFromFile(FileName);

    for I := Memo.Lines.Count - 1 downto 0 do
    begin
      if not InsertOneLine(Memo.Lines[I]) then
      begin
        ShowMessage('Error Insert: ' + Memo.Lines[I]);
        Exit;
      end;
      Memo.Lines.Delete(I);
    end;
    SL.SaveToFile(FileName);
    Result := True;
  finally
    SL.Free;
  end;
end;

end.
