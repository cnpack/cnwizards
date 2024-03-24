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

unit CnFilesSnapshot;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：文件列表快照单元
* 单元作者：熊恒（beta） xbeta@tom.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：PWin2000Pro + Delphi 6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2007.08.01 V1.3
*               beta 默认优先打开工程组文件及工程文件
*               管理快照允许撤消操作
*           2004.07.22 V1.2
*               LiuXiao 将本专家从工程扩展工具中独立出来成单独子菜单项专家
*               并将打开历史文件移动至此中。
*           2004.06.01 V1.1
*               LiuXiao 修改当只创建一项列表子菜单时"最后标志"被跳过而没赋值的问题
*           2004.04.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ActnList,
  ToolsAPI, IniFiles, ShellAPI, Menus, CnCommon, CnWizClasses, CnWizUtils,
  CnConsts, CnWizConsts, CnFilesSnapshotManageFrm, CnWizOptions, CnWizIdeUtils,
  CnRoWizard;

type

//==============================================================================
// 文件列表快照专家
//==============================================================================

{ TCnFilesSnapshotWizard }

  TCnFilesSnapshotWizard = class(TCnSubMenuWizard)
  private
    FExecuting: Boolean;
    // 上一次执行添加快照的时间，用于防止一个 bug，详见 FilesSnapshotAdd 方法
    FLastAddExecuteTick: DWord;
    IdFilesSnapshotsFirst: Integer;
    IdFilesSnapshotsLast: Integer;
    IdFilesSnapshotAdd: Integer;
    IdFilesSnapshotManage: Integer;
    IdReopen: Integer;
    FFilesSnapshots: TStringList;
    FReOpener: TCnFileReopener;
    FSnapSection: string;
    procedure InternalLoadSettings(Ini: TCustomIniFile);
    procedure InternalSaveSettings(Ini: TCustomIniFile);
    procedure FilesSnapshotAdd;
    procedure FilesSnapshotManage;
    function IsAnyFileOpen: Boolean;
    procedure FilesRestore(Index: Integer);
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState; override;
    procedure AcquireSubActions; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;
  end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

// todo: 这部分代码应该提取到相应单元或新建单元中，如果其它地方也需要
type
  TCnSourceFileType = (sftGroup, sftProject, sftHeader, sftUnit, sftForm, sftOthers);

function GetSourceFileType(const AFileName: string): TCnSourceFileType;
begin
  Result := sftOthers;
  // todo: 对于用户定义的不同语言源文件扩展名，应该允许分类，以避免此处的硬编码
  if FileMatchesExts(AFileName, '.bpg;.bdsgroup;.groupproj') then
    Result := sftGroup
  else if FileMatchesExts(AFileName, '.dpr;.dpk;.bdsproj;.dproj;.cbproj;.bpr;.bpk') then
    Result := sftProject
  else if FileMatchesExts(AFileName, '.h;.hpp') then
    Result := sftHeader
  else if FileMatchesExts(AFileName, '.pas;.c;.cpp') then
    Result := sftUnit
  else if FileMatchesExts(AFileName, '.dfm;.xfm') then
    Result := sftForm
end;

//==============================================================================
// 文件列表快照专家
//==============================================================================

const
  csSnapshots = 'Snapshots';

{ TCnFilesSnapshotWizard }

constructor TCnFilesSnapshotWizard.Create;
begin
  inherited;
  FExecuting := False;
  FLastAddExecuteTick := 0;
  FFilesSnapshots := TStringList.Create;
  FReOpener := TCnFileReopener.Create;
  FSnapSection := csSnapshots + '.' + WizOptions.CompilerID;
end;

destructor TCnFilesSnapshotWizard.Destroy;
var
  i: Integer;
begin
  for i := 0 to FFilesSnapshots.Count - 1 do
    FFilesSnapshots.Objects[i].Free;
  FFilesSnapshots.Free;
  FReOpener.Free;
  inherited;
end;

procedure TCnFilesSnapshotWizard.AcquireSubActions;
var
  i: Integer;
