unit UnitCompareProperties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, TypInfo, CnSampleComponent;

type
  TFormTestCompare = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    btnCompare: TButton;
    spl1: TSplitter;
    btnCompare2: TButton;
    procedure btnCompareClick(Sender: TObject);
    procedure btnCompare2Click(Sender: TObject);
  private
    FComp1, FComp2: TCnSampleComponent;
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

procedure TFormTestCompare.btnCompare2Click(Sender: TObject);
begin
  FreeAndNil(FComp1);
  FreeAndNil(FComp2);

  FComp1 := TCnSampleComponent.Create(Self);
  FComp2 := TCnSampleComponent.Create(Self);

  FComp2.WideHint := '2 Wide Hint';
  FComp2.Height := 65;
  FComp2.AccChar := 'p';
  FComp2.FloatValue := 2.71828;
  FComp1.Parent := Self;
  FComp1.Anchors := [akLeft, akRight, akTop, akBottom];
  FComp1.WideAccChar := 'X';
//  FComp1.Point.x := 9;
//  FComp1.Point.y := 18;

  HelpContext := GetOrdProp(FComp2, 'WideAccChar');
  CompareTwoObjects(FComp1, FComp2);
end;

end.
