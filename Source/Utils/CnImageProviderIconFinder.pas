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

unit CnImageProviderIconFinder;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：www.IconFinder.com 服务支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：该服务已迁移至 api.freepik.com
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

{$DEFINE USE_MSXML}

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnInetUtils,
{$IFDEF CN_USE_MSXML}
  ActiveX, ComObj, msxml,
{$ELSE}
  OmniXML, OmniXMLUtils,
{$ENDIF}
  CnCommon, CnWizXmlUtils;

type
  TCnImageProviderFreePik = class(TCnBaseImageProvider)
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

uses
  CnJSON, CnWizUtils;

const
  API_KEY = '871ADC4931BD5990FD344F00B26B1698CE35F5B550C5A377A775389C6F46576' +
    'DF4942120F13D27C8873282FB90F6735324FF369E';

{ TCnImageProviderFreePik }

constructor TCnImageProviderFreePik.Create;
begin
  inherited;
  FItemsPerPage := 20;
  FFeatures := [pfOpenInBrowser, pfSearchIconset];
end;

destructor TCnImageProviderFreePik.Destroy;
begin

  inherited;
end;

class procedure TCnImageProviderFreePik.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'FreePik.com';
  HomeUrl := 'http://www.freepik.com';
end;

function TCnImageProviderFreePik.DoSearchImage(Req: TCnImageReqInfo): Boolean;
var
  Url, Text: string;
  I: Integer;
  Item: TCnImageRespItem;
  Obj, MO: TCnJSONObject;
  Arr, Thumb: TCnJSONArray;
  Http: TCnHTTP;
  ErrCode: DWORD;
begin
  Result := False;
  Url := Format('https://api.freepik.com/v1/icons?term=%s&page=%d&per_page=%d&thumbnail_size=%d',
    [Req.Keyword, Req.Page + 1, FItemsPerPage, Req.MinSize]);

  Http := TCnHTTP.Create;
  try
    Http.HttpRequestHeaders.Add('x-freepik-api-key: ' + CnWizDecryptKey(API_KEY));
    Text := string(Http.GetString(Url, TStringList(nil), @ErrCode));
  finally
    Http.Free;
  end;

  Obj := CnJSONParse(Text);
  try
    if (Obj <> nil) and (Obj['data'] <> nil) and (Obj['data'] is TCnJSONArray) then
    begin
      Arr := Obj['data'] as TCnJSONArray;
      for I := 0 to Arr.Count - 1 do
      begin
        if (Arr[I]['id'] <> nil) and (Arr[I]['id'] is TCnJSONNumber) and
          (Arr[I]['thumbnails'] <> nil) and (Arr[I]['thumbnails'] is TCnJSONArray) and
          ((Arr[I]['thumbnails'] as TCnJSONArray).Count > 0) then
        begin
          Thumb := Arr[I]['thumbnails'] as TCnJSONArray;
          Item := Items.Add;
          Item.Id := Arr[I]['id'].AsString;
          Item.Size := Thumb[0]['width'].AsInteger;
          Item.Url := Thumb[0]['url'].AsString;
          Item.Ext := _CnExtractFileExt(Item.Url);
          Result := True;
        end;
      end;
    end;

    if (Obj['meta'] <> nil) and (Obj['meta'] is TCnJSONObject) then
    begin
      MO := Obj['meta'] as TCnJSONObject;
      if (MO['pagination'] <> nil) and (MO['pagination'] is TCnJSONObject) then
      begin
        MO := MO['pagination'] as TCnJSONObject;
        FTotalCount := MO['total'].AsInteger;
        FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
      end;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TCnImageProviderFreePik.OpenInBrowser(Item: TCnImageRespItem);
begin
  OpenUrl(Item.Url);
end;

function TCnImageProviderFreePik.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin
  Result := False; // 不支持图标集搜索
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProviderFreePik);

end.
