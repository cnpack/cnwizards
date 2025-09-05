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

{ TCnPrefixItem }

  TCnPrefixItem = class(TObject)
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

{ TCnPrefixList }

  TCnPrefixList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetIgnore(ComponentClass: string): Boolean;
    function GetItem(Index: Integer): TCnPrefixItem;
    function GetPrefix(ComponentClass: string): string;
    procedure SetIgnore(ComponentClass: string; const Value: Boolean);
    procedure SetPrefix(ComponentClass: string; const Value: string);
    function GetPrefixsWithParent(ComponentClass: TClass): string;
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

    property Items[Index: Integer]: TCnPrefixItem read GetItem; default;
    property Count: Integer read GetCount;
    property Prefixs[ComponentClass: string]: string read GetPrefix write SetPrefix;
    {* 根据类名查找对应前缀}
    property Ignore[ComponentClass: string]: Boolean read GetIgnore write SetIgnore;
    {* 根据类名查找哪些要忽略前缀}
    property PrefixsWithParent[ComponentClass: TClass]: string read GetPrefixsWithParent;
    {* 根据类及其父类查找最靠近顶级 TObject 的匹配前缀}
  end;

{ TCnPrefixCompItem }

  TCnPrefixCompItem = class(TObject)
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

{ TCnPrefixCompList }

  TCnPrefixCompList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCnPrefixCompItem;
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
    property Items[Index: Integer]: TCnPrefixCompItem read GetItem; default;
  end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{ TCnPrefixItem }

procedure TCnPrefixItem.SetPrefix(const Value: string);
begin
  if (Value <> '') and IsValidIdent(Value) then
  begin
    FPrefix := Value;
  end
  else
    FPrefix := '';
end;

{ TCnPrefixList }

function TCnPrefixList.Add(const ComponentClass, Prefix: string;
  Ignore: Boolean): Integer;
var
  Item: TCnPrefixItem;
begin
  Result := IndexOf(ComponentClass);
  if Result < 0 then
  begin
    Item := TCnPrefixItem.Create;
    Result := FList.Add(Item);
  end
  else
    Item := Items[Result];

  Item.ComponentClass := ComponentClass;
  Item.Prefix := Prefix;
  Item.Ignore := Ignore;
end;

procedure TCnPrefixList.Clear;
begin
  FList.Clear;
end;

constructor TCnPrefixList.Create;
begin
  FList := TObjectList.Create;
end;

procedure TCnPrefixList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TCnPrefixList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnPrefixList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPrefixList.GetIgnore(ComponentClass: string): Boolean;
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Result := Items[Idx].Ignore
  else
    Result := False;
end;

function TCnPrefixList.GetItem(Index: Integer): TCnPrefixItem;
begin
  Result := TCnPrefixItem(FList[Index]);
end;

function TCnPrefixList.GetPrefix(ComponentClass: string): string;
var
  Idx: Integer;
begin
  Idx := IndexOf(ComponentClass);
  if Idx >= 0 then
    Result := Items[Idx].Prefix
  else
    Result := '';
end;

function TCnPrefixList.GetPrefixsWithParent(ComponentClass: TClass): string;
var
  S, R: string;
begin
  repeat
    S := ComponentClass.ClassName;

    R := Prefixs[S];
    if R <> '' then  // 哪怕找到也要往下找，以尽量靠近顶级 TObject 的匹配前缀
      Result := R;

    ComponentClass := ComponentClass.ClassParent;
  until ComponentClass = nil;
end;

function TCnPrefixList.IndexOf(const ComponentClass: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if SameText(Items[I].ComponentClass, ComponentClass) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

const
  csPrefix = 'Prefix';
  csIgnore = 'Ignore';

function TCnPrefixList.LoadFromFile(const FileName: string): Boolean;
var
  I: Integer;
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

      for I := 0 to Strs.Count - 1 do
        Add(Strs[I], ReadString(csPrefix, Strs[I], ''),
          ReadBool(csIgnore, Strs[I], False));
      Result := True;
    finally
      Strs.Free;
    end;
  finally
    Free;
  end;
end;

function TCnPrefixList.SaveToFile(const FileName: string): Boolean;
var
  I: Integer;
begin
  try
    with TMemIniFile.Create(FileName) do
    try
      for I := 0 to Count - 1 do
      begin
        if (Items[I].Prefix <> '') or Items[I].Ignore then
        begin
          if Items[I].Prefix <> '' then
            WriteString(csPrefix, Items[I].ComponentClass, Items[I].Prefix);
          if Items[I].Ignore then
            WriteBool(csIgnore, Items[I].ComponentClass, Items[I].Ignore)
          else
            DeleteKey(csIgnore, Items[I].ComponentClass);
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

procedure TCnPrefixList.SetIgnore(ComponentClass: string;
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

procedure TCnPrefixList.SetPrefix(ComponentClass: string;
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

{ TCnPrefixCompList }

function TCnPrefixCompList.Add(const AProjectName: string; AFormEditor: IOTAFormEditor;
  AComponent: TComponent; const APrefix, AOldName, ANewName: string): Integer;
var
  Item: TCnPrefixCompItem;
begin
  Item := TCnPrefixCompItem.Create;
  Item.FActive := True;
  Item.FProjectName := AProjectName;
  Item.FFormEditor := AFormEditor;
  Item.FComponent := AComponent;
  Item.FPrefix := APrefix;
  Item.FOldName := AOldName;
  Item.FNewName := ANewName;
  Result := FList.Add(Item);
end;

procedure TCnPrefixCompList.Clear;
begin
  FList.Clear;
end;

constructor TCnPrefixCompList.Create;
begin
  FList := TObjectList.Create;
end;

procedure TCnPrefixCompList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TCnPrefixCompList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnPrefixCompList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPrefixCompList.GetItem(Index: Integer): TCnPrefixCompItem;
begin
  Result := TCnPrefixCompItem(FList[Index]);
end;

function TCnPrefixCompList.IndexOfComponent(AFormEditor: IOTAFormEditor;
  AComponent: TComponent): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (Items[I].FFormEditor = AFormEditor) and (Items[I].FComponent = AComponent) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnPrefixCompList.IndexOfNewName(AFormEditor: IOTAFormEditor;
  ANewName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (Items[I].FFormEditor = AFormEditor) and SameText(Items[I].FNewName,
      ANewName) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
