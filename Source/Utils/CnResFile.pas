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

unit CnResFile;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：资源文件简易操作单元
* 单元作者：CnPack 开发组
* 备    注：该单元实现了 RES 文件的版本号操作。
* 开发平台：Win7 + Delphi XE2
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2026.04.30 V1.1
*               修正版本号读写时未跳过 VS_VERSIONINFO 头部的 Bug
*           2026.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows;

type
  TCnResFile = class
  {* 资源文件操作类，目前只实现版本号的处理}
  private
    FStream: TFileStream;
    FFileName: string;
    FVersionInfoStart: Int64;
    FVersionDataSize: DWORD;
    FFixedFilePos: Int64;
    function ReadResourceEntry(var HeaderSize: Integer;
      var DataSize: DWORD; var ResType: Integer): Boolean;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;

    function HasVersionInfo: Boolean;
    function GetVersionInfo(var Major, Minor, Release, Build: Integer;
      var LangID, CodePage: Integer): Boolean;
    function SetVersionInfo(Major, Minor, Release, Build: Integer;
      LangID, CodePage: Integer): Boolean;
  end;

  TCnVersionInfo = class
  {* 版本信息工具类}
  private
    FModule: THandle;
    FVersionInfo: PChar;
    FVersionHeader: PChar;
    FChildStrings: TStringList;
    FTranslations: TList;
    FFixedInfo: PVSFixedFileInfo;
    FVersionResHandle: THandle;
    function GetInfo: boolean;
    function GetKeyCount: Integer;
    function GetKeyName(Index: Integer): string;
    function GetKeyValue(const Index: string): string;
    procedure SetKeyValue(const Index, Value: string);
  public
    constructor Create(AModule: THandle); overload;
    constructor Create(AVersionInfo: PChar); overload;
    destructor Destroy; override;

    procedure SaveToStream(strm: TStream);

    property KeyCount: Integer read GetKeyCount;
    property KeyName[Index: Integer]: string read GetKeyName;
    property KeyValue[const Index: string]: string read GetKeyValue write SetKeyValue;
  end;

function CnReadProjectResVersion(const ResFileName: string;
  var Major, Minor, Release, Build: Integer): Boolean;

function CnWriteProjectResVersion(const ResFileName: string;
  Major, Minor, Release, Build: Integer): Boolean;

implementation

const
  RT_VERSION_INT = 16;

  VS_FFI_SIGNATURE = $FEEF04BD;

type
  TCnVersionStringValue = class
  public
    FValue: string;
    FLangID, FCodePage: Integer;

    constructor Create(const AValue: string; ALangID, ACodePage: Integer);
  end;

  TCnResResourceHeader = packed record
    DataSize: DWORD;
    HeaderSize: DWORD;
    ResType: DWORD;
    Name: DWORD;
    DataVersion: DWORD;
    MemoryFlags: Word;
    LanguageId: Word;
    Version: DWORD;
    Characteristics: DWORD;
  end;

  TCnVSFixedFileInfo = packed record
    dwSignature: DWORD;
    dwStrucVersion: DWORD;
    dwFileVersionMS: DWORD;
    dwFileVersionLS: DWORD;
    dwProductVersionMS: DWORD;
    dwProductVersionLS: DWORD;
    dwFileFlagsMask: DWORD;
    dwFileFlags: DWORD;
    dwFileOS: DWORD;
    dwFileType: DWORD;
    dwFileSubType: DWORD;
    dwFileDateMS: DWORD;
    dwFileDateLS: DWORD;
  end;

procedure AlignStream(Stream: TStream);
begin
  if Stream.Position mod 4 <> 0 then
    Stream.Position := Stream.Position + (4 - Stream.Position mod 4);
end;

{ TCnResFile }

constructor TCnResFile.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
  FVersionInfoStart := Int64(-1);
  FVersionDataSize := 0;

  if FileExists(AFileName) then
  begin
    try
      FStream := TFileStream.Create(AFileName, fmOpenReadWrite or fmShareDenyWrite);
    except
      FStream := nil;
    end;
  end;
end;

destructor TCnResFile.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TCnResFile.ReadResourceEntry(var HeaderSize: Integer;
  var DataSize: DWORD; var ResType: Integer): Boolean;
var
  Header: TCnResResourceHeader;
