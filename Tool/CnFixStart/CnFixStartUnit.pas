unit CnFixStartUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, Contnrs, Registry, CnCommon,
  CnWizCompilerConst, ImgList, CnLangStorage, CnHashLangStorage, CnClasses,
  CnLangMgr, CnWizLangID, CnWideCtrls;

const
  KEY_MAPPING_DELPHI_START: TCnCompiler = cnDelphiXE8;  // 从 XE8 起就可能有 KeyMapping 的毛病
  KEY_MAPPING_DELPHI_END: TCnCompiler = TCnCompiler(Integer(High(TCnCompiler)) -
    2); // 去掉 BCB5/6

type

{$I WideCtrls.inc}

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
    lblKeyMappingNote: TLabel;
    lm1: TCnLangManager;
    hfs1: TCnHashLangFileStorage;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstInstalledKeyMappnigListDrawItem(Control: TWinControl; Index:
      Integer; Rect: TRect; State: TOwnerDrawState);
    procedure btnKeyMappingFixClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    FKeyMappingOK: Boolean;
    FKeyMappingRegs: TObjectList;
    function LoadKeyMappingResult(IDE: TCnCompiler; List: TStrings;
      Objects: TObjectList): Boolean;
    procedure LoadKeyMappingResults;
    procedure CheckKeyMappingOK;
    procedure UpdateMappingOKUI;
    procedure FixKeyMapping;
    procedure TranslateStrings;
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
  end;

var
  FormStartFix: TFormStartFix;

implementation

{$R *.DFM}

const
  csLangPath = 'Lang\';
  KEY_MAPPING_REG = '\Editor\Options\Known Editor Enhancements';
  CNPACK_KEYNAME = 'CnPack';
  PRIORITY_KEY = 'Priority';

var
  SCnNoKeyMappingProblemFound: string = 'NO Key Mapping Problem Found. Everything is OK.';
  SCnKeyMappingProblemFound: string = 'Possible Key Mapping Problem Found.';
  SCnKeyMappingProblemFixed: string = 'Key Mapping Problem Fixed. Please Try to Start Delphi.';
  SCnKeyMappingNoProblemNeedFix: string = 'NO Key Mapping Problem Needs to Fix.';
  SCnFixToolAbout: string =
    'CnPack IDE Wizards Starting-Up Fix Tool 1.0' + #13#10#13#10 +
    'This Tool is Used to Try to Fix Delphi Starting-Up Problem when Installed CnPack.' + #13#10#13#10 +
    'Author: Liu Xiao (master@cnpack.org)' + #13#10 +
    'Copyright (C) 2001-2025 CnPack Team';

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

function TFormStartFix.LoadKeyMappingResult(IDE: TCnCompiler; List: TStrings;
  Objects: TObjectList): Boolean;
var
  Contain: Boolean;
  I, CnPackIdx, MaxIdx, MinValue, MaxValue: Integer;
  Reg: TRegistry;
  Res: TCnKeyMappingCheckResult;
begin
  Result := False;
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
          if Reg.OpenKey(SCnIDERegPaths[IDE] + KEY_MAPPING_REG + '\' + List[I],
            False) then
          begin
            List.Objects[I] := Pointer(Reg.ReadInteger(PRIORITY_KEY));
          end;
        finally
          Reg.Free;
        end;
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

      Objects.Add(Res);
      Result := True;
    end;
  end;
end;

procedure TFormStartFix.LoadKeyMappingResults;
var
  J: Integer;
  List: TStrings;
begin
  FKeyMappingRegs.Clear;
  List := TStringList.Create;
  try
    for J := Ord(KEY_MAPPING_DELPHI_START) to Ord(KEY_MAPPING_DELPHI_END) do
      LoadKeyMappingResult(TCnCompiler(J), List, FKeyMappingRegs);
  finally
    List.Free;
  end;

  lstInstalledKeyMappnigList.Clear;
  for J := 0 to FKeyMappingRegs.Count - 1 do
    lstInstalledKeyMappnigList.Items.Add(SCnCompilerNames[TCnKeyMappingCheckResult
      (FKeyMappingRegs[J]).IDE]);

  CheckKeyMappingOK;
  UpdateMappingOKUI;
