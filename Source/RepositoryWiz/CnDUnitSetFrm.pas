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

unit CnDUnitSetFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：DUnit 单元测试工程向导窗体
* 单元作者：刘玺 (SQUALL)
* 备    注：由 LiuXiao 移植。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.10.13 V1.0
*               移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDUNITWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, CnWizMultiLang, CnOTACreators;

type
  TCnDUnitSetForm = class(TCnTranslateForm)
    gbxSetup: TGroupBox;
    chbxUnitHead: TCheckBox;
    chbxInitClass: TCheckBox;
    rbCreateApplication: TRadioButton;
    rbCreateUnit: TRadioButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
    function GetIsAddHead: Boolean;
    procedure SetIsAddHead(const Value: Boolean);
    function GetIsAddInit: Boolean;
    procedure SetIsAddInit(const Value: Boolean);
    function GetCreatorType: TCnCreatorType;
    procedure SetCreatorType(const Value: TCnCreatorType);
  protected
    function GetHelpTopic: string; override;
  public
    property IsAddHead: Boolean read GetIsAddHead write SetIsAddHead;
    property IsAddInit: Boolean read GetIsAddInit write SetIsAddInit;
    property CreatorType: TCnCreatorType read GetCreatorType write SetCreatorType;
  end;

{$ENDIF CNWIZARDS_CNDUNITWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDUNITWIZARD}

{$R *.DFM}

{ TCnDUnitSetForm }

function TCnDUnitSetForm.GetIsAddHead: Boolean;
begin
  Result := Self.chbxUnitHead.Checked;
end;

procedure TCnDUnitSetForm.SetIsAddHead(const Value: Boolean);
begin
  Self.chbxUnitHead.Checked := Value;
end;

function TCnDUnitSetForm.GetIsAddInit: Boolean;
begin
  Result := Self.chbxInitClass.Checked;
end;

procedure TCnDUnitSetForm.SetIsAddInit(const Value: Boolean);
begin
  Self.chbxInitClass.Checked := Value;
end;

function TCnDUnitSetForm.GetCreatorType: TCnCreatorType;
begin
  if Self.rbCreateApplication.Checked then
    Result := ctProject
  else // if Self.rbCreateUnit.Checked then
    Result := ctPascalUnit;
end;

procedure TCnDUnitSetForm.SetCreatorType(const Value: TCnCreatorType);
begin
  case Value of
    ctProject: Self.rbCreateApplication.Checked := True;
    ctPascalUnit: Self.rbCreateUnit.Checked := True;
  end;
end;

procedure TCnDUnitSetForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnDUnitSetForm.GetHelpTopic: string;
begin
  Result := 'CnDUnitWizard';
end;

{$ENDIF CNWIZARDS_CNDUNITWIZARD}
end.
