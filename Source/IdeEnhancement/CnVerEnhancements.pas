{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnVerEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��汾��Ϣ��ǿר��
* ��Ԫ���ߣ���ʡ��hubdog��
* ��    ע����ר�Ҳ�֧��D5, C5
* ����ƽ̨��JWinXPPro + Delphi 7.01
* ���ݲ��ԣ�JWinXPPro ��Delphi 7.01
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2019.03.26 V1.5 by liuxiao
*               ���뽫��������Ϊ�汾�ŵ�����
*           2015.01.05 V1.4 by liuxiao
*               �����Զ�������ʱ���ʽ������
*           2013.05.23 V1.3 by liuxiao
*               Wiseinfo �������빤����ʱʹ�õ�ǰ�����������������
*           2013.04.28 V1.2 by liuxiao
*               ���� XE �°汾���Ӻ�δ��д��Ŀ���ļ������Ⲣ�����������ʱ�������
*           2007.01.22 V1.1 by liuxiao
*               ʹ�ܴ˵�Ԫ��������Ӧ���޸�
*           2005.05.05 V1.0 by hubdog
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, Contnrs, {$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  CnCommon, CnWizUtils, CnWizNotifier, CnWizIdeUtils, CnWizConsts, CnMenuHook,
  CnConsts, CnWizClasses;

type

//==============================================================================
// �汾��Ϣ��չר��
//==============================================================================

  { TCnVerEnhanceWizard }

  TCnVerEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FCurrentProject: IOTAProject;
    FLastCompiled: Boolean;
    FIncBuild: Boolean;
    FBeforeBuildNo: Integer;
    FAfterBuildNo: Integer;
    FIncludeVer: Boolean;
    FCompileNotifierAdded: Boolean;
    FDateTimeFormat: string;
    FDateAsVersion: Boolean;
    function GetCompileNotifyEnabled: Boolean;
    procedure SetIncBuild(const Value: Boolean);
    procedure SetLastCompiled(const Value: Boolean);
{$IFDEF COMPILER6_UP}
    function CanSetValueWithoutBug(Project: IOTAProject): Boolean;
{$ENDIF}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    procedure UpdateConfigurationFileVersionAndTime(IncB: Boolean; LastComp: Boolean);
{$ENDIF}
  protected
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure InsertTime;
    procedure DeleteTime;
    function GetHasConfig: Boolean; override;
    procedure UpdateCompileNotify;
    property CompileNotifyEnabled: Boolean read GetCompileNotifyEnabled;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email,
      Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    property LastCompiled: Boolean read FLastCompiled write SetLastCompiled;
    property DateTimeFormat: string read FDateTimeFormat write FDateTimeFormat;
    property DateAsVersion: Boolean read FDateAsVersion write FDateAsVersion;
    property IncBuild: Boolean read FIncBuild write SetIncBuild;
  end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnVerEnhanceFrm, VersionInfo;

const
  csDateKeyName = 'LastCompiledTime';
  csVerInfoKeys = 'VerInfo_Keys';
  csMajorVer = 'VerInfo_MajorVer';
  csMinorVer = 'VerInfo_MinorVer';
  csRelease = 'VerInfo_Release';
  csBuild = 'VerInfo_Build';

  csFileVersion = 'FileVersion';

  csLastCompiled = 'LastCompiled';
  csDateTimeFormat = 'DateTimeFormat';
  csDateAsVersion = 'DateAsVersion';
  csIncBuild = 'IncBuild';

  csDefaultDateTimeFormat = 'yyyy/mm/dd hh:nn:ss';

{ TCnVerEnhanceWizard }

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}

procedure TCnVerEnhanceWizard.UpdateConfigurationFileVersionAndTime(IncB: Boolean;
  LastComp: Boolean);
var
  S, St: string;
  Sl: TStrings;
  Idx: Integer;
  Major, Minor, Release, Build: Integer;
begin
  S := CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csVerInfoKeys);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance Get VerInfo_Keys: ' + S);
{$ENDIF}

  Sl := TStringList.Create;
  try
    ExtractStrings([';'], [], PWideChar(S), Sl);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('VerEnhance Get VerInfo_Keys Strings Line ' + IntToStr(Sl.Count));
    CnDebugger.LogMsg('VerEnhance Get FileVersion ' + Sl.Values['FileVersion']);
{$ENDIF}

    if Active and IncB then
    begin
      Major := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csMajorVer), 0);
      Minor := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csMinorVer), 0);
      Release := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease), 0);
      Build := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild), 0);

      St := Format('%d.%d.%d.%d', [Major, Minor, Release, Build]);
      Sl.Values[csFileVersion] := St;
    end;

    if Active and FLastCompiled then
    begin
      try
        Sl.Values[csDateKeyName] := FormatDateTime(FDateTimeFormat, Now);
      except
        Sl.Values[csDateKeyName] := DateTimeToStr(Now);
      end;
    end
    else
    begin
      Idx := Sl.IndexOfName(csDateKeyName);
      if Idx >= 0 then
        Sl.Delete(Idx);
    end;

    S := '';
    for Idx := 0 to Sl.Count - 1 do
    begin
      if S = '' then
        S := Sl[Idx]
      else
        S := S + ';' + Sl[Idx];
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('VerEnhance Set VerInfo_Keys: ' + S);
{$ENDIF}
    CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csVerInfoKeys, S);
  finally
    Sl.Free;
  end;
