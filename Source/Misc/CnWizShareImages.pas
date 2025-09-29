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

unit CnWizShareImages;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����� ImageList ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ������ CnPack IDE ר�Ұ�����Ĺ����� ImageList
*           ע�⣺D11 �Լ�֮֮��� IDE ֧�� HDPI������ֱ���� ImageList ��
*          ����Ϊ�ߴ�̶�Ϊ�������ز��ɱ䵼�»���̫С������ͨ�ߴ�ģʽ��ȫ����
*           ���� HDPI �Ŵ��������ش�С�� VirtualImageList����ߴ�ģʽ�¸�����
*           ���� HDPI �Ŵ����Ĵ�ߴ����ش�С�� VirtualImageList��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.09.15 V1.1
*               ֧�� HDPI �ɱ�ֱ������
*           2003.04.18 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Windows, Classes, Graphics, Forms, ImgList, Buttons, Controls,
  {$IFDEF DELPHI_OTA} {$IFDEF IDE_SUPPORT_HDPI} Vcl.VirtualImageList, Vcl.ImageCollection, {$ENDIF} {$ENDIF}
  {$IFDEF SUPPORT_GDIPLUS} WinApi.GDIPOBJ, WinApi.GDIPAPI, {$ENDIF}
  CnWizOptions, CnWizUtils, CnWizIdeUtils, CnGraphUtils;

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

{$IFDEF DELPHI_IDE_WITH_HDPI}
    FIdxUnknownLargeInIDE: Integer;
    FImageCollection: TImageCollection;       // ��ͨ�ߴ����ߴ�� Images ��Ӧ�� Collection
    FVirtualImages: TVirtualImageList;        // ��Ӧ��ͨ�ߴ�� Images
    FLargeVirtualImages: TVirtualImageList;   // ��Ӧ��ߴ�� Images���ǷŴ�ʱ������
    FDisabledImageCollection: TImageCollection;       // ��ͨ�ߴ����ߴ�� DisabledImages ��Ӧ�� Collection
    FDisabledVirtualImages: TVirtualImageList;        // ��Ӧ��ͨ�ߴ�� DisabledImages
    FDisabledLargeVirtualImages: TVirtualImageList;   // ��Ӧ��ߴ� DisabledImages���ǷŴ�ʱ������
    FProcToolbarImageCollection: TImageCollection;      // ��ͨ�ߴ����ߴ�� ilProcToolbarLarge ��Ӧ�� Collection
    FProcToolbarVirtualImages: TVirtualImageList;       // ��Ӧ��ͨ�ߴ�� ilProcToolbar
    FLargeProcToolbarVirtualImages: TVirtualImageList;  // ��Ӧ��ߴ�� ilProcToolbar���ǷŴ�ʱ������

    FIDELargeVirtualImages: TVirtualImageList;   // ��Ӧ IDELargeImages �� IDELargeDisabledImages���ǷŴ�ʱ������
    FLargeIDEOffset: Integer; // D110A ֮���ͼ��ƫ��ֵ��ͬ
{$ENDIF}

    FIdxUnknownInIDE: Integer;
    FIDEOffset: Integer;      // D110A ֮ǰ�������Ƿ��ͼ�궼�����ֵ
    FCopied: Boolean;         // ��¼���ǵ� ImageList �������� IDE �� ImageList ��

{$IFNDEF STAND_ALONE}
    FLargeCopied: Boolean;    // ��¼ IDE �� ImageList ���޸���һ�ݴ��
    FLargeCopiedCount: Integer; // ��¼ IDE �� ImageList ����һ�ݴ������
    function GetIdxUnknownInIDE: Integer;
{$ENDIF}
  public
    property IdxUnknown: Integer read FIdxUnknown;
{$IFNDEF STAND_ALONE}
    property IdxUnknownInIDE: Integer read GetIdxUnknownInIDE;
{$ENDIF}

    procedure StretchCopyToLarge(SrcImageList, DstImageList: TCustomImageList);
    {* ���ⶼʹ�ã�����С�ߴ� ImageList ������Ƶ���� ImageList ��}
    procedure CenterCopyTo(SrcImageList, DstImageList: TCustomImageList);
    {* ����С�ߴ� ImageList ԭ�ߴ���л��Ƶ���� ImageList ��}

    procedure CopyToIDEMainImageList;
    // Images �ᱻ���ƽ� IDE �� ImageList ��ͼ�걻ͬʱʹ�õĳ��ϣ�FIDEOffset ��ʾƫ����
    // ע����Щͼ�겻�ǲ˵�ͼ�꣬�Ǹ��� WizMenuAction ���ƽ� IDE �� ImageList��

{$IFNDEF STAND_ALONE}
    procedure GetSpeedButtonGlyph(Button: TSpeedButton; ImageList: TImageList; 
      EmptyIdx: Integer);
    procedure CopyLargeIDEImageList(Force: Boolean = False);
    // ��ר��ȫ�����������ز˵������ã��� IDE �� ImageList �ٸ���һ�ݴ��
    // ע������ᱻ�����ظ������Σ�һ�ο�ǰ�Գ�ʼ��ר�ҹ�������أ�һ�� IDE ��������Է�ӳ����ͼ��
    // Force Ϊ True ʱ��ʾ�� FLargeCopied Ϊ True ʱ�ж��������������ٽ���һ�θ���

    function GetMixedImageList(ForceSmall: Boolean = False): TCustomImageList;
    function CalcMixedImageIndex(ImageIndex: Integer): Integer;

