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

unit CnPrefixExecuteFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件前缀专家执行窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：组件前缀专家执行窗体单元
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
  Contnrs, IniFiles, StdCtrls, ExtCtrls, ToolsAPI, CnWizUtils, CnWizMultiLang;

type

{ TCnPrefixExecuteForm }

  TPrefixExeKind = (pkSelComp, pkCurrForm, pkOpenedForm, pkCurrProject,
    pkProjectGroup);

  TPrefixCompKind = (pcIncorrect, pcUnnamed, pcAll);

  TCnPrefixExecuteForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    btnConfig: TButton;
    gbKind: TGroupBox;
    rbSelComp: TRadioButton;
    rbCurrForm: TRadioButton;
    rbOpenedForm: TRadioButton;
    rbCurrProject: TRadioButton;
    rbProjectGroup: TRadioButton;
    rgCompKind: TRadioGroup;
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function GetExeKind: TPrefixExeKind;
  protected
    function GetHelpTopic: string; override;
  public
    property ExeKind: TPrefixExeKind read GetExeKind;
  end;

function ShowPrefixExecuteForm(OnConfig: TNotifyEvent;
  var Kind: TPrefixExeKind; var CompKind: TPrefixCompKind): Boolean;

{$ELSE}

uses
  Windows, SysUtils, Classes;
// 未定义 CNWIZARDS_CNPREFIXWIZARD 时，简单 uses 几个单元，以备 RenameProc 声明使用

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}

var
  RenameProc: procedure (AComp: TComponent) = nil;

implementation

{$IFDEF CNWIZARDS_CNPREFIXWIZARD}

{$R *.DFM}

function ShowPrefixExecuteForm(OnConfig: TNotifyEvent;
  var Kind: TPrefixExeKind; var CompKind: TPrefixCompKind): Boolean;
begin
  with TCnPrefixExecuteForm.Create(nil) do
  try
    btnConfig.OnClick := OnConfig;
    rgCompKind.ItemIndex := Ord(CompKind);
    Result := ShowModal = mrOk;
    if Result then
    begin
      Kind := ExeKind;
      CompKind := TPrefixCompKind(rgCompKind.ItemIndex);
    end;
  finally
    Free;
  end;
end;

{ TCnPrefixExecuteForm }

procedure TCnPrefixExecuteForm.FormShow(Sender: TObject);
begin
  rbSelComp.Enabled := not CnOtaIsCurrFormSelectionsEmpty;
  if not rbSelComp.Enabled and rbSelComp.Checked then
    rbCurrForm.Checked := True;
  rbCurrForm.Enabled := CurrentIsForm;
  if not rbCurrForm.Enabled and rbCurrForm.Checked then
    rbOpenedForm.Checked := True;
  rbCurrProject.Enabled := CnOtaGetCurrentProject <> nil;
  rbProjectGroup.Enabled := CnOtaGetProjectGroup <> nil;
end;

function TCnPrefixExecuteForm.GetExeKind: TPrefixExeKind;
begin
  if rbSelComp.Checked then
    Result := pkSelComp
  else if rbCurrForm.Checked then
    Result := pkCurrForm
  else if rbOpenedForm.Checked then
    Result := pkOpenedForm
  else if rbCurrProject.Checked then
    Result := pkCurrProject
  else
    Result := pkProjectGroup;
end;

procedure TCnPrefixExecuteForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPrefixExecuteForm.GetHelpTopic: string;
begin
  Result := 'CnPrefixWizard';
end;

{$ENDIF CNWIZARDS_CNPREFIXWIZARD}
end.
