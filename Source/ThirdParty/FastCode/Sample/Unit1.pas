unit Unit1;

interface

uses
  Forms, Windows, ExtCtrls, Classes, Controls, Grids;

type
  TForm1 = class(TForm)
    StringGrid: TStringGrid;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  SysUtils, StrUtils, Graphics, FastCode;

procedure TForm1.FormCreate(Sender: TObject);
const
 SrcArray : array[0..12] of Char =
  ('1','2','3','4','5','6','7','8','9','0','A','B',#0);
var
  i: Integer;
  Dest, Src: PChar;
  DestArray: array[0..12] of Char;
begin
  Caption := Caption + FastCodeRTLVersion;

  with StringGrid do
  begin
    Cells[1, 0] := 'Delphi Result';
    Cells[2, 0] := 'FastCode Result';
    Cells[3, 0] := 'Correct';

    Cells[0, 0] := 'Routine';
    Cells[0, 1] := 'Pos';
    Cells[0, 2] := 'PosEx';
    Cells[0, 3] := 'LowerCase';
    Cells[0, 4] := 'UpperCase';
    Cells[0, 5] := 'CompareText';
    Cells[0, 6] := 'StrComp';
    Cells[0, 7] := 'StrCopy';
    Cells[0, 8] := 'StrLen';
    Cells[0, 9] := 'AnsiStringReplace';
    Cells[0, 10] := 'StrToInt32';
    Cells[0, 11] := 'StrIComp';

    // Pos
    Cells[1, 1] := '3';
    Cells[2, 1] := IntToStr(Pos('l', 'Hello world'));

    // PosEx
    Cells[1, 2] := '2';
    Cells[2, 2] := IntToStr(PosEx('el', 'Hello'));

    // LowerCase
    Cells[1, 3] := 'test';
    Cells[2, 3] := LowerCase('TEST');

    // UpperCase
    Cells[1, 4] := 'TEST';
    Cells[2, 4] := UpperCase('test');

    // CompareText
    Cells[1, 5] := '0';
    Cells[2, 5] := IntToStr(CompareText('HeLLo', 'Hello'));

    // StrComp
    Cells[1, 6] := '0';
    Cells[2, 6] := IntToStr(StrComp('Hello', 'Hello'));

    // StrCopy
    Dest := @DestArray[0];
    Src := @SrcArray[0];
    StrCopy(Dest, Src);

    Cells[1, 7] := '1234567890AB';
    Cells[2, 7] := Dest;

    // StrLen
    Cells[1, 8] := '5';
    Cells[2, 8] := IntToStr(StrLen('Hello'));

    // StringReplace
    Cells[1, 9] := 'Haaao';
    Cells[2, 9] := StringReplace('Hello', 'eLl', 'aaa', [rfReplaceAll,
      rfIgnoreCase]);

    // StrToInt32
    Cells[1, 10] := '1234567890';
    Cells[2, 10] := IntToStr(StrToInt('1234567890'));

    // StrIComp;
    Cells[1, 11] := '7';
    Cells[2, 11] := IntToStr(StrIComp('Hello', 'aBcDHELLOefg'));

    for i := 1 to RowCount - 1 do
      Cells[3, i] := BoolToStr(Cells[2, i] = Cells[1, i], True);
  end;
end;

procedure TForm1.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  with TStringGrid(Sender) do
  begin
    if ARow = 0 then
    begin
      Canvas.Brush.Color := clGray;
      Canvas.Font.Color := clWhite;
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 4, Rect.Top +4, Cells[ACol, ARow]);
    end
    else
    if Cells[3, ARow] = 'True' then
    begin
      Canvas.Brush.Color := $00F2EFEA;
      Canvas.Font.Color := clBlack;
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 4, Rect.Top +4, Cells[ACol, ARow]);
    end
    else
    begin
      Canvas.Brush.Color := clRed;
      Canvas.Font.Color := clWhite;
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 4, Rect.Top +4, Cells[ACol, ARow]);
    end;
  end;
end;

end.
