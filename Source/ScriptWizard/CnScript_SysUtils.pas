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

unit CnScript_SysUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 SysUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, FileCtrl, Classes, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_SysUtils = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_SysUtils(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_SysUtils_Routines(S: TPSExec);

implementation

resourcestring
  SInvalidGUID = '''%s'' is not a valid GUID value';

procedure SIRegister_SysUtils(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TSysCharSet', 'set of Char');
  CL.AddTypeS('TFileName', 'string');
  CL.AddTypeS('TSearchRec', 'record Time : Integer; Size : Integer; Attr : Inte'
    + 'ger; Name : TFileName; ExcludeAttr : Integer; FindHandle : THandle; FindDa'
    + 'ta : TWin32FindData; end');
  CL.AddTypeS('TTimeStamp', 'record Time : Integer; Date : Integer; end');
  CL.AddTypeS('TMbcsByteType', '( mbSingleByte, mbLeadByte, mbTrailByte )');
  CL.AddDelphiFunction('Function AllocMem( Size : Cardinal) : Pointer');
  CL.AddDelphiFunction('Function UpperCase( const S : string) : string');
  CL.AddDelphiFunction('Function LowerCase( const S : string) : string');
  CL.AddDelphiFunction('Function CompareStr( const S1, S2 : string) : Integer');
  CL.AddDelphiFunction('Function CompareText( const S1, S2 : string) : Integer');
  CL.AddDelphiFunction('Function SameText( const S1, S2 : string) : Boolean');
  CL.AddDelphiFunction('Function AnsiUpperCase( const S : string) : string');
  CL.AddDelphiFunction('Function AnsiLowerCase( const S : string) : string');
  CL.AddDelphiFunction('Function AnsiCompareStr( const S1, S2 : string) : Integer');
  CL.AddDelphiFunction('Function AnsiSameStr( const S1, S2 : string) : Boolean');
  CL.AddDelphiFunction('Function AnsiCompareText( const S1, S2 : string) : Integer');
  CL.AddDelphiFunction('Function AnsiSameText( const S1, S2 : string) : Boolean');
  CL.AddDelphiFunction('Function AnsiStrComp( S1, S2 : PChar) : Integer');
  CL.AddDelphiFunction('Function AnsiStrIComp( S1, S2 : PChar) : Integer');
  CL.AddDelphiFunction('Function AnsiStrLComp( S1, S2 : PChar; MaxLen : Cardinal) : Integer');
  CL.AddDelphiFunction('Function AnsiStrLIComp( S1, S2 : PChar; MaxLen : Cardinal) : Integer');
  CL.AddDelphiFunction('Function AnsiStrLower( Str : PChar) : PChar');
  CL.AddDelphiFunction('Function AnsiStrUpper( Str : PChar) : PChar');
  CL.AddDelphiFunction('Function AnsiLastChar( const S : string) : PChar');
  CL.AddDelphiFunction('Function AnsiStrLastChar( P : PChar) : PChar');
  CL.AddDelphiFunction('Function QuotedStr( const S : string) : string');
  CL.AddDelphiFunction('Function AnsiQuotedStr( const S : string; Quote : Char) : string');
  CL.AddDelphiFunction('Function AnsiExtractQuotedStr( var Src : PChar; Quote : Char) : string');
  CL.AddDelphiFunction('Function IsValidIdent( const Ident : string) : Boolean');
  CL.AddDelphiFunction('Function IntToHex( Value : Integer; Digits : Integer) : string;');
  CL.AddDelphiFunction('Function StrToInt( const S : string) : Integer');
  CL.AddDelphiFunction('Function StrToIntDef( const S : string; Default : Integer) : Integer');
  CL.AddDelphiFunction('Function StrToInt64( const S : string) : Int64');
  CL.AddDelphiFunction('Function StrToInt64Def( const S : string; const Default : Int64) : Int64');
  CL.AddDelphiFunction('Function LoadStr( Ident : Integer) : string');
  CL.AddDelphiFunction('Function FmtLoadStr( Ident : Integer; const Args : array of const) : string');
  CL.AddDelphiFunction('Function FileAge( const FileName : string) : Integer');
  CL.AddDelphiFunction('Function FileExists( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function DirectoryExists( const Directory : string) : Boolean');
  CL.AddDelphiFunction('Function ForceDirectories( Dir : string) : Boolean');
  CL.AddDelphiFunction('Function FindFirst( const Path : string; Attr : Integer; var F : TSearchRec) : Integer');
  CL.AddDelphiFunction('Function FindNext( var F : TSearchRec) : Integer');
  CL.AddDelphiFunction('Procedure FindClose( var F : TSearchRec)');
  CL.AddDelphiFunction('Function FileGetAttr( const FileName : string) : Integer');
  CL.AddDelphiFunction('Function FileSetAttr( const FileName : string; Attr : Integer) : Integer');
  CL.AddDelphiFunction('Function DeleteFile( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function RenameFile( const OldName, NewName : string) : Boolean');
  CL.AddDelphiFunction('Function ChangeFileExt( const FileName, Extension : string) : string');
  CL.AddDelphiFunction('Function ExtractFilePath( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExtractFileDir( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExtractFileDrive( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExtractFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExtractFileExt( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExpandFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExpandUNCFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function ExtractRelativePath( const BaseName, DestName : string) : string');
  CL.AddDelphiFunction('Function ExtractShortPathName( const FileName : string) : string');
  CL.AddDelphiFunction('Function FileSearch( const Name, DirList : string) : string');
  CL.AddDelphiFunction('Function DiskFree( Drive : Byte) : Int64');
  CL.AddDelphiFunction('Function DiskSize( Drive : Byte) : Int64');
  CL.AddDelphiFunction('Function FileDateToDateTime( FileDate : Integer) : TDateTime');
  CL.AddDelphiFunction('Function DateTimeToFileDate( DateTime : TDateTime) : Integer');
  CL.AddDelphiFunction('Function GetCurrentDir : string');
  CL.AddDelphiFunction('Function SetCurrentDir( const Dir : string) : Boolean');
  CL.AddDelphiFunction('Function CreateDir( const Dir : string) : Boolean');
  CL.AddDelphiFunction('Function RemoveDir( const Dir : string) : Boolean');
  CL.AddDelphiFunction('Function StrLen( const Str : PChar) : Cardinal');
  CL.AddDelphiFunction('Function StrEnd( const Str : PChar) : PChar');
  CL.AddDelphiFunction('Function StrMove( Dest : PChar; const Source : PChar; Count : Cardinal) : PChar');
  CL.AddDelphiFunction('Function StrCopy( Dest : PChar; const Source : PChar) : PChar');
  CL.AddDelphiFunction('Function StrECopy( Dest : PChar; const Source : PChar) : PChar');
  CL.AddDelphiFunction('Function StrLCopy( Dest : PChar; const Source : PChar; MaxLen : Cardinal) : PChar');
  CL.AddDelphiFunction('Function StrPCopy( Dest : PChar; const Source : string) : PChar');
  CL.AddDelphiFunction('Function StrPLCopy( Dest : PChar; const Source : string; MaxLen : Cardinal) : PChar');
  CL.AddDelphiFunction('Function StrCat( Dest : PChar; const Source : PChar) : PChar');
  CL.AddDelphiFunction('Function StrLCat( Dest : PChar; const Source : PChar; MaxLen : Cardinal) : PChar');
  CL.AddDelphiFunction('Function StrComp( const Str1, Str2 : PChar) : Integer');
  CL.AddDelphiFunction('Function StrIComp( const Str1, Str2 : PChar) : Integer');
  CL.AddDelphiFunction('Function StrLComp( const Str1, Str2 : PChar; MaxLen : Cardinal) : Integer');
  CL.AddDelphiFunction('Function StrLIComp( const Str1, Str2 : PChar; MaxLen : Cardinal) : Integer');
  CL.AddDelphiFunction('Function StrPos( const Str1, Str2 : PChar) : PChar');
  CL.AddDelphiFunction('Function StrUpper( Str : PChar) : PChar');
  CL.AddDelphiFunction('Function StrLower( Str : PChar) : PChar');
  CL.AddDelphiFunction('Function Format( const Format : string; const Args : array of const) : string;');
  CL.AddDelphiFunction('Function FloatToStr( Value : Extended) : string;');
  CL.AddDelphiFunction('Function CurrToStr( Value : Currency) : string;');
  CL.AddDelphiFunction('Function StrToFloat( const S : string) : Extended;');
  CL.AddDelphiFunction('Function StrToCurr( const S : string) : Currency;');
  CL.AddDelphiFunction('Function DateTimeToTimeStamp( DateTime : TDateTime) : TTimeStamp');
  CL.AddDelphiFunction('Function TimeStampToDateTime( const TimeStamp : TTimeStamp) : TDateTime');
  CL.AddDelphiFunction('Function TryEncodeDate( Year, Month, Day : Word; out Date : TDateTime) : Boolean');
  CL.AddDelphiFunction('Function TryEncodeTime( Hour, Min, Sec, MSec : Word; out Time : TDateTime) : Boolean');
  CL.AddDelphiFunction('Function EncodeDate( Year, Month, Day : Word) : TDateTime');
  CL.AddDelphiFunction('Function EncodeTime( Hour, Min, Sec, MSec : Word) : TDateTime');
  CL.AddDelphiFunction('Procedure DecodeDate( const DateTime : TDateTime; var Year, Month, Day : Word)');
  CL.AddDelphiFunction('Procedure DecodeTime( Time : TDateTime; var Hour, Min, Sec, MSec : Word)');
  CL.AddDelphiFunction('Function DateTimeToUnix( D : TDateTime) : Int64');
  CL.AddDelphiFunction('Function UnixToDateTime( U : Int64) : TDateTime');
  CL.AddDelphiFunction('Procedure DateTimeToSystemTime( const DateTime : TDateTime; var SystemTime : TSystemTime)');
  CL.AddDelphiFunction('Function SystemTimeToDateTime( const SystemTime : TSystemTime) : TDateTime');
  CL.AddDelphiFunction('Function DayOfWeek( const DateTime : TDateTime) : Word');
  CL.AddDelphiFunction('Function Date : TDateTime');
  CL.AddDelphiFunction('Function Time : TDateTime');
  CL.AddDelphiFunction('Function Now : TDateTime');
  CL.AddDelphiFunction('Function IncMonth( const DateTime : TDateTime; NumberOfMonths : Integer) : TDateTime');
  CL.AddDelphiFunction('Procedure ReplaceTime( var DateTime : TDateTime; const NewTime : TDateTime)');
  CL.AddDelphiFunction('Procedure ReplaceDate( var DateTime : TDateTime; const NewDate : TDateTime)');
  CL.AddDelphiFunction('Function IsLeapYear( Year : Word) : Boolean');
  CL.AddDelphiFunction('Function DateToStr( const DateTime : TDateTime) : string;');
  CL.AddDelphiFunction('Function TimeToStr( const DateTime : TDateTime) : string;');
  CL.AddDelphiFunction('Function DateTimeToStr( const DateTime : TDateTime) : string;');
  CL.AddDelphiFunction('Function StrToDate( const S : string) : TDateTime;');
  CL.AddDelphiFunction('Function StrToTime( const S : string) : TDateTime;');
  CL.AddDelphiFunction('Function StrToDateTime( const S : string) : TDateTime;');
  CL.AddDelphiFunction('Function FormatDateTime( const Format : string; DateTime : TDateTime) : string;');
  CL.AddDelphiFunction('Procedure DateTimeToString( var Result : string; const Format : string; DateTime : TDateTime);');
  CL.AddConstantN('MinDateTime', 'TDateTime').SetExtended(-657434.0);
  CL.AddConstantN('MaxDateTime', 'TDateTime').SetExtended(2958465.99999);
  CL.AddDelphiFunction('Procedure Abort');
  CL.AddDelphiFunction('Procedure Beep');
  CL.AddDelphiFunction('Function ByteType( const S : string; Index : Integer) : TMbcsByteType');
  CL.AddDelphiFunction('Function StrByteType( Str : PChar; Index : Cardinal) : TMbcsByteType');
  CL.AddDelphiFunction('Function ByteToCharLen( const S : string; MaxLen : Integer) : Integer');
  CL.AddDelphiFunction('Function CharToByteLen( const S : string; MaxLen : Integer) : Integer');
  CL.AddDelphiFunction('Function ByteToCharIndex( const S : string; Index : Integer) : Integer');
  CL.AddDelphiFunction('Function CharToByteIndex( const S : string; Index : Integer) : Integer');
  CL.AddDelphiFunction('Function IsPathDelimiter( const S : string; Index : Integer) : Boolean');
  CL.AddDelphiFunction('Function IsDelimiter( const Delimiters, S : string; Index : Integer) : Boolean');
  CL.AddDelphiFunction('Function IncludeTrailingBackslash( const S : string) : string');
  CL.AddDelphiFunction('Function ExcludeTrailingBackslash( const S : string) : string');
  CL.AddDelphiFunction('Function LastDelimiter( const Delimiters, S : string) : Integer');
  CL.AddDelphiFunction('Function AnsiCompareFileName( const S1, S2 : string) : Integer');
  CL.AddDelphiFunction('Function AnsiLowerCaseFileName( const S : string) : string');
  CL.AddDelphiFunction('Function AnsiUpperCaseFileName( const S : string) : string');
  CL.AddDelphiFunction('Function AnsiPos( const Substr, S : string) : Integer');
  CL.AddDelphiFunction('Function AnsiStrPos( Str, SubStr : PChar) : PChar');
  CL.AddTypeS('TReplaceFlag', '( rfReplaceAll, rfIgnoreCase )');
  CL.AddTypeS('TReplaceFlags', 'set of TReplaceFlag');
  CL.AddDelphiFunction('Function StringReplace( const S, OldPattern, NewPattern : string; Flags : TReplaceFlags) : string');
  CL.AddDelphiFunction('Function WrapText( const Line : string; MaxCol : Integer) : string;');
  CL.AddDelphiFunction('Function FindCmdLineSwitch( const Switch : string; const Chars : TSysCharSet; IgnoreCase : Boolean) : Boolean;');
  CL.AddDelphiFunction('Procedure RaiseLastWin32Error');
  CL.AddDelphiFunction('Function Win32Check( RetVal : BOOL) : BOOL');
  CL.AddDelphiFunction('Function SafeLoadLibrary( const FileName : string; ErrorMode : UINT) : HMODULE');
  CL.AddDelphiFunction('Function CreateGUID(out Guid: TGUID): HResult');
  CL.AddDelphiFunction('Function StringToGUID(const S: string): TGUID');
  CL.AddDelphiFunction('Function GUIDToString(const GUID: TGUID): string');
  CL.AddDelphiFunction('Function IsEqualGUID(const guid1, guid2: TGUID): Boolean');
end;

(* === run-time registration functions === *)
function FindCmdLineSwitch_P(const Switch: string; const Chars: TSysCharSet; IgnoreCase: Boolean): Boolean;
begin
  Result := SysUtils.FindCmdLineSwitch(Switch, Chars, IgnoreCase);
end;

function WrapText_P(const Line: string; MaxCol: Integer): string;
begin
  Result := SysUtils.WrapText(Line, MaxCol);
end;

procedure DateTimeToString_P(var Result: string; const Format: string; DateTime: TDateTime);
begin
  SysUtils.DateTimeToString(Result, Format, DateTime);
end;

function FormatDateTime_P(const Format: string; DateTime: TDateTime): string;
begin
  Result := SysUtils.FormatDateTime(Format, DateTime);
end;

function StrToDateTime_P(const S: string): TDateTime;
begin
  Result := SysUtils.StrToDateTime(S);
end;

function StrToTime_P(const S: string): TDateTime;
begin
  Result := SysUtils.StrToTime(S);
end;

function StrToDate_P(const S: string): TDateTime;
begin
  Result := SysUtils.StrToDate(S);
end;

function DateTimeToStr_P(const DateTime: TDateTime): string;
begin
  Result := SysUtils.DateTimeToStr(DateTime);
end;

function TimeToStr_P(const DateTime: TDateTime): string;
begin
  Result := SysUtils.TimeToStr(DateTime);
end;

function DateToStr_P(const DateTime: TDateTime): string;
begin
  Result := SysUtils.DateToStr(DateTime);
end;

function StrToFloat_P(const S: string): Extended;
begin
  Result := SysUtils.StrToFloat(S);
end;

function FloatToStr_P(Value: Extended): string;
begin
  Result := SysUtils.FloatToStr(Value);
end;

function Format_P(const Format: string; const Args: array of const): string;
begin
  Result := SysUtils.Format(Format, Args);
end;

function IntToHex_P(Value: Integer; Digits: Integer): string;
begin
  Result := SysUtils.IntToHex(Value, Digits);
end;

function CoCreateGuid(out guid: TGUID): HResult; stdcall;
  external 'ole32.dll' name 'CoCreateGuid';
function StringFromCLSID(const clsid: TGUID; out psz: PWideChar): HResult; stdcall;
  external 'ole32.dll' name 'StringFromCLSID';
procedure CoTaskMemFree(pv: Pointer); stdcall;
  external 'ole32.dll' name 'CoTaskMemFree';
function CLSIDFromString(psz: PWideChar; out clsid: TGUID): HResult; stdcall;
  external 'ole32.dll' name 'CLSIDFromString';
function IsEqualGUID(const guid1, guid2: TGUID): Boolean; stdcall;
  external 'ole32.dll' name 'IsEqualGUID';

function CreateGUID(out Guid: TGUID): HResult;
begin
  Result := CoCreateGuid(Guid);
end;

function StringToGUID(const S: string): TGUID;
begin
  if not Succeeded(CLSIDFromString(PWideChar(WideString(S)), Result)) then
    EConvertError.CreateResFmt(@SInvalidGUID, [s]);
end;

function GUIDToString(const GUID: TGUID): string;
var
  P: PWideChar;
begin
  if not Succeeded(StringFromCLSID(GUID, P)) then
    EConvertError.CreateRes(@SInvalidGUID);
  Result := P;
  CoTaskMemFree(P);
end;

function IsEqualGUID_P(const guid1, guid2: TGUID): Boolean;
begin
  Result := IsEqualGUID(guid1, guid2);
end;  

function TryEncodeDate(Year, Month, Day: Word; var Date: TDateTime): Boolean;
begin
  try
    Date := EncodeDate(Year, Month, Day);
    Result := true;
  except
    Result := false;
  end;
end;

function TryEncodeTime(Hour, Min, Sec, MSec: Word; var Time: TDateTime): Boolean;
begin
  try
    Time := EncodeTime(hour, Min, Sec, MSec);
    Result := true;
  except
    Result := false;
  end;
end;

function DateTimeToUnix(D: TDateTime): Int64;
begin
  Result := Round((D - 25569) * 86400);
end;

function UnixToDateTime(U: Int64): TDateTime;
begin
  Result := U / 86400 + 25569;
end;

procedure RIRegister_SysUtils_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@AllocMem, 'AllocMem', cdRegister);
  S.RegisterDelphiFunction(@UpperCase, 'UpperCase', cdRegister);
  S.RegisterDelphiFunction(@LowerCase, 'LowerCase', cdRegister);
  S.RegisterDelphiFunction(@CompareStr, 'CompareStr', cdRegister);
  S.RegisterDelphiFunction(@CompareText, 'CompareText', cdRegister);
  S.RegisterDelphiFunction(@SameText, 'SameText', cdRegister);
  S.RegisterDelphiFunction(@AnsiUpperCase, 'AnsiUpperCase', cdRegister);
  S.RegisterDelphiFunction(@AnsiLowerCase, 'AnsiLowerCase', cdRegister);
  S.RegisterDelphiFunction(@AnsiCompareStr, 'AnsiCompareStr', cdRegister);
  S.RegisterDelphiFunction(@AnsiSameStr, 'AnsiSameStr', cdRegister);
  S.RegisterDelphiFunction(@AnsiCompareText, 'AnsiCompareText', cdRegister);
  S.RegisterDelphiFunction(@AnsiSameText, 'AnsiSameText', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrComp, 'AnsiStrComp', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrIComp, 'AnsiStrIComp', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrLComp, 'AnsiStrLComp', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrLIComp, 'AnsiStrLIComp', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrLower, 'AnsiStrLower', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrUpper, 'AnsiStrUpper', cdRegister);
  S.RegisterDelphiFunction(@AnsiLastChar, 'AnsiLastChar', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrLastChar, 'AnsiStrLastChar', cdRegister);
  S.RegisterDelphiFunction(@QuotedStr, 'QuotedStr', cdRegister);
  S.RegisterDelphiFunction(@AnsiQuotedStr, 'AnsiQuotedStr', cdRegister);
  S.RegisterDelphiFunction(@AnsiExtractQuotedStr, 'AnsiExtractQuotedStr', cdRegister);
  S.RegisterDelphiFunction(@IsValidIdent, 'IsValidIdent', cdRegister);
  S.RegisterDelphiFunction(@IntToHex_P, 'IntToHex', cdRegister);
  S.RegisterDelphiFunction(@StrToInt, 'StrToInt', cdRegister);
  S.RegisterDelphiFunction(@StrToIntDef, 'StrToIntDef', cdRegister);
  S.RegisterDelphiFunction(@StrToInt64, 'StrToInt64', cdRegister);
  S.RegisterDelphiFunction(@StrToInt64Def, 'StrToInt64Def', cdRegister);
  S.RegisterDelphiFunction(@LoadStr, 'LoadStr', cdRegister);
  S.RegisterDelphiFunction(@FmtLoadStr, 'FmtLoadStr', cdRegister);
  S.RegisterDelphiFunction(@FileAge, 'FileAge', cdRegister);
  S.RegisterDelphiFunction(@FileExists, 'FileExists', cdRegister);
  S.RegisterDelphiFunction(@DirectoryExists, 'DirectoryExists', cdRegister);
  S.RegisterDelphiFunction(@ForceDirectories, 'ForceDirectories', cdRegister);
  S.RegisterDelphiFunction(@FindFirst, 'FindFirst', cdRegister);
  S.RegisterDelphiFunction(@FindNext, 'FindNext', cdRegister);
  S.RegisterDelphiFunction(@FindClose, 'FindClose', cdRegister);
  S.RegisterDelphiFunction(@FileGetAttr, 'FileGetAttr', cdRegister);
  S.RegisterDelphiFunction(@FileSetAttr, 'FileSetAttr', cdRegister);
  S.RegisterDelphiFunction(@DeleteFile, 'DeleteFile', cdRegister);
  S.RegisterDelphiFunction(@RenameFile, 'RenameFile', cdRegister);
  S.RegisterDelphiFunction(@ChangeFileExt, 'ChangeFileExt', cdRegister);
  S.RegisterDelphiFunction(@ExtractFilePath, 'ExtractFilePath', cdRegister);
  S.RegisterDelphiFunction(@ExtractFileDir, 'ExtractFileDir', cdRegister);
  S.RegisterDelphiFunction(@ExtractFileDrive, 'ExtractFileDrive', cdRegister);
  S.RegisterDelphiFunction(@ExtractFileName, 'ExtractFileName', cdRegister);
  S.RegisterDelphiFunction(@ExtractFileExt, 'ExtractFileExt', cdRegister);
  S.RegisterDelphiFunction(@ExpandFileName, 'ExpandFileName', cdRegister);
  S.RegisterDelphiFunction(@ExpandUNCFileName, 'ExpandUNCFileName', cdRegister);
  S.RegisterDelphiFunction(@ExtractRelativePath, 'ExtractRelativePath', cdRegister);
  S.RegisterDelphiFunction(@ExtractShortPathName, 'ExtractShortPathName', cdRegister);
  S.RegisterDelphiFunction(@FileSearch, 'FileSearch', cdRegister);
  S.RegisterDelphiFunction(@DiskFree, 'DiskFree', cdRegister);
  S.RegisterDelphiFunction(@DiskSize, 'DiskSize', cdRegister);
  S.RegisterDelphiFunction(@FileDateToDateTime, 'FileDateToDateTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToFileDate, 'DateTimeToFileDate', cdRegister);
  S.RegisterDelphiFunction(@GetCurrentDir, 'GetCurrentDir', cdRegister);
  S.RegisterDelphiFunction(@SetCurrentDir, 'SetCurrentDir', cdRegister);
  S.RegisterDelphiFunction(@CreateDir, 'CreateDir', cdRegister);
  S.RegisterDelphiFunction(@RemoveDir, 'RemoveDir', cdRegister);
  S.RegisterDelphiFunction(@StrLen, 'StrLen', cdRegister);
  S.RegisterDelphiFunction(@StrEnd, 'StrEnd', cdRegister);
  S.RegisterDelphiFunction(@StrMove, 'StrMove', cdRegister);
  S.RegisterDelphiFunction(@StrCopy, 'StrCopy', cdRegister);
  S.RegisterDelphiFunction(@StrECopy, 'StrECopy', cdRegister);
  S.RegisterDelphiFunction(@StrLCopy, 'StrLCopy', cdRegister);
  S.RegisterDelphiFunction(@StrPCopy, 'StrPCopy', cdRegister);
  S.RegisterDelphiFunction(@StrPLCopy, 'StrPLCopy', cdRegister);
  S.RegisterDelphiFunction(@StrCat, 'StrCat', cdRegister);
  S.RegisterDelphiFunction(@StrLCat, 'StrLCat', cdRegister);
  S.RegisterDelphiFunction(@StrComp, 'StrComp', cdRegister);
  S.RegisterDelphiFunction(@StrIComp, 'StrIComp', cdRegister);
  S.RegisterDelphiFunction(@StrLComp, 'StrLComp', cdRegister);
  S.RegisterDelphiFunction(@StrLIComp, 'StrLIComp', cdRegister);
  S.RegisterDelphiFunction(@StrPos, 'StrPos', cdRegister);
  S.RegisterDelphiFunction(@StrUpper, 'StrUpper', cdRegister);
  S.RegisterDelphiFunction(@StrLower, 'StrLower', cdRegister);
  S.RegisterDelphiFunction(@Format_P, 'Format', cdRegister);
  S.RegisterDelphiFunction(@FloatToStr_P, 'FloatToStr', cdRegister);
  S.RegisterDelphiFunction(@CurrToStr, 'CurrToStr', cdRegister);
  S.RegisterDelphiFunction(@StrToFloat_P, 'StrToFloat', cdRegister);
  S.RegisterDelphiFunction(@StrToCurr, 'StrToCurr', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToTimeStamp, 'DateTimeToTimeStamp', cdRegister);
  S.RegisterDelphiFunction(@TimeStampToDateTime, 'TimeStampToDateTime', cdRegister);
  S.RegisterDelphiFunction(@TryEncodeDate, 'TryEncodeDate', cdRegister);
  S.RegisterDelphiFunction(@TryEncodeTime, 'TryEncodeTime', cdRegister);
  S.RegisterDelphiFunction(@EncodeDate, 'EncodeDate', cdRegister);
  S.RegisterDelphiFunction(@EncodeTime, 'EncodeTime', cdRegister);
  S.RegisterDelphiFunction(@DecodeDate, 'DecodeDate', cdRegister);
  S.RegisterDelphiFunction(@DecodeTime, 'DecodeTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToUnix, 'DateTimeToUnix', cdRegister);
  S.RegisterDelphiFunction(@UnixToDateTime, 'UnixToDateTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToSystemTime, 'DateTimeToSystemTime', cdRegister);
  S.RegisterDelphiFunction(@SystemTimeToDateTime, 'SystemTimeToDateTime', cdRegister);
  S.RegisterDelphiFunction(@DayOfWeek, 'DayOfWeek', cdRegister);
  S.RegisterDelphiFunction(@Date, 'Date', cdRegister);
  S.RegisterDelphiFunction(@Time, 'Time', cdRegister);
  S.RegisterDelphiFunction(@Now, 'Now', cdRegister);
  S.RegisterDelphiFunction(@IncMonth, 'IncMonth', cdRegister);
  S.RegisterDelphiFunction(@ReplaceTime, 'ReplaceTime', cdRegister);
  S.RegisterDelphiFunction(@ReplaceDate, 'ReplaceDate', cdRegister);
  S.RegisterDelphiFunction(@IsLeapYear, 'IsLeapYear', cdRegister);
  S.RegisterDelphiFunction(@DateToStr_P, 'DateToStr', cdRegister);
  S.RegisterDelphiFunction(@TimeToStr_P, 'TimeToStr', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToStr_P, 'DateTimeToStr', cdRegister);
  S.RegisterDelphiFunction(@StrToDate_P, 'StrToDate', cdRegister);
  S.RegisterDelphiFunction(@StrToTime_P, 'StrToTime', cdRegister);
  S.RegisterDelphiFunction(@StrToDateTime_P, 'StrToDateTime', cdRegister);
  S.RegisterDelphiFunction(@FormatDateTime_P, 'FormatDateTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToString_P, 'DateTimeToString', cdRegister);
  S.RegisterDelphiFunction(@Abort, 'Abort', cdRegister);
  S.RegisterDelphiFunction(@Beep, 'Beep', cdRegister);
  S.RegisterDelphiFunction(@ByteType, 'ByteType', cdRegister);
  S.RegisterDelphiFunction(@StrByteType, 'StrByteType', cdRegister);
  S.RegisterDelphiFunction(@ByteToCharLen, 'ByteToCharLen', cdRegister);
  S.RegisterDelphiFunction(@CharToByteLen, 'CharToByteLen', cdRegister);
  S.RegisterDelphiFunction(@ByteToCharIndex, 'ByteToCharIndex', cdRegister);
  S.RegisterDelphiFunction(@CharToByteIndex, 'CharToByteIndex', cdRegister);
  S.RegisterDelphiFunction(@IsPathDelimiter, 'IsPathDelimiter', cdRegister);
  S.RegisterDelphiFunction(@IsDelimiter, 'IsDelimiter', cdRegister);
  S.RegisterDelphiFunction(@IncludeTrailingBackslash, 'IncludeTrailingBackslash', cdRegister);
  S.RegisterDelphiFunction(@ExcludeTrailingBackslash, 'ExcludeTrailingBackslash', cdRegister);
  S.RegisterDelphiFunction(@LastDelimiter, 'LastDelimiter', cdRegister);
  S.RegisterDelphiFunction(@AnsiCompareFileName, 'AnsiCompareFileName', cdRegister);
  S.RegisterDelphiFunction(@AnsiLowerCaseFileName, 'AnsiLowerCaseFileName', cdRegister);
  S.RegisterDelphiFunction(@AnsiUpperCaseFileName, 'AnsiUpperCaseFileName', cdRegister);
  S.RegisterDelphiFunction(@AnsiPos, 'AnsiPos', cdRegister);
  S.RegisterDelphiFunction(@AnsiStrPos, 'AnsiStrPos', cdRegister);
  S.RegisterDelphiFunction(@StringReplace, 'StringReplace', cdRegister);
  S.RegisterDelphiFunction(@WrapText_P, 'WrapText', cdRegister);
  S.RegisterDelphiFunction(@FindCmdLineSwitch_P, 'FindCmdLineSwitch', cdRegister);
  S.RegisterDelphiFunction(@RaiseLastWin32Error, 'RaiseLastWin32Error', cdRegister);
  S.RegisterDelphiFunction(@Win32Check, 'Win32Check', cdRegister);
  S.RegisterDelphiFunction(@SafeLoadLibrary, 'SafeLoadLibrary', cdRegister);
  S.RegisterDelphiFunction(@CreateGUID, 'CreateGUID', cdRegister);
  S.RegisterDelphiFunction(@StringToGUID, 'StringToGUID', cdRegister);
  S.RegisterDelphiFunction(@GUIDToString, 'GUIDToString', cdRegister);
  S.RegisterDelphiFunction(@IsEqualGUID_P, 'IsEqualGUID', cdRegister);
end;

{ TPSImport_SysUtils }

procedure TPSImport_SysUtils.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_SysUtils(CompExec.Comp);
end;

procedure TPSImport_SysUtils.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_SysUtils_Routines(CompExec.Exec);
end;

end.

