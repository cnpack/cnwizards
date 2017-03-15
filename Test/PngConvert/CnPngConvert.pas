unit CnPngConvert;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormTestPng = class(TForm)
    grpPng2Bmp: TGroupBox;
    lblPng: TLabel;
    lblBmp: TLabel;
    edtPng: TEdit;
    edtBmp: TEdit;
    btnToBmp: TButton;
    btnBrowsePng: TButton;
    btnBrowseBmp: TButton;
    btnToPng: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowsePngClick(Sender: TObject);
    procedure btnBrowseBmpClick(Sender: TObject);
    procedure btnToBmpClick(Sender: TObject);
    procedure btnToPngClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTestPng: TFormTestPng;

implementation

uses
  CnPngUtils;

{$R *.dfm}

procedure TFormTestPng.btnBrowseBmpClick(Sender: TObject);
begin
  dlgOpen.Title := 'Select a BMP File';
  if dlgOpen.Execute then
    edtBmp.Text := dlgOpen.FileName;
end;

procedure TFormTestPng.btnBrowsePngClick(Sender: TObject);
begin
  dlgOpen.Title := 'Select a PNG File';
  if dlgOpen.Execute then
    edtPng.Text := dlgOpen.FileName;
end;

procedure TFormTestPng.btnToBmpClick(Sender: TObject);
var
  S, D: AnsiString;
begin
  if FileExists(edtPng.Text) then
    if dlgSave.Execute then
    begin
      S := AnsiString(edtPng.Text);
      D := AnsiString(dlgSave.FileName);
      if CnConvertPngToBmp(PAnsiChar(S), PAnsiChar(D)) then
        ShowMessage('PNG Convert OK.')
      else
        ShowMessage('PNG Convert Fail.');
    end;
end;

procedure TFormTestPng.btnToPngClick(Sender: TObject);
var
  S, D: AnsiString;
begin
  if FileExists(edtBmp.Text) then
    if dlgSave.Execute then
    begin
      S := AnsiString(edtBmp.Text);
      D := AnsiString(dlgSave.FileName);
      if CnConvertBmpToPng(PAnsiChar(S), PAnsiChar(D)) then
        ShowMessage('BMP Convert OK.')
      else
        ShowMessage('BMP Convert Fail.');
    end;
end;

procedure TFormTestPng.FormCreate(Sender: TObject);
var
  S: string;
begin
  S := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'apng8.png';
  if FileExists(S) then
    edtPng.Text := S;
end;

end.
