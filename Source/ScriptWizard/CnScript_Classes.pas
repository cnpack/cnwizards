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

unit CnScript_Classes;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 SysUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, FileCtrl, Classes, uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_Classes = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TBasicAction(CL: TPSPascalCompiler);
procedure SIRegister_TBasicActionLink(CL: TPSPascalCompiler);
procedure SIRegister_TComponent(CL: TPSPascalCompiler);
procedure SIRegister_IDesignerNotify(CL: TPSPascalCompiler);
procedure SIRegister_IVCLComObject(CL: TPSPascalCompiler);
procedure SIRegister_TParser(CL: TPSPascalCompiler);
procedure SIRegister_TWriter(CL: TPSPascalCompiler);
procedure SIRegister_TReader(CL: TPSPascalCompiler);
procedure SIRegister_TFiler(CL: TPSPascalCompiler);
procedure SIRegister_TStreamAdapter(CL: TPSPascalCompiler);
procedure SIRegister_TResourceStream(CL: TPSPascalCompiler);
procedure SIRegister_TStringStream(CL: TPSPascalCompiler);
procedure SIRegister_TMemoryStream(CL: TPSPascalCompiler);
procedure SIRegister_TCustomMemoryStream(CL: TPSPascalCompiler);
procedure SIRegister_TFileStream(CL: TPSPascalCompiler);
procedure SIRegister_THandleStream(CL: TPSPascalCompiler);
procedure SIRegister_TStream(CL: TPSPascalCompiler);
procedure SIRegister_TStringList(CL: TPSPascalCompiler);
procedure SIRegister_TStrings(CL: TPSPascalCompiler);
procedure SIRegister_IStringsAdapter(CL: TPSPascalCompiler);
procedure SIRegister_TOwnedCollection(CL: TPSPascalCompiler);
procedure SIRegister_TCollection(CL: TPSPascalCompiler);
procedure SIRegister_TCollectionItem(CL: TPSPascalCompiler);
procedure SIRegister_TPersistent(CL: TPSPascalCompiler);
procedure SIRegister_TBits(CL: TPSPascalCompiler);
procedure SIRegister_TInterfaceList(CL: TPSPascalCompiler);
procedure SIRegister_IInterfaceList(CL: TPSPascalCompiler);
procedure SIRegister_TList(CL: TPSPascalCompiler);
procedure SIRegister_Classes(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Classes_Routines(S: TPSExec);
procedure RIRegister_TBasicAction(CL: TPSRuntimeClassImporter);
procedure RIRegister_TBasicActionLink(CL: TPSRuntimeClassImporter);
procedure RIRegister_TComponent(CL: TPSRuntimeClassImporter);
procedure RIRegister_TParser(CL: TPSRuntimeClassImporter);
procedure RIRegister_TWriter(CL: TPSRuntimeClassImporter);
procedure RIRegister_TReader(CL: TPSRuntimeClassImporter);
procedure RIRegister_TFiler(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStreamAdapter(CL: TPSRuntimeClassImporter);
procedure RIRegister_TResourceStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStringStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMemoryStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomMemoryStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TFileStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_THandleStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStream(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStringList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TStrings(CL: TPSRuntimeClassImporter);
procedure RIRegister_TOwnedCollection(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCollection(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCollectionItem(CL: TPSRuntimeClassImporter);
procedure RIRegister_TPersistent(CL: TPSRuntimeClassImporter);
procedure RIRegister_TBits(CL: TPSRuntimeClassImporter);
procedure RIRegister_TInterfaceList(CL: TPSRuntimeClassImporter);
procedure RIRegister_TList(CL: TPSRuntimeClassImporter);
procedure RIRegister_Classes(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)
procedure SIRegister_TBasicAction(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TBasicAction') do
  with CL.AddClass(CL.FindClass('TComponent'), TBasicAction) do
  begin
    RegisterMethod('Function HandlesTarget( Target : TObject) : Boolean');
    RegisterMethod('Procedure UpdateTarget( Target : TObject)');
    RegisterMethod('Procedure ExecuteTarget( Target : TObject)');
    RegisterMethod('Function Execute : Boolean');
{$IFNDEF DELPHI101_BERLIN_UP}
    RegisterMethod('Procedure RegisterChanges( Value : TBasicActionLink)');
    RegisterMethod('Procedure UnRegisterChanges( Value : TBasicActionLink)');
{$ENDIF}
    RegisterMethod('Function Update : Boolean');
    RegisterProperty('OnExecute', 'TNotifyEvent', iptrw);
    RegisterProperty('OnUpdate', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TBasicActionLink(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TBasicActionLink') do
  with CL.AddClass(CL.FindClass('TObject'), TBasicActionLink) do
  begin
    RegisterMethod('Constructor Create( AClient : TObject)');
    RegisterMethod('Function Execute : Boolean');
    RegisterMethod('Function Update : Boolean');
    RegisterProperty('Action', 'TBasicAction', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TComponent(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TComponent') do
  with CL.AddClass(CL.FindClass('TPersistent'), TComponent) do
  begin
    RegisterMethod('Constructor Create( AOwner : TComponent)');
    RegisterMethod('Procedure DestroyComponents');
    RegisterMethod('Procedure Destroying');
    RegisterMethod('Function ExecuteAction( Action : TBasicAction) : Boolean');
    RegisterMethod('Function FindComponent( const AName : string) : TComponent');
    RegisterMethod('Procedure FreeNotification( AComponent : TComponent)');
    RegisterMethod('Procedure RemoveFreeNotification( AComponent : TComponent)');
    RegisterMethod('Procedure FreeOnRelease');
    RegisterMethod('Function GetParentComponent : TComponent');
    RegisterMethod('Function HasParent : Boolean');
    RegisterMethod('Procedure InsertComponent( AComponent : TComponent)');
    RegisterMethod('Procedure RemoveComponent( AComponent : TComponent)');
    RegisterMethod('Function UpdateAction( Action : TBasicAction) : Boolean');
    RegisterProperty('ComObject', 'IUnknown', iptr);
    RegisterProperty('Components', 'TComponent Integer', iptr);
    RegisterProperty('ComponentCount', 'Integer', iptr);
    RegisterProperty('ComponentIndex', 'Integer', iptrw);
    RegisterProperty('ComponentState', 'TComponentState', iptr);
    RegisterProperty('ComponentStyle', 'TComponentStyle', iptr);
    RegisterProperty('DesignInfo', 'Longint', iptrw);
    RegisterProperty('Owner', 'TComponent', iptr);
    RegisterProperty('VCLComObject', 'Pointer', iptrw);
    RegisterProperty('Name', 'TComponentName', iptrw);
    RegisterProperty('Tag', 'Longint', iptrw);
  end;
end;

procedure SIRegister_IDesignerNotify(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IDesignerNotify') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IDesignerNotify, 'IDesignerNotify') do
  begin
    RegisterMethod('Procedure Modified', cdRegister);
    RegisterMethod('Procedure Notification( AnObject : TPersistent; Operation : TOperation)', cdRegister);
  end;
end;

procedure SIRegister_IVCLComObject(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IVCLComObject') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IVCLComObject, 'IVCLComObject') do
  begin
    RegisterMethod('Function GetTypeInfoCount( out Count : Integer) : HResult', CdStdCall);
    RegisterMethod('Function GetTypeInfo( Index, LocaleID : Integer; out TypeInfo : Pointer) : HResult', CdStdCall);
    RegisterMethod('Function GetIDsOfNames( const IID : TGUID; Names : Pointer; NameCount, LocaleID : Integer; DispIDs : Pointer) : HResult', CdStdCall);
    RegisterMethod('Function Invoke( DispID : Integer; const IID : TGUID; LocaleID : Integer; Flags : Word; Params : Pointer; VarResult, ExcepInfo, ArgErr : Pointer) : HResult', CdStdCall);
    RegisterMethod('Function SafeCallException( ExceptObject : TObject; ExceptAddr : Pointer) : HResult', cdRegister);
    RegisterMethod('Procedure FreeOnRelease', cdRegister);
  end;
end;

procedure SIRegister_TParser(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TParser') do
  with CL.AddClass(CL.FindClass('TObject'), TParser) do
  begin
    RegisterMethod('Constructor Create( Stream : TStream)');
    RegisterMethod('Procedure CheckToken( T : Char)');
    RegisterMethod('Procedure CheckTokenSymbol( const S : string)');
    RegisterMethod('Procedure Error( const Ident : string)');
    RegisterMethod('Procedure ErrorFmt( const Ident : string; const Args : array of const)');
    RegisterMethod('Procedure ErrorStr( const Message : string)');
    RegisterMethod('Procedure HexToBinary( Stream : TStream)');
    RegisterMethod('Function NextToken : Char');
    RegisterMethod('Function SourcePos : Longint');
    RegisterMethod('Function TokenComponentIdent : string');
    RegisterMethod('Function TokenFloat : Extended');
    RegisterMethod('Function TokenInt : Int64');
    RegisterMethod('Function TokenString : string');
    RegisterMethod('Function TokenWideString : WideString');
    RegisterMethod('Function TokenSymbolIs( const S : string) : Boolean');
    RegisterProperty('FloatType', 'Char', iptr);
    RegisterProperty('SourceLine', 'Integer', iptr);
    RegisterProperty('Token', 'Char', iptr);
  end;
end;

procedure SIRegister_TWriter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TFiler', 'TWriter') do
  with CL.AddClass(CL.FindClass('TFiler'), TWriter) do
  begin
    RegisterMethod('Procedure Write( Buf : Pointer; Count : Longint)');
    RegisterMethod('Procedure WriteBoolean( Value : Boolean)');
    RegisterMethod('Procedure WriteCollection( Value : TCollection)');
    RegisterMethod('Procedure WriteComponent( Component : TComponent)');
    RegisterMethod('Procedure WriteChar( Value : Char)');
    RegisterMethod('Procedure WriteDescendent( Root : TComponent; AAncestor : TComponent)');
    RegisterMethod('Procedure WriteFloat( const Value : Extended)');
    RegisterMethod('Procedure WriteSingle( const Value : Single)');
    RegisterMethod('Procedure WriteCurrency( const Value : Currency)');
    RegisterMethod('Procedure WriteDate( const Value : TDateTime)');
    RegisterMethod('Procedure WriteIdent( const Ident : string)');
    RegisterMethod('Procedure WriteInteger( Value : Longint);');
    RegisterMethod('Procedure WriteInt64( Value : Int64);');
    RegisterMethod('Procedure WriteListBegin');
    RegisterMethod('Procedure WriteListEnd');
    RegisterMethod('Procedure WriteRootComponent( Root : TComponent)');
    RegisterMethod('Procedure WriteSignature');
    RegisterMethod('Procedure WriteStr( const Value : string)');
    RegisterMethod('Procedure WriteString( const Value : string)');
    RegisterMethod('Procedure WriteWideString( const Value : WideString)');
    RegisterProperty('Position', 'Longint', iptrw);
    RegisterProperty('RootAncestor', 'TComponent', iptrw);
    RegisterProperty('OnFindAncestor', 'TFindAncestorEvent', iptrw);
  end;
end;

procedure SIRegister_TReader(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TFiler', 'TReader') do
  with CL.AddClass(CL.FindClass('TFiler'), TReader) do
  begin
    RegisterMethod('Procedure BeginReferences');
    RegisterMethod('Procedure CheckValue( Value : TValueType)');
    RegisterMethod('Function EndOfList : Boolean');
    RegisterMethod('Procedure EndReferences');
    RegisterMethod('Procedure FixupReferences');
    RegisterMethod('Function NextValue : TValueType');
    RegisterMethod('Procedure Read( Buf : Pointer; Count : Longint)');
    RegisterMethod('Function ReadBoolean : Boolean');
    RegisterMethod('Function ReadChar : Char');
    RegisterMethod('Procedure ReadCollection( Collection : TCollection)');
    RegisterMethod('Function ReadComponent( Component : TComponent) : TComponent');
    RegisterMethod('Procedure ReadComponents( AOwner, AParent : TComponent; Proc : TReadComponentsProc)');
    RegisterMethod('Function ReadFloat : Extended');
    RegisterMethod('Function ReadSingle : Single');
    RegisterMethod('Function ReadCurrency : Currency');
    RegisterMethod('Function ReadDate : TDateTime');
    RegisterMethod('Function ReadIdent : string');
    RegisterMethod('Function ReadInteger : Longint');
    RegisterMethod('Function ReadInt64 : Int64');
    RegisterMethod('Procedure ReadListBegin');
    RegisterMethod('Procedure ReadListEnd');
    RegisterMethod('Procedure ReadPrefix( var Flags : TFilerFlags; var AChildPos : Integer)');
    RegisterMethod('Function ReadRootComponent( Root : TComponent) : TComponent');
    RegisterMethod('Procedure ReadSignature');
    RegisterMethod('Function ReadStr : string');
    RegisterMethod('Function ReadString : string');
    RegisterMethod('Function ReadWideString : WideString');
    RegisterMethod('Function ReadValue : TValueType');
    RegisterMethod('Procedure CopyValue( Writer : TWriter)');
    RegisterProperty('Owner', 'TComponent', iptrw);
    RegisterProperty('Parent', 'TComponent', iptrw);
    RegisterProperty('Position', 'Longint', iptrw);
    RegisterProperty('OnError', 'TReaderError', iptrw);
    RegisterProperty('OnFindMethod', 'TFindMethodEvent', iptrw);
    RegisterProperty('OnSetName', 'TSetNameEvent', iptrw);
    RegisterProperty('OnReferenceName', 'TReferenceNameEvent', iptrw);
  end;
end;

procedure SIRegister_TFiler(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TFiler') do
  with CL.AddClass(CL.FindClass('TObject'), TFiler) do
  begin
    RegisterMethod('Constructor Create( Stream : TStream; BufSize : Integer)');
    RegisterProperty('Root', 'TComponent', iptrw);
    RegisterProperty('LookupRoot', 'TComponent', iptr);
    RegisterProperty('Ancestor', 'TPersistent', iptrw);
    RegisterProperty('IgnoreChildren', 'Boolean', iptrw);
  end;
end;

procedure SIRegister_TStreamAdapter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TInterfacedObject', 'TStreamAdapter') do
  with CL.AddClass(CL.FindClass('TInterfacedObject'), TStreamAdapter) do
  begin
    RegisterMethod('Constructor Create( Stream : TStream; Ownership : TStreamOwnership)');
    RegisterMethod('Function Read( pv : Pointer; cb : Longint; pcbRead : PLongint) : HResult');
    RegisterMethod('Function Write( pv : Pointer; cb : Longint; pcbWritten : PLongint) : HResult');
    RegisterMethod('Function Seek( dlibMove : Largeint; dwOrigin : Longint; out libNewPosition : Largeint) : HResult');
    RegisterMethod('Function SetSize( libNewSize : Largeint) : HResult');
    RegisterMethod('Function CopyTo( stm : IStream; cb : Largeint; out cbRead : Largeint; out cbWritten : Largeint) : HResult');
    RegisterMethod('Function Commit( grfCommitFlags : Longint) : HResult');
    RegisterMethod('Function Revert : HResult');
    RegisterMethod('Function LockRegion( libOffset : Largeint; cb : Largeint; dwLockType : Longint) : HResult');
    RegisterMethod('Function UnlockRegion( libOffset : Largeint; cb : Largeint; dwLockType : Longint) : HResult');
    RegisterMethod('Function Stat( out statstg : TStatStg; grfStatFlag : Longint) : HResult');
    RegisterMethod('Function Clone( out stm : IStream) : HResult');
    RegisterProperty('Stream', 'TStream', iptr);
    RegisterProperty('StreamOwnership', 'TStreamOwnership', iptrw);
  end;
end;

procedure SIRegister_TResourceStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomMemoryStream', 'TResourceStream') do
  with CL.AddClass(CL.FindClass('TCustomMemoryStream'), TResourceStream) do
  begin
    RegisterMethod('Constructor Create( Instance : THandle; const ResName : string; ResType : PChar)');
    RegisterMethod('Constructor CreateFromID( Instance : THandle; ResID : Integer; ResType : PChar)');
  end;
end;

procedure SIRegister_TStringStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TStream', 'TStringStream') do
  with CL.AddClass(CL.FindClass('TStream'), TStringStream) do
  begin
    RegisterMethod('Constructor Create( const AString : string)');
    RegisterMethod('Function ReadString( Count : Longint) : string');
    RegisterMethod('Procedure WriteString( const AString : string)');
    RegisterProperty('DataString', 'string', iptr);
  end;
end;

procedure SIRegister_TMemoryStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomMemoryStream', 'TMemoryStream') do
  with CL.AddClass(CL.FindClass('TCustomMemoryStream'), TMemoryStream) do
  begin
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure LoadFromStream( Stream : TStream)');
    RegisterMethod('Procedure LoadFromFile( const FileName : string)');
  end;
end;

procedure SIRegister_TCustomMemoryStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TStream', 'TCustomMemoryStream') do
  with CL.AddClass(CL.FindClass('TStream'), TCustomMemoryStream) do
  begin
    RegisterMethod('Procedure SaveToStream( Stream : TStream)');
    RegisterMethod('Procedure SaveToFile( const FileName : string)');
    RegisterProperty('Memory', 'Pointer', iptr);
  end;
end;

procedure SIRegister_TFileStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'THandleStream', 'TFileStream') do
  with CL.AddClass(CL.FindClass('THandleStream'), TFileStream) do
  begin
    RegisterMethod('Constructor Create( const FileName : string; Mode : Word)');
  end;
end;

procedure SIRegister_THandleStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TStream', 'THandleStream') do
  with CL.AddClass(CL.FindClass('TStream'), THandleStream) do
  begin
    RegisterMethod('Constructor Create( AHandle : Integer)');
    RegisterProperty('Handle', 'Integer', iptr);
  end;
end;

procedure SIRegister_TStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TStream') do
  with CL.AddClass(CL.FindClass('TObject'), TStream) do
  begin
    RegisterMethod('Function Read( Buffer : Pointer; Count : Longint) : Longint');
    RegisterMethod('Function Write( Buffer : Pointer; Count : Longint) : Longint');
    RegisterMethod('Function Seek( Offset : Longint; Origin : Word) : Longint');
    RegisterMethod('Procedure ReadBuffer( Buffer : Pointer; Count : Longint)');
    RegisterMethod('Procedure WriteBuffer( Buffer : Pointer; Count : Longint)');
    RegisterMethod('Function CopyFrom( Source : TStream; Count : Longint) : Longint');
    RegisterMethod('Function ReadComponent( Instance : TComponent) : TComponent');
    RegisterMethod('Function ReadComponentRes( Instance : TComponent) : TComponent');
    RegisterMethod('Procedure WriteComponent( Instance : TComponent)');
    RegisterMethod('Procedure WriteComponentRes( const ResName : string; Instance : TComponent)');
    RegisterMethod('Procedure WriteDescendent( Instance, Ancestor : TComponent)');
    RegisterMethod('Procedure WriteDescendentRes( const ResName : string; Instance, Ancestor : TComponent)');
    RegisterMethod('Procedure WriteResourceHeader( const ResName : string; out FixupInfo : Integer)');
    RegisterMethod('Procedure FixupResourceHeader( FixupInfo : Integer)');
    RegisterMethod('Procedure ReadResHeader');
    RegisterProperty('Position', 'Longint', iptrw);
    RegisterProperty('Size', 'Longint', iptrw);
  end;
end;

procedure SIRegister_TStringList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TStrings', 'TStringList') do
  with CL.AddClass(CL.FindClass('TStrings'), TStringList) do
  begin
    RegisterMethod('Function Find( const S : string; var Index : Integer) : Boolean');
    RegisterMethod('Procedure Sort');
    RegisterMethod('Procedure CustomSort( Compare : TStringListSortCompare)');
    RegisterProperty('Duplicates', 'TDuplicates', iptrw);
    RegisterProperty('Sorted', 'Boolean', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnChanging', 'TNotifyEvent', iptrw);
  end;
end;

procedure SIRegister_TStrings(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TStrings') do
  with CL.AddClass(CL.FindClass('TPersistent'), TStrings) do
  begin
    RegisterMethod('Function Add( const S : string) : Integer');
    RegisterMethod('Function AddObject( const S : string; AObject : TObject) : Integer');
    RegisterMethod('Procedure Append( const S : string)');
    RegisterMethod('Procedure AddStrings( Strings : TStrings)');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function Equals( Strings : TStrings) : Boolean');
    RegisterMethod('Procedure Exchange( Index1, Index2 : Integer)');
    RegisterMethod('Function GetText : PChar');
    RegisterMethod('Function IndexOf( const S : string) : Integer');
    RegisterMethod('Function IndexOfName( const Name : string) : Integer');
    RegisterMethod('Function IndexOfObject( AObject : TObject) : Integer');
    RegisterMethod('Procedure Insert( Index : Integer; const S : string)');
    RegisterMethod('Procedure InsertObject( Index : Integer; const S : string; AObject : TObject)');
    RegisterMethod('Procedure LoadFromFile( const FileName : string)');
    RegisterMethod('Procedure LoadFromStream( Stream : TStream)');
    RegisterMethod('Procedure Move( CurIndex, NewIndex : Integer)');
    RegisterMethod('Procedure SaveToFile( const FileName : string)');
    RegisterMethod('Procedure SaveToStream( Stream : TStream)');
    RegisterMethod('Procedure SetText( Text : PChar)');
    RegisterProperty('Capacity', 'Integer', iptrw);
    RegisterProperty('CommaText', 'string', iptrw);
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Names', 'string Integer', iptr);
    RegisterProperty('Objects', 'TObject Integer', iptrw);
    RegisterProperty('Values', 'string string', iptrw);
    RegisterProperty('ValueFromIndex', 'Integer string', iptrw);
    RegisterProperty('Strings', 'string Integer', iptrw);
    SetDefaultPropery('Strings');
    RegisterProperty('Text', 'string', iptrw);
    RegisterProperty('StringsAdapter', 'IStringsAdapter', iptrw);
  end;
end;

procedure SIRegister_IStringsAdapter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IStringsAdapter') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IStringsAdapter, 'IStringsAdapter') do
  begin
    RegisterMethod('Procedure ReferenceStrings( S : TStrings)', cdRegister);
    RegisterMethod('Procedure ReleaseStrings', cdRegister);
  end;
end;

procedure SIRegister_TOwnedCollection(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCollection', 'TOwnedCollection') do
  with CL.AddClass(CL.FindClass('TCollection'), TOwnedCollection) do
  begin
  end;
end;

procedure SIRegister_TCollection(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TCollection') do
  with CL.AddClass(CL.FindClass('TPersistent'), TCollection) do
  begin
    RegisterMethod('Function Add : TCollectionItem');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function FindItemID( ID : Integer) : TCollectionItem');
    RegisterMethod('Function Insert( Index : Integer) : TCollectionItem');
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Items', 'TCollectionItem Integer', iptrw);
  end;
end;

procedure SIRegister_TCollectionItem(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TPersistent', 'TCollectionItem') do
  with CL.AddClass(CL.FindClass('TPersistent'), TCollectionItem) do
  begin
    RegisterMethod('Constructor Create( Collection : TCollection)');
    RegisterProperty('Collection', 'TCollection', iptrw);
    RegisterProperty('ID', 'Integer', iptr);
    RegisterProperty('Index', 'Integer', iptrw);
    RegisterProperty('DisplayName', 'string', iptrw);
  end;
end;

procedure SIRegister_TPersistent(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TPersistent') do
  with CL.AddClass(CL.FindClass('TObject'), TPersistent) do
  begin
    RegisterMethod('Procedure Assign( Source : TPersistent)');
    RegisterMethod('Function GetNamePath : string');
    // 注意 GetNamePath 是 dynamic 方法不是 virtual 方法，脚本引擎目前
    // 无法拿到正确的 GetNamePath 入口地址，注册了也不能调用这方法
  end;
end;

procedure SIRegister_TBits(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TBits') do
  with CL.AddClass(CL.FindClass('TObject'), TBits) do
  begin
    RegisterMethod('Function OpenBit : Integer');
    RegisterProperty('Bits', 'Boolean Integer', iptrw);
    SetDefaultPropery('Bits');
    RegisterProperty('Size', 'Integer', iptrw);
  end;
end;

procedure SIRegister_TInterfaceList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TInterfacedObject', 'TInterfaceList') do
  with CL.AddClass(CL.FindClass('TInterfacedObject'), TInterfaceList) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure Exchange( Index1, Index2 : Integer)');
    RegisterMethod('Function Expand : TInterfaceList');
    RegisterMethod('Function First : IUnknown');
    RegisterMethod('Function IndexOf( Item : IUnknown) : Integer');
    RegisterMethod('Function Add( Item : IUnknown) : Integer');
    RegisterMethod('Procedure Insert( Index : Integer; Item : IUnknown)');
    RegisterMethod('Function Last : IUnknown');
    RegisterMethod('Function Remove( Item : IUnknown) : Integer');
    RegisterMethod('Procedure Lock');
    RegisterMethod('Procedure Unlock');
    RegisterProperty('Capacity', 'Integer', iptrw);
    RegisterProperty('Count', 'Integer', iptrw);
    RegisterProperty('Items', 'IUnknown Integer', iptrw);
    SetDefaultPropery('Items');
  end;
end;

procedure SIRegister_IInterfaceList(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IInterfaceList') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IInterfaceList, 'IInterfaceList') do
  begin
    RegisterMethod('Function Get( Index : Integer) : IUnknown', cdRegister);
    RegisterMethod('Function GetCapacity : Integer', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Procedure Put( Index : Integer; Item : IUnknown)', cdRegister);
    RegisterMethod('Procedure SetCapacity( NewCapacity : Integer)', cdRegister);
    RegisterMethod('Procedure SetCount( NewCount : Integer)', cdRegister);
    RegisterMethod('Procedure Clear', cdRegister);
    RegisterMethod('Procedure Delete( Index : Integer)', cdRegister);
    RegisterMethod('Procedure Exchange( Index1, Index2 : Integer)', cdRegister);
    RegisterMethod('Function First : IUnknown', cdRegister);
    RegisterMethod('Function IndexOf( Item : IUnknown) : Integer', cdRegister);
    RegisterMethod('Function Add( Item : IUnknown) : Integer', cdRegister);
    RegisterMethod('Procedure Insert( Index : Integer; Item : IUnknown)', cdRegister);
    RegisterMethod('Function Last : IUnknown', cdRegister);
    RegisterMethod('Function Remove( Item : IUnknown) : Integer', cdRegister);
    RegisterMethod('Procedure Lock', cdRegister);
    RegisterMethod('Procedure Unlock', cdRegister);
  end;
end;

procedure SIRegister_TList(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TList') do
  with CL.AddClass(CL.FindClass('TObject'), TList) do
  begin
    RegisterMethod('Function Add( Item : Pointer) : Integer');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure Exchange( Index1, Index2 : Integer)');
    RegisterMethod('Function Expand : TList');
    RegisterMethod('Function Extract( Item : Pointer) : Pointer');
    RegisterMethod('Function First : Pointer');
    RegisterMethod('Function IndexOf( Item : Pointer) : Integer');
    RegisterMethod('Procedure Insert( Index : Integer; Item : Pointer)');
    RegisterMethod('Function Last : Pointer');
    RegisterMethod('Procedure Move( CurIndex, NewIndex : Integer)');
    RegisterMethod('Function Remove( Item : Pointer) : Integer');
    RegisterMethod('Procedure Pack');
    RegisterMethod('Procedure Sort( Compare : TListSortCompare)');
    RegisterProperty('Capacity', 'Integer', iptrw);
    RegisterProperty('Count', 'Integer', iptrw);
    RegisterProperty('Items', 'Pointer Integer', iptrw);
    SetDefaultPropery('Items');
  end;
end;

procedure SIRegister_Classes(CL: TPSPascalCompiler);
begin
  CL.AddConstantN('soFromBeginning', 'LongInt').SetInt(0);
  CL.AddConstantN('soFromCurrent', 'LongInt').SetInt(1);
  CL.AddConstantN('soFromEnd', 'LongInt').SetInt(2);
  CL.AddConstantN('fmCreate', 'LongWord').SetUInt($FFFF);
  CL.AddConstantN('toEOF', 'Char').SetChar(Char(0));
  CL.AddConstantN('toSymbol', 'Char').SetChar(Char(1));
  CL.AddConstantN('toString', 'Char').SetChar(Char(2));
  CL.AddConstantN('toInteger', 'Char').SetChar(Char(3));
  CL.AddConstantN('toFloat', 'Char').SetChar(Char(4));
  CL.AddConstantN('toWString', 'Char').SetChar(Char(5));
  CL.AddConstantN('scShift', 'LongWord').SetUInt($2000);
  CL.AddConstantN('scCtrl', 'LongWord').SetUInt($4000);
  CL.AddConstantN('scAlt', 'LongWord').SetUInt($8000);
  CL.AddConstantN('scNone', 'LongWord').SetUInt(0);
  CL.AddTypeS('TAlignment', '( taLeftJustify, taRightJustify, taCenter )');
  CL.AddTypeS('TLeftRight', 'TAlignment');
  CL.AddTypeS('TBiDiMode', '( bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlig'
    + 'n, bdRightToLeftReadingOnly )');
  CL.AddTypeS('TShiftStateE', '( ssShift, ssAlt, ssCtrl, ssLeft, ssRight,'
    + ' ssMiddle, ssDouble )');
  CL.AddTypeS('TShiftState', 'set of TShiftStateE');
  CL.AddTypeS('THelpContext', 'Integer');
  CL.AddTypeS('TShortCut', 'Word');
  CL.AddTypeS('TNotifyEvent', 'Procedure ( Sender : TObject)');
  CL.AddTypeS('THelpEvent', 'Function ( Command : Word; Data : Longint; var Cal'
    + 'lHelp : Boolean) : Boolean');
  CL.AddTypeS('TGetStrProc', 'Procedure ( const S : string)');
  CL.AddTypeS('TDuplicates', '( dupIgnore, dupAccept, dupError )');
  CL.AddClass(CL.FindClass('TObject'), TStream);
  CL.AddClass(CL.FindClass('TObject'), TFiler);
  CL.AddClass(CL.FindClass('TFiler'), TReader);
  CL.AddClass(CL.FindClass('TFiler'), TWriter);
  CL.AddClass(CL.FindClass('TObject'), TPersistent);
  CL.AddClass(CL.FindClass('TPersistent'), TComponent);
  CL.AddTypeS('TListNotification', '( lnAdded, lnExtracted, lnDeleted )');
  SIRegister_TList(CL);
  SIRegister_IInterfaceList(CL);
  SIRegister_TInterfaceList(CL);
  SIRegister_TBits(CL);
  SIRegister_TPersistent(CL);
  //CL.AddTypeS('TPersistentClass', 'class of TPersistent');
  CL.AddClass(CL.FindClass('TPersistent'), TCollection);
  SIRegister_TCollectionItem(CL);
  //CL.AddTypeS('TCollectionItemClass', 'class of TCollectionItem');
  SIRegister_TCollection(CL);
  SIRegister_TOwnedCollection(CL);
  CL.AddClass(CL.FindClass('TPersistent'), TStrings);
  SIRegister_IStringsAdapter(CL);
  SIRegister_TStrings(CL);
  CL.AddClass(CL.FindClass('TStrings'), TStringList);
  SIRegister_TStringList(CL);
  SIRegister_TStream(CL);
  SIRegister_THandleStream(CL);
  SIRegister_TFileStream(CL);
  SIRegister_TCustomMemoryStream(CL);
  SIRegister_TMemoryStream(CL);
  SIRegister_TStringStream(CL);
  SIRegister_TResourceStream(CL);
  CL.AddTypeS('TStreamOwnership', '( soReference, soOwned )');
  SIRegister_TStreamAdapter(CL);
  CL.AddTypeS('TValueType', '( vaNull, vaList, vaInt8, vaInt16, vaInt32, vaExte'
    + 'nded, vaString, vaIdent, vaFalse, vaTrue, vaBinary, vaSet, vaLString, vaNi'
    + 'l, vaCollection, vaSingle, vaCurrency, vaDate, vaWString, vaInt64 )');
  CL.AddTypeS('TFilerFlag', '( ffInherited, ffChildPos, ffInline )');
  CL.AddTypeS('TFilerFlags', 'set of TFilerFlag');
  CL.AddTypeS('TReaderProc', 'Procedure ( Reader : TReader)');
  CL.AddTypeS('TWriterProc', 'Procedure ( Writer : TWriter)');
  CL.AddTypeS('TStreamProc', 'Procedure ( Stream : TStream)');
  SIRegister_TFiler(CL);
  //CL.AddTypeS('TComponentClass', 'class of TComponent');
  CL.AddTypeS('TFindMethodEvent', 'Procedure ( Reader : TReader; const MethodNa'
    + 'me : string; var Address : Pointer; var Error : Boolean)');
  CL.AddTypeS('TSetNameEvent', 'Procedure ( Reader : TReader; Component : TComp'
    + 'onent; var Name : string)');
  CL.AddTypeS('TReferenceNameEvent', 'Procedure ( Reader : TReader; var Name : '
    + 'string)');
  CL.AddTypeS('TReadComponentsProc', 'Procedure ( Component : TComponent)');
  CL.AddTypeS('TReaderError', 'Procedure ( Reader : TReader; const Message : st'
    + 'ring; var Handled : Boolean)');
  SIRegister_TReader(CL);
  CL.AddTypeS('TFindAncestorEvent', 'Procedure ( Writer : TWriter; Component : '
    + 'TComponent; const Name : string; var Ancestor, RootAncestor : TComponent)');
  SIRegister_TWriter(CL);
  SIRegister_TParser(CL);
  CL.AddTypeS('TOperation', '( opInsert, opRemove )');
  CL.AddTypeS('TComponentStateE', '( csLoading, csReading, csWriting, csD'
    + 'estroying, csDesigning, csAncestor, csUpdating, csFixups, csFreeNotificati'
    + 'on, csInline, csDesignInstance )');
  CL.AddTypeS('TComponentState', 'TComponentStateE');
  CL.AddTypeS('TComponentStyleE', '( csInheritable, csCheckPropAvail )');
  CL.AddTypeS('TComponentStyle', 'set of TComponentStyleE');
  CL.AddTypeS('TGetChildProc', 'Procedure ( Child : TComponent)');
  CL.AddTypeS('TComponentName', 'string');
  SIRegister_IVCLComObject(CL);
  SIRegister_IDesignerNotify(CL);
  CL.AddClass(CL.FindClass('TComponent'), TBasicAction);
  SIRegister_TComponent(CL);
  SIRegister_TBasicActionLink(CL);
  //CL.AddTypeS('TBasicActionLinkClass', 'class of TBasicActionLink');
  SIRegister_TBasicAction(CL);
  //CL.AddTypeS('TBasicActionClass', 'class of TBasicAction');
  CL.AddDelphiFunction('Function Point( AX, AY : Integer) : TPoint');
  CL.AddDelphiFunction('Function SmallPoint( AX, AY : SmallInt) : TSmallPoint');
  CL.AddDelphiFunction('Function Rect( ALeft, ATop, ARight, ABottom : Integer) : TRect');
  CL.AddDelphiFunction('Function Bounds( ALeft, ATop, AWidth, AHeight : Integer) : TRect');
  CL.AddTypeS('TIdentMapEntry', 'record Value : Integer; Name : String; end');
  CL.AddDelphiFunction('Function FindGlobalComponent( const Name: string) : TComponent;');
  CL.AddDelphiFunction('Function CollectionsEqual( C1, C2 : TCollection) : Boolean');
  CL.AddTypeS('TStreamOriginalFormat', '( sofUnknown, sofBinary, sofText )');
  CL.AddDelphiFunction('Procedure ObjectBinaryToText( Input, Output : TStream; var OriginalFormat : TStreamOriginalFormat);');
  CL.AddDelphiFunction('Procedure ObjectTextToBinary( Input, Output : TStream; var OriginalFormat : TStreamOriginalFormat);');
  CL.AddDelphiFunction('Procedure ObjectResourceToText( Input, Output : TStream; var OriginalFormat : TStreamOriginalFormat);');
  CL.AddDelphiFunction('Procedure ObjectTextToResource( Input, Output : TStream; var OriginalFormat : TStreamOriginalFormat);');
  CL.AddDelphiFunction('Function TestStreamFormat( Stream : TStream) : TStreamOriginalFormat');
  CL.AddDelphiFunction('Function LineStart( Buffer, BufPos : PChar) : PChar');
  CL.AddDelphiFunction('Function ExtractStrings( Separators, WhiteSpace : TSysCharSet; Content : PChar; Strings : TStrings) : Integer');
  CL.AddDelphiFunction('Procedure BinToHex( Buffer, Text : PChar; BufSize : Integer)');
  CL.AddDelphiFunction('Function HexToBin( Text, Buffer : PChar; BufSize : Integer) : Integer');
  CL.AddDelphiFunction('Function FindRootDesigner( Obj : TPersistent) : IDesignerNotify');
{$IFDEF BDS2012_UP}
  CL.AddDelphiFunction('Procedure ReportClassGroups( Report : TStrings);');
{$ENDIF}
end;

(* === run-time registration functions === *)
procedure ObjectTextToResource_P(Input, Output: TStream; var OriginalFormat: TStreamOriginalFormat);
begin
  Classes.ObjectTextToResource(Input, Output, OriginalFormat);
end;

procedure ObjectResourceToText_P(Input, Output: TStream; var OriginalFormat: TStreamOriginalFormat);
begin
  Classes.ObjectResourceToText(Input, Output, OriginalFormat);
end;

procedure ObjectTextToBinary_P(Input, Output: TStream; var OriginalFormat: TStreamOriginalFormat);
begin
  Classes.ObjectTextToBinary(Input, Output, OriginalFormat);
end;

procedure ObjectBinaryToText_P(Input, Output: TStream; var OriginalFormat: TStreamOriginalFormat);
begin
  Classes.ObjectBinaryToText(Input, Output, OriginalFormat);
end;

function FindGlobalComponent_P(const Name: string): TComponent;
begin
{$IFDEF COMPILER6_UP}
  Result := Classes.FindGlobalComponent(Name);
{$ELSE}
  if @Classes.FindGlobalComponent <> nil then
    Result := Classes.FindGlobalComponent(Name)
  else
    Result := nil;
{$ENDIF}
end;

procedure TBasicActionOnUpdate_W(Self: TBasicAction; const T: TNotifyEvent);
begin
  Self.OnUpdate := T;
end;

procedure TBasicActionOnUpdate_R(Self: TBasicAction; var T: TNotifyEvent);
begin
  T := Self.OnUpdate;
end;

procedure TBasicActionOnExecute_W(Self: TBasicAction; const T: TNotifyEvent);
begin
  Self.OnExecute := T;
end;

procedure TBasicActionOnExecute_R(Self: TBasicAction; var T: TNotifyEvent);
begin
  T := Self.OnExecute;
end;

procedure TBasicActionLinkOnChange_W(Self: TBasicActionLink; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TBasicActionLinkOnChange_R(Self: TBasicActionLink; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TBasicActionLinkAction_W(Self: TBasicActionLink; const T: TBasicAction);
begin
  Self.Action := T;
end;

procedure TBasicActionLinkAction_R(Self: TBasicActionLink; var T: TBasicAction);
begin
  T := Self.Action;
end;

procedure TComponentTag_W(Self: TComponent; const T: Longint);
begin
  Self.Tag := T;
end;

procedure TComponentTag_R(Self: TComponent; var T: Longint);
begin
  T := Self.Tag;
end;

procedure TComponentName_W(Self: TComponent; const T: TComponentName);
begin
  Self.Name := T;
end;

procedure TComponentName_R(Self: TComponent; var T: TComponentName);
begin
  T := Self.Name;
end;

procedure TComponentVCLComObject_W(Self: TComponent; const T: Pointer);
begin
  Self.VCLComObject := T;
end;

procedure TComponentVCLComObject_R(Self: TComponent; var T: Pointer);
begin
  T := Self.VCLComObject;
end;

procedure TComponentOwner_R(Self: TComponent; var T: TComponent);
begin
  T := Self.Owner;
end;

procedure TComponentDesignInfo_W(Self: TComponent; const T: Longint);
begin
  Self.DesignInfo := T;
end;

procedure TComponentDesignInfo_R(Self: TComponent; var T: Longint);
begin
  T := Self.DesignInfo;
end;

procedure TComponentComponentStyle_R(Self: TComponent; var T: TComponentStyle);
begin
  T := Self.ComponentStyle;
end;

procedure TComponentComponentState_R(Self: TComponent; var T: TComponentState);
begin
  T := Self.ComponentState;
end;

procedure TComponentComponentIndex_W(Self: TComponent; const T: Integer);
begin
  Self.ComponentIndex := T;
end;

procedure TComponentComponentIndex_R(Self: TComponent; var T: Integer);
begin
  T := Self.ComponentIndex;
end;

procedure TComponentComponentCount_R(Self: TComponent; var T: Integer);
begin
  T := Self.ComponentCount;
end;

procedure TComponentComponents_R(Self: TComponent; var T: TComponent; const t1: Integer);
begin
  T := Self.Components[t1];
end;

procedure TComponentComObject_R(Self: TComponent; var T: IUnknown);
begin
  T := Self.ComObject;
end;

procedure TParserToken_R(Self: TParser; var T: Char);
begin
  T := Self.Token;
end;

procedure TParserSourceLine_R(Self: TParser; var T: Integer);
begin
  T := Self.SourceLine;
end;

procedure TParserFloatType_R(Self: TParser; var T: Char);
begin
  T := Self.FloatType;
end;

procedure TWriterOnFindAncestor_W(Self: TWriter; const T: TFindAncestorEvent);
begin
  Self.OnFindAncestor := T;
end;

procedure TWriterOnFindAncestor_R(Self: TWriter; var T: TFindAncestorEvent);
begin
  T := Self.OnFindAncestor;
end;

procedure TWriterRootAncestor_W(Self: TWriter; const T: TComponent);
begin
  Self.RootAncestor := T;
end;

procedure TWriterRootAncestor_R(Self: TWriter; var T: TComponent);
begin
  T := Self.RootAncestor;
end;

procedure TWriterPosition_W(Self: TWriter; const T: Longint);
begin
  Self.Position := T;
end;

procedure TWriterPosition_R(Self: TWriter; var T: Longint);
begin
  T := Self.Position;
end;

procedure TWriterWriteInt64_P(Self: TWriter; Value: Int64);
begin
  Self.WriteInteger(Value);
end;

procedure TWriterWriteInteger_P(Self: TWriter; Value: Longint);
begin
  Self.WriteInteger(Value);
end;

procedure TReaderOnReferenceName_W(Self: TReader; const T: TReferenceNameEvent);
begin
  Self.OnReferenceName := T;
end;

procedure TReaderOnReferenceName_R(Self: TReader; var T: TReferenceNameEvent);
begin
  T := Self.OnReferenceName;
end;

procedure TReaderOnSetName_W(Self: TReader; const T: TSetNameEvent);
begin
  Self.OnSetName := T;
end;

procedure TReaderOnSetName_R(Self: TReader; var T: TSetNameEvent);
begin
  T := Self.OnSetName;
end;

procedure TReaderOnFindMethod_W(Self: TReader; const T: TFindMethodEvent);
begin
  Self.OnFindMethod := T;
end;

procedure TReaderOnFindMethod_R(Self: TReader; var T: TFindMethodEvent);
begin
  T := Self.OnFindMethod;
end;

procedure TReaderOnError_W(Self: TReader; const T: TReaderError);
begin
  Self.OnError := T;
end;

procedure TReaderOnError_R(Self: TReader; var T: TReaderError);
begin
  T := Self.OnError;
end;

procedure TReaderPosition_W(Self: TReader; const T: Longint);
begin
  Self.Position := T;
end;

procedure TReaderPosition_R(Self: TReader; var T: Longint);
begin
  T := Self.Position;
end;

procedure TReaderParent_W(Self: TReader; const T: TComponent);
begin
  Self.Parent := T;
end;

procedure TReaderParent_R(Self: TReader; var T: TComponent);
begin
  T := Self.Parent;
end;

procedure TReaderOwner_W(Self: TReader; const T: TComponent);
begin
  Self.Owner := T;
end;

procedure TReaderOwner_R(Self: TReader; var T: TComponent);
begin
  T := Self.Owner;
end;

procedure TFilerIgnoreChildren_W(Self: TFiler; const T: Boolean);
begin
  Self.IgnoreChildren := T;
end;

procedure TFilerIgnoreChildren_R(Self: TFiler; var T: Boolean);
begin
  T := Self.IgnoreChildren;
end;

procedure TFilerAncestor_W(Self: TFiler; const T: TPersistent);
begin
  Self.Ancestor := T;
end;

procedure TFilerAncestor_R(Self: TFiler; var T: TPersistent);
begin
  T := Self.Ancestor;
end;

procedure TFilerLookupRoot_R(Self: TFiler; var T: TComponent);
begin
  T := Self.LookupRoot;
end;

procedure TFilerRoot_W(Self: TFiler; const T: TComponent);
begin
  Self.Root := T;
end;

procedure TFilerRoot_R(Self: TFiler; var T: TComponent);
begin
  T := Self.Root;
end;

procedure TStreamAdapterStreamOwnership_W(Self: TStreamAdapter; const T: TStreamOwnership);
begin
  Self.StreamOwnership := T;
end;

procedure TStreamAdapterStreamOwnership_R(Self: TStreamAdapter; var T: TStreamOwnership);
begin
  T := Self.StreamOwnership;
end;

procedure TStreamAdapterStream_R(Self: TStreamAdapter; var T: TStream);
begin
  T := Self.Stream;
end;

procedure TStringStreamDataString_R(Self: TStringStream; var T: string);
begin
  T := Self.DataString;
end;

procedure TCustomMemoryStreamMemory_R(Self: TCustomMemoryStream; var T: Pointer);
begin
  T := Self.Memory;
end;

procedure THandleStreamHandle_R(Self: THandleStream; var T: Integer);
begin
  T := Self.Handle;
end;

procedure TStreamSize_W(Self: TStream; const T: Longint);
begin
  Self.Size := T;
end;

procedure TStreamSize_R(Self: TStream; var T: Longint);
begin
  T := Self.Size;
end;

procedure TStreamPosition_W(Self: TStream; const T: Longint);
begin
  Self.Position := T;
end;

procedure TStreamPosition_R(Self: TStream; var T: Longint);
begin
  T := Self.Position;
end;

procedure TStringListOnChanging_W(Self: TStringList; const T: TNotifyEvent);
begin
  Self.OnChanging := T;
end;

procedure TStringListOnChanging_R(Self: TStringList; var T: TNotifyEvent);
begin
  T := Self.OnChanging;
end;

procedure TStringListOnChange_W(Self: TStringList; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TStringListOnChange_R(Self: TStringList; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TStringListSorted_W(Self: TStringList; const T: Boolean);
begin
  Self.Sorted := T;
end;

procedure TStringListSorted_R(Self: TStringList; var T: Boolean);
begin
  T := Self.Sorted;
end;

procedure TStringListDuplicates_W(Self: TStringList; const T: TDuplicates);
begin
  Self.Duplicates := T;
end;

procedure TStringListDuplicates_R(Self: TStringList; var T: TDuplicates);
begin
  T := Self.Duplicates;
end;

procedure TStringsStringsAdapter_W(Self: TStrings; const T: IStringsAdapter);
begin
  Self.StringsAdapter := T;
end;

procedure TStringsStringsAdapter_R(Self: TStrings; var T: IStringsAdapter);
begin
  T := Self.StringsAdapter;
end;

procedure TStringsText_W(Self: TStrings; const T: string);
begin
  Self.Text := T;
end;

procedure TStringsText_R(Self: TStrings; var T: string);
begin
  T := Self.Text;
end;

procedure TStringsStrings_W(Self: TStrings; const T: string; const t1: Integer);
begin
  Self.Strings[t1] := T;
end;

procedure TStringsStrings_R(Self: TStrings; var T: string; const t1: Integer);
begin
  T := Self.Strings[t1];
end;

procedure TStringsValueFromIndex_W(Self: TStrings; const T: string; const t1: Integer);
{$IFNDEF COMPILER7_UP}
var
  Index: Integer;
{$ENDIF}
begin
{$IFDEF COMPILER7_UP}
  Self.ValueFromIndex[t1] := T;
{$ELSE}
  Index := t1;
  if T <> '' then
  begin
    if Index < 0 then Index := Self.Add('');
    Self[Index] := Self.Names[Index] + '=' + T;
  end
  else
    if Index >= 0 then Self.Delete(Index);
{$ENDIF}
end;

procedure TStringsValueFromIndex_R(Self: TStrings; var T: string; const t1: Integer);
begin
{$IFDEF COMPILER7_UP}
  T := Self.ValueFromIndex[t1];
{$ELSE}
  if t1 >= 0 then
    T := Copy(Self[t1], Length(Self.Names[t1]) + 2, MaxInt)
  else
    T := '';
{$ENDIF}
end;

procedure TStringsValues_W(Self: TStrings; const T: string; const t1: string);
begin
  Self.Values[t1] := T;
end;

procedure TStringsValues_R(Self: TStrings; var T: string; const t1: string);
begin
  T := Self.Values[t1];
end;

procedure TStringsObjects_W(Self: TStrings; const T: TObject; const t1: Integer);
begin
  Self.Objects[t1] := T;
end;

procedure TStringsObjects_R(Self: TStrings; var T: TObject; const t1: Integer);
begin
  T := Self.Objects[t1];
end;

procedure TStringsNames_R(Self: TStrings; var T: string; const t1: Integer);
begin
  T := Self.Names[t1];
end;

procedure TStringsCount_R(Self: TStrings; var T: Integer);
begin
  T := Self.Count;
end;

procedure TStringsCommaText_W(Self: TStrings; const T: string);
begin
  Self.CommaText := T;
end;

procedure TStringsCommaText_R(Self: TStrings; var T: string);
begin
  T := Self.CommaText;
end;

procedure TStringsCapacity_W(Self: TStrings; const T: Integer);
begin
  Self.Capacity := T;
end;

procedure TStringsCapacity_R(Self: TStrings; var T: Integer);
begin
  T := Self.Capacity;
end;

procedure TCollectionItems_W(Self: TCollection; const T: TCollectionItem; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TCollectionItems_R(Self: TCollection; var T: TCollectionItem; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TCollectionCount_R(Self: TCollection; var T: Integer);
begin
  T := Self.Count;
end;

procedure TCollectionItemDisplayName_W(Self: TCollectionItem; const T: string);
begin
  Self.DisplayName := T;
end;

procedure TCollectionItemDisplayName_R(Self: TCollectionItem; var T: string);
begin
  T := Self.DisplayName;
end;

procedure TCollectionItemIndex_W(Self: TCollectionItem; const T: Integer);
begin
  Self.Index := T;
end;

procedure TCollectionItemIndex_R(Self: TCollectionItem; var T: Integer);
begin
  T := Self.Index;
end;

procedure TCollectionItemID_R(Self: TCollectionItem; var T: Integer);
begin
  T := Self.ID;
end;

procedure TCollectionItemCollection_W(Self: TCollectionItem; const T: TCollection);
begin
  Self.Collection := T;
end;

procedure TCollectionItemCollection_R(Self: TCollectionItem; var T: TCollection);
begin
  T := Self.Collection;
end;

procedure TBitsSize_W(Self: TBits; const T: Integer);
begin
  Self.Size := T;
end;

procedure TBitsSize_R(Self: TBits; var T: Integer);
begin
  T := Self.Size;
end;

procedure TBitsBits_W(Self: TBits; const T: Boolean; const t1: Integer);
begin
  Self.Bits[t1] := T;
end;

procedure TBitsBits_R(Self: TBits; var T: Boolean; const t1: Integer);
begin
  T := Self.Bits[t1];
end;

procedure TInterfaceListItems_W(Self: TInterfaceList; const T: IUnknown; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TInterfaceListItems_R(Self: TInterfaceList; var T: IUnknown; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TInterfaceListCount_W(Self: TInterfaceList; const T: Integer);
begin
  Self.Count := T;
end;

procedure TInterfaceListCount_R(Self: TInterfaceList; var T: Integer);
begin
  T := Self.Count;
end;

procedure TInterfaceListCapacity_W(Self: TInterfaceList; const T: Integer);
begin
  Self.Capacity := T;
end;

procedure TInterfaceListCapacity_R(Self: TInterfaceList; var T: Integer);
begin
  T := Self.Capacity;
end;

procedure TListItems_W(Self: TList; const T: Pointer; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TListItems_R(Self: TList; var T: Pointer; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TListCount_W(Self: TList; const T: Integer);
begin
  Self.Count := T;
end;

procedure TListCount_R(Self: TList; var T: Integer);
begin
  T := Self.Count;
end;

procedure TListCapacity_W(Self: TList; const T: Integer);
begin
  Self.Capacity := T;
end;

procedure TListCapacity_R(Self: TList; var T: Integer);
begin
  T := Self.Capacity;
end;

procedure RIRegister_Classes_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@Point, 'Point', cdRegister);
  S.RegisterDelphiFunction(@SmallPoint, 'SmallPoint', cdRegister);
  S.RegisterDelphiFunction(@Rect, 'Rect', cdRegister);
  S.RegisterDelphiFunction(@Bounds, 'Bounds', cdRegister);
  S.RegisterDelphiFunction(@FindGlobalComponent_P, 'FindGlobalComponent', cdRegister);
  S.RegisterDelphiFunction(@CollectionsEqual, 'CollectionsEqual', cdRegister);
  S.RegisterDelphiFunction(@ObjectBinaryToText_P, 'ObjectBinaryToText', cdRegister);
  S.RegisterDelphiFunction(@ObjectTextToBinary_P, 'ObjectTextToBinary', cdRegister);
  S.RegisterDelphiFunction(@ObjectResourceToText_P, 'ObjectResourceToText', cdRegister);
  S.RegisterDelphiFunction(@ObjectTextToResource_P, 'ObjectTextToResource', cdRegister);
  S.RegisterDelphiFunction(@TestStreamFormat, 'TestStreamFormat', cdRegister);
  S.RegisterDelphiFunction(@LineStart, 'LineStart', cdRegister);
  S.RegisterDelphiFunction(@ExtractStrings, 'ExtractStrings', cdRegister);
  S.RegisterDelphiFunction(@BinToHex, 'BinToHex', cdRegister);
  S.RegisterDelphiFunction(@HexToBin, 'HexToBin', cdRegister);
  S.RegisterDelphiFunction(@FindRootDesigner, 'FindRootDesigner', cdRegister);
{$IFDEF BDS2012_UP}
  S.RegisterDelphiFunction(@ReportClassGroups, 'ReportClassGroups', cdRegister);
{$ENDIF}
end;

procedure RIRegister_TBasicAction(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBasicAction) do
  begin
    RegisterVirtualMethod(@TBasicAction.HandlesTarget, 'HandlesTarget');
    RegisterVirtualMethod(@TBasicAction.UpdateTarget, 'UpdateTarget');
    RegisterVirtualMethod(@TBasicAction.ExecuteTarget, 'ExecuteTarget');
    RegisterVirtualMethod(@TBasicAction.Execute, 'Execute');
{$IFNDEF DELPHI101_BERLIN_UP}
    RegisterMethod(@TBasicAction.RegisterChanges, 'RegisterChanges');
    RegisterMethod(@TBasicAction.UnRegisterChanges, 'UnRegisterChanges');
{$ENDIF}
    RegisterVirtualMethod(@TBasicAction.Update, 'Update');
    RegisterPropertyHelper(@TBasicActionOnExecute_R, @TBasicActionOnExecute_W, 'OnExecute');
    RegisterPropertyHelper(@TBasicActionOnUpdate_R, @TBasicActionOnUpdate_W, 'OnUpdate');
  end;
end;

procedure RIRegister_TBasicActionLink(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBasicActionLink) do
  begin
    RegisterVirtualConstructor(@TBasicActionLink.Create, 'Create');
    RegisterVirtualMethod(@TBasicActionLink.Execute, 'Execute');
    RegisterVirtualMethod(@TBasicActionLink.Update, 'Update');
    RegisterPropertyHelper(@TBasicActionLinkAction_R, @TBasicActionLinkAction_W, 'Action');
    RegisterPropertyHelper(@TBasicActionLinkOnChange_R, @TBasicActionLinkOnChange_W, 'OnChange');
  end;
end;

procedure RIRegister_TComponent(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TComponent) do
  begin
    RegisterVirtualConstructor(@TComponent.Create, 'Create');
    RegisterMethod(@TComponent.DestroyComponents, 'DestroyComponents');
    RegisterMethod(@TComponent.Destroying, 'Destroying');
    RegisterVirtualMethod(@TComponent.ExecuteAction, 'ExecuteAction');
    RegisterMethod(@TComponent.FindComponent, 'FindComponent');
    RegisterMethod(@TComponent.FreeNotification, 'FreeNotification');
    RegisterMethod(@TComponent.RemoveFreeNotification, 'RemoveFreeNotification');
    RegisterMethod(@TComponent.FreeOnRelease, 'FreeOnRelease');
    RegisterVirtualMethod(@TComponent.GetParentComponent, 'GetParentComponent');
    RegisterVirtualMethod(@TComponent.HasParent, 'HasParent');
    RegisterMethod(@TComponent.InsertComponent, 'InsertComponent');
    RegisterMethod(@TComponent.RemoveComponent, 'RemoveComponent');
    RegisterVirtualMethod(@TComponent.UpdateAction, 'UpdateAction');
    RegisterPropertyHelper(@TComponentComObject_R, nil, 'ComObject');
    RegisterPropertyHelper(@TComponentComponents_R, nil, 'Components');
    RegisterPropertyHelper(@TComponentComponentCount_R, nil, 'ComponentCount');
    RegisterPropertyHelper(@TComponentComponentIndex_R, @TComponentComponentIndex_W, 'ComponentIndex');
    RegisterPropertyHelper(@TComponentComponentState_R, nil, 'ComponentState');
    RegisterPropertyHelper(@TComponentComponentStyle_R, nil, 'ComponentStyle');
    RegisterPropertyHelper(@TComponentDesignInfo_R, @TComponentDesignInfo_W, 'DesignInfo');
    RegisterPropertyHelper(@TComponentOwner_R, nil, 'Owner');
    RegisterPropertyHelper(@TComponentVCLComObject_R, @TComponentVCLComObject_W, 'VCLComObject');
    RegisterPropertyHelper(@TComponentName_R, @TComponentName_W, 'Name');
    RegisterPropertyHelper(@TComponentTag_R, @TComponentTag_W, 'Tag');
  end;
end;

procedure RIRegister_TParser(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TParser) do
  begin
    RegisterConstructor(@TParser.Create, 'Create');
    RegisterMethod(@TParser.CheckToken, 'CheckToken');
    RegisterMethod(@TParser.CheckTokenSymbol, 'CheckTokenSymbol');
    RegisterMethod(@TParser.Error, 'Error');
    RegisterMethod(@TParser.ErrorFmt, 'ErrorFmt');
    RegisterMethod(@TParser.ErrorStr, 'ErrorStr');
    RegisterMethod(@TParser.HexToBinary, 'HexToBinary');
    RegisterMethod(@TParser.NextToken, 'NextToken');
    RegisterMethod(@TParser.SourcePos, 'SourcePos');
    RegisterMethod(@TParser.TokenComponentIdent, 'TokenComponentIdent');
    RegisterMethod(@TParser.TokenFloat, 'TokenFloat');
    RegisterMethod(@TParser.TokenInt, 'TokenInt');
    RegisterMethod(@TParser.TokenString, 'TokenString');
    RegisterMethod(@TParser.TokenWideString, 'TokenWideString');
    RegisterMethod(@TParser.TokenSymbolIs, 'TokenSymbolIs');
    RegisterPropertyHelper(@TParserFloatType_R, nil, 'FloatType');
    RegisterPropertyHelper(@TParserSourceLine_R, nil, 'SourceLine');
    RegisterPropertyHelper(@TParserToken_R, nil, 'Token');
  end;
end;

procedure RIRegister_TWriter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TWriter) do
  begin
    RegisterMethod(@TWriter.Write, 'Write');
    RegisterMethod(@TWriter.WriteBoolean, 'WriteBoolean');
    RegisterMethod(@TWriter.WriteCollection, 'WriteCollection');
    RegisterMethod(@TWriter.WriteComponent, 'WriteComponent');
    RegisterMethod(@TWriter.WriteChar, 'WriteChar');
    RegisterMethod(@TWriter.WriteDescendent, 'WriteDescendent');
    RegisterMethod(@TWriter.WriteFloat, 'WriteFloat');
    RegisterMethod(@TWriter.WriteSingle, 'WriteSingle');
    RegisterMethod(@TWriter.WriteCurrency, 'WriteCurrency');
    RegisterMethod(@TWriter.WriteDate, 'WriteDate');
    RegisterMethod(@TWriter.WriteIdent, 'WriteIdent');
    RegisterMethod(@TWriterWriteInteger_P, 'WriteInteger');
    RegisterMethod(@TWriterWriteInt64_P, 'WriteInt64');
    RegisterMethod(@TWriter.WriteListBegin, 'WriteListBegin');
    RegisterMethod(@TWriter.WriteListEnd, 'WriteListEnd');
    RegisterMethod(@TWriter.WriteRootComponent, 'WriteRootComponent');
    RegisterMethod(@TWriter.WriteSignature, 'WriteSignature');
    RegisterMethod(@TWriter.WriteStr, 'WriteStr');
    RegisterMethod(@TWriter.WriteString, 'WriteString');
    RegisterMethod(@TWriter.WriteWideString, 'WriteWideString');
    RegisterPropertyHelper(@TWriterPosition_R, @TWriterPosition_W, 'Position');
    RegisterPropertyHelper(@TWriterRootAncestor_R, @TWriterRootAncestor_W, 'RootAncestor');
    RegisterPropertyHelper(@TWriterOnFindAncestor_R, @TWriterOnFindAncestor_W, 'OnFindAncestor');
  end;
end;

procedure RIRegister_TReader(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TReader) do
  begin
    RegisterMethod(@TReader.BeginReferences, 'BeginReferences');
    RegisterMethod(@TReader.CheckValue, 'CheckValue');
    RegisterMethod(@TReader.EndOfList, 'EndOfList');
    RegisterMethod(@TReader.EndReferences, 'EndReferences');
    RegisterMethod(@TReader.FixupReferences, 'FixupReferences');
    RegisterMethod(@TReader.NextValue, 'NextValue');
    RegisterMethod(@TReader.Read, 'Read');
    RegisterMethod(@TReader.ReadBoolean, 'ReadBoolean');
    RegisterMethod(@TReader.ReadChar, 'ReadChar');
    RegisterMethod(@TReader.ReadCollection, 'ReadCollection');
    RegisterMethod(@TReader.ReadComponent, 'ReadComponent');
    RegisterMethod(@TReader.ReadComponents, 'ReadComponents');
    RegisterMethod(@TReader.ReadFloat, 'ReadFloat');
    RegisterMethod(@TReader.ReadSingle, 'ReadSingle');
    RegisterMethod(@TReader.ReadCurrency, 'ReadCurrency');
    RegisterMethod(@TReader.ReadDate, 'ReadDate');
    RegisterMethod(@TReader.ReadIdent, 'ReadIdent');
    RegisterMethod(@TReader.ReadInteger, 'ReadInteger');
    RegisterMethod(@TReader.ReadInt64, 'ReadInt64');
    RegisterMethod(@TReader.ReadListBegin, 'ReadListBegin');
    RegisterMethod(@TReader.ReadListEnd, 'ReadListEnd');
    RegisterVirtualMethod(@TReader.ReadPrefix, 'ReadPrefix');
    RegisterMethod(@TReader.ReadRootComponent, 'ReadRootComponent');
    RegisterMethod(@TReader.ReadSignature, 'ReadSignature');
    RegisterMethod(@TReader.ReadStr, 'ReadStr');
    RegisterMethod(@TReader.ReadString, 'ReadString');
    RegisterMethod(@TReader.ReadWideString, 'ReadWideString');
    RegisterMethod(@TReader.ReadValue, 'ReadValue');
    RegisterMethod(@TReader.CopyValue, 'CopyValue');
    RegisterPropertyHelper(@TReaderOwner_R, @TReaderOwner_W, 'Owner');
    RegisterPropertyHelper(@TReaderParent_R, @TReaderParent_W, 'Parent');
    RegisterPropertyHelper(@TReaderPosition_R, @TReaderPosition_W, 'Position');
    RegisterPropertyHelper(@TReaderOnError_R, @TReaderOnError_W, 'OnError');
    RegisterPropertyHelper(@TReaderOnFindMethod_R, @TReaderOnFindMethod_W, 'OnFindMethod');
    RegisterPropertyHelper(@TReaderOnSetName_R, @TReaderOnSetName_W, 'OnSetName');
    RegisterPropertyHelper(@TReaderOnReferenceName_R, @TReaderOnReferenceName_W, 'OnReferenceName');
  end;
end;

procedure RIRegister_TFiler(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TFiler) do
  begin
    RegisterConstructor(@TFiler.Create, 'Create');
    RegisterPropertyHelper(@TFilerRoot_R, @TFilerRoot_W, 'Root');
    RegisterPropertyHelper(@TFilerLookupRoot_R, nil, 'LookupRoot');
    RegisterPropertyHelper(@TFilerAncestor_R, @TFilerAncestor_W, 'Ancestor');
    RegisterPropertyHelper(@TFilerIgnoreChildren_R, @TFilerIgnoreChildren_W, 'IgnoreChildren');
  end;
end;

procedure RIRegister_TStreamAdapter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStreamAdapter) do
  begin
    RegisterConstructor(@TStreamAdapter.Create, 'Create');
    RegisterVirtualMethod(@TStreamAdapter.Read, 'Read');
    RegisterVirtualMethod(@TStreamAdapter.Write, 'Write');
    RegisterVirtualMethod(@TStreamAdapter.Seek, 'Seek');
    RegisterVirtualMethod(@TStreamAdapter.SetSize, 'SetSize');
    RegisterVirtualMethod(@TStreamAdapter.CopyTo, 'CopyTo');
    RegisterVirtualMethod(@TStreamAdapter.Commit, 'Commit');
    RegisterVirtualMethod(@TStreamAdapter.Revert, 'Revert');
    RegisterVirtualMethod(@TStreamAdapter.LockRegion, 'LockRegion');
    RegisterVirtualMethod(@TStreamAdapter.UnlockRegion, 'UnlockRegion');
    RegisterVirtualMethod(@TStreamAdapter.Stat, 'Stat');
    RegisterVirtualMethod(@TStreamAdapter.Clone, 'Clone');
    RegisterPropertyHelper(@TStreamAdapterStream_R, nil, 'Stream');
    RegisterPropertyHelper(@TStreamAdapterStreamOwnership_R, @TStreamAdapterStreamOwnership_W, 'StreamOwnership');
  end;
end;

procedure RIRegister_TResourceStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TResourceStream) do
  begin
    RegisterConstructor(@TResourceStream.Create, 'Create');
    RegisterConstructor(@TResourceStream.CreateFromID, 'CreateFromID');
  end;
end;

procedure RIRegister_TStringStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStringStream) do
  begin
    RegisterConstructor(@TStringStream.Create, 'Create');
    RegisterMethod(@TStringStream.ReadString, 'ReadString');
    RegisterMethod(@TStringStream.WriteString, 'WriteString');
    RegisterPropertyHelper(@TStringStreamDataString_R, nil, 'DataString');
  end;
end;

procedure RIRegister_TMemoryStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMemoryStream) do
  begin
    RegisterMethod(@TMemoryStream.Clear, 'Clear');
    RegisterMethod(@TMemoryStream.LoadFromStream, 'LoadFromStream');
    RegisterMethod(@TMemoryStream.LoadFromFile, 'LoadFromFile');
  end;
end;

procedure RIRegister_TCustomMemoryStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomMemoryStream) do
  begin
    RegisterMethod(@TCustomMemoryStream.SaveToStream, 'SaveToStream');
    RegisterMethod(@TCustomMemoryStream.SaveToFile, 'SaveToFile');
    RegisterPropertyHelper(@TCustomMemoryStreamMemory_R, nil, 'Memory');
  end;
end;

procedure RIRegister_TFileStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TFileStream) do
  begin
    RegisterConstructor(@TFileStream.Create, 'Create');
  end;
end;

procedure RIRegister_THandleStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(THandleStream) do
  begin
    RegisterConstructor(@THandleStream.Create, 'Create');
    RegisterPropertyHelper(@THandleStreamHandle_R, nil, 'Handle');
  end;
end;

procedure RIRegister_TStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStream) do
  begin
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.Read, 'Read');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.Write, 'Write');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.Seek, 'Seek');
    RegisterMethod(@TStream.ReadBuffer, 'ReadBuffer');
    RegisterMethod(@TStream.WriteBuffer, 'WriteBuffer');
    RegisterMethod(@TStream.CopyFrom, 'CopyFrom');
    RegisterMethod(@TStream.ReadComponent, 'ReadComponent');
    RegisterMethod(@TStream.ReadComponentRes, 'ReadComponentRes');
    RegisterMethod(@TStream.WriteComponent, 'WriteComponent');
    RegisterMethod(@TStream.WriteComponentRes, 'WriteComponentRes');
    RegisterMethod(@TStream.WriteDescendent, 'WriteDescendent');
    RegisterMethod(@TStream.WriteDescendentRes, 'WriteDescendentRes');
    RegisterMethod(@TStream.WriteResourceHeader, 'WriteResourceHeader');
    RegisterMethod(@TStream.FixupResourceHeader, 'FixupResourceHeader');
    RegisterMethod(@TStream.ReadResHeader, 'ReadResHeader');
    RegisterPropertyHelper(@TStreamPosition_R, @TStreamPosition_W, 'Position');
    RegisterPropertyHelper(@TStreamSize_R, @TStreamSize_W, 'Size');
  end;
end;

procedure RIRegister_TStringList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStringList) do
  begin
    RegisterVirtualMethod(@TStringList.Find, 'Find');
    RegisterVirtualMethod(@TStringList.Sort, 'Sort');
    RegisterVirtualMethod(@TStringList.CustomSort, 'CustomSort');
    RegisterPropertyHelper(@TStringListDuplicates_R, @TStringListDuplicates_W, 'Duplicates');
    RegisterPropertyHelper(@TStringListSorted_R, @TStringListSorted_W, 'Sorted');
    RegisterPropertyHelper(@TStringListOnChange_R, @TStringListOnChange_W, 'OnChange');
    RegisterPropertyHelper(@TStringListOnChanging_R, @TStringListOnChanging_W, 'OnChanging');
  end;
end;

procedure RIRegister_TStrings(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStrings) do
  begin
    RegisterVirtualMethod(@TStrings.Add, 'Add');
    RegisterVirtualMethod(@TStrings.AddObject, 'AddObject');
    RegisterMethod(@TStrings.Append, 'Append');
    RegisterVirtualMethod(@TStrings.AddStrings, 'AddStrings');
    RegisterMethod(@TStrings.BeginUpdate, 'BeginUpdate');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Clear, 'Clear');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Delete, 'Delete');
    RegisterMethod(@TStrings.EndUpdate, 'EndUpdate');
    RegisterMethod(@TStrings.Equals, 'Equals');
    RegisterVirtualMethod(@TStrings.Exchange, 'Exchange');
    RegisterVirtualMethod(@TStrings.GetText, 'GetText');
    RegisterVirtualMethod(@TStrings.IndexOf, 'IndexOf');
    RegisterMethod(@TStrings.IndexOfName, 'IndexOfName');
    RegisterMethod(@TStrings.IndexOfObject, 'IndexOfObject');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Insert, 'Insert');
    RegisterMethod(@TStrings.InsertObject, 'InsertObject');
    RegisterVirtualMethod(@TStrings.LoadFromFile, 'LoadFromFile');
    RegisterVirtualMethod(@TStrings.LoadFromStream, 'LoadFromStream');
    RegisterVirtualMethod(@TStrings.Move, 'Move');
    RegisterVirtualMethod(@TStrings.SaveToFile, 'SaveToFile');
    RegisterVirtualMethod(@TStrings.SaveToStream, 'SaveToStream');
    RegisterVirtualMethod(@TStrings.SetText, 'SetText');
    RegisterPropertyHelper(@TStringsCapacity_R, @TStringsCapacity_W, 'Capacity');
    RegisterPropertyHelper(@TStringsCommaText_R, @TStringsCommaText_W, 'CommaText');
    RegisterPropertyHelper(@TStringsCount_R, nil, 'Count');
    RegisterPropertyHelper(@TStringsNames_R, nil, 'Names');
    RegisterPropertyHelper(@TStringsObjects_R, @TStringsObjects_W, 'Objects');
    RegisterPropertyHelper(@TStringsValues_R, @TStringsValues_W, 'Values');
    RegisterPropertyHelper(@TStringsValueFromIndex_R, @TStringsValueFromIndex_W, 'ValueFromIndex');
    RegisterPropertyHelper(@TStringsStrings_R, @TStringsStrings_W, 'Strings');
    RegisterPropertyHelper(@TStringsText_R, @TStringsText_W, 'Text');
    RegisterPropertyHelper(@TStringsStringsAdapter_R, @TStringsStringsAdapter_W, 'StringsAdapter');
  end;
end;

procedure RIRegister_TOwnedCollection(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TOwnedCollection) do
  begin
  end;
end;

procedure RIRegister_TCollection(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCollection) do
  begin
    RegisterMethod(@TCollection.Add, 'Add');
    RegisterVirtualMethod(@TCollection.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TCollection.Clear, 'Clear');
    RegisterMethod(@TCollection.Delete, 'Delete');
    RegisterVirtualMethod(@TCollection.EndUpdate, 'EndUpdate');
    RegisterMethod(@TCollection.FindItemID, 'FindItemID');
    RegisterMethod(@TCollection.Insert, 'Insert');
    RegisterPropertyHelper(@TCollectionCount_R, nil, 'Count');
    RegisterPropertyHelper(@TCollectionItems_R, @TCollectionItems_W, 'Items');
  end;
end;

procedure RIRegister_TCollectionItem(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCollectionItem) do
  begin
    RegisterVirtualConstructor(@TCollectionItem.Create, 'Create');
    RegisterPropertyHelper(@TCollectionItemCollection_R, @TCollectionItemCollection_W, 'Collection');
    RegisterPropertyHelper(@TCollectionItemID_R, nil, 'ID');
    RegisterPropertyHelper(@TCollectionItemIndex_R, @TCollectionItemIndex_W, 'Index');
    RegisterPropertyHelper(@TCollectionItemDisplayName_R, @TCollectionItemDisplayName_W, 'DisplayName');
  end;
end;

procedure RIRegister_TPersistent(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPersistent) do
  begin
    RegisterVirtualMethod(@TPersistent.Assign, 'Assign');
    RegisterVirtualMethod(@TPersistent.GetNamePath, 'GetNamePath');
  end;
end;

procedure RIRegister_TBits(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TBits) do
  begin
    RegisterMethod(@TBits.OpenBit, 'OpenBit');
    RegisterPropertyHelper(@TBitsBits_R, @TBitsBits_W, 'Bits');
    RegisterPropertyHelper(@TBitsSize_R, @TBitsSize_W, 'Size');
  end;
end;

procedure RIRegister_TInterfaceList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TInterfaceList) do
  begin
    RegisterConstructor(@TInterfaceList.Create, 'Create');
    RegisterMethod(@TInterfaceList.Clear, 'Clear');
    RegisterMethod(@TInterfaceList.Delete, 'Delete');
    RegisterMethod(@TInterfaceList.Exchange, 'Exchange');
    RegisterMethod(@TInterfaceList.Expand, 'Expand');
    RegisterMethod(@TInterfaceList.First, 'First');
    RegisterMethod(@TInterfaceList.IndexOf, 'IndexOf');
    RegisterMethod(@TInterfaceList.Add, 'Add');
    RegisterMethod(@TInterfaceList.Insert, 'Insert');
    RegisterMethod(@TInterfaceList.Last, 'Last');
    RegisterMethod(@TInterfaceList.Remove, 'Remove');
    RegisterMethod(@TInterfaceList.Lock, 'Lock');
    RegisterMethod(@TInterfaceList.Unlock, 'Unlock');
    RegisterPropertyHelper(@TInterfaceListCapacity_R, @TInterfaceListCapacity_W, 'Capacity');
    RegisterPropertyHelper(@TInterfaceListCount_R, @TInterfaceListCount_W, 'Count');
    RegisterPropertyHelper(@TInterfaceListItems_R, @TInterfaceListItems_W, 'Items');
  end;
end;

procedure RIRegister_TList(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TList) do
  begin
    RegisterMethod(@TList.Add, 'Add');
    RegisterVirtualMethod(@TList.Clear, 'Clear');
    RegisterMethod(@TList.Delete, 'Delete');
    RegisterMethod(@TList.Exchange, 'Exchange');
    RegisterMethod(@TList.Expand, 'Expand');
    RegisterMethod(@TList.Extract, 'Extract');
    RegisterMethod(@TList.First, 'First');
    RegisterMethod(@TList.IndexOf, 'IndexOf');
    RegisterMethod(@TList.Insert, 'Insert');
    RegisterMethod(@TList.Last, 'Last');
    RegisterMethod(@TList.Move, 'Move');
    RegisterMethod(@TList.Remove, 'Remove');
    RegisterMethod(@TList.Pack, 'Pack');
    RegisterMethod(@TList.Sort, 'Sort');
    RegisterPropertyHelper(@TListCapacity_R, @TListCapacity_W, 'Capacity');
    RegisterPropertyHelper(@TListCount_R, @TListCount_W, 'Count');
    RegisterPropertyHelper(@TListItems_R, @TListItems_W, 'Items');
  end;
end;

procedure RIRegister_Classes(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TStream);
  CL.Add(TFiler);
  CL.Add(TReader);
  CL.Add(TWriter);
  CL.Add(TComponent);
  RIRegister_TList(CL);
  RIRegister_TInterfaceList(CL);
  RIRegister_TBits(CL);
  RIRegister_TPersistent(CL);
  CL.Add(TCollection);
  RIRegister_TCollectionItem(CL);
  RIRegister_TCollection(CL);
  RIRegister_TOwnedCollection(CL);
  CL.Add(TStrings);
  RIRegister_TStrings(CL);
  CL.Add(TStringList);
  RIRegister_TStringList(CL);
  RIRegister_TStream(CL);
  RIRegister_THandleStream(CL);
  RIRegister_TFileStream(CL);
  RIRegister_TCustomMemoryStream(CL);
  RIRegister_TMemoryStream(CL);
  RIRegister_TStringStream(CL);
  RIRegister_TResourceStream(CL);
  RIRegister_TStreamAdapter(CL);
  RIRegister_TFiler(CL);
  RIRegister_TReader(CL);
  RIRegister_TWriter(CL);
  RIRegister_TParser(CL);
  CL.Add(TBasicAction);
  RIRegister_TComponent(CL);
  RIRegister_TBasicActionLink(CL);
  RIRegister_TBasicAction(CL);
end;

{ TPSImport_Classes }
procedure TPSImport_Classes.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Classes(CompExec.Comp);
end;

procedure TPSImport_Classes.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Classes(ri);
  RIRegister_Classes_Routines(CompExec.Exec);
end;

end.

