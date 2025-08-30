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

unit CnSampleMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��򵥵�ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ��ʾ��һ�������Ĳ˵�ר��Ӧ���еĶ���
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
// ��ʾ�ò˵�ר��
//==============================================================================

{ TCnSampleMenuWizard }

  TCnSampleMenuWizard = class(TCnMenuWizard)
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
// ��ʾ�ò˵�ר��
//==============================================================================

{ TCnSampleMenuWizard }

procedure TCnSampleMenuWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : �ڴ���ʾ���ô��� }
end;

procedure TCnSampleMenuWizard.Execute;
begin
  ShowMessage('Test');
  { TODO -oAnyone : ��ר�ҵ���ִ�й��� }
end;

function TCnSampleMenuWizard.GetCaption: string;
begin
  Result := 'Test';
  { TODO -oAnyone : ����ר�Ҳ˵��ı��⣬�ַ�������б��ػ����� }
end;

function TCnSampleMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : ����Ĭ�ϵĿ�ݼ� }
end;

function TCnSampleMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
  { TODO -oAnyone : ����ר���Ƿ������ô��� }
end;

function TCnSampleMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
  { TODO -oAnyone : ����ר�Ҳ˵���ʾ��Ϣ���ַ�������б��ػ����� }
end;

function TCnSampleMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : ����ר�Ҳ˵�״̬���ɸ���ָ���������趨 }
end;

class procedure TCnSampleMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Menu Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Only test';
  { TODO -oAnyone : ����ר�ҵ����ơ����ߡ����估��ע���ַ�������б��ػ����� }
end;

procedure TCnSampleMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ�װ��ר���ڲ��õ��Ĳ�����ר�Ҵ���ʱ�Զ������� }
end;

procedure TCnSampleMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : �ڴ˱���ר���ڲ��õ��Ĳ�����ר���ͷ�ʱ�Զ������� }
end;

initialization
  RegisterCnWizard(TCnSampleMenuWizard); // ע��ר��

end.
