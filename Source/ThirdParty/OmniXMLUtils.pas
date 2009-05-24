(*:XML helper unit. Contains routines to convert data, retrieve/set data of
   different types, manipulate nodes, load/save XML documents.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2002 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2001-10-25
   Last modification : 2003-04-01
   Version           : 1.13
</pre>*)(*
   History:
     1.13: 2003-04-01
       - Filter* and Find* routines modified to skip all non-ELEMENT_NODE nodes.
     1.12b: 2003-01-15
       - Safer implementation of some internal functions.
     1.12a: 2003-01-13
       - Adapted for latest fixes in OmniXML 2002-01-13.
     1.12: 2003-01-13
       - CopyNode, and CloneDocument made MS XML compatible.
       - Automatic DocumentElement dereferencing now works with MS XML.
     1.11: 2003-01-13
       - Fixed buggy GetNode(s)Text*/SetNode(s)Text* functions.
       - Fixed buggy CopyNode and CloneDocument.
     1.10a: 2003-01-09
       - Fixed filterProc support in the CopyNode.
     1.10: 2003-01-07
       - Added functions XMLLoadFromRegistry and XMLSaveToRegistry.
       - Added function CloneDocument.
       - Added parameter filterProc to the CopyNode procedure.
       - Smarter GetNodeAttr (automatically dereferences DocumentElement if
         root xml node is passed to it).
     1.09: 2002-12-26
       - Added procedure CopyNode that copies contents of one node into another.
       - Modified DeleteAllChildren to preserve Text property.
     1.08: 2002-12-21
       - Smarter GetNodeText (automatically dereferences DocumentElement if
         root xml node is passed to it).
     1.07a: 2002-12-10
       - Bug fixed in XMLSaveToString (broken since 1.06).
     1.07: 2002-12-09
       - Added XMLLoadFromFile and XMLSaveToFile.
       - Small code cleanup.
     1.06: 2002-12-09
       - MSXML compatible (define USE_MSXML).
     1.05a: 2002-11-23
       - Fixed bug in Base64Decode.
     1.05: 2002-11-05
       - Added function ConstructXMLDocument.
     1.04: 2002-10-03
       - Added function EnsureNode.
     1.03: 2002-09-24
       - Added procedure SetNodesText.
     1.02: 2002-09-23
       - SetNode* familiy of procedures changed into functions returning the
         modified node.
     1.01: 2001-11-07
       - (mr) Added function XMLDateTimeToStrEx.
       - (mr) ISODateTime2DateTime enhanced.
       - (mr) Bug fixed in Str2Time.
     1.0: 2001-10-25
       - Created by extracting common utilities from unit GpXML.
*)

unit OmniXMLUtils;

interface

{$I CnWizards.inc}

uses
  Windows,
  Classes,
  OmniXML
{$IFDEF USE_MSXML}
  , OmniXML_MSXML
{$ENDIF USE_MSXML}
  ;

// TODO 1 -oPrimoz Gabrijelcic: Convert this class to use GpManagedClass and pre/post-conditions.

  {:Delete the specified node.
  }
  procedure DeleteNode(parentNode: IXMLNode; nodeTag: string);

  {:Delete all/some children of the specified node.
  }
  procedure DeleteAllChildren(parentNode: IXMLNode; pattern: string = '');

  {:Returns text of the specified node. Result is True if node exists, False
    otherwise.
  }
  function GetNodeText(parentNode: IXMLNode; nodeTag: string;
    var nodeText: WideString): boolean;

  {:Returns texts of all child nodes into the string list. Text for each child
    is trimmed before it is stored in the list. Caller must create result list
    in advance.
  }
  procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
    {var} nodesText: TStrings); overload;

  {:Returns texts of all child nodes as a CRLF-delimited string.
  }
  procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
    var nodesText: string); overload;

  {:A family of functions that will return node text reformatted into another
    type or default value if node doesn't exist or if node text is not in a
    proper format. Basically they all call GetNodeText and convert the result.
  }
  function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
    defaultValue: WideString): WideString;
  function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
    defaultValue: real): real;
  function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
    defaultValue: integer): integer;
  function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
    defaultValue: int64): int64;
  function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
    defaultValue: boolean): boolean;
  function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
    defaultValue: TDateTime): TDateTime;
  function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
    defaultValue: TDateTime): TDateTime;
  function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
    defaultValue: TDateTime): TDateTime;
  procedure GetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
    const value: TStream);

  {:Returns value of the specified attribute. Result is True if attribute
    exists, False otherwise.
  }
  function GetNodeAttr(parentNode: IXMLNode; attrName: string;
    var value: WideString): boolean;
    
  {:A family of functions that will return attribute value reformatted into
    another type or default value if attribute doesn't exist or if attribute
    is not in a proper format. Basically they all call GetNodeAttr and
    convert the result.
  }
  function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
    defaultValue: WideString): WideString;
  function GetNodeAttrReal(parentNode: IXMLNode; attrName: string;
    defaultValue: real): real; 
  function GetNodeAttrInt(parentNode: IXMLNode; attrName: string;
    defaultValue: integer): integer;
  function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
    defaultValue: int64): int64;
  function GetNodeAttrBool(parentNode: IXMLNode; attrName: string;
    defaultValue: boolean): boolean;
  function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
    defaultValue: TDateTime): TDateTime;
  function GetNodeAttrDate(parentNode: IXMLNode; attrName: string;
    defaultValue: TDateTime): TDateTime;
  function GetNodeAttrTime(parentNode: IXMLNode; attrName: string;
    defaultValue: TDateTime): TDateTime;

  {:A family of functions used to convert string to some other value according
    to the conversion rules used in this unit. Used in Get* functions above.
  }
  function XMLStrToReal(nodeValue: WideString; var value: real): boolean;
  function XMLStrToRealDef(nodeValue: WideString; defaultValue: real): real;
  function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
  function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
  function XMLStrToInt64(nodeValue: WideString; var value: int64): boolean;
  function XMLStrToInt64Def(nodeValue: WideString; defaultValue: int64): int64;
  function XMLStrToBool(nodeValue: WideString; var value: boolean): boolean;
  function XMLStrToBoolDef(nodeValue: WideString; defaultValue: boolean): boolean;
  function XMLStrToDateTime(nodeValue: WideString; var value: TDateTime): boolean;
  function XMLStrToDateTimeDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
  function XMLStrToDate(nodeValue: WideString; var value: TDateTime): boolean;
  function XMLStrToDateDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
  function XMLStrToTime(nodeValue: WideString; var value: TDateTime): boolean;
  function XMLStrToTimeDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
  function XMLStrToBinary(nodeValue: WideString; const value: TStream): boolean;

  {:Creates the node if it doesn't exist, then sets node text to the specified
    value.
  }
  function SetNodeText(parentNode: IXMLNode; nodeTag: string;
    value: WideString): IXMLNode;

  {:Sets texts for many child nodes. All nodes are created anew. 
  }
  procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
    nodesText: TStrings); overload;

  {:Sets texts for many child nodes. All nodes are created anew.
    @param nodesText Contains CRLF-delimited text list. 
  }
  procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
    nodesText: string); overload;

  {:A family of functions that will first check that the node exists (creating
    it if necessary) and then set node text to the properly formatted value.
    Basically they all reformat the value to the string and then call
    SetNodeText.
  }
  function SetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
    value: WideString): IXMLNode;
  function SetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
    value: real): IXMLNode;
  function SetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
    value: integer): IXMLNode;
  function SetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
    value: int64): IXMLNode;
  function SetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
    value: boolean): IXMLNode;
  function SetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
    const value: TStream): IXMLNode; overload;

  {:Creates the attribute if it doesn't exist, then sets it to the specified
    value.
  }
  procedure SetNodeAttr(parentNode: IXMLNode; attrName: string;
    value: WideString);

  {:A family of functions that will first check that the attribute exists
    (creating it if necessary) and then set attribute's value to the properly
    formatted value. Basically they all reformat the value to the string and
    then call SetNodeAttr.
  }
  procedure SetNodeAttrStr(parentNode: IXMLNode; attrName: string;
    value: WideString);
  procedure SetNodeAttrReal(parentNode: IXMLNode; attrName: string;
    value: real);
  procedure SetNodeAttrInt(parentNode: IXMLNode; attrName: string;
    value: integer);
  procedure SetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
    value: int64);
  procedure SetNodeAttrBool(parentNode: IXMLNode; attrName: string;
    value: boolean);
  procedure SetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
    value: TDateTime);
  procedure SetNodeAttrDate(parentNode: IXMLNode; attrName: string;
    value: TDateTime);
  procedure SetNodeAttrTime(parentNode: IXMLNode; attrName: string;
    value: TDateTime);

  {:A family of functions used to convert value to string according to the
    conversion rules used in this unit. Used in Set* functions above.
  }
  function XMLRealToStr(value: real): WideString;
  function XMLIntToStr(value: integer): WideString;
  function XMLInt64ToStr(value: int64): WideString;
  function XMLBoolToStr(value: boolean): WideString;
  function XMLDateTimeToStr(value: TDateTime): WideString;
  function XMLDateTimeToStrEx(value: TDateTime): WideString;
  function XMLDateToStr(value: TDateTime): WideString;
  function XMLTimeToStr(value: TDateTime): WideString;
  function XMLBinaryToStr(value: TStream): WideString; overload;

