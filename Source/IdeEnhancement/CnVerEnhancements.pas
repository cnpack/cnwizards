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

unit CnVerEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：版本信息增强专家
* 单元作者：陈省（hubdog）
* 备    注：本专家不支持D5, C5
* 开发平台：JWinXPPro + Delphi 7.01
* 兼容测试：JWinXPPro ＋Delphi 7.01
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2019.03.26 V1.5 by liuxiao
*               加入将年月日设为版本号的设置
*           2015.01.05 V1.4 by liuxiao
*               加入自定义日期时间格式的设置
*           2013.05.23 V1.3 by liuxiao
*               Wiseinfo 修正编译工程组时使用当前工程引发错误的问题
*           2013.04.28 V1.2 by liuxiao
*               修正 XE 下版本增加后未能写入目标文件的问题并修正插入编译时间的问题
*           2007.01.22 V1.1 by liuxiao
*               使能此单元并加以适应性修改
*           2005.05.05 V1.0 by hubdog
*               创建单元
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
  TCnBuildCarryType = (bctNone, bct10, bct100, bct1000, bct10000);
  {* Build 号进位类型，不进，满十、百、千、万进}

//==============================================================================
// 版本信息扩展专家
//==============================================================================

  { TCnVerEnhanceWizard }

  TCnVerEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FCurrentProject: IOTAProject;
    FLastCompiled: Boolean;
    FIncBuild: Boolean;
    FBeforeBuildNo: Integer;
    FAfterBuildNo: Integer;
    FBeforeRelease: Integer;
    FAfterRelease: Integer;
    FIncludeVer: Boolean;
    FCompileNotifierAdded: Boolean;
    FDateTimeFormat: string;
    FDateAsVersion: Boolean;
    FBuildCarryType: TCnBuildCarryType;
    FThisTimeCarry: Boolean;
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
    property BuildCarryType: TCnBuildCarryType read FBuildCarryType write FBuildCarryType;
    {* Build 号朝 Release 进位的类型，包括不进及满十、百、千、万进}
  end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnVerEnhanceFrm, CnResFile;

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
  csBuildCarryType = 'BuildCarryType';

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
{$IFDEF VERSIONINFO_PER_CONFIGURATION}
  ResFileName: string;
  ResFile: TCnResFile;
  M1, M2, M3, M4, M5, M6: Integer;
{$ENDIF}
begin
  if IsCodeInsight or not Active then
    Exit;

  // 注意 build project 是在编译后才增加 buildno 的
  // 如果不将版本信息加入可执行文件，退出
  if not FIncludeVer then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance AfterCompile');
{$ENDIF}
  Options := CnOtaGetActiveProjectOptions(FCurrentProject);
  if not Assigned(Options) then
    Exit;

  FAfterBuildNo := Options.GetOptionValue('Build');
  FAfterRelease := Options.GetOptionValue('Release');

