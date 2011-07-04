{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnImageListEditorFrm;

interface
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：支持在线搜索的 ImageList 编辑器窗体
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, ExtCtrls, StdCtrls, ImgList, ComCtrls;

type
  TCnImageListEditorForm = class(TCnTranslateForm)
    pnlLeft: TPanel;
    spl1: TSplitter;
    pnlSearch: TPanel;
    grp1: TGroupBox;
    grp2: TGroupBox;
    btnAdd: TButton;
    btnReplace: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    btnExport: TButton;
    lvList: TListView;
    cbbSize: TComboBox;
    grp3: TGroupBox;
    lbl1: TLabel;
    btnSearch: TButton;
    lv2: TListView;
    btnSearchAdd: TButton;
    btnPrev: TButton;
    btnNext: TButton;
    btnFirst: TButton;
    btnLast: TButton;
    btnSearchReplace: TButton;
    pnl3: TPanel;
    imgSelected: TImage;
    lbl2: TLabel;
    cbbTransparentColor: TComboBox;
    lbl3: TLabel;
    cbbFillColor: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    btnHelp: TButton;
    btnShowSearch: TButton;
    cbbKeyword: TComboBox;
    rgOptions: TRadioGroup;
    lbl4: TLabel;
    cbb1: TComboBox;
    btnGoto: TButton;
    il1: TImageList;
  private
    { Private declarations }
    FComponent: TCustomImageList;
  public
    { Public declarations }
  end;

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList);

implementation

{$R *.dfm}

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList);
begin
  with TCnImageListEditorForm.Create(nil) do
  try
    FComponent := AComponent;
    ShowModal;
  finally
    Free;
  end;
end;

end.
