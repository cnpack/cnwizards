(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXML.pas                                             *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec                     *
*   http://www.MihaRemec.com/                                                  *
*                                                                              *
* Last changed: 2003-02-24                                                     *
*                                                                              *
* History: see history.txt file                                                *
*                                                                              *
* Contributor(s):                                                              *
*   Primoz Gabrijelcic (gp)                                                    *
*******************************************************************************)
unit OmniXML;

interface

{$I CnWizards.inc}

uses
  Classes, SysUtils, GpTextStream;

const
  CP_UTF16 = CP_UNICODE;
  CP_UTF8 = 65001;  // UTF-8 translation

const
  HEADER_UTF16: WideChar = WideChar($FEFF);  // don't change!

const
  DEFAULT_DECIMALSEPARATOR  = '.';        // don't change!
  DEFAULT_TRUE              = '1';        // don't change!
  DEFAULT_FALSE             = '0';        // don't change!
  DEFAULT_DATETIMESEPARATOR = 'T';        // don't change!
  DEFAULT_DATESEPARATOR     = '-';        // don't change!
  DEFAULT_TIMESEPARATOR     = ':';        // don't change!
  DEFAULT_MSSEPARATOR       = '.';        // don't change!

const
  // element node
  ELEMENT_NODE = 1;
  // attribute node
  ATTRIBUTE_NODE = 2;
  // text node
  TEXT_NODE = 3;
  // CDATA section node
  CDATA_SECTION_NODE = 4;
  // entity reference node
  ENTITY_REFERENCE_NODE = 5;
  // entity node
  ENTITY_NODE = 6;
  // processing instruction node
  PROCESSING_INSTRUCTION_NODE = 7;
  // comment node
  COMMENT_NODE = 8;
  // document node
  DOCUMENT_NODE = 9;
  // document type node
  DOCUMENT_TYPE_NODE = 10;
  // document fragment node
  DOCUMENT_FRAGMENT_NODE = 11;
  // notation node
  NOTATION_NODE = 12;

type
  TNodeType = 1..12;

const
  // these codes are part of Exception codes
  // index or size is negative, or greater than the allowed value
  INDEX_SIZE_ERR = 1;
  // the specified range of text does not fit into a WideString
  XMLSTRING_SIZE_ERR = 2;
  // any node is inserted somewhere it doesn't belong
  HIERARCHY_REQUEST_ERR = 3;
  // a node is used in a different document than the one that created it (that doesn't support it)
  WRONG_DOCUMENT_ERR = 4;
  // an invalid character is specified, such as in a name
  INVALID_CHARACTER_ERR = 5;
  // data is specified for a node which does not support data
  NO_DATA_ALLOWED_ERR = 6;
  // an attempt is made to modify an object where modifications are not allowed
  NO_MODIFICATION_ALLOWED_ERR = 7;
  // an attempt was made to reference a node in a context where it does not exist
  NOT_FOUND_ERR = 8;
  // the implementation does not support the type of object requested
  NOT_SUPPORTED_ERR = 9;
  // an attempt is made to add an attribute that is already inuse elsewhere
  INUSE_ATTRIBUTE_ERR = 10;

const
  MSG_E_NOTEXT = $0000;
  MSG_E_BASE = $0001;
  MSG_E_FORMATINDEX_BADINDEX = MSG_E_BASE + 0;
  MSG_E_FORMATINDEX_BADFORMAT = MSG_E_BASE + 1;
  MSG_E_SYSTEM_ERROR = MSG_E_BASE + 2;
  MSG_E_MISSINGEQUALS = MSG_E_BASE + 3;
  MSG_E_EXPECTED_TOKEN = MSG_E_BASE + 4;
  MSG_E_UNEXPECTED_TOKEN = MSG_E_BASE + 5;
  MSG_E_MISSINGQUOTE = MSG_E_BASE + 6;
  MSG_E_COMMENTSYNTAX = MSG_E_BASE + 7;
  MSG_E_BADSTARTNAMECHAR = MSG_E_BASE + 8;
  MSG_E_BADNAMECHAR = MSG_E_BASE + 9;
  MSG_E_BADCHARINSTRING = MSG_E_BASE + 10;
  MSG_E_XMLDECLSYNTAX = MSG_E_BASE + 11;
  MSG_E_BADCHARDATA = MSG_E_BASE + 12;
  MSG_E_MISSINGWHITESPACE = MSG_E_BASE + 13;
  MSG_E_EXPECTINGTAGEND = MSG_E_BASE + 14;
  MSG_E_BADCHARINDTD = MSG_E_BASE + 15;
  MSG_E_BADCHARINDECL = MSG_E_BASE + 16;
  MSG_E_MISSINGSEMICOLON = MSG_E_BASE + 17;
  MSG_E_BADCHARINENTREF = MSG_E_BASE + 18;
  MSG_E_UNBALANCEDPAREN = MSG_E_BASE + 19;
  MSG_E_EXPECTINGOPENBRACKET = MSG_E_BASE + 20;
  MSG_E_BADENDCONDSECT = MSG_E_BASE + 21;
  MSG_E_INTERNALERROR = MSG_E_BASE + 22;
  MSG_E_UNEXPECTED_WHITESPACE = MSG_E_BASE + 23;
  MSG_E_INCOMPLETE_ENCODING = MSG_E_BASE + 24;
  MSG_E_BADCHARINMIXEDMODEL = MSG_E_BASE + 25;
  MSG_E_MISSING_STAR = MSG_E_BASE + 26;
  MSG_E_BADCHARINMODEL = MSG_E_BASE + 27;
  MSG_E_MISSING_PAREN = MSG_E_BASE + 28;
  MSG_E_BADCHARINENUMERATION = MSG_E_BASE + 29;
  MSG_E_PIDECLSYNTAX = MSG_E_BASE + 30;
  MSG_E_EXPECTINGCLOSEQUOTE = MSG_E_BASE + 31;
  MSG_E_MULTIPLE_COLONS = MSG_E_BASE + 32;
  MSG_E_INVALID_DECIMAL = MSG_E_BASE + 33;
  MSG_E_INVALID_HEXADECIMAL = MSG_E_BASE + 34;
  MSG_E_INVALID_UNICODE = MSG_E_BASE + 35;
  MSG_E_WHITESPACEORQUESTIONMARK = MSG_E_BASE + 36;
  MSG_E_SUSPENDED = MSG_E_BASE + 37;
  MSG_E_STOPPED = MSG_E_BASE + 38;
  MSG_E_UNEXPECTEDENDTAG = MSG_E_BASE + 39;
  MSG_E_UNCLOSEDTAG = MSG_E_BASE + 40;
  MSG_E_DUPLICATEATTRIBUTE = MSG_E_BASE + 41;
  MSG_E_MULTIPLEROOTS = MSG_E_BASE + 42;
  MSG_E_INVALIDATROOTLEVEL = MSG_E_BASE + 43;
  MSG_E_BADXMLDECL = MSG_E_BASE + 44;
  MSG_E_MISSINGROOT = MSG_E_BASE + 45;
  MSG_E_UNEXPECTEDEOF = MSG_E_BASE + 46;
  MSG_E_BADPEREFINSUBSET = MSG_E_BASE + 47;
  MSG_E_PE_NESTING = MSG_E_BASE + 48;
  MSG_E_INVALID_CDATACLOSINGTAG = MSG_E_BASE + 49;
  MSG_E_UNCLOSEDPI = MSG_E_BASE + 50;
  MSG_E_UNCLOSEDSTARTTAG = MSG_E_BASE + 51;
  MSG_E_UNCLOSEDENDTAG = MSG_E_BASE + 52;
  MSG_E_UNCLOSEDSTRING = MSG_E_BASE + 53;
  MSG_E_UNCLOSEDCOMMENT = MSG_E_BASE + 54;
  MSG_E_UNCLOSEDDECL = MSG_E_BASE + 55;
  MSG_E_UNCLOSEDMARKUPDECL = MSG_E_BASE + 56;
  MSG_E_UNCLOSEDCDATA = MSG_E_BASE + 57;
  MSG_E_BADDECLNAME = MSG_E_BASE + 58;
  MSG_E_BADEXTERNALID = MSG_E_BASE + 59;
  MSG_E_BADELEMENTINDTD = MSG_E_BASE + 60;
  MSG_E_RESERVEDNAMESPACE = MSG_E_BASE + 61;
  MSG_E_EXPECTING_VERSION = MSG_E_BASE + 62;
  MSG_E_EXPECTING_ENCODING = MSG_E_BASE + 63;
  MSG_E_EXPECTING_NAME = MSG_E_BASE + 64;
  MSG_E_UNEXPECTED_ATTRIBUTE = MSG_E_BASE + 65;
  MSG_E_ENDTAGMISMATCH = MSG_E_BASE + 66;
  MSG_E_INVALIDENCODING = MSG_E_BASE + 67;
  MSG_E_INVALIDSWITCH = MSG_E_BASE + 68;
  MSG_E_EXPECTING_NDATA = MSG_E_BASE + 69;
  MSG_E_INVALID_MODEL = MSG_E_BASE + 70;
  MSG_E_INVALID_TYPE = MSG_E_BASE + 71;
  MSG_E_INVALIDXMLSPACE = MSG_E_BASE + 72;
  MSG_E_MULTI_ATTR_VALUE = MSG_E_BASE + 73;
  MSG_E_INVALID_PRESENCE = MSG_E_BASE + 74;
  MSG_E_BADXMLCASE = MSG_E_BASE + 75;
  MSG_E_CONDSECTINSUBSET = MSG_E_BASE + 76;
  MSG_E_CDATAINVALID = MSG_E_BASE + 77;
  MSG_E_INVALID_STANDALONE = MSG_E_BASE + 78;
  MSG_E_UNEXPECTED_STANDALONE = MSG_E_BASE + 79;
  MSG_E_DOCTYPE_IN_DTD = MSG_E_BASE + 80;
  MSG_E_MISSING_ENTITY = MSG_E_BASE + 81;
  MSG_E_ENTITYREF_INNAME = MSG_E_BASE + 82;
  MSG_E_DOCTYPE_OUTSIDE_PROLOG = MSG_E_BASE + 83;
  MSG_E_INVALID_VERSION = MSG_E_BASE + 84;
  MSG_E_DTDELEMENT_OUTSIDE_DTD = MSG_E_BASE + 85;
  MSG_E_DUPLICATEDOCTYPE = MSG_E_BASE + 86;
  MSG_E_RESOURCE = MSG_E_BASE + 87;
  // 2003-02-22 (mr): added MSG_E_INVALID_OPERATION
  MSG_E_INVALID_OPERATION = MSG_E_BASE + 88;

  XML_BASE = MSG_E_BASE + 89;
  XML_IOERROR = XML_BASE + 0; 
  XML_ENTITY_UNDEFINED = XML_BASE + 1;
  XML_INFINITE_ENTITY_LOOP = XML_BASE + 2;
  XML_NDATA_INVALID_PE = XML_BASE + 3;
  XML_REQUIRED_NDATA = XML_BASE + 4;
  XML_NDATA_INVALID_REF = XML_BASE + 5;
  XML_EXTENT_IN_ATTR = XML_BASE + 6;
  XML_STOPPED_BY_USER = XML_BASE + 7;
  XML_PARSING_ENTITY = XML_BASE + 8;
  XML_E_MISSING_PE_ENTITY = XML_BASE + 9;
  XML_E_MIXEDCONTENT_DUP_NAME = XML_BASE + 10;
  XML_NAME_COLON = XML_BASE + 11;
  XML_ELEMENT_UNDECLARED = XML_BASE + 12;
  XML_ELEMENT_ID_NOT_FOUND = XML_BASE + 13;
  XML_DEFAULT_ATTRIBUTE = XML_BASE + 14;
  XML_XMLNS_RESERVED = XML_BASE + 15;
  XML_EMPTY_NOT_ALLOWED = XML_BASE + 16;
  XML_ELEMENT_NOT_COMPLETE = XML_BASE + 17;
  XML_ROOT_NAME_MISMATCH = XML_BASE + 18;
  XML_INVALID_CONTENT = XML_BASE + 19;
  XML_ATTRIBUTE_NOT_DEFINED = XML_BASE + 20;
  XML_ATTRIBUTE_FIXED = XML_BASE + 21;
  XML_ATTRIBUTE_VALUE = XML_BASE + 22;
  XML_ILLEGAL_TEXT = XML_BASE + 23;
  XML_MULTI_FIXED_VALUES = XML_BASE + 24;
  XML_NOTATION_DEFINED = XML_BASE + 25;
  XML_ELEMENT_DEFINED = XML_BASE + 26;
  XML_ELEMENT_UNDEFINED = XML_BASE + 27;
  XML_XMLNS_UNDEFINED = XML_BASE + 28;
  XML_XMLNS_FIXED = XML_BASE + 29;
  XML_E_UNKNOWNERROR = XML_BASE + 30;
  XML_REQUIRED_ATTRIBUTE_MISSING = XML_BASE + 31;
  XML_MISSING_NOTATION = XML_BASE + 32;
  XML_ATTLIST_DUPLICATED_ID = XML_BASE + 33;
  XML_ATTLIST_ID_PRESENCE = XML_BASE + 34;
  XML_XMLLANG_INVALIDID = XML_BASE + 35;
  XML_PUBLICID_INVALID = XML_BASE + 36;
  XML_DTD_EXPECTING = XML_BASE + 37;
  XML_NAMESPACE_URI_EMPTY = XML_BASE + 38;
  XML_LOAD_EXTERNALENTITY = XML_BASE + 39;
  XML_BAD_ENCODING = XML_BASE + 40;

type
  EXMLException = class(Exception)
  private
    FDOMCode: Integer;
    FXMLCode: Integer;
  public
    property DOMCode: Integer read FDOMCode;
    property XMLCode: Integer read FXMLCode;
    constructor CreateParseError(const DOMCode, XMLCode: Integer; const Args: array of const);
  end;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{                                                                             }
{         S T A R T   O F   I N T E R F A C E   D E C L A R A T I O N         }
{                                                                             }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }


type
  TOutputFormat = (ofNone, ofFlat, ofIndent);
  IUnicodeStream = interface
    ['{F3ECA11F-EA18-491C-B59A-4203D5DC8CCA}']
    // private
    function GetCodePage: Word;
    procedure SetCodePage(const CodePage: Word);
    function GetOutputFormat: TOutputFormat;
    procedure SetOutputFormat(const Value: TOutputFormat);
    // public
    procedure IncreaseIndent;
    procedure DecreaseIndent;
    procedure WriteIndent(const ForceNextLine: Boolean = False);
    property OutputFormat: TOutputFormat read GetOutputFormat write SetOutputFormat;
    property CodePage: Word read GetCodePage write SetCodePage;
    procedure UndoRead;
    function ProcessChar(var Char: WideChar): Boolean;
    function GetNextString(var ReadString: WideString; const Len: Integer): Boolean;
    procedure WriteOutputChar(const OutChar: WideChar);
    function GetOutputBuffer: WideString;
    function OutputBufferLen: Integer;
    procedure ClearOutputBuffer;
    procedure WriteString(Value: WideString);
  end;

