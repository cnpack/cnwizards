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

unit SysUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 SysUtils 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

type
  // Pascal Script doesn't support Pointer directly,
  // so we declare Pointer as Cardinal.
  // Use _GetXXX() and _SetXXX() to access Pointer
  Pointer = type Cardinal;

  HRESULT = LongInt;
  UCS2Char = WideChar;
  UCS4Char = LongWord;
  UTF8String = string;
  TDateTime = Double;
  THandle = LongWord;
  HINST = THandle;
  HMODULE = HINST;
  HGLOBAL = THandle;

  TMethod = record
    Code, Data: Pointer;
  end;

  TGUID = record
    D1: LongWord;
    D2: Word;
    D3: Word;
    D4: array[0..7] of Byte;
  end;

const
  S_OK = 0;
  S_FALSE = $00000001;
  E_NOINTERFACE = HRESULT($80004002);
  E_UNEXPECTED = HRESULT($8000FFFF);
  E_NOTIMPL = HRESULT($80004001);

type
  TObject = class
    constructor Create;
    procedure Free;
    class function ClassName: string;
    class function ClassNameIs(const Name: string): Boolean;
    class function ClassInfo: Pointer;
    class function InstanceSize: Longint;
    class function MethodAddress(const Name: string): Pointer;
    class function MethodName(Address: Pointer): string;
    function FieldAddress(const Name: string): Pointer;
  end;

  IUnknown = interface
    ['{00000000-0000-0000-C000-000000000046}']
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  IDispatch = interface(IUnknown)
    ['{00020400-0000-0000-C000-000000000046}']
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  end;

  TInterfacedObject = class(TObject, IUnknown)
  public
    property RefCount: Integer read FRefCount;
  end;

function _PChar(P: Pointer): PChar;

function _Pointer(P: TObject): Pointer;

function _TObject(P: Pointer): TObject;

function _GetChar(P: Pointer): Char;

procedure _SetChar(P: Pointer; V: Char);

function _GetByte(P: Pointer): Byte;

procedure _SetByte(P: Pointer; V: Byte);

function _GetWord(P: Pointer): Word;

procedure _SetWord(P: Pointer; V: Word);

function _GetInteger(P: Pointer): Integer;

procedure _SetInteger(P: Pointer; V: Integer);

function _GetSingle(P: Pointer): Single;

procedure _SetSingle(P: Pointer; V: Single);

function _GetDouble(P: Pointer): Double;

procedure _SetDouble(P: Pointer; V: Double);

procedure ChDir(const S: string);

procedure MkDir(const S: string);

function ParamCount: Integer;

function ParamStr(Index: Integer): string;

procedure Randomize;

function Random(Range: Integer): Integer;

procedure RmDir(const S: string);

function UpCase(Ch: Char): Char;

{$IFDEF COMPILER6_UP}
function UTF8Encode(const WS: WideString): UTF8String;

function UTF8Decode(const S: UTF8String): WideString;

function AnsiToUtf8(const S: string): UTF8String;

function Utf8ToAnsi(const S: UTF8String): string;
{$ENDIF}

function GetMemory(Size: Integer): Pointer;

function FreeMemory(P: Pointer): Integer;

function ReallocMemory(P: Pointer; Size: Integer): Pointer;

procedure GetMem(var P: Pointer; Size: Integer);

procedure FreeMem(var P: Pointer);

implementation

end.

