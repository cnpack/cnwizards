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

unit CnCpuWinEnhanceFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CPU ���Դ�����չ���ô���
* ��Ԫ���ߣ�Aimingoo (ԭ����) aim@263.net; http://www.doany.net
*           �ܾ��� (��ֲ) zjy@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.07.31 V1.0
*               ��ֲ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, CnSpin, CnWizUtils, CnWizMultiLang;

type

{ TCnCpuWinEnhanceForm }

  TCnCopyFromMode = (cfTopAddr, cfSelectAddr);
  TCnCopyToMode = (ctClipboard, ctFile);

  TCnCpuWinEnhanceForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgcCpu: TPageControl;
    tsASM: TTabSheet;
    tsMemory: TTabSheet;
    CopyParam: TGroupBox;
    Label1: TLabel;
    rbTopAddr: TRadioButton;
    rbSelectAddr: TRadioButton;
    seCopyLineCount: TCnSpinEdit;
    rgCopyToMode: TRadioGroup;
    cbSettingToAll: TCheckBox;
    GroupBox1: TGroupBox;
    lblCopyMem: TLabel;
    seCopyMemLine: TCnSpinEdit;
    procedure btnHelpClick(Sender: TObject);
    procedure seCopyLineCountKeyPress(Sender: TObject; var Key: Char);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

function ShowCpuWinEnhanceForm(var CopyForm: TCnCopyFromMode; var CopyTo: TCnCopyToMode;
  var CopyLineCount: Integer; var SettingToAll: Boolean; var CopyMemLine: Integer): Boolean;

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$R *.DFM}

function ShowCpuWinEnhanceForm(var CopyForm: TCnCopyFromMode; var CopyTo: TCnCopyToMode;
  var CopyLineCount: Integer; var SettingToAll: Boolean; var CopyMemLine: Integer): Boolean;
begin
  with TCnCpuWinEnhanceForm.Create(nil) do
  try
    rbTopAddr.Checked := CopyForm = cfTopAddr;
    rbSelectAddr.Checked := not rbTopAddr.Checked;
    seCopyLineCount.Value := CopyLineCount;
    rgCopyToMode.ItemIndex := Ord(CopyTo);
    cbSettingToAll.Checked := SettingToAll;

    seCopyMemLine.Value := CopyMemLine;

    Result := ShowModal = mrOk;
    if Result then
    begin
      if rbTopAddr.Checked then
        CopyForm := cfTopAddr
      else
        CopyForm := cfSelectAddr;
      CopyLineCount := seCopyLineCount.Value;
      CopyTo := TCnCopyToMode(rgCopyToMode.ItemIndex);
      SettingToAll := cbSettingToAll.Checked;

      CopyMemLine := seCopyMemLine.Value;
    end;
  finally
    Free;
  end;
end;

procedure TCnCpuWinEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnCpuWinEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnCpuWinEnhanceWizard';
end;

procedure TCnCpuWinEnhanceForm.seCopyLineCountKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end
  else
  if Key = #13 then
  begin
    ModalResult := mrOk;
    Key := #0;
  end
end;

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

end.
