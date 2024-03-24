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

unit CnWizIdeHooks;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：ImageList 更新 Hook 单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：VCL 的 TCustomImageList 提供的 BeginUpdate 和 EndUpdate 是 private
*           方法。在 IDE 中如果要大量添加图片，每次添加都会引起很多控件的刷新，
*           严重影响速度。特别是在 Delphi7 下，添加一张图片需要 70ms，对专家启动
*           性能影响很大，故编写该 Hook，提供 BeginUpdate 和 EndUpdate 功能。
*           另外，ActionList 也有类似的问题，同样处理。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2004.12.25 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Classes, SysUtils, Controls, ImgList, ActnList, CnWizMethodHook,
  CnWizUtils, CnWizIdeUtils;

// 开始更新 ImageList 和 ActionList
procedure CnListBeginUpdate;

// 结束更新
procedure CnListEndUpdate;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  TImageListAccess = class(TCustomImageList);
  TActionListAccess = class(TCustomActionList);
  TListChangeProc = procedure(Self: TCustomImageList);
  TListChangeMethod = procedure of object;

  TCnListComponent = class(TComponent)
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  end;
  
var
  FImageLists: TThreadList = nil;
  FActionLists: TThreadList = nil;
  FImageListHook: TCnMethodHook = nil;
  FActionListHook: TCnMethodHook = nil;
  FCnListComponent: TCnListComponent = nil;
  FUpdateCount: Integer = 0;

procedure TCnListComponent.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  FImageLists.Remove(AComponent);
  FActionLists.Remove(AComponent);
end;

procedure MyImageListChange(Self: TCustomImageList);
begin
  if (Self <> nil) and (Self is TCustomImageList) then
  begin
    Self.FreeNotification(FCnListComponent);
    FImageLists.Add(Self);

// 此通知机制已去除，IDE 的主 ImageList 后面如更新，得不到通知了
//    if Self = GetIDEImageList then
//      ClearIDEBigImageList;
  end;
end;

procedure MyActionListChange(Self: TCustomActionList);
begin
  if (Self <> nil) and (Self is TCustomActionList) then
  begin
    Self.FreeNotification(FCnListComponent);
    FActionLists.Add(Self);
  end;
end;

procedure CnListBeginUpdate;
var
  Method: TListChangeMethod;
begin
  if FUpdateCount = 0 then
  begin
    FImageLists := TThreadList.Create;
    FImageLists.Duplicates := dupIgnore;

    FActionLists := TThreadList.Create;
    FActionLists.Duplicates := dupIgnore;

    FCnListComponent := TCnListComponent.Create(nil);

    Method := TImageListAccess(GetIDEImageList).Change;
    FImageListHook := TCnMethodHook.Create(GetBplMethodAddress(TMethod(Method).Code),
      @MyImageListChange);
      
    Method := TActionListAccess(GetIDEActionList).Change;
    FActionListHook := TCnMethodHook.Create(GetBplMethodAddress(TMethod(Method).Code),
      @MyActionListChange);
  end;
  
  Inc(FUpdateCount);
end;

procedure CnListEndUpdate;
var
  I: Integer;
begin
  Dec(FUpdateCount);

  if FUpdateCount = 0 then
  begin
    FreeAndNil(FImageListHook);
    FreeAndNil(FActionListHook);
    FreeAndNil(FCnListComponent);

    with FImageLists.LockList do
    try
      for I := Count - 1 downto 0 do
        TImageListAccess(Items[I]).Change;
    finally
      FImageLists.UnlockList;
    end;

    with FActionLists.LockList do
    try
      for I := Count - 1 downto 0 do
        TActionListAccess(Items[I]).Change;
    finally
      FActionLists.UnlockList;
    end;
    
    FreeAndNil(FImageLists);
    FreeAndNil(FActionLists);
  end;
end;

end.
