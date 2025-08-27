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

unit CnTestEditorMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���Ҽ��˵���Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 7
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.08.17 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager;

type

//==============================================================================
// ���Ա༭���Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestEditorMenuWizard }

  TCnTestEditorMenuWizard = class(TCnMenuWizard)
  private
    procedure ExecutorExecute(Sender: TObject);
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

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
// ���Ա༭���Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestEditorMenuWizard }

procedure TCnTestEditorMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorMenuWizard.Create;
var
  Ext: TCnContextMenuExecutor;
begin
  inherited;
  Ext := TCnContextMenuExecutor.Create;
  Ext.OnExecute := ExecutorExecute;
  Ext.Caption := 'Test Case 1';
  RegisterEditorMenuExecutor(Ext);

  Ext := TCnContextMenuExecutor.Create;
  Ext.OnExecute := ExecutorExecute;
  Ext.Caption := 'Test Item 2';
  RegisterEditorMenuExecutor(Ext);
end;

procedure TCnTestEditorMenuWizard.Execute;
begin
  ShowMessage('2 Menu Items Registered using TCnContextMenuExecutor.' + #13#10
    + 'Please Check Editor Context Menu.');
end;

procedure TCnTestEditorMenuWizard.ExecutorExecute(Sender: TObject);
begin
  ShowMessage('Executor Run Here.');
end;

function TCnTestEditorMenuWizard.GetCaption: string;
begin
  Result := 'Test Editor Menu';
end;

function TCnTestEditorMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Context Menu';
end;

procedure TCnTestEditorMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestEditorMenuWizard); // ע��˲���ר��

end.
