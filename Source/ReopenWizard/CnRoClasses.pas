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

unit CnRoClasses;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开历史文件的各个类单元
* 单元作者：Leeon (real-like@163.com); John Howe
* 备    注：
*           - TCnNodeManager : 节点管理器
*           - TCnStrIntfMap  : 字符串对应接口Map
*           - TCnRoFiles     : 记录保存文件
*           - TCnIniContainer: Ini文件处理类
*           使用对应的 Get 函数获取接口实例
*
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2019-05-04 by liuxiao
*               修正高版本的 Delphi 下 Ini 读出的 Objects 里无 Strings 的问题
*           2012-09-19 by shenloqi
*               移植到Delphi XE3
*           2004-12-12 V1.1
*               去除TMyStringList，改用TList来管理。
*               添加节点管理器，以及提取接口的Map
*               将TCnIniContainer移动到此文件
*           2004-03-02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, SysUtils, Classes, IniFiles, CnRoInterfaces, CnWizIni;

const
  SProjectGroup = 'bpg';
  SFavorite = 'fav';
  SOther = 'oth';
{$IFDEF DELPHI}
  SCnRecentFile = 'RecentFiles.ini';
  SProject = 'dpr';
  SPackge = 'dpk';
  SUnt = 'pas';
{$ELSE}
  SCnRecentFile = 'RecentFiles_BCB.ini';
  SProject = 'bpr';
  SPackge = 'bpk';
  SUnt = 'cpp';
{$ENDIF}

type
  PCnRoFileEntry = ^TCnRoFileEntry;
  TCnRoFileEntry = record
    FileName: string;
    OpenedTime: string;
    ClosingTime: string;
  end;

function CreateReopener: ICnReopener;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  CnWizOptions, CnCommon;

const
  SSeparator = '|';
  SFilePrefix = 'No';
  SSection = '[%s]';
  SCapacity = 'Capacity';
  SDefaults = 'Defaults';
  SPersistance = 'Persistance';

  SIgnoreDefaultUnits = 'IgnoreDefaultUnits';
  SDefaultPage = 'DefaultPage';
  SFormPersistance = 'FormPersistance';
  SSortPersistance = 'SortPersistance';
  SColumnPersistance = 'ColumnPersistance';
  SLocalDate = 'LocalDate';
  SAutoSaveInterval = 'AutoSaveInterval';

  SColumnSorting = 'ColumnSorting';
  SDataFormat = 'yyyy-mm-dd hh:nn:ss';

  PageSize = 1024;
  iDefaultFileQty = 30;
  LowFileType = 0;
  HighFileType = 5;
  FileType: array[LowFileType..HighFileType] of string =
    (SProjectGroup, SProject, SPackge, SUnt, SFavorite, SOther);

