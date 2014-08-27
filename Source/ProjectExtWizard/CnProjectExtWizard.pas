{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnProjectExtWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�������չ���ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
*           ��ΰ��Alan�� BeyondStudio@163.com
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2012.09.19 by shenloqi
*               ��ֲ��Delphi XE3
*           2005.05.10
*               Alan ��������Ŀ¼������
*           2005.05.03
*               hubdog ���󲿷ֵ�ExploreDir���øĳ�ExploreFile����
*           2004.12.31 V3.0
*               qsoft �¼���Ŀ������
*           2004.07.22 V2.0
*               LiuXiao ɾ��������չ�����е��ļ��б����
*           2004.04.27 V1.9
*               beta ͨ�������Ӳ˵�֧�ֶ����ļ��б����
*           2004.04.20 V1.8
*               beta ������ļ��б���չ���
*           2004.3.02 V1.7
*               ���� Leeon ����ʷ�ļ�����
*           2004.2.06 V1.6
*               Leeon �Ż����ִ���
*           2003.9.25 V1.5
*               ��������Դ��༭����һ��ʱ���ڲ���Ӧ���������BUG
*           2003.9.25 V1.4 ����(QSoft)
*               ����Դ��༭����һ��ʱ���ڲ���Ӧ���������BUG
*           2003.6.26 V1.3
*               �����ҽ� IDE ����
*           2003.6.7 V1.2
*               ��Ԫ�б�͹����б�����˿�ݼ�
*           2003.05.28 V1.1
*               �������̵�Ԫ�б�͹��̴����б�
*           2003.05.25 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

{$IFNDEF BDS2010_UP}
  {$DEFINE SUPPORT_USE_UNIT}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ActnList,
  ToolsAPI, IniFiles, ShellAPI, Menus, FileCtrl, {$IFDEF BDS} Variants, {$ENDIF}
  {$IFDEF DelphiXE3_UP}Actions,{$ENDIF}
  CnCommon, CnWizClasses, CnWizUtils, CnConsts, CnWizConsts, CnProjectViewUnitsFrm,
  CnProjectViewFormsFrm, CnProjectListUsedFrm, CnProjectDelTempFrm, CnIni,
  CnWizCompilerConst, CnProjectBackupFrm, CnProjectDirBuilderFrm, CnWizMethodHook;
                                           
type

//==============================================================================
// ������չר��
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
  {$IFDEF SUPPORT_PRJ_BACKUP}
    IdProjBackup: Integer;
  {$ENDIF}
    IdDelTemp: Integer;
    IdDirBuilder: Integer;

    FUnitsListAction: TContainedAction;
    FFormsListAction: TContainedAction;
    FOldUnitNotifyEvent: TNotifyEvent;
    FOldFormNotifyEvent: TNotifyEvent;

    FUseUnitAction: TContainedAction;
    FCorIdeModule: HModule;
    FMethodHook: TCnMethodHook;
    FOldViewDialogExecute: Pointer;
    function GetOutputDir: string;
  {$IFNDEF BDS}
    procedure RunSeparately;
  {$ENDIF}
    procedure ExploreProject;
    procedure ExploreUnit;
    procedure ExploreExe;
    procedure FormsListActionOnExecute(Sender: TObject);
    procedure UnitsListActionOnExecute(Sender: TObject);
  protected
    function GetHasConfig: Boolean; override;

    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SetActive(Value: Boolean); override;
  public
    procedure UpdateActionHook(HookUnitsList, HookFormsList: Boolean);
    procedure UpdateMethodHook(HookUseUnit: Boolean);
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

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPROJECTEXTWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizIdeUtils, CnWizOptions, CnWizMenuAction, CnProjectUseUnitsFrm;

const
  SCnViewDialogExecuteName = '@Viewdlg@TViewDialog@Execute$qqrv';

//==============================================================================
// ������չר��
//==============================================================================

{ TCnProjectExtWizard }

constructor TCnProjectExtWizard.Create;
begin
  inherited;
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if FCorIdeModule <> 0 then
  begin
    FOldViewDialogExecute := GetProcAddress(FCorIdeModule, SCnViewDialogExecuteName);
    if FOldViewDialogExecute <> nil then
    begin
      FMethodHook := TCnMethodHook.Create(FOldViewDialogExecute, @ShowProjectUseUnits);
      FMethodHook.Disable;
    end;
  end;
end;

destructor TCnProjectExtWizard.Destroy;
begin
  FMethodHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
  inherited;
end;

procedure TCnProjectExtWizard.Loaded;
begin
  inherited;
  // ȡ�� Action
  FUnitsListAction := FindIDEAction('ViewUnitCommand');
  FFormsListAction := FindIDEAction('ViewFormCommand');
  FUseUnitAction := FindIDEAction(SCnUseUnitActionName);

  // ����ԭ Action
  if (FUnitsListAction <> nil) and not Assigned(FOldUnitNotifyEvent) then
    FOldUnitNotifyEvent := FUnitsListAction.OnExecute;
  if (FFormsListAction <> nil) and not Assigned(FOldFormNotifyEvent) then
    FOldFormNotifyEvent := FFormsListAction.OnExecute;

  // ���¶�Ӧ IDE �� Action
  if Active then
  begin
    UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked);
    UpdateMethodHook(UseUnitsHookBtnChecked);
  end;
