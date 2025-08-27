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

{ TCnTestBreakpointMenuWizard }

  TCnTestBreakpointMenuWizard = class(TCnMenuWizard)
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
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ���� CnWizDebuggerNotifier �еĻ�ȡ�ϵ�Ĳ˵�ר��
//==============================================================================

{ TCnTestBreakpointMenuWizard }

procedure TCnTestBreakpointMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestBreakpointMenuWizard.Execute;
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

function TCnTestBreakpointMenuWizard.GetCaption: string;
begin
  Result := 'Get Current Breakpoints';
end;

function TCnTestBreakpointMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBreakpointMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBreakpointMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestBreakpointMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBreakpointMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Breakpoints Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Get Breakpoints';
end;

procedure TCnTestBreakpointMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBreakpointMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestBreakpointMenuWizard); // ע��˲���ר��

end.

