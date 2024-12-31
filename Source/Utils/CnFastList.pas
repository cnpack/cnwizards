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

unit CnFastList;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：快速 List 类元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：该单元定义了 快速列表类 TCnFastList
* 开发平台：PWinXP SP3 + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2017.01.11 V1.2
*               增加作为队列和栈使用的 Push/Pop/Peek 方法
*           2015.06.29 V1.1
*               去除几处边界检查操作以增加性能，略危险
*           2008.06.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, {$IFDEF COMPILER6_UP}RTLConsts{$ELSE}Consts{$ENDIF}, SysUtils;

{$IFDEF BDS2012_UP}
const
  MaxListSize = Maxint div 16;

type
  PCnPointerList = ^TCnPointerList;
  TCnPointerList = array[0..MaxListSize - 1] of Pointer;
{$ELSE}
type
  PCnPointerList = PPointerList;
{$ENDIF}

type
  TCnBaseList = class(TObject)
  private
    FList: PCnPointerList;
    FObjectList: Boolean;
    FCount: Integer;
    FCapacity: Integer;
    procedure DirectSetCapacity(NewCapacity: Integer);
  protected
    function Get(Index: Integer): Pointer; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure Grow;
    procedure Put(Index: Integer; Item: Pointer);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    class procedure Error(const Msg: string; Data: Integer);
  public
    constructor Create(AObjectList: Boolean);
    destructor Destroy; override;
    function Add(Item: Pointer): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function First: Pointer;
    function IndexOf(Item: Pointer): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
    function Last: Pointer;

    procedure StackPush(Item: Pointer);
    function StackPop: Pointer;
    function StackPeek: Pointer;

    procedure QueuePush(Item: Pointer);
    function QueuePop: Pointer;
    function QueuePeek: Pointer;

    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Pointer read Get write Put; default;
    property List: PCnPointerList read FList;
  end;

  TCnList = class(TCnBaseList)
  public
    constructor Create;

    procedure Assign(Source: TCnList); virtual;
  end;

  TCnFastObjectList = class(TCnBaseList)
  public
    constructor Create;
  end;

implementation

{ TCnBaseList }

constructor TCnBaseList.Create(AObjectList: Boolean);
begin
  inherited Create;
  FObjectList := AObjectList;
end;

destructor TCnBaseList.Destroy;
begin
  Clear;
  inherited;
end;

function TCnBaseList.Add(Item: Pointer): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TCnBaseList.Clear;
var
  I: Integer;
begin
  if FObjectList then
    for I := 0 to FCount - 1 do
      TObject(FList^[I]).Free;
  FCount := 0;
  SetCapacity(0);
end;

procedure TCnBaseList.Delete(Index: Integer);
var
  Temp: Pointer;
begin
//  if (Index < 0) or (Index >= FCount) then
//    Error(SListIndexError, Index);
// Do NOT check bounds for performance.

  Temp := Items[Index];
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Pointer));
  if FObjectList and (Temp <> nil) then
    TObject(Temp).Free;
end;

class procedure TCnBaseList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

function TCnBaseList.First: Pointer;
begin
  Result := Get(0);
end;

function TCnBaseList.Get(Index: Integer): Pointer;
begin
//  if (Index < 0) or (Index >= FCount) then
//    Error(SListIndexError, Index);
// Do NOT check bounds for performance.

  Result := FList^[Index];
end;

procedure TCnBaseList.Grow;
var
  Delta: Integer;
begin
  if FCapacity >= 4 then
    Delta := FCapacity
  else
    Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TCnBaseList.IndexOf(Item: Pointer): Integer;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    if FList^[I] = Item then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TCnBaseList.Last: Pointer;
begin
  Result := Get(FCount - 1);
end;

procedure TCnBaseList.Put(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(SListIndexError, Index);
  FList^[Index] := Item;
end;

procedure TCnBaseList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Pointer));
    FCapacity := NewCapacity;
  end;
end;

procedure TCnBaseList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Pointer), 0)
  else if FObjectList then
    for I := FCount - 1 downto NewCount do
      TObject(FList^[I]).Free;
  FCount := NewCount;
end;

procedure TCnBaseList.DirectSetCapacity(NewCapacity: Integer);
begin
  if NewCapacity > MaxListSize then
    Error(SListCapacityError, NewCapacity);

  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Pointer));
    FCapacity := NewCapacity;

    if NewCapacity < FCount then // 缩小容量时直接抛弃过多的 Count
      FCount := NewCapacity;
  end;
end;

function TCnBaseList.QueuePeek: Pointer;
begin
  if FCount <= 0  then
    Error(SListIndexError, FCount);
  Result := Last;
end;

function TCnBaseList.QueuePop: Pointer;
begin
  Result := QueuePeek;
  Delete(FCount - 1);
end;

procedure TCnBaseList.QueuePush(Item: Pointer);
begin
  Insert(0, Item);
end;

function TCnBaseList.StackPeek: Pointer;
begin
  if FCount <= 0  then
    Error(SListIndexError, FCount);
  Result := Last;
end;

function TCnBaseList.StackPop: Pointer;
begin
  Result := StackPeek;
  Delete(FCount - 1);
end;

procedure TCnBaseList.StackPush(Item: Pointer);
begin
  Add(Item);
end;

procedure TCnBaseList.Insert(Index: Integer; Item: Pointer);
begin
  if (Index < 0) or (Index > FCount) then
    Error(SListIndexError, Index);
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Pointer));
  FList^[Index] := Item;
  Inc(FCount);
end;

{ TCnList }

procedure TCnList.Assign(Source: TCnList);
begin
  if Source <> nil then
  begin
    DirectSetCapacity(Source.Capacity);
    FCount := Source.Count;
    if Source.FList <> nil then
      Move(Source.FList^[0], FList^[0], Source.Count * SizeOf(Pointer));
  end;
end;

constructor TCnList.Create;
begin
  inherited Create(False);
end;

{ TCnObjectList }

constructor TCnFastObjectList.Create;
begin
  inherited Create(True);
end;

end.