type
  TStreamMode = (smRead, smWrite);
  TXMLTextStream = class(TInterfacedObject, IUnicodeStream)
  private
    FMode: TGpTSAccess;
    FSize: Integer;
    FXTS: TGpTextStream;
    FPreviousOutBuffer: WideString;
    FOutBuffer: PWideChar;
    FOutBufferPos,
    FOutBufferSize: Integer;
    // undo support
    FPreviousChar: WideChar;
    FReadFromUndo: Boolean;
    FCanUndo: Boolean;
    FIndent: Integer;
    FOutputFormat: TOutputFormat;
    FLinePos,
    FLine: Integer;
    FLineStartPosition: Integer;
    function GetPreviousChar: WideChar;
    property PreviousChar: WideChar read GetPreviousChar;
    function GetCodePage: Word;
    procedure SetCodePage(const CodePage: Word);
    function GetOutputFormat: TOutputFormat;
    procedure SetOutputFormat(const Value: TOutputFormat);
  protected
    FStream: TStream;
    FEOF: Boolean;
    function ReadChar(var ReadChar: WideChar): Boolean; virtual;
    function ProcessChar(var ch: WideChar): Boolean; virtual;
    procedure IncreaseIndent;
    procedure DecreaseIndent;
    procedure WriteIndent(const ForceNextLine: Boolean = False);
    // helper functions
    function GetPosition: Integer;
    function GetPreviousOutputBuffer: WideString;
    function GetLastLine: WideString;
  public
    property OutputFormat: TOutputFormat read GetOutputFormat write SetOutputFormat;
    property CodePage: Word read GetCodePage write SetCodePage;
    constructor Create(const Stream: TStream; const Mode: TStreamMode; const Encoding: Word = CP_UTF16);
    destructor Destroy; override;
    procedure UndoRead; virtual;
    function GetNextString(var ReadString: WideString; const Len: Integer): Boolean;
    procedure WriteOutputChar(const OutChar: WideChar);
    function GetOutputBuffer: WideString;
    function OutputBufferLen: Integer;
    procedure ClearOutputBuffer;
    procedure WriteString(Value: WideString);
  end;

  IXMLParseError = interface
    ['{546E9AE4-4E1E-4014-B0B8-4F024C797544}']
    // private
    function GetErrorCode: Integer;
    function GetFilePos: Integer;
    function GetLine: Integer;
    function GetLinePos: Integer;
    function GetReason: string;
    function GetSrcText: WideString;
    function GetURL: string;
    // public
    property ErrorCode: Integer read GetErrorCode;
    property FilePos: Integer read GetFilePos;
    property Line: Integer read GetLine;
    property LinePos: Integer read GetLinePos;
    property Reason: string read GetReason;
    property SrcText: WideString read GetSrcText;
    property URL: string read GetURL;
  end;

  IXMLElement = interface;
  IXMLDocument = interface;
  IXMLNodeList = interface;
  IXMLNamedNodeMap = interface;

  IXMLNode = interface
    ['{F4D7D3DE-C6EC-4191-8E35-F652C2705E81}']
    // private
    function GetAttributes: IXMLNamedNodeMap;
    function GetChildNodes: IXMLNodeList;
    function GetFirstChild: IXMLNode;
    function GetLastChild: IXMLNode;
    function GetNextSibling: IXMLNode;
    function GetNodeName: WideString;
    function GetNodeType: TNodeType;
    function GetNodeValue: WideString;
    function GetOwnerDocument: IXMLDocument;
    function GetParentNode: IXMLNode;
    function GetPreviousSibling: IXMLNode;
    procedure SetNodeValue(const Value: WideString);
    procedure SetParentNode(const Parent: IXMLNode);
    // public
    function InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
    function ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
    function RemoveChild(const OldChild: IXMLNode): IXMLNode;
    function AppendChild(const NewChild: IXMLNode): IXMLNode;
    function HasChildNodes: Boolean;
    function CloneNode(const Deep: Boolean): IXMLNode;

    property NodeName: WideString read GetNodeName;
    property NodeValue: WideString read GetNodeValue write SetNodeValue;
    property NodeType: TNodeType read GetNodeType;
    property ParentNode: IXMLNode read GetParentNode;
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property FirstChild: IXMLNode read GetFirstChild;
    property LastChild: IXMLNode read GetLastChild;
    property PreviousSibling: IXMLNode read GetPreviousSibling;
    property NextSibling: IXMLNode read GetNextSibling;
    property Attributes: IXMLNamedNodeMap read GetAttributes;
    property OwnerDocument: IXMLDocument read GetOwnerDocument;

    // MS (non-standard) extensions
    function GetText: WideString;
    procedure SetText(const Value: WideString);
    property Text: WideString read GetText write SetText;
    procedure WriteToStream(const OutputStream: IUnicodeStream);
    procedure SelectSingleNode(Pattern: string; var Result: IXMLNode); overload;
    function SelectSingleNode(Pattern: string): IXMLNode; overload;
    procedure SelectNodes(Pattern: string; var Result: IXMLNodeList); overload;
    function SelectNodes(Pattern: string): IXMLNodeList; overload;
    function GetXML: WideString;
    property XML: WideString read GetXML;
  end;

  IXMLCustomList = interface
    ['{6520A0BC-8738-4E40-8CDB-33713DED32ED}']
    // protected
    function GetLength: Integer;
    function GetItem(const Index: Integer): IXMLNode;
    // public
    property Item[const Index: Integer]: IXMLNode read GetItem;
    property Length: Integer read GetLength;
    function Add(const XMLNode: IXMLNode): Integer;
    function IndexOf(const XMLNode: IXMLNode): Integer;
    procedure Insert(const Index: Integer; const XMLNode: IXMLNode);
    function Remove(const XMLNode: IXMLNode): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
  end;

  IXMLNodeList = interface(IXMLCustomList)
    ['{66AF674E-4697-4356-ACCC-4258DA138EA1}']
    // public
    function AddNode(const Arg: IXMLNode): IXMLNode;
    // MS (non-standard) extensions
    procedure Reset;
    function NextNode: IXMLNode;
  end;

  IXMLNamedNodeMap = interface(IXMLCustomList)
    ['{87964B1D-F6CC-46D2-A602-67E198C8BFF5}']
    // public
    function GetNamedItem(const Name: WideString): IXMLNode;
    function SetNamedItem(const Arg: IXMLNode): IXMLNode;
    function RemoveNamedItem(const Name: WideString): IXMLNode;
  end;

  IXMLDocumentType = interface(IXMLNode)
    ['{881517D3-A2F5-4AF0-8A3D-5A57D2C77ED9}']
    // private
    function GetEntities: IXMLNamedNodeMap;
    function GetName: WideString;
    function GetNotations: IXMLNamedNodeMap;
    // public
    property Name: WideString read GetName;
    property Entities: IXMLNamedNodeMap read GetEntities;
    property Notations: IXMLNamedNodeMap read GetNotations;
  end;

  IXMLDocumentFragment = interface(IXMLNode)
    ['{A21A11BF-E489-4416-9607-172EFA2CFE45}']
  end;

  IXMLCharacterData = interface(IXMLNode)
    ['{613A6538-A0DC-49BC-AFA6-D8E611176B86}']
    // private
    function GetData: WideString;
    function GetLength: Integer;
    procedure SetData(const Value: WideString);
    // public
    property Data: WideString read GetData write SetData;
    property Length: Integer read GetLength;
    function SubstringData(const Offset, Count: Integer): WideString;
    procedure AppendData(const Arg: WideString);
    procedure InsertData(const Offset: Integer; const Arg: WideString);
    procedure DeleteData(const Offset, Count: Integer);
    procedure ReplaceData(const Offset, Count: Integer; const Arg: WideString);
  end;

  IXMLText = interface(IXMLCharacterData)
    ['{0EC46ED2-AB58-4DC9-B964-965615248564}']
    // public
    function SplitText(const Offset: Integer): IXMLText;
  end;

  IXMLComment = interface(IXMLCharacterData)
    ['{B094A54C-039F-4ED7-9331-F7CF5A711EDA}']
  end;

  IXMLCDATASection = interface(IXMLText)
    ['{CF58778D-775D-4299-884C-F1DC61925D54}']
  end;

  IXMLProcessingInstruction = interface(IXMLNode)
    ['{AF449E32-2615-4EF7-82B6-B2E9DCCE9FC3}']
    // private
    function GetData: WideString;
    function GetTarget: WideString;
    // public
    property Target: WideString read GetTarget;
    property Data: WideString read GetData;
  end;

  IXMLAttr = interface(IXMLNode)
    ['{10796B8E-FBAC-4ADF-BDD8-E4BBC5A5196F}']
    // private
    function GetName: WideString;
    function GetSpecified: Boolean;
    function GetValue: WideString;
    procedure SetValue(const Value: WideString);
    // public
    property Name: WideString read GetName;
    property Specified: Boolean read GetSpecified;
    property Value: WideString read GetValue write SetValue;
  end;

  IXMLEntityReference = interface(IXMLNode)
    ['{4EC18B2B-BD52-464D-BAD1-1FBE2C445989}']
  end;

  IXMLDocument = interface(IXMLNode)
    ['{59A76970-451C-4343-947C-242EFF17413C}']
    // private
    function GetDocType: IXMLDocumentType;
    procedure SetDocType(const Value: IXMLDocumentType);
    function GetDocumentElement: IXMLElement;
    procedure SetDocumentElement(const Value: IXMLElement);
    function GetPreserveWhiteSpace: Boolean;
    procedure SetPreserveWhiteSpace(const Value: Boolean);
    // public
    property DocType: IXMLDocumentType read GetDocType;
    property DocumentElement: IXMLElement read GetDocumentElement write SetDocumentElement;
    property PreserveWhiteSpace: Boolean read GetPreserveWhiteSpace write SetPreserveWhiteSpace;
    function CreateElement(const TagName: WideString): IXMLElement;
    function CreateDocumentFragment: IXMLDocumentFragment;
    function CreateTextNode(const Data: WideString): IXMLText;
    function CreateComment(const Data: WideString): IXMLComment;
    function CreateCDATASection(const Data: WideString): IXMLCDATASection;
    function CreateProcessingInstruction(const Target, Data: WideString): IXMLProcessingInstruction;
    function CreateAttribute(const Name: WideString): IXMLAttr;
    function CreateEntityReference(const Name: WideString): IXMLEntityReference;
    function GetElementsByTagName(const TagName: WideString): IXMLNodeList;

    // MS (non-standard) extensions
    function Load(const FileName: string): Boolean;
    function LoadFromStream(const Stream: TStream): Boolean;
    procedure Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone);
    procedure SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat = ofNone);
    function LoadXML(const XML: WideString): Boolean;
    function GetParseError: IXMLParseError;
    property ParseError: IXMLParseError read GetParseError;
  end;

  IXMLElement = interface(IXMLNode)
    ['{C858C4E1-FB3F-4C98-8BDE-671E060D17B9}']
    // private
    function GetTagName: WideString;
    // public
    property TagName: WideString read GetTagName;
    function GetAttribute(const Name: WideString): WideString;
    procedure SetAttribute(const Name, Value: WideString);
    procedure RemoveAttribute(const Name: WideString);
    function GetAttributeNode(const Name: WideString): IXMLAttr;
    function SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
    function RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
    function GetElementsByTagName(const Name: WideString): IXMLNodeList;
    procedure Normalize;
  end;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{                                                                             }
{          E N D   O F   I N T E R F A C E   D E C L A R A T I O N            }
{                                                                             }
{                                                                             }
{      S T A R T   O F   I N T E R F A C E   I M P L E M E N T A T I O N      }
{                                                                             }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

type
  TXMLParseError = class(TInterfacedObject, IXMLParseError)
  private
    FErrorCode: Integer;
    FFilePos: Integer;
    FLine: Integer;
    FLinePos: Integer;
    FReason: string;
    FSrcText: WideString;
    FURL: string;
    function GetErrorCode: Integer;
    function GetFilePos: Integer;
    function GetLine: Integer;
    function GetLinePos: Integer;
    function GetReason: string;
    function GetSrcText: WideString;
    function GetURL: string;
  protected
    procedure SetErrorCode(const ErrorCode: Integer);
    procedure SetFilePos(const FilePos: Integer);
    procedure SetLine(const Line: Integer);
    procedure SetLinePos(const LinePos: Integer);
    procedure SetReason(const Reason: string);
    procedure SetSrcText(const SrcText: WideString);
    procedure SetURL(const URL: string);
  public
    destructor Destroy; override;
    property ErrorCode: Integer read GetErrorCode;
    property FilePos: Integer read GetFilePos;
    property Line: Integer read GetLine;
    property LinePos: Integer read GetLinePos;
    property Reason: string read GetReason;
    property SrcText: WideString read GetSrcText;
    property URL: string read GetURL;
  end;

  TXMLNodeList = class;
  TXMLNamedNodeMap = class;
  TXMLDocument = class;
  TXMLAttr = class;
  TXMLElement = class;
  TXMLText = class;
  TXMLComment = class;
  TXMLCDATASection = class;
  TXMLProcessingInstruction = class;

  TXMLNode = class(TInterfacedObject, IXMLNode)
  protected
    FOwnerDocument: TXMLDocument;
    FNodeType: TNodeType;
    FAttributes: IXMLNamedNodeMap;
    FChildNodes: IXMLNodeList;
    FParentNode: IXMLNode;
    FNodeName: WideString;
    FNodeValue: WideString;
    function GetAttributes: IXMLNamedNodeMap;
    function GetChildNodes: IXMLNodeList;
    function GetFirstChild: IXMLNode;
    function GetLastChild: IXMLNode;
    function GetNextSibling: IXMLNode;
    function GetNodeName: WideString;
    function GetNodeType: TNodeType;
    function GetNodeValue: WideString; virtual;
    function GetOwnerDocument: IXMLDocument; virtual;
    function GetParentNode: IXMLNode;
    function GetPreviousSibling: IXMLNode;
    procedure SetNodeValue(const Value: WideString); virtual;
    procedure InternalWrite(const Stream: TStream; Text: WideString); virtual;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); virtual;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); virtual;
    procedure SetParentNode(const Parent: IXMLNode);
    function GetText: WideString; virtual;
    procedure SetText(const Value: WideString); virtual;
    function GetXML: WideString;
  public
    property NodeName: WideString read GetNodeName;
    property NodeValue: WideString read GetNodeValue write SetNodeValue;
    property NodeType: TNodeType read GetNodeType;
    property ParentNode: IXMLNode read GetParentNode;
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property FirstChild: IXMLNode read GetFirstChild;
    property LastChild: IXMLNode read GetLastChild;
    property PreviousSibling: IXMLNode read GetPreviousSibling;
    property NextSibling: IXMLNode read GetNextSibling;
    property Attributes: IXMLNamedNodeMap read GetAttributes;
    property OwnerDocument: IXMLDocument read GetOwnerDocument;
    property Text: WideString read GetText write SetText;
    constructor Create(const AOwnerDocument: TXMLDocument);
    destructor Destroy; override;
    function InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
    function ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
    function RemoveChild(const OldChild: IXMLNode): IXMLNode;
    function AppendChild(const NewChild: IXMLNode): IXMLNode;
    function HasChildNodes: Boolean;
    function CloneNode(const Deep: Boolean): IXMLNode; virtual;
    procedure WriteToStream(const OutputStream: IUnicodeStream);
    procedure SelectNodes(Pattern: string; var Result: IXMLNodeList); overload; virtual;
    function SelectNodes(Pattern: string): IXMLNodeList; overload; virtual;
    procedure SelectSingleNode(Pattern: string; var Result: IXMLNode); overload; virtual;
    function SelectSingleNode(Pattern: string): IXMLNode; overload; virtual;
    property XML: WideString read GetXML;
  end;

  TXMLDocumentType = class(TXMLNode, IXMLNode)
  private
    function GetEntities: IXMLNamedNodeMap;
    function GetName: WideString;
    function GetNotations: IXMLNamedNodeMap;
  public
    property Name: WideString read GetName;
    property Entities: IXMLNamedNodeMap read GetEntities;
    property Notations: IXMLNamedNodeMap read GetNotations;
  end;

  TXMLEntityReference = class(TXMLNode, IXMLEntityReference);

  TXMLDocumentFragment = class(TXMLNode, IXMLDocumentFragment)
  protected
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor Create(const OwnerDocument: TXMLDocument);
  end;

  TXMLCustomList = class(TInterfacedObject, IXMLCustomList)
  private
    FList: TInterfaceList;
  protected
    function GetLength: Integer;
    function GetItem(const Index: Integer): IXMLNode;
    procedure Put(Index: Integer; Item: IXMLNode);
  public
    constructor Create;
    destructor Destroy; override;
    property Item[const Index: Integer]: IXMLNode read GetItem; default;
    property Length: Integer read GetLength;
    function Add(const XMLNode: IXMLNode): Integer;
    function IndexOf(const XMLNode: IXMLNode): Integer;
    procedure Insert(const Index: Integer; const XMLNode: IXMLNode);
    function Remove(const XMLNode: IXMLNode): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
  end;

  TXMLNodeList = class(TXMLCustomList, IXMLNodeList)
  protected
    FItemNo: Integer;
  public
    procedure Reset;
    function NextNode: IXMLNode;
    function AddNode(const Arg: IXMLNode): IXMLNode;
  end;

  TXMLNamedNodeMap = class(TXMLCustomList, IXMLNamedNodeMap)
  public
    function GetNamedItem(const Name: WideString): IXMLNode;
    function SetNamedItem(const Arg: IXMLNode): IXMLNode;
    function RemoveNamedItem(const Name: WideString): IXMLNode;
  end;

  TXMLElement = class(TXMLNode, IXMLElement)
  private
    FTagName: WideString;
  protected
    function GetTagName: WideString;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure SetTagName(const TagName: WideString);
  public
    property TagName: WideString read GetTagName;
    constructor CreateElement(const OwnerDocument: TXMLDocument; const TagName: WideString);
    function GetAttribute(const Name: WideString): WideString;
    procedure SetAttribute(const Name, Value: WideString);
    procedure RemoveAttribute(const Name: WideString);
    function GetAttributeNode(const Name: WideString): IXMLAttr;
    function SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
    function RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
    function GetElementsByTagName(const Name: WideString): IXMLNodeList;
    procedure Normalize;
