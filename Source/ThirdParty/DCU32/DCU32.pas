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

{$RANGECHECKS OFF}

uses
  {$IFDEF UNICODE}  AnsiStrings, {$ENDIF}
  SysUtils, Classes, DasmDefs, DCU_In, DCU_Out, FixUp, DCURecs;

{$IFNDEF VER90}
 {$IFNDEF VER100}
  {$REALCOMPATIBILITY ON}
 {$ENDIF}
{$ENDIF}
{$IFDEF WIN32}
{$DEFINE WIN}
{$ENDIF}

const {My own (AX) codes for Delphi/Kylix versions}
  verD2 = 2;
  verD3 = 3;
  verD4 = 4;
  verD5 = 5;
  verD6 = 6;
  verD7 = 7;
  verD8 = 8;
  verD2005 = 9; //2005
  verD2006 = 10; //2006
  verD2009 = 12; //2009
  verD2010 = 13; //2010
  verD_XE = 14; //XE
  verD_XE2 = 15; //XE2
  verD_XE3 = 16; //XE3
  verD_XE4 = 17; //XE4
  verD_XE5 = 18; //XE5
  verD_XE6 = 19; //XE6
  //verAppMethod=20; //AppMethod
  verD_XE7 = 20; //XE7&AppMethod
  verD_XE8 = 21; // Added by LiuXiao Begin.
  verD_10S = 22;
  verD_101B = 23;
  verD_102T = 24;
  verD_103R = 25;
  verD_104S = 26;
  verD_110A = 27;
  verD_120A = 28; // Added by LiuXiao End.
  verK1 = 100; //Kylix 1.0
  verK2 = 101; //Kylix 2.0
  verK3 = 102; //Kylix 3.0
  MaxDelphiVer = 20;

type
  TDCUPlatform = (dcuplWin32, dcuplWin64, dcuplOsx32, dcuplIOSEmulator, dcuplIOSDevice, dcuplAndroid);

