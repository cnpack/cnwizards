{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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

unit CnRoClasses;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开历史文件的各个类单元
* 单元作者：Leeon (real-like@163.com); John Howe
* 备    注：
*           - TNodeManager : 节点管理器
*           - TStrIntfMap  : 字符串对应接口Map
*           - TRoFiles     : 记录保存文件
*           - TIniContainer: Ini文件处理类
*           使用对应的Get函数实现接口实例
*
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2012-09-19 by shenloqi
*               移植到Delphi XE3
*           2004-12-12 V1.1
*               去除TMyStringList，改用TList来管理。
*               添加节点管理器，以及提取接口的Map
*               将TIniContainer移动到此文件
*           2004-03-02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, SysUtils, Classes, IniFiles, CnRoConst, CnRoInterfaces, CnWizIni;

type
  PRoFileEntry = ^TRoFileEntry;
  TRoFileEntry = record
    FileName: string;
    OpenedTime: string;
    ClosingTime: string;
  end;

function GetNodeManager(ANodeSize: Cardinal): ICnNodeManager;
function GetStrIntfMap(): ICnStrIntfMap;
function GetRoFiles(ADefaultCap: Integer = iDefaultFileQty): ICnRoFiles;
function GetReopener(): ICnReopener;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  CnWizOptions, CnCommon;

type
  PGenericNode = ^TGenericNode;
  TGenericNode = packed record
    gnNext: PGenericNode;
    gnData: record end;
  end;
  
  TNodeManager = class(TInterfacedObject, ICnNodeManager)
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
    procedure FreeNode(aNode: Pointer);
  end;

  TBaseClass = class(TInterfacedObject)
  private
    FNodeMgr: ICnNodeManager;
  protected
    property NodeMgr: ICnNodeManager read FNodeMgr write FNodeMgr;
  public
    constructor Create(ANodeSize: Integer); virtual;
    destructor Destroy; override;
  end;
  
  PStrIntfMapEntry = ^TStrIntfMapEntry;
  TStrIntfMapEntry = record
    Key: string;
    Value: IUnknown;
  end;

  TStrIntfMap = class(TBaseClass, ICnStrIntfMap)
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
  
  TRoFiles = class(TBaseClass, ICnRoFiles)
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

  TIniContainer = class(TInterfacedObject, ICnReopener, ICnRoOptions)
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
    S := {$IFDEF DelphiXE3_UP}FormatSettings.{$ENDIF}LongTimeFormat
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
  Result := AnsiCompareStr(PRoFileEntry(Item1)^.OpenedTime, PRoFileEntry(Item2)^.OpenedTime);
end;

{
******************************************* TNodeManager *******************************************
}
constructor TNodeManager.Create(aNodeSize: Cardinal);
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

destructor TNodeManager.Destroy;
var
  Temp: Pointer;
begin
  while (FPageHead <> nil) do
  begin
    Temp := PGenericNode(FPageHead)^.gnNext;
    FreeMem(FPageHead, FPageSize);
    FPageHead := Temp;
  end;
  inherited Destroy;
end;

procedure TNodeManager.AllocNewPage;
var
  NewPage: PAnsiChar;
  index: Integer;
begin
  GetMem(NewPage, FPageSize);
  PGenericNode(NewPage)^.gnNext := FPageHead;
  FPageHead := NewPage;
  
  Inc(NewPage, SizeOf(Pointer));
  for index := FNodesPerPage - 1 downto 0 do
  begin
    FreeNode(NewPage);
    Inc(NewPage, FNodeSize);
  end;
end;

function TNodeManager.AllocNode: Pointer;
begin
  if (FFreeList = nil) then AllocNewPage;
  Result := FFreeList;
  FFreeList := PGenericNode(FFreeList)^.gnNext;
end;

function TNodeManager.AllocNodeClear: Pointer;
begin
  if (FFreeList = nil) then AllocNewPage;
  Result := FFreeList;
  FFreeList := PGenericNode(FFreeList)^.gnNext;
  FillChar(Result^, FNodeSize, 0);
end;

procedure TNodeManager.FreeNode(aNode: Pointer);
begin
  if (aNode = nil) then Exit;
  PGenericNode(aNode)^.gnNext := FFreeList;
  FFreeList := aNode;
end;

{
******************************************** TBaseClass ********************************************
}
constructor TBaseClass.Create(ANodeSize: Integer);
begin
  inherited Create;
  FNodeMgr := GetNodeManager(ANodeSize);
end;

destructor TBaseClass.Destroy;
begin
  FNodeMgr := nil;
  inherited Destroy;
end;

{
******************************************* TStrIntfMap ********************************************
}
constructor TStrIntfMap.Create(ANodeSize: Integer);
begin
  inherited Create(ANodeSize);
  FItems := TList.Create();
end;

destructor TStrIntfMap.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TStrIntfMap.Add(const Key: string; Value: IUnknown);
var
  P: PStrIntfMapEntry;
begin
  P := NodeMgr.AllocNodeClear;
  P^.Key := Key;
  P^.Value := Value;
  FItems.Add(P);
end;

procedure TStrIntfMap.Clear;
var
  I: Integer;
  Temp: PStrIntfMapEntry;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Temp := FItems[I];
    Temp.Key := '';
    Temp.Value := nil;
    NodeMgr.FreeNode(Temp);
  end; //end for
  FItems.Clear;
end;

function TStrIntfMap.GetValue(const Key: string): IUnknown;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    if (AnsiSameText(PStrIntfMapEntry(FItems[I]).Key, Key)) then
    begin
      Result := PStrIntfMapEntry(FItems[I]).Value;
      Exit;
    end;
  end; //end for
end;

function TStrIntfMap.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TStrIntfMap.KeyOf(Value: IUnknown): string;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    if (PStrIntfMapEntry(FItems[I]).Value = Value) then
    begin
      Result := PStrIntfMapEntry(FItems[I]).Key;
      Exit;
    end;
  end; //end for
end;

procedure TStrIntfMap.Remove(const Key: string);
var
  I: Integer;
  Temp: PStrIntfMapEntry;
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
  end; //end for
end;

{************************************ TRoFiles ********************************}

constructor TRoFiles.Create(ADefaultCap: Integer);
begin
  inherited Create(SizeOf(TRoFileEntry));
  FItems := TList.Create();
  FCapacity := ADefaultCap;
end;

destructor TRoFiles.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TRoFiles.AddFile(AFileName: string);
begin
  AddFileAndTime(AFileName, '', '');
end;

procedure TRoFiles.AddFileAndTime(AFileName, AOpenedTime, AClosingTime: string);
var
  Node: PRoFileEntry;
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

procedure TRoFiles.Clear;
var
  I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
  begin
    Delete(I);
  end; //end for
end;

function TRoFiles.Count: Integer;
begin
  Result := FItems.Count;
end;

procedure TRoFiles.Delete(AIndex: Integer);
var
  Temp: PRoFileEntry;
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

function TRoFiles.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TRoFiles.GetColumnSorting: string;
begin
  Result := FColumnSorting;
end;

function TRoFiles.GetNodes(Index: Integer): Pointer;
begin
  Result := FItems[Index];
end;

function TRoFiles.GetString(Index: Integer): string;
begin
  with PRoFileEntry(FItems[Index])^ do
  begin
    Result := FileName + SSeparator + OpenedTime + SSeparator + ClosingTime + SSeparator;
  end; //end with
end;

function TRoFiles.IndexOf(AFileName: string): Integer;
begin
  for Result := 0 to FItems.Count - 1 do
    if (AnsiSameText(PRoFileEntry(GetNodes(Result))^.FileName, AFileName)) then Exit;
  Result := -1;
end;

procedure TRoFiles.SetCapacity(const AValue: Integer);
begin
  FCapacity := AValue;
end;

procedure TRoFiles.SetColumnSorting(const AValue: string);
begin
  FColumnSorting := AValue;
end;

procedure TRoFiles.SetString(Index: Integer; AValue: string);
var
  I: Integer;
  AParam: array[0..2] of string;
  P, Start: PChar;
begin
  if (AnsiPos(SSeparator, AValue) = 0) then Exit;
  
  P := Pointer(AValue);
  I := 0;
  while P^ <> #0 do
  begin
    Start := P;
    while not CharInSet(P^, [#0, SSeparator]) do Inc(P);
    System.SetString(AParam[I], Start, P - Start);
    Inc(I);
    if P^ = SSeparator then Inc(P);
  end; //end while

  if (not FileExists(AParam[0])) then Exit;
  
  if (Index > Count - 1) or (Index < 0) then
  begin
    AddFileAndTime(AParam[0], AParam[1], AParam[2]);
  end else
  begin
    PRoFileEntry(FItems[Index])^.FileName := AParam[0];
    PRoFileEntry(FItems[Index])^.OpenedTime:= AParam[1];
    PRoFileEntry(FItems[Index])^.ClosingTime := AParam[2];
  end;
end;

procedure TRoFiles.SortByTimeOpened;
begin
  FItems.Sort(CompareOpenedTime);
end;

procedure TRoFiles.UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
begin
  if (AIndex < 0) then Exit;
  with PRoFileEntry(FItems[AIndex])^ do
  begin
    if (AOpenedTime <> '') then OpenedTime := AOpenedTime;
    if (AClosingTime <> '') then ClosingTime := AClosingTime;
  end; //end with
end;

{****************************** TIniContainer *********************************}

constructor TIniContainer.Create;
begin
  inherited Create;
  CheckForIni;
  FIniFile := TMemIniFile.Create(GetIniFileName);
  CreateRoFilesList;
  ReadAll;
end;

destructor TIniContainer.Destroy;
begin
  SaveAll;
  FreeAndNil(FIniFile);
  DestroyRoFilesList;
  inherited Destroy;
end;

procedure TIniContainer.CheckForIni;
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
  if FileExists(GetIniFileName) then Exit;
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
  //  Writeln(F, AddBool(SFormPersistance, True));
  //  Writeln(F, AddBool(SColumnPersistance, False));
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

procedure TIniContainer.CreateRoFilesList;
var
  I: Integer;
begin
  FRoFilesList := GetStrIntfMap;
  with FRoFilesList do
    for I := LowFileType to HighFileType do
      Add(FileType[I], GetRoFiles(iDefaultFileQty));
end;

procedure TIniContainer.DestroyRoFilesList;
begin
  FRoFilesList := nil;
end;

function TIniContainer.GetColumnPersistance: Boolean;
begin
  Result := FColumnPersistance;
end;

function TIniContainer.GetDefaultPage: Integer;
begin
  Result := FDefaultPage;
end;

function TIniContainer.GetFiles(Name: string): ICnRoFiles;
begin
  Result := ICnRoFiles(FRoFilesList[Name]);
end;

function TIniContainer.GetFormPersistance: Boolean;
begin
  Result := FFormPersistance;
end;

function TIniContainer.GetIgnoreDefaultUnits: Boolean;
begin
  Result := FIgnoreDefaultUnits;
end;

function TIniContainer.GetIniFileName: string;
begin
  Result := WizOptions.UserPath + SCnRecentFile;
end;

function TIniContainer.GetLocalDate: Boolean;
begin
  Result := FLocalDate;
end;

function TIniContainer.GetSortPersistance: Boolean;
begin
  Result := FSortPersistance;
end;

procedure TIniContainer.GetValues(const ASection: string; Strings: TStrings);
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
  
      SectionStrings := TStrings(Sections.Objects[I]);
      for J := 0 to SectionStrings.Count - 1 do
      begin
        S := SectionStrings.Names[J];
        S := Copy(SectionStrings[J], Length(S) + 2, MaxInt);
        Strings.Add(S);
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    Sections.Free;
  end;          
end;

procedure TIniContainer.LogClosingFile(AFileName: string);
begin
  LogFile(AFileName, SetClosingTime);
end;

procedure TIniContainer.LogFile(AFileName: string; ASetTime: TSetTimeEvent);
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
      '.FAV', '.BDSPROJ', 'DPROJ', 'CBPROJ']);
    case Index of
      0:
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
    if (GetIgnoreDefaultUnits) and (IsDefaultUnit(AFileName)) then Exit;
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

procedure TIniContainer.LogOpenedFile(AFileName: string);
begin
  LogFile(AFileName, SetOpenedTime);
end;

procedure TIniContainer.ReadAll;
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
    //SetColumnPersistance(ReadBool(SDefaults, SColumnPersistance, False));
    //SetFormPersistance(ReadBool(SDefaults, SFormPersistance, True));
    for I := LowFileType to HighFileType do
    begin
      Files[FileType[I]].Capacity := ReadInteger(SCapacity, FileType[I], iDefaultFileQty);
      Files[FileType[I]].ColumnSorting := ReadString(SPersistance, SColumnSorting + FileType[I], '0,0');
      ReadFiles(FileType[I]);
    end;
  end;
end;

procedure TIniContainer.ReadFiles(ASection: string);
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

procedure TIniContainer.SaveAll;
begin
  SaveSetting;
  SaveFiles;
end;

procedure TIniContainer.SaveFiles;
var
  I: Integer;
begin
  for I := LowFileType to HighFileType do
  begin
    WriteFiles(FileType[I]);
  end;
  UpdateIniFile;
end;

procedure TIniContainer.SaveSetting;
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

procedure TIniContainer.SetColumnPersistance(const AValue: Boolean);
begin
  FColumnPersistance := AValue;
end;

procedure TIniContainer.SetDefaultPage(const AValue: Integer);
begin
  FDefaultPage := AValue;
end;

procedure TIniContainer.SetFormPersistance(const AValue: Boolean);
begin
  FFormPersistance := AValue;
end;

procedure TIniContainer.SetIgnoreDefaultUnits(const AValue: Boolean);
begin
  FIgnoreDefaultUnits := AValue;
end;

procedure TIniContainer.SetLocalDate(const AValue: Boolean);
begin
  FLocalDate := AValue;
end;

procedure TIniContainer.SetSortPersistance(const AValue: Boolean);
begin
  FSortPersistance := AValue;
end;

procedure TIniContainer.UpdateIniFile;
begin
  FIniFile.UpdateFile;
end;

procedure TIniContainer.WriteFiles(ASection: string);
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

{******************************************************************************}

function GetNodeManager(ANodeSize: Cardinal): ICnNodeManager;
begin
  Result := TNodeManager.Create(ANodeSize);
end;

function GetStrIntfMap(): ICnStrIntfMap;
begin
  Result := TStrIntfMap.Create(SizeOf(TStrIntfMapEntry));
end;

function GetRoFiles(ADefaultCap: Integer = iDefaultFileQty): ICnRoFiles;
begin
  Result := TRoFiles.Create(ADefaultCap);
end;

function GetReopener(): ICnReopener;
begin
  Result := TIniContainer.Create;
end;

function TIniContainer.GetAutoSaveInterval: Cardinal;
begin
  Result := FAutoSaveInterval;
end;

procedure TIniContainer.SetAutoSaveInterval(const AValue: Cardinal);
begin
  FAutoSaveInterval := AValue;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.