begin
  // 若没有快照，则不必创建快照菜单项和分隔符
  if FFilesSnapshots.Count > 0 then
  begin
    // 创建快照菜单项
    i := 0;
    IdFilesSnapshotsFirst := RegisterASubAction(SCnFilesSnapshotsItem +
      IntToStr(i), FFilesSnapshots[i], 0, FFilesSnapshots[i],
      SCnFilesSnapshotsItem + IntToStr(i));
    IdFilesSnapshotsLast := IdFilesSnapshotsFirst; // 避免下面被跳过而没赋值，LiuXiao
    for i := 1 to FFilesSnapshots.Count - 1 do
      IdFilesSnapshotsLast := RegisterASubAction(SCnFilesSnapshotsItem +
        IntToStr(i), FFilesSnapshots[i], 0, FFilesSnapshots[i],
        SCnFilesSnapshotsItem + IntToStr(i));

    AddSepMenu;
  end
  else
  begin
    IdFilesSnapshotsFirst := -1;
    IdFilesSnapshotsLast := -1;
  end;

  // 创建其余的子菜单项
  IdFilesSnapshotAdd := RegisterASubAction(SCnFilesSnapshotAdd,
    SCnFilesSnapshotAddCaption, ShortCut(Word('W'), [ssCtrl, ssShift]),
    SCnFilesSnapshotAddHint, SCnFilesSnapshotAdd);

  IdFilesSnapshotManage := RegisterASubAction(SCnFilesSnapshotManage,
    SCnFilesSnapshotManageCaption, 0,
    SCnFilesSnapshotManageHint, SCnFilesSnapshotManage);
  AddSepMenu;

  IdReopen := RegisterASubAction(SCnFilesSnapshotReopen,
    SCnFilesSnapshotReopenCaption, FReOpener.GetDefShortCut,
    SCnFilesSnapshotReopenHint, SCnFilesSnapshotReopen);
end;

function TCnFilesSnapshotWizard.GetCaption: string;
begin
  Result := SCnFilesSnapshotWizardCaption;
end;

function TCnFilesSnapshotWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnFilesSnapshotWizard.GetHint: string;
begin
  Result := SCnFilesSnapshotWizardHint;
end;

function TCnFilesSnapshotWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnFilesSnapshotWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFilesSnapshotWizardName;
  Author := SCnPack_Beta + ';' + SCnPack_Leeon + ';' + SCnPack_LiuXiao;
  Email := SCnPack_BetaEmail + ';' + SCnPack_LeeonEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnFilesSnapshotWizardComment;
end;

procedure TCnFilesSnapshotWizard.SubActionExecute(Index: Integer);
begin
  if not Active or FExecuting then Exit;
  FExecuting := True;
  try
    case IndexInt(Index, [IdFilesSnapshotAdd, IdFilesSnapshotManage, IdReopen]) of
      0:        // IdFilesSnapshotAdd
        FilesSnapshotAdd;
      1:        // IdFilesSnapshotManage
        FilesSnapshotManage;
      2:
        FReOpener.Execute;
      else
      begin
        if (Index <= IdFilesSnapshotsLast) and (Index >= IdFilesSnapshotsFirst) then
          FilesRestore(Index - IdFilesSnapshotsFirst);
      end;
    end;
  finally
    FExecuting := False;
  end;
end;

procedure TCnFilesSnapshotWizard.SubActionUpdate(Index: Integer);
begin
  inherited;
  case IndexInt(Index, [IdFilesSnapshotAdd, IdFilesSnapshotManage, IdReopen]) of
    0:  // IdFilesSnapshotAdd
      SubActions[IdFilesSnapshotAdd].Enabled := IsAnyFileOpen;
    1:  // IdFilesSnapshotManage
      SubActions[IdFilesSnapshotManage].Enabled := FFilesSnapshots.Count > 0;
    2:
      SubActions[IdReopen].Enabled := True;
  end;
end;

procedure TCnFilesSnapshotWizard.FilesSnapshotAdd;

  // 获取已经打开的文件名列表
  function DoSnapshotFiles(Files: TStrings): Boolean;
  var
    i: Integer;
    iModuleServices: IOTAModuleServices;
  begin
    Files.Clear;
    QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);

    // 反序获取，因为遍历获得的文件顺序和打开时是相反的
    for i := iModuleServices.ModuleCount - 1 downto 0 do
      Files.Add(iModuleServices.Modules[i].FileName);

    Result := Files.Count > 0;
  end;

  // 打开一个工程文件会关闭已经打开的单元文件，所以应该优先打开工程文件
  function FixupFileOrders(Files: TStrings): TStrings;
  var
    i, Base: Integer;
  begin
    Result := Files;

    for i := 0 to Files.Count - 1 do
      Files.Objects[i] := TObject(GetSourceFileType(Files[i]));

    Base := 0;
    // 优先打开工程组文件
    for i := 0 to Files.Count - 1 do
      if TCnSourceFileType(Files.Objects[i]) = sftGroup then
      begin
        Files.Move(i, Base);
        Inc(Base);
      end;
    // 其次是工程文件
    for i := 0 to Files.Count - 1 do
      if TCnSourceFileType(Files.Objects[i]) = sftProject then
      begin
        Files.Move(i, Base);
        Inc(Base);
      end;
  end;

var
  Idx: Integer;
  NewName: string;
  Files, List: TStringList;
  NeedRefresh: Boolean;
