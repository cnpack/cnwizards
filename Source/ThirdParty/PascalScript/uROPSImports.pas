unit uROPSImports;

interface

uses
  uPSCompiler, uPSRuntime, uROBINMessage, uROIndyHTTPChannel,
  uROXMLSerializer, uROIndyTCPChannel, idTcpClient,
  uROPSServerLink, uROWinInetHttpChannel;


procedure SIRegisterTROBINMESSAGE(CL: TIFPSPascalCompiler);
procedure SIRegisterTROINDYHTTPCHANNEL(CL: TIFPSPascalCompiler);
procedure SIRegisterTROINDYTCPCHANNEL(CL: TIFPSPascalCompiler);
procedure SIRegisterTIDTCPCLIENT(CL: TIFPSPascalCompiler);
procedure SIRegisterRODLImports(Cl: TIFPSPascalCompiler);



procedure RIRegisterTROBINMESSAGE(Cl: TIFPSRuntimeClassImporter);
procedure RIRegisterTROINDYHTTPCHANNEL(Cl: TIFPSRuntimeClassImporter);
procedure RIRegisterTROINDYTCPCHANNEL(Cl: TIFPSRuntimeClassImporter);
procedure RIRegisterTIDTCPCLIENT(Cl: TIFPSRuntimeClassImporter);
procedure RIRegisterRODLImports(CL: TIFPSRuntimeClassImporter);
(*
Todo:
     TROWinInetHTTPChannel = class(TROTransportChannel, IROTransport, IROTCPTransport, IROHTTPTransport)
     published
       property UserAgent:string read GetUserAgent write SetUserAgent;
       property TargetURL : string read fTargetURL write SetTargetURL;
       property StoreConnected:boolean read fStoreConnected write fStoreConnected default false;
       property KeepConnection:boolean read fKeepConnection write fKeepConnection default false;
     end;
*)
type
  
  TPSROIndyTCPModule = class(TPSROModule)
  protected
    class procedure ExecImp(exec: TIFPSExec; ri: TIFPSRuntimeClassImporter); override;
    class procedure CompImp(comp: TIFPSPascalCompiler); override;
  end;
  
  TPSROIndyHTTPModule = class(TPSROModule)
  protected
    class procedure ExecImp(exec: TIFPSExec; ri: TIFPSRuntimeClassImporter); override;
    class procedure CompImp(comp: TIFPSPascalCompiler); override;
  end;
  
  TPSROBinModule = class(TPSROModule)
  protected
    class procedure ExecImp(exec: TIFPSExec; ri: TIFPSRuntimeClassImporter); override;
    class procedure CompImp(comp: TIFPSPascalCompiler); override;
  end;


implementation

{procedure TROSOAPMESSAGESERIALIZATIONOPTIONS_W(Self: TROSOAPMESSAGE;
  const T: TXMLSERIALIZATIONOPTIONS);
begin 
  Self.SERIALIZATIONOPTIONS := T; 
end;

procedure TROSOAPMESSAGESERIALIZATIONOPTIONS_R(Self: TROSOAPMESSAGE;
  var T: TXMLSERIALIZATIONOPTIONS);
begin 
  T := Self.SERIALIZATIONOPTIONS; 
end;

procedure TROSOAPMESSAGECUSTOMLOCATION_W(Self: TROSOAPMESSAGE; const T: string);
begin 
  Self.CUSTOMLOCATION := T; 
end;

procedure TROSOAPMESSAGECUSTOMLOCATION_R(Self: TROSOAPMESSAGE; var T: string);
begin 
  T := Self.CUSTOMLOCATION; 
end;

procedure TROSOAPMESSAGELIBRARYNAME_W(Self: TROSOAPMESSAGE; const T: string);
begin 
  Self.LIBRARYNAME := T; 
end;

procedure TROSOAPMESSAGELIBRARYNAME_R(Self: TROSOAPMESSAGE; var T: string);
begin 
  T := Self.LIBRARYNAME; 
end; }

procedure TROBINMESSAGEUSECOMPRESSION_W(Self: TROBINMESSAGE; const T: boolean);
begin 
  Self.USECOMPRESSION := T; 
