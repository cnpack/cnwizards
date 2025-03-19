unit uROPSServerLink;

interface
uses
  SysUtils, Classes, uPSCompiler, uPSUtils, uPSRuntime,
  uROServer, uROClient, uRODL{$IFDEF WIN32},
  Windows{$ELSE}, Types{$ENDIF}, uROTypes, uROClientIntf,
  uROSerializer, uPSComponent;

type
  
  TPSROModule = class
  protected
    class procedure ExecImp(exec: TPSExec; ri: TPSRuntimeClassImporter); virtual;
    class procedure CompImp(comp: TPSPascalCompiler); virtual;
  end;
  TPSROModuleClass = class of TPSROModule;
  TPSRemObjectsSdkPlugin = class;
  TPSROModuleLoadEvent = procedure (Sender: TPSRemObjectsSdkPlugin) of object;
  
  TPSRemObjectsSdkPlugin = class(TPSPlugin)
  private
    FRodl: TRODLLibrary;
    FModules: TList;
    FOnLoadModule: TPSROModuleLoadEvent;
    
    FEnableIndyTCP: Boolean;
    FEnableIndyHTTP: Boolean;
    FEnableBinary: Boolean;
    function GetHaveRodl: Boolean;
    function MkStructName(Struct: TRODLStruct): string;
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  protected
    procedure Loaded; override;
  public
    
    procedure RODLLoadFromFile(const FileName: string);
    
    procedure RODLLoadFromResource;

    procedure RODLLoadFromStream(S: TStream);
    
    procedure ClearRodl;
    
    property HaveRodl: Boolean read GetHaveRodl;
    
    constructor Create(AOwner: TComponent); override;
    
    destructor Destroy; override;

    
    procedure ReloadModules;
    
    procedure RegisterModule(Module: TPSROModuleClass);
  published
    property OnLoadModule: TPSROModuleLoadEvent read FOnLoadModule write FOnLoadModule;
    
    property EnableIndyTCP: Boolean read FEnableIndyTCP write FEnableIndyTCP default true;
    
    property EnableIndyHTTP: Boolean read FEnableIndyHTTP write FEnableIndyHTTP default true;
    
    property EnableBinary: Boolean read FEnableBinary write FEnableBinary default true;
  end;

implementation
uses
  uRODLToXML, uROPSImports;

procedure SIRegisterTROTRANSPORTCHANNEL(CL: TPSPascalCompiler);
Begin
With cl.AddClassN(cl.FindClass('TComponent'), 'TROTRANSPORTCHANNEL') do
  begin
  end;
end;

procedure SIRegisterTROMESSAGE(CL: TPSPascalCompiler);
Begin
With cl.AddClassN(cl.FindClass('TComponent'),'TROMESSAGE') do
  begin
  RegisterProperty('MESSAGENAME', 'STRING', iptrw);
  RegisterProperty('INTERFACENAME', 'STRING', iptrw);
  end;
end;

procedure TROMESSAGEINTERFACENAME_W(Self: TROMESSAGE; const T: STRING);
begin Self.INTERFACENAME := T; end;

procedure TROMESSAGEINTERFACENAME_R(Self: TROMESSAGE; var T: STRING);
begin T := Self.INTERFACENAME; end;

procedure TROMESSAGEMESSAGENAME_W(Self: TROMESSAGE; const T: STRING);
begin Self.MESSAGENAME := T; end;

procedure TROMESSAGEMESSAGENAME_R(Self: TROMESSAGE; var T: STRING);
begin T := Self.MESSAGENAME; end;

procedure RIRegisterTROTRANSPORTCHANNEL(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TROTRANSPORTCHANNEL) do
  begin
  RegisterVirtualConstructor(@TROTRANSPORTCHANNEL.CREATE, 'CREATE');
  end;
end;

procedure RIRegisterTROMESSAGE(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TROMESSAGE) do
  begin
  RegisterVirtualConstructor(@TROMESSAGE.CREATE, 'CREATE');
  RegisterPropertyHelper(@TROMESSAGEMESSAGENAME_R,@TROMESSAGEMESSAGENAME_W,'MESSAGENAME');
  RegisterPropertyHelper(@TROMESSAGEINTERFACENAME_R,@TROMESSAGEINTERFACENAME_W,'INTERFACENAME');
  end;
