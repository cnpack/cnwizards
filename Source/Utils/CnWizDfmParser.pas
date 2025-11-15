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

unit CnWizDfmParser;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：分析 DFM 文件信息
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 7.1
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2012.09.19 by shenloqi
*               移植到 Delphi XE3
*           2005.03.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnCommon, CnTree,
{$IFDEF COMPILER6_UP}
  Variants, RTLConsts,
{$ELSE}
  Consts,
{$ENDIF}
  TypInfo;

type
  TDfmFormat = (dfUnknown, dfText, dfBinary);
  TDfmKind = (dkObject, dkInherited, dkInline);

  TDfmInfo = class(TPersistent)
  private
    FFormat: TDfmFormat;
    FKind: TDfmKind;
    FName: string;
    FFormClass: string;
    FCaption: string;
    FLeft: Integer;
    FTop: Integer;
    FWidth: Integer;
    FHeight: Integer;
  published
    property Top: Integer read FTop write FTop;
    property Width: Integer read FWidth write FWidth;
    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Kind: TDfmKind read FKind write FKind;
    property Height: Integer read FHeight write FHeight;
    property Format: TDfmFormat read FFormat write FFormat;
    property FormClass: string read FFormClass write FFormClass;
    property Caption: string read FCaption write FCaption;
  end;

  TCnDfmTree = class;

  TCnDfmLeaf = class(TCnLeaf)
  {* 代表 DFM 中的一个组件}
  private
    FElementClass: string;
    FElementKind: TDfmKind;
    FProperties: TStrings;
    function GetItems(Index: Integer): TCnDfmLeaf;
    procedure SetItems(Index: Integer; const Value: TCnDfmLeaf);
    function GetTree: TCnDfmTree;
    function GetPropertyValue(const PropertyName: string): string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(ATree: TCnTree); override;
    {* 构造方法 }
    destructor Destroy; override;
    {* 析构方法 }

    procedure AppendToStrings(List: TStrings; Tab: Integer = 0);
    {* 将自身名字、类名以及属性内容写入一个字符串列表，供保存用，不写末尾的 end}

    property Items[Index: Integer]: TCnDfmLeaf read GetItems write SetItems; default;
    property Tree: TCnDfmTree read GetTree;

    // 注意：解析过程中，用父类的 Text 属性当作 Name
    property ElementClass: string read FElementClass write FElementClass;
    {* ClassName 类名}
    property ElementKind: TDfmKind read FElementKind write FElementKind;
    {* 元素类型}
    property Properties: TStrings read FProperties;
    {* 存储文本属性，格式为 PropName = PropValue，对于复杂属性，PropValue 里可能包含回车
      注意 Objects 属性里可能存 TMemoryStream 的二进制数据}
    property PropertyValue[const PropertyName: string]: string read GetPropertyValue;
    {* 根据某属性名拿到属性值，如果是字符串，会带 DFM 中的单引号与转码，注意不支持多行属性}
  end;

  TCnDfmTree = class(TCnTree)
  {* 代表 DFM 树，其中 Root 的第一个子节点是根容器，不代表实际组件}
  private
    FDfmFormat: TDfmFormat;
    FDfmKind: TDfmKind;
    function GetRoot: TCnDfmLeaf;
    function GetItems(AbsoluteIndex: Integer): TCnDfmLeaf;
  protected
    procedure SaveLeafToStrings(Leaf: TCnDfmLeaf; List: TStrings; Tab: Integer = 0);
  public
    constructor Create;
    destructor Destroy; override;

    function SaveToStrings(List: TStrings): Boolean;
    function GetSameClassIndex(Leaf: TCnDfmLeaf): Integer;
    {* 在和该 Leaf 的 ElementClass 相同的 Leaf 中找该 Leaf 的 Index，0 开始}

    property Root: TCnDfmLeaf read GetRoot;
    property Items[AbsoluteIndex: Integer]: TCnDfmLeaf read GetItems;

    property DfmKind: TDfmKind read FDfmKind write FDfmKind;
    property DfmFormat: TDfmFormat read FDfmFormat write FDfmFormat;
  end;

const
  SDfmFormats: array[TDfmFormat] of string = ('Unknown', 'Text', 'Binary');
  SDfmKinds: array[TDfmKind] of string = ('Object', 'Inherited', 'Inline');

function ParseDfmStream(Stream: TStream; Info: TDfmInfo): Boolean;
{* 简单解析 DFM 流读出最外层 Container 的信息}

function ParseDfmFile(const FileName: string; Info: TDfmInfo): Boolean;
{* 简单解析 DFM 文件读出最外层 Container 的信息}

function LoadMultiTextStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
{* 将字符串流解析成树，允许多次调用以应对剪贴板内那种无根的多个组件
  注意 Stream 内的内容需要是 AnsiString，因为 TParser 没法处理 UTF16 流}

function LoadDfmStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
{* 将 DFM 流解析成树}

function LoadDfmFileToTree(const FileName: string; Tree: TCnDfmTree): Boolean;
{* 将 DFM 文件解析成树}

function SaveTreeToDfmFile(const FileName: string; Tree: TCnDfmTree): Boolean;
{* 将树的内容存成 DFM 文本文件}

function SaveTreeToStrings(const List: TStrings; Tree: TCnDfmTree): Boolean;
{* 将树的内容存成字符串列表}

function ConvertWideStringToDfmString(const W: WideString): WideString;
{* 将宽字符串转换为 Delphi 7 或以上版本中的 DFM 字符串}

