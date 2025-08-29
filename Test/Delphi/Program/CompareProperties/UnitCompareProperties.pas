unit UnitCompareProperties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, TypInfo, Contnrs, CnSampleComponent;

type
  TFormTestCompare = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    btnCompare: TButton;
    spl1: TSplitter;
    btnCompare2: TButton;
    RadioButton1: TRadioButton;
    Memo1: TMemo;
    bvl1: TBevel;
    mmoLeft: TMemo;
    mmoRight: TMemo;
    btnMerge: TButton;
    procedure btnCompareClick(Sender: TObject);
    procedure btnCompare2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
  private
    FComp1, FComp2: TCnSampleComponent;
  public
    procedure MakeAlignList;
  end;

var
  FormTestCompare: TFormTestCompare;

implementation

uses
  CnPropertyCompareFrm, CnPropSheetFrm;

{$R *.DFM}

procedure TFormTestCompare.btnCompareClick(Sender: TObject);
begin
  CompareTwoObjects(Memo1, RadioButton1);
end;

procedure TFormTestCompare.btnCompare2Click(Sender: TObject);
begin
  FreeAndNil(FComp1);
  FreeAndNil(FComp2);

  FComp1 := TCnSampleComponent.Create(Self);
  FComp2 := TCnSampleComponent.Create(Self);

  FComp2.WideHint := '2 Wide Hint';
  FComp2.Height := 65;
  FComp2.AccChar := 'p';
  FComp2.FloatValue := 2.71828;
  FComp1.Parent := Self;
  FComp1.Anchors := [akLeft, akRight, akTop, akBottom];
  FComp1.WideAccChar := 'X';
//  FComp1.Point.x := 9;
//  FComp1.Point.y := 18;

  HelpContext := GetOrdProp(FComp2, 'WideAccChar');
  CompareTwoObjects(FComp1, FComp2);
end;

procedure TFormTestCompare.Button1Click(Sender: TObject);
begin
  ShowMessage('Button Clicked.');
end;

function PropertyListCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnPropertyObject;
begin
  P1 := TCnPropertyObject(Item1);
  P2 := TCnPropertyObject(Item2);

  if (P1.PropType in tkMethods) and not (P2.PropType in tkMethods) then
    Result := 1
  else if (P2.PropType in tkMethods) and not (P1.PropType in tkMethods) then
    Result := -1
  else
    Result := CompareStr(P1.PropName, P2.PropName);
end;

procedure TFormTestCompare.MakeAlignList;
var
  L, R, C: Integer;
  PL, PR: TCnPropertyObject;
  Merge: TStringList;
  FLeftProperties, FRightProperties: TObjectList;
begin
  Merge := TStringList.Create;
  Merge.Duplicates := dupIgnore;

  FLeftProperties := TObjectList.Create;
  FRightProperties := TObjectList.Create;
  for L := 0 to mmoLeft.Lines.Count - 1 do
  begin
    PL := TCnPropertyObject.Create;
    PL.PropName := mmoLeft.Lines[L];
    if (Length(PL.PropName) > 0) and (PL.PropName[1] = 'O') then
      PL.PropType := tkMethod
    else
      PL.PropType := tkInteger;
    FLeftProperties.Add(PL);
  end;
  for R := 0 to mmoRight.Lines.Count - 1 do
  begin
    PR := TCnPropertyObject.Create;
    PR.PropName := mmoRight.Lines[R];
    if (Length(PR.PropName) > 0) and (PR.PropName[1] = 'O') then
      PR.PropType := tkMethod
    else
      PR.PropType := tkInteger;
    FRightProperties.Add(PR);
  end;

  try
    L := 0;
    R := 0;
    while (L < FLeftProperties.Count) and (R < FRightProperties.Count) do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      PR := TCnPropertyObject(FRightProperties[R]);

      C := PropertyListCompare(PL, PR);

      // 相等
      if C = 0 then
      begin
        Inc(L);
        Inc(R);

        Merge.Add(PL.PropName);
      end
      else if C < 0 then // 左比右小
      begin
        Merge.Add(PL.PropName);
        Inc(L);
      end
      else if C > 0 then // 右比左小
      begin
        Merge.Add(PR.PropName);
        Inc(R);
      end;
    end;

    // Merge 中得到归并后的排序点，然后左右各找自己每一项对应的索引
    L := 0;
    while L < FLeftProperties.Count do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      R := Merge.IndexOf(PL.PropName);

      // R 一定会 >= L
      if R > L then
      begin
        // 在 L 的前一个插入适当数量的 nil
        for C := 1 to R - L do
          FLeftProperties.Insert(L, nil);
        Inc(L, R - L);
      end;

      Inc(L);
    end;

    R := 0;
    while R < FRightProperties.Count do
    begin
      PR := TCnPropertyObject(FRightProperties[R]);
      L := Merge.IndexOf(PR.PropName);

      // L 一定会 >= R
      if L > R then
      begin
        // 在 R 的前一个插入适当数量的 nil
        for C := 1 to L - R do
          FRightProperties.Insert(R, nil);
        Inc(R, L - R);
      end;

      Inc(R);
    end;

    // 尾部不等的话，补上
    if FLeftProperties.Count > FRightProperties.Count then
    begin
      for L := 0 to FLeftProperties.Count - FRightProperties.Count - 1 do
        FRightProperties.Add(nil);
    end
    else if FRightProperties.Count > FLeftProperties.Count then
    begin
      for L := 0 to FRightProperties.Count - FLeftProperties.Count - 1 do
        FLeftProperties.Add(nil);
    end;

    mmoLeft.Clear;
    mmoRight.Clear;
    for L := 0 to FLeftProperties.Count - 1 do
    begin
      if FLeftProperties[L] <> nil then
        mmoLeft.Lines.Add(TCnPropertyObject(FLeftProperties[L]).PropName)
      else
        mmoLeft.Lines.Add('-');
    end;
    for R := 0 to FRightProperties.Count - 1 do
    begin
      if FRightProperties[R] <> nil then
        mmoRight.Lines.Add(TCnPropertyObject(FRightProperties[R]).PropName)
      else
        mmoRight.Lines.Add('-');
    end;
  finally
    Merge.Free;
  end;
end;

procedure TFormTestCompare.btnMergeClick(Sender: TObject);
begin
  MakeAlignList;
end;

procedure TFormTestCompare.RadioButton1Click(Sender: TObject);
begin
//
end;

end.
