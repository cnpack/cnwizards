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
*           32 位下统一使用相对跳转也即 E9 加 32 位偏移，一般没啥问题。
*           64 位下如果也用 E9 加 32 位偏移，那么 DLL 在内存空间中太远就会跳不过去
*           64 位下有 25FF 加 RIP 偏移处的 8 字节作为绝对跳转地址的模式（BPL 就如此），
*           但同样存在该 8 字节存储的位置离待挂接的方法太远的问题。
*
*           因而两种选择，一是在 64 位下使用 DDetours 来规避。二是考虑这种（已实现）：
*              push address.low32
*              mov dword [rsp+4], address.high32
*              ret
*           好处是能覆盖所有空间不用担心太远，坏处是 14 个字节，远超 32 位下的 5 个。
*
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2025.02.09
*               64 位下完善长短跳转的 Hook
*           2025.02.07
*               修正 GetBplMethodAddress 在 64 位下的错误，但跳转还是有问题
*               先强行在 64 位下使用 DDetours
*           2024.02.04
*               将 64 位支持从 CnMethodHook 中移入。差异则是是否使用 DDetours
*           2018.01.12
*               加入初始化时不自动挂接的控制，加入接口函数的真实地址获取
*           2014.10.01
*               将 DDetours 调用改为动态
*           2014.08.28
*               改用 DDetours 实现调用
*           2003.10.27
*               实现属性编辑器方法挂接核心技术
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnNative {$IFDEF USE_DDETOURS_HOOK}, DDetours{$ENDIF};

type
  PCnLongJump = ^TCnLongJump;
  TCnLongJump = packed record
    JmpOp: Byte;        // Jmp 相对跳转指令，为 $E9，32 位和 64 位通用
{$IFDEF CPU64BITS}
    Addr: DWORD;        // 64 位下的跳转到的相对地址，也是 32 位，但覆盖不到 DLL 布局太远的情况
{$ELSE}
    Addr: Pointer;      // 跳转到的 32 位相对地址
{$ENDIF}
  end;

{$IFDEF CPU64BITS}

  { 64 位下的变相长跳转汇编，占 14 字节
      PUSH addr.low32
      MOV DWORD [rsp+4], addr.high32
      RET
    也即 68 44332211
         C74424 04 88776655
         C3
    可跳转到 $5566778811223344
  }
  PCnLongJump64 = ^TCnLongJump64;
  TCnLongJump64 = packed record
    PushOp: Byte;         // $68
    AddrLow32: DWORD;
    MovOp: DWORD;         // $042444C7
    AddrHigh32: DWORD;
    RetOp: Byte;          // $C3
  end;

{$ENDIF}

  TCnMethodHook = class
  {* 静态或 dynamic 方法挂接类，用于挂接类中静态方法或声明为 dynamic 的动态方法。
     该类通过修改原方法入口前 5/14 字节，改为跳转指令来实现方法挂接操作，在使用时
     请保证原方法的执行体代码大于 5/14 字节，否则可能会出现严重后果。}
  private
    FUseDDteours: Boolean;
    FHooked: Boolean;
    FOldMethod: Pointer;
    FNewMethod: Pointer;
    FTrampoline: Pointer;
    FSaveData: TCnLongJump;
{$IFDEF CPU64BITS}
    FSaveData64: TCnLongJump64; // 64 位远跳的保存数据
    FFar: Boolean;              // 64 位下是否太远要用更长的跳转
    procedure InitLongJump64(JmpPtr: PCnLongJump64);
{$ENDIF}
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
   一个 Jmp 跳转地址，该函数可以返回在 BPL 中方法的真实地址，支持 32 位和 64 位
   其中 64 位下目前只处理了跳转是 JMP QWORD PTR [RIP + offset] 也即 $25FF 的情形}

