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

unit CnHighlightLineFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器高亮画线设置窗体
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2008.07.02
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnSpin, CnLangMgr, CnWizMultiLang;

type
  TCnHighlightLineForm = class(TCnTranslateForm)
    GroupBox1: TGroupBox;
    lblLineWidth: TLabel;
    seLineWidth: TCnSpinEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lblLineType: TLabel;
    cbbLineType: TComboBox;
    chkLineEnd: TCheckBox;
    chkLineClass: TCheckBox;
    chkLineHori: TCheckBox;
    chkLineHoriDot: TCheckBox;
    chkLineNamespace: TCheckBox;
    procedure cbbLineTypeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure chkLineHoriClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  CnSourceHighlight;

{$R *.DFM}

procedure TCnHighlightLineForm.cbbLineTypeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  OldStyle: TPenStyle;
  OldBrushColor, OldPenColor: TColor;
begin
  OldStyle := cbbLineType.Canvas.Pen.Style;
  OldBrushColor := cbbLineType.Canvas.Brush.Color;
  OldPenColor := cbbLineType.Canvas.Pen.Color;

  if odSelected in State then
  begin
    cbbLineType.Canvas.Brush.Color := clHighlight;
    cbbLineType.Canvas.Pen.Color := clWhite;
  end
  else
  begin
    cbbLineType.Canvas.Brush.Color := clWhite;
    cbbLineType.Canvas.Pen.Color := clBlack;
  end;

  cbbLineType.Canvas.FillRect(Rect);

  HighlightCanvasLine(cbbLineType.Canvas, Rect.Left + 2, (Rect.Top + Rect.Bottom) div 2,
    Rect.Right - 2, (Rect.Top + Rect.Bottom) div 2, TCnLineStyle(Index));

  cbbLineType.Canvas.Pen.Style := OldStyle;
  cbbLineType.Canvas.Pen.Color := OldPenColor;
  cbbLineType.Canvas.Brush.Color := OldBrushColor;
end;

procedure TCnHighlightLineForm.chkLineHoriClick(Sender: TObject);
begin
  chkLineHoriDot.Enabled := chkLineHori.Checked;
end;

procedure TCnHighlightLineForm.FormCreate(Sender: TObject);
begin
  chkLineHoriDot.Enabled := chkLineHori.Checked;
end;

function TCnHighlightLineForm.GetHelpTopic: string;
begin
  Result := 'CnSourceHighlight';
end;

procedure TCnHighlightLineForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
