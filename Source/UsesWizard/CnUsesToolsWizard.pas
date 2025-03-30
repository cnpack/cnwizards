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

unit CnUsesToolsWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：引用单元清理工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：原理：编译好的 DCU 文件里记录了 interface 部分以及 implementation 部
*           分导入的每一个单元名，以及对应的单元导入标识符，如果某个单元的标识符
*           数量为 0，表示没有用到其内容，可以考虑修改源码剔除之。
*           注意分析 DCU 得到的单元名在 XE2 或以上支持命名空间的编译器里会带点号
*           源码中则不一定带，目前以尾部匹配点号加单元名的模式支持。
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2022.02.26 V1.2
*               清理时继续完善对 XE2 风格的带点的单元名的支持
*           2021.08.26 V1.3
*               改成子菜单专家以添加引用树功能
*           2016.08.02 V1.2
*               加入自动保存并关闭处理结果的选项以应对大项目
*           2011.11.05 V1.1
*               完善对 XE2 风格的带点的单元名的支持
*           2005.08.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolsAPI, IniFiles, Contnrs, CnWizMultiLang, CnWizClasses, CnWizConsts,
  CnCommon, CnConsts, CnWizUtils, CnDCU32, CnWizIdeUtils, CnWizEditFiler,
  CnWizOptions, CnHashMap, mPasLex, {$IFDEF UNICODE} CnPasWideLex, {$ENDIF}
  Math, TypInfo, RegExpr, ActnList {$IFDEF DELPHIXE3_UP}, System.Actions {$ENDIF};

type

{ TCnUsesCleanerForm }

  TCnUsesCleanerForm = class(TCnTranslateForm)
    grpKind: TGroupBox;
    rbCurrUnit: TRadioButton;
    rbOpenedUnits: TRadioButton;
    rbCurrProject: TRadioButton;
    rbProjectGroup: TRadioButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    grpSettings: TGroupBox;
    chkIgnoreInit: TCheckBox;
    lblIgnore: TLabel;
    chkIgnoreReg: TCheckBox;
    mmoClean: TMemo;
    lbl1: TLabel;
    mmoIgnore: TMemo;
    chkIgnoreNoSrc: TCheckBox;
    chkIgnoreCompRef: TCheckBox;
    chkProcessDependencies: TCheckBox;
    chkSaveAndClose: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
    procedure rbCurrUnitClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

  TCnUsesCleanKind = (ukCurrUnit, ukOpenedUnits, ukCurrProject, ukProjectGroup);

{ TCnUsesToolsWizard }

  TCnUsesToolsWizard = class(TCnSubMenuWizard)
  private
    FIdCleaner: Integer;
    FIdInitTree: Integer;
    FIdFromIdent: Integer;
    FIdProjImplUse: Integer;
    FIgnoreInit: Boolean;
    FIgnoreReg: Boolean;
    FIgnoreNoSrc: Boolean;
    FIgnoreCompRef: Boolean;
    FProcessDependencies: Boolean;
    FUseBuildAction: Boolean;  // 是否使用 IDE 的 Build 菜单项点击来编译而不是使用 OTA 接口
    FSaveAndClose: Boolean;    // 对于未打开的文件，Clean 后是否保存并关闭，避免大项目的文件全打开导致耗尽资源
    FIgnoreList: TStringList;
    FCleanList: TStringList;
    FRegExpr: TRegExpr;
    FUnitsMap: TCnStrToStrHashMap; // 用来去重
    FUnitIdents: TStringList; // 存储分析出来的结果供赋值给 DataList
    FUnitNames: TStringList;  // 存储搜索出来的不重复的完整 dcu 们的路径文件名供中间使用
    FSysPath: string;
{$IFDEF SUPPORT_CROSS_PLATFORM}
    FCurrPlatform: string;    // 工程的 Platform 发生变化时 lib 库会变，需要重新解析
{$ENDIF}
    FProjImplUnit: string;
    function MatchInListWithExpr(List: TStrings; const Str: string): Boolean;
    function GetProjectFromModule(AModule: IOTAModule): IOTAProject;
    function ShowKindForm(var AKind: TCnUsesCleanKind): Boolean;
    function CompileUnits(AKind: TCnUsesCleanKind): Boolean;
    function ProcessUnits(AKind: TCnUsesCleanKind; List: TObjectList): Boolean;
    {* 编译后的总体的单元解析查找处理函数，处理 dcu 与源码，结果为 TCnProjectUsesInfo 实例，放 List 里}
    procedure ParseUnitKind(const FileName: string; var Kinds: TCnUsesKinds);
    {* 解析各 unit 源码获取其有无 init、有无 Register 函数等信息}
    procedure GetCompRefUnits(AModule: IOTAModule; AProject: IOTAProject; Units:
      TStrings);
    procedure CheckUnits(List: TObjectList);
    {* 总体的单元分析清理函数，List 来自 ProcessUnits，存储了所有工程的所有引用信息}
    function DoCleanUnit(Buffer: IOTAEditBuffer; Intf, Impl: TStrings): Boolean;
    {* 做单个源码文件的实际清理工作}
    procedure CleanUnitUses(List: TObjectList);
    {* 根据用户的选择，开始做源码的实际清理工作}

    procedure UsesEnumCallback(const AUnitFullName: string; Exists: Boolean;
      FileType: TCnUsesFileType; ModuleSearchType: TCnModuleSearchType);
    procedure CheckReLoadUnitsMap;
    procedure LoadSysUnitsToList(DataList: TStringList);

    procedure CleanExecute;
    procedure InitTreeExecute;
    procedure FromIdentExecute;
    procedure ProjImplExecute;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    procedure Config; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure Execute; override;
    procedure AcquireSubActions; override;

    function IsValidUnitName(const AUnitName: string): Boolean;
  end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnUsesCleanResultFrm, CnUsesInitTreeFrm, DCURecs, CnUsesIdentFrm, CnNative,
  CnWideStrings, CnProgressFrm, CnIDEStrings, CnPasCodeParser, CnWidePasParser;

{$R *.DFM}

const
  csCleanList = 'UsesClean.dat';
  csIgnoreList = 'UsesIgnore.dat';

  csIgnoreInit = 'IgnoreInit';
  csIgnoreReg = 'IgnoreReg';
  csIgnoreNoSrc = 'IgnoreNoSrc';
  csIgnoreCompRef = 'IgnoreCompRef';
  csProcessDependencies = 'ProcessDependencies';
  csUseBuildAction = 'UseBuildAction';
  csSaveAndClose = 'SaveAndClose';
  csDcuExt = '.dcu';

  csProjectBuildCommand = 'ProjectBuildCommand';
  csProjectBuildAllCommand = 'ProjectBuildAllCommand';

{ TCnUsesCleaner }

constructor TCnUsesToolsWizard.Create;
begin
  inherited;
  FIgnoreInit := True;
  FIgnoreReg := True;
  FIgnoreNoSrc := False;
  FIgnoreCompRef := True;
  FProcessDependencies := False;
  FUseBuildAction := False; // 默认使用 OTA 接口，True 时未完整测试，选项不对外开放
  FSaveAndClose := False;   // 默认使用打开后改内存的方式，避免自动存盘，但大项目可能耗尽资源
  FIgnoreList := TStringList.Create;
  FCleanList := TStringList.Create;

  FRegExpr := TRegExpr.Create;
  FRegExpr.ModifierI := True;
end;

destructor TCnUsesToolsWizard.Destroy;
begin
  FRegExpr.Free;
  FCleanList.Free;
  FIgnoreList.Free;
  FUnitsMap.Free;
  FUnitIdents.Free;
  FUnitNames.Free;
  inherited;
end;

procedure TCnUsesToolsWizard.Execute;
begin

end;

procedure TCnUsesToolsWizard.CleanExecute;
var
  Kind: TCnUsesCleanKind;
  List: TObjectList;