function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
{* 由于 Delphi 不支持 @AIntf.Proc 的方式返回接口的函数入口地址，并且 Self 指针也
   有偏移问题。本函数用于返回 AIntf 的第 MethodIndex 个函数的入口地址，并修正了
   Self 指针的偏移问题。
   MethodIndex 从 0 开始，0、1、2 分别代表 QueryInterface、_AddRef、_Release。
   注意 MethodIndex 不做边界检查，超过了该 Interface 的方法数会出错}

implementation

resourcestring
  SCnMemoryWriteError = 'Error Writing Method Memory (%s).';
  SCnFailInstallHook = 'Failed to Install Method Hook';
  SCnFailUninstallHook = 'Failed to Uninstall Method Hook';
  SCnErrorNoDDetours = 'DDetours NOT Included. Can NOT Hook.';

const
  csJmpCode = $E9;              // 相对跳转指令机器码
  csJmp32Code = $25FF;          // BPL 内入口的跳转机器码，32 位和 64 位通用

type
{$IFDEF CPU64BITS}
  TCnAddressInt = NativeInt;
{$ELSE}
  TCnAddressInt = Integer;
{$ENDIF}

var
{$IFDEF CPU64BITS}
  Is64: Boolean = True;
{$ELSE}
  Is64: Boolean = False;
{$ENDIF}

// 返回在 BPL 中实际的方法地址，支持 32 位和 64 位，机器码都为 $25FF，但含义不同
function GetBplMethodAddress(Method: Pointer): Pointer;
type
  TJmpCode = packed record
    Code: Word;                 // 间接跳转指定，为 $25FF
{$IFDEF CPU64BITS}
    Addr: DWORD;                // 64 位下的跳转到的 8 字节地址所存储位置的相对偏移，也是 32 位，JMP QWORD PTR [RIP + Addr]
{$ELSE}
    Addr: ^Pointer;             // 32 位下的跳转指针地址，指向保存目标地址的指针，JMP DWORD PTR [Addr]
{$ENDIF}
  end;
  PJmpCode = ^TJmpCode;

{$IFDEF CPU64BITS}
var
  P: PPointer;
{$ENDIF}
begin
  if (Method <> nil) and (PJmpCode(Method)^.Code = csJmp32Code) then
  begin
{$IFDEF CPU64BITS}
    // Addr 存放一个 32 位偏移，加上 RIP 也就是 Method 入口再加本跳转指令的 6 字节
    // 就能得到一个绝对地址，该地址存放的 8 字节是真正的跳转目标地址
    P := PPointer(NativeInt(Method) + SizeOf(TJmpCode) + Integer(PJmpCode(Method)^.Addr));
    Result := P^;
{$ELSE}
    Result := PJmpCode(Method)^.Addr^;
{$ENDIF}
  end
  else
    Result := Method;
end;

// 返回 Interface 的某序号方法的实际地址，并修正 Self 偏移，支持 32 位和 64 位
function GetInterfaceMethodAddress(const AIntf: IUnknown;
  MethodIndex: Integer): Pointer;
type
  TIntfMethodEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte);        // 32 位下的 $05 加四字节
      1: (WordOpCode: Word);        // 32 位下的 $C083 加一字节
      2: (DWordOpCode: DWORD);      // 32 位下的 $04244483 加一字节或 $04244481 加四字节，
                                    // 或 64 位下的 $4883C1E0 加一字节
  end;
  PIntfMethodEntry = ^TIntfMethodEntry;

{$IFDEF CPU64BITS}
  TRelativeAddr = DWORD;
{$ELSE}
  TRelativeAddr = ^Pointer;
{$ENDIF}

  // 长短跳转的组合声明，实际上等同于 TJmpCode 与 TLongJmp 俩结构的组合
  TIntfJumpEntry = packed record
    case Integer of
      0: (ByteOpCode: Byte; Offset: LongInt);       // $E9 加四字节，32 位和 64 位通用
      1: (WordOpCode: Word; Addr: TRelativeAddr);   // $25FF 加四字节
  end;
  PIntfJumpEntry = ^TIntfJumpEntry;
  PPointer = ^Pointer;

