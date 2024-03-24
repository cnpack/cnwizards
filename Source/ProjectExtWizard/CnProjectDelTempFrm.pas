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

unit CnProjectDelTempFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：删除工程临时文件窗体单元
* 单元作者：Hhha（Hhha） Hhha@eyou.con
*           周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2021.08.24
*               加入删除 __history 和 __recovery 目录的选项
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, SysUtils, Messages, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, CheckLst, IniFiles, Menus, ActnList, FileCtrl, ToolsAPI,
  CnCommon, CnWizConsts, CnWizMultiLang, CnWizIdeUtils, CnPopupMenu;

type
  TCnProjectDelTempForm = class(TCnTranslateForm)
    nb: TNotebook;
    btnFinish: TButton;
    btnNext: TButton;
    btnPrio: TButton;
    btnCancel: TButton;
    pnlDelList: TPanel;
    pnlDelCond: TPanel;
    grpPath: TGroupBox;
    grpFileType: TGroupBox;
    chklstDirs: TCheckListBox;
    btnAdd: TButton;
    btnRemove: TButton;
    chklstExtensions: TCheckListBox;
    btnAddExt: TButton;
    btnRemoveExt: TButton;
    ActionList: TActionList;
    actDirsCheckAll: TAction;
    actDirsUncheckAll: TAction;
    actDirsInvert: TAction;
    actExtsCheckAll: TAction;
    actExtsUncheckAll: TAction;
    actExtsInvert: TAction;
    pmuDirs: TPopupMenu;
    mitDirsCheckAll: TMenuItem;
    mitDirsUncheckAll: TMenuItem;
    mitDirsInvertChecked: TMenuItem;
    pmuExts: TPopupMenu;
    mitExtsCheckAll: TMenuItem;
    mitExtsUncheckAll: TMenuItem;
    mitExtsInvertChecked: TMenuItem;
    grpFileList: TGroupBox;
    chklstFileList: TCheckListBox;
    btnDefault: TButton;
    Label1: TLabel;
    lblpe: TLabel;
    cbbSelectType: TComboBox;
    btnHelp: TButton;
    chkCheckSource: TCheckBox;
    chkRemoveHistory: TCheckBox;
    btnSelAllDirs: TSpeedButton;
    btnSelAllExts: TSpeedButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnAddExtClick(Sender: TObject);
    procedure btnRemoveExtClick(Sender: TObject);
    procedure btnPrioClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure CheckActionExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chklstDirsClick(Sender: TObject);
    procedure chklstDirsKeyPress(Sender: TObject; var Key: Char);
    procedure chklstExtensionsClick(Sender: TObject);
    procedure chklstExtensionsKeyPress(Sender: TObject; var Key: Char);
    procedure btnFinishClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure cbbSelectTypeChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure chkCheckSourceClick(Sender: TObject);
    procedure btnSelAllDirsClick(Sender: TObject);
    procedure btnSelAllExtsClick(Sender: TObject);
  private
    FTotalBytesCleaned: Integer;
    FTotalFilesCleaned: Integer;
    CleanExtList: TStrings;
    FAbort: Boolean;
    FCheckSource: Boolean;
    FCheckDirs: Boolean;
    procedure CheckButton;
    procedure UpdateControls;
    procedure FillProjectDirectoriesList;
    procedure DeleteFoundFileOrDir(const FileName: string);
    procedure GetDelFile;
    procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure SetCheckSource(const Value: Boolean);
    procedure SetCheckDirs(const Value: Boolean);
  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    property CheckSource: Boolean read FCheckSource write SetCheckSource;
    property CheckDirs: Boolean read FCheckDirs write SetCheckDirs;
  end;

function ShowProjectDelTempForm(Ini: TCustomIniFile): Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  {$IFDEF COMPILER6_UP}Variants, {$ENDIF} CnWizUtils, CnDebug, CnWizOptions, Math;

const
  csDelTemp = 'DelTemp';
  csCleanExtList = 'CleanExtList';
  csSelExeList = 'SelExeList';
  csSelectType = 'SelectType';
  csCheckSource = 'CheckSource';
  csCheckDirs = 'CheckDirs';

  csDelHistory = '__history';
  csDelRecovery = '__recovery';

