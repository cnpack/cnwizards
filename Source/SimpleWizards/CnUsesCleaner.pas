{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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

unit CnUsesCleaner;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：引用单元清理工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2011.11.05 V1.1
*               完善对XE2风格的带点的单元名的支持
*           2005.08.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESCLEANER}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolsAPI, IniFiles, Contnrs, CnWizMultiLang, CnWizClasses, CnWizConsts,
  CnCommon, CnConsts, CnWizUtils, CnDCU32, CnWizIdeUtils, CnWizEditFiler,
  CnWizOptions, mPasLex, Math, TypInfo, RegExpr, ActnList
  {$IFDEF DELPHIXE3_UP}
  , System.Actions
  {$ENDIF}
  ;

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
    procedure btnHelpClick(Sender: TObject);
    procedure rbCurrUnitClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

{ TCnUsesCleaner }

  TCnUsesCleanKind = (ukCurrUnit, ukOpenedUnits, ukCurrProject, ukProjectGroup);

  TCnUsesCleaner = class(TCnMenuWizard)
  private
    FIgnoreInit: Boolean;
    FIgnoreReg: Boolean;
    FIgnoreNoSrc: Boolean;
    FIgnoreCompRef: Boolean;
    FProcessDependencies: Boolean;
    FUseBuildAction: Boolean;  // 是否使用 IDE 的 Build 菜单项点击来编译而不是使用 OTA 接口
    FIgnoreList: TStringList;
    FCleanList: TStringList;
    FRegExpr: TRegExpr;
    function MatchInListWithExpr(List: TStrings; const Str: string): Boolean;
    function GetProjectFromModule(AModule: IOTAModule): IOTAProject;
    function ShowKindForm(var AKind: TCnUsesCleanKind): Boolean;
    function CompileUnits(AKind: TCnUsesCleanKind): Boolean;
    function ProcessUnits(AKind: TCnUsesCleanKind; List: TObjectList): Boolean;
    procedure ParseUnitKind(const FileName: string; var Kinds: TCnUsesKinds);
    procedure GetCompRefUnits(AModule: IOTAModule; AProject: IOTAProject; Units:
      TStrings);
    procedure CheckUnits(List: TObjectList);
    function DoCleanUnit(Buffer: IOTAEditBuffer; Intf, Impl: TStrings): Boolean;
    procedure CleanUnitUses(List: TObjectList);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNUSESCLEANER}

implementation

{$IFDEF CNWIZARDS_CNUSESCLEANER}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnUsesCleanResultFrm;

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
  csDcuExt = '.dcu';

  csProjectBuildCommand = 'ProjectBuildCommand';
  csProjectBuildAllCommand = 'ProjectBuildAllCommand';

{ TCnUsesCleaner }

constructor TCnUsesCleaner.Create;
begin
  inherited;
  FIgnoreInit := True;
  FIgnoreReg := True;
  FIgnoreNoSrc := False;
  FIgnoreCompRef := True;
  FProcessDependencies := False;
  FUseBuildAction := False; // 默认使用 OTA 接口，True 时未完整测试，选项不对外开放
  FIgnoreList := TStringList.Create;
  FCleanList := TStringList.Create;

  FRegExpr := TRegExpr.Create;
  FRegExpr.ModifierI := True;
end;

destructor TCnUsesCleaner.Destroy;
begin
  FRegExpr.Free;
  FCleanList.Free;
  FIgnoreList.Free;
  inherited;
end;

procedure TCnUsesCleaner.Execute;
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
        if ShowUsesCleanResultForm(List) then
        begin
          CleanUnitUses(List);
        end;
      end;
    finally
      List.Free;
    end;   
  end;
end;

function TCnUsesCleaner.ShowKindForm(var AKind: TCnUsesCleanKind): Boolean;
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

function TCnUsesCleaner.GetProjectFromModule(AModule: IOTAModule): IOTAProject;
var
  i: Integer;
begin
  Result := AModule.GetOwner(0);
  for i := 1 to AModule.OwnerCount - 1 do
    if AModule.GetOwner(i) = CnOtaGetCurrentProject then
    begin
      Result := AModule.GetOwner(i);
      Break;
    end;
