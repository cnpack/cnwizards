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

unit CnDebugIntf;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：CnDebug 接口单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2008.07.16
*               调整声明以区别于宽字符的支持
*           2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, Windows;

const
  CnDefLevel = 3;
  CnMaxTagLength = 8; // 不可改变
  CnMaxMsgLength = 4096;
  CnDebugMagicLength = 8;
  CnDebugMapEnabled = $7F3D92E0; // 随便定义的一个值表示 MapEnable
{$IFDEF UNICODE}
  CnDebugMagicName: AnsiString = 'CNDEBUG';
{$ELSE}
  CnDebugMagicName = 'CNDEBUG';
{$ENDIF}

  SCnDebugPrefix = 'Global\';

var
  SCnDebugMapName: string = SCnDebugPrefix + 'CnDebugMap';
  SCnDebugQueueEventName: string = SCnDebugPrefix + 'CnDebugQueueEvent';
  SCnDebugQueueMutexName: string = SCnDebugPrefix + 'CnDebugQueueMutex';
  SCnDebugStartEventName: string = SCnDebugPrefix + 'CnDebugStartEvent';
  SCnDebugFlushEventName: string = SCnDebugPrefix + 'CnDebugFlushEvent';

type
  // ===================== 以下结构定义需要和 Viewer 共享 ======================

  // 输出的信息类型
  TCnMsgType = (cmtInformation, cmtWarning, cmtError, cmtSeparator, cmtEnterProc,
    cmtLeaveProc, cmtTimeMarkStart, cmtTimeMarkStop, cmtMemoryDump, cmtException,
    cmtObject, cmtComponent, cmtCustom, cmtSystem, cmtUDPMsg, cmtWatch,
    cmtClearWatch);
  TCnMsgTypes = set of TCnMsgType;

  // 时间戳格式类型
  TCnTimeStampType = (ttNone, ttDateTime, ttTickCount, ttCPUPeriod);

  {$NODEFINE TCnMsgAnnex}
  TCnMsgAnnex = packed record
  {* 放入数据区的每条信息的头描述结构 }
    Level:     Integer;                            // 自定义 Level 数，供用户过滤用
    Indent:    Integer;                            // 缩进数目，由 Enter 和 Leave 控制
    ProcessId: Cardinal;                           // 调用者的进程 ID
    ThreadId:  Cardinal;                           // 调用者的线程 ID
    Tag: array[0..CnMaxTagLength - 1] of AnsiChar; // 自定义 Tag 值，供用户过滤用
    MsgType:   Cardinal;                           // 消息类型
    MsgCPInterval: Int64;                          // 计时结束时的 CPU 周期数
    TimeStampType: Cardinal;                       // 消息输出的时间戳类型
    case Integer of
      1: (MsgDateTime:   TDateTime);               // 消息输出的时间戳值 DateTime
      2: (MsgTickCount:  Cardinal);                // 消息输出的时间戳值 TickCount
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
    NeedRefresh: Cardinal;                         // 非 0 时需要更新
    Enabled: Integer;                              // 非 0 时表示使能
    Level: Integer;                                // 限定的 Level
    Tag: array[0..CnMaxTagLength - 1] of AnsiChar; // 限定的 Tag
    case Integer of
      0: (MsgTypes: TCnMsgTypes);                  // 限定的 MsgTypes
      1: (DummyPlace: Cardinal);
  end;
  PCnMapFilter = ^TCnMapFilter;

  {$NODEFINE TCnMapHeader}
  {$NODEFINE PCnMapHeader}
  TCnMapHeader = packed record
  {* 用内存映射文件传送数据时的内存区头格式}
    MagicName:  array[0..CnDebugMagicLength - 1] of AnsiChar;  // 'CNDEBUG'
    MapEnabled: Cardinal;           // 为一 CnDebugMapEnabled 时，表示区域可用
    MapSize:    Cardinal;           // 整个 Map 的大小，不包括尾保护区
    DataOffset: Integer;            // 数据区相对于头部的偏移量，目前定为 64
    QueueFront: Integer;            // 队列头指针，是相对于数据区的偏移量
    QueueTail:  Integer;            // 队列尾指针，是相对于数据区的偏移量
    Filter: TCnMapFilter;           // Viewer 端设置的过滤器
  end;
  PCnMapHeader = ^TCnMapHeader;

  // ===================== 以上结构定义需要和 Viewer 共享 ======================

procedure ReInitLocalConsts;

implementation

procedure ReInitLocalConsts;
const
  SCnDebugLocalPrefix = 'Local\';
begin
  SCnDebugMapName := SCnDebugLocalPrefix + 'CnDebugMap';
  SCnDebugQueueEventName := SCnDebugLocalPrefix + 'CnDebugQueueEvent';
  SCnDebugQueueMutexName := SCnDebugLocalPrefix + 'CnDebugQueueMutex';
  SCnDebugStartEventName := SCnDebugLocalPrefix + 'CnDebugStartEvent';
  SCnDebugFlushEventName := SCnDebugLocalPrefix + 'CnDebugFlushEvent';
end;

end.
