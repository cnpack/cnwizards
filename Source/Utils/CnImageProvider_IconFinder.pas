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

unit CnImageProvider_IconFinder;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：www.IconFinder.com 服务支持单元
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
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
  TCnImageProvider_IconFinder = class(TCnBaseImageProvider)
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

{ TCnImageProvider_IconFinder }

constructor TCnImageProvider_IconFinder.Create;
begin
  inherited;
  FItemsPerPage := 20;
  FFeatures := [pfOpenInBrowser, pfSearchIconset];
end;

destructor TCnImageProvider_IconFinder.Destroy;
begin

  inherited;
end;

class procedure TCnImageProvider_IconFinder.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'IconFinder.com';
  HomeUrl := 'http://www.iconfinder.com';
end;

function TCnImageProvider_IconFinder.DoSearchImage(Req: TCnImageReqInfo): Boolean;
var
  Url, Text: string;
  Lic: Integer;
  Xml: IXMLDocument;
  Root, Node, Icon: IXMLNode;
  I, J, Size: Integer;
  Item: TCnImageRespItem;
begin
  Result := False;
  if Req.CommercialLicenses then
    Lic := 1
  else
    Lic := 0;
  Url := Format('http://www.iconfinder.com/xml/search/?q=%s&c=%d&p=%d&l=%d&min=%d&max=%d&api_key=7cb3bc9947285bc4b3a2f2d8bd20a3dd',
    [Req.Keyword, FItemsPerPage, Req.Page, Lic, Req.MinSize, Req.MaxSize]);
  Text := string(CnInet_GetString(Url));
  Xml := CreateXMLDoc;
  if Xml.LoadXML(Text) then
  begin
    Root := FindNode(Xml, 'results');
    if Root <> nil then
    begin
      for I := 0 to Root.ChildNodes.Length - 1 do
      begin
        Node := Root.ChildNodes.Item[I];
        if SameText(Node.NodeName, 'opensearch:totalResults') then
        begin
          FTotalCount := XMLStrToIntDef(Node.Text, 0);
          FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
        end
        else if SameText(Node.NodeName, 'iconmatches') then
        begin
          Result := True;
          for J := 0 to Node.ChildNodes.Length - 1 do
          begin
            Icon := Node.ChildNodes.Item[J];
            if SameText(Icon.NodeName, 'icon') then
            begin
              Size := GetNodeTextInt(Icon, 'size', 0);
              if (Size >= Req.MinSize) and (Size <= Req.MaxSize) then
              begin
                Item := Items.Add;
                Item.Size := Size;
                Item.Id := GetNodeTextStr(Icon, 'id', '');
                Item.Url := GetNodeTextStr(Icon, 'image', '');
                Item.Ext := _CnExtractFileExt(Item.Url);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCnImageProvider_IconFinder.OpenInBrowser(Item: TCnImageRespItem);
begin
  OpenUrl(Format('http://www.iconfinder.com/icondetails/%s/%d/', [Item.Id, Item.Size]));
end;

function TCnImageProvider_IconFinder.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
var
  Url, Text: string;
  Xml: IXMLDocument;
  Root, Node: IXMLNode;
begin
  Result := False;
  Url := Format('http://www.iconfinder.com/xml/icondetails/?id=%s&size=%d&api_key=7cb3bc9947285bc4b3a2f2d8bd20a3dd',
    [Item.Id, Item.Size]);
  Text := string(CnInet_GetString(Url));
  Xml := CreateXMLDoc;
  if Xml.LoadXML(Text) then
  begin
    Root := FindNode(Xml, 'icon');
    if Root <> nil then
    begin
      Node := FindNode(Root, 'iconsetid');
      if Node <> nil then
      begin
        Req.Keyword := 'iconset:' + Node.Text;
        Req.Page := 0;
        Result := True;
      end;
    end;
  end;
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProvider_IconFinder);

end.
