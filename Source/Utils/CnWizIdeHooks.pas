{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizIdeHooks;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ImageList ���� Hook ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��VCL �� TCustomImageList �ṩ�� BeginUpdate �� EndUpdate �� private
*           �������� IDE �����Ҫ�������ͼƬ��ÿ����Ӷ�������ܶ�ؼ���ˢ�£�
*           ����Ӱ���ٶȡ��ر����� Delphi7 �£����һ��ͼƬ��Ҫ 70ms����ר������
*           ����Ӱ��ܴ󣬹ʱ�д�� Hook���ṩ BeginUpdate �� EndUpdate ���ܡ�
*           ���⣬ActionList Ҳ�����Ƶ����⣬ͬ������
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2004.12.25 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  Windows, Classes, SysUtils, Controls, ImgList, ActnList, CnWizMethodHook,
  CnWizUtils;

// ��ʼ���� ImageList �� ActionList
procedure CnListBeginUpdate;

// ��������
procedure CnListEndUpdate;

implementation

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
begin
  if FUpdateCount = 0 then
  begin
    FImageLists := TThreadList.Create;
    FImageLists.Duplicates := dupIgnore;

    FActionLists := TThreadList.Create;
    FActionLists.Duplicates := dupIgnore;

    FCnListComponent := TCnListComponent.Create(nil);

    FImageListHook := TCnMethodHook.Create(@TImageListAccess.Change,
      @MyImageListChange);

    FActionListHook := TCnMethodHook.Create(@TActionListAccess.Change,
      @MyActionListChange);
  end;
  
  Inc(FUpdateCount);
end;

procedure CnListEndUpdate;
var
  i: Integer;
begin
  Dec(FUpdateCount);
  
  if FUpdateCount = 0 then
  begin
    FreeAndNil(FImageListHook);
    FreeAndNil(FActionListHook);
    FreeAndNil(FCnListComponent);

    with FImageLists.LockList do
    try
      for i := Count - 1 downto 0 do
        TImageListAccess(Items[i]).Change;
    finally
      FImageLists.UnlockList;
    end;

    with FActionLists.LockList do
    try
      for i := Count - 1 downto 0 do
        TActionListAccess(Items[i]).Change;
    finally
      FActionLists.UnlockList;
    end;
    
    FreeAndNil(FImageLists);
    FreeAndNil(FActionLists);
  end;
end;

end.
