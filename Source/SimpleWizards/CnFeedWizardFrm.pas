{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnFeedWizardFrm;

interface
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：RSS 专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: $
* 修改记录：2010.04.08
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFEEDWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, StdCtrls, CnFeedWizard;

type
  TCnFeedWizardForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
    FWizard: TCnFeedWizard;
  public
    { Public declarations }
  end;

function ShowCnFeedWizardForm(Wizard: TCnFeedWizard): Boolean;

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

implementation

{$IFDEF CNWIZARDS_CNFEEDWIZARD}

{$R *.dfm}

function ShowCnFeedWizardForm(Wizard: TCnFeedWizard): Boolean;
begin
  with TCnFeedWizardForm.Create(nil) do
  try
    FWizard := Wizard;
    Result := ShowModal = mrOk;
  finally
    Free;
  end;   
end;  

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

end.
