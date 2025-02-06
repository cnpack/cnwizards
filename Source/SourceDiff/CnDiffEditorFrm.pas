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

unit CnDiffEditorFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源代码拼合窗体单元
* 单元作者：Angus Johnson（原作者） ajohnson@rpi.net.au
*           周劲羽（移植）zjy@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.03.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, CnWizMultiLang;

type
  TCnDiffEditorForm = class(TCnTranslateForm)
    Panel1: TPanel;
    Memo: TMemo;
    bSave: TButton;
    bCancel: TButton;
    Label1: TLabel;
    ActionList: TActionList;
    actSave: TAction;
    actCancel: TAction;
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
    procedure actSaveExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private

  public

  end;

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSOURCEDIFFWIZARD}

{$R *.DFM}

procedure TCnDiffEditorForm.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  //if Key = #27 then
    //ModalResult := mrCancel;
end;

procedure TCnDiffEditorForm.actSaveExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCnDiffEditorForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{$ENDIF CNWIZARDS_CNSOURCEDIFFWIZARD}
end.
