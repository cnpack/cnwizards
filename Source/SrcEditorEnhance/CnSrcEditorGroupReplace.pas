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

unit CnSrcEditorGroupReplace;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展其它工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2013.09.01
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
  CnWizConsts, CnCommon, CnWizOptions, CnWizUtils, CnWizShortCut, OmniXML,
  OmniXMLPersistent, CnGroupReplace;

type
  TCnXMLGroupReplacements = class(TCnGroupReplacements)
  public
    function LoadFromFile(const FileName: string; Append: Boolean = False): Boolean;
    function SaveToFile(const FileName: string): Boolean;
  end;

  TCnSrcEditorGroupReplaceForm = class(TCnTranslateForm)
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
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnUp: TButton;
    btnDown: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    lvItems: TListView;
    btnItemAdd: TButton;
    btnItemDelete: TButton;
    btnItemUp: TButton;
    btnItemDown: TButton;
    lbl2: TLabel;
    edtSource: TEdit;
    lbl3: TLabel;
    edtDest: TEdit;
    chkIgnoreCase: TCheckBox;
    chkWholeWord: TCheckBox;
    lbl5: TLabel;
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
    procedure lvItemsData(Sender: TObject; Item: TListItem);
    procedure btnItemAddClick(Sender: TObject);
    procedure btnItemDeleteClick(Sender: TObject);
    procedure btnItemUpClick(Sender: TObject);
    procedure btnItemDownClick(Sender: TObject);
    procedure ItemControlChanged(Sender: TObject);
    procedure lvItemsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvItemsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvItemsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    List: TCnXMLGroupReplacements;
    IsUpdating: Boolean;
    IsItemUpdating: Boolean;
    procedure UpdateControls;
    procedure UpdateListView;
    procedure SetDataToControls;
    procedure GetDataFromControls;
    procedure UpdateItemListView;
    procedure SetItemDataToControls;
    procedure GetItemDataFromControls;
  public
    function GetHelpTopic: string; override;
  end;

  TCnSrcEditorGroupReplaceTool = class
  private
    FItems: TCnXMLGroupReplacements;
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
    procedure Execute(Item: TCnGroupReplacement);
    procedure InitMenuItems(AMenu: TMenuItem);
    property Items: TCnXMLGroupReplacements read FItems;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnSrcEditorReplaceInBlock;

const
  TAG_REPLACE_IN_BLOCK = -1;

{$R *.DFM}

function TCnXMLGroupReplacements.LoadFromFile(const FileName: string;
  Append: Boolean): Boolean;
var
  Col: TCnXMLGroupReplacements;
  I: Integer;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  try
    if not Append then
      Clear;
      
    Col := TCnXMLGroupReplacements.Create;
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

function TCnXMLGroupReplacements.SaveToFile(const FileName: string): Boolean;
begin
  Result := False;
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    ;
  end;
end;

{ TCnSrcEditorGroupReplaceTool }

procedure TCnSrcEditorGroupReplaceTool.Clear;
var
  i: Integer;
  ShortCut: TCnWizShortCut;
begin
  if FMenu <> nil then
    FMenu.Clear;
    
  WizShortCutMgr.BeginUpdate;
  try
    for i := 0 to FShortCuts.Count - 1 do
    begin
      ShortCut := TCnWizShortCut(FShortCuts[i]);
      WizShortCutMgr.DeleteShortCut(ShortCut);
    end;
  finally
    WizShortCutMgr.EndUpdate;
  end;          
  FShortCuts.Clear;
end;

function TCnSrcEditorGroupReplaceTool.Config: Boolean;
begin
  with TCnSrcEditorGroupReplaceForm.Create(Application) do
  try
    List.Assign(FItems);
    Result := ShowModal = mrOk;
    if Result then
    begin
      FItems.Assign(List);
      FItems.SaveToFile(WizOptions.GetUserFileName(SCnGroupReplaceFile, False));
      WizOptions.CheckUserFile(SCnGroupReplaceFile);
      if FMenu <> nil then
        InitMenuItems(FMenu);
    end;
  finally
    Free;
  end;
end;

constructor TCnSrcEditorGroupReplaceTool.Create;
begin
  inherited;
  FItems := TCnXMLGroupReplacements.Create;
  FItems.LoadFromFile(WizOptions.GetUserFileName(SCnGroupReplaceFile, True));
  FShortCuts := TList.Create;
end;

destructor TCnSrcEditorGroupReplaceTool.Destroy;
begin
  Clear;
  FShortCuts.Free;
  FItems.Free;
  inherited;
end;

procedure TCnSrcEditorGroupReplaceTool.Execute(Item: TCnGroupReplacement);
var
  EditView: IOTAEditView;
  StartPos: Integer;
  BlockText: string;
