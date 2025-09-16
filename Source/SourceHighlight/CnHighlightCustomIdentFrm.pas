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

unit CnHighlightCustomIdentFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭���Զ��������ʶ�����ô���
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.02.23
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, ActnList, ToolWin, CnWizOptions,
  CnConsts, CnWizConsts, CnWizUtils, CnLangMgr, CnWizMultiLang, CnWizShareImages;

type
  TCnHighlightCustomIdentForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    dlgColor: TColorDialog;
    actlstCustom: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    grpCustom: TGroupBox;
    lvIdents: TListView;
    lblCurTokenFg: TLabel;
    shpCustomFg: TShape;
    lblCurTokenBg: TLabel;
    shpCustomBg: TShape;
    tlb1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    chkBkTransparent: TCheckBox;
    procedure shpCustomColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actlstCustomUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actDeleteExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure lvIdentsDblClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadFromStringList(List: TStringList);
    procedure SaveToStringList(List: TStringList);
  end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  CnCommon;

{$R *.DFM}

procedure TCnHighlightCustomIdentForm.shpCustomColorMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TShape then
  begin
    dlgColor.Color := TShape(Sender).Brush.Color;
    if dlgColor.Execute then
      TShape(Sender).Brush.Color := dlgColor.Color;
  end;
end;

procedure TCnHighlightCustomIdentForm.actlstCustomUpdate(
  Action: TBasicAction; var Handled: Boolean);
begin
  if Action = actDelete then
  begin
    (Action as TAction).Enabled := lvIdents.Selected <> nil;
    Handled := True;
  end;
end;

procedure TCnHighlightCustomIdentForm.actDeleteExecute(Sender: TObject);
begin
  if lvIdents.Selected <> nil then
  begin
    if QueryDlg(SCnSourceHighlightCustomIdentConfirm, False, SCnInformation) then
    begin
      lvIdents.Items.Delete(lvIdents.Selected.Index);
      lvIdents.Invalidate;
    end;
  end;
end;

procedure TCnHighlightCustomIdentForm.actAddExecute(Sender: TObject);
var
  S: string;
  Item: TListItem;
begin
  S := CnWizInputBox(SCnInformation, SCnSourceHighlightCustomIdentHint, '');

  if Trim(S) <> '' then
  begin
    Item := lvIdents.Items.Add;
    Item.Caption := '';
    Item.SubItems.Add(Trim(S));

    lvIdents.Invalidate;
  end;
end;

procedure TCnHighlightCustomIdentForm.LoadFromStringList(
  List: TStringList);
var
  I: Integer;
  Item: TListItem;
begin
  lvIdents.Items.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Item := lvIdents.Items.Add;
    Item.Caption := '';
    Item.SubItems.Add(List[I]);

    Item.Checked := List.Objects[I] <> nil;
  end;
end;

procedure TCnHighlightCustomIdentForm.SaveToStringList(List: TStringList);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to lvIdents.Items.Count - 1 do
  begin
    if lvIdents.Items[I].Checked then
      List.AddObject(lvIdents.Items[I].SubItems[0], TObject(1))
    else
      List.Add(lvIdents.Items[I].SubItems[0]);
  end;
end;

procedure TCnHighlightCustomIdentForm.lvIdentsDblClick(Sender: TObject);
var
  S: string;
begin
  if lvIdents.Selected <> nil then
  begin
    S := lvIdents.Selected.SubItems[0];
    S := CnWizInputBox(SCnInformation, SCnSourceHighlightCustomIdentHint, S);
    if S <> '' then
      lvIdents.Selected.SubItems[0] := Trim(S);
  end;
end;

function TCnHighlightCustomIdentForm.GetHelpTopic: string;
begin
  Result := 'CnSourceHighlight';
end;

procedure TCnHighlightCustomIdentForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnHighlightCustomIdentForm.FormCreate(Sender: TObject);
begin
  WizOptions.ResetToolbarWithLargeIcons(tlb1);
end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
