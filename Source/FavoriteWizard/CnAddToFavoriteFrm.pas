unit CnAddToFavoriteFrm;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, ToolsAPI, CnWizOptions, CnWizUtils, CnWizIdeUtils;

type
  TCnAddToFavoriteForm = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    tvFavorite: TTreeView;
    lblTo: TLabel;
    btnNewCategory: TButton;
    imgFavorite: TImage;
    GroupBox: TGroupBox;
    lblFileName: TLabel;
    lblProjectName: TLabel;
    lblPathName: TLabel;
    chkCurrFile: TCheckBox;
    chkCurrProject: TCheckBox;
    chkCurrPath: TCheckBox;
    edtFileName: TEdit;
    edtProjectName: TEdit;
    edtPathName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkCurrFileClick(Sender: TObject);
    procedure chkCurrProjectClick(Sender: TObject);
    procedure chkCurrPathClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure GetFileInfo;
  public
    { Public declarations }
  end;

function ShowAddToFavoriteForm: Boolean;

var
  CnAddToFavoriteForm: TCnAddToFavoriteForm;

implementation

{$IFDEF Debug}
uses
  uDbg;
{$ENDIF Debug}

{$R *.DFM}

function ShowAddToFavoriteForm: Boolean;
begin
  with TCnAddToFavoriteForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    //LoadSettings(Ini);
    Result := ShowModal = mrOk;
    //SaveSettings(Ini);

    if Result then
    begin

    end;
  finally
    Free;
  end;
end;

procedure TCnAddToFavoriteForm.FormCreate(Sender: TObject);
begin
//
end;

procedure TCnAddToFavoriteForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TCnAddToFavoriteForm.FormShow(Sender: TObject);
begin
  GetFileInfo;
end;

procedure TCnAddToFavoriteForm.chkCurrFileClick(Sender: TObject);
begin
  edtFileName.Enabled := chkCurrFile.Checked;
  if chkCurrFile.Checked then
    edtFileName.SetFocus;
end;

procedure TCnAddToFavoriteForm.chkCurrProjectClick(Sender: TObject);
begin
  edtProjectName.Enabled := chkCurrProject.Checked;
  if chkCurrProject.Checked then
    edtProjectName.SetFocus;
end;

procedure TCnAddToFavoriteForm.chkCurrPathClick(Sender: TObject);
begin
  edtPathName.Enabled := chkCurrPath.Checked;
  if chkCurrPath.Checked then
    edtPathName.SetFocus;
end;

procedure TCnAddToFavoriteForm.GetFileInfo;
var
  FormEditor: IOTAFormEditor;
  SourceEditor: IOTASourceEditor;
  Project: IOTAProject;
  Path: String;

function TopEditorIsFormEditor: Boolean;
var
  Idx: Integer;
begin
  Result := False;
  for Idx := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeDesignForm(Screen.CustomForms[Idx]) then
      Result := Screen.CustomForms[Idx].Handle = GetTopWindow(Application.Handle);
  end;
end;

begin
  Project := CnOtaGetCurrentProject;

  // Current File
  if TopEditorIsFormEditor then
  begin
    FormEditor := CnOtaGetCurrentFormEditor;
    chkCurrFile.Checked := True;
    edtFileName.Text := ExtractFileName(FormEditor.FileName);
    Path := ExtractFilePath(FormEditor.FileName);
  end
  else
    SourceEditor := CnOtaGetCurrentSourceEditor;
    if IsPas(SourceEditor.FileName) or IsCppSourceModule(SourceEditor.FileName) then
    begin
      chkCurrFile.Checked := True;
      edtFileName.Text := ExtractFileName(SourceEditor.FileName);
      Path := ExtractFilePath(SourceEditor.FileName);
    end
  else
  begin
    chkCurrFile.Checked := False;
    chkCurrFile.Enabled := False;
    edtFileName.Enabled := False;
  end;

  // Current Project
  if Project <> nil then
  begin
    edtProjectName.Text := ExtractFileName(Project.FileName);
    Path := ExtractFilePath(Project.FileName);
  end
  else
  begin
    chkCurrProject.Checked := False;
    chkCurrProject.Enabled := False;
    edtProjectName.Enabled := False;
  end;

  // Current Path
  if Path <> '' then
    edtPathName.Text := Path
  else
  begin
    chkCurrPath.Checked := False;
    chkCurrPath.Enabled := False;
    edtPathName.Enabled := False;
  end;
end;

procedure TCnAddToFavoriteForm.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    ModalResult := mrOk;
    Key := #0;
  end
  else if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end;
end;

end.
