{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnSMRBplUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：BPL 分析单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2007.08.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, CnCommon, CnBaseUtils;

const
  csDefaultPackageExt = '.bpl';
  cssExecutableFiles = ' Executable Files ';
  cssUnits = 'Units:';
  cssRequiredPackages = 'Required Packages:';
  { DO NOT LOCALIZE }

  csFileNotExists = 'File %s not exists.';
  csCanNotAnalyseFile = 'Analyze "%s" failed: ';

type
  PPackageInfos = ^TPackageInfos;
  TPackageInfos = record
    Units: TStrings;
    RequiredPackages: TStrings;
  end;

  TPackageInfosList = class(TStringList)
  private
    FStringProcessProc: TStringProcessProc;
    function GetPackageInfos(Index: Integer): PPackageInfos;
    procedure SetPackageInfos(Index: Integer; const Value: PPackageInfos);

    function ProcessString(const s: string): string;

    procedure ClearPackageInfos;
    procedure InternalSaveToText(var Stream: Text);
  public
    constructor Create;
    destructor Destroy; override;

    function GetRequiredPackagesSectionName(const s: string): string; virtual;
    function GetUnitsSectionName(const s: string): string; virtual;

    procedure AddFile(const FileName: string);
    procedure Clear; override;
    procedure Delete(Index: Integer); override;

    procedure BuildPackageUsedBy(UsedByPackagesList: TStringObjectList); overload;
    procedure BuildPackageUsedBy(UsedByPackagesList: TStringObjectList; TempStrings: TStrings); overload;
    procedure BuildUnits(Units: TStringObjectList);
    procedure GetAllAffectedPackages(UsedByPackagesList: TStringObjectList; ssUsedByPackages, ssAllAffectedPackages: TStrings);
    procedure GetAllRequiredPackages(ssRequiredPackages, ssAllRequiredPackages: TStrings);
    procedure GetAllUsedByPackages(UsedByPackagesList: TStringObjectList; ssUsedByPackages, ssAllUsedByPackages: TStrings);
    procedure GetRequiredPackages(const s: string; ssAllRequiredPackages: TStrings);
    procedure GetUsedByPackages(UsedByPackagesList: TStringObjectList; const s: string; ssAllUsedByPackages: TStrings);

    procedure AppendToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string); override;
    procedure SaveToFile(const FileName: string); override;

    property PackageInfos[Index: Integer]: PPackageInfos read GetPackageInfos write SetPackageInfos;
    property StringProcessProc: TStringProcessProc read FStringProcessProc write FStringProcessProc;
  end;

function NewPackageInfos: PPackageInfos;
function NewPackageInfosAndCreateList: PPackageInfos;
procedure DisposePackageInfos(P: PPackageInfos);

function EnumUnits(const FileName: string; ss: TStrings): Boolean; overload;
function EnumUnits(const Module: HMODULE; ss: TStrings): Boolean; overload;
function EnumRequiredPackages(const FileName: string; ss: TStrings): Boolean; overload;
function EnumRequiredPackages(const Module: HMODULE; ss: TStrings): Boolean; overload;
function EnumPackageInfos(const FileName: string; ssUnits, ssRequiredPackages: TStrings): Boolean; overload;
function EnumPackageInfos(const Module: HMODULE; ssUnits, ssRequiredPackages: TStrings): Boolean; overload;

implementation

{$IFDEF DELPHI7_UP}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

uses
  FileCtrl, CnBuffStr, CnSMRPEUtils;

function NewPackageInfos: PPackageInfos;
begin
  New(Result);
  Result.Units := nil;
  Result.RequiredPackages := nil;
end;

function NewPackageInfosAndCreateList: PPackageInfos;
begin
  New(Result);
  Result.Units := TStringList.Create;
  TStringList(Result.Units).Sorted := True;
  Result.RequiredPackages := TStringList.Create;
  TStringList(Result.RequiredPackages).Sorted := True;
end;

procedure DisposePackageInfos(P: PPackageInfos);
begin
  if P <> nil then
  begin
    if Assigned(P.Units) then
    begin
      FreeAndNil(P.Units);
    end;
    if Assigned(P.RequiredPackages) then
    begin
      FreeAndNil(P.RequiredPackages);
    end;
    Dispose(P);
  end;
end;

procedure GetPackageInfosProc(const Name: string; NameType: TNameType; Flags: Byte;
  Param: Pointer);
var
  P: PPackageInfos;
