unit DCURecs;
(*
The DCU records module of the DCU32INT utility by Alexei Hmelnov.
It contains classes for representation of DCU declarations and
definitions in memory. 
----------------------------------------------------------------------------
E-Mail: alex@icc.ru
http://hmelnov.icc.ru/DCU/
----------------------------------------------------------------------------

See the file "readme.txt" for more details.

------------------------------------------------------------------------
                             IMPORTANT NOTE:
This software is provided 'as-is', without any expressed or implied warranty.
In no event will the author be held liable for any damages arising from the
use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented, you must not
   claim that you wrote the original software.
2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.
3. This notice may not be removed or altered from any source
   distribution.
*)

{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  SysUtils, Classes, DCU_In, DCU_Out, DasmDefs, FixUp;

type
{ Auxiliary data types }

PLocVarRec = ^TLocVarRec;
TLocVarRec = record
  sym: integer; //Symbol # in the symbol table, 0 - proc data end
  ofs: integer; //Offset in procedure code
  frame: integer; //-1(0x7f)-symbol end, else - symbol start 0-EAX, 1-EDX,
    //2-ECX, 3-EBX, 4-ESI...
end ;

PLocVarTbl = ^TLocVarTbl;
TLocVarTbl = array[Word] of TLocVarRec;

TDeclListKind = (dlMain,dlMainImpl,dlArgs,dlArgsT,dlEmbedded,dlFields,
  dlClass,dlInterface,dlDispInterface,dlUnitAddInfo);

TDeclSecKind = (skNone,skLabel,skConst,skType,skVar,skThreadVar,skResStr,
  skExport,skProc,skPrivate,skProtected,skPublic,skPublished);

type

PTDCURec = ^TDCURec;
TDCURec = class
  Next: TDCURec;
  function GetName: PName; virtual; abstract;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; virtual;
  function NameIsUnique: boolean; virtual;
  procedure ShowName; virtual; abstract;
  procedure Show; virtual; abstract;
  property Name: PName read GetName;
end ;

TBaseDef = class(TDCURec)
  FName: PName;
  Def: PDef;
  hUnit: integer;
  constructor Create(AName: PName; ADef: PDef; AUnit: integer);
  procedure ShowName; override;
  procedure Show; override;
  procedure ShowNamed(N: PName);
  function GetName: PName; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
end ;

TImpKind=Char;

TImpDef = class(TBaseDef)
  ik: TImpKind;
  FNameIsUnique: boolean;
//  ImpRec: TDCURec;
  Inf: integer;
  constructor Create(AIK: TImpKind; AName: PName; AnInf: integer; ADef: PDef; AUnit: integer);
  procedure Show; override;
//  procedure GetImpRec;
  function NameIsUnique: boolean; override;
end ;

TDLLImpRec = class(TBaseDef{TImpDef})
  NDX: integer;
  constructor Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
  procedure Show; override;
end ;

TImpTypeDefRec = class(TImpDef{TBaseDef})
  RTTIOfs,RTTISz: Cardinal; //L: Byte;
  hImpUnit: integer;
  ImpName: PName;
  constructor Create(AName: PName; AnInf: integer; ARTTISz: Cardinal{AL: Byte}; ADef: PDef; AUnit: integer);
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
end ;

type

TNameDecl = class(TDCURec)
  Def: PNameDef;
  hDecl: integer;
  constructor Create0;
  constructor Create;
  destructor Destroy; override;
  procedure ShowName; override;
  procedure Show; override;
  procedure ShowDef(All: boolean); virtual;
  function GetName: PName; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; virtual;
  function IsVisible(LK: TDeclListKind): boolean; virtual;
  function GetTag: TDCURecTag;
end ;

TNameFDecl = class(TNameDecl)
  F: TNDX;
  Inf: integer;
  B2: TNDX; //D8+
  constructor Create(NoInf: boolean);
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TTypeDecl = class(TNameFDecl)
  hDef: TDefNDX;
  constructor Create;
  function IsVisible(LK: TDeclListKind): boolean; override;
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TVarDecl = class(TNameFDecl)
  hDT: TDefNDX;
  Ofs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TVarCDecl = class(TVarDecl)
  Sz: Cardinal;
  OfsR: Cardinal;
  constructor Create(OfsValid: boolean);
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TAbsVarDecl = class(TVarDecl)
  procedure Show; override;
end ;

TTypePDecl = class(TVarCDecl{TTypeDecl})
  {B1: Byte;
  constructor Create;}
  constructor Create;
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TThreadVarDecl = class(TVarDecl)
  function GetSecKind: TDeclSecKind; override;
end ;

//In Delphi>=8 they started to create this kind of records for string constants
TStrConstDecl = class({TVarCDecl}TNameFDecl)
  hDT: TDefNDX;
  Ofs: Cardinal;
  Sz: Cardinal;
  constructor Create;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
  procedure Show; override;
end ;



TLabelDecl = class(TNameDecl)
  Ofs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TExportDecl = class(TNameDecl)
  hSym,Index: TNDX;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TLocalDecl = class(TNameDecl)
  LocFlags: TNDX;
  hDT: TDefNDX;
  NDXB: TNDX;//B: Byte; //Interface only
  Ndx: TNDX;
  constructor Create(LK: TDeclListKind);
  procedure Show; override;
  function GetLocFlagsSecKind: TDeclSecKind;
  function GetSecKind: TDeclSecKind; override;
end ;

TMethodDecl = class(TLocalDecl)
  InIntrf: boolean;
  hImport: TNDX; //for property P:X read Proc{virtual,Implemented in parent class}
  //VMTNDX: integer; //Offset in VMT of VM=VMTNDX*SizeOf(Pointer)
  constructor Create(LK: TDeclListKind);
  procedure Show; override;
end ;

TClassVarDecl = class(TLocalDecl)
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

{TSetDeft struc pas
  sd: Cardinal;
ends
}

TPropDecl = class(TNameDecl)
  LocFlags: TNDX;
  hDT: TNDX;
  NDX: TNDX;
  hIndex: TNDX;
  hRead: TNDX;
  hWrite: TNDX;
  hStored: TNDX;
  hDeft: TNDX;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TDispPropDecl = class(TLocalDecl)
  procedure Show; override;
end ;

TConstDeclBase = class(TNameFDecl)
  hDT: TDefNDX;
  hX: Cardinal; //Ver>4
  ValPtr: Pointer;
  ValSz: Cardinal;
  Val: integer;
  constructor Create;
  procedure ReadConstVal;
  procedure ShowValue;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TConstDecl = class(TConstDeclBase)
  constructor Create;
end ;
{
TResStrDef = class(TConstDeclBase)
  NDX: TNDX;
  NDX1: TNDX;
  B1: Byte;
  B2: Byte;
  V: TNDX; //Data type again - AnsiString
  RefOfs,RefSz: Cardinal;
  constructor Create;
  procedure Show; override;
  procedure SetMem(MOfs,MSz: Cardinal); override;
end ;}

TResStrDef = class(TVarCDecl)
  OfsR: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

TSetDeftInfo=class(TNameDecl{TDCURec, but it should be included into NameDecl list})
  hConst,hArg: TDefNDX;
  constructor Create;
  procedure Show; override;
end ;

TCopyDecl = class(TNameDecl)
  hBase: TDefNDX;
  Base: TNameDecl; //Just in case and for convenience
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

(*
TProcDeclBase = class(TNameDecl)
  CodeOfs,AddrBase: Cardinal;
  Sz: TDefNDX;
  constructor Create;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
end ;
*)

TProcCallKind = (pcRegister,pcCdecl,pcPascal,pcStdCall,pcSafeCall);

TMethodKind = (mkProc,mkMethod,mkConstructor,mkDestructor);

TProcDecl = class(TNameFDecl{TProcDeclBase})
  CodeOfs,AddrBase: Cardinal;
  Sz: TDefNDX;
 {---}
  B0: TNDX;
  VProc: TNDX;
  hDTRes: TNDX;
  Args: TNameDecl;
  Locals: TNameDecl;
  Embedded: TNameDecl;
  CallKind: TProcCallKind;
  MethodKind: TMethodKind; //may be this information is encoded by some flag, but
    //I can't detect it. May be it would be enough to analyse the structure of
    //the procedure name, but this way it will be safer.
  FProcLocVarTbl: PLocVarTbl;
  FProcLocVarCnt: integer;
  constructor Create(AnEmbedded: TNameDecl; NoInf: boolean);
  destructor Destroy; override;
  function IsUnnamed: boolean;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function GetSecKind: TDeclSecKind; override;
  procedure ShowArgs;
  function IsProc: boolean;
  procedure ShowDef(All: boolean); override;
  procedure Show; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
  function GetRegDebugInfo(ProcOfs: integer; hReg: THBMName; Ofs: integer): String;
end ;

TSysProcDecl = class(TNameDecl{TProcDeclBase})
  F: TNDX;
  Ndx: TNDX;
//  CodeOfs: Cardinal;
  constructor Create;
  procedure Show; override;
  function GetSecKind: TDeclSecKind; override;
end ;

//Starting from Delphi 8 Borlands begin to give complete proc. defs to system
//procedures
TSysProc8Decl = class(TProcDecl)
  F: TNDX;
  Ndx: TNDX;
//  CodeOfs: Cardinal;
  constructor Create;
//  procedure Show; override;
end ;



(*
TAtDecl = class(TNameDecl)
  //May be start of implementation?
  NDX: TNDX;
  NDX1: TNDX;
  constructor Create;
  procedure Show; virtual;
end ;
*)

TUnitAddInfo = class(TNameFDecl)
 //Ver 8.0 and higher, MSIL
  B: TNDX;
  Sub: TNameDecl;
  constructor Create;
  destructor Destroy; override;
  function IsVisible(LK: TDeclListKind): boolean; override;
end ;

TSpecVar = class(TVarDecl)
  procedure Show; override;
end ;

(*
TAddInfo6 = class(TNameDecl)
  V0,V1,V2,V3: TNDX;
  Ofs: Cardinal;
  Sz: Cardinal;
  constructor Create;
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
end ;
*)
type

TTypeDef = class(TBaseDef)
//  hDecl: integer;
  RTTISz: TNDX; //Size of RTTI for type, if available
  Sz: TNDX; //Size of corresponding variable
  V: TNDX;
  RTTIOfs: Cardinal;
  constructor Create;
  destructor Destroy; override;
  procedure ShowBase;
  procedure Show; override;
  function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; virtual;
  function GetOfsQualifier(Ofs: integer): String; virtual;
  function GetRefOfsQualifier(Ofs: integer): String; virtual;
end ;

TRangeBaseDef = class(TTypeDef)
  hDTBase: TNDX;
  LH: Pointer;
  {Lo: TNDX;
  Hi: TNDX;}
  B: Byte;
  procedure GetRange(var Lo,Hi: TInt64Rec);
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TRangeDef = class(TRangeBaseDef)
  constructor Create;
end ;

TEnumDef = class(TRangeBaseDef)
  Ndx: TNDX;
  NameTbl: TList;
  constructor Create;
  destructor Destroy; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TFloatDef = class(TTypeDef)
  B: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TPtrDef = class(TTypeDef)
  hRefDT: TNDX;
  constructor Create;
  function ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
  function GetRefOfsQualifier(Ofs: integer): String; override;
end ;

TTextDef = class(TTypeDef)
  procedure Show; override;
end ;

TFileDef = class(TTypeDef)
  hBaseDT: TNDX;
  constructor Create;
  procedure Show; override;
end ;

TSetDef = class(TTypeDef)
  BStart: Byte; //0-based start byte number
  hBaseDT: TNDX;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TArrayDef = class(TTypeDef)
  B1: Byte;
  hDTNdx: TNDX;
  hDTEl: TNDX;
  constructor Create(IsStr: boolean);
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
  function GetOfsQualifier(Ofs: integer): String; override;
end ;

TShortStrDef = class(TArrayDef)
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TStringDef = class(TArrayDef)
  function ShowStrConst(DP: Pointer; DS: Cardinal): integer {Size used};
  function ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
end ;

TVariantDef = class(TTypeDef)
  B: byte;
  constructor Create;
  procedure Show; override;
end ;

TObjVMTDef = class(TTypeDef)
  hObjDT: TNDX;
  Ndx1: TNDX;
  constructor Create;
  procedure Show; override;
end ;

TRecBaseDef = class(TTypeDef)
  Fields: TNameDecl;
  procedure ReadFields(LK: TDeclListKind);
  function ShowFieldValues(DP: Pointer; DS: Cardinal): integer {Size used};
  destructor Destroy; override;
  function GetParentType: TNDX; virtual;
  function GetFldOfsQualifier(Ofs: integer; TotSize: integer; Sorted: boolean): String;
  function GetFldProperty(Fld: TNameDecl; hDT: TNDX): TPropDecl;
end ;

TRecDef = class(TRecBaseDef)
  B2: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
  function GetOfsQualifier(Ofs: integer): String; override;
end ;

TProcTypeDef = class(TRecBaseDef)
  NDX0: TNDX;//B0: Byte; //Ver>2
  hDTRes: TNDX;
  AddStart: Pointer;
  AddSz: Cardinal; //Ver>2
  CallKind: TProcCallKind;
  constructor Create;
  function IsProc: boolean;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  function ProcStr: String;
  procedure ShowDecl(Braces: PChar);
  procedure Show; override;
end ;

TObjDef = class(TRecBaseDef)
  B03: Byte;
  hParent: TNDX;
  BFE: Byte;
  Ndx1: TNDX;
  B00: Byte;
  constructor Create;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
  function GetParentType: TNDX; override;
  function GetOfsQualifier(Ofs: integer): String; override;
end ;

TClassDef = class(TRecBaseDef)
  hParent: TNDX;
//  InstBase: TTypeDef;
  InstBaseRTTISz: TNDX; //Size of RTTI for the type, if available
  InstBaseSz: TNDX; //Size of corresponding variable
  InstBaseV: TNDX;
  VMCnt: TNDX;//number of virtual methods
  NdxFE: TNDX;//BFE: Byte
  Ndx00a: TNDX;//B00a: Byte
  B04: TNDX;
//%$IF Ver>2;
  ICnt: TNDX;
// DAdd: case @.B00b=0 of
  {DAddB0: Byte;
  DAddB1: Byte;}
  ITbl: PNDXTbl;
// endc
//$END
  constructor Create;
  destructor Destroy; override;
  function ShowValue(DP: Pointer; DS: Cardinal): integer {Size used}; override;
  procedure Show; override;
  function GetParentType: TNDX; override;
  function GetRefOfsQualifier(Ofs: integer): String; override;
  procedure ReadBeforeIntf; virtual;
end ;

TMetaClassDef = class(TClassDef)
  hCl: TNDX;
  procedure ReadBeforeIntf; override;
end ;

TInterfaceDef = class(TRecBaseDef)
  hParent: TNDX;
  VMCnt: TNDX;
  GUID: PGUID;
  B: Byte;
  constructor Create;
  procedure Show; override;
end ;

TVoidDef = class(TTypeDef)
  procedure Show; override;
end ;

{TStrConstTypeDef = class(TTypeDef)
  hBase: TNDX;
  constructor Create;
  procedure Show; override;
end ;}

const
  NoName: ShortString='?';

const
{Register, where register variable is located,
 I am not sure that it is valid for smaller than 4 bytes variables}
  RegName: array[0..6] of String[3] =
    ('EAX','EDX','ECX','EBX','ESI','EDI','EBP');

var                  // Added by Liu Xiao for Delphi 2009
  Ver: Integer = 0;

procedure FreeDCURecList(L: TDCURec);
function GetDCURecListEnd(L: TDCURec): PTDCURec;

implementation

uses
  DCU32, op;

procedure FreeDCURecList(L: TDCURec);
var
  Tmp: TDCURec;
begin
  while L<>Nil do begin
    Tmp := L;
    L := L.Next;
    Tmp.Free;
  end ;
end ;

function GetDCURecListEnd(L: TDCURec): PTDCURec;
begin
  Result := @L;
  while Result^<>Nil do
    Result := @Result^.Next;
end ;

{ TDCURec. }
function TDCURec.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  DCUErrorFmt('Trying to set memory 0x%x[0x%x] to %s',[MOfs,MSz,Name^]);
end ;

function TDCURec.NameIsUnique: boolean;
begin
  Result := false;
end ;

{ TBaseDef. }
constructor TBaseDef.Create(AName: PName; ADef: PDef; AUnit: integer);
begin
  inherited Create;
  FName := AName;
  Def := ADef;
  hUnit := AUnit;
end ;

procedure TBaseDef.ShowName;
var
  U: PUnitImpRec;
  NP: PName;
begin
  NP := FName;
  if (NP=Nil)or(NP^[0]=#0) then
    NP := @NoName;
  if hUnit<0 then begin
    if NP^[0]<>#0 {Temp.} then
      PutS(GetDCURecStr(Self,-1{dummy - won't be used},false));
   end
  else if NameIsUnique then
    PutS(NP^)
  else begin
    U := CurUnit.UnitImpRec[hUnit];
    PutSFmt('%s.%s',[U^.Name^,NP^]);
  end ;
end ;

procedure TBaseDef.Show;
var
  NP: PName;
begin
  NP := FName;
  if (NP=Nil)or(NP^[0]=#0) then
    NP := @NoName;
  PutS(NP^);
//  PutS('?');
//  ShowName;
end ;

procedure TBaseDef.ShowNamed(N: PName);
begin
  if ((N<>Nil)and(N=FName)or(FName=Nil)or(FName^[0]=#0)or
      (not ShowDotTypes and(FName^[1]='.')and(Self is TTypeDef)))
    and CurUnit.RegTypeShow(Self)
    {if RegTypeShow fails the type name will be shown instead of its
     definition}
  then
    try
      Show;
    finally
      CurUnit.UnRegTypeShow(Self)
    end
  else
    ShowName;
end ;

function TBaseDef.GetName: PName;
begin
  Result := FName;
  if Result=Nil then
    Result := @NoName;
end ;

function TBaseDef.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  DCUErrorFmt('Trying to set memory 0x%x[0x%x] to %s[0x%x]',[MOfs,MSz,Name^,
    PChar(Def)-CurUnit.MemPtr]);
end ;

{ TImpDef. }
constructor TImpDef.Create(AIK: TImpKind; AName: PName; AnInf: integer;
  ADef: PDef; AUnit: integer);
begin
  inherited Create(AName,ADef,AUnit);
  Inf := AnInf;
  ik := AIK;
end ;

procedure TImpDef.Show;
begin
  PutSFmt('%s:',[ik]);
  inherited Show;
end ;

function TImpDef.NameIsUnique: boolean;
begin
  Result := FNameIsUnique;
end ;

{ TDLLImpRec. }
constructor TDLLImpRec.Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
begin
  inherited Create({'A',}AName,ADef,AUnit);
  NDX := ANDX;
end ;

procedure TDLLImpRec.Show;
var
  NoName: boolean;
begin
  NoName := (FName=Nil)or(FName^[0]=#0);
  if not NoName then
    PutSFmt('name ''%s''',[FName^]);
  if NoName or(NDX<>0) then
    PutSFmt('index $%x',[NDX])
end ;

{ TImpTypeDefRec. }
constructor TImpTypeDefRec.Create(AName: PName; AnInf: integer;
  ARTTISz: Cardinal{AL: Byte}; ADef: PDef; AUnit: integer);
begin
  inherited Create('T',AName,AnInf,ADef,AUnit);
//  L := AL;
  RTTISz := ARTTISz;
  RTTIOfs := Cardinal(-1);
  hImpUnit := hUnit;
  hUnit := -1;
  ImpName := FName;
  FName := Nil {Will be named later in the corresponding TTypeDecl};
end ;

procedure TImpTypeDefRec.Show;
var
  U: PUnitImpRec;
begin
  PutS('type'+cSoftNL);
//  ShowName;
  if hImpUnit>=0 then begin
    U := CurUnit.UnitImpRec[hImpUnit];
    PutS(U^.Name^);
    PutS('.');
  end ;
  PutS(ImpName^);
//  PutSFmt('[%d]',[L]);
  if RTTISz>0 then begin
    Inc(AuxLevel);
    PutS('{ RTTI: ');
    Inc(NLOfs,2);
    NL;
    CurUnit.ShowDataBl(0,RTTIOfs,RTTISz);
    Dec(NLOfs,2);
    PutS('}');
    Dec(AuxLevel);
  end ;
end ;

function TImpTypeDefRec.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if RTTIOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change ImpRTTI(%s) memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if RTTISz<>MSz then
    DCUErrorFmt('ImpRTTI %s: memory size mismatch (.[0x%x]<>0x%x[0x%x])',
      [Name^,RTTISz,MOfs,MSz]);
  RTTIOfs := MOfs;
end ;

{**************************************************}
{ TNameDecl. }
constructor TNameDecl.Create0;
begin
  inherited Create;
  hDecl := CurUnit.AddAddrDef(Self);
end ;

constructor TNameDecl.Create;
var
  N: PName;
begin
  Create0;
  Def := DefStart;
  N := ReadName;
end ;

destructor TNameDecl.Destroy;
begin
  CurUnit.ClearAddrDef(Self);
  inherited Destroy;
end ;

function TNameDecl.GetTag: TDCURecTag;
begin
  Result := CurUnit.FixTag(Def^.Tag);
end ;

procedure TNameDecl.ShowName;
begin
  PutS(GetDCURecStr(Self,hDecl,false));
end ;
{var
  N: PName;
begin
  N := Name;
  if (N^[0]<>#0) then
    PutS(N^)
  else
    PutSFmt('_N_%x',[hDecl])
end ;
}

procedure TNameDecl.Show;
begin
  ShowName;
end ;

procedure TNameDecl.ShowDef(All: boolean);
begin
  Show;
end ;

function TNameDecl.GetName: PName;
begin
  if Def=Nil then
    Result := @NoName
  else
    Result := @Def^.Name;
end ;

function TNameDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  DCUErrorFmt('Trying to set memory 0x%x[0x%x] to %s[0x%x]',[MOfs,MSz,Name^,
    PChar(Def)-CurUnit.MemPtr]);
end ;

function TNameDecl.GetSecKind: TDeclSecKind;
begin
  Result := skNone;
end ;

function TNameDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  Result := true;
end ;

{ TNameFDecl.}
constructor TNameFDecl.Create(NoInf: boolean);
var
  F1,F3: integer;
begin
  inherited Create;
  F := ReadUIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then begin
    F1 := ReadUIndex;
  end ;
  {if F and $1<>0 then
    raise Exception.CreateFmt('Flag 1 found: 0x%x',[F]);}
  if not NoInf and(F and $40<>0) then
    Inf := Integer(ReadULong);
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then begin
    if F1 and $80<>0 then begin//Could be valid for MSIL only
      B2 := ReadUIndex;
      if (CurUnit.Ver=verD8)and(F and $08<>0) then
        F3 := ReadUIndex;
    end ;
  end ;
end ;

procedure TNameFDecl.Show;
begin
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{%x,%x}',[F,Inf]);
  Dec(AuxLevel);
end ;

function TNameFDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  case LK of
    dlMain: Result := (F and $40<>0);
    dlMainImpl: Result := (F and $40=0);
  else
    Result := true;
  end ;
end ;

{ TTypeDecl. }
constructor TTypeDecl.Create;
begin
  inherited Create(false{NoInf});
  hDef := ReadUIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1)and(B2<>0) then
    hDef := B2;
  CurUnit.AddTypeName(hDef,{hDecl,}@Def^.Name);
//  CurUnit.AddAddrDef(Self); moved to TNameDecl
end ;

function TTypeDecl.IsVisible(LK: TDeclListKind): boolean;
var
  RefName: PName;
begin
  Result := inherited IsVisible(LK);
  if not Result then
    Exit;
  if ShowDotTypes or(Def=Nil) then
    Exit;
  RefName := @Def^.Name;
  Result := not((RefName^[0]>#0)and(RefName^[1]='.'));
end ;

procedure TTypeDecl.Show;
var
  RefName: PName;
begin
  inherited Show;
  if (Def=Nil) then
    RefName := Nil
  else
    RefName := @Def^.Name;
 (*
  RefName := CurUnit.GetTypeName(hDef);
  if (Def=Nil)or(RefName=@Def^.Name) then
    RefName := Nil;
  if RefName<>Nil then
    PutSFmt('=%s{#%d}',[RefName^,hDef])
  else
    PutSFmt('=#%d',[hDef]);
  *)
  PutS('=');
  {  PutS('type'+cSoftNL);}
  CurUnit.ShowTypeDef(hDef,RefName);
//  PutSFmt('{#%x}',[hDef])
end ;

function TTypeDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
var
  D: TTypeDef;
begin
  Result := 0;
  D := CurUnit.GetTypeDef(hDef);
  if D=Nil then
    Exit;
  Result := D.SetMem(MOfs,MSz);
end ;

function TTypeDecl.GetSecKind: TDeclSecKind;
begin
  Result := skType;
end ;

{ TTypePDecl. }

constructor TTypePDecl.Create;
begin
  inherited Create(false);
//  B1 := ReadByte;
end ;

procedure TTypePDecl.Show;
begin
//  PutS('VMT of ');
  inherited Show;
//  PutSFmt('{B1:%x}',[B1]);
  PutS(',VMT');
end ;

function TTypePDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  Result := ShowVMT;
end ;

{ TVarDecl. }
constructor TVarDecl.Create;
begin
  inherited Create(false{NoInf});
  hDT := ReadUIndex;
  Ofs := ReadUIndex;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TVarDecl.Show;
{var
  RefName: PName;}
begin
//  PutS('var ');
  inherited Show;
 (* RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt(':%s{#%d @%x}',[RefName^,hDT,Ofs])
  else
    PutSFmt(':{#%d @%x}',[hDT,Ofs]);
  *)
  PutS(': ');
  CurUnit.ShowTypeDef(hDT,Nil);
//  PutSFmt('{#%x @%x}',[hDT,Ofs]);
  Inc(AuxLevel);
  PutSFmt('{Ofs:0x%x}',[Ofs]);
  Dec(AuxLevel);
end ;

function TVarDecl.GetSecKind: TDeclSecKind;
begin
  Result := skVar;
end ;

{ TVarCDecl. }
constructor TVarCDecl.Create(OfsValid: boolean);
begin
  inherited Create;
  Sz := Cardinal(-1);
  OfsR := Ofs;
  if not OfsValid then
    Ofs := Cardinal(-1);
end ;

procedure TVarCDecl.Show;
var
  DP: Pointer;
  {SzShown: integer;}
  DS: Cardinal;
var
  Fix0: integer;
  MS: TFixupMemState;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS(' ='+cSoftNL);
  if Sz=Cardinal(-1) then
    PutS(' ?')
  else begin
    DP := Nil;
    if ResolveConsts then begin
      DP := CurUnit.GetBlockMem(Ofs,Sz,DS);
      if DP<>Nil then begin
        SaveFixupMemState(MS);
        SetCodeRange(CurUnit.DataBlPtr,DP,DS);
        Fix0 := CurUnit.GetStartFixup(Ofs);
        CurUnit.SetStartFixupInfo(Fix0);
      end ;
    end ;
    CurUnit.ShowGlobalTypeValue(hDT,DP,DS,true,false);
    if DP<>Nil then
      RestoreFixupMemState(MS);
   {
    SzShown := 0;
    if DP<>Nil then begin
      SzShown := CurUnit.ShowGlobalTypeValue(hDT,DP,Sz,true);
      if SzShown<0 then
        SzShown := 0;
    end ;
    if SzShown<Sz then
      CurUnit.ShowDataBl(SzShown,Ofs,Sz);}
  end ;
  Dec(NLOfs,2);
end ;

function TVarCDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if Sz=Cardinal(-1) then
    Sz := MSz
  else if Sz<>MSz then //Changed for StrConstRec
    DCUErrorFmt('Trying to change typed const %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Ofs=Cardinal(-1) then
    Ofs := MOfs
  else if Ofs<>MOfs then
    DCUErrorFmt('typed const %s: memory ofs mismatch (0x%x<>0x%x)',
      [Name^,Ofs,MOfs]);
end ;

function TVarCDecl.GetSecKind: TDeclSecKind;
begin
  if GenVarCAsVars then
    Result := skVar
  else
    Result := skConst;
end ;

{ TAbsVarDecl. }
procedure TAbsVarDecl.Show;
begin
  inherited Show;
  PutSFmt(' absolute %s',[CurUnit.GetAddrStr(integer(Ofs),false)]);
end ;

{ TThreadVarDecl. }
function TThreadVarDecl.GetSecKind: TDeclSecKind;
begin
  Result := skThreadVar;
end ;

{ TStrConstDecl. }
constructor TStrConstDecl.Create;
var
  Tag: TDCURecTag;
begin
  inherited Create(false{NoInf});
//  if CurUnit.Ver<verD10 then
    Sz := ReadUIndex;
  hDT := ReadUIndex;
{  if CurUnit.Ver>=verD10 then begin   Wrong code - to mix with UnitAddInfo
    Tag := ReadTag;
    if Tag<>drStop1 then
      DCUError('unexplored StrConstDecl found, please report to the author.');
  end ;}
  if Sz=0 then
    Sz := Cardinal(-1);
  Ofs := Cardinal(-1);
//  if (CurUnit.Ver>=verD10)and(CurUnit.Ver)
end ;

procedure TStrConstDecl.Show;
var
  DP: Pointer;
  {SzShown: integer;}
  DS: Cardinal;
var
  Fix0: integer;
  MS: TFixupMemState;
begin
  inherited Show;
  PutS(': ');
  CurUnit.ShowTypeDef(hDT,Nil);
//  PutSFmt('{#%x @%x}',[hDT,Ofs]);
  Inc(AuxLevel);
  PutSFmt('{Ofs:0x%x}',[Ofs]);
  Dec(AuxLevel);
//  CurUnit.ShowTypeName(hDT);
  Inc(NLOfs,2);
  PutS(' ='+cSoftNL);
  if Sz=Cardinal(-1) then
    PutS(' ?')
  else begin
    DP := Nil;
    if ResolveConsts then begin
      DP := CurUnit.GetBlockMem(Ofs,Sz,DS);
      if DP<>Nil then begin
        SaveFixupMemState(MS);
        SetCodeRange(CurUnit.DataBlPtr,DP,DS);
        Fix0 := CurUnit.GetStartFixup(Ofs);
        CurUnit.SetStartFixupInfo(Fix0);
      end ;
    end ;
    CurUnit.ShowGlobalTypeValue(hDT,DP,DS,true,false);
    if DP<>Nil then
      RestoreFixupMemState(MS);
  end ;
  Dec(NLOfs,2);
end ;

function TStrConstDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if Sz=Cardinal(-1) then
    Sz := MSz
  else if Sz<>MSz then //Changed for StrConstRec
    DCUErrorFmt('Trying to change typed const %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Ofs=Cardinal(-1) then
    Ofs := MOfs
  else if Ofs<>MOfs then
    DCUErrorFmt('typed const %s: memory ofs mismatch (0x%x<>0x%x)',
      [Name^,Ofs,MOfs]);
end ;

function TStrConstDecl.GetSecKind: TDeclSecKind;
begin
  if GenVarCAsVars then
    Result := skVar
  else
    Result := skConst;
end ;

{ TLabelDecl. }
constructor TLabelDecl.Create;
begin
  inherited Create;
  Ofs := ReadUIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    ReadUIndex; //=0

//  CurUnit.AddAddrDef(Self);
end ;

procedure TLabelDecl.Show;
begin
//  PutS('label ');
  inherited Show;
  PutSFmt('{at $%x}',[Ofs]);
end ;

function TLabelDecl.GetSecKind: TDeclSecKind;
begin
  Result := skLabel;
end ;

//Labels can appear in the global decl. list when declared for unit init./fin.
function TLabelDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  {case LK of
    dlMain: Result := false;
    dlMainImpl: Result := true;
  else
    Result := true;
  end ;}
  Result := LK<>dlMain;
end ;

{ TExportDecl. }
constructor TExportDecl.Create;
begin
  inherited Create;
  hSym := ReadUIndex;
  Index := ReadUIndex;
end ;

procedure TExportDecl.Show;
var
  D: TDCURec;
  N: PName;
begin
  D := CurUnit.GetAddrDef(hSym);
  N := Nil;
  if D=Nil then
    PutS('?')
  else begin
    D.ShowName;
    N := D.Name;
  end ;
  Inc(NLOfs,2);
  if (N<>Nil)and(Name<>Nil)and(N^<>Name^) then begin
    PutS(cSoftNL+'name'+cSoftNL);
    ShowName;
  end ;
  if Index<>0 then
    PutSFmt(cSoftNL+'index $%x',[Index]);
  Dec(NLOfs,2);
end ;

function TExportDecl.GetSecKind: TDeclSecKind;
begin
  Result := skExport;
end ;

{ TLocalDecl. }
constructor TLocalDecl.Create(LK: TDeclListKind);
var
  M,M2: boolean;
begin
  inherited Create;
  M := GetTag in [arMethod,arConstr,arDestr];
  M2 := (CurUnit.Ver=verD2)and M;
  LocFlags := ReadUIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    ReadUIndex; //Not shure that it's right place
  if not M2 then
    hDT := ReadUIndex
  else if M then
    Ndx := ReadUIndex
  else
    Ndx := ReadIndex;
  if LK in [dlInterface,dlDispInterface] then
    NDXB := ReadUIndex
  else
    NDXB := -1;
//    B := ReadByte;
  if not M2 then begin
    if M then
      Ndx := ReadUIndex
    else
      Ndx := ReadIndex;
   end
  else
    hDT := ReadUIndex;
  {if LK=dlArgsT then
    Exit;}
  if not(LK in [dlClass,dlInterface,dlDispInterface,dlFields]) then
  case GetTag of
    arFld:  Exit ;
    arMethod,
    arConstr,
    arDestr: (*if not((LK in [dlClass,dlInterface])and(NDX1<>0{virtual?})) then*) Exit ;
  end ;
//  CurUnit.AddAddrDef(Self);
end ;

procedure TLocalDecl.Show;
var
  RefName: PName;
  MS: String;
begin
  MS := '';
  if ShowAuxValues then
   case GetTag of
     arVal: MS := 'val ';
     arVar: MS := 'var ';
     drVar: MS := 'local ';
     arResult: MS := 'result ';
     arAbsLocVar: MS := 'local absolute ';
     arFld: MS := 'field ';
     {arMethod: MS := 'method';
     arConstr: MS := 'constructor';
     arDestr: MS := 'destructor';}
   end
  else
   case GetTag of
//     arVar,drVar,arAbsLocVar: MS := 'var ';
     arVar: MS := 'var ';
     arResult: MS := 'result ';
   end ;
  if MS<>'' then
    PutS(MS);
  inherited Show;
 (* RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt(':%s{#%d #1:%x #2:%x}',[RefName^,hDT,Ndx1,Ndx])
  else
    PutSFmt(':{#%d #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
  *)
  PutS(': ');
  CurUnit.ShowTypeDef(hDT,Nil);
//  PutSFmt('{#%x #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
  Inc(AuxLevel);
  PutSFmt('{F:%x Ofs:%d',[LocFlags,integer(Ndx)]);
  if (LocFlags and $8<>0 {register})and(GetTag<>arFld) then begin
    if (Ndx>=Low(RegName))and(Ndx<=High(RegName)) then
      PutSFmt('=%s',[RegName[Ndx]])
    else
      PutS('=?')
  end ;
  if NDXB<>-1 then
    PutSFmt(' NDXB:%x',[NDXB]);
  PutS('}');
  Dec(AuxLevel);
  if GetTag=arAbsLocVar then
    PutSFmt(' absolute %s',[CurUnit.GetAddrStr(integer(Ndx),false)]);
end ;

function TLocalDecl.GetLocFlagsSecKind: TDeclSecKind;
begin
  case LocFlags and lfScope of
    lfPrivate: Result := skPrivate;
    lfProtected: Result := skProtected;
    lfPublic: Result := skPublic;
    lfPublished: Result := skPublished;
  else
    Result := skNone{Temp};
  end
end ;

function TLocalDecl.GetSecKind: TDeclSecKind;
begin
  if GetTag in [arFld, arMethod, arConstr, arDestr, arProperty, arClassVar] then
    Result := GetLocFlagsSecKind
  else if GetTag in [arResult,drVar,arAbsLocVar] then
    Result := skVar
  else
    Result := skNone;
end ;

{ TMethodDecl. }
constructor TMethodDecl.Create(LK: TDeclListKind);
begin
  inherited Create(LK);
  InIntrf := LK in [dlInterface,dlDispInterface];
  { if Name^[0]=#0 then
      hImport := ReadUIndex; //then hDT seems to be valid index in the
        //parent class unit}
  if not InIntrf then begin
    if CurUnit.IsMSIL and(NDX<>0) then begin
      ReadByteIfEQ(1);//I was unable to find something less perverse to skip this byte
    end ;
    if (CurUnit.Ver>=verD7)and(CurUnit.Ver<verK1)or(Name^[0]=#0)
    then begin
      hImport := ReadUIndex; //then hDT seems to be valid index in the
        //parent class unit
    end ;
  end ;
  //VMTNDX := MaxInt;
end ;

procedure TMethodDecl.Show;
var
  MS: String;
  D: TDCURec;
  MK: TMethodKind;
  PD: TProcDecl absolute D;

  procedure ShowFlags;
  begin
    Inc(AuxLevel);
    PutSFmt('{F:#%x hDT:%x} ',[LocFlags,hDT]);
    if (Name^[0]=#0)and(hImport<>0) then
      PutSFmt('{hImp: #%x} ',[hImport]);
    Dec(AuxLevel);
  end ;

begin
  if LocFlags and lfClass<>0 then
    PutS('class ');
  PD := Nil;
  if ResolveMethods then begin
    if not((NDX=0)and CurUnit.IsMSIL) then begin
      D := CurUnit.GetAddrDef(NDX);
      if (D<>Nil)and not(D is TProcDecl) then
        D := Nil;
      if D<>Nil then begin
        MK := mkProc;
        case GetTag of
          arMethod: MK := mkMethod;
          arConstr: MK := mkConstructor;
          arDestr: MK := mkDestructor;
        end ;
        TProcDecl(D).MethodKind := MK;
      end ;
    end ;
  end ;
  MS := '';
  case GetTag of
    arMethod: begin
      if PD=Nil then
        MS := 'method '
      else if PD.IsProc then
        MS := 'procedure '
      else
        MS := 'function ';
    end ;
    arConstr: MS := 'constructor ';
    arDestr: MS := 'destructor ';
  end ;
  if (not InIntrf)and not((NDX=0)and CurUnit.IsMSIL) then begin
    if MS<>'' then
      PutS(MS);
    {if (Name^[0]=#0)and(hImport<>0) then
      PutS(CurUnit.GetAddrStr(integer(hImport),true))
    else}
      ShowName;
    if PD=Nil then
      PutS(': ');
    ShowFlags;
    if PD<>Nil then begin
      Inc(AuxLevel);
      PutSFmt('{%x=>%s}',[Ndx,PD.Name^]);
      Dec(AuxLevel);
      PD.ShowArgs;
     end
    else
      PutS(CurUnit.GetAddrStr(Ndx,true));
    Inc(NLOfs,2);
    if LocFlags and lfOverride<>0 then
      PutS(';'+cSoftNL+'override{');
    if LocFlags and lfVirtual<>0 then
      PutS(';'+cSoftNL+'virtual');
    if LocFlags and lfVirtual<>0 then begin
      if LocFlags and lfOverride=0 then
        PutSFmt('{@%d}',[hDT*4])
      else
        PutSFmt(' @%d',[hDT*4]);
    end ;
    if LocFlags and lfDynamic<>0 then
      PutS(';'+cSoftNL+'dynamic');
    if LocFlags and lfOverride<>0 then
      PutS('}');
    Dec(NLOfs,2);
   end
  else begin
    if MS<>'' then begin
      Inc(AuxLevel);
      PutS(MS);
      Dec(AuxLevel);
    end ;
    if (NDX=0)and CurUnit.IsMSIL then
      D := CurUnit.GetTypeDef(hImport) //this feature is used for copying method
        //definitions of TA into that of TB when TB is defined by  TB = type TA
    else
      D := CurUnit.GetTypeDef(NDX);
    if (D<>Nil)and(D is TProcTypeDef) then begin
      Inc(AuxLevel);
      PutSFmt('{T#%x}',[hDT]);
      Dec(AuxLevel);
      PutS(TProcTypeDef(D).ProcStr);
      PutS(' ');
      ShowName;
      SoftNL;
      TProcTypeDef(D).ShowDecl(Nil);
      ShowFlags;
     end
    else begin
      ShowName;
      PutS(': ');
      ShowFlags;
      CurUnit.ShowTypeDef(Ndx,Name);
    end ;
  end ;
end ;

{ TClassVarDecl. }
procedure TClassVarDecl.Show;
begin
  PutS('class var'+cSoftNL);
  inherited Show;
end ;

function TClassVarDecl.GetSecKind: TDeclSecKind;
begin
  Result := GetLocFlagsSecKind;
end ;

{ TPropDecl. }
constructor TPropDecl.Create;
var
  X,X1,X2,X3,Flags1: integer;
begin
  inherited Create;
  LocFlags := ReadIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    Flags1 := ReadUIndex;
  hDT := ReadUIndex;
  NDX := ReadIndex;
  hIndex := ReadIndex;
  hRead := ReadUIndex;
  hWrite := ReadUIndex;
  hStored := ReadUIndex;
//  CurUnit.AddAddrDef(Self);
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then begin
    X := ReadUIndex;
    X1 := ReadUIndex;
    if CurUnit.IsMSIL then begin
      X2 := ReadUIndex;
      X3 := ReadUIndex;
    end ;
  end ;
  hDeft := ReadIndex;
end ;

procedure TPropDecl.Show;

  procedure PutOp(Name: String; hOp: TNDX);
  var
    V: String;
  begin
    if hOp=0 then
      Exit;
    V := CurUnit.GetAddrStr(hOp,true);
    PutSFmt(cSoftNL+'%s %s',[Name,V])
  end ;

var
  D: TBaseDef;
  hDT0: TDefNDX;
  U: TUnit;
begin
  PutS('property ');
  inherited Show;
  Inc(NLOfs,2);
  if hDT<>0 then begin
   {hDT=0 => inherited and something overrided}
    D := CurUnit.GetTypeDef(hDT);
    if (D<>Nil)and(D is TProcTypeDef)and(D.FName=Nil) then begin
      {array property}
      Inc(AuxLevel);
      PutSFmt('{T#%x}',[hDT]);
      Dec(AuxLevel);
      //SoftNL;
      Dec(NLOfs,2);
      TProcTypeDef(D).ShowDecl('[]');
      Inc(NLOfs,2);
     end
    else begin
      PutS(':');
    //  PutSFmt(':{#%x}',[hDT]);
      CurUnit.ShowTypeDef(hDT,Nil);
    end
  end ;
  if hIndex<>TNDX($80000000) then
    PutSFmt(cSoftNL+'index $%x',[hIndex]);
  PutOp('read',hRead);
  PutOp('write',hWrite);
  PutOp('stored',hStored);
  if hDeft<>TNDX($80000000) then begin
    hDT0 := hDT;
    U := CurUnit;
    {if hDT0=0 then //ToDo: get property type in the parent class
      hDT0 := GetPropType(U);}
    PutS(cSoftNL+'default ');
    if (U=Nil)or(U.ShowGlobalTypeValue(hDT0,@hDeft,SizeOf(hDeft),false{AndRest},true{IsConst})<0)
    then
      PutSFmt('$%x',[hDeft]);
  end ;
  Inc(AuxLevel);
  SoftNL;
  PutSFmt('{F:#%x,NDX:#%x}',[LocFlags,NDX]);
  Dec(AuxLevel);
  if LocFlags and lfDeftProp<>0 then
    PutS('; default');
  Dec(NLOfs,2);
end ;

function TPropDecl.GetSecKind: TDeclSecKind;
begin
  case LocFlags and lfScope of
    lfPrivate: Result := skPrivate;
    lfProtected: Result := skProtected;
    lfPublic: Result := skPublic;
    lfPublished: Result := skPublished;
  else
    Result := skNone{Temp};
  end;
end ;

{ TDispPropDecl. }
procedure TDispPropDecl.Show;
begin
  PutS('property ');
  ShowName;
  Inc(NLOfs,2);
  PutS(':'+cSoftNL);
  CurUnit.ShowTypeDef(hDT,Nil);
  Inc(AuxLevel);
  PutSFmt('{F:%x',[LocFlags]);
  if NDXB<>-1 then
    PutSFmt(' NDXB:%x',[NDXB]);
  PutS('}');
  Dec(AuxLevel);
  if NDXB<>-1 then begin
    case NDXB and $6 of
      $2: PutS(cSoftNL+'readonly');
      $4: PutS(cSoftNL+'writeonly');
    end ;
  end ;
  PutsFmt(cSoftNL+'dispid $%x',[integer(NDX)]);
  Dec(NLOfs,2);
end ;

{ TConstDeclBase. }
constructor TConstDeclBase.Create;
begin
  inherited Create(false{NoInf});
//  CurUnit.AddAddrDef(Self);
end ;

procedure TConstDeclBase.ReadConstVal;
begin
  ValSz := ReadUIndex;
  if ValSz=0 then begin
    ValPtr := Nil;
    Val := ReadIndex;
    ValSz := NDXHi;
   end
  else begin
    ValPtr := ScSt.CurPos;
    SkipBlock(ValSz);
    Val := 0;
  end ;
end ;

procedure TConstDeclBase.ShowValue;
var
  DP: Pointer;
  DS: Cardinal;
  V: TInt64Rec;
  MemVal: boolean;
begin
  if ValPtr=Nil then begin
    V.Hi := ValSz;
    V.Lo := Val;
    DP := @V;
    DS := 8;
   end
  else begin
    DP := ValPtr;
    DS := ValSz;
  end ;
  MemVal := ValPtr<>Nil;
  if (CurUnit.ShowGlobalTypeValue(hDT,DP,DS,MemVal,true)<0)and not MemVal then begin
    CurUnit.ShowTypeName(hDT);
    NDXHi := V.Hi;
    PutSFmt('(%s)',[NDXToStr(V.Lo)]);
  end ;
end ;

procedure TConstDeclBase.Show;
var
  RefName: PName;
  TypeNamed: boolean;
begin
  inherited Show;
 (*
  RefName := CurUnit.GetTypeName(hDT);
  if RefName<>Nil then
    PutSFmt('=%s{#%d}(',[RefName^,hDT])
  else
    PutSFmt('={#%d}',[hDT]);
  if ValPtr=Nil then begin
    if ValSz<>0 then
      PutSFmt('$%x%8:8x',[ValSz,Val])
    else
      PutSFmt('$%x',[Val]);
  end ;
  if RefName<>Nil then
    PutS(')');
  *)
  Inc(NLOfs,2);
  PutS(' ');
  Inc(AuxLevel);
  if AuxLevel<=0 then begin
    PutS('{:'+cSoftNL);
    CurUnit.ShowTypeName(hDT);
    PutS('}'+cSoftNL)
  end ;
  Dec(AuxLevel);
  PutS('='+cSoftNL);
  Inc(AuxLevel);
  if (CurUnit.Ver>verD4)and(hX<>0{It is almost always=0}) then
    PutSFmt('{X:#%x}',[hX]);
  Dec(AuxLevel);
  ShowValue;
  Dec(NLOfs,2);
 (*
  TypeNamed := CurUnit.ShowTypeName(hDT);
  if TypeNamed then
    PutS('(');
  if ValPtr=Nil then begin
    NDXHi := ValSz;
    PutS(NDXToStr(Val));
   end
  else begin
    Inc(NLOfs,2);
    NL;
    ShowDump(ValPtr,0,ValSz,0,0,0,0,Nil,false);
    Dec(NLOfs,2);
  end ;
  if TypeNamed then
    PutS(')');
  *)
end ;

function TConstDeclBase.GetSecKind: TDeclSecKind;
begin
  Result := skConst;
end ;

{ TConstDecl. }
constructor TConstDecl.Create;
begin
  inherited Create;
  hDT := ReadUIndex;
  if CurUnit.Ver>verD4 then
    hX := ReadUIndex;
  ReadConstVal;
end ;

{ TResStrDef. }
constructor TResStrDef.Create;
begin
  inherited Create(false);
  OfsR := Ofs;
  Ofs := Cardinal(-1);
end ;

procedure TResStrDef.Show;
begin
  inherited Show; //The reference to HInstance will be shown
  Inc(NLOfs,2);
  SoftNL;
  CurUnit.ShowGlobalConstValue(hDecl+1);
  Dec(NLOfs,2);
end ;

function TResStrDef.GetSecKind: TDeclSecKind;
begin
  Result := skResStr;
end ;

{
procedure TResStrDef.Show;
begin
  PutS('res');
  inherited Show;
end ;
}
(*
constructor TResStrDef.Create;
begin
  inherited Create;
  hDT := ReadUIndex;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
  B1 := ReadByte;
  B2 := ReadByte;
  V := ReadIndex;
  ReadConstVal;
  RefOfs := Cardinal(-1);
end ;

procedure TResStrDef.Show;
begin
  inherited Show;
  PutSFmt('{NDX:%x,NDX1:%x,B1:%x,B2:%x,V:%x}',[NDX,NDX1,B1,B2,V]);
  NL;
  if RefOfs<>Cardinal(-1) then begin
    PutS('{');
    CurUnit.ShowDataBl(RefOfs,RefSz);
    PutS('}');
  // NL;
  end ;
end ;

procedure TResStrDef.SetMem(MOfs,MSz: Cardinal);
begin
  if RefOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change resourcestring memory %s',[Name^]);
  RefOfs := MOfs;
  RefSz := MSz;
end ;
*)

{ TSetDeftInfo. }
constructor TSetDeftInfo.Create;
begin
//  inherited Create;
  Def := DefStart;
  hDecl := -1;
  hConst := ReadUIndex;
  hArg := ReadUIndex;
end ;

procedure TSetDeftInfo.Show;
begin
  Inc(NLOfs,2);
  PutSFmt('Let %s :='+cSoftNL,[CurUnit.GetAddrStr(hArg,false)]);
  CurUnit.ShowGlobalConstValue(hConst);
  Dec(NLOfs,2);
end ;

{ TCopyDecl. }
constructor TCopyDecl.Create;
{
This kind of records was observed in DRIntf.dcu of D2006 where the
unit has several records of the same structure:
  TID         = record Reserved: array[$1..$6] of Byte; end;
  TDatabaseID = record Reserved: array[$1..$6] of Byte; end;
  TTableID    = --//--
  TFieldID    = --//--
  TAttrID     = --//--
Now they use drCopyDecl to point to the 1st Reserved declaration
instead of duplicating it
}
var
  SrcDef: TDCURec;
begin
  inherited Create0;
  hBase := ReadUIndex; //index of the address to copy from
  SrcDef := CurUnit.GetAddrDef(hBase);
  if SrcDef=Nil then
    DCUErrorFmt('CopyDecl index #%x not found',[hBase]);
  if not(SrcDef is TNameDecl) then
    DCUErrorFmt('CopyDecl index #%x(%s) is not a TNameDecl',[hBase,SrcDef.Name^]);
  Base := TNameDecl(SrcDef);
  Def := Base.Def;
end ;

procedure TCopyDecl.Show;
begin
  Base.Show;
  Inc(AuxLevel);
  PutSFmt('{Copy of:#%x}',[hBase]);
  Dec(AuxLevel);
end ;

function TCopyDecl.GetSecKind: TDeclSecKind;
begin
  Result := Base.GetSecKind;
end ;

(*
{ TProcDeclBase. }
constructor TProcDeclBase.Create;
begin
  inherited Create;
  CodeOfs := Cardinal(-1);
//  CurUnit.AddAddrDef(Self);
end ;

function TProcDeclBase.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  if CodeOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change procedure %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Sz>MSz then
    DCUErrorFmt('Procedure %s: memory size mismatch (.[0x%x]>0x%x[0x%x])',
      [Name^,Sz,MOfs,MSz]);
  CodeOfs := MOfs;
  Result := MSz-Sz {it can happen for ($L file) with several procedures};
end ;

function TProcDeclBase.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;
*)

{ TProcDecl. }

function ReadCallKind: TProcCallKind;
begin
  Result := pcRegister;
  if (Tag>=Low(TProcCallTag))and(Tag<=High(TProcCallTag)) then begin
    Result := TProcCallKind(Ord(Tag)-Ord(Low(TProcCallTag))+1);
    Tag := ReadTag;
  end ;
end ;

constructor TProcDecl.Create(AnEmbedded: TNameDecl; NoInf: boolean);
var
  NoName: boolean;
  ArgP: ^TNameDecl;
  Loc: TNameDecl;
begin
  inherited Create(NoInf);
  CodeOfs := Cardinal(-1);
 {---}
  Embedded := AnEmbedded;
  NoName := IsUnnamed;
  MethodKind := mkProc;
  Locals := Nil;
  B0 := ReadUIndex{ReadByte};
  Sz := ReadUIndex;
  if not NoName then begin
    if CurUnit.Ver>verD2 then
      VProc := ReadIndex;
    hDTRes := ReadUIndex;
    if (CurUnit.Ver>verD7)and(CurUnit.Ver<verK1) then
      ReadUIndex;
    Tag := ReadTag;
    CallKind := ReadCallKind;
    try
      CurUnit.ReadDeclList(dlArgs,Args);
    except
      on E: Exception do begin
        E.Message := Format('%s in proc %s',[E.Message,Name^]);
        raise;
      end ;
    end ;
    if Tag<>drStop1 then
      TagError('Stop Tag');
    ArgP := @Args;
    while ArgP^<>Nil do begin
      Loc := ArgP^;
      if not(Loc.GetTag in [arVal,arVar]) then
        Break;
      ArgP := @Loc.Next;
    end ;
    Locals := ArgP^;
    ArgP^ := Nil;
    //Tag := ReadTag;
  end ;
//  CodeOfs := CurUnit.RegDataBl(Sz);
end ;

destructor TProcDecl.Destroy;
begin
  FreeDCURecList(Locals);
  FreeDCURecList(Args);
  FreeDCURecList(Embedded);
  inherited Destroy;
end ;

function TProcDecl.IsUnnamed: boolean;
begin
  Result := (Def^.Name[0]=#0)or(Def^.Name='.')
    or(CurUnit.Ver>=verD6)and(CurUnit.Ver<verK1)and(Def^.Name='..')
    or((CurUnit.Ver>=verK1)or(CurUnit.Ver>=verD8))
      and(Def^.Name[1]='.'){and(Def^.Name[Length(Def^.Name)]='.')};
   //In Kylix are used the names of the kind '.<X>.'
   //In Delphi 6 were noticed only names '..'
   //In Delphi 9 were noticed names of the kind '.<X>'
end ;

function TProcDecl.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  if CodeOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change procedure %s memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if Sz>MSz then
    DCUErrorFmt('Procedure %s: memory size mismatch (.[0x%x]>0x%x[0x%x])',
      [Name^,Sz,MOfs,MSz]);
  CodeOfs := MOfs;
  Result := MSz-Sz {it can happen for ($L file) with several procedures};
end ;

function TProcDecl.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;

const
  CallKindName: array[TProcCallKind] of String =
    ('register','cdecl','pascal','stdcall','safecall');

function TProcDecl.IsProc: boolean;
begin
  Result := CurUnit.TypeIsVoid(hDTRes);
end ;

procedure TProcDecl.ShowArgs;
var
  NoName: boolean;
  Ofs0: Cardinal;
begin
  NoName := IsUnnamed;
  Inc(AuxLevel);
  PutSFmt('{B0:%x,Sz:%x',[B0,Sz]);
  if not NoName then begin
    if CurUnit.Ver>verD2 then
      PutSFmt(',VProc:%x',[VProc]);
  end ;
  PutS('}');
  Dec(AuxLevel);
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  if Args<>Nil then
    PutS(cSoftNL+'(');
  CurUnit.ShowDeclList(dlArgs,Args,Ofs0,2,[{dsComma,}dsNoFirst,dsSoftNL],
    ProcSecKinds,skNone);
  NLOfs := Ofs0+2;
  if Args<>Nil then
    PutS(')');
  if not IsProc then begin
    PutS(':'+cSoftNL);
    CurUnit.ShowTypeDef(hDTRes,Nil);
  end ;
  if CallKind<>pcRegister then begin
    PutS(';'+cSoftNL);
    PutS(CallKindName[CallKind]);
  end ;
  if (CurUnit.Ver>verD3)and(VProc and $1000 <> 0) then begin
    PutS(';'+cSoftNL);
    PutS('overload');
  end ;
  NLOfs := Ofs0;
end ;

function GetNameAtOfs(L,LBest: TDCURec; Frame: integer; var DBest: integer): TDCURec;
var
  D: integer;
begin
  Result := LBest;
  while L<>Nil do begin
    if (L is TLocalDecl)and(TLocalDecl(L).GetTag<>arFld)
      and(TLocalDecl(L).LocFlags and $8=0 {not a register})
    then begin
      D := Frame-TLocalDecl(L).Ndx;
      if (D>=0)and(D<DBest) then begin
        Result := L;
        DBest := D;
        if D=0 then
          Exit;
      end ;
    end ;
    L := L.Next;
  end ;
end ;

function TProcDecl.GetRegDebugInfo(ProcOfs: integer; hReg: THBMName; Ofs: integer): String;
const
  RegId: array[0..6+12] of THBMName =
    (hnEAX,hnEDX,hnECX,hnEBX,hnESI,hnEDI,hnEBP,
    //Register parts:
     hnAL,hnDL,hnCL,hnBL, hnAH,hnDH,hnCH,hnBH, hnAX,hnDX,hnCX,hnBX);
var
  i,id,hDef: integer;
  {Res: TLocalDecl;}
  D: TDCURec;
  TD: TTypeDef;
  U: TUnit;
  DOfs,Sz: integer;
  LVP: PLocVarRec;
  Tag: TDCURecTag;
  InReg,IsVar: boolean;
begin
  Result := '';
  id := -1;
  hReg := hReg or nf;
  for i:=Low(RegId) to High(RegId) do
   if RegId[i]=hReg then begin
     id := i;
     break;
   end ;
  if id<0 then begin
    if hReg<>hnESP then
      Exit;
    //For ESP-based procedures. I can't understand how
    //we can distinguish the two kinds by some flags
    id := -2; //-1 denotes symbol scope end
  end ;
  if id>6 then
    id := (id-7)and $3; //Register part
  LVP := @(FProcLocVarTbl^[2]);
  hDef := -1;
  for i:=2 to FProcLocVarCnt-1 do begin
    if LVP^.Ofs>ProcOfs then
      break;
    if LVP^.frame=id then
      hDef := LVP^.Sym
    else if (LVP^.frame=-1)and(LVP^.Sym=hDef) then
      hDef := -1;
    Inc(LVP);
  end ;
  TD := Nil;
  IsVar := false;
  if hDef>=0 then begin
    InReg := true;
    D := CurUnit.GetAddrDef(hDef);
    if D=Nil then begin
      Result := Format('Def #%x=Nil',[hDef]);
      Exit; //Silent error
    end ;
    Sz := 4;
    //TD := CurUnit.GetGlobalTypeDef(TLocalDecl(D).hDT,U);
    case TLocalDecl(D).GetTag of
     arVar: IsVar := true;
     //arVal,drVar{local},arResult:;
    end ;
   end
  else begin
    if (id<>6{EBP})and(hReg<>hnESP{It can also be used as frame base}){or(Ofs=0)}
      //But it's difficult to follow the ESP changes due to arg PUSHes
    then
      Exit;
    {Seek EBP+Ofs variables}
    InReg := false;
    DOfs := MaxInt;
    D := GetNameAtOfs(Args,Nil,Ofs,DOfs);
    if DOfs<>0 then begin
      D := GetNameAtOfs(Locals,D,Ofs,DOfs);
      if DOfs<>0 then begin
        D := GetNameAtOfs(Embedded,D,Ofs,DOfs);
        if D=Nil then
          Exit;
      end ;
    end ;
    Sz := 1;
    case TLocalDecl(D).GetTag of
     arVar: begin
       Sz := 4;
       IsVar := true;
      end ;
     arVal,drVar{local},arResult: begin
       TD := CurUnit.GetGlobalTypeDef(TLocalDecl(D).hDT,U);
       if TD<>Nil then
         Sz := TD.Sz
     end ;
    end ;
    if DOfs>=Sz then
      Exit;
    hDef := TLocalDecl(D).hDecl;
    Ofs := DOfs;
  end ;
  Result := GetDCURecStr(D, hDef,false);
  if Ofs<0 then begin
    Result := Format('%s%d',[Result,Ofs]);
    Exit;
  end ;
  if not(IsVar and not InReg {it doesn't make sense}) then begin
    if IsVar or not InReg then
      Result := Result+CurUnit.GetOfsQualifier(TLocalDecl(D).hDT,Ofs)
    else {not IsVar and InReg} begin
      if Ofs=0 then
        Exit;
     //Try to interpret the value as a pointer:
      Result := Format('@%s%s',[Result,CurUnit.GetRefOfsQualifier(TLocalDecl(D).hDT,Ofs)]);
    end ;
    Exit;
  end ;
  if Ofs=0 then
    Exit;
  Result := Format('%s+%d',[Result,Ofs])
end ;

procedure TProcDecl.ShowDef(All: boolean);
var
  Ofs0: Cardinal;
begin
  if IsProc then begin
    case MethodKind of
      mkConstructor: PutS('constructor ');
      mkDestructor: PutS('destructor ');
    else
      PutS('procedure ');
    end ;
   end
  else
    PutS('function ');
  inherited Show;
  if Def^.Name[0]=#0 then
    PutS('?');
  ShowArgs;
  if All then begin
    if FProcLocVarCnt>=2 then begin
      Inc(AuxLevel);
      PutSFmt('{LVFlags: %x,%x,%x,%x,%x}',[FProcLocVarTbl^[0].ofs,
        FProcLocVarTbl^[0].frame,FProcLocVarTbl^[1].sym,
        FProcLocVarTbl^[1].ofs,FProcLocVarTbl^[1].frame]);
      Dec(AuxLevel);
    end ;
    Ofs0 := NLOfs;
    PutS(';');
    if Locals<>Nil then
      CurUnit.ShowDeclList(dlEmbedded,Locals,Ofs0{+2},2,[dsLast,dsOfsProc],
        BlockSecKinds,skNone);
    if Embedded<>Nil then
      CurUnit.ShowDeclList(dlEmbedded,Embedded,Ofs0{+2},2,[dsLast,dsOfsProc],
        BlockSecKinds,skNone);
//    PutS('; ');
    NLOfs := Ofs0;
    NL;
    PutS('begin');
    NLOfs := Ofs0+2;
    GetRegVarInfo := GetRegDebugInfo;
    CurUnit.ShowCodeBl(AddrBase,CodeOfs,Sz);
    GetRegVarInfo := Nil;
    NLOfs := Ofs0;
    NL;
    PutS('end');
  end ;
end ;

procedure TProcDecl.Show;
begin
  ShowDef(true);
end ;

function TProcDecl.IsVisible(LK: TDeclListKind): boolean;
begin
  case LK of
    dlMain: Result := (F and $40<>0)and (MethodKind=mkProc);
  else
    Result := true;
  end ;
end ;

{ TSysProcDecl. }
constructor TSysProcDecl.Create;
begin
  inherited Create;
  F := ReadUIndex;
  Ndx := ReadIndex;
//  CurUnit.AddAddrDef(Self);
//  CodeOfs := CurUnit.RegDataBl(Sz);
end ;

function TSysProcDecl.GetSecKind: TDeclSecKind;
begin
  Result := skProc;
end ;

procedure TSysProcDecl.Show;
begin
  PutS('sysproc ');
  inherited Show;
  PutSFmt('{#%x}',[F]);
//  PutSFmt('{%x,#%x}',[F,V]);
//  NL;

//  CurUnit.ShowDataBl(CodeOfs,Sz);
end ;

(*
{ TAtDecl. }
  //May be start of implementation?
constructor TAtDecl.Create;
begin
  inherited Create;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
end ;

procedure TAtDecl.Show;
begin
  PutSFmt('implementation ?{NDX:%x,NDX:%x}',[NDX,NDX1]);
  inherited Show;
end ;
*)

{ TSysProc8Decl. }
constructor TSysProc8Decl.Create;
{var
  B80,H,B0,Sz: TNDX;}
begin
  {B80 := ReadUIndex;
  H := ReadUIndex;
  B0 := ReadUIndex;
  Sz := ReadUIndex;}
  inherited Create(Nil{AnEmbedded},true{NoInf});
end ;


{ TUnitAddInfo. }
constructor TUnitAddInfo.Create;
begin
  inherited Create(false{NoInf});
  if Ver >= verD12 then   // Added by Liu Xiao for Delphi 2009
    ReadByte;
  B := ReadUIndex;
  Tag := ReadTag;
  CurUnit.ReadDeclList(dlUnitAddInfo,Sub);
end ;

destructor TUnitAddInfo.Destroy;
begin
  FreeDCURecList(Sub);
  inherited Destroy;
end ;

function TUnitAddInfo.IsVisible(LK: TDeclListKind): boolean;
begin
  Result := false;
end ;


{ TSpecVar. }
procedure TSpecVar.Show;
begin
  PutS('spec var'+cSoftNL);
  inherited Show;
end ;

(* It's StrConstRec
{ TAddInfo6. }
constructor TAddInfo6.Create;
begin
  inherited Create;
  V0 := ReadUIndex;
  V1 := ReadUIndex;
  V2 := ReadUIndex;
  V3 := ReadUIndex;
  Ofs := 0;
  Sz := 0;
end ;

procedure TAddInfo6.Show;
begin
  inherited Show;
  Puts('{AddInfo6}={'); NL;
  CurUnit.ShowDataBl(0,Ofs,Sz);
  Puts('}');
end ;

function TAddInfo6.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  Sz := MSz;
  Ofs := MOfs;
end ;
*)

{--------------------------------------------------------------------}
{ TTypeDef. }
constructor TTypeDef.Create;
begin
  inherited Create(Nil,DefStart,-1);
  RTTISz := ReadUIndex;
  Sz := ReadIndex{ReadUIndex};
  V := ReadUIndex;
  if CurUnit.IsMSIL then begin
    ReadUIndex;
    ReadUIndex;
   end
  else if (CurUnit.Ver>=verD9)and(CurUnit.Ver<verK1) then
    ReadUIndex;
  CurUnit.AddTypeDef(Self);
  {if V<>0 then
    CurUnit.AddAddrDef(Self);}
  RTTIOfs := Cardinal(-1){CurUnit.RegDataBl(RTTISz)};
end ;

destructor TTypeDef.Destroy;
begin
  CurUnit.ClearLastTypeDef(Self);
  inherited Destroy;
end ;

procedure TTypeDef.ShowBase;
begin
  Inc(AuxLevel);
  PutSFmt('{Sz: %x, RTTISz: %x, V: %x}',[Sz,RTTISz,V]);
  Dec(AuxLevel);
//  PutSFmt('{Sz: %x, V: %x}',[Sz,V]);
  if RTTISz>0 then begin
    Inc(AuxLevel);
    PutS('{ RTTI: ');
    Inc(NLOfs,2);
    NL;
    CurUnit.ShowDataBl(0,RTTIOfs,RTTISz);
    Dec(NLOfs,2);
    PutS('}');
    Dec(AuxLevel);
  end ;
end ;

procedure TTypeDef.Show;
begin
  ShowBase;
end ;

function TTypeDef.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
begin
  Result := 0;
  if RTTIOfs<>Cardinal(-1) then
    DCUErrorFmt('Trying to change RTTI(%s) memory to 0x%x[0x%x]',
      [Name^,MOfs,MSz]);
  if RTTISz<>MSz then
    DCUErrorFmt('RTTI %s: memory size mismatch (.[0x%x]<>0x%x[0x%x])',
      [Name^,RTTISz,MOfs,MSz]);
  RTTIOfs := MOfs;
end ;

function TTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  NL;
  ShowDump(DP,Nil,0,0,Sz,0,0,0,0,Nil,false);
end ;

function TTypeDef.GetOfsQualifier(Ofs: integer): String;
begin
  if Ofs=0 then
    Result := ''
  else if Ofs<Sz then
    Result := Format('.byte[%d]',[Ofs])
  else
    Result := Format('.?%d',[Ofs]); //Error
end ;

function TTypeDef.GetRefOfsQualifier(Ofs: integer): String;
begin
  if Ofs=0 then
    Result := '^'
  else
    Result := Format('^?%d',[Ofs]); //Error
end ;

{ TRangeBaseDef. }

procedure TRangeBaseDef.GetRange(var Lo,Hi: TInt64Rec);
var
  CP0: TScanState;
begin
  ChangeScanState(CP0,LH,18);
  ReadIndex64(Lo);
  ReadIndex64(Hi);
  RestoreScanState(CP0);
end ;

function TRangeBaseDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  CP0: TScanState;
  Neg: boolean;
  Lo: TNDX;
  Tag: TDCURecTag;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  if Def=Nil then
    Tag := drRangeDef{Just in case}
  else
    Tag := TDCURecTag(Def^);
  case Tag of
    drChRangeDef:
     if Sz=1 then begin
       PutS(CharStr(Char(DP^)));
       Exit;
     end ;
    drWCharRangeDef:
     if Sz=2 then begin
       PutS(WCharStr(WideChar(DP^)));
       Exit;
     end ;
    drBoolRangeDef: begin
      PutS(BoolStr(DP,Sz));
      Exit;
    end ;
  end ;
  ChangeScanState(CP0,LH,18);
  Lo := ReadIndex;
  Neg := NDXHi<0{Lo<0};
  RestoreScanState(CP0);
  PutS(IntLStr(DP,Sz,Neg));
end ;

procedure TRangeBaseDef.Show;
var
  Lo,Hi: TInt64Rec;
  U: TUnit;
  T: TTypeDef;

  procedure ShowVal(var V: TInt64Rec);
  begin
    if (T=Nil)or(U.ShowTypeValue(T,@V,8,true)<0) then begin
      NDXHi := V.Hi;
      PutS(NDXToStr(V.Lo));
    end ;
  end ;

begin
  inherited Show;
  Inc(AuxLevel);
  PutS('{');
//  CurUnit.ShowTypeDef(hDTBase,Nil);
  CurUnit.ShowTypeName(hDTBase);
//  PutSFmt(',#%x,B:%x}',[hDTBase,B]);
  PutSFmt(',B:%x}',[B]);
  Dec(AuxLevel);
  GetRange(Lo,Hi);
  T := CurUnit.GetGlobalTypeDef(hDTBase,U);
  ShowVal(Lo);
  PutS('..');
  ShowVal(Hi);
end ;

{ TRangeDef. }
constructor TRangeDef.Create;
var
  Lo: TNDX;
  Hi: TNDX;
begin
  inherited Create;
  hDTBase := ReadUIndex;
  LH := ScSt.CurPos;
  Lo := ReadIndex;
  Hi := ReadIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    B := ReadUIndex
  else
    B := ReadByte; //It could be index too, but I'm not sure
end ;

{ TEnumDef. }
constructor TEnumDef.Create;
var
  Lo: TNDX;
  Hi: TNDX;
begin
  inherited Create;
  hDTBase := ReadUIndex;
  NDX := ReadIndex;
  LH := ScSt.CurPos;
  Lo := ReadIndex;
  Hi := ReadIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    B := ReadUIndex
  else
    B := ReadByte; //It could be index too, but I'm not sure
end ;

destructor TEnumDef.Destroy;
begin
  if NameTbl<>Nil then begin
    if NameTbl.Count>0 then
      FreeDCURecList(NameTbl[0]);
    NameTbl.Free;
  end ;
  inherited Destroy;
end ;

function TEnumDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  V: Cardinal;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  if not MemToUInt(DP,Sz,V)or(V<0)or(NameTbl=Nil)or(V>=NameTbl.Count) then begin
    ShowName;
    PutS('(');
    inherited ShowValue(DP,DS);
    PutS(')');
    Exit;
  end ;
  TConstDecl(NameTbl[V]).ShowName;
end ;

procedure TEnumDef.Show;
var
  EnumConst: TNameDecl;
  i: integer;
begin
  if NameTbl=Nil then begin
    inherited Show;
    Exit;
  end ;
  ShowBase;
  Inc(AuxLevel);
  PutS('{');
//  CurUnit.ShowTypeDef(hDTBase,Nil);
  CurUnit.ShowTypeName(hDTBase);
//  PutSFmt(',#%x,B:%x}',[hDTBase,B]);
  PutSFmt(',B:%x}',[B]);
  Dec(AuxLevel);
  Inc(NLOfs,1);
  SoftNL;
  PutS('(');
  Inc(NLOfs,1);
  for i:=0 to NameTbl.Count-1 do begin
    if i>0 then
      PutS(','+cSoftNL);
    EnumConst := NameTbl[i];
    PutS(EnumConst.Name^);
  end ;
  PutS(')');
  Dec(NLOfs,2);
end ;

{ TFloatDef. }
constructor TFloatDef.Create;
begin
  inherited Create;
  B := ReadByte;
end ;

function TFloatDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  E: Extended;
  N: PName;
  Ok: boolean;
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  Result := Sz;
  Ok := true;
  case Sz of
    SizeOf(Single): E := Single(DP^);
    SizeOf(Double): begin {May be TypeInfo should be used here}
      N := Name;
      if N=Nil then
        Ok := false
      else begin
        if CompareText(N^,'Double')=0 then
          E := Double(DP^)
        else if CompareText(N^,'Currency')=0 then
          E := Currency(DP^)
        else if CompareText(N^,'Comp')=0 then
          E := Comp(DP^)
        else
          Ok := false;
      end ;
    end ;
    SizeOf(Extended): E := Extended(DP^);
    SizeOf(Real): E := Real(DP^);
  else
    Ok := false;
  end ;
  if Ok then begin
    PutsFmt('%g',[E]);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TFloatDef.Show;
begin
  Inc(AuxLevel);
  PutS('float');
  Dec(AuxLevel);
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{B:%x}',[B]);
  Dec(AuxLevel);
end ;

{ TPtrDef. }
constructor TPtrDef.Create;
begin
  inherited Create;
  hRefDT := ReadUIndex;
end ;

type
  TShowPtrValProc = function(Ndx: TNDX; Ofs: Cardinal): boolean of object;

procedure ShowPointer(DP: Pointer; NilStr: String; ShowVal: TShowPtrValProc);
var
  V: Pointer;
  Fix: PFixupRec;
  VOk: boolean;
  FxName: PName;
begin
  V := Pointer(DP^);
  if GetFixupFor(DP,4,true,Fix)and(Fix<>Nil) then begin
    FxName := TUnit(FixUnit).AddrName[Fix^.Ndx];
    VOk := (FxName^[0]=#0) {To prevent from decoding named blocks}
      and Assigned(ShowVal)and ShowVal(Fix^.Ndx,Cardinal(V));
    if VOk then begin
      PutS(cSoftNL+'{');
    end ;
    PutS('@');
    if not ReportFixup(Fix,Cardinal(V)) then
     if V<>Nil then
       PutSFmt('+$%x',[Cardinal(V)]);
    if VOk then begin
      PutS('}');
    end ;
   end
  else if V=Nil then
    PutS(NilStr)
  else
    PutSFmt('$%8.8x',[Cardinal(V)]);
end ;

function StrLEnd(Str: PChar; L: Cardinal): PChar; assembler;
asm
        MOV     ECX,EDX
        MOV     EDX,EDI
        MOV     EDI,EAX
        XOR     AL,AL
        REPNE   SCASB
        JCXZ    @1
        DEC     EDI
  @1:
        MOV     EAX,EDI
        MOV     EDI,EDX
end;

function TPtrDef.ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
var
  U: TUnit;
  DT: TTypeDef;
  AR: TDCURec;
  DP: PChar;
  Sz: Cardinal;
  EP: PChar;
begin
  Result := false;
  if FixUnit=Nil then
    Exit;
  DT := CurUnit.GetGlobalTypeDef(hRefDT,U);
  if (DT=Nil)or(DT.Def=Nil)or(TDCURecTag(DT.Def^)<>drChRangeDef) then
    Exit;
  AR := TUnit(FixUnit).GetGlobalAddrDef(Ndx,U);
  if (AR=Nil)or not(AR is TProcDecl) then
    Exit;
  DP := TUnit(FixUnit).GetBlockMem(TProcDecl(AR).CodeOfs,TProcDecl(AR).Sz,Sz);
  if Ofs>=Sz then
    Exit;
  EP := StrLEnd(DP+Ofs,Sz-Ofs);
  if EP-DP=Sz then
    Exit;
 {We could also check that there are no fixups in the DP+Ofs..EP range}
  Result := true;
  PutS(StrConstStr(DP+Ofs,EP-(DP+Ofs)));
end ;

function TPtrDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',ShowRefValue);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TPtrDef.Show;
begin
  inherited Show;
//  PutSFmt('^{#%x}',[hRefDT]);
  PutS('^');
  CurUnit.ShowTypeDef(hRefDT,Nil);
end ;

function TPtrDef.GetRefOfsQualifier(Ofs: integer): String;
begin
  Result := '^'+CurUnit.GetOfsQualifier(hRefDT,Ofs);
end ;

{ TTextDef. }
procedure TTextDef.Show;
begin
  inherited Show;
  PutS('text');
end ;

{ TFileDef. }
constructor TFileDef.Create;
begin
  inherited Create;
  hBaseDT := ReadUIndex;
end ;

procedure TFileDef.Show;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS('file of'+cSoftNL);
//  PutSFmt('file of {#%x}',[hBaseDT]);
  CurUnit.ShowTypeDef(hBaseDT,Nil);
  Dec(NLOfs,2);
end ;

{ TSetDef. }
constructor TSetDef.Create;
begin
  inherited Create;
  BStart := ReadByte;
  hBaseDT := ReadUIndex;
end ;

function TSetDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  U: TUnit;
  T: TTypeDef;
  Cnt,K: integer;
  V0,Lo,Hi: TInt64Rec;
  WasOn,SetOn: boolean;
  B: Byte;

  procedure ShowRange;
  begin
    if Cnt>0 then
      PutS(','+cSoftNL);
    Inc(Cnt);
    U.ShowTypeValue(T,@V0,SizeOf(V0),true);
    Dec(Lo.Lo);
    if V0.Lo<>Lo.Lo then begin
      PutS('..');
      U.ShowTypeValue(T,@Lo,SizeOf(Lo),true);
    end ;
    Inc(Lo.Lo);
  end ;

begin
  Result := -1;
  if Sz>DS then
    Exit;
  T := CurUnit.GetGlobalTypeDef(hBaseDT,U);
  if (T=Nil)or not(T is TRangeBaseDef) then
    Exit;
  TRangeBaseDef(T).GetRange(Lo,Hi);
{  if (Lo.Hi<>0)or(Hi.Hi<>0)or(Lo.Lo<0) then
    Exit;
  Cnt := Hi.Lo div 8+1-Lo.Lo div 8;
  if Cnt > Sz then
    Exit;}
  {if Lo.Lo and $7>0 then begin
    B := Byte(DP^);
    Inc(PChar(DP));
  end ;}
  Lo.Lo := BStart*8{Lo.Lo and not $7};
  Hi.Lo := (BStart+Sz)*8 - 1;
  PutS('[');
  Inc(NLOfs,2);
  Cnt := 0;
  try
    SetOn := false;
    while Lo.Lo<=Hi.Lo do begin
      K := Lo.Lo and $7;
      if K=0 then begin
        B := Byte(DP^);
        Inc(PChar(DP));
      end ;
      WasOn := SetOn;
      SetOn := B and (1 shl K)<>0;
      if WasOn<>SetOn then begin
        if WasOn then
          ShowRange
        else
          V0.Lo := Lo.Lo;
      end;
      Inc(Lo.Lo);
    end ;
    if SetOn then
      ShowRange
  finally
    Dec(NLOfs,2);
  end ;
  PutS(']');
  Result := Sz;
end ;

procedure TSetDef.Show;
begin
  inherited Show;
  PutS('set ');
  Inc(AuxLevel);
  PutSFmt('{BStart:%x} ',[BStart]);
  Dec(AuxLevel);
  Inc(NLOfs,2);
  PutS('of'+cSoftNL);
  CurUnit.ShowTypeDef(hBaseDT,Nil);
  Dec(NLOfs,2);
end ;

{ TArrayDef. }
constructor TArrayDef.Create(IsStr: boolean);
begin
  inherited Create;
  B1 := ReadByte;
  hDTNdx := ReadUIndex;
  hDTEl := ReadUIndex;
  if not IsStr and CurUnit.IsMSIL then begin
    ReadUIndex;
  end ;
end ;

function TArrayDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  U: TUnit;
  T: TTypeDef;
  Rest,ElSz: Cardinal;
  Cnt: integer;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  T := CurUnit.GetGlobalTypeDef(hDTEl,U);
  if T=Nil then
    Exit;
  if (T.Def<>Nil)and(TDCURecTag(T.Def^)=drChRangeDef) then begin
    Result := Sz;
    PutS(StrConstStr(DP,Sz));
    Exit;
  end ;
  Rest := Sz;
  ElSz := T.Sz;
  PutS('(');
  Inc(NLOfs,2);
  try
    Cnt := 0;
    while Rest>=ElSz do begin
      if Cnt>0 then
        PutS(','+cSoftNL);
      if U.ShowTypeValue(T,DP,Rest,false)<0 then
        Exit;
      Inc(Cnt);
      Inc(PChar(DP),ElSz);
      Dec(Rest,ElSz);
    end ;
  finally
    Dec(NLOfs,2);
  end ;
  PutS(')');
  Result := Sz;
end ;

procedure TArrayDef.Show;
begin
//  PutSFmt('array{B1:%x}[{#%x}',[B1,hDTNDX]);
  PutS('array');
  Inc(NLOfs,2);
  ShowBase;
  Inc(AuxLevel);
  PutSFmt('{B1:%x}',[B1]);
  Dec(AuxLevel);
  PutS('[');
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of {#%x}',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  Dec(NLOfs,2);
end ;

function TArrayDef.GetOfsQualifier(Ofs: integer): String;
var
  U: TUnit;
  TD: TTypeDef;
  ElSz: integer;
begin
  TD := CurUnit.GetGlobalTypeDef(hDTEl,U);
  if TD=Nil then
    Result := inherited GetOfsQualifier(Ofs)
  else begin
    ElSz := TD.Sz;
    Result := Format('[%d]%s',[Ofs div ElSz,
      CurUnit.GetOfsQualifier(hDTEl,Ofs mod ElSz)]);
  end ;
end ;

{ TShortStrDef. }
function TShortStrDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
var
  L: integer;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  L := Length(PShortString(DP)^);
  if L>=Sz then
    Result := inherited ShowValue(DP,DS)
  else begin
    Result := Sz;
    PutS(StrConstStr(PChar(DP)+1,L));
  end ;
end ;

procedure TShortStrDef.Show;
begin
  if Sz=Cardinal(-1) then
    PutS('ShortString')
  else
    PutSFmt('String[%d]',[Sz-1]);
  Inc(NLOfs,2);
  ShowBase;
//  PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
  Inc(AuxLevel);
  PutSFmt('{B1:%x,[',[B1]);
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of #%x:',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  PutS('}');
  Dec(AuxLevel);
  Dec(NLOfs,2);
end ;

{ TStringDef. }
function TStringDef.ShowStrConst(DP: Pointer; DS: Cardinal): integer {Size used};
var
  L: integer;
  VP: Pointer;
begin
  Result := -1;
  if DS<9 {Min size} then
    Exit;
  if integer(DP^)<>-1 then
    Exit {Reference count,-1 => ~infinity};
  VP := PChar(DP)+SizeOf(integer);
  L := integer(VP^);
  if DS<L+9 then
    Exit;
  Inc(PChar(VP),SizeOf(integer));
  if (PChar(VP)+L)^<>#0 then
    Exit;
  Result := L+9;
  PutS(StrConstStr(VP,L));
end ;

function TStringDef.ShowRefValue(Ndx: TNDX; Ofs: Cardinal): boolean;
var
  U: TUnit;
  DT: TTypeDef;
  AR: TDCURec;
  DP: PChar;
  Sz: Cardinal;
  EP: PChar;
  LP: ^integer;
  L: integer;
begin
  Result := false;
  if (FixUnit=Nil)or(Ofs<8) then
    Exit;
  AR := TUnit(FixUnit).GetGlobalAddrDef(Ndx,U);
  if (AR=Nil)or not(AR is TProcDecl) then
    Exit;
  DP := TUnit(FixUnit).GetBlockMem(TProcDecl(AR).CodeOfs,TProcDecl(AR).Sz,Sz);
  if Ofs>=Sz then
    Exit;
  L := ShowStrConst(DP+Ofs-8,Sz-Ofs+8);
  Result := L>0;
end ;

function TStringDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'''''',ShowRefValue);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

procedure TStringDef.Show;
begin
  PutS('String');
  Inc(NLOfs,2);
  ShowBase;
//  PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
  Inc(AuxLevel);
  PutSFmt('{B1:%x,[',[B1]);
  CurUnit.ShowTypeDef(hDTNDX,Nil);
//  PutSFmt('] of #%x:',[hDTEl]);
  PutS('] of'+cSoftNL);
  CurUnit.ShowTypeDef(hDTEl,Nil);
  PutS('}');
  Dec(AuxLevel);
  Dec(NLOfs,2);
end ;

{ TVariantDef. }
constructor TVariantDef.Create;
begin
  inherited Create;
  if CurUnit.Ver>verD2 then
    B := ReadByte;
end ;

procedure TVariantDef.Show;
begin
  PutS('variant');
  inherited Show;
  Inc(AuxLevel);
  if CurUnit.Ver>verD2 then
    PutSFmt('{B:0x%x}',[B]);
  Dec(AuxLevel);
end ;

{ TObjVMTDef. }
constructor TObjVMTDef.Create;
begin
  inherited Create;
  hObjDT := ReadUIndex;
  NDX1 := ReadUIndex;
  if CurUnit.IsMSIL then begin
    ReadUIndex;
  end ;
end ;

procedure TObjVMTDef.Show;
begin
  inherited Show;
  Inc(NLOfs,2);
  PutS('class of'+cSoftNL);
//  PutSFmt('{hObjDT:#%x,NDX1:#%x}',[hObjDT,NDX1]);
  Inc(AuxLevel);
  PutSFmt('{NDX1:#%x}',[NDX1]);
  Dec(AuxLevel);
  CurUnit.ShowTypeDef(hObjDT,Nil);
  Dec(NLOfs,2);
end ;

{ TRecBaseDef. }
procedure TRecBaseDef.ReadFields(LK: TDeclListKind);
var
  NP: PName;
begin
  Tag := ReadTag;
  try
    CurUnit.ReadDeclList(LK,Fields);
  except
    on E: Exception do begin
      NP := Name;
      if NP<>Nil then
        E.Message := Format('%s in proc %s',[E.Message,NP^]);
      raise;
    end ;
  end ;
  if Tag<>drStop1 then
    TagError('Stop Tag');
end ;

destructor TRecBaseDef.Destroy;
begin
  FreeDCURecList(Fields);
  inherited Destroy;
end ;

function TRecBaseDef.ShowFieldValues(DP: Pointer; DS: Cardinal): integer {Size used};
{ Attention: records with variants can't be correctly shown
  (see readme.txt for details)}
var
  Cnt: integer;
  Ofs: integer;
  Ok: boolean;
  DeclL,Decl: TNameDecl;
begin
  Result := -1;
  if Sz>DS then
    Exit;
  Cnt := 0;
  Ok := true;
  DeclL := Fields;
  PutS('(');
  Inc(NLOfs,2);
  try
    while DeclL<>Nil do begin
      Decl := DeclL;
      if Decl is TCopyDecl then
        Decl := TCopyDecl(Decl).Base;
      if (Decl is TLocalDecl)and(Decl.GetTag = arFld) then begin
        if Cnt>0 then
          PutS(';'+cSoftNL);
        Decl.ShowName;
        PutS(': ');
        Ofs := TLocalDecl(Decl).Ndx;
        if (Ofs<0)or(Ofs>Sz)or
          (CurUnit.ShowGlobalTypeValue(TLocalDecl(Decl).hDT,PChar(DP)+Ofs,
             Sz-Ofs,false,false)<0)
        then begin
          PutS('?');
          Ok := false;
        end ;
        Inc(Cnt);
      end ;
      DeclL := DeclL.Next as TNameDecl;
    end ;
  finally
    PutS(')');
    if not Ok then
      inherited ShowValue(DP,DS);
    Dec(NLOfs,2);
  end ;
  Result := Sz;
end ;

function TRecBaseDef.GetParentType: TNDX;
begin
  Result := -1;
end ;

function TRecBaseDef.GetFldProperty(Fld: TNameDecl; hDT: TNDX): TPropDecl;
{ This procedure is required to find properties corresponding to unnamed fields }
var
  Decl: TDCURec;
begin
  while Decl<>Nil do begin
    if (Decl is TPropDecl)and(TPropDecl(Decl).hDT=hDT) then begin
      Result := TPropDecl(Decl);
      if (Result.hRead<>0)and(CurUnit.GetAddrDef(Result.hRead)=Fld) then
        Exit;
      if (Result.hWrite<>0)and(CurUnit.GetAddrDef(Result.hWrite)=Fld) then
        Exit;
    end ;
    Decl := Decl.Next;
  end ;
  Result := Nil;
end ;

function TRecBaseDef.GetFldOfsQualifier(Ofs: integer; TotSize: integer;
  Sorted: boolean): String;
var
  DeclL,Decl: TDCURec;
  FldOfs: integer;
var
  U: TUnit;
  TD: TTypeDef;
  FldName: String;
begin
  Result := '';
  if Ofs>=TotSize then
    Exit;
  DeclL := Fields;
  while DeclL<>Nil do begin
    Decl := DeclL;
    if Decl is TCopyDecl then
      Decl := TCopyDecl(Decl).Base;
    if (Decl is TLocalDecl)and(TLocalDecl(Decl).GetTag = arFld) then begin
      FldOfs := TLocalDecl(Decl).Ndx;
      if (FldOfs>=0) then begin
        if (FldOfs<=Ofs) then begin
          TD := CurUnit.GetGlobalTypeDef(TLocalDecl(Decl).hDT,U);
          if (TD<>Nil)and(Ofs<FldOfs+TD.Sz) then {Field found} begin
            FldName := TLocalDecl(Decl).Name^;
            if FldName='' then begin
              Decl := GetFldProperty(TNameDecl(Decl),TLocalDecl(Decl).hDT);
              if Decl<>Nil then
                FldName := TNameDecl(Decl).Name^;
              if FldName='' then
                FldName := Format('(:%s)',[TD.Name^]);
            end ;
            Result := Format('.%s%s',[FldName,
              CurUnit.GetOfsQualifier(TLocalDecl(Decl).hDT,Ofs-FldOfs)]);
            Exit;
          end ;
         end
        else if Sorted then
          break;
      end ;
    end ;
    DeclL := DeclL.Next;
  end ;
  Result := '';
end ;

{ TRecDef. }

function ReadClassInterfaces(PITbl: PPNDXTbl): integer{ICnt};
var
  i,j,hIntf,MCnt,N,hMember: integer;
  X1,X2: TNDX;
  ITbl: PNDXTbl;
begin
  Result := ReadIndex;
  if Result<=0 then
    Exit;
  {DAddB0 := ReadByte;
  DAddB1 := ReadByte;}
  ITbl := Nil;
  if PITbl<>Nil then begin
    GetMem(ITbl,Result*2*SizeOf(TNDX));
    PITbl^ := ITbl;
  end ;
  for i:=0 to Result-1 do begin
    hIntf := ReadUIndex;
    MCnt := ReadUIndex;
    if ITbl<>Nil then begin
      ITbl^[2*i] := hIntf;
      ITbl^[2*i+1] := MCnt;
    end ;
    if CurUnit.IsMSIL then begin
      for j:=1 to MCnt do begin
        N := ReadUIndex;
        hMember := ReadUIndex;
      end ;
    end ;
    if (CurUnit.Ver>=verD10)and(CurUnit.Ver<verK1) then begin
      X1 := ReadUIndex;
      X2 := ReadUIndex;
    end ;
  end ;
end ;

constructor TRecDef.Create;
var
  B1: Byte;
  X0,X: TNDX;
begin
  inherited Create;
  B2 := ReadByte;
  if CurUnit.IsMSIL then begin
    X := ReadUIndex;
    //!!!Temp Skip interface info - should make it stored in recs too
    ReadClassInterfaces(Nil);
   end
  else if (CurUnit.Ver>=verD9)and(CurUnit.Ver<verK1) then begin
    if (CurUnit.Ver>=verD10)and(CurUnit.Ver<verK1) then begin
      B1 := ReadByte;
      X0 := ReadUIndex;
    end ;
    X := ReadUIndex;
  end ;
  ReadFields(dlFields);
end ;

function TRecDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  Result := ShowFieldValues(DP,DS);
end ;

procedure TRecDef.Show;

type
  PNameDecl = ^TNameDecl;

  function GetCaseOfs(L: TDCURec): integer;
  //Find the smallest field offset, among the fields before the end of the previous field
  var
    Ofs,Sz,PrevOfs: integer;
  begin
    Result := MaxInt;
    PrevOfs := -1;
    while L<>Nil do begin
      if not(L is TLocalDecl) then
        Exit;
      Ofs := TLocalDecl(L).NDX;
      if Ofs<PrevOfs then begin
        if Ofs<Result then
          Result := Ofs;
      end ;
      Sz := CurUnit.GetTypeSize(TLocalDecl(L).hDT);
      if Sz<0 then
        Sz := 1; {For unknown data types I suppose that it should take some space}
      PrevOfs := Ofs+Sz;
      L := L.Next;
    end ;
  end ;

  function GetNoCaseEP(var L: TDCURec; OfsRq: integer): PNameDecl;
  //Find 1st field >= OfsRq => 1st case field
  var
    Ofs: integer;
  begin
    Result := @L;
    while (Result^<>Nil)and(Result^ is TLocalDecl) do begin
      if TLocalDecl(Result^).NDX>=OfsRq then
        Exit;
      Result := @Result^.Next;
    end ;
    Result := Nil;
  end ;

  function GetNextEP(var L: TDCURec; OfsRq: integer): PNameDecl;
 {Requires: L-case field
  Find the next field with the same or higher (because of alignment) offset

  For example, in D7 this record has the following field offsets:
  TRec = record
    case integer of
    0: (A: integer@0);
    1: (V: byte@0;
      case integer of
      0: (B: double@8);
      1: (C: Byte@4))
  end ;
  }
  var
    Ofs,OfsMax,Sz,PrevOfs: integer;
  begin
    Sz := CurUnit.GetTypeSize(TLocalDecl(L).hDT);
    if Sz<0 then
      Sz := 1;
    OfsMax := TLocalDecl(L).NDX+Sz;
    Result := @L.Next;
    while Result^<>Nil do begin
      if not(Result^ is TLocalDecl) then
        Break;
      Ofs := TLocalDecl(Result^).NDX;
      if (Ofs>=OfsRq)and(Ofs<OfsMax) then
        Exit;
      Result := @(Result^.Next);
    end ;
    Result := Nil;
  end ;

  procedure ShowCase(Ofs0: Cardinal; Start: TNameDecl; Sep: TDeclSepFlags; SK: TDeclSecKind);
  var
    CaseOfs,hCase: integer;
    EP: PNameDecl;
    EP0,CaseP: TNameDecl;
  begin
    CaseOfs := GetCaseOfs(Start);
    EP := Nil;
    if CaseOfs<MaxInt then
      EP := GetNoCaseEP(TDCURec(Start),CaseOfs);
    if EP<>Nil then begin
      EP0 := EP^;
      EP^ := Nil;
      Include(Sep,dsLast);
    end ;
    SK := CurUnit.ShowDeclList(dlFields,Start,Ofs0,2,Sep,RecSecKinds,SK);
    if EP<>Nil then begin
      NLOfs := Ofs0+2;
      NL;
      PutS('case Integer of');
      hCase := 0;
      repeat
        EP^ := EP0;
        NLOfs := Ofs0+3;
        NL;
        PutSFmt('%d: (',[hCase]); //The actual case labels and case data type
          //are not stored in DCUs
        Inc(hCase);
        CaseP := EP0;
        EP := GetNextEP(TDCURec(CaseP),CaseOfs);
        if EP<>Nil then begin
          EP0 := EP^;
          EP^ := Nil;
        end ;
        ShowCase(Ofs0+3,CaseP,[dsNoFirst],SK);
        //CurUnit.ShowDeclList(dlFields,CaseP,Ofs0+3,2,[{dsLast}],RecSecKinds,SK);
        PutS(')');
        if EP=Nil then
          break;
        PutS(';');
      until EP=Nil;
    end ;
    NLOfs := Ofs0;
  end ;

begin
  PutS('record ');
  Inc(AuxLevel);
  PutSFmt('{B2:%x}',[B2]);
  Dec(AuxLevel);
  inherited Show;
  ShowCase(NLOfs,Fields,[dsLast],skPublic);
  NL;
  PutS('end');
end ;

function TRecDef.GetOfsQualifier(Ofs: integer): String;
begin
  Result := GetFldOfsQualifier(Ofs,Sz,false{Sorted});
end ;

{ TProcTypeDef. }
constructor TProcTypeDef.Create;
var
  CK: TProcCallKind;
begin
  inherited Create;
  if CurUnit.Ver>verD2 then
    NDX0 := ReadUIndex;//B0 := ReadByte;
  hDTRes := ReadUIndex;
  AddSz := 0;
  AddStart := ScSt.CurPos;
  Tag := ReadTag;
 {99.99% that instead of WHILE it would be enough to use IF} 
  while (Tag<>drEmbeddedProcStart) do begin
    if (Tag=drStop1) then
      Exit;
    CK := ReadCallKind;
    if CK=pcRegister then
      Tag := ReadTag
    else
      CallKind := CK;
    Inc(AddSz);
  end ;
  ReadFields(dlArgsT);
end ;

function TProcTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',Nil);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
end ;

function TProcTypeDef.IsProc: boolean;
begin
  Result := CurUnit.TypeIsVoid(hDTRes);
end ;

function TProcTypeDef.ProcStr: String;
begin
  if IsProc then
    Result := 'procedure'
  else
    Result := 'function';
end ;

procedure TProcTypeDef.ShowDecl(Braces: PChar);
var
  Ofs0: Cardinal;
begin
  if Braces=Nil then
    Braces := '()';
  {if B0 and $4<>0 then}
  Inc(AuxLevel);
  if CurUnit.Ver>0 then
    PutSFmt('{NDX0:#%x}',[NDX0]);
  Dec(AuxLevel);
  inherited Show;
  Inc(AuxLevel);
  PutSFmt('{AddSz:%x}',[AddSz]);
  Dec(AuxLevel);
  Ofs0 := NLOfs;
  if Fields<>Nil then begin
    PutS(Braces[0]);
    CurUnit.ShowDeclList(dlArgsT,Fields,Ofs0,2,[{dsComma,}dsNoFirst,dsSoftNL],
      ProcSecKinds,skNone);
    PutS(Braces[1]);
  end ;
  NLOfs := Ofs0+2;
  if not IsProc then begin
    PutS(':');
    SoftNL;
    CurUnit.ShowTypeDef(hDTRes,Nil);
  end ;
  if NDX0 and $10<>0 then
    PutS(cSoftNL+'of object');
  if CallKind<>pcRegister then begin
    SoftNL;
    PutS(CallKindName[CallKind]);
  end ;
  NLOfs := Ofs0;
end ;

procedure TProcTypeDef.Show;
begin
  PutS(ProcStr);
 // SoftNL;
  ShowDecl(Nil);
end ;

{ TObjDef. }
constructor TObjDef.Create;
begin
  inherited Create;
  B03 := ReadByte;
  hParent := ReadUIndex;
  BFE := ReadByte;
  NDX1 := ReadIndex;
  B00 := ReadByte;
  ReadFields(dlFields);
end ;

function TObjDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  Result := ShowFieldValues(DP,DS);
end ;

procedure TObjDef.Show;
var
  Ofs0: Cardinal;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  PutS('object');
  inherited Show;
  if hParent<>0 then begin
    PutS('(');
    CurUnit.ShowTypeName(hParent);
    PutS(')');
  end ;
  Inc(AuxLevel);
  NL;
  PutSFmt('{B03:%x, BFE:%x, NDX1:%x, B00:%x)}',
    [B03, BFE, NDX1, B00]);
  CurUnit.ShowDeclList(dlFields,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  Dec(AuxLevel);
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

function TObjDef.GetParentType: TNDX;
begin
  Result := hParent;
end ;

function TObjDef.GetOfsQualifier(Ofs: integer): String;
begin
  Result := GetFldOfsQualifier(Ofs,Sz,true{Sorted});
  if Result<>'' then
    Exit;
  if hParent<>0 then
    Result := CurUnit.GetOfsQualifier(hParent,Ofs)
  else
    Result := inherited GetOfsQualifier(Ofs);
end ;

{ TClassDef. }

(*
procedure CalcVMOffsets(Fields: TNameDecl; VMCnt: integer);
var
  Decl: TNameDecl;
  MD: TMethodDecl absolute Decl;
begin
  Decl := Fields;
  while Decl<>Nil do begin
    if Decl is TMethodDecl then begin
      if MD.InIntrf or(MD.LocFlags and(lfOverride or lfVirtual)=lfVirtual) then
        Dec(VMCnt);
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
  Decl := Fields;
  while Decl<>Nil do begin
    if Decl is TMethodDecl then begin
      if MD.InIntrf or(MD.LocFlags and(lfOverride or lfVirtual)=lfVirtual) then begin
        MD.VMTNDX := VMCnt;
        Inc(VMCnt);
      end ;
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
end ;
*)

constructor TClassDef.Create;
var
  BX: Byte;//TNDX;
begin
  inherited Create;
  if (CurUnit.Ver>=verD10)and(CurUnit.Ver<verK1) then
    BX := ReadByte;//ReadUIndex;    Some flags
  hParent := ReadUIndex;
  InstBaseRTTISz := ReadUIndex;
  InstBaseSz := ReadIndex;
  InstBaseV := ReadUIndex;
  VMCnt := ReadUIndex;
  NdxFE := ReadUIndex;
  NDX00a := ReadUIndex;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then
    B04 := ReadUIndex
  else
    B04 := ReadByte;
  if CurUnit.Ver>verD2 then begin
    ReadBeforeIntf; //Fo
    ICnt := ReadClassInterfaces(@ITbl);
  end ;
  ReadFields(dlClass);
 // CalcVMOffsets(Fields,VMCnt);
end ;

destructor TClassDef.Destroy;
begin
  if ITbl<>Nil then
    FreeMem(ITbl,ICnt*2*SizeOf(TNDX));
  inherited Destroy;
end ;

function TClassDef.ShowValue(DP: Pointer; DS: Cardinal): integer {Size used};
begin
  if Sz>DS then begin
    Result := -1;
    Exit;
  end ;
  if Sz=4 then begin
    Result := Sz;
    ShowPointer(DP,'Nil',Nil);
    Exit;
  end ;
  Result := inherited ShowValue(DP,Sz);
//  Result := ShowFieldValues(DP,DS);
end ;

procedure TClassDef.Show;
var
  Ofs0: Cardinal;
  i,j: integer;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
  PutS('class ');
  if (hParent<>0)or(ICnt<>0) then begin
    PutS('(');
    i := 0;
    if hParent<>0 then begin
      CurUnit.ShowTypeName(hParent);
      Inc(i);
    end ;
    NDXHi := 0;
    for j:=0 to integer(ICnt)-1 do begin
      if i>0 then
        PutS(','+cSoftNL);
      CurUnit.ShowTypeName(ITbl^[2*j]);
      PutSFmt('{%s}',[NDXToStr(ITbl^[2*j+1])]);
    end ;
    PutS(')'+cSoftNL);
  end ;
  Inc(AuxLevel);
  PutSFmt('{InstBase:(Sz: %x, RTTISz: %x, V: %x),',
    [InstBaseSz,InstBaseRTTISz,InstBaseV]);
  SoftNL;
  PutSFmt('VMCnt:#%x,NdxFE:#%x,NDX00a:#%x,B04:%x', [VMCnt,NdxFE,NDX00a,B04]);
  PutS('}');
  Dec(AuxLevel);
  inherited Show;
  CurUnit.ShowDeclList(dlClass,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

function TClassDef.GetParentType: TNDX;
begin
  Result := hParent;
end ;

function TClassDef.GetRefOfsQualifier(Ofs: integer): String;
begin
  Result := GetFldOfsQualifier(Ofs,InstBaseSz,true{Sorted});
  if Result<>'' then
    Exit;
  if hParent<>0 then
    Result := CurUnit.GetRefOfsQualifier(hParent,Ofs)
  else
    Result := inherited GetRefOfsQualifier(Ofs);
end ;

procedure TClassDef.ReadBeforeIntf;
begin
end ;

{ TMetaClassDef. }
procedure TMetaClassDef.ReadBeforeIntf;
begin
  hCl := ReadUIndex;
  ReadUIndex; //Ignore - was always 0
end ;

{ TInterfaceDef. }
constructor TInterfaceDef.Create;
var
  LK: TDeclListKind;
  i,Cnt,X: integer;
begin
  inherited Create;
  hParent := ReadUIndex;
  VMCnt := ReadIndex;
  GUID := ReadMem(SizeOf(TGUID));
  B := ReadByte;
  if (B and $4)=0 then
    LK := dlInterface
  else
    LK := dlDispInterface;
  if (CurUnit.Ver>=verD8)and(CurUnit.Ver<verK1) then begin
    Cnt := ReadUIndex;
    for i:=1 to Cnt do begin
      X := ReadUIndex;
      X := ReadUIndex;
    end ;
  end ;
  ReadFields(LK);
 // CalcVMOffsets(Fields,VMCnt);
end ;

procedure TInterfaceDef.Show;
var
  Ofs0: Cardinal;
begin
  Ofs0 := NLOfs;
  Inc(NLOfs,2);
//  PutSFmt('interface {Ndx1:#%x,B:%x,hParent: #%x}', [Ndx1,B,hParent]);
  PutS('interface ');
  if hParent<>0 then begin
    PutS('(');
    CurUnit.ShowTypeName(hParent);
    PutS(')');
  end ;
  Inc(AuxLevel);
  SoftNL;
  PutSFmt('{VMCnt:#%x,B:%x}', [VMCnt,B]);
  Dec(AuxLevel);
  SoftNL;
  inherited Show;
  SoftNL;
  with GUID^ do
    PutSFmt('[''{%8.8x-%4.4x-%4.4x-%2.2x%2.2x-%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x}'']',
      [D1,D2,D3,D4[0],D4[1],D4[2],D4[3],D4[4],D4[5],D4[6],D4[7]]);
  CurUnit.ShowDeclList(dlInterface,Fields,Ofs0,2,[dsLast],ClassSecKinds,skNone);
  {if Args<>Nil then}
  NLOfs := Ofs0;
  NL;
  PutS('end');
end ;

{ TVoidDef. }
procedure TVoidDef.Show;
begin
  PutS('void');
  inherited Show;
end ;

(*
{ TStrConstTypeDef. }
constructor TStrConstTypeDef.Create;
begin
  inherited Create;
  hBase := ReadUIndex;
end ;

procedure TStrConstTypeDef.Show;
begin
  PutS('strConstType');
  inherited Show;
end ;
*)

end.