//    function CloneNode(const Deep: Boolean): IXMLNode; override;
  end;

  TXMLProcessingInstruction = class(TXMLNode, IXMLProcessingInstruction)
  private
    FData: WideString;
    function GetData: WideString;
    function GetTarget: WideString;
  protected
    procedure SetData(Data: WideString); virtual;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    property Target: WideString read GetTarget;
    property Data: WideString read GetData;
    constructor CreateProcessingInstruction(const OwnerDocument: TXMLDocument; const Target, Data: WideString);
  end;

  TXMLAttr = class(TXMLNode, IXMLAttr)
  private
    FSpecified: Boolean;
    function GetName: WideString;
    function GetSpecified: Boolean;
    function GetValue: WideString;
    procedure SetValue(const Value: WideString);
  protected
    procedure SetNodeValue(const Value: WideString); override;
    function GetText: WideString; override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
  public
    property Name: WideString read GetName;
    property Specified: Boolean read GetSpecified;
    property Value: WideString read GetValue write SetValue;
    constructor CreateAttr(const OwnerDocument: TXMLDocument; const Name: WideString);
  end;

  TXMLCharacterData = class(TXMLNode, IXMLCharacterData)
  private
    function GetData: WideString;
    function GetLength: Integer;
    procedure SetData(const Value: WideString);
  protected
    procedure SetNodeValue(const Value: WideString); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    property Data: WideString read GetData write SetData;
    property Length: Integer read GetLength;
    constructor CreateCharacterData(const OwnerDocument: TXMLDocument; const Data: WideString); virtual;
    function SubstringData(const Offset, Count: Integer): WideString;
    procedure AppendData(const Arg: WideString);
    procedure InsertData(const Offset: Integer; const Arg: WideString);
    procedure DeleteData(const Offset, Count: Integer);
    procedure ReplaceData(const Offset, Count: Integer; const Arg: WideString);
  end;

  TXMLText = class(TXMLCharacterData, IXMLText)
  protected
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor Create(const OwnerDocument: TXMLDocument; const Data: WideString); overload;
    function SplitText(const Offset: Integer): IXMLText;
  end;

  TXMLComment = class(TXMLCharacterData, IXMLComment)
  protected
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor CreateComment(const OwnerDocument: TXMLDocument; const Data: WideString); virtual;
  end;

  TXMLCDATASection = class(TXMLText, IXMLCDATASection)
  protected
    procedure SetNodeValue(const Value: WideString); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor CreateCDATASection(const OwnerDocument: TXMLDocument; const Data: WideString); virtual;
  end;

  TXMLElementClass = class of TXMLElement;
  TXMLProcessingInstructionClass = class of TXMLProcessingInstruction;
  TXMLAttrClass = class of TXMLAttr;
  TXMLTextClass = class of TXMLText;
  TXMLCommentClass = class of TXMLComment;
  TXMLCDATASectionClass = class of TXMLCDATASection;

  TXMLDocument = class(TXMLNode, IXMLDocument)
  private
    FDocType: IXMLDocumentType;
    FParseError: TXMLParseError;
    FPreserveWhiteSpace: Boolean;
    FURL: string;
    FIParseError: IXMLParseError;
  protected
    function GetParseError: IXMLParseError;
    function GetDocType: IXMLDocumentType;
    procedure SetDocType(const Value: IXMLDocumentType);
    function GetDocumentElement: IXMLElement;
    procedure SetDocumentElement(const Value: IXMLElement);
    function GetPreserveWhiteSpace: Boolean;
    procedure SetPreserveWhiteSpace(const Value: Boolean);
    function GetText: WideString; override;
    function GetOwnerDocument: IXMLDocument; override;
  protected
    FXMLElementClass: TXMLElementClass;
    FXMLProcessingInstructionClass: TXMLProcessingInstructionClass;
    FXMLAttrClass: TXMLAttrClass;
    FXMLTextClass: TXMLTextClass;
    FXMLCommentClass: TXMLCommentClass;
    FXMLCDATASectionClass: TXMLCDATASectionClass;
    // creating new childs
    function InternalCreateAttribute(const Name: WideString): TXMLAttr;
    function InternalCreateElement(const TagName: WideString): TXMLElement;
    function InternalCreateDocumentFragment: TXMLDocumentFragment;
    function InternalCreateTextNode(const Data: WideString): TXMLText;
    function InternalCreateComment(const Data: WideString): TXMLComment;
    function InternalCreateCDATASection(const Data: WideString): TXMLCDATASection;
    function InternalCreateProcessingInstruction(const Target, Data: WideString): TXMLProcessingInstruction;
    function InternalCreateEntityReference(const Name: WideString): TXMLEntityReference;
    // reading / writing support
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
  public
    property DocType: IXMLDocumentType read GetDocType;
    property DocumentElement: IXMLElement read GetDocumentElement write SetDocumentElement;
    property PreserveWhiteSpace: Boolean read GetPreserveWhiteSpace write SetPreserveWhiteSpace;
    constructor Create; virtual;
    destructor Destroy; override;
    function CreateElement(const TagName: WideString): IXMLElement;
    function CreateDocumentFragment: IXMLDocumentFragment;
    function CreateTextNode(const Data: WideString): IXMLText;
    function CreateComment(const Data: WideString): IXMLComment;
    function CreateCDATASection(const Data: WideString): IXMLCDATASection;
    function CreateProcessingInstruction(const Target, Data: WideString): IXMLProcessingInstruction;
    function CreateAttribute(const Name: WideString): IXMLAttr;
    function CreateEntityReference(const Name: WideString): IXMLEntityReference;
    function GetElementsByTagName(const TagName: WideString): IXMLNodeList;

    function Load(const FileName: string): Boolean; virtual;
    function LoadFromStream(const Stream: TStream): Boolean;
    procedure Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone); virtual;
    procedure SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat = ofNone);
    function LoadXML(const XML: WideString): Boolean; virtual;
    property ParseError: IXMLParseError read GetParseError;
  end;

type
  TCodePage = record
    CodePage: Word;
    Alias: string;
  end;
  TCodePages = array[1..22] of TCodePage;

const
  CodePages: TCodePages = (
    (CodePage:   932; Alias: 'shift-jis'),  // Japanese (Shift-JIS)
    (CodePage: CP_UTF16; Alias: 'utf-16'),  // Central European Alphabet (Windows)
    (CodePage:  1250; Alias: 'windows-1250'),  // Central European Alphabet (Windows)
    (CodePage:  1251; Alias: 'windows-1251'),  // Cyrillic Alphabet (Windows)
    (CodePage:  1252; Alias: 'windows-1252'),  // Western Alphabet
    (CodePage:  1253; Alias: 'windows-1253'),  // Greek Alphabet (Windows)
    (CodePage:  1254; Alias: 'windows-1254'),  // Turkish Alphabet
    (CodePage:  1255; Alias: 'windows-1255'),  // Hebrew Alphabet (Windows)
    (CodePage:  1256; Alias: 'windows-1256'),  // Arabic Alphabet (Windows)
    (CodePage:  1257; Alias: 'windows-1257'),  // Baltic Alphabet (Windows)
    (CodePage:  1258; Alias: 'windows-1258'),  // Vietnamese Alphabet (Windows)
    (CodePage: ISO_8859_1; Alias: 'iso-8859-1'),  // Western Alphabet (ISO)
    (CodePage: ISO_8859_2; Alias: 'iso-8859-2'),  // Central European Alphabet (ISO)
    (CodePage: ISO_8859_3; Alias: 'iso-8859-3'),  // Latin 3 Alphabet (ISO)
    (CodePage: ISO_8859_4; Alias: 'iso-8859-4'),  // Baltic Alphabet (ISO)
    (CodePage: ISO_8859_5; Alias: 'iso-8859-5'),  // Cyrillic Alphabet (ISO)
    (CodePage: ISO_8859_6; Alias: 'iso-8859-6'),  // Arabic Alphabet (ISO)
    (CodePage: ISO_8859_7; Alias: 'iso-8859-7'),  // Greek Alphabet (ISO)
    (CodePage: ISO_8859_8; Alias: 'iso-8859-8'),  // Hebrew Alphabet (ISO)
    (CodePage: 50220; Alias: 'iso-2022-jp'),  // Japanese (JIS)
    (CodePage: 51932; Alias: 'euc-jp'),  // Japanese (EUC)
    (CodePage: CP_UTF8; Alias: 'utf-8')  // Universal Alphabet (UTF-8)
  );

// helper functions
function CreateXMLDoc: IXMLDocument;
// Unicode functions
function UniTrim(const Value: WideString): WideString;

// XML related helper functions
function CharIs_BaseChar(const ch: WideChar): Boolean;
function CharIs_Ideographic(const ch: WideChar): Boolean;
function CharIs_Letter(const ch: WideChar): Boolean;
function CharIs_Extender(const ch: WideChar): Boolean;
function CharIs_Digit(const ch: WideChar): Boolean;
function CharIs_CombiningChar(const ch: WideChar): Boolean;
function CharIs_WhiteSpace(const ch: WideChar): Boolean;
function CharIs_Char(const ch: WideChar): Boolean;
function CharIs_NameChar(const ch: WideChar): Boolean;
function CharIs_Name(const ch: WideChar; const IsFirstChar: Boolean): Boolean;
function EncodeText(const Value: WideString): WideString;

implementation

uses
  OmniXML_LookupTables;

const
  MAX_OUTPUTBUFFERSIZE = 256;  // initial output buffer size (it only stores one tag at once!)
  OUTPUT_INDENT = 2;

type
  TCharRef = record
    Code: Word;
    Name: string;
  end;
  TCharacterReferences = array[1..101] of TCharRef;

var
  DOMErrorInfoList: array[INDEX_SIZE_ERR..INUSE_ATTRIBUTE_ERR] of string = (
    'Index or size is negative, or greater than the allowed value',
    'The specified range of text does not fit into a WideString',
    'Any node is inserted somewhere it doesn''t belong',
    'A node is used in a different document than the one that created it (that doesn''t support it)',
    'An invalid character is specified, such as in a name',
    'Data is specified for a node which does not support data',
    'An attempt is made to modify an object where modifications are not allowed',
    'An attempt was made to reference a node in a context where it does not exist',
    'The implementation does not support the type of object requested',
    'An attempt is made to add an attribute that is already inuse elsewhere');

type
  TErrorInfo = record
    ID: Integer;
    Text: string;
  end;

var
  NodeTypeList: array[TNodeType] of String =
    ('ELEMENT', 'ATTRIBUTE', 'TEXT', 'CDATA_SECTION', 'ENTITY_REFERENCE',
    'ENTITY_NODE', 'PROCESSING_INSTRUCTION', 'COMMENT', 'DOCUMENT',
    'DOCUMENT_TYPE', 'DOCUMENT_FRAGMENT', 'NOTATION');