type
  PCnGenericNode = ^TCnGenericNode;
  TCnGenericNode = packed record
    gnNext: PCnGenericNode;
    gnData: record end;
  end;

  TCnNodeManager = class(TInterfacedObject, ICnNodeManager)
  private
    FFreeList: Pointer;
    FNodeSize: Cardinal;
    FNodesPerPage: Cardinal;
    FPageHead: Pointer;
    FPageSize: Cardinal;
    procedure AllocNewPage;
  public
    constructor Create(aNodeSize: Cardinal);
    destructor Destroy; override;
    function AllocNode: Pointer;
    function AllocNodeClear: Pointer;
    procedure FreeNode(ANode: Pointer);
  end;

  TCnBaseNode = class(TInterfacedObject)
  private
    FNodeMgr: ICnNodeManager;
  protected
    property NodeMgr: ICnNodeManager read FNodeMgr write FNodeMgr;
  public
    constructor Create(ANodeSize: Integer); virtual;
    destructor Destroy; override;
  end;

  PCnStrIntfMapEntry = ^TCnStrIntfMapEntry;
  TCnStrIntfMapEntry = record
    Key: string;
    Value: IUnknown;
  end;

  TCnStrIntfMap = class(TCnBaseNode, ICnStrIntfMap)
  private
    FItems: TList;
  protected
    procedure Add(const Key: string; Value: IUnknown);
    procedure Clear;
    function GetValue(const Key: string): IUnknown;
    function IsEmpty: Boolean;
    function KeyOf(Value: IUnknown): string;
    procedure Remove(const Key: string);
  public
    constructor Create(ANodeSize: Integer); override;
    destructor Destroy; override;
  end;

  TCnRoFiles = class(TCnBaseNode, ICnRoFiles)
  private
    FCapacity: Integer;
    FColumnSorting: string;
    FItems: TList;
  protected
    procedure AddFile(AFileName: string);
    procedure AddFileAndTime(AFileName, AOpenedTime, AClosingTime: string);
    procedure Clear;
    function Count: Integer;
    procedure Delete(AIndex: Integer);
    function GetCapacity: Integer;
    function GetColumnSorting: string;
    function GetNodes(Index: Integer): Pointer;
    function GetString(Index: Integer): string;
    function IndexOf(AFileName: string): Integer;
    procedure SetCapacity(const AValue: Integer);
    procedure SetColumnSorting(const AValue: string);
    procedure SetString(Index: Integer; AValue: string);
    procedure SortByTimeOpened;
    procedure UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
  public
    constructor Create(ADefaultCap: Integer); reintroduce;
    destructor Destroy; override;
  end;
  
  TSetTimeEvent = procedure (AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);

  TCnIniContainer = class(TInterfacedObject, ICnReopener, ICnRoOptions)
  private
    FColumnPersistance: Boolean;
    FDefaultPage: Integer;
    FFormPersistance: Boolean;
    FIgnoreDefaultUnits: Boolean;
    FIniFile: TMemIniFile;
    FLocalDate: Boolean;
    FRoFilesList: ICnStrIntfMap;
    FSortPersistance: Boolean;
    FAutoSaveInterval: Cardinal;
    procedure CheckForIni;
    procedure CreateRoFilesList;
    procedure DestroyRoFilesList;
    function GetIniFileName: string;
    procedure GetValues(const ASection: string; Strings: TStrings);
    procedure ReadAll;
    procedure ReadFiles(ASection: string);
    procedure WriteFiles(ASection: string);
  protected
    function GetColumnPersistance: Boolean;
    function GetDefaultPage: Integer;
    function GetFiles(Name: string): ICnRoFiles;
    function GetFormPersistance: Boolean;
    function GetIgnoreDefaultUnits: Boolean;
    function GetLocalDate: Boolean;
    function GetSortPersistance: Boolean;
    function GetAutoSaveInterval: Cardinal;
    procedure LogClosingFile(AFileName: string);
    procedure LogFile(AFileName: string; ASetTime: TSetTimeEvent);
    procedure LogOpenedFile(AFileName: string);
    procedure SaveAll;
    procedure SaveFiles;
    procedure SaveSetting;
    procedure SetColumnPersistance(const AValue: Boolean);
    procedure SetDefaultPage(const AValue: Integer);
    procedure SetFormPersistance(const AValue: Boolean);
    procedure SetIgnoreDefaultUnits(const AValue: Boolean);
    procedure SetLocalDate(const AValue: Boolean);
    procedure SetSortPersistance(const AValue: Boolean);
    procedure SetAutoSaveInterval(const AValue: Cardinal);
    procedure UpdateIniFile;
    property Files[Name: string]: ICnRoFiles read GetFiles;
  public
    constructor Create;
    destructor Destroy; override;
  end;

function GetCurrTime(ALocalData: Boolean): string;
var
  S: string;
begin
  if (ALocalData) then
    S := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}LongTimeFormat
  else
    S := SDataFormat;
  Result := FormatDateTime(S, Now);
end;

procedure SetOpenedTime(AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);
begin
  AFiles.UpdateTime(AIndex, GetCurrTime(ALocalData), '');
end;

procedure SetClosingTime(AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);
begin
  AFiles.UpdateTime(AIndex, '', GetCurrTime(ALocalData));
end;

