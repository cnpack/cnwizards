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

unit CnWizIni;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Ansi ��ʽ����� IniFile �滻��Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��
* ����ƽ̨��PWinXP SP3 + Delphi 2009
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2016.02.22 V1.1
*               ����һ�� CnWizIni ʵ���࣬�ɿ����Ƿ񻺴����
*           2008.08.06 V1.0
*               ������Ԫ
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
  {* ������д��ֵ�� Default ���ʱ�Ƿ�����д��Ĺ��ܣ������� Section ֵ}
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
  if FDefaultsMap = nil then                       // ������Ĭ��ֵ��д
    inherited WriteDate(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteDate(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteDate(Section, Name, Value)
  else if not DoubleEqual(ReadDate(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteDate(Section, Name, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

procedure TCnWizIniFile.WriteDateTime(const Section, Name: string;
  Value: TDateTime);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // ������Ĭ��ֵ��д
    inherited WriteDateTime(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteDateTime(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteDateTime(Section, Name, Value)
  else if not DoubleEqual(ReadDateTime(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteDateTime(Section, Name, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

procedure TCnWizIniFile.WriteFloat(const Section, Name: string;
  Value: Double);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // ������Ĭ��ֵ��д
    inherited WriteFloat(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteFloat(Section, Name, Value)
  else if not DoubleEqual(Value, AValue) then      // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteFloat(Section, Name, Value)
  else if not DoubleEqual(ReadFloat(Section, Name, AValue), Value) then
    inherited WriteFloat(Section, Name, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

procedure TCnWizIniFile.WriteInteger(const Section, Ident: string;
  Value: Integer);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                        // ������Ĭ��ֵ��д
    inherited WriteInteger(Section, Ident, Value)
  else if not FDefaultsMap.Find(Ident, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteInteger(Section, Ident, Value)
  else if Value <> Integer(AValue) then       // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteInteger(Section, Ident, Value)
  else if ReadInteger(Section, Ident, AValue) <> Value then
    inherited WriteInteger(Section, Ident, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

procedure TCnWizIniFile.WriteString(const Section, Ident, Value: string);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                        // ������Ĭ��ֵ��д
    inherited WriteString(Section, Ident, Value)
  else if not FDefaultsMap.Find(Ident, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteString(Section, Ident, Value)
  else if Value <> VarToStr(AValue) then       // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteString(Section, Ident, Value)
  else if ReadString(Section, Ident, AValue) <> Value then
    inherited WriteString(Section, Ident, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

procedure TCnWizIniFile.WriteTime(const Section, Name: string;
  Value: TDateTime);
var
  AValue: Variant;
begin
  if FDefaultsMap = nil then                       // ������Ĭ��ֵ��д
    inherited WriteTime(Section, Name, Value)
  else if not FDefaultsMap.Find(Name, AValue) then // ������û��Ĭ��ֵҲд
    inherited WriteTime(Section, Name, Value)
  else if not DoubleEqual(Value, VarToDateTime(AValue)) then      // �����Ĭ��ֵ��Ҫд��ֵ��ͬҲд
    inherited WriteTime(Section, Name, Value)
  else if not DoubleEqual(ReadTime(Section, Name, VarToDateTime(AValue)), Value) then
    inherited WriteTime(Section, Name, Value)
  // �����Ĭ��ֵ��Ҫд��ֵ��ͬ����ʵ�ʴ洢�Ĳ������ֵ��Ҳ��д
end;

end.