begin
  if CnOtaGetProjectGroup <> nil then
  begin
    // 显示选择对话框
    if not ShowKindForm(Kind) then
      Exit;

    // 编译单元
    if not CompileUnits(Kind) then
    begin
      ErrorDlg(SCnUsesCleanerCompileFail);
      Exit;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('UsesCleaner Compile OK. Start to Process Files.');
{$ENDIF}

    // 进行分析
    List := TObjectList.Create;
    try
      if ProcessUnits(Kind, List) then
      begin
        if List.Count = 0 then
        begin
          InfoDlg(SCnUsesCleanerNoneResult);
          Exit;
        end;

        CheckUnits(List);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('UsesCleaner CheckUnits OK. To Show Results.');
{$ENDIF}

        if ShowUsesCleanResultForm(List) then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('UsesCleaner ShowUsesCleanResultForm OK. To Clean Unit Uses. Project Count: ' + IntToStr(List.Count));
{$ENDIF}
          CleanUnitUses(List);
        end;
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('UsesCleaner ProcessUnits Fail.');
{$ENDIF}
      end;
    finally
      List.Free;
    end;   
  end;
end;

function TCnUsesToolsWizard.ShowKindForm(var AKind: TCnUsesCleanKind): Boolean;
var
  Module: IOTAModule;
begin
  Result := False;
  // 显示处理窗口
  with TCnUsesCleanerForm.Create(nil) do
  try
    chkIgnoreInit.Checked := FIgnoreInit;
    chkIgnoreReg.Checked := FIgnoreReg;
    chkIgnoreNoSrc.Checked := FIgnoreNoSrc;
    chkIgnoreCompRef.Checked := FIgnoreCompRef;
    chkProcessDependencies.Checked := FProcessDependencies;
    chkSaveAndClose.Checked := FSaveAndClose;
    mmoIgnore.Lines.Assign(FIgnoreList);
    mmoClean.Lines.Assign(FCleanList);
    Module := CnOtaGetCurrentModule;
    if (Module <> nil) and IsPas(Module.FileName) and (Module.OwnerCount > 0) then
      rbCurrUnit.Checked := True
    else
    begin
      rbCurrUnit.Enabled := False;
      rbOpenedUnits.Checked := True;
    end;

    if ShowModal = mrOK then
    begin
      FIgnoreInit := chkIgnoreInit.Checked;
      FIgnoreReg := chkIgnoreReg.Checked;
      FIgnoreNoSrc := chkIgnoreNoSrc.Checked;
      FIgnoreList.Assign(mmoIgnore.Lines);
      FIgnoreCompRef := chkIgnoreCompRef.Checked;
      FProcessDependencies := chkProcessDependencies.Checked;
      FSaveAndClose := chkSaveAndClose.Checked;
      FCleanList.Assign(mmoClean.Lines);
      if rbCurrUnit.Checked then
        AKind := ukCurrUnit
      else if rbOpenedUnits.Checked then
        AKind := ukOpenedUnits
      else if rbCurrProject.Checked then
        AKind := ukCurrProject
      else
        AKind := ukProjectGroup;

      DoSaveSettings;
      Result := True;
    end;
  finally
    Free;
  end;
end;

function TCnUsesToolsWizard.GetProjectFromModule(AModule: IOTAModule): IOTAProject;
var
  I: Integer;
begin
  Result := AModule.GetOwner(0);
  for I := 1 to AModule.OwnerCount - 1 do
    if AModule.GetOwner(I) = CnOtaGetCurrentProject then
    begin
      Result := AModule.GetOwner(I);
      Break;
    end;
end;

function TCnUsesToolsWizard.CompileUnits(AKind: TCnUsesCleanKind): Boolean;
var
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  I: Integer;

  function DoBuildProjectAction: Boolean;
  var
    Action: TContainedAction;
  begin
{$IFDEF DEBUG}
    CnDebugger.LogEnter('DoBuildProjectAction');
{$ENDIF}

    InfoDlg('Will Build Current Project.');

    Action := FindIDEAction(csProjectBuildCommand);
    if Action <> nil then
      Result := Action.Execute
    else
      Result := False;

{$IFDEF DEBUG}
    CnDebugger.LogLeave('DoBuildProjectAction');
{$ENDIF}
  end;

  function DoBuildAllProjectAction: Boolean;
  var
    Action: TContainedAction;
  begin
{$IFDEF DEBUG}
    CnDebugger.LogEnter('DoBuildAllProjectAction');
{$ENDIF}

    InfoDlg('Will Build All Projects.');

    Action := FindIDEAction(csProjectBuildAllCommand);
    if Action <> nil then
      Result := Action.Execute
    else
      Result := False;

{$IFDEF DEBUG}
    CnDebugger.LogLeave('DoBuildAllProjectAction');
{$ENDIF}
  end;

begin
  Result := False;
  try
    case AKind of
      ukCurrUnit:
        begin
          if FUseBuildAction then
          begin
            Result := DoBuildAllProjectAction; // 不知道当前单元属于哪个 Project，只能全编译
          end
          else
          begin
            Module := CnOtaGetCurrentModule;
            Assert(Assigned(Module) and (Module.OwnerCount > 0));
            Project := GetProjectFromModule(Module);
            Result := CompileProject(Project);
          end;
        end;
      ukCurrProject:
        begin
          Project := CnOtaGetCurrentProject;
          Assert(Assigned(Project));
          if FUseBuildAction then
            Result := DoBuildProjectAction
          else
            Result := CompileProject(Project);
        end;
    else
      begin
        if FUseBuildAction then
        begin
          Result := DoBuildAllProjectAction;
        end
        else
        begin
          ProjectGroup := CnOtaGetProjectGroup;
          Assert(Assigned(ProjectGroup));
          for I := 0 to ProjectGroup.ProjectCount - 1 do
          begin
            Result := CompileProject(ProjectGroup.Projects[I]);
            if not Result then
              Break;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException('Compile Units ' + E.Message);
  end;
end;

function TCnUsesToolsWizard.ProcessUnits(AKind: TCnUsesCleanKind;
  List: TObjectList): Boolean;
