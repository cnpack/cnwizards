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

unit CnTestBreakpointWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnWizDebuggerNotifier �жϵ���صĲ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�� CnWizDebuggerNotifier ��Ԫ�ṩ�Ļ�ȡ�ϵ�Ľӿڽ��в���
            ֻ�轫�˵�Ԫ����ר�Ұ�Դ�빤�̺��ر�����ؼ��ɽ��в��ԣ�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.06.03 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper,
  CnWizDebuggerNotifier;

type

//==============================================================================
// ���� CnWizDebuggerNotifier �Ļ�ȡ�ϵ�Ĳ˵�ר��
//==============================================================================

{ TCnTestBreakpointWizard }

  TCnTestBreakpointWizard = class(TCnSubMenuWizard)
  private
    FIdGetBPFromCnService: Integer;
    FIdGetBPFromToolsAPI: Integer;
    procedure GetBPFromCnServiceExecute;
    procedure GetBPFromToolsAPIExecute;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure AcquireSubActions; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���� CnWizDebuggerNotifier �еĻ�ȡ�ϵ�Ĳ˵�ר��
//==============================================================================

{ TCnTestBreakpointWizard }

procedure TCnTestBreakpointWizard.AcquireSubActions;
begin
  FIdGetBPFromCnService := RegisterASubAction('CnGetBPFromCnService', 'Get BP From Wizard Service');
  FIdGetBPFromToolsAPI := RegisterASubAction('CnGetBPFromToolsAPI', 'Get BP From ToolsAPI');
end;

procedure TCnTestBreakpointWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestBreakpointWizard.GetBPFromCnServiceExecute;
var
  List: TList;
  I: Integer;
  S: string;
begin
  List := TList.Create;
  try
    CnOtaGetCurrentBreakpoints(List);

    if List.Count = 0 then
      ShowMessage('No Breakpoints.')
    else
    begin
      for I := 0 to List.Count - 1 do
        S := S + TCnBreakpointDescriptor(List[I]).ToString + #13#10;
      ShowMessage(S);
    end;

    ShowMessage('To Add a Breakpoint at Line 15');
    if EditControlWrapper.ClickBreakpointAtActualLine(15) then
      ShowMessage('Breakpoint Clicked.')
    else
      ShowMessage('Breakpoint Click Fail.');
  finally
    List.Free;
  end;
end;

procedure TCnTestBreakpointWizard.GetBPFromToolsAPIExecute;
var
  DebugSvcs: IOTADebuggerServices;
  B: IOTASourceBreakpoint;
  S: string;
  I: Integer;
begin
  if Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
  begin
    I := DebugSvcs.GetSourceBkptCount;
    if I = 0 then
      ShowMessage('No Breakpoints from Tools API.')
    else
    begin
      for I := 0 to DebugSvcs.GetSourceBkptCount - 1 do
      begin
        B := DebugSvcs.GetSourceBkpt(I);
        S := S + Format('#%d. Line %d - %s%s', [I, B.LineNumber, B.FileName, #13#10]);
      end;
      ShowMessage(S);
    end;
  end;
end;

function TCnTestBreakpointWizard.GetCaption: string;
begin
  Result := 'Test Breakpoints';
end;

function TCnTestBreakpointWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBreakpointWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBreakpointWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestBreakpointWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBreakpointWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Breakpoints Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Get Breakpoints';
end;

procedure TCnTestBreakpointWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBreakpointWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBreakpointWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdGetBPFromCnService then
    GetBPFromCnServiceExecute
  else if Index = FIdGetBPFromToolsAPI then
    GetBPFromToolsAPIExecute;
end;

initialization
  RegisterCnWizard(TCnTestBreakpointWizard); // ע��˲���ר��

end.