end;

function TCnUsesCleaner.CompileUnits(AKind: TCnUsesCleanKind): Boolean;
var
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  i: Integer;

  function DoCompileProject(AProject: IOTAProject): Boolean;
  begin
    Result := not AProject.ProjectBuilder.ShouldBuild or
      AProject.ProjectBuilder.BuildProject(cmOTAMake, False);
  end;

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
            Result := DoCompileProject(Project);
          end;
        end;
      ukCurrProject:
        begin
          Project := CnOtaGetCurrentProject;
          Assert(Assigned(Project));
          if FUseBuildAction then
            Result := DoBuildProjectAction
          else
            Result := DoCompileProject(Project);
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
          for i := 0 to ProjectGroup.ProjectCount - 1 do
          begin
            Result := DoCompileProject(ProjectGroup.Projects[i]);
            if not Result then
              Break;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

function TCnUsesCleaner.ProcessUnits(AKind: TCnUsesCleanKind;
  List: TObjectList): Boolean;
var
  Module: IOTAModule;
  Project: IOTAProject;
  ProjectGroup: IOTAProjectGroup;
  DcuPath: string;
  DcuName: string;
  ProjectInfo: TCnProjectUsesInfo;
  UsesInfo: TCnEmptyUsesInfo;
  i: Integer;

  function ModuleExists(const FileName: string): Boolean;
  var
    i, j: Integer;
  begin
    for i := 0 to List.Count - 1 do
      with TCnProjectUsesInfo(List[i]) do
        for j := 0 to Units.Count - 1 do
          if SameFileName(TCnEmptyUsesInfo(Units[i]).SourceFileName,
            FileName) then
          begin
            Result := True;
            Exit;
          end;
    Result := False;
  end;

  function GetProjectDcuPath(AProject: IOTAProject): string;
  begin
    if (AProject <> nil) and (AProject.ProjectOptions <> nil) then
    begin
      Result := ReplaceToActualPath(AProject.ProjectOptions.Values['UnitOutputDir'], AProject);
      if Result <> '' then
        Result := MakePath(LinkPath(_CnExtractFilePath(AProject.FileName), Result));
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
    {$ENDIF}
    end
    else
      Result := '';    
  end;

  function GetDcuName(const ADcuPath, ASourceFileName: string): string;
  begin
    if ADcuPath = '' then
      Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
    else
      Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
  end;

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
      i: Integer;
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
        for i := 0 to UnitUsesInfo.IntfUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.IntfUses[i]);
          if not Result then
            Exit;
        end;

        for i := 0 to UnitUsesInfo.ImplUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.ImplUses[i]);
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
      i: Integer;
    begin
      UnitUsesInfo := TCnUnitUsesInfo.Create(ADcuName);
      try
        for i := 0 to UnitUsesInfo.IntfUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.IntfUses[i]);
          if not Result then
            Exit;
        end;

        for i := 0 to UnitUsesInfo.ImplUsesCount - 1 do
        begin
          Result := RecursiveProcessUnit(UnitUsesInfo.ImplUses[i]);
          if not Result then
            Exit;
        end;
      finally
        FreeAndNil(UnitUsesInfo);
      end;
      Result := True;
    end;
  var
    i: Integer;
    ModuleInfo: IOTAModuleInfo;
    Opened: Boolean;
  begin
    Result := False;
    DcuPath := GetProjectDcuPath(Project);
    ProjectInfo := TCnProjectUsesInfo.Create;
    ProjectInfo.Project := AProject;
    try
      for i := 0 to AProject.GetModuleCount - 1 do
      begin
        ModuleInfo := AProject.GetModule(i);
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
          for i := 0 to AProject.GetModuleCount - 1 do
          begin
            ModuleInfo := AProject.GetModule(i);
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
        for i := 0 to ProjectGroup.ProjectCount - 1 do
        begin
          Project := ProjectGroup.GetProject(i);
          Result := ProcessAProject(Project, AKind = ukOpenedUnits, FProcessDependencies);
          if not Result then
            Break;
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

