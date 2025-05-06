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
* 修改记录：2023.03.04 V1.2 by LiuXiao
*               加入固定自定义文件的机制
*           2008.06.20 V1.1 by LiuXiao
*               加入备份后运行命令的机制
*           2006.08.19 V1.3 by LiuXiao
*               工程备份完善保存密码的功能
*           2005.01.10 V1.2 by 何清
*               1. 使用 TObjectList 来预加载文件列表，提高加载速度
*           2005.01.09 V1.1 by 何清
*               1. 文件列表使用系统文件图标
*               2. 支持全部工程、当前活动工程和特定工程项目备份选择
*               3. 修正一处工程文件两次添加的 Bug
*           2004.12.31 V1.0 by 何清
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
  Windows, SysUtils, Messages, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, CheckLst, IniFiles, Menus, ActnList, FileCtrl, CnCommon,
  CnWizConsts, CnWizMultiLang, ComCtrls, ToolWin, ToolsAPI, ShellAPI, CommCtrl,
  Contnrs, Dialogs, CnLangTranslator, CnLangMgr, CnLangStorage, CnHashLangStorage;

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

    procedure LoadFromFile(const FileName: string);
    {* 从普通文件载入内容，注意只载入简单的文件名}
    procedure SaveToFile(const FileName: string);
    {* 将内容存储入普通文件，注意只存简单的文件名}

    function AddFile(const FileName: string): Boolean;
    {* 根据文件名添加单个文件}

    procedure Add(FileInfo: TCnBackupFileInfo);
    {* 添加已组装好文件信息的对象}

    procedure Delete(Index: Integer);
    {* 删除指定索引的文件对象并释放}

    procedure AddFiles(const FileName, UnitName, FormName: string);
    {* 根据源码文件信息添加一批必要的文件}

    property Count: Integer read GetCount;
    {* 数量}
    property Items[Index: Integer]: TCnBackupFileInfo read GetItem;
    {* 条目}
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
    actAddOpened: TAction;
    actAddDir: TAction;
    btnAddOpened: TToolButton;
    btnAddDir: TToolButton;
    lblLast: TLabel;
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
    procedure FormShow(Sender: TObject);
    procedure actAddOpenedExecute(Sender: TObject);
    procedure actAddDirExecute(Sender: TObject);
  private
    FCustomFiles: TCnBackupProjectInfo;
    FProjectList: TCnBackupProjectList; // 根列表，里头有多个 ProjectInfo，每个里有有多个 FileInfo
    FExt: string;
    FListViewWidthStr: string;
    FSortIndex: Integer;
    FSortDown: Boolean;
    FUpArrow: TBitmap;
    FDownArrow: TBitmap;
    FNoArrow: TBitmap;
    FRemovePath: Boolean;
    FUsePassword: Boolean;
    FRememberPass: Boolean;
    FShowPass: Boolean;
    FPassword: string;
    FSavePath: string;
    FCurrentName: string;
    FIncludeVer: Boolean;
    FTimeFormatIndex: Integer;
    FUseExternal: Boolean;
    FCompressor: string;
    FCompressCmd: string;
    FExecCmdAfterBackup: Boolean;
    FExecCmdFile: string;
    FExecCmdString: string;
    FSendMail: Boolean;
    FMailAddr: string;
    FDialogWidth: Integer;
    FDialogHeight: Integer;
    procedure OnAppMessage(var Msg: Tmsg; var Handled: Boolean);
    procedure CreateProjectList;
    procedure InitComboBox;
    procedure UpdateStatusBar;
    function AddBackupFile(const ProjectName: string; FileInfo: TCnBackupFileInfo): Boolean;
    // 返回添加是否成功。如未成功，FileInfo 需要调用者自行释放
    procedure AddBackupFiles(ProjectInfo: TCnBackupProjectInfo);
    procedure UpdateBackupFileView(ProjectName: string);
    function FindBackupFile(const FileName: string): Integer;

    procedure SimpleDecode(var Pass: string);
    procedure SimpleEncode(var Pass: string);
    procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);

    procedure InitArrowBitmaps;
    procedure ClearColumnArrow;
    procedure ChangeColumnArrow;
    procedure lvFileViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvFileViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  protected
    FLastBackupFile: string;
    FLastBackupTime: TDateTime;
    procedure FirstInit(Sender: TObject);
    function GetHelpTopic: string; override;
  public
    procedure UpdateLast;
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
  end;

function ShowProjectBackupForm(Ini: TCustomIniFile): Boolean;

function GetFileIconIndex(FileName: string): Integer;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$R *.DFM}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  CnWizOptions, CnWizUtils, CnWizHelperIntf,
  CnWizShareImages, CnProjectBackupSaveFrm, CnWizNotifier;

