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

unit CnSampleSubMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��򵥵��Ӳ˵�ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ��ʾ��һ�������Ĵ��Ӳ˵�ר��Ӧ���еĶ���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2003.09.10 V1.0 ����(Qsoft) hq.com@263.net
*             ����CreateSubActions�������ڴ����˲˵�ר��
*           2003.05.25 V1.0
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
// ��ʾ���Ӳ˵�ר��
//==============================================================================

{ TCnSampleSubMenuWizard }

  TCnSampleSubMenuWizard = class(TCnSubMenuWizard)
  private
    IdTool: Integer;
    IdConfig: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

//==============================================================================
// ��ʾ�ò˵�ר��
//==============================================================================

{ TCnSampleSubMenuWizard }

procedure TCnSampleSubMenuWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

constructor TCnSampleSubMenuWizard.Create;
begin
  inherited;

end;

// �������ظ÷����������Ӳ˵�ר����
procedure TCnSampleSubMenuWizard.AcquireSubActions;
begin
  { TODO -oAnyone : �˴������Ӳ˵���ַ�������б��ػ����� }
  IdTool := RegisterASubAction('SampleTool', 'SampleToolCaption', 0,
    'SampleToolHint', 'SampleTool');

  // �����ָ��˵�
  AddSepMenu;

  IdConfig := RegisterASubAction('SampleConfig',
    'SampleConfigCaption', 0, 'SampleConfigHint', 'SampleConfig');
end;

function TCnSampleSubMenuWizard.GetCaption: string;
begin
  Result := 'Test';
  { TODO -oAnyone : ����ר�Ҳ˵��ı��⣬�ַ�������б��ػ����� }
end;

function TCnSampleSubMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
  { TODO -oAnyone : ����ר���Ƿ������ô��� }
end;

function TCnSampleSubMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
  { TODO -oAnyone : ����ר�Ҳ˵���ʾ��Ϣ���ַ�������б��ػ����� }
end;

function TCnSampleSubMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : ����ר�Ҳ˵�״̬���ɸ���ָ���������趨 }
end;

class procedure TCnSampleSubMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Submenu Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Only test';
  { TODO -oAnyone : ����ר�ҵ����ơ����ߡ����估��ע���ַ�������б��ػ����� }
end;

procedure TCnSampleSubMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ�װ��ר���ڲ��õ��Ĳ�����ר�Ҵ���ʱ�Զ������� }
end;

procedure TCnSampleSubMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ˱���ר���ڲ��õ��Ĳ�����ר���ͷ�ʱ�Զ������� }
end;

procedure TCnSampleSubMenuWizard.SubActionExecute(Index: Integer);
begin
  if not Active then Exit;

  if Index = IdTool then
     // Tool �ӹ���ִ����
  else if Index = IdConfig then
    Config;
end;

procedure TCnSampleSubMenuWizard.SubActionUpdate(Index: Integer);
begin
  // ע������˴�ʹ�� inherited��������ݵ�ǰר�ҵ� Active ������
  // �� Action �� Enabled��Visible �����ԣ������ Action Ҫ�Լ�����
  // ״̬���벻Ҫ���� inherited ������������ܻᵼ�� Action ״̬����
  // inherited;
  
  if Index = IdTool then
  begin
    SubActions[IdTool].Visible := Active;
    SubActions[IdTool].Enabled := Active;
  end
  else if Index = IdConfig then
  begin
    SubActions[IdConfig].Visible := Active;
    SubActions[IdConfig].Enabled := Active;
  end;
end;

initialization
  RegisterCnWizard(TCnSampleSubMenuWizard); // ע��ר��

end.
