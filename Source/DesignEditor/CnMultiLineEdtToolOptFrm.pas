{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnMultiLineEdtToolOptFrm;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ��ַ����༭�������������ô���
* ��Ԫ���ߣ�Chinbo(Shenloqi@hotmail.com)
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��
*           2003.10.29
*               ����ȥ�����÷ָ��ַ���ѡ��
*           2003.10.18
*               ������Ԫ
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
    FToolsOption: TCnToolsOpt;
  public
    property ToolsOption: TCnToolsOpt read FToolsOption write FToolsOption;
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