end;

procedure TROBINMESSAGEUSECOMPRESSION_R(Self: TROBINMESSAGE; var T: boolean);
begin 
  T := Self.USECOMPRESSION; 
end;

procedure TROINDYHTTPCHANNELTARGETURL_W(Self: TROINDYHTTPCHANNEL; const T: string);
begin 
  Self.TARGETURL := T; 
end;

procedure TROINDYHTTPCHANNELTARGETURL_R(Self: TROINDYHTTPCHANNEL; var T: string);
begin 
  T := Self.TARGETURL; 
end;

procedure TROINDYTCPCHANNELINDYCLIENT_R(Self: TROINDYTCPCHANNEL; var T: TIdTCPClientBaseClass);
begin 
  T := Self.INDYCLIENT; 
end;

procedure TIDTCPCLIENTPORT_W(Self: TIDTCPCLIENT; const T: integer);
begin 
  Self.PORT := T; 
end;

procedure TIDTCPCLIENTPORT_R(Self: TIdTCPClientBaseClass; var T: integer);
begin 
  T := TIdIndy10HackClient(Self).PORT;
end;

procedure TIDTCPCLIENTHOST_W(Self: TIdTCPClientBaseClass; const T: string);
begin 
  TIdIndy10HackClient(Self).HOST := T;
end;

procedure TIDTCPCLIENTHOST_R(Self: TIdTCPClientBaseClass; var T: string);
begin 
  T := TIdIndy10HackClient(Self).HOST; 
end;

{procedure TIDTCPCLIENTBOUNDPORT_W(Self: TIdTCPClientBaseClass; const T: integer);
begin 
  Self.BOUNDPORT := T; 
end;

procedure TIDTCPCLIENTBOUNDPORT_R(Self: TIdTCPClientBaseClass; var T: integer);
begin 
  T := Self.BOUNDPORT; 
end;

procedure TIDTCPCLIENTBOUNDIP_W(Self: TIdTCPClientBaseClass; const T: string);
begin 
  Self.BOUNDIP := T; 
end;

procedure TIDTCPCLIENTBOUNDIP_R(Self: TIdTCPClientBaseClass; var T: string);
begin 
  T := Self.BOUNDIP; 
end;]

procedure TIDTCPCLIENTBOUNDPORTMIN_W(Self: TIdTCPClientBaseClass; const T: integer);
begin 
  Self.BOUNDPORTMIN := T; 
end;

procedure TIDTCPCLIENTBOUNDPORTMIN_R(Self: TIdTCPClientBaseClass; var T: integer);
begin 
  T := Self.BOUNDPORTMIN; 
end;

procedure TIDTCPCLIENTBOUNDPORTMAX_W(Self: TIdTCPClientBaseClass; const T: integer);
begin 
  Self.BOUNDPORTMAX := T; 
end;

procedure TIDTCPCLIENTBOUNDPORTMAX_R(Self: TIdTCPClientBaseClass; var T: integer);
begin 
  T := Self.BOUNDPORTMAX; 
end;

{procedure RIRegisterTROSOAPMESSAGE(Cl: TIFPSRuntimeClassImporter);
begin
  with Cl.Add(TROSOAPMESSAGE) do
  begin
    RegisterPropertyHelper(@TROSOAPMESSAGELIBRARYNAME_R, @TROSOAPMESSAGELIBRARYNAME_W,
      'LIBRARYNAME');
    RegisterPropertyHelper(@TROSOAPMESSAGECUSTOMLOCATION_R,
      @TROSOAPMESSAGECUSTOMLOCATION_W, 'CUSTOMLOCATION');
    RegisterPropertyHelper(@TROSOAPMESSAGESERIALIZATIONOPTIONS_R,
      @TROSOAPMESSAGESERIALIZATIONOPTIONS_W, 'SERIALIZATIONOPTIONS');
  end;
end; }

procedure RIRegisterTROBINMESSAGE(Cl: TIFPSRuntimeClassImporter);
begin
  with Cl.Add(TROBINMESSAGE) do
  begin
    RegisterPropertyHelper(@TROBINMESSAGEUSECOMPRESSION_R,
      @TROBINMESSAGEUSECOMPRESSION_W, 'USECOMPRESSION');
  end;