{$IFNDEF USE_MSXML}
  {:Select specified child nodes. Can filter on subnode name and text.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName: string;
    matchesText: string = ''): IXMLNodeList; overload;

  {:Select specified child nodes. Can filter on subnode name, subnode text and
    on grandchildren names.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames: array of string): IXMLNodeList; overload;

  {:Select specified child nodes. Can filter on subnode name, subnode text and
    on grandchildren names and text.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames, matchesChildText: array of string): IXMLNodeList; overload;
{$ENDIF USE_MSXML}

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name and text.
  }
  function FindNode(parentNode: IXMLNode; matchesName: string;
    matchesText: string = ''): IXMLNode; overload;

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name, subnode text and on grandchildren names.
  }
  function FindNode(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames: array of string): IXMLNode; overload;

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name, subnode text and on grandchildren names and text.
  }
  function FindNode(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames, matchesChildText: array of string): IXMLNode; overload;

  {:Load XML document from the named RCDATA resource and return interface to it.
  }
  function XMLLoadFromResource(xmlDocument: IXMLDocument;
    const resourceName: string): boolean;

  {:Load XML document from a string.
  }
  function XMLLoadFromString(xmlDocument: IXMLDocument;
    const xmlData: WideString): boolean;

  {:Save XML document to a string.
  }
  function XMLSaveToString(xmlDocument: IXMLDocument;
    outputFormat: TOutputFormat = ofNone): WideString;

  {:Load XML document from a stream.
  }
  function XMLLoadFromStream(xmlDocument: IXMLDocument;
    const xmlStream: TStream): boolean;

  {:Save XML document to a stream.
  }
  procedure XMLSaveToStream(xmlDocument: IXMLDocument;
    const xmlStream: TStream; outputFormat: TOutputFormat = ofNone);

  {:Load XML document from a file.
  }
  function XMLLoadFromFile(xmlDocument: IXMLDocument;
    const xmlFileName: string): boolean;

  {:Save XML document to a file.
  }
  procedure XMLSaveToFile(xmlDocument: IXMLDocument;
    const xmlFileName: string; outputFormat: TOutputFormat = ofNone);

  {:Load XML document from the registry.
  }
  function  XMLLoadFromRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
    const key, value: string): boolean;

  {:Save XML document to the registry.
  }
  function XMLSaveToRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
    const key, value: string; outputFormat: TOutputFormat): boolean;

  {:Ensure that the node exists and return its interface.
  }
  function EnsureNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;

  {:Constructs XML document from given data.
  }
  function ConstructXMLDocument(const documentTag: string;
    const nodeTags, nodeValues: array of string): IXMLDocument; overload;

  {:Constructs XML document containing only documentelement node.
  }
  function ConstructXMLDocument(const documentTag: string): IXMLDocument; overload;