const
  csProjBackupFile = 'CustomBackup.txt'; // 自定义文件的存储

  csBackupSection = 'ProjectBackup';
  csRemovePath = 'RemovePath';
  csUsePassword = 'UsePassword';
  csSavePath = 'SavePath';
  csRememberPass = 'RememberPass';
  csShowPass = 'ShowPass';
  csZipPass = 'ZipPass';
  csTimeFormatIndex = 'TimeFormatIndex';
  csIncludeVer = 'IncludeVer';
  
  csUseExternal = 'UseExternal';
  csCompressor = 'Compressor';
  csCompressCmd = 'CompressCmd';
  csExecCmdAfterBackup = 'ExecCmdAfterBackup';
  csExecCmdFile = 'ExecCmdFile';
  csExecCmdString = 'ExecCmdString';
  csSendMail = 'SendMail';
  csMailAddr = 'MailAddr';

  csWidth = 'Width';
  csHeight = 'Height';
  csListViewWidth = 'ListViewWidth';
  csDialogWidth = 'DialogWidth';
  csDialogHeight = 'DialogHeight';

  csLastBackupFile = 'LastBackupFile';
  csLastBackupTime = 'LastBackupTime';

  csCmdCompress = '<compress.exe>';
  csCmdBackupFile = '<BackupFile>';
  csVersionInfo = '<VersionInfo>';
  csCmdListFile = '<ListFile>';
  csCmdPassword = '<Password>';
  csComments = '<Comments>';
  csAfterCmd = '<externfile.exe>';

  {CommCtrl Constants For Windows >= XP }
  HDF_SORTUP              = $0400;
  HDF_SORTDOWN            = $0200;

var
  FileList: TStrings = nil;
  GlobalSortIndex: Integer;
  GlobalSortDown: Boolean;

function ShowProjectBackupForm(Ini: TCustomIniFile): Boolean;
begin
  with TCnProjectBackupForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    LoadSettings(Ini);
    UpdateLast;
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
  FName := _CnExtractFileName(FileName);
  FPath := _CnExtractFilePath(FileName);
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

function TCnBackupProjectInfo.AddFile(const FileName: string): Boolean;
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

procedure TCnBackupProjectInfo.AddFiles(const FileName, UnitName, FormName: string);
var
  TempFileName: string;
begin
  // 不备份 DCP/BPI/DLL 文件
  TempFileName := ExtractUpperFileExt(FileName);
  if (TempFileName = '.DCP') or (TempFileName = '.BPI') or (TempFileName = '.DLL') then
    Exit;

  AddFile(FileName);

  // 加入 cpp 文件对应的 h/hpp/bpr/bpk
  if TempFileName = '.CPP' then
  begin
    AddFile(_CnChangeFileExt(FileName, '.h'));
    AddFile(_CnChangeFileExt(FileName, '.hpp'));
    AddFile(_CnChangeFileExt(FileName, '.bpr'));
    AddFile(_CnChangeFileExt(FileName, '.bpk'));
  end;

  // 加入其他文件
  AddFile(_CnChangeFileExt(FileName, '.dfm'));
  AddFile(_CnChangeFileExt(FileName, '.xfm'));
  AddFile(_CnChangeFileExt(FileName, '.nfm'));
  AddFile(_CnChangeFileExt(FileName, '.todo'));
  AddFile(_CnChangeFileExt(FileName, '.tlb'));

{$IFDEF SUPPORT_FMX}
  // 加入 fmx 的支持
  AddFile(_CnChangeFileExt(FileName, '.fmx'));
{$ENDIF}
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

procedure TCnBackupProjectInfo.LoadFromFile(const FileName: string);
var
  L: TStringList;
  I: Integer;
begin
  if not FileExists(FileName) then
    Exit;

  L := TStringList.Create;
  try
    FInfoList.Clear;

    L.LoadFromFile(FileName);
    for I := 0 to L.Count - 1 do
      AddFile(L[I]);
  finally
    L.Free;
  end;
end;

procedure TCnBackupProjectInfo.SaveToFile(const FileName: string);
var
  L: TStringList;
  I: Integer;
begin
  if Count <= 0 then
    Exit;

  L := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      L.Add(Items[I].FullFileName);

    L.SaveToFile(FileName);
  finally
    L.Free;
  end;
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

procedure TCnBackupProjectList.Delete(Index: Integer);
begin
  FProjectList.Delete(Index);
end;

//==============================================================================
// 工程备份主窗口类
//==============================================================================

{ TCnProjectBackupForm }

procedure TCnProjectBackupForm.FormCreate(Sender: TObject);
var
  hImgList: THandle;
  FileInfo: TSHFileInfo;
begin
  WizOptions.ResetToolbarWithLargeIcons(tlbMain);

