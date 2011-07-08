{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
* 单元标识：$Id: CnPngUtils.pas 763 2011-02-07 14:18:23Z liuxiao@cnpack.org $
* 修改记录：2011.07.05 V1.0
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
  png: TPngImage;
  bmp: TBitmap;
begin
  Result := False;
  if not FileExists(string(PngFile)) then
    Exit;
  png := nil;
  bmp := nil;
  try
    png := TPngImage.Create;
    bmp := TBitmap.Create;
    png.LoadFromFile(string(PngFile));
    bmp.Assign(png);
    if not bmp.Empty then
    begin
      bmp.SaveToFile(string(BmpFile));
      Result := True;
    end;
  except
    png.Free;
    bmp.Free;
  end;
end;

function CnConvertBmpToPng(BmpFile, PngFile: PAnsiChar): LongBool;
var
  png: TPngImage;
  bmp: TBitmap;
  i, j: Integer;
  p, p1, p2: PByteArray;
begin
  Result := False;
  if not FileExists(string(BmpFile)) then
    Exit;
  png := nil;
  bmp := nil;
  try
    bmp := TBitmap.Create;
    bmp.LoadFromFile(string(BmpFile));
    if bmp.PixelFormat = pf32bit then
    begin
      png := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, bmp.Width, bmp.Height);
      for i := 0 to bmp.Height - 1 do
      begin
        p := bmp.ScanLine[i];
        p1 := png.Scanline[i];
        p2 := png.AlphaScanline[i];
        for j := 0 to bmp.Width - 1 do
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
      png := TPngImage.Create;
      png.Assign(bmp);
    end;
    if not png.Empty then
    begin
      png.SaveToFile(string(PngFile));
      Result := True;
    end;
  except
    png.Free;
    bmp.Free;
  end;
end;

end.
