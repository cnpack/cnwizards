unit ConvertConstsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TConvertForm = class(TForm)
    mmoSrc: TMemo;
    btnConvert: TButton;
    mmoResult: TMemo;
    procedure btnConvertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvertForm: TConvertForm;

implementation

{$R *.DFM}

procedure TConvertForm.btnConvertClick(Sender: TObject);
var
  I, EquPos, PlusPos, SemicolonPos, Idx, Value1, Value2: Integer;
  Dst: TStrings;
  Values: TStrings;
  S, LeftStr, Param1, Param2: string;
begin
  Dst := TStringList.Create;
  Values := TStringList.Create;
  try
    Dst.Assign(mmoSrc.Lines);

    for I := 0 to Dst.Count - 1 do
    begin
      S := Dst[I];
      EquPos := Pos('=', S);
      if EquPos <= 0 then
        Continue;
      SemicolonPos := Pos(';', S);
      if SemicolonPos <= 0 then
        Continue;

      PlusPos := Pos('+', S);
      if PlusPos <= 0 then
      begin
        // A Simple =
        LeftStr := Trim(Copy(S, 1, EquPos - 1));
        Param1 := Trim(Copy(S, EquPos + 1, SemicolonPos - EquPos - 1));

        Idx := Values.IndexOf(Param1);
        if Idx >= 0 then
          Value1 := Integer(Values.Objects[Idx])
        else
          Value1 := StrToIntDef(Param1, 0);

        Values.AddObject(LeftStr, TObject(Value1));
        S := '  ' + LeftStr + ' = ' + IntToStr(Value1) + ';';
      end
      else
      begin
        LeftStr := Trim(Copy(S, 1, EquPos - 1));
        Param1 := Trim(Copy(S, EquPos + 1, PlusPos - EquPos - 1));
        Param2 := Trim(Copy(S, PlusPos + 1, SemicolonPos - PlusPos - 1));

        Idx := Values.IndexOf(Param1);
        if Idx >= 0 then
          Value1 := Integer(Values.Objects[Idx])
        else
          Value1 := StrToIntDef(Param1, 0);

        Idx := Values.IndexOf(Param2);
        if Idx >= 0 then
          Value2 := Integer(Values.Objects[Idx])
        else
          Value2 := StrToIntDef(Param2, 0);

        Values.AddObject(LeftStr, TObject(Value1 + Value2));
        S := '  ' + LeftStr + ' = ' + IntToStr(Value1 + Value2) + ';';
      end;
      Dst[I] := S;
    end;
    mmoResult.Lines.Assign(Dst);
  finally
    Values.Free;
    Dst.Free;
  end;
end;

end.
