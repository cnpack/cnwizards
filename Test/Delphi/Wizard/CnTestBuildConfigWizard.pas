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

unit CnTestBuildConfigWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnWizDebuggerNotifier ����������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫֻ֧�� Delphi 2009 �������汾
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
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ���� D2009 �� BuildConfiguration ��ؽӿڵĲ˵�ר��
//==============================================================================

{ TCnTestBuildConfigWizard }

  TCnTestBuildConfigWizard = class(TCnMenuWizard)
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

//==============================================================================
// ���� D2009 �� BuildConfiguration ��ؽӿڵĲ˵�ר��
//==============================================================================

{ TCnTestBuildConfigWizard }

procedure TCnTestBuildConfigWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestBuildConfigWizard.Execute;
var
  BC: IOTAProjectOptionsConfigurations;
  I: Integer;
begin
  BC := CnOtaGetActiveProjectOptionsConfigurations();
  if BC <> nil then
  begin
    ShowMessage('Current Project''s Configuration Count: ' + IntToStr(BC.ConfigurationCount));
    for I := 0 to BC.ConfigurationCount - 1 do
    begin
      if BC.Configurations[I] = BC.ActiveConfiguration then
        ShowMessage(Format('Cofiguration %d: %s. Active.', [I, BC.Configurations[I].Name]))
      else
        ShowMessage(Format('Cofiguration %d: %s', [I, BC.Configurations[I].Name]));
    end;
  end;
end;

function TCnTestBuildConfigWizard.GetCaption: string;
begin
  Result := 'Test Build Configuration';
end;

function TCnTestBuildConfigWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestBuildConfigWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestBuildConfigWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestBuildConfigWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBuildConfigWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Build Configuration Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Build Configuration under Delphi 2009';
end;

procedure TCnTestBuildConfigWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBuildConfigWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestBuildConfigWizard); // ע��˲���ר��

end.
