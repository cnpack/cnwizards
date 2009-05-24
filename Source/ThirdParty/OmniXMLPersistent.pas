(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is mr_Storage_XML.pas                                      *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec,                    *
*   http://www.MihaRemec.com/                                                  *
*                                                                              *
* History:                                                                     *
*   2000-11-21: initial release                                                *
*   2001-01-03: code cleanup                                                   *
*   2001-06-26: changed date & time formats for ISO 8601 compatibility         *
*   2001-11-01: adapted for use with OmniXMLUtils                              *
*               introduced EOmniXMLPersistent                                  *
*               some bug fixes                                                 *
*   2003-05-27: added more support for tkEnumeration variables                 *
*******************************************************************************)
unit OmniXMLPersistent;

interface

{$I CnWizards.inc}

// if you want to use MS XML parser, uncomment (in your program!!!)
// the following compiler directive {.$DEFINE USE_MSXML}

uses
  Classes, SysUtils, Controls, TypInfo,
{$IFDEF COMPILER6_UP}
  Variants,
{$ENDIF}
  OmniXML,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLUtils;

type
  TPropsFormat = (pfAuto, pfAttributes, pfNodes);
  EOmniXMLPersistent = class(Exception);

type
  TOmniXMLWriter = class
  protected
    Doc: IXMLDocument;
    procedure WriteProperty(Instance: TPersistent; PropInfo: PPropInfo; Element: IXMLElement);
    procedure InternalWriteText(Root: IXMLElement; Name, Value: string);
    procedure Write(Instance: TPersistent; Root: IXMLElement; const WriteRoot: Boolean = True; const CheckIfEmpty: Boolean = True);
    procedure WriteCollection(Collection: TCollection; Root: IXMLElement);
  public
    PropsFormat: TPropsFormat;
    constructor Create(Doc: IXMLDocument; const PropFormat: TPropsFormat = pfAuto);
    class procedure SaveToFile(const Instance: TPersistent; const FileName: string; const PropFormat: TPropsFormat = pfAuto; const OutputFormat: TOutputFormat = ofNone);
    class procedure SaveXML(const Instance: TPersistent; var XML: WideString; const PropFormat: TPropsFormat = pfAuto; const OutputFormat: TOutputFormat = ofNone);
  end;

  TOmniXMLReader = class
  protected
    function FindElement(const Root: IXMLElement; const TagName: string): IXMLElement;
    procedure ReadProperty(Instance: TPersistent; PropInfo: Pointer; Element: IXMLElement);
    function InternalReadText(Root: IXMLElement; Name: string; var Value: WideString): Boolean;
    procedure Read(Instance: TPersistent; Root: IXMLElement; const ReadRoot: Boolean = False);
    procedure ReadCollection(Collection: TCollection; Root: IXMLElement);
  public
    PropsFormat: TPropsFormat;
    constructor Create(const PropFormat: TPropsFormat = pfAuto);
    class procedure LoadFromFile(Instance: TPersistent; FileName: string); overload;
    class procedure LoadFromFile(Collection: TCollection; FileName: string); overload;
    class procedure LoadXML(Instance: TPersistent; const XML: WideString); overload;
  end;

var
  DefaultPropFormat: TPropsFormat = pfNodes;

implementation

const
  COLLECTIONITEM_NODENAME = 'o';  // do not change!
  PROP_FORMAT = 'PropFormat';

var
  PropFormatValues: array[TPropsFormat] of string = ('auto', 'attr', 'node');

function PropInfoName(PropInfo: PPropInfo): string;
begin
  Result := string(PropInfo^.Name);
end;

function IsElementEmpty(Element: IXMLElement; PropsFormat: TPropsFormat): Boolean;
begin
  Result := ((PropsFormat = pfAttributes) and (Element.Attributes.Length = 0)) or
    ((PropsFormat = pfNodes) and (Element.ChildNodes.Length = 0));
end;

procedure CreateDocument(var XMLDoc: IXMLDocument; var Root: IXMLElement; RootNodeName: string);
begin
  XMLDoc := CreateXMLDoc;
  Root := XMLDoc.CreateElement(RootNodeName);
  XMLDoc.DocumentElement := Root;
end;

procedure Load(var XMLDoc: IXMLDocument; var XMLRoot: IXMLElement; var PropsFormat: TPropsFormat);
var
  i: TPropsFormat;
  PropFormatValue: string;