end;

//------------------------------------------------------------------------------
// ����ִ��
//------------------------------------------------------------------------------

function TCnProjectExtWizard.GetOutputDir: string;
var
  ProjectDir: string;
{$IFNDEF DELPHI2011_UP}
  OutputDir: Variant;
{$ENDIF}
begin
  ProjectDir := _CnExtractFileDir(CnOtaGetCurrentProjectFileName);
{$IFDEF DELPHI2011_UP}
  if CnOtaGetActiveProjectOptions <> nil then
  begin
    Result := _CnExtractFilePath(CnOtaGetActiveProjectOptions.TargetName);
  end
  else
  begin
    Result := ProjectDir;
  end;
{$ELSE}
  if CnOtaGetActiveProjectOption('OutputDir', OutputDir) then
  begin
    // D2011 �� OutputDir �� $(Config)/$(Platform) ����ʽ��Replace�滻���� Config�������
    Result := LinkPath(ProjectDir, ReplaceToActualPath(OutputDir))
  end
  else
  begin
    Result := ProjectDir;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('OutputDir: ' + Result);
{$ENDIF}
end;

procedure TCnProjectExtWizard.ExploreExe;
var
  Project: IOTAProject;
  Dir, ProjectFileName, OutName: string;
{$IFNDEF DELPHI2011_UP}
  OutExt, IntermediaDir: string;
  Val: Variant;
{$ENDIF}
begin
  Project := CnOtaGetCurrentProject;
  if not Assigned(Project) then
    Exit;

  ProjectFileName := Project.GetFileName;
  if ProjectFileName <> '' then
  begin
    Dir := GetOutputDir;
    if Dir <> '' then
    begin
{$IFDEF DELPHI2011_UP}
      if CnOtaGetActiveProjectOptions <> nil then
        OutName := CnOtaGetActiveProjectOptions.TargetName;
{$ELSE}
      { TODO : �Զ���������չ���ݲ�֧�� }
      try
        if CnOtaGetActiveProjectOption('GenPackage', Val) and Val then
          OutExt := '.bpl';
      except
        ;
      end;

      try
        if (OutExt = '') and CnOtaGetActiveProjectOption('GenStaticLibrary', Val) and Val then
          OutExt := '.lib';
      except
        ;
      end;

      try
        if (OutExt = '') and CnOtaGetActiveProjectOption('GenDll', Val) and Val then
          OutExt := '.dll';
      except
        ;
      end;

      if OutExt = '' then
        OutExt := '.exe';

