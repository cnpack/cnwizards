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

unit CnDCU32;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：DCU32 简单封装单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元的字符串均符合本地化处理方式
* 修改记录：2005.08.11 v1.0
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Classes, SysUtils, Contnrs, DCURecs, DCU32, DCU_Out
  {$IFNDEF STAND_ALONE}, ToolsAPI, CnWizUtils, CnPasCodeParser
  {$IFDEF UNICODE}, CnWidePasParser {$ENDIF}, CnCommon,
  CnWizConsts {$ENDIF};

type

{ TCnUnitUsesInfo }

  TCnUnitUsesInfo = class(TUnit)
  {* 描述从 DCU 中解析出来的 Uses 内容}
  private
    FIntfUses: TStringList;  // 存储 interface 部分的 uses 单元，以及每个单元对应的导入类名
    FImplUses: TStringList;  // 存储 implementation 部分的 uses 单元，以及每个单元对应的导入类名
    function GetImplUse(Index: Integer): string;
    function GetImplUsesCount: Integer;
    function GetImplUsesImport(Index: Integer): TStrings;
    function GetIntfUse(Index: Integer): string;
    function GetIntfUsesCount: Integer;
    function GetIntfUsesImport(Index: Integer): TStrings;
    procedure GetUsesList(AList: TStringList; AFlag: TUnitImpFlags);
    procedure ClearUsesList(AList: TStringList);
  public
    constructor Create(const DcuName: string; UseOnly: Boolean = True); reintroduce;
    destructor Destroy; override;
    procedure Sort;
    
    property IntfUsesCount: Integer read GetIntfUsesCount;
    {* interface 部分有多少个 uses}
    property IntfUses[Index: Integer]: string read GetIntfUse;
    {* interface 部分的每一个 uses}
    property IntfUsesImport[Index: Integer]: TStrings read GetIntfUsesImport;
    {* interface 部分每一个 uses 单元导入的类名列表}
    property ImplUsesCount: Integer read GetImplUsesCount;
    {* implementation 部分有多少个 uses}
    property ImplUses[Index: Integer]: string read GetImplUse;
    {* implementation 部分的每一个 uses}
    property ImplUsesImport[Index: Integer]: TStrings read GetImplUsesImport;
    {* implementation 部分每一个 uses 单元导入的类名列表}

    property ExportedNames: TStringList read FExportNames;
    {* 导出的名字们}
  end;

  TCnUsesKind = (ukHasInitSection, ukHasRegProc, ukInCleanList, ukInIgnoreList,
    ukNoSource, tkCompRef);
  TCnUsesKinds = set of TCnUsesKind;

{ TCnUsesItem }

  TCnUsesItem = class
  {* 描述一项 uses 项}
  private
    FChecked: Boolean;
    FKinds: TCnUsesKinds;
    FName: string;
  public
    property Name: string read FName write FName;
    property Checked: Boolean read FChecked write FChecked;
    property Kinds: TCnUsesKinds read FKinds write FKinds;
  end;

{ TCnEmptyUsesInfo }

  TCnEmptyUsesInfo = class
  {* 描述一所需处理的文件处理类}
  private
    FSourceFileName: string;
{$IFNDEF STAND_ALONE}
    FProject: IOTAProject;
{$ENDIF}
    FDcuName: string;
    FIntfItems: TObjectList;
    FImplItems: TObjectList;

    function GetImplCount: Integer;
    function GetImplItem(Index: Integer): TCnUsesItem;
    function GetIntfCount: Integer;
    function GetIntfItem(Index: Integer): TCnUsesItem;
  public
    constructor Create(const ADcuName, ASourceFileName: string {$IFNDEF STAND_ALONE};
      AProject: IOTAProject {$ENDIF});
    destructor Destroy; override;
{$IFNDEF STAND_ALONE}
    function Process: Boolean;
{$ENDIF}
    property DcuName: string read FDcuName;
    property SourceFileName: string read FSourceFileName;
{$IFNDEF STAND_ALONE}
    property Project: IOTAProject read FProject;
{$ENDIF}
    property IntfCount: Integer read GetIntfCount;
    property IntfItems[Index: Integer]: TCnUsesItem read GetIntfItem;
    property ImplCount: Integer read GetImplCount;
    property ImplItems[Index: Integer]: TCnUsesItem read GetImplItem;
  end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$IFNDEF STAND_ALONE}
