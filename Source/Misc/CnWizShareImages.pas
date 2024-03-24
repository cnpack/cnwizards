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

unit CnWizShareImages;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：共享 ImageList 单元
* 单元作者：CnPack 开发组
* 备    注：该单元定义了 CnPack IDE 专家包共享的工具栏 ImageList
*           注意：D11 以及之之后的 IDE 支持 HDPI，不能直接用 ImageList 了
*          （因为尺寸固定为物理像素不可变导致绘制太小），普通尺寸模式下全得用
*           经过 HDPI 放大过后的像素大小的 VirtualImageList，大尺寸模式下更得用
*           经过 HDPI 放大过后的大尺寸像素大小的 VirtualImageList。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2021.09.15 V1.1
*               支持 HDPI 可变分辨率组件
*           2003.04.18 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, Graphics, Forms, ImgList, Buttons, Controls,
  {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF}
  {$IFDEF SUPPORT_GDIPLUS} WinApi.GDIPOBJ, WinApi.GDIPAPI, {$ENDIF}
  {$IFNDEF STAND_ALONE} CnWizUtils, CnWizOptions, CnWizIdeUtils, {$ENDIF}
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
    LargeImages: TImageList;
    DisabledLargeImages: TImageList;
    IDELargeImages: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    FIdxUnknown: Integer;
{$IFDEF IDE_SUPPORT_HDPI}
    FIdxUnknownLargeInIDE: Integer;
    FImageCollection: TImageCollection;       // 普通尺寸与大尺寸的 Images 对应的 Collection
    FVirtualImages: TVirtualImageList;        // 对应普通尺寸的 Images
    FLargeVirtualImages: TVirtualImageList;   // 对应大尺寸的 Images，非放大时不创建
    FDisabledImageCollection: TImageCollection;       // 普通尺寸与大尺寸的 DisabledImages 对应的 Collection
    FDisabledVirtualImages: TVirtualImageList;        // 对应普通尺寸的 DisabledImages
    FDisabledLargeVirtualImages: TVirtualImageList;   // 对应大尺寸 DisabledImages，非放大时不创建
    FProcToolbarImageCollection: TImageCollection;      // 普通尺寸与大尺寸的 ilProcToolbarLarge 对应的 Collection
    FProcToolbarVirtualImages: TVirtualImageList;       // 对应普通尺寸的 ilProcToolbar
    FLargeProcToolbarVirtualImages: TVirtualImageList;  // 对应大尺寸的 ilProcToolbar，非放大时不创建

    FIDELargeVirtualImages: TVirtualImageList;   // 对应 IDELargeImages 与 IDELargeDisabledImages，非放大时不创建
    FLargeIDEOffset: Integer; // D110A 之后大图标偏移值不同
{$ENDIF}
{$IFNDEF STAND_ALONE}
    FIdxUnknownInIDE: Integer;
    FIDEOffset: Integer;      // D110A 之前，无论是否大图标都用这个值
    FCopied: Boolean;         // 记录我们的 ImageList 有无塞到 IDE 的 ImageList 中
    FLargeCopied: Boolean;    // 记录 IDE 的 ImageList 有无复制一份大的
    FLargeCopiedCount: Integer; // 记录 IDE 的 ImageList 复制一份大的数量
    function GetIdxUnknownInIDE: Integer;
{$ENDIF}
  public
    property IdxUnknown: Integer read FIdxUnknown;
{$IFNDEF STAND_ALONE}
    property IdxUnknownInIDE: Integer read GetIdxUnknownInIDE;
{$ENDIF}

    procedure StretchCopyToLarge(SrcImageList, DstImageList: TCustomImageList);
    {* 内外都使用，供将小尺寸 ImageList 拉伸绘制到大的 ImageList 上}
    procedure CenterCopyTo(SrcImageList, DstImageList: TCustomImageList);
    {* 供将小尺寸 ImageList 原尺寸居中绘制到大的 ImageList 上}

{$IFNDEF STAND_ALONE}
    procedure GetSpeedButtonGlyph(Button: TSpeedButton; ImageList: TImageList; 
      EmptyIdx: Integer);
    procedure CopyToIDEMainImageList;
    // Images 会被复制进 IDE 的 ImageList 供图标被同时使用的场合，FIDEOffset 表示偏移量
    procedure CopyLargeIDEImageList(Force: Boolean = False);
    // 由专家全部创建并加载菜单项后调用，把 IDE 的 ImageList 再复制一份大的
    // 注意这个会被至少重复调两次，一次靠前以初始化专家管理器相关，一次 IDE 加载完成以反映最新图标
    // Force 为 True 时表示在 FLargeCopied 为 True 时判断数量，不等则再进行一次复制

    function GetMixedImageList(ForceSmall: Boolean = False): TCustomImageList;
    function CalcMixedImageIndex(ImageIndex: Integer): Integer;

