{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnSrcEditorCodeWrap;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展其它工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2024.09.24
*               加入对 Pascal 或 C/++ 的设置及显示过滤
*           2013.09.01
*               修正 Unicode 环境下可能乱码的问题
*           2005.06.14
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, StdCtrls, ComCtrls, Menus, ToolsApi, CnSpin, CnClasses,
  CnWizConsts, CnCommon, CnWizOptions, CnWizUtils, CnWizMacroText, CnWizMacroFrm,
  CnWizShortCut, OmniXML, OmniXMLPersistent;

type
  TCnCodeWrapItem = class(TCnAssignableCollectionItem)
  private
    FCaption: string;
    FShortCut: TShortCut;
    FLineBlockMode: Boolean;
    FIndentLevel: Integer;
    FHeadText: string;
    FHeadAutoIndent: Boolean;
    FHeadIndentLevel: Integer;
    FTailText: string;
    FTailAutoIndent: Boolean;
    FTailIndentLevel: Integer;
    FForPas: Boolean;
    FForCpp: Boolean;
  public
    constructor Create(Collection: TCollection); override;
  published
    property Caption: string read FCaption write FCaption;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property LineBlockMode: Boolean read FLineBlockMode write FLineBlockMode;
    property IndentLevel: Integer read FIndentLevel write FIndentLevel;
    property HeadText: string read FHeadText write FHeadText;
    property HeadAutoIndent: Boolean read FHeadAutoIndent write FHeadAutoIndent;
    property HeadIndentLevel: Integer read FHeadIndentLevel write FHeadIndentLevel;
    property TailText: string read FTailText write FTailText;
    property TailAutoIndent: Boolean read FTailAutoIndent write FTailAutoIndent;
    property TailIndentLevel: Integer read FTailIndentLevel write FTailIndentLevel;
    property ForPas: Boolean read FForPas write FForPas;
    property ForCpp: Boolean read FForCpp write FForCpp;
  end;

  TCnCodeWrapCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TCnCodeWrapItem;
    procedure SetItem(Index: Integer; const Value: TCnCodeWrapItem);
  public
    constructor Create;
    function Add: TCnCodeWrapItem;
    function LoadFromFile(const FileName: string; Append: Boolean = False): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    property Items[Index: Integer]: TCnCodeWrapItem read GetItem write SetItem; default;
  end;

  TCnSrcEditorCodeWrapForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnImport: TButton;
    btnExport: TButton;
    grp2: TGroupBox;
    lbl1: TLabel;
    edtCaption: TEdit;
    lbl4: TLabel;
    HotKey: THotKey;
    chkLineBlock: TCheckBox;
    lbl2: TLabel;
    mmoHead: TMemo;
    lbl5: TLabel;
    mmoTail: TMemo;
    lbl6: TLabel;
    lbl7: TLabel;
    seIndent: TCnSpinEdit;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    chkHeadIndent: TCheckBox;
    lbl8: TLabel;
    seHeadIndent: TCnSpinEdit;
    chkTailIndent: TCheckBox;
    lbl9: TLabel;
    seTailIndent: TCnSpinEdit;
    btnUp: TButton;
    btnDown: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    chkForPas: TCheckBox;
    chkForCpp: TCheckBox;
    btnReset: TButton;
    procedure ListViewData(Sender: TObject; Item: TListItem);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure ControlChanged(Sender: TObject);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnHelpClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  private
    List: TCnCodeWrapCollection;
    IsUpdating: Boolean;
    procedure UpdateListView;
    procedure UpdateControls;
    procedure SetDataToControls;
    procedure GetDataFromControls;
  public
    function GetHelpTopic: string; override;
  end;

  TCnSrcEditorCodeWrapTool = class
  private
    FItems: TCnCodeWrapCollection;
    FMenu: TMenuItem;
    FShortCuts: TList;
  protected
    procedure OnMenuItemClick(Sender: TObject);
    procedure OnConfig(Sender: TObject);
    procedure OnShortCut(Sender: TObject);
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
    function Config: Boolean;
    procedure Execute(Item: TCnCodeWrapItem);
    procedure InitMenuItems(AMenu: TMenuItem);
    {* 初始化时被调用供创建菜单项}
    procedure UpdateMenuItems(AMenu: TMenuItem);
    {* 弹出时被调用供控制可见项}
    property Items: TCnCodeWrapCollection read FItems;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

{ TCnCodeWrapItem }

constructor TCnCodeWrapItem.Create(Collection: TCollection);
begin
  inherited;
  LineBlockMode := True;
  HeadAutoIndent := True;
  TailAutoIndent := True;
  ForPas := True;
  ForCpp := True;
end;

{ TCnCodeWrapCollection }

function TCnCodeWrapCollection.Add: TCnCodeWrapItem;
begin
  Result := TCnCodeWrapItem(inherited Add);
end;

constructor TCnCodeWrapCollection.Create;
begin
  inherited Create(TCnCodeWrapItem);
end;

function TCnCodeWrapCollection.GetItem(Index: Integer): TCnCodeWrapItem;
begin
  Result := TCnCodeWrapItem(inherited Items[Index]);
end;

function TCnCodeWrapCollection.LoadFromFile(const FileName: string;
  Append: Boolean): Boolean;
var
  Col: TCnCodeWrapCollection;
  I: Integer;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  try
    if not Append then
      Clear;

    Col := TCnCodeWrapCollection.Create;
    try
      TOmniXMLReader.LoadFromFile(Col, FileName);
      for I := 0 to Col.Count - 1 do
        Add.Assign(Col.Items[I]);
      Result := True;
    finally
      Col.Free;
    end;
  except
    ;
  end;
end;

function TCnCodeWrapCollection.SaveToFile(const FileName: string): Boolean;
begin
  Result := False;
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    ;
  end;
end;

procedure TCnCodeWrapCollection.SetItem(Index: Integer;
  const Value: TCnCodeWrapItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnSrcEditorCodeWrapTool }

procedure TCnSrcEditorCodeWrapTool.Clear;
var
  I: Integer;
  ShortCut: TCnWizShortCut;
begin
  if FMenu <> nil then
    FMenu.Clear;

  for I := 0 to FShortCuts.Count - 1 do
  begin
    ShortCut := TCnWizShortCut(FShortCuts[I]);
    WizShortCutMgr.DeleteShortCut(ShortCut);
  end;
  FShortCuts.Clear;
end;

function TCnSrcEditorCodeWrapTool.Config: Boolean;
begin
  with TCnSrcEditorCodeWrapForm.Create(Application) do
  try
    List.Assign(FItems);
    Result := ShowModal = mrOk;

    if Result then
    begin
      FItems.Assign(List);
      FItems.SaveToFile(WizOptions.GetUserFileName(SCnCodeWrapFile, False));
      WizOptions.CheckUserFile(SCnCodeWrapFile);

      if FMenu <> nil then
        InitMenuItems(FMenu);
    end;
  finally
    Free;
  end;
end;

constructor TCnSrcEditorCodeWrapTool.Create;
begin
  inherited;
  FItems := TCnCodeWrapCollection.Create;
  FItems.LoadFromFile(WizOptions.GetUserFileName(SCnCodeWrapFile, True));
  FShortCuts := TList.Create;
end;

destructor TCnSrcEditorCodeWrapTool.Destroy;
begin
  Clear;
  FShortCuts.Free;
  FItems.Free;
  inherited;
end;

procedure TCnSrcEditorCodeWrapTool.Execute(Item: TCnCodeWrapItem);
var
  EditView: IOTAEditView;
  StartLine, EndLine: Integer;
  MacroText: TCnWizMacroText;
  Lines, Macros: TStringList;
  HeadText, TailText, BlockText: string;
  Relocate, NeedAlignStart: Boolean;
  CurPos, BlockIndent, CurrIndent, PrevIndent: Integer;
  CurX, CurY: Integer;
  StartPos: Integer;

  function ProcessMacros: Boolean;
  begin
    Result := False;
    MacroText := nil;
    Macros := nil;
    try
      HeadText := StringReplace(Item.HeadText, GetMacroEx(cwmCursor), '|', [rfReplaceAll]);
      TailText := StringReplace(Item.TailText, GetMacroEx(cwmCursor), '|', [rfReplaceAll]);
      MacroText := TCnWizMacroText.Create('');
      Macros := TStringList.Create;
      Macros.Duplicates := dupIgnore;

      MacroText.Text := HeadText;
      Macros.AddStrings(MacroText.Macros);
      MacroText.Text := TailText;
      Macros.AddStrings(MacroText.Macros);
      if not GetEditorMacroValue(Macros) then
        Exit;

      MacroText.Text := HeadText;
      MacroText.Macros.Assign(Macros);
      HeadText := MacroText.OutputText(CurPos);
      MacroText.Text := TailText;
      MacroText.Macros.Assign(Macros);
      TailText := MacroText.OutputText(CurPos);
      Result := True;
    finally
      MacroText.Free;
      Macros.Free;
    end;
  end;

  function GetIndentPos(AEditView: IOTAEditView): Integer;
  var
    Text: string;
    CharPos: TOTACharPos;
    EditPos: TOTAEditPos;
  begin
    // 向下查找选区中的第一个非空行
    CharPos.Line := AEditView.Block.StartingRow - 1;
    repeat
      Inc(CharPos.Line);
      Text := CnOtaGetLineText(CharPos.Line, AEditView.Buffer);
    until (Trim(Text) <> '') or (CharPos.Line >= AEditView.Block.EndingRow);

    // 向上查找非空行
    if Trim(Text) = '' then
    begin
      CharPos.Line := AEditView.Block.StartingRow;
      repeat
        Dec(CharPos.Line);
        Text := CnOtaGetLineText(CharPos.Line, AEditView.Buffer);
      until (Trim(Text) <> '') or (CharPos.Line <= 1);
    end;

    // 计算字符缩进量
    CharPos.CharIndex := 0;
    while (CharPos.CharIndex < Length(Text)) and
      CharInSet(Text[CharPos.CharIndex + 1], [' ', #9]) do
      Inc(CharPos.CharIndex);

    // 转换为栏位置
    AEditView.ConvertPos(False, EditPos, CharPos);
    Result := EditPos.Col - 1;
  end;

  function GetPreviousIndentPos(AEditView: IOTAEditView): Integer;
  var
    Text: string;
    CharPos: TOTACharPos;
    EditPos: TOTAEditPos;
  begin
    // 向上查找选区外的第一个非空行
    CharPos.Line := AEditView.Block.StartingRow;
    repeat
      Dec(CharPos.Line);
      Text := CnOtaGetLineText(CharPos.Line, AEditView.Buffer);
    until (Trim(Text) <> '') or (CharPos.Line <= 1);

    // 向下查找非空行
    if Trim(Text) = '' then
    begin
      CharPos.Line := AEditView.Block.StartingRow - 1;
      repeat
        Inc(CharPos.Line);
        Text := CnOtaGetLineText(CharPos.Line, AEditView.Buffer);
      until (Trim(Text) <> '') or (CharPos.Line >= AEditView.Block.EndingRow);
    end;

    // 计算字符缩进量
    CharPos.CharIndex := 0;
    while (CharPos.CharIndex < Length(Text)) and
      CharInSet(Text[CharPos.CharIndex + 1], [' ', #9]) do
      Inc(CharPos.CharIndex);

    // 转换为栏位置
    AEditView.ConvertPos(False, EditPos, CharPos);
    Result := EditPos.Col - 1;
  end;

  procedure OutputLines(ALineNo: Integer; AIndent: Integer);
  var
    Line: string;
    I: Integer;
  begin
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      if AIndent > 0 then
        Line := Spc(AIndent) + Line;

      if not Relocate and (Pos('|', Line) > 0) then
      begin
        CurX := Pos('|', Line);
        CurY := ALineNo + I;
        Relocate := True;
      end;

      Line := StringReplace(Line, '|', '', [rfReplaceAll]);
      CnOtaInsertSingleLine(ALineNo + I, Line, EditView);
    end;
  end;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) and EditView.Block.IsValid and
    (EditView.Block.Style <> btColumn) then
  begin
    if not ProcessMacros then
      Exit;

    if not Item.LineBlockMode then
    begin
      StartPos := CnOtaEditPosToLinePos(OTAEditPos(EditView.Block.StartingColumn,
        EditView.Block.StartingRow), EditView);

{$IFDEF UNICODE}
      BlockText := EditView.Block.Text; // Unicode 环境下无需转换
{$ELSE}
      BlockText := ConvertEditorTextToText(EditView.Block.Text);
{$ENDIF}

      CurPos := AnsiPos('|', HeadText);
      HeadText := StringReplace(HeadText, '|', '', [rfReplaceAll]);
      if CurPos = 0 then
      begin
        CurPos := AnsiPos('|', TailText);
        if CurPos > 0 then
          CurPos := Length(HeadText) + Length(BlockText) + CurPos;
      end;
      TailText := StringReplace(TailText, '|', '', [rfReplaceAll]);

      EditView.Block.Delete;

{$IFDEF UNICODE}
      CnOtaInsertTextIntoEditorAtPosW(HeadText + BlockText + TailText, StartPos,
        EditView.Buffer);
{$ELSE}
      CnOtaInsertTextIntoEditorAtPos(HeadText + BlockText + TailText, StartPos,
        EditView.Buffer);
{$ENDIF}

      if CurPos > 0 then
        EditView.CursorPos := CnOtaLinePosToEditPos(StartPos + CurPos - 1, EditView);
    end
    else
    begin
      NeedAlignStart := Item.HeadAutoIndent and Item.TailAutoIndent and
        ((IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName)) and ((LowerCase(Item.HeadText) = 'begin') or (LowerCase(Item.HeadText) = 'try'))
         or (IsCppSourceModule(EditView.Buffer.FileName) and (LowerCase(Item.HeadText) = '{')));
      // begin 和 try 开头的块，以及 C 中的大括号，需要和上一行开头对齐

     // 计算块首尾行
      StartLine := EditView.Block.StartingRow;
      EndLine := EditView.Block.EndingRow;
      if EditView.Block.EndingColumn > 1 then
        Inc(EndLine);

      // 计算缩进量
      CurrIndent := GetIndentPos(EditView);
      BlockIndent := CnOtaGetBlockIndent;

      // 先把块和上一行先对齐
      if NeedAlignStart then
      begin
        PrevIndent := GetPreviousIndentPos(EditView);
        EditView.Block.Indent(PrevIndent - CurrIndent + BlockIndent * Item.IndentLevel);
        CurrIndent := PrevIndent;
      end
      else if Item.IndentLevel <> 0 then // 缩进当前块
        EditView.Block.Indent(BlockIndent * Item.IndentLevel);

      Relocate := False;
      CurX := 0;
      CurY := 0;
      Lines := TStringList.Create;
      try
        if HeadText <> '' then
        begin
          Lines.Text := HeadText;
          if Item.HeadAutoIndent then
            OutputLines(StartLine, CurrIndent + Item.HeadIndentLevel * BlockIndent)
          else
            OutputLines(StartLine, 0);
          Inc(EndLine, Lines.Count);
        end;

        if TailText <> '' then
        begin
          Lines.Text := TailText;
          if Item.TailAutoIndent then
            OutputLines(EndLine, CurrIndent + Item.TailIndentLevel * BlockIndent)
          else
            OutputLines(EndLine, 0);
        end;
      finally
        Lines.Free;
      end;

      if Relocate then
        EditView.CursorPos := OTAEditPos(CurX, CurY);
    end;

    Application.ProcessMessages;
    EditView.Paint;
  end;
end;

procedure TCnSrcEditorCodeWrapTool.InitMenuItems(AMenu: TMenuItem);
var
  I: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    FMenu := AMenu;
    Clear;

    for I := 0 to Items.Count - 1 do
    begin
      AddMenuItem(AMenu, Items[I].Caption, OnMenuItemClick, nil,
        Items[I].ShortCut, '', I);

//    加了WizShortCutMgr的处理后热键弹出右键菜单后可能会出未知错误。
//    2007.12.13 Commented by LiuXiao | 2008.11.11 UnCommented Back

      if (Items[I].Caption <> '-') and (Items[I].ShortCut <> 0) then
        FShortCuts.Add(WizShortCutMgr.Add('', Items[I].ShortCut, OnShortCut, '', I));
    end;

    AddSepMenuItem(AMenu);
    AddMenuItem(AMenu, SCnWizConfigCaption, OnConfig);
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnSrcEditorCodeWrapTool.UpdateMenuItems(AMenu: TMenuItem);
var
  I: Integer;
  MI: TMenuItem;
  CI: TCnCodeWrapItem;
  Pas, Cpp: Boolean;
begin
  // 避免不匹配
  if (AMenu.Count <= 0) or (AMenu.Count < Items.Count) then
    Exit;

  Pas := CurrentIsDelphiSource;
  Cpp := CurrentIsCSource;

  for I := 0 to Items.Count - 1 do
  begin
    MI := AMenu.Items[I];
    CI := Items[I];

    if (CI.Caption = '-') or (not Pas and not Cpp) then
      MI.Visible := True // 分隔条，以及不认识的扩展名，都显示
    else if Pas then
      MI.Visible := CI.ForPas
    else if Cpp then
      MI.Visible := CI.ForCpp;
  end;
end;

procedure TCnSrcEditorCodeWrapTool.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnSrcEditorCodeWrapTool.OnMenuItemClick(Sender: TObject);
var
  Item: TCnCodeWrapItem;
begin
  if Sender is TMenuItem then
  begin
    Item := Items[TMenuItem(Sender).Tag];
    if Item <> nil then
      Execute(Item);
  end;
end;

procedure TCnSrcEditorCodeWrapTool.OnShortCut(Sender: TObject);
var
  Item: TCnCodeWrapItem;
begin
  if Sender is TCnWizShortCut then
  begin
    Item := Items[TCnWizShortCut(Sender).Tag];
    if Item <> nil then
      Execute(Item);
  end;
end;

{ TCnSrcEditorCodeWrapForm }

procedure TCnSrcEditorCodeWrapForm.FormCreate(Sender: TObject);
begin
  inherited;
  List := TCnCodeWrapCollection.Create;
end;

procedure TCnSrcEditorCodeWrapForm.FormDestroy(Sender: TObject);
begin
  inherited;
  List.Free;
end;

function TCnSrcEditorCodeWrapForm.GetHelpTopic: string;
begin
  Result := 'CnSrcEditorCodeWrap';
end;

procedure TCnSrcEditorCodeWrapForm.ListViewData(Sender: TObject;
  Item: TListItem);
begin
  Item.Caption := List.Items[Item.Index].Caption;
  Item.SubItems.Clear;
  Item.SubItems.Add(ShortCutToText(List.Items[Item.Index].ShortCut));
  Item.SubItems.Add(IntToStr(List.Items[Item.Index].IndentLevel));
end;

procedure TCnSrcEditorCodeWrapForm.FormShow(Sender: TObject);
begin
  inherited;
  UpdateListView;
end;

procedure TCnSrcEditorCodeWrapForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnSrcEditorCodeWrapForm.UpdateListView;
begin
  ListView.Items.Count := List.Count;
  ListView.Refresh;
  UpdateControls;
end;

procedure TCnSrcEditorCodeWrapForm.btnAddClick(Sender: TObject);
begin
  ListViewSelectItems(ListView, smNothing);
  List.Add;
  UpdateListView;
  ListView.Selected := ListView.Items[ListView.Items.Count - 1];
  ListView.Selected.MakeVisible(True);
  edtCaption.SetFocus;
end;

procedure TCnSrcEditorCodeWrapForm.btnDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  if (ListView.SelCount > 0) and QueryDlg(SCnDeleteConfirm) then
  begin
    for I := ListView.Items.Count - 1 downto 0 do
    begin
      if ListView.Items[I].Selected then
        List.Delete(I);
    end;

    UpdateListView;
    ListViewSelectItems(ListView, smNothing);
  end;
end;

procedure TCnSrcEditorCodeWrapForm.btnUpClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to ListView.Items.Count - 1 do
  begin
    if ListView.Items[I].Selected and not ListView.Items[I - 1].Selected then
    begin
      List.Items[I].Index := I - 1;
      ListView.Items[I - 1].Selected := True;
      ListView.Items[I].Selected := False;
    end;
  end;
  ListView.Update;
end;

procedure TCnSrcEditorCodeWrapForm.btnDownClick(Sender: TObject);
var
  I: Integer;
begin
  for I := ListView.Items.Count - 2 downto 0 do
  begin
    if ListView.Items[I].Selected and not ListView.Items[I + 1].Selected then
    begin
      List.Items[I].Index := I + 1;
      ListView.Items[I + 1].Selected := True;
      ListView.Items[I].Selected := False;
    end;
  end;
  ListView.Update;
end;

procedure TCnSrcEditorCodeWrapForm.btnImportClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    List.LoadFromFile(dlgOpen.FileName, QueryDlg(SCnImportAppend));
    UpdateListView;
  end;
end;

procedure TCnSrcEditorCodeWrapForm.btnExportClick(Sender: TObject);
begin
  if dlgSave.Execute then
    List.SaveToFile(dlgSave.FileName);
end;

procedure TCnSrcEditorCodeWrapForm.ControlChanged(Sender: TObject);
begin
  UpdateControls;
  GetDataFromControls;
end;

procedure TCnSrcEditorCodeWrapForm.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  SetDataToControls;
  UpdateControls;
end;

procedure TCnSrcEditorCodeWrapForm.ListViewKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  SetDataToControls;
  UpdateControls;
end;

procedure TCnSrcEditorCodeWrapForm.ListViewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SetDataToControls;
  UpdateControls;
end;

procedure TCnSrcEditorCodeWrapForm.GetDataFromControls;
var
  Item: TCnCodeWrapItem;
begin
  if not IsUpdating and (ListView.Selected <> nil) then
  begin
    IsUpdating := True;
    try
      Item := List.Items[ListView.Selected.Index];
      Item.Caption := edtCaption.Text;
      Item.ShortCut := HotKey.HotKey;
      Item.LineBlockMode := chkLineBlock.Checked;
      Item.IndentLevel := seIndent.Value;
      Item.HeadText := mmoHead.Lines.Text;
      Item.HeadAutoIndent := chkHeadIndent.Checked;
      Item.HeadIndentLevel := seHeadIndent.Value;
      Item.TailText := mmoTail.Lines.Text;
      Item.TailAutoIndent := chkTailIndent.Checked;
      Item.TailIndentLevel := seTailIndent.Value;
      Item.ForPas := chkForPas.Checked;
      Item.ForCpp := chkForCpp.Checked;
      ListView.Selected.Update;
    finally
      IsUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorCodeWrapForm.SetDataToControls;
var
  Item: TCnCodeWrapItem;
begin
  if not IsUpdating then
  begin
    IsUpdating := True;
    try
      if ListView.Selected <> nil then
      begin
        Item := List.Items[ListView.Selected.Index];
        edtCaption.Text := Item.Caption;
        HotKey.HotKey := Item.ShortCut;
        chkLineBlock.Checked := Item.LineBlockMode;
        seIndent.Value := Item.IndentLevel;
        mmoHead.Lines.Text := Item.HeadText;
        chkHeadIndent.Checked := Item.HeadAutoIndent;
        seHeadIndent.Value := Item.HeadIndentLevel;
        mmoTail.Lines.Text := Item.TailText;
        chkTailIndent.Checked := Item.TailAutoIndent;
        seTailIndent.Value := Item.TailIndentLevel;
        chkForPas.Checked := Item.ForPas;
        chkForCpp.Checked := Item.ForCpp;
      end
      else
      begin
        edtCaption.Text := '';
        HotKey.HotKey := 0;
        chkLineBlock.Checked := False;
        seIndent.Value := 0;
        mmoHead.Lines.Text := '';
        chkHeadIndent.Checked := False;
        seHeadIndent.Value := 0;
        mmoTail.Lines.Text := '';
        chkTailIndent.Checked := False;
        seTailIndent.Value := 0;
        chkForPas.Checked := False;
        chkForCpp.Checked := False;
      end;
    finally
      IsUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorCodeWrapForm.UpdateControls;
begin
  btnUp.Enabled := ListViewSelectedItemsCanUp(ListView);
  btnDown.Enabled := ListViewSelectedItemsCanDown(ListView);
  btnDelete.Enabled := ListView.SelCount > 0;
  edtCaption.Enabled := ListView.Selected <> nil;
  HotKey.Enabled := ListView.Selected <> nil;
  chkLineBlock.Enabled := ListView.Selected <> nil;
  seIndent.Enabled := (ListView.Selected <> nil) and chkLineBlock.Checked;
  mmoHead.Enabled := ListView.Selected <> nil;
  chkHeadIndent.Enabled := (ListView.Selected <> nil) and chkLineBlock.Checked;
  seHeadIndent.Enabled := (ListView.Selected <> nil) and chkLineBlock.Checked and
    chkHeadIndent.Checked;
  mmoTail.Enabled := ListView.Selected <> nil;
  chkTailIndent.Enabled := (ListView.Selected <> nil) and chkLineBlock.Checked;
  seTailIndent.Enabled := (ListView.Selected <> nil) and chkLineBlock.Checked and
    chkTailIndent.Checked;
  chkForPas.Enabled := ListView.Selected <> nil;
  chkForCpp.Enabled := ListView.Selected <> nil;
end;

procedure TCnSrcEditorCodeWrapForm.btnResetClick(Sender: TObject);
var
  S: string;
begin
  // 删除旧配置文件并重新载入
  S := WizOptions.GetAbsoluteUserFileName(SCnCodeWrapFile);
  DeleteFile(S);

  List.Clear;
  S := WizOptions.GetUserFileName(SCnCodeWrapFile, True);
  List.LoadFromFile(S);

  UpdateListView;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
