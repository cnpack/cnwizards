{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestDbgNotifWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnWizDebuggerNotifier����������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ��CnWizDebuggerNotifier��Ԫ�ṩ�� Debugger ֪ͨ���ӿڽ��в���
            ֻ�轫�˵�Ԫ����ר�Ұ�Դ�빤�̺��ر�����ؼ��ɽ��в��ԣ�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizDebuggerNotifier;

type

//==============================================================================
// ���� CnWizDebuggerNotifier �˵�ר��
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
// ���� CnWizDebuggerNotifier �˵�ר��
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
  Eval: TCnRemoteProcessEvaluator;
  S: string;
begin
  if (FProcess = nil) or (FThread = nil) then
  begin
    ShowMessage('Test DebuggerNotifier.' + #13#10#13#10 +
      'Please Use CnDebugViewer to See the Output Results' + #13#10 + 'when Add/Delete Breakpoint and Run/Pause/Stop Process.');
  end;

  Eval := TCnRemoteProcessEvaluator.Create;
  try
    S := Eval.EvaluateExpression('Screen.FormCount');
    if S <> '' then
      CnDebugger.TraceMsg(S)
    else
      CnDebugger.TraceMsg('Empty String Returned from Local Evaluator');
  finally
    Eval.Free;
  end;

  S := CnRemoteProcessEvaluator.EvaluateExpression('ADOTable1');
  if S <> '' then
    CnDebugger.TraceMsg(S)
  else
    CnDebugger.TraceMsg('Empty String Returned from Global Evaluator');
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
      // ������ص��Ƕ����� ResAddr ���Ǵ˶�������õ�ַ��Ҳ���Ƕ�����
      // �����ڵ�ַ�ռ䲻ͬ������û��ֱ��ʹ���ӽ��̵Ĵ˶������������䲻���á�
      // if ResAddr <> 0 then
      //  CnDebugger.TraceMsg(TApplication(TObject(ResAddr)).Title);
    end
    else
      CnDebugger.TraceFmt('ResultStr %s, ResAddr %x, ResSize %x, ResVal %x.', [a, ResAddr, ResSize, ResVal]);
  end;
end;

initialization
  RegisterCnWizard(TCnTestDbgNotifMenuWizard); // ע��˲���ר��

end.
