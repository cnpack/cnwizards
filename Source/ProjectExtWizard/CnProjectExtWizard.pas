{******************************************************************************}
{                                                                              }
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

unit CnProjectExtWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：工程扩展工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
*           张伟（Alan） BeyondStudio@163.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2021.09.09 by LiuXiao
*               抽出获取工程输出目录的函数
*           2012.09.19 by shenloqi
*               移植到 Delphi XE3
*           2005.05.10
*               Alan 新增工程目录创建器
*           2005.05.03
*               hubdog 将大部分的 ExploreDir 调用改成 ExploreFile 调用
*           2004.12.31 V3.0
*               qsoft 新加项目备份向导
*           2004.07.22 V2.0
*               LiuXiao 删除工程扩展工具中的文件列表快照
*           2004.04.27 V1.9
*               beta 通过二级子菜单支持多组文件列表快照
*           2004.04.20 V1.8
*               beta 加入打开文件列表快照功能
*           2004.3.02 V1.7
*               加入 Leeon 的历史文件管理
*           2004.2.06 V1.6
*               Leeon 优化部分代码
*           2003.9.25 V1.5
*               重新修正源码编辑器在一段时间内不响应键盘输入的BUG
*           2003.9.25 V1.4 何清(QSoft)
*               修正源码编辑器在一段时间内不响应键盘输入的BUG
*           2003.6.26 V1.3
*               新增挂接 IDE 功能
*           2003.6.7 V1.2
*               单元列表和工程列表添加了快捷键
*           2003.05.28 V1.1
*               新增工程单元列表和工程窗体列表
*           2003.05.25 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

//{$IFNDEF BDS2010_UP}
  {$DEFINE SUPPORT_USE_UNIT}
//{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ActnList,
  {$IFDEF LAZARUS} LCLProc, IDECommands, MenuIntf, {$ENDIF}
  {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} IniFiles, ShellAPI, Menus, FileCtrl,
  {$IFDEF BDS} Variants, {$ENDIF} ComCtrls, {$IFDEF DELPHIXE3_UP} Actions,{$ENDIF}
  CnCommon, CnWizClasses, CnWizUtils, CnConsts, CnWizConsts, CnProjectViewUnitsFrm,
  CnProjectViewFormsFrm, CnProjectListUsedFrm, CnProjectDelTempFrm, CnIni,
  CnWizCompilerConst, CnProjectBackupFrm, CnProjectDirBuilderFrm, CnWizMethodHook,
  CnProjectFramesFrm
  {$IFNDEF LAZARUS} // CnInputSymbolList 属于 InputHelper 目录，Lazarus 侧暂未引入且本单元未使用
  , CnInputSymbolList
  {$ENDIF};
                                           
type

//==============================================================================
// 工程扩展专家
//==============================================================================

{ TCnProjectExtWizard }

  TCnProjectExtWizard = class(TCnSubMenuWizard)
  private
  {$IFNDEF BDS}
    IdRunSeparately: Integer;
  {$ENDIF}
    IdExploreProject: Integer;
    IdExploreUnit: Integer;
    IdExploreExe: Integer;
    IdViewUnits: Integer;
    IdViewForms: Integer;
  {$IFDEF SUPPORT_USE_UNIT}
    IdUseUnits: Integer;
  {$ENDIF}
    IdListUsed: Integer;
    IdProjBackup: Integer;
    IdDelTemp: Integer;
    IdDirBuilder: Integer;
  {$IFDEF SUPPORT_FMX}
    IdConvertVclToFmx: Integer;
  {$ENDIF}
    FUnitsListAction: TContainedAction;
    FFormsListAction: TContainedAction;
    FUseUnitAction: TContainedAction;
    FOldUnitNotifyEvent: TNotifyEvent;
    FOldFormNotifyEvent: TNotifyEvent;
  {$IFDEF SUPPORT_USE_UNIT}
    FOldUseUnitNotifyEvent: TNotifyEvent;
  {$ENDIF}
    FCorIdeModule: HModule;
    FMethodHook: TCnMethodHook;
    FOldViewDialogExecute: Pointer;
{$IFDEF LAZARUS}
    // Lazarus 下的 IDE 命令挂接（取代机器码钩子，覆盖菜单/工具栏/快捷键三个入口）
    FUnitsMenuCmd: TIDEMenuCommand;        // 工程菜单中的"查看单元"命令项
    FFormsMenuCmd: TIDEMenuCommand;        // 工程菜单中的"查看窗体"命令项
    FUnitsIDECommand: TIDECommand;         // 对应的 IDE 命令对象（工具栏按钮绑定）
    FFormsIDECommand: TIDECommand;
    FOldViewUnitsMenuClick: TNotifyEvent;  // 原 OnClick（TMainIDE.mnuViewUnitsClicked）
    FOldViewFormsMenuClick: TNotifyEvent;
    FOldUnitsCmdExecute: TNotifyEvent;     // 原 OnExecute（ec 命令通常为空）
    FOldFormsCmdExecute: TNotifyEvent;
    FOldUnitsCmdExecuteProc: TNotifyProcedure;
    FOldFormsCmdExecuteProc: TNotifyProcedure;
    FOldExecuteIDECommand: TExecuteIDECommand; // 原中央分发（快捷键路径）
    FHooksInstalled: Boolean;
{$ENDIF}
{$IFNDEF LAZARUS} // 类型来自 CnInputSymbolList，Lazarus 侧暂未引入；列表本就未创建
    FPasUnitNameList: TCnUnitNameList;
    FCppUnitNameList: TCnUnitNameList;
{$ENDIF}
{$IFNDEF LAZARUS}
  {$IFNDEF BDS}
    procedure RunSeparately;
  {$ENDIF}
{$ENDIF}
    procedure ExploreProject;
    procedure ExploreUnit;
    procedure ExploreExe;
    procedure FormsListActionOnExecute(Sender: TObject);
    procedure UnitsListActionOnExecute(Sender: TObject);
{$IFDEF LAZARUS}
    procedure LazInstallHooks;
    {* 查找并替换 IDE 的查看单元/窗体命令入口（菜单 + 工具栏 + 中央分发）}
    procedure LazUninstallHooks;
    {* 还原全部挂接}
    procedure LazViewUnitsExec(Sender: TObject);
    {* 挂接后的"查看单元"执行体：按开关决定显示 CnPack 列表或调用原行为}
    procedure LazViewFormsExec(Sender: TObject);
    {* 挂接后的"查看窗体"执行体}
    function LazExecuteIDECommand(Sender: TObject; Command: word): Boolean;
    {* 中央分发包装器：拦截查看单元/窗体的命令字，其余透传}
    function FindMenuCmd(ASection: TIDEMenuSection;
      const AName: string): TIDEMenuCommand;
    {* 在菜单 section 及其子 section 中递归查找指定名称的命令项}
{$ENDIF}
  {$IFDEF SUPPORT_USE_UNIT}
    procedure UseUnitActionOnExecute(Sender: TObject);
  {$ENDIF}
  protected
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SetActive(Value: Boolean); override;

    procedure CommandNotify(const Command: Cardinal; const SourceID: PAnsiChar;
      const DestID: PAnsiChar; const IDESets: TCnCompilers; const Params: TStrings);
  public
    procedure UpdateActionHook(HookUnitsList, HookFormsList, HookUseUnit: Boolean);
    procedure UpdateMethodHook(HookUseUnit: Boolean);
    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure Loaded; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure AcquireSubActions; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