var
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  DcuPath: string;
  DcuName: string;
  ProjectInfo: TCnProjectUsesInfo;
  UsesInfo: TCnEmptyUsesInfo;
  I: Integer;

  function ModuleExists(const FileName: string): Boolean;
  var
    I, J: Integer;
  begin
    for I := 0 to List.Count - 1 do
    begin
      with TCnProjectUsesInfo(List[I]) do
      begin
        for J := 0 to Units.Count - 1 do
        begin
          if SameFileName(TCnEmptyUsesInfo(Units[I]).SourceFileName,
            FileName) then
          begin
            Result := True;
            Exit;
          end;
        end;
      end;
    end;
    Result := False;
  end;

  function GetDcuName(const ADcuPath, ASourceFileName: string): string;
  begin
    if ADcuPath = '' then
      Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
    else
      Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
  end;

  // 单独处理单个单元
  function ProcessAUnit(const ADcuName, ASourceFileName: string;
    AProject: IOTAProject; var AInfo: TCnEmptyUsesInfo): Boolean;
  begin
    AInfo := nil;
    Result := False;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('UsesCleaner ProcessAUnit: ' + ADcuName);
  {$ENDIF}

    if IsDprOrPas(ASourceFileName) and FileExists(ADcuName) then
    begin
      AInfo := TCnEmptyUsesInfo.Create(ADcuName, ASourceFileName, AProject);
      Result := AInfo.Process;
      if not Result then
        FreeAndNil(AInfo);
    end;
  end;

  function ProcessAProject(AProject: IOTAProject; OpenedOnly, AProcessDependencies: Boolean): Boolean;
  var
    ProcessedUnitNames: TStringList;

    function RecursiveProcessUnit(const AUnitName: string): Boolean;
    var
      UnitUsesInfo: TCnUnitUsesInfo;
      DcuName: string;
      SourceFileName: string;
      I: Integer;
    begin
      Result := True;
      if ProcessedUnitNames.IndexOf(LowerCase(AUnitName)) <> -1 then
        Exit;

      DcuName := GetDcuName(DcuPath, AUnitName + '.pas');
      if not FileExists(DcuName) then
        Exit;

      SourceFileName := GetFileNameFromModuleName(AUnitName);

      if (SourceFileName = '') or not FileExists(SourceFileName) or
        ModuleExists(SourceFileName) then
        Exit;

      if ProcessAUnit(DcuName, SourceFileName, Project, UsesInfo) then
      begin
        if (UsesInfo.IntfCount > 0) or (UsesInfo.ImplCount > 0) then
          ProjectInfo.Units.Add(UsesInfo)
        else
          FreeAndNil(UsesInfo);
      end
      else if not QueryDlg(Format(SCnUsesCleanerProcessError,
        [_CnExtractFileName(SourceFileName)])) then
      begin
        Result := False;
        Exit;
      end;

      ProcessedUnitNames.Add(LowerCase(AUnitName));

      UnitUsesInfo := TCnUnitUsesInfo.Create(DcuName);
      try
        for I := 0 to UnitUsesInfo.IntfUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.IntfUses[I]);
          if not Result then
            Exit;
        end;

        for I := 0 to UnitUsesInfo.ImplUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.ImplUses[I]);
          if not Result then
            Exit;
        end;
      finally
        FreeAndNil(UnitUsesInfo);
      end;
      Result := True;
    end;

    function ProcessModuleDependencies(const ADcuName: string): Boolean;
    var
      UnitUsesInfo: TCnUnitUsesInfo;
      I: Integer;
    begin
      UnitUsesInfo := TCnUnitUsesInfo.Create(ADcuName);
      try
        for I := 0 to UnitUsesInfo.IntfUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.IntfUses[I]);
          if not Result then
            Exit;
        end;

        for I := 0 to UnitUsesInfo.ImplUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.ImplUses[I]);
          if not Result then
            Exit;
        end;
      finally
        FreeAndNil(UnitUsesInfo);
      end;
      Result := True;
    end;

  var
    I: Integer;
    ModuleInfo: IOTAModuleInfo;
    Opened: Boolean;
  begin
    Result := False;
    DcuPath := GetProjectDcuPath(Project);
    ProjectInfo := TCnProjectUsesInfo.Create;
    ProjectInfo.Project := AProject;
    try
      for I := 0 to AProject.GetModuleCount - 1 do
      begin
        ModuleInfo := AProject.GetModule(I);
        if not Assigned(ModuleInfo) or not IsPas(ModuleInfo.FileName) or
          ModuleExists(ModuleInfo.FileName) then
          Continue;

        Opened := CnOtaIsFileOpen(ModuleInfo.FileName);
        if OpenedOnly and not Opened then
          Continue;

        Module := ModuleInfo.OpenModule;
        try
          if not Assigned(Module) or not IsDprOrPas(Module.FileName) then
            Continue;

          DcuName := GetDcuName(DcuPath, Module.FileName);
          if not FileExists(DcuName) then
            Continue;

          if ProcessAUnit(DcuName, Module.FileName, Project, UsesInfo) then
          begin
            if (UsesInfo.IntfCount > 0) or (UsesInfo.ImplCount > 0) then
              ProjectInfo.Units.Add(UsesInfo)
            else
              FreeAndNil(UsesInfo);
          end
          else if not QueryDlg(Format(SCnUsesCleanerProcessError,
            [_CnExtractFileName(Module.FileName)])) then
          begin
            Exit;
          end;
        finally
          if not Opened and Assigned(Module) then
            Module.CloseModule(True);
        end;
      end;

      if AProcessDependencies then
      begin
        ProcessedUnitNames := TStringList.Create;
        try
          for I := 0 to AProject.GetModuleCount - 1 do
          begin
            ModuleInfo := AProject.GetModule(I);
            if not Assigned(ModuleInfo) or not IsPas(ModuleInfo.FileName) then
              Continue;

            DcuName := GetDcuName(DcuPath, Module.FileName);
            if not FileExists(DcuName) then
              Continue;

            if not ProcessModuleDependencies(DcuName) then
              Exit;
          end;
        finally
          FreeAndNil(ProcessedUnitNames);
        end;
      end;

      if ProjectInfo.Units.Count > 0 then
        List.Add(ProjectInfo);
      Result := True;
    finally
      if not Result then
        ProjectInfo.Free;
    end;
  end;

begin
  Result := False;
  try
    List.Clear;
    case AKind of
      ukCurrUnit:
        begin
          Module := CnOtaGetCurrentModule;
          Assert(Assigned(Module) and (Module.OwnerCount > 0));
          Project := GetProjectFromModule(Module);
          DcuPath := GetProjectDcuPath(Project);
          DcuName := GetDcuName(DcuPath, Module.FileName);
          Result := ProcessAUnit(DcuName, Module.FileName, Project, UsesInfo);
          if Result then
          begin
            if (UsesInfo.IntfCount > 0) or (UsesInfo.ImplCount > 0) then
            begin
              ProjectInfo := TCnProjectUsesInfo.Create;
              ProjectInfo.Project := Project;
              ProjectInfo.Units.Add(UsesInfo);
              List.Add(ProjectInfo);
            end
            else
            begin
              FreeAndNil(UsesInfo);
            end;
          end
          else
            ErrorDlg(Format(SCnUsesCleanerUnitError, [_CnExtractFileName(Module.FileName)]))
        end;
      ukCurrProject:
        begin
          Project := CnOtaGetCurrentProject;
          Assert(Assigned(Project));
          Result := ProcessAProject(Project, False, FProcessDependencies);
        end;
    else
      begin
        ProjectGroup := CnOtaGetProjectGroup;
        Assert(Assigned(ProjectGroup));
        for I := 0 to ProjectGroup.ProjectCount - 1 do
        begin
          Project := ProjectGroup.GetProject(I);
          Result := ProcessAProject(Project, AKind = ukOpenedUnits, FProcessDependencies);
          if not Result then
            Break;
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException('Process Units ' + E.Message);
  end;
end;

procedure TCnUsesToolsWizard.ParseUnitKind(const FileName: string;
  var Kinds: TCnUsesKinds);
var
  Stream: TMemoryStream;
{$IFDEF UNICODE}
  Lex: TCnPasWideLex;
{$ELSE}
  Lex: TmwPasLex;
{$ENDIF}
  Token: TTokenKind;
  RegDecl: Boolean;
begin
  Stream := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Stream, True); // Ansi/Ansi/Utf16

{$IFDEF UNICODE}
    Lex := TCnPasWideLex.Create;
    Lex.Origin := PWideChar(Stream.Memory);
{$ELSE}
    Lex := TmwPasLex.Create;
    Lex.Origin := PAnsiChar(Stream.Memory);
{$ENDIF}

    try
      RegDecl := False;
      Token := Lex.TokenID;
      while not (Lex.TokenID in [tkImplementation, tkNull]) do
      begin
        if (Lex.TokenID = tkRegister) and (Token = {$IFDEF DELPHI2010_UP}TTokenKind.{$ENDIF}tkProcedure) then
          RegDecl := True;
        Token := Lex.TokenID;
        Lex.NextNoJunk;
      end;

      Token := Lex.TokenID;
      while Lex.TokenID <> tkNull do
      begin
        if RegDecl and (Lex.TokenID = tkRegister) and (Token = {$IFDEF DELPHI2010_UP}TTokenKind.{$ENDIF}tkProcedure) then
          Include(Kinds, ukHasRegProc);

        // initialization 后是标识符或 begin 等才表示有效初始化节，不太严谨。
        if Token = tkInitialization then
          if (Lex.TokenID in [tkIdentifier, tkBegin, tkFinalization, tkCompDirect]) then
            Include(Kinds, ukHasInitSection);

        Token := Lex.TokenID;
        Lex.NextNoJunk;
      end;
    finally
      Lex.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TCnUsesToolsWizard.GetCompRefUnits(AModule: IOTAModule; AProject:
  IOTAProject; Units: TStrings);
