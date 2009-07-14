{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnDebug;
{* |<PRE>
================================================================================
* 软件名称：CnDebugger
* 单元名称：CnDebug 调试信息输出接口单元
* 单元作者：刘啸（liuxiao@cnpack.org）
* 备    注：该单元定义并实现了 CnDebugger 输出信息的接口内容
*           部分内容引用了 overseer 的 udbg 单元内容
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2008.07.16
*               增加部分声明以区分对宽字符的支持。
*           2008.05.01
*               增加部分记录入文件的属性。
*           2007.09.24
*               增加 DUMP_TO_FILE 条件，可同时将信息记录入文件中。
*           2007.01.05
*               增加 ALLDEBUG 条件，等同于 DEBUG 与 SUPPORT_EVALUATE。
*           2006.11.11
*               增加运行期查看对象 RTTI 信息的功能，需要定义 SUPPORT_EVALUATE。
*           2006.10.11
*               增加一消息类型，修改为全局对象。
*           2006.07.16
*               增加了三个消息统计属性。
*           2005.02.27
*               增加了类似于 Overseer 的 JclExcept 记录功能，需要安装 JCL 库。
*               如不安装 JCL 库，则需要从 JCL 库中复制以下文件来参与编译：
*           INC:crossplatform.inc, jcl.inc, jedi.inc, windowsonly.inc
*           PAS:Jcl8087, JclBase, JclConsole, JclDateTime,
*               JclDebug, JclFileUtils, JclHookExcept,
*               JclIniFiles, JclLogic, JclMath, JclPeImage,
*               JclRegistry, JclResources, JclSecurity, JclShell,
*               JclStrings, JclSynch, JclSysInfo, JclSysUtils,
*               JclTD32, JclWideStrings, JclWin32, Snmp;
*           并打开编译选项 Include TD32 debug Info 或生成 MapFile 以获得更多信息
*               (以 JCL 1.94 版为准)
*           2004.12.22 V1.0
*               创建单元,实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

// {$DEFINE DUMP_TO_FILE}
// 定义此条件可重定向到文件.
// Define this flag to log message to a file.

{$IFDEF NDEBUG}
  {$UNDEF DEBUG}
  {$UNDEF USE_JCL}
  {$UNDEF SUPPORT_EVALUATE}
  {$UNDEF ALLDEBUG}
  {$UNDEF DUMP_TO_FILE}
{$ENDIF}

{$IFDEF ALLDEBUG}
  {$DEFINE DEBUG}
  {$DEFINE SUPPORT_EVALUATE}
{$ENDIF}

uses
  SysUtils, Classes, Windows, TypInfo, Graphics, Registry
  {$IFDEF USE_JCL}
  ,JclDebug, JclHookExcept
  {$ENDIF USE_JCL}
  ;

const
  CnMaxTagLength = 8; // 不可改变
  CnMaxMsgLength = 4096;
  CnDebugMagicLength = 8;
  CnDebugMapEnabled = $7F3D92E0; // 定义的一个 Magic 值表示 MapEnable

  SCnDebugPrefix = 'Global\';
  SCnDebugMapName = SCnDebugPrefix + 'CnDebugMap';
  SCnDebugQueueEventName = SCnDebugPrefix + 'CnDebugQueueEvent';
  SCnDebugQueueMutexName = SCnDebugPrefix + 'CnDebugQueueMutex';
  SCnDebugStartEventName = SCnDebugPrefix + 'CnDebugStartEvent';
  SCnDebugFlushEventName = SCnDebugPrefix + 'CnDebugFlushEvent';

  SCnDefaultDumpFileName = 'CnDebugDump.cdd';

type
  // ===================== 以下结构定义需要和 Viewer 共享 ======================

  // 输出的信息类型
  TCnMsgType = (cmtInformation, cmtWarning, cmtError, cmtSeparator, cmtEnterProc,
    cmtLeaveProc, cmtTimeMarkStart, cmtTimeMarkStop, cmtMemoryDump, cmtException,
    cmtObject, cmtComponent, cmtCustom, cmtSystem);
  TCnMsgTypes = set of TCnMsgType;

  // 时间戳格式类型
  TCnTimeStampType = (ttNone, ttDateTime, ttTickCount, ttCPUPeriod);

  {$NODEFINE TCnMsgAnnex}
  TCnMsgAnnex = packed record
  {* 放入数据区的每条信息的头描述结构 }
    Level:     Integer;                            // 自定义 Level 数，供用户过滤用
    Indent:    Integer;                            // 缩进数目，由 Enter 和 Leave 控制
    ProcessId: DWORD;                              // 调用者的进程 ID
    ThreadId:  DWORD;                              // 调用者的线程 ID
    Tag: array[0..CnMaxTagLength - 1] of AnsiChar; // 自定义 Tag 值，供用户过滤用
    MsgType:   DWORD;                              // 消息类型
    MsgCPInterval: DWORD;                          // 计时结束时的 CPU 周期数
    TimeStampType: DWORD;                          // 消息输出的时间戳类型
    case Integer of
      1: (MsgDateTime:   TDateTime);               // 消息输出的时间戳值 DateTime
      2: (MsgTickCount:  DWORD);                   // 消息输出的时间戳值 TickCount
      3: (MsgCPUPeriod:  Int64);                   // 消息输出的时间戳值 CPU 周期
  end;

  {$NODEFINE TCnMsgDesc}
  {$NODEFINE PCnMsgDesc}
  TCnMsgDesc = packed record
  {* 放入数据区的每条信息的描述结构，包括一信息头}
    Length: Integer;                               // 总长度，包括信息头
    Annex: TCnMsgAnnex;                            // 一个信息头
    Msg: array[0..CnMaxMsgLength - 1] of AnsiChar; // 需要记录的信息
  end;
  PCnMsgDesc = ^TCnMsgDesc;

  {$NODEFINE TCnMapFilter}
  {$NODEFINE PCnMapFilter}
  TCnMapFilter = packed record
  {* 用内存映射文件传送数据时的内存区头中的过滤器格式}
    NeedRefresh: DWORD;                            // 非 0 时需要更新
    Enabled: Integer;                              // 非 0 时表示使能
    Level: Integer;                                // 限定的 Level
    Tag: array[0..CnMaxTagLength - 1] of AnsiChar; // 限定的 Tag
    case Integer of
      0: (MsgTypes: TCnMsgTypes);                  // 限定的 MsgTypes
      1: (DummyPlace: DWORD);
  end;
  PCnMapFilter = ^TCnMapFilter;

  {$NODEFINE TCnMapHeader}
  {$NODEFINE PCnMapHeader}
  TCnMapHeader = packed record
  {* 用内存映射文件传送数据时的内存区头格式}
    MagicName:  array[0..CnDebugMagicLength - 1] of AnsiChar;  // 'CNDEBUG'
    MapEnabled: DWORD;              // 为一 CnDebugMapEnabled 时，表示区域可用
    MapSize:    DWORD;              // 整个 Map 的大小，不包括尾保护区
    DataOffset: Integer;            // 数据区相对于头部的偏移量，目前定为 64
    QueueFront: Integer;            // 队列头指针，是相对于数据区的偏移量
    QueueTail:  Integer;            // 队列尾指针，是相对于数据区的偏移量
    Filter: TCnMapFilter;           // Viewer 端设置的过滤器
  end;
  PCnMapHeader = ^TCnMapHeader;

  // ===================== 以上结构定义需要和 Viewer 共享 ======================

  TCnTimeDesc = packed record
    Tag: array[0..CnMaxTagLength - 1] of AnsiChar;
    PassCount: Integer;
    StartTime: Int64;
    AccuTime: Int64;
  end;
  PCnTimeDesc = ^TCnTimeDesc;

  TCnDebugFilter = class(TObject)
  {* 信息输出的过滤条件}
  private
    FLevel: Integer;
    FTag: string;
    FMsgTypes: TCnMsgTypes;
    FEnabled: Boolean;
  public
    property Enabled: Boolean read FEnabled write FEnabled;
    property MsgTypes: TCnMsgTypes read FMsgTypes write FMsgTypes;
    property Level: Integer read FLevel write FLevel;
    property Tag: string read FTag write FTag;
  end;

  TCnDebugChannel = class;

  TCnDebugger = class(TObject)
  private
    FActive: Boolean;
    FThrdIDList: TList;
    FIndentList: TList;
    FTimes: TList;
    FFilter: TCnDebugFilter;
    FChannel: TCnDebugChannel;
    FCSThrdId: TRTLCriticalSection;
    FAutoStart: Boolean;
    FViewerAutoStartCalled: Boolean;
    // 内部变量，控制不朝 Viewer 输出
    FIgnoreViewer: Boolean;
    FExceptFilter: TStringList;
    FExceptTracking: Boolean;
    FPostedMessageCount: Integer;
    FMessageCount: Integer;
    FDumpToFile: Boolean;
    FDumpFileName: string;
    FDumpFile: TFileStream;
    FUseAppend: Boolean;
    FAfterFirstWrite: Boolean;
    procedure CreateChannel;

    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

    function PointToString(APoint: TPoint): string;
    function RectToString(ARect: TRect): string;
    function GetExceptTracking: Boolean;
    procedure SetExceptTracking(const Value: Boolean);
    function GetDiscardedMessageCount: Integer;

    function VirtualKeyToString(AKey: Word): string;
    procedure SetDumpFileName(const Value: string);
    procedure SetDumpToFile(const Value: Boolean);
  protected
    function CheckEnabled: Boolean;
    {* 检测当前输出功能是否使能 }
    function CheckFiltered(const Tag: string; Level: Byte; AType: TCnMsgType): Boolean;
    {* 检测当前输出信息是否被允许输出，True 允许，False 允许 }

    // 处理 Indent
    function GetCurrentIndent(ThrdID: DWORD): Integer;
    function IncIndent(ThrdID: DWORD): Integer;
    function DecIndent(ThrdID: DWORD): Integer;

    // 处理计时
    function IndexOfTime(const ATag: string): PCnTimeDesc;
    function AddTimeDesc(const ATag: string): PCnTimeDesc;

    // 统一处理 Format
    function FormatMsg(const AFormat: string; Args: array of const): string;

    procedure InternalOutputMsg(const AMsg: AnsiString; Size: Integer; const ATag: AnsiString;
      ALevel, AIndent: Integer; AType: TCnMsgType; ThreadID: DWORD; CPUPeriod: Int64);
    procedure InternalOutput(var Data; Size: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure StartDebugViewer;

    // 利用 CPU 周期计时 == Start ==
    procedure StartTimeMark(const ATag: Integer; const AMsg: string = ''); overload;
    procedure StopTimeMark(const ATag: Integer; const AMsg: string = ''); overload;
    {* 此两函数不使用局部字符串变量，误差相对较小，所以推荐使用}

    // 以下两函数由于使用了 Delphi 字符串，误差较大（几万左右个 CPU 周期）
    procedure StartTimeMark(const ATag: string; const AMsg: string = ''); overload;
    procedure StopTimeMark(const ATag: string; const AMsg: string = ''); overload;
    // 利用 CPU 周期计时 == End ==

    // Log 系列输出函数 == Start ==
    procedure LogMsg(const AMsg: string);
    procedure LogMsgWithTag(const AMsg: string; const ATag: string);
    procedure LogMsgWithLevel(const AMsg: string; ALevel: Integer);
    procedure LogMsgWithType(const AMsg: string; AType: TCnMsgType);
    procedure LogMsgWithTagLevel(const AMsg: string; const ATag: string; ALevel: Integer);
    procedure LogMsgWithLevelType(const AMsg: string; ALevel: Integer; AType: TCnMsgType);
    procedure LogMsgWithTypeTag(const AMsg: string; AType: TCnMsgType; const ATag: string);
    procedure LogFmt(const AFormat: string; Args: array of const);
    procedure LogFmtWithTag(const AFormat: string; Args: array of const; const ATag: string);
    procedure LogFmtWithLevel(const AFormat: string; Args: array of const; ALevel: Integer);
    procedure LogFmtWithType(const AFormat: string; Args: array of const; AType: TCnMsgType);
    procedure LogFull(const AMsg: string; const ATag: string;
      ALevel: Integer; AType: TCnMsgType; CPUPeriod: Int64 = 0);

    procedure LogSeparator;
    procedure LogEnter(const AProcName: string; const ATag: string = '');
    procedure LogLeave(const AProcName: string; const ATag: string = '');

    // 额外辅助的输出函数
    procedure LogMsgWarning(const AMsg: string);
    procedure LogMsgError(const AMsg: string);
    procedure LogErrorFmt(const AFormat: string; Args: array of const);

    procedure LogLastError;
    procedure LogAssigned(Value: Pointer; const AMsg: string = '');
    procedure LogBoolean(Value: Boolean; const AMsg: string = '');
    procedure LogColor(Color: TColor; const AMsg: string = '');
    procedure LogFloat(Value: Extended; const AMsg: string = '');
    procedure LogInteger(Value: Integer; const AMsg: string = '');
    procedure LogChar(Value: Char; const AMsg: string = '');
    procedure LogDateTime(Value: TDateTime; const AMsg: string = '' );
    procedure LogDateTimeFmt(Value: TDateTime; const AFmt: string; const AMsg: string = '' );
    procedure LogPointer(Value: Pointer; const AMsg: string = '');
    procedure LogPoint(Point: TPoint; const AMsg: string = '');
    procedure LogRect(Rect: TRect; const AMsg: string = '');
    procedure LogStrings(Strings: TStrings; const AMsg: string = '');
    procedure LogMemDump(AMem: Pointer; Size: Integer);
    procedure LogVirtualKey(AKey: Word);
    procedure LogVirtualKeyWithTag(AKey: Word; const ATag: string);
    procedure LogObject(AObject: TObject);
    procedure LogObjectWithTag(AObject: TObject; const ATag: string);
    procedure LogCollection(ACollection: TCollection);
    procedure LogCollectionWithTag(ACollection: TCollection; const ATag: string);
    procedure LogComponent(AComponent: TComponent);
    procedure LogComponentWithTag(AComponent: TComponent; const ATag: string);
    // Log 系列输出函数 == End ==

    // Trace 系列输出函数 == Start ==
    procedure TraceMsg(const AMsg: string);
    procedure TraceMsgWithTag(const AMsg: string; const ATag: string);
    procedure TraceMsgWithLevel(const AMsg: string; ALevel: Integer);
    procedure TraceMsgWithType(const AMsg: string; AType: TCnMsgType);
    procedure TraceMsgWithTagLevel(const AMsg: string; const ATag: string; ALevel: Integer);
    procedure TraceMsgWithLevelType(const AMsg: string; ALevel: Integer; AType: TCnMsgType);
    procedure TraceMsgWithTypeTag(const AMsg: string; AType: TCnMsgType; const ATag: string);
    procedure TraceFmt(const AFormat: string; Args: array of const);
    procedure TraceFmtWithTag(const AFormat: string; Args: array of const; const ATag: string);
    procedure TraceFmtWithLevel(const AFormat: string; Args: array of const; ALevel: Integer);
    procedure TraceFmtWithType(const AFormat: string; Args: array of const; AType: TCnMsgType);
    procedure TraceFull(const AMsg: string; const ATag: string;
      ALevel: Integer; AType: TCnMsgType; CPUPeriod: Int64 = 0);

    procedure TraceSeparator;
    procedure TraceEnter(const AProcName: string; const ATag: string = '');
    procedure TraceLeave(const AProcName: string; const ATag: string = '');

    // 额外辅助的输出函数
    procedure TraceMsgWarning(const AMsg: string);
    procedure TraceMsgError(const AMsg: string);
    procedure TraceErrorFmt(const AFormat: string; Args: array of const);

    procedure TraceLastError;
    procedure TraceAssigned(Value: Pointer; const AMsg: string = '');
    procedure TraceBoolean(Value: Boolean; const AMsg: string = '');
    procedure TraceColor(Color: TColor; const AMsg: string = '');
    procedure TraceFloat(Value: Extended; const AMsg: string = '');
    procedure TraceInteger(Value: Integer; const AMsg: string = '');
    procedure TraceChar(Value: Char; const AMsg: string = '');
    procedure TraceDateTime(Value: TDateTime; const AMsg: string = '' );
    procedure TraceDateTimeFmt(Value: TDateTime; const AFmt: string; const AMsg: string = '' );
    procedure TracePointer(Value: Pointer; const AMsg: string = '');
    procedure TracePoint(Point: TPoint; const AMsg: string = '');
    procedure TraceRect(Rect: TRect; const AMsg: string = '');
    procedure TraceStrings(Strings: TStrings; const AMsg: string = '');
    procedure TraceMemDump(AMem: Pointer; Size: Integer);
    procedure TraceVirtualKey(AKey: Word);
    procedure TraceVirtualKeyWithTag(AKey: Word; const ATag: string);
    procedure TraceObject(AObject: TObject);
    procedure TraceObjectWithTag(AObject: TObject; const ATag: string);
    procedure TraceCollection(ACollection: TCollection);
    procedure TraceCollectionWithTag(ACollection: TCollection; const ATag: string);
    procedure TraceComponent(AComponent: TComponent);
    procedure TraceComponentWithTag(AComponent: TComponent; const ATag: string);
    // Trace 系列输出函数 == End ==

    // 异常过滤函数
    procedure AddFilterExceptClass(E: ExceptClass); overload;
    procedure RemoveFilterExceptClass(E: ExceptClass); overload;
    procedure AddFilterExceptClass(const EClassName: string); overload;
    procedure RemoveFilterExceptClass(const EClassName: string); overload;

    // 查看对象函数
    procedure EvaluateObject(AObject: TObject); overload;
    procedure EvaluateObject(APointer: Pointer); overload;

    // 其他属性
    property Channel: TCnDebugChannel read FChannel;
    property Filter: TCnDebugFilter read FFilter;

    property Active: Boolean read GetActive write SetActive;
    {* 是否使能，也就是是否输出信息}
    property ExceptTracking: Boolean read GetExceptTracking write SetExceptTracking;
    {* 是否捕捉异常}
    property AutoStart: Boolean read FAutoStart write FAutoStart;
    {* 是否自动启动 Viewer}

    property DumpToFile: Boolean read FDumpToFile write SetDumpToFile;
    {* 是否把输出信息同时输出到文件}
    property DumpFileName: string read FDumpFileName write SetDumpFileName;
    {* 输出的文件名}
    property UseAppend: Boolean read FUseAppend write FUseAppend;
    {* 每次运行时，如果文件已存在，是否追加到已有内容后还是重写}

    // 输出消息统计
    property MessageCount: Integer read FMessageCount;
    property PostedMessageCount: Integer read FPostedMessageCount;
    property DiscardedMessageCount: Integer read GetDiscardedMessageCount;
  end;

  TCnDebugChannel = class(TObject)
  {* 信息输出 Channel 的抽象类}
  private
    FAutoFlush: Boolean;
    FActive: Boolean;
    procedure SetAutoFlush(const Value: Boolean);
  protected
    procedure SetActive(const Value: Boolean); virtual;
    // 供子类重载以处理 Active 变化
    function CheckReady: Boolean; virtual;
    // 检测是否准备好
    procedure UpdateFlush; virtual;
    // AutoFlush 属性更新时供子类重载以进行处理
  public
    constructor Create(IsAutoFlush: Boolean = True); virtual;
    // 构造函数，参数为是否自动送出并等待接收完成
    procedure StartDebugViewer; virtual;
    // 启动 Debug Viewer 并等待其启动完成
    function CheckFilterChanged: Boolean; virtual;
    // 检测过滤条件是否改变
    procedure RefreshFilter(Filter: TCnDebugFilter); virtual;
    // 过滤条件改变时重新载入
    procedure SendContent(var MsgDesc; Size: Integer); virtual;
    // 发送信息内容
    property Active: Boolean read FActive write SetActive;
    // 是否激活
    property AutoFlush: Boolean read FAutoFlush write SetAutoFlush;
    // 是否自动送出并等接收方接收
  end;

  TCnDebugChannelClass = class of TCnDebugChannel;

  TCnMapFileChannel = class(TCnDebugChannel)
  {* 使用内存映射文件来传输数据的 Channel 实现类}
  private
    FMap: THandle;               // 内存映射文件 Handle
    FQueueEvent: THandle;        // 队列写成功事件
    FQueueFlush: THandle;        // 队列一元素被读完成事件
    FMapSize:   Integer;         // 整个 Map 的大小
    FQueueSize: Integer;         // 数据区大小
    FMapHeader: Pointer;         // Map 区指针，也是头指针
    FMsgBase:   Pointer;         // Map 的数据区指针
    FFront:     Integer;         // 队列头指针，也是相对于数据区的偏移量
    FTail:      Integer;         // 队列尾指针，也是相对于数据区的偏移量

    function IsInitedFromHeader: Boolean;  // 检测并载入头信息
    procedure DestroyHandles;
    procedure LoadQueuePtr;
    procedure SaveQueuePtr(SaveFront: Boolean = False);
  protected
    function CheckReady: Boolean; override;
    procedure UpdateFlush; override;
  public
    constructor Create(IsAutoFlush: Boolean = True); override;
    destructor Destroy; override;
    procedure StartDebugViewer; override;
    function CheckFilterChanged: Boolean; override;
    procedure RefreshFilter(Filter: TCnDebugFilter); override;
    procedure SendContent(var MsgDesc; Size: Integer); override;
  end;

function CnDebugger: TCnDebugger;

var
  CnDebugChannelClass: TCnDebugChannelClass = TCnMapFileChannel;
  // 当前 Channel 的 Class

  CnDebugMagicName: string = 'CNDEBUG';

  CurrentLevel: Byte = 3;
  CurrentTag: string = '';
  CurrentMsgType: TCnMsgType = cmtInformation;
  TimeStampType: TCnTimeStampType = ttDateTime;

implementation

{$IFDEF SUPPORT_EVALUATE}
uses
  CnPropSheetFrm;
{$ENDIF}

const
  SCnCRLF = #13#10;
  SCnTimeMarkStarted = 'Start Time Mark. ';
  SCnTimeMarkStopped = 'Stop Time Mark. ';

  SCnEnterProc = 'Enter: ';
  SCnLeaveProc = 'Leave: ';

  SCnAssigned = 'Assigned: ';
  SCnUnAssigned = 'Unassigned: ';
  SCnDefAssignedMsg = 'a Pointer.';

  SCnBooleanTrue = 'True: ';
  SCnBooleanFalse = 'False: ';
  SCnDefBooleanMsg = 'a Boolean Value.';

  SCnColor = 'Color: ';
  SCnInteger = 'Integer: ';
  SCnCharFmt = 'Char: ''%s''(%d/$%2.2x)';
  SCnDateTime = 'A Date/Time: ';
  SCnPointer = 'Pointer Address: ';
  SCnFloat = 'Float: ';
  SCnPoint = 'Point: ';
  SCnRect = 'Rect: ';
  SCnVirtualKeyFmt = 'VirtualKey: %d($%2.2x), %s';
  SCnException = 'Exception:';
  SCnNilComponent = 'Component is nil.';
  SCnObjException = '*** Exception ***';
  SCnUnknownError = 'Unknown Error! ';
  SCnLastErrorFmt = 'Last Error (Code: %d): %s';

  CnDebugWaitingMutexTime = 1000;  // Mutex 的等待时间顶多 1 秒
  CnDebugStartingEventTime = 5000; // 启动 Viewer 的 Event 的等待时间顶多 5 秒
  CnDebugFlushEventTime = 100;     // 写队列后等待读取完成的时间顶多 0.1 秒

var
  FCnDebugger: TCnDebugger = nil;

  FFixedCalling: Cardinal = 0;

{$IFDEF USE_JCL}
  FCSExcept: TRTLCriticalSection;
{$ENDIF}

function GetCPUPeriod: Int64; assembler;
asm
  DB 0FH;
  DB 031H;
end;

procedure FixCallingCPUPeriod;
var
  I: Integer;
  TestDesc: PCnTimeDesc;
begin
  CnDebugger.Channel.Active := False;
  CnDebugger.FIgnoreViewer := True;
  for I := 1 to 1000 do
  begin
    CnDebugger.StartTimeMark('', '');
    CnDebugger.StopTimeMark('', SCnTimeMarkStopped);
  end;
  CnDebugger.FIgnoreViewer := False;

  CnDebugger.FMessageCount := 0;
  CnDebugger.FPostedMessageCount := 0;
  CnDebugger.Channel.Active := True;
  TestDesc := CnDebugger.IndexOfTime('');
  if TestDesc <> nil then
    FFixedCalling := TestDesc^.AccuTime div 1000;
end;

procedure ShowError(const AMsg: string);
begin
  // MessageBox(0, PChar(AMsg), 'Error', MB_OK or MB_ICONWARNING);
end;

function PropInfoName(PropInfo: PPropInfo): string;
begin
  Result := string(PropInfo^.Name);
end;

function TypeInfoName(TypeInfo: PTypeInfo): string;
begin
  Result := string(TypeInfo^.Name);
end;

// 移植自 uDbg
procedure AddObjectToStringList(PropOwner: TObject; List: TStrings; Level: Integer);
type
  TIntegerSet = set of 0..SizeOf(Integer) * 8 - 1; // see Classes.pas
var
  PropIdx: Integer;
  PropertyList: ^TPropList;
  PropertyName: string;
  PropertyInfo: PPropInfo;
  PropertyType: PTypeInfo;
  PropertyKind: TTypeKind;
  BaseType: PTypeInfo;
  BaseData: PTypeData;
  GetProc: Pointer;
  OrdValue: Integer;
  FloatValue: Extended;
  N: Integer;
  Prefix: string;
  NewLine: string;
  EnumName: string;
  NextObject: TObject;
  FollowObject: Boolean;
begin
  GetMem(PropertyList, SizeOf(TPropList));
  try
    Prefix := StringOfChar(' ', 2 * Level);
    // Build list of published properties
    FillChar(PropertyList^[0], SizeOf(TPropList), #00);
    GetPropList(PropOwner.ClassInfo, tkProperties - [tkArray, tkRecord,
      tkInterface], @PropertyList^[0]);
    // Process property list
    PropIdx := 0;
    while ((PropIdx < High(PropertyList^)) and (nil <> PropertyList^[PropIdx])) do
    begin
      // Get information about found properties
      PropertyInfo := PropertyList^[PropIdx];
      PropertyType := PropertyInfo^.PropType^;
      PropertyKind := PropertyType^.Kind;
      PropertyName := PropInfoName(PropertyInfo);
      // Write only property
      GetProc := PropertyInfo^.GetProc;
      if not Assigned(GetProc) then
      begin
        NewLine := Prefix + '  ' + PropertyName + ' = <' +
          TypeInfoName(PropertyType) + '> (can''t be read)';
        List.Add(NewLine);
      end
      else
      begin
        case PropertyKind of
          tkSet:
            begin
              BaseType := GetTypeData(PropertyType)^.CompType^;
              BaseData := GetTypeData(BaseType);
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '+ ' + PropertyName + ' = [' +
                TypeInfoName(BaseType) + ']';
              List.Add(NewLine);
              for N := BaseData^.MinValue to BaseData^.MaxValue do
              begin
                EnumName := GetEnumName(BaseType, N);
                if EnumName = '' then
                  Break;
                NewLine := Prefix + '    ' + EnumName;
                if N in TIntegerSet(OrdValue) then
                  NewLine := NewLine + ' = True'
                else
                  NewLine := NewLine + ' = False';
                List.Add(NewLine);
              end;
            end;
          tkInteger:
            begin
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '  ' + PropertyName + ' = ' + IntToStr(OrdValue);
              List.Add(NewLine);
            end;
          tkChar:
            begin
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '  ' + PropertyName + ' = ' + '#$' +
                IntToHex(OrdValue, 2);
              List.Add(NewLine);
            end;
          tkWChar:
            begin
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '  ' + PropertyName + ' = #$' + IntToHex(OrdValue, 4);
              List.Add(NewLine);
            end;
          tkClass:
            begin
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              if OrdValue = 0 then
              begin
                NewLine := Prefix + '  ' + PropertyName + ' = <' +
                  TypeInfoName(PropertyType) + '> (not assigned)';
                List.Add(NewLine);
              end
              else
              begin
                NextObject := TObject(OrdValue);
                NewLine := Prefix + '  ' + PropertyName + ' = <' +
                  TypeInfoName(PropertyType) + '>';
                if NextObject is TComponent then
                begin
                  FollowObject := False;
                  NewLine := NewLine + ': ' + TComponent(NextObject).Name
                end
                else
                begin
                  FollowObject := True;
                  NewLine[Succ(Length(Prefix))] := '*';
                end;
                List.Add(NewLine);
                if FollowObject then
                begin
                  try
                    AddObjectToStringList(NextObject, List, Level + 1);
                  except
                    List.Add('*** Exception triggered ***');
                  end;
                end;
              end;
            end;
          tkFloat:
            begin
              FloatValue := GetFloatProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '  ' + PropertyName + ' = ' +
                FormatFloat('n', FloatValue);
              List.Add(NewLine);
            end;
          tkEnumeration:
            begin
              OrdValue := GetOrdProp(PropOwner, PropertyInfo);
              NewLine := Prefix + '  ' + PropertyName + ' = ' +
                GetEnumName(PropertyType, OrdValue);
              List.Add(NewLine);
            end;
          tkString, tkLString, tkWString{$IFDEF VER200}, tkUString{$ENDIF}:
            begin
              NewLine := Prefix + '  ' + PropertyName + ' = ' + '''' +
                GetStrProp(PropOwner, PropertyInfo) + '''';
              List.Add(NewLine);
            end;
          tkVariant:
            begin
              NewLine := Prefix + '  ' + PropertyName + ' = ' +
                GetVariantProp(PropOwner, PropertyInfo);
              List.Add(NewLine);
            end;
          tkMethod:
            begin
              NewLine := Prefix + '  ' + PropertyName + ' = (' +
                GetEnumName(TypeInfo(TMethodKind),
                Ord(GetTypeData(PropertyType)^.MethodKind)) + ')';
              List.Add(NewLine);
            end;
        else
          begin
            NewLine := Prefix + '  ' + PropertyName + ' = <' +
              TypeInfoName(PropertyType) + '> ('
              + GetEnumName(TypeInfo(TTypeKind), Ord(PropertyKind)) + ')';
            List.Add(NewLine);
          end;
        end
      end;
      // Next item in the property list
      Inc(PropIdx);
    end;
    NewLine := '';
  finally
    if NewLine <> '' then
      List.Add(NewLine);
    FreeMem(PropertyList);
  end;
end;

procedure CollectionToStringList(Collection: TCollection;
  AList: TStrings);
var
  I: Integer;
begin
  if (AList = nil) or (Collection = nil) then Exit;

  AList.Add('Collection: $' + IntToHex(Integer(Collection), 2) + ' ' + Collection.ClassName);
  AList.Add('  Count = ' + IntToStr(Collection.Count));
  for I := 0 to Collection.Count - 1 do
  begin
    AList.Add('');
    AList.Add('  object: ' + Collection.Items[I].ClassName);
    AList.Add('    Index = ' + IntToStr(I));
    AddObjectToStringList(Collection.Items[I], AList, 1);
    AList.Add('  end');
  end;
  AList.Add('end');
end;


function CnDebugger: TCnDebugger;
begin
{$IFNDEF NDEBUG}
  if FCnDebugger = nil then
    FCnDebugger := TCnDebugger.Create;
  Result := FCnDebugger;
{$ELSE}
  Result := nil;
{$ENDIF}
end;

{ TCnDebugger }

procedure TCnDebugger.AddFilterExceptClass(E: ExceptClass);
begin
  FExceptFilter.Add(E.ClassName);
end;

procedure TCnDebugger.AddFilterExceptClass(const EClassName: string);
begin
  FExceptFilter.Add(EClassName);
end;

function TCnDebugger.AddTimeDesc(const ATag: string): PCnTimeDesc;
var
  ADesc: PCnTimeDesc;
  Len: Integer;
begin
  New(ADesc);
  FillChar(ADesc^, SizeOf(TCnTimeDesc), 0);
  Len := Length(ATag);
  if Len > CnMaxTagLength then
    Len := CnMaxTagLength;

  CopyMemory(@(ADesc^.Tag), PChar(ATag), Len);
  FTimes.Add(ADesc);
  Result := ADesc;
end;

function TCnDebugger.CheckEnabled: Boolean;
begin
  Result := (Self <> nil) and FActive and (FChannel <> nil) and FChannel.Active;
end;

function TCnDebugger.CheckFiltered(const Tag: string;
  Level: Byte; AType: TCnMsgType): Boolean;
begin
  Result := True;
  if FFilter.Enabled then
  begin
    Result := Level <= FFilter.Level;
    if Result then
    begin
      Result := (FFilter.MsgTypes = []) or (AType in FFilter.MsgTypes);
      if Result then
        Result := (FFilter.Tag = '') or ((UpperCase(Tag) = UpperCase(FFilter.Tag))
          and (Length(Tag) <= CnMaxTagLength));
    end;
  end;
end;

constructor TCnDebugger.Create;
begin
  inherited;
  FAutoStart := True; // 是否有输出时自动启动 Viewer
  FIndentList := TList.Create;
  FThrdIDList := TList.Create;
  FTimes := TList.Create;

  FFilter := TCnDebugFilter.Create;
  FFilter.FLevel := CurrentLevel;

  {$IFDEF USE_JCL}
  FExceptTracking := True;
  FExceptFilter := TStringList.Create;
  FExceptFilter.Duplicates := dupIgnore;
  {$ENDIF}

  FDumpFileName := SCnDefaultDumpFileName;
  InitializeCriticalSection(FCSThrdId);
  CreateChannel;

{$IFDEF DUMP_TO_FILE}
  DumpToFile := True;
{$ENDIF}
  
  FActive := True;
end;

procedure TCnDebugger.CreateChannel;
begin
  if CnDebugChannelClass <> nil then
  begin
    FChannel := TCnDebugChannel(CnDebugChannelClass.NewInstance);
    try
      FChannel.Create(True); // 此处控制是否自动 Flush
    except
      FChannel := nil;
    end;
  end;
end;

function TCnDebugger.DecIndent(ThrdID: DWORD): Integer;
var
  Indent, Index: Integer;
begin
  Index := FThrdIDList.IndexOf(Pointer(ThrdID));
  if Index >= 0 then
  begin
    Indent := Integer(FIndentList.Items[Index]);
    if Indent > 0 then Dec(Indent);
    FIndentList.Items[Index] := Pointer(Indent);
    Result := Indent;
  end
  else
  begin
    EnterCriticalSection(FCSThrdId);
    FThrdIDList.Add(Pointer(ThrdID));
    FIndentList.Add(nil);
    LeaveCriticalSection(FCSThrdId);
    Result := 0;
  end;
end;

destructor TCnDebugger.Destroy;
var
  I: Integer;
begin
  DeleteCriticalSection(FCSThrdId);
  FChannel.Free;
  FDumpFile.Free;
  FFilter.Free;
  for I := 0 to FTimes.Count - 1 do
    if FTimes[I] <> nil then
      Dispose(FTimes[I]);
  FExceptFilter.Free;
  FTimes.Free;
  FThrdIDList.Free;
  FIndentList.Free;
  inherited;
end;


function TCnDebugger.FormatMsg(const AFormat: string;
  Args: array of const): string;
var
  I: Integer;
begin
  try
    Result := Format(AFormat, Args);
  except
    // Format String Error.
    Result := 'Format Error! Format String: ' + AFormat + '. ';
    if Integer(High(Args)) >= 0 then
    begin
      Result := Result + #13#10'Hex Params:';
      for I := Low(Args) to High(Args) do
        Result := Result + Format(' %8.8x', [Args[I].VInteger]);
    end;
  end;
end;

function TCnDebugger.GetActive: Boolean;
begin
  Result := FActive;
end;

function TCnDebugger.GetCurrentIndent(ThrdID: DWORD): Integer;
var
  Index: Integer;
begin
  Index := FThrdIDList.IndexOf(Pointer(ThrdID));
  if Index >= 0 then
  begin
    Result := Integer(FIndentList.Items[Index]);
  end
  else
  begin
    EnterCriticalSection(FCSThrdId);
    FThrdIDList.Add(Pointer(ThrdID));
    FIndentList.Add(nil);
    LeaveCriticalSection(FCSThrdId);
    Result := 0;
  end;
end;

function TCnDebugger.GetExceptTracking: Boolean;
begin
  Result := FExceptTracking;
end;

function TCnDebugger.IncIndent(ThrdID: DWORD): Integer;
var
  Indent, Index: Integer;
begin
  Index := FThrdIDList.IndexOf(Pointer(ThrdID));
  if Index >= 0 then
  begin
    Indent := Integer(FIndentList.Items[Index]);
    Inc(Indent);
    FIndentList.Items[Index] := Pointer(Indent);
    Result := Indent;
  end
  else
  begin
    EnterCriticalSection(FCSThrdId);
    FThrdIDList.Add(Pointer(ThrdID));
    FIndentList.Add(Pointer(1));
    LeaveCriticalSection(FCSThrdId);
    Result := 1;
  end;
end;

function TCnDebugger.IndexOfTime(const ATag: string): PCnTimeDesc;
var
  I, Len: Integer;
  TmpTag: array[0..CnMaxTagLength - 1] of Char;
begin
  Result := nil;
  FillChar(TmpTag, CnMaxTagLength, 0);
  Len := Length(ATag);
  if Len > CnMaxTagLength then
    Len := CnMaxTagLength;
  CopyMemory(@TmpTag, PChar(ATag), Len);

  for I := 0 to FTimes.Count - 1 do
  begin
    if FTimes[I] <> nil then
    begin
      if ((ATag = '') and (PCnTimeDesc(FTimes[I])^.Tag[0] = #0))
        or CompareMem(@(PCnTimeDesc(FTimes[I])^.Tag), @TmpTag, CnMaxTagLength) then
      begin
        Result := PCnTimeDesc(FTimes[I]);
        Exit;
      end;
    end
  end;
end;

procedure TCnDebugger.InternalOutput(var Data; Size: Integer);
begin
  if (FChannel = nil) or not FChannel.Active or not FChannel.CheckReady then Exit;
  if Size > 0 then
  begin
    FChannel.SendContent(Data, Size);
    Inc(FPostedMessageCount);
  end;
end;

procedure TCnDebugger.InternalOutputMsg(const AMsg: AnsiString; Size: Integer;
  const ATag: AnsiString; ALevel, AIndent: Integer; AType: TCnMsgType;
  ThreadID: DWORD; CPUPeriod: Int64);
var
  TagLen, MsgLen: Integer;
  MsgDesc: TCnMsgDesc;
begin
  if FAutoStart and not FIgnoreViewer and not FViewerAutoStartCalled then
  begin
    StartDebugViewer;
    FViewerAutoStartCalled := True;
  end;

  Inc(FMessageCount);
  if not CheckEnabled or not FChannel.CheckReady then Exit;
  if FChannel.CheckFilterChanged then
    FChannel.RefreshFilter(FFilter);

  if not CheckFiltered(string(ATag), ALevel, AType) then
    Exit;
  
  // 进行具体的组装工作
  MsgLen := Size;
  if MsgLen > CnMaxMsgLength then
    MsgLen := CnMaxMsgLength;
  TagLen := Length(ATag);
  if TagLen > CnMaxTagLength then
    TagLen := CnMaxTagLength;

  FillChar(MsgDesc, SizeOf(MsgDesc), 0);
  MsgDesc.Annex.Level := ALevel;
  MsgDesc.Annex.Indent := AIndent;
  MsgDesc.Annex.ProcessId := GetCurrentProcessId;
  MsgDesc.Annex.ThreadId := ThreadID;
  MsgDesc.Annex.MsgType := Ord(AType);
  MsgDesc.Annex.TimeStampType := Ord(TimeStampType);
  
  case TimeStampType of
    ttDateTime: MsgDesc.Annex.MsgDateTime := Date + Time;
    ttTickCount: MsgDesc.Annex.MsgTickCount := GetTickCount;
    ttCPUPeriod: MsgDesc.Annex.MsgCPUPeriod := GetCPUPeriod;
  else
    MsgDesc.Annex.MsgCPUPeriod := 0; // 设为全 0
  end;

  // TimeMarkStop 时所耗 CPU 时钟周期数
  MsgDesc.Annex.MsgCPInterval := CPUPeriod;

  CopyMemory(@(MsgDesc.Annex.Tag), Pointer(ATag), TagLen);
  CopyMemory(@(MsgDesc.Msg), Pointer(AMsg), MsgLen);

  MsgLen := MsgLen + SizeOf(MsgDesc.Annex) + SizeOf(DWORD);
  MsgDesc.Length := MsgLen;
  InternalOutput(MsgDesc, MsgLen);

  // 同时 DumpToFile
  if FDumpToFile and not FIgnoreViewer and (FDumpFile <> nil) then
  begin
    if not FAfterFirstWrite then // 第一回写时需要判断是否重写
    begin
      if FUseAppend then
        FDumpFile.Seek(0, soFromEnd)
      else
      begin
        FDumpFile.Size := 0;
        FDumpFile.Seek(0, soFromBeginning);
      end;
      FAfterFirstWrite := True; // 后续写就无需判断了
    end;
    
    FDumpFile.Write(MsgDesc, MsgLen);
  end;
end;

procedure TCnDebugger.LogAssigned(Value: Pointer; const AMsg: string);
begin
{$IFDEF DEBUG}
  if Assigned(Value) then
  begin
    if AMsg = '' then
      LogMsg(SCnAssigned + SCnDefAssignedMsg)
    else
      LogMsg(SCnAssigned + AMsg);
  end
  else
  begin
    if AMsg = '' then
      LogMsg(SCnUnAssigned + SCnDefAssignedMsg)
    else
      LogMsg(SCnUnAssigned + AMsg);
  end;
{$ENDIF}
end;

procedure TCnDebugger.LogBoolean(Value: Boolean; const AMsg: string);
begin
{$IFDEF DEBUG}
  if Value then
  begin
    if AMsg = '' then
      LogMsg(SCnBooleanTrue + SCnDefBooleanMsg)
    else
      LogMsg(SCnBooleanTrue + AMsg);
  end
  else
  begin
    if AMsg = '' then
      LogMsg(SCnBooleanFalse + SCnDefBooleanMsg)
    else
      LogMsg(SCnBooleanFalse + AMsg);
  end;
{$ENDIF}  
end;

procedure TCnDebugger.LogCollectionWithTag(ACollection: TCollection;
  const ATag: string);
{$IFDEF DEBUG}
var
  List: TStringList;
{$ENDIF}
begin
{$IFDEF DEBUG}
  List := nil;
  try
    List := TStringList.Create;
    try
      CollectionToStringList(ACollection, List);
    except
      List.Add(SCnObjException);
    end;
    LogMsgWithType(List.Text, cmtObject);
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.LogCollection(ACollection: TCollection);
begin
{$IFDEF DEBUG}
  LogCollectionWithTag(ACollection, CurrentTag);
{$ENDIF}
end;

procedure TCnDebugger.LogColor(Color: TColor; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnColor + ColorToString(Color))
  else
    LogFmt('%s %s', [AMsg, ColorToString(Color)]);
{$ENDIF}
end;

procedure TCnDebugger.LogComponent(AComponent: TComponent);
begin
{$IFDEF DEBUG}
  LogComponentWithTag(AComponent, CurrentTag);
{$ENDIF}
end;

procedure TCnDebugger.LogComponentWithTag(AComponent: TComponent;
  const ATag: string);
{$IFDEF DEBUG}
var
  InStream, OutStream: TMemoryStream;
  ThrdID: DWORD;
{$ENDIF}
begin
{$IFDEF DEBUG}
  InStream := nil; OutStream := nil;
  try
    InStream := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;

    if Assigned(AComponent) then
    begin
      InStream.WriteComponent(AComponent);
      InStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(InStream, OutStream);
      ThrdID := GetCurrentThreadID;
      InternalOutputMsg(AnsiString(OutStream.Memory), OutStream.Size, AnsiString(ATag), CurrentLevel,
        GetCurrentIndent(ThrdID), cmtComponent, ThrdID, 0);
    end
    else
      LogMsgWithTypeTag(SCnNilComponent, cmtComponent, ATag);
  finally
    InStream.Free;
    OutStream.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.LogEnter(const AProcName, ATag: string);
begin
{$IFDEF DEBUG}
  LogFull(SCnEnterProc + AProcName, ATag, CurrentLevel, cmtEnterProc);
  IncIndent(GetCurrentThreadId);
{$ENDIF}
end;

procedure TCnDebugger.LogFloat(Value: Extended; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnFloat + FloatToStr(Value))
  else
    LogFmt('%s %s', [AMsg, FloatToStr(Value)]);
{$ENDIF}
end;

procedure TCnDebugger.LogFmt(const AFormat: string; Args: array of const);
begin
{$IFDEF DEBUG}
  LogFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogFmtWithLevel(const AFormat: string;
  Args: array of const; ALevel: Integer);
begin
{$IFDEF DEBUG}
  LogFull(FormatMsg(AFormat, Args), CurrentTag, ALevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogFmtWithTag(const AFormat: string;
  Args: array of const; const ATag: string);
begin
{$IFDEF DEBUG}
  LogFull(FormatMsg(AFormat, Args), ATag, CurrentLevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogFmtWithType(const AFormat: string;
  Args: array of const; AType: TCnMsgType);
begin
{$IFDEF DEBUG}
  LogFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, AType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgError(const AMsg: string);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, CurrentLevel, cmtError);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWarning(const AMsg: string);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, CurrentLevel, cmtWarning);
{$ENDIF}
end;

procedure TCnDebugger.LogErrorFmt(const AFormat: string;
  Args: array of const);
begin
{$IFDEF DEBUG}
  LogFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, cmtError);
{$ENDIF}
end;

procedure TCnDebugger.LogFull(const AMsg, ATag: string; ALevel: Integer;
  AType: TCnMsgType; CPUPeriod: Int64 = 0);
{$IFDEF DEBUG}
{$IFNDEF NDEBUG}
var
  ThrdID: DWORD;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUG}
{$IFNDEF NDEBUG}
  if AMsg = '' then Exit;
  ThrdID := GetCurrentThreadID;
  InternalOutputMsg(AnsiString(AMsg), Length(AnsiString(AMsg)), AnsiString(ATag),
    ALevel, GetCurrentIndent(ThrdID), AType, ThrdID, CPUPeriod);
{$ENDIF}
{$ENDIF}
end;

procedure TCnDebugger.LogInteger(Value: Integer; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnInteger + IntToStr(Value))
  else
    LogFmt('%s %d', [AMsg, Value]);
{$ENDIF}
end;

procedure TCnDebugger.LogChar(Value: Char; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogFmt(SCnCharFmt, [Value, Ord(Value), Ord(Value)])
  else
    LogFmt('%s ''%s''(%d/$%2.2x)', [AMsg, Value, Ord(Value), Ord(Value)]);
{$ENDIF}
end;

procedure TCnDebugger.LogDateTime(Value: TDateTime; const AMsg: string = '' );
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnDateTime + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Value))
  else
    LogMsg(AMsg + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Value));
{$ENDIF}
end;

procedure TCnDebugger.LogDateTimeFmt(Value: TDateTime; const AFmt: string; const AMsg: string = '' );
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnDateTime + FormatDateTime(AFmt, Value))
  else
    LogMsg(AMsg + FormatDateTime(AFmt, Value));
{$ENDIF}
end;

procedure TCnDebugger.LogPointer(Value: Pointer; const AMsg: string = '');
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogFmt('%s $%p', [SCnPointer, Value])
  else
    LogFmt('%s $%p', [AMsg, Value]);
{$ENDIF}
end;

procedure TCnDebugger.LogLeave(const AProcName, ATag: string);
begin
{$IFDEF DEBUG}
  DecIndent(GetCurrentThreadId);
  LogFull(SCnLeaveProc + AProcName, ATag, CurrentLevel, cmtLeaveProc);
{$ENDIF}
end;

procedure TCnDebugger.LogMemDump(AMem: Pointer; Size: Integer);
{$IFDEF DEBUG}
var
  ThrdID: DWORD;
{$ENDIF}  
begin
{$IFDEF DEBUG}
  ThrdID := GetCurrentThreadID;
  InternalOutputMsg(AnsiString(AMem), Size, AnsiString(CurrentTag), CurrentLevel, GetCurrentIndent(ThrdID),
    cmtMemoryDump, ThrdID, 0);
{$ENDIF}
end;

procedure TCnDebugger.LogVirtualKey(AKey: Word);
begin
{$IFDEF DEBUG}
  LogVirtualKeyWithTag(AKey, CurrentTag);
{$ENDIF}
end;

procedure TCnDebugger.LogVirtualKeyWithTag(AKey: Word; const ATag: string);
begin
{$IFDEF DEBUG}
  LogFmtWithTag(SCnVirtualKeyFmt, [AKey, AKey, VirtualKeyToString(AKey)], ATag);
{$ENDIF}
end;

procedure TCnDebugger.LogMsg(const AMsg: string);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, CurrentLevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithLevel(const AMsg: string; ALevel: Integer);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, ALevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithLevelType(const AMsg: string;
  ALevel: Integer; AType: TCnMsgType);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, ALevel, AType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithTag(const AMsg, ATag: string);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, ATag, CurrentLevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithTagLevel(const AMsg, ATag: string;
  ALevel: Integer);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, ATag, ALevel, CurrentMsgType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithType(const AMsg: string;
  AType: TCnMsgType);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, CurrentTag, CurrentLevel, AType);
{$ENDIF}
end;