procedure TCnUsesCleaner.ParseUnitKind(const FileName: string;
  var Kinds: TCnUsesKinds);
var
  Stream: TMemoryStream;
  Lex: TmwPasLex;
  Token: TTokenKind;
  RegDecl: Boolean;
begin
  Stream := TMemoryStream.Create;
  try
    EditFilerSaveFileToStream(FileName, Stream);
    Lex := TmwPasLex.Create;
    try
      Lex.Origin := PAnsiChar(Stream.Memory);
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

procedure TCnUsesCleaner.GetCompRefUnits(AModule: IOTAModule; AProject:
  IOTAProject; Units: TStrings);
var
  FormEditor: IOTAFormEditor;
  Root: TComponent;
  i: Integer;

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
    Count, i, j: Integer;
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
        for i := 0 to Count - 1 do
        begin
          Obj := TObject(GetOrdProp(AObj, PropList[I]));
          if Obj <> nil then
          begin
            if Obj is TComponent then
            begin
              if (TComponent(Obj).Owner <> nil) and (TComponent(Obj).Owner <> Root) then
              begin
                FormName := TComponent(Obj).Owner.Name;
                for j := 0 to AProject.GetModuleCount - 1 do
                  if SameText(AProject.GetModule(j).FormName, FormName) then
                  begin
                    UnitName := _CnChangeFileExt(_CnExtractFileName(
                      AProject.GetModule(j).FileName), '');
                    if Units.IndexOf(UnitName) < 0 then
                      Units.Add(UnitName);
                  end;
              end;
            end
            else if Obj is TCollection then
            begin
              for j := 0 to TCollection(Obj).Count - 1 do
                DoAddPropRef(TCollection(Obj).Items[j]);
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
        for i := 0 to Root.ComponentCount - 1 do
        begin
          DoAddCompRef(Root.Components[i].ClassType);
          DoAddPropRef(Root.Components[i]);
        end;
      end;
    end;
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;   
end;

procedure TCnUsesCleaner.CheckUnits(List: TObjectList);
var
  UnitList, CompRef: TStringList;
  i, j, k, u: Integer;
  FileName: string;
  Kinds: TCnUsesKinds;
  Checked: Boolean;
begin
  // 分析公共的单元
  UnitList := TStringList.Create;
  try
    // 取得所有引用到的单元
    UnitList.Sorted := True;
    for i := 0 to List.Count - 1 do
      for j := 0 to TCnProjectUsesInfo(List[i]).Units.Count - 1 do
        with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[i]).Units[j]) do
        begin
          for k := 0 to IntfCount - 1 do
            if UnitList.IndexOf(IntfItems[k].Name) < 0 then
              UnitList.AddObject(IntfItems[k].Name, TObject(Pointer(Project)));
          for k := 0 to ImplCount - 1 do
            if UnitList.IndexOf(ImplItems[k].Name) < 0 then
              UnitList.AddObject(ImplItems[k].Name, TObject(Pointer(Project)));
        end;

    // 分析单元类型
    for u := 0 to UnitList.Count - 1 do
    begin
      Kinds := [];

      if MatchInListWithExpr(FCleanList, UnitList[u]) then
        Include(Kinds, ukInCleanList);
      if MatchInListWithExpr(FIgnoreList, UnitList[u]) then
        Include(Kinds, ukInIgnoreList);

      FileName := GetFileNameFromModuleName(UnitList[u],
        IOTAProject(Pointer(UnitList.Objects[u])));
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Check Unit ' + UnitList[u] + ': ' + FileName);
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

      for i := 0 to List.Count - 1 do
        for j := 0 to TCnProjectUsesInfo(List[i]).Units.Count - 1 do
          with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[i]).Units[j]) do
          begin
            for k := 0 to IntfCount - 1 do
              if SameText(UnitList[u], IntfItems[k].Name) then
              begin
                IntfItems[k].Kinds := Kinds;
                IntfItems[k].Checked := Checked;
              end;
            for k := 0 to ImplCount - 1 do
              if SameText(UnitList[u], ImplItems[k].Name) then
              begin
                ImplItems[k].Kinds := Kinds;
                ImplItems[k].Checked := Checked;
              end;
          end;
    end;

  finally
    UnitList.Free;
  end;

  // 分析每个单元的组件引用单元
  CompRef := TStringList.Create;
  try
    for i := 0 to List.Count - 1 do
      for j := 0 to TCnProjectUsesInfo(List[i]).Units.Count - 1 do
        with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[i]).Units[j]) do
        begin
          CompRef.Clear;
          GetCompRefUnits(CnOtaGetModule(SourceFileName), Project, CompRef);
          if CompRef.Count > 0 then
          begin
            for k := 0 to IntfCount - 1 do
              if CompRef.IndexOf(IntfItems[k].Name) >= 0 then
              begin
                IntfItems[k].Kinds := IntfItems[k].Kinds + [tkCompRef];
                if FIgnoreCompRef and not (ukInCleanList in IntfItems[k].Kinds) then
                  IntfItems[k].Checked := False;
              end;
            for k := 0 to ImplCount - 1 do
              if CompRef.IndexOf(ImplItems[k].Name) >= 0 then
              begin
                ImplItems[k].Kinds := ImplItems[k].Kinds + [tkCompRef];
                if FIgnoreCompRef and not (ukInCleanList in ImplItems[k].Kinds) then
                  ImplItems[k].Checked := False;
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