{$IFDEF IDE_CONF_MANAGER}
      if not IsDelphiRuntime then
      begin
{$IFDEF BDS2009_UP}
        if CnOtaGetActiveProjectOptionsConfigurations <> nil then
        begin
          if CnOtaGetActiveProjectOptionsConfigurations.GetActiveConfiguration <> nil then
          begin
            IntermediaDir := MakePath(CnOtaGetActiveProjectOptionsConfigurations.GetActiveConfiguration.GetName);
          end;
        end;
{$ELSE}
        // TODO: BCB2007 ���� OTA �ӿڵõ� Configuration�������ķ���
        try
          if CnOtaGetActiveProjectOption('UnitOutputDir', Val) then
            IntermediaDir := MakePath(VarToStr(Val));
        except
          ;
        end;
{$ENDIF}
      end;
{$ENDIF}
      OutName := MakePath(Dir) + IntermediaDir + _CnChangeFileExt(_CnExtractFileName(ProjectFileName), OutExt);
{$ENDIF}
      if FileExists(OutName) then
        ExploreFile(OutName)
      else if DirectoryExists(Dir) then
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

  // ���빤��
  ProjectBuilder := Project.GetProjectBuilder;
  // Exit if failure
  if ProjectBuilder.ShouldBuild and not ProjectBuilder.BuildProject(cmOTAMake, False) then
    Exit;

  // ȡ Host ����
  if CnOtaGetActiveProjectOption('HostApplication', HostApp) then
    ExeName := ReplaceToActualPath(HostApp, Project);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('HostApplication: ' + HostApp);
{$ENDIF}

  // ȡ���в���
  CnOtaGetActiveProjectOption('RunParams', RunParams);
  Params := RunParams;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('RunParams: ' + Params);
{$ENDIF}

  // ����������
  if ExeName = '' then
  begin
    OutputDir := GetOutputDir;
    ExeName := MakePath(OutputDir) + _CnChangeFileExt(_CnExtractFileName(ProjectFileName), '.exe');
  end;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('ExeName: ' + ExeName);
{$ENDIF}

  // ִ�г���
  if FileExists(ExeName) then
    ShellExecute(0, 'open', PChar(ExeName), PChar(Params),
      PChar(_CnExtractFileDir(ExeName)), SW_SHOWNORMAL);
end;
{$ENDIF}

//------------------------------------------------------------------------------
// Action ����
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

{$IFDEF SUPPORT_PRJ_BACKUP}
  IdProjBackup := RegisterASubAction(SCnProjExtBackup,
    SCnProjExtBackupCaption, 0,
    SCnProjExtBackupHint, SCnProjExtBackup);
{$ENDIF}

  IdDelTemp := RegisterASubAction(SCnProjExtDelTemp,
    SCnProjExtDelTempCaption, 0,
    SCnProjExtDelTempHint, SCnProjExtDelTemp);

  IdDirBuilder := RegisterASubAction(SCnProjExtDirBuilder,
    SCnProjExtDirBuilderCaption, 0,
    SCnProjExtDirBuilderHint, SCnProjExtDirBuilder);
end;

procedure TCnProjectExtWizard.SubActionExecute(Index: Integer);
var
  Ini: TCustomIniFile;
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
      UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked);
    finally
      Ini.Free;
    end;
  end
  else if Index = IdViewForms then
  begin
    Ini := CreateIniFile;
    try
      ShowProjectViewForms(Ini, FormsListHookBtnChecked);
      UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked);
    finally
      Ini.Free;
    end;
  end
{$IFDEF SUPPORT_USE_UNIT}
  else if Index = IdUseUnits then
  begin
    CnProjectUseUnitsFrm.Ini := CreateIniFile;
    try
      if FUseUnitAction <> nil then
      begin
        NeedUpdateMethodHook := False;
        UpdateMethodHook(True);
        FUseUnitAction.Execute;
        UpdateMethodHook(UseUnitsHookBtnChecked);
        NeedUpdateMethodHook := True;
      end;
    finally
      CnProjectUseUnitsFrm.Ini.Free;
      CnProjectUseUnitsFrm.Ini := nil;
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
{$IFDEF SUPPORT_PRJ_BACKUP}
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
{$ENDIF}
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
    // ���ڲ��ͷţ��˴������� Free
    ShowProjectDirBuilder(Ini);
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
  
