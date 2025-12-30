{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit Classes;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Classes 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses SysUtils, Windows, ActiveX;

const

{ TStream seek origins }

  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;

{ TFileStream create mode }

  fmCreate = $FFFF;

{ TParser special tokens }

  toEOF     = Char(0);
  toSymbol  = Char(1);
  toString  = Char(2);
  toInteger = Char(3);
  toFloat   = Char(4);
  toWString = Char(5);

{ TShortCut special values }

  scShift = $2000;
  scCtrl = $4000;
  scAlt = $8000;
  scNone = 0;

type

{ Text alignment types }

  TAlignment = (taLeftJustify, taRightJustify, taCenter);
  TLeftRight = TAlignment; // taLeftJustify..taRightJustify;
  TBiDiMode = (bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlign,
    bdRightToLeftReadingOnly);

{ Types used by standard events }

  TShiftState = set of (ssShift, ssAlt, ssCtrl,
    ssLeft, ssRight, ssMiddle, ssDouble);

  THelpContext = Integer; // -MaxLongint..MaxLongint;

  TShortCut = Word; // Low(Word)..High(Word);

{ Standard events }

  TNotifyEvent = procedure(Sender: TObject) of object;
  THelpEvent = function (Command: Word; Data: Longint;
    var CallHelp: Boolean): Boolean of object;
  TGetStrProc = procedure(const S: string) of object;

{ Duplicate management }

  TDuplicates = (dupIgnore, dupAccept, dupError);

{ Forward class declarations }

  TStream = class;
  TFiler = class;
  TReader = class;
  TWriter = class;
  TComponent = class;

{ TList class }

  TListSortCompare = function (Item1, Item2: Pointer): Integer;
  TListNotification = (lnAdded, lnExtracted, lnDeleted);

  TList = class(TObject)
  public
    destructor Destroy; override;
    function Add(Item: Pointer): Integer;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TList;
    function Extract(Item: Pointer): Pointer;
    function First: Pointer;
    function IndexOf(Item: Pointer): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
    function Last: Pointer;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Pointer): Integer;
    procedure Pack;
    procedure Sort(Compare: TListSortCompare);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Pointer read Get write Put; default;
  end;

{ IInterfaceList interface }

  IInterfaceList = interface
  ['{285DEA8A-B865-11D1-AAA7-00C04FB17A72}']
    function Get(Index: Integer): IUnknown;
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; Item: IUnknown);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);

    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function First: IUnknown;
    function IndexOf(Item: IUnknown): Integer;
    function Add(Item: IUnknown): Integer;
    procedure Insert(Index: Integer; Item: IUnknown);
    function Last: IUnknown;
    function Remove(Item: IUnknown): Integer;
    procedure Lock;
    procedure Unlock;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: IUnknown read Get write Put; default;
  end;

{ EXTERNALSYM IInterfaceList}

{ TInterfaceList class }

  TInterfaceList = class(TInterfacedObject, IInterfaceList)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TInterfaceList;
    function First: IUnknown;
    function IndexOf(Item: IUnknown): Integer;
    function Add(Item: IUnknown): Integer;
    procedure Insert(Index: Integer; Item: IUnknown);
    function Last: IUnknown;
    function Remove(Item: IUnknown): Integer;
    procedure Lock;
    procedure Unlock;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: IUnknown read Get write Put; default;
  end;

{ EXTERNALSYM TInterfaceList}

{ TBits class }

  TBits = class
  public
    destructor Destroy; override;
    function OpenBit: Integer;
    property Bits[Index: Integer]: Boolean read GetBit write SetBit; default;
    property Size: Integer read FSize write SetSize;
  end;

{ TPersistent abstract class }

{$M+}

  TPersistent = class(TObject)
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); virtual;
    function  GetNamePath: string; dynamic;
  end;

{$M-}

{ TPersistent class reference type }

  TPersistentClass = class of TPersistent;

