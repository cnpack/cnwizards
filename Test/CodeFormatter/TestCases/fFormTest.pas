unit fFormTest;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TFormTest = class(TForm)
    bbClose: TBitBtn;
    mNotice: TMemo;
    procedure bbCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTest: TFormTest;

implementation

{$R *.DFM}

procedure TFormTest.bbCloseClick(Sender: TObject);
begin
  Close;
  Application.Terminate;
  Halt;
end;

end.