var
  OffsetStubPtr: Pointer;
  IntfPtr: PIntfMethodEntry;
  JmpPtr: PIntfJumpEntry;
{$IFDEF CPU64BITS}
  P: PPointer;
{$ENDIF}
begin
  Result := nil;
  if (AIntf = nil) or (MethodIndex < 0) then
    Exit;

  OffsetStubPtr := PPointer(TCnAddressInt(PPointer(AIntf)^) + SizeOf(Pointer) * MethodIndex)^;

  // 得到该 interface 成员函数跳转入口，该入口会修正 Self 指针后跳至真正入口
  // 32 位下，IUnknown 的仨标准函数入口均是 add dword ptr [esp+$04],-$xx （xx 为 ShortInt 或 LongInt），因为是 stdcall
  // stdcall/safecall/cdecl 的代码为 $04244483 加一字节的 ShortInt，或 $04244481 加四字节的 LongInt
  // 但其他函数看调用方式，有可能是默认 register 的 add eax -$xx （xx 为 ShortInt 或 LongInt）
  // stdcall/safecall/cdecl 的代码为 $C083 加一字节的 ShortInt，或 $05 加四字节的 LongInt
  // pascal 照理换了入栈方式，但似乎仍和 stdcall 等一样
  // Win64 下，函数入口均是 add ecx, -$20，之后再 Jump
  IntfPtr := PIntfMethodEntry(OffsetStubPtr);

  JmpPtr := nil;

{$IFDEF CPU64BITS}
  // 64 位跳转似乎就这一种
  if IntfPtr^.DWordOpCode = $E0C18348 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4);
{$ELSE}
  if IntfPtr^.ByteOpCode = $05 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 1 + 4)
  else if IntfPtr^.DWordOpCode = $04244481 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4 + 4)
  else if IntfPtr^.WordOpCode = $C083 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 2 + 1)
  else if IntfPtr^.DWordOpCode = $04244483 then
    JmpPtr := PIntfJumpEntry(TCnAddressInt(IntfPtr) + 4 + 1);
{$ENDIF}

  if JmpPtr <> nil then
  begin
    // 要区分各种不同的跳转，至少有 E9 加四字节相对偏移（32 位和 64 位通用），以及 25FF 加四字节绝对地址的地址
    if JmpPtr^.ByteOpCode = csJmpCode then
    begin
      Result := Pointer(TCnAddressInt(JmpPtr) + JmpPtr^.Offset + 5); // 5 表示 Jmp 指令的长度
    end
    else if JmpPtr^.WordOpCode = csJmp32Code then
    begin
{$IFDEF CPU64BITS}
      // Addr 存放一个 32 位偏移，加上 RIP 也就是本入口再加本跳转指令的 6 字节
      // 就能得到一个绝对地址，该地址存放的 8 字节是真正的跳转目标地址
      P := PPointer(NativeInt(JmpPtr) + 6 + Integer(JmpPtr^.Addr));
      Result := P^;
{$ELSE}
      Result := JmpPtr^.Addr^;
{$ENDIF}
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
    raise Exception.Create(SCnErrorNoDDetours);
{$ENDIF}

  FUseDDteours := UseDDteoursHook;

  FHooked := False;
  FOldMethod := AOldMethod;
  FNewMethod := ANewMethod;
  FTrampoline := nil;

