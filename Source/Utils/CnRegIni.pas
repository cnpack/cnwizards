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

unit CnRegIni;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Lazarus 下的 TRegistryIniFile 修改单元
* 单元作者：CnPack 开发组
* 备    注：Lazarus 下的 TRegistryIniFile 默认 LazyWrite 为 True，读取后 Free
*           会重复 CloseKey 导致出错，这里拎出来整一个修改版，实质内容仅用于 Lazarus
*           Delphi 中会重定义至系统库
*           注意不要包含我们的 inc
* 开发平台：PWin7 + Lazarus 4.0
* 兼容测试：PWin7 + Lazarus 4.0
* 本 地 化：无
* 修改记录：2025.07.01 V1.0
*                从 Lazarus 运行库移植而来修改
================================================================================
|</PRE>}

interface

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}

uses
  Classes, SysUtils, Windows, Registry, IniFiles;

type
{$IFDEF FPC}
  TCnRegistry = class(TObject)
  private
    FLastError: Longint;
    FStringSizeIncludesNull: Boolean;
    FSysData: Pointer;
    FAccess: LongWord;
    FCurrentKey: HKEY;
    FRootKey: HKEY;
    FLazyWrite: Boolean;
    FCurrentPath: UnicodeString;
    function FixPath(APath: UnicodeString): UnicodeString;
    function GetLastErrorMsg: string;
    function RegMultiSzDataToUnicodeStringArray(U: UnicodeString): TUnicodeStringArray;
    function ListToArray(List: TStrings; IsUtf8: Boolean): TUnicodeStringArray;
    procedure ArrayToList(const Arr: TUnicodeStringArray; List: TStrings;
      ForceUtf8: Boolean);
    procedure SetRootKey(Value: HKEY);
    procedure SysRegCreate;
    procedure SysRegFree;
    function SysGetData(const Name: UnicodeString; Buffer: Pointer; BufSize:
      Integer; out RegData: TRegDataType): Integer;
    function SysPutData(const Name: UnicodeString; Buffer: Pointer; BufSize:
      Integer; RegData: TRegDataType): Boolean;
    function SysCreateKey(Key: UnicodeString): Boolean;
  protected
    function GetBaseKey(Relative: Boolean): HKey;
    function GetData(const Name: UnicodeString; Buffer: Pointer; BufSize:
      Integer; out RegData: TRegDataType): Integer;
    function GetData(const Name: string; Buffer: Pointer; BufSize: Integer; out
      RegData: TRegDataType): Integer;
    function GetKey(Key: UnicodeString): HKEY;
    function GetKey(Key: string): HKEY;
    procedure ChangeKey(Value: HKey; const Path: UnicodeString);
    procedure ChangeKey(Value: HKey; const Path: string);
    procedure PutData(const Name: UnicodeString; Buffer: Pointer; BufSize:
      Integer; RegData: TRegDataType);
    procedure PutData(const Name: string; Buffer: Pointer; BufSize: Integer;
      RegData: TRegDataType);
    procedure SetCurrentKey(Value: HKEY);
  public
    constructor Create; overload;
    constructor Create(aaccess: longword); overload;
    destructor Destroy; override;

    function CreateKey(const Key: UnicodeString): Boolean;
    function CreateKey(const Key: string): Boolean;
    function DeleteKey(const Key: UnicodeString): Boolean;
    function DeleteKey(const Key: string): Boolean;
    function DeleteValue(const Name: UnicodeString): Boolean;
    function DeleteValue(const Name: string): Boolean;
    function GetDataInfo(const ValueName: UnicodeString; out Value: TRegDataInfo):
      Boolean;
    function GetDataInfo(const ValueName: string; out Value: TRegDataInfo): Boolean;
    function GetDataSize(const ValueName: UnicodeString): Integer;
    function GetDataSize(const ValueName: string): Integer;
    function GetDataType(const ValueName: UnicodeString): TRegDataType;
    function GetDataType(const ValueName: string): TRegDataType;
    function GetKeyInfo(out Value: TRegKeyInfo): Boolean;
    function HasSubKeys: Boolean;
    function KeyExists(const Key: UnicodeString): Boolean;
    function KeyExists(const Key: string): Boolean;
    function LoadKey(const Key, FileName: UnicodeString): Boolean;
    function LoadKey(const Key, FileName: string): Boolean;
    function OpenKey(const Key: UnicodeString; CanCreate: Boolean): Boolean;
    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
    function OpenKeyReadOnly(const Key: UnicodeString): Boolean;
    function OpenKeyReadOnly(const Key: string): Boolean;
    function ReadCurrency(const Name: UnicodeString): Currency;
    function ReadCurrency(const Name: string): Currency;
    function ReadBinaryData(const Name: UnicodeString; var Buffer; BufSize:
      Integer): Integer;
    function ReadBinaryData(const Name: string; var Buffer; BufSize: Integer): Integer;
    function ReadBool(const Name: UnicodeString): Boolean;
    function ReadBool(const Name: string): Boolean;
    function ReadDate(const Name: UnicodeString): TDateTime;
    function ReadDate(const Name: string): TDateTime;
    function ReadDateTime(const Name: UnicodeString): TDateTime;
    function ReadDateTime(const Name: string): TDateTime;
    function ReadFloat(const Name: UnicodeString): Double;
    function ReadFloat(const Name: string): Double;
    function ReadInteger(const Name: UnicodeString): Integer;
    function ReadInteger(const Name: string): Integer;
    function ReadInt64(const Name: UnicodeString): Int64;
    function ReadInt64(const Name: string): Int64;
    function ReadString(const Name: UnicodeString): UnicodeString;
    function ReadString(const Name: string): string;
    procedure ReadStringList(const Name: UnicodeString; AList: TStrings;
      ForceUtf8: Boolean = False);
    procedure ReadStringList(const Name: string; AList: TStrings);
    function ReadStringArray(const Name: UnicodeString): TUnicodeStringArray;
    function ReadStringArray(const Name: string): TStringArray;
    function ReadTime(const Name: UnicodeString): TDateTime;
    function ReadTime(const Name: string): TDateTime;
    function RegistryConnect(const UNCName: UnicodeString): Boolean;
    function RegistryConnect(const UNCName: string): Boolean;
    function ReplaceKey(const Key, FileName, BackUpFileName: UnicodeString): Boolean;
    function ReplaceKey(const Key, FileName, BackUpFileName: string): Boolean;
    function RestoreKey(const Key, FileName: UnicodeString): Boolean;
    function RestoreKey(const Key, FileName: string): Boolean;
    function SaveKey(const Key, FileName: UnicodeString): Boolean;
    function SaveKey(const Key, FileName: string): Boolean;
    function UnLoadKey(const Key: UnicodeString): Boolean;
    function UnLoadKey(const Key: string): Boolean;
    function ValueExists(const Name: UnicodeString): Boolean;
    function ValueExists(const Name: string): Boolean;

    procedure CloseKey;
    procedure CloseKey(key: HKEY);
    procedure GetKeyNames(Strings: TStrings);
    function GetKeyNames: TUnicodeStringArray;
    procedure GetValueNames(Strings: TStrings);
    //ToDo
    function GetValueNames: TUnicodeStringArray;
    procedure MoveKey(const OldName, NewName: UnicodeString; Delete: Boolean);
    procedure MoveKey(const OldName, NewName: string; Delete: Boolean);
    procedure RenameValue(const OldName, NewName: UnicodeString);
    procedure RenameValue(const OldName, NewName: string);
    procedure WriteCurrency(const Name: UnicodeString; Value: Currency);
    procedure WriteCurrency(const Name: string; Value: Currency);
    procedure WriteBinaryData(const Name: UnicodeString; const Buffer; BufSize: Integer);
    procedure WriteBinaryData(const Name: string; const Buffer; BufSize: Integer);
    procedure WriteBool(const Name: UnicodeString; Value: Boolean);
    procedure WriteBool(const Name: string; Value: Boolean);
    procedure WriteDate(const Name: UnicodeString; Value: TDateTime);
    procedure WriteDate(const Name: string; Value: TDateTime);
    procedure WriteDateTime(const Name: UnicodeString; Value: TDateTime);
    procedure WriteDateTime(const Name: string; Value: TDateTime);
    procedure WriteFloat(const Name: UnicodeString; Value: Double);
    procedure WriteFloat(const Name: string; Value: Double);
    procedure WriteInteger(const Name: UnicodeString; Value: Integer);
    procedure WriteInteger(const Name: string; Value: Integer);
    procedure WriteInt64(const Name: UnicodeString; Value: Int64);
    procedure WriteInt64(const Name: string; Value: Int64);
    procedure WriteString(const Name, Value: UnicodeString);
    procedure WriteString(const Name, Value: string);
    procedure WriteExpandString(const Name, Value: UnicodeString);
    procedure WriteExpandString(const Name, Value: string);
    procedure WriteStringList(const Name: UnicodeString; List: TStrings; IsUtf8:
      Boolean = False);
    procedure WriteStringArray(const Name: UnicodeString; const Arr: TUnicodeStringArray);
    procedure WriteStringArray(const Name: string; const Arr: TStringArray);
    procedure WriteTime(const Name: UnicodeString; Value: TDateTime);
    procedure WriteTime(const Name: string; Value: TDateTime);

    property Access: LongWord read FAccess write FAccess;
    property CurrentKey: HKEY read FCurrentKey;
    property CurrentPath: UnicodeString read FCurrentPath;
    property LazyWrite: Boolean read FLazyWrite write FLazyWrite;
    property RootKey: HKEY read FRootKey write SetRootKey;
    property StringSizeIncludesNull: Boolean read FStringSizeIncludesNull;
    property LastError: Longint read FLastError;
    property LastErrorMsg: string read GetLastErrorMsg;
  end;

  TCnRegIniFile = class(TCnRegistry)
  private
    FFileName: string;
    FPath: string;
    FPreferStringValues: Boolean;
    function OpenSection(const Section: string; CreateSection: Boolean = False): Boolean;
    procedure CloseSection;
  public
    constructor Create(const FN: string); overload;
    constructor Create(const FN: string; aaccess: longword); overload;
    function ReadString(const Section, Ident, Default: string): string;
    function ReadInteger(const Section, Ident: string; Default: Longint): Longint;
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    function ReadDate(const Section, Ident: string; Default: TDateTime): TDateTime;
    function ReadDateTime(const Section, Ident: string; Default: TDateTime): TDateTime;
    function ReadTime(const Section, Ident: string; Default: TDateTime): TDateTime;
    function ReadFloat(const Section, Ident: string; Default: Double): Double;

    procedure WriteString(const Section, Ident, Value: string);
    procedure WriteInteger(const Section, Ident: string; Value: Longint);
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure WriteDate(const Section, Ident: string; Value: TDateTime);
    procedure WriteDateTime(const Section, Ident: string; Value: TDateTime);
    procedure WriteTime(const Section, Ident: string; Value: TDateTime);
    procedure WriteFloat(const Section, Ident: string; Value: Double);
    procedure ReadSection(const Section: string; Strings: TStrings);
    procedure ReadSections(Strings: TStrings);
    procedure ReadSectionValues(const Section: string; Strings: TStrings);
    procedure EraseSection(const Section: string);
    procedure DeleteKey(const Section, Ident: string);

    property FileName: string read FFileName;
    property PreferStringValues: Boolean read FPreferStringValues write
      FPreferStringValues;
  end;

  TCnRegistryIniFile = class(TCustomIniFile)
  private
    FRegIniFile: TCnRegIniFile;
  public
    constructor Create(const AFileName: string); overload;
    constructor Create(const AFileName: string; AAccess: LongWord); overload;
    destructor destroy; override;
    function ReadDate(const Section, Name: string; Default: TDateTime):
      TDateTime; override;
    function ReadDateTime(const Section, Name: string; Default: TDateTime):
      TDateTime; override;
    function ReadInteger(const Section, Name: string; Default: Longint): Longint;
      override;
    function ReadFloat(const Section, Name: string; Default: Double): Double; override;
    function ReadString(const Section, Name, Default: string): string; override;
    function ReadTime(const Section, Name: string; Default: TDateTime):
      TDateTime; override;
    function ReadBinaryStream(const Section, Name: string; Value: TStream):
      Integer; override;
    procedure WriteDate(const Section, Name: string; Value: TDateTime); override;
    procedure WriteDateTime(const Section, Name: string; Value: TDateTime); override;
    procedure WriteFloat(const Section, Name: string; Value: Double); override;
    procedure WriteInteger(const Section, Name: string; Value: Longint); override;
    procedure WriteString(const Section, Name, Value: string); override;
    procedure WriteTime(const Section, Name: string; Value: TDateTime); override;
    procedure WriteBinaryStream(const Section, Name: string; Value: TStream); override;
    procedure ReadSection(const Section: string; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const Section: string; Strings: TStrings); override;
    procedure EraseSection(const Section: string); override;
    procedure DeleteKey(const Section, Name: string); override;
    procedure UpdateFile; override;
    function ValueExists(const Section, Ident: string): Boolean; override;
    property RegIniFile: TCnRegIniFile read FRegIniFile;
  end;
{$ELSE}

  TCnRegistryIniFile = TRegistryIniFile;

