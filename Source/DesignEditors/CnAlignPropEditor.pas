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

unit CnAlignPropEditor;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：Align属性编辑器单元
* 单元作者：real-like@163.com
* 备    注：
* 开发平台：Windows2000Pro + Delphi 6.1
* 兼容测试：PWin2000Pro + Delphi 6
* 本 地 化：
* 修改记录：2012-12-21 V1.1
*               加入编辑状态的图标绘制
*           2004-11-16 V1.0 by Leeon
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, SysUtils, Classes,
  Graphics, TypInfo, Controls,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnDesignEditor, CnDesignEditorConsts, CnConsts;

type

  TCnAlignProperty = class(TEnumProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyDrawing, ICustomPropertyListDrawing
      {$IFDEF COMPILER9_UP}, ICustomPropertyDrawing80{$ENDIF}
    {$ENDIF})
  private
    procedure DrawAlignBitmap(const Value: string; ACanvas: TCanvas;
      var ARect: TRect; ASelected, AListDraw: Boolean);
  public
  {$IFDEF COMPILER6_UP}
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    {$IFDEF COMPILER9_UP}
      function PropDrawNameRect(const ARect: TRect): TRect;
      function PropDrawValueRect(const ARect: TRect): TRect;
    {$ENDIF}
  {$ELSE}
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer); override;
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer); override;
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
      override;
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean); override;
  {$ENDIF}
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
  end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R CnAlignPropEditor.res}

const
  AlignResNames: array[TAlign] of string = (
    'CN_ALIGN_NONE',
    'CN_ALIGN_TOP',
    'CN_ALIGN_BOTTOM',
    'CN_ALIGN_LEFT',
    'CN_ALIGN_RIGHT',
    'CN_ALIGN_CLIENT'
  {$IFDEF COMPILER6_UP}
    , 'CN_ALIGNPROP_CUSTOM'
  {$ENDIF}
  );

  AlignPropResNames: array[TAlign] of string = (
    'CN_ALIGNPROP_NONE',
    'CN_ALIGNPROP_TOP',
    'CN_ALIGNPROP_BOTTOM',
    'CN_ALIGNPROP_LEFT',
    'CN_ALIGNPROP_RIGHT',
    'CN_ALIGNPROP_CLIENT'
  {$IFDEF COMPILER6_UP}
    , 'CN_ALIGNPROP_CUSTOM'
  {$ENDIF}
  );

  csItemHeight = 24;
  csItemWidth = 24;
{$IFDEF COMPILER9_UP}
  csItemBorder = 3;
{$ELSE}
  csItemBorder = 2;
{$ENDIF}

class procedure TCnAlignProperty.GetInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnAlignPropEditorName;
  Author := SCnPack_Leeon;
  Email := SCnPack_LeeonEmail;
  Comment := SCnAlignPropEditorComment;
end;

procedure TCnAlignProperty.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
begin
  if AHeight < csItemHeight then
    AHeight := csItemHeight;
end;

procedure TCnAlignProperty.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + csItemWidth;
end;

{$IFDEF COMPILER6_UP}
procedure TCnAlignProperty.PropDrawName(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;
{$ENDIF}

procedure TCnAlignProperty.DrawAlignBitmap(const Value: string;
  ACanvas: TCanvas; var ARect: TRect; ASelected, AListDraw: Boolean);
var
  Align: TAlign;
  Bmp: TBitmap;
  R: TRect;
begin
  if Value <> '' then
  begin
    Bmp := TBitmap.Create;
    try
      Align := TAlign(GetEnumValue(GetPropInfo^.PropType^, Value));
      if AListDraw then
        Bmp.Handle := LoadBitmap(HInstance, PChar(AlignResNames[Align]))
      else
        Bmp.Handle := LoadBitmap(HInstance, PChar(AlignPropResNames[Align]));
      Bmp.Transparent := True;
      Bmp.TransparentColor := clFuchsia;
      
      R := ARect;
      R.Right := ARect.Left + csItemBorder * 2 + Bmp.Width;
      ACanvas.FillRect(R);
      ACanvas.Draw(R.Left + csItemBorder, (R.Top + R.Bottom - Bmp.Height) div 2, Bmp);

      ARect.Left := ARect.Left + csItemBorder * 2 + Bmp.Width;
    finally
      Bmp.Free;
    end;
  end;
end;

procedure TCnAlignProperty.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
var
  R: TRect;
begin
  R := ARect;
  DrawAlignBitmap(GetVisualValue, ACanvas, R, ASelected, False);
{$IFDEF COMPILER6_UP}
  DefaultPropertyDrawValue(Self, ACanvas, R);
{$ELSE}
  inherited PropDrawValue(ACanvas, R, ASelected);
{$ENDIF}
end;

{$IFDEF COMPILER9_UP}
function TCnAlignProperty.PropDrawNameRect(const ARect: TRect): TRect;
begin
  Result := ARect;
end;

function TCnAlignProperty.PropDrawValueRect(const ARect: TRect): TRect;
begin
  Result := Rect(ARect.Left, ARect.Top, (ARect.Bottom - ARect.Top) + ARect.Left, ARect.Bottom);
end;
{$ENDIF}

procedure TCnAlignProperty.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  R: TRect;
begin
  R := ARect;
  DrawAlignBitmap(Value, ACanvas, R, ASelected, True);
{$IFDEF COMPILER6_UP}
  DefaultPropertyListDrawValue(Value, ACanvas, R, ASelected);
{$ELSE}
  inherited ListDrawValue(Value, ACanvas, R, ASelected);
{$ENDIF}
end;

class procedure TCnAlignProperty.Register;
begin
  RegisterPropertyEditor(TypeInfo(TAlign), TWinControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TGraphicControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TComponent, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TPersistent, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), nil, '', TCnAlignProperty);
end;

initialization
{$IFNDEF COMPILER22_UP}
  // XE8 及以上，自带 Align 属性编辑器，因此不需要了。
  CnDesignEditorMgr.RegisterPropEditor(TCnAlignProperty,
    TCnAlignProperty.GetInfo, TCnAlignProperty.Register);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnAlignPropEditor.');
{$ENDIF}

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