resourcestring
  SCnProjExtDefaultCleanExts =
    '.dcu,.obj,.~bpg,.~cpp,.~dfm,.~dpk,.~dsk,.~h,.~hpp,.~pas,.bak,.csm,.dsk,.drc,' +
    '.fts,.gid,.il*,.kwf,.md,.tds,.tmp,.$*,.~*,.#??,.ddp,.rsm,.map,.~xfm';

function ShowProjectDelTempForm(Ini: TCustomIniFile): Boolean;
begin
  with TCnProjectDelTempForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    LoadSettings(Ini);
    chkCheckSource.Checked := CheckSource;
    chkRemoveHistory.Checked := CheckDirs;

    Result := ShowModal = mrOk;
    if Result then
    begin
      CheckSource := chkCheckSource.Checked;
      CheckDirs := chkRemoveHistory.Checked;

      SaveSettings(Ini);
    end;
  finally
    Free;
  end;
end;

type
  TListBoxCheckAction = (chAll, chNone, chInvert);

procedure SetListBoxChecked(CheckList: TCheckListBox; Action:
  TListBoxCheckAction);
var
  I: Integer;
begin
  Assert(Assigned(CheckList));
  for I := 0 to CheckList.Items.Count - 1 do
  begin
    case Action of
      chAll: CheckList.Checked[I] := True;
      chNone: CheckList.Checked[I] := False;
      chInvert: CheckList.Checked[I] := not CheckList.Checked[I];
    end;
  end;
end;

procedure TCnProjectDelTempForm.FormCreate(Sender: TObject);
begin
  FAbort := True;
  CheckButton;
end;

procedure TCnProjectDelTempForm.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    chklstExtensions.Items.CommaText :=
      Ini.ReadString(csDelTemp, csCleanExtList, SCnProjExtDefaultCleanExts);
    List.CommaText :=
      Ini.ReadString(csDelTemp, csSelExeList, SCnProjExtDefaultCleanExts);
    for I := 0 to chklstExtensions.Items.Count - 1 do
      chklstExtensions.Checked[I] := List.IndexOf(chklstExtensions.Items[I]) >= 0;
  finally
    List.Free;
  end;

  cbbSelectType.ItemIndex := Ini.ReadInteger(csDelTemp, csSelectType, 0);
  FillProjectDirectoriesList;
  FCheckSource := Ini.ReadBool(csDelTemp, csCheckSource, True);
  FCheckDirs := Ini.ReadBool(csDelTemp, csCheckDirs, False);
end;

procedure TCnProjectDelTempForm.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
  List: TStrings;
begin
  List := TStringList.Create;
  try
    Ini.WriteString(csDelTemp, csCleanExtList, chklstExtensions.Items.CommaText);
    for I := 0 to chklstExtensions.Items.Count - 1 do
      if chklstExtensions.Checked[I] then
        List.Add(chklstExtensions.Items[I]);
    Ini.WriteString(csDelTemp, csSelExeList, List.CommaText);
  finally
    List.Free;
  end;

  Ini.WriteInteger(csDelTemp, csSelectType, cbbSelectType.ItemIndex);
  Ini.WriteBool(csDelTemp, csCheckSource, FCheckSource);
  Ini.WriteBool(csDelTemp, csCheckDirs, FCheckDirs);
end;

