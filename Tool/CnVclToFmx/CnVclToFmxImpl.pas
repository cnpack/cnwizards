{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnVclToFmxImpl;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：VCL 至 FMX 转换功能的接口实现
* 单元作者：CnPack 开发组
* 备    注：该单元是 VCL 至 FMX 转换功能的接口实现
* 开发平台：Win7 + Delphi 5.0
* 兼容测试：各种平台
* 本 地 化：不需要
* 修改记录：2022.05.11 V1.0
*               创建单元。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  System.SysUtils, System.Classes, CnVclToFmxIntf;

type
  TCnVclToFmxImpl = class(TInterfacedObject, ICnVclToFmxIntf)
  private
    FFmx: string;
    FPas: string;
  public
    function OpenAndConvertFile(InDfmFile: PWideChar): Boolean;
    function SaveNewFile(InNewFile: PWideChar): Boolean;
  end;

function GetVclToFmxConverter: ICnVclToFmxIntf; stdcall;

exports
  GetVclToFmxConverter;

implementation

uses
  CnVclToFmxConverter;

var
  FImpl: ICnVclToFmxIntf = nil;

function GetVclToFmxConverter: ICnVclToFmxIntf;
begin
  if FImpl = nil then
    FImpl := TCnVclToFmxImpl.Create;
  Result := FImpl;
end;

{ TCnVclToFmxImpl }

function TCnVclToFmxImpl.OpenAndConvertFile(InDfmFile: PWideChar): Boolean;
begin
  FFmx := '';
  FPas := '';
  Result := CnVclToFmxConvert(InDfmFile, FFmx, FPas);
end;

function TCnVclToFmxImpl.SaveNewFile(InNewFile: PWideChar): Boolean;
var
  F: string;
begin
  if (FFmx <> '') and (InNewFile <> nil) then
  begin
    F := InNewFile;
    Result := CnVclToFmxSaveContent(ChangeFileExt(F, '.fmx'), FFmx);
    if Result and (FPas <> '') then
    begin
      FPas := CnVclToFmxReplaceUnitName(F, FPas);
      Result := CnVclToFmxSaveContent(ChangeFileExt(F, '.pas'), FPas);
    end;
  end;
end;

initialization

finalization
  FImpl := nil;

end.
