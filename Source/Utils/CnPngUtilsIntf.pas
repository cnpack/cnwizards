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

unit CnPngUtilsIntf;
{* |<PRE>
================================================================================
* 软件名称：Cnpack IDE 专家包辅助工具
* 单元名称：Png 格式支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：由于 pngimage 已经被 Embarcadero 收购，新的许可协议似乎不再允许该项目
*           开源。为了避免版权问题，此处在 D2010 下使用官方的 pngimage 编译一个
*           DLL 来供低版本的 IDE 环境下使用，并在 D10.4 下编译 64 位版本。
* 开发平台：Win7 + Delphi 2010/D10.4
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2025.02.03 V1.1
*               加入 64 位的支持
*           2011.07.05 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

function CnPngLibLoaded: LongBool;

function CnConvertPngToBmp(PngFile, BmpFile: string): LongBool; stdcall;

function CnConvertBmpToPng(BmpFile, PngFile: string): LongBool; stdcall;

implementation

uses
  Windows, SysUtils, CnCommon;

type
  TCnConvertPngToBmpProc = function (PngFile, BmpFile: PAnsiChar): LongBool; stdcall;
  TCnConvertBmpToPngProc = function (BmpFile, PngFile: PAnsiChar): LongBool; stdcall;

var
  FModuleHandle: HMODULE;
  FCnConvertPngToBmpProc: TCnConvertPngToBmpProc = nil;
  FCnConvertBmpToPngProc: TCnConvertBmpToPngProc = nil;

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

procedure LoadCnPngLib;
var
  DllName: string;
begin
{$IFDEF WIN64}
  DllName := ModulePath + 'CnPngLib64.dll';
{$ELSE}
  DllName := ModulePath + 'CnPngLib.dll';
{$ENDIF}

  FModuleHandle := LoadLibrary(PChar(DllName));
  if FModuleHandle <> 0 then
  begin
    FCnConvertPngToBmpProc := TCnConvertPngToBmpProc(GetProcAddress(FModuleHandle, 'CnConvertPngToBmp'));
    FCnConvertBmpToPngProc := TCnConvertBmpToPngProc(GetProcAddress(FModuleHandle, 'CnConvertBmpToPng'));
  end;
end;

procedure FreeCnPngLib;
begin
  if FModuleHandle <> 0 then
  begin
    FreeLibrary(FModuleHandle);
    FCnConvertPngToBmpProc := nil;
    FCnConvertBmpToPngProc := nil;
    FModuleHandle := 0;
  end;
end;

function CnPngLibLoaded: LongBool;
begin
  Result := Assigned(FCnConvertPngToBmpProc) and Assigned(FCnConvertBmpToPngProc);
end;

function CnConvertPngToBmp(PngFile, BmpFile: string): LongBool; stdcall;
var
  P, B: AnsiString;
begin
  P := AnsiString(PngFile);
  B := AnsiString(BmpFile);
  if Assigned(FCnConvertPngToBmpProc) then
    Result := FCnConvertPngToBmpProc(PAnsiChar(P), PAnsiChar(B))
  else
    Result := False;
end;

function CnConvertBmpToPng(BmpFile, PngFile: string): LongBool; stdcall;
var
  P, B: AnsiString;
begin
  P := AnsiString(PngFile);
  B := AnsiString(BmpFile);
  if Assigned(FCnConvertBmpToPngProc) then
    Result := FCnConvertBmpToPngProc(PAnsiChar(B), PAnsiChar(P))
  else
    Result := False;
end;

initialization
  LoadCnPngLib;

finalization
  FreeCnPngLib;

end.
