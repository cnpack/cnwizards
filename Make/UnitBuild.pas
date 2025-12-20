unit UnitBuild;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ExtCtrls;

type
  TAppBuillder = class(TForm)
    btnRunWant: TButton;
    cbbTarget: TComboBox;
    rgDef: TRadioGroup;
    lbl1: TLabel;
    procedure btnRunWantClick(Sender: TObject);
  private

  public

  end;

var
  AppBuillder: TAppBuillder;

implementation

{$R *.dfm}

procedure TAppBuillder.btnRunWantClick(Sender: TObject);
var
  S, Cmd, Param: string;
begin
  S := '';
  case rgDef.ItemIndex of
    0: S := ' -Dnightly=true';
    1: S := ' -Ddebug=true';
    2: S := ' -Dpreview=true';
    3: S := ' -Drelease=true';
  end;

  Cmd := ExtractFilePath(Application.ExeName) + 'want.exe';
  Param := cbbTarget.Text;
  if S <> '' then
    Param := Param + S;

  ShellExecute(0, 'open', PChar(Cmd), PChar(Param),
    PChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL);
end;

end.
