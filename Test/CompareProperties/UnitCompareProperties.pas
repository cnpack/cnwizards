unit UnitCompareProperties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TFormTestCompare = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    btnCompare: TButton;
    spl1: TSplitter;
    procedure btnCompareClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTestCompare: TFormTestCompare;

implementation

uses
  CnPropertyCompareFrm;

{$R *.DFM}

procedure TFormTestCompare.btnCompareClick(Sender: TObject);
begin
  CompareTwoObjects(Button1, CheckBox1);
end;

end.
