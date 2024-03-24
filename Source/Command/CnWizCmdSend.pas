{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnWizCmdSend;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家工具包
* 单元名称：CnWizards 命令机制的发送端
* 单元作者：CnPack开发组 刘啸 (liuxiao@cnpack.org)
* 备    注：该单元实现了 CnWizards 命令机制的发送端
*           外部程序进行命令消息发送时需要使用到本单元
* 开发平台：WinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2017.11.14 V1.1
*               适配 Unicode 编译器
*           2008.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Messages, Windows, Classes, SysUtils, CnWizCompilerConst;

function CnWizSendCommand(Command: Cardinal; DestIDESet: TCnCompilers = [];
  const DestID: AnsiString = ''; const SourceID: AnsiString = '';
  const Params: TStrings = nil): Boolean;
{* 根据传入的参数发送命令
   参数:      Command: Cardinal;             命令号
              DestIDESet: TCnCompilers = []; 目的 IDE 版本要求
              const DestID: AnsiString = '';     目的 ID
              const SourceID: AnsiString = '';   发送者的源 ID
              const Params: TStrings = nil;  待发送的额外数据，
                为字符串列表的形式，由多行 param=value 形式的字符串组成

   返回值:    Boolean，是否发送成功

   备注：     如程序未使用 CnWizCmdNotifier.AddCmdNotifier 来注册自己的接收 ID，
              则此处的 SourceID 不起作用，对方即使利用此 SourceID 回复，程序也
              无法接收。因此 SourceID 置为空适用于只发送消息而不接收的简单场合。

              只有已经注册自己的接收 ID 并且此处发送的 SourceID 等于注册 ID 的
              情况下，发送的消息被对方 Reply 时程序才能收到对方的回应。}

function CnWizSendCommandFromScript(Command: Cardinal; DestIDESet: TCnCompilers;
  const DestID: AnsiString; const Params: TStrings): Boolean;
{* 供脚本专家调用的、简易的发送命令的函数
   参数:      Command: Cardinal;             命令号
              DestIDESet: TCnCompilers = []; 目的 IDE 版本要求
              const DestID: AnsiString = '';     目的 ID
              const Params: TStrings = nil;  待发送的额外数据，
                为字符串列表的形式，由多行 param=value 形式的字符串组成

   返回值:    Boolean，是否发送成功

   备注：     由于脚本无法注册自己的接收 ID，因此发送时也无需标注源 ID，
}

function CnWizReplyCommand(Command: Cardinal; DestIDESet: TCnCompilers = [];
  const SourceID: AnsiString = ''; const Params: TStrings = nil): Boolean;
{* 在收到命令的处理过程中回复命令，无需再次指明目的端
   参数:      Command: Cardinal;             命令号
              DestIDESet: TCnCompilers = [];     目的 IDE 版本要求
              const SourceID: AnsiString = '';   发送者的源 ID
              const Params: TStrings = nil;  待发送的额外数据，
                为字符串列表的形式，由多行 param=value 形式的字符串组成

   返回值:    Boolean，返回是否回复成功

   备注：     此函数只能在被 CnWizCmdNotifier.AddCmdNotifier 注册的通知回调方法
              中调用，在其他地方调用则无法获知当前命令的发送者，因此会出错。
              另外只有客户不匿名时（也就是存在 SourceID 时）才允许回复。

              运行流程为：
              对方首次发送->本地首次接收->本地回应->对方接收回应
              ->本地回应完成->对方首次发送完成
}

implementation

uses
  CnWizCmdMsg, CnWizCmdNotify {$IFDEF DEBUG}, CnDebug {$ENDIF};

// 根据传入的参数发送命令，返回是否发送成功
function CnWizSendCommand(Command: Cardinal; DestIDESet: TCnCompilers;
  const DestID: AnsiString; const SourceID: AnsiString; const Params: TStrings): Boolean;
var
  ASet: TCnCompilers;
  Cds: TCopyDataStruct;
  Cmd: PCnWizMessage;
  HWnd: Cardinal;
  S: AnsiString;
  DataLength, Cnt: Integer;
begin
  Result := False;

  // 超长则出错退出
  if (Length(DestID) > CN_WIZ_MAX_ID) or (Length(SourceID) > CN_WIZ_MAX_ID) then
    Exit;

  HWnd := FindWindowEx(0, 0, PChar(SCN_WIZ_CMD_WINDOW_NAME), nil);
  if HWnd = 0 then // 无目的窗口则退出
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('SendCommand: No Target Found.');
{$ENDIF}
    Exit;
  end;

  // 无参数则置为空
  if Params <> nil then
  begin
    S := AnsiString(Params.Text);
    DataLength := Length(S);
  end
  else
    DataLength := 0;

  Cds.cbData := SizeOf(TCnWizMessage) - SizeOf(Cardinal) + DataLength;

  GetMem(Cds.lpData, Cds.cbData);
  if Cds.lpData = nil then
    Exit;

  Cmd := Cds.lpData;
  FillChar(Cmd^, Cds.cbData, 0);

  Cmd^.Command := Command;

  ASet := DestIDESet;
  Cmd^.IDESets := Cardinal(PInteger(@ASet)^);

  // Unicode 编译器中 StrCopy 有 Ansi 版本号
  StrCopy(Cmd^.DestID, PAnsiChar(DestID));
  StrCopy(Cmd^.SourceID, PAnsiChar(SourceID));

  Cmd^.DataLength := DataLength;
  CopyMemory(@(Cmd^.Data[0]), @S[1], DataLength);

  try
    Cnt := 0;
    while HWnd <> 0 do
    begin
      Inc(Cnt);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('SendCommand: Found %d Target %8.8x', [Cnt, HWnd]);
{$ENDIF}
      if GetCurrentThreadId <> GetWindowThreadProcessId(HWnd, nil) then
      begin
        // 只发给调用者线程之外的窗口
        Result := Boolean(SendMessage(HWnd, WM_COPYDATA, 0, LPARAM(@Cds)));
{$IFDEF DEBUG}
        CnDebugger.LogFmt('SendCommand: %d Target %8.8x Sent. Result: %d', [Cnt, HWnd, Integer(Result)]);
{$ENDIF}
      end;
      HWnd := FindWindowEx(0, HWnd, PChar(SCN_WIZ_CMD_WINDOW_NAME), nil);
    end;
  finally
    FreeMem(Cds.lpData);
  end;
end;

// 供脚本专家调用的、简易的发送命令的函数
function CnWizSendCommandFromScript(Command: Cardinal; DestIDESet: TCnCompilers;
  const DestID: AnsiString; const Params: TStrings): Boolean;
begin
  Result := CnWizSendCommand(Command, DestIDESet, DestID, '', Params);
end;  

// 在收到命令的处理过程中回复命令，无需再次指明目的端，返回是否回复成功
function CnWizReplyCommand(Command: Cardinal; DestIDESet: TCnCompilers;
  const SourceID: AnsiString; const Params: TStrings): Boolean;
begin
  Result := False;
  if CnWizCmdNotifier.GetCurrentSourceId <> '' then // 只回复给署名的客户
    Result := CnWizSendCommand(Command, DestIDESet,
      CnWizCmdNotifier.GetCurrentSourceId, SourceID, Params);
end;

end.
