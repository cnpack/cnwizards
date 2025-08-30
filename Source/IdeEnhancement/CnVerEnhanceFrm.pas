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

unit CnVerEnhanceFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��汾��Ϣ��չ���õ�Ԫ
* ��Ԫ���ߣ���ʡ��hubdog��
* ��    ע��
* ����ƽ̨��JWinXPPro + Delphi 7.01
* ���ݲ��ԣ�JWinXPPro+ Delphi 7.01
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2019.03.26 V1.1 by liuxiao
*               ���뽫��������Ϊ�汾�ŵ�����
*           2005.05.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, StdCtrls;

type
  TCnVerEnhanceForm = class(TCnTranslateForm)
    grpVerEnh: TGroupBox;
    chkLastCompiled: TCheckBox;
    chkIncBuild: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lblNote: TLabel;
    lblFormat: TLabel;
    cbbFormat: TComboBox;
    chkDateAsVersion: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkLastCompiledClick(Sender: TObject);
    procedure chkIncBuildClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;    
  public

  end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

{$R *.DFM}

procedure TCnVerEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnVerEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnVerEnhanceWizard';
end;

procedure TCnVerEnhanceForm.FormCreate(Sender: TObject);
begin
{$IFNDEF COMPILER6_UP}
  chkLastCompiled.Enabled := False;
  chkIncBuild.Enabled := False;
  lblFormat.Enabled := False;
  cbbFormat.Enabled := False;
  chkDateAsVersion.Enabled := False;
{$ELSE}
  lblFormat.Enabled := chkLastCompiled.Checked;
  cbbFormat.Enabled := chkLastCompiled.Checked;
  chkDateAsVersion.Enabled := chkIncBuild.Checked;
{$ENDIF}
end;

procedure TCnVerEnhanceForm.chkLastCompiledClick(Sender: TObject);
begin
  lblFormat.Enabled := chkLastCompiled.Checked;
  cbbFormat.Enabled := chkLastCompiled.Checked;
end;

procedure TCnVerEnhanceForm.chkIncBuildClick(Sender: TObject);
begin
  chkDateAsVersion.Enabled := chkIncBuild.Checked;
end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}
end.

