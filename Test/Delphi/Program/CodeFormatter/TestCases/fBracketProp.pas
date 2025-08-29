unit fBracketProp;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Button2: TButton;
    Button3: TButton;
    CheckBox2: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ welcome to the freakshow of brackets}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (CheckBox1.Checked) then (CheckBox1.Checked := False);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if (CheckBox1.Checked) then
    (CheckBox1.Checked := False)
  else
    (CheckBox1.Checked := True);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if (CheckBox1.Checked) then
    (CheckBox1.Checked := False)
  else if (CheckBox2.Checked) then
    ((CheckBox1.Checked := not CheckBox1.Checked))
  else
    (((CheckBox1.Checked := false)));
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  liLoop: integer;
begin
  for liLoop := 0 to 100 do
    (CheckBox1.Checked := False);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  while CheckBox1.Checked do
    (CheckBox1.Checked := not CheckBox1.Checked);
end;
end.
