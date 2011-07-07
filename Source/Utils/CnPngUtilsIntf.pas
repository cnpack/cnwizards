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

unit CnPngUtilsIntf;
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
* 单元标识：$Id: $
* 修改记录：
*           2011.07.05 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

function CnPngLibLoaded: LongBool;
function CnConvertPngToBmp(PngFile, BmpFile: string): LongBool; stdcall;
function CnConvertBmpToPng(BmpFile, PngFile: string): LongBool; stdcall;

implementation

uses
  Windows, SysUtils;

type
  TCnConvertPngToBmpProc = function (PngFile, BmpFile: PAnsiChar): LongBool; stdcall;
  TCnConvertBmpToPngProc = function (BmpFile, PngFile: PAnsiChar): LongBool; stdcall;

var
  _hMod: HMODULE;
  _CnConvertPngToBmpProc: TCnConvertPngToBmpProc = nil;
  _CnConvertBmpToPngProc: TCnConvertBmpToPngProc = nil;

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := ExtractFilePath(Result);
end;

procedure LoadCnPngLib;
var
  DllName: string;
begin
  DllName := ModulePath + 'CnPngLib.dll';
  _hMod := LoadLibrary(PChar(DllName));
  if _hMod <> 0 then
  begin
    _CnConvertPngToBmpProc := TCnConvertPngToBmpProc(GetProcAddress(_hMod, 'CnConvertPngToBmp'));
    _CnConvertBmpToPngProc := TCnConvertBmpToPngProc(GetProcAddress(_hMod, 'CnConvertBmpToPng'));
  end;
end;

procedure FreeCnPngLib;
begin
  if _hMod <> 0 then
  begin
    FreeLibrary(_hMod);
    _CnConvertPngToBmpProc := nil;
    _CnConvertBmpToPngProc := nil;
    _hMod := 0;
  end;
end;

function CnPngLibLoaded: LongBool;
begin
  Result := Assigned(_CnConvertPngToBmpProc) and Assigned(_CnConvertBmpToPngProc);
end;

function CnConvertPngToBmp(PngFile, BmpFile: string): LongBool; stdcall;
var
  P, B: AnsiString;
begin
  P := AnsiString(PngFile);
  B := AnsiString(BmpFile);
  if Assigned(_CnConvertPngToBmpProc) then
    Result := _CnConvertPngToBmpProc(PAnsiChar(P), PAnsiChar(B))
  else
    Result := False;
end;

function CnConvertBmpToPng(BmpFile, PngFile: string): LongBool; stdcall;
var
  P, B: AnsiString;
begin
  P := AnsiString(PngFile);
  B := AnsiString(BmpFile);
  if Assigned(_CnConvertBmpToPngProc) then
    Result := _CnConvertBmpToPngProc(PAnsiChar(B), PAnsiChar(P))
  else
    Result := False;
end;

initialization
  LoadCnPngLib;

finalization
  FreeCnPngLib;

end.