{$IFDEF SUPPORT_PRJ_BACKUP}
  SetVisible([IdProjBackup], Active);
  SetEnabled([IdProjBackup], AEnabled);
{$ENDIF}

{$IFDEF SUPPORT_USE_UNIT}
  if FUseUnitAction <> nil then
  begin
    SetEnabled([IdUseUnits], (FUseUnitAction as TCustomAction).Enabled);
    SetVisible([IdUseUnits], True);
  end
  else
    SetVisible([IdUseUnits], False);
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
     SubActionExecute(IdViewUnits)   // ִ�� SubActionExecute �����е� IdViewUnits
  else
  begin
    // ���ҽӣ�����Ҫȡ�� ViewDialogExecute �ĹҽӺ����� IDE ԭ�е�����
    if FMethodHook <> nil then
      FMethodHook.Disable;
    if Assigned(FOldUnitNotifyEvent) then
      FOldUnitNotifyEvent(Sender);
    // �����ǰ���ˣ��ٻָ�
    if UseUnitsHookBtnChecked and (FMethodHook <> nil) then
      FMethodHook.Enable;
  end;
end;

procedure TCnProjectExtWizard.FormsListActionOnExecute(Sender: TObject);
begin
  if Active and FormsListHookBtnChecked then
    SubActionExecute(IdViewForms)  // ִ�� SubActionExecute �����е� IdViewForms
  else
  begin
    // ���ҽӣ�����Ҫȡ�� ViewDialogExecute �ĹҽӺ����� IDE ԭ�е�����
    if FMethodHook <> nil then
      FMethodHook.Disable;
    if Assigned(FOldFormNotifyEvent) then
      FOldFormNotifyEvent(Sender);
    // �����ǰ���ˣ��ٻָ�
    if UseUnitsHookBtnChecked and (FMethodHook <> nil) then
      FMethodHook.Enable;
  end;
end;

procedure TCnProjectExtWizard.UpdateActionHook(HookUnitsList, HookFormsList: Boolean);
begin
  // ʵ����ǿ�н��йҽӣ�
  // �ڹҽӺ�������вŴ����Ƿ�ҽӵĲ��������������µĻ��Ǿɵ�
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
    
  // �ָ�ʱ��ֱ�ӻָ�OnExecute�������ڹҽӺ������������Ҫ������������
  // FUnitsListAction.OnExecute := FOldUnitNotifyEvent;
  // FFormsListAction.OnExecute := FOldFormNotifyEvent;
end;

// ����ҽ�
procedure TCnProjectExtWizard.UpdateMethodHook(HookUseUnit: Boolean);
begin
  if FMethodHook <> nil then
  begin
    if HookUseUnit then
      FMethodHook.Enable
    else
      FMethodHook.Disable;
  end;
end;

procedure TCnProjectExtWizard.SetActive(Value: Boolean);
var
  Ini: TCustomIniFile;
begin
  inherited;
  // ԭ IDE �� Action �ҽӱ�ǲ��䣬�Ƿ�ʹ���¹����ڹҽӵ��¹����о���
  UpdateActionHook(UnitsListHookBtnChecked, FormsListHookBtnChecked);
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
  else // ����ʱȡ���ҽ�
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
  // ��ʾ�ռ䲻������Ϊÿ����ʾ����
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

initialization
  RegisterCnWizard(TCnProjectExtWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNPROJECTEXTWIZARD}
end.
