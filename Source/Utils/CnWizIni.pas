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

unit CnWizIni;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Ansi 方式保存的 IniFile 替换单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 2009
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2016.02.22 V1.1
*               加入一个 CnWizIni 实现类，可控制是否缓存更新
*           2008.08.06 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, IniFiles, Registry,
  {$IFDEF FPC} Variants, CnRegIni, {$ENDIF}
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  {$IFDEF UNICODE} RTLConsts, {$ENDIF}
  CnCommon, CnHashMap;

type

{$IFDEF UNICODE}

  TCnAnsiMemIniFile = class(TMemIniFile)
  public
    procedure UpdateFile; override;
  end;

  TCnAnsiIniFile = class(TCnAnsiMemIniFile)
  public
    destructor Destroy; override;
  end;

  TMemIniFile = TCnAnsiMemIniFile;

  TIniFile = TCnAnsiIniFile;
  
{$ENDIF}

  TCnWizIniFile = class({$IFDEF FPC} TCnRegistryIniFile {$ELSE} TRegistryIniFile {$ENDIF})
  {* 带控制写入值和 Default 相等时是否真正写入的功能，但忽略 Section 值}
  private
    FDefaultsMap: TCnBaseHashMap;
  public
    constructor Create(const FileName: string; DefaultsMap: TCnBaseHashMap = nil);
      overload;
    constructor Create(const FileName: string; AAccess: LongWord; DefaultsMap:
      TCnBaseHashMap = nil); overload;
    destructor Destroy; override;

    function ReadDate(const Section, Name: string; Default: TDateTime): TDateTime; override;
    function ReadDateTime(const Section, Name: string; Default: TDateTime): TDateTime; override;
    function ReadInteger(const Section, Ident: string; Default: Longint): Longint; override;
    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    function ReadString(const Section, Ident, Default: string): string; override;
    function ReadTime(const Section, Name: string; Default: TDateTime): TDateTime; override;
    procedure WriteDate(const Section, Name: string; Value: TDateTime); override;
    procedure WriteDateTime(const Section, Name: string; Value: TDateTime); override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;
    procedure WriteInteger(const Section, Ident: string; Value: Longint); override;
    procedure WriteString(const Section, Ident, Value: string); override;
    procedure WriteTime(const Section, Name: string; Value: TDateTime); override;
  end;

implementation

{$IFDEF UNICODE}
  
{ TCnAnsiMemIniFile }

procedure TCnAnsiMemIniFile.UpdateFile;
var
  List: TStringList;
  Text: AnsiString;
  Stream: TFileStream;
begin
  List := TStringList.Create;
  try
    GetStrings(List);
    Text := AnsiString(List.Text);
  finally
    List.Free;
  end;

  Stream := TFileStream.Create(FileName, fmCreate);
  try
    Stream.WriteBuffer(PAnsiChar(Text)^, Length(Text));
  finally
    Stream.Free;
  end;
end;

{ TCnAnsiIniFile }

destructor TCnAnsiIniFile.Destroy;
begin
  UpdateFile;
  inherited;
end;

{$ENDIF}

{ TCnWizIniFile }

constructor TCnWizIniFile.Create(const FileName: string;
  DefaultsMap: TCnBaseHashMap);
begin
  inherited Create(FileName);
  FDefaultsMap := DefaultsMap;
end;

constructor TCnWizIniFile.Create(const FileName: string; AAccess: LongWord;
  DefaultsMap: TCnBaseHashMap);
begin
  inherited Create(FileName, AAccess);
  FDefaultsMap := DefaultsMap;
end;

destructor TCnWizIniFile.Destroy;
begin

  inherited;
end;

function TCnWizIniFile.ReadDate(const Section, Name: string;
  Default: TDateTime): TDateTime;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Name, Default);

  Result := inherited ReadDate(Section, Name, Default);
end;

function TCnWizIniFile.ReadDateTime(const Section, Name: string;
  Default: TDateTime): TDateTime;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Name, Default);

  Result := inherited ReadDateTime(Section, Name, Default);
