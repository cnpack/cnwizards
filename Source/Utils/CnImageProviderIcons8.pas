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

unit CnImageProviderIcons8;
{* |<PRE>
================================================================================
* 组件名称：CnPack IDE 专家包
* 单元名称：Icons8 图标搜索支持单元
* 单元作者：CnPack Team
* 备    注：该站点无公开免费 API，当前实现基于网页抓取。
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnInetUtils,
  CnCommon, AsRegExpr;

type
  TCnImageProviderIcons8 = class(TCnBaseImageProvider)
  protected
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; override;
  public
    constructor Create; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); override;
    procedure OpenInBrowser(Item: TCnImageRespItem); override;
    function SearchIconset(Item: TCnImageRespItem; var Req: TCnImageReqInfo): Boolean; override;
  end;

implementation

constructor TCnImageProviderIcons8.Create;
begin
  inherited;
  FItemsPerPage := 12;
  FFeatures := [pfOpenInBrowser];
end;

class procedure TCnImageProviderIcons8.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'Icons8.com';
  HomeUrl := 'https://icons8.com';
end;

function TCnImageProviderIcons8.DoSearchImage(Req: TCnImageReqInfo): Boolean;
var
  Url, Text, KeyStr, Id, Slug, RefUrl, UA: string;
  Item: TCnImageRespItem;
  RegExpr: TRegExpr;
  IconMap: TStringList;
  I, Size: Integer;
  Err: DWORD;

  procedure AddIcon(const AId, ASlug: string);
  begin
    if AId = '' then
      Exit;
    if IconMap.IndexOfName(AId) < 0 then
      IconMap.Values[AId] := ASlug
    else if (IconMap.Values[AId] = '') and (ASlug <> '') then
      IconMap.Values[AId] := ASlug;
  end;

  procedure MatchIcons(const Pattern: string; IdxId, IdxSlug: Integer);
  begin
    RegExpr.Expression := Pattern;
    if RegExpr.Exec(Text) then
    begin
      repeat
        if IdxSlug > 0 then
          AddIcon(RegExpr.Match[IdxId], RegExpr.Match[IdxSlug])
        else
          AddIcon(RegExpr.Match[IdxId], '');
      until not RegExpr.ExecNext;
    end;
  end;
begin
  Result := False;
  KeyStr := Trim(Req.Keyword);
  if KeyStr = '' then
    Exit;

  Url := Format('https://icons8.com/icons/set/%s?size=small&page=%d',
    [EncodeURL(KeyStr), Req.Page + 1]);

  UA := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ' +
    '(KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36';
  with TCnHTTP.Create do
  try
    UserAgent := UA;
    NoCookie := True;
    Text := string(GetString(Url, TStrings(nil), @Err));
  finally
    Free;
  end;

  if Text = '' then
    Exit;

  IconMap := TStringList.Create;
  RegExpr := TRegExpr.Create;
  try
    IconMap.NameValueSeparator := '=';

    MatchIcons('icons8\.com/icon/([A-Za-z0-9]+)/([A-Za-z0-9\-_]+)', 1, 2);
    MatchIcons('icons8\\.com\\u002Ficon\\u002F([A-Za-z0-9]+)\\u002F([A-Za-z0-9\-_]+)', 1, 2);
    MatchIcons('img\.icons8\.com/\?size=\d+&id=([A-Za-z0-9]+)&format=png', 1, 0);
    MatchIcons('img\\.icons8\\.com\\u002F\\?size=\d+&id=([A-Za-z0-9]+)&format=png', 1, 0);

    if IconMap.Count <= 0 then
      Exit;

    Size := Req.MinSize;
    if Size <= 0 then
      Size := 32;
    if (Req.MaxSize > 0) and (Size > Req.MaxSize) then
      Size := Req.MaxSize;

    for I := 0 to IconMap.Count - 1 do
    begin
      Id := IconMap.Names[I];
      Slug := IconMap.ValueFromIndex[I];

      Item := Items.Add;
      Item.Ext := '.png';
      Item.Size := Size;
      if Slug <> '' then
        Item.Id := Id + '/' + Slug
      else
        Item.Id := Id;
      Item.Url := Format('https://img.icons8.com/?size=%d&id=%s&format=png',
        [Size, Id]);
      Item.UserAgent := UA;
      if Slug <> '' then
        RefUrl := 'https://icons8.com/icon/' + Id + '/' + Slug
      else
        RefUrl := 'https://icons8.com/icon/' + Id;
      Item.Referer := RefUrl;
    end;

    FPageCount := Req.Page + 1;
    if Items.Count >= FItemsPerPage then
      Inc(FPageCount);
    FTotalCount := FPageCount * FItemsPerPage;
    Result := Items.Count > 0;
  finally
    RegExpr.Free;
    IconMap.Free;
  end;
end;

procedure TCnImageProviderIcons8.OpenInBrowser(Item: TCnImageRespItem);
begin
  OpenUrl('https://icons8.com/icon/' + Item.Id);
end;

function TCnImageProviderIcons8.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin
  Result := False;
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProviderIcons8);

end.