procedure TCnDebugger.LogMsgWithTypeTag(const AMsg: string;
  AType: TCnMsgType; const ATag: string);
begin
{$IFDEF DEBUG}
  LogFull(AMsg, ATag, CurrentLevel, AType);
{$ENDIF}
end;

procedure TCnDebugger.LogLastError;
begin
{$IFDEF DEBUG}
  TraceLastError;
{$ENDIF}
end;

procedure TCnDebugger.LogObject(AObject: TObject);
begin
{$IFDEF DEBUG}
  LogObjectWithTag(AObject, CurrentTag);
{$ENDIF}
end;

procedure TCnDebugger.LogObjectWithTag(AObject: TObject;
  const ATag: string);
{$IFDEF DEBUG}
var
  List: TStringList;
{$ENDIF}
begin
{$IFDEF DEBUG}
  List := nil;
  try
    List := TStringList.Create;
    try
      AddObjectToStringList(AObject, List, 0);
    except
      List.Add(SCnObjException);
    end;
    LogMsgWithType('Object: $' + IntToHex(Integer(AObject), 2) + SCnCRLF +
      List.Text, cmtObject);
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.LogPoint(Point: TPoint; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnPoint + PointToString(Point))
  else
    LogFmt('%s %s', [AMsg, PointToString(Point)]);
{$ENDIF}
end;

