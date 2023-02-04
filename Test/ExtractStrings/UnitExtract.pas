unit UnitExtract;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormExtract = class(TForm)
    btnConvertIdent: TButton;
    mmoStrings: TMemo;
    chkUnderLine: TCheckBox;
    mmoIdent: TMemo;
    procedure btnConvertIdentClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormExtract: TFormExtract;

implementation

{$R *.DFM}

uses
  CnCommon;

procedure TFormExtract.btnConvertIdentClick(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  mmoIdent.Lines.Clear;
  for I := 0 to mmoStrings.Lines.Count - 1 do
  begin
    S := ConvertStringToIdent(mmoStrings.Lines[I], 'SCN', chkUnderLine.Checked);
    mmoIdent.Lines.Add(S);
  end;
end;

end.
