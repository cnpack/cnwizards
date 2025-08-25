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

unit CnFloatWindow;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：浮动窗，供输入助手以及浮动工具栏等使用
* 单元作者：Johnson Zhong zhongs@tom.com http://www.longator.com
*           周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：PWinXP + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2015.07.21
*               从代码输入助手移出
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
  {* 浮动窗体实现类}
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
  {* 浮动列表框实现类}
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
    {* 是否使用编辑器配色，也即是否自动将编辑器的配色设置同步到下面的属性中
      注意是否绘制时使用以下配色取决于子类的 OnDrawItem 事件，不在本类中控制}

    // 以下仨使用编辑器配色
    property BackColor: TColor read FBackColor write FBackColor;
    property FontColor: TColor read FFontColor write FFontColor;
    property KeywordColor: TColor read FKeywordColor write FKeywordColor;

    // 以下仨没用编辑器颜色，根据主题生硬切换
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
  csDarkMatchColor = $006060FF;   // 浅红

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
  else // 高低版本都不阴影
  begin
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('%s Create with Shadow.', [AName]);
{$ENDIF}
  end;
end;

//==============================================================================
// 浮动窗体
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
// 浮动列表框
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
  FBackColor := clWindow;       // 默认弹窗未选中条目的背景色，主题状态下会感知主题
  FFontColor := clWindowText;   // 默认弹窗未选中条目的文字颜色，主题状态下会感知主题
  FSelectBackColor := clHighlight;      // 选中条目的背景色
  FSelectFontColor := clHighlightText;  // 选中条目的文字色
  FMatchColor := csMatchColor;          // 匹配色
  FKeywordColor := clBlue;              // 关键字颜色
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
  // 拿编辑器背景色给 FBackColor，普通标识符文字色给 FFontColor
  Control := GetCurrentEditControl;
  if Control <> nil then
  begin
    FBackColor := TControlHack(Control).Color;
    // 不能直接用 TControlHack(Control).Font.Color，不符合实际情况，得用高亮设置里的普通标识符颜色
    FFontColor := EditControlWrapper.FontIdentifier.Color;
    FKeywordColor := EditControlWrapper.FontKeyWord.Color;

    // 关键字和普通字都是黑色时，关键字搞成蓝色以示区分
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
  // 10.4 下主题混乱，不得不禁用下拉框的主题
  TStyleManager.Engine.RegisterStyleHook(TCnFloatListBox, TStyleHook);
{$ENDIF}

end.