{$IFNDEF COMPILER5}
  // D5 下不支持 OnCompare 事件，没法按列排序
  FUpArrow := TBitmap.Create;
  FDownArrow := TBitmap.Create;
  FNoArrow := TBitmap.Create;

  lvFileView.OnColumnClick := lvFileViewColumnClick;
  lvFileView.OnCompare := lvFileViewCompare;
{$ENDIF}

  Screen.Cursor := crHourGlass;
  try
    FProjectList := TCnBackupProjectList.Create;
    FCustomFiles := TCnBackupProjectInfo.Create;

    { 获取系统图标列表 }
    hImgList := SHGetFileInfo('C:\', 0, FileInfo, SizeOf(FileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SendMessage(lvFileView.Handle, LVM_SETIMAGELIST, LVSIL_SMALL, hImgList);

    // 备份文件视图支持一自外部的文件拖放
    DragAcceptFiles(lvFileView.Handle, True);
    CnWizNotifierServices.AddApplicationMessageNotifier(OnAppMessage);

    CnWizNotifierServices.ExecuteOnApplicationIdle(FirstInit);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCnProjectBackupForm.FirstInit(Sender: TObject);
begin
  CreateProjectList;
  InitComboBox;
end;

procedure TCnProjectBackupForm.FormDestroy(Sender: TObject);
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnAppMessage);
  FreeAndNil(FProjectList);
  FreeAndNil(FCustomFiles);

  FNoArrow.Free;
  FDownArrow.Free;
  FUpArrow.Free;
  inherited;
end;

procedure TCnProjectBackupForm.LoadSettings(Ini: TCustomIniFile);
begin
  FUsePassword := Ini.ReadBool(csBackupSection, csUsePassword, False);
  FRememberPass := Ini.ReadBool(csBackupSection, csRememberPass, False);
  FShowPass := Ini.ReadBool(csBackupSection, csShowPass, False);
  FRemovePath := Ini.ReadBool(csBackupSection, csRemovePath, False);
  FSavePath := Ini.ReadString(csBackupSection, csSavePath, '');
  FTimeFormatIndex := Ini.ReadInteger(csBackupSection, csTimeFormatIndex, 0);
  FIncludeVer := Ini.ReadBool(csBackupSection, csIncludeVer, False);
  FPassword := Ini.ReadString(csBackupSection, csZipPass, '');
  FUseExternal := Ini.ReadBool(csBackupSection, csUseExternal, False);
  FCompressor := Ini.ReadString(csBackupSection, csCompressor, '');
  FCompressCmd := Ini.ReadString(csBackupSection, csCompressCmd, '');
  FExecCmdAfterBackup := Ini.ReadBool(csBackupSection, csExecCmdAfterBackup, False);
  FExecCmdFile := Ini.ReadString(csBackupSection, csExecCmdFile, '');
  FExecCmdString := Ini.ReadString(csBackupSection, csExecCmdString, '');
  FSendMail := Ini.ReadBool(csBackupSection, csSendMail, False);
  FMailAddr := Ini.ReadString(csBackupSection, csMailAddr, '');

  try
    SimpleDecode(FPassword);
  except
    FPassword := '';
  end;

  Width := Ini.ReadInteger(csBackupSection, csWidth, Width);
  Height := Ini.ReadInteger(csBackupSection, csHeight, Height);
  CenterForm(Self);

  FDialogWidth := Ini.ReadInteger(csBackupSection, csDialogWidth, 0);
  FDialogHeight := Ini.ReadInteger(csBackupSection, csDialogHeight, 0);

  FLastBackupFile := Ini.ReadString(csBackupSection, csLastBackupFile, '');
  FLastBackupTime := Ini.ReadDateTime(csBackupSection, csLastBackupTime, 0.0);

  FListViewWidthStr := Ini.ReadString(csBackupSection, csListViewWidth, '');
  SetListViewWidthString(lvFileView, FListViewWidthStr, GetFactorFromSizeEnlarge(Enlarge));

  if FileExists(WizOptions.GetAbsoluteUserFileName(csProjBackupFile)) then
  begin
    FCustomFiles.LoadFromFile(WizOptions.GetAbsoluteUserFileName(csProjBackupFile));
{$IFDEF DEBUG}
    CnDebugger.LogInteger(FCustomFiles.Count, 'TCnProjectBackupForm.LoadSettings Custom Files Count');
{$ENDIF}
  end;
end;