procedure TCnProjectDelTempForm.FillProjectDirectoriesList;
var
  Strings: TStrings;

  procedure AddPathToStrings(const Path: string);
  begin
    if Trim(Path) = '' then
      Exit;
    if Strings.IndexOf(Path) = -1 then
      Strings.Add(Path);
  end;
  
  procedure AddProjectDir(Project: IOTAProject; const OptionName: string);
  var
    Directory: string;
    ProjectDir, S: string;
  begin
    S := '';
    if Project.ProjectOptions <> nil then
      S := VarToStr(Project.ProjectOptions.GetOptionValue(OptionName));

    if S = '' then
      S := CnOtaGetProjectCurrentBuildConfigurationValue(nil, OptionName);

    if S <> '' then
    begin
      Directory := ReplaceToActualPath(S, Project);
      ProjectDir := _CnExtractFileDir(Project.FileName);
      if Trim(Directory) <> '' then
      begin
        Directory := LinkPath(ProjectDir, Directory);
        if DirectoryExists(Directory) then
          AddPathToStrings(Directory);
      end;
    end;
  end;

  procedure AddProjectToList(Project: IOTAProject; NeedBin: Boolean);
  var
    I: Integer;
    ModuleInfo: IOTAModuleInfo;
    TempPathString: string;
  begin
    AddPathToStrings(_CnExtractFileDir(Project.FileName));
    for I := 0 to Project.GetModuleCount - 1 do
    begin
      ModuleInfo := Project.GetModule(I);
      Assert(Assigned(ModuleInfo));
      TempPathString := _CnExtractFileDir(ModuleInfo.FileName);
      AddPathToStrings(TempPathString);
    end;

    if NeedBin then
    begin
      TempPathString := CnOtaGetProjectOutputDirectory(Project);
      if DirectoryExists(TempPathString) then
        AddPathToStrings(TempPathString);

      TempPathString := GetProjectDcuPath(Project);
      if DirectoryExists(TempPathString) then
        AddPathToStrings(TempPathString);

      AddProjectDir(Project, 'PkgDcpDir');
    end;
  end;

var
  I: Integer;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  ProjectInterfaceList: TInterfaceList;
begin
  chklstDirs.Clear;
  Strings := chklstDirs.Items;
  Strings.BeginUpdate;
  try
    case cbbSelectType.ItemIndex of
      0, 1:
        begin
          Project := CnOtaGetCurrentProject;
          if not Assigned(Project) then
            Exit;
          AddProjectToList(Project, cbbSelectType.ItemIndex = 1);
        end;
      2, 3:
        begin
          ProjectGroup := CnOtaGetProjectGroup;
          if not Assigned(ProjectGroup) then
            Exit;

          ProjectInterfaceList := TInterfaceList.Create;
          try
            CnOtaGetProjectList(ProjectInterfaceList);

            for I := 0 to ProjectInterfaceList.Count - 1 do
            begin
              Project := IOTAProject(ProjectInterfaceList[I]);
{$IFDEF BDS}
              // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
              if Supports(Project, IOTAProjectGroup, ProjectGroup) then
                Continue;
{$ENDIF}
              AddProjectToList(Project, cbbSelectType.ItemIndex = 3);
            end;
          finally
            ProjectInterfaceList.Free;
          end;
        end;
    end;
  finally
    Strings.EndUpdate;
  end;

  ListboxHorizontalScrollbar(chklstDirs);
end;

procedure TCnProjectDelTempForm.UpdateControls;
begin
  btnRemove.Enabled := (chklstDirs.ItemIndex > -1)
    and (chklstDirs.Items.Count > 0);
  btnRemoveExt.Enabled := (chklstExtensions.ItemIndex > -1)
    and (chklstExtensions.Items.Count > 0);
end;

procedure TCnProjectDelTempForm.btnAddClick(Sender: TObject);
var
  Temp: string;
  Index: Integer;
begin
  Temp := '';
  if GetDirectory(SCnSelectDir, Temp) and (chklstDirs.Items.IndexOf(Temp) < 0) then
  begin
    Index := chklstDirs.Items.Add(Temp);
    chklstDirs.Checked[Index] := True;
    cbbSelectType.ItemIndex := -1;
    ListboxHorizontalScrollbar(chklstDirs);
  end;
end;

procedure TCnProjectDelTempForm.btnRemoveClick(Sender: TObject);
var
  I: Integer;
  OldIndex: Integer;
begin
  I := 0;
  OldIndex := chklstDirs.ItemIndex;
  while I <= chklstDirs.Items.Count - 1 do
  begin
    if chklstDirs.Selected[I] then
      chklstDirs.Items.Delete(I)
    else
      Inc(I);
  end;
  if (OldIndex > -1) and (chklstDirs.Items.Count > 0) then
    chklstDirs.ItemIndex := Min(OldIndex, chklstDirs.Items.Count - 1);
    
  UpdateControls;
  cbbSelectType.ItemIndex := -1;
end;

procedure TCnProjectDelTempForm.btnAddExtClick(Sender: TObject);
var
  NewExt: string;
  Idx: Integer;
