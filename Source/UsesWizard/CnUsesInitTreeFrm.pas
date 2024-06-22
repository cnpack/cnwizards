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

unit CnUsesInitTreeFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程引用树分析单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin7/10 + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2021.08.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ToolWin, ExtCtrls, ActnList, ToolsAPI,
  CnTree, CnCommon, CnWizMultiLang, CnWizConsts, CnWizUtils, CnWizIdeUtils,
  Menus;

type
  TCnUsesInitTreeForm = class(TCnTranslateForm)
    grpFilter: TGroupBox;
    chkProjectPath: TCheckBox;
    chkSystemPath: TCheckBox;
    grpTree: TGroupBox;
    tvTree: TTreeView;
    pnlTop: TPanel;
    lblProject: TLabel;
    cbbProject: TComboBox;
    tlbUses: TToolBar;
    btnGenerateUsesTree: TToolButton;
    grpInfo: TGroupBox;
    actlstUses: TActionList;
    actGenerateUsesTree: TAction;
    actHelp: TAction;
    actExit: TAction;
    btn1: TToolButton;
    btnHelp: TToolButton;
    btnExit: TToolButton;
    lblSourceFile: TLabel;
    lblDcuFile: TLabel;
    lblSearchType: TLabel;
    lblUsesType: TLabel;
    lblSearchTypeText: TLabel;
    lblUsesTypeText: TLabel;
    actExport: TAction;
    actSearch: TAction;
    btnSearch: TToolButton;
    btnExport: TToolButton;
    btn2: TToolButton;
    actOpen: TAction;
    btnOpen: TToolButton;
    actLocateSource: TAction;
    btnLocateSource: TToolButton;
    pmTree: TPopupMenu;
    Open1: TMenuItem;
    OpeninExplorer1: TMenuItem;
    ExportTree1: TMenuItem;
    Search1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    dlgSave: TSaveDialog;
    actSearchNext: TAction;
    btnSearchNext: TToolButton;
    btn4: TToolButton;
    dlgFind: TFindDialog;
    mmInit: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Search2: TMenuItem;
    Help1: TMenuItem;
    Exit1: TMenuItem;
    AnalyseProject1: TMenuItem;
    ExportTree2: TMenuItem;
    Search3: TMenuItem;
    SearchNext1: TMenuItem;
    N3: TMenuItem;
    Open2: TMenuItem;
    OpeninExplorer2: TMenuItem;
    Help2: TMenuItem;
    SearchNext2: TMenuItem;
    mmoSourceFileText: TMemo;
    mmoDcuFileText: TMemo;
    statUses: TStatusBar;
    procedure actGenerateUsesTreeExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkSystemPathClick(Sender: TObject);
    procedure tvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure actExitExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actlstUsesUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actExportExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure dlgFindClose(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure actSearchNextExecute(Sender: TObject);
    procedure actLocateSourceExecute(Sender: TObject);
  private
    FTree: TCnTree;
    FFileNames: TStringList;
    FLibPaths: TStringList;
    FDcuPath: string;
    FProjectList: TInterfaceList;
    FOldSearchStr: string;
    procedure InitProjectList;
    procedure TreeSaveANode(ALeaf: TCnLeaf; ATreeNode: TTreeNode; var Valid: Boolean);
    procedure SearchAUnit(const AFullDcuName, AFullSourceName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
    {* 递归调用，分析并查找对应 dcu 或源码的 Uses 列表并加入到树中的 UnitLeaf 的子节点中}
    procedure UpdateTreeView;
    procedure UpdateInfo(Leaf: TCnLeaf);
    function SearchText(const Text: string; ToDown, IgnoreCase, WholeWord: Boolean): Boolean;
  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$R *.DFM}

uses
  CnWizShareImages, CnDCU32, CnWizOptions;

const
  csDcuExt = '.dcu';
  csExploreCmdLine = 'EXPLORER.EXE /e, /select, "%s"';

  csSearchTypeStrings: array[Low(TCnModuleSearchType)..High(TCnModuleSearchType)] of PString =
    (nil, @SCnUsesInitTreeSearchInProject, @SCnUsesInitTreeSearchInProjectSearch,
    @SCnUsesInitTreeSearchInSystemSearch);

type
  TCnUsesLeaf = class(TCnLeaf)
  private
    FIsImpl: Boolean;
    FDcuName: string;
    FSearchType: TCnModuleSearchType;
    FSourceName: string;
  public
    property SourceName: string read FSourceName write FSourceName;
    {* 源文件完整路径名}
    property DcuName: string read FDcuName write FDcuName;
    {* Dcu 文件完整路径名}
    property SearchType: TCnModuleSearchType read FSearchType write FSearchType;
    {* 哪种引用类型}
    property IsImpl: Boolean read FIsImpl write FIsImpl;
    {* 引用是否在 implementation 部分}
  end;

function GetDcuName(const ADcuPath, ASourceFileName: string): string;
begin
  if ADcuPath = '' then
    Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
  else
    Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
end;

procedure TCnUsesInitTreeForm.actGenerateUsesTreeExecute(Sender: TObject);
var
  Proj, P: IOTAProject;
  I: Integer;
  ProjDcu: string;
begin
  Proj := nil;
  if cbbProject.ItemIndex <= 0 then // 当前工程
  begin
    Proj := CnOtaGetCurrentProject;
    if (Proj = nil) or not IsDelphiProject(Proj) then
      Exit;
  end
  else
  begin
    // 特定名称的工程
    for I := 0 to FProjectList.Count - 1 do
    begin
      P := FProjectList[I] as IOTAProject;
      if cbbProject.Items[cbbProject.ItemIndex] = _CnExtractFileName(P.FileName) then
      begin
        Proj := P;
        Break;
      end;
    end;
  end;

  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  // 编译工程
  if not CompileProject(Proj) then
  begin
    Close;
    ErrorDlg(SCnUsesCleanerCompileFail);
    Exit;
  end;

  FTree.Clear;
  FFileNames.Clear;
  statUses.SimpleText := '';

  FDcuPath := GetProjectDcuPath(Proj);
  GetLibraryPath(FLibPaths, False);

  (FTree.Root as TCnUsesLeaf).SourceName := CnOtaGetProjectSourceFileName(Proj);;
  (FTree.Root as TCnUsesLeaf).DcuName := ProjDcu;
  (FTree.Root as TCnUsesLeaf).SearchType := mstInProject;
  (FTree.Root as TCnUsesLeaf).IsImpl := False;
  (FTree.Root as TCnUsesLeaf).Text := _CnExtractFileName((FTree.Root as TCnUsesLeaf).SourceName);
  ProjDcu := GetDcuName(FDcuPath, (FTree.Root as TCnUsesLeaf).SourceName);

  Screen.Cursor := crHourGlass;
  try
    SearchAUnit(ProjDcu, (FTree.Root as TCnUsesLeaf).SourceName, FFileNames,
      FTree.Root, FTree, Proj);
  finally
    Screen.Cursor := crDefault;
  end;

  UpdateTreeView;
end;

procedure TCnUsesInitTreeForm.FormCreate(Sender: TObject);
begin
  FFileNames := TStringList.Create;
  FLibPaths := TStringList.Create;
  FTree := TCnTree.Create(TCnUsesLeaf);
  FProjectList := TInterfaceList.Create;
  tlbUses.ShowHint := WizOptions.ShowHint;

  FTree.OnSaveANode := TreeSaveANode;

  InitProjectList;
  WizOptions.ResetToolbarWithLargeIcons(tlbUses);
  IdeScaleToolbarComboFontSize(cbbProject);

  if WizOptions.UseLargeIcon then
  begin
    tlbUses.Height := tlbUses.Height + csLargeToolbarHeightDelta;
    pnlTop.Height := pnlTop.Height + csLargeToolbarHeightDelta;
  end;
end;

procedure TCnUsesInitTreeForm.FormDestroy(Sender: TObject);
begin
  FProjectList.Free;
  FTree.Free;
  FLibPaths.Free;
  FFileNames.Free;
end;

procedure TCnUsesInitTreeForm.InitProjectList;
var
  I: Integer;
  Proj: IOTAProject;
{$IFDEF BDS}
  PG: IOTAProjectGroup;
{$ENDIF}
begin
  CnOtaGetProjectList(FProjectList);
  cbbProject.Items.Clear;

  if FProjectList.Count <= 0 then
    Exit;

  for I := 0 to FProjectList.Count - 1 do
  begin
    Proj := IOTAProject(FProjectList[I]);
    if Proj.FileName = '' then
      Continue;

{$IFDEF BDS}
    // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
    if Supports(Proj, IOTAProjectGroup, PG) then
      Continue;
{$ENDIF}

    if not IsDelphiProject(Proj) then
      Continue;

    cbbProject.Items.Add(_CnExtractFileName(Proj.FileName));
  end;

  if cbbProject.Items.Count > 0 then
  begin
    cbbProject.Items.Insert(0, SCnProjExtCurrentProject);
    cbbProject.ItemIndex := 0;
  end;
end;

procedure TCnUsesInitTreeForm.SearchAUnit(const AFullDcuName,
  AFullSourceName: string; ProcessedFiles: TStrings; UnitLeaf: TCnLeaf;
  Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  ASourceFileName, ADcuFileName: string;
  UsesList: TStringList;
  I, J: Integer;
  Leaf: TCnUsesLeaf;
  Info: TCnUnitUsesInfo;
begin
  // 分析 DCU 或源码得到 intf 与 impl 的引用列表，并加入至 UnitLeaf 的直属子节点
  // 递归调用该方法，处理每个引用列表中的引用单元名
  if  not FileExists(AFullDcuName) and not FileExists(AFullSourceName)
    and not CnOtaIsFileOpen(AFullSourceName) then // 还没保存并且还没编译的情况也要处理
    Exit;

  UsesList := TStringList.Create;
  try
    if FileExists(AFullDcuName) then // 有 DCU 就解析 DCU
    begin
      statUses.SimpleText := AFullDcuName;
      Info := TCnUnitUsesInfo.Create(AFullDcuName);
      try
        for I := 0 to Info.IntfUsesCount - 1 do
          UsesList.Add(Info.IntfUses[I]);
        for I := 0 to Info.ImplUsesCount - 1 do
          UsesList.AddObject(Info.ImplUses[I], TObject(True));
      finally
        Info.Free;
      end;
    end
    else // 否则解析源码
    begin
      statUses.SimpleText := AFullSourceName;
      ParseUnitUsesFromFileName(AFullSourceName, UsesList);
    end;
    Application.ProcessMessages;

    // UsesList 里拿到各引用名，无路径，需找到源文件与编译后的 dcu
    for I := 0 to UsesList.Count - 1 do
    begin
      // 找到源文件
      ASourceFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (ASourceFileName = '') or (ProcessedFiles.IndexOf(ASourceFileName) >= 0) then
        Continue;

      // 再找编译后的 dcu，可能在工程输出目录里，也可能在系统的 LibraryPath 里
      ADcuFileName := GetDcuName(FDcuPath, ASourceFileName);
      if not FileExists(ADcuFileName) then
      begin
        // 在系统的多个 LibraryPath 里找
        for J := 0 to FLibPaths.Count - 1 do
        begin
          if FileExists(MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt) then
          begin
            ADcuFileName := MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt;
            Break;
          end;
        end;
      end;

      if not FileExists(ADcuFileName) then
        Continue;

      // ASourceFileName 存在且未处理过，新建一个 Leaf，挂当前 Leaf 下面
      Leaf := Tree.AddChild(UnitLeaf) as TCnUsesLeaf;
      Leaf.Text := _CnExtractFileName(_CnChangeFileExt(ASourceFileName, ''));
      Leaf.SourceName := ASourceFileName;
      Leaf.DcuName := ADcuFileName;
      Leaf.SearchType := St;
      Leaf.IsImpl := UsesList.Objects[I] <> nil;

      ProcessedFiles.Add(ASourceFileName);
      SearchAUnit(ADcuFileName, ASourceFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

procedure TCnUsesInitTreeForm.UpdateTreeView;
var
  Node: TTreeNode;
  I: Integer;
  Leaf: TCnUsesLeaf;
begin
  tvTree.Items.Clear;
  Node := tvTree.Items.AddObject(nil,
    _CnExtractFileName(_CnChangeFileExt(FTree.Root.Text, '')), FTree.Root);

  FTree.SaveToTreeView(tvTree, Node);

  if chkSystemPath.Checked and chkProjectPath.Checked then
  begin
    if tvTree.Items.Count > 0 then
      tvTree.Items[0].Expand(True);

    statUses.SimpleText := Format(SCnBookmarkFileCount, [tvTree.Items.Count]);
    Exit;
  end;

  for I := tvTree.Items.Count - 1 downto 0 do
  begin
    Node := tvTree.Items[I];
    Leaf := TCnUsesLeaf(Node.Data);

    if not chkSystemPath.Checked and (Leaf.SearchType = mstSystemSearch) then
      tvTree.Items.Delete(Node)
    else if not chkProjectPath.Checked and (Leaf.SearchType = mstProjectSearch) then
      tvTree.Items.Delete(Node);
  end;

  if tvTree.Items.Count > 0 then
    tvTree.Items[0].Expand(True);

  statUses.SimpleText := Format(SCnBookmarkFileCount, [tvTree.Items.Count]);
end;

procedure TCnUsesInitTreeForm.chkSystemPathClick(Sender: TObject);
begin
  UpdateTreeView;
end;

procedure TCnUsesInitTreeForm.TreeSaveANode(ALeaf: TCnLeaf;
  ATreeNode: TTreeNode; var Valid: Boolean);
begin
  ATreeNode.Text := ALeaf.Text;
  ATreeNode.Data := ALeaf;
end;

procedure TCnUsesInitTreeForm.tvTreeChange(Sender: TObject;
  Node: TTreeNode);
var
  Leaf: TCnUsesLeaf;
begin
  if Node <> nil then
  begin
    Leaf := TCnUsesLeaf(Node.Data);
    if Leaf <> nil then
      UpdateInfo(Leaf);
  end;
end;

procedure TCnUsesInitTreeForm.UpdateInfo(Leaf: TCnLeaf);
var
  ALeaf: TCnUsesLeaf;
begin
  ALeaf := TCnUsesLeaf(Leaf);

  mmoSourceFileText.Lines.Text := ALeaf.SourceName;
  mmoDcuFileText.Lines.Text := ALeaf.DcuName;
  if ALeaf.SearchType <> mstInvalid then
    lblSearchTypeText.Caption := csSearchTypeStrings[ALeaf.SearchType]^
  else
    lblSearchTypeText.Caption := SCnUnknownNameResult;

  if ALeaf.IsImpl then
    lblUsesTypeText.Caption := 'implementation'
  else if not IsDpr(ALeaf.SourceName) and not IsDpk(ALeaf.SourceName) then
    lblUsesTypeText.Caption := 'interface'
  else
    lblUsesTypeText.Caption := '';
end;

procedure TCnUsesInitTreeForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnUsesInitTreeForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnUsesInitTreeForm.actOpenExecute(Sender: TObject);
var
  Leaf: TCnUsesLeaf;
begin
  if tvTree.Selected <> nil then
  begin
    Leaf := TCnUsesLeaf(tvTree.Selected.Data);
    if (Leaf <> nil) and (Leaf.SourceName <> '') then
      CnOtaOpenFile(Leaf.SourceName);
  end;
end;

procedure TCnUsesInitTreeForm.actlstUsesUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = actOpen) or (Action = actLocateSource) then
    TCustomAction(Action).Enabled := tvTree.Selected <> nil
  else if (Action = actExport) or (Action = actSearch) or (Action = actSearchNext) then
    TCustomAction(Action).Enabled := tvTree.Items.Count > 1
  else if Action = actGenerateUsesTree then
    TCustomAction(Action).Enabled := cbbProject.Items.Count > 0;
end;

procedure TCnUsesInitTreeForm.actExportExecute(Sender: TObject);
var
  I: Integer;
  L: TStringList;
begin
  if dlgSave.Execute then
  begin
    L := TStringList.Create;
    try
      for I := 0 to tvTree.Items.Count - 1 do
      begin
        L.Add(Format('%2.2d:%s%s',[I + 1, StringOfChar(' ', tvTree.Items[I].Level),
          tvTree.Items[I].Text]));
      end;
      L.SaveToFile(_CnChangeFileExt(dlgSave.FileName, '.txt'));
    finally
      L.Free;
    end;
  end;
end;

procedure TCnUsesInitTreeForm.actSearchExecute(Sender: TObject);
begin
  if tvTree.Items.Count <= 0 then
    Exit;

  dlgFind.FindText := FOldSearchStr;
  dlgFind.Execute;
end;

procedure TCnUsesInitTreeForm.dlgFindClose(Sender: TObject);
begin
  FOldSearchStr := dlgFind.FindText;
end;

procedure TCnUsesInitTreeForm.dlgFindFind(Sender: TObject);
begin
  // 根据 dlgFind.FindText 以及查找选项（上下等）进行 TreeView 内的 Node 的 Text 搜索
  if not SearchText(dlgFind.FindText, frDown in dlgFind.Options,
    not (frMatchCase in dlgFind.Options), frWholeWord in dlgFind.Options) then
    ErrorDlg(SCnUsesInitTreeNotFound);
end;

function TCnUsesInitTreeForm.SearchText(const Text: string; ToDown,
  IgnoreCase, WholeWord: Boolean): Boolean;
var
  StartNode: TTreeNode;
  I, Idx, FindIdx: Integer;
  Found: Boolean;

  function MatchNode(ANode: TTreeNode): Boolean;
  var
    S1, S2: string;
  begin
    Result := False;
    if IgnoreCase then // 忽略大小写，都用小写比较
    begin
      S1 := LowerCase(Text);
      S2 := LowerCase(ANode.Text);
    end
    else // 匹配大小写
    begin
      S1 := Text;
      S2 := ANode.Text;
    end;

    if WholeWord and (S1 = S2) then
      Result := True
    else if not WholeWord and (Pos(S1, S2) >= 1) then
      Result := True;
  end;

begin
  Result := False;
  StartNode := tvTree.Selected;
  if StartNode = nil then
  begin
    if ToDown then
      StartNode := tvTree.Items[0]
    else
      StartNode := tvTree.Items[tvTree.Items.Count - 1];
  end;

  if StartNode = nil then
    Exit;

  Idx := StartNode.AbsoluteIndex;
  Found := False;
  FindIdx := -1;

  if ToDown then
  begin
    for I := Idx + 1 to tvTree.Items.Count - 1 do
    begin
      if MatchNode(tvTree.Items[I]) then
      begin
        Found := True;
        FindIdx := I;
        Break;
      end;
    end;

    if not Found then
    begin
      for I := 0 to Idx do
      begin
        if MatchNode(tvTree.Items[I]) then
        begin
          Found := True;
          FindIdx := I;
          Break;
        end;
      end;
    end;
  end
  else
  begin
    for I := Idx - 1 downto 0 do
    begin
      if MatchNode(tvTree.Items[I]) then
      begin
        Found := True;
        FindIdx := I;
        Break;
      end;
    end;

    if not Found then
    begin
      for I := tvTree.Items.Count - 1 downto Idx do
      begin
        if MatchNode(tvTree.Items[I]) then
        begin
          Found := True;
          FindIdx := I;
          Break;
        end;
      end;
    end;
  end;

  if Found then
  begin
    tvTree.Selected := tvTree.Items[FindIdx];
    tvTree.Selected.MakeVisible;
    Result := True;
  end
  else
    Result := False;
end;

procedure TCnUsesInitTreeForm.actSearchNextExecute(Sender: TObject);
begin
  if FOldSearchStr = '' then
    dlgFind.Execute
  else if not SearchText(dlgFind.FindText, frDown in dlgFind.Options,
    not (frMatchCase in dlgFind.Options), frWholeWord in dlgFind.Options) then
    ErrorDlg(SCnUsesInitTreeNotFound);
end;

procedure TCnUsesInitTreeForm.actLocateSourceExecute(Sender: TObject);
var
  strExecute: string;
  Leaf: TCnUsesLeaf;
begin
  if tvTree.Selected = nil then
    Exit;

  Leaf := TCnUsesLeaf(tvTree.Selected.Data);
  if Leaf = nil then
    Exit;

  if FileExists(Leaf.SourceName) then
  begin
    strExecute := Format(csExploreCmdLine, [Leaf.SourceName]);
{$IFDEF UNICODE}
    WinExecute(strExecute, SW_SHOWNORMAL);
{$ELSE}
    WinExec(PAnsiChar(strExecute), SW_SHOWNORMAL);
{$ENDIF}
  end;
end;

function TCnUsesInitTreeForm.GetHelpTopic: string;
begin
  Result := 'CnUsesUnitsTools';
end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.

