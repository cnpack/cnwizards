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
    btnUtf8Convert: TButton;
    btnCalcUtf8Len: TButton;
    procedure btnLengthClick(Sender: TObject);
    procedure btnCalcAnsiClick(Sender: TObject);
    procedure btnCalcWideClick(Sender: TObject);
    procedure btnUtf8ConvertClick(Sender: TObject);
    procedure btnCalcUtf8LenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestAnsiUniForm: TTestAnsiUniForm;

implementation

uses
  CnCommon, CnWideStrings;

{$R *.DFM}

procedure TTestAnsiUniForm.btnLengthClick(Sender: TObject);
var
  WS: WideString;
  I, Len: Integer;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    WS := mmoStr.Lines[I];
    Len := CalcAnsiDisplayLengthFromWideString(PWideChar(WS));
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
    Offset := CalcAnsiDisplayLengthFromWideStringOffset(PWideChar(WS), udOffset.Position);
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
    Offset := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(WS), udOffset.Position);
    ShowMessage(Format('Wide SubString Length of Memo Line %d is %d', [I, Offset]));
  end;
end;

procedure TTestAnsiUniForm.btnUtf8ConvertClick(Sender: TObject);
var
  I: Integer;
  S: AnsiString;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    S := CnAnsiToUtf8(mmoStr.Lines[I]);
    ShowMessage(ConvertUtf8ToAlterDisplayAnsi(PAnsiChar(S), '~'));
  end;
end;

procedure TTestAnsiUniForm.btnCalcUtf8LenClick(Sender: TObject);
var
  I, Offset, Len: Integer;
  S, S1: AnsiString;
  W: WideString;
begin
  for I := 0 to mmoStr.Lines.Count - 1 do
  begin
    S := CnAnsiToUtf8(mmoStr.Lines[I]);
    Offset := CalcUtf8StringLengthFromWideOffset(PAnsiChar(S), udOffset.Position);

    W := Copy(WideString(mmoStr.Lines[I]), 1, udOffset.Position);
    // WideString to Utf8 AnsiString
    S1 := AnsiString(W);
    Len := Length(CnAnsiToUtf8(S1));

    ShowMessage('Utf8 is ' + S + #13#10#13#10 + 'Calc is ' + IntToStr(Offset) + ' Actual is ' + IntToStr(Len));
  end;
end;

end.