uses
  CnWizEditFiler;
{$ENDIF}

{ TCnUnitUsesInfo }

procedure TCnUnitUsesInfo.ClearUsesList(AList: TStringList);
var
  i: Integer;
begin
  if Assigned(AList) then
    for i := AList.Count - 1 downto 0 do
    begin
      AList.Objects[i].Free;
      AList.Delete(i);
    end;
end;

constructor TCnUnitUsesInfo.Create(const DcuName: string; UseOnly: Boolean);
begin
  FIntfUses := TStringList.Create;
  FImplUses := TStringList.Create;
  inherited Create;
  try
    Load(DcuName, 0, False, dcuplWin32, nil);
  except
    {$IFNDEF DELPHI2009_UP}
    raise;
    {$ENDIF}
  end;
  GetUsesList(FIntfUses, []);
  GetUsesList(FImplUses, [ufImpl]);
end;

destructor TCnUnitUsesInfo.Destroy;
begin
  ClearUsesList(FIntfUses);
  ClearUsesList(FImplUses);
  FIntfUses.Free;
  FImplUses.Free;
  inherited;
end;

function TCnUnitUsesInfo.GetImplUse(Index: Integer): string;
begin
  Result := FImplUses[Index];
end;

function TCnUnitUsesInfo.GetImplUsesCount: Integer;
begin
  Result := FImplUses.Count;
end;

function TCnUnitUsesInfo.GetImplUsesImport(Index: Integer): TStrings;
begin
  Result := TStrings(FImplUses.Objects[Index]);
end;

function TCnUnitUsesInfo.GetIntfUse(Index: Integer): string;
begin
  Result := FIntfUses[Index];
end;

function TCnUnitUsesInfo.GetIntfUsesCount: Integer;
begin
  Result := FIntfUses.Count;
end;

function TCnUnitUsesInfo.GetIntfUsesImport(Index: Integer): TStrings;
begin
  Result := TStrings(FIntfUses.Objects[Index]);
end;

procedure TCnUnitUsesInfo.GetUsesList(AList: TStringList; AFlag: TUnitImpFlags);
var
  i: Integer;
  PRec: PUnitImpRec;
  Lines: TStringList;
  Decl: TBaseDef;
begin
  ClearUsesList(AList);
  if FUnitImp.Count = 0 then
    Exit;

  for i := 0 to FUnitImp.Count - 1 do
  begin
    PRec := FUnitImp[i];
    if AFlag <> PRec.Flags then
      Continue;
    Lines := TStringList.Create;
    AList.AddObject({$IFDEF UNICODE}string{$ENDIF}(PRec^.Name^.GetStr), Lines);

    Decl := PRec^.Decls;
    while Decl <> nil do
    begin
      if Decl is TImpDef then
        Lines.Add(TImpDef(Decl).ik + ':' + {$IFDEF UNICODE}string{$ENDIF}(Decl.Name^.GetStr))
      else
        Lines.Add({$IFDEF UNICODE}string{$ENDIF}(Decl.Name^.GetStr));
      Decl := Decl.Next as TBaseDef;
    end;
  end;
end;

procedure TCnUnitUsesInfo.Sort;
begin
  FIntfUses.Sorted := True;
  FImplUses.Sorted := True;
end;

{ TCnEmptyUsesInfo }

constructor TCnEmptyUsesInfo.Create(const ADcuName, ASourceFileName: string
  {$IFNDEF STAND_ALONE}; AProject: IOTAProject {$ENDIF});