end;

procedure RIRegisterTROINDYHTTPCHANNEL(Cl: TIFPSRuntimeClassImporter);
begin
  with Cl.Add(TROINDYHTTPCHANNEL) do
  begin
    RegisterPropertyHelper(@TROINDYHTTPCHANNELTARGETURL_R,
      @TROINDYHTTPCHANNELTARGETURL_W, 'TARGETURL');
  end;
end;

procedure RIRegisterTROINDYTCPCHANNEL(Cl: TIFPSRuntimeClassImporter);
begin
  with Cl.Add(TROINDYTCPCHANNEL) do
  begin
    RegisterPropertyHelper(@TROINDYTCPCHANNELINDYCLIENT_R, nil, 'INDYCLIENT');
  end;
end;

procedure RIRegisterTIDTCPCLIENT(Cl: TIFPSRuntimeClassImporter);
begin
  with Cl.Add(TIdTCPClientBaseClass) do
  begin
    {RegisterPropertyHelper(@TIDTCPCLIENTBOUNDPORTMAX_R, @TIDTCPCLIENTBOUNDPORTMAX_W,
      'BOUNDPORTMAX');
    RegisterPropertyHelper(@TIDTCPCLIENTBOUNDPORTMIN_R, @TIDTCPCLIENTBOUNDPORTMIN_W,
      'BOUNDPORTMIN');
    RegisterPropertyHelper(@TIDTCPCLIENTBOUNDIP_R, @TIDTCPCLIENTBOUNDIP_W, 'BOUNDIP');
    RegisterPropertyHelper(@TIDTCPCLIENTBOUNDPORT_R, @TIDTCPCLIENTBOUNDPORT_W,
      'BOUNDPORT');}
    RegisterPropertyHelper(@TIDTCPCLIENTHOST_R, @TIDTCPCLIENTHOST_W, 'HOST');
    RegisterPropertyHelper(@TIDTCPCLIENTPORT_R, @TIDTCPCLIENTPORT_W, 'PORT');
  end;
end;

procedure RIRegisterRODLImports(CL: TIFPSRuntimeClassImporter);
begin
  RIRegisterTIDTCPCLIENT(Cl);
  RIRegisterTROINDYTCPCHANNEL(Cl);
  RIRegisterTROINDYHTTPCHANNEL(Cl);
  RIRegisterTROBINMESSAGE(Cl);
  //RIRegisterTROSOAPMESSAGE(Cl);
end;

function RegClassS(cl: TIFPSPascalCompiler; const InheritsFrom,
  ClassName: string): TPSCompileTimeClass;
begin
  Result := cl.FindClass(ClassName);
  if Result = nil then
    Result := cl.AddClassN(cl.FindClass(InheritsFrom), ClassName)
  else
    Result.ClassInheritsFrom := cl.FindClass(InheritsFrom);
end;

{procedure SIRegisterTROSOAPMESSAGE(CL: TIFPSPascalCompiler);
begin
  Cl.addTypeS('TXMLSERIALIZATIONOPTIONS', 'BYTE');
  Cl.AddConstantN('XSOWRITEMULTIREFARRAY', 'BYTE').SetInt(1);
  Cl.AddConstantN('XSOWRITEMULTIREFOBJECT', 'BYTE').SetInt(2);
  Cl.AddConstantN('XSOSENDUNTYPED', 'BYTE').SetInt(4);
  with RegClassS(cl, 'TROMESSAGE', 'TROSOAPMESSAGE') do
  begin
    RegisterProperty('LIBRARYNAME', 'STRING', iptrw);
    RegisterProperty('CUSTOMLOCATION', 'STRING', iptrw);
    RegisterProperty('SERIALIZATIONOPTIONS', 'TXMLSERIALIZATIONOPTIONS', iptrw);
  end;
end;}

