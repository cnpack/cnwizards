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

unit CnProjectDirBuilderFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程目录创建器单元
* 单元作者：张伟(Alan) BeyondStudio@163.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2005.05.10 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, Menus, StdCtrls, ExtCtrls, ComCtrls, FileCtrl, ToolWin, IniFiles,
  CnCheckTreeView, OmniXML, CnIni, CnCommon, CnConsts, CnWizConsts,
  CnWizMultiLang, CnWizOptions, CnTree, CnTreeXMLFiler, CnPopupMenu;

const
  WM_EditItem = WM_User + 100;

type
  TSelectMode = (smSelectAll, smReverseSelect, smUnselect);
  { 树节点选择模式
    smSelectAll:        全选
    smReverseSelect:    反向选择
    smUnselect:         取消选择
  }

//==============================================================================
// CnDirTree Classes
//==============================================================================

  { TCnDirInfo }

  TCnDirInfo = class
    Comments: string;
    MakeComments: Boolean;
  end;

  { TCnDirLeaf }

  TCnDirLeaf = class(TCnLeaf)
  private
    FComments: string;
    FMakeComments: Boolean;
    FMakeDir: Boolean;
  published
    property Comments: string read FComments write FComments;
    property MakeComments: Boolean read FMakeComments write FMakeComments;
    property MakeDir: Boolean read FMakeDir write FMakeDir;
  end;

  { TCnDirTree }

  TCnDirTree = class(TCnTree)
  protected
    function DoLoadFromATreeNode(ALeaf: TCnLeaf; ANode: TTreeNode): Boolean; override;
    function DoSaveToATreeNode(ALeaf: TCnLeaf; ANode: TTreeNode): Boolean; override;
  end;

//==============================================================================
// 工程目录创建器窗体
//==============================================================================