end;
{$ENDIF}

procedure TCnVerEnhanceWizard.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
var
  Options: IOTAProjectOptions;
begin
  if IsCodeInsight or not Active then
    Exit;

  // ע�� build project ���ڱ��������� buildno ��
  // ��������汾��Ϣ�����ִ���ļ����˳�
  if not FIncludeVer then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance AfterCompile');
{$ENDIF}
  Options := CnOtaGetActiveProjectOptions(FCurrentProject);
  if not Assigned(Options) then
    Exit;

  FAfterBuildNo := Options.GetOptionValue('Build');

{$IFDEF DEBUG}
  CnDebugger.LogMsg(Format('VerEnhance After Build No %d. Compile Succ %d.',
    [FAfterBuildNo, Integer(Succeeded)]));
{$ENDIF}

  if not Assigned(FCurrentProject) then
    Exit;

  if not Succeeded and FIncBuild and (FAfterBuildNo > FBeforeBuildNo) then
  begin
    // ����ʧ�ܣ��汾�ŸĻ�ȥ
{$IFDEF COMPILER6_UP} // ֻ D6 �����ϸĻذ汾�ţ�D5 ���� Bug ����Ч
    if CanSetValueWithoutBug(FCurrentProject) then
      CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FBeforeBuildNo]));
    // TODO: ����һ���� 2009 �����Ͽ��ܵ��� dpk Դ�ļ����ƻ���ԭ��δ֪��ֻ�ܽ���
  {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(FBeforeBuildNo));
    UpdateConfigurationFileVersionAndTime(FIncBuild, False);
  {$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
    CnDebugger.LogMsg(Format('VerEnhance Compiling Fail. Set Back Build No %d.', [FBeforeBuildNo]));
{$ENDIF}
  end;

  if not FIncBuild and FLastCompiled then
  begin
    // ���İ汾��ʱ�����Ҫ����ʱ�䣬����Ҫ������дһ���ò���ʱ����Ч
{$IFDEF COMPILER6_UP} // ֻ D6 ���������Ӱ汾�ţ�D5 ���� Bug ����Ч
    if CanSetValueWithoutBug(FCurrentProject) then
      CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FAfterBuildNo]));
    // TODO: ����һ���� 2009 �����Ͽ��ܵ��� dpk Դ�ļ����ƻ���ԭ��δ֪��ֻ�ܽ���
  {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    UpdateConfigurationFileVersionAndTime(FIncBuild, FLastCompiled);
  {$ENDIF}
{$ENDIF}
  end;
end;

procedure TCnVerEnhanceWizard.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
{$IFDEF COMPILER6_UP}
  I: Integer;
  ModuleFileEditor: IOTAEditor;
  ProjectResource: IOTAProjectResource;
  ResourceEntry: IOTAResourceEntry;
  VI: TVersionInfo;
  Stream: TMemoryStream;
{$ENDIF}
  Options: IOTAProjectOptions;
{$IFDEF COMPILER6_UP}
  Y, M, D: Word;
{$ENDIF}
begin
  if IsCodeInsight then
    Exit;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance BeforeCompile');
{$ENDIF}

  // Hubdog: ע�⣺ͨ����� dof �ļ�����ð汾��Ϣ��û���õģ���Ϊֻ���� save project �󣬲ŻὫ�ڴ��е�
  // Hubdog: ��Щ��Ϣд�� dof
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then
    Exit;

  FCurrentProject := Project;
  // -1 Ϊ�������߰汾 True Ϊ����
  FIncludeVer := (Options.GetOptionValue('IncludeVersionInfo') = '-1')
    or (Options.GetOptionValue('IncludeVersionInfo') = 'True');
{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance BeforeCompile IncludeVersionInfo '
    + VarToStr(Options.GetOptionValue('IncludeVersionInfo')));
{$ENDIF}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  if not FIncludeVer then
    FIncludeVer := (CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, 'VerInfo_IncludeVerInfo') = 'true');
{$ENDIF}
  if not FIncludeVer then
    Exit;

  try
    FBeforeBuildNo := Options.GetOptionValue('Build');
  except
    FBeforeBuildNo := 0; // ���ֵ�Ƿ�����ĳ� 0
  end;

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  {$IFNDEF PROJECT_VERSION_NUMBER_BUG}
  // 2009/2010/XE has a bug that below got a wrong value.
  FBeforeBuildNo := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild), 0);
  {$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance BeforeCompile BeforeBuildNo: '
    + IntToStr(FBeforeBuildNo));
{$ENDIF}

  //�������ļ��汾��Ϣ, �޸� OptionValue ��ֵ�Ϳ�����
  // Hubdog: SetProjectOptionValue �� D5 ���޷��޸� Build, Release �Ȱ汾��Ϣ
  //������ D5/BCB5/BCB6 ��һ��Bug)������ D6 �������޸ĳɹ�
  if FIncBuild then
  begin
{$IFDEF COMPILER6_UP} // ֻ D6 ���������Ӱ汾�ţ�D5 ���� Bug ����Ч
    if CanSetValueWithoutBug(FCurrentProject) then
    begin
      CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FBeforeBuildNo + 1]));
      if FDateAsVersion then
      begin
        DecodeDate(Now, Y, M, D);
        CnOtaSetProjectOptionValue(Options, 'MajorVersion', IntToStr(Y));
        CnOtaSetProjectOptionValue(Options, 'MinorVersion', IntToStr(M));
        CnOtaSetProjectOptionValue(Options, 'Release', IntToStr(D));
      end;
    end;
    // TODO: ����һ���� 2009 �����Ͽ��ܵ��� dpk Դ�ļ����ƻ���ԭ��δ֪��ֻ�ܽ���
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(FBeforeBuildNo + 1));
    if FDateAsVersion then
    begin
      DecodeDate(Now, Y, M, D);
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csMajorVer, IntToStr(Y));
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csMinorVer, IntToStr(M));
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease, IntToStr(D));
    end;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
    CnDebugger.LogFmt('VerEnhance Set New Build No %d.', [FBeforeBuildNo + 1]);
{$ENDIF}
  end;

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  UpdateConfigurationFileVersionAndTime(FIncBuild, Active and FLastCompiled);
{$ENDIF}