var
  UnitsListHookBtnChecked: Boolean;
  FormsListHookBtnChecked: Boolean;
  UseUnitsHookBtnChecked: Boolean;
  FrameInsertHookBtnChecked: Boolean;

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  {$IFDEF SUPPORT_FMX} CnVclToFmxIntf, {$ENDIF}
  CnWizIdeUtils, CnWizOptions, CnWizMenuAction, CnWizCmdNotify,
  CnWizCmdMsg
  {$IFNDEF LAZARUS} // UseUnits 链依赖 InputHelper 的 CnInputSymbolList，且 SUPPORT_USE_UNIT 从未启用
  , CnProjectUseUnitsFrm
  {$ENDIF};

const
{$IFDEF WIN64}
  SCnViewDialogExecuteName = '_ZN7Viewdlg11TViewDialog7ExecuteEv';
{$ELSE}
  SCnViewDialogExecuteName = '@Viewdlg@TViewDialog@Execute$qqrv';
{$ENDIF}

{$IFDEF SUPPORT_FMX}
  {$IFDEF WIN64}
  SCnVclToFmxDllName = 'CnVclToFmx64.dll';
  {$ELSE}
  SCnVclToFmxDllName = 'CnVclToFmx.dll';
  {$ENDIF}
{$ENDIF}

//==============================================================================
// 工程扩展专家
//==============================================================================

{ TCnProjectExtWizard }

constructor TCnProjectExtWizard.Create;
begin
  inherited;
{$IFDEF DELPHI_OTA}
  FCorIdeModule := GetModuleHandle(CorIdeLibName);
  if FCorIdeModule <> 0 then
  begin
    FOldViewDialogExecute := GetProcAddress(FCorIdeModule, SCnViewDialogExecuteName);
    if FOldViewDialogExecute <> nil then
    begin
      FOldViewDialogExecute := GetBplMethodAddress(FOldViewDialogExecute);
      if FOldViewDialogExecute <> nil then
      begin
        FMethodHook := TCnMethodHook.Create(FOldViewDialogExecute, @ShowProjectInsertFrame);
        FMethodHook.UnhookMethod;
      end;
    end;
  end;
{$ENDIF}

  CnWizCmdNotifier.AddCmdNotifier(CommandNotify);

  // Lazy to Let UI Create them to Optimize Starting-Up Speed.
  // FPasUnitNameList := TUnitNameList.Create(True, False, False);
  // FCppUnitNameList := TUnitNameList.Create(True, True, False);
end;

destructor TCnProjectExtWizard.Destroy;
begin
{$IFDEF LAZARUS}
  LazUninstallHooks;
{$ENDIF}
  CnWizCmdNotifier.RemoveCmdNotifier(CommandNotify);

{$IFNDEF LAZARUS}
  FPasUnitNameList.Free;
  FCppUnitNameList.Free;
{$ENDIF}
  FMethodHook.Free;

  inherited;
end;

procedure TCnProjectExtWizard.CommandNotify(const Command: Cardinal;
  const SourceID, DestID: PAnsiChar; const IDESets: TCnCompilers;
  const Params: TStrings);
var
  I: Integer;
  S: string;
  F: TCustomForm;
  Lv: TListView;
begin
  if Command = CN_WIZ_CMD_LVCOLUMN_WIDTH then
  begin
{$IFDEF DEBUG}
    F := Screen.ActiveCustomForm;
    if F = nil then
      Exit;

    Lv := nil;
    for I := 0 to F.ComponentCount - 1 do
    begin
      if F.Components[I] is TListView then
      begin
        Lv := TListView(F.Components[I]);
        Break;
      end;
    end;

    if Lv = nil then
      Exit;

    S := '';
{$IFDEF DELPHI_OTA}
{$IFDEF IDE_SUPPORT_HDPI}
    S := FloatToStr(Lv.CurrentPPI / Windows.USER_DEFAULT_SCREEN_DPI);
{$ENDIF}
{$ENDIF}
    for I := 0 to Lv.Columns.Count - 1 do
      S := S + ' ' + IntToStr(Lv.Columns[I].Width);

    CnDebugger.LogMsg('CN_WIZ_CMD_LVCOLUMN_WIDTH: ' + S);
{$ENDIF}
  end;
