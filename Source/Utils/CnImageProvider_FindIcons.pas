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

unit CnImageProvider_FindIcons;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：www.FindIcons.com 服务支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.08 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnInetUtils,
  OmniXML, OmniXMLUtils, CnCommon;

type
  TCnImageProvider_FindIcons = class(TCnBaseImageProvider)
  protected
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); override;
    procedure OpenInBrowser(Item: TCnImageRespItem); override;
    function SearchIconset(Item: TCnImageRespItem; var Req: TCnImageReqInfo): Boolean; override;
  end;


implementation

{ TCnImageProvider_FindIcons }

constructor TCnImageProvider_FindIcons.Create;
begin
  inherited;
  FItemsPerPage := 20;
  FFeatures := [pfOpenInBrowser, pfSearchIconset];
end;

destructor TCnImageProvider_FindIcons.Destroy;
begin

  inherited;
end;

class procedure TCnImageProvider_FindIcons.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'FindIcons.com';
  HomeUrl := 'http://www.findicons.com';
end;

function TCnImageProvider_FindIcons.DoSearchImage(
  Req: TCnImageReqInfo): Boolean;
var
  Url, Text, KeyStr, PageStr, LicStr: string;
  i, j, size: Integer;
  Item: TCnImageRespItem;
begin
  Result := False;
  KeyStr := Req.Keyword;
  if Req.Page = 0 then
    PageStr := ''
  else
    PageStr := '/' + IntToStr(Req.Page + 1);
  if Req.CommercialLicenses then
    LicStr := 'cf'
  else
    LicStr := 'all';
  Url := Format('http://findicons.com/search/%s%s?icons=%d&width_from=%d&width_to=%d&color=all&style=all&order=default&license=%s&icon_box=small&icon=&png_file=&output_format=jpg',
    [Req.Keyword, PageStr, FItemsPerPage, Req.MinSize, Req.MaxSize, LicStr]);
  with TCnHTTP.Create do
  try
    HttpRequestHeaders.Add('x-requested-with: XMLHttpRequest');
    NoCookie := True;
    Text := GetString(Url);
  finally
    Free;
  end;
  // todo:
end;

procedure TCnImageProvider_FindIcons.OpenInBrowser(Item: TCnImageRespItem);
begin
  inherited;

end;

function TCnImageProvider_FindIcons.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin

end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProvider_FindIcons);

end.