function ConvertStreamToHexDfmString(Stream: TStream; Tab: Integer = 2): string;
{* 将二进制数据转换为 DFM 字符串，不带前后大括号}

function DecodeDfmStr(const QuotedStr: string): string;
{* 把 Caption 里那种带引号的转码后的字符转换为正常字符串}

implementation

const
  csPropCount = 5;
  csTabWidth = 2;
  CRLF = #13#10;
  FILER_SIGNATURE: array[1..4] of AnsiChar = ('T', 'P', 'F', '0');

{$IFNDEF COMPILER6_UP}
function CombineString(Parser: TParser): string;
begin
  Result := Parser.TokenString;
  while Parser.NextToken = '+' do
  begin
    Parser.NextToken;
    Parser.CheckToken(toString);
    Result := Result + Parser.TokenString;
  end;
end;
{$ENDIF}

function ConvertStreamToHexDfmString(Stream: TStream; Tab: Integer): string;
const
  BYTES_PER_LINE = 32;
var
  I, Count: Integer;
  MultiLine: Boolean;
  Buffer: array[0..BYTES_PER_LINE - 1] of AnsiChar;
  Text: array[0..BYTES_PER_LINE * 2 - 1] of Char;
begin
  Result := '';
  Count := Stream.Size;
  MultiLine := Count >= BYTES_PER_LINE;
  if Tab < 0 then
    Tab := 0;

  while Count > 0 do
  begin
    if MultiLine then
      Result := Result + #13#10 + StringOfChar(' ', Tab);

    if Count >= BYTES_PER_LINE then
      I := BYTES_PER_LINE
    else
      I := Count;

    Stream.Read(Buffer, I);
    BinToHex(Buffer, Text, I);
    Result := Result + Copy(Text, 1, I * 2);
    Dec(Count, I);
  end;
end;

function ConvertWideStringToDfmString(const W: WideString): WideString;
const
  LINE_LENGTH = 1024;
var
  L, I, J, K: Integer;
  LineBreak: Boolean;