begin
  if CnWizInputQuery(SCnProjExtAddExtension, SCnProjExtAddNewText, NewExt) then
  begin
    if chklstExtensions.Items.IndexOf(NewExt) < 0 then
    begin
      if NewExt[1] = '*' then
        Delete(NewExt, 1, 1);
      if not (NewExt[1] = '.') then
        NewExt := '.' + NewExt;
      Idx := chklstExtensions.Items.Add(NewExt);
      chklstExtensions.Checked[Idx] := True;
    end;
  end;
end;

procedure TCnProjectDelTempForm.btnRemoveExtClick(Sender: TObject);
var
  I: Integer;
begin
  I := chklstExtensions.ItemIndex;
  if I < 0 then
    Exit;

  chklstExtensions.Checked[I] := False;
  chklstExtensions.Items.Delete(I);

  UpdateControls;
end;

procedure TCnProjectDelTempForm.CheckButton;
begin
  btnPrio.Enabled := not (nb.ActivePage = 'DelCondition');
  btnNext.Enabled := not btnPrio.Enabled;
end;

procedure TCnProjectDelTempForm.btnPrioClick(Sender: TObject);
begin
  nb.ActivePage := 'DelCondition';
  CheckButton;
end;

procedure TCnProjectDelTempForm.btnNextClick(Sender: TObject);
begin
  nb.ActivePage := 'DelList';
  CheckButton;
  GetDelFile;
end;

procedure TCnProjectDelTempForm.CheckActionExecute(Sender: TObject);
begin
  if Sender = actDirsCheckAll then
    SetListBoxChecked(chklstDirs, chAll)
  else if Sender = actDirsUncheckAll then
    SetListBoxChecked(chklstDirs, chNone)
  else if Sender = actDirsInvert then
    SetListBoxChecked(chklstDirs, chInvert)
  else if Sender = actExtsCheckAll then
    SetListBoxChecked(chklstExtensions, chAll)
  else if Sender = actExtsUncheckAll then
    SetListBoxChecked(chklstExtensions, chNone)
  else if Sender = actExtsInvert then
    SetListBoxChecked(chklstExtensions, chInvert);
end;

procedure TCnProjectDelTempForm.chklstDirsClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TCnProjectDelTempForm.chklstDirsKeyPress(Sender: TObject;
  var Key: Char);
begin
  UpdateControls;
end;

procedure TCnProjectDelTempForm.chklstExtensionsClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TCnProjectDelTempForm.chklstExtensionsKeyPress(Sender: TObject;
  var Key: Char);
begin
  UpdateControls;
end;

procedure TCnProjectDelTempForm.DeleteFoundFileOrDir(const FileName: string);
var
  TempFileSize: Integer;
  FS: TStringList;
  I: Integer;
begin
  if DirectoryExists(FileName) then
  begin
    // 是目录，先统计目录里文件大小，暂不递归搜索子目录，但删除会全删
    FS := TStringList.Create;
    try
      GetDirFiles(FileName, FS);
      for I := 0 to FS.Count - 1 do
      begin
        TempFileSize := GetFileSize(MakePath(FileName) + FS[I]);
        if DeleteFile(MakePath(FileName) + FS[I]) then
        begin
          Inc(FTotalFilesCleaned);
          FTotalBytesCleaned := FTotalBytesCleaned + TempFileSize;
        end;
      end;
      RemoveDir(FileName);
    finally
      FS.Free;
    end;
  end
  else
  begin
    TempFileSize := GetFileSize(FileName);
    if DeleteFile(FileName) then
    begin
      Inc(FTotalFilesCleaned);
      FTotalBytesCleaned := FTotalBytesCleaned + TempFileSize;
    end;
  end;
end;

procedure TCnProjectDelTempForm.GetDelFile;
var
  I: Integer;

  procedure CheckDirAndAdd(const Dir: string);
  var
    Index: Integer;
  begin
    if DirectoryExists(Dir) then
    begin
      Index := chklstFileList.Items.Add(Dir);
      chklstFileList.Checked[Index] := True;
    end;
  end;

