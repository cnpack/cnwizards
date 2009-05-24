unit CnManageFavoriteFrm;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls,
  ComCtrls, CnWizOptions, Graphics, ExtCtrls;

type
  TCnManageFavoriteForm = class(TForm)
    tvFavorite: TTreeView;
    btnReName: TButton;
    btnDelete: TButton;
    lblFavoriteTree: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    btnNewCategory: TButton;
    lblPath: TLabel;
    imgFavorite: TImage;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowManageFavoriteForm: Boolean;

var
  CnManageFavoriteForm: TCnManageFavoriteForm;

implementation

{$IFDEF Debug}
uses
  uDbg;
{$ENDIF Debug}

{$R *.DFM}

function ShowManageFavoriteForm: Boolean;
begin
  with TCnManageFavoriteForm.Create(nil) do
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

procedure TCnManageFavoriteForm.FormKeyPress(Sender: TObject;
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

procedure TCnManageFavoriteForm.FormCreate(Sender: TObject);
begin
//
end;

procedure TCnManageFavoriteForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TCnManageFavoriteForm.FormShow(Sender: TObject);
begin
//
end;

end.
