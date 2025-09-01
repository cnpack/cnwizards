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

unit CnSrcTemplateEditFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Editor ר�ұ༭���嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���ô��������޸ı༭������
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2002.11.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ActnList,
  StdCtrls, ComCtrls, Buttons, CnSrcTemplate, CnWizConsts, CnCommon, CnWizUtils,
  CnWizManager, CnWizMacroText, CnWizOptions, CnWizMultiLang, CnWizMacroUtils,
  CnHotKey;

type
  TCnSrcTemplateEditForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    OpenDialog: TOpenDialog;
    grp1: TGroupBox;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl7: TLabel;
    btnOpen: TSpeedButton;
    edtHint: TEdit;
    HotKey: THotKey;
    cbbInsertPos: TComboBox;
    edtIcon: TEdit;
    chkDisabled: TCheckBox;
    edtCaption: TEdit;
    chkSavePos: TCheckBox;
    grp2: TGroupBox;
    lbl6: TLabel;
    mmoContent: TMemo;
    cbbMacro: TComboBox;
    btnInsert: TButton;
    chkForDelphi: TCheckBox;
    chkForBcb: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FItemIndex: Integer;
  protected
    function GetHelpTopic: string; override;
  public
    property ItemIndex: Integer read FItemIndex write FItemIndex;
    {* �����Ӧ�� TemplateItem ������������Ѱ�Ҷ�Ӧ Action}
  end;

function ShowEditorEditForm(TemplateItem: TCnTemplateItem): Boolean; overload;
{* ��ʾ�༭��ר�ұ༭���壬���ڱ༭����}

function ShowEditorEditForm(var ACaption, AHint, AIconName: string;
  var AShortCut: TShortCut; var AInsertPos: TCnEditorInsertPos;
  var AEnabled, ASavePos: Boolean; var AContent: string; var AForDelphi,
  AForBcb: Boolean): Boolean; overload;
{* ��ʾ�༭��ר�ұ༭���壬������������}

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}

implementation

{$IFDEF CNWIZARDS_CNSRCTEMPLATE}

{$R *.DFM}

function ShowEditorEditForm(TemplateItem: TCnTemplateItem): Boolean;
begin
  Assert(TemplateItem <> nil);
  with TCnSrcTemplateEditForm.Create(nil) do
  try
    ItemIndex := TemplateItem.Index;
    ShowHint := WizOptions.ShowHint;
    edtCaption.Text := TemplateItem.Caption;
    edtHint.Text := TemplateItem.Hint;
    edtIcon.Text := TemplateItem.IconName;
    HotKey.HotKey := TemplateItem.ShortCut;
    cbbInsertPos.ItemIndex := Ord(TemplateItem.InsertPos);
    chkDisabled.Checked := not TemplateItem.Enabled;
    chkSavePos.Checked := TemplateItem.SavePos;
    mmoContent.Lines.Text := TemplateItem.Content;
    chkForDelphi.Checked := TemplateItem.ForDelphi;
    chkForBcb.Checked := TemplateItem.ForBcb;
    Result := ShowModal = mrOk;

    if Result then
    begin
      TemplateItem.Caption := edtCaption.Text;
      TemplateItem.Hint := edtHint.Text;
      TemplateItem.IconName := edtIcon.Text;
      TemplateItem.ShortCut := HotKey.HotKey;
      TemplateItem.InsertPos := TCnEditorInsertPos(cbbInsertPos.ItemIndex);
      TemplateItem.Enabled := not chkDisabled.Checked;
      TemplateItem.SavePos := chkSavePos.Checked;
      TemplateItem.Content := mmoContent.Lines.Text;
      TemplateItem.ForDelphi := chkForDelphi.Checked;
      TemplateItem.ForBcb := chkForBcb.Checked;
    end;
  finally
    Free;
  end;
end;

function ShowEditorEditForm(var ACaption, AHint, AIconName: string;
  var AShortCut: TShortCut; var AInsertPos: TCnEditorInsertPos;
  var AEnabled, ASavePos: Boolean; var AContent: string; var AForDelphi,
  AForBcb: Boolean): Boolean; overload;
