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
  ToolsAPI, IniFiles, ShellAPI, Menus, FileCtrl, {$IFDEF BDS} Variants, {$ENDIF}
  {$IFDEF DelphiXE3_UP} Actions,{$ENDIF}
  CnCommon, CnWizClasses, CnWizUtils, CnConsts, CnWizConsts, CnProjectViewUnitsFrm,
  CnProjectViewFormsFrm, CnProjectListUsedFrm, CnProjectDelTempFrm, CnIni,
  CnWizCompilerConst, CnProjectBackupFrm, CnProjectDirBuilderFrm, CnWizMethodHook,
  CnProjectFramesFrm, CnInputSymbolList;
                                           
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
    FPasUnitNameList: TCnUnitNameList;
    FCppUnitNameList: TCnUnitNameList;
  {$IFNDEF BDS}
    procedure RunSeparately;
  {$ENDIF}
    procedure ExploreProject;
    procedure ExploreUnit;
    procedure ExploreExe;
    procedure FormsListActionOnExecute(Sender: TObject);
    procedure UnitsListActionOnExecute(Sender: TObject);
  {$IFDEF SUPPORT_USE_UNIT}
    procedure UseUnitActionOnExecute(Sender: TObject);
  {$ENDIF}
  protected
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SetActive(Value: Boolean); override;
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
  CnWizIdeUtils, CnWizOptions, CnWizMenuAction, CnProjectUseUnitsFrm;

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

  // Lazy to Let UI Create them to Optimize Starting-Up Speed.
  // FPasUnitNameList := TUnitNameList.Create(True, False, False);
  // FCppUnitNameList := TUnitNameList.Create(True, True, False);
end;

destructor TCnProjectExtWizard.Destroy;
begin
  FPasUnitNameList.Free;
  FCppUnitNameList.Free;
  FMethodHook.Free;

  inherited;
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
end;

//------------------------------------------------------------------------------
// 功能执行
//------------------------------------------------------------------------------

procedure TCnProjectExtWizard.ExploreExe;
var
  Project: IOTAProject;
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
    ProjectFileName := Project.GetFileName;
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
  Project: IOTAProject;
  ProjectFileName: string;
begin
  Project := CnOtaGetCurrentProject;
  if not Assigned(Project) then
    Exit;

  ProjectFileName := Project.GetFileName;
  if ProjectFileName <> '' then
  begin
    if FileExists(ProjectFileName) then
      ExploreFile(ProjectFileName)
    else if DirectoryExists(_CnExtractFileDir(ProjectFileName)) then
      ExploreDir(_CnExtractFileDir(ProjectFileName));
  end;
end;

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

//------------------------------------------------------------------------------
// Action 处理
//------------------------------------------------------------------------------

procedure TCnProjectExtWizard.AcquireSubActions;
begin
{$IFNDEF BDS}
  IdRunSeparately := RegisterASubAction(SCnProjExtRunSeparately,
    SCnProjExtRunSeparatelyCaption, ShortCut(VK_F9, [ssShift]),
    SCnProjExtRunSeparatelyHint, SCnProjExtRunSeparately);

  AddSepMenu;
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

{$IFNDEF BDS}
  if Index = IdRunSeparately then
    RunSeparately
  else
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

  SubActions[IdExploreUnit].Enabled := CnOtaGetCurrentModule <> nil;
  SubActions[IdListUsed].Enabled := CnOtaGetCurrentModule <> nil;

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
