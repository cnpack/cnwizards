{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnPrefixEditFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家组件改名窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家组件改名窗体单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.04.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CnWizConsts, CnCommon, CnWizUtils, CnWizMultiLang,
  Buttons;

type

{ TCnPrefixEditForm }

  TCnPrefixEditForm = class(TCnTranslateForm)
    gbEdit: TGroupBox;
    lblFormName: TLabel;
    bvl1: TBevel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtName: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    cbNeverDisp: TCheckBox;
    cbIgnoreComp: TCheckBox;
    btnPrefix: TButton;
    img1: TImage;
    edtOldName: TEdit;
    lbl4: TLabel;
    lblClassName: TLabel;
    lbl5: TLabel;
    lblText: TLabel;
    btnClassName: TSpeedButton;
    chkDisablePrefix: TCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnPrefixClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtNameKeyPress(Sender: TObject; var Key: Char);
    procedure btnClassNameClick(Sender: TObject);
  private
    FPrefix: string;
    FRootName: string;
    FUseUnderLine: Boolean;
    FComponentClass: string;
    procedure SetEditSel(Sender: TObject);
  protected
    function GetHelpTopic: string; override;
  public

  end;

// 显示对话框，取得新的组件名称。RootName 不为空时表示是 Form 的情形
function GetNewComponentName(const FormName, ComponentClass, ComponentText,
  OldName: string; var Prefix, NewName: string; HideMode: Boolean;
  var IgnoreComp, AutoPopSuggestDlg, WizardActive: Boolean; UseUnderLine: Boolean;
  const RootName: string = ''; AWizard: TObject = nil): Boolean;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

uses
  CnPrefixNewFrm, CnPrefixWizard, CnWizNotifier {$IFDEF DEBUG}, CnDebug {$ENDIF};

{$R *.DFM}

{ TCnPrefixEditForm }

// 取得新的组件名称
function GetNewComponentName(const FormName, ComponentClass, ComponentText,
  OldName: string; var Prefix, NewName: string; HideMode: Boolean;
  var IgnoreComp, AutoPopSuggestDlg, WizardActive: Boolean; UseUnderLine: Boolean;
  const RootName: string; AWizard: TObject): Boolean;
var
  Wizard: TCnPrefixWizard;
  OldWidth, OldHeight: Integer;
begin
  Result := False;
  if not (AWizard is TCnPrefixWizard) then
    Exit;

  Wizard := AWizard as TCnPrefixWizard;
  with TCnPrefixEditForm.Create(nil) do
  try
    // 加载保存的未缩放尺寸并缩放
    if Wizard.EditDialogWidth > 0 then
      Width := CalcIntEnlargedValue(Wizard.EditDialogWidth);
    if  Wizard.EditDialogHeight > 0 then
      Height := CalcIntEnlargedValue(Wizard.EditDialogHeight);

    lblFormName.Caption := FormName;
    lblClassName.Caption := ComponentClass;
    lblText.Caption := ComponentText;
    FUseUnderLine := UseUnderLine;
    FPrefix := Prefix;
    FRootName := RootName;
    FComponentClass := ComponentClass;
    edtOldName.Text := OldName;
    edtName.Text := NewName;
    cbNeverDisp.Checked := not AutoPopSuggestDlg;
    chkDisablePrefix.Checked := not WizardActive;
    if HideMode then
    begin
      cbIgnoreComp.Visible := False;
      cbNeverDisp.Visible := False;
      chkDisablePrefix.Visible := False;
    end;

    OldWidth := Width;
    OldHeight := Height;
    Result := ShowModal = mrOk;

    Prefix := FPrefix;
    NewName := edtName.Text;
    IgnoreComp := cbIgnoreComp.Checked;
    AutoPopSuggestDlg := not cbNeverDisp.Checked;
    WizardActive := not chkDisablePrefix.Checked;

    // 如果尺寸改变了，保存未缩放后的尺寸
    if (Width <> OldWidth) or (Height <> OldHeight) then
    begin
      Wizard.EditDialogWidth := CalcIntUnEnlargedValue(Width);
      Wizard.EditDialogHeight := CalcIntUnEnlargedValue(Height);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('GetNewComponentName from Prefix Dialog. Save Width %d, Height %d,',
        [Wizard.EditDialogWidth, Wizard.EditDialogHeight]);
{$ENDIF}
    end;

    if not WizardActive then
      Result := False;
  finally
    Free;
  end;
end;

procedure TCnPrefixEditForm.FormShow(Sender: TObject);
begin
  CnWizNotifierServices.ExecuteOnApplicationIdle(SetEditSel);
end;

procedure TCnPrefixEditForm.btnOKClick(Sender: TObject);
begin
  if IsValidIdent(edtName.Text) then
    ModalResult := mrOk
  else
    ErrorDlg(SCnPrefixNameError);
end;

procedure TCnPrefixEditForm.btnPrefixClick(Sender: TObject);
var
  B1, B2: Boolean;
  OldPrefix: string;
begin
  OldPrefix := FPrefix;
  if GetNewComponentPrefix(FComponentClass, FPrefix, True, B1, B2, FRootName) then
    if Pos(OldPrefix, edtName.Text) = 1 then
      edtName.Text := StringReplace(edtName.Text, OldPrefix, FPrefix, []);

  SetEditSel(nil);
end;

procedure TCnPrefixEditForm.SetEditSel(Sender: TObject);
begin
  edtName.SetFocus;
  if Self.FUseUnderLine then
  begin
    edtName.SelStart := Length(FPrefix) + 1;
    edtName.SelLength := Length(edtName.Text) - Length(FPrefix) - 1;
  end
  else
  begin
    edtName.SelStart := Length(FPrefix);
    edtName.SelLength := Length(edtName.Text) - Length(FPrefix);
  end;
end;

procedure TCnPrefixEditForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPrefixEditForm.GetHelpTopic: string;
begin
  Result := 'CnPrefixEditForm';
end;

procedure TCnPrefixEditForm.edtNameKeyPress(Sender: TObject;
  var Key: Char);
const
  Chars = ['A'..'Z', 'a'..'z', '_', '0'..'9', #03, #08, #22, #24, #26]; // Ctrl+C/V/X/Z
begin
  if not CharInSet(Key, Chars) and not IsValidIdent('A' + Key) then
    Key := #0;
end;

procedure TCnPrefixEditForm.btnClassNameClick(Sender: TObject);
begin
  edtName.Text := RemoveClassPrefix(lblClassName.Caption);
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