begin
  // set root element
  XMLRoot := XMLDoc.documentElement;
  PropsFormat := pfNodes;

  if XMLRoot = nil then
    Exit;

  PropFormatValue := XMLRoot.GetAttribute(PROP_FORMAT);

  for i := Low(TPropsFormat) to High(TPropsFormat) do begin
    if SameText(PropFormatValue, PropFormatValues[i]) then begin
      PropsFormat := i;
      Break;
    end;
  end;
end;

procedure LoadDocument(const FileName: string; var XMLDoc: IXMLDocument; var XMLRoot: IXMLElement; var PropsFormat: TPropsFormat);
begin
  XMLDoc := CreateXMLDoc;
  { TODO : implement and test preserveWhiteSpace }
  XMLDoc.preserveWhiteSpace := True;
  XMLDoc.Load(FileName);

  Load(XMLDoc, XMLRoot, PropsFormat);
end;

{ TOmniXMLWriter }

class procedure TOmniXMLWriter.SaveToFile(const Instance: TPersistent; const FileName: string; const PropFormat: TPropsFormat = pfAuto; const OutputFormat: TOutputFormat = ofNone);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Writer: TOmniXMLWriter;
begin
  if Instance is TCollection then
    CreateDocument(XMLDoc, Root, Instance.ClassName)
  else
    CreateDocument(XMLDoc, Root, 'data');

  Writer := TOmniXMLWriter.Create(XMLDoc, PropFormat);
  try
    if Instance is TCollection then
      Writer.WriteCollection(TCollection(Instance), Root)
    else
      Writer.Write(Instance, Root);
  finally
    Writer.Free;
  end;

{$IFNDEF USE_MSXML}
  XMLDoc.Save(FileName, OutputFormat);
{$ELSE}
  XMLDoc.Save(FileName);
{$ENDIF}
end;

class procedure TOmniXMLWriter.SaveXML(const Instance: TPersistent;
  var XML: WideString; const PropFormat: TPropsFormat;
  const OutputFormat: TOutputFormat);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Writer: TOmniXMLWriter;
begin
  if Instance is TCollection then
    CreateDocument(XMLDoc, Root, Instance.ClassName)
  else
    CreateDocument(XMLDoc, Root, 'data');

  Writer := TOmniXMLWriter.Create(XMLDoc, PropFormat);
  try
    if Instance is TCollection then
      Writer.WriteCollection(TCollection(Instance), Root)
    else
      Writer.Write(Instance, Root);
  finally
    Writer.Free;
  end;

  XML := XMLDoc.XML;
end;

constructor TOmniXMLWriter.Create(Doc: IXMLDocument; const PropFormat: TPropsFormat = pfAuto);
begin
  Self.Doc := Doc;
  if PropFormat <> pfAuto then
    PropsFormat := PropFormat
  else
    PropsFormat := DefaultPropFormat;
  Doc.DocumentElement.SetAttribute(PROP_FORMAT, PropFormatValues[PropsFormat]);
end;

procedure TOmniXMLWriter.InternalWriteText(Root: IXMLElement; Name, Value: string);
var
  PropNode: IXMLElement;
begin
  case PropsFormat of
    pfAttributes: Root.SetAttribute(Name, Value);
    pfNodes:
      begin
        PropNode := Doc.CreateElement(Name);
        PropNode.Text := Value;
        Root.appendChild(PropNode);
      end;
  end;
end;

procedure TOmniXMLWriter.WriteCollection(Collection: TCollection; Root: IXMLElement);
var
  i: Integer;
begin
  for i := 0 to Collection.Count - 1 do
    Write(Collection.Items[i], Root, True, False);
end;