begin
  L := Length(W);

  if L = 0 then
    Result := ''''''
  else
  begin
    I := 1;
    if L > LINE_LENGTH then
      Result := Result + #13#10;
    K := I;
    repeat
      LineBreak := False;
      if (W[I] >= ' ') and (W[I] <> '''') and (Ord(W[I]) <= 127) then
      begin
        J := I;
        repeat
          Inc(I)
        until (I > L) or (W[I] < ' ') or (W[I] = '''') or
          ((I - K) >= LINE_LENGTH) or (Ord(W[I]) > 127);
        if ((I - K) >= LINE_LENGTH) then
          LineBreak := True;
        Result := Result + '''';
        while J < I do
        begin
          Result := Result + Char(W[J]);
          Inc(J);
        end;
        Result := Result + '''';
      end else
      begin
        Result := Result + '#' + IntToStr(Ord(W[I]));
        Inc(I);
        if ((I - K) >= LINE_LENGTH) then
          LineBreak := True;
      end;
      if LineBreak and (I <= L) then
      begin
        Result := Result + ' +' + #13#10;
        K := I;
      end;
    until I > L;
  end;
end;

function CombineWideString(Parser: TParser): WideString;
begin
  Result := Parser.TokenWideString;
  while Parser.NextToken = '+' do
  begin
    Parser.NextToken;
    if not CharInSet(Parser.Token, [toString, toWString]) then
      Parser.CheckToken(toString);
    Result := Result + Parser.TokenWideString;
  end;
end;

function ParseTextOrderModifier(Parser: TParser): Integer;
begin
  Result := -1;
  if Parser.Token = '[' then
  begin
    Parser.NextToken;
    Parser.CheckToken(toInteger);
    Result := Parser.TokenInt;
    Parser.NextToken;
    Parser.CheckToken(']');
    Parser.NextToken;
  end;
end;

function ParseTextPropertyValue(Parser: TParser; out BinStream: TObject): string; forward;

procedure ParseTextHeaderToLeaf(Parser: TParser; IsInherited, IsInline: Boolean;
  Leaf: TCnDfmLeaf); forward;

procedure ParseTextPropertyToLeaf(Parser: TParser; Leaf: TCnDfmLeaf);
var
  PropName: string;
  PropValue: string;
  Obj: TObject;
begin
  Parser.CheckToken(toSymbol);
  PropName := Parser.TokenString;
  Parser.NextToken;
  while Parser.Token = '.' do
  begin
    Parser.NextToken;
    Parser.CheckToken(toSymbol);
    PropName := PropName + '.' + Parser.TokenString;
    Parser.NextToken;
  end;

  Parser.CheckToken('=');
  Parser.NextToken;
  Obj := nil;
  PropValue := ParseTextPropertyValue(Parser, Obj);

  if Obj <> nil then
    Leaf.Properties.AddObject(PropName + ' = ' + PropValue, Obj)
  else
    Leaf.Properties.Add(PropName + ' = ' + PropValue);
end;

function ParseTextPropertyValue(Parser: TParser; out BinStream: TObject): string;
var
  Stream: TStream;
  QS: string;

  function GetQuotedStr: string;
  begin
{$IFDEF COMPILER6_UP}
    if CharInSet(Parser.Token, [toString, toWString]) then
    begin
      Result := CombineWideString(Parser);
      Result := ConvertWideStringToDfmString(Result);
    end;
{$ELSE}
    // 会有拼成一行的副作用，但可以先不管
    if Parser.Token = toString then
      Result := QuotedStr(CombineString(Parser))
    else if Parser.Token = toWString then
      Result := QuotedStr(CombineWideString(Parser));
{$ENDIF}
  end;

begin
  Result := '';
{$IFDEF COMPILER6_UP}
  if CharInSet(Parser.Token, [toString, toWString]) then
  begin
    Result := CombineWideString(Parser);
    Result := ConvertWideStringToDfmString(Result);
  end
{$ELSE}
  // 会有拼成一行的副作用，但可以先不管
  if Parser.Token = toString then
    Result := QuotedStr(CombineString(Parser))
  else if Parser.Token = toWString then
    Result := QuotedStr(CombineWideString(Parser))
{$ENDIF}
  else
  begin
    case Parser.Token of
      toSymbol:
        Result := Parser.TokenComponentIdent;
      toInteger:
        Result := IntToStr(Parser.TokenInt);
      toFloat:
        Result := FloatToStr(Parser.TokenFloat);
      '[':  // 集合
        begin
          Result := Parser.TokenString;
          Parser.NextToken;
          while Parser.Token <> ']' do
          begin
            if Parser.Token = ',' then
              Result := Result + Parser.TokenString + ' '
            else
              Result := Result + Parser.TokenString;
            Parser.NextToken;
          end;
          Result := Result + ']';
        end;
      '(':  // 字符串列表或 DesignSize 的整数列表，缩进由输出时控制，这里不放缩进
        begin
          Result := Parser.TokenString;
          Parser.NextToken;
          while Parser.Token <> ')' do
          begin
            QS := GetQuotedStr;
            if QS <> '' then
              Result := Result + #13#10 + '  ' + QS
            else
              Parser.NextToken; // GetQuotedStr 内部已经 NextToken 了，整数则先行忽略
          end;
          Result := Result + ')';
        end;
      '{':  // 二进制数据
        begin
          Result := Parser.TokenString;
          // Parser.NextToken; // 无需 NextToken，下面 HexToBinary 会做这一步

          Stream := TMemoryStream.Create;
          Parser.HexToBinary(Stream);
          Stream.Position := 0;
          Result := ConvertStreamToHexDfmString(Stream) + '}';

          BinStream := Stream; // 将存有二进制数据的流对象传出
        end;
      '<':  // TODO: Collection 的 Items 需要分割处理
        begin
          Result := Parser.TokenString;
          Parser.NextToken;
          while Parser.Token <> '>' do
          begin
            Result := Result + Parser.TokenString;
            Parser.NextToken;
          end;
          Result := Result + '>';
        end;
    else
      Parser.Error(SInvalidProperty);
    end;
    Parser.NextToken;
  end;
end;

// 递归解析 Object。进入调用时 Parser 停留在 object，Leaf 是个新建的
procedure ParseTextObjectToLeaf(Parser: TParser; Tree: TCnDfmTree; Leaf: TCnDfmLeaf);
var
  InheritedObject: Boolean;
  InlineObject: Boolean;
  Child: TCnDfmLeaf;
begin
  InheritedObject := False;
  InlineObject := False;
  if Parser.TokenSymbolIs('INHERITED') then
  begin
    InheritedObject := True;
    Leaf.ElementKind := dkInherited;
  end
  else if Parser.TokenSymbolIs('INLINE') then
  begin
    InlineObject := True;
    Leaf.ElementKind := dkInline;
  end
  else
  begin
    Parser.CheckTokenSymbol('OBJECT');
    Leaf.ElementKind := dkObject;
  end;

  Parser.NextToken;
  ParseTextHeaderToLeaf(Parser, InheritedObject, InlineObject, Leaf);

  while not Parser.TokenSymbolIs('END') and
    not Parser.TokenSymbolIs('OBJECT') and
    not Parser.TokenSymbolIs('INHERITED') and
    not Parser.TokenSymbolIs('INLINE') do
    ParseTextPropertyToLeaf(Parser, Leaf);

  while Parser.TokenSymbolIs('OBJECT') or
    Parser.TokenSymbolIs('INHERITED') or
    Parser.TokenSymbolIs('INLINE') do
  begin
    Child := Tree.AddChild(Leaf) as TCnDfmLeaf;
    ParseTextObjectToLeaf(Parser, Tree, Child);
  end;
  Parser.NextToken; // 过 end
end;

procedure ParseTextHeaderToLeaf(Parser: TParser; IsInherited, IsInline: Boolean; Leaf: TCnDfmLeaf);
begin
  Parser.CheckToken(toSymbol);
  Leaf.ElementClass := Parser.TokenString;
  Leaf.Text := '';
  if Parser.NextToken = ':' then
  begin
    Parser.NextToken;
    Parser.CheckToken(toSymbol);
    Leaf.Text := Leaf.ElementClass;
    Leaf.ElementClass := Parser.TokenString;
    Parser.NextToken;
  end;
  ParseTextOrderModifier(Parser);
end;

procedure ParseBinaryHeader(Reader: TReader; Leaf: TCnDfmLeaf);
var
  Flags: TFilerFlags;
  Position: Integer;
begin
  Reader.ReadPrefix(Flags, Position);
  Leaf.ElementClass := Reader.ReadStr;
  Leaf.Text := Reader.ReadStr;
  if Leaf.Text = '' then
    Leaf.Text := Leaf.ElementClass;
end;

procedure ParseBinaryObjectToLeaf(Reader: TReader; Tree: TCnDfmTree; Leaf: TCnDfmLeaf);
var
  Child: TCnDfmLeaf;
  PropName: string;
  PropValue: string;
  BinStream: TObject;
  Buffer: array of Byte;

  function ParseBinaryPropertyValue(Reader: TReader): string;
  var
    ValueType: TValueType;
    I, Size: Integer;
    W: WideString;
    S: string;
    Stream: TMemoryStream;
  begin
    Result := '';
    ValueType := Reader.NextValue;

    case ValueType of
      vaInt8, vaInt16, vaInt32:
        Result := IntToStr(Reader.ReadInteger);
      vaInt64:
        {$IFDEF COMPILER6_UP}
        Result := IntToStr(Reader.ReadInt64);
        {$ELSE}
        Result := IntToStr(Integer(Reader.ReadInt64));
        {$ENDIF}
      vaExtended:
        Result := FloatToStr(Reader.ReadFloat);
      vaSingle:
        Result := FloatToStr(Reader.ReadSingle);
      vaCurrency:
        Result := FloatToStr(Reader.ReadCurrency);
      vaDate:
        Result := FloatToStr(Reader.ReadDate);
      vaWString, vaUTF8String:
        begin
          W := Reader.ReadWideString;
          Result := ConvertWideStringToDfmString(W);
        end;
      vaString, vaLString:
        begin
          S := Reader.ReadString;
          Result := '''' + StringReplace(S, '''', '''''', [rfReplaceAll]) + '''';
        end;
      vaIdent, vaFalse, vaTrue, vaNil, vaNull:
        Result := Reader.ReadIdent;
      vaBinary:
        begin
          Size := Reader.ReadInteger;
          Stream := TMemoryStream.Create;
          try
            if Size > 0 then
            begin
              SetLength(Buffer, Size);
              Reader.Read(Buffer[0], Size);
              Stream.Write(Buffer[0], Size);
              Stream.Position := 0;
            end;
            Result := '{' + ConvertStreamToHexDfmString(Stream) + '}';
            BinStream := Stream; // Pass binary stream object
          except
            Stream.Free;
            raise;
          end;
        end;
      vaSet:
        begin
          Result := '[';
          Reader.ReadValue; // Skip Value Type
          while True do
          begin
            S := Reader.ReadStr;
            if S = '' then Break;
            if Result <> '[' then
              Result := Result + ', ';
            Result := Result + S;
          end;
          Result := Result + ']';
        end;
      vaCollection:
        begin
          Result := '<';
          Reader.ReadValue; // Skip Value Type
          while not Reader.EndOfList do
          begin
            Result := Result + 'item' + #13#10;
            // Read order modifier if present
            if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
            begin
              Reader.ReadInteger; // Skip order modifier for now
            end;

            // Read item properties
            while not Reader.EndOfList do
            begin
              PropName := Reader.ReadStr;
              PropValue := ParseBinaryPropertyValue(Reader);
              Result := Result + '  ' + PropName + ' = ' + PropValue + #13#10;
            end;
            Reader.ReadListEnd;
            Result := Result + 'end' + #13#10;
          end;
          Reader.ReadListEnd;
          Result := Result + '>';
        end;
      vaList:
        begin
          Result := '(' + #13#10;
          Reader.ReadValue;
          while not Reader.EndOfList do
          begin
            S := ParseBinaryPropertyValue(Reader);
            Result := Result + '  ' + S + #13#10;
          end;
          Reader.ReadListEnd;
          Result := Result + ')';
        end;
    else
      raise EReadError.CreateResFmt(@SInvalidPropertyType, [Ord(ValueType)]);
    end;
  end;

begin
  ParseBinaryHeader(Reader, Leaf);

  // Parse properties
  BinStream := nil;
  while not Reader.EndOfList do
  begin
    PropName := Reader.ReadStr;
    PropValue := ParseBinaryPropertyValue(Reader);

    if BinStream <> nil then
    begin
      Leaf.Properties.AddObject(PropName + ' = ' + PropValue, BinStream);
      BinStream := nil;
    end
    else
    begin
      Leaf.Properties.Add(PropName + ' = ' + PropValue);
    end;
  end;
  Reader.ReadListEnd; // End of properties list

  // Parse child objects
  while not Reader.EndOfList do
  begin
    Child := Tree.AddChild(Leaf) as TCnDfmLeaf;
    ParseBinaryObjectToLeaf(Reader, Tree, Child);
  end;
  Reader.ReadListEnd; // End of children list
end;

// 简单解析 Text 格式的 Dfm 拿到 Info
function ParseTextDfmStream(Stream: TStream; Info: TDfmInfo): Boolean;
var
  SaveSeparator: Char;
  Parser: TParser;
  PropCount: Integer;

  procedure ParseHeader(IsInherited, IsInline: Boolean);
  begin
    Parser.CheckToken(toSymbol);
    Info.FormClass := Parser.TokenString;
    Info.Name := '';
    if Parser.NextToken = ':' then
    begin
      Parser.NextToken;
      Parser.CheckToken(toSymbol);
      Info.Name := Info.FormClass;
      Info.FormClass := Parser.TokenString;
      Parser.NextToken;
    end;
    ParseTextOrderModifier(Parser);
  end;

  procedure ParseProperty(IsForm: Boolean); forward;

  function ParseValue: Variant;
  begin
    Result := Null;
  {$IFDEF COMPILER6_UP}
    if CharInSet(Parser.Token, [toString, toWString]) then
      Result := CombineWideString(Parser)
  {$ELSE}
    if Parser.Token = toString then
      Result := CombineString(Parser)
    else if Parser.Token = toWString then
      Result := CombineWideString(Parser)
  {$ENDIF}
    else
    begin
      case Parser.Token of
        toSymbol:
          Result := Parser.TokenComponentIdent;
        toInteger:
        {$IFDEF COMPILER6_UP}
          Result := Parser.TokenInt;
        {$ELSE}
          Result := Integer(Parser.TokenInt);
        {$ENDIF}
        toFloat:
          Result := Parser.TokenFloat;
        '[':
          begin
            Parser.NextToken;
            if Parser.Token <> ']' then
              while True do
              begin
                if Parser.Token <> toInteger then
                  Parser.CheckToken(toSymbol);
                if Parser.NextToken = ']' then Break;
                Parser.CheckToken(',');
                Parser.NextToken;
              end;
          end;
        '(':
          begin
            Parser.NextToken;
            while Parser.Token <> ')' do ParseValue;
          end;
        '{':
          Parser.HexToBinary(Stream);
        '<':
          begin
            Parser.NextToken;
            while Parser.Token <> '>' do
            begin
              Parser.CheckTokenSymbol('item');
              Parser.NextToken;
              ParseTextOrderModifier(Parser);
              while not Parser.TokenSymbolIs('end') do ParseProperty(False);
              Parser.NextToken;
            end;
          end;
      else
        Parser.Error(SInvalidProperty);
      end;
      Parser.NextToken;
    end;
  end;

  procedure ParseProperty(IsForm: Boolean);
  var
    PropName: string;
    PropValue: Variant;
  begin
    Parser.CheckToken(toSymbol);
    PropName := Parser.TokenString;
    Parser.NextToken;
    while Parser.Token = '.' do
    begin
      Parser.NextToken;
      Parser.CheckToken(toSymbol);
      PropName := PropName + '.' + Parser.TokenString;
      Parser.NextToken;
    end;

    Parser.CheckToken('=');
    Parser.NextToken;
    PropValue := ParseValue;

    if IsForm then
    begin
      Inc(PropCount);
      if SameText(PropName, 'Left') then
        Info.Left := PropValue
      else if SameText(PropName, 'Top') then
        Info.Top := PropValue
      else if SameText(PropName, 'Width') or SameText(PropName, 'ClientWidth') then
        Info.Width := PropValue
      else if SameText(PropName, 'Height') or SameText(PropName, 'ClientHeight') then
        Info.Height := PropValue
      else if SameText(PropName, 'Caption') then
        Info.Caption := PropValue
      else
        Dec(PropCount);
    end;
  end;

  procedure ParseObject;
  var
    InheritedObject: Boolean;
    InlineObject: Boolean;
  begin
    InheritedObject := False;
    InlineObject := False;
    if Parser.TokenSymbolIs('INHERITED') then
    begin
      InheritedObject := True;
      Info.Kind := dkInherited;
    end
    else if Parser.TokenSymbolIs('INLINE') then
    begin
      InlineObject := True;
      Info.Kind := dkInline;
    end
    else
    begin
      Parser.CheckTokenSymbol('OBJECT');
      Info.Kind := dkObject;
    end;
    Parser.NextToken;
    ParseHeader(InheritedObject, InlineObject);
    while (PropCount < csPropCount) and
      not Parser.TokenSymbolIs('END') and
      not Parser.TokenSymbolIs('OBJECT') and
      not Parser.TokenSymbolIs('INHERITED') and
      not Parser.TokenSymbolIs('INLINE') do
      ParseProperty(True);
  end;

begin
  try
    Parser := TParser.Create(Stream);
    SaveSeparator := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator;
    {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := '.';
    try
      PropCount := 0;
      ParseObject;
      Result := True;
    finally
      {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := SaveSeparator;
      Parser.Free;
    end;
  except
    Result := False;
  end;
end;

// 简单解析二进制格式的 Dfm 拿到 Info
function ParseBinaryDfmStream(Stream: TStream; Info: TDfmInfo): Boolean;
var
  SaveSeparator: Char;
  Reader: TReader;
  PropName: string;
  PropCount: Integer;

  procedure ParseHeader;
  var
    Flags: TFilerFlags;
    Position: Integer;
  begin
    Reader.ReadPrefix(Flags, Position);
    Info.FormClass := Reader.ReadStr;
    Info.Name := Reader.ReadStr;
    if Info.Name = '' then
      Info.Name := Info.FormClass;
  end;

  procedure ParseBinary;
  const
    BYTES_PER_LINE = 32;
  var
    I: Integer;
    Count: Longint;
    Buffer: array[0..BYTES_PER_LINE - 1] of Char;
  begin
    Reader.ReadValue;
    Reader.Read(Count, SizeOf(Count));
    while Count > 0 do
    begin
      if Count >= 32 then I := 32 else I := Count;
      Reader.Read(Buffer, I);
      Dec(Count, I);
    end;
  end;

  procedure ParseProperty(IsForm: Boolean); forward;

  function ParseValue: Variant;
  const
    LineLength = 64;
  var
    S: string;
  begin
    Result := Null;
    case Reader.NextValue of
      vaList:
        begin
          Reader.ReadValue;
          while not Reader.EndOfList do
            ParseValue;
          Reader.ReadListEnd;
        end;
      vaInt8, vaInt16, vaInt32:
        Result := Reader.ReadInteger;
      vaExtended:
        Result := Reader.ReadFloat;
      vaSingle:
        Result := Reader.ReadSingle;
      vaCurrency:
        Result := Reader.ReadCurrency;
      vaDate:
        Result := Reader.ReadDate;
      vaWString{$IFDEF COMPILER6_UP}, vaUTF8String{$ENDIF}:
        Result := Reader.ReadWideString;
      vaString, vaLString:
        Result := Reader.ReadString;
      vaIdent, vaFalse, vaTrue, vaNil, vaNull:
        Result := Reader.ReadIdent;
      vaBinary:
        ParseBinary;
      vaSet:
        begin
          Reader.ReadValue;
          while True do
          begin
            S := Reader.ReadStr;
            if S = '' then Break;
          end;
        end;
      vaCollection:
        begin
          Reader.ReadValue;
          while not Reader.EndOfList do
          begin
            if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
            begin
              ParseValue;
            end;
            Reader.CheckValue(vaList);
            while not Reader.EndOfList do ParseProperty(False);
            Reader.ReadListEnd;
          end;
          Reader.ReadListEnd;
        end;
      vaInt64:
      {$IFDEF COMPILER6_UP}
        Result := Reader.ReadInt64;
      {$ELSE}
        Result := Integer(Reader.ReadInt64);
      {$ENDIF}
    else
      raise EReadError.CreateResFmt(@sPropertyException,
        [Info.Name, DotSep, PropName, IntToStr(Ord(Reader.NextValue))]);
    end;
  end;

  procedure ParseProperty(IsForm: Boolean);
  var
    PropValue: Variant;
  begin
    PropName := Reader.ReadStr;
    PropValue := ParseValue;

    if IsForm then
    begin
      Inc(PropCount);
      if SameText(PropName, 'Left') then
        Info.Left := PropValue
      else if SameText(PropName, 'Top') then
        Info.Top := PropValue
      else if SameText(PropName, 'Width') then
        Info.Width := PropValue
      else if SameText(PropName, 'Height') then
        Info.Height := PropValue
      else if SameText(PropName, 'Caption') then
        Info.Caption := PropValue
      else
        Dec(PropCount);
    end;
  end;

  procedure ParseObject;
  begin
    ParseHeader;
    while (PropCount < csPropCount) and not Reader.EndOfList do
      ParseProperty(True);
  end;

begin
  try
    Reader := TReader.Create(Stream, 4096);
    SaveSeparator := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator;
    {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := '.';
    try
      PropCount := 0;
      Reader.ReadSignature;
      ParseObject;
      Result := True;
    finally
      {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := SaveSeparator;
      Reader.Free;
    end;
  except
    Result := False;
  end;
end;

function ParseDfmStream(Stream: TStream; Info: TDfmInfo): Boolean;
var
  Pos: Integer;
  Signature: Integer;
  BOM: array[1..3] of AnsiChar;
begin
  Pos := Stream.Position;
  Signature := 0;
  Stream.Read(Signature, SizeOf(Signature));
  Stream.Position := Pos;
  if AnsiChar(Signature) in ['o','O','i','I',' ',#13,#11,#9] then
  begin
    Info.Format := dfText;
    Result := ParseTextDfmStream(Stream, Info);
  end
  else
  begin
    Pos := Stream.Position;
    Signature := 0;
    Stream.Read(BOM, SizeOf(BOM));
    Stream.Position := Pos;

    if ((BOM[1] = #$FF) and (BOM[2] = #$FE)) or // UTF8/UTF 16
      ((BOM[1] = #$EF) and (BOM[2] = #$BB) and (BOM[3] = #$BF)) then
    begin
      Info.Format := dfText;
      Result := ParseTextDfmStream(Stream, Info); // Only ANSI yet
    end
    else
    begin
      Stream.ReadResHeader;
      Pos := Stream.Position;
      Signature := 0;
      Stream.Read(Signature, SizeOf(Signature));
      Stream.Position := Pos;
      if Signature = Integer(FILER_SIGNATURE) then
      begin
        Info.Format := dfBinary;
        Result := ParseBinaryDfmStream(Stream, Info);
      end
      else
      begin
        Info.Format := dfUnknown;
        Result := False;
      end;
    end;
  end;
end;

function ParseDfmFile(const FileName: string; Info: TDfmInfo): Boolean;
var
  Stream: TFileStream;
begin
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      Result := ParseDfmStream(Stream, Info);
    finally
      Stream.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadTextDfmStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
var
  SaveSeparator: Char;
  Parser: TParser;
  StartLeaf: TCnDfmLeaf;
begin
  Parser := TParser.Create(Stream);
  try
    SaveSeparator := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator;
    {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := '.';
    try
      StartLeaf := Tree.AddChild(Tree.Root) as TCnDfmLeaf;
      ParseTextObjectToLeaf(Parser, Tree, StartLeaf as TCnDfmLeaf);
      Result := True;
    finally
      {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := SaveSeparator;
      Parser.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadBinaryDfmStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
var
  Reader: TReader;
  SaveSeparator: Char;
  StartLeaf: TCnDfmLeaf;
begin
  try
    Reader := TReader.Create(Stream, 4096);
    SaveSeparator := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator;
    {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := '.';
    try
      Reader.ReadSignature;
      StartLeaf := Tree.AddChild(Tree.Root) as TCnDfmLeaf;
      ParseBinaryObjectToLeaf(Reader, Tree, StartLeaf);
      Result := True;
    finally
      {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := SaveSeparator;
      Reader.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadMultiTextStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
var
  Pos: Integer;
  Signature: Integer;
  SaveSeparator: Char;
  Parser: TParser;
  StartLeaf: TCnDfmLeaf;
begin
  Result := False;
  Pos := Stream.Position;
  Signature := 0;
  Stream.Read(Signature, SizeOf(Signature));
  Stream.Position := Pos;

  if AnsiChar(Signature) in ['o','O','i','I',' ',#13,#11,#9] then
  begin
    Tree.DfmFormat := dfText;
    SaveSeparator := {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator;
    {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := '.';

    Parser := TParser.Create(Stream);
    try
      while Parser.Token <> #0 do
      begin
        StartLeaf := Tree.AddChild(Tree.Root) as TCnDfmLeaf;
        try
          ParseTextObjectToLeaf(Parser, Tree, StartLeaf as TCnDfmLeaf);
        except
          // StartLeaf 解析失败，可能到尾巴了，要删掉
          StartLeaf.Delete;
          Result := Tree.Count > 1;
          Exit;
        end;
      end;
      Result := True;
    finally
      {$IFDEF DELPHIXE3_UP}FormatSettings.{$ENDIF}DecimalSeparator := SaveSeparator;
      Parser.Free;
    end;
  end;
end;

function LoadDfmStreamToTree(Stream: TStream; Tree: TCnDfmTree): Boolean;
var
  Pos: Integer;
  Signature: Integer;
  BOM: array[1..3] of AnsiChar;
begin
  Result := False;
  Pos := Stream.Position;
  Signature := 0;
  Stream.Read(Signature, SizeOf(Signature));
  Stream.Position := Pos;

  if AnsiChar(Signature) in ['o','O','i','I',' ',#13,#11,#9] then
  begin
    Tree.DfmFormat := dfText;
    Result := LoadTextDfmStreamToTree(Stream, Tree);
  end
  else
  begin
    Pos := Stream.Position;
    Signature := 0;
    Stream.Read(BOM, SizeOf(BOM));
    Stream.Position := Pos;

    if ((BOM[1] = #$FF) and (BOM[2] = #$FE)) or // UTF8/UTF 16
      ((BOM[1] = #$EF) and (BOM[2] = #$BB) and (BOM[3] = #$BF)) then
    begin
      Tree.DfmFormat := dfText;
      Result := LoadTextDfmStreamToTree(Stream, Tree); // Only ANSI yet
    end
    else
    begin
      try
        Stream.ReadResHeader;
      except
        Exit; // 如果内容异常就退出
      end;

      Pos := Stream.Position;
      Signature := 0;
      Stream.Read(Signature, SizeOf(Signature));
      Stream.Position := Pos;
      if Signature = Integer(FILER_SIGNATURE) then
      begin
        Tree.DfmFormat := dfBinary;
        Result := LoadBinaryDfmStreamToTree(Stream, Tree);
      end
      else
      begin
        Tree.DfmFormat := dfUnknown;
        Result := False;
      end;
    end;
  end;
end;

function LoadDfmFileToTree(const FileName: string; Tree: TCnDfmTree): Boolean;
var
  Stream: TFileStream;
begin
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      Result := LoadDfmStreamToTree(Stream, Tree);
    finally
      Stream.Free;
    end;
  except
    Result := False;
  end;
end;

function SaveTreeToStrings(const List: TStrings; Tree: TCnDfmTree): Boolean;
begin
  Result := Tree.SaveToStrings(List);
end;

function SaveTreeToDfmFile(const FileName: string; Tree: TCnDfmTree): Boolean;
var
  List: TStrings;
begin
  Result := False;
  if (FileName <> '') and (Tree <> nil) then
  begin
    List := TStringList.Create;
    try
      Result := Tree.SaveToStrings(List);
      List.SaveToFile(FileName);
    finally
      List.Free;
    end;
  end;
end;

function DecodeDfmStr(const QuotedStr: string): string;
var
  Stream: TMemoryStream;
  Parser: TParser;
  Reparse: Boolean;
{$IFDEF UNICODE}
  A: AnsiString;
{$ENDIF}
begin
  Result := QuotedStr;
  if QuotedStr = '' then
    Exit;

  Reparse := True;
  if Pos('#', Result) > 0 then
  begin
    Stream := nil;
    Parser := nil;

    try
      // 通过 Parser 处理掉 #12345 这种 Unicode 转义字符
      Stream := TMemoryStream.Create;
  {$IFDEF UNICODE}  // Parser 只接受 AnsiString 内容
      A := AnsiString(QuotedStr);
      Stream.Write(A[1], Length(A));
  {$ELSE}
      Stream.Write(QuotedStr[1], Length(QuotedStr));
  {$ENDIF}
      Stream.Position := 0;

      Parser := TParser.Create(Stream);
      Parser.NextToken;

      Result := string(Parser.TokenWideString);

      Reparse := Result = ''; // # 如果解析成功，则 Reparse 设为 False，无需重解析
    finally
      Parser.Free;
      Stream.Free;
    end;
  end;

  // 以上经过 Parser，如果原始内容有 #，则会解析通过，大概已经没引号了
  // 但如果原始内容没 #，会解析出空字符串，相当于失败了，重新手工去引号
  if Reparse then
  begin
    Result := QuotedStr;
    if Length(Result) > 1 then
    begin
      if Result[1] = '''' then // 删头引号
        Delete(Result, 1, 1)
      else
        Exit;

      if Length(Result) > 0 then
      begin
        if Result[Length(Result)] = '''' then // 删尾引号
          Delete(Result, Length(Result), 1)
        else
          Exit;

        Result := StringReplace(Result, '''''', '''', [rfReplaceAll]); // 双引号替换成单引号
      end;
    end;
  end;
end;

{ TCnDfmTree }

constructor TCnDfmTree.Create;
begin
  inherited Create(TCnDfmLeaf);
end;

destructor TCnDfmTree.Destroy;
begin

  inherited;
end;

function TCnDfmTree.GetItems(AbsoluteIndex: Integer): TCnDfmLeaf;
begin
  Result := TCnDfmLeaf(inherited GetItems(AbsoluteIndex));
end;

function TCnDfmTree.GetRoot: TCnDfmLeaf;
begin
  Result := TCnDfmLeaf(inherited GetRoot);
end;

function TCnDfmTree.GetSameClassIndex(Leaf: TCnDfmLeaf): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Leaf.Tree <> Self then
    Exit;

  for I := 0 to Count - 1 do
  begin
    if Items[I].ElementClass = Leaf.ElementClass then
      Inc(Result);
    if Items[I] = Leaf then
      Exit;
  end;
end;

procedure TCnDfmTree.SaveLeafToStrings(Leaf: TCnDfmLeaf; List: TStrings;
  Tab: Integer);
var
  I: Integer;
begin
  if (Leaf <> nil) and (Leaf.ElementClass <> '') then
  begin
    Leaf.AppendToStrings(List, Tab);
    for I := 0 to Leaf.Count - 1 do
      SaveLeafToStrings(Leaf.Items[I], List, Tab + csTabWidth);

    List.Append(Spc(Tab) + 'end');
  end;
end;

function TCnDfmTree.SaveToStrings(List: TStrings): Boolean;
begin
  Result := False;
  if List <> nil then
  begin
    List.Clear;
    // Root 本身不存
    if Root.Count = 1 then
      SaveLeafToStrings(Root.Items[0], List, 0);
  end;
end;

{ TCnDfmLeaf }

procedure TCnDfmLeaf.AppendToStrings(List: TStrings; Tab: Integer);
var
  I, P: Integer;
  S, N, V: string;
begin
  if Tab < 0 then
    Tab := 0;

  if List <> nil then
  begin
    List.Add(Format('%s%s %s: %s', [Spc(Tab), LowerCase(SDfmKinds[FElementKind]), Text, FElementClass]));
    for I := 0 to FProperties.Count - 1 do
    begin
      S := FProperties[I];
      P := Pos(' = ', S);
      if P > 0 then
      begin
        N := Copy(S, 1, P - 1);
        V := Copy(S, P + 3, MaxInt);
        // 在 V 的每个回车后面加上 Tab + csTabWidth 个空格以示缩进
        V := StringReplace(V, #13#10, #13#10 + Spc(Tab + csTabWidth), [rfReplaceAll]);
        if (N <> '') and (V <> '') then
          List.Add(Format('%s%s = %s', [Spc(Tab + csTabWidth), N, V]));
      end;
    end;
  end;
end;

procedure TCnDfmLeaf.AssignTo(Dest: TPersistent);
var
  I: Integer;
  SourceStream, DestStream: TMemoryStream;
begin
  if Dest is TCnDfmLeaf then
  begin
    TCnDfmLeaf(Dest).ElementKind := FElementKind;
    TCnDfmLeaf(Dest).ElementClass := FElementClass;
    TCnDfmLeaf(Dest).Properties.Assign(FProperties);

    for I := 0 to FProperties.Count - 1 do
    begin
      SourceStream := TMemoryStream(FProperties.Objects[I]);
      if SourceStream <> nil then
      begin
        // 复制二进制内存流
        DestStream := TMemoryStream.Create;
        DestStream.LoadFromStream(SourceStream);
        TCnDfmLeaf(Dest).Properties.Objects[I] := DestStream;
      end;
    end;
  end;
  inherited;
end;

constructor TCnDfmLeaf.Create(ATree: TCnTree);
begin
  inherited;
  FProperties := TStringList.Create;
end;

destructor TCnDfmLeaf.Destroy;
var
  I: Integer;
begin
  for I := 0 to FProperties.Count - 1 do
    if FProperties.Objects[I] <> nil then
      FProperties.Objects[I].Free;
  FProperties.Free;
  inherited;
end;

function TCnDfmLeaf.GetItems(Index: Integer): TCnDfmLeaf;
begin
  Result := TCnDfmLeaf(inherited GetItems(Index));
end;

function TCnDfmLeaf.GetPropertyValue(const PropertyName: string): string;
var
  I, D: Integer;
begin
  Result := '';
  for I := 0 to FProperties.Count - 1 do
  begin
    D := Pos('=', FProperties[I]);
    if D > 1 then
    begin
      if PropertyName = Trim(Copy(FProperties[I], 1, D - 1)) then
      begin
        Result := Trim(Copy(FProperties[I], D + 1, MaxInt));
        Exit;
      end;
    end;
  end;
end;

function TCnDfmLeaf.GetTree: TCnDfmTree;
begin
  Result := TCnDfmTree(inherited Tree);
end;

procedure TCnDfmLeaf.SetItems(Index: Integer; const Value: TCnDfmLeaf);
begin
  inherited SetItems(Index, Value);
end;

end.
