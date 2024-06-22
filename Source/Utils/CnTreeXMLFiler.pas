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

unit CnTreeXMLFiler;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnTree 流化接口 XML 实现单元
* 单元作者：LiuXiao (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2004.11.04 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, SysUtils, Controls, TypInfo, {$IFDEF COMPILER6_UP}Variants,{$ENDIF}
  CnCommon, CnTree, OmniXMLPersistent, OmniXML,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLUtils;

type
  TCnTreeXMLFiler = class(TInterfacedObject, ICnTreeFiler)
  private
    FXMLDoc: IXMLDocument;
    FRoot: IXMLElement;
    FPropsFormat: TPropsFormat;

    function FindElement(const Root: IXMLElement; const TagName: string): IXMLElement;
    procedure ReadProperties(Instance: TPersistent; Element: IXMLElement);
    procedure ReadProperty(Instance: TPersistent; PropInfo: Pointer; Element: IXMLElement);
    function InternalReadText(Root: IXMLElement; Name: string; var Value: WideString): Boolean;
    procedure Read(Instance: TPersistent; Root: IXMLElement);

    procedure WriteProperties(Instance: TPersistent; Element: IXMLElement);
    procedure WriteProperty(Instance: TPersistent; PropInfo: PPropInfo; Element: IXMLElement);
    procedure InternalWriteText(Root: IXMLElement; Name, Value: string);
    procedure Write(Instance: TPersistent; Root: IXMLElement);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(Instance: TPersistent; const FileName: string);
    procedure SaveToFile(Instance: TPersistent; const FileName: string);
  end;

implementation

const
  CNLEAF_NODENAME = 'CnLeaf';
  PROP_FORMAT = 'PropFormat';

var
  PropFormatValues: array[TPropsFormat] of string = ('auto', 'attr', 'node');

procedure CreateDocument(var XMLDoc: IXMLDocument; var Root: IXMLElement; RootNodeName: string);
begin
  XMLDoc := CreateXMLDoc;
  Root := XMLDoc.CreateElement(RootNodeName);
  XMLDoc.DocumentElement := Root;
end;

procedure Load(var XMLDoc: IXMLDocument; var XMLRoot: IXMLElement; var PropsFormat: TPropsFormat);
var
  I: TPropsFormat;
  PropFormatValue: string;
begin
  // set root element
  XMLRoot := XMLDoc.documentElement;
  PropsFormat := pfNodes;

  if XMLRoot = nil then
    Exit;

  PropFormatValue := XMLRoot.GetAttribute(PROP_FORMAT);

  for I := Low(TPropsFormat) to High(TPropsFormat) do begin
    if SameText(PropFormatValue, PropFormatValues[I]) then begin
      PropsFormat := I;
      Break;
    end;
  end;
end;

procedure LoadDocument(const FileName: string; var XMLDoc: IXMLDocument; var XMLRoot: IXMLElement; var PropsFormat: TPropsFormat);
begin
  XMLDoc := CreateXMLDoc;

  XMLDoc.preserveWhiteSpace := True;
  XMLDoc.Load(FileName);

  Load(XMLDoc, XMLRoot, PropsFormat);
end;

{ TCnTreeXMLFiler }

constructor TCnTreeXMLFiler.Create;
begin
  inherited;
end;

destructor TCnTreeXMLFiler.Destroy;
begin
  FXMLDoc := nil;
  FRoot := nil;
  inherited;
end;

function TCnTreeXMLFiler.FindElement(const Root: IXMLElement;
  const TagName: string): IXMLElement;
var
  I: Integer;
begin
  Result := nil;
  if Root = nil then
    Exit;
  I := 0;
  while (Result = nil) and (I < Root.ChildNodes.Length) do
  begin
    if (Root.ChildNodes.Item[I].NodeType = ELEMENT_NODE)
      and (CompareText(Root.ChildNodes.Item[I].NodeName, TagName) = 0) then
      Result := Root.ChildNodes.Item[I] as IXMLElement
    else
      Inc(I);
  end;
end;

function TCnTreeXMLFiler.InternalReadText(Root: IXMLElement; Name: string;
  var Value: WideString): Boolean;
var
  PropNode: IXMLElement;
  AttrNode: IXMLNode;
begin
  case FPropsFormat of
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

procedure TCnTreeXMLFiler.InternalWriteText(Root: IXMLElement; Name,
  Value: string);
var
  PropNode: IXMLElement;
begin
  PropNode := FXMLDoc.CreateElement(Name);
  PropNode.Text := Value;
  Root.appendChild(PropNode);
end;

procedure TCnTreeXMLFiler.LoadFromFile(Instance: TPersistent;
  const FileName: string);
begin
  FXMLDoc := nil;
  FRoot := nil;

  if Instance is TCnTree then
  begin
    LoadDocument(FileName, FXMLDoc, FRoot, FPropsFormat);
    Read(Instance, FRoot);

    FXMLDoc := nil;
    FRoot := nil;
  end;
end;

procedure TCnTreeXMLFiler.Read(Instance: TPersistent; Root: IXMLElement);
var
  I: Integer;
  ALeaf: TCnLeaf;
  ATree: TCnTree;
begin
  if Instance is TCnTree then
  begin
    Root := FindElement(Root, Instance.ClassName);
    if Root = nil then
      Exit;
    // 读 Tree 本身
    (Instance as TCnTree).Clear;
    ReadProperties(Instance, Root);
    // 递归，从根节点读起
    Root := FindElement(Root, CNLEAF_NODENAME);
    if Root <> nil then
      Read((Instance as TCnTree).Root, Root);
  end
  else if Instance is TCnLeaf then
  begin
    // 读节点本身
    ReadProperties(Instance, Root);

    // 递归读下属子节点
    ATree := (Instance as TCnLeaf).Tree;
    for I := 0 to Root.ChildNodes.Length - 1 do
    begin
      if Root.ChildNodes.Item[I].NodeType = ELEMENT_NODE then
      begin
        if Root.ChildNodes.Item[I].NodeName = CNLEAF_NODENAME then
        begin
          ALeaf := ATree.AddChild(Instance as TCnLeaf);
          Read(ALeaf, Root.ChildNodes.Item[I] as IXMLElement);
        end;
      end;
    end;
  end;
end;

procedure TCnTreeXMLFiler.ReadProperties(Instance: TPersistent;
  Element: IXMLElement);
var
  I: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
begin
  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount > 0 then begin
    GetMem(PropList, PropCount * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for I := 0 to PropCount - 1 do begin
        PropInfo := PropList^[I];
        if PropInfo = nil then
          Break;
        ReadProperty(Instance, PropInfo, Element);
      end;
    finally
      FreeMem(PropList, PropCount * SizeOf(Pointer));
    end;
  end;
end;

procedure TCnTreeXMLFiler.ReadProperty(Instance: TPersistent;
  PropInfo: Pointer; Element: IXMLElement);
var
  PropType: PTypeInfo;

  procedure ReadFloatProp;
  var
    Value: Extended;
    Text: WideString;
  begin
    if InternalReadText(Element, PropInfoName(PropInfo), Text) then
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
    if InternalReadText(Element, PropInfoName(PropInfo), Text) then begin
      if XMLStrToDateTime(Text, Value) then
        SetFloatProp(Instance, PropInfo, Value)
      else
        raise EOmniXMLPersistent.CreateFmt('Error in datetime property %s', [PropInfoName(PropInfo)]);
    end
    else
      raise EOmniXMLPersistent.CreateFmt('Missing datetime property %s', [PropInfoName(PropInfo)]);
  end;

  procedure ReadStrProp;
  var
    Value: WideString;
  begin
    if InternalReadText(Element, PropInfoName(PropInfo), Value) then
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
    if InternalReadText(Element, PropInfoName(PropInfo), Value) then begin
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
              if XMLStrToInt(Value, IntValue) then
                SetOrdProp(Instance, PropInfo, IntValue)
              else
                SetEnumProp(Instance, PropInfo, Value);
          end;
      end;
    end
    else
      SetOrdProp(Instance, PropInfo, PPropInfo(PropInfo)^.Default)
  end;

  procedure ReadInt64Prop;
  var
    Value: WideString;
    IntValue: Int64;
  begin
    if InternalReadText(Element, PropInfoName(PropInfo), Value) then begin
      if XMLStrToInt64(Value, IntValue) then
        SetInt64Prop(Instance, PropInfo, IntValue)
      else
        raise EOmniXMLPersistent.CreateFmt('Invalid int64 value (%s).', [Value]);
    end
    else
      SetFloatProp(Instance, PropInfo, 0)
  end;

begin
  if (PPropInfo(PropInfo)^.SetProc <> nil)
    and (PPropInfo(PropInfo)^.GetProc <> nil) then
  begin
    PropType := PPropInfo(PropInfo)^.PropType^;
    case PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet: ReadOrdProp;
      tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}: ReadStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or (PropType = System.TypeInfo(TTime)) or (PropType = System.TypeInfo(TDate)) then
          ReadDateTimeProp
        else
          ReadFloatProp;
      tkInt64: ReadInt64Prop;
    end;
  end;
end;

procedure TCnTreeXMLFiler.SaveToFile(Instance: TPersistent;
  const FileName: string);
begin
  FXMLDoc := nil;
  FRoot := nil;

  if Instance is TCnTree then
  begin
    CreateDocument(FXMLDoc, FRoot, 'data');
    FXMLDoc.DocumentElement.SetAttribute(PROP_FORMAT, PropFormatValues[pfNodes]);

    Write(Instance, FRoot);
    FXMLDoc.Save(FileName, ofIndent);

    FXMLDoc := nil;
    FRoot := nil;
  end;
end;

procedure TCnTreeXMLFiler.Write(Instance: TPersistent; Root: IXMLElement);
var
  I: Integer;
  Element, ChildElement: IXMLElement;
begin
  if Instance is TCnTree then
  begin
    // 写 CnTree 本身
    Element := FXMLDoc.CreateElement(Instance.ClassName);
    WriteProperties(Instance, Element);
    // 递归写根节点
    ChildElement := FXMLDoc.CreateElement(CNLEAF_NODENAME);
    Write((Instance as TCnTree).Root, ChildElement);
    Element.AppendChild(ChildElement);

    Root.AppendChild(Element);
  end
  else if Instance is TCnLeaf then
  begin
    // 写节点本身
    WriteProperties(Instance, Root);

    // 递归写节点的直属子节点
    for I := 0 to (Instance as TCnLeaf).Count - 1 do
    begin
      ChildElement := FXMLDoc.CreateElement(CNLEAF_NODENAME);
      Write((Instance as TCnLeaf).Items[I], ChildElement);
      Root.AppendChild(ChildElement);
    end;
  end;
end;

procedure TCnTreeXMLFiler.WriteProperties(Instance: TPersistent;
  Element: IXMLElement);
var
  I: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
begin
  if (Instance <> nil) and (Element <> nil) then
  begin
    PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
    if PropCount > 0 then
    begin
      GetMem(PropList, PropCount * SizeOf(Pointer));
      try
        GetPropInfos(Instance.ClassInfo, PropList);
        for I := 0 to PropCount - 1 do
        begin
          PropInfo := PropList^[I];
          if PropInfo = nil then
            Break;
          if IsStoredProp(Instance, PropInfo) then
            WriteProperty(Instance, PropInfo, Element)
        end;
      finally
        FreeMem(PropList, PropCount * SizeOf(Pointer));
      end;
    end;
  end;
end;

procedure TCnTreeXMLFiler.WriteProperty(Instance: TPersistent;
  PropInfo: PPropInfo; Element: IXMLElement);
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
    if Value <> PropInfo^.Default then begin
      case PropType^.Kind of
        tkInteger: InternalWriteText(Element, PropInfoName(PropInfo), XMLIntToStr(Value));
        tkChar: InternalWriteText(Element, PropInfoName(PropInfo), Chr(Value));
        tkSet: InternalWriteText(Element, PropInfoName(PropInfo), GetSetProp(Instance, PropInfo, True));
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

begin
  if (PropInfo^.SetProc <> nil) and
    (PropInfo^.GetProc <> nil) then
  begin
    PropType := PropInfo^.PropType^;
    case PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet: WriteOrdProp;
      tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}: WriteStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or
         (PropType = System.TypeInfo(TTime)) or (PropType = System.TypeInfo(TDate)) then
          WriteDateTimeProp
        else
          WriteFloatProp;
      tkInt64: WriteInt64Prop;
      // 省事，不处理 Class 类型的了
    end;
  end;
end;

end.