type
  TFilterXMLNodeEvent = procedure(node: IXMLNode; var canProcess: boolean) of object;

  {:Copies contents of one node into another. Some (sub)nodes can optionally be
    filtered out during the copy operation.
  }
  procedure CopyNode(sourceNode, targetNode: IXMLNode;
    copySubnodes: boolean = true; filterProc: TFilterXMLNodeEvent = nil);

  {:Creates a copy of a XML document. Some nodes can optionally be filtered out
    during the copy operation.
    @since   2003-01-06
  }
  function CloneDocument(sourceDoc: IXMLDocument;
    filterProc: TFilterXMLNodeEvent = nil): IXMLDocument;

  {:Decode base64-encoded stream.
  }
  function  Base64Decode(const encoded, decoded: TStream): boolean;

  {:Encode a stream into base64 form.
  }
  procedure Base64Encode(const decoded, encoded: TStream);

implementation

uses
  SysUtils,
  Registry,
  GpMemStr;

const
  DEFAULT_DECIMALSEPARATOR  = '.'; // don't change!
  DEFAULT_TRUE              = '1'; // don't change!
  DEFAULT_FALSE             = '0'; // don't change!
  DEFAULT_DATETIMESEPARATOR = 'T'; // don't change!
  DEFAULT_DATESEPARATOR     = '-'; // don't change!
  DEFAULT_TIMESEPARATOR     = ':'; // don't change!
  DEFAULT_MSSEPARATOR       = '.'; // don't change!

{:Convert time from string (ISO format) to TDateTime.
}
function Str2Time(s: string): TDateTime;
var
  hour  : word;
  minute: word;
  msec  : word;
  p     : integer;
  second: word;
begin
  s := Trim(s);
  if s = '' then
    Result := 0
  else begin
    p := Pos(DEFAULT_TIMESEPARATOR,s);
    hour := StrToInt(Copy(s,1,p-1));
    Delete(s,1,p);
    p := Pos(DEFAULT_TIMESEPARATOR,s);
    minute := StrToInt(Copy(s,1,p-1));
    Delete(s,1,p);
    p := Pos(DEFAULT_MSSEPARATOR,s);
    if p > 0 then begin
      msec := StrToInt(Copy(s,p+1,Length(s)-p));
      Delete(s,p,Length(s)-p+1);
    end
    else
      msec := 0;
    second := StrToInt(s);
    Result := EncodeTime(hour,minute,second,msec);
  end;
end; { Str2Time }

{:Convert date/time from string (ISO format) to TDateTime.
}
function ISODateTime2DateTime (const ISODT: String): TDateTime;
var
  day   : word;
  month : word;
  p     : integer;
  sDate : string;
  sTime : string;
  year  : word;
begin
  p := Pos (DEFAULT_DATETIMESEPARATOR,ISODT);
  // detect all known date/time formats
  if (p = 0) and (Pos(DEFAULT_DATESEPARATOR, ISODT) > 0) then
    p := Length(ISODT) + 1;
  sDate := Trim(Copy(ISODT,1,p-1));
  sTime := Trim(Copy(ISODT,p+1,Length(ISODT)-p));
  Result := 0;
  if sDate <> '' then begin
    p := Pos (DEFAULT_DATESEPARATOR,sDate);
    year :=  StrToInt(Copy(sDate,1,p-1));
    Delete(sDate,1,p);
    p := Pos (DEFAULT_DATESEPARATOR,sDate);
    month :=  StrToInt(Copy(sDate,1,p-1));
    day := StrToInt(Copy(sDate,p+1,Length(sDate)-p));
    Result := EncodeDate(year,month,day);
  end;
  Result := Result + Frac(Str2Time(sTime));
end; { ISODateTime2DateTime }

function Base64Decode(const encoded, decoded: TStream): boolean;
var
  ch: char;
  group3: longint; { Must be a 3+ byte entity }
  idx: integer;
  outb: array [1..3] of byte;
begin
  Result := true;
  group3 := 0;
  idx := 0;
  while encoded.Read(ch,1) = 1 do begin
    case ch of
      'A'..'Z': group3 := (group3 shl 6) + Ord(ch) - Ord('A');
      'a'..'z': group3 := (group3 shl 6) + Ord(ch) - Ord('a') + 26;
      '0'..'9': group3 := (group3 shl 6) + Ord(ch) - Ord('0') + 52;
      '+'     : group3 := (group3 shl 6) + 62;
      '/'     : group3 := (group3 shl 6) + 63;
      '='     : group3 := (group3 shl 6);
      else begin
        Result := false;
        Exit;
      end;
    end; //case
    if ch <> '=' then
      idx := (idx + 1) mod 4;
    if idx = 0 then begin
      outb[1] := (group3 shr 16) and $ff;
      outb[2] := (group3 shr 8)  and $ff;
      outb[3] := group3 and $ff;
      decoded.Write(outb,3);
      group3 := 0;
    end;
  end;
  { Do the last one or two bytes }
  case Idx of
   0:
     { Not possible };
   2:
     begin
       { Two encoded-data bytes yield one decoded byte }
       outb[1] := (Group3 shr 16) and $ff;
       decoded.Write(outb,1);
     end; //2
   3:
     begin
       { Three encoded-data bytes yield two decoded bytes }
       outb[1] := (Group3 shr 16) and $ff;
       outb[2] := (Group3 shr 8) and $ff;
       decoded.Write(outb,2);
     end; //3
   else
     Result := false;
  end; //case
end;

procedure Base64Encode(const decoded, encoded: TStream);
var
  alphabet: array[0..63] of byte;
  i: byte;
  inb: array [1..3] of byte;
  outb: array [1..4] of byte;
  numRead: integer;
