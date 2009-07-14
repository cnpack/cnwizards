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

unit CnPrefixList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家列表定义单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家列表定义单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.04.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Contnrs, IniFiles, ToolsAPI, CnWizIni;

type

{ TPrefixItem }

  TPrefixItem = class(TObject)
  private
    FIgnore: Boolean;
    FPrefix: string;
    FComponentClass: string;
    procedure SetPrefix(const Value: string);
  public
    property ComponentClass: string read FComponentClass write FComponentClass;
    property Prefix: string read FPrefix write SetPrefix;
    property Ignore: Boolean read FIgnore write FIgnore;
  end;

{ TPrefixList }

  TPrefixList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetIgnore(ComponentClass: string): Boolean;
    function GetItem(Index: Integer): TPrefixItem;
    function GetPrefix(ComponentClass: string): string;
    procedure SetIgnore(ComponentClass: string; const Value: Boolean);
    procedure SetPrefix(ComponentClass: string; const Value: string);
  protected

  public
    constructor Create;
    destructor Destroy; override;
    function IndexOf(const ComponentClass: string): Integer;
    function Add(const ComponentClass, Prefix: string; Ignore: Boolean = False): Integer;
    procedure Delete(Index: Integer);
    procedure Clear;
    function LoadFromFile(const FileName: string): Boolean;
    function SaveToFile(const FileName: string): Boolean;

    property Items[Index: Integer]: TPrefixItem read GetItem; default;
    property Count: Integer read GetCount;
    property Prefixs[ComponentClass: string]: string read GetPrefix write SetPrefix;
    property Ignore[ComponentClass: string]: Boolean read GetIgnore write SetIgnore;
  end;

{ TCompItem }

  TCompItem = class(TObject)
  private
    FActive: Boolean;
    FFormEditor: IOTAFormEditor;
    FComponent: TComponent;
    FPrefix: string;
    FOldName: string;
    FNewName: string;
    FProjectName: string;
  public
    property Active: Boolean read FActive write FActive;
    property ProjectName: string read FProjectName write FProjectName;
    property FormEditor: IOTAFormEditor read FFormEditor write FFormEditor;
    property Component: TComponent read FComponent write FComponent;
    property Prefix: string read FPrefix write FPrefix;
    property OldName: string read FOldName write FOldName;
    property NewName: string read FNewName write FNewName;
  end;

{ TCompList }

  TCompList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCompItem;
  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AProjectName: string; AFormEditor: IOTAFormEditor;
      AComponent: TComponent; const APrefix, AOldName, ANewName: string): Integer;
    procedure Delete(Index: Integer);
    procedure Clear;
    function IndexOfNewName(AFormEditor: IOTAFormEditor; ANewName: string): Integer;
    function IndexOfComponent(AFormEditor: IOTAFormEditor; AComponent: TComponent): Integer;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCompItem read GetItem; default;
  end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{ TPrefixItem }

procedure TPrefixItem.SetPrefix(const Value: string);
begin
  if (Value <> '') and IsValidIdent(Value) then
  begin
    FPrefix := Value;
  end
  else
    FPrefix := '';
end;

{ TPrefixList }

function TPrefixList.Add(const ComponentClass, Prefix: string;
  Ignore: Boolean): Integer;
var
  Item: TPrefixItem;
begin
  Result := IndexOf(ComponentClass);
  if Result < 0 then
  begin
    Item := TPrefixItem.Create;
    Result := FList.Add(Item);
  end
  else
    Item := Items[Result];

  Item.ComponentClass := ComponentClass;
  Item.Prefix := Prefix;
  Item.Ignore := Ignore;
end;

procedure TPrefixList.Clear;
begin
  FList.Clear;
end;

constructor TPrefixList.Create;
begin
  FList := TObjectList.Create;
end;

procedure TPrefixList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TPrefixList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TPrefixList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPrefixList.GetIgnore(ComponentClass: string): Boolean;
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Result := Items[Idx].Ignore
  else
    Result := False;
end;

function TPrefixList.GetItem(Index: Integer): TPrefixItem;
begin
  Result := TPrefixItem(FList[Index]);
end;

function TPrefixList.GetPrefix(ComponentClass: string): string;
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Result := Items[Idx].Prefix
  else
    Result := '';
end;

function TPrefixList.IndexOf(const ComponentClass: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameText(Items[i].ComponentClass, ComponentClass) then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

const
  csPrefix = 'Prefix';
  csIgnore = 'Ignore';

function TPrefixList.LoadFromFile(const FileName: string): Boolean;
var
  i: Integer;
  Strs: TStrings;
begin
  Result := False;
  Clear;
  if not FileExists(FileName) then Exit;

  with TMemIniFile.Create(FileName) do
  try
    Strs := TStringList.Create;
    try
      ReadSection(csPrefix, Strs);

      for i := 0 to Strs.Count - 1 do
        Add(Strs[i], ReadString(csPrefix, Strs[i], ''),
          ReadBool(csIgnore, Strs[i], False));
      Result := True;
    finally
      Strs.Free;
    end;
  finally
    Free;
  end;
end;

function TPrefixList.SaveToFile(const FileName: string): Boolean;
var
  i: Integer;
begin
  try
    with TMemIniFile.Create(FileName) do
    try
      for i := 0 to Count - 1 do
      begin
        if (Items[i].Prefix <> '') or Items[i].Ignore then
        begin
          if Items[i].Prefix <> '' then
            WriteString(csPrefix, Items[i].ComponentClass, Items[i].Prefix);
          if Items[i].Ignore then
            WriteBool(csIgnore, Items[i].ComponentClass, Items[i].Ignore)
          else
            DeleteKey(csIgnore, Items[i].ComponentClass);
        end;
      end;

      UpdateFile;
      Result := True;
    finally
      Free;
    end;
  except
    Result := False;
  end;
end;

procedure TPrefixList.SetIgnore(ComponentClass: string;
  const Value: Boolean);
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Items[Idx].Ignore := Value
  else if Value then
    Add(ComponentClass, '', Value);
end;

procedure TPrefixList.SetPrefix(ComponentClass: string;
  const Value: string);
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Items[Idx].Prefix := Value
  else
    Add(ComponentClass, Value);
end;

{ TCompList }

function TCompList.Add(const AProjectName: string; AFormEditor: IOTAFormEditor;
  AComponent: TComponent; const APrefix, AOldName, ANewName: string): Integer;
var
  Item: TCompItem;
begin
  Item := TCompItem.Create;
  Item.FActive := True;
  Item.FProjectName := AProjectName;
  Item.FFormEditor := AFormEditor;
  Item.FComponent := AComponent;
  Item.FPrefix := APrefix;
  Item.FOldName := AOldName;
  Item.FNewName := ANewName;
  Result := FList.Add(Item);
end;

procedure TCompList.Clear;
begin
  FList.Clear;
end;

constructor TCompList.Create;
begin
  FList := TObjectList.Create;
end;

procedure TCompList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TCompList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCompList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCompList.GetItem(Index: Integer): TCompItem;
begin
  Result := TCompItem(FList[Index]);
end;

function TCompList.IndexOfComponent(AFormEditor: IOTAFormEditor;
  AComponent: TComponent): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if (Items[i].FFormEditor = AFormEditor) and (Items[i].FComponent = AComponent) then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;

end;

function TCompList.IndexOfNewName(AFormEditor: IOTAFormEditor;
  ANewName: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if (Items[i].FFormEditor = AFormEditor) and SameText(Items[i].FNewName,
      ANewName) then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
