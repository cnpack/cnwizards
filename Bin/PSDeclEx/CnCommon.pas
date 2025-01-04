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

unit CnCommon;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 CnCommon 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, StdCtrls, ComCtrls, ExtCtrls;

//------------------------------------------------------------------------------
// 扩展的文件目录操作函数
//------------------------------------------------------------------------------

procedure ExploreDir(APath: string; ShowDir: Boolean);
{* 在资源管理器中打开指定目录 }

procedure ExploreFile(AFile: string; ShowDir: Boolean);
{* 在资源管理器中打开指定文件 }

function ForceDirectories(Dir: string): Boolean;
{* 递归创建多级子目录}

function MoveFile(const sName, dName: string): Boolean;
{* 移动文件、目录，参数为源、目标名}

function DeleteToRecycleBin(const FileName: string): Boolean;
{* 删除文件到回收站}

procedure FileProperties(const FName: string);
{* 打开文件属性窗口}

function OpenDialog(var FileName: string; Title: string; Filter: string;
  Ext: string): Boolean;
{* 打开文件框}

function GetDirectory(const Caption: string; var Dir: string;
  ShowNewButton: Boolean = True): Boolean;
{* 显示选择文件夹对话框，支持设置默认文件夹}

function FormatPath(APath: string; Width: Integer): string;
{* 缩短显示不下的长路径名}

procedure DrawCompactPath(Hdc: HDC; Rect: TRect; Str: string);
{* 通过 DrawText 来画缩略路径}

function SameCharCounts(s1, s2: string): Integer;
{* 两个字符串的前面的相同字符数}
function CharCounts(Str: PChar; C: Char): Integer;
{* 在字符串中某字符出现的次数}
function GetRelativePath(ATo, AFrom: string;
  const PathStr: string = '\'; const ParentStr: string = '..';
  const CurrentStr: string = '.'; const UseCurrentDir: Boolean = False): string;
{* 取两个目录的相对路径}

function LinkPath(const Head, Tail: string): string;
{* 连接两个路径，
   Head - 首路径，可以是 C:\Test、\\Test\C\Abc、http://www.abc.com/dir/ 等格式
   Tail - 尾路径，可以是 ..\Test、Abc\Temp、\Test、/web/lib 等格式或绝对地址格式 }

procedure RunFile(const FName: string; Handle: THandle = 0;
  const Param: string = '');
{* 运行一个文件}

procedure OpenUrl(const Url: string);
{* 打开一个链接}

procedure MailTo(const Addr: string; const Subject: string = '');
{* 发送邮件}

function WinExecute(FileName: string; Visibility: Integer = SW_NORMAL): Boolean;
{* 运行一个文件并立即返回 }

function WinExecAndWait32(FileName: string; Visibility: Integer = SW_NORMAL;
  ProcessMsg: Boolean = False): Integer;
{* 运行一个文件并等待其结束}

function WinExecWithPipe(const CmdLine, Dir: string; slOutput: TStrings;
  var dwExitCode: Cardinal): Boolean; overload;
{* 用管道方式在 Dir 目录执行 CmdLine，Output 返回输出信息，
   dwExitCode 返回退出码。如果成功返回 True }

function AppPath: string;
{* 应用程序路径}

function ModulePath: string;
{* 当前执行模块所在的路径 }

function GetProgramFilesDir: string;
{* 取Program Files目录}

function GetWindowsDir: string;
{* 取Windows目录}

function GetWindowsTempPath: string;
{* 取临时文件路径}

function CnGetTempFileName(const Ext: string): string;
{* 返回一个临时文件名 }

function GetSystemDir: string;
{* 取系统目录}

function ShortNameToLongName(const FileName: string): string;
{* 短文件名转长文件名}

function LongNameToShortName(const FileName: string): string;
{* 长文件名转短文件名}

function GetTrueFileName(const FileName: string): string;
{* 取得真实长文件名，包含大小写}

function FindExecFile(const AName: string; var AFullName: string): Boolean;
{* 查找可执行文件的完整路径 }

function GetSpecialFolderLocation(const Folder: Integer): string;
{* 取得系统特殊文件夹位置，Folder 使用在 ShlObj 中定义的标识，如 CSIDL_DESKTOP }

