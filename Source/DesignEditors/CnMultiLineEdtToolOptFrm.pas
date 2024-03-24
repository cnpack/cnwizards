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

unit CnMultiLineEdtToolOptFrm;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：字符串编辑器辅助工具设置窗体
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：
*           2003.10.29
*               增加去除引用分隔字符串选项
*           2003.10.18
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, ComCtrls, StdCtrls, ExtCtrls, CnMultiLineEditorFrm,
  CnSpin;

type
  TCnMultiLineEditorToolsOptionForm = class(TCnTranslateForm)
    pgc1: TPageControl;
    tsQuoted: TTabSheet;
    tsSQLFormatter: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    grpSQLIndent: TGroupBox;
    grpSQLCase: TGroupBox;
    tsLineMove: TTabSheet;
    lbl1: TLabel;
    edtQuotedChar: TEdit;
    lbl2: TLabel;
    edtLineSep: TEdit;
    lbl3: TLabel;
    chkMoveReplaceTab: TCheckBox;
    lbl4: TLabel;
    lbl5: TLabel;
    cbb1: TComboBox;
    lbl6: TLabel;
    cbb2: TComboBox;
    lbl7: TLabel;
    cbb3: TComboBox;
    lbl8: TLabel;
    cbb4: TComboBox;
    seMoveSpaces: TCnSpinEdit;
    seTabAsSpaces: TCnSpinEdit;
    lbl9: TLabel;
    edtUnQuotedSep: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure chkMoveReplaceTabClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtQuotedCharExit(Sender: TObject);
  private
    { Private declarations }
    FToolsOption: TToolsOpt;
  public
    { Public declarations }
    property ToolsOption: TToolsOpt read FToolsOption write FToolsOption;
  end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$R *.DFM}

{$DEFINE ITR} //In The Rough

procedure TCnMultiLineEditorToolsOptionForm.FormCreate(Sender: TObject);
begin
  inherited;
{$IFDEF ITR}
  tsSQLFormatter.TabVisible := False;
{$ENDIF ITR}
end;

procedure TCnMultiLineEditorToolsOptionForm.chkMoveReplaceTabClick(Sender: TObject);
begin
  lbl4.Enabled := chkMoveReplaceTab.Checked;
  seTabAsSpaces.Enabled := chkMoveReplaceTab.Checked;
end;

procedure TCnMultiLineEditorToolsOptionForm.FormShow(Sender: TObject);
begin
  inherited;
  edtQuotedChar.Text := ToolsOption.QuotedChar;
  edtUnQuotedSep.Text := ToolsOption.UnQuotedSep;
  edtLineSep.Text := ToolsOption.SingleLineSep;
  seMoveSpaces.Value := ToolsOption.LineMoveSpaces;
  chkMoveReplaceTab.Checked := ToolsOption.MoveReplaceTab;
  seTabAsSpaces.Value := ToolsOption.MoveTabAsSpace;

  chkMoveReplaceTabClick(chkMoveReplaceTab);
end;

procedure TCnMultiLineEditorToolsOptionForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;
  FToolsOption.QuotedChar := edtQuotedChar.Text[1];
  FToolsOption.UnQuotedSep := edtUnQuotedSep.Text;
  FToolsOption.SingleLineSep := edtLineSep.Text;
  FToolsOption.LineMoveSpaces := seMoveSpaces.Value;
  FToolsOption.MoveReplaceTab := chkMoveReplaceTab.Checked;
  FToolsOption.MoveTabAsSpace := seTabAsSpaces.Value;
end;

procedure TCnMultiLineEditorToolsOptionForm.edtQuotedCharExit(
  Sender: TObject);
begin
  if edtQuotedChar.Text = '' then
    edtQuotedChar.Text := #39;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
