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

unit CnBaseUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：分析基础库
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2007.08.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DELPHI7_UP}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}

uses
  SysUtils, Windows, Classes, CnBuffStr, CnCommon;

type
  TStringProcessProc = function(const s: string): string;

  TStringObjectList = class(TStringList)
  private
    function GetStringObjects(Index: Integer): string;
    procedure SetStringObjects(Index: Integer; const Value: string);

    procedure ClearStringObjects;
  public
    constructor Create;
    destructor Destroy; override;

    function AddStringObject(const S: string; str: string): Integer;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;

    property StringObjects[Index: Integer]: string read GetStringObjects write SetStringObjects;
  end;

  TSectionList = class(TStringList)
  private
    function GetPostions(Index: Integer): TList;
    procedure SetPostions(Index: Integer; const Value: TList);
  public
    constructor Create;
    destructor Destroy; override;

    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;

    property Postions[Index: Integer]: TList read GetPostions write SetPostions;
  end;
  
  TFindFileCallBack = procedure(obj: TObject;
    const FileName: string; const Info: TSearchRec; var Abort: Boolean);
  TFindDirCallBack = procedure(obj: TObject; const SubDir: string);
  TProcMsgCallBack = procedure(obj: TObject);
  
procedure BulidSectionList(Stream: TStringReader; var sl: TSectionList);
procedure FreeSectionList(var sl: TSectionList);

procedure StringsLoadFromFileWithSection(ss: TStrings;
  const FileName: string; const Section: string = '';
  const SectionList: TSectionList = nil;
  IncludeBlankLine: Boolean = False);
procedure StringsLoadFromTextWithSection(ss: TStrings;
  Stream: TStringReader; const Section: string = '';
  const SectionList: TSectionList = nil;
  IncludeBlankLine: Boolean = False);
procedure StringsSaveToFileWithSection(ss: TStrings;
  FileName: string; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);
procedure StringsAppendToFileWithSection(ss: TStrings;
  FileName: string; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);
procedure StringsSaveToTextWithSection(ss: TStrings;
  var Stream: Text; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);

function MatchFileName(const Mask, FileName: string): Boolean;
procedure FileMasksToStrings(const FileMasks: string; MaskList: TStrings;
  CaseSensitive: Boolean);
function FileMatchesMasks(const FileName, FileMasks: string;
  CaseSensitive: Boolean = False): Boolean; overload;
function FileMatchesMasks(const FileName: string; MaskList: TStrings;
  CaseSensitive: Boolean = False): Boolean; overload;

function RefString(const S: string): Pointer;
procedure ReleaseString(P: Pointer);
function PointerToString(P: Pointer): string; 

procedure SetCommaText(const s: string; ss: TStrings);

function ExtractFileNames(ssFiles, ssNames, ssDuplicated: TStringList): Boolean;

function DirListExtractFileNames(ssFiles, ssNames, ssDuplicated: TStrings): Boolean;

function FindFile(obj: TObject;
  const Path: string; const FileName: string = '*.*';
  FileProc: TFindFileCallBack = nil; DirProc: TFindDirCallBack = nil;
  bSub: Boolean = True; DoMsgProc: TProcMsgCallBack = nil): Boolean;

function IsDelimiter(const S: string; Delimiter: Char; Index: Integer): Boolean;
function LastCharPos(const s: string; chr: Char): Integer;

function RelativePath_API(const aFrom, aTo: string;
  FromIsDir, ToIsDir: Boolean): string;

function FileNameMatch(Pattern, FileName: PChar): Integer;
function MatchExt(const ext, FileName: string): Boolean;
procedure FileExtsToStrings(const FileExts: string; ExtList: TStrings;
  CaseSensitive: Boolean);

procedure FileMasksToStringsStrict(const FileMasks: string; MaskList: TStrings;
  CaseSensitive: Boolean);

  function FileMatchesExts(const FileName, FileExts: string;
  CaseSensitive: Boolean = False): Boolean; overload;