end;

function TCnWizIniFile.ReadFloat(const Section, Name: string;
  Default: Double): Double;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Name, Default);

  Result := inherited ReadFloat(Section, Name, Default);
end;

function TCnWizIniFile.ReadInteger(const Section, Ident: string;
  Default: Integer): Longint;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Ident, Default);

  Result := inherited ReadInteger(Section, Ident, Default);
end;

function TCnWizIniFile.ReadString(const Section, Ident,
  Default: string): string;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Ident, Default);

  Result := inherited ReadString(Section, Ident, Default);
end;

function TCnWizIniFile.ReadTime(const Section, Name: string;
  Default: TDateTime): TDateTime;
begin
  if FDefaultsMap <> nil then
    FDefaultsMap.Add(Name, Default);

  Result := inherited ReadTime(Section, Name, Default);
end;

procedure TCnWizIniFile.WriteDate(const Section, Name: string;
  Value: TDateTime);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // 不缓存默认值就写
    inherited WriteDate(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // 缓存里没有默认值也写
    inherited WriteDate(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // 缓存的默认值和要写的值不同也写
    inherited WriteDate(Section, Name, Value)
  else if not DoubleEqual(ReadDate(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteDate(Section, Name, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

procedure TCnWizIniFile.WriteDateTime(const Section, Name: string;
  Value: TDateTime);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // 不缓存默认值就写
    inherited WriteDateTime(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // 缓存里没有默认值也写
    inherited WriteDateTime(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // 缓存的默认值和要写的值不同也写
    inherited WriteDateTime(Section, Name, Value)
  else if not DoubleEqual(ReadDateTime(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteDateTime(Section, Name, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

procedure TCnWizIniFile.WriteFloat(const Section, Name: string;
  Value: Double);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // 不缓存默认值就写
    inherited WriteFloat(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // 缓存里没有默认值也写
    inherited WriteFloat(Section, Name, Value)
  else if not DoubleEqual(Value, AValue) then      // 缓存的默认值和要写的值不同也写
    inherited WriteFloat(Section, Name, Value)
  else if not DoubleEqual(ReadFloat(Section, Name, AValue), Value) then
    inherited WriteFloat(Section, Name, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

procedure TCnWizIniFile.WriteInteger(const Section, Ident: string;
  Value: Integer);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                        // 不缓存默认值就写
    inherited WriteInteger(Section, Ident, Value)
  else if not FDefaultsMap.Find(Ident, AValue) then // 缓存里没有默认值也写
    inherited WriteInteger(Section, Ident, Value)
  else if Value <> Integer(AValue) then       // 缓存的默认值和要写的值不同也写
    inherited WriteInteger(Section, Ident, Value)
  else if ReadInteger(Section, Ident, AValue) <> Value then
    inherited WriteInteger(Section, Ident, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

procedure TCnWizIniFile.WriteString(const Section, Ident, Value: string);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                        // 不缓存默认值就写
    inherited WriteString(Section, Ident, Value)
  else if not FDefaultsMap.Find(Ident, AValue) then // 缓存里没有默认值也写
    inherited WriteString(Section, Ident, Value)
  else if Value <> VarToStr(AValue) then       // 缓存的默认值和要写的值不同也写
    inherited WriteString(Section, Ident, Value)
  else if ReadString(Section, Ident, AValue) <> Value then
    inherited WriteString(Section, Ident, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

procedure TCnWizIniFile.WriteTime(const Section, Name: string;
  Value: TDateTime);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // 不缓存默认值就写
    inherited WriteTime(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // 缓存里没有默认值也写
    inherited WriteTime(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // 缓存的默认值和要写的值不同也写
    inherited WriteTime(Section, Name, Value)
  else if not DoubleEqual(ReadTime(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteTime(Section, Name, Value)
  // 缓存的默认值和要写的值相同，但实际存储的不是这个值，也得写
end;

end.
