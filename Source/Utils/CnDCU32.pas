{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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
* 单元标识：$Id$
* 修改记录：2005.08.11 v1.0
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESCLEANER}

uses
  Windows, Classes, SysUtils, DCURecs, DCU32, DCU_Out, ToolsAPI, Contnrs,
  CnWizUtils, CnPasCodeParser, CnWizConsts;

type

{ TCnUnitUsesInfo }

  TCnUnitUsesInfo = class(TUnit)
  private
    FIntfUses: TStringList;
    FImplUses: TStringList;
    function GetImplUse(Index: Integer): string;
    function GetImplUsesCount: Integer;
    function GetImplUsesImport(Index: Integer): TStrings;
    function GetIntfUse(Index: Integer): string;
    function GetIntfUsesCount: Integer;
    function GetIntfUsesImport(Index: Integer): TStrings;
    procedure GetUsesList(AList: TStringList; AFlag: TUnitImpFlags);
    procedure ClearUsesList(AList: TStringList);
  public
    constructor Create(const DcuName: string);
    destructor Destroy; override;
    procedure Sort;
    
    property IntfUsesCount: Integer read GetIntfUsesCount;
    property IntfUses[Index: Integer]: string read GetIntfUse;
    property IntfUsesImport[Index: Integer]: TStrings read GetIntfUsesImport;

    property ImplUsesCount: Integer read GetImplUsesCount;
    property ImplUses[Index: Integer]: string read GetImplUse;
    property ImplUsesImport[Index: Integer]: TStrings read GetImplUsesImport;
  end;

{ TCnUsesItem }

  TCnUsesKind = (ukHasInitSection, ukHasRegProc, ukInCleanList, ukInIgnoreList,
    ukNoSource, tkCompRef);
  TCnUsesKinds = set of TCnUsesKind;

  TCnUsesItem = class
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
  private
    FBuffer: IOTAEditBuffer;
    FProject: IOTAProject;
    FDcuName: string;
    FIntfItems: TObjectList;
    FImplItems: TObjectList;
    function GetImplCount: Integer;
    function GetImplItem(Index: Integer): TCnUsesItem;
    function GetIntfCount: Integer;
    function GetIntfItem(Index: Integer): TCnUsesItem;
  public
    constructor Create(const ADcuName: string; ABuffer: IOTAEditBuffer; AProject:
      IOTAProject);
    destructor Destroy; override;
    function Process: Boolean;
    property DcuName: string read FDcuName;
    property Buffer: IOTAEditBuffer read FBuffer;
    property Project: IOTAProject read FProject;
    property IntfCount: Integer read GetIntfCount;
    property IntfItems[Index: Integer]: TCnUsesItem read GetIntfItem;
    property ImplCount: Integer read GetImplCount;
    property ImplItems[Index: Integer]: TCnUsesItem read GetImplItem;
  end;

{$ENDIF CNWIZARDS_CNUSESCLEANER}

implementation

{$IFDEF CNWIZARDS_CNUSESCLEANER}

uses
  CnWizEditFiler;

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

constructor TCnUnitUsesInfo.Create(const DcuName: string);
begin
  InitOut;
  FIntfUses := TStringList.Create;
  FImplUses := TStringList.Create;
  inherited Create;
  try
    Load(DcuName, 0, False, nil, True);
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
    AList.AddObject({$IFDEF DELPHI2009_UP}string{$ENDIF}(PRec^.Name^), Lines);

    Decl := PRec^.Decls;
    while Decl <> nil do
    begin
      if Decl is TImpDef then
        Lines.Add(TImpDef(Decl).ik + ':' + {$IFDEF DELPHI2009_UP}string{$ENDIF}(Decl.Name^))
      else
        Lines.Add({$IFDEF DELPHI2009_UP}string{$ENDIF}(Decl.Name^));
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

constructor TCnEmptyUsesInfo.Create(const ADcuName: string; ABuffer: 
  IOTAEditBuffer; AProject: IOTAProject);
begin
  inherited Create;
  FIntfItems := TObjectList.Create;
  FImplItems := TObjectList.Create;
  FDcuName := ADcuName;
  FBuffer := ABuffer;
  FProject := AProject;
end;

destructor TCnEmptyUsesInfo.Destroy;
begin
  FIntfItems.Free;
  FImplItems.Free;
  inherited;
end;

function TCnEmptyUsesInfo.Process: Boolean;
var
  Info: TCnUnitUsesInfo;
  UsesList: TStringList;
  Stream: TMemoryStream;
  Item: TCnUsesItem;
  i: Integer;
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
          EditFilerSaveFileToStream(Buffer.FileName, Stream);
          // CnOtaSaveEditorToStream(Buffer, Stream);
          ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);
        finally
          Stream.Free;
        end;

        for i := 0 to Info.IntfUsesCount - 1 do
          if (Info.IntfUsesImport[i].Count = 0) and
            (UsesList.IndexOf(Info.IntfUses[i]) >= 0) then
          begin
            Item := TCnUsesItem.Create;
            Item.Name := Info.IntfUses[i];
            FIntfItems.Add(Item);
          end;

        for i := 0 to Info.ImplUsesCount - 1 do
          if (Info.ImplUsesImport[i].Count = 0) and
            (UsesList.IndexOf(Info.ImplUses[i]) >= 0) then
          begin
            Item := TCnUsesItem.Create;
            Item.Name := Info.ImplUses[i];
            FImplItems.Add(Item);
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
      DoHandleException(E.Message);
  end;
end;

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

{$ENDIF CNWIZARDS_CNUSESCLEANER}
end.
