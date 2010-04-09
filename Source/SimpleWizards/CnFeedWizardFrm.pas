{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnFeedWizardFrm;

interface
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：RSS 专家单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: $
* 修改记录：2010.04.08
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFEEDWIZARD}

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
    FWizard: TCnFeedWizard;
    FFeedCfg: TCnFeedCfg;
    procedure SetToControl;
    procedure GetFromControl;
  public
    { Public declarations }
  end;

function ShowCnFeedWizardForm(Wizard: TCnFeedWizard): Boolean;

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

implementation

{$IFDEF CNWIZARDS_CNFEEDWIZARD}

const
  SCnFeedNewItem = 'New Item';

{$R *.dfm}

function ShowCnFeedWizardForm(Wizard: TCnFeedWizard): Boolean;
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
end;

procedure TCnFeedWizardForm.FormDestroy(Sender: TObject);
begin
  FFeedCfg.Free;
end;

procedure TCnFeedWizardForm.FormShow(Sender: TObject);
begin
  FFeedCfg.Assign(FWizard.FeedCfg);
  lvList.Items.Count := FFeedCfg.Count;
  if FFeedCfg.Count > 0 then
    lvList.ItemIndex := 0;
  SetToControl;
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
begin
  if FUpdating then Exit;

  FUpdating := True;
  try
    if lvList.ItemIndex >= 0 then
    begin
      FFeedCfg[lvList.ItemIndex].Caption := Trim(edtCaption.Text);
      FFeedCfg[lvList.ItemIndex].Url := Trim(edtUrl.Text);
      FFeedCfg[lvList.ItemIndex].CheckPeriod := sePeriod.Value;
      FFeedCfg[lvList.ItemIndex].Limit := seLimit.Value;
      lvList.UpdateItems(lvList.ItemIndex, lvList.ItemIndex);
    end;
  finally
    FUpdating := False;
  end;          
end;

procedure TCnFeedWizardForm.SetToControl;
begin
  if FUpdating then Exit;

  FUpdating := True;
  try
    if lvList.ItemIndex >= 0 then
    begin
      edtCaption.Text := FFeedCfg[lvList.ItemIndex].Caption;
      edtUrl.Text := FFeedCfg[lvList.ItemIndex].Url;
      sePeriod.Value := FFeedCfg[lvList.ItemIndex].CheckPeriod;
      seLimit.Value := FFeedCfg[lvList.ItemIndex].Limit;
    end
    else
    begin
      edtCaption.Text := '';
      edtUrl.Text := '';
      sePeriod.Value := 1;
      seLimit.Value := 0;
    end;
    edtCaption.Enabled := lvList.ItemIndex >= 0;
    edtUrl.Enabled := lvList.ItemIndex >= 0;
    sePeriod.Enabled := lvList.ItemIndex >= 0;
    seLimit.Enabled := lvList.ItemIndex >= 0;
  finally
    FUpdating := False;
  end;
end;

procedure TCnFeedWizardForm.edtCaptionChange(Sender: TObject);
begin
  GetFromControl;
end;

procedure TCnFeedWizardForm.btnAddClick(Sender: TObject);
var
  GUID: TGUID;
begin
  with FFeedCfg.Add do
  begin
    Caption := SCnFeedNewItem;
    CreateGUID(GUID);
    IDStr := GUIDToString(GUID);
    CheckPeriod := 60;
    Limit := 20;
  end;
  lvList.Items.Count := FFeedCfg.Count;
  lvList.ItemIndex := FFeedCfg.Count - 1;
  SetToControl;
end;

procedure TCnFeedWizardForm.btnDeleteClick(Sender: TObject);
begin
  if (lvList.ItemIndex >= 0) and QueryDlg(SCnDeleteConfirm) then
  begin
    FFeedCfg.Delete(lvList.ItemIndex);
    lvList.Items.Count := FFeedCfg.Count;
    if FFeedCfg.Count > 0 then
      lvList.ItemIndex := 0;
    SetToControl;
  end;
end;

procedure TCnFeedWizardForm.btnOKClick(Sender: TObject);
begin
  FWizard.FeedCfg.Assign(FFeedCfg);
  ModalResult := mrOk;
end;

{$ENDIF CNWIZARDS_CNCOMPONENTSELECTOR}

end.