begin
  { Setup the encoding alphabet }
  for i := 0 to 25 do begin
    alphabet[i] := i + Ord('A');
    alphabet[i+26] := i + Ord('a');
  end;
  for i := 0 to 9 do
    alphabet[i+52] := i + Ord('0');
  alphabet[62] := Ord('+');
  alphabet[63] := Ord('/');
  repeat
    numRead := decoded.Read(inb,3);
    if numRead <> 3 then
      break; //repeat
    outb[1] := alphabet[inb[1] shr 2];
    outb[2] := alphabet[((inb[1] and $03) shl 4) or (inb[2] shr 4)];
    outb[3] := alphabet[((inb[2] and $0f) shl 2) or (inb[3] shr 6)];
    outb[4] := alphabet[inb[3] and $3f];
    encoded.Write(outb,4);
  until false;
  if numRead = 1 then begin
    outb[1] := alphabet[inb[1] shr 2];
    outb[2] := alphabet[(inb[1] and $03) shl 4];
    outb[3] := Ord('=');
    outb[4] := Ord('=');
    encoded.Write(outb,4);
  end
  else if numRead = 2 then begin
    outb[1] := alphabet[inb[1] shr 2];
    outb[2] := alphabet[((inb[1] and $03) shl 4) or (inb[2] shr 4)];
    outb[3] := alphabet[(inb[2] and $0f) shl 2];
    outb[4] := Ord('=');
    encoded.Write(outb,4);
  end;
end; { Base64Encode }

{:Checks whether the specified node is an xml document node.
  @since   2003-01-13
}
function IsDocument(node: IXMLNode): boolean;
var
  docNode: IXMLDocument;
begin
  Result := Supports(node, IXMLDocument, docNode);
end; { IsDocument }

{:Returns owner document interface of the specified node.
  @since   2003-01-13
}
function OwnerDocument(node: IXMLNode): IXMLDocument;
begin
  if not Supports(node, IXMLDocument, Result) then
    Result := node.OwnerDocument;
end; { OwnerDocument }

{:Returns document element node.
  @since   2003-01-13
}
function DocumentElement(node: IXMLNode): IXMLElement;
begin
  Result := OwnerDocument(node).DocumentElement;
end; { DocumentElement }

{:Retrive text child of the specified node.
  @since   2003-01-13
}
function GetTextChild(node: IXMLNode): IXMLNode;
var
  iText: integer;
begin
  Result := nil;
  for iText := 0 to node.ChildNodes.Length-1 do
    if node.ChildNodes.Item[iText].NodeType = TEXT_NODE then begin
      Result := node.ChildNodes.Item[iText];
      break; //for
    end;
end; { GetTextChild }

{:Set the value of the text child and return its interface.
  @since   2003-01-13
}
function SetTextChild(node: IXMLNode; value: WideString): IXMLNode;
var
  iText: integer;
begin
  iText := 0;
  while iText < node.ChildNodes.Length do begin
    if node.ChildNodes.Item[iText].NodeType = TEXT_NODE then
      node.RemoveChild(node.ChildNodes.Item[iText])
    else
      Inc(iText);
  end; //while
  Result := OwnerDocument(node).CreateTextNode(value);
  node.AppendChild(Result);
end; { SetTextChild }

{:@param   parentNode Parent of the node to be deleted.
  @param   nodeTag    Name of the node (which is child of parentNode) to be
                      deleted.
}
procedure DeleteNode(parentNode: IXMLNode; nodeTag: string);
var
  myNode: IXMLNode;
begin
  myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then
    parentNode.RemoveChild(myNode);
end; { DeleteNode }

{:@param   parentNode Node containing children to be deleted.
  @param   pattern    Name of the children nodes that have to be deleted. If
                      empty, all children will be deleted.
}
procedure DeleteAllChildren(parentNode: IXMLNode; pattern: string = '');
var
  myNode  : IXMLNode;
  oldText : WideString;
  textNode: IXMLNode;
begin
  textNode := GetTextChild(parentNode);
  if assigned(textNode) then // following code will delete TEXT_NODE
    oldText := textNode.Text;
  repeat
    if pattern = '' then
      myNode := parentNode.FirstChild
    else
      myNode := parentNode.SelectSingleNode(pattern);
    if assigned(myNode) then
      parentNode.RemoveChild(myNode);
  until not assigned(myNode);
  if assigned(textNode) then 
    SetTextChild(parentNode, oldText);
end; { DeleteAllChildren }

function XMLStrToReal(nodeValue: WideString; var value: real): boolean;
begin
  try
    value := StrToFloat(StringReplace(nodeValue,DEFAULT_DECIMALSEPARATOR,
      DecimalSeparator,[rfReplaceAll]));
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToReal }

function XMLStrToRealDef(nodeValue: WideString; defaultValue: real): real;
begin
  if not XMLStrToReal(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToRealDef }

function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
begin
  try
    value := StrToInt(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToInt }

function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
begin
  if not XMLStrToInt(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToIntDef }

function XMLStrToInt64(nodeValue: WideString; var value: int64): boolean;
begin
  try
    value := StrToInt64(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToInt64 }

function XMLStrToInt64Def(nodeValue: WideString; defaultValue: int64): int64;
begin
  if not XMLStrToInt64(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToInt64Def }

function XMLStrToBool(nodeValue: WideString; var value: boolean): boolean;
begin
  if nodeValue = DEFAULT_TRUE then begin
    value := true;
    Result := true;
  end
  else if nodeValue = DEFAULT_FALSE then begin
    value := false;
    Result := true;
  end
  else
    Result := false;
end; { XMLStrToBool }

function XMLStrToBoolDef(nodeValue: WideString; defaultValue: boolean): boolean;
begin
  if not XMLStrToBool(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToBoolDef }

function XMLStrToDateTime(nodeValue: WideString; var value: TDateTime): boolean;
begin
  try
    value := ISODateTime2DateTime(nodeValue);
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToDateTime }

function XMLStrToDateTimeDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToDateTime(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToDateTimeDef }

function XMLStrToDate(nodeValue: WideString; var value: TDateTime): boolean;
begin
  try
    value := Int(ISODateTime2DateTime(nodeValue));
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToDate }

function XMLStrToDateDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToDate(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToDateDef }

function XMLStrToTime(nodeValue: WideString; var value: TDateTime): boolean;
begin
  try
    value := Str2Time(nodeValue);
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToTime }

