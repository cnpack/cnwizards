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

unit CnTestUsesToolsWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestUsesInitTreeWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2021.08.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnPasCodeParser, CnWizEditFiler, CnTree, CnCommon, CnUsesInitTreeFrm, CnHashMap;

type

//==============================================================================
// CnTestUsesToolsWizard 菜单专家
//==============================================================================

{ TCnTestUsesToolsWizard }

  TCnTestUsesToolsWizard = class(TCnSubMenuWizard)
  private
    FTreeId: Integer;
    FEnumId: Integer;
    FUnits: TStringList;
    FSysDcus: TStringList;
    FUnitsMap: TCnStrToStrHashMap;
    FTree: TCnTree;
    FFileNames, FLibPaths: TStringList;
    FDcuPath: string;
    procedure SearchAUnit(const AFullDcuName, AFullSourceName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
    {* 递归调用，分析并查找 AUnitName 对应源码的 Uses 列表并加入到树中的 UnitLeaf 的子节点中}
    procedure UsesCallback(const AUnitFullName: string; Exists: Boolean;
      FileType: TCnUsesFileType; ModuleSearchType: TCnModuleSearchType);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure InitTreeExecute;
    procedure EnumExecute;
    procedure AcquireSubActions; override;
  end;

implementation

uses
  CnDebug, CnDCU32, DCURecs;

const
  csDcuExt = '.dcu';

type
  TCnUsesLeaf = class(TCnLeaf)
  private
    FIsImpl: Boolean;
    FDcuName: string;
    FSearchType: TCnModuleSearchType;
  public
    property DcuName: string read FDcuName write FDcuName;
    property SearchType: TCnModuleSearchType read FSearchType write FSearchType;
    property IsImpl: Boolean read FIsImpl write FIsImpl;
  end;

function GetDcuName(const ADcuPath, ASourceFileName: string): string;
begin
  if ADcuPath = '' then
    Result := _CnChangeFileExt(ASourceFileName, csDcuExt)
  else
    Result := _CnChangeFileExt(ADcuPath + _CnExtractFileName(ASourceFileName), csDcuExt);
end;

//==============================================================================
// CnTestUsesToolsWizard 子菜单专家
//==============================================================================

{ TCnTestUsesToolsWizard }

procedure TCnTestUsesToolsWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestUsesToolsWizard.Create;
begin
  inherited;
  FFileNames := TStringList.Create;
  FLibPaths := TStringList.Create;
  FTree := TCnTree.Create(TCnUsesLeaf);
end;

destructor TCnTestUsesToolsWizard.Destroy;
begin
  FTree.Free;
  FLibPaths.Free;
  FFileNames.Free;
  inherited;
end;

procedure TCnTestUsesToolsWizard.InitTreeExecute;
var
  Proj: IOTAProject;
  I: Integer;
  ProjDcu, S: string;
begin
  with TCnUsesInitTreeForm.Create(Application) do
  begin
    ShowModal;
    Free;
    Exit;
  end;

  Proj := CnOtaGetCurrentProject;
  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  FTree.Clear;
  FFileNames.Clear;
  FDcuPath := GetProjectDcuPath(Proj);
  GetLibraryPath(FLibPaths, False);

  CnDebugger.Active := False;
  FTree.Root.Text := CnOtaGetProjectSourceFileName(Proj);
  ProjDcu := GetDcuName(FDcuPath, FTree.Root.Text);

  SearchAUnit(ProjDcu, FTree.Root.Text, FFileNames, FTree.Root, FTree, Proj);
  CnDebugger.Active := True;

  // 打印出树内容
  for I := 0 to FTree.Count - 1 do
  begin
    S := StringOfChar('-', FTree.Items[I].Level) + FTree.Items[I].Text;

    case (FTree.Items[I] as TCnUsesLeaf).SearchType of
      mstInProject: S := S + ' | (In Project)';
      mstProjectSearch: S := S + ' | (In Project Search Path)';
      mstSystemSearch: S := S + ' | (In System Path)';
    end;

    if (FTree.Items[I] as TCnUsesLeaf).IsImpl then
      S := S + ' | impl';

    CnDebugger.LogMsg(S);
  end;
end;

function TCnTestUsesToolsWizard.GetCaption: string;
begin
  Result := 'Test Uses Tools';
end;

function TCnTestUsesToolsWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestUsesToolsWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestUsesToolsWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestUsesToolsWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestUsesToolsWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Uses Tools Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestUsesToolsWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesToolsWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesToolsWizard.SearchAUnit(const AFullDcuName, AFullSourceName: string;
  ProcessedFiles: TStrings; UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  ASourceFileName, ADcuFileName: string;
  UsesList: TStringList;
  I, J: Integer;
  Leaf: TCnLeaf;
  Info: TCnUnitUsesInfo;
begin
  // 分析 DCU 或源码得到 intf 与 impl 的引用列表，并加入至 UnitLeaf 的直属子节点
  // 递归调用该方法，处理每个引用列表中的引用单元名
  if  not FileExists(AFullDcuName) and not FileExists(AFullSourceName) then
    Exit;

  UsesList := TStringList.Create;
  try
    if FileExists(AFullDcuName) then // 有 DCU 就解析 DCU
    begin
      Info := TCnUnitUsesInfo.Create(AFullDcuName);
      try
        for I := 0 to Info.IntfUsesCount - 1 do
          UsesList.Add(Info.IntfUses[I]);
        for I := 0 to Info.ImplUsesCount - 1 do
          UsesList.AddObject(Info.ImplUses[I], TObject(True));
      finally
        Info.Free;
      end;
    end
    else // 否则解析源码
    begin
      ParseUnitUsesFromFileName(AFullSourceName, UsesList);
    end;

    // UsesList 里拿到各引用名，无路径，需找到源文件与编译后的 dcu
    for I := 0 to UsesList.Count - 1 do
    begin
      // 找到源文件
      ASourceFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (ASourceFileName = '') or (ProcessedFiles.IndexOf(ASourceFileName) >= 0) then
        Continue;

      // 再找编译后的 dcu，可能在工程输出目录里，也可能在系统的 LibraryPath 里
      ADcuFileName := GetDcuName(FDcuPath, ASourceFileName);
      if not FileExists(ADcuFileName) then
      begin
        // 在系统的多个 LibraryPath 里找
        for J := 0 to FLibPaths.Count - 1 do
        begin
          if FileExists(MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt) then
          begin
            ADcuFileName := MakePath(FLibPaths[J]) + UsesList[I] + csDcuExt;
            Break;
          end;
        end;
      end;

      if not FileExists(ADcuFileName) then
        Continue;

      // ASourceFileName 存在且未处理过，新建一个 Leaf，挂当前 Leaf 下面
      Leaf := Tree.AddChild(UnitLeaf);
      Leaf.Text := ASourceFileName;
      (Leaf as TCnUsesLeaf).DcuName := ADcuFileName;
      (Leaf as TCnUsesLeaf).SearchType := St;
      (Leaf as TCnUsesLeaf).IsImpl := UsesList.Objects[I] <> nil;

      ProcessedFiles.Add(ASourceFileName);

      SearchAUnit(ADcuFileName, ASourceFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

procedure TCnTestUsesToolsWizard.SubActionExecute(Index: Integer);
begin
  if Index =   FTreeId then
    InitTreeExecute
  else if Index = FEnumId then
    EnumExecute;
end;

procedure TCnTestUsesToolsWizard.AcquireSubActions;
begin
  FTreeId := RegisterASubAction('TestUsesInitTree', 'Test Uses Init Tree');
  FEnumId := RegisterASubAction('TestEnumUses', 'Test Enum Uses');
end;

procedure TCnTestUsesToolsWizard.EnumExecute;
var
  Sl, OldNames: TStringList;
  I, Idx: Integer;
  Info: TCnUnitUsesInfo;
  Decl: TDCURec;
  S, AKey: string;
begin
  FUnits := TStringList.Create;
  FSysDcus := TStringList.Create;

  if IdeEnumUsesIncludeUnits(UsesCallback) then
    LongMessageDlg(FUnits.Text);
  FUnits.Free;

  Sl := TStringList.Create;
  OldNames := TStringList.Create;

  FSysDcus.Sort;

  for I := 0 to FSysDcus.Count - 1 do
  begin
    Sl.Add(_CnExtractFilePath(FSysDcus[I]));
    FSysDcus[I] := _CnChangeFileExt(_CnExtractFileName(FSysDcus[I]), '');
    OldNames.Add(FSysDcus[I]); // 拆分保留原有的路径与文件名
  end;
    LongMessageDlg(FSysDcus.Text);

  CorrectCaseFromIdeModules(FSysDcus); // 只支持纯文件名，还会给你排好序
  FSysDcus.Sorted := False;

  for I := 0 to FSysDcus.Count - 1 do
  begin
    Idx := OldNames.IndexOf(FSysDcus[I]); // 根据更改后的文件名找到原来对应的路径
    FSysDcus[I] := MakePath(Sl[Idx]) + FSysDcus[I] + '.dcu';
  end;

  LongMessageDlg(FSysDcus.Text);

  // 拿到了系统库中的所有 dcu，分析其输出
  if FUnitsMap <> nil then
    FreeAndNil(FUnitsMap);
  FUnitsMap := TCnStrToStrHashMap.Create;

  for I := 0 to FSysDcus.Count - 1 do
  begin
    Info := TCnUnitUsesInfo.Create(FSysDcus[I]);
    Decl := Info.DeclList;
    while Decl <> nil do
    begin
      S := Decl.Name^.GetStr;
      if S <> '' then
        FUnitsMap.Add(S, FSysDcus[I]);
      Decl := Decl.Next;
    end;

    Info.Free;
  end;

  ShowMessage(IntToStr(FUnitsMap.Size));
  if FUnitsMap.Size > 0 then
  begin
    Sl.Clear;
    FUnitsMap.StartEnum;
    while FUnitsMap.GetNext(AKey, S) do
    begin
      Sl.Add(AKey + ' | ' + S);
    end;
    Sl.SaveToFile('C:\Temp\Units.txt');
  end;

  FSysDcus.Free;
  OldNames.Free;
  Sl.Free;
end;

procedure TCnTestUsesToolsWizard.UsesCallback(
  const AUnitFullName: string; Exists: Boolean; FileType: TCnUsesFileType;
  ModuleSearchType: TCnModuleSearchType);
const
  USES_FILE_TYPES: array[TCnUsesFileType] of string =
    ('Invalid', 'Pascal Source', 'Pascal Dcu', 'Cpp Header');
  MODULE_SEARCH_TYPES: array[TCnModuleSearchType] of string =
    ('Invalid', 'In ProjectGroup', 'In Project Search Paths', 'In System Paths');
var
  S: string;
begin
  S := AUnitFullName;
  if not Exists then
    S := S + ' * ';
  S := S + ' | ' + USES_FILE_TYPES[FileType] + ' | ' + MODULE_SEARCH_TYPES[ModuleSearchType];
  FUnits.Add(S);

  if (FileType = uftPascalDcu) and (ModuleSearchType = mstSystemSearch) then
    FSysDcus.Add(AUnitFullName);
end;

initialization
  RegisterCnWizard(TCnTestUsesToolsWizard); // 注册此测试专家

end.