{$IFDEF IDE_SUPPORT_HDPI}
    property VirtualImages: TVirtualImageList read FVirtualImages;
    property LargeVirtualImages: TVirtualImageList read FLargeVirtualImages;
    {* D110A 或以上，因为 IDE 中没有，故普通工具栏用这个，普通尺寸和大尺寸}
    property DisabledVirtualImages: TVirtualImageList read FDisabledVirtualImages;
    property DisabledLargeVirtualImages: TVirtualImageList read FDisabledLargeVirtualImages;
    {* D110A 或以上，因为 IDE 中没有，普通工具栏禁用状态用这个，普通尺寸和大尺寸}
    property ProcToolbarVirtualImages: TVirtualImageList read FProcToolbarVirtualImages;
    property LargeProcToolbarVirtualImages: TVirtualImageList read FLargeProcToolbarVirtualImages;
    {* D110A 或以上，因为 IDE 中没有，故函数列表工具栏需要用这个，普通尺寸和大尺寸}

    property IDELargeVirtualImages: TVirtualImageList read FIDELargeVirtualImages;
    {* 大尺寸下的 D110A 或以上，编辑器工具栏等需要 IDE 的用这个}
{$ENDIF}
{$ENDIF}
  end;

var
  dmCnSharedImages: TdmCnSharedImages;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

const
  MaskColor = clBtnFace;

procedure TdmCnSharedImages.StretchCopyToLarge(SrcImageList,
  DstImageList: TCustomImageList);
var
  Src, Dst: TBitmap;
  Rs, Rd: TRect;
  I: Integer;
begin
  // 从小的 ImageList 中拉扯绘制，把 16*16 扩展到 24* 24
  Src := nil;
  Dst := nil;

{$IFNDEF SUPPORT_GDIPLUS}
  CnStartUpGdiPlus;
{$ENDIF}

  try
    Src := CreateEmptyBmp24(16, 16, MaskColor);
    Dst := CreateEmptyBmp24(24, 24, MaskColor);

    Rs := Rect(0, 0, Src.Width, Src.Height);
    Rd := Rect(0, 0, Dst.Width, Dst.Height);

    Src.Canvas.Brush.Color := MaskColor;
    Src.Canvas.Brush.Style := bsSolid;
    Dst.Canvas.Brush.Color := clFuchsia;
    Dst.Canvas.Brush.Style := bsSolid;

    for I := 0 to SrcImageList.Count - 1 do
    begin
      Src.Canvas.FillRect(Rs);
      SrcImageList.GetBitmap(I, Src);

      StretchDrawBmp(Src, Dst);
      DstImageList.AddMasked(Dst, MaskColor);
    end;
  finally
{$IFNDEF SUPPORT_GDIPLUS}
    CnShutDownGdiPlus;
{$ENDIF}
    Src.Free;
    Dst.Free;
  end;
end;

procedure TdmCnSharedImages.CenterCopyTo(SrcImageList,
  DstImageList: TCustomImageList);
var
  Src, Dst: TBitmap;
  Rs, Rd: TRect;
  I: Integer;
begin
  // 从小的 ImageList 中拉扯绘制，把小图居中画到大的
  Src := nil;
  Dst := nil;
  try
    Src := TBitmap.Create;
    Src.Width := SrcImageList.Width;
    Src.Height := SrcImageList.Height;
    Src.PixelFormat := pf24bit;

    Dst := TBitmap.Create;
    Dst.Width := DstImageList.Width;
    Dst.Height := DstImageList.Height;
    Dst.PixelFormat := pf24bit;

    Rs := Rect(0, 0, Src.Width, Src.Height);
    Rd := Rect(0, 0, Dst.Width, Dst.Height);

    Src.Canvas.Brush.Color := MaskColor;
    Src.Canvas.Brush.Style := bsSolid;
    Dst.Canvas.Brush.Color := clFuchsia;
    Dst.Canvas.Brush.Style := bsSolid;

    for I := 0 to SrcImageList.Count - 1 do
    begin
      Src.Canvas.FillRect(Rs);
      SrcImageList.GetBitmap(I, Src);
      Dst.Canvas.FillRect(Rd);
      Dst.Canvas.Draw((Dst.Width - Src.Width) div 2, (Dst.Height - Src.Height) div 2, Src);
      DstImageList.AddMasked(Dst, MaskColor);
    end;
  finally
    Src.Free;
    Dst.Free;
  end;
end;