{ TCollection class }

  TCollection = class;

  TCollectionItem = class(TPersistent)
  public
    constructor Create(Collection: TCollection); virtual;
    destructor Destroy; override;
    function GetNamePath: string; override;
    property Collection: TCollection read FCollection write SetCollection;
    property ID: Integer read FID;
    property Index: Integer read GetIndex write SetIndex;
    property DisplayName: string read GetDisplayName write SetDisplayName;
  end;

  TCollectionItemClass = class of TCollectionItem;

  TCollection = class(TPersistent)
  public
    destructor Destroy; override;
    function Add: TCollectionItem;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate; virtual;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure EndUpdate; virtual;
    function FindItemID(ID: Integer): TCollectionItem;
    function GetNamePath: string; override;
    function Insert(Index: Integer): TCollectionItem;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCollectionItem read GetItem write SetItem;
  end;

{ Collection class that maintains an "Owner" in order to obtain property
  path information at design-time }

  TOwnedCollection = class(TCollection)
  end;

  TStrings = class;

{ IStringsAdapter interface }
{ Maintains link between TStrings and IStrings implementations }

  IStringsAdapter = interface
    ['{739C2F34-52EC-11D0-9EA6-0020AF3D82DA}']
    procedure ReferenceStrings(S: TStrings);
    procedure ReleaseStrings;
  end;

{ TStrings class }

  TStrings = class(TPersistent)
  public
    destructor Destroy; override;
    function Add(const S: string): Integer; virtual;
    function AddObject(const S: string; AObject: TObject): Integer; virtual;
    procedure Append(const S: string);
    procedure AddStrings(Strings: TStrings); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(Strings: TStrings): Boolean;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetText: PChar; virtual;
    function IndexOf(const S: string): Integer; virtual;
    function IndexOfName(const Name: string): Integer;
    function IndexOfObject(AObject: TObject): Integer;
    procedure Insert(Index: Integer; const S: string); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: string;
      AObject: TObject);
    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure SetText(Text: PChar); virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: string read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Names[Index: Integer]: string read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property Values[const Name: string]: string read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
    property Strings[Index: Integer]: string read Get write Put; default;
    property Text: string read GetTextStr write SetTextStr;
    property StringsAdapter: IStringsAdapter read FAdapter write SetStringsAdapter;
  end;

{ TStringList class }

  TStringList = class;

  TStringListSortCompare = function(List: TStringList; Index1, Index2: Integer): Integer;

  TStringList = class(TStrings)
  public
    destructor Destroy; override;
    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: string; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
  end;

{ TStream abstract class }

  TStream = class(TObject)
  public
    function Read(Buffer: Pointer; Count: Longint): Longint; virtual; abstract;
    function Write(Buffer: Pointer; Count: Longint): Longint; virtual; abstract;
    function Seek(Offset: Longint; Origin: Word): Longint; virtual; abstract;
    procedure ReadBuffer(Buffer: Pointer; Count: Longint);
    procedure WriteBuffer(Buffer: Pointer; Count: Longint);
    function CopyFrom(Source: TStream; Count: Longint): Longint;
    function ReadComponent(Instance: TComponent): TComponent;
    function ReadComponentRes(Instance: TComponent): TComponent;
    procedure WriteComponent(Instance: TComponent);
    procedure WriteComponentRes(const ResName: string; Instance: TComponent);
    procedure WriteDescendent(Instance, Ancestor: TComponent);
    procedure WriteDescendentRes(const ResName: string; Instance, Ancestor: TComponent);
    procedure WriteResourceHeader(const ResName: string; out FixupInfo: Integer);
    procedure FixupResourceHeader(FixupInfo: Integer);
    procedure ReadResHeader;
    property Position: Longint read GetPosition write SetPosition;
    property Size: Longint read GetSize write SetSize;
  end;

{ THandleStream class }

  THandleStream = class(TStream)
  public
    constructor Create(AHandle: Integer);
    property Handle: Integer read FHandle;
  end;

{ TFileStream class }

  TFileStream = class(THandleStream)
  public
    constructor Create(const FileName: string; Mode: Word);
    destructor Destroy; override;
  end;

{ TCustomMemoryStream abstract class }

  TCustomMemoryStream = class(TStream)
  public
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
  end;

{ TMemoryStream }

  TMemoryStream = class(TCustomMemoryStream)
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
  end;

