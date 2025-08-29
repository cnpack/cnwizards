unit UnitTestFastList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTestFastListForm = class(TForm)
    btnAssign: TButton;
    procedure btnAssignClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestFastListForm: TTestFastListForm;

implementation

{$R *.DFM}

uses
  CnFastList;

procedure TTestFastListForm.btnAssignClick(Sender: TObject);
const
  COUNT = 10000000;
var
  I: Integer;
  L1, L2: TCnList;
  T: Integer;
  S: string;
begin
  L1 := TCnList.Create;

  T := GetTickCount;
  for I := 0 to COUNT - 1 do
    L1.Add(nil);
  T := GetTickCount - T;

  S := Format('L1: Time %d. Count %d. Capacity %d.', [T, L1.Count, L1.Capacity]);
  ShowMessage(S);

  L2 := TCnList.Create;
  T := GetTickCount;
  L2.Assign(L1);
  T := GetTickCount - T;

  S := Format('L2: Time %d. Count %d. Capacity %d.', [T, L2.Count, L2.Capacity]);
  ShowMessage(S);
  
  L2.Free;
  L1.Free;
end;

end.
