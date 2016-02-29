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

unit CnWizClasses;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards 基础类定义单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2015.05.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, IniFiles, Forms;

type
//==============================================================================
// 设计器右键菜单执行条目基类，可用属性与事件来指定执行参数
//==============================================================================

  TCnDesignMenuExecutor = class(TCnBaseDesignMenuExecutor)
  {* 设计器右键菜单执行条目的基类，可用属性与事件来指定执行参数}
  private
    FActive: Boolean;
    FEnabled: Boolean;
    FCaption: string;
    FHint: string;
    FOnExecute: TNotifyEvent;
  protected
    procedure DoExecute; virtual;
  public
    constructor Create; reintroduce; virtual;

    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;

    property Caption: string read FCaption write FCaption;
    {* 条目显示的标题}
    property Hint: string read FHint write FHint;
    {* 条目显示的提示}
    property Active: Boolean read FActive write FActive;
    {* 控制条目是否显示}
    property Enabled: Boolean read FEnabled write FEnabled;
    {* 控制条目是否使能}
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    {* 条目执行方法，执行时触发}
  end;

procedure RegisterDesignMenuExecutor(Executor: TCnDesignMenuExecutor);
{* 注册一个设计器右键菜单的执行对象实例}

implementation

procedure RegisterDesignMenuExecutor(Executor: TCnDesignMenuExecutor);
begin

end;

{ TCnDesignMenuExecutor }

constructor TCnDesignMenuExecutor.Create;
begin

end;

procedure TCnDesignMenuExecutor.DoExecute;
begin

end;

function TCnDesignMenuExecutor.Execute: Boolean;
begin

end;

function TCnDesignMenuExecutor.GetActive: Boolean;
begin

end;

function TCnDesignMenuExecutor.GetCaption: string;
begin

end;

function TCnDesignMenuExecutor.GetEnabled: Boolean;
begin

end;

function TCnDesignMenuExecutor.GetHint: string;
begin

end;

end.