procedure TOmniXMLWriter.WriteProperty(Instance: TPersistent; PropInfo: PPropInfo; Element: IXMLElement);
var
  PropType: PTypeInfo;

  procedure WriteStrProp;
  var
    Value: string;
  begin
    Value := GetStrProp(Instance, PropInfo);
    if Value <> '' then
      InternalWriteText(Element, PropInfoName(PropInfo), Value);
  end;

  procedure WriteOrdProp;
  var
    Value: Longint;
  begin
    Value := GetOrdProp(Instance, PropInfo);
    if Value <> PPropInfo(PropInfo)^.Default then begin
      case PropType^.Kind of
        tkInteger: InternalWriteText(Element, PropInfoName(PropInfo), XMLIntToStr(Value));
        tkChar: InternalWriteText(Element, PropInfoName(PropInfo), Chr(Value));
        tkSet: InternalWriteText(Element, PropInfoName(PropInfo), GetSetProp(Instance, PPropInfo(PropInfo), True));
        tkEnumeration:
          begin
            if PropType = System.TypeInfo(Boolean) then
              InternalWriteText(Element, PropInfoName(PropInfo), XMLBoolToStr(Boolean(Value)))
            else if PropType^.Kind = tkInteger then
              InternalWriteText(Element, PropInfoName(PropInfo), XMLIntToStr(Value))
            // 2003-05-27 (mr): added tkEnumeration processing
            else if PropType^.Kind = tkEnumeration then
              InternalWriteText(Element, PropInfoName(PropInfo), GetEnumName(PropType, Value));
          end;
      end;
    end;
  end;

  procedure WriteFloatProp;
  var
    Value: Real;
  begin
    Value := GetFloatProp(Instance, PropInfo);
    if Value <> 0 then
      InternalWriteText(Element, PropInfoName(PropInfo), XMLRealToStr(Value));
  end;

  procedure WriteDateTimeProp;
  var
    Value: TDateTime;
  begin
    Value := VarAsType(GetFloatProp(Instance, PropInfo), varDate);
    if Value <> 0 then
      InternalWriteText(Element, PropInfoName(PropInfo), XMLDateTimeToStrEx(Value));
  end;

  procedure WriteInt64Prop;
  var
    Value: Int64;
  begin
    Value := GetInt64Prop(Instance, PropInfo);
    if Value <> 0 then
      InternalWriteText(Element, PropInfoName(PropInfo), XMLInt64ToStr(Value));
  end;

  procedure WriteObjectProp;
  var
    Value: TObject;
    PropNode: IXMLElement;
  begin
    Value := TObject(GetOrdProp(Instance, PropInfo));
    if Value <> nil then begin
      PropNode := Doc.CreateElement(PropInfoName(PropInfo));

      if Value is TCollection then begin
        WriteCollection(TCollection(Value), PropNode);
        if not IsElementEmpty(PropNode, pfNodes) then
          Element.appendChild(PropNode);
      end
      else begin
        if Value is TPersistent then begin
          Write(TPersistent(Value), PropNode, False);
          if not IsElementEmpty(PropNode, PropsFormat) then
            Element.appendChild(PropNode);
        end;
      end;
    end;
  end;

begin
  if (PPropInfo(PropInfo)^.SetProc <> nil) and (PPropInfo(PropInfo)^.GetProc <> nil) then begin
    PropType := PPropInfo(PropInfo)^.PropType^;
    case PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet: WriteOrdProp;
      tkString, tkLString, tkWString{$IFDEF UNICODE_STRING}, tkUString{$ENDIF}: WriteStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or (PropType = System.TypeInfo(TTime)) or (PropType = System.TypeInfo(TDate)) then
          WriteDateTimeProp
        else
          WriteFloatProp;
      tkInt64: WriteInt64Prop;
      tkClass: WriteObjectProp;
    end;
  end;
end;

procedure TOmniXMLWriter.Write(Instance: TPersistent; Root: IXMLElement; const WriteRoot: Boolean; const CheckIfEmpty: Boolean);
var
  PropCount: Integer;
  PropList: PPropList;
  i: Integer;
  PropInfo: PPropInfo;
  Element: IXMLElement;
begin
  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount = 0 then
    Exit;

  if Instance is TCollectionItem then
    Element := Doc.CreateElement(COLLECTIONITEM_NODENAME)
  else if WriteRoot then
    Element := Doc.CreateElement(Instance.ClassName)
  else
    Element := Root;

  GetMem(PropList, PropCount * SizeOf(Pointer));
  try
    GetPropInfos(Instance.ClassInfo, PropList);
    for i := 0 to PropCount - 1 do begin
      PropInfo := PropList^[I];
      if PropInfo = nil then
        Break;
      if IsStoredProp(Instance, PropInfo) then
        WriteProperty(Instance, PropInfo, Element)
    end;
  finally
    FreeMem(PropList, PropCount * SizeOf(Pointer));
  end;

  if WriteRoot then begin
    if CheckIfEmpty and IsElementEmpty(Element, PropsFormat) then
      Exit
    else begin
      if Root <> nil then
        Root.appendChild(Element)
      else
        Doc.documentElement := Element;
    end;
  end;
end;

{ TOmniXMLReader }