procedure TCnProjectBackupForm.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csBackupSection, csUsePassword, FUsePassword);
  Ini.WriteBool(csBackupSection, csRememberPass, FRememberPass);
  Ini.WriteBool(csBackupSection, csShowPass, FShowPass);
  Ini.WriteBool(csBackupSection, csRemovePath, FRemovePath);
  Ini.WriteString(csBackupSection, csSavePath, FSavePath);
  Ini.WriteInteger(csBackupSection, csTimeFormatIndex, FTimeFormatIndex);
  Ini.WriteBool(csBackupSection, csIncludeVer, FIncludeVer);
  Ini.WriteBool(csBackupSection, csUseExternal, FUseExternal);
  Ini.WriteString(csBackupSection, csCompressor, FCompressor);
  Ini.WriteString(csBackupSection, csCompressCmd, FCompressCmd);
  Ini.WriteBool(csBackupSection, csExecCmdAfterBackup, FExecCmdAfterBackup);
  Ini.WriteString(csBackupSection, csExecCmdFile, FExecCmdFile);
  Ini.WriteString(csBackupSection, csExecCmdString, FExecCmdString);
  Ini.WriteBool(csBackupSection, csSendMail, FSendMail);
  Ini.WriteString(csBackupSection, csMailAddr, FMailAddr);

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

  Ini.WriteInteger(csBackupSection, csWidth, Width);
  Ini.WriteInteger(csBackupSection, csHeight, Height);

  Ini.WriteInteger(csBackupSection, csDialogWidth, FDialogWidth);
  Ini.WriteInteger(csBackupSection, csDialogHeight, FDialogHeight);

  if FLastBackupFile <> '' then
  begin
    Ini.WriteString(csBackupSection, csLastBackupFile, FLastBackupFile);
    Ini.WriteDateTime(csBackupSection, csLastBackupTime, FLastBackupTime);
  end;

  Ini.WriteString(csBackupSection, csListViewWidth,
    GetListViewWidthString(lvFileView, GetFactorFromSizeEnlarge(Enlarge)));

  if FCustomFiles.Count > 0 then
  begin
    FCustomFiles.SaveToFile(WizOptions.GetAbsoluteUserFileName(csProjBackupFile));
{$IFDEF DEBUG}
    CnDebugger.LogInteger(FCustomFiles.Count, 'TCnProjectBackupForm.SaveSettings Custom Files Count');
{$ENDIF}
  end
  else
    DeleteFile(WizOptions.GetAbsoluteUserFileName(csProjBackupFile));
end;

function TCnProjectBackupForm.GetHelpTopic: string;
begin
  Result := 'CnProjectBackup';
end;

function TCnProjectBackupForm.FindBackupFile(const FileName: string): Integer;
var
  I: Integer;
  FileInfo: TCnBackupFileInfo;
begin
  for I := 0 to lvFileView.Items.Count - 1 do
  begin
    FileInfo := TCnBackupFileInfo(lvFileView.Items[I].Data);
    if CompareText(FileName, FileInfo.FullFileName) = 0 then
    begin
      Result := I;
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

      // TODO: 暂时不支持目录拖放，将在之后版本中给予支持...
      if DirectoryExists( DroppedFilename ) then
        Continue;
        
      if FindBackupFile(DroppedFilename) <> -1 then // 文件已经被加入到视图中
        Continue;

      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo(DroppedFilename, True);

      if AddBackupFile(SCnProjExtCustomBackupFile, FileInfo) then
        FCustomFiles.Add(FileInfo)
      else
        FileInfo.Free;
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
  I, J: Integer;
  ProjectInterfaceList: TInterfaceList;
{$IFDEF BDS}
  ProjectGroup: IOTAProjectGroup;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnProjectBackupForm.CreateProjectList');
{$ENDIF}

  IProjectGroup := CnOtaGetProjectGroup;
  if IProjectGroup = nil then
    Exit;

  FileName := CnOtaGetProjectGroupFileName;
  if FileExists(FileName) then
    FProjectList.SetFileInfo(FileName);

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
      FProjectList.Add(ProjectInfo); // 先加工程文件

      for J := 0 to IProject.GetModuleFileCount - 1 do
      begin
        IEditor := IProject.GetModuleFileEditor(J);
        Assert(IEditor <> nil);

        FileName := IEditor.FileName;
        if FileName <> '' then       // 再加工程中的每一个源文件
          ProjectInfo.AddFiles(IEditor.FileName, '', '');
      end;

      for J := 0 to IProject.GetModuleCount - 1 do
      begin
        IModuleInfo := IProject.GetModule(J);
        Assert(IModuleInfo <> nil);

        FileName := IModuleInfo.FileName;
        if FileName <> '' then      // 再加工程中的每一个窗体文件
          ProjectInfo.AddFiles(IModuleInfo.FileName, '', IModuleInfo.FormName);
      end;
    end;
  finally
    ProjectInterfaceList.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnProjectBackupForm.CreateProjectList');
{$ENDIF}
end;

procedure TCnProjectBackupForm.InitComboBox;
var
  ProjectInfo: TCnBackupProjectInfo;
  I: Integer;