function FileMatchesExts(const FileName: string; ExtList: TStrings;
  CaseSensitive: Boolean = False): Boolean; overload;

implementation

const
  cSectionStart = '[';
  cSectionEnd = ']';

function StringIsSection(const s: string): Boolean; overload;
begin
  Result := (s <> '') and (s[1] = cSectionStart) and (s[Length(s)] = cSectionEnd) and (s <> '[]');
end;

function StringIsSection(const s: string; var Section: string): Boolean; overload;
begin
  Result := StringIsSection(s);
  if Result then
  begin
    Section := Copy(s, 2, Length(s) - 2);
  end;
end;

function SectionToString(const s: string): string;
begin
  Result := cSectionStart + s + cSectionEnd;
end;

function _Max(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

{ TSectionList }

function TSectionList.Add(const S: string): Integer;
var
  lst: TList;
begin
  Result := inherited Add(S); // 不能调用 AddObject(s, nil)，否则会递归出错;
  if Objects[Result] = nil then
  begin
    lst := TList.Create;
    Objects[Result] := lst;
  end;
end;

procedure TSectionList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Objects[i].Free;
  end;
  inherited;
end;

constructor TSectionList.Create;
begin
  inherited;
  Sorted := True;
end;

procedure TSectionList.Delete(Index: Integer);
begin
  Objects[Index].Free;
  inherited;
end;

destructor TSectionList.Destroy;
begin
  Clear;
  inherited;
end;

function TSectionList.GetPostions(Index: Integer): TList;
begin
  Result := TList(Objects[Index]);
end;

procedure TSectionList.SetPostions(Index: Integer; const Value: TList);
begin
  Objects[Index].Free;
  PutObject(Index, Value);
end;

function FindSection(sl: TSectionList; const Section: string; const iSection: Integer = -1): Integer; 
var
  i, idx: Integer;
begin
  Result := -1;
  idx := sl.IndexOf(Section);
  if idx >= 0 then
  begin
    with sl.Postions[idx] do
    begin
      if iSection >= 0 then
      begin
        i := IndexOf(Pointer(iSection));
        if (i >= 0) and (i + 1 < Count) then
        begin
          Result := Integer(Items[i + 1]);
        end;
      end
      else
      begin
        Result := Integer(Items[0]);
      end;
    end;
  end;
end;

procedure BulidSectionList(Stream: TStringReader; var sl: TSectionList);
var
  s, Section: string;
  i: Integer;
begin
  sl := TSectionList.Create;

  Stream.Seek(0, soFromBeginning);
  while not Stream.EoS do
  begin
    s := Stream.ReadLn;
    if StringIsSection(s, Section) then
    begin
      i := sl.Add(Section);
      sl.Postions[i].Add(Pointer(Stream.Position));
    end;
  end;
end;

procedure FreeSectionList(var sl: TSectionList);
begin
  sl.Free;
end;

procedure StringsLoadFromFileWithSection(ss: TStrings;
  const FileName: string; const Section: string = '';
  const SectionList: TSectionList = nil;
  IncludeBlankLine: Boolean = False);
var
  i: Integer;
  Stream: TStringReader;
begin
  if not Assigned(ss) then
  begin
    Exit;
  end;

  if Section = '' then
  begin
    ss.LoadFromFile(FileName);

    if not IncludeBlankLine then
    begin
      for i := ss.Count - 1 downto 0 do
      begin
        if ss[i] = '' then
        begin
          ss.Delete(i);
        end;
      end;
    end;

    Exit;
  end;

  Stream := TStringReader.Create;
  try
    Stream.LoadFromFile(FileName);
    StringsLoadFromTextWithSection(ss, Stream, Section, SectionList, IncludeBlankLine);
  finally
    Stream.Free;
  end;
end;

procedure StringsLoadFromTextWithSection(ss: TStrings;
  Stream: TStringReader; const Section: string = '';
  const SectionList: TSectionList = nil;
  IncludeBlankLine: Boolean = False);
var
  IsSection, IsCurrentSection: Boolean;
  s, sSection: string;
  iSection: Integer;
begin
  if not Assigned(ss) then
  begin
    Exit;
  end;

  Stream.Seek(0, soFromBeginning);

  IsCurrentSection := False;

  ss.BeginUpdate;
  try
    if Section = '' then
    begin
      while not Stream.EoS do
      begin
        s := Stream.ReadLn;
        if (not IncludeBlankLine) and (s = '') then
        begin
          Continue;
        end;
        ss.Add(s);
      end;
    end
    else if Assigned(SectionList) then
    begin
      iSection := FindSection(SectionList, Section);
      while iSection >= 0 do
      begin
        Stream.Seek(iSection, soFromBeginning);
        while not Stream.EoS do
        begin
          s := Stream.ReadLn;
          if (not IncludeBlankLine) and (s = '') then
          begin
            Continue;
          end;
          if StringIsSection(s) then
          begin
            Break;
          end;
          ss.Add(s);
        end;
        iSection := FindSection(SectionList, Section, iSection);
      end;
    end
    else
    begin
      sSection := SectionToString(Section);
      while not Stream.EoS do
      begin
        s := Stream.ReadLn;
        if (s = '') and (not IncludeBlankLine) then
        begin
          Continue;
        end;

        IsSection := StringIsSection(s);
        if IsSection then
        begin
          IsCurrentSection := s = sSection;
        end;
        if (not IsCurrentSection) or IsSection then
        begin
          Continue;
        end;
        ss.Add(s);
      end;
    end;
  finally
    ss.EndUpdate;
  end;
end;

procedure StringsSaveToFileWithSection(ss: TStrings;
  FileName: string; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);
var
  Stream: TextFile;
begin
  if not Assigned(ss) then
  begin
    Exit;
  end;

  AssignFile(Stream, FileName);
  try
    Reset(Stream);
    Rewrite(Stream);
    StringsSaveToTextWithSection(ss, Stream, Section, IncludeBlankLine, ProcessProc);
  finally
    CloseFile(Stream);
  end;
end;

procedure StringsAppendToFileWithSection(ss: TStrings;
  FileName: string; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);
var
  Stream: TextFile;
begin
  if not Assigned(ss) then
  begin
    Exit;
  end;

  AssignFile(Stream, FileName);
  try
    Append(Stream);
    StringsSaveToTextWithSection(ss, Stream, Section, IncludeBlankLine, ProcessProc);
  finally
    CloseFile(Stream);
  end;
end;

procedure StringsSaveToTextWithSection(ss: TStrings;
  var Stream: Text; const Section: string;
  IncludeBlankLine: Boolean = False;
  ProcessProc: TStringProcessProc = nil);
var
  i: Integer;
begin
  if not Assigned(ss) then
  begin
    Exit;
  end;

  if FilePos(Stream) > 0 then
  begin
    Writeln(Stream);
  end;

  Writeln(Stream, SectionToString(Section));
  for i := 0 to ss.Count - 1 do
  begin
    if (not IncludeBlankLine) and (ss[i] = '') then
    begin
      Continue;
    end;

    if Assigned(ProcessProc) then
    begin
      Writeln(Stream, ProcessProc(ss[i]));
    end
    else
    begin
      Writeln(Stream, ss[i]);
    end;
  end;
end;

function PointerXX(var X: PChar): PChar;
{$IFDEF PUREPASCAL}
begin
  Result := X;
  Inc(X);
end;
{$ELSE}
asm
  {
  EAX = X
  }
  MOV EDX, [EAX]
  INC dword ptr [EAX]
  MOV EAX, EDX
end;
{$ENDIF}

// Evaluate operation

function Evaluate(var X: Char; const Value: Char): Char;
{$IFDEF PUREPASCAL}
begin
  X := Value;
  Result := X;
end;
{$ELSE}
asm
  {
  EAX = X
  EDX = Value (DL)
  }
  MOV [EAX], DL
  MOV AL, [EAX]
end;
{$ENDIF}

function FileNameMatch(Pattern, FileName: PChar): Integer;
var
  p, n: PChar;
  c: Char;
begin
  p := Pattern;
  n := FileName;

  while Evaluate(c, PointerXX(p)^) <> #0 do
  begin
    case c of
      '?':
        begin
          if n^ = '.' then
          begin
            while (p^ <> '.') and (p^ <> #0) do
            begin
              if (p^ <> '?') and (p^ <> '*') then
              begin
                Result := -1;
                Exit;
              end;
              Inc(p);
            end;
          end
          else
          begin
            if n^ <> #0 then
            begin
              Inc(n);
            end;
          end;
        end;

      '>':
        begin
          if n^ = '.' then
          begin
            if ((n + 1)^ = #0) and (FileNameMatch(p, n + 1) = 0) then
            begin
              Result := 0;
              Exit;
            end;
            if FileNameMatch(p, n) = 0 then
            begin
              Result := 0;
              Exit;
            end;
            Result := -1;
            Exit;
          end;
          if n^ = #0 then
          begin
            Result := FileNameMatch(p, n);
            Exit;
          end;
          Inc(n);
        end;

      '*':
        begin
          while n^ <> #0 do
          begin
            if FileNameMatch(p, n) = 0 then
            begin
              Result := 0;
              Exit;
            end;
            Inc(n);
          end;
        end;

      '<':
        begin
          while n^ <> #0 do
          begin
            if FileNameMatch(p, n) = 0 then
            begin
              Result := 0;
              Exit;
            end;
            if (n^ = '.') and (StrScan(n + 1, '.') = nil) then
            begin
              Inc(n);
              Break;
            end;
            Inc(n);
          end;
        end;

      '"':
        begin
          if (n^ = #0) and (FileNameMatch(p, n) = 0) then
          begin
            Result := 0;
            Exit;
          end;
          if n^ <> '.' then
          begin
            Result := -1;
            Exit;
          end;
          Inc(n);
        end;
    else
      if (c = '.') and (n^ = #0) then
      begin
        while p^ <> #0 do
        begin
          if (p^ = '*') and ((p + 1)^ = #0) then
          begin
            Result := 0;
            Exit;
          end;
          if p^ <> '?' then
          begin
            Result := -1;
            Exit;
          end;
          Inc(p);
        end;
        Result := 0;
        Exit;
      end;
      if c <> n^ then
      begin
        Result := -1;
        Exit;
      end;
      Inc(n);
    end;
  end;

  if n^ = #0 then
  begin
    Result := 0;
    Exit;
  end;

  Result := -1;
end;

function MatchFileName(const Mask, FileName: string): Boolean;
begin
  if Mask = '*.*' then
  begin
    Result := True;
    Exit;
  end;

  Result := FileNameMatch(PChar(Mask), PChar(FileName)) = 0;
end;

function _CaseSensitive(const CaseSensitive: Boolean; const S: string): string;
begin
  if CaseSensitive then
    Result := S
  else
    Result := AnsiUpperCase(S);
end;

procedure FileMasksToStrings(const FileMasks: string; MaskList: TStrings;
  CaseSensitive: Boolean);
var
  Masks: string;
  i: Integer;
begin
  Masks := StringReplace(FileMasks, ';', ',', [rfReplaceAll]);
  SetCommaText(Masks, MaskList);

  for i := MaskList.Count - 1 downto 0 do
  begin
    if MaskList[i] = '' then
    begin
      MaskList.Delete(i);
      Continue;
    end;

    if StrScan(PChar(MaskList[i]), '.') <> nil then
    begin
      if (MaskList[i] <> '') and (MaskList[i][1] = '.') then
        MaskList[i] := '*' + _CaseSensitive(CaseSensitive, MaskList[i])
      else
        MaskList[i] := _CaseSensitive(CaseSensitive, MaskList[i]);
    end
    else
    begin
      MaskList[i] := '*.' + _CaseSensitive(CaseSensitive, MaskList[i]);
    end;
    if MaskList[i] = '*.*' then
    begin
      if i > 0 then
        MaskList.Exchange(0, i);
      Exit;
    end;
  end;
end;

function FileMatchesMasks(const FileName, FileMasks: string;
  CaseSensitive: Boolean = False): Boolean;
var
  MaskList: TStrings;
  FFileName: string;
  i: Integer;
begin
  MaskList := TStringList.Create;
  try
    FileMasksToStrings(FileMasks, MaskList, CaseSensitive);

    FFileName := _CaseSensitive(CaseSensitive, _CnExtractFileName(FileName));
    Result := False;
    for i := 0 to MaskList.Count - 1 do
    begin
      if MatchFileName(MaskList[i], FFileName) then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    MaskList.Free;
  end;
end;

function FileMatchesMasks(const FileName: string; MaskList: TStrings;
  CaseSensitive: Boolean = False): Boolean;
var
  FFileName: string;
  i: Integer;
begin
  FFileName := _CaseSensitive(CaseSensitive, _CnExtractFileName(FileName));

  Result := False;
  for i := 0 to MaskList.Count - 1 do
  begin
    if MatchFileName(MaskList[i], FFileName) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function RefString(const S: string): Pointer;
var
  tmpS: string;
begin
  tmpS := S;
  Result := Pointer(tmpS);
  Pointer(tmpS) := nil;
end;

procedure ReleaseString(P: Pointer);
var
  tmpS: string;
begin
  Pointer(tmpS) := P;
end;

function PointerToString(P: Pointer): string;
begin
  Result := StrPas(P);
end;

procedure SetCommaText(const s: string; ss: TStrings);
begin
  if Assigned(ss) then
  begin
    if s <> '' then
    begin
      ss.CommaText := s;
    end
    else
    begin
      ss.Clear;
    end;
  end;
end;

function ExtractFileNames(ssFiles, ssNames, ssDuplicated: TStringList): Boolean;
var
  i, idx: Integer;
  s: string;
begin
  Result := False;

  if (not Assigned(ssFiles)) or (not Assigned(ssNames)) then
  begin
    Exit;
  end;

  ssNames.Clear;
  ssNames.Sorted := True;
  Result := True;
  for i := 0 to ssFiles.Count - 1 do
  begin
    s := _CnExtractFileName(ssFiles[i]);
    idx := ssNames.IndexOf(s);
    if idx >= 0 then
    begin
      Result := False;
      if Assigned(ssDuplicated) then
      begin
        ssDuplicated.Add(ssFiles[Integer(ssNames.Objects[idx])]);
        ssDuplicated.Add(ssFiles[i]);
        ssDuplicated.Add('');
      end;
      Continue;
    end;
    ssNames.AddObject(s, Pointer(i));
  end;
end;

function DirListExtractFileNames(ssFiles, ssNames, ssDuplicated: TStrings): Boolean;
var
  i, idx: Integer;
  s: string;
begin
  Result := False;

  if (not Assigned(ssFiles)) or (not Assigned(ssNames)) then
  begin
    Exit;
  end;

  ssNames.Clear;
  Result := True;
  for i := 0 to ssFiles.Count - 1 do
  begin
    s := _CnExtractFileName(ssFiles[i]);
    idx := ssNames.IndexOf(s);
    if idx >= 0 then
    begin
      Result := False;
      if Assigned(ssDuplicated) then
      begin
        ssDuplicated.Add(s);
      end;
      Continue;
    end;
    ssNames.AddObject(s, Pointer(i));
  end;
end;

{ TStringObjectList }

function TStringObjectList.AddStringObject(const S: string;
  str: string): Integer;
begin
  Result := AddObject(S, RefString(str));
end;

procedure TStringObjectList.Clear;
begin
  ClearStringObjects;
  inherited;
end;

procedure TStringObjectList.ClearStringObjects;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    ReleaseString(Objects[i]);
  end;
end;

constructor TStringObjectList.Create;
begin
  inherited;
end;

procedure TStringObjectList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
  begin
    Exit;
  end;
  ReleaseString(Objects[Index]);
  inherited;
end;

destructor TStringObjectList.Destroy;
begin
  Clear;
  inherited;
end;

function TStringObjectList.GetStringObjects(Index: Integer): string;
begin
  Result := PointerToString(Objects[Index]);
end;

procedure TStringObjectList.SetStringObjects(Index: Integer;
  const Value: string);
begin
  if (Index < 0) or (Index >= Count) then
  begin
    Exit;
  end;
  ReleaseString(Objects[Index]);
  PutObject(Index, RefString(Value));
end;

function DirectoryExists(const Directory: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Directory));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function FindFile(obj: TObject;
  const Path: string; const FileName: string = '*.*';
  FileProc: TFindFileCallBack = nil; DirProc: TFindDirCallBack = nil;
  bSub: Boolean = True; DoMsgProc: TProcMsgCallBack = nil): Boolean;
var
  FindAbort: Boolean;

  procedure DoFindFile(obj: TObject;
    const Path, SubPath: string; const FileName: string;
    FileProc: TFindFileCallBack; DirProc: TFindDirCallBack;
    bSub: Boolean; DoMsgProc: TProcMsgCallBack);
  var
    APath: string;
    Info: TSearchRec;
    Succ: Integer;
  begin
    FindAbort := False;
    APath := MakePath(
      MakePath(Path) + SubPath);
    Succ := FindFirst(APath + FileName, faAnyFile {- faVolumeID}, Info);
    try
      while Succ = 0 do
      begin
        if (Info.Name <> '.') and (Info.Name <> '..') then
        begin
          if (Info.Attr and faDirectory) <> faDirectory then
          begin
            if Assigned(FileProc) then
            begin
              FileProc(obj, APath + Info.FindData.cFileName, Info, FindAbort);
            end;
          end;
        end;

        if Assigned(DoMsgProc) then
        begin
          DoMsgProc(obj);
        end;

        if FindAbort then
        begin
          Exit;
        end;
        Succ := FindNext(Info);
      end;
    finally
      SysUtils.FindClose(Info);
    end;

    if bSub then
    begin
      Succ := FindFirst(APath + '*.*', faAnyFile {- faVolumeID}, Info);
      try
        while Succ = 0 do
        begin
          if (Info.Name <> '.') and (Info.Name <> '..') and
            (Info.Attr and faDirectory = faDirectory) then
          begin
            if Assigned(DirProc) then
            begin
              DirProc(obj, MakePath(SubPath + Info.Name));
            end;

            DoFindFile(obj,
              Path,
              MakePath(SubPath + Info.Name),
              FileName,
              FileProc,
              DirProc,
              bSub,
              DoMsgProc);

            if FindAbort then
            begin
              Exit;
            end;
          end;
          Succ := FindNext(Info);
        end;
      finally
        SysUtils.FindClose(Info);
      end;
    end;
  end;

begin
  Result := False;
  if not DirectoryExists(Path) then
  begin
    Exit;
  end;

  DoFindFile(obj,
    MakePath(Path),
    '',
    FileName,
    FileProc,
    DirProc,
    bSub,
    DoMsgProc);
  Result := not FindAbort;
end;

function IsDelimiter(const S: string; Delimiter: Char; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and
    (S[Index] = Delimiter) and (ByteType(S, Index) = mbSingleByte);
end;

function LastCharPos(const s: string; chr: Char): Integer;
var
  i: Integer;
begin
  i := Length(s);
  while (i > 0) and (not IsDelimiter(s, chr, i)) do
  begin
    Dec(i);
  end;
  Result := i;
end;

const
  shlwapi32 = 'shlwapi.dll';
  
function PathRelativePathToA(pszPath: PAnsiChar; pszFrom: PAnsiChar; dwAttrFrom: DWORD;
  pszTo: PAnsiChar; dwAttrTo: DWORD): BOOL; stdcall; external shlwapi32 name
  'PathRelativePathToA';

function PathRelativePathToW(pszPath: PWideChar; pszFrom: PWideChar; dwAttrFrom: DWORD;
  pszTo: PWideChar; dwAttrTo: DWORD): BOOL; stdcall; external shlwapi32 name
  'PathRelativePathToW';

function PathRelativePathTo(pszPath: PChar; pszFrom: PChar; dwAttrFrom: DWORD;
  pszTo: PChar; dwAttrTo: DWORD): BOOL; stdcall; external shlwapi32 name
  'PathRelativePathToA';

function RelativePath_API(const aFrom, aTo: string; FromIsDir, ToIsDir: Boolean): string;
  function GetAttr(IsDir: Boolean): DWORD;
  begin
    if IsDir then
      Result := FILE_ATTRIBUTE_DIRECTORY
    else
      Result := FILE_ATTRIBUTE_NORMAL;
  end;
var
  p: array[0..MAX_PATH] of Char;
begin
  PathRelativePathTo(p, PChar(aFrom), GetAttr(FromIsDir), PChar(aTo), GetAttr(ToIsDir));
  Result := StrPas(p);
end;


function MatchExt(const ext, FileName: string): Boolean;
begin
  if ext = '.*' then
  begin
    Result := True;
    Exit;
  end;

  Result := FileNameMatch(PChar(ext), PChar(FileName)) = 0;
end;


procedure FileExtsToStrings(const FileExts: string; ExtList: TStrings;
  CaseSensitive: Boolean);
var
  Exts: string;
  i: Integer;
begin
  Exts := StringReplace(FileExts, ';', ',', [rfReplaceAll]);
  ExtList.CommaText := Exts;

  for i := ExtList.Count - 1 downto 0 do
  begin
    if ExtList[i] = '' then
    begin
      ExtList.Delete(i);
      Continue;
    end;

    if StrScan(PChar(ExtList[i]), '.') <> nil then
    begin
      ExtList[i] := _CaseSensitive(CaseSensitive, _CnExtractFileExt(ExtList[i]));
    end
    else
    begin
      ExtList[i] := '.' + _CaseSensitive(CaseSensitive, ExtList[i]);
    end;
    if ExtList[i] = '.*' then
    begin
      if i > 0 then
        ExtList.Exchange(0, i);
      Exit;
    end;
  end;
end;

procedure FileMasksToStringsStrict(const FileMasks: string; MaskList: TStrings;
  CaseSensitive: Boolean);
var
  Exts: string;
  i: Integer;
begin
  Exts := StringReplace(FileMasks, ';', ',', [rfReplaceAll]);
  MaskList.CommaText := Exts;

  for i := MaskList.Count - 1 downto 0 do
  begin
    if MaskList[i] = '' then
    begin
      MaskList.Delete(i);
      Continue;
    end;

    MaskList[i] := _CaseSensitive(CaseSensitive, MaskList[i]);

    if MaskList[i] = '*.*' then
    begin
      if i > 0 then
        MaskList.Exchange(0, i);
      Exit;
    end;
  end;
end;

function FileMatchesExts(const FileName, FileExts: string;
  CaseSensitive: Boolean = False): Boolean;
var
  ExtList: TStrings;
  FExt: string;
  i: Integer;
begin
  ExtList := TStringList.Create;
  try
    FileExtsToStrings(FileExts, ExtList, CaseSensitive);

    FExt := _CaseSensitive(CaseSensitive, _CnExtractFileExt(FileName));
    Result := False;
    for i := 0 to ExtList.Count - 1 do
    begin
      if MatchExt(ExtList[i], FExt) then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    ExtList.Free;
  end;
end;

function FileMatchesExts(const FileName: string; ExtList: TStrings;
  CaseSensitive: Boolean = False): Boolean;
var
  FExt: string;
  i: Integer;
begin
  FExt := _CaseSensitive(CaseSensitive, _CnExtractFileExt(FileName));

  Result := False;
  for i := 0 to ExtList.Count - 1 do
  begin
    if MatchExt(ExtList[i], FExt) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