class procedure TOmniXMLReader.LoadXML(Instance: TPersistent; const XML: WideString);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  XMLDoc := CreateXMLDoc;
  { TODO : implement and test preserveWhiteSpace }
  XMLDoc.preserveWhiteSpace := True;
  XMLDoc.LoadXML(XML);

  Load(XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    if Instance is TCollection then
      Reader.ReadCollection(TCollection(Instance), XMLRoot)
    else
      Reader.Read(Instance, XMLRoot, True);
  finally
    Reader.Free;
  end;
end;

class procedure TOmniXMLReader.LoadFromFile(Instance: TPersistent; FileName: string);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  // read document
  LoadDocument(FileName, XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    if Instance is TCollection then
      Reader.ReadCollection(TCollection(Instance), XMLRoot)
    else
      Reader.Read(Instance, XMLRoot, True);
  finally
    Reader.Free;
  end;
end;

class procedure TOmniXMLReader.LoadFromFile(Collection: TCollection; FileName: string);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  // read document
  LoadDocument(FileName, XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    Reader.ReadCollection(Collection, XMLRoot);
  finally
    Reader.Free;
  end;
end;

constructor TOmniXMLReader.Create(const PropFormat: TPropsFormat = pfAuto);
begin
  if PropFormat = pfAuto then
    raise EOmniXMLPersistent.Create('Auto PropFormat not allowed here.');

  PropsFormat := PropFormat;
end;

function TOmniXMLReader.FindElement(const Root: IXMLElement; const TagName: string): IXMLElement;
var
  i: Integer;
begin
  Result := nil;
  if Root = nil then
    Exit;
  i := 0;
  while (Result = nil) and (i < Root.ChildNodes.Length) do begin
    if (Root.ChildNodes.Item[i].NodeType = ELEMENT_NODE) and (CompareText(Root.ChildNodes.Item[i].NodeName, TagName) = 0) then
      Result := Root.ChildNodes.Item[i] as IXMLElement
    else
      Inc(i);
  end;
end;

function TOmniXMLReader.InternalReadText(Root: IXMLElement; Name: string; var Value: WideString): Boolean;
var
  PropNode: IXMLElement;
  AttrNode: IXMLNode;
begin
  case PropsFormat of
    pfAttributes:
      begin
        AttrNode := Root.Attributes.GetNamedItem(Name);
        Result := AttrNode <> nil;
        if Result then
          Value := AttrNode.NodeValue;
      end;
    pfNodes:
      begin
        PropNode := FindElement(Root, Name);
        Result := PropNode <> nil;
        if Result then
          Value := PropNode.Text;
      end;
    else
      Result := False;
  end;
end;

procedure TOmniXMLReader.ReadCollection(Collection: TCollection; Root: IXMLElement);
var
  i: Integer;
  Item: TCollectionItem;
begin
  Collection.Clear;
  if Root = nil then
    Exit;
  for i := 0 to Root.ChildNodes.Length - 1 do begin
    if Root.ChildNodes.Item[i].NodeType = ELEMENT_NODE then begin
      if Root.ChildNodes.Item[i].NodeName = COLLECTIONITEM_NODENAME then begin
        Item := Collection.Add;
        Read(Item, Root.ChildNodes.Item[i] as IXMLElement, False);
      end;
    end;
  end;
end;

procedure TOmniXMLReader.ReadProperty(Instance: TPersistent; PropInfo: Pointer; Element: IXMLElement);
var
  PropType: PTypeInfo;

  procedure ReadFloatProp;
  var
    Value: Extended;
    Text: WideString;
  begin
    if InternalReadText(Element, PropInfoName(PPropInfo(PropInfo)), Text) then
      Value := XMLStrToRealDef(Text, 0)
    else
      Value := 0;
    SetFloatProp(Instance, PropInfo, Value)
  end;

  procedure ReadDateTimeProp;
  var
    Value: TDateTime;
    Text: WideString;
  begin
    if InternalReadText(Element, PropInfoName(PPropInfo(PropInfo)), Text) then begin
      if XMLStrToDateTime(Text, Value) then
        SetFloatProp(Instance, PropInfo, Value)
      else
        raise EOmniXMLPersistent.CreateFmt('Error in datetime property %s', [PPropInfo(PropInfo)^.Name]);
    end
    else
      raise EOmniXMLPersistent.CreateFmt('Missing datetime property %s', [PPropInfo(PropInfo)^.Name]);
  end;

  procedure ReadStrProp;
  var
    Value: WideString;
  begin
    if InternalReadText(Element, PropInfoName(PPropInfo(PropInfo)), Value) then
      SetStrProp(Instance, PropInfo, Value)
    else
      SetStrProp(Instance, PropInfo, '');
  end;

  procedure ReadOrdProp;
  var
    Value: WideString;
    IntValue: Integer;
    BoolValue: Boolean;
  begin
    if InternalReadText(Element, PropInfoName(PPropInfo(PropInfo)), Value) then begin
      case PropType^.Kind of
        tkInteger:
          if XMLStrToInt(Value, IntValue) then
            SetOrdProp(Instance, PropInfo, XMLStrToIntDef(Value, 0))
          else
            raise EOmniXMLPersistent.CreateFmt('Invalid integer value (%s).', [Value]);
        tkChar: SetOrdProp(Instance, PropInfo, Ord(Value[1]));
        tkSet: SetSetProp(Instance, PropInfo, Value);
        tkEnumeration:
          begin
            if PropType = System.TypeInfo(Boolean) then begin
              if XMLStrToBool(Value, BoolValue) then
                SetOrdProp(Instance, PropInfo, Ord(BoolValue))
              else
                raise EOmniXMLPersistent.CreateFmt('Invalid boolean value (%s).', [Value]);
            end
            else if PropType^.Kind = tkInteger then begin
              if XMLStrToInt(Value, IntValue) then
                SetOrdProp(Instance, PropInfo, IntValue)
              else
                raise EOmniXMLPersistent.CreateFmt('Invalid enum value (%s).', [Value]);
            end
            // 2003-05-27 (mr): added tkEnumeration processing
            else if PropType^.Kind = tkEnumeration then
              SetEnumProp(Instance, PropInfo, Value);
          end;
      end;
    end
    else if IsStoredProp(Instance, PropInfo) then
      SetOrdProp(Instance, PropInfo, PPropInfo(PropInfo)^.Default)
  end;

  procedure ReadInt64Prop;
  var
    Value: WideString;
    IntValue: Int64;
  begin
    if InternalReadText(Element, PropInfoName(PPropInfo(PropInfo)), Value) then begin
      if XMLStrToInt64(Value, IntValue) then
        SetInt64Prop(Instance, PropInfo, IntValue)
      else
        raise EOmniXMLPersistent.CreateFmt('Invalid int64 value (%s).', [Value]);
    end
    else
      SetFloatProp(Instance, PropInfo, 0)
  end;

  procedure ReadObjectProp;
  var
    Value: TObject;
    PropNode: IXMLElement;
  begin
    Value := TObject(GetOrdProp(Instance, PropInfo));
    if Value <> nil then begin
      PropNode := FindElement(Element, PropInfoName(PPropInfo(PropInfo)));
      if Value is TCollection then
        ReadCollection(TCollection(Value), PropNode)
      else if Value is TPersistent then
        Read(TPersistent(Value), PropNode);
    end;
  end;

begin
  if (PPropInfo(PropInfo)^.SetProc <> nil) and (PPropInfo(PropInfo)^.GetProc <> nil) then begin
    PropType := PPropInfo(PropInfo)^.PropType^;
    case PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet: ReadOrdProp;
      tkString, tkLString, tkWString{$IFDEF UNICODE_STRING}, tkUString{$ENDIF}: ReadStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or (PropType = System.TypeInfo(TTime)) or (PropType = System.TypeInfo(TDate)) then
          ReadDateTimeProp
        else
          ReadFloatProp;
      tkInt64: ReadInt64Prop;
      tkClass: ReadObjectProp;
    end;
  end;
end;

procedure TOmniXMLReader.Read(Instance: TPersistent; Root: IXMLElement; const ReadRoot: Boolean);
var
  PropCount: Integer;
  PropList: PPropList;
  i: Integer;
  PropInfo: PPropInfo;
begin
  if ReadRoot then
    Root := FindElement(Root, Instance.ClassName);

  if Root = nil then
    Exit;

  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount > 0 then begin
    GetMem(PropList, PropCount * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for i := 0 to PropCount - 1 do begin
        PropInfo := PropList^[I];
        if PropInfo = nil then
          Break;
        ReadProperty(Instance, PropInfo, Root);
      end;
    finally
      FreeMem(PropList, PropCount * SizeOf(Pointer));
    end;
  end;
end;

end.
