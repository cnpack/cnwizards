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

unit CnImageProviderIconify;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：www.iconify.com 服务支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：Iconify 是免费的开源图标 API。搜索接口返回 prefix:name 形式的图标名称，
*           SVG 接口生成独立的 SVG 文件。SVG 文件由 CnImageProviderMgr 中的 .svg
*           支持代码负责渲染。
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2026.09.01 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnInetUtils,
  CnCommon, CnJSON;

type
  TCnImageProviderIconify = class(TCnBaseImageProvider)
  protected
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; override;
  public
    constructor Create; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); override;
    procedure OpenInBrowser(Item: TCnImageRespItem); override;
  end;

implementation

const
  CnIconifyApi = 'https://api.iconify.design';
  CnIconifyWeb = 'https://icon-sets.iconify.design';
  CnIconifyUserAgent = 'CnPack ImageListEditor (Iconify SVG provider)';

function IconifyCommercialLicense(Root: TCnJSONObject;
  const Prefix: string): Boolean;
var
  Collections, CollectionInfo, License: TCnJSONValue;
  SPDX: string;
begin
  { 当用户要求仅显示可用于商业用途的图标时，许可证未知的图标会被排除。
    普通搜索（全部许可证）不进行此项过滤。 }
  Result := True;
  if Root = nil then
    Exit;

  Collections := Root['collections'];
  if not (Collections is TCnJSONObject) then
  begin
    Result := False;
    Exit;
  end;
  CollectionInfo := TCnJSONObject(Collections)[Prefix];
  if not (CollectionInfo is TCnJSONObject) then
  begin
    Result := False;
    Exit;
  end;
  License := TCnJSONObject(CollectionInfo)['license'];
  if not (License is TCnJSONObject) then
  begin
    Result := False;
    Exit;
  end;
  if TCnJSONObject(License)['spdx'] = nil then
  begin
    Result := False;
    Exit;
  end;
  SPDX := UpperCase(Trim(TCnJSONObject(License)['spdx'].AsString));
  Result := (SPDX <> '') and (Pos('NC', SPDX) = 0);
end;

{ TCnImageProviderIconify }

constructor TCnImageProviderIconify.Create;
begin
  inherited;
   { Iconify 当前每次搜索至少返回 32 条结果。 }
  FItemsPerPage := 32;
  FFeatures := [pfOpenInBrowser];
end;

class procedure TCnImageProviderIconify.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'Iconify (free SVG)';
  HomeUrl := 'https://iconify.design';
end;

function TCnImageProviderIconify.DoSearchImage(Req: TCnImageReqInfo): Boolean;
var
  KeyStr, Url, Text, Prefix, Name, UA: string;
  Size, Start, I, P: Integer;
  Item: TCnImageRespItem;
  Http: TCnHTTP;
  ErrCode: DWORD;
  Root: TCnJSONObject;
  Icons: TCnJSONArray;

  procedure AddIcon(const AIconName: string);
  begin
    P := Pos(':', AIconName);
    if P <= 1 then
      Exit;
    Prefix := Copy(AIconName, 1, P - 1);
    Name := Copy(AIconName, P + 1, MaxInt);
    if (Name = '') or (Pos('/', Prefix) > 0) or (Pos('/', Name) > 0) then
      Exit;
    if Req.CommercialLicenses and not IconifyCommercialLicense(Root, Prefix) then
      Exit;

    Item := Items.Add;
    Item.Id := AIconName;
    Item.Ext := '.svg';
    Item.Size := Size;
    Item.Url := Format('%s/%s/%s.svg?width=%d&height=%d',
      [CnIconifyApi, Prefix, Name, Size, Size]);
    Item.UserAgent := UA;
    Item.Referer := CnIconifyWeb + '/' + Prefix + '/';
  end;

begin
  Result := False;
  KeyStr := Trim(Req.Keyword);
  if KeyStr = '' then
    Exit;

  Size := Req.MinSize;
  if Size <= 0 then
    Size := 32;
  if (Req.MaxSize > 0) and (Size > Req.MaxSize) then
    Size := Req.MaxSize;

  if Req.Page < 0 then
    Start := 0
  else
    Start := Req.Page * FItemsPerPage;
  Url := Format('%s/search?query=%s&limit=%d&start=%d',
    [CnIconifyApi, EncodeURL(KeyStr), FItemsPerPage, Start]);
  UA := CnIconifyUserAgent;

  Http := TCnHTTP.Create;
  try
    Http.UserAgent := UA;
    Http.NoCookie := True;
    Http.EncodeUrlPath := False;
    Text := string(Http.GetString(Url, TStrings(nil), @ErrCode));
  finally
    Http.Free;
  end;
  if Text = '' then
    Exit;

  Root := CnJSONParse(Text);
  try
    if Root = nil then
      Exit;
    if not (Root['icons'] is TCnJSONArray) then
      Exit;
    Icons := TCnJSONArray(Root['icons']);
    for I := 0 to Icons.Count - 1 do
      AddIcon(Icons[I].AsString);

    if Root['total'] <> nil then
      FTotalCount := Root['total'].AsInteger
    else
      FTotalCount := Items.Count;
    if FTotalCount > 0 then
      FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage
    else
      FPageCount := 0;
    Result := Items.Count > 0;
  finally
    Root.Free;
  end;
end;

procedure TCnImageProviderIconify.OpenInBrowser(Item: TCnImageRespItem);
var
  P: Integer;
  Prefix, Name: string;
begin
  P := Pos(':', Item.Id);
  if P > 1 then
  begin
    Prefix := Copy(Item.Id, 1, P - 1);
    Name := Copy(Item.Id, P + 1, MaxInt);
    OpenUrl(CnIconifyWeb + '/' + Prefix + '/' + Name + '/');
  end
  else
    OpenUrl(CnIconifyApi);
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProviderIconify);

end.