begin
  cbbProjectList.Clear;

  cbbProjectList.Items.Add(SCnProjExtProjectAll);
  cbbProjectList.Items.Add(SCnProjExtCurrentProject);

  for I := 0 to FProjectList.Count - 1 do
  begin
    ProjectInfo := FProjectList.Items[I];
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

function TCnProjectBackupForm.AddBackupFile(const ProjectName: string;
  FileInfo: TCnBackupFileInfo): Boolean;
begin
  Result := False;
  if (FileInfo.Name = '') or FileInfo.Hidden then
    Exit;

  // 该文件是否已经被添中到备份文件视图中，因为一个文件可能存在于多个工程中，
  // 所以在 TCnProjectInfo 中可能保存多个同名文件，该步处理是非常有必要的！
  if FindBackupFile(FileInfo.FullFileName) <> -1 then
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
  Result := True;
end;

procedure TCnProjectBackupForm.AddBackupFiles(ProjectInfo: TCnBackupProjectInfo);
var
  I: Integer;
begin
  { 对于用户自添加的文件列表，则 Name 值为空 }
  if ProjectInfo.Name <> '' then
    AddBackupFile(ProjectInfo.Name, ProjectInfo);

  for I := 0 to ProjectInfo.Count - 1 do
    AddBackupFile(ProjectInfo.Name, ProjectInfo.Items[I]);
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

    if ProjectName = SCnProjExtProjectAll then // 备份全部的工程项
    begin
      IProjectGroup := CnOtaGetProjectGroup;
      if (IProjectGroup <> nil) and (IProjectGroup.ProjectCount > 1) then
        FCurrentName := CnOtaGetProjectGroupFileName
      else
        FCurrentName := CnOtaGetCurrentProjectFileName;

      AddBackupFile(FProjectList.Name, FProjectList);
      for I := 0 to FProjectList.Count - 1 do
        AddBackupFiles(FProjectList.Items[I]);
    end
    else
    begin
      if (ProjectName = SCnProjExtCurrentProject) then  // 备份当前工程项
      begin
        IProject := CnOtaGetCurrentProject;
        if IProject = nil then
          Exit;

        ProjectName := _CnExtractFileName(IProject.FileName);
        FCurrentName := IProject.FileName;
      end;

      for I := 0 to FProjectList.Count - 1 do
      begin
        if (CompareText(FProjectList.Items[I].Name, ProjectName) = 0) then
        begin
          FCurrentName := FProjectList.Items[I].GetFullFileName;
          AddBackupFiles(FProjectList.Items[I]);
        end;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogInteger(FCustomFiles.Count, 'UpdateBackupFileView to Add Custom Files Count');
{$ENDIF}
    // 添加用户自选备份文件组
    AddBackupFiles(FCustomFiles);
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
  CompressorCommand, ListFileName, ExecCommand, VerStr: string;
  List: TStrings;
  Comment: AnsiString;
  SrcList, ArcList: TStrings;
  SaveForm: TCnProjectBackupSaveForm;
