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

unit CnWizEdtTabSetFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器 TabSet 挂接基窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元用于扩展IDE源码编辑器的TabSet标签
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, ToolsAPI;

type
  TCnWizEdtTabSetForm = class(TCnTranslateForm)
  private
    { Private declarations }
  public
    { Public declarations }
    function GetTabCaption: string; virtual; abstract;
    function IsTabVisible(Editor: IOTASourceEditor; View: IOTAEditView): Boolean; virtual;
    procedure DoTabShow(Editor: IOTASourceEditor; View: IOTAEditView); virtual;
    procedure DoTabHide; virtual;
  end;

  TCnWizEdtTabSetFormClass = class of TCnWizEdtTabSetForm;

implementation

{$R *.DFM}

{ TCnWizEdtTabSetForm }

procedure TCnWizEdtTabSetForm.DoTabHide;
begin

end;

procedure TCnWizEdtTabSetForm.DoTabShow(Editor: IOTASourceEditor;
  View: IOTAEditView);
begin

end;

function TCnWizEdtTabSetForm.IsTabVisible(Editor: IOTASourceEditor;
  View: IOTAEditView): Boolean;
begin
  Result := True;
end;

end.