{ TStringStream }

  TStringStream = class(TStream)
  public
    constructor Create(const AString: string);
    function ReadString(Count: Longint): string;
    procedure WriteString(const AString: string);
    property DataString: string read FDataString;
  end;

{ TResourceStream }

  TResourceStream = class(TCustomMemoryStream)
  public
    constructor Create(Instance: THandle; const ResName: string; ResType: PChar);
    constructor CreateFromID(Instance: THandle; ResID: Integer; ResType: PChar);
    destructor Destroy; override;
  end;

{ TStreamAdapter }
{ Implements OLE IStream on VCL TStream }

  TStreamOwnership = (soReference, soOwned);

  TStreamAdapter = class(TInterfacedObject, IStream)
  public
    constructor Create(Stream: TStream; Ownership: TStreamOwnership = soReference);
    destructor Destroy; override;
    function Read(pv: Pointer; cb: Longint;
      pcbRead: PLongint): HResult; virtual; stdcall;
    function Write(pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; virtual; stdcall;
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; virtual; stdcall;
    function SetSize(libNewSize: Largeint): HResult; virtual; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; virtual; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall;
    function Revert: HResult; virtual; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function Stat(out statstg: TStatStg;
      grfStatFlag: Longint): HResult; virtual; stdcall;
    function Clone(out stm: IStream): HResult; virtual; stdcall;
    property Stream: TStream read FStream;
    property StreamOwnership: TStreamOwnership read FOwnership write FOwnership;
  end;

{ TFiler }

  TValueType = (vaNull, vaList, vaInt8, vaInt16, vaInt32, vaExtended,
    vaString, vaIdent, vaFalse, vaTrue, vaBinary, vaSet, vaLString,
    vaNil, vaCollection, vaSingle, vaCurrency, vaDate, vaWString, vaInt64);

  TFilerFlag = (ffInherited, ffChildPos, ffInline);
  TFilerFlags = set of TFilerFlag;

  TReaderProc = procedure(Reader: TReader) of object;
  TWriterProc = procedure(Writer: TWriter) of object;
  TStreamProc = procedure(Stream: TStream) of object;

  TFiler = class(TObject)
  public
    constructor Create(Stream: TStream; BufSize: Integer);
    destructor Destroy; override;
    property Root: TComponent read FRoot write SetRoot;
    property LookupRoot: TComponent read FLookupRoot;
    property Ancestor: TPersistent read FAncestor write FAncestor;
    property IgnoreChildren: Boolean read FIgnoreChildren write FIgnoreChildren;
  end;

{ TComponent class reference type }

  TComponentClass = class of TComponent;

{ TReader }

  TFindMethodEvent = procedure(Reader: TReader; const MethodName: string;
    var Address: Pointer; var Error: Boolean) of object;
  TSetNameEvent = procedure(Reader: TReader; Component: TComponent;
    var Name: string) of object;
  TReferenceNameEvent = procedure(Reader: TReader; var Name: string) of object;
  TReadComponentsProc = procedure(Component: TComponent) of object;
  TReaderError = procedure(Reader: TReader; const Message: string; var Handled: Boolean) of object;

  TReader = class(TFiler)
  public
    destructor Destroy; override;
    procedure BeginReferences;
    procedure CheckValue(Value: TValueType);
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, WriteData: TStreamProc;
      HasData: Boolean); override;
    function EndOfList: Boolean;
    procedure EndReferences;
    procedure FixupReferences;
    procedure FlushBuffer; override;
    function NextValue: TValueType;
    procedure Read(Buf: Pointer; Count: Longint);
    function ReadBoolean: Boolean;
    function ReadChar: Char;
    procedure ReadCollection(Collection: TCollection);
    function ReadComponent(Component: TComponent): TComponent;
    procedure ReadComponents(AOwner, AParent: TComponent;
      Proc: TReadComponentsProc);
    function ReadFloat: Extended;
    function ReadSingle: Single;
    function ReadCurrency: Currency;
    function ReadDate: TDateTime;
    function ReadIdent: string;
    function ReadInteger: Longint;
    function ReadInt64: Int64;
    procedure ReadListBegin;
    procedure ReadListEnd;
    procedure ReadPrefix(var Flags: TFilerFlags; var AChildPos: Integer); virtual;
    function ReadRootComponent(Root: TComponent): TComponent;
    procedure ReadSignature;
    function ReadStr: string;
    function ReadString: string;
    function ReadWideString: WideString;
    function ReadValue: TValueType;
    procedure CopyValue(Writer: TWriter);
    property Owner: TComponent read FOwner write FOwner;
    property Parent: TComponent read FParent write FParent;
    property Position: Longint read GetPosition write SetPosition;
    property OnError: TReaderError read FOnError write FOnError;
    property OnFindMethod: TFindMethodEvent read FOnFindMethod write FOnFindMethod;
    property OnSetName: TSetNameEvent read FOnSetName write FOnSetName;
    property OnReferenceName: TReferenceNameEvent read FOnReferenceName write FOnReferenceName;
  end;