begin
  P := PPackageInfos(Param);
  if not Assigned(P) then
  begin
    Exit;
  end;

  if (NameType = ntContainsUnit) and (Assigned(P.Units)) then
  begin
    P.Units.Add(Name);
  end
  else if (NameType = ntRequiresPackage) and (Assigned(P.RequiredPackages)) then
  begin
    P.RequiredPackages.Add(Name);
  end;
end;

function EnumUnits(const FileName: string; ss: TStrings): Boolean;
begin
  Result := EnumPackageInfos(FileName, ss, nil);
end;

function EnumUnits(const Module: HMODULE; ss: TStrings): Boolean;
begin
  Result := EnumPackageInfos(Module, ss, nil);
end;

function EnumRequiredPackages(const FileName: string; ss: TStrings): Boolean;
begin
  Result := EnumPackageInfos(FileName, nil, ss);
end;

function EnumRequiredPackages(const Module: HMODULE; ss: TStrings): Boolean;
begin
  Result := EnumPackageInfos(Module, nil, ss);
end;

function EnumPackageInfos(const FileName: string; ssUnits, ssRequiredPackages: TStrings): Boolean;
var
  Module: HMODULE;
begin
  Result := False;
  if not FileExists(FileName) then
  begin
    Exit;
  end;

  Module := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
  if Module = 0 then
  begin
    RaiseLastWin32Error;
  end;
  
  try
    Result := EnumPackageInfos(Module, ssUnits, ssRequiredPackages);
  finally
    FreeLibrary(Module);
  end;
end;

function EnumPackageInfos(const Module: HMODULE; ssUnits, ssRequiredPackages: TStrings): Boolean;
var
  Flags: Integer;
  PI: TPackageInfos;
begin
  Result := False;
  if FindResource(Module, 'PACKAGEINFO', RT_RCDATA) <> 0 then
  begin
    PI.Units := ssUnits;
    PI.RequiredPackages := ssRequiredPackages;
    GetPackageInfo(Module, @PI, Flags, GetPackageInfosProc);
    Result := True;
  end;
end;

{ TPackageInfosList }

procedure TPackageInfosList.AddFile(const FileName: string);
var
  P: PPackageInfos;
begin
  if not FileExists(FileName) then
  begin
    raise Exception.CreateFmt(csFileNotExists, [AnsiQuotedStr(FileName, '"')]);
  end;

  P := NewPackageInfosAndCreateList;
  try
    EnumPackageInfos(FileName, P.Units, P.RequiredPackages);
    if P.RequiredPackages.Count = 0 then
      GetImportTable(P.RequiredPackages, FileName);
  except
    on E: Exception do
    begin
      DisposePackageInfos(P);
      E.Message := Format(csCanNotAnalyseFile, [FileName]) + E.Message;
      raise;
    end;
  end;
  AddObject(FileName, Pointer(P));
end;

procedure TPackageInfosList.AppendToFile(const FileName: string);
var
  Stream: TextFile;
begin
  AssignFile(Stream, FileName);
  try
    if FileExists(FileName) then
    begin
      System.Append(Stream);
    end
    else
    begin
      Rewrite(Stream);
    end;
    InternalSaveToText(Stream);
  finally
    CloseFile(Stream);
  end;
end;

procedure TPackageInfosList.BuildPackageUsedBy(
  UsedByPackagesList: TStringObjectList; TempStrings: TStrings);
var
  i, j: Integer;
  idx: Integer;
  P: PPackageInfos;
  sRequiredPackage, sPackages, s: string;
begin
  if not (Assigned(UsedByPackagesList) and Assigned(TempStrings)) then
  begin
    Exit;
  end;

  UsedByPackagesList.BeginUpdate;
  try
    UsedByPackagesList.Clear;
    for i := 0 to Self.Count - 1 do
    begin
      P := Self.PackageInfos[i];
      if (P <> nil) and (P.RequiredPackages <> nil) then
      begin
        for j := 0 to P.RequiredPackages.Count - 1 do
        begin
          sRequiredPackage := P.RequiredPackages[j];
          if _CnExtractFileExt(sRequiredPackage) = '' then
          begin
            sRequiredPackage := sRequiredPackage + csDefaultPackageExt;
          end;
          with UsedByPackagesList do
          begin
            idx := IndexOf(sRequiredPackage);
            if idx >= 0 then
            begin
              s := Strings[idx];
              SetCommaText(StringObjects[idx], TempStrings);
              TempStrings.Add(Self[i]);
              sPackages := TempStrings.CommaText;
              Delete(idx);
            end
            else
            begin
              sPackages := AnsiQuotedStr(Self[i], '"');
            end;
            AddStringObject(sRequiredPackage, sPackages);
          end;
        end;
      end;
    end;
  finally
    UsedByPackagesList.EndUpdate;
  end;
