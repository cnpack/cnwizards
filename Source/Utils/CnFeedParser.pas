{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnFeedParser;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：RSS Parser 单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: $
* 修改记录：2010.04.08
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnClasses;

type

  TCnFeedItem = class(TCnAssignableCollectionItem)
  private
    FPubDate: TDateTime;
    FDescription: WideString;
    FCategory: WideString;
    FTitle: WideString;
    FAuthor: WideString;
    FLink: WideString;
  published
    property Title: WideString read FTitle write FTitle;
    property Link: WideString read FLink write FLink;
    property Description: WideString read FDescription write FDescription;
    property Category: WideString read FCategory write FCategory;
    property PubDate: TDateTime read FPubDate write FPubDate;
    property Author: WideString read FAuthor write FAuthor;
  end;

  TCnFeedChannel = class(TCnAssignableCollection)
  private
    FLastBuildDate: TDateTime;
    FPubDate: TDateTime;
    FDescription: WideString;
    FTitle: WideString;
    FLanguage: WideString;
    FLink: WideString;
    FIDStr: WideString;
    function GetItems(Index: Integer): TCnFeedItem;
    procedure SetItems(Index: Integer; const Value: TCnFeedItem);
  public
    constructor Create;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);

    property Items[Index: Integer]: TCnFeedItem read GetItems write SetItems; default;
  published
    property IDStr: WideString read FIDStr write FIDStr;
    property Title: WideString read FTitle write FTitle;
    property Link: WideString read FLink write FLink;
    property Description: WideString read FDescription write FDescription;
    property Language: WideString read FLanguage write FLanguage;
    property PubDate: TDateTime read FPubDate write FPubDate;
    property LastBuildDate: TDateTime read FLastBuildDate write FLastBuildDate;
  end;

implementation

uses
  OmniXML, OmniXMLUtils;

{ TCnFeedChannel }                                 

constructor TCnFeedChannel.Create;
begin
  inherited Create(TCnFeedItem);
end;

function TCnFeedChannel.GetItems(Index: Integer): TCnFeedItem;
begin
  Result := TCnFeedItem(inherited Items[Index]);
end;

procedure TCnFeedChannel.LoadFromFile(const FileName: string);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FileName);
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCnFeedChannel.LoadFromStream(Stream: TStream);
var
  XML: IXMLDocument;
  Node, Item: IXMLNode;
  i: Integer;
  
  function FeedStrToDateTime(S: WideString): TDateTime;
  begin
    if not XMLStrToDateTime(S, Result) then
      Result := Now; // todo: FeedStrToDateTime
  end;  
begin
  try
    Clear;
    XML := CreateXMLDoc;
    if XML.LoadFromStream(Stream) then
    begin
      // RSS 2.0
      Node := FindNode(XML, 'rss');
      if Node <> nil then
      begin
        Node := FindNode(Node, 'channel');
        if Node <> nil then
        begin
          Title := GetNodeTextStr(Node, 'title', '');
          Link := GetNodeTextStr(Node, 'link', '');
          Description := GetNodeTextStr(Node, 'description', '');
          Language := GetNodeTextStr(Node, 'language', '');
          PubDate := FeedStrToDateTime(GetNodeTextStr(Node, 'pubDate', ''));
          LastBuildDate := FeedStrToDateTime(GetNodeTextStr(Node, 'lastBuildDate', ''));

          for i := 0 to Node.ChildNodes.Length - 1 do
          begin
            if SameText(Node.ChildNodes.Item[i].NodeName, 'item') then
            begin
              Item := Node.ChildNodes.Item[i];
              with TCnFeedItem(Add) do
              begin
                Title := GetNodeTextStr(Item, 'title', '');
                Link := GetNodeTextStr(Item, 'link', '');
                Description := GetNodeTextStr(Item, 'description', '');
                Category := GetNodeTextStr(Item, 'category', '');
                Author := GetNodeTextStr(Item, 'author', '');
                PubDate := FeedStrToDateTime(GetNodeTextStr(Item, 'pubDate', ''));
              end;
            end;
          end;
          Exit;
        end;
      end;

      // ATOM
      Node := FindNode(XML, 'feed');
      if Node <> nil then
      begin
        // todo: Support ATOM format
      end;  
    end;
  except
    ;
  end;
end;

procedure TCnFeedChannel.SetItems(Index: Integer;
  const Value: TCnFeedItem);
begin
  inherited Items[Index] := Value;
end;

end.
