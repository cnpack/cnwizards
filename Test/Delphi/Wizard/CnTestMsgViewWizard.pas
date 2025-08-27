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

unit CnTestMsgViewWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnMessageViewWrapper ��װ����������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�� CnWizIdeUtils ��Ԫ�� CnMessageViewWrapper ��װ����Ϣ��������
            ���в��ԣ�ֻ�轫�˵�Ԫ����ר�Ұ�Դ�빤�̺��ر�����ؼ��ɽ��в��ԣ�
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
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils;

type

//==============================================================================
// ���� CnMessageViewWrapper �˵�ר��
//==============================================================================

{ TCnTestMessageViewMenuWizard }

  TCnTestMessageViewMenuWizard = class(TCnMenuWizard)
  private
    procedure ShowAndLog(const Msg: string);
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
// ���� CnMessageViewWrapper �˵�ר��
//==============================================================================

{ TCnTestMessageViewMenuWizard }

procedure TCnTestMessageViewMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestMessageViewMenuWizard.Execute;
begin
  if CnMessageViewWrapper.MessageViewForm <> nil then
  begin
    ShowAndLog('MessageView Got. Show It');
    CnOtaMakeSourceVisible(CnOtaGetCurrentSourceFile());

    CnMessageViewWrapper.MessageViewForm.Show;

    if CnMessageViewWrapper.TabSet <> nil then
    begin
      ShowAndLog(Format('TabSet Got. Visible %d.', [Integer(CnMessageViewWrapper.TabSetVisible)]));
      ShowAndLog(Format('%d of %d Tabs Selected: %s',
        [CnMessageViewWrapper.TabIndex,
         CnMessageViewWrapper.TabCount,
         CnMessageViewWrapper.TabCaption]));
    end;

    if CnMessageViewWrapper.TreeView <> nil then
    begin
      ShowAndLog('TreeView Got.');
{$IFDEF BDS}
      ShowAndLog('BDS: Can NOT got message from Virtual TreeView.');
{$ELSE}
      ShowAndLog(Format('MessageCount: %d. Number %d Selected:  %s',
        [CnMessageViewWrapper.MessageCount,
         CnMessageViewWrapper.SelectedIndex,
         CnMessageViewWrapper.CurrentMessage]));
{$ENDIF}
    end;

{$IFNDEF BDS}
    if CnMessageViewWrapper.SelectedIndex < CnMessageViewWrapper.MessageCount then
    begin
      ShowAndLog('To Select Message Next to ' + IntToStr(CnMessageViewWrapper.SelectedIndex));
      CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex + 1;
    end;
{$ENDIF}
    CnMessageViewWrapper.EditMessageSource;
    ShowAndLog('EditSource Called. Jump to Line if Possible.');
  end;
end;

function TCnTestMessageViewMenuWizard.GetCaption: string;
begin
  Result := 'Test MessageViewWrapper';
end;

function TCnTestMessageViewMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestMessageViewMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestMessageViewMenuWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestMessageViewMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestMessageViewMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test MessageViewWrapper Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for MessageViewWrapper';
end;

procedure TCnTestMessageViewMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestMessageViewMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestMessageViewMenuWizard.ShowAndLog(const Msg: string);
begin
  ShowMessage(Msg);
  CnDebugger.TraceMsg(Msg);
end;

initialization
  RegisterCnWizard(TCnTestMessageViewMenuWizard); // ע��˲���ר��

end.
