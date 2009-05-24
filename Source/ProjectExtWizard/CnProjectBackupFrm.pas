{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnProjectBackupFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：项目备份单元
* 单元作者：何清 (qsoft@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnProjectBackupFrm.pas,v 1.40 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2008.06.20 V1.1 by LiuXiao
*               加入备份后运行命令的机制
*           2006.08.19 V1.3 by LiuXiao
*               工程备份完善保存密码的功能
*           2005.01.10 V1.2 by 何清
*               1. 使用TObjectList来预加载文件列表，提高加载速度
*           2005.01.09 V1.1 by 何清
*               1. 文件列表使用系统文件图标
*               2. 支持全部工程、当前活动工程和特定工程项目备份选择
*               3. 修正一处工程文件两次添加的Bug
*           2004.12.31 V1.0 by 何清
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$IFDEF SUPPORT_PRJ_BACKUP}

uses
  Windows, SysUtils, Messages, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, CheckLst, IniFiles, Menus, ActnList, FileCtrl, CnCommon,
  CnWizConsts, CnWizMultiLang, ComCtrls, ToolWin, ToolsAPI, ShellAPI, CommCtrl,
  contnrs, Dialogs, AbBase, AbBrowse, AbZBrows, AbZipper, AbArcTyp,
  CnLangTranslator, CnLangMgr, CnLangStorage, CnHashLangStorage;

type

  { TCnBackupFileInfo }

  TCnBackupFileInfo = class
  private
    FCustomFile: Boolean;
    FName: string;
    FPath: string;
    FSize: Integer;
    FHidden: Boolean;

    function GetFullFileName: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetFileInfo(FileName: string; ACustomFile: Boolean = False);

    property CustomFile: Boolean read FCustomFile write FCustomFile;
    property Name: string read FName write FName;
    property Path: string read FPath write FPath;
    property FullFileName: string read GetFullFileName;
    property Size: Integer read FSize write FSize;
    property Hidden: Boolean read FHidden write FHidden;
  end;

  { TCnBackupProjectInfo }

  TCnBackupProjectInfo = class(TCnBackupFileInfo)
  private
    FInfoList: TObjectList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TCnBackupFileInfo;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(FileInfo: TCnBackupFileInfo);
    procedure Delete(Index: Integer);
    procedure AddFiles(FileName, UnitName, FormName: string);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCnBackupFileInfo read GetItem;
  end;

  { TCnBackupProjectList }

  TCnBackupProjectList = class(TCnBackupFileInfo)
  private
    FProjectList: TObjectList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TCnBackupProjectInfo;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(ProjectInfo: TCnBackupProjectInfo);
    procedure Delete(Index: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCnBackupProjectInfo read GetItem;
  end;

  TCnProjectBackupForm = class(TCnTranslateForm)
    statMain: TStatusBar;
    lvFileView: TListView;
    actlstMain: TActionList;
    actAddFile: TAction;
    actRemoveFile: TAction;
    actClose: TAction;
    actHelp: TAction;
    tlbMain: TToolBar;
    btnAddFile: TToolButton;
    btnRemoveFile: TToolButton;
    btnSprt1: TToolButton;
    btnHelp: TToolButton;
    btnClose: TToolButton;
    pnlTool: TPanel;
    lblProjects: TLabel;
    cbbProjectList: TComboBox;
    btnZip: TToolButton;
    btn1: TToolButton;
    actZip: TAction;
    dlgOpen: TOpenDialog;
    procedure actCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbProjectListChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvFileViewCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actZipExecute(Sender: TObject);
    procedure actRemoveFileExecute(Sender: TObject);
    procedure actAddFileExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure lvFileViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    CustomFiles: TCnBackupProjectInfo;
    ProjectList: TCnBackupProjectList;
    FExt: string;

    FRemovePath: Boolean;
    FUsePassword: Boolean;
    FRememberPass: Boolean;
    FPassword: string;
    FSavePath: string;
    FCurrentName: string;
    FTimeFormatIndex: Integer;
    FUseExternal: Boolean;
    FCompressor: string;
    FCompressCmd: string;
    FExecCmdAfterBackup: Boolean;
    FExecCmdFile: string;
    FExecCmdString: string;

    procedure OnAppMessage(var Msg: Tmsg; var Handled: Boolean);
    procedure CreateProjectList;
    procedure InitComboBox;
    procedure UpdateStatusBar;
    procedure AddBackupFile(const ProjectName: string; FileInfo: TCnBackupFileInfo);
    procedure AddBackupFiles(ProjectInfo: TCnBackupProjectInfo);
    procedure UpdateBackupFileView(ProjectName: string);
    function FindBackupFile(const FileName: string): Integer;

    procedure SimpleDecode(var Pass: string);
    procedure SimpleEncode(var Pass: string);
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
  end;

var
  CnProjectBackupForm: TCnProjectBackupForm;

function ShowProjectBackupForm(Ini: TCustomIniFile): Boolean;

function GetFileIconIndex(FileName: string): Integer;

{$ENDIF SUPPORT_PRJ_BACKUP}

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$IFDEF SUPPORT_PRJ_BACKUP}

{$R *.DFM}

uses
{$IFDEF DEBUG} CnDebug, {$ENDIF}
{$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  CnWizOptions, CnWizUtils,
  CnWizShareImages, CnProjectBackupSaveFrm, CnWizNotifier;

const
  csBackupSection = 'ProjectBackup';
  csRemovePath = 'RemovePath';
  csUsePassword = 'UsePassword';
  csSavePath = 'SavePath';
  csRememberPass = 'RememberPass';
  csZipPass = 'ZipPass';
  csTimeFormatIndex = 'TimeFormatIndex';
  
  csUseExternal = 'UseExternal';
  csCompressor = 'Compressor';
  csCompressCmd = 'CompressCmd';
  csExecCmdAfterBackup = 'ExecCmdAfterBackup';
  csExecCmdFile = 'ExecCmdFile';
  csExecCmdString = 'ExecCmdString';

const
  csCmdCompress = '<compress.exe>';
  csCmdBackupFile = '<BackupFile>';
  csVersionInfo = '<VersionInfo>';
  csCmdListFile = '<ListFile>';
  csCmdPassword = '<Password>';
  csAfterCmd = '<externfile.exe>';

function ShowProjectBackupForm(Ini: TCustomIniFile): Boolean;
begin
  with TCnProjectBackupForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    LoadSettings(Ini);
    Result := ShowModal = mrOK;
    SaveSettings(Ini);
  finally
    Free;
  end;
end;

{ 由文件名或路径名获取系统图标列表的索引号 }
function GetFileIconIndex(FileName: string): Integer;
var
  FileInfo: TSHFileInfo;
begin
  ShGetFileInfo(PChar(FileName), 0, FileInfo, SizeOf(FileInfo),
    SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_TYPENAME);

  Result := FileInfo.iIcon; { 返回获取的图标序号 }
end;

//==============================================================================
// 工程信息类
//==============================================================================

constructor TCnBackupFileInfo.Create;
begin  
  inherited Create;

  FCustomFile := False;
  FName := '';
  FPath := '';
  FSize := 0;
end;

destructor TCnBackupFileInfo.Destroy;
begin

  inherited Destroy;
end;
   
function TCnBackupFileInfo.GetFullFileName: string;
begin
  Result := FPath + FName;
end;

procedure TCnBackupFileInfo.SetFileInfo(FileName: string; ACustomFile: Boolean = False);
begin
  FCustomFile := ACustomFile;
  FName := ExtractFileName(FileName);
  FPath := ExtractFilePath(FileName);
  FSize := GetFileSize(FileName);
end;

{ TCnBackupProjectInfo }

constructor TCnBackupProjectInfo.Create;
begin
  inherited Create;
  FInfoList := TObjectList.Create;
end;

destructor TCnBackupProjectInfo.Destroy;
begin
  FreeAndNil(FInfoList);
  inherited Destroy;
end;

procedure TCnBackupProjectInfo.Add(FileInfo: TCnBackupFileInfo);
begin
  FInfoList.Add(FileInfo);
end;

procedure TCnBackupProjectInfo.AddFiles(FileName, UnitName, FormName: string);
var
  TempFileName: string;

  function AddFile(FileName: string): Boolean;
  var
    FileInfo: TCnBackupFileInfo;
  begin
    Result := False;
    if not FileExists(FileName) then
      Exit;

    FileInfo := TCnBackupFileInfo.Create;
    FileInfo.SetFileInfo(FileName);
    Add(FileInfo);

    Result := True;
  end;
begin
  // 不备份 DCP/BPI/DLL 文件
  TempFileName := ExtractUpperFileExt(FileName);
  if (TempFileName = '.DCP') or (TempFileName = '.BPI') or (TempFileName = '.DLL') then
    Exit;

  AddFile( FileName );

  // 加入 cpp 文件对应的 h/hpp/bpr/bpk
  if TempFileName = '.CPP' then
  begin
    AddFile(ChangeFileExt(FileName, '.h'));
    AddFile(ChangeFileExt(FileName, '.hpp'));
    AddFile(ChangeFileExt(FileName, '.bpr'));
    AddFile(ChangeFileExt(FileName, '.bpk'));
  end;

  // 加入其他文件
  AddFile(ChangeFileExt(FileName, '.dfm'));
  AddFile(ChangeFileExt(FileName, '.xfm'));
  AddFile(ChangeFileExt(FileName, '.nfm'));
  AddFile(ChangeFileExt(FileName, '.todo'));
  AddFile(ChangeFileExt(FileName, '.tlb'));
end;

function TCnBackupProjectInfo.GetCount: Integer;
begin
  Result := FInfoList.Count;
end;

function TCnBackupProjectInfo.GetItem(Index: Integer): TCnBackupFileInfo;
begin
  Result := TCnBackupFileInfo(FInfoList.Items[Index]);
end;

procedure TCnBackupProjectInfo.Delete(Index: Integer);
begin
  FInfoList.Delete(Index);
end;

{ TCnBackupProjectList }

constructor TCnBackupProjectList.Create;
begin
  inherited Create;
  FProjectList := TObjectList.Create;
end;

destructor TCnBackupProjectList.Destroy;
begin
  FreeAndNil(FProjectList);
  inherited Destroy;
end;

procedure TCnBackupProjectList.Add(ProjectInfo: TCnBackupProjectInfo);
begin
  FProjectList.Add(ProjectInfo);
end;

function TCnBackupProjectList.GetCount: Integer;
begin
  Result := FProjectList.Count;
end;

function TCnBackupProjectList.GetItem(Index: Integer): TCnBackupProjectInfo;
begin
  Result := TCnBackupProjectInfo(FProjectList.Items[index]);
end;
 
//==============================================================================
// 工程备份主窗口类
//==============================================================================

procedure TCnBackupProjectList.Delete(Index: Integer);
begin
  FProjectList.Delete(Index);
end;

{ TCnProjectBackupForm }

procedure TCnProjectBackupForm.FormCreate(Sender: TObject);
var
  hImgList: THandle;
  FileInfo: TSHFileInfo;
begin
  inherited;
  Screen.Cursor := crHourGlass;
  try
    ProjectList := TCnBackupProjectList.Create;
    CustomFiles := TCnBackupProjectInfo.Create;

    { 获取系统图标列表 }
    hImgList := SHGetFileInfo('C:\', 0, FileInfo, SizeOf(FileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SendMessage(lvFileView.Handle, LVM_SETIMAGELIST, LVSIL_SMALL, hImgList);

    CreateProjectList;
    InitComboBox;

    // 备份文件视图支持一自外部的文件拖放
    DragAcceptFiles(lvFileView.Handle, True);
    CnWizNotifierServices.AddApplicationMessageNotifier(OnAppMessage);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCnProjectBackupForm.FormDestroy(Sender: TObject);
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnAppMessage);
  FreeAndNil(ProjectList);
  FreeAndNil(CustomFiles);
  inherited;
end;

procedure TCnProjectBackupForm.LoadSettings(Ini: TCustomIniFile);
begin
  FUsePassword := Ini.ReadBool(csBackupSection, csUsePassword, False);
  FRememberPass := Ini.ReadBool(csBackupSection, csRememberPass, False);
  FRemovePath := Ini.ReadBool(csBackupSection, csRemovePath, False);
  FSavePath := Ini.ReadString(csBackupSection, csSavePath, '');
  FTimeFormatIndex := Ini.ReadInteger(csBackupSection, csTimeFormatIndex, 0);
  FPassword := Ini.ReadString(csBackupSection, csZipPass, '');
  FUseExternal := Ini.ReadBool(csBackupSection, csUseExternal, False);
  FCompressor := Ini.ReadString(csBackupSection, csCompressor, '');
  FCompressCmd := Ini.ReadString(csBackupSection, csCompressCmd, '');
  FExecCmdAfterBackup := Ini.ReadBool(csBackupSection, csExecCmdAfterBackup, False);
  FExecCmdFile := Ini.ReadString(csBackupSection, csExecCmdFile, '');
  FExecCmdString := Ini.ReadString(csBackupSection, csExecCmdString, '');
  try
    SimpleDecode(FPassword);
  except
    FPassword := '';
  end;
end;

procedure TCnProjectBackupForm.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csBackupSection, csUsePassword, FUsePassword);
  Ini.WriteBool(csBackupSection, csRememberPass, FRememberPass);
  Ini.WriteBool(csBackupSection, csRemovePath, FRemovePath);
  Ini.WriteString(csBackupSection, csSavePath, FSavePath);
  Ini.WriteInteger(csBackupSection, csTimeFormatIndex, FTimeFormatIndex);
  Ini.WriteBool(csBackupSection, csUseExternal, FUseExternal);
  Ini.WriteString(csBackupSection, csCompressor, FCompressor);
  Ini.WriteString(csBackupSection, csCompressCmd, FCompressCmd);
  Ini.WriteBool(csBackupSection, csExecCmdAfterBackup, FExecCmdAfterBackup);
  Ini.WriteString(csBackupSection, csExecCmdFile, FExecCmdFile);
  Ini.WriteString(csBackupSection, csExecCmdString, FExecCmdString);
  if FRememberPass then
  begin
    try
      SimpleEncode(FPassword);
    except
      FPassword := '';
    end;
    Ini.WriteString(csBackupSection, csZipPass, FPassword);
  end
  else
    Ini.WriteString(csBackupSection, csZipPass, '');
end;

function TCnProjectBackupForm.GetHelpTopic: string;
begin
  Result := 'CnProjectBackup';
end;

function TCnProjectBackupForm.FindBackupFile(const FileName: string): Integer;
var
  i: Integer;
  FileInfo: TCnBackupFileInfo;
begin
  for i := 0 to lvFileView.Items.Count - 1 do
  begin
    FileInfo := TCnBackupFileInfo(lvFileView.Items[i].Data);
    if CompareText(FileName, FileInfo.FullFileName) = 0 then
    begin
      Result := i;
      Exit;
    end;
  end;

  Result := -1;
end;

procedure TCnProjectBackupForm.OnAppMessage(var Msg: Tmsg; var Handled: Boolean);
var
  DroppedFilename: string;
  FileIndex: UINT;
  QtyDroppedFiles: UINT;
  pDroppedFilename: PChar;
  BufferLength, DroppedFileLength: UINT;
  FileInfo: TCnBackupFileInfo;
begin
  if Msg.Message = WM_DROPFILES then
  begin
    BufferLength := 0;
    pDroppedFilename := Nil;

    // 取当前拖放的文件数
    FileIndex := $FFFFFFFF;
    QtyDroppedFiles := DragQueryFile(Msg.WParam, FileIndex,
                                     pDroppedFilename, BufferLength);
    for FileIndex := 0 to (QtyDroppedFiles - 1) do
    begin
      // 先计算文件名所需内存大小
      DroppedFileLength := DragQueryFile(Msg.WParam, FileIndex, Nil, 0);

      // 内存不足时需要重新分配内存
      if (DroppedFileLength > BufferLength) then
      begin
        if (pDroppedFilename <> nil) then
          FreeMem(pDroppedFilename);
        BufferLength := DroppedFileLength + 1;
        GetMem(pDroppedFilename, BufferLength );
      end;

      DragQueryFile(Msg.WParam, FileIndex, pDroppedFilename, BufferLength);

      DroppedFilename := StrPas(pDroppedFilename);

      //TODO: 暂时不支持目录拖放，将在之后版本中给予支持...
      if DirectoryExists( DroppedFilename ) then
        Continue;
        
      if FindBackupFile(DroppedFilename) <> -1 then // 文件已经被加入到视图中
        Continue;

      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo( DroppedFilename, True );
      CustomFiles.Add( FileInfo );

      AddBackupFile( SCnProjExtCustomBackupFile, FileInfo );
    end;

    DragFinish(Msg.WParam);
    if (pDroppedFilename <> nil) then
      FreeMem(pDroppedFilename);

    UpdateStatusBar; // 更新状态条显示

    Handled := True;
  end;
end;

procedure TCnProjectBackupForm.CreateProjectList;
var
  ProjectInfo: TCnBackupProjectInfo;

  FileName: string;
  IProjectGroup: IOTAProjectGroup;
  IProject: IOTAProject;
  IModuleInfo: IOTAModuleInfo;
  IEditor: IOTAEditor;
  i, j: Integer;
  ProjectInterfaceList: TInterfaceList;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnProjectBackupForm.CreateProjectList');
{$ENDIF DEBUG}

  IProjectGroup := CnOtaGetProjectGroup;
  if IProjectGroup = nil then
    Exit;

  FileName := CnOtaGetProjectGroupFileName;
  if FileExists(FileName) then
    ProjectList.SetFileInfo(FileName);

  ProjectInterfaceList := TInterfaceList.Create;
  try
    CnOtaGetProjectList(ProjectInterfaceList);

    for I := 0 to ProjectInterfaceList.Count - 1 do
    begin
      IProject := IOTAProject(ProjectInterfaceList[I]);
      if (IProject = nil) then
        Continue;

{$IFDEF BDS}
      // BDS 后，ProjectGroup 也支持 Project 接口，因此需要去掉
      if Supports(IProject, IOTAProjectGroup, ProjectGroup) then
        Continue;
{$ENDIF}

      ProjectInfo := TCnBackupProjectInfo.Create;
      ProjectInfo.SetFileInfo(IProject.FileName);
      ProjectList.Add(ProjectInfo);

      for J := 0 to IProject.GetModuleFileCount - 1 do
      begin
        IEditor := IProject.GetModuleFileEditor(J);
        Assert(IEditor <> nil);

        FileName := IEditor.FileName;
        if FileName <> '' then
          ProjectInfo.AddFiles(IEditor.FileName, '', '');
      end;

      for J := 0 to IProject.GetModuleCount - 1 do
      begin
        IModuleInfo := IProject.GetModule(J);
        Assert(IModuleInfo <> nil);

        FileName := IModuleInfo.FileName;
        if FileName <> '' then
          ProjectInfo.AddFiles(IModuleInfo.FileName, '', IModuleInfo.FormName);
      end;
    end;
  finally
    ProjectInterfaceList.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnProjectBackupForm.CreateProjectList');
{$ENDIF DEBUG}
end;

procedure TCnProjectBackupForm.InitComboBox;
var
  ProjectInfo: TCnBackupProjectInfo;
  i: Integer;
begin
  cbbProjectList.Clear;

  cbbProjectList.Items.Add(SCnProjExtProjectAll);
  cbbProjectList.Items.Add(SCnProjExtCurrentProject);

  for i := 0 to ProjectList.Count - 1 do
  begin
    ProjectInfo := ProjectList.Items[i];
    cbbProjectList.Items.Add(ProjectInfo.Name);
  end;

  cbbProjectList.ItemIndex := 0;
  cbbProjectListChange(nil); // 更新备份文件列表
end;

procedure TCnProjectBackupForm.UpdateStatusBar;
begin
  with statMain do
  begin
    Panels[1].Text := Format(SCnProjExtProjectCount,
      [cbbProjectList.Items.Count - 2]);

    if cbbProjectList.Text = '' then
      Panels[2].Text := ''
    else
      Panels[2].Text := Format(SCnProjExtBackupFileCount,
        [cbbProjectList.Text, lvFileView.Items.Count]);
  end;
end;

procedure TCnProjectBackupForm.AddBackupFile(const ProjectName: string;
  FileInfo: TCnBackupFileInfo);
begin
  if (FileInfo.Name = '') or FileInfo.Hidden then
    Exit;

  // 该文件是否已经被添中到备份文件视图中，因为一个文件可能存在于多个工程中，
  // 所以在TCnProjectInfo中可能保存多个同名文件，该步处理是非常有必要的！
  if FindBackupFile( FileInfo.FullFileName ) <> -1 then
    Exit;

  with lvFileView.Items.Add do
  begin
    Caption := FileInfo.Name;
    SubItems.Add(ProjectName);
    SubItems.Add(FileInfo.Path);
    SubItems.Add(IntToStrSp(FileInfo.Size));
    Data := FileInfo;
    ImageIndex := GetFileIconIndex(FileInfo.FullFileName);
  end;
end;

procedure TCnProjectBackupForm.AddBackupFiles(ProjectInfo: TCnBackupProjectInfo);
var
  i: Integer;
begin
  { 对于用户自添加的文件列表，则Name值为空 }
  if (ProjectInfo.Name <> '') then
    AddBackupFile(ProjectInfo.Name, ProjectInfo);

  for i := 0 to ProjectInfo.Count - 1 do
    AddBackupFile(ProjectInfo.Name, ProjectInfo.Items[i]);
end;

{ 该函数由 GExperts 移植而来 }

procedure TCnProjectBackupForm.UpdateBackupFileView(ProjectName: string);
var
  IProjectGroup: IOTAProjectGroup;
  IProject: IOTAProject;
  I: Integer;
begin
  lvFileView.Items.BeginUpdate;
  try
    lvFileView.Items.Clear;

    if (ProjectName = SCnProjExtProjectAll) then // 备份全部的工程项
    begin
      IProjectGroup := CnOtaGetProjectGroup;
      if (IProjectGroup <> nil) and (IProjectGroup.ProjectCount > 1) then
        FCurrentName := CnOtaGetProjectGroupFileName
      else
        FCurrentName := CnOtaGetCurrentProjectFileName;

      AddBackupFile(ProjectList.Name, ProjectList);
      for I := 0 to ProjectList.Count - 1 do
        AddBackupFiles( ProjectList.Items[I] );
    end
    else
    begin
      if (ProjectName = SCnProjExtCurrentProject) then  // 备份当前工程项
      begin
        IProject := CnOtaGetCurrentProject;
        if (IProject = nil) then
          Exit;

        ProjectName := ExtractFileName(IProject.FileName);
        FCurrentName := ProjectName;
      end;

      for I := 0 to ProjectList.Count - 1 do
      begin
        if (CompareText(ProjectList.Items[i].Name, ProjectName) = 0) then
        begin
          FCurrentName := ProjectName;
          AddBackupFiles(ProjectList.Items[I]);
        end;
      end;
    end;

    // 添加用户自选备份文件组
    AddBackupFiles(CustomFiles);
  finally
    lvFileView.Items.EndUpdate;
  end;
end;

procedure TCnProjectBackupForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnProjectBackupForm.cbbProjectListChange(Sender: TObject);
begin
  UpdateBackupFileView(cbbProjectList.Text);
  UpdateStatusBar;
end;

procedure TCnProjectBackupForm.lvFileViewCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  FileInfo: TCnBackupFileInfo;
begin
  if Item = nil then
    Exit;

  FileInfo := TCnBackupFileInfo(Item.Data);
  if CnOtaIsFileOpen(FileInfo.FullFileName) then
  begin
    if FileInfo.CustomFile then // 对于打开的自选备份文件，显示为红色
      Sender.Canvas.Font.Color := clRed
    else
      Sender.Canvas.Font.Color := clGreen;
  end
  else
  begin
    if FileInfo.CustomFile then // 对于未打开的自选备份文件，显示为蓝色
      Sender.Canvas.Font.Color := clBlue
  end;
end;

procedure TCnProjectBackupForm.actZipExecute(Sender: TObject);
var
  I: Integer;
  Zip: TAbZipper;
  CompressorCommand, ListFileName, ExecCommand, VerStr: string;
  List: TStrings;
  Options: IOTAProjectOptions;
begin
  if lvFileView.Items.Count = 0 then
  begin
    ErrorDlg(SCnProjExtBackupNoFile);
    Exit;
  end;

  with TCnProjectBackupSaveForm.Create(nil) do
  begin
    RemovePath := FRemovePath;
    RememberPass := FRememberPass;
    UsePassword := FUsePassword;
    UseExternal := FUseExternal;
    Compressor := FCompressor;
    CompressCmd := FCompressCmd;
    ExecAfterFile := FExecCmdFile;
    ExecAfter := FExecCmdAfterBackup;
    AfterCmd := FExecCmdString;

    if RememberPass then
      Password := FPassword;
      
    cbbTimeFormat.ItemIndex := FTimeFormatIndex;
    SavePath := MakePath(FSavePath);
    CurrentName := ChangeFileExt(ExtractFileName(FCurrentName), '');

    if not FUseExternal then
      SaveFileName := SavePath + CurrentName + FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + '.zip'
    else
    begin
      FExt := GetExtFromCompressor(FCompressor);
      if FExt = '' then
        FExt := '.zip';
      SaveFileName := SavePath + CurrentName + FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + FExt;
    end;

    if ShowModal = mrOK then
    begin
      Update;

      FRemovePath := RemovePath;
      FUsePassword := UsePassword;
      FRememberPass := RememberPass;
      FUseExternal := UseExternal;
      FCompressor := Compressor;
      FCompressCmd := CompressCmd;

      FExecCmdAfterBackup := ExecAfter;
      FExecCmdFile := ExecAfterFile;
      FExecCmdString := AfterCmd;

      if FRememberPass then
        FPassword := Password
      else
        FPassword := '';
        
      FSavePath := ExtractFilePath(SaveFileName);
      FTimeFormatIndex := cbbTimeFormat.ItemIndex;
      
      if FSavePath = '' then
      begin
        FSavePath := MakePath(ExtractFilePath(FCurrentName));
        SaveFileName := FSavePath + SaveFileName;
      end;

      if FileExists(SaveFileName) and not Confirmed then
        if not QueryDlg(SCnOverwriteQuery) then
          Exit;

      // 处理 Version 信息来生成 VerStr
      VerStr := '';
      Options := CnOtaGetActiveProjectOptions;
      if Assigned(Options) then
      begin
        try
          VerStr := Format('%d.%d.%d.%d',
            [StrToIntDef(VarToStr(Options.GetOptionValue('MajorVersion')), 0),
            StrToIntDef(VarToStr(Options.GetOptionValue('MinorVersion')), 0),
            StrToIntDef(VarToStr(Options.GetOptionValue('Release')), 0),
            StrToIntDef(VarToStr(Options.GetOptionValue('Build')), 0)]);
        except
          ;
        end;
      end;

      if FUseExternal then
      begin
        ListFileName := MakePath(GetWindowsTempPath) + 'BackupList.txt';
        List := TStringList.Create;
        try
          for I := 0 to Self.lvFileView.Items.Count - 1 do
            if Self.lvFileView.Items[I].Data <> nil then
              List.Add(TCnBackupFileInfo(Self.lvFileView.Items[I].Data).FullFileName);

          List.SaveToFile(ListFileName);
        finally
          List.Free;
        end;
        // 构造命令行
        CompressorCommand := StringReplace(FCompressCmd, csCmdCompress, '"' + FCompressor + '"', [rfReplaceAll]);
        CompressorCommand := StringReplace(CompressorCommand, csCmdBackupFile, '"' + SaveFileName + '"', [rfReplaceAll]);
        CompressorCommand := StringReplace(CompressorCommand, csCmdListFile, '"' + ListFileName + '"', [rfReplaceAll]);
        CompressorCommand := StringReplace(CompressorCommand, csVersionInfo, '"' + VerStr + '"', [rfReplaceAll]);
        if FUsePassword then
          CompressorCommand := StringReplace(CompressorCommand, csCmdPassword, '"' + Password + '"', [rfReplaceAll])
        else
        begin
          CompressorCommand := StringReplace(CompressorCommand, '-p' + csCmdPassword, '', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, '-s' + csCmdPassword, '', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, csCmdPassword, '', [rfReplaceAll]);
        end;
          
        WinExecAndWait32(CompressorCommand);
      end
      else
      begin
        Zip := TAbZipper.Create(nil);
        Screen.Cursor := crHourGlass;
        try
          DeleteFile(SaveFileName);
          Zip.FileName := SaveFileName;
          Zip.StoreOptions := Zip.StoreOptions + [soReplace];
          Zip.DeleteFiles('*.*');

          if RemovePath then
            Zip.StoreOptions := Zip.StoreOptions + [soStripPath];
          if UsePassword then
            Zip.Password := Password;

          for I := 0 to Self.lvFileView.Items.Count - 1 do
            if Self.lvFileView.Items[I].Data <> nil then
              Zip.AddFiles(TCnBackupFileInfo(Self.lvFileView.Items[I].Data).FullFileName, 0);

          Zip.Save;
          Zip.CloseArchive;
          InfoDlg(Format(SCnProjExtBackupSuccFmt, [SaveFileName]));
        finally
          Screen.Cursor := crDefault;
          Zip.Free;
        end;
      end;

      // 备份后调外部程序进行通知
      if FExecCmdAfterBackup and (Trim(FExecCmdFile) <> '') then
      begin
        if FileExists(FExecCmdFile) then
        begin
          ExecCommand := StringReplace(FExecCmdString,
            csAfterCmd, '"' + FExecCmdFile + '"', [rfReplaceAll]);
          ExecCommand := StringReplace(ExecCommand,
            csCmdBackupFile, '"' + SaveFileName + '"', [rfReplaceAll]);
          ExecCommand := StringReplace(ExecCommand,
            csVersionInfo, '"' + VerStr + '"', [rfReplaceAll]);

          WinExec(PAnsiChar(AnsiString(ExecCommand)), SW_SHOW);
        end;
      end;  
    end;
    Free;
  end;
end;

procedure TCnProjectBackupForm.actRemoveFileExecute(Sender: TObject);
var
  I, J, K: Integer;
  Info: Pointer;
  Project: TCnBackupProjectInfo;
  Found: Boolean;
begin
  if Self.lvFileView.SelCount > 0 then
  begin
    for I := Self.lvFileView.Items.Count - 1 downto 0 do
    begin
      if not Self.lvFileView.Items[I].Selected then
        Continue;

      Info := Self.lvFileView.Items[I].Data;
      if Info <> nil then
      begin
        Found := False;
        for J := Self.ProjectList.Count - 1 downto 0 do
        begin
          if ProjectList.Items[J] = Info then // 要删的是工程文件
          begin
            ProjectList.Items[J].Hidden := True;
            Found := True;
            Break;
          end
          else // 找工程中的子文件
          begin
            Project := ProjectList.Items[J];
            for K := Project.Count - 1 downto 0 do
            begin
              if Project.Items[K] = Info then
              begin
                Project.Delete(K);
                Found := True;
                Break;
              end;
            end;
          end;
        end;

        if not Found then
          for J := Self.CustomFiles.Count - 1 downto 0 do
            if Self.CustomFiles.Items[J] = Info then
            begin
              CustomFiles.Delete(J);
              Break;
            end;

      end;
      Self.lvFileView.Items[I].Delete;
    end;
  end;
end;

procedure TCnProjectBackupForm.actAddFileExecute(Sender: TObject);
var
  I: Integer;
  FileInfo: TCnBackupFileInfo;
begin
  if Self.dlgOpen.Execute then
  begin
    for I := 0 to Self.dlgOpen.Files.Count - 1 do
    begin
      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo( Self.dlgOpen.Files[I], True );
      CustomFiles.Add( FileInfo );

      AddBackupFile( SCnProjExtCustomBackupFile, FileInfo );
    end;
    UpdateBackupFileView(cbbProjectList.Text);
  end;
end;

procedure TCnProjectBackupForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnProjectBackupForm.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end;
end;

procedure TCnProjectBackupForm.SimpleDecode(var Pass: string);
var
  Tmp: string;
  I: Integer;
begin
  if Pass <> '' then
  begin
    // 如果是非法密文，则清空
    if (Length(Pass) mod 2) <> 0 then
    begin
      Pass := '';
      Exit;
    end
    else
    begin
      for I := 1 to Length(Pass) do
      begin
        if not CharInSet(Pass[I], ['0'..'9', 'A'..'F']) then
        begin
          Pass := '';
          Exit;
        end;
      end;
    end;
    
    Tmp := '';
    for I := 1 to ((Length(Pass) + 1) div 2) do
      Tmp := Tmp + Chr(255 - StrToInt('$' + Copy(Pass, 2 * I - 1, 2)));
  end;
  Pass := Tmp;
end;

procedure TCnProjectBackupForm.SimpleEncode(var Pass: string);
var
  Tmp: string;
  I: Integer;
begin
  if Pass <> '' then
  begin
    Tmp := '';
    for I := 1 to Length(Pass) do
      Tmp := Tmp + IntToHex(255 - Ord(Pass[I]), 2);
  end;
  Pass := Tmp;
end;

procedure TCnProjectBackupForm.lvFileViewKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift = []) then
    Self.actRemoveFile.Execute;
end;

{$ENDIF SUPPORT_PRJ_BACKUP}

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
