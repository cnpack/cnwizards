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

unit CnInputHelperEditFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：输入助手专家符号编辑窗体
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：PWinXP XP2 + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2005.06.03
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINPUTHELPER}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, CnWizConsts, StdCtrls, CnCommon, CnInputSymbolList,
  CnSpin;

type
  TCnInputHelperEditForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    lbl1: TLabel;
    edtName: TEdit;
    lbl2: TLabel;
    edtDesc: TEdit;
    lbl3: TLabel;
    cbbKind: TComboBox;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    chkAutoIndent: TCheckBox;
    lbl4: TLabel;
    seScope: TCnSpinEdit;
    lbl5: TLabel;
    chkAlwaysDisp: TCheckBox;
    chkForPascal: TCheckBox;
    chkForCpp: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbbKindChange(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

function CnShowInputHelperEditForm(var AName, ADesc: string;
  var AKind: TSymbolKind; var Scope: Integer; var AutoIndent,
  AlwaysDisp, ForPascal, ForCpp: Boolean): Boolean;

{$ENDIF CNWIZARDS_CNINPUTHELPER}

implementation

{$IFDEF CNWIZARDS_CNINPUTHELPER}

{$R *.DFM}

function CnShowInputHelperEditForm(var AName, ADesc: string;
  var AKind: TSymbolKind; var Scope: Integer; var AutoIndent,
  AlwaysDisp, ForPascal, ForCpp: Boolean): Boolean;
begin
  with TCnInputHelperEditForm.Create(Application) do
  try
    edtName.Text := AName;
    edtDesc.Text := ADesc;
    cbbKind.ItemIndex := Ord(AKind);
    seScope.Value := Scope;
    chkAutoIndent.Checked := AutoIndent;
    chkAlwaysDisp.Checked := AlwaysDisp;
    chkForPascal.Checked := ForPascal;
    chkForCpp.Checked := ForCpp;
    cbbKindChange(nil);

    Result := ShowModal = mrOk;
    if Result then
    begin
      AName := Trim(edtName.Text);
      ADesc := Trim(edtDesc.Text);
      AKind := TSymbolKind(cbbKind.ItemIndex);
      Scope := seScope.Value;
      AutoIndent := chkAutoIndent.Checked;
      AlwaysDisp := chkAlwaysDisp.Checked;
      ForPascal := chkForPascal.Checked;
      ForCpp := chkForCpp.Checked;
    end;
  finally
    Free;
  end;
end;

procedure TCnInputHelperEditForm.FormCreate(Sender: TObject);
var
  Kind: TSymbolKind;
begin
  inherited;
  for Kind := Low(Kind) to High(Kind) do
    cbbKind.Items.Add(GetSymbolKindName(Kind));
end;

function TCnInputHelperEditForm.GetHelpTopic: string;
begin
  Result := SCnInputHelperHelpStr;
end;

procedure TCnInputHelperEditForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnInputHelperEditForm.btnOKClick(Sender: TObject);
begin
  if Trim(edtName.Text) = '' then
  begin
    ErrorDlg(SCnInputHelperSymbolNameIsEmpty);
    Exit;
  end;

  if cbbKind.ItemIndex < 0 then
  begin
    ErrorDlg(SCnInputHelperSymbolKindError);
    Exit;
  end;

  ModalResult := mrOk;
end;

procedure TCnInputHelperEditForm.cbbKindChange(Sender: TObject);
begin
  chkAutoIndent.Enabled := TSymbolKind(cbbKind.ItemIndex) in
    [skTemplate, skComment];
end;

{$ENDIF CNWIZARDS_CNINPUTHELPER}
end.