function TCnUsesCleaner.DoCleanUnit(Buffer: IOTAEditBuffer; Intf, Impl:
  TStrings): Boolean;
var
  SrcStream: TMemoryStream;
  Writer: IOTAEditWriter;
  Lex: TmwPasLex;
  Source: string;

  // 以下代码部分参考了 GExperts 的 GX_UsesManager 单元
  // liuxiao 加入对带点号文件名的支持
  function GetUsesSource(List: TStrings): AnsiString;
  var
    UsesList: TObjectList;
    Item: TPrvUsesItem;
    LastCommaPos: Integer;
    CPos, BegPos, EndPos: Integer;
    I, UnitStartPos, UnitEndPos: Integer;
    S: string;
  begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('GetUsesSource List: %s.', [List.Text]);
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
        UsesList.Add(Item);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('GetUsesSource UsesList Add Last: %s.', [Item.Name]);
{$ENDIF}
      end;

{$IFDEF DEBUG}
      CnDebugger.LogFmt('GetUsesSource UsesList Count: %d. List Count %d.',
        [UsesList.Count, List.Count]);
{$ENDIF}
      if Lex.TokenID <> tkNull then
        Lex.Next;
      SetLength(Result, Lex.TokenPos - CPos);
      CopyMemory(Pointer(Result), Pointer(Integer(Lex.Origin) + CPos), Lex.TokenPos - CPos);

{$IFDEF DEBUG}
//    CnDebugger.LogFmt('GetUsesSource First Copy Result %s.', [Result]);
{$ENDIF}
      for I := UsesList.Count - 1 downto 0 do
      begin
        Item := TPrvUsesItem(UsesList[I]);
        if List.IndexOf(Item.Name) >= 0 then
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
      CnDebugger.LogMsg('GetUsesSource Return: ' + string(Result));
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
      EditFilerSaveFileToStream(Buffer.FileName, SrcStream);
      // CnOtaSaveEditorToStream(Buffer, SrcStream, False, False);
      Lex := TmwPasLex.Create;
      Lex.Origin := PAnsiChar(SrcStream.Memory);

      Writer := Buffer.CreateUndoableWriter;
      
      while not (Lex.TokenID in [tkImplementation, tkUses, tkNull]) do
        Lex.NextNoJunk;

      if (Intf.Count > 0) and (Lex.TokenID = tkUses) then
      begin
        Writer.CopyTo(Lex.TokenPos);
        Source := string(ConvertEditorTextToText(GetUsesSource(Intf)));
        Writer.DeleteTo(Lex.TokenPos);
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
      Writer.CopyTo(Lex.TokenPos);

      if Impl.Count > 0 then
      begin
        while not (Lex.TokenID in [tkUses, tkNull]) do
          Lex.NextNoJunk;

        if Lex.TokenID = tkUses then
        begin
          Writer.CopyTo(Lex.TokenPos);
          Source := string(ConvertEditorTextToText(GetUsesSource(Impl)));
          Writer.DeleteTo(Lex.TokenPos);
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

