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

unit CnBookmarkConfigFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：书签管理工具设置窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2002.11.24 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNBOOKMARKWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnSpin, CnWizOptions, CnWizMultiLang;

type
  TCnBookmarkConfigForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    gbBrowse: TGroupBox;
    btnSourceFont: TButton;
    btnHighlightFont: TButton;
    Label1: TLabel;
    Label2: TLabel;
    gwBookmark: TGroupBox;
    cbSaveBookmark: TCheckBox;
    SourceFontDialog: TFontDialog;
    HighlightFontDialog: TFontDialog;
    chkAutoRefresh: TCheckBox;
    seDispLines: TCnSpinEdit;
    lbl1: TLabel;
    seInterval: TCnSpinEdit;
    lbl2: TLabel;
    ListFontDialog: TFontDialog;
    btnListFont: TButton;
    procedure btnSourceFontClick(Sender: TObject);
    procedure btnHighlightFontClick(Sender: TObject);
    procedure seDispLinesKeyPress(Sender: TObject; var Key: Char);
    procedure btnListFontClick(Sender: TObject);
  private

  public

  end;

function ShowBookmarkConfigForm(var DispLines: Integer; var SaveBookmark,
  AutoRefresh: Boolean; var Interval: Integer; SourceFont, HighlightFont, ListFont:
  TFont): Boolean;

{$ENDIF CNWIZARDS_CNBOOKMARKWIZARD}

implementation

{$IFDEF CNWIZARDS_CNBOOKMARKWIZARD}

{$R *.DFM}

function ShowBookmarkConfigForm(var DispLines: Integer; var SaveBookmark,
  AutoRefresh: Boolean; var Interval: Integer; SourceFont, HighlightFont,
  ListFont: TFont): Boolean;
begin
  with TCnBookmarkConfigForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    seDispLines.Value := DispLines;
    cbSaveBookmark.Checked := SaveBookmark;
    chkAutoRefresh.Checked := AutoRefresh;
    seInterval.Value := Interval;
    SourceFontDialog.Font.Assign(SourceFont);
    HighlightFontDialog.Font.Assign(HighlightFont);
    ListFontDialog.Font.Assign(ListFont);
    Result := ShowModal = mrOk;
    if Result then
    begin
      DispLines := seDispLines.Value;
      SaveBookmark := cbSaveBookmark.Checked;
      AutoRefresh := chkAutoRefresh.Checked;
      Interval := seInterval.Value;
      SourceFont.Assign(SourceFontDialog.Font);
      HighlightFont.Assign(HighlightFontDialog.Font);
      ListFont.Assign(ListFontDialog.Font);
    end;
  finally
    Free;
  end;
end;

procedure TCnBookmarkConfigForm.btnSourceFontClick(Sender: TObject);
begin
  SourceFontDialog.Execute;
end;

procedure TCnBookmarkConfigForm.btnHighlightFontClick(Sender: TObject);
begin
  HighlightFontDialog.Execute;
end;

procedure TCnBookmarkConfigForm.seDispLinesKeyPress(Sender: TObject;
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


procedure TCnBookmarkConfigForm.btnListFontClick(Sender: TObject);
begin
  ListFontDialog.Execute;
end;

{$ENDIF CNWIZARDS_CNBOOKMARKWIZARD}
end.