function XMLStrToTimeDef(nodeValue: WideString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToTime(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToTimeDef }

function XMLStrToBinary(nodeValue: WideString; const value: TStream): boolean;
var
  nodeStream: TStringStream;
begin
  nodeStream := TStringStream.Create(nodeValue);
  try
    Result := Base64Decode(nodeStream, value);
  finally FreeAndNil(nodeStream); end;
end; { XMLStrToBinary }

function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
var
  myNode: IXMLNode;
begin
  myNode := nil;
  Result := false;
  if IsDocument(parentNode) and assigned(DocumentElement(parentNode)) then begin
    parentNode := DocumentElement(parentNode);
    if parentNode.NodeName = nodeTag then
      myNode := parentNode;
  end;
  if not assigned(myNode) then
    myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then begin
    myNode := GetTextChild(myNode);
    if assigned(myNode) then begin
      nodeText := myNode.Text;
      Result := true;
    end;
  end;
end; { GetNodeText }

procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
  {var} nodesText: TStrings); overload;
var
  iNode: integer;
  nodes: IXMLNodeList;
begin
  nodesText.Clear;
  nodes := parentNode.SelectNodes(nodeTag);
  for iNode := 0 to nodes.Length-1 do
    nodesText.Add(Trim(nodes.Item[iNode].Text));
end; { GetNodesText }

procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
  var nodesText: string); overload;
var
  texts: TStringList;
begin
  texts := TStringList.Create;
  try
    GetNodesText(parentNode, nodeTag, texts);
    nodesText := texts.Text;
  finally FreeAndNil(texts); end;
end; { GetNodesText }

function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeText(parentNode,nodeTag,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end; { GetNodeTextStr }

function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
  defaultValue: real): real;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToRealDef(nodeText,defaultValue);
end; { GetNodeTextReal }

function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(nodeText,defaultValue);
end; { GetNodeTextInt }

function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
  defaultValue: int64): int64;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToInt64Def(nodeText,defaultValue);
end; { GetNodeTextInt64 }

function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
  defaultValue: boolean): boolean;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToBoolDef(nodeText,defaultValue);
end; { GetNodeTextBool }

function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToDateTimeDef(nodeText,defaultValue);
end; { GetNodeTextDateTime }

function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToDateDef(nodeText,defaultValue);
end; { GetNodeTextDate }

function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToTimeDef(nodeText,defaultValue);
end; { GetNodeTextTime }

procedure GetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
  const value: TStream);
var
  decoded: TMemoryStream;
begin
  decoded := TMemoryStream.Create;
  try
    if XMLStrToBinary(GetNodeTextStr(parentNode,nodeTag,''),decoded) then
      value.CopyFrom(decoded,0);
  finally FreeAndNil(decoded); end;
end; { GetNodeTextBinary }

function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
var
  attrNode: IXMLNode;
begin
  if IsDocument(parentNode) and assigned(DocumentElement(parentNode)) then
    parentNode := DocumentElement(parentNode);
  attrNode := parentNode.Attributes.GetNamedItem(attrName);
  if not assigned(attrNode) then
    Result := false
  else begin
    value := attrNode.NodeValue;
    Result := true;
  end;
end; { GetNodeAttr }

function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeAttr(parentNode,attrName,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end; { GetNodeAttrStr }

function GetNodeAttrReal(parentNode: IXMLNode; attrName: string;
  defaultValue: real): real;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToRealDef(attrValue,defaultValue);
end; { GetNodeAttrReal }

function GetNodeAttrInt(parentNode: IXMLNode; attrName: string;
  defaultValue: integer): integer;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(attrValue,defaultValue);
end; { GetNodeAttrInt }

function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
  defaultValue: int64): int64;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToInt64Def(attrValue,defaultValue);
end; { GetNodeAttrInt64 }

function GetNodeAttrBool(parentNode: IXMLNode; attrName: string;
  defaultValue: boolean): boolean;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToBoolDef(attrValue,defaultValue);
end; { GetNodeAttrBool }

function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToDateTimeDef(attrValue,defaultValue);
end; { GetNodeAttrDateTime }

function GetNodeAttrDate(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToDateDef(attrValue,defaultValue);
end; { GetNodeAttrDate }

function GetNodeAttrTime(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: WideString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToTimeDef(attrValue,defaultValue);
end; { GetNodeAttrTime }

function XMLRealToStr(value: real): WideString;
begin
  Result := StringReplace(FloatToStr(value),
    DecimalSeparator,DEFAULT_DECIMALSEPARATOR,[rfReplaceAll]);
end; { XMLRealToStr }

function XMLIntToStr(value: integer): WideString;
begin
  Result := IntToStr(value);
end; { XMLIntToStr }

function XMLInt64ToStr(value: int64): WideString;
begin
  Result := IntToStr(value)
end; { XMLInt64ToStr }

function XMLBoolToStr(value: boolean): WideString;
begin
  if value then
    Result := DEFAULT_TRUE
  else
    Result := DEFAULT_FALSE;
end; { XMLBoolToStr }

function XMLDateTimeToStr(value: TDateTime): WideString;
begin
  Result := FormatDateTime('yyyy-mm-dd"'+
    DEFAULT_DATETIMESEPARATOR+'"hh":"mm":"ss.zzz',value)
end; { XMLDateTimeToStr }

function XMLDateTimeToStrEx(value: TDateTime): WideString;
begin
  if Trunc(value) = 0 then
    Result := XMLTimeToStr(value)
  else if Frac(Value) = 0 then
    Result := XMLDateToStr(value)
  else
    Result := XMLDateTimeToStr(value);
end; { XMLDateTimeToStrEx }

function XMLDateToStr(value: TDateTime): WideString;
begin
  Result := FormatDateTime('yyyy-mm-dd',value);
end; { XMLDateToStr }

function XMLTimeToStr(value: TDateTime): WideString;
begin
  Result := FormatDateTime('hh":"mm":"ss.zzz',value);
end; { XMLTimeToStr }

function XMLBinaryToStr(value: TStream): WideString;
var
  nodeStream: TStringStream;
begin
  nodeStream := TStringStream.Create('');
  try
    Base64Encode(value, nodeStream);
    Result := nodeStream.DataString;
  finally FreeAndNil(nodeStream); end;
end; { XMLBinaryToStr }

function SetNodeText(parentNode: IXMLNode; nodeTag: string;
  value: WideString): IXMLNode;
begin
  Result := EnsureNode(parentNode, nodeTag);
  SetTextChild(Result, value);
end; { SetNodeText }

procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
  nodesText: TStrings); overload;
var
  childNode: IXMLNode;
  iText    : integer;
begin
  for iText := 0 to nodesText.Count-1 do begin
    childNode := OwnerDocument(parentNode).CreateElement(nodeTag);
    parentNode.AppendChild(childNode);
    childNode.Text := nodesText[iText];
  end; //for
end; { SetNodesText }

procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
  nodesText: string); overload;