{$IFDEF DEBUG}
  CnDebugger.LogMsg(Format('VerEnhance After Release %d Build No %d. Compile Succ %d.',
    [FAfterRelease, FAfterBuildNo, Integer(Succeeded)]));
{$ENDIF}

  if not Assigned(FCurrentProject) then
    Exit;

  if not Succeeded and FIncBuild then
  begin
    // 编译失败
    if not FThisTimeCarry and (FAfterBuildNo > FBeforeBuildNo) then
    begin
      // 没进位，且版本号大，则改回去
{$IFDEF COMPILER6_UP} // 只 D6 及以上改回版本号，D5 由于 Bug 而无效
      if CanSetValueWithoutBug(FCurrentProject) then
        CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FBeforeBuildNo]));
  {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(FBeforeBuildNo));
      UpdateConfigurationFileVersionAndTime(FIncBuild, False);

  {$IFDEF VERSIONINFO_PER_CONFIGURATION}
      // XE2 以上的编译（非 Build）不会把版本号写入 res，得手工写
      ResFileName := ChangeFileExt(FCurrentProject.FileName, '.res');
      if FileExists(ResFileName) then
      begin
        ResFile := TCnResFile.Create(ResFileName);
        try
          // 操作 res 文件写回 FBeforeBuildNo
          if ResFile.GetVersionInfo(M1, M2, M3, M4, M5, M6) then
          begin
            ResFile.SetVersionInfo(M1, M2, M3, FBeforeBuildNo, M5, M6);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Update Res File Back to %d', [FBeforeBuildNo]);
{$ENDIF}
          end;
        finally
          ResFile.Free;
        end;
      end;
  {$ENDIF}

  {$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
      CnDebugger.LogFmt('VerEnhance Compiling Fail. Set Back Build No %d.', [FBeforeBuildNo]);
{$ENDIF}
    end
    else if FThisTimeCarry and (FAfterBuildNo = 0) then
    begin
      // 有进位，且新版本号 0，两个都改回去
{$IFDEF COMPILER6_UP} // 只 D6 及以上改回版本号，D5 由于 Bug 而无效
      if CanSetValueWithoutBug(FCurrentProject) then
      begin
        CnOtaSetProjectOptionValue(Options, 'Release', Format('%d', [FBeforeRelease]));
        CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FBeforeBuildNo]));
      end;
  {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease, IntToStr(FBeforeRelease));
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(FBeforeBuildNo));
      UpdateConfigurationFileVersionAndTime(FIncBuild, False);

  {$IFDEF VERSIONINFO_PER_CONFIGURATION}
      // XE2 以上的编译（非 Build）不会把版本号写入 res，得手工写
      ResFileName := ChangeFileExt(FCurrentProject.FileName, '.res');
      if FileExists(ResFileName) then
      begin
        ResFile := TCnResFile.Create(ResFileName);
        try
          // 操作 res 文件写回 FBeforeRelease、FBeforeBuildNo
          if ResFile.GetVersionInfo(M1, M2, M3, M4, M5, M6) then
          begin
            ResFile.SetVersionInfo(M1, M2, FBeforeRelease, FBeforeBuildNo, M5, M6);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Update Res File Back to %d.%d', [FBeforeRelease, FBeforeBuildNo]);
{$ENDIF}
          end;
        finally
          ResFile.Free;
        end;
      end;
  {$ENDIF}
  {$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
      CnDebugger.LogFmt('VerEnhance Compiling Fail. Set Back Release %d Build No %d.', [FBeforeRelease, FBeforeBuildNo]);
{$ENDIF}
    end;
  end;

  if not FIncBuild and FLastCompiled then
  begin
    // 不改版本号时如果需要插入时间，则需要这样重写一下让插入时间有效
{$IFDEF COMPILER6_UP} // 只 D6 及以上增加版本号，D5 由于 Bug 而无效
    if CanSetValueWithoutBug(FCurrentProject) then
      CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [FAfterBuildNo]));

  {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    UpdateConfigurationFileVersionAndTime(FIncBuild, FLastCompiled);
  {$ENDIF}
{$ENDIF}
  end;
end;

procedure TCnVerEnhanceWizard.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
var
  NewRelease, NewBuildNo: Integer;
{$IFDEF COMPILER6_UP}
  I: Integer;
  ModuleFileEditor: IOTAEditor;
  ProjectResource: IOTAProjectResource;
  ResourceEntry: IOTAResourceEntry;
  VI: TCnVersionInfo;
  Stream: TMemoryStream;
{$IFDEF VERSIONINFO_PER_CONFIGURATION}
  ResFileName: string;
  ResFile: TCnResFile;
  M1, M2, M3, M4, M5, M6: Integer;
{$ENDIF}
{$ENDIF}
  Options: IOTAProjectOptions;
{$IFDEF COMPILER6_UP}
  Y, M, D: Word;
{$ENDIF}

  // 传入加一后的 L，计算并返回是否进位
  function CheckCarry(CarryType: TCnBuildCarryType; var H, L: Integer): Boolean;
  begin
    if ((CarryType = bct10) and (L >= 10)) or
      ((CarryType = bct100) and (L >= 100)) or
      ((CarryType = bct1000) and (L >= 1000)) or
      ((CarryType = bct10000) and (L >= 10000)) then
    begin
      L := 0;
      Inc(H);
      Result := True;
    end
    else
      Result := False;
  end;

begin
  if IsCodeInsight then
    Exit;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('VerEnhance BeforeCompile');
{$ENDIF}

  // Hubdog: 注意：通过检查 dof 文件来获得版本信息是没有用的，因为只有在 save project 后，才会将内存中的
  // Hubdog: 这些信息写进 dof
  Options := CnOtaGetActiveProjectOptions(Project);
  if not Assigned(Options) then
    Exit;

  FCurrentProject := Project;
  // -1 为包含，高版本 True 为包含
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
    FBeforeBuildNo := 0; // 如果值非法，则改成 0
  end;

  try
    FBeforeRelease := Options.GetOptionValue('Release');
  except
    FBeforeRelease := 0; // 如果值非法，则改成 0
  end;

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  {$IFNDEF PROJECT_VERSION_NUMBER_BUG}
  // 2009/2010/XE has a bug that below got a wrong value.
  FBeforeBuildNo := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild), 0);
  FBeforeRelease := StrToIntDef(CnOtaGetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease), 0);
  {$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogFmt('VerEnhance BeforeCompile BeforeRelease %d BeforeBuildNo %d', [FBeforeRelease, FBeforeBuildNo]);
{$ENDIF}

  //先增加文件版本信息, 修改 OptionValue 的值就可以了
  // Hubdog: SetProjectOptionValue 在 D5 下无法修改 Build, Release 等版本信息
  //（这是 D5/BCB5/BCB6 的一个Bug)，但在 D6 下又能修改成功
  if FIncBuild then
  begin
    NewRelease := FBeforeRelease;
    NewBuildNo := FBeforeBuildNo + 1;
    FThisTimeCarry := False;
{$IFDEF COMPILER6_UP} // 只 D6 及以上增加版本号，D5 由于 Bug 而无效
    if CanSetValueWithoutBug(FCurrentProject) then
    begin
      if FBuildCarryType = bctNone then
      begin
        CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [NewBuildNo]));
        if FDateAsVersion then
        begin
          DecodeDate(Now, Y, M, D);
          CnOtaSetProjectOptionValue(Options, 'MajorVersion', IntToStr(Y));
          CnOtaSetProjectOptionValue(Options, 'MinorVersion', IntToStr(M));
          CnOtaSetProjectOptionValue(Options, 'Release', IntToStr(D));
        end;
      end
      else
      begin
        // 处理是否进位，并忽略 FDateAsVersion
        FThisTimeCarry := CheckCarry(FBuildCarryType, NewRelease, NewBuildNo);
        if FThisTimeCarry then
          CnOtaSetProjectOptionValue(Options, 'Release', Format('%d', [NewRelease]));

        CnOtaSetProjectOptionValue(Options, 'Build', Format('%d', [NewBuildNo]));
      end;
    end;
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
    if FBuildCarryType = bctNone then
    begin
      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(NewBuildNo));

  {$IFDEF VERSIONINFO_PER_CONFIGURATION}
      // XE2 以上的编译（非 Build）不会把版本号写入 res，得手工写
      ResFileName := ChangeFileExt(FCurrentProject.FileName, '.res');
      if FileExists(ResFileName) then
      begin
        ResFile := TCnResFile.Create(ResFileName);
        try
          // 操作 res 文件写 NewBuildNo
          if ResFile.GetVersionInfo(M1, M2, M3, M4, M5, M6) then
          begin
            ResFile.SetVersionInfo(M1, M2, M3, NewBuildNo, M5, M6);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Update Res File to %d', [NewBuildNo]);
{$ENDIF}
          end;
        finally
          ResFile.Free;
        end;
      end;
  {$ENDIF}

      if FDateAsVersion then
      begin
        DecodeDate(Now, Y, M, D);
        CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csMajorVer, IntToStr(Y));
        CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csMinorVer, IntToStr(M));
        CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease, IntToStr(D));
      end;
    end
    else
    begin
      // 处理是否进位，并忽略 FDateAsVersion
      FThisTimeCarry := CheckCarry(FBuildCarryType, NewRelease, NewBuildNo);
      if FThisTimeCarry then
        CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csRelease, IntToStr(NewRelease));

      CnOtaSetProjectCurrentBuildConfigurationValue(FCurrentProject, csBuild, IntToStr(NewBuildNo));

  {$IFDEF VERSIONINFO_PER_CONFIGURATION}
      // XE2 以上的编译（非 Build）不会把版本号写入 res，得手工写
      ResFileName := ChangeFileExt(FCurrentProject.FileName, '.res');
      if FileExists(ResFileName) then
      begin
        ResFile := TCnResFile.Create(ResFileName);
        try
          if ResFile.GetVersionInfo(M1, M2, M3, M4, M5, M6) then
          begin
            // 操作 res 文件根据进位状况写 NewRelease、NewBuildNo
            if FThisTimeCarry then
              ResFile.SetVersionInfo(M1, M2, NewRelease, NewBuildNo, M5, M6)
            else
              ResFile.SetVersionInfo(M1, M2, M3, NewBuildNo, M5, M6);
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Update Res File to %d.%d', [NewRelease, NewBuildNo]);
{$ENDIF}
          end;
        finally
          ResFile.Free;
        end;
      end;
  {$ENDIF}
    end;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
    CnDebugger.LogFmt('VerEnhance Set New Release %d Build No %d.', [NewRelease, NewBuildNo]);
{$ENDIF}
  end;