procedure TdmCnSharedImages.DataModuleCreate(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  ImgLst: TCustomImageList;
{$IFDEF IDE_SUPPORT_HDPI}
  Ico: TIcon;
{$ELSE}
  Bmp: TBitmap;
  Save: TColor;
{$ENDIF}
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  FIdxUnknown := 66;
  ImgLst := GetIDEImageList;

{$IFDEF IDE_SUPPORT_HDPI}
  Ico := TIcon.Create;
  try
    Images.GetIcon(IdxUnknown, Ico);
    FIdxUnknownInIDE := AddGraphicToVirtualImageList(Ico,
      ImgLst as TVirtualImageList, 'CnWizardsUnknown');
  finally
    Ico.Free;
  end;
{$ELSE}
  Bmp := TBitmap.Create;        // 给 IDE 的主 List 加个 Unknown 的图标
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
{$ENDIF}

{$IFDEF IDE_SUPPORT_HDPI}
  FVirtualImages := TVirtualImageList.Create(Self);
  FVirtualImages.Name := 'CnVirtualImages';
  FImageCollection := TImageCollection.Create(Self);
  FImageCollection.Name := 'CnImageCollection';
  FVirtualImages.ImageCollection := FImageCollection;
  FVirtualImages.Width := IdeGetScaledPixelsFromOrigin(Images.Width);
  FVirtualImages.Height := IdeGetScaledPixelsFromOrigin(Images.Height);

  FDisabledVirtualImages := TVirtualImageList.Create(Self);
  FDisabledVirtualImages.Name := 'CnDisabledVirtualImages';
  FDisabledImageCollection := TImageCollection.Create(Self);
  FDisabledImageCollection.Name := 'CnDisabledImageCollection';
  FDisabledVirtualImages.ImageCollection := FDisabledImageCollection;
  FDisabledVirtualImages.Width := IdeGetScaledPixelsFromOrigin(DisabledImages.Width);
  FDisabledVirtualImages.Height := IdeGetScaledPixelsFromOrigin(DisabledImages.Height);

  FProcToolbarVirtualImages := TVirtualImageList.Create(Self);
  FProcToolbarVirtualImages.Name := 'CnProcToolbarVirtualImages';
  FProcToolbarImageCollection := TImageCollection.Create(Self);
  FProcToolbarImageCollection.Name := 'CnProcToolbarImageCollection';
  FProcToolbarVirtualImages.ImageCollection := FProcToolbarImageCollection;
  FProcToolbarVirtualImages.Width := IdeGetScaledPixelsFromOrigin(ilProcToolbar.Width);
  FProcToolbarVirtualImages.Height := IdeGetScaledPixelsFromOrigin(ilProcToolbar.Height);

  CopyImageListToVirtual(Images, FVirtualImages);
  CopyImageListToVirtual(DisabledImages, FDisabledVirtualImages);
  CopyImageListToVirtual(ilProcToolbar, FProcToolbarVirtualImages);
{$ENDIF}

  if WizOptions.UseLargeIcon then
  begin
    // 为大图标版做好准备
{$IFDEF IDE_SUPPORT_HDPI}
    FIDELargeVirtualImages := TVirtualImageList.Create(Self);
    FIDELargeVirtualImages.Name := 'CnIDELargeVirtualImages';
    FIDELargeVirtualImages.ImageCollection := GetIDEImagecollection;
    FIDELargeVirtualImages.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth);
    FIDELargeVirtualImages.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight);

    FLargeVirtualImages := TVirtualImageList.Create(Self);
    FLargeVirtualImages.Name := 'CnLargeVirtualImages';
    FLargeVirtualImages.ImageCollection := FImageCollection;
    FLargeVirtualImages.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth);
    FLargeVirtualImages.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight);

    FDisabledLargeVirtualImages := TVirtualImageList.Create(Self);
    FDisabledLargeVirtualImages.Name := 'CnDisabledLargeVirtualImages';
    FDisabledLargeVirtualImages.ImageCollection := FDisabledImageCollection;
    FDisabledLargeVirtualImages.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth);
    FDisabledLargeVirtualImages.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight);

    FLargeProcToolbarVirtualImages := TVirtualImageList.Create(Self);
    FLargeProcToolbarVirtualImages.Name := 'CnLargeProcToolbarVirtualImages';
    FLargeProcToolbarVirtualImages.ImageCollection := FProcToolbarImageCollection;
    FLargeProcToolbarVirtualImages.Width := IdeGetScaledPixelsFromOrigin(csLargeImageListWidth);
    FLargeProcToolbarVirtualImages.Height := IdeGetScaledPixelsFromOrigin(csLargeImageListHeight);

    // 大尺寸模式下，不重新创建 ImageColleciton，复用原始的，只是放大后加入 VirtualImageList
    FLargeVirtualImages.Add('', -1, -1, False);
    FDisabledLargeVirtualImages.Add('', -1, -1, False);
    FLargeProcToolbarVirtualImages.Add('', -1, -1, False);
{$ELSE}
    StretchCopyToLarge(ilProcToolbar, ilProcToolbarLarge);
    StretchCopyToLarge(Images, LargeImages);
    StretchCopyToLarge(DisabledImages, DisabledLargeImages);
{$ENDIF}
  end;