begin
  EditView := CnOtaGetTopMostEditView;
  if Assigned(EditView) and EditView.Block.IsValid and
    (EditView.Block.Style <> btColumn) then
  begin
    StartPos := CnOtaEditPosToLinePos(OTAEditPos(EditView.Block.StartingColumn,
      EditView.Block.StartingRow), EditView);

{$IFDEF UNICODE}
    BlockText := Item.Execute(EditView.Block.Text); // Unicode 环境下无需转换
{$ELSE}
    BlockText := Item.Execute(ConvertEditorTextToText(EditView.Block.Text));
{$ENDIF}

    EditView.Block.Delete;
{$IFDEF UNICODE}
    CnOtaInsertTextIntoEditorAtPosW(BlockText, StartPos, EditView.Buffer);
{$ELSE}
    CnOtaInsertTextIntoEditorAtPos(BlockText, StartPos, EditView.Buffer);
{$ENDIF}
    Application.ProcessMessages;
    EditView.Paint;
  end;
end;

procedure TCnSrcEditorGroupReplaceTool.InitMenuItems(AMenu: TMenuItem);
var
  I: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    FMenu := AMenu;
    Clear;

    AddMenuItem(AMenu, SCnSrcBlockReplaceInBlock, OnMenuItemClick, nil, 0, '', TAG_REPLACE_IN_BLOCK);
    AddSepMenuItem(AMenu);
    for I := 0 to Items.Count - 1 do
    begin
      AddMenuItem(AMenu, Items[I].Caption, OnMenuItemClick, nil,
        Items[I].ShortCut, '', I);

//      不能加WizShortCutMgr的处理，免得热键弹出右键菜单后出未知错误。2007.12.13 by LiuXiao
//      if (Items[i].Caption <> '-') and (Items[i].ShortCut <> 0) then
//        FShortCuts.Add(WizShortCutMgr.Add('', Items[i].ShortCut, OnShortCut, '', i));
    end;

    AddSepMenuItem(AMenu);
    AddMenuItem(AMenu, SCnWizConfigCaption, OnConfig);
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnSrcEditorGroupReplaceTool.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnSrcEditorGroupReplaceTool.OnMenuItemClick(Sender: TObject);
var
  Item: TCnGroupReplacement;
  Rule: TCnReplacement;
  ASource: string;
  ADest: string;
  Inverse, Save: Boolean;
begin
  if Sender is TMenuItem then
  begin
    if TMenuItem(Sender).Tag = TAG_REPLACE_IN_BLOCK then
    begin
      with TCnSrcEditorReplaceInBlockForm.Create(nil) do
      begin
        try
          if ShowModal = mrOK then
          begin
            ASource := edtFrom.Text;
            ADest := edtTo.Text;
            if ASource = '' then
              Exit;

            Inverse := chkInverse.Checked;
            Save := chkSaveToItem.Checked;

            // 创建临时 Item 并执行
            Item := FItems.Add;
            Rule := Item.Items.Add;
            Rule.Source := ASource;
            Rule.Dest := ADest;
            Rule.WholeWord := False;

            // 如果是双向
            if Inverse and (ADest <> '') then
            begin
              Rule := Item.Items.Add;
              Rule.Source := ADest;
              Rule.Dest := ASource;
              Rule.WholeWord := False;

              Item.Caption := ASource + ' <==> ' + ADest;
            end
            else
              Item.Caption := ASource + ' ==> ' + ADest;

            Execute(Item);

            // 不保存就删掉，保存则更新菜单
            if not Save then
              FItems.Delete(Item.Index)
            else if FMenu <> nil then
              InitMenuItems(FMenu);
          end;
        finally
          Free;
        end;
      end;
    end
    else
    begin
      Item := Items[TMenuItem(Sender).Tag];
      if Item <> nil then
        Execute(Item);
    end;
  end;
end;

procedure TCnSrcEditorGroupReplaceTool.OnShortCut(Sender: TObject);
var
  Item: TCnGroupReplacement;
begin
  if Sender is TCnWizShortCut then
  begin
    Item := Items[TCnWizShortCut(Sender).Tag];
    if Item <> nil then
      Execute(Item);
  end;
end;

{ TCnSrcEditorCodeWrapForm }

procedure TCnSrcEditorGroupReplaceForm.FormCreate(Sender: TObject);
begin
  inherited;
  List := TCnXMLGroupReplacements.Create;
end;

procedure TCnSrcEditorGroupReplaceForm.FormDestroy(Sender: TObject);
begin
  inherited;
  List.Free;
end;

function TCnSrcEditorGroupReplaceForm.GetHelpTopic: string;
begin
  Result := 'CnSrcEditorGroupReplace';
end;

procedure TCnSrcEditorGroupReplaceForm.FormShow(Sender: TObject);
begin
  inherited;
  UpdateListView;
