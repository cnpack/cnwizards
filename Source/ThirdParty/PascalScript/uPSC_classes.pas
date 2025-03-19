{ Compiletime Classes support }
unit uPSC_classes;

{$I PascalScript.inc}
interface
uses
  uPSCompiler, uPSUtils;

{
  Will register files from:
    Classes (exception TPersistent and TComponent)

  Register STD first

}

procedure SIRegister_Classes_TypesAndConsts(Cl: TPSPascalCompiler);

procedure SIRegisterTStrings(cl: TPSPascalCompiler; Streams: Boolean);
procedure SIRegisterTStringList(cl: TPSPascalCompiler);
{$IFNDEF PS_MINIVCL}
procedure SIRegisterTBITS(Cl: TPSPascalCompiler);
{$ENDIF}
procedure SIRegisterTSTREAM(Cl: TPSPascalCompiler);
procedure SIRegisterTHANDLESTREAM(Cl: TPSPascalCompiler);
{$IFNDEF PS_MINIVCL}
procedure SIRegisterTMEMORYSTREAM(Cl: TPSPascalCompiler);
{$ENDIF}
procedure SIRegisterTFILESTREAM(Cl: TPSPascalCompiler);
{$IFNDEF PS_MINIVCL}
procedure SIRegisterTCUSTOMMEMORYSTREAM(Cl: TPSPascalCompiler);
procedure SIRegisterTRESOURCESTREAM(Cl: TPSPascalCompiler);
procedure SIRegisterTPARSER(Cl: TPSPascalCompiler);
procedure SIRegisterTCOLLECTIONITEM(CL: TPSPascalCompiler);
procedure SIRegisterTCOLLECTION(CL: TPSPascalCompiler);
{$IFDEF DELPHI3UP}
procedure SIRegisterTOWNEDCOLLECTION(CL: TPSPascalCompiler);
{$ENDIF}
{$ENDIF}

procedure SIRegister_Classes(Cl: TPSPascalCompiler; Streams: Boolean{$IFDEF D4PLUS}=True{$ENDIF});

implementation

procedure SIRegisterTStrings(cl: TPSPascalCompiler; Streams: Boolean); // requires TPersistent
begin
  with Cl.AddClassN(cl.FindClass('TPersistent'), 'TStrings') do
  begin
    IsAbstract := True;
    RegisterMethod('function Add(S: string): Integer;');
    RegisterMethod('procedure Append(S: string);');
    RegisterMethod('procedure AddStrings(Strings: TStrings);');
    RegisterMethod('procedure Clear;');
    RegisterMethod('procedure Delete(Index: Integer);');
    RegisterMethod('function IndexOf(const S: string): Integer; ');
    RegisterMethod('procedure Insert(Index: Integer; S: string); ');
    RegisterProperty('Count', 'Integer', iptR);
    RegisterProperty('Text', 'String', iptrw);
    RegisterProperty('CommaText', 'String', iptrw);
    if Streams then
    begin
      RegisterMethod('procedure LoadFromFile(FileName: string); ');
      RegisterMethod('procedure SaveToFile(FileName: string); ');
    end;
    RegisterProperty('Strings', 'String Integer', iptRW);
    SetDefaultPropery('Strings');
    RegisterProperty('Objects', 'TObject Integer', iptRW);

    {$IFNDEF PS_MINIVCL}
    RegisterMethod('procedure BeginUpdate;');
    RegisterMethod('procedure EndUpdate;');
    RegisterMethod('function Equals(Strings: TStrings): Boolean;');
    RegisterMethod('procedure Exchange(Index1, Index2: Integer);');
    RegisterMethod('function IndexOfName(Name: string): Integer;');
    if Streams then
      RegisterMethod('procedure LoadFromStream(Stream: TStream); ');
    RegisterMethod('procedure Move(CurIndex, NewIndex: Integer); ');
    if Streams then
      RegisterMethod('procedure SaveToStream(Stream: TStream); ');
    RegisterMethod('procedure SetText(Text: PChar); ');
    RegisterProperty('Names', 'String Integer', iptr);
    RegisterProperty('Values', 'String String', iptRW);
    RegisterMethod('function AddObject(S:String;AObject:TObject):integer');
    RegisterMethod('function GetText:PChar');
    RegisterMethod('function IndexofObject(AObject:tObject):Integer');
    RegisterMethod('procedure InsertObject(Index:Integer;S:String;AObject:TObject)');
    {$ENDIF}
  end;