begin
  // 如果是启动 Delphi 后第一次通过快捷键添加快照，则 RefreshSubActions 将导致
  // 该 Action 被重复执行，这应该是框架的问题。暂时只有通过避免该 Action 被过快
  // 的重复执行来修正。
  if GetTickCount - FLastAddExecuteTick < 300 then Exit;

  // 如果当前没有打开的文件
  if not IsAnyFileOpen then
  begin
    MessageBeep(MB_ICONWARNING);
    Exit;
  end;

  Files := TStringList.Create;
  try
    // 从输入窗口取得新的快照名
    if not DoSnapshotFiles(Files) then Exit;
    NewName := AddFilesSnapshot(FFilesSnapshots, FixupFileOrders(Files));

    // 若成功取得快照名，则将当前文件列表存入快照
    if (NewName <> '') and (Files.Count > 0) then
    begin
      Idx := FFilesSnapshots.IndexOf(NewName);
      if Idx >= 0 then
      begin
        List := TStringList(FFilesSnapshots.Objects[Idx]);
        NeedRefresh := False;
      end
      else
      begin
        List := TStringList.Create;
        FFilesSnapshots.AddObject(NewName, List);
        NeedRefresh := True;
      end;

      List.Assign(Files);

      // 若是一个新的快照名则强制刷新本专家，以使新的快照显示在专家菜单中
      if NeedRefresh then
      begin
        ClearSubActions;
        RefreshSubActions;
      end;

      DoSaveSettings;
    end;
  finally
    // 记录下最后一次执行本次操作的时间
    FLastAddExecuteTick := GetTickCount;

    Files.Free;
  end;
end;

procedure TCnFilesSnapshotWizard.FilesSnapshotManage;
var
  Ini: TCustomIniFile;
begin
  Ini := TMemIniFile.Create('');
  try
    InternalSaveSettings(Ini);
    if ManageFilesSnapshot(FFilesSnapshots) then
    begin
      ClearSubActions;
      RefreshSubActions;
      DoSaveSettings;
    end
    else
      InternalLoadSettings(Ini);
  finally
    Ini.Free;
  end;          
end;

function TCnFilesSnapshotWizard.IsAnyFileOpen: Boolean;
var
  iModuleServices: IOTAModuleServices;
begin
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  Result := (iModuleServices <> nil) and (iModuleServices.ModuleCount > 0);
end;

procedure TCnFilesSnapshotWizard.FilesRestore(Index: Integer);

  function DoRestoreFiles(Files: TStrings): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    BeginBatchOpenClose;
    try
      for i := 0 to Files.Count - 1 do
        if FileExists(Files[i]) then
          Result := CnOtaOpenFile(Files[i]) or Result;
    finally
      EndBatchOpenClose;
    end;
  end;

begin
  Assert((Index >= 0) and (Index < FFilesSnapshots.Count));

  if not DoRestoreFiles(TStringList(FFilesSnapshots.Objects[Index])) then
    MessageBeep(MB_ICONWARNING);
end;

procedure TCnFilesSnapshotWizard.InternalLoadSettings(Ini: TCustomIniFile);
var
  i: Integer;
  Files: TStringList;
begin
  for i := 0 to FFilesSnapshots.Count - 1 do
    FFilesSnapshots.Objects[i].Free;
  FFilesSnapshots.Clear;

  Ini.ReadSection(FSnapSection, FFilesSnapshots);
  for i := 0 to FFilesSnapshots.Count - 1 do
  begin
    Files := TStringList.Create;
    Files.CommaText := Ini.ReadString(FSnapSection, FFilesSnapshots[i], '');
    FFilesSnapshots.Objects[i] := Files;
  end;
end;

procedure TCnFilesSnapshotWizard.InternalSaveSettings(Ini: TCustomIniFile);
var
  i: Integer;
begin
  if Ini.SectionExists(FSnapSection) then
    Ini.EraseSection(FSnapSection);

  for i := 0 to FFilesSnapshots.Count - 1 do
    Ini.WriteString(FSnapSection, FFilesSnapshots[i],
      TStringList(FFilesSnapshots.Objects[i]).CommaText);
end;

procedure TCnFilesSnapshotWizard.LoadSettings(Ini: TCustomIniFile);
begin
  InternalLoadSettings(Ini);
  // 改变配置过后，需要更新快照菜单
  ClearSubActions;
  RefreshSubActions;
end;

procedure TCnFilesSnapshotWizard.SaveSettings(Ini: TCustomIniFile);
begin
  InternalSaveSettings(Ini);
end;

procedure TCnFilesSnapshotWizard.Config;
begin
  FilesSnapshotManage;
end;

procedure TCnFilesSnapshotWizard.SetActive(Value: Boolean);
begin
  inherited;
  if not Active then
  begin
    if FReOpener.FilesListForm <> nil then
    begin
      FReOpener.FilesListForm.Free;
      FReOpener.FilesListForm := nil;
      FormOpened := False;
    end;
  end;
end;

function TCnFilesSnapshotWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '收藏,favorite';
end;

initialization
  RegisterCnWizard(TCnFilesSnapshotWizard);

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.