end;

procedure TCnProjectExtWizard.Loaded;
begin
  inherited;
  // 取得 Action
  FUnitsListAction := FindIDEAction('ViewUnitCommand');
  FFormsListAction := FindIDEAction('ViewFormCommand');
  FUseUnitAction := FindIDEAction(SCnUseUnitActionName);

  // 保存原 Action
  if (FUnitsListAction <> nil) and not Assigned(FOldUnitNotifyEvent) then
    FOldUnitNotifyEvent := FUnitsListAction.OnExecute;
  if (FFormsListAction <> nil) and not Assigned(FOldFormNotifyEvent) then
    FOldFormNotifyEvent := FFormsListAction.OnExecute;
{$IFDEF SUPPORT_USE_UNIT}
  if (FUseUnitAction <> nil) and not Assigned(FOldUseUnitNotifyEvent) then
    FOldUseUnitNotifyEvent := FUseUnitAction.OnExecute;
{$ENDIF}

  // 更新对应 IDE 的 Action
  if Active then
    UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked, UseUnitsHookBtnChecked);

{$IFDEF LAZARUS}
  // Lazarus：挂接 IDE 的查看单元/窗体命令（菜单 + 工具栏 + 快捷键）
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProjExt Loaded: Begin LazInstallHooks.');
{$ENDIF}
  LazInstallHooks;
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 功能执行
//------------------------------------------------------------------------------

procedure TCnProjectExtWizard.ExploreExe;
var
  Project: TCnIDEProjectInterface;
  Dir, ProjectFileName, OutName: string;
begin
  Project := CnOtaGetCurrentProject;
  if not Assigned(Project) then
    Exit;

  OutName := CnOtaGetProjectOutputTarget(Project);
  if (OutName <> '') and FileExists(OutName) then
    ExploreFile(OutName)
  else
  begin
{$IFDEF DELPHI_OTA}
    ProjectFileName := Project.GetFileName;
{$ENDIF}
{$IFDEF LAZARUS}
    ProjectFileName := Project.MainFile.Filename;
{$ENDIF}

    if ProjectFileName <> '' then
    begin
      Dir := CnOtaGetProjectOutputDirectory(Project);
      if (Dir <> '') and DirectoryExists(Dir) then
        ExploreDir(Dir);
    end;
  end;
end;

procedure TCnProjectExtWizard.ExploreUnit;
var
  FileName: string;
begin
  FileName := CnOtaGetCurrentSourceFile;
  if FileName <> '' then
  begin
    if FileExists(FileName) then
      ExploreFile(FileName)
    else if DirectoryExists(_CnExtractFileDir(FileName)) then
      ExploreDir(_CnExtractFileDir(FileName));
  end;
end;

procedure TCnProjectExtWizard.ExploreProject;
var
  Project: TCnIDEProjectInterface;
  ProjectFileName: string;
begin
  Project := CnOtaGetCurrentProject;
  if not Assigned(Project) then
    Exit;

{$IFDEF DELPHI_OTA}
  ProjectFileName := Project.GetFileName;
{$ENDIF}
{$IFDEF LAZARUS}
  ProjectFileName := Project.MainFile.Filename;
{$ENDIF}

  if ProjectFileName <> '' then
  begin
    if FileExists(ProjectFileName) then
      ExploreFile(ProjectFileName)
    else if DirectoryExists(_CnExtractFileDir(ProjectFileName)) then
      ExploreDir(_CnExtractFileDir(ProjectFileName));
  end;
end;

{$IFNDEF LAZARUS}
{$IFNDEF BDS}

procedure TCnProjectExtWizard.RunSeparately;
var
  Project: IOTAProject;
  ProjectBuilder: IOTAProjectBuilder;
  HostApp, RunParams: Variant;
  Params, OutputDir, ProjectFileName, ExeName, ProjectExt: string;
begin
  Project := CnOtaGetCurrentProject;
  if not Assigned(Project) then
    Exit;

  ProjectFileName := Project.GetFileName;
  ProjectExt := _CnExtractFileExt(ProjectFileName);

  if IndexStr(ProjectExt, ['.dpr', '.cpp', '.bpr', 'dpk', 'bpk']) < 0 then Exit;

  // 编译工程
  ProjectBuilder := Project.GetProjectBuilder;
  // Exit if failure
  if ProjectBuilder.ShouldBuild and not ProjectBuilder.BuildProject(cmOTAMake, False) then
    Exit;

  // 取 Host 程序
  if CnOtaGetActiveProjectOption('HostApplication', HostApp) then
    ExeName := ReplaceToActualPath(HostApp, Project);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('HostApplication: ' + HostApp);
{$ENDIF}

  // 取运行参数
  CnOtaGetActiveProjectOption('RunParams', RunParams);
  Params := RunParams;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('RunParams: ' + Params);
{$ENDIF}

  // 无宿主程序
  if ExeName = '' then
  begin
    OutputDir := CnOtaGetProjectOutputDirectory(Project);
    ExeName := MakePath(OutputDir) + _CnChangeFileExt(_CnExtractFileName(ProjectFileName), '.exe');
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('ExeName: ' + ExeName);
{$ENDIF}

  // 执行程序
  if FileExists(ExeName) then
    ShellExecute(0, 'open', PChar(ExeName), PChar(Params),
      PChar(_CnExtractFileDir(ExeName)), SW_SHOWNORMAL);
end;

{$ENDIF}
{$ENDIF}

//------------------------------------------------------------------------------
// Action 处理
//------------------------------------------------------------------------------