var
  texts: TStringList;
begin
  texts := TStringList.Create;
  try
    texts.Text := nodesText;
    SetNodesText(parentNode, nodeTag, texts);
  finally FreeAndNil(texts); end;
end; { SetNodesText }

function SetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  value: WideString): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,value);
end; { SetNodeTextStr }

function SetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
  value: real): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLRealToStr(value));
end; { SetNodeTextReal }

function SetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  value: integer): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLIntToStr(value));
end; { SetNodeTextInt }

function SetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
  value: int64): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLInt64ToStr(value));
end; { SetNodeTextInt64 }

function SetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
  value: boolean): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLBoolToStr(value));
end; { SetNodeTextBool }

function SetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLDateTimeToStr(value));
end; { SetNodeTextDateTime }

function SetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLDateToStr(value));
end; { SetNodeTextDate }

function SetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLTimeToStr(value));
end; { SetNodeTextTime }

function SetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
  const value: TStream): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLBinaryToStr(value));
end; { SetNodeTextBinary }

procedure SetNodeAttr(parentNode: IXMLNode; attrName: string;
  value: WideString);
var
  attrNode: IXMLNode;
begin
  attrNode := OwnerDocument(parentNode).CreateAttribute(attrName);
  attrNode.NodeValue := value;
  parentNode.Attributes.SetNamedItem(attrNode);
end; { SetNodeAttr }

procedure SetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  value: WideString);
begin
  SetNodeAttr(parentNode,attrName,value);
end; { SetNodeAttrStr }

procedure SetNodeAttrReal(parentNode: IXMLNode; attrName: string;
  value: real);
begin
  SetNodeAttr(parentNode,attrName,XMLRealToStr(value));
end; { SetNodeAttrReal }

procedure SetNodeAttrInt(parentNode: IXMLNode; attrName: string;
  value: integer);
begin
  SetNodeAttr(parentNode,attrName,XMLIntToStr(value));
end; { SetNodeAttrInt }

procedure SetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
  value: int64);
begin
  SetNodeAttr(parentNode,attrName,XMLInt64ToStr(value));
end; { SetNodeAttrInt64 }

procedure SetNodeAttrBool(parentNode: IXMLNode; attrName: string;
  value: boolean);
begin
  SetNodeAttr(parentNode,attrName,XMLBoolToStr(value));
end; { SetNodeAttrBool }

procedure SetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLDateTimeToStr(value));
end; { SetNodeAttrDateTime }

procedure SetNodeAttrDate(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLDateToStr(value));
end; { SetNodeAttrDate }

procedure SetNodeAttrTime(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLTimeToStr(value));
end; { SetNodeAttrTime }

{$IFNDEF USE_MSXML}
function InternalFilterNodes(parentNode: IXMLNode; matchesName,
  matchesText: string;
  matchOnGrandchildrenName, matchOnGrandchildrenText: boolean;
  matchesChildNames, matchesChildText: array of string): IXMLNodeList;
var
  childNode  : IXMLNode;
  grandNode  : IXMLNode;
  iGrandChild: integer;
  iNode      : integer;
  matches    : boolean;
begin
  Result := TXMLNodeList.Create;
  iNode := 0;
  while iNode < parentNode.ChildNodes.Length do begin
    childNode := parentNode.ChildNodes.Item[iNode];
    if childNode.NodeType = ELEMENT_NODE then begin
      matches := true;
      if matches and (matchesName <> '') then
        matches := (childNode.NodeName = matchesName);
      if matches and (matchesText <> '') then
        matches := (Trim(childNode.Text) = matchesText);
      if matches and matchOnGrandchildrenName then begin
        for iGrandChild := Low(matchesChildNames) to High(matchesChildNames) do
        begin
          grandNode := childNode.SelectSingleNode(matchesChildNames[iGrandChild]);
          if not assigned(grandNode) then begin
            matches := false;
            break; //for
          end
          else begin
            if matchOnGrandchildrenText and
               (iGrandChild >= Low(matchesChildText)) and
               (iGrandChild <= High(matchesChildText)) then
              matches := (Trim(grandNode.Text) = matchesChildText[iGrandChild]);
          end;
        end; //for
      end;
      if matches then
        Result.AddNode(parentNode.ChildNodes.Item[iNode]);
    end;
    Inc(iNode);
  end;
end; { InternalFilterNodes }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @param   matchesChildText  If not empty, grandchildren nodes text is checked.
                             For each grandchildren node named
                             matchesChildNames[], its text must equal
                             matchesChildText[]. Only if this condition is
                             satisfied, child node can be included in the result
                             list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-25
}
function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames, matchesChildText: array of string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    true, true, matchesChildNames, matchesChildText);
end; { FilterNodes }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-26
}
function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames: array of string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    true, false, matchesChildNames, ['']);
end; { FilterNodes }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-25
}
function FilterNodes(parentNode: IXMLNode; matchesName,
  matchesText: string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    false, false, [''], ['']);
end; { FilterNodes }
{$ENDIF USE_MSXML}

function InternalFindNode(parentNode: IXMLNode; matchesName,
  matchesText: string;
  matchOnGrandchildrenName, matchOnGrandchildrenText: boolean;
  matchesChildNames, matchesChildText: array of string): IXMLNode;
var
  childNode  : IXMLNode;
  grandNode  : IXMLNode;
  iGrandChild: integer;
  iNode      : integer;
  matches    : boolean;
