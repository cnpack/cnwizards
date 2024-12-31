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

unit CnScript_Windows;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Windows 注册类
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
  Windows, Classes, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_Windows = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_Windows(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Windows_Routines(S: TPSExec);

implementation

procedure SIRegister_Windows(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('WCHAR', 'WideChar');
  CL.AddTypeS('DWORD', 'LongWord');
  CL.AddTypeS('BOOL', 'LongBool');
  CL.AddTypeS('UCHAR', 'Byte');
  CL.AddTypeS('SHORT', 'Smallint');
  CL.AddTypeS('UINT', 'LongWord');
  CL.AddTypeS('ULONG', 'Cardinal');
  CL.AddTypeS('LCID', 'DWORD');
  CL.AddTypeS('LANGID', 'Word');
  CL.AddTypeS('THandle', 'LongWord');
  CL.AddConstantN('MAX_PATH', 'LongInt').SetInt(260);
  CL.AddTypeS('LONGLONG', 'Int64');
  CL.AddTypeS('TLargeInteger', 'Int64');
  CL.AddConstantN('MINCHAR', 'LongInt').SetInt($80);
  CL.AddConstantN('MAXCHAR', 'LongInt').SetInt(127);
  CL.AddConstantN('MINSHORT', 'LongInt').SetInt($8000);
  CL.AddConstantN('MAXSHORT', 'LongInt').SetInt(32767);
  CL.AddConstantN('MININT', 'LongInt').SetInt(Integer($80000000));
  CL.AddConstantN('MINLONG', 'LongInt').SetInt(Integer($80000000));
  CL.AddConstantN('MAXINT', 'LongInt').SetInt($7FFFFFFF);
  CL.AddConstantN('MAXLONG', 'LongInt').SetInt($7FFFFFFF);
  CL.AddConstantN('MAXBYTE', 'LongInt').SetInt(255);
  CL.AddConstantN('MAXWORD', 'LongInt').SetInt(65535);
  CL.AddConstantN('MAXDWORD', 'LongWord').SetUInt($FFFFFFFF);
  CL.AddTypeS('HDC', 'LongWord');
  CL.AddTypeS('HFONT', 'LongWord');
  CL.AddTypeS('HICON', 'LongWord');
  CL.AddTypeS('HMENU', 'LongWord');
  CL.AddTypeS('HINST', 'LongWord');
  CL.AddTypeS('HMODULE', 'HINST');
  CL.AddTypeS('HCURSOR', 'HICON');
  CL.AddTypeS('COLORREF', 'DWORD');
  CL.AddTypeS('TColorRef', 'DWORD');
  CL.AddTypeS('TPoint', 'record x : LongInt; y : LongInt; end');
  CL.AddTypeS('TSize', 'record cx : LongInt; cy : LongInt; end');
  Cl.AddTypeS('TRect', 'record Left, Top, Right, Bottom: LongInt; end');
  Cl.AddTypeS('TSmallPoint', 'record x : SmallInt; y : SmallInt; end');
  CL.AddTypeS('HWND', 'LongWord');
  CL.AddTypeS('WPARAM', 'Longint');
  CL.AddTypeS('LPARAM', 'Longint');
  CL.AddTypeS('LRESULT', 'Longint');
  CL.AddTypeS('MSG', 'record hwnd : HWND; message : UINT; wParam : WPARAM; lPar'
    + 'am : LPARAM; time : DWORD; pt : TPoint; end');
  CL.AddTypeS('TMsg', 'MSG');
  CL.AddConstantN('INVALID_HANDLE_VALUE', 'LongWord').SetUInt(DWORD(-1));
  CL.AddConstantN('INVALID_FILE_SIZE', 'LongWord').SetUInt($FFFFFFFF);
  CL.AddConstantN('FILE_BEGIN', 'LongInt').SetInt(0);
  CL.AddConstantN('FILE_CURRENT', 'LongInt').SetInt(1);
  CL.AddConstantN('FILE_END', 'LongInt').SetInt(2);
  CL.AddTypeS('FILETIME', 'record dwLowDateTime : DWORD; dwHighDateTime : DWORD; end');
  CL.AddTypeS('TFileTime', 'FILETIME');
  CL.AddTypeS('SYSTEMTIME', 'record wYear : Word; wMonth : Word; wDayOfWeek : '
    + 'Word; wDay : Word; wHour : Word; wMinute : Word; wSecond : Word; wMillisec'
    + 'onds : Word; end');
  CL.AddTypeS('TSystemTime', 'SYSTEMTIME');
  CL.AddTypeS('WIN32_FIND_DATA', 'record dwFileAttributes : DWORD; ftCreationTim'
    + 'e : TFileTime; ftLastAccessTime : TFileTime; ftLastWriteTime : TFileTime; '
    + 'nFileSizeHigh : DWORD; nFileSizeLow : DWORD; dwReserved0 : DWORD; dwReserv'
    + 'ed1 : DWORD; cFileName : array[0..259] of Char; cAlternateFileName : array'
    + '[0..13] of Char; end');
  CL.AddTypeS('TWin32FindData', 'WIN32_FIND_DATA');
  CL.AddTypeS('TOwnerDrawStateE', '( odSelected, odGrayed, odDisabled, odChecke'
    + 'd, odFocused, odDefault, odHotLight, odInactive, odNoAccel, odNoFocusRect,'
    + ' odReserved1, odReserved2, odComboBoxEdit )');
  CL.AddTypeS('TOwnerDrawState', 'set of TOwnerDrawStateE');
  CL.AddTypeS('HKEY', 'LongWord');
  CL.AddConstantN('HKEY_CLASSES_ROOT', 'LongWord').SetUInt(DWORD($80000000));
  CL.AddConstantN('HKEY_CURRENT_USER', 'LongWord').SetUInt(DWORD($80000001));
  CL.AddConstantN('HKEY_LOCAL_MACHINE', 'LongWord').SetUInt(DWORD($80000002));
  CL.AddConstantN('HKEY_USERS', 'LongWord').SetUInt(DWORD($80000003));
  CL.AddConstantN('HKEY_PERFORMANCE_DATA', 'LongWord').SetUInt(DWORD($80000004));
  CL.AddConstantN('HKEY_CURRENT_CONFIG', 'LongWord').SetUInt(DWORD($80000005));
  CL.AddConstantN('HKEY_DYN_DATA', 'LongWord').SetUInt(DWORD($80000006));
  CL.AddConstantN('MB_OK', 'LongWord').SetUInt($00000000);
  CL.AddConstantN('MB_OKCANCEL', 'LongWord').SetUInt($00000001);
  CL.AddConstantN('MB_ABORTRETRYIGNORE', 'LongWord').SetUInt($00000002);
  CL.AddConstantN('MB_YESNOCANCEL', 'LongWord').SetUInt($00000003);
  CL.AddConstantN('MB_YESNO', 'LongWord').SetUInt($00000004);
  CL.AddConstantN('MB_RETRYCANCEL', 'LongWord').SetUInt($00000005);
  CL.AddConstantN('MB_ICONHAND', 'LongWord').SetUInt($00000010);
  CL.AddConstantN('MB_ICONQUESTION', 'LongWord').SetUInt($00000020);
  CL.AddConstantN('MB_ICONEXCLAMATION', 'LongWord').SetUInt($00000030);
  CL.AddConstantN('MB_ICONASTERISK', 'LongWord').SetUInt($00000040);
  CL.AddConstantN('MB_USERICON', 'LongWord').SetUInt($00000080);
  CL.AddConstantN('MB_ICONWARNING', 'LongWord').SetUInt($00000030);
  CL.AddConstantN('MB_ICONERROR', 'LongWord').SetUInt($00000010);
  CL.AddConstantN('MB_ICONINFORMATION', 'LongWord').SetUInt($00000040);
  CL.AddConstantN('MB_ICONSTOP', 'LongWord').SetUInt($00000010);
  CL.AddConstantN('MB_DEFBUTTON1', 'LongWord').SetUInt($00000000);
  CL.AddConstantN('MB_DEFBUTTON2', 'LongWord').SetUInt($00000100);
  CL.AddConstantN('MB_DEFBUTTON3', 'LongWord').SetUInt($00000200);
  CL.AddConstantN('MB_DEFBUTTON4', 'LongWord').SetUInt($00000300);
  CL.AddConstantN('MB_APPLMODAL', 'LongWord').SetUInt($00000000);
  CL.AddConstantN('MB_SYSTEMMODAL', 'LongWord').SetUInt($00001000);
  CL.AddConstantN('MB_TASKMODAL', 'LongWord').SetUInt($00002000);
  CL.AddConstantN('MB_HELP', 'LongWord').SetUInt($00004000);
  CL.AddConstantN('MB_NOFOCUS', 'LongWord').SetUInt($00008000);
  CL.AddConstantN('MB_SETFOREGROUND', 'LongWord').SetUInt($00010000);
  CL.AddConstantN('MB_DEFAULT_DESKTOP_ONLY', 'LongWord').SetUInt($00020000);
  CL.AddConstantN('MB_TOPMOST', 'LongWord').SetUInt($00040000);
  CL.AddConstantN('COLOR_SCROLLBAR', 'LongInt').SetInt(0);
  CL.AddConstantN('COLOR_BACKGROUND', 'LongInt').SetInt(1);
  CL.AddConstantN('COLOR_ACTIVECAPTION', 'LongInt').SetInt(2);
  CL.AddConstantN('COLOR_INACTIVECAPTION', 'LongInt').SetInt(3);
  CL.AddConstantN('COLOR_MENU', 'LongInt').SetInt(4);
  CL.AddConstantN('COLOR_WINDOW', 'LongInt').SetInt(5);
  CL.AddConstantN('COLOR_WINDOWFRAME', 'LongInt').SetInt(6);
  CL.AddConstantN('COLOR_MENUTEXT', 'LongInt').SetInt(7);
  CL.AddConstantN('COLOR_WINDOWTEXT', 'LongInt').SetInt(8);
  CL.AddConstantN('COLOR_CAPTIONTEXT', 'LongInt').SetInt(9);
  CL.AddConstantN('COLOR_ACTIVEBORDER', 'LongInt').SetInt(10);
  CL.AddConstantN('COLOR_INACTIVEBORDER', 'LongInt').SetInt(11);
  CL.AddConstantN('COLOR_APPWORKSPACE', 'LongInt').SetInt(12);
  CL.AddConstantN('COLOR_HIGHLIGHT', 'LongInt').SetInt(13);
  CL.AddConstantN('COLOR_HIGHLIGHTTEXT', 'LongInt').SetInt(14);
  CL.AddConstantN('COLOR_BTNFACE', 'LongInt').SetInt(15);
  CL.AddConstantN('COLOR_BTNSHADOW', 'LongInt').SetInt(16);
  CL.AddConstantN('COLOR_GRAYTEXT', 'LongInt').SetInt(17);
  CL.AddConstantN('COLOR_BTNTEXT', 'LongInt').SetInt(18);
  CL.AddConstantN('COLOR_INACTIVECAPTIONTEXT', 'LongInt').SetInt(19);
  CL.AddConstantN('COLOR_BTNHIGHLIGHT', 'LongInt').SetInt(20);
  CL.AddConstantN('COLOR_3DDKSHADOW', 'LongInt').SetInt(21);
  CL.AddConstantN('COLOR_3DLIGHT', 'LongInt').SetInt(22);
  CL.AddConstantN('COLOR_INFOTEXT', 'LongInt').SetInt(23);
  CL.AddConstantN('COLOR_INFOBK', 'LongInt').SetInt(24);
  CL.AddConstantN('COLOR_HOTLIGHT', 'LongInt').SetInt(26);
  CL.AddConstantN('COLOR_GRADIENTACTIVECAPTION', 'LongInt').SetInt(27);
  CL.AddConstantN('COLOR_GRADIENTINACTIVECAPTION', 'LongInt').SetInt(28);
  CL.AddConstantN('COLOR_ENDCOLORS', 'LongInt').SetInt(COLOR_GRADIENTINACTIVECAPTION);
  CL.AddConstantN('COLOR_DESKTOP', 'LongInt').SetInt(COLOR_BACKGROUND);
  CL.AddConstantN('COLOR_3DFACE', 'LongInt').SetInt(COLOR_BTNFACE);
  CL.AddConstantN('COLOR_3DSHADOW', 'LongInt').SetInt(COLOR_BTNSHADOW);
  CL.AddConstantN('COLOR_3DHIGHLIGHT', 'LongInt').SetInt(COLOR_BTNHIGHLIGHT);
  CL.AddConstantN('COLOR_3DHILIGHT', 'LongInt').SetInt(COLOR_BTNHIGHLIGHT);
  CL.AddConstantN('COLOR_BTNHILIGHT', 'LongInt').SetInt(COLOR_BTNHIGHLIGHT);
  CL.AddDelphiFunction('Function MessageBox( hWnd : HWND; lpText, lpCaption : PChar; uType : UINT) : Integer');
  CL.AddDelphiFunction('Function GetCurrentProcess : THandle');
  CL.AddDelphiFunction('Function GetCurrentProcessId : DWORD');
  CL.AddDelphiFunction('Procedure ExitProcess( uExitCode : UINT)');
  CL.AddDelphiFunction('Function TerminateProcess( hProcess : THandle; uExitCode : UINT) : BOOL');
  CL.AddDelphiFunction('Function GetExitCodeProcess( hProcess : THandle; var lpExitCode : DWORD) : BOOL');
  CL.AddDelphiFunction('Function GetEnvironmentStrings : PChar');
  CL.AddDelphiFunction('Function GetCurrentThread : THandle');
  CL.AddDelphiFunction('Function GetCurrentThreadId : DWORD');
  CL.AddDelphiFunction('Function SetThreadPriority( hThread : THandle; nPriority : Integer) : BOOL');
  CL.AddDelphiFunction('Function GetThreadPriority( hThread : THandle) : Integer');
  CL.AddDelphiFunction('Procedure ExitThread( dwExitCode : DWORD)');
  CL.AddDelphiFunction('Function TerminateThread( hThread : THandle; dwExitCode : DWORD) : BOOL');
  CL.AddDelphiFunction('Function GetExitCodeThread( hThread : THandle; var lpExitCode : DWORD) : BOOL');
  CL.AddDelphiFunction('Function GetLastError : DWORD');
  CL.AddDelphiFunction('Procedure SetLastError( dwErrCode : DWORD)');
  CL.AddDelphiFunction('Function SuspendThread( hThread : THandle) : DWORD');
  CL.AddDelphiFunction('Function ResumeThread( hThread : THandle) : DWORD');
  CL.AddDelphiFunction('Procedure Sleep( dwMilliseconds : DWORD)');
  CL.AddDelphiFunction('Function Beep( dwFreq, dwDuration : DWORD) : BOOL');
  CL.AddDelphiFunction('Function SystemTimeToFileTime( const lpSystemTime : TSystemTime; var lpFileTime : TFileTime) : BOOL');
  CL.AddDelphiFunction('Function FileTimeToLocalFileTime( const lpFileTime : TFileTime; var lpLocalFileTime : TFileTime) : BOOL');
  CL.AddDelphiFunction('Function LocalFileTimeToFileTime( const lpLocalFileTime : TFileTime; var lpFileTime : TFileTime) : BOOL');
  CL.AddDelphiFunction('Function FileTimeToSystemTime( const lpFileTime : TFileTime; var lpSystemTime : TSystemTime) : BOOL');
  CL.AddDelphiFunction('Function CompareFileTime( const lpFileTime1, lpFileTime2 : TFileTime) : LongInt');
  CL.AddDelphiFunction('Function FileTimeToDosDateTime( const lpFileTime : TFileTime; var lpFatDate, lpFatTime : Word) : BOOL');
  CL.AddDelphiFunction('Function DosDateTimeToFileTime( wFatDate, wFatTime : Word; var lpFileTime : TFileTime) : BOOL');
  CL.AddDelphiFunction('Function GetTickCount : DWORD');
  CL.AddDelphiFunction('Function GetModuleFileName( hModule : HINST; lpFilename : PChar; nSize : DWORD) : DWORD');
  CL.AddDelphiFunction('Function GetModuleHandle( lpModuleName : PChar) : HMODULE');
  CL.AddDelphiFunction('Function LoadLibrary( lpLibFileName : PChar) : HMODULE');
  CL.AddDelphiFunction('Function FreeLibrary( hLibModule : HMODULE) : LongBool');
  CL.AddDelphiFunction('Function GetProcAddress( Module : HMODULE; Proc : PChar) : Pointer');
  CL.AddDelphiFunction('Function GetCommandLine : PChar');
  CL.AddDelphiFunction('Procedure OutputDebugString( lpOutputString : PChar)');
  CL.AddDelphiFunction('Function CopyFile( lpExistingFileName, lpNewFileName : PChar; bFailIfExists : BOOL) : BOOL');
  CL.AddDelphiFunction('Function MoveFile( lpExistingFileName, lpNewFileName : PChar) : BOOL');
  CL.AddDelphiFunction('procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: DWORD)');
  CL.AddDelphiFunction('procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD)');
  CL.AddDelphiFunction('procedure FillMemory(Destination: Pointer; Length: DWORD; Fill: Byte)');
  CL.AddDelphiFunction('procedure ZeroMemory(Destination: Pointer; Length: DWORD)');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)

procedure RIRegister_Windows_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@MessageBoxA, 'MessageBox', CdStdCall);
  S.RegisterDelphiFunction(@GetCurrentProcess, 'GetCurrentProcess', CdStdCall);
  S.RegisterDelphiFunction(@GetCurrentProcessId, 'GetCurrentProcessId', CdStdCall);
  S.RegisterDelphiFunction(@ExitProcess, 'ExitProcess', CdStdCall);
  S.RegisterDelphiFunction(@TerminateProcess, 'TerminateProcess', CdStdCall);
  S.RegisterDelphiFunction(@GetExitCodeProcess, 'GetExitCodeProcess', CdStdCall);
  S.RegisterDelphiFunction(@GetEnvironmentStringsA, 'GetEnvironmentStrings', CdStdCall);
  S.RegisterDelphiFunction(@GetCurrentThread, 'GetCurrentThread', CdStdCall);
  S.RegisterDelphiFunction(@GetCurrentThreadId, 'GetCurrentThreadId', CdStdCall);
  S.RegisterDelphiFunction(@SetThreadPriority, 'SetThreadPriority', CdStdCall);
  S.RegisterDelphiFunction(@GetThreadPriority, 'GetThreadPriority', CdStdCall);
  S.RegisterDelphiFunction(@ExitThread, 'ExitThread', CdStdCall);
  S.RegisterDelphiFunction(@TerminateThread, 'TerminateThread', CdStdCall);
  S.RegisterDelphiFunction(@GetExitCodeThread, 'GetExitCodeThread', CdStdCall);
  S.RegisterDelphiFunction(@GetLastError, 'GetLastError', CdStdCall);
  S.RegisterDelphiFunction(@SetLastError, 'SetLastError', CdStdCall);
  S.RegisterDelphiFunction(@SuspendThread, 'SuspendThread', CdStdCall);
  S.RegisterDelphiFunction(@ResumeThread, 'ResumeThread', CdStdCall);
  S.RegisterDelphiFunction(@Sleep, 'Sleep', CdStdCall);
  S.RegisterDelphiFunction(@Beep, 'Beep', CdStdCall);
  S.RegisterDelphiFunction(@SystemTimeToFileTime, 'SystemTimeToFileTime', CdStdCall);
  S.RegisterDelphiFunction(@FileTimeToLocalFileTime, 'FileTimeToLocalFileTime', CdStdCall);
  S.RegisterDelphiFunction(@LocalFileTimeToFileTime, 'LocalFileTimeToFileTime', CdStdCall);
  S.RegisterDelphiFunction(@FileTimeToSystemTime, 'FileTimeToSystemTime', CdStdCall);
  S.RegisterDelphiFunction(@CompareFileTime, 'CompareFileTime', CdStdCall);
  S.RegisterDelphiFunction(@FileTimeToDosDateTime, 'FileTimeToDosDateTime', CdStdCall);
  S.RegisterDelphiFunction(@DosDateTimeToFileTime, 'DosDateTimeToFileTime', CdStdCall);
  S.RegisterDelphiFunction(@GetTickCount, 'GetTickCount', CdStdCall);
  S.RegisterDelphiFunction(@GetModuleFileNameA, 'GetModuleFileName', CdStdCall);
  S.RegisterDelphiFunction(@GetModuleHandleA, 'GetModuleHandle', CdStdCall);
  S.RegisterDelphiFunction(@LoadLibraryA, 'LoadLibrary', CdStdCall);
  S.RegisterDelphiFunction(@FreeLibrary, 'FreeLibrary', CdStdCall);
  S.RegisterDelphiFunction(@GetProcAddress, 'GetProcAddress', CdStdCall);
  S.RegisterDelphiFunction(@GetCommandLineA, 'GetCommandLine', CdStdCall);
  S.RegisterDelphiFunction(@OutputDebugStringA, 'OutputDebugString', CdStdCall);
  S.RegisterDelphiFunction(@CopyFileA, 'CopyFile', CdStdCall);
  S.RegisterDelphiFunction(@MoveFileA, 'MoveFile', CdStdCall);
  S.RegisterDelphiFunction(@MoveMemory, 'MoveMemory', cdRegister);
  S.RegisterDelphiFunction(@CopyMemory, 'CopyMemory', cdRegister);
  S.RegisterDelphiFunction(@FillMemory, 'FillMemory', cdRegister);
  S.RegisterDelphiFunction(@ZeroMemory, 'ZeroMemory', cdRegister);
end;

{ TPSImport_Windows }

procedure TPSImport_Windows.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Windows(CompExec.Comp);
end;

procedure TPSImport_Windows.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Windows_Routines(CompExec.Exec);
end;

end.

