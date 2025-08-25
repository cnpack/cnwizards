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

unit CnFloatWindow;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��������������������Լ�������������ʹ��
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.07.21
*               �Ӵ������������Ƴ�
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, Windows, Controls, SysUtils, Messages, Graphics, StdCtrls, Math,
  {$IFDEF LAZARUS} LCLType, {$ENDIF}
  CnCommon {$IFNDEF STAND_ALONE}, {$IFDEF DELPHI104_SYDNEY_UP} Vcl.Themes, {$ENDIF}
  CnWizIdeUtils, CnEditControlWrapper {$ENDIF};

const
  CS_DROPSHADOW = $20000;

type
{ TCnFloatWindow }

  TCnFloatWindow = class(TCustomControl)
  {* ��������ʵ����}
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

  TCnFloatListBox = class(TCustomListBox)
  {* �����б��ʵ����}
  private
    FSelectFontColor: TColor;
    FFontColor: TColor;
    FBackColor: TColor;
    FMatchColor: TColor;
    FSelectBackColor: TColor;
    FKeywordColor: TColor;
    FUseEditorColor: Boolean;
    procedure InitOriginalColors;
    function AdjustHeight(AHeight: Integer): Integer;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CNCancelMode(var Message: TMessage); message CM_CANCELMODE;
    procedure SetUseEditorColor(const Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
{$IFNDEF FPC}
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateColor;
    procedure SetCount(const Value: Integer);

    procedure SetPos(X, Y: Integer); virtual;
    procedure CloseUp; virtual;
    procedure Popup; virtual;

    property UseEditorColor: Boolean read FUseEditorColor write SetUseEditorColor;
    {* �Ƿ�ʹ�ñ༭����ɫ��Ҳ���Ƿ��Զ����༭������ɫ����ͬ���������������
      ע���Ƿ����ʱʹ��������ɫȡ��������� OnDrawItem �¼������ڱ����п���}

    // ������ʹ�ñ༭����ɫ
    property BackColor: TColor read FBackColor write FBackColor;
    property FontColor: TColor read FFontColor write FFontColor;
    property KeywordColor: TColor read FKeywordColor write FKeywordColor;

    // ������û�ñ༭����ɫ������������Ӳ�л�
    property MatchColor: TColor read FMatchColor write FMatchColor;
    property SelectBackColor: TColor read FSelectBackColor write FSelectBackColor;
    property SelectFontColor: TColor read FSelectFontColor write FSelectFontColor;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csMatchColor = clRed;
  csDarkMatchColor = $006060FF;   // ǳ��

type
  TControlHack = class(TControl);

procedure AdjustShadowParam(var Params: TCreateParams; const AName: string);
begin
  if {$IFDEF DELPHI104_SYDNEY_UP} True or {$ENDIF} CheckWin8 or CheckWindowsNT then
  begin
    Params.WindowClass.style := CS_DBLCLKS;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('%s Create with NO Shadow.', [AName]);
{$ENDIF}
  end
  else // �ߵͰ汾������Ӱ
  begin
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('%s Create with Shadow.', [AName]);
{$ENDIF}
  end;
end;

//==============================================================================
// ��������
//==============================================================================

{ TCnFloatWindow }

procedure TCnFloatWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW or WS_MAXIMIZEBOX;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;

  AdjustShadowParam(Params, ClassName);
end;

procedure TCnFloatWindow.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

procedure TCnFloatWindow.Paint;
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

//==============================================================================
// �����б��
//==============================================================================

{ TCnFloatListBox }

function TCnFloatListBox.AdjustHeight(AHeight: Integer): Integer;
var
  BorderSize: Integer;
begin
  BorderSize := Height - ClientHeight;
  Result := Max((AHeight - BorderSize) div ItemHeight, 4) * ItemHeight + BorderSize;
end;

{$IFNDEF FPC}

function TCnFloatListBox.CanResize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
  NewHeight := AdjustHeight(NewHeight);
  Result := True;
end;

{$ENDIF}

procedure TCnFloatListBox.CloseUp;
begin
  Visible := False;
end;

procedure TCnFloatListBox.CNCancelMode(var Message: TMessage);
begin
  CloseUp;
end;

procedure TCnFloatListBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
{$IFDEF FPC}
    State := TOwnerDrawState(itemState);
{$ELSE}
    State := TOwnerDrawState(LongRec(itemState).Lo);
{$ENDIF}
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Brush.Color := FBackColor;
      Canvas.Font.Color := FFontColor;
    end;

    if Integer(itemID) >= 0 then
    begin
      if Assigned(OnDrawItem) then
        OnDrawItem(Self, itemID, rcItem, State);
    end
    else
      Canvas.FillRect(rcItem);
    Canvas.Handle := 0;
  end;
end;

procedure TCnFloatListBox.CNMeasureItem(var Message: TWMMeasureItem);
begin
  Message.MeasureItemStruct^.itemHeight := ItemHeight;
end;

constructor TCnFloatListBox.Create(AOwner: TComponent);
begin
  inherited;
  Visible := False;
  Style := lbOwnerDrawFixed;

  FUseEditorColor := True;
  InitOriginalColors;

  ShowHint := True;
  Font.Name := 'Tahoma';
  Font.Size := 8;
end;

procedure TCnFloatListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := (Params.Style or WS_CHILDWINDOW or WS_SIZEBOX or WS_MAXIMIZEBOX
    or LBS_NODATA or LBS_OWNERDRAWFIXED) and not (LBS_SORT or LBS_HASSTRINGS);
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;

  AdjustShadowParam(Params, ClassName);
end;

procedure TCnFloatListBox.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
  Height := AdjustHeight(Height);
end;

destructor TCnFloatListBox.Destroy;
begin

  inherited;
end;

procedure TCnFloatListBox.InitOriginalColors;
begin
  FBackColor := clWindow;       // Ĭ�ϵ���δѡ����Ŀ�ı���ɫ������״̬�»��֪����
  FFontColor := clWindowText;   // Ĭ�ϵ���δѡ����Ŀ��������ɫ������״̬�»��֪����
  FSelectBackColor := clHighlight;      // ѡ����Ŀ�ı���ɫ
  FSelectFontColor := clHighlightText;  // ѡ����Ŀ������ɫ
  FMatchColor := csMatchColor;          // ƥ��ɫ
  FKeywordColor := clBlue;              // �ؼ�����ɫ
end;

procedure TCnFloatListBox.Popup;
begin
  UpdateColor;
  Visible := True;
end;

procedure TCnFloatListBox.SetCount(const Value: Integer);
var
  Error: Integer;
begin
{$IFDEF DEBUG}
  if Value <> 0 then
    CnDebugger.LogInteger(Value, 'TCnFloatListBox.SetCount');
{$ENDIF}
  // Limited to 32767 on Win95/98 as per Win32 SDK
  Error := SendMessage(Handle, LB_SETCOUNT, Min(Value, 32767), 0);
  if (Error = LB_ERR) or (Error = LB_ERRSPACE) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('TCnFloatListBox.SetCount Error: ' + IntToStr(Error), cmtError);
  {$ENDIF}
  end;
end;

procedure TCnFloatListBox.SetPos(X, Y: Integer);
begin
  SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
end;

procedure TCnFloatListBox.SetUseEditorColor(const Value: Boolean);
begin
  FUseEditorColor := Value;
end;

procedure TCnFloatListBox.UpdateColor;
{$IFNDEF STAND_ALONE}
var
  Control: TControl;
{$ENDIF}
begin
  if not FUseEditorColor then
  begin
    InitOriginalColors;
    Exit;
  end;

{$IFDEF DELPHI_OTA}
  // �ñ༭������ɫ�� FBackColor����ͨ��ʶ������ɫ�� FFontColor
  Control := GetCurrentEditControl;
  if Control <> nil then
  begin
    FBackColor := TControlHack(Control).Color;
    // ����ֱ���� TControlHack(Control).Font.Color��������ʵ����������ø������������ͨ��ʶ����ɫ
    FFontColor := EditControlWrapper.FontIdentifier.Color;
    FKeywordColor := EditControlWrapper.FontKeyWord.Color;

    // �ؼ��ֺ���ͨ�ֶ��Ǻ�ɫʱ���ؼ��ָ����ɫ��ʾ����
    if (ColorToRGB(FFontColor) = clBlack) and (ColorToRGB(FKeywordColor) = clBlack) then
      FKeywordColor := clBlue;

    if CnThemeWrapper.IsUnderDarkTheme then
    begin
      FSelectBackColor := csDarkHighlightBkColor;
      FSelectFontColor := csDarkHighlightFontColor;
      FMatchColor := csDarkMatchColor;
    end
    else
    begin
      FSelectBackColor := clHighlight;
      FSelectFontColor := clHighlightText;
      FMatchColor := csMatchColor;
    end;
  end;

  Color := FBackColor;
{$ENDIF}
end;

initialization
{$IFDEF DELPHI104_SYDNEY_UP}
  // 10.4 ��������ң����ò����������������
  TStyleManager.Engine.RegisterStyleHook(TCnFloatListBox, TStyleHook);
{$ENDIF}

end.