begin
  Result := False;
  if FStream = nil then
    Exit;

  try
    if FStream.Read(Header, SizeOf(Header)) = SizeOf(Header) then
    begin
      HeaderSize := Header.HeaderSize;
      DataSize := Header.DataSize;
      ResType := Header.ResType;
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TCnResFile.HasVersionInfo: Boolean;
var
  Major, Minor, Release, Build: Integer;
  LangID, CodePage: Integer;
begin
  Result := GetVersionInfo(Major, Minor, Release, Build, LangID, CodePage);
end;

function TCnResFile.GetVersionInfo(var Major, Minor, Release, Build: Integer;
  var LangID, CodePage: Integer): Boolean;
var
  HeaderSize: Integer;
  DataSize: DWORD;
  ResType: Integer;
  DataStart: Int64;
  FixedInfo: TCnVSFixedFileInfo;
  wLength, wValueLength, wType: Word;
  KeyBuf: array[0..15] of WideChar; // "VS_VERSION_INFO" + #0 = 15+1 chars
  FixedFilePos: Int64;
begin
  Result := False;
  Major := 0;
  Minor := 0;
  Release := 0;
  Build := 0;
  LangID := $0409;
  CodePage := 1252;
  FVersionInfoStart := Int64(-1);
  FVersionDataSize := 0;
  FFixedFilePos := Int64(-1);

  if FStream = nil then
    Exit;

  try
    FStream.Position := 0;

    while FStream.Position < FStream.Size do
    begin
      DataStart := FStream.Position;
      if not ReadResourceEntry(HeaderSize, DataSize, ResType) then
        Break;

      if ResType = RT_VERSION_INT then
      begin
        FVersionInfoStart := DataStart;
        FVersionDataSize := DataSize;

        // 版本信息资源的数据结构是 VS_VERSIONINFO:
        //   wLength (WORD), wValueLength (WORD), wType (WORD),
        //   szKey ("VS_VERSION_INFO\0" = 32 bytes),
        //   Padding (对齐到 DWORD),
        //   Value (VS_FIXEDFILEINFO)
        // 需要先跳过头部，才能读到 VS_FIXEDFILEINFO

        // 定位到数据区起始: DataStart + HeaderSize
        FStream.Position := DataStart + HeaderSize;

        if DataSize >= 6 then
        begin
          // 读取 VS_VERSIONINFO 头部
          if FStream.Read(wLength, SizeOf(Word)) <> SizeOf(Word) then
          begin
            FStream.Position := DataStart + HeaderSize + DataSize;
            AlignStream(FStream);
            Continue;
          end;
          if FStream.Read(wValueLength, SizeOf(Word)) <> SizeOf(Word) then
          begin
            FStream.Position := DataStart + HeaderSize + DataSize;
            AlignStream(FStream);
            Continue;
          end;
          if FStream.Read(wType, SizeOf(Word)) <> SizeOf(Word) then
          begin
            FStream.Position := DataStart + HeaderSize + DataSize;
            AlignStream(FStream);
            Continue;
          end;

          // 读取 szKey，应该是 "VS_VERSION_INFO"
          if FStream.Read(KeyBuf, SizeOf(KeyBuf)) <> SizeOf(KeyBuf) then
          begin
            FStream.Position := DataStart + HeaderSize + DataSize;
            AlignStream(FStream);
            Continue;
          end;

          // 对齐到 DWORD
          AlignStream(FStream);

          // 现在流位置应在 VS_FIXEDFILEINFO 处
          FixedFilePos := FStream.Position;

          if wValueLength >= SizeOf(TCnVSFixedFileInfo) then
          begin
            if FStream.Read(FixedInfo, SizeOf(FixedInfo)) = SizeOf(FixedInfo) then
            begin
              if FixedInfo.dwSignature = VS_FFI_SIGNATURE then
              begin
                FFixedFilePos := FixedFilePos;
                Major := HiWord(FixedInfo.dwFileVersionMS);
                Minor := LoWord(FixedInfo.dwFileVersionMS);
                Release := HiWord(FixedInfo.dwFileVersionLS);
                Build := LoWord(FixedInfo.dwFileVersionLS);

                Result := True;
                Exit;
              end;
            end;
          end;
        end;
      end;

      // Skip to next entry (DWORD aligned)
      FStream.Position := DataStart + HeaderSize + DataSize;
      AlignStream(FStream);
    end;
  except
    Result := False;
    FVersionInfoStart := Int64(-1);
    FFixedFilePos := Int64(-1);
  end;
end;

