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

unit Windows;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Windows 单元声明
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

const
  MAX_PATH = 260;

type

  WCHAR = WideChar;
  DWORD = LongWord;
  BOOL = LongBool;
  UCHAR = Byte;
  SHORT = Smallint;
  UINT = LongWord;
  ULONG = Cardinal;
  LCID = DWORD;
  LANGID = Word;
  THandle = LongWord;
  LONGLONG = Int64;
  TLargeInteger = Int64;

  FILETIME = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
  TFileTime = FILETIME;

  SYSTEMTIME = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  TSystemTime = SYSTEMTIME;

  WIN32_FIND_DATA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of Char;
    cAlternateFileName: array[0..13] of Char;
  end;

  TWin32FindData = WIN32_FIND_DATA;

  HWND = LongWord;
  HDC = LongWord;
  HFONT = LongWord;
  HICON = LongWord;
  HMENU = LongWord;
  HINST = LongWord;
  HMODULE = HINST;
  HCURSOR = HICON;
  COLORREF = DWORD;
  TColorRef = DWORD;

  TPoint = record
    x: LongInt;
    y: LongInt;
  end;

  TSize = record
    cx: LongInt;
    cy: LongInt;
  end;

  TRect = record
    Left, Top, Right, Bottom: LongInt;
  end;

  TSmallPoint = record
    x: SmallInt;
    y: SmallInt;
  end;

  WPARAM = Longint;
  LPARAM = Longint;
  LRESULT = Longint;

  MSG = record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
    time: DWORD;
    pt: TPoint;
  end;
  TMsg = MSG;
  
  TOwnerDrawStateE = (odSelected, odGrayed, odDisabled, odChecked,
    odFocused, odDefault, odHotLight, odInactive, odNoAccel, odNoFocusRect,
    odReserved1, odReserved2, odComboBoxEdit);
  TOwnerDrawState = set of TOwnerDrawStateE;

  HKEY = type LongWord;

const

  HKEY_CLASSES_ROOT     = DWORD($80000000);
  HKEY_CURRENT_USER     = DWORD($80000001);
  HKEY_LOCAL_MACHINE    = DWORD($80000002);
  HKEY_USERS            = DWORD($80000003);
  HKEY_PERFORMANCE_DATA = DWORD($80000004);
  HKEY_CURRENT_CONFIG   = DWORD($80000005);
  HKEY_DYN_DATA         = DWORD($80000006);

  MINCHAR = $80;
  MAXCHAR = 127;
  MINSHORT = $8000;
  MAXSHORT = 32767;
  MININT = Integer($80000000);
  MINLONG = Integer($80000000);
  MAXINT = $7FFFFFFF;
  MAXLONG = $7FFFFFFF;
  MAXBYTE = 255;
  MAXWORD = 65535;
  MAXDWORD = $FFFFFFFF;

  INVALID_HANDLE_VALUE = DWORD(-1);
  INVALID_FILE_SIZE = $FFFFFFFF;
  FILE_BEGIN = 0;
  FILE_CURRENT = 1;
  FILE_END = 2;

  MB_OK = $00000000;
  MB_OKCANCEL = $00000001;
  MB_ABORTRETRYIGNORE = $00000002;
  MB_YESNOCANCEL = $00000003;
  MB_YESNO = $00000004;
  MB_RETRYCANCEL = $00000005;
  MB_ICONHAND = $00000010;
  MB_ICONQUESTION = $00000020;
  MB_ICONEXCLAMATION = $00000030;
  MB_ICONASTERISK = $00000040;
  MB_USERICON = $00000080;
  MB_ICONWARNING = $00000030;
  MB_ICONERROR = $00000010;
  MB_ICONINFORMATION = $00000040;
  MB_ICONSTOP = $00000010;
  MB_DEFBUTTON1 = $00000000;
  MB_DEFBUTTON2 = $00000100;
  MB_DEFBUTTON3 = $00000200;
  MB_DEFBUTTON4 = $00000300;
  MB_APPLMODAL = $00000000;
  MB_SYSTEMMODAL = $00001000;
  MB_TASKMODAL = $00002000;
  MB_HELP = $00004000;
  MB_NOFOCUS = $00008000;
  MB_SETFOREGROUND = $00010000;
  MB_DEFAULT_DESKTOP_ONLY = $00020000;
  MB_TOPMOST = $00040000;

  COLOR_SCROLLBAR = 0;
  COLOR_BACKGROUND = 1;
  COLOR_ACTIVECAPTION = 2;
  COLOR_INACTIVECAPTION = 3;
  COLOR_MENU = 4;
  COLOR_WINDOW = 5;
  COLOR_WINDOWFRAME = 6;
  COLOR_MENUTEXT = 7;
  COLOR_WINDOWTEXT = 8;
  COLOR_CAPTIONTEXT = 9;
  COLOR_ACTIVEBORDER = 10;
  COLOR_INACTIVEBORDER = 11;
  COLOR_APPWORKSPACE = 12;
  COLOR_HIGHLIGHT = 13;
  COLOR_HIGHLIGHTTEXT = 14;
  COLOR_BTNFACE = 15;
  COLOR_BTNSHADOW = $10;
  COLOR_GRAYTEXT = 17;
  COLOR_BTNTEXT = 18;
  COLOR_INACTIVECAPTIONTEXT = 19;
  COLOR_BTNHIGHLIGHT = 20;
  COLOR_3DDKSHADOW = 21;
  COLOR_3DLIGHT = 22;
  COLOR_INFOTEXT = 23;
  COLOR_INFOBK = 24;
  COLOR_HOTLIGHT = 26;
  COLOR_GRADIENTACTIVECAPTION = 27;
  COLOR_GRADIENTINACTIVECAPTION = 28;
  COLOR_ENDCOLORS = COLOR_GRADIENTINACTIVECAPTION;
  COLOR_DESKTOP = COLOR_BACKGROUND;
  COLOR_3DFACE = COLOR_BTNFACE;
  COLOR_3DSHADOW = COLOR_BTNSHADOW;
  COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT;

