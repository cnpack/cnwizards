unit UnitRuntimeSale;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormRuntimeTest = class(TForm)
    lblScale: TLabel;
    cbbScale: TComboBox;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    procedure cbbScaleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormRuntimeTest: TFormRuntimeTest;

  GlobalScaleFactor: Single = 1.0;

implementation

uses
  TestEditorCodeToString, TestEditorCodeComment, TestEditorWizard;

{$R *.DFM}

procedure TFormRuntimeTest.cbbScaleChange(Sender: TObject);
begin
  try
    GlobalScaleFactor := StrToFloat(cbbScale.Text);
  except
    GlobalScaleFactor := 1.0;
  end;
end;

procedure TFormRuntimeTest.FormCreate(Sender: TObject);
begin
  GlobalScaleFactor := StrToFloat(cbbScale.Text);
end;

procedure TFormRuntimeTest.btn1Click(Sender: TObject);
begin
  with TEditorCodeToStringForm.Create(Application) do
  begin
    Show;
  end;
end;

procedure TFormRuntimeTest.btn2Click(Sender: TObject);
begin
  with TEditorCodeCommentForm.Create(Application) do
  begin
    Show;
  end;
end;

procedure TFormRuntimeTest.btn3Click(Sender: TObject);
begin
  with TEditorToolsForm.Create(Application) do
  begin
    Show;
  end;
end;

end.