var
  XMLErrorInfoList: array[MSG_E_NOTEXT..XML_BAD_ENCODING] of TErrorInfo =
    ( (ID: MSG_E_NOTEXT; Text: '%s'),
      (ID: MSG_E_FORMATINDEX_BADINDEX; Text: 'The value passed in to formatIndex needs to be greater than zero.'),
      (ID: MSG_E_FORMATINDEX_BADFORMAT; Text: 'Invalid format string.'),
      (ID: MSG_E_SYSTEM_ERROR; Text: 'System error: %1.'),
      (ID: MSG_E_MISSINGEQUALS; Text: 'Missing equals sign between attribute and attribute value.'),
      (ID: MSG_E_EXPECTED_TOKEN; Text: 'Expected token %1 found %2.'),
      (ID: MSG_E_UNEXPECTED_TOKEN; Text: 'Unexpected token %1.'),
      (ID: MSG_E_MISSINGQUOTE; Text: 'A string literal was expected, but no opening quote character was found.'),
      (ID: MSG_E_COMMENTSYNTAX; Text: 'Incorrect syntax was used in a comment.'),
      (ID: MSG_E_BADSTARTNAMECHAR; Text: 'A name started with an invalid character.'),
      (ID: MSG_E_BADNAMECHAR; Text: 'A name contained an invalid character.'),
      (ID: MSG_E_BADCHARINSTRING; Text: 'The character "<" cannot be used in an attribute value.'),
      (ID: MSG_E_XMLDECLSYNTAX; Text: 'Invalid syntax for an xml declaration.'),
      (ID: MSG_E_BADCHARDATA; Text: 'An invalid character was found in text content.'),
      (ID: MSG_E_MISSINGWHITESPACE; Text: 'Required white space was missing.'),
      (ID: MSG_E_EXPECTINGTAGEND; Text: 'The character ">" was expected.'),
      (ID: MSG_E_BADCHARINDTD; Text: 'Invalid character found in DTD.'),
      (ID: MSG_E_BADCHARINDECL; Text: 'An invalid character was found inside a DTD declaration.'),
      (ID: MSG_E_MISSINGSEMICOLON; Text: 'A semi colon character was expected.'),
      (ID: MSG_E_BADCHARINENTREF; Text: 'An invalid character was found inside an entity reference.'),
      (ID: MSG_E_UNBALANCEDPAREN; Text: 'Unbalanced parentheses.'),
      (ID: MSG_E_EXPECTINGOPENBRACKET; Text: 'An opening "[" character was expected.'),
      (ID: MSG_E_BADENDCONDSECT; Text: 'Invalid syntax in a conditional section.'),
      (ID: MSG_E_INTERNALERROR; Text: 'Internal error: %s'),
      (ID: MSG_E_UNEXPECTED_WHITESPACE; Text: 'Whitespace is not allowed at this location.'),
      (ID: MSG_E_INCOMPLETE_ENCODING; Text: 'End of file reached in invalid state for current encoding.'),
      (ID: MSG_E_BADCHARINMIXEDMODEL; Text: 'Mixed content model cannot contain this character.'),
      (ID: MSG_E_MISSING_STAR; Text: 'Mixed content model must be defined as zero or more("*").'),
      (ID: MSG_E_BADCHARINMODEL; Text: 'Invalid character in content model.'),
      (ID: MSG_E_MISSING_PAREN; Text: 'Missing parenthesis.'),
      (ID: MSG_E_BADCHARINENUMERATION; Text: 'Invalid character found in ATTLIST enumeration.'),
      (ID: MSG_E_PIDECLSYNTAX; Text: 'Invalid syntax in processing instruction declaration.'),
      (ID: MSG_E_EXPECTINGCLOSEQUOTE; Text: 'A single or double closing quote character ('' or ") is missing.'),
      (ID: MSG_E_MULTIPLE_COLONS; Text: 'Multiple colons are not allowed in a name.'),
      (ID: MSG_E_INVALID_DECIMAL; Text: 'Invalid character for decimal digit.'),
      (ID: MSG_E_INVALID_HEXADECIMAL; Text: 'Invalid character for hexadecimal digit.'),
      (ID: MSG_E_INVALID_UNICODE; Text: 'Invalid Unicode character value for this platform.'),
      (ID: MSG_E_WHITESPACEORQUESTIONMARK; Text: 'Expecting white space or "?".'),
      (ID: MSG_E_SUSPENDED; Text: 'The parser is suspended.'),
      (ID: MSG_E_STOPPED; Text: 'The parser is stopped.'),
      (ID: MSG_E_UNEXPECTEDENDTAG; Text: 'End tag was not expected at this location.'),
      (ID: MSG_E_UNCLOSEDTAG; Text: 'The following tags were not closed: %1.'),
      (ID: MSG_E_DUPLICATEATTRIBUTE; Text: 'Duplicate attribute.'),
      (ID: MSG_E_MULTIPLEROOTS; Text: 'Only one top level element is allowed in an XML document.'),
      (ID: MSG_E_INVALIDATROOTLEVEL; Text: 'Invalid character at the top level of the document.'),
      (ID: MSG_E_BADXMLDECL; Text: 'Invalid XML declaration.'),
      (ID: MSG_E_MISSINGROOT; Text: 'XML document must have a top level element.'),
      (ID: MSG_E_UNEXPECTEDEOF; Text: 'Unexpected end of file.'),
      (ID: MSG_E_BADPEREFINSUBSET; Text: 'Parameter entities cannot be used inside markup declarations in an internal subset.'),
      (ID: MSG_E_PE_NESTING; Text: 'The replacement text for a parameter entity must be properly nested with parenthesized groups.'),
      (ID: MSG_E_INVALID_CDATACLOSINGTAG; Text: 'The literal string "]]>" is not allowed in element content.'),
      (ID: MSG_E_UNCLOSEDPI; Text: 'Processing instruction was not closed.'),
      (ID: MSG_E_UNCLOSEDSTARTTAG; Text: 'Element was not closed.'),
      (ID: MSG_E_UNCLOSEDENDTAG; Text: 'End element was missing the character ">".'),
      (ID: MSG_E_UNCLOSEDSTRING; Text: 'A string literal was not closed.'),
      (ID: MSG_E_UNCLOSEDCOMMENT; Text: 'A comment was not closed.'),
      (ID: MSG_E_UNCLOSEDDECL; Text: 'A declaration was not closed.'),
      (ID: MSG_E_UNCLOSEDMARKUPDECL; Text: 'A markup declaration was not closed.'),
      (ID: MSG_E_UNCLOSEDCDATA; Text: 'A CDATA section was not closed.'),
      (ID: MSG_E_BADDECLNAME; Text: 'Declaration has an invalid name.'),
      (ID: MSG_E_BADEXTERNALID; Text: 'External ID is invalid.'),
      (ID: MSG_E_BADELEMENTINDTD; Text: 'An XML element is not allowed inside a DTD.'),
      (ID: MSG_E_RESERVEDNAMESPACE; Text: 'The namespace prefix is not allowed to start with the reserved string "xml".'),
      (ID: MSG_E_EXPECTING_VERSION; Text: 'The version attribute is required at this location.'),
      (ID: MSG_E_EXPECTING_ENCODING; Text: 'The encoding attribute is required at this location.'),
      (ID: MSG_E_EXPECTING_NAME; Text: 'At least one name is required at this location.'),
      (ID: MSG_E_UNEXPECTED_ATTRIBUTE; Text: 'The specified attribute was not expected at this location. The attribute may be case-sensitive.'),
      (ID: MSG_E_ENDTAGMISMATCH; Text: 'End tag %s does not match the start tag %s.'),
      (ID: MSG_E_INVALIDENCODING; Text: 'System does not support the specified encoding.'),
      (ID: MSG_E_INVALIDSWITCH; Text: 'Switch from current encoding to specified encoding not supported.'),
      (ID: MSG_E_EXPECTING_NDATA; Text: 'NDATA keyword is missing.'),
      (ID: MSG_E_INVALID_MODEL; Text: 'Content model is invalid.'),
      (ID: MSG_E_INVALID_TYPE; Text: 'Invalid type defined in ATTLIST.'),
      (ID: MSG_E_INVALIDXMLSPACE; Text: 'XML space attribute has invalid value. Must specify "default" or "preserve".'),
      (ID: MSG_E_MULTI_ATTR_VALUE; Text: 'Multiple names found in attribute value when only one was expected.'),
      (ID: MSG_E_INVALID_PRESENCE; Text: 'Invalid ATTDEF declaration. Expected #REQUIRED, #IMPLIED, or #FIXED.'),
      (ID: MSG_E_BADXMLCASE; Text: 'The name "xml" is reserved and must be lowercase.'),
      (ID: MSG_E_CONDSECTINSUBSET; Text: 'Conditional sections are not allowed in an internal subset.'),
      (ID: MSG_E_CDATAINVALID; Text: 'CDATA is not allowed in a DTD.'),
      (ID: MSG_E_INVALID_STANDALONE; Text: 'The standalone attribute must have the value "yes" or "no".'),
      (ID: MSG_E_UNEXPECTED_STANDALONE; Text: 'The standalone attribute cannot be used in external entities.'),
      (ID: MSG_E_DOCTYPE_IN_DTD; Text: 'Cannot have a DOCTYPE declaration in a DTD.'),
      (ID: MSG_E_MISSING_ENTITY; Text: 'Reference to an undefined entity.'),
      (ID: MSG_E_ENTITYREF_INNAME; Text: 'Entity reference is resolved to an invalid name character.'),
      (ID: MSG_E_DOCTYPE_OUTSIDE_PROLOG; Text: 'Cannot have a DOCTYPE declaration outside of a prolog.'),
      (ID: MSG_E_INVALID_VERSION; Text: 'Invalid version number.'),
      (ID: MSG_E_DTDELEMENT_OUTSIDE_DTD; Text: 'Cannot have a DTD declaration outside of a DTD.'),
      (ID: MSG_E_DUPLICATEDOCTYPE; Text: 'Cannot have multiple DOCTYPE declarations.'),
      (ID: MSG_E_RESOURCE; Text: 'Error processing resource %1.'),
      (ID: MSG_E_INVALID_OPERATION; Text: 'This operation can not be performed with a Node of type %s.'),

      (ID: XML_IOERROR; Text: 'Error opening input file: %1.'),
      (ID: XML_ENTITY_UNDEFINED; Text: 'Reference to undefined entity %1.'),
      (ID: XML_INFINITE_ENTITY_LOOP; Text: 'Entity %1 contains an infinite entity reference loop.'),
      (ID: XML_NDATA_INVALID_PE; Text: 'Cannot use the NDATA keyword in a parameter entity declaration.'),
      (ID: XML_REQUIRED_NDATA; Text: 'Cannot use a general parsed entity ''%1'' as the value for attribute ''%2''.'),
      (ID: XML_NDATA_INVALID_REF; Text: 'Cannot use unparsed entity %1 in an entity reference.'),
      (ID: XML_EXTENT_IN_ATTR; Text: 'Cannot reference an external general parsed entity %1 in an attribute value.'),
      (ID: XML_STOPPED_BY_USER; Text: 'XML parser stopped by user.'),
      (ID: XML_PARSING_ENTITY; Text: 'Error while parsing entity %1. %2.'),
      (ID: XML_E_MISSING_PE_ENTITY; Text: 'Parameter entity must be defined before it is used.'),
      (ID: XML_E_MIXEDCONTENT_DUP_NAME; Text: 'The same name must not appear more than once in a single mixed-content declaration: %1.'),
      (ID: XML_NAME_COLON; Text: 'Entity, EntityRef, PI, Notation names, or NMToken cannot contain a colon.'),
      (ID: XML_ELEMENT_UNDECLARED; Text: 'The element %1 is used but not declared in the DTD/Schema.'),
      (ID: XML_ELEMENT_ID_NOT_FOUND; Text: 'The attribute %1 references the ID %2, which is not defined anywhere in the document.'),
      (ID: XML_DEFAULT_ATTRIBUTE; Text: 'Error in the default attribute value defined in DTD/Schema.'),
      (ID: XML_XMLNS_RESERVED; Text: 'Reserved namespace "%1" cannot be redeclared.'),
      (ID: XML_EMPTY_NOT_ALLOWED; Text: 'Element cannot be empty according to the DTD/Schema.'),
      (ID: XML_ELEMENT_NOT_COMPLETE; Text: 'Element content is incomplete according to the DTD/Schema.'),
      (ID: XML_ROOT_NAME_MISMATCH; Text: 'The name of the top-most element must match the name of the DOCTYPE declaration.'),
      (ID: XML_INVALID_CONTENT; Text: 'Element content is invalid according to the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_NOT_DEFINED; Text: 'The attribute %1 on this element is not defined in the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_FIXED; Text: 'Attribute %1 has a value which does not match the fixed value defined in the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_VALUE; Text: 'Attribute %1 has an invalid value according to the DTD/Schema.'),
      (ID: XML_ILLEGAL_TEXT; Text: 'Text is not allowed in this element according to the DTD/Schema.'),
      (ID: XML_MULTI_FIXED_VALUES; Text: 'An attribute declaration cannot contain multiple fixed values: "%1".'),
      (ID: XML_NOTATION_DEFINED; Text: 'The notation %1 is already declared.'),
      (ID: XML_ELEMENT_DEFINED; Text: 'The element %1 is already declared.'),
      (ID: XML_ELEMENT_UNDEFINED; Text: 'Reference to undeclared element: %1.'),
      (ID: XML_XMLNS_UNDEFINED; Text: 'Reference to undeclared namespace prefix: %1.'),
      (ID: XML_XMLNS_FIXED; Text: 'Attribute %1 must be a #FIXED attribute.'),
      (ID: XML_E_UNKNOWNERROR; Text: 'Unknown error: %1.'),
      (ID: XML_REQUIRED_ATTRIBUTE_MISSING; Text: 'Required attribute %1 is missing.'),
      (ID: XML_MISSING_NOTATION; Text: 'Declaration %1 contains a reference to undefined notation %2.'),
      (ID: XML_ATTLIST_DUPLICATED_ID; Text: 'Cannot define multiple ID attributes on the same element.'),
      (ID: XML_ATTLIST_ID_PRESENCE; Text: 'An attribute of type ID must have a declared default of #IMPLIED or #REQUIRED.'),
      (ID: XML_XMLLANG_INVALIDID; Text: 'The language ID %1 is invalid.'),
      (ID: XML_PUBLICID_INVALID; Text: 'The public ID %1 is invalid.'),
      (ID: XML_DTD_EXPECTING; Text: 'Expecting: %1.'),
      (ID: XML_NAMESPACE_URI_EMPTY; Text: 'Only a default namespace can have an empty URI.'),
      (ID: XML_LOAD_EXTERNALENTITY; Text: 'Could not load %1.'),
      (ID: XML_BAD_ENCODING; Text: 'Unable to save character to %1 encoding.') );

var
  CharacterReferences: TCharacterReferences = (
    (Code:  34; Name: 'quot'),
    (Code:  38; Name: 'amp'),
    (Code:  39; Name: 'apos'),
    (Code:  60; Name: 'lt'),
    (Code:  62; Name: 'gt'),
    (Code: 160; Name: 'nbsp'),
    (Code: 161; Name: 'iexcl'),
    (Code: 162; Name: 'cent'),
    (Code: 163; Name: 'pound'),
    (Code: 164; Name: 'curren'),
    (Code: 165; Name: 'yen'),
    (Code: 166; Name: 'brvbar'),
    (Code: 167; Name: 'sect'),
    (Code: 168; Name: 'uml'),
    (Code: 169; Name: 'copy'),
    (Code: 170; Name: 'ordf'),
    (Code: 171; Name: 'laquo'),
    (Code: 172; Name: 'not'),
    (Code: 173; Name: 'shy'),
    (Code: 174; Name: 'reg'),
    (Code: 175; Name: 'macr'),
    (Code: 176; Name: 'deg'),
    (Code: 177; Name: 'plusm'),
    (Code: 178; Name: 'sup2'),
    (Code: 179; Name: 'sup3'),
    (Code: 180; Name: 'acute'),
    (Code: 181; Name: 'micro'),
    (Code: 182; Name: 'para'),
    (Code: 183; Name: 'middot'),
    (Code: 184; Name: 'cedil'),
    (Code: 185; Name: 'supl'),
    (Code: 186; Name: 'ordm'),
    (Code: 187; Name: 'raquo'),
    (Code: 188; Name: 'frac14'),
    (Code: 189; Name: 'frac12'),
    (Code: 190; Name: 'frac34'),
    (Code: 191; Name: 'iquest'),
    (Code: 192; Name: 'Agrave'),
    (Code: 193; Name: 'Aacute'),
    (Code: 194; Name: 'circ'),
    (Code: 195; Name: 'Atilde'),
    (Code: 196; Name: 'Auml'),
    (Code: 197; Name: 'ring'),
    (Code: 198; Name: 'AElig'),
    (Code: 199; Name: 'Ccedil'),
    (Code: 200; Name: 'Egrave'),
    (Code: 201; Name: 'Eacute'),
    (Code: 202; Name: 'Ecirc'),
    (Code: 203; Name: 'Euml'),
    (Code: 204; Name: 'Igrave'),
    (Code: 205; Name: 'Iacute'),
    (Code: 206; Name: 'Icirc'),
    (Code: 207; Name: 'Iuml'),
    (Code: 208; Name: 'ETH'),
    (Code: 209; Name: 'Ntilde'),
    (Code: 210; Name: 'Ograve'),
    (Code: 211; Name: 'Oacute'),
    (Code: 212; Name: 'Ocirc'),
    (Code: 213; Name: 'Otilde'),
    (Code: 214; Name: 'Ouml'),
    (Code: 215; Name: 'times'),
    (Code: 216; Name: 'Oslash'),
    (Code: 217; Name: 'Ugrave'),
    (Code: 218; Name: 'Uacute'),
    (Code: 219; Name: 'Ucirc'),
    (Code: 220; Name: 'Uuml'),
    (Code: 221; Name: 'Yacute'),
    (Code: 222; Name: 'THORN'),
    (Code: 223; Name: 'szlig'),
    (Code: 224; Name: 'agrave'),
    (Code: 225; Name: 'aacute'),
    (Code: 226; Name: 'acirc'),
    (Code: 227; Name: 'atilde'),
    (Code: 228; Name: 'auml'),
    (Code: 229; Name: 'aring'),
    (Code: 230; Name: 'aelig'),
    (Code: 231; Name: 'ccedil'),
    (Code: 232; Name: 'egrave'),
    (Code: 233; Name: 'eacute'),
    (Code: 234; Name: 'ecirc'),
    (Code: 235; Name: 'euml'),
    (Code: 236; Name: 'igrave'),
    (Code: 237; Name: 'iacute'),
    (Code: 238; Name: 'icirc'),
    (Code: 239; Name: 'iuml'),
    (Code: 240; Name: 'ieth'),
    (Code: 241; Name: 'ntilde'),
    (Code: 242; Name: 'ograve'),
    (Code: 243; Name: 'oacute'),
    (Code: 244; Name: 'ocirc'),
    (Code: 245; Name: 'otilde'),
    (Code: 246; Name: 'ouml'),
    (Code: 247; Name: 'divide'),
    (Code: 248; Name: 'oslash'),
    (Code: 249; Name: 'ugrave'),
    (Code: 250; Name: 'uacute'),
    (Code: 251; Name: 'ucirc'),
    (Code: 252; Name: 'uuml'),
    (Code: 253; Name: 'yacute'),
    (Code: 254; Name: 'thorn'),
    (Code: 255; Name: 'yuml')
  );

const
  BIT_IS_BaseChar = Byte($01);
  BIT_IS_CombiningChar = Byte($02);
  BIT_IS_Digit = Byte($04);
  BIT_IS_Ideographic = Byte($08);
  BIT_IS_Letter = Byte($10);
  BIT_IS_Extender = Byte($20);
  BIT_IS_Char = Byte($40);
  BIT_IS_NameChar = Byte($80);

function CreateXMLDoc: IXMLDocument;
begin
  Result := TXMLDocument.Create;
end;

function GetCodePage(const Alias: string; var CodePage: Word): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := Low(TCodePages);
  while (not Result) and (i <= High(TCodePages)) do begin
    Result := CompareText(Alias, CodePages[i].Alias) = 0;
    if Result then
      CodePage := CodePages[i].CodePage
    else
      Inc(i);
  end;
end;

function FindEncoding(const PI: IXMLProcessingInstruction; var CodePage: Word): Boolean;
var
  EncodingStartPos,
  EncodingEndPos: Integer;
  R: string;
  Encoding: string;
begin
  Result := False;
  if CompareText(PI.Target, 'xml') = 0 then begin
    EncodingStartPos := Pos(AnsiString('encoding="'), PI.Data) + 10;
    if EncodingStartPos > 10 then begin
      R := Copy(PI.Data, EncodingStartPos, MaxInt);
      EncodingEndPos := Pos('"', R) + EncodingStartPos;
      if EncodingEndPos > 0 then begin
        Encoding := Copy(PI.Data, EncodingStartPos, EncodingEndPos - EncodingStartPos - 1);
        Result := GetCodePage(Encoding, CodePage);
      end;
    end;
  end;
end;

function FindCharReference(const CharReferenceName: string; var Character: WideChar): Boolean;
var
  i: Integer;
begin
  Result := False;

  i := Low(CharacterReferences);
  while (not Result) and (i <= High(CharacterReferences)) do begin
    Result := SameText(CharReferenceName, CharacterReferences[i].Name);
    if Result then
      Character := WideChar(CharacterReferences[i].Code)
    else
      Inc(i);
  end;
end;

function CharIs_BaseChar(const ch: WideChar): Boolean;
begin
  // [85] BaseChar
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_BaseChar) > 0;
end;

