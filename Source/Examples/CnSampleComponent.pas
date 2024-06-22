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

unit CnSampleComponent;
{ |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：示例组件单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 5
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串暂不符合本地化处理方式
* 修改记录：2021.08.07
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TCnDynIntArray = array of Integer;

  TCnSampleCollectionItem = class(TCollectionItem)
  private
    FText: string;
  published
    property Text: string read FText write FText;
  end;

  TCnSampleCollection = class(TCollection)
  private
    FVersion: Integer;
    function GetItem(Index: Integer): TCnSampleCollectionItem;
    procedure SetItem(Index: Integer;
      const Value: TCnSampleCollectionItem);
  public
    constructor Create; reintroduce; virtual;
    property Items[Index: Integer]: TCnSampleCollectionItem read GetItem write SetItem;
  published
    property Version: Integer read FVersion write FVersion;
  end;

  TCnSampleComponent = class(TComponent)
  private
    FHint: AnsiString;
    FAccChar: Char;
    FFloatValue: Double;
    FInt64Value: Int64;
    FHeight: Integer;
    FIntfValue: IUnknown;
    FCaption: string;
    FDynArray: TCnDynIntArray;
    FAnchorKind: TAnchorKind;
    FAnchors: TAnchors;
    FParent: TControl;
    FArrayValue: TKeyboardState;
    FOnClick: TNotifyEvent;
    FVarValue: Variant;
    FWideAccChar: WideChar;
    FWideHint: WideString;
    FPoint: TPoint;
{$IFDEF UNICODE}
    FUniStr: string;
{$ENDIF}
    FThisDate: TDate;
    FThisDateTime: TDateTime;
    FThisTime: TTime;
    FCollection: TCnSampleCollection;

    FReadOnlyHint: AnsiString;
    FReadOnlyAccChar: Char;
    FReadOnlyFloatValue: Double;
    FReadOnlyInt64Value: Int64;
    FReadOnlyHeight: Integer;
    FReadOnlyIntfValue: IUnknown;
    FReadOnlyCaption: string;
    FReadOnlyDynArray: TCnDynIntArray;
    FReadOnlyAnchorKind: TAnchorKind;
    FReadOnlyAnchors: TAnchors;
    FReadOnlyParent: TControl;
    FReadOnlyArrayValue: TKeyboardState;
    FReadOnlyOnClick: TNotifyEvent;
    FReadOnlyVarValue: Variant;
    FReadOnlyWideAccChar: WideChar;
    FReadOnlyWideHint: WideString;
    FReadOnlyPoint: TPoint;
    FReadOnlyFont: TFont;
{$IFDEF UNICODE}
    FReadOnlyUniStr: string;
{$ENDIF}
    FReadOnlyDate: TDate;
    FReadOnlyDateTime: TDateTime;
    FReadOnlyTime: TTime;
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ArrayValue: TKeyboardState read FArrayValue write FArrayValue;
    property DynArray: TCnDynIntArray read FDynArray write FDynArray;
    property ReadOnlyArrayValue: TKeyboardState read FReadOnlyArrayValue;
    property ReadOnlyDynArray: TCnDynIntArray read FReadOnlyDynArray;

  published
{   属性涵盖：
    tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray,
    tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
}

    property Height: Integer read FHeight write FHeight;
    property AccChar: Char read FAccChar write FAccChar;
    property AnchorKind: TAnchorKind read FAnchorKind write FAnchorKind;
    property FloatValue: Double read FFloatValue write FFloatValue;
    property Caption: string read FCaption write FCaption;
    property Anchors: TAnchors read FAnchors write FAnchors;
    property Parent: TControl read FParent write FParent;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property WideAccChar: WideChar read FWideAccChar write FWideAccChar;
    property Hint: AnsiString read FHint write FHint;
    property WideHint: WideString read FWideHint write FWideHint;
    property VarValue: Variant read FVarValue write FVarValue;
    property Point: TPoint read FPoint write FPoint;
    property IntfValue: IUnknown read FIntfValue write FIntfValue;
    property Int64Value: Int64 read FInt64Value write FInt64Value;
{$IFDEF UNICODE}
    property UniStr: string read FUniStr write FUniStr;
{$ENDIF}
    property ThisDate: TDate read FThisDate write FThisDate;
    property ThisTime: TTime read FThisTime write FThisTime;
    property ThisDateTime: TDateTime read FThisDateTime write FThisDateTime;
    property Collection: TCnSampleCollection read FCollection write FCollection;

    property ReadOnlyHeight: Integer read FReadOnlyHeight;
    property ReadOnlyAccChar: Char read FReadOnlyAccChar;
    property ReadOnlyAnchorKind: TAnchorKind read FReadOnlyAnchorKind;
    property ReadOnlyFloatValue: Double read FReadOnlyFloatValue;
    property ReadOnlyCaption: string read FReadOnlyCaption;
    property ReadOnlyAnchors: TAnchors read FReadOnlyAnchors;
    property ReadOnlyParent: TControl read FReadOnlyParent;
    property ReadOnlyOnClick: TNotifyEvent read FReadOnlyOnClick;
    property ReadOnlyWideAccChar: WideChar read FReadOnlyWideAccChar;
    property ReadOnlyHint: AnsiString read FReadOnlyHint;
    property ReadOnlyWideHint: WideString read FReadOnlyWideHint;
    property ReadOnlyVarValue: Variant read FReadOnlyVarValue;
    property ReadOnlyPoint: TPoint read FReadOnlyPoint;
    property ReadOnlyIntfValue: IUnknown read FReadOnlyIntfValue;
    property ReadOnlyInt64Value: Int64 read FReadOnlyInt64Value;
    property ReadOnlyFont: TFont read FReadOnlyFont;
{$IFDEF UNICODE}
    property ReadOnlyUniStr: string read FReadOnlyUniStr write FReadOnlyUniStr;
{$ENDIF}
    property ReadOnlyDate: TDate read FReadOnlyDate write FReadOnlyDate;
    property ReadOnlyTime: TTime read FReadOnlyTime write FReadOnlyTime;
    property ReadOnlyDateTime: TDateTime read FReadOnlyDateTime write FReadOnlyDateTime;

  end;

implementation

{ TCnSampleComponent }

constructor TCnSampleComponent.Create(AOwner: TComponent);
var
  WStr: WideString;
begin
  inherited;
  WStr := '我';

  FHint := 'Ansi Hint';
{$IFDEF UNICODE}
  FAccChar := '吃';
{$ELSE}
  FAccChar := 'A';
{$ENDIF}
  FFloatValue := 3.1415926;
  FInt64Value := 9999999988888888;
  FHeight := 80;
  FIntfValue := nil;
  FCaption := 'Caption';

  FAnchorKind := akRight;
  FAnchors := [akLeft, akBottom];
  FParent := nil;

  FArrayValue[0] := 10;

  FOnClick := nil;
  FVarValue := 0;
  FWideAccChar := WStr[1];
  FWideHint := 'Wide Hint';
  FPoint.x := 10;
  FPoint.y := 20;

  FReadOnlyFont := TFont.Create;

  FThisDate := Date;
  FThisTime := Time;
  FThisDateTime := Now;

  FReadOnlyDate := Date;
  FReadOnlyTime := Time;
  FReadOnlyDateTime := Now;

  FCollection := TCnSampleCollection.Create;
  FCollection.Version := 42;
  FCollection.Add;
  FCollection.Add;
  FCollection.Items[0].Text := '吃菜';
  FCollection.Items[1].Text := '20240101';
end;

destructor TCnSampleComponent.Destroy;
begin
  FCollection.Free;
  FReadOnlyFont.Free;
  inherited;
end;

{ TCnSampleCollection }

constructor TCnSampleCollection.Create;
begin
  inherited Create(TCnSampleCollectionItem);
end;

function TCnSampleCollection.GetItem(
  Index: Integer): TCnSampleCollectionItem;
begin
  Result := TCnSampleCollectionItem(inherited GetItem(Index));
end;

procedure TCnSampleCollection.SetItem(Index: Integer;
  const Value: TCnSampleCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

end.
 