begin
  Result := nil;
  iNode := 0;
  while iNode < parentNode.ChildNodes.Length do begin
    childNode := parentNode.ChildNodes.Item[iNode];
    if childNode.NodeType = ELEMENT_NODE then begin
      matches := true;
      if matches and (matchesName <> '') then
        matches := (childNode.NodeName = matchesName);
      if matches and (matchesText <> '') then
        matches := (Trim(childNode.Text) = matchesText);
      if matches and matchOnGrandchildrenName then begin
        for iGrandChild := Low(matchesChildNames) to High(matchesChildNames) do
        begin
          grandNode := childNode.SelectSingleNode(matchesChildNames[iGrandChild]);
          if not assigned(grandNode) then begin
            matches := false;
            break; //for
          end
          else begin
            if matchOnGrandchildrenText and
               (iGrandChild >= Low(matchesChildText)) and
               (iGrandChild <= High(matchesChildText)) then
              matches := (Trim(grandNode.Text) = matchesChildText[iGrandChild]);
          end;
        end; //for
      end;
      if matches then begin
        Result := parentNode.ChildNodes.Item[iNode];
        Exit;
      end;
    end;
    Inc(iNode);
  end;
end; { InternalFilterNodes }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @param   matchesChildText  If not empty, grandchildren nodes text is checked.
                             For each grandchildren node named
                             matchesChildNames[], its text must equal
                             matchesChildText[]. Only if this condition is
                             satisfied, child node can be included in the result
                             list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-25
}
function FindNode(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames, matchesChildText: array of string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    true, true, matchesChildNames, matchesChildText);
end; { FindNode }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-26
}
function FindNode(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames: array of string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    true, false, matchesChildNames, ['']);
end; { FindNode }

{:@param   paramNode         Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-25
}
function FindNode(parentNode: IXMLNode; matchesName,
  matchesText: string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    false, false, [''], ['']);
end; { FindNode }

{:@param   paramNode Parent node.
  @param   nodeTag   Tag of the child node.
  @since   2002-10-03
}        
function EnsureNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;
begin
  // TODO 1 -oPrimoz Gabrijelcic: Testing - remove when done
  if IsDocument(parentNode) and (assigned(DocumentElement(parentNode))) then begin
    parentNode := DocumentElement(parentNode);
    if parentNode.NodeName = nodeTag then begin
      Result := parentNode;
      Exit;
    end;
  end;
  Result := parentNode.SelectSingleNode(nodeTag);
  if not assigned(Result) then begin
    Result := OwnerDocument(parentNode).CreateElement(nodeTag);
    parentNode.AppendChild(Result);
  end;
end; { EnsureNode }

{:@param   resourceName Name of the RCDATA resource.
  @returns XML document interface or nil if error occured during load.
  @since   2001-09-25
}
function XMLLoadFromResource(xmlDocument: IXMLDocument;
  const resourceName: string): boolean;
var
  rstr: TResourceStream;
begin
  rstr := TResourceStream.Create(HInstance,resourceName,RT_RCDATA);
  try
    Result := XMLLoadFromStream(xmlDocument, rstr);
  finally FreeAndNil(rstr); end;
end; { XMLLoadFromResource }

{:@param   xmlDocument XML document.
  @param   xmlData     XML document, stored in the string.
  @returns True if xmlData was successfully parsed and loaded into the
           xmlDocument.
  @since   2001-09-26
}
function XMLLoadFromString(xmlDocument: IXMLDocument;
  const xmlData: WideString): boolean;
begin
  Result := xmlDocument.LoadXML(xmlData);
end; { XMLLoadFromString }

{:@param   xmlDocument  XML document.
  @param   outputFormat XML document formatting.
  @returns Contents of the XML document, stored in the string.
  @since   2001-09-26
}
function XMLSaveToString(xmlDocument: IXMLDocument;
  outputFormat: TOutputFormat = ofNone): WideString;
{$IFNDEF USE_MSXML}
var
  str: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  str := TStringStream.Create('');
  try
    XMLSaveToStream(xmlDocument, str, outputFormat);
    Result := str.DataString;
  finally FreeAndNil(str); end;
{$ELSE}
  Result := xmlDocument.XML;
{$ENDIF USE_MSXML}
end; { XMLSaveToString }

{:@param   xmlDocument XML document.
  @param   xmlStream   Stream containing XML document.
  @returns True if xmlData was successfully parsed and loaded into the
           xmlDocument.
  @since   2001-10-24
}
function XMLLoadFromStream(xmlDocument: IXMLDocument;
  const xmlStream: TStream): boolean;
{$IFDEF USE_MSXML}
var
  sstr: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  Result := xmlDocument.LoadFromStream(xmlStream);
{$ELSE}
  sstr := TStringStream.Create('');
  try
    sstr.CopyFrom(xmlStream,0);
    Result := XMLLoadFromString(xmlDocument, sstr.DataString);
  finally FreeAndNil(sstr); end;
{$ENDIF USE_MSXML}
end; { XMLLoadFromStream }

{:@param   xmlDocument XML document.
  @param   xmlStream   Stream that will receive the XML document.
  @param   outputFormat XML document formatting.
  @since   2001-10-24
}
procedure XMLSaveToStream(xmlDocument: IXMLDocument;
  const xmlStream: TStream; outputFormat: TOutputFormat = ofNone);
{$IFDEF USE_MSXML}
var
  sstr: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  xmlDocument.SaveToStream(xmlStream, outputFormat);
{$ELSE}
  sstr := TStringStream.Create(XMLSaveToString(xmlDocument, outputFormat));
  try
    xmlStream.CopyFrom(sstr, 0);
  finally FreeAndNil(sstr); end;
{$ENDIF USE_MSXML}
end; { XMLSaveToStream }

{:@param   xmlDocument XML document.
  @param   xmlFileName Name of the file containing XML document.
  @returns True if contents of file were successfully parsed and loaded into the
           xmlDocument.
  @since   2001-10-24
}
function XMLLoadFromFile(xmlDocument: IXMLDocument;
  const xmlFileName: string): boolean;
begin
  Result := xmlDocument.Load(xmlFileName);
end; { XMLLoadFromFile }

{:@param   xmlDocument  XML document.
  @param   xmlFileName  Name of the file containing XML document.
  @param   outputFormat XML document formatting.
  @since   2001-10-24
}
procedure XMLSaveToFile(xmlDocument: IXMLDocument;
  const xmlFileName: string; outputFormat: TOutputFormat = ofNone);