{$IFDEF IDE_SUPPORT_HDPI}
{$IFDEF DELPHI_OTA}
    property VirtualImages: TVirtualImageList read FVirtualImages;
    property LargeVirtualImages: TVirtualImageList read FLargeVirtualImages;
    {* D110A �����ϣ���Ϊ IDE ��û�У�����ͨ���������������ͨ�ߴ�ʹ�ߴ�}
    property DisabledVirtualImages: TVirtualImageList read FDisabledVirtualImages;
    property DisabledLargeVirtualImages: TVirtualImageList read FDisabledLargeVirtualImages;
    {* D110A �����ϣ���Ϊ IDE ��û�У���ͨ����������״̬���������ͨ�ߴ�ʹ�ߴ�}
    property ProcToolbarVirtualImages: TVirtualImageList read FProcToolbarVirtualImages;
    property LargeProcToolbarVirtualImages: TVirtualImageList read FLargeProcToolbarVirtualImages;
    {* D110A �����ϣ���Ϊ IDE ��û�У��ʺ����б�������Ҫ���������ͨ�ߴ�ʹ�ߴ�}

    property IDELargeVirtualImages: TVirtualImageList read FIDELargeVirtualImages;
    {* ��ߴ��µ� D110A �����ϣ��༭������������Ҫ IDE �������}
{$ENDIF}
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
  // ��С�� ImageList ���������ƣ��� 16*16 ��չ�� 24* 24
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
  // ��С�� ImageList ���������ƣ���Сͼ���л������
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
{$IFDEF DELPHI_IDE_WITH_HDPI}
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

{$IFDEF DELPHI_IDE_WITH_HDPI}
  Ico := TIcon.Create;
  try
    Images.GetIcon(IdxUnknown, Ico);
    FIdxUnknownInIDE := AddGraphicToVirtualImageList(Ico,
      ImgLst as TVirtualImageList, 'CnWizardsUnknown');
  finally
    Ico.Free;
  end;
{$ELSE}
  Bmp := TBitmap.Create;        // �� IDE ���� List �Ӹ� Unknown ��ͼ��
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

{$IFDEF DELPHI_IDE_WITH_HDPI}
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
    // Ϊ��ͼ�������׼��
{$IFDEF DELPHI_IDE_WITH_HDPI}
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

    // ��ߴ�ģʽ�£������´��� ImageColleciton������ԭʼ�ģ�ֻ�ǷŴ����� VirtualImageList
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
{$IFDEF DELPHI_OTA}
{$IFDEF IDE_SUPPORT_HDPI}
    if WizOptions.UseLargeIcon then
    begin
      // D11 �����Ժ�IDE ���� ImageList �� VirtualImageList �ˣ��������ڷֱ��ʱ仯��FLargeOffset ������
      CopyVirtualImageList(IDEs as TVirtualImageList, FIDELargeVirtualImages);
      FLargeIDEOffset := FIDELargeVirtualImages.Count;
      FIDELargeVirtualImages.Clear;   // ���ֻ������ FIDELargeOffset
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
{$ENDIF}

    FIDEOffset := Cnt;
    FCopied := True;
  end;
end;

{$IFNDEF STAND_ALONE}

function TdmCnSharedImages.CalcMixedImageIndex(
  ImageIndex: Integer): Integer;
begin
  if FCopied and (ImageIndex >= 0) then
  begin
    Result := ImageIndex + FIDEOffset;
{$IFDEF DELPHI_IDE_WITH_HDPI}
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
{$IFDEF DELPHI_IDE_WITH_HDPI}
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

procedure TdmCnSharedImages.GetSpeedButtonGlyph(Button: TSpeedButton;
  ImageList: TImageList; EmptyIdx: Integer);
var
  Save: TColor;
begin
  Button.Glyph.TransparentMode := tmFixed; // ǿ��͸��
  Button.Glyph.TransparentColor := clFuchsia;
  if Button.Glyph.Empty then
  begin
    Save := dmCnSharedImages.Images.BkColor;
    ImageList.BkColor := clFuchsia;
    ImageList.GetBitmap(EmptyIdx, Button.Glyph);
    ImageList.BkColor := Save;
  end;

{$IFNDEF LAZARUS}
  // ������ťλͼ�Խ����Щ��ť Disabled ʱ��ͼ�������
  AdjustButtonGlyph(Button.Glyph);
{$ENDIF}
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

  if FLargeCopied and not Force then // �Ѿ������ˣ��� Force ʱ���˳�
    Exit;

  IDEs := GetIDEImageList;
  if IDEs = nil then
    Exit;

  // �� Force ʱ�ж� IDE �� ImageList �������Ƿ���ȣ�����򲻸���
  if Force and (FLargeCopiedCount = IDEs.Count) then
    Exit;

  // ������ IDE �� ImageList ����һ�������͵Ĺ���ߴ���ʹ��
{$IFDEF DELPHI_IDE_WITH_HDPI}
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
{$IFDEF DELPHI_IDE_WITH_HDPI}
  if WizOptions.UseLargeIcon then
    Result := FIdxUnknownLargeInIDE;
{$ENDIF}
end;

{$ENDIF}
end.