function CompareOpenedTime(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareStr(PCnRoFileEntry(Item1)^.OpenedTime, PCnRoFileEntry(Item2)^.OpenedTime);
end;

function CreateReopener: ICnReopener;
begin
  Result := TCnIniContainer.Create;
end;

constructor TCnNodeManager.Create(aNodeSize: Cardinal);
begin
  inherited Create;
  if (aNodeSize <= SizeOf(Pointer)) then
    aNodeSize := SizeOf(Pointer)
  else
    aNodeSize := ((aNodeSize + 3) shr 2) shl 2;
  FNodeSize := aNodeSize;
  
  FNodesPerPage := (PageSize - SizeOf(Pointer)) div aNodeSize;
  if (FNodesPerPage > 1) then
  begin
    FPageSize := 1024;
  end else
  begin
    FNodesPerPage := 1;
    FPagesize := aNodeSize + SizeOf(Pointer);
  end;
end;

destructor TCnNodeManager.Destroy;
var
  Temp: Pointer;
begin
  while (FPageHead <> nil) do
  begin
    Temp := PCnGenericNode(FPageHead)^.gnNext;
    FreeMem(FPageHead, FPageSize);
    FPageHead := Temp;
  end;
  inherited Destroy;
end;

procedure TCnNodeManager.AllocNewPage;
var
  NewPage: PAnsiChar;
  index: Integer;
begin
  GetMem(NewPage, FPageSize);
  PCnGenericNode(NewPage)^.gnNext := FPageHead;
  FPageHead := NewPage;
  
  Inc(NewPage, SizeOf(Pointer));
  for index := FNodesPerPage - 1 downto 0 do
  begin
    FreeNode(NewPage);
    Inc(NewPage, FNodeSize);
  end;
end;

function TCnNodeManager.AllocNode: Pointer;
begin
  if (FFreeList = nil) then AllocNewPage;
  Result := FFreeList;
  FFreeList := PCnGenericNode(FFreeList)^.gnNext;
end;

function TCnNodeManager.AllocNodeClear: Pointer;
begin
  if (FFreeList = nil) then
    AllocNewPage;

  Result := FFreeList;
  FFreeList := PCnGenericNode(FFreeList)^.gnNext;
  FillChar(Result^, FNodeSize, 0);
end;

procedure TCnNodeManager.FreeNode(ANode: Pointer);
begin
  if ANode = nil then
    Exit;

  PCnGenericNode(ANode)^.gnNext := FFreeList;
  FFreeList := ANode;
end;

constructor TCnBaseNode.Create(ANodeSize: Integer);
begin
  inherited Create;
  FNodeMgr := TCnNodeManager.Create(ANodeSize) as ICnNodeManager;
end;

destructor TCnBaseNode.Destroy;
begin
  FNodeMgr := nil;
  inherited Destroy;
end;

constructor TCnStrIntfMap.Create(ANodeSize: Integer);
begin
  inherited Create(ANodeSize);
  FItems := TList.Create;
end;

destructor TCnStrIntfMap.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TCnStrIntfMap.Add(const Key: string; Value: IUnknown);
var
  P: PCnStrIntfMapEntry;
begin
  P := NodeMgr.AllocNodeClear;
  P^.Key := Key;
  P^.Value := Value;
  FItems.Add(P);
end;

procedure TCnStrIntfMap.Clear;
var
  I: Integer;
  Temp: PCnStrIntfMapEntry;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Temp := FItems[I];
    Temp.Key := '';
    Temp.Value := nil;
    NodeMgr.FreeNode(Temp);
  end;
  FItems.Clear;
end;

function TCnStrIntfMap.GetValue(const Key: string): IUnknown;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    if (AnsiSameText(PCnStrIntfMapEntry(FItems[I]).Key, Key)) then
    begin
      Result := PCnStrIntfMapEntry(FItems[I]).Value;
      Exit;
    end;
  end;
end;

function TCnStrIntfMap.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TCnStrIntfMap.KeyOf(Value: IUnknown): string;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    if (PCnStrIntfMapEntry(FItems[I]).Value = Value) then
    begin
      Result := PCnStrIntfMapEntry(FItems[I]).Key;
      Exit;
    end;
  end;
end;

procedure TCnStrIntfMap.Remove(const Key: string);
var
  I: Integer;
  Temp: PCnStrIntfMapEntry;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Temp := FItems[I];
    if (AnsiSameText(Temp.Key, Key)) then
    begin
      Temp.Key := '';
      Temp.Value := nil;
      NodeMgr.FreeNode(Temp);
      FItems.Delete(I);
      Exit;
    end;
  end;
end;

constructor TCnRoFiles.Create(ADefaultCap: Integer);
begin
  inherited Create(SizeOf(TCnRoFileEntry));
  FItems := TList.Create();
  FCapacity := ADefaultCap;
end;

destructor TCnRoFiles.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TCnRoFiles.AddFile(AFileName: string);
begin
  AddFileAndTime(AFileName, '', '');
end;

procedure TCnRoFiles.AddFileAndTime(AFileName, AOpenedTime, AClosingTime: string);
var
  Node: PCnRoFileEntry;
begin
  Node := NodeMgr.AllocNodeClear;
  with Node^ do
  begin
    FileName := AFileName;
    OpenedTime := AOpenedTime;
    ClosingTime := AClosingTime;
  end;
  FItems.Add(Node);
end;

procedure TCnRoFiles.Clear;
var
  I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
  begin
    Delete(I);
  end;
end;

function TCnRoFiles.Count: Integer;
begin
  Result := FItems.Count;
end;

procedure TCnRoFiles.Delete(AIndex: Integer);
var
  Temp: PCnRoFileEntry;
begin
  Temp := FItems[AIndex];
  with Temp^ do
  begin
    FileName := '';
    OpenedTime := '';
    ClosingTime := '';
  end;
  NodeMgr.FreeNode(Temp);
  FItems.Delete(AIndex);
end;

function TCnRoFiles.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TCnRoFiles.GetColumnSorting: string;
begin
  Result := FColumnSorting;
end;

function TCnRoFiles.GetNodes(Index: Integer): Pointer;
begin
  Result := FItems[Index];
end;

function TCnRoFiles.GetString(Index: Integer): string;
begin
  with PCnRoFileEntry(FItems[Index])^ do
  begin
    Result := FileName + SSeparator + OpenedTime + SSeparator + ClosingTime + SSeparator;
  end;
end;

function TCnRoFiles.IndexOf(AFileName: string): Integer;
begin
  for Result := 0 to FItems.Count - 1 do
    if (AnsiSameText(PCnRoFileEntry(GetNodes(Result))^.FileName, AFileName))
      then Exit;
  Result := -1;
end;

procedure TCnRoFiles.SetCapacity(const AValue: Integer);
begin
  FCapacity := AValue;
end;

procedure TCnRoFiles.SetColumnSorting(const AValue: string);
begin
  FColumnSorting := AValue;
end;

procedure TCnRoFiles.SetString(Index: Integer; AValue: string);
var
  I: Integer;
  AParam: array[0..2] of string;
  P, Start: PChar;
begin
  if (AnsiPos(SSeparator, AValue) = 0) then
    Exit;
  
  P := Pointer(AValue);
  I := 0;
  while P^ <> #0 do
  begin
    Start := P;
    while not CharInSet(P^, [#0, SSeparator]) do Inc(P);
    System.SetString(AParam[I], Start, P - Start);
    Inc(I);
    if P^ = SSeparator then Inc(P);
  end;

  if (not FileExists(AParam[0])) then
    Exit;
  
  if (Index > Count - 1) or (Index < 0) then
  begin
    AddFileAndTime(AParam[0], AParam[1], AParam[2]);
  end
  else
  begin
    PCnRoFileEntry(FItems[Index])^.FileName := AParam[0];
    PCnRoFileEntry(FItems[Index])^.OpenedTime:= AParam[1];
    PCnRoFileEntry(FItems[Index])^.ClosingTime := AParam[2];
  end;
end;

procedure TCnRoFiles.SortByTimeOpened;
begin
  FItems.Sort(CompareOpenedTime);
end;

procedure TCnRoFiles.UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
begin
  if (AIndex < 0) then
    Exit;

  with PCnRoFileEntry(FItems[AIndex])^ do
  begin
    if (AOpenedTime <> '') then OpenedTime := AOpenedTime;
    if (AClosingTime <> '') then ClosingTime := AClosingTime;
  end;
end;

constructor TCnIniContainer.Create;
begin
  inherited Create;
  CheckForIni;
  FIniFile := TMemIniFile.Create(GetIniFileName);
  CreateRoFilesList;
  ReadAll;
end;

destructor TCnIniContainer.Destroy;
begin
  SaveAll;
  FreeAndNil(FIniFile);
  DestroyRoFilesList;
  inherited Destroy;
end;

procedure TCnIniContainer.CheckForIni;
var
  F: Text;
  
  function AddBool(const S: string; B: Boolean): string;
  begin
    Result := S + '=' + IntToStr(Integer(B));
  end;
  
  function AddNum(const S: string; I: Integer): string;
  begin
    Result := S + '=' + IntToStr(I);
  end;
  
begin
  if FileExists(GetIniFileName) then
    Exit;

  Assign(F, GetIniFileName);
  Rewrite(F);
  Writeln(F, Format(SSection, [SCapacity]));
  Writeln(F, AddNum(SProjectGroup, iDefaultFileQty));
  Writeln(F, AddNum(SProject, iDefaultFileQty));
  Writeln(F, AddNum(SUnt, iDefaultFileQty * 2));
  Writeln(F, AddNum(SPackge, iDefaultFileQty));
  Writeln(F, AddNum(SOther, iDefaultFileQty));
  Writeln(F, AddNum(SFavorite, iDefaultFileQty));
  
  Writeln(F, Format(SSection, [SDefaults]));
  Writeln(F, AddBool(SIgnoreDefaultUnits, True));
  Writeln(F, AddNum(SDefaultPage, 2));

  Writeln(F, AddBool(SSortPersistance, True));
  Writeln(F, AddBool(SLocalDate, False));
  
  Writeln(F, Format(SSection, [SPersistance]));
  Writeln(F, AddBool(SColumnSorting + SProjectGroup, False));
  Writeln(F, AddBool(SColumnSorting + SProject, False));
  Writeln(F, AddBool(SColumnSorting + SUnt, False));
  Writeln(F, AddBool(SColumnSorting + SPackge, False));
  Writeln(F, AddBool(SColumnSorting + SOther, False));
  Writeln(F, AddBool(SColumnSorting + SFavorite, False));
  
  Writeln(F, Format(SSection, [SProjectGroup]));
  Writeln(F, Format(SSection, [SProject]));
  Writeln(F, Format(SSection, [SUnt]));
  Writeln(F, Format(SSection, [SPackge]));
  Writeln(F, Format(SSection, [SOther]));
  Writeln(F, Format(SSection, [SFavorite]));
  Close(F);
end;

procedure TCnIniContainer.CreateRoFilesList;
var
  I: Integer;
begin
  FRoFilesList := TCnStrIntfMap.Create(SizeOf(TCnStrIntfMapEntry)) as ICnStrIntfMap;
  with FRoFilesList do
    for I := LowFileType to HighFileType do
      Add(FileType[I], TCnRoFiles.Create(iDefaultFileQty) as ICnRoFiles);
end;

procedure TCnIniContainer.DestroyRoFilesList;
begin
  FRoFilesList := nil;
end;

function TCnIniContainer.GetColumnPersistance: Boolean;
begin
  Result := FColumnPersistance;
end;

function TCnIniContainer.GetDefaultPage: Integer;
begin
  Result := FDefaultPage;
end;

function TCnIniContainer.GetFiles(Name: string): ICnRoFiles;
begin
  Result := ICnRoFiles(FRoFilesList[Name]);
end;

function TCnIniContainer.GetFormPersistance: Boolean;
begin
  Result := FFormPersistance;
end;

function TCnIniContainer.GetIgnoreDefaultUnits: Boolean;
begin
  Result := FIgnoreDefaultUnits;
end;

function TCnIniContainer.GetIniFileName: string;
begin
  Result := WizOptions.UserPath + SCnRecentFile;
end;

function TCnIniContainer.GetLocalDate: Boolean;
begin
  Result := FLocalDate;
end;

function TCnIniContainer.GetSortPersistance: Boolean;
begin
  Result := FSortPersistance;
end;

procedure TCnIniContainer.GetValues(const ASection: string; Strings: TStrings);
var
  I, J: Integer;
  S: string;
  Sections: TStrings;
  SectionStrings: TStrings;
begin
  Sections := TStringList.Create;
  try
    FIniFile.ReadSections(Sections);

    Strings.BeginUpdate;
    try
      Strings.Clear;
      I := Sections.IndexOf(ASection);
      if I < 0 then Exit;

      SectionStrings := TStringList.Create;
      try
        FIniFile.ReadSection(ASection, SectionStrings);

        // SectionStrings := TStrings(Sections.Objects[I]);
        // Sections.Objects 在高版本 Delphi 中不再是包含 Section 的所有内容的 Strings 了
        // 必须手工读
        for J := 0 to SectionStrings.Count - 1 do
        begin
          S := FIniFile.ReadString(ASection, SectionStrings[J], '');
          if S <> '' then
            Strings.Add(S);
          // S := SectionStrings.Names[J];
          // S := Copy(SectionStrings[J], Length(S) + 2, MaxInt);
          // Strings.Add(S);
        end;
      finally
        SectionStrings.Free;
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    Sections.Free;
  end;          
end;

procedure TCnIniContainer.LogClosingFile(AFileName: string);
begin
  LogFile(AFileName, SetClosingTime);
end;

procedure TCnIniContainer.LogFile(AFileName: string; ASetTime: TSetTimeEvent);
var
  I: Integer;
  vFiles: ICnRoFiles;
  
  function GetList(S: string): ICnRoFiles;
  var
    Index: Integer;
  begin
    S := _CnExtractFileExt(S);
    Index := IndexStr(S, [
      '.BPG',
      '.DPR', '.BPR', '.BPF',
      '.PAS', '.H', '.HPP', '.C', '.CPP',
      '.DPK', '.BPK',
      '.FAV', '.BDSPROJ', '.DPROJ', '.CBPROJ',
      '.GROUPPROJ']);
    case Index of
      0, 15:
        Result := GetFiles(SProjectGroup);
      1, 2, 3, 12, 13, 14:
        Result := GetFiles(SProject);
      4, 5, 6, 7, 8:
        Result := GetFiles(SUnt);
      9, 10:
        Result := GetFiles(SPackge);
      11:
        Result := GetFiles(SFavorite);
    else
      Result := GetFiles(SOther);
    end;
  end;
  
  function IsDefaultUnit(S: string): Boolean;
  begin
    Result := (AnsiPos('ProjectGroup1', S) <> 0) or
              (AnsiPos('Project1', S) <> 0) or
              (AnsiPos('Package1', S) <> 0) or
              (AnsiPos('Unit1', S) <> 0)
  end;
  
  procedure SetTime(S: string; Idx: Integer);
  begin
    vFiles.AddFile(S);
    ASetTime(vFiles, Idx, GetLocalDate);
  end;
  
begin
  if (AFileName = '') then Exit;
  vFiles := GetList(AFileName);
  I := vFiles.IndexOf(AFileName);
  if (I >= 0) then
  begin
    ASetTime(vFiles, I, GetLocalDate);
  end else
  begin
    if (GetIgnoreDefaultUnits) and (IsDefaultUnit(AFileName)) then
      Exit;

    if vFiles.Count = vFiles.Capacity then
      vFiles.Delete(0)
    else if vFiles.Capacity < vFiles.Count then
      for I := 0 to (vFiles.Count - vFiles.Capacity) do
      begin
        vFiles.Delete(I);
      end;
    SetTime(AFileName, vFiles.Count - 1);
  end;
end;

procedure TCnIniContainer.LogOpenedFile(AFileName: string);
begin
  LogFile(AFileName, SetOpenedTime);
end;

procedure TCnIniContainer.ReadAll;
var
  I: Integer;
begin
  with FIniFile do
  begin
    SetIgnoreDefaultUnits(ReadBool(SDefaults, SIgnoreDefaultUnits, False));
    SetDefaultPage(ReadInteger(SDefaults, SDefaultPage, 0));
    SetLocalDate(ReadBool(SDefaults, SLocalDate, False));
    SetSortPersistance(ReadBool(SDefaults, SSortPersistance, False));
    SetAutoSaveInterval(ReadInteger(SDefaults, SAutoSaveInterval, 5));

    for I := LowFileType to HighFileType do
    begin
      Files[FileType[I]].Capacity := ReadInteger(SCapacity, FileType[I], iDefaultFileQty);
      Files[FileType[I]].ColumnSorting := ReadString(SPersistance, SColumnSorting + FileType[I], '0,0');
      ReadFiles(FileType[I]);
    end;
  end;
end;

procedure TCnIniContainer.ReadFiles(ASection: string);
var
  I: Integer;
  vFiles: ICnRoFiles;
  vStrs: TStrings;
begin
  vFiles := GetFiles(ASection);
  vStrs := TStringList.Create;
  try
    GetValues(ASection, vStrs);
    if (vStrs.Count = 0) then Exit;
    with vFiles do
    begin
      Clear;
      for I := 0 to vStrs.Count - 1 do
      begin
        SetString(-1, vStrs[I]);
      end;
      SortByTimeOpened;
    end;
  finally
    vStrs.Free;
  end;
end;

procedure TCnIniContainer.SaveAll;
begin
  SaveSetting;
  SaveFiles;
end;

procedure TCnIniContainer.SaveFiles;
var
  I: Integer;
begin
  for I := LowFileType to HighFileType do
  begin
    WriteFiles(FileType[I]);
  end;
  UpdateIniFile;
end;

procedure TCnIniContainer.SaveSetting;
var
  I: Integer;
begin
  with FIniFile do
  begin
    EraseSection(SDefaults);
    EraseSection(SPersistance);
    EraseSection(SCapacity);
    WriteBool(SDefaults, SIgnoreDefaultUnits, GetIgnoreDefaultUnits);
    WriteInteger(SDefaults, SDefaultPage, GetDefaultPage);
    WriteBool(SDefaults, SSortPersistance, GetSortPersistance);
    WriteBool(SDefaults, SLocalDate, GetLocalDate);
    WriteInteger(SDefaults, SAutoSaveInterval, FAutoSaveInterval);
    //WriteBool(SDefaults, SColumnPersistance, GetColumnPersistance);
    //WriteBool(SDefaults, SFormPersistance, GetFormPersistance);
    for I := LowFileType to HighFileType do
    begin
      WriteInteger(SCapacity, FileType[I], Files[FileType[I]].Capacity);
      WriteString(SPersistance, SColumnSorting + FileType[I], Files[FileType[I]].ColumnSorting);
    end;
  end; //end with
  UpdateIniFile;
end;

procedure TCnIniContainer.SetColumnPersistance(const AValue: Boolean);
begin
  FColumnPersistance := AValue;
end;

procedure TCnIniContainer.SetDefaultPage(const AValue: Integer);
begin
  FDefaultPage := AValue;
end;

procedure TCnIniContainer.SetFormPersistance(const AValue: Boolean);
begin
  FFormPersistance := AValue;
end;

procedure TCnIniContainer.SetIgnoreDefaultUnits(const AValue: Boolean);
begin
  FIgnoreDefaultUnits := AValue;
end;

procedure TCnIniContainer.SetLocalDate(const AValue: Boolean);
begin
  FLocalDate := AValue;
end;

procedure TCnIniContainer.SetSortPersistance(const AValue: Boolean);
begin
  FSortPersistance := AValue;
end;

procedure TCnIniContainer.UpdateIniFile;
begin
  FIniFile.UpdateFile;
end;

procedure TCnIniContainer.WriteFiles(ASection: string);
var
  I: Integer;
begin
  with Files[ASection], FIniFile do
  begin
    EraseSection(ASection);
    for I := 0 to Count - 1 do
    begin
      WriteString(ASection, SFilePrefix + IntToStr(I), GetString(I));
    end;
  end;
end;

function TCnIniContainer.GetAutoSaveInterval: Cardinal;
begin
  Result := FAutoSaveInterval;
end;

procedure TCnIniContainer.SetAutoSaveInterval(const AValue: Cardinal);
begin
  FAutoSaveInterval := AValue;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.


