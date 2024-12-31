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
* 修改记录：2018.01.12
*               加入初始化时不自动挂接的控制，加入接口函数的真实地址获取
*           2014.10.01
*               将 DDetours 调用改为动态
*           2014.08.28
*               改用DDetours实现调用
*           2003.10.27
*               实现属性编辑器方法挂接核心技术
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes{$IFDEF USE_DDETOURS_HOOK}, DDetours{$ENDIF};

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
    FUseDDteours: Boolean;
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
    FTrampoline: Pointer;
    FSaveData: TLongJump;
  public
    constructor Create(const AOldMethod, ANewMethod: Pointer; UseDDteoursHook: Boolean = False;
      DefaultHook: Boolean = True);
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

    property Hooked: Boolean read FHooked;
    {* 是否已挂接}
    procedure HookMethod; virtual;
    {* 重新挂接，如果需要执行原过程，并使用了 UnhookMethod，请在执行完成后重新挂接}
    procedure UnhookMethod; virtual;
    {* 取消挂接，如果需要执行原过程，请先使用 UnhookMethod，再调用原过程，否则会出错}
    property Trampoline: Pointer read FTrampoline;
    {* DDetours 挂接后的旧方法地址，供外界不切换挂接状态而直接调用。
       如不使用 DDetours，则为 nil}
    property UseDDteours: Boolean read FUseDDteours;
    {* 是否使用 UseDDteours 库进行挂接}
  end;

function GetBplMethodAddress(Method: Pointer): Pointer;
{* 返回在 BPL 中实际的方法地址。如专家包中用 @TPersistent.Assign 返回的其实是
   一个 Jmp 跳转地址，该函数可以返回在 BPL 中方法的真实地址。}

function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
{* 由于 Delphi 不支持 @AIntf.Proc 的方式返回接口的函数入口地址，并且 Self 指针也
   有偏移问题。本函数用于返回 AIntf 的第 MethodIndex 个函数的入口地址，并修正了
   Self 指针的偏移问题。
   MethodIndex 从 0 开始，0、1、2 分别代表 QueryInterface、_AddRef、_Release。
   注意 MethodIndex 不做边界检查，超过了该 Interface 的方法数会出错}

implementation

type
  TJmpCode = packed record
    Code: Word;                 // 间接跳转指定，为 $25FF
    Addr: ^Pointer;             // 跳转指针地址，指向保存目标地址的指针
  end;
  PJmpCode = ^TJmpCode;

resourcestring
  SMemoryWriteError = 'Error writing method memory (%s).';

const
  csJmpCode = $E9;              // 相对跳转指令机器码
  csJmp32Code = $25FF;

// 返回在 BPL 中实际的方法地址
function GetBplMethodAddress(Method: Pointer): Pointer;
begin
  if PJmpCode(Method)^.Code = csJmp32Code then
    Result := PJmpCode(Method)^.Addr^
  else
    Result := Method;
end;

// 返回 Interface 的某序号方法的实际地址，并修正 Self 偏移
function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
type
  TIntfMethodEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte);        // $05 加四字节
      1: (WordOpCode: Word);        // $C083 加一字节
      2: (DWordOpCode: DWORD);      // $04244483 加一字节或 $04244481 加四字节
  end;
  PIntfMethodEntry = ^TIntfMethodEntry;

  // 长短跳转的组合声明，实际上等同于 TJmpCode 与 TLongJmp 俩结构的组合
  TIntfJumpEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte; Offset: LongInt);         // $E9 加四字节
      1: (WordOpCode: Word; Addr: ^Pointer);        // $25FF 加四字节
  end;
  PIntfJumpEntry = ^TIntfJumpEntry;
  PPointer = ^Pointer;

var
  OffsetStubPtr: Pointer;
  IntfPtr: PIntfMethodEntry;
  JmpPtr: PIntfJumpEntry;
begin
  Result := nil;
  if (AIntf = nil) or (MethodIndex < 0) then
    Exit;

  OffsetStubPtr := PPointer(Integer(PPointer(AIntf)^) + SizeOf(Pointer) * MethodIndex)^;

  // 得到该 interface 成员函数跳转入口，该入口会修正 Self 指针后跳至真正入口
  // IUnknown 的仨标准函数入口均是 add dword ptr [esp+$04],-$xx （xx 为 ShortInt 或 LongInt），因为是 stdcall
  // stdcall/safecall/cdecl 的代码为 $04244483 加一字节的 ShortInt，或 $04244481 加四字节的 LongInt
  // 但其他函数看调用方式，有可能是默认 register 的 add eax -$xx （xx 为 ShortInt 或 LongInt）
  // stdcall/safecall/cdecl 的代码为 $C083 加一字节的 ShortInt，或 $05 加四字节的 LongInt
  // pascal 照理换了入栈方式，但似乎仍和 stdcall 等一样
  IntfPtr := PIntfMethodEntry(OffsetStubPtr);

  JmpPtr := nil;
  if IntfPtr^.ByteOpCode = $05 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 1 + 4)
  else if IntfPtr^.DWordOpCode = $04244481 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 4 + 4)
  else if IntfPtr^.WordOpCode = $C083 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 2 + 1)
  else if IntfPtr^.DWordOpCode = $04244483 then
    JmpPtr := PIntfJumpEntry(Integer(IntfPtr) + 4 + 1);

  if JmpPtr <> nil then
  begin
    // 要区分各种不同的跳转，至少有 E9 加四字节相对偏移，以及 25FF 加四字节绝对地址的地址
    if JmpPtr^.ByteOpCode = csJmpCode then
    begin
      Result := Pointer(Integer(JmpPtr) + JmpPtr^.Offset + 5); // 5 表示 Jmp 指令的长度
    end
    else if JmpPtr^.WordOpCode = csJmp32Code then
    begin
      Result := JmpPtr^.Addr^;
    end;
  end;
end;

//==============================================================================
// 静态或 dynamic 方法挂接类
//==============================================================================

{ TCnMethodHook }

constructor TCnMethodHook.Create(const AOldMethod, ANewMethod: Pointer;
  UseDDteoursHook, DefaultHook: Boolean);
begin
  inherited Create;
{$IFNDEF USE_DDETOURS_HOOK}
  if UseDDteoursHook then
    raise Exception.Create('DDetours NOT Included. Can NOT Hook.');
{$ENDIF}
  FUseDDteours := UseDDteoursHook;
  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;
  FTrampoline := nil;

  if DefaultHook then
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

  if FUseDDteours then
  begin
{$IFDEF USE_DDETOURS_HOOK}
    FTrampoline := DDetours.InterceptCreate(FOldMethod, FNewMethod);
    if not Assigned(FTrampoline) then
      raise Exception.Create('Failed to install method hook');
{$ENDIF}
  end
  else
  begin
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
  end;

  FHooked := True;
end;

procedure TCnMethodHook.UnhookMethod;
var
  DummyProtection: DWORD;
  OldProtection: DWORD;
begin
  if not FHooked then Exit;

  if FUseDDteours then
  begin
{$IFDEF USE_DDETOURS_HOOK}
    if not DDetours.InterceptRemove(FTrampoline) then
      raise Exception.Create('Failed to release method hook');
{$ENDIF}
    FTrampoline := nil;
  end
  else
  begin
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
  end;

  FHooked := False;
end;

end.
