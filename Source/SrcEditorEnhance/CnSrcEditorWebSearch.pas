{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnSrcEditorWebSearch;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器扩展其它工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2005.06.14
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, StdCtrls, ComCtrls, Menus, ToolsAPI,
  CnClasses, OmniXML, OmniXMLPersistent, CnCommon, CnWizUtils, CnWizConsts,
  CnWizShortCut, CnWizOptions, CnInetUtils;

type

{ TCnWebSearchItem }

  TCnWebSearchItem = class(TCnAssignableCollectionItem)
  private
    FCaption: string;
    FShortCut: TShortCut;
    FUrl: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Caption: string read FCaption write FCaption;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property Url: string read FUrl write FUrl;
  end;

{ TCnWebSearchCollection }

  TCnWebSearchCollection = class(TCollection)
  private
    function GetItems(Index: Integer): TCnWebSearchItem;
    procedure SetItems(Index: Integer; const Value: TCnWebSearchItem);
  public
    constructor Create; 
    destructor Destroy; override;
    function LoadFromFile(const FileName: string; Append: Boolean): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function Add: TCnWebSearchItem;
    property Items[Index: Integer]: TCnWebSearchItem read GetItems write SetItems; default;
  end;

{ TCnSrcEditorSearchForm }

  TCnSrcEditorWebSearchForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lbl1: TLabel;
    edtCaption: TEdit;
    lbl2: TLabel;
    HotKey: THotKey;
    lbl3: TLabel;
    edtUrl: TEdit;
    btnImport: TButton;
    btnExport: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure ListViewData(Sender: TObject; Item: TListItem);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure ControlChanged(Sender: TObject);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    List: TCnWebSearchCollection;
    IsUpdating: Boolean;
    procedure UpdateControls;
    procedure UpdateListView;
    procedure SetDataToControls;
    procedure GetDataFromControls;
  public
    function GetHelpTopic: string; override;
  end;

{ TCnSrcEditorWebSearchTool }

  TCnSrcEditorWebSearchTool = class
  private
    FItems: TCnWebSearchCollection;
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
    procedure LanguageChanged(Sender: TObject);
    procedure Execute(Item: TCnWebSearchItem);
    procedure InitMenuItems(AMenu: TMenuItem);
    property Items: TCnWebSearchCollection read FItems;
  end;

implementation

{$R *.DFM}

const
  csBlockStr = '%s';  // Do not localize
  csMaxKeywordLen = 128;

{ TCnWebSearchItem }

constructor TCnWebSearchItem.Create(Collection: TCollection);
begin
  inherited;
end;

destructor TCnWebSearchItem.Destroy;
begin
  inherited;
end;

{ TCnWebSearchCollection }

function TCnWebSearchCollection.Add: TCnWebSearchItem;
begin
  Result := TCnWebSearchItem(inherited Add);
end;

constructor TCnWebSearchCollection.Create;
begin
  inherited Create(TCnWebSearchItem);
end;

destructor TCnWebSearchCollection.Destroy;
begin
  inherited;
end;

function TCnWebSearchCollection.GetItems(Index: Integer): TCnWebSearchItem;
begin
  Result := TCnWebSearchItem(inherited Items[Index]);
end;

function TCnWebSearchCollection.LoadFromFile(const FileName: string; Append:
  Boolean): Boolean;
var
  Col: TCnWebSearchCollection;
  i: Integer;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  try
    if not Append then
      Clear;
      
    Col := TCnWebSearchCollection.Create;
    try
      TOmniXMLReader.LoadFromFile(Col, FileName);
      for i := 0 to Col.Count - 1 do
        Add.Assign(Col.Items[I]);
      Result := True;
    finally
      Col.Free;
    end;
  except
    ;
  end;
end;

function TCnWebSearchCollection.SaveToFile(const FileName: string): Boolean;
begin
  Result := False;
  try
    TOmniXMLWriter.SaveToFile(Self, FileName, pfAuto, ofIndent);
    Result := True;
  except
    ;
  end;   
end;

procedure TCnWebSearchCollection.SetItems(Index: Integer;
  const Value: TCnWebSearchItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnSrcEditorWebSearchTool }

procedure TCnSrcEditorWebSearchTool.Clear;
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

function TCnSrcEditorWebSearchTool.Config: Boolean;
begin
  with TCnSrcEditorWebSearchForm.Create(Application) do
  try
    List.Assign(FItems);
    Result := ShowModal = mrOk;
    if Result then
    begin
      FItems.Assign(List);
      FItems.SaveToFile(WizOptions.GetUserFileName(SCnWebSearchFile, False));
      WizOptions.CheckUserFile(SCnWebSearchFile, SCnWebSearchFileDef);
      if FMenu <> nil then
        InitMenuItems(FMenu);
    end;
  finally
    Free;
  end;
end;

constructor TCnSrcEditorWebSearchTool.Create;
begin
  inherited;
  FItems := TCnWebSearchCollection.Create;
  FItems.LoadFromFile(WizOptions.GetUserFileName(SCnWebSearchFile, True,
    SCnWebSearchFileDef), False);
  FShortCuts := TList.Create;
end;

destructor TCnSrcEditorWebSearchTool.Destroy;
begin
  Clear;
  FShortCuts.Free;
  FItems.Free;
  inherited;
end;

procedure TCnSrcEditorWebSearchTool.Execute(Item: TCnWebSearchItem);
var
  EditView: iotaeditview;
  Keyword, Token: string;
  Url: string;
  Idx: Integer;
begin
  EditView := CnOtaGetTopMostEditView;
  Keyword := '';
  if Assigned(EditView) then
  begin
    if EditView.Block.IsValid and (EditView.Block.Style <> btColumn) then
    begin
      Keyword := Trim(EditView.Block.Text);
      if Pos(#13, Keyword) > 0 then
        Delete(Keyword, Pos(#13, Keyword), MaxInt);
    end
    else
      if CnOtaGetCurrPosToken(Token, Idx, True) then
        Keyword := Token;

    if Length(Keyword) > 0 then
    begin
      Delete(Keyword, csMaxKeywordLen, MaxInt);

      Url := Trim(StringReplace(Item.Url, csBlockStr, EncodeURL(Keyword),
        [rfReplaceAll, rfIgnoreCase]));
      RunFile(Url);
    end;
  end;
end;

procedure TCnSrcEditorWebSearchTool.InitMenuItems(AMenu: TMenuItem);
var
  i: Integer;
begin
  WizShortCutMgr.BeginUpdate;
  try
    FMenu := AMenu;
    Clear;

    for i := 0 to Items.Count - 1 do
    begin
      AddMenuItem(AMenu, Items[i].Caption, OnMenuItemClick, nil,
        Items[i].ShortCut, '', i);

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

procedure TCnSrcEditorWebSearchTool.LanguageChanged(Sender: TObject);
begin
  FItems.LoadFromFile(WizOptions.GetUserFileName(SCnWebSearchFile, True,
    SCnWebSearchFileDef), False);
  if FMenu <> nil then
    InitMenuItems(FMenu);
end;

procedure TCnSrcEditorWebSearchTool.OnConfig(Sender: TObject);
begin
  Config;
end;

procedure TCnSrcEditorWebSearchTool.OnMenuItemClick(Sender: TObject);
var
  Item: TCnWebSearchItem;
begin
  if Sender is TMenuItem then
  begin
    Item := Items[TMenuItem(Sender).Tag];
    if Item <> nil then
      Execute(Item);
  end;
end;

procedure TCnSrcEditorWebSearchTool.OnShortCut(Sender: TObject);
var
  Item: TCnWebSearchItem;
begin
  if Sender is TCnWizShortCut then
  begin
    Item := Items[TCnWizShortCut(Sender).Tag];
    if Item <> nil then
      Execute(Item);
  end;
end;

{ TCnSrcEditorSearchForm }

procedure TCnSrcEditorWebSearchForm.FormCreate(Sender: TObject);
begin
  inherited;
  List := TCnWebSearchCollection.Create;
  EnlargeListViewColumns(ListView);
end;

procedure TCnSrcEditorWebSearchForm.FormShow(Sender: TObject);
begin
  inherited;
  UpdateListView;
end;

procedure TCnSrcEditorWebSearchForm.FormDestroy(Sender: TObject);
begin
  List.Free;
  inherited;
end;

procedure TCnSrcEditorWebSearchForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcEditorWebSearchForm.GetHelpTopic: string;
begin
  Result := 'CnSrcEditorWebSearch';
end;

procedure TCnSrcEditorWebSearchForm.UpdateControls;
begin
  btnUp.Enabled := ListViewSelectedItemsCanUp(ListView);
  btnDown.Enabled := ListViewSelectedItemsCanDown(ListView);
  btnDelete.Enabled := ListView.SelCount > 0;
  edtCaption.Enabled := ListView.Selected <> nil;
  HotKey.Enabled := ListView.Selected <> nil;
  edtUrl.Enabled := ListView.Selected <> nil;
end;

procedure TCnSrcEditorWebSearchForm.UpdateListView;
begin
  ListView.Items.Count := List.Count;
  ListView.Refresh;
  UpdateControls;
end;

procedure TCnSrcEditorWebSearchForm.ListViewData(Sender: TObject;
  Item: TListItem);
begin
  Item.Caption := List.Items[Item.Index].Caption;
  Item.SubItems.Clear;
  Item.SubItems.Add(ShortCutToText(List.Items[Item.Index].ShortCut));
  Item.SubItems.Add(List.Items[Item.Index].Url);
end;

procedure TCnSrcEditorWebSearchForm.btnAddClick(Sender: TObject);
begin
  ListViewSelectItems(ListView, smNothing);
  List.Add;
  UpdateListView;
  ListView.Selected := ListView.Items[ListView.Items.Count - 1];
  ListView.Selected.MakeVisible(True);
  edtCaption.SetFocus;
end;

procedure TCnSrcEditorWebSearchForm.btnDeleteClick(Sender: TObject);
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

procedure TCnSrcEditorWebSearchForm.btnUpClick(Sender: TObject);
var
  i: Integer;
begin
  IsUpdating := True;
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
  end;
end;

procedure TCnSrcEditorWebSearchForm.btnDownClick(Sender: TObject);
var
  i: Integer;
begin
  IsUpdating := True;
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
  end;
end;

procedure TCnSrcEditorWebSearchForm.btnImportClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    List.LoadFromFile(dlgOpen.FileName, QueryDlg(SCnImportAppend));
    UpdateListView;
  end;
end;

procedure TCnSrcEditorWebSearchForm.btnExportClick(Sender: TObject);
begin
  if dlgSave.Execute then
    List.SaveToFile(dlgSave.FileName);
end;

procedure TCnSrcEditorWebSearchForm.ControlChanged(Sender: TObject);
begin
  UpdateControls;
  GetDataFromControls;
end;

procedure TCnSrcEditorWebSearchForm.ListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorWebSearchForm.ListViewKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorWebSearchForm.ListViewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not IsUpdating then
  begin
    SetDataToControls;
    UpdateControls;
  end;
end;

procedure TCnSrcEditorWebSearchForm.GetDataFromControls;
var
  Item: TCnWebSearchItem;
begin
  if not IsUpdating and (ListView.Selected <> nil) then
  begin
    IsUpdating := True;
    try
      Item := List.Items[ListView.Selected.Index];
      Item.Caption := edtCaption.Text;
      Item.ShortCut := HotKey.HotKey;
      Item.Url := edtUrl.Text;
      ListView.Selected.Update;
    finally
      IsUpdating := False;
    end;
  end;
end;

procedure TCnSrcEditorWebSearchForm.SetDataToControls;
var
  Item: TCnWebSearchItem;
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
        edtUrl.Text := Item.Url;
      end
      else
      begin
        edtCaption.Text := '';
        HotKey.HotKey := 0;
        edtUrl.Text := '';
      end;
    finally
      IsUpdating := False;
    end;
  end;
end;

end.