end;

procedure TPackageInfosList.BuildUnits(Units: TStringObjectList);
var
  i, j: Integer;
  idx: Integer;
  P: PPackageInfos;
  sUnit, sPackages, s: string;
begin
  Units.BeginUpdate;
  try
    Units.Clear;
    for i := 0 to Self.Count - 1 do
    begin
      P := Self.PackageInfos[i];
      if (P <> nil) and (P.Units <> nil) then
      begin
        for j := 0 to P.Units.Count - 1 do
        begin
          sUnit := P.Units[j];
          with Units do
          begin
            idx := IndexOf(sUnit);
            if idx >= 0 then
            begin
              s := Strings[idx];
              sPackages := StringObjects[idx] + ',' + AnsiQuotedStr(Self[i], '"');
              Delete(idx);
            end
            else
            begin
              sPackages := AnsiQuotedStr(Self[i], '"');
            end;
            AddStringObject(sUnit, sPackages);
          end;
        end;
      end;
    end;
  finally
    Units.EndUpdate;
  end;
end;

procedure TPackageInfosList.BuildPackageUsedBy(UsedByPackagesList: TStringObjectList);
var
  sstmp: TStringList;
begin
  sstmp := TStringList.Create;
  try
    sstmp.Sorted := True;
    BuildPackageUsedBy(UsedByPackagesList, sstmp);
  finally
    sstmp.Free;
  end;
end;

procedure TPackageInfosList.Clear;
begin
  ClearPackageInfos;
  inherited;
end;

procedure TPackageInfosList.ClearPackageInfos;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    DisposePackageInfos(PPackageInfos(Objects[i]));
  end;
end;

constructor TPackageInfosList.Create;
begin
  inherited;
end;

procedure TPackageInfosList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
  begin
    Exit;
  end;
  DisposePackageInfos(PackageInfos[Index]);
  inherited;
end;

destructor TPackageInfosList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TPackageInfosList.GetAllAffectedPackages(
  UsedByPackagesList: TStringObjectList;
  ssUsedByPackages, ssAllAffectedPackages: TStrings);
var
  i, j, idx: Integer;
  ss: TStringList;
begin
  if not (Assigned(ssUsedByPackages) and Assigned(ssAllAffectedPackages) and
    Assigned(UsedByPackagesList)) then
  begin
    Exit;
  end;

  ssAllAffectedPackages.Clear;
  for i := 0 to ssUsedByPackages.Count - 1 do
  begin
    ssAllAffectedPackages.Add(ssUsedByPackages[i]);
  end;

  ss := TStringList.Create;
  try
    for i := 0 to ssUsedByPackages.Count - 1 do
    begin
      idx := UsedByPackagesList.IndexOf(ssUsedByPackages[i]);
      if idx >= 0 then
      begin
        SetCommaText(UsedByPackagesList.StringObjects[idx], ss);
        for j := 0 to ss.Count - 1 do
        begin
          if ssAllAffectedPackages.IndexOf(ss[j]) < 0 then
            ssAllAffectedPackages.Add(ss[j]);
        end;
      end;
    end;
  finally
    ss.Free;
  end;
end;

procedure TPackageInfosList.GetAllRequiredPackages(ssRequiredPackages,
  ssAllRequiredPackages: TStrings);
var
  i: Integer;
  s: string;
begin
  if not (Assigned(ssRequiredPackages) and Assigned(ssAllRequiredPackages)) then
  begin
    Exit;
  end;

  for i := 0 to ssRequiredPackages.Count - 1 do
  begin
    s := ssRequiredPackages[i];
    if ssAllRequiredPackages.IndexOf(s) >= 0 then
    begin
      Continue;
    end;

    ssAllRequiredPackages.Add(s);
    GetRequiredPackages(s, ssAllRequiredPackages);
  end;
end;

procedure TPackageInfosList.GetAllUsedByPackages(UsedByPackagesList: TStringObjectList;
  ssUsedByPackages, ssAllUsedByPackages: TStrings);
var
  i: Integer;
  s: string;
begin
  if not (Assigned(ssUsedByPackages) and Assigned(ssAllUsedByPackages) and Assigned(UsedByPackagesList)) then
  begin
    Exit;
  end;

  for i := 0 to ssUsedByPackages.Count - 1 do
  begin
    s := ssUsedByPackages[i];
    if ssAllUsedByPackages.IndexOf(s) >= 0 then
    begin
      Continue;
    end;

    ssAllUsedByPackages.Add(s);
    GetUsedByPackages(UsedByPackagesList, s, ssAllUsedByPackages);
  end;