var
  FormEditor: IOTAFormEditor;
  Root: TComponent;
  I: Integer;

  // 添加组件及其父类的定义单元
  procedure DoAddCompRef(ACls: TClass);
  var
    TypeData: PTypeData;
  begin
    if (ACls <> nil) and (ACls.ClassInfo <> nil) then
    begin
      TypeData := GetTypeData(PTypeInfo(ACls.ClassInfo));
      if (TypeData <> nil) and (Units.IndexOf({$IFDEF UNICODE}string{$ENDIF}(TypeData^.UnitName)) < 0) then
        Units.Add({$IFDEF UNICODE}string{$ENDIF}(TypeData^.UnitName));
      DoAddCompRef(ACls.ClassParent);
    end;
  end;

  // 增加组件属性中引用的外部窗体单元
  procedure DoAddPropRef(AObj: TPersistent);
  var
    PropList: PPropList;
    Count, I, J: Integer;
    Obj: TObject;
    FormName, UnitName: string;
  begin
    try
      Count := GetPropList(AObj.ClassInfo, [tkClass], nil);
    except
      Exit;
    end;

    if Count > 0 then
    begin
      GetMem(PropList, Count * SizeOf(PPropInfo));
      try
        GetPropList(AObj.ClassInfo, [tkClass], PropList);
        for I := 0 to Count - 1 do
        begin
          Obj := TObject(GetOrdProp(AObj, PropList[I]));
          if Obj <> nil then
          begin
            if Obj is TComponent then
            begin
              if (TComponent(Obj).Owner <> nil) and (TComponent(Obj).Owner <> Root) then
              begin
                FormName := TComponent(Obj).Owner.Name;
                for J := 0 to AProject.GetModuleCount - 1 do
                begin
                  if SameText(AProject.GetModule(J).FormName, FormName) then
                  begin
                    UnitName := _CnChangeFileExt(_CnExtractFileName(
                      AProject.GetModule(J).FileName), '');
                    if Units.IndexOf(UnitName) < 0 then
                      Units.Add(UnitName);
                  end;
                end;
              end;
            end
            else if Obj is TCollection then
            begin
              for J := 0 to TCollection(Obj).Count - 1 do
                DoAddPropRef(TCollection(Obj).Items[J]);
            end
            else if Obj is TPersistent then
            begin
              DoAddPropRef(TPersistent(Obj));
            end;  
          end;
        end;
      finally
        FreeMem(PropList);
      end;
    end;      
  end;
begin
  Units.Clear;
  try
    FormEditor := CnOtaGetFormEditorFromModule(AModule);
    if Assigned(FormEditor) then
    begin
      Root := CnOtaGetRootComponentFromEditor(FormEditor);
      if Assigned(Root) then
      begin
        for I := 0 to Root.ComponentCount - 1 do
        begin
          DoAddCompRef(Root.Components[I].ClassType);
          DoAddPropRef(Root.Components[I]);
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException('Get CompRef Units ' + E.Message);
  end;   
end;

procedure TCnUsesToolsWizard.CheckUnits(List: TObjectList);
var
  UnitList, CompRef: TStringList;
  I, J, K, U: Integer;
  FileName: string;
  Kinds: TCnUsesKinds;
  Checked: Boolean;
begin
  // 分析公共的单元
  UnitList := TStringList.Create;
  try
    // 取得所有引用到的单元
    UnitList.Sorted := True;
    for I := 0 to List.Count - 1 do
      for J := 0 to TCnProjectUsesInfo(List[I]).Units.Count - 1 do
        with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[I]).Units[J]) do
        begin
          for K := 0 to IntfCount - 1 do
            if UnitList.IndexOf(IntfItems[K].Name) < 0 then
              UnitList.AddObject(IntfItems[K].Name, TObject(Pointer(Project)));
          for K := 0 to ImplCount - 1 do
            if UnitList.IndexOf(ImplItems[K].Name) < 0 then
              UnitList.AddObject(ImplItems[K].Name, TObject(Pointer(Project)));
        end;

    // 分析单元类型
    for U := 0 to UnitList.Count - 1 do
    begin
      Kinds := [];

      if MatchInListWithExpr(FCleanList, UnitList[U]) then
        Include(Kinds, ukInCleanList);
      if MatchInListWithExpr(FIgnoreList, UnitList[U]) then
        Include(Kinds, ukInIgnoreList);

      FileName := GetFileNameFromModuleName(UnitList[U],
        IOTAProject(Pointer(UnitList.Objects[U])));
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Check Unit ' + UnitList[U] + ': ' + FileName);
    {$ENDIF}

      if FileName = '' then
        Include(Kinds, ukNoSource)
      else
        ParseUnitKind(FileName, Kinds);

      // 判断是否默认选择
      if ukInCleanList in Kinds then
        Checked := True
      else if ukInIgnoreList in Kinds then
        Checked := False
      else if FIgnoreInit and (ukHasInitSection in Kinds) then
        Checked := False
      else if FIgnoreReg and (ukHasRegProc in Kinds) then
        Checked := False
      else if FIgnoreNoSrc and (ukNoSource in Kinds) then
        Checked := False
      else
        Checked := True;

      for I := 0 to List.Count - 1 do
      begin
        for J := 0 to TCnProjectUsesInfo(List[I]).Units.Count - 1 do
        begin
          with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[I]).Units[J]) do
          begin
            for K := 0 to IntfCount - 1 do
              if SameText(UnitList[U], IntfItems[K].Name) then
              begin
                IntfItems[K].Kinds := Kinds;
                IntfItems[K].Checked := Checked;
              end;
            for K := 0 to ImplCount - 1 do
              if SameText(UnitList[U], ImplItems[K].Name) then
              begin
                ImplItems[K].Kinds := Kinds;
                ImplItems[K].Checked := Checked;
              end;
          end;
        end;
      end;
    end;

  finally
    UnitList.Free;
  end;

  // 分析每个单元的组件引用单元
  CompRef := TStringList.Create;
  try
    for I := 0 to List.Count - 1 do
    begin
      for J := 0 to TCnProjectUsesInfo(List[I]).Units.Count - 1 do
      begin
        with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[I]).Units[J]) do
        begin
          CompRef.Clear;
          GetCompRefUnits(CnOtaGetModule(SourceFileName), Project, CompRef);
          if CompRef.Count > 0 then
          begin
            for K := 0 to IntfCount - 1 do
            begin
              if CompRef.IndexOf(IntfItems[K].Name) >= 0 then
              begin
                IntfItems[K].Kinds := IntfItems[K].Kinds + [tkCompRef];
                if FIgnoreCompRef and not (ukInCleanList in IntfItems[K].Kinds) then
                  IntfItems[K].Checked := False;
              end;
            end;

            for K := 0 to ImplCount - 1 do
            begin
              if CompRef.IndexOf(ImplItems[K].Name) >= 0 then
              begin
                ImplItems[K].Kinds := ImplItems[K].Kinds + [tkCompRef];
                if FIgnoreCompRef and not (ukInCleanList in ImplItems[K].Kinds) then
                  ImplItems[K].Checked := False;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    CompRef.Free;
  end;
end;

type
  TPrvUsesItem = class
    Name: string;
    BeginPos: Longint;
    EndPos: Longint; // Position at the end of the unit name
    CommaBeforePos: Longint; // Position of ',' before unit name
    CommaAfterPos: Longint;  // Position of ',' after unit name
    SpaceAfter: Boolean;
  end;

function TCnUsesToolsWizard.DoCleanUnit(Buffer: IOTAEditBuffer; Intf, Impl:
  TStrings): Boolean;
