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

unit CnFeedWizardFrm;

interface
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�RSS ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP SP3 + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2010.04.08
*               ������Ԫ
================================================================================
|</PRE>}

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFEEDREADERWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ActiveX,
  Dialogs, CnWizMultiLang, StdCtrls, CnFeedWizard, ComCtrls, CnSpin, CnCommon,
  CnConsts, CnWizConsts;

type
  TCnFeedWizardForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    grpFeeds: TGroupBox;
    lvList: TListView;
    lbl1: TLabel;
    edtCaption: TEdit;
    lbl2: TLabel;
    edtUrl: TEdit;
    lbl3: TLabel;
    sePeriod: TCnSpinEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    seLimit: TCnSpinEdit;
    lbl6: TLabel;
    btnAdd: TButton;
    btnDelete: TButton;
    grp1: TGroupBox;
    lbl7: TLabel;
    seChangePeriod: TCnSpinEdit;
    lbl8: TLabel;
    chkSubCnPackChannels: TCheckBox;
    chkRandomDisplay: TCheckBox;
    lbl9: TLabel;
    mmoFilter: TMemo;
    chkSubPartnerChannels: TCheckBox;
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListData(Sender: TObject; Item: TListItem);
    procedure lvListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvListClick(Sender: TObject);
    procedure edtCaptionChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    FUpdating: Boolean;
    FWizard: TCnFeedReaderWizard;
    FFeedCfg: TCnFeedCfg;
    procedure SetToControl;
    procedure GetFromControl;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

function ShowCnFeedWizardForm(Wizard: TCnFeedReaderWizard): Boolean;

{$ENDIF CNWIZARDS_CNFEEDREADERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFEEDREADERWIZARD}

{$R *.DFM}

function ShowCnFeedWizardForm(Wizard: TCnFeedReaderWizard): Boolean;
begin
  with TCnFeedWizardForm.Create(nil) do
  try
    FWizard := Wizard;
    Result := ShowModal = mrOk;
  finally
    Free;
  end;   
end;  

procedure TCnFeedWizardForm.FormCreate(Sender: TObject);
begin
  FFeedCfg := TCnFeedCfg.Create;
  EnlargeListViewColumns(lvList);
end;

procedure TCnFeedWizardForm.FormDestroy(Sender: TObject);
begin
  FFeedCfg.Free;
end;

procedure TCnFeedWizardForm.FormShow(Sender: TObject);
begin
  mmoFilter.Lines.CommaText := FWizard.Filter;
  seChangePeriod.Value := FWizard.ChangePeriod;
  chkSubCnPackChannels.Checked := FWizard.SubCnPackChannels;
  chkSubPartnerChannels.Checked := FWizard.SubPartnerChannels;
  chkRandomDisplay.Checked := FWizard.RandomDisplay;
  FFeedCfg.Assign(FWizard.FeedCfg);
  lvList.Items.Count := FFeedCfg.Count;
  if FFeedCfg.Count > 0 then
    lvList.Selected := lvList.Items[0];
  SetToControl;
end;

function TCnFeedWizardForm.GetHelpTopic: string;
begin
  Result := 'CnFeedReaderWizard';
end;

procedure TCnFeedWizardForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnFeedWizardForm.lvListData(Sender: TObject; Item: TListItem);
begin
  if (Item.Index >= 0) and (Item.Index < FFeedCfg.Count) then
  begin
    Item.Caption := FFeedCfg[Item.Index].Caption;
    Item.SubItems.Clear;
    Item.SubItems.Add(FFeedCfg[Item.Index].Url);
    Item.SubItems.Add(IntToStr(FFeedCfg[Item.Index].CheckPeriod));
    Item.SubItems.Add(IntToStr(FFeedCfg[Item.Index].Limit));
  end;
end;

procedure TCnFeedWizardForm.lvListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  SetToControl;
end;

procedure TCnFeedWizardForm.lvListClick(Sender: TObject);
begin
  SetToControl;
end;

procedure TCnFeedWizardForm.GetFromControl;
var
  Idx: Integer;
begin
  if FUpdating then Exit;

  FUpdating := True;
  try
    if lvList.Selected <> nil then
    begin
      Idx := lvList.Selected.Index;
      FFeedCfg[Idx].Caption := Trim(edtCaption.Text);
      FFeedCfg[Idx].Url := Trim(edtUrl.Text);
      FFeedCfg[Idx].CheckPeriod := sePeriod.Value;
      FFeedCfg[Idx].Limit := seLimit.Value;
      lvList.UpdateItems(Idx, Idx);
    end;
  finally
    FUpdating := False;
  end;          
end;

procedure TCnFeedWizardForm.SetToControl;
var
  Idx: Integer;
begin
  if FUpdating then Exit;

  FUpdating := True;
  try
    if lvList.Selected <> nil then
    begin
      Idx := lvList.Selected.Index;
      edtCaption.Text := FFeedCfg[Idx].Caption;
      edtUrl.Text := FFeedCfg[Idx].Url;
      sePeriod.Value := FFeedCfg[Idx].CheckPeriod;
      seLimit.Value := FFeedCfg[Idx].Limit;
    end
    else
    begin
      edtCaption.Text := '';
      edtUrl.Text := '';
      sePeriod.Value := 1;
      seLimit.Value := 0;
    end;
    edtCaption.Enabled := lvList.Selected <> nil;
    edtUrl.Enabled := lvList.Selected <> nil;
    sePeriod.Enabled := lvList.Selected <> nil;
    seLimit.Enabled := lvList.Selected <> nil;
  finally
    FUpdating := False;
  end;
end;

procedure TCnFeedWizardForm.edtCaptionChange(Sender: TObject);
begin
  GetFromControl;
end;

procedure TCnFeedWizardForm.btnAddClick(Sender: TObject);
begin
  with FFeedCfg.Add do
  begin
    Caption := SCnFeedNewItem;
    IDStr := CreateGuidString;
    CheckPeriod := 60;
    Limit := 20;
  end;
  lvList.Items.Count := FFeedCfg.Count;
  lvList.Selected := lvList.Items[FFeedCfg.Count - 1];
  SetToControl;
end;

procedure TCnFeedWizardForm.btnDeleteClick(Sender: TObject);
begin
  if (lvList.Selected <> nil) and QueryDlg(SCnDeleteConfirm) then
  begin
    FFeedCfg.Delete(lvList.Selected.Index);
    lvList.Items.Count := FFeedCfg.Count;
    if FFeedCfg.Count > 0 then
      lvList.Selected := lvList.Items[0]
    else
      lvList.Invalidate;
    SetToControl;
  end;
end;

procedure TCnFeedWizardForm.btnOKClick(Sender: TObject);
begin
  FWizard.ChangePeriod := seChangePeriod.Value;
  FWizard.SubCnPackChannels := chkSubCnPackChannels.Checked;
  FWizard.SubPartnerChannels := chkSubPartnerChannels.Checked;
  FWizard.RandomDisplay := chkRandomDisplay.Checked;
  FWizard.Filter := Trim(mmoFilter.Lines.CommaText);
  GetFromControl;
  FWizard.FeedCfg.Assign(FFeedCfg);
  ModalResult := mrOk;
end;

{$ENDIF CNWIZARDS_CNFEEDREADERWIZARD}

end.
