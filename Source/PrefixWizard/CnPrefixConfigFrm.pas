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

unit CnPrefixConfigFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ǰ׺ר�����ô��嵥Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע�����ǰ׺ר�����ô��嵥Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.09.05 V1.3
*               ������������ʱʹ�ø���ǰ׺��ѡ��
*           2023.02.21 V1.2
*               ���� F2 ������ѡ��
*           2003.05.11 V1.1
*               �����»���ѡ��
*           2003.04.26 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnPrefixList, CnWizIdeUtils, CnCommon, CnWizUtils,
  CnWizConsts, CnWizOptions, CnWizMultiLang, CnPrefixWizard, ExtCtrls;

type

{ TCnPrefixConfigForm }

  TCnPrefixConfigForm = class(TCnTranslateForm)
    grpConfig: TGroupBox;
    gbList: TGroupBox;
    cbAutoPopSuggestDlg: TCheckBox;
    cbPopPrefixDefine: TCheckBox;
    ListView: TListView;
    cbAllowClassName: TCheckBox;
    lbl1: TLabel;
    edtPrefix: TEdit;
    btnModify: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    btnImport: TButton;
    btnExport: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    lbl2: TLabel;
    cbAutoPrefix: TCheckBox;
    cbDelOldPrefix: TCheckBox;
    cbUseUnderLine: TCheckBox;
    cbPrefixCaseSens: TCheckBox;
    chkUseActionName: TCheckBox;
    chkWatchActionLink: TCheckBox;
    chkUseFieldName: TCheckBox;
    chkWatchFieldLink: TCheckBox;
    chkF2Rename: TCheckBox;
    bvl1: TBevel;
    chkUseAncestor: TCheckBox;
    procedure ListViewClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtPrefixKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure cbAutoPrefixClick(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCreate(Sender: TObject);
  private
    FList: TCnPrefixList;
    FSortIndex: Integer;
    FSortDown: Boolean;
    procedure GetListFromListView(List: TCnPrefixList);
    procedure SetListToListView(List: TCnPrefixList);
  protected
    function GetHelpTopic: string; override;
  public

  end;

// ��ʾ���ô���
function ShowPrefixConfigForm(Wizard: TCnPrefixWizard): Boolean;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{$R *.DFM}

function ShowPrefixConfigForm(Wizard: TCnPrefixWizard): Boolean;
begin
  with TCnPrefixConfigForm.Create(nil) do
  try
    cbAutoPrefix.Checked := Wizard.AutoPrefix;
    cbAutoPopSuggestDlg.Checked := Wizard.AutoPopSuggestDlg;
    cbPopPrefixDefine.Checked := Wizard.PopPrefixDefine;
    cbAllowClassName.Checked := Wizard.AllowClassName;
    cbDelOldPrefix.Checked := Wizard.DelOldPrefix;
    cbUseUnderLine.Checked := Wizard.UseUnderLine;
    cbPrefixCaseSens.Checked := Wizard.PrefixCaseSensitive;
    chkUseActionName.Checked := Wizard.UseActionName;
    chkWatchActionLink.Checked := Wizard.WatchActionLink;
    chkUseFieldName.Checked := Wizard.UseFieldName;
    chkWatchFieldLink.Checked := Wizard.WatchFieldLink;
    chkF2Rename.Checked := Wizard.F2Rename;
    chkUseAncestor.Checked := Wizard.UseAncestor;
    FList := Wizard.PrefixList;

    Result := ShowModal = mrOk;

    if Result then
    begin
      Wizard.AutoPrefix := cbAutoPrefix.Checked;
      Wizard.AutoPopSuggestDlg := cbAutoPopSuggestDlg.Checked;
      Wizard.PopPrefixDefine := cbPopPrefixDefine.Checked;
      Wizard.AllowClassName := cbAllowClassName.Checked;
      Wizard.DelOldPrefix := cbDelOldPrefix.Checked;
      Wizard.UseUnderLine := cbUseUnderLine.Checked;
      Wizard.PrefixCaseSensitive := cbPrefixCaseSens.Checked;
      Wizard.UseActionName := chkUseActionName.Checked;
      Wizard.WatchActionLink := chkWatchActionLink.Checked;
      Wizard.UseFieldName := chkUseFieldName.Checked;
      Wizard.WatchFieldLink := chkWatchFieldLink.Checked;
      Wizard.F2Rename := chkF2Rename.Checked;
      Wizard.UseAncestor := chkUseAncestor.Checked;

      Wizard.DoSaveSettings;
    end;
  finally
    Free;
  end;
end;

{ TCnPrefixConfigForm }

procedure TCnPrefixConfigForm.FormShow(Sender: TObject);
begin
  FSortIndex := 0;
  FSortDown := False;
  cbAutoPrefixClick(nil);
  SetListToListView(FList);
end;

procedure TCnPrefixConfigForm.GetListFromListView(List: TCnPrefixList);
var
  I: Integer;
begin
  for I := 0 to ListView.Items.Count - 1 do
  begin
    List.Prefixs[ListView.Items[I].Caption] := ListView.Items[I].SubItems[0];
    List.Ignore[ListView.Items[I].Caption] := not ListView.Items[I].Checked;
  end;
end;

procedure TCnPrefixConfigForm.SetListToListView(List: TCnPrefixList);
var
  CompList: TStringList;
  I: Integer;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    
    CompList := TStringList.Create;
    try
      CompList.Sorted := True;
      GetInstalledComponents(nil, CompList);
      for I := 0 to CnNoIconList.Count - 1 do
        CompList.Add(CnNoIconList[I]);

      // ���������
      CompList.Add('TComponent');
      CompList.Add('TControl');
      CompList.Add('TWinControl');
        
      for I := 0 to CompList.Count - 1 do
      begin
        with ListView.Items.Add do
        begin
          Caption := CompList[I];
          Checked := not List.Ignore[CompList[I]];
          SubItems.Add(List.Prefixs[CompList[I]]);
        end;
      end;

      if ListView.Items.Count > 0 then
        ListView.Selected := ListView.Items[0];
      ListViewClick(nil);
    finally
      CompList.Free;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TCnPrefixConfigForm.cbAutoPrefixClick(Sender: TObject);
begin
  cbAutoPopSuggestDlg.Enabled := cbAutoPrefix.Checked;
  cbPopPrefixDefine.Enabled := cbAutoPrefix.Checked;
  cbAllowClassName.Enabled := cbAutoPrefix.Checked;
  cbDelOldPrefix.Enabled := cbAutoPrefix.Checked;
  cbUseUnderLine.Enabled := cbAutoPrefix.Checked;
  cbPrefixCaseSens.Enabled := cbAutoPrefix.Checked;
  chkUseActionName.Enabled := cbAutoPrefix.Checked;
  chkWatchActionLink.Enabled := cbAutoPrefix.Checked and chkUseActionName.Checked;
  chkUseFieldName.Enabled := cbAutoPrefix.Checked;
  chkWatchFieldLink.Enabled := cbAutoPrefix.Checked and chkUseFieldName.Checked;
end;

procedure TCnPrefixConfigForm.ListViewClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    edtPrefix.Enabled := True;
    btnModify.Enabled := True;
    edtPrefix.Text := ListView.Selected.SubItems[0];
  end
  else
  begin
    edtPrefix.Enabled := False;
    btnModify.Enabled := False;
    edtPrefix.Text := '';
  end;
end;

procedure TCnPrefixConfigForm.btnModifyClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    if (edtPrefix.Text = '') or IsValidIdent(edtPrefix.Text) then
      ListView.Selected.SubItems[0] := edtPrefix.Text
    else
      ErrorDlg(SCnPrefixInputError);
  end;
end;

procedure TCnPrefixConfigForm.btnExportClick(Sender: TObject);
var
  AList: TCnPrefixList;
begin
  if SaveDialog.FileName = '' then
    SaveDialog.FileName := WizOptions.GetUserFileName(SCnPrefixDataName, False);
  if SaveDialog.Execute then
  begin
    AList := TCnPrefixList.Create;
    try
      GetListFromListView(AList);
      AList.SaveToFile(SaveDialog.FileName);
    finally
      AList.Free;
    end;
  end;
end;

procedure TCnPrefixConfigForm.btnImportClick(Sender: TObject);
var
  AList: TCnPrefixList;
begin
  if OpenDialog.FileName = '' then
    OpenDialog.FileName := WizOptions.GetUserFileName(SCnPrefixDataName, True);
  if OpenDialog.Execute then
  begin
    AList := TCnPrefixList.Create;
    try
      AList.LoadFromFile(OpenDialog.FileName);
      SetListToListView(AList);
    finally
      AList.Free;
    end;
  end;
end;

procedure TCnPrefixConfigForm.edtPrefixKeyPress(Sender: TObject;
  var Key: Char);
const
  Chars = ['A'..'Z', 'a'..'z', '_', '0'..'9', #03, #08, #22];
begin
  if Key = #13 then
  begin
    btnModifyClick(nil);
    if (edtPrefix.Text = '') or IsValidIdent(edtPrefix.Text) then
      if ListView.Selected.Index < ListView.Items.Count - 1 then
      begin
        ListView.Selected := ListView.Items[ListView.Selected.Index + 1];
        ListViewClick(nil);
        edtPrefix.SetFocus;
      end;
    Key := #0;
  end
  else if not CharInSet(Key, Chars) then
    Key := #0;
end;

procedure TCnPrefixConfigForm.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;
  ListView.CustomSort(nil, 0);
end;

procedure TCnPrefixConfigForm.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if FSortIndex = 0 then
    Compare := CompareText(Item1.Caption, Item2.Caption)
  else
    Compare := CompareText(Item1.SubItems[0], Item2.SubItems[0]);
  if FSortDown then
    Compare := -Compare;
end;

procedure TCnPrefixConfigForm.ListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  ListViewClick(nil);
end;

procedure TCnPrefixConfigForm.btnOKClick(Sender: TObject);
begin
  GetListFromListView(FList);
  ModalResult := mrOk;
end;

procedure TCnPrefixConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPrefixConfigForm.GetHelpTopic: string;
begin
  Result := 'CnPrefixConfigForm';
end;

procedure TCnPrefixConfigForm.FormCreate(Sender: TObject);
begin
  EnlargeListViewColumns(ListView);
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.

