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

unit CnMultiLineEdtUserFmtFrm;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：字符串编辑器辅助工具自定义格式化设置
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：
*           2003.10.18
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, CnMultiLineEditorFrm, StdCtrls;

type
  TCnMultiLineEditorUserFmtForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    edt1: TEdit;
    edt2: TEdit;
    chk1: TCheckBox;
    chk2: TCheckBox;
    lbl1: TLabel;
    lbl2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FUserFormatOpt: DWORD;
    FUserFormatStrBefore: string;
    FUserFormatStrAfter: string;
    function Getchk1Enabled: Boolean;
    procedure Setchk1Enabled(const Value: Boolean);
  public
    { Public declarations }
    property UserFormatStrBefore: string read FUserFormatStrBefore write FUserFormatStrBefore;
    property UserFormatStrAfter: string read FUserFormatStrAfter write FUserFormatStrAfter;
    property UserFormatOpt: DWORD read FUserFormatOpt write FUserFormatOpt;
    property chk1Enabled: Boolean read Getchk1Enabled write Setchk1Enabled;
  end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  CnCommon;

{$R *.DFM}

procedure TCnMultiLineEditorUserFmtForm.FormShow(Sender: TObject);
begin
  inherited;
  edt1.Text := UserFormatStrBefore;
  edt2.Text := UserFormatStrAfter;
  chk1.Checked := GetBit(UserFormatOpt, 0);
  chk2.Checked := GetBit(UserFormatOpt, 1);
end;

procedure TCnMultiLineEditorUserFmtForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;
  UserFormatStrBefore := edt1.Text;
  UserFormatStrAfter := edt2.Text;
  SetBit(FUserFormatOpt, 0, chk1.Checked);
  SetBit(FUserFormatOpt, 1, chk2.Checked);
end;

function TCnMultiLineEditorUserFmtForm.Getchk1Enabled: Boolean;
begin
  Result := chk1.Enabled;
end;

procedure TCnMultiLineEditorUserFmtForm.Setchk1Enabled(const Value: Boolean);
begin
  chk1.Enabled := Value;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