end;

procedure TCnSrcEditorGroupReplaceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

//------------------------------------------------------------------------------
// 主列表处理
//------------------------------------------------------------------------------

procedure TCnSrcEditorGroupReplaceForm.ListViewData(Sender: TObject;
  Item: TListItem);
begin
  Item.Caption := List.Items[Item.Index].Caption;
  Item.SubItems.Clear;
  Item.SubItems.Add(ShortCutToText(List.Items[Item.Index].ShortCut));
  Item.SubItems.Add(IntToStr(List.Items[Item.Index].Items.Count));
end;

procedure TCnSrcEditorGroupReplaceForm.UpdateListView;
begin
  ListView.Items.Count := List.Count;
  ListView.Refresh;
  UpdateControls;
end;

procedure TCnSrcEditorGroupReplaceForm.btnAddClick(Sender: TObject);
begin
  ListViewSelectItems(ListView, smNothing);
  List.Add;
  UpdateListView;
  ListView.Selected := ListView.Items[ListView.Items.Count - 1];
  ListView.Selected.MakeVisible(True);
  edtCaption.SetFocus;
end;

procedure TCnSrcEditorGroupReplaceForm.btnDeleteClick(Sender: TObject);
var
  i: Integer;
begin
  if (ListView.SelCount > 0) and QueryDlg(SCnDeleteConfirm) then
  begin
    for i := ListView.Items.Count - 1 downto 0 do
      if ListView.Items[i].Selected then
        List.Delete(i);
    UpdateListView;
    ListViewSelectItems(ListView, smNothing);
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnUpClick(Sender: TObject);
var
  i: Integer;
begin
  IsUpdating := True;
  IsItemUpdating := True;
  try
    for i := 1 to ListView.Items.Count - 1 do
      if ListView.Items[i].Selected and not ListView.Items[i - 1].Selected then
      begin
        List.Items[i].Index := i - 1;
        ListView.Items[i - 1].Selected := True;
        ListView.Items[i].Selected := False;
      end;
    ListView.Update;
  finally
    IsUpdating := False;
    IsItemUpdating := False;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnDownClick(Sender: TObject);
var
  i: Integer;
begin
  IsUpdating := True;
  IsItemUpdating := True;
  try
    for i := ListView.Items.Count - 2 downto 0 do
      if ListView.Items[i].Selected and not ListView.Items[i + 1].Selected then
      begin
        List.Items[i].Index := i + 1;
        ListView.Items[i].Selected := False;
        ListView.Items[i + 1].Selected := True;
      end;
    ListView.Update;
  finally
    IsUpdating := False;
    IsItemUpdating := False;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnImportClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    List.LoadFromFile(dlgOpen.FileName, QueryDlg(SCnImportAppend));
    UpdateListView;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnExportClick(Sender: TObject);
begin
  if dlgSave.Execute then
    List.SaveToFile(dlgSave.FileName);
end;

procedure TCnSrcEditorGroupReplaceForm.ControlChanged(Sender: TObject);
begin
  UpdateControls;
  GetDataFromControls;
end;

procedure TCnSrcEditorGroupReplaceForm.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.ListViewKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.ListViewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.GetDataFromControls;
var
  Item: TCnGroupReplacement;
begin
  if not IsUpdating and (ListView.Selected <> nil) then
  begin
    IsUpdating := True;
    try
      Item := List.Items[ListView.Selected.Index];
      Item.Caption := edtCaption.Text;
      Item.ShortCut := HotKey.HotKey;
      ListView.Selected.Update;
    finally
      IsUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.SetDataToControls;
var
  Item: TCnGroupReplacement;
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
        lvItems.Items.Count := Item.Items.Count;
      end
      else
      begin
        edtCaption.Text := '';
        HotKey.HotKey := 0;
        lvItems.Items.Count := 0;
      end;
    finally
      IsUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.UpdateControls;
begin
  btnUp.Enabled := ListViewSelectedItemsCanUp(ListView);
  btnDown.Enabled := ListViewSelectedItemsCanDown(ListView);
  btnDelete.Enabled := ListView.SelCount > 0;
  edtCaption.Enabled := ListView.Selected <> nil;
  HotKey.Enabled := ListView.Selected <> nil;
  lvItems.Enabled := ListView.Selected <> nil;

  btnItemUp.Enabled := ListViewSelectedItemsCanUp(lvItems);
  btnItemDown.Enabled := ListViewSelectedItemsCanDown(lvItems);
  btnItemAdd.Enabled := ListView.Selected <> nil;
  btnItemDelete.Enabled := lvItems.SelCount > 0;

  edtSource.Enabled := lvItems.Selected <> nil;
  edtDest.Enabled := lvItems.Selected <> nil;
  chkIgnoreCase.Enabled := lvItems.Selected <> nil;
  chkWholeWord.Enabled := lvItems.Selected <> nil;
