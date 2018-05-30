unit UnitParse;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TParseForm = class(TForm)
    lblForm: TLabel;
    edtFile: TEdit;
    btnParse: TButton;
    dlgOpen: TOpenDialog;
    btnBrowse: TButton;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ParseForm: TParseForm;

implementation

uses
  CnWizDfmParser;

{$R *.DFM}

procedure TParseForm.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    edtFile.Text := dlgOpen.FileName;
end;

procedure TParseForm.btnParseClick(Sender: TObject);
var
  Info: TDfmInfo;
begin
  Info := TDfmInfo.Create;
  try
    if FileExists(edtFile.Text) then
    begin
      ParseDfmFile(edtFile.Text, Info);
      ShowMessage(Info.Name);
    end;
  finally
    Info.Free;
  end;
end;

end.