procedure TCnProjectExtWizard.AcquireSubActions;
begin
{$IFNDEF LAZARUS}
{$IFNDEF BDS}
  IdRunSeparately := RegisterASubAction(SCnProjExtRunSeparately,
    SCnProjExtRunSeparatelyCaption, ShortCut(VK_F9, [ssShift]),
    SCnProjExtRunSeparatelyHint, SCnProjExtRunSeparately);

  AddSepMenu;
{$ENDIF}
{$ENDIF}

  IdExploreUnit := RegisterASubAction(SCnProjExtExploreUnit,
    SCnProjExtExploreUnitCaption, 0,
    SCnProjExtExploreUnitHint, SCnProjExtExploreUnit);

  IdExploreProject := RegisterASubAction(SCnProjExtExploreProject,
    SCnProjExtExploreProjectCaption, 0,
    SCnProjExtExploreProjectHint, SCnProjExtExploreProject);

  IdExploreExe := RegisterASubAction(SCnProjExtExploreExe,
    SCnProjExtExploreExeCaption, TextToShortCut('Ctrl+\'),
    SCnProjExtExploreExeHint, SCnProjExtExploreExe);

  AddSepMenu;

  IdViewUnits := RegisterASubAction(SCnProjExtViewUnits,
    SCnProjExtViewUnitsCaption, ShortCut(Word('U'), [ssCtrl]),
    SCnProjExtViewUnitsHint, SCnProjExtViewUnits);

  IdViewForms := RegisterASubAction(SCnProjExtViewForms,
    SCnProjExtViewFormsCaption, 0,
    SCnProjExtViewFormsHint, SCnProjExtViewForms);

 {$IFDEF SUPPORT_USE_UNIT}
  IdUseUnits := RegisterASubAction(SCnProjExtUseUnits,
    SCnProjExtUseUnitsCaption, 0,
    SCnProjExtUseUnitsHint, SCnProjExtUseUnits);
{$ENDIF}

  IdListUsed := RegisterASubAction(SCnProjExtListUsed,
    SCnProjExtListUsedCaption, 0,
    SCnProjExtListUsedHint, SCnProjExtListUsed);

  AddSepMenu;

  IdProjBackup := RegisterASubAction(SCnProjExtBackup,
    SCnProjExtBackupCaption, 0,
    SCnProjExtBackupHint, SCnProjExtBackup);

  IdDelTemp := RegisterASubAction(SCnProjExtDelTemp,
    SCnProjExtDelTempCaption, 0,
    SCnProjExtDelTempHint, SCnProjExtDelTemp);

  IdDirBuilder := RegisterASubAction(SCnProjExtDirBuilder,
    SCnProjExtDirBuilderCaption, 0,
    SCnProjExtDirBuilderHint, SCnProjExtDirBuilder);

{$IFDEF SUPPORT_FMX}
  AddSepMenu;

  IdConvertVclToFmx := RegisterASubAction(SCnProjExtVclToFmx,
    SCnProjExtVclToFmxCaption, 0,
    SCnProjExtVclToFmxHint, SCnProjExtVclToFmx);;
{$ENDIF}
end;

procedure TCnProjectExtWizard.SubActionExecute(Index: Integer);
var
  Ini: TCustomIniFile;
{$IFDEF SUPPORT_FMX}
  VFHandle: HModule;
  VFProc: TCnGetVclToFmxConverter;
  VFIntf: ICnVclToFmxIntf;
  DlgOpen: TOpenDialog;
  DlgSave: TSaveDialog;
{$ENDIF}
begin
  if not Active then
    Exit;

{$IFNDEF LAZARUS}
{$IFNDEF BDS}
  if Index = IdRunSeparately then
    RunSeparately
  else
{$ENDIF}
{$ENDIF}
  if Index = IdExploreUnit then
    ExploreUnit
  else if Index = IdExploreProject then
    ExploreProject
  else if Index = IdExploreExe then
    ExploreExe
  else if Index = IdViewUnits then
  begin
    Ini := CreateIniFile;
    try
      ShowProjectViewUnits(Ini, UnitsListHookBtnChecked);
      UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked, UseUnitsHookBtnChecked);
    finally
      Ini.Free;
    end;
  end
  else if Index = IdViewForms then
  begin
    Ini := CreateIniFile;
    try
      ShowProjectViewForms(Ini, FormsListHookBtnChecked);
      UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked, UseUnitsHookBtnChecked);
    finally
      Ini.Free;
    end;
  end
{$IFDEF SUPPORT_USE_UNIT}
  else if Index = IdUseUnits then
  begin
{$IFDEF DELPHI_OTA}
    Ini := CreateIniFile;
    try
      if CurrentSourceIsC then
        ShowProjectUseUnits(Ini, UseUnitsHookBtnChecked, FCppUnitNameList)
      else
        ShowProjectUseUnits(Ini, UseUnitsHookBtnChecked, FPasUnitNameList);

      UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked, UseUnitsHookBtnChecked);

      // 一并处理 Frame 插入的 Hook
      if Active and FrameInsertHookBtnChecked and (FMethodHook <> nil) then
        FMethodHook.HookMethod;
    finally
      Ini.Free;
    end;
{$ENDIF}
  end
{$ENDIF}
  else if Index = IdListUsed then
  begin
    Ini := CreateIniFile;
    try
      ShowProjectListUsed(Ini);
    finally
      Ini.Free;
    end;
  end
  else if Index = IdProjBackup then
  begin
    begin
      Ini := CreateIniFile;
      try
        ShowProjectBackupForm(Ini);
      finally
        Ini.Free;
      end;
    end;
  end
  else if Index = IdDelTemp then
  begin
    Ini := CreateIniFile;
    try
      ShowProjectDelTempForm(Ini);
    finally
      Ini.Free;
    end;
  end
  else if Index = IdDirBuilder then
  begin
    Ini := CreateIniFile;
    // 由内部释放，此处无需再 Free
    ShowProjectDirBuilder(Ini);
  end
  else
  begin
{$IFDEF SUPPORT_FMX}
    if Index = IdConvertVclToFmx then
    begin
      VFHandle := Loadlibrary(PChar(MakePath(WizOptions.DllPath) + SCnVclToFmxDllName));
      if VFHandle <> 0 then
      begin
        DlgOpen := nil;
        DlgSave := nil;

        try
          VFProc := TCnGetVclToFmxConverter(GetProcAddress(VFHandle, 'GetVclToFmxConverter'));
          if Assigned(VFProc) then
          begin
            VFIntf := VFProc();
            if VFIntf <> nil then
            begin
              DlgOpen := TOpenDialog.Create(nil);
              DlgOpen.Filter := '*.dfm|*.dfm';
              DlgOpen.DefaultExt := '*.dfm';

              if DlgOpen.Execute then
              begin
                try
                  if VFIntf.OpenAndConvertFile(PChar(DlgOpen.FileName)) then
                  begin
                    DlgSave := TSaveDialog.Create(nil);
                    DlgSave.Filter := '*.fmx|*.fmx';
                    DlgSave.DefaultExt := '*.fmx';

                    DlgSave.FileName := _CnChangeFileExt(_CnExtractFileName(DlgOpen.FileName), '.fmx');
                    if DlgSave.Execute then
                    begin
                      if VFIntf.SaveNewFile(PChar(DlgSave.FileName)) then
                        InfoDlg(SCnProjExtVclToFmxConvertOK)
                      else
                        ErrorDlg(SCnProjExtVclToFmxConvertError);
                    end;
                  end
                  else
                    ErrorDlg(SCnProjExtVclToFmxConvertError);
                except
                  ErrorDlg(SCnProjExtVclToFmxConvertError);
                end;
              end;
            end;
          end;
        finally
          DlgSave.Free;
          DlgOpen.Free;
          FreeLibrary(VFHandle);
        end;
      end;
    end;
{$ENDIF}
  end;
