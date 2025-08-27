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

unit CnTestUsesToolsWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestUsesInitTreeWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2021.08.20 V1.0
*               ������Ԫ
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
// CnTestUsesToolsWizard �˵�ר��
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
    {* �ݹ���ã����������� AUnitName ��ӦԴ��� Uses �б����뵽���е� UnitLeaf ���ӽڵ���}
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
// CnTestUsesToolsWizard �Ӳ˵�ר��
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

  // ��ӡ��������
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
  // ���� DCU ��Դ��õ� intf �� impl �������б��������� UnitLeaf ��ֱ���ӽڵ�
  // �ݹ���ø÷���������ÿ�������б��е����õ�Ԫ��
  if  not FileExists(AFullDcuName) and not FileExists(AFullSourceName) then
    Exit;

  UsesList := TStringList.Create;
  try
    if FileExists(AFullDcuName) then // �� DCU �ͽ��� DCU
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
    else // �������Դ��
    begin
      ParseUnitUsesFromFileName(AFullSourceName, UsesList);
    end;

    // UsesList ���õ�������������·�������ҵ�Դ�ļ�������� dcu
    for I := 0 to UsesList.Count - 1 do
    begin
      // �ҵ�Դ�ļ�
      ASourceFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (ASourceFileName = '') or (ProcessedFiles.IndexOf(ASourceFileName) >= 0) then
        Continue;

      // ���ұ����� dcu�������ڹ������Ŀ¼�Ҳ������ϵͳ�� LibraryPath ��
      ADcuFileName := GetDcuName(FDcuPath, ASourceFileName);
      if not FileExists(ADcuFileName) then
      begin
        // ��ϵͳ�Ķ�� LibraryPath ����
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

      // ASourceFileName ������δ��������½�һ�� Leaf���ҵ�ǰ Leaf ����
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
    OldNames.Add(FSysDcus[I]); // ��ֱ���ԭ�е�·�����ļ���
  end;
    LongMessageDlg(FSysDcus.Text);

  CorrectCaseFromIdeModules(FSysDcus); // ֻ֧�ִ��ļ�������������ź���
  FSysDcus.Sorted := False;

  for I := 0 to FSysDcus.Count - 1 do
  begin
    Idx := OldNames.IndexOf(FSysDcus[I]); // ���ݸ��ĺ���ļ����ҵ�ԭ����Ӧ��·��
    FSysDcus[I] := MakePath(Sl[Idx]) + FSysDcus[I] + '.dcu';
  end;

  LongMessageDlg(FSysDcus.Text);

  // �õ���ϵͳ���е����� dcu�����������
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
  RegisterCnWizard(TCnTestUsesToolsWizard); // ע��˲���ר��

end.
