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

{$DEFINE USE_MSXML}

uses
  Windows, SysUtils, Classes, CnClasses;

type

  TCnFeedChannel = class;
  
  TCnFeedItem = class(TCnAssignableCollectionItem)
  private
    FIsNew: Boolean;
    FPubDate: TDateTime;
    FDescription: WideString;
    FCategory: WideString;
    FTitle: WideString;
    FAuthor: WideString;
    FLink: WideString;
  public
    function Channel: TCnFeedChannel;
  published
    property Title: WideString read FTitle write FTitle;
    property Link: WideString read FLink write FLink;
    property Description: WideString read FDescription write FDescription;
    property Category: WideString read FCategory write FCategory;
    property PubDate: TDateTime read FPubDate write FPubDate;
    property Author: WideString read FAuthor write FAuthor;
    property IsNew: Boolean read FIsNew write FIsNew;
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
    FUserData: Integer;
    function GetItems(Index: Integer): TCnFeedItem;
    procedure SetItems(Index: Integer; const Value: TCnFeedItem);
  public
    constructor Create;
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
    property UserData: Integer read FUserData write FUserData;
  end;

implementation

uses
{$IFDEF USE_MSXML}
  ActiveX, ComObj, msxml;
{$ELSE}
  OmniXML, OmniXMLUtils;
{$ENDIF}

{$IFDEF USE_MSXML}
type
  IXMLNode = IXMLDOMNode;
  IXMLDocument = IXMLDOMDocument;
{$ENDIF}

