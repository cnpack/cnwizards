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

unit CnPrefixList;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ǰ׺ר���б��嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע�����ǰ׺ר���б��嵥Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.04.26 V1.0
*               ������Ԫ
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
    {* �����������Ҷ�Ӧǰ׺}
    property Ignore[ComponentClass: string]: Boolean read GetIgnore write SetIgnore;
    {* ��������������ЩҪ����ǰ׺}
    property PrefixsWithParent[ComponentClass: TClass]: string read GetPrefixsWithParent;
    {* �����༰�丸������������ TObject ��ƥ��ǰ׺}
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
    if R <> '' then  // �����ҵ�ҲҪ�����ң��Ծ����������� TObject ��ƥ��ǰ׺
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
