{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnFrmMatchButton;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����������Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע�����������߰�ť�������˵�ѡ��ƥ�䷽ʽ�Ĺ��� Frame
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.04.30
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ToolWin, CnStrings, CnWizOptions;

type
  TCnMatchButtonFrame = class(TFrame)
    tlb1: TToolBar;
    btnMatchMode: TToolButton;
    pmMatchMode: TPopupMenu;
    mniMatchStart: TMenuItem;
    mniMatchAny: TMenuItem;
    mniMatchFuzzy: TMenuItem;
    procedure mniMatchClick(Sender: TObject);
    procedure btnMatchModeClick(Sender: TObject);
  private
    FOnModeChange: TNotifyEvent;
    function GetMatchMode: TCnMatchMode;
    procedure SetMatchMode(const Value: TCnMatchMode);
  protected
    procedure DoModeChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SyncButtonHint;

    property MatchMode: TCnMatchMode read GetMatchMode write SetMatchMode;
    property OnModeChange: TNotifyEvent read FOnModeChange write FOnModeChange;
  end;

implementation

{$R *.DFM}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF} CnWizShareImages;

{ TCnMatchButtonFrame }

procedure TCnMatchButtonFrame.DoModeChange;
begin
  if Assigned(FOnModeChange) then
    FOnModeChange(Self);
end;

function TCnMatchButtonFrame.GetMatchMode: TCnMatchMode;
begin
  if mniMatchStart.Checked then
    Result := mmStart
  else if mniMatchAny.Checked then
    Result := mmAnywhere
  else
    Result := mmFuzzy;
end;

procedure TCnMatchButtonFrame.SetMatchMode(const Value: TCnMatchMode);
var
  I, Idx: Integer;
begin
  if Value <> MatchMode then
  begin
    Idx := Ord(Value);
    if (Idx < 0) or (Idx >= pmMatchMode.Items.Count) then
      Exit;

    for I := 0 to pmMatchMode.Items.Count - 1 do
      pmMatchMode.Items[I].Checked := False;

    pmMatchMode.Items.Items[Idx].Checked := True;
    btnMatchMode.ImageIndex := pmMatchMode.Items.Items[Idx].ImageIndex;
    SyncButtonHint;

    DoModeChange;
  end;
end;

procedure TCnMatchButtonFrame.mniMatchClick(Sender: TObject);
var
  Idx: Integer;
begin
  if Sender is TMenuItem then
  begin
    Idx := (Sender as TMenuItem).MenuIndex;
    if TCnMatchMode(Idx) in [Low(TCnMatchMode)..High(TCnMatchMode)] then
      MatchMode := TCnMatchMode(Idx);
  end;
end;

procedure TCnMatchButtonFrame.btnMatchModeClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := Ord(MatchMode);
  if Idx = Ord(High(TCnMatchMode)) then
    Idx := 0
  else
    Inc(Idx);

  MatchMode := TCnMatchMode(Idx);
end;

procedure TCnMatchButtonFrame.SyncButtonHint;
var
  Idx: Integer;
begin
  Idx := Ord(MatchMode);
  if (Idx >= 0) and (Idx < pmMatchMode.Items.Count) then
    btnMatchMode.Hint := pmMatchMode.Items.Items[Idx].Hint;
end;

constructor TCnMatchButtonFrame.Create(AOwner: TComponent);
begin
  inherited;
{$IFNDEF STAND_ALONE}
{$IFDEF DELPHI_IDE_WITH_HDPI}
  if WizOptions.UseLargeIcon then
    pmMatchMode.Images := dmCnSharedImages.LargeVirtualImages
  else
    pmMatchMode.Images := dmCnSharedImages.VirtualImages;
{$ELSE}
  if WizOptions.UseLargeIcon then
    pmMatchMode.Images := dmCnSharedImages.LargeImages;
{$ENDIF}
{$ENDIF}
end;

end.