const
  csShortMonthNames: array[1..12] of string = ('Jan', 'Feb', 'Mar',
    'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

// From: IdGlobal.pas
// www.indyproject.org
function GmtOffsetStrToDateTime(S: WideString): TDateTime;
begin
  Result := 0.0;
  S := Copy(Trim(s), 1, 5);
  if Length(S) > 0 then
  begin
    if (s[1] = '-') or (s[1] = '+') then
    begin
      try
        Result := EncodeTime(StrToInt(Copy(s, 2, 2)), StrToInt(Copy(s, 4, 2)), 0, 0);
        if s[1] = '-' then
        begin
          Result := -Result;
        end;
      except
        Result := 0.0;
      end;
    end;
  end;
end;

// From: IdGlobal.pas
// www.indyproject.org
function OffsetFromUTC: TDateTime;
var
  iBias: Integer;
  tmez: TTimeZoneInformation;
begin
  Result := 0;
  Case GetTimeZoneInformation(tmez) of
    TIME_ZONE_ID_UNKNOWN  :
      iBias := tmez.Bias;
    TIME_ZONE_ID_DAYLIGHT :
      iBias := tmez.Bias + tmez.DaylightBias;
    TIME_ZONE_ID_STANDARD :
      iBias := tmez.Bias + tmez.StandardBias;
    else
      Exit;
  end;
  {We use ABS because EncodeTime will only accept positve values}
  Result := EncodeTime(Abs(iBias) div 60, Abs(iBias) mod 60, 0, 0);
  {The GetTimeZone function returns values oriented towards convertin
   a GMT time into a local time.  We wish to do the do the opposit by returning
   the difference between the local time and GMT.  So I just make a positive
   value negative and leave a negative value as positive}
  if iBias > 0 then begin
    Result := 0 - Result;
  end;
end;

function FeedStrToDateTime1(S: WideString; var Time: TDateTime): Boolean;
var
  i: Integer;
  T: WideString;
  List: TStringList;
  Y, M, D: Word;
begin
  Result := False;
  try
    // Wed, 09 Sep 2009 12:42:19 GMT
    T := Trim(S);
    if Pos(',', T) = 4 then
    begin
      Delete(T, 1, 4);
      T := Trim(T);
      List := TStringList.Create;
      try
        List.Text := StringReplace(T, ' ', #13#10, [rfReplaceAll]);
        for i := List.Count - 1 downto 0 do
          if Trim(List[i]) = '' then
            List.Delete(i);
        if List.Count > 4 then
        begin
          D := StrToInt(List[0]);
          M := 0;
          for i := Low(csShortMonthNames) to High(csShortMonthNames) do
            if SameText(csShortMonthNames[i], List[1]) then
            begin
              M := i;
              Break;
            end;
          Y := StrToInt(List[2]);
          if Y < 100 then
            Y := 1900 + Y;
          Time := EncodeDate(Y, M, D) + StrToTime(List[3]);
          if List.Count > 4 then
            Time := Time - GmtOffsetStrToDateTime(List[4]);
          Time := Time + OffsetFromUTC;
          Result := True;
        end;
      finally
        List.Free;
      end;
    end;
  except
    ;
  end;
end;

function FeedStrToDateTime2(S: WideString; var Time: TDateTime): Boolean;
var
  T: WideString;
  Y, M, D: Word;
begin
  Result := False;
  try
    T := Trim(S);
    if Length(T) < 19 then Exit;
    // 2010-04-09T14:55:18Z
    if T[11] = 'T' then
    begin
      Y := StrToInt(Copy(T, 1, 4));
      M := StrToInt(Copy(T, 6, 2));
      D := StrToInt(Copy(T, 9, 2));
      Time := EncodeDate(Y, M, D) + StrToTime(Copy(T, 12, 8));
      if (Length(T) > 19) and (T[20] = 'Z') then
        Time := Time + OffsetFromUTC;
      Result := True;
    end;
  except
    ;
  end;
end;  

function FeedStrToDateTime(S: WideString): TDateTime;
begin
  if not FeedStrToDateTime1(S, Result) and not FeedStrToDateTime2(S, Result) then
    Result := Now;
end;

{$IFDEF USE_MSXML}
function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
var
  attrNode: IXMLNode;
begin
  attrNode := parentNode.Attributes.GetNamedItem(attrName);
  if not assigned(attrNode) then
    Result := false
  else begin
    value := attrNode.NodeValue;
    Result := true;
  end;
end;

function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeAttr(parentNode,attrName,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end;

function GetTextChild(node: IXMLNode): IXMLNode;
var
  iText: integer;
begin
  Result := nil;
  for iText := 0 to node.ChildNodes.Length-1 do
    if node.ChildNodes.Item[iText].NodeType = NODE_TEXT then begin
      Result := node.ChildNodes.Item[iText];
      break; //for
    end;
end;

function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
var
  myNode: IXMLNode;
begin
  nodeText := '';
  Result := false;
  myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then
  begin
    nodeText := myNode.text;
    Result := true;
  end;
end;

function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeText(parentNode,nodeTag,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end;

function FindNode(parentNode: IXMLNode; matchesName: string): IXMLNode;
var
  i: Integer;
begin
  for i := 0 to parentNode.childNodes.length - 1 do
    if SameText(parentNode.childNodes.item[i].nodeName, matchesName) then
    begin
      Result := parentNode.childNodes.item[i];
      Exit;
    end;
  Result := nil;
end;

function CreateXMLDoc: IXMLDOMDocument;
begin
  try
    Result := CreateOleObject('Microsoft.XMLDOM') as IXMLDomDocument;
  except
    ;
  end;
end;
{$ENDIF}

{ TCnFeedItem }

function TCnFeedItem.Channel: TCnFeedChannel;
begin
  Result := TCnFeedChannel(Collection);
end;

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
  XML: IXMLDocument;
  Node, Item, Tmp: IXMLNode;
  i: Integer;

  function GetATOMLinkProp(ANode: IXMLNode): WideString;
  var
    i: Integer;
    N: IXMLNode;
  begin
    Result := '';
    for i := 0 to ANode.ChildNodes.Length - 1 do
    begin
      N := ANode.ChildNodes.Item[i];
      if SameText('link', N.NodeName) then
      begin
        if (Result = '') or SameText(GetNodeAttrStr(N, 'rel', ''), 'alternate') then
          Result := GetNodeAttrStr(N, 'href', '');
      end;
    end;
  end;
begin
  try
    Clear;
    XML := CreateXMLDoc;
    if (XML <> nil) and XML.load(FileName) then
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
        Title := GetNodeTextStr(Node, 'title', '');
        Link := GetATOMLinkProp(Node);
        Description := GetNodeTextStr(Node, 'description', '');
        Language := GetNodeTextStr(Node, 'language', '');
        PubDate := FeedStrToDateTime(GetNodeTextStr(Node, 'updated', ''));
        LastBuildDate := FeedStrToDateTime(GetNodeTextStr(Node, 'lastBuildDate', ''));

        for i := 0 to Node.ChildNodes.Length - 1 do
        begin
          if SameText(Node.ChildNodes.Item[i].NodeName, 'entry') then
          begin
            Item := Node.ChildNodes.Item[i];
            with TCnFeedItem(Add) do
            begin
              Title := GetNodeTextStr(Item, 'title', '');
              Link := GetATOMLinkProp(Item);
              Description := GetNodeTextStr(Item, 'content', '');
              Category := GetNodeTextStr(Item, 'category', '');
              Tmp := FindNode(Item, 'author');
              if Tmp <> nil then
                Author := GetNodeTextStr(Tmp, 'name', '');
              PubDate := FeedStrToDateTime(GetNodeTextStr(Item, 'updated', ''));
            end;
          end;
        end;
        Exit;
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