procedure TCnDebugger.LogRect(Rect: TRect; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    LogMsg(SCnRect + RectToString(Rect))
  else
    LogFmt('%s %s', [AMsg, RectToString(Rect)]);
{$ENDIF}
end;

procedure TCnDebugger.LogSeparator;
begin
{$IFDEF DEBUG}
  LogFull('-', CurrentTag, CurrentLevel, cmtSeparator);
{$ENDIF}
end;

procedure TCnDebugger.LogStrings(Strings: TStrings; const AMsg: string);
begin
{$IFDEF DEBUG}
  if AMsg = '' then
    TraceMsg(Strings.Text)
  else
    TraceMsg(AMsg + SCnCRLF + Strings.Text);
{$ENDIF}    
end;

function TCnDebugger.PointToString(APoint: TPoint): string;
begin
  Result := '(' + IntToStr(APoint.x) + ',' + IntToStr(APoint.y) + ')';
end;

function TCnDebugger.RectToString(ARect: TRect): string;
begin
  Result := '(' + PointToString(ARect.TopLeft) + ',' +
    PointToString(ARect.BottomRight) + ')';
end;

procedure TCnDebugger.RemoveFilterExceptClass(E: ExceptClass);
var
  I: Integer;
begin
  I := FExceptFilter.IndexOf(E.ClassName);
  if I >= 0 then
    FExceptFilter.Delete(I);
end;

procedure TCnDebugger.RemoveFilterExceptClass(const EClassName: string);
var
  I: Integer;
begin
  I := FExceptFilter.IndexOf(EClassName);
  if I >= 0 then
    FExceptFilter.Delete(I);
end;

procedure TCnDebugger.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TCnDebugger.SetExceptTracking(const Value: Boolean);
begin
  FExceptTracking := Value;
end;

procedure TCnDebugger.StartDebugViewer;
begin
  if FChannel <> nil then
    FChannel.StartDebugViewer;
end;

procedure TCnDebugger.StartTimeMark(const ATag, AMsg: string);
{$IFNDEF NDEBUG}
var
  ADesc: PCnTimeDesc;
{$ENDIF}
begin
{$IFNDEF NDEBUG}
  // 根据 ATag 找是否存在以前的记录，不存在则新增
//  if ATag = '' then Exit;
  ADesc := IndexOfTime(ATag);
  if ADesc = nil then
    ADesc := AddTimeDesc(ATag);

  if ADesc <> nil then
  begin
//    不发记录，以降低误差，原理不详，惭愧
//    if AMsg <> '' then
//      TraceFull(AMsg, ATag, DefLevel, mtTimeMarkStart)
//    else
//      TraceFull(SCnTimeMarkStarted, ATag, DefLevel, mtTimeMarkStart);

    // 最后记录当时的 CPU 周期
    Inc(ADesc^.PassCount);
    ADesc^.StartTime := GetCPUPeriod;
  end;
{$ENDIF}
end;

procedure TCnDebugger.StartTimeMark(const ATag: Integer;
  const AMsg: string);
begin
  StartTimeMark(Copy('#' + IntToStr(ATag), 1, CnMaxTagLength), AMsg);
end;

procedure TCnDebugger.StopTimeMark(const ATag, AMsg: string);
{$IFNDEF NDEBUG}
var
  Period: Int64;
  ADesc: PCnTimeDesc;
{$ENDIF}
begin
{$IFNDEF NDEBUG}
  // 马上记录当时的 CPU 周期
  Period := GetCPUPeriod;
  // if ATag = '' then Exit;
  ADesc := IndexOfTime(ATag);
  if ADesc <> nil then
  begin
    // 得到相应的旧记录，相减，并减去误差，作为记录发出去
    Inc(ADesc^.AccuTime, Period - ADesc^.StartTime - FFixedCalling);
    if AMsg <> '' then
      TraceFull(AMsg, ATag, CurrentLevel, cmtTimeMarkStop, ADesc^.AccuTime)
    else
      TraceFull(SCnTimeMarkStopped, ATag, CurrentLevel, cmtTimeMarkStop, ADesc^.AccuTime);
  end;
{$ENDIF}
end;

procedure TCnDebugger.StopTimeMark(const ATag: Integer;
  const AMsg: string);
begin
  StopTimeMark(Copy('#' + IntToStr(ATag), 1, CnMaxTagLength), AMsg);
end;

procedure TCnDebugger.TraceAssigned(Value: Pointer; const AMsg: string);
begin
  if Assigned(Value) then
  begin
    if AMsg = '' then
      TraceMsg(SCnAssigned + SCnDefAssignedMsg)
    else
      TraceMsg(SCnAssigned + AMsg);
  end
  else
  begin
    if AMsg = '' then
      TraceMsg(SCnUnAssigned + SCnDefAssignedMsg)
    else
      TraceMsg(SCnUnAssigned + AMsg);
  end;
end;

procedure TCnDebugger.TraceBoolean(Value: Boolean;
  const AMsg: string);
begin
  if Value then
  begin
    if AMsg = '' then
      TraceMsg(SCnBooleanTrue + SCnDefBooleanMsg)
    else
      TraceMsg(SCnBooleanTrue + AMsg);
  end
  else
  begin
    if AMsg = '' then
      TraceMsg(SCnBooleanFalse + SCnDefBooleanMsg)
    else
      TraceMsg(SCnBooleanFalse + AMsg);
  end;
end;

procedure TCnDebugger.TraceCollection(ACollection: TCollection);
begin
  TraceCollectionWithTag(ACollection, CurrentTag);
end;

procedure TCnDebugger.TraceCollectionWithTag(ACollection: TCollection;
  const ATag: string);
{$IFNDEF NDEBUG}
var
  List: TStringList;
{$ENDIF}  
begin
{$IFNDEF NDEBUG}
  List := nil;
  try
    List := TStringList.Create;
    try
      CollectionToStringList(ACollection, List);
    except
      List.Add(SCnObjException);
    end;
    TraceMsgWithType(List.Text, cmtObject);
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.TraceColor(Color: TColor; const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(SCnColor + ColorToString(Color))
  else
    TraceFmt('%s %s', [AMsg, ColorToString(Color)]);
end;

procedure TCnDebugger.TraceComponent(AComponent: TComponent);
begin
  TraceComponentWithTag(AComponent, CurrentTag);
end;

procedure TCnDebugger.TraceComponentWithTag(AComponent: TComponent;
  const ATag: string);
{$IFNDEF NDEBUG}
var
  InStream, OutStream: TMemoryStream;
  ThrdID: DWORD;
{$ENDIF}
begin
{$IFNDEF NDEBUG}
  InStream := nil; OutStream := nil;
  try
    InStream := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;

    if Assigned(AComponent) then
    begin
      InStream.WriteComponent(AComponent);
      InStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(InStream, OutStream);
      ThrdID := GetCurrentThreadID;
      InternalOutputMsg(AnsiString(OutStream.Memory), OutStream.Size, AnsiString(ATag), CurrentLevel,
        GetCurrentIndent(ThrdID), cmtComponent, ThrdID, 0);
    end
    else
      TraceMsgWithTypeTag(SCnNilComponent, cmtComponent, ATag);
  finally
    InStream.Free;
    OutStream.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.TraceEnter(const AProcName, ATag: string);
begin
  TraceFull(SCnEnterProc + AProcName, ATag, CurrentLevel, cmtEnterProc);
  IncIndent(GetCurrentThreadId);
end;

procedure TCnDebugger.TraceFloat(Value: Extended; const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(SCnFloat + FloatToStr(Value))
  else
    TraceFmt('%s %s', [AMsg, FloatToStr(Value)]);
end;

procedure TCnDebugger.TraceFmt(const AFormat: string;
  Args: array of const);
begin
  TraceFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceFmtWithLevel(const AFormat: string;
  Args: array of const; ALevel: Integer);
begin
  TraceFull(FormatMsg(AFormat, Args), CurrentTag, ALevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceFmtWithTag(const AFormat: string;
  Args: array of const; const ATag: string);
begin
  TraceFull(FormatMsg(AFormat, Args), ATag, CurrentLevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceFmtWithType(const AFormat: string;
  Args: array of const; AType: TCnMsgType);
begin
  TraceFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, AType);
end;

procedure TCnDebugger.TraceFull(const AMsg, ATag: string; ALevel: Integer;
  AType: TCnMsgType; CPUPeriod: Int64 = 0);
{$IFNDEF NDEBUG}
var
  ThrdID: DWORD;
{$ENDIF}
begin
{$IFNDEF NDEBUG}
  if AMsg = '' then Exit;
  ThrdID := GetCurrentThreadID;
  InternalOutputMsg(AnsiString(AMsg), Length(AnsiString(AMsg)), AnsiString(ATag),
    ALevel, GetCurrentIndent(ThrdID), AType, ThrdID, CPUPeriod);
{$ENDIF}
end;

procedure TCnDebugger.TraceInteger(Value: Integer;
  const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(SCnInteger + IntToStr(Value))
  else
    TraceFmt('%s %d', [AMsg, Value]);
end;

procedure TCnDebugger.TraceChar(Value: Char; const AMsg: string);
begin
  if AMsg = '' then
    TraceFmt(SCnCharFmt, [Value, Ord(Value), Ord(Value)])
  else
    TraceFmt('%s ''%s''(%d/$%2.2x)', [AMsg, Value, Ord(Value), Ord(Value)]);
end;

procedure TCnDebugger.TraceDateTime(Value: TDateTime; const AMsg: string = '' );
begin
  if AMsg = '' then
    TraceMsg(SCnDateTime + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Value))
  else
    TraceMsg(AMsg + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Value));
end;

procedure TCnDebugger.TraceDateTimeFmt(Value: TDateTime; const AFmt: string; const AMsg: string = '' );
begin
  if AMsg = '' then
    TraceMsg(SCnDateTime + FormatDateTime(AFmt, Value))
  else
    TraceMsg(AMsg + FormatDateTime(AFmt, Value));
end;

procedure TCnDebugger.TracePointer(Value: Pointer; const AMsg: string = '');
begin
  if AMsg = '' then
    TraceFmt('%s $%p', [SCnPointer, Value])
  else
    TraceFmt('%s $%p', [AMsg, Value]);
end;

procedure TCnDebugger.TraceLeave(const AProcName, ATag: string);
begin
  DecIndent(GetCurrentThreadId);
  TraceFull(SCnLeaveProc + AProcName, ATag, CurrentLevel, cmtLeaveProc);
end;

procedure TCnDebugger.TraceMemDump(AMem: Pointer; Size: Integer);
{$IFNDEF NDEBUG}
var
  ThrdID: DWORD;
{$ENDIF}
begin
{$IFNDEF NDEBUG}
  ThrdID := GetCurrentThreadID;
  InternalOutputMsg(AnsiString(AMem), Size, AnsiString(CurrentTag), CurrentLevel, GetCurrentIndent(ThrdID),
    cmtMemoryDump, ThrdID, 0);
{$ENDIF}
end;

procedure TCnDebugger.TraceVirtualKey(AKey: Word);
begin
  TraceVirtualKeyWithTag(AKey, CurrentTag);
end;

procedure TCnDebugger.TraceVirtualKeyWithTag(AKey: Word; const ATag: string);
begin
  TraceFmtWithTag(SCnVirtualKeyFmt, [AKey, AKey, VirtualKeyToString(AKey)], ATag);
end;

procedure TCnDebugger.TraceMsg(const AMsg: string);
begin
  TraceFull(AMsg, CurrentTag, CurrentLevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceMsgWithLevel(const AMsg: string;
  ALevel: Integer);
begin
  TraceFull(AMsg, CurrentTag, ALevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceMsgWithLevelType(const AMsg: string;
  ALevel: Integer; AType: TCnMsgType);
begin
  TraceFull(AMsg, CurrentTag, ALevel, AType);
end;

procedure TCnDebugger.TraceMsgWithTag(const AMsg, ATag: string);
begin
  TraceFull(AMsg, ATag, CurrentLevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceMsgWithTagLevel(const AMsg, ATag: string;
  ALevel: Integer);
begin
  TraceFull(AMsg, ATag, ALevel, CurrentMsgType);
end;

procedure TCnDebugger.TraceMsgWithType(const AMsg: string;
  AType: TCnMsgType);
begin
  TraceFull(AMsg, CurrentTag, CurrentLevel, AType);
end;

procedure TCnDebugger.TraceMsgWithTypeTag(const AMsg: string;
  AType: TCnMsgType; const ATag: string);
begin
  TraceFull(AMsg, ATag, CurrentLevel, AType);
end;

procedure TCnDebugger.TraceObject(AObject: TObject);
begin
  TraceObjectWithTag(AObject, CurrentTag);
end;

procedure TCnDebugger.TraceObjectWithTag(AObject: TObject;
  const ATag: string);
{$IFNDEF NDEBUG}
var
  List: TStringList;
{$ENDIF}  
begin
{$IFNDEF NDEBUG}
  List := nil;
  try
    List := TStringList.Create;
    try
      AddObjectToStringList(AObject, List, 0);
    except
      List.Add(SCnObjException);
    end;
    TraceMsgWithType('Object: ' + IntToHex(Integer(AObject), 2) + SCnCRLF +
      List.Text, cmtObject);
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnDebugger.TracePoint(Point: TPoint; const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(SCnPoint + PointToString(Point))
  else
    TraceFmt('%s %s', [AMsg, PointToString(Point)]);
end;

procedure TCnDebugger.TraceRect(Rect: TRect; const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(SCnRect + RectToString(Rect))
  else
    TraceFmt('%s %s', [AMsg, RectToString(Rect)]);
end;

procedure TCnDebugger.TraceSeparator;
begin
  TraceFull('-', CurrentTag, CurrentLevel, cmtSeparator);
end;

procedure TCnDebugger.TraceStrings(Strings: TStrings; const AMsg: string);
begin
  if AMsg = '' then
    TraceMsg(Strings.Text)
  else
    TraceMsg(AMsg + SCnCRLF + Strings.Text);
end;

procedure TCnDebugger.TraceErrorFmt(const AFormat: string;
  Args: array of const);
begin
  TraceFull(FormatMsg(AFormat, Args), CurrentTag, CurrentLevel, cmtError);
end;

procedure TCnDebugger.TraceMsgError(const AMsg: string);
begin
  TraceFull(AMsg, CurrentTag, CurrentLevel, cmtError);
end;

procedure TCnDebugger.TraceMsgWarning(const AMsg: string);
begin
  TraceFull(AMsg, CurrentTag, CurrentLevel, cmtWarning);
end;

procedure TCnDebugger.TraceLastError;
var
  ErrNo: Integer;
  Buf: array[0..255] of Char;
begin
  ErrNo := GetLastError;
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrNo, $400, Buf, 255, nil);
  if Buf = '' then StrCopy(PChar(@Buf), PChar(SCnUnknownError));
  TraceErrorFmt(SCnLastErrorFmt, [ErrNo, Buf]);
end;

function TCnDebugger.GetDiscardedMessageCount: Integer;
begin
  Result := FMessageCount - FPostedMessageCount;
end;

procedure TCnDebugger.EvaluateObject(AObject: TObject);
begin
{$IFDEF SUPPORT_EVALUATE}
  EvaluatePointer(AObject);
{$ENDIF}
end;

procedure TCnDebugger.EvaluateObject(APointer: Pointer);
begin
{$IFDEF SUPPORT_EVALUATE}
  EvaluatePointer(APointer);
{$ENDIF}
end;

function TCnDebugger.VirtualKeyToString(AKey: Word): string;
begin
  case AKey of
    VK_LBUTTON:      Result := 'VK_LBUTTON';
    VK_RBUTTON:      Result := 'VK_RBUTTON';
    VK_CANCEL:       Result := 'VK_CANCEL';
    VK_MBUTTON:      Result := 'VK_MBUTTON';
    VK_BACK:         Result := 'VK_BACK';
    VK_TAB:          Result := 'VK_TAB';
    VK_CLEAR:        Result := 'VK_CLEAR';
    VK_RETURN:       Result := 'VK_RETURN';
    VK_SHIFT:        Result := 'VK_SHIFT';
    VK_CONTROL:      Result := 'VK_CONTROL';
    VK_MENU:         Result := 'VK_MENU';
    VK_PAUSE:        Result := 'VK_PAUSE';
    VK_CAPITAL:      Result := 'VK_CAPITAL';
    VK_KANA:         Result := 'VK_KANA/VK_HANGUL';
    VK_JUNJA:        Result := 'VK_JUNJA';
    VK_FINAL:        Result := 'VK_FINAL';
    VK_HANJA:        Result := 'VK_HANJA/VK_KANJI';
    VK_CONVERT:      Result := 'VK_CONVERT';
    VK_NONCONVERT:   Result := 'VK_NONCONVERT';
    VK_ACCEPT:       Result := 'VK_ACCEPT';
    VK_MODECHANGE:   Result := 'VK_MODECHANGE';
    VK_ESCAPE:       Result := 'VK_ESCAPE';
    VK_SPACE:        Result := 'VK_SPACE';
    VK_PRIOR:        Result := 'VK_PRIOR';
    VK_NEXT:         Result := 'VK_NEXT';
    VK_END:          Result := 'VK_END';
    VK_HOME:         Result := 'VK_HOME';
    VK_LEFT:         Result := 'VK_LEFT';
    VK_UP:           Result := 'VK_UP';
    VK_RIGHT:        Result := 'VK_RIGHT';
    VK_DOWN:         Result := 'VK_DOWN';
    VK_SELECT:       Result := 'VK_SELECT';
    VK_PRINT:        Result := 'VK_PRINT';
    VK_EXECUTE:      Result := 'VK_EXECUTE';
    VK_SNAPSHOT:     Result := 'VK_SNAPSHOT';
    VK_INSERT:       Result := 'VK_INSERT';
    VK_DELETE:       Result := 'VK_DELETE';
    VK_HELP:         Result := 'VK_HELP';
    Ord('0'):        Result := 'VK_0';
    Ord('1'):        Result := 'VK_1';
    Ord('2'):        Result := 'VK_2';
    Ord('3'):        Result := 'VK_3';
    Ord('4'):        Result := 'VK_4';
    Ord('5'):        Result := 'VK_5';
    Ord('6'):        Result := 'VK_6';
    Ord('7'):        Result := 'VK_7';
    Ord('8'):        Result := 'VK_8';
    Ord('9'):        Result := 'VK_9';
    Ord('A'):        Result := 'VK_A';
    Ord('B'):        Result := 'VK_B';
    Ord('C'):        Result := 'VK_C';
    Ord('D'):        Result := 'VK_D';
    Ord('E'):        Result := 'VK_E';
    Ord('F'):        Result := 'VK_F';
    Ord('G'):        Result := 'VK_G';
    Ord('H'):        Result := 'VK_H';
    Ord('I'):        Result := 'VK_I';
    Ord('J'):        Result := 'VK_J';
    Ord('K'):        Result := 'VK_K';
    Ord('L'):        Result := 'VK_L';
    Ord('M'):        Result := 'VK_M';
    Ord('N'):        Result := 'VK_N';
    Ord('O'):        Result := 'VK_O';
    Ord('P'):        Result := 'VK_P';
    Ord('Q'):        Result := 'VK_Q';
    Ord('R'):        Result := 'VK_R';
    Ord('S'):        Result := 'VK_S';
    Ord('T'):        Result := 'VK_T';
    Ord('U'):        Result := 'VK_U';
    Ord('V'):        Result := 'VK_V';
    Ord('W'):        Result := 'VK_W';
    Ord('X'):        Result := 'VK_X';
    Ord('Y'):        Result := 'VK_Y';
    Ord('Z'):        Result := 'VK_Z';
    VK_LWIN:         Result := 'VK_LWIN';
    VK_RWIN:         Result := 'VK_RWIN';
    VK_APPS:         Result := 'VK_APPS';
    VK_NUMPAD0:      Result := 'VK_NUMPAD0';
    VK_NUMPAD1:      Result := 'VK_NUMPAD1';
    VK_NUMPAD2:      Result := 'VK_NUMPAD2';
    VK_NUMPAD3:      Result := 'VK_NUMPAD3';
    VK_NUMPAD4:      Result := 'VK_NUMPAD4';
    VK_NUMPAD5:      Result := 'VK_NUMPAD5';
    VK_NUMPAD6:      Result := 'VK_NUMPAD6';
    VK_NUMPAD7:      Result := 'VK_NUMPAD7';
    VK_NUMPAD8:      Result := 'VK_NUMPAD8';
    VK_NUMPAD9:      Result := 'VK_NUMPAD9';
    VK_MULTIPLY:     Result := 'VK_MULTIPLY';
    VK_ADD:          Result := 'VK_ADD';
    VK_SEPARATOR:    Result := 'VK_SEPARATOR';
    VK_SUBTRACT:     Result := 'VK_SUBTRACT';
    VK_DECIMAL:      Result := 'VK_DECIMAL';
    VK_DIVIDE:       Result := 'VK_DIVIDE';
    VK_F1:           Result := 'VK_F1';
    VK_F2:           Result := 'VK_F2';
    VK_F3:           Result := 'VK_F3';
    VK_F4:           Result := 'VK_F4';
    VK_F5:           Result := 'VK_F5';
    VK_F6:           Result := 'VK_F6';
    VK_F7:           Result := 'VK_F7';
    VK_F8:           Result := 'VK_F8';
    VK_F9:           Result := 'VK_F9';
    VK_F10:          Result := 'VK_F10';
    VK_F11:          Result := 'VK_F11';
    VK_F12:          Result := 'VK_F12';
    VK_F13:          Result := 'VK_F13';
    VK_F14:          Result := 'VK_F14';
    VK_F15:          Result := 'VK_F15';
    VK_F16:          Result := 'VK_F16';
    VK_F17:          Result := 'VK_F17';
    VK_F18:          Result := 'VK_F18';
    VK_F19:          Result := 'VK_F19';
    VK_F20:          Result := 'VK_F20';
    VK_F21:          Result := 'VK_F21';
    VK_F22:          Result := 'VK_F22';
    VK_F23:          Result := 'VK_F23';
    VK_F24:          Result := 'VK_F24';
    VK_NUMLOCK:      Result := 'VK_NUMLOCK';
    VK_SCROLL:       Result := 'VK_SCROLL';
    VK_LSHIFT:       Result := 'VK_LSHIFT';
    VK_RSHIFT:       Result := 'VK_RSHIFT';
    VK_LCONTROL:     Result := 'VK_LCONTROL';
    VK_RCONTROL:     Result := 'VK_RCONTROL';
    VK_LMENU:        Result := 'VK_LMENU';
    VK_RMENU:        Result := 'VK_RMENU';

    166:             Result := 'VK_BROWSER_BACK';
    167:             Result := 'VK_BROWSER_FORWARD';
    168:             Result := 'VK_BROWSER_REFRESH';
    169:             Result := 'VK_BROWSER_STOP';
    170:             Result := 'VK_BROWSER_SEARCH';
    171:             Result := 'VK_BROWSER_FAVORITES';
    172:             Result := 'VK_BROWSER_HOME';
    173:             Result := 'VK_VOLUME_MUTE';
    174:             Result := 'VK_VOLUME_DOWN';
    175:             Result := 'VK_VOLUME_UP';
    176:             Result := 'VK_MEDIA_NEXT_TRACK';
    177:             Result := 'VK_MEDIA_PREV_TRACK';
    178:             Result := 'VK_MEDIA_STOP';
    179:             Result := 'VK_MEDIA_PLAY_PAUSE';
    180:             Result := 'VK_LAUNCH_MAIL';
    181:             Result := 'VK_LAUNCH_MEDIA_SELECT';
    182:             Result := 'VK_LAUNCH_APP1';
    183:             Result := 'VK_LAUNCH_APP2';

    186:             Result := 'VK_OEM_1';
    187:             Result := 'VK_OEM_PLUS';
    188:             Result := 'VK_OEM_COMMA';
    189:             Result := 'VK_OEM_MINUS';
    190:             Result := 'VK_OEM_PERIOD';
    191:             Result := 'VK_OEM_2';
    192:             Result := 'VK_OEM_3';
    219:             Result := 'VK_OEM_4';
    220:             Result := 'VK_OEM_5';
    221:             Result := 'VK_OEM_6';
    222:             Result := 'VK_OEM_7';
    223:             Result := 'VK_OEM_8';
    226:             Result := 'VK_OEM_102';
    231:             Result := 'VK_PACKET';

    VK_PROCESSKEY:   Result := 'VK_PROCESSKEY';
    VK_ATTN:         Result := 'VK_ATTN';
    VK_CRSEL:        Result := 'VK_CRSEL';
    VK_EXSEL:        Result := 'VK_EXSEL';
    VK_EREOF:        Result := 'VK_EREOF';
    VK_PLAY:         Result := 'VK_PLAY';
    VK_ZOOM:         Result := 'VK_ZOOM';
    VK_NONAME:       Result := 'VK_NONAME';
    VK_PA1:          Result := 'VK_PA1';
    VK_OEM_CLEAR:    Result := 'VK_OEM_CLEAR';
  else
    Result := 'VK_UNKNOWN';
  end;
end;

procedure TCnDebugger.SetDumpFileName(const Value: string);
var
  Mode: Word;
begin
  if FDumpFileName <> Value then
  begin
    FDumpFileName := Value;
    // Dump 时更新文件
    if FDumpToFile then
    begin
      if FDumpFile <> nil then
        FreeAndNil(FDumpFile);
      if FDumpFileName = '' then
        FDumpFileName := SCnDefaultDumpFileName;

      if FileExists(FDumpFileName) then
        Mode := fmOpenWrite
      else
        Mode := fmCreate;

      FDumpFile := TFileStream.Create(FDumpFileName,
        Mode or fmShareDenyWrite);
      FAfterFirstWrite := False; // 重新开另一文件，需要重新判断

      if FUseAppend then   // 追加则定位到结尾
        FDumpFile.Seek(0, soFromEnd)
      else
        FDumpFile.Seek(0, soFromBeginning); // 移动到开头
    end;
  end;
end;

procedure TCnDebugger.SetDumpToFile(const Value: Boolean);
var
  Mode: Word;
begin
  if FDumptoFile <> Value then
  begin
    FDumpToFile := Value;
    if FDumptoFile then
    begin
      if FDumpFileName = '' then
        FDumpFileName := SCnDefaultDumpFileName;

      try
        if FDumpFile <> nil then
          FreeAndNil(FDumpFile);

        if FileExists(FDumpFileName) then
          Mode := fmOpenWrite
        else
          Mode := fmCreate;

        FDumpFile := TFileStream.Create(FDumpFileName,
          Mode or fmShareDenyWrite);
        FAfterFirstWrite := False; // 重新开文件，需要重新判断

        if FUseAppend then // 追加则定位到结尾
          FDumpFile.Seek(0, soFromEnd)
        else
          FDumpFile.Seek(0, soFromBeginning); // 移动到开头
      except
        ;
      end;
    end
    else
    begin
      FreeAndNil(FDumpFile);
    end;
  end;
end;

{ TCnDebugChannel }

function TCnDebugChannel.CheckFilterChanged: Boolean;
begin
  Result := False;
end;

function TCnDebugChannel.CheckReady: Boolean;
begin
  Result := False;
end;

constructor TCnDebugChannel.Create(IsAutoFlush: Boolean);
begin
  Active := True;
  FAutoFlush := IsAutoFlush;
end;

procedure TCnDebugChannel.RefreshFilter(Filter: TCnDebugFilter);
begin
// Do Nothing
end;

procedure TCnDebugChannel.SendContent(var MsgDesc; Size: Integer);
begin
// Do Nothing
end;

procedure TCnDebugChannel.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TCnDebugChannel.SetAutoFlush(const Value: Boolean);
begin
  if FAutoFlush <> Value then
  begin
    FAutoFlush := Value;
    UpdateFlush;
  end;
end;

procedure TCnDebugChannel.StartDebugViewer;
begin
// Do nothing
end;

procedure TCnDebugChannel.UpdateFlush;
begin
// Do nothing
end;

{ TCnMapFileChannel }

function TCnMapFileChannel.CheckFilterChanged: Boolean;
var
  Header: PCnMapHeader;
begin
  Result := False;
  if FMapHeader <> nil then
  begin
    Header := FMapHeader;
    Result := Header^.Filter.NeedRefresh <> 0;
  end;
end;

function TCnMapFileChannel.CheckReady: Boolean;
begin
  Result := (FMap <> 0) and (FMapHeader <> nil) and (FQueueEvent <> 0);
  if not Result then
  begin
    FMap := OpenFileMapping(FILE_MAP_READ or FILE_MAP_WRITE, False, PChar(SCnDebugMapName));
    if FMap <> 0 then
    begin
      FMapHeader := MapViewOfFile(FMap, FILE_MAP_READ or FILE_MAP_WRITE, 0, 0, 0);
      if FMapHeader <> nil then
      begin
        FQueueEvent := OpenEvent(EVENT_MODIFY_STATE, False, PChar(SCnDebugQueueEventName));
        if (FQueueEvent <> 0) then
        begin
          UpdateFlush;
          Result := IsInitedFromHeader;
        end;
      end;
    end;
  end
  else // 区域都有效
    Result := PCnMapHeader(FMapHeader)^.MapEnabled = CnDebugMapEnabled;

  if not Result then
    DestroyHandles;
end;

constructor TCnMapFileChannel.Create(IsAutoFlush: Boolean = True);
begin
  inherited;
  UpdateFlush;
end;

destructor TCnMapFileChannel.Destroy;
begin
  DestroyHandles;
  inherited;
end;

procedure TCnMapFileChannel.DestroyHandles;
begin
  if FQueueFlush <> 0 then
  begin
    CloseHandle(FQueueFlush);
    FQueueFlush := 0;
  end;
  if FQueueEvent <> 0 then
  begin
    CloseHandle(FQueueEvent);
    FQueueEvent := 0;
  end;
  if FMapHeader <> nil then
  begin
    UnmapViewOfFile(FMapHeader);
    FMapHeader := nil;
  end;
  if FMap <> 0 then
  begin
    CloseHandle(FMap);
    FMap := 0;
  end;
end;

function TCnMapFileChannel.IsInitedFromHeader: Boolean;
var
  Header: PCnMapHeader;
begin
  Result := False;
  if (FMap <> 0) and (FMapHeader <> nil) then
  begin
    Header := FMapHeader;
    FMsgBase := Pointer(Header^.DataOffset + Integer(FMapHeader));
    FMapSize := Header^.MapSize;
    FQueueSize := FMapSize - Header^.DataOffset;
    Result := (Header^.MapEnabled = CnDebugMapEnabled) and
      CompareMem(@(Header^.MagicName), PAnsiChar(AnsiString(CnDebugMagicName)), CnDebugMagicLength);
  end;
end;

procedure TCnMapFileChannel.LoadQueuePtr;
var
  Header: PCnMapHeader;
begin
  if (FMap <> 0) and (FMapHeader <> nil) then
  begin
    Header := FMapHeader;
    FFront := Header^.QueueFront;
    FTail := Header^.QueueTail;
  end;
end;

procedure TCnMapFileChannel.RefreshFilter(Filter: TCnDebugFilter);
var
  Header: PCnMapHeader;
  TagArray: array[0..CnMaxTagLength] of Char;
begin
  if (Filter <> nil) and (FMap <> 0) and (FMapHeader <> nil) then
  begin
    Header := FMapHeader;
    FillChar(TagArray, CnMaxTagLength + 1, 0);
    CopyMemory(@TagArray, @(Header^.Filter.Tag), CnMaxTagLength);

    Filter.Enabled := Header^.Filter.Enabled <> 0;
    Filter.Level := Header^.Filter.Level;
    Filter.Tag := TagArray;
    Filter.MsgTypes := Header^.Filter.MsgTypes;
    Header^.Filter.NeedRefresh := 0;
  end;
end;

procedure TCnMapFileChannel.SaveQueuePtr(SaveFront: Boolean = False);
var
  Header: PCnMapHeader;
begin
  if (FMap <> 0) and (FMapHeader <> nil) then
  begin
    Header := FMapHeader;
    Header^.QueueTail := FTail;
    if SaveFront then
      Header^.QueueFront := FFront;
  end;
end;

procedure TCnMapFileChannel.SendContent(var MsgDesc; Size: Integer);
var
  Mutex: THandle;
  Res: DWORD;
  MsgLen, RestLen: Integer;
  IsFull: Boolean;
  MsgBuf : array[0..255] of Char;

  function BufferFull: Boolean;
  begin
    if FTail = FFront then      // 空队列
      Result := False
    else if FTail < FFront then // Tail 已经折返，Front 没有
      Result := FTail + Size < FFront
    // 都未折返，Tail 比 FFront 大
    else if FTail + Size < FQueueSize then // 新位置如不产生折返，则未满
      Result := False
    else if (FTail + Size) mod FQueueSize < FFront then // 新位置折返但不超过 Front
      Result := False
    else
      Result := True;
  end;

begin
  if Size > FQueueSize then Exit;
  // 从尾进，头由 Viewer 读出. Tail 一直前进，到尾折返
  // 写完数据后，才置增加的 Tail，Tail 指向下一个空位置
  IsFull := False;
  Mutex := OpenMutex(MUTEX_ALL_ACCESS, False, PChar(SCnDebugQueueMutexName));
  if Mutex <> 0 then
  begin
    Res := WaitForSingleObject(Mutex, CnDebugWaitingMutexTime);
    if (Res = WAIT_TIMEOUT) or (Res = WAIT_FAILED) then // 出错或对方不释放，没法子，撤
    begin
      ShowError('Mutex Obtained Error.');
      CloseHandle(Mutex);
      Exit;
    end;
  end
  else
  begin
    ShowError('Mutex Opened Error.');
    DestroyHandles;
    Exit;  // 无 Mutex 便不写
  end;

  try
    LoadQueuePtr;
    if BufferFull then
    begin
      // 锁定并删队列头元素，直到有足够的空间来容纳本 Size 为止
      IsFull := True;
      repeat
        MsgLen := PInteger(Integer(FMsgBase) + FFront)^;
        FFront := (FFront + MsgLen) mod FQueueSize;
      until not BufferFull;
      // 删完毕，进入写步骤 -- 以上可以考虑改成直接清空队列
    end;

    // 先写数据再改指针
    if FTail + Size < FQueueSize then
      CopyMemory(Pointer(Integer(FMsgBase) + FTail), @MsgDesc, Size)
    else
    begin
      RestLen := FQueueSize - FTail;
      if RestLen < SizeOf(Integer) then // 剩余空间不足以容纳信息头的 Length 字段
        CopyMemory(Pointer(Integer(FMsgBase) + FTail), @MsgDesc, SizeOf(Integer))
        // 强行复制，要求队列超出QueueSize外的尾部至少有 SizeOf(Integer)的空余缓冲
        // 可不如此做，但会增加 Viewer 读取长度时的回溯困难
      else
        CopyMemory(Pointer(Integer(FMsgBase) + FTail), @MsgDesc, RestLen);

      CopyMemory(FMsgBase, Pointer(Integer(@MsgDesc) + RestLen), Size - RestLen);
    end;

    Inc(FTail, Size);
    if FTail >= FQueueSize then
      FTail := FTail mod FQueueSize;

    SaveQueuePtr(IsFull);
    if Mutex <> 0 then
    begin
      ReleaseMutex(Mutex);
      CloseHandle(Mutex);
    end;
    SetEvent(FQueueEvent);
    if AutoFlush and (FQueueFlush <> 0) then
    begin
      Res := WaitForSingleObject(FQueueFlush, CnDebugFlushEventTime);
      if Res = WAIT_FAILED then
      begin
        Res := GetLastError;
        // 处理出错情况, 5 是拒绝访问。
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, Res,
          LANG_NEUTRAL or (SUBLANG_DEFAULT shl 10), // Default language
          PChar(@MsgBuf),
          Sizeof(MsgBuf)-1,
          nil);
        ShowError(MsgBuf);
      end;
    end;

  except
    DestroyHandles;
  end;
end;

procedure TCnMapFileChannel.StartDebugViewer;
const
  SCnDebugViewerExeName = 'CnDebugViewer.exe -a ';
var
  hStarting: THandle;
  Reg: TRegistry;
  S: string;
  ViewerExe: AnsiString;
begin
  ViewerExe := '';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\CnPack\CnDebug', False) then
      S := Reg.ReadString('CnDebugViewer');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  
  // 加上调用参数
  if S <> '' then
    ViewerExe := AnsiString(S + ' -a ')
  else
    ViewerExe := SCnDebugViewerExeName;
  
  hStarting := CreateEvent(nil, False, False, PChar(SCnDebugStartEventName));
  if 31 < WinExec(PAnsiChar(ViewerExe + AnsiString(IntToStr(GetCurrentProcessId))),
    SW_SHOW) then // 成功创建，等待
  begin
    if hStarting <> 0 then
    begin
      WaitForSingleObject(hStarting, CnDebugStartingEventTime);
      CloseHandle(hStarting);
    end;
  end;
end;

procedure TCnMapFileChannel.UpdateFlush;
begin
  if AutoFlush then
  begin
    FQueueFlush := CreateEvent(nil, False, False, PChar(SCnDebugFlushEventName));
  end
  else if FQueueFlush <> 0 then
  begin
    CloseHandle(FQueueFlush);
    FQueueFlush := 0;
  end;
end;

{$IFDEF USE_JCL}
procedure ExceptNotifyProc(ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
var
  Strings: TStrings;
begin
  if not FCnDebugger.Active or not FCnDebugger.ExceptTracking then Exit;

  EnterCriticalSection(FCSExcept);
  try
    if FCnDebugger.FExceptFilter.IndexOf(ExceptObj.ClassName) >= 0 then Exit;
  finally
    LeaveCriticalSection(FCSExcept);
  end;

  if OSException then
    FCnDebugger.TraceMsgWithType('OS Exceptions', cmtError)
  else
    with Exception(ExceptObj) do
      FCnDebugger.TraceMsgWithType(ClassName + ': ' + Message, cmtError);

  Strings := TStringList.Create;
  try
    JclLastExceptStackListToStrings(Strings, True, True, True);
    FCnDebugger.TraceMsgWithType('Exception call stack:' + SCnCRLF +
      Strings.Text, cmtException);
  finally
    Strings.Free;
  end;
end;
{$ENDIF}

initialization
{$IFNDEF NDEBUG}
  FCnDebugger := TCnDebugger.Create;
  FixCallingCPUPeriod;
  {$IFDEF USE_JCL}
  InitializeCriticalSection(FCSExcept);
  JclHookExceptions;
  JclAddExceptNotifier(ExceptNotifyProc);
  JclStartExceptionTracking;
  {$ENDIF}
{$ELSE}
  CnDebugChannelClass := nil; // NDEBUG 环境下不创建 Channel
{$ENDIF}

finalization
{$IFDEF USE_JCL}
  DeleteCriticalSection(FCSExcept);
{$ENDIF}
  FreeAndNil(FCnDebugger);

end.