function CharIs_Ideographic(const ch: WideChar): Boolean;
begin
  // [86] Ideographic
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Ideographic) > 0;
end;

function CharIs_Letter(const ch: WideChar): Boolean;
begin
  // [84] Letter ::= BaseChar | Ideographic
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Letter) > 0;
end;

function CharIs_Extender(const ch: WideChar): Boolean;
begin
  // [89] Extender
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Extender) > 0;
end;

function CharIs_Digit(const ch: WideChar): Boolean;
begin
  // [88] Digit
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Digit) > 0;
end;

function CharIs_CombiningChar(const ch: WideChar): Boolean;
begin
  // [87] CombiningChar
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_CombiningChar) > 0;
end;

function CharIs_WhiteSpace(const ch: WideChar): Boolean;
var
  _ch: Cardinal;
begin
  // [3] WhiteSpace
  _ch := Ord(ch);
  Result := (_ch = $0020) or (_ch = $0009) or (_ch = $000D) or (_ch = $000A);
end;

function CharIs_Char(const ch: WideChar): Boolean;
begin
  // [2] Char - any Unicode character, excluding the surrogate blocks, FFFE, and FFFF
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Char) > 0;
end;

function CharIs_NameChar(const ch: WideChar): Boolean;
begin
  // [4] NameChar ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_NameChar) > 0;
end;

function CharIs_Name(const ch: WideChar; const IsFirstChar: Boolean): Boolean;
var
  _ch: Cardinal;
begin
  // [5] Name ::= (Letter | '_' | ':') (NameChar)*
  _ch := Ord(ch);
  if IsFirstChar then
    Result := CharIs_Letter(ch) or (_ch = $005F) or (_ch = $003A)  // '_', ':'
  else
    Result := CharIs_NameChar(ch);
end;

//
//  E N D
// 


function EncodeText(const Value: WideString): WideString;
var
  iResult: Integer;
  iValue: Integer;

  procedure ExtendResult(atLeast: Integer = 0);
  begin
    SetLength(Result, Round(1.1 * System.Length(Result) + atLeast));
  end;

  procedure Store(const token: WideString);
  var
    iToken: Integer;
  begin
    if (iResult + System.Length(token)) >= System.Length(Result) then
      ExtendResult(System.Length(token));
    for iToken := 1 to System.Length(token) do begin
      Inc(iResult);
      Result[iResult] := token[iToken];
    end;
  end;
begin
  SetLength(Result, Round(1.1 * System.Length(Value)));  // a wild guess
  iResult := 0;
  iValue := 1;
  while iValue <= System.Length(Value) do begin
    case Ord(Value[iValue]) of
      38: Store('&amp;');
      60: Store('&lt;');
      62: Store('&gt;');
    else
      begin
        Inc(iResult);
        if iResult > System.Length(Result) then
          ExtendResult;
        Result[iResult] := Value[iValue];
      end;
    end;
    Inc(iValue);
  end;
  SetLength(Result, iResult);
end;

function Reference2Char(const InputStream: IUnicodeStream): WideChar;
type
  TParserState = (psReference, psEntityRef, psCharRef, psCharDigitalRef, psCharHexRef);
var
  ReadChar: WideChar;
  PState: TParserState;
  CharRef: LongWord;
  EntityName: string;
begin
  // [67] Reference ::= EntityRef | CharRef
  // [68] EntityRef ::= '&' Name ';'
  // [66] CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
  PState := psReference;
  CharRef := 0;
  Result := ' ';
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psReference:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else if ReadChar = '#' then
          PState := psCharRef
        else begin
          if CharIs_Name(ReadChar, True) then begin
            PState := psEntityRef;
            EntityName := ReadChar;
          end
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
        end;
      psCharRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else begin
          case ReadChar of
            '0'..'9':
              begin
                CharRef := Ord(ReadChar) - 48;
                PState := psCharDigitalRef;
              end;
            'x': PState := psCharHexRef;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADCHARINENTREF, []);
          end;
        end;
      psCharDigitalRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else begin
          case ReadChar of
            '0'..'9': CharRef := LongWord(CharRef * 10) + LongWord(Ord(ReadChar) - 48);
            ';':
              begin
                Result := WideChar(CharRef);
                Exit;
              end;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_DECIMAL, []);
          end;
        end;
      psCharHexRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else begin
          case ReadChar of
            '0'..'9': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 48);
            'A'..'F': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 64 - 10);
            'a'..'f': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 96 - 10);
            ';':
              if CharIs_Char(WideChar(CharRef)) then begin
                Result := WideChar(CharRef);
                Exit;
              end
              else
                raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_UNICODE, []);
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_HEXADECIMAL, []);
          end;
          // simple "out of range" check
          if CharRef > $10FFFF then
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_UNICODE, []);
        end;
      psEntityRef:
        case ReadChar of
          ';':
            begin
              if FindCharReference(EntityName, Result) then
                Exit
              else
                raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, XML_ENTITY_UNDEFINED, []);
            end;
        else
          if CharIs_NameChar(ReadChar) then
            EntityName := EntityName + ReadChar
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGSEMICOLON, []);
        end;
    end;
  end;
end;

// Unicode functions

function UniTrim(const Value: WideString): WideString;
var
  Start, Stop: Integer;
begin
  Start := 1;
  Stop := Length(Value);

  // trim from start
  while (Start <= Stop) and (Cardinal(Value[Start]) = $0020) do
    Inc(Start);

  // little optimization
  if Start > Stop then begin
    Result := '';
    Exit;
  end;

  // trim from end
  while (Cardinal(Value[Stop]) = $0020) and (Stop > Start) do
    Dec(Stop);

  Result := Copy(Value, Start, Stop - Start + 1);
end;


// Eol and Whitespace handling
{ TODO -omr : possible optimizations (with expandable buffer) - see EncodeText ? }

function ShrinkEol(const Value: WideString): WideString;
var
  i: Integer;
  SkipFirstLF: Boolean;