begin
  if lvFileView.Items.Count = 0 then
  begin
    ErrorDlg(SCnProjExtBackupNoFile);
    Exit;
  end;

  SaveForm := TCnProjectBackupSaveForm.Create(nil);
  if FDialogWidth > 0 then
    SaveForm.Width := FDialogWidth;
  if FDialogHeight > 0 then
    SaveForm.Height := FDialogHeight;

  try
    with SaveForm  do
    begin
      RemovePath := FRemovePath;
      RememberPass := FRememberPass;
      ShowPass := FShowPass;
      UsePassword := FUsePassword;
      UseExternal := FUseExternal;
      Compressor := FCompressor;
      CompressCmd := FCompressCmd;
      ExecAfterFile := FExecCmdFile;
      ExecAfter := FExecCmdAfterBackup;
      AfterCmd := FExecCmdString;
      SendMail := FSendMail;
      MailAddr := FMailAddr;

      if RememberPass then
        Password := FPassword;

      cbbTimeFormat.ItemIndex := FTimeFormatIndex;
      IncludeVer := FIncludeVer;
      SavePath := MakePath(FSavePath);
      CurrentName := _CnChangeFileExt(_CnExtractFileName(FCurrentName), '');

      VerStr := CnOtaGetProjectVersion;
      Version := VerStr;

      if not FUseExternal then
      begin
        if FIncludeVer and (VerStr <> '') then
          SaveFileName := SavePath + CurrentName + '_' + VerStr +
            FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + '.zip'
        else
          SaveFileName := SavePath + CurrentName +
            FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + '.zip';
      end
      else
      begin
        FExt := GetExtFromCompressor(FCompressor);
        if FExt = '' then
          FExt := '.zip';

        if FIncludeVer and (VerStr <> '') then
          SaveFileName := SavePath + CurrentName + '_' + VerStr +
            FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + FExt
        else
          SaveFileName := SavePath + CurrentName +
            FormatDateTime('_' + cbbTimeFormat.Items[FTimeFormatIndex], Date + Time) + FExt;
      end;

      if ShowModal = mrOK then
      begin
        Update;

        FRemovePath := RemovePath;
        FUsePassword := UsePassword;
        FRememberPass := RememberPass;
        FShowPass := ShowPass;
        FUseExternal := UseExternal;
        FCompressor := Compressor;
        FCompressCmd := CompressCmd;

        FExecCmdAfterBackup := ExecAfter;
        FExecCmdFile := ExecAfterFile;
        FExecCmdString := AfterCmd;

        FSendMail := SendMail;
        FMailAddr := MailAddr;

        if FRememberPass then
          FPassword := Password
        else
          FPassword := '';

        FSavePath := _CnExtractFilePath(SaveFileName);
        FTimeFormatIndex := cbbTimeFormat.ItemIndex;
        FIncludeVer := IncludeVer;

        SaveFileName := LinkPath(_CnExtractFilePath(FCurrentName), SaveFileName);

        if FileExists(SaveFileName) and not Confirmed then
          if not QueryDlg(SCnOverwriteQuery) then
            Exit;

        // 处理 Version 信息来生成 VerStr
        if FUseExternal then
        begin
          ListFileName := MakePath(GetWindowsTempPath) + 'BackupList.txt';
          List := TStringList.Create;
          try
            for I := 0 to lvFileView.Items.Count - 1 do
              if lvFileView.Items[I].Data <> nil then
                List.Add(TCnBackupFileInfo(lvFileView.Items[I].Data).FullFileName);

            List.SaveToFile(ListFileName);
          finally
            List.Free;
          end;

          // 构造命令行
          CompressorCommand := StringReplace(FCompressCmd, csCmdCompress, '"' + FCompressor + '"', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, csCmdBackupFile, '"' + SaveFileName + '"', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, csCmdListFile, '"' + ListFileName + '"', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, csVersionInfo, '"' + VerStr + '"', [rfReplaceAll]);
          CompressorCommand := StringReplace(CompressorCommand, csComments, '"' + Comments + '"', [rfReplaceAll]);
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
          // 调用 CnWizards 自带的外部 DLL 来实现压缩
          if not CnWizHelperZipValid then
          begin
            ErrorDlg(SCnProjExtBackupDllMissCorrupt);
            Exit;
          end;

          Screen.Cursor := crHourGlass;
          try
            DeleteFile(SaveFileName);
            try
              CnWizStartZip(_CnPChar(SaveFileName), _CnPChar(Password), RemovePath);

              if FRemovePath then
              begin
                for I := 0 to lvFileView.Items.Count - 1 do
                  if lvFileView.Items[I].Data <> nil then
                    CnWizZipAddFile(_CnPChar(TCnBackupFileInfo(lvFileView.Items[I].Data).FullFileName), nil);
              end
              else
              begin
                // 拿到文件名列表，抽取掉前面的公共部分再传入
                SrcList := TStringList.Create;
                ArcList := TStringList.Create;
                try
                  for I := 0 to lvFileView.Items.Count - 1 do
                    if lvFileView.Items[I].Data <> nil then
                      SrcList.Add(TCnBackupFileInfo(lvFileView.Items[I].Data).FullFileName);

                  // 删除掉公共目录头后，添加进去
                  if CombineCommonPath(SrcList, ArcList) then
                  begin
                    for I := 0 to SrcList.Count - 1 do
                      CnWizZipAddFile(_CnPChar(SrcList[I]), _CnPChar(ArcList[I]));
                  end
                  else // 无齐头并进的公共目录，原样添加
                  begin
                    for I := 0 to SrcList.Count - 1 do
                      CnWizZipAddFile(_CnPChar(SrcList[I]), nil);
                  end;
                finally
                  ArcList.Free;
                  SrcList.Free;
                end;
              end;

              if mmoComments.Lines.Text <> '' then
              begin
                Comment := AnsiString(mmoComments.Lines.Text);
                CnWizZipSetComment(PAnsiChar(Comment));
              end;

              if CnWizZipSaveAndClose then
              begin
                InfoDlg(Format(SCnProjExtBackupSuccFmt, [SaveFileName]));
                FLastBackupFile := ExtractFileName(SaveFileName);
                FLastBackupTime := Now;
                UpdateLast;

                Close;
              end;
            except
              ErrorDlg(SCnProjExtBackupFail);
            end;
          finally
            Screen.Cursor := crDefault;
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

        if FSendMail and IsValidEmail(FMailAddr) then
        begin
          ShellExecute(0, 'open', PChar('mailto:?to=' + FMailAddr + '&subject=' + CurrentName + ' ' + VerStr),
            PChar(SaveFileName), nil, SW_SHOWNORMAL);
        end;
      end;
    end;
  finally
    FDialogWidth := SaveForm.Width;
    FDialogHeight := SaveForm.Height;
    SaveForm.Free;
  end;