function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer;

function GetCurrentProcess: THandle;

function GetCurrentProcessId: DWORD;

procedure ExitProcess(uExitCode: UINT);

function TerminateProcess(hProcess: THandle; uExitCode: UINT): BOOL;

function GetExitCodeProcess(hProcess: THandle; var lpExitCode: DWORD): BOOL;

function GetEnvironmentStrings: PChar;

function GetCurrentThread: THandle;

function GetCurrentThreadId: DWORD;

function SetThreadPriority(hThread: THandle; nPriority: Integer): BOOL;

function GetThreadPriority(hThread: THandle): Integer;

procedure ExitThread(dwExitCode: DWORD);

function TerminateThread(hThread: THandle; dwExitCode: DWORD): BOOL;

function GetExitCodeThread(hThread: THandle; var lpExitCode: DWORD): BOOL;

function GetLastError: DWORD;

procedure SetLastError(dwErrCode: DWORD);

function SuspendThread(hThread: THandle): DWORD;

function ResumeThread(hThread: THandle): DWORD;

procedure Sleep(dwMilliseconds: DWORD);

function Beep(dwFreq, dwDuration: DWORD): BOOL;

function SystemTimeToFileTime(const lpSystemTime: TSystemTime; var lpFileTime: TFileTime): BOOL;

function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL;

function LocalFileTimeToFileTime(const lpLocalFileTime: TFileTime; var lpFileTime: TFileTime): BOOL;

function FileTimeToSystemTime(const lpFileTime: TFileTime; var lpSystemTime: TSystemTime): BOOL;

function CompareFileTime(const lpFileTime1, lpFileTime2: TFileTime): LongInt;

function FileTimeToDosDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL;

function DosDateTimeToFileTime(wFatDate, wFatTime: Word; var lpFileTime: TFileTime): BOOL;

function GetTickCount: DWORD;

function GetModuleFileName(hModule: HINST; lpFilename: PChar; nSize: DWORD): DWORD;

function GetModuleHandle(lpModuleName: PChar): HMODULE;

function GetCommandLine: PChar;

procedure OutputDebugString(lpOutputString: PChar);

function CopyFile(lpExistingFileName, lpNewFileName: PChar; bFailIfExists: BOOL): BOOL;

function MoveFile(lpExistingFileName, lpNewFileName: PChar): BOOL;

procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: DWORD);

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);

procedure FillMemory(Destination: Pointer; Length: DWORD; Fill: Byte);

procedure ZeroMemory(Destination: Pointer; Length: DWORD);

implementation

end.


