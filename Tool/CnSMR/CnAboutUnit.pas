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

unit CnAboutUnit;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：关于介绍单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2007.08.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnMainUnit, StdCtrls, ExtCtrls, CnClasses, CnLangStorage,
  CnHashLangStorage, Buttons, CnCommon, CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnAboutForm = class(TForm)
    GridPanel1: TPanel;
    Label2: TLabel;
    pnl1: TPanel;
    lbl2: TLabel;
    lbl1: TLabel;
    bvl1: TBevel;
    img1: TImage;
    btnAbout: TBitBtn;
    btnClose: TBitBtn;
    btnHelp: TBitBtn;
    CnHashLangFileStorage: TCnHashLangFileStorage;
    bvlLine: TBevel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure CMGetFormIndex(var Message: TMessage); message CM_GETFORMINDEX;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TfAbout }

procedure TCnAboutForm.CMGetFormIndex(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TCnAboutForm.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TCnAboutForm.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnIDEAbout, SCnAboutCaption);
end;

procedure TCnAboutForm.btnHelpClick(Sender: TObject);
begin
  if CnSMRMainForm <> nil then
    CnSMRMainForm.actHelp.Execute;
end;

procedure TCnAboutForm.FormShow(Sender: TObject);
begin
  lbl1.Font.Style := lbl1.Font.Style + [fsBold];
  Label2.Anchors := Label2.Anchors + [akRight];
end;

initialization
  RegisterFormClass(TCnAboutForm);

end.