begin
  // 2003-02-22 (mr): speed optimization: skip conversion when Value contains no CR characters
  i := 1;
  while i <= System.Length(Value) do begin
    if Value[i] = #$000D then
      Break;
    Inc(i);
  end;
  if i > System.Length(Value) then begin
    // indeed, there was no CR so return original text
    Result := Value;
    Exit;
  end;

  Result := '';
  SkipFirstLF := False;
  for i := 1 to System.Length(Value) do begin
    if Value[i] = #$000D then begin
      SkipFirstLF := True;
      Result := Result + #$000A;
    end
    else if not ((Value[i] = #$000A) and SkipFirstLF) then begin
      SkipFirstLF := False;
      Result := Result + Value[i];
    end
    else if Value[i] = #$000A then
      SkipFirstLF := False;
  end;
end;

function ExpandEol(const Value: WideString): WideString;
var
  i: Integer;
begin
  // 2003-02-22 (mr): speed optimization: skip conversion when Value contains no LF characters
  i := 1;
  while i <= System.Length(Value) do begin
    if Value[i] = #$000A then
      Break;
    Inc(i);
  end;
  if i > System.Length(Value) then begin
    // indeed, there was not LF so return original text
    Result := Value;
    Exit;
  end;

  Result := '';
  for i := 1 to System.Length(Value) do begin
    if Value[i] = #$000A then
      Result := Result + #$000D + #$000A
    else
      Result := Result + Value[i];
  end;
end;

function ShrinkWhitespace(const Value: WideString): WideString;
var
  Start, Stop: Integer;
begin
  Start := 1;
  Stop := Length(Value);

  // trim from start
  while (Start <= Stop) and CharIs_WhiteSpace(Value[Start]) do
    Inc(Start);

  // little optimization
  if Start > Stop then begin
    Result := '';
    Exit;
  end;

  // trim from end
  while CharIs_WhiteSpace(Value[Stop]) and (Stop > Start) do
    Dec(Stop);

  Result := Copy(Value, Start, Stop - Start + 1);
end;


{ EXMLException }

constructor EXMLException.CreateParseError(const DOMCode, XMLCode: Integer; const Args: array of const);
begin
  inherited CreateFmt(XMLErrorInfoList[XMLCode].Text, Args);
  FDOMCode := DOMCode;
  FXMLCode := XMLCode;
end;

{ TXMLTextStream }

constructor TXMLTextStream.Create(const Stream: TStream; const Mode: TStreamMode; const Encoding: Word);
const
  Modes: array[TStreamMode] of TGpTSAccess = (tsaccRead, tsaccWrite);
begin
  FXTS := TGpTextStream.Create(Stream, Modes[Mode], [], Encoding);

  // set defaults
  FIndent := -1;
  FLineStartPosition := FXTS.Position;

  // allocate initial output buffer
  FOutBufferSize := MAX_OUTPUTBUFFERSIZE;
  FOutBufferPos := -1;
  GetMem(FOutBuffer, FOutBufferSize * SizeOf(WideChar));

  // store Mode and prefetch Size
  FMode := Modes[Mode];
  if FMode = tsaccRead then
    FSize := FXTS.Size;
end;

destructor TXMLTextStream.Destroy;
begin
  FreeMem(FOutBuffer, FOutBufferSize * SizeOf(WideChar));
  FXTS.Free;
  inherited;
end;

procedure TXMLTextStream.ClearOutputBuffer;
begin
  FOutBufferPos := -1;
end;

function TXMLTextStream.GetOutputFormat: TOutputFormat;
begin
  Result := FOutputFormat;
end;

procedure TXMLTextStream.SetOutputFormat(const Value: TOutputFormat);
begin
  FOutputFormat := Value;
end;

function TXMLTextStream.GetCodePage: Word;
begin
  Result := FXTS.Codepage;
end;

procedure TXMLTextStream.SetCodePage(const CodePage: Word);
begin
  FXTS.Codepage := CodePage;
end;

function TXMLTextStream.GetNextString(var ReadString: WideString; const Len: Integer): Boolean;
var
  i: Integer;
  ReadChar: WideChar;
begin
  SetLength(ReadString, Len);
  i := 0;
  while (i < Len) and ProcessChar(ReadChar) do begin
    ReadString[i+1] := ReadChar;
    Inc(i);
  end;
  Result := i = Len;
end;

function TXMLTextStream.GetOutputBuffer: WideString;
begin
  SetString(Result, FOutBuffer, FOutBufferPos + 1);
  FPreviousOutBuffer := Result;
  ClearOutputBuffer;  // do not remove this call!
end;

function TXMLTextStream.GetPreviousChar: WideChar;
begin
  if FCanUndo then
    Result := FPreviousChar
  else
    raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INTERNALERROR, ['Only one undo level is supported']);

  FCanUndo := False;
end;

function TXMLTextStream.ReadChar(var ReadChar: WideChar): Boolean;
begin
  if FReadFromUndo then begin
    ReadChar := PreviousChar;
    FReadFromUndo := False;
    Result := True;
  end
  else begin
    // we always expect WideChar (with length=2)
    Result := FXTS.Read(ReadChar, 2) > 0;
    FCanUndo := True;
    FPreviousChar := ReadChar;
  end;
end;

function TXMLTextStream.ProcessChar(var ch: WideChar): Boolean;
begin
  Result := ReadChar(ch);

  Inc(FLinePos);
  // 2003-02-24 (mr): fixed bug (corrected #$0010 to #$000A)
  if ch = #$000A then begin
    Inc(FLine);
    FLinePos := 0;
    FLineStartPosition := FXTS.Position;
  end;
end;

procedure TXMLTextStream.UndoRead;
begin
  // next char will be from the undo buffer
  FReadFromUndo := True;
end;

procedure TXMLTextStream.WriteOutputChar(const OutChar: WideChar);
begin
  // FOutBufferPos points to PWideChar buffer - increment only by 1
  Inc(FOutBufferPos);
  // check for space in output buffer
  if FOutBufferPos = FOutBufferSize then begin
    // double the size of the output buffer
    FOutBufferSize := 2 * FOutBufferSize;
    ReallocMem(FOutBuffer, FOutBufferSize * SizeOf(WideChar));
  end;
  FOutBuffer[FOutBufferPos] := OutChar;
end;

procedure TXMLTextStream.WriteString(Value: WideString);
begin
  FXTS.WriteString(Value);
end;

procedure TXMLTextStream.IncreaseIndent;
begin
  if FIndent = MaxInt then
    FIndent := 0;
  Inc(FIndent);
end;

procedure TXMLTextStream.DecreaseIndent;
begin
  Dec(FIndent);
  if FIndent = 0 then
    FIndent := MaxInt;
end;

procedure TXMLTextStream.WriteIndent(const ForceNextLine: Boolean);
begin
  if FOutputFormat = ofNone then
    Exit;

  // 2002-12-17 (mr): added ForceNextLine
  if (FIndent > 0) or ForceNextLine then
    FXTS.WriteString(#13#10);

  if (FOutputFormat = ofIndent) and (FIndent < MaxInt) and (FIndent > 0) then
    FXTS.WriteString(StringOfChar(' ', FIndent * OUTPUT_INDENT));
end;

function TXMLTextStream.OutputBufferLen: Integer;
begin
  Result := FOutBufferPos + 1;
end;

function TXMLTextStream.GetPosition: Integer;
begin
  if FReadFromUndo then
    Result := FXTS.Position - 1
  else
    Result := FXTS.Position;
end;

function TXMLTextStream.GetPreviousOutputBuffer: WideString;
begin
  Result := FPreviousOutBuffer;
end;

function TXMLTextStream.GetLastLine: WideString;
var
  CurrentPos: Integer;
begin
  CurrentPos := FXTS.Position;
  FXTS.Seek(FLineStartPosition, soFromBeginning);
  if CurrentPos - FLineStartPosition > 0 then begin
    SetLength(Result, FLinePos);
    FXTS.Read(Result[1], FLinePos * 2);
  end
  else
    Result := '';
end;

{ TXMLParseError }

destructor TXMLParseError.Destroy;
begin
  inherited;
  //
end;

function TXMLParseError.GetErrorCode: Integer;
begin
  Result := FErrorCode;
end;

function TXMLParseError.GetFilePos: Integer;
begin
  Result := FFilePos;
end;

function TXMLParseError.GetLine: Integer;
begin
  Result := FLine;
end;

function TXMLParseError.GetLinePos: Integer;
begin
  Result := FLinePos;
end;

function TXMLParseError.GetReason: string;
begin
  Result := FReason;
end;

function TXMLParseError.GetSrcText: WideString;
begin
  Result := FSrcText;
end;

function TXMLParseError.GetURL: string;
begin
  Result := FURL;
end;

procedure TXMLParseError.SetErrorCode(const ErrorCode: Integer);
begin
  FErrorCode := ErrorCode;
end;

procedure TXMLParseError.SetFilePos(const FilePos: Integer);
begin
  FFilePos := FilePos;
end;

procedure TXMLParseError.SetLine(const Line: Integer);
begin
  FLine := Line;
end;

procedure TXMLParseError.SetLinePos(const LinePos: Integer);
begin
  FLinePos := LinePos;
end;

procedure TXMLParseError.SetReason(const Reason: string);
begin
  FReason := Reason;
end;

procedure TXMLParseError.SetSrcText(const SrcText: WideString);
begin
  FSrcText := SrcText;
end;

procedure TXMLParseError.SetURL(const URL: string);
begin
  FURL := URL;
end;

{ TXMLCustomList }

constructor TXMLCustomList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TXMLCustomList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TXMLCustomList.GetItem(const Index: Integer): IXMLNode;
begin
  Result := FList.Items[Index] as IXMLNode;
end;

function TXMLCustomList.GetLength: Integer;
begin
  Result := FList.Count;
end;

function TXMLCustomList.Add(const XMLNode: IXMLNode): Integer;
begin
  Result := FList.Add(XMLNode as IXMLNode);
end;

function TXMLCustomList.Remove(const XMLNode: IXMLNode): Integer;
begin
  Result := FList.Remove(XMLNode as IXMLNode);
end;

procedure TXMLCustomList.Put(Index: Integer; Item: IXMLNode);
begin
  FList[Index] := Item as IXMLNode;
end;

function TXMLCustomList.IndexOf(const XMLNode: IXMLNode): Integer;
begin
  Result := FList.IndexOf(XMLNode as IXMLNode);
end;

procedure TXMLCustomList.Insert(const Index: Integer; const XMLNode: IXMLNode);
begin
  FList.Insert(Index, XMLNode as IXMLNode);
end;

procedure TXMLCustomList.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

procedure TXMLCustomList.Clear;
begin
  FList.Clear;
end;

{ TXMLNodeList }

function TXMLNodeList.NextNode: IXMLNode;
begin
  Result := nil;
  if FItemNo < GetLength then begin
    Result := Item[FItemNo];
    Inc(FItemNo);
  end;
end;

procedure TXMLNodeList.Reset;
begin
  FItemNo := 0;
end;

function TXMLNodeList.AddNode(const Arg: IXMLNode): IXMLNode;
begin
  Result := Arg;
  Add(Arg);
end;

{ TXMLNamedNodeMap }

function TXMLNamedNodeMap.GetNamedItem(const Name: WideString): IXMLNode;
var
  i: Integer;
begin
  i := 0;
  Result := nil;
  while (Result = nil) and (i < GetLength) do begin
    if Item[i].NodeName = Name then
      Result := Item[i]
    else
      Inc(i);
  end;
end;

function TXMLNamedNodeMap.RemoveNamedItem(const Name: WideString): IXMLNode;
begin
  Result := GetNamedItem(Name);
  if Result <> nil then
    Remove(Result);
end;

function TXMLNamedNodeMap.SetNamedItem(const Arg: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  Result := GetNamedItem(Arg.NodeName);
  if Result = nil then
    // old node was not found
    Add(Arg)
  else begin
    // replace old node with new node
    Index := IndexOf(Result);
    Put(Index, Arg);
  end;
end;

{ TXMLNode }

constructor TXMLNode.Create(const AOwnerDocument: TXMLDocument);
begin
  inherited Create;
  FOwnerDocument := AOwnerDocument;
  FChildNodes := TXMLNodeList.Create;
  FAttributes := TXMLNamedNodeMap.Create;
end;

destructor TXMLNode.Destroy;
begin
  Pointer(FParentNode) := nil;  // (gp)
  inherited;
end;

function TXMLNode.appendChild(const newChild: IXMLNode): IXMLNode;
begin
  { TODO -omr : do full checking }
  if (NodeType = ELEMENT_NODE) and (newChild.NodeType = ATTRIBUTE_NODE) then
    raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR,
      MSG_E_INVALID_OPERATION, [NodeTypeList[newChild.NodeType]]);
  Result := FChildNodes.AddNode(NewChild);
  NewChild.SetParentNode(Self);
end;

function TXMLNode.GetParentNode: IXMLNode;
begin
  Result := FParentNode;
end;

procedure TXMLNode.SetParentNode(const Parent: IXMLNode);
begin
  Pointer(FParentNode) := Pointer(Parent);  // (gp)
end;

function TXMLNode.CloneNode(const Deep: Boolean): IXMLNode;
var
  i: Integer;
begin
  case NodeType of
    ELEMENT_NODE: Result := FOwnerDocument.CreateElement(Self.NodeName);
    ATTRIBUTE_NODE: Result := FOwnerDocument.CreateAttribute(Self.NodeName);
    TEXT_NODE: Result := FOwnerDocument.CreateTextNode(Self.NodeValue);
    CDATA_SECTION_NODE: Result := FOwnerDocument.CreateCDATASection(Self.NodeValue);
    ENTITY_REFERENCE_NODE, ENTITY_NODE, DOCUMENT_TYPE_NODE: Assert(False, 'NYI - CloneNode');
    PROCESSING_INSTRUCTION_NODE: Result := FOwnerDocument.CreateProcessingInstruction(Self.NodeName, Self.NodeValue);
    COMMENT_NODE: Result := FOwnerDocument.CreateComment(Self.NodeValue);
    DOCUMENT_NODE: Result := CreateXMLDoc;
    DOCUMENT_FRAGMENT_NODE: Result := FOwnerDocument.CreateDocumentFragment;
    NOTATION_NODE: raise EXMLException.Create('Invalid operation: cannot clone Notation node');
  end;

  Result.NodeValue := Self.NodeValue;

  // clone attributes
  for i := 0 to Self.Attributes.Length - 1 do
    Result.Attributes.Add(Self.Attributes.Item[i].CloneNode(Deep));

  if Deep then begin
    // clone child nodes
    for i := 0 to Self.ChildNodes.Length - 1 do
      Result.ChildNodes.Add(Self.ChildNodes.Item[i].CloneNode(Deep));
  end;
end;

function TXMLNode.GetAttributes: IXMLNamedNodeMap;
begin
  Result := FAttributes;
end;

function TXMLNode.GetChildNodes: IXMLNodeList;
begin
  Result := FChildNodes;
end;

function TXMLNode.GetFirstChild: IXMLNode;
begin
  if FChildNodes.Length > 0 then
    Result := FChildNodes.Item[0]
  else
    Result := nil;
end;

function TXMLNode.GetLastChild: IXMLNode;
begin
  if FChildNodes.Length > 0 then
    Result := FChildNodes.Item[FChildNodes.Length - 1]
  else
    Result := nil;
end;

function TXMLNode.GetNodeName: WideString;
begin
  Result := FNodeName;
end;

function TXMLNode.GetNodeType: TNodeType;
begin
  Result := FNodeType;
end;

function TXMLNode.GetNodeValue: WideString;
begin
  Result := FNodeValue;
end;

procedure TXMLNode.SetNodeValue(const Value: WideString);
begin
  // 2003-02-22 (mr): exception is now raised as default action
  raise EXMLException.CreateParseError(NO_MODIFICATION_ALLOWED_ERR,
    MSG_E_INVALID_OPERATION, [NodeTypeList[FNodeType]]);
end;

function TXMLNode.GetOwnerDocument: IXMLDocument;
begin
  Result := FOwnerDocument;
end;

function TXMLNode.GetPreviousSibling: IXMLNode;
  function FindPreviousNode(const Self: IXMLNode): IXMLNode;
  var
    i: Integer;
    Childs: IXMLNodeList;
    Node: IXMLNode;
  begin
    Result := nil;
    if FParentNode.HasChildNodes then begin
      Childs := FParentNode.ChildNodes;
      i := Childs.Length - 1;
      while (Result = nil) and (i > 0) do begin
        Node := Childs.Item[i] as IXMLNode;
        if Pointer(Node) = Pointer(Self) then
          Result := Childs.Item[i - 1]
        else
          Dec(i);
      end;
    end;
  end;
begin
  if FParentNode <> nil then
    Result := FindPreviousNode(Self as IXMLNode)
  else
    Result := nil;
end;

function TXMLNode.GetNextSibling: IXMLNode;
  function FindNextNode(const Self: IXMLNode): IXMLNode;
  var
    i: Integer;
    Childs: IXMLNodeList;
    Node: IXMLNode;
  begin
    Result := nil;
    if FParentNode.HasChildNodes then begin
      Childs := FParentNode.ChildNodes;
      i := 0;
      while (Result = nil) and (i < (Childs.Length - 1)) do begin
        Node := Childs.Item[i];
        if Pointer(Node) = Pointer(Self) then
          Result := Childs.Item[i + 1]
        else
          Inc(i);
      end;
    end;
  end;
begin
  if FParentNode <> nil then
    Result := FindNextNode(Self as IXMLNode)
  else
    Result := nil;
end;

function TXMLNode.HasChildNodes: Boolean;
begin
  Result := FChildNodes.Length > 0;
end;

function TXMLNode.InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  if RefChild = nil then
    Result := AppendChild(NewChild)
  else begin
    Index := FChildNodes.IndexOf(RefChild) + 1;
    if Index > 0 then begin
      FChildNodes.Insert(Index - 1, NewChild);
      Result := NewChild;
    end
    else
      raise EXMLException.CreateParseError(NOT_FOUND_ERR, MSG_E_NOTEXT, ['Invalid RefChild']);
  end;
end;

function TXMLNode.RemoveChild(const OldChild: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  Index := FChildNodes.IndexOf(OldChild);
  if Index <> -1 then begin
    Result := FChildNodes.Item[Index];
    FChildNodes.Remove(OldChild);
  end;
end;

function TXMLNode.ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  Index := FChildNodes.IndexOf(OldChild);
  if Index <> -1 then begin
    Result := OldChild;
    FChildNodes.Insert(Index, NewChild);
    FChildNodes.Remove(OldChild);
  end;
end;

procedure TXMLNode.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
  // do nothing
end;

procedure TXMLNode.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  if FChildNodes.Length > 0 then begin
    // 2002-12-17 (mr): fixed indentation
    OutputStream.IncreaseIndent;
    for i := 0 to FChildNodes.Length - 1 do
      (FChildNodes.Item[i]).WriteToStream(OutputStream);
    // 2002-12-17 (mr): fixed indentation
    OutputStream.DecreaseIndent;
  end;
end;

procedure TXMLNode.WriteToStream(const OutputStream: IUnicodeStream);
begin
  InternalWriteToStream(OutputStream);
end;

procedure TXMLNode.InternalWrite(const Stream: TStream; Text: WideString);
begin
  Stream.WriteBuffer(Text[1], Length(Text) * 2);
end;

function TXMLNode.GetXML: WideString;
var
  Stream: TMemoryStream;
  US: IUnicodeStream;
begin
  Stream := TMemoryStream.Create;
  try
    US := TXMLTextStream.Create(Stream, smWrite, CP_UTF16);
    try
      InternalWriteToStream(US);
      SetLength(Result, (Stream.Size - SizeOf(WideChar)) div 2);
      Stream.Seek(SizeOf(WideChar), soFromBeginning);
      Stream.Read(PWideChar(Result)^, Stream.Size - SizeOf(WideChar));
    finally
      US := nil;
    end;
  finally
    Stream.Free;
  end;
end;

function TXMLNode.GetText: WideString;
var
  i: Integer;
begin
  i := 0;
  Result := '';
  while i < FChildNodes.Length do begin
    // 2002-12-20 (mr): GetText is now using recursion
    Result := Result + FChildNodes.Item[i].Text;
    Inc(i);
  end;
  if FOwnerDocument.PreserveWhiteSpace then
    Result := Result + Self.NodeValue
  else
    Result := Result + ShrinkWhitespace(Self.NodeValue);
end;

procedure TXMLNode.SetText(const Value: WideString);
var
  i: Integer;
  TextNode: TXMLText;
begin
  i := FChildNodes.Length - 1;
  while i >= 0 do begin
    // 2003-01-13 (mr): setting Text deletes all child nodes
//    if FChildNodes.Item[i].NodeType = TEXT_NODE then
    FChildNodes.Delete(i);
    Dec(i);
  end;

  // adding pure text - no parsing needed
  if Value <> '' then begin
    TextNode := TXMLText.Create(FOwnerDocument, Value);
    AppendChild(TextNode);
  end;
end;

procedure TXMLNode.SelectNodes(Pattern: string; var Result: IXMLNodeList);
var
  i: Integer;
  Delimiter: Integer;
  NodeName: string;
  SubPattern: string;
  EndNode: Boolean;
begin
  if Result = nil then
    Result := TXMLNodeList.Create;

  if (Pattern <> '') and (Pattern[1] = '/') then begin
    // redirect query to the root element
    if FOwnerDocument.DocumentElement <> nil then
      FOwnerDocument.DocumentElement.SelectNodes(Copy(Pattern, 2, MaxInt), Result);
    Exit;
  end
  else begin
    Delimiter := Pos('/', Pattern);
    EndNode := Delimiter = 0;
    if EndNode then begin
      NodeName := Pattern;
    end
    else begin
      NodeName := Copy(Pattern, 1, Delimiter - 1);
      SubPattern := Copy(Pattern, Delimiter + 1, MaxInt);
    end;

    i := 0;
    while i < ChildNodes.Length do begin
      if ChildNodes.Item[i].NodeName = NodeName then begin
        if EndNode then
          // no more subnodes
          Result.AddNode(ChildNodes.Item[i])
        else
          ChildNodes.Item[i].SelectNodes(SubPattern, Result);
      end;
      Inc(i);
    end;
  end;
end;

function TXMLNode.SelectNodes(Pattern: string): IXMLNodeList;
begin
  SelectNodes(Pattern, Result);
end;

procedure TXMLNode.SelectSingleNode(Pattern: string; var Result: IXMLNode);
var
  i: Integer;
  Delimiter: Integer;
  NodeName: string;
  SubPattern: string;
  EndNode: Boolean;
begin
  Result := nil;

  if (Pattern <> '') and (Pattern[1] = '/') then begin
    // redirect query to the root element
    if FOwnerDocument.DocumentElement <> nil then
      FOwnerDocument.DocumentElement.SelectSingleNode(Copy(Pattern, 2, MaxInt), Result);
    Exit;
  end
  else begin
    Delimiter := Pos('/', Pattern);
    EndNode := Delimiter = 0;
    if EndNode then begin
      NodeName := Pattern;
    end
    else begin
      NodeName := Copy(Pattern, 1, Delimiter - 1);
      SubPattern := Copy(Pattern, Delimiter + 1, MaxInt);
    end;

    if NodeName[1] = '@' then begin
      NodeName := Copy(NodeName, 2, MaxInt);
      // searching within attributes
      i := 0;
      while i < Attributes.Length do begin
        if Attributes.Item[i].NodeName = NodeName then begin
          Result := Attributes.Item[i];
          Exit;
        end;
      end;
    end
    else begin
      i := 0;
      while i < ChildNodes.Length do begin
        if ChildNodes.Item[i].NodeName = NodeName then begin
          if EndNode then begin
            Result := ChildNodes.Item[i];
            Exit;
          end
          else begin
            ChildNodes.Item[i].SelectSingleNode(SubPattern, Result);
            if Result <> nil then
              Exit;
          end;
        end;
        Inc(i);
      end;
    end;
  end;
end;

function TXMLNode.SelectSingleNode(Pattern: string): IXMLNode;
begin
  Result := nil;
  SelectSingleNode(Pattern, Result);
end;

{ TXMLDocumentType }

function TXMLDocumentType.GetEntities: IXMLNamedNodeMap;
begin
  Assert(False, 'NYI - getEntities');
end;

function TXMLDocumentType.GetName: WideString;
begin
  Assert(False, 'NYI - getName');
end;

function TXMLDocumentType.GetNotations: IXMLNamedNodeMap;
begin
  Assert(False, 'NYI - getNotations');
end;

{ TXMLElement }

constructor TXMLElement.CreateElement(const OwnerDocument: TXMLDocument; const tagName: WideString);
begin
  inherited Create(OwnerDocument);
  FNodeName := TagName;
  FTagName := TagName;
  FNodeType := ELEMENT_NODE;
end;

function TXMLElement.GetAttribute(const Name: WideString): WideString;
var
  Attr: IXMLAttr;
begin
  Attr := GetAttributeNode(Name);
  if Attr <> nil then
    Result := Attr.Value
  else
    Result := '';
end;

function TXMLElement.GetAttributeNode(const Name: WideString): IXMLAttr;
var
  i: Integer;
begin
  i := 0;
  Result := nil;
  while i < FAttributes.Length do begin
    if FAttributes.Item[i].NodeName = Name then begin
      Result := FAttributes.Item[i] as IXMLAttr;
      Exit;
    end;
    Inc(i);
  end;
end;

function TXMLElement.GetElementsByTagName(const Name: WideString): IXMLNodeList;
  procedure InternalGetElementsByTagName(const Node: IXMLNode);
  var
    i: Integer;
    ChildNode: IXMLNode;
  begin
    for i := 0 to Node.ChildNodes.Length - 1 do begin
      ChildNode := Node.ChildNodes.Item[i];
      if (ChildNode.NodeType = ELEMENT_NODE) and ((ChildNode as IXMLElement).NodeName = Name) then
        Result.AddNode(ChildNode);
      InternalGetElementsByTagName(ChildNode);
    end;
  end;
begin
  Result := TXMLNodeList.Create;
  InternalGetElementsByTagName(Self);
end;

function TXMLElement.GetTagName: WideString;
begin
  Result := FTagName;
end;

procedure TXMLElement.SetTagName(const TagName: WideString);
begin
  FTagName := TagName;
  FNodeName := TagName;
end;

procedure TXMLElement.Normalize;
begin
  Assert(False, 'NYI - Normalize');
end;

procedure TXMLElement.RemoveAttribute(const Name: WideString);
begin
  Assert(False, 'NYI - RemoveAttribute');
end;

function TXMLElement.RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
begin
  Assert(False, 'NYI - RemoveAttributeNode');
end;

procedure TXMLElement.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent;
  OutputStream.WriteString(Format('<%s', [FNodeName]));

  if FAttributes.Length > 0 then
    for i := 0 to FAttributes.Length - 1 do
      FAttributes.Item[i].WriteToStream(OutputStream);

  if ChildNodes.Length = 0 then begin
    if OutputStream.OutputFormat = ofIndent then
      OutputStream.WriteString(' ');
    OutputStream.WriteString('/>');
    Exit;
  end;

  OutputStream.WriteString('>');
  inherited;

  if not ((ChildNodes.Length = 1) and (ChildNodes.Item[0].NodeType = TEXT_NODE)) then
    OutputStream.WriteIndent;

  OutputStream.WriteString(Format('</%s>', [FNodeName]));
end;

procedure TXMLElement.SetAttribute(const Name, Value: WideString);
var
  Attr: IXMLAttr;
begin
  Attr := FOwnerDocument.InternalCreateAttribute(Name);
  Attr.Value := Value;
  FAttributes.SetNamedItem(Attr);
end;

function TXMLElement.SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
begin
  Assert(False, 'NYI - SetAttributeNode');
end;

procedure TXMLElement.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psName, psAttr, psEndTag);
var
  _nodeAttr: TXMLAttr;
  ReadChar: WideChar;
  PState: TParserState;
begin
  // [40] STag ::= '<' Name (S Attribute)* S? '>'
  PState := psName;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psName:
        if CharIs_WhiteSpace(ReadChar) then begin
          SetTagName(InputStream.GetOutputBuffer);
          PState := psAttr;  // switch to an attribute name
        end
        else begin
          case ReadChar of
            '/':
              begin
                SetTagName(InputStream.GetOutputBuffer);
                PState := psEndTag;
              end;
            '>':
              begin
                SetTagName(InputStream.GetOutputBuffer);
                // recursively read subnodes
                FOwnerDocument.ReadFromStream(Self, InputStream);
                Exit;
              end;
          else
            // [4] NameChar
            if CharIs_NameChar(ReadChar) then
              InputStream.WriteOutputChar(ReadChar)
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
          end;
        end;
      psAttr:
        if not CharIs_WhiteSpace(ReadChar) then begin
          case ReadChar of
            '/': PState := psEndTag;
            '>':
              begin
                // recursively read subnodes
                FOwnerDocument.ReadFromStream(Self, InputStream);
                Exit;
              end;
          else
            // [41] Attribute
            // [5] Name
            if CharIs_Letter(ReadChar) or (ReadChar = '_') then begin
              InputStream.ClearOutputBuffer;
              InputStream.WriteOutputChar(ReadChar);
              _nodeAttr := FOwnerDocument.InternalCreateAttribute('');
              Self.Attributes.SetNamedItem(_nodeAttr);
              _nodeAttr.ReadFromStream(Self, InputStream);
            end
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
          end;
        end;
      psEndTag:
        // [44] EmptyElemTag
        begin
          if ReadChar = '>' then
            Exit
          else if CharIs_WhiteSpace(ReadChar) then
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_EXPECTINGTAGEND, []);
        end;
    end;
  end;
end;

{ TXMLProcessingInstruction }

constructor TXMLProcessingInstruction.CreateProcessingInstruction(const OwnerDocument: TXMLDocument; const Target, Data: WideString);
begin
  inherited Create(OwnerDocument);
  FNodeType := PROCESSING_INSTRUCTION_NODE;
  FNodeName := Target;
  SetData(Data);
end;

function TXMLProcessingInstruction.GetData: WideString;
begin
  Result := FData;
end;

procedure TXMLProcessingInstruction.SetData(Data: WideString);
begin
  FData := Data;
end;

function TXMLProcessingInstruction.GetTarget: WideString;
begin
  Result := FNodeName;
end;

procedure TXMLProcessingInstruction.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent;
  OutputStream.WriteString(Format('<?%s %s?>', [FNodeName, FData]));
end;

procedure TXMLProcessingInstruction.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psTarget, psInTarget, psWaitForData, psData, psEndData);
var
  ReadChar: WideChar;
  PState: TParserState;
  CodePage: Word;
  _xmlDoc: IXMLDocument;