{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function TdmCnSharedImages.CalcMixedImageIndex(
  ImageIndex: Integer): Integer;
begin
  if FCopied and (ImageIndex >= 0) then
  begin
    Result := ImageIndex + FIDEOffset;
{$IFDEF IDE_SUPPORT_HDPI}
    if WizOptions.UseLargeIcon then
      Result := ImageIndex + FLargeIDEOffset;
{$ENDIF}
  end
  else
    Result := ImageIndex;
end;

function TdmCnSharedImages.GetMixedImageList(ForceSmall: Boolean): TCustomImageList;
begin
  if FCopied then
  begin
    if WizOptions.UseLargeIcon and not ForceSmall and FLargeCopied then
    begin
{$IFDEF IDE_SUPPORT_HDPI}
      Result := FIDELargeVirtualImages;
{$ELSE}
      Result := IDELargeImages;
{$ENDIF}
    end
    else
      Result := GetIDEImageList;
  end
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
  if IDEs <> nil then
  begin
    Cnt := IDEs.Count;
{$IFDEF IDE_SUPPORT_HDPI}
    if WizOptions.UseLargeIcon then
    begin
      // D11 及其以后，IDE 的主 ImageList 变 VirtualImageList 了，而且由于分辨率变化，FLargeOffset 得另求
      CopyVirtualImageList(IDEs as TVirtualImageList, FIDELargeVirtualImages);
      FLargeIDEOffset := FIDELargeVirtualImages.Count;
      FIDELargeVirtualImages.Clear;   // 这段只用来求 FIDELargeOffset
    end;
    CopyImageListToVirtual(Images, IDEs as TVirtualImageList, 'CnWizardsItem');
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add %d Images to IDE Main VirtualImageList. Offset %d. LargeOffset %d', [Images.Count, Cnt, FLargeIDEOffset]);
{$ENDIF}
{$ELSE}
    if (IDEs.Width = Images.Width) and (IDEs.Height = Images.Height) then
    begin
      IDEs.AddImages(Images);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Add %d Images to IDE Main 16x16 ImageList. Offset %d.', [Images.Count, Cnt]);
{$ENDIF}
    end;
{$ENDIF}

    FIDEOffset := Cnt;
    FCopied := True;
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

procedure TdmCnSharedImages.CopyLargeIDEImageList(Force: Boolean);
var
  IDEs: TCustomImageList;
{$IFDEF IDE_SUPPORT_HDPI}
  Ico: TIcon;
{$ENDIF}
begin
  if not WizOptions.UseLargeIcon then
    Exit;

  if FLargeCopied and not Force then // 已经复制了，不 Force 时则退出
    Exit;

  IDEs := GetIDEImageList;
  if IDEs = nil then
    Exit;

  // 是 Force 时判断 IDE 的 ImageList 的数量是否相等，相等则不复制
  if Force and (FLargeCopiedCount = IDEs.Count) then
    Exit;

  // 真正把 IDE 的 ImageList 复制一个超大型的供大尺寸下使用
{$IFDEF IDE_SUPPORT_HDPI}
  FIDELargeVirtualImages.Clear;
  CopyVirtualImageList(IDEs as TVirtualImageList, FIDELargeVirtualImages);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Copy IDE ImageList %d to a Large Virtual ImageList %d',
    [IDEs.Count, FIDELargeVirtualImages.Count]);
{$ENDIF}

  Ico := TIcon.Create;
  try
    Images.GetIcon(IdxUnknown, Ico);
    FIdxUnknownLargeInIDE := AddGraphicToVirtualImageList(Ico,
      FIDELargeVirtualImages, 'CnWizardsLargeUnknown');
{$IFDEF DEBUG}
    CnDebugger.LogFmt('Add an Unknown Icon to IDE Large Index %d',
      [FIdxUnknownLargeInIDE]);
{$ENDIF}
  finally
    Ico.Free;
  end;
{$ENDIF}

  IDELargeImages.Clear;
  StretchCopyToLarge(IDEs, IDELargeImages);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('Copy IDE ImageList %d to a Large ImageList %d',
    [IDEs.Count, IDELargeImages.Count]);
{$ENDIF}
  FLargeCopiedCount := IDEs.Count;
  FLargeCopied := True;
end;

function TdmCnSharedImages.GetIdxUnknownInIDE: Integer;
begin
  Result := FIdxUnknownInIDE;
{$IFDEF IDE_SUPPORT_HDPI}
  if WizOptions.UseLargeIcon then
    Result := FIdxUnknownLargeInIDE;
{$ENDIF}
end;

{$ENDIF}
end.
