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

unit CnPasCodeSample;
{* |<PRE>
================================================================================
* 软件名称：CnPack 公共单元
* 单元名称：供测试代码文档生成的示例单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元为测试代码文档生成的示例，应有各种声明
* 开发平台：PWin7 + Delphi 5
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2022.04.02 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

{$I CnPack.inc}

interface

uses
  SysUtils, Classes;

const
  CN_DOC_TEST_MAX_LENGTH = 1024;
  {* 某整型常量值，代表某最大长度}

  CN_DOC_TEST_TITLE: string = 'Document Title';
  {* 某字符串常量值，代表某标题}

type

// =========================== 四种不同的类声明 ================================

  TCnDocTestObject = class;
  {* 某类的前向声明}

  TCnDocTestObject1 = class(TObject);
  {* 某继承类，有显式基类，无声明体}

  TCnDocTestObject2 = class
  {* 某继承类，无显式基类}
  end;

  TCnDocTestObject3 = class(TObject)
  {* 某继承类，有显式基类}
  end;

// =========================== 三种不同的接口声明 ==============================

  ICnDocTestInterface1 = interface;
  {* 某接口的前向声明}

  ICnDocTestInterface2 = interface
  {* 某继承接口，无显式基类}
  end;

  ICnDocTestInterface3 = interface(IUnknown)
  {* 某继承接口，有显式基类}
  end;

// ================================ 其他各类声明 ===============================

  ECnDocTestException = class(Exception);
  {* 某异常}

  TCnDocTestEnum = (teNone, teTitle, teText);
  {* 某枚举类型}

  TCnDocTestEnums = set of TCnDocTestEnum;
  {* 某集合值}

  TCnDocTestArray = array[0..1023] of Cardinal;
  {* 某数组类型}

  PCnDocTestArray = ^TCnDocTestArray;
  {* 某数组指针}

  TCnDocTestRecord = packed record
  {* 某紧凑结构}
    RecordField1: Cardinal;
    {* 某结构成员一}
    RecordField2: Boolean;
    {* 某结构成员二}
  end;

  ICnDocTestInterface = interface(IUnknown)
  {* 某继承接口，里头有成员函数和属性}
  ['{D735C546-338D-4108-ABF8-3A2D23D93FD1}']
    procedure TestInterfaceProcedure;
    {* 某接口的某方法}
    function GetTestProperty: Boolean;
    {* 某接口的某属性函数}
    property TestProperty: Boolean read GetTestProperty;
    {* 某接口的某属性}
  end;

  TCnDocTestObject = class(TObject)
  {* 某测试大类，有各种内容}
  private
    FAProperty: Integer;
    function GetItem(Index: Integer): string;
    procedure SetAProperty(const Value: Integer);
    procedure SetItem(Index: Integer; const Value: string);

  protected
    FTestField: Boolean;
    {* 某测试字段}
    procedure DoTest; virtual;
    {* 某测试虚拟方法}
  public
    constructor Create(AOwner: TObject); virtual;
    {* 构造函数}
    destructor Destroy; override;
    {* 析构函数}
  private
    procedure Init;
    {* 初始化函数}
    function IsReady: Boolean;
    {* 返回是否准备好}
  protected
    property Items[Index: Integer]: string read GetItem write SetItem; default;
    {* 某索引属性}

  published
    property AProperty: Integer read FAProperty write SetAProperty;
    {* 某属性}
  end;

  ICnDocTestInterface1 = interface
  {* 某没继承接口，里头有成员函数}
    procedure TestInterfaceProcedure1;
    {* 某接口的某过程}
  end;

  TCnDocTestObject4 = class
  {* 某另一测试类}
    FTestField1: Integer;
    {* 某无范围的 Field1}
    FTesetField2: string;
    {* 某无范围的 Field2}
  public
    FTestField3: Cardinal;
    {* 某有范围的 Field3}
  end;

procedure CnDocTestProcedure(Param1: Integer; var Param2: string); stdcall;
{* 某全局过程，带 Directive}

function CnDocTestFunction(const Param1: Integer; Param2: string = ''): Integer;
{* 某全局函数}

var
  CnDocTestGlobalVar1: TCnDocTestEnum = teNone;
  {* 某全局变量一}

  CnDocTestGlobalVar2: TCnDocTestArray;
  {* 某全局变量二}

implementation

procedure CnDocTestProcedure(Param1: Integer; var Param2: string); stdcall;
begin

end;

function CnDocTestFunction(const Param1: Integer; Param2: string = ''): Integer;
begin
  Result := 0;
end;

{ TCnDocTestObject }

constructor TCnDocTestObject.Create(AOwner: TObject);
begin

end;

destructor TCnDocTestObject.Destroy;
begin
  inherited;

end;

procedure TCnDocTestObject.DoTest;
begin

end;

function TCnDocTestObject.GetItem(Index: Integer): string;
begin

end;

procedure TCnDocTestObject.Init;
begin

end;

function TCnDocTestObject.IsReady: Boolean;
begin
  Result := False;
end;

procedure TCnDocTestObject.SetAProperty(const Value: Integer);
begin
  FAProperty := Value;
end;

procedure TCnDocTestObject.SetItem(Index: Integer; const Value: string);
begin

end;

end.