{$IFDEF COMPILER6_UP} // D6 �����ϲŴ������ʱ��

  // ��� LastCompileTime ��Ϣ
  if Active and FLastCompiled then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('VerEnhance. Set LastCompiledTime ');
{$ENDIF}
    InsertTime;
  end
  else
  begin
    DeleteTime;
    Exit;
  end;

  // Hubdog: ע�ⲻ���Ǳ��뻹�� build���������ɰ汾��Ϣ��ֻ����һ������ build no ,һ��������
  // Hubdog: ע�⣺������ Auto-inc Build No��Ҳֻ�ǽ���ǰ�İ汾�ű���� EXE��Ȼ������� BuildNo
  // LiuXiao: ��ע�⣺���¶� BDS 2005/20006 ��Ч�����ǵ� Bug �����޷���� Resource�ӿڣ����ƺ�ûӰ�졣
  for I := 0 to Project.GetModuleFileCount - 1 do
  begin
    ModuleFileEditor := CnOtaGetFileEditorForModule(Project, I);
    if Supports(ModuleFileEditor, IOTAProjectResource, ProjectResource) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('VerEnhance IOTAProjectResource Got.');
{$ENDIF}

      ResourceEntry := ProjectResource.FindEntry(RT_VERSION, PChar(1));
      if Assigned(ResourceEntry) then
      begin
        VI := TVersionInfo.Create(PChar(ResourceEntry.GetData));
        try
          Stream := TMemoryStream.Create;
          try
            VI.SaveToStream(Stream);
            ResourceEntry.DataSize := Stream.Size;
            Move(Stream.Memory^, ResourceEntry.GetData^, Stream.Size);
          finally
            Stream.Free;
          end;
        finally
          VI.Free;
        end;
      end;
    end
  end;
{$ENDIF}
end;

procedure TCnVerEnhanceWizard.Config;
begin
  // �������á�
  with TCnVerEnhanceForm.Create(nil) do
    try
      chkLastCompiled.Checked := FLastCompiled;
      chkIncBuild.Checked := FIncBuild;
      chkDateAsVersion.Checked := FDateAsVersion;
      cbbFormat.Text := FDateTimeFormat;

      if ShowModal = mrOK then
      begin
        LastCompiled := chkLastCompiled.Checked;
        IncBuild := chkIncBuild.Checked;
        DateAsVersion := chkDateAsVersion.Checked;
        DateTimeFormat := Trim(cbbFormat.Text);
        
        DoSaveSettings;
      end;
    finally
      Free;
    end;
