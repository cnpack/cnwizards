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
* 备    注：该网站没有提供API接口，通过网页分析可以拿到图标。但由于网站做了流量
*           限制，查询时可能不稳定。
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
  OmniXML, OmniXMLUtils, CnCommon, RegExpr;

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
  FItemsPerPage := 24;
  FFeatures := [pfOpenInBrowser];
end;

destructor TCnImageProvider_FindIcons.Destroy;
begin

  inherited;
end;

class procedure TCnImageProvider_FindIcons.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'FindIcons.com (Beta)';
  HomeUrl := 'http://www.findicons.com';
end;

function TCnImageProvider_FindIcons.DoSearchImage(
  Req: TCnImageReqInfo): Boolean;
var
  Url, Text, KeyStr, PageStr, LicStr: string;
  Item: TCnImageRespItem;
  RegExpr: TRegExpr;
begin
  RegExpr := TRegExpr.Create;
  try
    Result := False;
    RegExpr.Expression := '\w+';
    if RegExpr.Exec(Req.Keyword) then
    begin
      KeyStr := RegExpr.Match[0];
      while RegExpr.ExecNext do
        KeyStr := KeyStr + '-' + RegExpr.Match[0];
    end;
    if KeyStr = '' then
      Exit;

    if Req.Page = 0 then
      PageStr := ''
    else
      PageStr := '/' + IntToStr(Req.Page + 1);
    if Req.CommercialLicenses then
      LicStr := 'cf'
    else
      LicStr := 'all';
    Url := Format('http://findicons.com/search/%s%s?icons=%d&width_from=%d&width_to=%d&color=all&style=all&order=default&license=%s&icon_box=small&icon=&png_file=&output_format=jpg',
      [KeyStr, PageStr, FItemsPerPage, Req.MinSize, Req.MaxSize, LicStr]);
    with TCnHTTP.Create do
    try
      UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
      HttpRequestHeaders.Add('x-requested-with: XMLHttpRequest');
      NoCookie := True;
      Text := string(GetString(Url));
    finally
      Free;
    end;

    if Text = '' then
      Exit;

    RegExpr.Expression := 'of (\d+) icons for';
    if RegExpr.Exec(Text) then
    begin
      FTotalCount := StrToIntDef(RegExpr.Match[1], 0);
      FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
    end;
    if FTotalCount <= 0 then
      Exit;

    RegExpr.Expression := '<a class="header_download_link" href="#" rel="/icon/download/(\d+)/([^\/]+)/(\d+)/png\?id=(\d+)" title="PNG">PNG</a>';
    if RegExpr.Exec(Text) then
    begin
      repeat
        Item := Items.Add;
        Item.Url := Format('http://findicons.com/icon/download/%s/%s/%s/png?id=%s',
          [RegExpr.Match[1], RegExpr.Match[2], RegExpr.Match[3], RegExpr.Match[4]]);
        Item.Ext := '.png';
        Item.Size := StrToIntDef(RegExpr.Match[3], Req.MinSize);
        Item.Id := Format('%s/%s?id=%s', [RegExpr.Match[1], RegExpr.Match[2], RegExpr.Match[4]]);
        Item.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
        Item.Referer := 'http://findicons.com/icon/' + Item.Id;
      until not RegExpr.ExecNext;
      Result := True;
    end;
  finally
    RegExpr.Free;
  end;   
end;

procedure TCnImageProvider_FindIcons.OpenInBrowser(Item: TCnImageRespItem);
begin
  OpenUrl('http://findicons.com/icon/' + Item.Id);
end;

function TCnImageProvider_FindIcons.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin
  // todo: 支持图标集
  Result := False;
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProvider_FindIcons);

end.