{ TWriter }

  TFindAncestorEvent = procedure (Writer: TWriter; Component: TComponent;
    const Name: string; var Ancestor, RootAncestor: TComponent) of object;

  TWriter = class(TFiler)
  public
    destructor Destroy; override;
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, WriteData: TStreamProc;
      HasData: Boolean); override;
    procedure FlushBuffer; override;
    procedure Write(Buf: Pointer; Count: Longint);
    procedure WriteBoolean(Value: Boolean);
    procedure WriteCollection(Value: TCollection);
    procedure WriteComponent(Component: TComponent);
    procedure WriteChar(Value: Char);
    procedure WriteDescendent(Root: TComponent; AAncestor: TComponent);
    procedure WriteFloat(const Value: Extended);
    procedure WriteSingle(const Value: Single);
    procedure WriteCurrency(const Value: Currency);
    procedure WriteDate(const Value: TDateTime);
    procedure WriteIdent(const Ident: string);
    procedure WriteInteger(Value: Longint); overload;
    procedure WriteInt64(Value: Int64); overload;
    procedure WriteListBegin;
    procedure WriteListEnd;
    procedure WriteRootComponent(Root: TComponent);
    procedure WriteSignature;
    procedure WriteStr(const Value: string);
    procedure WriteString(const Value: string);
    procedure WriteWideString(const Value: WideString);
    property Position: Longint read GetPosition write SetPosition;
    property RootAncestor: TComponent read FRootAncestor write FRootAncestor;
    property OnFindAncestor: TFindAncestorEvent read FOnFindAncestor write FOnFindAncestor;
  end;

{ TParser }

  TParser = class(TObject)
  public
    constructor Create(Stream: TStream);
    destructor Destroy; override;
    procedure CheckToken(T: Char);
    procedure CheckTokenSymbol(const S: string);
    procedure Error(const Ident: string);
    procedure ErrorFmt(const Ident: string; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure HexToBinary(Stream: TStream);
    function NextToken: Char;
    function SourcePos: Longint;
    function TokenComponentIdent: string;
    function TokenFloat: Extended;
    function TokenInt: Int64;
    function TokenString: string;
    function TokenWideString: WideString;
    function TokenSymbolIs(const S: string): Boolean;
    property FloatType: Char read FFloatType;
    property SourceLine: Integer read FSourceLine;
    property Token: Char read FToken;
  end;

{ TComponent class }

  TOperation = (opInsert, opRemove);
  TComponentState = set of (csLoading, csReading, csWriting, csDestroying,
    csDesigning, csAncestor, csUpdating, csFixups, csFreeNotification,
    csInline, csDesignInstance);
  TComponentStyle = set of (csInheritable, csCheckPropAvail);
  TGetChildProc = procedure (Child: TComponent) of object;

  TComponentName = type string;

  IVCLComObject = interface
    ['{E07892A0-F52F-11CF-BD2F-0020AF0E5B81}']
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo: Pointer): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; Params: Pointer; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult;
    procedure FreeOnRelease;
  end;

  IDesignerNotify = interface
    ['{B971E807-E3A6-11D1-AAB1-00C04FB16FBC}']
    procedure Modified;
    procedure Notification(AnObject: TPersistent; Operation: TOperation);
  end;  

  TBasicAction = class;

  TComponent = class(TPersistent)
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    procedure DestroyComponents;
    procedure Destroying;
    function ExecuteAction(Action: TBasicAction): Boolean; dynamic;
    function FindComponent(const AName: string): TComponent;
    procedure FreeNotification(AComponent: TComponent);
    procedure RemoveFreeNotification(AComponent: TComponent);
    procedure FreeOnRelease;
    function GetParentComponent: TComponent; dynamic;
    function GetNamePath: string; override;
    function HasParent: Boolean; dynamic;
    procedure InsertComponent(AComponent: TComponent);
    procedure RemoveComponent(AComponent: TComponent);
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
    function UpdateAction(Action: TBasicAction): Boolean; dynamic;
    property ComObject: IUnknown read GetComObject;
    property Components[Index: Integer]: TComponent read GetComponent;
    property ComponentCount: Integer read GetComponentCount;
    property ComponentIndex: Integer read GetComponentIndex write SetComponentIndex;
    property ComponentState: TComponentState read FComponentState;
    property ComponentStyle: TComponentStyle read FComponentStyle;
    property DesignInfo: Longint read FDesignInfo write FDesignInfo;
    property Owner: TComponent read FOwner;
    property VCLComObject: Pointer read FVCLComObject write FVCLComObject;
  published
    property Name: TComponentName read FName write SetName stored False;
    property Tag: Longint read FTag write FTag default 0;
  end;