end;

procedure TCnProjectExtWizard.SubActionUpdate(Index: Integer);
var
  AEnabled: Boolean;

  procedure SetVisible(aIndex: array of Integer; aValue: Boolean);
  var
    i: Integer;
  begin
    for i:= Low(aIndex) to High(aIndex) do
      SubActions[aIndex[i]].Visible := aValue;
  end;

  procedure SetEnabled(aIndex: array of Integer; aValue: Boolean);
  var
    i: Integer;
  begin
    for i:= Low(aIndex) to High(aIndex) do
      SubActions[aIndex[i]].Enabled := aValue;
  end;
begin
  AEnabled := CnOtaGetCurrentProject <> nil;
  
{$IFNDEF BDS}
  SetVisible([IdRunSeparately], Active);
  SetEnabled([IdRunSeparately], AEnabled);
{$ENDIF}

  SetVisible([IdExploreUnit, IdExploreProject, IdExploreExe, IdDelTemp], Active);
  SetEnabled([IdExploreProject, IdExploreExe], AEnabled);
  
  SetVisible([IdProjBackup], Active);
  SetEnabled([IdProjBackup], AEnabled);

{$IFDEF SUPPORT_USE_UNIT}
//  if FUseUnitAction <> nil then
//  begin
//    SetEnabled([IdUseUnits], (FUseUnitAction as TCustomAction).Enabled);
//    SetVisible([IdUseUnits], True);
//  end
//  else
  SetEnabled([IdUseUnits], CurrentSourceIsDelphiOrCSource);
  SetVisible([IdUseUnits], True);
{$ENDIF}

  if FUnitsListAction is TCustomAction then
  begin
    TCustomAction(FUnitsListAction).Update;
    AEnabled := AEnabled or TCustomAction(FUnitsListAction).Enabled;
  end;

  SetVisible([IdViewUnits, IdViewForms], Active);
  SetEnabled([IdViewUnits, IdViewForms], AEnabled);

{$IFDEF DELPHI_OTA}
  SubActions[IdExploreUnit].Enabled := CnOtaGetCurrentModule <> nil;
  SubActions[IdListUsed].Enabled := CnOtaGetCurrentModule <> nil;
{$ENDIF}

{$IFDEF LAZARUS}
  SubActions[IdExploreUnit].Enabled := CnOtaGetCurrentSourceEditor <> nil;
  SubActions[IdListUsed].Enabled := CnOtaGetCurrentSourceEditor <> nil;
{$ENDIF}

  SubActions[IdDelTemp].Enabled := AEnabled;
  SubActions[IdDirBuilder].Enabled := True;
end;

procedure TCnProjectExtWizard.UnitsListActionOnExecute(Sender: TObject);
begin
  if Active and UnitsListHookBtnChecked then
     SubActionExecute(IdViewUnits)   // 执行 SubActionExecute 方法中的 IdViewUnits
  else
  begin
    // 不挂接，则需要取消 ViewDialogExecute 的挂接后跳回 IDE 原有的内容
    if FMethodHook <> nil then
      FMethodHook.UnhookMethod;
    if Assigned(FOldUnitNotifyEvent) then
      FOldUnitNotifyEvent(Sender);
    // 如果以前挂了，再恢复
    if Active and UseUnitsHookBtnChecked and (FMethodHook <> nil) then
      FMethodHook.HookMethod;
  end;
end;

