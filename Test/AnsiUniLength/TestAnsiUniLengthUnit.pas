unit TestAnsiUniLengthUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TTestAnsiUniForm = class(TForm)
    mmoStr: TMemo;
    btnLength: TButton;
    lblFrom: TLabel;
    edtOffset: TEdit;
    udOffset: TUpDown;
    bvl1: TBevel;
    btnCalcAnsi: TButton;
    btnCalcWide: TButton;
    procedure btnLengthClick(Sender: TObject);
    procedure btnCalcAnsiClick(Sender: TObject);
    procedure btnCalcWideClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestAnsiUniForm: TTestAnsiUniForm;

implementation

uses
  CnCommon;

{$R *.DFM}

procedure TTestAnsiUniForm.btnLengthClick(Sender: TObject);
var
  WS: WideString;
  I, Len: Integer;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    WS := mmoStr.Lines[I];
    Len := CalcAnsiLengthFromWideString(PWideChar(WS));
    ShowMessage('Ansi Length of Memo Line ' + IntToStr(I) + ' is ' + IntToStr(Len));
  end;
end;

procedure TTestAnsiUniForm.btnCalcAnsiClick(Sender: TObject);
var
  WS: WideString;
  I, Offset: Integer;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    WS := mmoStr.Lines[I];
    Offset := CalcAnsiLengthFromWideStringOffset(PWideChar(WS), udOffset.Position);
    ShowMessage(Format('Ansi SubString Length of Memo Line %d is %d', [I, Offset]));
  end;
end;

procedure TTestAnsiUniForm.btnCalcWideClick(Sender: TObject);
var
  WS: WideString;
  I, Offset: Integer;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    WS := mmoStr.Lines[I];
    Offset := CalcWideStringLengthFromAnsiOffset(PWideChar(WS), udOffset.Position);
    ShowMessage(Format('Wide SubString Length of Memo Line %d is %d', [I, Offset]));
  end;
end;

end.
