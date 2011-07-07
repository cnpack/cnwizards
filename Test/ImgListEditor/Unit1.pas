unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, ComCtrls, CnImageListEditorFrm, CnCommon,
  IniFiles, Registry;

type
  TImgListEdtTestForm = class(TForm)
    il1: TImageList;
    btnTest: TButton;
    lbl1: TLabel;
    procedure btnTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FIni: TCustomIniFile;
  public
    { Public declarations }
  end;

var
  ImgListEdtTestForm: TImgListEdtTestForm;

implementation

{$R *.dfm}

procedure TImgListEdtTestForm.btnTestClick(Sender: TObject);
begin
  ShowCnImageListEditorForm(il1, FIni, nil);
end;

procedure TImgListEdtTestForm.FormCreate(Sender: TObject);
var
  Sup, Valid: Boolean;
begin
  FIni := TRegistryIniFile.Create('\Software\CnPack\Test\ImgListEdtTest');
  if CheckXPManifest(Sup, Valid) then
    lbl1.Caption := Format('Check XPManifest: OS Support[%s] App Valid[%s]',
      [BoolToStr(Sup, True), BoolToStr(Valid, True)])
  else
    lbl1.Caption := 'Check XPManifest fail.';
end;

procedure TImgListEdtTestForm.FormDestroy(Sender: TObject);
begin
  FIni.Free;
end;

end.
 