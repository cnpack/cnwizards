{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnPrefixNewFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家新前缀对话框单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家新前缀对话框单元
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
  StdCtrls, CnWizConsts, CnCommon, CnWizUtils, CnWizMultiLang;

type

{ TCnPrefixNewForm }

  TCnPrefixNewForm = class(TCnTranslateForm)
    gbNew: TGroupBox;
    lbl1: TLabel;
    lbl3: TLabel;
    edtPrefix: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    cbNeverDisp: TCheckBox;
    Label1: TLabel;
    edtComponent: TEdit;
    cbIgnore: TCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure edtPrefixKeyPress(Sender: TObject; var Key: Char);
  private

  protected
    function GetHelpTopic: string; override;
  public
  end;

// 取得新的组件前缀名。RootName 不为空表示是 Form 的情形，修改的是 TForm 对应的前缀
function GetNewComponentPrefix(const ComponentClass: string; var NewPrefix: string;
  UserMode: Boolean; var Ignore, PopPrefixDefine: Boolean; const RootName: string = ''): Boolean;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{$R *.DFM}

{ TCnPrefixNewForm }

function GetNewComponentPrefix(const ComponentClass: string; var NewPrefix: string;
  UserMode: Boolean; var Ignore, PopPrefixDefine: Boolean; const RootName: string): Boolean;
begin
  with TCnPrefixNewForm.Create(nil) do
  try
    if RootName <> '' then
      edtComponent.Text := RootName
    else
      edtComponent.Text := ComponentClass;
    edtPrefix.Text := NewPrefix;
    cbIgnore.Visible := not UserMode;
    cbNeverDisp.Visible := not UserMode;

    Result := ShowModal = mrOk;
   
    NewPrefix := edtPrefix.Text;
    PopPrefixDefine := not cbNeverDisp.Checked;
    Ignore := cbIgnore.Checked;
  finally
    Free;
  end;
end;

procedure TCnPrefixNewForm.btnOKClick(Sender: TObject);
begin
  if IsValidIdent(edtPrefix.Text) then
    ModalResult := mrOk
  else
    ErrorDlg(SCnPrefixInputError);
end;

procedure TCnPrefixNewForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPrefixNewForm.GetHelpTopic: string;
begin
  Result := 'CnPrefixNewForm';
end;

procedure TCnPrefixNewForm.edtPrefixKeyPress(Sender: TObject;
  var Key: Char);
const
  Chars = ['A'..'Z', 'a'..'z', '_', '0'..'9', #03, #08, #22];
begin
  if not CharInSet(Key, Chars) then
    Key := #0;
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
