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
* 单元标识：$Id: CnUsesCleaner.pas,v 1.36 2009/02/15 09:28:22 liuxiao Exp $
* 修改记录：2005.08.11 V1.0
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
  CnWizOptions, mPasLex, Math, TypInfo;

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
    procedure btnHelpClick(Sender: TObject);
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
    FIgnoreList: TStringList;
    FCleanList: TStringList;
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
  csDcuExt = '.dcu';

{ TCnUsesCleaner }

constructor TCnUsesCleaner.Create;
begin
  inherited;
  FIgnoreInit := True;
  FIgnoreReg := True;
  FIgnoreNoSrc := False;
  FIgnoreCompRef := True;
  FIgnoreList := TStringList.Create;
  FCleanList := TStringList.Create;
end;

destructor TCnUsesCleaner.Destroy;
begin
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
begin
  Result := False;
  try
    case AKind of
      ukCurrUnit:
        begin
          Module := CnOtaGetCurrentModule;
          Assert(Assigned(Module) and (Module.OwnerCount > 0));
          Project := GetProjectFromModule(Module);
          Result := DoCompileProject(Project);
        end;
      ukCurrProject:
        begin
          Project := CnOtaGetCurrentProject;
          Assert(Assigned(Project));
          Result := DoCompileProject(Project);
        end;
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
          if SameFileName(TCnEmptyUsesInfo(Units[i]).Buffer.Module.FileName,
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
      Result := ReplaceToActualPath(AProject.ProjectOptions.Values['UnitOutputDir']);
      if Result <> '' then
        Result := MakePath(LinkPath(ExtractFilePath(AProject.FileName), Result));
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('GetProjectDcuPath: ' + Result);
    {$ENDIF}
    end
    else
      Result := '';    
  end;

  function GetDcuName(const ADcuPath: string; AModule: IOTAModule): string;
  begin
    if ADcuPath = '' then
      Result := ChangeFileExt(Module.FileName, csDcuExt)
    else
      Result := ChangeFileExt(ADcuPath + ExtractFileName(Module.FileName), csDcuExt);
  end;

  function ProcessAUnit(const ADcuName: string; AModule: IOTAModule;
    AProject: IOTAProject; var AInfo: TCnEmptyUsesInfo): Boolean;
  var
    Editor: IOTASourceEditor;
  begin
    AInfo := nil;
    Result := False;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('UsesCleaner ProcessAUnit: ' + ADcuName);
  {$ENDIF}
    if FileExists(ADcuName) then
    begin
      Editor := CnOtaGetSourceEditorFromModule(AModule);
      Assert(Assigned(Editor));
      AInfo := TCnEmptyUsesInfo.Create(ADcuName, Editor as IOTAEditBuffer,
        AProject);
      Result := AInfo.Process;
      if not Result then
      begin
        FreeAndNil(AInfo);
      end;
    end;
  end;

  function ProcessAProject(AProject: IOTAProject; OpenedOnly: Boolean): Boolean;
  var
    i: Integer;
    ModuleInfo: IOTAModuleInfo;
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

        if OpenedOnly and not CnOtaIsFileOpen(ModuleInfo.FileName) then
          Continue;

        Module := ModuleInfo.OpenModule;
        if not Assigned(Module) then
          Continue;

        DcuName := GetDcuName(DcuPath, Module);
        if ProcessAUnit(DcuName, Module, Project, UsesInfo) then
        begin
          if (UsesInfo.IntfCount > 0) or (UsesInfo.ImplCount > 0) then
            ProjectInfo.Units.Add(UsesInfo)
          else
            FreeAndNil(UsesInfo);
        end
        else if not QueryDlg(Format(SCnUsesCleanerProcessError,
          [ExtractFileName(Module.FileName)])) then
        begin
          Exit;
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
          DcuName := GetDcuName(DcuPath, Module);
          Result := ProcessAUnit(DcuName, Module, Project, UsesInfo);
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
            ErrorDlg(Format(SCnUsesCleanerUnitError, [ExtractFileName(Module.FileName)]))
        end;
      ukCurrProject:
        begin
          Project := CnOtaGetCurrentProject;
          Assert(Assigned(Project));
          Result := ProcessAProject(Project, False);
        end;
    else
      begin
        ProjectGroup := CnOtaGetProjectGroup;
        Assert(Assigned(ProjectGroup));
        for i := 0 to ProjectGroup.ProjectCount - 1 do
        begin
          Project := ProjectGroup.GetProject(i);
          Result := ProcessAProject(Project, AKind = ukOpenedUnits);
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

        if (Lex.TokenID = tkIdentifier) and (Token = tkInitialization) then
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
      if (TypeData <> nil) and (Units.IndexOf({$IFDEF DELPHI2009_UP}string{$ENDIF}(TypeData^.UnitName)) < 0) then
        Units.Add({$IFDEF DELPHI2009_UP}string{$ENDIF}(TypeData^.UnitName));
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
                    UnitName := ChangeFileExt(ExtractFileName(
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
      if FCleanList.IndexOf(UnitList[u]) >= 0 then
        Include(Kinds, ukInCleanList);
      if FIgnoreList.IndexOf(UnitList[u]) >= 0 then
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
          GetCompRefUnits(Buffer.Module, Project, CompRef);
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

  // 以下代码参考了 GExperts 的 GX_UsesManager 单元
  function GetUsesSource(List: TStrings): AnsiString;
  var
    UsesList: TObjectList;
    Item: TPrvUsesItem;
    LastCommaPos: Integer;
    CPos, BegPos, EndPos: Integer;
    i: Integer;
  begin
    Result := '';
    CPos := Lex.TokenPos;
    UsesList := TObjectList.Create;
    try
      Item := nil;
      LastCommaPos := 0;
      while not (Lex.TokenID in [tkNull, tkSemiColon]) do
      begin
        if Lex.TokenID = tkIdentifier then
        begin
          Item := TPrvUsesItem.Create;
          Item.Name := Lex.Token;
          Item.BeginPos := Lex.TokenPos;
          Item.EndPos := Lex.RunPos;
          if LastCommaPos <> 0 then
            Item.CommaBeforePos := LastCommaPos - 1;
          Item.CommaAfterPos := 0;
          UsesList.Add(Item);
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

      if Lex.TokenID <> tkNull then
        Lex.Next;
      SetLength(Result, Lex.TokenPos - CPos);
      CopyMemory(Pointer(Result), Pointer(Integer(Lex.Origin) + CPos), Lex.TokenPos - CPos);

      for i := UsesList.Count - 1 downto 0 do
      begin
        Item := TPrvUsesItem(UsesList[i]);
        if List.IndexOf(Item.Name) >= 0 then
        begin
          if i = 0 then // First in the uses clause
          begin
            if Item.CommaAfterPos <> 0 then
              EndPos := Item.CommaAfterPos + 1
            else
              EndPos := Item.EndPos;
            BegPos := Item.BeginPos;
          end
          else if i = UsesList.Count - 1 then // Last in the uses clause
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

          Delete(Result, BegPos - CPos + 1, EndPos - BegPos);
          UsesList.Delete(i);
        end;
      end;
      
      if UsesList.Count = 0 then
        Result := '';
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
        Source := string(GetUsesSource(Intf));
        Writer.DeleteTo(Lex.TokenPos);
        if Source <> '' then
        begin
          Writer.Insert(PAnsiChar(ConvertTextToEditorText({$IFDEF DELPHI2009_UP}AnsiString{$ENDIF}(Source))));
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
          Source := string(GetUsesSource(Impl));
          Writer.DeleteTo(Lex.TokenPos);
          if Source <> '' then
          begin
            Writer.Insert(PAnsiChar(ConvertTextToEditorText({$IFDEF DELPHI2009_UP}AnsiString{$ENDIF}(Source))));
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
var
  Intf, Impl, Logs: TStringList;
  i, j, k: Integer;
  UCnt, Cnt: Integer;
  FileName: string;
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
      for j := 0 to TCnProjectUsesInfo(List[i]).Units.Count - 1 do
        with TCnEmptyUsesInfo(TCnProjectUsesInfo(List[i]).Units[j]) do
        begin
          Intf.Clear;        
          Impl.Clear;
          for k := 0 to IntfCount - 1 do
            if IntfItems[k].Checked then
              Intf.Add(IntfItems[k].Name);
          for k := 0 to ImplCount - 1 do
            if ImplItems[k].Checked then
              Impl.Add(ImplItems[k].Name);
              
          if (Intf.Count > 0) or (Impl.Count > 0) then
          begin
            if DoCleanUnit(Buffer, Intf, Impl) then
            begin
              Inc(UCnt);
              Inc(Cnt, Intf.Count + Impl.Count);
              Logs.Add(Buffer.FileName);
              if Intf.Count > 0 then
                Logs.Add('  Interface Uses: ' + Intf.CommaText);
              if Impl.Count > 0 then
                Logs.Add('  Implementation Uses: ' + Impl.CommaText);
            end
            else if not QueryDlg(Format(SCnUsesCleanerProcessError,
              [ExtractFileName(Buffer.FileName)])) then
              Exit;
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

{ TCnUsesCleanerForm }

function TCnUsesCleanerForm.GetHelpTopic: string;
begin
  Result := 'CnUsesCleaner';
end;

procedure TCnUsesCleanerForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

initialization
  RegisterCnWizard(TCnUsesCleaner); // 注册专家

{$ENDIF CNWIZARDS_CNUSESCLEANER}
end.
