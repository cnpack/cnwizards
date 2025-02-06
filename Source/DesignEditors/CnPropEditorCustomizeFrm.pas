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

unit CnPropEditorCustomizeFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性编辑器定制窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2006.09.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnDesignEditorConsts, CnWizMultiLang;

type
  TCnPropEditorCustomizeForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    mmoProp: TMemo;
    lbl1: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure btnHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

function ShowPropEditorCustomizeForm(List: TStrings; IsComp: Boolean): Boolean;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$R *.DFM}

function ShowPropEditorCustomizeForm(List: TStrings; IsComp: Boolean): Boolean;
begin
  with TCnPropEditorCustomizeForm.Create(nil) do
  try
    if IsComp then
    begin
      Caption := SCnCompEditorCustomizeCaption;
      grp1.Caption := SCnCompEditorCustomizeCaption1;
      lbl1.Caption := SCnCompEditorCustomizeDesc;
    end;
    mmoProp.Lines.Assign(List);
    Result := ShowModal = mrOk;
    if Result then
      List.Assign(mmoProp.Lines);
  finally
    Free;
  end;   
end;  

procedure TCnPropEditorCustomizeForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPropEditorCustomizeForm.GetHelpTopic: string;
begin
  Result := 'CnPropEditorCustomizeForm';
end;

procedure TCnPropEditorCustomizeForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Ord(Key) = VK_RETURN) then
    btnOK.Click;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
 