end;

procedure TCnProjectBackupForm.actRemoveFileExecute(Sender: TObject);
var
  I, J, K: Integer;
  Info: Pointer;
  Project: TCnBackupProjectInfo;
  Found: Boolean;
begin
  if lvFileView.SelCount > 0 then
  begin
    for I := lvFileView.Items.Count - 1 downto 0 do
    begin
      if not lvFileView.Items[I].Selected then
        Continue;

      Info := lvFileView.Items[I].Data;
      if Info <> nil then
      begin
        Found := False;
        for J := FProjectList.Count - 1 downto 0 do
        begin
          if FProjectList.Items[J] = Info then // 要删的是工程文件
          begin
            FProjectList.Items[J].Hidden := True;
            Found := True;
            Break;
          end
          else // 找工程中的子文件
          begin
            Project := FProjectList.Items[J];
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
        begin
          for J := FCustomFiles.Count - 1 downto 0 do
          begin
            if FCustomFiles.Items[J] = Info then
            begin
              FCustomFiles.Delete(J);
              Break;
            end;
          end;
        end;
      end;
      lvFileView.Items[I].Delete;
    end;
  end;
end;

procedure TCnProjectBackupForm.actAddFileExecute(Sender: TObject);
var
  I: Integer;
  FileInfo: TCnBackupFileInfo;
begin
  if dlgOpen.Execute then
  begin
    for I := 0 to dlgOpen.Files.Count - 1 do
    begin
      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo(dlgOpen.Files[I], True);

      if AddBackupFile(SCnProjExtCustomBackupFile, FileInfo) then
        FCustomFiles.Add(FileInfo)
      else
        FileInfo.Free;
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
    actRemoveFile.Execute;
end;

procedure TCnProjectBackupForm.FormShow(Sender: TObject);
begin
{$IFDEF BDS}
  SetListViewWidthString(lvFileView, FListViewWidthStr, GetFactorFromSizeEnlarge(Enlarge));
  DragAcceptFiles(lvFileView.Handle, True);
{$ENDIF}
end;

procedure TCnProjectBackupForm.actAddOpenedExecute(Sender: TObject);
var
  I, J, Cnt: Integer;
  SName: string;
  MS: IOTAModuleServices;
  MO: IOTAModule;
  FileInfo: TCnBackupFileInfo;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, MS);
  Cnt := 0;

  for I := 0 to MS.GetModuleCount - 1 do
  begin
    MO := MS.GetModule(I);
    SName := CnOtaGetFileNameOfModule(MO);
    if not FileExists(SName) then
      Continue;

    FileInfo := TCnBackupFileInfo.Create;
    FileInfo.SetFileInfo(SName, True);

    if AddBackupFile(SCnProjExtCustomBackupFile, FileInfo) then
    begin
      FCustomFiles.Add(FileInfo);
      Inc(Cnt);
    end
    else
      FileInfo.Free;

    // 得包括 dfm 与其他工程文件
    for J := 0 to MO.GetModuleFileCount - 1 do
    begin
      SName := MO.GetModuleFileEditor(J).FileName;
      if not FileExists(SName) then
        Continue;

//      T := ExtractUpperFileExt(SName);
//      if (T = '.DPR') or (T = '.BPR') or (T = '.DPROJ') or (T = '.BDSPROJ')
//        or (T = '.BPG') then
//        Continue;

      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo(SName, True);

      if AddBackupFile(SCnProjExtCustomBackupFile, FileInfo) then
      begin
        FCustomFiles.Add(FileInfo);
        Inc(Cnt);
      end
      else
        FileInfo.Free;
    end;
  end;
  // Cnt 个文件
  InfoDlg(Format(SCnProjExtBackupAddFile, [Cnt]));
end;


procedure TCnProjectBackupForm.actAddDirExecute(Sender: TObject);
var
  S: string;
  I, Cnt: Integer;
  FileInfo: TCnBackupFileInfo;
begin
  if GetDirectory(SCnSelectDirCaption, S) then
  begin
    FileList := TStringList.Create;
    FindFile(MakePath(S), '*.*', DoFindFile, nil, True, True);

    Cnt := 0;
    for I := 0 to FileList.Count - 1 do
    begin
      S := FileList[I];
      if not FileExists(S) then
        Continue;

      FileInfo := TCnBackupFileInfo.Create;
      FileInfo.SetFileInfo(S, True);

      if AddBackupFile(SCnProjExtCustomBackupFile, FileInfo) then
      begin
        FCustomFiles.Add(FileInfo);
        Inc(Cnt);
      end
      else
        FileInfo.Free;
    end;

    FreeAndNil(FileList);
    InfoDlg(Format(SCnProjExtBackupAddFile, [Cnt]));
  end;