begin
  inherited Create;
  FIntfItems := TObjectList.Create;
  FImplItems := TObjectList.Create;
  FDcuName := ADcuName;
  FSourceFileName := ASourceFileName;
{$IFNDEF STAND_ALONE}
  FProject := AProject;
{$ENDIF}
end;

destructor TCnEmptyUsesInfo.Destroy;
begin
  FIntfItems.Free;
  FImplItems.Free;
  inherited;
end;

{$IFNDEF STAND_ALONE}

function TCnEmptyUsesInfo.Process: Boolean;
var
  Info: TCnUnitUsesInfo; // 存储 DCU 文件中解析出来的 uses 内容列表
  UsesList: TStringList; // 存储源码中解析出来的 uses 内容列表
  Stream: TMemoryStream;
  Item: TCnUsesItem;
  I: Integer;

  function UnitUsesListContainsUnitName({$IFNDEF SUPPORT_UNITNAME_DOT} const
    {$ENDIF} DcuName: string): Boolean;
{$IFDEF SUPPORT_UNITNAME_DOT}
  var
    K: Integer;
{$ENDIF}
  begin
    Result := UsesList.IndexOf(DcuName) >= 0;
{$IFDEF SUPPORT_UNITNAME_DOT}
    // 如果没找到，则判断点号，使用 DcuName 最后一个点的后面部分搜索
    if not Result then
    begin
      K := LastCharPos(DcuName, '.');
      if K > 0 then
      begin
        Delete(DcuName, 1, K);
        Result := UsesList.IndexOf(DcuName) >= 0;
      end;
    end;
{$ENDIF}
  end;

begin
  Result := False;
  try
    Info := TCnUnitUsesInfo.Create(DcuName);
    try
      Info.Sort;
      UsesList := TStringList.Create;
      try
        Stream := TMemoryStream.Create;
        try
          EditFilerSaveFileToStream(FSourceFileName, Stream, True); // Ansi/Ansi/Utf16
{$IFDEF UNICODE}
          ParseUnitUsesW(PChar(Stream.Memory), UsesList);
{$ELSE}
          ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);
{$ENDIF}
        finally
          Stream.Free;
        end;

        // 注意从源码里 UsesList 解析出来的单元名可能是不带点的，
        // 而 Dcu 里解析出来的 Info 里的则是带点的，简单匹配不够
        for I := 0 to Info.IntfUsesCount - 1 do
        begin
          if (Info.IntfUsesImport[I].Count = 0) and
            UnitUsesListContainsUnitName(Info.IntfUses[I]) then
          begin
            Item := TCnUsesItem.Create;
            Item.Name := Info.IntfUses[I];
            FIntfItems.Add(Item);
          end;
        end;

        for I := 0 to Info.ImplUsesCount - 1 do
        begin
          if (Info.ImplUsesImport[I].Count = 0) and
            UnitUsesListContainsUnitName(Info.ImplUses[I]) then
          begin
            Item := TCnUsesItem.Create;
            Item.Name := Info.ImplUses[I];
            FImplItems.Add(Item);
          end;
        end;
        Result := True;
      finally
        UsesList.Free;
      end;
    finally
      Info.Free;
    end;
  except
    on E: Exception do
      DoHandleException('Dcu32 UsesInfo ' + E.Message);
  end;
end;

{$ENDIF}

function TCnEmptyUsesInfo.GetImplCount: Integer;
begin
  Result := FImplItems.Count;
end;

function TCnEmptyUsesInfo.GetImplItem(Index: Integer): TCnUsesItem;
begin
  Result := TCnUsesItem(FImplItems[Index]);
end;

function TCnEmptyUsesInfo.GetIntfCount: Integer;
begin
  Result := FIntfItems.Count;
end;

function TCnEmptyUsesInfo.GetIntfItem(Index: Integer): TCnUsesItem;
begin
  Result := TCnUsesItem(FIntfItems[Index]);
end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.