{$ENDIF}

implementation

{$IFDEF FPC}

const
  RegDataWords: array[TRegDataType] of DWORD = (REG_NONE, REG_SZ, REG_EXPAND_SZ,
    REG_BINARY, REG_DWORD, REG_DWORD_BIG_ENDIAN, REG_LINK, REG_MULTI_SZ,
    REG_RESOURCE_LIST, REG_FULL_RESOURCE_DESCRIPTOR, REG_RESOURCE_REQUIREMENTS_LIST, REG_QWORD);

type
  TWinRegData = record
    RootKeyOwned: Boolean;
  end;

  PWinRegData = ^TWinRegData;

procedure TCnRegistry.SysRegCreate;
begin
  FStringSizeIncludesNull := True;
  New(PWinRegData(FSysData));
  PWinRegData(FSysData)^.RootKeyOwned := False;
end;

procedure TCnRegistry.SysRegfree;
begin
  if PWinRegData(FSysData)^.RootKeyOwned and (RootKey <> 0) then
    RegCloseKey(RootKey);
  Dispose(PWinRegData(FSysData));
end;

function PrepKey(const S: UnicodeString): UnicodeString;
begin
  Result := S;
  if (Result <> '') and (Result[1] = '\') then
    System.Delete(Result, 1, 1);
end;

function RelativeKey(const S: UnicodeString): Boolean;
begin
  Result := (S = '') or (S[1] <> '\')
end;

function TCnRegistry.sysCreateKey(Key: UnicodeString): Boolean;
var
  Disposition: Dword;
  Handle: HKEY;
  SecurityAttributes: Pointer;
  U: UnicodeString;
begin
  SecurityAttributes := nil;
  U := PrepKey(Key);
  FLastError := RegCreateKeyExW(GetBaseKey(RelativeKey(Key)),
    PWideChar(U),
    0,
    '',
    REG_OPTION_NON_VOLATILE,
    FAccess,
    SecurityAttributes,
    Handle,
    @Disposition);
  Result := FLastError = ERROR_SUCCESS;
  RegCloseKey(Handle);
end;

function TCnRegistry.DeleteKey(const Key: UnicodeString): Boolean;
var
  U: UnicodeString;
begin
  U := PRepKey(Key);
  FLastError := RegDeleteKeyW(GetBaseKey(RelativeKey(Key)), PWideChar(U));
  Result := FLastError = ERROR_SUCCESS;
end;

function TCnRegistry.DeleteValue(const Name: UnicodeString): Boolean;
begin
  FLastError := RegDeleteValueW(FCurrentKey, PWideChar(Name));
  Result := FLastError = ERROR_SUCCESS;
end;

function TCnRegistry.SysGetData(const Name: UnicodeString; Buffer: Pointer;
  BufSize: Integer; out RegData: TRegDataType): Integer;
var
  RD: DWord;
begin
  FLastError := RegQueryValueExW(FCurrentKey, PWideChar(Name), nil,
    @RD, Buffer, lpdword(@BufSize));
  if (FLastError <> ERROR_SUCCESS) then
    Result := -1
  else
  begin
    RegData := High(TRegDataType);
    while (RegData > rdUnknown) and (RD <> RegDataWords[RegData]) do
      RegData := Pred(RegData);
    Result := BufSize;
  end;
end;

function TCnRegistry.GetDataInfo(const ValueName: UnicodeString; out Value:
  TRegDataInfo): Boolean;
var
  RD: DWord;
begin
  with Value do
  begin
    FLastError := RegQueryValueExW(FCurrentKey, PWideChar(ValueName), nil,
      lpdword(@RegData), nil, lpdword(@DataSize));
    Result := FLastError = ERROR_SUCCESS;
    if Result then
    begin
      RD := DWord(RegData);
      RegData := High(TRegDataType);
      while (RegData > rdUnknown) and (RD <> RegDataWords[RegData]) do
        RegData := Pred(RegData);
    end;
  end;
  if not Result then
  begin
    Value.RegData := rdUnknown;
    Value.DataSize := 0
  end
end;

function TCnRegistry.GetKey(Key: UnicodeString): HKEY;
var
  Rel: Boolean;
begin
  Result := 0;
  Rel := RelativeKey(Key);
  if not (Rel) then
    Delete(Key, 1, 1);
{$ifdef WinCE}
  FLastError := RegOpenKeyEx(GetBaseKey(Rel), PWideChar(Key), 0, FAccess, Result);
{$else WinCE}
  FLastError := RegOpenKeyExW(GetBaseKey(Rel), PWideChar(Key), 0, FAccess, Result);
{$endif WinCE}
end;

function TCnRegistry.GetKeyInfo(out Value: TRegKeyInfo): Boolean;
var
  winFileTime: Windows.FILETIME;
  sysTime: TSystemTime;
begin
  FillChar(Value, SizeOf(Value), 0);
  with Value do
  begin
    FLastError := RegQueryInfoKeyA(CurrentKey, nil, nil, nil, lpdword(@NumSubKeys),
      lpdword(@MaxSubKeyLen), nil, lpdword(@NumValues), lpdword(@MaxValueLen),
      lpdword(@MaxDataLen), nil, @winFileTime);
    Result := FLastError = ERROR_SUCCESS;
  end;
  if Result then
  begin
    FileTimeToSystemTime(@winFileTime, @sysTime);
    Value.FileTime := SystemTimeToDateTime(sysTime);
  end;
end;

function TCnRegistry.KeyExists(const Key: UnicodeString): Boolean;
var
  KeyHandle: HKEY;
  OldAccess: LONG;
begin
  Result := False;
  OldAccess := FAccess;
  try
    FAccess := KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS or STANDARD_RIGHTS_READ
    {$ifndef WinCE} or (OldAccess and (KEY_WOW64_64KEY or KEY_WOW64_32KEY)) {$endif};
    KeyHandle := GetKey(Key);
    if KeyHandle <> 0 then
    begin
      RegCloseKey(KeyHandle);
      Result := True;
    end;
  finally
    FAccess := OldAccess;
  end;
end;

function TCnRegistry.LoadKey(const Key, FileName: UnicodeString): Boolean;
begin
  Result := False;
end;

function TCnRegistry.OpenKey(const Key: UnicodeString; CanCreate: Boolean): Boolean;
var
  U, S: UnicodeString;
  Handle: HKEY;
  Disposition: Integer;
  SecurityAttributes: Pointer; //LPSECURITY_ATTRIBUTES;
begin
  SecurityAttributes := nil;
  U := PrepKey(Key);
  if CanCreate then
  begin
    Handle := 0;
    FLastError := RegCreateKeyExW(GetBaseKey(RelativeKey(Key)), PWideChar(U), 0, '',
      REG_OPTION_NON_VOLATILE,
      FAccess, SecurityAttributes, Handle,
      pdword(@Disposition));
    Result := FLastError = ERROR_SUCCESS;
  end
  else
  begin
    FLastError := RegOpenKeyExW(GetBaseKey(RelativeKey(Key)),
      PWideChar(U), 0, FAccess, Handle);
    Result := FLastError = ERROR_SUCCESS;
  end;
  if Result then
  begin
    if RelativeKey(Key) then
    begin
      if (Key > '') and (CurrentPath > '') and (CurrentPath[Length(CurrentPath)]
        <> '\') then
        S := CurrentPath + '\' + Key
      else
        S := CurrentPath + Key;
    end
    else
      S := U;
    ChangeKey(Handle, S);
  end;
end;

function TCnRegistry.OpenKeyReadOnly(const Key: UnicodeString): Boolean;
var
  OldAccess: LongWord;
begin
  OldAccess := FAccess;
  FAccess := KEY_READ {$ifndef WinCE} or (OldAccess and (KEY_WOW64_64KEY or
    KEY_WOW64_32KEY)) {$endif};
  try
    Result := OpenKey(Key, False);
  finally
    FAccess := OldAccess;
  end;
end;

function TCnRegistry.RegistryConnect(const UNCName: UnicodeString): Boolean;
{$ifndef WinCE}
var
  NewRoot: HKEY;
{$endif}
begin
{$ifdef WinCE}
  Result := False;
{$else}
  FLastError:=RegConnectRegistryW(PWideChar(UNCName),RootKey,NewRoot);
  Result:=FLastError=ERROR_SUCCESS;
  if Result then begin
    RootKey:=NewRoot;
    PWinRegData(FSysData)^.RootKeyOwned:=True;
  end;
{$endif}
end;

function TCnRegistry.ReplaceKey(const Key, FileName, BackUpFileName:
  UnicodeString): Boolean;
begin
  Result := False;
end;

function TCnRegistry.RestoreKey(const Key, FileName: UnicodeString): Boolean;
begin
  Result := False;
end;

function TCnRegistry.SaveKey(const Key, FileName: UnicodeString): Boolean;
begin
  Result := False;
end;

function TCnRegistry.UnLoadKey(const Key: UnicodeString): Boolean;
begin
  Result := False;
end;

function TCnRegistry.ValueExists(const Name: UnicodeString): Boolean;
var
  Info: TRegDataInfo;
begin
  Result := GetDataInfo(Name, Info);
end;

procedure TCnRegistry.CloseKey;
begin
  if (CurrentKey <> 0) then
  begin
    if LazyWrite then
      RegCloseKey(CurrentKey)
    else
      RegFlushKey(CurrentKey);
    FCurrentKey := 0;
  end;
  FCurrentPath := '';
end;

procedure TCnRegistry.CloseKey(key: HKEY);
begin
  RegCloseKey(key);
end;

procedure TCnRegistry.ChangeKey(Value: HKey; const Path: UnicodeString);
begin
  CloseKey;
  FCurrentKey := Value;
  FCurrentPath := FixPath(Path);
end;

function TCnRegistry.GetKeyNames: TUnicodeStringArray;
var
  Info: TRegKeyInfo;
  dwLen: DWORD;
  lpName: LPWSTR;
  dwIndex: DWORD;
  lResult: LONGINT;
  U: UnicodeString;
begin
  Result := nil;
  if GetKeyInfo(Info) and (Info.NumSubKeys > 0) then
  begin
    dwLen := Info.MaxSubKeyLen + 1;
    GetMem(lpName, dwLen * SizeOf(WideChar));
    try
      //writeln('TRegistry.GetKeyNames: Info.NumSubKeys=',Info.NumSubKeys);
      SetLength(Result, Info.NumSubKeys);
      for dwIndex := 0 to Info.NumSubKeys - 1 do
      begin
        dwLen := Info.MaxSubKeyLen + 1;
        lResult := RegEnumKeyExW(CurrentKey, dwIndex, lpName, dwLen, nil, nil, nil, nil);
        if lResult = ERROR_NO_MORE_ITEMS then
          Break;
        if lResult <> ERROR_SUCCESS then
          raise ERegistryException.Create(SysErrorMessage(lResult));
        if dwLen = 0 then
          U := ''
        else
        begin           // dwLen>0
          U := lpName;
        end;            // if dwLen=0
        Result[dwIndex] := U;
      end;              // for dwIndex:=0 ...
    finally
      FreeMem(lpName);
    end;
  end;
end;

function TCnRegistry.GetValueNames: TUnicodeStringArray;
var
  Info: TRegKeyInfo;
  dwLen: DWORD;
  lpName: LPWSTR;
  dwIndex: DWORD;
  lResult: LONGINT;
  U: UnicodeString;
begin
  Result := nil;
  if GetKeyInfo(Info) and (Info.NumValues > 0) then
  begin
    dwLen := Info.MaxValueLen + 1;
    GetMem(lpName, dwLen * SizeOf(WideChar));
    try
      SetLength(Result, Info.NumValues);
      for dwIndex := 0 to Info.NumValues - 1 do
      begin
        dwLen := Info.MaxValueLen + 1;
        lResult := RegEnumValueW(CurrentKey, dwIndex, lpName, dwLen, nil, nil, nil, nil);
        if lResult = ERROR_NO_MORE_ITEMS then
          Break;
        if lResult <> ERROR_SUCCESS then
          raise ERegistryException.Create(SysErrorMessage(lResult));
        if dwLen = 0 then
          U := ''
        else
        begin           // dwLen>0
          U := lpName;
        end;            // if dwLen=0
        Result[dwIndex] := U;
      end;              // for dwIndex:=0 ...
    finally
      FreeMem(lpName);
    end;
  end;
end;

function TCnRegistry.SysPutData(const Name: UnicodeString; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType): Boolean;
var
  RegDataType: DWORD;
begin
  RegDataType := RegDataWords[RegData];
  FLastError := RegSetValueExW(FCurrentKey, PWideChar(Name), 0, RegDataType,
    Buffer, BufSize);
  Result := FLastError = ERROR_SUCCESS;
end;

procedure TCnRegistry.RenameValue(const OldName, NewName: UnicodeString);
var
  L: Integer;
  InfoO, InfoN: TRegDataInfo;
  D: TRegDataType;
  P: PChar;
begin
  if GetDataInfo(OldName, InfoO) and not GetDataInfo(NewName, InfoN) then
  begin
    L := InfoO.DataSize;
    if L > 0 then
    begin
      GetMem(P, L);
      try
        L := GetData(OldName, P, L, D);
        if SysPutData(NewName, P, L, D) then
          DeleteValue(OldName);
      finally
        FreeMem(P);
      end;
    end;
  end;
end;

procedure TCnRegistry.SetCurrentKey(Value: HKEY);
begin
  FCurrentKey := Value;
end;

procedure TCnRegistry.SetRootKey(Value: HKEY);
begin
  if FRootKey = Value then
    Exit;
  { close a root key that was opened using RegistryConnect }
  if PWinRegData(FSysData)^.RootKeyOwned and (FRootKey <> 0) then
  begin
    RegCloseKey(FRootKey);
    PWinRegData(FSysData)^.RootKeyOwned := False;
  end;
  FRootKey := Value;
end;

function TCnRegistry.GetLastErrorMsg: string;
begin
  if FLastError <> ERROR_SUCCESS then
    Result := SysErrorMessage(FLastError)
  else
    Result := '';
end;

constructor TCnRegistry.Create;
begin
  inherited Create;
  FAccess := KEY_ALL_ACCESS;
  FRootKey := HKEY_CURRENT_USER;
  FLazyWrite := False;
  FCurrentKey := 0;
  SysRegCreate;
end;

constructor TCnRegistry.Create(aaccess: longword);
begin
  Create;
  FAccess := aaccess;
end;

destructor TCnRegistry.Destroy;
begin
  CloseKey;
  SysRegFree;
  inherited Destroy;
end;

function TCnRegistry.CreateKey(const Key: UnicodeString): Boolean;
begin
  Result := SysCreateKey(Key);
  if not Result then
    raise ERegistryException.CreateFmt(SRegCreateFailed, [Key]);
end;

function TCnRegistry.CreateKey(const Key: string): Boolean;
begin
  Result := CreateKey(UnicodeString(Key));
end;

function TCnRegistry.DeleteKey(const Key: string): Boolean;
begin
  Result := DeleteKey(UnicodeString(Key));
end;

function TCnRegistry.DeleteValue(const Name: string): Boolean;
begin
  Result := DeleteValue(UnicodeString(Name));
end;

function TCnRegistry.GetDataInfo(const ValueName: string; out Value:
  TRegDataInfo): Boolean;
begin
  Result := GetDataInfo(UnicodeString(ValueName), Value);
end;

function TCnRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
  if Relative and (CurrentKey <> 0) then
    Result := CurrentKey
  else
    Result := RootKey;
end;

function TCnRegistry.GetData(const Name: UnicodeString; Buffer: Pointer; BufSize:
  Integer; out RegData: TRegDataType): Integer;
begin
  Result := SysGetData(Name, Buffer, BufSize, RegData);
  if Result = -1 then
    raise ERegistryException.CreateFmt(SRegGetDataFailed, [Name]);
end;

function TCnRegistry.GetData(const Name: string; Buffer: Pointer; BufSize:
  Integer; out RegData: TRegDataType): Integer;
begin
  Result := GetData(UnicodeString(Name), Buffer, BufSize, RegData);
end;

function TCnRegistry.GetKey(Key: string): HKEY;
begin
  Result := GetKey(UnicodeString(Key));
end;

procedure TCnRegistry.ChangeKey(Value: HKey; const Path: string);
begin
  ChangeKey(Value, UnicodeString(Path));
end;

procedure TCnRegistry.PutData(const Name: UnicodeString; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
begin
  if not SysPutData(Name, Buffer, BufSize, RegData) then
    raise ERegistryException.CreateFmt(SRegSetDataFailed, [Name]);
end;

procedure TCnRegistry.PutData(const Name: string; Buffer: Pointer; BufSize:
  Integer; RegData: TRegDataType);
begin
  PutData(UnicodeString(Name), Buffer, BufSize, RegData);
end;

function TCnRegistry.GetDataSize(const ValueName: UnicodeString): Integer;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(ValueName, Info) then
    Result := Info.DataSize
  else
    Result := -1;
end;

function TCnRegistry.GetDataSize(const ValueName: string): Integer;
begin
  Result := GetDataSize(UnicodeString(ValueName));
end;

function TCnRegistry.GetDataType(const ValueName: UnicodeString): TRegDataType;
var
  Info: TRegDataInfo;
begin
  GetDataInfo(ValueName, Info);
  Result := Info.RegData;
end;

function TCnRegistry.GetDataType(const ValueName: string): TRegDataType;
begin
  Result := GetDataType(UnicodeString(ValueName));
end;

function TCnRegistry.KeyExists(const Key: string): Boolean;
begin
  Result := KeyExists(UnicodeString(Key));
end;

function TCnRegistry.LoadKey(const Key, FileName: string): Boolean;
begin
  Result := LoadKey(UnicodeString(Key), UnicodeString(FileName));
end;

function TCnRegistry.OpenKey(const Key: string; CanCreate: Boolean): Boolean;
begin
  Result := OpenKey(UnicodeString(Key), CanCreate);
end;

function TCnRegistry.OpenKeyReadOnly(const Key: string): Boolean;
begin
  Result := OpenKeyReadOnly(UnicodeString(Key));
end;

function TCnRegistry.HasSubKeys: Boolean;
var
  Info: TRegKeyInfo;
begin
  Result := GetKeyInfo(Info);
  if Result then
    Result := (Info.NumSubKeys > 0);
end;

function TCnRegistry.ReadBinaryData(const Name: UnicodeString; var Buffer;
  BufSize: Integer): Integer;
var
  RegDataType: TRegDataType;
begin
  Result := GetData(Name, @Buffer, BufSize, RegDataType);
end;

function TCnRegistry.ReadBinaryData(const Name: string; var Buffer; BufSize:
  Integer): Integer;
begin
  Result := ReadBinaryData(UnicodeString(Name), Buffer, BufSize);
end;

function TCnRegistry.ReadInteger(const Name: UnicodeString): Integer;
var
  RegDataType: TRegDataType;
begin
  GetData(Name, @Result, SizeOf(Integer), RegDataType);
  if RegDataType <> rdInteger then
    raise ERegistryException.CreateFmt(SInvalidRegType, [Name]);
end;

function TCnRegistry.ReadInteger(const Name: string): Integer;
begin
  Result := ReadInteger(UnicodeString(Name));
end;

function TCnRegistry.ReadInt64(const Name: UnicodeString): Int64;
var
  RegDataType: TRegDataType;
begin
  GetData(Name, @Result, SizeOf(Int64), RegDataType);
  if RegDataType <> rdInt64 then
    raise ERegistryException.CreateFmt(SInvalidRegType, [Name]);
end;

function TCnRegistry.ReadInt64(const Name: string): Int64;
begin
  Result := ReadInt64(UnicodeString(Name));
end;

function TCnRegistry.ReadBool(const Name: UnicodeString): Boolean;
begin
  Result := ReadInteger(Name) <> 0;
end;

function TCnRegistry.ReadBool(const Name: string): Boolean;
begin
  Result := ReadBool(UnicodeString(Name));
end;

function TCnRegistry.ReadCurrency(const Name: UnicodeString): Currency;
begin
  Result := Default(Currency);
  ReadBinaryData(Name, Result, SizeOf(Currency));
end;

function TCnRegistry.ReadCurrency(const Name: string): Currency;
begin
  Result := ReadCurrency(UnicodeString(Name));
end;

function TCnRegistry.ReadDate(const Name: UnicodeString): TDateTime;
begin
  Result := Trunc(ReadDateTime(Name));
end;

function TCnRegistry.ReadDate(const Name: string): TDateTime;
begin
  Result := ReadDate(UnicodeString(Name));
end;

function TCnRegistry.ReadDateTime(const Name: UnicodeString): TDateTime;
begin
  Result := Default(TDateTime);
  ReadBinaryData(Name, Result, SizeOf(TDateTime));
end;

function TCnRegistry.ReadDateTime(const Name: string): TDateTime;
begin
  Result := ReadDateTime(UnicodeString(Name));
end;

function TCnRegistry.ReadFloat(const Name: UnicodeString): Double;
begin
  Result := Default(Double);
  ReadBinaryData(Name, Result, SizeOf(Double));
end;

function TCnRegistry.ReadFloat(const Name: string): Double;
begin
  Result := ReadFloat(UnicodeString(Name));
end;

function TCnRegistry.ReadString(const Name: UnicodeString): UnicodeString;
var
  Info: TRegDataInfo;
  ReadDataSize: Integer;
  U: UnicodeString;
begin
  Result := '';
  GetDataInfo(Name, Info);
  if Info.datasize > 0 then
  begin
    if not (Info.RegData in [rdString, rdExpandString]) then
      raise ERegistryException.CreateFmt(SInvalidRegType, [Name]);
    if Odd(Info.DataSize) then
      SetLength(U, round((Info.DataSize + 1) / SizeOf(UnicodeChar)))
    else
      SetLength(U, round(Info.DataSize / SizeOf(UnicodeChar)));
    ReadDataSize := GetData(Name, @U[1], Info.DataSize, Info.RegData);
    if ReadDataSize > 0 then
    begin
      // If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type,
      // the size includes any terminating null character or characters
      // unless the data was stored without them! (RegQueryValueEx @ MSDN)
      if StringSizeIncludesNull and
        (U[Length(U)] = WideChar(0)) then
        SetLength(U, Length(U) - 1);
      Result := U;
    end;
  end;
end;

function TCnRegistry.ReadString(const Name: string): string;
begin
  Result := ReadString(UnicodeString(Name));
end;

procedure TCnRegistry.ReadStringList(const Name: UnicodeString; AList: TStrings;
  ForceUtf8: Boolean = False);
var
  UArr: TUnicodeStringArray;
begin
  UArr := ReadStringArray(Name);
  ArrayToList(UArr, AList, ForceUtf8);
end;

procedure TCnRegistry.ReadStringList(const Name: string; AList: TStrings);
begin
  ReadStringList(UnicodeString(Name), AList);
end;

function TCnRegistry.FixPath(APath: UnicodeString): UnicodeString;
const
  Delim ={$ifdef XMLREG}  '/'{$else}'\'{$endif};
begin
  //At this point we know the path is valid, since this is only called after OpenKey succeeded
  //Just sanitize it
  while (Pos(Delim + Delim, APath) > 0) do
    APath := UnicodeStringReplace(APath, Delim + Delim, Delim, [rfReplaceAll]);
  if (Length(APath) > 1) and (APath[Length(APath)] = Delim) then
    System.Delete(APath, Length(APath), 1);
  Result := APath;
end;

function TCnRegistry.RegMultiSzDataToUnicodeStringArray(U: UnicodeString):
  TUnicodeStringArray;
var
  Len, i, p: Integer;
  Sub: UnicodeString;
begin
  Result := nil;
  if (U = '') then
    Exit;
  Len := 1;
  for i := 1 to Length(U) do
    if (U[i] = #0) then
      Inc(Len);
  SetLength(Result, Len);
  i := 0;

  while (U <> '') and (i < Length(Result)) do
  begin
    p := Pos(#0, U);
    if (p = 0) then
      p := Length(U) + 1;
    Sub := Copy(U, 1, p - 1);
    Result[i] := Sub;
    System.Delete(U, 1, p);
    Inc(i);
  end;
end;

function TCnRegistry.ListToArray(List: TStrings; IsUtf8: Boolean): TUnicodeStringArray;
var
  i, curr, Len: Integer;
  U: UnicodeString;
begin
  Result := nil;
  Len := List.Count;
  SetLength(Result, Len);
  //REG_MULTI_SZ data cannot contain empty strings
  curr := 0;
  for i := 0 to List.Count - 1 do
  begin
    if IsUtf8 then
      U := Utf8Decode(List[i])
    else
      U := List[i];
    if (U > '') then
    begin
      Result[curr] := U;
      inc(curr);
    end
    else
      Dec(Len);
  end;
  if (Len <> List.Count) then
    SetLength(Result, Len);
end;

procedure TCnRegistry.ArrayToList(const Arr: TUnicodeStringArray; List: TStrings;
  ForceUtf8: Boolean);
var
  i: Integer;
begin
  List.Clear;
  for i := Low(Arr) to High(Arr) do
  begin
    if ForceUtf8 then
      List.Add(Utf8Encode(Arr[i]))
    else
      List.Add(string(Arr[i]));
  end;
end;

function TCnRegistry.ReadStringArray(const Name: UnicodeString): TUnicodeStringArray;
var
  Info: TRegDataInfo;
  ReadDataSize: Integer;
  Data: UnicodeString;
begin
  Result := nil;
  GetDataInfo(Name, Info);
  //writeln('TRegistry.ReadStringArray: datasize=',info.datasize);
  if Info.datasize > 0 then
  begin
    if not (Info.RegData in [rdMultiString]) then
      raise ERegistryException.CreateFmt(SInvalidRegType, [Name]);
    SetLength(Data, Info.DataSize);
    ReadDataSize := GetData(Name, PWideChar(Data), Info.DataSize, Info.RegData)
      div SizeOf(WideChar);
     //writeln('TRegistry.ReadStringArray: ReadDataSize=',ReadDataSize);
    if ReadDataSize > 0 then
    begin
       // Windows returns the data with or without trailing zero's, so just strip all trailing null characters
      while (Data[ReadDataSize] = #0) do
        Dec(ReadDataSize);
      SetLength(Data, ReadDataSize);
       //writeln('Data=',dbgs(data));
       //Data := UnicodeStringReplace(Data, #0, AList.LineBreak, [rfReplaceAll]);
       //AList.Text := Data;
      Result := RegMultiSzDataToUnicodeStringArray(Data);
    end
  end
end;

function TCnRegistry.ReadStringArray(const Name: string): TStringArray;
var
  UArr: TUnicodeStringArray;
  i: Integer;
begin
  Result := nil;
  UArr := ReadStringArray(UnicodeString(Name));
  SetLength(Result, Length(UArr));
  for i := Low(UArr) to High(UArr) do
    Result[i] := UArr[i];
end;

function TCnRegistry.ReadTime(const Name: UnicodeString): TDateTime;
begin
  Result := Frac(ReadDateTime(Name));
end;

function TCnRegistry.ReadTime(const Name: string): TDateTime;
begin
  Result := ReadTime(UnicodeString(Name));
end;

function TCnRegistry.RegistryConnect(const UNCName: string): Boolean;
begin
  Result := RegistryConnect(UnicodeString(UNCName));
end;

function TCnRegistry.ReplaceKey(const Key, FileName, BackUpFileName: string): Boolean;
begin
  Result := ReplaceKey(UnicodeString(Key), UnicodeString(FileName),
    UnicodeString(BackUpFileName))
end;

function TCnRegistry.RestoreKey(const Key, FileName: string): Boolean;
begin
  Result := RestoreKey(UnicodeString(Key), UnicodeString(FileName));
end;

function TCnRegistry.SaveKey(const Key, FileName: string): Boolean;
begin
  Result := SaveKey(UnicodeString(Key), UnicodeString(FileName));
end;

function TCnRegistry.UnLoadKey(const Key: string): Boolean;
begin
  Result := UnloadKey(UnicodeString(Key));
end;

function TCnRegistry.ValueExists(const Name: string): Boolean;
begin
  Result := ValueExists(UnicodeString(Name));
end;

procedure TCnRegistry.WriteBinaryData(const Name: UnicodeString; const Buffer;
  BufSize: Integer);
begin
  PutData(Name, @Buffer, BufSize, rdBinary);
end;

procedure TCnRegistry.WriteBinaryData(const Name: string; const Buffer; BufSize: Integer);
begin
  WriteBinaryData(UnicodeString(Name), Buffer, BufSize);
end;

procedure TCnRegistry.WriteBool(const Name: UnicodeString; Value: Boolean);
begin
  WriteInteger(Name, Ord(Value));
end;

procedure TCnRegistry.WriteBool(const Name: string; Value: Boolean);
begin
  WriteBool(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteCurrency(const Name: UnicodeString; Value: Currency);
begin
  WriteBinaryData(Name, Value, SizeOf(Currency));
end;

procedure TCnRegistry.WriteCurrency(const Name: string; Value: Currency);
begin
  WriteCurrency(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteDate(const Name: UnicodeString; Value: TDateTime);
begin
  WriteBinarydata(Name, Value, SizeOf(TDateTime));
end;

procedure TCnRegistry.WriteDate(const Name: string; Value: TDateTime);
begin
  WriteDate(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteTime(const Name: UnicodeString; Value: TDateTime);
begin
  WriteBinaryData(Name, Value, SizeOf(TDateTime));
end;

procedure TCnRegistry.WriteTime(const Name: string; Value: TDateTime);
begin
  WriteTime(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteDateTime(const Name: UnicodeString; Value: TDateTime);
begin
  WriteBinaryData(Name, Value, SizeOf(TDateTime));
end;

procedure TCnRegistry.WriteDateTime(const Name: string; Value: TDateTime);
begin
  WriteDateTime(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteExpandString(const Name, Value: UnicodeString);
begin
  PutData(Name, PWideChar(Value), ByteLength(Value), rdExpandString);
end;

procedure TCnRegistry.WriteExpandString(const Name, Value: string);
begin
  WriteExpandString(UnicodeString(Name), UnicodeString(Value));
end;

procedure TCnRegistry.WriteStringList(const Name: UnicodeString; List: TStrings;
  IsUtf8: Boolean = False);
var
  UArr: TUnicodeStringArray;
begin
  UArr := ListToArray(List, IsUtf8);
  WriteStringArray(Name, UArr);
end;

procedure TCnRegistry.WriteStringArray(const Name: UnicodeString; const Arr:
  TUnicodeStringArray);
var
  Data: UnicodeString;
  U: UnicodeString;
  i: Integer;
begin
  Data := '';
  //REG_MULTI_SZ data cannot contain empty strings
  for i := Low(Arr) to High(Arr) do
  begin
    U := Arr[i];
    if (U > '') then
    begin
      if (Data > '') then
        Data := Data + #0 + U
      else
        Data := Data + U;
    end;
  end;
  if StringSizeIncludesNull then
    Data := Data + #0#0;
  //writeln('Data=',Dbgs(Data));
  PutData(Name, PWideChar(Data), ByteLength(Data), rdMultiString);
end;

procedure TCnRegistry.WriteStringArray(const Name: string; const Arr: TStringArray);
var
  UArr: TUnicodeStringArray;
  i: Integer;
begin
  UArr := nil;
  SetLength(UArr, Length(Arr));
  for i := Low(Arr) to High(Arr) do
    UArr[i] := Arr[i];
  WriteStringArray(UnicodeString(Name), UArr);
end;

procedure TCnRegistry.WriteFloat(const Name: UnicodeString; Value: Double);
begin
  WriteBinaryData(Name, Value, SizeOf(Double));
end;

procedure TCnRegistry.WriteFloat(const Name: string; Value: Double);
begin
  WriteFloat(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteInteger(const Name: UnicodeString; Value: Integer);
begin
  PutData(Name, @Value, SizeOf(Integer), rdInteger);
end;

procedure TCnRegistry.WriteInteger(const Name: string; Value: Integer);
begin
  WriteInteger(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteInt64(const Name: UnicodeString; Value: Int64);
begin
  PutData(Name, @Value, SizeOf(Int64), rdInt64);
end;

procedure TCnRegistry.WriteInt64(const Name: string; Value: Int64);
begin
  WriteInt64(UnicodeString(Name), Value);
end;

procedure TCnRegistry.WriteString(const Name, Value: UnicodeString);
begin
  PutData(Name, PWideChar(Value), ByteLength(Value), rdString);
end;

procedure TCnRegistry.WriteString(const Name, Value: string);
begin
  WriteString(UnicodeString(Name), UnicodeString(Value));
end;

procedure TCnRegistry.GetKeyNames(Strings: TStrings);
var
  UArr: TUnicodeStringArray;
begin
  UArr := GetKeyNames;
  ArrayToList(UArr, Strings, True);
end;

procedure TCnRegistry.GetValueNames(Strings: TStrings);
var
  UArr: TUnicodeStringArray;
begin
  UArr := GetValueNames;
  ArrayToList(UArr, Strings, True);
end;

procedure TCnRegistry.MoveKey(const OldName, NewName: UnicodeString; Delete: Boolean);
begin

end;

procedure TCnRegistry.MoveKey(const OldName, NewName: string; Delete: Boolean);
begin
  MoveKey(UnicodeString(OldName), UnicodeString(NewName), Delete);
end;

procedure TCnRegistry.RenameValue(const OldName, NewName: string);
begin
  RenameValue(UnicodeString(OldName), UnicodeString(NewName));
end;

{******************************************************************************
                                TRegIniFile
 ******************************************************************************}

constructor TCnRegIniFile.Create(const FN: string);
begin
  Create(FN, KEY_ALL_ACCESS);
end;

constructor TCnRegIniFile.Create(const FN: string; aaccess: longword);
begin
  inherited Create(aaccess);
  FFileName := FN;
  if FFileName <> '' then
  begin
    FPath := FFileName + '\';
    if FPath[1] = '\' then
      System.Delete(FPath, 1, 1);
    OpenKey(FFileName, aaccess <> KEY_READ);
  end
  else
    FPath := '';
  FPreferStringValues := True; // Delphi compatibility
end;

procedure TCnRegIniFile.DeleteKey(const Section, Ident: string);
begin
  if OpenSection(Section) then
  try
    DeleteValue(Ident);
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.EraseSection(const Section: string);
begin
  inherited DeleteKey(Section);
end;

procedure TCnRegIniFile.ReadSection(const Section: string; Strings: TStrings);
begin
  if OpenSection(Section) then
  try
    GetValueNames(Strings);
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.ReadSections(Strings: TStrings);
begin
  GetKeyNames(Strings);
end;

procedure TCnRegIniFile.ReadSectionValues(const Section: string; Strings: TStrings);
var
  ValList: TStringList;
  V: string;
  i: Integer;
begin
  if OpenSection(Section) then
  try
    ValList := TStringList.Create;
    try
      GetValueNames(ValList);
      for i := 0 to ValList.Count - 1 do
      begin
        V := inherited ReadString(ValList.Strings[i]);
        Strings.Add(ValList.Strings[i] + '=' + V);
      end;
    finally
      ValList.Free;
    end;
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.WriteBool(const Section, Ident: string; Value: Boolean);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteBool(Ident, Value)
    else
    begin
      if ValueExists(Ident) and (GetDataType(Ident) = rdInteger) then
        inherited WriteBool(Ident, Value)
      else
        inherited WriteString(Ident, BoolToStr(Value));
    end;
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.WriteInteger(const Section, Ident: string; Value: LongInt);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteInteger(Ident, Value)
    else
    begin
      if ValueExists(Ident) and (GetDataType(Ident) = rdInteger) then
        inherited WriteInteger(Ident, Value)
      else
        inherited WriteString(Ident, IntToStr(Value));
    end;
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.WriteString(const Section, Ident, Value: string);
begin
  if OpenSection(Section, True) then
  try
    inherited WriteString(Ident, Value);
  finally
    CloseSection;
  end;
end;

procedure TCnRegIniFile.WriteDate(const Section, Ident: string; Value: TDateTime);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteDate(Ident, Value)
    else if ValueExists(Ident) and (GetDataType(Ident) <> rdString) then
      inherited WriteDate(Ident, Value)
    else
      inherited WriteString(Ident, DateToStr(Value));
  finally
    CloseKey;
  end;
end;

procedure TCnRegIniFile.WriteDateTime(const Section, Ident: string; Value: TDateTime);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteDateTime(Ident, Value)
    else if ValueExists(Ident) and (GetDataType(Ident) <> rdString) then
      inherited WriteDateTime(Ident, Value)
    else
      inherited WriteString(Ident, DateTimeToStr(Value));
  finally
    CloseKey;
  end;
end;

procedure TCnRegIniFile.WriteTime(const Section, Ident: string; Value: TDateTime);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteTime(Ident, Value)
    else if ValueExists(Ident) and (GetDataType(Ident) <> rdString) then
      inherited WriteTime(Ident, Value)
    else
      inherited WriteString(Ident, TimeToStr(Value));
  finally
    CloseKey;
  end;
end;

procedure TCnRegIniFile.WriteFloat(const Section, Ident: string; Value: Double);
begin
  if OpenSection(Section, True) then
  try
    if not FPreferStringValues then
      inherited WriteFloat(Ident, Value)
    else if ValueExists(Ident) and (GetDataType(Ident) <> rdString) then
      inherited WriteFloat(Ident, Value)
    else
      inherited WriteString(Ident, FloatToStr(Value));
  finally
    CloseKey;
  end;
end;

function TCnRegIniFile.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) = rdInteger) then
        Result := inherited ReadBool(Ident)
      else
        Result := StrToBool(inherited ReadString(Ident));
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadInteger(const Section, Ident: string; Default:
  LongInt): LongInt;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) = rdInteger) then
        Result := inherited ReadInteger(Ident)
      else
        Result := StrToInt(inherited ReadString(Ident));
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadString(const Section, Ident, Default: string): string;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      Result := inherited ReadString(Ident);
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadDate(const Section, Ident: string; Default: TDateTime):
  TDateTime;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) <> rdString) then
        Result := inherited ReadDate(Ident)
      else
        Result := StrToDateDef(inherited ReadString(Ident), Result);
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadDateTime(const Section, Ident: string; Default:
  TDateTime): TDateTime;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) <> rdString) then
        Result := inherited ReadDateTime(Ident)
      else
        Result := StrToDateTimeDef(inherited ReadString(Ident), Result);
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadTime(const Section, Ident: string; Default: TDateTime):
  TDateTime;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) <> rdString) then
        Result := inherited ReadTime(Ident)
      else
        Result := StrToTimeDef(inherited ReadString(Ident), Result);
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.ReadFloat(const Section, Ident: string; Default: Double): Double;
begin
  Result := Default;
  if OpenSection(Section) then
  try
    if ValueExists(Ident) then
      if (not FPreferStringValues) or (GetDataType(Ident) <> rdString) then
        Result := inherited ReadFloat(Ident)
      else
        Result := StrToFloatDef(inherited ReadString(Ident), Result);
  finally
    CloseSection;
  end;
end;

function TCnRegIniFile.OpenSection(const Section: string; CreateSection: Boolean
  = False): Boolean;
var
  k: HKEY;
  S: string;
begin
  S := Section;
  if (S <> '') and (S[1] = '\') then
    Delete(S, 1, 1);
  if CreateSection and (S <> '') then
    CreateKey('\' + CurrentPath + '\' + S);
  if S <> '' then
    k := GetKey('\' + CurrentPath + '\' + S)
  else
    k := GetKey('\' + CurrentPath);
  if k = 0 then
  begin
    Result := False;
    exit;
  end;
  SetCurrentKey(k);
  Result := True;
end;

procedure TCnRegIniFile.CloseSection;
begin
  CloseKey(CurrentKey);
end;

constructor TCnRegistryIniFile.Create(const AFileName: string; AAccess: LongWord);
begin
  inherited create(AFileName);
  FRegInifile := TCnRegIniFile.Create(AFileName, AAccess);
end;

constructor TCnRegistryIniFile.Create(const AFileName: string);
begin
  Create(AFileName, KEY_ALL_ACCESS);
end;

destructor TCnRegistryIniFile.destroy;
begin
  FreeAndNil(FRegInifile);
  inherited;
end;

procedure TCnRegistryIniFile.DeleteKey(const Section, Name: string);
begin
  FRegIniFile.Deletekey(Section, Name);
end;

procedure TCnRegistryIniFile.EraseSection(const Section: string);
begin
  FRegIniFile.EraseSection(Section);
end;

function TCnRegistryIniFile.ReadBinaryStream(const Section, Name: string; Value:
  TStream): Integer;
begin
  result := -1; // unimplemented
 //
end;

function TCnRegistryIniFile.ReadDate(const Section, Name: string; Default:
  TDateTime): TDateTime;
begin
  Result := FRegInifile.ReadDate(Section, Name, Default);
end;

function TCnRegistryIniFile.ReadDateTime(const Section, Name: string; Default:
  TDateTime): TDateTime;
begin
  Result := FRegInifile.ReadDateTime(Section, Name, Default);
end;

function TCnRegistryIniFile.ReadFloat(const Section, Name: string; Default:
  Double): Double;
begin
  Result := FRegInifile.ReadFloat(Section, Name, Default);
end;

function TCnRegistryIniFile.ReadInteger(const Section, Name: string; Default:
  Integer): Longint;
begin
  Result := FRegInifile.ReadInteger(Section, Name, Default);
end;

procedure TCnRegistryIniFile.ReadSection(const Section: string; Strings: TStrings);
begin
  FRegIniFile.ReadSection(Section, Strings);
end;

procedure TCnRegistryIniFile.ReadSections(Strings: TStrings);
begin
  FRegIniFile.ReadSections(Strings);
end;

procedure TCnRegistryIniFile.ReadSectionValues(const Section: string; Strings: TStrings);
begin
  FRegIniFile.ReadSectionValues(Section, Strings);
end;

function TCnRegistryIniFile.ReadString(const Section, Name, Default: string): string;
begin
  Result := FRegInifile.ReadString(Section, Name, Default);
end;

function TCnRegistryIniFile.ReadTime(const Section, Name: string; Default:
  TDateTime): TDateTime;
begin
  Result := FRegInifile.ReadTime(Section, Name, Default);
end;

procedure TCnRegistryIniFile.UpdateFile;
begin
//  FRegIniFile.UpdateFile; ??
end;

procedure TCnRegistryIniFile.WriteBinaryStream(const Section, Name: string;
  Value: TStream);
begin
 // ??
end;

procedure TCnRegistryIniFile.WriteDate(const Section, Name: string; Value: TDateTime);
begin
  FRegInifile.WriteDate(Section, Name, Value);
end;

procedure TCnRegistryIniFile.WriteDateTime(const Section, Name: string; Value: TDateTime);
begin
  FRegInifile.WriteDateTime(Section, Name, Value);
end;

procedure TCnRegistryIniFile.WriteFloat(const Section, Name: string; Value: Double);
begin
  FRegInifile.WriteFloat(Section, Name, Value);
end;

procedure TCnRegistryIniFile.WriteInteger(const Section, Name: string; Value: Integer);
begin
  FRegInifile.WriteInteger(Section, Name, Value);
end;

procedure TCnRegistryIniFile.WriteString(const Section, Name, Value: string);
begin
  FRegInifile.WriteString(Section, Name, Value);
end;

procedure TCnRegistryIniFile.WriteTime(const Section, Name: string; Value: TDateTime);
begin
  FRegInifile.WriteTime(Section, Name, Value);
end;

function TCnRegistryIniFile.ValueExists(const Section, Ident: string): Boolean;
begin
  with FRegInifile do
    if OpenSection(Section) then
    try
      Result := FRegInifile.ValueExists(Ident);
    finally
      CloseSection;
    end;
end;

{$ENDIF}
end.