{ TCnProjectDirBuilderForm }

  TCnProjectDirBuilderForm = class(TCnTranslateForm)
    Splitter: TSplitter;
    CoolBar: TCoolBar;
    ToolBar: TToolBar;
    btnBuildDir: TToolButton;
    btnSplitter1: TToolButton;
    cbbDirList: TComboBox;
    TreeView: TCnCheckTreeView;
    StatusBar: TStatusBar;
    Panel: TPanel;
    PopupMenu: TPopupMenu;
    mnuAdd: TMenuItem;
    mnuAddSub: TMenuItem;
    mnuRename: TMenuItem;
    mnuDelete: TMenuItem;
    mnuLine1: TMenuItem;
    mnuExpand: TMenuItem;
    mnuCollapse: TMenuItem;
    mnuLine2: TMenuItem;
    mnuSelectAll: TMenuItem;
    mnuReverseSelect: TMenuItem;
    mnuUnselect: TMenuItem;
    btnNew: TToolButton;
    btnSave: TToolButton;
    btnFont: TToolButton;
    btnSplitter2: TToolButton;
    pnlTop: TPanel;
    pnlClient: TPanel;
    Memo: TMemo;
    CheckBox: TCheckBox;
    FontDialog: TFontDialog;
    btnDelete: TToolButton;
    btnSplitter3: TToolButton;
    btnHelp: TToolButton;
    btnSplitter4: TToolButton;
    btnClose: TToolButton;
    btnSplitter5: TToolButton;
    btnImport: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);    
    procedure btnBuildDirClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbbDirListChange(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure mnuAddClick(Sender: TObject);
    procedure mnuAddSubClick(Sender: TObject);
    procedure mnuRenameClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuExpandClick(Sender: TObject);
    procedure mnuCollapseClick(Sender: TObject);
    procedure mnuSelectAllClick(Sender: TObject);
    procedure mnuReverseSelectClick(Sender: TObject);
    procedure mnuUnselectClick(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure TreeViewStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBoxClick(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
  private
    FCnDirTree: TCnDirTree;
    FIni: TCustomIniFile;
    FTempletSaved: Boolean;
    FDataFilePath: string;
    FUserFilePath: string;
    FRootDir: string;
    FIgnoreDir, FIgnoreDir1, FIgnoreDir2: string;
    FIgnore: Boolean;
    FGenReadMe: Boolean;
    FDirs: TStrings;
    FOldTemplet: string;

    function AddNode(SelectedNode: TTreeNode; AddSubNode: Boolean = False;
      const AName: string = ''; const AComments: string = '';
      AMakeDir: Boolean = True; AMakeComments: Boolean = False;
      EditNode: Boolean = True): TTreeNode;
    procedure ChangeTreeNodeState(SelectMode: TSelectMode);
    procedure ClearTreeViewAndMemo;
    procedure FreeNodeData(Data: Pointer);
    function GetNodeFullPath(const Tree: TTreeView; Node: TTreeNode): string;
    function GetUniqueName(const BaseName: string;
      GetChildNodeName: Boolean = False): string;
    function GetTempletLeaf(ALeafName: string): TCnDirLeaf;
    function MakeDirectories(const RootDir: string): Boolean;
    procedure SelectNode(Tree: TTreeView; X,Y: Integer);
    procedure UpdateLeaf;
    procedure UpdateStatusBar;
    procedure WMEditItem(var Message: TMessage); message WM_EditItem;
    procedure LoadTreeFromFile;
    procedure SaveTreeToFile;
    function SaveTempletToTree(const ATempletName: string): Boolean;
    procedure ImportDirectory;
    procedure LoadDirsToTreeView(SubDirs: TStrings);
    procedure OnDirFind(const SubDir: string);
  protected
    function GetHelpTopic: string; override;  
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile);
    procedure LoadSettings(Ini: TCustomIniFile; aSection: string);
    procedure SaveSettings(Ini: TCustomIniFile; aSection: string);
  end;

procedure ShowProjectDirBuilder(AIni: TCustomIniFile);

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  CnWizUtils, CnWizIdeUtils, CnProjectDirImportFrm;

var
  CnProjectDirBuilderForm: TCnProjectDirBuilderForm = nil;

procedure ShowProjectDirBuilder(AIni: TCustomIniFile);
begin
  if CnProjectDirBuilderForm = nil then
    CnProjectDirBuilderForm := TCnProjectDirBuilderForm.CreateEx(Application, AIni);

  with CnProjectDirBuilderForm do
  begin
    ShowHint := WizOptions.ShowHint;
    Show;
  end;
end;

//==============================================================================
// CnDirTree Classes
//==============================================================================

{ TCnDirTree }

function TCnDirTree.DoLoadFromATreeNode(ALeaf: TCnLeaf;
  ANode: TTreeNode): Boolean;
begin
  Result := inherited DoLoadFromATreeNode(ALeaf, ANode);
  if Result and Assigned(ANode.Data) then
    with TCnDirLeaf(ALeaf) do
    try
      FComments := TCnDirInfo(ANode.Data).Comments;
      FMakeComments := TCnDirInfo(ANode.Data).MakeComments;
      FMakeDir := TCnCheckTreeView(ANode.TreeView).CheckBoxState[ANode] <> cbUnchecked;
      Result := True;
    except
      Result := False;
    end;
end;

function TCnDirTree.DoSaveToATreeNode(ALeaf: TCnLeaf;
  ANode: TTreeNode): Boolean;
var
  CnDirInfo: TCnDirInfo;

  function FormatStr(const AString: string): string;
  begin
    Result := StringReplace(AString, #10, #13#10, [rfReplaceAll]);
  end;

begin
  Result := inherited DoSaveToATreeNode(ALeaf, ANode);
  if Result then
    with TCnDirLeaf(ALeaf) do
    try
      CnDirInfo := TCnDirInfo.Create;
      with CnDirInfo do
      begin
        Comments := FormatStr(FComments);
        MakeComments := FMakeComments;
      end;

      with ANode do
      begin
        Data := Pointer(CnDirInfo);
        if CnDirInfo.MakeComments then
        begin
          ImageIndex := 24;
          SelectedIndex := 25;
        end
        else
        begin
          ImageIndex := 84;
          SelectedIndex := 85;
        end;
      end;

      TCnCheckTreeView(ANode.TreeView).Checked[ANode] := FMakeDir;
      Result := True;
    except
      Result := False;
    end;
end;

//==============================================================================
// 工程目录创建器窗体
//==============================================================================

{ TCnProjectDirBuilderForm }

const
  csDirBuilder = 'DirBuilder';
  csDefaultDirName = 'NewDir';
  csReadmeFileName = 'Readme.txt';
  csTempletFileName = 'DirTemplet.xml';
  csFont = 'Font';

constructor TCnProjectDirBuilderForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile);
begin
  Create(AOwner);
  FIni := AIni;
  LoadSettings(FIni, csDirBuilder);
end;

procedure TCnProjectDirBuilderForm.LoadSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  FontDialog.Font := TCnIniFile(FIni).ReadFont(aSection, csFont, Memo.Font);
end;

procedure TCnProjectDirBuilderForm.SaveSettings(Ini: TCustomIniFile;
  aSection: string);
begin
  TCnIniFile(FIni).WriteFont(aSection, csFont, FontDialog.Font);
end;

function TCnProjectDirBuilderForm.AddNode(SelectedNode: TTreeNode;
  AddSubNode: Boolean; const AName: string; const AComments: string;
  AMakeDir, AMakeComments, EditNode: Boolean): TTreeNode;
var
  Node: TTreeNode;
  DirInfo: TCnDirInfo;
  DirName: string;
begin
  DirInfo := TCnDirInfo.Create;
  with DirInfo do
  begin
    Comments := AComments;
    MakeComments := AMakeComments;
  end;

  if AName <> '' then
    DirName := AName
  else
    DirName := GetUniqueName(csDefaultDirName, AddSubNode);

  with TreeView.Items do
  begin
    if AddSubNode then
      Node := AddChildObject(SelectedNode, DirName, Pointer(DirInfo))
    else
      Node := AddObject(SelectedNode, DirName, Pointer(DirInfo));
  end;

  if Assigned(Node) then
  begin
    with Node do
    begin
      if AMakeComments then
      begin
        ImageIndex := 24;
        SelectedIndex := 25;
      end
      else
      begin
        ImageIndex := 84;
        SelectedIndex := 85;
      end;

      Self.TreeView.Checked[Node] := True;
      Selected := True;
      if EditNode then
        EditText;
    end;
  end;

  FTempletSaved := False;
  Result := Node;
end;

procedure TCnProjectDirBuilderForm.ChangeTreeNodeState(SelectMode: TSelectMode);
begin
  case SelectMode of
    smSelectAll: TreeView.SelectAll;
    smReverseSelect: TreeView.SelectInvert;
    smUnselect: TreeView.SelectNone;
  end;
  FTempletSaved := False;
end;

procedure TCnProjectDirBuilderForm.ClearTreeViewAndMemo;
var
  Node: TTreeNode;
begin
  TreeView.BeginUpdate;
  try
    Node := TreeView.Items.GetFirstNode;
    while Node <> nil do
    begin
      FreeNodeData(Node.Data);
      Node.Data := nil;
      Node := Node.GetNext;
    end;
    TreeView.Items.Clear;
  finally
    TreeView.EndUpdate;
  end;

  UpdateStatusBar;
  CheckBox.Checked := False;
  Memo.Clear;
  FTempletSaved := True;
end;

procedure TCnProjectDirBuilderForm.FreeNodeData(Data: Pointer);
var
  DirInfo: TCnDirInfo;
begin
  if Assigned(Data) then
  begin
    DirInfo := TCnDirInfo(Data);
    DirInfo.Free;
  end;
end;

function TCnProjectDirBuilderForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtDirBuilder';
end;

function TCnProjectDirBuilderForm.GetNodeFullPath(const Tree: TTreeView;
  Node: TTreeNode): string;
begin
  Result := '';

  if (Tree = nil) or (Node = nil) or (Node.TreeView <> Tree) or
    (Tree.Items.Count <= 0)  then
    Exit;

  if Node.Level = 0 then
    Result := '\' + Node.Text
  else
  begin
    while Assigned(Node.Parent) do
    begin
      Result := '\' + Node.Text + Result;
      Node := Node.Parent;
    end;
    Result := '\' + Node.Text + Result;
  end;
end;

function TCnProjectDirBuilderForm.GetUniqueName(const BaseName: string;
  GetChildNodeName: Boolean): string;
var
  I, Index, Level: Integer;
  Node: TTreeNode;
label
  Start;
begin
  Result := EmptyStr;
  Index := 0;
  Level := 0;

  if Assigned(TreeView.Selected) then
    if GetChildNodeName then
      Level := TreeView.Selected.Level + 1
    else
      Level := TreeView.Selected.Level;

Start:
  for I := 0 to TreeView.Items.Count - 1 do
  begin
    Node := TreeView.Items[I];

    if GetChildNodeName then
    begin
      if (Node.Level = Level) and
        (Node.HasAsParent(TreeView.Selected)) then
        if UpperCase(Node.Text) = UpperCase(BaseName + IntToStr(Index)) then
        begin
          Inc(Index);
          goto Start;
        end;
    end
    else
    begin
      if (Node.Level = Level) and
        (Node.HasAsParent(TreeView.Selected.Parent)) then
        if UpperCase(Node.Text) = UpperCase(BaseName + IntToStr(Index)) then
        begin
          Inc(Index);
          goto Start;
        end;
    end;
  end;

  Result := BaseName + IntToStr(Index);
end;

function TCnProjectDirBuilderForm.GetTempletLeaf(
  ALeafName: string): TCnDirLeaf;
begin
  Result := TCnDirLeaf(FCnDirTree.Root.GetFirstChild);
  while Result <> nil do
  begin
    if Result.Text = ALeafName then
      Exit;

    Result := TCnDirLeaf(Result.GetNextSibling);
  end;

  Result := nil;
end;

function TCnProjectDirBuilderForm.MakeDirectories(const RootDir: string): Boolean;
var
  Node: TTreeNode;
  Path: string;
begin
  Result := True;

  Node := TreeView.Items.GetFirstNode;
  while Node <> nil do
  begin
    if TreeView.CheckBoxState[Node] <> cbUnchecked then
    begin
      Path := RootDir + GetNodeFullPath(TreeView, Node);
      Result := Result and ForceDirectories(Path);

      if TCnDirInfo(Node.Data).MakeComments then
        with TStringList.Create do
        try
          Text := TCnDirInfo(Node.Data).Comments;
          SaveToFile(Path + '\' + csReadmeFileName);
        finally
          Free;
        end;
    end;
    Node := Node.GetNext;
  end;
end;

procedure TCnProjectDirBuilderForm.SelectNode(Tree: TTreeView; X, Y: Integer);
var
  Node: TTreeNode;
begin
  Node := Tree.GetNodeAt(X, Y);
  if Assigned(Node) then
    Node.Selected := True;
end;

procedure TCnProjectDirBuilderForm.UpdateStatusBar;
begin
  StatusBar.Panels[0].Text := GetNodeFullPath(TreeView, TreeView.Selected);
end;

procedure TCnProjectDirBuilderForm.WMEditItem(var Message: TMessage);
begin
  with TTreeNode(Message.WParam) do
    EditText;
end;

procedure TCnProjectDirBuilderForm.LoadTreeFromFile;
var
  Filer: ICnTreeFiler;
  XMLDoc: IXMLDocument;
  Leaf: TCnDirLeaf;
  Path: string;
begin
  Path := FUserFilePath;
  ClearTreeViewAndMemo;
  Filer := TCnTreeXMLFiler.Create;
  
  with FCnDirTree do
  begin
    Clear;

    if FileExists(FUserFilePath) then
      LoadFromFile(Filer, FUserFilePath)
    else
    if FileExists(FDataFilePath) then
      LoadFromFile(Filer, FDataFilePath)
    else
    begin
      XMLDoc := CreateXMLDoc;
      XMLDoc.Save(FDataFilePath);
      XMLDoc := nil;
      LoadFromFile(Filer, FDataFilePath)
    end;
  end;

  cbbDirList.Clear;

  Leaf := TCnDirLeaf(FCnDirTree.Root.GetFirstChild);
  while Leaf <> nil do
  begin
    cbbDirList.Items.Add(Leaf.Text);
    Leaf := TCnDirLeaf(Leaf.GetNextSibling);
  end;

  if cbbDirList.Items.Count > 0 then
  begin
    cbbDirList.ItemIndex := 0;
    if Assigned(cbbDirList.OnChange) then
      cbbDirList.OnChange(cbbDirList);
    FOldTemplet := cbbDirList.Text;
  end;

  FTempletSaved := True;
end;

procedure TCnProjectDirBuilderForm.SaveTreeToFile;
var
  Filer: ICnTreeFiler;
begin
  Filer := TCnTreeXMLFiler.Create;
  FCnDirTree.SaveToFile(Filer, FUserFilePath);
  FTempletSaved := True;
end;

function TCnProjectDirBuilderForm.SaveTempletToTree(const ATempletName: string): Boolean;
var
  Leaf: TCnDirLeaf;
  TempletName: string;
  NeedInput, NeedConfirm: Boolean;
begin
  Result := False;
  NeedInput := False;
  NeedConfirm := False;

  UpdateLeaf;
  if ATempletName <> '' then // 无输入名称则需要输入
    TempletName := ATempletName
  else
  begin
    NeedInput := True;
    NeedConfirm := True;     // 覆盖的话也需要确认
  end;

  if NeedInput and not CnWizInputQuery(SCnProjExtSaveTempletCaption, SCnProjExtInputTempletName,
    TempletName) then
    Exit;

  if TempletName = '' then
    Exit;
  Leaf := GetTempletLeaf(TempletName);

  if Assigned(Leaf) then
  begin
    if NeedConfirm and (cbbDirList.Items.IndexOf(TempletName) >= 0) and
      QueryDlg(Format(SCnProjExtConfirmOverrideTemplet, [TempletName]), True) then
    begin
      Leaf.Clear;
      Leaf.Text := TempletName;
    end;
  end
  else
  begin
    Leaf := TCnDirLeaf.Create(FCnDirTree);
    Leaf.Text := TempletName;
    FCnDirTree.Root.AddChild(Leaf);

    with cbbDirList do
    begin
      if Items.IndexOf(TempletName) < 0 then
        Items.Add(TempletName);
      ItemIndex := Items.IndexOf(TempletName);
    end;
  end;
  FCnDirTree.LoadFromTreeView(TreeView, nil, Leaf);

  SaveTreeToFile;
  FTempletSaved := True;
  Result := True;
end;

procedure TCnProjectDirBuilderForm.FormCreate(Sender: TObject);
begin
  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
  IdeScaleToolbarComboFontSize(cbbDirList);
  FDataFilePath := MakePath(WizOptions.DataPath) + csTempletFileName;
  FUserFilePath := MakePath(WizOptions.UserPath) + csTempletFileName;
  FCnDirTree := TCnDirTree.Create(TCnDirLeaf);
end;

procedure TCnProjectDirBuilderForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (not FTempletSaved) and (TreeView.Items.Count > 0) then
    case Application.MessageBox(PChar(SCnProjExtConfirmSaveTemplet),
      PChar(SCnInformation), MB_ICONQUESTION + MB_YESNOCANCEL) of
      ID_YES:
        if not SaveTempletToTree(cbbDirList.Text) then
        begin
          Action := caNone;
          Exit;
        end;
      ID_CANCEL:
        begin
          Action := caNone;
          Exit;
        end;
    end;

  ClearTreeViewAndMemo;
  FCnDirTree.Free;
  SaveSettings(FIni, csDirBuilder);
  FIni.Free;
  Action := caFree;
  CnProjectDirBuilderForm := nil;
end;

procedure TCnProjectDirBuilderForm.FormShow(Sender: TObject);
begin
  LoadTreeFromFile;
end;

procedure TCnProjectDirBuilderForm.btnBuildDirClick(Sender: TObject);
var
  SelectedDir: string;
begin
  UpdateLeaf;
  if not GetDirectory(SCnProjExtSelectDir, SelectedDir) then
    Exit;
  
  if MakeDirectories(SelectedDir) then
    InfoDlg(SCnProjExtDirCreateSucc)
  else
    ErrorDlg(SCnProjExtDirCreateFail);
end;

procedure TCnProjectDirBuilderForm.btnNewClick(Sender: TObject);
var
  CbbChange: TNotifyEvent;
begin
  UpdateLeaf;
  if (not FTempletSaved) and (TreeView.Items.Count > 0) then
    case Application.MessageBox(PChar(SCnProjExtConfirmSaveTemplet),
      PChar(SCnInformation), MB_ICONQUESTION + MB_YESNOCANCEL) of
      ID_YES:
        if not SaveTempletToTree(cbbDirList.Text) then
          Exit;
      ID_CANCEL: Exit;
    end;

  ClearTreeViewAndMemo;
  CbbChange := cbbDirList.OnChange;
  cbbDirList.OnChange := nil;
  cbbDirList.ItemIndex := -1;
  cbbDirList.OnChange := CbbChange;
  FTempletSaved := True;
end;

procedure TCnProjectDirBuilderForm.btnDeleteClick(Sender: TObject);
var
  Leaf: TCnDirLeaf;
begin
  if cbbDirList.Text = EmptyStr then
    Exit;

  Leaf := GetTempletLeaf(cbbDirList.Text);
  if Assigned(Leaf) then
    if QueryDlg(Format(SCnProjExtConfirmDeleteTemplet, [Leaf.Text]), True) then
    begin
      Leaf.Delete;
      SaveTreeToFile;
      LoadTreeFromFile;
    end;
end;

procedure TCnProjectDirBuilderForm.btnSaveClick(Sender: TObject);
begin
  SaveTempletToTree(cbbDirList.Text);
end;

procedure TCnProjectDirBuilderForm.btnFontClick(Sender: TObject);
begin
  with FontDialog do
  begin
    Font := Memo.Font;

    if Execute then
      Memo.Font := Font;
  end;
end;

procedure TCnProjectDirBuilderForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnProjectDirBuilderForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCnProjectDirBuilderForm.cbbDirListChange(Sender: TObject);
var
  CnDirLeaf: TCnDirLeaf;         
begin
  if (not FTempletSaved) and (TreeView.Items.Count > 0) then
    case Application.MessageBox(PChar(SCnProjExtConfirmSaveTemplet),
      PChar(SCnInformation), MB_ICONQUESTION + MB_YESNOCANCEL) of
      ID_YES:
        if not SaveTempletToTree(FOldTemplet) then
          Exit;
      ID_CANCEL: Exit;
    end;

  FOldTemplet := cbbDirList.Text;
  ClearTreeViewAndMemo;

  CnDirLeaf := TCnDirLeaf(FCnDirTree.Root.GetFirstChild);
  while CnDirLeaf <> nil do
  begin
    if CnDirLeaf.Text = cbbDirList.Text then
    begin
      TreeView.BeginUpdate;
      try
        FCnDirTree.SaveToTreeView(TreeView, nil, CnDirLeaf);
      finally
        TreeView.EndUpdate;
      end;                      
      Break;
    end;

    CnDirLeaf := TCnDirLeaf(CnDirLeaf.GetNextSibling);
  end;
  
  if Visible then
  begin
    if TreeView.Items.Count > 0 then
      TreeView.Selected := TreeView.Items.GetFirstNode;
    TreeView.SetFocus;
  end;
  
  FTempletSaved := True;
end;

procedure TCnProjectDirBuilderForm.PopupMenuPopup(Sender: TObject);

  procedure EnabledAllMenuItem(AMenu: TMenu; Value: Boolean = True);
  var
    I: Integer;
  begin
    if Assigned(AMenu) then
      for I := 0 to AMenu.Items.Count - 1 do
        AMenu.Items[I].Enabled := Value;
  end;

begin
  EnabledAllMenuItem(PopupMenu, False);

  with TreeView.Items do
  begin
    mnuAdd.Enabled := True;
    mnuAddSub.Enabled := Count > 0;
    mnuRename.Enabled := Assigned(TreeView.Selected);
    mnuDelete.Enabled := Assigned(TreeView.Selected);
    mnuExpand.Enabled := Count > 1;
    mnuCollapse.Enabled := Count > 1;
    mnuSelectAll.Enabled := Count > 0;
    mnuReverseSelect.Enabled := Count > 0;
    mnuUnSelect.Enabled := Count > 0;
  end;
end;

procedure TCnProjectDirBuilderForm.mnuAddClick(Sender: TObject);
begin
  AddNode(TreeView.Selected, False);
end;

procedure TCnProjectDirBuilderForm.mnuAddSubClick(Sender: TObject);
begin
  AddNode(TreeView.Selected, True);
end;

procedure TCnProjectDirBuilderForm.mnuRenameClick(Sender: TObject);
begin
  TreeView.Selected.EditText;
end;

procedure TCnProjectDirBuilderForm.mnuDeleteClick(Sender: TObject);

  procedure DeleteSelectedNode(ANode: TTreeNode);
  var
    I: Integer;
    CurrentNode: TTreeNode;
  begin
    if not Assigned(ANode) then
      Exit;

    I := ANode.AbsoluteIndex + 1;
    while (I <= TreeView.Items.Count - 1) and
      (TreeView.Items[I].Level > ANode.Level) do
    begin
      CurrentNode := TreeView.Items[I];
      FreeNodeData(CurrentNode.Data);
      Inc(I);
    end;
    FreeNodeData(ANode.Data);
    ANode.Delete;
  end;

begin
  if QueryDlg(Format(SCnProjExtConfirmDeleteDir, [TreeView.Selected.Text])) then
  begin
    DeleteSelectedNode(TreeView.Selected);
    FTempletSaved := False;
  end;
end;

procedure TCnProjectDirBuilderForm.mnuExpandClick(Sender: TObject);
begin
  TreeView.FullExpand;
end;

procedure TCnProjectDirBuilderForm.mnuCollapseClick(Sender: TObject);
begin
  TreeView.FullCollapse;
end;

procedure TCnProjectDirBuilderForm.mnuSelectAllClick(Sender: TObject);
begin
  ChangeTreeNodeState(smSelectAll);
end;

procedure TCnProjectDirBuilderForm.mnuReverseSelectClick(Sender: TObject);
begin
  ChangeTreeNodeState(smReverseSelect);
end;

procedure TCnProjectDirBuilderForm.mnuUnselectClick(Sender: TObject);
begin
  ChangeTreeNodeState(smUnselect);
end;

type
  TButtonControlAccess = class(TButtonControl);

procedure TCnProjectDirBuilderForm.TreeViewChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node) and Assigned(Node.Data) then
  begin
    TButtonControlAccess(CheckBox).ClicksDisabled := True;
    CheckBox.Checked := TCnDirInfo(Node.Data).MakeComments;
    TButtonControlAccess(CheckBox).ClicksDisabled := False;
    Memo.Lines.Text := TCnDirInfo(Node.Data).Comments;
  end;
  UpdateStatusBar;
end;

procedure TCnProjectDirBuilderForm.TreeViewChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  UpdateLeaf;
end;

procedure TCnProjectDirBuilderForm.TreeViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Source is TTreeView then
  begin
    TTreeview(Source).Selected.MoveTo(TTreeView(Sender).GetNodeAt(X, Y), naAddChild);
    UpdateStatusBar;
  end;
end;

procedure TCnProjectDirBuilderForm.TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TTreeView;
end;

procedure TCnProjectDirBuilderForm.TreeViewEdited(Sender: TObject;
  Node: TTreeNode; var S: String);

  function IsUniqueName(const AName: string): Boolean;
  var
    Node: TTreeNode;
    I, Level: Integer;
  begin
    Result := True;

    Level := TreeView.Selected.Level;

    for I := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[I];

      if (Node.Level = Level) and (Node <> TreeView.Selected) and
      (Node.HasAsParent(TreeView.Selected.Parent)) then
        if UpperCase(Node.Text) = UpperCase(AName) then
        begin
          Result := False;
          Break;
        end;
    end;
  end;

begin
  if not IsValidFileName(S) then
  begin
    ErrorDlg(SCnProjExtDirNameHasInvalidChar);
    S := Node.Text;
    PostMessage(Handle, WM_EditItem, Integer(Node), 0);
    Exit;
  end;

  if not IsUniqueName(S) then
  begin
    ErrorDlg(SCnProjExtIsNotUniqueDirName);
    S := Node.Text;
    PostMessage(Handle, WM_EditItem, Integer(Node), 0);
    Exit;
  end;

  FTempletSaved := False;
  UpdateStatusBar;
end;

procedure TCnProjectDirBuilderForm.TreeViewStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  DragObject := nil;
end;

procedure TCnProjectDirBuilderForm.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F2 then
    TreeView.Selected.EditText;
end;

procedure TCnProjectDirBuilderForm.TreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    SelectNode(TreeView, X, Y);
end;

procedure TCnProjectDirBuilderForm.CheckBoxClick(Sender: TObject);
begin
  UpdateLeaf;
  FTempletSaved := False;
end;

procedure TCnProjectDirBuilderForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  ARect: TRect;
begin
  ARect := Rect;
  ARect.Right := ARect.Right - 14;
  DrawCompactPath(StatusBar.Canvas.Handle, ARect, StatusBar.Panels[0].Text);
end;

procedure TCnProjectDirBuilderForm.MemoChange(Sender: TObject);
begin
  FTempletSaved := False;
end;

procedure TCnProjectDirBuilderForm.UpdateLeaf;
var
  SelectNode: TTreeNode;
begin
  if Assigned(TreeView.Selected) then
  begin
    SelectNode := TreeView.Selected;
    if Assigned(SelectNode.Data) then
    begin
      TCnDirInfo(SelectNode.Data).MakeComments := CheckBox.Checked;
      TCnDirInfo(SelectNode.Data).Comments := Memo.Lines.Text;
      if TCnDirInfo(SelectNode.Data).MakeComments then
      begin
        SelectNode.ImageIndex := 24;
        SelectNode.SelectedIndex := 25;
      end
      else
      begin
        SelectNode.ImageIndex := 84;
        SelectNode.SelectedIndex := 85;
      end;
    end;
  end;
end;

procedure TCnProjectDirBuilderForm.btnImportClick(Sender: TObject);
begin
  // 此处导入现存的目录结构
  ImportDirectory;
end;

procedure TCnProjectDirBuilderForm.ImportDirectory;
begin
  if SelectImportDir(FRootDir, FIgnore, FIgnoreDir, FGenReadMe) then
  begin
    FIgnoreDir1 := '\' + UpperCase(FIgnoreDir) + '\';
    FIgnoreDir2 := UpperCase(FIgnoreDir) + '\';

    ClearTreeViewAndMemo;
    FDirs := TStringList.Create;
    BeginWait;
    try
      FindFile(FRootDir, '*.*', nil, OnDirFind);
      TreeView.BeginUpdate;
      try
        LoadDirsToTreeView(FDirs);
      finally
        TreeView.EndUpdate;
      end;                      
    finally
      EndWait;
      FDirs.Free;
    end;
  end;
end;

procedure TCnProjectDirBuilderForm.OnDirFind(const SubDir: string);
var
  Dir: string;
begin
  Dir := MakePath(SubDir);
  if not FIgnore or ((UpperCase(SubDir) <> FIgnoreDir) // 避免此目录
    and (Pos(FIgnoreDir2, UpperCase(Dir)) <> 1) // 避免此目录开头
    and (Pos(FIgnoreDir1, UpperCase(Dir)) = 0)) then // 避免包含此目录
    FDirs.Add(SubDir);
end;

procedure TCnProjectDirBuilderForm.LoadDirsToTreeView(SubDirs: TStrings);
var
  I, OldDepth, Depth: Integer;
  DirName: string;
  OldNode, Node: TTreeNode;

  // 获得一 Node 的第 n 层父节点；0 是本身，到顶了则 nil
  function GetNodeByParentLevel(ANode: TTreeNode; Level: Integer): TTreeNode;
  begin
    Result := ANode;
    if Level > 0 then
      while (Result <> nil) and (Level > 0) do
      begin
        Dec(Level);
        Result := Result.Parent;
      end;
  end;

begin
  OldDepth := 0; OldNode := nil;
  for I := 0 to SubDirs.Count - 1 do
  begin
    Depth := CountCharInStr('\', SubDirs[I]); // 0 表示顶层
    if Depth = 0 then
      DirName := SubDirs[I]
    else
      DirName := StrRight(SubDirs[I], Length(SubDirs[I]) -
        CharPosWithCounter('\', SubDirs[I], Depth));

    if Depth <= OldDepth then // 新的比旧的浅，回溯 n 层
      Node := GetNodeByParentLevel(OldNode, OldDepth - Depth + 1)
    else // 新的比旧的深，不管深多少，都是前一个的直属子节点
      Node := OldNode;

    if FGenReadMe then
      OldNode := AddNode(Node, True, DirName, DirName, True, True, False)
    else
      OldNode := AddNode(Node, True, DirName, '', True, False, False);
    OldDepth := Depth;
  end;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