end;

constructor TCnVerEnhanceWizard.Create;
begin
  inherited;
  FDateTimeFormat := csDefaultDateTimeFormat;
  CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
  FCompileNotifierAdded := True;
end;

procedure TCnVerEnhanceWizard.InsertTime;
var
  Keys: TStringList;
begin
  Keys := TStringList(CnOtaGetVersionInfoKeys(FCurrentProject));
  try
    try
      Keys.Values[csDateKeyName] := FormatDateTime(FDateTimeFormat, Now);
    except
      Keys.Values[csDateKeyName] := DateTimeToStr(Now);
    end;
  except
    // ���� D5/BCB5/BCB6 ����ģ�������
{$IFDEF DEBUG}
    CnDebugger.LogMsg('VerEnhance. Insert LastCompiledTime not Exists or Fail.');
{$ENDIF}
  end;
end;

procedure TCnVerEnhanceWizard.DeleteTime;
var
  Keys: TStringList;
  Index: Integer;
begin
  Keys := TStringList(CnOtaGetVersionInfoKeys(FCurrentProject));
  Keys.Values[csDateKeyName] := '';

  Index := Keys.IndexOfName(csDateKeyName);
  if Index > -1 then
  begin
    Keys.Delete(Index);
{$IFDEF DEBUG}
    CnDebugger.LogInteger(Index, 'VerEnhance VersionInfoKeys: DateTime.');
{$ENDIF}
  end;
end;

destructor TCnVerEnhanceWizard.Destroy;
begin
  if FCompileNotifierAdded then
  begin
    CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
    CnWizNotifierServices.RemoveBeforeCompileNotifier(BeforeCompile);
    FCompileNotifierAdded := False;
  end;
  inherited;
end;

function TCnVerEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnVerEnhanceWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnVerEnhanceWizardName;
  Author := SCnPack_Hubdog + ';' + SCnPack_LiuXiao;
  Email := SCnPack_HubdogEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnVerEnhanceWizardComment;
end;

procedure TCnVerEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  FLastCompiled := Ini.ReadBool('', csLastCompiled, False);
  FIncBuild := Ini.ReadBool('', csIncBuild, False);
  FDateTimeFormat := Ini.ReadString('', csDateTimeFormat, csDefaultDateTimeFormat);
  FDateAsVersion := Ini.ReadBool('', csDateAsVersion, False);
  UpdateCompileNotify; // ��Ϊ����Ҫ�Ž���֪ͨ��������
end;

procedure TCnVerEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csLastCompiled, FLastCompiled);
  Ini.WriteBool('', csIncBuild, FIncBuild);
  Ini.WriteString('', csDateTimeFormat, FDateTimeFormat);
  Ini.WriteBool('', csDateAsVersion, FDateAsVersion);
end;

function TCnVerEnhanceWizard.GetCompileNotifyEnabled: Boolean;
begin
  Result := FIncBuild or FLastCompiled;
end;

procedure TCnVerEnhanceWizard.SetIncBuild(const Value: Boolean);
begin
  if FIncBuild <> Value then
  begin
    FIncBuild := Value;
    UpdateCompileNotify;
  end;
end;

procedure TCnVerEnhanceWizard.SetLastCompiled(const Value: Boolean);
begin
  if FLastCompiled <> Value then
  begin
    FLastCompiled := Value;
    UpdateCompileNotify;
  end;
end;

procedure TCnVerEnhanceWizard.UpdateCompileNotify;
begin
  if CompileNotifyEnabled and not FCompileNotifierAdded then
  begin
    // ����Ҫ������ǰû֪ͨ��������
    CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
    CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
    FCompileNotifierAdded := True;
  end
  else if not CompileNotifyEnabled and FCompileNotifierAdded then
  begin
    // ����Ҫ������ǰ��֪ͨ����ɾ��
    CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
    CnWizNotifierServices.RemoveBeforeCompileNotifier(BeforeCompile);
    FCompileNotifierAdded := False;
  end;
end;

{$IFDEF COMPILER6_UP}

function TCnVerEnhanceWizard.CanSetValueWithoutBug(Project: IOTAProject): Boolean;
begin
  Result := True;
{$IFDEF OTA_DPKOPTION_SETVALUE_CORRUPT_BUG}
  if (Project <> nil) and (IsDpk(Project.FileName) or (sPackage = Project.ProjectType)) then
    Result := False;
{$ENDIF}
end;

{$ENDIF}

initialization
{$IFDEF COMPILER6_UP} // D5/BCB5/BCB6 ���� OTA Bug ����Ч���ʲ�ע��
{$IFNDEF BCB6}
  RegisterCnWizard(TCnVerEnhanceWizard);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}
end.