procedure TCnUsesCleaner.CleanUnitUses(List: TObjectList);

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
  i, j, k: Integer;
  UCnt, Cnt: Integer;
  FileName: string;
  Buffer: IOTAEditBuffer;
  UsesInfo: TCnEmptyUsesInfo;
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
    for i := 0 to List.Count - 1 do
    begin
      for j := 0 to TCnProjectUsesInfo(List[i]).Units.Count - 1 do
      begin
        UsesInfo := TCnEmptyUsesInfo(TCnProjectUsesInfo(List[i]).Units[j]);
        Intf.Clear;
        Impl.Clear;
        for k := 0 to UsesInfo.IntfCount - 1 do
          if UsesInfo.IntfItems[k].Checked then
            Intf.Add(UsesInfo.IntfItems[k].Name);
        for k := 0 to UsesInfo.ImplCount - 1 do
          if UsesInfo.ImplItems[k].Checked then
            Impl.Add(UsesInfo.ImplItems[k].Name);

        if (Intf.Count > 0) or (Impl.Count > 0) then
        begin
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
    end;
    Logs.Free;
  end;
end;

procedure TCnUsesCleaner.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FIgnoreInit := Ini.ReadBool('', csIgnoreInit, FIgnoreInit);
  FIgnoreReg := Ini.ReadBool('', csIgnoreReg, FIgnoreReg);
  FIgnoreNoSrc := Ini.ReadBool('', csIgnoreNoSrc, FIgnoreNoSrc);
  FIgnoreCompRef := Ini.ReadBool('', csIgnoreCompRef, FIgnoreCompRef);
  FProcessDependencies := Ini.ReadBool('', csProcessDependencies, FProcessDependencies);
  FUseBuildAction := Ini.ReadBool('', csUseBuildAction, FUseBuildAction);
  WizOptions.LoadUserFile(FIgnoreList, csIgnoreList);
  WizOptions.LoadUserFile(FCleanList, csCleanList);
end;

procedure TCnUsesCleaner.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteBool('', csIgnoreInit, FIgnoreInit);
  Ini.WriteBool('', csIgnoreReg, FIgnoreReg);
  Ini.WriteBool('', csIgnoreNoSrc, FIgnoreNoSrc);
  Ini.WriteBool('', csIgnoreCompRef, FIgnoreCompRef);
  Ini.WriteBool('', csProcessDependencies, FProcessDependencies);
  Ini.WriteBool('', csUseBuildAction, FUseBuildAction);
  WizOptions.SaveUserFile(FIgnoreList, csIgnoreList);
  WizOptions.SaveUserFile(FCleanList, csCleanList);
end;

function TCnUsesCleaner.GetCaption: string;
begin
  Result := SCnUsesCleanerMenuCaption;
end;

function TCnUsesCleaner.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnUsesCleaner.GetHint: string;
begin
  Result := SCnUsesCleanerMenuHint;
end;

function TCnUsesCleaner.GetState: TWizardState;
begin
  if CnOtaGetProjectGroup <> nil then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnUsesCleaner.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnUsesCleanerName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnUsesCleanerComment;
end;

function TCnUsesCleaner.MatchInListWithExpr(List: TStrings;
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

{ TCnUsesCleanerForm }

function TCnUsesCleanerForm.GetHelpTopic: string;
begin
  Result := 'CnUsesCleaner';
end;

procedure TCnUsesCleanerForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnUsesCleanerForm.rbCurrUnitClick(Sender: TObject);
begin
  chkProcessDependencies.Enabled := not rbCurrUnit.Checked;
end;

initialization
  RegisterCnWizard(TCnUsesCleaner); // 注册专家

{$ENDIF CNWIZARDS_CNUSESCLEANER}
end.
