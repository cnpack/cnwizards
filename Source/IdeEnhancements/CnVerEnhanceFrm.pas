{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnVerEnhanceFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：版本信息扩展设置单元
* 单元作者：陈省（hubdog）
* 备    注：
* 开发平台：JWinXPPro + Delphi 7.01
* 兼容测试：JWinXPPro+ Delphi 7.01
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2019.03.26 V1.1 by liuxiao
*               加入将年月日设为版本号的设置
*           2005.05.05 V1.0
*               创建单元
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
    { Private declarations }
  protected
    function GetHelpTopic: string; override;    
  public
    { Public declarations }
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