begin
  // [16] PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
  PState := psTarget;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psTarget:
        begin
          // [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l')) 
          if CharIs_Name(ReadChar, True) then begin
            InputStream.WriteOutputChar(ReadChar);
            PState := psInTarget;
          end
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
        end;
      psInTarget:
        begin
          // [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))
          if CharIs_WhiteSpace(ReadChar) then begin
            FNodeName := InputStream.GetOutputBuffer;
            if SameText(FNodeName, 'xml') and (not Supports(Parent as IXMLNode, IXMLDocument, _xmlDoc)) then
              raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR, MSG_E_BADXMLDECL, []);
            PState := psWaitForData;
          end
          else if CharIs_NameChar(ReadChar) then
            InputStream.WriteOutputChar(ReadChar)
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
        end;
      psWaitForData:
        if not CharIs_WhiteSpace(ReadChar) then begin
          if ReadChar = '?' then
            PState := psEndData
          else begin
            InputStream.WriteOutputChar(ReadChar);
            PState := psData;
          end;
        end;
      psData:
        if ReadChar = '?' then
          PState := psEndData
        else if CharIs_Char(ReadChar) then
          InputStream.WriteOutputChar(ReadChar)
        else
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
      psEndData:
        begin
          if ReadChar = '>' then begin
            SetData(InputStream.GetOutputBuffer);
            if FindEncoding(Self, CodePage) then
              InputStream.CodePage := CodePage;
            Exit;
          end
          else begin
            // it was a false alert - both characters are part of PI
            InputStream.WriteOutputChar('?');
            InputStream.WriteOutputChar(ReadChar);
            // read more
            PState := psData;
          end;
        end;
    end;
  end;
end;

{ TXMLAttr }

constructor TXMLAttr.CreateAttr(const OwnerDocument: TXMLDocument; const Name: WideString);
begin
  inherited Create(OwnerDocument);
  FNodeName := Name;
  FNodeType := ATTRIBUTE_NODE;
  FSpecified := True;
end;

procedure TXMLAttr.SetNodeValue(const Value: WideString);
begin
  FNodeValue := Value;
end;

function TXMLAttr.GetName: WideString;
begin
  Result := FNodeName;
end;

function TXMLAttr.GetSpecified: Boolean;
begin
  Result := FSpecified;
end;

function TXMLAttr.GetText: WideString;
begin
  // same as nodeValue except the leading and trailing white space is trimmed
  // 2002-12-20 (mr): added checking of PreserveWhiteSpace property
  if FOwnerDocument.PreserveWhiteSpace then
    Result := NodeValue
  else
    Result := ShrinkWhitespace(NodeValue);
end;

function TXMLAttr.GetValue: WideString;
begin
  Result := NodeValue;
end;

procedure TXMLAttr.SetValue(const Value: WideString);
begin
  NodeValue := Value;
end;

procedure TXMLAttr.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  OutputStream.WriteString(Format(' %s="%s"', [FNodeName, EncodeText(NodeValue)]));
end;

procedure TXMLAttr.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psName, psBeforeEqual, psValue, psInValue);
  TAttrValueDelimiter = (avdNone, avdSingle, avdDouble);
var
  ReadChar: WideChar;
  PState: TParserState;
  AttrValueDelimiter: TAttrValueDelimiter;
