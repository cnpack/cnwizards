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

unit CnPropertyCompConfigFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：组件属性对比设置窗体单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 5
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串暂不符合本地化处理方式
* 修改记录：2021.08.08
*               创建单元，实现基础功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnWizMultiLang, ExtCtrls;

type
  TCnPropertyCompConfigForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pgc1: TPageControl;
    tsProperty: TTabSheet;
    chkSameType: TCheckBox;
    lblAll: TLabel;
    mmoIgnoreProperties: TMemo;
    chkShowMenu: TCheckBox;
    tsFont: TTabSheet;
    pnlFont: TPanel;
    btnFont: TButton;
    dlgFont: TFontDialog;
    btnReset: TButton;
    procedure btnHelpClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  private
    FFontChanged: Boolean;
  protected
    function GetHelpTopic: string; override;
  public
    property FontChanged: Boolean read FFontChanged;
  end;

var
  CnPropertyCompConfigForm: TCnPropertyCompConfigForm;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

{$R *.DFM}

uses
  CnGraphUtils;

{ TCnPropertyCompConfigForm }

function TCnPropertyCompConfigForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

procedure TCnPropertyCompConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnPropertyCompConfigForm.btnFontClick(Sender: TObject);
begin
  dlgFont.Font := pnlFont.Font;
  if dlgFont.Execute then
  begin
    pnlFont.Font := dlgFont.Font;
    FFontChanged := True;
  end;
end;

procedure TCnPropertyCompConfigForm.btnResetClick(Sender: TObject);
var
  OldFont: TFont;
begin
  OldFont := TFont.Create;
  try
    OldFont.Assign(pnlFont.Font);
    pnlFont.ParentFont := True;

    // 重置后得字体有变化才行
    FFontChanged := not FontEqual(OldFont, pnlFont.Font);
  finally
    OldFont.Free;
  end;
end;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.
