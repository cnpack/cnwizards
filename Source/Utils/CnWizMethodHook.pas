{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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
  Windows, SysUtils, Classes;

type
  PLongJump = ^TLongJump;
  TLongJump = packed record
    JmpOp: Byte;        // Jmp 相对跳转指令，为 $E9
    Addr: Pointer;      // 跳转到的相对地址
  end;

  TCnMethodHook = class
  {* 静态或 dynamic 方法挂接类，用于挂接类中静态方法或声明为 dynamic 的动态方法。
     该类通过修改原方法入口前 5字节，改为跳转指令来实现方法挂接操作，在使用时
     请保证原方法的执行体代码大于 5字节，否则可能会出现严重后果。}
  private
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
    FSaveData: TLongJump;
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
    
    procedure HookMethod; virtual;
    {* 重新挂接，如果需要执行原过程，并使用了 UnhookMethod，请在执行完成后重新挂接}
    procedure UnhookMethod; virtual;
    {* 取消挂接，如果需要执行原过程，请先使用 UnhookMethod，再调用原过程，否则会出错}
  end;

function GetBplMethodAddress(Method: Pointer): Pointer;
{* 返回在 BPL 中实际的方法地址。如专家包中用 @TPersistent.Assign 返回的其实是
   一个 Jmp 跳转地址，该函数可以返回在 BPL 中方法的真实地址。}

implementation

resourcestring
  SMemoryWriteError = 'Error writing method memory (%s).';

const
  csJmpCode = $E9;              // 相对跳转指令机器码

// 返回在 BPL 中实际的方法地址
function GetBplMethodAddress(Method: Pointer): Pointer;
type
  PJmpCode = ^TJmpCode;
  TJmpCode = packed record
    Code: Word;                 // 间接跳转指定，为 $25FF
    Addr: ^Pointer;             // 跳转指针地址，指向保存目标地址的指针
  end;
const
  csJmp32Code = $25FF;
begin
  if PJmpCode(Method)^.Code = csJmp32Code then
    Result := PJmpCode(Method)^.Addr^
  else
    Result := Method;
end;

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
  HookMethod;
end;

destructor TCnMethodHook.Destroy;
begin
  UnHookMethod;
  inherited;
end;

procedure TCnMethodHook.HookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if FHooked then Exit;
  
  // 设置代码页写访问权限
  if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_EXECUTE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // 保存原来的代码
    FSaveData := PLongJump(FOldMethod)^;

    // 用跳转指令替换原来方法前 5 字节代码
    PLongJump(FOldMethod)^.JmpOp := csJmpCode;
    PLongJump(FOldMethod)^.Addr := Pointer(Integer(FNewMethod) -
      Integer(FOldMethod) - SizeOf(TLongJump)); // 使用 32 位相对地址

    // 保存多处理器下指令缓冲区同步
    FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));
  finally
    // 恢复代码页访问权限
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;

  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if not FHooked then Exit;
  
  // 设置代码页写访问权限
  if not VirtualProtect(FOldMethod, SizeOf(TLongJump), PAGE_READWRITE, @OldProtection) then
    raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

  try
    // 恢复原来的代码
    PLongJump(FOldMethod)^ := FSaveData;
  finally
    // 恢复代码页访问权限
    if not VirtualProtect(FOldMethod, SizeOf(TLongJump), OldProtection, @DummyProtection) then
      raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
  end;

  // 保存多处理器下指令缓冲区同步
  FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TLongJump));

  FHooked := False;
end;

end.
