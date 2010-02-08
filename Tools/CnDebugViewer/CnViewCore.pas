{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnViewCore;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：核心结构与字符串定义单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2008.01.18
*               Sesame: 增加保存窗口上次位置的属性
*           2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, Windows, Forms, TLHelp32, OmniXML, OmniXMLPersistent,
  CnLangMgr, CnDebugIntf;

const
  CnMapSize = 65536;
  CnHeadSize = 64;
  CnProtectSize = 4;

  CnWaitEventTime = 100;
  CnWaitMutexTime = 100;
  CnStartRetryCount = 20;

  SCnViewerMutexName = 'CnViewerMutexName';
  SCnDefDateTimeFmt = 'hh:nn:ss.zzz';
  SCnOptionFileName = 'CnDVOptions.xml';

  csLangDir = 'Lang\';
  csHelpDir = 'Help\';
  SCnDbgHelpIniFile = 'Help.ini';
  SCnDbgHelpIniSecion = 'CnDebugger';
  SCnDbgHelpIniTopic = 'CnDebugViewer';

  CnInvalidSlot = -1;
  CnInvalidLine = -1;
  CnInvalidFileProcId = $FFFFFFFF;

  DbWinBufferSize = 4096;
  SDbWinBufferReady = 'DBWIN_BUFFER_READY';
  SDbWinDataReady = 'DBWIN_DATA_READY';
  SDbWinBuffer = 'DBWIN_BUFFER';

type
  TCnViewerOptions = class(TPersistent)
  private
    FDateTimeFormat: string;
    FSearchDownCount: Integer;
    FEnableFilter: Boolean;
    FFilterTypes: TCnMsgTypes;
    FFilterLevel: Integer;
    FFilterTag: string;
    FMsgColumnWidth: Integer;
    FIgnoreODString: Boolean;
    FShowTrayIcon: Boolean;
    FMinToTrayIcon: Boolean;
    FMainShortCut: TShortCut;
    FCloseToTrayIcon: Boolean;
    FStartMin: Boolean;
    FAutoScroll: Boolean;
    FSaveFormPosition: Boolean;
    FTop, FLeft, FHeight, FWidth, FWinState: Integer;
    procedure SetTop(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetHeight(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property IgnoreODString: Boolean read FIgnoreODString write FIgnoreODString;
    property EnableFilter: Boolean read FEnableFilter write FEnableFilter;
    property FilterLevel: Integer read FFilterLevel write FFilterLevel;
    property FilterTag: string read FFilterTag write FFilterTag;
    property FilterTypes: TCnMsgTypes read FFilterTypes write FFilterTypes;

    property SearchDownCount: Integer read FSearchDownCount write FSearchDownCount;
    property DateTimeFormat: string read FDateTimeFormat write FDateTimeFormat;
    property MsgColumnWidth: Integer read FMsgColumnWidth write FMsgColumnWidth;
    
    property ShowTrayIcon: Boolean read FShowTrayIcon write FShowTrayIcon;
    {* 是否显示系统托盘图标，如为 False，则下面的最小化到系统托盘的属性无效 }
    property MinToTrayIcon: Boolean read FMinToTrayIcon write FMinToTrayIcon;   
    {* 最小化时是否到系统托盘，也即不显示任务栏窗口 }
    property MainShortCut: TShortCut read FMainShortCut write FMainShortCut;
    {* 显示主窗体的全局快捷键 }
    property CloseToTrayIcon: Boolean read FCloseToTrayIcon write FCloseToTrayIcon;
    {* 关闭时是否最小化到系统托盘，不关闭，也不显示任务栏窗口 }
    property StartMin: Boolean read FStartMin write FStartMin;
    {* 启动时是否最小化}
    property AutoScroll: Boolean read FAutoScroll write FAutoScroll;
    {* 接受消息时是否自动向下滚动}
    property SaveFormPosition: Boolean read FSaveFormPosition write FSaveFormPosition;
    {* 是否保存窗口上次退出时的状态}      
    property Top: Integer read FTop write SetTop;
    {* 窗口顶部起始位置}
    property Left: Integer read FLeft write SetLeft;
    {* 窗口左边起始位置}
    property Height: Integer read FHeight write SetHeight;
    {* 窗口高度}
    property Width: Integer read FWidth write SetWidth;
    {* 窗口宽度}  
    property WinState: Integer read FWinState write FWinState;
    {* 窗口状态}
  end;

var
  HMap:   THandle = 0;
  HMutex: THandle = 0;
  HEvent: THandle = 0;
  HFlush: THandle = 0;
  HViewerMutex: THandle = 0;
  PHeader: PCnMapHeader;
  PBase: Pointer;

  SysDebugReady: Boolean = False;
  SysDebugExists: Boolean = False;

  SysDbgSa: TSecurityAttributes;
  SysDbgSd: TSecurityDescriptor;
  HSysBufferReady: THandle = 0;
  HSysDataReady: THandle = 0;
  HSysBuffer: THandle = 0;
  PSysDbgBase: Pointer;

  CSMsgStore: TRTLCriticalSection;

  CPUClock: Extended; // 计算而得的 CPU 主频，以 MHZ 为单位
  CnViewerOptions: TCnViewerOptions = nil;

// ==== Start of 'Constant' String for Translation

  SCnNoneProcName: string = '[未知程序]';
  SCnHintMsgTree: string = '调试信息显示区';

  SCnCPUSpeedFmt: string = 'CPU 估算频率：%f MHz';
  SCnTreeColumn0: string = '#';
  SCnTreeColumn1: string = '输出信息';
  SCnTreeColumn2: string = '类型';
  SCnTreeColumn3: string = 'Level';
  SCnTreeColumn4: string = 'Thread';
  SCnTreeColumn5: string = 'Tag';
  SCnTreeColumn6: string = '时刻';

  SCnMsgTypeNone:          string = '*';
  SCnMsgTypeInformation:   string = '信息';
  SCnMsgTypeWarning:       string = '警告';
  SCnMsgTypeError:         string = '错误';
  SCnMsgTypeSeparator:     string = '分隔';
  SCnMsgTypeEnterProc:     string = '进入';
  SCnMsgTypeLeaveProc:     string = '退出';
  SCnMsgTypeTimeMarkStart: string = '计时';
  SCnMsgTypeTimeMarkStop:  string = '计时';
  SCnMsgTypeMemoryDump:    string = '内存';
  SCnMsgTypeException:     string = '异常';
  SCnMsgTypeObject:        string = '对象';
  SCnMsgTypeComponent:     string = '组件';
  SCnMsgTypeCustom:        string = '自定义';
  SCnMsgTypeSystem:        string = '系统';

  SCnMsgDescriptionFmt: string =
    '序号: %-5d    Level: %-1d    ThreadID: $%-8x    ProcessID: $%-8x   Tag: %-8s   时间戳: %s' +
    #13#10 + '%s';
  SCnTimeDescriptionFmt: string =
    '序号: %-5d    累计次数: %8d    Tag: %-8s    总耗时: %f 微秒 (%s)';

  SCnThreadRunning: string = '正在运行...';
  SCnThreadPaused: string = '已暂停';
  SCnThreadStopped: string = '已停止';

  SCnErrorCaption: string = '出错信息';
  SCnInfoCaption: string = '提示';
  SCnNotFound: string = '未找到字符串';
  SCnStopFirst: string = '读取信息期间不支持文件的载入，是否先停止信息的读取？';
  SCnDebuggerExists: string = '提示: 系统中已存在另一调试器。';
  SCnBookmarkFull: string = '已达到书签最大数目，无法再定义书签';
  SCnBookmarkNOTExist: string = '此书签不可见，可能已被过滤掉';
  SCnRegisterHotKeyError: string = '注册全局热键错误。';

  SCnBookmark: string = '书签 &%d，第 %d 行';
  SCnNoHelpofThisLang: string = 'Sorry. No HELP in this Language.';

  SCnCSVFormatHeader: string = '序号,Level,类型,ThreadID,ProcessID,Tag,时间戳,内容';

  SCnHTMFormatStyle: string =
    '.tabletext   { font-family: 宋体; font-size: 9pt; text-align: left; line-height: 13pt;' + #13#10 +
                   'color: #000000; background-color: #FFFFF8 }' + #13#10 +
    '.tablehead   { font-family: 宋体; font-size: 9pt; text-align: center; line-height: 13pt;' + #13#10 +
                   'color: #0000FF; background-color: #DDEEFF }' + #13#10;

  SCnHTMFormatCharset: string = 'gb2312';

  SCnHTMFormatHeader: string =
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + #13#10 +
    '<html>' + #13#10 +
    '<head>' + #13#10 +
    '<style>' + #13#10 +
    '<!--' + #13#10 + '%s' +
    '-->' + #13#10 +
    '</style>' + #13#10 +
    '<title>%s</title>' + #13#10 +
    '<meta http-equiv="Content-Type" content="text/html; charset=%s">' + #13#10 +
    '<link rel="stylesheet" href="../css/style.css" type="text/css">' + #13#10 +
    '</head>' + #13#10 +
    '<table width="100%%" cellspacing="1" cellpadding="2" bgcolor="#CCCCFF"' + #13#10 +
    'bordercolor="#CCCCFF" bordercolorlight="#FFFFFF" bordercolordark="#6666FF" valign="top">';

  SCnHTMFormatTableHead: string =
    '<tr>' + #13#10 +
      '<td width="24pt" class="tablehead" valign="top">序号</td>' + #13#10 +
      '<td width="9pt" class="tablehead" valign="top">Level</td>' + #13#10 +
      '<td width="28pt" class="tablehead" valign="top">类型</td>' + #13#10 +
      '<td width="32pt" class="tablehead" valign="top">线程</td>' + #13#10 +
      '<td width="32pt" class="tablehead" valign="top">进程</td>' + #13#10 +
      '<td width="28pt" class="tablehead" valign="top">Tag</td>' + #13#10 +
      '<td width="60pt" class="tablehead" valign="top">时间戳</td>' + #13#10 +
      '<td class="tablehead">内容</td>' + #13#10 +
    '</tr>';

  SCnHTMFormatLine: string = 
    '<tr>' + #13#10 +
      '<td width="24pt" class="tabletext" valign="top">%d</td>' + #13#10 +
      '<td width="9pt" class="tabletext" valign="top">%d</td>' + #13#10 +
      '<td width="28pt" class="tabletext" valign="top">%s</td>' + #13#10 +
      '<td width="32pt" class="tabletext" valign="top">$%x</td>' + #13#10 +
      '<td width="32pt" class="tabletext" valign="top">$%x</td>' + #13#10 +
      '<td width="28pt" class="tabletext" valign="top">%s</td>' + #13#10 +
      '<td width="60pt" class="tabletext" valign="top">%s</td>' + #13#10 +
      '<td class="tabletext">%s</td>' + #13#10 +
    '</tr>';

  SCnHTMFormatEnd: string = '</table></body></html>';

  SCnDebugViewerAboutCaption: string = '关于';
  SCnDebugViewerAbout: string =
    'CnDebugViewer 调试信息查看工具 1.4' + #13#10 +
    '' + #13#10 +
    '该工具用来查看 CnDebug 单元输出的调试信息。' + #13#10 +
    '' + #13#10 +
    '软件作者 刘啸 (LiuXiao) liuxiao@cnpack.org' + #13#10 +
    '版权所有 (C) 2001-2010 CnPack 开发组';

// ==== End of 'Constant' String for Translation

const
  SCnTreeColumnArray: array[0..6] of PString = (@SCnTreeColumn0,
    @SCnTreeColumn1, @SCnTreeColumn2, @SCnTreeColumn3, @SCnTreeColumn4,
    @SCnTreeColumn5, @SCnTreeColumn6);

  SCnMsgTypeDescArray: array[TCnMsgType] of PString = (
    @SCnMsgTypeInformation, @SCnMsgTypeWarning, @SCnMsgTypeError,
    @SCnMsgTypeSeparator, @SCnMsgTypeEnterProc, @SCnMsgTypeLeaveProc,
    @SCnMsgTypeTimeMarkStart, @SCnMsgTypeTimeMarkStop, @SCnMsgTypeMemoryDump,
    @SCnMsgTypeException, @SCnMsgTypeObject, @SCnMsgTypeComponent,
    @SCnMsgTypeCustom, @SCnMsgTypeSystem);

  SCnHotKeyId = 1;
  
procedure InitializeCore;

procedure FinalizeCore;

procedure InitSysDebug;

procedure CalcCPUSpeed;

function CheckRunning: Boolean;

procedure SetAnotherViewer;

procedure PostStartEvent;

function GetProcNameFromProcessID(ProcessID: DWORD): string;

procedure LoadOptions(const FileName: string);

procedure SaveOptions(const FileName: string);

procedure UpdateFilterToMap;

procedure ErrorDlg(const AText: string);

function QueryDlg(Mess: string; DefaultNo: Boolean = False;
  Caption: string = ''): Boolean;

procedure TranslateStrings;

implementation

function GetCPUPeriod: Int64; assembler;
asm
  DB 0FH;
  DB 031H;
end;

procedure InitializeCore;
begin
  HEvent := CreateEvent(nil, False, False, SCnDebugQueueEventName);
  HMutex := CreateMutex(nil, False, SCnDebugQueueMutexName);
  HMap := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0,
    CnMapSize + CnProtectSize, SCnDebugMapName);

  if HMap <> 0 then
  begin
    PBase := MapViewOfFile(HMap, FILE_MAP_WRITE or FILE_MAP_READ, 0, 0, 0);
    if PBase <> nil then
    begin
      PHeader := PBase;
      PHeader^.MapSize := CnMapSize;
      PHeader^.DataOffset := CnHeadSize;
      PHeader^.QueueFront := 0;
      PHeader^.QueueTail := 0;
      PHeader^.MapEnabled := CnDebugMapEnabled;
      StrCopy(Pointer(PHeader), CnDebugMagicName);
    end;
  end;

  InitializeCriticalSection(CSMsgStore);
  if not CnViewerOptions.IgnoreODString then
    InitSysDebug;
end;

procedure InitSysDebug;
begin
  if not InitializeSecurityDescriptor(@SysDbgSd, SECURITY_DESCRIPTOR_REVISION) then
    Exit;

  if not SetSecurityDescriptorDacl(@SysDbgSd, True, nil, False) then
    Exit;

  SysDbgSa.nLength := sizeof(TSecurityAttributes);
  SysDbgSa.bInheritHandle := True;
  SysDbgSa.lpSecurityDescriptor := @SysDbgSd;

  HSysBufferReady := CreateEvent(@SysDbgSa, False, False, SDbWinBufferReady);
  if HSysBufferReady = 0 then
    Exit;

  if GetLastError() = ERROR_ALREADY_EXISTS then
  begin
    SysDebugExists := True;
    Exit;
  end;

  HSysDataReady := CreateEvent(@SysDbgSa, False, False, SDbWinDataReady);
  if HSysDataReady = 0 then
    Exit;

  HSysBuffer := CreateFileMapping(INVALID_HANDLE_VALUE, @SysDbgSa, PAGE_READWRITE,
    0, DbWinBufferSize, SDbWinBuffer);
  if HSysBuffer <> 0 then
  begin
    PSysDbgBase := MapViewOfFile(HSysBuffer, FILE_MAP_READ, 0, 0, DbWinBufferSize);
    if PSysDbgBase <> nil then
      SysDebugReady := True;
  end;
end;

procedure FinalizeCore;
begin
  if HViewerMutex <> 0 then
  begin
    CloseHandle(HViewerMutex);
    HViewerMutex := 0;
  end;
  if PBase <> nil then
  begin
    PHeader := PBase;
    PHeader^.MapEnabled := 0;
    // 写入非正常值，让下次 CnDebug 单元停止输出
    UnmapViewOfFile(PBase);
    PBase := nil;
  end;
  if HMap <> 0 then
  begin
    CloseHandle(HMap);
    HMap := 0;
  end;
  if HEvent <> 0 then
  begin
    CloseHandle(HEvent);
    HEvent := 0;
  end;
  if HFlush <> 0 then
  begin
    CloseHandle(HFlush);
    HFlush := 0;
  end;
  if HMutex <> 0 then
  begin
    CloseHandle(HMutex);
    HMutex := 0;
  end;

  DeleteCriticalSection(CSMsgStore);

  if PSysDbgBase <> nil then
  begin
    UnmapViewOfFile(PSysDbgBase);
    PSysDbgBase := nil;
  end;
  if HSysBuffer <> 0 then
  begin
    CloseHandle(HSysBuffer);
    HSysBuffer := 0;
  end;
  if HSysDataReady <> 0 then
  begin
    CloseHandle(HSysDataReady);
    HSysDataReady := 0;
  end;
  if HSysBufferReady <> 0 then
  begin
    CloseHandle(HSysBufferReady);
    HSysBufferReady := 0;
  end;
end;

procedure CalcCPUSpeed;
var
  T: DWORD;
  A, B: Int64;
begin
  T := GetTickCount;
  while T = GetTickCount do;{wait for tickchange}
  A := GetCPUPeriod;
  while GetTickCount < (T + 501) do;
  B := GetCPUPeriod;
  CPUClock := 2e-6 * (B - A);{MHz}
end;

function CheckRunning: Boolean;
begin
  HViewerMutex := CreateMutex(nil, False, PChar(SCnViewerMutexName));
  Result := ERROR_ALREADY_EXISTS = GetLastError;
  if Result and FindCmdLineSwitch('A', ['-'], True) then
    PostStartEvent;
end;

procedure SetAnotherViewer;
var
  HViewer: HWND;
begin
  HViewer := FindWindow('TCnMainViewer', nil);
  if HViewer <> 0 then
    SetForegroundWindow(HViewer);
end;

procedure PostStartEvent;
var
  HStartEvent: THandle;
begin
  HStartEvent := OpenEvent(EVENT_MODIFY_STATE, False, PChar(SCnDebugStartEventName));
  if HStartEvent <> 0 then
  begin
    SetEvent(HStartEvent);
    CloseHandle(HStartEvent);
  end;
end;

function GetProcNameFromProcessID(ProcessID: DWORD): string;
var
  HSnap: THandle;
  Pe: TProcessEntry32;
  Next: BOOL;
begin
  Result := '';
  HSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  Pe.dwSize := SizeOf(Pe);
  Next := Process32First(HSnap, Pe);
  while (Next) do
  begin
    if Pe.th32ProcessID = ProcessID then
    begin
      Result := Pe.szExeFile;
      Break;
    end;
    Next := Process32Next(HSnap, Pe);
  end;
  CloseHandle(HSnap);
end;

procedure LoadOptions(const FileName: string);
begin
  if FileExists(FileName) then
    TOmniXMLReader.LoadFromFile(CnViewerOptions, FileName);
end;

procedure SaveOptions(const FileName: string);
begin
  TOmniXMLWriter.SaveToFile(CnViewerOptions, FileName, pfAuto, ofIndent);
end;

procedure UpdateFilterToMap;
var
  Len: Integer;
begin
  if (HMap <> 0) and (PHeader <> nil) then
  begin
    if CnViewerOptions.EnableFilter then
      PHeader^.Filter.Enabled := 1
    else
      PHeader^.Filter.Enabled := 0;
    PHeader^.Filter.Level := CnViewerOptions.FFilterLevel;

    FillChar(PHeader^.Filter.Tag, CnMaxTagLength, 0);
    Len := Length(CnViewerOptions.FFilterTag);
    if Len > CnMaxTagLength then Len := CnMaxTagLength;
    CopyMemory(@(PHeader^.Filter.Tag), PChar(CnViewerOptions.FilterTag), Len);

    PHeader^.Filter.MsgTypes := CnViewerOptions.FilterTypes;
    PHeader^.Filter.NeedRefresh := 1;
  end;
end;

procedure ErrorDlg(const AText: string);
begin
  MessageBox(Application.Handle, PChar(AText), PChar(SCnErrorCaption),
    MB_OK or MB_ICONERROR);
end;

function QueryDlg(Mess: string; DefaultNo: Boolean; Caption: string): Boolean;
const
  Defaults: array[Boolean] of DWORD = (0, MB_DEFBUTTON2);
begin
  if Caption = '' then
    Caption := SCnInfoCaption;
  Result := Application.MessageBox(PChar(Mess), PChar(Caption),
    MB_YESNO + MB_ICONQUESTION + Defaults[DefaultNo]) = IDYES;
end;

procedure TranslateStrings;
begin
  TranslateStr(SCnNoneProcName, 'SCnNoneProcName');
  TranslateStr(SCnHintMsgTree, 'SCnHintMsgTree');

  TranslateStr(SCnCPUSpeedFmt, 'SCnCPUSpeedFmt');
  TranslateStr(SCnTreeColumn0, 'SCnTreeColumn0');
  TranslateStr(SCnTreeColumn1, 'SCnTreeColumn1');
  TranslateStr(SCnTreeColumn2, 'SCnTreeColumn2');
  TranslateStr(SCnTreeColumn3, 'SCnTreeColumn3');
  TranslateStr(SCnTreeColumn4, 'SCnTreeColumn4');
  TranslateStr(SCnTreeColumn5, 'SCnTreeColumn5');
  TranslateStr(SCnTreeColumn6, 'SCnTreeColumn6');

  TranslateStr(SCnMsgTypeNone, 'SCnMsgTypeNone');
  TranslateStr(SCnMsgTypeInformation, 'SCnMsgTypeInformation');
  TranslateStr(SCnMsgTypeWarning, 'SCnMsgTypeWarning');
  TranslateStr(SCnMsgTypeError, 'SCnMsgTypeError');
  TranslateStr(SCnMsgTypeSeparator, 'SCnMsgTypeSeparator');
  TranslateStr(SCnMsgTypeEnterProc, 'SCnMsgTypeEnterProc');
  TranslateStr(SCnMsgTypeLeaveProc, 'SCnMsgTypeLeaveProc');
  TranslateStr(SCnMsgTypeTimeMarkStart, 'SCnMsgTypeTimeMarkStart');
  TranslateStr(SCnMsgTypeTimeMarkStop, 'SCnMsgTypeTimeMarkStop');
  TranslateStr(SCnMsgTypeMemoryDump, 'SCnMsgTypeMemoryDump');
  TranslateStr(SCnMsgTypeException, 'SCnMsgTypeException');
  TranslateStr(SCnMsgTypeObject, 'SCnMsgTypeObject');
  TranslateStr(SCnMsgTypeComponent, 'SCnMsgTypeComponent');
  TranslateStr(SCnMsgTypeCustom, 'SCnMsgTypeCustom');
  TranslateStr(SCnMsgTypeSystem, 'SCnMsgTypeSystem');

  TranslateStr(SCnMsgDescriptionFmt, 'SCnMsgDescriptionFmt');
  TranslateStr(SCnTimeDescriptionFmt, 'SCnTimeDescriptionFmt');

  TranslateStr(SCnThreadRunning, 'SCnThreadRunning');
  TranslateStr(SCnThreadPaused, 'SCnThreadPaused');
  TranslateStr(SCnThreadStopped, 'SCnThreadStopped');

  TranslateStr(SCnErrorCaption, 'SCnErrorCaption');
  TranslateStr(SCnInfoCaption, 'SCnInfoCaption');
  TranslateStr(SCnNotFound, 'SCnNotFound');
  TranslateStr(SCnStopFirst, 'SCnStopFirst');
  TranslateStr(SCnDebuggerExists, 'SCnDebuggerExists');

  TranslateStr(SCnBookmarkFull, 'SCnBookmarkFull');
  TranslateStr(SCnBookmark, 'SCnBookmark');
  TranslateStr(SCnBookmarkNOTExist, 'SCnBookmarkNOTExist');

  TranslateStr(SCnCSVFormatHeader, 'SCnCSVFormatHeader');
  TranslateStr(SCnHTMFormatStyle, 'SCnHTMFormatStyle');
  TranslateStr(SCnHTMFormatCharset, 'SCnHTMFormatCharset');
  TranslateStr(SCnHTMFormatTableHead, 'SCnHTMFormatTableHead');

  TranslateStr(SCnDebugViewerAboutCaption, 'SCnDebugViewerAboutCaption');
  TranslateStr(SCnDebugViewerAbout, 'SCnDebugViewerAbout');
end;

{ TCnViewerOptions }

constructor TCnViewerOptions.Create;
begin
  inherited;
  FFilterLevel := 3;
  FSearchDownCount := 7;
  FDateTimeFormat := SCnDefDateTimeFmt;
  FIgnoreODString := True;
  FMainShortCut := 49238; //Ctrl + Alt + V
  FShowTrayIcon := True;
  FMinToTrayIcon := True;
  FSaveFormPosition := True;
  FTop := 0;
  FLeft := 0;
  FHeight := Screen.Height - 25;
  FWidth := Screen.Width;
  FWinState := 0;
end;

destructor TCnViewerOptions.Destroy;
begin

  inherited;
end;

procedure TCnViewerOptions.SetTop(const Value: Integer);
begin
  if (Value >= 0) and (Value <> FTop) then
    FTop := Value;
end;

procedure TCnViewerOptions.SetLeft(const Value: Integer);
begin
  if (Value >= 0) and (Value <> FLeft) then
  FLeft := Value;
end;

procedure TCnViewerOptions.SetWidth(const Value: Integer);
begin
  if (Value > 0) and (Value <> FWidth) then
    FWidth := Value;
end;

procedure TCnViewerOptions.SetHeight(const Value: Integer);
begin
  if (Value > 0) and (Value <> FHeight) then
    FHeight := Value;
end;

initialization
  CalcCPUSpeed;
  CnViewerOptions := TCnViewerOptions.Create;

finalization
  FreeAndNil(CnViewerOptions);
  FinalizeCore;

end.
