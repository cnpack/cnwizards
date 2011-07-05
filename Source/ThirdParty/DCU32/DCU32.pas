unit DCU32;
(*
The DCU parser module of the DCU32INT utility by Alexei Hmelnov.
(All the DCU data structures are described here and in the DCURecs module)
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
interface
uses
  SysUtils, Classes, DasmDefs, DCU_In, DCU_Out, FixUp, DCURecs;

{$WARNINGS OFF}
{$HINTS OFF}

{$IFNDEF VER90}
 {$IFNDEF VER100}
  {$REALCOMPATIBILITY ON}
 {$ENDIF}
{$ENDIF}

const {My own (AX) codes for Delphi/Kylix versions}
  verD2=2;
  verD3=3;
  verD4=4;
  verD5=5;
  verD6=6;
  verD7=7;
  verD8=8;
  verD9=9; //2005
  verD10=10; //2006
  verD12=12; // Added by Liu Xiao. Delphi 2009.
  verD14=14; // Added by Liu Xiao. Delphi 2010.
  verD15=15; // Added by Liu Xiao. Delphi 2011(XE).
  verD16=16; // Added by Liu Xiao. Delphi 2012(XE2).
  verK1=100; //Kylix 1.0
  verK2=101; //Kylix 2.0
  verK3=103; //Kylix 2.0

{ Internal unit types }
const
  drStop=0;
  drStop_a=$61{'a'}; //Last Tag in all files
  drStop1=$63{'c'};
  drUnit=$64{'d'};
  drUnit1=$65{'e'}; //in implementation
  drImpType=$66{'f'};
  drImpVal=$67{'g'};
  drDLL=$68{'h'};
  drExport=$69{'i'};
  drEmbeddedProcStart=$6A{'j'};
  drEmbeddedProcEnd=$6B{'k'};
  drCBlock=$6C{'l'};
  drFixUp=$6D{'m'};
  drImpTypeDef=$6E{'n'}; //import of type definition by "A = type B"
  drSrc=$70{'p'};
  drObj=$71{'q'};
  drRes=$72{'r'};
  drAsm=$73{'s'}; //Found in D5 Debug versions
  drSrcGeneric=$76{'v'}; // Generic import (D2009)
  drStop2=$9F{'?}; //!!!
  drConst=$25{'%'};
  drResStr=$32{'2'};
  drType=$2A{'*'};
  drTypeP=$26{'&'};
  drProc=$28{'('};
  drSysProc=$29{')'};
  drVoid=$40{'@'};
  drVar=$20{' '};
  drThreadVar=$31{'1'};
  drVarC=$27{'''};
  drBoolRangeDef=$41{'A'};
  drChRangeDef=$42{'B'};
  drEnumDef=$43{'C'};
  drRangeDef=$44{'D'};
  drPtrDef=$45{'E'};
  drClassDef=$46{'F'};
  drObjVMTDef=$47{'G'};
  drProcTypeDef=$48{'H'};
  drFloatDef=$49{'I'};
  drSetDef=$4A{'J'};
  drShortStrDef=$4B{'K'};
  drArrayDef=$4C{'L'};
  drRecDef=$4D{'M'};
  drObjDef=$4E{'N'};
  drFileDef=$4F{'O'};
  drTextDef=$50{'P'};
  drWCharRangeDef=$51{'Q'}; //WideChar
  drStringDef=$52{'R'};
  drVariantDef=$53{'S'};
  drInterfaceDef=$54{'T'};
  drWideStrDef=$55{'U'};
  drWideRangeDef=$56{'V'};

//Various tables
  drCodeLines=$90;
  drLinNum=$91;
  drStrucScope=$92;
  drSymbolRef=$93;
  drLocVarTbl=$94;

  drUnitFlags=$96;

//ver70 or higher tags (all of unknown purpose)
  drUnitAddInfo=$34{'4'};
  drConstAddInfo=$9C;
  drProcAddInfo=$9E;

//ver80 or higher tags (all of unknown purpose)
  drORec=$6F{'o'}; //goes before drCBlock in MSIL
  drInfo98=$98;
  drStrConstRec=$35{'5'};
  drMetaClassDef=$57{'W'};
//Kylix specific flags
{  drUnit3=$E0; //4-bytes record, present in almost all units
  drUnit3c=$06; //4-bytes record, present in System, SysInit
}
  drUnit4=$0F; //5-bytes record, was observed in QOpenBanner.dcu only

//ver10 and higher tags
//  drAddInfo6=$36{'6'};
  drSpecVar=$37{'7'};
  arClassVarReal=$2D {real value}{'-'};
  arClassVar=$36 {technical value};
  drCLine=$A0;
  drA1Info=$A1;
  drA2Info=$A2;
  arCopyDecl=$A3;

  arVal=$21{'!'};
  arVar=$22{'"'};
  arResult=$23{'#'};
  arAbsLocVar=$24{'$'};
  arLabel=$2B{'+'};
//Fields
  arFld=$2C{','};
  arMethod=$2D{'-'};
  arConstr=$2E{'.'};
  arDestr=$2F{'/'};
  arProperty=$30{'0'};
  arSetDeft=$9A;

  arCDecl=$81;
  arPascal=$82;
  arStdCall=$83;
  arSafeCall=$84;

type
  TProcCallTag=arCDecl..arSafeCall;

type
{ Auxiliary data types }

TDeclSepFlags = set of (dsComma,dsLast,dsNoFirst,dsNL,dsSoftNL,
  dsSmallSameNL,dsOfsProc);

TDeclSecKinds = set of TDeclSecKind;

const
  RecSecKinds: TDeclSecKinds = [];
  ProcSecKinds: TDeclSecKinds = [];
  BlockSecKinds: TDeclSecKinds = [skNone,skLabel,skConst,skType,skVar,
    skThreadVar,skResStr,skExport,skProc];
  ClassSecKinds: TDeclSecKinds = [skPrivate,skProtected,skPublic, skPublished];

type

PSrcFileRec = ^TSrcFileRec;
TSrcFileRec = record
  Next: PSrcFileRec;
  Def: PNameDef;
  FT: LongInt;
  NDX: integer;
  Lines: TStringList;
end ;

type //AUX, not real file structures

PCodeLineRec = ^TCodeLineRec;
TCodeLineRec = record
  Ofs,L: integer;
end ;

PCodeLineTbl = ^TCodeLineTbl;
TCodeLineTbl = array[Word] of TCodeLineRec;

//Using the $I directive DCU file can be composed of several source files
//The TLineRangeRec sructure represents the mapping of DCU internal line numbers
//to the real line numbers of source files
PLineRangeRec = ^TLineRangeRec;
TLineRangeRec = record
  Line0,LineNum,Num0: integer;
  SrcF: PSrcFileRec;
end ;

PLineRangeTbl = ^TLineRangeTbl;
TLineRangeTbl = array[Word] of TLineRangeRec;

type

TUnit = class;

PUnitImpRec = ^TUnitImpRec;
TUnitImpFlags = set of (ufImpl,ufDLL);
TUnitImpRec = record
  Ref: TImpDef;
  Name: PName;
  Decls: TBaseDef;
//  Types: TBaseDef;
//  Addrs: TBaseDef;
  Flags: TUnitImpFlags;
  U: TUnit;
end ;

TUnit = class
protected
  FMemPtr: PChar;
  FMemSize: Cardinal;
  FFromPackage: boolean;
  FVer: integer;
  FIsMSIL: boolean;
  FStamp,FFlags,FUnitPrior: integer;
  FFName,FFExt,FUnitName: String;
  FSrcFiles: PSrcFileRec;
  FUnitImp: TList;
  FTypes: TList;
  FAddrs: TList;
  FhNextAddr: integer; //Required for ProcAddInfo in Ver>verD8
  FExportNames: TStringList;
  FDecls: TNameDecl;
//  FDefs: TBaseDef;
  FTypeDefCnt: integer;
  FTypeShowStack: TList;
 {Data block}
  FDataBlPtr: PChar;
  FDataBlSize: Cardinal;
  FDataBlOfs: Cardinal;
 {Fixups}
//  FfxStart,FfxEnd: Byte;
  FFixupCnt: integer;
  FFixupTbl: PFixupTbl;
  FCodeLineCnt: integer;
  FCodeLineTbl: PCodeLineTbl;
  FLineRangeCnt: integer;
  FLineRangeTbl: PLineRangeTbl;
  FLocVarCnt: integer;
  FLocVarTbl: PLocVarTbl;
  FLoaded: boolean;
  procedure ReadSourceFiles;
  procedure ShowSourceFiles;
  function ShowUses(PfxS: String; FRq: TUnitImpFlags): boolean;
  procedure ReadUses(TagRq: TDCURecTag);
  function ReadUnitAddInfo: TUnitAddInfo;
  procedure SetListDefName(L: TList; hDef: integer; Name: PName);
  procedure SetDeclMem(hDef: integer; Ofs,Sz: Cardinal);
//  procedure AddAddrName(hDef: integer; Name: PName);
  function GetTypeName(hDef: integer): PName;
  function GetAddrName(hDef: integer): PName;
{-------------------------}
  function GetUnitImpRec(hUnit: integer): PUnitImpRec;
  function GetUnitImp(hUnit: integer): TUnit;
  procedure SetExportNames(Decl: TNameDecl);
  procedure SetEnumConsts(var Decl: TNameDecl);
  function GetExportDecl(Name: String; Stamp: integer): TNameFDecl;
  function GetExportType(Name: String; Stamp: integer): TTypeDef;
{-------------------------}
  procedure LoadFixups;
  procedure LoadCodeLines;
  function GetSrcFile(N: integer): PSrcFileRec;
  procedure LoadLineRanges;
  procedure LoadStrucScope;
  procedure LoadSymbolInfo;
  procedure LoadLocVarTbl;
  function GetNextFixup(iStart: integer; Ofs: Cardinal): integer;
  function GetStartCodeLine(Ofs: integer): integer;
  procedure GetCodeLineRec(i: integer; var CL: TCodeLineRec);
  function GetStartLineRange(L: integer): integer;
  procedure GetLineRange(i: integer; var LR: TLineRangeRec);
//  function RegDataBl(BlSz: Cardinal): Cardinal;
  procedure DetectUniqueNames;
  procedure DasmCodeBlSeq(Ofs0,BlOfs,BlSz,SzMax: Cardinal);
  procedure DasmCodeBlCtlFlow(Ofs0,BlOfs,BlSz: Cardinal);
  function ReadConstAddInfo(LastProcDecl: TNameDecl): integer;
  procedure SetProcAddInfo(V: integer{; LastProcDecl: TNameDecl});
public { Exported for DCURecs: }
  function AddAddrDef(ND: TDCURec): integer;
  procedure RefAddrDef(V: integer);
  function GetAddrDef(hDef: integer): TDCURec;
  function GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
  procedure AddTypeDef(TD: TTypeDef);
  procedure ClearLastTypeDef(TD: TTypeDef);
  procedure ClearAddrDef(ND: TNameDecl);
  function GetTypeDef(hDef: integer): TTypeDef;
  function GetTypeSize(hDef: integer): integer;
  procedure AddTypeName(hDef: integer; Name: PName);
  function ShowTypeName(hDef: integer): boolean;
  function TypeIsVoid(hDef: integer): boolean;
  function RegTypeShow(T: TBaseDef): boolean;
  procedure UnRegTypeShow(T: TBaseDef);
  procedure ShowDataBl(Ofs0,BlOfs,BlSz: Cardinal);
  procedure ShowCodeBl(Ofs0,BlOfs,BlSz: Cardinal);
  procedure ShowTypeDef(hDef: integer; N: PName);
  function GetGlobalTypeDef(hDef: integer; var U: TUnit): TTypeDef;
  function ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal;
     IsConst: boolean): integer {Size used};
  function ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal;
    AndRest,IsConst: boolean): integer {Size used};
  function ShowGlobalConstValue(hDef: integer): boolean;
  function GetOfsQualifier(hDef: integer; Ofs: integer): String;
  function GetRefOfsQualifier(hDef: integer; Ofs: integer): String;
  function GetBlockMem(BlOfs,BlSz: Cardinal; var ResSz: Cardinal): Pointer;
  function FixTag(Tag: TDCURecTag): TDCURecTag;
  procedure ReadDeclList(LK: TDeclListKind; var Result: TNameDecl);
  function ShowDeclList(LK: TDeclListKind; Decl: TNameDecl; Ofs: Cardinal;
    dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds;
    skDefault: TDeclSecKind): TDeclSecKind;
  function GetStartFixup(Ofs: Cardinal): integer;
  procedure SetStartFixupInfo(Fix0: integer);
  property DataBlPtr: PChar read FDataBlPtr;
  property UnitImpRec[hUnit: integer]: PUnitImpRec read GetUnitImpRec;
  procedure DoShowFixupTbl;
  procedure FillProcLocVarTbls;
  procedure DoShowLocVarTbl;
public
  function Load(FName: String; VerRq: integer; MSILRq: boolean; AMem: Pointer; 
    UsesOnly: Boolean = False): boolean; //Load instead of Create
    //to prevent from Destroy after Exception in constructor
  destructor Destroy; override;
  procedure Show;
  function GetAddrStr(hDef: integer; ShowNDX: boolean): String;
  property UnitName: String read FUnitName;
  property FileName: String read FFName;
  property ExportDecls[Name: String; Stamp: integer]: TNameFDecl read GetExportDecl;
  property ExportTypes[Name: String; Stamp: integer]: TTypeDef read GetExportType;
  property Ver: integer read FVer;
  property IsMSIL: boolean read FIsMSIL;
  property Stamp: integer read FStamp;
//  property fxStart: Byte read FfxStart;
//  property fxEnd: Byte read FfxEnd;
  property AddrName[hDef: integer]: PName read GetAddrName;
  property DeclList: TNameDecl read FDecls;
  property MemPtr: PChar read FMemPtr;
end ;

var
  MainUnit: TUnit = Nil;
  CurUnit: TUnit;

{ Exported for DCURecs: }
function GetDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean): String;

implementation

uses
  DCUTbl, DCP, DasmX86, DasmMSIL, DasmCF, Op;

type
  ulong = Cardinal;
  TFileTime = ulong;

procedure FreeDCURecTList(L: TList);
var
  Tmp: TDCURec;
  i: integer;
begin
  if L=Nil then
    Exit;
  for i:=0 to L.Count-1 do begin
    Tmp := L[i];
    Tmp.Free;
  end ;
  L.Free;
end ;

function FileDateToStr(FT: TFileTime): String;
const
  DaySec=24*60*60;
var
  T: TDateTime;
begin
  if CurUnit.Ver<verK1 then
    T := FileDateToDateTime(FT)
  else
    T := EncodeDate(1970,1,1)+FT/DaySec{Unix Time to Delphi time};
  Result := FormatDateTime('c',T);
end ;

function GetDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean): String;
var
  N: PName;
  ScopeCh: Char;
  Pfx: String;
  CP: PChar;
  cd: integer;
begin
  if D=Nil then
    N := @NoName
  else
    N := D.Name;
  if N^[0]=#0 then begin
    Pfx := NoNamePrefix;
    Result := Format('%x',[hDef]);
    ShowNDX := false;
   end
  else if N^[1]='.' then begin
    Pfx := DotNamePrefix;
    Result := Copy(N^,2,255);
   end
  else begin
    Result := N^;
    Pfx := '';
  end ;
  if Pfx<>'' then begin
    CP := StrScan(PChar(Pfx),'%');
    if CP<>Nil then begin
      if D=Nil then
        ScopeCh := 'N'
      else begin
        if (D is TTypeDecl)or(D is TTypeDef) then
          ScopeCh := 'T'
        else if D is TVarDecl then
          ScopeCh := 'V'
        else if D is TConstDecl then
          ScopeCh := 'C'
        else if D is TProcDecl then
          ScopeCh := 'F'
        else if D is TLabelDecl then
          ScopeCh := 'L'
        else if (D is TPropDecl)or(D is TDispPropDecl) then
          ScopeCh := 'P'
        else if D is TLocalDecl then
          ScopeCh := 'v'
        else if D is TMethodDecl then
          ScopeCh := 'M'
        else if D is TExportDecl then
          ScopeCh := 'E'
        else
          ScopeCh := 'n';
      end ;
      cd := CP-PChar(Pfx);
      SetLength(Pfx,Length(Pfx));{Make the string unique - it could be altered}
      CP := PChar(Pfx)+cd;
      repeat
        CP^ := ScopeCh;
        CP := StrScan(CP+1,'%');
      until CP=Nil;
    end ;
    Result := Pfx+Result;
  end ;
  if ShowNDX then
    Result := Format('%s{0x%x}',[Result, hDef]);
end ;

{ TUnit. }

procedure TUnit.ReadSourceFiles;
var
  hSrc,F: integer;
  SrcFName: String;
  CP: PChar;
  FT: TFileTime;
  B: Byte;
  SFRP: ^PSrcFileRec;
  SFR,SFRMain: PSrcFileRec;
begin
//  NLOfs := 0;
  hSrc := 0;
  FSrcFiles := Nil;
  SFRMain := Nil;
  SFRP := @FSrcFiles;
  while (Tag=drSrc)or(Tag=drRes)or(Tag=drObj)or(Tag=drAsm)or(Tag=drSrcGeneric) do begin
    New(SFR);
    SFR^.Next := Nil;
    SFRP^ := SFR;
    SFRP := @SFR^.Next;
    SFR^.Def := DefStart;
    ReadName;
    SFR^.FT := ReadULong;
    F := ReadUIndex;
    if F=0 then
      SFRMain := SFR;
    SFR^.Ndx := F;
    SFR^.Lines := Nil;
    if IsMSIL and(Tag<>drRes) then begin
      SrcFName := ReadStr; //Ignored by now, because it's always empty
    end ;
    Tag := ReadTag;
  end ;
  if FSrcFiles=Nil then
    DCUError('No source files');
  if SFRMain=Nil{Paranoic} then
    SFRMain := FSrcFiles;
  FUnitName := ExtractFileNameAnySep(SFRMain^.Def^.Name);
  CP := StrRScan(PChar(FUnitName),'.');
  if CP<>Nil then
    SetLength(FUnitName,CP-PChar(FUnitName));
end ;

procedure TUnit.ShowSourceFiles;
var
  SFR: PSrcFileRec;
  T: TDCURecTag;
begin
  if FSrcFiles=Nil then
    Exit {Paranoic test};
  PutSFmt('unit %s;',[FUnitName]);
  Inc(AuxLevel);
  if Ver>verD2 then begin
    PutSFmt(' {Flags: 0x%x',[FFlags]);
    if Ver>verD3 then
      PutSFmt(', Priority: 0x%x',[FUnitPrior]);
    PutS('}');
  end ;
  Dec(AuxLevel);
  NL;
  PutS('{Source files:');
  NLOfs := 2;
  SFR := FSrcFiles;
  NL;
  while true do begin
    T := SFR^.Def^.Tag;
    case T of
     drObj: PutS('$L ');
     drRes: PutS('$R ');
    end ;
    PutS(SFR^.Def^.Name);
    if (integer(SFR^.FT)<>-1)and(integer(SFR^.FT)<>0) then
      PutSFmt(' (%s)',[FileDateToStr(SFR^.FT)]);
    SFR := SFR^.Next;
    if SFR=Nil then
      Break;
    PutS(','+cSoftNL)
  end ;
  PutS('}');
  NLOfs := 0;
  NL;
  NL;
end ;

function TUnit.ShowUses(PfxS: String; FRq: TUnitImpFlags): boolean;
var
  i,Cnt,hImp: integer;
  U: PUnitImpRec;
  Decl: TBaseDef;
  NLOfs0: Cardinal;
begin
  Result := false;
  if FUnitImp.Count=0 then
    Exit;
  Cnt := 0;
  NLOfs0 := NLOfs;
  for i:=0 to FUnitImp.Count-1 do begin
    U := FUnitImp[i];
    if FRq<>U.Flags then
      Continue;
    if Cnt>0 then
      PutS(',')
    else begin
      NL;
      PutS(PfxS);
      Inc(NLOfs,2);
    end ;
    NL;
    PutS(U^.Name^);
    Inc(Cnt);
    if ShowImpNames then begin
      Decl := U^.Decls;
      hImp := 0;
      while Decl<>Nil do begin
        if hImp>0 then begin
          {if (hImp mod 3)<>0 then
            PutS(', ')
          else begin
            PutS(',');
            NL;
          end ;}
          PutS(',');
          SoftNL;
         end
        else begin
          PutS(' {');
          Inc(NLOfs,2);
          NL;
        end ;
  //      PutSFmt('%s%x: %s',[Ch,NDX,ImpN^]);
  //      PutSFmt('%s%x: ',[Ch,NDX]);
        Decl.Show;
        Inc(hImp);
        Decl := Decl.Next as TBaseDef;
      end ;
      if hImp>0 then begin
        PutS('}');
        Dec(NLOfs,2);
      end ;
    end ;
  end ;
  NLOfs := NLOfs0;
  Result := Cnt>0;
  if Result then
    PutS(';');
end ;

procedure TUnit.ReadUses(TagRq: TDCURecTag);
var
  hUses,hImp,hPack: integer;
  UseName: PName;
  ImpN: PName;
  //B: Byte;
  RTTISz: Cardinal;
  L,L1: LongInt;
  Ch: Char;
  hUnit: integer;
  U: PUnitImpRec;
  TR,AR: TBaseDef;
  IR: TImpDef;
  DeclEnd: ^TBaseDef;
//  TypesEnd,AddrsEnd: ^TBaseDef;
  NDX,ImpBase,ImpBase0,ImpReBase: integer;
begin
  hUses := 0;
  ImpBase := 0;
  while Tag=TagRq do begin
    UseName := ReadName;
    {if hUses>0 then
      PutS(',')
    else begin
      PutS('uses');
      NLOfs := 2;
    end ;
    NL;
    PutS(UseName^);}
    New(U);
    FillChar(U^,SizeOf(TUnitImpRec),0);
    U^.Name := UseName;
    Ch := '?';
    case TagRq of
      drUnit1: begin Ch := 'U'; U^.Flags := [ufImpl]; end ;
      drDLL: begin Ch := 'D'; U^.Flags := [ufDLL]; end ;
    end ;
    hUnit := FUnitImp.Count;
    FUnitImp.Add(U);
    hPack := 0;
    if (TagRq<>drDLL)and(Ver>=verD8)and(Ver<verK1) then
      hPack := ReadUIndex;
    if (Ver>=verD10)and(Ver<verK1) then
      L := ReadUIndex
    else
      L := ReadULong;
    //if (Ver>=verD7)and(Ver<verK1) then begin
    if (Ver=verD7)and(Ver<verK1)or(Ver>=verD8)and(Ver<verK1)and(TagRq=drDLL) then begin
      L1 := ReadULong;
    end ;
    {TypesEnd := @U^.Types;
    AddrsEnd := @U^.Addrs;}
    DeclEnd := @U^.Decls;
    hImp := 0;
    IR := TImpDef.Create(Ch,UseName,L,Nil{DefStart},hUnit) {Unit reference};
    U^.Ref := IR;
    ImpBase0 := ImpBase;
    ImpBase := AddAddrDef(IR); //FAddrs.Add(IR);
    if hPack>0 then
      RefAddrDef(hPack); //Reserve index for unit package number
    if Ver >= verD12 then // Added by Liu Xiao for Delphi 2009
      ReadTag;
    while true do begin
      Tag := ReadTag;
      case Tag of
        drImpType,drImpTypeDef: if TagRq<>drDLL then begin
          Ch := 'T';
          ImpN := ReadName;
          if Tag=drImpTypeDef then begin
            //B := ReadByte;
            RTTISz := ReadUIndex;
            {ImpN := Format('%s[%d]',[ImpN,B]);}
          end ;
          L := LongInt(ReadULong);
          if Tag=drImpTypeDef then
            TR := TImpTypeDefRec.Create(ImpN,L,RTTISz{B},Nil{DefStart},hUnit)
          else
            TR := TImpDef.Create('T',ImpN,L,Nil{DefStart},hUnit);
          {TypesEnd^ := TR;
          TypesEnd := @TR.Next;}
          FTypes.Add(TR);
          AddAddrDef(TR); //FAddrs.Add(TR); {TypeInfo}

          ndx := FTypes.Count;
          FTypeDefCnt := ndx;
        end ;
        drImpVal: begin
          Ch := 'A';
          ImpN := ReadName;
          L := LongInt(ReadULong);
          if TagRq<>drDLL then
            AR := TImpDef.Create('A',ImpN,L,Nil{DefStart},hUnit)
          else
            AR := TDLLImpRec.Create(ImpN,L,Nil,hUnit);
          {AddrsEnd^ := AR;
          AddrsEnd := @AR.Next;}
          ndx := AddAddrDef(AR); //FAddrs.Add(AR);
          //ndx := FAddrs.Count;
          TR := AR;
        end ;
        drStop2: begin
         //Imports drConstAddInfo may be for the prev. drImpVal always
          L := -1;
          if (Ver>=verD8)and(Ver<verK1) then
            L := LongInt(ReadULong); //==IP for the imported drConstAddInfo
          Continue;
        end ;
        drConstAddInfo: begin
          if not IsMSIL then
            break;
          if hImp<>0 then
            DCUErrorFmt('ConstAddInfo encountered for %s in subrecord #%d',[UseName,hImp]);
          ImpReBase := ReadConstAddInfo(Nil); //Just skip it by now
         (* This code is not required now after detecting hPack field
          if (ImpReBase<>ImpBase) then begin
           //It looks like that Borlands now load DCUs in several passes:
           //on the one hand, they refer to some objects by their ordinal numbers in
           //FAddrs, on the other hand, the drProcAddInfo records may insert new Addrs into
           //FAddrs thus changing some ordinal numbers.
           //I hope that rebasing previous records in advance will be enough, to guess the
           //place of future insertion.
            if ImpReBase<ImpBase then
              DCUErrorFmt('Wrong import rebase %d<%d of %s',[ImpReBase,ImpBase,UseName]);
            if FAddrs.Count<ImpReBase then
              FAddrs.Count := ImpReBase;
            for NDX:=ImpBase downto ImpBase0+1 do begin
              FAddrs[NDX+ImpReBase-ImpBase-1] := FAddrs[NDX-1];
              FAddrs[NDX-1] := Nil;
            end ;
          end ;
          *)
          Continue;
        end ;
      else
        Break;
      end ;
      DeclEnd^ := TR;
      DeclEnd := @TR.Next;
      Inc(hImp);
    end ;
//    NLOfs := 2;
    if Tag<>drStop1 then
      DCUErrorFmt('Unexpected tag: 0x%x',[Byte(Tag)]);
(*    if hImp>0 then
      PutS('}');*)
    Inc(hUses);
    Tag := ReadTag;
    case Tag of
     drProcAddInfo: {The only tag by now, which was observed between imports}begin
       if not((Ver>=verD7)and(ver<verK1)) then
         break;
       hImp := ReadIndex;
       SetProcAddInfo(hImp{,Nil});
       Tag := ReadTag;
     end ;
    end ;
  end ;
end ;

{ For ver70 or higher }
function TUnit.ReadUnitAddInfo: TUnitAddInfo;
var
  Name: PName;
  CP: PChar;
begin
 (* This separate stuff is not required for D7
  if Ver=7 then begin
    Result := Nil;
   {Just skip the records of this kind}
    Name := ReadName;
    CP := SkipDataUntil(drStop1);
    {if byte(CP^)and $80<>0 then
      AddAddrDef(Nil);}
    AddAddrDef(Nil); //It takes an item in FDecls
    Exit;
  end ;
  *)
  Result := TUnitAddInfo.Create;
end ;

procedure ChkListSize(L: TList; hDef: integer);
begin
  if hDef<=0 then
    Exit;
  if hDef>L.Count then begin
    if hDef>L.Capacity then
      L.Capacity := (hDef*3)div 2;
    L.Count := hDef;
  end ;
end ;

procedure TUnit.SetListDefName(L: TList; hDef: integer; Name: PName);
var
  Def: TBaseDef;
begin
  if L=Nil then
    Exit;
  if hDef<=0 then
    Exit;
  ChkListSize(L,hDef);
  Dec(hDef);
  Def := L[hDef];
  if Def=Nil then begin
    Def := TBaseDef.Create(Name,Nil,-1);
//    Def.Next := FDefs;
//    FDefs := Def;
    L[hDef] := Def;
    Exit;
  end ;
  if (Def.FName=Nil) then
    Def.FName := Name;
end ;

procedure TUnit.AddTypeName(hDef: integer; Name: PName);
begin
  SetListDefName(FTypes,hDef,Name);
end ;

procedure TUnit.AddTypeDef(TD: TTypeDef);
var
  Def: TBaseDef;
begin
  ChkListSize(FTypes,FTypeDefCnt+1);
  Def := FTypes[FTypeDefCnt];
  if Def<>Nil then begin
    if (Def.Def<>Nil) then
      DCUErrorFmt('Type def #%x override',[FTypeDefCnt+1]);
    if (Def.hUnit<>TD.hUnit) then
      DCUErrorFmt('Type def #%x unit mismatch',[FTypeDefCnt+1]);
    TD.FName := Def.Name;
    Def.FName := Nil;
    Def.Free;
  end ;
  FTypes[FTypeDefCnt] := TD;
  Inc(FTypeDefCnt);
end ;

procedure TUnit.ClearLastTypeDef(TD: TTypeDef);
//This procedure is called from TTypeDef.Destroy, and required when
//Destroy is called due to errors in Create
begin
  if FLoaded or(FTypeDefCnt<=0) then
    Exit;
  if FTypes[FTypeDefCnt-1]=TD then
    FTypes[FTypeDefCnt-1] := Nil;
    //Dec(FTypeDefCnt);
end ;

procedure TUnit.ClearAddrDef(ND: TNameDecl);
var
  hDecl: integer;
begin
  if FLoaded then
    Exit;
  if FAddrs=Nil then
    Exit;
  hDecl := ND.hDecl-1;
  if (hDecl<0)or(hDecl>=FAddrs.Count) then
    Exit;
  if FAddrs[hDecl]=ND then
    FAddrs[hDecl] := Nil;
end ;

{
procedure TUnit.AddAddrName(hDef: integer; Name: PName);
begin
  SetListDefName(FAddrs,hDef,Name);
end ;
}
function TUnit.AddAddrDef(ND: TDCURec): integer;
begin
  if (FhNextAddr>0) then begin
    Result := FhNextAddr;
    if Result>FAddrs.Count then
      DCUErrorFmt('ProcAddInfo Value 0x%x>FAddrs.Count=0x%x',[Result,FAddrs.Count]);
    if FAddrs[Result-1]<>Nil then
      DCUErrorFmt('FAddrs[0x%x] already used',[Result]);
    FAddrs[Result-1] := ND;
    Inc(FhNextAddr); //Just in case: all the observed samples contained
      //insertion of a single address only
    Exit;
  end ;
  FAddrs.Add(ND);
  Result := FAddrs.Count;
end ;

procedure TUnit.RefAddrDef(V: integer);
{This procedure is used for addrs, which may be forward references to the objects,
which don't yet exist. To fill the empty slot the drProcAddInfo tag is used after
creation of the object. }
var
  MissingRefs : integer;
begin
  if V>FAddrs.Count then begin
    MissingRefs := V - FAddrs.Count;
    while MissingRefs > 0 do begin
      Dec(MissingRefs);
      FAddrs.Add(Nil); //This way it won't interfere with FhNextAddr
      {AddAddrDef(Nil);} //Reserve addr index, which will be claimed by drProcAddInfo
    end;
  end ;
end ;

procedure TUnit.SetDeclMem(hDef: integer; Ofs,Sz: Cardinal);
var
  D: TDCURec;
  Base,Rest: Cardinal;
begin
  if (hDef<=0)or(hDef>FAddrs.Count) then
    DCUErrorFmt('Undefined Fixup Declaration: #%x',[hDef]);
  D := FAddrs[hDef-1];
  Base := 0;
  while (D<>Nil) do begin
    if D is TProcDecl then
      TProcDecl(D).AddrBase := Base;
    Rest := D.SetMem(Ofs+Base,Sz-Base);
    if integer(Rest)<=0 then
      Break;
    Base := Sz-Rest;
    D := D.Next {Next declaration - should be procedure};
  end ;
end ;

function TUnit.GetTypeDef(hDef: integer): TTypeDef;
begin
  Result := Nil;
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  Result := FTypes[hDef-1];
end ;

function TUnit.GetTypeName(hDef: integer): PName;
var
  D: TTypeDef;
begin
  Result := Nil;
  D := GetTypeDef(hDef);
  if D=Nil then
    Exit;
  Result := D.FName;
end ;

function TUnit.GetAddrDef(hDef: integer): TDCURec;
begin
  if (hDef<=0)or(hDef>FAddrs.Count) then
    Result := Nil
  else
    Result := FAddrs[hDef-1];
end ;

function TUnit.GetAddrName(hDef: integer): PName;
var
  D: TDCURec;
begin
  Result := @NoName;
  D := GetAddrDef(hDef);
  if D=Nil then
    Exit;
  Result := D.Name;
end ;

function TUnit.GetAddrStr(hDef: integer; ShowNDX: boolean): String;
begin
  Result := GetDCURecStr(GetAddrDef(hDef), hDef,ShowNDX);
end ;

function TUnit.GetGlobalTypeDef(hDef: integer; var U: TUnit): TTypeDef;
var
  D: TBaseDef;
  hUnit: integer;
  N: PName;
begin
  Result := Nil;
  U := Self;
  D := GetTypeDef(hDef);
  repeat
    if D=Nil then
      Exit;
    if (D is TTypeDef) then
      Break {Found - Ok};
    if not (D is TImpDef) then
      Exit;
    if (D is TImpTypeDefRec) then begin
      hUnit := TImpTypeDefRec(D).hImpUnit;
      N := TImpTypeDefRec(D).ImpName;
     end
    else begin
      hUnit := TImpDef(D).hUnit;
      N := TImpDef(D).Name;
    end ;
    {imported value}
    U := U.GetUnitImp(hUnit);
    if U=Nil then begin
      U := Self;
      Exit;
    end ;
    D := U.ExportTypes[N^,TImpDef(D).Inf];
  until false;
  Result := TTypeDef(D);
end ;

function TUnit.GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
var
  D: TDCURec;
begin
  Result := Nil;
  U := Self;
  D := GetAddrDef(hDef);
  if D=Nil then
    Exit;
  if (D is TImpDef) then begin
    {imported value}
    U := GetUnitImp(TImpDef(D).hUnit);
    if U=Nil then begin
      U := Self;
      Exit;
    end ;
    D := U.ExportDecls[TImpDef(D).Name^,TImpDef(D).Inf];
  end ;
  Result := D;
end ;

function TUnit.GetTypeSize(hDef: integer): integer;
var
  T: TTypeDef;
  U: TUnit;
begin
  Result := -1;
  T := GetGlobalTypeDef(hDef,U);
  if T=Nil then
    Exit;
  Result := T.Sz;
end ;

function TUnit.ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal;
  IsConst: boolean): integer {Size used};
var
  U0: TUnit;
  MS: TFixupMemState;
begin
  if T=Nil then begin
    Result := -1;
    Exit;
  end ;
  U0 := CurUnit;
  CurUnit := Self;
  if IsConst then begin
    SaveFixupMemState(MS);
    SetCodeRange(DP,DP,DS);
  end ;
  if IsConst and (T is TStringDef) then
    Result := TStringDef(T).ShowStrConst(DP,DS)
  else
    Result := T.ShowValue(DP,DS);
  if IsConst then
    RestoreFixupMemState(MS);
  CurUnit := U0;
end ;

function TUnit.ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal;
  AndRest,IsConst: boolean): integer {Size used};
var
  T: TTypeDef;
  U: TUnit;
  SzShown: integer;
  FOfs0: PChar;
begin
  if DP=Nil then begin
    Result := -1;
    Exit;
  end ;
  T := GetGlobalTypeDef(hDef,U);
  Result := U.ShowTypeValue(T,DP,DS,IsConst);
  if not AndRest then
    Exit;
  SzShown := Result;
  if SzShown<0 then
    SzShown := 0;
  if SzShown>=DS then
    Exit;
  if (PChar(DP)>=FDataBlPtr)and(PChar(DP)<FDataBlPtr+FDataBlSize) then
    CurUnit.ShowDataBl(SzShown,PChar(DP)-FDataBlPtr,DS)
  else begin
    NL;
    FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;
    ShowDump(DP,FOfs0,FMemSize,0,DS,SzShown,SzShown,0,0,Nil,false);
  end ;
end ;

function TUnit.ShowGlobalConstValue(hDef: integer): boolean;
var
  D: TDCURec;
  U,U0: TUnit;
begin
  Result := false;
  D := GetGlobalAddrDef(hDef,U);
  if (D=Nil)or not(D is TConstDecl) then
    Exit;
  U0 := CurUnit;
  CurUnit := U;
  TConstDecl(D).ShowValue;
  CurUnit := U0;
  Result := true;
end ;

function TUnit.GetOfsQualifier(hDef: integer; Ofs: integer): String;
var
  U,U0: TUnit;
  TD: TTypeDef;
begin
  Result := '';
  {if Ofs=0 then
    Exit; Let it will show the 1st field too}
  TD := GetGlobalTypeDef(hDef,U);
  if TD=Nil then begin
    if Ofs>0 then
      Result := Format('+%d',[Ofs])
    else if Ofs<0 then
      Result := Format('%d',[Ofs]);
    Exit;
  end ;
  U0 := CurUnit;
  CurUnit := U;
  Result := TD.GetOfsQualifier(Ofs);
  CurUnit := U0;
end ;

function TUnit.GetRefOfsQualifier(hDef: integer; Ofs: integer): String;
var
  U,U0: TUnit;
  TD: TTypeDef;
begin
  Result := '';
  {if Ofs=0 then
    Exit;}
  TD := GetGlobalTypeDef(hDef,U);
  if TD=Nil then begin
    if Ofs>0 then
      Result := Format('^+%d',[Ofs])
    else if Ofs<0 then
      Result := Format('^%d',[Ofs]);
    Exit;
  end ;
  U0 := CurUnit;
  CurUnit := U;
  Result := TD.GetRefOfsQualifier(Ofs);
  CurUnit := U0;
end ;


procedure TUnit.ShowTypeDef(hDef: integer; N: PName);
var
  D: TBaseDef;
begin
  Inc(AuxLevel);
  PutSFmt('{T#%x}',[hDef]);
  Dec(AuxLevel);
  D := GetTypeDef(hDef);
  if D=Nil  then begin
    PutS('?');
    Exit;
  end ;
  D.ShowNamed(N);
end ;

function TUnit.ShowTypeName(hDef: integer): boolean;
var
  D: TBaseDef;
  N: PName;
begin
  Result := false;
  Inc(AuxLevel);
  PutSFmt('{T#%x}',[hDef]);
  Dec(AuxLevel);
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  D := FTypes[hDef-1];
  if D=Nil  then
    Exit;
  N := D.FName;
  if (N=Nil)or(N^[0]=#0) then
    Exit;
  D.ShowName;
  Result := true;
end ;

function TUnit.TypeIsVoid(hDef: integer): boolean;
var
  D: TBaseDef;
begin
  Result := true;
  if (hDef<=0)or(hDef>FTypes.Count) then
    Exit;
  D := FTypes[hDef-1];
  if D=Nil  then
    Exit;
  Result := D.ClassType=TVoidDef;
end ;

function TUnit.GetUnitImpRec(hUnit: integer): PUnitImpRec;
begin
  Result := PUnitImpRec(FUnitImp[hUnit]);
end ;

function TUnit.GetUnitImp(hUnit: integer): TUnit;
var
  UI: PUnitImpRec;
begin
  UI := GetUnitImpRec(hUnit);
  if UI=Nil then begin
    Result := Nil;
    Exit;
  end ;
  Result := UI^.U;
  if Result<>Nil then begin
    if integer(Result)=-1 then
      Result := Nil;
    Exit;
  end ;
  Result := GetDCUByName(UI^.Name^,FFExt,Ver,FIsMSIL,UI^.Ref.Inf);
  if Result=Nil then
    integer(UI^.U) := -1
  else
    UI^.U := Result;
end ;

procedure TUnit.SetExportNames(Decl: TNameDecl);
var
  NDX: integer;
begin
  FExportNames := TStringList.Create;
  FExportNames.Sorted := true;
  FExportNames.Duplicates := dupAccept{For overloaded functions} {dupError};
  while Decl<>Nil do begin
    if (Decl is TNameFDecl)and Decl.IsVisible(dlMain) then begin
//      if not FExportNames.Find(Decl.Name^,NDX) then
        FExportNames.AddObject(Decl.Name^,Decl);
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
end ;

procedure TUnit.SetEnumConsts(var Decl: TNameDecl);
var
  LastConst: TConstDecl;
  ConstCnt: integer;
  D: TNameDecl;
  DeclP,LastConstP: ^TNameDecl;
  TD: TTypeDef;
  Enum: TEnumDef;
  CP0: TScanState;
  Lo,Hi: integer;
  NT: TList;
begin
  DeclP := @Decl;
  LastConstP := Nil;
  LastConst := Nil;
  ConstCnt := 0;
  while DeclP^<>Nil do begin
    D := DeclP^;
    if D is TConstDecl then begin
      if (LastConst<>Nil)and(LastConst.hDT=TConstDecl(D).hDT) then
        Inc(ConstCnt)
      else begin
        LastConstP := DeclP;
        LastConst := TConstDecl(D);
        ConstCnt := 1;
      end ;
     end
    else begin
      if (D is TTypeDecl)and(LastConst<>Nil) then begin
        TD := GetTypeDef(TTypeDecl(D).hDef);
        if {(TD<>Nil)and}(TD is TEnumDef) then begin
          Enum := TEnumDef(TD);
         {Some paranoic tests:}
          ChangeScanState(CP0,Enum.LH,18);
          Lo := ReadIndex;
          Hi := ReadIndex;
          RestoreScanState(CP0);
          if (Lo=0)and(ConstCnt=Hi+1) then begin
            NT := TList.Create;
            NT.Capacity := ConstCnt;
            LastConstP^ := D;
            DeclP^ := Nil;
            while LastConst<>Nil do begin
              NT.Add(LastConst);
              LastConst := TConstDecl(LastConst.Next);
            end ;
            Enum.NameTbl := NT;
          end ;
        end ;
      end ;
      LastConst := Nil;
      ConstCnt := 0;
    end ;
    DeclP := @(D.Next);
  end ;
end ;

function TUnit.GetExportDecl(Name: String; Stamp: integer): TNameFDecl;
var
  NDX: integer;
begin
  Result := Nil;
  if FExportNames=Nil then
    Exit;
  if not FExportNames.Find(Name,NDX) then
    Exit;
 //Find should return the 1st occurence of Name
 //now it is reqired to find the name by Stamp
  repeat
    Result := FExportNames.Objects[NDX] as TNameFDecl;
    if Stamp=0 {The don't check Stamp value} then
      Exit;
    if (Result=Nil) then
      Exit;
    if (CompareText(FExportNames[NDX],Name)<>0) then begin
      Result := Nil;
      Exit;
    end ;
    if Result.Inf=Stamp then
      Break;
    Inc(NDX);
    if NDX>=FExportNames.Count then begin
      Result := Nil;
      Exit;
    end ;
  until false;
end ;

function TUnit.GetExportType(Name: String; Stamp: integer): TTypeDef;
var
  ND: TNameDecl;
begin
  Result := Nil;
  ND := ExportDecls[Name,Stamp];
  if (ND=Nil)or not(ND is TTypeDecl) then
    Exit;
  Result := GetTypeDef(TTypeDecl(ND).hDef);
end ;

procedure TUnit.LoadFixups;
var
  i: integer;
  CurOfs,PrevDeclOfs,dOfs: Cardinal;
  B1: Byte;
  FP: PFixupRec;
  hPrevDecl: integer;
begin
  if FFixupTbl<>Nil then
    DCUError('2nd fixup');
  FFixupCnt := ReadUIndex;
  FFixupTbl := AllocMem(FFixupCnt*SizeOf(TFixupRec));
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  for i:=0 to FFixupCnt-1 do begin
    dOfs := ReadUIndex;
    Inc(CurOfs,dOfs);
    if (NDXHi<>0)or(CurOfs>FDataBlSize) then
      DCUErrorFmt('Fixup offset 0x%x>Block size = 0x%x',[CurOfs,FDataBlSize]);
    B1 := ReadByte;
    FP^.OfsF := (CurOfs and FixOfsMask)or(B1 shl 24);
    FP^.NDX := ReadUIndex;
    Inc(FP);
  end ;
 {After loading fixups set the memory sizes of CBlock parts} 
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  hPrevDecl := 0;
  PrevDeclOfs := 0;
  for i:=0 to FFixupCnt-1 do begin
    CurOfs := FP^.OfsF and FixOfsMask;
    B1 := TByte4(FP^.OfsF)[3];
    if (B1=fxStart)or(B1=fxEnd) then begin
      if hPrevDecl>0 then
        CurUnit.SetDeclMem(hPrevDecl,PrevDeclOfs,CurOfs-PrevDeclOfs);
      hPrevDecl := FP^.NDX;
      PrevDeclOfs := CurOfs;
      FDataBlOfs := CurOfs;
    end ;
    Inc(FP);
  end ;
end ;

procedure TUnit.LoadCodeLines;
var
  i,CurL,dL: integer;
  CR: PCodeLineRec;
  CurOfs,dOfs: Cardinal;
begin
  if FCodeLineTbl<>Nil then
    DCUError('2nd Code Lines table');
  FCodeLineCnt := ReadUIndex;
  FCodeLineTbl := AllocMem(FCodeLineCnt*SizeOf(TCodeLineRec));
  CurL := 0;
  CurOfs := 0;
  CR := Pointer(FCodeLineTbl);
  for i:=0 to FCodeLineCnt-1 do begin
    dL := ReadIndex;
    dOfs := ReadUIndex;
    Inc(CurOfs,dOfs);
    Inc(CurL,dL);
    if (NDXHi<>0)or(CurOfs>FDataBlSize) then
      DCUErrorFmt('Code line offset 0x%x>Block size = 0x%x',[CurOfs,FDataBlSize]);
    CR^.Ofs := CurOfs;
    CR^.L := CurL;
    Inc(CR);
  end ;
end ;

function TUnit.GetSrcFile(N: integer): PSrcFileRec;
begin
  Result := FSrcFiles;
  while (N>0)and(Result<>Nil) do begin
    Result := Result^.Next;
    Dec(N);
  end ;
end ;

procedure TUnit.LoadLineRanges;
var
  i: integer;
  LR: PLineRangeRec;
  hFile,Num: integer;
begin
  if FLineRangeTbl<>Nil then
    DCUError('2nd Line Ranges table');
  FLineRangeCnt := ReadUIndex;
  if FLineRangeCnt > (HIGH(Cardinal) div 256) then
    Exit;  // FLineRangeCnt way to high and probably incorrect, better to Exit right now...
  FLineRangeTbl := AllocMem(FLineRangeCnt*SizeOf(TLineRangeRec));
  LR := Pointer(FLineRangeTbl);
  Num := 0;
  for i:=0 to FLineRangeCnt-1 do begin
    LR^.Line0 := ReadUIndex;
    LR^.LineNum := ReadUIndex;
    LR^.Num0 := Num;
    Inc(Num,LR^.LineNum);
    hFile := ReadUIndex;
    LR^.SrcF := GetSrcFile(hFile);
    if (LR^.SrcF=Nil) then
      DCUErrorFmt('Source file number %d is out of range',[hFile]);
    Inc(LR);
  end ;
end ;

procedure TUnit.LoadStrucScope;
{In fact just skip them by now}
var
  Cnt,i: integer;
begin
  Cnt := ReadUIndex;
  for i:=1 to Cnt*5 do
    ReadUIndex; {(hType,hVar,Ofs,LnStart,LnCnt}
end ;

procedure TUnit.LoadSymbolInfo;
{In fact just skip it by now}
var
  Cnt,NPrimary,i,j: integer;
  hSym,
  hMember, //for symbols - type members, else - 0
  Sz,
  hDef: integer;//index of symbol definition in the L array
begin
  Cnt := ReadUIndex;
  NPrimary := ReadUIndex;
  for i:=1 to Cnt do begin
    hSym := ReadUIndex;
    hMember := ReadUIndex;
    Sz := ReadUIndex;
    hDef := ReadUIndex;
    for j:=1 to Sz do
      ReadUIndex;
  end ;
end ;

procedure TUnit.LoadLocVarTbl;
var
  i: integer;
  LR: PLocVarRec;
begin
  if FLocVarTbl<>Nil then
    DCUError('2nd Local Vars table');
  FLocVarCnt := ReadUIndex;
  FLocVarTbl := AllocMem(FLocVarCnt*SizeOf(TLocVarRec));
  LR := Pointer(FLocVarTbl);
  for i:=0 to FLocVarCnt-1 do begin
    LR^.sym := ReadUIndex;
    LR^.ofs := ReadUIndex;
    LR^.frame := ReadIndex;
    Inc(LR);
  end ;
end ;

function TUnit.GetStartFixup(Ofs: Cardinal): integer;
var
  i,iMin,iMax: integer;
  d: integer;
begin
  Result := 0;
  if (FFixupTbl=Nil)or(FFixupCnt=0) then
    Exit;
  if Ofs=0 then
    Exit;
  iMin := 0;
  iMax := FFixupCnt-1;
  while iMin<=iMax do begin
    i := (iMin+iMax)div 2;
    D := FFixupTbl^[i].OfsF and FixOfsMask-Ofs;
    if D<0 then
      iMin := i+1
    else
      iMax := i-1;
  end ;
  Result := iMin;
end ;
{
  iMin := 0;
  iMax := FFixupCnt;
  while iMin<iMax do begin
    Result := (iMin+iMax)div 2;
    D := FFixupTbl^[Result].OfsF and FixOfsMask-Ofs;
    if D=0 then
      Break;
    if D<0 then
      iMin := Result+1
    else
      iMax := Result;
  end ;
  while (Result>0)and(FFixupTbl^[Result-1].OfsF and FixOfsMask = Ofs) do
    Dec(Result);
}
function TUnit.GetNextFixup(iStart: integer; Ofs: Cardinal): integer;
begin
  while iStart<FFixupCnt do begin
    if FFixupTbl^[iStart].OfsF and FixOfsMask >= Ofs then begin
      Result := iStart;
      Exit;
    end ;
    Inc(iStart);
  end ;
  Result := FFixupCnt;
end ;

procedure TUnit.SetStartFixupInfo(Fix0: integer);
begin
  SetFixupInfo(FFixupCnt-Fix0,@FFixupTbl^[Fix0],Self);
end ;

function TUnit.GetStartCodeLine(Ofs: integer): integer;
var
  d,i,iMin,iMax: integer;
begin
  Result := FCodeLineCnt; //Not found
  iMin := 0;
  iMax := FCodeLineCnt-1;
  while iMin<=iMax do begin
    i := (iMin+iMax) div 2;
    d := Ofs-FCodeLineTbl^[i].Ofs;
    if d>0 then
      iMin := i+1
    else begin
      Result := i;
      if D=0 then
        Break;
      iMax := i-1;
    end ;
  end ;
end ;

procedure TUnit.GetCodeLineRec(i: integer; var CL: TCodeLineRec);
begin
  if i>=FCodeLineCnt then begin
    CL.Ofs := MaxInt;
    CL.L := MaxInt;
    Exit;
  end ;
  CL := FCodeLineTbl^[i];
end ;

function TUnit.GetStartLineRange(L: integer): integer;
var
  d,iMin,iMax: integer;
begin
  Result := 0;
  iMin := 0;
  iMax := FLineRangeCnt;
  while iMin<iMax do begin
    Result := (iMin+iMax) div 2;
    with FLineRangeTbl^[Result] do
      if Num0+LineNum<L then
        iMin := Result+1
      else if Num0>=L then
        iMax := Result
      else
        Break;
  end ;
end ;

procedure TUnit.GetLineRange(i: integer; var LR: TLineRangeRec);
begin
  if i>=FLineRangeCnt then begin
    LR.Num0 := MaxInt;
    LR.LineNum := MaxInt;
    LR.SrcF := Nil;
    Exit;
  end ;
  LR := FLineRangeTbl^[i];
  if (LR.SrcF<>Nil)and(LR.SrcF^.Lines=Nil) then begin
    LR.SrcF^.Lines := TStringList.Create;
    LoadSourceLines(LR.SrcF^.Def^.Name,LR.SrcF^.Lines);
  end ;
end ;

function TUnit.ReadConstAddInfo(LastProcDecl: TNameDecl): integer;
var
  Tag,caiStop: byte;
  hDef,hDef1,hDef2,hDef3,hDef4,hDef5,hDT,F,IP,i,j: integer;
  V1,V2,V3,V4,V5: integer;
  Len,Len1,V,hUnit: Cardinal;
  hDef11,hDef12,hDef13,hDef14,hDef15: integer;
  S: String;
begin
  Result := -1;
  if (Ver<=VerD7)or(Ver>=verK1) then begin
    ReadByte; //01
    ReadUIndex;
    ReadByte; //02
    ReadByte; //06
    Exit;
  end ;
  caiStop := $0D;
  if Ver>=verD9 then
    caiStop := $0F;
  repeat
    Tag := ReadByte;
    case Tag of
     $01: begin
       Result := ReadUIndex;
       F := ReadUIndex;
       if IsMSIL then begin
         Len := ReadUIndex;
         for i:=1 to Len do begin
           hDef := ReadUIndex;
           RefAddrDef(hDef);
           V := ReadUIndex;
           S := ReadNDXStr;
           if S<>'' then begin
             Len1 := ReadUIndex;
             for j:=1 to Len1 do begin
               hDef1 := ReadUIndex;
               RefAddrDef(hDef1); //Seems that it's required to reserve addr index
              // AddAddrDef(Nil);
             end ;
           end ;
         end ;
       end ;
       if F and $80000<>0 then begin
         //Very complex structure - corresponds to the new (Ver>=8) inline directive
         //Fortunately, we can completely ignore all this info, because it is duplicated
         //as a regular procedure info even for inlines
         if (Ver>=verD10)and(Ver<verK1) then begin
           ReadUIndex;
           ReadUIndex;
         end ;
         Len := ReadUIndex;
         SkipBlock(Len*SizeOf(Byte));
         for i:=1 to 5 do
           ReadUIndex;
         V := ReadUIndex;
         {if V<>2 then
           DCUError('V2<>2 in TConstAddInfoRec,Tag=1');}
         Len := ReadUIndex;
         for i:=1 to Len do begin
           V := ReadUIndex;
           {if V<>0 then
             DCUError('Z<>0 in TConstAddInfoRec,Tag=1,D1');}
           V := ReadUIndex;
           RefAddrDef(V); //Seems that it's required to reserve addr index
           V := ReadUIndex;
           {if V<>0 then
             DCUError('Z1<>0 in TConstAddInfoRec,Tag=1,D1');}
         end ;
         Len := ReadUIndex;
         for i:=1 to Len do begin
           V := ReadUIndex;
           {if V<>4 then
             DCUError('V4<>4 in TConstAddInfoRec,Tag=1,D2');}
           V := ReadUIndex;
         end ;
         Len := ReadUIndex; //Number of units defs from which are used in this def
         for i:=1 to Len do begin
           hUnit := ReadUIndex;
           Len1 := ReadUIndex;
           for j:=1 to Len1 do begin
             V := ReadUIndex;
             if hUnit<>0 then
               Continue; //Import from another unit - don't care
             RefAddrDef(V);
           end ;
         end ;
       end ;
       if F and $100000<>0 then begin
         if (Ver>=verD10)and(Ver<verK1) then begin
           Len := ReadUIndex;
           for i:=1 to Len do
             V := ReadUIndex;
         end ;
         IP := ReadUIndex;
       end ;
       if (Ver>=verD10)and(Ver<verK1) then begin
         if F and $1000000<>0 then
           IP := ReadUIndex;
       end ;
      end ;
     $04: begin
       if not((Ver>=verD10)and(Ver<verK1)) then
         break;
       V := ReadUindex;
       V := ReadUindex;
      end ;
     $06: begin
       Result := ReadUindex;
       hDT := ReadUindex;
       V := ReadUindex;
       hDef1 := ReadUindex;
      end ;
     $07: begin
       Result := ReadUindex;
       hDef1 := ReadUindex;
       hDef2 := ReadUindex;
       V := ReadUindex;
      end ;
     $09: begin
       Result := ReadUindex;
       hDT := ReadUindex;
      end ;
     $0A: begin
       Result := ReadUIndex;
       V := ReadUIndex;
       F := ReadUIndex;
       hDT := 0;
       if F and $01<>0 then
         hDT := ReadUIndex;
       hDef1 := 0;
       if F and $02<>0 then
         hDef1 := ReadUIndex;
       V2 := 0;
       if F and $04<>0 then
         V2 := ReadUIndex;
       V3 := 0;
       if F and $08<>0 then
         V3 := ReadUIndex;
       V4 := 0;
       if F and $10<>0 then
         V4 := ReadUIndex;
       hDef5 := 0;
       if F and $20<>0 then
         hDef5 := ReadUIndex;
       if F and $40<>0 then begin
         Len := ReadUIndex;
         for i:=1 to Len do begin
           S := ReadNDXStr;
           V := ReadUIndex;
           V1 := ReadUIndex;
           hDT := ReadUIndex;
         end ;
       end ;
       if F and $80<>0 then begin
         V := ReadUIndex;
         V1 := ReadUIndex;
         V2 := ReadUIndex;
       end ;
       if F and $100<>0 then
         S := ReadNDXStr;
       if F and $200<>0 then
         S := ReadNDXStr;
       hDef11 := 0;
       if F and $400<>0 then begin
         hDef11 := ReadUIndex;
         if IsMSIL then
           //AddAddrDef(Nil);
           RefAddrDef(hDef11);
       end ;
       hDef12 := 0;
       if F and $800<>0 then begin
         hDef12 := ReadUIndex;
         if IsMSIL then
           RefAddrDef(hDef12);
       end ;
       hDef13 := 0;
       if F and $1000<>0 then begin
         hDef13 := ReadUIndex;
         if IsMSIL then
           RefAddrDef(hDef13);
       end ;
       hDef14 := 0;
       if F and $2000<>0 then begin
         hDef14 := ReadUIndex;
         if IsMSIL then
           RefAddrDef(hDef14);
       end ;
       hDef15 := 0;
       if F and $4000<>0 then begin
         hDef15 := ReadUIndex; //MSIL 9 only?
         if IsMSIL then
           RefAddrDef(hDef15);
       end ;
      end ;
     $0C: begin
       Result := ReadUIndex;
       V1 := ReadUIndex;
       V2 := ReadUIndex;
      end ;
     $0D: begin
       if (Ver<9)or(Ver>=verK1) then
         Exit;
      //imported unit module information (FileName and version)?
       Result := ReadUIndex;
       S := ReadNDXStr;
      // AddAddrDef(Nil); //Seems that it's required to reserve addr index
      end ;
    else
      if Tag=caiStop then
        Exit;
      break;
    end ;
  until false;
  DCUErrorFmt('Unexpected Tag=0x%x in TConstAddInfoRec',[Tag]);
end ;

procedure TUnit.SetProcAddInfo(V: integer{; LastProcDecl: TNameDecl});
begin
  if (V=-1{(B=$FE)}) then begin
    FhNextAddr := 0;
    {FAddrs[0] := LastProcDecl;
    FAddrs.Count := FAddrs.Count-1; //Initialization}
  end ;
  if (V>=1)and(Ver>=verD7) then begin
    {if V>FAddrs.Count then
      DCUErrorFmt('ProcAddInfo Value 0x%x>FAddrs.Count=0x%x',[V,FAddrs.Count]);
    if FAddrs[V-1]<>Nil then
      DCUErrorFmt('FAddrs[0x%x] already used',[V]);}
    FhNextAddr := V;
  end ;
end ;


function TUnit.FixTag(Tag: TDCURecTag): TDCURecTag;
begin
  Result := Tag;
  if (Ver>=verD10)and(Ver<verK1) then begin
   //In D10 some codes were changed, we'll try to move them back
    if (Result>=$2D)and(Result<=$36) then begin
      Dec(Result);
      if Result<$2D then
        Result := $36; //This code could be wrong, but the overloaded value of $2D should be moved somewhere
    end ;
  end ;
end ;

procedure TUnit.ReadDeclList(LK: TDeclListKind; var Result: TNameDecl);
var
  DeclEnd: ^TNameDecl;
  Decl,LastProcDecl: TNameDecl;
  Embedded: TNameDecl;
  B: Byte;
  i,V: integer;
  Tag1: TDCURecTag;
  WasEmbEnd: boolean;
begin
  Result := Nil;
  DeclEnd := @Result;
  Embedded := Nil;
  LastProcDecl := Nil;
  FhNextAddr := 0;
  WasEmbEnd := false; //For MSIL only
  while true do begin
    Tag1 := FixTag(Tag);
    Decl := Nil;
    try
      case Tag1 of
        drType: Decl := TTypeDecl.Create;
        drTypeP: Decl := TTypePDecl.Create;
        drConst: Decl := TConstDecl.Create;
        drResStr: Decl := TResStrDef.Create;
        drSysProc: if (Ver>=verD8)and(Ver<verK1) then
           Decl := TSysProc8Decl.Create
         else
           Decl := TSysProcDecl.Create;
        drProc: begin
            Decl := TProcDecl.Create(Embedded,false);
            LastProcDecl := Decl;
            Embedded := Nil;
          end ;
        drEmbeddedProcStart: begin
            if IsMSIL and WasEmbEnd then
              WasEmbEnd := false //Just ignore and continue
            else begin
              if Embedded<>Nil then begin
              // Below 2 lines are Commentted by Liu Xiao to prevent duplicated
              // error when meet 2 consts in resourcestring. Reported by Michel Terrisse
              //  if not IsMSIL then
              //    TagError('Duplicate embedded list');
                //MSIL code contains brackets drEmbeddedProcEnd - drEmbeddedProcStart
                //perhaps to denote one level upper scope. We handle this kind of brackets
                //by WasEmbEnd in dlArgs and by joining Embedded lists here
                Tag := ReadTag;
                ReadDeclList(dlEmbedded,TNameDecl(GetDCURecListEnd(Embedded)^));
               end
              else begin
                Tag := ReadTag;
                ReadDeclList(dlEmbedded,Embedded);
              end ;
              if Tag<>drEmbeddedProcEnd then
                TagError('Embedded Stop Tag');
             {In DCU 6 for resourcestring declarations inside procs
              here follows the constant value instead of drProc
              Tag := ReadTag;
              if Tag<>drProc then
                TagError('Proc Tag');
              Decl := TProcDecl.Create(Embedded);}
            end ;
          end ;
        drVar: case LK of
          dlArgs,dlArgsT: Decl := TLocalDecl.Create(LK);
        else
          Decl := TVarDecl.Create;
        end ;
        drThreadVar: Decl := TThreadVarDecl.Create;
        drExport: Decl := TExportDecl.Create;
        drVarC: Decl := TVarCDecl.Create(false{LK=dlMain});
        arVal, arVar, arResult, arFld:
          Decl := TLocalDecl.Create(LK);
        arAbsLocVar: case LK of
          dlMain,dlMainImpl: Decl := TAbsVarDecl.Create;
        else
          Decl := TLocalDecl.Create(LK);
        end ;
        arLabel: Decl := TLabelDecl.Create;
        arMethod, arConstr, arDestr:
          Decl := TMethodDecl.Create(LK);
        arClassVar: begin
          if not((Ver>=verD10)and(Ver<verK1)) then
            break;
          Decl := TClassVarDecl.Create(LK);
         end ;
        arProperty:
          if LK=dlDispInterface then
            Decl := TDispPropDecl.Create(LK)
          else
            Decl := TPropDecl.Create;
        arCDecl,arPascal,arStdCall,arSafeCall: {Skip it};
        arSetDeft: Decl := TSetDeftInfo.Create;//ReadULong{Skip it};
        drStop2: begin
          if (Ver>=verD8)and(Ver<verK1) then
            ReadULong;
         end ;
//        drVoid: Decl := TAtDecl.Create;{May be end of interface}
        drStrConstRec: begin
          if not((Ver>=verD8)and(Ver<verK1)) then
            break;
          {TStrConstTypeDef.Create;}
          Decl := TStrConstDecl.Create;
         {//?? надо регистрировать ?таблиц?адресо?
          ReadStr;
          ReadUIndex;
          ReadUIndex;
          ReadUIndex;
          ReadUIndex;}
         end ;
       {drAddInfo6: begin //Some structures of 4 indices
         if not((Ver>=verD10)and(Ver<verK1)) then
           break;
         Decl := TAddInfo6.Create;
        end ;}
       drSpecVar: begin //Memory allocation for class vars and so on
         if not((Ver>=verD10)and(Ver<verK1)) then
           break;
         Decl := TSpecVar.Create;
        end ;

       {--------- Type definitions ---------}
      drRangeDef,drChRangeDef,drBoolRangeDef,drWCharRangeDef,
      drWideRangeDef: TRangeDef.Create;
      drEnumDef: TEnumDef.Create;
      drFloatDef: TFloatDef.Create;
      drPtrDef: TPtrDef.Create;
      drTextDef: TTextDef.Create;
      drFileDef: TFileDef.Create;
      drSetDef: TSetDef.Create;
      drShortStrDef: TShortStrDef.Create(true{IsStr});
      drStringDef,drWideStrDef: TStringDef.Create(true{IsStr});
      drArrayDef: TArrayDef.Create(false{IsStr});
      drVariantDef: TVariantDef.Create;
      drObjVMTDef: TObjVMTDef.Create;
      drRecDef: TRecDef.Create;
      drProcTypeDef: TProcTypeDef.Create;
      drObjDef: TObjDef.Create;
      drClassDef: TClassDef.Create;
      drMetaClassDef: begin
        if not((Ver>=verD8)and(Ver<verK1)) then
          break;
        TMetaClassDef.Create;
       end ;
      drInterfaceDef: TInterfaceDef.Create;
      drVoid: TVoidDef.Create;{May be end of interface}
      drCBlock: begin
          if LK<>dlMain then
            Break;
          if FDataBlPtr<>Nil then
            DCUError('2nd Data block');
          FDataBlSize := ReadUIndex;
          FDataBlPtr := ReadMem(FDataBlSize);
        end ;
      drFixUp: LoadFixups;
      drEmbeddedProcEnd: begin
        if not((LK=dlArgsT)and(Ver>verD3)or(LK=dlArgs)
          and(Ver>verD3{verD5 was observed, but may be in prev ver. too}))
        then
          Break; {Temp. - this tag can mark the const definition used as an
          interface arg. default value and also as proc. arg. default value}
        if IsMSIL then
          WasEmbEnd := true; //For MSIL only.
            //drEmbeddedProcEnd - drEmbeddedProcStart mark block of const defs
            //We'll try to just ignore them
       end;
     //The following tables are present only when debug info is on
      drCodeLines: LoadCodeLines;
      drLinNum: LoadLineRanges;
      drStrucScope: LoadStrucScope;
      drLocVarTbl: LoadLocVarTbl;
     //Present if symbol info is on
      drSymbolRef: LoadSymbolInfo;
     //ver70
      drUnitAddInfo: begin
        if not((Ver>=verD7)and(Ver<verK1)) then
          break;
        Decl := ReadUnitAddInfo;
       end ;
      drConstAddInfo: begin
        if not((Ver>=verD7)and(Ver<verK1)or(Ver>=verK3)) then
          break;
       //used for deprecated and may be something else
        ReadConstAddInfo(LastProcDecl);
       end ;
      drProcAddInfo: begin
        if not((Ver>=verD7)and(ver<verK1)) then
          break;
        if (LK<>dlMain)and(Ver=verD7) then
          Break;
        V := ReadIndex;{B := ReadByte;} //Skip the byte, it was =2 after Finalization
            //and =FE after initialization
       // if (LK=dlMain) then
        SetProcAddInfo(V{,LastProcDecl});
       end ;
      drORec: begin
        if not((Ver>=verD8)and(Ver<verK1)) then
          break;
        ReadUIndex;
       end ;
      drInfo98: begin
        if not((Ver>=verD8)and(Ver<verK1)) then
          break;
        ReadUIndex;
        ReadUIndex;
       end ;
      drCLine: begin //Lines of C text, just ignore them by now
        if not((Ver>=verD10)and(Ver<verK1)) then
          break;
        V := ReadUIndex; //Length of the line
        SkipBlock(V); //Line chars
       end ;
      drA1Info: begin //Some record of 6 indices, ignore it completely
        if not((Ver>=verD10)and(Ver<verK1)) then
          break;
        ReadUIndex;
        ReadUIndex;
        ReadUIndex;
        ReadUIndex;
        V := ReadUIndex;
        for i:=1 to V do
          ReadUIndex;
       end ;
      drA2Info: begin
        if not((Ver>=verD10)and(Ver<verK1)) then
          break;
        //No data for this tag
       end ;
      arCopyDecl: begin
        if not((Ver>=verD10)and(Ver<verK1)) then
          break;
        Decl := TCopyDecl.Create;
       end ;
      else
        Break;
        //DCUErrorFmt('Unexpected tag: %s(%x)',[Tag,Byte(Tag)]);
      end ;
    finally
      if Decl<>Nil then begin
        DeclEnd^ := Decl;
        DeclEnd := @Decl.Next;
      end ;
    end ;
    Tag := ReadTag;
  end ;
  if Embedded<>Nil then begin
    if IsMSIL and(LK=dlEmbedded) then begin
      //A lot of files contain additional drEmbeddedProcStart - drEmbeddedProcEnd
      //brackets for aux record
      DeclEnd^ := Embedded;
     end
    else begin
      FreeDCURecList(Embedded);
      TagError('Unused embedded list');
    end ;
  end ;
end ;


var
  TstDeclCnt: integer=0;

function TUnit.ShowDeclList(LK: TDeclListKind; Decl: TNameDecl; Ofs: Cardinal;
  dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds;
  skDefault: TDeclSecKind): TDeclSecKind;
const
  SecNames: array[TDeclSecKind] of String = (
    '','label','const','type','var',
    'threadvar','resourcestring','exports','',
    'private','protected','public','published');
var
  DeclCnt: integer;
  SepS,SecN: String;
  SK: TDeclSecKind;
  Ofs0: Cardinal;
  Visible,NLRq: boolean;
var {for dsSmallSameNL:}
  LStart: integer;
  PrevDecl: TNameDecl;
  NP,PrevNP: PName;
  TD: TTypeDef;
begin
  DeclCnt := 0;
  if dsComma in SepF then
    SepS := ','
  else
    SepS := ';';
  Result := skDefault;
  Ofs0 := NLOfs;
  NLOfs := Ofs+dScopeOfs;
  LStart := -1;
  PrevDecl := Nil;
  while Decl<>Nil do begin
    Inc(TstDeclCnt);
    Visible := Decl.IsVisible(LK);
    if Visible then begin
      SK := Decl.GetSecKind;
      if (DeclCnt>0) then begin
        PutS(SepS);
        if dsNL in SepF then begin
          if dsSoftNL in SepF then
            SoftNL
          else
            NL;
        end ;
      end ;
      NLRq := false;
      if (SK<>Result) then begin
        Result := SK;
        NLOfs := Ofs;
        SecN := SecNames[SK];
        if SecN<>'' then begin
          NL;
          PutS(SecN);
        end ;
        if (SK<>skProc)or(dsOfsProc in SepF) then
          Inc(NLOfs,dScopeOfs);
        NLRq := true;
      end ;
      if (DeclCnt>0)or not(dsNoFirst in SepF) then begin
        if dsSoftNL in SepF then
          SoftNL
        else begin
          if not NLRq then begin
            NLRq := true;
           {Use simple heuristics: no empty line between one line declaration
            and the next one, if their names are same (same 1st char)}
            if (dsSmallSameNL in SepF)and(OutLineNum=LStart+1) then begin
              if Result<>skType then begin
                NP := Decl.Name;
                PrevNP := PrevDecl.Name;
                NLRq := NP^[1]<>PrevNP^[1];
               end
              else begin
                if (PrevDecl<>Nil)and(PrevDecl is TTypeDecl)
                  and(Decl is TTypeDecl)
                then begin
                  TD := GetTypeDef(TTypeDecl(PrevDecl).hDef);
                  if (TD<>Nil)and(TD is TPtrDef) then
                    NLRq := TPtrDef(TD).hRefDT<>TTypeDecl(Decl).hDef;
                end ;
              end ;
            end ;
          end ;
        end ;
      end ;
      if NLRq then
        NL;
      LStart := OutLineNum;
      PrevDecl := Decl;
      case LK of
        dlMain: Decl.ShowDef(false);
        dlMainImpl: Decl.ShowDef(true)
      else
        Decl.Show;
      end ;
      Inc(DeclCnt);
    end ;
    Decl := Decl.Next as TNameDecl;
  end ;
  if (DeclCnt>0)and(dsLast in SepF) then begin
    PutS(SepS);
    {if dsNL in SepF then
      NL;}
  end ;
  NLOfs := Ofs0;
end ;

procedure ShowDeclTList(Title: String; L: TList);
var
  i: integer;
  D: TDCURec;
begin
  NLOfs := 0;
  NL;
  NL;
  PutS(Title);
  for i:=1 to L.Count do begin
    NLOfs := 2;
    NL;
    PutSFmt('#%x: ',[i]);
    D := L[i-1];
    if D<>Nil then begin
      if D is TNameDecl then begin
        //if not TNameDecl(D).ShowDef(false) then
          TNameDecl(D).ShowName;
       end
      else if D is TBaseDef then
        TBaseDef(D).ShowNamed(Nil)
      else
        D.Show;
     end
    else
      PutS('-');
  end ;
end ;

{ Two methods against circular references }
function TUnit.RegTypeShow(T: TBaseDef): boolean;
begin
  Result := false;
  if FTypeShowStack.IndexOf(T)>=0 then
    Exit;
  FTypeShowStack.Add(T);
  Result := true;
end ;

procedure TUnit.UnRegTypeShow(T: TBaseDef);
var
  C: integer;
begin
  C := FTypeShowStack.Count-1;
  if (C<0)or(FTypeShowStack[C]<>T) then
    DCUError('in UnRegTypeShow');
  FTypeShowStack.Count := C;
end ;
{
function TUnit.RegDataBl(BlSz: Cardinal): Cardinal;
begin
  Result := FDataBlOfs;
  Inc(FDataBlOfs,BlSz);
end ;
}

function TUnit.GetBlockMem(BlOfs,BlSz: Cardinal; var ResSz: Cardinal): Pointer;
var
  EOfs: Cardinal;
begin
  Result := Nil;
  ResSz := BlSz;
  if (FDataBlPtr=Nil)or(integer(BlOfs)<0)or(BlSz=0) then
    Exit;
  EOfs := BlSz+BlOfs;
  if BlSz+BlOfs>FDataBlSize then begin
    BlSz := FDataBlSize-BlOfs;
    if integer(BlSz)<=0 then
      Exit;
  end ;
  Result := FDataBlPtr+BlOfs;
  ResSz := BlSz;
end ;

procedure TUnit.ShowDataBl(Ofs0,BlOfs,BlSz: Cardinal);
var
  Fix0: integer;
  DP,FOfs0: PChar;
begin
  PutSFmt('raw[$%x..$%x]',[Ofs0,BlSz-1]);
  if BlOfs<>Cardinal(-1) then
    PutSFmt('at $%x',[BlOfs]);
  DP := GetBlockMem(BlOfs+Ofs0,BlSz-Ofs0,BlSz);
  if DP=Nil then
    Exit;
//  Inc(NLOfs,2);
  NL;
  Fix0 := GetStartFixup(BlOfs+Ofs0);
  FOfs0 := Nil;
  if ShowFileOffsets then
    FOfs0 := FMemPtr;
  ShowDump(DP,FOfs0,FMemSize,0,BlSz,Ofs0,BlOfs+Ofs0,0,
    FFixupCnt-Fix0,@FFixupTbl^[Fix0],true);
//  Dec(NLOfs,2);
end ;


procedure TUnit.DasmCodeBlSeq(Ofs0,BlOfs,BlSz,SzMax: Cardinal);
var
  CmdOfs,OfsInProc,CmdSz: Cardinal;
  DP: Pointer;
  Fix0,hCL0,hLR0,L: integer;
  CL: TCodeLineRec;
  LR: TLineRangeRec;
  Ok: boolean;
  S: String;
  FOfs0: PChar;
begin
  DP := GetBlockMem(BlOfs,BlSz,BlSz);
  if DP=Nil then
    Exit;
{  Inc(AuxLevel);
//  Inc(NLOfs,2);
  NL;
  Dec(AuxLevel);}

  CmdOfs := BlOfs;
  Fix0 := GetStartFixup(BlOfs);
  hCL0 := GetStartCodeLine(BlOfs);
  GetCodeLineRec(hCL0,CL);
  hLR0 := GetStartLineRange(CL.L);
  GetLineRange(hLR0,LR);
  if SzMax<=0 then
    SzMax := BlSz+Ofs0;
  SetCodeRange(FDataBlPtr,PChar(DP)-Ofs0,BlSz+Ofs0);
  while true do begin
    while CmdOfs>=CL.Ofs do begin
      Dec(NLOfs,2);
      NL;
      L := CL.L;
      if LR.SrcF<>Nil then
        Inc(L,LR.Line0-LR.Num0-1);
      PutSFmt('// -- Line #%d -- ',[L]);
      if LR.SrcF=Nil then
        PutS('in ? ')
      else if LR.SrcF<>FSrcFiles then
        PutSFmt('in %s',[LR.SrcF^.Def^.Name]);
      if CmdOfs>CL.Ofs then
        PutSFmt('<<%d',[CmdOfs-CL.Ofs]);
      if (LR.SrcF<>Nil)and(LR.SrcF^.Lines<>Nil)and(L>0)and(L<=LR.SrcF^.Lines.Count)
      then begin
        S := LR.SrcF^.Lines[L-1];
        if S<>'' then begin
          NL;
          PutSFmt('//%s',[S]);
        end ;
      end ;
      Inc(NLOfs,2);
      Inc(hCL0);
      GetCodeLineRec(hCL0,CL);
      if CL.L>LR.Num0+LR.LineNum then begin
        Inc(hLR0);
        GetLineRange(hLR0,LR);
      end ;
    end ;
    NL;
    CodePtr := FDataBlPtr+CmdOfs;
    SetStartFixupInfo(Fix0);
    Ok := Disassembler.ReadCommand;
    if Ok then
      CmdSz := CodePtr-PrevCodePtr
    else if FixUpEnd>PrevCodePtr then
      CmdSz := FixUpEnd-PrevCodePtr
    else
      CmdSz := 1;
    FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;
    OfsInProc := CmdOfs-BlOfs+Ofs0;
    ShowDump(FDataBlPtr+CmdOfs,FOfs0,FMemSize,SzMax-OfsInProc{BlSz+Ofs0},CmdSz,OfsInProc,CmdOfs,
      7,FFixupCnt-Fix0,@FFixupTbl^[Fix0],not Ok);
    PutS(' ');
    if not Ok then begin
      PutS('?');
     end
    else begin
      Disassembler.ShowCommand;
    end ;
    Dec(BlSz,CmdSz);
    if BlSz<=0 then
      Break;
    Inc(CmdOfs,CmdSz);
    Fix0 := GetNextFixup(Fix0,CmdOfs);
  end ;
//  Dec(NLOfs,2);
end ;

type
  TDasmCodeBlState = record
    Proc: TProc;
    Ofs0,BlOfs,CmdOfs,CmdEnd: Cardinal;
    Seq: TCmdSeq;
  end ;

procedure RegCommandRef(RefP: LongInt; RefKind: Byte; IP: Pointer);
var
  {DP: Pointer;
  Ofs: LongInt;}
  RefSeq: TCmdSeq;
begin
  with TDasmCodeBlState(IP^) do begin
    if (RefP>CmdOfs)and(RefP<CmdEnd) then
      CmdEnd := RefP;
    RefSeq := Proc.AddSeq(RefP-BlOfs+Ofs0);
    if RefSeq=Nil then
      Exit;
    if RefKind=crJCond then
      Seq.SetCondNext(RefSeq)
    else
      Seq.SetNext(RefSeq);
  end ;
end ;


procedure TUnit.DasmCodeBlCtlFlow(Ofs0,BlOfs,BlSz: Cardinal);
var
  St: TDasmCodeBlState;
  {CmdOfs,CmdEnd,}CmdSz: Cardinal;
  i: integer;
  DP: Pointer;
  Fix0,hCL0,hCL,hLR0,L: integer;
  CL: TCodeLineRec;
  LR: TLineRangeRec;
  Ok: boolean;
  S: String;
var
  {Seq,}Seq1: TCmdSeq;
  hCurSeq: integer;
  MaxSeqSz: Cardinal;

(* Modified to make the disassembler abstract
  function RegisterCodeRef(Seq: TCmdSeq; RefKind: Byte; i: integer): boolean;
  var
    RefP: LongInt;
    DP: Pointer;
    Ofs: LongInt;
    RefSeq: TCmdSeq;
  begin
    Result := false;
    if i>Cmd.Cnt then
      Exit;
    with Cmd.Arg[i{Cmd.Cnt}] do
     Case Kind and caMask of
       {caImmed: begin
           if (Kind shr 4)and dsMask <> dsPtr then
             Exit;
           DP := PChar(PrevCodePtr)+Inf;
           RefP := LongInt(DP^);
         end ;}
       caJmpOfs: begin
           if Fix<>Nil then
             Exit; //!!!
           if not GetIntData(Kind shr 4,Inf,Ofs) then
             Exit;
           RefP := CmdOfs+Ofs;
         end;
     else
       Exit;
     End ;
    if (RefP>CmdOfs)and(RefP<CmdEnd) then
      CmdEnd := RefP;
    RefSeq := Proc.AddSeq(RefP-BlOfs+Ofs0);
    if RefSeq=Nil then
      Exit;
    if RefKind=crJCond then
      Seq.SetCondNext(RefSeq)
    else
      Seq.SetNext(RefSeq);
    Result := true;
  end ;

  function CheckCommandRefs(Seq: TCmdSeq): integer;
  begin
    case Cmd.hCmd of
     hnRet: begin
       Result := crJmp;
       Exit;
      end ;
     {!!! - temp
     hnCall: begin
       RegisterCodeRef(Seq,crCall,1);
       RegisterCodeRef(Seq,crCall,2);
      end ;}
     hnJMP: begin
       Result := crJmp;
       RegisterCodeRef(Seq,crJmp,1);
      end ;
     hnJ_: begin
       Result := crJCond;
       RegisterCodeRef(Seq,crJCond,2);
      end ;
     hnLOOP, hnLOOPE, hnLOOPNE, hnJCXZ: begin
       Result := crJCond;
       RegisterCodeRef(Seq,crJCond,1);
      end ;
    else
      Result := -1;
      Exit;
    end ;
  end ;
*)

  procedure ShowNotParsedDump;
  var
    Fix0: integer;
    FOfs0: PChar;
  begin
    if St.CmdEnd>=St.CmdOfs then
      Exit;
    NL;
    Fix0 := GetStartFixup(St.CmdEnd);
    FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;
    ShowDump(FDataBlPtr+St.CmdEnd,FOfs0,FMemSize,BlSz+St.Ofs0,St.CmdOfs-St.CmdEnd,
      St.CmdEnd-St.BlOfs+St.Ofs0,St.CmdEnd,0,
      FFixupCnt-Fix0,@FFixupTbl^[Fix0],true);
  end ;

begin
  DP := GetBlockMem(BlOfs,BlSz,BlSz);
  if DP=Nil then
    Exit;
  St.Ofs0 := Ofs0;
  St.BlOfs := BlOfs;
  St.Proc := TProc.Create(St.Ofs0,BlSz);
  try
   //If the line numbers info is present, include every line
   //start as a separate code sequence start (anyway, our decompiler
   //shouldn't be too smart to try to merge the commands from several lines
   //into a single operator):
    hCL0 := GetStartCodeLine(St.BlOfs);
    hCL := hCL0;
    St.CmdOfs := St.BlOfs+BlSz;
    while true do begin
      GetCodeLineRec(hCL,CL);
      if CL.Ofs>=St.CmdOfs then
        break;
      St.Proc.AddSeq(CL.Ofs-St.BlOfs+St.Ofs0);
      Inc(hCL);
    end ;
    while true do begin
      hCurSeq := St.Proc.GetNotReadySeqNum;
      St.Seq := St.Proc.GetCmdSeq(hCurSeq);
      if St.Seq=Nil then
        break;
      MaxSeqSz := St.Proc.GetMaxSeqSize(hCurSeq);
      St.CmdOfs := St.Seq.Start+St.BlOfs-St.Ofs0;
      Fix0 := GetStartFixup(St.CmdOfs);
      St.CmdEnd := St.CmdOfs+MaxSeqSz;
      SetCodeRange(FDataBlPtr,PChar(DP)-St.Ofs0+St.CmdOfs-St.BlOfs,St.CmdEnd);
      while true do begin
        if St.CmdOfs>=St.CmdEnd then begin
          St.Proc.ReachedNextS(St.Seq);
          break;
        end ;
        CodePtr := FDataBlPtr+St.CmdOfs;
        SetStartFixupInfo(Fix0);
        if not Disassembler.ReadCommand then
          break;
        CmdSz := CodePtr-PrevCodePtr;
        St.Seq.AddCmd(St.CmdOfs-St.BlOfs+St.Ofs0,CmdSz);
        Inc(St.CmdOfs,CmdSz);
        case Disassembler.CheckCommandRefs(RegCommandRef,St.CmdOfs,@St) of
         crJmp: break;
         crJCond: if St.CmdOfs<St.CmdEnd then begin
           Seq1 := St.Proc.AddSeq(St.CmdOfs-St.BlOfs+St.Ofs0);
           St.Seq.SetNext(Seq1);
           St.Seq := Seq1;
          end ;
        end ;
          //Cmd interrupts sequence (Jmp or Ret)
        Fix0 := GetNextFixup(Fix0,St.CmdOfs);
      end ;
    end ;
    St.CmdOfs := St.BlOfs;
    St.CmdEnd := St.BlOfs;
    for i:=0 to St.Proc.Count-1 do begin
      St.Seq := St.Proc.GetCmdSeq(i);
      St.CmdOfs := St.BlOfs+St.Seq.Start-St.Ofs0;
      ShowNotParsedDump;
      Dec(NLOfs,2);
      NL;
      PutSFmt('// -- Part #%d -- ',[i]);
      Inc(NLOfs,2);
      DasmCodeBlSeq(St.Seq.Start,St.CmdOfs,St.Seq.Size,BlSz+St.Ofs0);
      St.CmdEnd := St.CmdOfs+St.Seq.Size;
    end ;
    St.CmdOfs := St.BlOfs+BlSz;
    ShowNotParsedDump;
  finally
    St.Proc.Free;
  end ;
end ;

procedure TUnit.ShowCodeBl(Ofs0,BlOfs,BlSz: Cardinal);
var
  MSILHdr: PMSILHeader;
  Sz,CodeSz: Cardinal;
begin
  CodeSz := BlSz;
  if IsMSIL then begin
    if BlSz-Ofs0<=SizeOf(TMSILHeader) then begin
      NL;
      ShowDataBl(Ofs0,BlOfs,Ofs0+BlSz);
      Exit; //Wrong size
    end ;
    {NL;
    ShowDataBl(Ofs0,BlOfs,Ofs0+BlSz); //!!!Temp
    NL;}
    MSILHdr := GetBlockMem(BlOfs+Ofs0,SizeOf(TMSILHeader),Sz);
    if MSILHdr=Nil then begin
      ShowDataBl(Ofs0,BlOfs,Ofs0+BlSz);
      Exit; //Error reading MSIL header
    end ;
    if Ofs0=Cardinal(-1) then
      Ofs0 := 0;
   //1st 3 dwords - some info about proc.
    CodeSz := MSILHdr^.CodeSz;
    if CodeSz>BlSz then
      CodeSz := BlSz; //Just in case
    PutsFmt('[%4.4x|%4.4x,%d,%d]',[MSILHdr^.F,MSILHdr^.F1,MSILHdr^.CodeSz,MSILHdr^.L1]);
    NL;
//    Inc(Ofs0,SizeOf(TMSILHeader));
    Inc(BlOfs,SizeOf(TMSILHeader));
    Dec(BlSz,SizeOf(TMSILHeader));
  end ;
  Inc(AuxLevel);
  if Ofs0=0 then
    PutSFmt('//raw[0x%x]',[CodeSz])
  else
    PutSFmt('//raw[0x%x..0x%x]',[Ofs0,Ofs0+CodeSz]);
  if BlOfs<>Cardinal(-1) then
    PutSFmt('at 0x%x',[BlOfs]);
  Dec(AuxLevel);
  if IsMSIL then
    SetMSILDisassembler
  else
    Set80x86Disassembler;
  case DasmMode of
   dasmSeq: DasmCodeBlSeq(Ofs0,BlOfs,CodeSz,0);
   dasmCtlFlow: DasmCodeBlCtlFlow(Ofs0,BlOfs,CodeSz);
  end ;
  if CodeSz<BlSz then begin
    NL;
    PutS('rest:');NL;
    ShowDataBl(Ofs0+CodeSz,BlOfs+CodeSz,Ofs0+BlSz);
  end ;
end ;

(*
function CmpDCURecNames(Item1, Item2: Pointer): Integer;
var
  NP1,NP2: PName;
begin
  NP1 := TDCURec(Item1).Name;
  NP2 := TDCURec(Item2).Name;
  Result := Byte(NP1^[0])-Byte(NP2^[0]);
  if Result<>0 then
    Exit;
  Result := StrLIComp(@NP1^[1],@NP2^[1],Byte(NP1^[0]));
end ;

procedure TUnit.DetectUniqueNames;
{Detect the names, which are unique in the unit context}
var
  L: TList;
  UnitNames: TStringList;
  i,j: integer;
  D,D0: TDCURec;
begin
 {Wrong: should check not only the imported names, but all the names
  from all the imported units}
  L := nil;
  try
    L := TList.Create;
    L.Capacity := FAddrs.Count;
    for i:=0 to FAddrs.Count-1 do
      L.Add(FAddrs[i]);
    L.Sort(CmpDCURecNames);
    j := 0;
    D := L[0];
    for i:=1 to L.Count-1 do begin
      D0 := D;
      D := L[i];
      if CmpDCURecNames(D0,D)=0 then
        Continue;
      if (i=j+1)and(D0 is TImpDef) then
        TImpDef(D0).FNameIsUnique := true;
      j := i;
    end ;
    if (j>0)and(j=L.Count)and(D0 is TImpDef) then
      TImpDef(D0).FNameIsUnique := true;
  finally
    L.Free;
  end ;
end ;
*)

procedure TUnit.DetectUniqueNames;
{Detect the names, which are unique in the unit context}
var
  Decl: TNameDecl;
  NDX: integer;
  UnitNames: TStringList;
  UI,UI1: PUnitImpRec;
  Name: String;
  i,j: integer;
  D: TDCURec;
  IsUnique: boolean;
begin
 {Check whether all the imported units where found}
  for i:=0 to FUnitImp.Count-1 do begin
    UI := PUnitImpRec(FUnitImp[i]);
    if ufDLL in UI^.Flags then
      Continue;
    if (GetUnitImp(i)=Nil)and(UI^.Decls<>Nil{This check is for those pseudo-units of MSIL like .mscorlib})
    then begin
      DCUWarningFmt('used unit "%s" not found or incorrect - '+
        'all imported names will be shown with unit names',[UI^.Name^]);
      Exit;
    end ;
  end ;
  UnitNames := TStringList.Create;
  try
    UnitNames.Sorted := true;
    UnitNames.Duplicates := dupIgnore;
    Decl := FDecls;
    while Decl<>Nil do begin
      UnitNames.Add(Decl.Name^);
      Decl := Decl.Next as TNameDecl;
    end ;
    for i:=0 to FUnitImp.Count-1 do begin
      UI := PUnitImpRec(FUnitImp[i]);
      if ufDLL in UI^.Flags then
        Continue {DLL names can't be referenced in code};
      D := UI^.Decls;
      while D<>Nil do begin
        if (D is TImpDef) then begin
          Name := D.Name^;
          IsUnique := true;
          if UnitNames.Find(Name,NDX) then
            IsUnique := false
          else
            for j:=0 to FUnitImp.Count-1 do
             if j<>i then begin
               UI1 := PUnitImpRec(FUnitImp[j]);
               if ufDLL in UI1^.Flags then
                 Continue;
               if UI1^.Decls=Nil then
                 Continue;
               if UI1^.U.ExportDecls[Name,0]<>Nil then begin
                 IsUnique := false;
                 Break;
               end ;
             end ;
          TImpDef(D).FNameIsUnique := IsUnique;
        end ;
        D := D.Next as TBaseDef;
      end ;
    end ;
  finally
    UnitNames.Free;
  end ;
end ;

function TUnit.Load(FName: String; VerRq: integer; MSILRq: boolean; AMem: Pointer;
  UsesOnly: Boolean): boolean;
var
  F: File;
  Magic: ulong;
  FileSizeH,L,Flags1: ulong;
  FT: TFileTime;
  B: Byte;
  CP0: TScanState;
  SName: String;
begin
  Result := false;
  CurUnit := Self;
  if MainUnit=Nil then
    MainUnit := Self;
  FUnitImp := TList.Create;
  FTypes := TList.Create;
  FAddrs := TList.Create;
  FTypeShowStack := TList.Create;
  FDecls := Nil;
  FTypeDefCnt := 0;
//  FDefs := Nil;
  FFName := FName;
  FFExt := ExtractFileExt(FName);
  if AMem=Nil then begin
    AssignFile(F,FName);
    FileMode := 0; //Read only, helps with DCUs on CD
    Reset(F,1);
    try
      FMemSize := FileSize(F);
      GetMem(FMemPtr,FMemSize);
      BlockRead(F,FMemPtr^,FMemSize);
    finally
      Close(F);
    end ;
   end
  else begin
    FFromPackage := true;
    FMemPtr := AMem;
    FMemSize := PDCPUnitHdr(AMem)^.FileSize;
  end ;
  ChangeScanState(CP0,FMemPtr,FMemSize);
  try
    Magic := ReadULong;
    case Magic of
      $50505348: FVer := verD2;
      $44518641: FVer := verD3;
      $4768A6D8: FVer := verD4;
      ulong($F21F148B): FVer := verD5;
      $0E0000DD,$0E8000DD{Was observed too. Why differs?}: FVer := verD6;
      ulong($FF0000DF){Free},$0F0000DF,$0F8000DF: FVer := verD7;
      $10000229: begin
        FVer := verD8;
        FIsMSIL := true;
       end ;
      $11000239: begin
        FVer := verD9;
        FIsMSIL := true;
       end ;
      $1100000D,$11800009: FVer := verD9;
      $12000023: FVer := verD10; //Delphi 2006, testing is very incomplete
      $14000039: FVer := verD12; // Added by Liu Xiao for Delphi 2009.
      $15800045,$15000045: FVer := verD14; // Added by Liu Xiao for Delphi 2010.
      $1600034B: FVer := verD15; // Added by Liu Xiao for Delphi 2011(XE).
      $1780034B: FVer := verD16; // Added by Liu Xiao for Delphi 2012(XE2).      
      ulong($F21F148C): FVer := verK1; //Kylix 1.0
      $0E1011DD,$0E0001DD: FVer := verK2; //Kylix 2.0
      $0F1001DD,$0F0001DD: FVer := verK3; //Kylix 3.0
     //I guess some other magic values for Delphi 6.0, Kylix 2.0 and higher
     //versions are possible. One can easily add them here, and, please,
     //send me the file with different magic value.
    else
      DCUErrorFmt('Wrong magic: 0x%x',[Magic]);
    end ;
    DCURecs.Ver := FVer;
    if (VerRq>0)and((FVer<>VerRq)or(MSILRq<>FIsMSIL)) then
      Exit;
    Result := true; //Required version found
    if Ver=verD2 then begin
      fxStart := fxStart20;
      fxEnd := fxEnd20;
     end
    else if (Ver<verD7)or(Ver>=verK1)and(Ver<=verK2) then begin
      fxStart := fxStart30;
      fxEnd := fxEnd30;
     end
    else if (Ver>=verD10)and(Ver<verK1) then begin
      fxStart := fxStart100;
      fxEnd := fxEnd100;
     end
    else if not IsMSIL then begin
      fxStart := fxStart70;
      fxEnd := fxEnd70;
     end
    else {IsMSIL} begin
      fxStart := fxStartMSIL;
      fxEnd := fxEndMSIL;
    end ;
   { Read File Header }
    FileSizeH := ReadULong;
    if FileSizeH<>FMemSize then
      DCUErrorFmt('Wrong size: 0x%x<>0x%x',[FMemSize,FileSizeH]);
    FT := ReadULong;
    if Ver=verD2 then begin
      B := ReadByte;
      Tag := ReadTag;
     end
    else begin
      FStamp := Integer(ReadULong);
      B := ReadByte;
      if (Ver>=verD7)and(Ver<verK1) then begin
        B := ReadByte; //It has another header byte (or index)
        AddAddrDef(Nil); //Self reference added
      end ;
      if (Ver>=verD9)and(Ver<verK1) then
        SName := ReadStr;
      {if Ver>=verK1 then
        L := ReadULong; //$7E64AEE0 expected, it could be a tag $E0}
      {repeat
        Tag := ReadTag;
        case Tag of
         drUnitFlags: begin
           FFlags := ReadUIndex;
           if Ver>verD3 then
             FUnitPrior := ReadUIndex;
         end ;
         drUnit3,drUnit3c: begin
           if Ver<verK1 then
             Break;
           SkipBlock(3);
          end ;
         drUnit4: begin
           if Ver<verK1 then
             Break;
           L := ReadULong;
          end ;
        else
          Break;
        end ;
      until false;}
      if Ver>=verD12 then   // Added by Liu Xiao to get correct Tag in Delphi 2009
      begin
        ReadByte;
        ReadByte;
        ReadByte;
      end;
      if Ver>=verD15 then   // Added by Liu Xiao to get correct Tag in Delphi 2011(XE)
      begin
        ReadByte;
      end;

      Tag := ReadTag;
      if Ver>=verK1 then begin
        if Tag=drUnit4 then begin
          repeat
            L := ReadULong;
            Tag := ReadTag;
          until Tag<>drUnit4;
         end
        else if Tag<>drUnitFlags then begin
          SkipBlock(3);
          Tag := ReadTag;
        end ;
      end ;
      if Tag=drUnitFlags then begin
        FFlags := ReadUIndex;
        if (Ver>verD9)and(Ver<verK1) then
          Flags1 := ReadUIndex;
        if Ver>verD3 then
          FUnitPrior := ReadUIndex;
        Tag := ReadTag;
      end ;
    end ;
    ReadSourceFiles;
  {  PutS('interface');
    NLOfs := 0;
    NL;}
    ReadUses(drUnit);
  {  NLOfs := 0;
    NL;
    PutS('implementation');
    NLOfs := 0;
    NL;}
    ReadUses(drUnit1);
  {  NLOfs := 0;
    NL;
    PutS('imports');
    NLOfs := 0;
    NL;}
    ReadUses(drDLL);

    if UsesOnly then
      Exit;

    try
      ReadDeclList(dlMain,FDecls);
      if (FDataBlPtr=Nil)or(FFixupTbl=Nil) then
       //Let's ignore unknown tags after drCBlock and drFixUp, but not before
        DCUError('stop tag');
      //if Tag<>drStop then
      //  DCUError({'Unexpected '+}'stop tag');
    finally
      SetExportNames(FDecls);
      SetEnumConsts(FDecls);
      FillProcLocVarTbls;
     // Show;
    end ;
  finally
    FLoaded := true;
    RestoreScanState(CP0);
  end ;
end ;

destructor TUnit.Destroy;
var
  i: integer;
  U: PUnitImpRec;
  SFR: PSrcFileRec;
begin
  CurUnit := Self;
  FTypeShowStack.Free;
  if FLocVarTbl<>Nil then
    FreeMem(FLocVarTbl,FLocVarCnt*SizeOf(TLocVarRec));
  if FLineRangeTbl<>Nil then
    FreeMem(FLineRangeTbl,FLineRangeCnt*SizeOf(TLineRangeRec));
  if FCodeLineTbl<>Nil then
    FreeMem(FCodeLineTbl,FCodeLineCnt*SizeOf(TCodeLineRec));
  if FFixupTbl<>Nil then
    FReeMem(FFixupTbl,FFixupCnt*SizeOf(TFixupRec));
//  FreeDCURecList(FDecls);
//  FreeDCURecList(FDefs);
  if FUnitImp<>Nil then begin
    for i:=0 to FUnitImp.Count-1 do begin
      U := FUnitImp[i];
      FreeDCURecList(U^.Decls);
      U^.Ref.Free;
//      FreeDCURecList(U^.Addrs);
//      FreeDCURecList(U^.Types);
      Dispose(U);
    end ;
    FUnitImp.Free;
  end ;
  FExportNames.Free;
//  FreeDCURecTList(FTypes);
  FTypes.Free;
//  FreeDCURecTList(FAddrs);
  FAddrs.Free;
  FreeDCURecList(FDecls);
//  FTypes.Free;
//  FAddrs.Free;
  while FSrcFiles<>Nil do begin
    SFR := FSrcFiles;
    FSrcFiles := SFR^.Next;
    SFR^.Lines.Free;
    Dispose(SFR);
  end ;
  if not FFromPackage and(FMemPtr<>Nil) then
    FreeMem(FMemPtr,FMemSize);
  if MainUnit=Self then
    MainUnit := Nil;
  inherited Destroy;
end ;

procedure TUnit.DoShowFixupTbl;
var
  i: integer;
  FP: PFixupRec;
begin
  if FFixupTbl=Nil then
    Exit ;
  PutSFmt('Fixups: %d',[FFixupCnt]);
  NLOfs := 2;
  FP := Pointer(FFixupTbl);
  for i:=0 to FFixupCnt-1 do begin
    NL;
    PutSFmt('%3d: %6x K%2x %s',[i,FP^.OfsF and FixOfsMask,TByte4(FP^.OfsF)[3],
      GetAddrStr(FP^.NDX,true)]);
    Inc(FP);
  end ;
  NLOfs := 0;
  NL;
  NL;
end ;

procedure TUnit.FillProcLocVarTbls;
var
  i,iStart: integer;
  LVP: PLocVarRec;
  Proc: TProcDecl;
  D: TDCURec;
  WasProc,IsProc: boolean;
  f: integer;

  procedure FlushProc(i0,i1: integer);
  begin
    if Proc=Nil then
      Exit;
    Proc.FProcLocVarTbl := @(FLocVarTbl^[i0]);
    Proc.FProcLocVarCnt := i1-i0;
  end ;

begin
  if FLocVarTbl=Nil then
    Exit;
  LVP := Pointer(FLocVarTbl);
  IsProc := false;
  Proc := Nil;
  iStart := 0;
  for i:=0 to FLocVarCnt-1 do begin
    WasProc := IsProc;
    f := LVP^.frame;
    D := Nil;
    IsProc := false;
    if not WasProc and(LVP^.Sym<>0) then begin
      D := GetAddrDef(LVP^.Sym);
      IsProc := D is TProcDecl;
      if IsProc then begin
        FlushProc(iStart,i);
        Proc := TProcDecl(D);
        iStart := i;
      end ;
    end ;
    Inc(LVP);
  end ;
  FlushProc(iStart,FLocVarCnt);
end ;

procedure TUnit.DoShowLocVarTbl;
var
  i: integer;
  LVP: PLocVarRec;
  D: TDCURec;
  WasProc,IsProc: boolean;
  S,S1: String;
  f: integer;
begin
  if FLocVarTbl=Nil then
    Exit;
  PutSFmt('Local Variables: %d',[FLocVarCnt]);
  NLOfs := 2;
  LVP := Pointer(FLocVarTbl);
  IsProc := false;
  for i:=0 to FLocVarCnt-1 do begin
    WasProc := IsProc;
    NL;
    f := LVP^.frame;
    D := Nil;
    S1 := '';
    IsProc := false;
    if WasProc then
      S1 := IntToStr(LVP^.Sym) //Proc takes 2 records => don't interpret the value
        //as an addr ref
    else if LVP^.Sym<>0 then begin
      D := GetAddrDef(LVP^.Sym);
      IsProc := D is TProcDecl;
      S1 := GetDCURecStr(D, LVP^.Sym,true);
      if IsProc then
        S1 := 'p:'+S1;
    end ;
    if (D=Nil)or IsProc or WasProc then
      S := Format('%d',[f]) //Proc takes 2 records => don't interpret the value
        //as a frame
    else if (f>=Low(RegName))and(f<=High(RegName)) then
      S := RegName[f]
    else if f=-1 then
      S := '/'
    else if f>0 then
      S := Format('[EBP+%d]',[f])
    else
      S := Format('[EBP%d]',[f]);
    PutSFmt('%4d: %4x %s %s',[i,LVP^.Ofs,S,S1]);
    Inc(LVP);
  end ;
  NLOfs := 0;
  NL;
  NL;
end ;

procedure TUnit.Show;
begin
  if Self=Nil then
    Exit;
  CurUnit := Self;
  if not ShowImpNamesUnits then
    DetectUniqueNames;
  InitOut;
  if ShowAuxValues then
    AuxLevel := -MaxInt
  else
    AuxLevel := 0;
  NLOfs := 0;
  ShowSourceFiles;
  PutS('interface');
  NLOfs := 0;
  NL;
  if ShowUses('uses',[]) then begin
    NLOfs := 0;
    NL;
    //NL;
  end ;
  ShowDeclList(dlMain,FDecls,0,2,[dsLast,dsNL,dsSmallSameNL],BlockSecKinds,skNone);
  NLOfs := 0;
  NL;
  NL;
  if InterfaceOnly then
    Exit;
  PutS('implementation');
  NLOfs := 0;
  NL;
  if ShowUses('uses',[ufImpl]) then begin
    NLOfs := 0;
    NL;
    //NL;
  end ;
  if ShowUses('imports',[ufDLL]) then begin
    NLOfs := 0;
    //NL;
    NL;
  end ;
  ShowDeclList(dlMainImpl,FDecls,0,2,[dsLast,dsNL,dsSmallSameNL],BlockSecKinds,skNone);
  NLOfs := 0;
  NL;
  NL;
  PutS('end.');
  NLOfs := 0;
  NL;
  NL;
  if ShowTypeTbl then begin
    PutSFmt('Types defined: 0x%x of 0x%x',[FTypeDefCnt,FTypes.Count]);
    ShowDeclTList('types',FTypes);
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowAddrTbl then begin
    PutSFmt('Addrs defined: 0x%x',[FAddrs.Count]);
    ShowDeclTList('addrs',FAddrs);
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowDataBlock then begin
    PutSFmt('Data used: 0x%x of 0x%x ',[FDataBlOfs,FDataBlSize]);
    if (FDataBlPtr<>Nil){and(FDataBlOfs<FDataBlSize)} then
      ShowDataBl(FDataBlOfs,0,FDataBlSize{-FDataBlOfs});
    NLOfs := 0;
    NL;
    NL;
  end ;
  if ShowFixupTbl then
    DoShowFixupTbl;
  if ShowLocVarTbl then
    DoShowLocVarTbl;
  FlushOut;
end ;

end.