procedure SIRegisterTROBINMESSAGE(CL: TIFPSPascalCompiler);
begin
  with RegClassS(cl, 'TROMESSAGE', 'TROBINMESSAGE') do
  begin
    RegisterProperty('USECOMPRESSION', 'BOOLEAN', iptrw);
  end;
end;

procedure SIRegisterTROINDYHTTPCHANNEL(CL: TIFPSPascalCompiler);
begin
  with RegClassS(cl, 'TROINDYTCPCHANNEL', 'TROINDYHTTPCHANNEL') do
  begin
    RegisterProperty('TARGETURL', 'STRING', iptrw);
  end;
end;

procedure SIRegisterTROINDYTCPCHANNEL(CL: TIFPSPascalCompiler);
begin
  with RegClassS(cl, 'TROTRANSPORTCHANNEL', 'TROINDYTCPCHANNEL') do
  begin
    RegisterProperty('INDYCLIENT', 'TIdTCPClientBaseClass', iptr);
  end;
end;

procedure SIRegisterTIDTCPCLIENT(CL: TIFPSPascalCompiler);
begin
  with RegClassS(cl, 'TCOMPONENT', 'TIdTCPClientBaseClass') do
  begin
    RegisterProperty('BOUNDPORTMAX', 'INTEGER', iptrw);
    RegisterProperty('BOUNDPORTMIN', 'INTEGER', iptrw);
    RegisterProperty('BOUNDIP', 'STRING', iptrw);
    RegisterProperty('BOUNDPORT', 'INTEGER', iptrw);
    RegisterProperty('HOST', 'STRING', iptrw);
    RegisterProperty('PORT', 'INTEGER', iptrw);
  end;
end;

procedure SIRegisterRODLImports(Cl: TIFPSPascalCompiler);
begin
  SIRegisterTIDTCPCLIENT(Cl);
  SIRegisterTROINDYTCPCHANNEL(Cl);
  SIRegisterTROINDYHTTPCHANNEL(Cl);
  SIRegisterTROBINMESSAGE(Cl);
  //SIRegisterTROSOAPMESSAGE(Cl);
end;

{ TPSROIndyTCPModule }

class procedure TPSROIndyTCPModule.CompImp(comp: TIFPSPascalCompiler);
begin
  SIRegisterTIDTCPCLIENT(Comp);
  SIRegisterTROINDYTCPCHANNEL(Comp);
end;

class procedure TPSROIndyTCPModule.ExecImp(exec: TIFPSExec;
  ri: TIFPSRuntimeClassImporter);
begin
  RIRegisterTIDTCPCLIENT(ri);
  RIRegisterTROINDYTCPCHANNEL(ri);
end;

{ TPSROIndyHTTPModule }

class procedure TPSROIndyHTTPModule.CompImp(comp: TIFPSPascalCompiler);
begin
  if Comp.FindClass('TROINDYTCPCHANNEL') = nil then
    TPSROIndyTCPModule.CompImp(Comp);
  SIRegisterTROINDYHTTPCHANNEL(Comp);
end;

class procedure TPSROIndyHTTPModule.ExecImp(exec: TIFPSExec;
  ri: TIFPSRuntimeClassImporter);
begin
  if ri.FindClass('TROINDYTCPCHANNEL') = nil then
    TPSROIndyTCPModule.ExecImp(exec, ri);
  RIRegisterTROINDYHTTPCHANNEL(ri);
end;

{ TPSROSoapModule }

{class procedure TPSROSoapModule.CompImp(comp: TIFPSPascalCompiler);
begin
  SIRegisterTROSOAPMESSAGE(comp);
end;

class procedure TPSROSoapModule.ExecImp(exec: TIFPSExec;
  ri: TIFPSRuntimeClassImporter);
begin
  RIRegisterTROSOAPMESSAGE(ri);
end;}

{ TPSROBinModule }

class procedure TPSROBinModule.CompImp(comp: TIFPSPascalCompiler);
begin
  SIRegisterTROBINMESSAGE(Comp);
end;

class procedure TPSROBinModule.ExecImp(exec: TIFPSExec;
  ri: TIFPSRuntimeClassImporter);
begin
  RIRegisterTROBINMESSAGE(ri);
end;

end.
