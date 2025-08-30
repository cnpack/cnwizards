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

unit CnSizeConstraintsEditorFrm;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ��Ľ�Delphi��TSizeConstraints���Ա༭��
* ��Ԫ���ߣ�Chinbo(Shenloqi@hotmail.com)
* ��    ע��
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�ʹ����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2002.07.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, CnCommon, CnConsts, CnDesignEditorConsts,
  CnDesignEditorUtils, CnWizUtils, CnWizMultiLang;

type
  TShenSizeConstraints = record
    MaxHeight,
    MaxWidth,
    MinHeight,
    MinWidth: TConstraintSize;
  end;

  TCnSizeConstraintsEditorForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    lblMXH: TLabel;
    lblMXW: TLabel;
    lblMNH: TLabel;
    lblMNW: TLabel;
    lblNowHeight: TLabel;
    lblNowWidth: TLabel;
    lblOld: TLabel;
    lblNew: TLabel;
    edtMXH: TEdit;
    edtMXW: TEdit;
    edtMNH: TEdit;
    edtMNW: TEdit;
    Panel1: TPanel;
    btnAbout: TButton;
    lblNow: TLabel;
    btnMXH: TSpeedButton;
    btnMXW: TSpeedButton;
    btnMNH: TSpeedButton;
    btnMNW: TSpeedButton;
    btnasMax: TSpeedButton;
    btnasMin: TSpeedButton;
    btnClear: TSpeedButton;
    btnFixed: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    procedure btnAboutClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CopyValue(Sender: TObject);
    procedure editExit(Sender: TObject);
  private
    FSC: TShenSizeConstraints;
    FNowHeight: TConstraintSize;
    FNowWidth: TConstraintSize;
    procedure SetSC(const Value: TShenSizeConstraints);
    procedure SetNowHeight(const Value: TConstraintSize);
    procedure SetNowWidth(const Value: TConstraintSize);
  protected
    function GetHelpTopic: string; override;
  public
    property SC: TShenSizeConstraints read FSC write SetSC;
    property NowHeight: TConstraintSize read FNowHeight write SetNowHeight;
    property NowWidth: TConstraintSize read FNowWidth write SetNowWidth;
  end;

var
  CnSizeConstraintsEditorForm: TCnSizeConstraintsEditorForm;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$R *.DFM}

const
  CRLF = #13#10;

{-----------------------------------------------------------------------------
  Procedure: TfrmSizeConstraintsEditor.btnAboutClick
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.btnAboutClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSizeConstraintsEditorForm.GetHelpTopic: string;
begin
  Result := 'CnSizeConstraintsEditor';
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.btnOKClick
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.btnOKClick(Sender: TObject);
begin
  try
    FSC.MaxHeight := StrToInt(edtMXH.Text);
    FSC.MaxWidth := StrToInt(edtMXW.Text);
    FSC.MinHeight := StrToInt(edtMNH.Text);
    FSC.MinWidth := StrToInt(edtMNW.Text);
    ModalResult := mrOk;
  except
    ShowMessage(SCnSizeConsInputError);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.btnCancelClick
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.FormKeyDown
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject; var Key: Word; Shift: TShiftState
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Ord(Key) = VK_ESCAPE then
  begin
    btnCancel.Click;
    Exit;
  end;
  if (Shift = [ssCtrl]) and (Ord(Key) = VK_RETURN) then
    btnOK.Click;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.SetSC
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: const Value: TSizeConstraints
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.SetSC(const Value: TShenSizeConstraints);
begin
  FSC := Value;
  lblMXH.Caption := Format('%4D', [FSC.MaxHeight]);
  lblMXW.Caption := Format('%4D', [FSC.MaxWidth]);
  lblMNH.Caption := Format('%4D', [FSC.MinHeight]);
  lblMNW.Caption := Format('%4D', [FSC.MinWidth]);
  edtMXH.Text := IntToStr(FSC.MaxHeight);
  edtMXW.Text := IntToStr(FSC.MaxWidth);
  edtMNH.Text := IntToStr(FSC.MinHeight);
  edtMNW.Text := IntToStr(FSC.MinWidth);
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.CopyValue
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.CopyValue(Sender: TObject);
begin
  case TButton(Sender).Tag of
    0: edtMXH.Text := IntToStr(FSC.MaxHeight);
    1: edtMXW.Text := IntToStr(FSC.MaxWidth);
    2: edtMNH.Text := IntToStr(FSC.MinHeight);
    3: edtMNW.Text := IntToStr(FSC.MinWidth);
    4:
      begin
        edtMXH.Text := IntToStr(FNowHeight);
        edtMXW.Text := IntToStr(FNowWidth);
      end;
    5:
      begin
        edtMNH.Text := IntToStr(FNowHeight);
        edtMNW.Text := IntToStr(FNowWidth);
      end;
    6:
      begin
        edtMXH.Text := '0';
        edtMXW.Text := '0';
        edtMNH.Text := '0';
        edtMNW.Text := '0';
      end;
    7:
      begin
        edtMXH.Text := IntToStr(FNowHeight);
        edtMXW.Text := IntToStr(FNowWidth);
        edtMNH.Text := IntToStr(FNowHeight);
        edtMNW.Text := IntToStr(FNowWidth);
      end;
    8:
      begin
        edtMXW.Text := IntToStr(FNowWidth);
        edtMNW.Text := IntToStr(FNowWidth);
      end;
    9:
      begin
        edtMXH.Text := IntToStr(FNowHeight);
        edtMNH.Text := IntToStr(FNowHeight);
      end;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.SetNowHeight
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: const Value: Integer
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.SetNowHeight(const Value: TConstraintSize);
begin
  FNowHeight := Value;
  lblNowHeight.Caption := Format('%4D', [Value]);
end;

{-----------------------------------------------------------------------------
  Procedure: TCnSizeConstraintsEditorForm.SetNowWidth
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: const Value: Integer
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnSizeConstraintsEditorForm.SetNowWidth(const Value: TConstraintSize);
begin
  FNowWidth := Value;
  lblNowWidth.Caption := Format('%4D', [Value]);
end;

procedure TCnSizeConstraintsEditorForm.editExit(Sender: TObject);
var
  TE: TEdit;
  I: TConstraintSize;
  X: Integer;
begin
  TE := Sender as TEdit;
  try
    X := StrToInt(TE.Text);
    if X < 0 then
    begin
      ShowMessage(SCnSizeConsInputNeg);
      TE.SetFocus;
      Exit;
    end;
  except
    ShowMessage(SCnSizeConsInputError);
    TE.SetFocus;
    Exit;
  end;
  I := StrToInt(TE.Text);
  case TE.Tag of
    0:
      begin
        FSC.MaxHeight := I;
      end;
    1:
      begin
        FSC.MaxWidth := I;
      end;
    2:
      begin
        FSC.MinHeight := I;
      end;
    3:
      begin
        FSC.MinWidth := I;
      end;
  end;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.