{ TBasicActionLink }

  TBasicActionLink = class(TObject)
  public
    constructor Create(AClient: TObject); virtual;
    destructor Destroy; override;
    function Execute: Boolean; virtual;
    function Update: Boolean; virtual;
    property Action: TBasicAction read FAction write SetAction;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TBasicActionLinkClass = class of TBasicActionLink;

{ TBasicAction }

  TBasicAction = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function HandlesTarget(Target: TObject): Boolean; virtual;
    procedure UpdateTarget(Target: TObject); virtual;
    procedure ExecuteTarget(Target: TObject); virtual;
    function Execute: Boolean; dynamic;
    procedure RegisterChanges(Value: TBasicActionLink);
    procedure UnRegisterChanges(Value: TBasicActionLink);
    function Update: Boolean; virtual;
    property OnExecute: TNotifyEvent read FOnExecute write SetOnExecute;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

{ TBasicAction class reference type }

  TBasicActionClass = class of TBasicAction;

{ Point and rectangle constructors }

function Point(AX, AY: Integer): TPoint;
function SmallPoint(AX, AY: SmallInt): TSmallPoint;
function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;

{ Object filing routines }

type
  TIdentMapEntry = record
    Value: Integer;
    Name: String;
  end;

  TIdentToInt = function(const Ident: string; var Int: Longint): Boolean;
  TIntToIdent = function(Int: Longint; var Ident: string): Boolean;
  TFindGlobalComponent = function(const Name: string): TComponent;

function FindGlobalComponent(const Name: string): TComponent;

function CollectionsEqual(C1, C2: TCollection): Boolean;

{ Object conversion routines }

type
  TStreamOriginalFormat = (sofUnknown, sofBinary, sofText);

procedure ObjectBinaryToText(Input, Output: TStream;
  var OriginalFormat: TStreamOriginalFormat); overload;
procedure ObjectTextToBinary(Input, Output: TStream;
  var OriginalFormat: TStreamOriginalFormat); overload;

procedure ObjectResourceToText(Input, Output: TStream;
  var OriginalFormat: TStreamOriginalFormat); overload;
procedure ObjectTextToResource(Input, Output: TStream;
  var OriginalFormat: TStreamOriginalFormat); overload;

function TestStreamFormat(Stream: TStream): TStreamOriginalFormat;

{ Utility routines }

function LineStart(Buffer, BufPos: PChar): PChar;
function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar;
  Strings: TStrings): Integer;

procedure BinToHex(Buffer, Text: PChar; BufSize: Integer);
function HexToBin(Text, Buffer: PChar; BufSize: Integer): Integer;

function FindRootDesigner(Obj: TPersistent): IDesignerNotify;

implementation

end.
