{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnIdentRenameFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：标识符改名提示窗体单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWinXpPro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnIdentRenameFrm.pas,v 1.1 2009/01/15 11:23:57 liuxiao Exp $
* 修改记录：2009.01.15
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnWizMultiLang;

type
  TCnIdentRenameForm = class(TCnTranslateForm)
    grpBrowse: TGroupBox;
    rbCurrentProc: TRadioButton;
    rbCurrentInnerProc: TRadioButton;
    rbUnit: TRadioButton;
    lblReplacePromt: TLabel;
    edtRename: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure edtRenameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$R *.DFM}

procedure TCnIdentRenameForm.FormShow(Sender: TObject);
begin
  edtRename.SetFocus;
end;

procedure TCnIdentRenameForm.edtRenameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  NextRadioButton: TRadioButton;
begin
  NextRadioButton := nil;
  if (Key = VK_UP) and (Shift = []) then
  begin
    if rbUnit.Checked then
    begin
      if rbCurrentInnerProc.Enabled then
        NextRadioButton := rbCurrentInnerProc
      else
        NextRadioButton := rbCurrentProc;
    end
    else if rbCurrentInnerProc.Checked then
      NextRadioButton := rbCurrentProc;

    Key := 0;
  end
  else if (Key = VK_DOWN) and (Shift = []) then
  begin
    if rbCurrentProc.Checked then
    begin
      if rbCurrentInnerProc.Enabled then
        NextRadioButton := rbCurrentInnerProc
      else
        NextRadioButton := rbUnit;
    end
    else if rbCurrentInnerProc.Checked then
      NextRadioButton := rbUnit;

    Key := 0;
  end;

  if NextRadioButton <> nil then
    if NextRadioButton.Enabled then
      NextRadioButton.Checked := True;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