end;

procedure TFormStartFix.lstInstalledKeyMappnigListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
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
  ListBox.Canvas.TextOut(Rect.Left + ilImage.Width + 4, Rect.Top + 4, ListBox.Items
    [Index]);
end;

procedure TFormStartFix.UpdateMappingOKUI;
begin
  imgKeyMappingOK.Visible := FKeyMappingOK;
  imgKeyMappingNOK.Visible := not FKeyMappingOK;

  btnKeyMappingFix.Visible := not FKeyMappingOK;
  lblKeyMappingNote.Visible := not FKeyMappingOK;

  if FKeyMappingOK then
    lblKeyMappingProblemFound.Caption := SCnNoKeyMappingProblemFound
  else
    lblKeyMappingProblemFound.Caption := SCnKeyMappingProblemFound;
end;

procedure TFormStartFix.btnKeyMappingFixClick(Sender: TObject);
begin
  FixKeyMapping;
  LoadKeyMappingResults;
end;

function ListCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  if Pos(CNPACK_KEYNAME, List[Index1]) > 0 then
    Result := 1
  else if Pos(CNPACK_KEYNAME, List[Index2]) > 0 then
    Result := -1
  else
    Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
end;

procedure TFormStartFix.FixKeyMapping;
var
  I, J, P: Integer;
  List: TStringList;
  Objects: TObjectList;
  Res: TCnKeyMappingCheckResult;
  Reg: TRegistry;
  Fixed: Boolean;
begin
  List := TStringList.Create;
  Objects := TObjectList.Create;
  Fixed := False;
  try
    for J := Ord(KEY_MAPPING_DELPHI_START) to Ord(KEY_MAPPING_DELPHI_END) do
    begin
      if LoadKeyMappingResult(TCnCompiler(J), List, Objects) then
      begin
        // 有该 IDE 的数据，拿到结果
        Res := TCnKeyMappingCheckResult(Objects[Objects.Count - 1]);
        if not Res.Correct then
        begin
          // CnPack 项不是最大的 Priority，需要将 List 里的内容排序调整
          // 确保无论 Priority 值如何，CnPack 都在最后
          List.CustomSort(ListCompare);

          // 排序排好后，直接赋值 0 到 Count - 1
          for I := 0 to List.Count - 1 do
            List.Objects[I] := TObject(I);

          // 写入注册表值
          for I := 0 to List.Count - 1 do
          begin
            Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
            try
              if Reg.OpenKey(SCnIDERegPaths[Res.IDE] + KEY_MAPPING_REG + '\' + List[I],
                False) then
              begin
                P := Reg.ReadInteger(PRIORITY_KEY);
                if P <> Integer(List.Objects[I]) then
                  Reg.WriteInteger(PRIORITY_KEY, Integer(List.Objects[I]));
              end;
            finally
              Reg.Free;
            end;
          end;
          Fixed := True;
        end;
      end;
    end;

    if Fixed then
      InfoDlg(SCnKeyMappingProblemFixed)
    else
      InfoDlg(SCnKeyMappingNoProblemNeedFix);
  finally
    Objects.Free;
    List.Free;
  end;
end;

procedure TFormStartFix.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnFixToolAbout);
end;

procedure TFormStartFix.DoCreate;
var
  I: Integer;
  LangID: DWORD;
begin
  if CnLanguageManager <> nil then
  begin
    hfs1.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangPath;
    CnLanguageManager.LanguageStorage := hfs1;

    LangID := GetWizardsLanguageID;
    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        Break;
      end;
    end;
  end;

  inherited;
end;

procedure TFormStartFix.TranslateStrings;
begin
  TranslateStr(SCnNoKeyMappingProblemFound, 'SCnNoKeyMappingProblemFound');
  TranslateStr(SCnKeyMappingProblemFound, 'SCnKeyMappingProblemFound');
  TranslateStr(SCnKeyMappingProblemFixed, 'SCnKeyMappingProblemFixed');
  TranslateStr(SCnKeyMappingNoProblemNeedFix, 'SCnKeyMappingNoProblemNeedFix');
  TranslateStr(SCnFixToolAbout, 'SCnFixToolAbout');
end;

end.

