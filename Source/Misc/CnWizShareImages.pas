{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2021 CnPack 开发组                       }
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

unit CnWizShareImages;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：共享 ImageList 单元
* 单元作者：CnPack开发组
* 备    注：该单元定义了 CnPack IDE 专家包共享的工具栏 ImageList 
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.04.18 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, Graphics, Forms, ImgList, Buttons, Controls,
  {$IFNDEF STAND_ALONE} CnWizUtils,  CnWizOptions, CnWizIdeUtils, {$ENDIF}
  CnGraphUtils;

type
  TdmCnSharedImages = class(TDataModule)
    Images: TImageList;
    DisabledImages: TImageList;
    SymbolImages: TImageList;
    ilBackForward: TImageList;
    ilInputHelper: TImageList;
    ilProcToolBar: TImageList;
    ilBackForwardBDS: TImageList;
    ilProcToolbarLarge: TImageList;
    ilColumnHeader: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FIdxUnknownInIDE: Integer;
    FIdxUnknown: Integer;
{$IFNDEF STAND_ALONE}
    FIDEOffset: Integer;
    FCopied: Boolean;
{$ENDIF}
  public
    { Public declarations }
    property IdxUnknown: Integer read FIdxUnknown;
    property IdxUnknownInIDE: Integer read FIdxUnknownInIDE;
{$IFNDEF STAND_ALONE}
    procedure GetSpeedButtonGlyph(Button: TSpeedButton; ImageList: TImageList; 
      EmptyIdx: Integer);

    procedure CopyToIDEMainImageList;
    // Images 会被复制进 IDE 的 ImageList 供统一处理，FIDEOffset 表示偏移量

    function GetMixedImageList: TCustomImageList;
    function CalcMixedImageIndex(ImageIndex: Integer): Integer;
{$ENDIF}
  end;

var
  dmCnSharedImages: TdmCnSharedImages;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.dfm}

procedure TdmCnSharedImages.DataModuleCreate(Sender: TObject);
{$IFNDEF STAND_ALONE}
const
  MaskColor = clBtnFace;
var
  ImgLst: TCustomImageList;
  Bmp, Src, Dst: TBitmap;
  Save: TColor;
  Rs, Rd: TRect;
  I: Integer;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  FIdxUnknown := 66;
  ImgLst := GetIDEImageList;
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Save := Images.BkColor;
    Images.BkColor := clFuchsia;
    Images.GetBitmap(IdxUnknown, Bmp);
    FIdxUnknownInIDE := ImgLst.AddMasked(Bmp, clFuchsia);
    Images.BkColor := Save;
  finally
    Bmp.Free;
  end;

  if WizOptions.UseLargeIcon then
  begin
    // 从小的 ImageList 中拉扯绘制，把 16*16 扩展到 24* 24
    Src := nil;
    Dst := nil;
    try
      Src := CreateEmptyBmp24(16, 16, MaskColor);
      Dst := CreateEmptyBmp24(24, 24, MaskColor);

      Rs := Rect(0, 0, Src.Width, Src.Height);
      Rd := Rect(0, 0, Dst.Width, Dst.Height);

      Src.Canvas.Brush.Color := MaskColor;
      Src.Canvas.Brush.Style := bsSolid;
      Dst.Canvas.Brush.Color := clFuchsia;
      Dst.Canvas.Brush.Style := bsSolid;

      for I := 0 to ilProcToolbar.Count - 1 do
      begin
        Src.Canvas.FillRect(Rs);
        ilProcToolbar.GetBitmap(I, Src);
        Dst.Canvas.FillRect(Rd);
        Dst.Canvas.StretchDraw(Rd, Src);
        ilProcToolbarLarge.AddMasked(Dst, MaskColor);
      end;
    finally
      Src.Free;
      Dst.Free;
    end;
  end;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function TdmCnSharedImages.CalcMixedImageIndex(
  ImageIndex: Integer): Integer;
begin
  if FCopied and (ImageIndex >= 0) then
    Result := ImageIndex + FIDEOffset
  else
    Result := ImageIndex;
end;

function TdmCnSharedImages.GetMixedImageList: TCustomImageList;
begin
  if FCopied then
    Result := GetIDEImageList
  else
    Result := Images;
end;

procedure TdmCnSharedImages.CopyToIDEMainImageList;
var
  IDEs: TCustomImageList;
  Cnt: Integer;
begin
  if FCopied then
    Exit;

  IDEs := GetIDEImageList;
  if (IDEs <> nil) and (IDEs.Width = Images.Width) and (IDEs.Height = Images.Height) then
  begin
    Cnt := IDEs.Count;
    IDEs.AddImages(Images);
    FIDEOffset := Cnt;
    FCopied := True;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add %d Images to IDE Main ImageList. Offset %d.', [Images.Count, FIDEOffset]);
{$ENDIF}
  end;
end;

procedure TdmCnSharedImages.GetSpeedButtonGlyph(Button: TSpeedButton;
  ImageList: TImageList; EmptyIdx: Integer);
var
  Save: TColor;
begin
  Button.Glyph.TransparentMode := tmFixed; // 强制透明
  Button.Glyph.TransparentColor := clFuchsia;
  if Button.Glyph.Empty then
  begin
    Save := dmCnSharedImages.Images.BkColor;
    ImageList.BkColor := clFuchsia;
    ImageList.GetBitmap(EmptyIdx, Button.Glyph);
    ImageList.BkColor := Save;
  end;    
  // 调整按钮位图以解决有些按钮 Disabled 时无图标的问题
  AdjustButtonGlyph(Button.Glyph);
  Button.NumGlyphs := 2;
end;

{$ENDIF}

end.
