unit TestToolbarResizeUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ToolWin, ExtCtrls, ComCtrls;

type
  TTestResizeForm = class(TForm)
    btnCreate: TButton;
    lbl1: TLabel;
    procedure btnCreateClick(Sender: TObject);
  private
    { Private declarations }
    Toolbar: TWinControl;
    Combo1, Combo2:TComboBox;
    Splitter: TSplitter;
  public
    { Public declarations }
  end;

var
  TestResizeForm: TTestResizeForm;

implementation

{$R *.dfm}

procedure TTestResizeForm.btnCreateClick(Sender: TObject);
begin
  if Toolbar <> nil then
    Exit;

  Toolbar := TToolBar.Create(Self);
  Toolbar.Parent := Self;

  Combo1 := TComboBox.Create(Toolbar);
  Combo1.Parent := Toolbar;
  Combo1.Top := 0;
  Combo1.Width := 150;
  Combo1.Height := 21;
  // Combo1.Align := alLeft; // If use this line, OK. if commented, Not OK under XE4 or above.

  Splitter := TSplitter.Create(Toolbar);
  Splitter.Align := alLeft;
  Splitter.Width := 5;
  Splitter.MinSize := 40;
  Splitter.Parent := Toolbar;
  Splitter.Left := Combo1.Left + Combo1.Width - 1;

  Combo2 := TComboBox.Create(Toolbar);
  Combo2.Parent := Toolbar;
  Combo2.Top := 0;
  Combo2.Width := 250;
  Combo2.Height := 21;
  Combo2.Left := Splitter.Left + Splitter.Width + 1;
end;

end.
