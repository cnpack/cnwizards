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

unit CnDirListFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：目录文件列表单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2008.02.27 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DELPHI7_UP}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Menus, CnCommon, CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnDirListForm = class(TForm)
    Panel1: TPanel;
    edtDir: TEdit;
    Label1: TLabel;
    btnDir: TSpeedButton;
    chbSubDir: TCheckBox;
    chbRelative: TCheckBox;
    chbGroup: TCheckBox;
    GridPanel1: TPanel;
    tvResult: TTreeView;
    mmoResult: TMemo;
    Panel3: TPanel;
    btnSaveTXT: TButton;
    btnList: TButton;
    SDText: TSaveDialog;
    btnAbortSearch: TButton;
    pmTV: TPopupMenu;
    ExpandAll1: TMenuItem;
    CollaspeAll1: TMenuItem;
    chbPrefix: TCheckBox;
    N1: TMenuItem;
    miDeleteSelected: TMenuItem;
    N2: TMenuItem;
    miDelByMasks: TMenuItem;
    chbAutoSync: TCheckBox;
    btnSynchronize: TButton;
    chbSyncDirs: TCheckBox;
    chbSyncFiles: TCheckBox;
    tmPerformUpdateText: TTimer;
    edtMasks: TEdit;
    Label3: TLabel;
    chbCaseSensitive: TCheckBox;
    N3: TMenuItem;
    Deleteemptydirectoriesfromtree1: TMenuItem;
    pmMasks: TPopupMenu;
    N4: TMenuItem;
    miSaveTree: TMenuItem;
    miLoadTree: TMenuItem;
    ODTree: TOpenDialog;
    SDTree: TSaveDialog;
    Splitter1: TSplitter;
    procedure miLoadTreeClick(Sender: TObject);
    procedure miSaveTreeClick(Sender: TObject);
    procedure edtMasksContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Deleteemptydirectoriesfromtree1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmPerformUpdateTextTimer(Sender: TObject);
    procedure tvResultKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chbAutoSyncClick(Sender: TObject);
    procedure btnSynchronizeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miDelByMasksClick(Sender: TObject);
    procedure miDeleteSelectedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pmTVPopup(Sender: TObject);
    procedure CollaspeAll1Click(Sender: TObject);
    procedure ExpandAll1Click(Sender: TObject);
    procedure btnAbortSearchClick(Sender: TObject);
    procedure tvResultDeletion(Sender: TObject; Node: TTreeNode);
    procedure chbSubDirClick(Sender: TObject);
    procedure btnListClick(Sender: TObject);
    procedure edtDirKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnDirClick(Sender: TObject);
    procedure btnSaveTXTClick(Sender: TObject);
    procedure edtDirChange(Sender: TObject);
  private
    { Private declarations }
    FSearching: Boolean;
    FSyncing: Boolean;
    FSearchAbort: Boolean;
    FSearchRoot: string;
    FSearchMasks: TStrings;
    FUIUpdating: Boolean;
    CachedNode: TTreeNode;
    CachedMasks: string;
    CachedCaseSensitive: Boolean;
    CachedDelDirs: Boolean;
    CachedDelFiles: Boolean;

    function GetNextLevelPath(const s, Relative: string): string;
    function GetNodeText(s: string; IsDir: Boolean): string;
    function GetFileMasks: string;
    function GetFileCaseSensitive: Boolean;
    function FindNodeByName(const s: string): TTreeNode;
    function FindParentNodeByName(const s: string): TTreeNode;
    function IncludeSubDirectoies: Boolean;
    function NodeToText(Node: TTreeNode): string;
    function TargetPath: string;
    function Quiting: Boolean;
    function NodeParentIs(Node, Parent: TTreeNode): Boolean;
    function UpdateTextPerformed: Boolean;

    procedure UpdateControlsState;
    procedure SaveAsTXT(const s: string);
    procedure SaveAsCSV(const s: string);
    procedure BuildTree;
    procedure TreeToText;
    procedure UpdateText;
    procedure Searching(const b: Boolean);
    procedure Syncing(const b: Boolean);
    procedure UpdateTreeView;
    procedure PerformUpdateText;
    procedure SetMasksPopupMenu;
    procedure MenuItemClick(Sender: TObject);
    procedure DeleteSelection(tv: TTreeView);
    procedure BeforeSaveTree;
    procedure AfterSaveTree;
    procedure AfterLoadTree;
    procedure SetSearchRoot(const s: string);
  public
    { Public declarations }
  end;