end;

//------------------------------------------------------------------------------
// 替换项列表处理
//------------------------------------------------------------------------------

procedure TCnSrcEditorGroupReplaceForm.lvItemsData(Sender: TObject;
  Item: TListItem);
const
  SBoolStr: array[Boolean] of string = ('', 'True');
begin
  if ListView.Selected <> nil then
  begin
    with List.Items[ListView.Selected.Index].Items[Item.Index] do
    begin
      Item.Caption := Source;
      Item.SubItems.Clear;
      Item.SubItems.Add(Dest);
      Item.SubItems.Add(SBoolStr[IgnoreCase]);
      Item.SubItems.Add(SBoolStr[WholeWord]);
    end;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.UpdateItemListView;
begin
  if ListView.Selected <> nil then
    lvItems.Items.Count := List.Items[ListView.Selected.Index].Items.Count
  else
    lvItems.Items.Count := 0;
  lvItems.Refresh;
  UpdateControls;
end;

procedure TCnSrcEditorGroupReplaceForm.btnItemAddClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    ListViewSelectItems(lvItems, smNothing);
    List.Items[ListView.Selected.Index].Items.Add;
    UpdateItemListView;
    lvItems.Selected := lvItems.Items[lvItems.Items.Count - 1];
    lvItems.Selected.MakeVisible(True);
    edtSource.SetFocus;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnItemDeleteClick(Sender: TObject);
var
  i: Integer;
begin
  if (ListView.Selected <> nil) and (lvItems.SelCount > 0) and
    QueryDlg(SCnDeleteConfirm) then
  begin
    for i := lvItems.Items.Count - 1 downto 0 do
      if lvItems.Items[i].Selected then
        List.Items[ListView.Selected.Index].Items.Delete(i);
    UpdateItemListView;
    ListViewSelectItems(lvItems, smNothing);
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnItemUpClick(Sender: TObject);
var
  i: Integer;
begin
  if ListView.Selected <> nil then
  begin
    for i := 1 to lvItems.Items.Count - 1 do
      if lvItems.Items[i].Selected and not lvItems.Items[i - 1].Selected then
      begin
        List.Items[ListView.Selected.Index].Items[i].Index := i - 1;
        lvItems.Items[i - 1].Selected := True;
        lvItems.Items[i].Selected := False;
      end;
    lvItems.Update;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.btnItemDownClick(Sender: TObject);
var
  i: Integer;
begin
  if ListView.Selected <> nil then
  begin
    for i := lvItems.Items.Count - 2 downto 0 do
      if lvItems.Items[i].Selected and not lvItems.Items[i + 1].Selected then
      begin
        List.Items[ListView.Selected.Index].Items[i].Index := i + 1;
        lvItems.Items[i + 1].Selected := True;
        lvItems.Items[i].Selected := False;
      end;
    lvItems.Update;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.ItemControlChanged(Sender: TObject);
begin
  UpdateControls;
  GetItemDataFromControls;
end;

procedure TCnSrcEditorGroupReplaceForm.lvItemsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if not IsItemUpdating then
  begin
    SetItemDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.lvItemsKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not IsItemUpdating then
  begin
    SetItemDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.lvItemsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not IsItemUpdating then
  begin
    SetItemDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.GetItemDataFromControls;
var
  Item: TCnReplacement;
begin
  if not IsItemUpdating and (ListView.Selected <> nil) and
    (lvItems.Selected <> nil) then
  begin
    IsItemUpdating := True;
    try
      Item := List.Items[ListView.Selected.Index].Items[lvItems.Selected.Index];
      Item.Source := edtSource.Text;
      Item.Dest := edtDest.Text;
      Item.IgnoreCase := chkIgnoreCase.Checked;
      Item.WholeWord := chkWholeWord.Checked;
      lvItems.Selected.Update;
    finally
      IsItemUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorGroupReplaceForm.SetItemDataToControls;
var
  Item: TCnReplacement;
begin
  if not IsItemUpdating then
  begin
    IsItemUpdating := True;
    try
      if (ListView.Selected <> nil) and (lvItems.Selected <> nil) then
      begin
        Item := List.Items[ListView.Selected.Index].Items[lvItems.Selected.Index];
        edtSource.Text := Item.Source;
        edtDest.Text := Item.Dest;
        chkIgnoreCase.Checked := Item.IgnoreCase;
        chkWholeWord.Checked := Item.WholeWord;
      end
      else
      begin
        edtSource.Text := '';
        edtDest.Text := '';
        chkIgnoreCase.Checked := False;
        chkWholeWord.Checked := False;
      end;
    finally
      IsItemUpdating := False;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
