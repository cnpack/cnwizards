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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit TypeInfo;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 TypInfo 单元声明
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
  TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray);

  TTypeKinds = set of TTypeKind;

  PTypeInfo = Pointer;

const
  tkAny = [Low(TTypeKind)..High(TTypeKind)];
  tkMethods = [tkMethod];
  tkProperties = tkAny - tkMethods - [tkUnknown];

function GetPropList(Instance: TObject; TypeKinds: TTypeKinds; PropList: TStrings): Integer;

function GetPropTypeInfo(Instance: TObject; const PropName: string): PTypeInfo;

function GetEnumName(TypeInfo: PTypeInfo; Value: Integer): string;

function GetEnumValue(TypeInfo: PTypeInfo; const Name: string): Integer;

function IsPublishedProp(Instance: TObject; const PropName: string): Boolean;

function PropIsType(Instance: TObject; const PropName: string; TypeKind: TTypeKind): Boolean;

function PropType(Instance: TObject; const PropName: string): TTypeKind;

function IsStoredProp(Instance: TObject; const PropName: string): Boolean;

function GetOrdProp(Instance: TObject; const PropName: string): Longint;

procedure SetOrdProp(Instance: TObject; const PropName: string; Value: Longint);

function GetEnumProp(Instance: TObject; const PropName: string): string;

procedure SetEnumProp(Instance: TObject; const PropName: string; const Value: string);

function GetSetProp(Instance: TObject; const PropName: string; Brackets: Boolean): string;

procedure SetSetProp(Instance: TObject; const PropName: string; const Value: string);

function GetObjectProp(Instance: TObject; const PropName: string): TObject;

procedure SetObjectProp(Instance: TObject; const PropName: string; Value: TObject);

function GetStrProp(Instance: TObject; const PropName: string): string;

procedure SetStrProp(Instance: TObject; const PropName: string; const Value: string);

function GetFloatProp(Instance: TObject; const PropName: string): Extended;

procedure SetFloatProp(Instance: TObject; const PropName: string; Value: Extended);

function GetVariantProp(Instance: TObject; const PropName: string): Variant;

procedure SetVariantProp(Instance: TObject; const PropName: string; const Value: Variant);

function GetMethodProp(Instance: TObject; const PropName: string): TMethod;

procedure SetMethodProp(Instance: TObject; const PropName: string; const Value: TMethod);

function GetInt64Prop(Instance: TObject; const PropName: string): Int64;

procedure SetInt64Prop(Instance: TObject; const PropName: string; const Value: Int64);

function GetPropValue(Instance: TObject; const PropName: string; PreferStrings: Boolean): Variant;

procedure SetPropValue(Instance: TObject; const PropName: string; const Value: Variant);

implementation

end.