end;

procedure SIRegisterTSTRINGLIST(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TStrings'), 'TStringList') do
  begin
    RegisterMethod('function Find(S:String;var Index:Integer):Boolean');
    RegisterMethod('procedure Sort');
    RegisterProperty('Duplicates', 'TDuplicates', iptrw);
    RegisterProperty('Sorted', 'Boolean', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnChanging', 'TNotifyEvent', iptrw);
  end;
end;

{$IFNDEF PS_MINIVCL}
procedure SIRegisterTBITS(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TObject'), 'TBits') do
  begin
    RegisterMethod('function OpenBit:Integer');
    RegisterProperty('Bits', 'Boolean Integer', iptrw);
    RegisterProperty('Size', 'Integer', iptrw);
  end;
end;
{$ENDIF}

procedure SIRegisterTSTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TOBJECT'), 'TStream') do
  begin
    IsAbstract := True;
    RegisterMethod('function Read(Buffer:String;Count:LongInt):LongInt');
    RegisterMethod('function Write(Buffer:String;Count:LongInt):LongInt');
    RegisterMethod('function Seek(Offset:LongInt;Origin:Word):LongInt');
    RegisterMethod('procedure ReadBuffer(Buffer:String;Count:LongInt)');
    RegisterMethod('procedure WriteBuffer(Buffer:String;Count:LongInt)');
    {$IFDEF DELPHI4UP}
    RegisterMethod('function CopyFrom(Source:TStream;Count:Int64):LongInt');
    {$ELSE}
    RegisterMethod('function CopyFrom(Source:TStream;Count:Integer):LongInt');
    {$ENDIF}
    RegisterProperty('Position', 'LongInt', iptrw);
    RegisterProperty('Size', 'LongInt', iptrw);
  end;
end;

procedure SIRegisterTHANDLESTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TSTREAM'), 'THandleStream') do
  begin
    RegisterMethod('constructor Create(AHandle:Integer)');
    RegisterProperty('Handle', 'Integer', iptr);
  end;
end;

{$IFNDEF PS_MINIVCL}
procedure SIRegisterTMEMORYSTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TCUSTOMMEMORYSTREAM'), 'TMemoryStream') do
  begin
    RegisterMethod('procedure Clear');
    RegisterMethod('procedure LoadFromStream(Stream:TStream)');
    RegisterMethod('procedure LoadFromFile(FileName:String)');
    RegisterMethod('procedure SetSize(NewSize:LongInt)');
  end;
end;
{$ENDIF}

procedure SIRegisterTFILESTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('THandleStream'), 'TFileStream') do
  begin
    RegisterMethod('constructor Create(FileName:String;Mode:Word)');
  end;
end;

{$IFNDEF PS_MINIVCL}
procedure SIRegisterTCUSTOMMEMORYSTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TSTREAM'), 'TCustomMemoryStream') do
  begin
    IsAbstract := True;
    RegisterMethod('procedure SaveToStream(Stream:TStream)');
    RegisterMethod('procedure SaveToFile(FileName:String)');
  end;
end;

procedure SIRegisterTRESOURCESTREAM(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TCUSTOMMEMORYSTREAM'), 'TResourceStream') do
  begin
    RegisterMethod('constructor Create(Instance:THandle;ResName:String;ResType:PChar)');
    RegisterMethod('constructor CreateFromId(Instance:THandle;ResId:Integer;ResType:PChar)');
  end;
end;

procedure SIRegisterTPARSER(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TOBJECT'), 'TParser') do
  begin
    RegisterMethod('constructor Create(Stream:TStream)');
    RegisterMethod('procedure CheckToken(t:char)');
    RegisterMethod('procedure CheckTokenSymbol(s:string)');
    RegisterMethod('procedure Error(Ident:Integer)');
    RegisterMethod('procedure ErrorStr(Message:String)');
    RegisterMethod('procedure HexToBinary(Stream:TStream)');
    RegisterMethod('function NextToken:Char');
    RegisterMethod('function SourcePos:LongInt');
    RegisterMethod('function TokenComponentIdent:String');
    RegisterMethod('function TokenFloat:Extended');
    RegisterMethod('function TokenInt:LongInt');
    RegisterMethod('function TokenString:String');
    RegisterMethod('function TokenSymbolIs(S:String):Boolean');
    RegisterProperty('SourceLine', 'Integer', iptr);
    RegisterProperty('Token', 'Char', iptr);
  end;
end;

procedure SIRegisterTCOLLECTIONITEM(CL: TPSPascalCompiler);
Begin
  if cl.FindClass('TCOLLECTION') = nil then cl.AddClassN(cl.FindClass('TPERSISTENT'), 'TCollection');
  With cl.AddClassN(cl.FindClass('TPERSISTENT'),'TCollectionItem') do
  begin
  RegisterMethod('Constructor Create( Collection : TCollection)');
  RegisterProperty('Collection', 'TCollection', iptrw);
{$IFDEF DELPHI3UP}  RegisterProperty('Id', 'Integer', iptr); {$ENDIF}
  RegisterProperty('Index', 'Integer', iptrw);
{$IFDEF DELPHI3UP}  RegisterProperty('DisplayName', 'String', iptrw); {$ENDIF}
  end;
end;

procedure SIRegisterTCOLLECTION(CL: TPSPascalCompiler);
var
  cr: TPSCompileTimeClass;
Begin
  cr := CL.FindClass('TCOLLECTION');
  if cr = nil then cr := cl.AddClassN(cl.FindClass('TPERSISTENT'), 'TCollection');
With cr do
  begin
//  RegisterMethod('constructor Create( ItemClass : TCollectionItemClass)');
{$IFDEF DELPHI3UP}  RegisterMethod('function Owner : TPersistent'); {$ENDIF}
  RegisterMethod('function Add : TCollectionItem');
  RegisterMethod('procedure BeginUpdate');
  RegisterMethod('procedure Clear');
{$IFDEF DELPHI5UP}  RegisterMethod('procedure Delete( Index : Integer)'); {$ENDIF}
  RegisterMethod('procedure EndUpdate');
{$IFDEF DELPHI3UP}  RegisterMethod('function FindItemId( Id : Integer) : TCollectionItem'); {$ENDIF}
{$IFDEF DELPHI3UP}  RegisterMethod('function Insert( Index : Integer) : TCollectionItem'); {$ENDIF}
  RegisterProperty('Count', 'Integer', iptr);
{$IFDEF DELPHI3UP}  RegisterProperty('ItemClass', 'TCollectionItemClass', iptr); {$ENDIF}
  RegisterProperty('Items', 'TCollectionItem Integer', iptrw);
  end;
end;

{$IFDEF DELPHI3UP}
procedure SIRegisterTOWNEDCOLLECTION(CL: TPSPascalCompiler);
Begin
With Cl.AddClassN(cl.FindClass('TCOLLECTION'),'TOwnedCollection') do
  begin
//  RegisterMethod('Constructor CREATE( AOWNER : TPERSISTENT; ITEMCLASS : TCOLLECTIONITEMCLASS)');
  end;
end;
{$ENDIF}
{$ENDIF}

procedure SIRegister_Classes_TypesAndConsts(Cl: TPSPascalCompiler);
begin
  cl.AddConstantN('soFromBeginning', 'Longint').Value.ts32 := 0;
  cl.AddConstantN('soFromCurrent', 'Longint').Value.ts32 := 1;
  cl.AddConstantN('soFromEnd', 'Longint').Value.ts32 := 2;
  cl.AddConstantN('toEOF', 'Char').SetString(#0);
  cl.AddConstantN('toSymbol', 'Char').SetString(#1);
  cl.AddConstantN('toString', 'Char').SetString(#2);
  cl.AddConstantN('toInteger', 'Char').SetString(#3);
  cl.AddConstantN('toFloat', 'Char').SetString(#4);
  cl.AddConstantN('fmCreate', 'Longint').Value.ts32 := $FFFF;
  cl.AddConstantN('fmOpenRead', 'Longint').Value.ts32 := 0;
  cl.AddConstantN('fmOpenWrite', 'Longint').Value.ts32 := 1;
  cl.AddConstantN('fmOpenReadWrite', 'Longint').Value.ts32 := 2;
  cl.AddConstantN('fmShareCompat', 'Longint').Value.ts32 := 0;
  cl.AddConstantN('fmShareExclusive', 'Longint').Value.ts32 := $10;
  cl.AddConstantN('fmShareDenyWrite', 'Longint').Value.ts32 := $20;
  cl.AddConstantN('fmShareDenyRead', 'Longint').Value.ts32 := $30;
  cl.AddConstantN('fmShareDenyNone', 'Longint').Value.ts32 := $40;
  cl.AddConstantN('SecsPerDay', 'Longint').Value.ts32 := 86400;
  cl.AddConstantN('MSecPerDay', 'Longint').Value.ts32 := 86400000;
  cl.AddConstantN('DateDelta', 'Longint').Value.ts32 := 693594;
  cl.AddTypeS('TAlignment', '(taLeftJustify, taRightJustify, taCenter)');
  cl.AddTypeS('THelpEvent', 'function (Command: Word; Data: Longint; var CallHelp: Boolean): Boolean');
  cl.AddTypeS('TGetStrProc', 'procedure(const S: string)');
  cl.AddTypeS('TDuplicates', '(dupIgnore, dupAccept, dupError)');
  cl.AddTypeS('TOperation', '(opInsert, opRemove)');
  cl.AddTypeS('THANDLE', 'Longint');

  cl.AddTypeS('TNotifyEvent', 'procedure (Sender: TObject)');
end;

procedure SIRegister_Classes(Cl: TPSPascalCompiler; Streams: Boolean);
begin
  SIRegister_Classes_TypesAndConsts(Cl);
  if Streams then
    SIRegisterTSTREAM(Cl);
  SIRegisterTStrings(cl, Streams);
  SIRegisterTStringList(cl);
  {$IFNDEF PS_MINIVCL}
  SIRegisterTBITS(cl);
  {$ENDIF}
  if Streams then
  begin
    SIRegisterTHANDLESTREAM(Cl);
    SIRegisterTFILESTREAM(Cl);
    {$IFNDEF PS_MINIVCL}
    SIRegisterTCUSTOMMEMORYSTREAM(Cl);
    SIRegisterTMEMORYSTREAM(Cl);
    SIRegisterTRESOURCESTREAM(Cl);
    {$ENDIF}
  end;
  {$IFNDEF PS_MINIVCL}
  SIRegisterTPARSER(Cl);
  SIRegisterTCOLLECTIONITEM(Cl);
  SIRegisterTCOLLECTION(Cl);
  {$IFDEF DELPHI3UP}
  SIRegisterTOWNEDCOLLECTION(Cl);
  {$ENDIF}
  {$ENDIF}
end;

// PS_MINIVCL changes by Martijn Laan (mlaan at wintax _dot_ nl)


end.