begin
  // [41] Attribute ::= Name Eq AttValue
  // [5] Name ::= (Letter | '_' | ':') (NameChar)*  
  // [25] Eq ::= S? '=' S?
  // [10] AttValue ::= '"' ([^<&"] | Reference)* '"' | "'" ([^<&'] | Reference)* "'"

  PState := psName;
  AttrValueDelimiter := avdNone;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psName:
        if CharIs_WhiteSpace(ReadChar) then begin
          FNodeName := InputStream.GetOutputBuffer;
          PState := psBeforeEqual;
        end
        else if ReadChar = '=' then begin
          FNodeName := InputStream.GetOutputBuffer;
          PState := psValue;
        end
        else begin
          // [4] NameChar
          if CharIs_NameChar(ReadChar) then
            InputStream.WriteOutputChar(ReadChar)
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
        end;
      psBeforeEqual:
        if not CharIs_WhiteSpace(ReadChar) then begin
          if ReadChar = '=' then
            PState := psValue
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGEQUALS, []);
        end;
      psValue:
        if not CharIs_WhiteSpace(ReadChar) then begin
          case ReadChar of
            '''', '"':  // [10] AttValue
              begin
                PState := psInValue;
                if ReadChar = '''' then
                  AttrValueDelimiter := avdSingle
                else
                  AttrValueDelimiter := avdDouble;
              end;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGQUOTE, []);
          end;
        end;
      psInValue:
        // [10] AttValue
        case ReadChar of
          '''': if AttrValueDelimiter = avdSingle then
            begin
              NodeValue := InputStream.GetOutputBuffer;
              Exit;
            end
            else
              InputStream.WriteOutputChar(ReadChar);
          '"': if AttrValueDelimiter = avdDouble then
            begin
              NodeValue := InputStream.GetOutputBuffer;
              Exit;
            end
            else
              InputStream.WriteOutputChar(ReadChar);
          '<': raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADCHARINSTRING, []);
          '&': InputStream.WriteOutputChar(Reference2Char(InputStream));
        else
          InputStream.WriteOutputChar(ReadChar);
        end;
    end;
  end;
end;

{ TXMLCharacterData }

constructor TXMLCharacterData.CreateCharacterData(const OwnerDocument: TXMLDocument; const Data: WideString);
begin
  inherited Create(OwnerDocument);
  NodeValue := Data;
end;

procedure TXMLCharacterData.SetNodeValue(const Value: WideString);
begin
  // 2003-02-22 (mr): apply EOL handling when setting NodeValue
  FNodeValue := ShrinkEol(Value);
end;

procedure TXMLCharacterData.AppendData(const Arg: WideString);
begin
  Assert(False, 'NYI - AppendData');
end;

procedure TXMLCharacterData.DeleteData(const Offset, Count: Integer);
begin
  Assert(False, 'NYI - DeleteData');
end;

function TXMLCharacterData.GetData: WideString;
begin
  Result := NodeValue;
end;

function TXMLCharacterData.GetLength: Integer;
begin
  Result := System.Length(NodeValue);
end;

procedure TXMLCharacterData.InsertData(const Offset: Integer; const Arg: WideString);
begin
  Assert(False, 'NYI - InsertData');
end;

procedure TXMLCharacterData.ReplaceData(const Offset, Count: Integer; const Arg: WideString);
begin
  Assert(False, 'NYI - ReplaceData');
end;

procedure TXMLCharacterData.SetData(const Value: WideString);
begin
  NodeValue := Value;
end;

function TXMLCharacterData.substringData(const Offset, Count: Integer): WideString;
begin
  Assert(False, 'NYI - SubstringData');
end;

procedure TXMLCharacterData.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2003-01-13 (mr): call inherited to include any child nodes
  inherited;
  OutputStream.WriteString(EncodeText(ExpandEol(NodeValue)));
end;

procedure TXMLCharacterData.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
  // do nothing
end;

{ TXMLText }

constructor TXMLText.Create(const OwnerDocument: TXMLDocument; const Data: WideString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeName := '#text';
  FNodeType := TEXT_NODE;
end;

procedure TXMLText.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psText);
var
  ReadChar: WideChar;
  PState: TParserState;
begin
  // [43] content ::= CharData? ((element | Reference | CDSect | PI | Comment) CharData?)* /* */ 
  // [14] CharData ::= [^<&]* - ([^<&]* ']]>' [^<&]*)
  PState := psText;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psText:
        case ReadChar of
          '<':
            begin
              InputStream.UndoRead;
              // 2002-12-20 (mr): speed optimization
              // add #text node only when some text exists
              if InputStream.OutputBufferLen > 0 then begin
                if not FOwnerDocument.PreserveWhiteSpace then
                  NodeValue := ShrinkWhitespace(NodeValue + InputStream.GetOutputBuffer)
                else
                  NodeValue := NodeValue + InputStream.GetOutputBuffer;
                if NodeValue = '' then
                  Parent.RemoveChild(Self);
              end
              else
                Parent.RemoveChild(Self);
              Exit;
            end;
          '&': InputStream.WriteOutputChar(Reference2Char(InputStream));
        else
          InputStream.WriteOutputChar(ReadChar);
        end;
    end;
  end;
end;

function TXMLText.SplitText(const Offset: Integer): IXMLText;
begin
  Assert(False, 'NYI - SplitText');
end;

{ TXMLCDATASection }

constructor TXMLCDATASection.CreateCDATASection(const OwnerDocument: TXMLDocument; const Data: WideString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeName := '#cdata-section';
  FNodeType := CDATA_SECTION_NODE;
end;

procedure TXMLCDATASection.SetNodeValue(const Value: WideString);
begin
  // 2003-02-22 (mr): there is no EOL handling for CDATA element
  FNodeValue := Value;
end;

procedure TXMLCDATASection.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent(True);
  OutputStream.WriteString(Format('<![CDATA[%s]]>', [NodeValue]));
end;

procedure TXMLCDATASection.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psData, psInEnd, psEnd);
var
  ReadChar: WideChar;
  PState: TParserState;
begin
  PState := psData;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psData:
        if ReadChar = ']' then
          PState := psInEnd
        else
          InputStream.WriteOutputChar(ReadChar);
      psInEnd:
        if ReadChar = ']' then
          PState := psEnd
        else begin
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
      psEnd:
        if ReadChar = '>' then begin
          NodeValue := InputStream.GetOutputBuffer;
          Exit;
        end
        else begin
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
    end;
  end;
end;

{ TXMLComment }

constructor TXMLComment.CreateComment(const OwnerDocument: TXMLDocument; const Data: WideString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeName := '#comment';
  FNodeType := COMMENT_NODE;
end;

procedure TXMLComment.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent(True);
  OutputStream.WriteString(Format('<!--%s-->', [ExpandEol(NodeValue)]));
end;

procedure TXMLComment.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psData, psInEnd, psEnd);
var
  ReadChar: WideChar;
  PState: TParserState;
begin
  PState := psData;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psData:
        if ReadChar = '-' then
          PState := psInEnd
        else
          InputStream.WriteOutputChar(ReadChar);
      psInEnd:
        if ReadChar = '-' then
          PState := psEnd
        else begin
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
      psEnd:
        if ReadChar = '>' then begin
          NodeValue := InputStream.GetOutputBuffer;
          Exit;
        end;
        else begin
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
    end;
  end;
end;

{ TXMLDocumentFragment }

constructor TXMLDocumentFragment.Create(const OwnerDocument: TXMLDocument);
begin
  inherited Create(OwnerDocument);
  FNodeName := '#document-fragment';
  FNodeType := DOCUMENT_FRAGMENT_NODE;
end;

procedure TXMLDocumentFragment.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
{ TODO -omr : choose better - Self or Parent }
  FOwnerDocument.ReadFromStream(Self, InputStream);
end;

{ TXMLDocument }

constructor TXMLDocument.Create;
begin
  inherited Create(Self);
  FNodeName := '#document';
  FNodeType := DOCUMENT_NODE;
  FParseError := TXMLParseError.Create;
  FIParseError := FParseError as IXMLParseError;

  // unlike MS XML parser, we want all characters preserved
  FPreserveWhiteSpace := True;

  // define XML child classes
  FXMLElementClass := TXMLElement;
  FXMLProcessingInstructionClass := TXMLProcessingInstruction;
  FXMLAttrClass := TXMLAttr;
  FXMLTextClass := TXMLText;
  FXMLCommentClass := TXMLComment;
  FXMLCDATASectionClass := TXMLCDATASection;
end;

destructor TXMLDocument.Destroy;
begin
  FIParseError := nil;
  inherited;
end;

function TXMLDocument.GetDocumentElement: IXMLElement;
var
  i: Integer;
begin
  i := 0;
  Result := nil;
  while (Result = nil) and (i < FChildNodes.Length) do begin
    if not Supports(FChildNodes.Item[i], IXMLElement, Result) then
      Inc(i);
  end;
end;

procedure TXMLDocument.SetDocumentElement(const Value: IXMLElement);
var
  i: Integer;
begin
  i := 0;
  while i < ChildNodes.Length do begin
    if ChildNodes.Item[i].NodeType = ELEMENT_NODE then begin
      // insert new element
      ChildNodes.Insert(i, Value);
      // delete old
      ChildNodes.Delete(i + 1);
      Exit;
    end;
    Inc(i);
  end;
  // old document element was not found, so add new
  AppendChild(Value);
end;

function TXMLDocument.GetPreserveWhiteSpace: Boolean;
begin
  Result := FPreserveWhiteSpace;
end;

procedure TXMLDocument.SetPreserveWhiteSpace(const Value: Boolean);
begin
  FPreserveWhiteSpace := Value;
end;

function TXMLDocument.GetParseError: IXMLParseError;
begin
  Result := FParseError as IXMLParseError;
end;

function TXMLDocument.GetDocType: IXMLDocumentType;
begin
  Result := FDocType;
end;

procedure TXMLDocument.SetDocType(const Value: IXMLDocumentType);
begin
  FDocType := Value;
end;

function TXMLDocument.InternalCreateAttribute(const Name: WideString): TXMLAttr;
begin
  Result := FXMLAttrClass.CreateAttr(Self, Name);
end;

function TXMLDocument.CreateAttribute(const Name: WideString): IXMLAttr;
begin
  Result := InternalCreateAttribute(Name);
end;

function TXMLDocument.InternalCreateCDATASection(const Data: WideString): TXMLCDATASection;
begin
  // 2003-01-13 (mr): calling CreateCDATASection instead CreateCharacterData
  Result := FXMLCDATASectionClass.CreateCDATASection(Self, Data);
end;

function TXMLDocument.CreateCDATASection(const Data: WideString): IXMLCDATASection;
begin
  Result := InternalCreateCDATASection(Data);
end;

function TXMLDocument.InternalCreateComment(const Data: WideString): TXMLComment;
begin
  Result := FXMLCommentClass.CreateComment(Self, Data);
end;

function TXMLDocument.CreateComment(const Data: WideString): IXMLComment;
begin
  Result := InternalCreateComment(Data);
end;

function TXMLDocument.InternalCreateDocumentFragment: TXMLDocumentFragment;
begin
  Result := TXMLDocumentFragment.Create(Self);
end;

function TXMLDocument.CreateDocumentFragment: IXMLDocumentFragment;
begin
  Result := InternalCreateDocumentFragment;
end;

function TXMLDocument.InternalCreateElement(const TagName: WideString): TXMLElement;
begin
  Result := FXMLElementClass.CreateElement(Self, TagName);
end;

function TXMLDocument.CreateElement(const TagName: WideString): IXMLElement;
begin
  Result := InternalCreateElement(TagName);
end;

function TXMLDocument.InternalCreateEntityReference(const Name: WideString): TXMLEntityReference;
begin
  Assert(False, 'NYI - CreateEntityReference');
  Result := nil;
end;

function TXMLDocument.CreateEntityReference(const Name: WideString): IXMLEntityReference;
begin
  Result := InternalCreateEntityReference(Name);
end;

function TXMLDocument.InternalCreateProcessingInstruction(const Target, Data: WideString): TXMLProcessingInstruction;
begin
  Result := FXMLProcessingInstructionClass.CreateProcessingInstruction(Self, Target, Data);
end;

function TXMLDocument.CreateProcessingInstruction(const Target, Data: WideString): IXMLProcessingInstruction;
begin
  Result := InternalCreateProcessingInstruction(Target, Data);
end;

function TXMLDocument.InternalCreateTextNode(const Data: WideString): TXMLText;
begin
  Result := FXMLTextClass.Create(Self, Data);
end;

function TXMLDocument.CreateTextNode(const Data: WideString): IXMLText;
begin
  Result := InternalCreateTextNode(Data);
end;

function TXMLDocument.GetText: WideString;
var
  TempDocElement: IXMLElement;
begin
  TempDocElement := DocumentElement;
  if TempDocElement <> nil then
    Result := TempDocElement.Text
  else
    Result := '';
end;

function TXMLDocument.GetOwnerDocument: IXMLDocument;
begin
  // 2003-01-13 (mr): overriden for DOM compatibility
  Result := nil;
end;

function TXMLDocument.GetElementsByTagName(const TagName: WideString): IXMLNodeList;
var
  TempDocElement: IXMLElement;
begin
  TempDocElement := DocumentElement;
  if TempDocElement = nil then
    Result := TXMLNodeList.Create
  else
    Result := TempDocElement.GetElementsByTagName(TagName);
end;

function TXMLDocument.LoadXML(const XML: WideString): Boolean;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.Write(HEADER_UTF16, SizeOf(WideChar));
    Stream.Write(PWideChar(XML)^, Length(XML) * SizeOf(WideChar));
    Stream.Seek(0, soFromBeginning);
    Result := LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TXMLDocument.Load(const FileName: string): Boolean;
var
  MS: TMemoryStream;
begin
  FURL := FileName;
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(FileName);
    Result := LoadFromStream(MS);
  finally
    MS.Free;
  end;
end;

function TXMLDocument.LoadFromStream(const Stream: TStream): Boolean;
var
  XTS: TXMLTextStream;
begin
  Result := True;
  FChildNodes.Clear;

  XTS := TXMLTextStream.Create(Stream, smRead, CP_UTF8);
  try
    try
      ReadFromStream(Self, XTS);
    except
      on E: Exception do begin
        if E is EXMLException then begin
          with FParseError do begin
            SetErrorCode(EXMLException(E).XMLCode);
            SetFilePos(XTS.GetPosition);
            SetLine(XTS.FLine + 1);
            SetLinePos(XTS.FLinePos);
            SetReason(XMLErrorInfoList[FErrorCode].Text);
            SetSrcText(XTS.GetLastLine);
            if SrcText = '' then
              // try to get source text from previously completed buffer
              SetSrcText(XTS.GetPreviousOutputBuffer);
            if SrcText = '' then
              // try to get source text from previously read character
              SetSrcText(XTS.PreviousChar);
            SetURL(Self.FURL);
          end;
          Result := False;
        end
        else
          raise;
      end;
    end;
  finally
    FreeAndNil(XTS);
    FURL := '';
  end;
end;

procedure TXMLDocument.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  if FChildNodes.Length > 0 then begin
    // 2002-12-17 (mr): fixed indentation
    OutputStream.IncreaseIndent;
    for i := 0 to FChildNodes.Length - 1 do begin
      (FChildNodes.Item[i]).WriteToStream(OutputStream);
      if i < (FChildNodes.Length - 1) then
        OutputStream.WriteIndent(True);
    end;
    // 2002-12-17 (mr): fixed indentation
    OutputStream.DecreaseIndent;
  end;
end;

procedure TXMLDocument.SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat);
var
  US: TXMLTextStream;

  function InternalFindEncoding: Word;
  var
    i: Integer;
    TempPI, PI: IXMLProcessingInstruction;
    CodePage: Word;
  begin
    Result := CP_UTF8;
    // find last processing instruction
    for i := 0 to FChildNodes.Length - 1 do begin
      if Supports(FChildNodes.Item[i], IXMLProcessingInstruction, TempPI) then
        PI := TempPI;
    end;
    if (PI <> nil) and FindEncoding(PI, CodePage) then
      Result := CodePage;
  end;
begin
  US := TXMLTextStream.Create(OutputStream, smWrite, InternalFindEncoding);
  try
    US.OutputFormat := OutputFormat;
    InternalWriteToStream(US);
  finally
    US.Free;
  end;
end;

procedure TXMLDocument.Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FileStream, OutputFormat);
  finally
    FileStream.Free;
  end;
end;

procedure TXMLDocument.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psTag, psTagName, psEndTagName, psCommentOrCDATA);
var
  _nodeText: TXMLText;
  _nodePI: TXMLProcessingInstruction;
  _nodeElement: TXMLElement;
  _nodeCDATA: TXMLCDATASection;
  _nodeComment: TXMLComment;
  ReadChar: WideChar;
  PState: TParserState;
  Text: WideString;
  EndTagName: WideString;
begin
  PState := psTag;

  // read next available character
  while InputStream.ProcessChar(ReadChar) do begin
    case PState of
      psTag:
        if ReadChar = '<' then
          PState := psTagName  // waiting for a tag name
        else begin
          InputStream.UndoRead;
          _nodeText := InternalCreateTextNode('');
          Parent.AppendChild(_nodeText);
          _nodeText.ReadFromStream(Parent, InputStream);
        end;
      psTagName:  // one-time stop
        if not CharIs_WhiteSpace(ReadChar) then begin
          case ReadChar of
            '?':
              begin
                _nodePI := InternalCreateProcessingInstruction('', '');
                Parent.AppendChild(_nodePI);
                _nodePI.ReadFromStream(Parent, InputStream);
                PState := psTag;
              end;
            '!': PState := psCommentOrCDATA;  // not enough info, check also next char
            '/': PState := psEndTagName;
          else
            // [40] STag
            // [5] Name
            if CharIs_Letter(ReadChar) or (ReadChar = '_') then begin
              // it's an element
              InputStream.WriteOutputChar(ReadChar);
              _nodeElement := InternalCreateElement('');
              Parent.AppendChild(_nodeElement);
              _nodeElement.ReadFromStream(Parent, InputStream);
              PState := psTag;
            end
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
          end;
        end;
      psEndTagName:
        // [42] ETag
        begin
          case ReadChar of
            '>':
              begin
                EndTagName := InputStream.GetOutputBuffer;
                if EndTagName = Parent.NodeName then
                  Exit
                else
                  raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR, MSG_E_ENDTAGMISMATCH, [EndTagName, Parent.NodeName]);
              end;
          else
            {'A'..'Z', 'a'..'z', '0'..'9':}
            InputStream.WriteOutputChar(ReadChar);
          end;
        end;
      psCommentOrCDATA:
        begin
          case ReadChar of
            '[':
              begin
                InputStream.GetNextString(Text, 6);
                if Text = 'CDATA[' then begin
                  InputStream.ClearOutputBuffer;
                  _nodeCDATA := InternalCreateCDATASection('');
                  Parent.AppendChild(_nodeCDATA);
                  _nodeCDATA.ReadFromStream(Parent, InputStream);
                  PState := psTag;
                end;
              end;
            '-':
              begin
                if InputStream.ProcessChar(ReadChar) and (ReadChar = '-') then begin
                  _nodeComment := InternalCreateComment('');
                  Parent.AppendChild(_nodeComment);
                  _nodeComment.ReadFromStream(Parent, InputStream);
                  PState := psTag;
                end
                else
                  raise Exception.CreateFmt('Invalid node %s', [InputStream.GetOutputBuffer]);
              end;
          end;
        end;
    end;
  end;
end;

end.