procedure TCnProjectExtWizard.FormsListActionOnExecute(Sender: TObject);
begin
  if Active and FormsListHookBtnChecked then
    SubActionExecute(IdViewForms)  // 执行 SubActionExecute 方法中的 IdViewForms
  else
  begin
    // 不挂接，则需要取消 ViewDialogExecute 的挂接后跳回 IDE 原有的内容
    if FMethodHook <> nil then
      FMethodHook.UnhookMethod;
    if Assigned(FOldFormNotifyEvent) then
      FOldFormNotifyEvent(Sender);
    // 如果以前挂了，再恢复
    if Active and UseUnitsHookBtnChecked and (FMethodHook <> nil) then
      FMethodHook.HookMethod;
  end;
end;

{$IFDEF SUPPORT_USE_UNIT}

procedure TCnProjectExtWizard.UseUnitActionOnExecute(Sender: TObject);
begin
  if Active and UseUnitsHookBtnChecked then
    SubActionExecute(IdUseUnits)  // 执行 SubActionExecute 方法中的 IdUseUnits
  else
  begin
    // 不挂接，则需要取消 ViewDialogExecute 的挂接后跳回 IDE 原有的内容
    if FMethodHook <> nil then
      FMethodHook.UnhookMethod;
    if Assigned(FOldUseUnitNotifyEvent) then
      FOldUseUnitNotifyEvent(Sender);
    // 如果以前挂了，再恢复
    if Active and UseUnitsHookBtnChecked and (FMethodHook <> nil) then
      FMethodHook.HookMethod;
  end;
end;

{$ENDIF}

procedure TCnProjectExtWizard.UpdateActionHook(HookUnitsList, HookFormsList,
  HookUseUnit: Boolean);
begin
  // 实际上强行进行挂接，
  // 在挂接后的内容中才处理是否挂接的参数而决定调用新的还是旧的
  if FUnitsListAction = nil then
    FUnitsListAction := FindIDEAction('ViewUnitCommand');

  if FUnitsListAction <> nil then
  begin
    if not Assigned(FOldUnitNotifyEvent) then
      FOldUnitNotifyEvent := FUnitsListAction.OnExecute;
    FUnitsListAction.OnExecute := UnitsListActionOnExecute;
    UnitsListHookBtnChecked := HookUnitsList;
  end;

  if FFormsListAction = nil then
    FFormsListAction := FindIDEAction('ViewFormCommand');

  if FFormsListAction <> nil then
  begin
    if not Assigned(FOldFormNotifyEvent) then
      FOldFormNotifyEvent := FFormsListAction.OnExecute;
    FFormsListAction.OnExecute := FormsListActionOnExecute;
    FormsListHookBtnChecked := HookFormsList;
  end;

{$IFDEF SUPPORT_USE_UNIT}
  if FUseUnitAction = nil then
    FUseUnitAction := FindIDEAction(SCnUseUnitActionName);

  if FUseUnitAction <> nil then
  begin
    if not Assigned(FOldUseUnitNotifyEvent) then
      FOldUseUnitNotifyEvent := FUseUnitAction.OnExecute;
    FUseUnitAction.OnExecute := UseUnitActionOnExecute;
    UseUnitsHookBtnChecked := HookUseUnit;
  end;
{$ENDIF}
  // 恢复时不直接恢复 OnExecute，而是在挂接后的内容中做必要处理再跳回来
  // FUnitsListAction.OnExecute := FOldUnitNotifyEvent;
  // FFormsListAction.OnExecute := FOldFormNotifyEvent;
  // FUseUnitAction.OnExecute := FOldUseUnitNotifyEvent;
end;

{$IFDEF LAZARUS}

// 在菜单 section 及其子 section 中递归查找指定名称的命令项
function TCnProjectExtWizard.FindMenuCmd(ASection: TIDEMenuSection;
  const AName: string): TIDEMenuCommand;
var
  I: Integer;
  Child: TIDEMenuItem;
begin
  Result := nil;
  if ASection = nil then
    Exit;

  // 先查直接子命令项
  if ASection.FindByName(AName) is TIDEMenuCommand then
    Result := TIDEMenuCommand(ASection.FindByName(AName));

  // 再递归查子 section
  if Result = nil then
    for I := 0 to ASection.Count - 1 do
    begin
      Child := ASection.Items[I];
      if Child is TIDEMenuSection then
      begin
        Result := FindMenuCmd(TIDEMenuSection(Child), AName);
        if Result <> nil then
          Exit;
      end;
    end;
end;

