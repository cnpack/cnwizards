{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnInputHelperFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手专家设置窗体
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：PWinXP XP2 + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2005.06.03
*               从 CnInputHelper 中分离出来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CheckLst, StdCtrls, ComCtrls, ExtCtrls, Menus, CnConsts, CnCommon, IniFiles,
  ToolsAPI, CnStrings, CnWizMultiLang, CnSpin, CnWizConsts, CnInputHelper,
  CnInputSymbolList, CnInputIdeSymbolList, CnInputHelperEditFrm, CnWizMacroText,
  CnWizUtils, CnWizOptions;

type

{ TCnInputHelperForm }

  TCnInputHelperForm = class(TCnTranslateForm)
    FontDialog: TFontDialog;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    chkAutoPopup: TCheckBox;
    seDispOnlyAtLeastKey: TCnSpinEdit;
    tbDispDelay: TTrackBar;
    chkSmartDisp: TCheckBox;
    hkEnabled: THotKey;
    hkPopup: THotKey;
    chkCheckImmRun: TCheckBox;
    chkDispOnIDECompDisabled: TCheckBox;
    grp3: TGroupBox;
    lbl9: TLabel;
    lbl10: TLabel;
    edtCompleteChars: TEdit;
    cbbOutputStyle: TComboBox;
    chkSelMidMatchByEnterOnly: TCheckBox;
    chkAutoInsertEnter: TCheckBox;
    chkSpcComplete: TCheckBox;
    ts3: TTabSheet;
    grp2: TGroupBox;
    lbl7: TLabel;
    lbl8: TLabel;
    PaintBox: TPaintBox;
    seListOnlyAtLeastLetter: TCnSpinEdit;
    cbbSortKind: TComboBox;
    btnFont: TButton;
    chkAutoAdjustScope: TCheckBox;
    chkUseCodeInsightMgr: TCheckBox;
    grp4: TGroupBox;
    lbl11: TLabel;
    chklstSymbol: TCheckListBox;
    grp5: TGroupBox;
    lbl12: TLabel;
    lvList: TListView;
    btnAdd: TButton;
    lbl13: TLabel;
    mmoTemplate: TMemo;
    btnDelete: TButton;
    btnEdit: TButton;
    btnImport: TButton;
    btnExport: TButton;
    btnInsertMacro: TButton;
    btnCursor: TButton;
    btnClear: TButton;
    lbl14: TLabel;
    chklstKind: TCheckListBox;
    pmMacro: TPopupMenu;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    btnDup: TButton;
    btnUserMacro: TButton;
    chkRemoveSame: TCheckBox;
    lbl15: TLabel;
    cbbKeyword: TComboBox;
    btnDefault: TButton;
    cbbList: TComboBox;
    chkAutoCompParam: TCheckBox;
    lbl16: TLabel;
    edtFilterSymbols: TEdit;
    chkIgnoreSpace: TCheckBox;
    chkUseKibitzCompileThread: TCheckBox;
    edtAutoSymbols: TEdit;
    chkKeySeq: TCheckBox;
    btnDisableCompletion: TButton;
    cbbMatchMode: TComboBox;
    lblMatchMode: TLabel;
    chkTabComplete: TCheckBox;
    chkIgnoreDot: TCheckBox;
    chkUseEditorColor: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure UpdateControls(Sender: TObject);
    procedure UpdateListControls(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lvListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnCursorClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure mmoTemplateExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnInsertMacroClick(Sender: TObject);
    procedure btnDupClick(Sender: TObject);
    procedure lvListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormDestroy(Sender: TObject);
    procedure btnUserMacroClick(Sender: TObject);
    procedure cbbListChange(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkSpcCompleteClick(Sender: TObject);
    procedure chkDispOnIDECompDisabledClick(Sender: TObject);
    procedure btnDisableCompletionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    InputHelper: TCnInputHelper;
    NewSymbol: string;
    SaveKind: TCnSymbolKind;
    SaveScope: Integer;
    SaveAutoIndent: Boolean;
    AddMode: Boolean;
    CurrList: TCnSymbolList;
    SortIdx: Integer;
    SortDesc: Boolean;
    function DoAddSymbol(const NewName: string): Boolean;
    procedure UpdateFont;
    procedure UpdateListView(SelOnly: Boolean);
    procedure OnMacroMenu(Sender: TObject);
    procedure InitListView;
    procedure UpdateListItem(Item: TListItem);
  protected
    function GetHelpTopic: string; override;
  end;

function CnInputHelperConfig(AInputHelper: TCnInputHelper; HideSymbolPages: Boolean = False): Boolean;

function CnInputHelperAddSymbol(AInputHelper: TCnInputHelper;
  const ASymbol: string): Boolean;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$R *.DFM}

const
  csCnKeywordStyles: array[TCnKeywordStyle] of PString = (
    @SCnKeywordDefault, @SCnKeywordLower, @SCnKeywordUpper, @SCnKeywordFirstUpper);

//==============================================================================
// 输入助手设置窗体
//==============================================================================

function CnInputHelperConfig(AInputHelper: TCnInputHelper;
  HideSymbolPages: Boolean): Boolean;
begin
  with TCnInputHelperForm.Create(nil) do
  try
    InputHelper := AInputHelper;
    AddMode := False;

    if HideSymbolPages then
    begin
      ts2.TabVisible := False;
      ts3.TabVisible := False;
    end;
    Result := ShowModal = mrOK;
  finally
    Free;
  end;
end;

function CnInputHelperAddSymbol(AInputHelper: TCnInputHelper;
  const ASymbol: string): Boolean;
begin
  with TCnInputHelperForm.Create(nil) do
  try
    InputHelper := AInputHelper;
    NewSymbol := ASymbol;
    AddMode := True;
    Result := ShowModal = mrOK;
  finally
    Free;
  end;
end;

{ TCnInputHelperForm }

const
  csOption = 'Option';
  csSortIdx = 'SortIdx';
  csSortDesc = 'SortDesc';
  csSaveKind = 'SaveKind';
  csSaveScope = 'SaveScope';

procedure TCnInputHelperForm.FormShow(Sender: TObject);
var
  Kind: TCnSortKind;
  SymbolKind: TCnSymbolKind;
  KwStyle: TCnKeywordStyle;
  Macro: TCnWizMacro;
  I: Integer;
begin
  inherited;

  if AddMode then
    pgc1.ActivePageIndex := 2
  else
    pgc1.ActivePageIndex := 0;

  with InputHelper.CreateIniFile do
  try
    SortIdx := ReadInteger(csOption, csSortIdx, 0);
    SortDesc := ReadBool(csOption, csSortDesc, False);
    SaveKind := TCnSymbolKind(ReadInteger(csOption, csSaveKind, Ord(skUser)));
    SaveScope := ReadInteger(csOption, csSaveScope, csDefScopeRate);
  finally
    Free;
  end;
  SaveAutoIndent := True;

  with InputHelper do
  begin
    chkUseEditorColor.Checked := UseEditorColor;
    chkUseCodeInsightMgr.Enabled := SupportMultiIDESymbolList;
    if SupportMultiIDESymbolList then
      chkUseCodeInsightMgr.Checked := UseCodeInsightMgr;
    chkUseKibitzCompileThread.Enabled := SupportKibitzCompileThread;
    if SupportKibitzCompileThread then
      chkUseKibitzCompileThread.Checked := UseKibitzCompileThread;
    chkAutoPopup.Checked := GetGeneralAutoPopup;
    seDispOnlyAtLeastKey.Value := DispOnlyAtLeastKey;
    tbDispDelay.Position := DispDelay;
    seListOnlyAtLeastLetter.Value := ListOnlyAtLeastLetter;
    cbbMatchMode.ItemIndex := Ord(MatchMode);
    chkAutoAdjustScope.Checked := AutoAdjustScope;
    chkRemoveSame.Checked := RemoveSame;
    chkSmartDisp.Checked := SmartDisplay;
    for Kind := Low(TCnSortKind) to High(TCnSortKind) do
      cbbSortKind.Items.Add(StripHotkey(csSortKindTexts[Kind]^));
    cbbSortKind.ItemIndex := Ord(SortKind);
    for KwStyle := Low(TCnKeywordStyle) to High(TCnKeywordStyle) do
      cbbKeyword.Items.Add(csCnKeywordStyles[KwStyle]^);
    cbbKeyword.ItemIndex := Ord(KeywordStyle);
    hkEnabled.HotKey := InputHelper.Action.ShortCut;
    hkPopup.HotKey := PopupKey;
    chkCheckImmRun.Checked := CheckImmRun;
    edtCompleteChars.Text := CompleteChars;
    edtFilterSymbols.Text := FilterSymbols.CommaText;
    edtAutoSymbols.Text := AutoSymbols.CommaText;
    chkSpcComplete.Checked := SpcComplete;
    chkTabComplete.Checked := TabComplete;
    chkIgnoreDot.Checked := not IgnoreDot;
    chkIgnoreSpace.Checked:= IgnoreSpc;
    chkIgnoreSpace.Enabled := chkSpcComplete.Checked;
    cbbOutputStyle.ItemIndex := Ord(OutputStyle);
    chkSelMidMatchByEnterOnly.Checked := SelMidMatchByEnterOnly;
    chkAutoInsertEnter.Checked := AutoInsertEnter;
    chkAutoCompParam.Checked := AutoCompParam;
    chkDispOnIDECompDisabled.Checked := DispOnIDECompDisabled;
    chkKeySeq.Checked := EnableAutoSymbols;
    FontDialog.Font.Assign(ListFont);

    for I := 0 to SymbolListMgr.Count - 1 do
    begin
      chklstSymbol.Items.Add(SymbolListMgr.List[I].GetListName);
      chklstSymbol.Checked[I] := SymbolListMgr.List[I].Active;
      if SymbolListMgr.List[I].CanCustomize then
        cbbList.Items.AddObject(SymbolListMgr.List[I].GetListName,
          SymbolListMgr.List[I]);
    end;

    for SymbolKind := Low(SymbolKind) to High(SymbolKind) do
    begin
      chklstKind.Items.Add(GetSymbolKindName(SymbolKind));
      chklstKind.Checked[Ord(SymbolKind)] := SymbolKind in DispKindSet;
    end;

    for Macro := Low(Macro) to High(Macro) do
    begin
      AddMenuItem(pmMacro.Items, Format('%s - %s', [GetMacroEx(Macro),
        csCnWizMacroDescs[Macro]^]), OnMacroMenu, nil, 0, '', Ord(Macro));
    end;

    InputHelper.SymbolListMgr.Load;
    CurrList := InputHelper.SymbolListMgr.ListByClass(TCnUserSymbolList);
    Assert(Assigned(CurrList));
    cbbList.ItemIndex := cbbList.Items.IndexOfObject(CurrList);
    Assert(cbbList.ItemIndex >= 0);
    InitListView;
  end;

  UpdateFont;
  UpdateControls(nil);
  UpdateListControls(nil);
end;

procedure TCnInputHelperForm.FormDestroy(Sender: TObject);
begin
  inherited;

  with InputHelper.CreateIniFile do
  try
    WriteInteger(csOption, csSortIdx, SortIdx);
    WriteBool(csOption, csSortDesc, SortDesc);
    WriteInteger(csOption, csSaveKind, Ord(SaveKind));
    WriteInteger(csOption, csSaveScope, SaveScope);
  finally
    Free;
  end;

  InputHelper.SymbolListMgr.Save;
end;

procedure TCnInputHelperForm.InitListView;
var
  I: Integer;
begin
  lvList.Items.Clear;
  for I := 0 to CurrList.Count - 1 do
    lvList.Items.Add.Data := CurrList.Items[I];
  UpdateListView(False);
  lvList.AlphaSort;
end;

procedure TCnInputHelperForm.FormActivate(Sender: TObject);
begin
  if AddMode then
  begin
    AddMode := False;
    DoAddSymbol(NewSymbol);
  end;
end;

procedure TCnInputHelperForm.btnOKClick(Sender: TObject);
var
  I: Integer;
  SymbolKind: TCnSymbolKind;
begin
  with InputHelper do
  begin
    UseEditorColor := chkUseEditorColor.Checked;
    if SupportMultiIDESymbolList then
      UseCodeInsightMgr := chkUseCodeInsightMgr.Checked;
    if SupportKibitzCompileThread then
      UseKibitzCompileThread := chkUseKibitzCompileThread.Checked;
{$IFDEF IDE_SUPPORT_LSP}
    AutoPopupLSP := chkAutoPopup.Checked;
{$ELSE}
    AutoPopup := chkAutoPopup.Checked;
{$ENDIF}
    DispOnlyAtLeastKey := seDispOnlyAtLeastKey.Value;
    DispDelay := tbDispDelay.Position;
    ListOnlyAtLeastLetter := seListOnlyAtLeastLetter.Value;
    MatchMode := TCnMatchMode(cbbMatchMode.ItemIndex);
    AutoAdjustScope := chkAutoAdjustScope.Checked;
    RemoveSame := chkRemoveSame.Checked;
    SmartDisplay := chkSmartDisp.Checked;
    SortKind := TCnSortKind(cbbSortKind.ItemIndex);
    KeywordStyle := TCnKeywordStyle(cbbKeyword.ItemIndex);
    InputHelper.Action.ShortCut := hkEnabled.HotKey;
    PopupKey := hkPopup.HotKey;
    CheckImmRun := chkCheckImmRun.Checked;
    CompleteChars := edtCompleteChars.Text;
    FilterSymbols.CommaText := edtFilterSymbols.Text;
    AutoSymbols.CommaText := edtAutoSymbols.Text;
    SpcComplete := chkSpcComplete.Checked;
    TabComplete := chkTabComplete.Checked;
    IgnoreDot := not chkIgnoreDot.Checked;
    IgnoreSpc := chkIgnoreSpace.Checked;
    OutputStyle := TCnOutputStyle(cbbOutputStyle.ItemIndex);
    SelMidMatchByEnterOnly := chkSelMidMatchByEnterOnly.Checked;
    AutoInsertEnter := chkAutoInsertEnter.Checked;
    AutoCompParam := chkAutoCompParam.Checked;
    DispOnIDECompDisabled := chkDispOnIDECompDisabled.Checked;
    EnableAutoSymbols := chkKeySeq.Checked;
    ListFont := FontDialog.Font; // 不能 Assign，要用赋值触发 SetListFont 以更新列表字体

    for I := 0 to SymbolListMgr.Count - 1 do
      SymbolListMgr.List[I].Active := chklstSymbol.Checked[I];

    DispKindSet := [];
    for SymbolKind := Low(SymbolKind) to High(SymbolKind) do
    begin
      if chklstKind.Checked[Ord(SymbolKind)] then
       DispKindSet := DispKindSet + [SymbolKind];
    end;
  end;

  ModalResult := mrOk;
end;

function TCnInputHelperForm.GetHelpTopic: string;
begin
  Result := SCnInputHelperHelpStr;
end;

procedure TCnInputHelperForm.PaintBoxPaint(Sender: TObject);
var
  Text: string;
  W, H: Integer;
begin
  with PaintBox.Canvas do
  begin
    Font := FontDialog.Font;
    Font.Color := clBlack;
    Brush.Color := clWhite;
    Text := Format('%s, %d', [FontDialog.Font.Name, FontDialog.Font.Size]);
    W := TextWidth(Text);
    H := TextHeight(Text);
    PaintBox.Canvas.TextRect(PaintBox.ClientRect, (PaintBox.Width - W) div 2,
      (PaintBox.Height - H) div 2, Text);
    Brush.Color := clBlack;
    FrameRect(PaintBox.ClientRect);
  end;
end;

procedure TCnInputHelperForm.UpdateFont;
begin
  PaintBox.Invalidate;
end;

procedure TCnInputHelperForm.btnFontClick(Sender: TObject);
begin
  if FontDialog.Execute then
    UpdateFont;
end;

procedure TCnInputHelperForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnInputHelperForm.UpdateControls(Sender: TObject);
begin
  tbDispDelay.Enabled := chkAutoPopup.Checked;
  seDispOnlyAtLeastKey.Enabled := chkAutoPopup.Checked;
  chkSmartDisp.Enabled := chkAutoPopup.Checked;
  chkDispOnIDECompDisabled.Enabled := chkAutoPopup.Checked;
  chkKeySeq.Enabled := chkAutoPopup.Checked;
  edtAutoSymbols.Enabled := chkAutoPopup.Checked and chkKeySeq.Checked;
  btnDisableCompletion.Enabled := chkDispOnIDECompDisabled.Checked;
end;

procedure TCnInputHelperForm.UpdateListItem(Item: TListItem);
begin
  if Item <> nil then
    with TCnSymbolItem(Item.Data) do
    begin
      Item.Caption := Name;
      Item.SubItems.Clear;
      Item.SubItems.Add(GetSymbolKindName(Kind));
      Item.SubItems.Add(IntToStr(ScopeRate));
      Item.SubItems.Add(Description);
    end;
end;

procedure TCnInputHelperForm.UpdateListView(SelOnly: Boolean);
var
  I: Integer;
begin
  if SelOnly then
    UpdateListItem(lvList.Selected)
  else
    for I := 0 to lvList.Items.Count - 1 do
      UpdateListItem(lvList.Items[I]);
end;

procedure TCnInputHelperForm.UpdateListControls(Sender: TObject);
var
  IsTemplate: Boolean;
begin
  btnDelete.Enabled := lvList.SelCount > 0;
  btnEdit.Enabled := lvList.Selected <> nil;
  btnDup.Enabled := lvList.SelCount > 0;
  IsTemplate := (lvList.Selected <> nil) and
    TCnSymbolItem(lvList.Selected.Data).AllowMultiLine;
  mmoTemplate.Enabled := IsTemplate;
  btnInsertMacro.Enabled := IsTemplate;
  btnUserMacro.Enabled := IsTemplate;
  btnCursor.Enabled := IsTemplate;
  btnClear.Enabled := IsTemplate;
  if IsTemplate then
    mmoTemplate.Lines.Text := TCnSymbolItem(lvList.Selected.Data).Text
  else
    mmoTemplate.Lines.Clear;
end;

procedure TCnInputHelperForm.lvListColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if Column.Index = SortIdx then
    SortDesc := not SortDesc
  else
    SortIdx := Column.Index;
  lvList.AlphaSort;
end;

procedure TCnInputHelperForm.lvListCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if SortIdx = 0 then
    Compare := CompareText(Item1.Caption, Item2.Caption)
  else if SortIdx = 2 then
  begin
    if TCnSymbolItem(Item1.Data).Scope > TCnSymbolItem(Item2.Data).Scope then
      Compare := 1
    else if TCnSymbolItem(Item1.Data).Scope < TCnSymbolItem(Item2.Data).Scope then
      Compare := -1
    else
      Compare := 0;
  end
  else if (SortIdx > 0) and (SortIdx <= Item1.SubItems.Count) then
    Compare := CompareText(Item1.SubItems[SortIdx - 1], Item2.SubItems[SortIdx - 1]);
  if SortDesc then
    Compare := -Compare;
end;

procedure TCnInputHelperForm.lvListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateListControls(Sender);
end;

procedure TCnInputHelperForm.cbbListChange(Sender: TObject);
begin
  if cbbList.ItemIndex >= 0 then
  begin
    CurrList := TCnSymbolList(cbbList.Items.Objects[cbbList.ItemIndex]);
    InitListView;
  end;
end;

function TCnInputHelperForm.DoAddSymbol(const NewName: string): Boolean;
var
  AName, ADesc: string;
  LVItem: TListItem;
  AlwaysDisp: Boolean;
  ForPascal: Boolean;
  ForCpp: Boolean;
  Idx: Integer;
begin
  AName := NewName;
  ADesc := '';
  AlwaysDisp := False;
  ForPascal := CurrentIsDelphiSource;
  ForCpp := CurrentIsCSource;

  if CnShowInputHelperEditForm(AName, ADesc, SaveKind, SaveScope,
    SaveAutoIndent, AlwaysDisp, ForPascal, ForCpp) then
  begin
    Idx := CurrList.Add(AName, SaveKind, RateToScope(SaveScope), ADesc, '',
      SaveAutoIndent, AlwaysDisp);
    CurrList.Items[Idx].ForPascal := ForPascal;
    CurrList.Items[Idx].ForCpp := ForCpp;

    LVItem := lvList.Items.Add;
    LVItem.Data := CurrList.Items[CurrList.Count - 1];
    UpdateListItem(LVItem);
    ListViewSelectItems(lvList, smNothing);
    lvList.Selected := LVItem;
    lvList.AlphaSort;
    Result := True;
  end
  else
    Result := False;
end;

procedure TCnInputHelperForm.btnAddClick(Sender: TObject);
begin
  DoAddSymbol('');
end;

procedure TCnInputHelperForm.btnDupClick(Sender: TObject);
var
  I: Integer;
  Item: TCnSymbolItem;
  LVItem: TListItem;
begin
  if lvList.SelCount > 0 then
  begin
    for I := 0 to lvList.Items.Count - 1 do
    begin
      if lvList.Items[I].Selected then
      begin
        lvList.Items[I].Selected := False;
        Item := TCnSymbolItem.Create;
        Item.Assign(TCnSymbolItem(lvList.Items[I].Data));
        Item.Name := Item.Name + '1';
        CurrList.Add(Item);
        LVItem := lvList.Items.Add;
        LVItem.Data := Item;
        LVItem.Selected := True;
        UpdateListItem(LVItem);
      end;
    end;
    lvList.AlphaSort;
  end;
end;

procedure TCnInputHelperForm.btnDeleteClick(Sender: TObject);
var
  I, Idx: Integer;
begin
  if (lvList.SelCount > 0) and QueryDlg(SCnDeleteConfirm) then
  begin
    Idx := -1;
    for I := lvList.Items.Count - 1 downto 0 do
    begin
      if lvList.Items[I].Selected then
      begin
        Idx := I;
        CurrList.Remove(TCnSymbolItem(lvList.Items[I].Data));
        lvList.Items.Delete(I);
      end;
    end;

    if Idx > lvList.Items.Count - 1 then
      Idx := lvList.Items.Count - 1;
    if Idx >= 0 then
      lvList.Selected := lvList.Items[Idx];
  end;
end;

procedure TCnInputHelperForm.btnEditClick(Sender: TObject);
var
  Item: TCnSymbolItem;
  AName, ADesc: string;
  AKind: TCnSymbolKind;
  AutoIndent: Boolean;
  AlwaysDisp: Boolean;
  AScope: Integer;
  ForPascal: Boolean;
  ForCpp: Boolean;
begin
  if lvList.Selected <> nil then
  begin
    Item := TCnSymbolItem(lvList.Selected.Data);
    AName := Item.Name;
    ADesc := Item.Description;
    AKind := Item.Kind;
    AScope := Item.ScopeRate;
    AutoIndent := Item.AutoIndent;
    AlwaysDisp := Item.AlwaysDisp;
    ForPascal := Item.ForPascal;
    ForCpp := Item.ForCpp;

    if CnShowInputHelperEditForm(AName, ADesc, AKind, AScope, AutoIndent,
      AlwaysDisp, ForPascal, ForCpp) then
    begin
      Item.Name := AName;
      Item.Description := ADesc;
      Item.Kind := AKind;
      Item.ScopeRate := AScope;
      Item.AutoIndent := AutoIndent;
      Item.AlwaysDisp := AlwaysDisp;
      Item.ForPascal := ForPascal;
      Item.ForCpp := ForCpp;

      UpdateListView(True);
      lvList.AlphaSort;
    end;
  end;
end;

procedure TCnInputHelperForm.btnImportClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    if not QueryDlg(SCnImportAppend) then
      CurrList.Clear;
    if not LoadListFromXMLFile(CurrList, dlgOpen.FileName) then
      ErrorDlg(SCnImportError);
    InitListView;
  end;
end;

procedure TCnInputHelperForm.btnExportClick(Sender: TObject);
begin
  if dlgSave.Execute then
    if not SaveListToXMLFile(CurrList, dlgSave.FileName) then
      ErrorDlg(SCnExportError);
end;

procedure TCnInputHelperForm.btnClearClick(Sender: TObject);
begin
  mmoTemplate.Lines.Clear;
end;

procedure TCnInputHelperForm.mmoTemplateExit(Sender: TObject);
begin
  if lvList.Selected <> nil then
    TCnSymbolItem(lvList.Selected.Data).Text := mmoTemplate.Lines.Text;
end;

procedure TCnInputHelperForm.btnInsertMacroClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Point(0, btnInsertMacro.Height);
  P := btnInsertMacro.ClientToScreen(P);
  pmMacro.Popup(P.x, P.y);
end;

procedure TCnInputHelperForm.OnMacroMenu(Sender: TObject);
var
  Macro: string;
  I: Integer;
begin
  if Sender is TMenuItem then
  begin
    Macro := GetMacro(GetMacroDefText(TCnWizMacro(TMenuItem(Sender).Tag)));
    for I := 1 to Length(Macro) do
      mmoTemplate.Perform(WM_CHAR, Ord(Macro[I]), 0);
    mmoTemplate.SetFocus;
  end;
end;

procedure TCnInputHelperForm.btnUserMacroClick(Sender: TObject);
var
  Ini: TCustomIniFile;
  Macro: string;
  I: Integer;
begin
  Ini := InputHelper.CreateIniFile;
  try
    if CnWizInputQuery(SCnInputHelperUserMacroCaption, SCnInputHelperUserMacroPrompt,
      Macro, Ini, 'UserMacroHis') then
    begin
      Macro := GetMacro(Macro);
      for I := 1 to Length(Macro) do
        mmoTemplate.Perform(WM_CHAR, Ord(Macro[I]), 0);
      mmoTemplate.SetFocus;
    end;
  finally
    Ini.Free;
  end;
end;

procedure TCnInputHelperForm.btnCursorClick(Sender: TObject);
begin
  mmoTemplate.Perform(WM_CHAR, Ord('|'), 0);
end;

procedure TCnInputHelperForm.btnDefaultClick(Sender: TObject);
begin
  if (CurrList <> nil) and QueryDlg(SCnDefaultConfirm) then
  begin
    CurrList.Load;
    InitListView;
  end;
end;

procedure TCnInputHelperForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Hk: THotKey;
begin
  if (ActiveControl = nil) or not (ActiveControl is THotKey) then
    Exit;

  Hk := ActiveControl as THotKey;

  if Key = VK_SPACE then
  begin
    if ssAlt in Shift then
    begin
      Hk.HotKey := ShortCut(VK_SPACE, [ssAlt]);
      Key := 0;
    end
    else if ssCtrl in Shift then
    begin
      Hk.HotKey := ShortCut(VK_SPACE, [ssCtrl]);
      Key := 0;
    end;
  end;
end;

procedure TCnInputHelperForm.chkSpcCompleteClick(Sender: TObject);
begin
  chkIgnoreSpace.Enabled := chkSpcComplete.Checked;
end;

procedure TCnInputHelperForm.chkDispOnIDECompDisabledClick(
  Sender: TObject);
begin
  btnDisableCompletion.Enabled := chkDispOnIDECompDisabled.Checked;
end;

procedure TCnInputHelperForm.btnDisableCompletionClick(Sender: TObject);
const
  SCnCodeCompletionKey = 'CodeCompletion';
  SCnCodeInsightAutoInvokeKey = 'CodeInsightAutoInvoke';
var
  Options: IOTAEnvironmentOptions;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Options = nil then
    Exit;

  Options.SetOptionValue(SCnCodeCompletionKey, 0);
{$IFDEF IDE_CODEINSIGHT_AUTOINVOKE}
  Options.SetOptionValue(SCnCodeInsightAutoInvokeKey, 0);
{$ENDIF}
  InfoDlg(SCnInputHelperDisableCodeCompletionSucc);
end;

procedure TCnInputHelperForm.FormCreate(Sender: TObject);
begin
  EnlargeListViewColumns(lvList);
end;

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.