begin
{$IFNDEF USE_MSXML}
  xmlDocument.Save(xmlFileName, outputFormat);
{$ELSE}
  xmlDocument.Save(xmlFileName);
{$ENDIF USE_MSXML}
end; { XMLSaveToFile }

{:@param   xmlDocument XML document.
  @param   rootKey     Root registry key.
  @param   key         Registry key.
  @param   value       Registry value containing the string representation of
                       the XML document.
  @returns True if contents of file were successfully parsed and loaded into the
           xmlDocument.
  @since   2003-01-06
}        
function XMLLoadFromRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
  const key, value: string): boolean;
var
  reg: TRegistry;
begin
  Result := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := rootKey;
    if reg.OpenKeyReadonly(key) then try
      if reg.ValueExists(value) then begin
        try
          Result := XMLLoadFromString(xmlDocument, reg.ReadString(value));
        except end;
      end;
    finally reg.CloseKey; end;
  finally FreeAndNil(reg); end;
end; { XMLLoadFromRegistry }

{:@param   xmlDocument XML document.
  @param   rootKey     Root registry key.
  @param   key         Registry key.
  @param   value       Registry value to contain the string representation of
                       the XML document.
  @returns False if document cannot be saved. 
  @param   outputFormat XML document formatting.
  @since   2003-01-06
}        
function XMLSaveToRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
  const key, value: string; outputFormat: TOutputFormat): boolean;
var
  reg    : TRegistry;
  xmlData: string;
begin
  Result := false;
  xmlData := XMLSaveToString(xmlDocument);
  reg := TRegistry.Create;
  try
    reg.RootKey := rootKey;
    if reg.OpenKey(key,true) then try
      try
        reg.WriteString(value, xmlData);
        Result := true;
      except end;
    finally reg.CloseKey; end;
  finally FreeAndNil(reg); end;
end; { XMLSaveToRegistry }

{:@param   documentTag Tag for the document element.
  @param   nodeTags    Tags for nodes to be set.
  @param   nodeValues  Node values, corresponding 1:1 to the nodeTags.
  @since   2002-11-05
}
function ConstructXMLDocument(const documentTag: string;
  const nodeTags, nodeValues: array of string): IXMLDocument;
var
  iNode   : integer;
  rootNode: IXMLNode;
begin
  if Length(nodeTags) <> Length(nodeValues) then
    raise Exception.Create('ConstructXMLDocument: tags and values arrays are of different length!');
  Result := CreateXMLDoc;
  rootNode := EnsureNode(Result, documentTag);
  for iNode := Low(nodeTags) to High(nodeTags) do
    SetNodeText(rootNode, nodeTags[iNode], nodeValues[iNode]);
end; { ConstructXMLDocument }

{:@param   documentTag Tag for the document element.
  @since   2002-11-05
}
function ConstructXMLDocument(const documentTag: string): IXMLDocument; overload;
begin
  Result := CreateXMLDoc;
  EnsureNode(Result, documentTag);
end; { ConstructXMLDocument }

{:@param   sourceNode   Source of the copy operation.
  @param   targetNode   Target of the copy operation. Already existing child
                        nodes will be cleared.
  @param   copySubnodes If true (default), subnodes will be copied too.
  @param   filterProc   If assigned, filtering procedure that can prevent a
                        (child) node from being copied to the target node.
  @since   2002-12-26
}
procedure CopyNode(sourceNode, targetNode: IXMLNode; copySubnodes: boolean;
  filterProc: TFilterXMLNodeEvent);
var
  alreadyDeleted: TStringList;
  attrib        : IXMLNode;
  doCopy        : boolean;
  iAttrib       : integer;
  iNode         : integer;
  sourceChild   : IXMLNode;
  targetChild   : IXMLNode;
  targetElement : IXMLElement;
begin
  if targetNode.NodeType = ELEMENT_NODE then begin
    while targetNode.Attributes.Length > 0 do
      targetNode.Attributes.RemoveNamedItem(targetNode.Attributes.Item[0].NodeName);
    if sourceNode.NodeType = ELEMENT_NODE then begin
      targetElement := (targetNode as IXMLElement);
      for iAttrib := 0 to sourceNode.Attributes.Length-1 do begin
        attrib := sourceNode.Attributes.Item[iAttrib];
        targetElement.SetAttribute(attrib.NodeName, (attrib as IXMLAttr).Value);
      end;
    end;
  end;
  alreadyDeleted := TStringList.Create;
  try
    for iNode := 0 to sourceNode.ChildNodes.Length-1 do begin
      sourceChild := sourceNode.ChildNodes.Item[iNode];
      if sourceChild.NodeType = TEXT_NODE then begin
        targetChild := targetNode.AppendChild(
          OwnerDocument(targetNode).CreateTextNode(sourceChild.Text));
      end
      else begin
        doCopy := true;
        if assigned(filterProc) then
          filterProc(sourceChild, doCopy);
        if doCopy then begin
          if alreadyDeleted.IndexOf(sourceChild.NodeName) < 0 then begin
            DeleteAllChildren(targetNode, sourceChild.NodeName);
            alreadyDeleted.Add(sourceChild.NodeName);
          end;
          targetChild := targetNode.AppendChild(
            OwnerDocument(targetNode).CreateElement(sourceChild.NodeName));
          if copySubnodes then
            CopyNode(sourceChild, targetChild, copySubnodes, filterProc);
        end;
      end;
    end;
  finally FreeAndNil(alreadyDeleted); end;
end; { CopyNode }

{:@param   sourceDoc  Source XML document.
  @param   filterProc If assigned, filtering procedure that can prevent a node
                      from being copied to the target document.
  @returns New XML document.
  @since   2003-01-06
}        
function CloneDocument(sourceDoc: IXMLDocument;
  filterProc: TFilterXMLNodeEvent): IXMLDocument;
begin
  Result := CreateXMLDoc;
  if assigned(DocumentElement(sourceDoc)) then begin
    EnsureNode(Result, DocumentElement(sourceDoc).NodeName);
    CopyNode(DocumentElement(sourceDoc), DocumentElement(Result), true,
      filterProc);
  end;
end; { CloneDocument }

end.
