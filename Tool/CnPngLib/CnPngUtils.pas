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

unit CnPngUtils;
{* |<PRE>
================================================================================
* 软件名称：CnWizards 辅助工具
* 单元名称：Png 格式支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：由于 pngimage 已经被 Embarcadero 收购，新的许可协议似乎不再允许该项目
*           开源。为了避免版权问题，此处在 D2010 下使用官方的 pngimage 编译一个
*           DLL 来供低版本的 IDE 环境下使用。
* 开发平台：Win7 + Delphi 2010
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: CnPngUtils.pas 763 2011-02-07 14:18:23Z (master@cnpack.org) $
* 修改记录：2017.03.15 V1.1
*               用绘制的方式取代 Assign 以避免部分 PNG8 图片全黑的问题
*           2011.07.05 V1.0
*               创建单元
================================================================================
|</PRE>}

{//$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Graphics, pngimage;

function CnConvertPngToBmp(PngFile, BmpFile: PAnsiChar): LongBool; stdcall;

function CnConvertBmpToPng(BmpFile, PngFile: PAnsiChar): LongBool; stdcall;

exports
  CnConvertPngToBmp,
  CnConvertBmpToPng;

implementation

function CnConvertPngToBmp(PngFile, BmpFile: PAnsiChar): LongBool;
var
  Png: TPngImage;
  Bmp: TBitmap;
begin
  Result := False;
  if not FileExists(string(PngFile)) then
    Exit;
  Png := nil;
  Bmp := nil;
  try
    Png := TPngImage.Create;
    Bmp := TBitmap.Create;
    Png.LoadFromFile(string(PngFile));

    // PNG24 以及不透明的 PNG8 对应 ptmNone
    // PNG8 透明对应 ptmBit
    // PNG32 对应 ptmPartial
    if Png.TransparencyMode = ptmPartial then
    begin
      Bmp.Assign(Png);
    end
    else
    begin
      // 某些 png8 图会出错导致全黑，换成绘制的方式
      Bmp.Height := Png.Height;
      Bmp.Width := Png.Width;
      Png.Draw(Bmp.Canvas, Bmp.Canvas.ClipRect);
    end;

    if not Bmp.Empty then
    begin
      Bmp.SaveToFile(string(BmpFile));
      Result := True;
    end;
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

function CnConvertBmpToPng(BmpFile, PngFile: PAnsiChar): LongBool;
var
  Png: TPngImage;
  Bmp: TBitmap;
  i, j: Integer;
  p, p1, p2: PByteArray;
begin
  Result := False;
  if not FileExists(string(BmpFile)) then
    Exit;
  Png := nil;
  Bmp := nil;
  try
    Bmp := TBitmap.Create;
    Bmp.LoadFromFile(string(BmpFile));
    if Bmp.PixelFormat = pf32bit then
    begin
      Png := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, Bmp.Width, Bmp.Height);
      for i := 0 to Bmp.Height - 1 do
      begin
        p := Bmp.ScanLine[i];
        p1 := Png.Scanline[i];
        p2 := Png.AlphaScanline[i];
        for j := 0 to Bmp.Width - 1 do
        begin
          p1[j * 3] := p[j * 4];
          p1[j * 3 + 1] := p[j * 4 + 1];
          p1[j * 3 + 2] := p[j * 4 + 2];
          p2[j] := p[j * 4 + 3];
        end;
      end;
    end
    else
    begin
      Png := TPngImage.Create;
      Png.Assign(Bmp);
    end;
    if not Png.Empty then
    begin
      Png.SaveToFile(string(PngFile));
      Result := True;
    end;
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

end.
