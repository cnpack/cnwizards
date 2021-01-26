unit CnFixStartUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, Contnrs, Registry,
  CnCommon, CnWizCompilerConst, ImgList;

const
  KEY_MAPPING_DELPHI_START: TCnCompiler = cnDelphiXE8;  // 从 XE8 起就可能有 KeyMapping 的毛病
  KEY_MAPPING_DELPHI_END: TCnCompiler = TCnCompiler(Integer(High(TCnCompiler)) - 2); // 去掉 BCB5/6

type
  TCnKeyMappingCheckResult = class
  {* 一个 IDE 的 KeyMapping 优先级结果}
  private
    FKeyMappingReg: string;
    FCorrect: Boolean;
    FInstalled: Boolean;
    FIDE: TCnCompiler;
  public
    property Installed: Boolean read FInstalled write FInstalled;
    property IDE: TCnCompiler read FIDE write FIDE;
    property KeyMappingReg: string read FKeyMappingReg write FKeyMappingReg;
    property Correct: Boolean read FCorrect write FCorrect;
  end;

  TFormStartFix = class(TForm)
    pnlTop: TPanel;
    bvlLineTop: TBevel;
    imgIcon: TImage;
    lblFun: TLabel;
    lblDesc: TLabel;
    btnAbout: TBitBtn;
    btnHelp: TBitBtn;
    btnClose: TBitBtn;
    pgc1: TPageControl;
    tsKeyMapping: TTabSheet;
    lblInstalledKeyMapping: TLabel;
    lstInstalledKeyMappnigList: TListBox;
    ilImage: TImageList;
    imgKeyMappingOK: TImage;
    imgKeyMappingNOK: TImage;
    btnKeyMappingFix: TButton;
    lblKeyMappingProblemFound: TLabel;
    bvl1: TBevel;
    lblKeyMappingDescription: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstInstalledKeyMappnigListDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    FKeyMappingOK: Boolean;
    FKeyMappingRegs: TObjectList;
    procedure LoadKeyMappingResults;
    procedure CheckKeyMappingOK;
    procedure UpdateMappingOKUI;
  public
    { Public declarations }
  end;

var
  FormStartFix: TFormStartFix;

implementation

{$R *.DFM}

const
  KEY_MAPPING_REG = '\Editor\Options\Known Editor Enhancements';

  SCnNoKeyMappingProblemFound = 'NO Key Mapping Problem Found. Everything is OK.';
  SCnKeyMappingProblemFound = 'Possible Key Mapping Problem Found.';

procedure TFormStartFix.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormStartFix.CheckKeyMappingOK;
var
  I: Integer;
begin
  FKeyMappingOK := True;
  for I := 0 to FKeyMappingRegs.Count - 1 do
  begin
    if not TCnKeyMappingCheckResult(FKeyMappingRegs[I]).Correct then
    begin
      FKeyMappingOK := False;
      Exit;
    end;
  end;
end;

procedure TFormStartFix.FormCreate(Sender: TObject);
begin
  FKeyMappingRegs := TObjectList.Create(True);
  LoadKeyMappingResults;
end;

procedure TFormStartFix.FormDestroy(Sender: TObject);
begin
  FKeyMappingRegs.Free;
end;

