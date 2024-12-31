{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnCpuWinEnhanceFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CPU 调试窗口扩展设置窗体
* 单元作者：Aimingoo (原作者) aim@263.net; http://www.doany.net
*           周劲羽 (移植) zjy@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.07.31 V1.0
*               移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$IFNDEF BDS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, CnSpin, CnWizUtils, CnWizMultiLang;

type

{ TCnCpuWinEnhanceForm }

  TCopyFrom = (cfTopAddr, cfSelectAddr);
  TCopyTo = (ctClipboard, ctFile);

  TCnCpuWinEnhanceForm = class(TCnTranslateForm)
    CopyParam: TGroupBox;
    rbTopAddr: TRadioButton;
    rbSelectAddr: TRadioButton;
    cbSettingToAll: TCheckBox;
    Label1: TLabel;
    seCopyLineCount: TCnSpinEdit;
    rgCopyToMode: TRadioGroup;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure btnHelpClick(Sender: TObject);
    procedure seCopyLineCountKeyPress(Sender: TObject; var Key: Char);
  private

  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

function ShowCpuWinEnhanceForm(var CopyForm: TCopyFrom; var CopyTo: TCopyTo;
  var CopyLineCount: Integer; var SettingToAll: Boolean): Boolean;

{$ENDIF}

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$IFNDEF BDS}

{$R *.DFM}

function ShowCpuWinEnhanceForm(var CopyForm: TCopyFrom; var CopyTo: TCopyTo;
  var CopyLineCount: Integer; var SettingToAll: Boolean): Boolean;
begin
  with TCnCpuWinEnhanceForm.Create(nil) do
  try
    rbTopAddr.Checked := CopyForm = cfTopAddr;
    rbSelectAddr.Checked := not rbTopAddr.Checked;
    seCopyLineCount.Value := CopyLineCount;
    rgCopyToMode.ItemIndex := Ord(CopyTo);
    cbSettingToAll.Checked := SettingToAll;

    Result := ShowModal = mrOk;
    if Result then
    begin
      if rbTopAddr.Checked then
        CopyForm := cfTopAddr
      else
        CopyForm := cfSelectAddr;
      CopyLineCount := seCopyLineCount.Value;
      CopyTo := TCopyTo(rgCopyToMode.ItemIndex);
      SettingToAll := cbSettingToAll.Checked;
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

{$ENDIF}

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

end.