var
  SrcStream: TMemoryStream;
  Writer: IOTAEditWriter;
{$IFDEF UNICODE}
  Lex: TCnPasWideLex;
{$ELSE}
  Lex: TmwPasLex;
{$ENDIF}
  Source: string;

  // 以下代码部分参考了 GExperts 的 GX_UsesManager 单元
  // liuxiao 加入对带点号文件名的支持
  function GetUsesSource(List: TStrings): string;
  var
    UsesList: TObjectList;
    Item: TPrvUsesItem;
    LastCommaPos: Integer;
    CPos, BegPos, EndPos: Integer;
    I, UnitStartPos, UnitEndPos: Integer;
    S: string;

    function SourceUsesListContainsUnitName(const ACleanUnitName: string): Boolean;
{$IFDEF SUPPORT_UNITNAME_DOT}
    var
      J, L1, L2: Integer;
      U: string;
{$ENDIF}
    begin
      Result := List.IndexOf(Item.Name) >= 0;
{$IFDEF SUPPORT_UNITNAME_DOT}
      if not Result then
      begin
        U := '.' + ACleanUnitName;
        L1 := Length(U);

        for J := 0 to List.Count - 1 do
        begin
          L2 := Length(List[J]);
          if L2 > L1 then
          begin
            if StrIComp(PChar(Copy(List[J], L2 - L1 + 1, MaxInt)), PChar(U)) = 0 then
            begin
              Result := True;
              Exit;
            end;
          end;
        end;
      end;
{$ENDIF}
    end;

  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('GetUsesSource To Clean List: %s.', [List.Text]);
{$ENDIF}
    Result := '';
    CPos := Lex.TokenPos;
    UsesList := TObjectList.Create;
    try
      Item := nil;
      LastCommaPos := 0;
      UnitStartPos := 0;
      UnitEndPos := 0;
      while not (Lex.TokenID in [tkNull, tkSemiColon]) do
      begin
        if Lex.TokenID = tkIdentifier then
        begin
          if UnitStartPos = 0 then
            UnitStartPos := Lex.TokenPos;
          UnitEndPos := Lex.RunPos;
          S := S + string(Lex.Token);
        end
        else if Lex.TokenID = tkPoint then
        begin
          S := S + '.';
          UnitEndPos := Lex.RunPos;
        end
        else if Trim(S) <> '' then
        begin
          Item := TPrvUsesItem.Create;
          Item.Name := S;
          Item.BeginPos := UnitStartPos;
          Item.EndPos := UnitEndPos;
          if LastCommaPos <> 0 then
            Item.CommaBeforePos := LastCommaPos - 1;
          Item.CommaAfterPos := 0;
          UsesList.Add(Item);
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('GetUsesSource UsesList Add: %s.', [Item.Name]);
{$ENDIF}
          S := '';
          UnitStartPos := 0;
          UnitEndPos := 0;
        end;

        if Lex.TokenID = tkComma then
        begin
          LastCommaPos := Lex.RunPos;
          if Item <> nil then
          begin
            Item.CommaAfterPos := LastCommaPos - 1;
            if Lex.Origin[Lex.RunPos] = ' ' then
              Item.SpaceAfter := True;
          end;
        end;
        
        Lex.NextNoJunk;
      end;
      if (Lex.TokenID = tkSemiColon) and (Trim(S) <> '') then
      begin
        // Add last unit before the semicolon
        Item := TPrvUsesItem.Create;
        Item.Name := S;
        Item.BeginPos := UnitStartPos;
        Item.EndPos := UnitEndPos;
        if LastCommaPos <> 0 then
          Item.CommaBeforePos := LastCommaPos - 1;
        Item.CommaAfterPos := 0;
        UsesList.Add(Item);  // UsesList 里拿到了源文件中的引用单元名，注意可能没有 WinApi 等前缀
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('GetUsesSource UsesList Add Last: %s.', [Item.Name]);
{$ENDIF}
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('GetUsesSource UsesList Count: %d. To Clean List Count %d.',
        [UsesList.Count, List.Count]);
{$ENDIF}
      if Lex.TokenID <> tkNull then
        Lex.Next;
      SetLength(Result, Lex.TokenPos - CPos);
      Move((Pointer(TCnNativeInt(Lex.Origin) + CPos * SizeOf(Char)))^, Result[1],
        (Lex.TokenPos - CPos) * SizeOf(Char));

