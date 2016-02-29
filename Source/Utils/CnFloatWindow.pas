{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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

unit CnFloatWindow;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：浮动窗，供输入助手以及浮动工具栏等使用
* 单元作者：Johnson Zhong zhongs@tom.com http://www.longator.com
*           周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：PWinXP + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.07.21
*               从代码输入助手移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, Windows, Controls, SysUtils, Messages, CnCommon;

const
  CS_DROPSHADOW = $20000;

type
{ TCnFloatWindow }

  TCnFloatWindow = class(TCustomControl)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

implementation

//==============================================================================
// 浮动窗体
//==============================================================================

{ TCnFloatWindow }

procedure TCnFloatWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW or WS_MAXIMIZEBOX;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnFloatWindow.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

procedure TCnFloatWindow.Paint;
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

end.