function TCnResFile.SetVersionInfo(Major, Minor, Release, Build: Integer;
  LangID, CodePage: Integer): Boolean;
var
  FixedInfo: TCnVSFixedFileInfo;
begin
  Result := False;

  if FStream = nil then
    Exit;
  if FVersionInfoStart < 0 then
  begin
    // Try to find it first
    if not GetVersionInfo(Major, Minor, Release, Build, LangID, CodePage) then
      Exit;
  end;

  if FFixedFilePos < 0 then
    Exit;

  try
    // 定位到 VS_FIXEDFILEINFO 所在位置
    FStream.Position := FFixedFilePos;

    // Read and update fixed info
    if FStream.Read(FixedInfo, SizeOf(FixedInfo)) = SizeOf(FixedInfo) then
    begin
      if FixedInfo.dwSignature = VS_FFI_SIGNATURE then
      begin
        // Update version numbers
        FixedInfo.dwFileVersionMS := MakeLong(Word(Minor), Word(Major));
        FixedInfo.dwFileVersionLS := MakeLong(Word(Build), Word(Release));
        FixedInfo.dwProductVersionMS := MakeLong(Word(Minor), Word(Major));
        FixedInfo.dwProductVersionLS := MakeLong(Word(Build), Word(Release));

        // Write back
        FStream.Position := FFixedFilePos;
        FStream.WriteBuffer(FixedInfo, SizeOf(FixedInfo));

        Result := True;
        Exit;
      end;
    end;
  except
    Result := False;
  end;
end;

function CnReadProjectResVersion(const ResFileName: string; var Major, Minor, Release, Build: Integer): Boolean;
var
  ResFile: TCnResFile;
  LangID, CodePage: Integer;
begin
  Result := False;
  ResFile := TCnResFile.Create(ResFileName);
  try
    Result := ResFile.GetVersionInfo(Major, Minor, Release, Build, LangID, CodePage);
  finally
    ResFile.Free;
  end;
end;

function CnWriteProjectResVersion(const ResFileName: string; Major, Minor, Release, Build: Integer): Boolean;
var
  ResFile: TCnResFile;
begin
  Result := False;
  ResFile := TCnResFile.Create(ResFileName);
  try
    Result := ResFile.SetVersionInfo(Major, Minor, Release, Build, $0409, 1252);
  finally
    ResFile.Free;
  end;
end;

{ TCnVersionInfo }

constructor TCnVersionInfo.Create(AModule: THandle);
var
  resHandle: THandle;
begin
  FModule := AModule;
  FChildStrings := TStringList.Create;
  FTranslations := TList.Create;
  resHandle := FindResource(FModule, Pointer(1), RT_VERSION);
  if resHandle <> 0 then
  begin
    FVersionResHandle := LoadResource(FModule, resHandle);
    if FVersionResHandle <> 0 then
      FVersionInfo := LockResource(FVersionResHandle)
  end;

  if not Assigned(FVersionInfo) then
    raise Exception.Create('Unable to load version info resource');
end;

constructor TCnVersionInfo.Create(AVersionInfo: PChar);
begin
  FChildStrings := TStringList.Create;
  FTranslations := TList.Create;
  FVersionInfo := AVersionInfo;
end;

destructor TCnVersionInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to FChildStrings.Count - 1 do
    FChildStrings.Objects[I].Free;

  FChildStrings.Free;
  FTranslations.Free;
  if FVersionResHandle <> 0 then
    FreeResource(FVersionResHandle);

  inherited;
end;