{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  UpdateConfigurationFileVersionAndTime(FIncBuild, Active and FLastCompiled);
{$ENDIF}

{$IFDEF COMPILER6_UP} // D6 及以上才处理编译时间

  // 添加 LastCompileTime 信息
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

  // Hubdog: 注意不管是编译还是 build，都会生成版本信息，只不过一个增加 build no ,一个不增加
  // Hubdog: 注意：即便是 Auto-inc Build No，也只是将当前的版本号编译进 EXE，然后才增加 BuildNo
  // LiuXiao: 再注意：以下对 BDS 2005/20006 无效，它们的 Bug 导致无法获得 Resource接口，但似乎没影响。
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
        VI := TCnVersionInfo.Create(PChar(ResourceEntry.GetData));
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
  // 进行配置。
  with TCnVerEnhanceForm.Create(nil) do
  begin
    try
      chkLastCompiled.Checked := FLastCompiled;
      chkIncBuild.Checked := FIncBuild;
      chkDateAsVersion.Checked := FDateAsVersion;
      cbbFormat.Text := FDateTimeFormat;
      chkBuildCarry.Checked := FBuildCarryType <> bctNone;

      if chkBuildCarry.Checked then
        cbbBuildCarryType.ItemIndex := Ord(FBuildCarryType) - 1
      else
        cbbBuildCarryType.ItemIndex := 1;

      if ShowModal = mrOK then
      begin
        LastCompiled := chkLastCompiled.Checked;
        IncBuild := chkIncBuild.Checked;
        DateAsVersion := chkDateAsVersion.Checked;
        DateTimeFormat := Trim(cbbFormat.Text);

        if chkBuildCarry.Checked then
          FBuildCarryType := TCnBuildCarryType(cbbBuildCarryType.ItemIndex + 1)
        else
          FBuildCarryType := bctNone;
        
        DoSaveSettings;
      end;
    finally
      Free;
    end;
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
    // 对于 D5/BCB5/BCB6 出错的，简单屏蔽
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
  FBuildCarryType := TCnBuildCarryType(Ini.ReadInteger('', csBuildCarryType, Ord(FBuildCarryType)));
  UpdateCompileNotify; // 改为有需要才进行通知器的增加
end;

procedure TCnVerEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool('', csLastCompiled, FLastCompiled);
  Ini.WriteBool('', csIncBuild, FIncBuild);
  Ini.WriteString('', csDateTimeFormat, FDateTimeFormat);
  Ini.WriteBool('', csDateAsVersion, FDateAsVersion);
  Ini.WriteInteger('', csBuildCarryType, Ord(FBuildCarryType));
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
    // 有需要并且以前没通知器就增加
    CnWizNotifierServices.AddBeforeCompileNotifier(BeforeCompile);
    CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
    FCompileNotifierAdded := True;
  end
  else if not CompileNotifyEnabled and FCompileNotifierAdded then
  begin
    // 无需要并且以前有通知器就删除
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
{$IFDEF COMPILER6_UP} // D5/BCB5/BCB6 由于 OTA Bug 而无效，故不注册
{$IFNDEF BCB6}
  RegisterCnWizard(TCnVerEnhanceWizard);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}
end.

