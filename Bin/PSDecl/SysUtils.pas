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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit SysUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 SysUtils 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

type

  TSysCharSet = set of Char;

  TFileName = type string;

  TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;

  TTimeStamp = record
    Time: Integer;                      { Number of milliseconds since midnight }
    Date: Integer;                      { One plus number of days since 1/1/0001 }
  end;

  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

const
  MinDateTime: TDateTime = -657434.0;   { 01/01/0100 12:00:00.000 AM }
  MaxDateTime: TDateTime = 2958465.99999; { 12/31/9999 11:59:59.999 PM }

function AllocMem(Size: Cardinal): Pointer;

function UpperCase(const S: string): string;

function LowerCase(const S: string): string;

function CompareStr(const S1, S2: string): Integer;

function CompareText(const S1, S2: string): Integer;

function SameText(const S1, S2: string): Boolean;

function AnsiUpperCase(const S: string): string;

function AnsiLowerCase(const S: string): string;

function AnsiCompareStr(const S1, S2: string): Integer;

function AnsiSameStr(const S1, S2: string): Boolean;

function AnsiCompareText(const S1, S2: string): Integer;

function AnsiSameText(const S1, S2: string): Boolean;

function AnsiStrComp(S1, S2: PChar): Integer;

function AnsiStrIComp(S1, S2: PChar): Integer;

function AnsiStrLComp(S1, S2: PChar; MaxLen: Cardinal): Integer;

function AnsiStrLIComp(S1, S2: PChar; MaxLen: Cardinal): Integer;

function AnsiStrLower(Str: PChar): PChar;

function AnsiStrUpper(Str: PChar): PChar;

function AnsiLastChar(const S: string): PChar;

function AnsiStrLastChar(P: PChar): PChar;

function QuotedStr(const S: string): string;

function AnsiQuotedStr(const S: string; Quote: Char): string;

function AnsiExtractQuotedStr(var Src: PChar; Quote: Char): string;

function IsValidIdent(const Ident: string): Boolean;

function IntToHex(Value: Integer; Digits: Integer): string;

function StrToInt(const S: string): Integer;

function StrToIntDef(const S: string; Default: Integer): Integer;

function StrToInt64(const S: string): Int64;

function StrToInt64Def(const S: string; const Default: Int64): Int64;

function LoadStr(Ident: Integer): string;

function FmtLoadStr(Ident: Integer; const Args: array of const): string;

function FileAge(const FileName: string): Integer;

function FileExists(const FileName: string): Boolean;

function DirectoryExists(const Directory: string): Boolean;

function ForceDirectories(Dir: string): Boolean;

function FindFirst(const Path: string; Attr: Integer; var F: TSearchRec): Integer;

function FindNext(var F: TSearchRec): Integer;

procedure FindClose(var F: TSearchRec);

function FileGetAttr(const FileName: string): Integer;

function FileSetAttr(const FileName: string; Attr: Integer): Integer;

function DeleteFile(const FileName: string): Boolean;

function RenameFile(const OldName, NewName: string): Boolean;

function ChangeFileExt(const FileName, Extension: string): string;

function ExtractFilePath(const FileName: string): string;

function ExtractFileDir(const FileName: string): string;

function ExtractFileDrive(const FileName: string): string;

function ExtractFileName(const FileName: string): string;

function ExtractFileExt(const FileName: string): string;

function ExpandFileName(const FileName: string): string;

function ExpandUNCFileName(const FileName: string): string;

function ExtractRelativePath(const BaseName, DestName: string): string;

function ExtractShortPathName(const FileName: string): string;

function FileSearch(const Name, DirList: string): string;

function DiskFree(Drive: Byte): Int64;

function DiskSize(Drive: Byte): Int64;

function FileDateToDateTime(FileDate: Integer): TDateTime;

function DateTimeToFileDate(DateTime: TDateTime): Integer;

function GetCurrentDir: string;

function SetCurrentDir(const Dir: string): Boolean;

function CreateDir(const Dir: string): Boolean;

function RemoveDir(const Dir: string): Boolean;

function StrLen(const Str: PChar): Cardinal;

function StrEnd(const Str: PChar): PChar;

function StrMove(Dest: PChar; const Source: PChar; Count: Cardinal): PChar;