procedure TFormStartFix.LoadKeyMappingResults;
var
  J: Integer;
  List: TStrings;

  procedure LoadKeyMappingResult(IDE: TCnCompiler);
  const
    PRIORITY_KEY = 'Priority';
    CNPACK_KEYNAME = 'CnPack';
  var
    Contain: Boolean;
    I, CnPackIdx, MaxIdx, MinValue, MaxValue: Integer;
    Reg: TRegistry;
    Res: TCnKeyMappingCheckResult;
  begin
    if GetKeysInRegistryKey(SCnIDERegPaths[IDE] + KEY_MAPPING_REG, List) then
    begin
      if List.Count >= 1 then
      begin
        // 有该 IDE 并且该 IDE 下有多个 KeyMapping，List 中已经存了每个 KeyMapping 的名字
        // 让 List 的 Objects 里头存每个 KeyMapping 的 Priority 值
        for I := 0 to List.Count - 1 do
        begin
          List.Objects[I] := Pointer(-1);
          Reg := TRegistry.Create(KEY_READ);
          try
            if Reg.OpenKey(SCnIDERegPaths[IDE] + KEY_MAPPING_REG + '\' + List[I], False) then
            begin
              List.Objects[I] := Pointer(Reg.ReadInteger(PRIORITY_KEY));
            end;
          finally
            Reg.Free;
          end;
  {$IFDEF DEBUG}
          CnDebugger.LogFmt('Key Mapping: %s: Priority %d.', [List[I], Integer(List.Objects[I])]);
  {$ENDIF}
        end;

        // 读完后检查 List 中是否有 CnPack 并且是否最大
        Contain := False;
        CnPackIdx := -1;
        for I := 0 to List.Count - 1 do
        begin
          if Pos(CNPACK_KEYNAME, List[I]) > 0 then
          begin
            Contain := True;
            CnPackIdx := I;
            Break;
          end;
        end;

        if not Contain then
          Exit;

        MaxIdx := 0;
        MinValue := Integer(List.Objects[0]);
        MaxValue := Integer(List.Objects[0]);
        for I := 0 to List.Count - 1 do
        begin
          if Integer(List.Objects[I]) < MinValue then
          begin
            //MinIdx := I;
            MinValue := Integer(List.Objects[I]);
          end;

          if Integer(List.Objects[I]) > MaxValue then
          begin
            MaxIdx := I;
            MaxValue := Integer(List.Objects[I]);
          end;
        end;

        Res := TCnKeyMappingCheckResult.Create;
        Res.Correct := MaxIdx = CnPackIdx; // CnPack 键盘映射顺序已在最下面。
        Res.IDE := IDE;

        FKeyMappingRegs.Add(Res);
      end;
    end;
  end;

begin
  List := TStringList.Create;
  try
    for J := Ord(KEY_MAPPING_DELPHI_START) to Ord(KEY_MAPPING_DELPHI_END) do
      LoadKeyMappingResult(TCnCompiler(J));
  finally
    List.Free;
  end;

  lstInstalledKeyMappnigList.Clear;
  for J := 0 to FKeyMappingRegs.Count - 1 do
    lstInstalledKeyMappnigList.Items.Add(SCnCompilerNames[TCnKeyMappingCheckResult(FKeyMappingRegs[J]).IDE]);

  CheckKeyMappingOK;
  UpdateMappingOKUI;
end;

procedure TFormStartFix.lstInstalledKeyMappnigListDrawItem(
  Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Reg: TCnKeyMappingCheckResult;
  ListBox: TListBox;
begin
  if not (Control is TListBox) then
    Exit;
  ListBox := TListBox(Control);
  Reg := TCnKeyMappingCheckResult(FKeyMappingRegs[Index]);

  if odSelected in State then
    ListBox.Canvas.Brush.Color := clHighlight
  else
    ListBox.Canvas.Brush.Color := clWindow;

  ListBox.Canvas.FillRect(Rect);

  ilImage.Draw(ListBox.Canvas, Rect.Left + 2, Rect.Top + 2, Integer(Reg.Correct));
  ListBox.Canvas.TextOut(Rect.Left + ilImage.Width + 4, Rect.Top + 4, ListBox.Items[Index]);
end;

procedure TFormStartFix.UpdateMappingOKUI;
begin
  imgKeyMappingOK.Visible := FKeyMappingOK;
  imgKeyMappingNOK.Visible := not FKeyMappingOK;

  btnKeyMappingFix.Visible := not FKeyMappingOK;

  if FKeyMappingOK then
    lblKeyMappingProblemFound.Caption := SCnNoKeyMappingProblemFound
  else
    lblKeyMappingProblemFound.Caption := SCnKeyMappingProblemFound;
end;

end.
