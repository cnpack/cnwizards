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

unit CnScript_CnCommon;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 CnCommon 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnCommon, CnVclFmxMixed,
  uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_CnCommon = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_CnCommon(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnCommon_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_CnCommon(CL: TPSPascalCompiler);
begin
  CL.AddDelphiFunction('Procedure ExploreDir( APath : string; ShowDir: Boolean)');
  CL.AddDelphiFunction('Procedure ExploreFile( AFile : string; ShowDir: Boolean)');
  CL.AddDelphiFunction('Function ForceDirectories( Dir : string) : Boolean');
  CL.AddDelphiFunction('Function MoveFile( const sName, dName : string) : Boolean');
  CL.AddDelphiFunction('Function DeleteToRecycleBin( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Procedure FileProperties( const FName : string)');
  CL.AddDelphiFunction('Function OpenDialog( var FileName : string; Title : string; Filter : string; Ext : string) : Boolean');
  CL.AddDelphiFunction('Function GetDirectory( const Caption : string; var Dir : string; ShowNewButton : Boolean) : Boolean');
  CL.AddDelphiFunction('Function FormatPath( APath : string; Width : Integer) : string');
  CL.AddDelphiFunction('Procedure DrawCompactPath( Hdc : HDC; Rect : TRect; Str : string)');
  CL.AddDelphiFunction('Function SameCharCounts( s1, s2 : string) : Integer');
  CL.AddDelphiFunction('Function CharCounts( Str : PChar; C : Char) : Integer');
  CL.AddDelphiFunction('Function GetRelativePath( ATo, AFrom : string; const PathStr : string; const ParentStr : string; const CurrentStr : string; const UseCurrentDir : Boolean) : string');
  CL.AddDelphiFunction('Function LinkPath( const Head, Tail : string) : string');
  CL.AddDelphiFunction('Procedure RunFile( const FName : string; Handle : THandle; const Param : string)');
  CL.AddDelphiFunction('Procedure OpenUrl( const Url : string)');
  CL.AddDelphiFunction('Procedure MailTo( const Addr : string; const Subject : string)');
  CL.AddDelphiFunction('Function WinExecute( FileName : string; Visibility : Integer) : Boolean');
  CL.AddDelphiFunction('Function WinExecAndWait32( FileName : string; Visibility : Integer; ProcessMsg : Boolean) : Integer');
  CL.AddDelphiFunction('Function WinExecWithPipe( const CmdLine, Dir : string; slOutput : TStrings; var dwExitCode : Cardinal) : Boolean;');
  CL.AddDelphiFunction('Function AppPath : string');
  CL.AddDelphiFunction('Function ModulePath : string');
  CL.AddDelphiFunction('Function GetProgramFilesDir : string');
  CL.AddDelphiFunction('Function GetWindowsDir : string');
  CL.AddDelphiFunction('Function GetWindowsTempPath : string');
  CL.AddDelphiFunction('Function CnGetTempFileName( const Ext : string) : string');
  CL.AddDelphiFunction('Function GetSystemDir : string');
  CL.AddDelphiFunction('Function ShortNameToLongName( const FileName : string) : string');
  CL.AddDelphiFunction('Function LongNameToShortName( const FileName : string) : string');
  CL.AddDelphiFunction('Function GetTrueFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function FindExecFile( const AName : string; var AFullName : string) : Boolean');
  CL.AddDelphiFunction('Function GetSpecialFolderLocation( const Folder : Integer) : string');
  CL.AddDelphiFunction('Function AddDirSuffix( const Dir : string) : string');
  CL.AddDelphiFunction('Function MakePath( const Dir : string) : string');
  CL.AddDelphiFunction('Function MakeDir( const Path : string) : string');
  CL.AddDelphiFunction('Function GetUnixPath( const Path : string) : string');
  CL.AddDelphiFunction('Function GetWinPath( const Path : string) : string');
  CL.AddDelphiFunction('Function FileNameMatch( Pattern, FileName : PChar) : Integer');
  CL.AddDelphiFunction('Function MatchExt( const S, Ext : string) : Boolean');
  CL.AddDelphiFunction('Function MatchFileName( const S, FN : string) : Boolean');
  CL.AddDelphiFunction('Procedure FileExtsToStrings( const FileExts : string; ExtList : TStrings; CaseSensitive : Boolean)');
  CL.AddDelphiFunction('Procedure FileMasksToStrings( const FileMasks : string; MaskList : TStrings; CaseSensitive : Boolean)');
  CL.AddDelphiFunction('Function FileMatchesMasks( const FileName, FileMasks : string; CaseSensitive : Boolean) : Boolean;');
  CL.AddDelphiFunction('Function FileMatchesExts( const FileName, FileExts : string) : Boolean;');
  CL.AddDelphiFunction('Function IsFileInUse( const FName : string) : Boolean');
  CL.AddDelphiFunction('Function IsAscii( FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsValidFileName( const Name : string) : Boolean');
  CL.AddDelphiFunction('Function GetValidFileName( const Name : string) : string');
  CL.AddDelphiFunction('Function SetFileDate( const FileName : string; CreationTime, LastWriteTime, LastAccessTime : TFileTime) : Boolean');
  CL.AddDelphiFunction('Function GetFileDate( const FileName : string; var CreationTime, LastWriteTime, LastAccessTime : TFileTime) : Boolean');
  CL.AddDelphiFunction('Function FileTimeToDateTime( const FileTime : TFileTime) : TDateTime');
  CL.AddDelphiFunction('Function DateTimeToFileTime( const DateTime : TDateTime) : TFileTime');
  CL.AddDelphiFunction('Function GetFileIcon( const FileName : string; var Icon : TIcon) : Boolean');
  CL.AddDelphiFunction('Function CreateBakFile( const FileName, Ext : string) : Boolean');
  CL.AddDelphiFunction('Function FileTimeToLocalSystemTime( FTime : TFileTime) : TSystemTime');
  CL.AddDelphiFunction('Function LocalSystemTimeToFileTime( STime : TSystemTime) : TFileTime');
  CL.AddDelphiFunction('Function DateTimeToLocalDateTime( DateTime : TDateTime) : TDateTime');
  CL.AddDelphiFunction('Function LocalDateTimeToDateTime( DateTime : TDateTime) : TDateTime');
  CL.AddDelphiFunction('Function CompareTextPos( const ASubText, AText1, AText2 : string) : Integer');
  CL.AddDelphiFunction('Function Deltree( Dir : string; DelRoot : Boolean; DelEmptyDirOnly : Boolean) : Boolean');
  CL.AddDelphiFunction('Procedure DelEmptyTree( Dir : string; DelRoot : Boolean)');
  CL.AddDelphiFunction('Function GetDirFiles( Dir : string) : Integer');
  CL.AddTypeS('TFindCallBack', 'Procedure ( const FileName : string; const Info'
    + ' : TSearchRec; var Abort : Boolean)');
  CL.AddTypeS('TDirCallBack', 'Procedure ( const SubDir : string)');
  CL.AddDelphiFunction('Function FindFile( const Path : string; const FileName : string; Proc : TFindCallBack; DirProc : TDirCallBack; bSub : Boolean; bMsg : Boolean) : Boolean');
  CL.AddDelphiFunction('Function OpenWith( const FileName : string) : Integer');
  CL.AddDelphiFunction('Function CheckAppRunning( const FileName : string; var Running : Boolean) : Boolean');
  CL.AddTypeS('TVersionNumber', 'record Minor : Word; Major : Word; Build : Wor'
    + 'd; Release : Word; end');
  CL.AddDelphiFunction('Function GetFileVersionNumber( const FileName : string) : TVersionNumber');
  CL.AddDelphiFunction('Function GetFileVersionStr( const FileName : string) : string');
  CL.AddDelphiFunction('Function GetFileInfo( const FileName : string; var FileSize : Int64; var FileTime : TDateTime) : Boolean');
  CL.AddDelphiFunction('Function GetFileSize( const FileName : string) : Int64');
  CL.AddDelphiFunction('Function GetFileDateTime( const FileName : string) : TDateTime');
  CL.AddDelphiFunction('Function LoadStringFromFile( const FileName : string) : string');
  CL.AddDelphiFunction('Function SaveStringToFile( const S, FileName : string) : Boolean');
  CL.AddDelphiFunction('Function DelEnvironmentVar( const Name : string) : Boolean');
  CL.AddDelphiFunction('Function ExpandEnvironmentVar( var Value : string) : Boolean');
  CL.AddDelphiFunction('Function GetEnvironmentVar( const Name : string; var Value : string; Expand : Boolean) : Boolean');
  CL.AddDelphiFunction('Function GetEnvironmentVars( const Vars : TStrings; Expand : Boolean) : Boolean');
  CL.AddDelphiFunction('Function SetEnvironmentVar( const Name, Value : string) : Boolean');
  CL.AddDelphiFunction('Function InStr( const sShort : string; const sLong : string) : Boolean');
  CL.AddDelphiFunction('Function IntToStrEx( Value : Integer; Len : Integer; FillChar : Char) : string');
  CL.AddDelphiFunction('Function IntToStrSp( Value : Integer; SpLen : Integer; Sp : Char) : string');
  CL.AddDelphiFunction('Function IsFloat( const s : String) : Boolean');
  CL.AddDelphiFunction('Function IsInt( const s : String) : Boolean');
  CL.AddDelphiFunction('Function IsDateTime( const s : string) : Boolean');
  CL.AddDelphiFunction('Function IsValidEmail( const s : string) : Boolean');
  CL.AddDelphiFunction('Function StrSpToInt( Value : String; Sp : Char) : Int64');
  CL.AddDelphiFunction('Function ByteToBin( Value : Byte) : string');
  CL.AddDelphiFunction('Function StrRight( Str : string; Len : Integer) : string');
  CL.AddDelphiFunction('Function StrLeft( Str : string; Len : Integer) : string');
  CL.AddDelphiFunction('Function GetLine( C : Char; Len : Integer) : string');
  CL.AddDelphiFunction('Function GetTextFileLineCount( FileName : String) : Integer');
  CL.AddDelphiFunction('Function Spc( Len : Integer) : string');
  CL.AddDelphiFunction('Procedure SwapStr( var s1, s2 : string)');
  CL.AddDelphiFunction('Procedure SeparateStrAndNum( const AInStr : string; var AOutStr : string; var AOutNum : Integer)');
  CL.AddDelphiFunction('Function UnQuotedStr( const str : string; const ch : Char; const sep : string) : string');
  CL.AddDelphiFunction('Function CharPosWithCounter( const Sub : Char; const AStr : String; Counter : Integer) : Integer');
  CL.AddDelphiFunction('Function CountCharInStr( const Sub : Char; const AStr : string) : Integer');
  CL.AddDelphiFunction('Function IsValidIdentChar( C : Char; First : Boolean) : Boolean');
  CL.AddDelphiFunction('Function BoolToStr( B : Boolean; UseBoolStrs : Boolean) : string');
  CL.AddDelphiFunction('Function LinesToStr( const Lines : string) : string');
  CL.AddDelphiFunction('Function StrToLines( const Str : string) : string');
  CL.AddDelphiFunction('Function MyDateToStr( Date : TDate) : string');
  CL.AddDelphiFunction('Function RegReadStringDef( const RootKey : HKEY; const Key, Name, Def : string) : string');
  CL.AddDelphiFunction('Procedure ReadStringsFromIni( Ini : TCustomIniFile; const Section : string; Strings : TStrings)');
  CL.AddDelphiFunction('Procedure WriteStringsToIni( Ini : TCustomIniFile; const Section : string; Strings : TStrings)');
  CL.AddDelphiFunction('Function VersionToStr( Version : DWORD) : string');
  CL.AddDelphiFunction('Function StrToVersion( s : string) : DWORD');
  CL.AddDelphiFunction('Function CnDateToStr( Date : TDateTime) : string');
  CL.AddDelphiFunction('Function CnStrToDate( const S : string) : TDateTime');
  CL.AddDelphiFunction('Function DateTimeToFlatStr( const DateTime : TDateTime) : string');
  CL.AddDelphiFunction('Function FlatStrToDateTime( const Section : string; var DateTime : TDateTime) : Boolean');
  CL.AddDelphiFunction('Function StrToRegRoot( const s : string) : HKEY');
  CL.AddDelphiFunction('Function RegRootToStr( Key : HKEY; ShortFormat : Boolean) : string');
  CL.AddDelphiFunction('Function ExtractSubstr( const S : string; var Pos : Integer; const Delims : TSysCharSet) : string');
  CL.AddDelphiFunction('Function WildcardCompare( const FileWildcard, FileName : string; const IgnoreCase : Boolean) : Boolean');
  CL.AddDelphiFunction('Function ScanCodeToAscii( Code : Word) : Char');
  CL.AddDelphiFunction('Function IsDeadKey( Key : Word) : Boolean');
  CL.AddDelphiFunction('Function VirtualKeyToAscii( Key : Word) : Char');
  CL.AddDelphiFunction('Function VK_ScanCodeToAscii( VKey : Word; Code : Word) : Char');
  CL.AddDelphiFunction('Function GetShiftState : TShiftState');
  CL.AddDelphiFunction('Function IsShiftDown : Boolean');
  CL.AddDelphiFunction('Function IsAltDown : Boolean');
  CL.AddDelphiFunction('Function IsCtrlDown : Boolean');
  CL.AddDelphiFunction('Function IsInsertDown : Boolean');
  CL.AddDelphiFunction('Function IsCapsLockDown : Boolean');
  CL.AddDelphiFunction('Function IsNumLockDown : Boolean');
  CL.AddDelphiFunction('Function IsScrollLockDown : Boolean');
  CL.AddDelphiFunction('Function HandleEditShortCut( AControl : TWinControl; AShortCut : TShortCut) : Boolean');
  CL.AddDelphiFunction('Function RemoveClassPrefix( const ClassName : string) : string');
  CL.AddDelphiFunction('Procedure InfoDlg( Mess : string)');
  CL.AddDelphiFunction('Function InfoOk( Mess : string) : Boolean');
  CL.AddDelphiFunction('Procedure ErrorDlg( Mess : string)');
  CL.AddDelphiFunction('Procedure WarningDlg( Mess : string)');
  CL.AddDelphiFunction('Function QueryDlg( Mess : string; DefaultNo : Boolean) : Boolean');
  CL.AddDelphiFunction('procedure LongMessageDlg( const Mess : string; AutoWrap : Boolean; const Caption : string)');
  CL.AddDelphiFunction('Function CnInputQuery( const ACaption, APrompt : string; var Value : string; Ini : TCustomIniFile; const Section : string) : Boolean');
  CL.AddDelphiFunction('Function CnInputBox( const ACaption, APrompt, ADefault : string; Ini : TCustomIniFile; const Section : string) : string');
  CL.AddDelphiFunction('Function GetYear( Date : TDate) : Integer');
  CL.AddDelphiFunction('Function GetMonth( Date : TDate) : Integer');
  CL.AddDelphiFunction('Function GetDay( Date : TDate) : Integer');
  CL.AddDelphiFunction('Function GetHour( Time : TTime) : Integer');
  CL.AddDelphiFunction('Function GetMinute( Time : TTime) : Integer');
  CL.AddDelphiFunction('Function GetSecond( Time : TTime) : Integer');
  CL.AddDelphiFunction('Function GetMSecond( Time : TTime) : Integer');
  CL.AddDelphiFunction('Procedure MoveMouseIntoControl( AWinControl : TControl)');
  CL.AddDelphiFunction('Procedure AddComboBoxTextToItems( ComboBox : TComboBox; MaxItemsCount : Integer)');
  CL.AddDelphiFunction('Function DynamicResolution( x, y : WORD) : Boolean');
  CL.AddDelphiFunction('Procedure StayOnTop( Handle : HWND; OnTop : Boolean)');
  CL.AddDelphiFunction('Procedure SetHidden( Hide : Boolean)');
  CL.AddDelphiFunction('Procedure SetTaskBarVisible( Visible : Boolean)');
  CL.AddDelphiFunction('Procedure SetDesktopVisible( Visible : Boolean)');
  CL.AddDelphiFunction('Function ForceForegroundWindow( HWND : HWND) : Boolean');
  CL.AddDelphiFunction('Function GetWorkRect( const Form : TCustomForm) : TRect');
  CL.AddDelphiFunction('Procedure BeginWait');
  CL.AddDelphiFunction('Procedure EndWait');
  CL.AddDelphiFunction('Function CheckWindows9598 : Boolean');
  CL.AddDelphiFunction('Function CheckWindowsNT : Boolean');
  CL.AddDelphiFunction('Function CheckWinXP : Boolean');
  CL.AddDelphiFunction('Function CheckWinVista : Boolean');
  CL.AddDelphiFunction('Function CheckWin8 : Boolean');
  CL.AddDelphiFunction('Function CheckWin10 : Boolean');
  CL.AddDelphiFunction('Function CheckWin64: Boolean');
  CL.AddDelphiFunction('Function CheckWow64: Boolean');
  CL.AddDelphiFunction('Function CheckProcess64( ProcessHandle: THandle): Boolean');
  CL.AddDelphiFunction('Function CheckProcessWow64( ProcessHandle: THandle): Boolean');
  CL.AddDelphiFunction('Function GetOSString : string');
  CL.AddDelphiFunction('Function GetComputeNameStr : string');
  CL.AddDelphiFunction('Function GetLocalUserName : string');
  CL.AddDelphiFunction('Function GetRegisteredCompany : string');
  CL.AddDelphiFunction('Function GetRegisteredOwner : string');
  CL.AddDelphiFunction('Function GetControlScreenRect( AControl : TControl) : TRect');
  CL.AddDelphiFunction('Procedure SetControlScreenRect( AControl : TControl; ARect : TRect)');
  CL.AddDelphiFunction('Function GetMultiMonitorDesktopRect : TRect');
  CL.AddDelphiFunction('Procedure ListboxHorizontalScrollbar( Listbox : TCustomListBox)');
  CL.AddDelphiFunction('Function TrimInt( Value, Min, Max : Integer) : Integer');
  CL.AddDelphiFunction('Function CompareInt( V1, V2 : Integer; Desc : Boolean) : Integer');
  CL.AddDelphiFunction('Function IntToByte( Value : Integer) : Byte');
  CL.AddDelphiFunction('Function InBound( Value : Integer; V1, V2 : Integer) : Boolean');
  CL.AddDelphiFunction('Function SameMethod( Method1, Method2 : TMethod) : Boolean');
  CL.AddDelphiFunction('Function RectEqu( Rect1, Rect2 : TRect) : Boolean');
  CL.AddDelphiFunction('Procedure DeRect( Rect : TRect; var x, y, Width, Height : Integer)');
  CL.AddDelphiFunction('Function EnSize( cx, cy : Integer) : TSize');
  CL.AddDelphiFunction('Function RectWidth( Rect : TRect) : Integer');
  CL.AddDelphiFunction('Function RectHeight( Rect : TRect) : Integer');
  CL.AddDelphiFunction('Procedure Delay( const uDelay : DWORD)');
  CL.AddDelphiFunction('Function GetLastErrorMsg( IncludeErrorCode : Boolean) : string');
  CL.AddDelphiFunction('Procedure ShowLastError');
{$IFDEF UNICODE}
  CL.AddDelphiFunction('Function GetHzPyW( const AHzStr : string) : string');
{$ELSE}
  CL.AddDelphiFunction('Function GetHzPy( const AHzStr : string) : string');
{$ENDIF}
  CL.AddDelphiFunction('Function GetSelText( edt : TCustomEdit) : string');
  CL.AddDelphiFunction('Function SoundCardExist : Boolean');
  CL.AddDelphiFunction('Function InheritsFromClassName( AObject : TObject; const AClass : string) : Boolean;');
  CL.AddDelphiFunction('Procedure KillProcessByFileName( const FileName : String)');
  CL.AddDelphiFunction('Procedure KillProcessByFullFileName( const FullFileName : String)');
  CL.AddDelphiFunction('Function IndexStr( AText : string; AValues : array of string; IgCase : Boolean) : Integer');
  CL.AddDelphiFunction('Function IndexInt( ANum : Integer; AValues : array of Integer) : Integer');
  CL.AddDelphiFunction('Procedure TrimStrings( AList : TStrings)');
  CL.AddDelphiFunction('Function GetPropValueIncludeSub( Instance : TObject; PropName : string; PreferStrings : Boolean) : Variant');
  CL.AddDelphiFunction('Function SetPropValueIncludeSub( Instance : TObject; const PropName : string; const Value : Variant) : Boolean');
  CL.AddDelphiFunction('Function IsParentFont( AControl : TControl) : Boolean');
  CL.AddDelphiFunction('Function GetParentFont( AControl : TComponent) : TFont');
end;

(* === run-time registration functions === *)

function InheritsFromClassName_P(AObject: TObject; const AClass: string): Boolean;
begin
  Result := CnCommon.InheritsFromClassName(AObject, AClass);
end;

function QueryDlg_P(Mess: string; DefaultNo: Boolean): Boolean;
begin
  Result := CnCommon.QueryDlg(Mess, DefaultNo);
end;

procedure WarningDlg_P(Mess: string);
begin
  CnCommon.WarningDlg(Mess);
end;

procedure ErrorDlg_P(Mess: string);
begin
  CnCommon.ErrorDlg(Mess);
end;

function InfoOk_P(Mess: string): Boolean;
begin
  Result := CnCommon.InfoOk(Mess);
end;

procedure InfoDlg_P(Mess: string);
begin
  CnCommon.InfoDlg(Mess);
end;

function FileMatchesExts_P(const FileName, FileExts: string): Boolean;
begin
  Result := CnCommon.FileMatchesExts(FileName, FileExts);
end;

function FileMatchesMasks_P(const FileName, FileMasks: string; CaseSensitive: Boolean): Boolean;
begin
  Result := CnCommon.FileMatchesMasks(FileName, FileMasks, CaseSensitive);
end;

function WinExecWithPipe_P(const CmdLine, Dir: string; slOutput: TStrings; var dwExitCode: Cardinal): Boolean;
begin
  Result := CnCommon.WinExecWithPipe(CmdLine, Dir, slOutput, dwExitCode);
end;

procedure RIRegister_CnCommon_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@ExploreDir, 'ExploreDir', cdRegister);
  S.RegisterDelphiFunction(@ExploreFile, 'ExploreFile', cdRegister);
  S.RegisterDelphiFunction(@ForceDirectories, 'ForceDirectories', cdRegister);
  S.RegisterDelphiFunction(@MoveFile, 'MoveFile', cdRegister);
  S.RegisterDelphiFunction(@DeleteToRecycleBin, 'DeleteToRecycleBin', cdRegister);
  S.RegisterDelphiFunction(@FileProperties, 'FileProperties', cdRegister);
  S.RegisterDelphiFunction(@OpenDialog, 'OpenDialog', cdRegister);
  S.RegisterDelphiFunction(@GetDirectory, 'GetDirectory', cdRegister);
  S.RegisterDelphiFunction(@FormatPath, 'FormatPath', cdRegister);
  S.RegisterDelphiFunction(@DrawCompactPath, 'DrawCompactPath', cdRegister);
  S.RegisterDelphiFunction(@SameCharCounts, 'SameCharCounts', cdRegister);
  S.RegisterDelphiFunction(@CharCounts, 'CharCounts', cdRegister);
  S.RegisterDelphiFunction(@GetRelativePath, 'GetRelativePath', cdRegister);
  S.RegisterDelphiFunction(@LinkPath, 'LinkPath', cdRegister);
  S.RegisterDelphiFunction(@RunFile, 'RunFile', cdRegister);
  S.RegisterDelphiFunction(@OpenUrl, 'OpenUrl', cdRegister);
  S.RegisterDelphiFunction(@MailTo, 'MailTo', cdRegister);
  S.RegisterDelphiFunction(@WinExecute, 'WinExecute', cdRegister);
  S.RegisterDelphiFunction(@WinExecAndWait32, 'WinExecAndWait32', cdRegister);
  S.RegisterDelphiFunction(@WinExecWithPipe_P, 'WinExecWithPipe', cdRegister);
  S.RegisterDelphiFunction(@AppPath, 'AppPath', cdRegister);
  S.RegisterDelphiFunction(@ModulePath, 'ModulePath', cdRegister);
  S.RegisterDelphiFunction(@GetProgramFilesDir, 'GetProgramFilesDir', cdRegister);
  S.RegisterDelphiFunction(@GetWindowsDir, 'GetWindowsDir', cdRegister);
  S.RegisterDelphiFunction(@GetWindowsTempPath, 'GetWindowsTempPath', cdRegister);
  S.RegisterDelphiFunction(@CnGetTempFileName, 'CnGetTempFileName', cdRegister);
  S.RegisterDelphiFunction(@GetSystemDir, 'GetSystemDir', cdRegister);
  S.RegisterDelphiFunction(@ShortNameToLongName, 'ShortNameToLongName', cdRegister);
  S.RegisterDelphiFunction(@LongNameToShortName, 'LongNameToShortName', cdRegister);
  S.RegisterDelphiFunction(@GetTrueFileName, 'GetTrueFileName', cdRegister);
  S.RegisterDelphiFunction(@FindExecFile, 'FindExecFile', cdRegister);
  S.RegisterDelphiFunction(@GetSpecialFolderLocation, 'GetSpecialFolderLocation', cdRegister);
  S.RegisterDelphiFunction(@AddDirSuffix, 'AddDirSuffix', cdRegister);
  S.RegisterDelphiFunction(@MakePath, 'MakePath', cdRegister);
  S.RegisterDelphiFunction(@MakeDir, 'MakeDir', cdRegister);
  S.RegisterDelphiFunction(@GetUnixPath, 'GetUnixPath', cdRegister);
  S.RegisterDelphiFunction(@GetWinPath, 'GetWinPath', cdRegister);
  S.RegisterDelphiFunction(@FileNameMatch, 'FileNameMatch', cdRegister);
  S.RegisterDelphiFunction(@MatchExt, 'MatchExt', cdRegister);
  S.RegisterDelphiFunction(@MatchFileName, 'MatchFileName', cdRegister);
  S.RegisterDelphiFunction(@FileExtsToStrings, 'FileExtsToStrings', cdRegister);
  S.RegisterDelphiFunction(@FileMasksToStrings, 'FileMasksToStrings', cdRegister);
  S.RegisterDelphiFunction(@FileMatchesMasks_P, 'FileMatchesMasks', cdRegister);
  S.RegisterDelphiFunction(@FileMatchesExts_P, 'FileMatchesExts', cdRegister);
  S.RegisterDelphiFunction(@IsFileInUse, 'IsFileInUse', cdRegister);
  S.RegisterDelphiFunction(@IsAscii, 'IsAscii', cdRegister);
  S.RegisterDelphiFunction(@IsValidFileName, 'IsValidFileName', cdRegister);
  S.RegisterDelphiFunction(@GetValidFileName, 'GetValidFileName', cdRegister);
  S.RegisterDelphiFunction(@SetFileDate, 'SetFileDate', cdRegister);
  S.RegisterDelphiFunction(@GetFileDate, 'GetFileDate', cdRegister);
  S.RegisterDelphiFunction(@FileTimeToDateTime, 'FileTimeToDateTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToFileTime, 'DateTimeToFileTime', cdRegister);
  S.RegisterDelphiFunction(@GetFileIcon, 'GetFileIcon', cdRegister);
  S.RegisterDelphiFunction(@CreateBakFile, 'CreateBakFile', cdRegister);
  S.RegisterDelphiFunction(@FileTimeToLocalSystemTime, 'FileTimeToLocalSystemTime', cdRegister);
  S.RegisterDelphiFunction(@LocalSystemTimeToFileTime, 'LocalSystemTimeToFileTime', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToLocalDateTime, 'DateTimeToLocalDateTime', cdRegister);
  S.RegisterDelphiFunction(@LocalDateTimeToDateTime, 'LocalDateTimeToDateTime', cdRegister);
  S.RegisterDelphiFunction(@CompareTextPos, 'CompareTextPos', cdRegister);
  S.RegisterDelphiFunction(@Deltree, 'Deltree', cdRegister);
  S.RegisterDelphiFunction(@DelEmptyTree, 'DelEmptyTree', cdRegister);
  S.RegisterDelphiFunction(@GetDirFiles, 'GetDirFiles', cdRegister);
  S.RegisterDelphiFunction(@FindFile, 'FindFile', cdRegister);
  S.RegisterDelphiFunction(@OpenWith, 'OpenWith', cdRegister);
  S.RegisterDelphiFunction(@CheckAppRunning, 'CheckAppRunning', cdRegister);
  S.RegisterDelphiFunction(@GetFileVersionNumber, 'GetFileVersionNumber', cdRegister);
  S.RegisterDelphiFunction(@GetFileVersionStr, 'GetFileVersionStr', cdRegister);
  S.RegisterDelphiFunction(@GetFileInfo, 'GetFileInfo', cdRegister);
  S.RegisterDelphiFunction(@GetFileSize, 'GetFileSize', cdRegister);
  S.RegisterDelphiFunction(@GetFileDateTime, 'GetFileDateTime', cdRegister);
  S.RegisterDelphiFunction(@LoadStringFromFile, 'LoadStringFromFile', cdRegister);
  S.RegisterDelphiFunction(@SaveStringToFile, 'SaveStringToFile', cdRegister);
  S.RegisterDelphiFunction(@DelEnvironmentVar, 'DelEnvironmentVar', cdRegister);
  S.RegisterDelphiFunction(@ExpandEnvironmentVar, 'ExpandEnvironmentVar', cdRegister);
  S.RegisterDelphiFunction(@GetEnvironmentVar, 'GetEnvironmentVar', cdRegister);
  S.RegisterDelphiFunction(@GetEnvironmentVars, 'GetEnvironmentVars', cdRegister);
  S.RegisterDelphiFunction(@SetEnvironmentVar, 'SetEnvironmentVar', cdRegister);
  S.RegisterDelphiFunction(@InStr, 'InStr', cdRegister);
  S.RegisterDelphiFunction(@IntToStrEx, 'IntToStrEx', cdRegister);
  S.RegisterDelphiFunction(@IntToStrSp, 'IntToStrSp', cdRegister);
  S.RegisterDelphiFunction(@IsFloat, 'IsFloat', cdRegister);
  S.RegisterDelphiFunction(@IsInt, 'IsInt', cdRegister);
  S.RegisterDelphiFunction(@IsDateTime, 'IsDateTime', cdRegister);
  S.RegisterDelphiFunction(@IsValidEmail, 'IsValidEmail', cdRegister);
  S.RegisterDelphiFunction(@StrSpToInt, 'StrSpToInt', cdRegister);
  S.RegisterDelphiFunction(@ByteToBin, 'ByteToBin', cdRegister);
  S.RegisterDelphiFunction(@StrRight, 'StrRight', cdRegister);
  S.RegisterDelphiFunction(@StrLeft, 'StrLeft', cdRegister);
  S.RegisterDelphiFunction(@GetLine, 'GetLine', cdRegister);
  S.RegisterDelphiFunction(@GetTextFileLineCount, 'GetTextFileLineCount', cdRegister);
  S.RegisterDelphiFunction(@Spc, 'Spc', cdRegister);
  S.RegisterDelphiFunction(@SwapStr, 'SwapStr', cdRegister);
  S.RegisterDelphiFunction(@SeparateStrAndNum, 'SeparateStrAndNum', cdRegister);
  S.RegisterDelphiFunction(@UnQuotedStr, 'UnQuotedStr', cdRegister);
  S.RegisterDelphiFunction(@CharPosWithCounter, 'CharPosWithCounter', cdRegister);
  S.RegisterDelphiFunction(@CountCharInStr, 'CountCharInStr', cdRegister);
  S.RegisterDelphiFunction(@IsValidIdentChar, 'IsValidIdentChar', cdRegister);
  S.RegisterDelphiFunction(@BoolToStr, 'BoolToStr', cdRegister);
  S.RegisterDelphiFunction(@LinesToStr, 'LinesToStr', cdRegister);
  S.RegisterDelphiFunction(@StrToLines, 'StrToLines', cdRegister);
  S.RegisterDelphiFunction(@MyDateToStr, 'MyDateToStr', cdRegister);
  S.RegisterDelphiFunction(@RegReadStringDef, 'RegReadStringDef', cdRegister);
  S.RegisterDelphiFunction(@ReadStringsFromIni, 'ReadStringsFromIni', cdRegister);
  S.RegisterDelphiFunction(@WriteStringsToIni, 'WriteStringsToIni', cdRegister);
  S.RegisterDelphiFunction(@VersionToStr, 'VersionToStr', cdRegister);
  S.RegisterDelphiFunction(@StrToVersion, 'StrToVersion', cdRegister);
  S.RegisterDelphiFunction(@CnDateToStr, 'CnDateToStr', cdRegister);
  S.RegisterDelphiFunction(@CnStrToDate, 'CnStrToDate', cdRegister);
  S.RegisterDelphiFunction(@DateTimeToFlatStr, 'DateTimeToFlatStr', cdRegister);
  S.RegisterDelphiFunction(@FlatStrToDateTime, 'FlatStrToDateTime', cdRegister);
  S.RegisterDelphiFunction(@StrToRegRoot, 'StrToRegRoot', cdRegister);
  S.RegisterDelphiFunction(@RegRootToStr, 'RegRootToStr', cdRegister);
  S.RegisterDelphiFunction(@ExtractSubstr, 'ExtractSubstr', cdRegister);
  S.RegisterDelphiFunction(@WildcardCompare, 'WildcardCompare', cdRegister);
  S.RegisterDelphiFunction(@ScanCodeToAscii, 'ScanCodeToAscii', cdRegister);
  S.RegisterDelphiFunction(@IsDeadKey, 'IsDeadKey', cdRegister);
  S.RegisterDelphiFunction(@VirtualKeyToAscii, 'VirtualKeyToAscii', cdRegister);
  S.RegisterDelphiFunction(@VK_ScanCodeToAscii, 'VK_ScanCodeToAscii', cdRegister);
  S.RegisterDelphiFunction(@GetShiftState, 'GetShiftState', cdRegister);
  S.RegisterDelphiFunction(@IsShiftDown, 'IsShiftDown', cdRegister);
  S.RegisterDelphiFunction(@IsAltDown, 'IsAltDown', cdRegister);
  S.RegisterDelphiFunction(@IsCtrlDown, 'IsCtrlDown', cdRegister);
  S.RegisterDelphiFunction(@IsInsertDown, 'IsInsertDown', cdRegister);
  S.RegisterDelphiFunction(@IsCapsLockDown, 'IsCapsLockDown', cdRegister);
  S.RegisterDelphiFunction(@IsNumLockDown, 'IsNumLockDown', cdRegister);
  S.RegisterDelphiFunction(@IsScrollLockDown, 'IsScrollLockDown', cdRegister);
  S.RegisterDelphiFunction(@HandleEditShortCut, 'HandleEditShortCut', cdRegister);
  S.RegisterDelphiFunction(@RemoveClassPrefix, 'RemoveClassPrefix', cdRegister);
  S.RegisterDelphiFunction(@InfoDlg_P, 'InfoDlg', cdRegister);
  S.RegisterDelphiFunction(@InfoOk_P, 'InfoOk', cdRegister);
  S.RegisterDelphiFunction(@ErrorDlg_P, 'ErrorDlg', cdRegister);
  S.RegisterDelphiFunction(@WarningDlg_P, 'WarningDlg', cdRegister);
  S.RegisterDelphiFunction(@QueryDlg_P, 'QueryDlg', cdRegister);
  S.RegisterDelphiFunction(@LongMessageDlg, 'LongMessageDlg', cdRegister);
  S.RegisterDelphiFunction(@CnInputQuery, 'CnInputQuery', cdRegister);
  S.RegisterDelphiFunction(@CnInputBox, 'CnInputBox', cdRegister);
  S.RegisterDelphiFunction(@GetYear, 'GetYear', cdRegister);
  S.RegisterDelphiFunction(@GetMonth, 'GetMonth', cdRegister);
  S.RegisterDelphiFunction(@GetDay, 'GetDay', cdRegister);
  S.RegisterDelphiFunction(@GetHour, 'GetHour', cdRegister);
  S.RegisterDelphiFunction(@GetMinute, 'GetMinute', cdRegister);
  S.RegisterDelphiFunction(@GetSecond, 'GetSecond', cdRegister);
  S.RegisterDelphiFunction(@GetMSecond, 'GetMSecond', cdRegister);
  S.RegisterDelphiFunction(@MoveMouseIntoControl, 'MoveMouseIntoControl', cdRegister);
  S.RegisterDelphiFunction(@AddComboBoxTextToItems, 'AddComboBoxTextToItems', cdRegister);
  S.RegisterDelphiFunction(@DynamicResolution, 'DynamicResolution', cdRegister);
  S.RegisterDelphiFunction(@StayOnTop, 'StayOnTop', cdRegister);
  S.RegisterDelphiFunction(@SetHidden, 'SetHidden', cdRegister);
  S.RegisterDelphiFunction(@SetTaskBarVisible, 'SetTaskBarVisible', cdRegister);
  S.RegisterDelphiFunction(@SetDesktopVisible, 'SetDesktopVisible', cdRegister);
  S.RegisterDelphiFunction(@ForceForegroundWindow, 'ForceForegroundWindow', cdRegister);
  S.RegisterDelphiFunction(@GetWorkRect, 'GetWorkRect', cdRegister);
  S.RegisterDelphiFunction(@BeginWait, 'BeginWait', cdRegister);
  S.RegisterDelphiFunction(@EndWait, 'EndWait', cdRegister);
  S.RegisterDelphiFunction(@CheckWindows9598, 'CheckWindows9598', cdRegister);
  S.RegisterDelphiFunction(@CheckWindowsNT, 'CheckWindowsNT', cdRegister);
  S.RegisterDelphiFunction(@CheckWinXP, 'CheckWinXP', cdRegister);
  S.RegisterDelphiFunction(@CheckWinVista, 'CheckWinVista', cdRegister);
  S.RegisterDelphiFunction(@CheckWin8, 'CheckWin8', cdRegister);
  S.RegisterDelphiFunction(@CheckWin10, 'CheckWin10', cdRegister);
  S.RegisterDelphiFunction(@CheckWin64, 'CheckWin64', cdRegister);
  S.RegisterDelphiFunction(@CheckWow64, 'CheckWow64', cdRegister);
  S.RegisterDelphiFunction(@CheckProcess64, 'CheckProcess64', cdRegister);
  S.RegisterDelphiFunction(@CheckProcessWow64, 'CheckProcessWow64', cdRegister);
  S.RegisterDelphiFunction(@GetOSString, 'GetOSString', cdRegister);
  S.RegisterDelphiFunction(@GetComputeNameStr, 'GetComputeNameStr', cdRegister);
  S.RegisterDelphiFunction(@GetLocalUserName, 'GetLocalUserName', cdRegister);
  S.RegisterDelphiFunction(@GetRegisteredCompany, 'GetRegisteredCompany', cdRegister);
  S.RegisterDelphiFunction(@GetRegisteredOwner, 'GetRegisteredOwner', cdRegister);
  S.RegisterDelphiFunction(@GetControlScreenRect, 'GetControlScreenRect', cdRegister);
  S.RegisterDelphiFunction(@SetControlScreenRect, 'SetControlScreenRect', cdRegister);
  S.RegisterDelphiFunction(@GetMultiMonitorDesktopRect, 'GetMultiMonitorDesktopRect', cdRegister);
  S.RegisterDelphiFunction(@ListboxHorizontalScrollbar, 'ListboxHorizontalScrollbar', cdRegister);
  S.RegisterDelphiFunction(@TrimInt, 'TrimInt', cdRegister);
  S.RegisterDelphiFunction(@CompareInt, 'CompareInt', cdRegister);
  S.RegisterDelphiFunction(@IntToByte, 'IntToByte', cdRegister);
  S.RegisterDelphiFunction(@InBound, 'InBound', cdRegister);
  S.RegisterDelphiFunction(@SameMethod, 'SameMethod', cdRegister);
  S.RegisterDelphiFunction(@RectEqu, 'RectEqu', cdRegister);
  S.RegisterDelphiFunction(@DeRect, 'DeRect', cdRegister);
  S.RegisterDelphiFunction(@EnSize, 'EnSize', cdRegister);
  S.RegisterDelphiFunction(@RectWidth, 'RectWidth', cdRegister);
  S.RegisterDelphiFunction(@RectHeight, 'RectHeight', cdRegister);
  S.RegisterDelphiFunction(@Delay, 'Delay', cdRegister);
  S.RegisterDelphiFunction(@GetLastErrorMsg, 'GetLastErrorMsg', cdRegister);
  S.RegisterDelphiFunction(@ShowLastError, 'ShowLastError', cdRegister);
{$IFDEF UNICODE}
  S.RegisterDelphiFunction(@GetHzPyW, 'GetHzPyW', cdRegister);
{$ELSE}
  S.RegisterDelphiFunction(@GetHzPy, 'GetHzPy', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@GetSelText, 'GetSelText', cdRegister);
  S.RegisterDelphiFunction(@SoundCardExist, 'SoundCardExist', cdRegister);
  S.RegisterDelphiFunction(@InheritsFromClassName_P, 'InheritsFromClassName', cdRegister);
  S.RegisterDelphiFunction(@KillProcessByFileName, 'KillProcessByFileName', cdRegister);
  S.RegisterDelphiFunction(@KillProcessByFullFileName, 'KillProcessByFullFileName', cdRegister);
  S.RegisterDelphiFunction(@IndexStr, 'IndexStr', cdRegister);
  S.RegisterDelphiFunction(@IndexInt, 'IndexInt', cdRegister);
  S.RegisterDelphiFunction(@TrimStrings, 'TrimStrings', cdRegister);
  S.RegisterDelphiFunction(@GetPropValueIncludeSub, 'GetPropValueIncludeSub', cdRegister);
  S.RegisterDelphiFunction(@SetPropValueIncludeSub, 'SetPropValueIncludeSub', cdRegister);
  S.RegisterDelphiFunction(@IsParentFont, 'IsParentFont', cdRegister);
  S.RegisterDelphiFunction(@GetParentFont, 'GetParentFont', cdRegister);
end;

{ TPSImport_CnCommon }

procedure TPSImport_CnCommon.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnCommon(CompExec.Comp);
end;

procedure TPSImport_CnCommon.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnCommon_Routines(CompExec.Exec); // comment it if no routines
end;

end.

