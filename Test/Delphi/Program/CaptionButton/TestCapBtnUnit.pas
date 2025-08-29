unit TestCapBtnUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTestCaptionButtonForm = class(TForm)
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestCaptionButtonForm: TTestCaptionButtonForm;

implementation

{$R *.DFM}

uses
  mxCaptionBarButtons;

var
  CapBtn: TmxCaptionBarButtons = nil;

procedure TTestCaptionButtonForm.FormCreate(Sender: TObject);
begin
  CapBtn := TmxCaptionBarButtons.Create(Self);
  CapBtn.Name := 'TestCapBtn';
  with CapBtn.Buttons.Add do
  begin
    ButtonType := btStayOnTop;
    Hint := 'Stay On Top';
  end;
  with CapBtn.Buttons.Add do
  begin
    ButtonType := btRoller;
    Hint := 'Roll';
  end;
  CapBtn.Loaded;
  CapBtn.Refresh;
end;

end.
