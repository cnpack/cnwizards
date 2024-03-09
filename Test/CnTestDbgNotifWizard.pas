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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestDbgNotifWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnWizDebuggerNotifier测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元对CnWizDebuggerNotifier单元提供的 Debugger 通知器接口进行测试
            只需将此单元加入专家包源码工程后重编译加载即可进行测试，
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizDebuggerNotifier;

type

//==============================================================================
// 测试 CnWizDebuggerNotifier 菜单专家
//==============================================================================

{ TCnTestDbgNotifMenuWizard }

  TCnTestDbgNotifMenuWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    procedure ProcessNotify(Process: IOTAProcess; Reason: TCnProcessNotifyReason);
    procedure ThreadNotify(Process: IOTAProcess; Thread: IOTAThread;
      Reason: TCnThreadNotifyReason);
    procedure BreakPointNotify(Breakpoint: IOTABreakpoint; Reason: TCnBreakpointNotifyReason);
  end;

implementation

uses
  CnDebug;

var
  FProcess: IOTAProcess = nil;
  FThread: IOTAThread = nil;

//==============================================================================
// 测试 CnWizDebuggerNotifier 菜单专家
//==============================================================================

{ TCnTestDbgNotifMenuWizard }

procedure TCnTestDbgNotifMenuWizard.BreakPointNotify(Breakpoint: IOTABreakpoint;
  Reason: TCnBreakpointNotifyReason);
begin
  CnDebugger.TraceFmt('Breakpoint! Reason %d. Bkpt %x', [Ord(Reason), Integer(Breakpoint)]);
end;

procedure TCnTestDbgNotifMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestDbgNotifMenuWizard.Execute;
var
  Eval: TCnInProcessEvaluator;
begin
  if (FProcess = nil) or (FThread = nil) then
  begin
    ShowMessage('Test DebuggerNotifier.' + #13#10#13#10 +
      'Please Use CnDebugViewer to See the Output Results' + #13#10 + 'when Add/Delete Breakpoint and Run/Pause/Stop Process.');
  end;

  Eval := TCnInProcessEvaluator.Create;
  try
    CnDebugger.TraceMsg(Eval.EvaluateExpression('Screen.FormCount'));
  finally
    Eval.Free;
  end;
end;

function TCnTestDbgNotifMenuWizard.GetCaption: string;
begin
  Result := 'Test DebuggerNotifier';
end;

function TCnTestDbgNotifMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDbgNotifMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDbgNotifMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestDbgNotifMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDbgNotifMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test DebuggerNotifier Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for CnWizDebuggerNotifierServices';
end;

procedure TCnTestDbgNotifMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin
  CnWizDebuggerNotifierServices.AddProcessNotifier(ProcessNotify);
  CnWizDebuggerNotifierServices.AddThreadNotifier(ThreadNotify);
  CnWizDebuggerNotifierServices.AddBreakpointNotifier(BreakPointNotify);
end;

procedure TCnTestDbgNotifMenuWizard.ProcessNotify(Process: IOTAProcess;
  Reason: TCnProcessNotifyReason);
begin
  CnDebugger.TraceFmt('Process! Reason %d. Process %x', [Ord(Reason), Integer(Process)]);
end;

procedure TCnTestDbgNotifMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin
  CnWizDebuggerNotifierServices.RemoveProcessNotifier(ProcessNotify);
  CnWizDebuggerNotifierServices.RemoveThreadNotifier(ThreadNotify);
  CnWizDebuggerNotifierServices.RemoveBreakpointNotifier(BreakPointNotify);
end;

procedure TCnTestDbgNotifMenuWizard.ThreadNotify(Process: IOTAProcess;
  Thread: IOTAThread; Reason: TCnThreadNotifyReason);
var
  C: TContext;
  Er: TOTAEvaluateResult;
  a: array[0..255] of Char;
  CanModify: Boolean;
  ResAddr: LongWord;
  ResSize, ResVal: LongWord;
begin
  CnDebugger.TraceFmt('Process: %x; Thread %x, Reason %d', [Integer(Process), Integer(Thread), Ord(Reason)]);
  if (Process <> nil) and (Thread <> nil) then
  begin
    FProcess := Process;
    FThread := Thread;
    CnDebugger.TraceFmt('File: %s', [Thread.CurrentFile]);
    CnDebugger.TraceFmt('Current Line %d.', [Thread.CurrentLine]);
    C := Thread.Context;
    CnDebugger.TraceFmt('EAX %x, EBX %x, ECX %x, EDX %x, ESI %x, EDI %x, EBP %x, EIP %x, ESP %x',
      [C.Eax, C.Ebx, C.Ecx, C.Edx, C.Esi, C.Edi, C.Ebp, C.Eip, C.Esp]);

    FillChar(a, SizeOf(a), 0);

    Er := Thread.Evaluate('Application', @a[0], 255, CanModify, True, '', ResAddr, ResSize, ResVal);
    if Er = erOK then
    begin
      CnDebugger.TraceFmt('Notify Evaluation OK. Return String: ', [a]);
      CnDebugger.TraceFmt('Notify ResAddr %x, ResSize %x, ResVal %x.', [ResAddr, ResSize, ResVal]);
      // 如果返回的是对象，则 ResAddr 就是此对象的引用地址，也就是对象本身。
      // 但由于地址空间不同，所以没法直接使用子进程的此对象。所以下两句不可用。
      // if ResAddr <> 0 then
      //  CnDebugger.TraceMsg(TApplication(TObject(ResAddr)).Title);
    end
    else
      CnDebugger.TraceFmt('ResultStr %s, ResAddr %x, ResSize %x, ResVal %x.', [a, ResAddr, ResSize, ResVal]);
  end;
end;

initialization
  RegisterCnWizard(TCnTestDbgNotifMenuWizard); // 注册此测试专家

end.
