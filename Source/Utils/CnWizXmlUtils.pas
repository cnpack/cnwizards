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

unit CnWizXmlUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Xml Parser Helper 单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：Win7 SP1 + Delphi 2010
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2013.02.17
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes,
{$IFDEF CN_USE_MSXML}
  ActiveX, ComObj, msxml
{$ELSE}
  OmniXML, OmniXMLUtils
{$ENDIF};

{$IFDEF CN_USE_MSXML}
type
  IXMLNode = IXMLDOMNode;
  IXMLDocument = IXMLDOMDocument;

function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: WideString): WideString;
function GetTextChild(node: IXMLNode): IXMLNode;
function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: WideString): WideString;
function FindNode(parentNode: IXMLNode; matchesName: string): IXMLNode;
function CreateXMLDoc: IXMLDOMDocument;
{$ENDIF}

implementation

{$IFDEF CN_USE_MSXML}
function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
begin
  try
    value := StrToInt(nodeValue);
    Result := True;
  except
    on EConvertError do
      Result := False;
  end;
end;

function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
begin
  if not XMLStrToInt(nodeValue,Result) then
    Result := defaultValue;
end;

function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
var
  attrNode: IXMLNode;
begin
  attrNode := parentNode.Attributes.GetNamedItem(attrName);
  if not assigned(attrNode) then
    Result := False
  else begin
    value := attrNode.NodeValue;
    Result := True;
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
      Break; //for
    end;
end;

function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
var
  myNode: IXMLNode;
begin
  nodeText := '';
  Result := False;
  myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then
  begin
    nodeText := myNode.text;
    Result := True;
  end;
end;

function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(nodeText,defaultValue);
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

end.
