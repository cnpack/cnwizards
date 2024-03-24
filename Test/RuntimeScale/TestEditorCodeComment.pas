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

unit TestEditorCodeComment;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码块注释工具单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org; http://www.cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2016.06.09 V1.1
*               加入保持原始代码缩进的设置
*           2002.12.31 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ExtCtrls;

type
  TEditorCodeCommentForm = class(TForm)
    grp1: TGroupBox;
    chkMoveToNextLine: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    rgIndentMode: TRadioGroup;
    procedure FormCreate(Sender: TObject);private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  UnitRuntimeSale, CnWizScaler;

{$R *.dfm}

procedure TEditorCodeCommentForm.FormCreate(Sender: TObject);
begin
  if ScaleFactor <> 1.0 then
    ScaleForm(Self, ScaleFactor);
end;

end.
