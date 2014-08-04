{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnWizMethodHook;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：对象方法挂接单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元用来挂接 IDE 内部类的方法
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.10.27
*               实现属性编辑器方法挂接核心技术
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, DDetours;

type
  TCnMethodHook = class
  {* 静态或 dynamic 方法挂接类，用于挂接类中静态方法或声明为 dynamic 的动态方法。
     该类通过修改原方法入口前 5字节，改为跳转指令来实现方法挂接操作，在使用时
     请保证原方法的执行体代码大于 5字节，否则可能会出现严重后果。}
  private
    FHooked: Boolean;
    FOldMethod,
    FNewMethod,
    FTrampoline : Pointer;
  protected
    procedure HookMethod; virtual;
    procedure UnhookMethod; virtual;
  public
    constructor Create(const AOldMethod, ANewMethod: Pointer);
    {* 构造器，参数为原方法地址和新方法地址。注意如果在专家包中使用，原方法地址
       请用 GetBplMethodAddress 转换成真实地址。构造器调用后会自动挂接传入的方法。
     |<PRE>
       例：如果要挂接 TTest.Abc(const A: Integer) 方法，可以定义新方法为：
       procedure MyAbc(ASelf: TTest; const A: Integer);
       此处 MyAbc 为普通过程，因为方法会隐含第一个参数为 Self，故此处定义一个
       ASelf: TTest 参数与之相对，实现代码中可以把它当作对象实例来访问。
     |</PRE>}
    destructor Destroy; override;
    {* 类析构器，取消挂接}

    procedure Enable;
    procedure Disable;

    property Trampoline : Pointer read FTrampoline;
  end;

implementation

//==============================================================================
// 静态或 dynamic 方法挂接类
//==============================================================================

{ TCnMethodHook }

constructor TCnMethodHook.Create(const AOldMethod, ANewMethod: Pointer);
begin
  inherited Create;
  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;
  FTrampoline := nil;
  HookMethod;
end;

destructor TCnMethodHook.Destroy;
begin
  UnHookMethod;
  inherited;
end;

procedure TCnMethodHook.Disable;
begin
  UnhookMethod;
end;

procedure TCnMethodHook.Enable;
begin
  HookMethod;
end;

procedure TCnMethodHook.HookMethod;
begin
  if FHooked then Exit;

  FTrampoline := DDetours.InterceptCreate(FOldMethod, FNewMethod);

  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
begin
  if not FHooked then Exit;

  DDetours.InterceptRemove(FTrampoline);
  FTrampoline := nil;

  FHooked := False;
end;

end.