begin
  FTotalBytesCleaned := 0;
  FTotalFilesCleaned := 0;
  chklstFileList.Items.Clear;
  FAbort := False;
  btnFinish.Enabled := False;
  btnNext.Enabled := False;
  btnPrio.Enabled := False;

  CleanExtList := TStringList.Create;
  try
    for I := 0 to chklstExtensions.Items.Count - 1 do
      if chklstExtensions.Checked[I] then
        CleanExtList.Add(chklstExtensions.Items[I]);

    for I := 0 to chklstDirs.Items.Count - 1 do
    begin
      FindFile(chklstDirs.Items[I], '*.*', DoFindFile, nil, chklstDirs.Checked[I]);

      if chkRemoveHistory.Checked then
      begin
        CheckDirAndAdd(MakePath(chklstDirs.Items[I]) + csDelHistory);
        CheckDirAndAdd(MakePath(chklstDirs.Items[I]) + csDelRecovery);
      end;
    end;
  finally
    FreeAndNil(CleanExtList);
    FAbort := True;
    btnFinish.Enabled := True;
    CheckButton;
  end;
end;

procedure TCnProjectDelTempForm.DoFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  I: Integer;
  Index: Integer;
  Ext: string;
  ToDelete: Boolean;
begin
  Abort := FAbort;
  if Abort then
    Exit;

  for I := 0 to CleanExtList.Count - 1 do
  begin
    ToDelete := True;
    if WildcardCompare('*' + CleanExtList.Strings[I], Info.Name) then
    begin
      if chklstFileList.Items.IndexOf(FileName) < 0 then
      begin
        Ext := UpperCase(_CnExtractFileExt(FileName));
        if FCheckSource and ((Ext = '.DCU') or (Ext = '.OBJ')) then
        begin
          ToDelete := False;

          // 如果待清理的目标文件无对应源文件，则不删除
          if FileExists(_CnChangeFileExt(FileName, '.pas')) then
            ToDelete := True
          else if FileExists(_CnChangeFileExt(FileName, '.cpp')) then
            ToDelete := True
          else if FileExists(_CnChangeFileExt(FileName, '.c')) then
            ToDelete := True;
        end;

        if ToDelete then
        begin
          Index := chklstFileList.Items.Add(FileName);
          chklstFileList.Checked[Index] := True;
        end;
      end;
      Exit;
    end;
  end;
end;

procedure TCnProjectDelTempForm.btnCancelClick(Sender: TObject);
begin
  if not FAbort then
  begin
    if QueryDlg(SCnQueryAbort) then
      FAbort := True
  end
  else
    ModalResult := mrCancel;
end;

procedure TCnProjectDelTempForm.btnFinishClick(Sender: TObject);
var
  I: Integer;
begin
  if btnNext.Enabled then
    GetDelFile;
  for I := 0 to chklstFileList.Items.Count - 1 do
  begin
    if chklstFileList.Checked[I] then
      DeleteFoundFileOrDir(chklstFileList.Items.Strings[I]);
  end;
  if FTotalFilesCleaned > 0 then
    InfoDlg(Format(SCnProjExtCleaningComplete,
      [FTotalFilesCleaned, IntToStrSp(FTotalBytesCleaned)]));
end;

procedure TCnProjectDelTempForm.btnDefaultClick(Sender: TObject);
begin
  chklstExtensions.Items.CommaText := SCnProjExtDefaultCleanExts;
  SetListBoxChecked(chklstExtensions, chAll);
end;

procedure TCnProjectDelTempForm.cbbSelectTypeChange(Sender: TObject);
begin
  FillProjectDirectoriesList;
end;

function TCnProjectDelTempForm.GetHelpTopic: string;
begin
  Result := 'CnProjectExtDelTemp';
end;

procedure TCnProjectDelTempForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnProjectDelTempForm.SetCheckSource(const Value: Boolean);
begin
  FCheckSource := Value;
end;

procedure TCnProjectDelTempForm.SetCheckDirs(const Value: Boolean);
begin
  FCheckDirs := Value;
end;

procedure TCnProjectDelTempForm.chkCheckSourceClick(Sender: TObject);
begin
  CheckSource := chkCheckSource.Checked;
end;

procedure TCnProjectDelTempForm.btnSelAllDirsClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to chklstDirs.Items.Count - 1 do
    chklstDirs.Checked[I] := True;
end;

procedure TCnProjectDelTempForm.btnSelAllExtsClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to chklstExtensions.Items.Count - 1 do
    chklstExtensions.Checked[I] := True;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