var
  CnDirListForm: TCnDirListForm;

implementation

{$R *.dfm}

uses
  FileCtrl, CommCtrl,
  CnBaseUtils, CnSelectMaskFrm, CnTextPreviewFrm, CnMainUnit;

const
  CQuotedChar = '"';
  CRLF = #13#10;

type
  PSearchResultInfo = ^TSearchResultInfo;
  TSearchResultInfo = record
    IsDir: Boolean;
    Name: string;
  end;

function NewSearchResultInfo(const bIsDir: Boolean; const sName: string): PSearchResultInfo;
begin
  New(Result);
  Result.IsDir := bIsDir;
  Result.Name := sName;
end;

procedure DisposeSearchResultInfo(PSRI: PSearchResultInfo);
begin
  Dispose(PSRI);
end;

function SearchResultInfoToString(Value: PSearchResultInfo): string;
begin
  if Value.IsDir then
  begin
    Result := MakePath(Value.Name);
  end
  else
  begin
    Result := MakeDir(Value.Name);
  end;
end;

function StringToSearchResultInfo(Value: string): PSearchResultInfo;
begin
  Result := NewSearchResultInfo(IsDelimiter(Value, '\', Length(Value)), Value);
end;

function GetParentPath(const s: string): string;
var
  i: Integer;
begin
  i := LastCharPos(MakeDir(s), '\');
  Result := Copy(s, 1, i);
end;

procedure OnFindDir(obj: TObject; const SubDir: string);
var
  _SubDir: string;
begin
  Assert(obj is TCnDirListForm);
  with TCnDirListForm(obj) do
  begin
    _SubDir := MakePath(FSearchRoot + SubDir);
    tvResult.Items.AddChildObject(FindParentNodeByName(_SubDir),
      GetNodeText(_SubDir, True),
      NewSearchResultInfo(True, _SubDir));
  end;
end;

procedure OnFindFile(obj: TObject; const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  Assert(obj is TCnDirListForm);

  with TCnDirListForm(obj) do
  begin
    Abort := FSearchAbort;

    if not Abort then
    begin
      if not FileMatchesMasks(FileName, FSearchMasks, GetFileCaseSensitive) then
      begin
        Exit;
      end;
      
      tvResult.Items.AddChildObject(FindParentNodeByName(FileName),
        GetNodeText(FileName, False),
        NewSearchResultInfo(False, FileName));
    end;
  end;
end;

procedure OnProcessMsg(obj: TObject);
begin
  Assert(obj is TCnDirListForm);
  with TCnDirListForm(obj) do
  begin
    FSearchAbort := Quiting or FSearchAbort;
  end;
end;

procedure TCnDirListForm.AfterLoadTree;
var
  i: Integer;
begin
  for i := 1 to tvResult.Items.Count - 1 do
  begin
    tvResult.Items.Item[i].Data := StringToSearchResultInfo(tvResult.Items.Item[i].Text);
  end;
  if tvResult.Items.Count > 0 then
  begin
    SetSearchRoot(tvResult.Items.GetFirstNode.Text);
    tvResult.Items.GetFirstNode.Delete;
  end;
  UpdateTreeView;
end;

procedure TCnDirListForm.AfterSaveTree;
begin
  if tvResult.Items.Count > 0 then
  begin
    tvResult.Items.GetFirstNode.Delete;
  end;
  UpdateTreeView;
end;

procedure TCnDirListForm.BeforeSaveTree;
var
  i: Integer;
begin
  for i := 0 to tvResult.Items.Count - 1 do
  begin
    tvResult.Items.Item[i].Text := SearchResultInfoToString(tvResult.Items.Item[i].Data);
  end;
  tvResult.Items.AddChildFirst(nil, FSearchRoot);
end;

procedure TCnDirListForm.btnAbortSearchClick(Sender: TObject);
begin
  FSearchAbort := True;
end;

procedure TCnDirListForm.btnDirClick(Sender: TObject);
var
  s: string;
begin
  s := TargetPath;
  if SelectDirectory(SCnSelectTargetPath, '', s) then
  begin
    edtDir.Text := s;
  end;
end;

procedure TCnDirListForm.btnListClick(Sender: TObject);
begin
  Searching(True);
  try
    FileMasksToStringsStrict(GetFileMasks, FSearchMasks, GetFileCaseSensitive);
    BuildTree;
  finally
    Searching(False);
  end;
  UpdateText;
end;

procedure TCnDirListForm.btnSaveTXTClick(Sender: TObject);
var
  ssNames, ssDuplicated: TStringList;
begin
  if SDText.Execute then
  begin
    ssNames := TStringList.Create;
    ssDuplicated := TStringList.Create;
    try
      ssNames.Sorted := True;
      ssDuplicated.Sorted := True;
      
      DirListExtractFileNames(mmoResult.Lines, ssNames, ssDuplicated);
{     if ssDuplicated.Count > 0 then
      begin
        if not PreviewText(ssDuplicated, False, SCnNameDuplicatedFiles) then
        begin
          Exit;
        end;
      end;  }
      
      case SDText.FilterIndex of
        2: begin
          SaveAsCSV(SDText.FileName);
        end;
      else
        SaveAsTXT(SDText.FileName);
      end;
    finally
      ssNames.Free;
      ssDuplicated.Free;
    end;
    ShowMessage(Format(SCnSuccessedSaveToFile, [AnsiQuotedStr(SDText.FileName, '"')]));
  end;
end;

procedure TCnDirListForm.btnSynchronizeClick(Sender: TObject);
begin
  TreeToText;
end;

procedure TCnDirListForm.BuildTree;
begin
  FSearchAbort := False;
  FSearchRoot := MakePath(TargetPath);

  tvResult.Items.Clear;
  tvResult.Items.BeginUpdate;
  try
    CnBaseUtils.FindFile(Self, FSearchRoot, '*.*', OnFindFile, OnFindDir, IncludeSubDirectoies, OnProcessMsg);
  finally
    tvResult.Items.EndUpdate;
    CachedNode := nil;
  end;
end;

procedure TCnDirListForm.chbAutoSyncClick(Sender: TObject);
begin
  if chbAutoSync.Checked then
  begin
    btnSynchronize.Click;
  end;
end;

procedure TCnDirListForm.chbSubDirClick(Sender: TObject);
begin
  if (Sender = chbRelative) or (Sender = chbGroup) then
  begin
    UpdateControlsState;
  end;

  if Sender <> chbSubDir then
  begin
    UpdateTreeView;
  end;
  UpdateText;
end;

procedure TCnDirListForm.CollaspeAll1Click(Sender: TObject);
begin
  tvResult.Items.BeginUpdate;
  try
    tvResult.FullCollapse;
  finally
    tvResult.Items.EndUpdate;
  end;
end;

procedure TCnDirListForm.Deleteemptydirectoriesfromtree1Click(Sender: TObject);

  function _GetNextNodeExcludeChild(Node: TTreeNode): TTreeNode;
  var
    NodeID, ParentID: HTreeItem;
  begin
    Result := nil;
    with Node do
    begin
      if (Handle <> 0) and (ItemId <> nil) then
      begin
        NodeID := TreeView_GetNextSibling(Handle, ItemId);
        ParentID := ItemId;
        while (NodeID = nil) and (ParentID <> nil) do
        begin
          ParentID := TreeView_GetParent(Handle, ParentID);
          NodeID := TreeView_GetNextSibling(Handle, ParentID);
        end;
        Result := Owner.GetNode(NodeID);
      end;
    end;
  end;

  function _GetCanDeleteNode(Node: TTreeNode): TTreeNode;
  begin
    Result := Node;
    while (Result.Parent <> nil) and (Result.Parent.Count <= 1) do
    begin
      Result := Result.Parent;
    end;
  end;

  function _DeleteNode(Node: TTreeNode): TTreeNode;
  var
    AncestorNode: TTreeNode;
  begin
    AncestorNode := _GetCanDeleteNode(Node);
    Result := _GetNextNodeExcludeChild(AncestorNode);
    AncestorNode.Delete;
  end;

var
  Node, NextNode: TTreeNode;
begin
  tvResult.Items.BeginUpdate;
  try
    Node := tvResult.Items.GetFirstNode;
    while Node <> nil do
    begin
      NextNode := Node.GetNext;
      if PSearchResultInfo(Node.Data).IsDir and (not Node.HasChildren) then
      begin
        NextNode := _DeleteNode(Node);
      end;

      Node := NextNode;
    end;
  finally
    tvResult.Items.EndUpdate;
  end;
  UpdateText;
end;

procedure TCnDirListForm.DeleteSelection(tv: TTreeView);
begin
  tv.Selected.Delete;
end;

procedure TCnDirListForm.miDelByMasksClick(Sender: TObject);

  procedure _AddChildren(ss: TStrings; Node: TTreeNode);
  var
    _Node: TTreeNode;
  begin
    _Node := Node.getFirstChild;
    while _Node <> nil do
    begin
      ss.Add(NodeToText(_Node));
      if _Node.HasChildren then
      begin
        _AddChildren(ss, _Node);
      end;
      _Node := _Node.getNextSibling;
    end;
  end;

var
  ss, ssMasks: TStrings;
  Node: TTreeNode;
  IsDir, WillDelete: Boolean;
  i: Integer;
  sri: PSearchResultInfo;
begin
  if not SelectMasks(CachedMasks, CachedCaseSensitive, CachedDelDirs, CachedDelFiles) then
  begin
    Exit;
  end;

  ss := TStringList.Create;
  ssMasks := TStringList.Create;
  try
    FileMasksToStringsStrict(CachedMasks, ssMasks, CachedCaseSensitive);

    tvResult.Items.BeginUpdate;
    try
      Node := tvResult.Items.GetFirstNode;
      while Node <> nil do
      begin
        sri := PSearchResultInfo(Node.Data);
        IsDir := sri.IsDir;
        WillDelete := False;
        if (IsDir and CachedDelDirs) or (CachedDelFiles and (not IsDir)) then
        begin
          WillDelete := FileMatchesMasks(
            _CnExtractFileName(MakeDir(sri.Name)),
            ssMasks, CachedCaseSensitive);
          if WillDelete then
          begin
            ss.AddObject(NodeToText(Node), Node);
          end;
        end;

        if IsDir and WillDelete then
        begin
          _AddChildren(ss, Node);
          Node := Node.getNextSibling;
        end
        else
        begin
          Node := Node.GetNext;
        end;
      end;
    finally
      tvResult.Items.EndUpdate;
    end;

    if ss.Count = 0 then
    begin
      if CachedDelDirs and CachedDelFiles then
      begin
        ShowMessage(SCnNoMatchedResultAll);
      end
      else if CachedDelDirs then
      begin
        ShowMessage(SCnNoMatchedResultDir);
      end
      else if CachedDelFiles then
      begin
        ShowMessage(SCnNoMatchedResultFile);
      end;

      Exit;
    end;

    if not PreviewText(ss, True) then
    begin
      Exit;
    end;

    tvResult.Items.BeginUpdate;
    try
      for i := 0 to ss.Count - 1 do
      begin
        if ss.Objects[i] <> nil then
        begin
          TTreeNode(ss.Objects[i]).Delete;
        end;
      end;
    finally
      tvResult.Items.EndUpdate;
    end;

  finally
    ss.Free;
    ssMasks.Free;
  end;

  UpdateText;
end;

procedure TCnDirListForm.edtDirChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnDirListForm.edtDirKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_CONTROL) and (Shift = []) and (TargetPath = '') then
  begin
    btnDir.Click;
  end;
end;

procedure TCnDirListForm.edtMasksContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Pos: TPoint;
begin
  if pmMasks.Items.Count > 0 then
  begin
    Pos := edtMasks.ClientToScreen(MousePos);
    pmMasks.Popup(Pos.X, Pos.Y);
    Handled := True;
  end;
end;

procedure TCnDirListForm.ExpandAll1Click(Sender: TObject);
begin
  tvResult.Items.BeginUpdate;
  try
    tvResult.FullExpand;
  finally
    tvResult.Items.EndUpdate;
  end;
end;

function TCnDirListForm.FindNodeByName(const s: string): TTreeNode;

  function _FindNode(_Node: TTreeNode; const _s: string): TTreeNode;
  var
    Node: TTreeNode;
  begin
    Result := nil;

    if _Node = nil then
    begin
      Node := tvResult.Items.GetFirstNode;
    end
    else
    begin
      Node := _Node.getFirstChild;
    end;

    while Node <> nil do
    begin
      if PSearchResultInfo(Node.Data).Name = _s then
      begin
        Result := Node;
        Break;
      end;
      Node := Node.getNextSibling;
    end;
  end;

var
  Node: TTreeNode;
  tmpRelativePath: string;
begin
  if (CachedNode <> nil) and (PSearchResultInfo(CachedNode.Data).Name = s) then
  begin
    Result := CachedNode;
    Exit;
  end;

  tmpRelativePath := FSearchRoot;
  Node := nil;
  Repeat
    tmpRelativePath := GetNextLevelPath(s, tmpRelativePath);
    if tmpRelativePath = '' then
    begin
      tmpRelativePath := s;
    end;
    Node := _FindNode(Node, tmpRelativePath);
  until (Node = nil) or (tmpRelativePath = s);

  CachedNode := Node;
  Result := Node;
end;

function TCnDirListForm.FindParentNodeByName(const s: string): TTreeNode;
var
  ParentPath: string;
begin
  ParentPath := GetParentPath(s);
  Result := FindNodeByName(ParentPath);
end;

procedure TCnDirListForm.FormCreate(Sender: TObject);
begin
  CachedCaseSensitive := False;
  CachedDelDirs := True;
  CachedDelFiles := True;
  FSearchMasks := TStringList.Create;
  SetMasksPopupMenu;
end;

procedure TCnDirListForm.FormDestroy(Sender: TObject);
begin
  FSearchMasks.Free;
end;

procedure TCnDirListForm.FormResize(Sender: TObject);
begin
  GridPanel1.Realign;
end;

function TCnDirListForm.GetFileCaseSensitive: Boolean;
begin
  Result := chbCaseSensitive.Checked;
end;

function TCnDirListForm.GetFileMasks: string;
begin
  Result := Trim(edtMasks.Text);
  if Result = '' then
  begin
    Result := '*.*';
  end;
end;

function TCnDirListForm.GetNextLevelPath(const s, Relative: string): string;
var
  ParentPath1: string;
begin
  if s = '' then
  begin
    Result := '';
  end;

  ParentPath1 := GetParentPath(s);

  if (ParentPath1 = '') then
  begin
    Result := '';
  end
  else if (ParentPath1 = Relative) then
  begin
    Result := s;
  end
  else
  begin
    Result := GetNextLevelPath(ParentPath1, Relative);
  end;
end;

function TCnDirListForm.GetNodeText(s: string; IsDir: Boolean): string;
begin
  s := MakeDir(s);

  if chbRelative.Checked then
  begin
    if chbGroup.Checked then
    begin
      Result := _CnExtractFileName(s);
      Exit;
    end;

    Result := RelativePath_API(FSearchRoot, s, True, IsDir);

    if not chbPrefix.Checked then
    begin
      if Pos('.\', Result) = 1 then
      begin
        Delete(Result, 1, 2);
      end
      else if Pos('\', Result) = 1 then
      begin
        Delete(Result, 1, 1);
      end;
    end;
    
    Exit;
  end;

  Result := s;
end;

function TCnDirListForm.IncludeSubDirectoies: Boolean;
begin
  Result := chbSubDir.Checked;
end;

procedure TCnDirListForm.MenuItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    if edtMasks.Text = '' then
    begin
      edtMasks.Text := TMenuItem(Sender).Caption;
    end
    else
    begin
      edtMasks.Text := edtMasks.Text + ';' + TMenuItem(Sender).Caption;
    end;
  end;
end;

procedure TCnDirListForm.miDeleteSelectedClick(Sender: TObject);
begin
  if tvResult.Selected <> nil then
  begin
    DeleteSelection(tvResult);
  end;
  UpdateText;
end;

procedure TCnDirListForm.miLoadTreeClick(Sender: TObject);
begin
  if ODTree.Execute then
  begin
    tvResult.Items.Clear;
    tvResult.Items.BeginUpdate;
    try
      tvResult.LoadFromFile(ODTree.FileName);
      AfterLoadTree;
    finally
      tvResult.Items.EndUpdate;
      UpdateText;
    end;
  end;
end;

procedure TCnDirListForm.miSaveTreeClick(Sender: TObject);
begin
  if SDTree.Execute then
  begin
    tvResult.Items.BeginUpdate;
    try
      BeforeSaveTree;
      tvResult.SaveToFile(SDTree.FileName);
      AfterSaveTree;
    finally
      tvResult.Items.EndUpdate;
    end;
  end;
end;

function TCnDirListForm.NodeParentIs(Node, Parent: TTreeNode): Boolean;
begin
  Result := Assigned(Node) and (Node.Parent = Parent);
  if (not Result) and
    (Parent <> nil) and (Parent.HasChildren) and
    Assigned(Node) and (Node.Parent <> nil) then
  begin
    Result := NodeParentIs(Node.Parent, Parent);
  end;
end;

function TCnDirListForm.NodeToText(Node: TTreeNode): string;
begin
  Result := Node.Text;
end;

procedure TCnDirListForm.PerformUpdateText;
begin
  if tmPerformUpdateText.Enabled then
  begin
    tmPerformUpdateText.Enabled := False;
  end;
  tmPerformUpdateText.Enabled := True;
end;

procedure TCnDirListForm.pmTVPopup(Sender: TObject);
var
  i: Integer;
  bEnable: Boolean;
begin
  bEnable := tvResult.Items.Count > 0;
  for i := 0 to pmTV.Items.Count - 1 do
  begin
    if pmTV.Items[i].Tag >= 0 then
    begin
      pmTV.Items[i].Enabled := bEnable;
    end;
  end;

  if not bEnable then
  begin
    Exit;
  end;

  miDeleteSelected.Enabled := tvResult.Selected <> nil;
end;

function TCnDirListForm.Quiting: Boolean;
begin
  Application.ProcessMessages;
  Result := Application.Terminated;
end;

procedure TCnDirListForm.SaveAsCSV(const s: string);
var
  i: Integer;
  tmpS: string;
  Stream: TStream;
begin
  Stream := TFileStream.Create(s, fmCreate);
  try
    for i := 0 to mmoResult.Lines.Count - 1 do
    begin
      tmpS := AnsiQuotedStr(mmoResult.Lines[i], CQuotedChar) + CRLF;
      Stream.WriteBuffer(Pointer(tmpS)^, Length(tmpS));
    end;
  finally
    Stream.Free;
  end;
end;

procedure TCnDirListForm.SaveAsTXT(const s: string);
begin
  mmoResult.Lines.SaveToFile(s);
end;

procedure TCnDirListForm.Searching(const b: Boolean);
begin
  FSearching := b;
  UpdateControlsState;
end;

procedure TCnDirListForm.SetMasksPopupMenu;
var
  ss: TStrings;
  sFile: string;
  i: Integer;
  mi: TMenuItem;
begin
  ss := TStringList.Create;
  try
    sFile := MakePath(_CnExtractFileDir(ParamStr(0))) + 'Masks.txt';
    if FileExists(sFile) then
    begin
      StringsLoadFromFileWithSection(ss, sFile, 'SearchMasks');
    end;

    for i := 0 to ss.Count - 1 do
    begin
      if Trim(ss[i]) = '' then
      begin
        Continue;
      end;

      mi := TMenuItem.Create(pmMasks);
      mi.Caption := ss[i];
      mi.OnClick := MenuItemClick;
      pmMasks.Items.Add(mi);
    end;
  finally
    ss.Free;
  end;
end;

procedure TCnDirListForm.SetSearchRoot(const s: string);
begin
  FSearchRoot := s;
  edtDir.Text := MakeDir(s);
end;

procedure TCnDirListForm.Syncing(const b: Boolean);
begin
  FSyncing := b;
  UpdateControlsState;
end;

function TCnDirListForm.TargetPath: string;
begin
  Result := Trim(edtDir.Text);
end;

procedure TCnDirListForm.tmPerformUpdateTextTimer(Sender: TObject);
begin
  tmPerformUpdateText.Enabled := False;
  UpdateText;
end;

procedure TCnDirListForm.TreeToText;
var
  Node: TTreeNode;
  bNext: Boolean;
  IsDir: Boolean;
begin
  Syncing(True);
  try
    bNext := chbSubDir.Checked;

    tvResult.Items.BeginUpdate;
    mmoResult.Lines.BeginUpdate;
    try
      mmoResult.Clear;

      Node := tvResult.Items.GetFirstNode;
      while (Node <> nil) and (not UpdateTextPerformed) do
      begin
        IsDir := PSearchResultInfo(Node.Data).IsDir;
        if (IsDir and chbSyncDirs.Checked) or ((not IsDir) and chbSyncFiles.Checked) then
        begin
          mmoResult.Lines.Add(NodeToText(Node));
        end;

        if bNext then
        begin
          Node := Node.getNext;
        end
        else
        begin
          Node := Node.getNextSibling;
        end;
      end;
    finally
      tvResult.Items.EndUpdate;
      mmoResult.Lines.EndUpdate;
    end;
  finally
    Syncing(False);
  end;
end;

procedure TCnDirListForm.tvResultDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node) and (Node.Data <> nil) then
  begin
    DisposeSearchResultInfo(Node.Data);
  end;
end;

procedure TCnDirListForm.tvResultKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (tvResult.Selected <> nil) and (Key = VK_DELETE) then
  begin
    DeleteSelection(tvResult);
    PerformUpdateText;
  end;
end;

procedure TCnDirListForm.UpdateControlsState;
var
  bEnabled: Boolean;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    Application.ProcessMessages;
    
    bEnabled := (not FSearching) and (not FSyncing);

    btnAbortSearch.Visible := FSearching;
    btnAbortSearch.Enabled := FSearching;
    btnList.Enabled := bEnabled and DirectoryExists(TargetPath);
    btnList.Visible := bEnabled;
    edtDir.Enabled := bEnabled;
    btnDir.Enabled := bEnabled;
    edtMasks.Enabled := bEnabled;
    chbCaseSensitive.Enabled := bEnabled;
    chbSubDir.Enabled := bEnabled;
    chbRelative.Enabled := bEnabled;
    chbGroup.Enabled := chbRelative.Enabled and chbRelative.Checked;
    chbPrefix.Enabled := chbGroup.Enabled and (not chbGroup.Checked);
    btnSaveTXT.Enabled := bEnabled and (mmoResult.Lines.Count > 0);
    chbSyncDirs.Enabled := bEnabled;
    chbSyncFiles.Enabled := bEnabled;
    btnSynchronize.Enabled := bEnabled and (chbSyncDirs.Checked or chbSyncFiles.Checked);
    chbAutoSync.Enabled := btnSynchronize.Enabled;
  finally
    FUIUpdating := False;
  end;
end;

procedure TCnDirListForm.UpdateText;
begin
  if chbAutoSync.Checked then
  begin
    TreeToText;
  end;
end;

function TCnDirListForm.UpdateTextPerformed: Boolean;
begin
  Result := Assigned(tmPerformUpdateText) and tmPerformUpdateText.Enabled;
end;

procedure TCnDirListForm.UpdateTreeView;
var
  i: Integer;
  s: string;
begin
  tvResult.Items.BeginUpdate;
  try
    for i := 0 to tvResult.Items.Count - 1 do
    begin
      with PSearchResultInfo(tvResult.Items[i].Data)^ do
      begin
        s := Name;
        tvResult.Items[i].Text := GetNodeText(s, IsDir);
      end;
    end;
  finally
    tvResult.Items.EndUpdate;
  end;
end;

initialization
  RegisterFormClass(TCnDirListForm);

end.