end;

function TPackageInfosList.GetPackageInfos(Index: Integer): PPackageInfos;
begin
  if (Index < 0) or (Index >= Count) then
  begin
    Result := nil;
    Exit;
  end;
  Result := Pointer(Objects[Index]);
end;

function TPackageInfosList.GetRequiredPackagesSectionName(
  const s: string): string;
begin
  Result := cssRequiredPackages + s;
end;

procedure TPackageInfosList.GetRequiredPackages(const s: string;
  ssAllRequiredPackages: TStrings);
var
  P: PPackageInfos;
begin
  P := Self.PackageInfos[Self.IndexOf(s)];
  if not (Assigned(ssAllRequiredPackages) and Assigned(P)) then
  begin
    Exit;
  end;

  GetAllRequiredPackages(P.RequiredPackages, ssAllRequiredPackages);
end;

function TPackageInfosList.GetUnitsSectionName(const s: string): string;
begin
  Result := cssUnits + s;
end;

procedure TPackageInfosList.GetUsedByPackages(UsedByPackagesList: TStringObjectList;
  const s: string; ssAllUsedByPackages: TStrings);
var
  idx: Integer;
  ss: TStringList;
begin
  if not (Assigned(ssAllUsedByPackages) and Assigned(UsedByPackagesList)) then
  begin
    Exit;
  end;

  idx := UsedByPackagesList.IndexOf(s);
  if idx < 0 then
  begin
    Exit;
  end;

  ss := TStringList.Create;
  try
    SetCommaText(UsedByPackagesList.StringObjects[idx], ss);
    GetAllUsedByPackages(UsedByPackagesList, ss, ssAllUsedByPackages);
  finally
    ss.Free;
  end;
end;

procedure TPackageInfosList.InternalSaveToText(var Stream: Text);
var
  i: Integer;
begin
  //Save Head
  StringsSaveToTextWithSection(Self, Stream, cssExecutableFiles, False, StringProcessProc);
  //Save Results
  for i := 0 to Count - 1 do
  begin
    if PackageInfos[i] <> nil then
    begin
      with PackageInfos[i]^ do
      begin
        StringsSaveToTextWithSection(
          Units,
          Stream,
          GetUnitsSectionName(ProcessString(Strings[i])));
        StringsSaveToTextWithSection(
          RequiredPackages,
          Stream,
          GetRequiredPackagesSectionName(ProcessString(Strings[i])));
      end;
    end;
  end;
end;

procedure TPackageInfosList.LoadFromFile(const FileName: string);
var
  P: PPackageInfos;
  Stream: TStringReader;
  i: Integer;
  sl: TSectionList;
begin
  Stream := TStringReader.Create;
  try
    Stream.LoadFromFile(FileName);
    BulidSectionList(Stream, sl);
//    sl := nil;
    BeginUpdate;
    try
      Clear;
      //Load Head
      StringsLoadFromTextWithSection(Self, Stream, cssExecutableFiles, sl);
      //Load Results
      for i := 0 to Count - 1 do
      begin
        P := NewPackageInfosAndCreateList;
        try
          PackageInfos[i] := P;
          StringsLoadFromTextWithSection(P.Units,
            Stream,
            GetUnitsSectionName(Strings[i]),
            sl);
          StringsLoadFromTextWithSection(
            P.RequiredPackages,
            Stream,
            GetRequiredPackagesSectionName(Strings[i]),
            sl);
        except
          DisposePackageInfos(P);
          raise;
        end;
      end;
    finally
      EndUpdate;
    end;
  finally
    Stream.Free;
    FreeSectionList(sl);
  end;
end;

function TPackageInfosList.ProcessString(const s: string): string;
begin
  if Assigned(StringProcessProc) then
  begin
    Result := StringProcessProc(s);
  end
  else
  begin
    Result := s;
  end;
end;

procedure TPackageInfosList.SaveToFile(const FileName: string);
var
  Stream: TextFile;
begin
  AssignFile(Stream, FileName);
  try
    Rewrite(Stream);
    InternalSaveToText(Stream);
  finally
    CloseFile(Stream);
  end;
end;

procedure TPackageInfosList.SetPackageInfos(Index: Integer;
  const Value: PPackageInfos);
begin
  if (Index < 0) or (Index >= Count) then
  begin
    Exit;
  end;
  PutObject(Index, Pointer(Value));
end;

end.