{ Internal unit types }
const
  drStop = 0;
  drStop_a = $61{'a'}; //Last Tag in all files
  drAssemblyData = $62{'b'}; //The data structure was found in .<PackageName> units of D8 packages
  drStop1 = $63{'c'};
  drUnit = $64{'d'};
  drUnit1 = $65{'e'}; //in implementation
  drImpType = $66{'f'};
  drImpVal = $67{'g'};
  drDLL = $68{'h'};
  drExport = $69{'i'};
  drEmbeddedProcStart = $6A{'j'};
  drEmbeddedProcEnd = $6B{'k'};
  drCBlock = $6C{'l'};
  drFixUp = $6D{'m'};
  drImpTypeDef = $6E{'n'}; //import of type definition by "A = type B"
  drSrc = $70{'p'};
  drObj = $71{'q'};
  drRes = $72{'r'};
  drAsm = $73{'s'}; //Found in D5 Debug versions
  drAssemblySrc = $74{'t'}; //For .net assembly the *.DCP is generated automatically, so the assembly is its source
  drStop2 = $9F{'?}; //!!!
  drConst = $25{'%'};
  drResStr = $32{'2'};
  drType = $2A{'*'};
  drTypeP = $26{'&'};
  drProc = $28{'('};
  drSysProc = $29{')'};
  drVoid = $40{'@'};
  drVar = $20{' '};
  drThreadVar = $31{'1'};
  drVarC = $27{'''};
  drBoolRangeDef = $41{'A'};
  drChRangeDef = $42{'B'};
  drEnumDef = $43{'C'};
  drRangeDef = $44{'D'};
  drPtrDef = $45{'E'};
  drClassDef = $46{'F'};
  drObjVMTDef = $47{'G'};
  drProcTypeDef = $48{'H'};
  drFloatDef = $49{'I'};
  drSetDef = $4A{'J'};
  drShortStrDef = $4B{'K'};
  drArrayDef = $4C{'L'};
  drRecDef = $4D{'M'};
  drObjDef = $4E{'N'};
  drFileDef = $4F{'O'};
  drTextDef = $50{'P'};
  drWCharRangeDef = $51{'Q'}; //WideChar
  drStringDef = $52{'R'};
  drVariantDef = $53{'S'};
  drInterfaceDef = $54{'T'};
  drWideStrDef = $55{'U'};
  drWideRangeDef = $56{'V'};

//Various tables
  drCodeLines = $90;
  drLinNum = $91;
  drStrucScope = $92;
  drSymbolRef = $93;
  drLocVarTbl = $94;
  drUnitFlags = $96;

//ver70 or higher tags (all of unknown purpose)
  drUnitAddInfo = $34{'4'};
  drInfo98 = $98;
  drConstAddInfo = $9C;
  drProcAddInfo = $9E;
  drAssemblyInfo = $9D; //Ver 2005,2006 .Net
//ver80 or higher tags (some of unknown purpose)
  drORec = $6F{'o'}; //goes before drCBlock in MSIL
  drStrConstRec = $35{'5'};
  drMetaClassDef = $57{'W'};
//Kylix specific flags
{  drUnit3=$E0; //4-bytes record, present in almost all units
  drUnit3c=$06; //4-bytes record, present in System, SysInit
}
  drUnit4 = $0F; //5-bytes record, was observed in QOpenBanner.dcu only

//ver10 and higher tags
//  drAddInfo6=$36{'6'};
  drSpecVar = $37{'7'};
  arClassVarReal = $2D {real value}{'-'};
  arClassVar = $36 {technical value};
  drCLine = $A0;
  drA1Info = $A1;
  drA2Info = $A2;
  arCopyDecl = $A3;

//ver12 and higher tags
  drDynArrayDef = Ord('X'); //Separate from drArrayDef tag now
  drTemplateArgDef = Ord('Y');
  drTemplateCall = Ord('Z');
  drUnicodeStringDef = Ord('[');
  //drA3Info=$A3;
  drA5Info = $A5;
  drA6Info = $A6;
  drA7Info = $A7;
  drA8Info = $A8;
  drDelayedImpInfo = $B0;

//ver13 and higher tags
  drUnitInlineSrc = Ord('v');
  arAnonymousBlock = $01;
  arVal = $21{'!'};
  arVar = $22{'"'};
  arResult = $23{'#'};
  arAbsLocVar = $24{'$'};
  arLabel = $2B{'+'};

//ver verD_XE2 and higher tags
//mode64 only till verD_XE5, all modes since verD_XE6
  drSegInfo = $B1;
  drB2Info = $B2;

//ver verD_XE3 and higher tags
  arFinalFlag = $C2;

//ver verD_XE4 and higher tags
  drA9Info = $A9;

//ver verD_XE7 and higher tags
  drNextOverload = $B6;

//Fields
  arFld = $2C{','};
  arMethod = $2D{'-'};
  arConstr = $2E{'.'};
  arDestr = $2F{'/'};
  arProperty = $30{'0'};
  arSetDeft = $9A;
  arCDecl = $81;
  arPascal = $82;
  arStdCall = $83;
  arSafeCall = $84;

type
  TProcCallTag = arCDecl..arSafeCall;

type
{ Auxiliary data types }

  TDeclSepFlags = set of (dsComma, dsLast, dsNoFirst, dsNL, dsSoftNL, dsSmallSameNL, dsOfsProc);

  TDeclSecKinds = set of TDeclSecKind;

const
  RecSecKinds: TDeclSecKinds = [];
  ProcSecKinds: TDeclSecKinds = [];
  BlockSecKinds: TDeclSecKinds = [skNone, skLabel, skConst, skType, skVar, skThreadVar, skResStr, skExport, skProc];
  ClassSecKinds: TDeclSecKinds = [skPrivate, skProtected, skPublic, skPublished];

type
  PSrcFileRec = ^TSrcFileRec;

  TSrcFileRec = record
    Next: PSrcFileRec;
    Def: PNameDef;
    FT: LongInt;
    NDX: integer;
    Lines: TStringList;
  end;

type //AUX, not real file structures

  PCodeLineRec = ^TCodeLineRec;

  TCodeLineRec = record
    Ofs, L: integer;
  end;

  PCodeLineTbl = ^TCodeLineTbl;

  TCodeLineTbl = array[Word] of TCodeLineRec;

//Using the $I directive DCU file can be composed of several source files
//The TLineRangeRec sructure represents the mapping of DCU internal line numbers
//to the real line numbers of source files
  PLineRangeRec = ^TLineRangeRec;

  TLineRangeRec = record
    Line0, LineNum, Num0: integer;
    SrcF: PSrcFileRec;
  end;

  PLineRangeTbl = ^TLineRangeTbl;

  TLineRangeTbl = array[Word] of TLineRangeRec;

//for verD_XE - fix orphaned local types problem
  PEmbeddedTypeInf = ^TEmbeddedTypeInf;

  TEmbeddedTypeInf = record
    TD: TTypeDecl;
    Depth: Integer
  end;

  PEmbeddedListInf = ^TEmbeddedListInf;

  TEmbeddedListInf = record
    List: TDCURec{TNameDecl};
    ListEnd: PTDCURec{PTNameDecl};
  end;

  PEmbeddedListInfTbl = ^TEmbeddedListInfTbl;

  TEmbeddedListInfTbl = array[Byte] of TEmbeddedListInf;

type
  TUnit = class;

  PUnitImpRec = ^TUnitImpRec;

  TUnitImpFlags = set of (ufImpl, ufDLL);

  TUnitImpRec = record
    Ref: TUnitImpDef;
    Name: PName;
    Decls: TBaseDef;
//  Types: TBaseDef;
//  Addrs: TBaseDef;
    Flags: TUnitImpFlags;
    U: TUnit;
  end;

  TUnitClass = class of TUnit;

  TUnit = class
  protected
    FMemPtr: TIncPtr;
    FMemSize: Cardinal;
    FFromPackage: boolean;
    FVer: integer;
    FIsMSIL: boolean;
    FPlatform: TDCUPlatform;
    FPtrSize: Cardinal;
    FStamp, FFlags, FUnitPrior: integer;
    FFName, FFExt: string;
    FUnitName: string;
    FSrcFiles: PSrcFileRec;
    FUnitImp: TList;
    FTypes: TList;
    FAddrs: TList;
    FhNextAddr: integer; //Required for ProcAddInfo in Ver>verD8
    FExportNames: TStringList;
    FDecls: TDCURec{TNameDecl};
    FOtherRecords: TDCURec; //The records, which where not included into FDecls or their fields
//  FDefs: TBaseDef;
    FTypeDefCnt: integer;
    FTypeShowStack: TList;
 {Data block}
    FDataBlPtr: TIncPtr;
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
    FLocVarSize: integer; //The actual number of records in FLocVarTbl (required for XE2 64bit)
    FLocVarTbl: PLocVarTbl;
    FLoaded: boolean;
    function GetVersionStr: string;
    procedure ReadMagic;
    procedure SetupFixups;
    procedure ReadUnitHeader;
    procedure ReadSourceFiles;
    procedure ShowSourceFiles;
    function ShowUses(PfxS: AnsiString; FRq: TUnitImpFlags): boolean;
    procedure ReadUses(TagRq: TDCURecTag);
    function ReadUnitAddInfo: TUnitAddInfo;
    procedure SetListDefName(L: TList; hDef, hDecl: integer; Name: PName);
    procedure SetDeclMem(hDef: integer; Ofs, Sz: Cardinal);
//  procedure AddAddrName(hDef: integer; Name: PName);
    function GetTypeName(hDef: integer): PName;
    function GetAddrName(hDef: integer): PName;
{-------------------------}
    function GetUnitImpRec(hUnit: integer): PUnitImpRec;
    function GetUnitImp(hUnit: integer): TUnit;
    procedure SetExportNames(Decl: TDCURec{TNameDecl});
    procedure SetEnumConsts(var Decl: TDCURec{TNameDecl});
    function GetExportDecl(const Name: string; Stamp: integer): TNameFDecl;
    function GetExportType(const Name: string; Stamp: integer): TTypeDef;
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
    procedure DasmCodeBlSeq(Ofs0, BlOfs, BlSz, SzMax: Cardinal); virtual;
    procedure DasmCodeBlCtlFlow(Ofs0, BlOfs, BlSz: Cardinal); virtual;
    function ReadConstAddInfo(LastProcDecl: TNameDecl): integer;
    procedure SetProcAddInfo(V: integer{; LastProcDecl: TNameDecl});
    function GetAddrCount: Integer;
    function GetTypeCount: Integer;
    function ShowMSILExcHandlers(Ofs0, BlOfs, Sz: Cardinal): Cardinal;
    procedure SetUnitPackageInfo(hDecl: Integer; const sInfo: string);
  public { Exported for DCURecs: }
    function AddAddrDef(ND: TDCURec): integer;
    function AppendAddrDef(ND: TDCURec): integer;
    procedure RefAddrDef(V: integer);
    function GetAddrDef(hDef: integer): TDCURec;
    function GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
    procedure AddTypeDef(TD: TTypeDef);
    procedure ClearLastTypeDef(TD: TTypeDef);
    procedure ClearAddrDef(ND: TNameDecl);
    function GetTypeDef(hDef: integer): TTypeDef;
    function GetTypeSize(hDef: integer): integer;
    procedure AddTypeName(hDef, hDecl: integer; Name: PName);
    function ShowTypeName(hDef: integer): boolean;
    function TypeIsVoid(hDef: integer): boolean;
    function RegTypeShow(T: TBaseDef): boolean;
    procedure UnRegTypeShow(T: TBaseDef);
    procedure ShowDataBl(Ofs0, BlOfs, BlSz: Cardinal);
    procedure ShowDataBlP(DP: Pointer; DS, Ofs0: Cardinal);
    procedure ShowCodeBl(Ofs0, BlOfs, BlSz: Cardinal); virtual;
    procedure ShowTypeDef(hDef: integer; N: PName);
    function GetLocalTypeDef(hDef: integer): TTypeDef;
    function GetGlobalTypeDef(hDef: integer; var U: TUnit): TTypeDef;
    function ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal; ConstKind: Integer): integer {Size used};
    function ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal; AndRest: boolean; ConstKind: Integer): integer {Size used};
    function ShowGlobalConstValue(hDef: integer): boolean;
    function GetOfsQualifierEx(hDef: integer; Ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): Boolean;
    function GetOfsQualifier(hDef: integer; Ofs: integer): AnsiString;
    function GetRefOfsQualifierEx(hDef: integer; Ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): Boolean;
    function GetRefOfsQualifier(hDef: integer; Ofs: integer): AnsiString;
  //function
    function GetBlockMem(BlOfs, BlSz: Cardinal; var ResSz: Cardinal): Pointer;
    function FixTag(Tag: TDCURecTag): TDCURecTag;
    procedure ReadDeclList(LK: TDeclListKind; var Result: TDCURec{TNameDecl});
    function ShowDeclList(LK: TDeclListKind; MainRec: TDCURec; Decl: TDCURec{TNameDecl}; Ofs: Cardinal; dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds; skDefault: TDeclSecKind): TDeclSecKind;
    function GetStartFixup(Ofs: Cardinal): integer;
    procedure SetStartFixupInfo(Fix0: integer);
    property DataBlPtr: TIncPtr read FDataBlPtr;
    property UnitImpRec[hUnit: integer]: PUnitImpRec read GetUnitImpRec;
    procedure DoShowFixupTbl;
    procedure FillProcLocVarTbls;
    procedure DoShowLocVarTbl;
  protected
    FEmbedDepth, FMaxEmbedDepth, FEmbedLimit: Integer;
    FEmbeddedLists: PEmbeddedListInfTbl; //contains the lists which were not consumed
    function IncEmbedDepth(var HeadBuf: TDCURec{TNameDecl}): PTDCURec{PTNameDecl};
    function ConsumeEmbedded: TDCURec{TNameDecl};
  protected //for verD_XE - fix orphaned local types problem
    FEmbeddedTypes: TList; //contains PEmbeddedTypeInf, it is indexed by TD.hDef, not by FEmbedDepth
    procedure RegisterEmbeddedTypes(var Embedded: TDCURec{TNameDecl}; Depth: Integer);
    procedure BindEmbeddedTypes;
  public
    constructor Create; virtual; //Allows to extend TUnit
    function Load(const FName: string; VerRq: integer; MSILRq: boolean; PlatformRq: TDCUPlatform; AMem: Pointer): boolean; //Load instead of Create
    //to prevent from Destroy after Exception in constructor
    destructor Destroy; override;
    procedure Show;
    property VersionStr: string read GetVersionStr;
    function GetAddrStr(hDef: integer; ShowNDX: boolean): AnsiString;
    procedure PutAddrStr(hDef: integer; ShowNDX: boolean);
    procedure PutAddrStrRmClassName(hDef: integer; ShowNDX: boolean);
    function IsValidMemPtr(DP: Pointer): Boolean;
    property UnitName: string read FUnitName;
    property FileName: string read FFName;
    property ExportDecls[const Name: string; Stamp: integer]: TNameFDecl read GetExportDecl;
    property ExportTypes[const Name: string; Stamp: integer]: TTypeDef read GetExportType;
    property Ver: integer read FVer;
    property IsMSIL: boolean read FIsMSIL;
    property platform: TDCUPlatform read FPlatform;
    property PtrSize: Cardinal read FPtrSize;
    property Stamp: integer read FStamp;
    property FromPackage: boolean read FFromPackage;
//  property fxStart: Byte read FfxStart;
//  property fxEnd: Byte read FfxEnd;
    property AddrName[hDef: integer]: PName read GetAddrName;
    property TypeName[hDef: integer]: PName read GetTypeName;
    property AddrCount: Integer read GetAddrCount;
    property TypeCount: Integer read GetTypeCount;
    property DeclList: TDCURec{TNameDecl} read FDecls;
    property MemPtr: TIncPtr read FMemPtr;
  end;

var
  MainUnit: TUnit = Nil;
  CurUnit: TUnit;
  CurMainRec:TDCURec {of ShowDeclList};
  CurDeclList: TDCURec{TNameDecl} {of ShowDeclList};

{ Exported for other TUnitClass: }
procedure RegCommandRef(RefP: LongInt; RefKind: Byte; IP: Pointer);
{ Exported for DCURecs: }

function GetDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean): AnsiString;

procedure PutDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean);

implementation

uses
  DCUTbl, DCP, DasmX86, DasmMSIL, DasmCF, Op{$IFDEF WIN}, Windows{$ENDIF};

{procedure FreeDCURecTList(L: TList);
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
end ;}

function FileDateToStr(FT: TDCUFileTime): AnsiString;
const
  DaySec = 24 * 60 * 60;
var
  T: TDateTime;
begin
  if CurUnit.Ver < verK1 then
    T := FileDateToDateTime(FT)
  else
    T := EncodeDate(1970, 1, 1) + FT / DaySec{Unix Time to Delphi time};
  Result := FormatDateTime('c', T);
end;

function GetDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean): AnsiString;
var
  N: PName;
  Ch, ScopeCh: AnsiChar;
  Pfx: AnsiString;
  CP: PAnsiChar;
  cd: integer;
begin
  if D = Nil then
    N := @NoName
  else
    N := D.Name;
  Ch := N^.Get1stChar;
  if Ch{N^[0]} = #0 then
  begin
    Pfx := NoNamePrefix;
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%x', [hDef]);
    ShowNDX := false;
  end
  else if Ch{N^[1]} = '.' then
  begin
    Pfx := DotNamePrefix;
    Result := N^.GetRightStr(1){Copy(N^,2,255)};
  end
  else
  begin
    Result := N^.GetStr;
    Pfx := '';
  end;
  if Pfx <> '' then
  begin
    CP := MyStrScan(PAnsiChar(Pfx), '%');
    if CP <> Nil then
    begin
      if D = Nil then
        ScopeCh := 'N'
      else
      begin
        if (D is TTypeDecl) or (D is TTypeDef) then
          ScopeCh := 'T'
        else if D is TVarDecl then
          ScopeCh := 'V'
        else if D is TConstDecl then
          ScopeCh := 'C'
        else if D is TProcDecl then
          ScopeCh := 'F'
        else if D is TLabelDecl then
          ScopeCh := 'L'
        else if (D is TPropDecl) or (D is TDispPropDecl) then
          ScopeCh := 'P'
        else if D is TLocalDecl then
          ScopeCh := 'v'
        else if D is TMethodDecl then
          ScopeCh := 'M'
        else if D is TExportDecl then
          ScopeCh := 'E'
        else
          ScopeCh := 'n';
      end;
      cd := CP - PAnsiChar(Pfx);
      UniqueString(Pfx); {Make the string unique - it will be altered}
      CP := PAnsiChar(Pfx) + cd;
      repeat
        CP^ := ScopeCh;
        CP := MyStrScan(CP + 1, '%');
      until CP = Nil;
    end;
    Result := Pfx + Result;
  end;
  if ShowNDX then
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s{0x%x}', [Result, hDef]);
end;

procedure PutDCURecStr(D: TDCURec; hDef: integer; ShowNDX: boolean);
var
  S: AnsiString;
begin
  S := GetDCURecStr(D, hDef, false{ShowNDX});
  PutAddrDefStr(S, hDef);
  if ShowNDX then
    PutSFmtRem('#$%x', [hDef]);
end;

{$IFDEF WIN}
function GetFileVersionStr: string;
{Copied from SysUtils of D7 and modified}
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize, V, B: DWORD;
begin
  Result := '';
  FileName := ParamStr(0);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
        begin
          V := FI^.dwFileVersionMS;
          B := FI^.dwFileVersionLS;
          Result := Format('Version: %d.%d', [V shr 16, V and $FFFF]);
          //Result := Format('Version: %d.%d, build %d.%d',[V shr 16, V and $FFFF,B shr 16, B and $FFFF]);
          //Delphi XE2 writes wrong build numbers into VersionInfo
        end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;
{$ENDIF}

{ TUnit. }

function TUnit.GetVersionStr: string;
const
  verStrDelphi: array[2..MaxDelphiVer] of string = ('2', '3', '4', '5', '6', '7', '8', '2005', '2006', '?2007', '2009', '2010', 'XE', 'XE2', 'XE3', 'XE4', 'XE5', 'XE6', 'XE7');
  platfStr: array[TDCUPlatform] of string = ('Win32', 'Win64', 'Osx32', 'iOSEmulator', 'iOSDevice', 'Android');
begin
  if Ver < verK1 then
  begin
    Result := 'Delphi ' + verStrDelphi[Ver];
    if Ver >= verD_XE2 then
      Result := Format('%s (%s)', [Result, platfStr[FPlatform]]);
  end
  else
    Result := Format('Kylix %d', [Ver - verK1 + 1]);
end;

procedure TUnit.ReadSourceFiles;
var
  {hSrc,}  F: integer;
  SrcFName: ShortString;
  SP, CP: PChar;
 // FT: TDCUFileTime;
 // B: Byte;
  SFRP: ^PSrcFileRec;
  SFR, SFRMain: PSrcFileRec;
begin
//  NLOfs := 0;
 // hSrc := 0;
  FSrcFiles := Nil;
  SFRMain := Nil;
  SFRP := @FSrcFiles;
  while (Tag = drSrc) or (Tag = drRes) or (Tag = drObj) or (Tag = drAsm) or (Ver >= verD2010) and (Ver < verK1) and (Tag = drUnitInlineSrc) or (Ver >= verD2005) and (Ver < verK1) and IsMSIL and (Tag = drAssemblyInfo) or
    {(Ver=verD8)and(Ver<verK1)and} IsMSIL and (Tag = drAssemblySrc) do
  begin
    New(SFR);
    SFR^.Next := Nil;
    SFRP^ := SFR;
    SFRP := @SFR^.Next;
    SFR^.Def := DefStart;
    SFR^.Lines := Nil;
    if Tag = drAssemblyInfo then
    begin
      ReadNDXStr;
      SFR^.FT := 0;
      SFR^.Ndx := 0;
    end
    else
    begin
      ReadName;
      SFR^.FT := ReadULong;
      F := ReadUIndex;
      if F = 0 then
        SFRMain := SFR;
      SFR^.Ndx := F;
      if IsMSIL and (Tag <> drRes) and (Tag <> drAssemblySrc) then
      begin
        SrcFName := ReadStr; //Ignored by now, because it's always empty
      end;
    end;
    Tag := ReadTag;
  end;
  if FSrcFiles = Nil then
  begin
    if not FromPackage then
      DCUError('No source files');
  end;
  if SFRMain = Nil{Paranoic} then
    SFRMain := FSrcFiles;
  if (SFRMain = Nil) or (SFRMain^.Def^.Tag in [drAssemblyInfo, drAssemblySrc]) then
  begin
    FUnitName := ChangeFileExt(ExtractFileNamePkg(FFName), '')
  end
  else
  begin
    FUnitName := ExtractFileNameAnySep(SFRMain^.Def^.Name.GetStr);
    SP := PChar(FUnitName);
    CP := StrRScan(SP, '.');
    if (CP <> Nil) and (CP > SP) then
      SetLength(FUnitName, CP - SP);
  end;
end;

procedure TUnit.ShowSourceFiles;
var
  SFR: PSrcFileRec;
  T: TDCURecTag;
begin
  PutKWSp('unit');
  PutSFmt('%s;', [FUnitName]);
  OpenAux;
  if Ver > verD2 then
  begin
    PutSpace;
    RemOpen;
    PutSFmt('Flags: 0x%x', [FFlags]);
    if Ver > verD3 then
      PutSFmt(', Priority: 0x%x', [FUnitPrior]);
    RemClose;
  end;
  CloseAux;
  NL;
  RemOpen;
  NL;
  PutSFmt('Compiled by %s', [VersionStr]);
  NL;
  PutSFmt('Decompiled by DCU32INT %s', [GetFileVersionStr]);
  NL;
  if FSrcFiles <> Nil then
  begin
    PutS('Source files:');
    Writer.NLOfs := 2;
    SFR := FSrcFiles;
    NL;
    while true do
    begin
      T := SFR^.Def^.Tag;
      case T of
        drObj:
          PutS('$L ');
        drRes:
          PutS('$R ');
        drAssemblyInfo:
          PutS('$Assembly ');
        drAssemblySrc:
          PutS('$Assembly8 ');
      end;
      if T = drAssemblyInfo then
        PutS(GetNDXStr(@SFR^.Def^.Name))
      else
        PutS(SFR^.Def^.Name.GetStr);
      if (integer(SFR^.FT) <> -1) and (integer(SFR^.FT) <> 0) then
        PutSFmt(' (%s)', [FileDateToStr(SFR^.FT)]);
      SFR := SFR^.Next;
      if SFR = Nil then
        Break;
      PutS(',' + cSoftNL)
    end;
  end;
  RemClose;
  Writer.NLOfs := 0;
  NL;
  NL;
end;

function TUnit.ShowUses(PfxS: AnsiString; FRq: TUnitImpFlags): boolean;
var
  i, Cnt, hImp: integer;
  U: PUnitImpRec;
  Decl: TBaseDef;
  NLOfs0: Cardinal;
begin
  Result := false;
  if FUnitImp.Count = 0 then
    Exit;
  Cnt := 0;
  NLOfs0 := Writer.NLOfs;
  for i := 0 to FUnitImp.Count - 1 do
  begin
    U := FUnitImp[i];
    if FRq <> U.Flags then
      Continue;
    if Cnt > 0 then
      PutCh(',')
    else
    begin
      NL;
      PutKW(PfxS);
      ShiftNLOfs(2);
    end;
    NL;
    PutS(U^.Name^.GetStr);
    if U^.Ref.sPackage <> '' then
    begin
      RemOpen;
      PutS(U^.Ref.sPackage);
      RemClose;
    end;
    Inc(Cnt);
    if ShowImpNames then
    begin
      Decl := U^.Decls;
      hImp := 0;
      while Decl <> Nil do
      begin
        if hImp > 0 then
        begin
          PutCh(',');
          SoftNL;
        end
        else
        begin
          PutSpace;
          RemOpen;
          ShiftNLOfs(2);
          NL;
        end;
  //      PutSFmt('%s%x: %s',[Ch,NDX,ImpN^]);
  //      PutSFmt('%s%x: ',[Ch,NDX]);
        MarkDefStart(Decl.hDecl);
        Decl.Show;
        Inc(hImp);
        Decl := Decl.Next as TBaseDef;
      end;
      if hImp > 0 then
      begin
        RemClose;
        ShiftNLOfs(-2);
      end;
    end;
  end;
  Writer.NLOfs := NLOfs0;
  Result := Cnt > 0;
  if Result then
    PutCh(';');
end;

procedure TUnit.ReadUses(TagRq: TDCURecTag);
var
  hUses, hImp, hPack: integer;
  UseName: PName;
  ImpN: PName;
  //B: Byte;
  RTTISz: Cardinal;
  L, L1, L2: LongInt;
  Ch: AnsiChar;
  hUnit: integer;
  U: PUnitImpRec;
  TR, AR: TBaseDef;
  IR: TImpDef;
  UIR: TUnitImpDef;
  DeclEnd: ^TBaseDef;
//  TypesEnd,AddrsEnd: ^TBaseDef;
  NDX, ImpBase, ImpBase0, ImpReBase: integer;
begin
  hUses := 0;
  ImpBase := 0;
  while Tag = TagRq do
  begin
    UseName := ReadName;
    {if hUses>0 then
      PutCh(',')
    else begin
      PutS('uses');
      NLOfs := 2;
    end ;
    NL;
    PutS(UseName^);}
    New(U);
    FillChar(U^, SizeOf(TUnitImpRec), 0);
    U^.Name := UseName;
    Ch := '?';
    case TagRq of
      drUnit1:
        begin
          Ch := 'U';
          U^.Flags := [ufImpl];
        end;
      drDLL:
        begin
          Ch := 'D';
          U^.Flags := [ufDLL];
        end;
    end;
    hUnit := FUnitImp.Count;
    FUnitImp.Add(U);
    hPack := 0;
    if (TagRq <> drDLL) and (Ver >= verD8) and (Ver < verK1) then
      hPack := ReadUIndex;
    if (Ver >= verD2006) and (Ver < verK1) then
      L := ReadUIndex
    else
      L := ReadULong;
    //if (Ver>=verD7)and(Ver<verK1) then begin
    if (Ver = verD7) and (Ver < verK1) or (Ver >= verD8) and (Ver < verK1) and (TagRq = drDLL) then
    begin
      L1 := ReadULong;
    end;
    if (Ver >= verD2009) and (Ver < verK1) then
      L2 := ReadUIndex;
    {TypesEnd := @U^.Types;
    AddrsEnd := @U^.Addrs;}
    DeclEnd := @U^.Decls;
    hImp := 0;
    UIR := TUnitImpDef.Create(Ch, UseName, L, Nil{DefStart}, hUnit) {Unit reference};
    U^.Ref := UIR;
    ImpBase0 := ImpBase;
    ImpBase := AddAddrDef(UIR); //FAddrs.Add(IR);
    if (hPack > 0) and (Ver < verD2009{or may be MSIL only}) then
      RefAddrDef(hPack); //Reserve index for unit package number
    while true do
    begin
      Tag := ReadTag;
      case Tag of
        drImpType, drImpTypeDef:
          if TagRq <> drDLL then
          begin
            Ch := 'T';
            ImpN := ReadName;
            if Tag = drImpTypeDef then
            begin
            //B := ReadByte;
              RTTISz := ReadUIndex;
            {ImpN := Format('%s[%d]',[ImpN,B]);}
            end;
            L := ReadULong;
            if Tag = drImpTypeDef then
              TR := TImpTypeDefRec.Create(ImpN, L, RTTISz{B}, Nil{DefStart}, hUnit)
            else
              TR := TImpDef.Create('T', ImpN, L, Nil{DefStart}, hUnit);
          {TypesEnd^ := TR;
          TypesEnd := @TR.Next;}
            FTypes.Add(TR);
            TR.hDecl := AddAddrDef(TR); //FAddrs.Add(TR); {TypeInfo}

            ndx := FTypes.Count;
            FTypeDefCnt := ndx;
          end;
        drImpVal:
          begin
            Ch := 'A';
            ImpN := ReadName;
            L := ReadULong;
            if TagRq <> drDLL then
              AR := TImpDef.Create('A', ImpN, L, Nil{DefStart}, hUnit)
            else
              AR := TDLLImpRec.Create(ImpN, L, Nil, hUnit);
          {AddrsEnd^ := AR;
          AddrsEnd := @AR.Next;}
            ndx := AddAddrDef(AR); //FAddrs.Add(AR);
            AR.hDecl := ndx;
          //ndx := FAddrs.Count;
            TR := AR;
          end;
        drStop2:
          begin
         //Imports drConstAddInfo may be for the prev. drImpVal always
            L := -1;
            if (Ver >= verD8) and (Ver < verK1) then
              L := ReadULong; //==IP for the imported drConstAddInfo
            Continue;
          end;
        drConstAddInfo:
          begin
            if (not IsMSIL) and not (Ver >= verD_110A) then // LiuXiao: D11.3 other info packed after uses unit name
              break;
            if hImp <> 0 then
              DCUErrorFmt('ConstAddInfo encountered for %s in subrecord #%d', [UseName, hImp]);
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
          end;
      else
        Break;
      end;
      DeclEnd^ := TR;
      DeclEnd := @TR.Next;
      Inc(hImp);
    end;
//    NLOfs := 2;
    if Tag <> drStop1 then
      DCUErrorFmt('Unexpected tag: 0x%x', [Byte(Tag)]);
(*    if hImp>0 then
      PutS('}');*)
    Inc(hUses);
    Tag := ReadTag;
    case Tag of
      drProcAddInfo: {The only tag by now, which was observed between imports}
        begin
          if not ((Ver >= verD7) and (ver < verK1)) then
            break;
          hImp := ReadIndex;
          SetProcAddInfo(hImp{,Nil});
          Tag := ReadTag;
        end;
    end;
  end;
end;

{ For ver70 or higher }
function TUnit.ReadUnitAddInfo: TUnitAddInfo;
{var
  Name: PName;
  CP: PChar;}
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
end;

procedure ChkListSize(L: TList; hDef: integer);
begin
  if hDef <= 0 then
    Exit;
  if hDef > L.Count then
  begin
    if hDef > L.Capacity then
      L.Capacity := (hDef * 3) div 2;
    L.Count := hDef;
  end;
end;

procedure TUnit.SetListDefName(L: TList; hDef, hDecl: integer; Name: PName);
var
  Def: TBaseDef;
begin
  if L = Nil then
    Exit;
  if hDef <= 0 then
    Exit;
  ChkListSize(L, hDef);
  Dec(hDef);
  Def := L[hDef];
  if Def = Nil then
  begin
    Def := TBaseDef.Create(Name, Nil, -1);
//    Def.Next := FDefs;
//    FDefs := Def;
    L[hDef] := Def;
    Def.hDecl := hDecl;
    Exit;
  end;
  if (Def.FName = Nil) then
    Def.FName := Name;
  if Def.hDecl = 0 then
    Def.hDecl := hDecl;
end;

procedure TUnit.AddTypeName(hDef, hDecl: integer; Name: PName);
begin
  SetListDefName(FTypes, hDef, hDecl, Name);
end;

procedure TUnit.AddTypeDef(TD: TTypeDef);
var
  Def: TBaseDef;
begin
  ChkListSize(FTypes, FTypeDefCnt + 1);
  Def := FTypes[FTypeDefCnt];
  if Def <> Nil then
  begin
    if (Def.Def <> Nil) then
      DCUErrorFmt('Type def #%x override', [FTypeDefCnt + 1]);
    if (Def.hUnit <> TD.hUnit) then
      DCUErrorFmt('Type def #%x unit mismatch', [FTypeDefCnt + 1]);
    TD.FName := Def.Name;
    TD.hDecl := Def.hDecl;
    Def.FName := Nil;
    Def.Free;
  end;
  FTypes[FTypeDefCnt] := TD;
  TD.FhDT := FTypeDefCnt;
  Inc(FTypeDefCnt);
end;

procedure TUnit.ClearLastTypeDef(TD: TTypeDef);
//This procedure is called from TTypeDef.Destroy, and required when
//Destroy is called due to errors in Create
begin
  if FLoaded or (FTypeDefCnt <= 0) then
    Exit;
  if FTypes[TD.FhDT{FTypeDefCnt-1}] = TD then
    FTypes[TD.FhDT{FTypeDefCnt-1}] := Nil;
    //Dec(FTypeDefCnt);
end;

procedure TUnit.ClearAddrDef(ND: TNameDecl);
var
  hDecl: integer;
begin
  if FLoaded then
    Exit;
  if FAddrs = Nil then
    Exit;
  hDecl := ND.hDecl - 1;
  if (hDecl < 0) or (hDecl >= FAddrs.Count) then
    Exit;
  if FAddrs[hDecl] = ND then
    FAddrs[hDecl] := Nil;
end;

{
procedure TUnit.AddAddrName(hDef: integer; Name: PName);
begin
  SetListDefName(FAddrs,hDef,Name);
end ;
}
function TUnit.AddAddrDef(ND: TDCURec): integer;
const
  sQ: string[1] = '?';
var
  NP: PName;
begin
  if (FhNextAddr > 0) then
  begin
    Result := FhNextAddr;
    if Result > FAddrs.Count then
      DCUErrorFmt('ProcAddInfo Value 0x%x>FAddrs.Count=0x%x', [Result, FAddrs.Count]);
    if FAddrs[Result - 1] <> Nil then
    begin
      NP := TDCURec(FAddrs[Result - 1]).GetName;
      if NP = Nil then
        NP := @sQ;
      DCUErrorFmt('FAddrs[0x%x] already used by %s', [Result, NP^.GetStr]);
    end;
    FAddrs[Result - 1] := ND;
   (*
    if (Ver>=verD_XE)and(Ver<verD_XE3{the counterexample was found in System.Generics.Collections})and(Ver<verK1) then
      FhNextAddr := -1 //It looks like they have added this rule, but still include
        //sometimes drProcAddInfo records with -1
    else*)
    Inc(FhNextAddr);
    Exit;
  end;
  FAddrs.Add(ND);
  Result := FAddrs.Count;
end;

function TUnit.AppendAddrDef(ND: TDCURec): integer;
//To the end of list - for TCopyDecl
begin
  FAddrs.Add(ND);
  Result := FAddrs.Count;
end;

procedure TUnit.RefAddrDef(V: integer);
{This procedure is used for addrs, which may be forward references to the objects,
which don't yet exist. To fill the empty slot the drProcAddInfo tag is used after
creation of the object. }
begin
  if V > FAddrs.Count then
  begin
    if V <> FAddrs.Count + 1 then
      DCUErrorFmt('Unexpected forward hDecl=0x%x<>0x%x', [V, FAddrs.Count + 1]);
    FAddrs.Add(Nil); //This way it won't interfere with FhNextAddr
    {AddAddrDef(Nil);} //Reserve addr index, which will be claimed by drProcAddInfo
  end;
end;

procedure TUnit.SetDeclMem(hDef: integer; Ofs, Sz: Cardinal);
var
  D: TDCURec;
  Base, Rest: Cardinal;
begin
  if (hDef <= 0) or (hDef > FAddrs.Count) then
    DCUErrorFmt('Undefined Fixup Declaration: #%x', [hDef]);
  D := FAddrs[hDef - 1];
  Base := 0;
  while (D <> Nil) do
  begin
    if D is TProcDecl then
      TProcDecl(D).AddrBase := Base;
    Rest := D.SetMem(Ofs + Base, Sz - Base);
    if integer(Rest) <= 0 then
      Break;
    Base := Sz - Rest;
    D := D.Next {Next declaration - should be procedure};
  end;
end;

function TUnit.GetTypeDef(hDef: integer): TTypeDef;
begin
  Result := Nil;
  if (hDef <= 0) or (hDef > FTypes.Count) then
    Exit;
  Result := FTypes[hDef - 1];
end;

function TUnit.GetTypeName(hDef: integer): PName;
var
  D: TTypeDef;
begin
  Result := Nil;
  D := GetTypeDef(hDef);
  if D = Nil then
    Exit;
  Result := D.FName;
end;

function TUnit.GetAddrCount: Integer;
begin
  Result := FAddrs.Count;
end;

function TUnit.GetTypeCount: Integer;
begin
  Result := FTypes.Count;
end;

function TUnit.GetAddrDef(hDef: integer): TDCURec;
begin
  if (hDef <= 0) or (hDef > FAddrs.Count) then
    Result := Nil
  else
    Result := FAddrs[hDef - 1];
end;

function TUnit.GetAddrName(hDef: integer): PName;
var
  D: TDCURec;
begin
  Result := @NoName;
  D := GetAddrDef(hDef);
  if D = Nil then
    Exit;
  Result := D.Name;
end;

function TUnit.GetAddrStr(hDef: integer; ShowNDX: boolean): AnsiString;
begin
  Result := GetDCURecStr(GetAddrDef(hDef), hDef, ShowNDX);
end;

procedure TUnit.PutAddrStr(hDef: integer; ShowNDX: boolean);
begin
  PutDCURecStr(GetAddrDef(hDef), hDef, ShowNDX);
end;

procedure TUnit.PutAddrStrRmClassName(hDef: integer; ShowNDX: boolean);
begin
  PutDCURecStr(GetAddrDef(hDef), hDef, ShowNDX);
end;

function TUnit.IsValidMemPtr(DP: Pointer): Boolean;
begin
  Result := (TIncPtr(DP) >= TIncPtr(FMemPtr)) and (TIncPtr(DP) < TIncPtr(FMemPtr) + FMemSize);
end;

function TUnit.GetLocalTypeDef(hDef: integer): TTypeDef;
//The type should be from this unit
var
  D: TBaseDef;
begin
  D := GetTypeDef(hDef);
  if (D is TTypeDef) then
    Result := TTypeDef(D)
  else //TImpDef
    Result := Nil;
end;

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
    if D = Nil then
      Exit;
    if (D is TTypeDef) then
      Break {Found - Ok};
    if not (D is TImpDef) then
      Exit;
    if (D is TImpTypeDefRec) then
    begin
      hUnit := TImpTypeDefRec(D).hImpUnit;
      N := TImpTypeDefRec(D).ImpName;
    end
    else
    begin
      hUnit := TImpDef(D).hUnit;
      N := TImpDef(D).Name;
    end;
    {imported value}
    U := U.GetUnitImp(hUnit);
    if U = Nil then
    begin
      U := Self;
      Exit;
    end;
    D := U.ExportTypes[N^.GetStr, TImpDef(D).Inf];
  until false;
  Result := TTypeDef(D);
end;

function TUnit.GetGlobalAddrDef(hDef: integer; var U: TUnit): TDCURec;
var
  D: TDCURec;
begin
  Result := Nil;
  U := Self;
  D := GetAddrDef(hDef);
  if D = Nil then
    Exit;
  if (D is TImpDef) then
  begin
    {imported value}
    U := GetUnitImp(TImpDef(D).hUnit);
    if U = Nil then
    begin
      U := Self;
      Exit;
    end;
    D := U.ExportDecls[TImpDef(D).Name^.GetStr, TImpDef(D).Inf];
  end;
  Result := D;
end;

function TUnit.GetTypeSize(hDef: integer): integer;
var
  T: TTypeDef;
  U: TUnit;
begin
  Result := -1;
  T := GetGlobalTypeDef(hDef, U);
  if T = Nil then
    Exit;
  Result := T.Sz;
end;

function TUnit.ShowTypeValue(T: TTypeDef; DP: Pointer; DS: Cardinal; ConstKind: Integer): integer {Size used};
var
  U0: TUnit;
  MS: TFixupMemState;
  E: Extended;
begin
  if T = Nil then
  begin
    Result := -1;
    Exit;
  end;
  U0 := CurUnit;
  CurUnit := Self;
  if ConstKind >= 0{IsConst} then
  begin
    SaveFixupMemState(MS);
    SetCodeRange(DP, DP, DS);
  end;
  try
    if (ConstKind >= 0{IsConst}) and (T is TStringDef) then
    begin
      if (Ver >= verD2009) and (Ver < verK1) then
      begin
        if ConstKind = 2 then
          Result := ShowUnicodeResStrConst(DP, DS)
        else
          Result := ShowUnicodeStrConst(DP, DS)
      end
      else
        Result := ShowStrConst(DP, DS)
    end
    else if (ConstKind = 3{float}) and (T is TFloatDef) and (DS = SizeOf(Extended)) then
    begin
      E := Extended(DP^);
      if TFloatDef(T).Kind = fkCurrency then
        E := E * 0.0001;
      PutS(FixFloatToStr(E)); //PutsFmt('%g',[E]); starting from D7 writes 3 digits after E
      Result := SizeOf(Extended);
    end
    else
      Result := T.ShowValue(DP, DS);
  finally
    if ConstKind >= 0{IsConst} then
      RestoreFixupMemState(MS);
    CurUnit := U0;
  end;
end;

function TUnit.ShowGlobalTypeValue(hDef: TNDX; DP: Pointer; DS: Cardinal; AndRest: boolean; ConstKind: Integer): integer {Size used};
var
  T: TTypeDef;
  U: TUnit;
  SzShown: integer;
  //FOfs0: PChar;
begin
  if DP = Nil then
  begin
    Result := -1;
    Exit;
  end;
  T := GetGlobalTypeDef(hDef, U);
  Result := U.ShowTypeValue(T, DP, DS, ConstKind);
  if not AndRest then
    Exit;
  SzShown := Result;
  if SzShown < 0 then
    SzShown := 0;
  if SzShown >= DS then
    Exit;
  NL;
  ShowDataBlP(DP, DS, SzShown);
 (*
  if (PChar(DP)>=FDataBlPtr)and(PChar(DP)<FDataBlPtr+FDataBlSize) then
    {CurUnit.}ShowDataBl(SzShown,PChar(DP)-FDataBlPtr,DS)
  else begin
    NL;
    {FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;}
    ShowDump(DP,FMemPtr{FOfs0},FMemSize,0,DS,SzShown,SzShown,0,0,Nil,false,ShowFileOffsets);
  end ;
  *)
end;

function TUnit.ShowGlobalConstValue(hDef: integer): boolean;
var
  D: TDCURec;
  U, U0: TUnit;
begin
  Result := false;
  D := GetGlobalAddrDef(hDef, U);
  if (D = Nil) or not (D is TConstDecl) then
    Exit;
  U0 := CurUnit;
  CurUnit := U;
  try
    TConstDecl(D).Value.Show;
  finally
    CurUnit := U0;
  end;
  Result := true;
end;

function TUnit.GetOfsQualifier(hDef: integer; Ofs: integer): AnsiString;
begin
  GetOfsQualifierEx(hDef, Ofs, 0{any QSz}, Nil{QI}, @Result);
end;

function TUnit.GetOfsQualifierEx(hDef: integer; Ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): Boolean;
var
  U, U0: TUnit;
  TD: TTypeDef;
begin
  if QS <> Nil then
    QS^ := '';
  {if Ofs=0 then
    Exit; Let it will show the 1st field too}
  if QI <> Nil then
  begin
    QI^.U := Self;
    QI^.hDT := hDef;
    QI^.hDTAddr := -1;
    QI^.OfsRest := Ofs;
    QI^.IsVMT := false;
  end;
  TD := GetGlobalTypeDef(hDef, U);
  if TD = Nil then
  begin
    if QS <> Nil then
    begin
      if Ofs > 0 then
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('+%d', [Ofs])
      else if Ofs < 0 then
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%d', [Ofs]);
    end;
    Result := Ofs >= 0;
    Exit;
  end;
  U0 := CurUnit;
  CurUnit := U;
  try
    Result := TD.GetOfsQualifierEx(Ofs, QSz, QI, QS);
  finally
    CurUnit := U0;
  end;
end;

function TUnit.GetRefOfsQualifier(hDef: integer; Ofs: integer): AnsiString;
begin
  GetRefOfsQualifierEx(hDef, Ofs, 0{any QSz}, Nil{QI}, @Result);
end;

function TUnit.GetRefOfsQualifierEx(hDef: integer; Ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): Boolean;
var
  U, U0: TUnit;
  TD: TTypeDef;
begin
  if QS <> Nil then
    QS^ := '';
  {if Ofs=0 then
    Exit;}
  if QI <> Nil then
  begin
    QI^.U := Self;
    QI^.hDT := -1;
    QI^.hDTAddr := -1;
    QI^.OfsRest := Ofs;
    QI^.IsVMT := false;
  end;
  TD := GetGlobalTypeDef(hDef, U);
  if TD = Nil then
  begin
    if QS <> Nil then
    begin
      if Ofs > 0 then
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('^+%d', [Ofs])
      else if Ofs < 0 then
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('^%d', [Ofs]);
    end;
    Result := Ofs >= 0;
    Exit;
  end;
  U0 := CurUnit;
  CurUnit := U;
  try
    Result := TD.GetRefOfsQualifierEx(Ofs, QSz, QI, QS);
  finally
    CurUnit := U0;
  end;
end;

procedure TUnit.ShowTypeDef(hDef: integer; N: PName);
var
  D: TBaseDef;
begin
  PutSFmtRemAux('T#%x', [hDef]);
  D := GetTypeDef(hDef);
  if D = Nil then
  begin
    PutCh('?');
    Exit;
  end;
  D.ShowNamed(N);
end;

function TUnit.ShowTypeName(hDef: integer): boolean;
var
  D: TBaseDef;
  N: PName;
begin
  Result := false;
  PutSFmtRemAux('T#%x', [hDef]);
  if (hDef <= 0) or (hDef > FTypes.Count) then
    Exit;
  D := FTypes[hDef - 1];
  if D = Nil then
    Exit;
  N := D.FName;
  if (N = Nil) or (N^.Get1stChar = #0) then
    Exit;
  D.ShowName;
  Result := true;
end;

function TUnit.TypeIsVoid(hDef: integer): boolean;
var
  D: TBaseDef;
begin
  Result := true;
  if (hDef <= 0) or (hDef > FTypes.Count) then
    Exit;
  D := FTypes[hDef - 1];
  if D = Nil then
    Exit;
  Result := D.ClassType = TVoidDef;
end;

function TUnit.GetUnitImpRec(hUnit: integer): PUnitImpRec;
begin
  Result := PUnitImpRec(FUnitImp[hUnit]);
end;

function TUnit.GetUnitImp(hUnit: integer): TUnit;
var
  UI: PUnitImpRec;
begin
  UI := GetUnitImpRec(hUnit);
  if UI = Nil then
  begin
    Result := Nil;
    Exit;
  end;
  Result := UI^.U;
  if Result <> Nil then
  begin
    if integer(Result) = -1 then
      Result := Nil;
    Exit;
  end;
  Result := GetDCUByName(UI^.Name^.GetStr, FFExt, Ver, FIsMSIL, FPlatform, UI^.Ref.Inf);
  if Result = Nil then
    integer(UI^.U) := -1
  else
    UI^.U := Result;
end;

procedure TUnit.SetExportNames(Decl: TDCURec{TNameDecl});
{var
  NDX: integer;}
begin
  FExportNames := TStringList.Create;
  FExportNames.Sorted := true;
  FExportNames.Duplicates := dupAccept{For overloaded functions} {dupError};
  while Decl <> Nil do
  begin
    if (Decl is TNameFDecl) and (TNameFDecl(Decl).F and $40 <> 0){Decl.IsVisible(dlMain) -
      it`s wrong, cause hides some names}
        then
    begin
//    if not FExportNames.Find(Decl.Name^,NDX) then
      FExportNames.AddObject(Decl.Name^.GetStr, Decl);
    end;
    Decl := Decl.Next {as TNameDecl};
  end;
end;

procedure TUnit.SetEnumConsts(var Decl: TDCURec{TNameDecl});
var
  LastConst: TConstDecl;
  ConstCnt, CMin, CMax, V: integer;
  HasEq: Boolean;
  D: TNameDecl;
  DeclP, LastConstP: ^TNameDecl;

  procedure FlushConsts;
  var
    TD: TTypeDef;
    Enum: TEnumDef;
    CP0: TScanState;
    Lo, Hi, V: integer;
    NT: TList;
  begin
    TD := GetLocalTypeDef(LastConst.Value.hDT);
    if (TD <> Nil) and (TD is TEnumDef) and (TEnumDef(TD).NameTbl = Nil) and (TD.hDecl >= LastConst.hDecl + ConstCnt) then
    begin
    {if (D is TTypeDecl) then begin
      TD := GetTypeDef(TTypeDecl(D).hDef);
      if (TD is TEnumDef) then begin}
      Enum := TEnumDef(TD);
       {Some paranoic tests:}
      ChangeScanState(CP0, Enum.LH, 18);
      Lo := ReadIndex;
      Hi := ReadIndex;
      RestoreScanState(CP0);
      if (Lo = CMin) and (Hi = CMax){(Lo=0)and(ConstCnt=Hi+1)} then
      begin
        LastConstP^ := D;
        DeclP^ := Nil;
        DeclP := LastConstP;
        Enum.CStart := LastConst;
        if ConstCnt + 100 > Hi - Lo then
        begin
          NT := TList.Create;
          NT.Count{Capacity}  := Hi - Lo + 1{ConstCnt};
          while LastConst <> Nil do
          begin
              //NT.Add(LastConst);
            V := LastConst.Value.Val - Lo;
            if NT[V] = Nil then
              NT[V] := LastConst;
            LastConst := TConstDecl(LastConst.Next);
          end;
          Enum.NameTbl := NT;
        end;
      end;
      {end ;}
    end;
    LastConst := Nil;
    ConstCnt := 0;
  end;

begin
  DeclP := @Decl;
  LastConstP := Nil;
  LastConst := Nil;
  ConstCnt := 0;
  HasEq := false;
  while DeclP^ <> Nil do
  begin
    D := DeclP^;
    if (D is TConstDecl) and (TConstDecl(D).Value.ValSz = 0{The enumerated consts use values defined by TNDXB1}) then
    begin
      if (LastConst <> Nil) and (LastConst.Value.hDT = TConstDecl(D).Value.hDT) then
      begin
        V := TConstDecl(D).Value.Val;
        Inc(ConstCnt);
        if V <> CMax + 1 then
          HasEq := true;
        if V > CMax then
          CMax := V
        else if V < CMin then
          CMin := V;
      end
      else
      begin
        if LastConst <> Nil then
          FlushConsts;
        LastConstP := DeclP;
        LastConst := TConstDecl(D);
        ConstCnt := 1;
        HasEq := false;
        CMin := LastConst.Value.Val;
        CMax := LastConst.Value.Val;
      end;
    end
    else
    begin
      if LastConst <> Nil then
        FlushConsts;
    end;
    DeclP := @(D.Next);
  end;
end;

function TUnit.GetExportDecl(const Name: string; Stamp: integer): TNameFDecl;
var
  NDX: integer;
begin
  Result := Nil;
  if FExportNames = Nil then
    Exit;
  if not FExportNames.Find(Name, NDX) then
    Exit;
 //Find should return the 1st occurence of Name
 //now it is reqired to find the name by Stamp
  repeat
    Result := FExportNames.Objects[NDX] as TNameFDecl;
    if Stamp = 0 {The don't check Stamp value} then
      Exit;
    if (Result = Nil) then
      Exit;
    if (CompareText(FExportNames[NDX], Name) <> 0) then
    begin
      Result := Nil;
      Exit;
    end;
    if Result.Inf = Stamp then
      Break;
    Inc(NDX);
    if NDX >= FExportNames.Count then
    begin
      Result := Nil;
      Exit;
    end;
  until false;
end;

function TUnit.GetExportType(const Name: string; Stamp: integer): TTypeDef;
var
  ND: TNameDecl;
begin
  Result := Nil;
  ND := ExportDecls[Name, Stamp];
  if (ND = Nil) or not (ND is TTypeDecl) then
    Exit;
  Result := GetTypeDef(TTypeDecl(ND).hDef);
end;

procedure TUnit.LoadFixups;
var
  i: integer;
  CurOfs, PrevDeclOfs, dOfs: Cardinal;
  B1: Byte;
  FP: PFixupRec;
  hPrevDecl: integer;
begin
  if FFixupTbl <> Nil then
    DCUError('2nd fixup');
  FFixupCnt := ReadUIndex;
  FFixupTbl := AllocMem(FFixupCnt * SizeOf(TFixupRec));
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  for i := 0 to FFixupCnt - 1 do
  begin
    dOfs := ReadUIndex;
    Inc(CurOfs, dOfs);
    if (NDXHi <> 0) or (CurOfs > FDataBlSize) then
      DCUErrorFmt('Fixup offset 0x%x>Block size = 0x%x', [CurOfs, FDataBlSize]);
    B1 := ReadByte;
    FP^.OfsF := (CurOfs and FixOfsMask) or (B1 shl 24);
    FP^.NDX := ReadUIndex;
    Inc(FP);
  end;
 {After loading fixups set the memory sizes of CBlock parts}
  CurOfs := 0;
  FP := Pointer(FFixupTbl);
  hPrevDecl := 0;
  PrevDeclOfs := 0;
  for i := 0 to FFixupCnt - 1 do
  begin
    CurOfs := FP^.OfsF and FixOfsMask;
    B1 := TByte4(FP^.OfsF)[3];
    if (B1 = fxStart) or (B1 = fxEnd) then
    begin
      if hPrevDecl > 0 then
        CurUnit.SetDeclMem(hPrevDecl, PrevDeclOfs, CurOfs - PrevDeclOfs);
      hPrevDecl := FP^.NDX;
      PrevDeclOfs := CurOfs;
      FDataBlOfs := CurOfs;
    end;
    Inc(FP);
  end;
end;

procedure TUnit.LoadCodeLines;
var
  i, CurL, dL: integer;
  CR: PCodeLineRec;
  CurOfs, dOfs: Cardinal;
begin
  if FCodeLineTbl <> Nil then
    DCUError('2nd Code Lines table');
  FCodeLineCnt := ReadUIndex;
  FCodeLineTbl := AllocMem(FCodeLineCnt * SizeOf(TCodeLineRec));
  CurL := 0;
  CurOfs := 0;
  CR := Pointer(FCodeLineTbl);
  for i := 0 to FCodeLineCnt - 1 do
  begin
    dL := ReadIndex;
    dOfs := ReadUIndex;
    Inc(CurOfs, dOfs);
    Inc(CurL, dL);
    if not FromPackage and ((NDXHi <> 0) or (CurOfs > FDataBlSize)) then
      DCUErrorFmt('Code line offset 0x%x>Block size = 0x%x', [CurOfs, FDataBlSize]);
    {in the file debug\MidasLib.dcu of D2009 (which was compiled from a lot of C
     and H files) the records 17291..82826 (exactly $10000 recs)
     contain dL=0, dOfs=$FFFF. The same file in D2010 doesn't contain such records.
     So i believe it's a bug of D2009 and won't fix it}
    CR^.Ofs := CurOfs;
    CR^.L := CurL;
    Inc(CR);
  end;
end;

function TUnit.GetSrcFile(N: integer): PSrcFileRec;
begin
  Result := FSrcFiles;
  while Result <> Nil do
  begin
    if Result^.NDX = N then
      Exit;
    Result := Result^.Next;
  end;
  {while (N>0)and(Result<>Nil) do begin
    Result := Result^.Next;
    Dec(N);
  end ;}
end;

procedure TUnit.LoadLineRanges;
var
  i: integer;
  LR: PLineRangeRec;
  hFile, Num: integer;
begin
  if FLineRangeTbl <> Nil then
    DCUError('2nd Line Ranges table');
  FLineRangeCnt := ReadUIndex;
  FLineRangeTbl := AllocMem(FLineRangeCnt * SizeOf(TLineRangeRec));
  LR := Pointer(FLineRangeTbl);
  Num := 0;
  for i := 0 to FLineRangeCnt - 1 do
  begin
    LR^.Line0 := ReadUIndex;
    LR^.LineNum := ReadUIndex;
    LR^.Num0 := Num;
    Inc(Num, LR^.LineNum);
    hFile := ReadUIndex;
   // if not FromPackage then begin
    LR^.SrcF := GetSrcFile(hFile);
    if (LR^.SrcF = Nil) then
      DCUErrorFmt('Source file number %d is out of range', [hFile]);
   // end ;
    Inc(LR);
  end;
end;

procedure TUnit.LoadStrucScope;
{In fact just skip them by now}
var
  Cnt, i: integer;
begin
  Cnt := ReadUIndex;
  for i := 1 to Cnt * 5 do
    ReadUIndex; {(hType,hVar,Ofs,LnStart,LnCnt}
end;

procedure TUnit.LoadSymbolInfo;
{In fact just skip it by now}
var
  Cnt, NPrimary, i, j: integer;
  hSym, hMember, //for symbols - type members, else - 0
Sz, hDef: integer; //index of symbol definition in the L array
begin
  Cnt := ReadUIndex;
  NPrimary := ReadUIndex;
  for i := 1 to Cnt do
  begin
    hSym := ReadUIndex;
    hMember := ReadUIndex;
    Sz := ReadUIndex;
    hDef := ReadUIndex;
    for j := 1 to Sz do
      ReadUIndex;
  end;
end;

procedure TUnit.LoadLocVarTbl;
var
  i, Sz, ProcRec, F: integer;
  LR: PLocVarRec;
  Sym: Integer;
  D: TDCURec;
begin
  if FLocVarTbl <> Nil then
    DCUError('2nd Local Vars table');
  FLocVarCnt := ReadUIndex;
  FLocVarSize := FLocVarCnt;
  if platform <> dcuplWin64 then
  begin
    FLocVarTbl := AllocMem(FLocVarSize * SizeOf(TLocVarRec));
    LR := Pointer(FLocVarTbl);
    for i := 0 to FLocVarCnt - 1 do
    begin
      LR^.sym := ReadUIndex;
      LR^.ofs := ReadUIndex;
      LR^.frame := ReadIndex;
      Inc(LR);
    end;
  end
  else
  begin
   //They write additional record in 64-bit mode for each procedure
   //without fixing FLocVarCnt
    FLocVarSize := (FLocVarCnt * 3) div 2;
    FLocVarTbl := AllocMem(FLocVarSize * SizeOf(TLocVarRec));
    LR := Pointer(FLocVarTbl);
    ProcRec := 0;
    i := 0;
    while i < FLocVarCnt do
    begin
      Sym := ReadUIndex;
      if ProcRec = 0 then
        if Sym <> 0 then
        begin
          D := GetAddrDef(Sym);
          if D is TProcDecl then
          begin
            ProcRec := 3;
            Dec(i);
          end;
        end;
      LR^.sym := Sym;
      {if ProcRec>0 then
        F := ReadIndex
      else
        F := ReadUIndex;}
      LR^.ofs := ReadUIndex{F};
      if ProcRec > 1 then
        F := ReadUIndex
      else
        F := ReadIndex;
      LR^.frame := F;
      Inc(LR);
      Inc(i);
      if ProcRec > 0 then
        Dec(ProcRec);
    end;
    Sz := (TIncPtr(LR) - TIncPtr(FLocVarTbl)) div SizeOf(TLocVarRec);
    if FLocVarSize <> Sz then
    begin
      ReAllocMem(FLocVarTbl, FLocVarSize * SizeOf(TLocVarRec));
      FLocVarSize := Sz;
    end;
  end;
end;

function TUnit.GetStartFixup(Ofs: Cardinal): integer;
var
  i, iMin, iMax: integer;
  d: integer;
begin
  Result := 0;
  if (FFixupTbl = Nil) or (FFixupCnt = 0) then
    Exit;
  if Ofs = 0 then
    Exit;
  iMin := 0;
  iMax := FFixupCnt - 1;
  while iMin <= iMax do
  begin
    i := (iMin + iMax) div 2;
    D := FFixupTbl^[i].OfsF and FixOfsMask - Ofs;
    if D < 0 then
      iMin := i + 1
    else
      iMax := i - 1;
  end;
  Result := iMin;
end;
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
  while iStart < FFixupCnt do
  begin
    if FFixupTbl^[iStart].OfsF and FixOfsMask >= Ofs then
    begin
      Result := iStart;
      Exit;
    end;
    Inc(iStart);
  end;
  Result := FFixupCnt;
end;

procedure TUnit.SetStartFixupInfo(Fix0: integer);
begin
  SetFixupInfo(FFixupCnt - Fix0, @FFixupTbl^[Fix0], Self);
end;

function TUnit.GetStartCodeLine(Ofs: integer): integer;
var
  d, i, iMin, iMax: integer;
begin
  Result := FCodeLineCnt; //Not found
  iMin := 0;
  iMax := FCodeLineCnt - 1;
  while iMin <= iMax do
  begin
    i := (iMin + iMax) div 2;
    d := Ofs - FCodeLineTbl^[i].Ofs;
    if d > 0 then
      iMin := i + 1
    else
    begin
      Result := i;
      if D = 0 then
        Break;
      iMax := i - 1;
    end;
  end;
end;

procedure TUnit.GetCodeLineRec(i: integer; var CL: TCodeLineRec);
begin
  if i >= FCodeLineCnt then
  begin
    CL.Ofs := MaxInt;
    CL.L := MaxInt;
    Exit;
  end;
  CL := FCodeLineTbl^[i];
end;

function TUnit.GetStartLineRange(L: integer): integer;
var
  iMin, iMax: integer;
begin
  Result := 0;
  iMin := 0;
  iMax := FLineRangeCnt;
  while iMin < iMax do
  begin
    Result := (iMin + iMax) div 2;
    with FLineRangeTbl^[Result] do
      if Num0 + LineNum < L then
        iMin := Result + 1
      else if Num0 >= L then
        iMax := Result
      else
        Break;
  end;
end;

procedure TUnit.GetLineRange(i: integer; var LR: TLineRangeRec);
begin
  if i >= FLineRangeCnt then
  begin
    LR.Num0 := MaxInt;
    LR.LineNum := MaxInt;
    LR.SrcF := Nil;
    Exit;
  end;
  LR := FLineRangeTbl^[i];
  if (LR.SrcF <> Nil) and (LR.SrcF^.Lines = Nil) then
  begin
    LR.SrcF^.Lines := TStringList.Create;
    LoadSourceLines(LR.SrcF^.Def^.Name.GetStr, LR.SrcF^.Lines);
  end;
end;

procedure TUnit.SetUnitPackageInfo(hDecl: Integer; const sInfo: string);
var
  D: TDCURec;
begin
  D := GetAddrDef(hDecl);
  if (D = Nil) or not (D is TUnitImpDef) then
    Exit;
  TUnitImpDef(D).sPackage := sInfo;
end;

function TUnit.ReadConstAddInfo(LastProcDecl: TNameDecl): integer;

  procedure AddDefModifier(Def: TDCURec; M: TDeclModifier);
  begin
    if M = Nil then
      Exit;
    if (Def <> Nil) and (Def is TNameDecl) then
      TNameDecl(Def).AddModifier(M)
    else
      M.Free; //Just in case - shouldn`t happen
  end;

  procedure ReadAttributes(Def: TDCURec);
  //The compiler emit the information about declaration attributes starting from XE6
  //(the previous versions from D2010 just emitted links to the attribute classes)
  var
    N, i, ArgCnt, j: Integer;
    hAttrCtor, Z, hAttrDT: TNDX;
    ArgKind, hArgT, Kind, Sz, V: TNDX;
    hDT, hDTAddr: TNDX;
  begin
    N := ReadUIndex;
    for i := 1 to N do
    begin
      AddDefModifier(Def, TAttributeDeclModifier.Read);
      {hAttrCtor := ReadUIndex;
      RefAddrDef(hAttrCtor);
      Z := ReadUIndex;
      if Z<>0 then
        DCUError('Z<>0 in attribute'); //!!!remove it later
      hAttrDT := ReadUIndex;
      ArgCnt := ReadUIndex;
      for j := 1 to ArgCnt do begin
        ArgKind := ReadUIndex;
        case ArgKind of
         0: begin //const
           hArgT := ReadUIndex;
           Kind := ReadUIndex;
          //ReadConstVal:
           Sz := ReadUIndex;
           if Sz>0 then
             SkipBlock(Sz)
           else if Kind<>4 then
             V := ReadUIndex;
          end ;
         1: begin //TypeInfo(DT)
           hDT := ReadUIndex; //DT index in the type table
           hDTAddr := ReadUIndex; //DT index in the addr table
           RefAddrDef(hDTAddr);
          end ;
        else
          DCUErrorFmt('Unexpected argument kind: %d in attribute argument table',[ArgKind]);
        end;
      end ;}
    end;
  end;

var
  Tag, caiStop: byte;
  hDef, hDef1, hDef2, hDef3, hDef4, hDef5, hDT, F, IP, i, j: integer;
  V1, V2, V3, V4, V5, cafInline, cafBigVal: integer;
  Len, Len1, V, hUnit: Cardinal;
  hDef11, hDef12, hDef13, hDef14, hDef15: integer;
  IP2, IP3, Z: integer;
  S: AnsiString;
  Def: TDCURec;
begin
  Result := -1;
  if (Ver <= VerD7) or (Ver >= verK1) then
  begin
    caiStop := $06;
    {ReadByte; //01
    ReadUIndex;
    ReadByte; //02
    ReadByte; //06
    Exit;}
  end
  else
  begin
    caiStop := $0D;
    if Ver >= verD2005 then
    begin
      caiStop := $0F;
      if Ver >= verD2009 then
        caiStop := $FF; //$15;
    end;
  end;
  repeat
    Tag := ReadByte;
    if Tag >= caiStop then
      break; //check it before case to skip the tags for the higher versions
    case Tag of
      $01:
        begin
          Result := ReadUIndex;
          F := ReadUIndex;
          Def := GetAddrDef(Result);
          if (Def <> Nil) and (Def is TNameDecl) then
            TNameDecl(Def).ConstAddInfoFlags := F;
          if (Ver >= verD2006) and (Ver < verK1) and not (platform in [dcuplIOSEmulator, dcuplIOSDevice, dcuplAndroid]) then
          begin
            if F and $1000000 <> 0 then
              IP := ReadUIndex;
          end;
          if IsMSIL then
          begin
            if (Ver >= verD2005) then
            begin
              if F and $10000{or $20000, because F was = $30000} <> 0 then
              begin
                Len := ReadUIndex;
                SkipBlock(Len); //A C# code associated with Result
              end;
            end;
            Len := ReadUIndex;
            for i := 1 to Len do
            begin
              hDef := ReadUIndex;
              RefAddrDef(hDef);
              V := ReadUIndex;
              S := ReadNDXStr;
              if S <> '' then
              begin
                Len1 := ReadUIndex;
                for j := 1 to Len1 do
                begin
                  hDef1 := ReadUIndex;
                  RefAddrDef(hDef1); //Seems that it's required to reserve addr index
              // AddAddrDef(Nil);
                end;
              end;
            end;
          end;
          if (Ver >= verD2005) and (Ver < verK1) then
          begin
            cafInline := $80000;
            cafBigVal := $100000;
            if Ver >= verD2009 then
            begin
              if F and $800000 <> 0 then
                IP2 := ReadUIndex; //hUsedCl - Attribute class used for the declaration
              if F and $1 <> 0 then
              begin //Deprecated
                AddDefModifier(Def, TDeprecatedDeclModifier.Create(ReadNDXStrRef));
             {if (Def<>Nil)and(Def is TNameDecl) then
               TNameDecl(Def).AddModifier(TDeprecatedDeclModifier.Create(S));}
              end;
              if (Ver >= verD_XE6) and (F and $80000000 <> 0) then
                ReadAttributes(Def);
              cafInline := $40000;
              cafBigVal := $80000;
            end;
            if F and cafInline <> 0 then
            begin
           //Very complex structure - corresponds to the new (Ver>=8) inline directive
           //Fortunately, we can completely ignore all this info, because it is duplicated
           //as a regular procedure info even for inlines
              if (Ver >= verD2006) and (Ver < verK1) then
              begin
                ReadUIndex;
                ReadUIndex;
              end;
              Len := ReadUIndex;
              SkipBlock(Len * SizeOf(Byte));
              for i := 1 to 5 do
                ReadUIndex;
              if (CurUnit.Ver >= verD_XE2) and (CurUnit.Ver < verK1) then
                V := ReadUIndex;
              V := ReadUIndex;
           {if V<>2 then
             DCUError('V2<>2 in TConstAddInfoRec,Tag=1');}
              Len := ReadUIndex;
              if Ver >= verD2009 then
              begin
                ReadUIndex;
                ReadUIndex;
                Len1 := ReadUIndex;
                SkipBlock(Len1 * SizeOf(LongInt));
              end;
              for i := 1 to Len do
              begin
                V := ReadUIndex;
                if Ver >= verD2009 then
                begin
                  RefAddrDef(V); //Seems that it's required to reserve addr index (1)
                 //Same as (2), looks like the field was relocated
                  ReadUIndex;
                  ReadUIndex;
                end;
             {if V<>0 then
               DCUError('Z<>0 in TConstAddInfoRec,Tag=1,D1');}
                V := ReadUIndex;
                if Ver < verD2009 then
                  RefAddrDef(V); //Seems that it's required to reserve addr index (2)
                Z := ReadUIndex;
                if Ver >= verD2010 then
                  ReadUIndex;
                if (Ver >= verD2009) and (Z <> 0) then
                  ReadUIndex;
              end;
              Len := ReadUIndex;
              for i := 1 to Len do
              begin
                V := ReadUIndex;
             {if V<>4 then
               DCUError('V4<>4 in TConstAddInfoRec,Tag=1,D2');}
                if Ver >= verD2009 then
                begin
                  case V of
                    1:
                      begin
                        V := ReadUIndex;
                        if Ver >= verD_XE then //Perhaps it's required for lower versions too
                          RefAddrDef(V);
                        V := 1 + Ord(Ver >= verD_XE);
                      end;
                    2:
                      V := 1;
                    3:
                      V := 3;
                    4:
                      V := 2;
                    5:
                      V := 4;
                    6:
                      V := 1;
                  else
                    DCUErrorFmt('Unexpected TConstAddInfo.1 LF value: %d', [V]);
                  end;
                  for j := 1 to V do
                    ReadUIndex;
                end
                else
                  V := ReadUIndex;
              end;
              Len := ReadUIndex; //Number of units defs from which are used in this def
              for i := 1 to Len do
              begin
                hUnit := ReadUIndex;
                Len1 := ReadUIndex;
                for j := 1 to Len1 do
                begin
                  V := ReadUIndex;
                  if hUnit <> 0 then
                    Continue; //Import from another unit - don't care
                  RefAddrDef(V);
                end;
              end;
              if Ver >= verD2006 then
              begin
                Len := ReadUIndex;
                for i := 1 to Len do
                  ReadUIndex;
                if Ver >= verD2009 then
                begin
                  ReadUIndex;
                  V := ReadUIndex;
                  RefAddrDef(V); //AppMethod: System.Threading
                  ReadUIndex;
                end;
              end;
            end;
            if (Ver >= verD2005) and (F and cafBigVal <> 0) then
              IP := ReadUIndex;
        {
         if F and $100000<>0 then begin
           if (Ver>=verD2006)and(Ver<verK1) then begin
             Len := ReadUIndex;
             for i:=1 to Len do
               V := ReadUIndex;
           end ;
           IP := ReadUIndex;
         end ;}
         {if (Ver>=verD2006)and(Ver<verK1) then begin
           if F and $1000000<>0 then
             IP := ReadUIndex;
         end ;}
          end;
       //ToDo: In fact all the flags should be considered in the order of their values
        end;
      $04:
        begin
          if not ((Ver >= verD2006) and (Ver < verK1)) then
            break;
          V := ReadUindex;
          V := ReadUindex;
        end;
      $06:
        begin
          Result := ReadUindex;
          hDT := ReadUindex;
          V := ReadUindex;
          hDef1 := ReadUindex;
        end;
      $07:
        begin
          Result := ReadUindex;
          hDef1 := ReadUindex;
          hDef2 := ReadUindex;
          V := ReadUindex;
        end;
      $08:  // 08 Add by LiuXiao to Process 11.3 DCUs for new string such as comment after ///
        begin
          Result := ReadUIndex;
          V := ReadUIndex;
          SkipBlock(V);
        end;
      $09:
        begin
          Result := ReadUindex;
          hDT := ReadUindex;
        end;
      $0A:
        begin //Information about generated code (was observed in .NET units)
          Result := ReadUIndex;
          Def := GetAddrDef(Result);
          V := ReadUIndex;
          F := ReadUIndex;
          hDT := 0;
          if F and $01 <> 0 then
            hDT := ReadUIndex;
          hDef1 := 0;
          if F and $02 <> 0 then
            hDef1 := ReadUIndex;
          V2 := 0;
          if F and $04 <> 0 then
            V2 := ReadUIndex;
          V3 := 0;
          if F and $08 <> 0 then
            V3 := ReadUIndex;
          V4 := 0;
          if F and $10 <> 0 then
            V4 := ReadUIndex;
          hDef5 := 0;
          if F and $20 <> 0 then
            hDef5 := ReadUIndex;
          if F and $40 <> 0 then
          begin
            AddDefModifier(Def, TExtraArgsDeclModifier.Read);
         {Len := ReadUIndex;
         for i:=1 to Len do begin
           S := ReadNDXStr;
           V := ReadUIndex;
           V1 := ReadUIndex;
           hDT := ReadUIndex;
         end ;}
          end;
          if F and $80 <> 0 then
          begin
            V := ReadUIndex;
            V1 := ReadUIndex;
            V2 := ReadUIndex;
          end;
          if F and $100 <> 0 then
            AddDefModifier(Def, TGeneratedNameDeclModifier.Create(ReadNDXStrRef));
          if F and $200 <> 0 then
            S := ReadNDXStr;
          hDef11 := 0;
          if F and $400 <> 0 then
          begin
            hDef11 := ReadUIndex;
            if IsMSIL then
           //AddAddrDef(Nil);
              RefAddrDef(hDef11);
          end;
          hDef12 := 0;
          if F and $800 <> 0 then
          begin
            hDef12 := ReadUIndex;
            if IsMSIL then
              RefAddrDef(hDef12);
          end;
          hDef13 := 0;
          if F and $1000 <> 0 then
          begin
            hDef13 := ReadUIndex;
            if IsMSIL then
              RefAddrDef(hDef13);
          end;
          hDef14 := 0;
          if F and $2000 <> 0 then
          begin
            hDef14 := ReadUIndex;
            if IsMSIL then
              RefAddrDef(hDef14);
          end;
          hDef15 := 0;
          if F and $4000 <> 0 then
          begin
            hDef15 := ReadUIndex; //MSIL 9 only?
            if IsMSIL then
              RefAddrDef(hDef15);
          end;
        end;
      $0C:
        begin
          Result := ReadUIndex;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
        end;
      $0D:
        begin
          if (Ver < verD2005) or (Ver >= verK1) then
            break;
      //imported unit module information (FileName and version)?
          Result := ReadUIndex;
          S := ReadNDXStr;
          if IsMSIL then
            SetUnitPackageInfo(Result, S);
      // AddAddrDef(Nil); //Seems that it's required to reserve addr index
        end;
      $10:
        begin
          if (Ver < verD2009) or (Ver >= verK1) then
            break;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
          V3 := ReadUIndex;
        end;
      $11:
        begin //The record links explicitly links drStrConstRec to drVarC, which uses its memory
          if (Ver < verD_XE4) or (Ver >= verK1) then
            break;
          V1 := ReadUIndex;
          RefAddrDef(V1); //Seems that it's required to reserve addr index
          V2 := ReadUIndex;
          RefAddrDef(V2); //Seems that it's required to reserve addr index
        end;
      $12:
        begin
          if (Ver < verD2009) or (Ver >= verK1) then
            break;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
        end;
      $13:
        begin
          if (Ver < verD2009) or (Ver >= verK1) then
            break;
          V1 := ReadUIndex;
          RefAddrDef(V1); //Seems that it's required to reserve addr index
          V2 := ReadUIndex;
          V3 := ReadUIndex;
          S := ReadNDXStr; //$EXTERNALSYM
          S := ReadNDXStr; //??
          S := ReadNDXStr; //$OBJTYPENAME
        end;
      $14:
        begin
          if (Ver < verD2009) or (Ver >= verK1) then
            break;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
          Len := ReadUIndex;
          for i := 1 to Len do
          begin
            V1 := ReadUIndex;
            V2 := ReadUIndex;
            V3 := ReadUIndex;
            S := ReadNDXStr;
          end;
        end;
      $15:
        begin
          if (Ver < verD_XE2) or (Ver >= verK1) then
            break;
          V := ReadUIndex;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
        end;
      $16:  // 16 Add by LiuXiao to Process 11.3 DCUs for new info
        begin
          Result := ReadUIndex;
          V := ReadUIndex;
          SkipBlock(V);
        end;
      $17:  // 17 Add by LiuXiao to Process D12 DCUs for new info
        begin
          Result := ReadUIndex;
          V := ReadUIndex;
          V1 := ReadUIndex;
          V2 := ReadUIndex;
        end;
    else
      break;
    end;
  until false;
  if Tag <> caiStop then
    DCUErrorFmt('Unexpected Tag=0x%x in TConstAddInfoRec', [Tag]);
end;

procedure TUnit.SetProcAddInfo(V: integer{; LastProcDecl: TNameDecl});
begin
  if (V = -1{(B=$FE)}) then
  begin
    FhNextAddr := 0;
    {FAddrs[0] := LastProcDecl;
    FAddrs.Count := FAddrs.Count-1; //Initialization}
  end;
  if (V >= 1) and (Ver >= verD7) then
  begin
    {if V>FAddrs.Count then
      DCUErrorFmt('ProcAddInfo Value 0x%x>FAddrs.Count=0x%x',[V,FAddrs.Count]);
    if FAddrs[V-1]<>Nil then
      DCUErrorFmt('FAddrs[0x%x] already used',[V]);}
    FhNextAddr := V;
  end;
end;

function TUnit.FixTag(Tag: TDCURecTag): TDCURecTag;
begin
  Result := Tag;
  if (Ver >= verD2006) and (Ver < verK1) then
  begin
   //In D10 some codes were changed, we'll try to move them back
    if (Result >= $2D) and (Result <= $36) then
    begin
      Dec(Result);
      if Result < $2D then
        Result := $36; //This code could be wrong, but the overloaded value of $2D should be moved somewhere
    end;
  end;
end;

function TUnit.IncEmbedDepth(var HeadBuf: TDCURec{TNameDecl}): PTDCURec{PTNameDecl};
var
  i, Lim: Integer;
begin
  Inc(FEmbedDepth);
  if FEmbedDepth > FMaxEmbedDepth then
  begin
    FMaxEmbedDepth := FEmbedDepth;
    if FMaxEmbedDepth > FEmbedLimit then
    begin
      Lim := FMaxEmbedDepth * 2;
      if Lim < 16 then
        Lim := 16;
      ReallocMem(FEmbeddedLists, Lim * SizeOf(TEmbeddedListInf));
      for i := 0 to FEmbedLimit - 1 do
        with FEmbeddedLists^[i] do
          if List = Nil then
            ListEnd := @List;
      for i := FEmbedLimit to Lim - 1 do
        with FEmbeddedLists^[i] do
        begin
          List := Nil;
          ListEnd := @List;
        end;
      FEmbedLimit := Lim;
    end;
  end;
  with FEmbeddedLists^[FEmbedDepth - 1] do
  begin
    HeadBuf := List;
    if List = Nil then
      Result := @HeadBuf
    else
      Result := ListEnd;
  end;
end;

function TUnit.ConsumeEmbedded: TDCURec{TNameDecl};
begin
  Result := Nil;
  if (FMaxEmbedDepth > FEmbedLimit) or (FMaxEmbedDepth <= 0) or (FEmbedDepth >= FMaxEmbedDepth) then
    Exit;
  {if FEmbedDepth>=FMaxEmbedDepth then
    DCUErrorFmt('Surplus embedded list consumption %d..%d',[FEmbedDepth+1,FMaxEmbedDepth-1]);}
  if FEmbedDepth < FMaxEmbedDepth - 1 then
    DCUWarningFmt('Skipped embedded lists %d..%d', [FEmbedDepth + 1, FMaxEmbedDepth - 1]);
  {if FEmbedDepth<FMaxEmbedDepth-1 then
    DCUErrorFmt('Unused embedded lists %d..%d',[FEmbedDepth+1,FMaxEmbedDepth-1]);}
  Dec(FMaxEmbedDepth);
  with FEmbeddedLists^[FMaxEmbedDepth] do
  begin
    Result := List;
    List := Nil;
    ListEnd := @List;
  end;
end;

procedure TUnit.RegisterEmbeddedTypes(var Embedded: TDCURec{TNameDecl}; Depth: Integer);
{In Delphi XE DCU local data type`s declarations are placed out of the list of
procedure local declarations, and several types from different procedures could
be placed into one common list. Here we try to find the place where the type
should be}
var
  DP: PTDCURec;
  D: TDCURec;
  TD: TTypeDecl;
  TI: PEmbeddedTypeInf;
begin
  DP := @Embedded;
  while true do
  begin
    D := DP^;
    if D = Nil then
      Exit;
    if (D is TTypeDecl) then
    begin //The effect was noticed only for types
      TD := TTypeDecl(D);
      if FEmbeddedTypes = Nil then
        FEmbeddedTypes := TList.Create;
      ChkListSize(FEmbeddedTypes, TD.hDef);
      TI := PEmbeddedTypeInf(FEmbeddedTypes[TD.hDef - 1]);
      if TI = Nil then
      begin
        TI := AllocMem(SizeOf(TEmbeddedTypeInf));
        FEmbeddedTypes[TD.hDef - 1] := TI;
      end
      else if TI^.TD.hDecl > TD.hDecl then
        TI^.TD := Nil;
      if TI^.TD = Nil then
      begin
        TI^.TD := TD;
        TI^.Depth := Depth;
      end;
      DP^ := D.Next;
    end
    else
      DP := @D.Next;
  end;
end;

type
  TBindEmbeddedTypeInf = record
    EmbL, EmbeddedTypes: TList;
  end;

procedure BindEmbeddedType(UseRec: TDCURec; hDT: TDefNDX; IP: Pointer);
var
  TI: PEmbeddedTypeInf;
  TD: TTypeDecl;
  PD: TProcDecl;
begin
  with TBindEmbeddedTypeInf(IP^) do
  begin
    if (hDT <= 0) or (hDT > EmbeddedTypes.Count) then
      Exit;
    TI := PEmbeddedTypeInf(EmbeddedTypes[hDT - 1]);
    if TI = Nil then
      Exit;
    if TI^.Depth > EmbL.Count then
      Exit{Paranoic};
    EmbeddedTypes[hDT - 1] := Nil;
    PD := TProcDecl(EmbL[TI^.Depth - 1]);
    TD := TI^.TD;
    TD.Next := PD.Locals;
    PD.Locals := TD;
    FreeMem(TI);
    TD.EnumUsedTypes(BindEmbeddedType, IP);
  end;
end;

procedure TUnit.BindEmbeddedTypes;
var
  BindEmbeddedTypeInf: TBindEmbeddedTypeInf;

  procedure CheckProcedures(D: TDCURec);
  begin
    while D <> Nil do
    begin
      if D is TProcDecl then
      begin
        BindEmbeddedTypeInf.EmbL.Add(D);
        EnumUsedTypeList(TProcDecl(D).Locals, BindEmbeddedType, @BindEmbeddedTypeInf);
        EnumUsedTypeList(TProcDecl(D).Embedded, BindEmbeddedType, @BindEmbeddedTypeInf);
        CheckProcedures(TProcDecl(D).Embedded);
        BindEmbeddedTypeInf.EmbL.Count := BindEmbeddedTypeInf.EmbL.Count - 1;
      end;
      D := D.Next;
    end;
  end;

var
  i: Integer;
  TI: PEmbeddedTypeInf;
begin
  if FEmbeddedTypes = Nil then
    Exit;
  BindEmbeddedTypeInf.EmbL := TList.Create;
  BindEmbeddedTypeInf.EmbeddedTypes := FEmbeddedTypes;
  try
    CheckProcedures(FDecls);
  finally
    BindEmbeddedTypeInf.EmbL.Free;
   {Paranoic (shouldn't happen): show not bound types}
    for i := FEmbeddedTypes.Count - 1 downto 0 do
    begin
      TI := PEmbeddedTypeInf(FEmbeddedTypes[i]);
      if TI = Nil then
        Continue;
      TI^.TD.Next := FDecls;
      FDecls := TI^.TD;
      FreeMem(TI);
    end;
  end;
  FEmbeddedTypes.Free;
  FEmbeddedTypes := Nil;
end;

procedure TUnit.ReadDeclList(LK: TDeclListKind; var Result: TDCURec{TNameDecl});
var
  DeclEnd, EmbLEnd: PTDCURec{PTNameDecl};
  Decl, EmbedBuf, Rec: TDCURec;
  LastProcDecl: TNameDecl;
 // Embedded: TNameDecl;
 // B: Byte;
  i{,Cnt}: integer;
  V, X: TNDX;
  Tag1: TDCURecTag;
  EmbEndCnt: Integer;
begin
  Result := Nil;
  DeclEnd := @Result;
 // Embedded := Nil;
  LastProcDecl := Nil;
  //FhNextAddr := 0;
  EmbEndCnt := 0; //For MSIL and D2009up
  while true do
  begin
    Tag1 := FixTag(Tag);
    Decl := Nil;
    Rec := Nil;
    try
      case Tag1 of
        drType:
          Decl := TTypeDecl.Create(LK in [dlArgs, dlArgsT, {dlEmbedded,}dlFields, dlClass, dlInterface, dlDispInterface]{NoInf});
        drTypeP:
          Decl := TTypePDecl.Create;
        drConst:
          Decl := TConstDecl.Create;
        drResStr:
          Decl := TResStrDef.Create;
        drSysProc:
          if (Ver >= verD8) and (Ver < verK1) then
            Decl := TSysProc8Decl.Create
          else
            Decl := TSysProcDecl.Create;
        drProc:
          begin
            LastProcDecl := TProcDecl.Create(ConsumeEmbedded{Embedded}, false);
            Decl := LastProcDecl;
           //Embedded := Nil;
          end;
        drEmbeddedProcStart:
          begin
            if (IsMSIL or (Ver >= verD2009) and (Ver < verK1)) and (EmbEndCnt > 0) then
          //Escape up from parameter list processing for default values` consts
              Dec(EmbEndCnt) //Just ignore and continue
            else
            begin
              EmbLEnd := IncEmbedDepth(EmbedBuf);
              Tag := ReadTag;
              ReadDeclList(dlEmbedded, EmbLEnd^);
              Dec(FEmbedDepth);
              if Tag <> drEmbeddedProcEnd then
                TagError('Embedded Stop Tag');
              if (Ver >= verD_XE) and (Ver < verK1) then
            //try to fix the local types relocation problem of XE
                RegisterEmbeddedTypes(EmbLEnd^, FEmbedDepth + 1);
              if (EmbedBuf <> Nil) then
              begin
                if EmbLEnd = @EmbedBuf then
                  FEmbeddedLists^[FEmbedDepth].List := EmbedBuf;
                PTDCURec(EmbLEnd) := GetDCURecListEnd(TDCURec(EmbLEnd^));
                FEmbeddedLists^[FEmbedDepth].ListEnd := EmbLEnd;
              end;
            end;
        (*
           if (IsMSIL or(Ver>=verD2009)and(Ver<verK1))and WasEmbEnd then
             WasEmbEnd := false //Just ignore and continue
           else begin
             Inc(FEmbedDepth);
             if Embedded<>Nil then begin
               if not IsMSIL then
                 TagError('Duplicate embedded list');
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
             Dec(FEmbedDepth);
             if Tag<>drEmbeddedProcEnd then
               TagError('Embedded Stop Tag');
             if (Ver>=verD_XE)and(Ver<verK1) then
              //try to fix the local types relocation problem of XE
               RegisterEmbeddedTypes(Embedded,FEmbedDepth+1);
            {In DCU 6 for resourcestring declarations inside procs
             here follows the constant value instead of drProc
             Tag := ReadTag;
             if Tag<>drProc then
               TagError('Proc Tag');
             Decl := TProcDecl.Create(Embedded);}
           end ;
           *)
          end;
        drEmbeddedProcEnd:
          begin
            if not ((LK = dlArgsT) and (Ver > verD3) or (LK = dlArgs) and (Ver > verD3{verD5 was observed, but may be in prev ver. too})) then
              Break; {Temp. - this tag can mark the const definition used as an
           interface arg. default value and also as proc. arg. default value}
            if IsMSIL or (Ver >= verD2009) and (Ver < verK1) then
              Inc(EmbEndCnt); //For MSIL only. And Ver>=verD2009 too
             //drEmbeddedProcEnd - drEmbeddedProcStart mark block of const defs
             //In fact they mark escape up from the data type declaration place
             //(when escaping from a data type defined inside a top level or embedded procedure,
             //the depth of escapes increases).
             //We'll try to just ignore them
             //Beginning from D2009 they started to close the escapes by drEmbeddedProcEnd
             //before the stop tag
          end;
        drVar:
          case LK of
            dlArgs, dlArgsT:
              Decl := TLocalDecl.Create(LK);
          else
            if (LK = dlMain) and (CurUnit.Ver >= verD_XE2) and (CurUnit.platform = dcuplWin64) then
              Decl := TVarVDecl.Create
            else
              Decl := TVarDecl.Create;
          end;
        drThreadVar:
          Decl := TThreadVarDecl.Create;
        drExport:
          Decl := TExportDecl.Create;
        drVarC:
          Decl := TVarCDecl.Create(false{LK=dlMain});
        arVal, arVar, arResult, arFld:
          Decl := TLocalDecl.Create(LK);
        arAbsLocVar:
          case LK of
            dlMain, dlMainImpl:
              Decl := TAbsVarDecl.Create;
          else
            Decl := TLocalDecl.Create(LK);
          end;
        arLabel:
          Decl := TLabelDecl.Create;
        arMethod, arConstr, arDestr:
          Decl := TMethodDecl.Create(LK);
        arClassVar:
          begin
            if not ((Ver >= verD2006) and (Ver < verK1)) then
              break;
            Decl := TClassVarDecl.Create(LK);
          end;
        arProperty:
          if LK = dlDispInterface then
            Decl := TDispPropDecl.Create(LK)
          else
            Decl := TPropDecl.Create;
        arCDecl, arPascal, arStdCall, arSafeCall: {Skip it}
          ;
        arSetDeft:
          Decl := TSetDeftInfo.Create; //ReadULong{Skip it};
        drStop2:
          begin
            if (Ver >= verD8) and (Ver < verK1) then
              ReadULong;
          end;
 //        drVoid: Decl := TAtDecl.Create;{May be end of interface}
        drStrConstRec:
          begin
            if not ((Ver >= verD8) and (Ver < verK1)) then
              break;
         {TStrConstTypeDef.Create;}
            Decl := TStrConstDecl.Create;
        {//
         ReadStr;
         ReadUIndex;
         ReadUIndex;
         ReadUIndex;
         ReadUIndex;}
          end;
       {drAddInfo6: begin //Some structures of 4 indices
         if not((Ver>=verD10)and(Ver<verK1)) then
           break;
         Decl := TAddInfo6.Create;
        end ;}
        drSpecVar:
          begin //Memory allocation for class vars and so on
            if not ((Ver >= verD2006) and (Ver < verK1)) then
              break;
            Decl := TSpecVar.Create;
          end;

      {--------- Type definitions ---------}
        drRangeDef, drChRangeDef, drBoolRangeDef, drWCharRangeDef, drWideRangeDef:
          Rec := TRangeDef.Create;
        drEnumDef:
          Rec := TEnumDef.Create;
        drFloatDef:
          Rec := TFloatDef.Create;
        drPtrDef:
          Rec := TPtrDef.Create;
        drTextDef:
          Rec := TTextDef.Create;
        drFileDef:
          Rec := TFileDef.Create;
        drSetDef:
          Rec := TSetDef.Create;
        drShortStrDef:
          Rec := TShortStrDef.Create;
        drStringDef, drWideStrDef:
          Rec := TStringDef.Create;
        drArrayDef:
          Rec := TArrayDef.Create(false{IsStr});
        drVariantDef:
          Rec := TVariantDef.Create;
        drObjVMTDef:
          Rec := TObjVMTDef.Create;
        drRecDef:
          Rec := TRecDef.Create;
        drProcTypeDef:
          Rec := TProcTypeDef.Create;
        drObjDef:
          Rec := TObjDef.Create;
        drClassDef:
          Rec := TClassDef.Create;
        drMetaClassDef:
          begin
            if not ((Ver >= verD8) and (Ver < verK1)) then
              break;
            Rec := TMetaClassDef.Create;
          end;
        drInterfaceDef:
          TInterfaceDef.Create;
        drVoid:
          TVoidDef.Create; {May be end of interface}
      {----------------------------------------------------}
        drCBlock:
          begin
            if LK <> dlMain then
              Break;
            if FDataBlPtr <> Nil then
              DCUError('2nd Data block');
            FDataBlSize := ReadUIndex;
            FDataBlPtr := ReadMem(FDataBlSize);
          end;
        drFixUp:
          LoadFixups;
      //The following tables are present only when debug info is on
        drCodeLines:
          LoadCodeLines;
        drLinNum:
          LoadLineRanges;
        drStrucScope:
          LoadStrucScope;
        drLocVarTbl:
          LoadLocVarTbl;
      //Present if symbol info is on
        drSymbolRef:
          LoadSymbolInfo;
      //ver70
        drUnitAddInfo:
          begin
            if not ((Ver >= verD7) and (Ver < verK1)) then
              break;
            Decl := ReadUnitAddInfo;
          end;
        drConstAddInfo:
          begin
            if not ((Ver >= verD7) and (Ver < verK1) or (Ver >= verK3)) then
              break;
        //used for deprecated and other additional information
            ReadConstAddInfo(LastProcDecl);
          end;
        drProcAddInfo:
          begin
            if not ((Ver >= verD7) and (ver < verK1)) then
              break;
         {if (LK<>dlMain)and(Ver=verD7) then
           Break; The sample was presented by Hans Meier}
            V := ReadIndex; {B := ReadByte;} //Skip the byte, it was =2 after Finalization
             //and =FE after initialization
        // if (LK=dlMain) then
            SetProcAddInfo(V{,LastProcDecl});
          end;
        drNextOverload:
          begin
            if not (Ver >= verD_XE7) and (Ver < verK1) then
              break;
            V := ReadUIndex; //Was observed after overloaded proc header before args
         //contains index of the next overload of the procedure, 0 => the last overload
            RefAddrDef(V);
          end;
        drORec:
          begin
            if not ((Ver >= verD8) and (Ver < verK1)) then
              break;
            if Ver >= verD2009 then
              Decl := TORecDecl.Create
            else
              ReadUIndex;
          end;
        drInfo98:
          begin
            if not ((Ver >= verD3) and (Ver < verK1)) then
              break;
         {if Ver=verD7 then
           ReadUIndex
         else}
            ReadByte;
            ReadUIndex;
          end;
        drCLine:
          begin //Lines of C text, just ignore them by now
            if not ((Ver >= verD2006) and (Ver < verK1)) then
              break;
            if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
              X := ReadByte; //ReadUIndex;
            V := ReadUIndex; //Length of the line
            SkipBlock(V); //Line chars
          end;
        drA1Info:
          begin //Some record of 6 indices, ignore it completely
            if not ((Ver >= verD2006) and (Ver < verK1){or FromPackage}) then
              break;
            ReadUIndex;
            ReadUIndex;
            ReadUIndex;
            ReadUIndex;
            V := ReadUIndex;
            for i := 1 to V do
              ReadUIndex;
          end;
        drA2Info:
          begin
            if not ((Ver >= verD2006) and (Ver < verK1)) then
              break;
         //No data for this tag
          end;
        arCopyDecl:
          begin
            if not ((Ver >= verD2006) and (Ver < verK1)) then
              break;
            Decl := TCopyDecl.Create;
          end;
        drA5Info:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
         //No data for this tag
          end;
        drA6Info:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Decl{Rec}  := TA6Def.Create;
          end;
        drA7Info:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Rec := TA7Def.Create;
          end;
        drA8Info:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            ReadUIndex; //!!!M.b. some DCU record to be created
          end;
        drA9Info:
          begin
            if not ((Ver >= verD_XE4) and (Ver < verK1)) then
              break;
            ReadUIndex; //!!!M.b. some DCU record to be created
          end;
        drDynArrayDef:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Rec := TDynArrayDef.Create;
          end;
        drTemplateArgDef:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Rec := TTemplateArgDef.Create;
          end;
        drTemplateCall:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Rec := TTemplateCall.Create;
          end;
        drUnicodeStringDef:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Rec := TStringDef.Create;
          end;
        arAnonymousBlock:
          begin
            if not ((Ver >= verD2010) and (Ver < verK1)) then
              break;
            ReadUIndex; //!!!M.b. some DCU record to be created
            ReadUIndex;
          end;
        drDelayedImpInfo:
          begin
            if not ((Ver >= verD2009) and (Ver < verK1)) then
              break;
            Decl := TDelayedImpRec.Create;
          end;
       //verD_XE2:
        drSegInfo:
          begin
            if not ((Ver >= verD_XE2) and (Ver < verK1)) then
              break;
            V := ReadUIndex;
            for i := 1 to V do
            begin
              ReadStr;
              ReadByte;
              ReadUIndex;
            end;
          end;
        drB2Info:
          begin
            if not ((Ver >= verD_XE2) and (Ver < verK1)) then
              break;
            V := ReadUIndex;
            for i := 1 to V do
            begin
              ReadUIndex;
              ReadUIndex;
              ReadByte;
              ReadUIndex;
              ReadUIndex;
              ReadUIndex;
              ReadUIndex;
            end;
          end;
        drAssemblyData:
          begin
            if not ({(Ver=verD8)and(Ver<verK1)and} FromPackage and IsMSIL) then
              break;
            Decl := TAssemblyData.Create;
          end;
        arFinalFlag:
          begin
            if not ((Ver >= verD_XE3) and (Ver < verK1)) then
              break;
            V := ReadUIndex; //!!!Should mark the previous method as final when V=#10
          end;
      else
        Break;
        //DCUErrorFmt('Unexpected tag: %s(%x)',[Tag,Byte(Tag)]);
      end;
    finally
      if Decl <> Nil then
      begin
        DeclEnd^ := Decl;
        DeclEnd := @Decl.Next;
      end
      else if Rec <> Nil then
      begin
        Rec.Next := FOtherRecords;
        FOtherRecords := Rec;
      end;
    end;
    Tag := ReadTag;
  end;
 { if Embedded<>Nil then begin
    if IsMSIL and(LK=dlEmbedded)or //A lot of files contain additional
         //drEmbeddedProcStart - drEmbeddedProcEnd brackets for aux record
      (CurUnit.Ver>=verD2010)and(CurUnit.Ver<verK1)and
      ((LK in [dlArgs,dlArgsT])or(LK=dlEmbedded)and(Result=Nil)) //anonymous
          //functions (dlArgsT) and Templates dlArgs with double dlEmbedded
    then
      DeclEnd^ := Embedded
    else begin
      FreeDCURecList(Embedded);
      TagError('Unused embedded list');
    end ;
  end ;}
end;

var
  TstDeclCnt: integer = 0;

function TUnit.ShowDeclList(LK: TDeclListKind; MainRec: TDCURec; Decl: TDCURec{TNameDecl}; Ofs: Cardinal; dScopeOfs: integer; SepF: TDeclSepFlags; ValidKinds: TDeclSecKinds; skDefault: TDeclSecKind): TDeclSecKind;
const
  SecNames: array[TDeclSecKind] of AnsiString = ('', 'label', 'const', 'type', 'var', 'threadvar', 'resourcestring', 'exports', '', 'private', 'protected', 'public', 'published');
var
  DeclCnt: integer;
  SepCh: AnsiChar;
  SecN: AnsiString;
  SK: TDeclSecKind;
  Ofs0: Cardinal;
  Visible, NLRq: boolean;
  MainRec0: TDCURec;
  CurDeclList0: TDCURec{TNameDecl};
var {for dsSmallSameNL:}
  LStart: integer;
  PrevDecl: TDCURec{TNameDecl};
  NP, PrevNP: PName;
  TD: TTypeDef;
begin
  DeclCnt := 0;
  if dsComma in SepF then
    SepCh := ','
  else
    SepCh := ';';
  MainRec0 := CurMainRec;
  CurMainRec := MainRec;
  CurDeclList0 := CurDeclList;
  CurDeclList := Decl;
  try
    Result := skDefault;
    Ofs0 := Writer.NLOfs;
    Writer.NLOfs := Ofs + dScopeOfs;
    LStart := -1;
    PrevDecl := Nil;
    while Decl <> Nil do
    begin
      Inc(TstDeclCnt);
      Visible := Decl.IsVisible(LK);
      if Visible then
      begin
        SK := Decl.GetSecKind;
        {if not(SK in ValidKinds) then
          SK := skNone; I'll better show the kind commented out}
        if (DeclCnt > 0) then
        begin
          PutCh(SepCh);
          if dsNL in SepF then
          begin
            if dsSoftNL in SepF then
              SoftNL
            else
              NL;
          end;
        end;
        if (LK = dlClass) and (SK = Result) and (Decl.GetTag = arFld) and (PrevDecl <> Nil) and (PrevDecl.GetTag <> arFld) then
          Result := skNone; //Force separator before field after method or property
        NLRq := false;
        if (SK <> Result) then
        begin
          Result := SK;
          Writer.NLOfs := Ofs;
          SecN := SecNames[SK];
          if SecN <> '' then
          begin
            NL;
            if not (SK in ValidKinds) then
            begin
              RemOpen;
              PutS(SecN);
              RemClose;
            end
            else
              PutKW(SecN);
          end;
          if (SK <> skProc) or (dsOfsProc in SepF) then
            ShiftNLOfs(dScopeOfs);
          NLRq := true;
        end;
        if (DeclCnt > 0) or not (dsNoFirst in SepF) then
        begin
          if dsSoftNL in SepF then
            SoftNL
          else
          begin
            if not NLRq then
            begin
              NLRq := true;
             {Use simple heuristics: no empty line between one line declaration
              and the next one, if their names are same (same 1st char)}
              if (dsSmallSameNL in SepF) and (Writer.OutLineNum = LStart + 1) then
              begin
                if Result <> skType then
                begin
                  NP := Decl.Name;
                  PrevNP := PrevDecl.Name;
                  NLRq := NP^.Get1stChar <> PrevNP^.Get1stChar;
                end
                else
                begin
                  if (PrevDecl <> Nil) and (PrevDecl is TTypeDecl) and (Decl is TTypeDecl) then
                  begin
                    TD := GetTypeDef(TTypeDecl(PrevDecl).hDef);
                    if (TD <> Nil) and (TD is TPtrDef) then
                      NLRq := TPtrDef(TD).hRefDT <> TTypeDecl(Decl).hDef;
                  end;
                end;
              end;
            end;
          end;
        end;
        if NLRq then
          NL;
        LStart := Writer.OutLineNum;
        PrevDecl := Decl;
        case LK of
          dlMain:
            Decl.ShowDef(false);
          dlMainImpl:
            Decl.ShowDef(true);
          dlA6:
            begin
              TD := Nil;
              if Decl is TTypeDecl then
              begin
                TD := GetTypeDef(TTypeDecl(Decl).hDef);
                if (TD <> Nil) and (TD is TTemplateArgDef) then
                  Decl.ShowName
                else
                  TD := Nil;
              end;
              if TD = Nil then
                Decl.Show; //Just in case
            end;
        else
          Decl.Show;
        end;
        Inc(DeclCnt);
      end;
      Decl := Decl.Next {as TNameDecl};
    end;
    if (DeclCnt > 0) and (dsLast in SepF) then
    begin
      PutCh(SepCh);
      {if dsNL in SepF then
        NL;}
    end;
    Writer.NLOfs := Ofs0;
  finally
    CurDeclList := CurDeclList0;
    CurMainRec := MainRec0;
  end;
end;

procedure ShowDeclTList(Title: AnsiString; L: TList);
var
  i: integer;
  D: TDCURec;
begin
  Writer.NLOfs := 0;
  NL;
  NL;
  PutKW(Title);
  for i := 1 to L.Count do
  begin
    Writer.NLOfs := 2;
    NL;
    PutSFmt('#%x: ', [i]);
    D := L[i - 1];
    if D <> Nil then
    begin
      if D is TNameDecl then
      begin
        //if not TNameDecl(D).ShowDef(false) then
        TNameDecl(D).ShowName;
      end
      else if D is TBaseDef then
        TBaseDef(D).ShowNamed(Nil)
      else
        D.Show;
    end
    else
      PutCh('-');
  end;
end;

{ Two methods against circular references }
function TUnit.RegTypeShow(T: TBaseDef): boolean;
begin
  Result := false;
  if FTypeShowStack.IndexOf(T) >= 0 then
    Exit;
  FTypeShowStack.Add(T);
  Result := true;
end;

procedure TUnit.UnRegTypeShow(T: TBaseDef);
var
  C: integer;
begin
  C := FTypeShowStack.Count - 1;
  if (C < 0) or (FTypeShowStack[C] <> T) then
    DCUError('in UnRegTypeShow');
  FTypeShowStack.Count := C;
end;
{
function TUnit.RegDataBl(BlSz: Cardinal): Cardinal;
begin
  Result := FDataBlOfs;
  Inc(FDataBlOfs,BlSz);
end ;
}

function TUnit.GetBlockMem(BlOfs, BlSz: Cardinal; var ResSz: Cardinal): Pointer;
{var
  EOfs: Cardinal;}
begin
  Result := Nil;
  ResSz := BlSz;
  if (FDataBlPtr = Nil) or (integer(BlOfs) < 0) or (BlSz = 0) then
    Exit;
 // EOfs := BlSz+BlOfs;
  if BlSz + BlOfs > FDataBlSize then
  begin
    BlSz := FDataBlSize - BlOfs;
    if integer(BlSz) <= 0 then
      Exit;
  end;
  Result := FDataBlPtr + BlOfs;
  ResSz := BlSz;
end;

procedure TUnit.ShowDataBl(Ofs0, BlOfs, BlSz: Cardinal);
var
  Fix0: integer;
  DP{,FOfs0}: TIncPtr;
begin
  PutKW('raw');
  PutSFmt('[$%x..$%x]', [Ofs0, BlSz - 1]);
  if BlOfs <> Cardinal(-1) then
  begin
    PutKWSp('at');
    PutSFmt('$%x', [BlOfs]);
  end;
  DP := GetBlockMem(BlOfs + Ofs0, BlSz - Ofs0, BlSz);
  if DP = Nil then
    Exit;
//  Inc(NLOfs,2);
  NL;
  Fix0 := GetStartFixup(BlOfs + Ofs0);
  {FOfs0 := Nil;
  if ShowFileOffsets then
    FOfs0 := FMemPtr;}
  ShowDump(DP, FMemPtr{FOfs0}, FMemSize, 0, BlSz, Ofs0, BlOfs + Ofs0, 0, FFixupCnt - Fix0, @FFixupTbl^[Fix0], true, ShowFileOffsets);
//  Dec(NLOfs,2);
end;

procedure TUnit.ShowDataBlP(DP: Pointer; DS, Ofs0: Cardinal);
begin
  if (TIncPtr(DP) >= FDataBlPtr) and (TIncPtr(DP) < FDataBlPtr + FDataBlSize) then
    {CurUnit.}    ShowDataBl(Ofs0, TIncPtr(DP) - FDataBlPtr, DS)
  else
  begin
    NL;
    {FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;}
    ShowDump(DP, FMemPtr{FOfs0}, FMemSize, 0, DS, Ofs0, Ofs0, 0, 0, Nil, false, ShowFileOffsets);
  end;
end;

procedure TUnit.DasmCodeBlSeq(Ofs0, BlOfs, BlSz, SzMax: Cardinal);
var
  CmdOfs, OfsInProc, CmdSz: Cardinal;
  DP: Pointer;
  Fix0, hCL0, hLR0, L: integer;
  CL: TCodeLineRec;
  LR: TLineRangeRec;
  Ok: boolean;
  S: string;
  {FOfs0: PChar;}
begin
  DP := GetBlockMem(BlOfs, BlSz, BlSz);
  if DP = Nil then
    Exit;
{  OpenAux;
//  Inc(NLOfs,2);
  NL;
  CloseAux;}

  CmdOfs := BlOfs;
  Fix0 := GetStartFixup(BlOfs);
  hCL0 := GetStartCodeLine(BlOfs);
  GetCodeLineRec(hCL0, CL);
  hLR0 := GetStartLineRange(CL.L);
  GetLineRange(hLR0, LR);
  if SzMax <= 0 then
    SzMax := BlSz + Ofs0;
  SetCodeRange(FDataBlPtr, TIncPtr(DP) - Ofs0, BlSz + Ofs0);
  while true do
  begin
    while CmdOfs >= CL.Ofs do
    begin
      ShiftNLOfs(-2);
      NL;
      L := CL.L;
      if LR.SrcF <> Nil then
        Inc(L, LR.Line0 - LR.Num0 - 1);
      RemOpen0;
      PutSFmt('// -- Line #%d -- ', [L]);
      if LR.SrcF = Nil then
        PutS('in ? ')
      else if LR.SrcF <> FSrcFiles then
        PutSFmt('in %s', [LR.SrcF^.Def^.Name.GetStr]);
      if CmdOfs > CL.Ofs then
        PutSFmt('<<%d', [CmdOfs - CL.Ofs]);
      if (LR.SrcF <> Nil) and (LR.SrcF^.Lines <> Nil) and (L > 0) and (L <= LR.SrcF^.Lines.Count) then
      begin
        S := LR.SrcF^.Lines[L - 1];
        if S <> '' then
        begin
          NL;
          PutSFmt('//%s', [S]);
        end;
      end;
      RemClose0;
      ShiftNLOfs(2);
      Inc(hCL0);
      GetCodeLineRec(hCL0, CL);
      if CL.L > LR.Num0 + LR.LineNum then
      begin
        Inc(hLR0);
        GetLineRange(hLR0, LR);
      end;
    end;
    NL;
    CodePtr := FDataBlPtr + CmdOfs;
    SetStartFixupInfo(Fix0);
    Ok := Disassembler.ReadCommand;
    if Ok then
      CmdSz := CodePtr - PrevCodePtr
    else if FixUpEnd > PrevCodePtr then
      CmdSz := FixUpEnd - PrevCodePtr
    else
      CmdSz := 1;
    {FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;}
    OfsInProc := CmdOfs - BlOfs + Ofs0;
    ShowDump(FDataBlPtr + CmdOfs, FMemPtr{FOfs0}, FMemSize, SzMax - OfsInProc{BlSz+Ofs0}, CmdSz, OfsInProc, CmdOfs, 7, FFixupCnt - Fix0, @FFixupTbl^[Fix0], not Ok, ShowFileOffsets);
    PutCh(' ');
    if not Ok then
    begin
      PutCh('?');
    end
    else
    begin
      Disassembler.ShowCommand;
    end;
    Dec(BlSz, CmdSz);
    if BlSz <= 0 then
      Break;
    Inc(CmdOfs, CmdSz);
    Fix0 := GetNextFixup(Fix0, CmdOfs);
  end;
//  Dec(NLOfs,2);
end;

type
  TDasmCodeBlState = record
    Proc: TProc;
    Ofs0, BlOfs, CmdOfs, CmdEnd: Cardinal;
    Seq: TCmdSeq;
  end;

procedure RegCommandRef(RefP: LongInt; RefKind: Byte; IP: Pointer);
var
  {DP: Pointer;
  Ofs: LongInt;}
  RefSeq: TCmdSeq;
begin
  with TDasmCodeBlState(IP^) do
  begin
    if (RefP > CmdOfs) and (RefP < CmdEnd) then
      CmdEnd := RefP;
    RefSeq := Proc.AddSeq(RefP - BlOfs + Ofs0);
    if RefSeq = Nil then
      Exit;
    if RefKind = crJCond then
      Seq.SetCondNext(RefSeq)
    else
      Seq.SetNext(RefSeq);
  end;
end;

procedure TUnit.DasmCodeBlCtlFlow(Ofs0, BlOfs, BlSz: Cardinal);
var
  St: TDasmCodeBlState;
  {CmdOfs,CmdEnd,}  CmdSz: Cardinal;
  i: integer;
  DP: Pointer;
  Fix0, hCL0, hCL{,hLR0,L}: integer;
  CL: TCodeLineRec;
  {LR: TLineRangeRec;
  Ok: boolean;}
  //S: AnsiString;
var
  {Seq,}  Seq1: TCmdSeq;
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
    {FOfs0: PChar;}
  begin
    if St.CmdEnd >= St.CmdOfs then
      Exit;
    NL;
    Fix0 := GetStartFixup(St.CmdEnd);
    {FOfs0 := Nil;
    if ShowFileOffsets then
      FOfs0 := FMemPtr;}
    ShowDump(FDataBlPtr + St.CmdEnd, FMemPtr{FOfs0}, FMemSize, BlSz + St.Ofs0, St.CmdOfs - St.CmdEnd, St.CmdEnd - St.BlOfs + St.Ofs0, St.CmdEnd, 0, FFixupCnt - Fix0, @FFixupTbl^[Fix0], true, ShowFileOffsets);
  end;

begin
  DP := GetBlockMem(BlOfs, BlSz, BlSz);
  if DP = Nil then
    Exit;
  St.Ofs0 := Ofs0;
  St.BlOfs := BlOfs;
  St.Proc := TProc.Create(St.Ofs0, BlSz);
  try
   //If the line numbers info is present, include every line
   //start as a separate code sequence start (anyway, our decompiler
   //shouldn't be too smart to try to merge the commands from several lines
   //into a single operator):
    hCL0 := GetStartCodeLine(St.BlOfs);
    hCL := hCL0;
    St.CmdOfs := St.BlOfs + BlSz;
    while true do
    begin
      GetCodeLineRec(hCL, CL);
      if CL.Ofs >= St.CmdOfs then
        break;
      St.Proc.AddSeq(CL.Ofs - St.BlOfs + St.Ofs0);
      Inc(hCL);
    end;
    while true do
    begin
      hCurSeq := St.Proc.GetNotReadySeqNum;
      St.Seq := St.Proc.GetCmdSeq(hCurSeq);
      if St.Seq = Nil then
        break;
      MaxSeqSz := St.Proc.GetMaxSeqSize(hCurSeq);
      St.CmdOfs := St.Seq.Start + St.BlOfs - St.Ofs0;
      Fix0 := GetStartFixup(St.CmdOfs);
      St.CmdEnd := St.CmdOfs + MaxSeqSz;
      SetCodeRange(FDataBlPtr, TIncPtr(DP) - St.Ofs0 + St.CmdOfs - St.BlOfs, St.CmdEnd);
      while true do
      begin
        if St.CmdOfs >= St.CmdEnd then
        begin
          St.Proc.ReachedNextS(St.Seq);
          break;
        end;
        CodePtr := FDataBlPtr + St.CmdOfs;
        SetStartFixupInfo(Fix0);
        if not Disassembler.ReadCommand then
          break;
        CmdSz := CodePtr - PrevCodePtr;
        St.Seq.AddCmd(St.CmdOfs - St.BlOfs + St.Ofs0, CmdSz);
        Inc(St.CmdOfs, CmdSz);
        case Disassembler.CheckCommandRefs(RegCommandRef, St.CmdOfs, @St) of
          crJmp:
            break;
          crJCond:
            if St.CmdOfs < St.CmdEnd then
            begin
              Seq1 := St.Proc.AddSeq(St.CmdOfs - St.BlOfs + St.Ofs0);
              St.Seq.SetNext(Seq1);
              St.Seq := Seq1;
            end;
        end;
          //Cmd interrupts sequence (Jmp or Ret)
        Fix0 := GetNextFixup(Fix0, St.CmdOfs);
      end;
    end;
    St.CmdOfs := St.BlOfs;
    St.CmdEnd := St.BlOfs;
    for i := 0 to St.Proc.Count - 1 do
    begin
      St.Seq := St.Proc.GetCmdSeq(i);
      St.CmdOfs := St.BlOfs + St.Seq.Start - St.Ofs0;
      ShowNotParsedDump;
      ShiftNLOfs(-2);
      NL;
      RemOpen0;
      PutSFmt('// -- Part #%d -- ', [i]);
      RemClose0;
      ShiftNLOfs(2);
      DasmCodeBlSeq(St.Seq.Start, St.CmdOfs, St.Seq.Size, BlSz + St.Ofs0);
      St.CmdEnd := St.CmdOfs + St.Seq.Size;
    end;
    St.CmdOfs := St.BlOfs + BlSz;
    ShowNotParsedDump;
  finally
    St.Proc.Free;
  end;
end;

function TUnit.ShowMSILExcHandlers(Ofs0, BlOfs, Sz: Cardinal): Cardinal;
var
  DP: Pointer;
  Rest, Al, Sz0, ElSz: Cardinal;
  IsFat: Boolean;
  F, TblSz: LongInt;
  ECF: PMSILFatExcClause;
  ECBuf: TMSILFatExcClause;
  ECS: PMSILSmallExcClause;
begin
  Result := 0;
  Al := ((Ofs0 + 3) and not 3) - Ofs0; //align to 4
  if Al + 4 > Sz then
    Exit;
  Inc(Ofs0, Al);
  Sz0 := Sz;
  Dec(Sz, Al);
  DP := GetBlockMem(BlOfs + Ofs0, Sz, Rest);
  if DP = Nil then
    Exit;
  repeat
    F := LongInt(DP^);
    if F and $3 <> CorILMethod_Sect_EHTable then
      break;
    IsFat := (F and CorILMethod_Sect_FatFormat) <> 0;
    if IsFat then
      ElSz := SizeOf(TMSILFatExcClause)
    else
      ElSz := SizeOf(TMSILSmallExcClause);
    TblSz := (F shr 8) and $FFFFFF;
    if (TblSz < SizeOf(LongInt)) or (TblSz > Sz) or (TblSz mod ElSz <> SizeOf(LongInt)) then
      break;
    Dec(Sz, TblSz);
    PutS('Exception handlers table');
    ShiftNLOfs(2);
    Inc(TIncPtr(DP), SizeOf(LongInt));
    Dec(TblSz, SizeOf(LongInt));
    while TblSz > 0 do
    begin
      if IsFat then
        ECF := DP
      else
      begin
        ECS := DP;
        ECBuf.Flags := ECS^.Flags;
        ECBuf.TryOffset := ECS^.TryOffset;
        ECBuf.TryLength := ECS^.TryLength;
        ECBuf.HandlerOffset := ECS^.HandlerOffset;
        ECBuf.HandlerLength := ECS^.HandlerLength;
        ECBuf.ClassToken := ECS^.ClassToken;
       // ECBuf.FilterOffset := ECS^.FilterOffset;
        ECF := @ECBuf;
      end;
      NL;
      PutsFmt('[Kind:%d,Try:%x[%x],Handler:%x[%x],TokenOrFilter:%x]', [ECF^.Flags, ECF^.TryOffset, ECF^.TryLength, ECF^.HandlerOffset, ECF^.HandlerLength, ECF^.ClassToken]);
      Inc(TIncPtr(DP), ElSz);
      Dec(TblSz, ElSz);
    end;
    ShiftNLOfs(-2);
    NL;
  until F and CorILMethod_Sect_MoreSects = 0;
  Result := Sz0 - Sz;
end;

procedure TUnit.ShowCodeBl(Ofs0, BlOfs, BlSz: Cardinal);
var
  MSILHdr: PMSILHeader;
  Sz, CodeSz: Cardinal;
begin
  CodeSz := BlSz;
  if IsMSIL then
  begin
    if BlSz - Ofs0 <= SizeOf(TMSILHeader) then
    begin
      NL;
      ShowDataBl(Ofs0, BlOfs, Ofs0 + BlSz);
      Exit; //Wrong size
    end;
    {NL;
    ShowDataBl(Ofs0,BlOfs,Ofs0+BlSz); //!!!Temp
    NL;}
    MSILHdr := GetBlockMem(BlOfs + Ofs0, SizeOf(TMSILHeader), Sz);
    if MSILHdr = Nil then
    begin
      ShowDataBl(Ofs0, BlOfs, Ofs0 + BlSz);
      Exit; //Error reading MSIL header
    end;
    if Ofs0 = Cardinal(-1) then
      Ofs0 := 0;
   //1st 3 dwords - some info about proc.
    CodeSz := MSILHdr^.CodeSz;
    if CodeSz > BlSz then
      CodeSz := BlSz; //Just in case
    PutsFmt('[Flags:%4.4x,MaxStack:%d,CodeSz:%x,LocalVarSigTok:%d]', [MSILHdr^.Flags, MSILHdr^.MaxStack, MSILHdr^.CodeSz, MSILHdr^.LocalVarSigTok]);
    NL;
//    Inc(Ofs0,SizeOf(TMSILHeader));
    Inc(BlOfs, SizeOf(TMSILHeader));
    Dec(BlSz, SizeOf(TMSILHeader));
  end;
  OpenAux;
  RemOpen0;
  if Ofs0 = 0 then
    PutSFmt('//raw[0x%x]', [CodeSz])
  else
    PutSFmt('//raw[0x%x..0x%x]', [Ofs0, Ofs0 + CodeSz]);
  if BlOfs <> Cardinal(-1) then
    PutSFmt('at 0x%x', [BlOfs]);
  RemClose0;
  CloseAux;
  if IsMSIL then
    SetMSILDisassembler
  else
    Set80x86Disassembler(FPlatform = dcuplWin64{I64});
  case DasmMode of
    dasmSeq:
      DasmCodeBlSeq(Ofs0, BlOfs, CodeSz, 0);
    dasmCtlFlow:
      DasmCodeBlCtlFlow(Ofs0, BlOfs, CodeSz);
  end;
  if CodeSz < BlSz then
  begin
    NL;
    if IsMSIL then
      Inc(CodeSz, ShowMSILExcHandlers(Ofs0 + CodeSz, BlOfs, BlSz - CodeSz));
    if CodeSz < BlSz then
    begin
      PutS('rest:');
      NL;
      ShowDataBl(Ofs0 + CodeSz, BlOfs{+CodeSz}, Ofs0 + BlSz);
    end;
  end;
end;

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
  Decl: TDCURec{TNameDecl};
  NDX: integer;
  UnitNames: TStringList;
  UI, UI1: PUnitImpRec;
  NameP: PName;
  Name: AnsiString;
  i, j: integer;
  D: TDCURec;
  IsUnique: boolean;
begin
 {Check whether all the imported units where found}
  for i := 0 to FUnitImp.Count - 1 do
  begin
    UI := PUnitImpRec(FUnitImp[i]);
    if ufDLL in UI^.Flags then
      Continue;
    if (GetUnitImp(i) = Nil) and (UI^.Decls <> Nil{This check is for those pseudo-units of MSIL like .mscorlib}) then
    begin
      DCUWarningFmt('used unit "%s" not found or incorrect - ' + 'all imported names will be shown with unit names', [UI^.Name^.GetStr]);
      Exit;
    end;
  end;
  UnitNames := TStringList.Create;
  try
    UnitNames.Sorted := true;
    UnitNames.Duplicates := dupIgnore;
    Decl := FDecls;
    while Decl <> Nil do
    begin
      NameP := Decl.Name;
      if NameP <> Nil then
      begin
        Name := NameP^.GetStr;
        if Name <> '' then
          UnitNames.Add(Name);
      end;
      Decl := Decl.Next {as TNameDecl};
    end;
    for i := 0 to FUnitImp.Count - 1 do
    begin
      UI := PUnitImpRec(FUnitImp[i]);
      if ufDLL in UI^.Flags then
        Continue {DLL names can't be referenced in code};
      D := UI^.Decls;
      while D <> Nil do
      begin
        if (D is TImpDef) then
        begin
          Name := D.Name^.GetStr;
          IsUnique := true;
          if UnitNames.Find(Name, NDX) then
            IsUnique := false
          else
            for j := 0 to FUnitImp.Count - 1 do
              if j <> i then
              begin
                UI1 := PUnitImpRec(FUnitImp[j]);
                if ufDLL in UI1^.Flags then
                  Continue;
                if UI1^.Decls = Nil then
                  Continue;
                if UI1^.U.ExportDecls[Name, 0] <> Nil then
                begin
                  IsUnique := false;
                  Break;
                end;
              end;
          TImpDef(D).FNameIsUnique := IsUnique;
        end;
        D := D.Next as TBaseDef;
      end;
    end;
  finally
    UnitNames.Free;
  end;
end;

constructor TUnit.Create;
begin
  inherited Create;
end;

procedure TUnit.ReadMagic;
var
  Magic: ulong;
begin
  Magic := ReadULong;
  FPtrSize := 4;
  case Magic of
    $50505348:
      FVer := verD2;
    $44518641:
      FVer := verD3;
    $4768A6D8:
      FVer := verD4;
    ulong($F21F148B):
      FVer := verD5;
    $0E0000DD, $0E8000DD{Was observed too. Why differs?}:
      FVer := verD6;
    ulong($FF0000DF){Free}, $0F0000DF, $0F8000DF:
      FVer := verD7;
    $10000229:
      begin
        FVer := verD8;
        FIsMSIL := true;
      end;
    $11000239:
      begin
        FVer := verD2005;
        FIsMSIL := true;
      end;
    $1100000D, $11800009:
      FVer := verD2005;
    $1200024D:
      begin
        FVer := verD2006;
        FIsMSIL := true;
      end;
    $12000023:
      FVer := verD2006; //Delphi 2006, testing is very incomplete
    $14000039:
      FVer := verD2009;
    $15000045:
      FVer := verD2010;
    $1600034B:
      FVer := verD_XE;

    $1700034B:
      FVer := verD_XE2;
    $1700234B:
      begin
        FVer := verD_XE2;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1700044B:
      begin
        FVer := verD_XE2;
        FPlatform := dcuplOsx32;
      end;

    $1800034B:
      FVer := verD_XE3;
    $1800234B:
      begin
        FVer := verD_XE3;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1800044B:
      begin
        FVer := verD_XE3;
        FPlatform := dcuplOsx32;
      end;

    $1900034B:
      FVer := verD_XE4;
    $1900234B:
      begin
        FVer := verD_XE4;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1900044B:
      begin
        FVer := verD_XE4;
        FPlatform := dcuplOsx32;
      end;
    $1900144B:
      begin
        FVer := verD_XE4;
        FPlatform := dcuplIOSEmulator;
      end;
    $1900764B:
      begin
        FVer := verD_XE4;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $1A00034B:
      FVer := verD_XE5;
    $1A00234B:
      begin
        FVer := verD_XE5;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1A00044B:
      begin
        FVer := verD_XE5;
        FPlatform := dcuplOsx32;
      end;
    $1A00144B:
      begin
        FVer := verD_XE5;
        FPlatform := dcuplIOSEmulator;
      end;
    $1A00764B:
      begin
        FVer := verD_XE5;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1A00774B:
      begin
        FVer := verD_XE5;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $1B00034D:
      FVer := verD_XE6;
    $1B00234D:
      begin
        FVer := verD_XE6;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1B00044D:
      begin
        FVer := verD_XE6;
        FPlatform := dcuplOsx32;
      end;
    $1B00144D:
      begin
        FVer := verD_XE6;
        FPlatform := dcuplIOSEmulator;
      end;
    $1B00764D:
      begin
        FVer := verD_XE6;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1B00774D:
      begin
        FVer := verD_XE6;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $1C00034D:
      FVer := verD_XE7;
    $1C00234D:
      begin
        FVer := verD_XE7;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1C00044D:
      begin
        FVer := verD_XE7;
        FPlatform := dcuplOsx32;
      end;
    $1C00144D:
      begin
        FVer := verD_XE7;
        FPlatform := dcuplIOSEmulator;
      end;
    $1C00764D:
      begin
        FVer := verD_XE7;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1C00774D:
      begin
        FVer := verD_XE7;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    // Added by LiuXiao Begin.
    $1D00034D:
      FVer := verD_XE8;
    $1D00234D:
      begin
        FVer := verD_XE8;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1D00044D:
      begin
        FVer := verD_XE8;
        FPlatform := dcuplOsx32;
      end;
    $1D00144D:
      begin
        FVer := verD_XE8;
        FPlatform := dcuplIOSEmulator;
      end;
    $1D00764D:
      begin
        FVer := verD_XE8;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1D00774D:
      begin
        FVer := verD_XE8;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $1E00034D:
      FVer := verD_10S;
    $1E00234D:
      begin
        FVer := verD_10S;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1E00044D:
      begin
        FVer := verD_10S;
        FPlatform := dcuplOsx32;
      end;
    $1E00144D:
      begin
        FVer := verD_10S;
        FPlatform := dcuplIOSEmulator;
      end;
    $1E00764D:
      begin
        FVer := verD_10S;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1E00774D:
      begin
        FVer := verD_10S;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $1F00034D:
      FVer := verD_101B;
    $1F00234D:
      begin
        FVer := verD_101B;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $1F00044D:
      begin
        FVer := verD_101B;
        FPlatform := dcuplOsx32;
      end;
    $1F00144D:
      begin
        FVer := verD_101B;
        FPlatform := dcuplIOSEmulator;
      end;
    $1F00764D:
      begin
        FVer := verD_101B;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $1F00774D:
      begin
        FVer := verD_101B;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $2000034D:
      FVer := verD_102T;
    $2000234D:
      begin
        FVer := verD_102T;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $2000044D:
      begin
        FVer := verD_102T;
        FPlatform := dcuplOsx32;
      end;
    $2000144D:
      begin
        FVer := verD_102T;
        FPlatform := dcuplIOSEmulator;
      end;
    $2000764D:
      begin
        FVer := verD_102T;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $2000774D:
      begin
        FVer := verD_102T;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $2100034D:
      FVer := verD_103R;
    $2100234D:
      begin
        FVer := verD_103R;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $2100044D:
      begin
        FVer := verD_103R;
        FPlatform := dcuplOsx32;
      end;
    $2100144D:
      begin
        FVer := verD_103R;
        FPlatform := dcuplIOSEmulator;
      end;
    $2100764D:
      begin
        FVer := verD_103R;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $2100774D:
      begin
        FVer := verD_103R;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $2200034D:
      FVer := verD_104S;
    $2200234D:
      begin
        FVer := verD_104S;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $2200044D:
      begin
        FVer := verD_104S;
        FPlatform := dcuplOsx32;
      end;
    $2200144D:
      begin
        FVer := verD_104S;
        FPlatform := dcuplIOSEmulator;
      end;
    $2200764D:
      begin
        FVer := verD_104S;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $2200774D:
      begin
        FVer := verD_104S;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $2300034D:
      FVer := verD_110A;
    $2300234D:
      begin
        FVer := verD_110A;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $2300044D:
      begin
        FVer := verD_110A;
        FPlatform := dcuplOsx32;
      end;
    $2300144D:
      begin
        FVer := verD_110A;
        FPlatform := dcuplIOSEmulator;
      end;
    $2300764D:
      begin
        FVer := verD_110A;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $2300774D:
      begin
        FVer := verD_110A;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;

    $2400034D:
      FVer := verD_120A;
    $2400234D:
      begin
        FVer := verD_120A;
        FPlatform := dcuplWin64;
        FPtrSize := 8;
      end;
    $2400044D:
      begin
        FVer := verD_120A;
        FPlatform := dcuplOsx32;
      end;
    $2400144D:
      begin
        FVer := verD_120A;
        FPlatform := dcuplIOSEmulator;
      end;
    $2400764D:
      begin
        FVer := verD_120A;
        FPlatform := dcuplIOSDevice;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    $2400774D:
      begin
        FVer := verD_120A;
        FPlatform := dcuplAndroid;
      //The drCBlock section is missing here, all the memory is in the corresponding
      //*.o file. Or inline info decoding is required
      end;
    // Added by LiuXiao End.

    ulong($F21F148C):
      FVer := verK1; //Kylix 1.0
    $0E1011DD, $0E0001DD:
      FVer := verK2; //Kylix 2.0
    $0F1001DD, $0F0001DD:
      FVer := verK3; //Kylix 3.0
   //I guess some other magic values for Delphi 6.0, Kylix 2.0 and higher
   //versions are possible. One can easily add them here, and, please,
   //send me the file with different magic value.
  else
    FVer := verD_XE7;
    FPlatform := dcuplWin32;
//    DCUErrorFmt('Wrong magic: 0x%x', [Magic]);
  end;
end;

procedure TUnit.SetupFixups;
begin
  fxJmpAddr := fxJmpAddr0;
  if Ver = verD2 then
  begin
    fxStart := fxStart20;
    fxEnd := fxEnd20;
  end
  else if (Ver < verD7) or (Ver >= verK1) and (Ver <= verK2) then
  begin
    fxStart := fxStart30;
    fxEnd := fxEnd30;
  end
  else if (Ver >= verD2006) and (Ver <= verD2009) then
  begin
    fxStart := fxStart100;
    fxEnd := fxEnd100;
  end
  else if (Ver >= verD2010) and (Ver < verK1) then
  begin
    fxStart := fxStart2010;
    fxEnd := fxEnd2010;
    fxJmpAddr := fxJmpAddrXE; //Was checked for XE only
  end
  else if not IsMSIL then
  begin
    fxStart := fxStart70;
    fxEnd := fxEnd70;
  end
  else {IsMSIL}
  begin
    fxStart := fxStartMSIL;
    fxEnd := fxEndMSIL;
  end;
  if fxStart > 0 then
    fxValid := [0..fxStart - 1]
  else if (Ver < verD_XE2) or (FPlatform <> dcuplWin64) then
    fxValid := [fxEnd + 1..fxMaxXE]
  else
    fxValid := [fxEnd + 1..fxMax];
end;

procedure TUnit.ReadUnitHeader;
var
  FileSizeH, L, Flags1, L1, L2: ulong;
  B: Byte;
  FT: TDCUFileTime;
  SName: AnsiString;
begin
  FileSizeH := ReadULong;
  if FileSizeH <> FMemSize then
    DCUErrorFmt('Wrong size: 0x%x<>0x%x', [FMemSize, FileSizeH]);
  FT := ReadULong;
  if Ver = verD2 then
  begin
    B := ReadByte;
    Tag := ReadTag;
  end
  else
  begin
    FStamp := ReadULong;
    B := ReadByte;
    if (Ver >= verD7) and (Ver < verK1) then
    begin
      B := ReadByte; //It has another header byte (or index)
      AddAddrDef(Nil); //Self reference added
    end;
    if (Ver >= verD2005) and (Ver < verK1) then
      SName := ReadStr;
    if (Ver >= verD2009) and (Ver < verK1) then
    begin
      L1 := ReadUIndex;
      L2 := ReadUIndex;
    end;
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
    Tag := ReadTag;
    if Ver >= verK1 then
    begin
      if Tag = drUnit4 then
      begin
        repeat
          L := ReadULong;
          Tag := ReadTag;
        until Tag <> drUnit4;
      end
      else if Tag <> drUnitFlags then
      begin
        SkipBlock(3);
        Tag := ReadTag;
      end;
    end;
    if Tag = drUnitFlags then
    begin
      FFlags := ReadUIndex;
      if (Ver > verD2005) and (Ver < verK1) then
        Flags1 := ReadUIndex;
      if Ver > verD3 then
        FUnitPrior := ReadUIndex;
      Tag := ReadTag;
    end;
  end;
end;

function TUnit.Load(const FName: string; VerRq: integer; MSILRq: boolean; PlatformRq: TDCUPlatform; AMem: Pointer): boolean;
var
  F: file;
  CP0: TScanState;
begin
  Result := false;
  CurUnit := Self;
  if MainUnit = Nil then
    MainUnit := Self;
  FUnitImp := TList.Create;
  FTypes := TList.Create;
  FAddrs := TList.Create;
  FTypeShowStack := TList.Create;
  FEmbeddedLists := Nil;
  FDecls := Nil;
  FTypeDefCnt := 0;
//  FDefs := Nil;
  FFName := FName;
  FFExt := ExtractFileExt(FName);
  if AMem = Nil then
  begin
    AssignFile(F, FName);
    FileMode := 0; //Read only, helps with DCUs on CD
    Reset(F, 1);
    try
      FMemSize := FileSize(F);
      GetMem(FMemPtr, FMemSize);
      BlockRead(F, FMemPtr^, FMemSize);
    finally
      Close(F);
    end;
  end
  else
  begin
    FFromPackage := true;
    FMemPtr := AMem;
    FMemSize := PDCPUnitHdr(AMem)^.FileSize;
  end;
  ChangeScanState(CP0, FMemPtr, FMemSize);
  try
    ReadMagic;
    if (VerRq > 0) and ((FVer <> VerRq) or (MSILRq <> FIsMSIL) or (PlatformRq <> FPlatform)) then
      Exit;
    Result := true; //Required version found
    SetupFixups;
    ReadUnitHeader;
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
    try
      ReadDeclList(dlMain, FDecls);
      if not (platform in [dcuplIOSDevice, dcuplAndroid]) and ((FDataBlPtr = Nil) or (FFixupTbl = Nil)) then
       //Let's ignore unknown tags after drCBlock and drFixUp, but not before
        DCUError('stop tag');
      //if Tag<>drStop then
      //  DCUError({'Unexpected '+}'stop tag');
    finally
      if (Ver >= verD_XE) and (Ver < verK1) then
       //try to fix the local types relocation problem of XE
        BindEmbeddedTypes;
      SetExportNames(FDecls);
      SetEnumConsts(FDecls);
      FillProcLocVarTbls;
     // Show;
    end;
  finally
    FLoaded := true;
    RestoreScanState(CP0);
  end;
end;

destructor TUnit.Destroy;
var
  i: integer;
  U: PUnitImpRec;
  SFR: PSrcFileRec;
  TI: PEmbeddedTypeInf;
begin
  CurUnit := Self;
  FTypeShowStack.Free;
  if FLocVarTbl <> Nil then
    FreeMem(FLocVarTbl, FLocVarSize * SizeOf(TLocVarRec));
  if FLineRangeTbl <> Nil then
    FreeMem(FLineRangeTbl, FLineRangeCnt * SizeOf(TLineRangeRec));
  if FCodeLineTbl <> Nil then
    FreeMem(FCodeLineTbl, FCodeLineCnt * SizeOf(TCodeLineRec));
  if FFixupTbl <> Nil then
    FReeMem(FFixupTbl, FFixupCnt * SizeOf(TFixupRec));
//  FreeDCURecList(FDecls);
//  FreeDCURecList(FDefs);
  if FUnitImp <> Nil then
  begin
    for i := 0 to FUnitImp.Count - 1 do
    begin
      U := FUnitImp[i];
      FreeDCURecList(U^.Decls);
      U^.Ref.Free;
//      FreeDCURecList(U^.Addrs);
//      FreeDCURecList(U^.Types);
      Dispose(U);
    end;
    FUnitImp.Free;
  end;
  FExportNames.Free;
//  FreeDCURecTList(FTypes);
  FTypes.Free;
//  FreeDCURecTList(FAddrs);
  FAddrs.Free;
  FreeDCURecList(FDecls);
  FreeDCURecList(FOtherRecords);
//  FTypes.Free;
//  FAddrs.Free;
  while FSrcFiles <> Nil do
  begin
    SFR := FSrcFiles;
    FSrcFiles := SFR^.Next;
    SFR^.Lines.Free;
    Dispose(SFR);
  end;
  if not FFromPackage and (FMemPtr <> Nil) then
    FreeMem(FMemPtr, FMemSize);
  if MainUnit = Self then
    MainUnit := Nil;
  if FEmbeddedTypes <> Nil then
  begin
    for i := FEmbeddedTypes.Count - 1 downto 0 do
    begin
      TI := PEmbeddedTypeInf(FEmbeddedTypes[i]);
      if TI <> Nil then
        FreeMem(TI);
    end;
    FEmbeddedTypes.Free;
  end;
  if FEmbeddedLists <> Nil then
    FreeMem(FEmbeddedLists);
  inherited Destroy;
end;

procedure TUnit.DoShowFixupTbl;
var
  i: integer;
  FP: PFixupRec;
begin
  if FFixupTbl = Nil then
    Exit;
  PutSFmt('Fixups: %d', [FFixupCnt]);
  Writer.NLOfs := 2;
  FP := Pointer(FFixupTbl);
  for i := 0 to FFixupCnt - 1 do
  begin
    NL;
    PutSFmt('%3d: %6x K%2x %s', [i, FP^.OfsF and FixOfsMask, TByte4(FP^.OfsF)[3], GetAddrStr(FP^.NDX, true)]);
    Inc(FP);
  end;
  Writer.NLOfs := 0;
  NL;
  NL;
end;

procedure TUnit.FillProcLocVarTbls;
var
  i, iStart: integer;
  LVP: PLocVarRec;
  Proc: TProcDecl;
  D: TDCURec;
  f, ProcRec, PRCnt: integer;

  procedure FlushProc(i0, i1: integer);
  begin
    if Proc = Nil then
      Exit;
    Proc.FProcLocVarTbl := @(FLocVarTbl^[i0 + PRCnt + 1]);
    Proc.FProcLocVarCnt := i1 - i0 - PRCnt - 1;
  end;

begin
  if FLocVarTbl = Nil then
    Exit;
  LVP := Pointer(FLocVarTbl);
  ProcRec := 0;
  Proc := Nil;
  iStart := 0;
  PRCnt := 1 + Ord(platform = dcuplWin64);
  for i := 0 to FLocVarSize{FLocVarCnt} - 1 do
  begin
    f := LVP^.frame;
    D := Nil;
    if ProcRec > 0 then
      Dec(ProcRec)
    else if (LVP^.Sym <> 0) then
    begin
      D := GetAddrDef(LVP^.Sym);
      if D is TProcDecl then
      begin
        FlushProc(iStart, i);
        Proc := TProcDecl(D);
        iStart := i;
        ProcRec := PRCnt;
      end;
    end;
    Inc(LVP);
  end;
  FlushProc(iStart, FLocVarSize{FLocVarCnt});
end;

procedure TUnit.DoShowLocVarTbl;
var
  i: integer;
  LVP: PLocVarRec;
  D: TDCURec;
  S, S1: AnsiString;
  f, ProcRec, PRCnt, MaxReg: integer;
  RegNames: PRegNameTbl;
  Mode64: Boolean;
begin
  if FLocVarTbl = Nil then
    Exit;
  PutSFmt('Local Variables: %d', [FLocVarCnt]);
  ProcRec := 0;
  Writer.NLOfs := 2;
  LVP := Pointer(FLocVarTbl);
  PRCnt := 1 + Ord(platform = dcuplWin64);
  Mode64 := platform = dcuplWin64;
  if Mode64 then
  begin
    MaxReg := High(RegName64);
    RegNames := @RegName64;
  end
  else
  begin
    MaxReg := High(RegName);
    RegNames := @RegName;
  end;
  for i := 0 to FLocVarSize - 1 do
  begin
    NL;
    f := LVP^.frame;
    D := Nil;
    S1 := '';
    if ProcRec > 0 then
    begin
      S1 := IntToStr(LVP^.Sym); //Proc takes 2 (or 3 in 64bit mode) records => don't interpret the value
        //as an addr ref
    end
    else if LVP^.Sym <> 0 then
    begin
      D := GetAddrDef(LVP^.Sym);
      S1 := GetDCURecStr(D, LVP^.Sym, true);
      if D is TProcDecl then
      begin
        S1 := 'p:' + S1;
        ProcRec := PRCnt + 1;
      end;
    end;
    if (D = Nil) or (ProcRec > 0) then
      S := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%d', [f]) //Proc takes the record => don't interpret the value
        //as a frame
    else if (f >= 0) and (f <= MaxReg) then
      S := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s(%d)', [RegNames^[f], f])//RegNames^[f]
    else if f = -1 then
      S := '/'
    else if f > 0 then
      S := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('[EBP+%d]', [f])
    else
      S := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('[EBP%d]', [f]);
    PutSFmt('%4d: %4x %s %s', [i, LVP^.Ofs, S, S1]);
    Inc(LVP);
    if ProcRec > 0 then
      Dec(ProcRec);
  end;
  Writer.NLOfs := 0;
  NL;
  NL;
end;

procedure TUnit.Show;
begin
  if Self = Nil then
    Exit;
  CurUnit := Self;
  CodeMemBase := FMemPtr;
  if not ShowImpNamesUnits then
    DetectUniqueNames;
//  InitOut;
  SetShowAuxValues(ShowAuxValues);
  Writer.NLOfs := 0;
  ShowSourceFiles;
  PutKW('interface');
  Writer.NLOfs := 0;
  NL;
  if ShowUses('uses', []) then
  begin
    Writer.NLOfs := 0;
    NL;
    //NL;
  end;
  ShowDeclList(dlMain, Nil{MainRec}, FDecls, 0, 2, [dsLast, dsNL, dsSmallSameNL], BlockSecKinds, skNone);
  Writer.NLOfs := 0;
  NL;
  NL;
  if InterfaceOnly then
    Exit;
  PutKW('implementation');
  Writer.NLOfs := 0;
  NL;
  if ShowUses('uses', [ufImpl]) then
  begin
    Writer.NLOfs := 0;
    NL;
    //NL;
  end;
  if ShowUses('imports', [ufDLL]) then
  begin
    Writer.NLOfs := 0;
    //NL;
    NL;
  end;
  ShowDeclList(dlMainImpl, Nil{MainRec}, FDecls, 0, 2, [dsLast, dsNL, dsSmallSameNL], BlockSecKinds, skNone);
  Writer.NLOfs := 0;
  NL;
  NL;
  PutKW('end');
  PutCh('.');
  Writer.NLOfs := 0;
  NL;
  NL;
  if ShowTypeTbl then
  begin
    PutSFmt('Types defined: 0x%x of 0x%x', [FTypeDefCnt, FTypes.Count]);
    ShowDeclTList('types', FTypes);
    Writer.NLOfs := 0;
    NL;
    NL;
  end;
  if ShowAddrTbl then
  begin
    PutSFmt('Addrs defined: 0x%x', [FAddrs.Count]);
    ShowDeclTList('addrs', FAddrs);
    Writer.NLOfs := 0;
    NL;
    NL;
  end;
  if ShowDataBlock then
  begin
    PutSFmt('Data used: 0x%x of 0x%x ', [FDataBlOfs, FDataBlSize]);
    if (FDataBlPtr <> Nil){and(FDataBlOfs<FDataBlSize)} then
      ShowDataBl(FDataBlOfs, 0, FDataBlSize{-FDataBlOfs});
    Writer.NLOfs := 0;
    NL;
    NL;
  end;
  if ShowFixupTbl then
    DoShowFixupTbl;
  if ShowLocVarTbl then
    DoShowLocVarTbl;
  FlushOut;
end;

end.

