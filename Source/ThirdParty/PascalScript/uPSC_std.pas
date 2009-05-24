{ Compiletime TObject, TPersistent and TComponent definitions }
unit uPSC_std;
{$I PascalScript.inc}
interface
uses
  uPSCompiler, uPSUtils;

{
  Will register files from:
    System
    Classes (Only TComponent and TPersistent)
 
}

procedure SIRegister_Std_TypesAndConsts(Cl: TPSPascalCompiler);
procedure SIRegisterTObject(CL: TPSPascalCompiler);
procedure SIRegisterTPersistent(Cl: TPSPascalCompiler);
procedure SIRegisterTComponent(Cl: TPSPascalCompiler);

procedure SIRegister_Std(Cl: TPSPascalCompiler);

implementation

procedure SIRegisterTObject(CL: TPSPascalCompiler);
begin
  with Cl.AddClassN(nil, 'TOBJECT') do
  begin
    RegisterMethod('constructor Create');
    RegisterMethod('procedure Free');
  end;
end;

procedure SIRegisterTPersistent(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TObject'), 'TPERSISTENT') do
  begin
    RegisterMethod('procedure Assign(Source: TPersistent)');
  end;
end;

procedure SIRegisterTComponent(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TPersistent'), 'TCOMPONENT') do
  begin
    RegisterMethod('function FindComponent(AName: string): TComponent;');
    RegisterMethod('constructor Create(AOwner: TComponent); virtual;');

    RegisterProperty('Owner', 'TComponent', iptRW);
    RegisterMethod('procedure DESTROYCOMPONENTS');
    RegisterMethod('procedure DESTROYING');
    RegisterMethod('procedure FREENOTIFICATION(ACOMPONENT:TCOMPONENT)');
    RegisterMethod('procedure INSERTCOMPONENT(ACOMPONENT:TCOMPONENT)');
    RegisterMethod('procedure REMOVECOMPONENT(ACOMPONENT:TCOMPONENT)');
    RegisterProperty('COMPONENTS', 'TCOMPONENT INTEGER', iptr);
    RegisterProperty('COMPONENTCOUNT', 'INTEGER', iptr);
    RegisterProperty('COMPONENTINDEX', 'INTEGER', iptrw);
    RegisterProperty('COMPONENTSTATE', 'Byte', iptr);
    RegisterProperty('DESIGNINFO', 'LONGINT', iptrw);
    RegisterProperty('NAME', 'STRING', iptrw);
    RegisterProperty('TAG', 'LONGINT', iptrw);
  end;
end;




procedure SIRegister_Std_TypesAndConsts(Cl: TPSPascalCompiler);
begin
  Cl.AddTypeS('TComponentStateE', '(csLoading, csReading, csWriting, csDestroying, csDesigning, csAncestor, csUpdating, csFixups, csFreeNotification, csInline, csDesignInstance)');
  cl.AddTypeS('TComponentState', 'set of TComponentStateE');
  Cl.AddTypeS('TRect', 'record Left, Top, Right, Bottom: Integer; end;');
end;

procedure SIRegister_Std(Cl: TPSPascalCompiler);
begin
  SIRegister_Std_TypesAndConsts(Cl);
  SIRegisterTObject(CL);
  SIRegisterTPersistent(Cl);
  SIRegisterTComponent(Cl);
end;

// PS_MINIVCL changes by Martijn Laan (mlaan at wintax _dot_ nl)


End.