function StrCopy(Dest: PChar; const Source: PChar): PChar;

function StrECopy(Dest: PChar; const Source: PChar): PChar;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar;

function StrPCopy(Dest: PChar; const Source: string): PChar;

function StrPLCopy(Dest: PChar; const Source: string; MaxLen: Cardinal): PChar;

function StrCat(Dest: PChar; const Source: PChar): PChar;

function StrLCat(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar;

function StrComp(const Str1, Str2: PChar): Integer;

function StrIComp(const Str1, Str2: PChar): Integer;

function StrLComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer;

function StrLIComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer;

function StrPos(const Str1, Str2: PChar): PChar;

function StrUpper(Str: PChar): PChar;

function StrLower(Str: PChar): PChar;

function Format(const Format: string; const Args: array of const): string;

function FloatToStr(Value: Extended): string;

function CurrToStr(Value: Currency): string;

function StrToFloat(const S: string): Extended;

function StrToCurr(const S: string): Currency;

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;

function TimeStampToDateTime(const TimeStamp: TTimeStamp): TDateTime;

function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;

function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;

function EncodeDate(Year, Month, Day: Word): TDateTime;

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);

procedure DecodeTime(Time: TDateTime; var Hour, Min, Sec, MSec: Word);

function DateTimeToUnix(D: TDateTime): Int64;

function UnixToDateTime(U: Int64): TDateTime;

procedure DateTimeToSystemTime(const DateTime: TDateTime; var SystemTime: TSystemTime);

function SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;

function DayOfWeek(const DateTime: TDateTime): Word;

function Date: TDateTime;

function Time: TDateTime;

function Now: TDateTime;

function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer): TDateTime;

procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime);

procedure ReplaceDate(var DateTime: TDateTime; const NewDate: TDateTime);

function IsLeapYear(Year: Word): Boolean;

function DateToStr(const DateTime: TDateTime): string;

function TimeToStr(const DateTime: TDateTime): string;

function DateTimeToStr(const DateTime: TDateTime): string;

function StrToDate(const S: string): TDateTime;

function StrToTime(const S: string): TDateTime;

function StrToDateTime(const S: string): TDateTime;

function FormatDateTime(const Format: string; DateTime: TDateTime): string;

procedure DateTimeToString(var Result: string; const Format: string; DateTime: TDateTime);

function LoadLibrary(ModuleName: PChar): HMODULE;

function FreeLibrary(Module: HMODULE): LongBool;

function GetProcAddress(Module: HMODULE; Proc: PChar): Pointer;

function GetModuleHandle(ModuleName: PChar): HMODULE;

procedure Abort;

procedure Beep;

function ByteType(const S: string; Index: Integer): TMbcsByteType;

function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType;

function ByteToCharLen(const S: string; MaxLen: Integer): Integer;

function CharToByteLen(const S: string; MaxLen: Integer): Integer;

function ByteToCharIndex(const S: string; Index: Integer): Integer;

function CharToByteIndex(const S: string; Index: Integer): Integer;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;

function IsDelimiter(const Delimiters, S: string; Index: Integer): Boolean;

function IncludeTrailingBackslash(const S: string): string;

function ExcludeTrailingBackslash(const S: string): string;

function LastDelimiter(const Delimiters, S: string): Integer;

function AnsiCompareFileName(const S1, S2: string): Integer;

function AnsiLowerCaseFileName(const S: string): string;

function AnsiUpperCaseFileName(const S: string): string;

function AnsiPos(const Substr, S: string): Integer;

function AnsiStrPos(Str, SubStr: PChar): PChar;

type
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;

function WrapText(const Line: string; MaxCol: Integer): string;

function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet; IgnoreCase: Boolean): Boolean;

procedure RaiseLastWin32Error;

function Win32Check(RetVal: BOOL): BOOL;

function SafeLoadLibrary(const FileName: string; ErrorMode: UINT): HMODULE;

function CreateGUID(out Guid: TGUID): HResult;

function StringToGUID(const S: string): TGUID;

function GUIDToString(const GUID: TGUID): string;

function IsEqualGUID(const guid1, guid2: TGUID): Boolean;

implementation

end.

