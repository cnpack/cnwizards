{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from mrExperts 1.9.1                                 }
{                                                                              }
{ Original author:                                                             }
{    Miha Remec  http://www.miharemec.com/mrExperts/                           }
{******************************************************************************}

unit VersionInfo;

interface

uses Windows, Classes, SysUtils;
type
  TVersionInfo = class
  fModule : THandle;
  fVersionInfo : PChar;
  fVersionHeader : PChar;
  fChildStrings : TStringList;
  fTranslations : TList;
  fFixedInfo : PVSFixedFileInfo;
  fVersionResHandle : THandle;

  private
    function GetInfo : boolean;
    function GetKeyCount: Integer;
    function GetKeyName(idx: Integer): string;
    function GetKeyValue(const idx: string): string;
    procedure SetKeyValue(const idx, Value: string);
  public
    constructor Create (AModule : THandle); overload;
    constructor Create (AVersionInfo : PChar); overload;
    destructor Destroy; override;
    procedure SaveToStream (strm : TStream);

    property KeyCount : Integer read GetKeyCount;
    property KeyName [idx : Integer] : string read GetKeyName;
    property KeyValue [const idx : string] : string read GetKeyValue write SetKeyValue;
  end;

implementation

{ TVersionInfo }

type
TVersionStringValue = class
  fValue : string;
  fLangID, fCodePage : Integer;

  constructor Create (const AValue : string; ALangID, ACodePage : Integer);
end;

procedure DisplayMessage (const msg : string);
begin
  MessageBox (0, PChar (msg), '', MB_ICONINFORMATION)
end;

constructor TVersionInfo.Create(AModule: THandle);
var
  resHandle : THandle;
begin
  fModule := AModule;
  fChildStrings := TStringList.Create;
  fTranslations := TList.Create;
  resHandle := FindResource (fModule, pointer (1), RT_VERSION);
  if resHandle <> 0 then
  begin
    fVersionResHandle := LoadResource (fModule, resHandle);
    if fVersionResHandle <> 0 then
      fVersionInfo := LockResource (fVersionResHandle)
  end;

  if not Assigned (fVersionInfo) then
    raise Exception.Create ('Unable to load version info resource');
end;

constructor TVersionInfo.Create(AVersionInfo: PChar);
begin
  fChildStrings := TStringList.Create;
  fTranslations := TList.Create;
  fVersionInfo := AVersionInfo;
end;

destructor TVersionInfo.Destroy;
var
  i : Integer;
begin
  for i := 0 to fChildStrings.Count - 1 do
    fChildStrings.Objects [i].Free;

  fChildStrings.Free;
  fTranslations.Free;
  if fVersionResHandle <> 0 then
    FreeResource (fVersionResHandle);
  inherited;
end;

function TVersionInfo.GetInfo : boolean;
var
  p : PChar;
  t, wLength, wValueLength, wType : word;
  key : string;

  varwLength, varwValueLength, varwType : word;
  varKey : string;

  function GetVersionHeader (var p : PChar; var wLength, wValueLength, wType : word; var key : string) : Integer;
  var
    szKey : PWideChar;
    baseP : PChar;
  begin
    baseP := p;
    wLength := PWord (p)^;
    Inc (p, sizeof (word));
    wValueLength := PWord (p)^;
    Inc (p, sizeof (word));
    wType := PWord (p)^;
    Inc (p, sizeof (word));
    szKey := PWideChar (p);
    Inc (p, (lstrlenw (szKey) + 1) * sizeof (WideChar));
    while Integer (p) mod 4 <> 0 do
      Inc (p);
    result := p - baseP;
    key := szKey;
  end;

  procedure GetStringChildren (var base : PChar; len : word);
  var
    p, strBase : PChar;
    t, wLength, wValueLength, wType, wStrLength, wStrValueLength, wStrType : word;
    key, value : string;
    i, langID, codePage : Integer;

  begin
    p := base;
    while (p - base) < len do
    begin
      t := GetVersionHeader (p, wLength, wValueLength, wType, key);
      Dec (wLength, t);

      langID := StrToInt ('$' + Copy (key, 1, 4));
      codePage := StrToInt ('$' + Copy (key, 5, 4));

      strBase := p;
      for i := 0 to fChildStrings.Count - 1 do
        fChildStrings.Objects [i].Free;
      fChildStrings.Clear;

      while (p - strBase) < wLength do
      begin
        t := GetVersionHeader (p, wStrLength, wStrValueLength, wStrType, key);
        Dec (wStrLength, t);

        if wStrValueLength = 0 then
          value := ''
        else
          value := PWideChar (p);
        Inc (p, wStrLength);
        while Integer (p) mod 4 <> 0 do
          Inc (p);

        fChildStrings.AddObject (key, TVersionStringValue.Create (value, langID, codePage))
      end
    end;
    base := p
  end;

  procedure GetVarChildren (var base : PChar; len : word);
  var
    p, strBase : PChar;
    t, wLength, wValueLength, wType: word;
    key : string;
    v : DWORD;

  begin
    p := base;
    while (p - base) < len do
    begin
      t := GetVersionHeader (p, wLength, wValueLength, wType, key);
      Dec (wLength, t);

      strBase := p;
      fTranslations.Clear;

      while (p - strBase) < wLength do
      begin
        v := PDWORD (p)^;
        Inc (p, sizeof (DWORD));
        fTranslations.Add (pointer (v));
      end
    end;
    base := p
  end;

begin
  result := False;
  if not Assigned (fFixedInfo) then
  try
    p := fVersionInfo;
    GetVersionHeader (p, wLength, wValueLength, wType, key);

    if wValueLength <> 0 then
    begin
      fFixedInfo := PVSFixedFileInfo (p);
      if fFixedInfo^.dwSignature <> $feef04bd then
        raise Exception.Create ('Invalid version resource');

      Inc (p, wValueLength);
      while Integer (p) mod 4 <> 0 do
        Inc (p);
    end
    else
      fFixedInfo := Nil;

    while wLength > (p - fVersionInfo) do
    begin
      t := GetVersionHeader (p, varwLength, varwValueLength, varwType, varKey);
      Dec (varwLength, t);

      if varKey = 'StringFileInfo' then
        GetStringChildren (p, varwLength)
      else
        if varKey = 'VarFileInfo' then
          GetVarChildren (p, varwLength)
        else
          break;
    end;

    result := True;
  except
  end
  else
    result := True
end;

function TVersionInfo.GetKeyCount: Integer;
begin
  if GetInfo then
    result := fChildStrings.Count
  else
    result := 0;
end;

function TVersionInfo.GetKeyName(idx: Integer): string;
begin
  if idx >= KeyCount then
    raise ERangeError.Create ('Index out of range')
  else
    result := fChildStrings [idx];
end;

function TVersionInfo.GetKeyValue(const idx: string): string;
var
  i : Integer;
begin
  if GetInfo then
  begin
    i := fChildStrings.IndexOf (idx);
    if i <> -1 then
      result := TVersionStringValue (fChildStrings.Objects [i]).fValue
    else
      raise Exception.Create ('Key not found')
  end
  else
    raise Exception.Create ('Key not found')
end;

procedure TVersionInfo.SaveToStream(strm: TStream);
var
  zeros, v : DWORD;
  wSize : WORD;
  stringInfoStream : TMemoryStream;
  strg : TVersionStringValue;
  i, p, p1 : Integer;
  wValue : WideString;

  procedure PadStream (strm : TStream);
  begin
    if strm.Position mod 4 <> 0 then
      strm.Write (zeros, 4 - (strm.Position mod 4))
  end;

  procedure SaveVersionHeader (strm : TStream; wLength, wValueLength, wType : word; const key : string; const value);
  var
    wKey : WideString;
    valueLen : word;
    keyLen : word;
  begin
    wKey := key;
    strm.Write (wLength, sizeof (wLength));

    strm.Write (wValueLength, sizeof (wValueLength));
    strm.Write (wType, sizeof (wType));
    keyLen := (Length (wKey) + 1) * sizeof (WideChar);
    strm.Write (wKey [1], keyLen);

    PadStream (strm);

    if wValueLength > 0 then
    begin
      valueLen := wValueLength;
      if wType = 1 then
        valueLen := valueLen * sizeof (WideChar);
      strm.Write (value, valueLen)
    end;
  end;

begin { SaveToStream }
  if GetInfo then
  begin
    zeros := 0;

    SaveVersionHeader (strm, 0, sizeof (fFixedInfo^), 0, 'VS_VERSION_INFO', fFixedInfo^);

    if fChildStrings.Count > 0 then
    begin
      stringInfoStream := TMemoryStream.Create;
      try
        strg := TVersionStringValue (fChildStrings.Objects [0]);

        SaveVersionHeader (stringInfoStream, 0, 0, 0, IntToHex (strg.fLangID, 4) + IntToHex (strg.fCodePage, 4), zeros);

        for i := 0 to fChildStrings.Count - 1 do
        begin
          PadStream (stringInfoStream);

          p := stringInfoStream.Position;
          strg := TVersionStringValue (fChildStrings.Objects [i]);
          wValue := strg.fValue;
          SaveVersionHeader (stringInfoStream, 0, Length (strg.fValue) + 1, 1, fChildStrings [i], wValue [1]);
          wSize := stringInfoStream.Size - p;
          stringInfoStream.Seek (p, soFromBeginning);
          stringInfoStream.Write (wSize, sizeof (wSize));
          stringInfoStream.Seek (0, soFromEnd);

        end;

        stringInfoStream.Seek (0, soFromBeginning);
        wSize := stringInfoStream.Size;
        stringInfoStream.Write (wSize, sizeof (wSize));

        PadStream (strm);
        p := strm.Position;
        SaveVersionHeader (strm, 0, 0, 0, 'StringFileInfo', zeros);
        strm.Write (stringInfoStream.Memory^, stringInfoStream.size);
        wSize := strm.Size - p;
      finally
        stringInfoStream.Free
      end;
      strm.Seek (p, soFromBeginning);
      strm.Write (wSize, sizeof (wSize));
      strm.Seek (0, soFromEnd)
    end;

    if fTranslations.Count > 0 then
    begin
      PadStream (strm);
      p := strm.Position;
      SaveVersionHeader (strm, 0, 0, 0, 'VarFileInfo', zeros);
      PadStream (strm);

      p1 := strm.Position;
      SaveVersionHeader (strm, 0, 0, 0, 'Translation', zeros);

      for i := 0 to fTranslations.Count - 1 do
      begin
        v := Integer (fTranslations [i]);
        strm.Write (v, sizeof (v))
      end;

      wSize := strm.Size - p1;
      strm.Seek (p1, soFromBeginning);
      strm.Write (wSize, sizeof (wSize));
      wSize := sizeof (Integer) * fTranslations.Count;
      strm.Write (wSize, sizeof (wSize));

      wSize := strm.Size - p;
      strm.Seek (p, soFromBeginning);
      strm.Write (wSize, sizeof (wSize));
    end;

    strm.Seek (0, soFromBeginning);
    wSize := strm.Size;
    strm.Write (wSize, sizeof (wSize));
    strm.Seek (0, soFromEnd);
  end
  else
    raise Exception.Create ('Invalid version resource');
end;

procedure TVersionInfo.SetKeyValue(const idx, Value: string);
var
  i : Integer;
  AObj:TObject;
begin
  if GetInfo then
  begin
    i := fChildStrings.IndexOf (idx);
    if i = -1 then
      i := fChildStrings.AddObject (idx, TVersionStringValue.Create (idx, 0, 0));

    if Trim(Value)='' then
    begin
      AObj:=fChildStrings.Objects[I];
      fChildStrings.Delete(I);
      AObj.Free;
    end
    else
    TVersionStringValue (fChildStrings.Objects [i]).fValue := Value
  end
  else
    raise Exception.Create ('Invalid version resource');
end;

{ TVersionStringValue }

constructor TVersionStringValue.Create(const AValue: string; ALangID,
  ACodePage: Integer);
begin
  fValue := AValue;
  fCodePage := ACodePage;
  fLangID := ALangID;
end;

end.