{$IFDEF DEBUG}
//    CnDebugger.LogFmt('GetUsesSource First Copy Result %s.', [Result]);
{$ENDIF}
      for I := UsesList.Count - 1 downto 0 do
      begin
        Item := TPrvUsesItem(UsesList[I]);
        if SourceUsesListContainsUnitName(Item.Name) then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('GetUsesSource Has Name %s.', [Item.Name]);
{$ENDIF}
          if I = 0 then // First in the uses clause
          begin
            if Item.CommaAfterPos <> 0 then
              EndPos := Item.CommaAfterPos + 1
            else
              EndPos := Item.EndPos;
            BegPos := Item.BeginPos;
          end
          else if I = UsesList.Count - 1 then // Last in the uses clause
          begin
            EndPos := Item.EndPos;
            if Item.CommaBeforePos <> 0 then
              BegPos := Item.CommaBeforePos
            else
              BegPos := Item.BeginPos;
          end
          else // In the middle of the uses clause
          begin
            if Item.CommaAfterPos = Item.EndPos then
            begin // Comma directly after unit
              BegPos := Item.BeginPos;
              EndPos := Item.CommaAfterPos + 1;
            end
            else // Comma before unit
            begin
              if Item.CommaBeforePos <> 0 then
                BegPos := Item.CommaBeforePos
              else
                BegPos := Item.BeginPos;
              EndPos := Item.EndPos;
            end;
          end;
          if Item.SpaceAfter then
            Inc(EndPos);

          // 防止删除最后的 ; 号
          EndPos := Min(EndPos, CPos + Length(Result) - 1);
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('GetUsesSource Before a Delete BegPos %d, CPos %d, EndPos %d.',
//          [BegPos, CPos, EndPos]);
{$ENDIF}
          Delete(Result, BegPos - CPos + 1, EndPos - BegPos);
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('GetUsesSource After a Delete Result %s.', [Result]);
{$ENDIF}
          UsesList.Delete(I);
        end;
      end;
      
      if UsesList.Count = 0 then
        Result := '';
{$IFDEF DEBUG}
      CnDebugger.LogMsg('GetUsesSource Return: ' + Result);
{$ENDIF}
    finally
      UsesList.Free;
    end;
  end;
begin
  Result := False;
  try
    if Buffer.IsReadOnly then Exit;

    SrcStream := nil;
    Lex := nil;
    try
      SrcStream := TMemoryStream.Create;
      EditFilerSaveFileToStream(Buffer.FileName, SrcStream, True); // Ansi/Ansi/Utf16

{$IFDEF UNICODE}
      Lex := TCnPasWideLex.Create;
      Lex.Origin := PWideChar(SrcStream.Memory);
{$ELSE}
      Lex := TmwPasLex.Create;
      Lex.Origin := PAnsiChar(SrcStream.Memory);
{$ENDIF}

      Writer := Buffer.CreateUndoableWriter;
      
      while not (Lex.TokenID in [tkImplementation, tkUses, tkNull]) do
        Lex.NextNoJunk;

      if (Intf.Count > 0) and (Lex.TokenID = tkUses) then
      begin
{$IFDEF UNICODE}
        // TokenPos 之前的，因而得 -1，但函数内部偏移以 1 开始，TokenPos 又 0 开始，因而得加 1。抵消
        Writer.CopyTo(CalcUtf8LengthFromWideStringOffset(Lex.Origin, Lex.TokenPos));   // Utf16 CharPos to Utf8 Offset
        Source := GetUsesSource(Intf);
        Writer.DeleteTo(CalcUtf8LengthFromWideStringOffset(Lex.Origin, Lex.TokenPos));
{$ELSE}
        Writer.CopyTo(Lex.TokenPos);
        Source := ConvertEditorTextToText(GetUsesSource(Intf));
        Writer.DeleteTo(Lex.TokenPos);
{$ENDIF}

        if Source <> '' then
        begin
          Writer.Insert(PAnsiChar(ConvertTextToEditorText({$IFDEF UNICODE}AnsiString{$ENDIF}(Source))));
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Intf write: ' + Source);
{$ENDIF}
        end;
      end;
      
      // 跳过当前的符号，避免在 impl 区处理 intf 的 uses
      Lex.Next;
{$IFDEF UNICODE}
      Writer.CopyTo(CalcUtf8LengthFromWideStringOffset(Lex.Origin, Lex.TokenPos)); // Utf16 CharPos to Utf8 Offset
{$ELSE}
      Writer.CopyTo(Lex.TokenPos);
{$ENDIF}

      if Impl.Count > 0 then
      begin
        while not (Lex.TokenID in [tkUses, tkNull]) do
          Lex.NextNoJunk;

        if Lex.TokenID = tkUses then
        begin
{$IFDEF UNICODE}
          Writer.CopyTo(CalcUtf8LengthFromWideStringOffset(Lex.Origin, Lex.TokenPos));   // Utf16 CharPos to Utf8 Offset
          Source := GetUsesSource(Impl);
          Writer.DeleteTo(CalcUtf8LengthFromWideStringOffset(Lex.Origin, Lex.TokenPos));
{$ELSE}
          Writer.CopyTo(Lex.TokenPos);
          Source := ConvertEditorTextToText(GetUsesSource(Impl));
          Writer.DeleteTo(Lex.TokenPos);
{$ENDIF}

          if Source <> '' then
          begin
            Writer.Insert(PAnsiChar(ConvertTextToEditorText({$IFDEF UNICODE}AnsiString{$ENDIF}(Source))));
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Impl write: ' + Source);
{$ENDIF}
          end;
        end;
      end;

      Writer.CopyTo(SrcStream.Size);
      Result := True;
    finally
      Writer := nil;
      Lex.Free;
      SrcStream.Free;
    end;
  except
    ;
  end;          
end;

procedure TCnUsesToolsWizard.CleanUnitUses(List: TObjectList);

  function GetEditBuffer(const aUsesInfo: TCnEmptyUsesInfo; out ABuffer: IOTAEditBuffer): Boolean;
  var
    SrcEditor: IOTAEditor;
  begin
    ABuffer := nil;
    SrcEditor := CnOtaGetEditor(aUsesInfo.SourceFileName);
    if not Assigned(SrcEditor) then
    begin
      if CnOtaOpenFile(aUsesInfo.SourceFileName) then
        SrcEditor := CnOtaGetEditor(aUsesInfo.SourceFileName);
    end;

    if Assigned(SrcEditor) then
      ABuffer := SrcEditor as IOTAEditBuffer;

    Result := Assigned(ABuffer);
  end;

var
  Intf, Impl, Logs: TStringList;
  I, J, K: Integer;
  UCnt, Cnt: Integer;
  FileName: string;
  Buffer: IOTAEditBuffer;
  UsesInfo: TCnEmptyUsesInfo;
  Opened: Boolean;
begin
  Intf := nil;
  Impl := nil;
  Logs := nil;
  UCnt := 0;
  Cnt := 0;

  try
    Intf := TStringList.Create;
    Impl := TStringList.Create;
    Logs := TStringList.Create;

    for I := 0 to List.Count - 1 do
    begin
      for J := 0 to TCnProjectUsesInfo(List[I]).Units.Count - 1 do
      begin
        // 开始处理单个文件
        UsesInfo := TCnEmptyUsesInfo(TCnProjectUsesInfo(List[I]).Units[J]);
        Intf.Clear;
        Impl.Clear;

        for K := 0 to UsesInfo.IntfCount - 1 do
          if UsesInfo.IntfItems[K].Checked then
            Intf.Add(UsesInfo.IntfItems[K].Name);
        for K := 0 to UsesInfo.ImplCount - 1 do
          if UsesInfo.ImplItems[K].Checked then
            Impl.Add(UsesInfo.ImplItems[K].Name);

{$IFDEF DEBUG}
        Cndebugger.LogFmt('CleanUnitUses Source %s Intf %d, Impl %d',
          [UsesInfo.SourceFileName, Intf.Count, Impl.Count]);
{$ENDIF}

        if (Intf.Count > 0) or (Impl.Count > 0) then
        begin
          Opened := CnOtaIsFileOpen(UsesInfo.SourceFileName);
          try
            if GetEditBuffer(UsesInfo, Buffer) and
              DoCleanUnit(Buffer, Intf, Impl) then
            begin
              Inc(UCnt);
              Inc(Cnt, Intf.Count + Impl.Count);
              Logs.Add(UsesInfo.SourceFileName);
              if Intf.Count > 0 then
                Logs.Add('  Interface Uses: ' + Intf.CommaText);
              if Impl.Count > 0 then
                Logs.Add('  Implementation Uses: ' + Impl.CommaText);
            end
            else if not QueryDlg(Format(SCnUsesCleanerProcessError,
              [_CnExtractFileName(UsesInfo.SourceFileName)])) then
              Exit;
          finally
            if not Opened and FSaveAndClose and FileExists(UsesInfo.SourceFileName) then
            begin
{$IFDEF DEBUG}
              CnDebugger.LogMsg('Clean Result. Auto Save and Close ' + UsesInfo.SourceFileName);
{$ENDIF}
              CnOtaSaveFile(UsesInfo.SourceFileName, True);
              Sleep(0);
              CnOtaCloseFileByAction(UsesInfo.SourceFileName);
            end;
          end;
        end;
      end;
    end;
  finally
    Intf.Free;
    Impl.Free;
    if Cnt > 0 then
    begin
      if QueryDlg(Format(SCnUsesCleanerReport, [Cnt, UCnt])) then
      begin
        FileName := GetWindowsTempPath + 'CnUsesCleaner.txt';
        Logs.SaveToFile(FileName);
        RunFile(FileName);
      end;
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Clean Result 0');
{$ENDIF}
    end;
    Logs.Free;
  end;
end;

procedure TCnUsesToolsWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FIgnoreInit := Ini.ReadBool('', csIgnoreInit, FIgnoreInit);
  FIgnoreReg := Ini.ReadBool('', csIgnoreReg, FIgnoreReg);
  FIgnoreNoSrc := Ini.ReadBool('', csIgnoreNoSrc, FIgnoreNoSrc);
  FIgnoreCompRef := Ini.ReadBool('', csIgnoreCompRef, FIgnoreCompRef);
  FProcessDependencies := Ini.ReadBool('', csProcessDependencies, FProcessDependencies);
  FUseBuildAction := Ini.ReadBool('', csUseBuildAction, FUseBuildAction);
  FSaveAndClose := Ini.ReadBool('', csSaveAndClose, FSaveAndClose);
  WizOptions.LoadUserFile(FIgnoreList, csIgnoreList);
  WizOptions.LoadUserFile(FCleanList, csCleanList);
end;

procedure TCnUsesToolsWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteBool('', csIgnoreInit, FIgnoreInit);
  Ini.WriteBool('', csIgnoreReg, FIgnoreReg);
  Ini.WriteBool('', csIgnoreNoSrc, FIgnoreNoSrc);
  Ini.WriteBool('', csIgnoreCompRef, FIgnoreCompRef);
  Ini.WriteBool('', csProcessDependencies, FProcessDependencies);
  Ini.WriteBool('', csUseBuildAction, FUseBuildAction);
  Ini.WriteBool('', csSaveAndClose, FSaveAndClose);
  WizOptions.SaveUserFile(FIgnoreList, csIgnoreList);
  WizOptions.SaveUserFile(FCleanList, csCleanList);
end;

function TCnUsesToolsWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnUsesToolsWizard.Config;
begin
  if ShowShortCutDialog(SCnUsesToolsName) then
    DoSaveSettings;
end;

function TCnUsesToolsWizard.GetCaption: string;
begin
  Result := SCnUsesToolsMenuCaption;
end;

function TCnUsesToolsWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnUsesToolsWizard.GetHint: string;
begin
  Result := SCnUsesToolsMenuHint;
end;

function TCnUsesToolsWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnUsesToolsWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnUsesToolsName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnUsesToolsComment;
end;

function TCnUsesToolsWizard.MatchInListWithExpr(List: TStrings;
  const Str: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (List = nil) or (Str = '') then
    Exit;

  for I := 0 to List.Count - 1 do
  begin
    if (Str = List[I]) or RegExpContainsText(FRegExpr, Str, List[I]) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnUsesToolsWizard.AcquireSubActions;
begin
  FIdCleaner := RegisterASubAction(SCnUsesToolsCleaner, SCnUsesCleanerMenuCaption,
    0, SCnUsesCleanerMenuHint);
  FIdInitTree := RegisterASubAction(SCnUsesToolsInitTree, SCnUsesInitTreeMenuCaption,
    0, SCnUsesInitTreeMenuHint);
  FIdFromIdent := RegisterASubAction(ScnUsesToolsFromIdent, SCnUsesUnitFromIdentMenuCaption,
    0, SCnUsesUnitFromIdentMenuHint);
  FIdProjImplUse := RegisterASubAction(SCnUsesToolsProjImplUse, SCnUsesToolsProjImplUseMenuCaption,
    0, SCnUsesToolsProjImplUseMenuHint);
end;

procedure TCnUsesToolsWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdCleaner then
    CleanExecute
  else if Index = FIdInitTree then
    InitTreeExecute
  else if Index = FIdFromIdent then
    FromIdentExecute
  else if Index = FIdProjImplUse then
    ProjImplExecute;
end;

procedure TCnUsesToolsWizard.SubActionUpdate(Index: Integer);
begin
  if (Index = FIdCleaner) or (Index = FIdInitTree) then
    SubActions[Index].Enabled := CnOtaGetProjectGroup <> nil
  else if Index = FIdProjImplUse then
    SubActions[Index].Enabled := CnOtaGetCurrentProject <> nil
end;

procedure TCnUsesToolsWizard.InitTreeExecute;
begin
  with TCnUsesInitTreeForm.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TCnUsesToolsWizard.CheckReLoadUnitsMap;
var
  ToReload: Boolean;
  Paths: TStringList;
{$IFDEF SUPPORT_CROSS_PLATFORM}
  S: string;
{$ENDIF}
begin
  ToReload := False;

  if FUnitsMap = nil then
  begin
    FUnitsMap := TCnStrToStrHashMap.Create;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('First Init. To Reload Dcus.');
{$ENDIF}
    ToReload := True;

    // 都记录下来备用
{$IFDEF SUPPORT_CROSS_PLATFORM}
    FCurrPlatform := CnOtaGetProjectPlatform(nil);
{$ENDIF}

    Paths := TStringList.Create;
    try
      GetLibraryPath(Paths, False);
      FSysPath := Paths.Text;
    finally
      Paths.Free;
    end;
  end
  else
  begin
    // 检查是否要重新载入系统 Units，条件为如果当前工程的平台发生改变（支持跨平台时），或系统路径发生改变
{$IFDEF SUPPORT_CROSS_PLATFORM}
    S := CnOtaGetProjectPlatform(nil);
    if S <> FCurrPlatform then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Current Platform Changed from %s to %s. To Reload Dcus.', [FCurrPlatform, S]);
{$ENDIF}
      ToReload := True;
      FCurrPlatform := S;
    end;
{$ENDIF}

    if not ToReload then
    begin
      Paths := TStringList.Create;
      try
        GetLibraryPath(Paths, False);
        if FSysPath <> Paths.Text then
        begin
          ToReload := True;
          FSysPath := Paths.Text; // 先保存
{$IFDEF DEBUG}
          CnDebugger.LogMsg('System Library Paths Changed. To Reload Dcus.');
{$ENDIF}
        end;
      finally
        Paths.Free;
      end;
    end;
  end;

  if ToReload then
  begin
    Screen.Cursor := crHourGlass;
    try
      ShowProgress(SCnUsesUnitAnalyzeWaiting);
      if FUnitIdents = nil then
        FUnitIdents := TStringList.Create
      else
        FUnitIdents.Clear;

      LoadSysUnitsToList(FUnitIdents);
{$IFDEF DEBUG}
      CnDebugger.LogMsg('LoadSysUnitsToList Complete.');
{$ENDIF}
    finally
      Screen.Cursor := crDefault;
      HideProgress;
    end;
  end;
end;

procedure TCnUsesToolsWizard.LoadSysUnitsToList(DataList: TStringList);
var
  I, T, H: Integer;
  Info: TCnUnitUsesInfo;
  Decl: TDCURec;
  S, V: string;
  IdentPair: TCnIdentUnitInfo;

  procedure CorrectCase;
  var
    J, Idx: Integer;
    OldPaths, OldNames: TStringList;
  begin
    OldNames := TStringList.Create;
    OldPaths := TStringList.Create;
    FUnitNames.Sort;

    try
      for J := 0 to FUnitNames.Count - 1 do
      begin
        OldPaths.Add(_CnExtractFilePath(FUnitNames[J]));
        FUnitNames[J] := _CnChangeFileExt(_CnExtractFileName(FUnitNames[J]), '');
        OldNames.Add(FUnitNames[J]); // 拆分保留原有的路径与文件名
      end;

      CorrectCaseFromIdeModules(FUnitNames); // 只支持纯文件名，还会给你排好序
      FUnitNames.Sorted := False;

      for J := 0 to FUnitNames.Count - 1 do
      begin
        Idx := OldNames.IndexOf(FUnitNames[J]); // 根据更改后的文件名找到原来对应的路径
        FUnitNames[J] := MakePath(OldPaths[Idx]) + FUnitNames[J] + '.dcu';
      end;
    finally
      OldPaths.Free;
      OldNames.Free;
    end;
  end;

  function ExtractSymbol(const Symbol: string): string;
  const
    THUNK = '$thunk_';
  var
    K, Idx, C, Front, Back: Integer;
    Deled: Boolean;
  begin
    // 不符合规范的 Symbol，返回空字符串，否则从 Symbol 中去除冗余内容
    Result := '';

    // 大体规则：是 initialization 与 finalization 要去掉，是分号数字要去掉，
    // 再从后往前，泛型 <> 里的要去掉，{} 里的要去掉，最后一个点号后的
    if (Symbol = '') or IsInt(Symbol) then
      Exit;

    if (lstrcmpi(PChar(Symbol), 'initialization') = 0) or
      (lstrcmpi(PChar(Symbol), 'finalization') = 0) then
      Exit;

    Result := Symbol;
    if Pos(THUNK, Result) = 1 then     // $thunk_ 这种延迟加载的，去掉该前缀
      Delete(Result, 1, Length(THUNK));

    if Result[1] in [':', '.'] then
      Delete(Result, 1, 1);
    if IsInt(Result) then
    begin
      Result := '';
      Exit;
    end;

    // 简明起见，去掉开头到 } 的部分
    Idx := LastCharPos(Result, '}');
    if Idx > 0 then
      Result := Copy(Result, Idx + 1, MaxInt);

    // 然后从尾部反复扫描泛型 <>，注意可能嵌套并且有多个
    while Pos('<', Result) > 0 do
    begin
      C := 0;
      // Front := 0;
      Back := 0;
      Deled := False;

      for K := Length(Result) downto 1 do
      begin
        if Result[K] = '>' then
        begin
          if C = 0 then
            Back := K;
          Inc(C);
        end
        else if Result[K] = '<' then
        begin
          Dec(C);
          if C = 0 then
          begin
            Front := K;
            if (Back > 0) and (Front > 0) and (Back > Front) then
            begin
              Delete(Result, Front, Back - Front + 1);  // 拿到一个最后面的最外层配对 <> 然后删掉
              Deled := True;
              Break;
            end;
          end;
        end;
      end;

      // Break 到这，如果本次没删说明没的删了
      if not Deled then
        Break;
    end;

    // 没有删的动作，然后删最后一个 < 后的内容，防止出现不配对的情况
    Idx := LastCharPos(Result, '<');
    if Idx > 0 then
      Result := Copy(Result, 1, Idx - 1);

{$IFDEF SUPPORT_GENERIC}
    // 删最后一个 ` 号后的
    Idx := LastCharPos(Result, '`');
    if Idx > 0 then
      Result := Copy(Result, 1, Idx - 1);
{$ENDIF}

    // 最后找最后一个点号后的
    Idx := LastCharPos(Result, '.');
    if Idx > 0 then
      Result := Copy(Result, Idx + 1, MaxInt);

{$IFDEF SUPPORT_CLASS_CONSTRUCTOR}
    if Result = '$ClassInitFlag' then
      Result := '';
{$ENDIF}

    if (Length(Result) >= 1) and (Result[1] = ':') then // 去除 TAClass.:-1 这种
      Delete(Result, 1, 1);
    if IsInt(Result) then
      Result := '';
  end;

begin
  if FUnitNames = nil then
    FUnitNames := TStringList.Create
  else
    FUnitNames.Clear;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Prepare to Call IdeEnumUsesIncludeUnits');
{$ENDIF}

  if IdeEnumUsesIncludeUnits(UsesEnumCallback, False, [mstSystemSearch]) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('After Call IdeEnumUsesIncludeUnits. Get %d', [FUnitNames.Count]);
{$ENDIF}

    // 取到了名字，更正大小写
    if FUnitNames.Count > 0 then
    begin
      CorrectCase;

      // 大小写更正完毕，加入 HashMap
      H := -1;
      for I := 0 to FUnitNames.Count - 1 do
      begin
{$IFDEF DEBUG}
//     CnDebugger.LogMsg(FUnitNames[I]);
{$ENDIF}
        Info := TCnUnitUsesInfo.Create(FUnitNames[I]);

        T := (100 * I) div FUnitNames.Count;
        if T <> H then
        begin
          H := T;
          UpdateProgress(H);
        end;

        try
          if Info.ExportedNames <> nil then
          begin
            for T := 0 to Info.ExportedNames.Count - 1 do
            begin
              Decl := TDCURec(Info.ExportedNames.Objects[T]);
              S := string(Decl.Name^.GetStr);
              if (S <> '') and (Decl.GetSecKind <> skNone) then
              begin
                S := ExtractSymbol(S);
                if S = '' then
                  Continue;

                // 针对 DataList 里的 S 与 FUnitNames[I]，得去重
                if FUnitsMap.Find(S, V) then
                begin
                  if V = FUnitNames[I] then
                  begin
                    Decl := Decl.Next;
                    Continue;
                  end;
                end;
                FUnitsMap.Add(S, FUnitNames[I]);

                IdentPair := TCnIdentUnitInfo.Create;
                IdentPair.Text := S;
                IdentPair.FullNameWithPath := FUnitNames[I];
                IdentPair.ImageIndex := 78; // Units
                DataList.AddObject(S, IdentPair);
              end;
            end
          end
          else
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsgError('Error Parsing: ' + FUnitNames[I]);
{$ENDIF}
          end;
        finally
          Info.Free;
        end;
      end;
      FUnitNames.Clear;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Ident Unit Form DataList Count %d', [DataList.Count]);
{$ENDIF}
    end;
    FreeAndNil(FUnitNames); // 清除掉一点点内存
  end;
end;

procedure TCnUsesToolsWizard.UsesEnumCallback(const AUnitFullName: string;
  Exists: Boolean; FileType: TCnUsesFileType;
  ModuleSearchType: TCnModuleSearchType);
begin
  if FileType = uftPascalDcu then
    FUnitNames.Add(AUnitFullName);
end;

procedure TCnUsesToolsWizard.FromIdentExecute;
var
  Token: TCnIdeTokenString;
  Idx: Integer;
  S: string;
  Ini: TCustomIniFile;
begin
  CheckReLoadUnitsMap;
  S := '';
  if CurrentIsSource and CnOtaGeneralGetCurrPosToken(Token, Idx) then
    S := string(Token);

  with TCnUsesIdentForm.Create(Application, FUnitIdents) do
  begin
    Ini := CreateIniFile;
    try
      LoadSettings(Ini, '');
    finally
      Ini.Free;
    end;

    if S <> '' then
    begin
      edtMatchSearch.Text := S;
      edtMatchSearch.SelStart := Length(S);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Set Text %s to Search, Got Result %d',
        [S, lvList.Items.Count]);
{$ENDIF}

      if lvList.Items.Count = 0 then
      begin
        ErrorDlg(Format(SCNUsesUnitFromIdentErrorFmt, [S]));
        Exit;
      end
    end
    else
      edtMatchSearch.Text := '';

    if ShowModal = mrOk then
    begin
      // uses 动作已在窗体内处理
      BringIdeEditorFormToFront;
    end;

    Ini := CreateIniFile;
    try
      SaveSettings(Ini, '');
    finally
      Ini.Free;
    end;
    Free;
  end;
end;

procedure TCnUsesToolsWizard.ProjImplExecute;
const
  DEF_UNIT = 'CnDebug';
var
  I, C: Integer;
  U: string;
  F: TStringList;

  function ProcessFile(const FileName: string; const AUnit: string): Boolean;
  var
    Stream, Dest: TMemoryStream;
    NameList: TStringList;
    HasUses: Boolean;
    LinearPos: Integer;
    Ins: TCnIdeTokenString;
  begin
    Result := False;
    // 打开单个源文件，解析 intf 和 impl 里是否引用了 AUnit，如无则引用上
    Stream := nil;
    Dest := nil;
    NameList := nil;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('UsesTools Project uses ProcessFile %s', [FileName]);
{$ENDIF}

    try
      Stream := TMemoryStream.Create;
      CnGeneralFilerSaveFileToStream(FileName, Stream); // Stream 得到 Ansi/*/Utf16

      NameList := TStringList.Create;
{$IFDEF UNICODE}
      ParseUnitUsesW(PChar(Stream.Memory), NameList);
{$ELSE}
      ParseUnitUses(PAnsiChar(Stream.Memory), NameList);
{$ENDIF}

      if NameList.IndexOf(AUnit) >= 0 then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('UsesTools Project File Already uses %s', [AUnit]);
{$ENDIF}
        Exit;
      end;

      // 要加上 uses，先查找插入位置
      if SearchUsesInsertPosInPasFile(FileName, False, HasUses, LinearPos) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('UsesTools Project File Search Uses. Impl Has uses %d. Can Insert to %d', [Ord(HasUses), LinearPos]);
{$ENDIF}

        // 根据 HasUses 和 Linear 位置拼凑内容插入
        NameList.Clear;
        NameList.Add(AUnit);

        Ins := TCnIdeTokenString(JoinUsesOrInclude(False, HasUses, False, NameList));

{$IFDEF DEBUG}
        CnDebugger.LogFmt('UsesTools Project File Insert Content %s', [Ins]);
{$ENDIF}

        Dest := TMemoryStream.Create;
        Stream.Position := 0;
        Dest.CopyFrom(Stream, LinearPos * SizeOf(TCnIdeTokenChar));
        Dest.Write(Ins[1], Length(Ins) * SizeOf(TCnIdeTokenChar));
        Dest.CopyFrom(Stream, Stream.Size - (LinearPos + 1) * SizeOf(TCnIdeTokenChar));

        CnGeneralFilerLoadFileFromStream(FileName, Dest);
        Result := True;
      end;
    finally
      Dest.Free;
      Stream.Free;
      NameList.Free;
    end;
  end;

begin
  // 拿到单元名，在工程内的非 dpr 文件里，全盘判断并 impl 部分加入 uses
  if FProjImplUnit = '' then
    FProjImplUnit := DEF_UNIT;

  U := FProjImplUnit;
  if CnWizInputQuery(SCnInformation, SCnUsesToolsProjImplPrompt, U) then
  begin
    // 判断 U 是否合法，不合法则退出
    if not IsValidUnitName(U) then
    begin
      ErrorDlg(SCnUsesToolsProjImplErrorUnit);
      Exit;
    end;

    FProjImplUnit := U;
    F := TStringList.Create;
    try
      if not CnOtaGetProjectSourceFiles(F, False) then
      begin
        ErrorDlg(SCnUsesToolsProjImplErrorSource);
        Exit;
      end;

      C := 0;
      for I := 0 to F.Count - 1 do
      begin
        if ProcessFile(F[I], FProjImplUnit) then
          Inc(C);
      end;

      InfoDlg(Format(SCnUsesToolsProjImplCountFmt, [C]));
    finally
      F.Free;
    end;
  end;
end;

{ TCnUsesCleanerForm }

function TCnUsesCleanerForm.GetHelpTopic: string;
begin
  Result := 'CnUsesUnitsTools';
end;

procedure TCnUsesCleanerForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnUsesCleanerForm.rbCurrUnitClick(Sender: TObject);
begin
  chkProcessDependencies.Enabled := not rbCurrUnit.Checked;
end;

function TCnUsesToolsWizard.IsValidUnitName(const AUnitName: string): Boolean;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9', '.'];
var
  I: Integer;
begin
  Result := False;
{$IFDEF UNICODE} // Unicode Identifier Supports
  if (Length(AUnitName) = 0) or not (CharInSet(AUnitName[1], Alpha) or (Ord(AUnitName[1]) > 127)) then
    Exit;
  for I := 2 to Length(AUnitName) do
  begin
    if not (CharInSet(AUnitName[I], AlphaNumeric) or (Ord(AUnitName[I]) > 127)) then
      Exit;
  end;
{$ELSE}
  if (Length(AUnitName) = 0) or not CharInSet(AUnitName[1], Alpha) then
    Exit;
  for I := 2 to Length(AUnitName) do
  begin
    if not CharInSet(AUnitName[I], AlphaNumeric) then
      Exit;
  end;
{$ENDIF}
  Result := True;
end;

initialization
  RegisterCnWizard(TCnUsesToolsWizard); // 注册专家

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.
