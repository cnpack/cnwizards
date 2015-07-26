unit EditLangUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, CnCommon, ExtCtrls, StdCtrls, ComCtrls, CnMemo;

type
  TEditLangForm = class(TForm)
    pnlLeft: TPanel;
    spl1: TSplitter;
    pnlRight: TPanel;
    pnlLeftTop: TPanel;
    cbbLeftDir: TComboBox;
    cbbLeftFile: TComboBox;
    pnlRightTop: TPanel;
    cbbRightDir: TComboBox;
    cbbRightFile: TComboBox;
    statMain: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbbLeftDirChange(Sender: TObject);
    procedure cbbRightDirChange(Sender: TObject);
    procedure cbbLeftFileChange(Sender: TObject);
    procedure cbbRightFileChange(Sender: TObject);
  private
    mmoLeft: TCnMemo;
    mmoRight: TCnMemo;

    FLangRoot: string;
    FLangDirs: TStrings;
    FLeftLangFiles: TStrings;
    FRightLangFiles: TStrings;
    procedure SearchLangFiles(const Dir: string; List: TStrings; IsDir: Boolean);
  public
    { Public declarations }
  end;

var
  EditLangForm: TEditLangForm;

implementation

{$R *.DFM}

const
  LANG_DIR = 'Lang\';

procedure TEditLangForm.FormCreate(Sender: TObject);
begin
{$IFNDEF UNICODE}
  ShowMessage('Must Run under Unicode Environment.');
  Application.Terminate;
{$ENDIF}
  FLangRoot := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + LANG_DIR;
  FLangDirs := TStringList.Create;

  SearchLangFiles(FLangRoot, FLangDirs, True);

  cbbLeftDir.Items.Assign(FLangDirs);
  cbbRightDir.Items.Assign(FLangDirs);

  mmoLeft := TCnMemo.Create(Self);
  with mmoLeft do
  begin
    Align := alClient;
    ShowLineNumber := True;
    Parent := pnlLeft;
    ScrollBars := ssBoth;
  end;

  mmoRight := TCnMemo.Create(Self);
  with mmoRight do
  begin
    Align := alClient;
    ShowLineNumber := True;
    Parent := pnlRight;
    ScrollBars := ssBoth;
  end;
end;

procedure TEditLangForm.FormDestroy(Sender: TObject);
begin
  FLangDirs.Free;
  FLeftLangFiles.Free;
  FRightLangFiles.Free;
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

procedure TEditLangForm.FormResize(Sender: TObject);
const
  MARGIN = 10;
begin
  pnlLeft.Width := Width div 2 - MARGIN;
  statMain.Panels[0].Width := Width div 2 - MARGIN;
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
begin
  if (cbbRightFile.Items.Count > 0) and (cbbRightFile.ItemIndex > 0) then
    mmoRight.Lines.LoadFromFile(FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbRightDir.ItemIndex])
      + cbbRightFile.Items[cbbRightFile.ItemIndex]);
end;

procedure TEditLangForm.cbbLeftFileChange(Sender: TObject);
begin
  if (cbbLeftFile.Items.Count > 0) and (cbbLeftFile.ItemIndex > 0) then
    mmoLeft.Lines.LoadFromFile(FLangRoot + IncludeTrailingPathDelimiter(FLangDirs[cbbLeftDir.ItemIndex])
      + cbbLeftFile.Items[cbbLeftFile.ItemIndex]);
end;

end.