end;

 
(*----------------------------------------------------------------------------*)
procedure SIRegister_TROBinaryMemoryStream(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TMemoryStream', 'TROBinaryMemoryStream') do
  with CL.AddClassN(CL.FindClass('TMemoryStream'),'TROBinaryMemoryStream') do
  begin
    RegisterMethod('Constructor Create2( const iString : Ansistring);');
    RegisterMethod('Constructor Create;');
    RegisterMethod('Procedure Assign( iSource : TStream)');
    RegisterMethod('Function Clone : TROBinaryMemoryStream');
    RegisterMethod('Procedure LoadFromString( const iString : Ansistring)');
    RegisterMethod('Procedure LoadFromHexString( const iString : Ansistring)');
    RegisterMethod('Function ToString : AnsiString');
    RegisterMethod('Function ToHexString : Ansistring');
    RegisterMethod('Function ToReadableString : Ansistring');
    RegisterMethod('Function WriteAnsiString( AString : AnsiString) : integer');
    RegisterProperty('CapacityIncrement', 'integer', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_uROClasses(CL: TPSPascalCompiler);
begin
  SIRegister_TROBinaryMemoryStream(CL);
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TROBinaryMemoryStreamCapacityIncrement_W(Self: TROBinaryMemoryStream; const T: integer);
begin Self.CapacityIncrement := T; end;

(*----------------------------------------------------------------------------*)
procedure TROBinaryMemoryStreamCapacityIncrement_R(Self: TROBinaryMemoryStream; var T: integer);
begin T := Self.CapacityIncrement; end;

(*----------------------------------------------------------------------------*)
Function TROBinaryMemoryStreamCreate_P(Self: TClass; CreateNewInstance: Boolean):TObject;
Begin Result := TROBinaryMemoryStream.Create; END;

(*----------------------------------------------------------------------------*)
Function TROBinaryMemoryStreamCreate2_P(Self: TClass; CreateNewInstance: Boolean;  const iString : Ansistring):TObject;
Begin Result := TROBinaryMemoryStream.Create(iString); END;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TROBinaryMemoryStream(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TROBinaryMemoryStream) do
  begin
    RegisterConstructor(@TROBinaryMemoryStreamCreate2_P, 'Create2');
    RegisterConstructor(@TROBinaryMemoryStreamCreate_P, 'Create');
    RegisterMethod(@TROBinaryMemoryStream.Assign, 'Assign');
    RegisterMethod(@TROBinaryMemoryStream.Clone, 'Clone');
    RegisterMethod(@TROBinaryMemoryStream.LoadFromString, 'LoadFromString');
    RegisterMethod(@TROBinaryMemoryStream.LoadFromHexString, 'LoadFromHexString');
    RegisterMethod(@TROBinaryMemoryStream.ToString, 'ToString');
    RegisterMethod(@TROBinaryMemoryStream.ToHexString, 'ToHexString');
    RegisterMethod(@TROBinaryMemoryStream.ToReadableString, 'ToReadableString');
    RegisterMethod(@TROBinaryMemoryStream.WriteAnsiString, 'WriteAnsiString');
    RegisterPropertyHelper(@TROBinaryMemoryStreamCapacityIncrement_R,@TROBinaryMemoryStreamCapacityIncrement_W,'CapacityIncrement');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_uROClasses(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TROBinaryMemoryStream(CL);
end;

 

(*----------------------------------------------------------------------------*)

type
  TRoObjectInstance = class;
  {   }
  IROClass = interface
    ['{246B5804-461F-48EC-B2CA-FBB7B69B0D64}']
    function SLF: TRoObjectInstance;
  end;
  TRoObjectInstance = class(TInterfacedObject, IROClass)
  private
    FMessage: IROMessage;
    FChannel: IROTransportChannel;
  public
    constructor Create;
    function SLF: TRoObjectInstance;
    property Message: IROMessage read FMessage write FMessage;
    property Channel: IROTransportChannel read FChannel write FChannel;
  end;



function CreateProc(Caller: TPSExec; p: PIFProcRec; Global, Stack: TPSStack): Boolean;
var
  temp, res: TPSVariantIFC;
  Chan: TROTransportChannel;
  Msg: TROMessage;
  NewRes: TRoObjectInstance;
begin
  res := NewTPSVariantIFC(Stack[Stack.count -1], True);
  if (Res.Dta = nil) or (res.aType.BaseType <> btInterface) then
  begin
    Caller.CMD_Err2(erCustomError, 'RO Invoker: Invalid Parameters');
    Result := False;
    exit;
  end;
  IUnknown(Res.Dta^) := nil;

  NewRes := TRoObjectInstance.Create;

  temp := NewTPSVariantIFC(Stack[Stack.Count -4], True);

  if (temp.aType <> nil) and (temp.Dta <> nil) and (Temp.aType.BaseType = btClass) and (TObject(Temp.Dta^) is TROTransportChannel) then
    Chan := TROTransportChannel(temp.dta^)
  else
    Chan := nil;
  temp := NewTPSVariantIFC(Stack[Stack.Count -3], True);
  if (temp.aType <> nil) and (temp.Dta <> nil) and (Temp.aType.BaseType = btClass) and (TObject(Temp.Dta^) is TROMessage) then
    Msg := TROMessage(temp.dta^)
  else
    Msg := nil;
  if (msg = nil) or (chan = nil) then
  begin
    Chan.free;
    msg.Free;

    NewRes.Free;
    Result := false;
    Caller.CMD_Err2(erCustomError, 'Could not create message');
    exit;
  end;

  IRoClass(Res.Dta^) := NewRes;

  NewRes.Message := Msg;
  NewRes.Channel := Chan;
  Result := True;
end;

function NilProc(Caller: TPSExec; p: PIFProcRec; Global, Stack: TPSStack): Boolean;
var
  n: TPSVariantIFC;
begin
  n := NewTPSVariantIFC(Stack[Stack.count -1], True);
  if (n.Dta = nil) or (n.aType = nil) or (n.aType.BaseType <> btInterface) then
  begin
    Caller.CMD_Err2(erCustomError, 'RO Invoker: Cannot free');
    Result := False;
    exit;
  end;
  IUnknown(n.Dta^) := nil;
  Result := True;
end;

type
  TROStructure = class(TPersistent, IROCustomStreamableType, IROCustomStreamableStruct)
  private
    FVar: TPSVariantIFC;
    FExec: TPSExec;
  protected
    function GetTypeName: string;
    procedure SetTypeName(const s: string);
    procedure Write(Serializer: TROSerializer; const Name: string);
    procedure Read(Serializer: TROSerializer; const Name: string);
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function CanImplementType(const aName: string):boolean;
    procedure SetNull(b: Boolean);
    function IsNull: Boolean;
  public
    constructor Create(aVar: TPSVariantIfc; Exec: TPSExec);
  end;
  TROArray = class(TROStructure, IROCustomStreamableType, IROCustomStreamableStruct, IROCustomStreamableArray)
  protected
    function GetCount: Longint;
     procedure SetCount(l: Longint);
  end;

procedure WriteUserDefined(Exec: TPSExec; const Msg: IROMessage; const Name: string; const n: TPSVariantIfc);
var
  obj: TROStructure;
begin
  if n.aType.BaseType = btArray then
    obj := TROArray.Create(n, exec)
  else if n.aType.BaseType = btRecord then
    obj := TROStructure.Create(n, exec)
  else
    raise Exception.Create('Unknown custom type');
  try
    Msg.Write(Name, obj.ClassInfo, obj, []);
  finally
    obj.Free;
  end;
end;

procedure ReadUserDefined(Exec: TPSExec; const Msg: IROMessage;  const Name: string; const n: TPSVariantIfc);
var
  obj: TROStructure;
begin
  if n.aType.BaseType = btArray then
    obj := TROArray.Create(n, exec)
  else if n.aType.BaseType = btRecord then
    obj := TROStructure.Create(n, exec)
  else
    raise Exception.Create('Unknown custom type');
  try
    Msg.Read(Name, obj.ClassInfo, obj, []);
  finally
    obj.Free;
  end;
end;

function RoProc(Caller: TPSExec; p: TIFExternalProcRec; Global, Stack: TIfList): Boolean;
var
  s, s2: string;
  res, n: TPSVariantIFC;
  aType: TRODataType;
  aMode: TRODLParamFlag;
  StartOffset, I: Longint;
  __request, __response : TMemoryStream;
  Inst:  TRoObjectInstance;

begin
  s := p.Decl;

  if s[1] = #255 then
  begin
    n := NewTPSVariantIFC(Stack[Stack.Count -1], True);
    res.Dta := nil;
    res.aType := nil;
    StartOffset := Stack.Count -2;
  end
  else
  begin
    n := NewTPSVariantIFC(Stack[Stack.Count -2], True);
    res := NewTPSVariantIFC(Stack[Stack.Count -1], True);
    StartOffset := Stack.Count -3;
  end;

  if (n.Dta = nil) or (N.aType = nil) or (n.aType.BaseType <> btInterface) or (Longint(n.Dta^) = 0) then
  begin
    Caller.CMD_Err2(erCustomError, 'RO Invoker: Invalid Parameters');
    Result := False;
    exit;
  end;

  Inst := IROClass(n.dta^).Slf;
  Delete(s, 1, 1);
  i := StartOffset;
  try
    Inst.SLF.Message.InitializeRequestMessage(Inst.Channel, '', Copy(p.Name,1,pos('.', p.Name) -1), Copy(p.Name, pos('.', p.Name)+1, MaxInt));
    while Length(s) > 0 do
    begin
      s2 := copy(s, 2, ord(s[1]));
      aMode := TRODLParamFlag(ord(s[length(s2)+2]));
      aType := TRODataType(ord(s[length(s2)+3]));
      Delete(s, 1, length(s2)+3);
      n := NewTPSVariantIFC(Stack[i], True);
      Dec(I);
      if ((aMode = fIn) or (aMode = fInOut)) and (n.Dta <> nil) then
      begin
        case aType of
          rtInteger: Inst.Message.Write(s2, TypeInfo(Integer),  Integer(n.Dta^), []);
          rtDateTime: Inst.Message.Write(s2, TypeInfo(DateTime), Double(n.Dta^), []);
          rtDouble: Inst.Message.Write(s2, TypeInfo(Double), Double(n.Dta^), []);
          rtCurrency: Inst.Message.Write(s2, TypeInfo(Double), Double(n.Dta^), []);
          rtWideString: Inst.Message.Write(s2, TypeInfo(WideString), WideString(n.Dta^), []);
          rtString: Inst.Message.Write(s2, TypeInfo(String), String(n.Dta^), []);
          rtInt64: Inst.Message.Write(s2, TypeInfo(Int64), Int64(n.Dta^), []);
          rtBoolean: Inst.Message.Write(s2, TypeInfo(Boolean), Byte(n.Dta^), []);
          rtUserDefined: WriteUserDefined(Caller, Inst.Message, s2, n);
        end;
      end;
    end;
    __request := TMemoryStream.Create;
    __response := TMemoryStream.Create;
    try
      Inst.Message.WriteToStream(__request);
      Inst.Channel.Dispatch(__request, __response);
      Inst.Message.ReadFromStream(__response);
    finally
      __request.Free;
      __response.Free;
    end;
    s := p.Decl;
    Delete(s, 1, 1);
    i := StartOffset;
    while Length(s) > 0 do
    begin
      s2 := copy(s, 2, ord(s[1]));
      aMode := TRODLParamFlag(ord(s[length(s2)+2]));
      aType := TRODataType(ord(s[length(s2)+3]));
      Delete(s, 1, length(s2)+3);
      n := NewTPSVariantIFC(Stack[i], True);
      Dec(I);
      if ((aMode = fOut) or (aMode = fInOut)) and (n.Dta <> nil) then
      begin
        case aType of
          rtInteger: Inst.Message.Read(s2, TypeInfo(Integer), Longint(n.Dta^), []);
          rtDateTime: Inst.Message.Read(s2, TypeInfo(DateTime), double(n.dta^), []);
          rtDouble: Inst.Message.Read(s2, TypeInfo(Double), double(n.dta^), []);
          rtCurrency: Inst.Message.Read(s2, TypeInfo(Double), double(n.dta^), []);
          rtWideString: Inst.Message.Read(s2, TypeInfo(WideString), widestring(n.Dta^), []);
          rtString: Inst.Message.Read(s2, TypeInfo(String), string(n.dta^), []);
          rtInt64: Inst.Message.Read(s2, TypeInfo(Int64), Int64(n.Dta^), []);
          rtBoolean: Inst.Message.Read(s2, TypeInfo(Boolean), Boolean(n.Dta^), []);
          rtUserDefined: ReadUserDefined(Caller, Inst.Message, s2, n);
        end;
      end;
    end;
    aType := TRODataType(p.Decl[1]);
    case aType of
      rtInteger: Inst.Message.Read('Result', TypeInfo(Integer), Longint(res.Dta^), []);
      rtDateTime: Inst.Message.Read('Result', TypeInfo(DateTime), Double(res.dta^), []);
      rtDouble: Inst.Message.Read('Result', TypeInfo(Double), Double(res.Dta^), []);
      rtCurrency: Inst.Message.Read('Result', TypeInfo(Double), double(res.Dta^), []);
      rtWideString: Inst.Message.Read('Result', TypeInfo(WideString), WideString(res.Dta^), []);
      rtString: Inst.Message.Read('Result', TypeInfo(String), String(res.Dta^), []);
      rtInt64: Inst.Message.Read('Result', TypeInfo(Int64), Int64(res.dta^), []);
      rtBoolean: Inst.Message.Read('Result', TypeInfo(Boolean), Boolean(res.dta^), []);
      rtUserDefined: ReadUserDefined(Caller, Inst.Message, 'Result', res);
    end;
  except
    on e: Exception do
    begin
      Caller.CMD_Err2(erCustomError, e.Message);
      Result := False;
      exit;
    end;
  end;
  Result := True;
end;

function SProcImport(Sender: TPSExec; p: TIFExternalProcRec; Tag: Pointer): Boolean;
var
  s: string;
begin
  s := p.Decl;
  Delete(s, 1, pos(':', s));
  if s[1] = '-' then
    p.ProcPtr := @NilProc
  else if s[1] = '!' then
  begin
    P.ProcPtr := @CreateProc;
    p.Decl := Copy(s, 2, MaxInt);
  end else
  begin
    Delete(s, 1, 1);
    p.Name := Copy(S,1,pos('!', s)-1);
    Delete(s, 1, pos('!', s));
    p.Decl := s;
    p.ProcPtr := @RoProc;
  end;
  Result := True;
end;


type
  TMYComp = class(TPSPascalCompiler);
  TRoClass = class(TPSExternalClass)
  private
    FService: TRODLService;
    FNilProcNo: Cardinal;
    FCompProcno: Cardinal;
    function CreateParameterString(l: TRODLOperation): string;
    function GetDT(DataType: string): TRODataType;
    procedure MakeDeclFor(Dest: TPSParametersDecl; l: TRODLOperation);
  public
    constructor Create(Se: TPSPascalCompiler; Service: TRODLService; Const Typeno: TPSType);

    function SelfType: TPSType; override;
    function Func_Find(const Name: tbtstring; var Index: Cardinal): Boolean; override;
    function Func_Call(Index: Cardinal; var ProcNo: Cardinal): Boolean; override;
    function SetNil(var ProcNo: Cardinal): Boolean; override;

    function ClassFunc_Find(const Name: tbtstring; var Index: Cardinal): Boolean; override;
    function ClassFunc_Call(Index: Cardinal; var ProcNo: Cardinal): Boolean; override;
    function IsCompatibleWith(Cl: TPSExternalClass): Boolean; override;
  end;

{ TROPSLink }
procedure TPSRemObjectsSdkPlugin.RODLLoadFromFile(const FileName: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    RODLLoadFromStream(f);
  finally
    f.Free;
  end;
end;

procedure TPSRemObjectsSdkPlugin.RODLLoadFromResource;
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(HInstance, 'RODLFILE', RT_RCDATA);
  try
    RODLLoadFromStream(rs);
  finally
    rs.Free;
  end;
end;

procedure TPSRemObjectsSdkPlugin.RODLLoadFromStream(S: TStream);
begin
  FreeAndNil(FRodl);
  with TXMLToRODL.Create do
  begin
    try
      FRodl := Read(S);
    finally
      Free;
    end;
  end;
end;


destructor TPSRemObjectsSdkPlugin.Destroy;
begin
  FreeAndNil(FRodl);
  FModules.Free;
  inherited Destroy;
end;

{ TRoClass }

constructor TRoClass.Create(Se: TPSPascalCompiler; Service: TRODLService; Const Typeno: TPSType);
begin
  inherited Create(SE, TypeNo);
  FService := Service;
  FNilProcNo := Cardinal(-1);
  FCompProcNo := Cardinal(-1);
end;

function TRoClass.GetDT(DataType: string): TRODataType;
begin
  DataType := LowerCase(DataType);
  if DataType = 'integer' then
    Result := rtInteger
  else if DataType = 'datetime' then
    Result := rtDateTime
  else if DataType = 'double' then
    Result := rtDouble
  else if DataType = 'currency' then
    Result := rtCurrency
  else if DataType = 'widestring' then
    Result := rtWidestring
  else if DataType = 'string' then
    Result := rtString
  else if DataType = 'int64' then
    Result := rtInt64
  else if DataType = 'boolean' then
    Result := rtBoolean
  else if DataType = 'variant' then
    Result := rtVariant
  else if DataType = 'binary' then
    Result := rtBinary
  else
    Result := rtUserDefined;
end;

function TRoClass.CreateParameterString(l: TRODLOperation): string;
var
  i: Longint;
begin
  if L.Result = nil then
  begin
    Result := #$FF;
  end else
  begin
    Result := Chr(Ord(GetDT(l.Result.DataType)));
  end;
  for i := 0 to l.Count -1 do
  begin
    if l.Items[i].Flag = fResult then Continue;
    Result := Result + Chr(Length(l.Items[i].Info.Name))+ l.Items[i].Info.Name + Chr(Ord(l.Items[i].Flag)) + Chr(Ord(GetDT(l.Items[i].DataType)));
  end;
end;

procedure TRoClass.MakeDeclFor(Dest: TPSParametersDecl; l: TRODLOperation);
var
  i: Longint;
  dd: TPSParameterDecl;
begin
  if l.Result <> nil then
  begin
    Dest.Result := TMyComp(SE).at2ut(SE.FindType(l.Result.DataType));
  end;
  for i := 0 to l.Count -1 do
  begin
    if l.Items[i].Flag = fResult then Continue;
    dd := Dest.AddParam;
    if l.Items[i].Flag = fIn then
      dd.mode := pmIn
    else
      dd.Mode := pmInOut;
    dd.OrgName := l.Items[i].Info.Name;
    dd.aType := TMyComp(SE).at2ut(SE.FindType(l.Items[i].DataType));
  end;
end;

function TRoClass.Func_Call(Index: Cardinal; var ProcNo: Cardinal): Boolean;
var
  h, i: Longint;
  s, e: string;
  P: TPSProcedure;
  p2: TPSExternalProcedure;
begin
    s := 'roclass:_'+FService.Info.Name + '.' + FService.Default.Items[Index].Info.Name;
  h := MakeHash(s);
  for i := 0 to TMyComp(SE).FProcs.Count -1 do
  begin
    P := TMyComp(SE).FProcs[i];
    if (p is TPSExternalProcedure) then
    begin
      p2 := TPSExternalProcedure(p);
      if (p2.RegProc.NameHash = h) and (Copy(p2.RegProc.ImportDecl, 1, pos(tbtchar('!'), p2.RegProc.ImportDecl)) = s) then
      begin
        Procno := I;
        Result := True;
        Exit;
      end;
    end;
  end;
  e := CreateParameterString(FService.Default.Items[Index]);
  s := s + '!' + e;
  ProcNo := TMyComp(SE).AddUsedFunction2(P2);
  p2.RegProc := TPSRegProc.Create;
  TMYComp(SE).FRegProcs.Add(p2.RegProc);
  p2.RegProc.Name := '';
  p2.RegProc.ExportName := True;
  MakeDeclFor(p2.RegProc.Decl, FService.Default.Items[Index]);
  p2.RegProc.ImportDecl := s;
  Result := True;
end;

function TRoClass.Func_Find(const Name: tbtstring; var Index: Cardinal): Boolean;
var
  i: Longint;
begin
  for i := 0 to FService.Default.Count -1 do
  begin
    if CompareText(FService.Default.Items[i].Info.Name, Name) = 0 then
    begin
      Index := i;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

const
  PSClassType = '!ROClass';
  MyGuid: TGuid = '{CADCCF37-7FA0-452E-971D-65DA691F7648}';

function TRoClass.SelfType: TPSType;
begin
  Result := SE.FindType(PSClassType);
  if Result = nil then
  begin
    Result := se.AddInterface(se.FindInterface('IUnknown'), MyGuid, PSClassType).aType;
  end;
end;

function TRoClass.SetNil(var ProcNo: Cardinal): Boolean;
var
  P: TPSExternalProcedure;
begin
  if FNilProcNo <> Cardinal(-1) then
    ProcNo:= FNilProcNo
  else
  begin
    ProcNo := TMyComp(SE).AddUsedFunction2(P);
    p.RegProc := TPSRegProc.Create;
    TMyComp(SE).FRegProcs.Add(p.RegProc);
    p.RegProc.Name := '';
    p.RegProc.ExportName := True;
    with p.RegProc.Decl.AddParam do
    begin
      OrgName := 'VarNo';
      aType := TMYComp(Se).at2ut(SelfType);
    end;
    p.RegProc.ImportDecl := 'roclass:-';
    FNilProcNo := Procno;
  end;
  Result := True;
end;

function TRoClass.ClassFunc_Call(Index: Cardinal;
  var ProcNo: Cardinal): Boolean;
var
  P: TPSExternalProcedure;
begin
  if FCompProcNo <> Cardinal(-1) then
  begin
    Procno := FCompProcNo;
    Result := True;
    Exit;
  end;
  ProcNo := TMyComp(SE).AddUsedFunction2(P);
  p.RegProc := TPSRegProc.Create;
  TMyComp(SE).FRegProcs.Add(p.RegProc);
  p.RegProc.ExportName := True;
  p.RegProc.Decl.Result := TMyComp(SE).at2ut(SelfType);
  with p.RegProc.Decl.AddParam do
  begin
    Orgname := 'Message';
    aType :=TMyComp(SE).at2ut(SE.FindType('TROMESSAGE'));
  end;
  with p.RegProc.Decl.AddParam do
  begin
    Orgname := 'Channel';
    aType :=TMyComp(SE).at2ut(SE.FindType('TROTRANSPORTCHANNEL'));
  end;
  p.RegProc.ImportDecl := 'roclass:!';
  FCompProcNo := Procno;
  Result := True;
end;

function TRoClass.ClassFunc_Find(const Name: tbtstring;
  var Index: Cardinal): Boolean;
begin
  if Name = 'CREATE' then
  begin
    Result := True;
    Index := 0;
  end else
    result := False;
end;

function TRoClass.IsCompatibleWith(Cl: TPSExternalClass): Boolean;
begin
  Result := Cl is TRoClass;
end;

{ TRoObjectInstance }

function TRoObjectInstance.SLF: TRoObjectInstance;
begin
  Result := Self;
end;

constructor TRoObjectInstance.Create;
begin
  FRefCount := 1;
end;


function TPSRemObjectsSdkPlugin.MkStructName(Struct: TRODLStruct): string;
var
  i: Longint;
begin
  Result := '!ROStruct!'+Struct.Info.Name+ ',';
  for i := 0 to Struct.Count -1 do
  begin
    Result := Result + Struct.Items[i].Info.Name+ ',';
  end;
end;

function CompareStructItem(const S1, S2: TRODLTypedEntity): Integer;
begin
  Result := CompareText(S1.Info.Name, S2.Info.Name);
end;

procedure SortStruct(struct: TRODLStruct; First, Last: Longint);
var
  l, r, Pivot: Integer;
begin
  while First < Last do
  begin
    Pivot := (First + Last) div 2;
    l := First - 1;
    r := Last + 1;
    repeat
      repeat inc(l); until CompareStructItem(Struct.Items[l], Struct.Items[Pivot]) >= 0;
      repeat dec(r); until CompareStructItem(Struct.Items[r], Struct.Items[Pivot]) <= 0;
      if l >= r then break;
      Struct.Exchange(l, r);
    until false;                                     
    if First < r then SortStruct(Struct, First, r);
    First := r+1;
  end;
end;

procedure TPSRemObjectsSdkPlugin.CompileImport1(CompExec: TPSScript);
var
  i, i1: Longint;
  Enum: TRODLEnum;
  TempType: TPSType;
  Struct: TRODLStruct;
  Arr: TRODLArray;
  RecType: TPSRecordFieldTypeDef;
  Service: TRODLService;
begin
  if FRODL = nil then exit;
  if CompExec.Comp.FindType('TDateTime') = nil then
    raise Exception.Create('Please register the DateUtils library first');
  if CompExec.Comp.FindType('TStream') = nil then
    raise Exception.Create('Please register the sysutils/classes library first');
  SIRegisterTROTRANSPORTCHANNEL(CompExec.Comp);
  SIRegisterTROMESSAGE(CompExec.Comp);
  SIRegister_uROClasses(CompExec.Comp);
  CompExec.Comp.AddTypeCopyN('Binary', 'TROBinaryMemoryStream');
  if CompExec.Comp.FindType('DateTime') = nil then
    CompExec.Comp.AddTypeCopyN('DateTime', 'TDateTime');
  if CompExec.Comp.FindType('Currency') = nil then
    CompExec.Comp.AddTypeCopyN('Currency', 'Double'); // for now
  for i := 0 to FRodl.EnumCount -1 do
  begin
    Enum := FRodl.Enums[i];
    TempType := CompExec.Comp.AddType(Enum.Info.Name, btEnum);
    for i1 := 0 to Enum.Count -1 do
    begin
      CompExec.Comp.AddConstant(Enum.Items[i1].Info.Name, TempType).SetUInt(i1);
    end;
  end;
  for i := 0 to FRodl.StructCount -1 do
  begin
    Struct := FRodl.Structs[i];
    SortStruct(Struct, 0, Struct.Count-1);
    TempType := CompExec.Comp.AddType('', btRecord);
    TempType.ExportName := True;
    TempType.Name := MkStructName(Struct);
    for i1 := 0 to Struct.Count -1 do
    begin
      RecType := TPSRecordType(TempType).AddRecVal;
      RecType.FieldOrgName := Struct.Items[i1].Info.Name;
      RecType.aType := CompExec.Comp.FindType(Struct.Items[i1].DataType);
      if RecType.aType = nil then begin
        Arr := fRodl.FindArray(Struct.Items[i1].DataType);
        if Arr <> nil then begin
          RecType.aType := CompExec.Comp.AddType(Arr.Info.Name, btArray);
          TPSArrayType(RecType.aType).ArrayTypeNo := CompExec.Comp.FindType(Arr.ElementType);
        end;
      end;
    end;
    CompExec.Comp.AddTypeCopy(Struct.Info.Name, TempType);
  end;
  for i := 0 to FRodl.ArrayCount -1 do
  begin
    Arr := FRodl.Arrays[i];
    TempType := CompExec.Comp.FindType(Arr.Info.Name);
    if TempType <> nil then begin
      if not (TempType is TPSArrayType) then begin
        CompExec.Comp.MakeError('ROPS', ecDuplicateIdentifier, Arr.Info.Name);
      end;
    end else begin
      TempType := CompExec.Comp.AddType(Arr.Info.Name, btArray);
    end;
    TPSArrayType(TempType).ArrayTypeNo := CompExec.Comp.FindType(Arr.ElementType);
  end;
  for i := 0 to FRodl.ServiceCount -1 do
  begin
    Service := FRodl.Services[i];
    TempType := CompExec.Comp.AddType(Service.Info.Name, btExtClass);
    TPSUndefinedClassType(TempType).ExtClass := TRoClass.Create(CompExec.Comp, Service, TempType);
  end;
  for i := 0 to FModules.Count -1 do
    TPSROModuleClass(FModules[i]).CompImp(CompExec.Comp);
end;

function TPSRemObjectsSdkPlugin.GetHaveRodl: Boolean;
begin
  Result := FRodl <> nil;
end;

procedure TPSRemObjectsSdkPlugin.ClearRodl;
begin
  FRodl.Free;
  FRodl := nil;
end;

procedure TPSRemObjectsSdkPlugin.ExecImport1(CompExec: TPSScript;
  const ri: TPSRuntimeClassImporter);
var
  i: Longint;
begin
  if FRODL = nil then exit;
  CompExec.Exec.AddSpecialProcImport('roclass', SProcImport, nil);
  RIRegisterTROTRANSPORTCHANNEL(ri);
  RIRegisterTROMESSAGE(ri);
  RIRegister_TROBinaryMemoryStream(ri);
  for i := 0 to FModules.Count -1 do
    TPSROModuleClass(FModules[i]).ExecImp(CompExec.Exec, ri);
end;

constructor TPSRemObjectsSdkPlugin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FModules := TList.Create;
  //FEnableSOAP := True;
  FEnableBinary := True;
  FEnableIndyTCP := True;
  FEnableIndyHTTP := True;
end;

procedure TPSRemObjectsSdkPlugin.Loaded;
begin
  inherited Loaded;
  ReloadModules;
end;

procedure TPSRemObjectsSdkPlugin.RegisterModule(
  Module: TPSROModuleClass);
begin
  FModules.Add(Module);
end;

procedure TPSRemObjectsSdkPlugin.ReloadModules;
begin
  FModules.Clear;
  if FEnableIndyTCP then RegisterModule(TPSROIndyTCPModule);
  if FEnableIndyHTTP then RegisterModule(TPSROIndyHTTPModule);
  //if FEnableSOAP then RegisterModule(TPSROSoapModule);
  if FEnableBinary then RegisterModule(TPSROBinModule);
  if assigned(FOnLoadModule) then
    FOnLoadModule(Self);
end;

{ TPSROModule }

class procedure TPSROModule.CompImp(comp: TPSPascalCompiler);
begin
  // do nothing
end;

class procedure TPSROModule.ExecImp(exec: TPSExec;
  ri: TPSRuntimeClassImporter);
begin
  // do nothing
end;

procedure IntRead(Exec: TPSExec; Serializer: TROSerializer;
  const Name: string; aVar: TPSVariantIFC; arridx: Longint);
var
  i: Longint;
  s, s2: string;
  r: TROStructure;
begin
  case aVar.aType.BaseType of
    btS64: Serializer.Read(Name, TypeInfo(int64), Int64(avar.Dta^), arridx);
    btu32: Serializer.Read(Name, TypeInfo(cardinal), Cardinal(avar.Dta^), arridx);
    bts32: Serializer.Read(Name, TypeInfo(longint), Longint(avar.Dta^), arridx);
    btu16: Serializer.Read(Name, TypeInfo(word), Word(aVar.Dta^), arridx);
    btS16: Serializer.Read(Name, TypeInfo(smallint), Smallint(aVar.Dta^), arridx);
    btu8: Serializer.Read(Name, TypeInfo(byte), Byte(aVar.Dta^), arridx);
    btS8: Serializer.Read(Name, TypeInfo(shortint), Shortint(aVar.Dta^), arridx);
    btDouble:
      begin
        if aVar.aType.ExportName = 'TDATETIME' then
          Serializer.Read(Name, TypeInfo(datetime), Double(avar.Dta^), arridx)
        else
          Serializer.Read(Name, TypeInfo(double), Double(aVar.Dta^), arridx);
      end;
    btSingle: Serializer.Read(Name, TypeInfo(single), Single(avar.Dta^), arridx);
    btExtended: Serializer.Read(Name, TypeInfo(extended), Extended(avar.dta^), arridx);
    btWideString: Serializer.Read(Name, TypeInfo(widestring), widestring(avar.dta^), arridx);
    btString: Serializer.Read(Name, TypeInfo(string), string(avar.dta^), arridx);
    btArray:
      begin
        if (TPSTypeRec_Array(avar.aType).ArrayType.BaseType = btRecord) then
        begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            r := TROStructure.Create(PSGetArrayField(avar, i), Exec);
            try
              Serializer.Read(Name, typeinfo(TROArray), r, i);
            finally
              r.Free;
            end;
          end;
        end else if (TPSTypeRec_Array(avar.aType).ArrayType.BaseType = btArray) then
        begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            r := TROArray.Create(PSGetArrayField(avar, i), Exec);
            try
              Serializer.Read(Name, typeinfo(TROArray), r, i);
            finally
              r.Free;
            end;
          end;
        end else begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            IntRead(Exec, Serializer, Name, PSGetArrayField(avar, i), i);
          end;
        end;
      end;
    btRecord:
      begin
        s := avar.aType.ExportName;
        if copy(s,1, 10) <> '!ROStruct!' then
          raise Exception.Create('Invalid structure: '+s);
        Delete(s,1,pos(',',s));
        for i := 0 to TPSTypeRec_Record(aVar.aType).FieldTypes.Count -1 do
        begin
          s2 := copy(s,1,pos(',',s)-1);
          delete(s,1,pos(',',s));
          if (TPSTypeRec(TPSTypeRec_Record(aVar.aType).FieldTypes[i]).BaseType = btRecord) then
          begin

            r := TROStructure.Create(PSGetRecField(aVar, i), Exec);
            try
              Serializer.Read(s2, typeinfo(TROStructure), r, -1);
            finally
              r.Free;
            end;
          end else if (TPSTypeRec(TPSTypeRec_Record(aVar.aType).FieldTypes[i]).BaseType = btArray)  then
          begin
            r := TROArray.Create(PSGetRecField(aVar, i), Exec);
            try
              Serializer.Read(s2, typeinfo(TROArray), r, -1);
            finally
              r.Free;
            end;
          end else
            IntRead(Exec, Serializer, s2, PSGetRecField(aVar, i), -1);
        end;
      end;
  else
    raise Exception.Create('Unable to read type');

  end;
end;

procedure IntWrite(Exec: TPSExec; Serializer: TROSerializer;
  const Name: string; aVar: TPSVariantIFC; arridx: Longint);
var
  i: Longint;
  s, s2: string;
  r: TROStructure;
begin
  case aVar.aType.BaseType of
    btS64: Serializer.Write(Name, TypeInfo(int64), Int64(avar.Dta^), arridx);
    btu32: Serializer.Write(Name, TypeInfo(cardinal), Cardinal(avar.Dta^), arridx);
    bts32: Serializer.Write(Name, TypeInfo(longint), Longint(avar.Dta^), arridx);
    btu16: Serializer.Write(Name, TypeInfo(word), Word(avar.Dta^), arridx);
    btS16: Serializer.Write(Name, TypeInfo(smallint), Smallint(aVar.Dta^), arridx);
    btu8: Serializer.Write(Name, TypeInfo(byte), Byte(aVar.Dta^), arridx);
    btS8: Serializer.Write(Name, TypeInfo(shortint), ShortInt(aVar.Dta^), arridx);
    btDouble:
      begin
        if aVar.aType.ExportName = 'TDATETIME' then
          Serializer.Write(Name, TypeInfo(datetime), Double(aVar.Dta^), arridx)
        else
          Serializer.Write(Name, TypeInfo(double), Double(aVar.Dta^), arridx);
      end;
    btSingle: Serializer.Write(Name, TypeInfo(single), Single(aVar.Dta^), arridx);
    btExtended: Serializer.Write(Name, TypeInfo(extended), Extended(aVar.Dta^), arridx);
    btWideString: Serializer.Write(Name, TypeInfo(widestring), WideString(aVar.Dta^), arridx);
    btString: Serializer.Write(Name, TypeInfo(string), String(aVar.Dta^), arridx);
    btArray:
      begin
        if (TPSTypeRec_Array(avar.aType).ArrayType.BaseType = btRecord) then
        begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            r := TROStructure.Create(PSGetArrayField(aVar, i), Exec);
            try
              Serializer.Write(Name, typeinfo(TROArray), r, i);
            finally
              r.Free;
            end;
          end;
        end else if (TPSTypeRec_Array(avar.aType).ArrayType.BaseType = btArray) then
        begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            r := TROArray.Create(PSGetArrayField(aVar, i), Exec);
            try
              Serializer.Write(Name, typeinfo(TROArray), r, i);
            finally
              r.Free;
            end;
          end;
        end else begin
          for i := 0 to PSDynArrayGetLength(Pointer(aVar.Dta^), aVar.aType) -1 do
          begin
            IntWrite(Exec, Serializer, Name, PSGetArrayField(aVar, i), i);
          end;
        end;
      end;
    btRecord:
      begin
        s := avar.aType.ExportName;
        if copy(s,1, 10) <> '!ROStruct!' then
          raise Exception.Create('Invalid structure: '+s);
        Delete(s,1,pos(',',s));
        for i := 0 to TPSTypeRec_Record(aVar.aType).FieldTypes.Count -1 do
        begin
          s2 := copy(s,1,pos(',',s)-1);
          delete(s,1,pos(',',s));
          if (TPSTypeRec(TPSTypeRec_Record(aVar.aType).FieldTypes[i]).BaseType = btRecord) then
          begin
            r := TROStructure.Create(PSGetRecField(aVar, i), Exec);
            try
              Serializer.Write(s2, typeinfo(TROStructure), r, -1);
            finally
              r.Free;
            end;
          end else if (TPSTypeRec(TPSTypeRec_Record(aVar.aType).FieldTypes[i]).BaseType = btArray)  then
          begin
            r := TROArray.Create(PSGetRecField(aVar, i), Exec);
            try
              Serializer.Write(s2, typeinfo(TROArray), r, -1);
            finally
              r.Free;
            end;
          end else
            IntWrite(Exec, Serializer, s2, PSGetRecField(aVar, i), -1);
        end;
      end;
  else
    raise Exception.Create('Unable to read type');

  end;
end;

{ TROStructure }

constructor TROStructure.Create(aVar: TPSVariantIfc; Exec: TPSExec);
begin
  inherited Create;
  FVar := aVar;
  FExec := Exec;
end;

function TROStructure.IsNull: Boolean;
begin
  Result := False;
end;

function TROStructure.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TROStructure.Read(Serializer: TROSerializer;
  const Name: string);
begin
  IntRead(FExec, Serializer, Name, FVar, -1);
end;

procedure TROStructure.SetNull(b: Boolean);
begin
  // null not supported
end;

function TROStructure.GetTypeName: string;
var
  s: string;
begin
  s := fvar.atype.ExportName;
  delete(s,1,1);
  delete(s,1,pos('!', s));
  result := copy(s,1,pos(',',s)-1);
end;

procedure TROStructure.Write(Serializer: TROSerializer;
  const Name: string);
begin
  IntWrite(FExec, Serializer, Name, FVar, -1);
end;


function TROStructure._AddRef: Integer;
begin
  // do nothing
  Result := 1;
end;

function TROStructure._Release: Integer;
begin
  // do nothing
  Result := 1;
end;

function TROStructure.CanImplementType(const aName: string): boolean;
begin
  if SameText(aName, Self.GetTypeName) then
    Result := True
  else
    Result := False;
end;

procedure TROStructure.SetTypeName(const s: string);
begin
  // Do nothing  
end;

{ TROArray }

function TROArray.GetCount: Longint;
begin

  // we should have an array in pVar now so assume that's true
  Result := PSDynArrayGetLength(Pointer(fVar.Dta^), fvar.aType);
end;

procedure TROArray.SetCount(l: Integer);
begin
  PSDynArraySetLength(Pointer(fVAr.Dta^), fVar.aType, l);
end;

end.