// 查找并替换 IDE 的查看单元/窗体命令入口
procedure TCnProjectExtWizard.LazInstallHooks;
var
  Section: TIDEMenuSection;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazInstallHooks Enter. Roots=%p IDECmdList=%p',
    [Pointer(IDEMenuRoots), Pointer(IDECommandList)]);
{$ENDIF}
  if FHooksInstalled then
    Exit;

  // 1. IDE 命令对象（工具栏按钮绑定的就是它）
  FUnitsIDECommand := IDECommandList.FindIDECommand(ecViewProjectUnits);
  FFormsIDECommand := IDECommandList.FindIDECommand(ecViewProjectForms);

  // 2. 工程菜单中的命令项（递归查找，位置可能随 IDE 版本调整）
  Section := IDEMenuRoots.FindByName('Project');
  if Section <> nil then
  begin
    FUnitsMenuCmd := FindMenuCmd(Section, 'itmProjectViewUnits');
    FFormsMenuCmd := FindMenuCmd(Section, 'itmProjectViewForms');
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazInstallHooks Found: Section=%p ' +
    'UnitsCmd=%p FormsCmd=%p UnitsMenu=%p FormsMenu=%p',
    [Pointer(Section), Pointer(FUnitsIDECommand), Pointer(FFormsIDECommand),
     Pointer(FUnitsMenuCmd), Pointer(FFormsMenuCmd)]);
  if FUnitsIDECommand <> nil then
    CnDebugger.LogMsg('ProjExt LazInstallHooks: UnitsIDECommand Name=' +
      FUnitsIDECommand.Name);
  if FFormsIDECommand <> nil then
    CnDebugger.LogMsg('ProjExt LazInstallHooks: FormsIDECommand Name=' +
      FFormsIDECommand.Name);
{$ENDIF}

  // 3. 保存原值并替换。菜单 OnClick 与命令 OnExecute 都指向同一执行体，
  //    执行体内部再按挂接开关决定显示 CnPack 列表还是回退原行为
  if FUnitsIDECommand <> nil then
  begin
    FOldUnitsCmdExecute := FUnitsIDECommand.OnExecute;
    FOldUnitsCmdExecuteProc := FUnitsIDECommand.OnExecuteProc;
    FUnitsIDECommand.OnExecute := LazViewUnitsExec;
  end;
  if FFormsIDECommand <> nil then
  begin
    FOldFormsCmdExecute := FFormsIDECommand.OnExecute;
    FOldFormsCmdExecuteProc := FFormsIDECommand.OnExecuteProc;
    FFormsIDECommand.OnExecute := LazViewFormsExec;
  end;

  if FUnitsMenuCmd <> nil then
  begin
    FOldViewUnitsMenuClick := FUnitsMenuCmd.OnClick;
    FUnitsMenuCmd.OnClick := LazViewUnitsExec;
  end;
  if FFormsMenuCmd <> nil then
  begin
    FOldViewFormsMenuClick := FFormsMenuCmd.OnClick;
    FFormsMenuCmd.OnClick := LazViewFormsExec;
  end;

  // 4. 中央分发（快捷键等入口），包装器只拦截两个命令字、其余透传
  FOldExecuteIDECommand := OnExecuteIDECommand;
  OnExecuteIDECommand := LazExecuteIDECommand;

  FHooksInstalled := (FUnitsMenuCmd <> nil) or (FUnitsIDECommand <> nil)
    or (FFormsMenuCmd <> nil) or (FFormsIDECommand <> nil);

{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazInstallHooks Done. Installed=%s',
    [BoolToStr(FHooksInstalled, True)]);
  if not FHooksInstalled then
    CnDebugger.LogMsgError('ProjExt: Laz Hook Install Failed. No Entry Found.');
{$ENDIF}
end;

// 还原全部挂接
procedure TCnProjectExtWizard.LazUninstallHooks;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazUninstallHooks Enter. Installed=%s IdeClosing=%s',
    [BoolToStr(FHooksInstalled, True), BoolToStr(IdeClosing, True)]);
{$ENDIF}
  if not FHooksInstalled then
    Exit;

  if IdeClosing then
  begin
    // IDE 关闭阶段菜单与命令对象可能已随 IDE 释放，不触碰，放弃引用即可
    FUnitsMenuCmd := nil;
    FFormsMenuCmd := nil;
    FUnitsIDECommand := nil;
    FFormsIDECommand := nil;
    FOldExecuteIDECommand := nil;
    FHooksInstalled := False;
    Exit;
  end;

  if FUnitsIDECommand <> nil then
  begin
    FUnitsIDECommand.OnExecute := FOldUnitsCmdExecute;
    FUnitsIDECommand.OnExecuteProc := FOldUnitsCmdExecuteProc;
  end;
  if FFormsIDECommand <> nil then
  begin
    FFormsIDECommand.OnExecute := FOldFormsCmdExecute;
    FFormsIDECommand.OnExecuteProc := FOldFormsCmdExecuteProc;
  end;

  if FUnitsMenuCmd <> nil then
    FUnitsMenuCmd.OnClick := FOldViewUnitsMenuClick;
  if FFormsMenuCmd <> nil then
    FFormsMenuCmd.OnClick := FOldViewFormsMenuClick;

  OnExecuteIDECommand := FOldExecuteIDECommand;

  FUnitsMenuCmd := nil;
  FFormsMenuCmd := nil;
  FUnitsIDECommand := nil;
  FFormsIDECommand := nil;
  FOldExecuteIDECommand := nil;
  FHooksInstalled := False;
end;

// 挂接后的"查看单元"执行体
procedure TCnProjectExtWizard.LazViewUnitsExec(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazViewUnitsExec Enter. Sender=%s Active=%s Hooked=%s ' +
    'OldClick=%p OldExec=%p',
    [DbgSName(Sender), BoolToStr(Active, True), BoolToStr(UnitsListHookBtnChecked, True),
     Pointer(TMethod(FOldViewUnitsMenuClick).Code),
     Pointer(TMethod(FOldUnitsCmdExecute).Code)]);
{$ENDIF}
  if Active and UnitsListHookBtnChecked then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazViewUnitsExec: Show CnPack Units List.');
{$ENDIF}
    SubActionExecute(IdViewUnits);   // CnPack 列表对话框内部自行打开选中文件
  end
  else if Assigned(FOldViewUnitsMenuClick) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazViewUnitsExec: Fallback to Old MenuClick.');
{$ENDIF}
    FOldViewUnitsMenuClick(Sender)  // 原生"查看单元"对话框
  end
  else if Assigned(FOldUnitsCmdExecute) then
    FOldUnitsCmdExecute(Sender)
  else if Assigned(FOldUnitsCmdExecuteProc) then
    FOldUnitsCmdExecuteProc(Sender);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProjExt LazViewUnitsExec Exit.');
{$ENDIF}
end;

