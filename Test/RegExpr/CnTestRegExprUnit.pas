unit CnTestRegExprUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RegExpr;

type
  TTestRegExprForm = class(TForm)
    lblPattern: TLabel;
    lblContent: TLabel;
    edtPattern: TEdit;
    edtContent: TEdit;
    btnCheck: TButton;
    chkCase: TCheckBox;
    btnCheckUpperW: TButton;
    procedure btnCheckClick(Sender: TObject);
    procedure btnCheckUpperWClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestRegExprForm: TTestRegExprForm;

implementation

{$R *.DFM}

function RegExpContainsText(ARegExpr: TRegExpr; const AText: string;
  APattern: string; IsMatchStart: Boolean = False): Boolean;
begin
  Result := True;
  if (APattern = '') or (ARegExpr = nil) then Exit;

  if IsMatchStart and (APattern[1] <> '^') then // 额外的从头匹配
    APattern := '^' + APattern;

  ARegExpr.Expression := APattern;
  try
    Result := ARegExpr.Exec(AText);
  except
    Result := False;
  end;
end;

procedure TTestRegExprForm.btnCheckClick(Sender: TObject);
var
  RegExpr: TRegExpr;
begin
  RegExpr := TRegExpr.Create;
  RegExpr.ModifierI := not chkCase.Checked;

  if RegExpContainsText(RegExpr, edtContent.Text, edtPattern.Text) then
    ShowMessage('Matched.')
  else
    ShowMessage('Not Matched.');
end;

procedure TTestRegExprForm.btnCheckUpperWClick(Sender: TObject);
{$IFDEF UNICODE}
var
  W, R: WideChar;
{$ENDIF}
begin
{$IFDEF UNICODE}
  W := 'C';
  R := WideChar(CharUpper(PChar(W)));

  R := CharUpper(W);
{$ENDIF}
end;

end.