begin
  with TCnSrcTemplateEditForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    edtCaption.Text := ACaption;
    edtHint.Text := AHint;
    edtIcon.Text := AIconName;
    HotKey.HotKey := AShortCut;
    cbbInsertPos.ItemIndex := Ord(AInsertPos);
    chkDisabled.Checked := not AEnabled;
    chkSavePos.Checked := ASavePos;
    mmoContent.Lines.Text := AContent;
    chkForDelphi.Checked := AForDelphi;
    chkForBcb.Checked := AForBcb;
    Result := ShowModal = mrOk;

    if Result then
    begin
      ACaption := edtCaption.Text;
      AHint := edtHint.Text;
      AIconName := edtIcon.Text;
      AShortCut := HotKey.HotKey;
      AInsertPos := TCnEditorInsertPos(cbbInsertPos.ItemIndex);
      AEnabled := not chkDisabled.Checked;
      ASavePos := chkSavePos.Checked;
      AContent := mmoContent.Lines.Text;
      AForDelphi := chkForDelphi.Checked;
      AForBcb := chkForBcb.Checked;
    end;
  finally
    Free;
  end;
end;

{ TCnSrcTemplateEditForm }

procedure TCnSrcTemplateEditForm.FormCreate(Sender: TObject);
var
  InsertPos: TCnEditorInsertPos;
  Macro: TCnWizMacro;
begin
  ItemIndex := -1;
  cbbInsertPos.Clear;

  for InsertPos := Low(InsertPos) to High(InsertPos) do
    cbbInsertPos.Items.Add(csEditorInsertPosDescs[InsertPos]^);
  cbbInsertPos.ItemIndex := 0;
  cbbMacro.Clear;

  for Macro := Low(Macro) to High(Macro) do
    cbbMacro.Items.Add(Format('%s - %s', [GetMacroEx(Macro),
      csCnWizMacroDescs[Macro]^]));
  cbbMacro.ItemIndex := 0;
end;

procedure TCnSrcTemplateEditForm.btnInsertClick(Sender: TObject);
var
  I: Integer;
  Macro: string;
begin
  if cbbMacro.ItemIndex >= 0 then
  begin
    Macro := GetMacro(GetMacroDefText(TCnWizMacro(cbbMacro.ItemIndex)));
{$IFDEF FPC}
    I := mmoContent.SelStart;
    mmoContent.SelText := Macro;
    mmoContent.SelStart := I + Length(Macro);
{$ELSE}
    for I := 1 to Length(Macro) do
      mmoContent.Perform(WM_CHAR, Ord(Macro[I]), 0);
{$ENDIF}
  end;

  mmoContent.SetFocus;
end;

procedure TCnSrcTemplateEditForm.btnOKClick(Sender: TObject);
begin
  if edtCaption.Text = '' then
    ErrorDlg(SCnSrcTemplateCaptionIsEmpty)
  else if mmoContent.Lines.Text = '' then
    ErrorDlg(SCnSrcTemplateContentIsEmpty)
  else
    ModalResult := mrOk;
end;

procedure TCnSrcTemplateEditForm.btnOpenClick(Sender: TObject);
begin
  OpenDialog.FileName := edtIcon.Text;
  if OpenDialog.Execute then
    edtIcon.Text := OpenDialog.FileName;
end;

procedure TCnSrcTemplateEditForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSrcTemplateEditForm.GetHelpTopic: string;
begin
  Result := 'CnSrcTemplate';
end;

procedure TCnSrcTemplateEditForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Wizard: TCnSrcTemplate;
begin
  CanClose := True;
  if ModalResult <> mrOK then
    Exit;

  Wizard := nil;
  if CnWizardMgr.WizardByClass(TCnSrcTemplate) <> nil then
  begin
    if CnWizardMgr.WizardByClass(TCnSrcTemplate) is TCnSrcTemplate then
      Wizard := TCnSrcTemplate(CnWizardMgr.WizardByClass(TCnSrcTemplate));
  end;

  if Wizard = nil then
    Exit;

  if ItemIndex < 0 then // ��ʾ��ԭʼ Action�����½�����
  begin
    if CheckQueryShortCutDuplicated(HotKey.HotKey, nil) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end
  else
  begin
    if CheckQueryShortCutDuplicated(HotKey.HotKey, // �˵�������ǰ����һ����á����� 1 ��ƫ����
      TCustomAction(Wizard.SubActions[ItemIndex + 1])) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCTEMPLATE}
end.