function AddDirSuffix(const Dir: string): string;
{* 目录尾加'\'修正}

function MakePath(const Dir: string): string;
{* 目录尾加'\'修正}

function MakeDir(const Path: string): string;
{* 路径尾去掉 '\'}

function GetUnixPath(const Path: string): string;
{* 路径中的 '\' 转成 '/'}

function GetWinPath(const Path: string): string;
{* 路径中的 '/' 转成 '\'}

function FileNameMatch(Pattern, FileName: PChar): Integer;
{* 文件名是否与通配符匹配，返回值为0表示匹配，其他为不匹配}

function MatchExt(const S, Ext: string): Boolean;
{* 文件名是否与扩展名通配符匹配}

function MatchFileName(const S, FN: string): Boolean;
{* 文件名是否与通配符匹配}

procedure FileExtsToStrings(const FileExts: string; ExtList: TStrings; CaseSensitive: Boolean);
{* 转换扩展名通配符字符串为通配符列表}

procedure FileMasksToStrings(const FileMasks: string; MaskList: TStrings; CaseSensitive: Boolean);
{* 转换文件通配符字符串为通配符列表}

function FileMatchesMasks(const FileName, FileMasks: string; CaseSensitive: Boolean): Boolean; overload;
{* 文件名是否匹配通配符}

function FileMatchesExts(const FileName, FileExts: string): Boolean; overload;
{* 文件名与扩展名列表比较。FileExts是如'.pas;.dfm;.inc'这样的字符串}

function IsFileInUse(const FName: string): Boolean;
{* 判断文件是否正在使用}

function IsAscii(FileName: string): Boolean;
{* 判断文件是否为 Ascii 文件}

function IsValidFileName(const Name: string): Boolean;
{* 判断文件是否是有效的文件名}

function GetValidFileName(const Name: string): string;
{* 返回有效的文件名 }

function SetFileDate(const FileName: string; CreationTime, LastWriteTime, LastAccessTime:
  TFileTime): Boolean;
{* 设置文件时间}

function GetFileDate(const FileName: string; var CreationTime, LastWriteTime, LastAccessTime:
  TFileTime): Boolean;
{* 取文件时间}

function FileTimeToDateTime(const FileTime: TFileTime): TDateTime;
{* 文件时间转本地日期时间}

function DateTimeToFileTime(const DateTime: TDateTime): TFileTime;
{* 本地日期时间转文件时间}

function GetFileIcon(const FileName: string; var Icon: TIcon): Boolean;
{* 取得与文件相关的图标，成功则返回True}

function CreateBakFile(const FileName, Ext: string): Boolean;
{* 创建备份文件}

function FileTimeToLocalSystemTime(FTime: TFileTime): TSystemTime;
{* 文件时间转本地时间}

function LocalSystemTimeToFileTime(STime: TSystemTime): TFileTime;
{* 本地时间转文件时间}

function DateTimeToLocalDateTime(DateTime: TDateTime): TDateTime;
{* UTC 时间转本地时间}
function LocalDateTimeToDateTime(DateTime: TDateTime): TDateTime;
{* 本地时间转 UTC 时间}

function CompareTextPos(const ASubText, AText1, AText2: string): Integer;
{* 比较 SubText 在两个字符串中出现的位置的大小，如果相等则比较字符串本身，忽略大小写 }

function Deltree(Dir: string; DelRoot: Boolean = True;
  DelEmptyDirOnly: Boolean = False): Boolean;
{* 删除整个目录, DelRoot 表示是否删除目录本身}

procedure DelEmptyTree(Dir: string; DelRoot: Boolean = True);
{* 删除整个目录中的空目录, DelRoot 表示是否删除目录本身}

function GetDirFiles(Dir: string): Integer;
{* 取文件夹文件数}

type
  TFindCallBack = procedure(const FileName: string; const Info: TSearchRec;
    var Abort: Boolean) of object;
{* 查找指定目录下文件的回调函数}

  TDirCallBack = procedure(const SubDir: string) of object;
{* 查找指定目录时进入子目录回调函数}

function FindFile(const Path: string; const FileName: string = '*.*';
  Proc: TFindCallBack = nil; DirProc: TDirCallBack = nil; bSub: Boolean = True;
  bMsg: Boolean = True): Boolean;
{* 查找指定目录下文件，返回是否被中断 }

function OpenWith(const FileName: string): Integer;
{* 显示文件打开方式对话框}

function CheckAppRunning(const FileName: string; var Running: Boolean): Boolean;
{* 检查指定的应用程序是否正在运行
 |<PRE>
   const FileName: string   - 应用程序文件名，不带路径，如果不带扩展名，
                              默认为".EXE"，大小写无所谓。
                              如 Notepad.EXE
   var Running: Boolean     - 返回该应用程序是否运行，运行为 True
   Result: Boolean          - 如果查找成功返回为 True，否则为 False
 |</PRE>}

type
  TVersionNumber = record
  {* 文件版本号}
    Minor: Word;
    Major: Word;
    Build: Word;
    Release: Word;
  end;

function GetFileVersionNumber(const FileName: string): TVersionNumber;
{* 取文件版本号}

function GetFileVersionStr(const FileName: string): string;
{* 取文件版本字符串}

function GetFileInfo(const FileName: string; var FileSize: Int64;
  var FileTime: TDateTime): Boolean;
{* 取文件信息}

function GetFileSize(const FileName: string): Int64;
{* 取文件长度}

function GetFileDateTime(const FileName: string): TDateTime;
{* 取文件Delphi格式日期时间}

function LoadStringFromFile(const FileName: string): string;
{* 将文件读为字符串}

function SaveStringToFile(const S, FileName: string): Boolean;
{* 保存字符串到为文件}

//------------------------------------------------------------------------------
// 环境变量相关
//------------------------------------------------------------------------------

function DelEnvironmentVar(const Name: string): Boolean;
{* 删除当前进程中的环境变量 }

function ExpandEnvironmentVar(var Value: string): Boolean;
{* 扩展当前进程中的环境变量 }

function GetEnvironmentVar(const Name: string; var Value: string;
  Expand: Boolean): Boolean;
{* 返回当前进程中的环境变量 }

function GetEnvironmentVars(const Vars: TStrings; Expand: Boolean): Boolean;
{* 返回当前进程中的环境变量列表 }

function SetEnvironmentVar(const Name, Value: string): Boolean;
{* 设置当前进程中的环境变量 }

//------------------------------------------------------------------------------
// 扩展的字符串操作函数
//------------------------------------------------------------------------------

function InStr(const sShort: string; const sLong: string): Boolean;
{* 判断s1是否包含在s2中}

function IntToStrEx(Value: Integer; Len: Integer; FillChar: Char = '0'): string;
{* 扩展整数转字符串函数}

function IntToStrSp(Value: Integer; SpLen: Integer = 3; Sp: Char = ','): string;
{* 带分隔符的整数－字符转换}

function IsFloat(const s: String): Boolean;
{* 判断字符串是否可转换成浮点型}

function IsInt(const s: String): Boolean;
{* 判断字符串是否可转换成整型}

function IsDateTime(const s: string): Boolean;
{* 判断字符串是否可转换成 DateTime }

function IsValidEmail(const s: string): Boolean;
{* 判断是否有效的邮件地址 }

function StrSpToInt(Value: String; Sp: Char = ','): Int64;
{* 去掉字符串中的分隔符－字符转换}

function ByteToBin(Value: Byte): string;
{* 字节转二进制串}

function StrRight(Str: string; Len: Integer): string;
{* 返回字符串右边的字符}

function StrLeft(Str: string; Len: Integer): string;
{* 返回字符串左边的字符}

function GetLine(C: Char; Len: Integer): string;
{* 返回字符串行}

function GetTextFileLineCount(FileName: String): Integer;
{* 返回文本文件的行数}

function Spc(Len: Integer): string;
{* 返回空格串}

procedure SwapStr(var s1, s2: string);
{* 交换字串}

procedure SeparateStrAndNum(const AInStr: string; var AOutStr: string;
  var AOutNum: Integer);
{* 分割"非数字+数字"格式的字符串中的非数字和数字}

function UnQuotedStr(const str: string; const ch: Char;
  const sep: string = ''): string;
{* 去除被引用的字符串的引用}

function CharPosWithCounter(const Sub: Char; const AStr: String;
  Counter: Integer = 1): Integer;
{* 查找字符串中出现的第 Counter 次的字符的位置 }

function CountCharInStr(const Sub: Char; const AStr: string): Integer;
{* 查找字符串中字符的出现次数}

function IsValidIdentChar(C: Char; First: Boolean = False): Boolean;
{* 判断字符是否有效标识符字符，First 表示是否为首字符}

{$IFDEF COMPILER5}
function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;
{* Delphi5没有实现布尔型转换为字符串，类似于Delphi6,7的实现}
{$ENDIF COMPILER5}

function LinesToStr(const Lines: string): string;
{* 多行文本转单行（换行符转'\n'）}

function StrToLines(const Str: string): string;
{* 单行文本转多行（'\n'转换行符）}

function MyDateToStr(Date: TDate): string;
{* 日期转字符串，使用 yyyy.mm.dd 格式}

function RegReadStringDef(const RootKey: HKEY; const Key, Name, Def: string): string;
{* 取注册表键值}

procedure ReadStringsFromIni(Ini: TCustomIniFile; const Section: string; Strings: TStrings);
{* 从 INI 中读取字符串列表}

procedure WriteStringsToIni(Ini: TCustomIniFile; const Section: string; Strings: TStrings);
{* 写字符串列表到 INI 文件中}

function VersionToStr(Version: DWORD): string;
{* 版本号转成字符串，如 $01020000 --> '1.2.0.0' }

function StrToVersion(s: string): DWORD;
{* 字符串转成版本号，如 '1.2.0.0' --> $01020000，如果格式不正确，返回 $01000000 }

function CnDateToStr(Date: TDateTime): string;
{* 转换日期为 yyyy.mm.dd 格式字符串 }

function CnStrToDate(const S: string): TDateTime;
{* 将 yyyy.mm.dd 格式字符串转换为日期 }

function DateTimeToFlatStr(const DateTime: TDateTime): string;
{* 日期时间转 '20030203132345' 式样的 14 位数字字符串}

function FlatStrToDateTime(const Section: string; var DateTime: TDateTime): Boolean;
{* '20030203132345' 式样的 14 位数字字符串转日期时间}

function StrToRegRoot(const s: string): HKEY;
{* 字符串转注册表根键，支持 'HKEY_CURRENT_USER' 'HKCR' 长短两种格式}

function RegRootToStr(Key: HKEY; ShortFormat: Boolean = True): string;
{* 注册表根键转字符串，可选 'HKEY_CURRENT_USER' 'HKCR' 长短两种格式}

function ExtractSubstr(const S: string; var Pos: Integer;
  const Delims: TSysCharSet): string;
{* 从字符串中根据指定的分隔符分离出子串
 |<PRE>
   const S: string           - 源字符串
   var Pos: Integer          - 输入查找的起始位置，输出查找完成的结束位置
   const Delims: TSysCharSet - 分隔符集合
   Result: string            - 返回子串
 |</PRE>}

function WildcardCompare(const FileWildcard, FileName: string; const IgnoreCase:
  Boolean = True): Boolean;
{* 文件名通配符比较}

function ScanCodeToAscii(Code: Word): Char;
{* 根据当前键盘布局将键盘扫描码转换成 ASCII 字符，可在 WM_KEYDOWN 等处使用
   由于不调用 ToAscii，故可支持使用 Accent Character 的键盘布局 }

function IsDeadKey(Key: Word): Boolean;
{* 返回一个虚拟键是否 Dead key}

function VirtualKeyToAscii(Key: Word): Char;
{* 根据当前键盘状态将虚拟键转换成 ASCII 字符，可在 WM_KEYDOWN 等处使用
   可能会导致 Accent Character 不正确}

function VK_ScanCodeToAscii(VKey: Word; Code: Word): Char;
{* 根据当前的键盘布局将虚拟键和扫描码转换成 ASCII 字符。通过虚拟键来处理小键盘，
   扫描码处理大键盘，支持 Accent Character 的键盘布局 }

function GetShiftState: TShiftState;
{* 返回当前的按键状态，暂不支持 ssDouble 状态 }

function IsShiftDown: Boolean;
{* 判断当前 Shift 是否按下 }

function IsAltDown: Boolean;
{* 判断当前 Alt 是否按下 }

function IsCtrlDown: Boolean;
{* 判断当前 Ctrl 是否按下 }

function IsInsertDown: Boolean;
{* 判断当前 Insert 是否按下 }

function IsCapsLockDown: Boolean;
{* 判断当前 Caps Lock 是否按下 }

function IsNumLockDown: Boolean;
{* 判断当前 NumLock 是否按下 }

function IsScrollLockDown: Boolean;
{* 判断当前 Scroll Lock 是否按下 }

function RemoveClassPrefix(const ClassName: string): string;
{* 删除类名前缀 T}

//------------------------------------------------------------------------------
// 扩展的对话框函数
//------------------------------------------------------------------------------

procedure InfoDlg(Mess: string); overload;
{* 显示提示窗口}

function InfoOk(Mess: string): Boolean; overload;
{* 显示提示确认窗口}

procedure ErrorDlg(Mess: string); overload;
{* 显示错误窗口}

procedure WarningDlg(Mess: string); overload;
{* 显示警告窗口}

function QueryDlg(Mess: string; DefaultNo: Boolean): Boolean; overload;
{* 显示查询是否窗口}

procedure LongMessageDlg(const Mess: string; AutoWrap: Boolean; const Caption: string);
{* 用 Memo 显示长字符串或多行字符串}

function CnInputQuery(const ACaption, APrompt: string;
  var Value: string; Ini: TCustomIniFile; const Section: string): Boolean;
{* 输入对话框}

function CnInputBox(const ACaption, APrompt, ADefault: string;
   Ini: TCustomIniFile; const Section: string): string;
{* 输入对话框}

//------------------------------------------------------------------------------
// 扩展日期时间操作函数
//------------------------------------------------------------------------------

function GetYear(Date: TDate): Integer;
{* 取日期年份分量}
function GetMonth(Date: TDate): Integer;
{* 取日期月份分量}
function GetDay(Date: TDate): Integer;
{* 取日期天数分量}
function GetHour(Time: TTime): Integer;
{* 取时间小时分量}
function GetMinute(Time: TTime): Integer;
{* 取时间分钟分量}
function GetSecond(Time: TTime): Integer;
{* 取时间秒分量}
function GetMSecond(Time: TTime): Integer;
{* 取时间毫秒分量}

//------------------------------------------------------------------------------
// 系统功能函数
//------------------------------------------------------------------------------

procedure MoveMouseIntoControl(AWinControl: TControl);
{* 移动鼠标到控件}

procedure AddComboBoxTextToItems(ComboBox: TComboBox; MaxItemsCount: Integer = 10);
{* 将 ComboBox 的文本内容增加到下拉列表中}

function DynamicResolution(x, y: WORD): Boolean;
{* 动态设置分辨率}

procedure StayOnTop(Handle: HWND; OnTop: Boolean);
{* 窗口最上方显示}

procedure SetHidden(Hide: Boolean);
{* 设置程序是否出现在任务栏}

procedure SetTaskBarVisible(Visible: Boolean);
{* 设置任务栏是否可见}

procedure SetDesktopVisible(Visible: Boolean);
{* 设置桌面是否可见}

function ForceForegroundWindow(HWND: HWND): Boolean;
{* 强制让一个窗口显示在前台}

function GetWorkRect(const Form: TCustomForm = nil): TRect;
{* 取桌面区域}

procedure BeginWait;
{* 显示等待光标}

procedure EndWait;
{* 结束等待光标}

function CheckWindows9598: Boolean;
{* 检测是否Win95/98平台}

function CheckWindowsNT: Boolean;
{* 检测是否 WinNT 平台}

function CheckWinXP: Boolean;
{* 检测是否WinXP以上平台}

function CheckWinVista: Boolean;
{* 检查是否 Vista/Windows 7 或以上系统}

function CheckWin8: Boolean;
{* 检查是否 Windows 8 或以上系统}

function CheckWin10: Boolean;
{* 检查是否 Windows 10 或以上系统}

function CheckWin64: Boolean;
{* 检查是否是 64 位 Windows}

function CheckWow64: Boolean;
{* 检查当前进程是否是 32 位进程跑在 64 位子系统里}

function CheckProcess64(ProcessHandle: THandle): Boolean;
{* 检查指定进程是否 64 位，参数为进程句柄（并非进程号）。如传 0 ，则判断当前进程}

function CheckProcessWow64(ProcessHandle: THandle): Boolean;
{* 检查指定进程是否是 32 位进程跑在 64 位子系统里。参数为进程句柄（并非进程号）}

function GetOSString: string;
{* 返回操作系统标识串}

function GetComputeNameStr : string;
{* 得到本机名}

function GetLocalUserName: string;
{* 得到本机用户名}

function GetRegisteredCompany: string;
{* 得到公司名}

function GetRegisteredOwner: string;
{* 得到注册用户名}

//------------------------------------------------------------------------------
// 其它过程
//------------------------------------------------------------------------------

function GetControlScreenRect(AControl: TControl): TRect;
{* 返回控件在屏幕上的坐标区域 }

procedure SetControlScreenRect(AControl: TControl; ARect: TRect);
{* 设置控件在屏幕上的坐标区域 }

function GetMultiMonitorDesktopRect: TRect;
{* 获得多显示器情况下，整个桌面相对于主显示器原点的坐标}

procedure ListboxHorizontalScrollbar(Listbox: TCustomListBox);
{* 为 Listbox 增加水平滚动条}

function TrimInt(Value, Min, Max: Integer): Integer;
{* 输出限制在Min..Max之间}

function CompareInt(V1, V2: Integer; Desc: Boolean = False): Integer;
{* 比较两个整数，V1 > V2 返回 1，V1 < V2 返回 -1，V1 = V2 返回 0
   如果 Desc 为 True，返回结果反向 }

function IntToByte(Value: Integer): Byte;
{* 输出限制在0..255之间}

function InBound(Value: Integer; V1, V2: Integer): Boolean;
{* 判断整数Value是否在V1和V2之间}

function SameMethod(Method1, Method2: TMethod): Boolean;
{* 比较两个方法地址是否相等}

function RectEqu(Rect1, Rect2: TRect): Boolean;
{* 比较两个Rect是否相等}

procedure DeRect(Rect: TRect; var x, y, Width, Height: Integer);
{* 分解一个TRect为左上角坐标x, y和宽度Width、高度Height}

function EnSize(cx, cy: Integer): TSize;
{* 返回一个TSize类型}

function RectWidth(Rect: TRect): Integer;
{* 计算TRect的宽度}

function RectHeight(Rect: TRect): Integer;
{* 计算TRect的高度}

procedure Delay(const uDelay: DWORD);
{* 延时}

function GetLastErrorMsg(IncludeErrorCode: Boolean = False): string;
{* 取得最后一次错误信息}

procedure ShowLastError;
{* 显示Win32 Api运行结果信息}

function GetHzPy(const AHzStr: string): string;
{* 取汉字的拼音}

function GetSelText(edt: TCustomEdit): string;
{* 获得CustomEdit选中的字符串，可正确处理使用了XP样式的程序}

function SoundCardExist: Boolean;
{* 声卡是否存在}

function InheritsFromClassName(AObject: TObject; const AClass: string): Boolean; overload;
{* 判断 AObject 是否派生自类名为 AClass 的类 }

procedure KillProcessByFileName(const FileName: String);
{* 根据文件名结束进程，不区分路径}

function KillProcessByFullFileName(const FullFileName: string): Boolean;
{* 根据完整文件名结束进程，区分路径}

function IndexStr(AText: string; AValues: array of string; IgCase: Boolean = True): Integer;
{* 查找字符串在动态数组中的索引，用于string类型使用Case语句}

function IndexInt(ANum: Integer; AValues: array of Integer): Integer;
{* 查找整形变量在动态数组中的索引，用于变量使用Case语句}

procedure TrimStrings(AList: TStrings);
{* 删除空行和每一行的行首尾空格 }

//==============================================================================
// 级联属性操作相关函数 by LiuXiao
//==============================================================================

function GetPropValueIncludeSub(Instance: TObject; PropName: string;
    PreferStrings: Boolean = True): Variant;
{* 获得级联属性值}

function SetPropValueIncludeSub(Instance: TObject; const PropName: string;
  const Value: Variant): Boolean;
{* 设置级联属性值}

//==============================================================================
// 其他杂项函数 by LiuXiao
//==============================================================================

function IsParentFont(AControl: TControl): Boolean;
{* 判断某 Control 的 ParentFont 属性是否为 True，如无 Parent 则返回 False }

function GetParentFont(AControl: TComponent): TFont;
{* 取某 Control 的 Parent 的 Font 属性，如果没有返回 nil }

implementation

{$WARNINGS OFF}

procedure ExploreDir(APath: string; ShowDir: Boolean);
begin
end;

procedure ExploreFile(AFile: string; ShowDir: Boolean);
begin
end;

function ForceDirectories(Dir: string): Boolean;
begin
end;

function MoveFile(const sName, dName: string): Boolean;
begin
end;

function DeleteToRecycleBin(const FileName: string): Boolean;
begin
end;

procedure FileProperties(const FName: string);
begin
end;

function OpenDialog(var FileName: string; Title: string; Filter: string;
  Ext: string): Boolean;
begin
end;

function GetDirectory(const Caption: string; var Dir: string;
  ShowNewButton: Boolean = True): Boolean;
begin
end;

function FormatPath(APath: string; Width: Integer): string;
begin
end;

procedure DrawCompactPath(Hdc: HDC; Rect: TRect; Str: string);
begin
end;

function SameCharCounts(s1, s2: string): Integer;
begin
end;

function CharCounts(Str: PChar; C: Char): Integer;
begin
end;

function GetRelativePath(ATo, AFrom: string;
  const PathStr: string = '\'; const ParentStr: string = '..';
  const CurrentStr: string = '.'; const UseCurrentDir: Boolean = False): string;
begin
end;

function LinkPath(const Head, Tail: string): string;
begin
end;

procedure RunFile(const FName: string; Handle: THandle = 0;
  const Param: string = '');
begin
end;

procedure OpenUrl(const Url: string);
begin
end;

procedure MailTo(const Addr: string; const Subject: string = '');
begin
end;

function WinExecute(FileName: string; Visibility: Integer = SW_NORMAL): Boolean;
begin
end;

function WinExecAndWait32(FileName: string; Visibility: Integer = SW_NORMAL;
  ProcessMsg: Boolean = False): Integer;
begin
end;

function WinExecWithPipe(const CmdLine, Dir: string; slOutput: TStrings;
  var dwExitCode: Cardinal): Boolean; overload;
begin
end;

function AppPath: string;
begin
end;

function ModulePath: string;
begin
end;

function GetProgramFilesDir: string;
begin
end;

function GetWindowsDir: string;
begin
end;

function GetWindowsTempPath: string;
begin
end;

function CnGetTempFileName(const Ext: string): string;
begin
end;

function GetSystemDir: string;
begin
end;

function ShortNameToLongName(const FileName: string): string;
begin
end;

function LongNameToShortName(const FileName: string): string;
begin
end;

function GetTrueFileName(const FileName: string): string;
begin
end;

function FindExecFile(const AName: string; var AFullName: string): Boolean;
begin
end;

function GetSpecialFolderLocation(const Folder: Integer): string;
begin
end;

function AddDirSuffix(const Dir: string): string;
begin
end;

function MakePath(const Dir: string): string;
begin
end;

function MakeDir(const Path: string): string;
begin
end;

function GetUnixPath(const Path: string): string;
begin
end;

function GetWinPath(const Path: string): string;
begin
end;

function FileNameMatch(Pattern, FileName: PChar): Integer;
begin
end;

function MatchExt(const S, Ext: string): Boolean;
begin
end;

function MatchFileName(const S, FN: string): Boolean;
begin
end;

procedure FileExtsToStrings(const FileExts: string; ExtList: TStrings; CaseSensitive: Boolean);
begin
end;

procedure FileMasksToStrings(const FileMasks: string; MaskList: TStrings; CaseSensitive: Boolean);
begin
end;

function FileMatchesMasks(const FileName, FileMasks: string; CaseSensitive: Boolean): Boolean; overload;
begin
end;

function FileMatchesExts(const FileName, FileExts: string): Boolean; overload;
begin
end;

function IsFileInUse(const FName: string): Boolean;
begin
end;

function IsAscii(FileName: string): Boolean;
begin
end;

function IsValidFileName(const Name: string): Boolean;
begin
end;

function GetValidFileName(const Name: string): string;
begin
end;

function SetFileDate(const FileName: string; CreationTime, LastWriteTime, LastAccessTime:
  TFileTime): Boolean;
begin
end;

function GetFileDate(const FileName: string; var CreationTime, LastWriteTime, LastAccessTime:
  TFileTime): Boolean;
begin
end;

function FileTimeToDateTime(const FileTime: TFileTime): TDateTime;
begin
end;

function DateTimeToFileTime(const DateTime: TDateTime): TFileTime;
begin
end;

function GetFileIcon(const FileName: string; var Icon: TIcon): Boolean;
begin
end;

function CreateBakFile(const FileName, Ext: string): Boolean;
begin
end;

function FileTimeToLocalSystemTime(FTime: TFileTime): TSystemTime;
begin
end;

function LocalSystemTimeToFileTime(STime: TSystemTime): TFileTime;
begin
end;

function DateTimeToLocalDateTime(DateTime: TDateTime): TDateTime;
begin
end;

function LocalDateTimeToDateTime(DateTime: TDateTime): TDateTime;
begin
end;

function CompareTextPos(const ASubText, AText1, AText2: string): Integer;
begin
end;

function Deltree(Dir: string; DelRoot: Boolean = True;
  DelEmptyDirOnly: Boolean = False): Boolean;
begin
end;

procedure DelEmptyTree(Dir: string; DelRoot: Boolean = True);
begin
end;

function GetDirFiles(Dir: string): Integer;
begin
end;

function FindFile(const Path: string; const FileName: string = '*.*';
  Proc: TFindCallBack = nil; DirProc: TDirCallBack = nil; bSub: Boolean = True;
  bMsg: Boolean = True): Boolean;
begin
end;

function OpenWith(const FileName: string): Integer;
begin
end;

function CheckAppRunning(const FileName: string; var Running: Boolean): Boolean;
begin
end;

function GetFileVersionNumber(const FileName: string): TVersionNumber;
begin
end;

function GetFileVersionStr(const FileName: string): string;
begin
end;

function GetFileInfo(const FileName: string; var FileSize: Int64;
  var FileTime: TDateTime): Boolean;
begin
end;

function GetFileSize(const FileName: string): Int64;
begin
end;

function GetFileDateTime(const FileName: string): TDateTime;
begin
end;

function LoadStringFromFile(const FileName: string): string;
begin
end;

function SaveStringToFile(const S, FileName: string): Boolean;
begin
end;

function DelEnvironmentVar(const Name: string): Boolean;
begin
end;

function ExpandEnvironmentVar(var Value: string): Boolean;
begin
end;

function GetEnvironmentVar(const Name: string; var Value: string;
  Expand: Boolean): Boolean;
begin
end;

function GetEnvironmentVars(const Vars: TStrings; Expand: Boolean): Boolean;
begin
end;

function SetEnvironmentVar(const Name, Value: string): Boolean;
begin
end;

function InStr(const sShort: string; const sLong: string): Boolean;
begin
end;

function IntToStrEx(Value: Integer; Len: Integer; FillChar: Char = '0'): string;
begin
end;

function IntToStrSp(Value: Integer; SpLen: Integer = 3; Sp: Char = ','): string;
begin
end;

function IsFloat(const s: String): Boolean;
begin
end;

function IsInt(const s: String): Boolean;
begin
end;

function IsDateTime(const s: string): Boolean;
begin
end;

function IsValidEmail(const s: string): Boolean;
begin
end;

function StrSpToInt(Value: String; Sp: Char = ','): Int64;
begin
end;

function ByteToBin(Value: Byte): string;
begin
end;

function StrRight(Str: string; Len: Integer): string;
begin
end;

function StrLeft(Str: string; Len: Integer): string;
begin
end;

function GetLine(C: Char; Len: Integer): string;
begin
end;

function GetTextFileLineCount(FileName: String): Integer;
begin
end;

function Spc(Len: Integer): string;
begin
end;

procedure SwapStr(var s1, s2: string);
begin
end;

procedure SeparateStrAndNum(const AInStr: string; var AOutStr: string;
  var AOutNum: Integer);
begin
end;

function UnQuotedStr(const str: string; const ch: Char;
  const sep: string = ''): string;
begin
end;

function CharPosWithCounter(const Sub: Char; const AStr: String;
  Counter: Integer = 1): Integer;
begin
end;

function CountCharInStr(const Sub: Char; const AStr: string): Integer;
begin
end;

function IsValidIdentChar(C: Char; First: Boolean = False): Boolean;
begin
end;

function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;
begin
end;

function LinesToStr(const Lines: string): string;
begin
end;

function StrToLines(const Str: string): string;
begin
end;

function MyDateToStr(Date: TDate): string;
begin
end;

function RegReadStringDef(const RootKey: HKEY; const Key, Name, Def: string): string;
begin
end;

procedure ReadStringsFromIni(Ini: TCustomIniFile; const Section: string; Strings: TStrings);
begin
end;

procedure WriteStringsToIni(Ini: TCustomIniFile; const Section: string; Strings: TStrings);
begin
end;

function VersionToStr(Version: DWORD): string;
begin
end;

function StrToVersion(s: string): DWORD;
begin
end;

function CnDateToStr(Date: TDateTime): string;
begin
end;

function CnStrToDate(const S: string): TDateTime;
begin
end;

function DateTimeToFlatStr(const DateTime: TDateTime): string;
begin
end;

function FlatStrToDateTime(const Section: string; var DateTime: TDateTime): Boolean;
begin
end;

function StrToRegRoot(const s: string): HKEY;
begin
end;

function RegRootToStr(Key: HKEY; ShortFormat: Boolean = True): string;
begin
end;

function ExtractSubstr(const S: string; var Pos: Integer;
  const Delims: TSysCharSet): string;
begin
end;

function WildcardCompare(const FileWildcard, FileName: string; const IgnoreCase:
  Boolean = True): Boolean;
begin
end;

function ScanCodeToAscii(Code: Word): Char;
begin
end;

function IsDeadKey(Key: Word): Boolean;
begin
end;

function VirtualKeyToAscii(Key: Word): Char;
begin
end;

function VK_ScanCodeToAscii(VKey: Word; Code: Word): Char;
begin
end;

function GetShiftState: TShiftState;
begin
end;

function IsShiftDown: Boolean;
begin
end;

function IsAltDown: Boolean;
begin
end;

function IsCtrlDown: Boolean;
begin
end;

function IsInsertDown: Boolean;
begin
end;

function IsCapsLockDown: Boolean;
begin
end;

function IsNumLockDown: Boolean;
begin
end;

function IsScrollLockDown: Boolean;
begin
end;

function RemoveClassPrefix(const ClassName: string): string;
begin
end;

procedure InfoDlg(Mess: string); overload;
begin
end;

function InfoOk(Mess: string): Boolean; overload;
begin
end;

procedure ErrorDlg(Mess: string); overload;
begin
end;

procedure WarningDlg(Mess: string); overload;
begin
end;

function QueryDlg(Mess: string; DefaultNo: Boolean): Boolean; overload;
begin
end;

procedure LongMessageDlg(const Mess: string; AutoWrap: Boolean; const Caption: string);
begin
end;

function CnInputQuery(const ACaption, APrompt: string;
  var Value: string; Ini: TCustomIniFile; const Section: string): Boolean;
begin
end;

function CnInputBox(const ACaption, APrompt, ADefault: string;
   Ini: TCustomIniFile; const Section: string): string;
begin
end;

function GetYear(Date: TDate): Integer;
begin
end;

function GetMonth(Date: TDate): Integer;
begin
end;

function GetDay(Date: TDate): Integer;
begin
end;

function GetHour(Time: TTime): Integer;
begin
end;

function GetMinute(Time: TTime): Integer;
begin
end;

function GetSecond(Time: TTime): Integer;
begin
end;

function GetMSecond(Time: TTime): Integer;
begin
end;

procedure MoveMouseIntoControl(AWinControl: TControl);
begin
end;

procedure AddComboBoxTextToItems(ComboBox: TComboBox; MaxItemsCount: Integer = 10);
begin
end;

function DynamicResolution(x, y: WORD): Boolean;
begin
end;

procedure StayOnTop(Handle: HWND; OnTop: Boolean);
begin
end;

procedure SetHidden(Hide: Boolean);
begin
end;

procedure SetTaskBarVisible(Visible: Boolean);
begin
end;

procedure SetDesktopVisible(Visible: Boolean);
begin
end;

function ForceForegroundWindow(HWND: HWND): Boolean;
begin
end;

function GetWorkRect(const Form: TCustomForm = nil): TRect;
begin
end;

procedure BeginWait;
begin
end;

procedure EndWait;
begin
end;

function CheckWindows9598: Boolean;
begin
end;

function CheckWindowsNT: Boolean;
begin
end;

function CheckWinXP: Boolean;
begin
end;

function CheckWinVista: Boolean;
begin
end;

function CheckWin8: Boolean;
begin
end;

function CheckWin10: Boolean;
begin
end;

function CheckWin64: Boolean;
begin
end;

function CheckWow64: Boolean;
begin
end;

function CheckProcess64(ProcessHandle: THandle): Boolean;
begin
end;

function CheckProcessWow64(ProcessHandle: THandle): Boolean;
begin
end;

function GetOSString: string;
begin
end;

function GetComputeNameStr : string;
begin
end;

function GetLocalUserName: string;
begin
end;

function GetRegisteredCompany: string;
begin
end;

function GetRegisteredOwner: string;
begin
end;

function GetControlScreenRect(AControl: TControl): TRect;
begin
end;

procedure SetControlScreenRect(AControl: TControl; ARect: TRect);
begin
end;

function GetMultiMonitorDesktopRect: TRect;
begin
end;

procedure ListboxHorizontalScrollbar(Listbox: TCustomListBox);
begin
end;

function TrimInt(Value, Min, Max: Integer): Integer;
begin
end;

function CompareInt(V1, V2: Integer; Desc: Boolean = False): Integer;
begin
end;

function IntToByte(Value: Integer): Byte;
begin
end;

function InBound(Value: Integer; V1, V2: Integer): Boolean;
begin
end;

function SameMethod(Method1, Method2: TMethod): Boolean;
begin
end;

function RectEqu(Rect1, Rect2: TRect): Boolean;
begin
end;

procedure DeRect(Rect: TRect; var x, y, Width, Height: Integer);
begin
end;

function EnSize(cx, cy: Integer): TSize;
begin
end;

function RectWidth(Rect: TRect): Integer;
begin
end;

function RectHeight(Rect: TRect): Integer;
begin
end;

procedure Delay(const uDelay: DWORD);
begin
end;

function GetLastErrorMsg(IncludeErrorCode: Boolean = False): string;
begin
end;

procedure ShowLastError;
begin
end;

function GetHzPy(const AHzStr: string): string;
begin
end;

function GetSelText(edt: TCustomEdit): string;
begin
end;

function SoundCardExist: Boolean;
begin
end;

function InheritsFromClassName(AObject: TObject; const AClass: string): Boolean; overload;
begin
end;

procedure KillProcessByFileName(const FileName: string);
begin
end;

function KillProcessByFullFileName(const FullFileName: string): Boolean;
begin
end;

function IndexStr(AText: string; AValues: array of string; IgCase: Boolean = True): Integer;
begin
end;

function IndexInt(ANum: Integer; AValues: array of Integer): Integer;
begin
end;

procedure TrimStrings(AList: TStrings);
begin
end;

function GetPropValueIncludeSub(Instance: TObject; PropName: string;
    PreferStrings: Boolean = True): Variant;
begin
end;

function SetPropValueIncludeSub(Instance: TObject; const PropName: string;
  const Value: Variant): Boolean;
begin
end;

function IsParentFont(AControl: TControl): Boolean;
begin
end;

function GetParentFont(AControl: TComponent): TFont;
begin
end;

end.