function TCnVersionInfo.GetInfo: boolean;
var
  P: PChar;
  T, wLength, wValueLength, wType: Word;
  Key: string;
  varwLength, varwValueLength, varwType: Word;
  varKey: string;

  function GetVersionHeader(var P: PChar; var wLength, wValueLength, wType: Word; var Key: string): Integer;
  var
    szKey: PWideChar;
    baseP: PChar;
  begin
    baseP := P;
    wLength := PWord(P)^;
    Inc(P, sizeof(Word));
    wValueLength := PWord(P)^;
    Inc(P, sizeof(Word));
    wType := PWord(P)^;
    Inc(P, sizeof(Word));
    szKey := PWideChar(P);
    Inc(P, (lstrlenw(szKey) + 1) * sizeof(WideChar));
    while Integer(P) mod 4 <> 0 do
      Inc(P);
    Result := P - baseP;
    Key := szKey;
  end;

  procedure GetStringChildren(var Base: PChar; Len: Word);
  var
    P, strBase: PChar;
    T, wLength, wValueLength, wType, wStrLength, wStrValueLength, wStrType: Word;
    Key, Value: string;
    I, LangID, CodePage: Integer;
  begin
    P := Base;
    while (P - Base) < Len do
    begin
      T := GetVersionHeader(P, wLength, wValueLength, wType, Key);
      Dec(wLength, T);

      LangID := StrToInt('$' + Copy(Key, 1, 4));
      CodePage := StrToInt('$' + Copy(Key, 5, 4));

      strBase := P;
      for I := 0 to FChildStrings.Count - 1 do
        FChildStrings.Objects[I].Free;
      FChildStrings.Clear;

      while (P - strBase) < wLength do
      begin
        T := GetVersionHeader(P, wStrLength, wStrValueLength, wStrType, Key);
        Dec(wStrLength, T);

        if wStrValueLength = 0 then
          Value := ''
        else
          Value := PWideChar(P);
        Inc(P, wStrLength);
        while Integer(P) mod 4 <> 0 do
          Inc(P);

        FChildStrings.AddObject(Key, TCnVersionStringValue.Create(Value, LangID, CodePage))
      end
    end;
    Base := P
  end;

  procedure GetVarChildren(var Base: PChar; Len: Word);
  var
    P, strBase: PChar;
    T, wLength, wValueLength, wType: Word;
    Key: string;
    v: DWORD;
  begin
    P := Base;
    while (P - Base) < Len do
    begin
      T := GetVersionHeader(P, wLength, wValueLength, wType, Key);
      Dec(wLength, T);

      strBase := P;
      FTranslations.Clear;

      while (P - strBase) < wLength do
      begin
        v := PDWORD(P)^;
        Inc(P, sizeof(DWORD));
        FTranslations.Add(Pointer(v));
      end
    end;
    Base := P
  end;

begin
  Result := False;
  if not Assigned(FFixedInfo) then
  try
    P := FVersionInfo;
    GetVersionHeader(P, wLength, wValueLength, wType, Key);

    if wValueLength <> 0 then
    begin
      FFixedInfo := PVSFixedFileInfo(P);
      if FFixedInfo^.dwSignature <> $feef04bd then
        raise Exception.Create('Invalid version resource');

      Inc(P, wValueLength);
      while Integer(P) mod 4 <> 0 do
        Inc(P);
    end
    else
      FFixedInfo := nil;

    while wLength > (P - FVersionInfo) do
    begin
      T := GetVersionHeader(P, varwLength, varwValueLength, varwType, varKey);
      Dec(varwLength, T);

      if varKey = 'StringFileInfo' then
        GetStringChildren(P, varwLength)
      else if varKey = 'VarFileInfo' then
        GetVarChildren(P, varwLength)
      else
        break;
    end;

    Result := True;
  except
  end
  else
    Result := True
end;

function TCnVersionInfo.GetKeyCount: Integer;
begin
  if GetInfo then
    Result := FChildStrings.Count
  else
    Result := 0;
end;

function TCnVersionInfo.GetKeyName(Index: Integer): string;
begin
  if Index >= KeyCount then
    raise ERangeError.Create('Index out of range')
  else
    Result := FChildStrings[Index];
end;

function TCnVersionInfo.GetKeyValue(const Index: string): string;
var
  I: Integer;
begin
  if GetInfo then
  begin
    I := FChildStrings.IndexOf(Index);
    if I <> -1 then
      Result := TCnVersionStringValue(FChildStrings.Objects[I]).FValue
    else
      raise Exception.Create('Key not found')
  end
  else
    raise Exception.Create('Key not found')
end;

procedure TCnVersionInfo.SaveToStream(strm: TStream);
var
  zeros, v: DWORD;
  wSize: Word;
  stringInfoStream: TMemoryStream;
  strg: TCnVersionStringValue;
  I, P, p1: Integer;
  wValue: WideString;

  procedure PadStream(strm: TStream);
  begin
    if strm.Position mod 4 <> 0 then
      strm.Write(zeros, 4 - (strm.Position mod 4))
  end;

  procedure SaveVersionHeader(strm: TStream; wLength, wValueLength, wType: Word; const Key: string; const Value);
  var
    wKey: WideString;
    valueLen: Word;
    keyLen: Word;
  begin
    wKey := Key;
    strm.Write(wLength, sizeof(wLength));

    strm.Write(wValueLength, sizeof(wValueLength));
    strm.Write(wType, sizeof(wType));
    keyLen := (Length(wKey) + 1) * sizeof(WideChar);
    strm.Write(wKey[1], keyLen);

    PadStream(strm);

    if wValueLength > 0 then
    begin
      valueLen := wValueLength;
      if wType = 1 then
        valueLen := valueLen * sizeof(WideChar);
      strm.Write(Value, valueLen)
    end;
  end;