// 挂接后的"查看窗体"执行体
procedure TCnProjectExtWizard.LazViewFormsExec(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazViewFormsExec Enter. Sender=%s Active=%s Hooked=%s ' +
    'OldClick=%p OldExec=%p',
    [DbgSName(Sender), BoolToStr(Active, True), BoolToStr(FormsListHookBtnChecked, True),
     Pointer(TMethod(FOldViewFormsMenuClick).Code),
     Pointer(TMethod(FOldFormsCmdExecute).Code)]);
{$ENDIF}
  if Active and FormsListHookBtnChecked then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazViewFormsExec: Show CnPack Forms List.');
{$ENDIF}
    SubActionExecute(IdViewForms)
  end
  else if Assigned(FOldViewFormsMenuClick) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazViewFormsExec: Fallback to Old MenuClick.');
{$ENDIF}
    FOldViewFormsMenuClick(Sender)
  end
  else if Assigned(FOldFormsCmdExecute) then
    FOldFormsCmdExecute(Sender)
  else if Assigned(FOldFormsCmdExecuteProc) then
    FOldFormsCmdExecuteProc(Sender);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProjExt LazViewFormsExec Exit.');
{$ENDIF}
end;

// 中央分发包装器：只拦截两个命令字，其余透传给 IDE 原处理器
function TCnProjectExtWizard.LazExecuteIDECommand(Sender: TObject;
  Command: word): Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('ProjExt LazExecuteIDECommand Enter. Command=%d Sender=%s',
    [Command, DbgSName(Sender)]);
{$ENDIF}
  if Command = ecViewProjectUnits then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazExecuteIDECommand: Intercept ViewUnits.');
{$ENDIF}
    LazViewUnitsExec(Sender);
    Result := True;
  end
  else if Command = ecViewProjectForms then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('ProjExt LazExecuteIDECommand: Intercept ViewForms.');
{$ENDIF}
    LazViewFormsExec(Sender);
    Result := True;
  end
  else if Assigned(FOldExecuteIDECommand) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ProjExt LazExecuteIDECommand: Forward Command=%d', [Command]);
{$ENDIF}
    Result := FOldExecuteIDECommand(Sender, Command)
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('ProjExt LazExecuteIDECommand: No Old Handler, Command=%d Ignored.', [Command]);
{$ENDIF}
    Result := False;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('ProjExt LazExecuteIDECommand Exit.');
{$ENDIF}
end;

{$ENDIF}

// 处理挂接
procedure TCnProjectExtWizard.UpdateMethodHook(HookUseUnit: Boolean);
begin
  if FMethodHook <> nil then
  begin
    if HookUseUnit then
      FMethodHook.HookMethod
    else
      FMethodHook.UnhookMethod;
  end;
end;

procedure TCnProjectExtWizard.SetActive(Value: Boolean);
var
  Ini: TCustomIniFile;
begin
  inherited;
  // 原 IDE 的 Action 挂接标记不变，是否使用新功能在挂接的新过程中决定
  UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked, UseUnitsHookBtnChecked);
  if Value then
  begin
    Ini := CreateIniFile;
    try
      LoadSettings(Ini);
      UpdateMethodHook(UseUnitsHookBtnChecked);
    finally
      Ini.Free;
    end;
  end
  else // 禁用时取消挂接
  begin
    UpdateMethodHook(False);
  end;
end;

const
  csViewUnits = 'ViewUnits';
  csViewForms = 'ViewForms';
  csUseUnits = 'UseUnits';
  csHookIDE = 'HookIDE';

procedure TCnProjectExtWizard.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    UnitsListHookBtnChecked := ReadBool(csViewUnits, csHookIDE, True);
    FormsListHookBtnChecked := ReadBool(csViewForms, csHookIDE, True);
    UseUnitsHookBtnChecked := ReadBool(csUseUnits, csHookIDE, True);
  finally
    Free;
  end;
end;

procedure TCnProjectExtWizard.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool(csViewUnits, csHookIDE, UnitsListHookBtnChecked);
    WriteBool(csViewForms, csHookIDE, FormsListHookBtnChecked);
    WriteBool(csUseUnits, csHookIDE, UseUnitsHookBtnChecked);
  finally
    Free;
  end;
end;

procedure TCnProjectExtWizard.Config;
begin
  if ShowShortCutDialog(SCnProjExtWizard) then
    DoSaveSettings;
end;

function TCnProjectExtWizard.GetCaption: string;
begin
  Result := SCnProjExtWizardCaption;
end;

function TCnProjectExtWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnProjectExtWizard.GetHint: string;
begin
  Result := SCnProjExtWizardHint;
end;

function TCnProjectExtWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnProjectExtWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnProjExtWizardName;
  // 显示空间不够，改为每行显示两个
  Author :=
    SCnPack_Alan + ', ' + SCnPack_Hhha + #13#10 +
    SCnPack_Zjy + ', ' + SCnPack_Leeon + #13#10 +
    SCnPack_Beta;
  Email :=
    SCnPack_AlanEmail + #13#10 +
    SCnPack_HhhaEmail + #13#10 +
    SCnPack_ZjyEmail + #13#10 +
    SCnPack_LeeonEmail + #13#10 +
    SCnPack_BetaEmail;
  Comment := SCnProjExtWizardComment;
end;

procedure TCnProjectExtWizard.DebugComand(Cmds, Results: TStrings);
begin
  if Results <> nil then
  begin
    Results.Add('UnitsListHookBtnChecked: ' + IntToStr(Integer(UnitsListHookBtnChecked)));
    Results.Add('FormsListHookBtnChecked: ' + IntToStr(Integer(FormsListHookBtnChecked)));
    Results.Add('UseUnitsHookBtnChecked: ' + IntToStr(Integer(UseUnitsHookBtnChecked)));
    Results.Add('FrameInsertHookBtnChecked: ' + IntToStr(Integer(FrameInsertHookBtnChecked)));
    Results.Add('ViewDialogExecute Hooked: ' + IntToStr(Integer(FMethodHook.Hooked)));
  end;
end;

initialization
  RegisterCnWizard(TCnProjectExtWizard); // 注册专家

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