end;

procedure TCnProjectBackupForm.DoFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Ext: string;
begin
  if (FileName = '.') or (FileName = '..') then
    Exit;

  Ext := ExtractUpperFileExt(FileName);
  if Pos('.~', Ext) <= 0 then  // 不收集带 ~ 的临时文件
    FileList.Add(FileName);
end;

procedure TCnProjectBackupForm.UpdateLast;
begin
  if FLastBackupFile <> '' then
    lblLast.Caption := Format(SCnProjExtBackupLastFmt,
      [FLastBackupFile, DateTimeToStr(FLastBackupTime)])
  else
    lblLast.Caption := '';
end;


procedure TCnProjectBackupForm.ChangeColumnArrow;
var
  Header: HWND;
  Item: THDItem;
begin
  if (FSortIndex >= 0) and (FSortIndex < lvFileView.Columns.Count) then
  begin
    Header := ListView_GetHeader(lvFileView.Handle);
    ZeroMemory(@Item, SizeOf(Item));
    Item.Mask := HDI_FORMAT or HDI_BITMAP;

    Header_GetItem(Header, FSortIndex, Item);

{$IFDEF BDS2007_UP}  // D2007 CommCtrl 才支持 SORTUP/DOWN 标记
    Item.fmt := Item.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
    if FSortDown then
      Item.fmt := Item.fmt or HDF_SORTUP
    else
      Item.fmt := Item.fmt or HDF_SORTDOWN;
{$ELSE}
    Item.fmt := Item.fmt or HDF_BITMAP_ON_RIGHT or HDF_BITMAP;
    if FSortDown then
      Item.hbm := FUpArrow.Handle
    else
      Item.hbm := FDownArrow.Handle;
{$ENDIF}

    Header_SetItem(Header, FSortIndex, Item);

{$IFDEF DEBUG}
    CnDebugger.LogMsg('ChangeColumnArrow for Column ' + IntToStr(FSortIndex));
{$ENDIF}
  end;
end;

procedure TCnProjectBackupForm.ClearColumnArrow;
var
  Header: HWND;
  Item: THDItem;
begin
  if (FSortIndex >= 0) and (FSortIndex < lvFileView.Columns.Count) then
  begin
    Header := ListView_GetHeader(lvFileView.Handle);
    ZeroMemory(@Item, SizeOf(Item));
    Item.Mask := HDI_FORMAT or HDI_BITMAP;

    Header_GetItem(Header, FSortIndex, Item);
    Item.fmt := Item.fmt and not (HDF_SORTUP or HDF_SORTDOWN);

{$IFNDEF BDS2007_UP} // D2007 CommCtrl 才支持 SORTUP/DOWN 标记
    Item.fmt := Item.fmt or HDF_BITMAP_ON_RIGHT or HDF_BITMAP;
    Item.hbm := FNoArrow.Handle;
{$ENDIF}

    Header_SetItem(Header, FSortIndex, Item);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ClearColumnArrow for Column ' + IntToStr(FSortIndex));
{$ENDIF}
  end;
end;

procedure TCnProjectBackupForm.InitArrowBitmaps;

  procedure MakeBitmap(Bmp: TBitmap; Idx: Integer);
  begin
    Bmp.Width := dmCnSharedImages.ilColumnHeader.Width;
    Bmp.Height := dmCnSharedImages.ilColumnHeader.Height;
    with Bmp.Canvas do
    begin
      Brush.COlor := clBtnface;
      Brush.Style := bsSolid;
      FillRect(ClipRect);
    end;
    dmCnSharedImages.ilColumnHeader.Draw(Bmp.Canvas, 0, 0, Idx);
  end;

begin
  MakeBitmap(FUpArrow, 0);
  MakeBitmap(FDownArrow, 1);
  MakeBitmap(FNoArrow, 2);
end;

procedure TCnProjectBackupForm.lvFileViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ClearColumnArrow;
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;

  // 根据 FSortIndex 和 FSortDown 排序
  lvFileView.AlphaSort;
  ChangeColumnArrow;
end;

procedure TCnProjectBackupForm.lvFileViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if FSortIndex = 0 then
    Compare := CompareText(Item1.Caption, Item2.Caption)
  else
    Compare := CompareText(Item1.SubItems[FSortIndex - 1], Item2.SubItems[FSortIndex - 1]);

  if FSortDown then
    Compare := -Compare;
end;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