begin { SaveToStream }
  if GetInfo then
  begin
    zeros := 0;

    SaveVersionHeader(strm, 0, sizeof(FFixedInfo^), 0, 'VS_VERSION_INFO', FFixedInfo^);

    if FChildStrings.Count > 0 then
    begin
      stringInfoStream := TMemoryStream.Create;
      try
        strg := TCnVersionStringValue(FChildStrings.Objects[0]);

        SaveVersionHeader(stringInfoStream, 0, 0, 0, IntToHex(strg.FLangID, 4) + IntToHex(strg.FCodePage, 4), zeros);

        for I := 0 to FChildStrings.Count - 1 do
        begin
          PadStream(stringInfoStream);

          P := stringInfoStream.Position;
          strg := TCnVersionStringValue(FChildStrings.Objects[I]);
          wValue := strg.FValue;
          SaveVersionHeader(stringInfoStream, 0, Length(strg.FValue) + 1, 1, FChildStrings[I], wValue[1]);
          wSize := stringInfoStream.Size - P;
          stringInfoStream.Seek(P, soFromBeginning);
          stringInfoStream.Write(wSize, sizeof(wSize));
          stringInfoStream.Seek(0, soFromEnd);

        end;

        stringInfoStream.Seek(0, soFromBeginning);
        wSize := stringInfoStream.Size;
        stringInfoStream.Write(wSize, sizeof(wSize));

        PadStream(strm);
        P := strm.Position;
        SaveVersionHeader(strm, 0, 0, 0, 'StringFileInfo', zeros);
        strm.Write(stringInfoStream.Memory^, stringInfoStream.size);
        wSize := strm.Size - P;
      finally
        stringInfoStream.Free
      end;
      strm.Seek(P, soFromBeginning);
      strm.Write(wSize, sizeof(wSize));
      strm.Seek(0, soFromEnd)
    end;

    if FTranslations.Count > 0 then
    begin
      PadStream(strm);
      P := strm.Position;
      SaveVersionHeader(strm, 0, 0, 0, 'VarFileInfo', zeros);
      PadStream(strm);

      p1 := strm.Position;
      SaveVersionHeader(strm, 0, 0, 0, 'Translation', zeros);

      for I := 0 to FTranslations.Count - 1 do
      begin
        v := Integer(FTranslations[I]);
        strm.Write(v, sizeof(v))
      end;

      wSize := strm.Size - p1;
      strm.Seek(p1, soFromBeginning);
      strm.Write(wSize, sizeof(wSize));
      wSize := sizeof(Integer) * FTranslations.Count;
      strm.Write(wSize, sizeof(wSize));

      wSize := strm.Size - P;
      strm.Seek(P, soFromBeginning);
      strm.Write(wSize, sizeof(wSize));
    end;

    strm.Seek(0, soFromBeginning);
    wSize := strm.Size;
    strm.Write(wSize, sizeof(wSize));
    strm.Seek(0, soFromEnd);
  end
  else
    raise Exception.Create('Invalid version resource');
end;

procedure TCnVersionInfo.SetKeyValue(const Index, Value: string);
var
  I: Integer;
  AObj: TObject;
begin
  if GetInfo then
  begin
    I := FChildStrings.IndexOf(Index);
    if I = -1 then
      I := FChildStrings.AddObject(Index, TCnVersionStringValue.Create(Index, 0, 0));

    if Trim(Value) = '' then
    begin
      AObj := FChildStrings.Objects[I];
      FChildStrings.Delete(I);
      AObj.Free;
    end
    else
      TCnVersionStringValue(FChildStrings.Objects[I]).FValue := Value
  end
  else
    raise Exception.Create('Invalid version resource');
end;

{ TCnVersionStringValue }

constructor TCnVersionStringValue.Create(const AValue: string; ALangID, ACodePage: Integer);
begin
  FValue := AValue;
  FCodePage := ACodePage;
  FLangID := ALangID;
end;

end.