{$IFDEF CPU64BITS}
  FFar := IsUInt64SubOverflowInt32(UInt64(FNewMethod), UInt64(FOldMethod));
{$ENDIF}

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
{$IFDEF CPU64BITS}
  NewAddr: UInt64;
{$ENDIF}
begin
  if FHooked then Exit;

  if FUseDDteours then
  begin
{$IFDEF USE_DDETOURS_HOOK}
    FTrampoline := DDetours.InterceptCreate(FOldMethod, FNewMethod);
    if not Assigned(FTrampoline) then
      raise Exception.Create(SCnFailInstallHook);
{$ENDIF}
  end
  else
  begin
    if Is64 {$IFDEF CPU64BITS} and FFar {$ENDIF} then
    begin
{$IFDEF CPU64BITS}
      // 64 位长跳转
      if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump64), PAGE_EXECUTE_READWRITE, @OldProtection) then
        raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);

      try
        // 保存原来的代码
        FSaveData64 := PCnLongJump64(FOldMethod)^;

        // 用跳转指令替换原来方法前 14 字节代码
        InitLongJump64(PCnLongJump64(FOldMethod));

        NewAddr := UInt64(FNewMethod); // 64 位跳转地址拆成高低两部分分别塞入堆栈
        PCnLongJump64(FOldMethod)^.AddrLow32 := DWORD(NewAddr and $FFFFFFFF);
        PCnLongJump64(FOldMethod)^.AddrHigh32 := DWORD(NewAddr shr 32);

        // 保存多处理器下指令缓冲区同步
        FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump64));
      finally
        // 恢复代码页访问权限
        if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump64), OldProtection, @DummyProtection) then
          raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);
      end;
{$ENDIF}
    end
    else // 64 或 32 位相对跳转
    begin
      // 设置代码页写访问权限
      if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), PAGE_EXECUTE_READWRITE, @OldProtection) then
        raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);

      try
        // 保存原来的代码
        FSaveData := PCnLongJump(FOldMethod)^;

        // 用跳转指令替换原来方法前 5 字节代码
        PCnLongJump(FOldMethod)^.JmpOp := csJmpCode;
{$IFDEF CPU64BITS}
        PCnLongJump(FOldMethod)^.Addr := DWORD(TCnAddressInt(FNewMethod) -
          TCnAddressInt(FOldMethod) - SizeOf(TCnLongJump)); // 64 下也使用 32 位相对地址
{$ELSE}
        PCnLongJump(FOldMethod)^.Addr := Pointer(TCnAddressInt(FNewMethod) -
          TCnAddressInt(FOldMethod) - SizeOf(TCnLongJump)); // 使用 32 位相对地址
{$ENDIF}

        // 保存多处理器下指令缓冲区同步
        FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump));
      finally
        // 恢复代码页访问权限
        if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), OldProtection, @DummyProtection) then
          raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);
      end;
    end;
  end;

  FHooked := True;
end;

{$IFDEF CPU64BITS}

procedure TCnMethodHook.InitLongJump64(JmpPtr: PCnLongJump64);
begin
  if JmpPtr <> nil then
  begin
    JmpPtr^.PushOp := $68;
    JmpPtr^.MovOp := $042444C7;
    JmpPtr^.RetOp := $C3;
  end;
end;

{$ENDIF}

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
      raise Exception.Create(SCnFailUninstallHook);
{$ENDIF}
    FTrampoline := nil;
  end
  else
  begin
    if Is64 {$IFDEF CPU64BITS} and FFar {$ENDIF} then
    begin
{$IFDEF CPU64BITS}
      // 设置代码页写访问权限
      if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump64), PAGE_READWRITE, @OldProtection) then
        raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);

      try
        // 恢复原来的代码
        PCnLongJump64(FOldMethod)^ := FSaveData64;
      finally
        // 恢复代码页访问权限
        if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump64), OldProtection, @DummyProtection) then
          raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);
      end;

      // 保存多处理器下指令缓冲区同步
      FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump64));
{$ENDIF}
    end
    else
    begin
      // 设置代码页写访问权限
      if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), PAGE_READWRITE, @OldProtection) then
        raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);

      try
        // 恢复原来的代码
        PCnLongJump(FOldMethod)^ := FSaveData;
      finally
        // 恢复代码页访问权限
        if not VirtualProtect(FOldMethod, SizeOf(TCnLongJump), OldProtection, @DummyProtection) then
          raise Exception.CreateFmt(SCnMemoryWriteError, [SysErrorMessage(GetLastError)]);
      end;

      // 保存多处理器下指令缓冲区同步
      FlushInstructionCache(GetCurrentProcess, FOldMethod, SizeOf(TCnLongJump));
    end;
  end;

  FHooked := False;
end;

end.

